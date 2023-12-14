<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%
	String userNowDate = ComUtils.GetLocalCurrentDate("yyyy-MM-dd"); 
%>
<style>
/*#realTimeTr{diplay:none}*/
.WorkBoxM.Absent {background-color:#E6E1E0;}
</style>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_Holiday' /> <spring:message code='Cache.lbl_StatusWorkers' /><span class="target-date"></span></h2> <!-- 휴일 근무자현황 -->
	<div class="pagingType02">
		<a href="#" class="pre dayChg" data-paging="-"></a>
		<a href="#" class="next dayChg" data-paging="+"></a>
		<a href="#" class="btnTypeDefault calendartoday"><spring:message code='Cache.lbl_Todays'/></a>
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
		<!-- 
		<div class="ATMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft"> 	 
				<a href="#" id="setAttBtn" class="s_active btnTypeDefault  btnTypeBg btnAttAdd"><spring:message code='Cache.lbl_n_att_history'/> <spring:message code='Cache.btn_Add'/>/<spring:message code='Cache.btn_Edit'/></a>				 
			</div>			
		</div>
		-->
		<div class="ATMFilter_Info_wrap" style="border-top: 0px; margin-top: 0px;">
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
	</div>
	<!-- 컨텐츠 끝 -->
</div>

<!-- 휴일 근무자현황 temp 테이블 시작 -->
<table id="attHolidayTemp" class="ATMTable" cellpadding="0" cellspacing="0" style="display:none;">
	<thead>
		<tr> 	
			<th width="150"><spring:message code='Cache.lbl_DeptName' /></th>
			<th width="130"><spring:message code='Cache.lbl_JobTitle' /></th> 	
			<th width="130"><spring:message code='Cache.lbl_JobLevel' /></th> 
			<th><spring:message code='Cache.lbl_name' /></th>
			<th><spring:message code='Cache.lbl_startWorkTime' /></th>
			<th><spring:message code='Cache.lbl_Contents' /></th>
			<th><spring:message code='Cache.lbl_Remark' /></th>
		</tr> 
	</thead>
</table>

<table id="attHolidayTempTable" class="ATMTable top_line" cellpadding="0" cellspacing="0" style="display:none;">
	<tbody>
		<tr id="attHolidayTempTd" style="height: 35px;">
			<td class="DeptName" width="150" style="border-left: 0px !important;"></td>
			<td class="JobLevelName" width="130" style="background: none !important;"></td>
			<td class="JobTitleName" width="130"></td> 
			<td class="URName"></td>
			<td class="AttStartTime"></td>
			<td class="Etc"></td>
			<td class="Remark"></td>				
		</tr>
	</tbody>
</table>	

<table id="attHolidayEmptyTempTable" class="ATMTable top_line" cellpadding="0" cellspacing="0" style="display:none;">
	<tbody>
		<tr>
			<td style="height: 35px;">
				<spring:message code='Cache.mag_Attendance22' /> <!-- 휴일 근무자 현황이 없습니다. -->
			</td>
		</tr>
	</tbody>
</table>	
<!-- 근태현황  temp 테이블 끝 -->

<script type="text/javascript">

var _targetDate = "<%=userNowDate%>";
var _curStDate;
var _curEdDate;
var _stDate;
var _edDate;

var _wpMon = "<spring:message code='Cache.lbl_WPMon' />";
var _wpTue = "<spring:message code='Cache.lbl_WPTue' />";
var _wpWed = "<spring:message code='Cache.lbl_WPWed' />";
var _wpThu = "<spring:message code='Cache.lbl_WPThu' />";
var _wpFri = "<spring:message code='Cache.lbl_WPFri' />";
var _wpSat = "<spring:message code='Cache.lbl_WPSat' />";
var _wpSun = "<spring:message code='Cache.lbl_WPSun' />";
var _days = "<spring:message code='Cache.lbl_days' />";
var _absent = "<spring:message code='Cache.lbl_n_att_absent' />";
var _calling = "<spring:message code='Cache.lbl_n_att_callingTarget' />";

var _page = 1 ;
var _pageSize = 10 ;

$(document).ready(function(){
	init();
	reLoadList();
});

function init(){
	// 날짜 초기화
	$(".target-date").html(_targetDate);
	
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

function searchList(d){
	_targetDate = d;
	clearGetAttList();
}

function dayChg(t){
	var tDate = new Date(_targetDate);
	
	if("+" == t){
		tDate.setDate(tDate.getDate() + 1);
		_targetDate = tDate.format('yyyy-MM-dd');		
	}else if("-" == t){
		tDate.setDate(tDate.getDate() - 1);
		_targetDate = tDate.format('yyyy-MM-dd');
	}
	
	$(".target-date").html(_targetDate);
}

function clearGetAttList(){
	$(".target-date").html(_targetDate);
	$(".tblList").html("");
	setTempHtml();
}

function reLoadList(){
	_page = 1; 
	clearGetAttList();
}

function refreshList(){
	_targetDate = "<%=userNowDate%>"; 
	reLoadList();
}

function setTempHtml(){
	var tempHtml = $("#attHolidayTemp").clone();
	tempHtml.removeAttr("style","display:none;")
	tempHtml.removeAttr("id");
	
	$(".tblList").html(tempHtml);
	$(".tblList").append("<div class='ATMTable_02_scroll' id='attTable'></div>");
	
	getAttList();
}

function setHolidayHtml(att){
	var tempTable = $("#attHolidayTempTable").clone();
	tempTable = tempTable.removeAttr("style","display:none;");
	tempTable = tempTable.removeAttr("id");
	tempTable.find("tbody").empty();
	
	$("#attTable").append(tempTable);
	
	for(var i = 0; i < att.length; i++) {		
		var tempTd = $("#attHolidayTempTd").clone();
		tempTd = tempTd.removeAttr("id");
		
		if(i == 0) tempTable.find("tbody").empty();
		
		for(key in att[i]) {
			tempTd.find("td." + key).html(att[i][key]);
		}
		
		$("#attTable").find("tbody").append(tempTd);
	}
	
	// 셀 병합
	genRowspan("DeptName");
}

function getAttList(){
	var params = {
		 targetDate : _targetDate
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
		url:"/groupware/attendHolidaySts/getHolidayAttendance.do",
		success:function (data) {
			if(data.status =="SUCCESS"){
				$(".mScrollVH").off();

				if(data.loadCnt > 0){					
					setHolidayHtml(data.data);
					
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
					var tempTable = $("#attHolidayEmptyTempTable").clone();
					tempTable = tempTable.removeAttr("style","display:none;");
					tempTable = tempTable.removeAttr("id");
					$("#attTable").append(tempTable);
				}
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
			}
		}
	});
}

// 셀 병합
function genRowspan(className){
    $("." + className).each(function() {
    	var curr = $(this).text();
    	var rows = $("." + className).filter(function() {
    		return $(this).text() == curr;
    	});
    	
        if (rows.length > 1) {
            rows.eq(0).attr("rowspan", rows.length);
            rows.not(":eq(0)").remove();
        }
    });
}
</script>