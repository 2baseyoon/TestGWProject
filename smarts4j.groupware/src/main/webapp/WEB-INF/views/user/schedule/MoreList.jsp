<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<aside id="moreListPop" class="shcDayTextLayerPopup active schLayerPopContent">
	<div class="top">
		<span id="moreDate"></span> <span id="moreWeekOfDay"></span>
		<a class="btnLayerClose" onclick="btnLayerCloseOnClick(this);"><spring:message code='Cache.lbl_schedule_closeView' /></a><!-- 일정보기 닫기 -->
	</div>
	<div id="moreListDiv" class="middle"></div>
</aside>