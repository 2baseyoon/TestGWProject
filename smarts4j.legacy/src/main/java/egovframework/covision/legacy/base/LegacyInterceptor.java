package egovframework.covision.legacy.base;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.web.servlet.AsyncHandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;


public class LegacyInterceptor implements AsyncHandlerInterceptor {
	private Logger LOGGER = LogManager.getLogger(LegacyInterceptor.class);
	
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		// legacy 의 경우 context path 에 회사코드가 노출되므로, 타회사 URL 접속을 제한한다.
		/*
		boolean isSaaS = "Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N"));
		if(isSaaS) {
			String message = "";
			boolean isValidationSuccees = true;
			String contextPath = request.getContextPath();

			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			// 세션없는건 여기서 처리하지 않는다.
			if(userDataObj != null && !userDataObj.isEmpty()){
				String userName = userDataObj.optString("USERNAME", "");
				String LogonID = userDataObj.optString("LogonID", "");
				String DN_Code = userDataObj.optString("DN_Code", "");
				
				if("ORGROOT".equals(DN_Code)) {
					return true;
				}
				
				if(!contextPath.equals("/legacy_" +DN_Code.toLowerCase())) {
					message = "Cross company access violation. request Context["+contextPath+"], user DN_Code["+DN_Code+"], user empNo["+LogonID+"], userName["+userName+"]";
					isValidationSuccees = false;
				}
				
				if(!isValidationSuccees) {
					LOGGER.info(message);
					response.sendError(HttpServletResponse.SC_NOT_FOUND);
					return false;
				}
			}
		}
		*/
		return true;
	}

	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
	}

	@Override
	public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
	}

	@Override
	public void afterConcurrentHandlingStarted(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
	}
}
