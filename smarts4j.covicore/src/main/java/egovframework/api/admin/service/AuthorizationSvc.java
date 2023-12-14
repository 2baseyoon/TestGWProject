package egovframework.api.admin.service;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public interface AuthorizationSvc {
	/**
	 * API 권한체크 ( 건수, )
	 * @param request
	 * @param response
	 */
	
	public void checkRequestIP(String requestIP) throws Exception;
	public void reloadIPSecureList() throws Exception;
}
