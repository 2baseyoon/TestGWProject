package egovframework.core.web;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.PrivateKey;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.regex.Pattern;

import javax.servlet.RequestDispatcher;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.sec.AES;
import egovframework.baseframework.sec.RSA;
import egovframework.baseframework.sso.saml.RequestUtil;
import egovframework.baseframework.sso.saml.SAMLSigner;
import egovframework.baseframework.sso.saml.SAMLVerifier;
import egovframework.baseframework.sso.saml.SamlException;
import egovframework.baseframework.sso.saml.Util;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.LicenseHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.LocalBaseSyncSvc;
import egovframework.core.sevice.LocalStorageSyncSvc;
import egovframework.core.sevice.LoginSvc;
import egovframework.core.sevice.MessageManageSvc;
import egovframework.core.sevice.OrgSyncManageSvc;
import egovframework.core.sso.saml.ProcessResponseServlet;
import egovframework.coviframework.base.TokenHelper;
import egovframework.coviframework.base.TokenParserHelper;
import egovframework.coviframework.service.AuthorityService;
import egovframework.coviframework.service.SessionService;
import egovframework.core.sevice.SysDomainSvc;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.CommonUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.coviframework.util.SessionCommonHelper;

import egovframework.baseframework.sec.EUMAES;


/**
 * @Class Name : LoginCon.java
 * @Description : 로그인 처리
 * @Modification Information
 * @ 2015.11.06 최초생성
 *
 * @author 코비젼 연구소
 * @since 2015. 11.13
 * @version 1.0
 * @see Copyright(C) by Covision All right reserved.
 */

@Controller
public class LoginCon extends HttpServlet {
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	private static final Logger LOGGER = LogManager.getLogger(LoginCon.class);
	
	private final String samlResponseTemplateFile = "SamlResponseTemplate.xml";
	private final String cryptoType = PropertiesUtil.getSecurityProperties().getProperty("cryptoType");
	private final String publicKey = PropertiesUtil.getSecurityProperties().getProperty("public.key");
	private final String privateKey = PropertiesUtil.getSecurityProperties().getProperty("private.key");
	private final String compulsionUrl = PropertiesUtil.getGlobalProperties().getProperty("privacy.secure.change.compulsion.url");
	private final String coercionUrl = PropertiesUtil.getGlobalProperties().getProperty("privacy.secure.change.non.coercion.url");
	
	@Autowired
	private LoginSvc loginsvc;
	
	@Autowired
	private OrgSyncManageSvc orgSyncManageSvc;

	@Autowired
	private MessageManageSvc messageManageSvc;
	
	@Autowired
	private AuthorityService authSvc;
	
	@Autowired
	private SysDomainSvc sysDomainSvc;
	
	@Autowired
	private SessionService sessionSvc;

	@RequestMapping(value = "/login.do") 
	public ModelAndView loginPage(Locale locale, Model model,HttpServletRequest request, HttpServletResponse response) throws Exception {
		StringUtil func = new StringUtil();
		
		RSA rsa = RSA.getEncKey();
		
		CookiesUtil cUtil = new CookiesUtil();
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		CoviMap account = null;
		
		String returnURL = "";
		String acr = request.getParameter("acr");
		String samlResponse = request.getParameter("SAMLResponse"); 
		String samlRequest = request.getParameter("SAMLRequest"); 
		String responseXmlString ="";
		String signedSamlResponse = "";
		String issueInstant = Util.getDateAndTime();
		String loginAuthType = PropertiesUtil.getSecurityProperties().getProperty("loginAuthType");
		
		int chkValue = 1;
		
		String userPwChangeMD  = SessionHelper.getExtensionSession(SessionHelper.getSession("USERID",isMobile)+"_PSM","UPCMD");
		
		if(func.f_NullCheck(userPwChangeMD).equals("Y")){
			returnURL = "redirect:"+request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()+compulsionUrl;
			ModelAndView mav = new ModelAndView(returnURL);
			return mav;
		}else{
			TokenHelper tokenHelper = new TokenHelper();
			
			String key = cUtil.getCooiesValue(request);
			String id = "";
			String lang = "";
			
			//쿠기값이 있을 경우 
			if(!key.isEmpty()){
				
				TokenParserHelper tokenParserHelper = new TokenParserHelper();
				String decodeKey = tokenHelper.getDecryptToken(key);
				
				if(tokenParserHelper.parserJsonLoginVerification(decodeKey)) {
					Map<Object, Object> map = tokenParserHelper.getSSOToken(decodeKey);
					
					id = (String) map.get("id");
					lang = (String) map.get("lang");
				}else {
					chkValue = 1;
				}
			}
			
			if (id.isEmpty()
					&& loginAuthType.equalsIgnoreCase("Unify")  
					&& request.getUserPrincipal() != null 
					&& func.f_NullCheck(request.getAuthType()).equalsIgnoreCase("SPNEGO")) {
				
				key = "";
				id = request.getUserPrincipal().getName();
				lang = loginsvc.selectUserLanguageCode(id);
			}
				
			if(!"".equals(id)){
				if(loginsvc.checkSSOUserAuthetication(id) < 1){
					chkValue = 1;
				}else{
					String authType = "SSO";
					String paramId = id;
					String paramLang = lang;
					
					String userID  = "";

					if(!key.isEmpty()){
						userID = SessionHelper.simpleGetSession("UR_ID",isMobile,key);
						
						if(!func.f_NullCheck(userID).equals("")){
							chkValue = 0;
							
							String sessionLangVal = SessionHelper.simpleGetSession("lang",isMobile,key);
							
							paramLang = func.f_NullCheck(sessionLangVal).equals("") ? paramLang : sessionLangVal;
						}
					}

					//인증체크 로직 수행
					CoviMap resultList = loginsvc.checkAuthetication(authType, paramId, "", paramLang);
					// 웹페이지에서받은 아이디,패스워드 일치시 admin 세션key 생성
					String status = resultList.get("status").toString();
					account = (CoviMap) resultList.get("account");

					//통합인증인 경우 KEY가 없기때문에 키 생성 
					if(key.isEmpty()) {
						String date = loginsvc.checkSSO("DAY");
						
						String accessDate = tokenHelper.selCookieDate(date,"");
						key = tokenHelper.setTokenString(id,date,"",lang,account.get("UR_Mail").toString(),account.get("DN_Code").toString(),account.get("UR_EmpNo").toString(),account.get("DN_Name").toString(),account.get("UR_Name").toString(),account.get("UR_Mail").toString(),account.get("GR_Code").toString(),account.get("GR_Name").toString(),account.get("Attribute").toString(),account.get("DN_ID").toString());
							
						cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());
					}

					if(func.f_NullCheck(userID).equals("")){
						//인증 성공 시
						if (status.equals("OK")) {
							//라이선스 인증 정보 초기화
							LicenseHelper.resetUserLicenseCheck(account.get("UR_Code").toString(), account.get("DN_ID").toString());
							
							//세션 생성
							HttpSession session = request.getSession();
							session.getServletContext().setAttribute(key, account.get("UR_ID").toString());
							session.setAttribute("KEY", key);
							session.setAttribute("USERID", account.get("UR_ID").toString());
							session.setAttribute("LOGIN", "Y");
							
							account.put("UR_LoginIP",func.getRemoteIP(request));
							SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account, isMobile);
							loginsvc.saveLoginInfo(account);
							LoggerHelper.connectLogger(account.get("UR_ID").toString(), account.get("UR_Code").toString(), account.get("LogonID").toString(), account.get("LanguageCode").toString());
							chkValue = 0;
						} else {
							//접속실패로그
							LoggerHelper.connectFalseLogger(paramId,"LOGIN");
							chkValue = 1;
						}	
					}
				
					if(func.f_NullCheck(acr).equals("")){
						LOGGER.info("LOGIN >>> NO ACR ");
						if(chkValue == 1 || func.f_NullCheck(samlResponse).equals("")){
							if(!func.f_NullCheck(samlRequest).equals("")){
								String publicKeyFilePath = null;
								String privateKeyFilePath = null;
								 
								String osName = System.getProperty("os.name");
								if(osName.indexOf("Windows") != -1){
									publicKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+publicKey);
									privateKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+privateKey);
								}else{
									String path = loginsvc.checkSSO("PATH");
									publicKeyFilePath = path+publicKey;
									privateKeyFilePath = path+privateKey; 
								}
								request.setAttribute("issueInstant", issueInstant);
								request.setAttribute("providerName", "Covision");
								request.setAttribute("RelayState", "");
								
								// First, verify that the NotBefore and NotOnOrAfter values
								// are valid
								RSAPrivateKey privateKey = (RSAPrivateKey) Util
										.getPrivateKey(privateKeyFilePath, "RSA");
								
								RSAPublicKey publicKey = (RSAPublicKey) Util.getPublicKey(
										publicKeyFilePath, "RSA");
								long now = System.currentTimeMillis();
								
								String day = loginsvc.checkSSO("DAY");
								int time = 0 ;
								if(func.f_NullCheck(day).equals("")){
									time = 0 ;
								}else{
									time = Integer.parseInt(day);
									time = time * 24;
								}
								
								long nowafter = now + 1000L * 60 * 60 * time;
								long nowbefore = now - 1000L * 60 * 60 * time;
								SimpleDateFormat dateFormat1 = new SimpleDateFormat(
										"yyyy-MM-dd'T'hh:mm:ss'Z'");
								java.util.Date pTime = new java.util.Date(nowbefore);
								String notBefore = dateFormat1.format(pTime);
								java.util.Date aTime = new java.util.Date(nowafter);
								String notOnOrAfter = dateFormat1.format(aTime);
								
								request.setAttribute("notBefore", notBefore);
								request.setAttribute("notOnOrAfter", notOnOrAfter);
								responseXmlString = createSamlResponse(account.get("UR_Name").toString(), notBefore, notOnOrAfter, "covision", request,id, issueInstant,request.getParameter("uid"), request.getParameter("destination"), request.getParameter("acr") );
								signedSamlResponse = SAMLSigner.signXML(
								responseXmlString, privateKey, publicKey);
								
								chkValue = 2;
								
								LOGGER.info("LOGIN >>> NO ACR - Response ");
							}else{
								chkValue = 0;
							}
								
						}else{
							String publicKeyFilePath = null;
							String privateKeyFilePath = null;
							 
							String osName = System.getProperty("os.name");
							if(osName.indexOf("Windows") != -1){
								publicKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+publicKey);
								privateKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+privateKey);
							}else{
								String path = loginsvc.checkSSO("PATH");
								publicKeyFilePath = path+publicKey ;
								privateKeyFilePath = path+privateKey ; 
							}
							request.setAttribute("issueInstant", issueInstant);
							request.setAttribute("providerName", "Covision");
							request.setAttribute("RelayState", "");
							
							// First, verify that the NotBefore and NotOnOrAfter values
							// are valid
							RSAPrivateKey privateKey = (RSAPrivateKey) Util
									.getPrivateKey(privateKeyFilePath, "RSA");
							
							RSAPublicKey publicKey = (RSAPublicKey) Util.getPublicKey(
									publicKeyFilePath, "RSA");
							long now = System.currentTimeMillis();
							
							String day = loginsvc.checkSSO("DAY");
							int time = 0 ;
							if(func.f_NullCheck(day).equals("")){
								time = 0 ;
							}else{
								time = Integer.parseInt(day);
								time = time * 24;
							}
							
							long nowafter = now + 1000L * 60 * 60 * time;
							long nowbefore = now - 1000L * 60 * 60 * time;
							SimpleDateFormat dateFormat1 = new SimpleDateFormat(
									"yyyy-MM-dd'T'hh:mm:ss'Z'");
							java.util.Date pTime = new java.util.Date(nowbefore);
							String notBefore = dateFormat1.format(pTime);

							java.util.Date aTime = new java.util.Date(nowafter);
							String notOnOrAfter = dateFormat1.format(aTime);
							
							request.setAttribute("notBefore", notBefore);
							request.setAttribute("notOnOrAfter", notOnOrAfter);
							responseXmlString = createSamlResponse(account.get("UR_Name").toString(), notBefore, notOnOrAfter, "covision", request,id, issueInstant,request.getParameter("uid"),request.getParameter("destination"),request.getParameter("acr") );
							signedSamlResponse = SAMLSigner.signXML(
									responseXmlString, privateKey, publicKey);
							
							chkValue = 2;
						}
							
					}else{
						if(func.f_NullCheck(request.getParameter("sop")).equals("Y")){
							String publicKeyFilePath = null;
							String privateKeyFilePath = null;
							 
							String osName = System.getProperty("os.name");
							if(osName.indexOf("Windows") != -1){
								publicKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+publicKey);
								privateKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+privateKey);
							}else{
								String path = loginsvc.checkSSO("PATH");
								publicKeyFilePath = path+publicKey ;
								privateKeyFilePath = path+privateKey ; 
							}
							request.setAttribute("issueInstant", issueInstant);
							request.setAttribute("providerName", "Covision");
							request.setAttribute("RelayState", "");
							
							// First, verify that the NotBefore and NotOnOrAfter values
							// are valid
							RSAPrivateKey privateKey = (RSAPrivateKey) Util
									.getPrivateKey(privateKeyFilePath, "RSA");
							
							RSAPublicKey publicKey = (RSAPublicKey) Util.getPublicKey(
									publicKeyFilePath, "RSA");
							long now = System.currentTimeMillis();
							
							String day = loginsvc.checkSSO("DAY");
							int time = 0 ;
							if(func.f_NullCheck(day).equals("")){
								time = 0 ;
							}else{
								time = Integer.parseInt(day);
								time = time * 24;
							}
							
							long nowafter = now + 1000L * 60 * 60 * time;
							long nowbefore = now - 1000L * 60 * 60 * time;
							SimpleDateFormat dateFormat1 = new SimpleDateFormat(
									"yyyy-MM-dd'T'hh:mm:ss'Z'");
								java.util.Date pTime = new java.util.Date(nowbefore);
							String notBefore = dateFormat1.format(pTime);
								java.util.Date aTime = new java.util.Date(nowafter);
							String notOnOrAfter = dateFormat1.format(aTime);
							
							request.setAttribute("notBefore", notBefore);
							request.setAttribute("notOnOrAfter", notOnOrAfter);
							responseXmlString = createSamlResponse(account.get("UR_Name").toString(), notBefore, notOnOrAfter, "covision", request,id, issueInstant,request.getParameter("uid"),request.getParameter("destination"),request.getParameter("acr") );
							signedSamlResponse = SAMLSigner.signXML(
									responseXmlString, privateKey, publicKey);
							
							chkValue = 2;
							
						}
						
					}
				}// if checkSSOUserAuthetication
			}//if equals(id) 
			
			String domainName = request.getServerName();
			String mobileDomain = RedisDataUtil.getBaseConfig("MobileDomain", isMobile);
			String mobileLogonType = RedisDataUtil.getBaseConfig("MobileLogonType", isMobile);
			String mobileDomainPCService = RedisDataUtil.getBaseConfig("MobileDomainPCService", isMobile);
		
			if(chkValue == 1){
				if(isMobile) {
					//모바일 접근 허용 X
					if(mobileLogonType.equalsIgnoreCase("DENY")) {
						response.setContentType("text/html; charset=UTF-8");
						PrintWriter out = response.getWriter();
			            out.println("<p style='font-size: 35px;'>[ACCESS DENY]<br>Mobile Office에 대한 연결이 거부되었습니다. 관리자에게 문의하시기 바랍니다.</p>");
			            out.close();
			            return null;
					}
					//모바일 APP 접근만 허용
					else if(mobileLogonType.equalsIgnoreCase("APP") && !ClientInfoHelper.isMobileApp(request)) {
						String mdmDownloadURL = RedisDataUtil.getBaseConfig("MDM_DownloadURL", isMobile);
						
						response.setContentType("text/html; charset=UTF-8");
						PrintWriter out = response.getWriter();
						out.println("<p style='font-size: 35px;'>[ACCESS DENY]<br>Mobile Office에 대한 연결이 거부되었습니다. APP을 사용하여 접근 바랍니다.</p>");
			            
			            if(!mdmDownloadURL.isEmpty()) {
			            	out.println("<p style='text-align:center'>"
			            			+ "		<button style='font-size: 35px; padding: 15px;' onclick=\"location.href='"+mdmDownloadURL+"'\">App Download</button>"
			            			+ "	</p>");
			            }
			            
			            out.close();
			            return null;
					}else {
						returnURL = "mobile/login/login";
					}
				}else {
					if(mobileDomainPCService.equalsIgnoreCase("DENY")) {
						if(mobileDomain.equalsIgnoreCase(domainName)) {
							returnURL = "mobile/login/login";
						}else {
							if(loginAuthType.equalsIgnoreCase("Unify")) {
								response.sendError(HttpServletResponse.SC_FORBIDDEN);
								return null;
							}else {
								returnURL = "core/login/login";
							}
						}
					}else {
						if(loginAuthType.equalsIgnoreCase("Unify")) {
							response.sendError(HttpServletResponse.SC_FORBIDDEN);
							return null;
						}else {
							returnURL = "core/login/login";
						}
					}				
				}

				CoviMap params = new CoviMap();
				params.put("DomainURL", request.getServerName());
				params.put("pageNo", 1);
				params.put("pageSize", 1);
				CoviMap domainMap = sysDomainSvc.select(params);
				CoviList domainList =  (CoviList)domainMap.get("list");
				String domainLoginImagePath = "";
				String domainThemeCode = "";
				String domainCode= "";

				if (domainList.size()>0){
					CoviMap map = domainList.getJSONObject(0);
					String domainImagePath = map.getString("DomainImagePath");
					if (domainImagePath.split(";").length>2){
						domainLoginImagePath = domainImagePath.split(";")[2];
					}
					domainThemeCode = map.getString("DomainThemeCode");
					domainCode = map.getString("DomainCode");
				}
				
				ModelAndView mav = new ModelAndView(returnURL);
				mav.addObject("samlRequest", request.getParameter("SAMLRequest"));
				mav.addObject("relayState", request.getParameter("RelayState"));
				mav.addObject("acr", acr);
				mav.addObject("uid", request.getParameter("uid"));
				mav.addObject("loginState", "success");
				mav.addObject("samlLogin", PropertiesUtil.getSecurityProperties().getProperty("sso.sp.yn"));
				mav.addObject("ssoType", PropertiesUtil.getSecurityProperties().getProperty("sso.type"));
				mav.addObject("destination", request.getParameter("destination"));
				mav.addObject("cryptoType", cryptoType);
				mav.addObject("useFIDO", PropertiesUtil.getSecurityProperties().getProperty("fido.login.used"));
				mav.addObject("domainLoginImagePath", domainLoginImagePath);
				mav.addObject("domainThemeCode", domainThemeCode);
				mav.addObject("domainCode", domainCode);
		
				if(func.f_NullCheck(cryptoType).equals("R") && (request.getHeader("AJAX") == null || !request.getHeader("AJAX").equals("true"))){
					mav.addObject("publicKeyModulus", rsa.getPublicKeyModulus());
					mav.addObject("publicKeyExponent", rsa.getPublicKeyExponent());
					
					request.getSession().setAttribute("__CoviRPK__", rsa.getPrivateKey());
				}
				
				return mav;
			}else if(chkValue == 2){
				LOGGER.info("## Login - SAML Response Send Redirect Page ##");
				//StringBuffer buf = new StringBuffer();
				
				if(func.f_NullCheck(acr).equals("")){
					String mainPage ="";
					
					if(	ClientInfoHelper.isMobile(request) ||
						(mobileDomainPCService.equalsIgnoreCase("DENY") && mobileDomain.equalsIgnoreCase(domainName) ) ){
						mainPage= PropertiesUtil.getGlobalProperties().getProperty("MobileMainPage.path");
						returnURL = "redirect:"+request.getScheme() + "://" + domainName + ":" + request.getServerPort() + mainPage;
					}else{
						if(func.f_NullCheck(account.get("INITIAL_CONNECTION")).equals("Y")){
							returnURL = "redirect:"+request.getScheme() + "://" + domainName + ":" + request.getServerPort()+compulsionUrl;
						}else if(func.f_NullCheck(account.get("TEMPORARY_PASSWORD_ISUSE")).equals("Y")){
							//임시패스워드 발급
							SessionHelper.setExtensionSession(SessionHelper.getSession("USERID")+"_PSM","UPCMD", "Y");
							returnURL = "redirect:"+request.getScheme() + "://" + domainName + ":" + request.getServerPort()+compulsionUrl;
						}else{
							mainPage= PropertiesUtil.getGlobalProperties().getProperty("MainPage.path");
							returnURL = "redirect:"+request.getScheme() + "://" + domainName + ":" + request.getServerPort() + mainPage;
						}
					}
					
					ModelAndView mav = new ModelAndView(returnURL);
					mav.addObject("samlRequest", request.getParameter("SAMLRequest"));
					mav.addObject("relayState", request.getParameter("RelayState"));
					mav.addObject("acr", acr);
					
					mav.addObject("loginState", "success");
					mav.addObject("samlLogin", PropertiesUtil.getSecurityProperties().getProperty("sso.sp.yn"));
					mav.addObject("ssoType", PropertiesUtil.getSecurityProperties().getProperty("sso.type"));
					mav.addObject("destination", request.getParameter("destination"));
					mav.addObject("cryptoType", cryptoType);
					mav.addObject("useFIDO", PropertiesUtil.getSecurityProperties().getProperty("fido.login.used"));
					
					if(func.f_NullCheck(cryptoType).equals("R")){
						mav.addObject("publicKeyModulus", rsa.getPublicKeyModulus());
						mav.addObject("publicKeyExponent", rsa.getPublicKeyExponent());
						
						request.getSession().setAttribute("__CoviRPK__", rsa.getPrivateKey());
					}

					return mav;
				}else{
					
					returnURL = "core/login/redirect";
					
					ModelAndView mav = new ModelAndView(returnURL);
					mav.addObject("returnURL", acr);
					mav.addObject("SAMLResponse", RequestUtil.encodeMessage(signedSamlResponse));
					mav.addObject("RelayState", URLEncoder.encode(""));
					mav.addObject("loginState", "success");
					return mav;
				}
				
			}else{
				String mainPage ="";
				
				if(	ClientInfoHelper.isMobile(request) ||
					(mobileDomainPCService.equalsIgnoreCase("DENY") && mobileDomain.equalsIgnoreCase(domainName) ) ){
					mainPage= PropertiesUtil.getGlobalProperties().getProperty("MobileMainPage.path");
					returnURL = "redirect:"+request.getScheme() + "://" + domainName + ":" + request.getServerPort() + mainPage;
				}else{
					if(func.f_NullCheck(account.get("INITIAL_CONNECTION")).equals("Y")){
						returnURL = "redirect:"+request.getScheme() + "://" + domainName + ":" + request.getServerPort()+compulsionUrl;
					}else if(func.f_NullCheck(account.get("TEMPORARY_PASSWORD_ISUSE")).equals("Y")){
						//임시패스워드 발급
						SessionHelper.setExtensionSession(SessionHelper.getSession("USERID")+"_PSM","UPCMD", "Y");
						returnURL = "redirect:"+request.getScheme() + "://" + domainName + ":" + request.getServerPort()+compulsionUrl;
					}else{
						mainPage = PropertiesUtil.getGlobalProperties().getProperty("MainPage.path");
						returnURL = "redirect:"+request.getScheme() + "://" + domainName + ":" + request.getServerPort() + mainPage;
					}
				}
				

				func = null;
				cUtil = null;
				
				ModelAndView mav = new ModelAndView(returnURL);
				mav.addObject("samlRequest", request.getParameter("SAMLRequest"));
				mav.addObject("relayState", request.getParameter("RelayState"));
				mav.addObject("acr", acr);
				
				mav.addObject("loginState", "success");
				mav.addObject("samlLogin", PropertiesUtil.getSecurityProperties().getProperty("sso.sp.yn"));
				mav.addObject("ssoType", PropertiesUtil.getSecurityProperties().getProperty("sso.type"));
				mav.addObject("useFIDO", PropertiesUtil.getSecurityProperties().getProperty("fido.login.used"));
				return mav;
			}
		}
		
	}

	/**
	 * 가상의 로그인체크 컨트롤러
	 *
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/loginchk.do")
	public ModelAndView login(HttpServletRequest request, HttpServletResponse response) throws Exception {
		LOGGER.debug("loginchk.do start ---------------------------------------------------------------------------");
		
		CookiesUtil cUtil = new CookiesUtil();
		//saml
		String acr = request.getParameter("acr");
		
		CoviMap loginInfo = new CoviMap();
		
		loginInfo.put("oa",request.getParameter("oa"));
		loginInfo.put("scope",request.getParameter("scope"));
		loginInfo.put("currenturl",request.getParameter("currenturl"));
		loginInfo.put("clientname",request.getParameter("clientname"));
		loginInfo.put("acr",request.getParameter("acr"));
		loginInfo.put("isFIDO",request.getParameter("isFIDO"));
		loginInfo.put("id",request.getParameter("id"));
		loginInfo.put("language",request.getParameter("language"));

		CoviMap returnData = getLoginInfo(loginInfo, ClientInfoHelper.isMobile(request), cUtil.getCooiesValue(request)
				,request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
				,PropertiesUtil.getGlobalProperties().getProperty("MainPage.path")
				,PropertiesUtil.getGlobalProperties().getProperty("MobileMainPage.path")
				,request, response);
		
		ModelAndView mav = new ModelAndView((String)returnData.get("returnURL"));
		mav.addObject("returnURL", acr);
		mav.addObject("SAMLResponse", returnData.get("SAMLResponse"));
		mav.addObject("RelayState", URLEncoder.encode(""));
		mav.addObject("loginState", returnData.get("loginState"));
		mav.addObject("result",returnData.get("result"));
		
		
		return mav;
	}	
	
	private CoviMap getLoginInfo(CoviMap loginInfo, boolean isMobile, String key, String serverUrl, String pcMainPage, String mobileMainPage
			, HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		CoviMap resultList = new CoviMap();
		HttpSession session = request.getSession();
		
		String returnURL = "";
		String loginState = "success";
		String status = "";
		String maxAge = "";
		
		//OAuth 
		String oa = (String)loginInfo.get("oa");
		String scope = (String)loginInfo.get("scope");
		String currenturl = (String)loginInfo.get("currenturl");
		String clientname = (String)loginInfo.get("clientname");
		
		
		//saml
		String acr = (String)loginInfo.get("acr");

		//base
		String urNm = "";
		String urCode = "";
		String urEmpNo = "";
		//String urId = "";
		String samlID= "";
		
		//fido
		String isFido  = Objects.toString( loginInfo.get("isFIDO") ,"N"); 											//FIDO 인증이 된 경우 비밀번호 및 two factor 체크 필요 없음, 비밀번호 변경 및 만료일 페이지 이동X
		String isFidoAccountLock = RedisDataUtil.getBaseConfig("isFidoAccountLock", isMobile);	//FIDO 로그인시 계정 잠금처리 사용 여부 Y/N
		
		try{
			
			//loginService 인증 처리 로직 시작
			String paramId = (String)loginInfo.get("id");
			String paramPwd = "";
			String paramLang = (String)loginInfo.get("language");
			String authType = "SSO";
		
		
			LOGGER.debug("쿠키 유효성 체크 start ---------------------------------------------------------------------------");
			
			TokenHelper tokenHelper = new TokenHelper();
			TokenParserHelper tokenParserHelper = new TokenParserHelper();
			String decodKey = tokenHelper.getDecryptToken(key);
			if(!tokenParserHelper.parserJsonVerification(decodKey,paramId)){
				returnURL = "redirect:"+serverUrl+ "/covicore/logout.do";
				returnData.put("returnURL", returnURL);
				returnData.put("loginState", "fail");
				return returnData;
			}else{
				maxAge = tokenParserHelper.parserJsonMaxAge(decodKey);
				
			}
			
			
			//인증체크 로직 수행
			LOGGER.debug("계정 정보 조회 start ---------------------------------------------------------------------------");
			resultList = loginsvc.checkAuthetication(authType, paramId, paramPwd, paramLang);
			status = resultList.get("status").toString();
			CoviMap account = (CoviMap) resultList.get("account");

			//인증 성공 시
			if (status.equals("OK")) {

				LOGGER.debug("세션생성 start ---------------------------------------------------------------------------");
				//라이선스 인증 정보 초기화
				LicenseHelper.resetUserLicenseCheck(account.optString("UR_Code"), account.optString("DN_ID"));
				
				//세션 생성
				session.getServletContext().setAttribute(key, account.optString("UR_ID"));
				session.setAttribute("KEY", key);
				session.setAttribute("USERID", account.optString("UR_ID"));
				session.setAttribute("LOGIN", "Y");
				
				urNm = account.optString("UR_Name");
				urCode = account.optString("UR_Code");
				urEmpNo = account.optString("UR_EmpNo");
				//urId = account.get("UR_ID");
				samlID = account.optString("LogonID");
				
				account.put("UR_LoginIP",func.getRemoteIP(request));
				SessionCommonHelper.makeSession(account.optString("UR_ID"), account, isMobile, key);
				//SessionHelper.setSession("SSO", authType);
				//SessionHelper.setSession("USERPW",  request.getParameter("password"));
				SessionHelper.setSimpleSession("lang", paramLang, isMobile, key);
				SessionHelper.setSimpleSession("LanguageCode", paramLang, isMobile, key);
				
				String userLanguageDB = sessionSvc.selectUserLanguageCode(paramId);
				if (!userLanguageDB.equals(paramLang)) {
					sessionSvc.updateUserLanguageCode(urCode, paramLang);
				}
				
				LOGGER.debug("접속로그 생성 start ---------------------------------------------------------------------------");
				// 접속로그 생성
				loginsvc.saveLoginInfo(account);
				LoggerHelper.connectLogger(account.optString("UR_ID"), urCode, samlID, paramLang);

				setLastLoginUser(request, response, account.optString("UR_ID"));
				
				LOGGER.debug("로그인 후 이동페이지 설정 start ---------------------------------------------------------------------------");
				String mainPage = "";
				if(func.f_NullCheck(oa).equals("20")){
					returnURL = "oauthAuthority";
				}else{

					String mobileDomainPCService = RedisDataUtil.getBaseConfig("MobileDomainPCService", isMobile);
					String mobileDomain = RedisDataUtil.getBaseConfig("MobileDomain", isMobile);
					
					if(	isMobile ||
							(mobileDomainPCService.equalsIgnoreCase("DENY") && mobileDomain.equalsIgnoreCase(request.getServerName() ) ) ){
						mainPage= mobileMainPage ;//PropertiesUtil.getGlobalProperties().getProperty("MobileMainPage.path");
						returnURL = "redirect:"+serverUrl + mainPage;
					}else{
						mainPage= pcMainPage;//PropertiesUtil.getGlobalProperties().getProperty("MainPage.path");
						
						//최초 접속 여부 확인 
						if(func.f_NullCheck(account.optString("INITIAL_CONNECTION")).equals("Y")){
							returnURL = "redirect:"+serverUrl+compulsionUrl;
						}else if(func.f_NullCheck(account.optString("TEMPORARY_PASSWORD_ISUSE")).equals("Y")){
							//임시패스워드 발급 변경페이지
							SessionHelper.setExtensionSession(account.optString("UR_ID")+"_PSM","UPCMD", "Y");
							returnURL = "redirect:"+serverUrl+compulsionUrl;
						}else{
							//최종 로그인 날짜와 비밀번호 변경 날짜 비교하여 계정 LOCK 또는 비밀번호 변경 페이지로 이동
							CoviMap params = new CoviMap();
							params.put("domainID", account.optString("DN_ID"));
							params = loginsvc.selectDomainPasswordPolicy(params);
							
							String strLastLoginDate = account.optString("LATEST_LOGIN_DATE");
							String strPwChangeDate = account.optString("PASSWORD_CHANGE_DATE");
							
							//최초 생성
							if(func.f_NullCheck(strLastLoginDate).equals("") || func.f_NullCheck(strPwChangeDate).equals("")){
								loginsvc.updateUserPasswordClear(samlID);
								returnURL = "redirect:"+serverUrl+coercionUrl;
							}else{
								if("N".equalsIgnoreCase(isFido) ||
										"Y".equalsIgnoreCase(isFido) && "Y".equalsIgnoreCase(isFidoAccountLock)) {
									//최종 로그인 날짜와 비밀번호 변경 날짜 비교하여 계정 LOCK 또는 비밀번호 변경 페이지로 이동
									SimpleDateFormat format = new SimpleDateFormat ("yyyy-MM-dd");
									String strCurrentDate = ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss"),"yyyy-MM-dd");
									Date currentDate = format.parse(strCurrentDate);
									
									Calendar calLastLoginDate = new GregorianCalendar();
									calLastLoginDate.setTime(format.parse(strLastLoginDate));
									calLastLoginDate.add(Calendar.DAY_OF_YEAR, Integer.parseInt(PropertiesUtil.getSecurityProperties().getProperty("login.maximum.unavailable.access.dates")));
									
									Calendar calPwChangeDate = new GregorianCalendar();
									calPwChangeDate.setTime(format.parse(strPwChangeDate));
									calPwChangeDate.add(Calendar.DAY_OF_YEAR,  Integer.parseInt(params.get("MaxChangeDate").toString()));
									
									Calendar calPwChangeNoticeDate = new GregorianCalendar();
									calPwChangeNoticeDate.setTime(calPwChangeDate.getTime());
									calPwChangeNoticeDate.add(Calendar.DAY_OF_YEAR,  -1 * Integer.parseInt(params.get("ChangeNoticeDate").toString()));
	
									Date lastLoginDate = new Date(calLastLoginDate.getTimeInMillis());
									Date pwChangeDate = new Date(calPwChangeDate.getTimeInMillis());
									Date pwChangeNoticeDate = new Date(calPwChangeNoticeDate.getTimeInMillis());
									
									long diffLastLogin = (lastLoginDate.getTime() - currentDate.getTime()) / (24 * 60 * 60 * 1000);
 									long diffPwChange = (pwChangeDate.getTime() - currentDate.getTime()) / (24 * 60 * 60 * 1000);
									long diffPwUseDate = (format.parse(strCurrentDate).getTime() - format.parse(strPwChangeDate).getTime()) / (24 * 60 * 60 * 1000);
									
									if(diffLastLogin < 0 || diffPwChange < 0){
										loginsvc.updateUserLock(paramId, "Y");
										returnURL = "redirect:"+serverUrl+"/covicore/logout.do";
									}else if(diffPwChange == 0){ //같은 경우 (게정 잠금이전)
										SessionHelper.setSession("UR_PassExpireDate", format.format(pwChangeNoticeDate));
										SessionHelper.setExtensionSession(account.optString("UR_ID")+"_PSM","UPCMD", "Y");
										SessionHelper.setSession("UR_PassMaxDate", params.get("MaxChangeDate").toString()); //최대사용기간
										SessionHelper.setSession("UR_PassUseDate",String.valueOf(diffPwUseDate)); 			//만료일
										returnURL = "redirect:"+serverUrl+compulsionUrl;
									}else if(currentDate.getTime() >= pwChangeNoticeDate.getTime()){ //아직 기간이 남은경우
										SessionHelper.setSession("UR_PassExpireDate", format.format(pwChangeNoticeDate));
										SessionHelper.setSession("UR_PassMaxDate", params.get("MaxChangeDate").toString()); //최대사용기간
										SessionHelper.setSession("UR_PassUseDate",String.valueOf(diffPwUseDate)); 			//만료일
										returnURL = "redirect:"+serverUrl+coercionUrl;
									}else{
										returnURL = "redirect:"+serverUrl + mainPage;
									}
								}else {
									returnURL = "redirect:"+serverUrl + mainPage;
								}
							}

						}
						
					}
					
				}
			
				//Token 저장.
				LOGGER.debug("Token Historty 추가 start ---------------------------------------------------------------------------");
				if(loginsvc.insertTokenHistory(key, samlID, urNm, urCode, urEmpNo, maxAge, "I", "")){
					
					//account.put("Type", "AI");
					//ssoSamlCon.setSamlInsideResponse(account,request,response);
					
				}
				
			} else {
				//접속실패로그
				LoggerHelper.connectFalseLogger(paramId,"LOGIN");
				if(func.f_NullCheck(oa).equals("20")){
					returnURL = "redirect:"+request.getParameter("redirectUri");
				}else{
					returnURL = "login";
				}
				loginState = "fail";
			}
			
		}
		catch (NullPointerException e){
			throw e;
		}
		catch (Exception e){
			throw e;
		}
		
		if(!func.f_NullCheck(acr).equals("")){
			returnURL = "core/login/redirect";
			
			String publicKeyFilePath = null;
			String privateKeyFilePath = null;
			
			String issueInstant = Util.getDateAndTime();
			
			String osName = System.getProperty("os.name");
			if(osName.indexOf("Windows") != -1){
				publicKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+publicKey);
				privateKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+privateKey);
			}else{
				String path = loginsvc.checkSSO("PATH");
				publicKeyFilePath = path+publicKey ;
				privateKeyFilePath = path+privateKey ; 
			}
			request.setAttribute("issueInstant", issueInstant);
			request.setAttribute("providerName", "Covision");
			request.setAttribute("RelayState", "");
			
			// First, verify that the NotBefore and NotOnOrAfter values
			// are valid
			RSAPrivateKey privateKey = (RSAPrivateKey) Util
					.getPrivateKey(privateKeyFilePath, "RSA");
			
			RSAPublicKey publicKey = (RSAPublicKey) Util.getPublicKey(
					publicKeyFilePath, "RSA");
			long now = System.currentTimeMillis();
			
			String day = loginsvc.checkSSO("DAY");
			int time = 0 ;
			if(func.f_NullCheck(day).equals("")){
				time = 0 ;
			}else{
				time = Integer.parseInt(day);
				time = time * 24;
			}
			
			long nowafter = now + 1000L * 60 * 60 * time;
			long nowbefore = now - 1000L * 60 * 60 * time;
			SimpleDateFormat dateFormat1 = new SimpleDateFormat(
					"yyyy-MM-dd'T'hh:mm:ss'Z'");
				java.util.Date pTime = new java.util.Date(nowbefore);
			String notBefore = dateFormat1.format(pTime);
				java.util.Date aTime = new java.util.Date(nowafter);
			String notOnOrAfter = dateFormat1.format(aTime);
			
			request.setAttribute("notBefore", notBefore);
			request.setAttribute("notOnOrAfter", notOnOrAfter);
			String responseXmlString = createSamlResponse(urNm, notBefore, notOnOrAfter, "covision", request, samlID, issueInstant,request.getParameter("uid"),request.getParameter("destination"),request.getParameter("acr") );
			String signedSamlResponse = SAMLSigner.signXML(
					responseXmlString, privateKey, publicKey);
			
			returnData.put("returnURL", acr);
			returnData.put("SAMLResponse", RequestUtil.encodeMessage(signedSamlResponse));
			returnData.put("RelayState", URLEncoder.encode(""));
			returnData.put("loginState", "success");
			return returnData;
		}

		returnData.put("returnURL", returnURL);
		if(!func.f_NullCheck(oa).equals("20")){
			returnData.put("loginState", loginState);
		}else{
			returnData.put("redirecturi", loginState);
			returnData.put("scope", scope+",");
			returnData.put("isloginned", true);
			returnData.put("currenturl", currenturl);
			returnData.put("clientname", clientname);
		}
		LOGGER.debug("loginchk.do end ---------------------------------------------------------------------------");
		return returnData;
	}

	@RequestMapping(value = "/logout.do")
	public ModelAndView logout(HttpServletRequest request, HttpServletResponse response) throws Exception {
		StringUtil func = new StringUtil();
		CookiesUtil cUtil = new CookiesUtil();
		RedisShardsUtil instance = RedisShardsUtil.getInstance();

		try{
			
			String subDomain = SessionHelper.getSession("SubDomain");
			HttpSession session = request.getSession();
			
			String key = (String) session.getAttribute("KEY");
			String key_psm =  (String) session.getAttribute("USERID");
			
			CoviMap params = new CoviMap();
			
			params.put("logonID", SessionHelper.getSession("LogonID"));
			params.put("IPAddress", func.getRemoteIP(request));
			params.put("OS", ClientInfoHelper.getClientOsInfo(request));
			params.put("browser", ClientInfoHelper.getClientWebKind(request)	+ ClientInfoHelper.getClientWebVer(request));
			
			loginsvc.updateLogoutTime(params);
			
			cUtil.removeCookies(response, request, key, "D", "N",subDomain);
			
			if( !ClientInfoHelper.isMobile(request) && !func.f_NullCheck(key_psm).equals("")){
				key_psm = key_psm + "_PSM";
				instance.remove(key_psm);
			}
		}
		catch(NullPointerException e){
			throw e;
		}
		catch(Exception e){
			throw e;
		}
		
		String returnURL =  "redirect:"+ request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + PropertiesUtil.getGlobalProperties().getProperty("LoginPage.path"); // /covicore/login.do";
		
		ModelAndView mav = new ModelAndView(returnURL);
		return mav;
	}
	
	@RequestMapping(value = "/removeSession.do")
	public void removeSession(HttpServletRequest request, HttpServletResponse response) throws Exception {
		StringUtil func = new StringUtil();
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		try{
			HttpSession session = request.getSession();
			
/*			CoviMap accountList = new CoviMap();
			CoviMap account = new CoviMap();
			SsoSamlCon ssoSamlCon = new SsoSamlCon();*/
			CookiesUtil cUtil = new CookiesUtil();
			
			String subDomain = SessionHelper.getSession("SubDomain");
			
			String key = (String) session.getAttribute("KEY");
			String key_psm =  (String) session.getAttribute("USERID");
			
			cUtil.removeCookies(response, request, key, "D", "N",subDomain);
			
			if( !ClientInfoHelper.isMobile(request) && !func.f_NullCheck(key_psm).equals("")){
				key_psm = key_psm + "_PSM";
				instance.remove(key_psm);
			}
		}
		catch(NullPointerException e){
			throw e;
		}
		catch(Exception e){
			throw e;
		}
	}
	
	@RequestMapping(value = "/loginbasechk.do")
	public @ResponseBody CoviMap loginBasedCheck(HttpServletRequest request, HttpServletResponse response) throws Exception {
		LOGGER.debug("loginbasechk.do start ---------------------------------------------------------------------------");
		
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		TokenHelper tokenHelper = new TokenHelper();
		CookiesUtil cUtil = new CookiesUtil();
		StringUtil func = new StringUtil();
		
		boolean isMobile = ClientInfoHelper.isMobile(request); 
		
		String id = request.getParameter("id");
		String pw = request.getParameter("pw");
		String lang = request.getParameter("language");
		String isFido  = Objects.toString( request.getParameter("isFIDO") ,"N"); 				//FIDO 인증이 된 경우 비밀번호 및 two factor 체크 필요 없음, 비밀번호 변경 및 만료일 페이지 이동X
		
		String message = "";
		String bodyText = "";
		
		if(func.f_NullCheck(cryptoType).equals("R")){
			if ((PrivateKey) request.getSession().getAttribute("__CoviRPK__") == null){
				returnList.put("result","nosession");
				return returnList;
			}
			else{
				try{
					pw = RSA.decryptRsa((PrivateKey) request.getSession().getAttribute("__CoviRPK__"), pw);
				}
				catch(NullPointerException e){
					returnList.put("result","nosession");
					return returnList;
				}
				catch(Exception e){
					returnList.put("result","nosession");
					return returnList;
				}
			}	
		}else if(func.f_NullCheck(cryptoType).equals("A")){
			AES aes = new AES("", "P");
			
			pw = aes.pb_decrypt(pw);
		}
		LOGGER.debug("lock 여부  check star ---------------------------------------------------------------------------");
		int lockCount = loginsvc.selectAccountLock(id); 
		
		if(lockCount > 0){
			returnList.put("result","lock");
			LoggerHelper.connectFalseLogger(id,"LOCK");
		}else{
			String pId = "";
			
			if(!"Y".equalsIgnoreCase(isFido)){
				pId = loginsvc.selectUserAuthetication(id, pw) ;
			}
		
			if(!"".equals(func.f_NullCheck(pId)) || "Y".equalsIgnoreCase(isFido) ){	
				LOGGER.debug("계정 정보 조회 start ---------------------------------------------------------------------------");
				resultList = loginsvc.checkAuthetication("SSO", id, pw, lang);
				CoviMap account = (CoviMap) resultList.get("account");
				
				if(!isMobile) { // mobile 아닐 경우 
					LOGGER.debug("사용자 IP 접근제어 체크로직 start ---------------------------------------------------------------------------");
					if(func.f_NullCheck(account.optString("CheckUserIP")).equals("Y")) {
						String currentIP = func.getRemoteIP(request);
						String userStartIP = func.f_NullCheck(account.optString("StartIP"));
						String userEndIP = func.f_NullCheck(account.optString("EndIP"));
						
						if(!loginsvc.checkIPScope(currentIP, userStartIP, userEndIP)) {
							LoggerHelper.connectFalseLogger(id,"IP");
							returnList.put("result", "inaccessIP");
							return returnList;
						}
						
					}
					
					LOGGER.debug("twofactor 체크로직 start ---------------------------------------------------------------------------");
					String twoFactorUsed = RedisDataUtil.getBaseConfig("useTwoFactorLogin", account.optString("DN_ID")); //Two Factor 로그인 사용여부 Y/N
					if(func.f_NullCheck(twoFactorUsed).equals("Y") && isFido.equalsIgnoreCase("N")){
						CoviMap params = new CoviMap();
						String partIPAddress = convertIpString(func.getRemoteIP(request)); 
						
						params.put("partIPAddress", partIPAddress);
						params.put("domainID", account.optString("DN_ID"));
						
						if(authSvc.selectTwoFactorIpCheck(params,"U") == 0){
							returnList.put("result","factor");
							return returnList;
						}
					}
					
					LOGGER.debug("중복로그인 체크로직 start ---------------------------------------------------------------------------");
					RedisShardsUtil instance = RedisShardsUtil.getInstance();	
					
					String key_psm = account.optString("UR_ID") + "_PSM";
					if(RedisDataUtil.getBaseConfig("chkDuplicatoinLogin", isMobile).equalsIgnoreCase("Y")){//중복 로그인 확인
						if(instance.get(key_psm) != null ){ //중복 로그인 확인
							String activeTime= request.getParameter("activeTime");
							int compare = -1;
							if (activeTime != null && !activeTime.equals("")){
								java.sql.Timestamp t = new java.sql.Timestamp(Long.parseLong(activeTime));
								java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		
								CoviMap obj = CoviMap.fromObject(instance.get(key_psm));
								CoviMap objUser = CoviMap.fromObject(instance.get(obj.optString("TokenKey")));
								if (instance.get(obj.optString("TokenKey")) != null		&& objUser.get("UR_LoginTime") != null)
									compare = (sdf.format(t)).compareTo(objUser.optString("UR_LoginTime"));
								else compare = 0;
							}	

							if (compare < 0){
								if(!func.f_NullCheck(account.optString("UR_Mail")).equals("")){
									bodyText = duplicationHtmlText(id,account.optString("DN_ID"),lang);
		
									LoggerHelper.auditLogger(id, "S", "SMTP", PropertiesUtil.getExtensionProperties().getProperty("mail.mailUrl"), bodyText, "MailAddress");
									MessageHelper.getInstance().sendSMTP(DicHelper.getDic("lbl_admin",lang), PropertiesUtil.getGlobalProperties().getProperty("SenderErrorMail"), account.get("UR_Mail").toString(), id+" "+DicHelper.getDic("msg_simultaneousAccessGuidInfo",lang), bodyText, true);  
								}
								returnList.put("result","duplication");
								return returnList;
							}	
						}	
						
					}
				}

				LOGGER.debug("SSO config 조회 start ---------------------------------------------------------------------------");
				String date = loginsvc.checkSSO("DAY");
				
				LOGGER.debug("쿠키 생성  start ---------------------------------------------------------------------------");
				String accessDate = tokenHelper.selCookieDate(date,"");
				String key = tokenHelper.setTokenString(id,date,pw,lang,account.optString("UR_Mail"), account.optString("DN_Code"), account.optString("UR_EmpNo"),account.optString("DN_Name"),account.optString("UR_Name"),account.optString("UR_Mail"),account.optString("GR_Code"),account.optString("GR_Name"),account.optString("Attribute"),account.optString("DN_ID"));
				
				if(!"".equals(key) && !"".equals(accessDate)){
					returnList.put("key", key);
					returnList.put("access_date", accessDate);
					returnList.put("result","ok");
					
					cUtil.setCookies(response, key, accessDate,account.optString("SubDomain"));
					
					if(loginsvc.deleteUserFailCount(id)){
						loginsvc.updateUserLock(id, "N");
					}
					
					LOGGER.debug("쿠키 생성 end ---------------------------------------------------------------------------");
				}else{
					returnList.put("result","fail");
					LoggerHelper.connectFalseLogger(id,"LOGIN");
				}
			}else{
				if(loginsvc.updateUserFailCount(id)){ //비밀번호만 틀렸을 경우 
					CoviMap failMap = loginsvc.selectUserFailCount(id);
					int failCount = failMap.getInt("failCount");
					String systemFailCount =  PropertiesUtil.getSecurityProperties().getProperty("privacy.secure.login.count");
					//기초설정에 값이 있으면 기초설정값으로 세팅
					if (!RedisDataUtil.getBaseConfig("loginFailCount", failMap.getString("DN_ID")).equals("")){
						systemFailCount = RedisDataUtil.getBaseConfig("loginFailCount", failMap.getString("DN_ID"));
					}
					
					if(failCount >= Integer.parseInt(systemFailCount)){
						resultList = loginsvc.checkAuthetication("SSO", id, pw, lang);
						
						CoviMap account = (CoviMap) resultList.get("account");
						
						loginsvc.updateUserLock(id, "Y");
						
						message = id+" "+DicHelper.getDic("msg_accountLockInfo",lang);
						
						
						if(!func.f_NullCheck(account.get("ExternalMailAddress").toString()).equals("")){
							
							bodyText = lockHtmlText(id,failMap.getString("DN_ID"),lang);
							
							LoggerHelper.auditLogger(id, "S", "SMTP", PropertiesUtil.getExtensionProperties().getProperty("mail.mailUrl"), bodyText, "ExternalMailAddress");						
							MessageHelper.getInstance().sendSMTP(DicHelper.getDic("lbl_admin",lang), PropertiesUtil.getGlobalProperties().getProperty("SenderErrorMail"), account.get("ExternalMailAddress").toString(), id+" "+DicHelper.getDic("msg_accountLockGuidInfo",lang), bodyText, true);
						}
						
						if(!func.f_NullCheck(account.get("UR_Mail").toString()).equals("")){
							
							if(func.f_NullCheck(bodyText).equals("")){
								bodyText = lockHtmlText(id,failMap.getString("DN_ID"),lang);
							}
							
							LoggerHelper.auditLogger(id, "S", "SMTP", PropertiesUtil.getExtensionProperties().getProperty("mail.mailUrl"), bodyText, "MailAddress");
							MessageHelper.getInstance().sendSMTP(DicHelper.getDic("lbl_admin",lang), PropertiesUtil.getGlobalProperties().getProperty("SenderErrorMail"), account.get("UR_Mail").toString(), id+" "+DicHelper.getDic("msg_accountLockGuidInfo",lang), bodyText, true);
						}
						
						String badgeCount = messageManageSvc.selectBadgeCount(id);		
						MessageHelper.getInstance().sendPushByUserID(id, message, badgeCount);
						
						returnList.put("result","lock");
					}else{ //아이디 & 비번 모두 틀렸을 경우 
						returnList.put("result","fail");	
					}
				}else{
					returnList.put("result","fail");
				}
				
				LoggerHelper.connectFalseLogger(id,"LOGIN");
			}
		}
		
		LOGGER.debug("loginbasechk.do end ---------------------------------------------------------------------------");
		return returnList;
	
	}
	
	private static final long serialVersionUID = 3493465535826290477L;
	private static final String SAML_REQUEST_TEMPLATE = "AuthnRequestTemplate.xml";
	
	@RequestMapping(value = "/samlloginchk.do")
	public void samlloginCheck(HttpServletRequest request, HttpServletResponse response) throws Exception {
		LOGGER.info("## SAML Login Check##");
		response.setHeader("Content-Type", "text/html; charset=UTF-8");
		response.setContentType("text/html; charset=UTF-8");
		
		StringUtil func = new StringUtil();
		TokenHelper tokenHelper = new TokenHelper();
		TokenParserHelper tokenParserHelper = new TokenParserHelper();

		CoviMap resultList = new CoviMap();
		SsoSamlCon ssoSamlCon = new SsoSamlCon();
		CookiesUtil cUtil = new CookiesUtil();
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		HttpSession session = request.getSession();
		
		String loginState = "success";
		String providerName = request.getParameter("providerName");
		String option =  request.getParameter("option");
		String ssoURL = loginsvc.checkSSO("URL");
		String samlRequest =  request.getParameter("SAMLRequest");
		String acr = request.getParameter("acr");
		String uid =  request.getParameter("uid");
		String relayState = "";
		
		//SAML Request 
		String issuer = "";
		String issueInstant = Util.getDateAndTime();
		String spEntity = "";
		String spIssuerUrl = "";
		String spTarget = "";
		String assertionConsumerServiceURL = request.getParameter("acr");
		String idpEntity = "";
		String idpSsoUrl = "";
		String destination = request.getParameter("destination");
		
		String name = "";
		String authType = "";
		String status = "";
		String key = "";
		String accessDate = "";
		String date = "";
		String returnURL = "";
		String maxAge = "";
		String signedSamlResponse = "";
		String assertionID = Util.createID();
		
		boolean continueLogin = true;
		
		if(func.f_NullCheck(samlRequest).equals("")){
			 LOGGER.info("## SAML Login - No SAML Request ##");
			 relayState = loginsvc.checkSSO("RS");
			 
				String SAMLRequest;
				String redirectURL = "";
				String id = request.getParameter("id");
				String pw = request.getParameter("password");
				String lang = request.getParameter("language");
				if(func.f_NullCheck(acr).equals("")){
					
						
					key = cUtil.getCooiesValue(request);
					
					String decodKey = tokenHelper.getDecryptToken(key);
					if(!tokenParserHelper.parserJsonVerification(decodKey,request.getParameter("id"))){
						
						returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/logout.do";
						
						RequestDispatcher  rd = request.getRequestDispatcher(returnURL);
						rd.forward(request, response);
						
					}else{
						maxAge = tokenParserHelper.parserJsonMaxAge(decodKey);
					}
						
					
					//loginService 인증 처리 로직 시작
					String paramId = request.getParameter("id");
					String paramPwd = "";
					String paramLang = request.getParameter("language");
					authType = "SSO";
					
					//인증체크 로직 수행
					resultList = loginsvc.checkAuthetication(authType, paramId, paramPwd, paramLang);
					// 웹페이지에서받은 아이디,패스워드 일치시 admin 세션key 생성
					status = resultList.get("status").toString();
					CoviMap account = (CoviMap) resultList.get("account");
					
					//인증 성공 시
					if (status.equals("OK")) {
						//라이선스 인증 정보 초기화
						LicenseHelper.resetUserLicenseCheck(account.get("UR_Code").toString(), account.get("DN_ID").toString());
						
						//세션 생성
						session.getServletContext().setAttribute(key, account.get("UR_ID").toString());
						session.setAttribute("KEY", key);
						session.setAttribute("USERID", account.get("UR_ID").toString());
						session.setAttribute("LOGIN", "Y");
						
						//redis에 세션 저장
						// key, value, expire 시간, 시간단위
						
						String urNm = account.get("UR_Name").toString();
						String urCode = account.get("UR_Code").toString();
						String urEmpNo = account.get("UR_EmpNo").toString();
						String urId = account.get("UR_ID").toString();
						
						account.put("UR_LoginIP",func.getRemoteIP(request));
						SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account, isMobile);
						//SessionHelper.setSession("SSO", authType);
						//SessionHelper.setSession("USERPW",  request.getParameter("password"));
						SessionHelper.setSession("lang", paramLang);
						
						// 접속로그 생성
						LoggerHelper.connectLogger();

						String mainPage = "";
						
						if(ClientInfoHelper.isMobile(request)){
							mainPage= PropertiesUtil.getGlobalProperties().getProperty("MobileMainPage.path");
						}else{
							mainPage= PropertiesUtil.getGlobalProperties().getProperty("MainPage.path");
						}
						
						returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + mainPage;
						
						
						if ("1".equals(PropertiesUtil.getSecurityProperties().getProperty("sso.type"))) {
							//Token 저장.

							if(loginsvc.insertTokenHistory(key, id, urNm, urCode, urEmpNo, maxAge, "I", "")){
								
								//account.put("Type", "AI");
								//ssoSamlCon.setSamlInsideResponse(account,request,response);
								
							}
						}
						loginState = "success";
					} else {
						//접속실패로그
						LoggerHelper.connectFalseLogger(paramId,"SAML");
						
						returnURL = "redirect:"+request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/logout.do";
						
						loginState = "fail";
					}
					
					response.sendRedirect(returnURL+"?loginState="+loginState);
					
				}else{
					LOGGER.info("## SAML Login - No SAML Request > AssertionConsumerServiceURL ##");
					String publicKeyFilePath = null;
					String privateKeyFilePath = null;
					String osName = System.getProperty("os.name");
					if(osName.indexOf("Windows") != -1){
						publicKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+publicKey);
						privateKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+privateKey);
					}else{
						String path = loginsvc.checkSSO("PATH");
						publicKeyFilePath = path+publicKey ;
						privateKeyFilePath = path+privateKey ; 
					}
					request.setAttribute("issueInstant", issueInstant);
					request.setAttribute("providerName", "Covision");
					request.setAttribute("RelayState", relayState);
					
					// First, verify that the NotBefore and NotOnOrAfter values
					// are valid
					RSAPrivateKey privateKey = (RSAPrivateKey) Util
							.getPrivateKey(privateKeyFilePath, "RSA");
					
					RSAPublicKey publicKey = (RSAPublicKey) Util.getPublicKey(
							publicKeyFilePath, "RSA");
					long now = System.currentTimeMillis();
					
					String day = loginsvc.checkSSO("DAY");
					int time = 0 ;
					if(func.f_NullCheck(day).equals("")){
						time = 0 ;
					}else{
						time = Integer.parseInt(day);
						time = time * 24;
					}
					
					long nowafter = now + 1000L * 60 * 60 * time;
					long nowbefore = now - 1000L * 60 * 60 * time;
					SimpleDateFormat dateFormat1 = new SimpleDateFormat(
							"yyyy-MM-dd'T'hh:mm:ss'Z'");

					java.util.Date pTime = new java.util.Date(nowbefore);
					String notBefore = dateFormat1.format(pTime);

					java.util.Date aTime = new java.util.Date(nowafter);
					String notOnOrAfter = dateFormat1.format(aTime);
					
					request.setAttribute("notBefore", notBefore);
					request.setAttribute("notOnOrAfter", notOnOrAfter);
					String responseXmlString = createSamlResponse(name, notBefore, notOnOrAfter, "covision", request,id, issuer, uid, destination, assertionConsumerServiceURL);
					
					signedSamlResponse = SAMLSigner.signXML(
							responseXmlString, privateKey, publicKey);
					
					
					StringBuffer buf = new StringBuffer();
					
					buf.append("samlRedirect.do");
					buf.append("?SAMLResponse=");
					buf.append(RequestUtil.encodeMessage(signedSamlResponse));
					buf.append("&RelayState=");
					buf.append(URLEncoder.encode(relayState));
					buf.append("&uid=");
					buf.append(uid);
					buf.append("&acr=");
					buf.append(acr);
					returnURL =  buf.toString();
					
					RequestDispatcher  rd = request.getRequestDispatcher(returnURL);
					rd.forward(request, response);
				}
			 
		}else{
			LOGGER.info("## SAML Login - SAML Request ##");
			
			relayState =  request.getParameter("RelayState");

			key = cUtil.getCooiesValue(request);
			
			if(!"".equals(key)){
				TokenParserHelper tokenParserHelperCon = new TokenParserHelper();
				String decodeKey = tokenHelper.getDecryptToken(key);
					
				Map map = new HashMap();
					
				map = tokenParserHelperCon.getSSOToken(decodeKey);
					
				//토큰과 현재 정보 비교.
				String id = (String) map.get("id");
				String pw = (String) map.get("pw");
				String lang = (String) map.get("lang");
				issueInstant = Util.getDateAndTime();
				if(!"".equals(id) && !"".equals(pw) ){
					if(loginsvc.checkUserAuthetication(id,pw) > 0){
						if(tokenParserHelperCon.parserJsonLoginVerification(decodeKey)){
								
							// Domain name of IP
							String publicKeyFilePath = null;
							String privateKeyFilePath = null;
							 
							String osName = System.getProperty("os.name");
							if(osName.indexOf("Windows") != -1){
								publicKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+publicKey);
								privateKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+privateKey);
							}else{
								String path = loginsvc.checkSSO("PATH");
								publicKeyFilePath = path+publicKey ;
								privateKeyFilePath = path+privateKey ; 
							}
							request.setAttribute("issueInstant", issueInstant);
							request.setAttribute("providerName", "Covision");
							request.setAttribute("RelayState", relayState);
							
							// First, verify that the NotBefore and NotOnOrAfter values
							// are valid
							RSAPrivateKey privateKey = (RSAPrivateKey) Util
									.getPrivateKey(privateKeyFilePath, "RSA");
							
							RSAPublicKey publicKey = (RSAPublicKey) Util.getPublicKey(
									publicKeyFilePath, "RSA");
							long now = System.currentTimeMillis();
							
							String day = loginsvc.checkSSO("DAY");
							
							int time = 0 ;
							
							if(func.f_NullCheck(day).equals("")){
								time = 0 ;
							}else{
								if (Integer.parseInt(day) < Integer.MAX_VALUE) {
									time = Integer.parseInt(day);
									time = time * 24;
								}
							}
							
							long nowafter = now + 1000L * 60 * 60 * time;
							long nowbefore = now - 1000L * 60 * 60 * time;
							SimpleDateFormat dateFormat1 = new SimpleDateFormat(
									"yyyy-MM-dd'T'hh:mm:ss'Z'");
								java.util.Date pTime = new java.util.Date(nowbefore);
							String notBefore = dateFormat1.format(pTime);
								java.util.Date aTime = new java.util.Date(nowafter);
							String notOnOrAfter = dateFormat1.format(aTime);
							
							request.setAttribute("notBefore", notBefore);
							request.setAttribute("notOnOrAfter", notOnOrAfter);
							
							if (!validSamlDateFormat(issueInstant)) {
								continueLogin = false;
								request.setAttribute("error",
										"ERROR: Invalid NotBefore date specified - "
												+ notBefore);
								request.setAttribute("authstatus", "FAIL");
							} else if (!validSamlDateFormat(notOnOrAfter)) {
								continueLogin = false;
								request.setAttribute("error",
										"ERROR: Invalid NotOnOrAfter date specified - "
												+ notOnOrAfter);
								request.setAttribute("authstatus", "FAIL");
							}
							
							// Sign XML containing user name with specified keys
							if (continueLogin) {
								// Generate SAML response contaning specified user name
								String responseXmlString = createSamlResponse(name, notBefore, notOnOrAfter, "covision", request,id, issuer, uid, destination, assertionConsumerServiceURL);
								// Sign the SAML response XML
								signedSamlResponse = SAMLSigner.signXML(
										responseXmlString, privateKey, publicKey);
								//여기서 작업 (Session 처리)
								String paramId = id;
								String paramPwd = pw;
								String paramLang = lang;
							
								authType = "SAML";
								
								//인증체크 로직 수행
								resultList = loginsvc.checkAuthetication(authType, paramId, paramPwd, paramLang);
								
								status = resultList.get("status").toString();
								CoviMap account = (CoviMap) resultList.get("account");
								CoviMap accountTokenList = (CoviMap) resultList.get("account");
									
								int sessionDelChk =0;
								//인증 성공 시
								if (status.equals("OK")) {
									date = loginsvc.checkSSO("DAY");
									CoviMap accountList = new CoviMap();
									
									if(func.f_NullCheck(account.get("UR_Code").toString()).equals("")
											|| func.f_NullCheck(account.get("LogonPW").toString()).equals("")
											|| func.f_NullCheck(account.get("LanguageCode").toString()).equals("")){
										// ERROR 
									}else{
										paramId = account.get("UR_Code").toString();
										paramLang = account.get("LanguageCode").toString();
											
										if(func.f_NullCheck(key).equals("")){
											key = (String) session.getAttribute("KEY");
											if(!func.f_NullCheck(key).equals("")){
												//accountList = loginsvc.selectTokenInForMation(key);
												//accountTokenList = (CoviMap) accountList.get("account");
												
												//account.put("Type", "AO");
												
												//ssoSamlCon.setSamlInsideResponse(accountTokenList,request,response);
												sessionDelChk = 1; //세션 삭제 확인 용.
												
												cUtil.removeCookies(response, request, key, "D", "N",account.get("SubDomain").toString());
												
											}
										}else{
											if(!func.f_NullCheck(key).equals("")){
												/*accountList = loginsvc.selectTokenInForMation(key);
												accountTokenList = (CoviMap) accountList.get("account");
											
												accountTokenList.put("Type", "AO");
												
												ssoSamlCon.setSamlInsideResponse(accountTokenList,request,response);*/
												sessionDelChk = 1; //세션 삭제 확인 용.
												
												cUtil.removeCookies(response, request, key, "D", "N",account.get("SubDomain").toString());
												
											}
										}
										if(sessionDelChk > 0 ){
											session = request.getSession();
										}
										
										key = tokenHelper.setTokenString(account.get("LogonID").toString(), date, paramPwd, paramLang,account.get("UR_Mail").toString(),account.get("DN_Code").toString(),account.get("UR_EmpNo").toString()
												, account.get("DN_Name").toString(), account.get("UR_Name").toString(), account.get("UR_Mail").toString(), account.get("GR_Code").toString() 
												, account.get("GR_Name").toString(), account.get("Attribute").toString(), account.get("DN_ID").toString()
												);
										
										accessDate = tokenHelper.selCookieDate(date,"");
										
										//라이선스 인증 정보 초기화
										LicenseHelper.resetUserLicenseCheck(account.get("UR_Code").toString(), account.get("DN_ID").toString());
										
										session.getServletContext().setAttribute(key, account.get("UR_ID").toString() );
										session.setAttribute("KEY", key);
										session.setAttribute("USERID", account.get("UR_ID").toString());
										session.setAttribute("LOGIN", "Y");
										
										String urNm = account.get("UR_Name").toString();
										String urCode = account.get("UR_Code").toString();
										String urEmpNo = account.get("UR_EmpNo").toString();
										String urId = account.get("UR_ID").toString();
												
										account.put("UR_LoginIP",func.getRemoteIP(request));
										SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account, isMobile);
										//SessionHelper.setSession("SSO", authType);
										//SessionHelper.setSession("USERPW", paramPwd);
										SessionHelper.setSession("lang", paramLang, isMobile);
												
										// 접속로그 생성
										LoggerHelper.connectLogger();
												
										String mainPage = "";
										if(ClientInfoHelper.isMobile(request)){
											mainPage= PropertiesUtil.getGlobalProperties().getProperty("MobileMainPage.path");
										}else{
											mainPage= PropertiesUtil.getGlobalProperties().getProperty("MainPage.path");
										}
												
										if(func.f_NullCheck(acr).equals("")){
											returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + mainPage;
										}else{
											returnURL = acr;
										}

										maxAge = tokenHelper.selCookieDate(date,"1");
										//Token 저장.
										if(loginsvc.insertTokenHistory(key, account.get("LogonID").toString(), urNm, urCode, urEmpNo, maxAge, "E", assertionID)){
										}
												
										//세션 생성이후 생성.
										if(!"".equals(key) && !"".equals(accessDate)){
											
											cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());
											
										}
												
									}//URCORE, LOGINPW, LANGUAGE CODE 
									
								}//status.equals("OK")
										
										
							}//continueLogin
								
						}//tokenParserHelperCon.parserJsonLoginVerification(decode_key)
					}//ssoSamlSvc.checkUserAuthetication(id,pw) > 0
				}//!"".equals(id) && !"".equals(pw)
					
			}//!"".equals(key)
				
				
			response.setContentType("text/html; charset=UTF-8");
			if(!func.f_NullCheck(returnURL).equals("")){
				LOGGER.info("## SAML Login - returnURL NOT NULL ##");
				
				StringBuffer buf = new StringBuffer();
				
				buf.append("samlRedirect.do");
				buf.append("?SAMLResponse=");
				buf.append(RequestUtil.encodeMessage(signedSamlResponse));
				buf.append("&RelayState=");
				buf.append(URLEncoder.encode(relayState));
				buf.append("&uid=");
				buf.append(uid);
				buf.append("&acr=");
				buf.append(acr);
				returnURL =  buf.toString();
				
				RequestDispatcher  rd = request.getRequestDispatcher(returnURL);
				rd.forward(request, response);
				
			}else{
				LOGGER.info("## SAML Login - returnURL ##");
				
			}
		}
		
	}
	
	private String createAuthnRequest(String acsURL, String providerName,
			HttpServletRequest request) throws SamlException {
		
		String filepath = request.getSession().getServletContext().getRealPath(
				"WEB-INF/classes/security/" + SAML_REQUEST_TEMPLATE);
		String authnRequest = Util.readFileContents(filepath);
		
		authnRequest = StringUtils.replace(authnRequest, "##PROVIDER_NAME##",
				providerName);
		
		authnRequest = StringUtils.replace(authnRequest, "##ACS_URL##", acsURL);
		authnRequest = StringUtils.replace(authnRequest, "##AUTHN_ID##", Util
				.createID());
		authnRequest = StringUtils.replace(authnRequest, "##ISSUE_INSTANT##",
				Util.getDateAndTime());
		
		return authnRequest;
	}

	/**
	 * <pre>
	 * 1. 개요 : compute URL to forward AuthnRequest to the Identity Provider
	 * </pre>
	 * @Method Name : computeURL
	 * @date : 2017. 7. 28.
	 * @param ssoURL
	 * @param authnRequest
	 * @param RelayState
	 * @return
	 * @throws SamlException
	 */ 	
	private String computeURL(String ssoURL, String authnRequest,
			String RelayState) throws SamlException {
		StringBuffer buf = new StringBuffer();
		try {
			buf.append(ssoURL);

			buf.append("?SAMLRequest=");
			buf.append(RequestUtil.encodeMessage(authnRequest));

			buf.append("&RelayState=");
			buf.append(URLEncoder.encode(RelayState));
			return buf.toString();
		} catch (UnsupportedEncodingException e) {
			throw new SamlException(
					"Error encoding SAML Request into URL: Check encoding scheme - "
							+ e.getMessage());
		} catch (IOException e) {
			throw new SamlException(
					"Error encoding SAML Request into URL: Check encoding scheme - "
							+ e.getMessage());
		}
	}
	
	@RequestMapping(value = "/response.do")
	public void samlresponse(HttpServletRequest request, HttpServletResponse response) throws Exception {
		LOGGER.info("## SAML Response ##");
		CookiesUtil cUtil = new CookiesUtil();
		
		String requestXmlString = request.getParameter("SAMLResponse");
		String SAMLResponse;
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		SAMLResponse = ProcessResponseServlet.decodeAuthnRequestXML(StringUtil.replaceNull(requestXmlString));
		String[] samlRequestAttributes = ProcessResponseServlet.getRequestAttributes(SAMLResponse);
		String userId = samlRequestAttributes[7];
		String issueInstant = samlRequestAttributes[0];
		String assertionID = samlRequestAttributes[3];
		
		String RelayState = request.getParameter("RelayState");
		String domainName = request.getParameter("domainName");
		String subDomain = SessionHelper.getSession("SubDomain");
		
		// acs knows public key only.
		String date = null;
		String publicKeyFilePath = null;
		String redirectURL = "";
		String authType = "";
		String key = "";
		
		int sessionDelChk = 0;
		
		StringUtil func = new StringUtil();
		
		HttpSession session = request.getSession();
		
		String osName = System.getProperty("os.name");
		
		if(osName.indexOf("Windows") != -1){
			publicKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+publicKey);
		}else{
			String path = loginsvc.checkSSO("PATH");
			publicKeyFilePath = path+publicKey ;
		}
		
		RSAPublicKey publicKey;
		publicKey = (RSAPublicKey) Util.getPublicKey(publicKeyFilePath,
				"RSA");
		boolean isVerified = SAMLVerifier
				.verifyXML(SAMLResponse, publicKey); 
		
		
		if (isVerified) {

			request.setAttribute("RelayState", RelayState);

			request.getSession().setAttribute("ssoSamlResult", SAMLResponse);
			response.setContentType("text/html; charset=UTF-8");
			
			//SAML
			authType = "SAML";
			
			CoviMap accountList = new CoviMap();
			CoviMap account = new CoviMap();
			SsoSamlCon ssoSamlCon = new SsoSamlCon();
			
			key = cUtil.getCooiesValue(request);
				
			if(func.f_NullCheck(key).equals("")){
				key = (String) session.getAttribute("KEY");
				if(!func.f_NullCheck(key).equals("")){
					/*accountList = loginsvc.selectTokenInForMation(key);
					account = (CoviMap) accountList.get("account");
					
					account.put("Type", "AO");
					
					ssoSamlCon.setSamlInsideResponse(account,request,response);*/
					sessionDelChk = 1; //세션 삭제 확인 용.
					
					cUtil.removeCookies(response, request, key, "D", "N",subDomain);
				}
			}else{
				/*accountList = loginsvc.selectTokenInForMation(key);
				account = (CoviMap) accountList.get("account");
				
				account.put("Type", "AO");
				
				ssoSamlCon.setSamlInsideResponse(account,request,response);*/
				sessionDelChk = 1; //세션 삭제 확인 값.
	
				cUtil.removeCookies(response, request, key, "D", "N",subDomain);
				
			}
			
			//처리 
			String day = loginsvc.checkSSO("DAY");
			
			boolean continueLogin = true;
			
			int time = 0 ;
			if(func.f_NullCheck(day).equals("")){
				time = 0 ;
			}else{
				time = Integer.parseInt(day);
				time = time * 24;
			}
			
			long now = System.currentTimeMillis();
			
			long nowafter = now + 1000L * 60 * 60 * time;
			long nowbefore = now - 1000L * 60 * 60 * time;
			SimpleDateFormat dateFormat1 = new SimpleDateFormat(
					"yyyy-MM-dd'T'hh:mm:ss'Z'");

			java.util.Date pTime = new java.util.Date(nowbefore);
			String notBefore = dateFormat1.format(pTime);

			java.util.Date aTime = new java.util.Date(nowafter);
			String notOnOrAfter = dateFormat1.format(aTime);
			
			request.setAttribute("notBefore", notBefore);
			request.setAttribute("notOnOrAfter", notOnOrAfter);

			CoviMap resultList = new CoviMap();
			String status = "";
			String accessDate = "";
			// Sign XML containing user name with specified keys
			if (continueLogin) {
				// Generate SAML response contaning specified user name
				resultList = loginsvc.selectSamlUser(userId);
				status = resultList.get("status").toString();
				account = (CoviMap) resultList.get("account");
				//인증 성공 시
				if (status.equals("OK")) {
					if ("1".equals(PropertiesUtil.getSecurityProperties().getProperty("sso.type"))) {
						date = loginsvc.checkSSO("DAY");
						
						if(func.f_NullCheck(account.get("UR_Code").toString()).equals("")
								|| func.f_NullCheck(account.get("LogonPW").toString()).equals("")
								|| func.f_NullCheck(account.get("LanguageCode").toString()).equals("")){
							// ERROR 
							LOGGER.info("ERROR");
						}else{
							TokenHelper tokenHelper = new TokenHelper();
							
							String paramId = account.get("UR_Code").toString();
							String paramLang = account.get("LanguageCode").toString();
							
							key = tokenHelper.setTokenString(account.get("LogonID").toString(), date, account.get("LogonPW").toString(), account.get("LanguageCode").toString(), account.get("UR_Mail").toString(),account.get("DN_Code").toString(),account.get("UR_EmpNo").toString()
									, account.get("DN_Name").toString(), account.get("UR_Name").toString(), account.get("UR_Mail").toString(), account.get("GR_Code").toString() 
									, account.get("GR_Name").toString(), account.get("Attribute").toString(), account.get("DN_ID").toString()
									);
							
							accessDate = tokenHelper.selCookieDate(date,"");
							
							if(sessionDelChk > 0 ){
								session = request.getSession();
							}
							
							//라이선스 인증 정보 초기화
							LicenseHelper.resetUserLicenseCheck(account.get("UR_Code").toString(), account.get("DN_ID").toString());
							
							session.getServletContext().setAttribute(key, paramId );
							session.setAttribute("KEY", key);
							session.setAttribute("USERID", paramId);
							session.setAttribute("LOGIN", "Y");
							
							String urNm = account.get("UR_Name").toString();
							String urCode = account.get("UR_Code").toString();
							String urEmpNo = account.get("UR_EmpNo").toString();
							String urId = account.get("UR_ID").toString();
							
							account.put("UR_LoginIP",func.getRemoteIP(request));
							SessionCommonHelper.makeSession(paramId, account, isMobile);
							//SessionHelper.setSession("SSO", authType);
							//SessionHelper.setSession("USERPW",  account.get("LogonPW").toString());
							SessionHelper.setSession("lang", paramLang, isMobile);
							
							// 접속로그 생성
							LoggerHelper.connectLogger();
							
							String mainPage = "";
							if(ClientInfoHelper.isMobile(request)){
								mainPage= PropertiesUtil.getGlobalProperties().getProperty("MobileMainPage.path");
							}else{
								mainPage= PropertiesUtil.getGlobalProperties().getProperty("MainPage.path");
							}
							redirectURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + mainPage;

							String maxAge = "";
							
							maxAge = tokenHelper.selCookieDate(date,"1");
							//Token 저장.
							if(loginsvc.insertTokenHistory(key, account.get("LogonID").toString(), urNm, urCode, urEmpNo, maxAge, "O",assertionID)){

							}
							
							//세션 생성이후 생성.
							if(!"".equals(key) && !"".equals(accessDate)){
								
								cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());
								
							}
						}
						
					}else{
						key = session.getId();
					}
					
				}
				
			}
					
			
			if(func.f_NullCheck(redirectURL).equals("")){
				redirectURL =  request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/login.do";
			}
			
			response.sendRedirect(redirectURL);
			
		} else {
			LOGGER.info("## SAML Response - RETURN NULL isVerified FALSE ##");
			return;
		}
		
	}
	
	private String createSamlResponse(String authenticatedUser,
			String notBefore, String notOnOrAfter, String providerName,HttpServletRequest request,String id, String issuer,String uid, String destination, String assertionConsumerServiceURL) throws SamlException {
		
		String filepath =  request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+samlResponseTemplateFile);
		
		String samlResponse = Util.readFileContents(filepath);
		samlResponse = StringUtils.replace(samlResponse, "##USERNAME_STRING##",
				authenticatedUser);
		samlResponse = StringUtils.replace(samlResponse, "##RESPONSE_ID##",
				id);
		samlResponse = StringUtils.replace(samlResponse, "##ISSUE_INSTANT##",
				Util.getDateAndTime());
		samlResponse = StringUtils.replace(samlResponse, "##AUTHN_INSTANT##",
				Util.getDateAndTime());
		samlResponse = StringUtils.replace(samlResponse, "##NOT_BEFORE##",
				notBefore);
		samlResponse = StringUtils.replace(samlResponse, "##NOT_ON_OR_AFTER##",
				notOnOrAfter);
		samlResponse = StringUtils.replace(samlResponse, "##ASSERTION_ID##",
				uid);
		samlResponse = StringUtils.replace(samlResponse, "##PROVIDER_NAME##",
				providerName);
		samlResponse = StringUtils.replace(samlResponse, "##ISSUER##",
				issuer);
		samlResponse = StringUtils.replace(samlResponse, "##IDP_ENTITY##",
				PropertiesUtil.getSecurityProperties().getProperty("sendLogoutRedirectSSO.Url"));
		samlResponse = StringUtils.replace(samlResponse, "##Destination##",
				destination);
		samlResponse = StringUtils.replace(samlResponse, "##ACS_URL##",
				assertionConsumerServiceURL);
		
		return samlResponse;

	}
	
	/*
	 * Checks if the specified samlDate is formatted as per the SAML 2.0
	 * specifications, namely YYYY-MM-DDTHH:MM:SSZ.
	 */
	public static boolean validSamlDateFormat(String samlDate) {
		if (samlDate == null) {
			return false;
		}
		int indexT = samlDate.indexOf("T");
		int indexZ = samlDate.indexOf("Z");
		if (indexT != 10 || indexZ != 19) {
			return false;
		}
		String dateString = samlDate.substring(0, indexT);
		String timeString = samlDate.substring(indexT + 1, indexZ);
		SimpleDateFormat dayFormat = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
		ParsePosition pos = new ParsePosition(0);
		Date parsedDate = dayFormat.parse(dateString, pos);
		pos = new ParsePosition(0);
		Date parsedTime = timeFormat.parse(timeString, pos);
		if(parsedDate == null || parsedTime == null) {
			return false;
		}
		return true;
	}
	
	@RequestMapping(value = "/samlRedirect.do") 
	public ModelAndView samlRedirectPage(Locale locale, Model model,HttpServletRequest request) throws Exception {
		LOGGER.info("## samlRedirectPage ##");
		
		String returnURL = "core/login/redirect";
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		mav.addObject("returnURL",  request.getParameter("acr"));
		mav.addObject("SAMLResponse", request.getParameter("SAMLResponse"));
		mav.addObject("RelayState", request.getParameter("RelayState"));
		mav.addObject("loginState", "success");
		
		return mav;
	
	}
	
	// 개인환경설정 > 비밀번호 변경 > 변경
	@RequestMapping(value = "/updateUserPassword.do")
	public @ResponseBody CoviMap updateUserPassword(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		StringUtil func = new StringUtil();
		String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));		
		String result = "";
		
		
		try {
			CoviMap params = new CoviMap();
			
			String userID = SessionHelper.getSession("USERID");
			String mail = SessionHelper.getSession("UR_Mail");
			String logonID = SessionHelper.getSession("LogonID");
			
			params.put("userCode", userID);
			params.put("logonID", logonID);
			
			CoviMap jo = loginsvc.getUserLoginPassword(params).getJSONArray("map").getJSONObject(0);	// 개인환경설정 > 비밀번호 변경 > 변경
			//String encNowPassword = jo.getString("LogonPassword");
			//String birthDate = jo.getString("BirthDate");
			
			//String mobile = jo.getString("Mobile");
			
			String newPassword = request.getParameter("newPassword");
			String nowPassword = request.getParameter("nowPassword");
			
			//2019.06 패스워드 암호화 방식 RSA로 단일화
			if(func.f_NullCheck(cryptoType).equals("R")){
				newPassword = RSA.decryptRsa((PrivateKey) request.getSession().getAttribute("__CoviRPK__"), newPassword);
				nowPassword = RSA.decryptRsa((PrivateKey) request.getSession().getAttribute("__CoviRPK__"), nowPassword);
			}else if(func.f_NullCheck(cryptoType).equals("A")){
				AES aes = new AES("", "P");
				
				newPassword = aes.pb_decrypt(newPassword);
				nowPassword = aes.pb_decrypt(nowPassword);
			}
			
			
			params.put("loginPassword", newPassword);
			
			params.put("nowPassword", nowPassword);
			params.put("newPassword", newPassword);
			params.put("aeskey", aeskey);
			
			
			if(loginsvc.checkPasswordCnt(params) > 0 ){
				CoviMap validationResult = checkPasswordValidation(params);
				if(validationResult.getInt("result") == 1 ){
					result = loginsvc.updateUserPassword(params, request, response);
				}else{
					returnData.put("status", "NOT_ALLOW");
					returnData.put("message", validationResult.getString("message"));
					return returnData;
				}
			}else{
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_diffPassword")); //현재 비밀번호가 다릅니다.
				return returnData;
			}
			
			if(func.f_NullCheck(result).equals("")){				
				//CP 메일 패스워드 변경, 메일을 사용할 경우에만 업데이트 처리				
				if(orgSyncManageSvc.getIndiSyncTF() && SessionHelper.getSession("UR_UseMailConnect").equals("Y") && !"".equals(mail)) {
					CoviMap params2 = new CoviMap();				
					params2.put("UserID",userID);
					params2.put("Returnpass",newPassword);
					params2.put("MailAddress", mail);
					returnData.put("indistatus", orgSyncManageSvc.modifyPass(params2));
				}
				
				//WorkTalk 패스워드 변경
				if(orgSyncManageSvc.getTSSyncTF()) {
					CoviMap params2 = new CoviMap();				
					params2.put("LogonID",userID);
					params2.put("Returnpass",newPassword);
					returnData.put("tsresult", orgSyncManageSvc.resetuserpasswordTS(params2));					
				}
										
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", DicHelper.getDic("msg_Edited"));
			}else{
				returnData.put("status", Return.FAIL);
				returnData.put("message", result);
			}
		}
		catch (NullPointerException e) {
			LOGGER.error("", e);
			returnData.put("status", Return.FAIL);
			returnData.put("message",DicHelper.getDic("msg_changeFail"));
		}
		catch (Exception e) {
			LOGGER.error("", e);
			returnData.put("status", Return.FAIL);
			returnData.put("message",DicHelper.getDic("msg_changeFail"));
		}
		
		return returnData;
	}
	
	// 개인환경설정 > 기본정보 > 비밀번호확인
	@RequestMapping(value = "/checkPassword.do", method = RequestMethod.POST)
	public @ResponseBody CoviMap checkPassword(HttpServletRequest request, HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
		
		try {
			CoviMap params = new CoviMap();
			String userID = SessionHelper.getSession("USERID");
			params.put("userCode", userID);
			String nowPassword = request.getParameter("password");
		
			nowPassword = RSA.decryptRsa((PrivateKey) request.getSession().getAttribute("__CoviRPK__"), nowPassword);
			
			params.put("nowPassword", nowPassword);
			params.put("aeskey", aeskey);
			
			
			if(loginsvc.checkPasswordCnt(params) > 0 ){
				returnData.put("result", "ok");
				returnData.put("status", Return.SUCCESS);
				returnData.put("message", DicHelper.getDic("msg_confirmed"));
			}
			else{
				returnData.put("status", Return.FAIL);
				returnData.put("message", DicHelper.getDic("msg_diffPassword"));
			}
		}
		catch (NullPointerException e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		catch (Exception e) {
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnData;
	}
	
	public CoviMap checkPasswordValidation(CoviMap params) throws Exception
	{

		CoviMap resultObj = new CoviMap();
		resultObj.put("result", 0);
		
		String patternStr = null;
		String patternMsg = "";
		String nowPassword = params.getString("nowPassword");
		String newPassword = params.getString("newPassword");
		String logonID = params.getString("logonID");
		String pwdCheckCount = RedisDataUtil.getBaseConfig("PasswordCheckCount");
		
		params.put("domainID", SessionHelper.getSession("DN_ID"));		
		params.put("pwdCheckCount", pwdCheckCount.equals("") ? "0" : Integer.parseInt(pwdCheckCount));
		
		CoviMap policyConfig = loginsvc.selectDomainPasswordPolicy(params);
		String SpecialCharacterPolicy = policyConfig.getString("SpecialCharacterPolicy");
		
		if(policyConfig.getInt("IsUseComplexity") == 1) {
			patternStr = "^.*(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d].*$";
			patternMsg = String.format(DicHelper.getDic("msg_ChangePasswordDSCR08").replace("{0}","%d"), policyConfig.getInt("MinimumLength"));
		}else if(policyConfig.getInt("IsUseComplexity") == 2) {
			patternStr = "^.*(?=.*\\d)(?=.*[a-zA-Z])(?=.*[" + SpecialCharacterPolicy + "]).*$";
			patternMsg = String.format(DicHelper.getDic("msg_ChangePasswordDSCR07").replace("{0}","%d"), policyConfig.getInt("MinimumLength"));
			patternMsg +=  "\n" + String.format(DicHelper.getDic("msg_allowSpecialChar").replace("{0}","%s"), SpecialCharacterPolicy);
		}else if(policyConfig.getInt("IsUseComplexity") == 3) {
			patternStr = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[" + SpecialCharacterPolicy + "])[A-Za-z\\d" + SpecialCharacterPolicy + "].*$";
			patternMsg = String.format(DicHelper.getDic("msg_ChangePasswordDSCR06").replace("{0}","%d"), policyConfig.getInt("MinimumLength"));
			patternMsg +=  "\n" + String.format(DicHelper.getDic("msg_allowSpecialChar").replace("{0}","%s"), SpecialCharacterPolicy);
		}
		
		
		if(nowPassword.isEmpty()) {
			resultObj.put("message", DicHelper.getDic("msg_PasswordChange_03")); //현재 비밀번호를 입력하여 주십시오.
		}else if(newPassword.isEmpty()) {
			resultObj.put("message", DicHelper.getDic("msg_PasswordChange_04")); //새 비밀번호를 입력하여 주십시오.
		}else if(nowPassword.equals(newPassword)) {
			resultObj.put("message", DicHelper.getDic("msg_PasswordChange_19")); //사용중인 패스워드와 변경하실 패스워드가 같습니다.
		}else if(newPassword.contains(logonID)) {
			resultObj.put("message", DicHelper.getDic("msg_CheckLogonID")); //로그인 아이디는 암호에 포함될 수 없습니다.
		}else if(newPassword.length() < policyConfig.getInt("MinimumLength")) {
			resultObj.put("message", String.format(DicHelper.getDic("msg_ChangePasswordDSCR09").replace("{0}","%d"), policyConfig.getInt("MinimumLength")));
		}else if(patternStr != null && !Pattern.matches(patternStr, newPassword)) {
			resultObj.put("message", patternMsg);
		}else if(Pattern.compile("(.)\\1{2,}").matcher(newPassword).find()) {
			resultObj.put("message", DicHelper.getDic("msg_ChangePasswordDSCR05").replace("{0}","%d"));
		}else if(RedisDataUtil.getBaseConfig("IsPasswordHistory").equals("Y")) {
			if(!passwordLogCheck(params)) {
				resultObj.put("message", DicHelper.getDic("msg_PasswordChange_20").replace("{0}",pwdCheckCount)); //이미 사용했던 비밀번호 입니다. 다른 비밀번호를 선택해주세요.
			}else {
				resultObj.put("result", 1);
			}
		}else {
			resultObj.put("result", 1);
		}
		
		return resultObj;
	}	
	
	public boolean passwordLogCheck(CoviMap params) throws Exception {
		return !(loginsvc.checkPasswordLogCnt(params) > 0);
	}
	
	// 개인환경설정 > 기본정보 > 비밀번호확인
	@RequestMapping(value = "/passwordCheck.do")
	public ModelAndView passwordCheck(HttpServletRequest request, HttpServletResponse response) throws Exception {
		//StringUtil func = new StringUtil();
		CoviMap params = new CoviMap();
		
		String returnURL = "";
		
		returnURL = "user/privacy/PasswordCheck" ;
		//2019.06 패스워드 암호화 방식 변경 무조건 R을 타도록
		//String cryptoType = "R";//PropertiesUtil.getSecurityProperties().getProperty("cryptoType");
		
		RSA rsa = RSA.getEncKey();
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		//JSONObject resultDataList = new CoviMap();
		
		mav.addObject("cryptoType", cryptoType);
		mav.addObject("publicKeyModulus", rsa.getPublicKeyModulus());
		mav.addObject("publicKeyExponent", rsa.getPublicKeyExponent());
		
		request.getSession().setAttribute("__CoviRPK__", rsa.getPrivateKey());
		
		return mav;
	}
		
	// 개인환경설정 > 기본정보 > 비밀번호변경
	@RequestMapping(value = "/passwordChange.do")
	public ModelAndView passwordChange(HttpServletRequest request, HttpServletResponse response) throws Exception {
		StringUtil func = new StringUtil();
		CoviMap params = new CoviMap();
		
		String returnURL = "";
		
		returnURL = "privacy".toLowerCase() + "/" + "PasswordChange" + "." + "user" + ".content" ;
	
		//2019.06 패스워드 암호화 방식 변경 무조건 R을 타도록
		//String cryptoType = "R";//PropertiesUtil.getSecurityProperties().getProperty("cryptoType");
		
		RSA rsa = RSA.getEncKey();
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		//JSONObject resultDataList = new CoviMap();
		
		params.put("domainID", SessionHelper.getSession("DN_ID"));
		
		params = loginsvc.selectDomainPasswordPolicy(params);
		
		mav.addObject("MinimumLength", params.get("MinimumLength"));
		mav.addObject("IsUseComplexity", params.get("IsUseComplexity"));
		mav.addObject("SpecialCharacterPolicy", params.get("SpecialCharacterPolicy"));
		mav.addObject("NPA", request.getParameter("NPA"));
		mav.addObject("cryptoType", cryptoType);
		if(func.f_NullCheck(cryptoType).equals("R")){
			mav.addObject("publicKeyModulus", rsa.getPublicKeyModulus());
			mav.addObject("publicKeyExponent", rsa.getPublicKeyExponent());
			
			request.getSession().setAttribute("__CoviRPK__", rsa.getPrivateKey());
			return mav;
		}
				
		return mav;
	}
	
	
	private Map<String, String> splitQuery(String url) throws UnsupportedEncodingException {
	    Map<String, String> query_pairs = new LinkedHashMap<String, String>();
	    String[] pairs = url.split("&");
	    for (String pair : pairs) {
	        int idx = pair.indexOf("=");
	        query_pairs.put(URLDecoder.decode(pair.substring(0, idx), "UTF-8"), URLDecoder.decode(pair.substring(idx + 1), "UTF-8"));
	    }
	    return query_pairs;
	}
	
	
	@RequestMapping(value = "/samlLogin.do")
	public ModelAndView samlLogin(Locale locale, Model model,HttpServletRequest request) throws Exception {
		//StringUtil func = new StringUtil();
		
		String returnURL = "core/login/samllogin";
		
		ModelAndView mav = new ModelAndView(returnURL);
		mav.addObject("samlRequest", request.getParameter("SAMLRequest"));
		mav.addObject("relayState", request.getParameter("RelayState"));
		
		mav.addObject("cryptoType", cryptoType);

		return mav;
	}
	
	@RequestMapping(value = "/samlLoginbasechk.do")
	public @ResponseBody CoviMap samlLoginbasechk(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		TokenHelper tokenHelper = new TokenHelper();
		CookiesUtil cUtil = new CookiesUtil();
		StringUtil func = new StringUtil();
		
		String id = request.getParameter("id");
		String pw = request.getParameter("pw");
		
		String message = "";
		String bodyText = "";
		
		if(func.f_NullCheck(cryptoType).equals("R")){
			pw = RSA.decryptRsa((PrivateKey) request.getSession().getAttribute("__CoviRPK__"), pw);
		}else if(func.f_NullCheck(cryptoType).equals("A")){
			AES aes = new AES("", "P");
			
			pw = aes.pb_decrypt(pw);
		}
		
		String lang = request.getParameter("language");
		
		int lockCount = loginsvc.selectAccountLock(id);
		
		if(lockCount > 0 ){
			returnList.put("result","lock");
			LoggerHelper.connectFalseLogger(id,"LOCK");
		}else{
			String pId = loginsvc.selectUserAuthetication(id, pw) ;
				
			if(!func.f_NullCheck(pId).equals("") ){	
				String date = loginsvc.checkSSO("DAY");
				String dn = loginsvc.selectUserMailAddress(id);
				
				resultList = loginsvc.checkAuthetication("SSO", id, pw, lang);
				
				CoviMap account = (CoviMap) resultList.get("account");
				
				String key = tokenHelper.setTokenString(id,date,pw,lang,dn,account.get("DN_Code").toString(),account.get("UR_EmpNo").toString(),account.get("DN_Name").toString(),account.get("UR_Name").toString(),account.get("UR_Mail").toString(),account.get("GR_Code").toString(),account.get("GR_Name").toString(),account.get("Attribute").toString(),account.get("DN_ID").toString());
				
				String accessDate = tokenHelper.selCookieDate(date,"");
				if(!"".equals(key) && !"".equals(accessDate)){
					returnList.put("key", key);
					returnList.put("access_date", accessDate);
					returnList.put("result","ok");
					
					cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());
					
					if(loginsvc.deleteUserFailCount(id)){
						loginsvc.updateUserLock(id, "N");
					}
				}else{
					returnList.put("result","fail");
					LoggerHelper.connectFalseLogger(id,"LOGIN");
				}
					
			}else{
				if(loginsvc.updateUserFailCount(id)){
					CoviMap failMap = loginsvc.selectUserFailCount(id);
					int failCount = failMap.getInt("failCount");
					String systemFailCount =  PropertiesUtil.getSecurityProperties().getProperty("privacy.secure.login.count");
					if (!RedisDataUtil.getBaseConfig("loginCount", failMap.getString("DN_ID")).equals("")){
						failCount = Integer.parseInt(RedisDataUtil.getBaseConfig("loginCount", failMap.getString("DN_ID")));
					}
					
					if(failCount >= Integer.parseInt(systemFailCount)){
						resultList = loginsvc.checkAuthetication("SSO", id, pw, lang);
						
						CoviMap account = (CoviMap) resultList.get("account");
						
						loginsvc.updateUserLock(id, "Y");
						
						message = id+" "+DicHelper.getDic("msg_accountLockInfo",lang);
						
						bodyText = lockHtmlText(id,failMap.getString("DN_ID"),lang);
						
						if(!func.f_NullCheck(account.get("ExternalMailAddress").toString()).equals("")){
							LoggerHelper.auditLogger(id, "S", "SMTP", PropertiesUtil.getExtensionProperties().getProperty("mail.mailUrl"), bodyText, "ExternalMailAddress");
							MessageHelper.getInstance().sendSMTP(DicHelper.getDic("lbl_admin",lang), PropertiesUtil.getGlobalProperties().getProperty("SenderErrorMail"), account.get("ExternalMailAddress").toString(), id+" "+DicHelper.getDic("msg_accountLockGuidInfo",lang), bodyText, true); 
						}
						
						if(!func.f_NullCheck(account.get("UR_Mail").toString()).equals("")){
							LoggerHelper.auditLogger(id, "S", "SMTP", PropertiesUtil.getExtensionProperties().getProperty("mail.mailUrl"), bodyText, "MailAddress");
							MessageHelper.getInstance().sendSMTP(DicHelper.getDic("lbl_admin",lang), PropertiesUtil.getGlobalProperties().getProperty("SenderErrorMail"), account.get("UR_Mail").toString(), id+" "+DicHelper.getDic("msg_accountLockGuidInfo",lang), bodyText, true);
						}
						
						String badgeCount = messageManageSvc.selectBadgeCount(id);		
						MessageHelper.getInstance().sendPushByUserID(id, message, badgeCount);
						
						returnList.put("result","lock");
					}else{
						returnList.put("result","fail");	
					}
				}else{
					returnList.put("result","fail");
				}
				
				LoggerHelper.connectFalseLogger(id,"LOGIN");
			}
		}
		
		return returnList;
	
	}
	
	@RequestMapping(value = "/samlLoginchk.do")
	public ModelAndView samlLoginchk(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		LOGGER.debug("/samlLoginchk.do");
		CookiesUtil cUtil = new CookiesUtil();
		StringUtil func = new StringUtil();
		SsoSamlCon ssoSamlCon = new SsoSamlCon();
		CoviMap resultList = new CoviMap();
		
		HttpSession session = request.getSession();
		
		String returnURL = "";
		String loginState = "success";
		String status = "";
		String key = "";
		String maxAge = "";
		
		String urNm = "";
		String urCode = "";
		String urEmpNo = "";
		String urId = "";
		String samlID= "";
		
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		try{
			
			//loginService 인증 처리 로직 시작
			String paramId = request.getParameter("id");
			String paramPwd = "";
			String paramLang = request.getParameter("language");
			String authType = "SSO";
		
			//인증체크 로직 수행
			resultList = loginsvc.checkAuthetication(authType, paramId, paramPwd, paramLang);
			// 웹페이지에서받은 아이디,패스워드 일치시 admin 세션key 생성
			status = resultList.get("status").toString();
			CoviMap account = (CoviMap) resultList.get("account");
			
			//인증 성공 시
			if (status.equals("OK")) {
				key = cUtil.getCooiesValue(request);
				
				TokenHelper tokenHelper = new TokenHelper();
				TokenParserHelper tokenParserHelper = new TokenParserHelper();
				String decodKey = tokenHelper.getDecryptToken(key);
				if(!tokenParserHelper.parserJsonVerification(decodKey,account.get("LogonID").toString())){

					returnURL = "redirect:"+request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/logout.do";
					
					ModelAndView mav = new ModelAndView(returnURL);
					mav.addObject("loginState", "fail");

					return mav;
					
				}else{
					maxAge = tokenParserHelper.parserJsonMaxAge(decodKey);
					
				}
				
				//라이선스 인증 정보 초기화
				LicenseHelper.resetUserLicenseCheck(account.get("UR_Code").toString(), account.get("DN_ID").toString());
				
				//세션 생성
				session.getServletContext().setAttribute(key, account.get("UR_ID").toString());
				session.setAttribute("KEY", key);
				session.setAttribute("USERID", account.get("UR_ID").toString());
				session.setAttribute("LOGIN", "Y");
				
				urNm = account.get("UR_Name").toString();
				urCode = account.get("UR_Code").toString();
				urEmpNo = account.get("UR_EmpNo").toString();
				urId = account.get("UR_ID").toString();
				samlID = account.get("LogonID").toString();
				
				account.put("UR_LoginIP",func.getRemoteIP(request));
				SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account, isMobile);
				//SessionHelper.setSession("SSO", authType);
				//SessionHelper.setSession("USERPW",  request.getParameter("password"));
				SessionHelper.setSession("lang", paramLang, isMobile);
					
				// 접속로그 생성
				LoggerHelper.connectLogger();
				
				if(loginsvc.insertTokenHistory(key, samlID, urNm, urCode, urEmpNo, maxAge, "I", "")){
					returnURL = "redirect:"+StringUtil.replaceNull(PropertiesUtil.getGlobalProperties().getProperty("covisignone2.saml.url"))
							+ "?RelayState="+StringUtil.replaceNull(request.getParameter("RelayState"))
							+ "&SAMLRequest="+StringUtil.replaceNull(request.getParameter("SamlRequest")).replaceAll(" ", "+");
				}
				
				//최종 로그인 날짜와 비밀번호 변경 날짜 비교하여 계정 LOCK 또는 비밀번호 변경 페이지로 이동
				CoviMap params = new CoviMap();
				params.put("domainID", account.get("DN_ID"));
				
				params = loginsvc.selectDomainPasswordPolicy(params);
				
				String strLastLoginDate = account.get("LATEST_LOGIN_DATE").toString();
				String strPwChangeDate = account.get("PASSWORD_CHANGE_DATE").toString();
				
				SimpleDateFormat format = new SimpleDateFormat ("yyyy-MM-dd");
				String strCurrentDate = ComUtils.TransServerTime(ComUtils.GetLocalCurrentDate("yyyy-MM-dd HH:mm:ss"),"yyyy-MM-dd");
				Date currentDate = format.parse(strCurrentDate);
				
				Calendar calLastLoginDate = new GregorianCalendar();
				calLastLoginDate.setTime(format.parse(strLastLoginDate));
				calLastLoginDate.add(Calendar.DAY_OF_YEAR, Integer.parseInt(PropertiesUtil.getSecurityProperties().getProperty("login.maximum.unavailable.access.dates")));
				
				Calendar calPwChangeDate = new GregorianCalendar();
				calPwChangeDate.setTime(format.parse(strPwChangeDate));
				calPwChangeDate.add(Calendar.DAY_OF_YEAR,  Integer.parseInt(params.get("MaxChangeDate").toString()));

				Date lastLoginDate = new Date(calLastLoginDate.getTimeInMillis());
				Date pwChangeDate = new Date(calPwChangeDate.getTimeInMillis());
				
				long diffLastLogin = (lastLoginDate.getTime() - currentDate.getTime()) / (24 * 60 * 60 * 1000);
				long diffPwChange = (pwChangeDate.getTime() - currentDate.getTime()) / (24 * 60 * 60 * 1000);
				
				if(diffLastLogin < 0 || diffPwChange < 0){
					loginsvc.updateUserLock(paramId, "Y");
					returnURL = "redirect:"+request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()+"/covicore/logout.do";
				}
			
			} else {
				//접속실패로그
				LoggerHelper.connectFalseLogger(paramId,"LOGIN");
				returnURL = "login";
				loginState = "fail";
			}
			
		}
		catch (NullPointerException e){
			throw e;
		}
		catch (Exception e){
			throw e;
		}
		
		ModelAndView mav = new ModelAndView(returnURL);
		
		return mav;
	}
	
	
	// 개인환경설정 > 기본정보 > 비밀번호변경
	@RequestMapping(value = "/passwordCompulsionChange.do")
	public ModelAndView passwordCompulsionChange(HttpServletRequest request, HttpServletResponse response) throws Exception {
			StringUtil func = new StringUtil();
			CoviMap params = new CoviMap();
			CommonUtil commonUtil = new CommonUtil();
			String returnURL = "";

			returnURL = "passwordCompulsionChange" ;

			//2019.06 패스워드 암호화 방식 변경 무조건 R을 타도록
			String cryptoType = "R";//PropertiesUtil.getSecurityProperties().getProperty("cryptoType");
			
			RSA rsa = RSA.getEncKey();
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			ModelAndView mav = new ModelAndView(returnURL);
			
			params.put("domainID", userDataObj.getString("DN_ID"));
			
			params = loginsvc.selectDomainPasswordPolicy(params);
			
			/*String authType = PropertiesUtil.getSecurityProperties().getProperty("admin.auth.type");
			
			String adminAuth = "N";
			String adminSession = userDataObj.getString("isAdmin");
			
			if(func.f_NullCheck(authType).equals("I") && func.f_NullCheck(adminSession).equals("Y")){
				String partIPAddress = convertIpString(func.getRemoteIP(request));
				
				if(func.f_NullCheck(partIPAddress).equals("127000000001")){
					params.put("partIPAddress", "127001");
				}else{
					params.put("partIPAddress", partIPAddress);
				}
				
				if(authSvc.selectTwoFactorIpCheck(params,"A") == 0){
					adminAuth = "N";
				}else{
					adminAuth = "Y";
				}
			}else if(func.f_NullCheck(adminSession).equals("Y")){
				adminAuth = "Y";
			}
			*/
			CoviMap myInfoData = commonUtil.makeMyInfoData(userDataObj);	//MyInfo 사이드 메뉴 전용
			
			mav.addObject("myInfoData", myInfoData);
			
			mav.addObject("MinimumLength", params.get("MinimumLength"));
			mav.addObject("IsUseComplexity", params.get("IsUseComplexity"));
			mav.addObject("SpecialCharacterPolicy", params.get("SpecialCharacterPolicy"));
			mav.addObject("lang", userDataObj.getString("lang"));
			mav.addObject("cryptoType", cryptoType);
			/*if(func.f_NullCheck(cryptoType).equals("R")){*/
				mav.addObject("publicKeyModulus", rsa.getPublicKeyModulus());
				mav.addObject("publicKeyExponent", rsa.getPublicKeyExponent());
				
				request.getSession().setAttribute("__CoviRPK__", rsa.getPrivateKey());
				/*return mav;
			}*/
			
		return mav;
	}
	
	public String lockHtmlText(String id) {
		return lockHtmlText(id, "0");
	}
	
	public String lockHtmlText(String id, String domainID) {
		return lockHtmlText(id, "0", "ko");
	}
	
	public String lockHtmlText(String id, String domainID, String lang){
		String bodyText = "";
		
			bodyText = "<html>";
			bodyText += "<table width='100%' bgcolor='#ffffff' cellpadding='0' cellspacing='0' style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.2em; color:#444; margin:0; padding:0;\">";
				bodyText += "<tbody>";
					bodyText += "<tr>";
						bodyText += "<td valign='middle' height='40' style='padding-left:26px;' bgcolor='#2b2e34'>";
							bodyText += "<table width='90%' height='50' cellpadding='0' cellspacing='0' style='background:url(mail_top.gif) no-repeat top left;'>";
								bodyText += "<tbody>";
									bodyText += "<tr>";
										bodyText += "<td style=\"font:bold 16px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">";
										bodyText += "System";
										bodyText += "</td>";
									bodyText += "</tr>";
								bodyText += "</tbody>";
							bodyText += "</table>";
						bodyText += "</td>";
					bodyText += "</tr>";	
					bodyText += "<tr>";
						bodyText += "<td bgcolor='#ffffff' style='padding:20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4;'>";
							bodyText += "<table width='100%' cellpadding='0' cellspacing='0'>";
								bodyText += "<tbody>";
									bodyText += "<tr>";
										bodyText += "<td valign='bottom' bgcolor='#f9f9f9' style='padding:17px 0 5px 20px;'>";
											bodyText += "<span style=\"font:bold 14px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.5em; color:#444;\">["+DicHelper.getDic("msg_accountLockGuidInfo",lang)+"]</span>";
										bodyText += "</td>";
									bodyText += "</tr>";
									bodyText += "<tr>";
										bodyText += "<td valign='bottom' bgcolor='#f9f9f9' style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.5em; padding:0 0 15px 20px; color:#444;\">";
											bodyText += id+" "+DicHelper.getDic("msg_accountLockInfo",lang)+"<br>";
											bodyText += DicHelper.getDic("msg_passwordReissuance",lang);
										bodyText += "</td>";
									bodyText += "</tr>";
								bodyText += "</tbody>";
							bodyText += "</table>";
						bodyText += "</td>";
					bodyText += "</tr>";
					bodyText += "<tr>";
						bodyText += "<td style='padding:0 0 20px 20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4;'>";
							bodyText += "<div style='border-bottom:2px solid #f9f9f9; margin-right:20px;'>";
								bodyText += "<div style=\"font:normal 15px dotum,'돋움', Apple-Gothic,sans-serif;border-bottom:1px solid #c2c2c2; height:30px; line-height:30px;\">";
									bodyText += "<strong></strong>";
								bodyText += "</div>";
							bodyText += "</div>";
						bodyText += "</td>";
					bodyText += "</tr>";	
					bodyText += "<tr style='height:130px;'>";
						bodyText += "<td style='padding:0 20px 20px 20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4;'>";
						bodyText += "</td>";
					bodyText += "</tr>";
					bodyText += "<tr>";
						bodyText += "<td align='center' valign='middle' height='109' bgcolor='' style='border:1px solid #d4d4d4; border-top:0;'>";
							bodyText += "<table cellpadding='0' cellspacing='0'>";
								bodyText += "<tbody>";
									bodyText += "<tr>";
										bodyText += "<td align='center' height='32'>";
											bodyText += "<span style=\"font:normal 12px dotum,'돋움'; color:#444444;\">"+(DicHelper.getDic("msg_PLZLogOnSmart",lang)).replace("{0}", RedisDataUtil.getBaseConfig("ApplicationName"))+" to check)</span>";
										bodyText += "</td>";
									bodyText += "</tr>";
								bodyText += "</tbody>";
							bodyText += "</table>";
							bodyText += "<table width='140' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;'>";
								bodyText += "<tbody>";
									bodyText += "<tr>";
										bodyText += "<td align='center' height='36' style='cursor:pointer;'>";
											bodyText += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+MessageHelper.replaceLinkUrl(domainID, PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"),false)+"'>";
												bodyText += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
													bodyText += "<strong>"+DicHelper.getDic("btn_GWShortcut",lang)+"</strong>";
												bodyText += "</span>";
											bodyText += "</a>";
										bodyText += "</td>";
									bodyText += "</tr>";	
								bodyText += "</tbody>";	
							bodyText += "</table>";			
						bodyText += "</td>";					
					bodyText += "</tr>";			
					bodyText += "<tr>";
						bodyText += "<td align='center' valign='middle' height='25' style=\"font:normal 12px dotum,'돋움', Apple-Gothic, 맑은 고딕, Malgun Gothic,sans-serif; color:#a1a1a1;\">";
							bodyText += "Copyright <span style='font-weight:bold; color:#222222;'>"+PropertiesUtil.getGlobalProperties().getProperty("copyright")+"</span> Corp. All Rights Reserved.";
						bodyText += "</td>";
					bodyText += "</tr>";	
				bodyText += "</tbody>";
			bodyText += "</table>";
		bodyText += "</html>";
		
		return bodyText;
	}
	public String duplicationHtmlText(String id) {
		return duplicationHtmlText(id, "0");
	}
	
	public String duplicationHtmlText(String id, String domainID) {
		return duplicationHtmlText(id, "0", "ko");
	}
	
	public String duplicationHtmlText(String id, String domainID, String lang){
		String bodyText = "";
		
		bodyText = "<html>";
		bodyText += "<table width='100%' bgcolor='#ffffff' cellpadding='0' cellspacing='0' style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.2em; color:#444; margin:0; padding:0;\">";
		bodyText += "<tbody>";
		bodyText += "<tr>";
		bodyText += "<td valign='middle' height='40' style='padding-left:26px;' bgcolor='#2b2e34'>";
		bodyText += "<table width='90%' height='50' cellpadding='0' cellspacing='0' style='background:url(mail_top.gif) no-repeat top left;'>";
		bodyText += "<tbody>";
		bodyText += "<tr>";
		bodyText += "<td style=\"font:bold 16px 맑은 고딕, Malgun Gothic, dotum,'돋움', Apple-Gothic, sans-serif; color:#fff;\">";
		bodyText += "System";
		bodyText += "</td>";
		bodyText += "</tr>";
		bodyText += "</tbody>";
		bodyText += "</table>";
		bodyText += "</td>";
		bodyText += "</tr>";	
		bodyText += "<tr>";
		bodyText += "<td bgcolor='#ffffff' style='padding:20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4;'>";
		bodyText += "<table width='100%' cellpadding='0' cellspacing='0'>";
		bodyText += "<tbody>";
		bodyText += "<tr>";
		bodyText += "<td valign='bottom' bgcolor='#f9f9f9' style='padding:17px 0 5px 20px;'>";
		bodyText += "<span style=\"font:bold 14px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.5em; color:#444;\">["+DicHelper.getDic("msg_simultaneousAccessGuidInfo",lang)+"]</span>";
		bodyText += "</td>";
		bodyText += "</tr>";
		bodyText += "<tr>";
		bodyText += "<td valign='bottom' bgcolor='#f9f9f9' style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; line-height:1.5em; padding:0 0 15px 20px; color:#444;\">";
		bodyText += id+" "+DicHelper.getDic("msg_simultaneousAccess",lang)+"<br>";
		bodyText += "</td>";
		bodyText += "</tr>";
		bodyText += "</tbody>";
		bodyText += "</table>";
		bodyText += "</td>";
		bodyText += "</tr>";
		bodyText += "<tr>";
		bodyText += "<td style='padding:0 0 20px 20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4;'>";
		bodyText += "<div style='border-bottom:2px solid #f9f9f9; margin-right:20px;'>";
		bodyText += "<div style=\"font:normal 15px dotum,'돋움', Apple-Gothic,sans-serif;border-bottom:1px solid #c2c2c2; height:30px; line-height:30px;\">";
		bodyText += "<strong></strong>";
		bodyText += "</div>";
		bodyText += "</div>";
		bodyText += "</td>";
		bodyText += "</tr>";	
		bodyText += "<tr style='height:130px;'>";
		bodyText += "<td style='padding:0 20px 20px 20px; border-left:1px solid #d4d4d4; border-right:1px solid #d4d4d4;'>";
		bodyText += "</td>";
		bodyText += "</tr>";
		bodyText += "<tr>";
		bodyText += "<td align='center' valign='middle' height='109' bgcolor='' style='border:1px solid #d4d4d4; border-top:0;'>";
		bodyText += "<table cellpadding='0' cellspacing='0'>";
		bodyText += "<tbody>";
		bodyText += "<tr>";
		bodyText += "<td align='center' height='32'>";
		bodyText += "<span style=\"font:normal 12px dotum,'돋움'; color:#444444;\">"+(DicHelper.getDic("msg_PLZLogOnSmart",lang)).replace("{0}", RedisDataUtil.getBaseConfig("ApplicationName"))+"</span>";
		bodyText += "</td>";
		bodyText += "</tr>";
		bodyText += "</tbody>";
		bodyText += "</table>";
		bodyText += "<table width='140' cellpadding='0' cellspacing='0' bgcolor='#2f91e3' style='cursor:pointer;'>";
		bodyText += "<tbody>";
		bodyText += "<tr>";
		bodyText += "<td align='center' height='36' style='cursor:pointer;'>";
		bodyText += "<a style='display:block; cursor:pointer; text-decoration:none;' target='_blank' href='"+MessageHelper.replaceLinkUrl(domainID, PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"),false)+"'>";
		bodyText += "<span style=\"font:normal 12px dotum,'돋움', Apple-Gothic,sans-serif; text-decoration:none; color:#ffffff;\">";
		bodyText += "<strong>"+DicHelper.getDic("btn_GWShortcut",lang)+"</strong>";
		bodyText += "</span>";
		bodyText += "</a>";
		bodyText += "</td>";
		bodyText += "</tr>";	
		bodyText += "</tbody>";	
		bodyText += "</table>";			
		bodyText += "</td>";					
		bodyText += "</tr>";			
		bodyText += "<tr>";
		bodyText += "<td align='center' valign='middle' height='25' style=\"font:normal 12px dotum,'돋움', Apple-Gothic, 맑은 고딕, Malgun Gothic,sans-serif; color:#a1a1a1;\">";
		bodyText += "Copyright <span style='font-weight:bold; color:#222222;'>"+PropertiesUtil.getGlobalProperties().getProperty("copyright")+"</span> Corp. All Rights Reserved.";
		bodyText += "</td>";
		bodyText += "</tr>";	
		bodyText += "</tbody>";
		bodyText += "</table>";
		bodyText += "</html>";
		
		return bodyText;
	}
	
	@RequestMapping(value = "/loginTwoFactorChk.do")
	public @ResponseBody CoviMap loginTwoFactorChk(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		TokenHelper tokenHelper = new TokenHelper();
		CookiesUtil cUtil = new CookiesUtil();
		StringUtil func = new StringUtil();
		
		String id = request.getParameter("id");
		String message = "";
		String bodyText = "";
		int otpUseTime = Integer.parseInt(request.getParameter("otpUseTime"));
		
		CoviMap otpParams = new CoviMap();
		otpParams.put("id",id);
		otpParams.put("otpNumber",request.getParameter("otp"));
		otpParams.put("logType", (request.getParameter("logType") == null) ? "login" : request.getParameter("logType"));
		otpParams.put("otpUseTime", StringUtil.replaceNull(RedisDataUtil.getBaseConfig("OTPUseTime"), "10"));
		if(loginsvc.selectOTPCheck(otpParams) == 0 ){
			int FailCount = 0;
			if(otpUseTime != 0) {
				FailCount = loginsvc.selectOTPFailCount(otpParams);
			}
			String baseFailCount = StringUtil.replaceNull(RedisDataUtil.getBaseConfig("OTPFailCount"), "5");
			returnList.put("baseFailCount", Integer.parseInt(baseFailCount));
			returnList.put("failcount", FailCount);
			returnList.put("result","fail");
			return returnList;
		}
		
		String pw = request.getParameter("pw");

		if(func.f_NullCheck(cryptoType).equals("R")){
			pw = RSA.decryptRsa((PrivateKey) request.getSession().getAttribute("__CoviRPK__"), pw);
		}else if(func.f_NullCheck(cryptoType).equals("A")){
			AES aes = new AES("", "P");
			
			pw = aes.pb_decrypt(pw);
		}
		String lang = request.getParameter("language");
		
		String date = loginsvc.checkSSO("DAY");
		String dn = loginsvc.selectUserMailAddress(id);
		
		resultList = loginsvc.checkAuthetication("SSO", id, "", lang);
		
		CoviMap account = (CoviMap) resultList.get("account");
		
		CoviMap params = new CoviMap();
		params.put("domainID", account.get("DN_ID"));
		
		params = loginsvc.selectDomainPasswordPolicy(params);
		
		String key = tokenHelper.setTokenString(id,date,pw,lang,dn,account.get("DN_Code").toString(),account.get("UR_EmpNo").toString()
				, account.get("DN_Name").toString(), account.get("UR_Name").toString(), account.get("UR_Mail").toString(), account.get("GR_Code").toString() 
				, account.get("GR_Name").toString(), account.get("Attribute").toString(), account.get("DN_ID").toString()
				);
		
		String accessDate = tokenHelper.selCookieDate(date,"");
		if(!"".equals(key) && !"".equals(accessDate)){
			returnList.put("key", key);
			returnList.put("access_date", accessDate);
			returnList.put("result","ok");
				
			cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());
				
			if(loginsvc.deleteUserFailCount(id)){
				loginsvc.updateUserLock(id, "N");
			}
				
		}else{
			returnList.put("result","fail");
			LoggerHelper.connectFalseLogger(id,"LOGIN");
		}
				
		
		return returnList;
	
	}
	
	@RequestMapping(value = "/loginDuplicationChk.do")
	public @ResponseBody CoviMap loginDuplicationChk(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		CoviMap returnList = new CoviMap();
		CoviMap resultList = new CoviMap();
		TokenHelper tokenHelper = new TokenHelper();
		CookiesUtil cUtil = new CookiesUtil();
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		StringUtil func = new StringUtil();
		
		String id = request.getParameter("id");
		String pw = request.getParameter("pw");
		String message = "";
		String bodyText = "";
		
		if(func.f_NullCheck(cryptoType).equals("R")){
			pw = RSA.decryptRsa((PrivateKey) request.getSession().getAttribute("__CoviRPK__"), pw);
		}else if(func.f_NullCheck(cryptoType).equals("A")){
			AES aes = new AES("", "P");
			
			pw = aes.pb_decrypt(pw);
		}
		
		String lang = request.getParameter("language");
		
		String date = loginsvc.checkSSO("DAY");
		String dn = loginsvc.selectUserMailAddress(id);
		
		resultList = loginsvc.checkAuthetication("SSO", id, "", lang);
		
		CoviMap account = (CoviMap) resultList.get("account");
		
		//기존 사용자 연결 끊기
		String key_psm = account.get("UR_ID").toString() + "_PSM";
		if(instance.get(key_psm) != null){
			CoviMap obj = CoviMap.fromObject(instance.get(key_psm));
			
			if(obj.containsKey("TokenKey")){;
				String removedKey = obj.getString("TokenKey");
				
				instance.remove(removedKey);
			}
		}
		
		String key = tokenHelper.setTokenString(id,date,pw,lang,dn,account.get("DN_Code").toString(),account.get("UR_EmpNo").toString()
				, account.get("DN_Name").toString(), account.get("UR_Name").toString(), account.get("UR_Mail").toString(), account.get("GR_Code").toString() 
				, account.get("GR_Name").toString(), account.get("Attribute").toString(), account.get("DN_ID").toString()
				);
		
		String accessDate = tokenHelper.selCookieDate(date,"");
		if(!"".equals(key) && !"".equals(accessDate)){
			returnList.put("key", key);
			returnList.put("access_date", accessDate);
			returnList.put("result","ok");
				
			cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());
				
			if(loginsvc.deleteUserFailCount(id)){
				loginsvc.updateUserLock(id, "N");
			}
				
		}else{
			returnList.put("result","fail");
			LoggerHelper.connectFalseLogger(id,"LOGIN");
		}
				
		
		return returnList;
	
	}
	
	@RequestMapping(value = "/eumLogin.do")
	public void eumLogin(HttpServletRequest request, HttpServletResponse response) throws Exception {
		LOGGER.debug("/eumLogin.do");
		CoviMap loginInfo = new CoviMap();

		String eumId= "";
		String eumToken = request.getParameter("EumToken") ;
		try{
		    EUMAES aes = new EUMAES("", "M");
			String plainStr = aes.decrypt(eumToken);
			if (plainStr.indexOf("|") > 0){
				eumId = plainStr.substring(0, plainStr.indexOf("|"));
			}else{
				eumId = plainStr;	
			}
		} catch (NullPointerException e) {
			response.sendRedirect("/");
			return;
		} catch(Exception e){
			response.sendRedirect("/");
			return;
		}

		CoviMap cmap = loginsvc.getMyInfo(eumId);
        String id = cmap.getString("LogonID");
        if (id.equals("")){
        	response.sendRedirect("/");
			return;
        }
        
		String sPage= URLDecoder.decode(request.getParameter("ReturnURL"), "UTF-8").replaceAll("&amp;", "&");
		TokenHelper tokenHelper = new TokenHelper();
		StringUtil func = new StringUtil();
		RedisShardsUtil instance = RedisShardsUtil.getInstance();
		CookiesUtil cUtil = new CookiesUtil();
		String lang = "ko";
		
		String key = cUtil.getCooiesValue(request);
		//쿠기값이 있을 경우 기존 값 말료????
		if(!key.isEmpty()){
			TokenParserHelper tokenParserHelper = new TokenParserHelper();
			String decodeKey = tokenHelper.getDecryptToken(key);
			
			if(tokenParserHelper.parserJsonLoginVerification(decodeKey)) {
				Map<Object, Object> map = tokenParserHelper.getSSOToken(decodeKey);
				
				String cookieId = (String) map.get("id");
				lang = (String) map.get("lang");
				if (!id.equals(cookieId)){
					try{
						
						String subDomain = SessionHelper.getSession("SubDomain");
						HttpSession session = request.getSession();
						
						key = (String) session.getAttribute("KEY");
						String key_psm =  (String) session.getAttribute("USERID");
						
						CoviMap params = new CoviMap();
						
						params.put("logonID", SessionHelper.getSession("USERID"));
						params.put("IPAddress", func.getRemoteIP(request));
						params.put("OS", ClientInfoHelper.getClientOsInfo(request));
						params.put("browser", ClientInfoHelper.getClientWebKind(request)	+ ClientInfoHelper.getClientWebVer(request));
						
						loginsvc.updateLogoutTime(params);
						
						cUtil.removeCookies(response, request, key, "D", "N",subDomain);
						
						if( !ClientInfoHelper.isMobile(request) && !func.f_NullCheck(key_psm).equals("")){
							key_psm = key_psm + "_PSM";
							instance.remove(key_psm);
						}
						key = "";
					} catch (NullPointerException e) {
						throw e;
					} catch(Exception e){
						throw e;
					}
				}
			}
		}

		if (key.isEmpty()){
			String date = loginsvc.checkSSO("DAY");
			String dn = loginsvc.selectUserMailAddress(id);
			
			CoviMap accountList = loginsvc.checkAuthetication("SSO", id, "", "kr");
			CoviMap account = (CoviMap) accountList.get("account");
	
			LOGGER.debug("쿠키 생성  start ---------------------------------------------------------------------------");
			key = tokenHelper.setTokenString(id,date,"",lang,dn,account.get("DN_Code").toString(),account.get("UR_EmpNo").toString(),account.get("DN_Name").toString(),account.get("UR_Name").toString(),account.get("UR_Mail").toString(),account.get("GR_Code").toString(),account.get("GR_Name").toString(),account.get("Attribute").toString(),account.get("DN_ID").toString());
			
			String accessDate = tokenHelper.selCookieDate(date,"");
			CoviMap returnData  = new CoviMap();
			
			if(!"".equals(key) && !"".equals(accessDate)){
				cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());
				
				if(loginsvc.deleteUserFailCount(id)){
					loginsvc.updateUserLock(id, "N");
				}
				loginInfo.put("id",id);
				loginInfo.put("language",lang);
				returnData = getLoginInfo(loginInfo, ClientInfoHelper.isMobile(request), key, "", sPage, sPage, request, response);
			}else{
				LoggerHelper.connectFalseLogger(id,"LOGIN");
			}
			sPage = returnData.getString("returnURL").replace("redirect:","");
		}
		
		response.sendRedirect(sPage.replaceAll("\r", "").replaceAll("\n", ""));
	}
	/**
	 * @param request
	 * @param response
	 * @param userID
	 * @throws Exception
	 * @description 최종 로그인 사용자 정보 쿠키 저장
	 */
	private void setLastLoginUser(HttpServletRequest request, HttpServletResponse response, String userID) throws Exception {
		Cookie cookie = new Cookie("LastLoginUser",userID);
		//cookie.setMaxAge(60 * 5);
		cookie.setPath("/");
		response.addCookie(cookie);
	}
	
	
	
	/**
	 * @param request
	 * @param pID
	 * @param response
	 * @return
	 * @throws Exception
	 * @description 계정 잠금처리 
	 */
	@RequestMapping(value = "/account/lock.do")
	public @ResponseBody CoviMap lockAccount(HttpServletRequest request, 
			@RequestParam(value = "logonID", required = true) String pID,
			HttpServletResponse response) throws Exception {
		CoviMap returnData = new CoviMap();
		
		boolean flag = loginsvc.updateUserLock(pID, "Y");
		if(flag){
			LoggerHelper.connectFalseLogger(pID,"MLOCK");
			returnData.put("status", Return.SUCCESS);
		} else {
			returnData.put("status", Return.FAIL);
		}
		return returnData;
	}
	

	@RequestMapping(value = "/teamsAuth.do", method = {RequestMethod.POST, RequestMethod.GET})
	public ModelAndView teamsAuth(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception{
		String pMode = request.getParameter("mode") == null ? "" : request.getParameter("mode");
		String pReturnUrl = request.getParameter("ReturnUrl") == null ? "" : request.getParameter("ReturnUrl").replace("&amp;", "&").replace("&quot;", "\"");
		String pUpn = request.getParameter("upn") == null ? "" : request.getParameter("upn");
		String pLocale = request.getParameter("locale") == null ? "" : request.getParameter("locale");
		String pWidth = request.getParameter("width") == null ? "" : request.getParameter("width");
		String pHeight = request.getParameter("height") == null ? "" : request.getParameter("height");
		String pEtcparam = request.getParameter("etcparam") == null ? "" : request.getParameter("etcparam");
		String pUseTeamsPopup = request.getParameter("UseTeamsPopup") == null ? "Y" : request.getParameter("UseTeamsPopup");
		String actionURL = "/covicore/teamsAuth.do";
		String errorMessage = "";
		String returnUrl = "";
		ModelAndView mav = null;
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		try {
			if (!"".equals(SessionHelper.getSession("LogonID"))) {
				// 세션이 있는 경우
				if (pMode.toUpperCase().equals("BOTSERVICE")) {
					 if (pUseTeamsPopup.toUpperCase().equals("N")) {
						 returnUrl = "/covicore/teamsPopup.do?mode=BotService&width=" + pWidth + "&height=" + pHeight + "&etcparam=" + pEtcparam + "&ReturnUrl=" + URLEncoder.encode(pReturnUrl, "utf-8");
					 }
				} else if ("".equals(pMode)) {
					returnUrl = pReturnUrl;
				} else {
					returnUrl = getTeamsTargetURL(pMode, isMobile);
				}
				
				if ("".equals(returnUrl)) {
					errorMessage = "이동할 URL이 잘못되었습니다(Invalid URL)";
				}

				mav = new ModelAndView("core/login/teamsRedirect");
				mav.addObject("ReturnUrl", returnUrl);
				mav.addObject("errorMessage", errorMessage);
				
				return mav;
			} else if (!"".equals(pUpn)) {
				returnUrl = pReturnUrl;
				
				// 세션이 없는 경우
				CookiesUtil cUtil = new CookiesUtil();
				TokenHelper tokenHelper = new TokenHelper();
				CoviMap account = null;
				
				CoviMap resultList = loginsvc.selectM365UserInfo("", pUpn, "");
                
                String logonid = resultList.get("LogonID").toString();

				//인증체크 로직 수행
				resultList = loginsvc.checkAuthetication("OAUTH", logonid, "", pLocale);

				String status = resultList.get("status").toString();
				account = (CoviMap) resultList.get("account");

				String date = loginsvc.checkSSO("DAY");
				
				String accessDate = tokenHelper.selCookieDate(date,"");
				String key = tokenHelper.setTokenString(logonid,date,"",pLocale,account.get("UR_Mail").toString(),account.get("DN_Code").toString(),account.get("UR_EmpNo").toString(),account.get("DN_Name").toString(),account.get("UR_Name").toString(),account.get("UR_Mail").toString(),account.get("GR_Code").toString(),account.get("GR_Name").toString(),account.get("Attribute").toString(),account.get("DN_ID").toString());
					
				cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());

				//인증 성공 시
				if (status.equals("OK")) {
					actionURL = "/covicore/teamsLogin.do";
				} else {
					errorMessage = "[" + status + "] 인증 실패";
					//접속실패로그
					LoggerHelper.connectFalseLogger(logonid,"LOGIN");
				}
			}
		} catch (NullPointerException e) {
			errorMessage = DicHelper.getDic("msg_OccurError"); // 에러가 발생했습니다.
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			errorMessage = DicHelper.getDic("msg_OccurError"); // 에러가 발생했습니다.
			LOGGER.error(e.getLocalizedMessage(), e);
		}
                    
		if (mav == null) {
			mav = new ModelAndView("core/login/teamsAuth");
			mav.addObject("mode", pMode);
			mav.addObject("ReturnUrl", returnUrl);
			mav.addObject("actionURL", actionURL);
			mav.addObject("errorMessage", errorMessage);
		}

		return mav;
	}
	
	@RequestMapping(value = "/teamsLogin.do", method = {RequestMethod.POST, RequestMethod.GET})
	public ModelAndView teamsLogin(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception{
		CookiesUtil cUtil = new CookiesUtil();
		CoviMap account = null;
		String pMode = request.getParameter("mode") == null ? "" : request.getParameter("mode");
		String pReturnUrl = request.getParameter("ReturnUrl") == null ? "" : request.getParameter("ReturnUrl").replace("&amp;", "&").replace("&quot;", "\"");
		String pUpn = request.getParameter("upn") == null ? "" : request.getParameter("upn");
		String pLocale = request.getParameter("locale") == null ? "" : request.getParameter("locale");
		String pWidth = request.getParameter("width") == null ? "" : request.getParameter("width");
		String pHeight = request.getParameter("height") == null ? "" : request.getParameter("height");
		String pEtcparam = request.getParameter("etcparam") == null ? "" : request.getParameter("etcparam");
		String pUseTeamsPopup = request.getParameter("UseTeamsPopup") == null ? "Y" : request.getParameter("UseTeamsPopup");
		String pAuthToken = request.getParameter("authToken") == null ? "" : request.getParameter("authToken").replace("&amp;", "&").replace("&quot;", "\"");
		String errorMessage = "";
		String returnUrl = "";
		ModelAndView mav = null;
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		try {
            if ("".equals(pUpn)) {
            	errorMessage = "잘못된 접근입니다(Invalid access)";
            } else {
        		CoviMap resultList = new CoviMap();
        		resultList = loginsvc.selectM365UserInfo("", pUpn, "");
                
                //String scope = (("BOTSERVICE".equals(pMode.toUpperCase())) ? "BotService" : "TeamsApp");
                String scope = "TeamsApp";
                String dnid = resultList.get("DN_ID").toString();
                String logonid = resultList.get("LogonID").toString();

        		resultList = loginsvc.selectM365AppInfo(dnid, scope);
                String appid = resultList.get("AppId").toString();
                String tenantid = resultList.get("TenantId").toString();
                String clientsecret = resultList.get("ClientSecret").toString();
                
                CoviMap params = new CoviMap();
        		StringUtil func = new StringUtil();
        		HttpClient client = new HttpClient();
        		client.getParams().setContentCharset("utf-8");
        		
        		int httpStatus = 404;
        		String method = "";
        		String url = "";
        		String dataOAuth = "";
        		String body = "";
        		String responseMsg = "";
        		Object obj = null;
        		org.json.simple.JSONObject jsonObj = null;
        		String RequestDate = func.getCurrentTimeStr();
        		org.json.simple.parser.JSONParser parser = new org.json.simple.parser.JSONParser();
        		
        		try {
        			url = "https://login.microsoftonline.com/" + tenantid + "/oauth2/v2.0/token";
        			dataOAuth = "client_id=" + URLEncoder.encode(appid, "utf-8") + "&client_secret=" + URLEncoder.encode(clientsecret, "utf-8") + "&grant_type=" + URLEncoder.encode("urn:ietf:params:oauth:grant-type:jwt-bearer", "utf-8") + "&assertion=" + URLEncoder.encode(pAuthToken, "utf-8") + "&requested_token_use=on_behalf_of&scope=" + URLEncoder.encode("https://graph.microsoft.com/.default offline_access", "utf-8");

        			method = "POST";
        			PostMethod connPost = new PostMethod(url);
        			connPost.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");  					
        			connPost.setRequestBody(dataOAuth);
    				
        			httpStatus = client.executeMethod(connPost);
        			try (InputStream bodyStream = connPost.getResponseBodyAsStream();){
        				body = IOUtils.toString(bodyStream, StandardCharsets.UTF_8);
        			}
    				
    				obj = parser.parse( body );
    				jsonObj = (org.json.simple.JSONObject) obj;
    				String access_token = jsonObj.get("access_token").toString();

        			url = "https://graph.microsoft.com/v1.0/me";
        			GetMethod connGet = new GetMethod(url);
        			connGet.setRequestHeader("Content-Type", "application/json");
        			connGet.setRequestHeader("Authorization", "Bearer " + access_token);

        			httpStatus = client.executeMethod(connGet);
        			try(InputStream bodyStream = connGet.getResponseBodyAsStream();){
        				body = IOUtils.toString(bodyStream, StandardCharsets.UTF_8);
        			}

    				obj = parser.parse( body );
    				jsonObj = (org.json.simple.JSONObject) obj;
    				String userPrincipalName = jsonObj.get("userPrincipalName").toString();
    				if(!pUpn.toLowerCase().equals(userPrincipalName.toLowerCase())) {
    					errorMessage = "잘못된 Token입니다(Invalid Token)";
    				} else {
        				//인증체크 로직 수행
        				resultList = loginsvc.checkAuthetication("OAUTH", logonid, "", pLocale);

        				String status = resultList.get("status").toString();
        				account = (CoviMap) resultList.get("account");

    					LOGGER.debug("쿠키 유효성 체크 start ---------------------------------------------------------------------------");
    					String key = cUtil.getCooiesValue(request);
    					
    					TokenHelper tokenHelper = new TokenHelper();
    					TokenParserHelper tokenParserHelper = new TokenParserHelper();
    					String decodKey = tokenHelper.getDecryptToken(key);
    					if(!tokenParserHelper.parserJsonVerification(decodKey,logonid)){

    						String redirectURL = "redirect:"+request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/logout.do";
    						
    						mav = new ModelAndView(redirectURL);
    						mav.addObject("loginState", "fail");

    						return mav;
    					}
    					
    					//라이선스 인증 정보 초기화
    					LicenseHelper.resetUserLicenseCheck(account.get("UR_Code").toString(), account.get("DN_ID").toString());
    					
    					//세션 생성
    					HttpSession session = request.getSession();
    					session.getServletContext().setAttribute(key, account.get("UR_ID").toString());
    					session.setAttribute("KEY", key);
    					session.setAttribute("USERID", account.get("UR_ID").toString());
    					session.setAttribute("LOGIN", "Y");

    					account.put("UR_LoginIP",func.getRemoteIP(request));
    					SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account, isMobile);
    					
    					setLastLoginUser(request, response, account.get("UR_ID").toString());
    					
    					LoggerHelper.connectLogger(account.get("UR_ID").toString(), account.get("UR_Code").toString(), account.get("LogonID").toString(), account.get("LanguageCode").toString());
    				}
        		} catch (NullPointerException e) {
        			httpStatus = 500;
        			responseMsg = e.toString();
        			errorMessage = "[" + httpStatus + "]" + responseMsg;
        		} catch (Exception e2) {
        			httpStatus = 500;
        			responseMsg = e2.toString();
        			errorMessage = "[" + httpStatus + "]" + responseMsg;
        		} finally {
        			params.put("LogType","TEAMS");
        			params.put("Method",method);
                	params.put("ConnetURL",url);
                	
                	params.put("RequestDate", RequestDate);
                	params.put("ResultState", Integer.toString(httpStatus));
                	params.put("RequestBody", dataOAuth);
                	
                	if(func.f_NullCheck(responseMsg).equals("")){
                		if(httpStatus < 299){
                			params.put("ResultType", "SUCCESS");
                		}else{
                			params.put("ResultType", "FAIL");
                		}
                		params.put("ResponseMsg", body);
                	}else{
                		params.put("ResultType", "FAIL");
                		params.put("ResponseMsg", responseMsg);
                	}
                	
                	params.put("ResponseDate", func.getCurrentTimeStr());
                	LoggerHelper.httpLog(params);
        		}
            }
		} catch (NullPointerException e) {
			errorMessage = DicHelper.getDic("msg_OccurError"); // 에러가 발생했습니다.
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			errorMessage = DicHelper.getDic("msg_OccurError"); // 에러가 발생했습니다.
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		if (mav == null) {
			if (pMode.toUpperCase().equals("BOTSERVICE")) {
				 if (pUseTeamsPopup.toUpperCase().equals("N")) {
					 returnUrl = "/covicore/teamsPopup.do?mode=BotService&width=" + pWidth + "&height=" + pHeight + "&etcparam=" + pEtcparam + "&ReturnUrl=" + URLEncoder.encode(returnUrl, "utf-8");
				 }
			} else if ("".equals(pMode)) {
				returnUrl = pReturnUrl;
			} else {
				returnUrl = getTeamsTargetURL(pMode, isMobile);
			}
			
			if ("".equals(returnUrl)) {
				errorMessage = "이동할 URL이 잘못되었습니다(Invalid URL)";
			}
			
			mav = new ModelAndView("core/login/teamsRedirect");
			mav.addObject("ReturnUrl", returnUrl);
			mav.addObject("errorMessage", errorMessage);
		}

		return mav;
	}

	@RequestMapping(value = "/teamsSLOAuth.do", method = {RequestMethod.POST, RequestMethod.GET})
	public ModelAndView teamsSLOAuth(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception{
		String pMode = request.getParameter("mode") == null ? "" : request.getParameter("mode");
		String pToken = request.getParameter("token") == null ? "" : request.getParameter("token").replace("&amp;", "&").replace("&quot;", "\"");
		String pReturnUrl = request.getParameter("ReturnUrl") == null ? "" : request.getParameter("ReturnUrl").replace("&amp;", "&").replace("&quot;", "\"");
		String pWidth = request.getParameter("width") == null ? "" : request.getParameter("width");
		String pHeight = request.getParameter("height") == null ? "" : request.getParameter("height");
		String pEtcparam = request.getParameter("etcparam") == null ? "" : request.getParameter("etcparam");
		String pLogonid = request.getParameter("logonid") == null ? "" : request.getParameter("logonid");
		String pLang = request.getParameter("lang") == null ? "ko" : request.getParameter("lang");
		String errorMessage = "";
		ModelAndView mav = null;
		
		try {
			if ("".equals(pReturnUrl)) {
				errorMessage = DicHelper.getDic("msg_InvalidMoveUrl",pLang); //이동할 URL이 잘못되었습니다.
			} else if ("".equals(pLogonid)) {
				errorMessage = DicHelper.getDic("msg_InvalidAccess",pLang); //잘못된 접근입니다.
			} else if ("".equals(SessionHelper.getSession("LogonID"))) {
				CookiesUtil cUtil = new CookiesUtil();
				TokenHelper tokenHelper = new TokenHelper();
				CoviMap account = null;
				
				//인증체크 로직 수행
                CoviMap resultList = loginsvc.checkAuthetication("SSO", pLogonid, "", pLang);

				String status = resultList.get("status").toString();
				account = (CoviMap) resultList.get("account");

				String date = loginsvc.checkSSO("DAY");
				
				String accessDate = tokenHelper.selCookieDate(date,"");
				String key = tokenHelper.setTokenString(pLogonid,date,"",pLang,account.get("UR_Mail").toString(),account.get("DN_Code").toString(),account.get("UR_EmpNo").toString(),account.get("DN_Name").toString(),account.get("UR_Name").toString(),account.get("UR_Mail").toString(),account.get("GR_Code").toString(),account.get("GR_Name").toString(),account.get("Attribute").toString(),account.get("DN_ID").toString());
					
				cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());

				//인증 성공 시
				if (!status.equals("OK")) {
					errorMessage = "{" + status + "] "+ DicHelper.getDic("lbl_NoAudit",pLang);
					//접속실패로그
					LoggerHelper.connectFalseLogger(pLogonid,"LOGIN");
				}
			}
		} catch (NullPointerException e) {
			errorMessage = DicHelper.getDic("msg_OccurError"); // 에러가 발생했습니다.
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			errorMessage = DicHelper.getDic("msg_OccurError"); // 에러가 발생했습니다.
			LOGGER.error(e.getLocalizedMessage(), e);
		}
                    
		if (mav == null) {
			mav = new ModelAndView("core/login/teamsSLOAuth");
			mav.addObject("mode", pMode);
			mav.addObject("token", pToken);
			mav.addObject("ReturnUrl", pReturnUrl);
			mav.addObject("width", pWidth);
			mav.addObject("height", pHeight);
			mav.addObject("etcparam", pEtcparam);
			mav.addObject("logonid", pLogonid);
			mav.addObject("lang", pLang);

			mav.addObject("errorMessage", errorMessage);
		}

		return mav;
	}
	
	@RequestMapping(value = "/teamsSLOLogin.do", method = {RequestMethod.POST, RequestMethod.GET})
	public ModelAndView teamsSLOLogin(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception{
		CookiesUtil cUtil = new CookiesUtil();
		CoviMap account = null;
		String pMode = request.getParameter("mode") == null ? "" : request.getParameter("mode");
		String pToken = request.getParameter("token") == null ? "" : request.getParameter("token").replace("&amp;", "&").replace("&quot;", "\"");
		String pReturnUrl = request.getParameter("ReturnUrl") == null ? "" : request.getParameter("ReturnUrl").replace("&amp;", "&").replace("&quot;", "\"");
		String pWidth = request.getParameter("width") == null ? "" : request.getParameter("width");
		String pHeight = request.getParameter("height") == null ? "" : request.getParameter("height");
		String pEtcparam = request.getParameter("etcparam") == null ? "" : request.getParameter("etcparam");
		String pLogonid = request.getParameter("logonid") == null ? "" : request.getParameter("logonid");
		String pLang = request.getParameter("lang") == null ? "ko" : request.getParameter("lang");
		String errorMessage = "";
		ModelAndView mav = null;
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		try {
            if ("".equals(pMode)) {
            	errorMessage = DicHelper.getDic("msg_InvalidAccess",pLang); //잘못된 접근입니다.
            } else if ("".equals(pToken)) {
            	errorMessage = DicHelper.getDic("msg_InvalidAccess",pLang); //잘못된 접근입니다.
            } else if ("".equals(pReturnUrl)) {
            	errorMessage = DicHelper.getDic("msg_InvalidMoveUrl",pLang); //이동할 URL이 잘못되었습니다.
			} else {
        		StringUtil func = new StringUtil();
				TokenHelper tokenHelper = new TokenHelper();
				TokenParserHelper tokenParserHelper = new TokenParserHelper();
				String decodToken = tokenHelper.getDecryptToken(pToken);
				if (!tokenParserHelper.parserJsonVerification(decodToken,pLogonid)) {
					errorMessage = DicHelper.getDic("msg_invalidToken",pLang); //Token이 유효하지 않습니다.
				} else {
    				//인증체크 로직 수행
    				CoviMap resultList = loginsvc.checkAuthetication("OAUTH", pLogonid, "", pLang);

    				String status = resultList.get("status").toString();
    				account = (CoviMap) resultList.get("account");
    				
					LOGGER.debug("쿠키 유효성 체크 start ---------------------------------------------------------------------------");
					String key = cUtil.getCooiesValue(request);
					String decodKey = tokenHelper.getDecryptToken(key);
					if(!tokenParserHelper.parserJsonVerification(decodKey,pLogonid)){

						String redirectURL = "redirect:"+request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/logout.do";
						
						mav = new ModelAndView(redirectURL);
						mav.addObject("loginState", "fail");

						return mav;
					}
					
					//라이선스 인증 정보 초기화
					LicenseHelper.resetUserLicenseCheck(account.get("UR_Code").toString(), account.get("DN_ID").toString());
					
					//세션 생성
					HttpSession session = request.getSession();
					session.getServletContext().setAttribute(key, account.get("UR_ID").toString());
					session.setAttribute("KEY", key);
					session.setAttribute("USERID", account.get("UR_ID").toString());
					session.setAttribute("LOGIN", "Y");

					account.put("UR_LoginIP",func.getRemoteIP(request));
					SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account, isMobile);

					setLastLoginUser(request, response, account.get("UR_ID").toString());
					
					LoggerHelper.connectLogger(account.get("UR_ID").toString(), account.get("UR_Code").toString(), account.get("LogonID").toString(), account.get("LanguageCode").toString());
				}
            }
		} catch (NullPointerException e) {
			errorMessage = DicHelper.getDic("msg_OccurError"); // 에러가 발생했습니다.
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			errorMessage = DicHelper.getDic("msg_OccurError"); // 에러가 발생했습니다.
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		if(mav == null) {
			mav = new ModelAndView("core/login/teamsSLORedirect");
			mav.addObject("mode", pMode);
			mav.addObject("ReturnUrl", pReturnUrl);
			mav.addObject("width", pWidth);
			mav.addObject("height", pHeight);
			mav.addObject("etcparam", pEtcparam);
			mav.addObject("errorMessage", errorMessage);
		}

		return mav;
	}
	
	@RequestMapping(value = "/teamsPopup.do", method = {RequestMethod.POST, RequestMethod.GET})
	public ModelAndView teamsPopup(HttpServletRequest request, HttpServletResponse response, Locale locale, Model model) throws Exception{
		CookiesUtil cUtil = new CookiesUtil();
		CoviMap account = null;
		String pMode = request.getParameter("mode") == null ? "" : request.getParameter("mode");
		String pToken = request.getParameter("token") == null ? "" : request.getParameter("token").replace("&amp;", "&").replace("&quot;", "\"");
		String pReturnUrl = request.getParameter("ReturnUrl") == null ? "" : request.getParameter("ReturnUrl").replace("&amp;", "&").replace("&quot;", "\"");
		String pWidth = request.getParameter("width") == null ? "" : request.getParameter("width");
		String pHeight = request.getParameter("height") == null ? "" : request.getParameter("height");
		String pEtcparam = request.getParameter("etcparam") == null ? "" : request.getParameter("etcparam");
		String errorMessage = "";
		
		ModelAndView mav = new ModelAndView("core/login/teamsPopup");
		mav.addObject("mode", pMode);
		mav.addObject("ReturnUrl", pReturnUrl);
		mav.addObject("width", pWidth);
		mav.addObject("height", pHeight);
		mav.addObject("etcparam", pEtcparam);
		mav.addObject("errorMessage", errorMessage);

		return mav;
	}
	
	private String getTeamsTargetURL(String mode, Boolean isMobile) throws Exception {
		String ReturnUrl = "";
		switch(mode.toUpperCase()) {
	        case "PORTAL": // 포탈
	        	ReturnUrl = "/groupware/mobile/portal/main.do";
	            break;
	        case "APPROVAL": // 결재
	        	ReturnUrl = "/approval/mobile/approval/list.do";
	            break;
	        case "ATTENDANCE": // 근태관리
	        	ReturnUrl = "/groupware/mobile/attend/main.do";
	            break;
	        case "BOARD": // 게시
	        	ReturnUrl = "/groupware/mobile/board/list.do?menucode=BoardMain&boardtype=Total";
	            break;
	        case "EACCOUNTING": // e-Accounting
	        	ReturnUrl = "/account/mobile/account/portal.do";
	            break;
	        case "MAIL": // 메일
	        	ReturnUrl = "/mail/mobile/mail/List.do";
	            break;
	        case "ORGMAP": // 조직도
	            if (isMobile)
	            {
	            	ReturnUrl = "/covicore/mobile/org/teamslist.do";
	            }
	            else
	            {
	            	ReturnUrl = "/covicore/control/goOrgChart.do?type=TEAMS&CFN_OpenLayerName=orgmap_pop&CLMD=user";
	            }
	            break;
	        case "RESOURCE": // 자원예약
	        	ReturnUrl = "/groupware/mobile/resource/list.do?viewtype=D";
	            break;
	        case "SURVEY": // 설문
	        	ReturnUrl = "/groupware/mobile/survey/list.do";
	            break;
	        default : break;
		}

		if (!"".equals(ReturnUrl) && ReturnUrl.indexOf("teamsaddin=") == -1) {
			if (ReturnUrl.indexOf("?") > -1) {
				ReturnUrl += "&teamsaddin=Y";
			} else {
				ReturnUrl += "?teamsaddin=Y";
			}
		}
			
		return ReturnUrl;
	}
	
	private String convertIpString(String ipaddress){
		if(ipaddress != null && ipaddress.indexOf(",") > 0) {
			ipaddress = ipaddress.split(",")[0];
		}
		if(ipaddress == null) {
			return "";
		}
		String[] ip = ipaddress.split("\\.");
		if(ip.length >= 4) {
			String partIPAddress = String.format("%03d.", StringUtil.parseInt(ip[0]))+String.format("%03d.", StringUtil.parseInt(ip[1]))	+String.format("%03d.", StringUtil.parseInt(ip[2]))	+String.format("%03d" , StringUtil.parseInt(ip[3]));
			return partIPAddress;
		}else {
			return "";
		}

	}
}
