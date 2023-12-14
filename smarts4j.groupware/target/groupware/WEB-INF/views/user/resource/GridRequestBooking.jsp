<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/resource.js<%=resourceVersion%>"></script>

<body>
	<div class="tblList tblCont type02" style="overflow-x: hidden; overflow-y: auto; height: 100%;">
		<div id="RequestListGrid"></div>					
	</div>
</body>

<script>
	resourceUser.resource_MakeRequestList();
</script>