package egovframework.covision.groupware.oauth2.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.oauth2.service.AdminOAuth2Svc;


@Controller
public class OAuth2GoogleClient {

	@Autowired
	private AdminOAuth2Svc adminOAuth2Svc;
	
	@RequestMapping(value = "oauth2/google.do")
	public ModelAndView authorize(HttpServletResponse response,	HttpServletRequest request) throws Exception{
		ModelAndView mav = new ModelAndView();
		
		StringUtil func = new StringUtil();
		
		String returnURL = "";
		String state = request.getParameter("state");
		
		SessionHelper.setExpireTime();
		String userId = SessionHelper.getSession("USERID");
		
		mav.addObject("email", adminOAuth2Svc.getEmail(userId));
		mav.addObject("state", state);
		
		returnURL = "user/oauth/OAuthGoogle";
		mav.setViewName(returnURL);
		return mav;
	}
	
	
}
