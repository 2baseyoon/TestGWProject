package egovframework.coviaccount.user.service.impl;

import java.lang.invoke.MethodHandles;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.interfaceUtil.interfaceVO.CostCenterVO;
import egovframework.coviaccount.user.service.BaseCodeSvc;
import egovframework.coviaccount.user.service.CostCenterSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("CostCenterSvc")
public class CostCenterSvcImpl extends EgovAbstractServiceImpl implements CostCenterSvc {
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());

	@Resource(name = "coviMapperOne")
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
	 * @Method Name : getCostCenterlist
	 * @Description : 코스트센터 목록 조회
	 */
	@Override
	public CoviMap getCostCenterlist(CoviMap params) throws Exception {
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
					interfaceParam.put("soapName",			"XpenseGetCCSearchPop");
					interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetCCSearchPop");
				      
					String pSortKey		= rtString(params.get("sortColumn"));
					String pOrder		= rtString(params.get("sortDirection"));
					String soapCostCenterType	= rtString(params.get("soapCostCenterType"));
					String soapCostCenterName	= rtString(params.get("soapCostCenterName"));
					
					CoviMap xmlParam = new CoviMap();
					
					xmlParam.put("pPageSize",		pageSize);
					xmlParam.put("pPageCurrent",	pageNo);
					xmlParam.put("pSortKey",		pSortKey);
					xmlParam.put("pOrder",			pOrder);
					xmlParam.put("pCCGubun",		soapCostCenterType);
					xmlParam.put("pCCName",			soapCostCenterName);
					
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
					String i_kostl	= "";
					String i_ktext	= "";
	
					CoviMap setValues = new CoviMap();
					
					setValues.put("PERNR",		pernr);
					setValues.put("LOGID",		logid);
					setValues.put("ENAME",		ename);
					setValues.put("BUKRS",		bukrs);
					setValues.put("SCRNO",		scrno);
					setValues.put("NO_MASK",	no_mask);
					setValues.put("SPRAS",		spras);
					setValues.put("I_KOSTL",	i_kostl);
					setValues.put("I_KTEXT",	i_ktext);
	
					ArrayList getValues = new ArrayList();
					//getValues.add("get1");
					//getValues.add("get2");
					//getValues.add("get3");
					interfaceParam.put("mapFunctionName",	"getSapMap");
					interfaceParam.put("tableName",			"ZFIS0020");
					interfaceParam.put("sapFunctionName",	"ZFI_IF_F6004_SEND");
					interfaceParam.put("setValues",			setValues);
					interfaceParam.put("getValues",			getValues);
				break;
				
			default:
				//일반 DB조회
				cnt		= (int) coviMapperOne.getNumber("account.costcenter.getCostCenterlistCnt", params);
				
				page 	= ComUtils.setPagingData(params,cnt);
				params.addAll(page);				
				
				list	= coviMapperOne.list("account.costcenter.getCostCenterlist",params);
				interfaceTF = false;
				break;
		}
		
		if(interfaceTF){
			
			interfaceParam.put("interFaceType",			searchProperty);
			interfaceParam.put("daoClassName",			"CostCenterDao");
			interfaceParam.put("voClassName",			"CostCenterVO");
			interfaceParam.put("mapClassName",			"CostCenterMap");

			interfaceParam.put("daoSetFunctionName",	"setCostCenterList");
			interfaceParam.put("daoGetFunctionName",	"getCostCenterList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			CostCenterVO costCenterVO = null;
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
			
			ArrayList arrayList = (ArrayList) getInterface.get("list");
			for (int i = 0; i < arrayList.size(); i++) {
				CoviMap listInfo = new CoviMap();
				
				costCenterVO = (CostCenterVO) arrayList.get(i);
				String companyCode		= costCenterVO.getCompanyCode(); 	// 회사코드
				String costCenterType	= costCenterVO.getCostCenterType();	// CostCenter타입#공통코드
				String costCenterCode	= costCenterVO.getCostCenterCode(); // CostCenter코드
				String costCenterName	= costCenterVO.getCostCenterName();	// CostCenter명
				String nameCode			= costCenterVO.getNameCode();		// 명칭코드
				String usePeriodStart	= costCenterVO.getUsePeriodStart();	// 사용기간시작일
				String usePeriodFinish	= costCenterVO.getUsePeriodFinish();// 사용기간종료일
				String isPermanent		= costCenterVO.getIsPermanent();	// 영구여부
				String isUse			= costCenterVO.getIsUse();			// 사용여부
				String description		= costCenterVO.getDescription();	// 비고
				String totalCount		= costCenterVO.getTotal();
				String registerID		= costCenterVO.getRegisterID();
				String registDate		= costCenterVO.getRegistDate();
				String modifierID		= costCenterVO.getModifierID();
				String modifyDate		= costCenterVO.getModifyDate();
				String usePeriod		= "";
				
				if(costCenterCode.equals("")){
					continue;
				}
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				//데이터 구조가 다른 관계로  임시로 셋팅
				if ((usePeriodStart		== null || usePeriodStart.equals(""))	&&
					(usePeriodFinish	== null || usePeriodFinish.equals(""))) {
					isPermanent		= "Y";
					usePeriodStart	= "19000101";
					usePeriodFinish	= "29991231";
				} else {
					isPermanent		= "N";
				}
				
				if(	usePeriodStart.equals("19000101")	&&
					usePeriodFinish.equals("29991231")){
					isPermanent		= "Y";
				}

				if(registDate.indexOf("T")>0){
					registDate = registDate.substring(0,registDate.indexOf("T"));
				}
				registDate = registDate.replaceAll("[^0-9]", ".");
				
				if(modifyDate.indexOf("T")>0){
					modifyDate = modifyDate.substring(0,modifyDate.indexOf("T"));
				}
				modifyDate = modifyDate.replaceAll("[^0-9]", ".");
				
				SimpleDateFormat dtb = new SimpleDateFormat("yyyyMMdd");
				SimpleDateFormat dta = new SimpleDateFormat("yyyy.MM.dd");
				usePeriod		= dta.format(dtb.parse(usePeriodStart)) +"~"+ dta.format(dtb.parse(usePeriodFinish));
				
				cnt = Integer.parseInt(totalCount);
				
				listInfo.put("CompanyCode",		companyCode);
				listInfo.put("CostCenterType",	costCenterType);
				listInfo.put("CostCenterCode",	costCenterCode);
				listInfo.put("CostCenterName",	costCenterName);
				listInfo.put("NameCode",		nameCode);
				listInfo.put("UsePeriodStart",	usePeriodStart);
				listInfo.put("UsePeriodFinish",	usePeriodFinish);
				listInfo.put("IsPermanent",		isPermanent);
				listInfo.put("IsUse",			isUse);
				listInfo.put("Description",		description);
				listInfo.put("registerID",		registerID);
				listInfo.put("registDate",		registDate);
				listInfo.put("modifierID",		modifierID);
				listInfo.put("modifyDate",		modifyDate);
				
				listInfo.put("UsePeriod",			usePeriod);
				listInfo.put("CostCenterTypeName",	costCenterType);
				
				listInfo.put("RegisterName",		registerID);
				listInfo.put("RegistDate",			registDate);
				
				list.add(listInfo);
			}
			
			page 	= ComUtils.setPagingData(params,cnt);
		}
		
		//page	= accountUtil.listPageCount(cnt, params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);

		return resultList;
	}

	/**
	 * @Method Name : getCostCenterDetail
	 * @Description : 코스트센터 상세 조회
	 */
	@Override
	public CoviMap getCostCenterDetail(CoviMap params) throws Exception {

		CoviMap resultList = new CoviMap();
		CoviList list = null;

		String costCenterID = params.get("costCenterID") == null ? "" : params.get("costCenterID").toString();
		
		if (costCenterID.equals("")) {
			list = coviMapperOne.list("account.costcenter.getCostCenterDetailDefault", params);
		} else {
			list = coviMapperOne.list("account.costcenter.getCostCenterDetail",params);
		}

		resultList.put("list",AccountUtil.convertNullToSpace(list));
		return resultList;
	}
	
	/**
	 * @Method Name : getCostCenterCodeCnt
	 * @Description : 코스트센터 코드 존재 여부 확인
	 */
	@Override
	public CoviMap getCostCenterCodeCnt(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();		

		int cnt = (int) coviMapperOne.getNumber("account.costcenter.getCostCenterCodeCnt", params); // ID체크(등록/수정)
		resultList.put("cnt", cnt);

		return resultList;
	}

	/**
	 * @Method Name : saveCostCenterInfo
	 * @Description : 코스트센터 정보 저장
	 */
	@Override
	public CoviMap saveCostCenterInfo(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		String costCenterID = params.get("costCenterID") == null ? "" : params.get("costCenterID").toString();
		String saveProperty = params.get("saveProperty").toString();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		if(saveProperty.equals("Y")){
			if (costCenterID.equals("")) {
				insertCostCenterInfo(params);
			} else {
				updateCostCenterInfo(params);
			}
		}else{
			int cnt = (int) coviMapperOne.getNumber("account.costcenter.getCostCenterCodeCnt", params); // ID체크(등록/수정)
			if (cnt == 0) {
				insertCostCenterInfo(params);
			} else if(cnt == 1){
				updateCostCenterInfo(params);
			}
		}

		return resultList;
	}

	/**
	 * @Method Name : deleteCostCenter
	 * @Description : 코스트센터 삭제
	 */
	@Override
	public CoviMap deleteCostCenter(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();

		String deleteStr = params.get("deleteSeq") == null ? "" : params.get("deleteSeq").toString();
		if (!deleteStr.equals("")) {
			String[] deleteArr = deleteStr.split(",");
			for (int i = 0; i < deleteArr.length; i++) {
				CoviMap sqlParam = new CoviMap();
				sqlParam.put("costCenterID", deleteArr[i]);
				deleteCostCenterInfo(sqlParam);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : deleteCostCenterInfo
	 * @Description : 코스트센터 Delete
	 */
	public void deleteCostCenterInfo(CoviMap params) throws Exception {
		coviMapperOne.delete("account.costcenter.deleteCostCenterInfo", params);
	}

	/**
	 * @Method Name : insertCostCenterInfo
	 * @Description : 코스트센터 Insert
	 */
	public void insertCostCenterInfo(CoviMap params) throws Exception {
		coviMapperOne.insert("account.costcenter.insertCostCenterInfo", params);
	}

	/**
	 * @Method Name : updateCostCenterInfo
	 * @Description : 코스트센터 Update
	 */
	public void updateCostCenterInfo(CoviMap params) throws Exception {
		coviMapperOne.update("account.costcenter.updateCostCenterInfo", params);
	}

	/**
	 * @Method Name : getCostCenterExcelList
	 * @Description : 코스트센터 엑셀 다운로드
	 */
	@Override
	public CoviMap getCostCenterExcelList(CoviMap params) throws Exception {
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
					interfaceParam.put("soapName",			"XpenseGetCCSearchPop");
					interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetCCSearchPop");
				      
					String soapCostCenterType	= rtString(params.get("soapCostCenterType"));
					String soapCostCenterName	= rtString(params.get("soapCostCenterName"));
					
					CoviMap xmlParam = new CoviMap();
					
				    xmlParam.put("pSortKey",		"");
				    xmlParam.put("pOrder",			"");
					xmlParam.put("pCCGubun",		soapCostCenterType);
					xmlParam.put("pCCName",			soapCostCenterName);
				
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
					String i_kostl	= "";
					String i_ktext	= rtString(params.get("soapCostCenterName"));
	
					CoviMap setValues = new CoviMap();
					
					setValues.put("PERNR",		pernr);
					setValues.put("LOGID",		logid);
					setValues.put("ENAME",		ename);
					setValues.put("BUKRS",		bukrs);
					setValues.put("SCRNO",		scrno);
					setValues.put("NO_MASK",	no_mask);
					setValues.put("SPRAS",		spras);
					setValues.put("I_KOSTL",	i_kostl);
					setValues.put("I_KTEXT",	i_ktext);
	
					ArrayList getValues = new ArrayList();
					//getValues.add("get1");
					//getValues.add("get2");
					//getValues.add("get3");
					interfaceParam.put("mapFunctionName",	"getSapMap");
					interfaceParam.put("tableName",			"ZFIS0020");
					interfaceParam.put("sapFunctionName",	"ZFI_IF_F6004_SEND");
					interfaceParam.put("setValues",			setValues);
					interfaceParam.put("getValues",			getValues);
				break;
				
			default:
				//일반 DB조회
				list	= coviMapperOne.list("account.costcenter.getCostCenterExcelList", params);
				cnt		= (int) coviMapperOne.getNumber("account.costcenter.getCostCenterlistCnt", params);
				interfaceTF = false;
				break;
		}
		
		if(interfaceTF){
			
			interfaceParam.put("interFaceType",			searchProperty);
			interfaceParam.put("daoClassName",			"CostCenterDao");
			interfaceParam.put("voClassName",			"CostCenterVO");
			interfaceParam.put("mapClassName",			"CostCenterMap");

			interfaceParam.put("daoSetFunctionName",	"setCostCenterList");
			interfaceParam.put("daoGetFunctionName",	"getCostCenterList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			CostCenterVO costCenterVO = null;
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
			
			ArrayList arrayList = (ArrayList) getInterface.get("list");
			for (int i = 0; i < arrayList.size(); i++) {
				CoviMap listInfo = new CoviMap();
				
				costCenterVO = (CostCenterVO) arrayList.get(i);
				String companyCode		= costCenterVO.getCompanyCode(); 	// 회사코드
				String costCenterType	= costCenterVO.getCostCenterType();	// CostCenter타입#공통코드
				String costCenterCode	= costCenterVO.getCostCenterCode(); // CostCenter코드
				String costCenterName	= costCenterVO.getCostCenterName();	// CostCenter명
				String nameCode			= costCenterVO.getNameCode();		// 명칭코드
				String usePeriodStart	= costCenterVO.getUsePeriodStart();	// 사용기간시작일
				String usePeriodFinish	= costCenterVO.getUsePeriodFinish();// 사용기간종료일
				String isPermanent		= costCenterVO.getIsPermanent();	// 영구여부
				String isUse			= costCenterVO.getIsUse();			// 사용여부
				String description		= costCenterVO.getDescription();	// 비고
				String registerID		= costCenterVO.getRegisterID();
				String registDate		= costCenterVO.getRegistDate();
				String modifierID		= costCenterVO.getModifierID();
				String modifyDate		= costCenterVO.getModifyDate();
				
				String totalCount		= costCenterVO.getTotal();
				String UsePeriod		= "";
				
				if(costCenterCode.equals("")){
					continue;
				}
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				//데이터 구조가 다른 관계로  임시로 셋팅
				if ((usePeriodStart		== null || usePeriodStart.equals(""))	&&
					(usePeriodFinish	== null || usePeriodFinish.equals(""))) {
					isPermanent		= "Y";
					usePeriodStart	= "19000101";
					usePeriodFinish	= "29991231";
				} else {
					isPermanent		= "N";
				}
				
				if(	usePeriodStart.equals("19000101")	&&
					usePeriodFinish.equals("29991231")){
					isPermanent		= "Y";
				}

				if(registDate.indexOf("T")>0){
					registDate = registDate.substring(0,registDate.indexOf("T"));
				}
				registDate = registDate.replaceAll("[^0-9]", ".");
				
				if(modifyDate.indexOf("T")>0){
					modifyDate = modifyDate.substring(0,modifyDate.indexOf("T"));
				}
				modifyDate = modifyDate.replaceAll("[^0-9]", ".");
				
				SimpleDateFormat dtb = new SimpleDateFormat("yyyyMMdd");
				SimpleDateFormat dta = new SimpleDateFormat("yyyy.MM.dd");
				UsePeriod		= dta.format(dtb.parse(usePeriodStart)) +"~"+ dta.format(dtb.parse(usePeriodFinish));

				cnt = Integer.parseInt(totalCount);
				
				listInfo.put("CompanyCode",		companyCode);
				listInfo.put("CostCenterType",	costCenterType);
				listInfo.put("CostCenterCode",	costCenterCode);
				listInfo.put("CostCenterName",	costCenterName);
				listInfo.put("NameCode",		nameCode);
				listInfo.put("UsePeriodStart",	usePeriodStart);
				listInfo.put("UsePeriodFinish",	usePeriodFinish);
				listInfo.put("IsPermanent",		isPermanent);
				listInfo.put("IsUse",			isUse);
				listInfo.put("Description",		description);
				listInfo.put("registerID",		registerID);
				listInfo.put("registDate",		registDate);
				listInfo.put("modifierID",		modifierID);
				listInfo.put("modifyDate",		modifyDate);
				
				listInfo.put("UsePeriod",			UsePeriod);
				listInfo.put("CostCenterTypeName",	costCenterType);
				
				listInfo.put("RegisterName",		registerID);
				listInfo.put("RegistDate",			registDate);
				
				list.add(listInfo);
			}
		}
		
		resultList.put("list",accountExcelUtil.selectJSONForExcel(list, headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}

	/**
	 * @Method Name : costCenterExcelUpload
	 * @Description : 코스트센터 엑셀 업로드
	 */
	@Override
	public CoviMap costCenterExcelUpload(CoviMap params) throws Exception {
		int cnt = 0;
		CoviMap resultList = new CoviMap();

		ArrayList<ArrayList<Object>> dataList = accountExcelUtil.extractionExcelData(params, 1);	// 엑셀 데이터 추출
		
		// index | (0) = 회사명 | (1) = CostCenter구분 | (2) = CostCenter코드 | (3) = CostCenter명 | (4) = 프로젝트명 | (5) = 사용기간 | (6) = 사용여부 |
		// (7) = 비고 | (8) = 영구사용 | 
		String propertyType = rtString(params.get("saveProperty")); 
		
		for (ArrayList list : dataList) { // 데이터체크
			if( accountUtil.checkNull(list.get(0).toString()) || 
				accountUtil.checkNull(list.get(1).toString()) ||
				accountUtil.checkNull(list.get(3).toString()) ||
				accountUtil.checkNull(list.get(6).toString()) ){
				resultList.put("err", "subStr");
				return resultList;
			}
			if(accountUtil.checkNull(list.get(5).toString()) && list.get(8).toString().equals("N") ){
				resultList.put("err", "subStr");
				return resultList;
			}

			if(propertyType.equals("Y")){
				String costCenterCode = list.get(2) == null ? "" : list.get(2).toString();
				params.put("costCenterCode", costCenterCode);
				cnt = (int) coviMapperOne.getNumber("account.costcenter.getCostCenterCodeCnt", params); // ID체크(등록/수정)
				if (costCenterCode.equals("")) {
	
				} else if (cnt == 0) { // 아웃
					resultList.put("err", "costCenterCode");
					return resultList;
				}
			}
		}

		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		if(propertyType.equals("Y")){
			for (ArrayList list : dataList) { // 추가
				String companyCode 		 = list.get(0) == null ? "" : list.get(0).toString();
				String costCenterType 	 = list.get(1) == null ? "" : list.get(1).toString();
				String costCenterCode 	 = list.get(2) == null ? "" : list.get(2).toString();
				String costCenterName	 = list.get(3) == null ? "" : list.get(3).toString();
				String nameCode			 = list.get(4) == null ? "" : list.get(4).toString();
				String date				 = list.get(5) == null ? "" : list.get(5).toString();
				String isUse 			 = list.get(6) == null ? "" : list.get(6).toString();
				String description		 = list.get(7) == null ? "" : list.get(7).toString();
				String isPermanent 		 = list.get(8) == null ? "" : list.get(8).toString();
				String usePeriodStart 	 = "19000101";
				String usePeriodFinish   = "29991231";
				if(isPermanent.equals("N") || isPermanent.equals("")){
					List<String> dateStr 	 = Arrays.asList(date.split(" ~ "));
					usePeriodStart	 = dateStr.get(0).replace(".", "");
					usePeriodFinish	 = dateStr.get(1).replace(".", "");
				}
				CoviMap searchStr		= new CoviMap();
	
				searchStr.put("codeGroup", "CompanyCode");
				searchStr.put("codeName", companyCode);
				companyCode = baseCodeSvc.selectBaseCodeByCodeName(searchStr); // 회사코드

				// 검색조건에 회사코드 추가
				searchStr.put("companyCode", companyCode);
	
				searchStr.put("codeGroup", "CostCenterGubun");
				searchStr.put("codeName", costCenterType);
				costCenterType = baseCodeSvc.selectBaseCodeByCodeName(searchStr); // 회사코드					
				
				params.put("companyCode", companyCode);
				params.put("costCenterCode", costCenterCode);
				params.put("costCenterName", costCenterName);
				params.put("nameCode", nameCode);
				params.put("usePeriodStart", usePeriodStart);
				params.put("usePeriodFinish", usePeriodFinish);
				params.put("description", description);
				params.put("costCenterType", costCenterType);
				params.put("isUse", isUse);
				params.put("isPermanent", isPermanent);
				
				if (costCenterCode.equals("")) { // 추가
					CoviMap map = new CoviMap();
					map = coviMapperOne.selectOne("account.costcenter.getCostCenterDetailDefaultExcel",params);
					params.put("costCenterCode", map.get("CostCenterCode"));
					coviMapperOne.insert("account.costcenter.insertCostCenterInfoExcel", params);
				} else { // 수정
					CoviMap map = new CoviMap();
					map = coviMapperOne.selectOne("account.costcenter.getCostCenterCodeCostCenterID",costCenterCode);
					String costCenterID = map.get("CostCenterID") == null ? "" : map.get("CostCenterID").toString();
					params.put("costCenterID", costCenterID);
					coviMapperOne.update("account.costcenter.updateCostCenterInfoExcel", params);
				}
			}
		}else{
			for (ArrayList list : dataList) { // 추가
				String companyCode 		 = list.get(0) == null ? "" : list.get(0).toString();
				String costCenterType 	 = list.get(1) == null ? "" : list.get(1).toString();
				String costCenterCode 	 = list.get(2) == null ? "" : list.get(2).toString();
				String costCenterName	 = list.get(3) == null ? "" : list.get(3).toString();
				String nameCode			 = list.get(4) == null ? "" : list.get(4).toString();
				String date				 = list.get(5) == null ? "" : list.get(5).toString();
				String isUse 			 = list.get(6) == null ? "" : list.get(6).toString();
				String description		 = list.get(7) == null ? "" : list.get(7).toString();
				String isPermanent 		 = list.get(8) == null ? "" : list.get(8).toString();
				String usePeriodStart 	 = "19000101";
				String usePeriodFinish   = "29991231";
				if(isPermanent.equals("N") || isPermanent.equals("")){
					List<String> dateStr 	 = Arrays.asList(date.split(" ~ "));
					usePeriodStart	 = dateStr.get(0).replace(".", "");
					usePeriodFinish	 = dateStr.get(1).replace(".", "");
				}
				CoviMap searchStr		= new CoviMap();
				
				searchStr.put("codeGroup", "CompanyCode");
				searchStr.put("codeName", companyCode);
				companyCode = baseCodeSvc.selectBaseCodeByCodeName(searchStr); // 회사코드

				// 검색조건에 회사코드 추가
				searchStr.put("companyCode", companyCode);
	
				searchStr.put("codeGroup", "CostCenterGubun");
				searchStr.put("codeName", costCenterType);
				costCenterType = baseCodeSvc.selectBaseCodeByCodeName(searchStr); // 회사코드		

				params.put("companyCode", companyCode);
				params.put("costCenterCode", costCenterCode);
				params.put("costCenterName", costCenterName);
				params.put("nameCode", nameCode);
				params.put("usePeriodStart", usePeriodStart);
				params.put("usePeriodFinish", usePeriodFinish);
				params.put("description", description);
				params.put("costCenterType", costCenterType);
				params.put("isUse", isUse);
				params.put("isPermanent", isPermanent);
				
				cnt = (int) coviMapperOne.getNumber("account.costcenter.getCostCenterCodeCnt", params); // ID체크(등록/수정)
				
				if (costCenterCode.equals("")) { // 추가
					continue;
				} else if (cnt == 1){ // 수정
					CoviMap map = new CoviMap();
					map = coviMapperOne.selectOne("account.costcenter.getCostCenterCodeCostCenterID",costCenterCode);
					String costCenterID = map.get("CostCenterID") == null ? "" : map.get("CostCenterID").toString();
					params.put("costCenterID", costCenterID);
					coviMapperOne.update("account.costcenter.updateCostCenterInfoExcel", params);
				} else if (cnt == 0){
					coviMapperOne.insert("account.costcenter.insertCostCenterInfoExcel", params);
				}
			}
		}
		return resultList;
	}

	/**
	 * @Method Name : getCostCenterUserMappingDeptList
	 * @Description : 코스트센터 유저 맵핑 리스트[부서]
	 */
	@Override
	public CoviList getCostCenterUserMappingDeptList(CoviMap params)
			throws Exception {
		String lang = SessionHelper.getSession("lang");
		CoviList list = coviMapperOne.list("account.costcenter.getCostCenterUserMappingDeptList", params);

		CoviList resultList = new CoviList();
		CoviList deptList = CoviSelectSet.coviSelectJSON(list,"itemType,CompanyCode,GroupCode,GroupType,CompanyName,GroupName,PrimaryMail,MemberOf,AN,DN,EM,ETID,ETNM,SGAN,SGDN,RCV,SortPath,GroupPath,GroupID,hasChild,GroupFullPath");

		for (Object dept : deptList) {
			CoviMap deptObj = null;

			deptObj = (CoviMap) dept;

			deptObj.put("no",			getSortNo(deptObj.getString("SortPath")));
			deptObj.put("nodeName",		DicHelper.getDicInfo(deptObj.getString("GroupName"), lang));
			deptObj.put("nodeValue",	deptObj.get("GroupCode"));
			deptObj.put("groupID",		deptObj.get("GroupID"));
			deptObj.put("pno",			getParentSortNo(deptObj.getString("SortPath")));
			deptObj.put("chk",			"N");
			deptObj.put("rdo",			"N");

			resultList.add(deptObj);
		}
		return resultList;
	}

	/**
	 * @Method Name : getCostCenterUserMappingUserList
	 * @Description : 코스트센터 유저 맵핑 리스트
	 */
	@Override
	public CoviMap getCostCenterUserMappingUserList(CoviMap params)throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("account.costcenter.getCostCenterUserMappingUserList", params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList;
	}

	/**
	 * @Method Name : getSortNo
	 * @Description : sort Number
	 */
	private String getSortNo(String pStr) {
		if (pStr == null || pStr.equals("")) {
			return "";
		} else {
			String[] strArr = pStr.split(";");
			StringBuilder strReturn = new StringBuilder();

			if(strArr != null) {
				for (String str : strArr) {
					strReturn.append(str);
				}
			}

			return strReturn.toString();
		}
	}

	/**
	 * @Method Name : getParentSortNo
	 * @Description : Parent Sort Number
	 */
	private String getParentSortNo(String pStr) {
		String[] strArr = pStr.split(";");
		StringBuilder resultStr = new StringBuilder();

		for (int i = 0; strArr != null && i < strArr.length - 1; i++) {
			if(strArr[i] != null && !"".equals(strArr[i])) {
				if(resultStr.length() > 0) {
					resultStr.append(";");
				}
				resultStr.append(strArr[i]);
			}
		}
		return getSortNo(resultStr.toString());
	}

	/**
	 * @Method Name : updateCostCenterUserMappingInfo
	 * @Description : 코스트센터 유저 맵핑 정보 저장
	 */
	@Override
	public CoviMap updateCostCenterUserMappingInfo(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		
		ArrayList<Map<String, Object>> rList = (ArrayList<Map<String, Object>>) params.get("rList");
		
		for(int i=0; i <rList.size(); i++){
			
			CoviMap infoListParam = new CoviMap(rList.get(i));
			
			String userCostCenterID = infoListParam.get("userCostCenterID") == null ? "" : infoListParam.get("userCostCenterID").toString();
			infoListParam.put("UR_Code", SessionHelper.getSession("UR_Code"));
			
			if(userCostCenterID.equals("")){
				//insert
				insertCenterUserMappingInfo(infoListParam);
			}else{
				//update
				updateCenterUserMappingInfo(infoListParam);
			}
		}
		return resultList;
	}

	/**
	 * @Method Name : insertCenterUserMappingInfo
	 * @Description : 코스트센터 유저 맵핑 정보 Insert
	 */
	public void insertCenterUserMappingInfo(CoviMap params) throws Exception {
		coviMapperOne.insert("account.costcenter.insertCenterUserMappingInfo",params);
	}

	/**
	 * @Method Name : updateCenterUserMappingInfo
	 * @Description : 코스트센터 유저 맵핑 정보 Update
	 */
	public void updateCenterUserMappingInfo(CoviMap params) throws Exception {
		coviMapperOne.update("account.costcenter.updateCenterUserMappingInfo",params);
	}

	/**
	 * @Method Name : getCostCenterUserMappingExcelList
	 * @Description : 사용자별 코스트센터 맵핑 엑셀 다운로드
	 */
	@Override
	public CoviMap getCostCenterUserMappingExcelList(CoviMap params) throws Exception {
		
		CoviMap resultList	= new CoviMap();
		
		String headerKey	= params.get("headerKey").toString();
		int cnt				= 0;
		
		params.put("assignedDomain", ComUtils.getAssignedDomainCode());
		
		//일반 DB조회
		CoviList list	= coviMapperOne.list("account.costcenter.getCostCenterUserMappingExcelList", params);
		cnt		= (int) coviMapperOne.getNumber("account.costcenter.getCostCenterUserMappingExcelListCnt", params);
		
		
		resultList.put("list",accountExcelUtil.selectJSONForExcel(list, headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}
	

	/**
	 * @Method Name : costCenterUserMappingExcelUpload
	 * @Description : 사용자별 코스트센터 맵핑 엑셀 업로드
	 */
	@Override
	public CoviMap costCenterUserMappingExcelUpload(CoviMap params) throws Exception {
		int cnt = 0;
		CoviMap resultList = new CoviMap();

		ArrayList<ArrayList<Object>> dataList = accountExcelUtil.extractionExcelData(params, 1);	// 엑셀 데이터 추출
		
		// index | (0) = 회사명 | (1) = 사용자코드 | (2) = 사용자명  | (3) = CostCenter코드
		
		for (ArrayList list : dataList) { // 데이터체크
			if( accountUtil.checkNull(list.get(0).toString()) || 
				accountUtil.checkNull(list.get(1).toString()) ||
				accountUtil.checkNull(list.get(3).toString())) {
				resultList.put("err", "nullErr");
				return resultList;
			}
			
			CoviMap tempMap = new CoviMap();
			int tempCnt = 0;
			
			//costcenter 존재 여부
			tempMap.put("costCenterCode", list.get(3).toString());
			tempCnt = (int) coviMapperOne.getNumber("account.costcenter.getCostCenterCodeCnt", tempMap);
			if(tempCnt == 0) {
				resultList.put("err", "notExistCostCenterErr");
				return resultList;				
			}
			
			tempMap = new CoviMap();
			
			//사용자 존재 여부
			tempMap.put("userCode", list.get(1).toString());
			tempCnt = (int) coviMapperOne.getNumber("account.costcenter.getUserCodeCnt", tempMap);
			
			if(tempCnt == 0) {
				resultList.put("err", "notExistUserErr");
				return resultList;				
			}
		}

		params.put("SessionUser", SessionHelper.getSession("UR_Code"));
		for (ArrayList list : dataList) { // 추가
			String companyCode		= list.get(0) == null ? "" : list.get(0).toString();
			String userCode			= list.get(1) == null ? "" : list.get(1).toString();
			String costCenterCode 	= list.get(3) == null ? "" : list.get(3).toString();
			CoviMap searchStr		= new CoviMap();

			searchStr.put("codeGroup", "CompanyCode");
			searchStr.put("codeName", companyCode);
			companyCode = baseCodeSvc.selectBaseCodeByCodeName(searchStr); // 회사코드
			
			params.put("companyCode", companyCode);
			params.put("userCode", userCode);
			params.put("costCenterCode", costCenterCode);
			
			cnt = (int) coviMapperOne.getNumber("account.costcenter.getCostCenterUserCodeCnt", params); // 사용자 등록 여부 체크(등록/수정)
			
			if (costCenterCode.equals("") || userCode.equals("")) {
				continue;
			} else if (cnt == 1){ // 수정
				coviMapperOne.update("account.costcenter.updateCostCenterUserMappingInfoExcel", params);
			} else if (cnt == 0){ // 추가
				coviMapperOne.insert("account.costcenter.insertCostCenterUserMappingInfoExcel", params);
			}
		}
		return resultList;
	}

	/**
	 * @Method Name : costCenterSync
	 * @Description : 코스트센터 동기화
	 */
	@Override
	public CoviMap costCenterSync(){

		CoviMap interfaceParam		= new CoviMap();
		CoviMap resultList		= new CoviMap();
		CostCenterVO costCenterVO	= null;
		
		try{
			
			//String syncType = accountUtil.getPropertyInfo("account.syncType.CostCenter");
			String syncType = accountUtil.getBaseCodeInfo("eAccSyncType", "CostCenter");
			
			interfaceParam.put("interFaceType",			syncType);
			interfaceParam.put("daoClassName",			"CostCenterDao");
			interfaceParam.put("voClassName",			"CostCenterVO");
			interfaceParam.put("mapClassName",			"CostCenterMap");
	
			interfaceParam.put("daoSetFunctionName",	"setCostCenterList");
			interfaceParam.put("daoGetFunctionName",	"getCostCenterList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			switch (syncType) {
				case "DB":
					//syncType이 DB인 경우 이곳에 정의
						interfaceParam.put("mapFunctionName",	"getDBMap");
						interfaceParam.put("type",				"get");
						interfaceParam.put("sqlName",			"accountInterFace.AccountSI.getInterFaceListCostCenter");
					break;
		
				case "SOAP":
					//syncType이 SOAP인 경우 이곳에 정의
						CoviMap xmlParam = new CoviMap();
						
					    xmlParam.put("pSortKey",		"");
					    xmlParam.put("pOrder",			"");
					    xmlParam.put("pCCGubun",		"");
					    xmlParam.put("pCCName",			"");
					    
						interfaceParam.put("xmlParam",			xmlParam);
						interfaceParam.put("mapFunctionName",	"getSoapMap");
						interfaceParam.put("soapName",			"XpenseGetCostCenterList");
						interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetCostCenterList");
					
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
					String i_kostl	= "";
					String i_ktext	= "";

					CoviMap setValues = new CoviMap();
					
					setValues.put("PERNR",		pernr);
					setValues.put("LOGID",		logid);
					setValues.put("ENAME",		ename);
					setValues.put("BUKRS",		bukrs);
					setValues.put("SCRNO",		scrno);
					setValues.put("NO_MASK",	no_mask);
					setValues.put("SPRAS",		spras);
					setValues.put("I_KOSTL",	i_kostl);
					setValues.put("I_KTEXT",	i_ktext);

					ArrayList getValues = new ArrayList();
					//getValues.add("get1");
					//getValues.add("get2");
					//getValues.add("get3");
					interfaceParam.put("mapFunctionName",	"getSapMap");
					interfaceParam.put("tableName",			"ZFIS0020");
					interfaceParam.put("sapFunctionName",	"ZFI_IF_F6004_SEND");
					interfaceParam.put("setValues",			setValues);
					interfaceParam.put("getValues",			getValues);
					break;
				case "SAPOdata":
					//syncType이 SAPOdata인 경우 이곳에 정의
					String sGetParam = "";
					interfaceParam.put("mapFunctionName",		"getSapODataMap");
					sGetParam = accountUtil.addGetParam(sGetParam,"Language","KO","eq","and");
					sGetParam = accountUtil.addGetParam(sGetParam,"ControllingArea","A000","eq","and");			
					interfaceParam.put("SAPOdataFuntionName", "API_COSTCENTER_SRV/A_CostCenterText");
					interfaceParam.put("SAPOdataParam", sGetParam);								
					break;
					
				default :
					break;
			}
	
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
	
			ArrayList list = (ArrayList) getInterface.get("list");
	
			String sessionUser = SessionHelper.getSession("UR_Code");
			int iListSize = list.size();
			for (int i = 0; i < iListSize; i++) {
				CoviMap listInfo = new CoviMap();
				costCenterVO = (CostCenterVO) list.get(i);
				String companyCode		= costCenterVO.getCompanyCode(); // 회사코드
				String costCenterType	= costCenterVO.getCostCenterType(); // CostCenter타입#공통코드
				String costCenterCode	= costCenterVO.getCostCenterCode(); // CostCenter코드
				String costCenterName	= costCenterVO.getCostCenterName(); // CostCenter명
				String nameCode			= costCenterVO.getNameCode(); // 명칭코드
				String usePeriodStart	= costCenterVO.getUsePeriodStart(); // 사용기간시작일
				String usePeriodFinish	= costCenterVO.getUsePeriodFinish();// 사용기간종료일
				String isPermanent		= costCenterVO.getIsPermanent(); // 영구여부
				String isUse			= costCenterVO.getIsUse(); // 사용여부
				String description		= costCenterVO.getDescription(); // 비고
				String registerID		= costCenterVO.getRegisterID();
				String registDate		= costCenterVO.getRegistDate();
				String modifierID		= costCenterVO.getModifierID();
				String modifyDate		= costCenterVO.getModifyDate();
	
				Date dUsePeriodStart;
				Date dUsePeriodFinish;
				dUsePeriodStart = accountUtil.getDateFromJsonDate(usePeriodStart);
				dUsePeriodFinish = accountUtil.getDateFromJsonDate(usePeriodFinish);
				SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
				if(dUsePeriodStart != null){
					usePeriodStart = sdf.format(dUsePeriodStart);
				}
				if(dUsePeriodFinish != null){
					usePeriodFinish = sdf.format(dUsePeriodFinish);
				}
				
				if(isPermanent == null || isPermanent.equals(""))
					isPermanent		= "Y";
				
				if(isUse == null || isUse.equals(""))
					isUse		= "Y";				
				
				if ((usePeriodStart		== null || usePeriodStart.equals(""))	&&
					(usePeriodFinish	== null || usePeriodFinish.equals(""))) {
					isPermanent		= "Y";
					usePeriodStart	= "19000101";
					usePeriodFinish	= "29991231";
				} else {
					isPermanent		= "N";
				}
				
				if(	usePeriodStart.equals("19000101")	&&
					usePeriodFinish.equals("29991231")){
					isPermanent		= "Y";
				}
	
				if(registDate.indexOf("T")>0){
					registDate = registDate.substring(0,registDate.indexOf("T"));
				}
				registDate = registDate.replaceAll("[^0-9]", ".");
				
				if(modifyDate.indexOf("T")>0){
					modifyDate = modifyDate.substring(0,modifyDate.indexOf("T"));
				}
				modifyDate = modifyDate.replaceAll("[^0-9]", ".");
				
				listInfo.put("UR_Code",			sessionUser);
				listInfo.put("companyCode",		companyCode.equals("") ? "ALL" : companyCode);
				listInfo.put("costCenterType",	costCenterType);
				listInfo.put("costCenterCode",	costCenterCode);
				listInfo.put("costCenterName",	costCenterName);
				listInfo.put("nameCode",		nameCode);
				listInfo.put("usePeriodStart",	usePeriodStart);
				listInfo.put("usePeriodFinish",	usePeriodFinish);
				listInfo.put("isPermanent",		isPermanent);
				listInfo.put("isUse",			isUse);
				listInfo.put("description",		description);
				listInfo.put("registerID",		registerID);
				listInfo.put("registDate",		registDate);
				listInfo.put("modifierID",		modifierID);
				listInfo.put("modifyDate",		modifyDate);
				
				costCenterInterfaceSave(listInfo);
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
	 * @Method Name : costCenterInterfaceSave
	 * @Description : 코스트센터 동기화 저장
	 */
	private void costCenterInterfaceSave(CoviMap map) {
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("account.costcenter.getCostCenterInterfaceSaveCnt", map);

		if (cnt == 0) {
			coviMapperOne.insert("account.costcenter.costCenterInterfaceInsert", map);
		} else {
			coviMapperOne.update("account.costcenter.costCenterInterfaceUpdate", map);
		}
	}
	
	/**
	 * @Method Name : costCenterUserMappingSync
	 * @Description : 사용자 별 코스트센터 매핑 동기화
	 */
	@Override
	public CoviMap costCenterUserMappingSync(){

		CoviMap resultList		= new CoviMap();
		int cnt = 0;
		
		try{
			//TODO: xml 쪽 구현 필요 (mapper 없음)
			/*
			CoviMap listParams = new CoviMap();
			CoviList list = coviMapperOne.list("account.costcenter.getCostCenterUserMappingInterfaceList", listParams);
			
			for(int i = 0; i < list.size(); i++) {
				CoviMap params = new CoviMap();
				params = list.getMap(i);
				params.put("SessionUser", SessionHelper.getSession("UR_Code"));
				
				cnt = 0;
				cnt = (int)coviMapperOne.getNumber("account.costcenter.chkDuplCostCenterUserMapping", params);
				
				if(cnt == 0) {
					coviMapperOne.insert("account.costcenter.insertCostCenterUserMappingInterface", params);
				} else {
					coviMapperOne.update("account.costcenter.updateCostCenterUserMappingInterface", params);	
				}
			}
			*/
			resultList.put("status",	Return.SUCCESS);
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
	 * @Method Name : rtString
	 * @Description : return String
	 */
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}
}
