<%@ page session="false"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib prefix="validator" uri="http://www.springmodules.org/tags/commons-validator" %>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>

<!doctype html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>covision</title>

<!-- Common -->

<script type="text/javascript" src="<%=appPath%>/resources/script/jquery.min.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXJ.min.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/activiti/manageActiviti.js"></script>

<!-- slimscroll -->
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/jquery.slimscroll.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/jquery.slimscroll.min.js"></script>

<!-- Layer Popup -->
<link rel="stylesheet" href="<%=cssPath%>/covicore/resources/css/jquery-ui.css">
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery-ui.js"></script>
<!-- <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script> -->


<!-- top menu -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXToolBar.css" />
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXTopDownMenu.js"></script>





<!-- grid -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXGrid.css" />
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXGrid.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/CommonControls.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Common.js"></script>






<!-- Select  -->
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXSelect.js"></script>




<!-- Utils -->
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Utils.js"></script>


<!-- Jsoner -->
<script type="text/javascript" src="<%=appPath%>/resources/script/Jsoner/Jsoner.0.8.2.js"></script>



<%-- <link rel="stylesheet" href="<%=appPath%>/resources/script/jquerymobile/jquery.mobile-1.4.5.min.css" /> --%>
<%-- <link rel="stylesheet" href="<%=cssPath%>/mobile/jqueryui/jquery-ui.css"> --%>
<%-- <script src="<%=appPath%>/resources/script/jquerymobile/jquery.mobile-1.4.5.min.js"></script> --%>
<link rel="stylesheet" href="<%=cssPath%>/covicore/resources/css/jquery.mobile-1.4.5.min.css" />
<script type="text/javascript" src="<%=appPath%>/resources/script/Mobile/jquery.mobile-1.4.5.min.js"></script>




</head>