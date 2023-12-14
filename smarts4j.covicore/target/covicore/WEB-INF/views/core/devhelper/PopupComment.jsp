<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop ui-draggable boradPopLayer" id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent commentLayerPop">
			<div class="">	
				<div id="sampleCoviCommentLoad" class="top">
				</div>			
			</div>
		</div>
	</div>	
</div>
<input type="hidden" id="chkPop" value="Y"/>

<script>
	init();
	
	function init(){
		//coviComment.load 바인딩
		
		/*	댓글 통합알림 옵셥
			모듈별로 알맞게 지정
			예제에서는 알림을 보낼 수 없으므로 생략
		var messageSetting = {
		    SenderCode : g_userCode,				// 보내는 사람
		    RegistererCode : g_userCode,			// 등록자
		    ReceiversCode : pConfig.CreatorCode,	// 받는 사람
		    MessagingSubject : pConfig.Subject,		// 현재 메세지 제목
		    ReceiverText : pConfig.Subject, 		// 요약된 내용
		    ServiceType : pBizSection, 				// serviceType (Board, Schedule, Survey 등)
		    GotoURL: goToUrl,						// URL
		    PopupURL: goToUrl,						// URL
		    MobileURL: mobileUrl,					// MobileURL
		    MsgType : "Comment"						// 메세지 타입 (기초코드 TodoMsgType에 등록된 값)
		};
		*/
		
		//coviComment.load('divComment', "Devhelper", "0" , messageSetting);
		coviComment.load('sampleCoviCommentLoad', "Devhelper", "0");
	}
	

</script>
