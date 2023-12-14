<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ page import="egovframework.baseframework.util.SessionHelper" %>
<%@ page import="egovframework.baseframework.data.CoviMap" %>

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

<%
	out.println("<script>");
	out.println("function setTeamsSessionData(sessionKey, sessionValue) {");
   	out.println("var _TeamIsLocalStorage = true;");
   	out.println("try {");
   	out.println("sessionStorage.setItem('test', 'test');");
   	out.println("sessionStorage.removeItem('test');");
   	out.println("} catch(e) {");
   	out.println("_TeamIsLocalStorage = false;");
   	out.println("}");
   	out.println("if (_TeamIsLocalStorage) {");
   	out.println("sessionStorage.removeItem(sessionKey); var sessionStoragedItem = { _ : new Date().getTime(), data : sessionValue }; sessionStorage.setItem(sessionKey, JSON.stringify(sessionStoragedItem));");
   	out.println("} else {");
   	out.println("localCache.remove(sessionKey); localCache.data[sessionKey] = { _ : new Date().getTime(), data : value };");
   	out.println("}");
   	out.println("}");
   	CoviMap sessionObj = SessionHelper.getSession();
   	java.util.Iterator arrKeys = sessionObj.keys();
   	out.println("setTeamsSessionData(\"SESSION_all\", $.parseJSON(\"" + sessionObj.toJSONString().replace("\"", "\\\"") + "\"));");
   	
	while (arrKeys.hasNext()) {
        String sessionKey = arrKeys.next().toString();

    	out.println("setTeamsSessionData(\"SESSION_" + sessionKey + "\", \"" + sessionObj.getString(sessionKey) + "\");");
	}
    
    out.println("</script>");
%>
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
	var width = "${width}";
	var height = "${height}";
	var etcparam = "${etcparam}";
	var errorMessage = "${errorMessage}";

	$(window).load(function () {
		if (errorMessage != "") {
			$("#divErrorMessage").text("Error : " + errorMessage);	
		} else {
			if (mode == "REDIRECT") {
				location.href = ReturnUrl;
			} else {
				var nWidth = parseInt(width, 10);
				var nHeight = parseInt(height, 10);
                var nTop = (window.screen.height / 2) - (nHeight / 2) - 70;
                var nLeft = (window.screen.width / 2) - (nWidth / 2);
                var sEtcParam = "";
                if (etcparam == 'fix') {
                    sEtcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=0";
                    nTop = (window.screen.height / 2) - (nHeight / 2) - 40;
                } else if (etcparam == 'resize') {
                    sEtcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=1";
                    nTop = (window.screen.height / 2) - (nHeight / 2) - 40;
                } else if (etcparam == 'scroll') {
                    sEtcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=1,resizable=0";
                } else if (etcparam == 'both') {
                    sEtcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=1,resizable=1";
                } else if (etcparam == 'all') {
                    sEtcParam = "toolbar=1,location=1,directories=1,status=1,menubar=1,scrollbars=1,resizable=1";
                } else {
                    sEtcParam = "toolbar=1,location=1,directories=1,status=1,menubar=1,scrollbars=1,resizable=1";
                }
                if (nTop < 0) { nTop = 0; }

                var oPopup = window.open(ReturnUrl, null, sEtcParam + ",width=" + nWidth + ",height=" + nHeight + ",top=" + nTop + "px,left=" + nLeft + "px");
                try {
                    oPopup.focus();
                    window.open("about:blank", "_self").close(); // 창닫기
                } catch (e) {
                    alert("팝업 차단을 해제 후 다시 시도하세요.");
                }
			}
		}
	});
	
</script>

</head>
<body>
	<div id="divErrorMessage" style="font-size:14pt; font-weight:bold;"></div>
</body>
