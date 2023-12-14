package egovframework.covision.coviflow.user.web;

import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.AuthHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.legacy.service.MessageSvc;
import egovframework.covision.coviflow.user.service.RightApprovalConfigSvc;


/**
 * @Class Name : RightApprovalConfigCon.java
 * @Description : 사용자 메뉴 > 개인환경설정 요청 처리
 * @ 2016.10.27 최초생성
 *
 * @author 코비젼 연구소
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class RightApprovalConfigCon {

	@Autowired
	private AuthHelper authHelper;

	private Logger LOGGER = LogManager.getLogger(RightApprovalConfigCon.class);

	@Autowired
	private RightApprovalConfigSvc rightApprovalConfigSvc;
	
	@Autowired
	private MessageSvc messageSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * getpersondirectorofunitlist : 사용자 메뉴 - 개인환경설정 : 전자결재 개인 환경 설정값 조회
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/getPersonSetting.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap getPersonSetting(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try	{

			//현재 사용자 ID
			String userCode = SessionHelper.getSession("USERID");

			CoviMap params = new CoviMap();

			params.put("UR_CODE",userCode);

			CoviMap resultList = rightApprovalConfigSvc.selectUserSetting(params);

			returnList.put("list", resultList.get("map"));
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException npE) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
			return returnList;
	}

	/**
	 * getjfauth : 사용자 메뉴 - 개인환경설정 - 전자결재 환경설정: 설정사항 저장
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception
	 */
	@RequestMapping(value = "user/updateUserSetting.do")
	public @ResponseBody CoviMap updateUserSetting(HttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
	{
		CoviMap returnList = new CoviMap();

		try {
			String userCode = SessionHelper.getSession("USERID");
			String deputyCode = request.getParameter("DeputyCode");
			String deputyName = request.getParameter("DeputyName");
			String deputyYN = request.getParameter("DeputyYN");
			String deputyReason = request.getParameter("DeputyReason");
			String deputyOption = request.getParameter("DeputyOption"); // [2019-02-19 ADD] gbhwang 대결 설정 시 옵션 추가
			String approvalPassword = request.getParameter("ApprovalPassword");
			String approvalAlarm = StringUtil.replaceNull(request.getParameter("ApprovalAlarm"));
			String approvalPWUse = request.getParameter("ApprovalPWUse");
			String passwordChangeYN = StringUtil.replaceNull(request.getParameter("passwordChangeYN"));
			approvalAlarm = approvalAlarm.replace("&quot;","\"");
			String isMobile = "N";
			String deputyFromDate = request.getParameter("DeputyFromDate") != null && request.getParameter("DeputyFromDate").length() > 0 ? ComUtils.TransServerTime(request.getParameter("DeputyFromDate") + " 00:00","yyyy-MM-dd HH:mm") : "";
			String deputyToDate =  request.getParameter("DeputyToDate") != null && request.getParameter("DeputyToDate").length() > 0 ?  ComUtils.TransServerTime(request.getParameter("DeputyToDate") + " 23:59","yyyy-MM-dd HH:mm") : "";
			String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
			if(request.getParameterMap().containsKey("IsMobile")) {
				isMobile = request.getParameter("IsMobile");
			}
			
			AES aes = new AES("", "P");
			approvalPassword = aes.pb_decrypt(approvalPassword);
			String messageContext =  DicHelper.getDic("Approval_DeputyName")+" : "+deputyName+"<br/>"
									+DicHelper.getDic("Approval_DeputyDate")+" : "+deputyFromDate+"~"+deputyToDate+"<br/>"
									+DicHelper.getDic("Approval_DeputyReason")+" : "+deputyReason;
			CoviMap params = new CoviMap();

			params.put("UR_Code",userCode);
			params.put("DeputyName",deputyName);
			params.put("DeputyFromDate",deputyFromDate);
			params.put("DeputyToDate",deputyToDate);
			params.put("DeputyYN",deputyYN);
			params.put("DeputyReason",deputyReason);
			params.put("DeputyOption",deputyOption); // [2019-02-19 ADD] gbhwang 대결 설정 시 옵션 추가
			params.put("Password",approvalPassword);
			params.put("Alarm",approvalAlarm);
			params.put("IsMobile",isMobile);
			params.put("ApprovalPWUse",approvalPWUse);
			params.put("passwordChangeYN",passwordChangeYN);
			params.put("aeskey", aeskey);
			
			params.put("DeputyCode",deputyCode); //대결지정자
			params.put("ServiceType", "Approval");
			params.put("MsgType", "Approval_DEPUTY");
			params.put("SenderCode",  userCode); //발신자
			params.put("RegistererCode",  userCode); 
			params.put("ReceiversCode",  deputyCode); //수신자
			params.put("MessagingSubject",  DicHelper.getDic("ApprovalAlarm_setDeputy")); //대결자로 지정되었습니다.
			params.put("MessageContext",  messageContext); //대결 지정자, 대결 기간, 대결 사유
			
			if(passwordChangeYN.equals("Y")) {
				CoviMap validationResult = checkPasswordValidation(params);
				if(validationResult.getInt("result") != 1 ){
					returnList.put("result", "fail");
					returnList.put("status", Return.FAIL);
					returnList.put("message", validationResult.getString("message"));
					return returnList;
				}
			}
			int cnt = rightApprovalConfigSvc.updateUserSetting(params);
			
			//대결자로 지정된 사용자에게 메일 발송
			messageSvc.callMessagingProcedure(params);
			
			returnList.put("cnt", cnt);
			returnList.put("result", "ok");
			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "등록되었습니다");
			
		}catch(NullPointerException npE){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?npE.getMessage():DicHelper.getDic("msg_apv_030"));
		}catch(Exception e){
			returnList.put("status", Return.FAIL);
			returnList.put("message", "Y".equals(isDevMode)?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}

		return returnList;
	}


	/**
	 * goRightApprovalJobFunctionSetPopup : 개인환경설정 - 답당업무함의 담당자보기 팝업
	 * @param locale
	 * @param model
	 * @return mav
	 */
	@RequestMapping(value = "user/goRightApprovalJobFunctionSetPopup.do", method = RequestMethod.GET)
	public ModelAndView goRightApprovalJobFunctionSetPopup(Locale locale, Model model) {
		String returnURL = "user/approval/RightApprovalJobFunctionSetPopup";
		return new ModelAndView(returnURL);
	}

	public CoviMap checkPasswordValidation(CoviMap params) throws Exception
	{
		CoviMap resultObj = new CoviMap();
		resultObj.put("result", 0);
		
		String patternStr = null;
		String patternMsg = "";
		String Password = params.getString("Password");
		
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		
		CoviMap policyConfig = rightApprovalConfigSvc.selectApprovalPasswordPolicy(params);
		
		if(policyConfig.getInt("IsUseComplexity") == 1) {
			patternStr = "^.*(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d].*$";
			patternMsg = String.format(DicHelper.getDic("msg_ChangePasswordDSCR08").replace("{0}","%d"), policyConfig.getInt("MinimumLength"));
		}else if(policyConfig.getInt("IsUseComplexity") == 2) {
			patternStr = "^.*(?=.*\\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=*]).*$";
			patternMsg = String.format(DicHelper.getDic("msg_ChangePasswordDSCR07").replace("{0}","%d"), policyConfig.getInt("MinimumLength"));
		}else if(policyConfig.getInt("IsUseComplexity") == 3) {
			patternStr = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&+=*])[A-Za-z\\d!@#$%^&+=*].*$";
			patternMsg = String.format(DicHelper.getDic("msg_ChangePasswordDSCR06").replace("{0}","%d"), policyConfig.getInt("MinimumLength"));
		}
		
		
		if(Password.isEmpty()) {
			resultObj.put("message", DicHelper.getDic("msg_PasswordChange_04")); //새 비밀번호를 입력하여 주십시오.
		}else if(Password.length() < policyConfig.getInt("MinimumLength")) {
			resultObj.put("message", String.format(DicHelper.getDic("msg_ChangePasswordDSCR09").replace("{0}","%d"), policyConfig.getInt("MinimumLength")));
		}else if(patternStr != null && !Pattern.matches(patternStr, Password)) {
			resultObj.put("message", patternMsg);
		}else {
			resultObj.put("result", 1);
		}
		
		return resultObj;
	}	
}