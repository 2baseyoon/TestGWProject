<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="community_apply_page">	
	
	<header data-role="header" id="community_apply_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_back"><span class="Hicon">이전페이지</span></a>
				<div class="menu_link gnb">
					<a href="#" class="pg_tit"><spring:message code='Cache.BizSection_Community' /> <spring:message code='Cache.CuMemberDetailStatus_RA' /></a> <!-- 커뮤니티 가입신청 -->
				</div>
			</div>
			<div class="utill">
				<a id="community_apply_btnAdd" href="javascript: mobile_community_joinCommunity();" class="topH_save"><span class="Hicon">등록</span></a>
			</div>
		</div>
	</header>
	<div data-role="content" class="cont_wrap" id="community_apply_content">
		<p id="community_apply_cuName" class="list_tit"></p>
		<div class="input_data">
        	<dl>
				<dt><spring:message code='Cache.lbl_FirstName' /></dt> <!-- 이름 -->
				<dd id="community_apply_userName"></dd>
			</dl>
        	<dl>
				<dt><spring:message code='Cache.btn_Mail' /></dt> <!-- 메일 -->
				<dd id="community_apply_userMail"></dd>
        	</dl>
        	<!-- <dl class="nickname">
				<dt>별명</dt>
				<dd><input type="text" name="" value=""><a href="#" class="g_btn05">중복체크</a></dd>
			</dl> -->
			<dl>
				<dt><spring:message code='Cache.lbl_Self_Intro' /></dt> <!-- 자기소개 -->
				<dd><input id="community_apply_userRegMsg" type="text" name="" value="" class="full"></dd>
			</dl>
		</div>
		<div class="agree_wrap" id="div_community_terms" style="display:none;">
			<p class="tit"><spring:message code='Cache.lbl_community_SubsTerm' /></p> <!-- 가입약관 -->
			<div id="community_apply_provision" class="terms" style="height: auto;"></div>
			<input type="checkbox" id="community_apply_userAgree">
			<label for="community_apply_userAgree"><spring:message code='Cache.lbl_CommunityAgreementJoinCheck' /></label> <!-- 위 약관에 동의하며 회원가입을 신청합니다. -->
		</div>
	</div>
	
	<div class="bg_dim" style="display: none;"></div>
	
</div>