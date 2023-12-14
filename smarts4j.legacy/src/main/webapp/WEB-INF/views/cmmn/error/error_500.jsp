<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = PropertiesUtil.getGlobalProperties().getProperty("resource.version", ""); 
	resourceVersion = resourceVersion.equals("") ? "" : ("?ver=" + resourceVersion);
%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="format-detection" content="telephone=no">
	<meta name="viewport" content="width=1280">
	
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.control.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery.mCustomScrollbar.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/Controls.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/blue.css<%=resourceVersion%>" />
</head>


<body>	
	<div id='wrap' >
		<section class="errorContainer">
			<div class="errorCont">
				<h1>로그인 접속 오류</h1>
				<div class="bottomCont">
					<p class="txt">
						<span class="col_red">시스템 접속</span>에 실패하였습니다.
						<br />
						관리자에게 문의 바랍니다.
					</p>					
					<p class="tel mt15"><strong>TEL : </strong>02-1254-1245</p>
					<p class="copyRight mt30">Copyright 2017. Covision Corp. All Rights Reserved.</p>
				</div>
			</div>
		</section>					
	</div>
</body>
</html>