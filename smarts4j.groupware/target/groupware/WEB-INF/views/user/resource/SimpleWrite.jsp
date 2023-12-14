<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<aside id="simpleWritePop" class="schViewLayerPopup active schLayerPopContent addResSchPop" style="top:100px;left:0px;">
	<div>
		<div class="top">
			<h3><spring:message code='Cache.lbl_resource_booking' /></h3><!-- 예약하기 -->		
			<a onclick="btnLayerCloseOnClick(this);" class="btnLayerClose"><spring:message code='Cache.lbl_schedule_closeView' /></a><!-- 일정보기 닫기 -->
		</div>
		<div class="middle">
			<div id="divFolderID" class="inputDateView02 ">
			</div>
			<input type="hidden" id="ResourceID" value="">
			<div class="inpBox">
				<input type="text" id="Subject" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.msg_ReservationWrite_01' />"><!-- 용도를 입력세요. -->
			</div>
			<div class="dateBox">
				<div id="simpleResDateCon" class="dateSel type02">
				</div>
			</div>
			<p><a id="IsSchedule" onclick="scheduleOnOffBtnOnClick(this);" class="btnResSchAdd"><spring:message code='Cache.lbl_schedule_addEvent' /></a></p><!-- 일정등록 -->
		</div>
		<div class="bottom">
			<a onclick="resourceUser.goDetailWritePage();" class="btnTypeDefault btnBlueBoder"><spring:message code='Cache.btn_WriteDetail' /></a><a id="resourceRegistBtn" onclick="resourceUser.setOne('S');" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_register' /></a><!-- 상세등록 --><!-- 등록 -->
		</div>
	</div>
</aside>