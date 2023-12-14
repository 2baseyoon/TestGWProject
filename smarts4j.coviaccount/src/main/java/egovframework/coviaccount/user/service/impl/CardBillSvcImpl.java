package egovframework.coviaccount.user.service.impl;

import java.lang.invoke.MethodHandles;
import java.util.ArrayList;

import javax.annotation.Resource;



import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.ComUtils;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.service.CommonSvc;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.interfaceUtil.interfaceVO.CardBillVO;
import egovframework.coviaccount.user.service.CardBillSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("CardBillSvcSvc")
public class CardBillSvcImpl extends EgovAbstractServiceImpl implements CardBillSvc {
	
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
	private CommonSvc commonSvc;
	
	//CardBill - Start
	
	/**
	 * @Method Name : getCardBillList
	 * @Description : 법인카드 청구내역 목록 조회
	 */
	@Override
	public CoviMap getCardBillList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);

		cnt		= (int) coviMapperOne.getNumber("account.cardBill.getCardBillListCnt" , params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("account.cardBill.getCardBillList", params);
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getCardBillExcelList
	 * @Description : 법인카드 청구내역 엑셀 다운로드
	 */
	@Override
	public CoviMap getCardBillExcelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		CoviList list		= coviMapperOne.list("account.cardBill.getCardBillExcelList", params);
		int cnt				= (int) coviMapperOne.getNumber("account.cardBill.getCardBillListCnt" , params);
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : getCardBillmmSumAmountWon
	 * @Description : 법인카드 청구내역 월간 합계 금액
	 */
	@Override
	public CoviMap getCardBillmmSumAmountWon(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviList sum		= coviMapperOne.list("account.cardBill.getCardBillmmSumAmountWon", params);
		resultList.put("sum",	sum);
		return resultList; 
	}
	
	/**
	 * @Method Name : cardBillSync
	 * @Description : 법인카드 청구내역 동기화
	 */
	@Override
	public CoviMap cardBillSync(){

		CoviMap interfaceParam	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		CardBillVO cardBillVO	= null;
		
		try{
			//String syncType = accountUtil.getPropertyInfo("account.syncType.CardBill");
			String syncType = accountUtil.getBaseCodeInfo("eAccSyncType", "CardBill");
			
			interfaceParam.put("interFaceType",			syncType);
	
			interfaceParam.put("daoClassName",			"CardBillDao");
			interfaceParam.put("voClassName",			"CardBillVO");
			interfaceParam.put("mapClassName",			"CardBillMap");
	
			interfaceParam.put("daoSetFunctionName",	"setCardBillList");
			interfaceParam.put("daoGetFunctionName",	"getCardBillList");
			interfaceParam.put("voFunctionName",		"setAll");
			interfaceParam.put("mapFunctionName",		"getMap");
	
			switch (syncType) {
				case "DB":
					//syncType이 DB인 경우 이곳에 정의
					interfaceParam.put("type",		"get");
					interfaceParam.put("sqlName",	"accountInterFace.AccountSI.getInterFaceListCardBill");
					break;
		
				case "SOAP":
					//syncType이 SOAP인 경우 이곳에 정의
					break;
					
				case "SAP":
					//syncType이 SAP인 경우 이곳에 정의
					break;
					
				default : 
					break;
			}
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
	
			ArrayList list = (ArrayList) getInterface.get("list");
	
			String sessionUser = SessionHelper.getSession("UR_Code");
			
			String companyCode = commonSvc.getCompanyCodeOfUser(sessionUser);
	
			for (int i = 0; i < list.size(); i++) {
				CoviMap listInfo = new CoviMap();
				cardBillVO = (CardBillVO) list.get(i);
				String sendDate			= cardBillVO.getSendDate();			String itemNo				= cardBillVO.getItemNo();
				String cardNo			= cardBillVO.getCardNo();			String infoIndex			= cardBillVO.getInfoIndex();
				String infoType			= cardBillVO.getInfoType();			String cardCompIndex		= cardBillVO.getCardCompIndex();
				String cardRegType		= cardBillVO.getCardRegType();		String cardType				= cardBillVO.getCardType();
				String bizPlaceNo		= cardBillVO.getBizPlaceNo();		String dept					= cardBillVO.getDept();
				String cardUserCode		= cardBillVO.getCardUserCode();		String useDate				= cardBillVO.getUseDate();
				String approveDate		= cardBillVO.getApproveDate();		String approveTime			= cardBillVO.getApproveTime();
				String approveNo		= cardBillVO.getApproveNo();		String withdrawDate			= cardBillVO.getWithdrawDate();
				String countryIndex		= cardBillVO.getCountryIndex();		String amountSign			= cardBillVO.getAmountSign();
				String amountCharge		= cardBillVO.getAmountCharge();		String amountWon			= cardBillVO.getAmountWon();
				String foreignCurrency	= cardBillVO.getForeignCurrency();	String amountForeign		= cardBillVO.getAmountForeign();
				String storeRegNo		= cardBillVO.getStoreRegNo();		String storeName			= cardBillVO.getStoreName();
				String storeNo			= cardBillVO.getStoreNo();			String storeRepresentative	= cardBillVO.getStoreRepresentative();
				String storeCondition	= cardBillVO.getStoreCondition();	String storeCategory		= cardBillVO.getStoreCategory();
				String storeZipCode		= cardBillVO.getStoreZipCode();		String storeAddress1		= cardBillVO.getStoreAddress1();
				String storeAddress2	= cardBillVO.getStoreAddress2();	String storeTel				= cardBillVO.getStoreTel();
				String repAmount		= cardBillVO.getRepAmount();		String taxAmount			= cardBillVO.getTaxAmount();
				String serviceAmount	= cardBillVO.getServiceAmount();	String paymentFlag			= cardBillVO.getPaymentFlag();
				String paymentDate		= cardBillVO.getPaymentDate();		String collNo				= cardBillVO.getCollNo();
				String classCode		= cardBillVO.getClassCode();
	
				//데이터 구조가 다른 관계로  임시로 셋팅
				sendDate		= sendDate.replaceAll("-", "");
				useDate			= useDate.replaceAll("-", "");
				approveDate		= approveDate.replaceAll("-", "");
				withdrawDate	= withdrawDate.replaceAll("-", "");
				paymentDate		= paymentDate.replaceAll("-", "");
				
				listInfo.put("UR_Code",				sessionUser);			listInfo.put("sendDate",		sendDate);
				listInfo.put("itemNo",				itemNo);				listInfo.put("cardNo",			cardNo);
				listInfo.put("infoIndex",			infoIndex);				listInfo.put("infoType",		infoType);
				listInfo.put("cardCompIndex",		cardCompIndex);			listInfo.put("cardRegType",		cardRegType);
				listInfo.put("cardType",			cardType);				listInfo.put("bizPlaceNo",		bizPlaceNo);
				listInfo.put("dept",				dept);					listInfo.put("cardUserCode",	cardUserCode);
				listInfo.put("useDate",				useDate);				listInfo.put("approveDate",		approveDate);
				listInfo.put("approveTime",			approveTime);			listInfo.put("approveNo",		approveNo);
				listInfo.put("withdrawDate",		withdrawDate);			listInfo.put("countryIndex",	countryIndex);
				listInfo.put("amountSign",			amountSign);			listInfo.put("amountCharge",	amountCharge);
				listInfo.put("amountWon",			amountWon);				listInfo.put("foreignCurrency",	foreignCurrency);
				listInfo.put("amountForeign",		amountForeign);			listInfo.put("storeRegNo",		storeRegNo);
				listInfo.put("storeName",			storeName);				listInfo.put("storeNo",			storeNo);
				listInfo.put("storeRepresentative",	storeRepresentative);	listInfo.put("storeCondition",	storeCondition);
				listInfo.put("storeCategory",		storeCategory);			listInfo.put("storeZipCode",	storeZipCode);
				listInfo.put("storeAddress1",		storeAddress1);			listInfo.put("storeAddress2",	storeAddress2);
				listInfo.put("storeTel",			storeTel);				listInfo.put("repAmount",		repAmount);
				listInfo.put("taxAmount",			taxAmount);				listInfo.put("serviceAmount",	serviceAmount);
				listInfo.put("paymentFlag",			paymentFlag);			listInfo.put("paymentDate",		paymentDate);
				listInfo.put("collNo",				collNo);				listInfo.put("classCode",		classCode);
				listInfo.put("companyCode",			companyCode);
				cardBillInterfaceSave(listInfo);
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
	 * @Method Name : cardBillInterfaceSave
	 * @Description : 법인카드 청구내역 동기화 저장
	 */
	private void cardBillInterfaceSave(CoviMap map) {
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("account.cardBill.getCardBillInterfaceSaveCnt", map);

		if (cnt == 0) {
			coviMapperOne.insert("account.cardBill.cardBillInterfaceInsert", map);
		} else {
			coviMapperOne.update("account.cardBill.cardBillInterfaceUpdate", map);
		}
	}
	
	//CardBill - End
	
	//CardBillUser - Start

	/**
	 * @Method Name : getCardBillUserList
	 * @Description : 법인카드 청구내역 [사용자] 목록 조회
	 */
	@Override
	public CoviMap getCardBillUserList(CoviMap params) throws Exception {
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
		
		cnt		= (int) coviMapperOne.getNumber("account.cardBill.getCardBillUserListCnt" , params);
		
		page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list	= coviMapperOne.list("account.cardBill.getCardBillUserList", params);
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : getCardBillUserExcelList
	 * @Description : 법인카드 청구내역 [사용자] 엑셀 다운로드
	 */
	@Override
	public CoviMap getCardBillUserExcelList(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		CoviList list		= coviMapperOne.list("account.cardBill.getCardBillUserExcelList", params);
		int cnt				= (int) coviMapperOne.getNumber("account.cardBill.getCardBillUserListCnt" , params);
		String headerKey	= params.get("headerKey").toString();
		
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : getCardBillmmSumAmountWonUser
	 * @Description : 법인카드 청구내역 [사용자] 월간 금액 합계
	 */
	@Override
	public CoviMap getCardBillmmSumAmountWonUser(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		CoviList sum		= coviMapperOne.list("account.cardBill.getCardBillmmSumAmountWon", params);
		resultList.put("sum",	sum);
		return resultList; 
	}
	//CardBillUser - End
}
