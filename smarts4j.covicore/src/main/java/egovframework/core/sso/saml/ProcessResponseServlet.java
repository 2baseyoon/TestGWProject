package egovframework.core.sso.saml;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.RequestDispatcher;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom.Document;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.sso.saml.RequestUtil;
import egovframework.baseframework.sso.saml.SAMLSigner;
import egovframework.baseframework.sso.saml.SamlException;
import egovframework.baseframework.sso.saml.Util;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.SsoSamlSvc;
import egovframework.core.web.SsoSamlCon;
import egovframework.coviframework.base.TokenHelper;
import egovframework.coviframework.base.TokenParserHelper;
import egovframework.coviframework.util.SessionCommonHelper;



@Controller
public class ProcessResponseServlet extends HttpServlet {
	@Autowired
	private SsoSamlSvc ssoSamlSvc;
	
	private Logger LOGGER = LogManager.getLogger(ProcessResponseServlet.class);

	private static final long serialVersionUID = -6573064495294318785L;
//	private static String assertionID = "";
	private final String samlResponseTemplateFile = "SamlResponseTemplate.xml";
	private String publicKey = PropertiesUtil.getSecurityProperties().getProperty("public.key");
	private String privateKey = PropertiesUtil.getSecurityProperties().getProperty("private.key");
	
	/**
	 * <pre>
	 * 1. 개요 : Select User Count Check.
	 * </pre>
	 * @Method Name : loginCheck
	 * @date : 2017. 7. 28.
	 * @param empno
	 * @param code
	 * @return
	 */ 	
	private boolean loginCheck(String empno, String code) {
		StringUtil func = new StringUtil();
		
		try {
			int count = 0 ;
			if(!func.f_NullCheck(empno).equals("") && !func.f_NullCheck(code).equals("")){
				count = ssoSamlSvc.checkUserCnt(empno, code);
				
				if(count > 0){
					return true;
				}else{
					return false;
				}
			}else{
				return false;
			}
		} catch (NullPointerException e) {
			return false;
		} catch (Exception e) {
			return false;
		}
	}

	/*
	 * Retrieves the AuthnRequest from the encoded and compressed String
	 * extracted from the URL. The AuthnRequest XML is retrieved in the
	 * following order: <p> 1. URL decode <br> 2. Base64 decode <br> 3. Inflate
	 * <br> Returns the String format of the AuthnRequest XML.
	 */ 
	public static String decodeAuthnRequestXML(String encodedRequestXmlString)
			throws SamlException {
		try {
			// URL decode
			// No need to URL decode: auto decoded by request.getParameter()
			// method

			// Base64 decode
			Base64 base64Decoder = new Base64();
			byte[] xmlBytes = encodedRequestXmlString.getBytes("UTF-8");
			byte[] base64DecodedByteArray = base64Decoder.decode(xmlBytes);
			return new String(base64DecodedByteArray, StandardCharsets.UTF_8);

		} catch (UnsupportedEncodingException e) {
			throw new SamlException("Error decoding AuthnRequest: "
					+ "Check decoding scheme - " + e.getMessage());
		} catch (IOException e) {
			throw new SamlException("Error decoding AuthnRequest: "
					+ "Check decoding scheme - " + e.getMessage());
		}
	}

	/*
	 * Creates a DOM document from the specified AuthnRequest xmlString and
	 * extracts the value under the "AssertionConsumerServiceURL" attribute
	 */
	public static String[] getRequestAttributes(String xmlString)
			throws SamlException {
		Document doc = Util.createJdomDoc(xmlString);
		if (doc != null) {
			String[] samlRequestAttributes = new String[8];
			samlRequestAttributes[0] = doc.getRootElement().getAttributeValue(
					"IssueInstant");
			samlRequestAttributes[1] = doc.getRootElement().getAttributeValue(
					"Name");
			samlRequestAttributes[2] = doc.getRootElement().getAttributeValue(
					"AssertionConsumerServiceURL");
			samlRequestAttributes[3] = doc.getRootElement().getAttributeValue(
					"ID");
			samlRequestAttributes[4] = doc.getRootElement().getAttributeValue(
					"ForceAuthn");
			samlRequestAttributes[5] = doc.getRootElement().getAttributeValue(
					"Emp");
			samlRequestAttributes[6] = doc.getRootElement().getAttributeValue(
					"Code");
			samlRequestAttributes[7] = doc.getRootElement().getAttributeValue(
					"InResponseTo");
			return samlRequestAttributes;
		} else {
			throw new SamlException(
					"Error parsing AuthnRequest XML: Null document");
		}
	}

	/*
	 * Creates a DOM document from the specified AuthnRequest xmlString and
	 * extracts the value under the "AssertionConsumerServiceURL" attribute
	 */
	public static String[] getRequestAttributesService(String xmlString)
			throws SamlException {
		
		Document doc = Util.createJdomDoc(xmlString);
		if (doc != null) {
			String[] samlRequestAttributes = new String[11];
			samlRequestAttributes[0] = doc.getRootElement().getAttributeValue(
					"Issuer");
			samlRequestAttributes[1] = doc.getRootElement().getAttributeValue(
					"IssueInstant");
			samlRequestAttributes[2] = doc.getRootElement().getAttributeValue(
					"SpEntity");
			samlRequestAttributes[3] = doc.getRootElement().getAttributeValue(
					"SpIssuerUrl");
			samlRequestAttributes[4] = doc.getRootElement().getAttributeValue(
					"SpTarget");
			samlRequestAttributes[5] = doc.getRootElement().getAttributeValue(
					"ProviderName");
			samlRequestAttributes[6] = doc.getRootElement().getAttributeValue(
					"AssertionConsumerServiceURL");
		/*	samlRequestAttributes[7] = doc.getRootElement().getAttributeValue(
					"Destination");*/
			samlRequestAttributes[7] = doc.getRootElement().getAttributeValue(
					"AssertionConsumerServiceURL");
			samlRequestAttributes[8] = doc.getRootElement().getAttributeValue(
					"IdpSsoUrl");
			samlRequestAttributes[9] = doc.getRootElement().getAttributeValue(
					"IdpEntity");
			samlRequestAttributes[10] = doc.getRootElement().getAttributeValue(
					"ID");
		
			return samlRequestAttributes;
		} else {
			throw new SamlException(
					"Error parsing AuthnRequest XML: Null document");
		}
	}
	

	/**
	 * <pre>
	 * 1. 개요 : SAML IDP 기능 (외부 프로세스)
	 * 2. 처리내용 : - Response와 동시 처리..
	 * </pre>
	 * @Method Name : setSamlGateWayData
	 * @date : 2017. 7. 31.
	 * @param request
	 * @param response
	 * @throws Exception
	 */ 	
	@RequestMapping(value="ssoSamlGateWayData.do" )
	public void samlGateWayData(HttpServletRequest request, HttpServletResponse response) throws Exception {
		StringUtil func = new StringUtil();
		CookiesUtil cUtil = new CookiesUtil();
		
	    LOGGER.info("## SAML GATE WAY DATA##");
		TokenHelper tokenHelper = new TokenHelper();
		TokenParserHelper tokenParserHelper = new TokenParserHelper();
		
		CoviMap resultList = new CoviMap();
	
		boolean continueLogin = true;
	
		// for forwarding to SP
		String samlRequest = request.getParameter("SAMLRequest");
		String relayState = request.getParameter("RelayState");
		
		String name = "";
		String authType = "";
		String status = "";
		String key = "";
		String accessDate = "";
		String date = "";
		String returnURL = "";
		String maxAge = "";
		String signedSamlResponse = "";
		
		//SAML Request 
		String issuer = "";
		String issueInstant = "";
		String spEntity = "";
		String spIssuerUrl = "";
		String spTarget = "";
		String assertionConsumerServiceURL = "";
		String providerName = "";
		String idpEntity = "";
		String idpSsoUrl = "";
		String destination = "";
		String uid = "";
		
		HttpSession session = request.getSession();
		
		//SAML
		authType = "SAML";
		
		if (func.f_NullCheck(samlRequest).equals("")) {
			//ERROR
			//page Redirect 
			LOGGER.error("## SAML GATE WAY - SAML REQUEST NULL [ERROR] ##");
		} else {
			
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
				
				String requestXmlString = ProcessResponseServlet.decodeAuthnRequestXML(StringUtil.replaceNull(samlRequest));
				String[] samlRequestAttributes = ProcessResponseServlet.getRequestAttributesService(requestXmlString);
				issuer = samlRequestAttributes[0];
				issueInstant = samlRequestAttributes[1];
				spEntity = samlRequestAttributes[2];
				spIssuerUrl = samlRequestAttributes[3];
				spTarget = samlRequestAttributes[4];
				providerName = samlRequestAttributes[5];
				assertionConsumerServiceURL = samlRequestAttributes[6];
				destination = samlRequestAttributes[7];
				idpEntity = samlRequestAttributes[8];
				idpSsoUrl = samlRequestAttributes[9];
				uid = samlRequestAttributes[10];
				if(!"".equals(id) && !"".equals(pw) ){
					if(ssoSamlSvc.checkUserAuthetication(id,pw) > 0){
						if(tokenParserHelperCon.parserJsonLoginVerification(decodeKey)){
							
								// Domain name of IP
								String publicKeyFilePath = null;
								String privateKeyFilePath = null;
								 
								String osName = System.getProperty("os.name");
								if(osName.indexOf("Windows") != -1){
									publicKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+publicKey);
									privateKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+privateKey);
								}else{
									String path = ssoSamlSvc.checkSSO("PATH");
									publicKeyFilePath = path+publicKey;
									privateKeyFilePath = path+privateKey ; 
								}
								request.setAttribute("issueInstant", issueInstant);
								request.setAttribute("providerName", "Covision");
								request.setAttribute("RelayState", relayState);
																		
						}//tokenParserHelperCon.parserJsonLoginVerification(decode_key)
					}//ssoSamlSvc.checkUserAuthetication(id,pw) > 0
				}//!"".equals(id) && !"".equals(pw)
				
			}else{
				String requestXmlString = ProcessResponseServlet.decodeAuthnRequestXML(StringUtil.replaceNull(samlRequest));
				String[] samlRequestAttributes = ProcessResponseServlet.getRequestAttributesService(requestXmlString);
				issuer = samlRequestAttributes[0];
				issueInstant = samlRequestAttributes[1];
				spEntity = samlRequestAttributes[2];
				spIssuerUrl = samlRequestAttributes[3];
				spTarget = samlRequestAttributes[4];
				providerName = samlRequestAttributes[5];
				assertionConsumerServiceURL = samlRequestAttributes[6];
				
				destination = samlRequestAttributes[7];
				idpEntity = samlRequestAttributes[8];
				idpSsoUrl = samlRequestAttributes[9];
				uid = samlRequestAttributes[10];
			}
			
			
		}//func.f_NullCheck(SAMLRequest).equals("")
		
		response.setContentType("text/html; charset=UTF-8");
		if(!func.f_NullCheck(returnURL).equals("")){
			
			LOGGER.info("## SAML GATE WAY - SP Response ##");
			
			StringBuffer buf = new StringBuffer();
			buf.append("samlRedirect.do");
			buf.append("?SAMLResponse=");
			buf.append(RequestUtil.encodeMessage(signedSamlResponse));
			buf.append("&RelayState=");
			buf.append(URLEncoder.encode(relayState));
			buf.append("&uid=");
			buf.append(uid);
			buf.append("&acr=");
			buf.append(assertionConsumerServiceURL);
			returnURL =  buf.toString();
			
			RequestDispatcher  rd = request.getRequestDispatcher(returnURL);
			rd.forward(request, response);
		
		}else{
			if(func.f_NullCheck(key).equals("")){
				LOGGER.info("## SAML GATE WAY - No key Login ##");
				returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/login.do?SAMLRequest="+samlRequest+"&RelayState="+relayState+"&acr="+assertionConsumerServiceURL+"&uid="+uid+"&destination="+destination;
				returnURL = returnURL.replaceAll("\r", "").replaceAll("\n", ""); //CLRF 대응
				response.sendRedirect(returnURL);
			}else{
				LOGGER.info("## SAML GATE WAY - No key Logout ##");
				returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/login.do?SAMLRequest="+samlRequest+"&RelayState="+relayState+"&acr="+assertionConsumerServiceURL+"&sop="+"Y"+"&uid="+uid+"&destination="+destination;
				returnURL = returnURL.replaceAll("\r", "").replaceAll("\n", ""); //CLRF 대응
				response.sendRedirect(response.encodeURL(returnURL));
				
			}
			
		}
	}
	
	@RequestMapping(value="ssoSamlGateWay.do" )
	public void samlGateWay(HttpServletRequest request, HttpServletResponse response) throws Exception {
		LOGGER.info("## SAML GATE WAY ##");
		
		StringUtil func = new StringUtil();
		CookiesUtil cUtil = new CookiesUtil();
		
		TokenHelper tokenHelper = new TokenHelper();
		TokenParserHelper tokenParserHelper = new TokenParserHelper();
		
		CoviMap resultList = new CoviMap();
	
		boolean continueLogin = true;
		boolean isMobile = ClientInfoHelper.isMobile(request);
		
		// for forwarding to SP
		String samlRequest = request.getParameter("SAMLRequest");
		String relayState = request.getParameter("RelayState");
		String name = "";
		String authType = "";
		String status = "";
		String key = "";
		String accessDate = "";
		String date = "";
		String returnURL = "";
		String maxAge = "";
		String signedSamlResponse = "";
		
		//SAML Request 
		String issuer = "";
		String issueInstant = "";
		String spEntity = "";
		String spIssuerUrl = "";
		String spTarget = "";
		String assertionConsumerServiceURL = "";
		String providerName = "";
		String idpEntity = "";
		String idpSsoUrl = "";
		String uid = "";
		String destination = "";
		
		
		HttpSession session = request.getSession();
		
		//SAML
		authType = "SAML";
		
		if (func.f_NullCheck(samlRequest).equals("")) {
			//ERROR
			//page Redirect 
			  LOGGER.error("## SAML GATE WAY - SAML REQUEST NULL [ERROR] ##");
		} else {
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
				
				String requestXmlString = ProcessResponseServlet.decodeAuthnRequestXML(StringUtil.replaceNull(samlRequest));
				String[] samlRequestAttributes = ProcessResponseServlet.getRequestAttributesService(requestXmlString);
				issuer = samlRequestAttributes[0];
				issueInstant = samlRequestAttributes[1];
				spEntity = samlRequestAttributes[2];
				spIssuerUrl = samlRequestAttributes[3];
				spTarget = samlRequestAttributes[4];
				providerName = samlRequestAttributes[5];
				assertionConsumerServiceURL = samlRequestAttributes[6];
				destination = samlRequestAttributes[7];
				idpEntity = samlRequestAttributes[8];
				idpSsoUrl = samlRequestAttributes[9];
				uid = samlRequestAttributes[10];
				if(!"".equals(id) && !"".equals(pw) ){
					if(ssoSamlSvc.checkUserAuthetication(id,pw) > 0){
						if(tokenParserHelperCon.parserJsonLoginVerification(decodeKey)){
							
								// Domain name of IP
								String publicKeyFilePath = null;
								String privateKeyFilePath = null;
								 
								String osName = System.getProperty("os.name");
								if(osName.indexOf("Windows") != -1){
									publicKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+publicKey);
									privateKeyFilePath = request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+privateKey);
								}else{
									String path = ssoSamlSvc.checkSSO("PATH");
									publicKeyFilePath = path+publicKey ;
									privateKeyFilePath = path+privateKey; 
								}
								request.setAttribute("issueInstant", issueInstant);
								request.setAttribute("providerName", "Covision");
								//request.setAttribute("username", name);
								request.setAttribute("RelayState", relayState);
								
								// First, verify that the NotBefore and NotOnOrAfter values
								// are valid
								RSAPrivateKey privateKey = (RSAPrivateKey) Util
										.getPrivateKey(privateKeyFilePath, "RSA");
								
								RSAPublicKey publicKey = (RSAPublicKey) Util.getPublicKey(
										publicKeyFilePath, "RSA");
								long now = System.currentTimeMillis();
								
								String day = ssoSamlSvc.checkSSO("DAY");
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
									String assertionID = Util.createID();
									
									// Sign the SAML response XML
									signedSamlResponse = SAMLSigner.signXML(
											responseXmlString, privateKey, publicKey);
									//여기서 작업 (Session 처리)
									String paramId = id;
									String paramPwd = pw;
									String paramLang = lang;
									
									authType = "SAML";
									
									//인증체크 로직 수행
									resultList = ssoSamlSvc.checkAuthetication(authType, paramId, paramPwd, paramLang);
									
									status = resultList.get("status").toString();
									CoviMap account = (CoviMap) resultList.get("account");
									CoviMap accountTokenList = (CoviMap) resultList.get("account");
									
									SsoSamlCon ssoSamlCon = new SsoSamlCon();
									int sessionDelChk =0;
									//인증 성공 시
									if (status.equals("OK")) {
										date = ssoSamlSvc.checkSSO("DAY");

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
													accountList = ssoSamlSvc.selectTokenInForMation(key);
													accountTokenList = (CoviMap) accountList.get("account");
													
													account.put("Type", "AO");
													
													ssoSamlCon.setSamlInsideResponse(accountTokenList,request,response);
													sessionDelChk = 1; //세션 삭제 확인 용.
													
													cUtil.removeCookies(response, request, key, "D", "N",account.get("SubDomain").toString());
													
												}
											}else{
												if(!func.f_NullCheck(key).equals("")){
													accountList = ssoSamlSvc.selectTokenInForMation(key);
													accountTokenList = (CoviMap) accountList.get("account");
													
													accountTokenList.put("Type", "AO");
													
													ssoSamlCon.setSamlInsideResponse(accountTokenList,request,response);
													sessionDelChk = 1; //세션 삭제 확인 용.
													
													cUtil.removeCookies(response, request, key, "D", "N",account.get("SubDomain").toString());
													
												}
											}
											if(sessionDelChk > 0 ){
												session = request.getSession();
											}
											
											key = tokenHelper.setTokenString(account.get("LogonID").toString(), date, paramPwd, paramLang,account.get("UR_Mail").toString(),account.get("DN_Code").toString(),account.get("UR_EmpNo").toString(),account.get("DN_Name").toString(),account.get("UR_Name").toString(),account.get("UR_Mail").toString(),account.get("GR_Code").toString(),account.get("GR_Name").toString(),account.get("Attribute").toString(),account.get("DN_ID").toString());
											
											accessDate = tokenHelper.selCookieDate(date,"");
											session.getServletContext().setAttribute(key, paramId );
											
											session.setAttribute("KEY", key);
											session.setAttribute("USERID", paramId);
											session.setAttribute("LOGIN", "Y");
											
											if(!paramId.equals("admin"))
												session.setAttribute("DEPTID", paramId);
											else
												session.setAttribute("DEPTID", "");
											
											String urNm = account.get("UR_Name").toString();
											String urCode = account.get("UR_Code").toString();
											String urEmpNo = account.get("UR_EmpNo").toString();
											String urId = account.get("UR_ID").toString();
											
											SessionCommonHelper.makeSession(paramId, account, isMobile);
											//SessionHelper.setSession("SSO", authType);
											//SessionHelper.setSession("lang", paramLang, isMobile);
											
											// 접속로그 생성
											LoggerHelper.connectLogger();
											
											String mainPage = "";
											if(isMobile(request)){
												mainPage= "/approval/mobile/MobileApprovalList.do";
											}else{
												mainPage= PropertiesUtil.getGlobalProperties().getProperty("MainPage.path");
											}
											
											returnURL = assertionConsumerServiceURL;
											
											maxAge = tokenHelper.selCookieDate(date,"1");
											//Token 저장.
											if(ssoSamlSvc.insertTokenHistory(key, account.get("LogonID").toString(), urNm, urCode, urEmpNo, maxAge, "E", assertionID)){

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
				
			}else{
				String requestXmlString = ProcessResponseServlet.decodeAuthnRequestXML(StringUtil.replaceNull(samlRequest));
				String[] samlRequestAttributes = ProcessResponseServlet.getRequestAttributesService(requestXmlString);
				issuer = samlRequestAttributes[0];
				issueInstant = samlRequestAttributes[1];
				spEntity = samlRequestAttributes[2];
				spIssuerUrl = samlRequestAttributes[3];
				spTarget = samlRequestAttributes[4];
				providerName = samlRequestAttributes[5];
				assertionConsumerServiceURL = samlRequestAttributes[6];
				idpEntity = samlRequestAttributes[7];
				idpSsoUrl = samlRequestAttributes[8];
				uid = samlRequestAttributes[9];
			}
			
			
		}//func.f_NullCheck(SAMLRequest).equals("")
		
		response.setContentType("text/html; charset=UTF-8");
		if(!func.f_NullCheck(returnURL).equals("")){
			
			LOGGER.info("## SAML GATE WAY - SP Response ##");
			
			StringBuffer buf = new StringBuffer();
			buf.append("samlRedirect.do");
			buf.append("?SAMLResponse=");
			buf.append(RequestUtil.encodeMessage(signedSamlResponse));
			buf.append("&RelayState=");
			buf.append(URLEncoder.encode(relayState));
			buf.append("&uid=");
			buf.append(uid);
			buf.append("&acr=");
			buf.append(assertionConsumerServiceURL);
			returnURL =  buf.toString();
			
			RequestDispatcher  rd = request.getRequestDispatcher(returnURL);
			rd.forward(request, response);
		
		}else{
			if(func.f_NullCheck(key).equals("")){
				LOGGER.info("## SAML GATE WAY - No key Login ##");
				returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/login.do?SAMLRequest="+samlRequest+"&RelayState="+relayState+"&acr="+assertionConsumerServiceURL+"&uid="+uid;
				returnURL = returnURL.replaceAll("\r", "").replaceAll("\n", ""); //CLRF 대응
				response.sendRedirect(returnURL);
			}else{
				LOGGER.info("## SAML GATE WAY - No key Logout ##");
				returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/login.do?SAMLRequest="+samlRequest+"&RelayState="+relayState+"&acr="+assertionConsumerServiceURL+"&sop="+"Y"+"&uid="+uid;
				returnURL = returnURL.replaceAll("\r", "").replaceAll("\n", ""); //CLRF 대응
				response.sendRedirect(returnURL);
				
			}
			
		}
	}
	
	private boolean isMobile(HttpServletRequest request) {
        String userAgent = request.getHeader("user-agent");
        boolean mobile1 = userAgent.matches(".*(iPhone|iPod|iPad|Android|Windows CE|BlackBerry|Symbian|Windows Phone|webOS|Opera Mini|Opera Mobi|POLARIS|IEMobile|lgtelecom|nokia|SonyEricsson).*");
        boolean mobile2 = userAgent.matches(".*(LG|SAMSUNG|Samsung).*");
        if(mobile1 || mobile2) {
            return true;
        }
        return false;
    }
	
	/*
	 * Generates a SAML response XML by replacing the specified username on the
	 * SAML response template file. Returns the String format of the XML file.
	 */
	private String createSamlResponse(String authenticatedUser,
			String notBefore, String notOnOrAfter, String providerName,HttpServletRequest request,String id, String issuer,String uid, String destination, String assertionConsumerServiceURL) throws SamlException {
		String filepath =  request.getSession().getServletContext().getRealPath("WEB-INF/classes/security/"+samlResponseTemplateFile);
//		Thread-safe 대응
//		assertionID = Util.createID();
		
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
	
}