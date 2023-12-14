package egovframework.core.sso.oauth;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import egovframework.baseframework.data.CoviMap;
import egovframework.core.sevice.SsoOauthSvc;

@Controller
public class ResourceController {
	
	@Autowired
	private SsoOauthSvc ssoOAuthsvc;
	
	@Autowired
	private OAuth2AccessTokenService tokenService;
	
	@RequestMapping(value="resource/myinfo.do" , method = RequestMethod.GET)
	public String getMyInfo(Model model, HttpServletRequest request,  HttpServletResponse response) throws Exception {
		
		String returnURL = "oauthException";
		String uri = request.getMethod() + " " + 
				request.getRequestURI().substring(request.getContextPath().length());
		String scope = OAuth2Scope.getScopeFromURI(uri);
		String authHeader = request.getHeader("Authorization");
		
		CoviMap clientResultList = new CoviMap();
		CoviMap userResultList = new CoviMap();
		
		TokenVO tVO = new TokenVO();
		
		//Bearer Header 
		if (authHeader == null || !authHeader.startsWith("Bearer ")) {
			response.sendRedirect(	returnURL = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/covicore/oauthException.do?message_b="+OAuth2ErrorConstant.UNAUTHORIZED_CLIENT+"&message_h="+OAuth2ErrorConstant.AUTHORIZATION_ERROR);
			model.addAttribute("message_b", OAuth2ErrorConstant.UNAUTHORIZED_CLIENT); 
			model.addAttribute("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR); 
			return returnURL;
		}

		String accessToken = OAuth2Util.parseBearerToken(authHeader);
		
		if (OAuth2Constant.USE_REFRESH_TOKEN) {
			try {
				clientResultList = ssoOAuthsvc.selectToken(accessToken);
			} catch (NullPointerException e) {
				model.addAttribute("message_b", OAuth2ErrorConstant.SERVER_ERROR); 
				model.addAttribute("message_h", OAuth2ErrorConstant.SERVER_EXCEPTION); 
				return returnURL;
			} catch (Exception e) {
				model.addAttribute("message_b", OAuth2ErrorConstant.SERVER_ERROR); 
				model.addAttribute("message_h", OAuth2ErrorConstant.SERVER_EXCEPTION); 
				return returnURL;
			}
			CoviMap clientAccount = (CoviMap) clientResultList.get("account");
			
			if (clientAccount.size() < 1) {
				model.addAttribute("message_b", OAuth2ErrorConstant.UNAUTHORIZED_CLIENT); 
				model.addAttribute("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR); 
				return returnURL;
			}
			
			tVO.setScope(clientAccount.get("scope").toString());
			tVO.setExpires_in(Long.parseLong(clientAccount.get("expires_in").toString()));
			tVO.setCreated_at(Long.parseLong(clientAccount.get("created_access_token").toString()));
			tVO.setClient_type(clientAccount.get("client_type").toString());
			
		} else {
			tVO = tokenService.validateAccessToken(accessToken);
		}
		
		if (!OAuth2Scope.isUriScopeValid(scope, tVO.getScope())) {
			model.addAttribute("message_b", OAuth2ErrorConstant.INSUFFICIENT_SCOPE); 
			model.addAttribute("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR); 
			return returnURL;
		}
		
		if (OAuth2Constant.USE_REFRESH_TOKEN) {
			long expires_in = tVO.getExpires_in();		//초단위
			long created_at = tVO.getCreated_at();		//밀리초
			long current_ts = OAuth2Util.getCurrentTimeStamp();	//현재의 timestamp
			if (current_ts > created_at + expires_in * 1000) {
				model.addAttribute("message_b", OAuth2ErrorConstant.EXPIRED_TOKEN); 
				model.addAttribute("message_h", OAuth2ErrorConstant.AUTHORIZATION_ERROR); 
				return returnURL;
			
			}
		}
		
		if (tVO.getClient_type().equals("U")) {
			String referer = request.getHeader("Referer");
			
			int index = referer.indexOf("/", 7);
			String origin = referer.substring(0, index).replaceAll("\r", "").replaceAll("\n", "");	 //CLRF 대응
			
			if (origin != null) {
				response.addHeader("Access-Control-Allow-Origin", origin);	
			}
		}
		
		if (OAuth2Constant.USE_REFRESH_TOKEN) {
			ssoOAuthsvc.deleteExpiredToken(7*24*60*60*1000);
		}
		
		try {
			userResultList = ssoOAuthsvc.getMyInfo(tVO.getUserid());
		} catch (NullPointerException e) {
			model.addAttribute("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION); 
			model.addAttribute("message_h", OAuth2ErrorConstant.SERVER_ERROR); 
			return returnURL;
		} catch(Exception e) {
			model.addAttribute("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION); 
			model.addAttribute("message_h", OAuth2ErrorConstant.SERVER_ERROR); 
			return returnURL;
		}
		
		CoviMap userAccount = (CoviMap) userResultList.get("account");
		
		
		// 미사용
		/*try {
			clientResultList = ssoOAuthsvc.getClientOne(tVO.getClient_id());
		} catch (Exception e) {
			model.addAttribute("message_b", OAuth2ErrorConstant.SERVER_EXCEPTION); 
			model.addAttribute("message_h", OAuth2ErrorConstant.SERVER_ERROR); 
			return returnURL;
		}*/
		
		String jsonUser = userAccount.toString();
		
		model.addAttribute("json", jsonUser);
		
		return "json";
	}
}
