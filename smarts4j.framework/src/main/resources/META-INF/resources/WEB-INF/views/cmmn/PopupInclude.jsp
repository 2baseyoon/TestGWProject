<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.RedisDataUtil"%>
<%@ page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page import="egovframework.coviframework.util.SessionCommonHelper"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<% 
	String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path");
 	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	
	pageContext.setAttribute("isUseMail", PropertiesUtil.getExtensionProperties().getProperty("isUse.mail"));
	pageContext.setAttribute("isUseAccount", PropertiesUtil.getExtensionProperties().getProperty("isUse.account"));
	pageContext.setAttribute("isUseProjectmng", PropertiesUtil.getExtensionProperties().getProperty("isUse.projectmng"));
	pageContext.setAttribute("isUseWebhard", PropertiesUtil.getExtensionProperties().getProperty("isUse.webhard"));
	pageContext.setAttribute("isUseBizMnt", PropertiesUtil.getExtensionProperties().getProperty("isUse.bizMnt"));
	pageContext.setAttribute("isUseHrManage", PropertiesUtil.getExtensionProperties().getProperty("isUse.hrmanage"));
	pageContext.setAttribute("themeType", SessionCommonHelper.getSessionMapKey("PortalOption","theme","purple"));
	pageContext.setAttribute("themeCode", SessionCommonHelper.getSession("UR_ThemeCode"));
	pageContext.setAttribute("LanguageCode", SessionHelper.getSession("LanguageCode"));	
	pageContext.setAttribute("projectCode", ("".equals(RedisDataUtil.getBaseConfig("projectCode"))) ? SessionCommonHelper.getSession("UR_ThemeCode") : RedisDataUtil.getBaseConfig("projectCode"));
%>
<link rel="stylesheet" id="languageCSS" type="text/css" href="<%=cssPath%>/covicore/resources/css/language/<c:out value="${LanguageCode}"/>.css<%=resourceVersion%>" />



<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXJ.min.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXGrid.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXTree.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery.mCustomScrollbar.css<%=resourceVersion%>"/>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.control.css<%=resourceVersion%>" />	
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/user_common_controls.css<%=resourceVersion%>" />  
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/Controls.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery-ui-1.12.1.css<%=resourceVersion%>" />

<!-- 서버용 -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval.css<%=resourceVersion%>"/>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/survey/resources/css/survey.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/schedule/resources/css/schedule.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/resource/resources/css/resource.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/board/resources/css/board.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/doc/resources/css/doc.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/bizcard/resources/css/bizcard.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/community/resources/css/community.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/task/resources/css/task.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/myInfo/resources/css/myInfo.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/extension/resources/css/extension.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/VacationManager/resources/css/VacationManager.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery-ui-1.12.1.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/palette-color-picker.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/slick.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/AttendanceManagement/resources/css/AttendanceManagement.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/AttendanceManagement/resources/css/AttendanceMgt.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/IntegratedTaskManagement/resources/css/IntegratedTaskManagement.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/collaboration/resources/css/collaboration.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/appstore/resources/css/appstore.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/contentsApp/resources/css/contentsApp.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.calendar.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/SaaSUserGuide/resources/css/SaaSUserGuide.css<%=resourceVersion%>">
    
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/style.css<%=resourceVersion%>"/>

<c:if test="${isUseMail eq 'Y'}"><link rel="stylesheet" type="text/css" href="<%=cssPath%>/mail/resources/css/mail.css<%=resourceVersion%>" /></c:if>
<c:if test="${isUseAccount eq 'Y'}"><link rel="stylesheet" type="text/css" href="<%=cssPath%>/eaccounting/resources/css/eaccounting.css<%=resourceVersion%>"></c:if>
<c:if test="${isUseProjectmng eq 'Y'}"><link rel="stylesheet" type="text/css" href="<%=cssPath%>/project/resources/css/Project_m.css<%=resourceVersion%>"></c:if>
<c:if test="${isUseWebhard eq 'Y'}"><link rel="stylesheet" type="text/css" href="<%=cssPath%>/webhard/resources/css/webhard.css<%=resourceVersion%>" /></c:if>
<c:if test="${isUseBizMnt eq 'Y'}"><link rel="stylesheet" type="text/css" href="<%=cssPath%>/BusinessManagement/resources/css/BusinessManagement.css<%=resourceVersion%>" /></c:if>
<c:if test="${isUseHrManage eq 'Y'}"><link rel="stylesheet" type="text/css" href="<%=cssPath%>/personnel/resources/css/personnel.css<%=resourceVersion%>"></c:if>

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/public/resources/css/public.css<%=resourceVersion%>" />

<!-- 순서 : theme/project/color -->
<link rel="stylesheet" id="themeCSS" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/${empty themeType?'blue':themeType}.css<%=resourceVersion%>" />
<link rel="stylesheet" id="projectCSS" type="text/css" href="<%=cssPath%>/customizing/<c:out value="${projectCode}"/>/css/project.css<%=resourceVersion%>" />
<c:choose>
	<c:when test="${themeType == 'green'}">
		<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/<c:out value="${themeCode}"/>/css/color_02.css<%=resourceVersion%>" />
	</c:when>
	<c:when test="${themeType == 'red'}">
		<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/<c:out value="${themeCode}"/>/css/color_03.css<%=resourceVersion%>" />
	</c:when>
	<c:when test="${themeType == 'black'}">
		<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/<c:out value="${themeCode}"/>/css/color_04.css<%=resourceVersion%>" />
	</c:when>
	<c:when test="${themeType == 'blue'}">
		<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/<c:out value="${themeCode}"/>/css/color_05.css<%=resourceVersion%>" />
	</c:when>
	<c:otherwise><!-- pupple -->
		<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/<c:out value="${themeCode}"/>/css/color_01.css<%=resourceVersion%>" />
	</c:otherwise>	
</c:choose>

<!-- JavaScript -->
<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.mousewheel.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.mCustomScrollbar.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/jquery-ui-1.12.1.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXTree.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
 <%if ( request.getParameter("commonMapUse") == null || "Y".equals(request.getParameter("commonMapUse"))){ %>
<script type="text/javascript" src="/covicore/resources/script/Controls/CommonMap.js<%=resourceVersion%>"></script>
<% }%>
<script type="text/javascript" src="/covicore/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.menu.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.dic.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.control.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/autosize.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/validation.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.slimscroll.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Jsoner/Jsoner.0.8.2.js<%=resourceVersion%>"></script>
