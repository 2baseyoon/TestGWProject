<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
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
			
 <style type="text/css">
	.quadBox {
	    position: absolute;
	    left: 50%;
	    top: 50%;
	    margin: -190px 0 0 -190px;
	    width: 380px;
	    height: 300px;
	    background : #063d82;
	    border-radius: 11%;
	    text-align: center;
	    box-shadow: 0px 2px 2px 0px rgb(6, 61, 130), 0px 3px 1px -2px rgb(6, 61, 130), 0px 1px 5px 0px rgb(6, 61, 130);
	}
    .oaAc {
   		font-size: 12px;
   		margin: 0 0 0 0;
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
    	margin-top: 10px;
    	margin-bottom: 30px;
	}
	
</style> 
<script type="text/javascript" language="javascript">
	function main(){
		location.href='/covicore/login.do';	
	}
</script>
</head>
<body id="loginWrap" class="loginWrap">
<form method="post" id="frm">
	<input type="hidden" id="isallow" name="isallow" value="true" />
	<div class="quadBox">
		 <dl class="loginCont">
			<dt><h1 class="intro_logo"></h1></dt>
         	<dd class="oaAc">
         		<h2><spring:message code="Cache.msg_oauthDenyTitle"/></h2>
         	</dd>
         	<dd class="oaPe">
				<spring:message code="Cache.msg_oauthDenyContent"/>
         	</dd>
         	<dd>
         	  <input type="button" value="<spring:message code="Cache.btn_oauthGoHome"/>" class="btnLogIn" onclick="javascript:main();" style="width: 130px;">
         	</dd>
		 </dl>
	</div>
</form>
</body>
</html>
