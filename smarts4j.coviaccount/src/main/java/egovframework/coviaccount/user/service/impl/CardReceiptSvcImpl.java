package egovframework.coviaccount.user.service.impl;

import java.lang.invoke.MethodHandles;
import java.util.ArrayList;
import java.util.Map;
import java.util.Map.Entry;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.interfaceUtil.interfaceVO.CardReceiptVO;
import egovframework.coviaccount.user.service.BaseCodeSvc;
import egovframework.coviaccount.user.service.CardReceiptSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("CardReceiptSvc")
public class CardReceiptSvcImpl extends EgovAbstractServiceImpl implements CardReceiptSvc {
	
	private Logger LOGGER = LogManager.getLogger(CardReceiptSvcImpl.class);
	
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
	
	//CardReceipt - Start
	
	/**
	 * @Method Name : getCardReceiptList
	 * @Description : 법인카드 사용내역 목록 조회
	 */
	@Override
	public CoviMap getCardReceiptList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		CoviMap interfaceParam	= new CoviMap();
		boolean interfaceTF		= true;

		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
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
				String pCardUserCode	= rtString(params.get("cardUserCode"));
				String pInfoIndex		= rtString(params.get("infoIndex"));
				String pIsPersonalUse	= rtString(params.get("isPersonalUse"));
				
				pApproveDateS = pApproveDateS.replaceAll("[^0-9]", "-");
				pApproveDateE = pApproveDateE.replaceAll("[^0-9]", "-");
				
				CoviMap xmlParam = new CoviMap();
				
				xmlParam.put("pPageSize",		pageSize);
				xmlParam.put("pPageCurrent",	pageNo);
				
				if(!pApproveDateS.equals("")){	xmlParam.put("pSDate",			pApproveDateS);}
				if(!pApproveDateE.equals("")){	xmlParam.put("pEDate",			pApproveDateE);}
				if(!pCardUserCode.equals("")){	xmlParam.put("pCarduser",		pCardUserCode);}
				if(!pCardNo.equals("")){		xmlParam.put("pCardNo",			pCardNo);}
				if(!pInfoIndex.equals("")){		xmlParam.put("pInfoIndex",		pInfoIndex);}
				if(!pIsPersonalUse.equals("")){	xmlParam.put("pIsPersonalUse",	pIsPersonalUse);}
				
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
				cnt		= (int) coviMapperOne.getNumber("account.cardReceipt.getCardReceiptListCnt", params);

				page 	= ComUtils.setPagingData(params,cnt);
				params.addAll(page);				
				
				list	= coviMapperOne.list("account.cardReceipt.getCardReceiptList", params);
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
				
				String active				= cardReceiptVO.getActive();
				String approveDate			= cardReceiptVO.getApproveDate();
				String approveTime			= cardReceiptVO.getApproveTime();
				String approveNo			= cardReceiptVO.getApproveNo();
				String storeName			= cardReceiptVO.getStoreName();
				String amountWon			= cardReceiptVO.getAmountWon();
				String foreignCurrency		= cardReceiptVO.getForeignCurrency();
				String cardNo				= cardReceiptVO.getCardNo();
				String cardUserCode			= cardReceiptVO.getCardUserCode();
				String tossSenderUserCode	= cardReceiptVO.getTossSenderUserCode();
				String tossUserCode			= cardReceiptVO.getTossUserCode();
				String tossComment			= cardReceiptVO.getTossComment();
				String totalCount			= cardReceiptVO.getTotalCount();
				//데이터 구조가 다른 관계로  임시로 셋팅
				
				cardNo		= cardNo.replaceAll("[^0-9]", "");
				approveDate	= approveDate.replaceAll("[^0-9]", ".");
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				cnt = Integer.parseInt(totalCount);
				
				if(searchType.equals("SOAP")){
					active		= "N";
				}
				
				listInfo.put("ReceiptID",			receiptID);
				listInfo.put("CardNo",				accountUtil.getCardNumStr(cardNo));
				listInfo.put("CardUserCode",		cardUserCode);
				listInfo.put("ApproveDate",			approveDate);
				listInfo.put("ApproveTime",			approveTime);
				listInfo.put("ApproveNo",			approveNo);
				listInfo.put("AmountWon",			accountUtil.getAmountStr(amountWon));
				listInfo.put("ForeignCurrency",		foreignCurrency);
				listInfo.put("StoreName",			storeName);
				listInfo.put("Active",				active);
				listInfo.put("TossUserCode",		tossUserCode);
				listInfo.put("TossSenderUserCode",	tossSenderUserCode);
				listInfo.put("TossComment",			tossComment);
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
	 * @Method Name : getCardReceiptExcelList
	 * @Description : 법인카드 사용내역 엑셀 다운로드
	 */
	@Override
	public CoviMap getCardReceiptExcelList(CoviMap params) throws Exception{
		boolean interfaceTF		= true;
		CoviMap interfaceParam	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		CoviList list			= new CoviList();
		
		String headerKey	= params.get("headerKey").toString();
		int cnt				= 0;
		
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
					String pCardUserCode	= rtString(params.get("cardUserCode"));
					
					pApproveDateS = pApproveDateS.replaceAll("[^0-9]", "-");
					pApproveDateE = pApproveDateE.replaceAll("[^0-9]", "-");
					
					CoviMap xmlParam = new CoviMap();
					
					if(!pApproveDateS.equals("")){	xmlParam.put("pSDate",		pApproveDateS);}
					if(!pApproveDateE.equals("")){	xmlParam.put("pEDate",		pApproveDateE);}
					if(!pCardUserCode.equals("")){	xmlParam.put("pCarduser",	pCardUserCode);}
					if(!pCardNo.equals("")){		xmlParam.put("pCardNo",		pCardNo);}
					
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
				list	= coviMapperOne.list("account.cardReceipt.getCardReceiptExcelList", params);
				cnt		= (int) coviMapperOne.getNumber("account.cardReceipt.getCardReceiptListCnt", params);
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
				
				String active				= cardReceiptVO.getActive();
				String approveDate			= cardReceiptVO.getApproveDate();
				String approveTime			= cardReceiptVO.getApproveTime();
				String approveNo			= cardReceiptVO.getApproveNo();
				String storeName			= cardReceiptVO.getStoreName();
				String amountWon			= cardReceiptVO.getAmountWon();
				String foreignCurrency		= cardReceiptVO.getForeignCurrency();
				String cardNo				= cardReceiptVO.getCardNo();
				String cardUserCode			= cardReceiptVO.getCardUserCode();
				String tossSenderUserCode	= cardReceiptVO.getTossSenderUserCode();
				String tossUserCode			= cardReceiptVO.getTossUserCode();
				String tossComment			= cardReceiptVO.getTossComment();
				String totalCount			= cardReceiptVO.getTotalCount();
				//데이터 구조가 다른 관계로  임시로 셋팅
				
				cardNo		= cardNo.replaceAll("[^0-9]", "");
				approveDate	= approveDate.replaceAll("[^0-9]", ".");
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				if(searchType.equals("SOAP")){
					active		= "N";
				}
				
				cnt = Integer.parseInt(totalCount);
				
				listInfo.put("ReceiptID",			receiptID);
				listInfo.put("CardNo",				accountUtil.getCardNumStr(cardNo));
				listInfo.put("CardUserCode",		cardUserCode);
				listInfo.put("ApproveDate",			approveDate);
				listInfo.put("ApproveTime",			approveTime);
				listInfo.put("ApproveNo",			approveNo);
				listInfo.put("AmountWon",			accountUtil.getAmountStr(amountWon));
				listInfo.put("ForeignCurrency",		foreignCurrency);
				listInfo.put("StoreName",			storeName);
				listInfo.put("Active",				active);
				listInfo.put("TossUserCode",		tossUserCode);
				listInfo.put("TossSenderUserCode",	tossSenderUserCode);
				listInfo.put("TossComment",			tossComment);
				list.add(listInfo);
			}
		}
		
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : saveCardReceiptTossUser
	 * @Description : 법인카드 사용내역 전달 사용자 저장
	 */
	@Override
	public CoviMap saveCardReceiptTossUser(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		ArrayList<Map<String, Object>> chkList	= (ArrayList<Map<String, Object>>) params.get("chkList");

		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		if(chkList.size() > 0){
			for(int i=0; i <chkList.size(); i++){
				CoviMap info = new CoviMap(chkList.get(i));
				params.put("receiptID", info.get("ReceiptID"));
				updateCardReceiptTossUser(params);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : updateCardReceiptTossUser
	 * @Description : 법인카드 사용내역 전달 사용자 정보 Update
	 */
	public void updateCardReceiptTossUser(CoviMap params)throws Exception {
		coviMapperOne.update("account.cardReceipt.updateCardReceiptTossUser", params);
	}
	//CardReceipt - End
	
	//CardReceiptCancel - Start

	/**
	 * @Method Name : getCardReceiptCancelList
	 * @Description : 법인카드 승인 취소 내역 목록 조회
	 */
	@Override
	public CoviMap getCardReceiptCancelList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		params.put("UR_Code", 		SessionHelper.getSession("UR_Code"));

		cnt		= (int) coviMapperOne.getNumber("account.cardReceipt.getCardReceiptCancelListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.cardReceipt.getCardReceiptCancelList", params);
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getCardReceiptCancelExcelList
	 * @Description : 법인카드 승인 취소 내역 엑셀 다운로드
	 */
	@Override
	public CoviMap getCardReceiptCancelExcelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		CoviList list		= coviMapperOne.list("account.cardReceipt.getCardReceiptCancelExcelList", params);
		int cnt				= (int) coviMapperOne.getNumber("account.cardReceipt.getCardReceiptCancelListCnt", params);
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
	//CardReceiptCancel - End
	
	//CardReceiptUser - Start
	
	/**
	 * @Method Name : getCardReceiptUserList
	 * @Description : 법인카드 청구내역 [사용자] 목록 조회
	 */
	@Override
	public CoviMap getCardReceiptUserList(CoviMap params) throws Exception {
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
				
				String pApproveDateS	= rtString(params.get("startDD"));
				String pApproveDateE	= rtString(params.get("endDD"));
				String pCardNo			= rtString(params.get("cardNo"));
				String pApproveNo		= rtString(params.get("approveNo"));
				String pCardUserCode	= rtString(params.get("cardUserCode"));
				
				pApproveDateS = pApproveDateS.replaceAll("[^0-9]", "-");
				pApproveDateE = pApproveDateE.replaceAll("[^0-9]", "-");
				
				CoviMap xmlParam = new CoviMap();
				
				xmlParam.put("pPageSize",		pageSize);
				xmlParam.put("pPageCurrent",	pageNo);
				
				if(!pApproveDateS.equals("")){	xmlParam.put("pSDate",		pApproveDateS);}
				if(!pApproveDateE.equals("")){	xmlParam.put("pEDate",		pApproveDateE);}
				if(!pCardUserCode.equals("")){	xmlParam.put("pCarduser",	pCardUserCode);}
				if(!pCardNo.equals("")){		xmlParam.put("pCardNo",		pCardNo);}
				if(!pApproveNo.equals("")){		xmlParam.put("pApproveNo",	pApproveNo);}
				
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
				cnt		= (int) coviMapperOne.getNumber("account.cardReceipt.getCardReceiptUserListCnt", params);
				
				page 	= ComUtils.setPagingData(params,cnt);
				params.addAll(page);
				
				list	= coviMapperOne.list("account.cardReceipt.getCardReceiptUserList", params);
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
				
				String active				= cardReceiptVO.getActive();
				String approveDate			= cardReceiptVO.getApproveDate();
				String approveTime			= cardReceiptVO.getApproveTime();
				String approveNo			= cardReceiptVO.getApproveNo();
				String storeName			= cardReceiptVO.getStoreName();
				String amountWon			= cardReceiptVO.getAmountWon();
				String foreignCurrency		= cardReceiptVO.getForeignCurrency();
				String cardNo				= cardReceiptVO.getCardNo();
				String cardUserCode			= cardReceiptVO.getCardUserCode();
				String tossSenderUserCode	= cardReceiptVO.getTossSenderUserCode();
				String tossUserCode			= cardReceiptVO.getTossUserCode();
				String tossComment			= cardReceiptVO.getTossComment();
				String totalCount			= cardReceiptVO.getTotalCount();
				//데이터 구조가 다른 관계로  임시로 셋팅
				
				cardNo		= cardNo.replaceAll("[^0-9]", "");
				approveDate	= approveDate.replaceAll("[^0-9]", ".");
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				if(searchType.equals("SOAP")){
					active		= "N";
				}
				
				cnt = Integer.parseInt(totalCount);
				
				listInfo.put("ReceiptID",			receiptID);
				listInfo.put("CardNo",				accountUtil.getCardNumStr(cardNo));
				listInfo.put("CardUserCode",		cardUserCode);
				listInfo.put("ApproveDate",			approveDate);
				listInfo.put("ApproveTime",			approveTime);
				listInfo.put("ApproveNo",			approveNo);
				listInfo.put("AmountWon",			accountUtil.getAmountStr(amountWon));
				listInfo.put("ForeignCurrency",		foreignCurrency);
				listInfo.put("StoreName",			storeName);
				listInfo.put("Active",				active);
				listInfo.put("TossUserCode",		tossUserCode);
				listInfo.put("TossSenderUserCode",	tossSenderUserCode);
				listInfo.put("TossComment",			tossComment);
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
	 * @Method Name : getCardReceiptUserExcelList
	 * @Description : 법인카드 청구내역 [사용자] 엑셀 다운로드
	 */
	@Override
	public CoviMap getCardReceiptUserExcelList(CoviMap params) throws Exception{
		boolean interfaceTF		= true;
		CoviMap interfaceParam	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		CoviList list			= new CoviList();
		
		params.put("UR_Code",	SessionHelper.getSession("UR_Code"));
		
		String headerKey	= params.get("headerKey").toString();
		int cnt				= 0;
		
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
				String pCardUserCode	= rtString(params.get("cardUserCode"));
				
				pApproveDateS = pApproveDateS.replaceAll("[^0-9]", "-");
				pApproveDateE = pApproveDateE.replaceAll("[^0-9]", "-");
				
				CoviMap xmlParam = new CoviMap();
				
				if(!pApproveDateS.equals("")){	xmlParam.put("pSDate",		pApproveDateS);}
				if(!pApproveDateE.equals("")){	xmlParam.put("pEDate",		pApproveDateE);}
				if(!pCardUserCode.equals("")){	xmlParam.put("pCarduser",	pCardUserCode);}
				if(!pCardNo.equals("")){		xmlParam.put("pCardNo",		pCardNo);}
				if(!pApproveNo.equals("")){		xmlParam.put("pApproveNo",	pApproveNo);}
				
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
				list	= coviMapperOne.list("account.cardReceipt.getCardReceiptUserExcelList", params);
				cnt		= (int) coviMapperOne.getNumber("account.cardReceipt.getCardReceiptUserListCnt", params);
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
				
				String active				= cardReceiptVO.getActive();
				String approveDate			= cardReceiptVO.getApproveDate();
				String approveTime			= cardReceiptVO.getApproveTime();
				String approveNo			= cardReceiptVO.getApproveNo();
				String storeName			= cardReceiptVO.getStoreName();
				String amountWon			= cardReceiptVO.getAmountWon();
				String foreignCurrency		= cardReceiptVO.getForeignCurrency();
				String cardNo				= cardReceiptVO.getCardNo();
				String cardUserCode			= cardReceiptVO.getCardUserCode();
				String tossSenderUserCode	= cardReceiptVO.getTossSenderUserCode();
				String tossUserCode			= cardReceiptVO.getTossUserCode();
				String tossComment			= cardReceiptVO.getTossComment();
				String totalCount			= cardReceiptVO.getTotalCount();
				//데이터 구조가 다른 관계로  임시로 셋팅
				
				cardNo		= cardNo.replaceAll("[^0-9]", "");
				approveDate	= approveDate.replaceAll("[^0-9]", ".");
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				if(searchType.equals("SOAP")){
					active		= "N";
				}
				
				cnt = Integer.parseInt(totalCount);
				
				listInfo.put("ReceiptID",			receiptID);
				listInfo.put("CardNo",				accountUtil.getCardNumStr(cardNo));
				listInfo.put("CardUserCode",		cardUserCode);
				listInfo.put("ApproveDate",			approveDate);
				listInfo.put("ApproveTime",			approveTime);
				listInfo.put("ApproveNo",			approveNo);
				listInfo.put("AmountWon",			accountUtil.getAmountStr(amountWon));
				listInfo.put("ForeignCurrency",		foreignCurrency);
				listInfo.put("StoreName",			storeName);
				listInfo.put("Active",				active);
				listInfo.put("TossUserCode",		tossUserCode);
				listInfo.put("TossSenderUserCode",	tossSenderUserCode);
				listInfo.put("TossComment",			tossComment);
				list.add(listInfo);
			}
		}
		
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : saveCardReceiptPersonal
	 * @Description : 법인카드 청구내역 [사용자] 개인 사용 처리 유무 저장
	 */
	@Override
	public CoviMap saveCardReceiptPersonal(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		ArrayList<Map<String, Object>> chkList	= (ArrayList<Map<String, Object>>) params.get("chkList");

		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		if(chkList.size() > 0){
			for(int i=0; i <chkList.size(); i++){
				CoviMap info = new CoviMap(chkList.get(i));
				params.put("receiptID", info.get("ReceiptID"));
				updateCardReceiptPersonal(params);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : updateCardReceiptPersonal
	 * @Description : 법인카드 청구내역 [사용자] 개인 사용처리 Update
	 */
	public void updateCardReceiptPersonal(CoviMap params)throws Exception {
		coviMapperOne.update("account.cardReceipt.updateCardReceiptPersonal", params);
	}
	//CardReceiptUser - End
	
	/**
	 * @Method Name : getCardReceiptUserPersonalUseList
	 * @Description : 개인카드 청구내역 목록 조회
	 */
	@Override
	public CoviMap getCardReceiptUserPersonalUseList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));

		cnt		= (int) coviMapperOne.getNumber("account.cardReceipt.getCardReceiptUserPersonalUseListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.cardReceipt.getCardReceiptUserPersonalUseList", params);
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : cardReceiptSync
	 * @Description : 카드 승인 내역 동기화
	 */
	@Override
	public CoviMap cardReceiptSync(CoviMap params){

		CoviMap interfaceParam		= new CoviMap();
		CoviMap resultList		= new CoviMap();
		CardReceiptVO cardReceiptVO	= null;
		
		// Copy parameter from Controller.
		for(Object o : params.entrySet()) {
			Entry entry = (Entry)o;
			interfaceParam.put(entry.getKey(), entry.getValue());
		}
		InterfaceUtil.setCurrentRequestAttr("DN_ID", interfaceParam.getString("DN_ID"));
		
		try{
			//String syncType = accountUtil.getPropertyInfo("account.syncType.CardReceipt");
			String syncType = accountUtil.getBaseCodeInfo("eAccSyncType", "CardReceipt", (String)InterfaceUtil.getCurrentRequestAttr("DN_ID"));
			
			interfaceParam.put("interFaceType",			syncType);
			interfaceParam.put("daoClassName",			"CardReceiptDao");
			interfaceParam.put("voClassName",			"CardReceiptVO");
			interfaceParam.put("mapClassName",			"CardReceiptMap");
	
			interfaceParam.put("daoSetFunctionName",	"setCardReceiptList");
			interfaceParam.put("daoGetFunctionName",	"getCardReceiptList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			switch (syncType) {
				case "DB":
					//syncType이 DB인 경우 이곳에 정의
					//String cardReceiptDBType = rtString(accountUtil.getPropertyInfo("account.searchDBType.CardReceipt"));
					String cardReceiptDBType = rtString(accountUtil.getBaseCodeInfo("eAccDBType", "CardReceipt", (String)InterfaceUtil.getCurrentRequestAttr("DN_ID")));
					
					String sqlName			= "";
					String mapFunctionName	= "";
					if(cardReceiptDBType.equals("InfoTech")){
						mapFunctionName	= "getInfoTechDBMap";
						sqlName			= "accountInterFace.Account4JIF.getInterFaceListCardReceiptInfoTech";
					}else if(cardReceiptDBType.equals("Kwic")) {
						String cardReceiptSelectType = RedisDataUtil.getBaseConfig("CardReceiptSelectType",params.getString("DN_ID"));

						if(cardReceiptSelectType.equals("P")) {	//법인카드 매입수신내역
							mapFunctionName	= "getKwicPurchaseMap";
							sqlName			= "accountInterFace.Account4JIF.getInterFaceListCardReceiptKwicPurchase";
						}else {	//법인카드 승인수신내역
							mapFunctionName	= "getKwicDBMap";
							sqlName			= "accountInterFace.Account4JIF.getInterFaceListCardReceiptKwic";
						}
						interfaceParam.put("AccountBatchDay", RedisDataUtil.getBaseConfig("AccountBatchDay", params.getString("DN_ID")));

					}else{
						mapFunctionName	= "getDBMap";
						//sqlName = StringUtil.replaceNull(accountUtil.getPropertyInfo("account.searchDBName.CardReceipt"),"accountInterFace.AccountSI.getInterFaceListCardReceipt");
						sqlName = StringUtil.replaceNull(accountUtil.getBaseCodeInfo("eAccDBName", "CardReceipt", (String)InterfaceUtil.getCurrentRequestAttr("DN_ID")),"accountInterFace.AccountSI.getInterFaceListCardReceipt");
					}
					
					interfaceParam.put("mapFunctionName",	mapFunctionName);
					interfaceParam.put("type",				"get");
					interfaceParam.put("sqlName",			sqlName);
					break;
		
				case "SOAP":
					//syncType이 SOAP인 경우 이곳에 정의
						CoviMap xmlParam = new CoviMap();
						interfaceParam.put("xmlParam",			xmlParam);
						interfaceParam.put("mapFunctionName",	"getSoapMap");
						interfaceParam.put("soapName",			"XpenseGetCardReceiptList");
						interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetCardReceiptList");
					
					break;
					
				case "SAP":
					//syncType이 SAP인 경우 이곳에 정의
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
					break;
			}
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
	
			ArrayList list = (ArrayList) getInterface.get("list");
	
			for (int i = 0; i < list.size(); i++) {
				CoviMap listInfo = new CoviMap();
				
				cardReceiptVO = (CardReceiptVO) list.get(i);
				
				String receiptID			= cardReceiptVO.getReceiptID();
				
				if(receiptID.equals("")){
					continue;
				}
				
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
				String storeStatus			= cardReceiptVO.getStoreStatus();
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
				
				cardNo		= cardNo.replaceAll("[^0-9]", 		"");
				taxTypeDate	= taxTypeDate.replaceAll("[^0-9]", 	"");
				approveDate	= approveDate.replaceAll("[^0-9]",	"");
				useDate		= useDate.replaceAll("[^0-9]",		"");
				sendDate	= sendDate.replaceAll("[^0-9]",		"");
				
				if(syncType.equals("SOAP")){
					active		= "N";
					infoIndex	= "A";
				}
				
				if(infoIndex.equals("C") || infoIndex.equals("D")) {
					amountWon = setNegative(amountWon);
					amountForeign = setNegative(amountForeign);
					repAmount = setNegative(repAmount);
					taxAmount = setNegative(taxAmount);
					serviceAmount = setNegative(serviceAmount);
				}
				if(StringUtil.isEmpty(amountForeign)) {
					amountForeign = "0"; // mssql에서 오류
				}
				
				listInfo.put("receiptID",			receiptID);
				listInfo.put("approveStatus",		(approveStatus.equals("") ? "A" : approveStatus));
				listInfo.put("dataIndex",			(dataIndex.equals("") ? "AUT" : dataIndex));
				listInfo.put("sendDate",			sendDate);
				listInfo.put("itemNo",				itemNo);
				listInfo.put("cardNo",				cardNo);
				listInfo.put("infoIndex",			infoIndex);
				listInfo.put("infoType",			infoType);
				listInfo.put("cardCompIndex",		cardCompIndex);
				listInfo.put("cardRegType",			cardRegType);
				listInfo.put("cardType",			cardType);
				listInfo.put("bizPlaceNo",			bizPlaceNo);
				listInfo.put("dept",				dept);
				listInfo.put("cardUserCode",		cardUserCode);
				listInfo.put("useDate",				(useDate.equals("") ? approveDate : useDate));
				listInfo.put("approveDate",			approveDate);
				listInfo.put("approveTime",			approveTime);
				listInfo.put("approveNo",			approveNo);
				listInfo.put("withdrawDate",		withdrawDate);
				listInfo.put("countryIndex",		countryIndex);
				listInfo.put("amountSign",			amountSign);
				listInfo.put("amountWon",			amountWon);
				listInfo.put("foreignCurrency",		foreignCurrency);
				listInfo.put("amountForeign",		amountForeign);
				listInfo.put("storeRegNo",			storeRegNo);
				listInfo.put("storeName",			storeName);
				listInfo.put("storeNo",				storeNo);
				listInfo.put("storeRepresentative",	storeRepresentative);
				listInfo.put("storeCondition",		storeCondition);
				listInfo.put("storeCategory",		storeCategory);
				listInfo.put("storeZipCode",		storeZipCode);
				listInfo.put("storeAddress1",		storeAddress1);
				listInfo.put("storeAddress2",		storeAddress2);
				listInfo.put("storeTel",			storeTel);
				listInfo.put("storeStatus",			storeStatus);
				listInfo.put("repAmount",			repAmount);
				listInfo.put("taxAmount",			taxAmount);
				listInfo.put("serviceAmount",		serviceAmount);
				listInfo.put("active",				(active.equals("") ? "N" : active));
				listInfo.put("intDate",				intDate);
				listInfo.put("collNo",				collNo);
				listInfo.put("taxType",				taxType);
				listInfo.put("taxTypeDate",			taxTypeDate);
				listInfo.put("merchCessDate",		merchCessDate);
				listInfo.put("class1",				class1);
				listInfo.put("tossUserCode",		tossUserCode);
				listInfo.put("tossSenderUserCode",	tossSenderUserCode);
				listInfo.put("tossDate",			tossDate);
				listInfo.put("tossComment",			tossComment);
				listInfo.put("isPersonalUse",		isPersonalUse);
				
				cardReceiptInterfaceSave(listInfo);
			}
			
			// 카드 정보 가져오기 (카드회사, 카드 소유자)
			coviMapperOne.update("account.cardReceipt.cardReceiptInterfaceUpdateCardInfo", interfaceParam);
			
			resultList.put("status",	getInterface.get("status"));
		} catch (NullPointerException e) {
			resultList.put("status",	Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			resultList.put("status",	Return.FAIL);
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : cardReceiptInterfaceSave
	 * @Description : 카드 승인 내역 동기화 저장
	 */
	private void cardReceiptInterfaceSave(CoviMap map){
		int dataDupCnt = (int) coviMapperOne.getNumber("account.cardReceipt.getCardReceiptInterfaceInsertCnt", map);
		
		if(dataDupCnt == 0){
			// ReceiptID 를 구성하는 값(카드번호, 승인번호 등)이 기존 승인 건과 동일하고 승인순번만 뒤바뀐 취소 건의 경우(*) 기존 승인 건의 ReceiptID 와 중복오류 발생. ReceiptID 에 추가 넘버링 부여.
			// 	(*) 승인순번만 뒤바뀐 취소 건의 경우 : 승인 건의 승인순번 1 --(취소/부분취소)--> 승인 건의 승인순번 2, 취소 건의 승인순번 1, 나머지 키 값은 동일
			int idDupCnt = (int) coviMapperOne.getNumber("account.cardReceipt.getCardReceiptInterfaceIdInsertCnt", map);
			if (idDupCnt > 0) map.put("receiptID", map.get("receiptID").toString() + (++idDupCnt));
			
			coviMapperOne.insert("account.cardReceipt.cardReceiptInterfaceInsert", map);
		}
		//기존 건 update 쿼리 실행 X
		/*else{
			coviMapperOne.update("account.cardReceipt.cardReceiptInterfaceUpdate", map);
		}*/
	}
	
	/**
	 * @Method Name : cardReceiptExcelUpload
	 * @Description : 법인카드 엑셀 업로드
	 */
	@Override
	public CoviMap cardReceiptExcelUpload(CoviMap params) throws Exception {
		int cnt = 0;
		CoviMap resultList	= new CoviMap();
		
		ArrayList<ArrayList<Object>> dataList = accountExcelUtil.extractionExcelData(params, 1);	// 엑셀 데이터 추출

		for (ArrayList list : dataList){
			//곻백체크
			if(	accountUtil.checkNull(list.get(0).toString()) || //카드사명
				accountUtil.checkNull(list.get(1).toString()) || //카드번호
				accountUtil.checkNull(list.get(2).toString()) || //승인일자
				accountUtil.checkNull(list.get(3).toString()) || //승인시간
				accountUtil.checkNull(list.get(10).toString()) || //공급가액
				accountUtil.checkNull(list.get(11).toString()) || //부가세
				accountUtil.checkNull(list.get(12).toString()) || //승인금액
				accountUtil.checkNull(list.get(13).toString())) { //승인번호
				resultList.put("err","nullErr");
				return resultList;
			}
		}
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		// index 
		// (0) = 카드사명 | (1) = 카드번호 | (2) = 승인일자 | (3) = 승인시간 | (4) = 가맹점(거래처) | 
		// (5) = 가맹점 번호 | (6) = 대표자명 | (7) = 사업자등록번호 | (8) = 전화번호 | (9) = 주소  |
		// (10) = 공급가액 | (11) = 부가세 | (12) = 승인금액 | (13) = 승인번호
		
		for (ArrayList list : dataList) { // 추가
			String cardCompanyName = list.get(0) == null ? "" : list.get(0).toString(); //카드사명
			String cardNo = list.get(1) == null ? "" : list.get(1).toString(); //카드번호
			String approveDate = list.get(2) == null ? "" : list.get(2).toString().replaceAll("/", "").replaceAll("[.]", "").replaceAll("-", ""); //승인일자
			String approveTime = list.get(3) == null ? "" : list.get(3).toString().replaceAll(":", ""); //승인시간
			String storeName = list.get(4) == null ? "" : list.get(4).toString(); //가맹점(거래처)
			String storeNo = list.get(5) == null ? "" : list.get(5).toString();//가맹점 번호
			String storeRepresentative = list.get(6) == null ? "" : list.get(6).toString();//대표자명
			String storeRegNo = list.get(7) == null ? "" : list.get(7).toString(); //사업자등록번호
			String storeTel = list.get(8) == null ? "" : list.get(8).toString(); //전화번호
			String storeAddress1 = list.get(9) == null ? "" : list.get(9).toString(); //주소
			String repAmount = list.get(10) == null ? "" : list.get(10).toString(); //공급가액
			String taxAmount = list.get(11) == null ? "" : list.get(11).toString();//부가세
			String amountWon = list.get(12) == null ? "" : list.get(12).toString();//승인금액
			String approveNo = list.get(13) == null ? "" : list.get(13).toString(); //승인번호
			String receiptID = approveDate + approveTime + approveNo; //내부승인관리번호(승인일자 + 승인시간 + 승인번호)

			CoviMap cardUser = null; //카드소유자 정보
			CoviMap searchStr = new CoviMap();
			
			//카드사명으로 검색해서 코드번호 select
			searchStr.put("codeGroup", "CardCompany");
			searchStr.put("codeName", cardCompanyName);
			String cardCompIndex = baseCodeSvc.selectBaseCodeByCodeName(searchStr); // 회사코드
			
			//카드번호로 검색해서 소유자정보 select
			searchStr.put("cardNo", cardNo);
			cardUser = coviMapperOne.selectOne("account.cardReceipt.getCorpCardOwnerInfo" , searchStr);
			
			params.put("ReceiptID", receiptID); //내부승인관리번호
			params.put("ApproveStatus", "A"); //결재구분
			params.put("DataIndex", "AUT"); //구분자#BUY:매입,BIL:청구,AUT:승인
			params.put("CardNo", cardNo); //카드번호
			params.put("InfoIndex", "A"); //정보구분#A:승인,B:매입,C:승인취소
			params.put("CardCompIndex", cardCompIndex); //카드사구분
			params.put("Dept", cardUser.getString("DeptCode")); //카드소유자의부서코드
			params.put("CardUserCode", cardUser.getString("OwnerUserCode")); //카드소유자코드
			params.put("UseDate", approveDate); //카드사용일자
			params.put("ApproveDate", approveDate); //카드승인일자
			params.put("ApproveTime", approveTime); //카드승인시각
			params.put("ApproveNo", approveNo); //카드승인번호
			params.put("AmountWon", amountWon); //총금액
			params.put("StoreRegNo", storeRegNo); //가맹점사업자번호
			params.put("StoreName", storeName); //가맹점(거래처)
			params.put("StoreNo", storeNo); //가맹점 번호
			params.put("StoreRepresentative", storeRepresentative); //가맹점대표자
			params.put("StoreAddress1", storeAddress1); //가맹점주소
			params.put("StoreAddress2", ""); //가맹점주소
			params.put("StoreTel", storeTel); //가맹점전화번호
			params.put("RepAmount", repAmount); //공급가액
			params.put("TaxAmount", taxAmount); //부가세
			params.put("ServiceAmount", 0); //봉사료
			params.put("Active", "N"); //정산처리여부#N:미정산,Y:정산서작성중,I:정산서상신완료
			params.put("Class", "A"); //구분#일시불,할부
			
			//이미 등록되어있는 ReceiptID이면 업데이트
			cnt = (int) coviMapperOne.getNumber("account.cardReceipt.getCardReceiptCnt", params); // ID체크(등록/수정)
			if(cnt == 0){ // 추가
				coviMapperOne.insert("account.cardReceipt.insertCardReceipt", params);
			} else{ // 수정
				coviMapperOne.update("account.cardReceipt.updateCardReceipt", params);
			}
		}
		
		return resultList;
	}
	
	/**
	 * @Method Name : getSendDelayCorpCardList
	 * @Description : 개인카드 청구내역 목록 조회
	 */
	@Override
	public CoviMap getSendDelayCorpCardList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		String UserName = "";
		String SearchName = "";
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		params.put("UR_Code",		SessionHelper.getSession("UR_Code"));
		params.put("approveDateS",		params.get("approveDateS"));
		params.put("approveDateE",		params.get("approveDateE"));
		params.put("cardClass",		params.get("cardClass"));
		params.put("companyCode",		params.get("companyCode"));
		params.put("cardNo",		params.get("cardNo"));
		
		cnt		= (int) coviMapperOne.getNumber("account.cardReceipt.getSendDelayCorpCardListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.cardReceipt.getSendDelayCorpCardList", params);
		for (int j =0 ; j < list.size(); j++)
		{
			CoviMap newObject = (CoviMap)list.get(j);
			UserName = newObject.getString("OwnerUser").split(",")[1].split(";")[0] + "(" + newObject.getString("OwnerUser").split(",")[2].split(";")[0] + ")";
			SearchName = newObject.getString("SearchUser");
			
			if(!SearchName.equals("")) {
				SearchName = makeSearchName(newObject.getString("SearchUser"));
			}
			
			//insertObject.put("UserName", UserName);
			newObject.put("UserName", UserName);
			//insertObject.put("SearchName", SearchName);
			newObject.put("SearchName", SearchName);
			
			UserName = "";
			SearchName = "";
		}
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	/**
	 * @Method Name : getCardCompare
	 * @Description : 법인카드 사용내역 대사
	 */
	@Override
	public CoviMap getCardCompare(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		cnt		= (int) coviMapperOne.getNumber("account.cardReceipt.getCardCompareListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.cardReceipt.getCardCompareList", params);
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	private String makeSearchName(String SearchUser) {
		if("".equals(SearchUser) || SearchUser == null) {
			return "";
		}
		
		StringBuilder rslt = new StringBuilder();
		String[] arrStepOne = SearchUser.split("n%");
		for(int i=0; i<arrStepOne.length; i++) {
			if(!StringUtil.isEmpty(arrStepOne[i])) {
				//rslt += arrStepOne[i].split(",")[1].split(";")[0] + "(" + arrStepOne[i].split(",")[2].split(";")[0] + "), ";
				if(rslt.length() > 0) {
					rslt.append(", ");
				}
				rslt.append(arrStepOne[i].split(",")[1].split(";")[0])
					.append("(" + arrStepOne[i].split(",")[2].split(";")[0])
					.append(")");
			}
		}
		
		return rslt.toString();
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
	
	private String setNegative(String pStr){
		String rtStr = pStr;
		double rtDouble;
		try {
			rtDouble = Double.parseDouble(pStr);
			if(rtDouble > 0) {
				if((int)rtDouble == rtDouble) {
					rtStr = Integer.toString((int)rtDouble*-1);
				}else {
					rtStr = Double.toString(rtDouble*-1);
				}
			}
		} catch(NumberFormatException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return rtStr;
	}
}
