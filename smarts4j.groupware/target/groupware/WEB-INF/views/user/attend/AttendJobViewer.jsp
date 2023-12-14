<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<style>
     @media print {
         body * {
		    visibility: hidden;
		  }
		  .section-to-print, .section-to-print * {
		    visibility: visible;
		  }
		  .section-to-print {
		    position: absolute;
		    left: 0px !important;
		    top: 0px !important;
		  }
     }
.ATMMgtMonthWrap .calMonWeekRow .calGrid.ThirdLine td .WorkBook {margin:05px 5px 5px 105px;position:relative;z-Index:100;color:skyblue}

.mCSB_inside > .mCSB_container {margin:0;text-overflow:clip;overflow:visible;}
.mCSB_scrollTools .mCSB_dragger .mCSB_dragger_bar {margin:2px auto;width:5px;background-color:rgba(255,255,255,0.1);}
.mCSB_scrollTools .mCSB_draggerRail {display:none;}
.scrollBarType02 .mCSB_scrollTools .mCSB_dragger .mCSB_dragger_bar {background-color:rgba(0,0,0,0.1);}
.mCSB_scrollTools a + .mCSB_draggerContainer {margin:5px 0;}
.mCSB_scrollTools {z-index:2;}
.scrollVType01 .mCSB_scrollTools .mCSB_dragger .mCSB_dragger_bar {background-color:rgba(0,0,0,0.1);}
<%=(RedisDataUtil.getBaseConfig("SchConfmYn").equals("Y")?"":".divConfm {display:none !important}")%>
	 #WeekCalendar .ATMTable td:nth-child(3){
		 background: #ffffff !important;
	 }
	 #WeekCalendar .ATMTable td:nth-child(2){
		 background: #fffdf0 !important;
	 }
	 #MonthCalendar .ATMTable td{
		 height: 76px;
	 }
	 #MonthCalendar .ATMTable tfoot td{
		 height: 43px;
	 }
</style>

	<div class="cRConTop titType AtnTop">
		<h2 class="title"><spring:message code='Cache.lbl_n_att_worksch'/> <spring:message code='Cache.lbl_GetView'/></h2>
		<span id="divDate" >
			<h2 class="title" id="dateTitle"></h2>
		    <div class="pagingType02">
		        <a class="pre"></a>
		        <a class="next"></a>
				<a href="#" class="calendartoday btnTypeDefault"><spring:message code='Cache.lbl_Todays'/></a>	<!-- 오늘 -->
			    <a href="#" class="calendarcontrol btnTypeDefault cal"></a>
				<input type="text" id="inputCalendarcontrol" style="height: 0px; width:0px; border: 0px;" >
		    </div>
		</span>
		<div class="searchBox02">
			<input type="text" id="searchText"><button type="button" class="btnSearchType01" id="btnSearch">검색</button>
		</div>
	</div>  
	<div class="cRContBottom">
		<div class="ATMCont">
			<div class="ATMTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					<select class="selectType02" id="deptList" style="height: 33px;"></select>
					<select class="selectType02" id="SchSeq">
					</select>
					<a class="btnTypeDefault btnExcel" id="btnExcelDownDaily"><spring:message code="Cache.btn_ExcelDownload"/></a>
					<a class="btnTypeDefault btnExcel" id="excelBtn" href="#"><spring:message code="Cache.btn_ExcelDownload"/></a>
				</div>
				<div class="ATMbuttonStyleBoxRight">
					<ul id="topButton" class="ATMschSelect">
						<li id="liDay"><a><spring:message code='Cache.lbl_Daily' /></a></li><!-- 일간 -->
						<li id="liWeek" class="selected"><a><spring:message code='Cache.lbl_Weekly' /></a></li><!-- 주간 -->
						<li id="liMonth"><a><spring:message code='Cache.lbl_Monthly' /></a></li><!-- 월간 -->
					</ul>
				</div>
				<div class="ATMFilter_Info_wrap">
					<div class="ATMFilter"  style="display: none;">
						<span id="monthlyFilter">
							&nbsp;주
							<input id="weeklyWorkValue" value="" style="width: 50px;height: 33px;" >&nbsp;시간&nbsp;
							<select class="selectType02" style="width: 68px;height: 33px;" id="weeklyWorkType">
								<option value="over">초과</option>
								<option value="under">이하</option>
							</select>
						</span>
						<button href="#" class="btnRefresh" type="button" id="btnRefresh" style="margin-left: 5px;"></button>
					</div>

					<div class="ATMInfo" id="monthlyatminfo">
						<p class="Calling" id="orange52">52<spring:message code="Cache.lbl_Hours"/> <spring:message code="Cache.lbl_above"/></p> <!-- 시간 초과 -->
						<select class="selectType02" style="width: 68px;height: 33px;" id="PageSize" onchange="setPage(1);">
							<option value="10" selected>10</option>
							<option value="15">15</option>
							<option value="20">20</option>
							<option value="30">30</option>
							<option value="50">50</option>
							<option value="100">100</option>
						</select>
					</div>
				</div>
			</div>
			<div id="DayCalendar" class="resDayListCont" style="display: none">
				<table class="ATMTable" cellpadding="0" cellspacing="0">
					<thead>
						<tr>
							<th width="150"></th>
							<th width="120"><spring:message code="Cache.lbl_att_Cumulative_duty_hours"/></th> <!-- 누적 근무시간 -->
							<th>
								<table class="ATMTable_day" cellpadding="0" cellspacing="0">
									<thead>
										<tr>
											<th colspan="12"><p class="tx_time">AM</p></th>
											<th colspan="12"><p class="tx_time">PM</p></th>
										</tr>
									</thead>
									<tbody>
										<tr>
											<td>12</td>
											<td>1</td>
											<td>2</td>
											<td>3</td>
											<td>4</td>
											<td>5</td>
											<td>6</td>
											<td>7</td>
											<td>8</td>
											<td>9</td>
											<td>10</td>
											<td>11</td>
											<td>12</td>
											<td>1</td>
											<td>2</td>
											<td>3</td>
											<td>4</td>
											<td>5</td>
											<td>6</td>
											<td>7</td>
											<td>8</td>
											<td>9</td>
											<td>10</td>
											<td>11</td>
										</tr>
									</tbody>
								</table>
							</th>
						</tr>
					</thead>
				</table>
				<div class="ATMTable_day_scroll scrollVType01" id="bodyDay">
					<table class="ATMTable" cellpadding="0" cellspacing="0"  id="bodyTblDay">
						<tbody>
						</tbody>
					</table>
				</div>
				<div class="ATMTable_day_tfoot">
					<table class="ATMTable" cellpadding="0" cellspacing="0" id="footerTimeList">
						<tfoot>
							<tr>
								<td width="150"><strong><spring:message code='Cache.lbl_total' /> <spring:message code='Cache.lbl_Hours' /></strong></td> <!-- 총 시간 -->
								<td width="120"><p class="td_time"></p></td>
								<td>
									<table class="ATMTable_day" cellpadding="0" cellspacing="0">
										<tbody>
											<tr>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
												<td>0</td>
											</tr>
										</tbody>
									</table>
								</td>
							</tr>
						</tfoot>
					</table>
				</div>
			</div>
			<div id="WeekCalendar" class="resDayListCont">
				<table class="ATMTable">
					<colgroup>
						<col width="150">
						<col width="120">
						<col>
						<col>
						<col>
						<col>
						<col>
						<col>
						<col>
					</colgroup>
					<tbody id="headerWeekList">
						<tr>
							<th width="150"><spring:message code='Cache.lbl_name' /></th> <!-- 이름 -->
							<th width="120"><spring:message code='Cache.lbl_att_Cumulative_duty_hours' /></th> <!-- 누적 근무시간 -->
							<th>1&nbsp;<spring:message code='Cache.lbl_sch_sun' /></th> <!-- 일 -->
							<th>2&nbsp;<spring:message code='Cache.lbl_sch_mon' /></th> <!-- 월 -->
							<th>3&nbsp;<spring:message code='Cache.lbl_sch_tue' /></th> <!-- 화 -->
							<th>4&nbsp;<spring:message code='Cache.lbl_sch_wed' /></th> <!-- 수 -->
							<th>5&nbsp;<spring:message code='Cache.lbl_sch_thu' /></th> <!-- 목 -->
							<th>6&nbsp;<spring:message code='Cache.lbl_sch_fri' /></th> <!-- 금 -->
							<th>7&nbsp;<spring:message code='Cache.lbl_sch_sat' /></th> <!-- 토-->
						</tr>
					</tbody>
				</table>
				<div class="ATMTable_01_scroll scrollVType01" id="bodyWeek">
					<table class="ATMTable" cellpadding="0" cellspacing="0" id="bodyTblWeek">
						<colgroup>
						<col width="150">
						<col width="120">
						<col>
						<col>
						<col>
						<col>
						<col>
						<col>
						<col>
						</colgroup>
						<tbody>
						</tbody>
					</table>
				</div>
	<!-- 총합계 테이블 시작 -->
				<div class="ATMTable_tfoot_wrap" id="footerWeek">
					<table class="ATMTable tfoot" cellpadding="0" cellspacing="0">
						<tfoot>
							<tr>
								<td width="150"><div class="tfoot_box"><p class="tfoot_title"><spring:message code='Cache.lbl_apv_TimeAverage' /></p></div></td> <!-- 평균시간 -->
								<td width="120"><p class="td_time"></p></td>
								<td><p class="td_time_day"></p></td>
								<td><p class="td_time_day"></p></td>
								<td><p class="td_time_day"></p></td>
								<td><p class="td_time_day"></p></td>
								<td><p class="td_time_day"></p></td>
								<td><p class="td_time_day"></p></td>
								<td><p class="td_time_day"></p></td>
							</tr>
							<tr>
								<td><div class="tfoot_box"><p class="tfoot_title"><spring:message code='Cache.lbl_TFTotalCount' /></p></div></td> <!-- 총인원 -->
								<td><p class="td_person"></p></td>
								<td><p class="td_time_day"></p></td>
								<td><p class="td_time_day"></p></td>
								<td><p class="td_time_day"></p></td>
								<td><p class="td_time_day"></p></td>
								<td><p class="td_time_day"></p></td>
								<td><p class="td_time_day"></p></td>
								<td><p class="td_time_day"></p></td>
							</tr>
						</tfoot>
					</table>
				</div>
	<!-- 총합계  테이블 끝 -->
			</div>
			<div id="MonthCalendar" class="resDayListCont" style="display:none">
				<table class="ATMTable" id="bodyTblMonthTitle">
					<colgroup>
						<col width="150">
						<col width="120">
						<col>
						<col>
						<col>
						<col>
						<col>
						<col>
					</colgroup>
					<tbody id="headerMonthList">
					<tr>
						<th width="150"><spring:message code='Cache.lbl_name' /></th> <!-- 이름 -->
						<th width="120"><spring:message code='Cache.lbl_Monthly' /> <spring:message code='Cache.lbl_sum' /></th> <!-- 월간 합계 -->
						<th>1&nbsp;<spring:message code='Cache.lbl_sch_sun' /></th> <!-- 일 -->
						<th>2&nbsp;<spring:message code='Cache.lbl_sch_mon' /></th> <!-- 월 -->
						<th>3&nbsp;<spring:message code='Cache.lbl_sch_tue' /></th> <!-- 화 -->
						<th>4&nbsp;<spring:message code='Cache.lbl_sch_wed' /></th> <!-- 수 -->
						<th>5&nbsp;<spring:message code='Cache.lbl_sch_thu' /></th> <!-- 목 -->
						<th>6&nbsp;<spring:message code='Cache.lbl_sch_fri' /></th> <!-- 금 -->
					</tr>
					</tbody>
				</table>
				<div class="ATMTable_02_scroll scrollVType01" id="bodyMonth">
					<table class="ATMTable" cellpadding="0" cellspacing="0" id="bodyTblMonth">
						<colgroup id="bodyTblMonthBodyColgroup">
							<col width="150">
							<col width="120">
							<col>
							<col>
							<col>
							<col>
						</colgroup>
						<tbody>
						</tbody>
					</table>
				</div>

			</div>
		</div>
	</div>
<input type="hidden" id="mode" value="W" />
<input type="hidden" id="StartDate" value="" />
<input type="hidden" id="EndDate" value="" />
<input type="hidden" id="pageNo" value="1" />
<input type="hidden" id="endPage" value="1" />
<script>
	var g_curDate = CFN_GetLocalCurrentDate("yyyy-MM-dd");
	var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
	
	if(CFN_GetCookie("AttListCnt")){
		pageSize = CFN_GetCookie("AttListCnt");
	}
	if(pageSize===null||pageSize===""||pageSize==="undefined"){
		pageSize=10;
	}

	$("#PageSize").val(pageSize);
	var weekCol = ["Sun","Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
	var viewCol = new Array(7);

	var strtWeek = parseInt(Common.getBaseConfig("AttBaseWeek"));
	var vacName = [];

	function dailyDataView(){
		$(".ATMFilter").hide();
		$("#topButton li").removeClass("selected");
		$("#liDay").addClass("selected");
		$(".cRConTop span").hide();
		$(".cRConTop #divDate").show();
		$(".resDayListCont").hide();
		$("#DayCalendar").show();
		$("#monthlyFilter").hide();
		$("#btnDelete").show();
		$("#btnExcelDownDaily").show();
		$("#excelBtn").hide();
		$("#orange52").hide();

		$("#mode").val("D");
		setDateTerm($("#mode").val(), $("#StartDate").val());
		setPage(1);
	}

	function weeklyDataView(){
		$(".ATMFilter").hide();
		$("#topButton li").removeClass("selected");
		$("#liWeek").addClass("selected");
		$(".cRConTop span").hide();
		$(".cRConTop #divDate").show();
		$(".resDayListCont").hide();
		$("#WeekCalendar").show();
		$("#monthlyFilter").hide();
		$("#btnDelete").show();
		$("#btnExcelDownDaily").hide();
		$("#excelBtn").show();
		$("#orange52").show();

		$("#mode").val("W");
		setDateTerm($("#mode").val(), $("#StartDate").val());
		setPage(1);
	}

	function monthlyDataView(){
		$(".ATMFilter").show();
		$("#topButton li").removeClass("selected");
		$("#liMonth").addClass("selected");
		$(".cRConTop span").hide();
		$(".cRConTop #divDate").show();
		$(".resDayListCont").hide();
		$("#WeekCalendar").hide();
		$("#MonthCalendar").show();
		$("#monthlyFilter").show();
		$("#btnDelete").hide();
		$("#btnExcelDownDaily").hide();
		$("#excelBtn").show();
		$("#orange52").show();

		$("#mode").val("M");
		setDateTerm($("#mode").val(), $("#StartDate").val());
		setPage(1);

	}

	//일간 엑셀다운
	$("#btnExcelDownDaily").click(function(){
		$('#download_iframe').remove();
		var url = "/groupware/attendJob/excelAttendJob.do";
		var params = {"mode" : $("#mode").val()
			,"StartDate": $("#StartDate").val()
			,"EndDate": $("#EndDate").val()
			,"SchSeq" : $("#SchSeq").val()
			,"searchText": $("#searchText").val()
			,"DeptCode":$("#deptList").val()};
		ajax_download(url, params); 	// 엑셀 다운로드 post 요청*/
	});

    // yyyy-MM-dd 포맷으로 반환 ==> MM.dd
    function getFormatDate(date){
        //var year = date.getFullYear();              //yyyy
        var month = (1 + date.getMonth());          //M
        month = month >= 10 ? month : '0' + month;  //month 두자리로 저장
        var day = date.getDate();                   //d
        day = day >= 10 ? day : '0' + day;          //day 두자리로 저장
        return  /*year + '-' + */month + '.' + day;
    }

    function addDays(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    }
	
	$(document).ready(function(){
		for (var i= 0; i< weekCol.length; i++){
			var idx = i+strtWeek-1;
			if (idx>= weekCol.length) idx = idx-7;
			viewCol[i] = weekCol[idx];
			
			if (viewCol[i] == "Sun"){
				$(".calMonTbl tr:eq(0) th:eq("+i+")").addClass("sun");
				for (var j=0; j<$(".monShcList").length; j++){
					$(".monShcList:eq("+j+") tr:eq(0) td:eq("+i+")").addClass("sun");
				}
			}	
			else if (viewCol[i] == "Sat"){
				$(".calMonTbl tr:eq(0) th:eq("+i+")").addClass("sat");
				for (var j=0; j<$(".monShcList").length; j++){
					$(".monShcList:eq("+j+") tr:eq(0) td:eq("+i+")").addClass("sat");
				}
			}	

			$(".calMonTbl tr:eq(0) th:eq("+i+")").text(Common.getDic("lbl_WP"+weekCol[idx]));
		}

		AttendUtils.getDeptList($("#deptList"), Common.getSession("GR_GroupPath"), false, false, true);
		AttendUtils.getScheduleList($("#SchSeq"),'', true);

		if ($("#deptList option").size() == 2)	$("#deptList").hide();
		setTodaySearch()
		$.ajax({
			type:"POST",
			data:{"codeGroups" : "VACATION_TYPE"},
			url:"/covicore/basecode/get.do",
			async : false,
			success:function (data) {
				if(data.result == "ok" && data.list != undefined){
					$.each(data.list[0].VACATION_TYPE, function(idx, obj){
						vacName[obj.Code]	= obj;				
					})	
				}
			}
		});
		sDate = AttendUtils.getWeekStart(new Date(replaceDate(g_curDate)), strtWeek-1);
		sDate = schedule_SetDateFormat(sDate, '-');
		eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '-');
		
        $("#StartDate").val(sDate);
        $("#EndDate").val(eDate);
        scrollH();
		//setPage(1);

		//일간 클릭
		$('#liDay').click(function(){
			dailyDataView();
		});

		//주간 클릭
		$('#liWeek').click(function(){
			weeklyDataView();
		});
		
		//월간 클릭
		$('#liMonth').click(function(){
			monthlyDataView();
		});
		
		//이전
		$(".pre").click(function(){
			var startDateObj = new Date(replaceDate($("#StartDate").val()));

			switch ($("#mode").val()){
				case "D":
					sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -1), '-');
					eDate = sDate;
					break;
				case "W":
					sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -7), '-');
					eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -1), '-');
					break;
				case "M":
					eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj.setDate(1), -1), '-');
					sDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()-1)).setDate(1), '-');
					break;
			}
			
            $("#StartDate").val(sDate);
            $("#EndDate").val(eDate);
			setPage(1);
		});
		
		//이후
		$(".next").click(function(){
			var startDateObj = new Date(replaceDate($("#StartDate").val()));

			switch ($("#mode").val()){
				case "D":
					sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 1), '-');
					eDate = sDate;
					break;
				case "W":
					sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 7), '-');
					eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 13), '-');
					break;
				case "M":
					sDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 1)), '-');
					eDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)), '-');
					break;
			}			
            $("#StartDate").val(sDate);
            $("#EndDate").val(eDate);
			setPage(1);
		});
		
		$("#deptList, #SchSeq").change(function(){
			setPage(1);
		});
		//사용자명 검색
		$("#searchText").on('keypress', function(e){ 
			if (e.which == 13) {
				setPage(1);
		    }
		});

		//검색
		$("#btnRefresh, #btnSearch").click(function(){
			setPage(1);
		});


		
		$.mCustomScrollbar.defaults.scrollButtons.enable=true; //enable scrolling buttons by default

		//일별 스크롤
		$("#bodyDay").mCustomScrollbar({
			mouseWheelPixels: 50,scrollInertia: 350,
			callbacks:{
		        onScroll:function(){
		            myCustomFn("bodyDay");
		        }
		    }
		});

		//주별 스크롤
		$("#bodyWeek").mCustomScrollbar({
			mouseWheelPixels: 50,scrollInertia: 350,
			callbacks:{
		        onScroll:function(){
		            myCustomFn("bodyWeek");
		        }
		    }
		});
		//월별 스크롤
		$("#bodyMonth").mCustomScrollbar({
			mouseWheelPixels: 50,scrollInertia: 350,
			callbacks:{
				onScroll:function(){
					myCustomFn("bodyMonth");
				}
			}
		});


		$("#topButton li").each(function (idx){
			if($(this).hasClass("selected") && $(this).attr("id")=="liDay"){
				dailyDataView();
			}else if($(this).hasClass("selected") && $(this).attr("id")=="liWeek"){
				weeklyDataView();
			}else if($(this).hasClass("selected") && $(this).attr("id")=="liMonth"){
				monthlyDataView();
			}
		});

		//엑셀다운로드 버튼 클릭 이벤트
		$("#excelBtn").on('click',function(){
			var popupID		= "AttendJobViewExcelDownPopup";
			var openerID	= "AttendJobView";
			var popupTit	= "<spring:message code='Cache.lbl_SaveToExcel' />";
			var popupYN		= "N";
			var popupUrl	= "/groupware/attendJob/getAttendJobViewExcelDownPopup.do?"
                + "popupID="		+ popupID	+ "&"
                + "mode="			+ $("#mode").val()	+ "&"
                + "openerID="		+ openerID	+ "&"
                + "popupYN="		+ popupYN	+ "&"
                + "StartDate="		+ $("#StartDate").val() + "&"
                + "EndDate="		+ $("#EndDate").val() + "&"
                + "searchText="		+ $("#searchText").val() + "&"
				+ "DeptCode="		+ encodeURIComponent($("#deptList").val()) + "&"
                + "weeklyWorkType="	+ $("#weeklyWorkType").val() + "&"
                + "weeklyWorkValue="+ $("#weeklyWorkValue").val();

			Common.open("", popupID, popupTit, popupUrl, "500px", "300px", "iframe", true, null, null, true);
		});
		//주당 시간 검색 조건 input 관련 이벤트
		//$("#weeklyWorkValue").bindNumber();
		$("#weeklyWorkValue").keyup(function() {
			if ($.trim($("#weeklyWorkValue").val()) != "") {
				var weeklyWorkValue = 0;
				weeklyWorkValue = Number($("#weeklyWorkValue").val());
				if(weeklyWorkValue<0){
					$("#weeklyWorkValue").val(0);
					weeklyWorkValue = Number($("#weeklyWorkValue").val());
				}
				if (!Number.isInteger(weeklyWorkValue)) {
					Common.Warning(Common.getDic("msg_ObjectUR_29"));
					return false;
				} else {//정상 반경 값 입력시
					setPage(1);
				}
			}
		});
		$("#weeklyWorkValue").change(function() {
			var weeklyWorkValue = 0;
			weeklyWorkValue = Number($("#weeklyWorkValue").val());
			if(weeklyWorkValue<0){
				$("#weeklyWorkValue").val(0);
			}
		});
		//-->

	});
	
	$(window).resize(function(){
		scrollH();
	});

	function myCustomFn(id){
		var scrollTop = Math.abs($("#"+id+" .mCSB_container").position().top);
        var innerHeight = $("#"+id).height();
        var scrollHeight = $("#"+id+" .mCSB_container").prop('scrollHeight');
		if ((scrollTop + innerHeight+20) >= scrollHeight) {
        	if (parseInt($("#pageNo").val())+1 <= parseInt($("#endPage").val())){
        		setPage(parseInt($("#pageNo").val())+1);
        	}	
        } 
	}

	
	function autoResize(sType){
		if ( sType =="W"){
			var 	w_height = $('#WeekCalendar').height() - 141 + 'px';
			if ($("#bodyWeek .mCSB_container").css("height") < $(".ATMTable_01_scroll").css("height")  ){
				w_height = $("#bodyWeek .mCSB_container").css("height");
			}
			$('.ATMTable_01_scroll').css('height',w_height);
			
		}else if ( sType =="M"){
			var 	m_height = $('#MonthCalendar').height() - 121 + 'px';
			$('.ATMTable_02_scroll').css('height',m_height);
		}
		else{
			var 	w_height = $('#WeekCalendar').height() - 121 + 'px';
			if ($("#bodyDay .mCSB_container").css("height") < $(".ATMTable_day_scroll").css("height")  ){
				w_height = $("#bodyDay .mCSB_container").css("height");
			}
			$('.ATMTable_day_scroll').css('height',w_height);
		}	
	}

	function scrollH() {
		//근무일정설정 스크롤 영역높이
		$('.cRContBottom').css("overflow","hidden");
		var w_height1 = $('.cRContBottom').height() - 105 + 'px';
		var w_height3 = $('.cRContBottom').height() - 50 + 'px';
		$('#DayCalendar').css('height',w_height1);
		$('#WeekCalendar').css('height',w_height1);
		$('#MonthCalendar').css('height',w_height3);
		var w_height2 = $('#WeekCalendar').height() - 121 + 'px';
		
		$('.ATMTable_01_scroll').css('height',w_height2);
		$('.ATMTable_day_scroll').css('height',w_height2);
	}

	function setPage (n) {
		CFN_SetCookieDay("AttListCnt", $("#PageSize option:selected").val(), 31536000000);
		$("#pageNo").val(n);
		searchData();
	}
	
	function searchList(dateText){
		setDateTerm($("#mode").val(), dateText);
		searchData();
	}
	
	function refreshList(){
		setDateTerm($("#mode").val(), g_curDate);
		searchData();
	}
	function setDateTerm(mode, gDate){
		switch (mode){
			case "D":
	            $("#StartDate").val(gDate);
	            $("#EndDate").val(gDate);
	            break;
			case "W":
				sDate = AttendUtils.getWeekStart(new Date(replaceDate(gDate)), strtWeek-1);
				sDate = schedule_SetDateFormat(sDate, '-');
				eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '-');
	            $("#StartDate").val(sDate);
	            $("#EndDate").val(eDate);
	            break;
			case "M":
				sDate = schedule_SetDateFormat(new Date(gDate.substring(0,4), (gDate.substring(5,7) - 1), 1), '-');
				eDate = schedule_SetDateFormat(new Date(gDate.substring(0,4), gDate.substring(5,7), 0), '-')
	            $("#StartDate").val(sDate);
	            $("#EndDate").val(eDate);
	            break;
		}
	}
	
	function searchData(){

		var params = {"mode" : $("#mode").val()
					 ,"StartDate": $("#StartDate").val()
					 ,"EndDate": $("#EndDate").val()
					 ,"weeklyWorkType" : $("#weeklyWorkType").val()
					 ,"weeklyWorkValue" : $("#weeklyWorkValue").val()
					 ,"searchText": $("#searchText").val()
					 ,"DeptCode":$("#deptList").val()
			     	 ,"SchSeq" : $("#SchSeq").val()
					 ,"pageNo" : $("#pageNo").val()
					 ,"pageSize": $("#PageSize option:selected").val() };
		
		switch ($("#mode").val())
		{
			case "D":
				params["pageSize"]=15;
				$("#dateTitle").text (AttendUtils.maskDate($("#StartDate").val()) );
				break;
			case "W":
				$("#dateTitle").text (AttendUtils.maskDate($("#StartDate").val()) +"~"+ AttendUtils.maskDate($("#EndDate").val()));
				for(var l=0; l < 7; l++){
					var tmp=				schedule_SetDateFormat(schedule_AddDays(sDate, l),"-");

					$("#WeekCalendar #headerWeekList tr:eq(0) th:eq("+(l+2)+")").html(tmp.substring(8,10)+"일&nbsp;("+Common.getDic("lbl_WP"+viewCol[l])+")");
					if (viewCol[l] == "Sun")
						$("#WeekCalendar #headerWeekList tr:eq(0) th:eq("+(l+2)+")").addClass("tx_sun");
					else if	(viewCol[l] == "Sat")
						$("#WeekCalendar #headerWeekList tr:eq(0) th:eq("+(l+2)+")").addClass("tx_sat");

					if (tmp == g_curDate){
						$("#WeekCalendar #headerWeekList tr:eq(0) th:eq("+(l+2)+")").addClass("selected");
					}
					else{
						$("#WeekCalendar #headerWeekList tr:eq(0) th:eq("+(l+2)+")").removeClass("selected");
					}
				}
				break;
			case "M":
				$("#dateTitle").text (AttendUtils.maskDate($("#StartDate").val()) +"~"+ AttendUtils.maskDate($("#EndDate").val()));

				break;
		}

		$.ajax({
			type:"POST",
			data:params,
			url:"/groupware/attendJob/getAttendJobView.do",
			success:function (data) {
				if(data.result == "ok"){
					switch ($("#mode").val())
					{
						case "D":
							showScheduleJobDay(data);
							break;
						case "W":
							showScheduleJobWeek(data);
							break;
						case "M":	
							showScheduleJobMonth(data);
							break;
					}		
				}
				else{
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
				}
			},
			error:function (request,status,error){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			}
		});
	}

	function settingTime(strtIdx, obj, startVal, endVal, workName, className){
		var sH = parseInt(startVal.substring(0,2),10);
		var sM = parseInt(startVal.substring(2,3),10);
		var eH = parseInt(endVal.substring(0,2),10);
		var eM  = parseInt(endVal.substring(2,3),10);

		var htmlList= "";
		var blinkIdx =0;
		for (var i=strtIdx; i< sH; i++){
			htmlList+='<td></td>';
			blinkIdx++;
		}
		var colspan = (eH-sH);

		var dataMap = {"UserName": obj["UserName"], "UserCode": obj["UserCode"], "JobDate":obj["JobDate"]};
		var vacInfo = workName+ " "+AttendUtils.formatTime(startVal,'AP') + '~' + AttendUtils.formatTime(endVal,'AP');
		htmlList+="<td colspan="+colspan+">"+
				"<a class='"+className +(obj["ConfmYn"] == "Y"?" Bg":"")+"' "+(sM>0?"style='left:20px'":"")+">"+
				"<span  data-map='"+JSON.stringify(dataMap)+"' id='jobInfoView' class='tx_title' title='"+vacInfo+"'>"+vacInfo+"</span>"+
				"</a>"+
				"</td>";
		var returnVal = {"endIdx":strtIdx+blinkIdx+colspan, "html":htmlList};
		return returnVal;
	}

	//근무시간 미지정 근무제 출력
	function settingNonefixedTime(strtIdx, obj, startVal, endVal, workName, className){
		var sH = parseInt(startVal.substring(0,2),10);
		var sM = parseInt(startVal.substring(2,3),10);
		var eH = parseInt(endVal.substring(0,2),10);
		var eM  = parseInt(endVal.substring(2,3),10);

		var htmlList= "";
		var blinkIdx =0;
		for (var i=strtIdx; i< sH; i++){
			htmlList+='<td></td>';
			blinkIdx++;
		}
		var colspan = (eH-sH);

		var dataMap = {"UserName": obj["UserName"], "UserCode": obj["UserCode"], "JobDate":obj["JobDate"]};
		htmlList+="<td colspan="+colspan+">"+
				"<a class='"+className +(obj["ConfmYn"] == "Y"?" Bg":"")+"' "+(sM>0?"style='left:20px'":"")+">"+
				"<span  data-map='"+JSON.stringify(dataMap)+"' id='jobInfoView' class='tx_title'>"+workName+
				"</a>"+
				"</td>";
		var returnVal = {"endIdx":strtIdx+blinkIdx+colspan, "html":htmlList};
		return returnVal;
	}
	
	//일간보기
	function showScheduleJobDay(data){
		var htmlHeader = "";
		var htmlList = "";
		var lastIdx = 24;
		var userCode = "";

		$.each(data.list, function(idx, obj){
			var lbl_ProfilePhoto = "<spring:message code='Cache.lbl_ProfilePhoto' />"; //프로필사진
			var reasonText = "";
			var reqMap = {"UserName": obj["UserName"], "UserCode": obj["UserCode"], "JobDate":obj["JobDate"], "StartDate":$("#StartDate").val(), "EndDate":$("#EndDate").val()};
			htmlList +='<tr>'+
				'<td width="150"><input type="hidden" value="'+obj.UserCode+'" data-map=\''+JSON.stringify(reqMap)+'\' >'+
				'	<div class="ATMT_user_wrap">'+
				'		<div class="ATMT_user_img">'+
				((obj["PhotoPath"]!= null && obj["PhotoPath"]!= "")?'<img src="'+coviCmn.loadImage(obj["PhotoPath"])+'" alt="'+lbl_ProfilePhoto+'" class="mCS_img_loaded" onerror="coviCmn.imgError(this, true)">':'<p class=\"bgColor'+Math.floor(idx%5+1)+'\"><strong>'+obj.UserName.substring(0,1)+'</strong></p>')+
				'	</div>'+
				'		<div class="ATMT_name btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="cursor:pointer" data-user-code="'+ obj.UserCode +'" data-user-mail="">'+obj.UserName+' '+AttendUtils.userRepJobType(obj)+'</div>'+
				'		<p class="ATMT_team">'+obj.DeptName+'</p>'+
				'	</div>'+
				'</td>'+
				'<td width="120"><p class="td_time">'+AttendUtils.convertSecToStr(obj["AttDayAC"],'H')+'</p></td>'+
				'<td>'+
				'<div class="ATMTable_day_wrap">'+
				'<table class="calGrid" cellpadding="0" cellspacing="0">'+
				'	<tr>';

			if (obj.WorkSts == "ON"){
				var returnObj ;
				var endIdx=0;
				var vacFlag ;
				if (obj["VacFlag"] != null) vacFlag = obj["VacFlag"].split("/");

				if (obj["VacFlag"] != null && parseFloat(vacFlag[2])>=1){
					htmlList+= "<td colspan="+lastIdx+" style='text-align:center'><a class='WorkBox Vacation TaC"+(obj["ConfmYn"] == "Y"?" Bg":"")+"'>";
					//<!--2021.07.21 nkpark 공동연차 등록시, 공동연차사유 값이 있으면 연차\n(사유) 표기처리
					if(vacFlag[1].indexOf('{')>-1&&vacFlag[1].indexOf('}')>-1){
						reasonText = vacFlag[1].substr(vacFlag[1].indexOf('{')+1,vacFlag[1].indexOf('}')-1);
						htmlList+= getVacName(vacFlag[0] ,vacFlag[1])+"("+reasonText+")";
					}else{
						htmlList+= getVacName(vacFlag[0] ,vacFlag[1]);
					}
					//-->
					htmlList+= "</a></td>";
				}
				else{
					var startTime = obj["AttDayStartTime"];
					var endTime = obj["AttDayEndTime"];
//VACATION_OFF|VACATION_ONE_HOUR|VACATION_ONE_HOUR
// AM|PM|PM
// .75
// 00:00|14:00|15:00
// 00:00|15:00|16:00
// .5|.125|.125
					if (obj["VacFlag"] != null)
					{
						if (parseFloat(vacFlag[2]) > 0){
							var arrVacDay = null;
							var arrVacFlag = null;
							var arrVacOffFlag = null;
							var arrVacStartTime = null;
							var arrVacEndTime = null;
							var arrAmPmVacDay = null;
							if(vacFlag[5].indexOf("|")>-1){
								arrVacFlag = vacFlag[0].split("|");
								arrVacOffFlag = vacFlag[1].split("|");
								arrVacStartTime = vacFlag[3].split("|");
								arrVacEndTime = vacFlag[4].split("|");
								arrVacDay = vacFlag[5].split("|");
								arrAmPmVacDay = vacFlag[6].split("|");
							}else{
								arrVacFlag = new Array( vacFlag[0]);
								arrVacOffFlag = new Array( vacFlag[1]);
								arrVacStartTime = new Array( vacFlag[3]);
								arrVacEndTime = new Array( vacFlag[4]);
								arrVacDay = new Array( vacFlag[5]);
								arrAmPmVacDay = new Array( vacFlag[6]);
							}
							var ampmCnt = 0;
							var bfEndTime = 0;
							for(var i=0;i<arrVacDay.length;i++){
								ampmCnt++;
								var vacName = getVacName(arrVacFlag[i] ,arrVacOffFlag[i]);
								var tmpStime = arrVacStartTime[i];
								var tmpEtime = arrVacEndTime[i];
								if(parseFloat(arrVacDay[i])===0.5 && parseFloat(arrAmPmVacDay[0])===0.5){
									var halfOffMin = parseFloat(obj["AttDayAC"])*0.5;
									var JobDateTime = obj["JobDate"].replaceAll('-','/')+" "+endTime.substring(0,2)+":"+endTime.substring(2,4)+":00"
									var newDateObj = new Date(JobDateTime);
									newDateObj.setTime(newDateObj.getTime()-(halfOffMin * 60 * 1000));
									var h = ""+newDateObj.getHours();
									if(newDateObj.getHours()<10){
										h = "0"+h;
									}
									var m = ""+newDateObj.getMinutes();
									if(newDateObj.getMinutes()<10){
										m = "0"+m;
									}
									tmpStime = startTime.substring(0,2)+":"+startTime.substring(2,4);
									tmpEtime = h+":"+m;
								}
								if(parseFloat(arrVacDay[i])===0.5 && parseFloat(arrAmPmVacDay[1])===0.5){
									var halfOffMin = parseFloat(obj["AttDayAC"])*0.5;
									var JobDateTime = obj["JobDate"].replaceAll('-','/')+" "+startTime.substring(0,2)+":"+startTime.substring(2,4)+":00"
									var newDateObj = new Date(JobDateTime);
									newDateObj.setTime(newDateObj.getTime()+(halfOffMin * 60 * 1000));
									if(obj["BaseYn"] == "Y"){
										newDateObj.setTime(newDateObj.getTime()-(60 * 60 * 1000));
									}
									var h = ""+newDateObj.getHours();
									if(newDateObj.getHours()<10){
										h = "0"+h;
									}
									var m = ""+newDateObj.getMinutes();
									if(newDateObj.getMinutes()<10){
										m = "0"+m;
									}
									tmpStime = h+":"+m;
									tmpEtime = endTime.substring(0,2)+":"+endTime.substring(2,4);
								}
								var sTime = tmpStime.replace(":","");
								var eTime = tmpEtime.replace(":","");
								if(i===0 && Number(startTime)<Number(sTime)){
									returnObj =    settingTime(endIdx, obj, startTime, sTime, (obj["SchName"]==null?'':obj["SchName"]), 'WorkBox Normal');
									htmlList+=returnObj["html"];
									endIdx = 	returnObj["endIdx"];
								}else if(i>0 && (bfEndTime+100)<Number(sTime)){
									var schStartTime = ""+bfEndTime;
									returnObj =    settingTime(endIdx, obj, schStartTime, sTime, (obj["SchName"]==null?'':obj["SchName"]), 'WorkBox Normal');
									htmlList+=returnObj["html"];
									endIdx = 	returnObj["endIdx"];
								}
								bfEndTime = Number(eTime);
								returnObj =    settingTime(endIdx, obj, sTime, eTime, vacName, 'WorkBox Vacation');
								htmlList+=returnObj["html"];
								endIdx = 	returnObj["endIdx"];
							}
							if(bfEndTime<Number(endTime)){
								var beforeEndTime = ""+bfEndTime;
								returnObj =    settingTime(endIdx, obj, beforeEndTime, endTime, (obj["SchName"]==null?'':obj["SchName"]), 'WorkBox Normal');
								htmlList+=returnObj["html"];
								endIdx = 	returnObj["endIdx"];
							}
						}
					}
					else{
						if(obj["WorkingSystemType"]>0 && obj["AttDayStartTime"]=="0000" && obj["AttDayEndTime"]=="0000"){
							returnObj =    settingNonefixedTime(0, obj, startTime, "2400", (obj["SchName"]==null?'':obj["SchName"]), 'WorkBox Normal');
						}else{
							returnObj =    settingTime(0, obj, startTime, endTime, (obj["SchName"]==null?'':obj["SchName"]), 'WorkBox Normal');
						}
						htmlList+=returnObj["html"];
						endIdx = 	returnObj["endIdx"];
					}

					var tmp=0;
					for (var k=endIdx; k< lastIdx; k++){
						htmlList+="<td></td>";
						tmp++;
					}
				}
			}
			else if (obj.WorkSts == "OFF" || obj.WorkSts == "HOL"){
				htmlList+="<td colspan="+lastIdx+" style='text-align:center'><a class='WorkBox Vacation TaC'>"+
						(obj["WorkSts"] == "OFF" ? "<spring:message code='Cache.lbl_att_sch_holiday' />": "<spring:message code='Cache.lbl_Holiday' />")+
						"</a></td>";
			}
			else{
				htmlList+="<td colspan="+lastIdx+" style='text-align:center'><spring:message code='Cache.lbl_NoSchedule' /></td>"; //무일정
			}

			htmlList+='</tr>'+
					'</table>'+
					'<table class="ATMTable_day" cellspacing="0" cellpadding="0">'+
					'	<tr>'+
					'		<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>'+
					'		<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>'+
					'	</tr>'+
				'</table>'+
				'</div>'+
			'</td>'+
			'</tr>';
		});

		if ($("#pageNo").val() == "1") {
			$("#bodyDay #bodyTblDay").html("");
		}

		$("#bodyDay #bodyTblDay").append(htmlList);
		if ($("#pageNo").val() == "1"){
			$("#DayCalendar #footerTimeList .td_time").text(AttendUtils.convertSecToStr(data.avg.ACAvg,'H'));
			for (var i=0;i<24; i++){
				$("#footerTimeList .ATMTable_day tr:eq(0) td:eq("+i+")").text(data.avg["Day_"+AttendUtils.paddingStr(i,"R","0",2)]);
			}
			setTimeout("autoResize('D')", 100);
		}

	}	
	
	//주간보기
	function showScheduleJobWeek(data){
		var htmlList = "";

		$.each(data.list, function(idx, obj){
			var lbl_ProfilePhoto = "<spring:message code='Cache.lbl_ProfilePhoto' />"; //프로필사진
			var reqMap = {"UserName": obj["UserName"], "UserCode": obj["UserCode"], "JobDate":obj["JobDate"], "StartDate":$("#StartDate").val(), "EndDate":$("#EndDate").val()};
			htmlList+='<tr><td><label>'+
					'<input type="hidden" value="'+obj.UserCode+'" data-map=\''+JSON.stringify(reqMap)+'\' >'+
					'<div class="ATMT_user_wrap">'+
					'		<div class="ATMT_user_img">'+
					((obj["PhotoPath"]!= null && obj["PhotoPath"]!= "")?'<img src="'+coviCmn.loadImage(obj["PhotoPath"])+'" alt="'+lbl_ProfilePhoto+'" class="mCS_img_loaded" onerror="coviCmn.imgError(this, true)">':'<p class=\"bgColor'+Math.floor(idx%5+1)+'\"><strong>'+obj.UserName.substring(0,1)+'</strong></p>')+
					'	</div>'+
					'<div class="ATMT_name btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="cursor:pointer" data-user-code="'+ obj.UserCode +'" data-user-mail="">'+obj.UserName+' '+AttendUtils.userRepJobType(obj)+'</div>'+
					'<p class="ATMT_team">'+obj.DeptName+'</p>'+
					'</div></td>';

			var tohh = Math.floor(obj["AttDayAC"]/60);
			var tomm = obj["AttDayAC"]%60;
			var alertOverTime = false;
			var alertOverCls = "";
			var alertOverSty = "";
			var workTimeTotal = "";
			if(tohh>0 || tomm>0) {
				workTimeTotal = tohh + "h ";
				workTimeTotal += tomm + "m";
				if(tohh>52){
					alertOverTime=true;
				}else if(tohh==52 && tomm>0){
					alertOverTime=true;
				}
			}
			if(alertOverTime){
				alertOverCls = "WorkBoxW Calling";
				alertOverSty = "margin: 0 0 3px 3px;padding: 1px 0;";
			}
			htmlList +='<td><span class="td_time tx_title '+alertOverCls+'" style="color: #457d80;font-size: 15px;line-height: 20px;'+alertOverSty+'">'+workTimeTotal+'</span></td>';

			for (var i=0;i<viewCol.length; i++){
				var workSts="";
				var className= "";
				var preWorkSts= "";
				var postWorkSts= "";
				if (obj["WorkSts_"+viewCol[i]] == "OFF" || obj["WorkSts_"+viewCol[i]] == "HOL" ){
					className = "Closed Bg";

					workSts = "<p class='tx_closed'>"+
					 (obj["WorkSts_"+viewCol[i]] == "OFF" ? "<spring:message code='Cache.lbl_att_sch_holiday' />": "<spring:message code='Cache.lbl_Holiday' />")+
						"</p>";
				}
				else
				{
					if (obj["AttDayStartTime_"+viewCol[i]] != null){
						className = "";
						var workClassName = "Normal";
						//var workName = obj["SchName_"+viewCol[i]];
						var workName = (obj["SchName_"+viewCol[i]]==null?'':obj["SchName_"+viewCol[i]]);
						var half = false;
						var reasonText = "";
						var ampmCnt = 0;
						if (obj["VacFlag_"+viewCol[i]] != null && obj["VacFlag_"+viewCol[i]] != '') {
							var vacFlag = obj["VacFlag_"+viewCol[i]].split(":");
							//VACATION_ONE_HOURS|VACATION_ONE_HOURS|VACATION_ONE_HOURS:
							// AM|PM|PM:
							// 0.3750:
							// 0.1250|0.2500
							if ((Number(vacFlag[2])>0 && Number(vacFlag[2])<=1) || vacFlag[1].indexOf("AM")>-1 || vacFlag[1].indexOf("PM")>-1) //반차이면
							{
								var vacNameStr = "";
								var vacAmPmVacDay = vacFlag[3];
								var arrVacAmPmVacDay = null;
								if(vacAmPmVacDay.indexOf("|")>-1){
									arrVacAmPmVacDay = vacAmPmVacDay.split('|');
								}
								if (vacFlag[1].indexOf("AM")>-1 && Number(arrVacAmPmVacDay[0])>=0.5) {
									ampmCnt++;
									if(vacFlag[0].indexOf("|")>-1){
										var arrVacFlag = vacFlag[0].split("|");
										var arrVacOffFlag = vacFlag[1].split("|");
										vacNameStr = getVacName(arrVacFlag[0] ,arrVacOffFlag[0]);
									}else{
										vacNameStr = getVacName(vacFlag[0] ,vacFlag[1]);
									}
									var halfName0 = '<a class="WorkBox Half Vacation" href="#">'+
											'<span class="tx_title">'+vacNameStr+'</span>'+
											'</a>';
									preWorkSts = halfName0;
								}
								if (vacFlag[1].indexOf("PM")>-1 && Number(arrVacAmPmVacDay[1])>=0.5){
									ampmCnt++;
									if(vacFlag[0].indexOf("|")>-1){
										var arrVacFlag = vacFlag[0].split("|");
										var arrVacOffFlag = vacFlag[1].split("|");
										vacNameStr = getVacName(arrVacFlag[1] ,arrVacOffFlag[1]);
									}else{
										vacNameStr = getVacName(vacFlag[0] ,vacFlag[1]);
									}
									var halfName1 = '<a class="WorkBox Half Vacation" href="#">'+
											'<span class="tx_title">'+vacNameStr+'</span>'+
											'</a>';
									postWorkSts = halfName1;
								}
								if(ampmCnt===1){
									workClassName ="Half Normal";
									half=true;
								}else if(ampmCnt===2){
									workClassName ="";
								}
							}
							else{
								workClassName ="Vacation";
								workName = getVacName(vacFlag[0] );
								//<!--2021.07.21 nkpark 공동연차 등록시, 공동연차사유 값이 있으면 연차\n(사유) 표기처리
								if(vacFlag[1].indexOf('{')>-1&&vacFlag[1].indexOf('}')>-1){
									reasonText = vacFlag[1].substr(vacFlag[1].indexOf('{')+1,vacFlag[1].indexOf('}')-1);
									workName += "<br/>("+reasonText+")";
								}
								//-->
							}

						}
						if (obj["ConfmYn_"+viewCol[i]] == "Y") workClassName += " Bg";

						workSts = preWorkSts;
						if(ampmCnt<2) {
							workSts += '<a class="WorkBox ' + workClassName + '">';
							workSts += '<span class="tx_title" ';
							if (reasonText.length > 0) {
								workSts += 'style="margin-top: -10px;"';
							}
							workSts += '>' + workName + '</span>';
							if (!half) {
								workSts += '<span class="tx_time">' + AttendUtils.formatTime(obj["AttDayStartTime_" + viewCol[i]], 'AP') + '</span>' +
										'<span class="tx_time">' + AttendUtils.formatTime(obj["AttDayEndTime_" + viewCol[i]], "AP") + '</span>';
							}
							workSts += '</a>';
						}
						workSts += postWorkSts;
					}
				}

				var dataMap = {"UserName": obj["UserName"], "UserCode": obj["UserCode"], "JobDate":obj["AttDay_"+viewCol[i]]};
				htmlList+='		<td class="'+className+'" data-map='+JSON.stringify(dataMap)+' id="jobInfoView">'+ workSts +'</td>';
			}
			htmlList+='	</tr>';
		});

		if ($("#pageNo").val() == "1")	{
			$("#bodyWeek #bodyTblWeek tbody").html("");
		}

		$("#bodyWeek #bodyTblWeek tbody").append(htmlList);
		if ($("#pageNo").val() == "1"){
			$("#footerWeek .tfoot tr:eq(0) td:eq(1) p").text(AttendUtils.convertSecToStr(data.avg["ACAvg"],'H'));
			$("#footerWeek .tfoot tr:eq(1) td:eq(1) p").text(data.avg["JobCnt"]);
			for (var i=0;i<viewCol.length; i++){
				$("#footerWeek .tfoot tr:eq(0) td:eq("+(i+2)+") p").text(AttendUtils.convertSecToStr(data.avg["ACAvg_"+viewCol[i]],'H'));
				$("#footerWeek .tfoot tr:eq(1) td:eq("+(i+2)+") p").text(data.avg["ACCount_"+viewCol[i]]);
			}
			setTimeout("autoResize('W')", 100);
		}

		showPageing(data.page);
	}
	
	//월간보기
	function showScheduleJobMonth(data){
		var htmlList = "";
        var colNumWeeks = data.colNumWeeks;
        var weeksNum = data.weeksNum;
        var rsdate = data.rangeStartDate;
        var rangeStartDate = new Date(rsdate);
        var viewCol = new Array(colNumWeeks);

        var htmlHeader = "<tr><th width=\"150\">이름</th><th width=\"120\"><spring:message code='Cache.lbl_Monthly' /> <spring:message code='Cache.lbl_sum' /></th>"; //월간 합계
        for(var c=0;c<weeksNum.length;c++){
            //헤더 label 입력
            htmlHeader += "<th>";
            htmlHeader += weeksNum[c]+"<spring:message code='Cache.lbl_TheWeek' />"; //주차
            htmlHeader += "<p style='font-weight: normal;color: #838383;'>";
            var sdate = getFormatDate(rangeStartDate);
            rangeStartDate = addDays(rangeStartDate, 6);
            var edate = getFormatDate(rangeStartDate);
            rangeStartDate = addDays(rangeStartDate, 1);
            htmlHeader += sdate+"~"+edate;
            htmlHeader += "</p>";
            htmlHeader += "</th>";
        }

        //헤더 교체
        htmlHeader += "</tr>";
        $("#headerMonthList").html(htmlHeader);
		//헤더 상단 콜 구룹 교체
        var htmlColGroup = '<col width="150"><col width="120">';
		for (var n=0;n<viewCol.length; n++){
			htmlColGroup += '<col>';
		}
		$("#bodyTblMonthTitle colgroup").html(htmlColGroup);
		$("#bodyTblMonthBodyColgroup colgroup").html(htmlColGroup);

		//데이터 생성
		$.each(data.list, function(idx, obj){
			var lbl_ProfilePhoto = "<spring:message code='Cache.lbl_ProfilePhoto' />"; //프로필사진
			var reqMap = {"UserName": obj["UserName"], "UserCode": obj["UserCode"], "JobDate":obj["JobDate"], "StartDate":$("#StartDate").val(), "EndDate":$("#EndDate").val()};
			var jobTitleName = obj.JobTitleName;
			var jobTitleNameHtml = "";
			if(jobTitleName!=""&&jobTitleName!=null){
				jobTitleNameHtml = "("+jobTitleName+")";
			}
			htmlList+='<tr><td><label>'+
					'<input type="hidden" value="'+obj.UserCode+'" data-map=\''+JSON.stringify(reqMap)+'\' >'+
					'<div class="ATMT_user_wrap">'+
					'		<div class="ATMT_user_img">'+
					((obj["PhotoPath"]!= null && obj["PhotoPath"]!= "")?'<img src="'+coviCmn.loadImage(obj["PhotoPath"])+'" alt="'+lbl_ProfilePhoto+'" class="mCS_img_loaded" onerror="coviCmn.imgError(this, true)">':'<p class=\"bgColor'+Math.floor(idx%5+1)+'\"><strong>'+obj.UserName.substring(0,1)+'</strong></p>')+
					'	</div>'+
					'<div class="ATMT_name btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="cursor:pointer" data-user-code="'+ obj.UserCode +'" data-user-mail="">'+obj.UserName+' '+AttendUtils.userRepJobType(obj)+'</div>'+
					'<p class="ATMT_team">'+obj.DeptName+''+jobTitleNameHtml+'</p>'+
					'</div></td>'+
					'<td><p class="td_time" style="line-height: 22px;">#totalAttenTime#</p></td>';

			var toToTime = 0;
			var toAcTime = 0;
            var toExTime = 0;
            var toHoTime = 0;
			for (var i=0;i<viewCol.length; i++){
			    var brCnt = 0;
				var workSts="";
				var className= "";
				var postWorkSts= "";
                var workClassName = "Normal";
				var workName = "";
				var workTimeTotal = "";

				//make row start
				//각 주간 업무시간 월단위 합산
				toToTime += obj["AttDayTO_"+i];
				toAcTime += obj["AttDayAC_"+i];
				toExTime += obj["AttDayEX_"+i];
				toHoTime += obj["AttDayHO_"+i];
				//기본근무시간
				var achh = Math.floor(obj["AttDayAC_"+i]/60);
				var acmm = obj["AttDayAC_"+i]%60;
				if(achh>0 || acmm>0) {
					brCnt++;
					workName = "<spring:message code='Cache.lbl_hr_base' />:" + achh + "h"; //기본
					if (acmm > 0) {
						workName += acmm + "m";
					}
				}
				//연장근무시간
				var exhh = Math.floor(obj["AttDayEX_"+i]/60);
				var exmm = obj["AttDayEX_"+i]%60;
				if(exhh>0 || exmm>0){
					if(brCnt>0){workName += "<br/>";}
					brCnt++;
					workName += "<spring:message code='Cache.lbl_att_overtime' />:"+exhh+"h"; //연장
					if(exmm>0){
						workName += exmm+"m";
					}
				}
				//휴일근무시간
				var hohh = Math.floor(obj["AttDayHO_"+i]/60);
				var homm = obj["AttDayHO_"+i]%60;
				if(hohh>0 || homm>0) {
					if(brCnt>0){workName += "<br/>";}
					brCnt++;
					workName += "<spring:message code='Cache.lbl_Holiday' />:" + hohh + "h"; //휴일
					if (homm > 0) {
						workName += homm + "m";
					}
				}
				//주간 합계
				var tohh = Math.floor(obj["AttDayTO_"+i]/60);
				var tomm = obj["AttDayTO_"+i]%60;
				var alertOverTime = false;
				var alertOverCls = "";
				var alertOverSty = "";
				if(tohh>0 || tomm>0) {
					brCnt++;
					workTimeTotal = tohh + "h ";
					workTimeTotal += tomm + "m";
					if(tohh>52){
						alertOverTime=true;
					}else if(tohh==52 && tomm>0){
						alertOverTime=true;
					}
				}
				if(brCnt==0){workClassName="";}
				if(alertOverTime){
					alertOverCls = "WorkBoxW Calling";
					alertOverSty = "margin: 0 0 3px 0;padding: 1px 0;";
				}
				workSts = '<a class="WorkBox '+workClassName+'" style="height: 90px;">';
				workSts +='<span class="tx_title '+alertOverCls+'" style="color: #457d80;font-size: 15px;line-height: 20px;'+alertOverSty+'">'+workTimeTotal+'</span>';
				workSts +='<span class="tx_title" style="text-align: left;line-height: 15px;font-size: 12px;font-weight: normal;">';
				workSts +=workName+'</span>';
				workSts += '</a>'+postWorkSts;
				// make row end.


				var dataMap = {"UserName": obj["UserName"], "UserCode": obj["UserCode"], "JobDate":obj["AttDay_"+viewCol[i]]};
				htmlList+='		<td class="'+className+'" data-map='+JSON.stringify(dataMap)+'>'+ workSts +'</td>';
			}
			htmlList+='	</tr>';
			//합산 시간 표기
			var totTimeHtml = "";
            var brCnt = 0;

			if(toToTime>0){
				var tTohh = Math.floor(toToTime/60);
				var tTomm = toToTime%60;
				if(tTohh>0 || tTomm>0) {
					brCnt++;
					totTimeHtml += '<span class="tx_title" style="color: #457d80;font-size: 15px;">';
					totTimeHtml += tTohh + "h ";
					totTimeHtml += tTomm + "m";
					totTimeHtml += '</span>';
				}
			}

            if(toAcTime>0){
                var tachh = Math.floor(toAcTime/60);
                var tacmm = toAcTime%60;
                if(tachh>0 || tacmm>0) {
					if(brCnt>0){totTimeHtml += "<br/>";}
                    brCnt++;
                    totTimeHtml += "<spring:message code='Cache.lbl_hr_base' />:" + tachh + "h "; //기본
					totTimeHtml += tacmm + "m";
                }
            }
            if(toExTime>0){
                var texhh = Math.floor(toExTime/60);
                var texmm = toExTime%60;
                if(texhh>0 || texmm>0) {
                    if(brCnt>0){totTimeHtml += "<br/>";}
                    brCnt++;
                    totTimeHtml += "<spring:message code='Cache.lbl_att_overtime' />:" + texhh + "h "; //연장
					totTimeHtml += texmm + "m";
                }
            }
            if(toHoTime>0){
                var thohh = Math.floor(toHoTime/60);
                var thomm = toHoTime%60;
                if(thohh>0 || thomm>0) {
                    if(brCnt>0){totTimeHtml += "<br/>";}
                    brCnt++;
                    totTimeHtml += "<spring:message code='Cache.lbl_Holiday' />:" + thohh + "h "; //휴일
					totTimeHtml += thomm + "m";
                }
            }

            htmlList = htmlList.replace("#totalAttenTime#",totTimeHtml);
		});

		if ($("#pageNo").val() == "1")	{
			$("#bodyMonth #bodyTblMonth tbody").html("");
		}


        //내용 넣기
		$("#bodyMonth #bodyTblMonth tbody").append(htmlList);
		if ($("#pageNo").val() == "1"){
			//$("#footerMonth .tfoot tr:eq(0) td:eq(1) p").text(AttendUtils.convertSecToStr(data.avg["ACAvg"],'H'));
			//$("#footerMonth .tfoot tr:eq(1) td:eq(1) p").text(data.avg["JobCnt"]);
			/*for (var i=0;i<viewCol.length; i++){
				$("#footerMonth .tfoot tr:eq(0) td:eq("+(i+2)+") p").text(AttendUtils.convertSecToStr(data.avg["ACAvg_"+viewCol[i]],'H'));
				$("#footerMonth .tfoot tr:eq(1) td:eq("+(i+2)+") p").text(data.avg["ACCount_"+viewCol[i]]);
			}*/
			setTimeout("autoResize('M')", 100);
		}

		showPageing(data.page);
		
	}
	
	//일 주 페이징 출력
	function showPageing(page){
		$("#endPage").val(page.pageCount);
	}

	
	function getVacName(vacCode, vacOff){
		var arrName =		vacName[vacCode];
		if (arrName  == undefined) return vacCode;
		if (vacOff == "AM" || vacOff == "PM"){
			return (vacOff=="PM"?"[<spring:message code='Cache.lbl_PM' />]":"[<spring:message code='Cache.lbl_AM' />]")+arrName["CodeName"]; //오후:오전
		}else {
			return arrName["CodeName"];
		}
	}
/*
	// 엑셀 다운로드 post 요청
	function ajax_download(url, data) {
		var $iframe, iframe_doc, iframe_html;

		if (($iframe = $('#download_iframe')).length === 0) {
			$iframe = $("<iframe id='download_iframe' style='display: none' src='about:blank'></iframe>").appendTo("body");
		}

		iframe_doc = $iframe[0].contentWindow || $iframe[0].contentDocument;
		if (iframe_doc.document) {
			iframe_doc = iframe_doc.document;
		}

		iframe_html = "<html><head></head><body><form method='POST' action='" + url +"'>"
		Object.keys(data).forEach(function(key) {
			iframe_html += "<input type='hidden' name='"+key+"' value='"+data[key]+"'>";
		});
		iframe_html +="</form></body></html>";

		iframe_doc.open();
		iframe_doc.write(iframe_html);
		$(iframe_doc).find('form').submit();
	}*/
</script>
