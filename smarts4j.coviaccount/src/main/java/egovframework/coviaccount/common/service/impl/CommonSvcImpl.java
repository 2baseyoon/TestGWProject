package egovframework.coviaccount.common.service.impl;

import java.io.File;
import java.io.IOException;
import java.lang.invoke.MethodHandles;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.annotation.Resource;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.service.CommonSvc;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.interfaceUtil.interfaceVO.AccountManageVO;
import egovframework.coviaccount.interfaceUtil.interfaceVO.BaseCodeVO;
import egovframework.coviaccount.interfaceUtil.interfaceVO.CardReceiptVO;
import egovframework.coviaccount.interfaceUtil.interfaceVO.CostCenterVO;
import egovframework.coviaccount.interfaceUtil.interfaceVO.TaxInvoiceVO;
import egovframework.coviaccount.user.service.TaxInvoiceSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("CommonSvc")
public class CommonSvcImpl extends EgovAbstractServiceImpl implements CommonSvc {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	@Autowired
	private TaxInvoiceSvc taxInvoiceSvc;

	@Override
	public String getCompanyCodeOfUser() throws Exception {
		if ("Y".equals(RedisDataUtil.getBaseConfig("eAccCompanyCode"))) {
			return SessionHelper.getSession("DN_Code");
		}
		// 기준정보 관리 등에서 해당 사용자의 권한 도메인에 ORGROOT가 있을 경우 그룹사 관리자로 간주하여 ALL 반환
		CoviMap searchParams = new CoviMap();
		searchParams.put("SessionUser", SessionHelper.getSession("UR_Code"));
		searchParams.put("AssignedDomain", SessionHelper.getSession("AssignedDomain"));
		return coviMapperOne.selectOne("account.common.selectCompanyCodeOfUser", searchParams);
	}

	@Override
	public String getCompanyCodeOfUser(String sessionUser) throws Exception {
		if ("Y".equals(RedisDataUtil.getBaseConfig("eAccCompanyCode"))) {
			return SessionHelper.getSession("DN_Code");
		}
		// 사용자 페이지 등에서 해당 사용자의 권한 도메인과 관련 없이 속해있는 도메인으로 반환 
		CoviMap searchParams = new CoviMap();
		searchParams.put("SessionUser", sessionUser);
		searchParams.put("AssignedDomain", "");
		return coviMapperOne.selectOne("account.common.selectCompanyCodeOfUser", searchParams);
	}
	
	/**
	 * @Method getBaseCodeCombo List Search
	 * @작성자 Covision
	 * @작성일 2018. 5. 8.
	 * @param params
	 * @throws Exception
	 */
	@Override
	public CoviList getBaseCodeCombo(CoviMap params) throws Exception {
		CoviList resultList	= null;
		CoviList list	= null;
		if(params.getString("codeGroup").equals("FormManage_RequestType")) {
			list = coviMapperOne.list("account.formmanage.getFormManageCodeCombo", params); 
		} else {
			list = coviMapperOne.list("account.common.getBaseCodeCombo", params);	
		}
		resultList		= convertToJSON(list);
		
		return resultList; 
	}
	
	/**
	 * @Method getBaseCodeComboMulti List Search
	 * @작성자 Covision
	 * @작성일 2018. 5. 8.
	 * @param params
	 * @throws Exception
	 */
	@Override
	public CoviList getBaseCodeComboMulti(CoviMap params) throws Exception {
		CoviList resultList	= null;
		
		String[] codeGroups = params.getString("codeGroups").split(",");
		
		List<String> arrayList = new ArrayList<>();
        for(String item : codeGroups){
            if(!arrayList.contains(item))
                arrayList.add(item);
        }
        
		CoviList list = new CoviList();
		for(int i=0; i<arrayList.size(); i++){
			params.put("codeGroup", arrayList.get(i));
			list.addAll(coviMapperOne.list("account.common.getBaseCodeCombo", params));
		}
		
		resultList = convertToJSON(list);
		return resultList; 
	}
	
	@Override
	public CoviList getBaseCodeData(CoviMap params) throws Exception {
		CoviList resultList	= null;
		params.put("chkIsUse", "Y");
		CoviList list	= coviMapperOne.list("account.common.getBaseCodeData", params);
		resultList		= convertToJSON(list);
		return resultList; 
	}

	@Override
	public CoviList getBaseCodeDataAll(CoviMap params) throws Exception {
		CoviList resultList	= null;
		CoviList list	= coviMapperOne.list("account.common.getBaseCodeData", params);
		resultList		= convertToJSON(list);
		return resultList; 
	}
	
	@Override
	public CoviList getBaseCodeSubSet(CoviMap params) throws Exception {
		CoviList resultList	= null;
		CoviList list	= coviMapperOne.list("account.common.getBaseCodeSubSet", params);
		resultList		= convertToJSON(list);
		return resultList; 
	}
	
	/**
	 * @Method getBaseGrpCodeCombo List Search
	 * @작성자 Covision
	 * @작성일 2018. 5. 8.
	 * @param params
	 * @throws Exception
	 */
	@Override
	public CoviList getBaseGrpCodeCombo(CoviMap params) throws Exception {
		CoviList resultList	= null;
		CoviList list	= coviMapperOne.list("account.common.getBaseGrpCodeCombo", params);
		resultList		= convertToJSON(list);
		return resultList; 
	}
	
	private CoviList convertToJSON(CoviList clist) {
		CoviList returnArray = new CoviList();
		
		if(null != clist && !clist.isEmpty()){
				for(int i=0; i<clist.size(); i++){
					
					CoviMap newObject = new CoviMap();
					
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();
					
					while(iter.hasNext()){   
						String ar = iter.next();
						newObject.put(ar, clist.getMap(i).getString(ar));
					}
					
					returnArray.add(newObject);
				}
			}
		
		return returnArray;
	}
	

	@Override
	public CoviMap getBankCodeList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page			= null;
		
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		int cnt = (int)coviMapperOne.getNumber("account.common.selectBaseCodeListCnt", params);
		
		page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("account.common.selectBaseCodeList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "BaseCodeID,Code,CodeName"));
		resultList.put("page", page);
		return resultList;
	}
	
	/**
	 * @Method getAccountCommonPopupList List Search
	 * @작성자 Covision
	 * @작성일 2018. 5. 8.
	 * @param params
	 * @throws Exception
	 */
	@Override
	public CoviMap getAccountCommonPopupList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		String paramTxt		= params.get("paramTxt").toString();
		String popupName	= params.get("popupName").toString();
		String pageing		= params.get("pageing").toString();
		String sqlStr		= "";
		
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		if(!popupName.equals("")){
			if(!paramTxt.equals("")){
				String[] arr = paramTxt.split(",");
				for(int i=0; i<arr.length;i++){
					String nowArr = arr[i];
					int lengthChk = nowArr.indexOf(":") + 1;
					if(nowArr.length() > lengthChk){
						String[] info = nowArr.split(":");
						params.put(info[0], info[1]);	
					}
				}
			}
			
			sqlStr	= "account.common.get" + popupName;
			if(pageing.equals("Y")){
				int cnt			= 0;
				int pageNo		= Integer.parseInt(params.get("pageNo").toString());
				int pageSize	= Integer.parseInt(params.get("pageSize").toString());
				int pageOffset	= (pageNo - 1) * pageSize;
				
				params.put("pageNo",		pageNo);
				params.put("pageSize",		pageSize);
				params.put("pageOffset",	pageOffset);
				
				cnt		= (int) coviMapperOne.getNumber(sqlStr+"Cnt" , params);
				CoviMap page	= accountUtil.listPageCount(cnt,params);
				resultList.put("page",	page);
			}
			
			CoviList list	= coviMapperOne.list(sqlStr,params);
			resultList.put("list",	AccountUtil.convertNullToSpace(list));
			
		}
		return resultList; 
	}
	
	@Override
	public CoviMap getVendorPopupList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();

		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		int cnt = (int)coviMapperOne.getNumber("account.common.selectVendorPopupListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("account.common.selectVendorPopupList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "VendorID,VendorNo,CorporateNo,VendorName,BankName,PaymentConditionName,BankAccountNo,VendorTypeName,BusinessNumber"));
		resultList.put("page", page);
		return resultList;
	}
	
	
	/**
	 * @Method getCopyPopupList
	 * @작성자 Covision
	 * @작성일 2018. 5. 8.
	 * @param params
	 * @throws Exception
	 * 전표복사 팝업
	 */
	@Override
	public CoviMap getCopyPopupList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();

		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		int cnt = (int)coviMapperOne.getNumber("account.common.selectCopyPopupListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("account.common.selectCopyPopupList", params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);
		return resultList;
	}

	@Override
	public CoviMap getBaseCodeSearchCommPopupList(CoviMap params) throws Exception {
		boolean interfaceTF		= true;
		CoviMap interfaceParam	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		CoviMap page			= null;
		CoviList list			= new CoviList();

		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;

		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		String searchProperty = "";
		if(rtString(params.get("codeGroup")).equals("IOCode")){
			//searchProperty = accountUtil.getPropertyInfo("account.searchType.IOPopup");
			searchProperty = accountUtil.getBaseCodeInfo("eAccSearchType", "IOPopup");
		}
		
		switch (searchProperty) {
			case "DB":
				//searchProperty이 DB인 경우 이곳에 정의
				break;
	
			case "SOAP":
				//searchProperty이 SOAP인 경우 이곳에 정의
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
					String i_aufnr	= "";
					String i_auart	= "";
					String i_ktext	= "";
	
					CoviMap setValues = new CoviMap();
					
					setValues.put("PERNR",		pernr);
					setValues.put("LOGID",		logid);
					setValues.put("ENAME",		ename);
					setValues.put("BUKRS",		bukrs);
					setValues.put("SCRNO",		scrno);
					setValues.put("NO_MASK",	no_mask);
					setValues.put("SPRAS",		spras);
					setValues.put("I_AUFNR",	i_aufnr);
					setValues.put("I_AUART",	i_auart);
					setValues.put("I_KTEXT",	i_ktext);
	
					ArrayList getValues = new ArrayList();
					//getValues.add("get1");
					//getValues.add("get2");
					//getValues.add("get3");
					interfaceParam.put("mapFunctionName",	"getSapMap");
					interfaceParam.put("tableName",			"");
					interfaceParam.put("sapFunctionName",	"ZFI_IF_F6001_SEND");
					interfaceParam.put("setValues",			setValues);
					interfaceParam.put("getValues",			getValues);
				break;
				
			default:
				//일반 DB조회
				cnt		= (int) coviMapperOne.getNumber("account.common.selectBaseCodeListCnt", params);		
				
				page 	= ComUtils.setPagingData(params,cnt);
				params.addAll(page);
				
				list	= coviMapperOne.list("account.common.selectBaseCodeList",params);
				interfaceTF = false;
				break;
		}
		
		if(interfaceTF){
			
			interfaceParam.put("interFaceType",			searchProperty);
			interfaceParam.put("daoClassName",			"BaseCodeDao");
			interfaceParam.put("voClassName",			"BaseCodeVO");
			interfaceParam.put("mapClassName",			"BaseCodeMap");

			interfaceParam.put("daoSetFunctionName",	"setBaseCodeList");
			interfaceParam.put("daoGetFunctionName",	"getBaseCodeList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			BaseCodeVO baseCodeVO = null;
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
			
			ArrayList arrayList = (ArrayList) getInterface.get("list");
			for (int i = 0; i < arrayList.size(); i++) {
				CoviMap listInfo = new CoviMap();
				
				baseCodeVO = (BaseCodeVO) arrayList.get(i);
				String totalCount		= baseCodeVO.getTotal();
				
				String baseCodeID		= baseCodeVO.getBaseCodeID();
				String codeGroup		= baseCodeVO.getCodeGroup();
				String code				= baseCodeVO.getCode();
				String codeName			= baseCodeVO.getCodeName();
				String isGroup			= baseCodeVO.getIsGroup();
				String isUse			= baseCodeVO.getIsUse();
				String sortKey			= baseCodeVO.getSortKey();
				String description		= baseCodeVO.getDescription();
				String reserved1		= baseCodeVO.getReserved1();
				String reserved2		= baseCodeVO.getReserved2();
				String reserved3		= baseCodeVO.getReserved3();
				String reserved4		= baseCodeVO.getReserved4();
				String reservedInt		= baseCodeVO.getReservedInt();
				String reservedFloat	= baseCodeVO.getReservedFloat();
				String isSync			= baseCodeVO.getIsSync();
				String registerID		= baseCodeVO.getRegisterID();
				String registDate		= baseCodeVO.getRegistDate();
				String modifierID		= baseCodeVO.getModifierID();
				String modifyDate		= baseCodeVO.getModifyDate();
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				cnt = Integer.parseInt(totalCount);
				
				listInfo.put("BaseCodeID",		baseCodeID);
				listInfo.put("CodeGroup",		codeGroup);
				listInfo.put("Code",			code);
				listInfo.put("CodeName",		codeName);
				listInfo.put("IsGroup",			isGroup);
				listInfo.put("IsUse",			isUse);
				listInfo.put("SortKey",			sortKey);
				listInfo.put("Description",		description);
				listInfo.put("Reserved1",		reserved1);
				listInfo.put("Reserved2",		reserved2);
				listInfo.put("Reserved3",		reserved3);
				listInfo.put("Reserved4",		reserved4);
				listInfo.put("ReservedInt",		reservedInt);
				listInfo.put("ReservedFloat",	reservedFloat);
				listInfo.put("IsSync",			isSync);
				listInfo.put("RegisterID",		registerID);
				listInfo.put("RegistDate",		registDate);
				listInfo.put("ModifierID",		modifierID);
				listInfo.put("ModifyDate",		modifyDate);
				
				list.add(listInfo);
			}
		}
		
		page	= accountUtil.listPageCount(cnt, params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);
		
		return resultList;
		
	}

	@Override
	public CoviMap getCashBillPopupList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("account.common.selectCashBillList", params);
		int cnt = (int)coviMapperOne.getNumber("account.common.selectCashBillListCnt", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "NTSConfirmNum,TradeDT,TradeType,SupplyCost,Tax,ServiceFree,TotalAmount,FranchiseCorpName,CashBillID"));
		resultList.put("cnt", cnt);
		return resultList;
	}

	@Override
	public CoviMap getLeftMenuList(CoviMap params) throws Exception {
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		CoviList list = coviMapperOne.list("account.common.getLeftMenuList", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		
		return resultList;
	}
	

	@Override
	public CoviMap getExpAppDocList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		int cnt = (int)coviMapperOne.getNumber("account.common.getExpAppDocListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
				
		CoviList list = coviMapperOne.list("account.common.getExpAppDocList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list
					, "ExpenceApplicationID,CompanyCode,ApplicationTitle,ApplicationType,ApplicationStatus,ApplicationTypeName,ApplicationStatusName,RegisterID"));
		resultList.put("page", page);
		return resultList;
	}

	/**
	 * @Method Name : getCorpCardAndReceiptList
	 * @작성일 : 2019. 11. 28.
	 * @작성자 : Covision
	 * @변경이력 : 
	 * @Method : 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getCorpCardAndReceiptList(CoviMap params) throws Exception {
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
		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));
		String searchType = rtString(params.get("searchProperty"));
		
		switch (searchType) {
			case "DB":
				//searchType이 DB인 경우 이곳에 정의
				break;
	
			case "SOAP":
				//searchType이 SOAP인 경우 이곳에 정의
				break;
				
			case "SAP":
				//searchType이 sap인 경우 이곳에 정의
				break;
				
			default :
				cnt		= (int) coviMapperOne.getNumber("account.common.getCorpCardAndReceiptListCnt", params);
				
				page 	= ComUtils.setPagingData(params,cnt);
				params.addAll(page);
				
				list	= coviMapperOne.list("account.common.getCorpCardAndReceiptList",params);
				break;
		}
		
		//page	= accountUtil.listPageCount(cnt, params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);

		return resultList;
	}
	
	/**
	 * 관리자정보 조회
	 */
	@Override
	public boolean getManagerCk() throws Exception {
		CoviMap params = new CoviMap();
		params.put("SessionUser",  SessionHelper.getSession("UR_Code"));
		int cnt = (int)coviMapperOne.getNumber("account.common.getManagerCk", params);
		return (cnt>0);
	}
	/**
	 * @Method getAccountCommonPopupList List Search
	 * @작성자 Covision
	 * @작성일 2018. 5. 8.
	 * @param params
	 * @throws Exception
	 */
	@Override
	public CoviMap getMobileReceipt(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		// storage정보에서 조회하도록 변경 
		//String filePath = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "EAccount/"; 
		// params.put("fileSavePath", filePath);
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));

//	    String iPAddress = ClientInfoHelper.getClntIP(request);
//		String filePath = FileUtil.BACK_PATH + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "EAccount/" + savedFileName.substring(0,8);
		
		CoviList list	= coviMapperOne.list("account.common.selectMobileReceipt",params);
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		
		return resultList; 
	}

	@Override
	public CoviMap getPrivateCardPopupList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		int cnt = (int)coviMapperOne.getNumber("account.common.selectPrivateCardPopupListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);

		CoviList list = coviMapperOne.list("account.common.selectPrivateCardPopupList", params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);
		return resultList;
	}

	/**
	 * @Method Name : getAccountSearchPopupList
	 * @작성일 : 2018. 8. 2.
	 * @작성자 : Covision
	 * @변경이력 : 
	 * @Method : 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getAccountSearchPopupList(CoviMap params) throws Exception {
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
		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));
		
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
					String amSearchTypePop	= rtString(params.get("amSearchTypePop"));
					String searchStr		= rtString(params.get("searchStr"));
					
					CoviMap xmlParam = new CoviMap();
					
					xmlParam.put("pPageSize",		pageSize);
					xmlParam.put("pPageCurrent",	pageNo);
					xmlParam.put("pSortKey",		pSortKey);
					xmlParam.put("pOrder",			pOrder);
					xmlParam.put("pAccountClass",	"");
					
					if(amSearchTypePop.equals("GLCP")){
						xmlParam.put("pAccountCode",	searchStr);
						xmlParam.put("pAccountName",	"");
					}
					
					if(amSearchTypePop.equals("GLNP")){
						xmlParam.put("pAccountCode",	"");
						xmlParam.put("pAccountName",	searchStr);
					}
					
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
					String i_saknr	= "";
					String i_txt20	= "";
	
					if(rtString(params.get("amSearchTypePop")).equals("GLCP")){
						i_saknr = rtString(params.get("searchStr"));
					}
					
					if(rtString(params.get("amSearchTypePop")).equals("GLNP")){
						i_txt20 = rtString(params.get("searchStr"));
					}
					
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
				cnt		= (int) coviMapperOne.getNumber("account.common.getAccountSearchPopupCnt", params);
				
				page 	= ComUtils.setPagingData(params,cnt);
				params.addAll(page);
				
				list	= coviMapperOne.list("account.common.getAccountSearchPopup",params);
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
					if(registDate.indexOf("T") > 0){
						registDate = registDate.substring(0,registDate.indexOf("T"));
					}
					registDate = registDate.replaceAll("[^0-9]", ".");
				}
				
				cnt = Integer.parseInt(totalCount);
				
				listInfo.put("AccountID",			accountCode);
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
		
		//page	= accountUtil.listPageCount(cnt, params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);

		return resultList;
	}

	/**
	 * @Method Name : getFavoriteAccountSearchPopupList
	 * @작성일 : 2018. 8. 6.
	 * @작성자 : Covision
	 * @변경이력 : 
	 * @Method : 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getFavoriteAccountSearchPopupList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();

		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;

		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));

		//일반 DB조회
		cnt		= (int) coviMapperOne.getNumber("account.common.getFavoriteAccountSearchPopupCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.common.getFavoriteAccountSearchPopup",params);
		
		//page	= accountUtil.listPageCount(cnt, params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);

		return resultList;
	}
	@Override
	public int setFavoriteAccountSearchPopupList(CoviMap params) throws Exception {
		int cnt = 0;

		CoviList checkList = (CoviList) AccountUtil.jobjGetObj(params,"checkList");
		String updateType = AccountUtil.jobjGetStr(params,"updateType");
		if(checkList != null) {
			for(int i=0; i<checkList.size(); i++){
				CoviMap item = checkList.getJSONObject(i);
				item.put("UR_Code",		SessionHelper.getSession("UR_Code"));
				if("A".equals(updateType)){
					int ckCnt = (int)(long)coviMapperOne.selectOne("account.common.ckFavoriteAccountSearchPopupList", item);
					if(ckCnt == 0){
						cnt = coviMapperOne.insert("account.common.insertFavoriteAccountSearchPopupList", item);
					}
				}else if("D".equals(updateType)){
					cnt = coviMapperOne.delete("account.common.deleteFavoriteAccountSearchPopupList", item);
				}
			}
		}
		return cnt;
	}
	
	
	
	
	/**
	 * @Method Name : getCardReceiptPopupInfo
	 * @작성일 : 2018. 8. 2.
	 * @작성자 : Covision
	 * @변경이력 : 
	 * @Method : 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getCardReceiptPopupInfo(CoviMap params) throws Exception {
		boolean interfaceTF		= true;
		CoviMap interfaceParam	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		CoviList list			= new CoviList();
		
		String searchType = rtString(params.get("searchProperty"));
		
		switch (searchType) {
			case "DB":
				//searchType이 DB인 경우 이곳에 정의
				break;
	
			case "SOAP":
				//searchType이 SOAP인 경우 이곳에 정의

				interfaceParam.put("mapFunctionName",	"getSoapMap");
				interfaceParam.put("soapName",			"XpenseGetCardReceiptList");
				interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetCardReceiptList");
				
				String approveNo	= rtString(params.get("approveNo"));
				
				CoviMap xmlParam = new CoviMap();
				xmlParam.put("pPageSize",			1);
				xmlParam.put("pPageCurrent",		1);
				xmlParam.put("pExceptApprovalNo",	approveNo);
				interfaceParam.put("xmlParam", xmlParam);
				
				break;
				
			case "SAP":
				//searchType이 SAP인 경우 이곳에 정의
					String pernr		= "";
					String logid		= "";
					String ename		= "";
					String bukrs		= "";
					String scrno		= "";
					String no_mask		= "";
					String spras		= "";
					String i_sdate		= "";
					String i_edate		= "";
					String i_gubun		= "";
					String i_gubun2		= "";
					String i_perenr		= "";
					String i_cardno		= "";
					String i_merchname	= "";
	
					CoviMap setValues = new CoviMap();
					
					setValues.put("PERNR",			pernr);
					setValues.put("LOGID",			logid);
					setValues.put("ENAME",			ename);
					setValues.put("BUKRS",			bukrs);
					setValues.put("SCRNO",			scrno);
					setValues.put("NO_MASK",		no_mask);
					setValues.put("SPRAS",			spras);
					setValues.put("I_SDATE",		i_sdate);
					setValues.put("I_EDATE",		i_edate);
					setValues.put("I_GUBUN",		i_gubun);
					setValues.put("I_GUBUN2",		i_gubun2);
					setValues.put("I_PERENR",		i_perenr);
					setValues.put("I_CARDNO",		i_cardno);
					setValues.put("I_MERCHNAME",	i_merchname);
	
					ArrayList getValues = new ArrayList();
					//getValues.add("get1");
					//getValues.add("get2");
					//getValues.add("get3");
					interfaceParam.put("mapFunctionName",	"getSapMap");
					interfaceParam.put("tableName",			"");
					interfaceParam.put("sapFunctionName",	"ZFI_IF_F7001_SEND");
					interfaceParam.put("setValues",			setValues);
					interfaceParam.put("getValues",			getValues);
				break;
				
			default :
				list	= coviMapperOne.list("account.common.getCardReceiptPopup",params);
				interfaceTF = false;
				break;
		}
		
		if(interfaceTF){
			
			interfaceParam.put("interFaceType",			searchType);
			
			interfaceParam.put("daoClassName",			"CardReceiptDao");
			interfaceParam.put("voClassName",			"CardReceiptVO");
			interfaceParam.put("mapClassName",			"CardReceiptMap");

			interfaceParam.put("daoSetFunctionName",	"setCardReceiptList");
			interfaceParam.put("daoGetFunctionName",	"getCardReceiptList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			CardReceiptVO cardReceiptVO = null;
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);

			ArrayList arrayList = (ArrayList) getInterface.get("list");
			for (int i = 0; i < arrayList.size(); i++) {
				CoviMap listInfo = new CoviMap();
				
				cardReceiptVO = (CardReceiptVO) arrayList.get(i);
				
				String receiptID			= cardReceiptVO.getReceiptID();
				
				if(receiptID.equals("")){
					continue;
				}
				
				String cardNo				= cardReceiptVO.getCardNo();	
				String amountWon			= cardReceiptVO.getAmountWon();	
				String infoIndexName		= cardReceiptVO.getInfoIndex();
				String storeAddress1		= cardReceiptVO.getStoreAddress1();
				String storeAddress2		= cardReceiptVO.getStoreAddress2();
				String approveNo			= cardReceiptVO.getApproveNo();
				String useDate				= cardReceiptVO.getUseDate();
				String storeName			= cardReceiptVO.getStoreName();	
				String storeNo				= cardReceiptVO.getStoreNo();	
				String storeRepresentative	= cardReceiptVO.getStoreRepresentative();	
				String storeRegNo			= cardReceiptVO.getStoreRegNo();	
				String storeTel				= cardReceiptVO.getStoreTel();	
				String repAmount			= cardReceiptVO.getRepAmount();	
				String taxAmount			= cardReceiptVO.getTaxAmount();	
				String serviceAmount		= cardReceiptVO.getServiceAmount();	
				//데이터 구조가 다른 관계로  임시로 셋팅
				
				amountWon		= amountWon.substring(0, amountWon.indexOf("."));
				repAmount		= repAmount.substring(0, repAmount.indexOf("."));
				taxAmount		= taxAmount.substring(0, taxAmount.indexOf("."));
				serviceAmount	= serviceAmount.substring(0, serviceAmount.indexOf("."));
				cardNo			= cardNo.replaceAll("[^0-9]", "");
				
				listInfo.put("CardNo",				cardNo);
				listInfo.put("AmountWon",			amountWon);
				listInfo.put("InfoIndexName",		infoIndexName);
				listInfo.put("StoreAddress1",		storeAddress1);
				listInfo.put("StoreAddress2",		storeAddress2);
				listInfo.put("ApproveNo",			approveNo);
				listInfo.put("UseDate",				useDate);
				listInfo.put("UseTime",				""); //TODO: InterFace 연동 사용 시 UseTime(ApproveTime) 컬럼 추가 필요
				listInfo.put("StoreName",			storeName);
				listInfo.put("StoreNo",				storeNo);
				listInfo.put("StoreRepresentative",	storeRepresentative);
				listInfo.put("StoreRegNo",			storeRegNo);
				listInfo.put("StoreTel",			storeTel);
				listInfo.put("RepAmount",			repAmount);
				listInfo.put("TaxAmount",			taxAmount);
				listInfo.put("ServiceAmount",		serviceAmount);
				
				list.add(listInfo);
			}
		}
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));

		return resultList;
	}
	
	/**
	 * @Method Name : getCardReceiptSearchPopupList
	 * @작성일 : 2018. 8. 2.
	 * @작성자 : Covision
	 * @변경이력 : 
	 * @Method : 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getCardReceiptSearchPopupList(CoviMap params) throws Exception {
		boolean interfaceTF		= true;
		CoviMap interfaceParam	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();

		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		String strUR_Code;
		strUR_Code	= (params.get("UR_Code") == null || "".equals(params.get("UR_Code")))?SessionHelper.getSession("UR_Code"):params.get("UR_Code").toString();
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		params.put("UR_Code",		strUR_Code);
		String searchType = rtString(params.get("searchProperty"));
		
		switch (searchType) {
			case "DB":
				//searchType이 DB인 경우 이곳에 정의
				break;
	
			case "SOAP":
				//searchType이 SOAP인 경우 이곳에 정의

				interfaceParam.put("mapFunctionName",	"getSoapMap");
				interfaceParam.put("soapName",			"XpenseGetCardReceiptList");
				interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetCardReceiptList");
				
				String pApproveDateS	= rtString(params.get("approveDateS"));
				String pApproveDateE	= rtString(params.get("approveDateE"));
				String pCardNo			= rtString(params.get("cardNo"));
				String pApproveNo		= rtString(params.get("approveNo"));
				String pCardUserCode	= rtString(params.get("UR_Code"));
				
				pApproveDateS = pApproveDateS.replaceAll("[^0-9]", "-");
				pApproveDateE = pApproveDateE.replaceAll("[^0-9]", "-");
				
				CoviMap xmlParam = new CoviMap();
				xmlParam.put("pPageSize",			pageSize);
				xmlParam.put("pPageCurrent",		pageNo);
				
				if(!pApproveDateS.equals("")){	xmlParam.put("pSDate",		pApproveDateS);}
				if(!pApproveDateE.equals("")){	xmlParam.put("pEDate",		pApproveDateE);}
				if(!pCardUserCode.equals("")){	xmlParam.put("pCarduser",	pCardUserCode);}
				if(!pCardNo.equals("")){		xmlParam.put("pCardNo",		pCardNo);}
				if(!pCardNo.equals("")){		xmlParam.put("pApproveNo",	pApproveNo);}
				
				interfaceParam.put("xmlParam",		xmlParam);
				
				break;
				
			case "SAP":
				//searchType이 sap인 경우 이곳에 정의
					String pernr		= "";
					String logid		= "";
					String ename		= "";
					String bukrs		= "";
					String scrno		= "";
					String no_mask		= "";
					String spras		= "";
					String i_sdate		= "";
					String i_edate		= "";
					String i_gubun		= "";
					String i_gubun2		= "";
					String i_perenr		= "";
					String i_cardno		= "";
					String i_approveno	= "";
					String i_merchname	= "";
	
					CoviMap setValues = new CoviMap();
					
					setValues.put("PERNR",			pernr);
					setValues.put("LOGID",			logid);
					setValues.put("ENAME",			ename);
					setValues.put("BUKRS",			bukrs);
					setValues.put("SCRNO",			scrno);
					setValues.put("NO_MASK",		no_mask);
					setValues.put("SPRAS",			spras);
					setValues.put("I_SDATE",		i_sdate);
					setValues.put("I_EDATE",		i_edate);
					setValues.put("I_GUBUN",		i_gubun);
					setValues.put("I_GUBUN2",		i_gubun2);
					setValues.put("I_PERENR",		i_perenr);
					setValues.put("I_CARDNO",		i_cardno);
					setValues.put("I_APPROVENO",	i_approveno);
					setValues.put("I_MERCHNAME",	i_merchname);
	
					ArrayList getValues = new ArrayList();
					//getValues.add("get1");
					//getValues.add("get2");
					//getValues.add("get3");
					interfaceParam.put("mapFunctionName",	"getSapMap");
					interfaceParam.put("tableName",			"");
					interfaceParam.put("sapFunctionName",	"ZFI_IF_F7001_SEND");
					interfaceParam.put("setValues",			setValues);
					interfaceParam.put("getValues",			getValues);
				break;
				
			default :
				cnt		= (int) coviMapperOne.getNumber("account.common.getCardReceiptSearchPopupCnt", params);
				
				page 	= ComUtils.setPagingData(params,cnt);
				params.addAll(page);
				
				list	= coviMapperOne.list("account.common.getCardReceiptSearchPopup",params);
				interfaceTF = false;
				break;
		}
		
		if(interfaceTF){

			interfaceParam.put("interFaceType",			searchType);
			
			interfaceParam.put("daoClassName",			"CardReceiptDao");
			interfaceParam.put("voClassName",			"CardReceiptVO");
			interfaceParam.put("mapClassName",			"CardReceiptMap");

			interfaceParam.put("daoSetFunctionName",	"setCardReceiptList");
			interfaceParam.put("daoGetFunctionName",	"getCardReceiptList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			CardReceiptVO cardReceiptVO = null;
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);

			ArrayList arrayList = (ArrayList) getInterface.get("list");
			for (int i = 0; i < arrayList.size(); i++) {
				CoviMap listInfo = new CoviMap();
				
				cardReceiptVO = (CardReceiptVO) arrayList.get(i);
				
				String totalCount			= cardReceiptVO.getTotalCount();
				String receiptID			= cardReceiptVO.getReceiptID();
				String approveStatus		= cardReceiptVO.getApproveStatus();
				String dataIndex			= cardReceiptVO.getDataIndex();
				String sendDate				= cardReceiptVO.getSendDate();
				String itemNo				= cardReceiptVO.getItemNo();
				String cardNo				= cardReceiptVO.getCardNo();
				String infoIndex			= cardReceiptVO.getInfoIndex();
				String infoType				= cardReceiptVO.getInfoType();
				String cardCompIndex		= cardReceiptVO.getCardCompIndex();
				String cardRegType			= cardReceiptVO.getCardRegType();
				String cardType				= cardReceiptVO.getCardType();
				String bizPlaceNo			= cardReceiptVO.getBizPlaceNo();
				String dept					= cardReceiptVO.getDept();
				String cardUserCode			= cardReceiptVO.getCardUserCode();
				String useDate				= cardReceiptVO.getUseDate();
				String approveDate			= cardReceiptVO.getApproveDate();
				String approveTime			= cardReceiptVO.getApproveTime();
				String approveNo			= cardReceiptVO.getApproveNo();
				String withdrawDate			= cardReceiptVO.getWithdrawDate();
				String countryIndex			= cardReceiptVO.getCountryIndex();
				String amountSign			= cardReceiptVO.getAmountSign();
				String amountWon			= cardReceiptVO.getAmountWon();
				String foreignCurrency		= cardReceiptVO.getForeignCurrency();
				String amountForeign		= cardReceiptVO.getAmountForeign();
				String storeRegNo			= cardReceiptVO.getStoreRegNo();
				String storeName			= cardReceiptVO.getStoreName();
				String storeNo				= cardReceiptVO.getStoreNo();
				String storeRepresentative	= cardReceiptVO.getStoreRepresentative();
				String storeCondition		= cardReceiptVO.getStoreCondition();
				String storeCategory		= cardReceiptVO.getStoreCategory();
				String storeZipCode			= cardReceiptVO.getStoreZipCode();
				String storeAddress1		= cardReceiptVO.getStoreAddress1();
				String storeAddress2		= cardReceiptVO.getStoreAddress2();
				String storeTel				= cardReceiptVO.getStoreTel();
				String repAmount			= cardReceiptVO.getRepAmount();
				String taxAmount			= cardReceiptVO.getTaxAmount();
				String serviceAmount		= cardReceiptVO.getServiceAmount();
				String active				= cardReceiptVO.getActive();
				String intDate				= cardReceiptVO.getIntDate();
				String collNo				= cardReceiptVO.getCollNo();
				String taxType				= cardReceiptVO.getTaxType();
				String taxTypeDate			= cardReceiptVO.getTaxTypeDate();
				String merchCessDate		= cardReceiptVO.getMerchCessDate();
				String class1				= cardReceiptVO.getClass1();
				String tossUserCode			= cardReceiptVO.getTossUserCode();
				String tossSenderUserCode	= cardReceiptVO.getTossSenderUserCode();
				String tossDate				= cardReceiptVO.getTossDate();
				String tossComment			= cardReceiptVO.getTossComment();
				String isPersonalUse		= cardReceiptVO.getIsPersonalUse();
				//데이터 구조가 다른 관계로  임시로 셋팅
				
				if(receiptID.equals("")){
					continue;
				}
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				cardNo		= cardNo.replaceAll("[^0-9]", "");
				approveDate	= approveDate.replaceAll("[^0-9]",	".");
				amountWon	= amountWon.substring(0, amountWon.indexOf("."));
				repAmount	= repAmount.substring(0, repAmount.indexOf("."));
				taxAmount	= taxAmount.substring(0, taxAmount.indexOf("."));
				
				if(searchType.equals("SOAP")){
					active		= "N";
					infoIndex	= "A";
				}
				
				cnt = Integer.parseInt(totalCount);
				
				listInfo.put("ReceiptID",			receiptID);
				listInfo.put("ApproveStatus",		approveStatus);
				listInfo.put("DataIndex",			dataIndex);
				listInfo.put("SendDate",			sendDate);
				listInfo.put("ItemNo",				itemNo);
				listInfo.put("CardNo",				cardNo);
				listInfo.put("InfoIndex",			infoIndex);
				listInfo.put("InfoType",			infoType);
				listInfo.put("CardCompIndex",		cardCompIndex);
				listInfo.put("CardRegType",			cardRegType);
				listInfo.put("CardType",			cardType);
				listInfo.put("BizPlaceNo",			bizPlaceNo);
				listInfo.put("Dept",				dept);
				listInfo.put("CardUserCode",		cardUserCode);
				listInfo.put("UseDate",				useDate);
				listInfo.put("ApproveDate",			approveDate);
				listInfo.put("ApproveTime",			approveTime);
				listInfo.put("ApproveNo",			approveNo);
				listInfo.put("WithdrawDate",		withdrawDate);
				listInfo.put("CountryIndex",		countryIndex);
				listInfo.put("AmountSign",			amountSign);
				listInfo.put("AmountWon",			amountWon);
				listInfo.put("ForeignCurrency",		foreignCurrency);
				listInfo.put("AmountForeign",		amountForeign);
				listInfo.put("StoreRegNo",			storeRegNo);
				listInfo.put("StoreName",			storeName);
				listInfo.put("StoreNo",				storeNo);
				listInfo.put("StoreRepresentative",	storeRepresentative);
				listInfo.put("StoreCondition",		storeCondition);
				listInfo.put("StoreCategory",		storeCategory);
				listInfo.put("StoreZipCode",		storeZipCode);
				listInfo.put("StoreAddress1",		storeAddress1);
				listInfo.put("StoreAddress2",		storeAddress2);
				listInfo.put("StoreTel",			storeTel);
				listInfo.put("RepAmount",			repAmount);
				listInfo.put("TaxAmount",			taxAmount);
				listInfo.put("ServiceAmount",		serviceAmount);
				listInfo.put("Active",				active);
				listInfo.put("IntDate",				intDate);
				listInfo.put("CollNo",				collNo);
				listInfo.put("TaxType",				taxType);
				listInfo.put("TaxTypeDate",			taxTypeDate);
				listInfo.put("MerchCessDate",		merchCessDate);
				listInfo.put("Class",				class1);
				listInfo.put("TossUserCode",		tossUserCode);
				listInfo.put("TossSenderUserCode",	tossSenderUserCode);
				listInfo.put("TossDate",			tossDate);
				listInfo.put("TossComment",			tossComment);
				listInfo.put("IsPersonalUse",		isPersonalUse);

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
	 * @Method Name : getCostCenterSearchPopupList
	 * @작성일 : 2018. 8. 2.
	 * @작성자 : Covision
	 * @변경이력 : 
	 * @Method : 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getCostCenterSearchPopupList(CoviMap params) throws Exception {
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
					String soapCostCenterName	= rtString(params.get("soapCostCenterName"));
					
					CoviMap xmlParam = new CoviMap();
					
					xmlParam.put("pPageSize",		pageSize);
				    xmlParam.put("pPageCurrent",	pageNo);
				    xmlParam.put("pSortKey",		pSortKey);
				    xmlParam.put("pOrder",			pOrder);
				    xmlParam.put("pCCGubun",		(params.get("popupType").equals("IO") ? "PROJECT" : ""));
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
				cnt		= (int) coviMapperOne.getNumber("account.common.getCostCenterSearchPopupCnt", params);		
				
				page 	= ComUtils.setPagingData(params,cnt);
				params.addAll(page);
				
				list	= coviMapperOne.list("account.common.getCostCenterSearchPopup",params);
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
	 * @Method Name : getFavoriteCCSearchPopupList
	 * @작성일 : 2018. 8. 6.
	 * @작성자 : Covision
	 * @변경이력 : 
	 * @Method : 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getFavoriteCCSearchPopupList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();

		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;

		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));

		//일반 DB조회
		cnt		= (int) coviMapperOne.getNumber("account.common.getFavoriteCCSearchPopupCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.common.getFavoriteCCSearchPopup",params);
		
		//page	= accountUtil.listPageCount(cnt, params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);

		return resultList;
	}
	@Override
	public int setFavoriteCCSearchPopupList(CoviMap params) throws Exception {
		int cnt = 0;

		CoviList checkList = (CoviList) AccountUtil.jobjGetObj(params,"checkList");
		String updateType = AccountUtil.jobjGetStr(params,"updateType");
		if(checkList != null) {
			for(int i=0; i<checkList.size(); i++){
				CoviMap item = checkList.getJSONObject(i);
				item.put("UR_Code",		SessionHelper.getSession("UR_Code"));
				if("A".equals(updateType)){
					int ckCnt = (int)(long)coviMapperOne.selectOne("account.common.ckFavoriteCCSearchPopupList", item);
					if(ckCnt == 0){
						cnt = coviMapperOne.insert("account.common.insertFavoriteCCSearchPopupList", item);
					}
				}else if("D".equals(updateType)){
					cnt = coviMapperOne.delete("account.common.deleteFavoriteCCSearchPopupList", item);
				}
			}
		}
		return cnt;
	}
	/**
	 * @Method Name : getStandardBriefSearchPopupList
	 * @작성일 : 2018. 8. 2.
	 * @작성자 : Covision
	 * @변경이력 : 
	 * @Method : 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getStandardBriefSearchPopupList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();

		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;

		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		cnt		= (int) coviMapperOne.getNumber("account.common.getStandardBriefSearchPopupCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);	
		
		CoviList list	= coviMapperOne.list("account.common.getStandardBriefSearchPopup",params);
		
		//page	= accountUtil.listPageCount(cnt, params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);

		return resultList;
	}
	


	/**
	 * @Method Name : getFavoriteStandardBriefSearchPopupList
	 * @작성일 : 2018. 8. 6.
	 * @작성자 : Covision
	 * @변경이력 : 
	 * @Method : 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getFavoriteStandardBriefSearchPopupList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();

		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;

		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));

		//일반 DB조회
		cnt		= (int) coviMapperOne.getNumber("account.common.getFavoriteStandardBriefSearchPopupCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.common.getFavoriteStandardBriefSearchPopup",params);
		
		//page	= accountUtil.listPageCount(cnt, params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);

		return resultList;
	}
	
	@Override
	public int setFavoriteStandardBriefSearchPopupList(CoviMap params) throws Exception {
		int cnt = 0;

		CoviList checkList = (CoviList) AccountUtil.jobjGetObj(params,"checkList");
		String updateType = AccountUtil.jobjGetStr(params,"updateType");
		if(checkList != null) {
			for(int i=0; i<checkList.size(); i++){
				CoviMap item = checkList.getJSONObject(i);
				item.put("UR_Code",		SessionHelper.getSession("UR_Code"));
				if("A".equals(updateType)){
					int ckCnt = (int)(long)coviMapperOne.selectOne("account.common.ckFavoriteStandardBriefSearchPopupList", item);
					if(ckCnt == 0){
						cnt = coviMapperOne.insert("account.common.insertFavoriteStandardBriefSearchPopupList", item);
					}
				}else if("D".equals(updateType)){
					cnt = coviMapperOne.delete("account.common.deleteFavoriteStandardBriefSearchPopupList", item);
				}
			}
		}
		return cnt;
	}
	
	/**
	 * @Method Name : getTaxInvoicePopupInfo
	 * @작성일 : 2018. 8. 2.
	 * @작성자 : Covision
	 * @변경이력 : 
	 * @Method : 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getTaxInvoicePopupInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list	= coviMapperOne.list("account.common.getTaxInvoicePopup",params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));

		return resultList;
	}
	
	/**
	 * @Method Name : getTaxinvoiceSearchPopupList
	 * @작성일 : 2018. 8. 2.
	 * @작성자 : Covision
	 * @변경이력 : 
	 * @Method : 
	 * @param params
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap getTaxinvoiceSearchPopupList(CoviMap params) throws Exception {
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
		params.put("SessionUser",	SessionHelper.getSession("UR_Code"));
		
		String searchProperty = rtString(params.get("searchProperty"));
		
		switch (searchProperty) {
			case "DB":
				//searchProperty이 DB인 경우 이곳에 정의
				break;
	
			case "SOAP":
				//searchProperty이 SOAP인 경우 이곳에 정의
					interfaceParam.put("mapFunctionName",	"getSoapMap");
					interfaceParam.put("soapName",			"XpenseGetTaxBillList");
					interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetTaxBillList");
					
					String pSDate	= rtString(params.get("writeDateS"));
					String pEDate	= rtString(params.get("writeDateE"));
					
					CoviMap xmlParam = new CoviMap();
					
					xmlParam.put("pPageSize",		pageSize);
					xmlParam.put("pPageCurrent",	pageNo);
					xmlParam.put("pSDate",			pSDate);
					xmlParam.put("pEDate",			pEDate);
					xmlParam.put("pVendorNo",		"");
					xmlParam.put("pVendorName",		"");
					xmlParam.put("pExistNo",		"");
					xmlParam.put("pUserID",			"");
				      
					interfaceParam.put("xmlParam", xmlParam);
				break;
				
			case "SAP":
				//searchProperty이 SAP인 경우 이곳에 정의
				break;
				
			default:
				//일반 DB조회
				cnt		= (int) coviMapperOne.getNumber("account.common.getTaxinvoiceSearchPopupCnt", params);
				
				page 	= ComUtils.setPagingData(params,cnt);
				params.addAll(page);
				
				list	= coviMapperOne.list("account.common.getTaxinvoiceSearchPopup",params);
				interfaceTF = false;
				break;
		}
		
		if(interfaceTF){
			
			interfaceParam.put("interFaceType",			searchProperty);
			interfaceParam.put("daoClassName",			"TaxInvoiceDao");
			interfaceParam.put("voClassName",			"TaxInvoiceVO");
			interfaceParam.put("mapClassName",			"TaxInvoiceMap");

			interfaceParam.put("daoSetFunctionName",	"setTaxInvoiceList");
			interfaceParam.put("daoGetFunctionName",	"getTaxInvoiceList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			TaxInvoiceVO taxInvoiceVO = null;
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
			
			ArrayList arrayList = (ArrayList) getInterface.get("list");
			for (int i = 0; i < arrayList.size(); i++) {
				CoviMap listInfo = new CoviMap();
				
				taxInvoiceVO = (TaxInvoiceVO) arrayList.get(i);

				//MAIN
				String taxInvoiceID			= taxInvoiceVO.getTaxInvoiceID();																	
				String companyCode			= taxInvoiceVO.getCompanyCode();																			
				//String dataIndex			= taxInvoiceVO.getDataIndex();																
				String writeDate			= taxInvoiceVO.getWriteDate();																
				String issueDT				= taxInvoiceVO.getIssueDT();																		
				String invoiceType			= taxInvoiceVO.getInvoiceType();																	
				String taxType				= taxInvoiceVO.getTaxType();																		
				String taxTotal				= taxInvoiceVO.getTaxTotal();																		
				String supplyCostTotal		= taxInvoiceVO.getSupplyCostTotal();																
				String totalAmount			= taxInvoiceVO.getTotalAmount();																	
				String purposeType			= taxInvoiceVO.getPurposeType();																	
				String serialNum			= taxInvoiceVO.getSerialNum();																
				String cash					= taxInvoiceVO.getCash();																			
				String chkBill				= taxInvoiceVO.getChkBill();																		
				String credit				= taxInvoiceVO.getCredit();																		
				String note					= taxInvoiceVO.getNote();																			
				String remark1				= taxInvoiceVO.getRemark1();																		
				String remark2				= taxInvoiceVO.getRemark2();																		
				String remark3				= taxInvoiceVO.getRemark3();																		
				String nTSConfirmNum		= taxInvoiceVO.getnTSConfirmNum();															
				String modifyCode			= taxInvoiceVO.getModifyCode();																	
				String orgNTSConfirmNum		= taxInvoiceVO.getOrgNTSConfirmNum();																
				String invoicerCorpNum		= taxInvoiceVO.getInvoicerCorpNum();																
				String invoicerMgtKey		= taxInvoiceVO.getInvoicerMgtKey();																
				String invoicerTaxRegID		= taxInvoiceVO.getInvoicerTaxRegID();																
				String invoicerCorpName		= taxInvoiceVO.getInvoicerCorpName();																
				String invoicerCEOName		= taxInvoiceVO.getInvoicerCEOName();																
				String invoicerAddr			= taxInvoiceVO.getInvoicerAddr();																	
				String invoicerBizType		= taxInvoiceVO.getInvoicerBizType();																
				String invoicerBizClass		= taxInvoiceVO.getInvoicerBizClass();																
				String invoicerContactName	= taxInvoiceVO.getInvoicerContactName();															
				String invoicerDeptName		= taxInvoiceVO.getInvoicerDeptName();																
				String invoicerTel			= taxInvoiceVO.getInvoicerTel();																	
				String invoicerEmail		= taxInvoiceVO.getInvoicerEmail();															
				String invoiceeCorpNum		= taxInvoiceVO.getInvoiceeCorpNum();																
				String invoiceeType			= taxInvoiceVO.getInvoiceeType();																	
				String invoiceeMgtKey		= taxInvoiceVO.getInvoiceeMgtKey();																
				String invoiceeTaxRegID		= taxInvoiceVO.getInvoiceeTaxRegID();																
				String invoiceeCorpName		= taxInvoiceVO.getInvoiceeCorpName();																
				String invoiceeCEOName		= taxInvoiceVO.getInvoiceeCEOName();																
				String invoiceeAddr			= taxInvoiceVO.getInvoiceeAddr();																	
				String invoiceeBizType		= taxInvoiceVO.getInvoiceeBizType();																
				String invoiceeBizClass		= taxInvoiceVO.getInvoiceeBizClass();																
				String invoiceeContactName1	= taxInvoiceVO.getInvoiceeContactName1();															
				String invoiceeDeptName1	= taxInvoiceVO.getInvoiceeDeptName1();														
				String invoiceeTel1			= taxInvoiceVO.getInvoiceeTel1();																	
				String invoiceeEmail1		= taxInvoiceVO.getInvoiceeEmail1();																
				String invoiceeContactName2	= taxInvoiceVO.getInvoiceeContactName2();															
				String invoiceDeptName2		= taxInvoiceVO.getInvoiceDeptName2();																
				String invoiceTel2			= taxInvoiceVO.getInvoiceTel2();																	
				String invoiceEmail2		= taxInvoiceVO.getInvoiceEmail2();															
				String trusteeCorpNum		= taxInvoiceVO.getTrusteeCorpNum();																
				String trusteeMgtKey		= taxInvoiceVO.getTrusteeMgtKey();															
				String trusteeTaxRegID		= taxInvoiceVO.getTrusteeTaxRegID();																
				String trusteeCorpName		= taxInvoiceVO.getTrusteeCorpName();																
				String trusteeCEOName		= taxInvoiceVO.getTrusteeCEOName();																
				String trusteeAddr			= taxInvoiceVO.getTrusteeAddr();																	
				String trusteeBizType		= taxInvoiceVO.getTrusteeBizType();																
				String trusteeBizClass		= taxInvoiceVO.getTrusteeBizClass();																
				String trusteeContactName	= taxInvoiceVO.getTrusteeContactName();															
				String trusteeDeptName		= taxInvoiceVO.getTrusteeDeptName();																
				String trusteeTel			= taxInvoiceVO.getTrusteeTel();																	
				String trusteeEmail			= taxInvoiceVO.getTrusteeEmail();																	
				String tossUserCode			= taxInvoiceVO.getTossUserCode();																	
				String tossSenderUserCode	= taxInvoiceVO.getTossSenderUserCode();															
				String tossDate				= taxInvoiceVO.getTossDate();																		
				String toss					= taxInvoiceVO.getToss();																			
				String registDate_main		= taxInvoiceVO.getRegistDate_main();																
				String intDate				= taxInvoiceVO.getIntDate();																		
				String isOffset				= taxInvoiceVO.getIsOffset();																		
				String cONVERSATION_ID		= taxInvoiceVO.getcONVERSATION_ID();																
				String sUPBUY_TYPE			= taxInvoiceVO.getsUPBUY_TYPE();																	
				String dIRECTION			= taxInvoiceVO.getdIRECTION();																
				String totalCount			= taxInvoiceVO.getTotal();																	
				
				if(nTSConfirmNum.equals("")){
					continue;
				}
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				//데이터 구조가 다른 관계로  임시로 셋팅
				
				cnt = Integer.parseInt(totalCount);
				
				String writeDateConvert = "";
				if(writeDate.indexOf("T") > 0){
					writeDateConvert = writeDate.substring(0,writeDate.indexOf("T"));
				}else{
					writeDateConvert = writeDate;
				}
				writeDateConvert = writeDateConvert.replaceAll("[^0-9]", "");
				
				//MAIN
				listInfo.put("TaxInvoiceID",			taxInvoiceID);
				listInfo.put("CompanyCode",				companyCode);
				listInfo.put("DataIndex",				sUPBUY_TYPE);
				listInfo.put("WriteDate",				writeDateConvert);
				listInfo.put("IssueDT",					issueDT);
				listInfo.put("InvoiceType",				invoiceType);
				listInfo.put("TaxType",					taxType);
				listInfo.put("TaxTotal",				taxTotal);
				listInfo.put("SupplyCostTotal",			supplyCostTotal);
				listInfo.put("TotalAmount",				totalAmount);
				listInfo.put("PurposeType",				purposeType);
				listInfo.put("SerialNum",				serialNum);
				listInfo.put("Cash",					cash);
				listInfo.put("ChkBill",					chkBill);
				listInfo.put("Credit",					credit);
				listInfo.put("Note",					note);
				listInfo.put("Remark1",					remark1);
				listInfo.put("Remark2",					remark2);
				listInfo.put("Remark3",					remark3);
				listInfo.put("NTSConfirmNum",			nTSConfirmNum);
				listInfo.put("ModifyCode",				modifyCode);
				listInfo.put("OrgNTSConfirmNum",		orgNTSConfirmNum);
				listInfo.put("InvoicerCorpNum",			invoicerCorpNum);
				listInfo.put("InvoicerMgtKey",			invoicerMgtKey);
				listInfo.put("InvoicerTaxRegID",		invoicerTaxRegID);
				listInfo.put("InvoicerCorpName",		invoicerCorpName);
				listInfo.put("InvoicerCEOName",			invoicerCEOName);
				listInfo.put("InvoicerAddr",			invoicerAddr);
				listInfo.put("InvoicerBizType",			invoicerBizType);
				listInfo.put("InvoicerBizClass",		invoicerBizClass);
				listInfo.put("InvoicerContactName",		invoicerContactName);
				listInfo.put("InvoicerDeptName",		invoicerDeptName);
				listInfo.put("InvoicerTel",				invoicerTel);
				listInfo.put("InvoicerEmail",			invoicerEmail);
				listInfo.put("InvoiceeCorpNum",			invoiceeCorpNum);
				listInfo.put("InvoiceeType",			invoiceeType);
				listInfo.put("InvoiceeMgtKey",			invoiceeMgtKey);
				listInfo.put("InvoiceeTaxRegID",		invoiceeTaxRegID);
				listInfo.put("InvoiceeCorpName",		invoiceeCorpName);
				listInfo.put("InvoiceeCEOName",			invoiceeCEOName);
				listInfo.put("InvoiceeAddr",			invoiceeAddr);
				listInfo.put("InvoiceeBizType",			invoiceeBizType);
				listInfo.put("InvoiceeBizClass",		invoiceeBizClass);
				listInfo.put("InvoiceeContactName1",	invoiceeContactName1);
				listInfo.put("InvoiceeDeptName1",		invoiceeDeptName1);
				listInfo.put("InvoiceeTel1",			invoiceeTel1);
				listInfo.put("InvoiceeEmail1",			invoiceeEmail1);
				listInfo.put("InvoiceeContactName2",	invoiceeContactName2);
				listInfo.put("InvoiceDeptName2",		invoiceDeptName2);
				listInfo.put("InvoiceTel2",				invoiceTel2);
				listInfo.put("InvoiceEmail2",			invoiceEmail2);
				listInfo.put("TrusteeCorpNum",			trusteeCorpNum);
				listInfo.put("TrusteeMgtKey",			trusteeMgtKey);
				listInfo.put("TrusteeTaxRegID",			trusteeTaxRegID);
				listInfo.put("TrusteeCorpName",			trusteeCorpName);
				listInfo.put("TrusteeCEOName",			trusteeCEOName);
				listInfo.put("TrusteeAddr",				trusteeAddr);
				listInfo.put("TrusteeBizType",			trusteeBizType);
				listInfo.put("TrusteeBizClass",			trusteeBizClass);
				listInfo.put("TrusteeContactName",		trusteeContactName);
				listInfo.put("TrusteeDeptName",			trusteeDeptName);
				listInfo.put("TrusteeTel",				trusteeTel);
				listInfo.put("TrusteeEmail",			trusteeEmail);
				listInfo.put("TossUserCode",			tossUserCode);
				listInfo.put("TossSenderUserCode",		tossSenderUserCode);
				listInfo.put("TossDate",				tossDate);
				listInfo.put("Toss",					toss);
				listInfo.put("RegistDate_main",			registDate_main);
				listInfo.put("IntDate",					intDate);
				listInfo.put("IsOffset",				isOffset);
				listInfo.put("CONVERSATION_ID",			cONVERSATION_ID);
				listInfo.put("SUPBUY_TYPE",				sUPBUY_TYPE);
				listInfo.put("DIRECTION",				dIRECTION);
				
				if(writeDate.indexOf("T") > 0){
					writeDate = writeDate.substring(0,writeDate.indexOf("T"));
				}
				writeDate = writeDate.replaceAll("[^0-9]", ".");
				
				if(totalAmount.length() > 0){
					if(totalAmount.indexOf(".") > 0){
						totalAmount		= totalAmount.substring(0, totalAmount.indexOf("."));
					}
				}else{
					totalAmount = "0";
				}
				
				if(supplyCostTotal.length() > 0){
					if(supplyCostTotal.indexOf(".") > 0){
						supplyCostTotal		= supplyCostTotal.substring(0, supplyCostTotal.indexOf("."));
					}
				}else{
					totalAmount = "0";
				}
				
				if(taxTotal.length() > 0){
					if(taxTotal.indexOf(".") > 0){
						taxTotal		= taxTotal.substring(0, taxTotal.indexOf("."));
					}
				}else{
					totalAmount = "0";
				}
				
				listInfo.put("FormatWriteDate",			writeDate);
				listInfo.put("FormatTotalAmount",		totalAmount);
				listInfo.put("FormatSupplyCostTotal",	supplyCostTotal);
				listInfo.put("FormatTaxTotal",			taxTotal);
				
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
	 * @Method Name : getInterfaceLogViewList
	 * @Description : Interface 로그 조회
	 */
	@Override
	public CoviMap getInterfaceLogViewList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();

		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;

		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		cnt		= (int) coviMapperOne.getNumber("account.common.getInterfaceLogViewListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.common.getInterfaceLogViewList",params);
		
		//page	= accountUtil.listPageCount(cnt, params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);

		return resultList;
	}
	
	/**
	 * @Method Name : getTaxInvoiceXmlInfo
	 * @Description : xml 데이터 추출
	 */
	@Override
	public CoviMap getTaxInvoiceXmlInfo(CoviMap params) throws Exception {
		CoviMap	resultList	= new CoviMap();
		try {
			CoviMap		obj			= new CoviMap();
			CoviList	objList		= new CoviList();
			
			MultipartFile mFile = (MultipartFile) params.get("uploadfile");
			File xmlFile		= xmlPrepareAttachment(mFile);	// 파일 생성
			
			DocumentBuilderFactory factory	= DocumentBuilderFactory.newInstance();
			DocumentBuilder builder			= factory.newDocumentBuilder();
			Document doc					= builder.parse(xmlFile);
			
			CoviMap tParam = new CoviMap();
			tParam.put("codeGroup","BusinessNumber");
			tParam.put("chkIsUse","Y");
			tParam.put("companyCode", getCompanyCodeOfUser());
			CoviList arrBusinessNumber = getBaseCodeData(tParam);
			
			doc.getDocumentElement().normalize();
			
			// 관리정보
			NodeList exchangedDocumentList			= doc.getElementsByTagName("ExchangedDocument");		
			for(int i=0; i<exchangedDocumentList.getLength();i++){
				Node node =exchangedDocumentList.item(i);
				if(node.getNodeType() == Node.ELEMENT_NODE){
					Element element = (Element) node;
					obj.put("IssueDateTimeExchangedDocument",	getElemenetNodeValue(element,"IssueDateTime"));
				}
			}
			
			// 기본정보
			NodeList taxInvoiceDocumentList			= doc.getElementsByTagName("TaxInvoiceDocument");
			for(int i=0; i<taxInvoiceDocumentList.getLength();i++){
				Node node =taxInvoiceDocumentList.item(i);
				if(node.getNodeType() == Node.ELEMENT_NODE){
					Element element = (Element) node;
					obj.put("IssueID",							getElemenetNodeValue(element,"IssueID"));
					obj.put("TypeCode",							getElemenetNodeValue(element,"TypeCode"));
					obj.put("IssueDateTimeTaxInvoiceDocument",	getElemenetNodeValue(element,"IssueDateTime"));
					obj.put("PurposeCode",						getElemenetNodeValue(element,"PurposeCode"));
				}
			}
			
			// 거래처정보-공급자
			NodeList invoicerPartyList			= doc.getElementsByTagName("InvoicerParty");
			for(int i=0; i<invoicerPartyList.getLength();i++){
				Node node =invoicerPartyList.item(i);
				
				if(node.getNodeType() == Node.ELEMENT_NODE){
					Element element = (Element) node;
					obj.put("InvoicerID",						getElemenetNodeValue(element,	"ID"));
					obj.put("InvoicerTypeCode",					getElemenetNodeValue(element,	"TypeCode"));
					obj.put("InvoicerNameText",					getElemenetNodeValue(element,	"NameText"));
					obj.put("InvoicerClassificationCode",		getElemenetNodeValue(element,	"ClassificationCode"));
					
					NodeList specifiedOrganization	= element.getElementsByTagName("SpecifiedOrganization");
					for(int j=0; j<specifiedOrganization.getLength(); j++){
						Node cNode =specifiedOrganization.item(j);
						if(cNode.getNodeType() == Node.ELEMENT_NODE){
							Element cElement = (Element) cNode;
							obj.put("InvoicerTaxRegistrationID",		getElemenetNodeValue(cElement,	"TaxRegistrationID"));
						}
					}
					
					NodeList specifiedPerson	= element.getElementsByTagName("SpecifiedPerson");
					for(int j=0; j<specifiedPerson.getLength(); j++){
						Node cNode =specifiedPerson.item(j);
						if(cNode.getNodeType() == Node.ELEMENT_NODE){
							Element cElement = (Element) cNode;
							obj.put("InvoicerSpecifiedPersonNameText",	getElemenetNodeValue(cElement,	"NameText"));
						}
					}
					
					NodeList definedContact	= element.getElementsByTagName("DefinedContact");
					for(int j=0; j<definedContact.getLength(); j++){
						Node cNode =definedContact.item(j);
						if(cNode.getNodeType() == Node.ELEMENT_NODE){
							Element cElement = (Element) cNode;
							obj.put("InvoicerPersonNameText",			getElemenetNodeValue(cElement,	"PersonNameText"));
							obj.put("InvoicerTelephoneCommunication",	getElemenetNodeValue(cElement,	"TelephoneCommunication"));
							obj.put("InvoicerURICommunication",			getElemenetNodeValue(cElement,	"URICommunication"));
						}
					}
					
					NodeList specifiedAddress	= element.getElementsByTagName("SpecifiedAddress");
					for(int j=0; j<specifiedAddress.getLength(); j++){
						Node cNode =specifiedAddress.item(j);
						if(cNode.getNodeType() == Node.ELEMENT_NODE){
							Element cElement = (Element) cNode;
							obj.put("InvoicerLineOneText",					getElemenetNodeValue(cElement,	"LineOneText"));
						}
					}
				}
			}
	
			if(!arrBusinessNumber.isEmpty()) {
				for(Object oBizNum : arrBusinessNumber) {
					if(oBizNum instanceof CoviMap) {
						CoviMap joBizNum = (CoviMap) oBizNum;
						
						if(joBizNum.getString("Code").replaceAll("-", "").equals(obj.getString("InvoicerID"))){
							throw new Exception(DicHelper.getDic("msg_AccXmlUploadOnlyPurchase"));
						}
					}
				}
			}
			
			// 거래처정보-공급받는자
			NodeList invoiceePartyList			= doc.getElementsByTagName("InvoiceeParty");
			for(int i=0; i<invoiceePartyList.getLength();i++){
				Node node =invoiceePartyList.item(i);
				if(node.getNodeType() == Node.ELEMENT_NODE){
					Element element = (Element) node;
					obj.put("InvoiceeID",						getElemenetNodeValue(element,	"ID"));
					obj.put("InvoiceeTypeCode",					getElemenetNodeValue(element,	"TypeCode"));
					obj.put("InvoiceeNameText",					getElemenetNodeValue(element,	"NameText"));
					obj.put("InvoiceeClassificationCode",		getElemenetNodeValue(element,	"ClassificationCode"));
					obj.put("InvoiceePersonNameText",			getElemenetNodeValue(element,	"PersonNameText"));
					obj.put("InvoiceeSecondaryDefinedContact",	getElemenetNodeValue(element,	"SecondaryDefinedContact"));
	
					NodeList specifiedOrganization	= element.getElementsByTagName("SpecifiedOrganization");
					for(int j=0; j<specifiedOrganization.getLength(); j++){
						Node cNode =specifiedOrganization.item(j);
						if(cNode.getNodeType() == Node.ELEMENT_NODE){
							Element cElement = (Element) cNode;
							obj.put("InvoiceeTaxRegistrationID",		getElemenetNodeValue(cElement,	"TaxRegistrationID"));
							obj.put("InvoiceeBusinessTypeCode",			getElemenetNodeValue(cElement,	"BusinessTypeCode"));
						}
					}
					
					NodeList specifiedPerson	= element.getElementsByTagName("SpecifiedPerson");
					for(int j=0; j<specifiedPerson.getLength(); j++){
						Node cNode =specifiedPerson.item(j);
						if(cNode.getNodeType() == Node.ELEMENT_NODE){
							Element cElement = (Element) cNode;
							obj.put("InvoiceeSpecifiedPersonNameText",	getElemenetNodeValue(cElement,	"NameText"));
						}
					}
					
					NodeList primaryDefinedContact	= element.getElementsByTagName("PrimaryDefinedContact");
					for(int j=0; j<primaryDefinedContact.getLength(); j++){
						Node cNode =primaryDefinedContact.item(j);
						if(cNode.getNodeType() == Node.ELEMENT_NODE){
							Element cElement = (Element) cNode;
							obj.put("InvoiceePersonNameText1",			getElemenetNodeValue(cElement,	"PersonNameText"));
							obj.put("InvoiceeTelephoneCommunication1",	getElemenetNodeValue(cElement,	"TelephoneCommunication"));
							obj.put("InvoiceeURICommunication1",			getElemenetNodeValue(cElement,	"URICommunication"));
						}
					}
					
					/*
					NodeList secondaryDefinedContact	= element.getElementsByTagName("SecondaryDefinedContact");
					for(int j=0; j<secondaryDefinedContact.getLength(); j++){
						Node cNode =secondaryDefinedContact.item(j);
						if(cNode.getNodeType() == Node.ELEMENT_NODE){
							Element cElement = (Element) cNode;
							obj.put("InvoiceePersonNameText2",			getElemenetNodeValue(cElement,	"PersonNameText"));
							obj.put("InvoiceeTelephoneCommunication2",	getElemenetNodeValue(cElement,	"TelephoneCommunication"));
							obj.put("InvoiceeURICommunication2",		getElemenetNodeValue(cElement,	"URICommunication"));
						}
					}
					*/
					
					NodeList specifiedAddress	= element.getElementsByTagName("SpecifiedAddress");
					for(int j=0; j<specifiedAddress.getLength(); j++){
						Node cNode =specifiedAddress.item(j);
						if(cNode.getNodeType() == Node.ELEMENT_NODE){
							Element cElement = (Element) cNode;
							obj.put("InvoiceeLineOneText",				getElemenetNodeValue(cElement,	"LineOneText"));
						}
					}
				}
			}
	
			// 결제정보 - 결제방법별금액
			NodeList specifiedPaymentMeans			= doc.getElementsByTagName("SpecifiedPaymentMeans");
			for(int i=0; i<specifiedPaymentMeans.getLength();i++){
				Node node =specifiedPaymentMeans.item(i);
				if(node.getNodeType() == Node.ELEMENT_NODE){
					Element element = (Element) node;
					String paymentMeans = "";
					switch(getElemenetNodeValue(element, "TypeCode")) {
					case "10":
						paymentMeans = "Cash";
						break;
					case "20":
						paymentMeans = "ChkBill";
						break;
					case "30":
						paymentMeans = "Credit";
						break;
					case "40":
						paymentMeans = "Note";
						break;
					default : 
						break;
					}
					obj.put(paymentMeans,						getElemenetNodeValue(element,	"PaidAmount"));
				}
			}
			
			// 결제정보-Summary
			NodeList specifiedMonetarySummationList			= doc.getElementsByTagName("SpecifiedMonetarySummation");
			for(int i=0; i<specifiedMonetarySummationList.getLength();i++){
				Node node =specifiedMonetarySummationList.item(i);
				if(node.getNodeType() == Node.ELEMENT_NODE){
					Element element = (Element) node;
					obj.put("ChargeTotalAmount",				getElemenetNodeValue(element,	"ChargeTotalAmount"));
					obj.put("TaxTotalAmount",					getElemenetNodeValue(element,	"TaxTotalAmount"));
					obj.put("GrandTotalAmount",					getElemenetNodeValue(element,	"GrandTotalAmount"));
				}
			}
			
			// 상품정보
			CoviMap itemObj = new CoviMap();
			NodeList taxInvoiceTradeLineItemList			= doc.getElementsByTagName("TaxInvoiceTradeLineItem");
			for(int i=0; i<taxInvoiceTradeLineItemList.getLength();i++){
				Node node =taxInvoiceTradeLineItemList.item(i);
				if(node.getNodeType() == Node.ELEMENT_NODE){
					itemObj = new CoviMap();
					Element element = (Element) node;
					itemObj.put("SequenceNumeric",				getElemenetNodeValue(element,	"SequenceNumeric")); // 일련번호
					itemObj.put("InvoiceAmount",				getElemenetNodeValue(element,	"InvoiceAmount")); // 공급가액
					itemObj.put("NameText",						getElemenetNodeValue(element,	"NameText")); // 품목명
					itemObj.put("PurchaseExpiryDateTime",		getElemenetNodeValue(element,	"PurchaseExpiryDateTime")); // 공급년월일
					itemObj.put("InformationText",				getElemenetNodeValue(element,	"InformationText")); // 규격
					itemObj.put("DescriptionText",				getElemenetNodeValue(element,	"DescriptionText")); // 비고
					itemObj.put("ChargeableUnitQuantity",		getElemenetNodeValue(element,	"ChargeableUnitQuantity")); //수량
					
					NodeList unitPrice	= element.getElementsByTagName("UnitPrice");
					for(int j=0; j<unitPrice.getLength(); j++){
						Node cNode =unitPrice.item(j);
						if(cNode.getNodeType() == Node.ELEMENT_NODE){
							Element cElement = (Element) cNode;
							itemObj.put("UnitAmount",			getElemenetNodeValue(cElement,	"UnitAmount")); //단가
						}
					}
					
					NodeList totalTax	= element.getElementsByTagName("TotalTax");
					for(int j=0; j<totalTax.getLength(); j++){
						Node cNode =totalTax.item(j);
						if(cNode.getNodeType() == Node.ELEMENT_NODE){
							Element cElement = (Element) cNode;
							itemObj.put("CalculatedAmount",				getElemenetNodeValue(cElement,	"CalculatedAmount")); //세액
						}
					}
					objList.add(itemObj);
				}
			}
			
			// 기존에 있는 정보인지 체크
			String conversationID = obj.getString("InvoicerID") + obj.getString("IssueID");
			if(taxInvoiceSvc.chkDupTaxInvoice(conversationID)) {
				throw new Exception(DicHelper.getDic("msg_dupAccTaxInvoice"));
			}
			
			resultList.put("info",		obj);
			resultList.put("items",		objList);
			resultList.put("status",	Return.SUCCESS);
		} catch (NullPointerException npE) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", npE.getMessage());
		} catch (Exception e) {
			resultList.put("status", Return.FAIL);
			resultList.put("message", e.getMessage());
		}
		return resultList;
	}
	
	/**
	 * @Method Name : xmlPrepareAttachment
	 * @Description : xml 임시파일 생성
	 */
	private File xmlPrepareAttachment(final MultipartFile mFile) throws IOException {
	    File tmp = null;
	    try {
	        tmp = File.createTempFile("upload", ".tmp");
	        mFile.transferTo(tmp);
	        
	        return tmp;
	    } catch (IOException ioE) {
	        if (tmp != null) {
	        	if(tmp.delete()) {
	        		logger.info("xmlPrepareAttachment : temp delete()");
	        	}
	        }
	        
	        throw ioE;
	    }
	}

	/**
	 * @Method Name : getElemenetNodeValue
	 * @Description : get xml Value
	 */
	private String getElemenetNodeValue(Element element, String tagName){
		String rtString  ="";
		try {
			NodeList elementList = element.getElementsByTagName(tagName).item(0).getChildNodes();
			Node elemenetNodeValue = elementList.item(0);
			if(elemenetNodeValue == null){
				rtString = "";
			}else{
				rtString = rtString(elemenetNodeValue.getNodeValue());				
			}
		} catch (NullPointerException npE) {
			logger.error(npE.getLocalizedMessage(), npE);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return rtString;
	}

	/**
	 * @Method Name : getApplicationStatus
	 * @Description : 비용 신청 상태
	 */
	@Override
	public CoviMap getApplicationStatus(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList list	= coviMapperOne.list("account.common.getApplicationStatus",params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));

		return resultList;		
	}
	
	/**
	 * @Method Name : searchUsageTextData
	 * @Description : 적요 조회
	 */
	@Override
	public CoviMap searchUsageTextData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list	= coviMapperOne.list("account.common.searchUsageTextData",params);
		resultList.put("list", AccountUtil.convertNullToSpace(list));

		return resultList;		
	}
	
	@Override
	public int saveUsageTextData(CoviMap params) throws Exception {
		int cnt = 0;
		cnt = coviMapperOne.update("account.common.updateUsageTextData",params);
		return cnt;
	}
	
	/**
	 * @Method Name : rtString
	 * @Description : 
	 */
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}
	
	@Override
	public void saveKakaoApprovalList(CoviMap params) throws Exception {
		int cnt = (int) coviMapperOne.getNumber("account.common.selectKakaoApprovalListCnt", params);
		
		if(cnt == 0){
			coviMapperOne.insert("account.common.insertKakaoApprovalList",params);
		}
	}
	public String getApprovalNoData(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("account.common.selectApprovalNo", params);
	}
	
	@Override
	public CoviMap getEntinfoListData(CoviMap params) throws Exception {		
		params.put("lang", SessionHelper.getSession("lang"));
		
		String queryId = "account.common.selectEntInfoList";
		if("ID".equals(params.get("domainCodeType"))) {
			queryId = "account.common.selectEntInfoListId";
		}
		CoviList list = coviMapperOne.list(queryId, params);		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "optionValue,optionText,defaultVal"));	
		return resultList;
	}
}
