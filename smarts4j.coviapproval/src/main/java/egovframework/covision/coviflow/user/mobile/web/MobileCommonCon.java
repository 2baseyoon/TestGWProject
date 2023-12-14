package egovframework.covision.coviflow.user.mobile.web;

import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ACLHelper;
import egovframework.covision.coviflow.approvalline.service.AutoApprovalLineService;
import egovframework.covision.coviflow.common.util.ApprovalUtil;
import egovframework.covision.coviflow.common.util.ComUtils;
import egovframework.covision.coviflow.form.dto.FormRequest;
import egovframework.covision.coviflow.form.dto.UserInfo;
import egovframework.covision.coviflow.form.service.FormAuthSvc;
import egovframework.covision.coviflow.form.service.FormFileCacheSvc;
import egovframework.covision.coviflow.form.service.FormSvc;
import egovframework.covision.coviflow.legacy.service.ForLegacySvc;
import egovframework.covision.coviflow.user.mobile.service.MobileApprovalListSvc;



@Controller
@RequestMapping("/mobile")
public class MobileCommonCon {

	private Logger LOGGER = LogManager.getLogger(MobileCommonCon.class);
	
	@Autowired
	private FormFileCacheSvc formFileCacheSvc;
	
	@Autowired
	private FormSvc formSvc;

	@Autowired
	private FormAuthSvc formAuthSvc;
	
	@Autowired
	private MobileApprovalListSvc mobileApprovalListSvc;
	
	@Autowired
	private ForLegacySvc forLegacySvc;
	
	@Autowired
	private AutoApprovalLineService autoApprovalLineService;
	
	@Autowired
	private FileUtilService fileUtilSvc;
	
	// Thread-safe patch
//	private boolean successYN;
//	private String errorMsg;
//	private String strTopTempl = "";
//	private String strApvLineTempl = "";
//	private String strCommonFieldsTempl = "";
//	private String strHeaderTempl = "";
//	private String strBodyTempl = "";
//	private String strBodyTemplJS = "";
//	private String strFooterTempl = "";
//	private String strEditorSrc = "";
//	private String strApvLineYN = "N";
//	private CoviList processdes;
//	private CoviList forminstance;
	
	final String osType = PropertiesUtil.getGlobalProperties().getProperty("Globals.OsType");
	final String domainName = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path");
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	final String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS");	
	
//	String filePath = "";
//	String formCompanyCode = "";
//	public String strLangIndex = "0";
	
//    CoviMap formJson = new CoviMap();

	/*
	 *  layout/tiles 처리 시작
	 * 
	 * 
	 */

	//(tiles-left) 햄버거/좌측 메뉴 표시를 위해 메뉴 목록을 조회해서 넘김 
	@RequestMapping(value = "layout/left.do", method = RequestMethod.GET)
	public ModelAndView getLeft(HttpServletRequest request, HttpServletResponse response) throws Exception {
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		JSONSerializer jUtil = new JSONSerializer();
		String domainId = userDataObj.getString("DN_ID");
		
		String menu = ACLHelper.getMenu(userDataObj);
		
		String isAdmin = "N";
		String menuType = "Top";
		String memberOf = "0";

		CoviList menuArray = null;
		CoviList queriedMenu = null;
		if (StringUtils.isNoneBlank(menu)) {
			menuArray = jUtil.jsonGetObject(menu);
			queriedMenu = ACLHelper.parseMenu(domainId, isAdmin, menuType, memberOf, menuArray, "M");
		}

		String returnURL = "mobile/MobileLeft";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("MenuData", queriedMenu);
		
		return mav;
	}
	
	//(tiles-content) 상단 메뉴 목록을 조회해서 넘김(list만)
	@RequestMapping(value = "/{programName}/go{pageName}.do", method = RequestMethod.GET)
	public ModelAndView getTopMenu(HttpServletRequest request, HttpServletResponse response,
			@PathVariable String programName,
			@PathVariable String pageName) throws Exception {
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);
		
		String domainId = userDataObj.getString("DN_ID");
		String returnURL = "mobile/" + programName + "/" + pageName;
		String hasTopMenu = RedisDataUtil.getBaseConfig("hasTopMenu", domainId);
		if(StringUtils.isBlank(hasTopMenu)) {
			hasTopMenu = "";
		}
		
		ModelAndView mav = new ModelAndView(returnURL);
		if(hasTopMenu.indexOf(programName + "/" + pageName) > -1) {
			mav.addObject("Menu", getTopMenuList(programName, userDataObj));
		}
		
		if(RedisDataUtil.getBaseConfig("UseWaterMark", domainId).equals("Y")) {
			//워터마크 추가
			String userCode = userDataObj.getString("USERID");
			SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
			String date = formatter.format(new Date());
			String watermark_data = userCode + " " + date;
			
			mav.addObject("WaterMark", watermark_data);
		}
				
		String strLangIndex = getLngIdx();
		if(pageName.equals("view") || pageName.equals("preview")) {
			// Thread-safe 개선
			CoviMap formInfo = new CoviMap();
			getFormInfo(request, formInfo);
			CoviMap formJson = formInfo.getJSONObject("formJson");
			CoviList processdes = formInfo.getJSONArray("processdes");
			if(processdes == null) {
				processdes = new CoviList();
			}
			CoviList forminstance = formInfo.getJSONArray("forminstance");
			if(forminstance == null) {
				forminstance = new CoviList();
			}
			String errorMsg = formInfo.optString("errorMsg");
			boolean successYN = formInfo.optBoolean("successYN");
			
			String strTopTempl = formInfo.optString("strTopTempl");
			String strApvLineTempl = formInfo.optString("strApvLineTempl");
			String strCommonFieldsTempl = formInfo.optString("strCommonFieldsTempl");
			String strHeaderTempl = formInfo.optString("strHeaderTempl");
			String strBodyTempl = formInfo.optString("strBodyTempl");
			String strBodyTemplJS = formInfo.optString("strBodyTemplJS");
			String strFooterTempl = formInfo.optString("strFooterTempl");
			String strEditorSrc = formInfo.optString("strEditorSrc");
			String strApvLineYN = formInfo.optString("strApvLineYN", "N");
			
			mav.addObject("processdesJson", processdes.toString());
			mav.addObject("forminstanceJson", forminstance.toString());
			
			mav.addObject("strTopTempl", strTopTempl);
			mav.addObject("strApvLineTempl", strApvLineTempl);
			mav.addObject("strCommonFieldsTempl", strCommonFieldsTempl);
			mav.addObject("strHeaderTempl", strHeaderTempl);
			mav.addObject("strBodyTempl", strBodyTempl);
			mav.addObject("strBodyTemplJS", strBodyTemplJS);
			mav.addObject("strFooterTempl", strFooterTempl);
			mav.addObject("strEditorSrc", strEditorSrc);
			mav.addObject("formJson", new String(Base64.encodeBase64(formJson.toString().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
			mav.addObject("strApvLineYN", strApvLineYN);			
			
			mav.addObject("strErrorMsg", errorMsg);
			mav.addObject("strSuccessYN", successYN);
			
			mav.addObject("strLangIndex", strLangIndex);
		}
		else if(pageName.equals("write")) {
			mav.addObject("strLangIndex", strLangIndex);
		}
		
		mav.addObject("useFIDO", PropertiesUtil.getSecurityProperties().getProperty("fido.login.used"));
		mav.addObject("aesSalt", PropertiesUtil.getSecurityProperties().getProperty("aes.login.salt"));
		mav.addObject("aesIv", PropertiesUtil.getSecurityProperties().getProperty("aes.login.iv"));
		mav.addObject("aesKeysize", PropertiesUtil.getSecurityProperties().getProperty("aes.login.keysize"));
		mav.addObject("aesIterationCount", PropertiesUtil.getSecurityProperties().getProperty("aes.login.iterationCount"));
		mav.addObject("aesPassPhrase", PropertiesUtil.getSecurityProperties().getProperty("aes.login.passPhrase"));
		
		return mav;
	}
	
	/*
	 *  layout/tiles 처리 끝
	 * 
	 * 
	 */
	
	
	// 일반 페이지 호출 처리 
	// ex> /mobile/board/list.do 
	//       => /mobile/board/list.mobile
	//       => /WEB-INF/views/mobile/board/list.jsp
	@RequestMapping(value = "/{programName}/{pageName}.do", method = RequestMethod.GET)
	public ModelAndView getContent(HttpServletRequest request, HttpServletResponse response, 
				@PathVariable String programName, 
				@PathVariable String pageName) {
			
		String returnURL = "mobile/" + programName.toLowerCase() + "/" + pageName + ".mobile";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("QueryString", request.getQueryString());
	
		return mav;
	}
	
	
	// 작성페이지 테스트 
	@RequestMapping(value = "/{programName}/write_load.do", method = RequestMethod.GET)
	public ModelAndView getContentNoInclude(HttpServletRequest request, HttpServletResponse response, 
				@PathVariable String programName) {
			
		String returnURL = "mobile/" + programName.toLowerCase() + "/write_load";
		
		return new ModelAndView(returnURL);
	}
	
	
	
	
	
	
	

	/*
	 *  기타 함수들
	 * 
	 * 
	 */
	
	//상단 메뉴를 조회
	private CoviList getTopMenuList(String bizSection, CoviMap userDataObj) throws Exception {
		CoviList result = null;
		JSONSerializer jUtil = new JSONSerializer();
		String domainId = userDataObj.getString("DN_ID");
		String isAdmin = "N";
		String menuType = "Left";
		
		String menu = "";
		
		try {
			menu = ACLHelper.getMenu(userDataObj);
			
			if (StringUtils.isNoneBlank(menu)) {
				result = jUtil.jsonGetObject(menu);
				result = ACLHelper.parseMenuByBiz(domainId, isAdmin, bizSection, menuType, result, userDataObj.getString("lang"), "M");
			}
		} catch(NullPointerException npE){
			LOGGER.error("MobileCommonCon", npE);
			LoggerHelper.errorLogger(npE, "egovframework.covision.coviflow.user.mobile.web.MobileCommonCon.getTopMenuList", "CON");			
		} catch(Exception e){
			LOGGER.error("MobileCommonCon", e);
			LoggerHelper.errorLogger(e, "egovframework.covision.coviflow.user.mobile.web.MobileCommonCon.getTopMenuList", "CON");			
		}
		
		return result;
	}
	
	private void getFormInfo(HttpServletRequest request, CoviMap formInfo) throws Exception {
		//변수 초기화
		boolean successYN = true;
		String errorMsg = "";
        
		String strTopTempl = "";
		String strApvLineTempl = "";
		String strCommonFieldsTempl = "";
		String strHeaderTempl = "";
		String strBodyTempl = "";
		String strBodyTemplJS = "";
		String strFooterTempl = "";
		String strEditorSrc = "";
		String strApvLineYN = "N";

		CoviList processdes;
		CoviList forminstance;
		try{
			/*초기 변수값 설정
			 *  - Request 값
			 *  - 세션 값
			 *  - GetBaseConfig
			*/ 
			FormRequest formRequest = initFormRequest(request);            
			strApvLineYN = formRequest.getIsApvLineChg();			
			UserInfo userInfo = initUserInfo();
			
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
            
        	if(formRequest.getBstored().equalsIgnoreCase("true")) {
        		throw new NoSuchElementException(DicHelper.getDic("msg_check_trans_doc"));
        	}
            /* Workitem 정보로 양식 오픈 여부체크 */
        	CoviMap procData = setProcessData(formRequest);				// Process Data Setting
            CoviMap processObj = procData.getJSONObject("processObj");
            
            if(procData.has("strSubkind"))
            	formRequest.setSubkind(procData.getString("strSubkind"));
            
            if(procData.has("isArchived")){
        		formRequest.setArchived(procData.getString("isArchived"));
        	}
            
			//상세보기 상단정보 조회
			String pFormInstID = formRequest.getFormInstanceID();
			
			if(pFormInstID.isEmpty() && !processObj.isEmpty()) {
				pFormInstID = processObj.getString("FormInstID");
			}
			
			CoviMap params = new CoviMap();
			params.put("mode", formRequest.getReadMode());
			params.put("gloct", formRequest.getGLoct());
			params.put("processDescID", formRequest.getProcessdescriptionID());
			params.put("formInstID", pFormInstID);

			CoviMap resultList = mobileApprovalListSvc.selectMobileApprovalView(params);
			params = null;
			
			processdes = (CoviList) resultList.get("processdes");
			forminstance = (CoviList) resultList.get("forminstance");
			
			if(processdes.isEmpty() && processObj != null && !processObj.isEmpty()) {
				processdes.add(processObj.getJSONObject("ProcessDescription"));
			}
            
            String isSecdoc = formRequest.getIsSecdoc();
            String strReadMode = formRequest.getReadMode();
            
            // 오픈 여부 체크 시작
            if(processObj != null && !processObj.isEmpty()){
            	//ProcessDescription 데이터에서 다시 세팅
                if(formRequest.getFormId() == null || formRequest.getFormId().equals("") ){
                	formRequest.setFormId(processObj.getJSONObject("ProcessDescription").getString("FormID"));
                }
            	if(formRequest.getFormInstanceID() == null || formRequest.getFormInstanceID().equals("") ){
                	formRequest.setFormInstanceID(processObj.getJSONObject("ProcessDescription").getString("FormInstID"));
                }
                if(isSecdoc == null || isSecdoc.equals("")){
                	isSecdoc = processObj.getJSONObject("ProcessDescription").getString("IsSecureDoc");
                	formRequest.setIsSecdoc(isSecdoc);
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
            // Legacy에서 piid만 넘겨 왔을때 performer 정보 찾기에 대한 소스 생략됨   
        	if (!strReadMode.equalsIgnoreCase("DRAFT") && !strReadMode.equalsIgnoreCase("TEMPSAVE") 
    			&& !SessionHelper.getSession("isAdmin").equals("Y") && !formAuthSvc.hasReadAuth(formRequest, userInfo)){
        		throw new SecurityException(DicHelper.getDic("msg_noViewACL")); // 조회 권한이 없습니다.
            }
        
        	String strUseMultiEditYN = "N";
        	String strUseHWPEditYN = "N";
        	String strUseScDistributionYN = "N";
        	String strUseWebHWPEditYN = "N";
        	String strUseWebEditorEditYN = "N";
    		String strUseWebHWPMultiEditYN = "N"; 		// 문서유통 + 다안기안
    		String strUseScWebHWPEditYN = "N"; 			// 문서유통 + 한글웹기안기
    		String strUseScWebEditorEditYN = "N"; 		// 문서유통 + 웹에디터
    		String strUseScWebEditorMultiEditYN = "N"; 	// 다안기안 + 문서유통 + 웹에디터
        	
			/* 초기 변수값 수정
			 *  - ReadMode 변경
			*/ 
            if (!strReadMode.equals("COMPLETE"))
            {
            	strReadMode = formSvc.getReadMode(strReadMode,  processObj.optString("BusinessState"), formRequest.getSubkind(), processObj.optString("State"), processObj.optString("ProcessState"));
            	formRequest.setReadMode(strReadMode);
            }
			
			/* 처리
			 *  - Form Data 생성
			 *  - Template 삽입처리
			 *  - 자동 결재선 Data 생성
			*/ 
            // 양식 파일 경로 > createFormJSON 내부에서 처리
//        	if(isSaaS.equals("Y")) {
//        		params = new CoviMap();
//        		params.put("FormID", formRequest.getFormId());
//        		params.put("FormPrefix", formRequest.getFormPrefix());
//        		params.put("ProcessID", formRequest.getProcessID());
//        		formCompanyCode = formSvc.selectFormCompanyCode(params);
//        	}
//        	filePath = initFilePath();
        	
        	//다국어 언어설정
			// Form Data 생성
            CoviMap formJsonRet = createFormJSON(formRequest, userInfo, processObj);
            String filePath = formJsonRet.getString("filePath");
            
            CoviMap formJson = formJsonRet.getJSONObject("formJson");
            //formRequest = (FormRequest) CoviMap.toBean(formJsonRet.getJSONObject("formRequest"), FormRequest.class);
            formRequest = (FormRequest) formJsonRet.get("formRequest");
            
            CoviMap initializedValueForTemplate = formJsonRet.getJSONObject("initializedValueForTemplate");
            
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
           	           
           	// (본사운영) 대외공문일 경우 다른 Header 사용 
            Boolean bNeedConvert = initializedValueForTemplate.getBoolean("bNeedConvert");
            if(formRequest.getFormPrefix().equals("WF_FORM_EXTERNAL")){
            	strHeaderTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormHeader_EXTERNAL.html", "UTF8"), bNeedConvert);
            } else if(fileUtilSvc.fileIsExistsBoolean(filePath+"common/FormHeader"+"_"+formRequest.getFormPrefix()+".html")) { // new File(filePath+"common/FormHeader"+"_"+formRequest.getFormPrefix()+".html").exists()
            	strHeaderTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormHeader"+"_"+formRequest.getFormPrefix()+".html", "UTF8"), bNeedConvert);
            } else if(strUseWebHWPMultiEditYN.equals("Y")) {
            	strHeaderTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormHeaderGovMulti.html", "UTF8"), bNeedConvert);
            //  다안기안 + 문서유통 + 웹에디터 사용
            } else if(strUseScWebEditorMultiEditYN.equals("Y")) {
            	strHeaderTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormHeaderGovEditorMulti.html", "UTF8"), bNeedConvert);
            //  문서유통 + 웹에디터 사용
            } else if(strUseScWebEditorEditYN.equals("Y")) {
            	strHeaderTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormHeaderGovEditor.html", "UTF8"), bNeedConvert);
            } else if(strUseMultiEditYN.equals("Y")) {
            	strHeaderTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormHeaderMulti.html", "UTF8"), bNeedConvert);
            } else if(strUseScWebHWPEditYN.equals("Y")) {
            	strHeaderTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormHeaderGov.html", "UTF8"), bNeedConvert);
            }  else {
            	strHeaderTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormHeader.html", "UTF8"), bNeedConvert);
            }
            
            if(fileUtilSvc.fileIsExistsBoolean(filePath+"common/FormFooter"+"_"+formRequest.getFormPrefix()+".html")) { // new File(filePath+"common/FormFooter"+"_"+formRequest.getFormPrefix()+".html").exists()
            	strFooterTempl = formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormFooter"+"_"+formRequest.getFormPrefix()+".html", "UTF8");
            } else {
            	strFooterTempl = formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormFooter.html", "UTF8");
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
                        strTopTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath + "common/FormTopDraftRec.html", "utf8"), bNeedConvert);
                        strApvLineTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath + "common/FormApvLineDraftRec.html", "utf8"), bNeedConvert);
                        break;
                    default:
                        strTopTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath + "common/FormTopDraft.html", "utf8"), bNeedConvert);
                        strApvLineTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath + "common/FormApvLineDraft.html", "utf8"), bNeedConvert);
                        break;
                }
            } else {
            	strApvLineTempl = formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormApvLine.html", "UTF8");
            }
            
			strCommonFieldsTempl = formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormCommonFields.html", "UTF8");
			
			// 외부 연동 시 Body Cotent 부분에 대해서 파라미터로 받은 HTML  그대로 삽입
			String isLegacy = formJson.getJSONObject("Request").getString("isLegacy");
			String bodyContext = formJson.getString("BodyContext");
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
								strBodyTempl = new String(Base64.decodeBase64(formRequest.getMobileBodyContext().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
							else
								strBodyTempl = new String(Base64.decodeBase64(formRequest.getHtmlBodyContext().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
						}
				}
				else{
					strBodyTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), initializedValueForTemplate.getString("fileurl"), "UTF8"), bNeedConvert);
				}
			}else{
				strBodyTempl = getConvertWriteHtmlToRead(formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), initializedValueForTemplate.getString("fileurl"), "UTF8"), bNeedConvert);
			}
			strBodyTemplJS = formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath + formJsonRet.getString("strFormFileName") + ".js", "UTF8");
			strFooterTempl = formFileCacheSvc.readAllText(SessionHelper.getSession("lang"), filePath+"common/FormFooter.html", "UTF8");
			
			// 다안기안 사용 시 추가 js 삽입
			if(strUseMultiEditYN.equals("Y") || strUseHWPEditYN.equals("Y") || strUseWebHWPEditYN.equals("Y")) {
				strEditorSrc = "<script type=\"text/javascript\" src=\"/approval/resources/script/forms/MultiApvUtil.js\"></script>";
				strEditorSrc += "<script type=\"text/javascript\" src=\"/approval/resources/script/forms/MultiCtrl.js\"></script>";
				
				if(strUseHWPEditYN.equals("Y") || strUseWebHWPEditYN.equals("Y")) {
					strEditorSrc += "<script type=\"text/javascript\" src=\"/approval/resources/script/forms/WebEditor_Approval_HWP.js\"></script>";
					strEditorSrc += "<script type=\"text/javascript\" src=\"/covicore/resources/script/Hwp/HwpToolbars.js\"></script>";
					strEditorSrc += "<script type=\"text/javascript\" src=\"/covicore/resources/script/Hwp/HwpCtrl.js\"></script>";
				} else {
					strEditorSrc += "<script type=\"text/javascript\" src=\"/approval/resources/script/forms/WebEditor_approval.js\"></script>";
				}
			}
			
			// 읽음확인 - 가장 하단으로 위치 변경
            if (!strReadMode.equals("DRAFT") && !strReadMode.equals("TEMPSAVE") && !strReadMode.equals("TEMPSAVE_BOX"))
            {
            	if(formRequest.getBstored().equalsIgnoreCase("false")){
            		formSvc.confirmRead(formRequest, userInfo, strReadMode, processObj);
            	} else {
            		formSvc.confirmReadStore(formRequest, userInfo);
            	}
            }
            
            // Thread-safe
            formInfo.put("successYN", successYN);
    		formInfo.put("errorMsg", errorMsg);
            
    		formInfo.put("strTopTempl", strTopTempl);
    		formInfo.put("strApvLineTempl", strApvLineTempl);
    		formInfo.put("strCommonFieldsTempl", strCommonFieldsTempl);
    		formInfo.put("strHeaderTempl", strHeaderTempl);
    		formInfo.put("strBodyTempl", strBodyTempl);
    		formInfo.put("strBodyTemplJS", strBodyTemplJS);
    		formInfo.put("strFooterTempl", strFooterTempl);
    		formInfo.put("strEditorSrc", strEditorSrc);
    		formInfo.put("strApvLineYN", strApvLineYN);

    		formInfo.put("processdes", processdes);
    		formInfo.put("forminstance", forminstance);
    		
    		formInfo.put("formJson", formJson);
		} catch(SecurityException securityException) {
			LOGGER.warn("FormCon", securityException);
			LoggerHelper.errorLogger(securityException, "egovframework.covision.coviflow.form.web.FormCon.goCommonFormPage", "CON");
			errorMsg = securityException.getMessage();
			successYN = false;
		} catch(NoSuchElementException noSuchElementException) {
			errorMsg = noSuchElementException.getMessage();
			successYN = false;
		} catch(NullPointerException npE){
 			LOGGER.error("MobileCommonCon", npE);
			LoggerHelper.errorLogger(npE, "egovframework.covision.coviflow.user.mobile.web.MobileCommonCon.getFormInfo", "CON");
			
			successYN = false;
			errorMsg = DicHelper.getDic("msg_apv_formLoadErrorMsg");
		} catch(Exception e){
 			LOGGER.error("MobileCommonCon", e);
			LoggerHelper.errorLogger(e, "egovframework.covision.coviflow.user.mobile.web.MobileCommonCon.getFormInfo", "CON");
			
			successYN = false;
			errorMsg = DicHelper.getDic("msg_apv_formLoadErrorMsg");
		}
	}
	
	private FormRequest initFormRequest(HttpServletRequest request){
		FormRequest fReq = new FormRequest();
		
		/** Request */
		// ID
        fReq.setProcessID(StringUtil.replaceNull(request.getParameter("processID"), "")); 						// Process ID
        fReq.setWorkitemID(StringUtil.replaceNull(request.getParameter("workitemID"), "")); 				// Workitem ID
        fReq.setPerformerID(StringUtil.replaceNull(request.getParameter("performerID"), "")); 				// Performer ID
        fReq.setFormId(StringUtil.replaceNull(request.getParameter("formID"), ""));				 				// Form ID
        fReq.setFormInstanceID(StringUtil.replaceNull(request.getParameter("forminstanceID"), "")); 		// Form instance id
        fReq.setFormTempInstanceID(StringUtil.replaceNull(request.getParameter("formtempID"), "")); 	// Form Temporary instance id
        fReq.setProcessdescriptionID(StringUtil.replaceNull(request.getParameter("processdescriptionID"), ""));					// processDescriptionID
        
        // mode 및 gloct, loct
        fReq.setReadMode(StringUtil.replaceNull(request.getParameter("mode"), "")); 							// mode
        fReq.setReadModeTemp(StringUtil.replaceNull(request.getParameter("mode"), ""));
        fReq.setReadtype(StringUtil.replaceNull(request.getParameter("Readtype"), "")); 						// Read Type
        fReq.setGLoct(StringUtil.replaceNull(request.getParameter("gloct"), "")); 									// gloct
        
        fReq.setUserCode(StringUtil.replaceNull(request.getParameter("userCode"), "")); 						// User Code (세션 정보 X, Performer 및 Workitem의 UserCode)
        fReq.setSubkind(StringUtil.replaceNull(request.getParameter("subkind"), "")); 							// SubKind
        fReq.setFormInstanceTableName(StringUtil.replaceNull(request.getParameter("forminstancetablename"), ""));			// Form instance Table Name
        fReq.setFormPrefix(StringUtil.replaceNull(request.getParameter("formPrefix"), ""));
        fReq.setRequestFormInstID(StringUtil.replaceNull(request.getParameter("RequestFormInstID"), ""));
        
        
        //편집할 때 request로 받은 데이터로 세팅
        if(request.getParameter("DocModifyApvLine") != null && !request.getParameter("DocModifyApvLine").equals(""))
        	fReq.setDocModifyApvLine(CoviMap.fromObject(request.getParameter("DocModifyApvLine").replace("&quot;", "\"")));
        
		// 구분값 (Y | N)
        fReq.setEditMode(StringUtil.replaceNull(request.getParameter("editMode"), "N")); 					// 편집 모드
        fReq.setArchived(StringUtil.replaceNull(request.getParameter("archived"), "false")); 						// archived. 완료 여부
        fReq.setBstored(StringUtil.replaceNull(request.getParameter("bstored"), "false")); 					// bStored. 이관함 여부
        fReq.setAdmintype(StringUtil.replaceNull(request.getParameter("admintype"), "")); 						// 관리자 페이지에서 조회시 ADMIN
        fReq.setIsAuth(StringUtil.replaceNull(request.getParameter("isAuth"), "")); 									// 사용자 문서함 권한 부여 여부
        fReq.setIsReuse(StringUtil.replaceNull(request.getParameter("reuse"), "")); 									// 재사용 여부
        fReq.setIsHistory(StringUtil.replaceNull(request.getParameter("ishistory"), "")); 								// 히스토리 여부
        fReq.setIsUsisdocmanager(StringUtil.replaceNull(request.getParameter("usisdocmanager"), ""));		// 문서 관리자 여부. Y
        fReq.setIsTempSaveBtn(StringUtil.replaceNull(request.getParameter("isTempSaveBtn"), "Y"));			// 임시저장 버튼 표시 여부
        
        fReq.setIsSecdoc(StringUtil.replaceNull(request.getParameter("secdoc"), ""));								// 기밀문서 여부
        fReq.setIsMobile(StringUtil.replaceNull(request.getParameter("isMobile"), "N"));
        fReq.setIsApvLineChg(StringUtil.replaceNull(request.getParameter("isApvLineChg"), "N"));	
        fReq.setIsLegacy(StringUtil.replaceNull(request.getParameter("isLegacy"), ""));							// 외부 연동 여부 (기안 양식 오픈을 외부에서)
        
        fReq.setJsonBodyContext(StringUtil.replaceNull(request.getParameter("jsonBody"), ""));				// 외부 연동시 기안 bodycontext (기안 양식 오픈을 외부에서)
        fReq.setHtmlBodyContext(StringUtil.replaceNull(request.getParameter("htmlBody"), ""));				// 외부 연동시 기안 html (기안 양식 오픈을 외부에서)
        fReq.setMobileBodyContext(StringUtil.replaceNull(request.getParameter("mobileBody"), ""));				// 외부 연동시 기안 html - 모바일 용
        fReq.setLegacyBodyContext(StringUtil.replaceNull(request.getParameter("bodyContext"), ""));		// 외부 연동시 기안 html 과 bodycontext (기안 양식 오픈을 외부에서)
        fReq.setSubject(StringUtil.replaceNull(request.getParameter("subject"), ""));								// 외부 연동시 제목 (기안 양식 오픈을 외부에서)
        fReq.setLegacyDataType(StringUtil.replaceNull(request.getParameter("legacyDataType"), ""));
        
        fReq.setOwnerProcessId(StringUtil.replaceNull(request.getParameter("ownerProcessId"), "")); // 연관문서 오픈 여부
        fReq.setOwnerExpAppID(StringUtil.replaceNull(request.getParameter("ownerExpAppID"), "")); //  연관문서(경비결재) 오픈 여부 확인
        
        fReq.setGovRecordID(StringUtil.replaceNull(request.getParameter("GovRecordID"), ""));
        fReq.setGovDocID(StringUtil.replaceNull(request.getParameter("GovDocID"), ""));
        fReq.setGovState(StringUtil.replaceNull(request.getParameter("GovState"), ""));
        fReq.setIsOpen(StringUtil.replaceNull(request.getParameter("isOpen"), "")); // 사업관리 오픈 여부 확인 [21-02-01 add]
        
		return fReq;
	}
	
	private UserInfo initUserInfo(){
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
        fSes.setApvDeptName(StringUtil.replaceNull(SessionHelper.getSession("ApprovalParentGR_Name"),SessionHelper.getSession("GR_MultiName")));
        
        return fSes;
	}
	

	// Process Data Setting
	private CoviMap setProcessData(FormRequest formRequest) throws Exception {
		CoviMap ret = new CoviMap();
		
		CoviMap paramsProcess = new CoviMap();
        CoviMap paramsProcessDes = new CoviMap();
        
        String isArchived = formRequest.getArchived();
        if(formRequest.getReadMode().equals("COMPLETE") && isArchived.equals("false")){
        	isArchived = "true";
        }
        
        String strFormInstanceID = formRequest.getFormInstanceID();
        if(!isArchived.equals("") && strFormInstanceID != null && !strFormInstanceID.equals("") ){
        	CoviMap paramID = new CoviMap();
        	paramID.put("FormInstID", strFormInstanceID);
        	isArchived = formSvc.selectFormInstanceIsArchived(paramID);
        }
        
        String strProcessID = formRequest.getProcessID();
        String strWorkitemID = formRequest.getWorkitemID();
        if(strProcessID != null && !strProcessID.equals("")){
        	paramsProcess.put("processID", strProcessID);
        	paramsProcess.put("workitemID", strWorkitemID);
        	paramsProcess.put("IsArchived", isArchived);					// Archive 가 있는 테이블은 반드시 넘겨야 함
        	
        	CoviMap processObj = new CoviMap();
        	processObj = (((CoviList)(formSvc.selectProcess(paramsProcess)).get("list")).getJSONObject(0));	// process 및 workitem 조합 데이터
        	
        	String strProcessdescriptionID = formRequest.getProcessdescriptionID();
        	if(strProcessdescriptionID == null || strProcessdescriptionID.equals("")){
        		strProcessdescriptionID= processObj.getString("ProcessDescriptionID");
        	}
        	
        	String strSubkind = formRequest.getSubkind();
        	if(strSubkind.equals("") && processObj.has("SubKind"))
        		strSubkind = processObj.optString("SubKind");
        	
        	paramsProcessDes.put("processDescID", strProcessdescriptionID);
        	paramsProcessDes.put("IsArchived", isArchived);					// Archive 가 있는 테이블은 반드시 넘겨야 함
        	CoviMap processDesObj = (((CoviList)(formSvc.selectProcessDes(paramsProcessDes)).get("list")).getJSONObject(0));
        	
            processObj.put("ProcessDescription",processDesObj);
            
            ret.put("strSubkind", strSubkind);
            ret.put("isArchived", isArchived);
            ret.put("processObj", processObj);
        }
        
        return ret;
	}	

	// make FormJSON
	/**
	 * 
	 * @param formRequest
	 * @param formSession
	 * @param processObj
	 * @return
	 * @throws Exception
	 */
	private CoviMap createFormJSON(FormRequest formRequest, UserInfo formSession, CoviMap processObj) throws Exception{
		CoviMap ret = new CoviMap();
		
        CoviMap paramsForms = new CoviMap();
        CoviMap paramsSchema = new CoviMap();
        CoviMap paramsFormInstance = new CoviMap();
        
        CoviMap forms = new CoviMap();
        String strFormFavoriteYN = "N";
        CoviMap extInfo = new CoviMap();
        String strUnifiedFormYN = null;
        String strMobileFormYN = "N";
        CoviMap subtableInfo = new CoviMap();
        CoviMap autoApprovalLine = new CoviMap();
        String strFormFileName = null;
        CoviMap formSchema = new CoviMap();
        CoviMap schemaContext = new CoviMap();	
        CoviMap formInstance = new CoviMap();
        CoviMap bodyContext = new CoviMap();
        CoviMap bodyData = new CoviMap();	
        
        String strFormId = formRequest.getFormId();
        String strFormPrefix = formRequest.getFormPrefix();
        String strReadMode = formRequest.getReadMode();
        
		if((strFormId != null && !strFormId.equals("")) || (strFormPrefix != null && !strFormPrefix.equals(""))){
			String strSessionUserID = formSession.getUserID();
			String isGovReceiveForm = "N"; // 문서유통 수신함 문서 여부
			
			paramsForms.put("userID", strSessionUserID);
			if(!strFormId.equals("")){
				paramsForms.put("formID", strFormId);
			}else{
				paramsForms.put("formPrefix", strFormPrefix);
			}
			forms = (((CoviList)(formSvc.selectForm(paramsForms)).get("list")).getJSONObject(0));
			
			if(!forms.get("FormPrefix").equals("")){
				strFormPrefix = forms.optString("FormPrefix");
				formRequest.setFormPrefix(strFormPrefix);
			}
			
			if(!forms.get("IsFavorite").equals("")){
				strFormFavoriteYN = forms.optString("IsFavorite");
			}
			
			if(!forms.get("ExtInfo").equals("")){
				extInfo = forms.getJSONObject("ExtInfo");
				strUnifiedFormYN = extInfo.optString("UnifiedFormYN");

				// [19-08-23] kimhs, 중간에 추가된 옵션으로 기존에 생성된 양식 모바일에서 조회불가하여 수정함.
				if(extInfo.has("MobileFormYN"))
					strMobileFormYN = extInfo.optString("MobileFormYN");
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
			
			strFormFileName = forms.getString("FileName").substring(0, forms.getString("FileName").lastIndexOf("."));
			// 파일 명 (읽기쓰기 모드 구별된 파일명) 데이터 추가 - HTMLFileName
			
			paramsSchema.put("schemaID", forms.getString("SchemaID"));
			formSchema = (((CoviList)(formSvc.selectFormSchema(paramsSchema)).get("list")).getJSONObject(0));
			
			if(!formSchema.get("SchemaContext").equals(""))
				schemaContext = formSchema.getJSONObject("SchemaContext");
		}
		
		String formCompanyCode = forms.optString("CompanyCode");
    	String filePath = ApprovalUtil.getTemplatePath(formCompanyCode);
    	ret.put("filePath", filePath);
    	
		String strFormInstanceID = formRequest.getFormInstanceID();
		if(strFormInstanceID != null && !strFormInstanceID.equals("")){
			paramsFormInstance.put("formInstID", strFormInstanceID);
			formInstance = (((CoviList)(formSvc.selectFormInstance(paramsFormInstance)).get("list")).getJSONObject(0));
			
			if(!formInstance.get("BodyContext").equals(""))
				bodyContext = CoviMap.fromObject(new String(Base64.decodeBase64(formInstance.optString("BodyContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
			formInstance.remove("BodyContext");
			
			if(formInstance.has("AttachFileInfo") && !formInstance.get("AttachFileInfo").equals(""))
				formInstance.put("AttachFileInfo", CoviMap.fromObject(new String(Base64.decodeBase64(formInstance.optString("AttachFileInfo").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8)));
			
			//formInstance에 fiid_spare 추가 (빈값)
		} else if(formRequest.getIsLegacy().equalsIgnoreCase("Y")){
			if(!formRequest.getLegacyBodyContext().equals(""))		// 미리보기시
				bodyContext = CoviMap.fromObject(new String(Base64.decodeBase64(formRequest.getLegacyBodyContext().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
			if(!formRequest.getSubject().equals(""))
				formInstance.put("Subject", formRequest.getSubject());
		}
		
		// BodyData
		bodyData = formSvc.getBodyData(subtableInfo, extInfo, strFormInstanceID);				/// 하위테이블 데이터가 있을 경우 bodyData에 세팅
		
		// ApprovalLine
		CoviMap approvalLine = new CoviMap();
		CoviMap docModifyApvLine = new CoviMap();
		docModifyApvLine = formRequest.getDocModifyApvLine();
		
		if(docModifyApvLine !=null && !docModifyApvLine.isEmpty()){
			approvalLine = docModifyApvLine;
		} else{
			approvalLine = setDomainData(strReadMode, formSession.getUserID(), formSession.getDeptID(), formRequest.getProcessID(), formRequest.getArchived());
		}
		
		// 파라미터에 RequestFormInstID가 있는 경우 (완료함의 양식에서 후속 작업을 위한 결재선 조회. ex) 휴가취소신청서, 출장복명서)
		String strRequestFormInstID = formRequest.getRequestFormInstID();
		if(strRequestFormInstID != null && !strRequestFormInstID.equals("")){
			paramsForms.clear();
			paramsForms.put("FormInstID", strRequestFormInstID);
        	
			CoviList selectData = (CoviList)(formSvc.selectFormAfterDomainData(paramsForms)).get("list");
        	if(!selectData.isEmpty()){
        		approvalLine = selectData.getJSONObject(0).getJSONObject("DomainDataContext");
        	}
		}
		
		CoviMap workedAutoApprovalLine = new CoviMap();
		if(!formRequest.getReadtype().equals("preview")) {
			//자동 결재선 Data 생성
			CoviMap allAutoLine = setAutoDomainData(autoApprovalLine, formSession, formRequest.getFormTempInstanceID(), strReadMode, schemaContext.getJSONObject("scStep"), strFormPrefix, strRequestFormInstID);
		
			workedAutoApprovalLine = allAutoLine.getJSONObject("autoDomainData");
			
			autoApprovalLine = allAutoLine.getJSONObject("autoApprovalLine");
		}
		
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
		requestData.put("isMobile", formRequest.getIsMobile());
		
		String isLegacy = formRequest.getIsLegacy();
		if(isLegacy.equals(""))
			isLegacy = forLegacySvc.isLegacyFormCheck(strFormPrefix) ? "Y" : "N";
		requestData.put("isLegacy", isLegacy);
		
		requestData.put("isTempSaveBtn", formRequest.getIsTempSaveBtn());
		requestData.put("legacyDataType", formRequest.getLegacyDataType());
		
		CoviMap initializedValueForTemplate = pInitValueForTemplate(strReadMode, formRequest.getReadtype(), formRequest.getEditMode(), strFormFileName, strUnifiedFormYN, strMobileFormYN, filePath);
		
		// 모바일 양식 조회 시 모바일용 스크립트를 조회
		if(initializedValueForTemplate.getString("viewMobileForm") != null && initializedValueForTemplate.optString("viewMobileForm").equals("Y")) {
			strFormFileName =  strFormFileName + "_MOBILE";
		}
		
		requestData.put("templatemode", initializedValueForTemplate.getString("strTemplateType"));
		
		String strProcessID = formRequest.getProcessID();
		if(strProcessID == null || strProcessID.equals("") || processObj.isNullObject() || processObj.isEmpty() ){
			requestData.put("loct", strReadMode);
		}else{
			requestData.put("loct", getLOCTData(formRequest, strReadMode, formSession.getUserID(), processObj));
		}
		
		// AppInfo - Session, 기타 등
		CoviMap appInfo = new CoviMap();
		
		appInfo.put("usid", formSession.getUserID());
		appInfo.put("usnm", formSession.getUserName());
		appInfo.put("dpid", formSession.getDeptID());
		appInfo.put("dpnm", formSession.getDeptName());
		appInfo.put("dpid_apv", formSession.getApvDeptID());				// 임의
		appInfo.put("dpdn_apv", formSession.getApvDeptName());			// 임의
		appInfo.put("etnm", formSession.getDNName());
		appInfo.put("etid", formSession.getDNCode());
		appInfo.put("ussip", formSession.getUserMail());				// 임의. 이메일 주소
		appInfo.put("sabun",  formSession.getUserEmpNo());										// 사번
		
		appInfo.put("uspc", formSession.getJobPositionCode());		// 직위 코드
		appInfo.put("uspn", formSession.getJobPositionName());		// 직위 명
		appInfo.put("ustc", formSession.getJobTitleCode());				// 직책 명
		appInfo.put("ustn", formSession.getJobTitleName());				// 직책 코드
		appInfo.put("uslc", formSession.getJobLevelCode());				// 직급 명
		appInfo.put("usln", formSession.getJobLevelName());			// 직급 코드
		
		appInfo.put("grpath", formSession.getDeptPath());
		appInfo.put("grfullname", formSession.getGRFullName()); 			//dppathdn
		
		appInfo.put("managercode", formSession.getURManagerCode());
		appInfo.put("managername", formSession.getURManagerName());
		appInfo.put("usismanager", formSession.getURIsManager());
		
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
		
		appInfo.put("usit", formSession.getUserSignFileID());			// 서명이미지
		
		appInfo.put("usnm_multi", formSession.getUserMultiName());
		appInfo.put("uspn_multi", formSession.getUserMultiJobPositionName());
		appInfo.put("ustn_multi", formSession.getUserMultiJobTitleName());
		appInfo.put("usln_multi", formSession.getUserMultiJobLevelName());
		appInfo.put("dpnm_multi", formSession.getDeptMultiName());
		
		appInfo.put("ustp", SessionHelper.getSession("PhoneNumber"));
		appInfo.put("usfx", SessionHelper.getSession("Fax"));
		
		String editortype = RedisDataUtil.getBaseConfig("EditorType");
		// 미사용
		//String fmfl = RedisDataUtil.getBaseConfig("FrontStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "Approval";																// 기존 데이터 : /FrontStorageApproval/
		//String fmurl = domainName + RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", SessionHelper.getSession("DN_Code")) + "e-sign/ApprovalEDMS/";					// 기존 데이터 : http://www.no1.com/GWStoragee-sign/ApprovalEDMS/
		//String fmpath = RedisDataUtil.getBaseConfig("BackStoragePath").replace("{0}", SessionHelper.getSession("DN_Code")) + "e-sign/ApprovalEDMS/";									// 기존 데이터 : \\192.168.32.71\GWStorage\e-sign\ApprovalEDMS\
		//String attpath = domainName + RedisDataUtil.getBaseConfig("BackStoragePath").replace("{0}", SessionHelper.getSession("DN_Code")) + "e-sign/Approval/Attach";			// 기존 데이터 : \\192.168.32.71\GWStorage\e-sign\Approval\Attach\
		//String sealpath = RedisDataUtil.getBaseConfig("OfficailSeal_SavePath");
		
		// BaseConfig
		CoviMap baseConfig = new CoviMap();
		baseConfig.put("editortype", editortype);						// Dext5로 임시 고정
		//baseConfig.put("fmfl", fmfl);															// 기존 데이터 : /FrontStorageApproval/
		//baseConfig.put("fmurl", fmurl);				// 기존 데이터 : http://www.no1.com/GWStoragee-sign/ApprovalEDMS/
		//baseConfig.put("fmpath", fmpath);									// 기존 데이터 : \\192.168.32.71\GWStorage\e-sign\ApprovalEDMS\
		//baseConfig.put("attpath", attpath);				// 기존 데이터 : \\192.168.32.71\GWStorage\e-sign\Approval\Attach\
		//baseConfig.put("sealpath", sealpath);
		
		// 첨부파일
		CoviList fileInfos = new CoviList();
		
		if(!strReadMode.equals("DRAFT") && !strFormInstanceID.equals("")){
			fileInfos = getFileInfos(strFormInstanceID);
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
	
	private String getConvertWriteHtmlToRead(String strDocument, Boolean bNeedConvert){
		StringBuffer result = new StringBuffer(strDocument.length());
        String strReturnDocument = "";
        /*String strPattern = "";
        String strReplaceValue = "";*/
        
        Pattern p = null;
        Matcher m = null;
        int count = 0;
        
        Pattern SPECIAL_REGEX_CHARS = Pattern.compile("[$]");	//("[{}()\\[\\].+*?^$\\\\|]");
        strDocument = SPECIAL_REGEX_CHARS.matcher(strDocument).replaceAll("\\\\$0");
        
        if(Boolean.TRUE.equals(bNeedConvert)){
			
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
	        
        }else{
        	strReturnDocument = strDocument;
        }

        return strReturnDocument;
    }
	
	// ApprovalLine - 결재선
	private CoviMap setDomainData(String strReadMode, String strSessionUserID, String strSessionDeptID, String strProcessID, String isArchived) throws Exception {
		// ApprovalLine
		CoviMap paramsDomain = new CoviMap();
		CoviMap approvalLine = new CoviMap();
		CoviMap stepsObj = new CoviMap();
		
		if (strReadMode.equals("DRAFT") || strReadMode.equals("TEMPSAVE") || strReadMode.equals("TEMPSAVE_BOX") || strReadMode.equals("PREDRAFT"))
        {
			stepsObj.put("status", strSessionUserID);
			stepsObj.put("initiatoroucode", strSessionDeptID);
			stepsObj.put("initiatorcode", "inactive");
			approvalLine.put("steps", stepsObj);
			
        }else{
			if(strProcessID != null && !strProcessID.equals("")){
				paramsDomain.put("processID", strProcessID);
				paramsDomain.put("IsArchived", isArchived);					// Archive 가 있는 테이블은 반드시 넘겨야 함
				CoviMap domainData = (((CoviList)(formSvc.selectDomainData(paramsDomain)).get("list")).getJSONObject(0));
				
				if(!domainData.get("DomainDataContext").equals(""))
					approvalLine = domainData.getJSONObject("DomainDataContext");
			}
        }
		
		return approvalLine;
	}
	
	// 자동결재선 세팅 함수 -> 추가적인 개발이 필요함
	private CoviMap setAutoDomainData(CoviMap autoApprovalLine, UserInfo formSession, String strFormTempInstanceID, String strReadMode, CoviMap scStep, String strFormPrefix, String strRequestFormInstID) throws Exception{
		// 양식 설정의 자동결재선
		autoApprovalLine = autoApprovalLineService.setFormAutoApprovalData(autoApprovalLine, formSession.getDNCode(), formSession.getUserRegionCode());
		
		// 양식 설정의 자동결재선 이외의 자동결재선
		CoviMap autoDomainData = new CoviMap();
		CoviMap returnData = new CoviMap();
		
		CoviMap params = new CoviMap();
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
            	
				CoviList selectData = (CoviList)(formSvc.selectPravateDomainData(params)).get("list");
            	if(!selectData.isEmpty()){
            		returnData = selectData.getJSONObject(0);
            		autoDomainData = returnData.getJSONObject("PrivateContext");
            	}
            	
				if(returnData.isNullObject() || returnData.isEmpty()){
					// 부서장 결재 단계 사용
					if (( strReadMode.equals("DRAFT") || strReadMode.equals("TEMPSAVE")) && scStep.optString("isUse").equals("Y") && !scStep.optString("value").equals("")){
						String[] aOUCodes = formSession.getDeptPath().split(";");
                        //다국어 처리를 위해 요청자 세션의 부서fullpath명칭 가져옮
						String[] aOUNames = formSession.getGRFullName().split("@");				//Request.QueryString["dppathdn"].Split(';');
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
	
	//파일명, template의 모드, 변환 여부를 처리하는 함수
	private CoviMap pInitValueForTemplate(String strReadMode, String strReadtype, String isEditMode, String strFormFileName, String strUnifiedFormYN, String strMobileFormYN, String filePath){
        
		String strTemplateType = "";
		String fileurl = "";
		String filename = "";
		String fileExtension = ".html";
		String viewMobileForm = "N";
		Boolean bNeedConvert = false;
		// String filePath = ApprovalUtil.getTemplatePath(formCompanyCode);
		
        if (strReadMode.trim().equalsIgnoreCase("DRAFT") && (!strReadtype.equals("preview")) && (!strReadtype.equals("Pubpreview")) && !isEditMode.equals("P")){
            //쓰기형태, 초기화 Y, 모바일 작성/수정 시 모바일용 양식파일 사용
        	if(strMobileFormYN.equals("Y")) {
        		fileExtension = "_MOBILE.html";
        		viewMobileForm = "Y";
        	}
            strTemplateType = "Write";
            fileurl = filePath + strFormFileName + fileExtension;
            filename = strFormFileName + fileExtension;
            /*bNeedInit = true;*/

        }else if ((strReadMode.trim().equalsIgnoreCase("TEMPSAVE") || !isEditMode.equals("N")) && (!strReadtype.equals("preview")) && (!strReadtype.equals("Pubpreview")) && (!isEditMode.equals("P"))){
            //쓰기 형태, 변환 N, 모바일 작성/수정 시 모바일용 양식파일 사용
        	if(strMobileFormYN.equals("Y")) {
        		fileExtension = "_MOBILE.html";
        		viewMobileForm = "Y";
        	}
            strTemplateType = "Write";
            fileurl = filePath + strFormFileName + fileExtension;
            filename = strFormFileName + fileExtension;
        }else{
            if (isEditMode.equals("P")){													// 통합모드가 아니면
                if (strUnifiedFormYN.trim().equalsIgnoreCase("N")){
                    //인쇄 형태, 변환 N
                    strTemplateType = "Read";
                    fileurl = filePath + strFormFileName + "_print_read.html";  //2012-04-02 HIW
                    filename = strFormFileName + "_print_read.html";
                }else{																				// 통합모드면
                    //인쇄 형태, 변환 Y
                    strTemplateType = "Read";
                    // [2015-01-29 LeeSM] editMode = P, ReadType = Pubpreview, Print일 때 "양식fmpf_print_read.html" 출력 페이지 호출
                    if (strReadtype.equals("Pubpreview") || strReadtype.equals("Print")){
                        fileurl = filePath + strFormFileName + "_print_read.html";  //2012-04-02 HIW
                        filename = strFormFileName + "_print_read.html";
                    }else{
                        fileurl = filePath + strFormFileName + ".html";  //2012-04-02 HIW
                        filename = strFormFileName + ".html";
                    }
                    bNeedConvert = true;
                }
            }else{
                // 다단계일때 재기안시 바로 편집모드 활성화																			// 통합모드가 아니면
                if (strUnifiedFormYN.trim().equalsIgnoreCase("N")){
                    strTemplateType = "Read";
                    fileurl = filePath + strFormFileName + "_read.html";  //2012-04-02 HIW
                    filename = strFormFileName + "_read.html";
                }else{																				// 통합모드면
                    //읽기 형태, 변환 Y
                    strTemplateType = "Read";
                    fileurl = filePath + strFormFileName + ".html";  //2012-04-02 HIW
                    filename = strFormFileName + ".html";
                    bNeedConvert = true;
                }
            }
        }
        
        CoviMap ret = new CoviMap();
        ret.put("strTemplateType", strTemplateType);
        ret.put("fileurl", fileurl);
        ret.put("filename", filename);
        ret.put("bNeedConvert", bNeedConvert);
        ret.put("viewMobileForm", viewMobileForm);
        
        return ret;
    }
	
	private String getLOCTData(FormRequest formRequest, String strReadMode, String strSessionUserID, CoviMap processObj) {
		String strLoct = "";

        //20041206 백종기 수정
		String processState = processObj.optString("ProcessState");
		String workitemState = processObj.has("State") ? processObj.optString("State") : "";
		String strDeputyID = processObj.has("DeputyID") ? processObj.optString("DeputyID") : "";
		
        if (strReadMode.equals("APPROVAL")){
            if (!processState.equals("288")){//(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                strLoct = "COMPLETE";
            }else{
                if (!workitemState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                    strLoct = "PROCESS";
                }else{
                    if (strSessionUserID.equals(formRequest.getUserCode())
                    		|| strSessionUserID.equals(processObj.has("UserCode") ? processObj.optString("UserCode") : "") 
                    		|| strSessionUserID.equals(strDeputyID) || formRequest.getGLoct().equals("JOBFUNCTION") || formRequest.getGLoct().equals("DEPART")){
                        strLoct = formRequest.getReadModeTemp();
                    }else{
                        strLoct = "PROCESS";
                    }
                }
            }
        }else if (strReadMode.equals("REDRAFT") || strReadMode.equals("SUBREDRAFT")){
            if (!processState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                strLoct = "COMPLETE";
            }else{
                if (!workitemState.equals("288")){ //(int)CfnEntityClasses.CfInstanceState.instOpen_Running)
                    strLoct = "PROCESS";
                }else{
                    strLoct = formRequest.getReadModeTemp();
                }
            }
        } else if (strReadMode.equals("REJECT")){
        	strLoct = "REJECT";
        } else if (strReadMode.equals("CONSULT") && workitemState.equals("288")){
        	strLoct = "APPROVAL";
        } else{
            strLoct = formRequest.getReadModeTemp();
        }

        return strLoct;

    }
	
	//첨부파일 정보
	private CoviList getFileInfos(String strFormInstanceID) throws Exception{

		CoviMap params = new CoviMap();
		params.put("ServiceType", "Approval");
		params.put("ObjectType", "DEPT");
		params.put("FormInstID", strFormInstanceID);
		
		return (CoviList)(formSvc.selectFiles(params)).get("list");
	}
	
	// 결재자 서명이미지 가져오기
	@RequestMapping(value = "/user/getUserSignInfo.do", method = {RequestMethod.GET,RequestMethod.POST})
	public @ResponseBody CoviMap getUserSignInfo(HttpServletRequest request, HttpServletResponse response, @RequestParam("UserCode") String userCode){
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

	
	/// <summary>
	/// 언어코드값 가져오기
	/// </summary>
	/// <param name="culturecode"></param>
	/// <returns></returns>
	private static String getLngIdx()
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
	
	/*
	 *  post 호출
	 * 
	 * 
	 */
	//선택된 양식의 formInfo 반환
	@RequestMapping(value = "/approval/getFormInfo.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getFormInfo(HttpServletRequest request, HttpServletResponse response ,@RequestParam Map<String, String> paramMap) throws Exception {
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap formInfo = new CoviMap();
			getFormInfo(request, formInfo);
			
			CoviMap formJson = formInfo.getJSONObject("formJson");
			
			returnList.put("strApvLineTempl", formInfo.getString("strApvLineTempl"));
			returnList.put("strCommonFieldsTempl", formInfo.getString("strCommonFieldsTempl"));
			returnList.put("strHeaderTempl", formInfo.getString("strHeaderTempl"));
			returnList.put("strBodyTempl", formInfo.getString("strBodyTempl"));
			returnList.put("strBodyTemplJS", formInfo.getString("strBodyTemplJS"));
			returnList.put("strFooterTempl", formInfo.getString("strFooterTempl"));
			returnList.put("strEditorSrc", formInfo.getString("strEditorSrc"));
			returnList.put("formJson", new String(Base64.encodeBase64(formJson.toString().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
			returnList.put("strApvLineYN", formInfo.getString("strApvLineYN"));
			
			returnList.put("strErrorMsg", formInfo.getString("errorMsg"));
			returnList.put("strSuccessYN", formInfo.optBoolean("successYN"));
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
}
