<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%
	String userNowYear = ComUtils.GetLocalCurrentDate("yyyy");
	String userNowMonth = ComUtils.GetLocalCurrentDate("yyyy-MM");
%>
<div class="cRConTop titType AtnTop">
	<h2 class="title">지각현황 <span class="target-date"></span></h2>
	<div class="pagingType02">
		<a href="#" class="pre dayChg" data-paging="-"></a>
		<a href="#" class="next dayChg" data-paging="+"></a>
		<!-- 
		<a href="#" class="btnTypeDefault calendartoday"><spring:message code='Cache.lbl_Todays'/></a>
		<a href="#" class="calendarcontrol btnTypeDefault cal"></a>
		-->
		<input type="text" id="inputCalendarcontrol" style="height: 0px; width:0px; border: 0px;" >
	</div> 
	<div class="searchBox02"> 
		<span><input type="text" id="sUserTxt"><button type="button" id="searchBtn" class="btnSearchType01"><spring:message code='Cache.lbl_search'/></button></span>
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<!-- 컨텐츠 시작 -->
	<div class="ATMCont">
		<div class="ATMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft"> 	 
				<a class="btnTypeDefault btnExcel" id="excelBtn" href="#"><spring:message code='Cache.lbl_SaveToExcel'/></a> 
			</div>
			<!-- 
			<div class="ATMbuttonStyleBoxRight">
				<ul class="ATMschSelect">
					<li class="pageToggle selected"><a href="#">연간</a></li>
					<li class="pageToggle"><a href="#"><spring:message code='Cache.lbl_Monthly' /></a></li>
				</ul>
			</div>
		 	-->
		</div>
		<div class="ATMFilter_Info_wrap">
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

<!-- 개인별 지각현황 Temp 테이블 시작 -->
<table id="attLateTemp" class="ATMTable" cellpadding="0" cellspacing="0" style="display:none;">
	<thead>
		<tr> 	
			<th width="150" rowspan="2"><spring:message code='Cache.lbl_DeptName' /></th>
			<th width="100" rowspan="2"><spring:message code='Cache.lbl_JobTitle' /></th> 	
			<th width="100" rowspan="2"><spring:message code='Cache.lbl_JobLevel' /></th> 
			<th width="100" rowspan="2"><spring:message code='Cache.lbl_name' /></th>
			<th colspan="13"><spring:message code='Cache.lbl_attendance_late' /></th>
		</tr>
		<tr>
			<th style="border-left: 1px solid #ebebec !important;"><spring:message code='Cache.lbl_Month_1' /></th>
			<th><spring:message code='Cache.lbl_Month_2' /></th>
			<th><spring:message code='Cache.lbl_Month_3' /></th>
			<th><spring:message code='Cache.lbl_Month_4' /></th>
			<th><spring:message code='Cache.lbl_Month_5' /></th>
			<th><spring:message code='Cache.lbl_Month_6' /></th>
			<th><spring:message code='Cache.lbl_Month_7' /></th>
			<th><spring:message code='Cache.lbl_Month_8' /></th>
			<th><spring:message code='Cache.lbl_Month_9' /></th>
			<th><spring:message code='Cache.lbl_Month_10' /></th>
			<th><spring:message code='Cache.lbl_Month_11' /></th>
			<th><spring:message code='Cache.lbl_Month_12' /></th>
			<th><spring:message code='Cache.lbl_sum' /></th>
		</tr> 
	</thead>
</table>

<table id="attLateTempTable" class="ATMTable top_line" cellpadding="0" cellspacing="0" style="display:none;">
	<tbody>
		<tr id="attLateTempTd" style="height: 35px;">
			<td class="DeptName" width="150" style="border-left: 0px !important;"></td>
			<td class="JobLevelName" width="100" style="background: none !important;"></td>
			<td class="JobTitleName" width="100"></td> 
			<td class="URName" width="100"></td>
			<td class="MonthCnt1"></td>
			<td class="MonthCnt2"></td>
			<td class="MonthCnt3"></td>
			<td class="MonthCnt4"></td>
			<td class="MonthCnt5"></td>
			<td class="MonthCnt6"></td>
			<td class="MonthCnt7"></td>
			<td class="MonthCnt8"></td>
			<td class="MonthCnt9"></td>
			<td class="MonthCnt10"></td>
			<td class="MonthCnt11"></td>
			<td class="MonthCnt12"></td>
			<td class="TotalCnt"></td>		
		</tr>
	</tbody>
</table>	

<table id="attLateEmptyTempTable" class="ATMTable top_line" cellpadding="0" cellspacing="0" style="display:none;">
	<tbody>
		<tr>
			<td style="height: 35px;">
				<spring:message code='Cache.mag_Attendance27' /> <!-- 지각현황이 없습니다. -->
			</td>
		</tr>
	</tbody>
</table>	
<!-- 개인별 지각현황 Temp 테이블 끝 -->

<script type="text/javascript">
var _pageType = 0; 
var _targetYear = "<%=userNowYear%>";
var _targetMonth = "<%=userNowMonth%>";
var _page = 1 ;
var _pageSize = 10 ;

$(document).ready(function(){
	init();
	reLoadList();
});

function init(){
	// 날짜 초기화
	$(".target-date").html(_targetYear);
	
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
	
	$(".pageToggle").on('click',function(){
		$(".pageToggle").attr("class","pageToggle");
		$(this).attr("class","selected pageToggle");
		
		_page = 1;
		setPageType($(this).index());
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
	
	
	//엑셀다운로드
	$("#excelBtn").on('click',function(){
		
	});
}

function searchList(d){
	_targetYear = d;
	clearGetAttList();
}

function dayChg(t){
	var tYear = new Date(_targetYear);
	var tMonth = new Date(_targetMonth);
	
	if("+" == t){
		if(_pageType == 0) {
			tYear.setFullYear(tYear.getFullYear() + 1);
			_targetYear = tYear.format('yyyy');	
		} else {
			tMonth.setMonth(tMonth.getMonth() + 1);
			_targetMonth = tMonth.format('yyyy-MM');	
		}
	}else if("-" == t){
		if(_pageType == 0) {
			tYear.setFullYear(tYear.getFullYear() - 1);
			_targetYear = tYear.format('yyyy');	
		} else {
			tMonth.setMonth(tMonth.getMonth() - 1);
			_targetMonth = tMonth.format('yyyy-MM');	
		}
	}
	
	$(".target-date").html(_pageType == 0 ? _targetYear : _targetMonth);
}

function clearGetAttList(){
	$(".target-date").html(_pageType == 0 ? _targetYear : _targetMonth);
	$(".tblList").html("");
	setTempHtml();
}

function reLoadList(){
	_page = 1; 
	clearGetAttList();
}

function refreshList(){
	_targetYear = "<%=userNowYear%>"; 
	reLoadList();
}

function setPageType(t){
	_pageType = t;
	$(".target-date").html(_pageType == 0 ? _targetYear : _targetMonth);
	setTempHtml();
}

function setTempHtml(){
	var tempHtml = $("#attLateTemp").clone();
	tempHtml.removeAttr("style","display:none;")
	tempHtml.removeAttr("id");
	
	$(".tblList").html(tempHtml);
	$(".tblList").append("<div class='ATMTable_02_scroll' id='attTable'></div>");
	
	getAttList();
}

function setLateHtml(att){
	var tempTable = $("#attLateTempTable").clone();
	tempTable = tempTable.removeAttr("style","display:none;");
	tempTable = tempTable.removeAttr("id");
	
	$("#attTable").append(tempTable);
	
	for(var i = 0; i < att.length; i++) {		
		var tempTd = $("#attLateTempTd").clone();
		tempTd = tempTd.removeAttr("id");
		
		if(i == 0) tempTable.find("tbody").empty();
		
		for(key in att[i]) {
			tempTd.find("td." + key).html(att[i][key] == 0 ? "" : att[i][key]);
		}
		
		$("#attTable").find("tbody").append(tempTd);
	}
	
	// 셀 병합
	genRowspan("DeptName");
}

function getAttList(){
	var params = {
		 targetYear : _targetYear
		,targetMonth : _targetMonth
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
		url:"/groupware/attendLateSts/getLateAttendance.do",
		success:function (data) {
			if(data.status =="SUCCESS"){
				//$(".mScrollVH").off();
				if(data.loadCnt > 0){				
					if(_pageType == 0){
						setLateHtml(data.data);
					}else if(_pageType == 1){
						//setMonthHtml(data.data);
					}		
					
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
					var tempTable = $("#attLateEmptyTempTable").clone();
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