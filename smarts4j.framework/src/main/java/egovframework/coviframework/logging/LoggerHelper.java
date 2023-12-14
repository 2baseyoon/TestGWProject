package egovframework.coviframework.logging;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Method;
import java.util.Enumeration;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.ThreadContext;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.service.CoviService;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.DateHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;

public class LoggerHelper {

	private static final Logger LOGGER = LogManager.getLogger(LoggerHelper.class);
	private static final Logger CLOGGER = LogManager.getLogger("connectLogger");
	private static final Logger CFLOGGER = LogManager.getLogger("connectFalseLogger");
	private static final Logger MLOGGER = LogManager.getLogger("pagemoveLogger");
	private static final Logger ELOGGER = LogManager.getLogger("errorLogger");
	private static final Logger HLOGGER = LogManager.getLogger("httpLogger");
	private static final Logger ALOGGER = LogManager.getLogger("auditLogger");
	private static final Logger FLOGGER = LogManager.getLogger("filedownloadLogger");
	private static final Logger LELOGGER = LogManager.getLogger("legacyDetailLogger");
	
	
	public static void errorLogger(Exception ex, String packageName, String alertMsg) throws Exception {
		
		boolean flag = true;
		
		try {
			StringUtil func = new StringUtil();

			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();

			boolean isMobile = ClientInfoHelper.isMobile(request);
			
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			String usrCode = ( !userDataObj.isNullObject() && userDataObj.has("UR_Code") ) ? userDataObj.getString("UR_Code") : "unknown";
			String usrId =  ( !userDataObj.isNullObject() && userDataObj.has("USERID") ) ? userDataObj.getString("USERID") : "unknown";
			String usrLogonID = ( !userDataObj.isNullObject() && userDataObj.has("LogonID") ) ? userDataObj.getString("LogonID") : "unknown";
			String usrCompanyCode = ( !userDataObj.isNullObject() && userDataObj.has("DN_Code") ) ? userDataObj.getString("DN_Code") : "unknown";
			
			StringWriter writer = new StringWriter();
			PrintWriter printWriter = new PrintWriter( writer );
			ex.printStackTrace( printWriter ); 
			printWriter.flush();

			String stackTrace = writer.toString();
			if (stackTrace.length()>1000){
				stackTrace = stackTrace.substring(0,1000);
			}
			
			String alertMessage = ex.getMessage();
			if (alertMessage.length()>1000){
				alertMessage = alertMessage.substring(0,1000);
			}
			
			CoviList params = new CoviList();
			Enumeration eNames = request.getParameterNames();
			if (eNames.hasMoreElements()) {
				while (eNames.hasMoreElements()) {
					String name = (String) eNames.nextElement();
					CoviMap param = new CoviMap();
					param.put(name, request.getParameterValues(name));
					params.add(param);
				}
			}
			
			if(func.f_NullCheck(ex.getMessage()).equals("MAX")){	//등록 X: 용량에 관련 메세지
				flag = false;
			}else{
				ThreadContext.put("id", UUID.randomUUID().toString()); // Add the fishtag;
				ThreadContext.put("USERID", usrId);
				ThreadContext.put("USERCODE", usrCode);
				ThreadContext.put("LOGONID", usrLogonID);
				ThreadContext.put("COMPANYCODE", usrCompanyCode);
				ThreadContext.put("ERRORTYPE", alertMsg);
				ThreadContext.put("ALERTMESSAGE", alertMessage);
				ThreadContext.put("ERRORMESSAGE", stackTrace);
				ThreadContext.put("SITENAME",	request.getServerName()	+ ":" + String.valueOf(request.getServerPort()));
				ThreadContext.put("PAGEURL", request.getRequestURL().toString());
				ThreadContext.put("PAGEPARAM", params.toString());
				ThreadContext.put("METHODNAME", packageName);
				ThreadContext.put("IPADDRESS", func.getRemoteIP(request));
				
				ELOGGER.info("DB error logging.");
			}
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			if(flag){
				ThreadContext.clearMap();
			}
		}
	}

	public static void connectFalseLogger(String id, String lock) throws Exception {
		try {
			StringUtil func = new StringUtil();
			
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
			
			String region = SessionHelper.getSession("lang");
			if(StringUtils.isNoneBlank(region)){
				region =  "NONE";
			}
			
			ThreadContext.put("id", UUID.randomUUID().toString()); // Add the fishtag;
			ThreadContext.put("LOGINERROR", lock); 
			ThreadContext.put("LOGONID", id); // 실패했기 때문에 시도한 id를 parameter로 넘김
			ThreadContext.put("REGION", region);
			ThreadContext.put("IPADDRESS", func.getRemoteIP(request));
			ThreadContext.put("OS", ClientInfoHelper.getClientOsInfo(request));
			ThreadContext.put("BROWSER", ClientInfoHelper.getClientWebKind(request)	+ ClientInfoHelper.getClientWebVer(request));
			ThreadContext.put("YEAR", DateHelper.getCurrentDay("yyyy"));
			ThreadContext.put("MONTH", DateHelper.getCurrentDay("MM"));
			ThreadContext.put("DAY", DateHelper.getCurrentDay("dd"));
			ThreadContext.put("HOUR", DateHelper.getCurrentDay("HH"));
			ThreadContext.put("LOGONAGENTINFO",ClientInfoHelper.getClientAgentInfo(request));

			CFLOGGER.info("DB connect false logging.");

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			ThreadContext.clearMap();
		}
	}

	public static void connectLogger() throws Exception {
		try {
			StringUtil func = new StringUtil();
			
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
			
			HttpSession session = request.getSession();
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			
			String usrCode = ( !userDataObj.isNullObject() && userDataObj.has("UR_Code") ) ? userDataObj.getString("UR_Code") : "NONE";
			String usrId =  ( !userDataObj.isNullObject() && userDataObj.has("USERID") ) ? userDataObj.getString("USERID") : "NONE";
			String usrLogonID = ( !userDataObj.isNullObject() && userDataObj.has("LogonID") ) ? userDataObj.getString("LogonID") : "NONE";
			String region = ( !userDataObj.isNullObject() && userDataObj.has("lang") ) ? userDataObj.getString("lang") : "NONE";
			String usrCompanyCode = ( !userDataObj.isNullObject() && userDataObj.has("DN_Code") ) ? userDataObj.getString("DN_Code") : "NONE";
			
			ThreadContext.put("id", UUID.randomUUID().toString()); // Add the fishtag;
			ThreadContext.put("USERID", usrId);
			ThreadContext.put("USERCODE", usrCode);
			ThreadContext.put("LOGONID", usrLogonID);
			ThreadContext.put("COMPANYCODE", usrCompanyCode);
			ThreadContext.put("REGION", region);
			ThreadContext.put("IPADDRESS", func.getRemoteIP(request));
			ThreadContext.put("OS", ClientInfoHelper.getClientOsInfo(request));
			ThreadContext.put("BROWSER", ClientInfoHelper.getClientWebKind(request)	+ ClientInfoHelper.getClientWebVer(request));
			ThreadContext.put("YEAR", DateHelper.getCurrentDay("yyyy"));
			ThreadContext.put("MONTH", DateHelper.getCurrentDay("MM"));
			ThreadContext.put("DAY", DateHelper.getCurrentDay("dd"));
			ThreadContext.put("HOUR", DateHelper.getCurrentDay("HH"));
			ThreadContext.put("LOGONAGENTINFO",ClientInfoHelper.getClientAgentInfo(request));
			ThreadContext.put("SESSIONID", session.getId());

			CLOGGER.info("DB connect logging");

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			ThreadContext.clearMap();
		}
	}

	public static void connectLogger(String usrId, String usrCode, String usrLogonID, String region) throws Exception {
		try {
			StringUtil func = new StringUtil();
			
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
			//향후 user 정보를 redis로 부터 가져 올 것
			HttpSession session = request.getSession();
			
			if(!StringUtils.isNoneBlank(usrId)){
				usrId = "NONE";
			}
			
			if(!StringUtils.isNoneBlank(usrCode)){
				usrCode = "NONE";
			}
			
			if(!StringUtils.isNoneBlank(usrLogonID)){
				usrLogonID = "NONE";
			}		
			
			if(!StringUtils.isNoneBlank(region)){
				region = "NONE";
			}
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			String usrCompanyCode = ( userDataObj != null && !userDataObj.isNullObject() && userDataObj.has("DN_Code") ) ? userDataObj.getString("DN_Code") : "NONE";
			
			/*
			 * MachineName - 삭제
			 * UserCode - 삭제
			 * Region - NONE
			 * Resolution - 삭제
			 * Week - 삭제
			 * */
			
			ThreadContext.put("id", UUID.randomUUID().toString()); // Add the fishtag;
			ThreadContext.put("USERID", usrId);
			ThreadContext.put("USERCODE", usrCode);
			ThreadContext.put("LOGONID", usrLogonID);
			ThreadContext.put("COMPANYCODE", usrCompanyCode);
			ThreadContext.put("REGION", region);
			ThreadContext.put("IPADDRESS", func.getRemoteIP(request));
			ThreadContext.put("OS", ClientInfoHelper.getClientOsInfo(request));
			ThreadContext.put("BROWSER", ClientInfoHelper.getClientWebKind(request)	+ ClientInfoHelper.getClientWebVer(request));
			ThreadContext.put("YEAR", DateHelper.getCurrentDay("yyyy"));
			ThreadContext.put("MONTH", DateHelper.getCurrentDay("MM"));
			ThreadContext.put("DAY", DateHelper.getCurrentDay("dd"));
			ThreadContext.put("HOUR", DateHelper.getCurrentDay("HH"));
			ThreadContext.put("LOGONAGENTINFO",ClientInfoHelper.getClientAgentInfo(request));
			ThreadContext.put("SESSIONID", session.getId());

			CLOGGER.info("DB connect logging");

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			ThreadContext.clearMap();
		}
	}
	
	
	public static void pageMoveLogger(String uri) throws Exception {
		pageMoveLogger(uri,"");
	}
	
	public static void pageMoveLogger(String uri, String objectType) throws Exception {
		
		String className = PropertiesUtil.getGlobalProperties().getProperty("logger.pagemove.class");
		if (className!= null && !className.equals("")){
			try {
				Class<?> c = Class.forName(className);
				Method  method = c.getMethod("pageMoveLogger", String.class, String.class);
				method.invoke(c, uri, objectType);
				return;
			} catch (NullPointerException e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			}	
		}
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
			
			CoviList params = new CoviList();
			Enumeration eNames = request.getParameterNames();
			if (eNames.hasMoreElements()) {
				while (eNames.hasMoreElements()) {
					String name = (String) eNames.nextElement();
					CoviMap param = new CoviMap();
					param.put(name, request.getParameterValues(name));
					params.add(param);
				}
			}
			

			ThreadContext.put("id", UUID.randomUUID().toString()); // Add the fishtag;
			ThreadContext.put("USERID", usrId);
			ThreadContext.put("USERCODE", usrCode);
			ThreadContext.put("LOGONID", usrLogonID);
			ThreadContext.put("COMPANYCODE", usrCompanyCode);
			ThreadContext.put("SITENAME",	request.getServerName() + ":" + String.valueOf(request.getServerPort()));
			ThreadContext.put("PAGEURL", pageUrl);
			ThreadContext.put("PAGEPARAM", params.toString());
			ThreadContext.put("IPADDRESS", func.getRemoteIP(request));
			ThreadContext.put("OBJECTTYPE", objectType);
		
			MLOGGER.error(pageUrl);

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			ThreadContext.clearMap();
		}
	}
	
	public static void pageMoveLoggerForSQL(String uri) throws Exception {
		pageMoveLoggerForSQL(uri,"");
	}

	public static void pageMoveLoggerForSQL(String uri, String objectType) throws Exception {
		
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
		}
	}
	
	public static void httpLog(CoviMap params) throws Exception {
		try {
			String LogType = (String) params.get("LogType");
			String Method = (String) params.get("Method");
			String ConnetURL = (String) params.get("ConnetURL");
			String RequestDate = (String) params.get("RequestDate");
			String ResultState = (String) params.get("ResultState");
			String ResultType = (String) params.get("ResultType");
			String ResponseMsg = params.optString("ResponseMsg");
			String ResponseDate = (String) params.get("ResponseDate");
			String RequestBody = params.optString("RequestBody");
			
			ThreadContext.put("LOGTYPE", LogType); 
			ThreadContext.put("METHOD", Method); 
			ThreadContext.put("CONNECTURL", ConnetURL); 
			ThreadContext.put("REQUESTDATE", RequestDate); 
			ThreadContext.put("RESULTSTATE", ResultState); 
			ThreadContext.put("RESULTTYPE", ResultType); 
			ThreadContext.put("RESPONSEMSG", ResponseMsg); 
			ThreadContext.put("RESPONSEDATE", ResponseDate); 
			ThreadContext.put("REQUESTBODY", RequestBody); 
		
			HLOGGER.info(params);

		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			ThreadContext.clearMap();
		}
	}
	
	public static void auditLogger(String id, String AuditManage, String KindsOfLog, String Message, String Reverved1, String Reverved2) throws Exception {
		try {
			StringUtil func = new StringUtil();
			
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
			
			ThreadContext.put("id", UUID.randomUUID().toString()); // Add the fishtag;
			ThreadContext.put("AUDITMANAGE", AuditManage); 
			ThreadContext.put("LOGINID", id); 
			ThreadContext.put("KINDSOFLOG", KindsOfLog); 
			
			ThreadContext.put("IPADDRESS", func.getRemoteIP(request));
			ThreadContext.put("OS", ClientInfoHelper.getClientOsInfo(request));
			ThreadContext.put("BROWSER", ClientInfoHelper.getClientWebKind(request)	+ ClientInfoHelper.getClientWebVer(request));
			ThreadContext.put("MESSAGE", Message);
			ThreadContext.put("RESERVED1", Reverved1);
			ThreadContext.put("RESERVED2", Reverved2);

			
			ALOGGER.info("Audit Logger logging");
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			ThreadContext.clearMap();
		}
	}
	
	public static void filedownloadLogger(String fileID, String fileUUID, String serviceType, String fileName, String downloadResult, String failReason) throws Exception {
		try {
			StringUtil func = new StringUtil();
			
			HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
			
			boolean isMobile = ClientInfoHelper.isMobile(request);
			
			CoviMap userDataObj = SessionHelper.getSession(isMobile);
			String usrCode = ( !userDataObj.isNullObject() && userDataObj.has("UR_Code") ) ? userDataObj.getString("UR_Code") : "NONE";
			
			ThreadContext.put("USERCODE", usrCode); 
			ThreadContext.put("FILEID", fileID); 
			ThreadContext.put("FILEUUID", fileUUID); 
			ThreadContext.put("SERVICETYPE", serviceType);
			ThreadContext.put("FILENAME", fileName);
			ThreadContext.put("ISMOBILE", isMobile ? "Y" : "N");
			ThreadContext.put("IPADDRESS", func.getRemoteIP(request));
			ThreadContext.put("REFERURL", egovframework.baseframework.filter.XSSUtils.XSSFilter(request.getHeader("referer")));
			ThreadContext.put("DOWNLOADRESULT", downloadResult);
			ThreadContext.put("FAILREASON", failReason);
			
			FLOGGER.info("filedownload Logger logging");
			
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} finally {
			ThreadContext.clearMap();
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
		} catch (NullPointerException e) {
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
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
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
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		
		return logChangeID;
	}

	
}
