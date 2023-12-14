<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="false"%>
<%@page import="egovframework.coviframework.util.SessionCommonHelper"%>
<%@page import="egovframework.baseframework.util.RedisDataUtil"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<%
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	String projectCode = RedisDataUtil.getBaseConfig("projectCode");
	
	pageContext.setAttribute("themeType", SessionCommonHelper.getSessionMapKey("PortalOption","theme","purple"));
	pageContext.setAttribute("themeCode", SessionCommonHelper.getSession("UR_ThemeCode"));
	pageContext.setAttribute("projectCode", ("".equals(RedisDataUtil.getBaseConfig("projectCode"))) ? SessionCommonHelper.getSession("UR_ThemeCode") : RedisDataUtil.getBaseConfig("projectCode"));
%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="format-detection" content="telephone=no">
	<meta name="viewport" content="width=1280">
	
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/board/resources/css/board.css<%=resourceVersion%>" />	
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/<c:out value="${themeType}"/>.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/<c:out value="${projectCode}"/>/css/project.css<%=resourceVersion%>" />
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/<c:out value="${themeCode}"/>/css/PN_dark.css<%=resourceVersion%>" />
	
	<c:if test="${themeCode != 'default'}">
		<c:choose>
			<c:when test="${themeType == 'blue'}">
				<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/<c:out value="${themeCode}"/>/css/color_01.css<%=resourceVersion%>" />
			</c:when>
			<c:when test="${themeType == 'green'}">
				<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/<c:out value="${themeCode}"/>/css/color_02.css<%=resourceVersion%>" />
			</c:when>
			<c:when test="${themeType == 'red'}">
				<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/<c:out value="${themeCode}"/>/css/color_03.css<%=resourceVersion%>" />
			</c:when>
			<c:when test="${themeType == 'black'}">
				<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/<c:out value="${themeCode}"/>/css/color_04.css<%=resourceVersion%>" />
			</c:when>
		</c:choose>
	</c:if>
	
	<style>
	<%
	if (!SessionCommonHelper.getSession("DomainImagePath").equals("") && SessionCommonHelper.getSession("DomainImagePath").indexOf(";") > 0 && !SessionCommonHelper.getSession("DomainImagePath").split(";")[0].equals("")){
		out.println("#header > h1 a { background: url('/covicore/common/logo/PC_Logo.png.do') no-repeat left center}");
	}	
	
	if (PropertiesUtil.getGlobalProperties().getProperty("isSaaS").equalsIgnoreCase("Y") && !SessionCommonHelper.getSession("DN_ID").equalsIgnoreCase("0")){
		out.print(".domain {display:none}");
	}
	%>
	</style>
	
	<title>Smart²</title>
</head>
<body>	
	<div>
	<section class="errorContainer">
			<div class="errorCont serviceError">
				<c:choose>
					<c:when test="${exceptionType eq 'NoAuth'}">
						<h1>(No permission) 요청한 작업에 대한 권한이 없습니다.</h1>
						<div class="bottomCont">
							<p class="txt">
								<span class="col_red"> 
								요청한 작업에 대해 권한을 부여받지 못했습니다.
								<br /> 
								권한 필요 시 운영자(또는 관리자)에게 권한을 요청하십시요.
							</p>	
							<p class="txt02 mt20">
								Authorization was not granted for the requested operation.
								<br />
								If permission is required, ask the operator (or manager) for permission.
							</p>
							<p class="errorBtnBox mt15">
								<a class="btnTypeDefault btnTypeBg" onclick="javascript:goHome();">홈으로 이동</a>
								<a class="btnTypeDefault " onclick="javascript:history.go(-1);">이전페이지</a>
							</p>				
						</div>
					</c:when>
					<c:when test="${exceptionType eq 'NotFound'}">
						<h1>(Message not found) 해당 게시물을 찾을 수 없습니다.</h1>
						<div class="bottomCont">
							<p class="txt">
								<span class="col_red"> 
								게시글의 삭제, 이동, 만료, 잠금 등의 사유로 조회할 수 없는 상태가 발생할 수도 있습니다.
								<br /> 
								필요 시 작성자 또는 운영자에게 문의하십시요.
							</p>	
							<p class="txt02 mt20">
								Messages may be unretrieved due to reasons such as deletion, movement, expiration, or locking.
								<br />
								If necessary, contact the author or operator.
							</p>
							<p class="errorBtnBox mt15">
								<a class="btnTypeDefault btnTypeBg" onclick="javascript:goHome();">홈으로 이동</a>
								<a class="btnTypeDefault " onclick="javascript:history.go(-2);">이전페이지</a>
							</p>				
						</div>
					</c:when>
					<c:otherwise>
						<h1>(Authentication access error) 인증 접속 오류</h1>
						<div class="bottomCont">
							<p class="txt">
								<span class="col_red">부여받지 않은 시스템 접속</span>입니다.
								<br />
								관리자에게 문의 바랍니다.
							</p>
							<br />	
							<p class="txt">
								(Unauthorized system access. Please contact the administrator)
							</p>
							<p class="txt02 mt20">
								페이지에 요구되는 권한 재인증 바랍니다.
								<br />
								동일한 문제가 지속적으로 발생하실 경우에 관리자에게 문의 부탁드립니다.
							</p>
							<p class="errorBtnBox mt15">
								<a class="btnTypeDefault btnTypeBg" onclick="javascript:goHome();">홈으로 이동</a>
								<a class="btnTypeDefault " onclick="javascript:history.go(-1);">이전페이지</a>
							</p>				
						</div>
					</c:otherwise>
				</c:choose>	
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