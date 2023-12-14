<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
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
</style>

<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_n_att_worksch'/><spring:message code='Cache.lbl_Setting'/></h2>
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
		<input type="text" id="searchText"><button type="button" class="btnSearchType01" id="btnSearch"><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
	</div>
</div>
<div class="cRContBottom">
	<div class="ATMCont">
		<div class="ATMTopCont ATMTopCont_l">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv">

				<select class="selectType02" id="deptList">
				</select>
				<select class="selectType02" id="SchSeq">
				</select>
				<a href="#" class="btnTypeDefault btnTypeBg btnAttAdd" id="btnCreate"><spring:message code='Cache.lbl_n_att_worksch' /><spring:message code='Cache.lbl_Creation' /></a> <!-- 근무일정생성 -->
				<a href="#" class="btnTypeDefault" id="btnCopy" style="display:none"><spring:message code='Cache.lbl_Schedule' /><spring:message code='Cache.lbl_Copy' /></a> <!-- 일정복사 -->
				<a href="#" onclick='AttendUtils.openVacationPopup("ADMIN");' class="btnTypeDefault btnIcon2"><spring:message code='Cache.lbl_vacationCreate' /></a>
				<span class="btnLayerWrap">
					<a href="#" class="btnTypeDefault btnDropdown"><spring:message code='Cache.lbl_otherJobCreate' /></a>  <!-- 기타근무 생성 -->
					<div class="btnDropdown_layer" style="display:none;z-index:999999;">
						<ul class="btnDropdown_layer_list" id="jobList"></ul>
					</div>
				</span>
				<a href="#" class="btnTypeDefault" id="btnDelete"><spring:message code='Cache.lbl_n_att_worksch' /><spring:message code='Cache.lbl_delete' /></a> <!-- 근무일정삭제 -->
				<a href="#" class="btnTypeDefault divConfm" id="btnConfm"><spring:message code='Cache.lbl_apv_determine' /></a> <!-- 확정 -->
				<a href="#" class="btnTypeDefault divConfm" id="btnCancel"><spring:message code='Cache.lbl_Apr_ConfirmNo' /></a> <!-- 확정취소 -->
				<a class="btnTypeDefault btnExcel" id="btnExcelDown"><spring:message code="Cache.btn_ExcelDownload"/></a>
				<a class="btnTypeDefault btnExcel" id="btnPrint" style="display:none"><spring:message code="Cache.lbl_Print"/></a>
				<button href="#" class="btnRefresh" type="button" id="btnRefresh"></button>
			</div>
			<div class="ATMbuttonStyleBoxRight">
				<ul id="topButton" class="ATMschSelect">
					<li><a  id="liDay"><spring:message code='Cache.lbl_Daily' /></a></li><!-- 일간 -->
					<li class="selected"><a id="liWeek" ><spring:message code='Cache.lbl_Weekly' /></a></li><!-- 주간 -->
					<li><a id="liMonth"><spring:message code='Cache.lbl_Monthly' /></a></li><!-- 월간 -->
				</ul>
			</div>
		</div>
		<div id="DayCalendar" class="resDayListCont" style="display: none">
			<table class="ATMTable" cellpadding="0" cellspacing="0">
				<thead>
				<tr>
					<th width="30"><label><input type="checkbox" id="checkDayAll"></label></th>
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
				<table class="ATMTable" cellpadding="0" cellspacing="0"  id="bodyTbl">
					<tbody>
					</tbody>
				</table>
			</div>
			<div class="ATMTable_day_tfoot">
				<table class="ATMTable" cellpadding="0" cellspacing="0" id="footerTimeList">
					<tfoot>
					<tr>
						<td width="180"><strong><spring:message code='Cache.lbl_total' /> <spring:message code='Cache.lbl_Hours' /></strong></td> <!-- 총 시간 -->
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
					<col width="30">
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
					<th width="30"><label><input type="checkbox" id="checkWeekAll"></label></th>
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
				<table class="ATMTable" cellpadding="0" cellspacing="0" id="bodyTbl">
					<colgroup>
						<col width="30">
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
						<td width="180"><div class="tfoot_box"><p class="tfoot_title"><spring:message code='Cache.lbl_apv_TimeAverage' /></p></div></td> <!-- 평균시간 -->
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
						<td><div class="tfoot_box"><p class="tfoot_title"><spring:message code='Cache.lbl_TFTotalCount' /></p></div></td> <!-- 총 인원 -->
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
		</div>
		<!-- 총합계  테이블 끝 -->
		<div id="MonthCalendar" class="ATMMgtMonthWrap resDayListCont section-to-print" style="display:none">
			<div class="calMonHeader">
				<table class="calMonTbl"><tbody><tr><th><spring:message code='Cache.lbl_sch_sun' /></th><th><spring:message code='Cache.lbl_sch_mon' /></th><th><spring:message code='Cache.lbl_sch_tue' /></th><th><spring:message code='Cache.lbl_sch_wed' /></th><th><spring:message code='Cache.lbl_sch_thu' /></th><th><spring:message code='Cache.lbl_sch_fri' /></th><th><spring:message code='Cache.lbl_sch_sat' /></th></tr></tbody></table> <!-- 일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th>토 -->
			</div>
			<div class="calMonBody resMonth ui-selectable" style="position:relative;">
				<c:forEach begin="1" end="6">
					<div class="calMonWeekRow" id="divWeekScheduleForMonth" week="0">
						<table class="calGrid FirstLine" cellpadding="0" cellspacing="0">
							<tbody>
							<tr>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
							</tbody>
						</table>
						<table class="calGrid SecondLine" cellpadding="0" cellspacing="0">
							<tbody>
							<tr>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
							</tbody>
						</table>
						<table class="calGrid ThirdLine" cellpadding="0" cellspacing="0">
							<tbody>
							<tr>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>

							</tr>
							</tbody>
						</table>

						<table class="monShcList" cellpadding="0" cellspacing="0">
							<tbody>
							<tr>
								<td><strong></strong></td>
								<td class=""><strong></strong></td>
								<td class=""><strong></strong></td>
								<td class=""><strong></strong></td>
								<td class=""><strong></strong></td>
								<td class=""><strong></strong></td>
								<td><strong></strong></td>
							</tr>
							</tbody>
						</table>
					</div>
				</c:forEach>
			</div>
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

	var weekCol = ["Sun","Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
	var viewCol = new Array(7);

	var strtWeek = parseInt(Common.getBaseConfig("AttBaseWeek"));
	var vacName = [];

	function init(){
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

		AttendUtils.getOtherJobList('Y', 'ADMIN');
		AttendUtils.getDeptList($("#deptList"), Common.getSession("GR_GroupPath"), false, false, true);
		AttendUtils.getScheduleList($("#SchSeq"), '', true);
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
		setPage(1);

		//근무일정생성
		$("#btnCreate").click(function(){
			var popupID		= "AttendJobPopup";
			var openerID	= "AttendJob";
			var popupTit	= "<spring:message code='Cache.MN_887' />";
			var popupYN		= "N";
			var callBack	= "AttendJobPopup_CallBack";
			var popupUrl	= "/groupware/attendJob/AttendJobPopup.do?"
					+ "popupID="		+ popupID	+ "&"
					+ "openerID="		+ openerID	+ "&"
					+ "popupYN="		+ popupYN	+ "&"
					+ "callBackFunc="	+ callBack	;

			//Common.open("", popupID, popupTit, popupUrl, "900px", "850px", "iframe", true, null, null, true);
			CFN_OpenWindow(popupUrl, popupID, "900", "930", "scroll","", "");
		});

		//근무신청
		$(".btnDropdown").on('click',function(){
			var j = $(".btnDropdown_layer").index($(this).next());  // 존재하는 모든 버튼을 기준으로 index
			$(".btnDropdown_layer:not(:eq("+j+"))").hide();
			$(this).next().toggle();
		});

		//일간 클릭
		$('#liDay').click(function(){
			$("#topButton li").removeClass("selected");
			$(this).parent().addClass("selected");
			$(".cRConTop span").hide();
			$(".cRConTop #divDate").show();
			$(".resDayListCont").hide();
			$("#DayCalendar").show();

			$("#mode").val("D");
			setDateTerm($("#mode").val(), $("#StartDate").val());

			$("#btnCopy").show();
			$("#btnDelete").show();
			$("#btnConfm").show();
			$("#btnCancel").show();
			$("#btnExcelDown").show();
			$("#btnPrint").hide();

			setPage(1);
		});

		//주간 클릭
		$('#liWeek').click(function(){
			$("#topButton li").removeClass("selected");
			$(this).parent().addClass("selected");
			$(".cRConTop span").hide();
			$(".cRConTop #divDate").show();
			$(".resDayListCont").hide();
			$("#WeekCalendar").show();

			$("#mode").val("W");
			setDateTerm($("#mode").val(), $("#StartDate").val());

			$("#btnCopy").hide();
			$("#btnDelete").show();
			$("#btnConfm").show();
			$("#btnCancel").show();
			$("#btnExcelDown").show();
			$("#btnPrint").hide();

			setPage(1);
		});

		//월간 클릭
		$('#liMonth').click(function(){
			$("#topButton li").removeClass("selected");
			$(this).parent().addClass("selected");
			$(".cRConTop span").hide();
			$(".cRConTop #divDate").show();
			$(".resDayListCont").hide();
			$("#MonthCalendar").show();

			$("#mode").val("M");
			setDateTerm($("#mode").val(), $("#StartDate").val());

			$("#btnCopy").hide();
			$("#btnDelete").hide();
			$("#btnConfm").hide();
			$("#btnCancel").hide();
			$("#btnExcelDown").hide();
			$("#btnPrint").show();

			setPage(1);
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

		//근무일복사
		$("#btnCopy").click(function(){
			var objId;
			if ($("#mode").val() == "D")
			{
				objId = "bodyTbl";
			}
			else
				objId = "bodyWeek";

			var objCnt = $("#"+objId+" input:checkbox:checked").length ;

			if(objCnt == 0){
				Common.Warning("<spring:message code='Cache.msg_SelItemCopy'/>");
				return;
			}else if (objCnt > 1){
				Common.Warning("<spring:message code='Cache.msg_SelectOnlyOne'/>");
				return;
			}
			else{

				var dataMap = JSON.parse($("#"+objId+" input:checkbox:checked").attr("data-map"));
				if (dataMap["JobDate"] == null || dataMap["JobDate"] === ""){//1개 선택 했으나 일정 미등록 사용자면
					Common.Warning("<spring:message code='Cache.lbl_NoSchedule'/> <spring:message code='Cache.lbl_Schedule' /><spring:message code='Cache.lbl_Copy' /> <spring:message code='Cache.lbl_apv_grform_08' />");
					return;
				}
				var popupID		= "AttendJobCopyPopup";
				var openerID	= "AttendJobCopy";
				var popupTit	= dataMap["UserName"]+' '+dataMap["JobDate"]+" <spring:message code='Cache.ACC_btn_copy' />";
				var popupYN		= "N";
				var callBack	= "AttendJobDetailPopup_CallBack";
				var popupUrl	= "/groupware/attendJob/AttendJobCopyPopup.do?"
						+ "popupID="		+ popupID	+ "&"
						+ "openerID="		+ openerID	+ "&"
						+ "popupYN="		+ popupYN	+ "&"
						+ "UserName="		+ encodeURIComponent(dataMap["UserName"])	+ "&"
						+ "UserCode="		+ dataMap["UserCode"]	+ "&"
						+ "JobDate="		+ dataMap["JobDate"]	+ "&"
						+ "callBackFunc="	+ callBack	;


				Common.open("", popupID, popupTit, popupUrl, "720px", "720px", "iframe", true, null, null, true);
			}
			/*var listobj = grid.getCheckedList(0);
			if(listobj.length == 0){
				Common.Warning("<spring:message code='Cache.msg_SelItemCopy'/>");
				return;
			}else if (listobj.length > 1){
				Common.Warning("<spring:message code='Cache.msg_SelectOnlyOne'/>");
				return;
			}


			var popupID		= "AttendJobCopyPopup";
			var openerID	= "AttendJobCopy";
			var popupTit	= listobj[0].UserName+' '+listobj[0].JobDate+" <spring:message code='Cache.ACC_btn_copy' />";
			var popupYN		= "N";
			var callBack	= "AttendJobDetailPopup_CallBack";
			var popupUrl	= "/groupware/attendJob/AttendJobCopyPopup.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "UserName="		+ listobj[0].UserName	+ "&"
							+ "UserCode="		+ listobj[0].UserCode	+ "&"
							+ "JobDate="		+ listobj[0].JobDate	+ "&"
							+ "callBackFunc="	+ callBack	;


			Common.open("", popupID, popupTit, popupUrl, "600px", "600px", "iframe", true, null, null, true);*/
		});

		//삭제
		$("#btnDelete").click(function(){
			var objId;
			if ($("#mode").val() == "D")
				objId = "bodyTbl";
			else
				objId = "bodyWeek";

			var objCnt = $("#"+objId+" input:checkbox:checked").length ;

			if(objCnt == 0){
				Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
				return;
			}else{
				Common.Confirm("<spring:message code='Cache.msg_RUDelete' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) { deleteList();		}
				})
			}
		});

		//확정
		$("#btnConfm").click(function(){
			var objId;
			if ($("#mode").val() == "D")
				objId = "bodyTbl";
			else
				objId = "bodyWeek";

			var objCnt = $("#"+objId+" input:checkbox:checked").length ;

			if(objCnt == 0){
				Common.Warning("<spring:message code='Cache.CPMail_mail_itemSel'/>");
				return;
			}else{
				Common.Confirm("<spring:message code='Cache.msg_hr_confirm_want' />", "Confirmation Dialog", function (confirmResult) { //확정하시겠습니까?
					if (confirmResult) {			confmList();}
				})
			}
		});

		//확정취소
		$("#btnCancel").click(function(){
			var objId;
			if ($("#mode").val() == "D")
				objId = "bodyTbl";
			else
				objId = "bodyWeek";

			var objCnt = $("#"+objId+" input:checkbox:checked").length ;

			if(objCnt == 0){
				Common.Warning("<spring:message code='Cache.CPMail_mail_itemSel'/>");
				return;
			}else{
				Common.Confirm("<spring:message code='Cache.msg_hr_cancle_want' />", "Confirmation Dialog", function (confirmResult) { //확정취소하시겠습니까?
					if (confirmResult) {			cancelList();}
				})
			}
		});


		$("#checkDayAll").click(function() {
			$("#bodyTbl input:checkbox").each(function() {
				$(this).prop("checked", $("#checkDayAll").prop("checked"));
			});
		});

		$("#checkWeekAll").click(function() {
			$("#bodyWeek input:checkbox").each(function() {
				$(this).prop("checked", $("#checkWeekAll").prop("checked"));
			});
		});

		//엑셀다운
		$("#btnExcelDown").click(function(){
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

		//인쇄
		$("#btnPrint").click(function(){
			window.print();
		});

		/*
			var objId ="";
			switch ($("#mode").val()){
				case "D":
					objId = "DayCalendar";
					break;
				case "W":
					objId = "WeekCalendar";
					break;
				case "M":
					objId = "MonthCalendar";
					break;
			}
			$("#"+objId).table2excel({
			        name: "Table2Excel",
			        filename: "table2excel"
			});

		});*/

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

		//월별 스크롤
		$("#bodyWeek").mCustomScrollbar({
			mouseWheelPixels: 50,scrollInertia: 350,
			callbacks:{
				onScroll:function(){
					myCustomFn("bodyWeek");
				}
			}
		});

	}

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

	$(document).on("click","#jobInfo",function(){
		var dataMap = JSON.parse($(this).attr("data-map"));
		if (dataMap["JobDate"] == null)
		{
			Common.Inform("<spring:message code='Cache.mag_Attendance23' />");	//지정일에 근무가 없습니다.
			return;
		}
		var popupID		= "AttendJobDetailPopup";
		var openerID	= "AttendJobDetail";
		var popupTit	= dataMap["UserName"]+' '+" <spring:message code='Cache.MN_887' />("+dataMap["JobDate"]+")";
		var popupYN		= "N";
		var callBack	= "AttendJobDetailPopup_CallBack";
		var popupUrl	= "/groupware/attendJob/AttendJobDetailPopup.do?"
				+ "popupID="		+ popupID	+ "&"
				+ "openerID="		+ openerID	+ "&"
				+ "popupYN="		+ popupYN	+ "&"
				+ "UserName="		+ encodeURIComponent(dataMap["UserName"])	+ "&"
				+ "UserCode="		+ dataMap["UserCode"]	+ "&"
				+ "JobDate="		+ dataMap["JobDate"]	+ "&"
				+ "callBackFunc="	+ callBack	;

		Common.open("", popupID, popupTit, popupUrl, "650px", "550px", "iframe", true, null, null, true);

	});

	$(document).on("click",".btnDropdown_layer ul li a",function() {
		$(".btnDropdown_layer").hide()
	});

	function autoResize(sType){
		var	w_height = $('#WeekCalendar').height() - 121 + 'px';
		
		if (sType =="W"){
			var bodyDay = $("#bodyWeek .mCSB_container").css("height").replace(/[^0-9]/g, "");
			var scroll = $(".ATMTable_01_scroll").css("height").replace(/[^0-9]/g, "");
			
			if(parseInt(scroll) < parseInt(w_height.replace(/[^0-9]/g, ""))) {
				scroll = w_height.replace(/[^0-9]/g, "");
			}
			
			if (parseInt(bodyDay) < parseInt(scroll)){
				w_height = $("#bodyWeek .mCSB_container").css("height");
			}
			
			$('.ATMTable_01_scroll').css('height',w_height);
		} else {
			var bodyDay = $("#bodyDay .mCSB_container").css("height").replace(/[^0-9]/g, "");
			var scroll = $(".ATMTable_day_scroll").css("height").replace(/[^0-9]/g, "");
			
			if(parseInt(scroll) < parseInt(w_height.replace(/[^0-9]/g, ""))) {
				scroll = w_height.replace(/[^0-9]/g, "");
			}
			
			if (parseInt(bodyDay) < parseInt(scroll)){
				w_height = $("#bodyDay .mCSB_container").css("height");
			}
			
			$('.ATMTable_day_scroll').css('height', w_height);
		}
	}

	function scrollH() {
		//근무일정설정 스크롤 영역높이
		var w_height1 = $('.cRContBottom').height() - 99 + 'px';
		$('#DayCalendar').css('height',w_height1);
		$('#WeekCalendar').css('height',w_height1);
		var w_height2 = $('#WeekCalendar').height() - 121 + 'px';

		$('.ATMTable_01_scroll').css('height',w_height2);
		$('.ATMTable_day_scroll').css('height',w_height2);
		
		if($(".ATMTable_01_scroll").height() > 588) {
			if (parseInt($("#pageNo").val())+1 <= parseInt($("#endPage").val())){
				setPage(parseInt($("#pageNo").val())+1);
			}	
		}
	}


	function setPage (n) {
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
		if ($("#mode").val() == "M"){
			if ($("#deptList").val().match(/;/g).length<4){
				Common.Error("<spring:message code='Cache.lbl_onlyTeam' />");
				return;
			}
		}
		$("#checkWeekAll").prop("checked", false);
		$("#checkDayAll").prop("checked", false);

		var params = {"mode" : $("#mode").val()
			,"StartDate": $("#StartDate").val()
			,"EndDate": $("#EndDate").val()
			,"SchSeq" : $("#SchSeq").val()
			,"searchText": $("#searchText").val()
			,"DeptCode":$("#deptList").val()
			,"pageNo" : $("#pageNo").val()
			,"pageSize": 10 };

		switch ($("#mode").val())
		{
			case "D":
				params["pageSize"]=15;
				$("#dateTitle").text (AttendUtils.maskDate($("#StartDate").val()) );
				break;
			case "W":
				$("#dateTitle").text (AttendUtils.maskDate($("#StartDate").val()) +"~"+ AttendUtils.maskDate($("#EndDate").val()));
				for(var i=0; i < 7; i++){
					var tmp=				schedule_SetDateFormat(schedule_AddDays(sDate, i),"-");

					$("#WeekCalendar #headerWeekList tr:eq(0) th:eq("+(i+3)+")").html(tmp.substring(8,10)+"일&nbsp;("+Common.getDic("lbl_WP"+viewCol[i])+")");
					if (viewCol[i] == "Sun")
						$("#WeekCalendar #headerWeekList tr:eq(0) th:eq("+(i+3)+")").addClass("tx_sun");
					else if	(viewCol[i] == "Sat")
						$("#WeekCalendar #headerWeekList tr:eq(0) th:eq("+(i+3)+")").addClass("tx_sat");

					if (tmp == g_curDate){
						$("#WeekCalendar #headerWeekList tr:eq(0) th:eq("+(i+3)+")").addClass("selected");
					}
					else{
						$("#WeekCalendar #headerWeekList tr:eq(0) th:eq("+(i+3)+")").removeClass("selected");
					}
				}
				break;
			case "M":
				var sunday = schedule_GetSunday(new Date(replaceDate($("#StartDate").val() )));
				sunday = AttendUtils.getWeekStart(new Date(replaceDate(replaceDate($("#StartDate").val()))), strtWeek-1);
				schday = schedule_SetDateFormat(sunday, '.');
				$('#dateTitle').text($("#StartDate").val().substring(0,4) + "." + $("#StartDate").val().substring(5,7));
				//shcToDay
				for (var i = 0; i < 6; i++) {
					for (var j = 0; j < 7; j++) {
						if (schedule_SetDateFormat(schday, '-') < $("#StartDate").val() ||
								schedule_SetDateFormat(schday, '-') > $("#EndDate").val())
							$(".monShcList:eq("+i+") tr:eq(0) td:eq("+j+")").addClass("disable");
						else
							$(".monShcList:eq("+i+") tr:eq(0) td:eq("+j+")").removeClass("disable");

						if (schedule_SetDateFormat(schday, '-') ==g_curDate) 	$(".monShcList:eq("+i+") tr:eq(0) td:eq("+j+")").addClass("shcToDay");
						else 	$(".monShcList:eq("+i+") tr:eq(0) td:eq("+j+")").removeClass("shcToDay");

						$(".monShcList:eq("+i+") tr:eq(0) td:eq("+j+")").removeClass("holiday");
						$(".monShcList:eq("+i+") tr:eq(0) td:eq("+j+") strong").html(schedule_SetDateFormat(schday, '-').substring(8));
						$(".monShcList:eq("+i+") tr:eq(0) td:eq("+j+")").attr("schday", schedule_SetDateFormat(schday, '-'));
						$(".monShcList:eq("+i+") tr:eq(0) td:eq("+j+")").attr("id", "td_"+schedule_SetDateFormat(schday, '-').replace(/-/g,""));
						$(".monShcList:eq("+i+") tr:eq(0) td:eq("+j+")").attr("rowIdx", i);
						$(".monShcList:eq("+i+") tr:eq(0) td:eq("+j+")").attr("colIdx", j);

						for (var k =0; k <$(".calMonWeekRow:eq("+i+") .calGrid").length; k++)
						{
							$(".calMonWeekRow:eq("+i+") .calGrid:eq("+k+") tr:eq(0) td:eq("+j+")").text("");
						}
						schday = schedule_AddDays(schday, 1);
					}
				}
				break;
		}

		$.ajax({
			type:"POST",
			data:params,
			url:"/groupware/attendJob/getAttendJob.do",
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
				"<span  data-map='"+JSON.stringify(dataMap)+"' id='jobInfo' class='tx_title' title='"+vacInfo+"'>"+vacInfo+"</span>"+
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
				"<span  data-map='"+JSON.stringify(dataMap)+"' id='jobInfo' class='tx_title'>"+workName+
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
		
		if(data.list.length > 0) {
			$.each(data.list, function(idx, obj){
				var lbl_ProfilePhoto = "<spring:message code='Cache.lbl_ProfilePhoto' />"; //프로필사진
				var reasonText = "";
				var reqMap = {"UserName": obj["UserName"], "UserCode": obj["UserCode"], "JobDate":obj["JobDate"], "StartDate":$("#StartDate").val(), "EndDate":$("#EndDate").val()};
				htmlList +='<tr>'+
						'<td width="30"><input type="checkbox" value="'+obj.UserCode+'" data-map=\''+JSON.stringify(reqMap)+'\' ></td>'+
						'<td width="150">'+
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
					if (obj["VacFlag"] != null && Number(vacFlag[2])>=1){
						htmlList+= "<td colspan="+lastIdx+" style='text-align:center'><a class='WorkBox Vacation TaC"+(obj["ConfmYn"] == "Y"?" Bg":"")+"'>";
						// 2021.07.21 nkpark 공동연차 등록시, 공동연차사유 값이 있으면 연차(사유) 표기처리
						if(vacFlag[1].indexOf('{')>-1&&vacFlag[1].indexOf('}')>-1){
							reasonText = vacFlag[1].substring(vacFlag[1].indexOf('{')+1,vacFlag[1].indexOf('}')-1);
							htmlList+= getVacName(vacFlag[0] ,vacFlag[1])+"("+reasonText+")";
						}else{
							htmlList+= getVacName(vacFlag[0] ,vacFlag[1]);
						}
						
						htmlList+= "</a></td>";
					}
					else{
						var startTime = obj["AttDayStartTime"];
						var endTime = obj["AttDayEndTime"];
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
		} else {
			htmlList +='<tr style="height: 55px;"><td colspan="4">'+Common.getDic("msg_nothingToDetail")+'</td></tr>';
		}		

		if ($("#pageNo").val() == "1") $("#bodyDay #bodyTbl").html("");

		$("#bodyDay #bodyTbl").append(htmlList);
		if ($("#pageNo").val() == "1"){
			$("#DayCalendar #footerTimeList .td_time").text(AttendUtils.convertSecToStr(data.avg.ACAvg,'H'));
			for (var i=0;i<24; i++){
				$("#footerTimeList .ATMTable_day tr:eq(0) td:eq("+i+")").text(data.avg["Day_"+AttendUtils.paddingStr(i,"L","0",2)]);
			}
			setTimeout("autoResize('D')", 100);
		}

	}

	//주간보기
	function showScheduleJobWeek(data){
		var htmlList = "";

		if(data.list.length > 0) {
			$.each(data.list, function(idx, obj){
				var lbl_ProfilePhoto = "<spring:message code='Cache.lbl_ProfilePhoto' />"; //프로필사진
				var reqMap = {"UserName": obj["UserName"], "UserCode": obj["UserCode"], "JobDate":obj["JobDate"], "StartDate":$("#StartDate").val(), "EndDate":$("#EndDate").val()};
				htmlList+='<tr><td><label>'+
						'<input type="checkbox" value="'+obj.UserCode+'" data-map=\''+JSON.stringify(reqMap)+'\' ></td>'+
						'<td><div class="ATMT_user_wrap">'+
						'		<div class="ATMT_user_img">'+
						((obj["PhotoPath"]!= null && obj["PhotoPath"]!= "")?'<img src="'+coviCmn.loadImage(obj["PhotoPath"])+'" alt="'+lbl_ProfilePhoto+'" class="mCS_img_loaded" onerror="coviCmn.imgError(this, true)">':'<p class=\"bgColor'+Math.floor(idx%5+1)+'\"><strong>'+obj.UserName.substring(0,1)+'</strong></p>')+
						'	</div>'+
						'<div class="ATMT_name btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="cursor:pointer" data-user-code="'+ obj.UserCode +'" data-user-mail="">'+obj.UserName+' '+AttendUtils.userRepJobType(obj)+'</div>'+
						'<p class="ATMT_team">'+obj.DeptName+'</p>'+
						'</div></td>'+
						'<td><p class="td_time">'+AttendUtils.convertSecToStr(obj["AttDayAC"],'H')+'</p></td>';

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
							var ampmCnt = 0.0;
							if (obj["VacFlag_"+viewCol[i]] != null && obj["VacFlag_"+viewCol[i]] != '') {
								workClassName ="Vacation";
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
										ampmCnt += 0.5;
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
										ampmCnt += 0.5;
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
									if(ampmCnt===0.5){
										workClassName ="Half Normal";
										half=true;
									}else if(vacFlag[1]==="0" && Number(vacFlag[2])===1){
										workClassName ="Vacation";
										workName = getVacName(vacFlag[0] ,vacFlag[1]);
									}
								}
								else{
									workClassName ="Vacation";
									workName = getVacName(vacFlag[0] ,vacFlag[1]);
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
							
							if(ampmCnt<1) {
								workSts += '<a class="WorkBox ' + workClassName + '">';
								workSts += '<span class="tx_title" ';
								
								if (reasonText.length > 0) {
									workSts += 'style="margin-top: -10px;"';
								}
								
								workSts += '>' + workName + '</span>';
								
								if (!half && workClassName != "Vacation") {
									workSts += '<span class="tx_time">' + AttendUtils.formatTime(obj["AttDayStartTime_" + viewCol[i]], 'AP') + '</span>' +
											'<span class="tx_time">' + AttendUtils.formatTime(obj["AttDayEndTime_" + viewCol[i]], "AP") + '</span>';
								}
								
								workSts += '</a>';
							}
							workSts += postWorkSts;
						}
					}

					var dataMap = {"UserName": obj["UserName"], "UserCode": obj["UserCode"], "JobDate":obj["AttDay_"+viewCol[i]]};
					htmlList+='		<td class="'+className+'" data-map='+JSON.stringify(dataMap)+' id="jobInfo">'+ workSts +'</td>';
				}
				htmlList+='	</tr>';
			});
		} else {
			htmlList +='<tr style="height: 76px;"><td colspan="10">'+Common.getDic("msg_nothingToDetail")+'</td></tr>';
		}

		if ($("#pageNo").val() == "1")	{
			$("#bodyWeek #bodyTbl tbody").html("");
		}

		$("#bodyWeek #bodyTbl tbody").append(htmlList);
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
		var schdate = "";
		var index =0;
		var cnt =0
		var dataIdx=0;

		var findId = "";
		var rowIdx = "";
		var colIdx = "";
		for (var i=0; i< data.list.length; i++){
			var obj = data.list[i];
			cnt++;
			if (schdate != obj.JobDate || dataIdx>=2 )
			{
				if (schdate == obj.JobDate){
					var sHtml ="";

					for (var j=i-1; j< data.list.length; j++)
					{
						obj = data.list[j];
						var dataMap = {"UserName": obj["UserName"], "UserCode": obj["UserCode"], "JobDate":obj["JobDate"], "DiffKey":obj["UserCode"]+":"+obj["VacFlag"]+":"+obj["AttDayStartTime"]+":"+obj["AttDayEndTime"]};
						sHtml+="<li><a data-map='"+JSON.stringify(dataMap)+"' id='jobInfo'>";

						if (obj["VacFlag"] != null){
							vacFlag = obj["VacFlag"].split(":");
							sHtml +="<span class='tx_title'>"+getVacName(vacFlag[0], vacFlag[1])+"<span class='tx_name'>("+obj.UserName+")</span></span>";
						}
						else{
							sHtml  += "<span class='tx_title'>"+(obj["SchName"]==null?'':obj["SchName"])+"<span class='tx_name'>("+obj.UserName+")</span><span class='tx_time'>"+obj.AttDayStartTime+"~"+obj.AttDayEndTime+"</span></span>";
						}
						sHtml+="</a></li>";

						if (schdate != obj.JobDate) {
							var objId = "divRepeat_"+rowIdx+"_"+colIdx;

							$(".calMonWeekRow:eq("+rowIdx+") .calGrid:eq(2) tr:eq(0) td:eq("+colIdx+")").html(""+
									"<a class='WorkBook' onclick=\"$('.ATMgt_Work_Popup').hide();$('#"+objId+"').show()\">+"+(j-i)+"</a>"+
									"<div class='ATMgt_Work_Popup ' id='"+objId+"' style='position:relative; right:15px; width:320px; z-index:105;display:none'>"+
									"<a onclick=\"$('#"+objId+"').hide()\" class='Btn_Popup_close'></a>"+
									"<ul class='ATMgt_list_Cont mScrollV  scrollVType01'>"+sHtml+"</ul>"+
									"</div>"+
									"");
							i=j;
							break;
						}
					}
				}

				schdate = obj.JobDate;
				findId = "td_"+schdate.replace(/-/g,"");
				rowIdx = $("#"+findId).attr("rowIdx");
				colIdx = $("#"+findId).attr("colIdx");
				dataIdx = -1;
			}
			dataIdx++;
			if (dataIdx<2){
				var dataMap = {"UserName": obj["UserName"], "UserCode": obj["UserCode"], "JobDate":obj["JobDate"], "DiffKey":obj["UserCode"]+":"+obj["VacFlag"]+":"+obj["AttDayStartTime"]+":"+obj["AttDayEndTime"]};
				var className ;
				var sMidHtml;
				if (obj["VacFlag"] != null){
					vacFlag = obj["VacFlag"].split(":");
					className = "WorkBox schDayText Vacation";
					sMidHtml ="<span class='tx_title'>"+getVacName(vacFlag[0], vacFlag[1])+"<span class='tx_name'>("+obj.UserName+")</span></span>";
				}
				else if (obj["WorkSts"] == "OFF" || obj["WorkSts"] == "HOL"){
					className = "WorkBox schDayText Vacation";
					sMidHtml  = "<span class='tx_title'>휴무<span class='tx_name'>("+obj.UserName+")</span></span>";
				}
				else{
					className = "WorkBox schDayText Normal";
					sMidHtml  = "<span class='tx_title'>"+(obj["SchName"]==null?'':obj["SchName"])+"<span class='tx_name'>("+obj.UserName+")</span><span class='tx_time'>"+obj.AttDayStartTime+"~"+obj.AttDayEndTime+"</span></span>";
				}

				var sHtml = "<a class='"+ className+"'>"+
						"<div data-map='"+JSON.stringify(dataMap)+"' id='jobInfo'>"+
						sMidHtml + "</div></a>";

				$(".calMonWeekRow:eq("+rowIdx+") .calGrid:eq("+dataIdx+") tr:eq(0) td:eq("+colIdx+")").html(sHtml);
			}
		}

		/*if (dataIdx>=2){
			$(".calMonWeekRow:eq("+rowIdx+") .calGrid:eq(2) tr:eq(0) td:eq("+colIdx+")").html(''+
					'<a >+'+(dataIdx-2)+'</a>'+
					'');
		}*/
		var width = $(".schDayText:eq(0)").outerWidth();
		var widthM = $(".schDayText:eq(0)").outerWidth(true)-width;
		for (var i = 0; i < 6; i++) {
			var bfDiffKey = "";
			var orgObj = "";
			var iSize = 1;
			for (var k =0; k <2; k++){
				bfDiffKey = "";
				orgObj = "";
				iSize = 1;
				var j=0;
				var dataMap = "";
				for (j = 0; j < 7; j++) {
					var dataStr = $(".calMonWeekRow:eq("+i+") .calGrid:eq("+k+") tr:eq(0) td:eq("+j+") .schDayText div").attr("data-map");
					if (dataStr == undefined || dataStr == "") {
						if (orgObj != "") orgObj.attr("colSize", iSize);
						iSize =1;
						bfDiffKey = "";
						orgObj ="";
					}
					else{
						dataMap = JSON.parse(dataStr);
						if (bfDiffKey == dataMap["DiffKey"])
						{
							$(".calMonWeekRow:eq("+i+") .calGrid:eq("+k+") tr:eq(0) td:eq("+j+") .schDayText").remove();
							iSize++;
						}
						else{
							if (orgObj != "") orgObj.attr("colSize", iSize);
							iSize =1;
							bfDiffKey = dataMap["DiffKey"];
							orgObj =$(".calMonWeekRow:eq("+i+") .calGrid:eq("+k+") tr:eq(0)  td:eq("+j+")").children(".schDayText");
						}
					}
				}
				if (bfDiffKey == dataMap["DiffKey"]){
					$(".calMonWeekRow:eq("+i+") .calGrid:eq("+k+") tr:eq(0)   td:eq("+j+") .schDayText").remove();
					iSize++;
				}
				iSize--;
				if (orgObj != "") orgObj.attr("colSize", iSize);
			}
		}

		$(".calMonWeekRow .schDayText").each(function(idx, obj){
			if ($(obj).attr("colsize")>1) {
				$(obj).css({ 'width': 'calc('+($(obj).attr("colsize")*100)+'% - 10px)' });
//				$(obj).width((width-widthM)*$(obj).attr("colsize")+((widthM*2)*($(obj).attr("colsize")-2))+widthM);
			}
		});

		//회사 휴무일
		$.each(data.holiList, function(idx, obj){
			$(".monShcList td[schday|='"+obj["dayList"]+"']").addClass("holiday");
			$(".monShcList td[schday|='"+obj["dayList"]+"'] strong").append("&nbsp;"+obj["HolidayName"]);
		});

	}

	//일 주 페이징 출력
	function showPageing(page){
		$("#endPage").val(page.pageCount);
	}

	//삭제하기
	function deleteList(){
		var aJsonArray = new Array();
		if ($("#mode").val() == "D")
			objId = "bodyTbl";
		else
			objId = "bodyWeek";

		$("#"+objId+" input:checkbox:checked").each(function() {
			var dataMap = JSON.parse($(this).attr("data-map"));

			var saveData = { "StartDate":dataMap["StartDate"], "EndDate":dataMap["EndDate"], "UserCode":dataMap["UserCode"]};
			aJsonArray.push(saveData);
		});

		$.ajax({
			type:"POST",
			contentType:'application/json; charset=utf-8',
			dataType   : 'json',
			data:JSON.stringify({"dataList" : aJsonArray  }),
			url:"/groupware/attendJob/delAttendJob.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_Deleted'/>");	//저장되었습니다.
					searchData();
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

	//확정하기
	function confmList(){
		var aJsonArray = new Array();
		if ($("#mode").val() == "D")
			objId = "bodyTbl";
		else
			objId = "bodyWeek";

		$("#"+objId+" input:checkbox:checked").each(function() {
			var dataMap = JSON.parse($(this).attr("data-map"));

			var saveData = { "StartDate":dataMap["StartDate"], "EndDate":dataMap["EndDate"], "UserCode":dataMap["UserCode"]};
			aJsonArray.push(saveData);
		});

		$.ajax({
			type:"POST",
			contentType:'application/json; charset=utf-8',
			dataType   : 'json',
			data:JSON.stringify({"dataList" : aJsonArray  }),
			url:"/groupware/attendJob/confirmAttendJob.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.lbl_Apr_ConfirmYes'/>");	//저장되었습니다.
					searchData();
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

	//확정취소하기
	function cancelList(){
		var aJsonArray = new Array();
		if ($("#mode").val() == "D")
			objId = "bodyTbl";
		else
			objId = "bodyWeek";

		$("#"+objId+" input:checkbox:checked").each(function() {
			var dataMap = JSON.parse($(this).attr("data-map"));

			var saveData = { "StartDate":dataMap["StartDate"], "EndDate":dataMap["EndDate"], "UserCode":dataMap["UserCode"]};
			aJsonArray.push(saveData);
		});

		$.ajax({
			type:"POST",
			contentType:'application/json; charset=utf-8',
			dataType   : 'json',
			data:JSON.stringify({"dataList" : aJsonArray  }),
			url:"/groupware/attendJob/confirmCancelAttendJob.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.lbl_Apr_ConfirmNo'/>");	//저장되었습니다.
					searchData();
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

	function getVacName(vacCode, vacOff){
		var arrName =		vacName[vacCode];
		if (arrName  == undefined) return vacCode;
		if (vacOff == "AM" || vacOff == "PM"){
			return (vacOff=="PM"?"[<spring:message code='Cache.lbl_PM' />]":"[<spring:message code='Cache.lbl_AM' />]")+arrName["CodeName"]; //오후:오전
		}else {
			return arrName["CodeName"];
		}
	}
	
	var attendAttendJob = function(){
		this.initContent = function(linkUrl) {
			init();
		}
	}
	$(document).ready(function(){
		var me = new attendAttendJob();
		me.initContent();
	});

	
</script>
