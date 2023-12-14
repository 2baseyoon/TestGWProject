<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%
	pageContext.setAttribute("communityID", (request.getParameter("communityId") == null) ? "" : request.getParameter("communityId"));
%>

<div class="cRConTop titType">
    <h2 id="dateTitle" class="title"></h2>
    <div class="pagingType02">
        <a class="pre" onclick="clickTopButton('PREV');"></a><a class="next" onclick="clickTopButton('NEXT');"></a><a onclick="scheduleUser.goCurrent();" class="btnTypeDefault"><spring:message code='Cache.lbl_Todays' /></a><!-- 오늘 -->
    </div>
    <div class="searchBox02">
        <span>
            <input type="text" id="simSearchSubject" onkeypress="scheduleUser.searchSubjectEnter(event);">
            <button type="button" class="btnSearchType01" onclick="scheduleUser.searchSubject();"><spring:message code='Cache.btn_search' /></button></span><a class="btnDetails" onclick="btnDetailsOnClick(this);"><spring:message code='Cache.lbl_detail' /></a><!-- 검색 --><!-- 상세 -->
    </div>
</div>
<div class='cRContBottom mScrollVH'>
    <div class="inPerView type03 ">
        <div>
            <div class="inPerTitbox">
                <span><spring:message code='Cache.lbl_Title' /></span><!-- 제목 -->
                <input type="text" id="searchSubject" onkeypress="scheduleUser.DetailSearchSubjectEnter(event);"/>
            </div>
            <div class="inPerTitbox">
                <span><spring:message code='Cache.lbl_Register' /></span><!-- 등록자 -->
                <input type="text" id="serachRegister" onkeypress="scheduleUser.DetailSearchSubjectEnter(event);"/>
            </div>
            <a onclick="scheduleUser.getSearchListData();" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a><!-- 검색 -->
        </div>
        <div>
            <div class="inPerTitbox">
                <span><spring:message code='Cache.lbl_Place' /></span><!-- 장소 -->
                <input type="text" id="searchPlace" onkeypress="scheduleUser.DetailSearchSubjectEnter(event);"/>
            </div>
            <div class="selectCalView">
                <span><spring:message code='Cache.lbl_Period' /></span><!-- 기간 -->
               	<div id="searchDateCon" class="dateSel type02">
				</div>
            </div>
        </div>
    </div>
    <div class="scheduleContent">
        <div class="calTopCont scheduleTop">
        	<button type="button" id="btPrint"  style="display:none;"  class="btnIcoComm btnPrint"  onclick="scheduleUser.openPrintView(); return false;"></button><!-- 프린트하기  -->
            <%-- <a class="btnTypeDefault btnExcel" onclick="scheduleUser.excelDownload();"><spring:message code='Cache.btn_SaveToExcel' /></a> --%><!-- 엑셀저장 -->
            <div class="subscriptionBtnBox">
				<a onclick="btnTopOptionMenuOnClick(this);" class="btnSubscription type02 btnTopOptionMenu"><spring:message code='Cache.btn_Subscription' /></a><!-- 구독 -->
				<ul class="topOptionListCont  subscriptionPopList">
					<li id="subscClose"><a onclick="btnTopOptionContCloseOnClick();" class="btnXClose btnShareListBoxClose btnTopOptionContClose"></a></li>
					<li><a onclick="coviCtrl.addSubscription();" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_Confirm' /></a></li><!-- 확인 -->
				</ul>
			</div>
			<c:if test="${communityID eq ''}">
			<a href="#" class="btnTypeDefault" onclick="javascript:showAttendRequest(this);"><spring:message code='Cache.lbl_schedule_attendRequest' /></a>
			</c:if>
            <ul id="topButton" class="schSelect clearFloat">
                <li id="liDay"><a onclick="clickTopButton('D');"><spring:message code='Cache.lbl_Daily' /></a></li><!-- 일간 -->
                <li id="liWeek"><a onclick="clickTopButton('W');" ><spring:message code='Cache.lbl_Weekly' /></a></li><!-- 주간 -->
                <li id="liMonth" class="selected"><a onclick="clickTopButton('M');" ><spring:message code='Cache.lbl_Monthly' /></a></li><!-- 월간 -->
                <li id="liList"><a onclick="clickTopButton('List');" ><spring:message code='Cache.lbl_List_View' /></a></li><!-- 목록보기 -->
            </ul>
            <div>
                <a id="btnOften" class="btnTypeDefault btnBlueArrow nonHover bntOften" onclick="bntOftenOnClick(this);"><spring:message code='Cache.lbl_schedule_favoriteSch' /></a>
                <button class="btnRefresh" type="button" onclick="scheduleUser.refresh();"></button>
            </div>
        </div>
        <div class="oftenSchCont">
            <div>
                <a onclick="scheduleUser.clickTemplateSchedule();" class="btnOftSchAdd"><spring:message code='Cache.lbl_schedule_favoriteSch' /></a><!-- 자주 쓰는 일정 -->
            </div>
            <div class="oftScroll">
                <div id="templateList" style="" class="clearFloat oftCont"></div>
            </div>
        </div>
        <div id="DayCalendar" style="display: none">
            <!-- 일간보기-->
			<div>
				<div class="weeklyCalendarContainer ">
					<div class="weeklyTitle">
						<div class="chkStyle04">
							<input type="checkbox" id="chkWorkTimeDay" onchange="scheduleUser.changeWorkTime(this);"><label for="chkWorkTimeDay"><span></span><spring:message code='Cache.lbl_BusinessTime' /></label><!-- 업무시간 -->
						</div>
						<div class="weeklyHeaderBody">
							<table id="weekHeaderDay" class="weeklyHeader day">
								<tbody>
									<tr>														
										<th id="headerTodayDate"></th>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div class="specialSchedule">
						<div class="specialScheduleTitle">
							<p><spring:message code='Cache.lbl_AllDay' /></p><!-- 종일 -->
						</div>
						<div id="allDayDataBgDiv" class="specialScheduleBody">
							<!-- 종일 데이터 -->
						</div>																
					</div>
					<div class="weeklyListCont">
						<div id="dayDataBgDiv" class="weeklyListTitle">
						</div>
						<div id="dayDataDiv" class="weeklyListBody ">
						</div>
					</div>
				</div>
			</div>
        </div>
        <div id="WeekCalendar" style="display: none">
            <div>
				<div class="weeklyCalendarContainer ">
					<div class="weeklyTitle">
						<div class="chkStyle04">
							<input type="checkbox" id="chkWorkTimeWeek" onchange="scheduleUser.changeWorkTime(this);"><label for="chkWorkTimeWeek"><span></span><spring:message code='Cache.lbl_BusinessTime' /></label><!-- 업무시간 -->
						</div>
						<div class="weeklyHeaderBody">
							<table id="weekHeader" class="weeklyHeader">
								<tbody>
									<tr>
									</tr>
								</tbody>
							</table>
						</div>
					</div>										
					<div class="specialSchedule">
						<div class="specialScheduleTitle">
							<p><spring:message code='Cache.lbl_AllDay' /></p><!-- 종일 -->
						</div>
						<div id="allDayWeekDataBgDiv" class="specialScheduleBody">
							<!-- 종일 데이터 -->
						</div>																
					</div>
					<div class="weeklyListCont">
						<div id="weekDataBgDiv" class="weeklyListTitle">
						</div>
						<div id="weekDataDiv" class="weeklyListBody ">
						</div>
					</div>
				</div>
			</div>
        </div>
        <div id="MonthCalendar"style="display: none"> 
        </div>
        <div id="List"style="display: none">
        	<div id="DefaultList" class="tblList tblCont shceduleListViewCont">
        	</div>
        	<h3 id="googleScheduleTxt" class="cycleTitle" style="display:none;"><spring:message code="Cache.lbl_schedule_googleSchedule"/></h3> <!-- 구글일정  -->
        	<div id="GoogleList" class="tblList tblCont shceduleListViewCont">
        	</div>
        </div>
        <input type="hidden" id="hidIsAllDay"  value="N"/> <!-- 주간, 월간 보기일 경우 종ㅇ  -->
        <input type="hidden" id="hidShowInfo" />
        <input type="hidden" id="hidShowInfoGoogle" />
    </div>
    <article id="popup" style="position: absolute;top: 0px;left:0px">
    </article>
</div>

<script>
//# sourceURL=View.jsp
	var eventDataList = {};
	var type = CFN_GetQueryString("type");				// all : 전체, import : 중요일정
	
	initContent();
	
	function initContent(){
		
		scheduleUser.initJS();
		
		$("#popup").on('click',function(){ event.stopPropagation(); });
		
		// 오늘의 날짜 초기값
		scheduleUser.fn_scheduleView_onload();
		
		// 구독 버튼 그리기
		scheduleUser.setSubscriptionButton();
		
		if(g_viewType == "M"){
			$("#btPrint").show();
			schedule_MakeMonthCalendar();			
		}else if(g_viewType == "D"){
			scheduleUser.schedule_MakeDayCalendar();
		}else if(g_viewType == "W"){
			scheduleUser.schedule_MakeWeekCalendar();
		}else if(g_viewType == "List"){
			scheduleUser.schedule_MakeList();
		}
	}

	function showAttendRequest(target){
		var openURL = "/groupware/schedule/goAttendRequestPopup.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&isPopupView=Y";
		Common.open("","attendRequest_pop", Common.getDic('lbl_attend_request_list'), openURL,"800px","500px","iframe",true,null,null,true);
	}
</script>