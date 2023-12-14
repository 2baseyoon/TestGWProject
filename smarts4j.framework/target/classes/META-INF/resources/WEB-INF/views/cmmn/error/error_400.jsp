<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
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
			<div class="errorCont serviceError">
				<h1><span class="pointTitle">서비스 이용에 불편을 드려 죄송합니다</span></h1>
				<div class="bottomCont">
					<p class="txt">
						찾으시려는 웹페이지의 <span class="col_red">이름이 바뀌었거나<span class="col_red">
						<br />
						<span class="col_red">현재 사용할 수 없거나 삭제되었습니다.<span class="col_red">
					</p>	
					<p class="txt02 mt20">
						입력하신 페이지 주소가 정확한지 다시 한번 확인해보시기 바랍니다.
						<br />
						동일한 문제가 지속적으로 발생하실 경우에 서비스 이용 문의 부탁드립니다.
					</p>
					<p class="errorBtnBox mt15">
						<a class="btnTypeDefault btnTypeBg" onclick="javascript:goHome();">홈으로 이동</a>
						<a class="btnTypeDefault " onclick="javascript:history.go(-1);">이전페이지</a>
						<a class="btnTypeDefault" onclick="javascript:self.close()">닫기</a>
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