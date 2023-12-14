<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType">
    <h2 id="dateTitle" class="title"></h2>
    <div class="pagingType02">
    	<a onclick="resourceUser.goCurrent();" class="btnTypeDefault">자원예약현황 보기</a>
    </div>
    <div class="searchBox02">
        <span>
            <input type="text" id="simSearchSubject" class="HtmlCheckXSS ScriptCheckXSS" onkeypress="resourceUser.searchSubjectEnter(event);">
            <button type="button" class="btnSearchType01" onclick="resourceUser.searchSubject();"><spring:message code='Cache.btn_search' /></button>
		</span>
		<a class="btnDetails" onclick="btnDetailsOnClick(this);"><spring:message code='Cache.lbl_detail' /></a><!-- 검색 --><!-- 상세 -->
    </div>
</div>
<div class='cRContBottom mScrollVH resourceContanier resourceContainerScroll'>
	<div class="inPerView type03 ">
		<div>
			<div class="inPerTitbox">
				<span><spring:message code='Cache.lbl_Purpose' /></span><!-- 용도 -->
				<input id="searchSubject" type="text" class="HtmlCheckXSS ScriptCheckXSS"/>
			</div>
			<div class="inPerTitbox">
				<span><spring:message code='Cache.lbl_Register' /></span><!-- 등록자 -->
				<input id="serachRegister" type="text" class="HtmlCheckXSS ScriptCheckXSS"/>
			</div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_State' /></span><!-- 상태 -->
				<select id="searchApprovalState" class="selectType02 size107">
					<option value=""><spring:message code='Cache.lbl_Whole' /></option><!-- 전체 -->
				</select>																		
			</div>
			<a id="searchDetailBtn" onclick="javascript: resourceUser.resource_MakeMyList({ page: 'Y', header: 'Y', search: 'Y', mode: 'listOnly' });" class="btnTypeDefault btnSearchBlue "><spring:message code='Cache.btn_search' /></a><!-- 검색 -->
		</div>
		<div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_Period' /></span><!-- 기간 -->
				<select id="searchDateType" class="selectType02">
					<option value="BookingDate"><spring:message code='Cache.lbl_bookingDate' /></option><!-- 예약일 -->
					<option value="RegistDate"><spring:message code='Cache.lbl_RegistDate' /></option><!-- 등록일 -->
				</select>
				<div id="searchDateCon" class="dateSel type02">
				</div>											
			</div>
		</div>									
	</div>
	
	<div class="resourceContent">
		<div class="resourceContScrollTop">
			<div class="resTopCont scheduleTop checkType">
				<div>
					<div class="resCalViewBox">
<!-- 						<button onclick="resourceUser.refresh();" class="btnRefresh" type="button"></button> -->
					</div>
				</div>
			</div>
			<div class="tblList tblCont">
				<div id="MyListGrid" style="overflow-x: hidden; overflow-y: auto; height: auto;"></div>
			</div>
			<article id="popup"></article>
		</div>
	</div>
</div>

<script>
	var eventDataList = {};
	
	initContent();
	
	function initContent(){
		if (!resourceUser.initialized) {
			resourceUser.initJS();
		}
		
		resourceUser.setSearchControl();
		
		resourceUser.resource_MakeMyList({ page: 'Y', header: 'Y', mode: 'listOnly' });
	}
</script>