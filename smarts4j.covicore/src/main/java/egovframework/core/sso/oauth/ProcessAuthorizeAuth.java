package egovframework.core.sso.oauth;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;



import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.CookiesUtil;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.sevice.SsoOauthSvc;

@Controller
public class ProcessAuthorizeAuth {
	private Logger LOGGER = LogManager.getLogger(ProcessAuthorizeAuth.class);
	
	@Autowired
	private SsoOauthSvc ssoOAuthsvc;
	
	@Autowired
	private OAuth2AccessTokenService tokenService;
	
	@RequestMapping(value = "oauth2/auth.do", method = RequestMethod.GET)
	public ModelAndView authorize(RequestAuthVO vo, HttpServletResponse response,
			HttpServletRequest request){
		
		ModelAndView mav = new ModelAndView();
		StringUtil func = new StringUtil();
		CookiesUtil cUtil = new CookiesUtil();
		
		HttpSession session = request.getSession();
		
		String key = "";
		String returnURL = "oauthException";
		
		boolean isloginned = false;
		
		if ("1".equals(PropertiesUtil.getSecurityProperties().getProperty("sso.type"))) {
			key = cUtil.getCooiesValue(request);
		}
		
		if(!"".equals(key)){
			SessionHelper.setExpireTime();
			
			String usrId = SessionHelper.getSession("USERID");
			
			if (!func.f_NullCheck(usrId).equals("")) {
				mav.addObject("isloginned", true);
				isloginned = true;
			}else{
				mav.addObject("isloginned", false);
			}
		}else{
			mav.addObject("isloginned", false);
		}
		
		CoviMap resultList = new CoviMap();
	
		try {
			resultList = ssoOAuthsvc.getClientOne(vo.getClient_id());
		} catch (NullPointerException e) {
			mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
			mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
		} catch (Exception e) {
			mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
			mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
		}
		
		CoviMap account = (CoviMap) resultList.get("account");
		
		if (account.size() < 1 || func.f_NullCheck(account.get("client_id").toString()).equals("")) {
			
			mav.addObject("message_b", OAuth2ErrorConstant.UNAUTHORIZED_CLIENT);
			mav.addObject("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
			
		}
		
		if (!vo.getResponse_type().equals(OAuth2Constant.RESPONSE_TYPE_CODE) && 
			!vo.getResponse_type().equals(OAuth2Constant.RESPONSE_TYPE_TOKEN)	) {
			
			mav.addObject("message_b", OAuth2ErrorConstant.UNSUPPORTED_RESPONSE_TYPE);
			mav.addObject("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
		}
		
		if (!OAuth2Scope.isScopeValid(vo.getScope(),func.f_NullCheck(account.get("scope").toString())) && !func.f_NullCheck(account.get("scope").toString()).equals("")){
			
			mav.addObject("message_b", OAuth2ErrorConstant.INVALID_SCOPE);
			mav.addObject("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
		}
		
		String gt = vo.getResponse_type();
		
		if (!gt.equals(OAuth2Constant.RESPONSE_TYPE_CODE) 
				&& !gt.equals(OAuth2Constant.RESPONSE_TYPE_TOKEN)) {
			mav.addObject("message_b", OAuth2ErrorConstant.UNSUPPORTED_RESPONSE_TYPE);
			mav.addObject("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR);
		}
		
		if(isloginned){
			returnURL = "oauthAuthority";
			mav.addObject("redirecturi", vo.getRedirect_uri());
			mav.addObject("scope", vo.getScope()+",");
			mav.addObject("currenturl", "/covicore/oauth2/auth.do?"+request.getQueryString());
			mav.addObject("clientname",account.get("client_name").toString());
			mav.setViewName(returnURL);
		}else{
			returnURL = "oauth2Login";
			mav.addObject("redirecturi", vo.getRedirect_uri());
			mav.addObject("scope", vo.getScope()+",");
			mav.addObject("currenturl","/covicore/oauth2/auth.do?"+request.getQueryString());
			mav.addObject("clientname",account.get("client_name").toString());
			mav.setViewName(returnURL);
		}
		
		return mav;
	}
	
	//사용자가 승인 또는 거부 버튼을 클릭하는 경우
	@RequestMapping(value = "oauth2/auth.do", method = RequestMethod.POST)
	public ModelAndView authorizePost(Model model, RequestAuthVO rVO, HttpServletRequest request, HttpServletResponse response){
		
		StringUtil func = new StringUtil();
		CookiesUtil cUtil = new CookiesUtil();
		
		ModelAndView mav = new ModelAndView();
		CoviMap userResultList = new CoviMap();
		CoviMap clientResultList = new CoviMap();
		
		
		HttpSession session = request.getSession();
		
		String key = "";
		String returnURL = "oauthException";
		String isAllow = request.getParameter("isallow");
			
		if (!func.f_NullCheck(isAllow).equals("true")) {
			returnURL = "oauth2LoginError";
			mav.setViewName(returnURL);
			return mav;
			
		}
			
		if ("1".equals(PropertiesUtil.getSecurityProperties().getProperty("sso.type"))) {
			key = cUtil.getCooiesValue(request);
		}else{
			key = session.getId();
		}
		
		if(!"".equals(key)){
			
			SessionHelper.setExpireTime();
			String usrId = SessionHelper.getSession("USERID");
			
			try {
				userResultList = ssoOAuthsvc.getUserInfo(usrId);
			} catch (NullPointerException e) {
				mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
				mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
				
				mav.setViewName(returnURL);
				return mav;
			} catch (Exception e) {
				mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
				mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
				
				mav.setViewName(returnURL);
				return mav;
			}
		}else{
			mav.addObject("message_b", OAuth2ErrorConstant.UNAUTHORIZED_CLIENT);
			mav.addObject("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
		}
		
		CoviMap userAccount = (CoviMap) userResultList.get("account");
		
		if (userAccount.size() < 1) {
			mav.addObject("message_b", OAuth2ErrorConstant.UNAUTHORIZED_CLIENT);
			mav.addObject("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
		}
		
		
		try {
			clientResultList = ssoOAuthsvc.getClientOne(rVO.getClient_id());
		} catch (NullPointerException e) {
			mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
			mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
		} catch (Exception e) {
			mav.addObject("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION);
			mav.addObject("message_h", OAuth2ErrorConstant.SERVER_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
		}
		
		CoviMap clientAccount = (CoviMap) clientResultList.get("account");
		
		if (clientAccount.size() < 1) {
			mav.addObject("message_b", OAuth2ErrorConstant.UNAUTHORIZED_CLIENT);
			mav.addObject("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
		}
			
		// 2. scope 포함여부 확인
		if (!OAuth2Scope.isScopeValid(rVO.getScope(), clientAccount.get("scope").toString())) {
			mav.addObject("message_b", OAuth2ErrorConstant.INVALID_CODE);
			mav.addObject("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
		}
		
		// 3. redirect_uri 일치여부 확인
		if (!rVO.getRedirect_uri().equals(clientAccount.get("redirect_uri").toString())) {
			mav.addObject("message_b", OAuth2ErrorConstant.NOT_MATCH_REDIRECT_URI);
			mav.addObject("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
		}

		TokenVO tVO = createTokenToTable(rVO, userAccount.get("UR_Code").toString(), clientAccount.get("client_type").toString());
		
		String response_type = rVO.getResponse_type();
		String redirect = "";
		
		if (response_type.equals(OAuth2Constant.RESPONSE_TYPE_CODE)) {

			redirect = "redirect:"+ rVO.getRedirect_uri() + "?code=" + tVO.getCode();
			if (rVO.getState() != null) {
				redirect += "&state=" + rVO.getState(); 
			}
		} else if (response_type.equals(OAuth2Constant.RESPONSE_TYPE_TOKEN)) {

			ResponseAccessTokenVO tokenVO = null;
			if (OAuth2Constant.USE_REFRESH_TOKEN) {
					tokenVO = new ResponseAccessTokenVO(
				 	tVO.getAccess_token(), tVO.getToken_type(), 
					tVO.getExpires_in(), tVO.getRefresh_token(), rVO.getState(), tVO.getCreated_at());				
			} else {
					//OAuth2AccessToken 클래스 기능을 이용해 정해진 규칙에 의해 생성함.
					tokenVO = new ResponseAccessTokenVO(
					this.tokenService.generateAccessToken(clientAccount.get("client_id").toString(), clientAccount.get("client_secret").toString(), userAccount.get("UR_Code").toString(),userAccount.get("LogonPW").toString()), 
					OAuth2Constant.TOKEN_TYPE_BEARER, 0, null, rVO.getState(), tVO.getCreated_at());
					tokenVO.setExpires_in(0);
					tokenVO.setRefresh_token(null);
			}

			String acc = OAuth2Util.getAccessTokenToFormUrlEncoded(tokenVO);
			redirect = "redirect:" + rVO.getRedirect_uri() + "?"+acc;
			
		} else {
			mav.addObject("message_b", OAuth2ErrorConstant.UNSUPPORTED_RESPONSE_TYPE);
			mav.addObject("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			
			mav.setViewName(returnURL);
			return mav;
		}
		
		mav.setViewName(redirect);
		return mav;	
	}
	
	private TokenVO createTokenToTable(RequestAuthVO rVO, String userId, String clientType){
		TokenVO tVO = null;
		try {
			tVO = new TokenVO();
			tVO.setClient_id(rVO.getClient_id());
			
			tVO.setUserid(userId);
			tVO.setToken_type(OAuth2Constant.TOKEN_TYPE_BEARER);
			tVO.setScope(rVO.getScope());
			
			tVO.setExpires_in(OAuth2Constant.EXPIRES_IN_VALUE);
			tVO.setRefresh_token(OAuth2Util.generateRandomState());
			tVO.setCode(OAuth2Util.generateRandomState());
			tVO.setClient_type(clientType);
			
			tVO.setAccess_token(OAuth2Util.generateRandomState());
			long currentTimeStamp = OAuth2Util.getCurrentTimeStamp();
			tVO.setCreated_at(currentTimeStamp);
			tVO.setCreated_rt(currentTimeStamp);
			
			ssoOAuthsvc.createToken(tVO);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return tVO;
	}
	
	@RequestMapping(value = "oauth2/token.do")
	public String accessToken(RequestAccessTokenVO ratVO, Model model, HttpServletRequest request, HttpServletResponse response) throws Exception{
		
		String json = "";
		String returnURL = "oauthException";
		
		if (ratVO.getGrant_type().equals(OAuth2Constant.GRANT_TYPE_AUTHORIZATION_CODE)) {
			ResponseAccessTokenVO resVO = accessTokenServerFlow(ratVO, request, response);
			json = OAuth2Util.getJSONFromObject(resVO);
		} else if (ratVO.getGrant_type().equals(OAuth2Constant.GRANT_TYPE_REFRESH_TOKEN)) {
			if (OAuth2Constant.USE_REFRESH_TOKEN) {
				ResponseAccessTokenVO resVO = refreshTokenFlow(ratVO, request, response);
				json = OAuth2Util.getJSONFromObject(resVO);
			} else {
				model.addAttribute("message_b", OAuth2ErrorConstant.UNSUPPORTED_RESPONSE_TYPE);
				model.addAttribute("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR);
				return "oauthException";
			}
		} else {
			model.addAttribute("message_b", OAuth2ErrorConstant.UNSUPPORTED_RESPONSE_TYPE);
			model.addAttribute("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			
			return "oauthException";
		
		}
		model.addAttribute("json", json); 
		return "json";
	}
	
	//grant_type이 authorization_code일 때 
	private ResponseAccessTokenVO accessTokenServerFlow(RequestAccessTokenVO ratVO, HttpServletRequest request, HttpServletResponse response) throws Exception {
		String returnURL = "oauthException";	
		StringUtil func = new StringUtil();
		
		//GET 방식일 때는 Client ID와 Client Secret은 Authorization Header를 통해 전달되어야 함.

		if (request.getMethod().equalsIgnoreCase("GET")) {
			String authHeader = (String)request.getHeader("Authorization");
			if (authHeader == null || authHeader.equals("")) {
				response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException?message_b="+OAuth2ErrorConstant.INVALID_PARAMETER+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
				return null;
			}
			//Basic 인증 헤더 파싱
			OAuth2Util.parseBasicAuthHeader(authHeader, ratVO);
		}
		
		if (ratVO.getClient_id() ==null || ratVO.getClient_secret() == null ) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException?message_b="+OAuth2ErrorConstant.INVALID_PARAMETER+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
		}
			
		CoviMap clientResultList = new CoviMap();
		CoviMap tokenResultList = new CoviMap();
		CoviMap userResultList = new CoviMap();
		
		try {
			clientResultList = ssoOAuthsvc.getClientOne(ratVO.getClient_id());
		} catch (NullPointerException e) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
		} catch (Exception e) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
		}
		
		CoviMap clientAccount = (CoviMap) clientResultList.get("account");
		
		if (clientAccount.size() < 1) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException?message_b="+OAuth2ErrorConstant.UNAUTHORIZED_CLIENT+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
		}
		
		if (!ratVO.getRedirect_uri().equals(clientAccount.get("redirect_uri"))) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException?message_b="+OAuth2ErrorConstant.NOT_MATCH_REDIRECT_URI+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
		}
		
		if (func.f_NullCheck(ratVO.getCode()).equals("")) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException?message_b="+OAuth2ErrorConstant.INVALID_PARAMETER+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
		}
			
		try {
			tokenResultList = ssoOAuthsvc.selectTokenByCode(ratVO.getCode());
		} catch (NullPointerException e) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
		} catch(Exception e) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
		}

		CoviMap tokenAccount = (CoviMap) tokenResultList.get("account");
		if (tokenAccount.size() < 1) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException?message_b="+OAuth2ErrorConstant.INVALID_CODE+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
		}
		
		if (OAuth2Constant.USE_REFRESH_TOKEN) {
			long expires = Long.parseLong(tokenAccount.get("created_at").toString()) +  Long.parseLong(tokenAccount.get("expires_in").toString());
			
			if (System.currentTimeMillis() > expires) {
				response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException?message_b="+OAuth2ErrorConstant.EXPIRED_TOKEN+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			}
		}	
		
		ResponseAccessTokenVO resVO = new ResponseAccessTokenVO();
		
		resVO.setIssued_at(Long.parseLong(tokenAccount.get("created_access_token").toString()));
		resVO.setState(ratVO.getState());
		resVO.setToken_type(tokenAccount.get("token_type").toString());
		
		if (OAuth2Constant.USE_REFRESH_TOKEN) {
			resVO.setAccess_token(tokenAccount.get("access_token").toString());
			resVO.setExpires_in(Long.parseLong(tokenAccount.get("expires_in").toString()));
			resVO.setRefresh_token(tokenAccount.get("refresh_token").toString());
		} else {
			try {
				userResultList = ssoOAuthsvc.getUserInfo(tokenAccount.get("userCode").toString());
			} catch (NullPointerException e) {
				response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
			} catch (Exception e) {
				response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
			}
			
			CoviMap userAccount = (CoviMap) userResultList.get("account");
			if (userAccount.size() < 1) {
				response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.INVALID_USER+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			}
			try {
				ssoOAuthsvc.deleteToken(tokenAccount.get("access_token").toString());
			} catch (NullPointerException e) {
				response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
			} catch (Exception e) {
				response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
			}
			resVO.setAccess_token(this.tokenService.generateAccessToken(clientAccount.get("client_id").toString(), clientAccount.get("client_secret").toString(), userAccount.get("UR_Code").toString(), userAccount.get("LogonPW").toString()));
		}
		return resVO;
	}
	
	private ResponseAccessTokenVO refreshTokenFlow(RequestAccessTokenVO ratVO, HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String returnURL = "oauthException";
		
		CoviMap clientResultList = new CoviMap();
		CoviMap tokenResultList = new CoviMap();
		CoviMap userResultList = new CoviMap();
		
		if (request.getMethod().equalsIgnoreCase("GET")) {
			String authHeader = (String)request.getHeader("Authorization");
			if (authHeader == null || authHeader.equals("")) {
				response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.INVALID_PARAMETER+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
				return null;
			}
			//Basic 인증 헤더 파싱
			OAuth2Util.parseBasicAuthHeader(authHeader, ratVO);
		}
		
		if (ratVO.getClient_id() ==null || ratVO.getClient_secret() == null ) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.INVALID_PARAMETER+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
		}

		try {
			clientResultList = ssoOAuthsvc.getClientOne(ratVO.getClient_id());
			
		} catch (NullPointerException e) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
		} catch(Exception e) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
		}
		
		CoviMap clientAccount = (CoviMap) clientResultList.get("account");
		
		if (clientAccount.size() < 1 ) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.UNAUTHORIZED_CLIENT+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
		}
		
		if (ratVO.getClient_secret() != null && !clientAccount.get("client_secret").equals(ratVO.getClient_secret())) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.UNAUTHORIZED_CLIENT+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
		}
		
		//4. refresh token의 일치 여부
		if (ratVO.getRefresh_token() == null) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException?message_b="+OAuth2ErrorConstant.INVALID_PARAMETER+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
		}
		
		try {
			tokenResultList = ssoOAuthsvc.selectRefreshToken(ratVO.getRefresh_token());
		} catch (NullPointerException e) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
		} catch (Exception e) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
		}
		
		CoviMap tokenAccount = (CoviMap) tokenResultList.get("account");
		
		if (tokenAccount.size() < 1) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.INVALID_TOKEN+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
		}
		
		String accessToken = OAuth2Util.generateRandomState();
		long createdAt = OAuth2Util.getCurrentTimeStamp();
		
		try {
			ssoOAuthsvc.updateAccessToken(ratVO.getRefresh_token(), accessToken, createdAt);
		} catch (NullPointerException e) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
		} catch (Exception e) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
		}
		
		ResponseAccessTokenVO resVO = new ResponseAccessTokenVO(
		accessToken, tokenAccount.get("token_type").toString(), 
		Long.parseLong(tokenAccount.get("expires_in").toString()), null, ratVO.getState(), createdAt);
	
		return resVO;
	}
	
	
	@RequestMapping(value = "oauthException.do")
	public ModelAndView oauthException(RequestAuthVO rVO, HttpServletRequest request){
		
		ModelAndView mav = new ModelAndView();
		String returnURL = "oauthException";
		
		mav.addObject("message_b", request.getParameter("message_b"));
		mav.addObject("message_h", request.getParameter("message_h"));
		
		mav.setViewName(returnURL);
		
		return mav;
	}
	
	
}