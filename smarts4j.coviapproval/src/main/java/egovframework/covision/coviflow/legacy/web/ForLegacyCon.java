package egovframework.covision.coviflow.legacy.web;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.HttpServletRequestHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpsUtil;
import egovframework.coviframework.util.SessionCommonHelper;
import egovframework.covision.coviflow.form.service.ApvProcessSvc;
import egovframework.covision.coviflow.legacy.service.ForLegacySvc;
import egovframework.covision.coviflow.legacy.service.FormLegacySvc;
import egovframework.baseframework.data.CoviMapperOne;


/**
 * @Class Name : ForLegacyCon.java
 * @Description : 전자결재 외부 연동
 * @Modification Information 
 * @ 2017.05.18 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 05.18
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */
@Controller
public class ForLegacyCon {
	@Autowired
	private ForLegacySvc forLegacySvc;
	
	@Autowired
	private FormLegacySvc formLegacySvc;

	@Autowired
	private ApvProcessSvc apvProcessSvc;
	
	@Resource(name="coviMapperOne")
	CoviMapperOne coviMapperOne;
	
	private Logger LOGGER = LogManager.getLogger(ForLegacyCon.class);
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	/**
	 * 전결규정 데이터 전달
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/getRuleApvLine.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getRuleApvLine(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		
		String legacyFormID = "";
		String ruleItemID = "";
		
		try {
			if(request.getParameter("legacyFormID") != null){
				legacyFormID = request.getParameter("legacyFormID");
				ruleItemID = request.getParameter("ruleItemID");
			}else{
				String bodyInfo = HttpServletRequestHelper.getBody(request);
				String escaped = StringEscapeUtils.unescapeHtml(bodyInfo);
				CoviMap jsonObj = CoviMap.fromObject(escaped);
				
				legacyFormID = jsonObj.optString("legacyFormID");
				ruleItemID = jsonObj.optString("ruleItemID");
			}
			
			// 기간계 연동으로 등록된 양식인지 체크 필요
			if(forLegacySvc.isLegacyFormCheck(legacyFormID)){
				CoviMap params = new CoviMap();
				params.put("legacyFormID", legacyFormID);
				params.put("itemId", ruleItemID);
				params.put("grCode", SessionHelper.getSession("DEPTID"));
				
				CoviMap apvLine = forLegacySvc.getRuleApvLine(params);		// 결재선 반환
				
				returnObj.put("result", apvLine);
				returnObj.put("status", Return.SUCCESS);
				returnObj.put("message", Return.SUCCESS);
			}else{
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "기간계 연동으로 등록된 양식이 아닙니다.");
			}
			
		} catch (NullPointerException npE) {
			LOGGER.error("ForLegacyCon", npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error("ForLegacyCon", e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	/**
	 * 신청유형 별 담당업무 데이터
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/getJobFunctionData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getJobFunctionData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		
		String jobFunctionCode = "";
		
		try {
			if(request.getParameter("JobFunctionCode") != null){
				jobFunctionCode = request.getParameter("JobFunctionCode");
			}else{
				String bodyInfo = HttpServletRequestHelper.getBody(request);
				String escaped = StringEscapeUtils.unescapeHtml(bodyInfo);
				CoviMap jsonObj = CoviMap.fromObject(escaped);
				
				jobFunctionCode = jsonObj.optString("JobFunctionCode");
			}
			
			String companyCode = StringUtil.replaceNull(request.getParameter("CompanyCode"));
			List<String> jobFunctionCodeList = Arrays.asList(jobFunctionCode.split("\\^"));
			
			CoviMap params = new CoviMap();
			params.put("JobFunctionCode", jobFunctionCodeList);
			params.put("CompanyCode", companyCode);

			CoviMap returnData = forLegacySvc.getJobFunctionData(params);		//담당업무함 데이터 반환 (JF_ACCOUNT_NORMAL@일반 비용신청)
			
			returnObj.put("result", returnData);
			returnObj.put("status", Return.SUCCESS);
			returnObj.put("message", Return.SUCCESS);
			
		} catch (NullPointerException npE) {
			LOGGER.error("ForLegacyCon", npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error("ForLegacyCon", e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	 
	/**
	 * 양식 팝업 링크 연결 (입력받은 데이터로 기안)
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/goFormLink.do")
	public ModelAndView goFormForLegacy(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		ModelAndView mav = new ModelAndView("forms/FormForLegacy");
		StringUtil func = new StringUtil();
		//CookiesUtil funcCookies = new CookiesUtil();
		CoviMap returnObj = new CoviMap();

		String mode = "";
		String processID = "";
		String key = "";
		String subject = "";
		String empno = "";
		String logonId = "";
		String deptId = "";
		String legacyFormID = "";
		String dataType = "";
		String lang = "";
		String isTempSaveBtn = "";
		String bodyContext = "";
		String apvLegacyData = "";

		try {
			mode = request.getParameter("mode");
			processID = request.getParameter("processID");
			key = request.getParameter("key");
			subject = request.getParameter("subject");
			empno = StringUtil.replaceNull(request.getParameter("empno"), "");
			logonId = StringUtil.replaceNull(request.getParameter("logonId"), "");
			deptId = StringUtil.replaceNull(request.getParameter("deptId"), "");
			legacyFormID = request.getParameter("legacyFormID");
			dataType = request.getParameter("dataType");
			lang = StringUtil.replaceNull(request.getParameter("language"), "");
			isTempSaveBtn = request.getParameter("isTempSaveBtn");
			bodyContext = request.getParameter("bodyContext");
			apvLegacyData = StringUtil.replaceNull(request.getParameter("apvLegacyData"), "");
			
			CoviMap logonUserInfo = forLegacySvc.selectLogonIDByDept(empno, logonId, deptId);
			String legacyLogonID = logonUserInfo.getString("LogonID");
			String legacyDeptCode = logonUserInfo.getString("DeptCode");
			
			String sessionLogonID = SessionHelper.getSession("LogonID"); // USERID
			String sessionDeptCode = SessionHelper.getSession("DEPTID");
			
			
			if( !legacyLogonID.equals("") || !sessionLogonID.equals("")){
				if((!legacyLogonID.equals("") && !sessionLogonID.equals("") && !legacyLogonID.equalsIgnoreCase(sessionLogonID)) // 로그인된 세션이 있고 사용자가 다른경우
						|| (!deptId.equals("") && !legacyDeptCode.equals("") && !sessionDeptCode.equals("") && !legacyDeptCode.equalsIgnoreCase(sessionDeptCode))){ // 부서코드를 입력한경우, 로그인된 세션이 있고 부서가 다른경우(겸직체크)
            		mav.addObject("status", Return.FAIL);
					mav.addObject("message", "다른 사용자/겸직부서로 이미 로그인되어 있습니다.");
				}else{ 
					HttpSession session = request.getSession();
					boolean isMobile = ClientInfoHelper.isMobile(request);
					String sessionKey = "";
					String legacyDnCode = SessionHelper.getSession("DN_Code");
					String status = "SUCCESS";
					
					if((!legacyLogonID.equals("") && sessionLogonID.equals("")) // 로그인된 세션이 없는경우 세션생성
							|| (deptId.equals("") && !legacyDeptCode.equals("") && !sessionDeptCode.equals("") && !legacyDeptCode.equalsIgnoreCase(sessionDeptCode))){ // 부서코드 입력안했는데, 로그인세션이 있고 부서가다른경우 본직으로 세션변경 후 진행 
						// 로그인 처리
						// 아직 request에 세션 key가 없어서 SessionHelper.getSession 사용 불가, SessionHelper.simpleGetSession 사용 필요
						status = forLegacySvc.setFormLegacyLogin(response, session, legacyLogonID, legacyDeptCode, isMobile, lang);  
						
						if(!func.f_NullCheck(status).equals("SUCCESS")){
							mav.addObject("status", Return.FAIL);
							mav.addObject("message", "로그인 처리 중 오류가 발생하였습니다.");
						}else{
							sessionKey = (session.getAttribute("KEY") != null) ? session.getAttribute("KEY").toString() : "";
							legacyDnCode = SessionHelper.simpleGetSession("DN_Code",isMobile,sessionKey);
						}
					}
					
					if(func.f_NullCheck(status).equals("SUCCESS")){
						// 진행 및 완료시 추가적인 값 조회
						if((mode == null || !mode.equalsIgnoreCase("DRAFT")) && processID != null && !processID.equals("")){
							CoviMap formInfo = forLegacySvc.getFormLegacyInfo(processID);
							
							mode = formInfo.getString("Mode");
							legacyFormID = formInfo.getString("FormPrefix");
						}
						
						if(forLegacySvc.isLegacyFormCheck(legacyFormID, legacyDnCode)){ // 기간계 연동으로 등록된 양식인지 체크
							CoviMap params = new CoviMap();
							params.put("mode", mode);
							params.put("processID", processID);
							params.put("key", key);
							//params.put("subject", subject);
							//params.put("empno", empno);
							params.put("legacyFormID", legacyFormID);
							params.put("dataType", dataType);
							params.put("bodyContext", bodyContext);
							params.put("isTempSaveBtn", isTempSaveBtn);
							
							// 양식 정보 구성(본문,url 등)
							returnObj = forLegacySvc.goFormLink(params);
										
							mav.addObject("status", Return.SUCCESS);
							mav.addObject("message", Return.SUCCESS);
							
							mav.addObject("URL", returnObj.getString("URL"));
							mav.addObject("logonid", legacyLogonID);
							mav.addObject("language", lang);
							
							if(mode.equalsIgnoreCase("DRAFT")){
								mav.addObject("HTMLBody", new String(Base64.encodeBase64(returnObj.getString("HTMLBody").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
								mav.addObject("JSONBody", new String(Base64.encodeBase64(returnObj.getJSONObject("JSONBody").toString().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
								//mav.addObject("BodyContext", new String(Base64.encodeBase64(params.getString("bodyContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
								mav.addObject("BodyContext", new String(Base64.encodeBase64(returnObj.getString("bodyContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
								mav.addObject("Subject", subject);
								
								if(returnObj.has("MobileBody"))
									mav.addObject("MobileBody", new String(Base64.encodeBase64(returnObj.getString("MobileBody").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
								else
									mav.addObject("MobileBody", new String(Base64.encodeBase64(returnObj.getString("JSONBody").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
								
								//연동결재선 생성
								if(!"".equals(apvLegacyData)) {
									apvLegacyData = new String(Base64.decodeBase64(apvLegacyData.getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8);
									params.put("APRV_LINE", apvLegacyData);
									params.put("empNo", empno);
									params.put("userID", legacyLogonID);
									params.put("deptID", legacyDeptCode);
									CoviMap legacyApprovalLine = forLegacySvc.getApvLineForDraft(params);
									
									mav.addObject("legacyApprovalLine", new String(Base64.encodeBase64(legacyApprovalLine.toString().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
								}
							}
						}else{
							mav.addObject("status", Return.FAIL);
							mav.addObject("message", "기간계 연동으로 등록된 양식이 아닙니다.");
						}
					}
				}
			}else{
				mav.addObject("status", Return.FAIL);
				mav.addObject("message", "로그인 정보가 없습니다.");
			}
		} catch (NullPointerException npE) {
			LOGGER.error("ForLegacyCon", npE);
			mav.addObject("status", Return.FAIL);
			mav.addObject("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error("ForLegacyCon", e);
			mav.addObject("status", Return.FAIL);
			mav.addObject("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return mav;
	}
	
	/**
	 * 양식 팝업 링크 연결 (DB 데이터로 기안)
	 * dataSoureType : GWDB(내부 중간테이블 이용) , EXTDB(외부 연계시스템 테이블 이용)
	 */
	@RequestMapping(value = "legacy/goFormLinkForDB.do")
	public ModelAndView goFormForLegacyForDB(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		ModelAndView mav = new ModelAndView("forms/FormForLegacy");
		StringUtil func = new StringUtil();
		CoviMap formInfo = new CoviMap();

		String dataSoureType = "";
		String systemCode = "";
		String key = "";
		
		String empno = "";
		String deptId = "";
		String legacyFormID = "";
		
		String mode = "DRAFT"; // 고정
		String logonId = ""; // 고정
		String lang = ""; // 고정
		String isTempSaveBtn = ""; // 고정
		String dataType = "JSON"; // 고정(EXTDB일때만 사용)
		
		try {
			dataSoureType = StringUtil.replaceNull(request.getParameter("dataSoureType"), "");
			systemCode = StringUtil.replaceNull(request.getParameter("systemCode"), "");
			key = StringUtil.replaceNull(request.getParameter("key"), "");
			
			if(dataSoureType.equals("") || systemCode.equals("") || key.equals("")) {
				mav.addObject("status", Return.FAIL);
				mav.addObject("message", "연동 정보가 없습니다.(dataSoureType,systemCode,key)");
				return mav;
			}
			
			// source DB에서 기안을 위한 데이터 가져오기
			CoviMap params = new CoviMap();
			params.put("SystemCode", systemCode);
			params.put("Key", key);
			params.put("Mode", mode);
			params.put("IsTempSaveBtn",isTempSaveBtn);
			switch(dataSoureType) {
				case "GWDB":
					formInfo = forLegacySvc.goFormLink_GWDB(params);
					break;
				case "EXTDB":
					params.put("DataType", dataType);
					formInfo = forLegacySvc.goFormLink_EXTDB(params);
					break;
				default:
					mav.addObject("status", Return.FAIL);
					mav.addObject("message", "연동 정보가 잘못되었습니다.(dataSoureType)");
					return mav;
			}
			
			if(!formInfo.optString("status").equals("S")) {
				mav.addObject("status", Return.FAIL);
				mav.addObject("message", formInfo.optString("message"));
				return mav;
			}
			empno = formInfo.optString("empno");
			deptId = formInfo.optString("deptId");
			legacyFormID = formInfo.optString("legacyFormID");
			dataType = formInfo.optString("dataType");
			
			// 세션 체크(세션이 있는지,로그인사용자/부서 정보가 같은지)
			CoviMap logonUserInfo = forLegacySvc.selectLogonIDByDept(empno, logonId, deptId);
			String legacyLogonID = logonUserInfo.getString("LogonID");
			String legacyDeptCode = logonUserInfo.getString("DeptCode");
			
			String sessionLogonID = SessionHelper.getSession("LogonID"); // USERID
			String sessionDeptCode = SessionHelper.getSession("DEPTID");
			
			
			if( !legacyLogonID.equals("") || !sessionLogonID.equals("")){
				if((!legacyLogonID.equals("") && !sessionLogonID.equals("") && !legacyLogonID.equalsIgnoreCase(sessionLogonID)) // 로그인된 세션이 있고 사용자가 다른경우
						|| (!deptId.equals("") && !legacyDeptCode.equals("") && !sessionDeptCode.equals("") && !legacyDeptCode.equalsIgnoreCase(sessionDeptCode))){ // 부서코드를 입력한경우, 로그인된 세션이 있고 부서가 다른경우(겸직체크)
            		mav.addObject("status", Return.FAIL);
					mav.addObject("message", "다른 사용자/겸직부서로 이미 로그인되어 있습니다.");
				}else{ 
					HttpSession session = request.getSession();
					boolean isMobile = ClientInfoHelper.isMobile(request);
					String sessionKey = "";
					String legacyDnCode = SessionHelper.getSession("DN_Code");
					String status = "SUCCESS";
					
					if((!legacyLogonID.equals("") && sessionLogonID.equals("")) // 로그인된 세션이 없는경우 세션생성
							|| (deptId.equals("") && !legacyDeptCode.equals("") && !sessionDeptCode.equals("") && !legacyDeptCode.equalsIgnoreCase(sessionDeptCode))){ // 부서코드 입력안했는데, 로그인세션이 있고 부서가다른경우 본직으로 세션변경 후 진행 
						// 로그인 처리
						// 아직 request에 세션 key가 없어서 SessionHelper.getSession 사용 불가, SessionHelper.simpleGetSession 사용 필요
						status = forLegacySvc.setFormLegacyLogin(response, session, legacyLogonID, legacyDeptCode, isMobile, lang);  
						
						if(!func.f_NullCheck(status).equals("SUCCESS")){
							mav.addObject("status", Return.FAIL);
							mav.addObject("message", "로그인 처리 중 오류가 발생하였습니다.");
						}else{
							sessionKey = (session.getAttribute("KEY") != null) ? session.getAttribute("KEY").toString() : "";
							legacyDnCode = SessionHelper.simpleGetSession("DN_Code",isMobile,sessionKey);
						}
					}
					
					if(func.f_NullCheck(status).equals("SUCCESS")){
						if(forLegacySvc.isLegacyFormCheck(legacyFormID, legacyDnCode)){ // 기간계 연동으로 등록된 양식인지 체크
							mav.addObject("status", Return.SUCCESS);
							mav.addObject("message", Return.SUCCESS);
							
							mav.addObject("URL", formInfo.getString("URL"));
							mav.addObject("logonid", legacyLogonID);
							mav.addObject("language", lang);
							
							
							mav.addObject("HTMLBody", new String(Base64.encodeBase64(formInfo.getString("HTMLBody").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
							mav.addObject("JSONBody", new String(Base64.encodeBase64(formInfo.getJSONObject("JSONBody").toString().getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
							mav.addObject("BodyContext", new String(Base64.encodeBase64(formInfo.getString("bodyContext").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
							mav.addObject("Subject", formInfo.optString("subject"));
							
							if(formInfo.has("MobileBody"))
								mav.addObject("MobileBody", new String(Base64.encodeBase64(formInfo.getString("MobileBody").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
							else
								mav.addObject("MobileBody", new String(Base64.encodeBase64(formInfo.getString("JSONBody").getBytes(StandardCharsets.UTF_8)),StandardCharsets.UTF_8));
						
						}else{
							mav.addObject("status", Return.FAIL);
							mav.addObject("message", "기간계 연동으로 등록된 양식이 아닙니다.");
						}
					}
				}
			}else{
				mav.addObject("status", Return.FAIL);
				mav.addObject("message", "로그인 정보가 없습니다.");
			}
		} catch (NullPointerException npE) {
			LOGGER.error("ForLegacyCon", npE);
			mav.addObject("status", Return.FAIL);
			mav.addObject("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error("ForLegacyCon", e);
			mav.addObject("status", Return.FAIL);
			mav.addObject("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return mav;
	}
	
	// 미사용(setFormLegacyLogin 에서 모두 처리하는것으로 변경)
	@RequestMapping(value = "legacy/loginchk.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap makeSessionForLegacy(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		StringUtil func = new StringUtil();	
		
		String paramId = StringUtil.replaceNull(request.getParameter("empno"), "");
		String authType = "SSO"; 
		String paramPwd = "";
		String paramLang = request.getParameter("language");
		
		CookiesUtil cUtil = new CookiesUtil();
		
		try{
			boolean isMobile = ClientInfoHelper.isMobile(request);
			String sessionUser = SessionHelper.getSession("USERID", isMobile);
			
			if(func.f_NullCheck(sessionUser).equals("")){
				CoviMap resultList = new CoviMap();
				resultList = forLegacySvc.checkAuthetication(authType, paramId, paramPwd, paramLang);
				CoviMap account = (CoviMap) resultList.get("account");
				
				HttpSession session = request.getSession();
				
				String key = cUtil.getCooiesValue(request);
				
				//세션 생성
				session.getServletContext().setAttribute(key, account.optString("UR_ID"));
				session.setAttribute("KEY", key);
				session.setAttribute("USERID", account.optString("UR_ID"));
				session.setAttribute("LOGIN", "Y");		
				
				SessionCommonHelper.makeSession(account.optString("UR_ID"), account, isMobile, key);
				//SessionHelper.setSession("SSO", authType);
				SessionHelper.setSimpleSession("lang", paramLang, isMobile, key);
					
				// 일회성으로 세션 생성&유지
				SessionHelper.setSession("OneTimeLogon", "Y", false);
				
				// 접속로그 생성
				LoggerHelper.connectLogger();
			}
			returnObj.put("status", "ok");
			returnObj.put("message", "");
		} catch (NullPointerException npE) {
			LOGGER.error("ForLegacyCon", npE);
			returnObj.put("status", "fail");
			returnObj.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error("ForLegacyCon", e);
			returnObj.put("status", "fail");
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	@RequestMapping(value = "legacy/draftForLegacy.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap draftForLegacy(MultipartHttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		
		String key = "";
		String subject = "";
		String empno = "";
		String logonId = "";
		String legacyFormID = "";
		String apvline = "";
		String bodyContext = "";
		String scChgrValue = "";
		String actionComment = "";
		String signImage = "";
		String deptcode = "";
		String lang = "";
		
		try{
			
			List<MultipartFile> mf = new ArrayList<>();
			
			if(request.getParameter("legacyFormID") != null){
				key = request.getParameter("key");
				subject = request.getParameter("subject");
				empno = request.getParameter("empno");
				logonId = request.getParameter("logonId");
				legacyFormID = request.getParameter("legacyFormID");
				apvline = request.getParameter("apvline");
				bodyContext = request.getParameter("bodyContext");
				scChgrValue = request.getParameter("scChgrValue"); //담당업무함
				actionComment = request.getParameter("actionComment");
				signImage = request.getParameter("signImage");
				deptcode = StringUtil.replaceNull(request.getParameter("deptId"), "");
				lang = StringUtil.replaceNull(request.getParameter("language"), "");

				mf = request.getFiles("attachFile[]");
				
				//첨부파일 확장자 체크
				if(!FileUtil.isEnableExtention(mf)){
					returnObj.put("status", Return.FAIL);
					returnObj.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
					return returnObj;
				}
			}else{
				String bodyInfo = HttpServletRequestHelper.getBody(request);
				String escaped = StringEscapeUtils.unescapeHtml(bodyInfo);
				CoviMap jsonObj = CoviMap.fromObject(escaped);
				
				key = jsonObj.optString("key");
				subject = jsonObj.optString("subject");
				empno = jsonObj.optString("empno");
				logonId = jsonObj.optString("logonId");
				legacyFormID = jsonObj.optString("legacyFormID");
				apvline = jsonObj.optString("apvline");
				bodyContext = jsonObj.optString("bodyContext");
				scChgrValue = jsonObj.optString("scChgrValue");
				actionComment = jsonObj.optString("actionComment");
				signImage = jsonObj.optString("signImage");
				deptcode = jsonObj.optString("deptId");
				lang = jsonObj.optString("language");
			}
			
			CoviMap logonUserInfo = forLegacySvc.selectLogonIDByDept(empno, logonId, deptcode); 
			empno = logonUserInfo.optString("LogonID");
			//deptcode = logonUserInfo.getString("DeptCode");
			if(empno.equals("")) {
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "사용자/부서 정보가 없습니다.");
				return returnObj;
			}
			
			// 기간계 연동으로 등록된 양식인지 체크 필요
			if(forLegacySvc.isLegacyFormCheck(legacyFormID)){
				CoviMap params = new CoviMap();
				params.put("key", key);
				params.put("subject", ComUtils.RemoveScriptAndStyle(subject));
				params.put("empno", empno);
				params.put("legacyFormID", legacyFormID);
				params.put("apvline", apvline);
				params.put("bodyContext", bodyContext);
				params.put("scChgrValue", scChgrValue);
				params.put("actionComment", actionComment);
				params.put("signImage", signImage);
				params.put("deptcode", deptcode);
				params.put("lang", lang);
				
				CoviMap formObj = new CoviMap();
				// 기안에 필요한 데이터 세팅
				params.put("isFile", !mf.isEmpty());
				formObj = forLegacySvc.makeFormObj(params);
				String reqFormInstID = formObj.optString("FormInstID");
				
				CoviMap processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, mf);
				
				try {
					formObj = forLegacySvc.draftForLegacy(formObj, processFormDataReturn);
				}catch(NullPointerException e) {
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
					LOGGER.error("ApvProcessCon", npE);
				} catch(Exception e) {
					LOGGER.error("ApvProcessCon", e);
				}
				
				returnObj.put("status", Return.SUCCESS);
				returnObj.put("message", Return.SUCCESS);
			}else{
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "기간계 연동으로 등록된 양식이 아닙니다.");
			}
		} catch (NullPointerException npE) {
			LOGGER.error("ForLegacyCon", npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error("ForLegacyCon", e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	@RequestMapping(value = "legacy/changeBodyContext.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap changeBodyContext(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		
		String processID = "";
		String userCode = "";
		String bodyContext = "";
		
		try{
			
			if(request.getParameter("processID") != null){
				processID = request.getParameter("processID");
				userCode = request.getParameter("userCode");
				bodyContext = request.getParameter("bodyContext");
			}else{
				String bodyInfo = HttpServletRequestHelper.getBody(request);
				String escaped = StringEscapeUtils.unescapeHtml(bodyInfo);
				CoviMap jsonObj = CoviMap.fromObject(escaped);
				
				processID = jsonObj.optString("processID");
				userCode = jsonObj.optString("userCode");
				bodyContext = jsonObj.optString("bodyContext");
			}
			
			// 기간계 연동으로 등록된 양식인지 체크 필요
			CoviMap formInfo = forLegacySvc.getFormLegacyInfo(processID);
			
			String mode = formInfo.getString("Mode");
			String legacyFormID = formInfo.getString("FormPrefix");
			
			if(forLegacySvc.isLegacyFormCheck(legacyFormID)){
				CoviMap params = new CoviMap();
				params.put("processID", processID);
				params.put("userCode", userCode);
				params.put("bodyContext", bodyContext);
				params.put("mode", mode);
				params.put("legacyFormID", legacyFormID);
				
				forLegacySvc.changeBodyContext(params);
				
				returnObj.put("status", Return.SUCCESS);
				returnObj.put("message", Return.SUCCESS);
			}else{
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", "기간계 연동으로 등록된 양식이 아닙니다.");
			}
		} catch (NullPointerException npE) {
			LOGGER.error("ForLegacyCon", npE);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error("ForLegacyCon", e);
			returnObj.put("status", Return.FAIL);
			returnObj.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	// 연동시스템 테이블 설정 리스트
	@RequestMapping(value = "legacy/getDraftLegacySystemList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDraftLegacySystemList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String pageNo = Objects.toString(request.getParameter("pageNo"), "1");
			String pageSize = Objects.toString(request.getParameter("pageSize"), "10");
			String sortColumn = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[0]:"";
			String sortDirection = request.getParameter("sortBy")!=null?request.getParameter("sortBy").split(" ")[1]:"";
			String searchType = request.getParameter("SearchType");
			String searchText = request.getParameter("SearchText");
			String icoSearch = Objects.toString(request.getParameter("icoSearch"), "");
		
			CoviMap resultList = null;
			CoviMap params = new CoviMap();			
			//params.put("lang", SessionHelper.getSession("lang"));
			params.put("pageNo", pageNo);
			params.put("pageSize", pageSize);
			params.put("sortColumn",ComUtils.RemoveSQLInjection(sortColumn, 100));
			params.put("sortDirection",ComUtils.RemoveSQLInjection(sortDirection, 100));
			params.put("SearchType",ComUtils.RemoveSQLInjection(searchType, 100));
			params.put("SearchText",ComUtils.RemoveSQLInjection(searchText, 100));
			params.put("icoSearch", ComUtils.RemoveSQLInjection(icoSearch, 100));
			
			resultList = forLegacySvc.selectDraftLegacySystemList(params);
			
			returnList.put("page",resultList.get("page"));
			returnList.put("list", resultList.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 연동시스템 테이블 설정 상세 데이터 조회
	@RequestMapping(value = "legacy/getDraftLegacySystemData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDraftLegacySystemData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {				
			String legacyID = request.getParameter("LegacyID");
			
			CoviMap resultList = null;
			CoviMap params = new CoviMap();		
			params.put("LegacyID", legacyID);
			
			resultList = forLegacySvc.selectDraftLegacySystemData(params);
			
			returnList.put("list", resultList.get("map"));			
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	// 연동시스템 테이블 설정 추가/수정
	@RequestMapping(value = "legacy/setDraftLegacySystemData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap setDraftLegacySystemData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			String queryType = request.getParameter("QueryType");
			String legacyID = request.getParameter("LegacyID");
			String systemCode = request.getParameter("SystemCode");
			String datasourceSeq = request.getParameter("DatasourceSeq");
			String dataTableName = request.getParameter("DataTableName");
			String dataTableKeyName = request.getParameter("DataTableKeyName");
			String subjectKeyName = request.getParameter("SubjectKeyName");
			String empnoKeyName = request.getParameter("EmpnoKeyName");
			String deptKeyName = request.getParameter("DeptKeyName");
			String multiTableName = request.getParameter("MultiTableName");
			String multiTableKeyName = request.getParameter("MultiTableKeyName");
			String formPrefix = request.getParameter("FormPrefix");
			String description = request.getParameter("Description");
			
			
			CoviMap params = new CoviMap();			
			params.put("LegacyID", legacyID);
			params.put("SystemCode", ComUtils.RemoveSQLInjection(systemCode, 1000));
			params.put("DatasourceSeq", datasourceSeq);
			params.put("DataTableName", ComUtils.RemoveSQLInjection(dataTableName, 1000));
			params.put("DataTableKeyName", ComUtils.RemoveSQLInjection(dataTableKeyName, 1000));
			params.put("SubjectKeyName", ComUtils.RemoveSQLInjection(subjectKeyName, 2000));
			params.put("EmpnoKeyName", ComUtils.RemoveSQLInjection(empnoKeyName, 1000));
			params.put("DeptKeyName", ComUtils.RemoveSQLInjection(deptKeyName, 1000));
			params.put("MultiTableName", ComUtils.RemoveSQLInjection(multiTableName, 1000));
			params.put("MultiTableKeyName", ComUtils.RemoveSQLInjection(multiTableKeyName, 1000));
			params.put("FormPrefix", ComUtils.RemoveSQLInjection(formPrefix, 1000));
			params.put("Description", ComUtils.RemoveSQLInjection(description, 0));
			params.put("ModifierCode",SessionHelper.getSession("USERID"));
			
			int cnt = 0;
			if(queryType.equalsIgnoreCase("Edit")) {
				cnt = forLegacySvc.updateDraftLegacySystemData(params);
			}else if(queryType.equalsIgnoreCase("Add")) {
				cnt = forLegacySvc.insertDraftLegacySystemData(params);
			}
			returnList.put("object", cnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "저장되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	// 연동시스템 테이블 설정 삭제
	@RequestMapping(value = "legacy/deleteDraftLegacySystemData.do", method = {RequestMethod.GET,RequestMethod.POST}, produces = "application/json;charset=UTF-8")	
	public @ResponseBody CoviMap deleteDraftLegacySystemData(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			CoviMap params = new CoviMap(paramMap);			
			
			returnList.put("object", forLegacySvc.deleteDraftLegacySystemData(params));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "삭제되었습니다.");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;	
	}
	
	// 테스트 데이터 가져오기 - 가이드 3 내부 중간테이블 , 가이드 4 연동시스템 테이블
	@RequestMapping(value = "legacy/getDraftLegacyGuideList.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getDraftLegacyList(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();
		
		try {
			
			CoviMap resultList3 = null;
			CoviMap resultList4 = null;
			CoviMap params = new CoviMap();			
			
			resultList3 = forLegacySvc.selectDraftLegacyList(params);
			resultList4 = forLegacySvc.selectDraftSampleList(params);
			
			returnList.put("list3", resultList3.get("list"));
			returnList.put("list4", resultList4.get("list"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
			
		} catch (NullPointerException npE) {
			LOGGER.error(npE.getLocalizedMessage(), npE);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnList;
	}
	
	
	/**
	 * 기간계 I/F 테스트 페이지 >> 미사용
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "legacy/LegacyTest.do")
	public @ResponseBody String legacyTest(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap)
	{
		return "미사용, [간편관리자(그룹웨어관리) > 전자결재관리 > 기안연동관리 > 기안연동가이드] 으로 통합";
		//return new ModelAndView("legacy/LegacyTest");
	}
	
	// 미사용
	@RequestMapping(value = "legacy/LegacyList.do")
	public @ResponseBody String legacyTest_YP(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		return "미사용, [간편관리자(그룹웨어관리) > 전자결재관리 > 기안연동관리 > 기안연동가이드] 으로 통합";
		//return new ModelAndView("legacy/LegacyList");
	}

	@RequestMapping(value = "legacy/DraftLegacyGuide.do")
	public @ResponseBody ModelAndView draftLegacyGuide(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap)
	{
		return new ModelAndView("legacy/DraftLegacyGuide");
	}
	
	@RequestMapping(value = "legacy/goDraftLegacySystemManagePop.do")
	public @ResponseBody ModelAndView draftLegacySystemManagePop(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap)
	{
		return new ModelAndView("manage/approval/DraftLegacySystemManagePop");
	}
	
	/***
	 * 
	 * 팀즈 연동 (POST) ex) http://localhost:8080/approval/legacy/TeamsLegacyLink.do
	 * 
	 * @param request
	 * @param response
	 * @return
	 */
	@RequestMapping(value = "legacy/TeamsLegacyLink.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap formLegacyLink(HttpServletRequest request, HttpServletRequest response) {

		CoviMap returnObj = new CoviMap();
		/* Input 
		 * apvMode : 승인(APPROVAL), 반려(REJECT)
		 * processId : 프로세스 아이디
		 * approverId : 결재자 아이디
		 * comment : 결재의견
		 * empno : 부서코드 (가져옴)
		 * apvline : 결재선 (가져옴)
		 *
		 * OutPut
		 * status : 상태
		 * message :오류 메시지
		 */
		
		String apvMode = ""; //승인인지 반려인지
		String processId = ""; // 프로세스 아이디
		String approverId =""; // 결재자 아이디
		String comment = ""; //의견
		
		String apvCode = "";	
		String apvMsg = "";
		
		CoviMap params = new CoviMap();
		CoviMap jsonObj = new CoviMap();
		

		try {
			String bodyInfo = HttpServletRequestHelper.getBody(request);
			LOGGER.info("LEGACYINFO:", bodyInfo);
			String escaped = StringEscapeUtils.unescapeHtml(bodyInfo);
			jsonObj = CoviMap.fromObject(escaped);
			
			if (jsonObj != null) {
				// 공통 영역
				apvMode = StringUtil.replaceNull(jsonObj.getString("apvMode")); //승인,반려
				processId = StringUtil.replaceNull(jsonObj.getString("processId")); //프로세스 아이디
				approverId = StringUtil.replaceNull(jsonObj.getString("approverId"));//결재자 아이디
				comment = StringUtil.replaceNull(jsonObj.getString("comment"));//결재자 아이디
				
				apvMsg = "SUCCESS";
				CoviMap logonUserInfo = new CoviMap();
				logonUserInfo = forLegacySvc.selectLogonID("", approverId);

				String empno = logonUserInfo.getString("LogonID"); //사번
				String deptcode = logonUserInfo.getString("DeptCode"); //부서코드

				params.put("apvMode", apvMode); //승인,반려
				params.put("piid", processId); //프로세스아이디
				params.put("empno", empno); //사번
				params.put("deptcode", deptcode); //부서코드
				params.put("comment", comment); //의견
				
				//보내는 값 : 승인/반려 여부, 프로세스 아이디, 결재자 아이디,부서코드
				if (!StringUtil.replaceNull(processId, "").equals("")) {
						CoviMap processResult = formLegacySvc.doAction(params);
						if (processResult.containsKey("status")
								&& processResult.getString("status").equalsIgnoreCase("SUCCESS")) {

						}
						else {
							apvMsg = apvMode + "시스템 문제가 발생하였습니다. 관리자에게 문의하세요.";
						}
						returnObj = processResult;
					} else {
						apvMsg = apvMode + "시스템 문제가 발생하였습니다. 관리자에게 문의하세요.";
					}
			
			} else {
				apvMsg = "parameter error";
			}

		} catch (NullPointerException npE) {
			LOGGER.error("ForLegacyCon : ", npE);
			apvMsg = npE.getMessage();
		} catch (Exception e) {
			LOGGER.error("ForLegacyCon : ", e);
			apvMsg = e.getMessage();
		} finally {

			try {

				// 공통 code 처리
				if (!apvMsg.equalsIgnoreCase("SUCCESS")) {
					apvCode = "9999";
				} else {
					apvCode = "0000";
				}

				/* 로그 처리 영역 */
				CoviMap logMap = new CoviMap();
				logMap.put("apvID", apvMode);
				logMap.put("apvCode", apvCode);
				logMap.put("apvMsg", apvMsg);
				logMap.put("jsonBody", jsonObj.getJSONObject("BODY").toString());
				logMap.put("formInstID", (params.containsKey("fiid") ? params.getString("fiid") : ""));
				logMap.put("approverId", (params.containsKey("approverId") ? params.getString("approverId") : ""));

				formLegacySvc.writeLog(logMap);
			} catch (NullPointerException npE) {
				LOGGER.error("ForLegacyCon writeLog : ", npE);
			} catch (Exception e) {
				LOGGER.error("ForLegacyCon writeLog : ", e);
			}

			if (!apvMsg.equalsIgnoreCase("SUCCESS")) {
				apvMsg = "Y".equals(isDevMode) ? apvMsg : DicHelper.getDic("msg_apv_030");
			}
		}
		return returnObj;
	}
	
}
