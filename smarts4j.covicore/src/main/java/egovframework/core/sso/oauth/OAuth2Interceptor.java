package egovframework.core.sso.oauth;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import egovframework.baseframework.data.CoviMap;
import egovframework.core.sevice.SsoOauthSvc;

@Controller
public class OAuth2Interceptor extends HandlerInterceptorAdapter {

	@Autowired
	private SsoOauthSvc ssoOAuthsvc;

	@Autowired
	private OAuth2AccessTokenService tokenService;
	
	@Override
	public boolean preHandle(HttpServletRequest request,
			HttpServletResponse response, Object handler) throws Exception {
		String returnURL = "";
		String uri = request.getMethod() + " " + 
				request.getRequestURI().substring(request.getContextPath().length());
		String scope = OAuth2Scope.getScopeFromURI(uri);
		String authHeader = request.getHeader("Authorization");
		CoviMap clientResultList = new CoviMap();
		
		if (authHeader == null || !authHeader.startsWith("Bearer ")) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.UNAUTHORIZED_CLIENT+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
		} else {
			String accessToken = OAuth2Util.parseBearerToken(authHeader);
			TokenVO tVO = null;
			if (OAuth2Constant.USE_REFRESH_TOKEN) {
				//1. 토큰이 존재하는지...
				try {
					clientResultList = ssoOAuthsvc.selectToken(accessToken);
				} catch (NullPointerException e) {
					response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);	
				} catch (Exception e) {
					response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.SERVER_ERROR+"&message_h="+OAuth2ErrorConstant.SERVER_EXCEPTION);
				}
				CoviMap clientAccount = (CoviMap) clientResultList.get("account");
				
				if (clientAccount.size() < 1) {
					response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.UNAUTHORIZED_CLIENT+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
				}
				tVO.setScope(clientAccount.get("scope").toString());
				tVO.setExpires_in(Long.parseLong(clientAccount.get("expires_in").toString()));
				tVO.setCreated_at(Long.parseLong(clientAccount.get("created_access_token").toString()));
				tVO.setClient_type(clientAccount.get("client_type").toString());
			} else {
				tVO = tokenService.validateAccessToken(accessToken);
			}
			
			if (!OAuth2Scope.isUriScopeValid(scope, tVO.getScope())) {
				response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.INSUFFICIENT_SCOPE+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			}
			
			if (OAuth2Constant.USE_REFRESH_TOKEN) {
				long expires_in = tVO.getExpires_in();		//초단위
				long created_at = tVO.getCreated_at();		//밀리초
				long current_ts = OAuth2Util.getCurrentTimeStamp();	//현재의 timestamp
				if (current_ts > created_at + expires_in * 1000) {
					response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.EXPIRED_TOKEN+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
				}
			}
			
			if (tVO.getClient_type().equals("U")) {
				String referer = request.getHeader("Referer");
				
				int index = referer.indexOf("/", 7);
				String origin = referer.substring(0, index).replaceAll("\r", "").replaceAll("\n", ""); //CLRF 대응
				
				if (origin != null) {
					response.addHeader("Access-Control-Allow-Origin", origin); 	
				}
			}
			
			if (OAuth2Constant.USE_REFRESH_TOKEN) {
				ssoOAuthsvc.deleteExpiredToken(7*24*60*60*1000);
			}
			
			request.setAttribute(OAuth2Constant.RESOURCE_TOKEN_NAME, tVO);
			response.setHeader("Pragma", "no-cache");
			response.setHeader("Cache-Control", "no-cache");
		}
		return true;
	}
	
}

