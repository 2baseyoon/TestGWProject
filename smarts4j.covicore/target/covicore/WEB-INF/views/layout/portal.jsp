<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.RedisDataUtil,egovframework.baseframework.util.SessionHelper"%>
<%
	pageContext.setAttribute("DarkMode", SessionHelper.getSession("DarkMode"));
%>
<!doctype html>
<html lang="ko">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=1280">
	<title><%=PropertiesUtil.getGlobalProperties().getProperty("front.title") %></title>
	<tiles:insertAttribute name="include" />
</head>
<body class="portalBodyWrap">	
	<c:choose>
		<c:when test='${DarkMode == "Y"}'><div id="wrap" class="PN_darkmode"></c:when>
		<c:otherwise><div id="wrap"></c:otherwise>
	</c:choose>
		<header id="header" class="clear">
			<tiles:insertAttribute name="header" />
		</header>
		<section id="comm_container">
			<aside class="favoritCont">
				<div class="faovriteListCont mScrollV">
					<ul id="quickContainer" class="favoriteList"></ul>			
				</div>
				<ul id="quickSetContainer" class="favorite_set clear"></ul>
			</aside>
			
			<section class="commContent">
				<div id="content">
					<tiles:insertAttribute name="content" />				
				</div>
				<%if(RedisDataUtil.getBaseConfig("useWorkPortal").equals("Y")){ %>
					<section id="work_portal" class="mainContent work_pop clearFloat" style="right: -100%;"></section>
				
					 <!-- [s]업무형 포탈 여닫기버튼 -->
		            <div class="btn_work close"> <a href="#"></a> <span class="toolTip2">기본포탈</span> </div>
		            <div class="btn_work open"> <a href="#"></a> <span class="toolTip1">업무포탈</span> </div>
				    <!-- [e]업무형 포탈 여닫기버튼 -->
				<%} %>
			</section>
			
			<aside class="simpleMakeLayerPopUp">
				<jsp:include page="/WEB-INF/views/cmmn/SimpleMake.jsp"></jsp:include>
			</aside>
						
			<!-- <aside id="secretaryContainer" class="secretary_cont new off"></aside> -->
		</section>
	</div>
</body>
</html>