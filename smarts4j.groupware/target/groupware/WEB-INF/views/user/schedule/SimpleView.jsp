<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<aside class="schViewLayerPopup active schLayerPopContent" style="top:0px;left:0px;">
	<div>
		<div class="top">
			<a class="btnType02 btnUrgent" id="ImportanceState" style="cursor: auto;"><spring:message code='Cache.lbl_Important' /></a><h3 id="Subject"></h3><!-- 중요 -->
			<a id="btnAddTemplate" onclick="scheduleUser.addTemplateScheduleData($('#eventID').val(), 'S');" class="btnSchLayerAdd" title="<spring:message code='Cache.lbl_schedule_addFavoriteSch' />"></a><!-- 자주 쓰는 일정 등록 -->
			<a class="btnLayerClose" onclick="btnLayerCloseOnClick(this);"><spring:message code='Cache.lbl_schedule_closeView' /></a><!-- 일정보기 닫기 -->
		</div>
		<div class="middle">
			<p>
				<span class="tit"><spring:message code='Cache.lbl_RepeateDate' /></span><span class="txt" id="StartEndDateTime"></span><!-- 일시 -->
			</p>
			<p>
				<span class="tit"><spring:message code='Cache.lbl_Register' /></span><span class="txt" id="Register"></span><!-- 등록자 -->
			</p>
			<p id="pPlace" style="display: none">
				<span class="tit"><spring:message code='Cache.lbl_Place' /></span><span class="txt" id="Place"></span><!-- 장소 -->
			</p>
		</div>
		<div id="divBtnBottom" class="bottom">
			<a onclick="scheduleUser.goDetailViewPage('S');" class="btnTypeDefault btnBlueBoder"><spring:message code='Cache.lbl_DetailView' /></a><!-- 상세보기 -->
		</div>
	</div>
	<input type="hidden" id="eventID">
	<input type="hidden" id="dateID">
	<input type="hidden" id="repeatID">
	<input type="hidden" id="isRepeat">
	<input type="hidden" id="folderID">
</aside>
