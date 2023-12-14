<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/PopupInclude.jsp"></jsp:include>
<html>
<head>
<meta charset="UTF-8">
</head>
<body>
	<div style="padding-top:20px;">
		<div id="popup_message" style="text-align:center;">
			<div class="join_inform"></div>
			<p style="width:60%;margin:10px auto;"><spring:message code='Cache.msg_doNotReadSystemNotice'/></p> <!-- 읽지 않은 시스템 공지가 있습니다. 확인하시겠습니까? -->
		</div>
	</div>
	<div class="popBtnWrap">
		<a href="#" id="moveSystemNoticePopup" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_ok'/></a>   <!-- 확인 -->
		<a href="#" id="closeSystemNoticePopup" class="btnTypeDefault"><spring:message code='Cache.btn_Close'/></a>   <!-- 닫기 -->
	</div>
</body>
</html>
<script type="text/javascript">
$(function() {
	$("#moveSystemNoticePopup").on("click", function() {
		window.open("/groupware/layout/board_OrgNoticeManage.do?CLSYS=conf&CLMD=manage&CLBIZ=Conf");
		Common.Close();
	});
	
	$("#closeSystemNoticePopup").on("click", function() {
		Common.Close();
	});
});
</script>