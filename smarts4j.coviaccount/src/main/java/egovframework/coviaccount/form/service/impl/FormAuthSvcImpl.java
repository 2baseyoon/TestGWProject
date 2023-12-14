package egovframework.coviaccount.form.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.service.CommonSvc;
import egovframework.coviaccount.form.dto.FormRequest;
import egovframework.coviaccount.form.dto.UserInfo;
import egovframework.coviaccount.form.service.FormAuthSvc;
import egovframework.coviaccount.user.service.ExpenceApplicationSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("formAuthService")
public class FormAuthSvcImpl extends EgovAbstractServiceImpl implements FormAuthSvc {
	Logger logger = LogManager.getLogger(FormAuthSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	ExpenceApplicationSvc expenceApplicationSvc;

	@Autowired
	CommonSvc commonSvc;

	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
	
	public boolean hasReadAuth(FormRequest formRequest, UserInfo userInfo){
		boolean hasReadAuth = true;
		if(isSaaS.equalsIgnoreCase("Y") && !isInDomain(formRequest.getFormInstanceID())) {
			// domain check only
			return false;
		}
		
		// Legacy에서 piid만 넘겨 왔을때 performer 정보 찾기에 대한 소스 생략됨            
		/*
		 * 문서 권한 체크 로직 변경 (2021-01-25)
		 * 관리자 외 해당 로직 모두 타도록 변경
		 * 결재자, 대결자, 담당업무함, 부서수신함, 업무문서함, 참조회람, 감사함, 연관문서, 사용자 문서 권한, 부서 문서 권한 부여, 집계함 체크
		 * 기밀문서는 연결문서라 하더라도 기존 로직에 따라 결재선에 포함되어 있지 않으면 보이지 않음.
		 */
		boolean authExceptModule = false;
		if (!formRequest.getGovState().isEmpty()
			|| (!formRequest.getIsOpen().isEmpty() && formRequest.getIsOpen().equalsIgnoreCase("bizmnt"))){ // 문서유통 or 사업관리 
			authExceptModule = true;
		}
		
		if (!SessionHelper.getSession("isAdmin").equals("Y") && !SessionHelper.getSession("isEasyAdmin").equals("Y") && !authExceptModule){ // 간편관리자 회사권한은 위 isInDomain에서 체크됨, saas n일때 필요시 isEasyAdmin 사용
			hasReadAuth = hasReadAuthDefault(formRequest, userInfo);
		}
		
		return hasReadAuth;
	}

	@Override
	public boolean hasReadAuthDefault(FormRequest formRequest, UserInfo userInfo) {
		String formInstID = formRequest.getFormInstanceID();
		String bStored = formRequest.getBstored();

		CoviMap params = new CoviMap();
		params.put("FormInstID", formInstID);
		params.put("UserID", userInfo.getUserID());
		params.put("DeptID", userInfo.getDeptID());
		params.put("GroupPath", userInfo.getDeptPath());
		params.put("entCode", userInfo.getDNCode());
		// 결재자 체크 - Performer(Workitem) 조회
		// 대결 확인 포함
		// 담당업무함 체크
		// 부서수신함 체크
		if (expenceApplicationSvc.isPerformer(params) || expenceApplicationSvc.isJobFunctionManager(params) || expenceApplicationSvc.isReceivedByDept(params)) {
			return true;
		}

		String formPrefix = expenceApplicationSvc.selectFormPrefixData(params);
		params.put("FormPreFix", formPrefix);
		// 업무문서함 체크
		if (expenceApplicationSvc.isContainedInManagedBizDoc(params)) {
			return true;
		}

		// 참조회람 체크
		if (expenceApplicationSvc.isInTCInfo(params)) {
			return true;
		}

		params.put("OwnerProcessId", formRequest.getOwnerProcessId());
		params.put("ProcessID", formRequest.getProcessID());
		// 감사함 권한 여부 체크
		if (expenceApplicationSvc.hasDocAuditAuth(params)) {
			return true;
		}
		// 연관문서 (기밀문서인 경우 회람하여야 보임)
		if (expenceApplicationSvc.isLinkedDoc(params)) {
			return true;
		}

		// 연관문서 (경비결재)
		if (!formRequest.getExpAppID().isEmpty()) {
			params.put("ExpAppID", formRequest.getExpAppID());
			if (expenceApplicationSvc.isLinkedExpenceDoc(params)) {
				return true;
			}
		}

		// 사용자 문서 권한, 부서 문서 권한 부여 체크
		if (formRequest.getReadMode().equals("COMPLETE")) {
			List<CoviMap> list = expenceApplicationSvc.selectManageDocTarget(params);

			for (CoviMap map : list) {
				CoviMap tmpParams = params;
				tmpParams.put("TargetType", map.getString("TARGETTYPE"));
				tmpParams.put("TargetCode", map.getString("TARGETCODE"));
				tmpParams.put("ViewStartDate", map.getString("VIEWSTARTDATE"));
				tmpParams.put("ViewEndDate", map.getString("VIEWENDDATE"));
				tmpParams.put("bStored", bStored);
				if (expenceApplicationSvc.selectManageDocData(tmpParams) > 0) {
					return true;
				}
			}
		}

		return false;
	}
	
	@SuppressWarnings("unchecked")
	public boolean isInDomain(String formInstanceID) {
		boolean isInDomain = true;
		CoviList entInfoList = null;
		try {
			CoviMap params = new CoviMap();
			CoviList domainList = egovframework.coviframework.util.ComUtils.getAssignedDomainID();
			if(domainList.isEmpty()) {
				domainList.add(SessionHelper.getSession("DN_ID"));
			}
			if(domainList.contains("0")) {
				return isInDomain;
			}
			params.put("assignedDomain", domainList);
			entInfoList = (CoviList)commonSvc.getEntinfoListData(params).get("list");
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
			return false;
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
			return false;
		}
		
		// 결재자 체크 - Performer(Workitem) 조회		
		try {
			CoviMap params = new CoviMap();
			params.put("FormInstID", formInstanceID);
			params.put("EntCodeList", entInfoList);
			CoviMap map = coviMapperOne.select("expenceApplication.selectDomainCheck", params);
			if(map.isEmpty()) isInDomain = false;
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
			return false;
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
			return false;
		}
				
		return isInDomain;
	}

	@Override
	public boolean hasWriteAuth(FormRequest formRequest, UserInfo userInfo) {
		String formId = formRequest.getFormId();
		String formPrefix = formRequest.getFormPrefix();
		
		if(formId.isEmpty() && formPrefix.isEmpty())
			throw new IllegalArgumentException();
		
		CoviMap params = new CoviMap();
		params.put("entCode", userInfo.getDNCode());
		params.put("deptCode", userInfo.getDeptID());
		if(formRequest.getFormId().isEmpty()) {
			params.put("formPrefix", formPrefix);
		} else {
			params.put("formId", formId);
		}
		params.put("isSaaS", isSaaS);
		
		int returnCnt = coviMapperOne.selectOne("expenceApplication.existsFormAuth", params);		
		return returnCnt > 0 ? true : false;
	}
	
	public boolean isEasyAdmin(FormRequest formRequest, UserInfo userInfo) {
		boolean isEasyAdmin = false;
		String formInstID = formRequest.getFormInstanceID();
		
		CoviMap params = new CoviMap();
		params.put("formInstID", formInstID);
		
		if(SessionHelper.getSession("isEasyAdmin").equals("Y")) {
			try {
				CoviList arr = (CoviList)(expenceApplicationSvc.selectFormInstance(params)).get("list");
				if(arr.isEmpty()) {
					arr = (CoviList)(expenceApplicationSvc.selectFormInstanceStore(params)).get("list");				
				}
				if(arr != null && !arr.isEmpty()) {
					CoviMap formInstance = arr.getJSONObject(0);
					String formEntCode = formInstance.optString("EntCode");
					if(formEntCode.equals(userInfo.getDNCode())) {
						isEasyAdmin = true;
					}
				}
			} catch (NullPointerException npE) {
				logger.error(npE.getLocalizedMessage(), npE);
			} catch (Exception e) {
				logger.error(e.getLocalizedMessage(), e);
			}
		}
		
		return isEasyAdmin;
	}
	
}
