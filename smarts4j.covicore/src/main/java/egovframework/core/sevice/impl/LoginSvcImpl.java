package egovframework.core.sevice.impl;

import java.util.HashMap;
import java.util.regex.Pattern;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.LoginSvc;
import egovframework.core.sevice.OrgSyncManageSvc;
import egovframework.core.web.SsoSamlCon;
import egovframework.coviframework.base.TokenHelper;
import egovframework.coviframework.util.ADAuthUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.coviframework.util.SessionCommonHelper;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


import egovframework.baseframework.util.json.JSONSerializer;

@Service("loginService")
public class LoginSvcImpl extends EgovAbstractServiceImpl implements LoginSvc{

	@Autowired
	private OrgSyncManageSvc orgSyncManageSvc;
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	private String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
	
	@Override
	public int saveLoginInfo(CoviMap account)throws Exception{
		return coviMapperOne.update("common.login.updateUserInfo", account);	//로그온 회수 증가 및 세션ID갱신
	}
	
	@Override
	public CoviMap checkAuthetication(String authType, String id, String password, String locale) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		/*
		 * 인증 처리를 세분화 할 것
		 * */
		boolean isAuthenticated = false;
		switch(authType){
			case "DB":
				int resultCnt = checkDB(id, password, "NONE");
				
				if(resultCnt > 0){
					isAuthenticated = true;
				}
				break;
			case "SAML":
			case "OAUTH":
			case "SSO":
				isAuthenticated = true;
				break;
			case "OTP":
				break;		
			default :
				break;
		}
		
		
		if ( isAuthenticated) 
		{
			//account 획득
			CoviMap params = new CoviMap();
			params.put("id", id);
			params.put("password", password);
			params.put("lang", locale);
			params.put("aeskey", aeskey);
			
			CoviMap account  = new CoviMap();
			
			if("SSO".equals(authType) || "SAML".equals(authType) || "OAUTH".equals(authType)){
				account = coviMapperOne.select("common.login.selectSSO", params);
			}else{
				account = coviMapperOne.select("common.login.select", params);
			}
			
//			params.put("userCode",account.get("UR_Code"));
			
			resultList.put("map", CoviSelectSet.coviSelectJSON(account, "LanguageCode,LogonID,URBG_ID,LogonPW,UR_ID,UR_Code,UR_EmpNo,UR_Name,UR_Mail,UR_JobPositionCode,UR_JobPositionName,UR_JobTitleCode,UR_JobTitleName,UR_JobLevelCode,UR_JobLevelName,UR_ManagerCode,UR_ManagerName,UR_IsManager,DN_ID,DN_Code,DN_Name,GR_Code,ApprovalParentGR_Code,ApprovalParentGR_Name,GR_Name,GR_GroupPath,GR_FullName,UR_ThemeType,UR_ThemeCode,SubDomain,Attribute,UR_MultiName,UR_MultiJobPositionName,UR_MultiJobTitleName,UR_MultiJobLevelName,GR_MultiName,AssignedBizSection"));		
			resultList.put("account", account);

			resultList.put("status", "OK");
			
		} else {
			resultList.put("account", null);
			resultList.put("status", "NOT");

		}
		
		return resultList;
	}
	
	
	private int checkDB(String id, String password, String pwdEncType) throws Exception{
		int iRet = 0;
		String encryptedPwd = null;
		
		//향후 password는 암호화를 구현 할 것
		switch(pwdEncType){
		case "NONE": 
			encryptedPwd = password;
			break;
			
		case "3DES":
			break;
			
		case "MD5":
			break;
			
		default : encryptedPwd = password;
			break;
	}
		
		CoviMap params = new CoviMap();
		params.put("id", id);
		params.put("password", encryptedPwd);
		params.put("aeskey", aeskey);
		
		iRet = (int) coviMapperOne.getNumber("common.login.selectCount", params);
		
		return iRet;
	}
	
	public String checkSSO(String OpType){
		String value = "";
		CoviMap params = new CoviMap();
		
		switch(OpType){
		 case "SERVER":
			params.put("Code", "sso_server");
			break;
		 case "DAY":
			params.put("Code","sso_expiration_day");
			break;
		 case "URL":
			params.put("Code","sso_sp_url");
			break;	
		 case "ACS":
			params.put("Code","sso_acs_url");
			break;
		 case "SPACS":
			params.put("Code","sso_spacs_url");
			break;	
		 case "RS":
			params.put("Code","sso_rs_url");
			break;			
		 default: 
			 params.put("Code","sso_storage_path");
			 break;
		}
		params.put("DomainID", "0");
		value = (String) coviMapperOne.getString("common.login.selectSSOValue", params);
		return value;
	}
	
	public CoviMap selectSamlUser(String id) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		//account 획득
		CoviMap params = new CoviMap();
		params.put("id", id);
		
		CoviMap account;
			
		account = coviMapperOne.select("common.login.selectSSO", params);
		
		resultList.put("status", "OK");
		resultList.put("account", account);
		
		return resultList;
	}
	
	public int checkUserAuthetication(String id, String password) throws Exception
	{
		CoviMap params = new CoviMap();
		params.put("id", id);
		params.put("password", password);
		params.put("aeskey",aeskey);
		
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("common.login.selectCount", params);
		
		return cnt;
	}

	public int checkSSOUserAuthetication(String id) throws Exception
	{
		CoviMap params = new CoviMap();
		params.put("id", id);
		
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("common.login.selectSSOCount", params);
		
		return cnt;
	}
	
	public boolean insertTokenHistory(String key, String urId, String urName, String urCode, String empNo, String maxAge, String type, String assertion_id )throws Exception{
		CoviMap params = new CoviMap();
		
		params.put("token", key);
		params.put("urid", urId);
		params.put("urname", urName);
		params.put("urcode", urCode);
		params.put("empno", empNo);
		params.put("maxage", maxAge);
		params.put("type", type);
		params.put("assertion_id", assertion_id);
		
		int cnt=0;
		boolean flag = false;
		cnt = (int) coviMapperOne.insert("common.login.ssoTokenHistory", params);
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	public CoviMap selectTokenInForMation(String key) throws Exception
	{
		CoviMap resultList = new CoviMap();
		
		//account 획득
		CoviMap params = new CoviMap();
		params.put("key", key);
			
		CoviMap account;
			
		account = coviMapperOne.select("common.login.selectTokenInForMation", params);
				
		resultList.put("map", CoviSelectSet.coviSelectJSON(account, "TOKEN, LogonID, UR_Name, UR_Code, UR_EmpNo, MAXAGE, MODIFIERDATE"));		
			
		resultList.put("account", account);
		resultList.put("status", "OK");
		
		return resultList;
	}
	
	@Override
	public  CoviMap getMyInfo(String key) throws Exception {
		CoviMap resultList = null;
		CoviMap map = null;
		
		resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("userId", key);
		params.put("lang", SessionHelper.getSession("lang"));
		
		map = coviMapperOne.select("common.login.getMyInfo", params);
		
		resultList = CoviSelectSet.coviSelectJSON(map, "LogonID,DisplayName,DeptName,JobPositionName,JobLevelName,JobTitleName,Description,Birthdate,BirthDiv,IsBirthLeapMonth,PhoneNumber,PhoneNumberInter,Mobile,Fax,PhotoPath,MailAddress,ChargeBusiness,CompanyCode,MultiCompanyName").getJSONObject(0);
			
		return resultList; 
	}
	
	@Override
	public  CoviList getAddJobList(String key) throws Exception {
		CoviList resultList = null;
		CoviList clist = null;
		
		resultList = new CoviList();
		
		CoviMap params = new CoviMap();
		params.put("userId", key);
		params.put("lang", SessionHelper.getSession("lang"));
		
		clist = coviMapperOne.list("common.login.getAddJobList", params);
		resultList = CoviSelectSet.coviSelectJSON(clist, "JobType,DisplayName,DeptName,JobTitleName,JobPositionName,JobLevelName");
			
		return resultList; 
	}
	
	// 개인환경설정 > 비밀번호 변경 > 기존 패스워드 조회
	@Override
	public CoviMap getUserLoginPassword(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("common.login.selectUserLoginPassword", params);		
		CoviMap resultList = new CoviMap();		
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "LogonPassword,BirthDate,Mobile"));	
		
		return resultList;
	}
	
	// 개인환경설정 > 비밀번호 변경 > 변경
	@Override
	public String updateUserPassword(CoviMap params,HttpServletRequest request, HttpServletResponse response) throws Exception {
		int result = 0;
		String reMsg = "";
		
		StringUtil func = new StringUtil();
		CookiesUtil cUtil = new CookiesUtil();
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		String body = "";
		String loginID = SessionHelper.getSession("LogonID");
		String userCode = SessionHelper.getSession("USERID");
		String mail = SessionHelper.getSession("UR_Mail");
		String subDomain = SessionHelper.getSession("SubDomain");
		StringBuffer returnMsg = new StringBuffer();
		
		CoviMap resultList = new CoviMap();

		boolean isIndiSync = false;
		
		isIndiSync = RedisDataUtil.getBaseConfig("IsSyncIndi",SessionHelper.getSession("DN_ID")).equals("Y") ? true : false;
		
		if(!func.f_NullCheck(mail).equals("") && isIndiSync && SessionHelper.getSession("UR_UseMailConnect").equals("Y")){
			params.put("LogonID",  loginID);
			params.put("LogonPW",params.getString("newPassword"));
			params.put("MailID", mail.split("@")[0]);
			params.put("Domain", mail.split("@")[1]);
			
			reMsg = orgSyncManageSvc.indiModifyPass(params);
			
			if(func.f_NullCheck(reMsg).equals("0")){
				body = "TRUE";
				returnMsg.append("|<b>MAIL</b> : SUCCESS<br/>");
			}else if(func.f_NullCheck(reMsg).equals("E0")){
				body = "FALSE";
				returnMsg.append("|<b>MAIL</b> : FAIL<br/><br/>");
				return returnMsg.toString();
			}else{
				CoviMap json = (CoviMap) JSONSerializer.toJSON(reMsg);
				
				if(func.f_NullCheck(json.get("FAIL").toString()).equals("") || func.f_NullCheck(json.get("FAIL").toString()).equals("0")){
					body = "TRUE";
					
					String msg = json.get("SUCCESS").toString();
					String arrSUMsg[] = msg.split(",");
					
					returnMsg.append("|<b>MAIL</b> : ");
					
					for (String suMsg : arrSUMsg ){
						returnMsg.append(suMsg+" (SUCCESS)<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  ");
			        }
					
				}else{
					String msg = json.get("SUCCESS").toString();
					String arrSUMsg[] = msg.split(",");
					
					returnMsg.append("|<b>MAIL</b> : ");
					
					for (String suMsg : arrSUMsg ){
						
						returnMsg.append(suMsg+" (SUCCESS)<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  ");
			        }

					msg = json.get("FAIL").toString();
					String arrFAILMsg[] = msg.split(",");
					
					
					for (String failMsg : arrFAILMsg ){
						returnMsg.append(failMsg+" (FAIL)<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  ");
			        }
					
					returnMsg.append("<br/>");
					
					body = "FALSE";
					
					return returnMsg.toString();
				}
			}
			
		}else{
			body = "TRUE";
		}
		
		boolean isSync = false;
		boolean isPasswordSync = false;
		boolean IsSyncAD_MP = false;
		
		isSync = RedisDataUtil.getBaseConfig("IsSyncAD",SessionHelper.getSession("DN_ID")).equals("Y") ? true : false;		
		isPasswordSync = RedisDataUtil.getBaseConfig("IsPasswordSyncAD",SessionHelper.getSession("DN_ID")).equals("Y") ? true : false;
		IsSyncAD_MP = RedisDataUtil.getBaseConfig("PassADIsUse",SessionHelper.getSession("DN_ID")).equals("Y") ? true : false;
		if(IsSyncAD_MP) {
			
			// 토큰 발급 서비스 사용을 위한 param
			CoviMap param = new CoviMap();
			
			// param 세팅
			param.put("userID", loginID);
			param.put("LogonID", loginID);
			param.put("UserCode", userCode);
			param.put("isAdmin", "N");
			param.put("newPass", params.getString("newPassword"));
			param.put("SamAccountName", mail.split("@")[0]);
			
			String pToken = ComUtils.jwtToken(param);
			
			String url = RedisDataUtil.getBaseConfig("Exch_mailSvcUrl") + "/WebSite/base/controls/externalwebservice.asmx";
			String bodydata = "<?xml version='1.0' encoding='utf-8'?>";
			bodydata += "<soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>";
			bodydata += "<soap:Body>";
			bodydata += "<SetADPassword xmlns='http://tempuri.org/'>";
			bodydata += "<pToken>"+pToken+"</pToken>";
			bodydata += "</SetADPassword>";
			bodydata += "</soap:Body>";
			bodydata += "</soap:Envelope>";
			
			HttpClientUtil httpClient = new HttpClientUtil();
			
			resultList = httpClient.httpClientNetConnect(url, bodydata, "POST");
			
			int status = (int) resultList.get("status");
			
			reMsg = resultList.get("body").toString().toLowerCase();
			
			/*if (status == 200 && (func.f_NullCheck(reMsg).equals("true") || func.f_NullCheck(reMsg).equals("success"))) {*/
			if (status == 200 && (reMsg.indexOf("true") > -1 || reMsg.indexOf("success") > -1)) {
				body = "TRUE";
				returnMsg.append("|<b>AD</b>&nbsp;&nbsp; : SUCCESS|");
			}else{
				body = "FLASE";
				returnMsg.append("|<b>AD</b>&nbsp;&nbsp; : FAIL|");
			}
		} else if(isSync || isPasswordSync)
		{
			
			returnMsg.append("<br/>");
			if (body.indexOf("TRUE") > -1 || body.indexOf("true") > -1) {
				
				/*
				String url = PropertiesUtil.getGlobalProperties().getProperty("password.service.url") + "?" + "pStrCN="+loginID
						+"&pStrOldPW="+params.getString("nowPassword")+"&pStrNewPW="+params.getString("newPassword");
			
				HttpClientUtil httpClient = new HttpClientUtil();
				
				resultList = httpClient.httpRestAPIConnect(url, "", "POST", "", "");*/
				
				
				String url = PropertiesUtil.getGlobalProperties().getProperty("password.service.url");
				String bodydata = "<?xml version='1.0' encoding='utf-8'?>";
				bodydata += "<soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>";
				bodydata += "<soap:Body>";
				bodydata += "<initADPassword xmlns='http://tempuri.org/'>";
				bodydata += "<userID>"+loginID+"</userID>";
				bodydata += "<logonPW>"+params.getString("newPassword")+"</logonPW>";
				bodydata += "</initADPassword>";
				bodydata += "</soap:Body>";
				bodydata += "</soap:Envelope>";
				
				HttpClientUtil httpClient = new HttpClientUtil();
				
				resultList = httpClient.httpClientNetConnect(url, bodydata, "POST");
				
				int status = (int) resultList.get("status");
				
				reMsg = resultList.get("body").toString().toLowerCase();
				
				/*if (status == 200 && (func.f_NullCheck(reMsg).equals("true") || func.f_NullCheck(reMsg).equals("success"))) {*/
				if (status == 200 && (reMsg.indexOf("true") > -1 || reMsg.indexOf("success") > -1)) {
					body = "TRUE";
					returnMsg.append("|<b>AD</b>&nbsp;&nbsp; : SUCCESS|");
				}else{
					body = "FLASE";
					returnMsg.append("|<b>AD</b>&nbsp;&nbsp; : FAIL|");
				}
				
			}else{
				
				returnMsg.append("|<b>AD</b>&nbsp;&nbsp; : FAIL</br></br>");
				
				return returnMsg.toString();
			}
		
		}
		
		params.put("aeskey", aeskey);
		
		if (body.indexOf("TRUE") > -1 || body.indexOf("true") > -1) {
		
			result = coviMapperOne.update("common.login.updateUserPassword", params);

			if(result > 0){
				this.updateUserInitialConection(params.getString("logonID"));
				try{
					coviMapperOne.insert("common.login.insertUserLogPassword", params);
					
					HttpSession session = request.getSession();
					
					CoviMap accountList = new CoviMap();
					CoviMap account = new CoviMap();
					SsoSamlCon ssoSamlCon = new SsoSamlCon();
					
					String key = (String) session.getAttribute("KEY");
					
					resultList = new CoviMap();
					CoviMap reAccount;
					
					params.put("key",key);
					
					reAccount = coviMapperOne.select("common.login.selectTokenInForMation", params);
							
					resultList.put("map", CoviSelectSet.coviSelectJSON(reAccount, "TOKEN, LogonID, UR_Name, UR_Code, UR_EmpNo, MAXAGE, MODIFIERDATE"));		
						
					resultList.put("account", reAccount);
					resultList.put("status", "OK");
					
					accountList = resultList;
					account = (CoviMap) accountList.get("account");
						
					account.put("Type", "AO");
						
					ssoSamlCon.setSamlInsideResponse(account,request,response);
					
					cUtil.removeCookies(response, request, key, "N", "N",subDomain);
					
					params.put("id",loginID);
			  		params.put("lang","");
					
			  		CoviMap ssoMap =  coviMapperOne.select("common.login.selectSSO", params);
			  		CoviMap resultListMap = new CoviMap();
			  		resultListMap.put("account", ssoMap);
					
			  		account = (CoviMap) resultListMap.get("account");
			  		
					//Token 생성,  Cookie Token 생성
					TokenHelper tokenHelper = new TokenHelper();
					
					key = tokenHelper.setTokenString(loginID,"2",params.getString("newPassword"),"ko", mail, account.get("DN_Code").toString(),account.get("UR_EmpNo").toString(),account.get("DN_Name").toString(),account.get("UR_Name").toString(),account.get("UR_Mail").toString(),account.get("GR_Code").toString(),account.get("GR_Name").toString(),account.get("Attribute").toString(),account.get("DN_ID").toString()); 
				    
					String accessDate = tokenHelper.selCookieDate("2","");
					
					if(!func.f_NullCheck(key).equals("") && !func.f_NullCheck(accessDate).equals("")){
						
					  cUtil.setCookies(response, key, accessDate,subDomain);
					  
					}  
				  
				  	//인증 성공 시
				  	//Redis 등록.  
				  	if (func.f_NullCheck(resultList.get("status").toString()).equals("OK")) {
				  		session.setAttribute("USERID", userCode);
				  		session.setAttribute("LOGIN", "Y");
				  		session.setAttribute("KEY", key);
				  		session.setAttribute("DeptCode", account.get("GR_Code").toString());
					
				  		SessionCommonHelper.makeSession(userCode, account, isMobile);
						//SessionHelper.setSession("SSO", authType);
						SessionHelper.setSession("lang", "ko", isMobile);
						//SessionHelper.setSession("USERPW", params.getString("newPassword").toString());
				 	}
				 	
				 	returnMsg.setLength(0);
				}
				catch(NullPointerException e){
					returnMsg.append("|coviSmart : FAIL</br></br>");
					return returnMsg.toString();
				}
				catch(Exception e){
					returnMsg.append("|coviSmart : FAIL</br></br>");
					return returnMsg.toString();
				}
			}
		} else {
			
			if(func.f_NullCheck(returnMsg).equals("")){
				returnMsg.append("|coviSmart : FAIL</br></br>");
			}
			
			return returnMsg.toString();
		}
	
		return returnMsg.toString();
	}
	
	public String selectUserAuthetication(String id, String password) throws Exception{
		String value = "";
		
		// 통합인증(Unify)의 경우는 이미 인증된 상태이기 떄문에 별도 체크 X 
		switch(PropertiesUtil.getSecurityProperties().getProperty("loginAuthType").toUpperCase()) {
			case "DB":
				CoviMap params = new CoviMap();
				params.put("id", id);
				params.put("password", password);
				params.put("aeskey",aeskey);
				
				value = (String) coviMapperOne.getString("common.login.selectUserAuthetication", params);
				
				break;
			case "AD":
				ADAuthUtil adAuthUtil = new ADAuthUtil();
				HashMap<String, Object> userInfo = adAuthUtil.getUserAuthetication(id, password);
				
				if(userInfo != null) {
					value = userInfo.get("sAMAccountName").toString();
				}
				
				break;
			default :
				break;
		}
		
		return value;
	}
	
	public String selectUserMailAddress(String id){
		String value = "";
		CoviMap params = new CoviMap();
		params.put("id", id);
		
		value = (String) coviMapperOne.getString("common.login.selectUserMailAddress", params);
		return value;
	}
	
	public String selectUserLanguageCode(String id){
		String value = "";
		CoviMap params = new CoviMap();
		params.put("id", id);
		
		value = (String) coviMapperOne.getString("common.login.selectUserLanguageCode", params);
		return value;
	}
	
	public int checkPasswordCnt(CoviMap params) throws Exception
	{
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("common.login.checkPasswordCnt", params);
		
		return cnt;
	}
	
	public CoviMap selectDomainPasswordPolicy(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.policy.getDomainPolicy", params);		
		
		return map;
	}
	
	public int checkPasswordLogCnt(CoviMap params) throws Exception {
		if(!params.getString("pwdCheckCount").equals("0")) {
			return (int) coviMapperOne.getNumber("common.login.checkPasswordLogCnt", params);
		}else {
			return 0;
		}
	}
	
	/*@Override
	public CoviMap selectPasswordPolicy(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.policy.getPolicy", params);		
		
		return map;
	}
	
	@Override
	public int selectPasswordPolicyCount(CoviMap params) throws Exception
	{
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("admin.policy.updatePasswordPolicyCount", params);
		
		return cnt;
	}*/
	
	public int selectAccountLock(String id) throws Exception
	{
		CoviMap params = new CoviMap();
		params.put("id", id);
		
		int cnt = 0;
		cnt = (int) coviMapperOne.getNumber("common.login.selectAccountLock", params);
		
		return cnt;
	}
	
	public CoviMap selectUserFailCount(String id) throws Exception{
		CoviMap params = new CoviMap();
		params.put("id", id);
		
		CoviMap map = coviMapperOne.select("common.login.selectUserFailCount", params);
		
		return map;
		
	}
	
	public boolean updateUserFailCount(String id)throws Exception{
		CoviMap params = new CoviMap();
		params.put("id", id);

		int cnt=0;
		boolean flag = false;
		cnt = (int) coviMapperOne.update("common.login.updateUserFailCount", params);
		
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean updateUserLock(String id, String lock)throws Exception{
		CoviMap params = new CoviMap();
		params.put("id", id);
		params.put("ACCOUT_LOCK", lock);

		int cnt=0;
		boolean flag = false;
		cnt = (int) coviMapperOne.update("common.login.updateUserLock", params);
		
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean deleteUserFailCount(String id)throws Exception{
		CoviMap params = new CoviMap();
		params.put("id", id);

		int cnt=0;
		boolean flag = false;
		cnt = (int) coviMapperOne.update("common.login.deleteUserFailCount", params);
		
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean updateUserInitialConection(String id)throws Exception{
		CoviMap params = new CoviMap();
		params.put("id", id);

		int cnt=0;
		boolean flag = false;
		cnt = (int) coviMapperOne.update("common.login.updateUserInitialConection", params);
		
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	public boolean updateUserPasswordClear(String id)throws Exception{
		CoviMap params = new CoviMap();
		params.put("id", id);
		
		int cnt=0;
		boolean flag = false;
		cnt = (int) coviMapperOne.update("common.login.updateUserPasswordClear", params);
		
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}
	
	public String selectUserDomainUrl(CoviMap params){
		String value = "";
		value = (String) coviMapperOne.getString("common.login.userDomainUrl", params);
		return value;
	}
	
	

	public CoviMap selectBaseCheckInfo(String id, String password) throws Exception{
		CoviMap returnObj = new CoviMap();
		CoviMap params = new CoviMap();
		
		params.put("id", id);
		params.put("password", password);
		params.put("aeskey",aeskey);
		
		returnObj.putAll(coviMapperOne.select("common.login.selectBaseCheckInfo", params));
		
		if(!returnObj.containsKey("LockCount")){
			returnObj.put("LockCount", 0);
		}
		
		if(!returnObj.containsKey("UserCode")){
			returnObj.put("UserCode", "");
		}
		
		return returnObj;
	}
	
	public int selectOTPCheck(CoviMap params)throws Exception{
		int cnt = 0;
		// OTP 실패 카운트 (기초설정 - OTPFailCount)
		params.put("OTPFailCount", StringUtil.replaceNull(RedisDataUtil.getBaseConfig("OTPFailCount"), "5"));
		cnt = (int)coviMapperOne.getNumber("common.login.selectOTPCheck", params);
		// 인증 실패 시 실패 카운트 +1
		if (cnt == 0) {
		coviMapperOne.update("common.login.updateOTPFailCount", params);
		}
		return cnt;
	}
	public int selectOTPFailCount(CoviMap params)throws Exception{
		int cnt = 0;
		cnt = (int)coviMapperOne.getNumber("common.login.selectOTPFailCount", params);
		
		return cnt;
	}

	@Override
	public boolean updateLogoutTime(CoviMap params) throws Exception {
		int cnt=0;
		boolean flag = false;
		cnt = (int) coviMapperOne.update("common.login.updateLogoutTime", params);
		
		if(cnt > 0){
			flag = true;			
		}else{
			flag = false;
		}
		return flag;
	}

	@Override
	public void mailTrashClear(CoviMap params) throws Exception{
		
		if("Y".equalsIgnoreCase(RedisDataUtil.getBaseConfig("isUseMail"))){	//CP 메일 사용여부 
			/*
			[Parameter Value]
			id: Login ID
			mailId: User Mail Address
			domainCode: User Domain Code
			password: 1 고정 (향후 해당 Parameter 삭제 예정)
			 
			[Response Data]
			{"list":[{"IsDeleteMessgeLogout":"Y"}],"result":"ok","status":"SUCCESS"}*/
			
			String url = RedisDataUtil.getBaseConfig("MailTrashClearAPIURL");
			
			if(url != null && !url.equals("")){
				url  += ("?id=" + params.getString("logonID")
						+ "&mailId=" + params.getString("mailAddress")
						+ "&domainCode=" + params.getString("domainCode")
						+ "&password=1");
				
				HttpClientUtil httpUtil = new HttpClientUtil();
				httpUtil.httpRestAPIConnect(url, "", "GET", "", "");
			}
			
		}
		
		
	}

	@Override
	public boolean checkIPScope(String currentIP, String userStartIP, String userEndIP) throws Exception {
		String validIPReg = "^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$"; //IP 유효성 체크 정규식
		
		if(!Pattern.matches(validIPReg, userStartIP )) {
			return false;
		}else if(!Pattern.matches(validIPReg, userEndIP)) {
			return false;
		}else if(ipToLong(userStartIP) <= ipToLong(currentIP) && ipToLong(currentIP) <= ipToLong(userEndIP)) {
			return true; //접근 가능 IP 
		}else {
			return false;
		}
	}
	
	public Long ipToLong(String addr) {
		
		
		String[] addrArray = addr.split("\\.");

        long num = 0;
        for (int i=0;i<addrArray.length;i++) {
            int power = 3-i;

            num += ((Integer.parseInt(addrArray[i])%256 * Math.pow(256,power)));
        }
        
        return num;
	}
	
	/*
	public String LongToIP(long i) {
        return ((i >> 24 ) & 0xFF) + "." +  ((i >> 16 ) & 0xFF) + "." + ((i >>  8 ) & 0xFF) + "." + ( i & 0xFF);
    }
	*/

	public String selectVacationCreateMethod(CoviMap params){
		String value = "";
		value = (String) coviMapperOne.getString("common.login.vacationCreateMethod", params);
		return value;
	}

	public CoviMap selectM365UserInfo(String userCode, String userPrincipalName, String aadObjectId) throws Exception {
		CoviMap resultList = null;
		CoviMap map = null;
		
		resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("userCode", userCode);
		params.put("userPrincipalName", userPrincipalName);
		params.put("aadObjectId", aadObjectId);
		params.put("lang", "");
		
		map = coviMapperOne.select("m365.getUserInfo", params);
		
		resultList = CoviSelectSet.coviSelectJSON(map, "UserCode,LogonID,UPN,AadObjectId,DN_Code,DN_ID").getJSONObject(0);
			
		return resultList; 
	}

	public CoviMap selectM365AppInfo(String dn_id, String scope) throws Exception {
		CoviMap resultList = null;
		CoviMap map = null;
		
		resultList = new CoviMap();
		
		CoviMap params = new CoviMap();
		params.put("dn_id", dn_id);
		params.put("scope", scope);
		
		map = coviMapperOne.select("m365.getAppInfo", params);
		
		resultList = CoviSelectSet.coviSelectJSON(map, "Scope,DN_ID,DN_Code,AppId,TenantId,ClientSecret").getJSONObject(0);
			
		return resultList; 
	}
	
}
