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
	        	
	        	<div id="divTimeSheetSelectBox" data-role="popup" data-theme="a" class="ui-corner-all" data-dismissible="false">
	        		<div>
		        		<div class="ui-bar ui-bar-a" style="padding : .7em 1em;">
		        			<h3>구분 / 업무 / 분류 설정</h3>
		        			<span style='position : absolute; right : 5px; top : 3px;'>
	        					<a href="#" onclick="closeSelectPop();" class="ui-btn ui-icon-delete ui-btn-icon-notext ui-corner-all ui-btn-inline" style='margin : 0px;'></a>
	        				</span>
		        		</div>
			        	<div class="ui-body ui-body-a">
							<select id="selDivision">
								<option value="">구분을 선택하세요</option>
							</select>
							
							<select id="selJob">
								<option value="">업무를 선택하세요</option>
							</select>
							
							
							<select id="selType">
								<option value="">분류를 선택하세요</option>
							</select>
							
							<button type="button" onclick="submitSelectVal()" class="ui-shadow ui-btn ui-btn-b ui-corner-all ui-btn-icon-left ui-icon-check">적용</button>
			        	</div>
		        	</div>
	        	</div>
	        	
	        	<div id="divTimeSheetSelectBoxWrap" style='position:absolute; top:0px; left:0px; width:100%; height:100%; background-color : rgba(245, 245, 245, .8); z-index:10; display: none;'>
					<div id="divTimeSheetSelectBox" style="position:relative; height:260px;">
		        		<div style='margin : 0px auto;'>
			        		<div class="ui-bar ui-bar-a" style="padding : .7em 1em;">
			        			<h3>구분 / 업무 / 분류 설정</h3>
			        			<span style='position : absolute; right : 5px; top : 3px;'>
		        					<a href="#" onclick="closeSelectPop();" class="ui-btn ui-icon-delete ui-btn-icon-notext ui-corner-all ui-btn-inline" style='margin : 0px;'></a>
		        				</span>
			        		</div>
				        	<div class="ui-body ui-body-a">
								<select id="selDivision">
									<option value="">구분을 선택하세요</option>
								</select>
								
								<select id="selJob">
									<option value="">업무를 선택하세요</option>
								</select>
								
								
								<select id="selType">
									<option value="">분류를 선택하세요</option>
								</select>
								
								<button type="button" onclick="submitSelectVal()" class="ui-shadow ui-btn ui-btn-b ui-corner-all ui-btn-icon-left ui-icon-check">적용</button>
				        	</div>
			        	</div>
		        	</div>
	        	</div>
	        	
	        	<div style='width:100%; border: 1px solid #c9c9c9; min-height:50px; background-color : #fff; margin-top : 10px; padding : 5px; box-sizing:border-box;'>
	        		<div class="ui-corner-all custom-corners">
	        		<div class="ui-bar ui-bar-a" style="padding : .7em 1em;">
	        			<div style='height:40px;'>
		        			<h3 style='font-size:1.3rem'>타임시트</h3>
		        			<span style='position : absolute; right : 5px; top : 3px;'>
		        				<button type="button" onclick="addTimeCard();" class="ui-shadow ui-btn ui-corner-all ui-btn-icon-left ui-icon-plus ui-btn-inline ui-mini" style="margin:0px;">
		        					추가
		        				</button>
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
	        					<td style="width:80%; background-color : #f0f0f0;">
	        						<div id="txtLastWeekPlan" class='txtPlanBox' style='max-width:400px; margin:0px; border:none; overflow:auto; background-color : #f0f0f0;'></div>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
									금
	        					</th>
	        					<td style="width:80%;">
	        						<textarea id="txtFriReport" class='txtPlanBox' style='margin:0px; border:none; resize:none; outline:none; overflow-y:auto;'></textarea>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
	        						토
	        					</th>
	        					<td style="width:80%;">
	        						<textarea id="txtSatReport" class='txtPlanBox' style='margin:0px; border:none; resize:none; outline:none; overflow-y:auto;'></textarea>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
									일		
	        					</th>
	        					<td style="width:80%;">
	        						<textarea id="txtSunReport" class='txtPlanBox' style='margin:0px; border:none; resize:none; outline:none; overflow-y:auto;'></textarea>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
									월	
	        					</th>
	        					<td style="width:80%;">
	        						<textarea  id="txtMonReport" class='txtPlanBox' style='margin:0px; border:none; resize:none; outline:none; overflow-y:auto;'></textarea>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
									화			
	        					</th>
	        					<td style="width:80%;">
	        						<textarea  id="txtTueReport" class='txtPlanBox' style='margin:0px; border:none; resize:none; outline:none; overflow-y:auto;'></textarea>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
	        						수
	        					</th>
	        					<td style="width:80%;">
	        						<textarea  id="txtWedReport" class='txtPlanBox' style='margin:0px; border:none; resize:none; outline:none; overflow-y:auto;'></textarea>
	        					</td>
	        				</tr>
	        				<tr style="height:35px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
	        						목
	        					</th>
	        					<td style="width:80%;">
	        						<textarea id="txtThuReport" class='txtPlanBox' style='margin:0px; border:none; resize:none; outline:none; overflow-y:auto;'></textarea>
	        					</td>
	        				</tr>
	        				<tr style="height:150px;">
	        					<th style="width:20%; text-align:center; background-color : #f1f1f1; color : #000;">
	        						차주계획
	        					</th>
	        					<td style="width:80%;">
	        						<textarea id="txtNextWeekPlan" class='txtPlanBox' style='margin:0px; border:none; resize:none; outline:none; overflow-y:auto;'></textarea>
	        					</td>	
	        				</tr>
	        			</table>
					</div>
	        	</div>
	        </div>
	        <!-- 실적 끝 -->
	        
	        <!-- 버튼 시작 -->
	        <div>
				<button id="btnSave" type="button" onclick="saveWorkReport();" class="ui-shadow ui-btn ui-btn-b ui-corner-all ui-btn-icon-left ui-icon-check">저장</button>
				<button id="btnCancle" type="button" onclick="returnViewPage();" style="display:none;" class="ui-shadow ui-btn ui-corner-all ui-btn-icon-left ui-icon-carat-l">취소</button>
	        </div>
	        <!-- 버튼 끝 -->    
	       </div>
		</div>
	</div>
</div>
</div>
</form>

<script>
	var g_workReportId = "${workReportID}";
	var g_selectedBox = "";
	var g_maxIdx = 0;
	var g_mode = "${mode}" == "" ? "W" : "${mode}";	
	var settingObj = {};
	
	$(function() {
		$.ajaxSetup({
			cache : false
		});
		
		$(".ui-loader.ui-corner-all.ui-body-a.ui-loader-default").hide();
		
		
		// 버튼 정리
		if(g_mode == "M") {
			$("#btnCancle").css("display", "");
		} else {
			$("#btnCancle").remove();
		}
		
		$("#datepicker").datepicker({
			dateFormat : "yy-mm-dd",
			monthNames : [ "1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월" ],
			
		});
		
		// selectBox Width Setting
		// $("#divTimeSheetSelectBox>div").css("width", $("body").width() - 20);
		$("#divTimeSheetSelectBox>div").css("width", $("body").width() - 20);
		
		$("#selDivision").on("change", function(event, isInitTrigger) {		
			var division = $(this).val();
			
			var selJobObj = $("#selJob");
			var selTypeObj = $("#selType");
			
			// 초기화
			selJobObj.empty().append('<option value="">업무를 선택하세요</option>');
			selTypeObj.empty().append('<option value="">분류를 선택하세요</option>');
						
			if(division != "") {
				var spnSelValueBox = $("div[data-idx='" + g_selectedBox + "'] #spnTimeSheetSelectValues");
				
				// 바인딩 (업무)
				$.getJSON('../getworkjob.do', {division : division}, function(d) {
					d.list.forEach(function(d) {
						selJobObj.append('<option value="' + d.JobID + '">' + d.JobName + '</option>');
					});
					
					if(isInitTrigger) {
						var job = spnSelValueBox.attr("data-job");
						$("#selJob").val(job).trigger("change");
					} else {
						$("#selJob").val("").trigger("change");
					}
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     mobile_comm_ajaxerror("../getworkjob.do", response, status, error);
				});
				
				$.getJSON('../getWorkReportTypeSel.do', {code : division}, function(d) {
					d.list.forEach(function(d) {
						selTypeObj.append('<option value="' + d.code + '">' + d.name + '</option>');
					});
					
					if(isInitTrigger) {
						var type = spnSelValueBox.attr("data-type");
						$("#selType").val(type).trigger("change");
					} else {
						$("#selType").val("").trigger("change");
					}
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     mobile_comm_ajaxerror("../getWorkReportTypeSel.do", response, status, error);
				});
			} else {
				$("#selType").val("").trigger("change");
				$("#selJob").val("").trigger("change");
			}
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
		
		// 최초 구분 세팅
		$.getJSON('../getWorkReportDiv.do', {}, function(d) {
			var obj = $("#selDivision");
			obj.empty();
			obj.append('<option value="">구분을 선택하세요</option>');
			d.list.forEach(function(d) {
				obj.append('<option value="' + d.code + '">' + d.name + '</option>');
			});
			
			// 구분세팅 완료 후 
			setLoadTimeSheet();
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     mobile_comm_ajaxerror("../getWorkReportDiv.do", response, status, error);
		});
		
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
			
			var calHeight = ($("#divTimeCardList>.divTimeCard").length * 175);
			
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
	
	/*
	var openSelectBox = function(idx) {
		g_selectedBox = idx;
		
		var spnSelValueBox = $("div[data-idx='" + g_selectedBox + "'] #spnTimeSheetSelectValues");
		
		var division = spnSelValueBox.attr("data-division");
		
		$("#selDivision").val(division).trigger("change", [true]);
	};
	*/
	
	var openSelectBox = function(idx) {
		var currentTop = (($(window)[0].innerHeight / 2) - ($("#divTimeSheetSelectBox").height()/2)) + $(window).scrollTop();
		
		$("#divTimeSheetSelectBox").css("top", currentTop + "px");
		
		g_selectedBox = idx;
		
		var spnSelValueBox = $("div[data-idx='" + g_selectedBox + "'] #spnTimeSheetSelectValues");
		
		var division = spnSelValueBox.attr("data-division");
		
		$("#selDivision").val(division).trigger("change", [true]);
		
		
		$("#divTimeSheetSelectBoxWrap").css("display", "block");
	};
	
	var submitSelectVal = function() {
		var division = $("#selDivision").val();
		var job = $("#selJob").val();
		var type = $("#selType").val();
		
		if(division == "" || job == "" || type == "") {
			alert('선택되지 않은 값이 있습니다.');
			return false;
		}
		
		var isFlag = false;
		
		$(".selectValues").each(function(idx, d) {
			var regDiv = $(d).attr("data-division");
			var regJob = $(d).attr("data-job");
			var regType = $(d).attr("data-type");
			
			if(division == regDiv && job == regJob && type == regType) {
				alert('이미 등록된 업무입니다.');
				isFlag = true;
				return false;
			}
		});
		
		if(isFlag) {
			return false;
		}
		
		
		var divisionText = $("#selDivision>option:selected").text();
		var jobText = $("#selJob>option:selected").text();
		var typeText = $("#selType>option:selected").text();
				
		var strSelectText = "<div style='width:100%; height:20px; box-sizing:border-box; padding:0px 5px 0px 5px; overflow:hidden; ";
		strSelectText += "text-overflow: ellipsis; white-space: nowrap;'>구분 : ";
		strSelectText += divisionText + "</div>";
		
		strSelectText += "<div style='width:100%; height:20px; box-sizing:border-box; padding:0px 5px 0px 5px; overflow:hidden; ";
		strSelectText += "text-overflow: ellipsis; white-space: nowrap;'>업무 : ";
		strSelectText += jobText + "</div>";
		
		strSelectText += "<div style='width:100%; height:20px; box-sizing:border-box; padding:0px 5px 0px 5px; overflow:hidden; ";
		strSelectText += "text-overflow: ellipsis; white-space: nowrap;'>분류 : ";
		strSelectText += typeText + "</div>";
		
		var spnSelValueBox = $("div[data-idx='" + g_selectedBox + "'] #spnTimeSheetSelectValues");
		spnSelValueBox.html(strSelectText)
					  .attr("data-division", division)
					  .attr("data-job", job)
					  .attr("data-type", type);
		
		// $("#divTimeSheetSelectBox").popup("close");
		$("#divTimeSheetSelectBox").parents("#divTimeSheetSelectBoxWrap").css("display", "none");
	};
	
	var closeSelectPop = function() {
		// $("#divTimeSheetSelectBox").popup("close");
		$("#divTimeSheetSelectBox").parents("#divTimeSheetSelectBoxWrap").css("display", "none");
	};
	
	var deleteTimeCard = function(target) {
		var boxObj = $(target).parents(".divTimeCard");
		
		boxObj.remove();
		var currentHeight = parseInt($("#divTimeCardList").css("height"));
		
		$("#divTimeCardList").css("height", currentHeight - 175 + "px");
		calSummary();
	};
	
	var addTimeCard = function(pDivisionCode, pJobId, pJobName, pTypeCode, pTypeName, pTimeSheetObj) {
		var divName = "";
		// JobId가 넘어온 경우
		if(pJobId && pDivisionCode) {
			// 업무 select box 확인
			var divSel = $("#selDivision");
			if(divSel.find("option[value='" + pDivisionCode + "']").length > 0) {
				divName = divSel.find("option[value='" + pDivisionCode + "']").text();
			}
		}
		
		var targetBox = $("#divTimeCardList");
		var idx = g_maxIdx++; //$("#divTimeCardList>.divTimeCard").length;
		var sHTML = "<div style='width:100%; border: 1px solid #c9c9c9; height : 160px;' class='divTimeCard' data-idx='" + idx + "'>";
		sHTML += "<div style='width:100%; background-color : #fff; height: 100px; color:#000; font-weight:bold; font-size:12px; box-sizing:border-box;'>";
		sHTML += "<div style='height:40px; position:relative; background-color : #f1f1f1'>";
		sHTML += "				<span style='position : absolute; left : 0px; top : 0px;'>";
		// sHTML += "					<a href='#divTimeSheetSelectBox' onclick='openSelectBox(" + idx + ");' data-rel='popup' data-position-to='window' class='ui-shadow ui-btn ui-corner-all ui-btn-icon-left ui-icon-gear ui-mini' style='margin:0px;'>구분 / 업무 / 분류 설정</a>";
		sHTML += "					<a href='javascript:openSelectBox(" + idx + ");' class='ui-shadow ui-btn ui-corner-all ui-btn-icon-left ui-icon-gear ui-mini' style='margin:0px;'>구분 / 업무 / 분류 설정</a>";
		sHTML += "				</span>";
		sHTML += "				<span style='position : absolute; right : 3px; top : 3px;'>";
		sHTML += "					<a href='#' onclick='deleteTimeCard(this);' class='ui-btn ui-icon-delete ui-btn-icon-notext ui-corner-all ui-mini' style='margin:0px;'></a>";
        sHTML += "				</span>";
		sHTML += "			</div>";
		sHTML += "			<div style='width:100%; height:60px; line-height:20px; font-size:0.9rem; text-align:left; box-sizing:border-box;'>";
		if(divName != "" && pJobId != "" && pTypeCode != "") {
			// var strSelectText = divName + " > " + pJobName + " [ " + pTypeName + " ]";
			var strSelectText = "<div style='width:100%; height:20px; box-sizing:border-box; padding:0px 5px 0px 5px; overflow:hidden; ";
			strSelectText += "text-overflow: ellipsis; white-space: nowrap;'>구분 : ";
			strSelectText += divName + "</div>";
			
			strSelectText += "<div style='width:100%; height:20px; box-sizing:border-box; padding:0px 5px 0px 5px; overflow:hidden; ";
			strSelectText += "text-overflow: ellipsis; white-space: nowrap;'>업무 : ";
			strSelectText += pJobName + "</div>";
			
			strSelectText += "<div style='width:100%; height:20px; box-sizing:border-box; padding:0px 5px 0px 5px; overflow:hidden; ";
			strSelectText += "text-overflow: ellipsis; white-space: nowrap;'>분류 : ";
			strSelectText += pTypeName + "</div>";
			
			sHTML += "<span id='spnTimeSheetSelectValues' class='selectValues' data-division='" + pDivisionCode + "' data-job='" + pJobId + "' data-type='" + pTypeCode + "'>";
			sHTML += strSelectText;
			sHTML += "</span>";
		} else { 
			sHTML += "<span id='spnTimeSheetSelectValues' class='selectValues' data-division='' data-job='' data-type='' style='display: inline-block; text-align: center; width: 100%;'>";
			sHTML += "<font style='color:red;'>구분 / 업무 / 분류를 설정해 주세요!</font></span>";
		}
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
		sHTML += "						<input type='text' class='fri timebox' onkeyup='writeHour(this)' value='' style='text-align:center;'/>";
		sHTML += "					</td>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='sat timebox' onkeyup='writeHour(this)' value='' style='text-align:center;' />";
		sHTML += "					</td>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='sun timebox' onkeyup='writeHour(this)' value='' style='text-align:center;' />";
		sHTML += "					</td>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='mon timebox' onkeyup='writeHour(this)' value='' style='text-align:center;' />";
		sHTML += "					</td>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='tue timebox' onkeyup='writeHour(this)' value='' style='text-align:center;' />";
		sHTML += "					</td>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='wed timebox' onkeyup='writeHour(this)' value='' style='text-align:center;' />";
		sHTML += "					</td>";
		sHTML += "					<td style='width:14%' class='tdTimeSheet'>";
		sHTML += "						<input type='text' class='thu timebox' onkeyup='writeHour(this)' value='' style='text-align:center;' />";
		sHTML += "					</td>";
		sHTML += "				</tr>";
		sHTML += "			</table>";
		sHTML += "		</div>";
		sHTML += "	</div>";
		
		targetBox.prepend(sHTML);
		
		var registObj = targetBox.find(".divTimeCard").eq(0);
		// 수정모드의 경우
		if(g_mode == "M") {
			if(pTimeSheetObj) {
				registObj.find(".tdTimeSheet input").eq(0).val(pTimeSheetObj.FRI.toFixed(1));
				registObj.find(".tdTimeSheet input").eq(1).val(pTimeSheetObj.SAT.toFixed(1));
				registObj.find(".tdTimeSheet input").eq(2).val(pTimeSheetObj.SUN.toFixed(1));
				registObj.find(".tdTimeSheet input").eq(3).val(pTimeSheetObj.MON.toFixed(1));
				registObj.find(".tdTimeSheet input").eq(4).val(pTimeSheetObj.TUE.toFixed(1));
				registObj.find(".tdTimeSheet input").eq(5).val(pTimeSheetObj.WED.toFixed(1));
				registObj.find(".tdTimeSheet input").eq(6).val(pTimeSheetObj.THU.toFixed(1));
			}
		}
		
		var calHeight = ($("#divTimeCardList>.divTimeCard").length * 175);
		
		targetBox.css({height : calHeight + "px"});
		
	};
	
	var convertOutputValue = function(pValue) {
		pValue = pValue.replace(/&amp;/img, "&");
	    pValue = pValue.replace(/&lt;/img, "<");
	    pValue = pValue.replace(/&gt;/img, ">");
	    pValue = pValue.replace(/&quot;/img, "\"");
	    pValue = pValue.replace(/&apos;/img, "'");
	    pValue = pValue.replace(/&#x2F;/img, "\\");
	    pValue = pValue.replace(/&nbsp;/img, " ");
	    
	    return pValue;
	};
	
	
	var setLoadTimeSheet = function() {
		// 나의 업무 세팅 or default row 세팅
		if(g_mode == 'M') {
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
			
			// 수정모드에선 기존내용 불러와서 맵핑
			// 기초 보고 정보
			$.getJSON('../getWorkReportBaseReport.do', {calID : settingObj.calendar.CalID, workReportID : g_workReportId, userCode : settingObj.userCode}, function(d) {
				var baseReport = d.baseReport;
				// 기본 정보 세팅
				// $("#txtLastWeekPlan").val(baseReport.LastWeekPlan);
				$("#txtNextWeekPlan").val(convertOutputValue(baseReport.NextWeekPlan));
				$("#txtMonReport").val(convertOutputValue(baseReport.MonDayReport));
				$("#txtTueReport").val(convertOutputValue(baseReport.TuesDayReport));
				$("#txtWedReport").val(convertOutputValue(baseReport.WedDayReport));
				$("#txtThuReport").val(convertOutputValue(baseReport.ThuDayReport));
				$("#txtFriReport").val(convertOutputValue(baseReport.FriDayReport));
				$("#txtSatReport").val(convertOutputValue(baseReport.SatDayReport));
				$("#txtSunReport").val(convertOutputValue(baseReport.SunDayReport));
				
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
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     mobile_comm_ajaxerror("../getWorkReportBaseReport.do", response, status, error);
			});	
		} else if(g_mode == "W") {
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
			
			// 나의 업무 세팅 맵핑
			// 자기자신의 업무 등록 시 
			$.getJSON('../myworksettingmyjob.do',{}, function(d) {
				var list = d.list;
				// 설정된 나의업무가 없다면
				if(list.length == 0) {
					addTimeCard();
				} else {
					list.forEach(function(mywork) {
						addTimeCard(mywork.JobDivision, mywork.JobID, mywork.JobName, mywork.TypeCode, mywork.DisplayName);
					});
				}
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     mobile_comm_ajaxerror("../myworksettingmyjob.do", response, status, error);
			});
		}
	}
	
	
	var writeHour = function(obj) {
		// Validation Chk
		var inputKey = event.key;
		var inputBox = $(obj);
		var value = inputBox.val();
		
		
		if(_ie) {
			if(inputKey == "Decimal")
				inputKey = ".";
		}
		
		// 숫자 및 소수점이 아닌 문자 치환
		value = value.replace(/[^0-9.]/g, '');
		
		value = value == "" ? "0" : value;

		// 숫자형식으로 변경
		// 숫자형식이거나 event에 바인딩되어 넘어오지 않은경우
		if(inputKey != ".") {
			//반올림 첫번째자리까지			
			value = parseFloat(value);
			
			
			// 23이상의 숫자의 경우 23으로 변경
			value = value > 24 ? 24 : value;
			
			inputBox.val(value);
			
			calSummary();
			
		} else if(inputKey == ".") {
			inputBox.val(value);
		}
		return false;
	};
	
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
	
	
	// 저장
	var saveWorkReport = function() {
		// Validation Check
		var chkFlag = false;
		
		if($(".divTimeCard").length <= 0) {
			alert("최소 1개의 업무가 선택되야 합니다.");
			return false;
		}
		
		$(".divTimeCard").each(function(idx, d) {
			var targetObj = $(d);
			var strDivisionCode = targetObj.find("#spnTimeSheetSelectValues").attr("data-division");	// 업무 구분
			var strJobId = targetObj.find("#spnTimeSheetSelectValues").attr("data-job");			// 업무
			var strJobType = targetObj.find("#spnTimeSheetSelectValues").attr("data-type");			// 업무 분류
			
			if(strDivisionCode == "") {
				alert("업무구분이 선택되지 않았습니다.");
				chkFlag = true;
				return false;
			}
			else if (strJobId == "") {
				alert("업무가 선택되지 않았습니다.");
				chkFlag = true;
				return false;
			}
			else if (strJobType == "") {
				alert("업무분류가 선택되지 않았습니다.");
				chkFlag = true;
				return false;
			}
		});
		
		if(chkFlag) {
			return false;
		}
		
		// JSON Object 생성 ( Parameters )
		var jsonParam = {};
		
		// 기본데이터
		// workReportID 바인딩 ( 없을경우 최초입력으로 판단 )
		jsonParam.workReportId = g_workReportId;
		
		// 보고내용
		jsonParam.lastWeekPlan = $("#txtLastWeekPlan").val();
		jsonParam.nextWeekPlan = $("#txtNextWeekPlan").val();
		jsonParam.friReport = $("#txtFriReport").val();
		jsonParam.satReport = $("#txtSatReport").val();
		jsonParam.sunReport = $("#txtSunReport").val();
		jsonParam.monReport = $("#txtMonReport").val();
		jsonParam.tueReport = $("#txtTueReport").val();
		jsonParam.wedReport = $("#txtWedReport").val();
		jsonParam.thuReport = $("#txtThuReport").val();
		
		// 주차코드
		jsonParam.calId = settingObj.calendar.CalID
		
		// 사용자 아이디는 선택된 경우에만 채워서 보냄
		jsonParam.creator = settingObj.userCode;
		
		
		 $.ajaxSetup({
	     	async: false
	   	 });
		
		// 사용자 등급 구해서 채워넣음 - 사용자등급은 최초 등록시에만 적용됨.
		$.getJSON("../getWorkReportGrade.do", {userid : jsonParam.creator}, function(d) {
			jsonParam.jobPositionCode = d.grade.JobPositionCode;
			jsonParam.memberType = d.grade.MemberType;
			jsonParam.gradeKind = d.grade.GradeKind;
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     mobile_comm_ajaxerror("../getWorkReportGrade.do", response, status, error);
		});
		
		$.ajaxSetup({
		   	async: true
		});	
		
		
		// 보안 관련 처리 필요 (escape 문자열 처리 등)
		
		
		// 타임시트 데이터
		var timeSheets = getTimeSheetJSON();
		
		if(timeSheets == null) {
			alert("잘못된 입력이 존재합니다.");
			return false;
		}
		
		timeSheets.unshift(jsonParam);
		
		// WorkReportID 값이 없을경우 저장 그 외 수정으로 처리
		var nWorkReportId = parseInt(g_workReportId);
		if(nWorkReportId > 0 && g_mode == "M") {
			// Update

			$.ajax({
				url : "../workReportUpdate.do",
				type : "POST",
				data : JSON.stringify(timeSheets),
				contentType : "application/json; charset=utf-8",
				dataType : "json",
				success : function(d) {
					if(d.message == "success") {
						document.location.href = "MobileWorkReport.do?wrid=" + g_workReportId + "&calid=" + settingObj.calendar.CalID + "&uid=" + jsonParam.creator;
					}
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     mobile_comm_ajaxerror("../workReportUpdate.do", response, status, error);
				}
			});
		} else {
			var isExist = false;
			// 중복검사 필요
			$.ajaxSetup({
	     		async: false
	   	 	});
		
			// 사용자 등급 구해서 채워넣음 - 사용자등급은 최초 등록시에만 적용됨.
			$.getJSON("../checkDuplicateWorkReport.do", {calId : settingObj.calendar.CalID, userCode : settingObj.userCode}, function(d) {
				if(d.wrid > 0) {
					isExist = true;
				}
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     mobile_comm_ajaxerror("../checkDuplicateWorkReport.do", response, status, error);
			});
		
			$.ajaxSetup({
			   	async: true
			});	
		
			if(!isExist) {
				// Save
				$.ajax({
					url : "../workReportSave.do",
					type : "POST",
					data : JSON.stringify(timeSheets),
					contentType : "application/json; charset=utf-8",
					dataType : "json",
					success : function(d) {
						var insertKey = d.insertKey;
						
						if(insertKey > 0) {
							// 조회 페이지로 이동 
							document.location.href = "MobileWorkReport.do?wrid=" + insertKey + "&calid=" + settingObj.calendar.CalID + "&uid=" + jsonParam.creator;
						}
					},
					error:function(response, status, error){
					     //TODO 추가 오류 처리
					     mobile_comm_ajaxerror("../workReportSave.do", response, status, error);
					}
				});
			} else {
				alert("이미 등록된 주차입니다.");
			}
		}
	};
	
	// TimeSheet 기록된 내용 JSON객체로 반환
	var getTimeSheetJSON = function() {
		var jsonArr = new Array();
		
		$(".divTimeCard").each(function(idx, d) {
			var targetObj = $(d);
			
			var strWorkReportId = g_workReportId; // 업무내용코드 ( PK ) 값이 존재한다면 꺼내서 맵핑		
			var strDivisionCode = targetObj.find("#spnTimeSheetSelectValues").attr("data-division");	// 업무 구분
			var strJobId = targetObj.find("#spnTimeSheetSelectValues").attr("data-job");			// 업무
			var strJobType = targetObj.find("#spnTimeSheetSelectValues").attr("data-type");			// 업무 분류
			var strWeekOfMonth = settingObj.calendar.WeekOfMonth;
			
			
			var dateObj = new Date(settingObj.calendar.Year, settingObj.calendar.Month - 1, settingObj.calendar.Day);
			for(var i = 0; i <= 6; i++) {
				var timeCard = {};
				timeCard.workReportId = strWorkReportId ? strWorkReportId : "";
				timeCard.divisionCode = strDivisionCode;
				timeCard.jobId = strJobId;
				timeCard.jobType = strJobType;
				timeCard.weekOfMonth = strWeekOfMonth;
				
				var hourVal = targetObj.find(".tbTimeSheetHour tr:nth-child(2)>td").eq(i).find(".timebox").val();
				hourVal = hourVal == "" ? 0 : hourVal;
				
				// 숫자가 아닌 데이터가 포함되 있을 시 
				if(isNaN(parseFloat(hourVal))) {
					// null 값 반환시 Validation Check
					jsonArr = null;
					return false;
				}
				
				// 날짜 계산
				if(i>0) {
					dateObj.setDate(dateObj.getDate() + 1);
				}
				
				timeCard.year = dateObj.getYear() + 1900;
				timeCard.month = dateObj.getMonth() + 1;
				timeCard.day = dateObj.getDate();
				
				timeCard.hour = hourVal;
				
				timeCard.yearMonth = timeCard.year + XFN_AddFrontZero(timeCard.month, 2);
				timeCard.workDate = timeCard.year + "-" + XFN_AddFrontZero(timeCard.month, 2) + "-" + XFN_AddFrontZero(timeCard.day, 2);
				
				jsonArr.push(timeCard);
			}
		});
		
		return jsonArr;
	};
	
	var returnViewPage = function() {
		document.location.href = "MobileWorkReport.do?calid=" + settingObj.calendar.CalID;
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