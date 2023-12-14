<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%
	String userNowDate = ComUtils.GetLocalCurrentDate("yyyy-MM-dd"); 
%>

<div class="cRConTop titType AtnTop">
	<h2 class="title"></h2> 
	<div class="pagingType02">
		<a href="#" class="pre dayChg" data-paging="-"></a>
		<a href="#" class="next dayChg" data-paging="+"></a>
		<a href="#" class="btnTypeDefault calendartoday"><spring:message code='Cache.lbl_Todays'/></a>
		<a href="#" class="calendarcontrol btnTypeDefault cal"></a>
		<input type="text" id="inputCalendarcontrol" style="height: 0px; width:0px; border: 0px;" >
	</div> 
	<div class="searchBox02"> 
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<!-- 컨텐츠 시작 -->
	<div class="ATMCont">
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
		<div class="tblList">
			<table id="jobHistory" class="ATMTable" cellpadding="0" cellspacing="0">
				<thead>
					<tr> 	
						<th width="200"><spring:message code='Cache.lbl_dept'/></th>
						<th width="100"><spring:message code='Cache.lbl_JobTitle'/></th> 
						<th width="100"><spring:message code='Cache.lbl_JobLevel'/></th> 	
						<th width="100"><spring:message code='Cache.lbl_User_DisplayName'/></th> 
						<th width="150"><spring:message code='Cache.lbl_att_806_s_1_h'/></th> 
						<th width="150"><spring:message code='Cache.lbl_att_workDate'/></th> 
						<th width="150"><spring:message code='Cache.lbl_att_workTime'/></th> 
						<th width=""><spring:message code='Cache.lbl_Remark'/></th> 
					</tr> 
				</thead>
				<tbody></tbody>
			</table>
		</div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>

<script type="text/javascript">
var _targetDate = "<%=userNowDate%>";
var _stDate;
var _edDate;

$(function(){
	init();
	setPageType();
});

function init(){
	//부서선택
	AttendUtils.getDeptList($("#groupPath"), '', false, false, true);
	$("#groupPath").on('change', function(){
		reLoadList();
	});
	
	//직급 직책 리스트 조회 
	$("#jobGubun").on('change', function(){
		AttendUtils.getJobList($(this).val(), 'jobCode');
		if($(this).val() == ''){
			reLoadList();			
		}
	});
	
	$("#jobCode").on('change', function(){
		reLoadList();
	});
	
	//날짜paging
	$(".dayChg").on('click', function(){
		dayChg($(this).data("paging"));
		reLoadList();
	});
	
	//달력 검색
	setTodaySearch();
}

function dayChg(t){
	if("+" == t){
		_targetDate = _edDate;
	}
	else if("-" == t){
		_targetDate = _stDate;
	}
}

function clearList(){
	$("#jobHistory tbody").html("");
	getUserJobHistoryList();
}

function reLoadList(){
	clearList();
}

function refreshList(){
	_targetDate = "<%=userNowDate%>"; 
	reLoadList();
}

function searchList(d){
	_targetDate = d;
	clearList();
}

function setPageType(){
	getUserJobHistoryList();
}

function setHtml(history){
	//상단 날짜 표시
	$(".title").html('<spring:message code="Cache.lbl_OtherWorkStat" /> '+ history.dayTitle); //기타근무현황
	_stDate = history.p_sDate;
	_edDate = history.p_eDate;
	
	if(history.jobHistory.length == 0){
		$("#jobHistory tbody").html('<tr><td colspan="8" style="height: 40px;"><spring:message code="Cache.msg_NoDataList" /></td></tr>'); //조회할 목록이 없습니다.
	}
	else {
		$.each(history.jobHistory, function(idx, el){
			var html = '<tr style="height: 40px;">'
			html += '<td>'+el.DeptName+'</td>';
			//html += '<td>'+((el.JobPositionName) ? el.JobPositionName : '&nbsp;') +'</td>';
			html += '<td>'+((el.JobTitleName) ? el.JobTitleName : '&nbsp;') +'</td>';
			html += '<td>'+((el.JobLevelName) ? el.JobLevelName : '&nbsp;') +'</td>';
			html += '<td>'+el.DisplayName+'</td>';
			html += '<td>'+el.JobStsName+'</td>';
			html += '<td>'+el.JobDate+'</td>';
			html += '<td>'+el.v_StartTime+'~'+el.v_EndTime+'</td>';
			html += '<td>'+el.Etc+'</td>';
			html += '</tr>';
			
			$("#jobHistory tbody").append(html);
		});
	}
}

function getUserJobHistoryList(){
	var param = {
		targetDate: _targetDate,
		requestType: 'period',
		groupPath: $("#groupPath").val(),
		sJobTitleCode: ($("#jobGubun").val()=="1_JobTitle") ? $("#jobCode").val() : null,
		sJobLevelCode: ($("#jobGubun").val()=="1_JobLevel") ? $("#jobCode").val() : null
	};
	
	$.ajax({
		url: "/groupware/attendUserSts/getUserJobHisInfoList.do",
		type: "post",
		data: param,
		success: function (data) {
			setHtml(data);
		},
		error: function(response, status, error){
			Common.Warning("<spring:message code='Cache.msg_OccurError'/>");
		}
	});
}
</script>