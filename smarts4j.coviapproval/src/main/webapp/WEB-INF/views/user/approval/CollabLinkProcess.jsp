<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@ page import="org.springframework.web.context.WebApplicationContext"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ page import="egovframework.covision.coviflow.user.service.ApprovalListSvc"%>

<html>
<head>
<script type="text/javascript">
function setProgress(idx){
	parent.callbackCollabTrans('progress', idx)
}
function setComplete(status, totalCnt, successCnt, failCnt, msg){
	var params = {
			status : status
			, totalCnt : totalCnt
			, successCnt : successCnt
			, failCnt : failCnt 
			, msg : msg
	};
	parent.callbackCollabTrans('complete', params);
}
</script>
<%

out.flush();
ServletContext servletContext = getServletContext();

WebApplicationContext waContext = WebApplicationContextUtils.getRequiredWebApplicationContext(servletContext);

ApprovalListSvc service = (ApprovalListSvc) waContext.getBean("approvalListService");

Map<String, String> param = new HashMap<String, String>();
Enumeration eParam = request.getParameterNames();
while (eParam.hasMoreElements()) {
    String pName = (String)eParam.nextElement();
    String pValue = request.getParameter(pName);

    param.put(pName, pValue);
}
service.transferCollabLink(request, response, param, out);

out.flush();
%>
</head>
</html>