<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%
	String userNowDate = ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
%>
<style>
.planTitle {
    display: inline-block;
    font-size: 24px;
    font-weight: 700;
    font-family: sans-serif, 'Nanum Gothic','맑은 고딕', 'Malgun Gothic';
    line-height: 57px;
    vertical-align: middle;
    margin-top: 50px;
}
</style>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_HolidayWorkPlan'/> <span class="target-date"></span></h2> <!-- 휴무일 근무계획 -->
	<div class="pagingType02">
		<a href="#" class="pre dayChg" data-paging="-"></a>
		<a href="#" class="next dayChg" data-paging="+"></a>
		<a href="#" class="btnTypeDefault calendartoday"><spring:message code='Cache.CPMail_ThisMonth'/></a>
		<a href="#" class="calendarcontrol btnTypeDefault cal"></a>
		<input type="text" id="inputCalendarcontrol" style="height: 0px; width:0px; border: 0px;" >
	</div> 
	<div class="searchBox02"> 
		<span><input type="text" id="sUserTxt"><button type="button" id="searchBtn" class="btnSearchType01"><spring:message code='Cache.lbl_search'/></button></span>
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<!-- 컨텐츠 시작 -->
	<div class="ATMCont">
		<div class="ATMFilter_Info_wrap" style="border-top: none; padding: 0px;">
			<div class="ATMFilter">
				<p class="ATMFilter_title"><spring:message code='Cache.lbl_att_select_department'/></p>
				<select class="size112" id="groupPath"></select>
				<select class="size72" id="jobGubun">
					<option value=""><spring:message code='Cache.lbl_Whole'/></option> 
					<option value="1_JobTitle"><spring:message code='Cache.lbl_JobTitle'/></option> 
					<option value="1_JobLevel"><spring:message code='Cache.lbl_JobLevel'/></option> 
				</select>
				<select class="size72" id="jobCode">
					<option value=""><spring:message code='Cache.lbl_Whole'/></option>
				</select>	
			</div>			
		</div>
		<div class="tblList"></div>
		
		<h2 class="planTitle"><spring:message code='Cache.lbl_MonthlyHolidayPlan'/></h2> <!-- 월 휴무계획 집계 -->
		<div class="tblList2"></div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>

<!-- 휴무일 근무계획 Temp 테이블 시작 -->
<table id="attClosedDayTemp" class="ATMTable" cellpadding="0" cellspacing="0" style="display:none;">
	<thead>
		<tr> 	
			<th width="100">일자</th>
		</tr>
	</thead>
</table>

<table id="attClosedDayTempTable" class="ATMTable top_line" cellpadding="0" cellspacing="0" style="display:none;">
	<tbody>
		<tr id="attClosedDayTempTd" style="height: 35px;">
			<td width="100" style="border-left: 0px !important; font: bold;"><spring:message code='Cache.lbl_name' /></td>
			<td class="ClosedDay_0" style="background: none; padding: 15px;"></td>		
			<td class="ClosedDay_1" style="background: none; padding: 15px;"></td>		
			<td class="ClosedDay_2" style="background: none; padding: 15px;"></td>		
			<td class="ClosedDay_3" style="background: none; padding: 15px;"></td>		
			<td class="ClosedDay_4" style="background: none; padding: 15px;"></td>
			<td class="ClosedDay_5" style="background: none; padding: 15px;"></td>		
			<td class="ClosedDay_6" style="background: none; padding: 15px;"></td>		
			<td class="ClosedDay_7" style="background: none; padding: 15px;"></td>		
			<td class="ClosedDay_8" style="background: none; padding: 15px;"></td>		
			<td class="ClosedDay_9" style="background: none; padding: 15px;"></td>
			<td class="ClosedDay_10" style="background: none; padding: 15px;"></td>
			<td class="ClosedDay_11" style="background: none; padding: 15px;"></td>
			<td class="ClosedDay_12" style="background: none; padding: 15px;"></td>
			<td class="ClosedDay_13" style="background: none; padding: 15px;"></td>
			<td class="ClosedDay_14" style="background: none; padding: 15px;"></td>
		</tr>
	</tbody>
</table>	

<table id="attClosedDayEmptyTempTable" class="ATMTable top_line" cellpadding="0" cellspacing="0" style="display:none;">
	<tbody>
		<tr>
			<td style="height: 35px;"><spring:message code='Cache.mag_NoPlanWorkHoliday' /></td> <!-- 휴무일 근무계획이 없습니다. -->
		</tr>
	</tbody>
</table>	
<!-- 휴무일 근무계획 Temp 테이블 끝 -->

<!-- 월 휴무계획 집계 Temp 테이블 시작 -->
<table id="attClosedDayPlanStsTemp" class="ATMTable" cellpadding="0" cellspacing="0" style="display:none;">
	<thead>
		<tr> 	
			<th width="200"><spring:message code='Cache.lbl_DeptName' /></th>
			<th width="150"><spring:message code='Cache.lbl_JobTitle' /></th>
			<th width="150"><spring:message code='Cache.lbl_JobLevel' /></th>
			<th width="150"><spring:message code='Cache.lbl_name' /></th>
			<th><spring:message code='Cache.lbl_NumberDay' /></th> <!-- 월 일수 -->
			<th><spring:message code='Cache.ACC_lbl_workingDay' /></th>
			<th><spring:message code='Cache.lbl_Saturday' /></th>
			<th><spring:message code='Cache.lbl_Sunday' /></th>
			<th><spring:message code='Cache.lbl_EtcHoliday' /></th> <!-- 기타 휴일 -->
			<th><spring:message code='Cache.lbl_apv_Section' /></th> <!-- 계 -->
			<th><spring:message code='Cache.lbl_Remark' /></th>
		</tr>
	</thead>
</table>

<table id="attClosedDayPlanStsTempTable" class="ATMTable top_line" cellpadding="0" cellspacing="0" style="display:none;">
	<tbody>
		<tr id="attClosedDayPlanStsTempTd" style="height: 35px;">
			<td class="DeptName" width="200" style="border-left: 0px !important;"></td>
			<td class="JobLevelName" width="150"></td>
			<td class="JobTitleName" width="150"></td>
			<td class="URName" width="150"></td>
			<td class="MonthDayCnt"></td>
			<td class="AttendDayCnt"></td>			
			<td class="SaturdayCnt"></td>
			<td class="SundayCnt"></td>
			<td class="EtcHolidayCnt"></td>
			<td class="ClosedDayCnt"></td>
			<td class="Etc"></td>
		</tr>
	</tbody>
</table>

<table id="attClosedDayPlanStsEmptyTempTable" class="ATMTable top_line" cellpadding="0" cellspacing="0" style="display:none;">
	<tbody>
		<tr>
			<td style="height: 35px;"><spring:message code='Cache.mag_NoMonthHolidayPlan' /></td> <!-- 월 휴무계획 집계가 없습니다. -->
		</tr>
	</tbody>
</table>	
<!-- 월 휴무계획 집계 Temp 테이블 끝 -->

<script type="text/javascript">
var _targetDate = "<%=userNowDate%>";
var _stDate;
var _edDate;
var _page = 1 ;
var _pageSize = 10 ;

$(document).ready(function(){
	init();
	reLoadList();
});

function init(){
	// 날짜 설정
	setDate();
	
	$(".target-date").html(_stDate + "~" + _edDate);
	
	//부서 선택
	AttendUtils.getDeptList($("#groupPath"),'', false, false, true);
	$("#groupPath").on('change',function(){
		reLoadList();
	});
	
	//날짜 Paging
	$(".dayChg").on('click',function(){
		dayChg($(this).data("paging"));
		reLoadList();
	});
	
	//사용자명 검색
	$("#sUserTxt").on('keypress', function(e){ 
		if (e.which == 13) {
			reLoadList();
	    }
	});
	
	$("#searchBtn").on('click',function(){
		reLoadList();
	});
	
	//달력 검색
	setTodaySearch();
	
	//직급 직책 리스트 조회
	$("#jobGubun").on('change',function(){
		AttendUtils.getJobList($(this).val(),'jobCode');
		if($(this).val()==''){
			reLoadList();			
		}
	});
	
	$("#jobCode").on('change',function(){
		reLoadList();
	});
}

// 날짜 조회조건 세팅
function setDate() {
	var tDate = new Date(_targetDate);
	var stDate = new Date(tDate.getFullYear(), tDate.getMonth(), 1);
	var edDate = new Date(tDate.getFullYear(), tDate.getMonth() + 1, 0);
	_stDate = stDate.format('yyyy-MM-dd')
	_edDate = edDate.format('yyyy-MM-dd')
	
	$(".target-date").html(_stDate + "~" + _edDate);
}

function searchList(d){
	_targetDate = d;
	
	setDate();
	clearGetAttList();
}

function dayChg(t){
	var tDate = new Date(_targetDate);
	
	if("+" == t) {
		tDate = addMonth(tDate, 1);
		_targetDate = tDate.format('yyyy-MM-dd');
		_stDate = new Date(tDate.getFullYear(), tDate.getMonth(), 1).format('yyyy-MM-dd')
		_edDate = new Date(tDate.getFullYear(), tDate.getMonth() + 1, 0).format('yyyy-MM-dd')
	} else if("-" == t) {
		tDate = addMonth(tDate, -1);		
		_targetDate = tDate.format('yyyy-MM-dd');
		_stDate = new Date(tDate.getFullYear(), tDate.getMonth(), 1).format('yyyy-MM-dd')
		_edDate = new Date(tDate.getFullYear(), tDate.getMonth() + 1, 0).format('yyyy-MM-dd')
	}
	
	$(".target-date").html(_stDate + "~" + _edDate);
}

function addMonth(date, month) {
	// month달 후의 1일
	var addMonthFirstDate = new Date(date.getFullYear(), date.getMonth() + month, 1);

	// month달 후의 말일
	var addMonthLastDate = new Date(addMonthFirstDate.getFullYear(), addMonthFirstDate.getMonth() + 1, 0);

	var result = addMonthFirstDate;
	if (date.getDate() > addMonthLastDate.getDate()) {
		result.setDate(addMonthLastDate.getDate());
	} else {
		result.setDate(date.getDate());
	}

	return result;
}

function clearGetAttList(){
	$(".target-date").html(_stDate + "~" + _edDate);	
	$(".tblList").html("");
	setTempHtml();
}

function reLoadList(){
	_page = 1; 
	clearGetAttList();
}

function refreshList(){
	_targetDate = "<%=userNowDate%>";
	setDate();
	reLoadList();
}

function setTempHtml(){
	var tempHtml = $("#attClosedDayTemp").clone();
	tempHtml.removeAttr("style","display:none;")
	tempHtml.attr("id", "Header");
	
	$(".tblList").html(tempHtml);
	$(".tblList").append("<div class='ATMTable_02_scroll' id='attTable'></div>");
	
	var tempHtml2 = $("#attClosedDayPlanStsTemp").clone();
	tempHtml2.removeAttr("style","display:none;")
	tempHtml2.attr("id", "Header");
	
	$(".tblList2").html(tempHtml2);
	$(".tblList2").append("<div class='ATMTable_02_scroll' id='attTable2'></div>");	
	
	getAttList();
}

//해더 세팅
function setHeader(att) {
	for(var i = 0; i < att.length; i++) {
		if(att[i].HolidayYn == "Y") {
			var html = "<th><font color='red'>" + setHeaderName(att[i].Header) + "</font></th>";
			$("#Header").find("tr").append(html);	
		} else {
			var html = "<th>" + setHeaderName(att[i].Header) + "</th>";
			$("#Header").find("tr").append(html);	
		}
	}
}

function setHeaderName(headerDate) {
	var d = new Date(headerDate);
	var week = new Array('<spring:message code="Cache.lbl_sch_sun" />', '<spring:message code="Cache.lbl_sch_mon" />', 
			'<spring:message code="Cache.lbl_sch_tue" />', '<spring:message code="Cache.lbl_sch_wed" />', 
			'<spring:message code="Cache.lbl_sch_thr" />', '<spring:message code="Cache.lbl_sch_fri" />',
			'<spring:message code="Cache.lbl_sch_sat" />');
	return d.format('MM.dd') + " (" + week[d.getDay()] + ")";
}

// 데이터 세팅
function setClosedDayHtml(att){
	var dataList = att.data;
	var headList = att.header;
	
	var tempTable = $("#attClosedDayTempTable").clone();
	tempTable = tempTable.removeAttr("style","display:none;");
	tempTable = tempTable.removeAttr("id");
	
	$("#attTable").append(tempTable);
	
	for(var i = 0; i < dataList.length; i++) {		
		var tempTd = $("#attClosedDayTempTd").clone();
		tempTd = tempTd.removeAttr("id");		
		
		for(var j = headList.length ; j < 15; j++) {
			tempTd.find(".ClosedDay_" + j).remove();	
		}
		
		if(i == 0) tempTable.find("tbody").empty();
		
		for(key in dataList[i]) {
			tempTd.find("td." + key).html(dataList[i][key]);
		}
		
		$("#attTable").find("tbody").append(tempTd);
	}
}

function setClosedDayStsHtml(att){
	var dataList = att.dataSts;
	var tempTable = $("#attClosedDayPlanStsTempTable").clone();
	tempTable = tempTable.removeAttr("style","display:none;");
	tempTable = tempTable.removeAttr("id");
	
	$("#attTable2").append(tempTable);
	
	for(var i = 0; i < dataList.length; i++) {		
		var tempTd = $("#attClosedDayPlanStsTempTd").clone();
		tempTd = tempTd.removeAttr("id");		
		
		if(i == 0) tempTable.find("tbody").empty();
		
		for(key in dataList[i]) {
			tempTd.find("td." + key).html(dataList[i][key]);
		}
		
		$("#attTable2").find("tbody").append(tempTd);
	}
}

function getAttList(){
	var params = {
		 stDate : _stDate
		,edDate : _edDate
		,groupPath : $("#groupPath").val()
		,sUserTxt : $("#sUserTxt").val()
		,sJobTitleCode : $("#jobGubun").val()=="1_JobTitle"?$("#jobCode").val():null
		,sJobLevelCode : $("#jobGubun").val()=="1_JobLevel"?$("#jobCode").val():null
		,pageSize : _pageSize
		,pageNo : _page
	}
	
	$.ajax({
		type:"POST",
		dataType : "json",
		data: params,
		url:"/groupware/attendClosedDaySts/getClosedDayPlan.do",
		success:function (data) {
			if(data.status =="SUCCESS"){
				$(".mScrollVH").off();
				
				setHeader(data.header);
				
				if(data.loadCnt > 0){				
					setClosedDayHtml(data);
					/*
					$(".mScrollVH").scroll(function(){
				        var scrollTop = $(this).scrollTop();
				        var innerHeight = $(this).innerHeight();
				        var scrollHeight = $(this).prop('scrollHeight');

				        if (scrollTop + innerHeight >= scrollHeight) {
			        		_page++;
			        		getAttList();
				        }
					});					
					*/
				} else {
					var tempTable = $("#attClosedDayEmptyTempTable").clone();
					tempTable = tempTable.removeAttr("style","display:none;");
					tempTable = tempTable.removeAttr("id");
					$("#attTable").append(tempTable);
				}
				
				if(data.loadStsCnt > 0){				
					setClosedDayStsHtml(data);
				} else {
					var tempTable = $("#attClosedDayPlanStsEmptyTempTable").clone();
					tempTable = tempTable.removeAttr("style","display:none;");
					tempTable = tempTable.removeAttr("id");
					$("#attTable2").append(tempTable);
				}
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
			}
		}
	});
}
</script>