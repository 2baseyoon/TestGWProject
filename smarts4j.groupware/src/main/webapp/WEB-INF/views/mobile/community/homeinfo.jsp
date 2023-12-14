<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="community_homeinfo_page">	
	
	<header data-role="header" id="community_homeinfo_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_back"><span>이전페이지로 이동</span></a>
				<div class="menu_link gnb">
					<a id="community_homeinfo_title" href="#" class="pg_tit"><spring:message code='Cache.lbl_DetailInfo' /></a> <!-- 상세정보 -->
				</div>
			</div>
		</div>
	</header>
	
	<div data-role="content" class="cont_wrap" id="community_homeinfo_content">
		<div class="community_view">
			<div class="list_tit">
				<span id="community_homeinfo_img"  class="thum" style="background-image:url(../../resources/images/@ex_list_thum02.jpg)"></span>
				<div class="txt_area">
					<p id="community_homeinfo_name" class="name"><!-- 멘토멘티의 공간 --></p>
					<p id="community_homeinfo_category" class="cate"><!-- 가족모임 <i class="location"></i> 친구 --></p>
					<div class="info">
						<p id="community_homeinfo_createDate" ><span><spring:message code='Cache.lbl_Establishment_Day' />:</span> <!-- 2017.10.10 --> </p> <!-- 개설일 -->
						<p id="community_homeinfo_creator"><span><spring:message code='Cache.lbl_Establishment_Man' />:</span> <!-- 홍길동 과장 --></p> <!-- 개설자 -->
						<p id="community_homeinfo_type"><span><spring:message code='Cache.lbl_type' />:</span>  <!-- 비공개 --></p> <!-- 유형 -->
					</div>
				</div>
			</div>
			<a href="#" onclick="mobile_community_clickAccLink(this);" class="acc_link show"><spring:message code='Cache.lbl_community_status' /></a> <!-- 운영현황 -->
			<div class="input_data acc_cont">
				<dl>
					<dt><spring:message code='Cache.lbl_Operator' /></dt> <!-- 운영자 -->
					<dd id="community_homeinfo_admin"></dd>
				</dl>
				<dl>
					<dt><spring:message code='Cache.lbl_User_Count' /></dt> <!-- 회원수 -->
					<dd id="community_homeinfo_userCnt"><!-- 2 --></dd>
				</dl>
				<dl>
					<dt><spring:message code='Cache.lbl_All_Count' /></dt> <!-- 전체글수 -->
					<dd id="community_homeinfo_msgCnt"><!-- 12 --></dd>
				</dl>
				<dl>
					<dt><spring:message code='Cache.lbl_AllocatedCapacity2' /></dt> <!-- 할당용량 -->
					<dd id="community_homeinfo_memory"><!-- 300MB --></dd>
				</dl>
				<dl>
					<dt><spring:message code='Cache.lbl_UsableVolume' /></dt> <!-- 사용용량 -->
					<dd id="community_homeinfo_memoryUsed"><!-- 200MB --></dd>
				</dl>
			</div>
			<a href="#"  onclick="mobile_community_clickAccLink(this);" class="acc_link show"><spring:message code='Cache.lbl_community_termIntro' /></a> <!-- 소개 및 약관 -->
			<div class="input_data acc_cont">
				<div id="community_homeinfo_oneTitle" class="txt_box">
					<!-- <p>멘토링 제도 운영에 따른 멘토-멘티 커플들의 공간 입니다</p> -->
				</div>
				<div id="community_homeinfo_provision"  class="txt_box terms">
					<!-- <p>약관 내용</p> -->
				</div>
			</div>
		</div>
	</div>
	
	<div class="bg_dim" style="display: none;"></div>
	
</div>