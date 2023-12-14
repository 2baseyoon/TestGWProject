<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>

<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% 
	String resourceVersion = PropertiesUtil.getGlobalProperties().getProperty("resource.version", ""); 
	resourceVersion = resourceVersion.equals("") ? "" : ("?ver=" + resourceVersion);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

<script type="text/javascript" src="<%=appPath%>/resources/script/jquery-1.8.0.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/MicrosoftTeams.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>

<script>
	var mode = "${mode}";
	var token = "${token}";
	var ReturnUrl = "${ReturnUrl}";
	var width = "${width}";
	var height = "${height}";
	var etcparam = "${etcparam}";
	var logonid = "${logonid}";
	var lang = "${lang}";
	var errorMessage = "${errorMessage}";

	$(window).load(function () {
		if(errorMessage != ""){
			$("#divErrorMessage").text("Error : " + errorMessage);	
		}else{
            $("#mode").val(mode);
            $("#token").val(token);
            $("#ReturnUrl").val(ReturnUrl);
            $("#width").val(width);
            $("#height").val(height);
            $("#etcparam").val(etcparam);
            $("#logonid").val(logonid);
            $("#lang").val(lang);
            
        	document.getElementById("formAuth").action = "/covicore/teamsSLOLogin.do";
            document.getElementById("formAuth").submit();
		}
	});
	
</script>

</head>
<body>
	<form method="post" id="formAuth" target="_self">
        <div id="divErrorMessage" style="font-size:14pt; font-weight:bold;"></div>
		<input type="hidden" id="mode" name="mode" value=""/>
		<input type="hidden" id="token" name="token" value=""/>
		<input type="hidden" id="ReturnUrl" name="ReturnUrl" value=""/>
		<input type="hidden" id="width" name="width" value=""/>
		<input type="hidden" id="height" name="height" value=""/>
		<input type="hidden" id="etcparam" name="etcparam" value=""/>
		<input type="hidden" id="logonid" name="logonid" value=""/>
		<input type="hidden" id="lang" name="lang" value=""/>
	</form>
</body>
