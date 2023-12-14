<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ page import="egovframework.coviframework.util.StringUtil" %>
<%@ page import="egovframework.core.sso.oauth.*" %>
<%@ page import="java.util.*" %>
<%@ page import="net.sf.json.JSONObject" %>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<title>Login</title>

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/admin_common_controls.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/logon.css<%=resourceVersion%>" />

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval.css<%=resourceVersion%>" />

<script type="text/javascript" src="<%=appPath%>/resources/script/jquery-1.8.0.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/activiti/manageActiviti.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
			
<%
	boolean isloggined = (Boolean)request.getAttribute("isloginned");
	
	String[] scopes = StringUtil.replaceNull(request.getParameter("scope")).split(",");
	
	String redirecturl = request.getParameter("redirecturi");
%>

 <style type="text/css">
	.quadBox {
	    position: absolute;
	    left: 50%;
	    top: 50%;
	    margin: -190px 0 0 -190px;
	    width: 380px;
	    height: 370px;
	    background : #063d82;
	    border-radius: 11%;
	    text-align: center;
	    box-shadow: 0px 2px 2px 0px rgb(6, 61, 130), 0px 3px 1px -2px rgb(6, 61, 130), 0px 1px 5px 0px rgb(6, 61, 130);
	}
	.oaRe {
	    font-family: "NanumBarunGothic", "Nanum Gothic", "맑은 고딕", "Malgun Gothic";
   		font-size: 18px;
   	    color: #fff;
   	    letter-spacing: 0;
    }
    .oaRera {
	    list-style: none;
	    color: #fff;
	    font-size: 13px;
	    margin-top: 25px;
	    line-height: 22px;
	}
	
    .oaAc {
   		font-size: 12px;
   		margin: 15px 0 0 0;
   		color: #fff;
	}
	
	.oaAc h2{
   		font-size: 14px;
	    font-weight: 500;
	    line-height: 20px;
	    margin-bottom: 0px;
	}
	.oaPe{
		color: #9e9e9e;
    	line-height: 1.4;
    	margin-top: 4px;
    	margin-bottom: 30px;
	}
	
	.oaRerasa{
		background: url(<%=cssPath%>/covicore/resources/images/theme/icn_png.png) no-repeat -460px -410px;
		padding-left: 24px;
	}

</style> 
<script type="text/javascript" language="javascript">
	function authorize(){
		var currenturl = "${currenturl}";
		currenturl = currenturl.replace(/\&amp;/g,'&');
		
		$("#frm").attr("method","POST")
		$("#frm").attr("action",currenturl);
		$("#frm").submit();		
	}
	
	function nonAuthorize(){
		var currenturl = "${currenturl}";
		currenturl = currenturl.replace(/\&amp;/g,'&');
		
		$("#isallow").val("false");
		$("#frm").attr("method","POST")
		$("#frm").attr("action", currenturl);
		$("#frm").submit();		
	}
</script>

</head>
<body id="loginWrap" class="loginWrap">
<form method="post" id="frm">
	<input type="hidden" id="isallow" name="isallow" value="true" />
	<div class="quadBox">
		 <dl class="loginCont">
			<dt><h1 class="intro_logo"></h1></dt>
			<dd class="oaRe">
				<span>${clientname}</span><spring:message code='Cache.lbl_oauthAccessRange'/>
         	</dd>
         	<dd class="oaRera">
         		<% for (int i=0; i < scopes.length; i++) { %>
					<span class="oaRerasa"><%=OAuth2Scope.getScopeMsg(scopes[i]) %></span>	
				<% } %>
         	</dd>
         	<dd class="oaAc">
         		<h2><spring:message code='Cache.msg_oauthAccess'/></h2>
         	</dd>
         	<dd class="oaPe">
         		<spring:message code='Cache.msg_oauthAccessTerms'/>
         	</dd>
         	<dd>
         	  <input type="button" value="허용" class="btnLogIn" onclick="javascript:authorize();" style="width: 110px;">
          	  <input type="button" value="취소" class="btnLogIn" onclick="javascript:nonAuthorize();" style="margin-left: 10px;width: 110px;">
         	</dd>
		 </dl>
	</div>
</form>
</body>
</html>
