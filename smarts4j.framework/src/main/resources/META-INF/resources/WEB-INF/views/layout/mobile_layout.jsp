<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="egovframework.coviframework.util.SessionCommonHelper,egovframework.baseframework.data.CoviMap"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%
	String useTeamsAddIn = "N";
	String userAgent = request.getHeader("User-Agent");
	String pIsTeamsAddIn = request.getParameter("teamsaddin");
    if ((userAgent != null && userAgent.toLowerCase().indexOf("teams") > -1) || (pIsTeamsAddIn != null && pIsTeamsAddIn.toUpperCase().equals("Y"))) {
    	useTeamsAddIn = "Y";
    }
%>
<!DOCTYPE html>
<html lang="ko"  class="portal<%=(useTeamsAddIn.equals("Y")?" teams":"") %>" data-theme="<%=SessionCommonHelper.getSessionMapKey("PortalOption","mbTheme","default")%>"  data-mode="<%=SessionCommonHelper.getSessionMapKey("PortalOption","mbMode","light")%>">

	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<%-- <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=yes, target-densitydpi=medium-dpi"> --%>
		<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=3.0, minimum-scale=1.0, user-scalable=yes, target-densitydpi=medium-dpi, viewport-fit=cover">
		<title>SmartS4j Mobile</title>
		
		<tiles:insertAttribute name="include" />
	</head>
	<body>
	
		<div id="mobile_left" style="display:none;">
			<h1 style="display:none;">mobile_left</h1>
			<tiles:insertAttribute name="left" />
		</div>
	
		<div id="mobile_content">
		
			<input type="hidden" id="mobile_locationcode"/>
			<input type="hidden" id="mobile_locationaddress"/>
			<% if (!"Y".equals(useTeamsAddIn)) { %>
			<!-- 웹용 하단 메뉴(메뉴열림) 시작 --> 
			<div class="BmenuWrap" id="btnBottomMenuLayout" style="display:none;">
		        <a id="btnBottomMenuOpen" onclick="mobile_comm_BottomMenuLayout(this)" class="Bmenu_open">닫힘</a>
				<div class="Bmenu" id="btnBottomMenu" style="display:none;">
					<ul>
						<li><a onclick="mobile_comm_openleftmenu()" class="ico_b_allmenu">전체메뉴</a></li>
						<li><a onclick="mobile_comm_go('/groupware/mobile/portal/main.do')" class="ico_b_home">홈</a></li>
						<li><a onclick="mobile_comm_go('/groupware/mobile/portal/integrated.do')" class="ico_b_notice">알림</a></li>
						<li><a onclick="mobile_comm_go('/covicore/mobile/org/list.do')" class="ico_b_org">조직도</a></li>
						<li><a onclick="mobile_comm_logout()" class="ico_b_logout">로그아웃</a></li>
					</ul>
				</div>
		    </div>
			<!-- 웹용 하단 메뉴(메뉴열림) 끝 -->		
			<%} %>	
			<h1 style="display:none;">mobile_content</h1>
			<tiles:insertAttribute name="content" />
		</div>
				
		<div id="mobile_home_addjobpop" class="mobile_popup_wrap" style="display:none;"></div>
		<div id="mobile_loading" class="mobile_loading" style="display: none;">
			<div class="mobile_loading_img"></div>
		</div>
		
	</body>
</html>