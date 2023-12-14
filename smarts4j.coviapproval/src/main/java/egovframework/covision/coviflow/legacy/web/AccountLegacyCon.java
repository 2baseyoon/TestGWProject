package egovframework.covision.coviflow.legacy.web;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.admin.service.MonitoringSvc;
import egovframework.covision.coviflow.form.service.ApvProcessSvc;
import egovframework.covision.coviflow.legacy.service.ForLegacySvc;
import egovframework.covision.coviflow.user.service.RightApprovalConfigSvc;



@Controller
public class AccountLegacyCon {
	
	@Autowired
	private ForLegacySvc forLegacySvc;

	@Autowired
	private ApvProcessSvc apvProcessSvc;

	@Autowired
	private MonitoringSvc monitoringSvc;
	
	@Autowired
	private RightApprovalConfigSvc rightApprovalConfigSvc;

	private Logger LOGGER = LogManager.getLogger(AccountLegacyCon.class);
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	@RequestMapping(value = "legacy/draftForAccount.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap draftForAccount(MultipartHttpServletRequest request, HttpServletResponse response,@RequestParam Map<String, String> paramMap) throws Exception
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
		String g_authKey = "";
		String g_password = "";
		String formDraftkey = "";
		String formID = "";
		String lang = "";
		
		try{
			
			List<MultipartFile> mf = new ArrayList<MultipartFile>();
			
			key = request.getParameter("key");
			subject = request.getParameter("subject");
			empno = request.getParameter("empno");
			logonId = request.getParameter("logonId");
			legacyFormID = request.getParameter("legacyFormID");
			apvline = request.getParameter("apvline");
			bodyContext = request.getParameterValues("bodyContext")[0];
			scChgrValue = request.getParameter("scChgrValue"); //담당업무함
			actionComment = request.getParameter("actionComment");
			signImage = request.getParameter("signImage");
			g_authKey = request.getParameter("g_authKey");
			g_password = request.getParameter("g_password");
			formDraftkey = request.getParameter("formDraftkey");
			formID = request.getParameter("formID");
			deptcode = StringUtil.replaceNull(request.getParameter("deptId"), "");
			lang = StringUtil.replaceNull(request.getParameter("language"), "");
			
			AES aes = new AES("", "P");
			g_password = aes.pb_decrypt(g_password);
			
//			보안이슈 사용자 인증 체크 2021-01-18 dgkim
			if(apvProcessSvc.getIsUsePasswordForm(formID)) {
				try {
					String fidoUse = PropertiesUtil.getSecurityProperties().getProperty("fido.login.used");

					String userCode = SessionHelper.getSession("UR_Code");
					Boolean chkUsePasswordYN = false;						
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
						if (g_password.length() > 0
								&& chkUsePasswordYN) {
							if (!apvProcessSvc.chkCommentWrite(logonId, g_password))
								throw new Exception();
						} else if (fidoUse.equals("Y") && g_authKey.length() > 0) {
							params.put("authKey", g_authKey);
							params.put("authType", "account");
							params.put("logonID", logonId);
							String status = apvProcessSvc.selectFidoStatus(params);
							if (null == status || status.trim().length() == 0 || !status.equals("Succ"))
								throw new Exception();
						} else {
							throw new Exception();
						}

					}
				} catch (NullPointerException npE) {
					throw new Exception(DicHelper.getDic("msg_apv_fido_chk"));
				} catch (Exception e) {
					throw new Exception(DicHelper.getDic("msg_apv_fido_chk"));
				}
			}			
			
			mf = request.getFiles("attachFile[]");
			
			//첨부파일 확장자 체크
			if(!FileUtil.isEnableExtention(mf)){
				returnObj.put("status", Return.FAIL);
				returnObj.put("message", DicHelper.getDic("msg_ExistLimitedExtensionFile"));
				return returnObj;
			}
			
			CoviMap logonUserInfo = forLegacySvc.selectLogonIDByDept(logonId, deptcode); 
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
				// 본문 저장관련해서 호출 분리함.
				CoviMap processFormDataReturn = apvProcessSvc.doCreateInstance("PROCESS", formObj, mf);
				
				try {
					forLegacySvc.draftForLegacy(formObj, processFormDataReturn);
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
	 * doAction : rest api 호출
	 * @param request
	 * @param response
	 * @param paramMap
	 * @return returnList
	 * @throws Exception tempSaveDoc
	 */
	@RequestMapping(value = "legacy/doActionForAccount.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap doAction(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> paramMap) throws Exception
	{
		//CoviMap resultList = new CoviMap();
		CoviMap returnList = new CoviMap();
		
		try {
			String pTaskId = paramMap.get("id");
			//CoviMap pData = CoviMap.fromObject(paramMap.get("data"));
			CoviMap pData = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(request.getParameter("data")));
			String pFormInstID = paramMap.get("formInstID");
			boolean bAbort = false;
			Boolean bAccount = false;
			CoviMap appvLine = new CoviMap();
			CoviList commentFileInfos = new CoviList();

//			보안이슈 사용자 인증 체크 2021-01-18 dgkim
			if(apvProcessSvc.getIsUsePasswordForm(pData.getString("formID"))) {
				try {
					String fidoUse = PropertiesUtil.getSecurityProperties().getProperty("fido.login.used");
					String g_password = pData.getString("g_password");
					String g_authKey = pData.getString("g_authKey");
					String logonId = pData.getString("logonId");
					AES aes = new AES("", "P");
					g_password = aes.pb_decrypt(g_password);
					
					String userCode = SessionHelper.getSession("UR_Code");
					Boolean chkUsePasswordYN = false;						
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
						if (g_password.length() > 0
								&& chkUsePasswordYN) {
							if (!apvProcessSvc.chkCommentWrite(logonId, g_password))
								throw new Exception();
						} else if (fidoUse.equals("Y") && g_authKey.length() > 0) {
							params.put("authKey", g_authKey);
							params.put("authType", "account");
							params.put("logonID", logonId);
							String status = apvProcessSvc.selectFidoStatus(params);
							if (null == status || status.trim().length() == 0 || !status.equals("Succ"))
								throw new Exception();
						} else {
							throw new Exception();
						}

					}
				} catch (NullPointerException npE) {
					throw new Exception(DicHelper.getDic("msg_apv_fido_chk"));
				} catch (Exception e) {
					throw new Exception(DicHelper.getDic("msg_apv_fido_chk"));
				}
			}	
			
			CoviList variables = new CoviList();
			for (Object key : pData.keySet()) {
				String keyStr = (String) key;
				
				if(keyStr.equals("isAccount") && pData.get(keyStr).equals("Y")) {
					bAccount = true;
					continue;
				}
				
				if(keyStr.equals("formID") || keyStr.equals("g_password") || keyStr.equals("g_authKey") || keyStr.equals("g_authToken")|| keyStr.equals("logonId"))
					continue;
				
				// 기안 취소인치 체크
				if(pData.get(keyStr).equals("WITHDRAW") || pData.get(keyStr).equals("ABORT")) {
					bAbort = true;
				}
				if(bAbort && keyStr.indexOf("g_appvLine") > -1) {
					appvLine = (CoviMap) pData.get(keyStr);
					continue; // 기안취소 시에는 결재선 변경 없음. 최종결재선 저장하기 위한 용도
				}
				if(bAbort && keyStr.indexOf("commentFileInfos") > -1) {
					commentFileInfos = CoviList.fromObject(pData.getString(keyStr));
					continue;
				}

				CoviMap variable = new CoviMap();
				
				Object value = pData.get(keyStr);
				if(keyStr.indexOf("g_actioncomment_attach_") > -1) {
					value = pData.getJSONArray(keyStr);
				}
				variable.put("name", keyStr);
				variable.put("value", value);
				variable.put("scope", "global");
				
				variables.add(variable);
			}
						
			CoviMap param = new CoviMap();
			param.put("action", "complete");
			param.put("variables", variables);
			
			monitoringSvc.doAction(pTaskId, param);
			
			//문서발번 처리
			if(!pFormInstID.equals(""))
				monitoringSvc.updateFormInstDocNumber(pFormInstID);
			
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
}
