package egovframework.coviaccount.user.service.impl;

import java.lang.invoke.MethodHandles;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviaccount.common.service.CommonSvc;
import egovframework.coviaccount.common.util.AccountExcelUtil;
import egovframework.coviaccount.common.util.AccountUtil;
import egovframework.coviaccount.interfaceUtil.InterfaceUtil;
import egovframework.coviaccount.interfaceUtil.interfaceVO.BankAccountVO;
import egovframework.coviaccount.interfaceUtil.interfaceVO.BusinessNumberVO;
import egovframework.coviaccount.interfaceUtil.interfaceVO.VendorVO;
import egovframework.coviaccount.user.service.BaseCodeSvc;
import egovframework.coviaccount.user.service.BaseInfoSvc;
import egovframework.coviframework.service.MessageService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.MessageHelper;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



/**
 * @Class Name : BaseInfoSvcImpl.java
 * @Description : 기준정보관리 서비스 구현
 * @Modification Information 
 * @author Covision
 * @ 2018.05.14 최초생성
 */
@Service("baseInfoService")
public class BaseInfoSvcImpl extends EgovAbstractServiceImpl implements BaseInfoSvc {

	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Resource(name="AccountExcelUtil")
	private AccountExcelUtil excelUtil;
	
	@Autowired
	private InterfaceUtil interfaceUtil;
	
	@Autowired
	private AccountUtil accountUtil;

	@Autowired
	private MessageService messageService;
	
	@Autowired
	private CommonSvc commonSvc;

	@Autowired
	private BaseCodeSvc baseCodeSvc;	
	
	/**
	* @Method Name : searchVendorList
	* @Description : 거래처 조회
	*/
	@Override
	public CoviMap searchVendorList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		int cnt = 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
				
		cnt = (int)coviMapperOne.getNumber("baseInfo.selectVendorListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("baseInfo.selectVendorList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list
				, "VendorID,CompanyCode,CompanyName,VendorNo,CorporateNo,VendorName,CEOName,Industry,Sector,Address,BankName,BankAccountNo,BankAccountName,PaymentMethod,VendorStatus,VendorStatusName,RegistDate,VendorTypeName,VendorType,BusinessNumber"));
		resultList.put("page", page);
		//resultList.put("cnt", cnt);
		return resultList;
	}

	/**
	* @Method Name : excelDownloadVenderList
	* @Description : 거래처 다운로드
	*/
	@Override
	public CoviMap excelDownloadVenderList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("baseInfo.selectVendorListExcel", params);
		int cnt = (int)coviMapperOne.getNumber("baseInfo.selectVendorListCnt", params);
		CoviMap resultList = new CoviMap();
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	excelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	* @Method Name : excelUploadVenderList
	* @Description : 거래처 등록 액셀 업로드
	*/
	@Override
	public CoviMap excelUploadVenderList(CoviMap params) throws Exception {
		
		int rtn = 0;
		int cnt = 0;
		String newCodeStr = "'";
		CoviMap resultList	= new CoviMap();
		CoviMap chkParam = new CoviMap();
		ArrayList<ArrayList<Object>> dataList = excelUtil.extractionExcelData(params, 1);	// 엑셀 데이터 추출
		CoviList chkList = new CoviList();
		
		int row = 1;
		String rowMsg = DicHelper.getDic("ACC_msg_excel_row");
		
		// 엑셀 업로드 파일의 데이터가 존재하지 않습니다.
		if(dataList.size() == 0) {
			resultList.put("err", "zeroErr");
			resultList.put("message", DicHelper.getDic("ACC_msg_excel_zeroErr"));
			return resultList;
		}
		
		try {
			// index | 0 : 회사코드 | 1 : 회사명 | 2 : 신청유형 | 3 : 사업자번호 | 4 : 법인번호 | 5 : 거래처명 | 6 : 대표자명 | 7 : 업종 | 8 : 업태 | 9 : 주소 | 10 : 은행코드 | 
			// 11 : 은행명 | 12 : 은행계좌 | 13 : 예금주 | 14 : 지급조건 | 15 : 지금방법 | 16 : 상태 | 17 : 소득세유형 | 18 : 지방세유형 |
			for (ArrayList list : dataList){
				if(AccountUtil.checkNull(list.get(1).toString()) ||  // 공백확인
						AccountUtil.checkNull(list.get(2).toString()) ||
						AccountUtil.checkNull(list.get(3).toString()) ||
						AccountUtil.checkNull(list.get(5).toString())){
					resultList.put("err","nullErr");
					resultList.put("message", rowMsg.replace("{row}", String.valueOf(row)) + " " + DicHelper.getDic("ACC_msg_excel_nullErr"));
					return resultList;
				}
				
				String companyCode = list.get(1).toString();
				String vendorNo = list.get(3).toString();
				String newCCode = "";
				
				chkParam.put("codeGroup", "CompanyCode");
				chkParam.put("codeName", companyCode);
				newCCode = baseCodeSvc.selectBaseCodeByCodeName(chkParam); // 회사코드
				
				// 회사가 존재하지 않습니다.
				if("".equals(newCCode) || newCCode == null) {
					resultList.put("err", "companyErr");
					resultList.put("message", rowMsg.replace("{row}", String.valueOf(row)) + " " + DicHelper.getDic("ACC_msg_excel_companyErr"));
					return resultList;
				}
				
				if(newCodeStr.indexOf("'" + newCCode + "','") < 0){ //회사코드체크용
					newCodeStr += newCCode + "','";
				}
				
				params.put("vendorNo", vendorNo);
				params.put("companyCode", newCCode);
//				cnt = (int) coviMapperOne.getNumber("baseInfo.chkVendorNoCntExcel", params);
//				if(cnt != 0){ // 이미 등록된 코드
//					resultList.put("err", "vendorNoErr");
//					resultList.put("message", rowMsg.replace("{row}", String.valueOf(row)) + " " + DicHelper.getDic("ACC_msg_excel_vendorNoErr"));
//					return resultList;
//				}
	
				CoviMap chkItem = new CoviMap();
				chkItem.put("CompanyCode", newCCode);
				chkItem.put("CompanyName", companyCode);
				chkItem.put("vendorNo", vendorNo); //사업자번호
				
				// 엑셀내 중복체크
				boolean bDup = false;
				for(Object item : chkList) {
					if(item instanceof CoviMap) {
						CoviMap map = (CoviMap)item;
						if(map.getString("CompanyCode").equals(newCCode) && map.getString("vendorNo").equals(vendorNo)) {
							bDup = true;
						}
					}
				}
				
				if(bDup){
					resultList.put("err", "excelErr");
					resultList.put("message", rowMsg.replace("{row}", String.valueOf(row)) + " " + DicHelper.getDic("ACC_msg_ckVendorNo"));
					return resultList;
				}else{
					chkList.add(chkItem);
				}
				
				row++;
			}
			String newStr = newCodeStr.substring(0, newCodeStr.length()-2);
			newStr = newStr.replace("&apos;","'").replace("'","");
			String[] chkStr = newStr.split(",");
	
			String sessionUser = SessionHelper.getSession("USERID");
			String userCompanyCode = commonSvc.getCompanyCodeOfUser();
			chkParam.put("companyCode", userCompanyCode);
			if(newStr != null && !newStr.equals("")) chkParam.put("companyCodes", newStr.split(","));
			rtn = (int) coviMapperOne.getNumber("baseInfo.chkCompanyCodeCntExcel", chkParam); // 회사코드 체크
			
			if(chkStr.length == rtn){ // 회사코드유무
				row = 1;
				for (ArrayList list : dataList){  
					CoviMap map = new CoviMap();
					String companyCode = list.get(0).toString();
					String companyName = list.get(1).toString();
					String vendorType = list.get(2).toString();
					String vendorNo = list.get(3).toString();
					String corporateNo = list.get(4).toString();
					String vendorName = list.get(5).toString();
					String CEOName = list.get(6).toString();
					String sector = list.get(7).toString();
					String industry = list.get(8).toString();
					String address = list.get(9).toString();
					String bankCode = list.get(10).toString();
					String bankName = list.get(11).toString();
					String bankAccountNo = list.get(12).toString();
					String bankAccountName = list.get(13).toString();
					String paymentCondition = list.get(14).toString();
					String paymentMethod = list.get(15).toString();
					String vendorStatus = list.get(16).toString();
					String incomTax = list.get(17).toString();
					String localTax = list.get(18).toString();
					
					chkParam.put("codeGroup", "VendorType");
					chkParam.put("codeName", vendorType);
					String newVType = baseCodeSvc.selectBaseCodeByCodeName(chkParam); // 회사코드	
					
					map.put("SessionUser", sessionUser);
					map.put("userCompanyCode", userCompanyCode);
					//insert
					if(newVType.equals("CO")){
						if(vendorNo.replace("-","").length() != 10) {
							resultList.put("err", "vendorErr");
							resultList.put("message", rowMsg.replace("{row}", String.valueOf(row)) + " " + DicHelper.getDic("ACC_msg_ckVendorNo"));
							return resultList;
						}
						map.put("vendorNo", vendorNo);
						map.put("corporateNo", corporateNo);
						map.put("vendorName", vendorName);
						map.put("CEOName", CEOName);
						map.put("sector", sector);
						map.put("industry", industry);
						map.put("address", address);
						map.put("BankCode", bankCode);
						map.put("BankName", bankName);
						map.put("BankAccountNo", bankAccountNo);
						map.put("BankAccountName", bankAccountName);
					}else if(newVType.equals("PE")){
						if(vendorNo.replace("-","").length() != 13) {
							resultList.put("err", "vendorErr");
							resultList.put("message", rowMsg.replace("{row}", String.valueOf(row)) + " " + DicHelper.getDic("ACC_036"));
							return resultList;
						}
						map.put("vendorNo", vendorNo);
						map.put("vendorName", vendorName);
						map.put("address", address);
						map.put("BankCode", bankCode);
						map.put("BankName", bankName);
						map.put("BankAccountNo", bankAccountNo);
						map.put("BankAccountName", bankAccountName);
						chkParam.put("codeGroup", "WHTax");
						chkParam.put("codeName", localTax);
						map.put("localTax", baseCodeSvc.selectBaseCodeByCodeName(chkParam));
						chkParam.put("codeGroup", "WHTax");
						chkParam.put("codeName", incomTax);
						map.put("incomTax", baseCodeSvc.selectBaseCodeByCodeName(chkParam));
					}else if(newVType.equals("OR")){
						map.put("vendorNo", vendorNo);
						map.put("vendorName", vendorName);
						map.put("address", address);
						map.put("BankCode", bankCode);
						map.put("BankName", bankName);
						map.put("BankAccountNo", bankAccountNo);
						map.put("BankAccountName", bankAccountName);
					}				
					map.put("companyCode" , companyCode);
					map.put("companyName" , companyName);
					map.put("vendorType", newVType);
					chkParam.put("codeGroup", "PayType");
					chkParam.put("codeName", paymentCondition);
					map.put("paymentCondition", baseCodeSvc.selectBaseCodeByCodeName(chkParam));
					chkParam.put("codeGroup", "PayMethod");
					chkParam.put("codeName", paymentMethod);
					map.put("paymentMethod", baseCodeSvc.selectBaseCodeByCodeName(chkParam));
					chkParam.put("codeGroup", "vendorStatus");
					chkParam.put("codeName", vendorStatus);
					map.put("vendorStatus", baseCodeSvc.selectBaseCodeByCodeName(chkParam));
					
					// insertVendorExcel(map);
					uploadVendorExcel(map);
					row++;
				}
			}else{
				resultList.put("err","companyCodeErr");
				return resultList;
			}
		} catch (NullPointerException e) {
			resultList.put("err", "rowErr");
			resultList.put("message", rowMsg.replace("{row}", String.valueOf(row)) + " " + DicHelper.getDic("msg_apv_030"));
			return resultList;
		}  catch (Exception e) {
			resultList.put("err", "rowErr");
			resultList.put("message", rowMsg.replace("{row}", String.valueOf(row)) + " " + DicHelper.getDic("msg_apv_030"));
			return resultList;
		} 
		return resultList;
	}
	
	/**
	* @Method Name : insertVendorExcel
	* @Description : 거래처 엑셀 업로드
	*/
	public void insertVendorExcel(CoviMap params) throws Exception {
		coviMapperOne.insert("baseInfo.insertVendorExcel", params);
		
		CoviMap bankParam = new CoviMap();
		
		bankParam.putAll(params);
		bankParam.put("VendorNo", bankParam.getString("vendorNo"));
		bankParam.put("VendorID", params.get("VendorID"));
		
		updateVendorBank(bankParam);
	}
	
	/**
	* @throws Exception 
	 * @throws DataAccessException 
	 * @Method Name : uploadVendorExcel
	* @Description : 거래처 엑셀 업로드
	*/
	private void uploadVendorExcel(CoviMap params) throws Exception {
		String companyCode = baseCodeSvc.selectBaseCodeByCodeName(new CoviMap() {{ 
			this.put("codeGroup", "CompanyCode");
			this.put("codeName", params.getString("companyName"));
		}});
		
		int count = (int) coviMapperOne.getNumber("chkVendorNoCntExcel", new CoviMap() {{
			this.put("companyCode", companyCode);
			this.put("vendorNo", params.getString("vendorNo"));
		}});
		
		if (count == 0) {
			coviMapperOne.insert("baseInfo.insertVendorExcel", params);
		}
		if (count > 0) {
			CoviMap vendor = coviMapperOne.select("baseInfo.selectVendorList", new CoviMap() {{
				this.put("searchCompanyCode", companyCode);
				this.put("searchVendorNo", params.getString("vendorNo"));
			}});
			params.put("VendorID", vendor.getString("VendorID"));
			coviMapperOne.update("baseInfo.updateVendorExcel", new CoviMap() {{
				this.putAll(params);
			}});
		}
		
		CoviMap bankParam = new CoviMap();
		bankParam.putAll(params);
		bankParam.put("VendorNo", bankParam.getString("vendorNo"));
		bankParam.put("VendorID", params.get("VendorID"));
		updateVendorBank(bankParam);
	}
	
	/**
	* @Method Name : updateVendorExcel
	* @Description : 거래처 엑셀 수정 - 사용 안 함
	*/
	public void updateVendorExcel(CoviMap params) throws Exception {
		coviMapperOne.update("baseInfo.updateVendorExcel", params);
	}
	/**
	* @Method Name : deleteVendorList
	* @Description : 거래처 삭제
	*/
	@Override
	public int deleteVendorList(CoviMap params) throws Exception {

		return coviMapperOne.delete("baseInfo.deleteVendorList", params);
	}
	
	/**
	* @Method Name : searchVendorDetail
	* @Description : 거래처 상세 조회
	*/
	@Override
	public CoviMap searchVendorDetail(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.selectOne("baseInfo.selectVendorDetail", params);
		
		CoviMap bankMap = coviMapperOne.selectOne("baseInfo.selectVendorBank", params);
		String bankCode = "";
		String bankName = "";
		String bankAccountNo = "";
		String bankAccountName = "";
		if(bankMap != null) {
			bankCode = bankMap.get("BankCode") == null ? "" : bankMap.get("BankCode").toString();
			bankName = bankMap.get("BankName") == null ? "" : bankMap.get("BankName").toString();
			bankAccountNo = bankMap.get("BankAccountNo") == null ? "" : bankMap.get("BankAccountNo").toString();
			bankAccountName = bankMap.get("BankAccountName") == null ? "" : bankMap.get("BankAccountName").toString();
		}
		
		map.put("BankCode", bankCode);
		map.put("BankName", bankName);
		map.put("BankAccountNo", bankAccountNo);
		map.put("BankAccountName", bankAccountName);

		CoviMap resultMap = new CoviMap();
		resultMap.put("result", AccountUtil.convertNullToSpace(map));
		return resultMap;
	}

	/**
	* @Method Name : checkVendorDuplicate
	* @Description : 거래처 중복체크
	*/
	@Override
	public CoviMap checkVendorDuplicate(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();

		CoviMap map = coviMapperOne.selectOne("baseInfo.checkVendorDuplicate", params);
		resultList.put("duplItem", AccountUtil.convertNullToSpace(map));
		return resultList;
	}

	/**
	* @Method Name : insertVendor
	* @Description : 거래처 추가
	*/
	@Override
	public CoviMap insertVendor(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();

		int cnt = callInsertVendor(params);
		if(cnt==-1){
			resultObj.put("status", "V");
		}
		else if(cnt==-2){
			resultObj.put("status", "D");
		}
		else if(cnt==-3){
			resultObj.put("status", "G");
		}
		else{
			updateVendorBank(params);
			resultObj.put("insertCnt", cnt);
			resultObj.put("status", "S");
		}
		return resultObj;
	}
	
	/**
	* @Method Name : callInsertVendor
	* @Description : 거래처 추가
	*/
	public int callInsertVendor(CoviMap params) throws Exception {		
		int cnt = coviMapperOne.update("baseInfo.insertVendor", params);
		
		if(!params.getString("VendorID").equals("")) {
			cnt = 1;
		}
		
		return cnt;
	}
	
	/**
	* @Method Name : updateVendor
	* @Description : 거래처 수정
	*/
	@Override
	public CoviMap updateVendor(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int cnt = 0;

		cnt = coviMapperOne.update("baseInfo.updateVendor", params);
		updateVendorBank(params);
		
		resultObj.put("status", "S");
		resultObj.put("updateCnt", cnt);
		return resultObj;
	}
	
	public void updateVendorBank(CoviMap params) throws Exception {
		coviMapperOne.delete("baseInfo.deleteVendorBank", params);
		
		String vendorID = (params.has("VendorID") ? AccountUtil.jobjGetStr(params,"VendorID") : "");
		String vendorNo = (params.has("VendorNo") ? AccountUtil.jobjGetStr(params,"VendorNo") : "");
		String[] bankCodeArr = AccountUtil.jobjGetStr(params,"BankCode").split(",");
		String[] bankNameArr = AccountUtil.jobjGetStr(params,"BankName").split(",");
		String[] bankAccountNoArr = AccountUtil.jobjGetStr(params,"BankAccountNo").split(",");
		String[] bankAccountNameArr = AccountUtil.jobjGetStr(params,"BankAccountName").split(",");
		
		for(int i = 0; i < bankCodeArr.length; i++) {
			CoviMap bankParam = new CoviMap();
			bankParam.put("VendorID", vendorID);
			bankParam.put("VendorNo", vendorNo);
			bankParam.put("BankCode", bankCodeArr[i]);
			bankParam.put("BankName", bankNameArr[i]);
			bankParam.put("BankAccountNo", bankAccountNoArr[i]);
			bankParam.put("BankAccountName", bankAccountNameArr[i]);
			//은행 정보가 존재 할 경우에만 insert 처리
			if(Boolean.FALSE.equals(AccountUtil.checkNull(bankCodeArr[i])))
				coviMapperOne.insert("baseInfo.insertVendorBank", bankParam);
		}
	}
	
	/**
	* @Method Name : vendorSync
	* @Description : 거래처 데이터 동기화
	*/
	@Override
	public CoviMap vendorSync() throws Exception{

		CoviMap interfaceParam	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		VendorVO vendorVO		= null;
		
		try{
			//String syncType = accountUtil.getPropertyInfo("account.syncType.Vendor");			
			String syncType = accountUtil.getBaseCodeInfo("eAccSyncType", "Vendor");
			
			interfaceParam.put("interFaceType",			syncType);
			interfaceParam.put("type",					"get");
	
			interfaceParam.put("daoClassName",			"VendorDao");
			interfaceParam.put("voClassName",			"VendorVO");
			interfaceParam.put("mapClassName",			"VendorMap");
	
			interfaceParam.put("daoSetFunctionName",	"setVendorList");
			interfaceParam.put("daoGetFunctionName",	"getVendorList");
			interfaceParam.put("voFunctionName",		"setAll");
			interfaceParam.put("mapFunctionName",		"getMap");
	
			switch (syncType) {
				case "DB":
					//syncType이 DB인 경우 이곳에 정의
					interfaceParam.put("type",		"get");
					interfaceParam.put("sqlName",	"accountInterFace.AccountSI.getInterFaceListVendor");
					break;
		
				case "SOAP":
					//syncType이 SOAP인 경우 이곳에 정의
					break;
					
				case "SAP":
					//syncType이 SAP인 경우 이곳에 정의
					break;
				case "SAPOdata":
					//syncType이 SAPOdata인 경우 이곳에 정의
					String sGetParam = "";
					interfaceParam.put("mapFunctionName",		"getSapODataMap");										
					interfaceParam.put("SAPOdataFuntionName", "API_BUSINESS_PARTNER/A_BusinessPartner");
					sGetParam = accountUtil.addGetParam(sGetParam,"BusinessPartner", "900000", "ge", "and");
					sGetParam = accountUtil.addGetParam(sGetParam,"BusinessPartner", "P00000", "ge", "or");
					interfaceParam.put("SAPOdataParam", sGetParam);		
					
					break;
					
				default :
					break;
			}
				
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
	
			ArrayList list = (ArrayList) getInterface.get("list");
	
			String sessionUser = SessionHelper.getSession("USERID");
	
			for (int i = 0; i < list.size(); i++) {
				CoviMap listInfo = new CoviMap();
				vendorVO = (VendorVO) list.get(i);
				if(vendorVO.getVendorNo().length() > 6) {
					continue;
				}
				
				String tempVendorType	= "P".equals(vendorVO.getVendorNo().substring(0, 1)) ? "PE" : "CO";
				String vendorID			= vendorVO.getVendorID();			//거래처관리ID
				String companyCode		= vendorVO.getCompanyCode();		//회사코드
				String vendorType		= vendorVO.getVendorType();			//거래처구분
				String vendorNo			= vendorVO.getVendorNo();			//사업자등록번호
				String corporateNo		= vendorVO.getCorporateNo();		//법인번호
				String vendorName		= vendorVO.getVendorName();			//거래처명
				String cEOName			= vendorVO.getcEOName();			//대표자명
				String industry			= vendorVO.getIndustry();			//업태
				String sector			= vendorVO.getSector();				//업종
				String address			= vendorVO.getAddress();			//주소
				String bankName			= vendorVO.getBankName();			//은행명
				String bankAccountNo	= vendorVO.getBankAccountNo();		//은행계좌
				String bankAccountName	= vendorVO.getBankAccountName();	//예금주명
				String paymentCondition	= vendorVO.getPaymentCondition();	//지급조건#공통코드
				String paymentMethod	= vendorVO.getPaymentMethod();		//지급방법#공통코드
				String vendorStatus		= vendorVO.getVendorStatus();		//거래처상태#공통코드
				String incomTax			= vendorVO.getIncomTax();			//소득세유형
				String localTax			= vendorVO.getLocalTax();			//지방세유형
				String currencyCode		= vendorVO.getCurrencyCode();		//통화
				
				/*
				switch(vendorType) {
				case "1":
					vendorType = "CO"; //법인
					break;
				case "2":
					vendorType = "PE"; //개인
					break;
				case "4":
					vendorType = "OR"; //임직원
					break;
				}
				*/
	
				listInfo.put("UR_Code",				sessionUser);
				listInfo.put("vendorID",			vendorID);
				listInfo.put("companyCode",			companyCode.equals("") ? "ALL" : companyCode);
				listInfo.put("vendorType",			vendorType);
				listInfo.put("vendorNo",			vendorNo);
				listInfo.put("corporateNo",			corporateNo);
				listInfo.put("vendorName",			vendorName);
				listInfo.put("cEOName",				cEOName);
				listInfo.put("industry",			industry);
				listInfo.put("sector",				sector);
				listInfo.put("address",				address);
				listInfo.put("bankName",			bankName);
				listInfo.put("bankAccountNo",		bankAccountNo);
				listInfo.put("bankAccountName",		bankAccountName);
				listInfo.put("paymentCondition",	paymentCondition);
				listInfo.put("paymentMethod",		paymentMethod);
				listInfo.put("vendorStatus",		vendorStatus);
				listInfo.put("incomTax",			incomTax);
				listInfo.put("localTax",			localTax);
				listInfo.put("currencyCode",		(currencyCode.equals("") ? "KRW" : currencyCode));
				
				if(!vendorName.equals(""))
					vendorInterfaceSave(listInfo);
			}
			
			resultList.put("status",	getInterface.get("status"));
			
			//SAPOdata 계좌정보 연동
			if(syncType.equals("SAPOdata") && getInterface.get("status").equals(Return.SUCCESS)){				
				CoviMap resultBank = new CoviMap();
				resultBank = vendorBankSync();
				resultList.put("status",	resultBank.get("status"));
			}	
			
			/*//SAPOdata 사업자 번호 연동
			if(syncType.equals("SAPOdata") && getInterface.get("status").equals(Return.SUCCESS)){				
				CoviMap resultBusinessNumber = new CoviMap();
				resultBusinessNumber = vendorBusinessNumberSync();
				resultList.put("status",	resultBusinessNumber.get("status"));
			}	*/
			
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
	* @Method Name : vendorInterfaceSave
	* @Description : 업체 인터페이스 저장
	*/
	private void vendorInterfaceSave(CoviMap map) {
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("baseInfo.getVendorInterfaceSaveCnt", map);

		if (cnt == 0) {
			coviMapperOne.insert("baseInfo.vendorInterfaceInsert", map);
		} else {
			coviMapperOne.update("baseInfo.vendorInterfaceUpdate", map);
		}
	}
	
	/**
	* @Method Name : vendorBankSync
	* @Description : 거래처 은행 데이터 동기화
	*/
	@Override
	public CoviMap vendorBankSync() throws Exception{

		CoviMap interfaceParam	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		BankAccountVO bankAccountVO		= null;
		
		try{			
			
			interfaceParam.put("interFaceType",			"SAPOdata");
			interfaceParam.put("type",					"get");
	
			interfaceParam.put("daoClassName",			"BankAccountDao");
			interfaceParam.put("voClassName",			"BankAccountVO");
			interfaceParam.put("mapClassName",			"BankAccountMap");
	
			interfaceParam.put("daoSetFunctionName",	"setBankAccountList");
			interfaceParam.put("daoGetFunctionName",	"getBankAccountList");
			interfaceParam.put("voFunctionName",		"setAll");
				
			String sGetParam = "";
			interfaceParam.put("mapFunctionName",		"getSapODataMap");										
			interfaceParam.put("SAPOdataFuntionName", "API_BUSINESS_PARTNER/A_BusinessPartnerBank");
			interfaceParam.put("SAPOdataParam", sGetParam);
				
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
	
			ArrayList list = (ArrayList) getInterface.get("list");
	
			String sessionUser = SessionHelper.getSession("USERID");
	
			for (int i = 0; i < list.size(); i++) {
				CoviMap listInfo = new CoviMap();
				bankAccountVO = (BankAccountVO) list.get(i);
				String vendorNo			= bankAccountVO.getVendorNo();			//거래처코드
				String bankCode			= bankAccountVO.getBankCode();			//은행코드
				String bankName			= bankAccountVO.getBankName();			//은행명
				String bankAccountNo	= bankAccountVO.getBankAccountNo();		//은행계좌
				String bankAccountName	= bankAccountVO.getBankAccountHolderName();	//예금주		
				String bankCountryKey	= bankAccountVO.getBankCountryKey();	//국가			
				
				listInfo.put("UR_Code",				sessionUser);
				listInfo.put("vendorNo",			vendorNo);
				listInfo.put("bankCode",			bankCode);
				listInfo.put("bankName",			bankName);
				listInfo.put("bankAccountNo",		bankAccountNo);
				listInfo.put("bankAccountName",		bankAccountName.equals("") ? "-" : bankAccountName);
				listInfo.put("bankCountryKey",		bankCountryKey);

				vendorBankInterfaceSave(listInfo);
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
	* @Method Name : vendorBankSync
	* @Description : 거래처 사업자번호 동기화
	*/
	@Override
	public CoviMap vendorBusinessNumberSync() throws Exception {

		CoviMap interfaceParam	= new CoviMap();
		CoviMap resultList	= new CoviMap();
		BusinessNumberVO businessNumberVo = null;
		
		try{			
			
			interfaceParam.put("interFaceType",			"SAPOdata");
			interfaceParam.put("type",					"get");
	
			interfaceParam.put("daoClassName",			"BusinessNumberDao");
			interfaceParam.put("voClassName",			"BusinessNumberVO");
			interfaceParam.put("mapClassName",			"BusinessNumberMap");
	
			interfaceParam.put("daoSetFunctionName",	"setBusinessNumberList");
			interfaceParam.put("daoGetFunctionName",	"getBusinessNumberList");
			interfaceParam.put("voFunctionName",		"setAll");
				
			String sGetParam = "";
			interfaceParam.put("mapFunctionName",		"getSapODataMap");										
			interfaceParam.put("SAPOdataFuntionName", "API_BUSINESS_PARTNER/A_BusinessPartnerTaxNumber");
			//sGetParam += accountUtil.addGetParam(sGetParam,"BPTaxType", "KR2", "eq", "and");
			sGetParam = accountUtil.addGetParam(sGetParam,"BusinessPartner", "900000", "ge", "and");
			sGetParam = accountUtil.addGetParam(sGetParam,"BusinessPartner", "P00000", "ge", "or");
			
			interfaceParam.put("SAPOdataParam", sGetParam);
				
			CoviMap getInterface = interfaceUtil.startInterface(interfaceParam);
	
			ArrayList list = (ArrayList) getInterface.get("list");
	
			for (int i = 0; i < list.size(); i++) {
				CoviMap listInfo = new CoviMap();
				businessNumberVo = (BusinessNumberVO) list.get(i);
				String bpBusinessPartner	= businessNumberVo.getBusinessPartner();		//파트너 정보
				String bpTaxType			= businessNumberVo.getbPTaxType();				//사업자번호 타입
				String bpTaxNumber			= businessNumberVo.getbPTaxNumber();			//사업자번호
				
				listInfo.put("businessPartner",		bpBusinessPartner);
				listInfo.put("taxType",				bpTaxType);
				listInfo.put("taxNumber",			bpTaxNumber);

				vendorBusinessNumberinterfaceSave(listInfo);
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
	* @Method Name : vendorBankInterfaceSave
	* @Description : 업체 은행정보 인터페이스 저장
	*/
	private void vendorBankInterfaceSave(CoviMap map) {
		CoviMap vendorMap = coviMapperOne.select("baseInfo.getVendorBankInterfaceSaveCnt", map);
		String vendorId = vendorMap.getString("VendorID");
		if (!"".equals(vendorId)) {
			map.put("vendorID", vendorId);
			coviMapperOne.delete("baseInfo.vendorBankInterfaceDelete", map);
			coviMapperOne.insert("baseInfo.vendorBankInterfaceInsert", map);
		}
	}
	
	/**
	* @Method Name : vendorBusinessNumberinterfaceSave
	* @Description : 사업자 번호 인터페이스 저장 
	*/
	private void vendorBusinessNumberinterfaceSave(CoviMap map) {
		coviMapperOne.update("baseInfo.mergeVendorBusinessNumber", map);
	}
	
	//==============================거래처신청관리======================================

	/**
	* @Method Name : searchVendorRequestList
	* @Description : 거래처 신청 조회
	*/
	public CoviMap searchVendorRequestList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		int cnt = 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt = (int)coviMapperOne.getNumber("baseInfo.selectVendorRequestListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("baseInfo.selectVendorRequestList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list
				, "VendorApplicationID,CompanyCode,CompanyName,ApplicationTitle,ApplicationType,ApplicationTypeName,IsNew,IsNewName,ApplicationStatus,ApplicationStatusName,VendorNo,CorporateNo,VendorName,CEOName,Industry,Sector,Address,BankName,BankAccountNo,BankAccountName,PaymentCondition,PaymentMethod,VendorStatus,IncomTax,LocalTax,RegistDate,ModifyDate"));
		resultList.put("page", page);
		//resultList.put("cnt", cnt);
		return resultList;
	}

	/**
	* @Method Name : insertVendorRequest
	* @Description : 거래처 신청 추가
	*/
	@Override
	public CoviMap insertVendorRequest(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		
		String userId = SessionHelper.getSession("USERID");
		
		params.put("CompanyCode", commonSvc.getCompanyCodeOfUser(userId));
		params.put("SessionUser", userId);
		
		int cnt = 0;
		cnt = coviMapperOne.update("baseInfo.insertVendorApplication", params);
		
		//거래처 신청 은행 정보 추가/수정
		updateVendorRequestBank(params);
		
		resultObj.put("status", "S");
		resultObj.put("VendorApplicationID", AccountUtil.jobjGetStr(params,"VendorApplicationID"));
		resultObj.put("updateCnt", cnt);		
		
		return resultObj;
	}	
	
	/**
	* @Method Name : updateVendorRequest
	* @Description : 거래처 신청 수정
	*/
	@Override
	public CoviMap updateVendorRequest(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();

		params.put("SessionUser", SessionHelper.getSession("USERID"));
		
		int cnt = 0;
		cnt = coviMapperOne.update("baseInfo.updateVendorApplication", params);

		//거래처 신청 은행 정보 추가/수정
		updateVendorRequestBank(params);
		
		resultObj.put("status", "S");
		resultObj.put("VendorApplicationID", AccountUtil.jobjGetStr(params,"VendorApplicationID"));
		resultObj.put("updateCnt", cnt);
		return resultObj;
	}

	public void updateVendorRequestBank(CoviMap params) throws Exception {
		coviMapperOne.delete("baseInfo.deleteVendorRequestBank", params);
		
		String vendorApplicationID = AccountUtil.jobjGetStr(params,"VendorApplicationID");
		String[] bankCodeArr = AccountUtil.jobjGetStr(params,"BankCode").split(",");
		String[] bankNameArr = AccountUtil.jobjGetStr(params,"BankName").split(",");
		String[] bankAccountNoArr = AccountUtil.jobjGetStr(params,"BankAccountNo").split(",");
		String[] bankAccountNameArr = AccountUtil.jobjGetStr(params,"BankAccountName").split(",");
		
		for(int i = 0; i < bankCodeArr.length; i++) {
			CoviMap bankParam = new CoviMap();
			bankParam.put("VendorApplicationID", vendorApplicationID);
			bankParam.put("BankName", bankNameArr[i]);
			bankParam.put("BankCode", bankCodeArr[i]);
			bankParam.put("BankAccountNo", bankAccountNoArr[i]);
			bankParam.put("BankAccountName", bankAccountNameArr[i]);
			if(Boolean.FALSE.equals(AccountUtil.checkNull(bankCodeArr[i])))
				coviMapperOne.insert("baseInfo.insertVendorRequestBank", bankParam);
		}
	}
	
	/**
	* @Method Name : searchVendorRequestDetail
	* @Description : 거래처 신청 조회
	*/
	@Override
	public CoviMap searchVendorRequestDetail(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.selectOne("baseInfo.selectVendorRequestDetail", params);
		
		CoviMap bankMap = coviMapperOne.selectOne("baseInfo.selectVendorRequestBank", params);
		String bankCode = "";
		String bankName = "";
		String bankAccountNo = "";
		String bankAccountName = "";
		if(bankMap != null) {
			bankCode = bankMap.get("BankCode") == null ? "" : bankMap.get("BankCode").toString();
			bankName = bankMap.get("BankName") == null ? "" : bankMap.get("BankName").toString();
			bankAccountNo = bankMap.get("BankAccountNo") == null ? "" : bankMap.get("BankAccountNo").toString();
			bankAccountName = bankMap.get("BankAccountName") == null ? "" : bankMap.get("BankAccountName").toString();
		}
		
		if(map != null) {
			map.put("BankCode", bankCode);
			map.put("BankName", bankName);
			map.put("BankAccountNo", bankAccountNo);
			map.put("BankAccountName", bankAccountName);
		}

		CoviMap resultMap = new CoviMap();
		resultMap.put("result", AccountUtil.convertNullToSpace(map));
		return resultMap;
	}

	/**
	* @Method Name : deleteVendorRequestList
	* @Description : 거래처 신청 삭제
	*/
	@Override
	public int deleteVendorRequestList(CoviMap params) throws Exception {

		int checkNum = (int)coviMapperOne.getNumber("baseInfo.selectVendorRequestDeleteCk", params);
		int cnt = 0;
		if(checkNum != 0){
			cnt =  -1;
		}
		else{
			cnt = coviMapperOne.delete("baseInfo.deleteVendorRequestList", params);
		}
		return cnt;
	}

	/**
	* @Method Name : excelDownloadVendorRequest
	* @Description : 거래처신청 엑셀 다운로드
	*/
	@Override
	public CoviMap excelDownloadVendorRequest(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("baseInfo.selectVendorRequestListExcel", params);
		int cnt = (int)coviMapperOne.getNumber("baseInfo.selectVendorRequestListCnt", params);
		CoviMap resultList = new CoviMap();
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	excelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	* @Method Name : vendAprvStatCk
	* @Description : 결재 상태 변경전 상태체크
	*/
	@Override
	public boolean vendAprvStatCk(CoviMap params) throws Exception {
		CoviList aprvList = (CoviList) AccountUtil.jobjGetObj(params,"aprvList");
		String setStat = AccountUtil.jobjGetStr(params,"setStatus");

		boolean retVal = false;
		CoviMap statCkParam = new CoviMap();
		List<String> ckList = new LinkedList<>();
		
		if(aprvList == null || aprvList.isEmpty()) {
			String vendorApplicationID = AccountUtil.jobjGetStr(params,"VendorApplicationID");
			if(vendorApplicationID != null && !vendorApplicationID.equals("")) statCkParam.put("VendorApplicationIDList", vendorApplicationID.split(","));	
		} else {
			for(int i=0; i<aprvList.size(); i++){
				CoviMap getItem =  aprvList.getJSONObject(i);
				String vdAppId = AccountUtil.jobjGetStr(getItem,"VendorApplicationID");
				
				ckList.add(vdAppId);
			}
			if(!ckList.isEmpty()) statCkParam.put("VendorApplicationIDList", ckList.stream().toArray(String[]::new));
		}
		
		if("T".equals(setStat)
				||"E".equals(setStat)
				||"R".equals(setStat)){
			//신청, 기안
			statCkParam.put("ckStatList", new String [] { "S","D"});
		}
		
		int ckCnt = (int)coviMapperOne.getNumber("baseInfo.selectVendorReqAprvStatck", statCkParam);
		if(ckCnt == 0){
			retVal = true;
		}
		return retVal;
	}
	
	/**
	* @Method Name : vendAprvStatChange
	* @Description : 승인상태 변경
	*/
	@Override
	public CoviMap vendAprvStatChange(CoviMap params) throws Exception {
		CoviMap resultObj	= new CoviMap();
		
		CoviList aprvList = (CoviList) AccountUtil.jobjGetObj(params,"aprvList");

		String setStat = AccountUtil.jobjGetStr(params,"setStatus");
		String sessionUser = SessionHelper.getSession("USERID");
		
		if(aprvList == null) {
			CoviMap aprvObj = new CoviMap();
			CoviList tempList = new CoviList();
			String vendorApplicationID = AccountUtil.jobjGetStr(params,"VendorApplicationID");
			aprvObj.put("VendorApplicationID", vendorApplicationID);
			tempList.add(aprvObj);
			aprvList = tempList;
		}
		
		if(aprvList != null){
			for(int i=0; i<aprvList.size(); i++){
				CoviMap getItem =  aprvList.getJSONObject(i);

				getItem.put("ApplicationStatus", setStat);
				getItem.put("SessionUser", sessionUser);
				coviMapperOne.update("baseInfo.vendAprvStatChange", getItem);

				CoviMap aprvItem = coviMapperOne.selectOne("baseInfo.selectVendorReqInfoAfterAprv", getItem); //회사코드
				if(aprvItem != null){
					aprvItem.put("SessionUser", sessionUser);
					//승인, 반려시 해야 할 작업
					if("E".equals(setStat)){
						
						String isAppNew = "";
						String isAppApplicationType = "";
						
						if(aprvItem.get("IsNew") != null){
							isAppNew = (String)aprvItem.get("IsNew");
						}
						if(aprvItem.get("ApplicationType") != null){
							isAppApplicationType = (String)aprvItem.get("ApplicationType");
						}
						
						CoviMap jsonBankItem = new CoviMap();
						if("Y".equals(isAppNew)){
							switch(aprvItem.getString("ApplicationType")) {
							case "People": aprvItem.put("VendorType", "PE"); break;
							case "Organization": aprvItem.put("VendorType", "OR"); break;
							case "Company": aprvItem.put("VendorType", "CO"); break;
							default : break;
							}
							coviMapperOne.insert("baseInfo.insertVendorReqInfoAfterAprv", aprvItem);
							jsonBankItem.put("VendorID", aprvItem.getString("VendorID"));
						}else if ("N".equals(isAppNew)){
							if(!("BankChange".equals(isAppApplicationType))){
								coviMapperOne.insert("baseInfo.updateVendorReqInfoAfterAprv", aprvItem);
							}
							jsonBankItem.put("VendorNo", aprvItem.getString("VendorNo"));
						}
						
						CoviMap bankItem = coviMapperOne.selectOne("baseInfo.selectVendorReqBankInfoAfterAprv", getItem);
						//은행 정보가 존재 할경우에만 Update 처리
						if(bankItem != null){
							jsonBankItem.putAll(bankItem);
							updateVendorBank(jsonBankItem);
						}
						
						//////////////////////////////
						SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
						String smart4jUrlPath = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
						String messageContext = MessageHelper.getInstance().makeDefaultMessageContext(
								"거래처신청이 승인되었습니다.", 						// pServiceName 
								"EAccountingVendorAprvSucc", 				// pMsgType / strMsgSubject
								"", 										// pDesc
								(String)aprvItem.get("ApplicationTitle"), 	// pSubject / strMsgSubject
								SessionHelper.getSession("UR_Name"), 		// pRegister / SessionHelper.getSession("UR_Name")
								sdf.format(new Date()), 					// pRegistDateTime
								smart4jUrlPath, 							// smart4jUrlPath + "/groupware/workreport/workreport_workreport.do";
								"", 										//MobileURL
								"EAccounting", 								//pServiceType
								SessionHelper.getSession("DN_ID")); 		//pDomainId
						CoviMap notificationMap = new CoviMap();
						notificationMap.put("ServiceType", "EAccounting");
						notificationMap.put("MsgType", "EAccountingVendorAprvSucc");
						notificationMap.put("MediaType", "MAIL,MDM,TODOLIST");
						//notificationMap.put("SenderCode", "superadmin");
						notificationMap.put("MessagingSubject", "[승인]거래처신청이 승인되었습니다.");
						notificationMap.put("MessageContext", messageContext);
						notificationMap.put("ReceiverText", "[승인]거래처신청이 승인되었습니다.");
						//notificationMap.put("ReceiversCode", userSetting.get("MailAddress"));
						notificationMap.put("ReceiversCode", aprvItem.get("RegisterID"));
						notificationMap.put("ApprovalState", "P");
						notificationMap.put("IsUse", "Y");
						notificationMap.put("IsDelay", "N");
						// mail send
						messageService.insertMessagingData(notificationMap);
					}else if("R".equals(setStat)){
						SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
						String smart4jUrlPath = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
						String messageContext = MessageHelper.getInstance().makeDefaultMessageContext(
								"거래처신청이 반려되었습니다.", 						// pServiceName 
								"EAccountingVendorAprvReject", 				// pMsgType / strMsgSubject
								"", 										// pDesc
								(String)aprvItem.get("ApplicationTitle"),  	// pSubject / strMsgSubject
								SessionHelper.getSession("UR_Name"), 		// pRegister / SessionHelper.getSession("UR_Name")
								sdf.format(new Date()), 					// pRegistDateTime
								smart4jUrlPath, 							// smart4jUrlPath + "/groupware/workreport/workreport_workreport.do";
								"", 										//MobileURL
								"EAccounting",								//pServiceType
								SessionHelper.getSession("DN_ID")); 		//pDomainId
						CoviMap notificationMap = new CoviMap();
						notificationMap.put("ServiceType", "EAccounting");
						notificationMap.put("MsgType", "EAccountingVendorAprvReject");
						notificationMap.put("MediaType", "MAIL,MDM,TODOLIST");
						//notificationMap.put("SenderCode", "superadmin");
						notificationMap.put("MessagingSubject", "[반려]거래처신청이 반려되었습니다.");
						notificationMap.put("MessageContext", messageContext);
						notificationMap.put("ReceiverText", "[반려]거래처신청이 반려되었습니다.");
						//notificationMap.put("ReceiversCode", userSetting.get("MailAddress"));
						notificationMap.put("ReceiversCode", aprvItem.get("RegisterID"));
						notificationMap.put("ApprovalState", "P");
						notificationMap.put("IsUse", "Y");
						notificationMap.put("IsDelay", "N");
						// mail send
						messageService.insertMessagingData(notificationMap);
					}
				}
			}
		}
		resultObj.put("status", "S");
		return resultObj;
	}
	//==============================카드신청======================================

	/**
	* @Method Name : searchCardApplicationList
	* @Description : 카드 신청 조회
	*/
	public CoviMap searchCardApplicationList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		
		int cnt			= 0;
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
				
		cnt = (int)coviMapperOne.getNumber("baseInfo.selectCardApplicationListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("baseInfo.selectCardApplicationList", params);
		
		resultList.put("list", CoviSelectSet.coviSelectJSON(list
				, "CardApplicationID,CompanyCode,CompanyName,ApplicationTitle,ApplicationClass,ApplicationType,ApplicationTypeName,ApplicationStatus,ApplicationStatusName,CardNo,CardCompany,CardCompanyName,LimitType,LimitAmountType,LimitAmount,ChangeExpirationDate,ApplicationStartDate,ApplicationFinishDate,ApplicationAmount,ApplicationReason,IsUse,RegisterID,ModifierID,ModifyDate,RegistDate"));
		resultList.put("page", page);
		//resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	* @Method Name : searchCardApplicationDetail
	* @Description : 카드신청 상세 조회
	*/
	@Override
	public CoviMap searchCardApplicationDetail(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.selectOne("baseInfo.selectCardApplicationDetail", params);

		CoviMap resultMap = new CoviMap();
		resultMap.put("result", AccountUtil.convertNullToSpace(map));
		return resultMap;
	}
	
	/**
	* @Method Name : getCompanyCardComboList
	* @Description : 회사코드 콤보 목록 상세 조회
	*/
	@Override
	public CoviMap getCompanyCardComboList(CoviMap params) throws Exception {
		
		String sessionUser = SessionHelper.getSession("USERID");
		params.put("SessionUser", sessionUser);
		params.put("companyCode", commonSvc.getCompanyCodeOfUser(sessionUser));
		CoviList list = coviMapperOne.list("baseInfo.selectCompanyCardComboList", params);
		CoviMap resultMap = new CoviMap();
		resultMap.put("list", CoviSelectSet.coviSelectJSON(list
				, "CorpCardID,CompanyCode,CardNo,CardNoView,CardCompany,CardCompanyName,CardClass,CardStatus,OwnerUserCode,VendorNo,IssueDate,ExpirationDate,LimitAmountType,LimitAmount,Note,data,label"));
		return resultMap;
	}

	/**
	* @Method Name : ckPrivateCardDuplCnt
	* @Description : 개인카드 중복체크
	*/
	@Override
	public int ckPrivateCardDuplCnt(CoviMap params) throws Exception {
		return (int)coviMapperOne.getNumber("baseInfo.selectPrivateCardDuplCnt", params);
	}
	
	/**
	* @Method Name : insertCardApplication
	* @Description : 카드 신청 추가
	*/
	@Override
	public CoviMap insertCardApplication(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();

		String sessionUser = SessionHelper.getSession("USERID");
		params.put("SessionUser", sessionUser);
		params.put("CompanyCode", commonSvc.getCompanyCodeOfUser(sessionUser));

		int cnt = 0;
		cnt = coviMapperOne.update("baseInfo.insertCardApplication", params);
		
		resultObj.put("status", "S");
		resultObj.put("CardApplicationID", AccountUtil.jobjGetStr(params,"CardApplicationID"));
		resultObj.put("updateCnt", cnt);
		
		return resultObj;
	}
	
	/**
	* @Method Name : updateCardApplication
	* @Description : 카드 신청 수정
	*/
	@Override
	public CoviMap updateCardApplication(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();

		String sessionUser = SessionHelper.getSession("USERID");
		params.put("SessionUser", sessionUser);
		params.put("CompanyCode", commonSvc.getCompanyCodeOfUser(sessionUser));
		
		int cnt = 0;
		cnt = coviMapperOne.update("baseInfo.updateCardApplication", params);
		
		resultObj.put("status", "S");
		resultObj.put("CardApplicationID", AccountUtil.jobjGetStr(params,"CardApplicationID"));
		resultObj.put("updateCnt", cnt);
		return resultObj;
	}

	/**
	* @Method Name : deleteCardApplicationList
	* @Description : 카드신청 삭제
	*/
	@Override
	public int deleteCardApplicationList(CoviMap params) throws Exception {
		return coviMapperOne.delete("baseInfo.deleteCardApplicationList", params);
	}
	
	/**
	* @Method Name : excelDownloadCardApplication
	* @Description : 카드신청 엑셀 다운로드
	*/
	@Override
	public CoviMap excelDownloadCardApplication(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("baseInfo.selectCardApplicationListExcel", params);
		int cnt = (int)coviMapperOne.getNumber("baseInfo.selectCardApplicationListCnt", params);
		CoviMap resultList = new CoviMap();
		String headerKey	= params.get("headerKey").toString();
		resultList.put("list",	excelUtil.selectJSONForExcel(list,headerKey));
		resultList.put("cnt", cnt);
		return resultList;
	}
	//==============================카드신청======================================

	/**
	* @Method Name : searchPrivateCardViewList
	* @Description : 개인카드 목록 조회(미사용)
	*/
	public CoviMap searchPrivateCardViewList(CoviMap params) throws Exception {
		int cnt = 0;			
		CoviMap resultList = new CoviMap();
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		cnt = (int)coviMapperOne.getNumber("baseInfo.selectPrivateCardViewListCnt", params);
		
		CoviMap page 	= ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("baseInfo.selectPrivateCardViewList", params);

		resultList.put("list", CoviSelectSet.coviSelectJSON(list
				, "CardApplicationID,CompanyCode,CompanyName,ApplicationTitle,ApplicationClass,ApplicationType,ApplicationTypeName,ApplicationStatus,ApplicationStatusName,CardNo,CardCompany,CardCompanyName,LimitType,LimitAmountType,LimitAmount,ChangeExpirationDate,ApplicationStartDate,ApplicationFinishDate,ApplicationAmount,ApplicationReason,IsUse,RegisterID,ModifierID,ModifyDate,RegistDate,IsUseView,RegisterName"));
		resultList.put("page", page);
		//resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	* @Method Name : updatePrivateCardUseYN
	* @Description : 개인카드 수정(미사용)
	*/
	@Override
	public CoviMap updatePrivateCardUseYN(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		int cnt = 0;
		cnt = coviMapperOne.update("baseInfo.updatePrivateCardUseYN", params);
		resultObj.put("status", "S");
		resultObj.put("updateCnt", cnt);
		return resultObj;
	}

	/**
	* @Method Name : excelDownloadPriCard
	* @Description : 개인카드 엑셀 다운로드
	*/
	@Override
	public CoviMap excelDownloadPriCard(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("baseInfo.selectPrivateCardViewListExcel", params);
		int cnt = (int)coviMapperOne.getNumber("baseInfo.selectPrivateCardViewListCnt", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list
				, "CardNo,CompanyName,RegisterName,RegistDate,IsUseView"));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	/**
	* @Method Name : cardAprvStatCk
	* @Description : 카드 승인상태 변경전 체크
	*/
	@Override
	public boolean cardAprvStatCk(CoviMap params) throws Exception {
		CoviList aprvList = (CoviList) AccountUtil.jobjGetObj(params,"aprvList");
		String setStat = AccountUtil.jobjGetStr(params,"setStatus");

		CoviMap statCkParam = new CoviMap();
		List<String> ckList = new LinkedList<>();
		if(aprvList != null) {
			for(int i=0; i<aprvList.size(); i++){
				CoviMap getItem =  aprvList.getJSONObject(i);
				String cardAppId = AccountUtil.jobjGetStr(getItem,"CardApplicationID");			
				ckList.add(cardAppId);
			}
		}
		if(!ckList.isEmpty()) statCkParam.put("CardApplicationIDList", ckList.stream().toArray(String[]::new));
		if("T".equals(setStat)
				||"E".equals(setStat)
				||"R".equals(setStat)){
			//신청, 기안
			statCkParam.put("ckStatList", new String [] { "S","D"});
		}
		int ckCnt = (int)coviMapperOne.getNumber("baseInfo.selectCardReqAprvStatck", statCkParam);
		
		return (ckCnt == 0);
	}

	/**
	* @Method Name : cardAprvStatChange
	* @Description : 승인상태 변경
	*/
	@Override
	public CoviMap cardAprvStatChange(CoviMap params) throws Exception {
		CoviMap resultObj	= new CoviMap();
		
		CoviList aprvList = (CoviList) AccountUtil.jobjGetObj(params,"aprvList");

		String setStat = AccountUtil.jobjGetStr(params,"setStatus");
		String sessionUser = SessionHelper.getSession("USERID");		

		if(aprvList == null) {
			CoviMap aprvObj = new CoviMap();
			CoviList tempList = new CoviList();
			String cardApplicationID = AccountUtil.jobjGetStr(params,"CardApplicationID");
			aprvObj.put("CardApplicationID", cardApplicationID);
			tempList.add(aprvObj);
			aprvList = tempList;
		}
		
		if(aprvList != null){
			for(int i=0; i<aprvList.size(); i++){
				CoviMap getItem =  aprvList.getJSONObject(i);

				getItem.put("ApplicationStatus", setStat);
				getItem.put("SessionUser", sessionUser);
				coviMapperOne.update("baseInfo.cardAprvStatChange", getItem);
				CoviMap aprvItem = coviMapperOne.selectOne("baseInfo.selectPrivateCardInfoAfterAprv", getItem); //회사코드
				
				//승인, 반려시 해야 할 작업
				if("E".equals(setStat)){
					if("PrCardApp".equals(aprvItem.get("ApplicationType"))){
						coviMapperOne.insert("baseInfo.insertPrivateCardInfoAfterAprv", aprvItem);
					}

					SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
					String smart4jUrlPath = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
					String messageContext = MessageHelper.getInstance().makeDefaultMessageContext(
									"카드신청이 승인되었습니다.", 						// pServiceName 
									"EAccountingCardAprvSucc", 					// pMsgType / strMsgSubject
									"", 										// pDesc
									(String)aprvItem.get("ApplicationTitle"),  	// pSubject / strMsgSubject
									SessionHelper.getSession("UR_Name"), 		// pRegister / SessionHelper.getSession("UR_Name")
									sdf.format(new Date()), 					// pRegistDateTime
									smart4jUrlPath, 							// smart4jUrlPath + "/groupware/workreport/workreport_workreport.do";
									"", 										//MobileURL
									"EAccounting",								//pServiceType
									SessionHelper.getSession("DN_ID")); 		//pDomainId
					
					CoviMap notificationMap = new CoviMap();
					notificationMap.put("ServiceType", "EAccounting");
					notificationMap.put("MsgType", "EAccountingCardAprvSucc");
					notificationMap.put("MediaType", "MAIL,MDM,TODOLIST");
					//notificationMap.put("SenderCode", "superadmin");
					notificationMap.put("MessagingSubject", "[승인]카드신청이 승인되었습니다.");
					notificationMap.put("MessageContext", messageContext);
					notificationMap.put("ReceiverText", "[승인]카드신청이 승인되었습니다.");
					//notificationMap.put("ReceiversCode", userSetting.get("MailAddress"));
					notificationMap.put("ReceiversCode", aprvItem.get("RegisterID"));
					notificationMap.put("ApprovalState", "P");
					notificationMap.put("IsUse", "Y");
					notificationMap.put("IsDelay", "N");
					
					// mail send
					messageService.insertMessagingData(notificationMap);
				}else if("R".equals(setStat)){
					SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
					String smart4jUrlPath = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
					String messageContext = MessageHelper.getInstance().makeDefaultMessageContext(
									"카드신청이 반려되었습니다.", 						// pServiceName 
									"EAccountingCardAprvSucc", 					// pMsgType / strMsgSubject
									"", 										// pDesc
									(String)aprvItem.get("ApplicationTitle"),	// pSubject / strMsgSubject
									SessionHelper.getSession("UR_Name"), 		// pRegister / SessionHelper.getSession("UR_Name")
									sdf.format(new Date()), 					// pRegistDateTime
									smart4jUrlPath, 							// smart4jUrlPath + "/groupware/workreport/workreport_workreport.do";
									"", 										//MobileURL
									"EAccounting",								//pServiceType
									SessionHelper.getSession("DN_ID")); 		//pDomainId
					CoviMap notificationMap = new CoviMap();
					notificationMap.put("ServiceType", "EAccounting");
					notificationMap.put("MsgType", "EAccountingCardAprvReject");
					notificationMap.put("MediaType", "MAIL,MDM,TODOLIST");
					//notificationMap.put("SenderCode", "superadmin");
					notificationMap.put("MessagingSubject", "[반려]카드신청이 반려되었습니다.");
					notificationMap.put("MessageContext", messageContext);
					notificationMap.put("ReceiverText", "[반려]카드신청이 반려되었습니다.");
					//notificationMap.put("ReceiversCode", userSetting.get("MailAddress"));
					notificationMap.put("ReceiversCode", aprvItem.get("RegisterID"));
					notificationMap.put("ApprovalState", "P");
					notificationMap.put("IsUse", "Y");
					notificationMap.put("IsDelay", "N");
					// mail send
					messageService.insertMessagingData(notificationMap);
				}
			}
		}
		resultObj.put("status", "S");
		return resultObj;
	}
}