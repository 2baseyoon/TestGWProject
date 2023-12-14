package egovframework.coviaccount.user.service.impl;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.interfaceUtil.interfaceVO.CardReceiptVO;
import egovframework.coviaccount.interfaceUtil.interfaceVO.TaxInvoiceVO;
import egovframework.coviaccount.user.service.AccountPortalSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

/**
 * @Class Name : AccountPortalSvcImpl.java
 * @Description : 경비신청
 * @Modification Information 
 * @author Covision
 * @ 2018.07.23 최초생성
 */
@Service("accountPortalSvcImpl")
public class AccountPortalSvcImpl extends EgovAbstractServiceImpl implements AccountPortalSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	@Override
	/**
	 * 포탈 메인정보 조회
	 */
	public CoviMap searchPortalMainData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));

		//String PropertyCardReceipt = accountUtil.getPropertyInfo("account.searchType.CardReceipt");
		//String PropertyTaxInvoice = accountUtil.getPropertyInfo("account.searchType.TaxInvoice");		
		String PropertyCardReceipt = accountUtil.getBaseCodeInfo("eAccSearchType", "CardReceipt");
		String PropertyTaxInvoice = accountUtil.getBaseCodeInfo("eAccSearchType", "TaxInvoice");

		List CCList = null;
		int CCCnt = 0;
		if("".equals(PropertyCardReceipt)){
			CCList = coviMapperOne.selectList("accountPortal.selectPortalCorpCardList", params);
			CCCnt = (int)(long)coviMapperOne.selectOne("accountPortal.selectPortalCorpCardListCnt", params);
		}else{
			CoviMap CCIF = getCCIFData();
			CCList = (List)AccountUtil.jobjGetObj(CCIF,"list");
			CCCnt = (int)AccountUtil.jobjGetObj(CCIF,"cnt");
		}
		List TIList = null;
		int TICnt = 0;
		if("".equals(PropertyTaxInvoice)){
			TIList = coviMapperOne.selectList("accountPortal.selectTaxInvioceList", params);
			TICnt = (int)(long)coviMapperOne.selectOne("accountPortal.selectTaxInvioceListCnt", params);
		}else{
			CoviMap TIIF = getTXIFData();
			TIList = (List)AccountUtil.jobjGetObj(TIIF,"list");
			TICnt = (int)AccountUtil.jobjGetObj(TIIF,"cnt");
		}
		List EAList = coviMapperOne.selectList("accountPortal.selectExpAppAprvList", params);
		CoviMap Deadline = coviMapperOne.selectOne("accountPortal.selectDeadlineInfo", params);
		List CCInfoList = coviMapperOne.selectList("accountPortal.selectCorpCardUseInfoList", params);
		
		int EACnt = (int)(long)coviMapperOne.selectOne("accountPortal.selectExpAppAprvListCnt", params);
		

		resultList.put("CorpCardList", AccountUtil.convertNullToSpace(CCList));
		resultList.put("ExpAppList", AccountUtil.convertNullToSpace(EAList));
		resultList.put("TaxInvoiveList", AccountUtil.convertNullToSpace(TIList));
		resultList.put("DeadlineInfo", Deadline);
		resultList.put("CorpCardInfoList", AccountUtil.convertNullToSpace(CCInfoList));
		
		resultList.put("CorpCardListCnt", CCCnt);
		resultList.put("ExpAppListCnt", EACnt);
		resultList.put("TaxInvoiveListCnt", TICnt);
		
		return resultList;
	}
	

	public CoviMap getCCIFData() throws Exception {
		CoviMap retObj = new CoviMap();

		//String PropertyCardReceipt = accountUtil.getPropertyInfo("account.searchType.CardReceipt");		
		String PropertyCardReceipt = accountUtil.getBaseCodeInfo("eAccSearchType", "CardReceipt");
		
		int cnt=0;
		CoviList list			= new CoviList();
		SimpleDateFormat sdf = new SimpleDateFormat("YYYYMMdd");
		SimpleDateFormat sdfStr = new SimpleDateFormat("YYYY.MM.dd");
		SimpleDateFormat sdfM = new SimpleDateFormat("YYYY.MM");
		Date today = new Date();
		Calendar cal = Calendar.getInstance();
		cal.setTime(today);
		cal.set(Calendar.DATE, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
		
		CoviMap interfaceParam	= new CoviMap();
		interfaceParam.put("mapFunctionName",	"getSoapMap");
		interfaceParam.put("soapName",			"XpenseGetCardReceiptList");
		interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetCardReceiptList");
		

		String pApproveDateS	= rtString(sdfM.format(cal.getTime())+".01");
		String pApproveDateE	= rtString(sdfStr.format(cal.getTime()));
		
		//String pApproveDateS	= rtString("2016.12.01");
		//String pApproveDateE	= rtString("2016.12.30");
				
		
		pApproveDateS = pApproveDateS.replaceAll("[^0-9]", "-");
		pApproveDateE = pApproveDateE.replaceAll("[^0-9]", "-");
		
		CoviMap xmlParam = new CoviMap();
		

		int pageSize = 5;
		int pageNo = 1;
		
		xmlParam.put("pPageSize",			pageSize);
		xmlParam.put("pPageCurrent",		pageNo);
		
		if(!pApproveDateS.equals("")){	xmlParam.put("pSDate",		pApproveDateS);}
		if(!pApproveDateE.equals("")){	xmlParam.put("pEDate",		pApproveDateE);}
		//if(!pCardUserCode.equals("")){	xmlParam.put("pCarduser",	pCardUserCode);}
		//if(!pCardNo.equals("")){		xmlParam.put("pCardNo",		pCardNo);}
		
		interfaceParam.put("xmlParam",		xmlParam);

		interfaceParam.put("interFaceType",			PropertyCardReceipt);
		
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
			
			approveDate	= approveDate.replaceAll("[^0-9]",	".");
			amountWon	= amountWon.substring(0, amountWon.indexOf("."));
			repAmount	= repAmount.substring(0, repAmount.indexOf("."));
			taxAmount	= taxAmount.substring(0, taxAmount.indexOf("."));
			
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

			
			//////

			listInfo.put("isIF",		"Y");
			listInfo.put("ProofCode",		"CorpCard");
			listInfo.put("CardUID",		receiptID);
			listInfo.put("CardApproveNo",		approveNo);
			listInfo.put("TotalAmount",		amountWon);
			listInfo.put("ProofDate",		sdf.format(today));
			listInfo.put("ProofDateStr",		sdfStr.format(today));
			listInfo.put("StoreAddress",		storeAddress1+storeAddress2);
			list.add(listInfo);
		}
	
		

		CoviMap infoMap = new CoviMap();
		
		for(int i = 0; i<list.size(); i++){
			Map getInfo = (Map) list.get(i);
			String ReceiptID = mapGetStr(getInfo, "ReceiptID");
			infoMap.put(ReceiptID, getInfo);
		}
		retObj.put("list", list);
		retObj.put("cnt", cnt);
		
		return retObj;
	}

	public CoviMap getTXIFData() throws Exception {
		CoviMap retObj = new CoviMap();
		
		//String PropertyTaxInvoice = accountUtil.getPropertyInfo("account.searchType.TaxInvoice");		
		String PropertyTaxInvoice = accountUtil.getBaseCodeInfo("eAccSearchType", "TaxInvoice");
		
		int cnt=0;
		CoviList list			= new CoviList();
		SimpleDateFormat sdfStr = new SimpleDateFormat("YYYY.MM.dd");
		SimpleDateFormat sdfM = new SimpleDateFormat("YYYY.MM");
		Date today = new Date();
		Calendar cal = Calendar.getInstance();
		cal.setTime(today);
		cal.set(Calendar.DATE, cal.getActualMaximum(Calendar.DAY_OF_MONTH));

		CoviMap interfaceParam	= new CoviMap();
		interfaceParam.put("mapFunctionName",	"getSoapMap");
		interfaceParam.put("soapName",			"XpenseGetTaxBillList");
		interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetTaxBillList");

		String stdt	= rtString(sdfM.format(cal.getTime())+".01");
		String eddt	= rtString(sdfStr.format(cal.getTime()));

		//String stdt	= rtString("2016.01.01");
		//String eddt	= rtString("2016.01.30");
		String pSDate	= rtString(stdt);
		String pEDate	= rtString(eddt);
		
		CoviMap xmlParam = new CoviMap();
		
		xmlParam.put("pPageSize",		"5");
		xmlParam.put("pPageCurrent",	"1");
		xmlParam.put("pSDate",			pSDate);
		xmlParam.put("pEDate",			pEDate);
		xmlParam.put("pVendorNo",		"");
		xmlParam.put("pVendorName",		"");
		xmlParam.put("pExistNo",		"");
		xmlParam.put("pUserID",			"");
	      
		interfaceParam.put("xmlParam", xmlParam);
		
		

		
		interfaceParam.put("interFaceType",			PropertyTaxInvoice);
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
			
			String WriteDateConvert = "";
			if(writeDate.indexOf("T") > 0){
				WriteDateConvert = writeDate.substring(0,writeDate.indexOf("T"));
			}else{
				WriteDateConvert = writeDate;
			}
			WriteDateConvert = WriteDateConvert.replaceAll("[^0-9]", "");
			
			//MAIN
			listInfo.put("TaxInvoiceID",			taxInvoiceID);
			listInfo.put("CompanyCode",				companyCode);
			listInfo.put("DataIndex",				sUPBUY_TYPE);
			listInfo.put("WriteDate",				WriteDateConvert);
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
			
			
			
		retObj.put("list", list);
		retObj.put("cnt", cnt);
		
		return retObj;
	}

	public String mapGetStr(Map params, String key) {
		String retVal = "";
		if(params.get(key) != null){
			retVal = params.get(key).toString();
		}
		return retVal;
	}
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}
}
