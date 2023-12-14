<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="false"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>  
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<link rel="stylesheet" type="text/css" href="/covicore/resources/css/font-awesome-4.7.0/css/font-awesome.min.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/admin_common_controls.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXJ.min.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/admin.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/page.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery-ui-1.12.1.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXGrid.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.control.css<%=resourceVersion%>" />	
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/jquery.treetable.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/jquery.treetable.theme.default.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/palette-color-picker.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXTree.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/AXMuliSelector.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/AXSegment.css<%=resourceVersion%>" />	
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXTabs.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.calendar.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/style.css<%=resourceVersion%>"/>

<%-- 21.12.29, 도메인 분리로 인해 도메인 관리자의 소유회사 선택 내용 display none 처리. --%>
<%
String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "");

if (isSaaS.equalsIgnoreCase("Y") && !egovframework.baseframework.util.SessionHelper.getSession("DN_ID").equalsIgnoreCase("0")){
	out.print("<style>"+
	".domain {display:none}"+
	"</style>");
}	
%>

<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/jquery-ui-1.12.1.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/activiti/manageActiviti.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXGrid.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/idle-timer.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.editor.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.comment.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.file.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.menu.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.acl.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.dic.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.orgchart.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.control.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.notify.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.calendar.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Dictionary.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.treetable.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/validation.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.policy.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/autosize.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/palette-color-picker.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/html2canvas.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXTree.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXInput.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXInputPro.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXMultiSelector.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXValidator.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXSelect.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXTab.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/ExControls/Chart.js-master/Chart.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Jsoner/Jsoner.0.8.2.js<%=resourceVersion%>"></script>
<!-- covision util 함수  -->
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.util.js<%=resourceVersion%>"></script>

<script type="text/javascript">
	var PARAM_VALID="<%=egovframework.coviframework.util.StringUtil.replaceNull(PropertiesUtil.getSecurityProperties().getProperty("param.valid"),"N")%>";
	const tabMode = "N";
</script>
