<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
.current-top-menu {
	color: #f55702 !important;
	background: #3f465c none !important;
}

.admin-menu-active { font-weight: bold !important; font-size: 14px !important; }
</style>

<script type="text/javascript">
	var headerdata = ${topMenuData};
	
	$(document).ready(function (){
		var sessionOutPopupTime =  Common.getBaseConfig("sessionExpirationTime");
		var redirectAfterTime = 300; //초

		var ls_USERID = Common.getSession("USERID");
		$( document ).on( "idle.idleTimer", function(event, elem, obj){
			var sessionLastActiveTime = localStorage.getItem(ls_USERID + "_sessionLastActiveTime");
			var idleTimerLastActiveTime = $.idleTimer("getLastActiveTime");
			
			if(sessionLastActiveTime == idleTimerLastActiveTime) {
				// 현재 브라우저의 LastActive 값이 SessionStorage의 LastActive 값과 일치하면 마지막 Active 브라우저라고 판단하여 세션종료 팝업 호출 그 외일 경우  
				if( $(".layer_dialog[id^=sessionOut]").size() == 0 ){
					coviCmn.sessionOut( '세션이 만료됩니다. <br />세션 시간 연장을 원하시면 <b>OK</b> 버튼을 선택해주세요.',  redirectAfterTime ,  coviCmn.continuSession , XFN_LogOut );	 
				}
			} else {
				$.idleTimer("reset");
			}

	    });

		// timer 설정 전 기존 localstorage에 모든 _sessionLastActiveTime 제거
		$.idleTimer( {timeout : ((sessionOutPopupTime == undefined?3600:sessionOutPopupTime) - redirectAfterTime) * 1000, sessionId : ls_USERID});
		 
		var opt = {
    			lang : "ko",
    			isPartial : "true"
    	};
    	var coviMenu = new CoviMenu(opt);
    	
    	coviMenu.render("#topmenu", headerdata, "adminTop");
    	
    	$("#adminLogoHome").attr("href", Common.getGlobalProperties("MainPage.path"));
    	
    	CoviMenu_SetCurrentTopMenu();
	});
	
</script>

<h1 class="nav_logo"><a id="adminLogoHome"></a></h1>
<nav class="gnb">
	<ul id="topmenu"></ul>
</nav>
