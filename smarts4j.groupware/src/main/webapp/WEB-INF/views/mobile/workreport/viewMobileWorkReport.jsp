<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<jsp:include page="/WEB-INF/views/cmmn/include_mobile_workreport.jsp"></jsp:include>
<meta http-equiv='cache-control' content='no-cache'> 
<meta http-equiv='expires' content='0'> 
<meta http-equiv='pragma' content='no-cache'>
<style>
	* {
		padding:0px;
		margin:0px;
		box-sizing:border-box;
	}
	
	html {
		font-size : 12px;
	}

	.tdTimeSheet input {
		background:none!important;
		margin : 0px;
		border : none!important;
		border-radius:0!important;
		width : 100%;
		height : 100%;
		box-sizing : border-box;
		padding : 0px;
		outline:none;
	}
	
	.tdTimeSheet div {
		background:none!important;
		margin : 0px;
		border : none!important;
		border-radius:0!important;
		width : 100%;
		height : 100%;
		box-sizing : border-box;
		padding : 0px;
		outline:none;
	}
	
	.divTimeCard {
		margin-bottom : 10px;
	}
	
	.divTimeCard:first-child {
		margin-top : 10px;
	}
	
	
	.txtPlanBox {
		height : 100%!important;
		overflow-y : auto!important;
		box-shadow : none;
		border-radius : none;
	}

</style>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=yes, target-densitydpi=medium-dpi">

<body>
<form>
<div id="divMobileTop" class="">
	<div class="wrap">
		<!-- 상단 tit 시작 -->
	    <div class="sub_top">
	    	<div class="sub_top_title"><a href="#">업무보고</a></div>
	    </div>
	    <!-- 상단 tit 끝 -->
	    
	    <!-- 본문 tit 시작 -->
	    <div data-role="page">
	        <div class="sub_title_box">
	        	<div class="sub_title_left"></div>
	        	<p class="sub_title">
	        		<span id="beforeWeek">
	        			<a href="#" class="ui-btn ui-mini ui-icon-carat-l ui-btn-icon-notext ui-corner-all ui-btn-inline" style="margin : 0px;"></a>
	        		</span>
	        		<span id="titleNm"></span>
	        		<span id="nextWeek">
	        			<a href="#" class="ui-btn ui-mini ui-icon-carat-r ui-btn-icon-notext ui-corner-all ui-btn-inline" style="margin : 0px;"></a>
	        		</span>
	        		
	        		<span style='float:right; display:inline-block; width:40px; height:40px; overflow:hidden; position:relative;'>
	        			<a href="#" onclick="toggleCalendar();" style='position:absolute; top:8px; left:5px; margin:0px;' class="ui-btn ui-corner-all ui-mini ui-icon-calendar ui-btn-icon-notext ui-btn-b ui-btn-inline"></a>
	        			<input type="button" data-role="none" id="datepicker" onChange="changeDate()" value="" style='float:left;width:100%;height:100%;display:inline-block;border:none;background:none;outline:none;visibility:hidden;' />
	        		</span>
	        	</p>
	        </div>
	        <!-- 본문 tit 끝 -->
	        
	        <!-- 본문 시작 -->
	        <div style='padding:5px; box-sizing:border-box;'>
	        	<div class="ui-corner-all custom-corners">
	        	
	        	<div style='width:100%; border: 1px solid #c9c9c9; min-height:50px; background-color : #fff; margin-top : 10px; padding : 5px; box-sizing:border-box;'>
	        		<div class="ui-corner-all custom-corners">
	        		<div class="ui-bar ui-bar-a" style="padding : .7em 1em;">
	        			<div style='height:40px;'>
		        			<h3 style='font-size:1.3rem'>타임시트</h3>
		        			<span style='position : absolute; right : 5px; top : 3px;'>
		        				<a href="#" onclick="toggleTimeCard(this);" class="ui-btn ui-icon-carat-d ui-btn-icon-notext ui-corner-all ui-btn-inline" style='margin : 0px;'></a>
		        				<!-- ui-icon-carat-u 위 화살표     //   ui-icon-carat-d 아래 화살표 -->
		        			</span>
	        			</div>
	        			<div style='width: 100%;'>
	        				<table style='width: 100%; font-size : 1.0rem; border:1px solid #c9c9c9; border-collapse: collapse' border='1'>
	        					<tr style='height:30px; text-align:center; background-color : #f9f9f9;' id="trSummaryHeader">
	        						<th style='width:12%;'></th>
	        						<th style='width:13%;'>금</th>
	        						<th style='width:12%;'>토</th>
	        						<th style='width:13%;'>일</th>
	        						<th style='width:12%;'>월</th>
	        						<th style='width:13%;'>화</th>
	        						<th style='width:12%;'>수</th>
	        						<th style='width:13%;'>목</th>
	        					</tr>
	        					<tr style='height:30px; text-align:center; background-color : #fff;' id="trSummaryBody">
	        						<td>합계</td>
	        						<td id='sumFri'></td>
	        						<td id='sumSat'></td>
	        						<td id='sumSun'></td>
	        						<td id='sumMon'></td>
	        						<td id='sumTue'></td>
	        						<td id='sumWed'></td>
	        						<td id='sumThu'></td>
	        					</tr>
	        				</table>
	        			</div>
	        		</div>
	        		<div id="divTimeCardList" class="ui-body ui-body-a" style="padding:0px 10px 0px 10px;">
	        	
					</div>
	        	</div>
	        </div>
	        
	        <!-- 전주계획 금주실적 차주계획 -->
	        <div style='width:100%; border: 1px solid #c9c9c9; min-height:50px; background-color : #fff; margin-top : 10px; padding : 5px; box-sizing:border-box;'>
	        		<div class="ui-corner-all custom-corners">
	        		<div class="ui-bar ui-bar-a" style="padding : .7em 1em;">
	        			<h3 style='font-size:1.3rem'>보고내용</h3>
	        			<span style='position : absolute; right : 5px; top : 3px;'>
	        				<a href="#" onclick="toggleBaseReport(this);" class="ui-btn ui-icon-carat-d ui-btn-icon-notext ui-corner-all" style='margin : 0px;'></a>
	        				<!-- ui-icon-carat-u 위 화살표     //   ui-icon-carat-d 아래 화살표 -->
	        			</span>
	        		</div>
	        		<div id="divBaseReport" class="ui-body ui-body-a" style="height:630px; padding:0px;">
	        			<!-- 전주계획 -->
	        			<table style="width:100%; height:100%; font-size : 13px; border:1px solid #999; border-collapse: collapse" border="1">
	        				<tr style="height:150px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
	        						전주계획
	        					</th>
	        					<td style="width:80%">
	        						<div id="txtLastWeekPlan" class='txtPlanBox' style='max-width:400px; margin:0px; border:none; overflow:auto;'></div>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
									금
	        					</th>
	        					<td style="width:80%;">
	        						<div id="txtFriReport" class='txtPlanBox' style='margin:0px; border:none; overflow-y:auto;'></div>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
	        						토
	        					</th>
	        					<td style="width:80%;">
	        						<div id="txtSatReport" class='txtPlanBox' style='margin:0px; border:none; overflow-y:auto;'></div>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
									일		
	        					</th>
	        					<td style="width:80%;">
	        						<div id="txtSunReport" class='txtPlanBox' style='margin:0px; border:none; overflow-y:auto;'></div>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
									월	
	        					</th>
	        					<td style="width:80%;">
	        						<div  id="txtMonReport" class='txtPlanBox' style='margin:0px; border:none; overflow-y:auto;'></div>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
									화			
	        					</th>
	        					<td style="width:80%;">
	        						<div  id="txtTueReport" class='txtPlanBox' style='margin:0px; border:none; overflow-y:auto;'></div>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
	        						수
	        					</th>
	        					<td style="width:80%;">
	        						<div  id="txtWedReport" class='txtPlanBox' style='margin:0px; border:none; overflow-y:auto;'></div>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
	        						목
	        					</th>
	        					<td style="width:80%;">
	        						<div id="txtThuReport" class='txtPlanBox' style='margin:0px; border:none; overflow-y:auto;'></div>
	        					</td>
	        				</tr>
	        				<tr style="height:150px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
	        						차주계획
	        					</th>
	        					<td style="width:80%;">
	        						<div id="txtNextWeekPlan" class='txtPlanBox' style='max-width:400px; margin:0px; border:none; overflow:auto;'></div>
	        					</td>	
	        				</tr>
	        			</table>
					</div>
	        	</div>
	        </div>
	        <!-- 실적 끝 -->
	        
	        <!-- 버튼 시작 -->
	        <div>
				<button id="btnModify" type="button" style="display:none;" class="ui-shadow ui-btn ui-btn-b ui-corner-all ui-btn-icon-left ui-icon-check">수정</button>
				<button id="btnReport" type="button" style="display:none;" class="ui-shadow ui-btn ui-btn-b ui-corner-all ui-btn-icon-left ui-icon-check">보고</button>
				<button id="btnCollect" type="button" style="display:none;" class="ui-shadow ui-btn ui-btn-b ui-corner-all ui-btn-icon-left ui-icon-check">회수</button>
	        </div>
	        <!-- 버튼 끝 -->    
	       </div>
		</div>
	</div>
</div>

</form>

<script>
	var g_workReportId = "${workReportID}";
	var g_mode = "${mode}" == "" ? "W" : "${mode}";	
	var settingObj = {};
	
	$(function() {
		$.ajaxSetup({
			cache : false
		});
		
		$(".ui-loader.ui-corner-all.ui-body-a.ui-loader-default").hide();

		$("#datepicker").datepicker({
				dateFormat : "yy-mm-dd",
				monthNames : [ "1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월" ],
				
		});
		
		$.ajaxSetup({
	    	async: false
	   	});
		
		Object.defineProperty(settingObj, "userCode", {
			value : "${userCode}",
			writable : false
		});
		// 달력정보 불러오기
		$.getJSON('../getWorkReportCalendarInfo.do', {calID : '${calid}'}, function(d) {
			// 전역변수 설정
			Object.defineProperty(settingObj, "calendar", {
				value : d.calendar,
				writable : false
			});
			
			$("#datepicker").datepicker("setDate", settingObj.calendar.StartDate);
			
			settingCalendarInfo();
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     mobile_comm_ajaxerror("../getWorkReportCalendarInfo.do", response, status, error);
		});
		
		$.getJSON('../getWorkReportBeforeAndNextCalInfo.do', {calID : settingObj.calendar.CalID}, function(d) {
			var calendarInfo = d.calendar;
			if(calendarInfo.BEFORE > 0) {
				$("#beforeWeek>a").on("click", function() {
					document.location.href = "MobileWorkReport.do?calid=" + calendarInfo.BEFORE
				});
			} else {
				$("#beforeWeek").remove();
			}
			
			if(calendarInfo.NEXT > 0) {
				$("#nextWeek>a").on("click", function() {
					document.location.href = "MobileWorkReport.do?calid=" + calendarInfo.NEXT
				});
			} else {
				$("#nextWeek").remove();
			}
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     mobile_comm_ajaxerror("../getWorkReportBeforeAndNextCalInfo.do", response, status, error);
		});
		
		// 구분세팅 완료 후 
		setLoadTimeSheet();
		
		$.ajaxSetup({
	    	async: true
	   	});
	});
	
	// 달력정보 바인딩
	var settingCalendarInfo = function() {
		var calendar = settingObj.calendar;
		
		// 타이틀 세팅
		$("#titleNm").text("[ " + calendar.Month + "월" + calendar.WeekOfMonth + "주차 ]");
		
		// 타임시트 세팅
		var iDate = new Date(calendar.Year, calendar.Month - 1, calendar.Day);
		
		$("#trSummaryHeader th").eq(1).html((iDate.getDate()) + '<font style="font-size:0.7rem">(금)</font>');
		$("#trSummaryHeader th").eq(2).html((iDate.add(1, "d").getDate()) + '<font style="font-size:0.7rem">(토)</font>');
		$("#trSummaryHeader th").eq(3).html((iDate.add(2, "d").getDate()) + '<font style="font-size:0.7rem">(일)</font>');
		$("#trSummaryHeader th").eq(4).html((iDate.add(3, "d").getDate()) + '<font style="font-size:0.7rem">(월)</font>');
		$("#trSummaryHeader th").eq(5).html((iDate.add(4, "d").getDate()) + '<font style="font-size:0.7rem">(화)</font>');
		$("#trSummaryHeader th").eq(6).html((iDate.add(5, "d").getDate()) + '<font style="font-size:0.7rem">(수)</font>');
		$("#trSummaryHeader th").eq(7).html((iDate.add(6, "d").getDate()) + '<font style="font-size:0.7rem">(목)</font>');
	};
	
	var toggleTimeCard = function(target) {
		if($(target).hasClass("ui-icon-carat-d")) {
			$("#divTimeCardList").animate({height : "0px"}, "fast");
			$(target).removeClass("ui-icon-carat-d").addClass("ui-icon-carat-u");
		} else {
			
			var calHeight = ($("#divTimeCardList>.divTimeCard").length * 135);
			
			$("#divTimeCardList").animate({height : calHeight + "px"}, "fast");
			$(target).removeClass("ui-icon-carat-u").addClass("ui-icon-carat-d");
		}
	};
	
	var toggleBaseReport = function(target) {
		if($(target).hasClass("ui-icon-carat-d")) {
			$("#divBaseReport").animate({height : "0px"}, "fast");
			$(target).removeClass("ui-icon-carat-d").addClass("ui-icon-carat-u");
		} else {
			$("#divBaseReport").animate({height : "630px"}, "fast");
			$(target).removeClass("ui-icon-carat-u").addClass("ui-icon-carat-d");
		}
	};

	
	var addTimeCard = function(pDivisionCode, pJobId, pJobName, pTypeCode, pTypeName, pTimeSheetObj) {
		var divName = pTimeSheetObj.DivisionName;
		
		var targetBox = $("#divTimeCardList");
		var idx = $("#divTimeCardList>.divTimeCard").length;
		var sHTML = "<div style='width:100%; border: 1px solid #c9c9c9; height : 120px;' class='divTimeCard' data-idx='" + idx + "'>";
		sHTML += "<div style='width:100%; background-color : #fff; height: 60px; color:#000; font-weight:bold; font-size:12px; box-sizing:border-box;'>";
		sHTML += "			<div style='width:100%; height:60px; line-height:20px; font-size:0.9rem; text-align:left; box-sizing:border-box;'>";
		
		var strSelectText = "<div style='width:100%; height:20px; box-sizing:border-box; padding:0px 5px 0px 5px; overflow:hidden; ";
		strSelectText += "text-overflow: ellipsis; white-space: nowrap;'>구분 : ";
		strSelectText += divName + "</div>";
		
		strSelectText += "<div style='width:100%; height:20px; box-sizing:border-box; padding:0px 5px 0px 5px; overflow:hidden; ";
		strSelectText += "text-overflow: ellipsis; white-space: nowrap;'>업무 : ";
		strSelectText += pJobName + "</div>";
		
		strSelectText += "<div style='width:100%; height:20px; box-sizing:border-box; padding:0px 5px 0px 5px; overflow:hidden; ";
		strSelectText += "text-overflow: ellipsis; white-space: nowrap;'>분류 : ";
		strSelectText += pTypeName + "</div>";
		
		sHTML += "<span id='spnTimeSheetSelectValues'>";
		sHTML += strSelectText;
		sHTML += "</span>";

		
		sHTML += "			</div>";
		sHTML += "		</div>";
		sHTML += "		<div style='width:100%;'>";
		sHTML += "			<table class='tbTimeSheetHour' style='width: 100%; font-size : 13px; border:1px solid #c9c9c9; border-collapse: collapse' border='1'>";
		sHTML += "				<tr style='text-align:center; height:30px; background-color : #f9f9f9; color: #000;'>";
		
		// 타임시트 세팅
		var iDate = new Date(settingObj.calendar.Year, settingObj.calendar.Month - 1, settingObj.calendar.Day);
		sHTML += "					<th>" + (iDate.getDate()) + "<font style='font-size:0.7rem'>(금)</font></th>";
		sHTML += "					<th>" + (iDate.add(1, "d").getDate()) + "<font style='font-size:0.7rem'>(토)</font></th>";
		sHTML += "					<th>" + (iDate.add(2, "d").getDate()) + "<font style='font-size:0.7rem'>(일)</font></th>";
		sHTML += "					<th>" + (iDate.add(3, "d").getDate()) + "<font style='font-size:0.7rem'>(월)</font></th>";
		sHTML += "					<th>" + (iDate.add(4, "d").getDate()) + "<font style='font-size:0.7rem'>(화)</font></th>";
		sHTML += "					<th>" + (iDate.add(5, "d").getDate()) + "<font style='font-size:0.7rem'>(수)</font></th>";
		sHTML += "					<th>" + (iDate.add(6, "d").getDate()) + "<font style='font-size:0.7rem'>(목)</font></th>";
		
		
		sHTML += "				</tr>";
		sHTML += "				<tr style='text-align:center; height:30px; text-align:center;'>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='fri timebox' value='' style='text-align:center;' readonly />";
		sHTML += "					</td>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='sat timebox' value='' style='text-align:center;' readonly />";
		sHTML += "					</td>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='sun timebox' value='' style='text-align:center;' readonly />";
		sHTML += "					</td>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='mon timebox' value='' style='text-align:center;' readonly />";
		sHTML += "					</td>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='tue timebox' value='' style='text-align:center;' readonly />";
		sHTML += "					</td>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='wed timebox' value='' style='text-align:center;' readonly />";
		sHTML += "					</td>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='thu timebox' value='' style='text-align:center;' readonly />";
		sHTML += "					</td>";
		sHTML += "				</tr>";
		sHTML += "			</table>";
		sHTML += "		</div>";
		sHTML += "	</div>";
		
		targetBox.prepend(sHTML);
		
		var registObj = targetBox.find(".divTimeCard").eq(0);

		if(pTimeSheetObj) {
			registObj.find(".tdTimeSheet input").eq(0).val(pTimeSheetObj.FRI.toFixed(1));
			registObj.find(".tdTimeSheet input").eq(1).val(pTimeSheetObj.SAT.toFixed(1));
			registObj.find(".tdTimeSheet input").eq(2).val(pTimeSheetObj.SUN.toFixed(1));
			registObj.find(".tdTimeSheet input").eq(3).val(pTimeSheetObj.MON.toFixed(1));
			registObj.find(".tdTimeSheet input").eq(4).val(pTimeSheetObj.TUE.toFixed(1));
			registObj.find(".tdTimeSheet input").eq(5).val(pTimeSheetObj.WED.toFixed(1));
			registObj.find(".tdTimeSheet input").eq(6).val(pTimeSheetObj.THU.toFixed(1));
		}
		
		var calHeight = ($("#divTimeCardList>.divTimeCard").length * 135);
		
		targetBox.css({height : calHeight + "px"});
		
	};
		
	var setLoadTimeSheet = function() {
		// 기초 보고 정보
		$.getJSON('../getWorkReportBaseReport.do', {calID : settingObj.calendar.CalID, workReportID : g_workReportId, userCode : settingObj.userCode}, function(d) {
			var baseReport = d.baseReport;
			
			Object.defineProperty(settingObj, "state", {
				value : baseReport.State,
				writable : false
			});	
			
			
			// 버튼 정리
			if(baseReport.State == "W" ||baseReport.State == "R") {
				// 작성중, 거부 상태에서 수정, 보고 버튼만 활성화
				$("#btnModify").css("display", "")
							   .on("click", function() {
								   document.location.href = "regMobileWorkReport.do?wrid=" + g_workReportId + "&mode=M&calid=" + settingObj.calendar.CalID
							   });
				$("#btnReport").css("display", "")
							   .on("click", function() {
								   var result = confirm('보고하시겠습니까?'); 
								   if(result) {
									   $.post("../reportWorkReport.do", {workReportId : g_workReportId, currentState : settingObj.state, userCode : settingObj.userCode, calId : settingObj.calendar.CalID }, function(d) {	
											if(d.result == "FAIL") {
												alert(d.message);
											}else if(d.result == "OK") {
												// 성공시 페이지 reload
												document.location.reload();
											}
										});
								   }
							   }).error(function(response, status, error){
								     //TODO 추가 오류 처리
								     mobile_comm_ajaxerror("../reportWorkReport.do", response, status, error);
								});
				$("#btnCollect").remove();
			} else if(baseReport.State == "I"){
				// 승인요청상태에선 회수 버튼만 활성화
				$("#btnCollect").css("display", "")
								.on("click", function() {
									var result = confirm('회수하시겠습니까?');
									if(result) {
										$.post("../collectWorkReport.do", {workReportId : g_workReportId, currentState : settingObj.state, userCode : settingObj.userCode }, function(d) {
											if(d.result == "FAIL") {
												alert(d.message);
											}else if(d.result == "OK") {
												// 성공시 페이지 reload
												document.location.reload();
											}
										}).error(function(response, status, error){
										     //TODO 추가 오류 처리
										     mobile_comm_ajaxerror("../collectWorkReport.do", response, status, error);
										});
									}
							   });
				$("#btnModify").remove();
				$("#btnReport").remove();
			} else {
				// 승인상태에선 모든 버튼 제거
				$("#btnModify").remove();
				$("#btnReport").remove();
				$("#btnCollect").remove();
			}

			
			// 직전주의 차주계획 불러와서 맵핑
			$.getJSON('../getLastWeekPlan.do', {calID : settingObj.calendar.CalID, userCode : settingObj.userCode}, function(d) {		
				var lastWeekPlan = d.lastWeekPlan;
				if(lastWeekPlan.CNT > 0) {					
					// MigData중 HTML로 시작하는 내용은 치환없이 그대로 보여줌
					var flagMig = false;
					var isEditorContext = false;
					var editorRegx = new RegExp(/<html/img);
					flagMig = lastWeekPlan.MigWorkreportID > 0;
					isEditorContext = editorRegx.test(lastWeekPlan.LastWeekPlan);
										
					if(flagMig && isEditorContext) {
						$("#txtLastWeekPlan").html(lastWeekPlan.LastWeekPlan.replace(/(<style[^>]*>)([^<].|[^<]\s)*(<\/style>)/gmi, ''));
					} else {
						$("#txtLastWeekPlan").html(lastWeekPlan.LastWeekPlan.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
					}
				}
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     mobile_comm_ajaxerror("../getLastWeekPlan.do", response, status, error);
			});
			
			
			// 기본 정보 세팅
			
			var flagMig = false;
			var isEditorContext = false;
			var editorRegx = new RegExp(/<html/img);
			flagMig = baseReport.MigWorkreportID > 0;
			isEditorContext = editorRegx.test(baseReport.NextWeekPlan);
								
			if(flagMig && isEditorContext) {
				$("#txtNextWeekPlan").html(baseReport.NextWeekPlan.replace(/(<style[^>]*>)([^<].|[^<]\s)*(<\/style>)/gmi, ''));
			} else {
				$("#txtNextWeekPlan").html(baseReport.NextWeekPlan.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
			}
			
			if(flagMig) {
				$("#btnModify").remove();
				$("#btnReport").remove();
				$("#btnCollect").remove();
				
				$("#txtMonReport").parents("tr").eq(0).remove();
				$("#txtTueReport").parents("tr").eq(0).remove();
				$("#txtWedReport").parents("tr").eq(0).remove();
				$("#txtThuReport").parents("tr").eq(0).remove();
				$("#txtFriReport").parents("tr").eq(0).remove();
				$("#txtSatReport").parents("tr").eq(0).remove();
				$("#txtSunReport").parents("tr").eq(0).remove();
			} else {
				// $("#txtLastWeekPlan").val(baseReport.LastWeekPlan);			
				$("#txtMonReport").html(baseReport.MonDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				$("#txtTueReport").html(baseReport.TuesDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				$("#txtWedReport").html(baseReport.WedDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				$("#txtThuReport").html(baseReport.ThuDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				$("#txtFriReport").html(baseReport.FriDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				$("#txtSatReport").html(baseReport.SatDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				$("#txtSunReport").html(baseReport.SunDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
			}
			
			// 파라미터로 넘어온 값들이 읽을 수 있는 값인경우 TimeSheet 정보 Load
			if(baseReport.WorkReportID == g_workReportId) {
				// 타임시트 정보
				$.getJSON('../getWorkReportTimeSheetReport.do', {workReportID : g_workReportId, calID : settingObj.calendar.CalID}, function(d) {
					
					var timeSheets = d.timeSheetReport;
					// 반복
					timeSheets.forEach(function(d) {
						var dateHourInfo = {};
						
						addTimeCard(d.DivisionCode, d.JobID, d.JobName, d.TypeCode, d.TypeName, d);
					});
					
					// 합계 계산
					calSummary();
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     mobile_comm_ajaxerror("../getWorkReportTimeSheetReport.do", response, status, error);
				});				
			}
		});
	}
	
	var calSummary = function() {
		// DaySummary
		var weekSumBoxs = $("#trSummaryBody td[id^='sum']");
		weekSumBoxs.each(function(idx, d) {
			var target = $(d);
			var idName = target.attr("id").substr(3);	// sum 제거-
			idName = idName.substring(0,1).toLowerCase() + idName.substring(1);
			
			
			var dayOfTime = 0;
			
			$("." + idName).each(function(i, timeObj) {
				var time = $(timeObj).val();
				dayOfTime += parseFloat((time == "" ? 0 : time));
			});
			
			target.text(dayOfTime.toFixed(1));
		});
	};
	
	var toggleCalendar = function() {
		$("#datepicker").datepicker("show");
	};
	
	var changeDate = function() {
		var dateVal = $("#datepicker").val();
		
		$.getJSON('../getWorkReportDateInfo.do', {date : dateVal}, function(d) {
			var calendarInfo = d.calendar;
			if(calendarInfo.CalID > 0) {
				document.location.href = "MobileWorkReport.do?calid=" + calendarInfo.CalID
			} else {
				alert('조회할 수 없는 기간입니다.');
			}
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     mobile_comm_ajaxerror("../getWorkReportDateInfo.do", response, status, error);
		});	
	};
	
</script>

</body>