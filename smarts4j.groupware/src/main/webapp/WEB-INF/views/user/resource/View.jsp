<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
.half_book {
	background-image: linear-gradient(45deg, white, white 25%, transparent 25%, transparent 50%, white 50%, white 75%, transparent 75%, transparent) !important;
    background-size: 5px 5px !important;
}

.resBoardListCont .tabMenu > li {
    height: 32px;
    line-height: 32px;
}

.resourceContScrollBottom {
	padding-bottom: 0;
    overflow: hidden;
}
</style>

<div class="cRConTop titType">
    <h2 id="dateTitle" class="title"></h2>
    <div class="pagingType02">
        <a class="pre" onclick="clickTopButton('PREV');"></a><a class="next" onclick="clickTopButton('NEXT');"></a><a onclick="resourceUser.goCurrent();" class="btnTypeDefault"><spring:message code='Cache.lbl_Todays' /></a><!-- 오늘 -->
    </div>
    <div class="searchBox02">
        <span>
            <input type="text" id="simSearchSubject" class="HtmlCheckXSS ScriptCheckXSS" onkeypress="resourceUser.searchSubjectEnter(event);">
            <button type="button" class="btnSearchType01" onclick="resourceUser.searchSubject();"><spring:message code='Cache.btn_search' /></button></span><a class="btnDetails" onclick="btnDetailsOnClick(this);"><spring:message code='Cache.lbl_detail' /></a><!-- 검색 --><!-- 상세 -->
    </div>
</div>
<div class='cRContBottom mScrollVH resourceContanier resourceContainerScroll'>
	<div class="inPerView type03 ">
		<div>
			<div class="inPerTitbox">
				<span><spring:message code='Cache.lbl_Purpose' /></span><!-- 용도 -->
				<input id="searchSubject" type="text" class="HtmlCheckXSS ScriptCheckXSS" onkeypress="resourceUser.DetailSearchSubjectEnter(event);"/>
			</div>
			<div class="inPerTitbox">
				<span><spring:message code='Cache.lbl_Register' /></span><!-- 등록자 -->
				<input id="serachRegister" type="text" class="HtmlCheckXSS ScriptCheckXSS" onkeypress="resourceUser.DetailSearchSubjectEnter(event);"/>
			</div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_State' /></span><!-- 상태 -->
				<select id="searchApprovalState" class="selectType02 size107"></select>																		
			</div>
			<a onclick="resourceUser.getSearchListData();" class="btnTypeDefault btnSearchBlue "><spring:message code='Cache.btn_search' /></a><!-- 검색 -->
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
				<%-- <a class="btnTypeDefault btnExcel" onclick="resourceUser.excelDownload();"><spring:message code='Cache.btn_SaveToExcel' /></a> --%><!-- 엑셀저장 -->
				<ul id="topButton" class="schSelect clearFloat">
					<li id="liDay"><a onclick="clickTopButton('D');"><spring:message code='Cache.lbl_Daily' /></a></li><!-- 일간 -->
					<li id="liWeek"><a onclick="clickTopButton('W');" ><spring:message code='Cache.lbl_Weekly' /></a></li><!-- 주간 -->
					<li id="liMonth" class="selected"><a onclick="clickTopButton('M');" ><spring:message code='Cache.lbl_Monthly' /></a></li><!-- 월간 -->
					<li id="liList"><a onclick="clickTopButton('List');" ><spring:message code='Cache.lbl_List_View' /></a></li><!-- 목록보기 -->
				</ul>
				<div>
					<div class="resCalViewBox">
						<span class="reserComp"><span class="half_book"></span>부분예약</span><!-- 부분예약 -->
						<span class="reserComp"><span></span><spring:message code='Cache.lbl_resource_bookingComlete' /></span><!-- 예약완료 -->
						<span class="myReser"><span></span><spring:message code='Cache.lbl_resource_MyBooking' /></span><!-- 나의예약 -->
						<button onclick="resourceUser.refresh();" class="btnRefresh" type="button"></button>
					</div>
				</div>
			</div>
			<div id="DayCalendar" class="resDayListCont" style="display: none">
				<div class="reserTblContent reserTblTit">
					<div class="chkStyle04">
						<input type="checkbox" id="chkWorkTimeDay" onchange="resourceUser.changeWorkTime(this);"><label for="chkWorkTimeDay"><span></span><spring:message code='Cache.lbl_BusinessTime' /></label><!-- 업무시간 -->
					</div>
					<div class="reserTblView ">
						<table id="headerTimeList" class=" reserTbl"></table>
					</div>
				</div>
				<div id="bodyResourceDay" class="reserTblContent reserTblCont">
				</div>
			</div>
			<div id="WeekCalendar" class="resDayListCont reserTblWeekly" style="display: none">
				<div class="reserTblContent reserTblTit">
					<div class="chkStyle04">
						<span><spring:message code='Cache.lbl_Res_Name' /></span><!-- 자원명 -->
					</div>
					<div class="reserTblView ">
						<table class=" reserTbl">
							<colgroup>
								<col width="16.6%"/>
								<col width="16.6%"/>
								<col width="16.6%"/>
								<col width="16.6%"/>
								<col width="16.6%"/>
								<col width="16.6%"/>
								<col width="16.6%"/>
								<col width="16.6%"/>
								<col width="16.6%"/>
								<col width="16.6%"/>
								<col width="16.6%"/>
								<col width="16.6%"/>
								<col width="16.6%"/>
								<col width="16.6%"/>
							</colgroup>
							<tbody id="headerDayList">
							</tbody>
						</table>
					</div>
				</div>
				<div id="bodyResourceWeek" class="reserTblContent reserTblCont">
				</div>
			</div>
			<div id="MonthCalendar" style="display: none">
			</div>
			<div id="List" class="resBoardListContTop" style="display: none">
				<div class="tblList tblCont shceduleListViewCont">
					<div id="ListGrid" style="height: auto;">
					</div>
					<div class="goPage" style="display: none">
						<input type="text"> <span> / <spring:message code='Cache.lbl_total' /> </span><span>1</span><span><spring:message code='Cache.lbl_page' /></span><a class="btnGo">go</a><!-- 총 ? 페이지 / go -->
					</div>							
				</div>									
			</div>
			<article id="popup" >
    		</article>
		</div>
		<div class="resourceContScrollMiddle">
			<div id="moveBar" class="sizeMoveBar"></div>
		</div>
		<div class="resourceContScrollBottom" >
			<div class="resBoardListCont" style="height:100%">
				<div>
					<ul class="tabMenu clearFloat">
						<li id="myTabLi" onclick="tabMenuOnClick(this);resourceUser.setSearchBtn(this);" value="MY"><a><spring:message code='Cache.lbl_resource_myEvent' /></a></li><!-- 나의 자원예약 -->
						<li onclick="tabMenuOnClick(this);resourceUser.setSearchBtn(this);" value="REQ"><a><spring:message code='Cache.lbl_resource_requestApprovalReturn' /></a></li><!-- 승인/반납 요청 -->
					</ul>
				</div>
				<div class="inPerView type03">
				</div>
				<div style="height:100%">
					<div class="tabContent active" style="height:100%">
						<iframe id="ifmMyBooking" src="" frameborder="0" width="100%" scrolling="no"></iframe>
					</div>
					<div class="tabContent " style="height:100%">
						<iframe id="ifmRequestBooking" src="" frameborder="0" width="100%" scrolling="no"></iframe>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<script>
//# sourceURL=View.jsp
	var eventDataList = {};
	
	initContent();
	
	function initContent(){
		resourceUser.initJS();
		
		resourceUser.fn_resourceView_onload();

		var currentTab = (CFN_GetCookie("Resource_SelectedTab_"+Common.getSession('USERID')) != '') ? CFN_GetCookie("Resource_SelectedTab_"+Common.getSession('USERID')) : 'MY';
		$(".resourceContScrollBottom .tabMenu [value="+currentTab+"]").click();
		
		if(g_viewType == "D"){
			resourceUser.resource_MakeDayCalendar();
		}else if(g_viewType == "W"){
			resourceUser.resource_MakeWeekCalendar();
		}else if(g_viewType == "M"){
			schedule_MakeMonthCalendar();
		}else if(g_viewType == "List"){
			resourceUser.resource_MakeList();
		}
	}
</script>