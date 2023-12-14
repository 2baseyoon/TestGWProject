<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%
	String userNowDate = ComUtils.GetLocalCurrentDate("yyyy-MM-dd"); 
%>
<style>
.ur-item {
	margin: 3px 3px 0 0;
    padding: 2px 4px;
    font-size: 13px;
    width: 250px;
    height: 25px;
    line-height: 20px;
    white-space: nowrap;
    display: inline-block;
    color: #333;
}
.ATMTable thead tr:last-child th { border-bottom: 1px solid #969696; } 
.ATMTable tbody tr td { line-height: 20px; }
.ATMTable tbody tr td:last-child { text-align: left; padding: 10px; }
</style>

<script type="text/javascript" src="/groupware/resources/script/moment.min.js"></script>

<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.CPMail_Daily'/><spring:message code='Cache.lbl_att_attendance_sts'/><span class="target-date"></span></h2>  <!-- 일별근태현황 -->
	<div class="pagingType02">
		<a href="#" class="pre dayChg" data-paging="-"></a>
		<a href="#" class="next dayChg" data-paging="+"></a>
		<a href="#" class="btnTypeDefault calendartoday" onclick="javascript:dayToday();"><spring:message code='Cache.lbl_Todays'/></a>
		<a href="#" class="calendarcontrol btnTypeDefault cal"></a>
		<input type="text" id="inputCalendarcontrol" style="height: 0px; width:0px; border: 0px;" >
	</div> 
</div>
<div class='cRContBottom mScrollVH'>
	<!-- 컨텐츠 시작 -->
	<div class="ATMCont">
		<div class="ATMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft"></div>			
		</div>		
		<div class="tblList">
			<table id="att" class="ATMTable">
				<thead>
					<tr> 	
						<th width="250"><spring:message code='Cache.lbl_Gubun' /></th>
						<th><spring:message code='Cache.lbl_officer' /></th>
					</tr> 
				</thead>
				<tbody>
					<tr>
						<td><spring:message code='Cache.lbl_Vacation'/><br><span id="VAC_cnt"></span></td>
						<td class="VAC"></td>
					</tr>
					<tr>
						<td><spring:message code='Cache.lbl_n_att_absent'/><br><span id="ABSENT_cnt"></span></td>
						<td class="ABSENT"></td>
					</tr>
					<tr>
						<td><spring:message code='Cache.lbl_attendance_late'/><br><span id="LATE_cnt"></span></td>
						<td class="LATE"></td>
					</tr>
					<tr>
						<td>
							<spring:message code='Cache.lbl_n_att_otherjob_sts'/><br>
							(
							<spring:message code='Cache.AttendanceCode_businessTrip'/>/
							<spring:message code='Cache.lbl_OutsideWorking'/>/
							<spring:message code='Cache.lbl_n_att_telecommuting'/> <spring:message code='Cache.lbl_Etc'/> <!-- 등 -->
							)
							<br><span id="JOB_cnt"></span></td>
						<td class="JOB">-</td>
					</tr>
				</tbody>
			</table>	
		</div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>

<script type="text/javascript">
var _targetDate = "<%=userNowDate%>";
var dnCode = JSON.parse(sessionStorage.SESSION_DN_Code);

$(function(){
	init();
});

function init(){
	$(".target-date").html(_targetDate);

	//달력 초기화
	initCalendar();
	
	getAttDailyStatus();
}

function initCalendar(){
	$("#inputCalendarcontrol").datepicker({
		dateFormat: 'yy-mm-dd',
		beforeShow: function(input) {
           var i_offset = $(".calendarcontrol").offset();      // 버튼이미지 위치 조회
           setTimeout(function(){
              $("#ui-datepicker-div").css({"left":i_offset});
           })
        },
		onSelect: function(dateText){
			_targetDate = dateText;
			$(".target-date").html(_targetDate);
			getAttDailyStatus();
		}
	});
	
	$(".calendarcontrol").click(function(){
		$("#inputCalendarcontrol").datepicker().datepicker("show");
	});
	
	$(".dayChg").on('click',function(){
		dayChg($(this).data("paging"));
	});
}

function dayChg(t){
	_targetDate = moment(_targetDate).add((t == '+') ? 1 : -1, 'day').format('YYYY-MM-DD');
	$("#inputCalendarcontrol").datepicker('setDate', _targetDate);
	$(".target-date").html(_targetDate);

	getAttDailyStatus();
}

function dayToday(){
	_targetDate = moment().format('YYYY-MM-DD');
	$("#inputCalendarcontrol").datepicker('setDate', _targetDate);
	$(".target-date").html(_targetDate);

	getAttDailyStatus();
}

function getAttDailyStatus(){
	getLateList('LATE'); 
	getLateList('VAC'); 
	getLateList('ABSENT'); 
	getUserJobHistoryList();
}

function getLateList(attendType){
	$.ajax({
		url: "/groupware/attendPortal/getUserStatus.do",
		type:"post",
		data: {
			targetDate: _targetDate,
			StartDate: _targetDate,
			EndDate: _targetDate,
			Status: attendType, 
			DeptUpCode: 'ORGROOT;'+dnCode.data+';',		// 최상위 조직. 조직별 검색기능 추가시, 파라미터 처리해야함. 세션스토리지의 SESSION_DN_Code 활용함.
			sortColumn: 'ur.MultiDisplayName',
			sortDirection: 'ASC'			
		},
		success:function (data) {
			$("."+attendType).html("");
			$("#"+attendType+"_cnt").html("");

			if (data.list && data.list.length > 0){		
				data.list.sort(function(a,b){
					if (a.URName > b.URName) return 1;
					if (a.URName < b.URName) return -1;
					if (a.URName === b.URName) return 0;
				});
				
				$.each(data.list, function(idx, el){
					$("."+attendType).append('<div class="ur-item">'+el.URName+'/'+el.DeptName+'</div>');
				});
				$("#"+attendType+"_cnt").html('('+ data.list.length +'<spring:message code="lbl_personCnt.lbl_personCnt"/>)'); //명
			}
			else {
				$("."+attendType).html('-');
			}
		},
		error:function(response, status, error){
			Common.Warning("<spring:message code='Cache.msg_OccurError'/>");
		}
	});
}

function getUserJobHistoryList(){
	var param = {
		targetDate: _targetDate
	};
	
	$.ajax({
		url: "/groupware/attendUserSts/getUserJobHisInfoList.do",
		type:"post",
		data: param,
		success:function (data) {
			$(".JOB").html("");
			$("#JOB_cnt").html("");
			
			if (data.jobHistory && data.jobHistory.length > 0){
				$.each(data.jobHistory, function(idx, el){
					$(".JOB").append('<div class="ur-item">'+el.DisplayName+'</div>')
				});
				$("#JOB_cnt").html('('+ data.jobHistory.length +'<spring:message code="lbl_personCnt.lbl_personCnt"/>)'); //명
			}
			else {
				$(".JOB").html('-');
			}
		},
		error:function(response, status, error){
			Common.Warning("<spring:message code='Cache.msg_OccurError'/>");
		}
	});
}
</script>