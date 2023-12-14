<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Error</title>
</head>
<%String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode"); %>

<body>
    <c:if test="${not empty exception}">
    	<h2>System Errors - 관리자에게 문의하여 주세요.</h2>
    	<%if (isDevMode.equalsIgnoreCase("Y")){%>
		<h3>${exception}</h3>
		<%}%>
	</c:if>
</body>
</html>