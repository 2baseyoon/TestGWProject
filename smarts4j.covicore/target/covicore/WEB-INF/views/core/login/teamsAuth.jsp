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
	var ReturnUrl = "${ReturnUrl}";
	var actionURL = "${actionURL}";
	var width = "${width}";
	var height = "${height}";
	var etcparam = "${etcparam}";
	var errorMessage = "${errorMessage}";

	$(window).load(function () {
		if(errorMessage != ""){
			$("#divErrorMessage").text("Error : " + errorMessage);	
		}else{
		    // Teams 테마 처리
		    microsoftTeams.initialize(window);
		    microsoftTeams.registerOnThemeChangeHandler(function (pTheme) {
		        // default dark contrast
		        CFN_SetCookieDay("Teams_Theme", pTheme, 31536000000);
		    });
		
		    microsoftTeams.appInitialization.notifySuccess();
		
		    window.setTimeout(function () {
		        microsoftTeams.initialize(window);
		        microsoftTeams.getContext(function (oResultContext) {
		        	CFN_SetCookieDay("Teams_Theme", oResultContext.theme, 31536000000);
		        });
		    }, 500);

	        if (microsoftTeams) {
	            microsoftTeams.initialize(window);
	            microsoftTeams.authentication.getAuthToken({
	                silent: true,
	                successCallback: function (oResultAuth) {
	                    $("#authToken").val(oResultAuth);
	                    microsoftTeams.getContext(function (oResultContext) {
	                    	CFN_SetCookieDay("Teams_Theme", oResultContext.theme, 31536000000);
	                        $("#mode").val(mode);
	                        $("#ReturnUrl").val(ReturnUrl);
	                        $("#upn").val(oResultContext.userPrincipalName);
	                        $("#locale").val(oResultContext.locale);
	                        
                        	document.getElementById("formAuth").action = actionURL;
	                        document.getElementById("formAuth").submit();
	                    });
	                },
	                failureCallback: function (oResult) {
	                    alert("getAuthToken Error : " + oResult);
	                }
	            });
	        }
		}
	});
	
</script>

</head>
<body>
	<form method="post" id="formAuth" target="_self">
        <div id="divErrorMessage" style="font-size:14pt; font-weight:bold;"></div>
		<input type="hidden" id="mode" name="mode" value=""/>
		<input type="hidden" id="ReturnUrl" name="ReturnUrl" value=""/>
		<input type="hidden" id="upn" name="upn" value=""/>
		<input type="hidden" id="locale" name="locale" value=""/>
		<input type="hidden" id="width" name="width" value=""/>
		<input type="hidden" id="height" name="height" value=""/>
		<input type="hidden" id="etcparam" name="etcparam" value=""/>
		<input type="hidden" id="authToken" name="authToken" value=""/>
	</form>
</body>
