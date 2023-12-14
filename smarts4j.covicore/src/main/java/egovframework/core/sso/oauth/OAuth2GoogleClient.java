package egovframework.core.sso.oauth;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;



import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mortbay.log.Log;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.HttpServletRequestHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.SsoOauthSvc;
import egovframework.coviframework.util.HttpClientUtil;


@Controller
public class OAuth2GoogleClient {

	private Logger LOGGER = LogManager.getLogger(OAuth2GoogleClient.class);
	
	@Autowired
	private SsoOauthSvc ssoOauthSvc;
	
	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");
	
	@RequestMapping(value = "oauth2/client/auth.do")
	public ModelAndView authorize(HttpServletResponse response,	HttpServletRequest request) throws Exception{
		ModelAndView mav = new ModelAndView();
		StringUtil func = new StringUtil();
		
		SessionHelper.setExpireTime();
		String userId = SessionHelper.getSession("USERID");
		
		String returnURL = "";
		String mail = request.getParameter("email");
		String callurl = request.getParameter("callurl");
		
		if(func.f_NullCheck(userId).equals("")){
			mav.addObject("message_b", OAuth2ErrorConstant.ERROR_SESSION);
			mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
			returnURL = "oauthException";
			mav.setViewName(returnURL);
			return mav;
		}else{
			if(func.f_NullCheck(mail).equals("")){
				mav.addObject("message_b", OAuth2ErrorConstant.ERROR_PARAMETER);
				mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
				returnURL = "oauthException";
				mav.setViewName(returnURL);
				return mav;
			}/*else{
				
				if(ssoOauthSvc.selectTokenCnt(userId) > 0){
					//update
					if(!ssoOauthSvc.updateUserTokenInfo(userId, mail)){
						mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
						mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
						returnURL = "oauthException";
						mav.setViewName(returnURL);
						return mav;
					}
					
				}else{
					//add
					if(!ssoOauthSvc.insertUserTokenInfo(userId, mail)){
						mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
						mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
						returnURL = "oauthException";
						mav.setViewName(returnURL);
						return mav;
					}
				}
				
			}*/
			
		}
		
		String state = OAuth2Util.generateRandomState();
	
		mav.addObject("client_id", ssoOauthSvc.getValue("sso_goclient_id"));
		mav.addObject("redirect_uri", ssoOauthSvc.getValue("sso_redirect_url"));
		mav.addObject("scope", "https://www.googleapis.com/auth/calendar");
		mav.addObject("approval_prompt", "force");
		mav.addObject("access_type", "offline");
		mav.addObject("response_type", "code");
		mav.addObject("state", state);
		
		HttpSession session = request.getSession();
		session.setAttribute("state", state);
		session.setAttribute("callurl", callurl);
		session.setAttribute("googleMail", mail);
		
		returnURL = "redirect:"+ ssoOauthSvc.getValue("sso_goauthorize_url");
		mav.setViewName(returnURL);
		return mav;
	}
	
	@RequestMapping(value = "oauth2/client/callback.do")
	public ModelAndView authorizeCallback(HttpServletResponse response,	HttpServletRequest request) throws Exception{
		ModelAndView mav = new ModelAndView();
		HttpSession session = request.getSession();
		StringUtil func = new StringUtil();
		
		String returnURL = "";
		String code = request.getParameter("code");
		String state = request.getParameter("state");
		String prevState = (String)session.getAttribute("state");
		String mail = (String)session.getAttribute("googleMail");
		SessionHelper.setExpireTime();
		String userId = SessionHelper.getSession("USERID");
		
		if(func.f_NullCheck(userId).equals("")){
			mav.addObject("message_b", OAuth2ErrorConstant.ERROR_SESSION);
			mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
			returnURL = "oauthException";
			mav.setViewName(returnURL);
			return mav;
		}
		
		if (!StringUtil.replaceNull(state).equals(prevState)) {
			mav.addObject("message_b", "CSRF(Cross Site Request Forgery)");
			mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
			returnURL = "oauthException";
			mav.setViewName(returnURL);
			return mav;
		}else{
			String clientId = ssoOauthSvc.getValue("sso_goclient_id");
			String clientSecret = ssoOauthSvc.getValue("sso_goclient_key");
			String redirectUri = ssoOauthSvc.getValue("sso_redirect_url");
			
			String url = ssoOauthSvc.getValue("sso_goaccess_url");
			
			CoviMap resultList = new CoviMap();
			
			HttpClientUtil httpClient = new HttpClientUtil();
			
			NameValuePair[] data = {
				    new NameValuePair("code", code),
				    new NameValuePair("client_id", clientId),
				    new NameValuePair("client_secret", clientSecret),
				    new NameValuePair("redirect_uri", redirectUri),
				    new NameValuePair("grant_type", "authorization_code"),
				    new NameValuePair("access_type", "offline")
		    };
			
			resultList = httpClient.httpClientConnect(url, "furl", "POST", data, 6);
			
			int status = (int) resultList.get("status");
			String body =  resultList.get("body").toString();
			AccessTokenVO token = OAuth2ClientUtil.getObjectFromJSON(body, AccessTokenVO.class);
			
			if (status == 200) {
				
				if(ssoOauthSvc.selectTokenCnt(userId) > 0){
					//update
					if(!ssoOauthSvc.updateUserTokenInfo(userId, mail)){
						mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
						mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
						returnURL = "oauthException";
						mav.setViewName(returnURL);
						return mav;
					}else{
						if(!ssoOauthSvc.updateRefreshToken(token, userId)){
							mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
							mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
							returnURL = "oauthException";
							mav.setViewName(returnURL);
							return mav;
						}
					}
					
				}else{
					//add
					if(!ssoOauthSvc.insertUserTokenInfo(userId, mail)){
						mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
						mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
						returnURL = "oauthException";
						mav.setViewName(returnURL);
						return mav;
					}else{
						if(!ssoOauthSvc.updateRefreshToken(token, userId)){
							mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
							mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
							returnURL = "oauthException";
							mav.setViewName(returnURL);
							return mav;
						}
					}
				}
				
				mav.addObject("state", "success");
				returnURL = "redirect:"+(String)session.getAttribute("callurl");
				mav.setViewName(returnURL);
				
			/*	mav.addObject("json", OAuth2Util.getJSONFromObject(token));
				returnURL = "json";
				mav.setViewName(returnURL);*/
			}else{
				mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
				mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
				returnURL = "oauthException";
				mav.setViewName(returnURL);
				return mav;
			}
			
		}
		
		return mav;
	}
	
	/**
	 * 구글 Rest API 호출
	 * @param request
	 * @param url
	 * @param type
	 * @param params
	 * @param userCode
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "oauth2/client/callGoogleRestAPI.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap googleRestAPI(HttpServletRequest request) throws Exception
	{
		CoviMap returnObj = new CoviMap();
		
		CoviMap resultList = new CoviMap();
		
		StringUtil func = new StringUtil();
		
		HttpClientUtil httpClient = new HttpClientUtil();
		
		String url = "";
		String type = "";
		String params = "";
		String userCode = "";
		
		if(request.getParameter("url") != null){
			url = request.getParameter("url");
			type = request.getParameter("type");
			params = request.getParameter("params");
			userCode = request.getParameter("userCode");
		}else{
			CoviMap paramMap = CoviMap.fromObject(HttpServletRequestHelper.getBody(request));
			
			url = paramMap.get("url").toString();
			type = paramMap.get("type").toString();
			params = paramMap.get("params").toString();
			userCode = paramMap.get("userCode").toString();
		}
		
		try{
			if(StringUtil.replaceNull(type).equals("REFLASH")){
				
				if(ssoOauthSvc.selectGoogleTokenNotToUseCount(userCode) < 1 ){
					Log.info("###### REFLASH Token NOT USED - " + userCode);
					return returnObj;
				}
				
			}
			
			
			CoviMap paramsObj = CoviMap.fromObject(StringEscapeUtils.unescapeHtml(StringEscapeUtils.unescapeHtml(params)));
			String body = "{}";
			int status = 404;
			
			// 구글 Oauth 계정 조회
			long oauthTimer = ssoOauthSvc.selectGoogleTokenByExpires(userCode);
			
			// Token 가져오기
			String token = "";
			if(oauthTimer < 1 ){
			
				String clientId = ssoOauthSvc.getValue("sso_goclient_id");
				String clientSecret = ssoOauthSvc.getValue("sso_goclient_key");
				String goaccessUrl = ssoOauthSvc.getValue("sso_goaccess_url");
				CoviMap oauthList = new CoviMap();
				String refreshToken =  ssoOauthSvc.selectGoogleRefreshTokenByUserCode(userCode);
				NameValuePair[] data = {
					    new NameValuePair("client_id", clientId),
					    new NameValuePair("client_secret", clientSecret),
					    new NameValuePair("refresh_token", refreshToken),
					    new NameValuePair("grant_type", "refresh_token")
			    };
				
				oauthList = httpClient.httpClientConnect(goaccessUrl, "furl", "POST", data, 4);
				int oauthStatus = (int) oauthList.get("status");
				String oauthBody =  oauthList.get("body").toString();
				
				if (oauthStatus == 200) {
					AccessTokenVO tokenVo = OAuth2ClientUtil.getObjectFromJSON(oauthBody, AccessTokenVO.class);
					tokenVo.setRefresh_token(refreshToken);
					if(ssoOauthSvc.selectTokenCnt(userCode) > 0){
						//ADD
						if(ssoOauthSvc.updateRefreshToken(tokenVo, userCode)){
							token = tokenVo.getAccess_token();
						}else{
							//ERROR
							Log.info("###### Token update Error");
						}
					}else{
						//ERROR
						Log.info("###### Token Count Error");
					}
				}else{
					//ERROR
					Log.info("###### Token http error ");
				}
				
				if(func.f_NullCheck(token).equals("")){
					// ERROR 방지
					token = ssoOauthSvc.selectGoogleTokenByUserCode(userCode);
				}
				
			}else{
				token = ssoOauthSvc.selectGoogleTokenByUserCode(userCode);
			}
			
			String authHeader  = OAuth2ClientUtil.generateBearerTokenHeaderString(token);
			
			if(StringUtil.replaceNull(type).equals("POST")){
				// 파라미터 세팅 paramObj.toString() 사용하므로 미사용 코드 삭제. 
				resultList = httpClient.httpRestAPIConnect(url, "json", type, paramsObj.toString(), authHeader);
				
				status = (int) resultList.get("status");
				body = (String) resultList.get("body");
						
			}else if(StringUtil.replaceNull(type).equals("GET")){
				StringBuilder paramStr = new StringBuilder();
				if(!paramsObj.isEmpty()){
					paramStr.append("?");
					Iterator<?> keys = paramsObj.keys();
	
					while (keys.hasNext()) {
						String key = (String) keys.next();
						if(paramStr.length() > 1) {
							paramStr.append("&");
						}
						paramStr.append(key)
							.append("=")
							.append(paramsObj.getString(key))
							;
							
					}
				}
				
				resultList = httpClient.httpRestAPIConnect(url + paramStr.toString(), "", type, "", authHeader);
				
				status = (int) resultList.get("status");
				body = (String) resultList.get("body");
				
			}else if(StringUtil.replaceNull(type).equals("DELETE")){
				
				resultList = httpClient.httpRestAPIConnect(url, "", type, "", authHeader);
				
				status = (int) resultList.get("status");
				
			}else if(StringUtil.replaceNull(type).equals("PUT")){
				
				resultList = httpClient.httpRestAPIConnect(url, "json", type, paramsObj.toString(), authHeader);
				
				status = (int) resultList.get("status");
				
			}else if(StringUtil.replaceNull(type).equals("REFLASH")){
				status = 202;
			}
			
			returnObj.put("data", CoviMap.fromObject(body));
			returnObj.put("status", status);
		} catch (NullPointerException e) {
			LOGGER.error("OAuth2GoogleClientCon", e);
			returnObj.put("IsError", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		} catch (Exception e) {
			LOGGER.error("OAuth2GoogleClientCon", e);
			returnObj.put("IsError", Return.FAIL);
			returnObj.put("message", isDevMode.equalsIgnoreCase("Y")?e.getMessage():DicHelper.getDic("msg_apv_030"));
		}
		
		return returnObj;
	}
	
	@RequestMapping(value = "oauth2/client/saveGoogleMail.do")
	public @ResponseBody CoviMap saveGoogleMail(HttpServletResponse response,	HttpServletRequest request) throws Exception{
		CoviMap returnObj = new CoviMap();
		StringUtil func = new StringUtil();
		
		String userId = SessionHelper.getSession("USERID");
		String mail = request.getParameter("email");
				
		if(ssoOauthSvc.selectTokenCnt(userId) > 0){
			//update
			if(!ssoOauthSvc.updateUserTokenInfo(userId, mail)){
				returnObj.put("state", Return.FAIL);
			}
					
		}else{
			//add
			if(!ssoOauthSvc.insertUserTokenInfo(userId, mail)){
				returnObj.put("state", Return.FAIL);
			}
		}
					
		returnObj.put("state", Return.SUCCESS);
		return returnObj;
	}
	
	
}
