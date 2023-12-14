package egovframework.core.manage.service.impl;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.core.manage.service.OrganizationSyncExcelSvc;
import egovframework.coviframework.util.ComUtils;


@Service("manage.organizationSyncExcelService")
public class OrganizationSyncExcelSvcImpl extends EgovAbstractServiceImpl implements OrganizationSyncExcelSvc {

	private Logger LOGGER = LogManager.getLogger(OrganizationSyncExcelSvcImpl.class);
	private boolean isSaaS = "Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N"));
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * 라이선스 리스트
	 */
	@Override
	public CoviMap selectLicenseList(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		if(!isSaaS){
			params.put("DomainID", "0");
			params.put("DomainCode", "ORGROOT");
		}
		CoviList list = coviMapperOne.list("organization.conf.syncexcel.selectLicenseList", params);
		resultObj.put("list", CoviSelectSet.coviSelectJSON(list, "LicSeq,LicName,LicMail"));
		return resultObj;
	}
	/**
	 * 엑셀동기화 대상 계열사 확인
	 */
	@Override
	public CoviMap checkSyncCompany(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		CoviList list = coviMapperOne.list("organization.conf.syncexcel.checkSyncCompany", params);

		if (list.size() == 0) {
			resultObj.put("result", "invalid");
		}
		else {
			resultObj.put("result", "valid");
			resultObj.put("list", CoviSelectSet.coviSelectJSON(list, "OrgSyncType,DomainID,DomainURL,DomainCode,MailDomain,CompanyCode"));
		}
		
		return resultObj;
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
	 * Excelorgdept 초기화
	 */
	@Override
	public CoviMap deleteExcelorgdept(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		
		coviMapperOne.delete("organization.syncexcel.deleteFileDataDept", params);
		coviMapperOne.delete("organization.syncmanage.deleteCompareObjectGroupList");
		
		resultObj.put("result", "OK");
		return resultObj;
	}
	
	/**
	 * 부서 엑셀 데이터 excel_orgdept 테이블에 추가
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap insertFileDataDept(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.insert("organization.syncexcel.insertFileDataDept", params);
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	/**
	 * Excelorguser 초기화
	 */
	@Override
	public CoviMap deleteExcelorguser(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		
		coviMapperOne.delete("organization.syncexcel.deleteFileDataUser", params);
		coviMapperOne.delete("organization.syncmanage.deleteCompareObjectUserList");
		
		resultObj.put("result", "OK");
		return resultObj;
	}
	
	/**
	 * 사용자 엑셀 데이터 excel_orguser 테이블에 추가
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap insertFileDataUser(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		
		returnCnt = coviMapperOne.insert("organization.syncexcel.insertFileDataUser", params);
		
		if(returnCnt > 0) resultObj.put("result", "OK");
		else resultObj.put("result", "FAIL");
		
		return resultObj;
	}
	
	/**
	 * 엑셀동기화 부서 데이터 대상 조회
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getExcelTempDeptDataList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		try{
			if(params.containsKey("pageNo")) {
	 			int cnt = (int)coviMapperOne.getNumber("organization.syncexcel.getExcelTempDeptDataListCnt", params);
	 			page = ComUtils.setPagingData(params,cnt);
	 			params.addAll(page);
	 			resultList.put("page", page);
	 		}
			
			CoviList list = coviMapperOne.list("organization.syncexcel.getExcelTempDeptDataList", params);
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "deptSyncType,deptGroupCode,deptCompanyCode,deptMemberOf,deptDisplayName,deptMultiDisplayName,deptSortKey,deptIsUse,deptIsDisplay,deptIsMail,deptIsHR,deptPrimaryMail,deptManagerCode"));
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return resultList;
	}
	
	/**
	 * 엑셀동기화 사용자 데이터 대상 조회
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getExcelTempUserDataList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		try{
			if(params.containsKey("pageNo")) {
	 			int cnt = (int)coviMapperOne.getNumber("organization.syncexcel.getExcelTempUserDataListCnt", params);
	 			page = ComUtils.setPagingData(params,cnt);
	 			params.addAll(page);
	 			resultList.put("page", page);
	 		}
			
			CoviList list = coviMapperOne.list("organization.syncexcel.getExcelTempUserDataList", params);
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "userLicSeq,userSyncType,userUserCode,userLogonID,userEmpNo,userDisplayName,userCompanyCode,userDeptCode,userJobTitleCode,userJobPositionCode,userJobLevelCode,userPhoneNumber,userMobile,userFax,userSortKey,userIsUse,userIsHR,userIsDisplay,userEnterDate,userRetireDate,userPhotoPath,userUseMailConnect,userMailAddress,userExternalMailAddress,userChargeBusiness,userPhoneNumberInter,useMessengerConnect,userBirthDiv,userBirthDate,userMultiDisplayName"));			
		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	
		return resultList;
	}
	
	/**
	 * 엑셀동기화 동기화 대상 추출
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap syncCompareObjectForExcel(String pType) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		//count check to import data
		int compareGroupCnt = 0;
		int compareUserCnt = 0;
		
		LOGGER.info("insertCompareData execute");
		
		if(pType.equals("DEPT")) {
			coviMapperOne.delete("organization.syncmanage.deleteCompareObjectGroupList");
			compareGroupCnt = coviMapperOne.insert("organization.syncexcel.insertCompareObjectGroupForExcelINSERT", null);
			compareGroupCnt += coviMapperOne.insert("organization.syncexcel.insertCompareObjectGroupForExcelUPDATE", null);
			compareGroupCnt += coviMapperOne.insert("organization.syncexcel.insertCompareObjectGroupForExcelDELETE", null);
			compareGroupCnt -= coviMapperOne.delete("organization.syncexcel.deleteNoMemberOf");
			
			LOGGER.info("insertCompareData execute complete");
			LOGGER.info("CompareData count check");
			LOGGER.info("[Group : " + compareGroupCnt + "]");
		}
		else if(pType.equals("USER")) {
			coviMapperOne.delete("organization.syncmanage.deleteCompareObjectUserList");
			compareUserCnt = coviMapperOne.insert("organization.syncexcel.insertCompareObjectUserForExcelINSERT", null);
			compareUserCnt += coviMapperOne.insert("organization.syncexcel.insertCompareObjectUserForExcelUPDATE", null);
			compareUserCnt += coviMapperOne.insert("organization.syncexcel.insertCompareObjectUserForExcelDELETE", null);
			
			LOGGER.info("insertCompareData execute complete");
			LOGGER.info("CompareData count check");
			LOGGER.info("[User : " + compareUserCnt + "]");
		}
		
		returnObj.put("compareGroupCnt", compareGroupCnt);
		returnObj.put("compareUserCnt", compareUserCnt);
		
		return returnObj;
	}
	
	/**
	 * 선택한 부서 삭제
	 */
	@Override
	public int deleteSelectDept(CoviMap params) throws Exception {
		int iReturn = 0;
		
		try {
			iReturn = coviMapperOne.delete("organization.syncexcel.deleteSelectDept", params);
		} catch (NullPointerException e) {
			iReturn = 0;
			LOGGER.error("deleteSelectDept Error [GroupCode : " + params.get("GroupCode") + "] " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e) {
			iReturn = 0;
			LOGGER.error("deleteSelectDept Error [GroupCode : " + params.get("GroupCode") + "] " + "[Message : " +  e.getMessage() + "]");
		}
		
		return iReturn;
	}
	
	/**
	 * 선택한 사용자 삭제
	 */
	@Override
	public int deleteSelectUser(CoviMap params) throws Exception {
		int iReturn = 0;
		
		try {
			iReturn = coviMapperOne.delete("organization.syncexcel.deleteSelectUser", params);
		} catch (NullPointerException e) {
			iReturn = 0;
			LOGGER.error("deleteSelectDept Error [GroupCode : " + params.get("GroupCode") + "] " + "[Message : " +  e.getMessage() + "]");
		} catch(Exception e) {
			iReturn = 0;
			LOGGER.error("deleteSelectUser Error [UserCode : " + params.get("UserCode") + "] " + "[Message : " +  e.getMessage() + "]");
		}
		
		return iReturn;
	}
	
	/**
	 * 대상 데이터 초기화
	 */
	@Override
	public int deleteTemp() throws Exception {
		int iReturn = 0;
		
		try {
			iReturn += coviMapperOne.delete("organization.syncmanage.deleteCompareObjectGroupList");
			iReturn += coviMapperOne.delete("organization.syncmanage.deleteCompareObjectUserList");
		} catch (NullPointerException e) {
			iReturn = 0;
			LOGGER.error("deleteAll Error [Message : " +  e.getMessage() + "]");
		} catch (Exception e) {
			iReturn = 0;
			LOGGER.error("deleteAll Error [Message : " +  e.getMessage() + "]");
		}
		
		return iReturn;
	}
	
	/**
	 * 전체 초기화
	 */
	@Override
	public int deleteAll(CoviMap params) throws Exception {
		int iReturn = 0;
		
		try {
			if("DEPT".equalsIgnoreCase((params.getString("Type"))))
			{	
				iReturn = coviMapperOne.delete("organization.conf.syncexcel.deleteFileDataDept", params);
				iReturn += coviMapperOne.delete("organization.syncmanage.deleteCompareObjectGroupList");
			}
			if("USER".equalsIgnoreCase((params.getString("Type"))))
			{
				iReturn += coviMapperOne.delete("organization.conf.syncexcel.deleteFileDataUser", params);
				iReturn += coviMapperOne.delete("organization.syncmanage.deleteCompareObjectUserList");
			}
		} catch (NullPointerException e) {
			iReturn = 0;
			LOGGER.error("deleteAll Error [Message : " +  e.getMessage() + "]");
		} catch (Exception e) { 
			iReturn = 0;
			LOGGER.error("deleteAll Error [Message : " +  e.getMessage() + "]");
		}
		
		return iReturn;
	}
	
	/**
	 * 타계열사 대상 삭제
	 */
	@Override
	public int deleteOtherCompany(CoviMap params) throws Exception {
		int iReturn = 0;
		
		try {
			iReturn = coviMapperOne.delete("organization.syncexcel.deleteOtherCompanyGroup", params);
			iReturn += coviMapperOne.delete("organization.syncexcel.deleteOtherCompanyUser", params);
		} catch (NullPointerException e) {
			iReturn = 0;
			LOGGER.error("deleteOtherCompany Error [Message : " +  e.getMessage() + "]");
		} catch(Exception e) {
			iReturn = 0;
			LOGGER.error("deleteOtherCompany Error [Message : " +  e.getMessage() + "]");
		}
		return iReturn;
	}
	
	/**
	 * 부서코드 중복 확인
	 */
	@Override
	public CoviMap selectIsDupDeptCode(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.syncexcel.selectIsDuplicateDeptCode", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate"));
		return resultList;
	}
	
	/**
	 * 사용자코드, 로그인ID 중복 확인
	 */
	@Override
	public CoviMap selectIsDupUserCode(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.syncexcel.selectIsDuplicateUserCode", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate"));
		return resultList;
	}
	
	/**
	 * 사용자코드, 사번, 로그인ID 중복 확인
	 */
	@Override
	public CoviMap selectIsDupEmpNo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.syncexcel.selectIsDuplicateEmpno", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate"));
		return resultList;
	}
}
