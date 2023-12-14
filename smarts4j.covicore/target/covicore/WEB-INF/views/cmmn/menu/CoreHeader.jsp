<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="egovframework.baseframework.util.SessionHelper" %>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<style>
.nav_logo a { background-image: none; color: white; }
.current-top-menu {
	color: #f55702 !important;
	background: #3f465c none !important;
}
.admin-menu-active { font-weight: bold !important; font-size: 14px !important; }
</style>

<script type="text/javascript">
	var headerdata = ${topMenuData};
	
	$(document).ready(function (){
		
		var sessionOutPopupTime = Common.getBaseConfig("sessionExpirationTime");
		var redirectAfterTime = 300; //초
		
		$( document ).on( "idle.idleTimer", function(event, elem, obj){
			 if( $(".layer_dialog[id^=sessionOut]").size() == 0 ){
				 coviCmn.sessionOut( '세션이 만료됩니다. <br />세션 시간 연장을 원하시면 <b>OK</b> 버튼을 선택해주세요.',  redirectAfterTime ,  coviCmn.continuSession , XFN_LogOut );	 
			 }
	    });
		$.idleTimer( (sessionOutPopupTime == undefined?3600:sessionOutPopupTime) * 1000);
		 
    	var coviMenu = new CoviMenu({
   			lang: "ko",
   			isPartial: "true"
    	});
    	
    	coviMenu.render("#topmenu", headerdata, "adminTop");
    	
    	$("#adminLogoHome").attr("href", Common.getGlobalProperties("MainPage.path")).text(Common.getSession("DN_Name"));
    	
    	CoviMenu_SetCurrentTopMenu();
	});
	
</script>

<h1 class="nav_logo" >
	<a id="adminLogoHome"></a>
</h1>
<nav class="gnb">
	<ul id="topmenu"></ul>
</nav>
