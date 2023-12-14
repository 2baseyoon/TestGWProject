<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>

<!doctype html>
<html lang="ko">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=1280">
	<title><%=PropertiesUtil.getGlobalProperties().getProperty("front.title") %></title>
	<tiles:insertAttribute name="include" />
</head>
<!-- groupware/user_default  -->
<body>	
	<div id="wrap">
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
				<div id="left" class="commContLeft">
					<tiles:insertAttribute name="left" /> 
				</div>
				<div id="contents" class="commContRight">
					<div id="tab">
						<tiles:insertAttribute name="tab" />
					</div>
					<div id="content">
						<tiles:insertAttribute name="content" />
					</div>			
				</div>				
			</section>
				
			<aside class="simpleMakeLayerPopUp">
				<jsp:include page="/WEB-INF/views/cmmn/SimpleMake.jsp"></jsp:include>
			</aside>
						
			<!-- <aside id="secretaryContainer" class="secretary_cont new off"></aside> -->
		</section>
	</div>
</body>
</html>