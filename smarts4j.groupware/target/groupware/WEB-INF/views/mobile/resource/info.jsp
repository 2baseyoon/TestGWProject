<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="resource_info_page">

	<header id="resource_info_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_close"><span><span>닫기</span></span></a>
				<div class="menu_link gnb">
					<a id="resource_info_title" class="pg_tit"><spring:message code='Cache.lbl_resource_Info' /></a> <!-- 자원정보 -->
				</div>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="resource_info_content">
		<div class="resource_info">
			<div class="img_info">
				<span class="thum"><img src="" alt="" id="resource_info_resourceImage"></span>
				<p class="name" id="resource_info_parentFolderName"></p>
			</div>
			<ul class="detail_info" id="resource_info_ulDetail">
				<li id="resource_info_ParentName"><span class="label"><spring:message code='Cache.lbl_ParentName' /></span></li> <!-- 자원분류 -->
				<li id="resource_info_managerList"><span class="label"><spring:message code='Cache.btn_charge' /></span></li> <!-- 담당자 -->
				<li id="resource_info_bookingType"><span class="label"><spring:message code='Cache.lbl_ReservationProc' /></span></li> <!-- 예약절차 -->
				<li id="resource_info_leastRentalTime"><span class="label"><spring:message code='Cache.lbl_resource_rentalTime' /></span></li> <!-- 대여시간 -->
				<li id="resource_info_returnType"><span class="label"><spring:message code='Cache.lbl_ReturnProc' /></span></li> <!-- 반납절차 -->
				<li id="resource_info_equipmentList"><span class="label"><spring:message code='Cache.lbl_Equipment' /></span></li> <!-- 지원장비 -->
				<li id="resource_info_placeOfBusiness"><span class="label"><spring:message code='Cache.lbl_PlaceOfBusiness' /></span></li> <!-- 사업장 -->
				<li id="resource_info_descriptionURL"><span class="label"><spring:message code='Cache.lbl_resource_descriptionURL' /></span></li> <!-- 부가설명 -->
				<li id="resource_info_description"><span class="label"><spring:message code='Cache.lbl_Description' /></span></li> <!-- 설명 -->
				<!-- <li id="resource_info_attrAfter"><span class="label"><spring:message code='Cache.lbl_AddProperty' /></span></li> --> <!-- 추가속성 -->
			</ul>
		</div>
	</div>
	
</div>