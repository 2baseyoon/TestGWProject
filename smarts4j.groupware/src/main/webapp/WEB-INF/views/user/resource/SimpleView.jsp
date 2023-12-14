<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<aside id="simpleViewPop" class="schViewLayerPopup active schLayerPopContent resLayerPop" style="top:0px;left:0px;">
	<div>
		<div class="top">
			<h3 id="Subject"></h3>												
			<a onclick="btnLayerCloseOnClick(this);" class="btnLayerClose"><spring:message code='Cache.lbl_schedule_closeView' /></a><!-- 일정보기 닫기 -->
		</div>
		<div class="middle">
			<p>
				<span class="tit"><spring:message code='Cache.lbl_RepeateDate' /></span><span class="txt" id="StartEndDateTime"></span><!-- 일시 -->
			</p>
			<p>
				<span class="tit"><spring:message code='Cache.lbl_Register' /></span><span class="txt" id="Register"></span><!-- 등록자 -->
			</p>
			<p>
				<span class="tit"><spring:message code='Cache.lbl_Place' /></span><span class="txt" id="ResourceName"></span><!-- 장소 -->
			</p>
		</div>
		<div id="divBtnBottom" class="bottom">
			<a onclick="resourceUser.goDetailViewPage();" class="btnTypeDefault btnBlueBoder"><spring:message code='Cache.lbl_DetailView' /></a><!-- 상세보기 -->
		</div>
	</div>
	<input type="hidden" id="eventID">
	<input type="hidden" id="dateID">
	<input type="hidden" id="repeatID">
	<input type="hidden" id="isRepeat">
	<input type="hidden" id="resourceID">
</aside>