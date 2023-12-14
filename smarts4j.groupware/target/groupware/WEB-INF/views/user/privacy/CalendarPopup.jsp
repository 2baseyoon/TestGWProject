<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div id="calendarDiv">
	<aside class="simpleMakeLayerPopUp active" id="calendarPopup" style="position:static;margin:0 0 0 0;height:300px;">
	</aside>
</div>

<script>
	initContent();
	
	// 승인 및 검토 요청 팝업
	function initContent() {
		$('#calendarPopup').load('/groupware/privacy/goSimpleMake.do', function() {
			$('.topHead').css("display", "none");
			$('#scheduleDetailBtn').css("display", "none");
			$('#mailSimpleMake').removeClass('active');
			$('#scheduleSimpleMake').addClass('active');
			$('#Subject').val(Base64.b64_to_utf8(CFN_GetQueryString("subject")));
			$('#calendarDiv').find('.middleCont').css('border-width','0px 0px 0px');
			$('#scheduleRegistBtn').attr("onclick", "scheduleUser.setOne('SAC');");
			scheduleUser.setFolderType('SAC');
		});
	}
	
</script>