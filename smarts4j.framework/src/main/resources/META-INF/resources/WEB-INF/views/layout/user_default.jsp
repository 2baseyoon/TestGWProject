<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.RedisDataUtil,egovframework.coviframework.util.SessionCommonHelper,java.util.Arrays"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
String[] arr = new String[]{"ptype01", "ptype02", "ptype03"};
String CLSYS = request.getParameter("CLSYS")==null?"":request.getParameter("CLSYS");
String CLBIZ = request.getParameter("CLBIZ")==null?"":request.getParameter("CLBIZ");
String CLTRG = request.getParameter("CLTRG")==null?"":request.getParameter("CLTRG");
%>
<!doctype html>
<html lang="ko" <%=(!CLTRG.equals("P")&&!Arrays.asList(arr).contains(SessionCommonHelper.getSession("UR_PortalCode"))?"data-direction='"+(SessionCommonHelper.getSessionMapKey("PortalOption","direction","horizontal"))+"'":"")%>  data-theme="<%=SessionCommonHelper.getSessionMapKey("PortalOption","theme","default")%>"  data-mode="<%=SessionCommonHelper.getSessionMapKey("PortalOption","mode","light")%>">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=1280">
    <meta name="format-detection" content="telephone=no">
	<title><%=PropertiesUtil.getGlobalProperties().getProperty("front.title") %></title>
    <link rel="shortcut icon" href="../common/images/favicon.ico">
   	<tiles:insertAttribute name="include" />
</head>
<%
if (SessionCommonHelper.getSessionMapKey("PortalOption","portalBg","image-1").equals("image-custom")){ %>
<style>
.ui_portal .portal_background[data-background=image-custom] {
	background-image:url('/covicore/common/photo/photo.do?img=<%=SessionCommonHelper.getSessionMapKey("PortalOption","portalBgPath","")%>') 
}
<%}%>
</style>
<!-- groupware/user_default  -->
<body class="portalBodyWrap<%=CLBIZ.equals("Portal")?" portal_wrap":""%>">	
	<div class="ui_app<%=CLSYS.equals("portalEx")?" ui_portal":""%><%=(!SessionCommonHelper.getSessionMapKey("PortalOption","contentsBg","").equals("Y")?" normal":"")%>" data-current-view="<%=(SessionCommonHelper.getSessionMapKey("PortalOption","onlyContents","N").equals("Y")?"one":"main")%>" data-text-color="<%=SessionCommonHelper.getSessionMapKey("PortalOption","portalText","black")%>">
 		<div class="portal_background" data-background="<%=SessionCommonHelper.getSessionMapKey("PortalOption","portalBg","black-1")%>"></div>
	    <div class="portal_dim"  <%=(SessionCommonHelper.getSessionMapKey("PortalOption","dim","").equals("Y")?"":"hidden")%>></div>
<% if (!CLTRG.equals("P")){%> 
		<div class="ui_global" >
			<tiles:insertAttribute name="header" />
		</div>
<%}	
	if (!CLTRG.equals("P")&&!Arrays.asList(arr).contains(SessionCommonHelper.getSession("UR_PortalCode"))){%>
		<div class="ui_dock" id="portal_dock" aria-expanded="true">
			<tiles:insertAttribute name="dock" />
		</div> 
<%	} 
	if (CLSYS.equals("portalEx")){%>
		<div class="portal_root" id="portal_content">
			<tiles:insertAttribute name="portal_content" />
			<jsp:include page="/WEB-INF/views/cmmn/user_guide.jsp"></jsp:include> 
		</div>	
<%	}%>
		<section id="<%=(CLTRG.equals("P")?"poup_container":"comm_container")%>" <%=(CLSYS.equals("portalEx")?"style='display:none'":"") %>>
			<section class="commContent">
				<%if (PropertiesUtil.getGlobalProperties().getProperty("tab.mode") != null && PropertiesUtil.getGlobalProperties().getProperty("tab.mode").equals("Y")){%>
				<div class=ui_tab_menu  id="ui_tab_menu" <%=(CLBIZ.equals("Portal")?"style='display:none'":"")%>>
					<div class="tab_menu_list">
					</div>
					<div class="tab_menu_more">
	                    <button type="button" class="ui_icon_button more_toggle toggle_more_context_menu" data-icon="more"><span>더보기</span></button>
	                    <div class="ui_more_context_menu">
	                        <button type="button" class="ui_button" data-close-type="other"><span>탭저장</span></button>
	                        <button type="button" class="ui_button" data-close-type="all"><span>모든 탭 닫기</span></button>
	                        <div class="auto"></div>
	                    </div>
	                </div>
	                <button type="button" class="tab_menu_toggle" data-icon="toggle"><span>접기</span></button>
				</div><!--  탭영역 -->
				<%} %>
				<div id="left" class="commContLeft" data-section="<%=(CLBIZ.equals("Portal")?"portal":CLSYS)%>" <%=(CLBIZ.equals("Portal")?"style='display:none'":"")%>>
					<tiles:insertAttribute name="left" />
				</div>
<% if (!CLTRG.equals("P")){%> 
				<div id="btnFolderOpen" class="btn_foldArea cLnbToggle" <%=(CLBIZ.equals("Portal")?"style='display:none'":"")%>>
					<a href="#" id="" class="btnOpen" onclick="" style="display: none;"><spring:message code='Cache.lbl_Open'/></a> <!-- 열기 -->
					<a href="#" id="" class="btnClose" onclick="" style="display: block;"><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
				</div>
<%} %>
				<div id="contents" class="<%=(CLBIZ.equals("Portal")?(SessionCommonHelper.getSessionMapKey("PortalOption","mode","light").equals("dark")?"PN_darkmode":""):"commContRight")%>">
					<div id="tab"  class="accountTab" <%=(CLBIZ.equals("Account")?"":"style='display:none'") %>>
						<tiles:insertAttribute name="tab" />
					</div>
					<div class="<%=(CLBIZ.equals("Account")?"accountContent":"")%>"  id="content" role="tabpanel" aria-labelledby="tab-1">	<!-- 일반 업무영역 -->
						<%if (!CLBIZ.equals("Account")) {%>
						<tiles:insertAttribute name="content" />
						<%}%>
					</div>
				</div>
			</section>
		</section>
	</div>
	<tiles:insertAttribute name="addtion" />
</body>
</html>