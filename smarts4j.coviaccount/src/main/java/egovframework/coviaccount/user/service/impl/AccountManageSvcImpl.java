package egovframework.coviaccount.user.service.impl;

import java.lang.invoke.MethodHandles;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.interfaceUtil.interfaceVO.AccountManageVO;
import egovframework.coviaccount.user.service.AccountManageSvc;
import egovframework.coviaccount.user.service.BaseCodeSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("AccountManageSvc")
public class AccountManageSvcImpl extends EgovAbstractServiceImpl implements AccountManageSvc {
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	@Autowired
	private BaseCodeSvc baseCodeSvc;
	
	/**
	 * @Method Name : getAccountmanagelist
	 * @Description : 계정관리 목록 조회
	 */
	@Override
	public CoviMap getAccountmanagelist(CoviMap params) throws Exception {
		boolean interfaceTF		= true;
		CoviMap interfaceParam	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		String searchProperty = rtString(params.get("searchProperty"));
		
		switch (searchProperty) {
			case "DB":
				//searchProperty이 DB인 경우 이곳에 정의
				break;
	
			case "SOAP":
				//searchProperty이 SOAP인 경우 이곳에 정의
					interfaceParam.put("mapFunctionName",	"getSoapMap");
					interfaceParam.put("soapName",			"XpenseGetGLAccountListPop");
					interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetGLAccountListPop");
					
					String pSortKey			= rtString(params.get("sortColumn"));
					String pOrder			= rtString(params.get("sortDirection"));
					String soapAccountCD	= rtString(params.get("soapAccountCD"));
					String soapAccountCN	= rtString(params.get("soapAccountCN"));
					
					CoviMap xmlParam = new CoviMap();
					
					xmlParam.put("pPageSize",		pageSize);
					xmlParam.put("pPageCurrent",	pageNo);
					xmlParam.put("pSortKey",		pSortKey);
					xmlParam.put("pOrder",			pOrder);
					xmlParam.put("pAccountClass",	"");
					xmlParam.put("pAccountCode",	soapAccountCD);
					xmlParam.put("pAccountName",	soapAccountCN);
					
					interfaceParam.put("xmlParam", xmlParam);
				break;
				
			case "SAP":
				//searchProperty이 SAP인 경우 이곳에 정의
					String pernr	= "";
					String logid	= "";
					String ename	= "";
					String bukrs	= "";
					String scrno	= "";
					String no_mask	= "";
					String spras	= "";
					String i_saknr	= rtString(params.get("soapAccountCD"));
					String i_txt20	= rtString(params.get("soapAccountCN"));
	
					CoviMap setValues = new CoviMap();
					
					setValues.put("PERNR",		pernr);
					setValues.put("LOGID",		logid);
					setValues.put("ENAME",		ename);
					setValues.put("BUKRS",		bukrs);
					setValues.put("SCRNO",		scrno);
					setValues.put("NO_MASK",	no_mask);
					setValues.put("SPRAS",		spras);
					setValues.put("I_SAKNR",	i_saknr);
					setValues.put("I_TXT20",	i_txt20);
	
					ArrayList getValues = new ArrayList();
					//getValues.add("get1");
					//getValues.add("get2");
					//getValues.add("get3");
					interfaceParam.put("mapFunctionName",	"getSapMap");
					interfaceParam.put("tableName",			"ZFIS0019");
					interfaceParam.put("sapFunctionName",	"ZFI_IF_F6003_SEND");
					interfaceParam.put("setValues",			setValues);
					interfaceParam.put("getValues",			getValues);
				break;
				
			default:
				//일반 DB조회
				cnt		= (int) coviMapperOne.getNumber("account.accountmanage.getAccountmanagelistCnt" , params);
				page 	= ComUtils.setPagingData(params,cnt);
				params.addAll(page);
				list	= coviMapperOne.list("account.accountmanage.getAccountmanagelist", params);				
				interfaceTF = false;
				break;
		}
		
		if(interfaceTF){
			
			interfaceParam.put("interFaceType",			searchProperty);
			interfaceParam.put("daoClassName",			"AccountManageDao");
			interfaceParam.put("voClassName",			"AccountManageVO");
			interfaceParam.put("mapClassName",			"AccountManageMap");

			interfaceParam.put("daoSetFunctionName",	"setAccountManageList");
			interfaceParam.put("daoGetFunctionName",	"getAccountManageList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			AccountManageVO accountManageVO = null;
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);

			ArrayList arrayList = (ArrayList) getInterface.get("list");
			for (int i = 0; i < arrayList.size(); i++) {
				CoviMap listInfo = new CoviMap();
				
				accountManageVO = (AccountManageVO) arrayList.get(i);
				String accountID		= accountManageVO.getAccountID();
				String companyCode		= accountManageVO.getCompanyCode();
				String accountClass		= accountManageVO.getAccountClass();
				String accountCode		= accountManageVO.getAccountCode();
				String accountName		= accountManageVO.getAccountName();
				String accountShortName	= accountManageVO.getAccountShortName();
				String isUse			= accountManageVO.getIsUse();
				String description		= accountManageVO.getDescription();
				String taxType			= accountManageVO.getTaxCode();
				String taxCode			= accountManageVO.getTaxType();
				String totalCount		= accountManageVO.getTotal();
				String registDate		= accountManageVO.getRegistDate();
				String registerID		= accountManageVO.getRegisterID();
				String modifyDate		= accountManageVO.getModifyDate();
				String modifierID		= accountManageVO.getModifierID();
				
				//데이터 구조가 다른 관계로  임시로 셋팅
				String accountClassName	= accountManageVO.getAccountClassName();
				
				if(accountCode.equals("")){
					continue;
				}
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				if(searchProperty.equals("SOAP")){
					if(registDate.indexOf("T")>0){
						registDate = registDate.substring(0,registDate.indexOf("T"));	
					}
					registDate = registDate.replaceAll("[^0-9]", ".");
				}
				
				cnt = Integer.parseInt(totalCount);
				listInfo.put("AccountID",			i);
				listInfo.put("CompanyCode",			companyCode);
				listInfo.put("AccountClass",		accountClass);
				listInfo.put("AccountCode",			accountCode);
				listInfo.put("AccountName",			accountName);
				listInfo.put("AccountShortName",	accountShortName);
				listInfo.put("IsUse",				isUse);
				listInfo.put("Description",			description);
				listInfo.put("RegistDate",			registDate);
				listInfo.put("AccountClassName",	accountClassName);
				list.add(listInfo);				
			}
			page 	= ComUtils.setPagingData(params,cnt);
		}
		//page	= accountUtil.listPageCount(cnt,params);
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getAccountManageDetail
	 * @Description : 계정관리 상세조회
	 */
	@Override
	public CoviMap getAccountManageDetail(CoviMap params) throws Exception {

		CoviMap resultList	= new CoviMap();

		CoviList list = coviMapperOne.list("account.accountmanage.getAccountManageDetail",	params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList; 
	}
	
	/**
	 * @Method Name : saveAccountManageInfo
	 * @Description : 계정관리 저장
	 */
	@Override
	public CoviMap saveAccountManageInfo(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		String accountID		= params.get("accountID")	== null ? "" : params.get("accountID").toString();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		resultList.put("result", "");
		if(accountID.equals("")){
			int chkCode	= (int) coviMapperOne.getNumber("account.accountmanage.getAccountCodeCnt" , params);
			if(chkCode > 0){
				resultList.put("result", "code");
			}else{
				insertAccountManageInfo(params);	
			}
		}else{
			updateAccountManageInfo(params);	
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : insertAccountManageInfo
	 * @Description : 계정관리 Insert
	 */
	public void insertAccountManageInfo(CoviMap params)throws Exception {
		coviMapperOne.insert("account.accountmanage.insertAccountManageInfo", params);
	}
	
	/**
	 * @Method Name : updateAccountManageInfo
	 * @Description : 계정관리 Update
	 */
	public void updateAccountManageInfo(CoviMap params)throws Exception {
		coviMapperOne.insert("account.accountmanage.updateAccountManageInfo", params);
	}
	
	/**
	 * @Method Name : deleteAccountManage
	 * @Description : 계정관리 삭제
	 */
	@Override
	public CoviMap deleteAccountManage(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		
		String deleteStr = params.get("deleteSeq") == null ? "" : params.get("deleteSeq").toString();
		if(!deleteStr.equals("")){
			String[] deleteArr = deleteStr.split(",");
			for(int i = 0; i < deleteArr.length; i++){
				CoviMap sqlParam	= new CoviMap();
				sqlParam.put("accountID", deleteArr[i]);
				deleteAccountManageInfo(sqlParam);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : deleteAccountManageInfo
	 * @Description : 계정관리 Delete
	 */
	public void deleteAccountManageInfo(CoviMap params)throws Exception {
		coviMapperOne.delete("account.accountmanage.deleteAccountManageInfo", params);
	}
	
	/**
	 * @Method Name : accountManageExcelDownload
	 * @Description : 계정관리 엑셀 다운로드
	 */
	@Override
	public CoviMap accountManageExcelDownload(CoviMap params) throws Exception{
		boolean interfaceTF		= true;
		CoviMap resultList	= new CoviMap();
		CoviList list			= new CoviList();
		CoviMap interfaceParam	= new CoviMap();
		
		String headerKey	= params.get("headerKey").toString();
		int cnt				= 0;
		
		String searchProperty = rtString(params.get("searchProperty"));
		
		switch (searchProperty) {
			case "DB":
				//searchProperty이 DB인 경우 이곳에 정의
				break;
	
			case "SOAP":
				//searchProperty이 SOAP인 경우 이곳에 정의
					interfaceParam.put("mapFunctionName",	"getSoapMap");
					interfaceParam.put("soapName",			"XpenseGetGLAccountListPop");
					interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetGLAccountListPop");
					
					String soapAccountCD	= rtString(params.get("soapAccountCD"));
					String soapAccountCN	= rtString(params.get("soapAccountCN"));
					
					CoviMap xmlParam = new CoviMap();
					
					xmlParam.put("pSortKey",		"");
					xmlParam.put("pOrder",			"");
					xmlParam.put("pAccountClass",	"");
					xmlParam.put("pAccountCode",	soapAccountCD);
					xmlParam.put("pAccountName",	soapAccountCN);
					
					interfaceParam.put("xmlParam", xmlParam);
				break;
				
			case "SAP":
				//searchProperty이 SAP인 경우 이곳에 정의
					String pernr	= "";
					String logid	= "";
					String ename	= "";
					String bukrs	= "";
					String scrno	= "";
					String no_mask	= "";
					String spras	= "";
					String i_saknr	= rtString(params.get("soapAccountCD"));
					String i_txt20	= rtString(params.get("soapAccountCN"));
	
					CoviMap setValues = new CoviMap();
					
					setValues.put("PERNR",		pernr);
					setValues.put("LOGID",		logid);
					setValues.put("ENAME",		ename);
					setValues.put("BUKRS",		bukrs);
					setValues.put("SCRNO",		scrno);
					setValues.put("NO_MASK",	no_mask);
					setValues.put("SPRAS",		spras);
					setValues.put("I_SAKNR",	i_saknr);
					setValues.put("I_TXT20",	i_txt20);
	
					ArrayList getValues = new ArrayList();
					//getValues.add("get1");
					//getValues.add("get2");
					//getValues.add("get3");
					interfaceParam.put("mapFunctionName",	"getSapMap");
					interfaceParam.put("tableName",			"ZFIS0019");
					interfaceParam.put("sapFunctionName",	"ZFI_IF_F6003_SEND");
					interfaceParam.put("setValues",			setValues);
					interfaceParam.put("getValues",			getValues);
				break;
				
			default:
				//일반 DB조회
				list	= coviMapperOne.list("account.accountmanage.getAccountmanageExcellist", params);
				cnt		= (int) coviMapperOne.getNumber("account.accountmanage.getAccountmanagelistCnt" , params);
				interfaceTF = false;
				break;
		}
		
		if(interfaceTF){
			
			interfaceParam.put("interFaceType",			searchProperty);
			interfaceParam.put("daoClassName",			"AccountManageDao");
			interfaceParam.put("voClassName",			"AccountManageVO");
			interfaceParam.put("mapClassName",			"AccountManageMap");

			interfaceParam.put("daoSetFunctionName",	"setAccountManageList");
			interfaceParam.put("daoGetFunctionName",	"getAccountManageList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			AccountManageVO accountManageVO = null;
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);

			ArrayList arrayList = (ArrayList) getInterface.get("list");
			for (int i = 0; i < arrayList.size(); i++) {
				CoviMap listInfo = new CoviMap();
				
				accountManageVO = (AccountManageVO) arrayList.get(i);
				String accountID		= accountManageVO.getAccountID();
				String companyCode		= accountManageVO.getCompanyCode();
				String accountClass		= accountManageVO.getAccountClass();
				String accountCode		= accountManageVO.getAccountCode();
				String accountName		= accountManageVO.getAccountName();
				String accountShortName	= accountManageVO.getAccountShortName();
				String isUse			= accountManageVO.getIsUse();
				String description		= accountManageVO.getDescription();
				String taxType			= accountManageVO.getTaxCode();
				String taxCode			= accountManageVO.getTaxType();
				String totalCount		= accountManageVO.getTotal();
				String registDate		= accountManageVO.getRegistDate();
				String registerID		= accountManageVO.getRegisterID();
				String modifyDate		= accountManageVO.getModifyDate();
				String modifierID		= accountManageVO.getModifierID();
				
				//데이터 구조가 다른 관계로  임시로 셋팅
				String accountClassName	= accountManageVO.getAccountClassName();
				
				if(accountCode.equals("")){
					continue;
				}
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				if(searchProperty.equals("SOAP")){
					if(registDate.indexOf("T")>0){
						registDate = registDate.substring(0,registDate.indexOf("T"));	
					}
					registDate = registDate.replaceAll("[^0-9]", ".");
				}
				
				cnt = Integer.parseInt(totalCount);
				listInfo.put("AccountID",			i);
				listInfo.put("CompanyCode",			companyCode);
				listInfo.put("AccountClass",		accountClass);
				listInfo.put("AccountCode",			accountCode);
				listInfo.put("AccountName",			accountName);
				listInfo.put("AccountShortName",	accountShortName);
				listInfo.put("IsUse",				isUse);
				listInfo.put("Description",			description);
				listInfo.put("RegistDate",			registDate);
				listInfo.put("AccountClassName",	accountClassName);
				list.add(listInfo);
			}
		}
		
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : accountManageExcelUpload
	 * @Description : 계정관리 엑셀 업로드
	 */
	@Override
	public CoviMap accountManageExcelUpload(CoviMap params) throws Exception {
		int cnt = 0;
		CoviMap resultList	= new CoviMap();
		String accountCode	= "";
		List<String> aidStr		= new ArrayList<String>();
		
		ArrayList<ArrayList<Object>> dataList = accountExcelUtil.extractionExcelData(params, 1);	// 엑셀 데이터 추출

		for (ArrayList list : dataList){                    // 중복체크
			if(	AccountUtil.checkNull(list.get(0).toString()) ||
					AccountUtil.checkNull(list.get(1).toString()) ||
					AccountUtil.checkNull(list.get(2).toString()) ||
					AccountUtil.checkNull(list.get(4).toString())){
				resultList.put("err","nullErr");
				return resultList;
			}
			accountCode = list.get(1) == null ? "" : list.get(1).toString();
			if(aidStr.indexOf(accountCode) > -1){
				resultList.put("err", "accountCode");
				return resultList;
			}else{
				aidStr.add(accountCode);
			}
		}
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		// index | (0) = 회사명 | (1) = 계정코드 | (2) = 계정이름 	 | (3) = 단축명 		| (4) = 계정유형
		//		 | (5) = 부가세 | (6) = 과세유형 | (7) = 부가세(코드) | (8) = 과세유형(코드) | (9) = 사용여부
		
		for (ArrayList list : dataList) { // 추가
			String companyCode		= list.get(0) == null ? "" : list.get(0).toString();
			accountCode				= list.get(1) == null ? "" : list.get(1).toString();
			String accountName 		= list.get(2) == null ? "" : list.get(2).toString();
			String accountShortName = list.get(3) == null ? "" : list.get(3).toString();
			String accountClass		= list.get(4) == null ? "" : list.get(4).toString();
			//String taxTypeName		= list.get(5) == null ? "" : list.get(5).toString();
			//String taxCodeName 		= list.get(6) == null ? "" : list.get(6).toString();
			String taxType			= list.get(7) == null ? "" : list.get(7).toString();
			String taxCode			= list.get(8) == null ? "" : list.get(8).toString();
			String isUse			= list.get(9) == null ? "Y" : list.get(9).toString();
			
			CoviMap searchStr 	= new CoviMap();
			
			searchStr.put("codeGroup", "CompanyCode");
			searchStr.put("codeName", companyCode);
			companyCode = baseCodeSvc.selectBaseCodeByCodeName(searchStr); // 회사코드

			// 검색조건에 회사코드 추가
			searchStr.put("companyCode", companyCode);
			
			searchStr.put("codeGroup", "AccountClass");
			searchStr.put("codeName", accountClass);
			accountClass = baseCodeSvc.selectBaseCodeByCodeName(searchStr); // 회사코드
			
			params.put("companyCode", companyCode);
			params.put("accountCode", accountCode);
			params.put("accountName", accountName);
			params.put("accountShortName", accountShortName);
			params.put("accountClass", accountClass);
			params.put("taxType", taxType);
			params.put("taxCode", taxCode);
			params.put("isUse", isUse);
			
			cnt = (int) coviMapperOne.getNumber("account.accountmanage.getAccountCodeCnt", params); // ID체크(등록/수정)
			if(cnt == 0){ // 추가
				insertAccountManageInfo(params);
			}else{  // 수정
				String accountID = coviMapperOne.selectOne("account.accountmanage.getAccountCodeAccountID", params);
				if(!"".equals(accountID)) params.put("accountID", accountID);
				coviMapperOne.insert("account.accountmanage.updateAccountManageInfoExcel", params);
			}
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : accountManageSync
	 * @Description : 계정관리 동기화
	 */
	@Override
	public CoviMap accountManageSync(){

		CoviMap interfaceParam			= new CoviMap();
		CoviMap resultList			= new CoviMap();
		AccountManageVO accountManageVO	= null;
		
		try{
			//String syncType = accountUtil.getPropertyInfo("account.syncType.AccountManage");
			String syncType = accountUtil.getBaseCodeInfo("eAccSyncType", "AccountManage");
			
			interfaceParam.put("interFaceType",			syncType);
			interfaceParam.put("daoClassName",			"AccountManageDao");
			interfaceParam.put("voClassName",			"AccountManageVO");
			interfaceParam.put("mapClassName",			"AccountManageMap");
	
			interfaceParam.put("daoSetFunctionName",	"setAccountManageList");
			interfaceParam.put("daoGetFunctionName",	"getAccountManageList");
			interfaceParam.put("voFunctionName",		"setAll");
	
			switch (syncType) {
				case "DB":
					//syncType이 DB인 경우 이곳에 정의
					interfaceParam.put("mapFunctionName",	"getDBMap");
					interfaceParam.put("type",				"get");
					interfaceParam.put("sqlName",			"accountInterFace.AccountSI.getInterFaceListAccountManage");
					break;
		
				case "SOAP":
					//syncType이 SOAP인 경우 이곳에 정의
					CoviMap xmlParam = new CoviMap();
					
					xmlParam.put("pSortKey",		"");
					xmlParam.put("pOrder",			"");
					xmlParam.put("pAccountClass",	"");
					xmlParam.put("pAccountCode",	"");
					xmlParam.put("pAccountName",	"");
					
					interfaceParam.put("xmlParam",			xmlParam);
					interfaceParam.put("mapFunctionName",	"getSoapMap");
					interfaceParam.put("soapName",			"XpenseGetGLAccountListPop");
					interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetGLAccountListPop");
					break;
					
				case "SAP":
					//syncType이 SAP인 경우 이곳에 정의
						String pernr	= "";
						String logid	= "";
						String ename	= "";
						String bukrs	= "";
						String scrno	= "";
						String no_mask	= "";
						String spras	= "";
						String i_saknr	= "";
						String i_txt20	= "";
		
						CoviMap setValues = new CoviMap();
						
						setValues.put("PERNR",		pernr);
						setValues.put("LOGID",		logid);
						setValues.put("ENAME",		ename);
						setValues.put("BUKRS",		bukrs);
						setValues.put("SCRNO",		scrno);
						setValues.put("NO_MASK",	no_mask);
						setValues.put("SPRAS",		spras);
						setValues.put("I_SAKNR",	i_saknr);
						setValues.put("I_TXT20",	i_txt20);
		
						ArrayList getValues = new ArrayList();
						//getValues.add("get1");
						//getValues.add("get2");
						//getValues.add("get3");
						interfaceParam.put("mapFunctionName",	"getSapMap");
						interfaceParam.put("tableName",			"ZFIS0019");
						interfaceParam.put("sapFunctionName",	"ZFI_IF_F6003_SEND");
						interfaceParam.put("setValues",			setValues);
						interfaceParam.put("getValues",			getValues);
					break;
				case "SAPOdata":
					//syncType이 SAPOdata인 경우 이곳에 정의

					String sGetParam = "";
					String sSearchType = "";
					String sSearchStr = "";
					String sAccountType = "YCOA";	//하드코딩 - 표준 계정과목표
					
					if(sSearchType.equals("GLC")){
						sGetParam = accountUtil.addGetParam(sGetParam,"GLAccount",sSearchStr,"eq","and");
					}else if(sSearchType.equals("GLN")){
						sGetParam = accountUtil.addGetParam(sGetParam,"GLAccountName",sSearchStr,"eq","and");
					}else if(sSearchType.equals("GLLN")){
						sGetParam = accountUtil.addGetParam(sGetParam,"GLAccountLongName",sSearchStr,"eq","and");
					}
					
					if(!sAccountType.equals("")){
						sGetParam = accountUtil.addGetParam(sGetParam,"ChartOfAccounts",sAccountType,"eq","and");
					}
					
					sGetParam = accountUtil.addGetParam(sGetParam,"Language","KO","eq","and");			
					sGetParam = accountUtil.addGetParam(sGetParam,"GLAccount","60000000","ge","and");
					sGetParam = accountUtil.addGetParam(sGetParam,"GLAccount","79999999","le","and");
					interfaceParam.put("SAPOdataFuntionName", "API_GLACCOUNTINCHARTOFACCOUNTS_SRV/A_GLAccountText");
					interfaceParam.put("SAPOdataParam", sGetParam);
					
					interfaceParam.put("mapFunctionName",		"getSapODataMap");
					interfaceParam.put("SearchType", sSearchType);
					interfaceParam.put("SearchStr", sSearchStr);
					interfaceParam.put("AccountType", sAccountType); 
					break;
				
				default :
					break;
			}
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
	
			ArrayList list = (ArrayList) getInterface.get("list");
			String UR_Code = SessionHelper.getSession("UR_Code");

			for (int i = 0; i < list.size(); i++) {
				CoviMap listInfo = new CoviMap();
				accountManageVO = (AccountManageVO) list.get(i);
				String companyCode		= accountManageVO.getCompanyCode();
				String accountClass		= accountManageVO.getAccountClass();
				String accountCode		= accountManageVO.getAccountCode();
				String accountName		= accountManageVO.getAccountName();
				String accountShortName	= accountManageVO.getAccountShortName();
				String isUse			= accountManageVO.getIsUse();
				String description		= accountManageVO.getDescription();
				String registDate		= accountManageVO.getRegistDate();
				String registerID		= accountManageVO.getRegisterID();
				String modifyDate		= accountManageVO.getModifyDate();
				String modifierID		= accountManageVO.getModifierID();
				
				listInfo.put("UR_Code",				UR_Code);
				listInfo.put("companyCode",			companyCode.equals("") ? "ALL" : companyCode);
				listInfo.put("accountClass",		accountClass);
				listInfo.put("accountCode",			accountCode);
				listInfo.put("accountName",			accountName);
				listInfo.put("accountShortName",	accountShortName);
				listInfo.put("isUse",				(isUse.equals("") ? "Y" : isUse));
				listInfo.put("description",			description);
				listInfo.put("registDate",			registDate);
				listInfo.put("registerID",			registerID);
				listInfo.put("modifyDate",			modifyDate);
				listInfo.put("modifierID",			modifierID);
				
				accountManageInterfaceSave(listInfo);
			}
			resultList.put("status",	getInterface.get("status"));
		} catch (NullPointerException e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			logger.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}

	/**
	 * @Method Name : accountManageInterfaceSave
	 * @Description : 계정관리 동기화 저장
	 */
	private void accountManageInterfaceSave(CoviMap map) {
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("account.accountmanage.getAccountmanageInterfaceSaveCnt", map);

		if (cnt == 0) {
			coviMapperOne.insert("account.accountmanage.accountmanageInterfaceInsert", map);
		} else {
			coviMapperOne.update("account.accountmanage.accountmanageInterfaceUpdate", map);
		}
	}
	
	/**
	 * @Method Name : rtString
	 * @Description : return String
	 */
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}
}
