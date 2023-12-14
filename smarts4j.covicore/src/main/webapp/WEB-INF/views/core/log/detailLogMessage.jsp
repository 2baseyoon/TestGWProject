<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
	<style>
		.divpop_body {
			padding: 20px !important;
		}
		
		th, td{
			font-size: 13px;
		}
		
	</style>
</head>

<form id="form1">
	<div style="width:100%;">
		<div>
			<span id="error_msg">${message}</span>
		</div>
		<div style="width: 100%; text-align: center;">
			<input type="button" id="btnClose" value="<spring:message code='Cache.btn_Close' />" onclick="closePopup();" class="AXButton" > <!-- 닫기 -->
		</div>
	</div>
</form>
<script type="text/javascript">

	function closePopup() {
		Common.Close();
	}
	
</script>
