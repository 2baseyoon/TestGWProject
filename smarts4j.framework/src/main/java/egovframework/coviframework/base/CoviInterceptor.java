package egovframework.coviframework.base;

import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.io.BufferedReader;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.codec.binary.Base64;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.joda.time.DateTime;
import org.joda.time.Duration;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.web.servlet.AsyncHandlerInterceptor;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.support.RequestContextUtils;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.sec.AES;
import egovframework.baseframework.sec.Sha256;
import egovframework.baseframework.sec.Sha512;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.baseframework.util.LicenseHelper;
import egovframework.baseframework.util.LicenseBizHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.SessionService;
import egovframework.coviframework.util.AccessURLUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.coviframework.util.SessionCommonHelper;




import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import javax.crypto.spec.IvParameterSpec;

import java.security.MessageDigest;
import java.security.spec.KeySpec;

import org.apache.commons.codec.binary.Hex;
import org.apache.commons.lang3.StringEscapeUtils;

import java.util.LinkedHashMap;
public class CoviInterceptor implements AsyncHandlerInterceptor {
	
	@Autowired
	private SessionService sessionSvc;
	
	private Logger LOGGER = LogManager.getLogger(CoviInterceptor.class);
	
	private String adminServieURL;
	
	private final String[] EXCEPTEDURLS = new String[] { 
				"/layout/left.do", 
				"/layout/user/left.do",
				"/WEB-INF/views/layout/",
				"/WEB-INF/views/mobile/"	//모바일용 추가
			};
	
	//bean에서 제거 후 아래 코드 제거 할 것
	private Set<String> permittedURL;
	public void setPermittedURL(Set<String> permittedURL) {
	    this.permittedURL = permittedURL;
	}
	
	
	/* (non-Javadoc)
	 * @see org.springframework.web.servlet.handler.HandlerInterceptorAdapter#preHandle(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse, java.lang.Object)
	 * @description 항상 preHandle을 타게 됨
	 * 세션에 계정정보가 있는지 여부로 인증 여부를 체크한다.
	 * 계정정보가 없다면, 로그인 페이지로 이동한다.
	 */
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		try {
			
			long currentTime = System.currentTimeMillis();
			request.setAttribute("sTime", currentTime);
			String[] excludeParamArr = RedisDataUtil.getBaseConfig("excludeParam", "0").split(",");
		
			StringUtil func = new StringUtil();
			
			HttpSession session = request.getSession();
			
			Map<String, String> map = new HashMap<String, String>();
			
			String requestURI = request.getRequestURI();
			
			boolean ajax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
		
			//허용된 URL 처리
			if(AccessURLUtil.checkAccessURL(requestURI)){
				return true;
			}

		
			CookiesUtil cUtil = new CookiesUtil();
			
			TokenHelper tokenHelper = new TokenHelper();
			TokenParserHelper tokenParserHelper = new TokenParserHelper();
			
			String loginAuthType = PropertiesUtil.getSecurityProperties().getProperty("loginAuthType");
			String sendLogoutRedirectSSO = PropertiesUtil.getSecurityProperties().getProperty("sendLogoutRedirectSSO.Url");
			
			String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
			String aestokenkey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.token.key"));
			
			String key = "";
			String decodeKey = "";
			String ssoLogOut = "";
			String subDomain = "";
			String usrId = "";
			String domainID = "";
			String domainUrl = "";
			String licSeq = "";
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			if(!userDataObj.isEmpty()){
				subDomain = userDataObj.getString("SubDomain");
				ssoLogOut =  userDataObj.getString("DELETE");
				usrId =  userDataObj.getString("USERID");
				domainID =  userDataObj.getString("DN_ID");
				domainUrl =  userDataObj.getString("DN_URL");
				licSeq =  StringUtil.replaceNull(userDataObj.get("UR_LicSeq"),"");
				if ((StringUtil.replaceNull(PropertiesUtil.getSecurityProperties().getProperty("ip.login.used"),"").equals("Y") && !isMobile)
				 || (StringUtil.replaceNull(PropertiesUtil.getSecurityProperties().getProperty("ip.login.used.mobile"),"").equals("Y") && isMobile)
					){
					if (userDataObj.get("UR_LoginIP")!= null && !userDataObj.getString("UR_LoginIP").equals("") && !userDataObj.getString("UR_LoginIP").equals(func.getRemoteIP(request))){	//쿠키제거
						cUtil.removeCookies(response, request, key, "D", "N",userDataObj.get("SubDomain").toString());
						String sendRedirectSSO = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()+PropertiesUtil.getSecurityProperties().getProperty("sendRedirectSSO.Url");
						response.sendRedirect(sendRedirectSSO);
						return false;
					}
				}
			}
			
			
			//라이선스 체크 로직
			String sendRedirectLicenseCheck = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/license/licenseWarning.do";
			
			egovframework.baseframework.base.Enums.LicenseConfirmCode licenseConfirmCode;
			licenseConfirmCode  = LicenseBizHelper.checkLicense(request.getRequestURL().toString(), usrId, domainID, domainUrl, licSeq, false);

			switch(licenseConfirmCode) {
				case PeriodExpiration:
					sendRedirectLicenseCheck += "?licenseConfirmCode=PeriodExpiration";
					break;
				case PeriodLimit:
					sendRedirectLicenseCheck += "?licenseConfirmCode=PeriodLimit";
					break;
				case UnConfirmedDomain:
					sendRedirectLicenseCheck += "?licenseConfirmCode=UnConfirmedDomain";
					break;
				case UserCountLimit:
					sendRedirectLicenseCheck += "?licenseConfirmCode=UserCountLimit";
					break;
				default://라이선스 통과
					sendRedirectLicenseCheck = null;
					CoviMap userObj  = SessionHelper.getSession();
					if (!userObj.containsKey("UR_AssignedBizSection")){
						StringUtil.replaceNull(userDataObj.get("UR_LicSeq"),"");
						String isManage = "N";
						if (SessionHelper.getSession("isEasyAdmin").equals("Y")||SessionHelper.getSession("isAdmin").equals("Y")){
							isManage = "Y";
						}
						LicenseBizHelper.getAssignedBizSection(usrId, domainID, domainUrl, isManage); //통과한 부가 lisense정보 조회
					}	
					break;
			}
			sendLicenseMailDaily();
			
			if(sendRedirectLicenseCheck != null) {
				response.sendRedirect(sendRedirectLicenseCheck);
				return false;
			}
			
			String sendRedirectSSO = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()+PropertiesUtil.getSecurityProperties().getProperty("sendRedirectSSO.Url");
			
			// 1차 분기 - PC
			if(!isMobile){
				
				key = cUtil.getCooiesValue(request);
				
				if(func.f_NullCheck(key).equals("")){
					
					if (loginAuthType.equalsIgnoreCase("Unify")  
							&& request.getUserPrincipal() != null 
							&& func.f_NullCheck(request.getAuthType()).equalsIgnoreCase("SPNEGO")) 	 {
						
						 	usrId = request.getUserPrincipal().getName();
						 	String sLang = sessionSvc.selectUserLanguageCode(usrId);
						 
						 	CoviMap resultList = sessionSvc.checkAuthetication("SSO", usrId, "", sLang);
							// 웹페이지에서받은 아이디,패스워드 일치시 admin 세션key 생성
							String status = resultList.get("status").toString();
							CoviMap account = (CoviMap) resultList.get("account");
							
							//인증 성공 시
							if (!account.isEmpty() && func.f_NullCheck(status).equals("OK")) {
										
									String date = sessionSvc.checkSSO("DAY");
									String dn = sessionSvc.selectUserMailAddress(usrId);
									key = tokenHelper.setTokenString(account.get("LogonID").toString(), date, usrId, sLang, 
											 dn, account.get("DN_Code").toString(), account.get("UR_EmpNo").toString(), account.get("DN_Name").toString()
											 , account.get("UR_Name").toString(), account.get("UR_Mail").toString(), account.get("GR_Code").toString()
											 , account.get("GR_Name").toString(), account.get("Attribute").toString(), account.get("DN_ID").toString());
	
									String accessDate = tokenHelper.selCookieDate(date,"");
									cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());
									
								
								//세션 생성
								session.getServletContext().setAttribute(key, account.get("UR_ID").toString());
								
								session.setAttribute("USERID", account.get("UR_ID").toString());
								session.setAttribute("LOGIN", "Y");
								session.setAttribute("KEY", key);
								
								SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account, isMobile, key);
								
								LoggerHelper.connectLogger(account.get("UR_ID").toString(), account.get("UR_Code").toString(), account.get("LogonID").toString(), account.get("LanguageCode").toString());
							}else {
								LoggerHelper.connectFalseLogger(usrId,"LOGIN");
								response.sendError(HttpServletResponse.SC_FORBIDDEN);
								
								return false;
							}
						 
					} else {
						if(requestURI.indexOf("/mail") == 0) {
							response.setContentType("text/html; charset=UTF-8");
							try(PrintWriter out = response.getWriter();){
								out.println("<script language='javascript'>top.location.replace('" + sendRedirectSSO + "');</script>");
							}
						} else {
							if (ajax) {
								response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "NOSESSION");
							} else {
								response.sendRedirect(sendRedirectSSO);
							}
						}
						return false;
					 }
				}
				
				decodeKey = tokenHelper.getDecryptToken(key);
				
				if(func.f_NullCheck(decodeKey).equals("")){
					if(requestURI.indexOf("/mail") == 0) {
						response.setContentType("text/html; charset=UTF-8");
						try(PrintWriter out = response.getWriter();){
							out.println("<script language='javascript'>top.location.replace('" + sendRedirectSSO + "');</script>");
						}
					} else {
						if (ajax) {
							response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "NOSESSION");
						} else {
							response.sendRedirect(sendRedirectSSO);
						}
					}
					return false;
				}
				
				
				if (!func.f_NullCheck(usrId).equals("")) {
					// 일회성 세션 끊기
					// approval이랑 covicore 은 세션 유지(양식 및 조직도)
					if(SessionHelper.getSession("OneTimeLogon").equalsIgnoreCase("Y")
						&& requestURI.indexOf("/approval") == -1 && (requestURI.indexOf("/covicore") == -1 || requestURI.indexOf("/covicore/login.do") > -1)) {
						cUtil.removeCookies(response, request, key, "D", "N",subDomain);
						response.sendRedirect(sendLogoutRedirectSSO);
						return false;
					}else if(requestURI.indexOf("/passwordCompulsionChange") > -1 || requestURI.indexOf("/updateUserPassword.do") > -1){
						
					}else{
						String userPwChangeMD  = SessionHelper.getExtensionSession(usrId+"_PSM","UPCMD");
						
						if(func.f_NullCheck(userPwChangeMD).equals("Y")){
							response.sendRedirect(request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()+PropertiesUtil.getGlobalProperties().getProperty("privacy.secure.change.compulsion.url"));
							return false;
						}
					}
						
					if(!AccessURLUtil.checkAccessURLWithNoExtendExpireTime(requestURI)) {
						SessionHelper.setExpireTime(isMobile, key, response);
					}
				}else{
					//여기서 처리 필요
					cUtil.removeCookies(response, request, key, "D", "N",subDomain);
					if(requestURI.indexOf("/mail") == 0) {
						response.setContentType("text/html; charset=UTF-8");
						try(PrintWriter out = response.getWriter();){
							out.println("<script language='javascript'>top.location.replace('" + sendLogoutRedirectSSO + "');</script>");
						}
					} else {
						response.sendRedirect(sendLogoutRedirectSSO);
					}
					return false;
				}
				
			}else{//isMobile
				key = cUtil.getCooiesValue(request);
				
				//모바일
				if(request.getHeader("mobiletoken") != null){
					if(!AccessURLUtil.checkAccessURLWithNoExtendExpireTime(requestURI)) {
						SessionHelper.setExpireTime(isMobile, key, response);
					}
				}else if(!"".equals(func.f_NullCheck(key))){
					if(!AccessURLUtil.checkAccessURLWithNoExtendExpireTime(requestURI)) {
						SessionHelper.setExpireTime(isMobile, key, response);
					}
				}else{
					response.sendRedirect(sendRedirectSSO);
					return false;
				}
				
			}
			
			if (func.f_NullCheck(ssoLogOut).equals("Y")) {
				cUtil.removeCookies(response, request, key, "D", "Y",subDomain);
				return false;
			}
			
			//2차 분기 
			if(!isMobile){
				//세션 정보가 없으면
				if (func.f_NullCheck(usrId).equals("")) {
					
					if(func.f_NullCheck(key).equals("")){
						LOGGER.info("SSO TOKEN 없음",this);
						response.sendRedirect(sendRedirectSSO);
						return false;
						
					}else{
						LOGGER.info("TOKEN 있음",this);
						
						decodeKey = tokenHelper.getDecryptToken(key);
						
						map = tokenParserHelper.getSSOToken(decodeKey);
						
						String id = (String) map.get("id");
						String pw = (String) map.get("pw");
						String lang = (String) map.get("lang");
						
						request.setAttribute("id", id);
						request.setAttribute("password", pw);
						request.setAttribute("language", lang);
						
						//locale 정보 하드코딩을 제거 할 것.
						setLocale(request, response, lang);
						
						CoviMap resultList = new CoviMap();
						resultList = sessionSvc.checkAuthetication("SSO", id, pw, lang);
						
						String status = resultList.get("status").toString();
						CoviMap account = (CoviMap) resultList.get("account");
						
						//인증 성공 시
						if (func.f_NullCheck(status).equals("OK")) {
							//세션 생성
							session.getServletContext().setAttribute(key, account.get("UR_ID").toString());
							
							session.setAttribute("USERID", account.get("UR_ID").toString());
							session.setAttribute("LOGIN", "Y");
							session.setAttribute("KEY", key);
							
							SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account, isMobile, key);
						}
						
						return true;
					}
					
				}
				
			}else{
				
				//세션 정보가 없으면
				if (func.f_NullCheck(usrId).equals("")) {
					//모바일 자동로그인 처리 - 모바일이면서 header에 특정 정보가 있는 경우
				    if(request.getHeader("mobiletoken") != null){
						
						// 1. 헤더에서 mobiletoken 값 꺼내기 (ID|PWD|Lang|DeviceID|CreatDate|packagename)
			        	String _encryptMobileToken = request.getHeader("mobiletoken");
			        	
			        	AES aes = new AES(aeskey, "N");
			        	
			            // 2. 암호화된 모바일토큰 복호화
			        	String[] _decryptMobileToken = aes.decrypt(_encryptMobileToken).split("\\|");
			        	
			            String sUserId = _decryptMobileToken[0];
			            String sUserpwd = _decryptMobileToken[1];
			            String sLang = _decryptMobileToken[2];
			           // String sDeviceID = _decryptMobileToken[3];
			            String linfo = "";
			            if(_decryptMobileToken.length > 6) {
			            	linfo = _decryptMobileToken[6];
							
							if(!func.f_NullCheck(linfo).equals("")) {
								aes = new AES(aestokenkey, "N");
								linfo = aes.decrypt(linfo);
								
								sUserId = linfo.split("\\|")[1];
								sUserpwd = linfo.split("\\|")[2];
							}
			            }
			            
			            //yyyy-MM-dd_HHmmss
			            String[] splittedDate = _decryptMobileToken[4].split("_");
			            String sDate = splittedDate[0];
			            String sTime = splittedDate[1];
			            
			            String formattedTime = sTime.substring(0, 2) + ":" + sTime.substring(2, 4) + ":" + sTime.substring(4, 6);
			            
			            DateTimeFormatter formatter = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss");
			            DateTime dtCreateDate = formatter.parseDateTime(sDate + " " + formattedTime);
	            
			           // String sPackageName = _decryptMobileToken[5];
	
			            //계정 잠금여부 확인
			            int lockCount = sessionSvc.selectAccountLock(sUserId);
			    		
			    		if(lockCount > 0 ){
			    			if(ajax){
								response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "LOCK");	
							} else{						
								response.setContentType("text/html; charset=UTF-8");
					            try(PrintWriter out = response.getWriter();){
					            	out.println("<script language='javascript'>alert('계정이 잠금되었습니다. 관리자에 문의하시기 바랍니다.');location.replace('" + PropertiesUtil.getGlobalProperties().getProperty("MainPage.path") + "');</script>");
					            }
					            return false; 
							}
				            
			    			LoggerHelper.connectFalseLogger(sUserId,"LOCK");
			    			response.sendRedirect(sendRedirectSSO);
							return false;
			    		}
			            
			            // 3. 계정 체크
			            DateTime dtNow = new DateTime();
			            Duration dur = new Duration(dtCreateDate, dtNow);
			            long diffSeconds = dur.getStandardSeconds();
			            
			            String pId = sessionSvc.selectUserAuthetication(sUserId, sUserpwd) ;
			            
			            if (!"".equals(func.f_NullCheck(pId)) && diffSeconds < 60){
			            	//인증체크 로직 수행
							CoviMap resultList = sessionSvc.checkAuthetication("SSO", sUserId, sUserpwd, sLang);
							// 웹페이지에서받은 아이디,패스워드 일치시 admin 세션key 생성
							String status = resultList.get("status").toString();
							CoviMap account = (CoviMap) resultList.get("account");
							
							//인증 성공 시
							if (func.f_NullCheck(status).equals("OK")) {
										
								String date = sessionSvc.checkSSO("DAY");
								String dn = sessionSvc.selectUserMailAddress(sUserId);
								key = tokenHelper.setTokenString(account.get("LogonID").toString(), date, sUserpwd, sLang, 
										 dn, account.get("DN_Code").toString(), account.get("UR_EmpNo").toString(), account.get("DN_Name").toString()
										 , account.get("UR_Name").toString(), account.get("UR_Mail").toString(), account.get("GR_Code").toString()
										 , account.get("GR_Name").toString(), account.get("Attribute").toString(), account.get("DN_ID").toString());

								String accessDate = tokenHelper.selCookieDate(date,"");
									
								
								//세션 생성
								session.getServletContext().setAttribute(key, account.get("UR_ID").toString());
								
								session.setAttribute("USERID", account.get("UR_ID").toString());
								session.setAttribute("LOGIN", "Y");
								session.setAttribute("KEY", key);
								account.put("UR_LoginIP",func.getRemoteIP(request));
								
								SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account, isMobile, key);
								SessionHelper.setSession("lang", sLang, isMobile);
								setLocale(request, response, sLang);
								cUtil.setCookies(response, key, accessDate,account.get("SubDomain").toString());
								
								return true;
							}
			            }else{
			            	response.sendRedirect(sendRedirectSSO);
							return false;
			            }
					} else if(func.f_NullCheck(key).equals("")){
						
						if(func.f_NullCheck(key).equals("")){
							LOGGER.info("SSO TOKEN 없음",this);
							response.sendRedirect(sendRedirectSSO);
							return false;
							
						}else{
							LOGGER.info("TOKEN 있음",this);
							
							decodeKey = tokenHelper.getDecryptToken(key);
							
							map = tokenParserHelper.getSSOToken(decodeKey);
							
							String id = (String) map.get("id");
							String pw = (String) map.get("pw");
							String lang = (String) map.get("lang");
							
							request.setAttribute("id", id);
							request.setAttribute("password", pw);
							request.setAttribute("language", lang);
							
							//locale 정보 하드코딩을 제거 할 것.
							setLocale(request, response, lang);
							
							CoviMap resultList = new CoviMap();
							resultList = sessionSvc.checkAuthetication("SSO", id, pw, lang);
							
							String status = resultList.get("status").toString();
							CoviMap account = (CoviMap) resultList.get("account");
							
							//인증 성공 시
							if (func.f_NullCheck(status).equals("OK")) {
								//세션 생성
								session.getServletContext().setAttribute(key, account.get("UR_ID").toString());
								
								session.setAttribute("USERID", account.get("UR_ID").toString());
								session.setAttribute("LOGIN", "Y");
								session.setAttribute("KEY", key);
								
								SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account, isMobile, key);
							}
							
							return true;
						}
				    }else{
				    	if (func.f_NullCheck(usrId).equals("") && !func.f_NullCheck(key).equals("")) {
				    		decodeKey = tokenHelper.getDecryptToken(key);
				    								
				    		map = tokenParserHelper.getSSOToken(decodeKey);
				    						
				    		String id = (String) map.get("id");
				    		String pw = (String) map.get("pw");
				    		String lang = (String) map.get("lang");
				    								
				    		request.setAttribute("id", id);
				    		request.setAttribute("password", pw);
				    		request.setAttribute("language", lang);
				    								
				    		//locale 정보 하드코딩을 제거 할 것.
				    		setLocale(request, response, lang);
				    								
				    		CoviMap resultList = new CoviMap();
				    		resultList = sessionSvc.checkAuthetication("SSO", id, pw, lang);
				    								
				    		String status = resultList.get("status").toString();
				    		CoviMap account = (CoviMap) resultList.get("account");
				    								
				    		//인증 성공 시
				    		if (func.f_NullCheck(status).equals("OK")) {
				    			//세션 생성
				    			session.getServletContext().setAttribute(key, account.get("UR_ID").toString());
				    									
				    			session.setAttribute("USERID", account.get("UR_ID").toString());
				    			session.setAttribute("LOGIN", "Y");
				    			session.setAttribute("KEY", key);
				    									
				    			SessionCommonHelper.makeSession(account.get("UR_ID").toString(), account, isMobile, key);
				    		}				    		
				    		
				    		return true;				    		
				    	}				    	
				    }
				}
			}
			
			userDataObj = SessionHelper.getSession(isMobile, key);
			
			//세션 정보가 있으면
			if(!userDataObj.isNullObject() && userDataObj.has("lang")) {
				setLocale(request, response, userDataObj.getString("lang"));
			}
			
			
			/*
			 * [관리자 접근 권한 check]
			 *  로그인 시 UserCode_PSM 내 CSA_SC는 'N'
			 *  인증(관리자 기본 페이지 접근) 시   CSA_SC 값 'Y'로 변경
			 *  관리자 접근 권한 없을 경우 접근 권한 인증만료로 403 페이지 이동
			 *  
			 *  accessURL 에는 관리자 페이지 등록 금지
			 *  
			 */
			if(!ClientInfoHelper.isMobile(request) && !func.f_NullCheck(PropertiesUtil.getSecurityProperties().getProperty("admin.auth.type")).equalsIgnoreCase("N")){
				
				if(func.f_NullCheck(adminServieURL).equals("")){
					for (Iterator<String> it = this.permittedURL.iterator(); it.hasNext();) {
						adminServieURL = (String) it.next();
						adminServieURL = new String(Base64.decodeBase64(adminServieURL.getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
					}
				}
				
				if( func.f_NullCheck(request.getParameter("CLMD")).equals("admin") || adminServieURL.indexOf(requestURI) > -1){
					String isAdmin = SessionHelper.getSession("isAdmin");
					
					if(func.f_NullCheck(isAdmin).equals("Y")){
						
						String cTempValue = SessionHelper.getExtensionSession(SessionHelper.getSession("USERID")+"_PSM","TEMP");
						String adminAuthEnc = Sha512.encrypt("|"+SessionHelper.getSession("USERID")+"|"+cTempValue+"|"+"Y"+"|");
	
						//파라미터 값 비교.
						if(func.f_NullCheck(adminAuthEnc).equals(request.getParameter("CSA_SC"))){
							String adminContext = RedisDataUtil.getBaseConfig("AdminBaseContext");
							
							//인증 여부 확인.
							if(adminContext.indexOf(requestURI) > -1){
								SessionHelper.setExtensionSession(SessionHelper.getSession("USERID")+"_PSM","CSA_SC", "Y");
							}else{
								String csaSC = SessionHelper.getExtensionSession(SessionHelper.getSession("USERID")+"_PSM", "CSA_SC");
								if(!"Y".equals(func.f_NullCheck(csaSC))){
									//에러페이지로 이동.
									response.sendError(HttpServletResponse.SC_FORBIDDEN, "NOAUTH");
									
									// 권한 오류 로그
									LoggerHelper.authErrorLogger(requestURI, "NOAUTH", "", "", "Auth unauthorized : Administrator authentication expiration", "");
									return false;
								}
							}
						}else{
							String csaSC = SessionHelper.getExtensionSession(SessionHelper.getSession("USERID")+"_PSM", "CSA_SC");
							if(!"Y".equals(func.f_NullCheck(csaSC))){
								//에러페이지로 이동.
								response.sendError(HttpServletResponse.SC_FORBIDDEN, "NOAUTH");
								
								// 권한 오류 로그
								LoggerHelper.authErrorLogger(requestURI, "NOAUTH", "", "", "Auth unauthorized : Administrator authentication expiration", "");
								return false;
							}
						}
					}else{
						response.sendError(HttpServletResponse.SC_FORBIDDEN, "NOAUTH");
						
						// 권한 오류 로그
						LoggerHelper.authErrorLogger(requestURI, "NOAUTH", "", "", "Auth unauthorized : Administrator only access", "");
						return false;
					}
				}
			}
			
			/*url 접근 제한  접근 url에 대한 권한을 체크*/
			if (!userDataObj.getString("isAdmin").equals("Y") && request.getParameter("CLMD")!= null && request.getParameter("CLMD").equals("admin")){ // 관리자가 아닌데 관리자 페이지 접근 시
            	String redirectURL = "/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal&exceptionType=NoAuth";
				response.sendRedirect(redirectURL);
				
				// 권한 오류 로그
				LoggerHelper.authErrorLogger(requestURI, "NOAUTH", "", "", "Auth unauthorized : Administrator only access", "");
				return false;
			}
			
			if (StringUtil.replaceNull(PropertiesUtil.getSecurityProperties().getProperty("param.valid"),"N").equals("Y") 
					&& request.getHeader("CSA_SM") != null && !request.getHeader("CSA_SM").equals("")){
				try{
					String queryString = request.getHeader("CSA_SM");
					String ciphertext = queryString; 
			        String passPhrase = SessionHelper.getSession("UR_PrivateKey");
			        
			        int keySize=128;
			        int iterationCount=1000;
			        String salt = "18b00b2fc5f0e0ee40447bba4dabc123"; 
			        String iv = "4378110db6392f93e95d5159dabde123";
			        		
			        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
			        KeySpec spec = new PBEKeySpec(passPhrase.toCharArray(), Hex.decodeHex(salt.toCharArray()), iterationCount, keySize);
			        SecretKey key2 = new SecretKeySpec(factory.generateSecret(spec).getEncoded(), "AES");        
			        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
			        cipher.init(Cipher.DECRYPT_MODE, key2, new IvParameterSpec(Hex.decodeHex(iv.toCharArray())));        
			        byte[] decrypted = cipher.doFinal(Base64.decodeBase64(ciphertext));        
			        String decryptstr= new String(decrypted, "UTF-8");

				    Map<String, String> query_pairs = new LinkedHashMap<String, String>();
				    if (request.getContentType().toLowerCase().contains("application/json")){
				    	BufferedReader reader = request.getReader();
				    	StringBuilder bodyBuilder = new StringBuilder();
				    	bodyBuilder.append(reader.readLine());
				    	String bodyStr = bodyBuilder.toString();
				    	reader.close();
			            
				    	if (!decryptstr.equals(Sha256.encrypt(bodyStr))){
				    		if (!isMobile && (request.getHeader("AJAX") == null || !request.getHeader("AJAX").equals("true"))){
				            	String redirectURL = "/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal";
								response.sendRedirect(redirectURL);
							}	else {
								response.sendError(HttpServletResponse.SC_FORBIDDEN);
							}	
							return false;
				    	}
				    }else{
					    String[] pairs = decryptstr.split("††");
					    for (String pair : pairs) {
					        int idx = pair.indexOf("||");
					        String paramKey = pair.substring(0, idx);
					        String paramVal =  pair.substring(idx + 2);
					        if (paramVal.equalsIgnoreCase("null")){
					        	paramVal = "";
					        }
					        String reqParamVal = (request.getParameter(paramKey) == null 
					        						|| "null".equals(request.getParameter(paramKey))
					        						|| "undefined".equals(request.getParameter(paramKey)) )
					        					? "" : 	request.getParameter(paramKey);
					        String headerParamval = paramVal.equals("undefined")?"":paramVal;
					        if (!Arrays.asList(excludeParamArr).contains(paramKey)
					        	&& !reqParamVal.equals("") 
					        	&& !headerParamval.equals(Sha256.encrypt(reqParamVal))
						        && !headerParamval.equals(Sha256.encrypt(StringEscapeUtils.unescapeHtml4(reqParamVal)))
						        && !headerParamval.equals(Sha256.encrypt(java.net.URLEncoder.encode(reqParamVal, "UTF-8")))
					        		){
					        	if (!isMobile && (request.getHeader("AJAX") == null || !request.getHeader("AJAX").equals("true"))){
					            	String redirectURL = "/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal";
									response.sendRedirect(redirectURL);
								}	else {
									response.sendError(HttpServletResponse.SC_FORBIDDEN); 
								}	
								return false;
					        }
					    }
				    }    
				} catch(NullPointerException e){	
			    	if (!isMobile && (request.getHeader("AJAX") == null || !request.getHeader("AJAX").equals("true"))){
		            	String redirectURL = "/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal";
						response.sendRedirect(redirectURL);
					}	else {
						response.sendError(HttpServletResponse.SC_FORBIDDEN);
					}	
					return false;
				} catch(Exception e) {
			    	if (!isMobile && (request.getHeader("AJAX") == null || !request.getHeader("AJAX").equals("true"))){
		            	String redirectURL = "/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal";
						response.sendRedirect(redirectURL);
					}	else {
						response.sendError(HttpServletResponse.SC_FORBIDDEN);
					}	
					return false;
				}
			}	
			
			if( !filterPageMove(requestURI) ){
				if (!CoviAuthUtil.getMenuAuth(requestURI, request.getQueryString(), request)){
					if (!isMobile && (request.getHeader("AJAX") == null || !request.getHeader("AJAX").equals("true"))){
		            	String redirectURL = "/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal&exceptionType=NoAuth";
						response.sendRedirect(redirectURL);
					}	else {
						response.sendError(461,"NOAUTH"); 
					}					
					return false;
				}	
			}	

		} catch(NullPointerException e){	
			LoggerHelper.errorLogger(e, "egovframework.coviframework.base.CoviInterceptor.preHandle", "RUN");
			return false;
		}catch(Exception e) {
			LoggerHelper.errorLogger(e, "egovframework.coviframework.base.CoviInterceptor.preHandle", "RUN");
			return false;
		}
		
		return true;
		
	}
	
	/**
	 * @param request
	 * @param response
	 * @throws Exception
	 * @description 최종 방문 페이지 정보 쿠키 저장
	 */
	private void setLastVisitPage(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String lastVisitedPage = request.getRequestURI();
		if (request.getQueryString() != null) {
			lastVisitedPage += "?"+ request.getQueryString();
			lastVisitedPage = lastVisitedPage.replaceAll("\r", "").replaceAll("\n", ""); //CLRF 대응
		}
		
		Cookie cookie = new Cookie("LastVisitedPage",lastVisitedPage);
		cookie.setMaxAge(60 * 5);
		cookie.setPath("/");
		response.addCookie(cookie);
	}
	
	/**
	 * @param request
	 * @param response
	 * @param lang
	 * @throws Exception
	 * @description 지역별 언어설정
	 */
	private void setLocale(HttpServletRequest request, HttpServletResponse response, String lang) throws Exception{
		Locale commonLoc = null;
		// locale 설정
		switch (lang) {
		case "ko":
			commonLoc = new Locale("ko", "KR");
			break;
		case "en":
			commonLoc = new Locale("en", "US");
			break;
		case "ja":
			commonLoc = new Locale("ja", "JP");
			break;
		case "zh":
			commonLoc = new Locale("zh", "CN");
			break;
		case "e1":
			commonLoc = new Locale("e1", "E1");
			break;
		case "e2":
			commonLoc = new Locale("e2", "E2");
			break;
		case "e3":
			commonLoc = new Locale("e3", "E3");
			break;
		case "e4":
			commonLoc = new Locale("e4", "E4");
			break;
		case "e5":
			commonLoc = new Locale("e5", "E5");
			break;
		case "e6":
			commonLoc = new Locale("e6", "E6");
			break;
		default:
			commonLoc = new Locale("ko", "KR");
			break;
		}
		

		Locale localLoc = LocaleContextHolder.getLocale();

		// redis에 저장된 locale 정보와 현재 컨텍스트 상의 locale 정보를 비교하여 다른
		// 경우
		// redis에 저장된 locale 정보로 setLocale
		if (!commonLoc.equals(localLoc)) {
			LocaleResolver localeResolver = RequestContextUtils.getLocaleResolver(request);
			localeResolver.setLocale(request, response, commonLoc);
		}
	}
	
	
	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object obj, ModelAndView modelandview) throws Exception {
		String requestURI = request.getRequestURI();
		boolean isMobile = ClientInfoHelper.isMobile(request);
		String domainName = request.getServerName();
		
		if(modelandview != null && !filterPageMove(requestURI)){
			setLastVisitPage(request,response);
			
			LoggerHelper.pageMoveLoggerForSQL(requestURI);	
		}
		
		String mobileDomainPCService = RedisDataUtil.getBaseConfig("MobileDomainPCService", isMobile);
		
		if(mobileDomainPCService.equalsIgnoreCase("DENY")) {
			String mobileDomain = RedisDataUtil.getBaseConfig("MobileDomain", isMobile);
			String commonServiceURL = RedisDataUtil.getBaseConfig("CommonServiceURL", isMobile);
			
			if(mobileDomain.equalsIgnoreCase(domainName)
					&& modelandview != null && !requestURI.equals("")) {
				ArrayList<String> paths = new ArrayList<String>(Arrays.asList(requestURI.split("/")));
				ArrayList<String> serviceURL = new ArrayList<String>(Arrays.asList(commonServiceURL.split("/")));
				
				if(!paths.contains("mobile") && !serviceURL.contains(requestURI)) {
					response.setContentType("text/html; charset=UTF-8");
		            try(PrintWriter out = response.getWriter();){
		            	out.println("<script language='javascript'>alert('해당 도메인으로 접근할 수 없는 서비스입니다.');location.replace('/');</script>");
		            }
				}
			}
		}
		
		if(modelandview != null && "Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isDevMode"))) {
			LOGGER.info("JSP : " + modelandview.getViewName() + "(.jsp)");
		}
	}
	
    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {

    	String requestURI = request.getRequestURI();
    	//성능 로그 쌓을 지 여부 세팅
		if("Y".equals(PropertiesUtil.getGlobalProperties().getProperty("performance.log.used")) && !filterPageMove(requestURI)){
	    	long currentTime = System.currentTimeMillis();
	    	long startTime =(long)request.getAttribute("sTime");
	    	long prossTime = currentTime - startTime;
	    	
	    	LoggerHelper.perfomanceLogger(requestURI,"",String.valueOf(prossTime));	
		}	
    }

    
	/**
	 * @param url
	 * @return
	 * @description 페이지 레이아웃 정책에 기반한 페이지 호출 가능 여부 체크
	 */
	private boolean filterPageMove(String url){
		boolean hasUrl = false;
		
		for (String s : EXCEPTEDURLS) {
			if(url.contains(s)){
				hasUrl = true;
			}
		}
		
		return hasUrl;
	}
	
	private void sendLicenseMailDaily(){
		String senderMail = PropertiesUtil.getGlobalProperties().getProperty("SenderErrorMail");
		
		try {
			CoviMap mailInfo = LicenseHelper.getLicenseMaliDailyList();
			
			while(mailInfo != null) {
				String receiverMail =  LicenseHelper.getLicenseAdmins(mailInfo.getString("domainID"));
				
				if(StringUtil.isNotNull(receiverMail)) {
					MessageHelper.getInstance().sendSMTP("CoviLicenseChecker", senderMail, receiverMail, mailInfo.getString("mailSubject"), mailInfo.getString("mailContext"), true);
				}
				
				mailInfo = LicenseHelper.getLicenseMaliDailyList();
			}
		} catch(NullPointerException e){	
			LOGGER.error("라이선스 체크 알림 발송 중 에러 발생", e);
		} catch (Exception e) {
			LOGGER.error("라이선스 체크 알림 발송 중 에러 발생", e);
		}
	}
	
	
}
