package egovframework.covision.coviflow.form.web;

import java.io.FileNotFoundException;
import java.lang.invoke.MethodHandles;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.codec.binary.Base64;
import egovframework.baseframework.util.json.JSONParser;
import egovframework.baseframework.util.json.JSONValue;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.HttpServletRequestHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.covision.coviflow.common.util.ComUtils;
import egovframework.covision.coviflow.common.util.RequestHelper;
import egovframework.covision.coviflow.form.service.ApvProcessSvc;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.govdocs.service.OpenDocSvc;
import egovframework.covision.coviflow.legacy.service.LegacyCommonSvc;
import egovframework.covision.coviflow.user.service.RightApprovalConfigSvc;
import org.springframework.web.bind.annotation.RequestParam;

@Scope("request")
@Controller
public class ApvProcessCon {

	@Autowired
	private ApvProcessSvc apvProcessSvc;
	@Autowired
	private LegacyCommonSvc legacyCmmnSvc;
	@Autowired
	private FormSvc formSvc;
	@Autowired
	private OpenDocSvc openDocSvc;
	@Autowired
	private RightApprovalConfigSvc rightApprovalConfigSvc;
	
	private final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 프로세스 시작 [기안, 승인, 반려, 합의, 재기안 등]
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "draft.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doProcess(MultipartHttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		CoviMap result = new CoviMap();	
		try{
			
			String formStr = new String(Base64.decodeBase64(StringUtil.replaceNull(request.getParameter("formObj"),"").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
			CoviMap formObj = ComUtils.removeFormXSS(formStr);
			
			if(formObj.isNullObject())
				throw new IllegalArgumentException();
			
			List<MultipartFile> mf = request.getFiles("fileData[]");
			
//			보안이슈 사용자 인증 체크 2021-01-18 dgkim
			String formID = formObj.optString("formID");
			String actionMode = formObj.getString("actionMode");
			String adminType = formObj.optString("adminType");
			if(adminType.equals("ADMIN") && !SessionHelper.getSession("isAdmin").equals("Y")) {
				adminType = "";
			}
			String reqFormInstID = formObj.optString("FormInstID");
			
			if(apvProcessSvc.getIsUsePasswordForm(formID) && !adminType.equals("ADMIN")) {
				AES aes = new AES("", "P");
				String approvalPassword = aes.pb_decrypt(formObj.getString("g_password")).trim();
				formObj.put("g_password", approvalPassword);
				if(!actionMode.equals("WITHDRAW") && !actionMode.equals("ABORT") && !actionMode.equals("APPROVECANCEL")  && !actionMode.equals("CHARGE")){
					try {
						String fidoUse = PropertiesUtil.getSecurityProperties().getProperty("fido.login.used");
						String fidoAuthKey =  formObj.getString("g_authKey").trim();
						String userCode = SessionHelper.getSession("UR_Code");
						
						boolean chkUsePasswordYN = false;						
						CoviMap params = new CoviMap();
						params.put("UR_CODE", userCode);
						CoviMap resultList = rightApprovalConfigSvc.selectUserSetting(params);
						if(resultList != null){
							CoviMap map = resultList.getJSONArray("map").getJSONObject(0);
							if(map.optString("UseApprovalPassWord").equals("Y")) {
								chkUsePasswordYN = true;
							}
						}
						if( chkUsePasswordYN ) {
							if(approvalPassword.length() > 0) {
								if( Boolean.FALSE.equals(apvProcessSvc.chkCommentWrite(userCode,approvalPassword)) ) throw new Exception();							
							}else if(fidoUse.equals("Y") && fidoAuthKey.length() > 0 ) {
								params.put("authKey", fidoAuthKey);
								params.put("authType", "approval");
								params.put("logonID", SessionHelper.getSession("UR_Code"));						
								String status = apvProcessSvc.selectFidoStatus(params);
								if( null == status || status.trim().length() == 0 || !status.equals("Succ") ) throw new SecurityException();
							}else {
								throw new SecurityException();
							}
						}
					}catch (SecurityException e) {
						logger.warn("draft.do", e);
						result.put("status", Return.FAIL);
						result.put("message", DicHelper.getDic("msg_apv_fido_chk")); //결재 인증정보를 확인해주세요.				
						return result;
					}
				}
			}
			
			//첨부파일 확장자 체크
			if(!FileUtil.isEnableExtention(mf)){
				result.put("status", Return.FAIL);
				result.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return result;
			}		

			// 다안기안 멀티 첨부 Start
			CoviMap multiFileList = new CoviMap();
			Map<String, MultipartFile> list = request.getFileMap();
			
			Iterator<String> keys = list.keySet().iterator();
			while(keys.hasNext()){
				String key = keys.next();
				if(key.equals("fileData[]")){
					list.remove(key);
				} else {
					multiFileList.put(key, request.getFiles(key));
				}
			}
			// 다안기안 멀티 첨부 End
			
			//결재 유효값 확인
			boolean returnVal = true;//DraftKeyCheck(formObj);		

			if (returnVal) {
				// 본문 저장관련해서 호출 분리함.
				CoviMap processFormDataReturn = null;
				if(multiFileList.size() > 0){
					processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, mf, multiFileList);
				} else {
					processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, mf);
				}
				
				// 승인자 내용변경 저장 시 기안 및 승인 프로세스를 태우지 않음
				if("EDIT".equals(formObj.get("btnFlag"))) {
					apvProcessSvc.doEditProcess(formObj);
					
					result.put("status", Return.SUCCESS);
					result.put("message", DicHelper.getDic("msg_apv_170"));
					return result;
				}
				
				// 기안 및 승인
				try {
					String formInstID = apvProcessSvc.doProcess(formObj, processFormDataReturn);
					//문서발번 처리
					if(!formInstID.equals(""))
						apvProcessSvc.updateFormInstDocNumber(formInstID);
				}catch(NullPointerException npE) {
					// System Exception 이 발생한 경우 jwf_forminstance 삭제처리. ( Tx 를 묶을 경우 연동처리시 FormCmmFunctionCon.java 에서 bodyContext 조회가 불가하여 동기화할 수 없는 구조임 )
					if(processFormDataReturn != null) {
						CoviMap prevFormObj = processFormDataReturn.getJSONObject("formObj");
						// 신규기안일 경우만.
						String mode = formObj.optString("mode").toUpperCase();
						if("DRAFT".equals(mode) && StringUtil.isEmpty(reqFormInstID)) {
							apvProcessSvc.deleteFormInstacne(prevFormObj);
						}
					}
					throw npE;
				}catch(Exception e) {
					// System Exception 이 발생한 경우 jwf_forminstance 삭제처리. ( Tx 를 묶을 경우 연동처리시 FormCmmFunctionCon.java 에서 bodyContext 조회가 불가하여 동기화할 수 없는 구조임 )
					if(processFormDataReturn != null) {
						CoviMap prevFormObj = processFormDataReturn.getJSONObject("formObj");
						// 신규기안일 경우만.
						String mode = formObj.optString("mode").toUpperCase();
						if("DRAFT".equals(mode) && StringUtil.isEmpty(reqFormInstID)) {
							apvProcessSvc.deleteFormInstacne(prevFormObj);
						}
					}
					throw e;
				}
				
				
				// 알림 처리
				try {
					String url = PropertiesUtil.getGlobalProperties().getProperty("approval.legacy.path") + "/legacy/setTimeLineData.do";
					HttpsUtil httpsUtil = new HttpsUtil();
					httpsUtil.httpsClientWithRequest(url, "POST", formObj, "UTF-8", null);
				} catch(NullPointerException npE) {
					logger.error(npE.getLocalizedMessage(), npE);
				} catch(Exception e) {
					logger.error(e.getLocalizedMessage(), e);
				}
				
				// 
				try {
					String mode = "";
					if (!formObj.isEmpty() && formObj.has("mode"))
						mode = formObj.optString("mode").toUpperCase();
					if("ADMIN".equals(mode)) {
						// 관리자에서 문서를 편집한경우. (완료문서를)
						if(formObj.has("SchemaID")) {
							CoviMap paramsSchema = new CoviMap();
							String strSchemaID = formObj.getString("SchemaID");
							paramsSchema.put("schemaID", strSchemaID);
							CoviMap formSchema = ((CoviList)(formSvc.selectFormSchema(paramsSchema)).get("list")).getJSONObject(0);
							
							if(!formSchema.get("SchemaContext").equals("")) {
								CoviMap schemaContext = formSchema.getJSONObject("SchemaContext");
								if(schemaContext.has("scPubOpenDoc") && "Y".equalsIgnoreCase(schemaContext.getJSONObject("scPubOpenDoc").getString("isUse"))) {
									paramsSchema.clear();
									paramsSchema.put("formInstID", formObj.getString("FormInstID"));
									openDocSvc.updateOpenDocInfo(paramsSchema);
								}
							}
							
						}
					}
				}catch(NullPointerException npE) {
					logger.error(npE.getLocalizedMessage(), npE);
				}catch(Exception e) {
					logger.error(e.getLocalizedMessage(), e);
				}
				result.put("status", Return.SUCCESS);
				result.put("message", DicHelper.getDic("msg_apv_170"));
			}else {
				result.put("status", Return.FAIL);
				result.put("message", DicHelper.getDic("msg_apv_030"));
			}
			
		}catch(FileNotFoundException e) {
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}catch(NullPointerException npE){
			Throwable c = npE;
			while(c.getCause() != null){
			    c = c.getCause();
			}
			logger.error(npE.getLocalizedMessage(), npE);
			result.put("status", Return.FAIL);
			result.put("message", c.getMessage() == null ? DicHelper.getDic("msg_apv_030") : c.getMessage());
		}catch(Exception e){
			Throwable c = e;
			while(c.getCause() != null){
			    c = c.getCause();
			}
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", c.getMessage() == null ? DicHelper.getDic("msg_apv_030") : c.getMessage());
		}
		return result;
	}
	
	/**
	 * 기안 및 재기안시 개인결재선 저장
	 * @param request
	 * @param response
	 * @throws Exception
	 */
	@RequestMapping(value = "apvline/setPrivateDomainDataForDraft.do", method=RequestMethod.POST)
	public @ResponseBody void getProjectList(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		String dataInfo = null;
		CoviMap apvLineInfo = new CoviMap();
		
		/*
		 * {
		 * 		"ApvLineInfo" : {
		 * 			"mode" : "",
		 * 			"approvalLine" : "",
		 * 			"actionMode" : "",
		 *  		"FormSubject" : "",
		 *  		"FormName" : "",
		 *  		"usid" : "",
		 *  		"usdn" : "",
		 *  		"FormPrefix" : ""
		 * 		}
		 * }
		 */
		
		try{
			if(request.getParameter("ApvLineInfo") != null){
				apvLineInfo = CoviMap.fromObject(request.getParameter("ApvLineInfo"));
				dataInfo = request.getParameter("ApvLineInfo");
			}else{
				String bodyInfo = HttpServletRequestHelper.getBody(request);
				String escaped = StringEscapeUtils.unescapeHtml(bodyInfo);
				CoviMap jsonObj = CoviMap.fromObject(escaped);
				dataInfo = jsonObj.optString("ApvLineInfo"); 
				apvLineInfo = CoviMap.fromObject(dataInfo);
			}
			
			if(!apvLineInfo.isEmpty() && !apvLineInfo.isNullObject()){
				apvProcessSvc.setPrivateDomainDataForDraft(apvLineInfo);
			}
		}catch(NullPointerException npE){
			legacyCmmnSvc.insertLegacy("MESSAGE", "error", dataInfo, npE);
		}catch(Exception e){
			legacyCmmnSvc.insertLegacy("MESSAGE", "error", dataInfo, e);
		}
	}
	
	/**
	 * 임시저장 메소드
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "tempSave.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doTempSave(MultipartHttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		CoviMap result = new CoviMap();	
		try{
			String formStr = new String(Base64.decodeBase64(StringUtil.replaceNull(request.getParameter("formObj"),"").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
			CoviMap formObj = ComUtils.removeFormXSS(formStr);
			
			List<MultipartFile> mf = request.getFiles("fileData[]");
		
			// 다안기안 멀티 첨부 Start
			CoviMap multiFileList = new CoviMap();
			Map<String, MultipartFile> list = request.getFileMap();
			
			Iterator<String> keys = list.keySet().iterator();
			while(keys.hasNext()){
				String key = keys.next();
				if(key.equals("fileData[]")){
					list.remove(key);
				} else {
					multiFileList.put(key, request.getFiles(key));
				}
			}
			// 다안기안 멀티 첨부 End
			
			//첨부파일 확장자 체크
			if(!FileUtil.isEnableExtention(mf)){
				result.put("status", Return.FAIL);
				result.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return result;
			}
			
			if(multiFileList.size() > 0){
				apvProcessSvc.doCreateInstance("TEMPSAVE", formObj, mf, multiFileList);
			} else {
				apvProcessSvc.doCreateInstance("TEMPSAVE", formObj, mf);				
			}
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_apv_170"));
		}catch(NullPointerException npE){
			logger.error(npE.getLocalizedMessage(), npE);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		return result;
	}
	
	
	/**
	 * 보류 메소드
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "reserve.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doReserve(MultipartHttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		CoviMap result = new CoviMap();
		try{
			String formStr = new String(Base64.decodeBase64(StringUtil.replaceNull(request.getParameter("formObj"),"").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
			CoviMap formObj = ComUtils.removeFormXSS(formStr);

			String formID = formObj.getString("formID");
			String actionMode = formObj.getString("actionMode");
			if(apvProcessSvc.getIsUsePasswordForm(formID)) {
				try {
					AES aes = new AES("", "P");
					String fidoUse = PropertiesUtil.getSecurityProperties().getProperty("fido.login.used");
					String fidoAuthKey = formObj.getString("g_authKey").trim();
					String approvalPassword = aes.pb_decrypt(formObj.getString("g_password")).trim();
					String userCode = SessionHelper.getSession("UR_Code");
					formObj.put("g_password", approvalPassword);
					
					boolean chkUsePasswordYN = false;						
					CoviMap params = new CoviMap();
					params.put("UR_CODE", userCode);
					CoviMap resultList = rightApprovalConfigSvc.selectUserSetting(params);
					if(resultList != null){
						CoviMap map = resultList.getJSONArray("map").getJSONObject(0);
						if(map.optString("UseApprovalPassWord").equals("Y")) {
							chkUsePasswordYN = true;
						}
					}
					if (chkUsePasswordYN) {
						if (approvalPassword.length() > 0) {
							if (Boolean.FALSE.equals(apvProcessSvc.chkCommentWrite(userCode, approvalPassword)))
								throw new SecurityException();
						} else if (fidoUse.equals("Y") && fidoAuthKey.length() > 0) {
							params.put("authKey", fidoAuthKey);
							params.put("authType", "approval");
							params.put("logonID", SessionHelper.getSession("UR_Code"));
							String status = apvProcessSvc.selectFidoStatus(params);
							if (null == status || status.trim().length() == 0 || !status.equals("Succ"))
								throw new SecurityException();
						} else {
							throw new SecurityException();
						}

					}
				} catch (NullPointerException npE) {
					logger.warn(npE.getLocalizedMessage(), npE);
					result.put("status", Return.FAIL);
					result.put("message", DicHelper.getDic("msg_apv_fido_chk")); // 결재 인증정보를 확인해주세요.
					return result;
				} catch (Exception e) {
					logger.warn(e.getLocalizedMessage(), e);
					result.put("status", Return.FAIL);
					result.put("message", DicHelper.getDic("msg_apv_fido_chk")); // 결재 인증정보를 확인해주세요.
					return result;
				}
			}
			
			//결재 유효값 확인
			boolean returnVal = draftKeyCheck(formObj);		

			if (returnVal) {
				// PC 전자결재 이외에, E-Accounting/모바일 전자결재는 보류 시 편집내용 저장하지 않음. , 편집모드일때만 내용저장
				if(formObj.containsKey("mode") && formObj.optString("editMode").equals("Y")) {
					List<MultipartFile> mf = new ArrayList<>();
					mf = request.getFiles("fileData[]");
					
					//첨부파일 확장자 체크
					if(!FileUtil.isEnableExtention(mf)){
						result.put("status", Return.FAIL);
						result.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
						return result;
					}
					
					// 본문 저장관련해서 호출 분리함.
					apvProcessSvc.doCreateInstance("PROCESS", formObj, mf);	
				}
				apvProcessSvc.doReserve(formObj);
				result.put("status", Return.SUCCESS);
				result.put("message", DicHelper.getDic("msg_apv_170"));			
			}else {				
				result.put("status", Return.FAIL);
				result.put("message", DicHelper.getDic("msg_apv_030"));
			}
		}catch(NullPointerException npE){
			logger.error(npE.getLocalizedMessage(), npE);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		return result;
	}
	
	/**
	 * 전달 메소드
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "forward.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doForward(MultipartHttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		CoviMap result = new CoviMap();
		try{
			String formStr = new String(Base64.decodeBase64(StringUtil.replaceNull(request.getParameter("formObj"),"").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
			CoviMap formObj = ComUtils.removeFormXSS(formStr);
			
			if(formObj.containsKey("mode")) {
				List<MultipartFile> mf = new ArrayList<>();
				mf = request.getFiles("fileData[]");
				
				//첨부파일 확장자 체크
				if(!FileUtil.isEnableExtention(mf)){
					result.put("status", Return.FAIL);
					result.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
					return result;
				}
				
				// 본문 저장관련해서 호출 분리함.
				apvProcessSvc.doCreateInstance("PROCESS", formObj, mf);	
			}
			
			apvProcessSvc.doForward(formObj);
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_apv_170"));
		}catch(NullPointerException npE){
			logger.error(npE.getLocalizedMessage(), npE);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		return result;
	}

	
	/**
	 * 일괄결재를 위한 결재선 조회 (담당업무함)
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "getBatchApvLine.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviList getBatchApvLine(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		CoviList resultArr = new CoviList();	
		
		String processIDArr = StringUtil.replaceNull(request.getParameter("processIDArr"));
		String[] processIDs = null;
		
		if(processIDArr.indexOf(',')>=0){
			processIDs = processIDArr.split(",");
		}else{
			processIDs = new String[]{ processIDArr };
		}
		
		CoviMap params = new CoviMap();
		params.put("processIDs", processIDs);
		resultArr = apvProcessSvc.getBatchApvLine(params).getJSONArray("list");
		
		return resultArr;
	}
	
		
	@RequestMapping(value = "CommentWrite.do", method = RequestMethod.GET)
	public @ResponseBody ModelAndView getApprovalDetailList(HttpServletRequest request, Locale locale, Model model)
	{
		String returnURL = "forms/CommentWrite";
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("useFIDO", PropertiesUtil.getSecurityProperties().getProperty("fido.login.used"));
		mav.addObject("usePWD", request.getParameter("usePWD"));
		
		return mav;
	}
	
	
	@RequestMapping(value = "chkCommentWrite.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody Boolean chkCommentWrite(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		Boolean result = false;
		String userCode = request.getParameter("ur_code");
		String password = request.getParameter("password");

		AES aes = new AES("", "P");
		password = aes.pb_decrypt(password);
		result = apvProcessSvc.chkCommentWrite(userCode,password);
		
		return result;
	}
	
	@RequestMapping(value = "chkUsePasswordYN.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody Boolean chkUsePasswordYN(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		Boolean result = false;
		String userCode = request.getParameter("ur_code");
		
		CoviMap params = new CoviMap();
		params.put("UR_CODE", userCode);
		
		CoviMap resultList = rightApprovalConfigSvc.selectUserSetting(params);
		if(resultList != null){
			CoviMap map = resultList.getJSONArray("map").getJSONObject(0);
			if(map.optString("UseApprovalPassWord").equals("Y")) {
				result = true;
			}
		}
		return result;
	}	
	/**
	 * 진행 데이터베이스에서 완료된 건 삭제
	 * @param request
	 * @param response
	 * @param locale
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "deleteArchiveInProcess.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap deleteArchiveInProcess(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap result = new CoviMap();
		
		try{
			String finishedMonth = RedisDataUtil.getBaseConfig("ProcessDelete_MonthAgo");
			String finishedWeek = RedisDataUtil.getBaseConfig("ProcessDelete_WeekAgo");
			String limit = RedisDataUtil.getBaseConfig("ProcessDelete_Limit");
			int repeatCount = Integer.parseInt(RedisDataUtil.getBaseConfig("ProcessDelete_RepeatCount"));
			
			CoviMap params = new CoviMap();
			params.put("Finished_Month", finishedMonth);
			params.put("Finished_Week", finishedWeek);
			params.put("Limit", limit);
			
			for(int i=0; i<repeatCount; i++){
				apvProcessSvc.deleteArchiveInProcess(params);
			}
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_com_processSuccess"));
			
		}catch(NullPointerException npE){
			logger.error(npE.getLocalizedMessage(), npE);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		
		return result;
	}
	
	/**
	 * 부재중 자동승인 스케쥴러
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "doAutoApprovalProcess.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doAutoApprovalProcess(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap result = new CoviMap();
		
		try{
			String sDNCode = "";
			
			try {
				sDNCode = StringUtil.replaceNull(request.getParameter("DN_Code"),"ORGROOT");
			}catch(NullPointerException npE) {
				logger.error("ApvProcessCon doAutoApprovalProcess request DN_Code is NULL", npE);
			}
			catch(Exception ex) {
				logger.error("ApvProcessCon doAutoApprovalProcess request DN_Code is NULL", ex);
			}
			CoviMap cmInput =new CoviMap();
			cmInput.put("CompanyCode", sDNCode);
			
			// 대상 가져오기(TaskID)
			CoviList list = apvProcessSvc.selectAutoDeputyList(cmInput);
			
			// 자동승인 제외 대상 목록 조회
			CoviList ExceptAutoApprovalList = RedisDataUtil.getBaseCode("AUTOAPPROVAL");
			
			List<String> autoApprovalBaseCode = new ArrayList<String>();
			for(int j=0; j<ExceptAutoApprovalList.size(); j++) {
				autoApprovalBaseCode.add((String)(((CoviMap) ExceptAutoApprovalList.get(j)).get("Code")));
			}
			
			String baseUrl = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
			
			for(int i=0; i<list.size(); i++) {
				
				String taskId = list.getJSONObject(i).getString("TaskID");
				String formInstID = list.getJSONObject(i).getString("FormInstID");
				String filePath = list.getJSONObject(i).getString("FilePath");
				String autoApproval = list.getJSONObject(i).getString("FormPrefix");
				
				if(autoApprovalBaseCode.contains(autoApproval)) continue; 
				
				CoviList variables = new CoviList();
				
				CoviMap variable = new CoviMap();
				variable.put("name", "g_action_" + taskId);
				
				/*
				 * if(subKind.equals("T000")){ variable.put("value", "APPROVAL"); }else{
				 * variable.put("value", "AGREE"); }
				 */
				
				variable.put("value", "APPROVAL");
				variable.put("scope", "global");
				variables.add(variable);
				
				variable = new CoviMap();
				variable.put("name", "g_actioncomment_" + taskId);
				variable.put("value", "");
				variable.put("scope", "global");
				variables.add(variable);
				
				variable = new CoviMap();
				variable.put("name", "g_actioncomment_attach_" + taskId);
				variable.put("value", new ArrayList<CoviMap>());
				variable.put("scope", "global");
				variables.add(variable);
				
				// 부재중 결재 시, 서명이미지
				variable = new CoviMap();
				variable.put("name", "g_signimage_" + taskId);
				variable.put("value", !filePath.equals("") ? filePath.split("/")[filePath.split("/").length-1] : "");
				variable.put("scope", "global");
				variables.add(variable);
				
				variable = new CoviMap();
				variable.put("name", "g_isMobile_" + taskId);
				variable.put("value", "N");
				variable.put("scope", "global");
				variables.add(variable);
				
				variable = new CoviMap();
				variable.put("name", "g_isBatch_" + taskId);
				variable.put("value", "N");
				variable.put("scope", "global");
				variables.add(variable);
							
				CoviMap param = new CoviMap();
				param.put("action", "complete");
				param.put("variables", variables);
				
				String url = baseUrl + "/service/runtime/tasks/" + taskId;
				
				try {
					// 활성화 된 task id가 아니면 오류 발생할 수 있어서 try-catch 구문 추가함
					RequestHelper.sendPOST(url, param);
					
					//문서발번 처리
					apvProcessSvc.updateFormInstDocNumber(formInstID);
					
					// Workitem - BusinessData4에 "AUTO"로 표시함
					apvProcessSvc.updateMarkAutoApprove(taskId, "AUTO");
				} catch(NullPointerException npE) {
					logger.error("ApvProcessCon", npE);
					
					// 오류난 문서는 마킹함.
					apvProcessSvc.updateMarkAutoApprove(taskId, "FAIL");
				} catch(Exception e) {
					logger.error("ApvProcessCon", e);
					
					// 오류난 문서는 마킹함.
					apvProcessSvc.updateMarkAutoApprove(taskId, "FAIL");
				}
			}
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_com_processSuccess"));
			
		}catch(NullPointerException npE){
			logger.error(npE.getLocalizedMessage(), npE);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		
		return result;
	}
	
	/**
	 * 자동접수 스케쥴러(실행 조건 사이트 별 수정 필요)
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "doAutoRecProcess.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doAutoRecProcess(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap result = new CoviMap();
		
		try{
			// 대상 가져오기(TaskID)
			CoviList list = apvProcessSvc.selectAutoRecList();
			
			String baseUrl = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
			for(int i=0; i<list.size(); i++) {
				String taskId = list.getJSONObject(i).getString("TaskID");
				String formInstID = list.getJSONObject(i).getString("FormInstID");
				
				// 결재선 접수자 구성(팀장 - ManagerCode)
				JSONParser parser = new JSONParser();
				
				CoviMap apvLineObj = new CoviMap();
				Object apvLine = list.getJSONObject(i).get("DomainDataContext");
				if(apvLine instanceof LinkedHashMap){
					apvLineObj = (CoviMap)JSONValue.parse(JSONValue.toJSONString(apvLine));
				} else {
					apvLineObj = (CoviMap)parser.parse(apvLine.toString());
				}
				
				CoviList variables = new CoviList();
				
				CoviMap variable = new CoviMap();
				variable.put("name", "g_action_" + taskId);
				variable.put("value", "APPROVAL");
				variable.put("scope", "global");
				variables.add(variable);
				
				variable = new CoviMap();
				variable.put("name", "g_actioncomment_" + taskId);
				variable.put("value", "");
				variable.put("scope", "global");
				variables.add(variable);
				
				variable = new CoviMap();
				variable.put("name", "g_actioncomment_attach_" + taskId);
				variable.put("value", new ArrayList<CoviMap>());
				variable.put("scope", "global");
				variables.add(variable);
				
				// 부재중 결재 시, 서명이미지
				variable = new CoviMap();
				variable.put("name", "g_signimage_" + taskId);
				variable.put("value", "");
				variable.put("scope", "global");
				variables.add(variable);
				
				variable = new CoviMap();
				variable.put("name", "g_isMobile_" + taskId);
				variable.put("value", "N");
				variable.put("scope", "global");
				variables.add(variable);
				
				variable = new CoviMap();
				variable.put("name", "g_isBatch_" + taskId);
				variable.put("value", "Y");
				variable.put("scope", "global");
				variables.add(variable);
				
				// 팀장 접수 결재선으로 변경
				variable = new CoviMap();
				variable.put("name", "g_appvLine");
				variable.put("value", apvProcessSvc.getRecApvline(apvLineObj));
				variable.put("scope", "global");
				variables.add(variable);
				
				CoviMap param = new CoviMap();
				param.put("action", "complete");
				param.put("variables", variables);
				
				String url = baseUrl + "/service/runtime/tasks/" + taskId;
				
				try {
					// 활성화 된 task id가 아니면 오류 발생할 수 있어서 try-catch 구문 추가함
					RequestHelper.sendPOST(url, param);
					
					//문서발번 처리
					apvProcessSvc.updateFormInstDocNumber(formInstID);
					
					// Workitem - BusinessData4에 "AUTO"로 표시함
					apvProcessSvc.updateMarkAutoApprove(taskId, "AUTO-REC");
				} catch(NullPointerException npE) {
					logger.error(npE.getLocalizedMessage(), npE);
					
					// 오류난 문서는 마킹함.
					apvProcessSvc.updateMarkAutoApprove(taskId, "FAIL");
				} catch(Exception e) {
					logger.error(e.getLocalizedMessage(), e);
					
					// 오류난 문서는 마킹함.
					apvProcessSvc.updateMarkAutoApprove(taskId, "FAIL");
				}
			}
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_com_processSuccess"));
			
		}catch(NullPointerException npE){
			logger.error(npE.getLocalizedMessage(), npE);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		
		return result;
	}
	
	@RequestMapping(value = "commentFileUpload.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap docommentFileUpload(MultipartHttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception {
		CoviMap result = new CoviMap();	
		try{
			List<MultipartFile> commentMultiFiles = new ArrayList<>();
			commentMultiFiles = request.getFiles("fileData_comment[]");
			
			//첨부파일 확장자 체크
			if(!FileUtil.isEnableExtention(commentMultiFiles)){
				result.put("status", Return.FAIL);
				result.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return result;
			}
			
			String savedCommentMultiFiles = apvProcessSvc.doCommentAttachFileSave(commentMultiFiles, null);
			result.put("result", savedCommentMultiFiles);
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_apv_170"));
			
		}catch(FileNotFoundException e) {
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}catch(NullPointerException npE){
			logger.error(npE.getLocalizedMessage(), npE);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		return result;
	}
	
	/**
	 * 예약기안 처리 (스케쥴러)
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "doReservedDraftProcess.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap doReservedDraftProcess(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap result = new CoviMap();
		
		try{
			// 대상 가져오기(TaskID)
			CoviList list = apvProcessSvc.selectReservedDraftList();
			String baseUrl = PropertiesUtil.getGlobalProperties().getProperty("activiti.legacy.path");
			for(int i=0; i<list.size(); i++) {
				String taskId = list.getJSONObject(i).getString("TaskID");
							
				CoviMap param = new CoviMap();
				param.put("action", "complete");
				
				String url = baseUrl + "/service/runtime/tasks/" + taskId;
				try {
					// 활성화 된 task id가 아니면 오류 발생할 수 있어서 try-catch 구문 추가함
					RequestHelper.sendPOST(url, param);
					
					// Workitem - BusinessData4에 "AUTO"로 표시함
					apvProcessSvc.updateMarkAutoApprove(taskId, "AUTO");
				} catch(NullPointerException npE) {
					logger.error("ApvProcessCon Error.", npE);
					
					// 오류난 문서는 마킹함.
					apvProcessSvc.updateMarkAutoApprove(taskId, "FAIL");
				} catch(Exception e) {
					logger.error("ApvProcessCon Error.", e);
					
					// 오류난 문서는 마킹함.
					apvProcessSvc.updateMarkAutoApprove(taskId, "FAIL");
				}
			}
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_com_processSuccess"));
			
		}catch(NullPointerException npE){
			logger.error(npE.getLocalizedMessage(), npE);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			logger.error(e.getLocalizedMessage(), e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		
		return result;
	}
	
	
	private boolean draftKeyCheck(CoviMap formObj) throws Exception {
		String pTaskID = "";
		String pFrominstID = "";
		boolean returnVal = true;
		
		if (formObj.has("formDraftkey") && formObj.has("taskID") && formObj.has("FormInstID")) {		
			AES aes = new AES("", "N");
			String formDraftkey = aes.decrypt(formObj.getString("formDraftkey"));
			String objTaskID = formObj.getString("taskID");
			String objFormInstID = formObj.getString("FormInstID");

			//기안 및 재사용시 값이 없을경우 비교않함
			if(!formDraftkey.isEmpty() && !objTaskID.isEmpty() && !objFormInstID.isEmpty()) {
				CoviMap params = new CoviMap();
				StringTokenizer stDraftkey = new StringTokenizer(formDraftkey,"@");
				while(stDraftkey.hasMoreTokens()){
					pFrominstID = stDraftkey.nextToken();
					params.put("draftFrominstID", pFrominstID);
					params.put("draftWorkitemID", stDraftkey.nextToken());
					params.put("draftProcessID", stDraftkey.nextToken());
					pTaskID = stDraftkey.nextToken();
				}
				
				if( pTaskID.equals(objTaskID) && pFrominstID.equals(objFormInstID) ){
					String getTaskID = apvProcessSvc.getDraftKey(params);
					if (!getTaskID.equals(objTaskID)) returnVal = false;
				}else {
					returnVal = false;
				}
			}
		}
		return returnVal;
	}
	
	/**
	 * @param : @param request
	 * @param : @param response
	 * @param : @param locale
	 * @param : @param model
	 * @param : @return
	 * @param : @throws Exception
	 * @Method : doConsultation
	 * @return : JSONObject
	 */
	@RequestMapping(value = "consultationRequst.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap doConsultationRequest(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> paramMap) throws Exception {
		CoviMap result = new CoviMap();
		try{
			String formStr = new String(Base64.decodeBase64(StringUtil.replaceNull(request.getParameter("formObj"), "").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
			CoviMap formObj = ComUtils.removeFormXSS(formStr);
			
			apvProcessSvc.doConsultationRequest(formObj);
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_apv_170"));
		} catch(NullPointerException npE){
			logger.error("ApvProcessCon", npE);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			logger.error("ApvProcessCon", e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		return result;
	}

	@RequestMapping(value = "consultationRequstCancel.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap consultationRequstCancel(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> paramMap) throws Exception {
		CoviMap result = new CoviMap();
		try{
			String formStr = new String(Base64.decodeBase64(StringUtil.replaceNull(request.getParameter("formObj"), "").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
			CoviMap formObj = ComUtils.removeFormXSS(formStr);
			
			apvProcessSvc.consultationRequstCancel(formObj);
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_apv_170"));
		} catch(NullPointerException npE){
			logger.error("ApvProcessCon", npE);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			logger.error("ApvProcessCon", e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		return result;
	}
	
	@RequestMapping(value = "consultation.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap doConsultation(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> paramMap) throws Exception {
		CoviMap result = new CoviMap();
		try{
			String formStr = new String(Base64.decodeBase64(StringUtil.replaceNull(request.getParameter("formObj"), "").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
			CoviMap formObj = ComUtils.removeFormXSS(formStr);
			
			apvProcessSvc.doConsultation(formObj);
			
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_apv_170"));
		} catch(NullPointerException npE){
			logger.error("ApvProcessCon", npE);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			logger.error("ApvProcessCon", e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		return result;
	}
	
	@RequestMapping(value = "chkBeforeEdited.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap chkBeforeEdited(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> paramMap) throws Exception {
		CoviMap result = new CoviMap();
		try{
			String FormInstID = StringUtil.replaceNull(request.getParameter("FormInstID"), "");
			CoviMap params = new CoviMap();
			params.put("FormInstID", FormInstID);
			
			CoviMap modDateReturn = apvProcessSvc.getLastModifiedDate(params);
			
			result.put("data", modDateReturn);
			result.put("status", Return.SUCCESS);
			result.put("message", DicHelper.getDic("msg_apv_170"));
		} catch(NullPointerException npE){
			logger.error("ApvProcessCon", npE);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?npE.toString():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			logger.error("ApvProcessCon", e);
			result.put("status", Return.FAIL);
			result.put("message", "Y".equals(isDevMode)?e.toString():DicHelper.getDic("msg_apv_030"));
		}
		return result;
	}
}