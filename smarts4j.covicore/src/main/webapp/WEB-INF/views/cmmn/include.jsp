<%@ page session="false"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib prefix="validator" uri="http://www.springmodules.org/tags/commons-validator" %>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<!doctype html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>coviFlow</title>

<!-- CSS 통합 -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/user_common_controls.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/user.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXJ.min.css<%=resourceVersion%>" />
<!-- <link rel="stylesheet" type="text/css" href="https://netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css<%=resourceVersion%>" /> -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/page.css<%=resourceVersion%>" />


<!-- Common -->

<script type="text/javascript" src="<%=appPath%>/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/activiti/manageActiviti.js<%=resourceVersion%>"></script>

<!-- slimscroll -->
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/jquery.slimscroll.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/jquery.slimscroll.min.js<%=resourceVersion%>"></script>

<!-- Layer Popup -->
<!-- <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css<%=resourceVersion%>"> -->
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery-ui.js<%=resourceVersion%>"></script>
<!-- <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js<%=resourceVersion%>"></script> -->


<!-- top menu -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXToolBar.css<%=resourceVersion%>" />





<!-- grid -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXGrid.css<%=resourceVersion%>" />
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.file.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.menu.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.acl.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.dic.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.orgchart.js<%=resourceVersion%>"></script>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.control.css<%=resourceVersion%>" />	
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.control.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.treetable.js<%=resourceVersion%>"></script>
<!-- <link rel="stylesheet" type="text/css" href="/covicore/resources/css/jquery.treetable.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="/covicore/resources/css/jquery.treetable.theme.default.css<%=resourceVersion%>" /> -->





<!-- Tree -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXTree.css<%=resourceVersion%>" />
<%-- <script type="text/javascript" src="<%=appPath%>/resources/script/Controls/coviTree.js<%=resourceVersion%>"></script> --%>





<!-- Input -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/AXMuliSelector.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/AXSegment.css<%=resourceVersion%>" />		<!-- 함수에 입력하는 사용자 지정 css명 -->
<%-- <script type="text/javascript" src="<%=appPath%>/resources/script/Controls/coviInput.js<%=resourceVersion%>"></script> --%>









<!-- Chart  -->
<script type="text/javascript" src="<%=appPath%>/resources/ExControls/Chart.js-master/Chart.js<%=resourceVersion%>"></script>
<%-- <script type="text/javascript" src="<%=appPath%>/resources/ExControls/Chart.js-master/Chart.HorizontalBar.js<%=resourceVersion%>"></script> --%>





<!-- Utils -->
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>



<!-- Tabs -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXTabs.css<%=resourceVersion%>" />

<!-- Jsoner -->
<script type="text/javascript" src="<%=appPath%>/resources/script/Jsoner/Jsoner.0.8.2.js<%=resourceVersion%>"></script>


<!-- User -->
<!-- <!-- Tree -->
<!-- <!-- Input -->
<!-- <!-- Tabs -->

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/theme.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>" />

</head>