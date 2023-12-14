package egovframework.coviaccount.user.service.impl;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.service.CommonSvc;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.user.service.BaseCodeSvc;
import egovframework.coviaccount.user.service.FormManageSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("FormManageSvc")
public class FormManageSvcImpl extends EgovAbstractServiceImpl implements FormManageSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private CommonSvc commonSvc;
	
	@Autowired
	private BaseCodeSvc baseCodeSvc;
	
	/**
	 * @Method Name : getFormManagelist
	 * @Description : 비용신청서관리 목록 조회
	 */
	@Override
	public CoviMap getFormManagelist(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt		= (int) coviMapperOne.getNumber("account.formmanage.getFormManageListCnt" , params);
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		CoviList list	= coviMapperOne.list("account.formmanage.getFormManageList", params);			
				
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getFormManageDetail
	 * @Description : 비용신청서관리 상세조회
	 */
	@Override
	public CoviMap getFormManageDetail(CoviMap params) throws Exception {

		CoviMap resultList	= new CoviMap();

		CoviList list = coviMapperOne.list("account.formmanage.getFormManageDetail",	params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList; 
	}

	/**
	 * @Method Name : getInfoListData
	 * @Description : 콤보박스 데이터 조회
	 */
	@Override
	public CoviMap getInfoListData(CoviMap params) throws Exception {

		CoviMap resultList	= new CoviMap();
		
		params.put("lang", SessionHelper.getSession("lang"));

		CoviList list = coviMapperOne.list("account.formmanage.get" + params.getString("TargetType") + "InfoList", params);
		
		String strList = "";
		if(params.getString("TargetArea").equals("DIV")) {
			strList = "ItemID,ItemCode,ItemName,Description,CompanyCode,CompanyName";
		} else if(params.getString("TargetArea").equals("SELECT")) {
			strList = "ItemID,optionValue,optionText";
		}
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, strList));
		return resultList; 
	}
	
	/**
	 * @Method Name : saveFormManageInfo
	 * @Description : 비용신청서관리 저장
	 */
	@Override
	public CoviMap saveFormManageInfo(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		String expenceFormID		= params.get("expenceFormID")	== null ? "" : params.get("expenceFormID").toString();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		resultList.put("result", "");
		if(expenceFormID.equals("")){
			int chkCode	= (int) coviMapperOne.getNumber("account.formmanage.getFormCodeCnt" , params);
			if(chkCode > 0){
				resultList.put("result", "code");
			}else{
				insertFormManageInfo(params);	
			}
		}else{
			updateFormManageInfo(params);	
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : insertFormManageInfo
	 * @Description : 비용신청서관리 Insert
	 */
	public void insertFormManageInfo(CoviMap params)throws Exception {
		coviMapperOne.insert("account.formmanage.insertFormManageInfo", params);
	}
	
	/**
	 * @Method Name : updateFormManageInfo
	 * @Description : 비용신청서관리 Update
	 */
	public void updateFormManageInfo(CoviMap params)throws Exception {
		coviMapperOne.insert("account.formmanage.updateFormManageInfo", params);
	}
	
	/**
	 * @Method Name : deleteFormManage
	 * @Description : 비용신청서관리 삭제
	 */
	@Override
	public CoviMap deleteFormManage(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		
		String deleteStr = params.get("deleteSeq") == null ? "" : params.get("deleteSeq").toString();
		if(!deleteStr.equals("")){
			String[] deleteArr = deleteStr.split(",");
			for(int i = 0; i < deleteArr.length; i++){
				CoviMap sqlParam	= new CoviMap();
				sqlParam.put("expenceFormID", deleteArr[i]);
				deleteFormManageInfo(sqlParam);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : deleteFormManageInfo
	 * @Description : 비용신청서관리 Delete
	 */
	public void deleteFormManageInfo(CoviMap params)throws Exception {
		coviMapperOne.delete("account.formmanage.deleteFormManageInfo", params);
	}
	
	/**
	 * @Method Name : formManageExcelDownload
	 * @Description : 비용신청서관리 엑셀 다운로드
	 */
	@Override
	public CoviMap formManageExcelDownload(CoviMap params) throws Exception{
		CoviMap resultList	= new CoviMap();
		
		String headerKey	= params.get("headerKey").toString();
		int cnt				= 0;
		
		CoviList list	= coviMapperOne.list("account.formmanage.getFormManageExcelList", params);
		cnt		= (int) coviMapperOne.getNumber("account.formmanage.getFormManageListCnt" , params);
		
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : formManageExcelUpload
	 * @Description : 비용신청서관리 엑셀 업로드
	 */
	@Override
	public CoviMap formManageExcelUpload(CoviMap params) throws Exception {
		int cnt = 0;
		CoviMap resultList	= new CoviMap();
		String formCode	= "";
		List<String> aidStr	= new ArrayList<String>();
		
		ArrayList<ArrayList<Object>> dataList = accountExcelUtil.extractionExcelData(params, 1);	// 엑셀 데이터 추출

		for (ArrayList list : dataList){                    // 중복체크
			if(	AccountUtil.checkNull(list.get(0).toString()) ||
					AccountUtil.checkNull(list.get(1).toString()) ||
					AccountUtil.checkNull(list.get(2).toString()) ||
					AccountUtil.checkNull(list.get(3).toString()) ||
					AccountUtil.checkNull(list.get(4).toString())){
				resultList.put("err","nullErr");
				return resultList;
			}
			formCode = list.get(1) == null ? "" : list.get(1).toString();
			if(aidStr.indexOf(formCode) > -1){
				resultList.put("err", "formCode");
				return resultList;
			}else{
				aidStr.add(formCode);
			}
		}
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		// index | (0) = 회사명 | (1) = 비용신청서 코드 | (2) = 비용신청서명 | (3) = 요청구분| (4) = 메뉴유형 | (5) = 사용여부 | (6) = 정렬값
		
		for (ArrayList list : dataList) { // 추가
			String companyCode		 = list.get(0) == null ? "" : list.get(0).toString();
			formCode				 = list.get(1) == null ? "" : list.get(1).toString();
			String formName 		 = list.get(2) == null ? "" : list.get(2).toString();
			String expAppType		 = list.get(3) == null ? "" : list.get(3).toString();
			String menuType		 	 = list.get(4) == null ? "" : list.get(4).toString();
			String isUse			 = list.get(5) == null ? "Y" : list.get(5).toString();
			String sortKey			 = list.get(6) == null ? "0" : list.get(6).toString();
			
			CoviMap searchParam = new CoviMap();
			searchParam.put("codeGroup", "CompanyCode");
			searchParam.put("codeName", companyCode);
			companyCode = baseCodeSvc.selectBaseCodeByCodeName(searchParam); // 회사코드
			
			searchParam.put("companyCode", companyCode);
			
			searchParam.put("codeGroup", "ExpAppType");
			searchParam.put("codeName", expAppType);
			expAppType = baseCodeSvc.selectBaseCodeByCodeName(searchParam); //비용신청타입
			
			searchParam.put("codeGroup", "MenuType");
			searchParam.put("codeName", menuType);
			menuType = baseCodeSvc.selectBaseCodeByCodeName(searchParam); // 메뉴유형

			params.put("companyCode", companyCode);
			params.put("formCode", formCode);
			params.put("formName", formName);
			params.put("expAppType", expAppType);
			params.put("menuType", menuType);
			params.put("isUse", isUse);
			params.put("sortKey", sortKey);
			params.put("UR_Code", SessionHelper.getSession("UR_Code"));
			
			cnt = (int) coviMapperOne.getNumber("account.formmanage.getFormCodeCnt", params); // ID체크(등록/수정)
			if(cnt == 0){ // 추가
				insertFormManageInfo(params);
			}else{  // 수정
				CoviMap map = coviMapperOne.selectOne("account.formmanage.getFormCodeExpenceFormID" , params);
				String expenceFormID = map.get("ExpenceFormID") == null ? "" : map.get("ExpenceFormID").toString();
				params.put("expenceFormID", expenceFormID);
				coviMapperOne.insert("account.formmanage.updateFormManageInfoExcel", params);
			}
		}
		
		return resultList;
	}
	

	/**
	 * @Method Name : getFormMenuList
	 * @Description : 메뉴 영역에 뿌려질 신청서 목록 조회
	 */
	@Override
	public CoviMap getFormMenuList(CoviMap params) throws Exception {

		CoviMap resultList	= new CoviMap();
		
		params.put("companyCode", commonSvc.getCompanyCodeOfUser(SessionHelper.getSession("UR_Code")));
		
		CoviList list = coviMapperOne.list("account.formmanage.getFormMenuList", params);
				
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FormCode,FormName,ExpAppType,MenuType,ReservedStr1"));
		return resultList; 
	}

	/**
	 * @Method Name : getFormManageInfo
	 * @Description : 신청서 별 관리 정보 조회
	 */
	@Override
	public CoviMap getFormManageInfo(CoviMap params) throws Exception {

		CoviMap resultList	= new CoviMap();

		CoviList list = coviMapperOne.list("account.formmanage.getFormManageInfo", params);
				
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ExpenceFormID,AccountInfo,StandardBriefInfo,RuleInfo,ProofInfo,AuditInfo,TaxInfo,AccountChargeInfo,ApprovalFormInfo,FormPrefix,FormID,FormName,SchemaContext,ChargeJob"));
		return resultList; 
	}
	
	/**
	 * @Method Name : getFormLegacyManageInfo
	 * @Description : 조회용 신청서 별 관리 정보 조회
	 */
	@Override
	public CoviMap getFormLegacyManageInfo(CoviMap params) throws Exception {

		CoviMap resultList	= new CoviMap();

		CoviList list = coviMapperOne.list("account.formmanage.getFormLegacyManageInfo", params);
				
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ExpenceFormID,AccountInfo,StandardBriefInfo,RuleInfo,ProofInfo,AuditInfo,TaxInfo,AccountChargeInfo,ApprovalFormInfo,FormPrefix,FormID,FormName,SchemaContext,ChargeJob"));
		return resultList; 
	}

	@Override
	public CoviMap getNoteIsUse(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap coviMap = coviMapperOne.select("account.formmanage.getNoteIsUse", params);
		
		resultList.put("NoteIsUse", coviMap.get("NoteIsUse").toString());
		
		return resultList;
	}
	
	@Override
	public CoviMap getExchangeIsUse(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap coviMap = coviMapperOne.select("account.formmanage.getExchangeIsUse", params);
		
		resultList.put("ExchangeIsUse", coviMap.get("ExchangeIsUse").toString());
		
		return resultList;
	}
}
