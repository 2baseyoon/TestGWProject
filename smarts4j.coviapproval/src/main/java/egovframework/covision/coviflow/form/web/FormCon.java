package egovframework.covision.coviflow.form.web;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.invoke.MethodHandles;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.StringUtils;
import egovframework.baseframework.util.json.JSONParser;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.coviframework.util.s3.AwsS3Data;
import egovframework.covision.coviflow.approvalline.service.AutoApprovalLineService;
import egovframework.covision.coviflow.common.util.ApprovalUtil;
import egovframework.covision.coviflow.common.util.ComUtils;
import egovframework.covision.coviflow.form.dto.FormRequest;
import egovframework.covision.coviflow.form.dto.UserInfo;
import egovframework.covision.coviflow.form.service.FormAuthSvc;
import egovframework.covision.coviflow.form.service.FormFileCacheSvc;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.form.service.impl.ApvProcessSvcImpl;
import egovframework.covision.coviflow.legacy.service.ForLegacySvc;
import egovframework.coviframework.service.FileUtilService;

/**
 * @Class Name : FormCon.java
 * @Description : 양식 공통 컨테이너 Controller
 * @ 2016.11.10 최초생성
 *
 * @author 코비젼 연구소
 * Copyright (C) by Covision All right reserved.
 */
@Controller
@Scope("request")
public class FormCon {
	
	@Autowired
	private AuthHelper authHelper;

	private final Logger LOGGER = LogManager.getLogger(FormCon.class);
	
	@Autowired
	private FormFileCacheSvc formFileCacheSvc;
	
	@Autowired
	public FormSvc formSvc;
	
	@Autowired
	private FormAuthSvc formAuthSvc;
	
	@Autowired
	private ForLegacySvc forLegacySvc;
	
	@Autowired
	public AutoApprovalLineService autoApprovalLineService;
	
	@Autowired
	private FileUtilService fileUtilSvc;
	
	final String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
	final String appName = PropertiesUtil.getGlobalProperties().getProperty("AppName");
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");	
	public final String lang = SessionHelper.getSession("lang"); 
	//String filePath = "";// Mutable variable 미사용
	
	@RequestMapping(value = "/approval_Form.do", method = {RequestMethod.GET, RequestMethod.POST}) 
	public ModelAndView goCommonFormPage(HttpServletRequest request, Locale locale, Model model) throws Exception {
		ModelAndView mav = new ModelAndView();

		//변수 초기화
		boolean successYN = true;
		String errorMsg = "";
		String strLangIndex = "";
		
        String strMenuTempl = "";
		String strTopTempl = "";
		String strApvLineTempl = "";
		String strAddInApvLineTempl = ""; // 문서 안 결재선
		String strCommonFieldsTempl = "";
		String strHeaderTempl = "";
		String strBodyTempl = "";
		String strBodyTemplJS = "";
		String strBodyTemplGov = "";
		String strFooterTempl = "";
		String strEditorSrc = "";
		String strAttachTempl = "";
		String isApvLineChanged = "N";
		String strFormFavoriteYN = "";
    	String strUseMultiEditYN = "N";
    	String strUseHWPEditYN = "N";
    	String strUseScDistributionYN = "N";
    	String strUseWebHWPEditYN = "N";
    	String strUseWebEditorEditYN = "N";
		String formJsonForDev = "";
		String formDraftkey = "";
		String strExpAppID = ""; //e-Accounting 비용신청 key 값
		String strUseWebHWPMultiEditYN = "N"; // 문서유통 + 다안기안
		String strUseScWebHWPEditYN = "N"; // 문서유통 + 한글웹기안기
		String strUseScWebEditorEditYN = "N"; // 문서유통 + 웹에디터
		String strUseScWebEditorMultiEditYN = "N"; // 다안기안 + 문서유통 + 웹에디터
		
		CoviMap formJson = new CoviMap();
		
		try{
			// 초기 변수값 설정
			FormRequest formRequest = initFormRequest(request);
			UserInfo userInfo = initUserInfo();
			//다국어 언어설정
            strLangIndex = getLngIdx();
			
			String returnURL = "forms/Form";
			if(formRequest.getBstored().equalsIgnoreCase("true")){
				returnURL = "forms_M/Form_MigrationMHT";
			}
			
			String useTotalApproval = RedisDataUtil.getBaseConfig("useTotalApproval"); // 통합결재 사용여부 Default "N"
			String useOtherAPV = RedisDataUtil.getBaseConfig("eAccOtherApv"); // Y: 일반 전자결재 양식, N: 이어카운팅 전표조회 팝업 Default "Y"
			
			if(useTotalApproval.equalsIgnoreCase("Y") && useOtherAPV.equalsIgnoreCase("N") && !formRequest.getExpAppID().isEmpty()) {
				strExpAppID = formRequest.getExpAppID();
				returnURL = "redirect/goAccount";
			}
			mav.setViewName(returnURL);			

			/* Validation
			 *  - 양식 오픈시 서명 이미지 체크
			 *  - Workitem 정보로 양식 오픈 여부 체크
			 *  - 문서 권한 체크
			*/ 
			// 양식 오픈시 서명이미지 체크
			String signFileID = formSvc.selectUsingSignImageId(userInfo.getUserID());
        	if(StringUtils.isNotBlank(signFileID) && RedisDataUtil.getBaseConfig("IS_USE_CHECK_SIGNIMAGE").equals("Y")){
        		throw new NoSuchElementException("개인환경설정에서 서명을 등록하세요.");
        	} else {
        		userInfo.setUserSignFileID(signFileID);
        	}
        	        	
            /* Workitem 정보로 양식 오픈 여부체크 */
        	CoviMap procData = getProcessData(formRequest);				// Process Data Setting
        	CoviMap processObj = procData.getJSONObject("processObj");
        	
            if(procData.has("strSubkind")) {
            	formRequest.setSubkind(procData.getString("strSubkind"));
            }
            if(procData.has("isArchived")){
        		formRequest.setArchived(procData.getString("isArchived"));
        	}            
            if(procData.has("bStored")){
           		formRequest.setBstored(procData.getString("bStored"));
           	}
            
            if(processObj != null && !processObj.isEmpty()){
            	if(processObj.has("ParentProcessID")) {
            		formRequest.setParentProcessID(processObj.getString("ParentProcessID"));
            	}
            	else if(processObj.has("FormInstID")) {
            		formRequest.setFormInstanceID(processObj.getString("FormInstID"));	
            	}
        	}
            
            
            // 오픈 여부 체크 시작
            if(processObj != null && !processObj.isEmpty()){
            	//ProcessDescription 데이터에서 다시 세팅
            	CoviMap processDescription = processObj.getJSONObject("ProcessDescription");
            	
                if(formRequest.getFormId().equals("") ){
                	formRequest.setFormId(processDescription.getString("FormID"));
                }
            	if(formRequest.getFormInstanceID().equals("") ){
                	formRequest.setFormInstanceID(processDescription.getString("FormInstID"));
                }
                if(formRequest.getIsSecdoc().equals("")){
                	formRequest.setIsSecdoc(processDescription.getString("IsSecureDoc"));
                }
                
                if(processObj.has("ProcessID") && !formRequest.getWorkitemID().equals("") && !formRequest.getFormInstanceID().equals("")){
                	formDraftkey = formRequest.getFormInstanceID() + "@" + formRequest.getWorkitemID() + "@" + processObj.getString("ProcessID")  + "@" + processObj.getString("TaskID");
                }
            	
            	if(!formRequest.getProcessID().equals(processObj.getString("ProcessID"))){
            		successYN = false;
            	}else{
            		String processState = processObj.optString("ProcessState");
            		String workitemState = processObj.optString("State");
            		if((processState.equals("") && workitemState.equals("")) || workitemState.equals("546") || processState.equals("546") 
                				|| ( workitemState.equals("688") || processState.equals("688") )){
                    	successYN = false;
            		}
            	}
            	if (!successYN) 
            		throw new NoSuchElementException(DicHelper.getDic("msg_apv_082")); //존재하지 않는 결재문서입니다.
            }
            
            // 문서 권한 체크
            String strReadMode = formRequest.getReadMode();
            if(!strReadMode.equalsIgnoreCase("DRAFT") && !strReadMode.equalsIgnoreCase("TEMPSAVE") 
            		&& !formRequest.getIsReuse().equals("Y") 
            		&& !formAuthSvc.hasReadAuth(formRequest, userInfo)) {
    	        	throw new SecurityException(DicHelper.getDic("msg_noViewACL")); // 조회 권한이 없습니다.
            }
            
            if(strReadMode.equalsIgnoreCase("DRAFT") || strReadMode.equalsIgnoreCase("TEMPSAVE") || strReadMode.equalsIgnoreCase("COMPLETE") || strReadMode.equalsIgnoreCase("REJECT")) {
            	boolean hasWriteAuth = formAuthSvc.hasWriteAuth(formRequest, userInfo);
                userInfo.setHasWriteAuth(hasWriteAuth);
            	if(!hasWriteAuth && (strReadMode.equalsIgnoreCase("DRAFT") || strReadMode.equalsIgnoreCase("TEMPSAVE")
            			|| formRequest.getEditMode().equals("Y")))
            		throw new SecurityException(DicHelper.getDic("msg_WriteAuth")); // 작성 권한이 없습니다.
            }
            
			/* 초기 변수값 수정
			 *  - ReadMode 변경
			*/ 
            if (!strReadMode.equals("COMPLETE"))
            {
            	strReadMode = formSvc.getReadMode(strReadMode,  processObj.optString("BusinessState"), formRequest.getSubkind(), processObj.optString("State"), processObj.optString("ProcessState"));
            	formRequest.setReadMode(strReadMode);
            } else if(processObj.optString("ProcessState").equals("288")) {
        		strReadMode = "PROCESS";
        		formRequest.setReadMode(strReadMode);
        		formRequest.setReadModeTemp(strReadMode);
            }
			
            // check whether migration or archive.
            if(formRequest.getBstored().equalsIgnoreCase("true")){
            	CoviMap paramsFormInstance = new CoviMap();
            	paramsFormInstance.put("formInstID", formRequest.getFormInstanceID());
            	CoviMap formInstance = (((CoviList)(formSvc.selectFormInstanceStore(paramsFormInstance)).get("list")).getJSONObject(0));	
            	// Store 데이터중 시스템에서 이관(마이그레이션  X)된 문서 여부.
            	if("Y".equals(formInstance.optString("IsArchive"))) {
            		formRequest.setIsFormInstArchived("true");
            		mav.setViewName("forms/Form");
            		mav.addObject("ArchiveStored", "true");
            	}
            }
            
            // 기록물 다안기안 권한처리
        	if (!formRequest.getGovRecordID().equals("")) {
        		String recordRowSeq = formSvc.selectGovRecordRowSeq(formRequest.getGovRecordID());
        		formRequest.setGovRecordRowSeq(recordRowSeq);
        	}
        	
			/* 처리
			 *  - Form Data 생성
			 *  - Template 삽입처리
			 *  - 자동 결재선 Data 생성
			*/ 
        	// 양식 파일 경로 > createFormJSON 내부에서 처리
//        	String formCompanyCode = null;
//        	if("Y".equals(isSaaS)) {
//        		CoviMap params = new CoviMap();
//        		params.put("FormID", formRequest.getFormId());
//        		params.put("FormPrefix", formRequest.getFormPrefix());
//        		params.put("ProcessID", formRequest.getProcessID());
//        		formCompanyCode = formSvc.selectFormCompanyCode(params);
//        	}
//        	filePath = initFilePath(formCompanyCode);
        	
			// Form Data 생성
            CoviMap formJsonRet = createFormJSON(formRequest, userInfo, processObj);
            
            String filePath = formJsonRet.getString("filePath");
            formJsonRet.remove("filePath");
            
            formJson = formJsonRet.getJSONObject("formJson");      
            //formRequest = (FormRequest) CoviMap.toBean(formJsonRet.getJSONObject("formRequest"), FormRequest.class);
            formRequest = (FormRequest) formJsonRet.get("formRequest");

            CoviMap initializedValueForTemplate = formJsonRet.getJSONObject("initializedValueForTemplate");
            
            strFormFavoriteYN = formJsonRet.getString("strFormFavoriteYN");
            
        	if(formJson.getJSONObject("ExtInfo").has("UseMultiEditYN"))
        		strUseMultiEditYN = formJson.getJSONObject("ExtInfo").getString("UseMultiEditYN");

        	if(formJson.getJSONObject("ExtInfo").has("UseHWPEditYN"))
        		strUseHWPEditYN = formJson.getJSONObject("ExtInfo").getString("UseHWPEditYN");
        	
        	if(formJson.getJSONObject("ExtInfo").has("UseWebHWPEditYN"))
        		strUseWebHWPEditYN = formJson.getJSONObject("ExtInfo").getString("UseWebHWPEditYN");
        	
        	if(formJson.getJSONObject("ExtInfo").has("UseEditYN"))
        		strUseWebEditorEditYN = formJson.getJSONObject("ExtInfo").getString("UseEditYN");
        	
        	if(formJson.getJSONObject("SchemaContext").getJSONObject("scDistribution").has("isUse"))
        		strUseScDistributionYN = formJson.getJSONObject("SchemaContext").getJSONObject("scDistribution").getString("isUse");
            
        	// 다안기안 + 문서유통(웹한글기안) 사용
        	if (strUseMultiEditYN.equals("Y") && strUseScDistributionYN.equals("Y") && strUseWebHWPEditYN.equals("Y"))
        		strUseWebHWPMultiEditYN = "Y";

        	//  문서유통 + 문서유통(웹한글기안) 사용
        	if (strUseScDistributionYN.equals("Y") && strUseWebHWPEditYN.equals("Y"))
        		strUseScWebHWPEditYN = "Y";
        	
        	//  문서유통 + 웹에디터 사용
        	if (strUseScDistributionYN.equals("Y") && strUseWebEditorEditYN.equals("Y"))
        		strUseScWebEditorEditYN = "Y";
        	
        	//  다안기안 + 문서유통 + 웹에디터 사용
        	if (strUseMultiEditYN.equals("Y") && strUseScDistributionYN.equals("Y") && strUseWebEditorEditYN.equals("Y"))
        		strUseScWebEditorMultiEditYN = "Y";
        	
			//Template 삽입 처리
            // 모바일일 경우 별도 메뉴 html 사용
            if(formRequest.getReadModeTemp().equals("mobile"))
            	strMenuTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormMobileMenu.html", "UTF8").trim();
            else if(formRequest.getMenuKind().equalsIgnoreCase("notelist"))
            	strMenuTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormNotelistMenu.html", "UTF8").trim();
            // 히스토리일 경우 메뉴 보이지 않도록 처리
            else if(!formRequest.getIsHistory().equals("true"))
            	strMenuTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormMenu.html", "UTF8").trim();
           
            // (본사운영) 대외공문일 경우 다른 Header 사용
            Boolean bNeedConvert = initializedValueForTemplate.getBoolean("bNeedConvert");
            if(formRequest.getFormPrefix().indexOf("WF_FORM_EXTERNAL") > -1){
            	strHeaderTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath+"common/FormHeader_EXTERNAL.html", "UTF8"), bNeedConvert);
            } else if(fileUtilSvc.fileIsExistsBoolean(filePath+"common/FormHeader"+"_"+formRequest.getFormPrefix()+".html")) { // new File(FileUtil.checkTraversalCharacter(filePath+"common/FormHeader"+"_"+formRequest.getFormPrefix()+".html")).exists() 
            	strHeaderTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath+"common/FormHeader"+"_"+formRequest.getFormPrefix()+".html", "UTF8"), bNeedConvert);
            } else if(strUseWebHWPMultiEditYN.equals("Y")) {
            	strHeaderTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath+"common/FormHeaderGovMulti.html", "UTF8"), bNeedConvert);
            //  다안기안 + 문서유통 + 웹에디터 사용
            } else if(strUseScWebEditorMultiEditYN.equals("Y")) {
            	// 공문형태 변환
            	if(formRequest.getGovState().equals("SENDWAIT") || formRequest.getReadtype().equals("govpreview") || formRequest.getGovState().equals("RECEIVEWAIT") || formRequest.getGovState().equals("RECEIVEPROCESS")) {
            		strBodyTemplGov = formSvc.docsTransform(formJson);
            	}else {
                	strHeaderTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath+"common/FormHeaderGovEditorMulti.html", "UTF8"), bNeedConvert);
            	}
            //  문서유통 + 웹에디터 사용
            } else if(strUseScWebEditorEditYN.equals("Y")) {
            	// 공문형태 변환
            	if(formRequest.getGovState().equals("SENDWAIT") || formRequest.getGovState().equals("RECEIVEWAIT") || formRequest.getReadtype().equals("govpreview")) {
            		strBodyTemplGov = formSvc.docsTransform(formJson);
            	}else {
                	strHeaderTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath+"common/FormHeaderGovEditor.html", "UTF8"), bNeedConvert);
            	}
            } else if(strUseMultiEditYN.equals("Y")) {
            	strHeaderTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath+"common/FormHeaderMulti.html", "UTF8"), bNeedConvert);
            } else if(strUseScWebHWPEditYN.equals("Y")) {
            	strHeaderTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath+"common/FormHeaderGov.html", "UTF8"), bNeedConvert);
            } else {
            	strHeaderTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath+"common/FormHeader.html", "UTF8"), bNeedConvert);
            }
            
            if(fileUtilSvc.fileIsExistsBoolean(filePath+"common/FormFooter"+"_"+formRequest.getFormPrefix()+".html")) { // new File(FileUtil.checkTraversalCharacter(filePath+"common/FormFooter"+"_"+formRequest.getFormPrefix()+".html")).exists()
            	strFooterTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormFooter"+"_"+formRequest.getFormPrefix()+".html", "UTF8");
            } else {
            	strFooterTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormFooter.html", "UTF8");
            }
            
            if(formRequest.getFormPrefix().equals("WF_FORM_DRAFT_HWP_MULTI")) {
	            String strBusinessState = !processObj.isNullObject() ? processObj.getString("BusinessState") : "";	
                //결재선 template 삽입
                switch (strBusinessState)
                {
                    case "01_01_02":    // 수신부서 결재중
                    case "01_01_04":    // 수신부서내 결재중
                    case "02_01_02":    // 수신부서 승인
                    case "02_02_02":    // 수신부서 반려
                    case "03_01_02":    // 수신부서 기안대기
                        strTopTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath + "common/FormTopDraftRec.html", "utf8"), bNeedConvert);
                        strApvLineTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath + "common/FormApvLineDraftRec.html", "utf8"), bNeedConvert);
                        break;
                    default:
                        strTopTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath + "common/FormTopDraft.html", "utf8"), bNeedConvert);
                        strApvLineTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath + "common/FormApvLineDraft.html", "utf8"), bNeedConvert);
                        break;
                }
            } else {
            	strApvLineTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormApvLine.html", "UTF8");
            }
            // 문서 안 결재선
            if (formJson.getJSONObject("SchemaContext").getJSONObject("scFormAddInApvLine").getString("isUse").equalsIgnoreCase("Y")) {
            	strAddInApvLineTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormAddInApvLine.html", "UTF8");
            }
			strCommonFieldsTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormCommonFields.html", "UTF8");
			
			// 외부 연동 시 Body Cotent 부분에 대해서 파라미터로 받은 HTML  그대로 삽입
			String isLegacy = formJson.getJSONObject("Request").getString("isLegacy");
			String bodyContext = formJson.getString("BodyContext");
			
			String domainID = "";
			if("Y".equals(isSaaS) && formJson.containsKey("FormInfo")) {
				domainID = formJson.getJSONObject("FormInfo").optString("DomainID");
			}
			if(isLegacy.equalsIgnoreCase("Y")){
				if((formRequest.getLegacyDataType().equalsIgnoreCase("ALL") || formRequest.getLegacyDataType().equalsIgnoreCase("HTML")) || (!bodyContext.equals("") && CoviMap.fromObject(bodyContext).has("HTMLBody"))){
					if(!strReadMode.equalsIgnoreCase("DRAFT")) {
						if(formRequest.getIsMobile().equalsIgnoreCase("Y") && CoviMap.fromObject(bodyContext).has("MobileBody"))
							strBodyTempl = formJson.getJSONObject("BodyContext").getString("MobileBody");
						else
							strBodyTempl = formJson.getJSONObject("BodyContext").getString("HTMLBody");								
					}
					else if(strReadMode.equalsIgnoreCase("DRAFT") && formRequest.getReadtype().equalsIgnoreCase("preview")) {
						strBodyTempl = "<div id='legacyFormDiv'></div>";
					}
					else {
						if(formRequest.getIsMobile().equalsIgnoreCase("Y") && CoviMap.fromObject(bodyContext).has("MobileBody"))
							strBodyTempl = new String(Base64.decodeBase64(formRequest.getMobileBodyContext().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
						else
							strBodyTempl = new String(Base64.decodeBase64(formRequest.getHtmlBodyContext().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
					}
				} else{
					strBodyTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, initializedValueForTemplate.getString("fileurl"), "UTF8", domainID), bNeedConvert);
				}
			} else{
				strBodyTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, initializedValueForTemplate.getString("fileurl"), "UTF8", domainID), bNeedConvert);
			}
			strBodyTemplJS = formFileCacheSvc.readAllText(lang, filePath + formJsonRet.getString("strFormFileName") + ".js", "UTF8", domainID);
			
			//첨부, 에디터 관련 삽입
            if (initializedValueForTemplate.optString("strTemplateType").equals("Write") || strUseMultiEditYN.equals("Y") || strUseHWPEditYN.equals("Y") || strUseWebHWPEditYN.equals("Y"))
            {	            		
                // 에디터 관련 스크립트 삽입
        		strEditorSrc = getEditorControlSrc(strUseHWPEditYN);

                if(initializedValueForTemplate.optString("strTemplateType").equals("Write")) {
	                // 첨부 template 삽입
	                strAttachTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormAttach.html", "UTF8");
	        		
	                if(strUseMultiEditYN.equals("Y")) {
	        			strAttachTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormAttachMulti.html", "UTF8");
	        		}
                }
            }
            
            // 문서유통 일반에디터 - 공문형식
            if(strUseScWebEditorEditYN.equals("Y") || strUseScWebEditorMultiEditYN.equals("Y")) {
            	if(formRequest.getGovState().equals("SENDWAIT") || formRequest.getReadtype().equals("govpreview") || formRequest.getGovState().equals("RECEIVEWAIT")) {
            		strBodyTempl = strBodyTemplGov;
            	}
            }
            
            // 문서유통 작성중 공문 미리보기
            if(strUseScWebEditorEditYN.equals("Y") || strUseScWebEditorMultiEditYN.equals("Y")) {
            	if(formRequest.getReadtype().equals("govpreviewWrite")) {
            		strHeaderTempl = "";
            		strBodyTempl = "<div id='govFormDiv'></div>";
            	}
            }
            
			// 읽음확인 - 가장 하단으로 위치 변경
            // 문서유통 수기등록 양식은 예외처리
            if (!strReadMode.equals("DRAFT") && !strReadMode.equals("TEMPSAVE") && !strReadMode.equals("TEMPSAVE_BOX") && !formRequest.getMenuKind().equalsIgnoreCase("notelist"))
            {
            	if(formRequest.getBstored().equalsIgnoreCase("false")){
            		formSvc.confirmRead(formRequest, userInfo, strReadMode, processObj);
            	} else {
            		formSvc.confirmReadStore(formRequest, userInfo);
            	}
            }
            
            // 개발모드일 경우, FormJson 값 주석으로 보여줌
            if(isDevMode.equals("Y")){
            	formJsonForDev = makeFormInfoForDev(formJson);
            }

        	//결재선 변경 여부
        	isApvLineChanged = formRequest.getIsApvLineChg();
        	
		} catch(SecurityException securityException) {
			LOGGER.warn("FormCon", securityException);
			LoggerHelper.errorLogger(securityException, "egovframework.covision.coviflow.form.web.FormCon.goCommonFormPage", "CON");
			errorMsg = securityException.getMessage();
			successYN = false;
		} catch(NoSuchElementException noSuchElementException) {
			errorMsg = noSuchElementException.getMessage();
			successYN = false;
		} catch(NullPointerException npE){
			LOGGER.error("FormCon", npE);
			LoggerHelper.errorLogger(npE, "egovframework.covision.coviflow.form.web.FormCon.goCommonFormPage", "CON");
			
			successYN = false;
			errorMsg = DicHelper.getDic("msg_apv_formLoadErrorMsg");
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, "egovframework.covision.coviflow.form.web.FormCon.goCommonFormPage", "CON");
			
			successYN = false;
			errorMsg = DicHelper.getDic("msg_apv_formLoadErrorMsg");
		}
		
		AES aes = new AES("", "N");
        formDraftkey = aes.encrypt(formDraftkey);
		
		mav.addObject("strMenuTempl", strMenuTempl);
		mav.addObject("strTopTempl", strTopTempl);
		mav.addObject("strApvLineTempl", strApvLineTempl);
		mav.addObject("strAddInApvLineTempl", strAddInApvLineTempl);
		mav.addObject("strCommonFieldsTempl", strCommonFieldsTempl);
		mav.addObject("strHeaderTempl", strHeaderTempl);
		mav.addObject("strBodyTempl", strBodyTempl);
		mav.addObject("strBodyTemplJS", strBodyTemplJS);
		mav.addObject("strFooterTempl", strFooterTempl);
		mav.addObject("strAttachTempl", strAttachTempl);
		
		// 2022-10-12 웹 한글 기안기 Y인 경우 스크립트 삽입
        if ("Y".equals(formJson.getJSONObject("ExtInfo").getString("UseWebHWPEditYN"))) {
        	strEditorSrc = getEditorControlSrc(formJson.getJSONObject("ExtInfo").getString("UseWebHWPEditYN"));
        }

		
		mav.addObject("strEditorSrc", strEditorSrc);
		mav.addObject("formJson", new String(Base64.encodeBase64(formJson.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8));
		mav.addObject("formJsonForDev", formJsonForDev);
		mav.addObject("strFormFavoriteYN", strFormFavoriteYN);
		mav.addObject("strApvLineYN", isApvLineChanged);
		mav.addObject("strUseMultiEditYN", strUseMultiEditYN);
		mav.addObject("formDraftkey", formDraftkey);
		
		mav.addObject("strErrorMsg", errorMsg);
		mav.addObject("strSuccessYN", successYN);
		
		mav.addObject("strLangIndex", strLangIndex);
		mav.addObject("AppName", appName); // 양식팝업 헤더명
		
		mav.addObject("useFido", PropertiesUtil.getSecurityProperties().getProperty("fido.login.used"));
		
		if(!strExpAppID.equals("")) {
			mav.addObject("ExpAppID", strExpAppID);
			mav.addObject("isUser", "Y");
		}
		
		return mav;
	}

	private UserInfo initUserInfo() throws Exception {
		UserInfo fSes = new UserInfo();
		//세션 값
        fSes.setUserID(SessionHelper.getSession("USERID"));
        fSes.setUserName(SessionHelper.getSession("USERNAME"));
        fSes.setUserMail(SessionHelper.getSession("UR_Mail"));
        fSes.setUserEmpNo(SessionHelper.getSession("UR_EmpNo"));
        fSes.setDeptID(SessionHelper.getSession("DEPTID"));
        fSes.setDeptName(SessionHelper.getSession("DEPTNAME"));
        fSes.setDNName(SessionHelper.getSession("DN_Name"));
        fSes.setDNCode(SessionHelper.getSession("DN_Code"));
        
        fSes.setJobPositionCode(SessionHelper.getSession("UR_JobPositionCode"));
        fSes.setJobPositionName(SessionHelper.getSession("UR_JobPositionName"));
        fSes.setJobTitleCode(SessionHelper.getSession("UR_JobTitleCode"));
        fSes.setJobTitleName(SessionHelper.getSession("UR_JobTitleName"));
        fSes.setJobLevelCode(SessionHelper.getSession("UR_JobLevelCode"));
        fSes.setJobLevelName(SessionHelper.getSession("UR_JobLevelName"));
        
        fSes.setDeptPath(SessionHelper.getSession("GR_GroupPath"));
        fSes.setGRFullName(SessionHelper.getSession("GR_FullName"));

        fSes.setURManagerCode(SessionHelper.getSession("UR_ManagerCode"));
        fSes.setURManagerName(SessionHelper.getSession("UR_ManagerName"));
        fSes.setURIsManager(SessionHelper.getSession("UR_IsManager"));
        
        // 사용자, 부서 다국어명 추가
        fSes.setUserMultiName(SessionHelper.getSession("UR_MultiName"));
        fSes.setUserMultiJobPositionName(SessionHelper.getSession("UR_MultiJobPositionName"));
        fSes.setUserMultiJobTitleName(SessionHelper.getSession("UR_MultiJobTitleName"));
        fSes.setUserMultiJobLevelName(SessionHelper.getSession("UR_MultiJobLevelName"));
        fSes.setDeptMultiName(SessionHelper.getSession("GR_MultiName"));
        
        // 사용자 사업장 추가
        fSes.setUserMultiRegionName(SessionHelper.getSession("UR_MultiRegionName"));
        fSes.setUserRegionCode(SessionHelper.getSession("UR_RegionCode"));

        // 결재 부서
        fSes.setApvDeptID(SessionHelper.getSession("ApprovalParentGR_Code"));
        //fSes.setApvDeptName(formSvc.selectDeptName(fSes.getApvDeptID()));
        fSes.setApvDeptName(StringUtil.replaceNull(SessionHelper.getSession("ApprovalParentGR_Name"),formSvc.selectDeptName(fSes.getApvDeptID())));

        fSes.setUserPhoneNumber(SessionHelper.getSession("PhoneNumber"));
        fSes.setUserFax(SessionHelper.getSession("Fax"));
		
        return fSes;
	}
	
	private UserInfo initUserInfo(String UserCode, String DeptCode) throws Exception {
		CoviMap params = new CoviMap();
		CoviMap userInfo = new CoviMap();
		params.put("id", UserCode);
		params.put("deptId", DeptCode);
		params.put("lang", lang);
		params.put("idType", "UserCode");
		userInfo = formSvc.selectUserInfo(params);
		
		UserInfo fSes = new UserInfo();
		
		//세션 값
        fSes.setUserID(userInfo.optString("UR_ID"));
        fSes.setUserName(userInfo.optString("UR_Name"));
        fSes.setUserMail(userInfo.optString("UR_Mail"));
        fSes.setUserEmpNo(userInfo.optString("UR_EmpNo"));
        fSes.setDeptID(userInfo.optString("GR_Code"));
        fSes.setDeptName(userInfo.optString("GR_Name"));
        fSes.setDNName(userInfo.optString("DN_Name"));
        fSes.setDNCode(userInfo.optString("DN_Code"));
        
        fSes.setJobPositionCode(userInfo.optString("UR_JobPositionCode"));
        fSes.setJobPositionName(userInfo.optString("UR_JobPositionName"));
        fSes.setJobTitleCode(userInfo.optString("UR_JobTitleCode"));
        fSes.setJobTitleName(userInfo.optString("UR_JobTitleName"));
        fSes.setJobLevelCode(userInfo.optString("UR_JobLevelCode"));
        fSes.setJobLevelName(userInfo.optString("UR_JobLevelName"));
        
        fSes.setDeptPath(userInfo.optString("GR_GroupPath"));
        fSes.setGRFullName(userInfo.optString("GR_FullName")); 

        fSes.setURManagerCode(userInfo.optString("UR_ManagerCode"));
        fSes.setURManagerName(userInfo.optString("UR_ManagerName"));
        fSes.setURIsManager(userInfo.optString("UR_IsManager"));
        
        // 사용자, 부서 다국어명 추가
        fSes.setUserMultiName(userInfo.optString("UR_MultiName"));
        fSes.setUserMultiJobPositionName(userInfo.optString("UR_MultiJobPositionName"));
        fSes.setUserMultiJobTitleName(userInfo.optString("UR_MultiJobTitleName"));
        fSes.setUserMultiJobLevelName(userInfo.optString("UR_MultiJobLevelName"));
        fSes.setDeptMultiName(userInfo.optString("GR_MultiName"));
        
        // 사용자 사업장 추가
        fSes.setUserMultiRegionName(userInfo.optString("UR_MultiRegionName"));
        fSes.setUserRegionCode(userInfo.optString("UR_RegionCode"));

        // 결재 부서
        fSes.setApvDeptID(userInfo.optString("ApprovalParentGR_Code")); 
        //fSes.setApvDeptName(formSvc.selectDeptName(fSes.getApvDeptID()));
        fSes.setApvDeptName(StringUtil.replaceNull(userInfo.optString("ApprovalParentGR_Name"),formSvc.selectDeptName(fSes.getApvDeptID()))); 

        fSes.setUserPhoneNumber(userInfo.optString("PhoneNumber")); // PhoneNumber/PhoneNumberInter/Mobile
        fSes.setUserFax(userInfo.optString("Fax")); // Fax
        
        return fSes;
	}
	
	private FormRequest initFormRequest(HttpServletRequest request){
		FormRequest fReq = new FormRequest();
		
		/** Request */
		// ID
        fReq.setProcessID(StringUtil.replaceNull(request.getParameter("processID"), ""));
        fReq.setWorkitemID(StringUtil.replaceNull(request.getParameter("workitemID"), ""));
        fReq.setPerformerID(StringUtil.replaceNull(request.getParameter("performerID"), ""));
        fReq.setFormId(StringUtil.replaceNull(request.getParameter("formID"), ""));
        fReq.setFormInstanceID(StringUtil.replaceNull(request.getParameter("forminstanceID"), ""));
        fReq.setFormTempInstanceID(StringUtil.replaceNull(request.getParameter("formtempID"), ""));
        fReq.setProcessdescriptionID(StringUtil.replaceNull(request.getParameter("processdescriptionID"), ""));
        
        // mode 및 gloct, loct
        fReq.setReadMode(StringUtil.replaceNull(request.getParameter("mode"), "").trim());
        fReq.setReadModeTemp(StringUtil.replaceNull(request.getParameter("mode"), "").trim());
        fReq.setReadtype(StringUtil.replaceNull(request.getParameter("Readtype"), ""));
        fReq.setGLoct(StringUtil.replaceNull(request.getParameter("gloct"), ""));
        
        fReq.setUserCode(StringUtil.replaceNull(request.getParameter("userCode"), "")); // User Code (세션 정보 X, Performer 및 Workitem의 UserCode)
        fReq.setSubkind(StringUtil.replaceNull(request.getParameter("subkind"), ""));
        fReq.setFormInstanceTableName(StringUtil.replaceNull(request.getParameter("forminstancetablename"), ""));
        fReq.setFormPrefix(StringUtil.replaceNull(request.getParameter("formPrefix"), ""));
        fReq.setRequestFormInstID(StringUtil.replaceNull(request.getParameter("RequestFormInstID"), ""));
        
        //편집할 때 request로 받은 데이터로 세팅
        if(request.getParameter("DocModifyApvLine") != null && !request.getParameter("DocModifyApvLine").equals(""))
        	fReq.setDocModifyApvLine(CoviMap.fromObject(request.getParameter("DocModifyApvLine").replace("&quot;", "\"")));
        
		// 구분값 (Y | N)
        fReq.setEditMode(StringUtil.replaceNull(request.getParameter("editMode"), "N")); // 편집 모드
        fReq.setArchived(StringUtil.replaceNull(request.getParameter("archived"), "false")); // archived. 완료 여부
        fReq.setBstored(StringUtil.replaceNull(request.getParameter("bstored"), "false")); // bStored. 이관함 여부
        fReq.setAdmintype(StringUtil.replaceNull(request.getParameter("admintype"), "")); // 관리자 페이지에서 조회시 ADMIN
        fReq.setIsAuth(StringUtil.replaceNull(request.getParameter("isAuth"), "")); 									// 사용자 문서함 권한 부여 여부
        fReq.setIsReuse(StringUtil.replaceNull(request.getParameter("reuse"), "")); 									// 재사용 여부
        fReq.setIsHistory(StringUtil.replaceNull(request.getParameter("ishistory"), "")); // 히스토리 여부
        fReq.setIsUsisdocmanager(StringUtil.replaceNull(request.getParameter("usisdocmanager"), "")); // 문서 관리자 여부. Y
        fReq.setIsTempSaveBtn(StringUtil.replaceNull(request.getParameter("isTempSaveBtn"), "Y")); // 임시저장 버튼 표시 여부
        fReq.setIsgovDocReply(StringUtil.replaceNull(request.getParameter("isgovDocReply"), "N")); // 문서24 개인사용자에 대한 회신표시 여부
        fReq.setSenderInfo(StringUtil.replaceNull(request.getParameter("senderInfo"), "")); // 문서24 발신한 개인사용자 정보
        fReq.setGovFormInstID(StringUtil.replaceNull(request.getParameter("govFormInstID"), "")); // 문서24 개인회신을 위한 접수문서 frminstid
        
        fReq.setIsSecdoc(StringUtil.replaceNull(request.getParameter("secdoc"), "")); // 기밀문서 여부
        fReq.setIsMobile(StringUtil.replaceNull(request.getParameter("isMobile"), "N"));
        fReq.setIsApvLineChg(StringUtil.replaceNull(request.getParameter("isApvLineChg"), "N"));
        fReq.setIsLegacy(StringUtil.replaceNull(request.getParameter("isLegacy"), "")); // 외부 연동 여부 (기안 양식 오픈을 외부에서)
        
        fReq.setJsonBodyContext(StringUtil.replaceNull(request.getParameter("jsonBody"), "")); // 외부 연동시 기안 bodycontext (기안 양식 오픈을 외부에서)
        fReq.setHtmlBodyContext(StringUtil.replaceNull(request.getParameter("htmlBody"), "")); // 외부 연동시 기안 html (기안 양식 오픈을 외부에서)
        fReq.setMobileBodyContext(StringUtil.replaceNull(request.getParameter("mobileBody"), "")); // 외부 연동시 기안 html - 모바일 용
        fReq.setLegacyBodyContext(StringUtil.replaceNull(request.getParameter("bodyContext"), "")); // 외부 연동시 기안 html 과 bodycontext (기안 양식 오픈을 외부에서)
        fReq.setSubject(StringUtil.replaceNull(request.getParameter("subject"), "")); // 외부 연동시 제목 (기안 양식 오픈을 외부에서)
        fReq.setLegacyDataType(StringUtil.replaceNull(request.getParameter("legacyDataType"), ""));	// 외부 연동 데이터 타입
        fReq.setLegacyApprovalLine(StringUtil.replaceNull(request.getParameter("legacyApprovalLine"), "")); // 외부 연동시 결재선
        
        fReq.setMenuKind(StringUtil.replaceNull(request.getParameter("menukind"), "")); // 양식 구분값(전자결재/문서유통)
        fReq.setDoclisttype(StringUtil.replaceNull(request.getParameter("doclisttype"), ""));
        fReq.setGovState(StringUtil.replaceNull(request.getParameter("GovState"), ""));
        fReq.setGovDocID(StringUtil.replaceNull(request.getParameter("GovDocID"), ""));
        // 기록물 다안기안 
        fReq.setGovRecordID(StringUtil.replaceNull(request.getParameter("GovRecordID"), ""));
        
        fReq.setOwnerProcessId(StringUtil.replaceNull(request.getParameter("ownerProcessId"), ""));
        
        fReq.setExpAppID(StringUtil.replaceNull(request.getParameter("ExpAppID"), "")); // 경비결재 오픈 여부 확인
        fReq.setOwnerExpAppID(StringUtil.replaceNull(request.getParameter("ownerExpAppID"), "")); // 경비결재 오픈 여부 확인
        
        fReq.setIsOpen(StringUtil.replaceNull(request.getParameter("isOpen"), "")); // 사업관리 오픈 여부 확인 [21-02-01 add]
		return fReq;
	}
		
	// Process Data Setting
	public CoviMap getProcessData(FormRequest formRequest) throws Exception {
		CoviMap ret = new CoviMap();
		
		CoviMap paramsProcess = new CoviMap();
        CoviMap paramsProcessDes = new CoviMap();
        
        String strFormInstanceID = formRequest.getFormInstanceID();
        String isArchived = formRequest.getArchived();
        String bStored  = formRequest.getBstored();
        
        if(bStored.equalsIgnoreCase("true")) {
        	isArchived = "true";
        }
        else if(!isArchived.equals("") && strFormInstanceID != null && !strFormInstanceID.equals("") ){
        	CoviMap paramID = new CoviMap();
        	paramID.put("FormInstID", strFormInstanceID);
        	isArchived = formSvc.selectFormInstanceIsArchived(paramID);
        }
        
        String strProcessID = formRequest.getProcessID();
        String strWorkitemID = formRequest.getWorkitemID();
        if(!strProcessID.equals("")){
        	paramsProcess.put("processID", strProcessID);
        	paramsProcess.put("workitemID", strWorkitemID);
        	paramsProcess.put("IsArchived", isArchived);					// Archive 가 있는 테이블은 반드시 넘겨야 함
        	paramsProcess.put("bStored", bStored);
        	
        	CoviMap resultObj = formSvc.selectProcess(paramsProcess);
        	CoviMap processObj = (((CoviList)resultObj.get("list")).getJSONObject(0));	// process 및 workitem 조합 데이터
        	
        	// 프로세스 조회 후, 값이 변경된 경우 다시 세팅
        	if(resultObj.containsKey("IsArchived")) {
        		isArchived = resultObj.getString("IsArchived");
        	}
        	if(resultObj.containsKey("bStored")) {
        		bStored = resultObj.getString("bStored");
        	}
        	
        	String strProcessdescriptionID = formRequest.getProcessdescriptionID();
        	if(strProcessdescriptionID.equals("")){
        		strProcessdescriptionID= processObj.getString("ProcessDescriptionID");
        	}
        	
        	String strSubkind = formRequest.getSubkind();
        	if(strSubkind.equals("") && processObj.has("SubKind"))
        		strSubkind = processObj.optString("SubKind");
        	
        	paramsProcessDes.put("processDescID", strProcessdescriptionID);
        	paramsProcessDes.put("IsArchived", isArchived);					// Archive 가 있는 테이블은 반드시 넘겨야 함
        	paramsProcessDes.put("bStored", bStored);
        	CoviMap processDesObj = (((CoviList)(formSvc.selectProcessDes(paramsProcessDes)).get("list")).getJSONObject(0));
        	
            processObj.put("ProcessDescription",processDesObj);
            
            ret.put("strSubkind", strSubkind);
            ret.put("isArchived", isArchived);
            ret.put("bStored", bStored);
            ret.put("processObj", processObj);
        }
        
        return ret;
	}
	
	// make FormJSON
	/**
	 * 
	 * @param formRequest
	 * @param userInfo
	 * @param processObj
	 * @return
	 * @throws Exception
	 */
	public CoviMap createFormJSON(FormRequest formRequest, UserInfo userInfo, CoviMap processObj) throws Exception{
		CoviMap ret = new CoviMap();
		
        CoviMap paramsForms = new CoviMap();
        CoviMap paramsSchema = new CoviMap();
        CoviMap paramsFormInstance = new CoviMap();
        
        CoviMap forms = new CoviMap();
        String strFormFavoriteYN = "N";
        CoviMap extInfo = new CoviMap();
        String strUnifiedFormYN = "";
        CoviMap subtableInfo = new CoviMap();
        CoviMap autoApprovalLine = new CoviMap();
        String strSchemaID = null;
        String strFormFileName = null;
        CoviMap formSchema = new CoviMap();
        CoviMap schemaContext = new CoviMap();	
        CoviMap formInstance = new CoviMap();
        CoviMap bodyContext = new CoviMap();
        CoviMap bodyData = new CoviMap();	
        
        String strFormId = formRequest.getFormId();
        String strFormPrefix = formRequest.getFormPrefix();
        String strReadMode = formRequest.getReadMode();
        String bStored = formRequest.getBstored();
        
		String strSessionUserID = userInfo.getUserID();
		String isGovReceiveForm = "N"; // 문서유통 수신함 문서 여부
		
		paramsForms.put("userID", strSessionUserID);
		if(!strFormId.equals("")){
			paramsForms.put("formID", strFormId);
		}else{
			paramsForms.put("formPrefix", strFormPrefix);
		}
		forms = (((CoviList)(formSvc.selectForm(paramsForms)).get("list")).getJSONObject(0));
		String filePath = ApprovalUtil.getTemplatePath(forms.optString("CompanyCode"));
		ret.putOrigin("filePath", filePath);
		
		if(!forms.get("FormPrefix").equals("")){
			strFormPrefix = forms.optString("FormPrefix");
			formRequest.setFormPrefix(strFormPrefix);
		}
		
		if(!forms.get("IsFavorite").equals("")){
			strFormFavoriteYN = forms.optString("IsFavorite");
		}
		
		if(!forms.get("ExtInfo").equals("")){
			extInfo = forms.getJSONObject("ExtInfo");
			strUnifiedFormYN = extInfo.optString("UnifiedFormYN").trim();
		}
		forms.remove("ExtInfo");
		
		// 문서유통 수신문서 여부 추가
		CoviList GovdocsReceiveInfo = RedisDataUtil.getBaseCode("GovdocsReceiveInfo");
		for (int z = 0; z < GovdocsReceiveInfo.size(); z++) {
			if (GovdocsReceiveInfo.getJSONObject(z).optString("Code").equalsIgnoreCase("formPrefix")) {
				if (GovdocsReceiveInfo.getJSONObject(z).getString("Reserved1").equals(strFormPrefix)) {
					isGovReceiveForm = "Y";
				}
				break;
			}
		}
		extInfo.put("IsGovReceiveForm", isGovReceiveForm);
		
		if(!forms.get("SubTableInfo").equals(""))
			subtableInfo = forms.getJSONObject("SubTableInfo");
		forms.remove("SubTableInfo");
		
		if(!forms.get("AutoApprovalLine").equals(""))
			autoApprovalLine = forms.getJSONObject("AutoApprovalLine");
		/* 자동결재선(설정)의 가공된 결재선 : workedApprovalLine 추가 */
		forms.remove("AutoApprovalLine");
		
		// 양식 도움말과 양식 팝업 내용 디코딩
		if(forms.has("FormHelperContext") && !forms.get("FormHelperContext").equals("")){
			forms.put("FormHelperContext", new String(Base64.decodeBase64(forms.optString("FormHelperContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
		}
		if(forms.has("FormNoticeContext") && !forms.get("FormNoticeContext").equals("")){
			forms.put("FormNoticeContext", new String(Base64.decodeBase64(forms.optString("FormNoticeContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
		}
		
		strSchemaID = forms.getString("SchemaID");
		
		strFormFileName = forms.getString("FileName").substring(0, forms.getString("FileName").lastIndexOf("."));
		// 파일 명 (읽기쓰기 모드 구별된 파일명) 데이터 추가 - HTMLFileName
		
		String strFormInstanceID = formRequest.getFormInstanceID();
		if(strFormInstanceID != null && !strFormInstanceID.equals("")){
			paramsFormInstance.put("formInstID", strFormInstanceID);
			if(formRequest.getBstored().equalsIgnoreCase("true")){
				formInstance = (((CoviList)(formSvc.selectFormInstanceStore(paramsFormInstance)).get("list")).getJSONObject(0));				
			}else{
				formInstance = (((CoviList)(formSvc.selectFormInstance(paramsFormInstance)).get("list")).getJSONObject(0));				
			}
			
			if(!formInstance.get("BodyContext").equals("") &&
					(!formRequest.getBstored().equalsIgnoreCase("true") || "true".equals(formRequest.getIsFormInstArchived()))) {
				//주소만 받아오기때문에 형식을 json 으로 하지 않는다.
				// IsFormInstArchived : store && system archived.
				bodyContext = CoviMap.fromObject(new String(Base64.decodeBase64(formInstance.optString("BodyContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8), false);					
				formInstance.remove("BodyContext");
			}
			if(formInstance.has("AttachFileInfo") && !formInstance.get("AttachFileInfo").equals("")) {
				formInstance.put("AttachFileInfo", CoviMap.fromObject(new String(Base64.decodeBase64(formInstance.optString("AttachFileInfo").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8)));
			}
			
			if(formInstance.containsKey("SchemaID") && !strReadMode.equalsIgnoreCase("TEMPSAVE")) {
				strSchemaID = (String) formInstance.get("SchemaID");
			}
		}else if(formRequest.getIsLegacy().equalsIgnoreCase("Y")){
			if(!formRequest.getLegacyBodyContext().equals(""))		// 미리보기시
				bodyContext = CoviMap.fromObject(new String(Base64.decodeBase64(formRequest.getLegacyBodyContext().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8), false);
			if(!formRequest.getSubject().equals(""))
				formInstance.put("Subject", formRequest.getSubject());
		}
		
		//SchemaContext
		paramsSchema.put("schemaID", strSchemaID);
		formSchema = (((CoviList)(formSvc.selectFormSchema(paramsSchema)).get("list")).getJSONObject(0));
		
		if(!formSchema.get("SchemaContext").equals(""))
			schemaContext = formSchema.getJSONObject("SchemaContext");
		
		// BodyData
		bodyData = formSvc.getBodyData(subtableInfo, extInfo, strFormInstanceID);				/// 하위테이블 데이터가 있을 경우 bodyData에 세팅
		
		// ApprovalLine
		CoviMap approvalLine = null;
		CoviMap docModifyApvLine = formRequest.getDocModifyApvLine();
		
		if(docModifyApvLine !=null && !docModifyApvLine.isEmpty()){
			approvalLine = docModifyApvLine;
		}else{
			approvalLine = setDomainData(strReadMode, userInfo.getUserID(), userInfo.getDeptID(), formRequest.getProcessID(), formRequest.getArchived(), formRequest.getBstored(), formRequest.getParentProcessID(), schemaContext);
		}
		
		// 파라미터에 RequestFormInstID가 있는 경우 (완료함의 양식에서 후속 작업을 위한 결재선 조회. ex) 휴가취소신청서, 출장복명서)
		Boolean afterDomain = false;
		String strRequestFormInstID = formRequest.getRequestFormInstID();
		if(strRequestFormInstID != null && !strRequestFormInstID.equals("")){
			paramsForms.clear();
			paramsForms.put("FormInstID", strRequestFormInstID);
        	
			CoviList selectData = (CoviList)(formSvc.selectFormAfterDomainData(paramsForms)).get("list");
        	if(!selectData.isEmpty()){
        		afterDomain = true;
        		approvalLine = selectData.getJSONObject(0).getJSONObject("DomainDataContext");
        	}
		}
		//재사용 및 후속작업시 검토삭제
		if("Y".equals(formRequest.getIsReuse()) || afterDomain)
			approvalLine = domainDataConsultDelete(approvalLine);
		
		//자동 결재선 Data 생성
		CoviMap allAutoLine = setAutoDomainData(autoApprovalLine, userInfo, formRequest.getFormTempInstanceID(), strReadMode, schemaContext.getJSONObject("scStep"), strFormPrefix, strRequestFormInstID);
	
		CoviMap workedAutoApprovalLine = allAutoLine.getJSONObject("autoDomainData");
		if(!"".equals(formRequest.getLegacyApprovalLine())) { //기간계 연동시 넘겨받은 결재선이 있을경우
			workedAutoApprovalLine = CoviMap.fromObject(new String(Base64.decodeBase64(formRequest.getLegacyApprovalLine().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
		}
		
		autoApprovalLine = allAutoLine.getJSONObject("autoApprovalLine");
		
		// JWF_Comment
		paramsForms.clear();
		paramsForms.put("FormInstID", strFormInstanceID);
		CoviList comment = (CoviList)(formSvc.selectComment(paramsForms)).get("list");
		
		// Request
		CoviMap requestData = new CoviMap();
		/* loct 포함 -> CheckLoct()함수 값 */
		requestData.put("editmode", formRequest.getEditMode());
		requestData.put("admintype", formRequest.getAdmintype());
		requestData.put("isAuth", formRequest.getIsAuth());
		requestData.put("mode", strReadMode);
		requestData.put("processID", formRequest.getProcessID());
		requestData.put("workitemID", formRequest.getWorkitemID());
		requestData.put("performerID", formRequest.getPerformerID());
		requestData.put("userCode", formRequest.getUserCode());
		requestData.put("gloct", formRequest.getGLoct());
		requestData.put("formID", strFormId);
		requestData.put("forminstanceID", strFormInstanceID);
		requestData.put("subkind", formRequest.getSubkind());
		requestData.put("formtempID", formRequest.getFormTempInstanceID());
		requestData.put("forminstancetablename", formRequest.getFormInstanceTableName());
		requestData.put("readtype", formRequest.getReadtype());
		requestData.put("processdescriptionID", formRequest.getProcessdescriptionID());
		requestData.put("reuse", formRequest.getIsReuse());
		requestData.put("ishistory", formRequest.getIsHistory());
		requestData.put("usisdocmanager", formRequest.getIsUsisdocmanager());
		requestData.put("secdoc", formRequest.getIsSecdoc());
		
		String strgovDocReply = formRequest.getIsgovDocReply();
		if (strgovDocReply.equals("Y")) {
			CoviMap govObj = CoviMap.fromObject(egovframework.coviframework.util.ComUtils.getProperties("govdocs.properties"));
			if(govObj.optString("gov24.reply.use", "N").equals("Y")) {
				requestData.put("isgovDocReply", strgovDocReply); 
				requestData.put("ReplyFlag", formSvc.selectCheckReplyDoc(strFormInstanceID) );
				requestData.put("govFormInstID", formRequest.getGovFormInstID());
				
				if(!formRequest.getSenderInfo().equals("")) {
					requestData.put("gov24sender", formSvc.selectGov24SenderInfo(formRequest.getSenderInfo()));
				}
			}
		}
		
		
		String isLegacy = formRequest.getIsLegacy();
		if(isLegacy.equals(""))
			isLegacy = (forLegacySvc.isLegacyFormCheck(strFormPrefix)) ? "Y" : "N";
		requestData.put("isLegacy", isLegacy);
		
		requestData.put("isTempSaveBtn", formRequest.getIsTempSaveBtn());
		requestData.put("legacyDataType", formRequest.getLegacyDataType());
		
		CoviMap initializedValueForTemplate = pInitValueForTemplate(strReadMode, formRequest.getReadtype(), formRequest.getEditMode(), strFormFileName, strUnifiedFormYN, filePath);
		
		requestData.put("templatemode", initializedValueForTemplate.getString("strTemplateType"));
		
		String strProcessID = formRequest.getProcessID();
		if(strProcessID == null || strProcessID.equals("") || processObj.isNullObject() || processObj.isEmpty() ){
			requestData.put("loct", strReadMode);
		}else{
			requestData.put("loct", getLOCTData(formRequest, strReadMode, userInfo.getUserID(), userInfo.getApvDeptID(), userInfo.getDNCode(), processObj));
		}
		
		requestData.put("isMobile", formRequest.getIsMobile());
		
		//문서유통 유형 비교를 위해 추가
		requestData.put("menukind", formRequest.getMenuKind());
		requestData.put("doclisttype", formRequest.getDoclisttype());
		requestData.put("govstate", formRequest.getGovState());
		requestData.put("govdocid", formRequest.getGovDocID());
		
		// 기록물 다안 권한처리를 위해 추가
		requestData.put("govrecordid", formRequest.getGovRecordID());
		requestData.put("govrecordrowseq", formRequest.getGovRecordRowSeq());
		
		// AppInfo - Session, 기타 등
		CoviMap appInfo = new CoviMap();
		
		UserInfo tmpUserInfo = userInfo;
		if(strReadMode.equalsIgnoreCase("TEMPSAVE") && formRequest.getGLoct().equalsIgnoreCase("ADMTEMPSAVE")) {
			// 관리자페이지 임시저장문서보기 : 양식 내 세션사용자 정보를 기안자 정보로 변경
			tmpUserInfo = initUserInfo(formInstance.optString("InitiatorID"),formInstance.optString("InitiatorUnitID"));
			// 사용자정보 조회시 겸직 처리를 위해 부서정보도 필요
			// 기안자 부서정보(InitiatorUnitID)는 결재사용부서(dpid_apv - ApprovalParentGR_Code)를 사용하므로  이게 실제 부서와 다른 경우 사용자 정보 조회 방법이 없음
			// 관리자페이지 임시저장문서보기의 기안자 정보를 위해 사용하는 기능이므로 정보조회가 되지 않는 경우 사용자명/부서명만 셋팅 
			if(StringUtils.isBlank(tmpUserInfo.getUserID())) {
				tmpUserInfo.setUserName(DicHelper.getDicInfo(formInstance.optString("InitiatorName"), lang));
				tmpUserInfo.setUserMultiName(formInstance.optString("InitiatorName"));
				tmpUserInfo.setDeptName(DicHelper.getDicInfo(formInstance.optString("InitiatorUnitName"), lang));
				tmpUserInfo.setApvDeptName(formInstance.optString("InitiatorUnitName"));
				tmpUserInfo.setDeptMultiName(formInstance.optString("InitiatorUnitName"));
			}
		}
		
		appInfo.put("usid", tmpUserInfo.getUserID());
		appInfo.put("usnm", tmpUserInfo.getUserName());
		appInfo.put("dpid", tmpUserInfo.getDeptID());
		appInfo.put("dpnm", tmpUserInfo.getDeptName());
		appInfo.put("dpid_apv", tmpUserInfo.getApvDeptID());				
		appInfo.put("dpdn_apv", tmpUserInfo.getApvDeptName());	
		appInfo.put("etnm", tmpUserInfo.getDNName());
		appInfo.put("etid", tmpUserInfo.getDNCode());
		appInfo.put("ussip", tmpUserInfo.getUserMail());				// 임의. 이메일 주소
		appInfo.put("sabun",  tmpUserInfo.getUserEmpNo());										// 사번
		
		appInfo.put("uspc", tmpUserInfo.getJobPositionCode());		// 직위 코드
		appInfo.put("uspn", tmpUserInfo.getJobPositionName());		// 직위 명
		appInfo.put("ustc", tmpUserInfo.getJobTitleCode());				// 직책 명
		appInfo.put("ustn", tmpUserInfo.getJobTitleName());				// 직책 코드
		appInfo.put("uslc", tmpUserInfo.getJobLevelCode());				// 직급 명
		appInfo.put("usln", tmpUserInfo.getJobLevelName());			// 직급 코드
		
		appInfo.put("grpath", tmpUserInfo.getDeptPath());
		appInfo.put("grfullname", tmpUserInfo.getGRFullName()); 			//dppathdn
		
		appInfo.put("managercode", tmpUserInfo.getURManagerCode());
		appInfo.put("managername", tmpUserInfo.getURManagerName());
		appInfo.put("usismanager", tmpUserInfo.getURIsManager());
		
		appInfo.put("hasWriteAuth",tmpUserInfo.isHasWriteAuth());
		
		String dateFormat = "yyyy-MM-dd HH:mm:ss";
		appInfo.put("svdt", DateHelper.getCurrentDay(dateFormat));
		
		// GMT 기준시간 추가
		if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
			appInfo.put("svdt_TimeZone", DateHelper.getCurrentDay(dateFormat));
		}
		else { // 타임존 사용하는 경우
			SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
			sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
			appInfo.put("svdt_TimeZone", sdf.format(new Date()));	
		}
		
		appInfo.put("usit", tmpUserInfo.getUserSignFileID());			// 서명이미지
		
		appInfo.put("usnm_multi", tmpUserInfo.getUserMultiName());
		appInfo.put("uspn_multi", tmpUserInfo.getUserMultiJobPositionName());
		appInfo.put("ustn_multi", tmpUserInfo.getUserMultiJobTitleName());
		appInfo.put("usln_multi", tmpUserInfo.getUserMultiJobLevelName());
		appInfo.put("dpnm_multi", tmpUserInfo.getDeptMultiName());
		
		//appInfo.put("ustp", SessionHelper.getSession("PhoneNumber"));
		//appInfo.put("usfx", SessionHelper.getSession("Fax"));
		appInfo.put("ustp", tmpUserInfo.getUserPhoneNumber());
		appInfo.put("usfx", tmpUserInfo.getUserFax());
		

		// BaseConfig
		String editortype = RedisDataUtil.getBaseConfig("EditorType");
		// 미사용
		//String fmfl = RedisDataUtil.getBaseConfig("FrontStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "Approval";																// 기존 데이터 : /FrontStorageApproval/
		//String fmurl = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "e-sign/ApprovalEDMS/";					// 기존 데이터 : http://www.no1.com/GWStoragee-sign/ApprovalEDMS/
		//String fmpath = RedisDataUtil.getBaseConfig("BackStoragePath").replace("{0}", SessionHelper.getSession("DN_Code")) + "e-sign/ApprovalEDMS/";									// 기존 데이터 : \\192.168.32.71\GWStorage\e-sign\ApprovalEDMS\
		//String attpath = RedisDataUtil.getBaseConfig("BackStoragePath").replace("{0}", SessionHelper.getSession("DN_Code")) + "e-sign/Approval/Attach";			// 기존 데이터 : \\192.168.32.71\GWStorage\e-sign\Approval\Attach\
		//String sealpath = RedisDataUtil.getBaseConfig("OfficailSeal_SavePath");
		
		CoviMap baseConfig = new CoviMap();
		//baseConfig.put("fmfl", fmfl);				// FrontStorage (+ Approval)기존 데이터 : /FrontStorageApproval/
		//baseConfig.put("fmurl", fmurl);				// 기존 데이터 : http://www.no1.com/GWStoragee-sign/ApprovalEDMS/
		//baseConfig.put("fmpath", fmpath);			// 기존 데이터 : \\192.168.32.71\GWStorage\e-sign\ApprovalEDMS\
		//baseConfig.put("attpath", attpath);			// 기존 데이터 : \\192.168.32.71\GWStorage\e-sign\Approval\Attach\
		//baseConfig.put("sealpath", sealpath);
		baseConfig.put("editortype", editortype);	// Dext5로 임시 고정
		/*
		 *fmfl : FrontStorage (+ Approval)
		 *fmurl : BackStorage (+ e-sign/ApprovalEDMS)
		 *fmpath : BackStoragePath (Replace ~)
		 *attpath : BackStoragePath (Replace ~)
		 *sealpath : OfficailSeal_SavePath
		 *editortype : EditorType 
		 */
		
		// 첨부파일
		CoviList fileInfos = new CoviList();
		
		if(!strReadMode.equals("DRAFT")){
			if(bStored.equalsIgnoreCase("true")){
				fileInfos = getStoreFileInfos(strFormInstanceID);
			}else{
				fileInfos = getFileInfos(strFormInstanceID);				
			}
		}
		
		CoviMap formJson = new CoviMap();
		formJson.put("FormInfo", forms);
		formJson.put("FormInstanceInfo", formInstance);
		formJson.put("ProcessInfo", processObj);				// process 및 workitem 조합 데이터
		//formJson.("ProcessInfo", processDesObj);			// process description 데이터
		formJson.put("SchemaContext", schemaContext);
		formJson.put("BodyContext", bodyContext);
		formJson.put("BodyData", bodyData);
		formJson.put("ApprovalLine", ComUtils.changeCommentFileInfos(approvalLine));
		formJson.put("ExtInfo", extInfo);
		formJson.put("SubTableInfo", subtableInfo);
		formJson.put("AutoApprovalLine", autoApprovalLine);
		formJson.put("WorkedAutoApprovalLine", workedAutoApprovalLine);
		formJson.put("JWF_Comment", comment);
		formJson.put("Request", requestData);
		formJson.put("AppInfo", appInfo);
		formJson.put("BaseConfig", baseConfig);
		formJson.put("FileInfos", fileInfos);
		
		ret.put("formJson", formJson);
		ret.put("formRequest", formRequest);
		ret.put("strFormFavoriteYN", strFormFavoriteYN);
		ret.put("initializedValueForTemplate", initializedValueForTemplate);
		ret.put("strFormFileName", strFormFileName);
		return ret;
	}
	
	public String getLOCTData(FormRequest formRequest, String strReadMode, String strSessionUserID, String strSessionDeptID, String strSessionDNCode, CoviMap processObj) {
		String strLoct = "";

		String processState = processObj.optString("ProcessState");
		String workitemState = processObj.has("State") ? processObj.optString("State") : "";
		String strDeputyID = processObj.has("DeputyID") ? processObj.optString("DeputyID") : "";
		
        if (strReadMode.equals("APPROVAL") || strReadMode.equals("PCONSULT") || strReadMode.equals("SUBAPPROVAL") || strReadMode.equals("RECAPPROVAL") || strReadMode.equals("AUDIT")
        		|| strReadMode.equals("REDRAFT") || strReadMode.equals("SUBREDRAFT")){
            if (!processState.equals("288")){//(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                strLoct = "COMPLETE";
            } else {
                if (!workitemState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                    strLoct = "PROCESS";
                } else {
                    if (strSessionUserID.equals(formRequest.getUserCode())
                    		|| strSessionUserID.equals(processObj.has("UserCode") ? processObj.optString("UserCode") : "") 
                    		|| strSessionUserID.equals(strDeputyID)) {
                    	strLoct = formRequest.getReadModeTemp();
                    }else if(formRequest.getGLoct().equals("DEPART") && (
                    		strSessionDeptID.equals(formRequest.getUserCode())
                    		|| strSessionDeptID.equals(processObj.has("UserCode") ? processObj.optString("UserCode") : "")
                    		)) {
                        strLoct = formRequest.getReadModeTemp();
                    } else if(formRequest.getGLoct().equals("JOBFUNCTION")){
                    	CoviMap params = new CoviMap();
                		params.put("FormInstID", formRequest.getFormInstanceID());
                		params.put("UserID", strSessionUserID);
                		params.put("DeptID", strSessionDeptID);
                		params.put("entCode", strSessionDNCode);
                		if(formSvc.isJobFunctionManager(params)) strLoct = formRequest.getReadModeTemp();
                		else strLoct = "PROCESS"; 
                    } else {
                        strLoct = "PROCESS";
                    }
                }
            }
        } 
//        else if (strReadMode.equals("REDRAFT") || strReadMode.equals("SUBREDRAFT")){
//            if (!processState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
//                strLoct = "COMPLETE";
//            } else {
//                if (!workitemState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
//                    strLoct = "PROCESS";
//                } else {
//                    strLoct = formRequest.getReadModeTemp();
//                }
//            }
//        } 
        else if (strReadMode.equals("REJECT")){
        	strLoct = "REJECT";
        } else if ((strReadMode.equals("CONSULT") || strReadMode.equals("CONSULTATION")) && workitemState.equals("288")){
        	strLoct = "APPROVAL";
        } else {
            strLoct = formRequest.getReadModeTemp();
        }

        return strLoct;
    }
	
	public String convertWriteHtmlToRead(String strDocument, Boolean bNeedConvert){
		StringBuffer result = new StringBuffer(strDocument.length());
        String strReturnDocument = "";
        
        Pattern p = null;
        Matcher m = null;
        int count = 0;
        
        Pattern SPECIAL_REGEX_CHARS = Pattern.compile("[$]");	//("[{}()\\[\\].+*?^$\\\\|]");
        strDocument = SPECIAL_REGEX_CHARS.matcher(strDocument).replaceAll("\\\\$0");
        
        if(Boolean.TRUE.equals(bNeedConvert)){
            //input 변경 -> span (type="text" 앞, value 뒤)
            // <input $1 type="text" $3 value="$5" $6 >
            // -> <span $1 $3 $6 >$5</span>
            //                   1                 2            3                  4      5      6                                       
            /*strPattern = @"<input(.*?)type\s*?=\s*?(['""])text\2(.*?)value\s*?=\s*?(['""])(.*?)\4(.*?)>";
            strReplaceValue = "<span $1 $3 $6 >$5</span>";
            strReturnDocument = Regex.Replace(strReturnDocument, strPattern, strReplaceValue, RegexOptions.Multiline | RegexOptions.IgnoreCase);*/
			
			p = Pattern.compile("<input(.*?)type\\s*?=\\s*?(['\"\"])text\\2(.*?)value\\s*?=\\s*?(['\"\"])(.*?)\\4(.*?)>");
			m = p.matcher(strDocument);
			
			while(m.find()){
				String value1 = m.group(1);
				String value3 = m.group(3);
				String value5 = m.group(5);
				String value6 = m.group(6);
				//tempDic 부분을 redis 다국어 가져 오는 걸로 대체
				m.appendReplacement(result, "<span " + value1 + " " + value3 + " " + value6 + " >" + value5 + "</span>");
				
				count++;
			}
			if(count > 0){
				m.appendTail(result);
				strDocument = result.toString();
			}
			
			count = 0;
			
            //input 변경 -> span  (value 앞, type="text" 뒤)
            // <input $1 value="$3" $4 type="text" $6 >
            // -> <span $1 $4 $6 >$3</span>
            //                   1                  2      3      4                 5            6                                       
            /*strPattern = @"<input(.*?)value\s*?=\s*?(['""])(.*?)\2(.*?)type\s*?=\s*?(['""])text\5(.*?)>";
            strReplaceValue = "<span $1 $4 $6 >$3</span>";
            strReturnDocument = Regex.Replace(strReturnDocument, strPattern, strReplaceValue, RegexOptions.Multiline | RegexOptions.IgnoreCase);*/
			
			result = new StringBuffer(strDocument.length());
			p = null;
			m = null;

			p = Pattern.compile("<input(.*?)value\\s*?=\\s*?(['\"\"])(.*?)\\2(.*?)type\\s*?=\\s*?(['\"\"])text\\5(.*?)>");
			m = p.matcher(strDocument);
			
			while(m.find()){
				String value1 = m.group(1);
				String value3 = m.group(3);
				String value4 = m.group(4);
				String value6 = m.group(6);
				//tempDic 부분을 redis 다국어 가져 오는 걸로 대체
				m.appendReplacement(result, "<span " + value1 + " " + value4 + " " + value6 + " >" + value3 + "</span>");
				count++;
			}
			
			if(count > 0){
				m.appendTail(result);
				strDocument = result.toString();
			}
			
			count = 0;
			
            //textarea 변경
            //                      1     2 

			// [2014-11-24 modi] textarea를 멀티로우와 아닌곳에서 모두사용한 양식이 있으면 오류남
			//strPattern = @"<textarea(.*?)>{{(.*?)}}</textarea>";
			//strReplaceValue = "<span data-element-type=\"textarea_linebreak\" $1>{{$2}}</span>";
			/*strPattern = @"<textarea(.*?)>(.*?)</textarea>";
			strReplaceValue = "<span data-element-type=\"textarea_linebreak\" $1>$2</span>";

            strReturnDocument = Regex.Replace(strReturnDocument, strPattern, strReplaceValue, RegexOptions.Singleline | RegexOptions.IgnoreCase);*/

			result = new StringBuffer(strDocument.length());
			p = null;
			m = null;
			
			p = Pattern.compile("<textarea(.*?)>(.*?)</textarea>");
			m = p.matcher(strDocument);
			
			
			while(m.find()){
				String value1 = m.group(1);
				String value2 = m.group(2);
				//tempDic 부분을 redis 다국어 가져 오는 걸로 대체
				m.appendReplacement(result, "<span data-element-type=\"textarea_linebreak\" " + value1 + ">" + value2 + "</span>");
				count++;
			}
			if(count > 0){
				m.appendTail(result);
				strDocument = result.toString();
			}
			
            //required 제거
            strReturnDocument = strDocument.replace("required=\"\"", "");
            strReturnDocument = strDocument.replace("required", "");

            //data-pattern 제거
            //strPattern = @"data-pattern\s*?=\s*?(['""])(.*?)\1";
            //strReplaceValue = "";
            //strReturnDocument = Regex.Replace(strReturnDocument, strPattern, strReplaceValue, RegexOptions.Multiline | RegexOptions.IgnoreCase);
	        
        }else{
        	strReturnDocument = strDocument;
        }

        return strReturnDocument;
    }
	
	//파일명, template의 모드, 변환 여부를 처리하는 함수
	public CoviMap pInitValueForTemplate(String strReadMode, String strReadtype, String isEditMode, String strFormFileName, String strUnifiedFormYN, String filePath){
        // 읽기, 쓰기 통합에 따른 추가 분기 처리
		
		String strTemplateType = "";
		String fileurl = "";
		String filename = "";
		Boolean bNeedConvert = false;
		
        if (strReadMode.equalsIgnoreCase("DRAFT") 
        		&& (!strReadtype.equals("preview")) 
        		&& (!strReadtype.equals("Pubpreview"))
        		&& !isEditMode.equals("P")
        		&& !strReadtype.equals("govpreviewWrite")){
            //쓰기형태, 초기화 Y
            strTemplateType = "Write";
        }else if ((strReadMode.equalsIgnoreCase("TEMPSAVE") || !isEditMode.equals("N")) 
        		&& (!strReadtype.equals("preview")) 
        		&& (!strReadtype.equals("Pubpreview")) 
        		&& (!isEditMode.equals("P"))
        		&& !strReadtype.equals("govpreviewWrite")){
            //쓰기 형태, 변환 N
            strTemplateType = "Write";
        }else{
            //읽기 형태, 변환 Y
            strTemplateType = "Read";
            bNeedConvert = true;
        }
        fileurl = filePath + strFormFileName + ".html";
        filename = strFormFileName + ".html";
        
        CoviMap ret = new CoviMap();
        ret.put("strTemplateType", strTemplateType);
        ret.put("fileurl", fileurl);
        ret.put("filename", filename);
        ret.put("bNeedConvert", bNeedConvert);
        
        return ret;
    }
	
	// ApprovalLine - 결재선
	public CoviMap setDomainData(String strReadMode, String strSessionUserID, String strSessionDeptID, String strProcessID, String isArchived, String bStored, String strParentProcessID, CoviMap schemaContext) throws Exception {
		// ApprovalLine
		CoviMap paramsDomain = new CoviMap();
		CoviMap domainData = new CoviMap();
		CoviMap parentDomainData = new CoviMap();
		CoviMap approvalLine = new CoviMap();
		CoviMap parentApprovalLine = new CoviMap();
		
		if (strReadMode.equals("DRAFT") || strReadMode.equals("TEMPSAVE") || strReadMode.equals("TEMPSAVE_BOX") || strReadMode.equals("PREDRAFT") || bStored.equalsIgnoreCase("true"))
        {
			CoviMap steps = new CoviMap();
			steps.put("status", "inactive");
			steps.put("initiatoroucode", strSessionDeptID);
			steps.put("initiatorcode", strSessionUserID);
			approvalLine.put("steps", steps);			
        }else{
			if(strProcessID != null && !strProcessID.equals("")){
				// 신청 프로세스 기준으로 분기
				String processType = ((CoviMap)schemaContext.get("pdef")).optString("value");
				if(isArchived.equals("true") && processType.indexOf("request") > -1) {
					if(!strParentProcessID.equals("0"))
						paramsDomain.put("processID", strParentProcessID);
					else
						paramsDomain.put("processID", strProcessID);
				} else {
					paramsDomain.put("processID", strProcessID);
				}
				
				paramsDomain.put("IsArchived", isArchived);					// Archive 가 있는 테이블은 반드시 넘겨야 함
				paramsDomain.put("bStored", bStored);
				domainData = (((CoviList)(formSvc.selectDomainData(paramsDomain)).get("list")).getJSONObject(0));
				
				if(!domainData.get("DomainDataContext").equals(""))
					approvalLine = domainData.getJSONObject("DomainDataContext");
				
				if(isArchived.equals("true") && processType.indexOf("request") == -1 && hasReviewerStep(approvalLine)){
					if(strParentProcessID.equals("0"))
						paramsDomain.put("processID", strProcessID);
					else
						paramsDomain.put("processID", strParentProcessID);
					
					parentDomainData = (((CoviList)(formSvc.selectDomainData(paramsDomain)).get("list")).getJSONObject(0));
					parentApprovalLine = parentDomainData.getJSONObject("DomainDataContext");
					
					// Parent - domaindata
					CoviMap s = new CoviMap();
					s = (CoviMap)parentApprovalLine.get("steps");
					
					Object divisionO = s.get("division");
					CoviList divisonArr = new CoviList();
					if(divisionO instanceof CoviMap){
						CoviMap divJsonObj = (CoviMap)divisionO;
						divisonArr.add(divJsonObj);
					} else {
						divisonArr = (CoviList)divisionO;
					}
					
					// Basic - domaindata
					s = (CoviMap)approvalLine.get("steps");
					
					divisionO = s.get("division");
					CoviList divs = new CoviList();
					if(divisionO instanceof CoviMap){
						CoviMap divJsonObj = (CoviMap)divisionO;
						divs.add(divJsonObj);
					} else {
						divs = (CoviList)divisionO;
					}
					
					// parent 기준으로 기안부서 데이터 덮어쓰기
					divs.remove(0);
					divs.add(0, divisonArr.get(0));
					
					s.put("division", divs);
				}
			}
        }
		
		return approvalLine;
	}
	
	//재사용시 검토자 삭제
	public CoviMap domainDataConsultDelete(CoviMap apvLineObj) throws Exception{
		CoviMap root = apvLineObj.getJSONObject("steps");
		Object divisionObj = root.get("division");
		CoviList divisions = new CoviList();
		if(divisionObj instanceof CoviMap){
			CoviMap divisionJsonObj = (CoviMap)divisionObj;
			divisions.add(divisionJsonObj);
		} else {
			divisions = (CoviList)divisionObj;
		}
		
		for(int i = 0; i < divisions.size(); i++)
		{
			CoviMap division = (CoviMap)divisions.get(i);
			
			Object stepO = division.get("step");
			CoviList steps = new CoviList();
			if(stepO instanceof CoviMap){
				CoviMap stepJsonObj = (CoviMap)stepO;
				steps.add(stepJsonObj);
			} else {
				steps = (CoviList)stepO;
			}
			
			for(int j = 0; j < steps.size(); j++)
			{
				CoviMap s = (CoviMap)steps.get(j);
				
				String unitType = (String)s.get("unittype");
				Object ouObj = s.get("ou");
				CoviList ouArray = new CoviList();
				if(ouObj instanceof CoviList){
					ouArray = (CoviList)ouObj;
				} else {
					ouArray.add((CoviMap)ouObj);
				}
					
				for(int z = 0; z < ouArray.size(); z++)
				{
					CoviMap ouObject = (CoviMap)ouArray.get(z);
					
					if(ouObject.containsKey("person") && unitType.equalsIgnoreCase("person")){
						Object personObj = ouObject.get("person");
						CoviList persons = new CoviList();
						if(personObj instanceof CoviMap){
							CoviMap jsonObj = (CoviMap)personObj;
							persons.add(jsonObj);
						} else {
							persons = (CoviList)personObj;
						}
						
						for(int pIdx = 0; pIdx < persons.size(); pIdx ++) {
							CoviMap personObject = (CoviMap)persons.get(pIdx);
							if(personObject.has("consultation"))
								personObject.remove("consultation");
						}
					}
				}
			}
		}
		return apvLineObj;
	}
	
	// 후결자 존재 여부 체크
	public boolean hasReviewerStep(CoviMap apvLineObj) {
		boolean ret = false;
		
		CoviMap root = (CoviMap)apvLineObj.get("steps");
		Object divisionObj = root.get("division");
		CoviList divisions = new CoviList();
		if(divisionObj instanceof CoviMap){
			CoviMap divisionJsonObj = (CoviMap)divisionObj;
			divisions.add(divisionJsonObj);
		} else {
			divisions = (CoviList)divisionObj;
		}
		
		CoviMap division = (CoviMap)divisions.get(0);
			
		Object stepO = division.get("step");
		CoviList steps = new CoviList();
		if(stepO instanceof CoviMap){
			CoviMap stepJsonObj = (CoviMap)stepO;
			steps.add(stepJsonObj);
		} else {
			steps = (CoviList)stepO;
		}
		
		String unitType = "";
		
		for(int i = 0; i < steps.size(); i++)
		{
			unitType = "";
			
			CoviMap s = (CoviMap)steps.get(i);
			
			unitType = (String)s.get("unittype");
			
			//jsonarray와 jsonobject 분기 처리
			Object ouObj = s.get("ou");
			CoviList ouArray = new CoviList();
			if(ouObj instanceof CoviList){
				ouArray = (CoviList)ouObj;
			} else {
				ouArray.add(ouObj);
			}
			
			for(int j = 0; j < ouArray.size(); j++)
			{
				CoviMap ouObject = (CoviMap)ouArray.get(j);
				CoviMap taskObject = new CoviMap();
				if(ouObject.containsKey("person") && unitType.equalsIgnoreCase("person")){
					Object personObj = ouObject.get("person");
					CoviList persons = new CoviList();
					if(personObj instanceof CoviMap){
						CoviMap jsonObj = (CoviMap)personObj;
						persons.add(jsonObj);
					} else {
						persons = (CoviList)personObj;
					}
					
					CoviMap personObject = (CoviMap)persons.get(0);
					taskObject = (CoviMap)personObject.get("taskinfo");
					
					//전달 처리
					if(taskObject.optString("kind").equalsIgnoreCase("conveyance")){
						CoviMap forwardedPerson = (CoviMap)persons.get(1);
						taskObject = (CoviMap)forwardedPerson.get("taskinfo");
					}
					
				} else if(ouObject.containsKey("role")) {
					CoviMap role = new CoviMap();
					role = (CoviMap)ouObject.get("role");
					taskObject = (CoviMap)role.get("taskinfo");
				} else {
					taskObject = (CoviMap)ouObject.get("taskinfo");
				}
				
				if(taskObject.optString("kind").equalsIgnoreCase("review")){
					ret = true;
					break;
				}	
			}	      
		}
		
		return ret;
	}
	
	// 자동결재선 세팅 함수 -> 추가적인 개발이 필요함
	public CoviMap setAutoDomainData(CoviMap autoApprovalLine, UserInfo formSession, String strFormTempInstanceID, String strReadMode, CoviMap scStep, String strFormPrefix, String strRequestFormInstID) throws Exception{
		// 양식 설정의 자동결재선
		autoApprovalLine = autoApprovalLineService.setFormAutoApprovalData(autoApprovalLine, formSession.getDNCode(), formSession.getUserRegionCode());
		
		// 양식 설정의 자동결재선 이외의 자동결재선		
		CoviMap autoDomainData = new CoviMap();
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
		CoviList selectData = new CoviList();
		
		// 임시저장 결재선 조회
		if(strFormTempInstanceID != null && !strFormTempInstanceID.equals("")){
			params.put("OwnerID", strFormTempInstanceID);
        	
        	returnData = (((CoviList)(formSvc.selectPravateDomainData(params)).get("list")).getJSONObject(0));
        	autoDomainData = returnData.getJSONObject("PrivateContext");
		}else{
			if(( (strReadMode.equals("DRAFT") && (strRequestFormInstID == null || strRequestFormInstID.equals(""))) || strReadMode.equals("TEMPSAVE")) ||  strReadMode.equals("REDRAFT")){
				// 주결재선 조회
				params.put("OwnerID", formSession.getUserID());
				params.put("DefaultYN", "Y");
            	
				selectData = (CoviList)(formSvc.selectPravateDomainData(params)).get("list");
            	if(!selectData.isEmpty()){
            		returnData = selectData.getJSONObject(0);
            		autoDomainData = returnData.getJSONObject("PrivateContext");
            	}
            	
				if(returnData.isNullObject() || returnData.isEmpty()){
					
					// 부서장 결재 단계 사용
					if (( strReadMode.equals("DRAFT") || strReadMode.equals("TEMPSAVE")) && scStep.optString("isUse").equals("Y") && !scStep.optString("value").equals("")){
						
						String[] aOUCodes = formSession.getDeptPath().split(";");
                        //다국어 처리를 위해 요청자 세션의 부서 명칭 가져옮
						String[] aOUNames = formSession.getGRFullName().split("@");
						int nStep = Integer.parseInt(scStep.getString("value"));
						
						int nCount = 0;
						CoviMap oSteps = new CoviMap();
						
						CoviList oStepArr = new CoviList();
						
						oSteps.put("status", "inactive");
						
						for (int i = aOUCodes.length - 1; i >= 0; i--)
						{
							if(!aOUCodes[i].equalsIgnoreCase("ORGROOT") && !(formSession.getURIsManager().equalsIgnoreCase("TRUE") && i == aOUCodes.length - 1)){				// TODO 부서장이 기안할 경우에는 자신이 포함된 부서를 제외해야 하며, ORGROOT 도 제외되어야 함
								nCount++;
								if (nCount <= nStep)
								{
									CoviMap oStep = new CoviMap();
									CoviMap oOu = new CoviMap();
									CoviMap oRole = new CoviMap();
									CoviMap oTaskInfo = new CoviMap();
									
										
										oStep.put("unittype", "role");
										oStep.put("routetype", "approve");
										oStep.put("name", "일반결재");
										
										oOu.put("code", aOUCodes[i]);
										oOu.put("name", aOUNames[i]);
										
										oRole.put("code", "UNIT_MANAGER");
										oRole.put("name", aOUNames[i]);
										oRole.put("oucode", aOUCodes[i]);
										oRole.put("ouname", aOUNames[i]);
										
										oTaskInfo.put("status", "inactive");
										oTaskInfo.put("result", "inactive");
										oTaskInfo.put("kind", "normal");
										
										oRole.put("taskinfo", oTaskInfo);
										
										oOu.put("role", oRole);
										
										oStep.put("ou", oOu);
										
										oStepArr.add(oStep);

								}
							}
						}

						oSteps.put("step", oStepArr);
						returnData.put("steps", oSteps);
						autoDomainData = returnData;
					}else{
						//양식별 개인 최종 결재선
						params.clear();
		            	
						if(strReadMode.equals("DRAFT")){
							params.put("OwnerID", formSession.getUserID() + "_" + strFormPrefix);
						}else if(strReadMode.equals("REDRAFT")){
							params.put("OwnerID", formSession.getUserID() + "_" + strFormPrefix + "_REDRAFT");
						}
						
						selectData = (CoviList)(formSvc.selectPravateDomainData(params)).get("list");
						if(!selectData.isEmpty()){
		            		returnData = selectData.getJSONObject(0);
		            		autoDomainData = returnData.getJSONObject("PrivateContext");
		            	}
					}
				}
			}
		}
        
		CoviMap returnObj = new CoviMap();
		returnObj.put("autoApprovalLine", autoApprovalLine);
		returnObj.put("autoDomainData", autoDomainData);
			
        return returnObj;
    }
	
	// 에디터
	public String getEditorControlSrc(String useHWPEditYN){
        String strEditorControlSrc = "";
        //0.TextArea, 1.DHtml, 2.TagFree, 3.XFree, 4.TagFree/XFree, 5.Activesquare, 6.CrossEditor, 7.ActivesquareDefault/CrossEditor
         if(useHWPEditYN.equals("Y")) {
        	strEditorControlSrc = "<script type=\"text/javascript\" src=\"/approval/resources/script/forms/WebEditor_Approval_HWP.js\"></script>";
        	strEditorControlSrc += "<script type=\"text/javascript\" src=\"/covicore/resources/script/Hwp/HwpToolbars.js\"></script>";
        	strEditorControlSrc += "<script type=\"text/javascript\" src=\"/covicore/resources/script/Hwp/HwpCtrl.js\"></script>";
        } else {
        	strEditorControlSrc = "<script type=\"text/javascript\" src=\"/approval/resources/script/forms/WebEditor_approval.js\"></script>";        	
        }
        return strEditorControlSrc;

    }
	
	//첨부파일 정보
	public CoviList getFileInfos(String strFormInstanceID) throws Exception{
		CoviList returnArr = new CoviList();
		
		CoviMap params = new CoviMap();
		params.put("ServiceType", "Approval");
		params.put("ObjectType", "DEPT");
		params.put("FormInstID", strFormInstanceID);
		
		returnArr =  (CoviList)(formSvc.selectFiles(params)).get("list");
			
		
		return returnArr;
	}
	
	public CoviList getStoreFileInfos(String strFormInstanceID) throws Exception{
		CoviList returnArr = new CoviList();
		
		CoviMap params = new CoviMap();
		params.put("ServiceType", "Approval");
		params.put("ObjectType", "DEPT");
		params.put("FormInstID", strFormInstanceID);
		
		returnArr =  (CoviList)(formSvc.selectStoreFiles(params)).get("list");
			
		
		return returnArr;
	}
	
	public String makeFormInfoForDev(CoviMap formJson) throws Exception{
        StringBuffer returnStr = new StringBuffer();
        
        returnStr.append("/*");
        returnStr.append("\n     * 이하 정보는 개발자 지원을 위한 결재 정보입니다.");
        returnStr.append("\n     * 운영시에는 숨기시기 바랍니다.");
        
        Iterator<?> keys = formJson.keys();

		while (keys.hasNext()) {
			String key = (String) keys.next();
			returnStr.append("\n     *     [" + key + "]");
			
			if(formJson.get(key) instanceof CoviMap){
				CoviMap jsonObj = formJson.getJSONObject(key);
				Iterator<?> inKeys = jsonObj.keys();
	
				while (inKeys.hasNext()) {
					String inKey = (String) inKeys.next();
					returnStr.append("\n     *     	" + inKey + " : " + jsonObj.optString(inKey));
				}
			}else{
				returnStr.append(" :      	" + formJson.optString(key));
			}
		}
        
        returnStr.append("*/");
        
        return returnStr.toString();
    }

	public String createAssistInfo(String assistInfo)
	{
		StringBuilder assistList = new StringBuilder();
		try {


			JSONParser jsonParser = new JSONParser();
	        CoviMap jsonObj = (CoviMap) jsonParser.parse(assistInfo);
	        CoviList stepArr = jsonObj.getJSONArray("step");

			assistList.append("<assist>");

			for (int i = 0; i < stepArr.size(); i++)
			{
				String order = "";
				if (i + 1 != stepArr.size())
				{
					order = Integer.toString(i + 1);
				}
				else
				{
					order = "final";
				}

				assistList.append("<order>");
				assistList.append(order);
				assistList.append("</order>");
				assistList.append("<signposition>");
				assistList.append(stepArr.getJSONObject(i).getJSONObject("ou").getJSONObject("person").getString("position"));
				assistList.append("</signposition>");
				assistList.append("<type>");
				assistList.append(stepArr.getJSONObject(i).getString("name"));
				assistList.append("</type>");
				assistList.append("<signimage>");
				assistList.append("");
				assistList.append("</signimage>");
				assistList.append("<name>");
				assistList.append(stepArr.getJSONObject(i).getJSONObject("ou").getString("name"));
				assistList.append("</name>");
				assistList.append("<date>");
				assistList.append(stepArr.getJSONObject(i).getJSONObject("ou").getJSONObject("person").getJSONObject("taskinfo").getString("datecompleted").split(" ")[0]);
				assistList.append("</date>");
				assistList.append("<time>");
				assistList.append(stepArr.getJSONObject(i).getJSONObject("ou").getJSONObject("person").getJSONObject("taskinfo").getString("datecompleted").split(" ")[1]);
				assistList.append("</time>");
			}

			assistList.append("</assist>");
			
		} catch(NullPointerException npE) {
			return npE.toString();
		} catch(Exception ex) {
			return ex.toString();
		}

		return assistList.toString();
	}
	
	// 결재자 서명이미지 가져오기
	@RequestMapping(value = "/user/getUserSignInfo.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getUserSignInfo(@RequestParam("UserCode") String userCode) throws Exception{
		CoviMap returnList = new CoviMap();
		
		try
		{    	
        	returnList.put("data", formSvc.selectUsingSignImageId(userCode));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 언어코드값 가져오기
	public static String getLngIdx()
	{
		String strLangID = "ko"; // 기본값
        if (SessionHelper.getSession("LanguageCode") != null)
        {
            strLangID = SessionHelper.getSession("LanguageCode");
        }
		String szReturn = "0";
		switch (strLangID.toUpperCase())
		{
			case "KO": szReturn = "0"; break;
			case "EN": szReturn = "1"; break;
			case "JA": szReturn = "2"; break;
			case "ZH": szReturn = "3"; break;
			case "KO-KR": szReturn = "0"; break;
			case "EN-US": szReturn = "1"; break;
			case "JA-JP": szReturn = "2"; break;
			case "ZH-CN": szReturn = "3"; break;
			default: szReturn = "0"; break;
		}
		return szReturn;
	}

	/**
	 * SerialApprovalForm - 연속결재 팝업 오픈
	 * @param locale Locale
	 * @param model Model
	 * @return ModelAndView
	 */
	@RequestMapping(value = "/approval_SerialApprovalForm.do", method = {RequestMethod.GET, RequestMethod.POST})
	public ModelAndView serialApprovalForm(Locale locale, Model model) throws Exception
	{
		String returnURL = "forms/SerialApprovalForm";
		return new ModelAndView(returnURL);
	}

	@RequestMapping(value = "/user/getDomainData.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getDomainData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviMap approvalLine = new CoviMap();
		
		try
		{
			String strProcessID = request.getParameter("ProcessID");
			
			CoviMap params = new CoviMap();
			
        	params.put("processID", strProcessID);
        	params.put("IsArchived", "false");					// Archive 가 있는 테이블은 반드시 넘겨야 함
        	
			CoviMap domainData = formSvc.selectDomainData(params).getJSONArray("list").getJSONObject(0);
			
			if(!domainData.get("DomainDataContext").equals(""))
				approvalLine = domainData.getJSONObject("DomainDataContext");

        	returnList.put("data", approvalLine);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	/**
	* @Method Name : getWorkedAutoDomainData
	* @Description : 양식별 최종결재선 조회
	*/
	@RequestMapping(value = "/getWorkedAutoDomainData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getWorkedAutoDomainData(HttpServletRequest request) throws Exception
	{
		CoviList selectData = new CoviList();
		CoviMap returnData = new CoviMap();
		CoviMap autoDomainData = new CoviMap();
		
		CoviMap returnObj = new CoviMap();
		
		try {
			CoviMap params = new CoviMap();
			
			String strFormPrefix = request.getParameter("strFormPrefix");
			String strExpAppID = request.getParameter("strExpAppID");
			
			if(strExpAppID == null || strExpAppID.equals("")) {
				params.put("OwnerID", SessionHelper.getSession("USERID") + "_" + strFormPrefix);
			} else {
				params.put("OwnerID", "ACCOUNT_" + strExpAppID);
			}
			
			selectData = (CoviList)(formSvc.selectPravateDomainData(params)).get("list");
			if(!selectData.isEmpty()){
        		returnData = selectData.getJSONObject(0);
        		autoDomainData = returnData.getJSONObject("PrivateContext");
        	}
			
			CoviMap paramsForms = new CoviMap();
			paramsForms.put("userID", SessionHelper.getSession("USERID"));
			paramsForms.put("formPrefix", strFormPrefix);
			CoviMap forms = (((CoviList)(formSvc.selectForm(paramsForms)).get("list")).getJSONObject(0));
			CoviMap autoApprovalLine = new CoviMap();
			if(!forms.get("AutoApprovalLine").equals("")) {
				autoApprovalLine = forms.getJSONObject("AutoApprovalLine");
				// 가공.
				autoApprovalLine = autoApprovalLineService.setFormAutoApprovalData(autoApprovalLine, SessionHelper.getSession("DN_Code"), SessionHelper.getSession("UR_RegionCode"));
			}
			
			returnObj.put("autoApprovalLine", autoApprovalLine); // 양식 자동결재선
			returnObj.put("autoDomainData", autoDomainData); // 직전결재선
			returnObj.put("result", "ok");
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	/**
	* @Method Name : getDataForCommentView
	* @Description : ApprovalLine + JWF_Comment
	*/
	@RequestMapping(value = "getDataForCommentView.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getApprovalLine(HttpServletRequest request) throws Exception
	{		
		CoviMap returnObj = new CoviMap();		
		try {
			CoviMap approvalLine = new CoviMap();
			CoviMap params = new CoviMap();

			String strFormInstID = request.getParameter("FormInstID");
			String strProcessID = request.getParameter("ProcessID");
			String isArchived = request.getParameter("archived");
			String bStored = request.getParameter("bstored");
			
			params.put("processID", strProcessID);
			params.put("IsArchived", isArchived);
			params.put("bStored", bStored);
			
			CoviMap domainData = (((CoviList)(formSvc.selectDomainData(params)).get("list")).getJSONObject(0));
			if(!domainData.get("DomainDataContext").equals("")) {
				approvalLine = domainData.getJSONObject("DomainDataContext");
			}
			
			params.clear();
			params.put("FormInstID", strFormInstID);
			params.put("bStored", bStored);
			CoviList comment = (CoviList)(formSvc.selectComment(params)).get("list");
			
			returnObj.put("ApprovalLine", ComUtils.changeCommentFileInfos(approvalLine));
			returnObj.put("JWF_Comment", comment);
			
			returnObj.put("result", "ok");
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	// 대외공문 변환
	//@SuppressWarnings("deprecation")
	//"/user/getDocTransfer.do"
	// 미사용
	@RequestMapping(value = "/user/saveHWPBody.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap saveHWPBody(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception{

		CoviMap returnList = new CoviMap();
		FileOutputStream fos = null;
		try
		{
			String encodingBody = request.getParameter("body");
			String fileName = request.getParameter("fileNm");
			
			Base64 decoder = new Base64();
			byte[] decodedBytes = decoder.decode(encodingBody);
			String companyCode = SessionHelper.getSession("DN_Code");
			String serviceType = "ApprovalHWPDoc";
			CoviMap storageInfo = FileUtil.getStorageInfo(serviceType,companyCode);
			//String serverPath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code"));
			//serverPath = serverPath + RedisDataUtil.getBaseConfig("ApprovalHWPDoc_SavePath");//ApprovalAttach_SavePath
			String serverPath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + storageInfo.optString("FilePath").replace("{0}", companyCode);
			
			if(!AwsS3.getInstance().getS3Active(companyCode)){
				File realUploadDir = new File(serverPath);

				if (!realUploadDir.exists()) {
					if (realUploadDir.mkdirs()) {
						LOGGER.info("saveHWPBody : realUploadDir mkdirs();");
					}
				}
			}
			
			fos = new FileOutputStream(FileUtil.checkTraversalCharacter(serverPath + fileName));
			fos.write(decodedBytes);
			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "파일저장 성공");
		} catch(IOException ioE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", ioE.getMessage());
		} catch(NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", npE.getMessage());
		} catch(Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		} finally {
			if(fos != null) {
				try {
					fos.close();
				} catch (IOException e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				} catch(Exception e) {
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		}
		
		return returnList;
	}

	/**
	* @Method Name : downloadMHT
	* @Description : 이관문서 mht 파일인 경우 mht 다운으로 변경
	*/
	@RequestMapping(value = "/downloadMHT.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap downloadMHT(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnObj = new CoviMap();

		String rootPath = FileUtil.getBackPath();
		String fileName = paramMap.get("fileName");
		String path = paramMap.get("path");
		String type = paramMap.get("type");
		AwsS3 awsS3 = AwsS3.getInstance();
		try {
			File file = null;
			if (type.equals("Mail")) {
				returnObj.put("fileName", fileName + ".mht");
				if(awsS3.getS3Active()) {
					String key = rootPath + path.replace("/GWStorage/", "");
					AwsS3Data awsS3Data = awsS3.downData(key);
					returnObj.put("saveFileName", awsS3Data.getName());
					returnObj.put("savePath", awsS3Data.getParentPath());
					returnObj.put("fileSize", awsS3Data.getLength());
				}else {
					file = new File(rootPath + path.replace("/GWStorage/", ""));
					returnObj.put("saveFileName", file.getName());
					returnObj.put("savePath", file.getParentFile().toString());
					returnObj.put("fileSize", file.length());
				}
				returnObj.put("status", Return.SUCCESS);
			} else {
				response.setContentType("message/rfc822");
				response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode(fileName, "UTF-8").replace("+", " ") + ".mht" + "\"");
				if(awsS3.getS3Active()) {
					String key = rootPath + path.replace("/GWStorage/", "");
					AwsS3Data awsS3Data = awsS3.downData(key);
					response.setContentLength((int)awsS3Data.getLength());
					try(InputStream fis = awsS3Data.getContentStream()){
						StreamUtils.copy(fis, response.getOutputStream());
					}
					
				}else{
					file = new File(rootPath + path.replace("/GWStorage/", ""));
					response.setContentLength((int)file.length());
					try(InputStream fis = new FileInputStream(file)){
						StreamUtils.copy(fis, response.getOutputStream());
					}
				}

			}
		} catch (IOException ioE) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message",
					isDevMode.equalsIgnoreCase("Y") ? ioE.getMessage()
							: DicHelper.getDic("msg_apv_030"));
		} catch (NullPointerException npE) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message",
					isDevMode.equalsIgnoreCase("Y") ? npE.getMessage()
							: DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message",
					isDevMode.equalsIgnoreCase("Y") ? e.getMessage()
							: DicHelper.getDic("msg_apv_030"));
		}
		return returnObj;
	}
	
	@RequestMapping(value = "/user/getCachedFormExtInfo.do", method = {RequestMethod.POST})
	public @ResponseBody CoviMap getCachedFormExtInfo(HttpServletRequest request, @RequestParam Map<String, String> paramMap) {
		CoviMap returnList = new CoviMap();
		try {
			String strFormID = paramMap.get("FormID");
			String strFormPrefix = paramMap.get("FormPrefix");
        	
			CoviMap extInfo = formSvc.getCachedFormExtInfo(strFormID, strFormPrefix);

        	returnList.put("result", extInfo);
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch(NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch(Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	/**
	* @Description : 문서24 개인회신시 문서연결
	*/
	@RequestMapping(value = "/govDocs/docLink.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap gov24DocLink(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();

		try {
			String formInstId = request.getParameter("formInstId");
			returnObj = formSvc.selectgov24DocLink(formInstId).getJSONArray("list").getJSONObject(0);
		} catch (NullPointerException npE) {
			returnObj.put("status", Return.FAIL);
			throw npE;
		} catch (Exception e) {
			returnObj.put("status", Return.FAIL);
			throw e;
		}
		return returnObj;
	}
	
	@RequestMapping(value = "/approval_CstfForm.do", method = {RequestMethod.GET, RequestMethod.POST}) 
	public ModelAndView goCstfFormPage(HttpServletRequest request, Locale locale, Model model) throws Exception {
		ModelAndView mav = new ModelAndView();

		//변수 초기화
		boolean successYN = true;
		String errorMsg = "";
		String strLangIndex = "";
		
        String strMenuTempl = "";
		String strTopTempl = "";
		String strApvLineTempl = "";
		String strCommonFieldsTempl = "";
		String strHeaderTempl = "";
		String strBodyTempl = "";
		String strBodyTemplJS = "";
		String strFooterTempl = "";
		String strEditorSrc = "";
		String strAttachTempl = "";
		String isApvLineChanged = "N";
		String strFormFavoriteYN = "N";
    	String strUseMultiEditYN = "N";
    	String strUseHWPEditYN = "N";
    	String strUseWebHWPEditYN = "N";
		String formJsonForDev = "";
		String formDraftkey = "";
		
		CoviMap formJson = new CoviMap();
		
		try{
			// 초기 변수값 설정
			FormRequest formRequest = initFormRequest(request);
			formRequest.setReadMode("DRAFT");
			formRequest.setCstfRevID(StringUtil.replaceNull(request.getParameter("cstfRevID"), "")); // 양식스토어 아이디
			UserInfo userInfo = initUserInfo();

			//다국어 언어설정
			strLangIndex = getLngIdx();
			
			String returnURL = "forms/Form";
			mav.setViewName(returnURL);			
			
        	//JSONObject procData = new CoviMap();	
        	//JSONObject processObj = null;
        	
			/* 처리
			 *  - Form Data 생성
			 *  - Template 삽입처리
			 *  - 자동 결재선 Data 생성
			*/ 
        	// 양식 파일 경로
        	String formCompanyCode = null;
        	if("Y".equals(isSaaS)) {
        		formCompanyCode = "ORGROOT";
        	}
        	String filePath = ApprovalUtil.getTemplatePath(formCompanyCode);
        	
			// Form Data 생성
            CoviMap formJsonRet = createCstfFormJSON(formRequest, userInfo);
            
            formJson = formJsonRet.getJSONObject("formJson");      
          //formRequest = (FormRequest) CoviMap.toBean(formJsonRet.getJSONObject("formRequest"), FormRequest.class);
            formRequest = (FormRequest) formJsonRet.get("formRequest");
            
            CoviMap initializedValueForTemplate = formJsonRet.getJSONObject("initializedValueForTemplate");
            
			//Template 삽입 처리
            strMenuTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormMenu.html", "UTF8").trim();
            	
           
            // (본사운영) 대외공문일 경우 다른 Header 사용
            Boolean bNeedConvert = initializedValueForTemplate.getBoolean("bNeedConvert");
            strHeaderTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, filePath+"common/FormHeader.html", "UTF8"), bNeedConvert);
            strFooterTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormFooter.html", "UTF8");
            strApvLineTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormApvLine.html", "UTF8");
			strCommonFieldsTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormCommonFields.html", "UTF8");
			strBodyTempl = convertWriteHtmlToRead(formFileCacheSvc.readAllText(lang, initializedValueForTemplate.getString("fileurl"), "UTF8"), bNeedConvert);
			//strBodyTemplJS = formFileCacheSvc.readAllText(lang, filePath + formJsonRet.getString("strFormFileName") + ".js", "UTF8");
			
			//첨부, 에디터 관련 삽입
            if (initializedValueForTemplate.optString("strTemplateType").equals("Write") || strUseMultiEditYN.equals("Y") || strUseHWPEditYN.equals("Y") || strUseWebHWPEditYN.equals("Y"))
            {	            		
                // 에디터 관련 스크립트 삽입
        		strEditorSrc = getEditorControlSrc(strUseHWPEditYN);

                if(initializedValueForTemplate.optString("strTemplateType").equals("Write")) {
	                // 첨부 template 삽입
	                strAttachTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormAttach.html", "UTF8");
	        		
	                if(strUseMultiEditYN.equals("Y")) {
	        			strAttachTempl = formFileCacheSvc.readAllText(lang, filePath+"common/FormAttachMulti.html", "UTF8");
	        		}
                }
            }
        	//결재선 변경 여부
        	isApvLineChanged = formRequest.getIsApvLineChg();
		} catch(SecurityException securityException) {
			LOGGER.warn("FormCon", securityException);
			LoggerHelper.errorLogger(securityException, "egovframework.covision.coviflow.form.web.FormCon.goCommonFormPage", "CON");
			errorMsg = securityException.getMessage();
			successYN = false;
		} catch(NoSuchElementException noSuchElementException) {
			errorMsg = noSuchElementException.getMessage();
			successYN = false;
		} catch(NullPointerException npE){
			LOGGER.error("FormCon", npE);
			LoggerHelper.errorLogger(npE, "egovframework.covision.coviflow.form.web.FormCon.goCommonFormPage", "CON");
			
			successYN = false;
			errorMsg = DicHelper.getDic("msg_apv_formLoadErrorMsg");
		} catch(Exception e){
			LOGGER.error(e.getLocalizedMessage(), e);
			LoggerHelper.errorLogger(e, "egovframework.covision.coviflow.form.web.FormCon.goCommonFormPage", "CON");
			
			successYN = false;
			errorMsg = DicHelper.getDic("msg_apv_formLoadErrorMsg");
		}
		
		AES aes = new AES("", "N");
        formDraftkey = aes.encrypt(formDraftkey);
		
		mav.addObject("strMenuTempl", strMenuTempl);
		mav.addObject("strTopTempl", strTopTempl);
		mav.addObject("strApvLineTempl", strApvLineTempl);
		mav.addObject("strCommonFieldsTempl", strCommonFieldsTempl);
		mav.addObject("strHeaderTempl", strHeaderTempl);
		mav.addObject("strBodyTempl", strBodyTempl);
		mav.addObject("strBodyTemplJS", strBodyTemplJS);
		mav.addObject("strFooterTempl", strFooterTempl);
		mav.addObject("strAttachTempl", strAttachTempl);
		mav.addObject("strEditorSrc", strEditorSrc);
		mav.addObject("formJson", new String(Base64.encodeBase64(formJson.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8));
		mav.addObject("formJsonForDev", formJsonForDev);
		mav.addObject("strFormFavoriteYN", strFormFavoriteYN);
		mav.addObject("strApvLineYN", isApvLineChanged);
		mav.addObject("strUseMultiEditYN", strUseMultiEditYN);
		mav.addObject("formDraftkey", formDraftkey);
		mav.addObject("strErrorMsg", errorMsg);
		mav.addObject("strSuccessYN", successYN);
		mav.addObject("strLangIndex", strLangIndex);
		mav.addObject("AppName", appName); // 양식팝업 헤더명
		mav.addObject("useFido", PropertiesUtil.getSecurityProperties().getProperty("fido.login.used"));
		mav.addObject("isCSTFPreview", "Y"); // 양식스토어 미리보기 여부
		return mav;
	}
	
	public CoviMap createCstfFormJSON(FormRequest formRequest, UserInfo userInfo) throws Exception{
		CoviMap ret = new CoviMap();
		
        CoviMap forms = new CoviMap();
        CoviMap extInfo = new CoviMap();
        String strFormFileName = null;
        CoviMap schemaContext = new CoviMap();	
        String strReadMode = formRequest.getReadMode();
		String cstfRevID = formRequest.getCstfRevID(); // 양식스토어 아이디
		String strCSTFFilePath = ""; // html파일 path
		
		// set forminfo
		forms = getCstfFormInfo(cstfRevID);
		strCSTFFilePath = forms.optString("CSTFFilePath");
		formRequest.setFormPrefix(forms.optString("FormPrefix"));
		strFormFileName = forms.optString("FileName").substring(0, forms.optString("FileName").lastIndexOf("."));
		forms.remove("CSTFFilePath");
		if(forms.has("ExtInfo")){
			extInfo = forms.getJSONObject("ExtInfo");
		}
		forms.remove("ExtInfo");
		
		//set SchemaContext
		schemaContext = getCstfSchemaContext();
		
		// ApprovalLine
		CoviMap approvalLine = null;
		approvalLine = setDomainData(strReadMode, userInfo.getUserID(), userInfo.getDeptID(), formRequest.getProcessID(), formRequest.getArchived(), formRequest.getBstored(), formRequest.getParentProcessID(), schemaContext);
		
		// Request
		CoviMap requestData = new CoviMap();
		/* loct 포함 -> CheckLoct()함수 값 */
		requestData.put("editmode", formRequest.getEditMode());
		requestData.put("admintype", formRequest.getAdmintype());
		requestData.put("isAuth", formRequest.getIsAuth());
		requestData.put("mode", strReadMode);
		requestData.put("processID", formRequest.getProcessID());
		requestData.put("workitemID", formRequest.getWorkitemID());
		requestData.put("performerID", formRequest.getPerformerID());
		requestData.put("userCode", formRequest.getUserCode());
		requestData.put("gloct", formRequest.getGLoct());
		requestData.put("formID", formRequest.getFormId());
		requestData.put("forminstanceID", formRequest.getFormInstanceID());
		requestData.put("subkind", formRequest.getSubkind());
		requestData.put("formtempID", formRequest.getFormTempInstanceID());
		requestData.put("forminstancetablename", formRequest.getFormInstanceTableName());
		requestData.put("readtype", formRequest.getReadtype());
		requestData.put("processdescriptionID", formRequest.getProcessdescriptionID());
		requestData.put("reuse", formRequest.getIsReuse());
		requestData.put("ishistory", formRequest.getIsHistory());
		requestData.put("usisdocmanager", formRequest.getIsUsisdocmanager());
		requestData.put("secdoc", formRequest.getIsSecdoc());
		requestData.put("isCSTF", "Y");
		requestData.put("isLegacy", "N");
		requestData.put("isTempSaveBtn", formRequest.getIsTempSaveBtn());
		requestData.put("legacyDataType", formRequest.getLegacyDataType());
		CoviMap initializedValueForTemplate = pInitValueForTemplate(strReadMode, formRequest.getReadtype(), formRequest.getEditMode(), strFormFileName, "Y", strCSTFFilePath);
		requestData.put("templatemode", initializedValueForTemplate.getString("strTemplateType"));
		requestData.put("loct", strReadMode);
		requestData.put("isMobile", formRequest.getIsMobile());
		//문서유통 유형 비교를 위해 추가
		requestData.put("menukind", formRequest.getMenuKind());
		requestData.put("doclisttype", formRequest.getDoclisttype());
		requestData.put("govstate", formRequest.getGovState());
		requestData.put("govdocid", formRequest.getGovDocID());
		requestData.put("cstfRevID", cstfRevID);
		
		// 기록물 다안 권한처리를 위해 추가
		requestData.put("govrecordid", formRequest.getGovRecordID());
		requestData.put("govrecordrowseq", formRequest.getGovRecordRowSeq());
		
		// AppInfo - Session, 기타 등
		CoviMap appInfo = new CoviMap();
		appInfo.put("usid", userInfo.getUserID());
		appInfo.put("usnm", userInfo.getUserName());
		appInfo.put("dpid", userInfo.getDeptID());
		appInfo.put("dpnm", userInfo.getDeptName());
		appInfo.put("dpid_apv", userInfo.getApvDeptID());				
		appInfo.put("dpdn_apv", userInfo.getApvDeptName());	
		appInfo.put("etnm", userInfo.getDNName());
		appInfo.put("etid", userInfo.getDNCode());
		appInfo.put("ussip", userInfo.getUserMail());				// 임의. 이메일 주소
		appInfo.put("sabun",  userInfo.getUserEmpNo());										// 사번
		appInfo.put("uspc", userInfo.getJobPositionCode());		// 직위 코드
		appInfo.put("uspn", userInfo.getJobPositionName());		// 직위 명
		appInfo.put("ustc", userInfo.getJobTitleCode());				// 직책 명
		appInfo.put("ustn", userInfo.getJobTitleName());				// 직책 코드
		appInfo.put("uslc", userInfo.getJobLevelCode());				// 직급 명
		appInfo.put("usln", userInfo.getJobLevelName());			// 직급 코드
		appInfo.put("grpath", userInfo.getDeptPath());
		appInfo.put("grfullname", userInfo.getGRFullName()); 			//dppathdn
		appInfo.put("managercode", userInfo.getURManagerCode());
		appInfo.put("managername", userInfo.getURManagerName());
		appInfo.put("usismanager", userInfo.getURIsManager());
		appInfo.put("hasWriteAuth",userInfo.isHasWriteAuth());
		String dateFormat = "yyyy-MM-dd HH:mm:ss";
		appInfo.put("svdt", DateHelper.getCurrentDay(dateFormat));
		// GMT 기준시간 추가
		if(!RedisDataUtil.getBaseConfig("useTimeZone").equalsIgnoreCase("Y")) {
			appInfo.put("svdt_TimeZone", DateHelper.getCurrentDay(dateFormat));
		}
		else { // 타임존 사용하는 경우
			SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
			sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
			appInfo.put("svdt_TimeZone", sdf.format(new Date()));	
		}
		appInfo.put("usit", userInfo.getUserSignFileID());			// 서명이미지
		appInfo.put("usnm_multi", userInfo.getUserMultiName());
		appInfo.put("uspn_multi", userInfo.getUserMultiJobPositionName());
		appInfo.put("ustn_multi", userInfo.getUserMultiJobTitleName());
		appInfo.put("usln_multi", userInfo.getUserMultiJobLevelName());
		appInfo.put("dpnm_multi", userInfo.getDeptMultiName());
		//appInfo.put("ustp", SessionHelper.getSession("PhoneNumber"));
		//appInfo.put("usfx", SessionHelper.getSession("Fax"));
		appInfo.put("ustp", userInfo.getUserPhoneNumber());
		appInfo.put("usfx", userInfo.getUserFax());
		// BaseConfig
		CoviMap baseConfig = new CoviMap();
		baseConfig.put("editortype", RedisDataUtil.getBaseConfig("EditorType"));
		
		CoviMap formJson = new CoviMap();
		formJson.put("FormInfo", forms);
		formJson.put("FormInstanceInfo", new CoviMap());
		formJson.put("ProcessInfo", new CoviMap());				// process 및 workitem 조합 데이터
		//formJson.("ProcessInfo", processDesObj);			// process description 데이터
		formJson.put("SchemaContext", schemaContext);
		formJson.put("BodyContext", new CoviMap());
		formJson.put("BodyData", new CoviMap());
		formJson.put("ApprovalLine", ComUtils.changeCommentFileInfos(approvalLine));
		formJson.put("ExtInfo", extInfo);
		formJson.put("SubTableInfo", new CoviMap());
		formJson.put("AutoApprovalLine", new CoviMap());
		formJson.put("WorkedAutoApprovalLine", new CoviMap());
		formJson.put("JWF_Comment", new CoviList());
		formJson.put("Request", requestData);
		formJson.put("AppInfo", appInfo);
		formJson.put("BaseConfig", baseConfig);
		formJson.put("FileInfos", new CoviList());
		
		ret.put("formJson", formJson);
		ret.put("formRequest", formRequest);
		ret.put("strFormFavoriteYN", "N");
		ret.put("initializedValueForTemplate", initializedValueForTemplate);
		ret.put("strFormFileName", strFormFileName);
		return ret;
	}
	
	public CoviMap getCstfFormInfo(String cstfRevID) throws Exception{
		CoviMap ret = new CoviMap();
		CoviMap cstfInfo = new CoviMap();
		CoviMap extInfo = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("StoredFormRevID", cstfRevID);
		cstfInfo = (((CoviList)(formSvc.selectCstfInfo(params)).get("list")).getJSONObject(0));
		
		String companyCode = cstfInfo.optString("CompanyCode").equals("") ? SessionHelper.getSession("DN_Code") : cstfInfo.optString("CompanyCode");
		String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + cstfInfo.optString("FullPath");
		
		extInfo.put("DocClassName","");
		extInfo.put("DocClassID","");
		
		ret.put("IsFavorite","N");
		ret.put("FileName",cstfInfo.optString("SavedName"));
		ret.put("CSTFFilePath",filePath);
		ret.put("FormName",cstfInfo.optString("FormName"));
		ret.put("FormPrefix",cstfInfo.optString("FormPrefix"));
		ret.put("BodyDefault","");
		
		ret.put("ExtInfo",extInfo);
		
		return ret;
	}
	
	public CoviMap getCstfSchemaContext(){
		CoviMap ret = new CoviMap();
		
		ret.put("scCMB",makeSchemaContextItem("N", "string", "", ""));
		ret.put("scApvLineType",makeSchemaContextItem("Y", "string", "2", ""));
		
		return ret;
	}
	
	public CoviMap makeSchemaContextItem(String sIsUse, String sType, String sValue, String sDesc) {
		CoviMap ret = new CoviMap();
		ret.put("isUse",sIsUse);
		ret.put("type",sType);
		ret.put("value",sValue);
		ret.put("desc",sDesc);
		return ret;
	}

	/**
	 * 마이그레이션 덤프파일 보기
	 * /approval/MigBody.do?companycode=GENERAL&type=ApprovalMig&file=Body/mig_pdf_sample.pdf
	 * @param response
	 * @param request
	 * @throws Exception
	 */
	@RequestMapping(value = "/MigBody.do", method = {RequestMethod.GET, RequestMethod.POST})
	public void viewMigBody(HttpServletResponse response, HttpServletRequest request) throws Exception {
		// /gwstorage/ + GENERAL/newcovistorage/ApprovalMig/ + Body/mig_pdf_sample.pdf
		String sFile = StringUtil.replaceNull(request.getParameter("file")); // Body/mig_pdf_sample.pdf
		String sType = StringUtil.replaceNull(request.getParameter("type"), "ApprovalMig"); // ApprovalMig
		String companyCode = StringUtil.replaceNull(request.getParameter("companycode"), SessionHelper.getSession("DN_Code")); // GENERAL
		String filePath = "";
		
		CoviMap storageInfo = FileUtil.getStorageInfo(sType,companyCode);
		String backServicePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + storageInfo.optString("FilePath").replace("{0}", companyCode);		
		String fileExtension = sFile.substring(sFile.lastIndexOf(".") + 1);

		filePath = backServicePath +  sFile;
		if(filePath.indexOf("GWStorage/FrontStorage/")>-1){
			filePath = filePath.replace("GWStorage/FrontStorage/","FrontStorage/");
		}
		fileUtilSvc.loadFileByPath(response, companyCode, filePath, fileExtension);
	}
	
	/**
	* @Description : 문서유통 본문 저장
	*/
	@RequestMapping(value = "/govDocs/updateDocHWP.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap updateDocHWP(HttpServletRequest request) throws Exception {
		CoviMap returnObj = new CoviMap();
		
		try
		{
			String FormInstID = request.getParameter("FormInstID");
			String BodyContext = StringUtil.replaceNull(request.getParameter("BodyContext"), "");
			
			if(!BodyContext.equals("") && formSvc.updateDocHWP(FormInstID, BodyContext) > 0) {
				returnObj.put("status", Return.SUCCESS);
				returnObj.put("message", "HWP저장 성공");
			} else {
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "[ERROR]BodyContext : " + BodyContext);
			}
		} catch(NullPointerException npE) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", npE.getMessage());
		} catch(Exception e) {
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", e.getMessage());
		}
		
		return returnObj;
	}
}