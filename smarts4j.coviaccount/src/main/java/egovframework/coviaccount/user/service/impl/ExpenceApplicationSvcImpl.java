package egovframework.coviaccount.user.service.impl;

import java.lang.invoke.MethodHandles;
import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

import javax.annotation.Resource;





import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.StringUtils;
import org.json.simple.parser.JSONParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.validation.BindException;
import org.springframework.validation.BindingResult;
import org.springframework.validation.Validator;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.service.CommonSvc;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountFileUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.interfaceUtil.interfaceVO.CardReceiptVO;
import egovframework.coviaccount.interfaceUtil.interfaceVO.ExpenceApplicationVO;
import egovframework.coviaccount.user.service.ExpenceApplicationSvc;
import egovframework.coviaccount.user.service.FormManageSvc;
import egovframework.coviaccount.user.service.TaxInvoiceSvc;
import egovframework.coviframework.service.EditorService;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.coviframework.util.MessageHelper;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

/**
 * @Class Name : ExpenceApplicationSvcImpl
 * @Description : 경비신청
 * @Modification Information 
 * @author Covision
 * @ 2018.05.29 최초생성
 */
@Service("expenceApplicationService")
public class ExpenceApplicationSvcImpl extends EgovAbstractServiceImpl implements ExpenceApplicationSvc {
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	@Resource(name="AccountExcelUtil")
	private AccountExcelUtil excelUtil;

	@Autowired
	private FileUtilService fileUtil;

	@Autowired
	private AccountUtil accountUtil;
	
	@Autowired
	private AccountFileUtil accountFileUtil;

	@Autowired
	private AccountExcelUtil accountExcelUtil;

	@Autowired
	private InterfaceUtil interfaceUtil;
	
	/*@Autowired
	private WebServiceTemplate webServiceTemplate;*/
	
	@Autowired
	private CommonSvc commonSvc;
	
	@Autowired
	private TaxInvoiceSvc taxInvoiceSvc; 
	
	@Autowired
	private EditorService editorService;
	
	@Autowired
	private FormManageSvc formManageSvc;

	@Autowired
	private MessageService messageSvc;
	
	@Autowired
	private Validator expenceApplicationListValidator;
	
	@Autowired
	private Validator expenceApplicationDivValidator;
	
	/**
	* @Method Name : getCardReceipt
	* @Description : 카드사용내역 추가정보 조회
	*/
	@Override
	public CoviMap getCardReceipt(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.getCardReceipt", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList;
	}
	
	/**
	* @Method Name : getTaxCodeCombo
	* @Description : 세금코드 콤보
	*/
	@Override
	public CoviMap getTaxCodeCombo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.getTaxCodeList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list
				, "CodeGroup,Code,CodeName,ProofCode,DeductionType,MapCode,IsUse"));
		return resultList;
	}
	
	/**
	* @Method Name : getBriefCombo
	* @Description : 표준적요 콤보
	*/
	@Override
	public CoviMap getBriefCombo(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("expenceApplication.selectBriefList", params);
		resultList.put("BriefList", CoviSelectSet.coviSelectJSON(list
				, "StandardBriefID,StandardBriefName,AccountID,AccountCode,AccountName,StandardBriefDesc,TaxCode,TaxCodeName,TaxType,TaxTypeName,CtrlCode,IsFile,IsDocLink"));
		
		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		CoviList userList = coviMapperOne.list("expenceApplication.selectUserBriefList", params);
		resultList.put("UserBriefList", CoviSelectSet.coviSelectJSON(userList
				, "StandardBriefID,StandardBriefName,AccountID,AccountCode,AccountName,StandardBriefDesc,TaxCode,TaxCodeName,TaxType,TaxTypeName,CtrlCode,IsFile,IsDocLink"));
		
		return resultList;
	}

	/**
	* @Method Name : insertCombineCostApplication
	* @Description : 통합비용신청 저장
	*/
	@Override
	public CoviMap insertCombineCostApplication(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();

		String userID = SessionHelper.getSession("USERID");
		CoviMap saveObj = params;
		saveObj.put("SessionUser",  userID);
		saveObj.put("Note", getNote(saveObj));
		
		coviMapperOne.insert("expenceApplication.insertExpApp", saveObj);

		String applicationStatus = AccountUtil.jobjGetStr(saveObj,"ApplicationStatus");
		String expenceApplicationID= AccountUtil.jobjGetStr(params,"ExpenceApplicationID");
		String companyCode = AccountUtil.jobjGetStr(params,"CompanyCode");
		
		CoviList appEvidList = (CoviList) AccountUtil.jobjGetObj(params,"pageExpenceAppEvidList");
		CoviList savedEvidList = new CoviList();

		if(appEvidList != null){
			for(int i = 0; i<appEvidList.size(); i++){
				CoviMap evidItem =  appEvidList.getJSONObject(i);
				evidItem.put("ExpenceApplicationID", expenceApplicationID);
				
				//useWriteVendor == Y
				if(evidItem.getString("ProofCode").equals("EtcEvid") && RedisDataUtil.getBaseConfig("useWriteVendor").equals("Y")) {
					String vendorNo = AccountUtil.jobjGetStr(evidItem,"VendorNo");
					String vendorName = AccountUtil.jobjGetStr(evidItem,"VendorName");
					 
					evidItem.put("VendorNo", insertActVendorForWrite(vendorNo, vendorName, companyCode));
				}
				
				savedEvidList.add(saveExpAppList(evidItem, userID));
				
				if("S".equals(applicationStatus)){
					evidItem.put("Active", "I");
				}
				else if("T".equals(applicationStatus)){
					evidItem.put("Active", "Y");
				}
				String proofCode = AccountUtil.jobjGetStr(evidItem,"ProofCode");
				if("CorpCard".equals(proofCode)){
					coviMapperOne.update("expenceApplication.updateCardActive", evidItem);
				}
				else if("Receipt".equals(proofCode)){
					coviMapperOne.update("expenceApplication.updateMobileActive", evidItem);
				}
			}
		}

		resultObj.put("getSavedKey", expenceApplicationID); //ExpenceApplicationID
		resultObj.put("getSavedList", savedEvidList); //savedEvidList
		resultObj.put("status", "S");
		return resultObj;
	}

	/**
	* @Method Name : updateCombineCostApplication
	* @Description : 통합비용신청 저장
	*/
	@Override
	public CoviMap updateCombineCostApplication(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();

		String userID = SessionHelper.getSession("USERID");
		CoviMap saveObj = params;
		saveObj.put("SessionUser", userID);
		saveObj.put("Note", getNote(saveObj));
		
		coviMapperOne.update("expenceApplication.updateExpApp", saveObj);

		String applicationStatus = AccountUtil.jobjGetStr(saveObj,"ApplicationStatus");
		String expenceApplicationID = AccountUtil.jobjGetStr(params,"ExpenceApplicationID");
		String companyCode = AccountUtil.jobjGetStr(params,"CompanyCode");
		
		String processID = "";
		if(saveObj.containsKey("ProcessID")) {
			processID = AccountUtil.jobjGetStr(saveObj,"ProcessID");
		}
		
		CoviList deleted = (CoviList) AccountUtil.jobjGetObj(params,"pageExpenceAppEvidDeletedList");
		if(deleted != null) {
			for(int i = 0; i<deleted.size(); i++){
	
				CoviMap deletedItem =  deleted.getJSONObject(i);
				CoviMap deletedCM = new CoviMap(deletedItem);
				deleteExpAppList(deletedCM, false);
			}
		}
		
		CoviList appEvidList = (CoviList) AccountUtil.jobjGetObj(params,"pageExpenceAppEvidList");
		
		CoviList savedEvidList = new CoviList();
		if(appEvidList != null) {
			for(int i = 0; i<appEvidList.size(); i++){
				CoviMap evidItem =  appEvidList.getJSONObject(i);
				evidItem.put("ExpenceApplicationID", expenceApplicationID);
				evidItem.put("SessionUser",  userID);
				evidItem.put("_ApplicationStatus", applicationStatus);
				
				//useWriteVendor == Y
				if(evidItem.getString("ProofCode").equals("EtcEvid") && RedisDataUtil.getBaseConfig("useWriteVendor").equals("Y")) {
					String vendorNo = AccountUtil.jobjGetStr(evidItem,"VendorNo");
					String vendorName = AccountUtil.jobjGetStr(evidItem,"VendorName");
					 
					evidItem.put("VendorNo", insertActVendorForWrite(vendorNo, vendorName, companyCode));
				}
				
				savedEvidList.add(saveExpAppList(evidItem, userID));
				
				if("S".equals(applicationStatus)){
					evidItem.put("Active", "I");
				}
				else if("T".equals(applicationStatus)){
					evidItem.put("Active", "Y");
				}
				
				String proofCode = AccountUtil.jobjGetStr(evidItem,"ProofCode");
				if(!("E".equals(applicationStatus))){
					if("CorpCard".equals(proofCode)){
						coviMapperOne.update("expenceApplication.updateCardActive", evidItem);
					}
					else if("Receipt".equals(proofCode)){
						coviMapperOne.update("expenceApplication.updateMobileActive", evidItem);
					}
				} 
				
				// 결재자 증빙 편집 시 processdescription의 businessdata 수정
				if(!processID.equals("") && i == 0) {
					CoviList divList = (CoviList) AccountUtil.jobjGetObj(evidItem, "divList");
					if(divList != null) {
						CoviMap divItem = divList.getJSONObject(0);
			    		//long amountSum = 0;
						Double amountSum = 0d;
			    		for(int d = 0; d < appEvidList.size(); d++) {
			    			//amountSum += appEvidList.getJSONObject(d).getLong("divSum");
			    			amountSum += appEvidList.getJSONObject(d).getDouble("divSum");
			    		}
			    		//divItem.put("AmountSum", amountSum);
			    		divItem.put("AmountSum", Double.toString(amountSum));
			    		String subUserCode = AccountUtil.jobjGetStr(saveObj,"Sub_UR_Code");
			    		divItem.put("Sub_UR_Code", subUserCode);
						coviMapperOne.update("expenceApplication.updateBusinessDataForApv", divItem);
					}
				}
			}
		}
		
		resultObj.put("getSavedKey", expenceApplicationID); //ExpenceApplicationID
		resultObj.put("getSavedList", savedEvidList); //savedEvidList
		resultObj.put("status", "S");
		return resultObj;
	}

	/**
	* @Method Name : saveExpAppList
	* @Description : 증빙목록 저장
	*/
	private CoviMap saveExpAppList(CoviMap evidItem, String userID) throws Exception {
		String expenceApplicationID = AccountUtil.jobjGetStr(evidItem, "ExpenceApplicationID");
		String expenceApplicationListID= AccountUtil.jobjGetStr(evidItem,"ExpenceApplicationListID");
		evidItem.put("SessionUser",  userID);
		if(evidItem.has("RealPayDate") && evidItem.getString("RealPayDate").indexOf(".") > -1) {
			evidItem.put("RealPayDate", evidItem.getString("RealPayDate").replaceAll("\\.", ""));
		}

		String proofCode = AccountUtil.jobjGetStr(evidItem,"ProofCode");
		
		if("".equals(expenceApplicationListID)){
			///인터페이스 데이터 삽입 로직
			if("CorpCard".equals(proofCode)){
				//String PropertyCardReceipt = accountUtil.getPropertyInfo("account.searchType.CardReceipt");
				String propertyCardReceipt = accountUtil.getBaseCodeInfo("eAccSearchType", "CardReceipt");
				if(!"".equals(propertyCardReceipt)){
					insertCorpCardIFData(evidItem);
				}
			}else if("CashBill".equals(proofCode)){
				//insertCashBillIFData(evidItem);
			}else if("TaxBill".equals(proofCode)){
				//String PropertyTaxInvoice = accountUtil.getPropertyInfo("account.searchType.TaxInvoice");
				String propertyTaxInvoice = accountUtil.getBaseCodeInfo("eAccSearchType", "TaxInvoice");
				String isXML = AccountUtil.jobjGetStr(evidItem,"isXML");
				
				if(!"".equals(propertyTaxInvoice)
						||"Y".equals(isXML)){
					String taxID = insertTaxBillIFData(evidItem);
					evidItem.put("TaxUID", taxID);
				}
			}
		}
		
		if("CorpCard".equals(proofCode)){
			coviMapperOne.insert("expenceApplication.updateCRInfo", evidItem);
		}
		
		expenceApplicationListValidator.validate(evidItem, new BindException(evidItem, "expenceApplicationList"));
		
		coviMapperOne.insert("expenceApplication.saveExpAppList", evidItem);
		//기본에 ListID가 없다는건 신규 추가 건이라는것이니 insert했을시 키를 새로 가져옴
		if("".equals(expenceApplicationListID)){
			expenceApplicationListID= AccountUtil.jobjGetStr(evidItem,"InsertedExpenceApplicationListID");
			evidItem.put("ExpenceApplicationListID", expenceApplicationListID);
		}
		
		// [2023.04.20]증빙신규 입력한 전표 상태가 완료상태일 경우 새로 등록된 증빙의 CapitalStatus 를 "W"(대기) 로 변경한다. 
		String applicationStatus = evidItem.getString("_ApplicationStatus");
		if("E".equals(applicationStatus)) {
			// 자금 지출 (상태값 변경 : NULL -> 대기)
			CoviMap params = new CoviMap();
			params.put("CapitalStatus", "W");
			params.put("ExpenceApplicationID", expenceApplicationID);
			
			expAppUpdateCapitalStatus(params);
		}
		
		//일비 저장
		CoviList dailyList = (CoviList) AccountUtil.jobjGetObj(evidItem, "pageDailyExpenceAppEvidList");
		if(dailyList != null) {
			coviMapperOne.delete("expenceApplication.deleteExpAppDailyList", evidItem);
			for(int y = 0; y < dailyList.size(); y++){
				CoviMap dailyItem = dailyList.getJSONObject(y);

				dailyItem.put("ExpenceApplicationID", expenceApplicationID);
				dailyItem.put("ExpenceApplicationListID", expenceApplicationListID);
				dailyItem.put("SessionUser",  userID);
				coviMapperOne.insert("expenceApplication.insertExpAppDailyList", dailyItem);
			}
		}
		
		//유류비 저장
		CoviList fuelList = (CoviList) AccountUtil.jobjGetObj(evidItem, "pageFuelExpenceAppEvidList");
		if(fuelList != null) {
			coviMapperOne.delete("expenceApplication.deleteExpAppFuelList", evidItem);
			for(int y = 0; y < fuelList.size(); y++){
				CoviMap fuelItem = fuelList.getJSONObject(y);

				fuelItem.put("ExpenceApplicationID", expenceApplicationID);
				fuelItem.put("ExpenceApplicationListID", expenceApplicationListID);
				fuelItem.put("SessionUser",  userID);
				coviMapperOne.insert("expenceApplication.insertExpAppFuelList", fuelItem);
			}
		}
		
		CoviList divList = (CoviList) AccountUtil.jobjGetObj(evidItem,"divList");
		if(divList != null){
			coviMapperOne.delete("expenceApplication.deleteExpAppDiv", evidItem);
			for(int y = 0; y<divList.size(); y++){
				CoviMap divItem =  divList.getJSONObject(y);
				
//				divItem.put("ExpenceApplicationListID", ExpenceApplicationListID);
//				divItem.put("SessionUser",  UserID);
//				coviMapperOne.insert("expenceApplication.insertExpAppListDiv", divItem);
				
				CoviMap params = new CoviMap();
				params.put("ExpenceApplicationListID", expenceApplicationListID);
				params.put("SessionUser", userID);
				params.put("AccountCode", Objects.toString(divItem.get("AccountCode"), ""));
				params.put("AccountName", Objects.toString(divItem.get("AccountName"), ""));
				params.put("CostCenterCode", Objects.toString(divItem.get("CostCenterCode"), ""));
				params.put("CostCenterName", Objects.toString(divItem.get("CostCenterName"), ""));
				params.put("IOCode", Objects.toString(divItem.get("IOCode"), ""));
				params.put("IOName", Objects.toString(divItem.get("IOName"), ""));
				params.put("Amount", Objects.toString(divItem.get("Amount"), ""));
				params.put("UsageComment", Objects.toString(divItem.get("UsageComment"), ""));
				params.put("StandardBriefID", Objects.toString(divItem.get("StandardBriefID"), ""));
				params.put("StandardBriefName", Objects.toString(divItem.get("StandardBriefName"), ""));
				params.put("ReservedStr1_Div", Objects.toString(divItem.get("ReservedStr1_Div"), ""));
				params.put("ReservedStr2_Div", Objects.toString(divItem.get("ReservedStr2_Div"), ""));
				params.put("ReservedStr3_Div", Objects.toString(divItem.get("ReservedStr3_Div"), ""));
				params.put("ReservedStr4_Div", Objects.toString(divItem.get("ReservedStr4_Div"), ""));
				params.put("ReservedStr5_Div", Objects.toString(divItem.get("ReservedStr5_Div"), ""));
				params.put("ReservedInt1_Div", Objects.toString(divItem.get("ReservedInt1_Div"), ""));
				params.put("ReservedInt2_Div", Objects.toString(divItem.get("ReservedInt2_Div"), ""));
					
				expenceApplicationDivValidator.validate(params, new BindException(params, "expenceApplicationDiv"));
				
				coviMapperOne.insert("expenceApplication.insertExpAppListDiv", params);
			}
		}
		
		CoviList deletedFile = (CoviList) AccountUtil.jobjGetObj(evidItem,"deletedFile");

		if(deletedFile != null){
			coviMapperOne.delete("expenceApplication.deleteExpAppFile", evidItem);
			for(int y = 0; y<deletedFile.size(); y++){
				CoviMap fileItem =  deletedFile.getJSONObject(y);
				fileItem.put("ExpenceApplicationListID", expenceApplicationListID);
				//accountFileUtil.deleteFileByID(fileItem.get("FileID").toString());
				fileUtil.deleteFileByID(fileItem.get("FileID").toString(), true);
				
				coviMapperOne.delete("expenceApplication.deleteExpAppFileOne", fileItem);
			}
		}
		
		CoviList fileList = (CoviList) AccountUtil.jobjGetObj(evidItem,"fileList");
		CoviList uploadFileList = (CoviList) AccountUtil.jobjGetObj(evidItem,"uploadFileList");
		if(uploadFileList != null){
			//CoviList uploadFiles = accountFileUtil.moveToBack(uploadFileList, "EAccount/", "EAccount", "0", "NONE", "0");
			CoviList uploadFiles = fileUtil.moveToBack(uploadFileList, "EAccount/", "EAccount", "0", "NONE", "0", false);
			
			if(fileList==null){
				fileList = uploadFiles;
			}else{
				fileList.addAll(uploadFiles);
			}
		}
		
		if(fileList != null){
			coviMapperOne.delete("expenceApplication.deleteExpAppFile", evidItem);
			for(int y = 0; y<fileList.size(); y++){
				CoviMap fileItem =  fileList.getJSONObject(y);
				fileItem.put("ExpenceApplicationListID", expenceApplicationListID);
				fileItem.put("SessionUser",  userID);
				coviMapperOne.insert("expenceApplication.insertExpAppFile", fileItem);
			}
		}
		CoviList docList = (CoviList) AccountUtil.jobjGetObj(evidItem,"docList");
		if(docList != null){
			coviMapperOne.delete("expenceApplication.deleteExpAppDoc", evidItem);
			for(int y = 0; y<docList.size(); y++){
				CoviMap docItem =  docList.getJSONObject(y);
				docItem.put("ExpenceApplicationListID", expenceApplicationListID);
				docItem.put("SessionUser",  userID);
				coviMapperOne.insert("expenceApplication.insertExpAppDoc", docItem);
			}
		}
		return evidItem;
	}

	/**
	* @Method Name : insertCorpCardIFData
	* @Description : 프로퍼티 값에 따라 인터페이스에서 가져온 데이터를 DB에 삽입
	*/
	private void insertCorpCardIFData(CoviMap evidItem) throws Exception {
		CoviMap getIFData = (CoviMap) AccountUtil.jobjGetObj(evidItem,"oriIFData");
		coviMapperOne.insert("expenceApplication.insertCorpCardIFData", getIFData);
	}
	
	/**
	* @Method Name : insertTaxBillIFData
	* @Description : 프로퍼티 값에 따라 인터페이스에서 가져온 데이터를 DB에 삽입
	*/
	private String insertTaxBillIFData(CoviMap evidItem) throws Exception {
		CoviMap getIFData = (CoviMap) AccountUtil.jobjGetObj(evidItem,"oriIFData");
		CoviList itemList = (CoviList) AccountUtil.jobjGetObj(evidItem,"itemList");
		String conversationID = "";
		String retVal = "";
		// 기존에 있는 정보인지 체크
		if(getIFData != null) {
			conversationID = AccountUtil.jobjGetStr(getIFData,"InvoicerCorpNum") + AccountUtil.jobjGetStr(getIFData,"NTSConfirmNum");
			if(taxInvoiceSvc.chkDupTaxInvoice(conversationID)) {
				throw new Exception(DicHelper.getDic("msg_dupAccTaxInvoice"));
			}
			getIFData.put("CONVERSATION_ID", conversationID);
			coviMapperOne.insert("expenceApplication.insertTaxBillIFData", getIFData);
			retVal = AccountUtil.jobjGetStr(getIFData,"TaxInvoiceID");
		}
		if(itemList != null){
			for(int i = 0; i<itemList.size(); i++){
				CoviMap getItem =  itemList.getJSONObject(i);
				getItem.put("TaxInvoiceID", retVal);
				coviMapperOne.insert("expenceApplication.insertTaxBillItemIFData", getItem);
			}
		}
		return retVal;
	}
	
	/**
	* @Method Name : getCashBillInfo
	* @Description : 현금영수증내역 추가데이터 조회
	*/
	@Override
	public CoviMap getCashBillInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.getCashBillInfo", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList;
	}

	/**
	* @Method Name : getTaxBillInfo
	* @Description : 세금계산서 추가데이터 조회 정보
	*/
	@Override
	public CoviMap getTaxBillInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.getTaxBillInfo", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList;
	}

	/**
	* @Method Name : getTaxBillItemInfo
	* @Description : 세금계산서 품목 정보 조회
	*/
	@Override
	public CoviMap getTaxBillItemInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.getTaxBillItemInfo", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList;
	}
	
	/**
	* @Method Name : getApplicationListCopy
	* @Description : 전표복사를 위한 
	*/
	@Override
	public CoviMap getApplicationListCopy(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.getApplicationListCopy", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList;
	}
	
	/**
	* @Method Name : getVdCheck
	* @Description : 인터페이스에서 가져온 업체정보 존재 체크
	*/
	@Override
	public CoviMap getVdCheck(CoviMap params) throws Exception {
		CoviMap vdInfo = coviMapperOne.selectOne("expenceApplication.getVdCheck", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("vdInfo", AccountUtil.convertNullToSpace(vdInfo));
		return resultList;
	}

	/**
	* @Method Name : searchExpenceApplicationList
	* @Description : 증빙 목록 조회
	*/
	public CoviMap searchExpenceApplicationList(CoviMap jsonParams) throws Exception {
		String searchType = AccountUtil.jobjGetStr(jsonParams,"SearchType");
		
		CoviMap resultList = new CoviMap();
		CoviList list = new CoviList();
		CoviMap page			= new CoviMap();
		
		CoviMap params = new CoviMap();
		params.addAll(jsonParams);
		
		int cnt = 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		if("app".equals(searchType)){
			cnt = (int) coviMapperOne.getNumber("expenceApplication.selectExpenceApplicationAppCnt", params);
			
			page 	= ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			
			list = coviMapperOne.list("expenceApplication.selectExpenceApplicationApp", params);
		}else if("list".equals(searchType)){
			params.put("displayType", "ListDisplay");
			CoviMap audit = coviMapperOne.selectOne("expenceApplication.selectAuditUseYN", params); 
			if(audit != null){
				Iterator<String> iter = audit.keySet().iterator();
				
				while(iter.hasNext()){
					String key = iter.next();
					params.put(key, audit.getString(key));
				}
			}
			
			cnt = (int)coviMapperOne.getNumber("expenceApplication.selectExpenceApplicationListCnt", params);
			
			page 	= ComUtils.setPagingData(params,cnt);
			params.addAll(page);

			list = coviMapperOne.list("expenceApplication.selectExpenceApplicationList", params);
		}else if("div".equals(searchType)){
			cnt = (int)coviMapperOne.getNumber("expenceApplication.selectExpenceApplicationManDivCnt", params);
			
			page 	= ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			
			list = coviMapperOne.list("expenceApplication.selectExpenceApplicationManDiv", params);
		}
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);
		return resultList;
	}
	
	/**
	* @Method Name : searchExpenceApplicationListExcel
	* @Description : 증빙 목록 조회 엑셀
	*/
	public CoviMap searchExpenceApplicationListExcel(CoviMap params) throws Exception {
		String searchType = (String)params.get("SearchType");
		
		CoviList list = new CoviList();
		DecimalFormat format = new DecimalFormat("###,###.##");
		int cnt = 0;
		params.put("isExcel", "Y");

		if("app".equals(searchType)){
			list = coviMapperOne.list("expenceApplication.selectExpenceApplicationAppExcel", params);
			cnt = (int)(long)coviMapperOne.selectOne("expenceApplication.selectExpenceApplicationAppCnt", params);
			
			for (int i = 0; i < list.size(); i++) {
				CoviMap coviMap = (CoviMap) list.get(i);
				coviMap.put("TotalAmountSum", "".equals(coviMap.getString("TotalAmountSum")) ? 0 : format.format(Double.parseDouble(coviMap.getString("TotalAmountSum").replaceAll(",", ""))));
				coviMap.put("AmountSum", "".equals(coviMap.getString("AmountSum")) ? 0 : format.format(Double.parseDouble(coviMap.getString("AmountSum").replaceAll(",", ""))));
			}
		}else if("list".equals(searchType)){
			list = coviMapperOne.list("expenceApplication.selectExpenceApplicationListExcel", params);
			cnt = (int)(long)coviMapperOne.selectOne("expenceApplication.selectExpenceApplicationListCnt", params);
			
			for (int i = 0; i < list.size(); i++) {
				CoviMap coviMap = (CoviMap) list.get(i);
				coviMap.put("TaxAmount", "".equals(coviMap.getString("TaxAmount")) ? 0 : format.format(Double.parseDouble(coviMap.getString("TaxAmount").replaceAll(",", ""))));
				coviMap.put("RepAmount", "".equals(coviMap.getString("RepAmount")) ? 0 : format.format(Double.parseDouble(coviMap.getString("RepAmount").replaceAll(",", ""))));
				coviMap.put("TotalAmount", "".equals(coviMap.getString("TotalAmount")) ? 0 : format.format(Double.parseDouble(coviMap.getString("TotalAmount").replaceAll(",", ""))));
				coviMap.put("AmountSum", "".equals(coviMap.getString("AmountSum")) ? 0 : format.format(Double.parseDouble(coviMap.getString("AmountSum").replaceAll(",", ""))));
			}
		}else if("div".equals(searchType)){
			list = coviMapperOne.list("expenceApplication.selectExpenceApplicationManDivExcel", params);
			cnt = (int)(long)coviMapperOne.selectOne("expenceApplication.selectExpenceApplicationManDivCnt", params);
			
			for (int i = 0; i < list.size(); i++) {
				CoviMap coviMap = (CoviMap) list.get(i);
				coviMap.put("TaxAmount", "".equals(coviMap.getString("TaxAmount")) ? 0 : format.format(Double.parseDouble(coviMap.getString("TaxAmount").replaceAll(",", ""))));
				coviMap.put("RepAmount", "".equals(coviMap.getString("RepAmount")) ? 0 : format.format(Double.parseDouble(coviMap.getString("RepAmount").replaceAll(",", ""))));
				coviMap.put("TotalAmount", "".equals(coviMap.getString("TotalAmount")) ? 0 : format.format(Double.parseDouble(coviMap.getString("TotalAmount").replaceAll(",", ""))));
				coviMap.put("Amount", "".equals(coviMap.getString("Amount")) ? 0 : format.format(Double.parseDouble(coviMap.getString("Amount").replaceAll(",", ""))));
			}
		}else if("douzone".equals(searchType)){
			list = coviMapperOne.list("expenceApplication.selectExpenceApplicationDouzoneExcel", params);
			cnt = (int)(long)coviMapperOne.selectOne("expenceApplication.selectExpenceApplicationDouzoneExcelCnt", params);
		}else if("CardReceiptExcel".equals(searchType)){
			list = coviMapperOne.list("expenceApplication.selectExpenceApplicationCardReceiptExcel", params);
			cnt = (int)(long)coviMapperOne.selectOne("expenceApplication.selectExpenceApplicationCardReceiptExcelCnt", params);
		}else if("TaxInvoiceExcel".equals(searchType)){
			list = coviMapperOne.list("expenceApplication.selectExpenceApplicationTaxInvoiceExcel", params);
			cnt = (int)(long)coviMapperOne.selectOne("expenceApplication.selectExpenceApplicationTaxInvoiceExcelCnt", params);
		}else{
			list = coviMapperOne.list("expenceApplication.selectExpenceApplicationListExcel", params);
		}

		CoviMap resultList = new CoviMap();
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt", cnt);

		return resultList;
	}

	/**
	* @Method Name : searchExpenceApplication
	* @Description : 비용신청 상세조회
	*/
	public CoviMap searchExpenceApplication(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		CoviMap expenceApplication = new CoviMap();
		
		if(params.containsKey("ExpenceApplicationID")) {
			expenceApplication = (CoviMap)AccountUtil.convertNullToSpace(coviMapperOne.selectOne("expenceApplication.selectExpenceApplication", params));
			expenceApplication.put("Note", new String(Base64.decodeBase64(expenceApplication.getString("Note").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
		}
		
		if(!params.containsKey("companyCode")) {
			params.put("companyCode", commonSvc.getCompanyCodeOfUser(SessionHelper.getSession("USERID")));
		}
		
		//법인카드, 세금계산서, 현금영수증, 개인카드, 기타증빙, 모바일영수증 조회후 list 하나로 합치기
		//각 증빙별로 join을 해야 할 테이블이 모두 달라서 각각 조회후 목록 합치기
		List<Object> getEAList = new ArrayList<>();
		getEAList.addAll((CoviList)AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationDetailListCC", params)));
		getEAList.addAll((CoviList)AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationDetailListTB", params)));
		getEAList.addAll((CoviList)AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationDetailListPB", params)));
		getEAList.addAll((CoviList)AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationDetailListCB", params)));
		getEAList.addAll((CoviList)AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationDetailListPC", params)));
		getEAList.addAll((CoviList)AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationDetailListEE", params)));
		getEAList.addAll(FileUtil.getFileTokenList((CoviList)AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationDetailListMR", params))));
//		JSONArray jsonArray = (JSONArray) AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationDetailListAll", params));
//		getEAList.addAll(FileUtil.getFileTokenList(jsonArray));
		
		if(params.containsKey("ExpenceApplicationID")) {
			String requestType = expenceApplication.getString("RequestType");
			if(requestType.equals("BIZTRIP") || requestType.equals("OVERSEA")) {
				CoviMap bizTripMap = coviMapperOne.selectOne("biztrip.selectBizTripApplicationInfo", params);
				expenceApplication.addAll(bizTripMap); //BizTripRequestID, BizTripNoteMap 추가
				
				List getEADailyList = (CoviList)AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationDailyList", params));
				List getEAFuelList = (CoviList)AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationFuelList", params));
				
				for(int i = 0; i<getEAList.size(); i++){
					Map itemData =  (Map) getEAList.get(i);
					String listId = itemData.get("ExpenceApplicationListID").toString();		
	
					// 일비
					List dailyList = new ArrayList();
					for(int y = 0; y<getEADailyList.size(); y++){
						Map dailyItem =  (Map) getEADailyList.get(y);
						String dailyListId = dailyItem.get("ExpenceApplicationListID").toString();
						if(listId.equals(dailyListId)){
							dailyList.add(dailyItem);
						}
					}
					itemData.put("pageDailyExpenceAppEvidList", dailyList);
					
					// 유류비
					List fuelList = new ArrayList();
					for(int y = 0; y<getEAFuelList.size(); y++){
						Map fuelItem =  (Map) getEAFuelList.get(y);
						String fuelListId = fuelItem.get("ExpenceApplicationListID").toString();
						if(listId.equals(fuelListId)){
							fuelList.add(fuelItem);
						}
					}
					itemData.put("pageFuelExpenceAppEvidList", fuelList);
				}
			}
			
			if(!expenceApplication.getString("ApplicationType").equals("CO")) {
				params.put("displayType", "DocDisplay");
				CoviMap docDisplayYN = coviMapperOne.selectOne("expenceApplication.selectAuditUseYN", params); //신청문서표시 사용 여부 확인
				if(docDisplayYN != null){	
					boolean hasValue = false;
					Iterator<String> iter = docDisplayYN.keySet().iterator();
					
					while(iter.hasNext()){
						String key = iter.next();
						params.put(key, docDisplayYN.getString(key));
						if(docDisplayYN.getString(key) != null && docDisplayYN.getString(key).equals("Y")) {
							hasValue = true;
						}
					}

					if(hasValue) { //조인할 감사규칙이 하나라도 있으면
						//하단증빙 체크한 감사규칙에 해당하는 증빙 정보
						List auditEvidList = (CoviList) AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationAuditEvid", params));
						expenceApplication.put("auditEvidList", auditEvidList);
						//상단건수표시 체크한 감사규칙에 해당하는 증빙 갯수
						CoviMap auditCntMap = (CoviMap) AccountUtil.convertNullToSpace(coviMapperOne.selectOne("expenceApplication.selectExpenceApplicationAuditCnt", params));
						expenceApplication.put("auditCntMap", auditCntMap);
					}
				}
				
				params.put("displayType", "ApplicationLimit");
				CoviMap appLimitYN = coviMapperOne.selectOne("expenceApplication.selectAuditUseYN", params); //신청 시 감사 여부 확인
				if(appLimitYN != null){
					boolean hasValue = false;		
					Iterator<String> iter = appLimitYN.keySet().iterator();
					
					while(iter.hasNext()){
						String key = iter.next();
						params.put(key, appLimitYN.getString(key));
						if(appLimitYN.getString(key) != null && appLimitYN.getString(key).equals("Y")) {
							hasValue = true;
						}
					}

					if(hasValue) { //조인할 감사규칙이 하나라도 있으면
						//감사규칙에 해당하는 증빙 정보
						List auditAppLimitList = (CoviList) AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationAuditEvid", params));
						expenceApplication.put("auditAppLimitList", auditAppLimitList);
					}
				}
			}
		}
		
		List getEADiv = (CoviList)AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationDiv", params));
		List getEAFile = (CoviList)AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationFile", params));
		List getEARef = (CoviList)AccountUtil.convertNullToSpace(coviMapperOne.selectList("expenceApplication.selectExpenceApplicationRef", params));
		
		//각 증빙정보 하위에 세부증빙, 파일, 문서연결 삽입
		for(int i = 0; i<getEAList.size(); i++){
			Map itemData =  (Map) getEAList.get(i);
			String listId = itemData.get("ExpenceApplicationListID").toString();
			
			List divList = new ArrayList();
			for(int y = 0; y<getEADiv.size(); y++){
				Map divItem =  (Map) getEADiv.get(y);
				String divListId = divItem.get("ExpenceApplicationListID").toString();
				if(listId.equals(divListId)){
					divList.add(divItem);
				}
			}
			itemData.put("divList", divList);

			List fileList = new ArrayList();
			List fileInfoList = new ArrayList();
			for(int y = 0; y<getEAFile.size(); y++){
				Map fileItem =  (Map) getEAFile.get(y);
				CoviMap fileCM = new CoviMap();
				String fileItemId = fileItem.get("ExpenceApplicationListID").toString();
				if(listId.equals(fileItemId)){
					fileList.add(fileItem);
					fileCM.put("FileID", fileItem.get("FileID"));
					fileInfoList.add(AccountUtil.convertNullToSpace(fileUtil.selectOne(fileCM)));
				}
			}
			itemData.put("fileList", FileUtil.getFileTokenList(fileList));
			itemData.put("fileInfoList", FileUtil.getFileTokenList(fileInfoList));
			
			List docList = new ArrayList();
			for(int y = 0; y<getEARef.size(); y++){
				Map docItem =  (Map) getEARef.get(y);
				String docItemId = docItem.get("ExpenceApplicationListID").toString();
				if(listId.equals(docItemId)){
					docList.add(docItem);
				}
			}
			itemData.put("docList", docList);
			
		}
		expenceApplication.put("pageExpenceAppEvidList", getEAList);
		resultObj.put("result", expenceApplication);
		return resultObj;
	}
	/**
	* @Method Name : searchExpenceApplicationFileList
	* @Description : 각 증빙에 업로드된 파일 목록
	*/
	public CoviMap searchExpenceApplicationFileList(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		List getEAFile = coviMapperOne.selectList("expenceApplication.selectExpenceApplicationFileByListID", params);
		int cnt = (int)(long)coviMapperOne.selectOne("expenceApplication.selectExpenceApplicationFileByListIDCnt", params);
		List fileInfoList = new ArrayList();
		for(int y = 0; y<getEAFile.size(); y++){
			Map fileItem =  (Map) getEAFile.get(y);
			
			CoviMap fileCM = new CoviMap();
			
			fileCM.put("FileID", fileItem.get("FileID"));
			fileInfoList.add(fileUtil.selectOne(fileCM));
		}
		resultObj.put("list", fileInfoList);
		resultObj.put("cnt", cnt);
		return resultObj;
	}

	/**
	* @Method Name : insertExpenceApplication
	* @Description : 비용신청 저장
	*/
	@Override
	public CoviMap insertExpenceApplication(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		CoviMap saveObj = params;
		
		String userID = AccountUtil.jobjGetStr(saveObj,"UserID");
		saveObj.put("SessionUser",  userID);
		saveObj.put("Note", getNote(saveObj));
		
		coviMapperOne.insert("expenceApplication.insertExpApp", saveObj);

		String requestType = AccountUtil.jobjGetStr(saveObj,"RequestType");
		if(requestType.equals("BIZTRIP") || requestType.equals("OVERSEA")) {
			coviMapperOne.insert("biztrip.insertBizTripApplication", saveObj);
		}

		String applicationStatus = AccountUtil.jobjGetStr(saveObj,"ApplicationStatus");
		String applicationType = AccountUtil.jobjGetStr(saveObj,"ApplicationType");
		String expenceApplicationID= AccountUtil.jobjGetStr(params,"ExpenceApplicationID");
		
		String iOCode= AccountUtil.jobjGetStr(params,"IOCode");
		String iOName= AccountUtil.jobjGetStr(params,"IOName");
		String costCenterCode= AccountUtil.jobjGetStr(params,"CostCenterCode");
		String costCenterName= AccountUtil.jobjGetStr(params,"CostCenterName");
		
		CoviList appEvidList = (CoviList) AccountUtil.jobjGetObj(params,"pageExpenceAppEvidList");
		CoviList savedList = new CoviList();
		
		if(appEvidList != null){
			for(int i = 0; i<appEvidList.size(); i++){
				CoviMap evidItem =  appEvidList.getJSONObject(i);
				evidItem.put("ExpenceApplicationID", expenceApplicationID);
				evidItem.put("SessionUser",  userID);
				
				evidItem.put("IOCode", iOCode);
				evidItem.put("IOName", iOName);
				evidItem.put("CostCenterCode", costCenterCode);
				evidItem.put("CostCenterName", costCenterName);
				
				//경비신청은 List/Div구분이 없이 데이터가 넘어오기에 Array화해서 한번 더 넣어줌
				if(applicationType.equals("EA")) {
					CoviList divList= new CoviList();
					divList.add(evidItem);
					evidItem.put("divList", divList);
				}
				
				CoviMap savedItem =  saveExpAppList(evidItem, userID);
				savedList.add(savedItem);
	
				//법인카드, 모바일영수증 상태값 변경
				if("S".equals(applicationStatus)){
					evidItem.put("Active", "I");
				}
				else if("T".equals(applicationStatus)){
					evidItem.put("Active", "Y");
				}
				String proofCode = AccountUtil.jobjGetStr(evidItem,"ProofCode");
				if("CorpCard".equals(proofCode)){
					coviMapperOne.update("expenceApplication.updateCardActive", evidItem);
				}
				else if("Receipt".equals(proofCode)){
					coviMapperOne.update("expenceApplication.updateMobileActive", evidItem);
				}
			}
		}
		resultObj.put("status", "S");
		resultObj.put("getSavedKey", expenceApplicationID);
		resultObj.put("getSavedList", savedList);
		return resultObj;
	}

	/**
	* @Method Name : updateExpenceApplication
	* @Description : 비용신청 저장
	*/
	@Override
	public CoviMap updateExpenceApplication(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();

		CoviMap saveObj = params;
		
		String userID = AccountUtil.jobjGetStr(saveObj,"UserID");
		saveObj.put("SessionUser",  userID);
		saveObj.put("CompanyCode", commonSvc.getCompanyCodeOfUser(userID));
		saveObj.put("Note", getNote(saveObj));
		
		coviMapperOne.update("expenceApplication.updateExpApp", saveObj);
		
		String requestType = AccountUtil.jobjGetStr(saveObj,"RequestType");
		if(requestType.equals("BIZTRIP") || requestType.equals("OVERSEA")) {
			coviMapperOne.update("biztrip.updateBizTripApplication", saveObj);
		}
 
		String applicationStatus = AccountUtil.jobjGetStr(saveObj,"ApplicationStatus");
		String applicationType = AccountUtil.jobjGetStr(saveObj,"ApplicationType");
		String expenceApplicationID = AccountUtil.jobjGetStr(params,"ExpenceApplicationID");
		String processID = AccountUtil.jobjGetStr(saveObj,"ProcessID");
		
		String iOCode= AccountUtil.jobjGetStr(params,"IOCode");
		String iOName= AccountUtil.jobjGetStr(params,"IOName");
		String costCenterCode= AccountUtil.jobjGetStr(params,"CostCenterCode");
		String costCenterName= AccountUtil.jobjGetStr(params,"CostCenterName");
		
		CoviList deleted = (CoviList) AccountUtil.jobjGetObj(params,"pageExpenceAppEvidDeletedList");
		if(deleted != null){
			for(int i = 0; i<deleted.size(); i++){

				CoviMap deletedItem =  deleted.getJSONObject(i);
				CoviMap deletedCM = new CoviMap(deletedItem);
				deleteExpAppList(deletedCM, false);
			}
		}
		
		CoviList appEvidList = (CoviList) AccountUtil.jobjGetObj(params,"pageExpenceAppEvidList");
		CoviList savedList = new CoviList();
		
		if(appEvidList != null){
			for(int i = 0; i<appEvidList.size(); i++){
				CoviMap evidItem =  appEvidList.getJSONObject(i);
				evidItem.put("ExpenceApplicationID", expenceApplicationID);
				evidItem.put("SessionUser",  userID);
				
				evidItem.put("IOCode", iOCode);
				evidItem.put("IOName", iOName);
				evidItem.put("CostCenterCode", costCenterCode);
				evidItem.put("CostCenterName", costCenterName);
				
				evidItem.put("_ApplicationStatus", applicationStatus);
				
				//경비신청은 List/Div구분이 없이 데이터가 넘어오기에 Array화해서 한번 더 넣어줌
				if(applicationType.equals("EA")) {
					CoviList divList= new CoviList();
					divList.add(evidItem);
					evidItem.put("divList", divList);
				}

				CoviMap savedItem = saveExpAppList(evidItem, userID);
				savedList.add(savedItem);

				if("S".equals(applicationStatus)){
					evidItem.put("Active", "I");
				}
				else if("T".equals(applicationStatus)){
					evidItem.put("Active", "Y");
				}
				String proofCode = AccountUtil.jobjGetStr(evidItem,"ProofCode");
				if(!("E".equals(applicationStatus))){
					if("CorpCard".equals(proofCode)){
						coviMapperOne.update("expenceApplication.updateCardActive", evidItem);
					}
					else if("Receipt".equals(proofCode)){
						coviMapperOne.update("expenceApplication.updateMobileActive", evidItem);
					}
				}

				// 결재자 증빙 편집 시 processdescription의 businessdata 수정
				if(!processID.equals("") && i == 0) {
					CoviList divList = (CoviList) AccountUtil.jobjGetObj(evidItem, "divList");
					if(divList != null) {
						CoviMap divItem = divList.getJSONObject(0);
						Double amountSum = 0d;
			    		for(int d = 0; d < appEvidList.size(); d++) {
			    			amountSum += appEvidList.getJSONObject(d).getDouble("divSum");
			    		}
			    		divItem.put("AmountSum", new DecimalFormat("#########.##").format(amountSum));
			    		String subUserCode = AccountUtil.jobjGetStr(saveObj,"Sub_UR_Code");
			    		divItem.put("Sub_UR_Code", subUserCode);
						coviMapperOne.update("expenceApplication.updateBusinessDataForApv", divItem);
					}
				}
			}
		}
		
		resultObj.put("status", "S");
		resultObj.put("getSavedKey", expenceApplicationID);
		resultObj.put("getSavedList", savedList);
		
		return resultObj;
	}
	
	@Override
	public CoviMap expenceApplicationDuplicateCheck(CoviMap params) throws Exception {
		CoviMap returnMap = coviMapperOne.select("expenceApplication.selectExpenceApplicationDuplicateCheck", params);
		if(!"".equals(returnMap.optString("ProcessID"))) {
			returnMap.put("duplChk", "Y");
		}else {
			returnMap.put("duplChk", "N");
		}
		
		return returnMap;
	}

	/**
	* @Method Name : duplCkExpenceApplicationList
	* @Description : 저장시 각 증빙연결번호로 중복체크
	*/
	@Override
	public CoviMap duplCkExpenceApplicationList(CoviMap params) throws Exception {
		CoviMap ckParam = new CoviMap();
		String expenceApplicationID= AccountUtil.jobjGetStr(params,"ExpenceApplicationID");
		CoviList appEvidList = (CoviList) AccountUtil.jobjGetObj(params,"pageExpenceAppEvidList");

		String corpCardList = "";
		String taxBillList = "";
		String cashBillList = "";
		String receiptList = "";
		
		if(appEvidList != null){
			for(int i = 0; i<appEvidList.size(); i++){
				CoviMap evidItem =  appEvidList.getJSONObject(i);
				String proofCode = AccountUtil.jobjGetStr(evidItem, "ProofCode" );
			
				if("CorpCard".equals(proofCode)){
					corpCardList = makeIDListPlainStr(corpCardList, AccountUtil.jobjGetStr(evidItem, "CardUID" ));
				}
				else if("TaxBill".equals(proofCode)){
					taxBillList = makeIDListPlainStr(taxBillList, AccountUtil.jobjGetStr(evidItem, "TaxUID" ));
				}
				else if("CashBill".equals(proofCode)){
					cashBillList = makeIDListPlainStr(cashBillList, AccountUtil.jobjGetStr(evidItem, "CashUID" ));
				}
				else if("Receipt".equals(proofCode)){
					receiptList = makeIDListPlainStr(receiptList, AccountUtil.jobjGetStr(evidItem, "ReceiptID" ));
				}
			}
		}
		
		ckParam.put("ExpenceApplicationID", expenceApplicationID);
		if(corpCardList != null && !corpCardList.equals("")) ckParam.put("CCList", corpCardList.split(","));
		if(taxBillList != null && !taxBillList.equals("")) ckParam.put("TBList", taxBillList.split(","));
		if(cashBillList != null && !cashBillList.equals("")) ckParam.put("CBList", cashBillList.split(","));
		if(receiptList != null && !receiptList.equals("")) ckParam.put("MRList", receiptList.split(","));

		return (CoviMap) AccountUtil.convertNullToSpace(coviMapperOne.selectOne("expenceApplication.selectExpenceApplicationListDuplCk", ckParam));
	}


	/**
	* @Method Name : makeIDListStr
	* @Description : 조회시 중복제거하고 저장하기 위해 in쿼리용 문자열 생성
	*/
	public String makeIDListStr(String list, String inputID) {
		String ret="";
		if(list != null){
			ret = list;
		}
		if(inputID != null){
			if("".equals(list)){
				ret = "'" + inputID + "'";
			}else{
				ret = ret + ",'" + inputID + "'";
			}
		}
		return ret;
	}
	
	public String makeIDListPlainStr(String list, String inputID) {
		String ret="";
		if(list != null){
			ret = list;
		}
		if(inputID != null){
			if("".equals(list)){
				ret = inputID;
			}else{
				ret = ret + "," + inputID;
			}
		}
		return ret;
	}
	
	@Override
	public CoviMap savePrivateDomainData(CoviMap params)throws Exception {
		CoviMap resultObj = new CoviMap();
		
		String tempExpAppID = AccountUtil.jobjGetStr(params, "getSavedKey");
		tempExpAppID = "ACCOUNT_" + tempExpAppID;
		
		CoviMap approvalLine = CoviMap.fromObject(params.get("ApprovalLine"));
		String applicationTitle = AccountUtil.jobjGetStr(params, "ApplicationTitle");
		
		String userName = SessionHelper.getSession("USERNAME");
		String formName = AccountUtil.jobjGetStr(params, "FormName");

		String mapperID = "";
		CoviMap doParams = new CoviMap();
		// 3. 임시저장된 결재선 조회
		if (getPrivateDomainData(tempExpAppID) == 0) {
			// 조회되는 결재선이 없을 경우 insert
			doParams.put("CustomCategory", "APPROVERCONTEXT");
			doParams.put("DefaultYN", null);
			doParams.put("DisplayName", userName + "-" + formName);
			doParams.put("OwnerID", tempExpAppID);
			doParams.put("Abstract", "");
			doParams.put("Description", applicationTitle);
			doParams.put("PrivateContext", approvalLine.toString());
			
			mapperID = "insert";
		} else if (getPrivateDomainData(tempExpAppID) > 0) {
			if (approvalLine != null && approvalLine.size() > 0) {
				// 조회되는 결재선이 있고, 임시저장할 결재선이 있을 경우, update
				doParams.put("OwnerID", tempExpAppID);
				doParams.put("Description", applicationTitle);
				doParams.put("DisplayName", userName + "-" + formName);
				doParams.put("PrivateContext", approvalLine.toString());
				
				mapperID = "update";
			} else {				
				// 조회되는 결재선이 있고, 임시저장할 결재선이 없을 경우, delete
				doParams.put("OwnerID", Objects.toString(tempExpAppID, ""));
				
				mapperID = "delete";
			}
		}
		
		if(!"".equals(mapperID)) {
			coviMapperOne.insert("expence.privatedomaindata." + mapperID, doParams);
		}

		resultObj.put("status", "S");
		return resultObj;
	}
	
	private int getPrivateDomainData(String tempExpAppID) {
		CoviMap params = new CoviMap();
		params.put("OwnerID", Objects.toString(tempExpAppID, ""));
		
		return coviMapperOne.selectOne("expence.privatedomaindata.selectCountTemp", params);
	}
	
	/**
	* @Method Name : getSimpCardInfoList
	* @Description : 간편카드신청 카드사용목록
	*/
	@Override
	public CoviMap getSimpCardInfoList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		//String PropertyCardReceipt = accountUtil.getPropertyInfo("account.searchType.CardReceipt");
		String propertyCardReceipt = accountUtil.getBaseCodeInfo("eAccSearchType", "CardReceipt");
		
		if("".equals(propertyCardReceipt)){
			
			int cnt = (int) coviMapperOne.getNumber("expenceApplication.selectCardReceiptListCnt", params);
			int pageNo		= Integer.parseInt(params.get("pageNo").toString());
			int pageSize	= Integer.parseInt(params.get("pageSize").toString());
			int pageOffset	= (pageNo - 1) * pageSize;
			
			params.put("pageNo",		pageNo);
			params.put("pageSize",		pageSize);
			params.put("pageOffset",	pageOffset);
			
			CoviMap page 	= ComUtils.setPagingData(params,cnt);
			params.addAll(page);
			
			CoviList list = (CoviList)AccountUtil.convertNullToSpace(coviMapperOne.list("expenceApplication.selectCardReceiptList", params));
			
			CoviMap infoMap = new CoviMap();
			for(int i = 0; i<list.size(); i++){
				Map getInfo = (Map) list.get(i);
				String receiptID = mapGetStr(getInfo, "ReceiptID");
				infoMap.put(receiptID, getInfo);
			}
			resultList.put("list", list);
			resultList.put("cnt", cnt);
			resultList.put("page", page);
			resultList.put("infoMap", infoMap);
		}
		else if("SAP".equals(propertyCardReceipt)){
			int cnt=0;
			CoviList list			= new CoviList();
			SimpleDateFormat sdf	= new SimpleDateFormat("YYYYMMdd");
			SimpleDateFormat sdfStr = new SimpleDateFormat("YYYY.MM.dd");
			
			CoviMap interfaceParam	= new CoviMap();

			String PERNR		= "";
			String LOGID		= "";
			String ENAME		= "";
			String BUKRS		= "";
			String SCRNO		= "";
			String NO_MASK		= "";
			String SPRAS		= "";
			String I_SDATE		= "";
			String I_EDATE		= "";
			String I_GUBUN		= "";
			String I_GUBUN2		= "";
			String I_PERENR		= "";
			String I_CARDNO		= "";
			String I_MERCHNAME	= "";

			CoviMap setValues = new CoviMap();
			
			setValues.put("PERNR",			PERNR);
			setValues.put("LOGID",			LOGID);
			setValues.put("ENAME",			ENAME);
			setValues.put("BUKRS",			BUKRS);
			setValues.put("SCRNO",			SCRNO);
			setValues.put("NO_MASK",		NO_MASK);
			setValues.put("SPRAS",			SPRAS);
			setValues.put("I_SDATE",		I_SDATE);
			setValues.put("I_EDATE",		I_EDATE);
			setValues.put("I_GUBUN",		I_GUBUN);
			setValues.put("I_GUBUN2",		I_GUBUN2);
			setValues.put("I_PERENR",		I_PERENR);
			setValues.put("I_CARDNO",		I_CARDNO);
			setValues.put("I_MERCHNAME",	I_MERCHNAME);

			ArrayList getValues = new ArrayList();
			//getValues.add("get1");
			//getValues.add("get2");
			//getValues.add("get3");
			interfaceParam.put("mapFunctionName",	"getSapMap");
			interfaceParam.put("tableName",			"");
			interfaceParam.put("sapFunctionName",	"ZFI_IF_F7001_SEND");
			interfaceParam.put("setValues",			setValues);
			interfaceParam.put("getValues",			getValues);
			
			String pApproveDateS	= rtString(params.get("approveDateS"));
			String pApproveDateE	= rtString(params.get("approveDateE"));
			String pCardNo			= rtString(params.get("cardNo"));
			String pCardUserCode	= rtString(params.get("UR_Code"));
			
			pApproveDateS = pApproveDateS.replaceAll("[^0-9]", "-");
			pApproveDateE = pApproveDateE.replaceAll("[^0-9]", "-");
			
			interfaceParam.put("interFaceType",			propertyCardReceipt);
			
			interfaceParam.put("daoClassName",			"CardReceiptDao");
			interfaceParam.put("voClassName",			"CardReceiptVO");
			interfaceParam.put("mapClassName",			"CardReceiptMap");

			interfaceParam.put("daoSetFunctionName",	"setCardReceiptList");
			interfaceParam.put("daoGetFunctionName",	"getCardReceiptList");
			interfaceParam.put("voFunctionName",		"setAll");
			
			CardReceiptVO cardReceiptVO = new CardReceiptVO();
			
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
				Date today = new Date();

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
				String receiptID = mapGetStr(getInfo, "ReceiptID");
				infoMap.put(receiptID, getInfo);
			}
			resultList.put("list", AccountUtil.convertNullToSpace(list));
			resultList.put("cnt", cnt);
			resultList.put("infoMap", AccountUtil.convertNullToSpace(infoMap));
		}
		else if("SOAP".equals(propertyCardReceipt)){
			int cnt=0;
			CoviList list			= new CoviList();
			SimpleDateFormat sdf	= new SimpleDateFormat("YYYYMMdd");
			SimpleDateFormat sdfStr = new SimpleDateFormat("YYYY.MM.dd");
			
			CoviMap interfaceParam	= new CoviMap();
			interfaceParam.put("mapFunctionName",	"getSoapMap");
			interfaceParam.put("soapName",			"XpenseGetCardReceiptList");
			interfaceParam.put("soapAction",		"http://tempuri.org/XpenseGetCardReceiptList");
			
			String pApproveDateS	= rtString(params.get("approveDateS"));
			String pApproveDateE	= rtString(params.get("approveDateE"));
			String pCardNo			= rtString(params.get("cardNo"));
			String pCardUserCode	= rtString(params.get("UR_Code"));
			
			pApproveDateS = pApproveDateS.replaceAll("[^0-9]", "-");
			pApproveDateE = pApproveDateE.replaceAll("[^0-9]", "-");
			
			CoviMap xmlParam = new CoviMap();
			

			int pageSize = params.getInt("pageSize");
			int pageNo = params.getInt("pageNo");
			
			xmlParam.put("pPageSize",			pageSize);
			xmlParam.put("pPageCurrent",		pageNo);
			
			if(!pApproveDateS.equals("")){	xmlParam.put("pSDate",		pApproveDateS);}
			if(!pApproveDateE.equals("")){	xmlParam.put("pEDate",		pApproveDateE);}
			if(!pCardUserCode.equals("")){	xmlParam.put("pCarduser",	pCardUserCode);}
			if(!pCardNo.equals("")){		xmlParam.put("pCardNo",		pCardNo);}
			
			interfaceParam.put("xmlParam",		xmlParam);

			interfaceParam.put("interFaceType",			propertyCardReceipt);
			
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
				
				if(propertyCardReceipt.equals("SOAP")){
					active		= "N";
					infoIndex	= "A";
				}
				
				if(totalCount.equals("")){
					totalCount = "0";
				}
				
				cardNo		= cardNo.replaceAll("[^0-9]", "");
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
				Date today = new Date();

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
				String receiptID = mapGetStr(getInfo, "ReceiptID");
				infoMap.put(receiptID, getInfo);
			}
			resultList.put("list", AccountUtil.convertNullToSpace(list));
			resultList.put("cnt", cnt);
			resultList.put("infoMap", AccountUtil.convertNullToSpace(infoMap));
		}
		return resultList;
	}
	
	/**
	* @Method Name : getSimpReceiptInfoList
	* @Description : 간편신청 모바일 영수증 업로드 목록
	*/
	@Override
	public CoviMap getSimpReceiptInfoList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("expenceApplication.getMobileReceiptListCnt", params);
		CoviList list = coviMapperOne.list("expenceApplication.getMobileReceiptList", params);
		
		CoviMap infoMap = new CoviMap();
		for(int i = 0; i<list.size(); i++){
			Map getInfo = (Map) list.get(i);
			String receiptID = mapGetStr(getInfo, "ReceiptID");
			infoMap.put(receiptID, getInfo);
		}
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("infoMap", AccountUtil.convertNullToSpace(infoMap));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	* @Method Name : mapGetStr
	* @Description : map에서 값 획득
	*/
	public String mapGetStr(Map params, String key) {
		String retVal = "";
		if(params.get(key) != null){
			retVal = params.get(key).toString();
		}
		return retVal;
	}
	
	/**
	* @Method Name : getCardReceiptDetail
	* @Description : 카드사용내역 상세 조회
	*/
	public CoviMap getCardReceiptDetail(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.getCardReceiptDetail", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list
				, "ReceiptID,ItemNo,CardNo,ApproveNo,UseDate,StoreName,StoreNo,StoreRepresentative,StoreRegNo,StoreTel,StoreAddress,StoreCondition,RepAmount,TaxAmount,ServiceAmount,AmountWon,InfoIndex"));
		return resultList;
	}
	
	/**
	* @Method Name : deleteExpenceApplicationManList
	* @Description : 증빙 삭제
	*/
	@Override
	public CoviMap deleteExpenceApplicationManList(CoviMap params, String deleteType) throws Exception {
		CoviMap resultObj	= new CoviMap();
		StringBuilder workItemArchiveIDs = new StringBuilder();
		
		CoviList deleteList = (CoviList) AccountUtil.jobjGetObj(params,"deleteList");
		if(deleteList != null){
			for(int i=0; i<deleteList.size(); i++){
				CoviMap deletedItem =  deleteList.getJSONObject(i);
				CoviMap deletedMap = new CoviMap(deletedItem);
				String applicationStatus = deletedMap.getString("ApplicationStatus");
				
				if("app".equals(deleteType) && applicationStatus.equals("R")) {
					CoviMap changeMap = new CoviMap();
					changeMap.put("ApplicationStatus", "DELETE");
					changeMap.put("SessionUser", SessionHelper.getSession("UR_Code"));
					changeMap.put("ExpenceApplicationID", deletedMap.getString("ExpenceApplicationID"));
					
					//반려 건 삭제 시 단순 삭제 마킹
					coviMapperOne.update("expenceApplication.statChangeExpenceApplicationManList", changeMap); //DELETE
					
					//결재문서 삭제 마킹을 위해 WorkItemArchiveID 가져오기
					workItemArchiveIDs.append(coviMapperOne.getString("expenceApplication.getWorkItemArchiveIDForDelMarking", changeMap));
					workItemArchiveIDs.append(",");

					//예산집행 내역 삭제 마킹
					if(RedisDataUtil.getBaseConfig("eAccIsUseBudget").equals("Y")) { //accountUtil.getPropertyInfo("account.searchType.Budget")
						expAppUpdateBudgetStatus(changeMap); //D
					}
					
					//출장정산 삭제 마킹
					if(deletedMap.getString("RequestType").equals("BIZTRIP") || deletedMap.getString("RequestType").equals("OVERSEAS")) {
						coviMapperOne.update("biztrip.updateBizTripAppStatus", changeMap); //DELETE
					}
				} else {
					//신청별, 증빙별 분기
					if("app".equals(deleteType)){
						List list = coviMapperOne.selectList("expenceApplication.selectExpAppListForDelete", deletedMap);
						for(int y = 0; y<list.size(); y++){
							CoviMap listInfoMap = (CoviMap) list.get(y);
							deleteExpAppList(listInfoMap, true);
						}
					}
					else if("list".equals(deleteType)){
						deleteExpAppList(deletedMap, true);
					}
				}
			}
		}
		resultObj.put("status", "S");
		resultObj.put("WorkItemArchiveIDs", workItemArchiveIDs.toString());
		return resultObj;
	}
	
	/**
	* @Method Name : deleteExpAppList
	* @Description : 증빙 list단위 삭제
	*/
	private void deleteExpAppList(CoviMap deletedMap, boolean deleteExpApp) throws Exception {
		
		//삭제/반려 시 Active 값 변경
		CoviMap params = new CoviMap();
		params.put("DomainID", SessionHelper.getSession("DN_ID"));
		params.put("ExpenceApplicationID", deletedMap.getString("ExpenceApplicationID"));
		params.put("Active", "N");
		params.put("ApplicationStatus", "DELETE");
		
		expAppUpdateActive(params);
		
		List list = coviMapperOne.selectList("expenceApplication.selectExpAppFileForDelete", deletedMap);
		for(int y = 0; y<list.size(); y++){
			Map fileInfo = (Map) list.get(y); 
			if(fileInfo.get("FileID")!=null){
				//accountFileUtil.deleteFileByID(fileInfo.get("FileID").toString());
				fileUtil.deleteFileByID(fileInfo.get("FileID").toString(), true);
			}
		}
		coviMapperOne.delete("expenceApplication.deleteExpAppFile", deletedMap);
		coviMapperOne.delete("expenceApplication.deleteExpAppDoc", deletedMap);
		coviMapperOne.delete("expenceApplication.deleteExpAppDiv", deletedMap);
		coviMapperOne.delete("expenceApplication.deleteExpAppList", deletedMap);

		params.put("OwnerID", "ACCOUNT_" + deletedMap.getString("ExpenceApplicationID"));
		coviMapperOne.delete("expenceApplication.deletePrivateDomainData", params);
		
		//자체 DB면 공백값으로 프로퍼티를 받음
		String proofCode = deletedMap.getString("ProofCode");
		if("CorpCard".equals(proofCode)){
			//String PropertyCardReceipt = accountUtil.getPropertyInfo("account.searchType.CardReceipt");
			String propertyCardReceipt = accountUtil.getBaseCodeInfo("eAccSearchType", "CardReceipt");
			if(!"".equals(propertyCardReceipt)){
				coviMapperOne.delete("expenceApplication.deleteIFCorpCardReceiptFromExpAppList", deletedMap);
			}
		}else if("TaxBill".equals(proofCode)){
			//String PropertyTaxInvoice = accountUtil.getPropertyInfo("account.searchType.TaxInvoice");
			String propertyTaxInvoice = accountUtil.getBaseCodeInfo("eAccSearchType", "TaxInvoice");
			if(!"".equals(propertyTaxInvoice)){
				coviMapperOne.delete("expenceApplication.deleteIFTaxBillFromExpAppList", deletedMap);
			}
		}
		
		//모든 리스트가 삭제되었을 시 신청 삭제
		//전표관리 메뉴에서 삭제할 시 이용
		if(deleteExpApp){
			int cnt		= (int) coviMapperOne.getNumber("expenceApplication.deleteExpAppCntList" , deletedMap);
			if(cnt==0){
				coviMapperOne.delete("expenceApplication.deleteExpApp", deletedMap);
				coviMapperOne.delete("biztrip.deleteBizTripApplication", deletedMap);
			}
		}
	}

	/**
	* @Method Name : getUserCC
	* @Description : 간편신청. 유저의 기본 CC 조회
	*/
	@Override
	public CoviMap getUserCC(CoviMap params) throws Exception {
		CoviMap resultObj	= new CoviMap();
		
		//CoviMap params = new CoviMap();

		String userCode = SessionHelper.getSession("UR_Code");		
		params.put("UserCode", userCode);
		params.put("companyCode", commonSvc.getCompanyCodeOfUser(userCode));
		CoviMap userInfo = coviMapperOne.selectOne("expenceApplication.getUserCC", params);

		resultObj.put("info", AccountUtil.convertNullToSpace(userInfo));
		resultObj.put("status", "S");
		
		return resultObj;
	}

	/**
	* @Method Name : searchExpenceApplicationReviewList
	* @Description : 리뷰 목록 조회
	*/
	public CoviMap searchExpenceApplicationReviewList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap coviParams = new CoviMap();
		coviParams.addAll(params);

		int pageNo		= Integer.parseInt(coviParams.get("pageNo").toString());
		int pageSize	= Integer.parseInt(coviParams.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		coviParams.put("pageNo",		pageNo);
		coviParams.put("pageSize",		pageSize);
		coviParams.put("pageOffset",	pageOffset);
		
		int cnt = (int)coviMapperOne.getNumber("expenceApplication.selectExpenceApplicationReviewListCnt", coviParams);
		
		CoviMap page = ComUtils.setPagingData(coviParams,cnt);
		coviParams.addAll(page);		
		
		CoviList list = coviMapperOne.list("expenceApplication.selectExpenceApplicationReviewList", coviParams);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList;
	}
	
	/**
	* @Method Name : makeSlip
	* @Description : 전표 작성
	*/
	@Override
	public CoviMap makeSlip(CoviMap params) throws Exception {
		//String slipType = accountUtil.getPropertyInfo("account.syncType.slipType");
		String slipType = accountUtil.getBaseCodeInfo("eAccSyncType", "slipType");
		
		CoviMap resultObj	= new CoviMap();
		CoviList makeList = (CoviList) AccountUtil.jobjGetObj(params,"makeList");
		
		if(makeList != null){
			if(slipType.equals("SOAP")) {
				//callMakeSlipBulk(makeList, params);
			} else {
				for(int i=0; i<makeList.size(); i++){
					CoviMap getItem =  makeList.getJSONObject(i);
					callMakeSlip(getItem, params);
				}
			}
		} else if(params.getString("ExpenceApplicationID") != null) { 
			//전표조회 팝업에서 전표 발행 시 신청 1건 전체에 대한 발행이므로 makeSlipAuto 호출
			CoviMap slipParam = new CoviMap();
			slipParam.addAll(params);
			makeSlipAuto(slipParam, null);
		}
		resultObj.put("status", "S");
		return resultObj;
	}
	
	/**
	* @Method Name : unMakeSlip
	* @Description : 전표 취소(역발행)
	*/
	@Override
	public CoviMap unMakeSlip(CoviMap params) throws Exception {
		//String slipType = accountUtil.getPropertyInfo("account.syncType.slipType");
		String slipType = accountUtil.getBaseCodeInfo("eAccSyncType", "slipType");
		
		CoviMap resultObj	= new CoviMap();
		CoviMap slipParam = new CoviMap();
		slipParam.addAll(params);

		String userID = SessionHelper.getSession("USERID");
		
		CoviList makeList = coviMapperOne.list("expenceApplication.selectAutoSlipMakeList", slipParam);
		
		if(makeList != null){
			if(slipType.equals("SOAP")) {
				CoviList makeListBulk = new CoviList();
				makeListBulk.addAll(makeList);
				//callMakeSlipBulk(makeListBulk, params, "N");
			} else {
				for(int i=0; i<makeList.size(); i++){
					CoviMap getItem =  makeList.getMap(i);
					CoviMap setItem = new CoviMap();
					setItem.put("ExpenceApplicationListID", getItem.get("ExpenceApplicationListID"));
					callMakeSlip(setItem, params);
				}
			}
			for(int i=0; i<makeList.size(); i++){
				CoviMap getItem =  makeList.getMap(i);
				CoviMap updateCoviMap = new CoviMap();
				updateCoviMap.put("ExpenceApplicationID", params.getString("ExpenceApplicationID"));
				updateCoviMap.put("ProcessID", getItem.get("ProcessID"));
				updateCoviMap.put("ApplicationStatus", "R");
				updateCoviMap.put("UR_Code", userID);
				updateCoviMap.put("SessionUser", userID);
				updateCoviMap.put("Comment", "전표 취소");
				updateCoviMap.put("Active", "Y");
				if(coviMapperOne.update("expenceApplication.statChangeExpenceApplicationManList", updateCoviMap) > 0) {
					expAppUpdateActive(updateCoviMap);
				}
			}
		}
		resultObj.put("status", "S");
		return resultObj;
	}
	
	/**
	* @Method Name : makeSlipAuto
	* @Description : 결재에서 호출하는 자동 전표 발행
	*/
	@Override
	public CoviMap makeSlipAuto(CoviMap params, CoviMap slipInfo) throws Exception {
		//String slipType = accountUtil.getPropertyInfo("account.syncType.slipType");
		String slipType = accountUtil.getBaseCodeInfo("eAccSyncType", "SlipType");
		
		//전표연동 api 호출 : 연계시스템에 expenceApplicationID 전송
		if(slipType.equals("API")) {
			String httpCommURL = "";
			String accountURL = PropertiesUtil.getGlobalProperties().getProperty("account.legacy.path");
			httpCommURL = accountURL + "/api/slip/sendExpenceApplicationID.do";
			HttpsUtil httpsUtil = new HttpsUtil();
			String strResult = httpsUtil.httpsClientWithRequest(httpCommURL, "POST", params, "UTF-8", null);
			CoviMap resultObj = CoviMap.fromObject(strResult);
			if(!"SUCCESS".equals(resultObj.getString("status"))) {
				if(resultObj.has("message")) {
					throw new Exception(resultObj.getString("message"));
				} else {
					throw new Exception(DicHelper.getDic("msg_apv_030"));
				}
			}
		}
		CoviMap resultObj	= new CoviMap();
		CoviList makeList = coviMapperOne.list("expenceApplication.selectAutoSlipMakeList", params);
		
		if(makeList != null){
			if(slipType.equals("SOAP")) {
				CoviList makeListBulk = new CoviList();
				makeListBulk.addAll(makeList);
				//callMakeSlipBulk(makeListBulk, slipInfo);
			} else {
				for(int i=0; i<makeList.size(); i++){
					CoviMap getItem =  makeList.getMap(i);
					CoviMap setItem = new CoviMap();
					setItem.put("ExpenceApplicationListID", getItem.get("ExpenceApplicationListID"));
					callMakeSlip(setItem, slipInfo);
				}
			}
		}
		resultObj.put("status", "S");
		return resultObj;
	}

	public void callMakeSlip(CoviMap getItem, CoviMap slipInfo) throws Exception {

		CoviMap getMap = coviMapperOne.selectOne("expenceApplication.makeSlipNo", getItem);

		String setPayDay = "";
		String setPostingDate = "";
		
		if(slipInfo != null){
			setPayDay = AccountUtil.jobjGetStr(slipInfo, "PayDayDate");
			setPostingDate = AccountUtil.jobjGetStr(slipInfo, "PostingDateDate");
			getMap.put("PostingDateCk", AccountUtil.jobjGetStr(slipInfo, "PostingDateCk"));
			getMap.put("PayDayCk", AccountUtil.jobjGetStr(slipInfo, "PayDayCk"));
			getMap.put("SetPayDay", setPayDay);
			getMap.put("SetPostingDate", setPostingDate);
		}else{
			getMap.put("PayDayCk", "Y");
			getMap.put("PostingDateCk", "Y");
		}
		
		//String slipType = accountUtil.getPropertyInfo("account.syncType.slipType");
		String slipType = accountUtil.getBaseCodeInfo("eAccSyncType", "slipType");
		
		if("SAP".equals(slipType)){
			if("".equals(setPayDay)){
				setPayDay = getMap.getString("PayDay");
			}
			if("".equals(setPostingDate)){
				setPostingDate = getMap.getString("PostingDate");
			}
			//프로퍼티에 따라 인터페이스를 통해 전표번호를 가져와야함
			long docno =  9999999;
			getMap.put("DocNo", docno);
		}
		coviMapperOne.update("expenceApplication.updateSlipInfo", getMap);
	}
	
	/**
	* @Method Name : reverseExpApp
	* @Description : 역분개
	*/
	@Override
	public CoviMap reverseExpApp(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		
		params.put("SessionUser", SessionHelper.getSession("UR_Code"));
		
		// 증빙상태 미정산으로 변경
		resultObj = expAppUpdateEvidActive(params);

		// 신청건 상태 전표취소로 변경
		int cnt = coviMapperOne.update("expenceApplication.statChangeExpenceApplicationManList", params);
		
		return resultObj;
	}
	
	/**
	* @Method Name : expAppAprvStatCk
	* @Description : 결재 상태 변경전 현재 상태값 체크
	*/
	@Override
	public boolean expAppAprvStatCk(CoviMap params) throws Exception {
		CoviList aprvList = (CoviList) AccountUtil.jobjGetObj(params,"aprvList");
		String setStat = AccountUtil.jobjGetStr(params,"setStatus");

		boolean retVal = false;
		CoviMap statCkParam = new CoviMap();
		String ckList = "";
		if(aprvList != null) {
			for(int i=0; i<aprvList.size(); i++){
				CoviMap getItem =  aprvList.getJSONObject(i);
				String expAppId = AccountUtil.jobjGetStr(getItem,"ExpenceApplicationID");
				ckList = makeIDListPlainStr(ckList, expAppId);
			}
		}
		
		if(ckList != null && !ckList.equals("")) statCkParam.put("ExpenceApplicationIDList", ckList.split(","));
		if("T".equals(setStat)
				||"E".equals(setStat)
				||"R".equals(setStat)){
			//신청, 기안
			statCkParam.put("ckStatList", new String [] { "S","D"});
		}
		int ckCnt = (int)coviMapperOne.getNumber("expenceApplication.statCheckExpenceApplication", statCkParam);
		if(ckCnt == 0){
			retVal = true;
		}
		return retVal;
	}
	
	/**
	* @Method Name : statChangeExpenceApplicationManList
	* @Description : 승인상태 변경
	*/
	@Override
	public CoviMap statChangeExpenceApplicationManList(CoviMap params, String inputType) throws Exception {
		CoviMap resultObj	= new CoviMap();
		
		CoviList aprvList = (CoviList) AccountUtil.jobjGetObj(params,"aprvList");
		CoviMap changedList	= new CoviMap();

		String setStat = AccountUtil.jobjGetStr(params,"setStatus");
		String sessionUser = SessionHelper.getSession("UR_Code");
		
		if(aprvList != null){
			for(int i=0; i<aprvList.size(); i++){
				CoviMap getItem =  aprvList.getJSONObject(i);

				String getId = AccountUtil.jobjGetStr(getItem,"ExpenceApplicationID");
				//list단위일 경우 동일한 ExpAppID가 여러번 들어올 가능성이 있으니 한번 처리 한 대상은 처리 안함
				String ckId = AccountUtil.jobjGetStr(changedList,getId);
				if(ckId==null || "".equals(ckId)){
					getItem.put("ApplicationStatus", setStat);
					getItem.put("SessionUser", sessionUser);
					coviMapperOne.update("expenceApplication.statChangeExpenceApplicationManList", getItem);
					changedList.put(getId, getId);
				}

				//삭제/반려 시 Active 값 변경
				if(setStat.equals("R")) {
					CoviMap activeParams = new CoviMap();
					activeParams.put("ExpenceApplicationID", getId);
					activeParams.put("UR_Code", SessionHelper.getSession("UR_Code"));
					activeParams.put("SessionUser", SessionHelper.getSession("UR_Code"));
					activeParams.put("Active", "N");
					activeParams.put("ApplicationStatus", setStat);
					expAppUpdateActive(activeParams);
				}
			}
		}

		resultObj.put("status", "S");
		return resultObj;
	}
	
	/**
	 * @Method getMobileReceiptList
	 * @작성자 Covision
	 * @작성일 2018. 6. 25
	 * @param params
	 * @throws Exception
	 */
	@Override
	public CoviMap getMobileReceiptList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt		= (int) coviMapperOne.getNumber("expenceApplication.getMobileReceiptListCnt" , params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list	= coviMapperOne.list("expenceApplication.getMobileReceiptList", params);
		
		//page	= accountUtil.listPageCount(cnt,params);
		
		resultList.put("list",	AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList; 
	}
	
	/**
	* @Method Name : getMobileReceipt
	* @Description : 모바일 영수증 등록내역 조회
	*/
	@Override
	public CoviMap getMobileReceipt(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.getMobileReceipt", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ReceiptID,ProofCode,CompanyCode,ExpenceMgmtCode,UsageText,UseDate,UseTime,StoreName,StoreAddress,TotalAmount,ProofDateStr,PhotoDate,PhotoDateStr,PhotoDateFull,ReceiptType,ReceiptFileID,Active,ActiveName,RegisterID,RegistDate,RegistDateStr,StandardBriefID,StandardBriefName"));
		
		return resultList;
	}

	/**
	* @Method Name : deleteMobileReceipt
	* @Description : 모바일 영수증 삭제
	*/
	@Override
	public CoviMap deleteMobileReceipt(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		@SuppressWarnings("unchecked")
		ArrayList<Map<String, Object>> chkList	= (ArrayList<Map<String, Object>>) params.get("chkList");

		params.put("UR_Code", SessionHelper.getSession("UR_Code"));
		
		if(!chkList.isEmpty()){
			for(int i=0; i<chkList.size(); i++){
				CoviMap info = new CoviMap(chkList.get(i));
				params.put("receiptID", info.get("ReceiptID"));
				coviMapperOne.delete("expenceApplication.deleteMobileReceipt", params);
			}
		}
		return resultList;
	}
	
	/**
	* @Method Name : insertMobileReceipt
	* @Description : 모바일 영수증 삽입
	*/
	@Override
	public CoviMap insertMobileReceipt(CoviMap params) throws Exception {
		params.put("CompanyCode", commonSvc.getCompanyCodeOfUser(params.getString("SessionUser")));
		CoviMap resultList	= new CoviMap();
		coviMapperOne.insert("expenceApplication.insertMobileReceipt", params);
		return resultList;
	}
	
	/**
	* @Method Name : updateMobileReceipt
	* @Description : 모바일 영수증 수정
	*/
	@Override
	public CoviMap updateMobileReceipt(CoviMap params) throws Exception {
		params.put("CompanyCode", commonSvc.getCompanyCodeOfUser(params.getString("SessionUser")));
		CoviMap resultList	= new CoviMap();
		coviMapperOne.insert("expenceApplication.updateMobileReceipt", params);
		return resultList;
	}
	
	/**
	* @Method Name : updateCorpCardReceipt
	* @Description : 모바일 영수증 수정
	*/
	@Override
	public CoviMap updateCorpCardReceipt(CoviMap params) throws Exception {
		params.put("CompanyCode", commonSvc.getCompanyCodeOfUser(params.getString("SessionUser")));
		CoviMap resultList	= new CoviMap();
		coviMapperOne.insert("expenceApplication.updateCorpCardReceipt", params);
		return resultList;
	}
	
	/**
	* @Method Name : setExpenceApplicationSync
	* @Description : 전표동기화
	*/
	@Override
	public CoviMap setExpenceApplicationSync(CoviMap params){
		CoviMap resultList	= new CoviMap();
		CoviMap interfaceParam	= new CoviMap();
		List interFaceList		= new CoviList();
		CoviMap setInterface	= new CoviMap();

		boolean keyTF	= false;
		String keyIDs	= "";
		int keyIDLen	= 0;
		
		ArrayList<Map<String, Object>> syncList	= (ArrayList<Map<String, Object>>) params.get("syncList");
		if(!syncList.isEmpty()){
			StringBuffer buf = new StringBuffer();
			for(int i=0; i<syncList.size(); i++){
				String key = rtString(syncList.get(i).get("ExpenceApplicationID"));
				//keyIDs += key + "','";
				buf.append(key).append(",");
			}
			keyIDs += buf.toString();
			keyIDLen = keyIDs.length()-1;
			
			if(keyIDLen > 0){
				keyIDs = keyIDs.substring(0,keyIDLen);
				params.put("keyIDs", keyIDs.split(","));
				keyTF = true;
			}else{
				keyTF = false;
			}
		}
		
		if(keyTF){	
			//EVIDENCE START
			interFaceList = coviMapperOne.selectList("expenceApplication.getInterFaceListEVIDENCE", params);
		
			//interfaceParam 정의
			interfaceParam.put("interFaceType",		"DB");
			interfaceParam.put("type",				"set");
		
			interfaceParam.put("mapClassName",		"ExpenceApplicationMap");
			interfaceParam.put("mapFunctionName",	"getMap");
		
			interfaceParam.put("cntKeySql",			"accountInterFace.Account.cntKeyInterFaceEVIDENCE");
			interfaceParam.put("insertSql",			"accountInterFace.Account.insertInterFaceEVIDENCE");
			interfaceParam.put("updateSql",			"accountInterFace.Account.updateInterFaceEVIDENCE");
			interfaceParam.put("deleteSql",			"accountInterFace.Account.deleteInterFaceEVIDENCE");
		
			interfaceParam.put("interFaceList",		interFaceList);
		
			//interface 호출
			setInterface = interfaceUtil.startInterface(interfaceParam);
			resultList.put("evidenceResult", setInterface);
			//EVIDENCE END
		
			//EVIDENCE_DIVISION START
			interfaceParam	= new CoviMap();
			setInterface	= new CoviMap();
			interFaceList	= new CoviList();
			
			interFaceList = coviMapperOne.selectList("expenceApplication.getInterFaceListEVIDENCEDIVISION", params);
		
			//interfaceParam 정의
			interfaceParam.put("interFaceType",		"DB");
			interfaceParam.put("type",				"set");
		
			interfaceParam.put("mapClassName",		"ExpenceApplicationMap");
			interfaceParam.put("mapFunctionName",	"getMap");
		
			interfaceParam.put("cntKeySql",			"accountInterFace.Account.cntKeyInterFaceEVIDENCEDIVISION");
			interfaceParam.put("insertSql",			"accountInterFace.Account.insertInterFaceEVIDENCEDIVISION");
			interfaceParam.put("updateSql",			"accountInterFace.Account.updateInterFaceEVIDENCEDIVISION");
			interfaceParam.put("deleteSql",			"accountInterFace.Account.deleteInterFaceEVIDENCEDIVISION");
		
			interfaceParam.put("interFaceList",		interFaceList);
		
			//interface 호출
			setInterface = interfaceUtil.startInterface(interfaceParam);
			resultList.put("evidenceDivisionResult", setInterface);
			
			//EVIDENCE_DIVISION END
		}else{
			resultList.put("status",	Return.FAIL);
		}
		return resultList;
	}
	
	/**
	* @Method Name : getExpenceApplicationSync
	* @Description : 전표데이터 인터페이스 전송
	*/
	@Override
	public CoviMap getExpenceApplicationSync(){

		CoviMap interfaceParam = new CoviMap();
		CoviMap resultList = new CoviMap();
		
		try {
			ExpenceApplicationVO expenceApplicationVO = null;
	
			//interfaceParam 정의
			//String syncType = accountUtil.getPropertyInfo("account.syncType.CostCenter");
			String syncType = accountUtil.getBaseCodeInfo("eAccSyncType", "CostCenter");
			
			interfaceParam.put("interFaceType",			syncType);
	
			interfaceParam.put("daoClassName",			"ExpenceApplicationDao");
			interfaceParam.put("voClassName",			"ExpenceApplicationVO");
			interfaceParam.put("mapClassName",			"ExpenceApplicationMap");
	
			interfaceParam.put("daoSetFunctionName",	"setExpenceApplicationList");
			interfaceParam.put("daoGetFunctionName",	"getExpenceApplicationList");
			interfaceParam.put("voFunctionName",		"setAll");
			interfaceParam.put("mapFunctionName",		"getMap");
	
			switch (syncType) {
				case "DB":
					//syncType이 DB인 경우 이곳에 정의
					interfaceParam.put("type",		"get");
					interfaceParam.put("sqlName",	"accountInterFace.Account.getInterFaceListExpenceApplication");
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
			//interface 호출
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
	
			ArrayList list = (ArrayList) getInterface.get("list");
	
			for (int i = 0; i < list.size(); i++) {
				CoviMap listInfo = new CoviMap();
				expenceApplicationVO = (ExpenceApplicationVO) list.get(i);
				
				//act_expence_application
				String formInstId				= expenceApplicationVO.getform_inst_id();
				String applicationTitle			= expenceApplicationVO.getApplicationTitle();	//신청제목
				String applicationDate			= expenceApplicationVO.getApplicationDate();	//신청일
				String userCode					= expenceApplicationVO.getUr_code();			//결재행위자
	
				//act_expence_application_list
				String evidenceIndex			= expenceApplicationVO.getevidence_index();
				String proofDate				= expenceApplicationVO.getProofDate();			//증빙일자
				String proofCode				= expenceApplicationVO.getProofCode();			//증빙타입
				String cardUID					= expenceApplicationVO.getCardUID();		//카드승인번호
				String taxType					= expenceApplicationVO.getTaxType();			//세금유형
				String taxCode					= expenceApplicationVO.getTaxCode();			//세금코드
				String payAdjustMethod			= expenceApplicationVO.getPayAdjustMethod();	//정산방법
				String payMethod				= expenceApplicationVO.getPayMethod();			//지급방법
				String vendorNo					= expenceApplicationVO.getVendorNo();			//거래처등록번호
				String totalAmount				= expenceApplicationVO.getTotalAmount();		//합계액
				String docNo					= expenceApplicationVO.getDocNo();				//전표번호
	
				//act_expence_application_div
				String divisionIndex			= expenceApplicationVO.getdivision_index();
				String accountCode				= expenceApplicationVO.getAccountCode();		//계정과목
				String costCenterCode			= expenceApplicationVO.getCostCenterCode();		//코스트센터코드
				String amount					= expenceApplicationVO.getAmount();				//금액
				String usageComment				= expenceApplicationVO.getUsageComment();		//사용내역
				
				//데이터 구조가 다른 관계로  임시로 셋팅
				String companyCode			= "GENERAL"; //회사코드
				String applicationType		= "EA";		 //신청유형
				String applicationStatus	= "E";		 //신청상태(임시저장:T,기안:D, 진행:P, 반려:R, 완료:E, 취소:C)
				String requestType			= "NORMAL";
				
				String interfaceKeyID		= formInstId;
				String interfaceKeyList	= formInstId + evidenceIndex;
				String interfaceKeyDiv		= formInstId + divisionIndex;
				
				applicationDate	= applicationDate.replaceAll("-", "");
				proofDate		= proofDate.replaceAll("-", "");
				
				//listInfo 셋팅
				listInfo.put("companyCode",			companyCode);
				listInfo.put("applicationType",		applicationType);
				listInfo.put("applicationStatus",	applicationStatus);
				listInfo.put("requestType",			requestType);
				
				listInfo.put("interfaceKeyID",		interfaceKeyID);
				listInfo.put("interfaceKey_list",	interfaceKeyList);
				listInfo.put("interfaceKey_Div",	interfaceKeyDiv);
				
				//act_expence_application
				listInfo.put("form_inst_id",		formInstId);
				listInfo.put("applicationTitle",	applicationTitle);	//신청제목
				listInfo.put("applicationDate",		applicationDate);	//신청일
				listInfo.put("ur_code",				userCode);			//결재행위자
	
				//act_expence_application_list
				listInfo.put("evidence_index",		evidenceIndex);
				listInfo.put("proofDate",			proofDate);			//증빙일자
				listInfo.put("proofCode",			proofCode);			//증빙타입
				listInfo.put("cardUID",				cardUID);			//카드승인번호
				listInfo.put("postingDate",			applicationDate);	//전기일자
				listInfo.put("taxType",				taxType);			//세금유형
				listInfo.put("taxCode",				taxCode);			//세금코드
				listInfo.put("payAdjustMethod",		payAdjustMethod);	//정산방법
				listInfo.put("payMethod",			payMethod);			//지급방법
				listInfo.put("vendorNo",			vendorNo);			//거래처등록번호
				listInfo.put("totalAmount",			totalAmount);		//합계액
				listInfo.put("docNo",				docNo);				//전표번호
				listInfo.put("docPostingDate",		applicationDate);	//전표전기일자
	
				//act_expence_application_div
				listInfo.put("division_index",		divisionIndex);
				listInfo.put("accountCode",			accountCode);		//계정과목
				listInfo.put("costCenterCode",		costCenterCode);	//코스트센터코드
				listInfo.put("amount",				amount);			//금액
				listInfo.put("usageComment",		usageComment);		//사용내역
				
				//저장
				expenceApplicationInterfaceSave(listInfo);
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
	* @Method Name : expenceApplicationInterfaceMakeParam
	* @Description : 
	*/
	private CoviMap expenceApplicationInterfaceMakeParam(CoviMap map) {
		
		CoviList list = coviMapperOne.list("expenceApplication.getExpenceApplicationSaveIDs", map);
		CoviMap info = (CoviMap) list.get(0);
		
		String expenceApplicationID		= rtString(info.get("ExpenceApplicationID"));
		String expenceApplicationListID	= rtString(info.get("ExpenceApplicationListID"));
		String expenceApplicationDivID	= rtString(info.get("ExpenceApplicationDivID"));
		
		map.put("SessionUser",	SessionHelper.getSession("UR_Code"));
		
		map.put("expenceApplicationID", 	expenceApplicationID);
		map.put("expenceApplicationListID",	expenceApplicationListID);
		map.put("expenceApplicationDivID",	expenceApplicationDivID);
		
		return map;
	}
	
	/**
	* @Method Name : expenceApplicationInterfaceSave
	* @Description : 
	*/
	private void expenceApplicationInterfaceSave(CoviMap map) {
		//KEY ID 조회
		map = expenceApplicationInterfaceMakeParam(map);
		
		//expenceApplication
		if(rtString(map.get("expenceApplicationID")).equals("")){
			coviMapperOne.insert("expenceApplication.expenceApplicationInterfaceInsert", map);
		}else{
			coviMapperOne.update("expenceApplication.expenceApplicationInterfaceUpdate", map);
		}
		
		//expenceApplicationList
		if(rtString(map.get("expenceApplicationListID")).equals("")){
			coviMapperOne.insert("expenceApplication.expenceApplicationListInterfaceInsert", map);
		}else{
			coviMapperOne.update("expenceApplication.expenceApplicationListInterfaceUpdate", map);
		}

		//expenceApplicationDiv
		if(rtString(map.get("expenceApplicationDivID")).equals("")){
			coviMapperOne.insert("expenceApplication.expenceApplicationDivInterfaceInsert", map);
		} else {
			coviMapperOne.update("expenceApplication.expenceApplicationDivInterfaceUpdate", map);
		}
	}

	/**
	* @Method Name : expAppUpdateActive
	* @Description : 결재 후처리
	*/
	@Override
	public CoviMap expAppUpdateActive(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		String strStatus = "S";

		params.put("companyCode", commonSvc.getCompanyCodeOfUser(params.getString("SessionUser")));
		
		String applicationStatus = params.getString("ApplicationStatus");
		
		int cnt = 0;
		if(!applicationStatus.equals("DELETE")) {
			cnt = coviMapperOne.update("expenceApplication.updateApvStatus", params);
			//출장정산 테이블 업데이트
			coviMapperOne.update("biztrip.updateBizTripAppStatus", params);
		}
		
		if(cnt > 0 || applicationStatus.equals("DELETE")) {
			strStatus = expAppUpdateEvidActive(params).getString("status");
			
			// 예산 집행
			if(RedisDataUtil.getBaseConfig("eAccIsUseBudget", params.getString("DomainID")).equals("Y")) { //accountUtil.getPropertyInfo("account.searchType.Budget")
				strStatus = expAppUpdateBudgetStatus(params).getString("status");
			}
			
			if(params.getString("ApplicationStatus").equals("C")) {
				strStatus = expAppUpdateApplicationStatus(params).getString("status");
			}
			
			if(params.getString("ApplicationStatus").equals("E")) {
				// 자금 지출 (상태값 변경 : NULL -> 대기)
				strStatus = expAppUpdateCapitalStatus(params).getString("status");
				
				// 전표 발행
				if(RedisDataUtil.getBaseConfig("UseAutoSlip", params.getString("DomainID")).equals("Y")) {
					CoviMap slipInfo = null;
					CoviMap slipParams = new CoviMap();
					slipParams.addAll(params);
					strStatus = makeSlipAuto(slipParams, slipInfo).getString("status");
				}
			}
		} else {
			strStatus = "F";
		}

		resultObj.put("status", strStatus);
		return resultObj;
	}

	/**
	* @Method Name : expAppUpdateEvidActive
	* @Description : 결재 후처리
	*/
	@Override
	public CoviMap expAppUpdateEvidActive(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		CoviList targetList = coviMapperOne.list("expenceApplication.selectUpdateActivityList", params);
		
		if(targetList != null){
			for(int i = 0; i<targetList.size(); i++){
				CoviMap evidItem = targetList.getMap(i);
				String proofCode = evidItem.getString("ProofCode");
				evidItem.put("Active", params.getString("Active"));
				if("CorpCard".equals(proofCode)){
					coviMapperOne.update("expenceApplication.updateCardActive", evidItem);
				}
				else if("Receipt".equals(proofCode)){
					coviMapperOne.update("expenceApplication.updateMobileActive", evidItem);
				}
				else if("TaxBill".equals(proofCode)){
					coviMapperOne.update("expenceApplication.updateTaxBillActive", evidItem);
				}
			}
		}

		resultObj.put("status", "S");
		
		return resultObj;
	}

	/**
	* @Method Name : expAppUpdateApplicationStatus
	* @Description : 결재 후처리
	*/
	@Override
	public CoviMap expAppUpdateApplicationStatus(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		
		if(!params.containsKey("SessionUser"))
			params.put("SessionUser", SessionHelper.getSession("USERID"));
		coviMapperOne.update("expenceApplication.updateApplicationStatus", params);
		
		//출장정산 테이블 업데이트
		coviMapperOne.update("expenceApplication.updateBizTripStatus", params);

		resultObj.put("status", "S");
		return resultObj;
	}

	/**
	* @Method Name : insertExpenceApplicationForReuse
	* @Description : 재사용 - 신청 건 복제
	*/
	@Override
	public CoviMap insertExpenceApplicationForReuse(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		
		//params에 newExpAppID 추가
		coviMapperOne.insert("expenceApplication.insertExpAppForReuse", params);
		
		// 출장정산
		coviMapperOne.insert("expenceApplication.insertExpAppBizTripForReuse", params);
		
		CoviList listArray = coviMapperOne.list("expenceApplication.selectExpAppListIDs", params);
		for(int i = 0; i < listArray.size(); i++) {
			String expAppListID = listArray.getMap(i).getString("ExpenceApplicationListID");
			params.put("ExpenceApplicationListID", expAppListID);
			
			//params에 newExpAppListID 추가
			int listCnt = coviMapperOne.insert("expenceApplication.insertExpAppListForReuse", params);
			
			int dailyCnt = coviMapperOne.insert("expenceApplication.insertExpAppDailyForReuse", params);
			int fuelCnt = coviMapperOne.insert("expenceApplication.insertExpAppFuelForReuse", params);
			
			int fileCnt = coviMapperOne.insert("expenceApplication.insertExpAppFileForReuse", params);
			int refCnt = coviMapperOne.insert("expenceApplication.insertExpAppRefForReuse", params);
			int divCnt = coviMapperOne.insert("expenceApplication.insertExpAppDivForReuse", params);
		}
		
		CoviMap jsonParams = new CoviMap();
		jsonParams.putAll(params);
		jsonParams.put("getSavedKey", jsonParams.getString("newExpAppID"));
		savePrivateDomainData(jsonParams);
		
		resultObj.put("status", "S");
		return resultObj;
	}
	
	/**
	* @Method Name : expAppUpdateBudgetStatus
	* @Description : 예산 집행 상태값 변경
	*/
	private CoviMap expAppUpdateBudgetStatus(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		String appStatus = params.getString("ApplicationStatus");
		
		switch(appStatus) {
		case "E": params.put("status", "C"); break; //집행 (완료)
		case "R": params.put("status", "R"); break; //반려
		case "C": params.put("status", "W"); break; //취소
		case "DELETE": params.put("status", "D"); break; //삭제
		default : params.put("status", "P"); break; //가집행 (진행, 기안)
		}

		if(!(appStatus.equals("C") || appStatus.equals("DELETE"))) {
			//증빙 모두 지우고 insert
			coviMapperOne.delete("budget.use.deleteExecuteRegist", params);
			
			CoviList getEADiv = coviMapperOne.list("expenceApplication.selectExpenceApplicationDiv", params);
			
			CoviMap userMap = new CoviMap();
			userMap.put("UR_Code", getEADiv.getMap(0).getString("RegisterID"));
			
			//UR_Code
			CoviMap getUserInfo = coviMapperOne.selectOne("account.common.selectUserInfo", userMap);
			
			params.put("initiatorID", getUserInfo.getString("UserCode"));
			params.put("initiatorName", getUserInfo.getString("UserName"));
			params.put("initiatorDeptCode", getUserInfo.getString("DeptCode"));
			params.put("initiatorDeptName", getUserInfo.getString("DeptName"));
			for(int i = 0; i < getEADiv.size(); i++) {
				CoviMap divItem = getEADiv.getMap(i);
				String requestType = divItem.getString("RequestType");
				
				params.put("costCenter", divItem.getString("CostCenterCode"));
				params.put("accountCode", divItem.getString("AccountCode"));
				params.put("standardBriefID", divItem.getString("StandardBriefID"));
				params.put("usedAmount", divItem.getString("Amount"));
				params.put("description", divItem.getString("UsageComment"));
				params.put("expenceApplicationListID", divItem.getString("ExpenceApplicationListID"));
				params.put("expenceApplicationDivID", divItem.getString("ExpenceApplicationDivID"));
				params.put("executeDate", divItem.getString("ProofDate"));
				
				String budgetType = coviMapperOne.selectOne("budget.use.getBudgetType", params);
				String budgetCode = divItem.getString("CostCenterCode");
				if(budgetType != null) {
					if(budgetType.equals("USER")) budgetCode = getUserInfo.getString("UserCode");
				}
				params.put("budgetCode", budgetCode);
				
				coviMapperOne.insert("budget.use.addExecuteRegist", params);
			}
		} else {
			coviMapperOne.update("budget.use.changeStatus", params);
		}

		resultObj.put("status", "S");
		return resultObj;
	}

	/**
	* @Method Name : expAppUpdateCapitalStatus
	* @Description : 증빙 별 자금지출 상태값 대기로 변경
	*/
	private CoviMap expAppUpdateCapitalStatus(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		params.put("CapitalStatus", "W");
		coviMapperOne.update("expenceApplication.updateCapitalStatus", params);

		resultObj.put("status", "S");
		return resultObj;
	}
	
	@Override
	public CoviMap createCapitalReportInfo(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();

		coviMapperOne.update("expenceApplication.updateCapitalStatus", params);
		
		if(params.getString("ApvState").equals("COMPLETE")) {
			//자금지출보고서 완료 시 자금지출결의를 하기 위한 자금지출보고서 정보 저장	
			coviMapperOne.insert("expenceApplication.insertCapitalReportInfo", params);
			//자금지출보고서로 올라간 증빙은 자금지출보고 건이라는 표시를 위해 ReservedStr5 컬럼에 Y 표시
			coviMapperOne.update("expenceApplication.updateIsCapitalReport", params);
		}
				
		resultObj.put("status", "S");
		return resultObj;
	}

	/**
	* @Method Name : searchCapitalSpendingStatus
	* @Description : 자금지출 현황 조회
	*/
	@Override
	public CoviMap searchCapitalSpendingStatus(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap coviParams = new CoviMap();
		coviParams.addAll(params);

		int pageNo		= Integer.parseInt(coviParams.get("pageNo").toString());
		int pageSize	= Integer.parseInt(coviParams.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		coviParams.put("pageNo",		pageNo);
		coviParams.put("pageSize",		pageSize);
		coviParams.put("pageOffset",	pageOffset);
		
		int cnt = (int)coviMapperOne.getNumber("expenceApplication.selectCapitalSpendingStatusCnt", coviParams);
		
		CoviMap page = ComUtils.setPagingData(coviParams,cnt);
		coviParams.addAll(page);		
		
		CoviList list = coviMapperOne.list("expenceApplication.selectCapitalSpendingStatus", coviParams);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList;
	}
	
	/**
	* @Method Name : searchCapitalSpendingStatusExcel
	* @Description : 자금지출 현황 조회 엑셀 저장 
	*/
	@Override
	public CoviMap searchCapitalSpendingStatusExcel(CoviMap jsonParams) throws Exception {
		CoviMap resultList = new CoviMap();
				
		CoviMap params = new CoviMap();
		params.addAll(jsonParams);

		int cnt = (int) coviMapperOne.getNumber("expenceApplication.selectCapitalSpendingStatusCnt", params);
		CoviList list = coviMapperOne.list("expenceApplication.selectCapitalSpendingStatusExcel", params);
		
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	accountExcelUtil.selectJSONForExcel(list, headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}

	/**
	* @Method Name : updateCapitalStatus
	* @Description : 증빙 자금지출 처리상태 수정
	*/
	@Override
	public CoviMap updateCapitalStatus(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		coviMapperOne.update("expenceApplication.updateCapitalStatus", params);
		return resultList;
	}
	
	/**
	* @Method Name : searchCapitalEditData
	* @Description : 수정할 증빙 정보 가져오기
	*/
	@Override
	public CoviMap searchCapitalEditData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap returnData = coviMapperOne.selectOne("expenceApplication.selectCapitalEditData", params);
		
		resultList.put("data", AccountUtil.convertNullToSpace(returnData));
		return resultList;
	}

	/**
	* @Method Name : updateCapitalEditInfo
	* @Description : 증빙 수정
	*/
	@Override
	public CoviMap updateCapitalEditInfo(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		Boolean alertFlag = params.getBoolean("AlertFlag");
		
		//자금집행일이 변경되었을 때 기안자에게 메일 알림 발송
		if(alertFlag) {
			CoviList expInfoList = (CoviList) coviMapperOne.list("expenceApplication.selectCapitalEditAlertData", params);
			
			for(int i = 0; i < expInfoList.size(); i++) {
				CoviMap expInfo = expInfoList.getJSONObject(i);
				
				SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
				SimpleDateFormat sdfStr = new SimpleDateFormat("YYYY.MM.dd");
				
				String oriRealPayDate = sdfStr.format(sdf.parse(expInfo.getString("RealPayDate"))); //20230327 -> 2023.03.27
				String fixRealPayDate = sdfStr.format(sdf.parse(params.getString("RealPayDate"))); 	//20230327 -> 2023.03.27
				
				if(oriRealPayDate.equals(fixRealPayDate)) continue;
				
				String msgDesc = String.format(DicHelper.getDic("ACC_msg_capitalRealPayDateEditAlert"))
										.replace("{subject}", 	expInfo.getString("ApplicationTitle"))
										.replace("{proofName}", expInfo.getString("ProofCodeName"))
										.replace("{amount}", 	expInfo.getString("TotalAmount"))
										.replace("{oriDate}", 	oriRealPayDate)
										.replace("{fixDate}", 	fixRealPayDate);
				
				CoviMap mailParams = new CoviMap();
				mailParams.put("MessagingSubject", 	expInfo.getString("ApplicationTitle"));
				mailParams.put("MessageContext", 	msgDesc);
				mailParams.put("ReceiversCode", 	expInfo.getString("RegisterID"));	//수신자
				mailParams.put("SenderCode", 		SessionHelper.getSession("USERID"));//발신자
				mailParams.put("RegistererCode", 	SessionHelper.getSession("USERID"));//등록자
				mailParams.put("PopupURL", 			PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/account/layout/left.do?CLSYS=account&CLMD=user&CLBIZ=Account");
				mailParams.put("GotoURL", 			PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") + "/account/layout/left.do?CLSYS=account&CLMD=user&CLBIZ=Account");
				mailParams.put("MobileURL", 		"/account/mobile/account/portal.do");
				mailParams.put("ServiceType", 		"EAccounting");
				mailParams.put("MsgType", 			"EAccountingCapitalEdit");
				mailParams.put("MediaType", 		"MAIL;");
				mailParams.put("DomainID", 			"".equals(expInfo.getString("DomainID")) ? "0" : expInfo.getString("DomainID"));
				MessageHelper.getInstance().createNotificationParam(mailParams);
		        
				messageSvc.insertMessagingData(mailParams);
			}
		}
		
		coviMapperOne.update("expenceApplication.updateCapitalEditInfo", params);
		
		resultList.put("status", "S");
		return resultList;
	}

	/**
	* @Method Name : getCapitalSpendingList
	* @Description : 자금 지출 결의서 작성 대상 목록
	*/
	@Override
	public CoviMap getCapitalSpendingList(CoviMap params) throws Exception {
		
		CoviList list = coviMapperOne.list("expenceApplication.getCapitalSpendingList"+params.getString("QueryMode"), params);
		
		CoviMap resultList = new CoviMap();

		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList;
	}
	
	/**
	* @Method Name : searchCapitalSummary
	* @Description : 자금지출 완료 집계표
	*/
	@Override
	public CoviMap searchCapitalSummary(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap coviParams = new CoviMap();
		coviParams.addAll(params);

		int pageNo		= Integer.parseInt(coviParams.get("pageNo").toString());
		int pageSize	= Integer.parseInt(coviParams.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		coviParams.put("pageNo",		pageNo);
		coviParams.put("pageSize",		pageSize);
		coviParams.put("pageOffset",	pageOffset);
		
		int cnt = (int)coviMapperOne.getNumber("expenceApplication.selectCapitalSummaryCnt", coviParams);
		
		CoviMap page = ComUtils.setPagingData(coviParams,cnt);
		coviParams.addAll(page);		
		
		CoviList list = coviMapperOne.list("expenceApplication.selectCapitalSummary", coviParams);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page",	page);
		
		return resultList;
	}
	
	/**
	* @Method Name : searchCapitalSummaryExcel
	* @Description : 자금지출 완료 집계표 엑셀 저장 
	*/
	@Override
	public CoviMap searchCapitalSummaryExcel(CoviMap jsonParams) throws Exception {
		CoviMap resultList = new CoviMap();
				
		CoviMap params = new CoviMap();
		params.addAll(jsonParams);

		int cnt = (int) coviMapperOne.getNumber("expenceApplication.selectCapitalSummaryCnt", params);
		CoviList list = coviMapperOne.list("expenceApplication.selectCapitalSummary", params);
		
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	AccountExcelUtil.selectJSONForExcel(list, headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}
	

	/**
	* @Method Name : getUserBankAccount
	* @Description : 사용자 은행 계좌 조회
	*/
	@Override
	public CoviMap getUserBankAccount(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.getUserBankAccount", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list
				, "VendorNo,BankID,BankCode,BankName,BankAccountNo,BankAccountName,BankAccountView"));
		return resultList;
	}
	
	/**
	* @Method Name : insertActVendorForWrite
	* @Description : 거래처 테이블에 insert
	*/
	@Override
	public String insertActVendorForWrite(String vendorNo, String vendorName, String companyCode) throws Exception {
		String retVendorNo = "";
		CoviMap param = new CoviMap();
		param.put("CompanyCode", companyCode);
		param.put("RegisterID", SessionHelper.getSession("USERID"));
		param.put("VendorType", "CO");
		param.put("VendorNo", vendorNo);
		param.put("VendorName", vendorName);
		 
		if(vendorNo.equals("")) {
			retVendorNo = coviMapperOne.getString("expenceApplication.selectVendorNoByAuto", param);
			param.put("VendorNo", retVendorNo);
		} else {
			retVendorNo = vendorNo;
		}
		 
		int cnt        = (int)coviMapperOne.getNumber("expenceApplication.checkActVendorForWrite" , param);
		if(cnt == 0){ //act_vendor에 이미 있는 경우 insert하지 않음
			coviMapperOne.insert("expenceApplication.insertActVendorForWrite", param);
		}
		 
		return retVendorNo;
	}
	 
	/**
	* @Method Name : checkActVendorIsRegistered
	* @Description : 이미 등록되어 있는 사업자번호/거래처명인지 조회
	*/
	@Override
	public CoviMap checkActVendorIsRegistered(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.selectActVendorIsRegistered", params);
		CoviMap resultList = new CoviMap();
		 
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "VendorNo,VendorName"));
		 
		return resultList;
	}	
	
	private String rtString(Object obj){
		String rtStr = "";
		rtStr = obj == null ? "" : obj.toString().trim();
		return rtStr;
	}
	
	/**
	* @Method Name : searchMonthlyAccountHeaderData
	* @Description : 월별 경비 계정별 집계표 헤더 데이터 조회
	*/
	@Override
	public CoviMap searchMonthlyAccountHeaderData(CoviMap jsonParams) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.addAll(jsonParams);
		
		CoviList list = coviMapperOne.list("expenceApplication.selectMonthlyAccountHeaderData", params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList;
	}
	
	/**
	* @Method Name : searchMonthlyAccountSummaryList
	* @Description : 월별 경비 계정별 집계표 목록 조회
	*/
	@Override
	public CoviMap searchMonthlyAccountSummaryList(CoviMap jsonParams) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list = new CoviList();
		
		String str = null;
		
		CoviMap params = new CoviMap();
		params.addAll(jsonParams);

		int cnt = 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;

		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		if(params.getString("SearchType").equals("user")) {
			cnt = (int) coviMapperOne.getNumber("expenceApplication.selectMonthlyAccountSummaryListCnt", params);
			
			page 	= ComUtils.setPagingData(params,cnt);
			params.addAll(page);	
			
			list = coviMapperOne.list("expenceApplication.selectMonthlyAccountSummaryList", params);
			str = "GroupName,UserName,";
		} else if(params.getString("SearchType").equals("dept")) {
			cnt = (int) coviMapperOne.getNumber("expenceApplication.selectMonthlyAccountDeptSummaryListCnt", params);

			page 	= ComUtils.setPagingData(params,cnt);
			params.addAll(page);	
			
			list = coviMapperOne.list("expenceApplication.selectMonthlyAccountDeptSummaryList", params);
			str = "GroupName,";
		}

		if(params.containsKey("result")) {
			ArrayList<CoviMap> tlist = (ArrayList<CoviMap>) params.get("result");
			list.addAll(tlist);
		}
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));			
		resultList.put("page", page);
		return resultList;
	}
	
	/**
	* @Method Name : searchMonthlyAccountSummaryListExcel
	* @Description : 월별 경비 계정별 집계표 목록 조회 엑셀저장
	*/
	@Override
	public CoviMap searchMonthlyAccountSummaryListExcel(CoviMap jsonParams) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = new CoviList();
		
		String str = null;
		
		CoviMap params = new CoviMap();
		params.addAll(jsonParams);

		int cnt = 0;
		
		if(params.getString("SearchType").equals("user")) {
			cnt = (int) coviMapperOne.getNumber("expenceApplication.selectMonthlyAccountSummaryListCnt", params);
			list = coviMapperOne.list("expenceApplication.selectMonthlyAccountSummaryList", params);
			str = "GroupName,UserName,";
		} else if(params.getString("SearchType").equals("dept")) {
			cnt = (int) coviMapperOne.getNumber("expenceApplication.selectMonthlyAccountDeptSummaryListCnt", params);
			list = coviMapperOne.list("expenceApplication.selectMonthlyAccountDeptSummaryList", params);
			str = "GroupName,";
		}

		if(params.containsKey("result")) {
			ArrayList<CoviMap> tlist = (ArrayList<CoviMap>) params.get("result");
			list.addAll(tlist);
		}
		
		String headerStr = "";
		headerStr = coviMapperOne.getString("expenceApplication.selectMonthlyAccountHeaderDataExcel", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, str+headerStr+",TotalSum"));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	* @Method Name : searchMonthlyStandardBriefHeaderData
	* @Description : 월별 경비 표준적요별 집계표 헤더 데이터 조회
	*/
	@Override
	public CoviMap searchMonthlyStandardBriefHeaderData(CoviMap jsonParams) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.addAll(jsonParams);
		
		CoviList list = coviMapperOne.list("expenceApplication.selectMonthlyStandardBriefHeaderData", params);
			
		resultList.put("list", AccountUtil.convertNullToSpace(list));			
		return resultList;
	}
	
	/**
	* @Method Name : searchMonthlyStandardBriefSummaryList
	* @Description : 월별 경비 표준적요별 집계표 목록 조회
	*/
	@Override
	public CoviMap searchMonthlyStandardBriefSummaryList(CoviMap jsonParams) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list = new CoviList();
		
		String str = null;
		
		CoviMap params = new CoviMap();
		params.addAll(jsonParams);
		
		int cnt = 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;

		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		if(params.getString("SearchType").equals("user")) {
			cnt = (int) coviMapperOne.getNumber("expenceApplication.selectMonthlyStandardBriefSummaryListCnt", params);		
			
			page 	= ComUtils.setPagingData(params,cnt);
			params.addAll(page);	
			
			list = coviMapperOne.list("expenceApplication.selectMonthlyStandardBriefSummaryList", params);
			str = "GroupName,UserName,";
		} else if(params.getString("SearchType").equals("dept")) {
			cnt = (int) coviMapperOne.getNumber("expenceApplication.selectMonthlyStandardBriefDeptSummaryListCnt", params);		
			
			page 	= ComUtils.setPagingData(params,cnt);
			params.addAll(page);	
			
			list = coviMapperOne.list("expenceApplication.selectMonthlyStandardBriefDeptSummaryList", params);
			str = "GroupName,";			
		}

		if(params.containsKey("result")) {
			ArrayList<CoviMap> tlist = (ArrayList<CoviMap>) params.get("result");
			list.addAll(tlist);
		}
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		resultList.put("page", page);
		return resultList;
	}
	
	/**
	* @Method Name : searchMonthlyStandardBriefSummaryListExcel
	* @Description : 월별 경비 표준적요별 집계표 목록 조회 엑셀저장
	*/
	@Override
	public CoviMap searchMonthlyStandardBriefSummaryListExcel(CoviMap jsonParams) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = new CoviList();
		
		String str = null;
		
		CoviMap params = new CoviMap();
		params.addAll(jsonParams);
		
		int cnt = 0;
		
		if(params.getString("SearchType").equals("user")) {
			cnt = (int) coviMapperOne.getNumber("expenceApplication.selectMonthlyStandardBriefSummaryListCnt", params);					
			list = coviMapperOne.list("expenceApplication.selectMonthlyStandardBriefSummaryList", params);
			str = "GroupName,UserName,";
		} else if(params.getString("SearchType").equals("dept")) {
			cnt = (int) coviMapperOne.getNumber("expenceApplication.selectMonthlyStandardBriefDeptSummaryListCnt", params);					
			list = coviMapperOne.list("expenceApplication.selectMonthlyStandardBriefDeptSummaryList", params);
			str = "GroupName,";			
		}
		
		if(params.containsKey("result")) {
			ArrayList<CoviMap> tlist = (ArrayList<CoviMap>) params.get("result");
			list.addAll(tlist);
		}
		
		String headerStr = "";
		headerStr = coviMapperOne.getString("expenceApplication.selectMonthlyStandardBriefHeaderDataExcel", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list, str+headerStr+",TotalSum"));
		resultList.put("cnt", cnt);
		return resultList;
	}

	
	/**
	* @Method Name : getFormData
	* @Description : 결재문서 값 조회
	*/
	@Override
	public CoviMap getFormData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviMap returnList = new CoviMap();
		
		CoviList list = coviMapperOne.list("expenceApplication.selectFormData", params);
		returnList.put("list", CoviSelectSet.coviSelectJSON(list, "BusinessState,ProcessState,ParentProcessID,DeputyID,UserCode,WorkitemState,ExtInfo,FormName,FormPrefix,FormID,SchemaContext,ChargeJob,FormInstID"));
		
		CoviMap returnObj = (((CoviList)returnList.get("list")).getJSONObject(0));

		String strReadMode = params.getString("mode");
		String strReadModeTemp = params.getString("mode");	
		String strGloct = params.getString("gloct");
		String strSubkind = params.getString("Subkind");
		String strReqUserCode = params.getString("UserCode");
		
		String strUserCode = returnObj.getString("UserCode");
		String strBusinessState = returnObj.getString("BusinessState");
		String processState = returnObj.getString("ProcessState");
		String workitemState = returnObj.getString("WorkitemState");
		String strDeputyID = returnObj.containsKey("DeputyID") ? returnObj.getString("DeputyID") : "";
		String strSessionUserID = SessionHelper.getSession("USERID");
        
        if (!strReadMode.equals("COMPLETE") && !(strReadMode.equals("undefined")))
        {
			switch (strBusinessState)
	        {
	            case "03_01_02": //수신부서기안대기   "Receive"
	                strReadMode = "REDRAFT";
	                break;
	            case "01_02_01": //"PersonConsult" 개인
	            case "01_04_01":
	            case "01_04_02":
	                strReadMode = "PCONSULT";
	                break;
	            case "01_03_01": //감사 개인
	                strReadMode = "AUDIT";
	                break;
	            case "01_01_02": //"RecApprove"
	                strReadMode = "RECAPPROVAL";
	                break;
	            case "03_01_03": //협조부서
	            case "03_01_04": //"SubRedraft" 합의부서기안대기
	            case "03_01_05": //감사 부서 대기
	                strReadMode = "SUBREDRAFT";
	                break;
	            case "01_01_04": //"SubApprove" 부서결재
	            case "01_02_02":
	            case "01_01_05":
	            case "01_03_02":
	            case "01_03_03":
	            case "01_02_03":
	                strReadMode = "SUBAPPROVAL";
	                break;
	            case "02_02_01":   //기안부서 반려"Reject"
	            case "02_02_02":
	            case "02_02_03":
	            case "02_02_04":
	            case "02_02_05":
	            case "02_02_06":
	            case "02_02_07":
	                strReadMode = "REJECT";
	                break;
	            case "03_01_06": //"Charge"
	                strReadMode = "CHARGE";
	                break;
	            default:
	                break;
	        }
	
	        if (strSubkind.equals("T001") || strSubkind.equals("T002")) //시행문변환
	        {
	            strReadMode = "TRANS"; //변환
	        }else if (strSubkind.equals("T003"))
	        {
	            strReadMode = "SIGN"; //직인
	        }else if (strSubkind.equals("T018"))
	        {
	            if (workitemState.equals("288"))
	            {
	                strReadMode = "APPROVAL";
	            }else
	            {
	                strReadMode = "COMPLETE"; //공람
	            }
	        }
        }
    	
        String strLoct = "";
        if (strReadMode.equals("APPROVAL")){
            if (!processState.equals("288")){//(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                strLoct = "COMPLETE";
            }else{
                if (!workitemState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                    strLoct = "PROCESS";
                }else{
                    if (strSessionUserID.equals(strReqUserCode)
                    		|| strSessionUserID.equals(strUserCode) 
                    		|| strSessionUserID.equals(strDeputyID) || strGloct.equals("JOBFUNCTION") || strGloct.equals("DEPART")){
                        strLoct = strReadModeTemp;
                    }else{
                        strLoct = "PROCESS";
                    }
                }
            }
        }else if (strReadMode.equals("REDRAFT") || strReadMode.equals("RECAPPROVAL")){
            if (!processState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                strLoct = "COMPLETE";
            }else{
                if (!workitemState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)                
                    strLoct = "PROCESS";
                }else{
                    strLoct = strReadModeTemp;
                }
            }
        }else{
            strLoct = strReadModeTemp;
        }
        
        params.addAll(returnObj);
        params.put("reqUserCode", strReqUserCode);
        params.put("mode", strReadMode);
        params.put("loct", strLoct);

		resultList.putAll(params);	
		return resultList;
	}
	
	/**
	* @Method Name : getCardList
	* @Description : 카드목록 조회
	*/
	@Override
	public CoviMap getCardList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.selectCardList", params);
		CoviMap resultList = new CoviMap();
		 
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CorpCardID,CardNo,CorpCardName"));
		 
		return resultList;
	}	

	/**
	 * @Method Name : saveAuditReason
	 * @Description : 감사규칙 위반 사유 저장
	 */
	@Override
	public CoviMap saveAuditReason(CoviMap params) throws Exception{
		CoviMap resultList = new CoviMap();
		
		coviMapperOne.update("expenceApplication.updateAuditReason", params);
		
		resultList.put("result" , "ok");
		
		return resultList;
	}
	
	/**
	* @Method Name : selRecentVendorInfo
	* @Description : 최근사용한 Vendor의 증빙정보 가져오기
	*/
	@Override
	public CoviMap selRecentVendorInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.selRecentVendorInfo", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList;
	}
	
	/**
	* @Method Name : getStoreCategoryCombo
	* @Description : 업종 콤보
	*/
	@Override
	public CoviMap getStoreCategoryCombo(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList userList = coviMapperOne.list("expenceApplication.selectStoreCategoryList", params);
		resultList.put("StoreCategoryList", CoviSelectSet.coviSelectJSON(userList
				, "CompanyCode,CategoryID,CategoryCode,CategoryName,TaxCode,StandardBriefID,Reserved1,Reserved2,Reserved3,StandardBriefName"));
		
		return resultList;
	}

	@Override
	public CoviMap getStandardBriefCtrlCombo(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("expenceApplication.selectStandardBriefCtrlCombo", params);
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList;
	}

	@Override
	public CoviMap getCtrlCodeHeader(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = new CoviList();
		
		String CtrlCode = coviMapperOne.getString("expenceApplication.selectCtrlCode", params);
		
		// mybatis foreach 돌 때 String을 iterator 형태로 바꾸기 위해 ArrayList에 저장하여 parameter로 넘김
		if(CtrlCode != null && !CtrlCode.equals("")) {		
			String[] ctrlCodeArr = CtrlCode.split(",");
			ArrayList<String> colList = new ArrayList<>();
			for (int i = 0; i < ctrlCodeArr.length; i++) {
				if(!ctrlCodeArr[i].equals("")) {
					colList.add(ctrlCodeArr[i]);
				}
	 		}
			
			if(!colList.isEmpty()) {
				params.put("CtrlCode", colList);
			}
			
			list = coviMapperOne.list("expenceApplication.selectCtrlCodeHeader", params);
		}
		
		resultList.put("list", AccountUtil.convertNullToSpace(list));
		return resultList;
	}

	@Override
	public CoviMap getMajorAccountUsageHistory(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		
		String ctrlCode = coviMapperOne.getString("expenceApplication.selectCtrlCode", params);
		
		// mybatis foreach 돌 때 String을 iterator 형태로 바꾸기 위해 ArrayList에 저장하여 parameter로 넘김   
		if(ctrlCode != null && !ctrlCode.equals("")) {
			String[] ctrlCodeArr = ctrlCode.split(",");
			ArrayList<String> colList = new ArrayList<>();
			for (int i = 0; i < ctrlCodeArr.length; i++) {
				if(!ctrlCodeArr[i].equals("")) {
					colList.add(ctrlCodeArr[i]);
				}
	 		}
			
			if(!colList.isEmpty()) {
				params.put("CtrlCode", colList);
			}
		}
		
		int cnt	= (int) coviMapperOne.getNumber("expenceApplication.selectMajorAccountUsageHistoryCnt", params);
		
		if(params.containsKey("isExcel") && params.getString("isExcel").equals("Y")) {
			CoviList list = coviMapperOne.list("expenceApplication.selectMajorAccountUsageHistory",params);
			
			list = getCtrlCodeJsonData(list, ctrlCode);

			String headerKey = params.get("headerKey").toString();
			
			returnList.put("list",	AccountExcelUtil.selectJSONForExcel(list,headerKey));
			returnList.put("cnt", cnt);
		} else {
			CoviMap page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
						
			CoviList list = coviMapperOne.list("expenceApplication.selectMajorAccountUsageHistory",params);
			
			list = getCtrlCodeJsonData(list, ctrlCode);
			
			returnList.put("list", AccountUtil.convertNullToSpace(list));
			returnList.put("page", page);
		}
		
		return returnList; 
	}
	
	private CoviList getCtrlCodeJsonData(CoviList list, String CtrlCode) throws Exception {
		if(CtrlCode != null && !CtrlCode.equals("")) {
			for(int i = 0; i < list.size(); i++) {
				CoviMap map = list.getMap(i);
				
				if(map.containsKey("ReservedStr2")) {
					//mariadb 10.1, oracle 11c, mssql 2014 이하 (json parse 지원 안 함)
					
					String reservedStr2 = map.getString("ReservedStr2");
					
					if(reservedStr2 != null && !reservedStr2.equals("")) {
						JSONParser parser = new JSONParser();
						egovframework.baseframework.data.CoviMap jsonObj = (egovframework.baseframework.data.CoviMap) parser.parse(reservedStr2);

						String[] ctrlCodeArr = CtrlCode.split(",");
						for(int j = 0; j < ctrlCodeArr.length; j++) {
							if(!ctrlCodeArr[j].equals("")) {
								if(jsonObj.containsKey(ctrlCodeArr[j])) {
									map.put(ctrlCodeArr[j], jsonObj.get(ctrlCodeArr[j]).toString());
								} else {
									map.put(ctrlCodeArr[j], "");
								}
							}
						}
					}
				} else {
					//mariadb 10.2, oracle 12c, sql server 2016 이상 (json parse 지원)
					//현재 mysql10.4만 지원됨
					break;
				}					
			}
		}
		
		return list;
	}
	
	/**
	* @Method Name : getExpenceApplicationListExcelDouzone
	* @Description : 더존엑셀다운
	*/
	public CoviMap getExpenceApplicationListExcelDouzone(CoviMap params) throws Exception {
		String searchType = (String)params.get("SearchType");
		
		CoviList list = null;
		CoviList div = null;
		
		CoviList douzoneicube = new CoviList();
		
		int cnt = 0;
		params.put("isExcel", "Y");
		
		if("douzone".equals(searchType)){
			list = coviMapperOne.list("expenceApplication.selectExpenceApplicationDouzoneicubeList", params);	// List 기준
			div =  coviMapperOne.list("expenceApplication.selectExpenceApplicationDouzoneicubeDiv", params);		// Div 기준
			// cnt = (int)(long)coviMapperOne.selectOne("expenceApplication.selectExpenceApplicationDouzoneicubeExcelCnt", params);
			
			// 람다식 사용하기위해 List<map> 만들기
			List<CoviMap> returnDiv = div;
			 			
			// erp 업로드 형식대로 데이터 가공
			// list 사이즈 만큼 돌면서 Div들을 가공
			List<CoviMap> makeList;
			for(int i =0; i<list.size(); i ++) {
				CoviMap newObjectI = (CoviMap)list.get(i);
				makeList  = returnDiv.stream().filter( u-> u.get("ExpenceApplicationListID").toString().equals(newObjectI.getString("ExpenceApplicationListID")) ).collect(Collectors.toList());
				
				// 만들어진 List<map> for문돌면서 만든다.
				for(int j=0; j<makeList.size(); j++) {
					// 차변 만들기 START
					CoviMap cvm = new CoviMap();
					CoviMap newObjectJ = makeList.get(j);
					cvm.put("CO_CD",newObjectI.getString("CompanyCode"));	// 회사코드
					cvm.put("IN_DT", newObjectI.getString("ProofDate"));		// 거래일자
					cvm.put("IN_SQ", Integer.toString(i));						// 거래순번
					cvm.put("LN_SQ", Integer.toString(j));						// 분개라인순번
					cvm.put("DIV_CD", "회계단위");	// 뭔지 모르겠음
					cvm.put("DRCR_FG", "3");	// 차변은 3
					cvm.put("ACCT_CD", newObjectJ.getString("StandardBriefID"));	// 계정코드(표준적요를 사용하는지 계정과목을 사용하는지는 확인해야함 우선은 표준적요 사용)
					cvm.put("REG_NB", newObjectI.getString("REG_NB"));	// 사업자번호 또는 주민등록번호
					cvm.put("ACCT_AM",newObjectJ.getString("Amount"));	// 차변 금액은 Div의 금액
					cvm.put("RMK_DC", newObjectJ.getString("UsageComment"));	// 차변은 적요 대변은 문서제목인듯
					cvm.put("PJT_CD", "");	// 부가세계정일 경우 신고사업장 코드입력, 문자10자리
					cvm.put("CT_AM", newObjectI.getString("RepAmount"));	// 공급가액(List의 공급가액)
					cvm.put("CT_DEAL","");	// 부가세계정일 경우필수 입력, 매입:21.과세매입 ~ 41.카드기타, 매출:11.과세매출 ~ 36.기타영세
					cvm.put("NONSUB_TY", "");	// 부가세계정일 경우 필수 입력, 23.면세매입 24.매입불공제 25.수입 26.의제매입일 경우에만 등록 
					cvm.put("FR_DT", "");	// 부가세계정일 경우 필수 입력,문자 8자리
					cvm.put("ISU_DOC", newObjectI.getString("ApplicationTitle"));	// 품의내역 제목으로 보임
					cvm.put("JEONJA_YN", newObjectI.getString("JEONJA_YN"));	// 0.미발행 1.발행, 숫자 1자리
					cvm.put("CT_NB", "");	// 부가세계정일 경우 12.영세 -> 서류번호, 16.수출 -> 수출신고번호 입력, 문자 30자리, 27.카드매입, 41.카드기타 -> 결제카드입력
					cvm.put("TR_CD", "");	// 거래처코드
					cvm.put("TR_NM", newObjectI.getString("TR_NM"));	// 거래처명 차변은 거래처명만 있음
										
					douzoneicube.add(cvm);
					// 차변 만들기 END
					
					// 대변 만들기 START
					// 만약 for문도는 j가 마지막꺼까지 돌게되면 차변은 다 만들었으니 이제 대변을 만들어야한다.
					if(j == (makeList.size() -1)) {
						CoviMap cvmCR = new CoviMap();
						cvmCR.put("CO_CD",newObjectI.getString("CompanyCode"));	// 회사코드
						cvmCR.put("IN_DT", newObjectI.getString("ProofDate"));		// 거래일자
						cvmCR.put("IN_SQ", Integer.toString(i));	// 거래순번
						cvmCR.put("LN_SQ", Integer.toString((j+1)));	// j 의 마지막 번째 + 1
						cvmCR.put("DIV_CD", "");	// 회계단위 뭔지 모르겠음
						cvmCR.put("DRCR_FG", "4");	// 대변은 4
						cvmCR.put("ACCT_CD", "미지급금계정");	// 대변계정은 알수가 없음.. 고정된 계정일수도 있고 선택할수도있음
						cvmCR.put("REG_NB", "");	// 거래처사업자번호 
						cvmCR.put("ACCT_AM", newObjectI.getString("TotalAmount"));	// 대변금액은 List의 총금액
						cvmCR.put("RMK_DC",newObjectI.getString("ApplicationTitle"));	// 대변은 적요가 문서제목
						cvmCR.put("PJT_CD", "");	// 부가세계정일 경우 신고사업장 코드입력, 문자10자리
						cvmCR.put("CT_AM", newObjectI.getString("RepAmount"));	// 공급가액(List의 공급가액)
						cvmCR.put("CT_DEAL","");	// 부가세계정일 경우필수 입력, 매입:21.과세매입 ~ 41.카드기타, 매출:11.과세매출 ~ 36.기타영세
						cvmCR.put("NONSUB_TY", "");	// 부가세계정일 경우 필수 입력, 23.면세매입 24.매입불공제 25.수입 26.의제매입일 경우에만 등록 
						cvmCR.put("FR_DT", "");	// 부가세계정일 경우 필수 입력,문자 8자리
						cvmCR.put("ISU_DOC", newObjectI.getString("ApplicationTitle"));	// 품의내역 제목으로 보임
						cvmCR.put("JEONJA_YN", newObjectI.getString("JEONJA_YN"));	// 0.미발행 1.발행, 숫자 1자리
						cvmCR.put("CT_NB", "");	// 부가세계정일 경우 12.영세 -> 서류번호, 16.수출 -> 수출신고번호 입력, 문자 30자리, 27.카드매입, 41.카드기타 -> 결제카드입력
						cvmCR.put("TR_CD", newObjectI.getString("TR_CD"));	// 거래처코드	전자세금계산서는 거래처코드일거고 법인카드는 카드사 
						cvmCR.put("TR_NM", "");	// 거래처명	
						
						douzoneicube.add(cvmCR);
					}
					// 대변 만들기 END
					
				}
			}
			
			
		}else{
			// list = coviMapperOne.list("expenceApplication.selectExpenceApplicationListExcel", params);
		}

		CoviMap resultList = new CoviMap();
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	AccountExcelUtil.selectJSONForExcel(douzoneicube,headerKey));
		resultList.put("cnt", douzoneicube.size());

		return resultList;
	}
	
	public String replaceBodyContext(String oBodyContext){
		if(oBodyContext == null)
			return null;
		
		return new String(Base64.encodeBase64(oBodyContext.getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
	}
	
	public String getNote(CoviMap saveObj) throws Exception {
		String note = "";
		
		CoviMap params = new CoviMap();
		params.put("companyCode", saveObj.optString("CompanyCode"));
		params.put("formCode", saveObj.optString("RequestType"));
		
		String noteIsUse = formManageSvc.getNoteIsUse(params).getString("NoteIsUse");
		
		if("Y".equals(noteIsUse)) {
			// Editor 처리 - BodyDefault
			CoviMap editorParam = new CoviMap();
			editorParam.put("serviceType", "Approval");  //BizSection
			editorParam.put("imgInfo", saveObj.optString("images"));
			editorParam.put("backgroundImage", saveObj.optString("backgroundImage"));
			editorParam.put("objectID", "0");     
			editorParam.put("objectType", "Form"); 
			editorParam.put("messageID", "0");  
			editorParam.putOrigin("bodyHtml", saveObj.getString("body"));
			
			CoviMap bodyEditorInfo = editorService.getContent(editorParam);
			String BodyHtml = bodyEditorInfo.getString("BodyHtml");
			
			//이미지 경로 체크
		    if( BodyHtml.indexOf(RedisDataUtil.getBaseConfig("FrontStorage").replace("/{0}", "")) < 0){
		    	note = replaceBodyContext(BodyHtml);
		    }else {
		    	logger.error("ExpeceApplicationSvcImpl[File Exception]");
				throw new Exception();
		    }
		} else {
			String expenceApplicationID = saveObj.getString("ExpenceApplicationID");
			// 스마트에디터 사용여부가 N인 경우 기존에 저장된 데이터는 유지하기 위한 로직
			if(!"".equals(expenceApplicationID) && expenceApplicationID != null) {
				CoviMap selectParams = new CoviMap();
				selectParams.put("ExpenceApplicationID", expenceApplicationID);
				CoviMap expenceApplication = (CoviMap)AccountUtil.convertNullToSpace(coviMapperOne.selectOne("expenceApplication.selectExpenceApplication", selectParams));
				note = expenceApplication.getString("Note");
			}
		}
		
		return note;
	}
	
	@Override
	public String selectUsingSignImageId(String userCode) {
		String signImgId = coviMapperOne.selectOne("expenceApplication.selectUsingSignImageId", userCode);
		if(StringUtils.isBlank(signImgId)) signImgId = "";
		return signImgId;
	}

	@Override
	public String selectFormInstanceIsArchived(CoviMap paramID) throws Exception{
		CoviMap map = coviMapperOne.select("expenceApplication.selectFormInstanceIsArchived", paramID);
		String isArchive = "false";
		
		if(map.containsKey("isArchive"))
			isArchive = map.getString("isArchive");
		
		return isArchive;
	}

	@Override
	public CoviMap selectProcess(CoviMap params) throws Exception {
		CoviList list = null;
		CoviMap resultList = new CoviMap();
		String queryName = "";
		boolean hasWorkitemID = !(params.get("workitemID") == null || params.get("workitemID").equals(""));
		
		if(!hasWorkitemID) queryName = "expenceApplication.selectOnlyProcess";
		else queryName = "expenceApplication.selectProcess";
		list = coviMapperOne.list(queryName, params);
		
		if(list == null || list.isEmpty()) {
			if(!hasWorkitemID) queryName = "expenceApplication.selectOnlyProcessArchive";
			else queryName = "expenceApplication.selectProcessArchive";
			list = coviMapperOne.list(queryName, params);
		}
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ProcessID,ProcessDescriptionID,FormInstID,State,ProcessState,ParentProcessID,UserCode,DocSubject,DeputyID,BusinessState,ProcessName,TaskID,SubKind"));
		return resultList;
	}

	@Override
	public CoviMap selectProcessDes(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.selectProcessDes", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ProcessDescriptionID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2"));
		
		return resultList;
	}

	@Override
	public CoviMap selectFormInstance(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.selectFormInstance", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FormInstID,ProcessID,FormID,SchemaID,Subject,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,CompletedDate,DeletedDate,LastModifiedDate,LastModifierID,EntCode,EntName,DocNo,DocLevel,DocClassID,DocClassName,DocSummary,IsPublic,SaveTerm,AttachFileInfo,AppliedDate,AppliedTerm,ReceiveNo,ReceiveNames,ReceiptList,BodyType,BodyContext,DocLinks,EDMSDocLinks,RuleItemInfo"));
		
		return resultList;
	}

	@Override
	public CoviMap selectFormInstanceStore(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.selectFormInstanceStore", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FormInstID,ProcessID,FormID,SchemaID,Subject,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,InitiatedDate,CompletedDate,DeletedDate,LastModifiedDate,LastModifierID,EntCode,EntName,DocNo,DocLevel,DocClassID,DocClassName,DocSummary,IsPublic,SaveTerm,AttachFileInfo,AppliedDate,AppliedTerm,ReceiveNo,ReceiveNames,ReceiptList,BodyType,BodyContext,DocLinks,EDMSDocLinks,RuleItemInfo"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectDomainData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.selectDomainData", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DomainDataID,DomainDataName,ProcessID,DomainDataContext"));
		
		return resultList;
	}

	@Override
	public CoviMap selectFormSchema(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.selectFormSchema", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SchemaID,SchemaName,SchemaDesc,SchemaContext"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectPravateDomainData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("expenceApplication.selectPravateDomainData", params);
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "PrivateDomainDataID,CustomCategory,DefaultYN,DisplayName,OwnerID,Abstract,Description,PrivateContext"));
		
		return resultList;
	}

	@Override
	public CoviMap selectForm(CoviMap params) throws Exception {
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
		params.put("DN_CODE", SessionHelper.getSession("DN_Code"));
		params.put("GR_CODE", SessionHelper.getSession("GR_Code"));
		params.put("isSaaS", isSaaS);
		
		CoviList list = new CoviList();
		if(params.optString("mode").equals("TEMPSAVE") && !params.optString("expAppID").equals("")) {
			list = coviMapperOne.list("expenceApplication.selectFormTemp", params);
		}else {
			list = coviMapperOne.list("expenceApplication.selectForm", params);
		}
		CoviMap resultList = new CoviMap();
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "FormID,FormClassID,SchemaID,IsUse,Revision,SortKey,FormName,FormPrefix,FormDesc,FileName,BodyDefault,EntCode,ExtInfo,AutoApprovalLine,BodyType,SubTableInfo,RegID,RegDate,ModID,ModDate,FormHelperContext,FormNoticeContext,IsFavorite"));
		
		return resultList;
	}
	
	@Override
	public String getReadMode(String strReadMode, String strBusinessState, String strSubkind, String workitemState) {
		if(SessionHelper.getSession("isAdmin").equals("Y") && strReadMode.equals("ADMIN")) {
			strReadMode = "ADMIN";
		}else{
	        switch (strBusinessState)
	        {
	            case "03_01_02": //수신부서기안대기   "Receive"
	                strReadMode = "REDRAFT";
	                break;
	            case "01_02_01": //"PersonConsult" 개인
	            case "01_04_01":
	            case "01_04_02":
	                strReadMode = "PCONSULT";
	                break;
	            case "01_03_01": //감사 개인
	                strReadMode = "AUDIT";
	                break;
	            case "01_01_02": //"RecApprove"
	                strReadMode = "RECAPPROVAL";
	                break;
	            case "03_01_03": //협조부서
	            case "03_01_04": //"SubRedraft" 합의부서기안대기
	            case "03_01_05": //감사 부서 대기
	                strReadMode = "SUBREDRAFT";
	                break;
	            case "01_01_04": //"SubApprove" 부서결재
	            case "01_02_02":
	            case "01_01_05":
	            case "01_03_02":
	            case "01_03_03":
	            case "01_02_03":
	                strReadMode = "SUBAPPROVAL";
	                break;
	            case "02_02_01":   //기안부서 반려"Reject"
	            case "02_02_02":
	            case "02_02_03":
	            case "02_02_04":
	            case "02_02_05":
	            case "02_02_06":
	            case "02_02_07":
	                strReadMode = "REJECT";
	                break;
	            case "03_01_06": //"Charge"
	                strReadMode = "CHARGE";
	                break;
	            default:
	            	strReadMode = strReadMode.trim();
	                break;
	        }
	
	        switch (strSubkind) {
	        case "T001":
	        case "T002": //시행문변환
	        	strReadMode = "TRANS"; //변환
	        	break;
	        case "T003":
	        	strReadMode = "SIGN"; //직인
	        	break;
	        case "T018":
	        	 if (workitemState.equals("288")) {
	                strReadMode = "APPROVAL";
	             } else {
	                strReadMode = "COMPLETE"; //공람
	             }
	        	 break;
	    	default:
	    		break;
	        }
		}	
	    return strReadMode;
	}
	
	@Override
	public boolean isPerformer(CoviMap params) {
		boolean isPerformer = false;
		CoviMap map = coviMapperOne.select("expenceApplication.selectPerformerData", params);
		
		// Archive
		if(map.isEmpty()){
			map = coviMapperOne.select("expenceApplication.selectPerformerDataArchive", params);
		}
		
		// 대결
		if(map.isEmpty()){
			map = coviMapperOne.select("expenceApplication.selectPerformerDeputyData", params);
			// 대결 Archive
			if(map.isEmpty()){
				map = coviMapperOne.select("expenceApplication.selectPerformerDeputyDataArchive", params);
			}
		}
		
		if(map.containsKey("PerformerID") && !map.getString("PerformerID").isEmpty())
			isPerformer = true;
		
		return isPerformer;
	}

	@Override
	public boolean isJobFunctionManager(CoviMap params) {
		boolean isManager = false;
		
		CoviMap map = coviMapperOne.select("expenceApplication.selectJobFunctionData", params);
		
		// Archive
		if(map.isEmpty()){
			map = coviMapperOne.select("expenceApplication.selectJobFunctionDataArchive", params);
		}
		
		if(map.containsKey("PerformerID") && !map.getString("PerformerID").isEmpty())
			isManager = true;
		
		return isManager;
	}

	@Override
	public boolean isReceivedByDept(CoviMap params) {
		boolean isRecevied = false;
		CoviMap list = coviMapperOne.select("expenceApplication.selectDeptReceiveData", params);
		
		// Archive
		if(list.size() <= 0){
			list = coviMapperOne.select("expenceApplication.selectDeptReceiveDataArchive", params);
		}
		
		if(list.containsKey("PerformerID") && !list.getString("PerformerID").isEmpty())
			isRecevied = true;
		
		return isRecevied;
	}

	@Override
	public String selectFormPrefixData(CoviMap params) {
		CoviMap map = coviMapperOne.select("expenceApplication.selectFormPrefixData", params);
		String returnStr = "";
		
		if(map.containsKey("FormPrefix"))
			returnStr = map.getString("FormPrefix");
		
		return returnStr;
	}

	@Override
	public boolean isContainedInManagedBizDoc(CoviMap params){
		CoviMap map = coviMapperOne.select("expenceApplication.selectBizDocData", params);		
		return (map.getInt("CNT") > 0);
	}

	@Override
	public boolean isInTCInfo(CoviMap params){
		CoviMap map = coviMapperOne.select("expenceApplication.selectTCInfoData", params);
		
		return (map.getInt("CNT") > 0);
	}
	
	// 감사함 권한 여부 체크
	@Override
	public boolean hasDocAuditAuth(CoviMap params) {
		boolean hasAuth = false;
	
		try {
			CoviList list = coviMapperOne.list("expenceApplication.selectAuditDocData", params);
			String entCode = coviMapperOne.selectOne("expenceApplication.selectEntCode", params);
			Set<String>  authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "MN", "", "V");
	
			for(int i = 0; i < list.size(); i++){
				CoviMap map = list.getMap(i);
				String menuID = map.getString("MenuID");
				String domainCode = map.getString("DomainCode");
			
				if(!menuID.equals("") && authorizedObjectCodeSet.contains(menuID) && (domainCode.equals("ORGROOT") || domainCode.equals(entCode))) {
					hasAuth = true;
					break;
				}
			}
		} catch (NullPointerException e) {
			logger.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage(), e);
		}
		return hasAuth;
	}
	 
	@Override
	public boolean isLinkedDoc(CoviMap params) {
		 CoviMap list = coviMapperOne.select("expenceApplication.selectIsLinkedDocData", params);	  
		 return (list.getInt("CNT") > 0);
	}
	 
	@Override
	public boolean isLinkedExpenceDoc(CoviMap params) {
		CoviMap map = coviMapperOne.select("expenceApplication.selectIsLinkedDocExpData", params);
		return (map.getInt("CNT") > 0);
	}
	
	@Override
	public boolean isDeletedDoc(CoviMap params) {
		 CoviMap list = coviMapperOne.select("expenceApplication.selectIsDeletedDoc", params);	  
		 return (list.getInt("CNT") > 0);
	}
	
	@Override
	public List<CoviMap> selectManageDocTarget(CoviMap params) {
		return coviMapperOne.list("expenceApplication.selectManageTarget", params);
	}

	@Override
	public int selectManageDocData(CoviMap params) {
		int completedCnt = 0;
		
		completedCnt = coviMapperOne.selectOne("expenceApplication.selectManageDocDataCnt", params);
		if(completedCnt == 0) completedCnt = coviMapperOne.selectOne("expenceApplication.selectManageDocTcInfoDataCnt", params);

		return completedCnt;
	}
	
	@Override
	public CoviMap selectChargeJob(CoviMap params) throws Exception{
		CoviMap map = coviMapperOne.select("expenceApplication.selectChargeJob", params); // ChargeJob, RegisterID
		return map;
	}

	@Override
	public CoviList selectSync() throws Exception {
		CoviList result = coviMapperOne.list("expenceApplication.selectSync", null);
		
		for (Object o1 : result) {
			CoviMap c1 = (CoviMap) o1;
			
			String id = c1.getString("ExpenceApplicationID");
			
			CoviMap params = new CoviMap();
			params.put("expenceApplicationId", id);
			
			CoviList list = coviMapperOne.list("expenceApplication.selectSyncList", params);
			
			for (Object o2 : list) {
				CoviMap c2 = (CoviMap) o2;
				
				id = c2.getString("ExpenceApplicationListID");
				
				params = new CoviMap();
				params.put("expenceApplicationListId", id);
				
				CoviList div = coviMapperOne.list("expenceApplication.selectSyncDiv", params);
				
				c2.put("ExpenceApplicationDiv", div);
			}
			
			c1.put("ExpenceApplicationList", list);
		}
		
		return result;
	}

	@Override
	public void syncComplete(CoviMap params) throws Exception {
		coviMapperOne.update("expenceApplication.syncComplete", params);
	}
	
	@Override
	public CoviMap selectUserInfo(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("common.login.selectSSO", params);
		return map;
	}
	
}

