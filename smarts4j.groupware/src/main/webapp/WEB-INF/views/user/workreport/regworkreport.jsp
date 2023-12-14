<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv='cache-control' content='no-cache'> 
<meta http-equiv='expires' content='0'> 
<meta http-equiv='pragma' content='no-cache'>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
	.pointReportBox {
		position : absolute;
		top : 33px;
		height : 280px!important;
		border : 1px solid #a9a9a9;
		z-index : 20;
	}
	td{
		border: 1px solid #c3d7df;
	}
</style>
</head>
<body>
<div style="padding: 10px;">
	<div style='position:relative; margin-bottom:5px; height:40px;'>
		<!-- 타이틀 & 필터 -->
		<p style='text-align:center; font-size:22px; font-weight:bold;'>[ <span id="spnWeekOfMonth"></span> ]</p>
		<div id="divManageUserBox" style='position:absolute; left:0px; top:0px; height:30px; display:none;' >
			<label id="lbManageUser" for="selManageUser" 
				   style="margin-right: 10px; height: 100%; display: inline-block; float: left; line-height: 30px; font-weight: 600;">사용자 : </label>
			<select id="selManageUser" style="width:150px;" onchange="manageUserChange()" class="selectType02"></select>
		</div>
	</div>
	<div style='width:100%; min-height:70px; margin-bottom : 10px;'>
		<!-- 타임시트 -->	
		<div>
			<table style='width:100%; border-color:#c3d7df;' border="1" id="tbTimeSheet">
				<tr style='height:30px; text-align:center; font-weight:bold; font-size:12px; background-color : #f1f6f9;'>
					<td width="20"></td>
					<td width="150">구분</td>
					<td width="260">업무</td>
					<td width="130">분류</td>
					<td width="30"></td>
					<td width="30"></td>
					<td width="30"></td>
					<td width="30"></td>
					<td width="30"></td>
					<td width="30"></td>
					<td width="30"></td>
					<td width="30">합계</td>
				</tr>
								
				<!-- 샘플 타임시트 입력박스 -->
				<tr id='workTimeSheetClone' style='height:30px; text-align:center; display:none;'>
					<td style='text-align:center;'>
						<span style='font-weight:bold; cursor:pointer;' onclick='removeWorkTimeSheet(this);'>[-]</span>	
					</td>
					<td>
						<select class="selectType02" style='width:100%;' id="selJobDiv" onchange="changeDivision(this)">
						</select>
					</td>
					<td>
						<select class="selectType02"  style='width:90%;' onchange="chkJobAndType(this)">
							<option>업무를 선택하세요</option>
						</select>
						<button id="searchBtn" type="button" onclick="javascript:workSearchPop(this);" class="btnSearchType01"></button>
					</td>
					<td>
						<select class="selectType02"  style='width:100%;' onchange="chkJobAndType(this)">
							<option>분류를 선택하세요</option>
						</select>
					</td>
					<td>
						<!-- <input type="text" mode="numberint" max_length="2" num_max="24" class="AXInput friTime" id="friTime" data-axbind="pattern" style='width:28px; text-align:center; text-indent:0px!important;'> -->
					</td>
					<td>					
					</td>
					<td>						
					</td>
					<td>						
					</td>
					<td>						
					</td>
					<td>						
					</td>
					<td>						
					</td>
					<td>
						
					</td>
				</tr>
				<!-- 샘플 타임시트 입력박스 -->
				
				<tr style='height:30px; text-align:center;' id="trSummary">
					<td style='text-align:center;'>
						<span style='font-weight:bold; cursor:pointer;' onclick='addWorkTimeSheet();'>[+]</span>
					</td>
					<td>합계</td>
					<td></td>
					<td></td>
					<td><input type="text" class="AXInput" id="sumFriTime" style='width:33px;; text-align:center; text-indent:0px!important;' readonly></td>
					<td><input type="text" class="AXInput" id="sumSatTime" style='width:33px; text-align:center; text-indent:0px!important;' readonly></td>
					<td><input type="text" class="AXInput" id="sumSunTime" style='width:33px; text-align:center; text-indent:0px!important;' readonly></td>
					<td><input type="text" class="AXInput" id="sumMonTime" style='width:33px; text-align:center; text-indent:0px!important;' readonly></td>
					<td><input type="text" class="AXInput" id="sumTueTime" style='width:33px; text-align:center; text-indent:0px!important;' readonly></td>
					<td><input type="text" class="AXInput" id="sumWedTime" style='width:33px; text-align:center; text-indent:0px!important;' readonly></td>
					<td><input type="text" class="AXInput" id="sumThuTime" style='width:33px; text-align:center; text-indent:0px!important;' readonly></td>
					<td><input type="text" class="AXInput" id="sumSumTime" style='width:33px; text-align:center; text-indent:0px!important;' readonly></td>
				</tr>
			</table>
		</div>
	</div>
	<div>
		<!-- 보고내용 -->
		<table style="width:100%; border-color:#c3d7df; position:relative;" border="1">
				<colgroup>
					<col style="*">
					<col style="width: 40px;">
					<col style="width: 309px;">
					<col style="*">
				</colgroup>
				<thead>
				<tr style='height:30px; line-height:30px; font-size:12px; font-weight:bold; background-color : #f1f6f9;'>
					<td style="text-align:center; width:300px;">전주계획</td>
					<td style="text-align:center; width:340px;" colspan="2">금주실적</td>
					<td style="text-align:center; width:300px;">차주계획</td>
				</tr>
			</thead>
			<tbody>
				<tr style='height:40px;'>
					<td rowspan="7" style='background-color : #f0f0f0;'>
						<div id="txtLastWeekPlan" style='background-color:#f0f0f0; height:280px; border:none; overflow-y:auto; width:309px;'></div>
					</td>
					<td id="hdFriReport" style='width:40px; text-align:center; background-color : #f7f7f7;'>금</td>
					<td>
						<textarea class='clsWeekReport HtmlCheckXSS ScriptCheckXSS' id="txtFriReport" style="overflow-y:auto; width:312px; height:100%; border:none; resize:none; padding:1px;"></textarea>
					</td>
					<td rowspan="7">
						<textarea id="txtNextWeekPlan" class="HtmlCheckXSS ScriptCheckXSS" style='height:280px; border:none; overflow-y:auto; width:304px; resize:none;'></textarea>
					</td>
				</tr>
				<tr style='height:40px;'>
					<td id="hdSatReport" style='width:40px; text-align:center; background-color : #f7f7f7;'><font style='color:blue;'>토</font></td>
					<td>
						<textarea class='clsWeekReport HtmlCheckXSS ScriptCheckXSS' id="txtSatReport" style="overflow-y:auto; width:312px; height:100%; border:none; resize:none; padding:1px;"></textarea>
					</td>
				</tr>
				<tr style='height:40px;'>
					<td id="hdSunReport" style='width:40px; text-align:center; background-color : #f7f7f7;'><font style='color:red'>일</font></td>
					<td>
						<textarea class='clsWeekReport HtmlCheckXSS ScriptCheckXSS' id="txtSunReport" style="overflow-y:auto; width:312px; height:100%; border:none; resize:none; padding:1px;"></textarea>
					</td>
				</tr>
				<tr style='height:40px;'>
					<td id="hdMonReport" style='width:40px; text-align:center; background-color : #f7f7f7;'>월</td>
					<td>
						<textarea class='clsWeekReport HtmlCheckXSS ScriptCheckXSS' id="txtMonReport" style="overflow-y:auto; width:312px; height:100%; border:none; resize:none; padding:1px;"></textarea>
					</td>
				</tr>
				<tr style='height:40px;'>
					<td id="hdTueReport" style='width:40px; text-align:center; background-color : #f7f7f7;'>화</td>
					<td>
						<textarea class='clsWeekReport HtmlCheckXSS ScriptCheckXSS' id="txtTueReport" style="overflow-y:auto; width:312px; height:100%; border:none; resize:none; padding:1px;"></textarea>
					</td>
				</tr>
				<tr style='height:40px;'>
					<td id="hdWedReport" style='width:40px; text-align:center; background-color : #f7f7f7;'>수</td>
					<td>
						<textarea class='clsWeekReport HtmlCheckXSS ScriptCheckXSS' id="txtWedReport" style="overflow-y:auto; width:312px; height:100%; border:none; resize:none; padding:1px;"></textarea>
					</td>
				</tr>
				<tr style='height:40px;'>
					<td id="hdThuReport" style='width:40px; text-align:center; background-color : #f7f7f7;'>목</td>
					<td>
						<textarea class='clsWeekReport HtmlCheckXSS ScriptCheckXSS' id="txtThuReport" style="overflow-y:auto; width:312px; height:100%; border:none; resize:none; padding:1px;"></textarea>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
	<div align="center" style="padding-top: 10px">
		<input type="button" id="btnSave" value="저장" onclick="saveWorkReport();" class="AXButton">
		<input type="button" id="btnClose" value="취소" onclick="closeLayer();" class="AXButton">
	</div>
</div>
<script>

//# sourceURL=regworkreport.jsp
var g_workReportId = "${workReportID}";
var g_mode = "${mode}".toUpperCase();
var g_isCors = "${isCors}";
var settingObj = {};

//
var addWorkTimeSheet = function(pDivisionCode, pJobId, pTypeCode, pTimeSheetObj) {
	
	// Default Row Copy
	var cloneObj = $("#workTimeSheetClone").clone();
	var returnObj;	
	var outterTr = $("<tr></tr>").css({
		height: "30px",
		"text-align" : "center"
	}).addClass('workTimeSheet').html(cloneObj.html());
	
	// 시간 입력 박스 추가
	// 금, 토, 일, 월, 화, 수, 목
	outterTr.find("td").eq(4).html('<input type="text" class="AXInput timebox friTime" style="width:33px; text-align:center; text-indent:0px!important;" />');
	outterTr.find("td").eq(5).html('<input type="text" class="AXInput timebox satTime" style="width:33px; text-align:center; text-indent:0px!important;" />');
	outterTr.find("td").eq(6).html('<input type="text" class="AXInput timebox sunTime" style="width:33px; text-align:center; text-indent:0px!important;" />');
	outterTr.find("td").eq(7).html('<input type="text" class="AXInput timebox monTime" style="width:33px; text-align:center; text-indent:0px!important;" />');
	outterTr.find("td").eq(8).html('<input type="text" class="AXInput timebox tueTime" style="width:33px; text-align:center; text-indent:0px!important;" />');
	outterTr.find("td").eq(9).html('<input type="text" class="AXInput timebox wedTime" style="width:33px; text-align:center; text-indent:0px!important;" />');
	outterTr.find("td").eq(10).html('<input type="text" class="AXInput timebox thuTime" style="width:33px; text-align:center; text-indent:0px!important;" />');
	outterTr.find("td").eq(11).html('<input type="text" class="AXInput timebox sumTime" style="width:33px; text-align:center; text-indent:0px!important;" readonly />');
	
	// JobId가 넘어온 경우
	if(pJobId && pDivisionCode) {
		// 업무 select box 확인
		var divSel = outterTr.find("td:nth-child(2) > select");
		if(divSel.find("option[value='" + pDivisionCode + "']").length > 0) {
			$.ajaxSetup({
		     	async: false
		   	});
			
			divSel.val(pDivisionCode).trigger("change");
			var jobSel = outterTr.find("td:nth-child(3) > select");
			
			if(jobSel.find("option[value = '" + pJobId + "']").length > 0) {
				jobSel.val(pJobId);	
			}
			
			if(pTypeCode) {
				var typeSel = outterTr.find("td:nth-child(4) > select");
				if(typeSel.find("option[value = '" + pTypeCode + "']").length > 0) {
					typeSel.val(pTypeCode);
				}
			}
			
			// 수정모드의 경우
			if(g_mode == "M") {
				if(pTimeSheetObj) {
					outterTr.find("td:nth-child(5) > input").val(pTimeSheetObj.FRI.toFixed(1));
					outterTr.find("td:nth-child(6) > input").val(pTimeSheetObj.SAT.toFixed(1));
					outterTr.find("td:nth-child(7) > input").val(pTimeSheetObj.SUN.toFixed(1));
					outterTr.find("td:nth-child(8) > input").val(pTimeSheetObj.MON.toFixed(1));
					outterTr.find("td:nth-child(9) > input").val(pTimeSheetObj.TUE.toFixed(1));
					outterTr.find("td:nth-child(10) > input").val(pTimeSheetObj.WED.toFixed(1));
					outterTr.find("td:nth-child(11) > input").val(pTimeSheetObj.THU.toFixed(1));
					outterTr.find("td:nth-child(12) > input").val(pTimeSheetObj.SUM.toFixed(1));
				}
			}
			$.ajaxSetup({
		     	async: true
		    });
		}
	}
	
	returnObj = outterTr.insertBefore("#workTimeSheetClone");

	// 창 크기 조절 ( 세로사이즈 )
	// var currentHeight = $(window).height();
	// parent.Common.toResize("WorkReportPop", "1000px", (currentHeight + 30) + "px");
	
	return returnObj;
};

// 타임시트 Row 삭제
var removeWorkTimeSheet = function(target) {
	var targetTr;
	
	// 기존 DB에 저장된 Row 삭제하는 로직 필요
	
	// 최초 1개는 기본으로 세팅 (기존껄 삭제하는 경우 대체하는 로직 필요)
	targetTr = $(target).parents("tr");
	targetTr.remove();	
	
	// 전체다 삭제되면 기초행 하나 추가
	if($(".workTimeSheet").length == 0)
		addWorkTimeSheet();
	
	
	// 합계 계산
	$(".timebox").trigger('focusout');
};

var settingCalendarInfo = function() {
	var calendar = settingObj.calendar;
	
	// 타이틀 세팅
	$("#spnWeekOfMonth").text( calendar.Month + "월" + calendar.WeekOfMonth + "주차");
	
	// 타임시트 세팅
	var iDate = new Date(calendar.Year, calendar.Month - 1, calendar.Day);
	
	$("#tbTimeSheet tr:first>td").eq(4).text((iDate.getDate()) + '(금)');
	$("#tbTimeSheet tr:first>td").eq(5).html('<font style="color:blue">' + (iDate.add(1, "d").getDate()) + '(토)</font>');
	$("#tbTimeSheet tr:first>td").eq(6).html('<font style="color:red">' + (iDate.add(2, "d").getDate()) + '(일)</font>');
	$("#tbTimeSheet tr:first>td").eq(7).text((iDate.add(3, "d").getDate()) + '(월)');
	$("#tbTimeSheet tr:first>td").eq(8).text((iDate.add(4, "d").getDate()) + '(화)');
	$("#tbTimeSheet tr:first>td").eq(9).text((iDate.add(5, "d").getDate()) + '(수)');
	$("#tbTimeSheet tr:first>td").eq(10).text((iDate.add(6, "d").getDate()) + '(목)');
};

var changeDivision = function(target) {
	var rowObj = $(target).parents("tr");
	var selJobObj = rowObj.find("td").eq(2).find("select");
	var selTypeObj = rowObj.find("td").eq(3).find("select");
	
	// 초기화
	selJobObj.empty().append('<option value="">업무를 선택하세요</option>');
	selTypeObj.empty().append('<option value="">분류를 선택하세요</option>');
	
	// 바인딩 (업무)
	var division = $(target).val();
	
	// 다수 호출 발생으로 인해 로직 수정
	// 매번 서버에 요청하던 구조 -> SessionStorage 이용으로 변경
	
	if(division != "") {
		
		var ssWorkJob = ''; 
		var ssWorkType = '';
				
		try {
			ssWorkJob = $.parseJSON(window.sessionStorage.getItem('workJob_' + division));
			ssWorkType = $.parseJSON(window.sessionStorage.getItem('workType_' + division));
		}catch(e){coviCmn.traceLog(e);}
	
		if(typeof ssWorkJob == 'object' && ssWorkJob !== null) {
			ssWorkJob.forEach(function(d) {
				selJobObj.append('<option value="' + d.JobID + '">' + d.JobName + '</option>');
			});
		} else {
			$.getJSON('getworkjob.do', {division : division}, function(d) {
				
				window.sessionStorage.setItem('workJob_' + division, JSON.stringify(d.list));
				
				d.list.forEach(function(d) {
					selJobObj.append('<option value="' + d.JobID + '">' + d.JobName + '</option>');
				});
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("getworkjob.do", response, status, error);
			});	
		}		
		
		if(typeof ssWorkType == 'object' && ssWorkType !== null) {
			ssWorkType.forEach(function(d) {
				selTypeObj.append('<option value="' + d.code + '">' + d.name + '</option>');
			});
		} else {
			$.getJSON('getWorkReportTypeSel.do', {code : division}, function(d) {
				
				window.sessionStorage.setItem('workType_' + division, JSON.stringify(d.list));
				
				d.list.forEach(function(d) {
					selTypeObj.append('<option value="' + d.code + '">' + d.name + '</option>');
				});
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("getWorkReportTypeSel.do", response, status, error);
			});	
		}	
	}
};


// 중복검사
var chkJobAndType = function(target) {
	var rowObj = $(target).parents("tr");
	var selJobObj = rowObj.find("td").eq(2).find("select");
	var selTypeObj = rowObj.find("td").eq(3).find("select");
	
	var selJobID = selJobObj.val();
	var selTypeCode = selTypeObj.val();
	
	$(".workTimeSheet").each(function(idx, pObj) {
		var targetJobID = '';
		var targetTypeCode = '';
		// 자기자신은 처리하지 않음
		if(pObj != rowObj[0]) {
			targetJobID = $(pObj).find("td").eq(2).find("select").val();
			targetTypeCode = $(pObj).find("td").eq(3).find("select").val();
			if(targetJobID == "" || targetTypeCode == "") {
				return true;
			}
			// 선택한 업무, 분류가 같은 행이 존재한다면 알림메세지 발생
			if(targetJobID == selJobID && targetTypeCode == selTypeCode) {
				Common.Inform("이미 선택된 업무 및 분류입니다.");
				selTypeObj.val('');
			}
		}			
	});
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
		$.getJSON('getLastWeekPlan.do', {calID : settingObj.calendar.CalID, userCode : settingObj.userCode}, function(d) {
			var lastWeekPlan = d.lastWeekPlan;
			if(lastWeekPlan.CNT > 0) {					
				// MigData중 HTML로 시작하는 내용은 치환없이 그대로 보여줌
				var flagMig = false;
				var isEditorContext = false;
				var editorRegx = new RegExp(/<html/img);
				flagMig = lastWeekPlan.MigWorkreportID > 0;
				isEditorContext = editorRegx.test(lastWeekPlan.LastWeekPlan);
									
				if(flagMig && isEditorContext) {
					$("#migTxtLastWeekPlan").html(lastWeekPlan.LastWeekPlan.replace(/(<style[^>]*>)([^<].|[^<]\s)*(<\/style>)/gmi, ''));
					$("#txtLastWeekPlan").html(lastWeekPlan.LastWeekPlan.replace(/(<style[^>]*>)([^<].|[^<]\s)*(<\/style>)/gmi, ''));
				} else {
					$("#txtLastWeekPlan").html(lastWeekPlan.LastWeekPlan.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				}
			}
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getLastWeekPlan.do", response, status, error);
		});
		
		// 수정모드에선 기존내용 불러와서 맵핑
		// 기초 보고 정보
		$.getJSON('getWorkReportBaseReport.do', {calID : settingObj.calendar.CalID, workReportID : g_workReportId, userCode : settingObj.userCode}, function(d) {
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
				$.getJSON('getWorkReportTimeSheetReport.do', {workReportID : g_workReportId, calID : settingObj.calendar.CalID}, function(d) {
					
					var timeSheets = d.timeSheetReport;
					
					// 반복
					timeSheets.forEach(function(d) {
						var dateHourInfo = {};
						
						addWorkTimeSheet(d.DivisionCode, d.JobID, d.TypeCode, d);
					});
					
					// 합계 계산
					$(".timebox").trigger('focusout');
				});				
			}
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getWorkReportBaseReport.do", response, status, error);
		});
	} else if(g_mode == "W") {
		// 직전주의 차주계획 불러와서 맵핑
		$.getJSON('getLastWeekPlan.do', {calID : settingObj.calendar.CalID, userCode : settingObj.userCode}, function(d) {		
			var lastWeekPlan = d.lastWeekPlan;
			if(lastWeekPlan.CNT > 0) {					
				// MigData중 HTML로 시작하는 내용은 치환없이 그대로 보여줌
				var flagMig = false;
				var isEditorContext = false;
				var editorRegx = new RegExp(/<html/img);
				flagMig = lastWeekPlan.MigWorkreportID > 0;
				isEditorContext = editorRegx.test(lastWeekPlan.LastWeekPlan);
									
				if(flagMig && isEditorContext) {
					$("#migTxtLastWeekPlan").html(lastWeekPlan.LastWeekPlan.replace(/(<style[^>]*>)([^<].|[^<]\s)*(<\/style>)/gmi, ''));
					$("#txtLastWeekPlan").html(lastWeekPlan.LastWeekPlan.replace(/(<style[^>]*>)([^<].|[^<]\s)*(<\/style>)/gmi, ''));
				} else {
					$("#txtLastWeekPlan").html(lastWeekPlan.LastWeekPlan.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				}
			}
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getLastWeekPlan.do", response, status, error);
		});
		
		// 나의 업무 세팅 맵핑
		// 자기자신의 업무 등록 시 
		// [2018-01-30 yjlee] 외주직원 기본 값 설정을 위해 세션 값과 현재 선택된 userCode 비교문 주석 처리
		//if("${currentUserCode}".toLowerCase() == settingObj.userCode) {
			$.getJSON('myworksettingmyjob.do',{userID : settingObj.userCode}, function(d) {
				var list = d.list;
				// 설정된 나의업무가 없다면
				if(list.length == 0) {
					addWorkTimeSheet();
				} else {
					list.forEach(function(mywork) {
						addWorkTimeSheet(mywork.JobDivision, mywork.JobID, mywork.TypeCode);
					});
				}
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("myworksettingmyjob.do", response, status, error);
			});
		//} else {
		//	addWorkTimeSheet();
		//}
	}
}




// TimeSheet 기록된 내용 JSON객체로 반환
var getTimeSheetJSON = function() {
	var jsonArr = new Array();
	
	$(".workTimeSheet").each(function(idx, d) {
		var targetObj = $(d);
		
		var strWorkReportId = g_workReportId; // 업무내용코드 ( PK ) 값이 존재한다면 꺼내서 맵핑		
		var strDivisionCode = targetObj.find("td").eq(1).find("select").val();	// 업무 구분
		var strJobId = targetObj.find("td").eq(2).find("select").val();			// 업무
		var strJobType = targetObj.find("td").eq(3).find("select").val();		// 업무 분류
		var strWeekOfMonth = settingObj.calendar.WeekOfMonth;
		
		
		
		var dateObj = new Date(settingObj.calendar.Year, settingObj.calendar.Month - 1, settingObj.calendar.Day);
		for(var i = 4; i <= 10; i++) {
			var timeCard = {};
			timeCard.workReportId = strWorkReportId ? strWorkReportId : "";
			timeCard.divisionCode = strDivisionCode;
			timeCard.jobId = strJobId;
			timeCard.jobType = strJobType;
			timeCard.weekOfMonth = strWeekOfMonth;
			
			var hourVal = targetObj.find("td").eq(i).find(".timebox").val();
			hourVal = hourVal == "" ? 0 : hourVal;
			
			// 숫자가 아닌 데이터가 포함되 있을 시 
			if(isNaN(parseFloat(hourVal))) {
				// null 값 반환시 Validation Check
				jsonArr = null;
				return false;
			}
			
			// 날짜 계산
			if(i>4) {
				dateObj.setDate(dateObj.getDate() + 1);
			}
			
			// 최초 작성 시 0일경우 저장 안함
			/*
			if(hourVal == 0 && g_mode != "M")
				continue;
			*/
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

var closeLayer = function() {
	if(g_isCors == "Y") {
		//var corsDomain = Common.getBaseConfig("CORSDomain");
		//document.location.href = corsDomain + "/WebSite/Portal/WebPart/WorkReport/WebPartClose.aspx";
		//자바 그룹웨어 오픈으로 수정
	    parent.Common.close('RegWorkReportPop');
	} else {
		if(g_mode == "W") {
			var isWindowed = CFN_GetQueryString("CFN_OpenedWindow");
			
			if(isWindowed.toLowerCase() == "true") {
				window.close();
			} else {
				parent.Common.close('WorkReportPop');
			}
		}
		else if (g_mode == "M")
			document.location.href = "viewWorkReport.do?wrid=" + g_workReportId + "&calid=" + settingObj.calendar.CalID + "&uid=" + settingObj.userCode;
	}
};


// 저장
var saveWorkReport = function() {
	// Validation Check
	var chkFlag = false;
	
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	$(".workTimeSheet").each(function(idx, d) {
		var targetObj = $(d);
		var strDivisionCode = targetObj.find("td").eq(1).find("select").val();	// 업무 구분
		var strJobId = targetObj.find("td").eq(2).find("select").val();			// 업무
		var strJobType = targetObj.find("td").eq(3).find("select").val();		// 업무 분류
		
		if(strDivisionCode == "") {
			Common.Inform("업무구분이 선택되지 않았습니다.", "알림");
			chkFlag = true;
			return false;
		}
		else if (strJobId == "") {
			Common.Inform("업무가 선택되지 않았습니다.", "알림");
			chkFlag = true;
			return false;
		}
		else if (strJobType == "") {
			Common.Inform("업무분류가 선택되지 않았습니다.", "알림");
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
	jsonParam.calId = settingObj.calendar.CalID;
	
	// 사용자 아이디는 선택된 경우에만 채워서 보냄
	jsonParam.creator = settingObj.userCode;
	
	
	 $.ajaxSetup({
     	async: false
   	 });
	
	// 사용자 등급 구해서 채워넣음 - 사용자등급은 최초 등록시에만 적용됨.
	$.getJSON("getWorkReportGrade.do", {userid : jsonParam.creator}, function(d) {
		jsonParam.jobPositionCode = d.grade.JobPositionCode;
		jsonParam.memberType = d.grade.MemberType;
		jsonParam.gradeKind = d.grade.GradeKind;
	}).error(function(response, status, error){
	     //TODO 추가 오류 처리
	     CFN_ErrorAjax("getWorkReportGrade.do", response, status, error);
	});
	
	$.ajaxSetup({
	   	async: true
	});	
	
	
	// 보안 관련 처리 필요 (escape 문자열 처리 등)
	
	
	// 타임시트 데이터
	var timeSheets = getTimeSheetJSON();
	
	if(timeSheets == null) {
		Common.Inform("잘못된 입력이 존재합니다.", "알림");
		return false;
	}
	
	if(timeSheets.length == 0) {
		Common.Inform("입력된 데이터가 없습니다.", "알림");
		return false;
	}
	
	timeSheets.unshift(jsonParam);
		
	// WorkReportID 값이 없을경우 저장 그 외 수정으로 처리
	var nWorkReportId = parseInt(g_workReportId);
	if(nWorkReportId > 0 && g_mode == "M") {
		// Update

		$.ajax({
			url : "workReportUpdate.do",
			type : "POST",
			data : JSON.stringify(timeSheets),
			contentType : "application/json; charset=utf-8",
			dataType : "json",
			success : function(d) {
				
				try {
					if(g_isCors != "Y") {
						// 수정 완료 시 부모창 reload
						if(typeof parent.workReportGrid == 'object') {
							parent.workReportGrid.reloadList();
						}
					}
				} catch(e) {
					coviCmn.traceLog(e);
				}
				
				if(d.message == "success") {
					document.location.href = "viewWorkReport.do?wrid=" + g_workReportId + "&calid=" + settingObj.calendar.CalID + "&uid=" + jsonParam.creator + "&isCors=" + g_isCors;
				}
			},
			error:function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("workReportUpdate.do", response, status, error);
			}
		});
	} else {
		var isExist = false;
		// 중복검사 필요
		$.ajaxSetup({
     		async: false
   	 	});
	
		$.getJSON("checkDuplicateWorkReport.do", {calId : settingObj.calendar.CalID, userCode : settingObj.userCode}, function(d) {
			if(d.wrid > 0) {
				isExist = true;
			}
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("checkDuplicateWorkReport.do", response, status, error);
		});
	
		$.ajaxSetup({
		   	async: true
		});	
	
		if(!isExist) {
			// Save
			$.ajax({
				url : "workReportSave.do",
				type : "POST",
				data : JSON.stringify(timeSheets),
				contentType : "application/json; charset=utf-8",
				dataType : "json",
				success : function(d) {
					
					try {
						if(g_isCors != "Y") {
							// 저장 완료 시 부모창 reload
							if(typeof parent.workReportGrid == 'object') {
								parent.workReportGrid.reloadList();
							}
					}
					}catch(e) {
						coviCmn.traceLog(e);
					}
					
					var insertKey = d.insertKey;
					
					if(insertKey > 0) {
						// 조회 페이지로 이동 
						document.location.href = "viewWorkReport.do?wrid=" + insertKey + "&calid=" + settingObj.calendar.CalID + "&uid=" + jsonParam.creator + "&isCors=" + g_isCors;
					}
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("workReportSave.do", response, status, error);
				}
			});
		} else {
			Common.Inform("이미 등록된 주차입니다.", "알림");
		}
	}
}


var manageUserChange = function() {
	var selUserCode = $("#selManageUser").val();
	location.href = "regWorkReport.do?wrid=&mode=W&calid=" + settingObj.calendar.CalID + "&uid=" + selUserCode + "&isCors=" + g_isCors;
};


$(function(){
	// 외부망 내부망 protocol 차이로 공통모듈 호출이 애매함
	if(g_isCors == "Y")
		$("#btnClose").remove();
	
	$.ajaxSetup({
		cache : false
	});
	
	
	$("#tbTimeSheet").on("focusout", ".workTimeSheet .timebox", function(e) {
		var inputBox = $(e.target);
		var value = inputBox.val();
		// 숫자 및 소수점이 아닌 문자 치환
		value = value.replace(/[^0-9.]/g, '');
		value = value == "" ? "0" : value;
		value = parseFloat(value);
		
		if(isNaN(value)) {
			value = 0;
			
			inputBox.val(value);
		} else {
			// 23이상의 숫자의 경우 23으로 변경
			value = value > 24 ? 24 : value;
			//반올림 첫번째자리까지			
			value = value.toFixed(1);
			
			inputBox.val(value);
			
			// Summary
			// WeekSummary
			var weekBoxs = inputBox.parents("tr").find(".timebox");
			var summaryTime = 0;
			weekBoxs.each(function(idx, d) {
				var targetObj = $(d);
				if(!targetObj.hasClass("sumTime")) {
					var time = targetObj.val();
					summaryTime += parseFloat((time == "" ? 0 : time));
				}
			});
			
			weekBoxs.filter(".sumTime").val(summaryTime.toFixed(1));
			
			// DaySummary
			var weekSumBoxs = $("#trSummary input[id^='sum']");
			weekSumBoxs.each(function(idx, d) {
				var target = $(d);
				var idName = target.attr("id").substr(3);	// sum 제거-
				idName = idName.substring(0,1).toLowerCase() + idName.substring(1);
				
				var dayOfTime = 0;
				
				$("." + idName).each(function(i, timeObj) {
					var time = $(timeObj).val();
					dayOfTime += parseFloat((time == "" ? 0 : time));
				});
				
				
				// 전체합계를 제외한 일별 합계 모두 체크
				if(target.attr("id") != "sumSumTime") {
					if(dayOfTime > 24) {
						Common.Inform("하루 최대 24시간을 넘길 수 없습니다.", "알림");
						inputBox.val("0").trigger("focus");
					}
				}
				
				target.val(dayOfTime.toFixed(1));
			});
		}
	});
	
	
	$(".clsWeekReport").on("focus", function() {
		var targetObj = $(this);
		var targetId = $(this).attr("id");
		
		var targetHdId = targetId.replace("txt", "hd");
		
		$("#" + targetHdId).css({"background-color" : "#fff", 
								 "font-weight" : "bold"});
		
		targetObj.addClass("pointReportBox");
	}).on("focusout", function() {
		var targetObj = $(this);
		var targetId = $(this).attr("id");
		
		var targetHdId = targetId.replace("txt", "hd");
		
		$("#" + targetHdId).css({"background-color" : "#f7f7f7", 
			 "font-weight" : "normal"});
		
		targetObj.removeClass("pointReportBox");
		targetObj.scrollTop(0);
	});
	
	
	$("td[id^=hd]").on("click", function() {
		var targetId = $(this).attr("id").replace("hd", "txt");
		$("#" + targetId).trigger("focus");
	});
	
	/*
	// event binding
	$("#tbTimeSheet").on("keyup", ".workTimeSheet .timebox", function(e) {
		// Validation Chk
		var inputKey = e.key;
		var inputBox = $(e.target);
		var value = inputBox.val();
		
		if(_ie) {
			if(inputKey == "Decimal")
				inputKey = ".";
		}
		
		value = value == "" ? "0" : value;
		
		// 숫자 및 소수점이 아닌 문자 치환
		value = value.replace(/[^0-9.]/g, '');

		// 숫자형식으로 변경
		// 숫자형식이거나 event에 바인딩되어 넘어오지 않은경우
		if(inputKey != ".") {
			//반올림 첫번째자리까지			
			value = parseFloat(value);
			
			
			// 23이상의 숫자의 경우 23으로 변경
			value = value > 24 ? 24 : value;
			
			inputBox.val(value);
			
			// Summary
			// WeekSummary
			var weekBoxs = inputBox.parents("tr").find(".timebox");
			var summaryTime = 0;
			weekBoxs.each(function(idx, d) {
				var targetObj = $(d);
				if(!targetObj.hasClass("sumTime")) {
					var time = targetObj.val();
					summaryTime += parseFloat((time == "" ? 0 : time));
				}
			});
			
			weekBoxs.filter(".sumTime").val(summaryTime.toFixed(1));
			
			// DaySummary
			var weekSumBoxs = $("#trSummary input[id^='sum']");
			weekSumBoxs.each(function(idx, d) {
				var target = $(d);
				var idName = target.attr("id").substr(3);	// sum 제거-
				idName = idName.substring(0,1).toLowerCase() + idName.substring(1);
				
				var dayOfTime = 0;
				
				$("." + idName).each(function(i, timeObj) {
					var time = $(timeObj).val();
					dayOfTime += parseFloat((time == "" ? 0 : time));
				});
				
				target.val(dayOfTime.toFixed(1));
			});
		} else if(inputKey == ".") {
			inputBox.val(value);
		}
		return false;
	});
	*/
	
	
	// 변경 불가능 정보 세팅
	// 전역변수 설정
	Object.defineProperty(settingObj, "userCode", {
		value : "${userCode}".toLowerCase(),
		writable : false
	});	
	
	$.ajaxSetup({
    	async: false
   	});
	
	// 달력정보 불러오기
	$.getJSON('getWorkReportCalendarInfo.do', {calID : '${calid}'}, function(d) {
		// 전역변수 설정
		Object.defineProperty(settingObj, "calendar", {
			value : d.calendar,
			writable : false
		});
		
		settingCalendarInfo();
	}).error(function(response, status, error){
	     //TODO 추가 오류 처리
	     CFN_ErrorAjax("getWorkReportCalendarInfo.do", response, status, error);
	});
	

	var sessionUR_Code = "${currentUserCode}".toLowerCase();
	var sessionUR_Name = "${currentUserName}";
	
	// 담당자 Binding
	$.getJSON("getManageUsers.do", {calId : '${calid}'}, function(d) {
		var manageList = d.manageList;
		$("#selManageUser").empty();
				
		if(manageList.length > 0) {
			$("#selManageUser").append("<option value='" + sessionUR_Code + "'>" + sessionUR_Name + "</option>");
			manageList.forEach(function(obj){
				$("#selManageUser").append("<option value='" + obj.OUR_Code + "'>" + obj.Name + "</option>");
			});
			
			if(settingObj.userCode != "") { 
				$("#selManageUser").val(settingObj.userCode);
			}
			$("#divManageUserBox").show();
		} else {
			// 담당자가 없는경우 사용자 선택박스 제거
			$("#divManageUserBox").remove();
			
		}
	}).error(function(response, status, error){
	     //TODO 추가 오류 처리
	     CFN_ErrorAjax("getManageUsers.do", response, status, error);
	});
	
	// 최초 구분 세팅
	$.getJSON('getWorkReportDiv.do', {}, function(d) {
		var obj = $("#selJobDiv");
		obj.empty();
		obj.append('<option value="">구분을 선택하세요</option>');
		d.list.forEach(function(d) {
			obj.append('<option value="' + d.code + '">' + d.name + '</option>');
		});
		
		// 구분세팅 완료 후 
		setLoadTimeSheet();
	}).error(function(response, status, error){
	     //TODO 추가 오류 처리
	     CFN_ErrorAjax("getWorkReportDiv.do", response, status, error);
	});
	
	$.ajaxSetup({
    	async: true
   	});
});

//업무검색
var workSearchPop = function(target) {
	var rowObj = $(target).parents("tr");
	var selDevObj = rowObj.find("td").eq(1).find("select");
	var selDevID = selDevObj.val();
	var num = rowObj.index();
	
	Common.open("", "WorkSearchPop", "업무검색", "workSearchPop.do?num="+num+"&selDevID=" + selDevID, "500px", "500px", "iframe", true, null, null, true);
}

//업무선택
var workSelect = function(num, i) {
	var rowObj = $("#tbTimeSheet").find("tr").eq(num);
	var selJobObj = rowObj.find("td").eq(2).find("select");
	
	selJobObj.children("option:eq("+i+")").prop("selected",true);
}

</script>
</body>
</html>