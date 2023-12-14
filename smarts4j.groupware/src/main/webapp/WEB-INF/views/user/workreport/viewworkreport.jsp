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
		border : 1px solid #a9a9a9!important;
		z-index : 20;
		background-color : #fefefe;
	}
	td{
		border: 1px solid #c3d7df;
	}
</style>
</head>
<body>
<div style="padding:10px;" id="divContextWrap">
	<div style='position:relative; margin-bottom:5px; height:40px;'>
		<!-- 타이틀 & 필터 -->
		<p style='text-align:center; font-size:22px; font-weight:bold;'>[ <span id="spnWeekOfMonth"></span> ]</p>
		<div id="divManageUserBox" style='position:absolute; left:0px; top:0px; height:30px; display:none;'>
			<label id="lbManageUser" for="selManageUser" 
				   style="margin-right: 10px; height: 100%; display: inline-block; float: left; line-height: 30px; font-weight: 600;">사용자 : </label>
			<select id="selManageUser" style="width:150px;" onchange="manageUserChange()"></select>
		</div>
		<div id="divCurrentUserInfoBox" style="position:absolute;right:10px;top:-6px;height:80px;">
			<c:if test="${selUserInfoName ne '' and selUserInfoJobPositionName ne ''}">
				<ul style="height:100%;">
				<li style="display:inline-block; float:left; margin-right : 10px; height:100%; box-sizing:border-box;">
					<div class="mainPro">
						<img id="workReportUserImg" style="max-width: 100%; height: auto;" alt="">
					</div>
				</li>
				<li style="display:inline-block; padding-top : 15px; height:100%; box-sizing:border-box;">
					<div id="spnUser" style="font-weight:bold; font-size:14px; color:#444;">
						${selUserInfoName} ${selUserInfoJobPositionName}
					</div>
				</li>
			</ul>
			</c:if>
		</div>
	</div>
	<div style='width:100%; min-height:70px; margin-bottom : 10px;'>
		<!-- 타임시트 -->	
		<div>
			<table style='width:100%; border-color:#c3d7df; border-collapse:collapse; font-size:12px;' border="1" id="tbTimeSheet">
				<tr style='height:30px; text-align:center; font-weight:bold; font-size:12px; background-color : #f1f6f9;'>
					<td width="150">구분</td>
					<td width="240">업무</td>
					<td width="150">분류</td>
					<td width="30"></td>
					<td width="30"></td>
					<td width="30"></td>
					<td width="30"></td>
					<td width="30"></td>
					<td width="30"></td>
					<td width="30"></td>
					<td width="30">합계</td>
				</tr>
				
				<tr style='height:30px; text-align:center; background-color : #f9f9f9; font-weight:600;' id="trSummary">
					<td>합계</td>
					<td></td>
					<td></td>
					<td></td>
					<td></td>
					<td></td>
					<td></td>
					<td></td>
					<td></td>
					<td></td>
					<td></td>
				</tr>
			</table>
		</div>
	</div>
	<div>
		<!-- 보고내용 -->
		<table id="currentReportBox" style="width:100%; border-color:#c3d7df; border-collapse:collapse; font-size:13px; position:relative;" border="1">
			<thead>
				<tr style='height:30px; line-height:30px; font-size:12px; font-weight:bold; background-color : #f1f6f9;'>
					<td style="text-align:center; width:300px;">전주계획</td>
					<td style="text-align:center; width:340px;" colspan="2">금주실적</td>
					<td style="text-align:center; width:300px;">차주계획</td>
				</tr>
			</thead>
			<colgroup>
				<col style="*">
				<col style="width: 40px;">
				<col style="width: 309px;">
				<col style="*">
			</colgroup>
			<tbody>
				<tr style='height:40px;'>
					<td rowspan="7">
						<div id="txtLastWeekPlan" style='height:280px; border:none; overflow-y:auto; width:309px; resize:none; outline:none;'></div>
					</td>
					<td id="hdFriReport" style='width:40px; text-align:center; background-color : #f7f7f7; cursor:default;'>금</td>
					<td>
						<div class="clsWeekReport" id="txtFriReport" style="overflow-y:auto; width:312px; height:40px; border:none;"></div>
					</td>
					<td rowspan="7">
						<div id="txtNextWeekPlan" style='height:280px; border:none; overflow-y:auto; width:304px; resize:none; outline:none;'></div>
					</td>
				</tr>
				<tr style='height:40px;'>
					<td id="hdSatReport" style='width:40px; text-align:center; background-color : #f7f7f7; cursor:default;'><font style='color:blue;'>토</font></td>
					<td>
						<div class="clsWeekReport" id="txtSatReport" style="overflow-y:auto; width:312px; height:40px; border:none;"></div>
					</td>
				</tr>
				<tr style='height:40px;'>
					<td id="hdSunReport" style='width:40px; text-align:center; background-color : #f7f7f7; cursor:default;'><font style='color:red;'>일</font></td>
					<td>
						<div class="clsWeekReport" id="txtSunReport" style="overflow-y:auto; width:312px; height:40px; border:none;"></div>
					</td>
				</tr>
				<tr style='height:40px;'>
					<td id="hdMonReport" style='width:40px; text-align:center; background-color : #f7f7f7; cursor:default;'>월</td>
					<td>
						<div class="clsWeekReport" id="txtMonReport" style="overflow-y:auto; width:312px; height:40px; border:none;"></div>
					</td>
				</tr>
				<tr style='height:40px;'>
					<td id="hdTueReport" style='width:40px; text-align:center; background-color : #f7f7f7; cursor:default;'>화</td>
					<td>
						<div class="clsWeekReport" id="txtTueReport" style="overflow-y:auto; width:312px; height:40px; border:none;"></div>
					</td>
				</tr>
				<tr style='height:40px;'>
					<td id="hdWedReport" style='width:40px; text-align:center; background-color : #f7f7f7; cursor:default;'>수</td>
					<td>
						<div class="clsWeekReport" id="txtWedReport" style="overflow-y:auto; width:312px; height:40px; border:none;"></div>
					</td>
				</tr>
				<tr style='height:40px;'>
					<td id="hdThuReport" style='width:40px; text-align:center; background-color : #f7f7f7; cursor:default;'>목</td>
					<td>
						<div class="clsWeekReport" id="txtThuReport" style="overflow-y:auto; width:312px; height:40px; border:none;"></div>
					</td>
				</tr>
			</tbody>
		</table>
		
		<table id="migReportBox"  style="display:none; width:100%; border-color:#c3d7df; border-collapse:collapse; font-size:13px;" border="1">
			<tbody>
				<tr style='height:185px;'>
					<th style="width:10%; background-color : #f7f7f7;">전주 계획</th>
					<td style="width:90%;">
						<div id="migTxtLastWeekPlan" style='height:150px; border:none; overflow-y:auto; width:100%;'>
						</div>
					</td>
				</tr>
				<tr style='height:185px;'>
					<th style="width:10%; background-color : #f7f7f7;">차주 계획</th>
					<td style="width:90%;">
						<div id="migTxtNextWeekPlan" style='height:150px; border:none; overflow-y:auto; width:100%;'>
						</div>
					</td>
				</tr>
			</tbody>
		</table>
		
	</div>
	<div id="divBtnWrap" align="center" style="padding-top: 10px">
		<input type="button" id="btnModify" value="수정" onclick="modifyWorkReport()" class="AXButton" style="display:none;"/>
		<input type="button" id="btnReport" value="보고" onclick="reportWorkReport()" class="AXButton" style="display:none;" />
		<input type="button" id="btnCollect" value="회수" onclick="collectWorkReport()" class="AXButton" style="display:none;" />
		
		<!-- 승인 / 반려  (승인자에게만 보이는 버튼)-->
		<input type="button" id="btnApproval" value="승인" onclick="approvalWorkReport()" class="AXButton" style="display:none;" />
		<input type="button" id="btnReject" value="거부" onclick="rejectWorkReport()" class="AXButton"  style="display:none;" />
		
		<input type="button" id="btnInit" value="승인해제" onclick="initApprovalWorkreport();" class="AXButton" style="display:none;">
		
		<input id="btnClose" type="button" value="닫기" onclick="closeLayer();" class="AXButton" />
	</div>
</div>

<div id="divCommentBox" style="display:none;">
	<div style="width:300px; height:200px; padding : 10px;">
		<textarea id="txtCommentContent" class="HtmlCheckXSS ScriptCheckXSS" style="width:280px; height:140px; overflow-y : auto; border:1px solid #a0a0a0; box-sizing:border-box; padding:5px; resize:none;"></textarea>
		<div style="margin-top : 10px; text-align:center;">
			<button id="confirmBtn" type="button" class="AXButton">확인</button>
			<button type="button" class="AXButton" onclick="Common.Close('commentRegPop')">취소</button>
		</div>
	</div>
</div>

<script>
	var g_workReportId = "${workReportId}";
	var g_calId = "${calId}";

	var g_isCors = "${isCors}";
	var settingObj = {};

	var settingCalendarInfo = function() {
		var calendar = settingObj.calendar;
		
		// 타이틀 세팅
		$("#spnWeekOfMonth").text( calendar.Month + "월" + calendar.WeekOfMonth + "주차");
		
		// 타임시트 세팅
		var iDate = new Date(calendar.Year, calendar.Month - 1, calendar.Day);
		
		$("#tbTimeSheet tr:first>td").eq(3).text((iDate.getDate()) + '(금)');
		$("#tbTimeSheet tr:first>td").eq(4).html('<font style="color:blue">' + (iDate.add(1, "d").getDate()) + '(토)</font>');
		$("#tbTimeSheet tr:first>td").eq(5).html('<font style="color:red">' + (iDate.add(2, "d").getDate()) + '(일)</font>');
		$("#tbTimeSheet tr:first>td").eq(6).text((iDate.add(3, "d").getDate()) + '(월)');
		$("#tbTimeSheet tr:first>td").eq(7).text((iDate.add(4, "d").getDate()) + '(화)');
		$("#tbTimeSheet tr:first>td").eq(8).text((iDate.add(5, "d").getDate()) + '(수)');
		$("#tbTimeSheet tr:first>td").eq(9).text((iDate.add(6, "d").getDate()) + '(목)');
		
	};
	
	var modifyWorkReport = function() {
		location.href = "regWorkReport.do?mode=M&calid=" + g_calId + "&wrid=" + g_workReportId + "&uid=" + settingObj.userCode + "&isCors=" + g_isCors;
	};
	
	var closeLayer = function() {
		if(g_isCors == "Y") {
			//자바 그룹웨어 오픈으로 수정 
			parent.Common.close('RegWorkReportPop');
			//var corsDomain = Common.getBaseConfig("CORSDomain"); //자바 그룹웨어 오픈으로 인행 4j로 url 변경 [운영]
			//document.location.href = corsDomain + "/WebSite/Portal/WebPart/WorkReport/WebPartClose.aspx";
		} else {
			var isWindowed = CFN_GetQueryString("CFN_OpenedWindow");
			
			if(isWindowed.toLowerCase() == "true") {
				window.close();
			} else {
				parent.Common.close('WorkReportPop');
			}
		}
	};
	
	var manageUserChange = function() {
		var selUserCode = $("#selManageUser").val();
		location.href = "viewWorkReport.do?wrid=&calid=" + settingObj.calendar.CalID + "&uid=" + selUserCode + "&isCors=" + g_isCors;
	};
	
	// 보고버튼
	var reportWorkReport = function() {
		$.post("reportWorkReport.do", 
				{workReportId : g_workReportId, 
				 currentState : settingObj.state, 
				 userCode : settingObj.userCode,
				 calId : settingObj.calendar.CalID
				}, function(d) {
			if(d.result == "FAIL") {
				Common.Inform(d.message,"알림");
			}else if(d.result == "OK") {
				// 성공시 페이지 reload
				Common.Inform(d.message,"알림", function() {
					document.location.reload();
					
					try {
						if(g_isCors != "Y")
						// 업무보고 페이지에서 호출 시 창을 닫을때 grid rebind
						if(typeof parent.workReportGrid == 'object') {
							parent.workReportGrid.reloadList();
						}
					} catch(e) {
						coviCmn.traceLog(e);
						// CORS로 인한 예외처리 
					}
				});
			}
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("reportWorkReport.do", response, status, error);
		});
	};
	
	var collectWorkReport = function() {
		$.post("collectWorkReport.do", {workReportId : g_workReportId, currentState : settingObj.state, userCode : settingObj.userCode }, function(d) {
			if(d.result == "FAIL") {
				Common.Inform(d.message,"알림");
			}else if(d.result == "OK") {
				// 성공시 페이지 reload
				Common.Inform(d.message,"알림", function() {
					document.location.reload();
					
					try {
						// 업무보고 페이지에서 호출 시 창을 닫을때 grid rebind
						if(typeof parent.workReportGrid == 'object') {
							parent.workReportGrid.reloadList();
						}
					} catch(e) {
						coviCmn.traceLog(e);
						// CORS로 인한 예외처리
					}
				});
			}
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("collectWorkReport.do", response, status, error);
		});
	};
	
	var openCommentRegPop = function(popName, callback) {
		Common.open("", popName, "의견작성", "divCommentBox", "300px", "200px", "id", true, null, null, true);
		
		// event binding
		$("#commentRegPop_p").on("click", "div #confirmBtn", function() {
			var strComment = $("#txtCommentContent").val();

			if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

			callback(strComment);
		});
	};
	
	
	var approvalWorkReport = function() {
		openCommentRegPop("commentRegPop", function(comment) {
			
			var strComment = comment;
			
			$.post("approvalWorkReport.do", {workReportId : g_workReportId, currentState : settingObj.state, userCode : settingObj.userCode, comment : strComment}, function(d) {
				var successCnt = d.successCnt;
				var failCnt = d.failCnt;
				
				var msg = "승인 완료되었습니다.";
				
				if(failCnt > 0) {
					msg = "승인처리에 실패하였습니다.<br/>권한이 없는 사용자 입니다.";
				}
				
				// 성공시 페이지 reload
				Common.Inform(msg, "알림", function() {
					// Common.Close("commentRegPop");
					document.location.reload();
					
					try {
						// 업무보고 페이지에서 호출 시 창을 닫을때 grid rebind
						if(typeof parent.workReportGrid == 'object') {
							parent.workReportGrid.reloadList();
						}
						
						// 승인 성공 시 창 닫음
						if(typeof parent == 'object') {
							parent.Common.close('WorkReportPop');
						}
						
					} catch(e) {
						coviCmn.traceLog(e);
						// CORS로 인한 예외처리
					}
				});
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("approvalWorkReport.do", response, status, error);
			});
		});
	};
	
	var rejectWorkReport = function() {
		
		openCommentRegPop("commentRegPop", function(comment) {
			
			var strComment = comment;
			
			$.post("rejectWorkReport.do", {workReportId : g_workReportId, currentState : settingObj.state, userCode : settingObj.userCode, comment : strComment }, function(d) {
				var successCnt = d.successCnt;
				var failCnt = d.failCnt;
				
				var msg = "거부 완료되었습니다.";
				
				if(failCnt > 0) {
					msg = "거부처리에 실패하였습니다.<br/>권한이 없는 사용자 입니다.";
				}
				
				// 성공시 페이지 reload
				Common.Inform(msg, "알림", function() {
					// Common.Close("commentRegPop");
					document.location.reload();
					
					try {
						// 업무보고 페이지에서 호출 시 창을 닫을때 grid rebind
						if(typeof parent.workReportGrid == 'object') {
							parent.workReportGrid.reloadList();
						}
						
						// 거절 성공 시 창 닫음
						if(typeof parent == 'object') {
							parent.Common.close('WorkReportPop');
						}
					} catch(e) {
						coviCmn.traceLog(e);
						// CORS로 인한 예외처리
					}
				});
			
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("rejectWorkReport.do", response, status, error);
			});
		});
	};
	
	var initApprovalWorkreport = function() {
		//console.log("g_workReportId : "+g_workReportId);
		//console.log("g_calId : "+settingObj.calendar.CalID);
		
		$.ajax({
			url : "initApprovalWorkreport.do",
			type : "GET",
			data : {
				"workReportId" : g_workReportId,
				"calId" : settingObj.calendar.CalID
			}, 
			contentType : "application/json; charset=utf-8",
			dataType : "json",
			success : function(d) {
				if(d.message == "success") {
					closeLayer();
					parent.workReportGrid.reloadList();
				}
			},
			error:function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("initApprovalWorkreport.do", response, status, error);
			}
		});
	};
	
	
	$(function() {
		$("#btnInit").hide();
		var adminUser = Common.getBaseConfig('bizmntAprv3rdPartyAuthUserId'); // 그룹웨어 기초코드의 사업관리 관리자 정보를 조회
		if(adminUser.indexOf(Common.getSession("UR_Code")) != -1){
			$("#btnInit").show();
		}
		
		// 외부망 내부망 protocol 차이로 공통모듈 호출이 애매함
		if(g_isCors == "Y")
			$("#btnClose").remove();
		
		$.ajaxSetup({
			cache : false
		});
		// 변경 불가능 정보 세팅
		// 전역변수 설정
		Object.defineProperty(settingObj, "userCode", {
			value : "${userCode}".toLowerCase(),
			writable : false
		});	
		
		Object.defineProperty(settingObj, "isManager", {
			value : "${isManager}",
			writable : false
		});	
		
		var photoPath = Common.getBaseConfig('ProfileImagePath').replace("{0}", Common.getSession("DN_Code"));
		
		$("#workReportUserImg").attr("src", coviCmn.loadImage(photoPath + "${userCode}" + ".jpg")).on("error", function() {coviCmn.imgError(this, true);});
				
		// 담당자 정보
		var sessionUR_Code = "${currentUser}".toLowerCase();
		var sessionUR_Name = "${currentUserName}";
		// 담당자 Binding
		$.getJSON("getManageUsers.do", {calId : g_calId}, function(d) {
			var manageList = d.manageList;
			$("#selManageUser").empty()
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
			
			// 버튼 정리
			if(settingObj.userCode != sessionUR_Code) {
				$("#btnReport").remove();
				// 외주직원인지 확인
				if($("#selManageUser>option[value='" + settingObj.userCode + "']").length == 0) {
					$("#divManageUserBox").remove();
					$("#btnModify").remove();	
				}
			}
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getManageUsers.do", response, status, error);
		});
				// 달력정보 불러오기
		$.getJSON('getWorkReportCalendarInfo.do', {calID : g_calId}, function(d) {
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
		
		// 기초 보고 정보
		$.getJSON('getWorkReportBaseReport.do', {calID : g_calId, workReportID : g_workReportId, userCode : settingObj.userCode}, function(d) {
			var baseReport = d.baseReport;
			// 전역변수 설정
			Object.defineProperty(settingObj, "state", {
				value : baseReport.State,
				writable : false
			});
			
			var sessionUR_Code = "${currentUser}".toLowerCase();
			
			if(settingObj.state == "W") {
				// 회수버튼 삭제
				$("#btnCollect").remove();
				$("#btnModify").show();
				$("#btnReport").show();
			} else if (settingObj.state == "I") {
				// 보고, 수정 버튼 삭제
				$("#btnModify").remove();
				$("#btnReport").remove();
				if(sessionUR_Code == settingObj.userCode)
					$("#btnCollect").show();
				else 
					$("#btnCollect").remove();
				
				if(settingObj.isManager == "Y") {
					$("#btnApproval").show();
					$("#btnReject").show();
				}
			} else if (settingObj.state == "A") {
				// 보고, 수정, 회수 버튼 삭제
				$("#btnModify").remove();
				$("#btnReport").remove();
				$("#btnCollect").remove();
				$("#btnApproval").remove();
				$("#btnReject").remove();
			} else if (settingObj.state == "R") {
				// 회수버튼 삭제
				$("#btnCollect").remove();
				$("#btnModify").show();
				$("#btnReport").show();
			}
			
			// 직전주의 차주계획 불러와서 맵핑
			$.getJSON('getLastWeekPlan.do', {calID : g_calId, userCode : settingObj.userCode}, function(d) {
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
						if(flagMig) {
							$("#migTxtLastWeekPlan").html(lastWeekPlan.LastWeekPlan.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
							$("#txtLastWeekPlan").html(lastWeekPlan.LastWeekPlan.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
						}
						else
							$("#txtLastWeekPlan").html(lastWeekPlan.LastWeekPlan.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
					}
				}
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("getLastWeekPlan.do", response, status, error);
			});
			
			// 기본 정보 세팅
			// $("#txtLastWeekPlan").html(baseReport.LastWeekPlan.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
			
			// MigData중 HTML로 시작하는 내용은 치환없이 그대로 보여줌
			var flagMig = false;
			var isEditorContext = false;
			var editorRegx = new RegExp(/<html/img);
			flagMig = baseReport.MigWorkreportID > 0;
			isEditorContext = editorRegx.test(baseReport.NextWeekPlan);
			
			// migData 수정 금지
			if(flagMig) {
				$("#btnReport").remove();
				$("#btnModify").remove();
				
				$("#currentReportBox").remove();
				$("#migReportBox").css("display", "");
			} else {
				$("#migReportBox").remove();
			}
			
			if(flagMig && isEditorContext) {
				$("#migTxtNextWeekPlan").html(baseReport.NextWeekPlan.replace(/(<style[^>]*>)([^<].|[^<]\s)*(<\/style>)/gmi, ''));
			} else {
				if(flagMig)
					$("#migTxtNextWeekPlan").html(baseReport.NextWeekPlan.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				else
					$("#txtNextWeekPlan").html(baseReport.NextWeekPlan.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
			}
			
			if(!flagMig) {
				$("#txtMonReport").html(baseReport.MonDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				$("#txtTueReport").html(baseReport.TuesDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				$("#txtWedReport").html(baseReport.WedDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				$("#txtThuReport").html(baseReport.ThuDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				$("#txtFriReport").html(baseReport.FriDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				$("#txtSatReport").html(baseReport.SatDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));
				$("#txtSunReport").html(baseReport.SunDayReport.replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g, "<br/>"));	
			} else {
				
			}
			
			// 파라미터로 넘어온 값들이 읽을 수 있는 값인경우 TimeSheet 정보 Load
			if(baseReport.WorkReportID == g_workReportId) {
				// 타임시트 정보
				$.getJSON('getWorkReportTimeSheetReport.do', {workReportID : g_workReportId, calID : g_calId}, function(d) {
					var timeSheets = d.timeSheetReport;
					// 합계 윗부분
					var insertPosition = $("#trSummary");
					
					// 반복
					timeSheets.forEach(function(d) {
						var appendTr = $("<tr></tr>").addClass('trTimeSheet').css({
							"height" : "30px",
							"text-align" : "center",
							"font-size" : "12px"							
						});
						var sHTML = "<td width='150'>" + d.DivisionName + "</td>";
						sHTML += "<td width='240'>" + d.JobName + "</td>";
						sHTML += "<td width='150'>" + d.TypeName + "</td>";
						sHTML += "<td width='30'>" + d.FRI.toFixed(1) + "</td>";		// 금
						sHTML += "<td width='30'>" + d.SAT.toFixed(1) + "</td>";		// 토
						sHTML += "<td width='30'>" + d.SUN.toFixed(1) + "</td>";		// 일
						sHTML += "<td width='30'>" + d.MON.toFixed(1) + "</td>";		// 월
						sHTML += "<td width='30'>" + d.TUE.toFixed(1) + "</td>";		// 화
						sHTML += "<td width='30'>" + d.WED.toFixed(1) + "</td>";		// 수
						sHTML += "<td width='30'>" + d.THU.toFixed(1) + "</td>";		// 목
						sHTML += "<td width='30'>" + d.SUM.toFixed(1) + "</td>";		// 합계
						
						appendTr.html(sHTML);
						
						appendTr.insertBefore(insertPosition);
					});
					
					// 합계 계산
					for(var i = 3; i <= 10; i++) {
						var sum = 0;
						$(".trTimeSheet").each(function(idx, obj) { 
							sum += parseFloat($(obj).find("td").eq(i).text()); 
						});
						
						$("#trSummary>td").eq(i).text(sum.toFixed(1));
					}
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("getWorkReportTimeSheetReport.do", response, status, error);
				});				
			}
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getWorkReportBaseReport.do", response, status, error);
		});
		
		
		
		$(".clsWeekReport").on("click", function() {
			var targetObj = $(this);
			var targetId = $(this).attr("id");
			
			var targetHdId = targetId.replace("txt", "hd");
			
			if(targetObj.hasClass("pointReportBox")) {
				$("td[id^=hd]").css({"background-color" : "#f7f7f7", 
					 "font-weight" : "normal"});
				
				$(".clsWeekReport").removeClass("pointReportBox");
			} else {
				$("td[id^=hd]").css({"background-color" : "#f7f7f7", 
					 "font-weight" : "normal"});
				
				$("#" + targetHdId).css({"background-color" : "#fff", 
										 "font-weight" : "bold"});
				$(".clsWeekReport").removeClass("pointReportBox");
				targetObj.addClass("pointReportBox");	
			}
		});
		
		$("td[id^=hd]").on("click", function() {
			var targetId = $(this).attr("id").replace("hd", "txt");
			$("#" + targetId).trigger("click");
		});
	});
</script>
</body>
</html>