package egovframework.covision.coviflow.store.service.impl;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.covision.coviflow.common.util.ApprovalUtil;
import egovframework.covision.coviflow.common.util.RequestHelper;
import egovframework.covision.coviflow.store.service.StoreUserFormSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("storeUserFormService")
public class StoreUserFormSvcImpl extends EgovAbstractServiceImpl implements StoreUserFormSvc{
	private static final Logger LOGGER = LogManager.getLogger(StoreUserFormSvcImpl.class);
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private FileUtilService fileUtilSvc;
	
	@Override
	public CoviList getFormsCategoryList(CoviMap params) throws Exception {
		CoviList list = new CoviList();
		
		list = coviMapperOne.list("store.userForm.selectFormsCategoryList", params);
		return CoviSelectSet.coviSelectJSON(list);
	}
	
	@Override
	public CoviMap getStoreUserFormList(CoviMap params, boolean paging) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		if(paging) {
			int cnt = (int) coviMapperOne.getNumber("store.userForm.selectStoreFormListCnt", params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}
		
		CoviList list = coviMapperOne.list("store.userForm.selectStoreFormList", params);
		if(params.containsKey("headerkey")) {
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, params.getString("headerkey")));
		}else {
			resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		}
		resultList.put("page",page);
		
		return resultList;
	}	
	
	@Override
	public CoviMap getPurchaseFormData(CoviMap params) throws Exception {
		// return coviMapperOne.select("store.userForm.selectPurchaseFormData", params);
		// Groupware [Store] 모듈 호출방식으로 변경.
		CoviMap resultList = new CoviMap();
		
		// API Call
		String gwUrl = PropertiesUtil.getGlobalProperties().getProperty("groupware.legacy.path");
		gwUrl = gwUrl + "/store/getCouponCountInfo.do";
		
		params.put("DomainID", SessionHelper.getSession("DN_ID"));
		params.put("CouponType", "APPFORM");
		Map<String, Object> rtnObject = RequestHelper.sendUrl(gwUrl, "application/json", "POST", params);
		
        //rtnObject.get("STATUS");
        String responseBody = (String)rtnObject.get("MESSAGE");
        CoviMap response = new CoviMap(responseBody);
        
		CoviMap info = response.getJSONObject("info");
		
		resultList.put("ApvFormsFreeCount", info.optInt("totCnt")); // 총개수
		resultList.put("CouponUseCnt", info.optInt("useCnt")); // 사용
		resultList.put("CouponRemainCnt", info.optInt("remainCnt")); // 잔여
		
		return resultList;
	}
	
	@Override
	public CoviMap getStoreUserFormData(CoviMap params) throws Exception {		
		CoviMap returnData = coviMapperOne.select("store.userForm.getStoreFormData", params);		
		
		return CoviSelectSet.coviSelectMapJSON(returnData);
	}
	
	@Override
	public CoviMap getStoreFormClassList(CoviMap params) throws Exception {		
		CoviList classlist = coviMapperOne.list("store.userForm.getStoreFormClassList", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("classlist", CoviSelectSet.coviSelectJSON(classlist, "optionValue,optionText"));
		return resultList;
	}
	
	@Override
	public CoviMap storePurchaseForm(CoviMap fObj) throws Exception {		
		boolean buyFormYN = false;
		String returnMsg = "";
		String isCoupon = "N"; // 쿠폰사용여부 (유료양식)
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");
		CoviMap returnData = new CoviMap();
		
		//양식구매 여부
		if("N".equals(fObj.optString("PurchaseYN"))) {
			if("Y".equals(fObj.optString("IsFree"))) {
				// 무료양식
				buyFormYN = true;
			} else {
				if(fObj.optLong("CouponRemainCnt") > 0) {
					// 유료양식
					buyFormYN = true;
					isCoupon = "Y";
				}else {
					returnMsg = DicHelper.getDic("msg_NoCoupon"); //"잔여쿠폰이 없습니다."
				}
			}
		}else{
			returnMsg = DicHelper.getDic("msg_BeenFormPaurchase"); //"이미 구매한 양식입니다."
		}
		
		try {
			int formsExistCnt = (int) coviMapperOne.getNumber("store.userForm.selectFormsExistCnt", fObj);
			if(buyFormYN && formsExistCnt == 0) {
				fObj.put("IsCoupon", isCoupon);
				if(fObj.containsKey("FormHtmlFileID")) { fObj.put("FileName", copyFile(fObj.optString("FormHtmlFileID"))); }
				if(fObj.containsKey("FormJsFileID")) { fObj.put("jsFileName", copyFile(fObj.optString("FormJsFileID"))); }
				if("Y".equals(fObj.optString("MobileFormYN"))) {
					if(fObj.has("MobileFormHtmlFileID") && !StringUtil.isEmpty(fObj.optString("MobileFormHtmlFileID"))) { fObj.put("mobileHtmlFileName", copyFile(fObj.optString("MobileFormHtmlFileID"))); }
					if(fObj.has("MobileFormJsFileID")   && !StringUtil.isEmpty(fObj.optString("MobileFormJsFileID")  )) { fObj.put("mobilejsFileName", copyFile(fObj.optString("MobileFormJsFileID"))); }
				}
				fObj.put("isSaaS", isSaaS);
				
				coviMapperOne.insert("store.userForm.insertStorePurchaseForm", fObj);
				coviMapperOne.update("store.userForm.updateStorePurchasedCnt", fObj);
				coviMapperOne.insert("store.userForm.insertSchemaData", fObj);
				if("Y".equals(fObj.optString("MobileFormYN"))) {
					CoviMap extInfo = coviMapperOne.select("store.userForm.getExtInfo", fObj).getJSONObject("ExtInfo");
					extInfo.put("MobileFormYN", "Y");
					fObj.put("extInfo", extInfo);
				}
				coviMapperOne.insert("store.userForm.insertFormsData", fObj);

				if(!"".equals(fObj.optString("SchemaID")) && !"".equals(fObj.optString("FormID"))) {
					returnData.put("buyFormYN", buyFormYN);
					returnData.put("returnMsg", DicHelper.getDic("msg_CompleteFormPaurchase")); // "구매가 완료되었습니다. 세부설정이 필요한 경우 양식관리 메뉴에서 설정해 주세요."
				}else{
					throw new Exception(DicHelper.getDic("msg_FailFormPaurchase"));//"양식구매시 오류가 발생하였습니다. 관리자에게 문의하세요."
				}
				
				// Coupon 사용처리(차감) , 시스템오류 발생시 Execption 을 그대로 발생시킨다. ( Rollback )
				// 유료양식일 경우만 처리
				if("Y".equals(isCoupon)) {
					String couponID = fObj.getString("CouponID");
					if(StringUtil.isEmpty(couponID)) {
						// 변조방지
						throw new Exception ("No Coupon Selected.");
					}
					// API Call
					String gwUrl = PropertiesUtil.getGlobalProperties().getProperty("groupware.legacy.path");
					gwUrl = gwUrl + "/store/consumeCoupon.do";
					
					CoviMap couponParams = new CoviMap();
					couponParams.put("CouponID", couponID);
					couponParams.put("DomainID", SessionHelper.getSession("DN_ID"));
					couponParams.put("RefID", fObj.optString("PurchaseID"));
					couponParams.put("ChgUserCode", SessionHelper.getSession("UR_Code"));
					// Event
					couponParams.put("CouponType", "APPFORM");
					couponParams.put("RegisterCode", SessionHelper.getSession("UR_Code"));
					couponParams.put("EventUser", SessionHelper.getSession("UR_Name"));
					couponParams.put("Memo", DicHelper.getDicInfo(fObj.optString("FormName"), SessionHelper.getSession("lang")) + " : Ver." + fObj.optString("RevisionNo")); // 구매양식명
					Map<String, Object> rtnObject = null;
					try {
						rtnObject = RequestHelper.sendUrl(gwUrl, "application/json", "POST", couponParams);
						String responseBody = (String)rtnObject.get("MESSAGE");
						CoviMap response = new CoviMap(responseBody);
						if(!"SUCCESS".equals(response.optString("status"))){
							throw new Exception("Fail to Coupon Process");
						}
					}catch(NullPointerException npE) {
						throw new Exception("Fail to Coupon Process");
					}catch(Exception e) {
						throw new Exception("Fail to Coupon Process");
					}
				}
			} else {
				if(formsExistCnt > 0) {
					returnMsg = DicHelper.getDic("msg_DuplicateFormPaurchase"); //"동일한 양식키가 존재하여 구매할수 없습니다."
				}
				
				throw new Exception(returnMsg);
			}
		}catch(NullPointerException npE) {
			LOGGER.error("storePurchaseForm() : " + npE);
			
			String companyCode = SessionHelper.getSession("DN_Code");
			String templatePath = ApprovalUtil.getTemplatePath(companyCode);
			
			fileUtilSvc.deleteFile(templatePath + fObj.optString("FileName"));
			fileUtilSvc.deleteFile(templatePath + fObj.optString("jsFileName"));
			fileUtilSvc.deleteFile(templatePath + fObj.optString("mobileHtmlFileName"));
			fileUtilSvc.deleteFile(templatePath + fObj.optString("mobilejsFileName"));
			
			throw new Exception(returnMsg);
		}catch(Exception e) {
			LOGGER.error("storePurchaseForm() : " + e);
			
			String companyCode = SessionHelper.getSession("DN_Code");
			String templatePath = ApprovalUtil.getTemplatePath(companyCode);
			
			fileUtilSvc.deleteFile(templatePath + fObj.optString("FileName"));
			fileUtilSvc.deleteFile(templatePath + fObj.optString("jsFileName"));
			fileUtilSvc.deleteFile(templatePath + fObj.optString("mobileHtmlFileName"));
			fileUtilSvc.deleteFile(templatePath + fObj.optString("mobilejsFileName"));
			
			throw new Exception(returnMsg);
		}
		return CoviSelectSet.coviSelectMapJSON(returnData);
	}

	private String copyFile(String fileID) throws Exception {
		CoviMap param = new CoviMap();
		param.put("fileID", fileID);
		CoviMap fileStorageInfos = FileUtil.getFileStorageInfo(fileID); // 기존 파일의 storage정보조회
		CoviMap fileStorageInfo = fileStorageInfos.getJSONObject(fileID);
		String sessionCompanyCode = SessionHelper.getSession("DN_Code");
		String companyCode = fileStorageInfo.optString("CompanyCode").equals("") ? sessionCompanyCode : fileStorageInfo.optString("CompanyCode");
		String storeFilePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + fileStorageInfo.optString("StorageFilePath").replace("{0}", companyCode) + fileStorageInfo.optString("FileFilePath") + fileStorageInfo.optString("SavedName");
		
		if(!new File(storeFilePath).exists()) {
			throw new FileNotFoundException(storeFilePath);
		}
		
		String fileName = FilenameUtils.getBaseName(fileStorageInfo.optString("FileName"));
		String ext = FilenameUtils.getExtension(fileStorageInfo.optString("FileName"));
		String mobileGubun = "_V0."; //계열사에서 구매시 Revision 0으로 고정
		if(fileName.endsWith("_MOBILE")) {
			fileName = fileName.replace("_MOBILE", "");
			mobileGubun = "_V0_MOBILE.";
		}
		fileName = fileName + mobileGubun + ext; 
		
		companyCode = sessionCompanyCode;
		String templatePath = ApprovalUtil.getTemplatePath(companyCode) + fileName;
		if(StringUtils.isNoneBlank(storeFilePath)){
			AwsS3 awsS3 = AwsS3.getInstance();
			if(awsS3.getS3Active(companyCode)){
				if (!storeFilePath.equals(templatePath)) {//동일경로에 있는 파일의 경우 copy하지 않음
					awsS3.copy(storeFilePath, templatePath);
				}
			}else {
				File templateFile = new File(templatePath);
				File orgFile = new File(storeFilePath);
				if (!storeFilePath.equals(templatePath)) {//동일경로에 있는 파일의 경우 copy하지 않음
					if (orgFile.isFile()) {
						FileUtils.copyFile(orgFile, templateFile);
					} else {
						LOGGER.error("Fail on copyFile() : " + storeFilePath);
						throw new Exception("copyFile error.");
					}
				}
			}
		}
		return fileName;
	}
	
}
