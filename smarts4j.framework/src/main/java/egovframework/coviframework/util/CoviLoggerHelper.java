package egovframework.coviframework.util;

import java.util.UUID;

import javax.servlet.http.HttpServletRequest;





import java.util.Enumeration;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.ThreadContext;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.service.CoviService;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;

public final class CoviLoggerHelper  {
	private static final Logger LOGGER = LogManager.getLogger(CoviLoggerHelper.class);
	private static final Logger LELOGGER = LogManager.getLogger("legacyDetailLogger");
	
	public static void pageMoveLogger(String uri) throws Exception {
		pageMoveLogger(uri,"");
	}

	public static void pageMoveLogger(String uri, String objectType) throws Exception {
		
		try {
			StringUtil func = new StringUtil();
			
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
						
			String pageUrl = "unknown";
			if(StringUtils.isNoneBlank(request.getRequestURL())){
				pageUrl = request.getRequestURL().toString();
			}
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			String usrCode = ( !userDataObj.isNullObject() && userDataObj.has("UR_Code") ) ? userDataObj.getString("UR_Code") : "unknown";
			String usrId =  ( !userDataObj.isNullObject() && userDataObj.has("USERID") ) ? userDataObj.getString("USERID") : "unknown";
			String usrLogonID = ( !userDataObj.isNullObject() && userDataObj.has("LogonID") ) ? userDataObj.getString("LogonID") : "unknown";
			String usrCompanyCode = ( !userDataObj.isNullObject() && userDataObj.has("DN_Code") ) ? userDataObj.getString("DN_Code") : "unknown";
			
			CoviMap reqMap = new CoviMap();
			StringBuffer sb = new StringBuffer("{");
			
			Enumeration eNames = request.getParameterNames();
			if (eNames.hasMoreElements()) {
				while (eNames.hasMoreElements()) {
					String name = (String) eNames.nextElement();
					sb.append("\""+name+"\":\""+ request.getParameter(name)+"\",");
				}
			}
			sb.append("}");
			reqMap.put("USERCODE", usrCode);
			reqMap.put("LOGONID", usrLogonID);
			reqMap.put("COMPANYCODE", usrCompanyCode);
			reqMap.put("SITENAME",	request.getServerName() + ":" + String.valueOf(request.getServerPort()));
			reqMap.put("PAGEURL", pageUrl);
			reqMap.put("PAGEPARAM", ComUtils.substringBytes(sb.toString(),1000));
			reqMap.put("IPADDRESS", func.getRemoteIP(request));
			reqMap.put("OBJECTTYPE", objectType);
		
			CoviService coviSvc = StaticContextAccessor.getBean(CoviService.class);
			coviSvc.insert("framework.logger.setPageMoveLog", reqMap);
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
		}
	}
	
	public static void perfomanceLogger(String uri, String objectType, String runTime) throws Exception {
		
		try {
			StringUtil func = new StringUtil();
			
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
						
			String pageUrl = "unknown";
			if(StringUtils.isNoneBlank(request.getRequestURL())){
				pageUrl = request.getRequestURL().toString();
			}
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			String usrCode = ( !userDataObj.isNullObject() && userDataObj.has("UR_Code") ) ? userDataObj.getString("UR_Code") : "unknown";
			String usrId =  ( !userDataObj.isNullObject() && userDataObj.has("USERID") ) ? userDataObj.getString("USERID") : "unknown";
			String usrLogonID = ( !userDataObj.isNullObject() && userDataObj.has("LogonID") ) ? userDataObj.getString("LogonID") : "unknown";
			String usrCompanyCode = ( !userDataObj.isNullObject() && userDataObj.has("DN_Code") ) ? userDataObj.getString("DN_Code") : "unknown";
			
			CoviMap reqMap = new CoviMap();
			StringBuffer sb = new StringBuffer("{");
			
			Enumeration eNames = request.getParameterNames();
			if (eNames.hasMoreElements()) {
				while (eNames.hasMoreElements()) {
					String name = (String) eNames.nextElement();
					sb.append("\""+name+"\":\""+ request.getParameter(name)+"\",");
				}
			}
			sb.append("}");
			
			reqMap.put("USERCODE", usrCode);
			reqMap.put("LOGONID", usrLogonID);
			reqMap.put("COMPANYCODE", usrCompanyCode);
			reqMap.put("SITENAME",	request.getServerName() + ":" + String.valueOf(request.getServerPort()));
			reqMap.put("PAGEURL", pageUrl);
			reqMap.put("PAGEPARAM", ComUtils.substringBytes(sb.toString(),1000));
			reqMap.put("IPADDRESS", func.getRemoteIP(request));
			reqMap.put("THREADID", uri);
			reqMap.put("OBJECTTYPE", objectType);
			//ThreadID
			
			reqMap.put("RUNTIME", runTime);
		
			CoviService coviSvc = StaticContextAccessor.getBean(CoviService.class);
			coviSvc.insert("framework.logger.setPerformanceLog", reqMap);
//			MLOGGER.error(pageUrl);
		} catch(NullPointerException e){	
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
	}
	
	
	
	
	/**
	 * @param logInfo : FormInstID,ProcessID,UserCode,ApvMode,LegacySystem,State,InputData,OutputData,Message,Reserved1,Reserved2,Reserved3,Reserved4
	 * @throws Exception
	 */
	public static void legacyDetailLogger(CoviMap logInfo) throws Exception {
		
		try {
			
			String formInstID = ( !logInfo.isNullObject() && logInfo.has("FormInstID") ) ? logInfo.getString("FormInstID") : "0";
			String processID = ( !logInfo.isNullObject() && logInfo.has("ProcessID") ) ? logInfo.getString("ProcessID") : "0";
			String userCode = ( !logInfo.isNullObject() && logInfo.has("UserCode") ) ? logInfo.getString("UserCode") : null;
			String apvMode = ( !logInfo.isNullObject() && logInfo.has("ApvMode") ) ? logInfo.getString("ApvMode") : null;
			String legacySystem = ( !logInfo.isNullObject() && logInfo.has("LegacySystem") ) ? logInfo.getString("LegacySystem") : null;
			String state = ( !logInfo.isNullObject() && logInfo.has("State") ) ? logInfo.getString("State") : null;
			String inputData = ( !logInfo.isNullObject() && logInfo.has("InputData") ) ? logInfo.getString("InputData") : null;
			String outputData = ( !logInfo.isNullObject() && logInfo.has("OutputData") ) ? logInfo.getString("OutputData") : null;
			String message = ( !logInfo.isNullObject() && logInfo.has("Message") ) ? logInfo.getString("Message") : null;
			String reserved1 = ( !logInfo.isNullObject() && logInfo.has("Reserved1") ) ? logInfo.getString("Reserved1") : null;
			String reserved2 = ( !logInfo.isNullObject() && logInfo.has("Reserved2") ) ? logInfo.getString("Reserved2") : null;
			String reserved3 = ( !logInfo.isNullObject() && logInfo.has("Reserved3") ) ? logInfo.getString("Reserved3") : null;
			String reserved4 = ( !logInfo.isNullObject() && logInfo.has("Reserved4") ) ? logInfo.getString("Reserved4") : null;
			
			ThreadContext.put("FormInstID", formInstID);
			ThreadContext.put("ProcessID", processID);
			ThreadContext.put("UserCode", userCode);
			ThreadContext.put("ApvMode", apvMode);
			ThreadContext.put("LegacySystem", legacySystem);
			ThreadContext.put("State", state);
			ThreadContext.put("InputData", inputData);
			ThreadContext.put("OutputData", outputData);
			ThreadContext.put("Message", message);
			ThreadContext.put("Reserved1", reserved1);
			ThreadContext.put("Reserved2", reserved2);
			ThreadContext.put("Reserved3", reserved3);
			ThreadContext.put("Reserved4", reserved4);
			
			LELOGGER.info("LegacyDetail Logger logging");
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			ThreadContext.clearMap();
		}
	}
	
	/**
	 * 권한 오류 로그
	 * 
	 * @param uri
	 * @throws Exception
	 */
	public static void authErrorLogger(String uri, String errorType, String auditClass, String auditMethod, String errorMessage, String type) throws Exception {
		
		try {
			StringUtil func = new StringUtil();
			
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
			
			String pageUrl = "unknown";
			if(StringUtils.isEmpty(type)) {
				if(StringUtils.isNoneBlank(request.getRequestURL())){
					pageUrl = request.getRequestURL().toString();
				}
			} else {
				pageUrl = request.getScheme() + "://" + request.getServerName() + ":" + String.valueOf(request.getServerPort()) + uri;
			}
						
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			String usrCode = ( !userDataObj.isNullObject() && userDataObj.has("UR_Code") ) ? userDataObj.getString("UR_Code") : "unknown";
			String usrId =  ( !userDataObj.isNullObject() && userDataObj.has("USERID") ) ? userDataObj.getString("USERID") : "unknown";
			String usrLogonID = ( !userDataObj.isNullObject() && userDataObj.has("LogonID") ) ? userDataObj.getString("LogonID") : "unknown";
			String usrCompanyCode = ( !userDataObj.isNullObject() && userDataObj.has("DN_Code") ) ? userDataObj.getString("DN_Code") : "unknown";
			
			CoviMap reqMap = new CoviMap();
			StringBuffer sb = new StringBuffer("{");
			
			Enumeration eNames = request.getParameterNames();
			if (eNames.hasMoreElements()) {
				while (eNames.hasMoreElements()) {
					String name = (String) eNames.nextElement();
					sb.append("\""+name+"\":\""+ request.getParameter(name)+"\",");
				}
			}
			sb.append("}");
			reqMap.put("USERCODE", usrCode);
			reqMap.put("LOGONID", usrLogonID);
			reqMap.put("COMPANYCODE", usrCompanyCode);
			reqMap.put("SITENAME",	request.getServerName() + ":" + String.valueOf(request.getServerPort()));
			reqMap.put("PAGEURL", pageUrl);
			reqMap.put("PAGEPARAM", ComUtils.substringBytes(sb.toString(),1000));
			reqMap.put("AUDITCLASS", auditClass);
			reqMap.put("AUDITMETHOD", auditMethod);
			reqMap.put("IPADDRESS", func.getRemoteIP(request));
			reqMap.put("ERRORTYPE", errorType);
			reqMap.put("ERRORMESSAGE", errorMessage);
			CoviService coviSvc = StaticContextAccessor.getBean(CoviService.class);
			coviSvc.insert("framework.logger.setAuthErrorLog", reqMap);
		} catch(NullPointerException e){	
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		}
	}
	
	
	public static String authLogger(CoviMap logInfo, String logType) throws Exception {
		
		String logChangeID = null;
		
		try {
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
			CoviService coviSvc = StaticContextAccessor.getBean(CoviService.class);
						
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);

			logInfo.put("registerCode", ( !userDataObj.isNullObject() && userDataObj.has("UR_Code") ) ? userDataObj.getString("UR_Code") : "unknown");
			
			// 권한 변경 이력
			if(!logInfo.has("logChangeID") && StringUtils.isEmpty(logInfo.getString("logChangeID"))) {				
				coviSvc.insert("framework.logger.setACLLog", logInfo);
			}
			
			// 권한 변경 세부 이력
			if(logInfo.has("logChangeID") && StringUtils.isNotEmpty(logInfo.getString("logChangeID"))) {
				if(StringUtils.equals(logType, "Before")) {				// 변경 전 로그
					coviSvc.insert("framework.logger.setBeforeACLDetailLog", logInfo);
				} else if(StringUtils.equals(logType, "After")) {		// 변경 후 로그
					if(logInfo.has("setInheritedACL") && StringUtils.equals(logInfo.getString("setInheritedACL"), "Y")) {
						coviSvc.insert("framework.logger.setAfterInheritedACLDetailLog", logInfo);	// 다건 등록
					} else {
						coviSvc.insert("framework.logger.setAfterACLDetailLog", logInfo);			// 단건 등록
					}
				}
				
				logChangeID = logInfo.getString("logChangeID");
			}
		} catch(NullPointerException e){	
			LOGGER.debug(e);
		} catch (Exception e) {
			LOGGER.debug(e);
		}
		
		return logChangeID;
	}

}