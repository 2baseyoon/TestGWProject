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

<div class="tblList tblCont shceduleListViewCont">
	<div id="ListGrid" style="height: auto;">
	</div>
	<div class="goPage">
		<input type="text"> <span> / <spring:message code='Cache.lbl_total' /> </span><span>1</span><span><spring:message code='Cache.lbl_page' /></span><a class="btnGo">go</a><!-- 총 ? 페이지 / go -->
	</div>							
</div>

<script>
	resourceUser.resource_MakeList();
</script>