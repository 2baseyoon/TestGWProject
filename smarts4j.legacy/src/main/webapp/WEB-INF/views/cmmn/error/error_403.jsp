<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
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
	
	<title>Smart²</title>
</head>


<body>	
	<div id='wrap' >
		<section class="errorContainer">
			<div class="errorCont serviceError">
				<h1><span class="pointTitle">인증이 유효하지 않습니다</span></h1>
				<div class="bottomCont">
					<p class="txt">
						접속하려는 페이지에 필요한
						<br />
						<span class="col_red">인증이 만료되었거나 유효하지 않거나 없습니다.<span class="col_red">
					</p>	
					<p class="txt02 mt20">
						페이지에 요구되는 권한 확인 바랍니다
						<br />
						동일한 문제가 지속적으로 발생하실 경우에 관리자에게 문의 부탁드립니다.
					</p>
					<p class="errorBtnBox mt15">
						<a class="btnTypeDefault btnTypeBg" onclick="javascript:history.go(-1);">이전페이지</a>
					</p>
					<p class="copyRight mt30">Copyright 2017. Covision Corp. All Rights Reserved.</p>
				</div>
			</div>
		</section>					
	</div>
</body>

</html>

<script type="text/javascript">
	function goHome(){
		document.location.href = '/groupware/portal/home.do?CLSYS=portal&CLMD=user&CLBIZ=Portal';
	}
</script>