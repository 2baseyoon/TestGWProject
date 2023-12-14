package egovframework.coviaccount.user.service.impl;

import java.lang.invoke.MethodHandles;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
import egovframework.coviaccount.interfaceUtil.interfaceVO.CashBillVO;
import egovframework.coviaccount.interfaceUtil.interfaceVO.TaxInvoiceVO;
import egovframework.coviaccount.user.service.TaxInvoiceSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("TaxInvoiceSvc")
public class TaxInvoiceSvcImpl extends EgovAbstractServiceImpl implements TaxInvoiceSvc {
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private AccountExcelUtil accountExcelUtil;
	
	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	/**
	 * @Method Name : getTaxInvoiceList
	 * @Description : 매입수신내역 목록 조회
	 */
	@Override
	public CoviMap getTaxInvoiceList(CoviMap params) throws Exception {
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
					cnt		= (int) coviMapperOne.getNumber("account.taxInvoice.getTaxInvoiceListCnt" , params);
					
					page 	= ComUtils.setPagingData(params,cnt);
					params.addAll(page);
					
					list	= coviMapperOne.list("account.taxInvoice.getTaxInvoiceList", params);
					
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
			
			TaxInvoiceVO taxInvoiceVO = new TaxInvoiceVO();
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
			
			ArrayList arrayList = (ArrayList) getInterface.get("list");
			for (int i = 0; i < arrayList.size(); i++) {
				CoviMap listInfo = new CoviMap();
				
				taxInvoiceVO = (TaxInvoiceVO) arrayList.get(i);

				String writeDate			= taxInvoiceVO.getWriteDate();
				String nTSConfirmNum		= taxInvoiceVO.getnTSConfirmNum();
				String invoicerCorpName		= taxInvoiceVO.getInvoicerCorpName();
				String invoicerCorpNum		= taxInvoiceVO.getInvoicerCorpNum();
				String invoicerContactName	= taxInvoiceVO.getInvoicerContactName();
				String totalAmount			= taxInvoiceVO.getTotalAmount();
				String supplyCostTotal		= taxInvoiceVO.getSupplyCostTotal();
				String taxTotal				= taxInvoiceVO.getTaxTotal();
				String invoiceeEmail1		= taxInvoiceVO.getInvoiceeEmail1();
				String remark1				= taxInvoiceVO.getRemark1();
				String modifyName			= taxInvoiceVO.getModifyCode();
				String orgNTSConfirmNum		= taxInvoiceVO.getOrgNTSConfirmNum();

				String totalCount			= taxInvoiceVO.getTotal();
				
				if(nTSConfirmNum.equals("")){
					continue;
				}
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				//데이터 구조가 다른 관계로  임시로 셋팅
				if(writeDate.indexOf("T")>0){
					writeDate = writeDate.substring(0,writeDate.indexOf("T"));
				}
				writeDate = writeDate.replaceAll("[^0-9]", ".");
				
				cnt = Integer.parseInt(totalCount);
				
				listInfo.put("WriteDate",			writeDate);
				listInfo.put("TaxTotal",			taxTotal);
				listInfo.put("SupplyCostTotal",		supplyCostTotal);
				listInfo.put("TotalAmount",			totalAmount);
				listInfo.put("Remark1",				remark1);
				listInfo.put("NTSConfirmNum",		nTSConfirmNum);
				listInfo.put("OrgNTSConfirmNum",	orgNTSConfirmNum);
				listInfo.put("InvoicerCorpNum",		invoicerCorpNum);
				listInfo.put("InvoicerCorpName",	invoicerCorpName);
				listInfo.put("InvoicerContactName",	invoicerContactName);
				listInfo.put("InvoiceeEmail1",		invoiceeEmail1);
				listInfo.put("ModifyName",			modifyName);
				
				list.add(listInfo);
			}
		}
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	 * @Method Name : taxInvoiceExcelDownload
	 * @Description : 매입수신내역 엑셀 다운로드
	 */
	@Override
	public CoviMap taxInvoiceExcelDownload(CoviMap params) throws Exception{
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
					interfaceParam.put("soapName",			"XpenseGetTaxBillList");
					interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetTaxBillList");
				      
					String pSDate	= rtString(params.get("writeDateS"));
					String pEDate	= rtString(params.get("writeDateE"));

					CoviMap xmlParam = new CoviMap();
					
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
					list	= coviMapperOne.list("account.taxInvoice.getTaxInvoiceExcelList", params);
					cnt		= (int) coviMapperOne.getNumber("account.taxInvoice.getTaxInvoiceListCnt" , params);
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
			
			TaxInvoiceVO taxInvoiceVO = new TaxInvoiceVO();
			
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
			
			ArrayList arrayList = (ArrayList) getInterface.get("list");
			for (int i = 0; i < arrayList.size(); i++) {
				CoviMap listInfo = new CoviMap();
				
				taxInvoiceVO = (TaxInvoiceVO) arrayList.get(i);
				String writeDate			= taxInvoiceVO.getWriteDate();
				String nTSConfirmNum		= taxInvoiceVO.getnTSConfirmNum();
				String invoicerCorpName		= taxInvoiceVO.getInvoicerCorpName();
				String invoicerCorpNum		= taxInvoiceVO.getInvoicerCorpNum();
				String invoicerContactName	= taxInvoiceVO.getInvoicerContactName();
				String totalAmount			= taxInvoiceVO.getTotalAmount();
				String supplyCostTotal		= taxInvoiceVO.getSupplyCostTotal();
				String taxTotal				= taxInvoiceVO.getTaxTotal();
				String invoiceeEmail1		= taxInvoiceVO.getInvoiceeEmail1();
				String invoiceEmail2		= taxInvoiceVO.getInvoiceEmail2();
				String remark1				= taxInvoiceVO.getRemark1();
				String modifyName			= taxInvoiceVO.getModifyCode();
				String orgNTSConfirmNum		= taxInvoiceVO.getOrgNTSConfirmNum();
				
				String totalCount			= taxInvoiceVO.getTotal();
				
				if(nTSConfirmNum.equals("")){
					continue;
				}
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				writeDate = writeDate.substring(0,writeDate.indexOf("T")).replaceAll("[^0-9]", ".");
				
				//데이터 구조가 다른 관계로  임시로 셋팅
				cnt = Integer.parseInt(totalCount);
				
				listInfo.put("WriteDate",			writeDate);
				listInfo.put("TaxTotal",			taxTotal);
				listInfo.put("SupplyCostTotal",		supplyCostTotal);
				listInfo.put("TotalAmount",			totalAmount);
				listInfo.put("Remark1",				remark1);
				listInfo.put("NTSConfirmNum",		nTSConfirmNum);
				listInfo.put("OrgNTSConfirmNum",	orgNTSConfirmNum);
				listInfo.put("InvoicerCorpNum",		invoicerCorpNum);
				listInfo.put("InvoicerCorpName",	invoicerCorpName);
				listInfo.put("InvoicerContactName",	invoicerContactName);
				listInfo.put("InvoiceeEmail1",		invoiceeEmail1);
				listInfo.put("InvoiceEmail2",		invoiceEmail2);
				listInfo.put("ModifyName",			modifyName);
				
				list.add(listInfo);
			}
		}
		
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt",	cnt);
		return resultList;
	}
	
	/**
	 * @Method Name : saveIsOffset
	 * @Description : 매입수신내역 개인사용 유무 저장
	 */
	@Override
	public CoviMap saveIsOffset(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		ArrayList<Map<String, Object>> chkList	= (ArrayList<Map<String, Object>>) params.get("chkList");

		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		if(chkList.size() > 0){
			for(int i=0; i <chkList.size(); i++){
				CoviMap info = new CoviMap(chkList.get(i));
				params.put("taxInvoiceID", info.get("TaxInvoiceID"));
				updateIsOffset(params);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : updateIsOffset
	 * @Description : 매입수신내역 개인사용 유무 Update
	 */
	public void updateIsOffset(CoviMap params)throws Exception {
		coviMapperOne.update("account.taxInvoice.updateIsOffset", params);
	}
	
	/**
	 * @Method Name : saveExpence
	 * @Description : 전표번호등록
	 */
	@Override
	public CoviMap saveExpence(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		ArrayList<Map<String, Object>> chkList	= (ArrayList<Map<String, Object>>) params.get("chkList");

		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		if(chkList.size() > 0){
			for(int i=0; i <chkList.size(); i++){
				CoviMap info = new CoviMap(chkList.get(i));
				params.put("taxInvoiceID", info.get("TaxInvoiceID"));
				updateExpence(params);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : updateIsOffset
	 * @Description : 매입수신내역 개인사용 유무 Update
	 */
	public void updateExpence(CoviMap params)throws Exception {
		coviMapperOne.update("account.taxInvoice.updateExpence", params);
	}
	
	/**
	 * @Method Name : saveTaxInvoiceTossUser
	 * @Description : 매입수신내역 전달 사용자 저장
	 */
	@Override
	public CoviMap saveTaxInvoiceTossUser(CoviMap params)throws Exception {
		CoviMap resultList	= new CoviMap();
		ArrayList<Map<String, Object>> chkList	= (ArrayList<Map<String, Object>>) params.get("chkList");

		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		if(chkList.size() > 0){
			for(int i=0; i <chkList.size(); i++){
				CoviMap info = new CoviMap(chkList.get(i));
				params.put("taxInvoiceID", info.get("TaxInvoiceID"));
				updateTaxInvoiceTossUser(params);
			}
		}
		return resultList;
	}
	
	/**
	 * @Method Name : updateTaxInvoiceTossUser
	 * @Description : 매입수신내역 전달 사용자 Update
	 */
	public void updateTaxInvoiceTossUser(CoviMap params)throws Exception {
		coviMapperOne.update("account.taxInvoice.updateTaxInvoiceTossUser", params);
	}

	/**
	 * @Method Name : taxInvoiceSync
	 * @Description : 매입수신내역 동기화
	 */
	@Override
	public CoviMap taxInvoiceSync(CoviMap params){

		CoviList coviList			= new CoviList();
		CoviMap interfaceParam		= new CoviMap();
		CoviMap resultList		= new CoviMap();
		TaxInvoiceVO taxInvoiceVO	= new TaxInvoiceVO();
		
		// Copy parameter from Controller.
		for(Object o : params.entrySet()) {
			Entry entry = (Entry)o;
			interfaceParam.put(entry.getKey(), entry.getValue());
		}
	    InterfaceUtil.setCurrentRequestAttr("DN_ID", interfaceParam.getString("DN_ID"));
		
		try {
			//String syncType = accountUtil.getPropertyInfo("account.syncType.TaxInvoice");
			String syncType = accountUtil.getBaseCodeInfo("eAccSyncType", "TaxInvoice", (String)InterfaceUtil.getCurrentRequestAttr("DN_ID"));
			
			interfaceParam.put("interFaceType",			syncType);
			interfaceParam.put("daoClassName",			"TaxInvoiceDao");
			interfaceParam.put("voClassName",			"TaxInvoiceVO");
			interfaceParam.put("mapClassName",			"TaxInvoiceMap");
	
			interfaceParam.put("daoSetFunctionName",	"setTaxInvoiceList");
			interfaceParam.put("daoGetFunctionName",	"getTaxInvoiceList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			switch (syncType) {
				case "DB":
					//syncType이 DB인 경우 이곳에 정의
					
					//String taxInvoiceDBType = rtString(accountUtil.getPropertyInfo("account.searchDBType.TaxInvoice"));
					String taxInvoiceDBType = rtString(accountUtil.getBaseCodeInfo("eAccDBType", "TaxInvoice", (String)InterfaceUtil.getCurrentRequestAttr("DN_ID")));
					
					String sqlName			= "";
					String mapFunctionName	= "";
					if(taxInvoiceDBType.equals("InfoTech")){
						mapFunctionName	= "getInfoTechDBMap";
						sqlName			= "accountInterFace.Account4JIF.getInterFaceListTaxInvoiceInfoTech";
					}else if(taxInvoiceDBType.equals("UniPost")){
						mapFunctionName	= "getDBMap";
						sqlName			= "accountInterFace.AccountSI.getInterFaceListTaxInvoiceUni";
					}else if(taxInvoiceDBType.equals("Kwic")) {
						mapFunctionName	= "getKwicDBMap";
						sqlName			= "accountInterFace.Account4JIF.getInterFaceListTaxInvoiceKwic";

						String[] bizNumList = RedisDataUtil.getBaseConfig("BizNumber",(String)InterfaceUtil.getCurrentRequestAttr("DN_ID")).split(";");
						interfaceParam.put("BizNumberList", bizNumList);

						interfaceParam.put("AccountBatchDay", RedisDataUtil.getBaseConfig("AccountBatchDay", params.getString("DN_ID")));
												
					}else{
						mapFunctionName	= "getDBMap";
						sqlName			= "accountInterFace.Account4JIF.getInterFaceListTaxInvoice";
					}
					
					interfaceParam.put("mapFunctionName",	mapFunctionName);
					interfaceParam.put("type",				"get");
					interfaceParam.put("sqlName",			sqlName);
					break;
		
				case "SOAP":
					//syncType이 SOAP인 경우 이곳에 정의
						CoviMap xmlParam = new CoviMap();
						xmlParam.put("pSDate",			"");
						xmlParam.put("pEDate",			"");
						xmlParam.put("pVendorNo",		"");
						xmlParam.put("pVendorName",		"");
						xmlParam.put("pExistNo",		"");
						xmlParam.put("pUserID",			"");
						
						interfaceParam.put("xmlParam",			xmlParam);
						interfaceParam.put("mapFunctionName",	"getSoapMap");
						interfaceParam.put("soapName",			"XpenseGetTaxBillList");
						interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetTaxBillList");
					
					break;
					
				case "SAP":
					//syncType이 SAP인 경우 이곳에 정의
					break;
			}
	
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
	
			ArrayList list = (ArrayList) getInterface.get("list");
	
			String sessionUser = SessionHelper.getSession("UR_Code");
			for (int i = 0; i < list.size(); i++) {
				CoviMap listInfo = new CoviMap();
				taxInvoiceVO = (TaxInvoiceVO) list.get(i);
	
				String companyCode			= taxInvoiceVO.getCompanyCode();
				String dataIndex			= taxInvoiceVO.getsUPBUY_TYPE();
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
				String isOffset				= taxInvoiceVO.getIsOffset();
				String cONVERSATION_ID		= taxInvoiceVO.getcONVERSATION_ID();
				String sUPBUY_TYPE			= taxInvoiceVO.getsUPBUY_TYPE();
				String dIRECTION			= taxInvoiceVO.getdIRECTION();
				String purchaseDT			= taxInvoiceVO.getPurchaseDT();
				String itemName				= taxInvoiceVO.getItemName();
				String spec					= taxInvoiceVO.getSpec();
				String qty					= taxInvoiceVO.getQty();
				String unitCost				= taxInvoiceVO.getUnitCost();
				String supplyCost			= taxInvoiceVO.getSupplyCost();
				String tax					= taxInvoiceVO.getTax();
				String remark				= taxInvoiceVO.getRemark();
				String registDate_item		= taxInvoiceVO.getRegistDate_item();
	
				//데이터 구조가 다른 관계로  임시로 셋팅
				if(dataIndex.equals("AP")){
					dataIndex = "BUY";
				} else if(dataIndex.equals("AR")){
					dataIndex = "SELL";
				}
				
				if(purposeType.equals("청구")) {
					purposeType = "02";
				} else if(purposeType.equals("영수")) {
					purposeType = "01";
				}
				
				listInfo.put("companyCode",				companyCode.equals("") ? "ALL" : companyCode);
				listInfo.put("UR_Code",					sessionUser);
				listInfo.put("dataIndex",				(dataIndex.equals("") ? "BUY" : ""));
				listInfo.put("writeDate",				writeDate);
				listInfo.put("issueDT",					issueDT);
				listInfo.put("invoiceType",				invoiceType);
				listInfo.put("taxType",					taxType);
				listInfo.put("taxTotal",				Double.parseDouble(StringUtil.replaceNull(taxTotal, "0")));
				listInfo.put("supplyCostTotal",			Double.parseDouble(StringUtil.replaceNull(supplyCostTotal, "0")));
				listInfo.put("totalAmount",				Double.parseDouble(StringUtil.replaceNull(totalAmount, "0")));
				listInfo.put("purposeType",				purposeType);
				listInfo.put("serialNum",				serialNum);
				listInfo.put("cash",					Double.parseDouble(StringUtil.replaceNull(cash, "0")));
				listInfo.put("chkBill",					Double.parseDouble(StringUtil.replaceNull(chkBill, "0")));
				listInfo.put("credit",					Double.parseDouble(StringUtil.replaceNull(credit, "0")));
				listInfo.put("note",					Double.parseDouble(StringUtil.replaceNull(note, "0")));
				listInfo.put("remark1",					remark1);
				listInfo.put("remark2",					remark2);
				listInfo.put("remark3",					remark3);
				listInfo.put("nTSConfirmNum",			nTSConfirmNum);
				listInfo.put("modifyCode",				modifyCode);
				listInfo.put("orgNTSConfirmNum",		orgNTSConfirmNum);
				listInfo.put("invoicerCorpNum",			invoicerCorpNum);
				listInfo.put("invoicerMgtKey",			invoicerMgtKey);
				listInfo.put("invoicerTaxRegID",		invoicerTaxRegID);
				listInfo.put("invoicerCorpName",		invoicerCorpName);
				listInfo.put("invoicerCEOName",			invoicerCEOName);
				listInfo.put("invoicerAddr",			invoicerAddr);
				listInfo.put("invoicerBizType",			invoicerBizType);
				listInfo.put("invoicerBizClass",		invoicerBizClass);
				listInfo.put("invoicerContactName",		invoicerContactName);
				listInfo.put("invoicerDeptName",		invoicerDeptName);
				listInfo.put("invoicerTel",				invoicerTel);
				listInfo.put("invoicerEmail",			invoicerEmail);
				listInfo.put("invoiceeCorpNum",			invoiceeCorpNum);
				listInfo.put("invoiceeMgtKey",			invoiceeMgtKey);
				listInfo.put("invoiceeTaxRegID",		invoiceeTaxRegID);
				listInfo.put("invoiceeCorpName",		invoiceeCorpName);
				listInfo.put("invoiceeCEOName",			invoiceeCEOName);
				listInfo.put("invoiceeAddr",			invoiceeAddr);
				listInfo.put("invoiceeBizType",			invoiceeBizType);
				listInfo.put("invoiceeBizClass",		invoiceeBizClass);
				listInfo.put("invoiceeContactName1",	invoiceeContactName1);
				listInfo.put("invoiceeDeptName1",		invoiceeDeptName1);
				listInfo.put("invoiceeTel1",			invoiceeTel1);
				listInfo.put("invoiceeEmail1",			invoiceeEmail1);
				listInfo.put("invoiceeContactName2",	invoiceeContactName2);
				listInfo.put("invoiceDeptName2",		invoiceDeptName2);
				listInfo.put("invoiceTel2",				invoiceTel2);
				listInfo.put("invoiceEmail2",			invoiceEmail2);
				listInfo.put("trusteeCorpNum",			trusteeCorpNum);
				listInfo.put("trusteeMgtKey",			trusteeMgtKey);
				listInfo.put("trusteeTaxRegID",			trusteeTaxRegID);
				listInfo.put("trusteeCorpName",			trusteeCorpName);
				listInfo.put("trusteeCEOName",			trusteeCEOName);
				listInfo.put("trusteeAddr",				trusteeAddr);
				listInfo.put("trusteeBizType",			trusteeBizType);
				listInfo.put("trusteeBizClass",			trusteeBizClass);
				listInfo.put("trusteeContactName",		trusteeContactName);
				listInfo.put("trusteeDeptName",			trusteeDeptName);
				listInfo.put("trusteeTel",				trusteeTel);
				listInfo.put("trusteeEmail",			trusteeEmail);
				listInfo.put("tossUserCode",			tossUserCode);
				listInfo.put("tossSenderUserCode",		tossSenderUserCode);
				listInfo.put("tossDate",				tossDate);
				listInfo.put("tossComment",				toss);
				listInfo.put("registDate_main",			registDate_main);
				listInfo.put("isOffset",				isOffset);
				listInfo.put("cONVERSATION_ID",			cONVERSATION_ID);
				listInfo.put("sUPBUY_TYPE",				sUPBUY_TYPE);
				listInfo.put("dIRECTION",				dIRECTION);
				
				listInfo.put("purchaseDT",				purchaseDT);
				listInfo.put("itemName",				itemName);
				listInfo.put("spec",					spec);
				listInfo.put("qty",						Double.parseDouble(StringUtil.replaceNull(qty, "0")));
				listInfo.put("unitCost",				Double.parseDouble(StringUtil.replaceNull(unitCost, "0")));
				listInfo.put("supplyCost",				Double.parseDouble(StringUtil.replaceNull(supplyCost, "0")));
				listInfo.put("tax",						Double.parseDouble(StringUtil.replaceNull(tax, "0")));
				listInfo.put("remark",					remark);
				listInfo.put("registDate_item",			registDate_item);
				//taxInvoiceInterfaceSave(listInfo);
				coviList.add(listInfo);
			}
			
			if(!coviList.isEmpty()){
				//key
				List<String> arrKey = new ArrayList<String>();
				for(int i=0; i<coviList.size(); i++){
					CoviMap info = (CoviMap) coviList.get(i);
					String chkKey = rtString(info.get("cONVERSATION_ID"));
					if(arrKey.indexOf(chkKey) < 0){
						//key = key + chkKey +",";
						arrKey.add(chkKey);
					}
				}
				
				//String[] arrKey = key.split(",");
				for(int k=0; k < arrKey.size(); k++){
					String key = rtString(arrKey.get(k));
					
					if(!key.equals("")){
						CoviList saveList = new CoviList();
						for(int z = 0; z < coviList.size(); z++){
							CoviMap info = (CoviMap) coviList.get(z);
							String listKey = rtString(info.get("cONVERSATION_ID"));
							if(listKey.equals(key)){
								saveList.add(info);
							}
						}
						taxInvoiceInterfaceSave(saveList);
					}
				}
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
	 * @Method Name : taxInvoiceInterfaceSave
	 * @Description : 매입수신내역 동기화 저장
	 */
	private void taxInvoiceInterfaceSave(CoviList list) {
		if(list.size() > 0){
			//String taxInvoiceDBType = rtString(accountUtil.getPropertyInfo("account.searchDBType.TaxInvoice"));
			String taxInvoiceDBType = rtString(accountUtil.getBaseCodeInfo("eAccDBType", "TaxInvoice", (String)InterfaceUtil.getCurrentRequestAttr("DN_ID")));
			
			String chkSql			= "";
			if(taxInvoiceDBType.equals("InfoTech")){
				chkSql	= "account.taxInvoice.getTaxInvoiceInterfaceInfoTechSaveCHK";
			}else if(taxInvoiceDBType.equals("Kwic")) {
				chkSql	= "account.taxInvoice.getTaxInvoiceInterfaceKwicSaveCHK";
			}else if(taxInvoiceDBType.equals("UniPost")){
				chkSql	= "account.taxInvoice.getTaxInvoiceInterfaceUniSaveCHK";
			}else{
				chkSql	= "account.taxInvoice.getTaxInvoiceInterfaceSaveCHK";
			}
			
			CoviMap info		= (CoviMap) list.get(0);
			CoviList chkList	= coviMapperOne.list(chkSql, info);
			
			/*if(chkList.size() > 0){
				for(int i=0; i<chkList.size(); i++){
					CoviMap delInfo = (CoviMap) chkList.get(i);
					coviMapperOne.delete("account.taxInvoice.taxInvoiceInterfaceMainDel", delInfo);
					coviMapperOne.delete("account.taxInvoice.taxInvoiceInterfaceItemDel", delInfo);
				}
			}*/
			
			if(chkList.isEmpty()) {
				String taxInvoiceID = "";
				for(int i=0; i<list.size(); i++){
					info = (CoviMap) list.get(i);
					if(i == 0){
						coviMapperOne.insert("account.taxInvoice.taxInvoiceInterfaceMainInsert", info);
						taxInvoiceID = rtString(info.get("taxInvoiceID"));
					}
					info.put("taxInvoiceID", taxInvoiceID);
					coviMapperOne.insert("account.taxInvoice.taxInvoiceInterfaceItemInsert", info);
				}
			}
		}
	}
	
	/**
	 * @Method Name : cashBillSync
	 * @Description : 현금 영수증 동기화
	 */
	@Override
	public CoviMap cashBillSync(CoviMap params){
			
		CoviMap interfaceParam	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		CashBillVO cashBillVO	= new CashBillVO();
		
		// Copy parameter from Controller.
		for(Object o : params.entrySet()) {
			Entry entry = (Entry)o;
			interfaceParam.put(entry.getKey(), entry.getValue());
		}
		InterfaceUtil.setCurrentRequestAttr("DN_ID", interfaceParam.getString("DN_ID"));
		
		try {
			//String syncType = accountUtil.getPropertyInfo("account.syncType.CashBill");
			String syncType = accountUtil.getBaseCodeInfo("eAccSyncType", "CashBill", (String)InterfaceUtil.getCurrentRequestAttr("DN_ID"));
			
			interfaceParam.put("interFaceType",			syncType);
			interfaceParam.put("daoClassName",			"CashBillDao");
			interfaceParam.put("voClassName",			"CashBillVO");
			interfaceParam.put("mapClassName",			"CashBillMap");
	
			interfaceParam.put("daoSetFunctionName",	"setCashBillList");
			interfaceParam.put("daoGetFunctionName",	"getCashBillList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			switch (syncType) {
				case "DB":
					//syncType이 DB인 경우 이곳에 정의
					interfaceParam.put("mapFunctionName",	"getInfoTechDBMap");
					interfaceParam.put("type",				"get");
					interfaceParam.put("sqlName",			"accountInterFace.Account4JIF.getInterFaceListCashBillInfoTech");
					break;
		
				case "SOAP":
					//syncType이 SOAP인 경우 이곳에 정의
					break;
					
				case "SAP":
					//syncType이 SAP인 경우 이곳에 정의
					break;
			}
	
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
			ArrayList list = (ArrayList) getInterface.get("list");
			String sessionUser = SessionHelper.getSession("UR_Code");
			for (int i = 0; i < list.size(); i++) {
				CoviMap listInfo = new CoviMap();
				cashBillVO = (CashBillVO) list.get(i);
	
				String cashBillID			= cashBillVO.getCashBillID();
				String companyCode			= cashBillVO.getCompanyCode();
				String nTSConfirmNum		= cashBillVO.getnTSConfirmNum();
				String tradeDT				= cashBillVO.getTradeDT();
				String tradeUsage			= cashBillVO.getTradeUsage();
				String tradeType			= cashBillVO.getTradeType();
				String supplyCost			= cashBillVO.getSupplyCost();
				String tax					= cashBillVO.getTax();
				String serviceFree			= cashBillVO.getServiceFree();
				String totalAmount			= cashBillVO.getTotalAmount();
				String invoiceType			= cashBillVO.getInvoiceType();
				String franchiseCorpNum		= cashBillVO.getFranchiseCorpNum();
				String franchiseCorpName	= cashBillVO.getFranchiseCorpName();
				String franchiseCorpType	= cashBillVO.getFranchiseCorpType();
				String registDate			= cashBillVO.getRegistDate();
				
				listInfo.put("cashBillID",			cashBillID);
				listInfo.put("companyCode",			companyCode.equals("") ? "ALL" : companyCode);
				listInfo.put("nTSConfirmNum",		nTSConfirmNum);
				listInfo.put("tradeDT",				tradeDT);
				listInfo.put("tradeUsage",			tradeUsage);
				listInfo.put("tradeType",			tradeType);
				listInfo.put("supplyCost",			supplyCost);
				listInfo.put("tax",					tax);
				listInfo.put("serviceFree",			serviceFree);
				listInfo.put("totalAmount",			totalAmount);
				listInfo.put("invoiceType",			invoiceType);
				listInfo.put("franchiseCorpNum",	franchiseCorpNum);
				listInfo.put("franchiseCorpName",	franchiseCorpName);
				listInfo.put("franchiseCorpType",	franchiseCorpType);
				listInfo.put("registDate",			registDate);
				
				cashBillInterfaceSave(listInfo);
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
	 * @Method Name : cashBillInterfaceSave
	 * @Description : 현금 영수증 동기화 저장
	 */
	private void cashBillInterfaceSave(CoviMap info) {
		coviMapperOne.delete("account.taxInvoice.cashBillInterfaceDel",		info);
		coviMapperOne.insert("account.taxInvoice.cashBillInterfaceInsert",	info);
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

	@Override
	public boolean chkDupTaxInvoice(String conversationID) throws Exception {
		boolean bReturn = false;
		String taxInvoiceDBType = rtString(accountUtil.getBaseCodeInfo("eAccDBType", "TaxInvoice", SessionHelper.getSession("DN_ID")));
		
		String chkSql			= "";
		if(taxInvoiceDBType.equals("InfoTech")){
			chkSql	= "account.taxInvoice.getTaxInvoiceInterfaceInfoTechSaveCHK";
		}else if(taxInvoiceDBType.equals("Kwic")) {
			chkSql	= "account.taxInvoice.getTaxInvoiceInterfaceKwicSaveCHK";
		}else if(taxInvoiceDBType.equals("UniPost")){
			chkSql	= "account.taxInvoice.getTaxInvoiceInterfaceUniSaveCHK";
		}else{
			chkSql	= "account.taxInvoice.getTaxInvoiceInterfaceSaveCHK";
		}
		CoviMap chkParam = new CoviMap();
		chkParam.put("cONVERSATION_ID", conversationID);
		CoviMap chkReturn = coviMapperOne.select(chkSql, chkParam);
		
		if(chkReturn.size() > 0) bReturn = true;
		return bReturn;
	}
}
