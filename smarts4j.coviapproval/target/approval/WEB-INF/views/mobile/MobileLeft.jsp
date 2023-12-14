<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="all_menu nt01">
	<div class="my_info_wrap">
		<div class="top_btn">
			<a href="javascript:mobile_home_setCntInit('ul_leftmenu');" class="topH_reload"><span class="Hicon">새로고침</span></a>
			<!-- 테마 설정 셀렉트박스 (손가락으로 탭하면 레이어 topH_colorS 열림)-->
			<a href="javascript:$('.topH_colorS').toggle();" class="topH_colorSbox" style="display:none;"><span id="user_theme_color" class="color01"></span></a>
			<!-- 테마 설정 레이어 컬러 값 선택 옵션 창 -->
			<ul class="topH_colorS" style="display:none;">
				<li><a href="javascript:mobile_portal_setMyInfo('Theme','blue');"><span id="user_theme_blue" class="color01"></span></a></li>
				<li><a href="javascript:mobile_portal_setMyInfo('Theme','red');"><span id="user_theme_red" class="color02"></span></a></li>
				<li><a href="javascript:mobile_portal_setMyInfo('Theme','green');"><span id="user_theme_green" class="color03"></span></a></li>
				<li><a href="javascript:mobile_portal_setMyInfo('Theme','black');"><span id="user_theme_black" class="color04"></span></a></li>
			</ul>
		</div>
		<div class="my_info">
			<span class="photo" id="user_profile_photo" style="background-position: 50% 0%;"></span>
			<p class="name" id="user_profile_name"></p> <!-- 홍길동 -->
			<p class="info" id="user_profile_dept_position"></p> <!-- <span>디자인팀</span>팀장 -->
		</div>
     	<ul class="my_link">
			<li type="integrated"><a href="javascript: mobile_comm_go('/groupware/mobile/portal/integrated.do','Y');"><i class="ico_my_link01"></i></a></li>
     	</ul>
   </div>
   
   <div class="menu_link_n">
		<ul id="ul_leftmenu"></ul>
	</div>
	<a href="javascript:mobile_comm_closeleftmenu();" class="close"></a>
</div>

<script>

//좌측 메뉴
var menudata = ${MenuData};

$(document).ready(function(){
	//좌측 메뉴 그리기
	$('#ul_leftmenu').html(mobile_comm_menu(menudata));	

	setTimeout("mobile_comm_LeftLoad()", 1000);
});

</script>