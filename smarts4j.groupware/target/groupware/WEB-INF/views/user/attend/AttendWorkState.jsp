<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.RedisDataUtil,egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<style>
.StateBox .commuteList .coPhoto img {width: 40px;}
.StateBox .commuteList .coTxt {width: calc(100% - 250px);} 
.StateCont {position: relative; display: block; min-width: 913px; margin: 0; padding: 67px 25px;}
.schListCheck {background-color: #f9f9f9; margin-top: 8px; border-bottom: 1px solid #c8c8c8; border-top: 1px solid #c8c8c8; width: 100%;}
</style>
<div class='cRConTop titType AtnTop'>
	<h2 class="title"><spring:message code='Cache.lbl_WorkState'/></h2>
	<div class="searchBox02"></div>				
</div>
<div class="cRContAll mScrollVH">
	<!-- 컨텐츠 시작 -->
	<div class="StateCont">
		<div class="StateArea">
			<div class="StateTop StateTop3">
				<div class="StateTopLeft">
					<input id="deptUpCodeWork" type="hidden" onchange="changeDeptWork();">
					<span id="deptCodeListWork"></span>
				</div>
				<div class="StateTopRight">
					<span class="temp"><spring:message code='Cache.mag_Attendance30' /></span> <!-- 근무템플릿 -->
					<select class="selectType02" id="SchSeq">
						<option value=""><spring:message code='Cache.lbl_all' /></option> <!-- 전체 -->
						<option value="multiCheck">다중선택</option> <!-- 다중선택 -->
						<c:forEach items="${SchList}" var="list" varStatus="status" >
							<option value="${list.SchSeq}">${list.SchName}</option>
						</c:forEach>
					</select>
					
					<div class="searchBox02">
						<span>
							<input type="text" id="searchText" />
							<button type="button" class="btnSearchType01"><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
						</span>
						<select class="selectType02 listCount" id="listCntSel" style="width: 62px;">
							<option value="10" selected>10</option>
							<option value="15">15</option>
							<option value="20">20</option>
							<option value="30">30</option>
							<option value="50">50</option>
							<option value="100">100</option>
						</select>
						<button href="#" class="btnRefresh" type="button"></button>
					</div>
				</div>
				
				<div class="StateTopRight schListCheck" style="display: none;">
					<c:forEach items="${SchList}" var="list" varStatus="status" >
						<li class="chkStyle06" style="margin-right: 10px;"><input type="checkbox" id="${list.SchSeq}" name="schItem" class="schItem" value="${list.SchSeq}" /><label for="${list.SchSeq}">${list.SchName}</label></li>
					</c:forEach>
				</div>
			</div>
			<div class="StateBottom StateBottom3">
				<div class="StateTit">
					<div class="StateTitLeft"  id="deptTit">
						<strong class="date" >${TargetDate}</strong>
						<div class="pagingType03"  section-type="D">
							<a href="#" class="pre" data-paging="-"></a>
							<a href="#" class="next" data-paging="+"></a>
							<a href="#" class="calendartoday btnTypeDefault"><spring:message code='Cache.lbl_Todays'/></a>
							<a href="#" class="calendarcontrol btnTypeDefault cal"></a>
							<input type="text" class="calendarinput" style="height: 0px; width:0px; border: 0px;" >
							<a class="btnTypeDefault" id="btnExcel" href="#"><spring:message code='Cache.btn_SaveToExcel'/></a> <!-- 엑셀저장 -->
						</div>
						<span style="margin-left: 10px;">
							<input type="checkbox" id="ckb_daynight" checked/> <spring:message code='Cache.lbl_DayNightMarking'/>
						</span> <!-- 주야표기 -->
					</div>					 
					<div class="StateTitRight">
						<ul class="ATMschSelect TabList">
							<li class="selected" data-tab="tab-1" data-type="D"><a href="#"><spring:message code='Cache.lbl_Daily'/></a></li>
							<li data-tab="tab-2" data-type="M"><a href="#"><spring:message code='Cache.lbl_Monthly'/></a></li>
						</ul>
					</div>					
				</div>
				<!-- StateTit end -->
				<div class="tblList">
					<div id="tab-1" class="TabCont selected">
						<!-- 근무현황 테이블 일간 시작 -->
						<table class="ATMTable ATMTablePd" cellpadding="0" cellspacing="0">
							<thead>
								<tr>
									<th width="" rowspan="2"><spring:message code='Cache.lbl_hr_name'/></th> <!-- 성명 -->
									<th width="" rowspan="2"><spring:message code='Cache.lbl_Postion'/></th> <!-- 소속 -->
									<th width="" rowspan="2" class="lh"><spring:message code='Cache.lbl_att_work'/><br /> <spring:message code='Cache.lbl_Template'/></th> <!-- 근무<br /> 템플릿 -->
									<th width="" colspan="8"><spring:message code='Cache.lbl_att_work'/><spring:message code='Cache.lbl_CurrentSituation'/></th> <!-- 근무현황 -->
								</tr>
								<tr>
									<th class="bl"><spring:message code='Cache.lbl_att_goWork'/></th> <!-- 출근 -->
									<th><spring:message code='Cache.lbl_leave'/></th> <!-- 퇴근 -->
									<th><spring:message code='Cache.lbl_BasicWork'/></th> <!-- 기본근무 -->
									<th><spring:message code='Cache.lbl_att_overtime_work'/></th> <!-- 연장근무 -->
									<th><spring:message code='Cache.lbl_att_holiday_work'/></th> <!-- 휴일근무 -->
									<th><spring:message code='Cache.lbl_att_beingLate'/></th> <!-- 지각 -->
									<th><spring:message code='Cache.lbl_att_leaveErly'/></th> <!-- 조퇴 -->
									<th><spring:message code='Cache.lbl_n_att_resttime'/></th> <!-- 휴게 -->
								</tr>
							</thead>
							<tbody>
							</tbody>
						</table>
						<!-- 근무현황 테이블 일간 끝 -->
						<div class="AXgridPageBody" style="z-index:1;">
							<div id="custom_navi_messageGrid_D" style="text-align:center;margin-top:2px;"></div>
						</div>
					</div>
					<div id="tab-2" class="TabCont">
						<!-- 근무현황 테이블 주/월 시작 (*상세보기 버튼 누르면 윈도우 팝업 노출됨)-->
						<table class="ATMTable" cellpadding="0" cellspacing="0">
							<thead>
								<tr>
									<th width="" rowspan="2"><spring:message code='Cache.lbl_hr_name'/></th> <!-- 성명 -->
									<th width="" rowspan="2"><spring:message code='Cache.lbl_Postion'/></th> <!-- 소속 -->
									<th width="" colspan="6"><spring:message code='Cache.lbl_CurrentSituation'/></th> <!-- 근무현황 -->
									<th width="" rowspan="2" class="lh"><spring:message code='Cache.lbl_att_work'/><br /> <spring:message code='Cache.lbl_Template'/></th> <!-- 근무<br /> 템플릿 -->
								</tr>
								<tr>
									<th class="bl"><spring:message code='Cache.lbl_BasicWork'/></th> <!-- 기본근무 -->
									<th><spring:message code='Cache.lbl_att_overtime_work'/></th> <!-- 연장근무 -->
									<th><spring:message code='Cache.lbl_att_holiday_work'/></th> <!-- 휴일근무 -->
									<th><spring:message code='Cache.lbl_att_beingLate'/></th> <!-- 지각 -->
									<th><spring:message code='Cache.lbl_att_leaveErly'/></th> <!-- 조퇴 -->
									<th><spring:message code='Cache.lbl_n_att_resttime'/></th> <!-- 휴게 -->
								</tr>
							</thead>
							<tbody>
							</tbody>
						</table>
						<!-- 근무현황 테이블 주/월 끝 -->
						<div class="AXgridPageBody" style="z-index:1;">
							<div id="custom_navi_messageGrid_M" style="text-align:center;margin-top:2px;"></div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>
<script>
var _targetDate = "${TargetDate}";
var _companyMap = {targetDate:"${TargetDate}",startDate:"${StartDate}", endDate: "${EndDate}", pageType: "W"};
var _userMap    = {targetDate:"${TargetDate}",startDate:"${StartDate}", endDate: "${EndDate}", pageType: "W"};
var _deptMap    = {targetDate:"${TargetDate}",startDate:"${TargetDate}", endDate: "${TargetDate}", pageType: "D"};
var _pageNo     = 1;
var _pageSize   = 10;
var _endPage    = 1;
var _printDN 	= true;
var schCheckList = new Array();

$(document).ready(function() {
	AttendUtils.getDeptStepList($("#deptCodeListWork"),'', false, false, "deptUpCodeWork");

	//회사별 근태현황 event
	$(".pre, .next").click(function(){
		var targetDate;
		var startDate = _deptMap["startDate"];
		var endDate = _deptMap["endDate"];

		if("+"==$(this).attr("data-paging")) {
			targetDate = schedule_SetDateFormat(schedule_AddDays(endDate, 1), '-');
		} else {
			targetDate = schedule_SetDateFormat(schedule_AddDays(startDate, -1), '-');
		}

		getCompanyAttInfo(targetDate, 1);
	});

	//오늘 클릭시
	$(".calendartoday").click(function(){
		getCompanyAttInfo("${TargetDate}", 1);
	});
	
	$(".calendarinput").datepicker({
		dateFormat: 'yy-mm-dd',
		beforeShow: function(input) {
           var i_offset = $(this).closest(".calendarcontrol").offset();
           
           setTimeout(function(){
              $("#ui-datepicker-div").css({"left":i_offset});
           })
        },
		onSelect: function(dateText){
			getCompanyAttInfo(dateText, 1);
		}
	});
	
	$(".calendarcontrol").click(function(event){
		$(this).next("input").datepicker().datepicker("show");
	});
	
	// 주간 / 월간 선택
	$('.TabList li').click(function(){
		var tab_id = $(this).attr('data-tab');

		$('.TabList li').removeClass('selected');
		$('.TabCont').removeClass('selected');

		$(this).addClass('selected');
		$("#"+tab_id).addClass('selected');
		_deptMap["pageType"] = $(this).attr('data-type');
		
		getCompanyAttInfo("", 1);
	});
	
	//엑셀
	$("#btnExcel").click(function() {
		$('#download_iframe').remove();
		
		var url = "/groupware/attendPortal/excelPortalDept.do";
		var params = {
			pageType : _deptMap["pageType"],
			dateTerm : _deptMap["pageType"],
			targetDate : _deptMap["targetDate"],
			sDate : _deptMap["startDate"],
			eDate : _deptMap["endDate"],
			deptCode : _deptMap["deptCode"],
			deptUpCode : _deptMap["deptUpCode"],
			deptUpCodeWork : _deptMap["deptUpCodeWork"],	
			queryType:"D",
			deptUpCode:$("#deptUpCode").val(),
			deptUpCodeWork:$("#deptUpCodeWork").val(),
			searchText:$("#searchText").val(),
			schSeq:$("#SchSeq").val(),
			schCheckList : schCheckList,
			printDN:_printDN
		}
	
		ajax_download(url, params);	
	});
	
	$("#SchSeq").change(function(){
		schCheckList = new Array();
		
		if($(this).val() != "multiCheck") {
			$(".schListCheck").hide();
			
			getCompanyAttInfo("", 1);	
		} else {
			$("input[name='schItem']").each(function() {
				$(this).prop("checked", false);
			});
			
			$(".schListCheck").show();
		}
	});
	
	//검색 클릭시
	$(".btnSearchType01").click(function(){
		getCompanyAttInfo("", 1);
	});	
	
	$("#listCntSel").change(function(){
		getCompanyAttInfo("", 1);
	});
	
	$('.btnRefresh').on('click', function(e) {
		getCompanyAttInfo("", _pageNo);
	});

	//주야 표기 모드
	if($("#ckb_daynight").is(":checked")){
		_printDN = true;
	} else {
		_printDN = false;
	}

	$("#ckb_daynight").change(function() {
		if(this.checked) {
			_printDN = true;
		} else {
			_printDN = false;
		}
		
		printDN();
	});	

	// 근무현황 상세보기
	$(document).on("click",".btnSearchDetail", function(){
		var dataMap = JSON.parse($(this).attr("data-map"));
		var popupID		= "AttendPortalDetailPopup";
		var openerID	= "AttendPortalDetail";
		var popupTit	= "<spring:message code='Cache.lbl_WeeklyMonthlyReport' />"; //근태주보/월보
		var popupYN		= "N";
		var popupUrl	= "/groupware/attendPortal/AttendPortalDetailPopup.do?"
						+ "popupID="		+ popupID	+ "&"
						+ "openerID="		+ openerID	+ "&"
						+ "popupYN="		+ popupYN	+ "&"
						+ "UserName="		+ encodeURIComponent(dataMap["URName"])	+ "&"
						+ "UserCode="		+ dataMap["UserCode"]	+ "&"
						+ "StartDate="		+ _deptMap["startDate"]	+ "&"
						+ "EndDate="		+ _deptMap["endDate"]	+ "&"
						+ "printDN="		+ _printDN	+ "&"
						+ "DeptName="		+ encodeURIComponent(dataMap["DeptName"])	+ "&"
		
		Common.open("", popupID, popupTit, popupUrl, "1200px", "700px", "iframe", true, null, null, true);
	});
	
	$(document).on("click", ".schItem", function() {
		schCheckList = new Array();
		
		$("input[name='schItem']").each(function() {
			if($(this).is(":checked")) {
				schCheckList.push($(this).val());
			}
		});
		
		getCompanyAttInfo("", 1);
	});
});

function goPage(pnum){
	_pageNo = pnum;
	$(".AXPaging").each(function(idx){
		$(this).removeClass("Blue");
		var valNum = $(this).attr("value");
		if(Number(valNum)===_pageNo){
			$(this).addClass("Blue");
		}
	});
	
	getCompanyAttInfo("", pnum);
}

function pagging(deptPage){
	//pageing
	var pageNo = Number(deptPage.pageNo);
	var sPage = pageNo - 5;
	if(sPage<1){
		sPage = 1;
	}
	var lPage = sPage + 9;
	if(lPage>Number(deptPage.pageCount)){
		lPage = Number(deptPage.pageCount);
	}
	var nextPage = Number(lPage)+1;
	if(nextPage>Number(deptPage.pageCount)){
		nextPage = Number(deptPage.pageCount);
	}
	var prePage = Number(sPage)-1;
	if(prePage<1){
		prePage = 1;
	}
	var firstPage = 1;
	var endPage = Number(deptPage.pageCount);
	var htmlStr = "";
	htmlStr+='<input type="button" id="AXPaging_begin" class="AXPaging_begin" onclick="javascript:goPage('+firstPage+');">';
	htmlStr+='<input type="button" id="AXPaging_prev" class="AXPaging_prev" onclick="javascript:goPage('+prePage+');">';

	for(var i=sPage;i<=lPage;i++){
		var blue = "";
		if(_pageNo==i){
			blue = " Blue";
		}
		htmlStr+='<input type="button" value="'+i+'" style="min-width:20px;" class="AXPaging'+blue+'" onclick="javascript:goPage('+i+');">';
	}
	htmlStr+='<input type="button" id="AXPaging_next" class="AXPaging_next" onclick="javascript:goPage('+nextPage+');">';
	htmlStr+='<input type="button" id="AXPaging_end" class="AXPaging_end" onclick="javascript:goPage('+endPage+');">';
	return htmlStr;
}

function changeDeptWork(){
	getCompanyAttInfo("", 1);
}

function getCompanyAttInfo(targetDate, pageNo){
	_pageNo = pageNo;
	
	if (targetDate != ""){
		_deptMap["targetDate"] = targetDate;
	}	
	
	var params = {
		companyMap : _companyMap
		,userMap : _userMap
		,deptMap : _deptMap
		,queryType : "D"
		,deptUpCode : $("#deptUpCode").val()
		,deptUpCodeWork : ($("#deptUpCodeWork").val() == "" ? $("#deptUpCode").val() : $("#deptUpCodeWork").val())
		,searchText : $("#searchText").val()
		,schSeq : $("#SchSeq").val()
		,pageNo : _pageNo
		,pageSize : $("#listCntSel").val()
		,schCheckList : schCheckList
	}
	
	$.ajax({
		type : "POST",
		contentType :'application/json; charset=utf-8',
		dataType : 'json',
		data : JSON.stringify(params),
		url : "/groupware/attendPortal/getMangerAttStatus.do",
		success:function (data) {
			if(data.status=="SUCCESS") {
				if (data.deptAttendList) {
					displayDeptList(data.TargetDate, data.StartDate, data.EndDate, data.deptAttendList, data.deptAttendPage);
				}
			} else {
				Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>");
			}
		},
		error:function (request,status,error) {
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
		}
	});
}

function printDN(){
	if(_printDN) {
		$(".printmode").each(function () {
			var dnmode = $(this).data('dnmode');
			if ("on" == dnmode) {
				$(this).show();
			} else {
				$(this).hide();
			}
		});
	}else{
		$(".printmode").each(function () {
			var dnmode = $(this).data('dnmode');
			if ("off" == dnmode) {
				$(this).show();
			} else {
				$(this).hide();
			}
		});
	}
}

// 근무현황 리스트
function displayDeptList(TargetDate, StartDate, EndDate, deptList, deptPage){
	var tabId = "tab-1";
	var listCount = Number(deptPage.listCount);
	
	_endPage= deptPage.pageCount;
	
	if (_deptMap["pageType"] == "D") {	// 일간
		_deptMap["startDate"] = TargetDate;
		_deptMap["endDate"] = TargetDate;
		
		$("#deptTit .date").text(AttendUtils.maskDate(TargetDate));
		
		tabId = "tab-1";
		
		$("#" + tabId + " table tbody").html("");
		
		//pageing
		$("#custom_navi_messageGrid_D").html(pagging(deptPage));

		var html = "";
		
		if(listCount == 0){
			$("#custom_navi_messageGrid_D").hide();
			html += "<tr><td colspan=\"11\"><spring:message code='Cache.msg_NoDataList' /></td></tr>";
		}else{
			$("#custom_navi_messageGrid_D").show();
			$.each(deptList, function(idx, item){
				html += '<tr>'+
						'<td>' + 
						'<div class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="position:relative;cursor:pointer"; data-user-code="'+ item.UserCode +'" data-user-mail="">' + item.URName + " " + AttendUtils.userRepJobType(item) + '</div>' +
						'</td>' +
						'<td>'+item.DeptName+'</td>'+
						'<td>'+AttendUtils.convertNull(item.SchName,'')+'</td>'+
						'<td>'+AttendUtils.convertNull(item.AttStartTime,'')+'</td>'+
						'<td>'+AttendUtils.convertNull(item.AttEndTime,'')+'</td>';
				html += '<td>' +
						'<span class="printmode" data-dnmode="off">'+AttendUtils.convertSecToStr(item.AttAc,"H")+'</span>' +
						'<span class="printmode" data-dnmode="on">'+AttendUtils.convertSecToStr(item.AttAcD,"H")+' /'+AttendUtils.convertSecToStr(item.AttAcN,"H")+'</span>' +
						'</td>';
				html += '<td>' +
						'<span class="printmode" data-dnmode="off">'+AttendUtils.convertSecToStr(item.ExtenAc,"H")+'</span>' +
						'<span class="printmode" data-dnmode="on">'+AttendUtils.convertSecToStr(item.ExtenAcD,"H")+' /'+AttendUtils.convertSecToStr(item.ExtenAcN,"H")+'</span>' +
						'</td>';
				html += '<td>' +
						'<span class="printmode" data-dnmode="off">'+AttendUtils.convertSecToStr(item.HoliAc,"H")+'</span>' +
						'<span class="printmode" data-dnmode="on">'+AttendUtils.convertSecToStr(item.HoliAcD,"H")+' /'+AttendUtils.convertSecToStr(item.HoliAcN,"H")+'</span>' +
						'</td>';
				html += '<td>'+AttendUtils.convertSecToStr(item.LateMin,"H")+'</td>'+
						'<td>'+AttendUtils.convertSecToStr(item.EarlyMin,"H")+'</td>'+
						'<td>'+AttendUtils.convertSecToStr(item.AttIdle,"H")+'</td>'+
				'</tr>';
			});
		}
		
		$("#"+tabId+"  table tbody").html(html);
	} else {	// 월간
		_deptMap["startDate"] = StartDate;
		_deptMap["endDate"] = EndDate;
		
		$("#deptTit .date").text(AttendUtils.maskDate(StartDate) +" ~ "+AttendUtils.maskDate(EndDate));
		
		tabId = "tab-2";
		
		$("#"+tabId+" table tbody").html("");

		$("#custom_navi_messageGrid_M").html(pagging(deptPage));
		
		if(listCount == 0){
			$("#custom_navi_messageGrid_M").hide();
			var html = "";
			html += "<tr height=\"43\"><td colspan=\"8\"><spring:message code='Cache.msg_NoDataList' /></td></tr>";
			$("#" + tabId + "  table tbody").append(html);
		} else {
			$("#custom_navi_messageGrid_M").show();
			
			$.each(deptList, function (idx, item) {
				var html = "";
				html += '<tr>' +
						'<td>' + 
						'<div class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="position:relative;cursor:pointer"; data-user-code="'+ item.UserCode +'" data-user-mail="">' + item.URName + " " + AttendUtils.userRepJobType(item) + '</div>' +
						'</td>' +
						'<td>' + item.DeptName + '</td>';
				html += '<td>' +
						'<span class="printmode" data-dnmode="off">' + AttendUtils.convertSecToStr(item.AttAc, "H") + '</span>' +
						'<span class="printmode" data-dnmode="on">' + AttendUtils.convertSecToStr(item.AttAcD, "H") + ' /' + AttendUtils.convertSecToStr(item.AttAcN, "H") + '</span>' +
						'</td>';
				html += '<td>' +
						'<span class="printmode" data-dnmode="off">' + AttendUtils.convertSecToStr(item.ExtenAc, "H") + '</span>' +
						'<span class="printmode" data-dnmode="on">' + AttendUtils.convertSecToStr(item.ExtenAcD, "H") + ' /' + AttendUtils.convertSecToStr(item.ExtenAcN, "H") + '</span>' +
						'</td>';
				html += '<td>' +
						'<span class="printmode" data-dnmode="off">' + AttendUtils.convertSecToStr(item.HoliAc, "H") + '</span>' +
						'<span class="printmode" data-dnmode="on">' + AttendUtils.convertSecToStr(item.HoliAcD, "H") + ' /' + AttendUtils.convertSecToStr(item.HoliAcN, "H") + '</span>' +
						'</td>';
				html += '<td>' + AttendUtils.convertSecToStr(item.LateMin, "H") + '</td>' +
						'<td>' + AttendUtils.convertSecToStr(item.EarlyMin, "H") + '</td>' +
						'<td>' + AttendUtils.convertSecToStr(item.AttIdle,"H")+'</td>'+
						'<td><a class="btnTypeDefault btnSearchDetail" data-map=\'' + JSON.stringify(item) + '\' ><spring:message code="Cache.lbl_DetailView"/></a></td>' +
						'</tr>';
				$("#" + tabId + "  table tbody").append(html);
			});
		}
	}
	
	_userMap["StartDate"] = StartDate;
	_userMap["EndDate"] = EndDate;
	
	printDN();
}
</script>	