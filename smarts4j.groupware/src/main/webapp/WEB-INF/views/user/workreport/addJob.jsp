<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
</head>
<body>
<div id="workRegistBox">
	<div style="padding:10px;">
		<input type="hidden" value="" id="hidJobId" />
		<table class="AXFormTable">
			<colgroup>
				<col width="90px">
				<col width="50%">
				<col width="90px">
				<col width="50%">
			</colgroup>
			<tbody>
				<tr>
					<th>
						<span><font color="red">* </font></span>
						업무명
					</th>
					<td colspan="3">
						<input type="text" class="AXInput W300 HtmlCheckXSS ScriptCheckXSS" id="txtWorkTitle"/>
					</td>
				</tr>
				<tr>
					<th>
						<span><font color="red">* </font></span>
						업무구분
					</th>
					<td>
						<select id="selDivision"></select>
					</td>
					<th>사용여부</th>
					<td>
						<select id="selUseYN">
							<option value="Y">사용</option>
							<option value="N">사용안함</option>
						</select>
					</td>
				</tr>
				<tr>
					<th>담당자</th>
					<td colspan="3">
						<span id="selectManagerInfo" style="font-weight:600;"></span>
						<input type="button" class="AXButton" value="<spring:message code='Cache.lbl_DeptOrgMap'/>" onclick="OrgMap_Open()"/>
					</td>
				</tr>
				<tr>
					<th><span><font color="red">* </font></span>업무기간</th>
					<td colspan="3">
						<input type="text" id="startdate" style="width: 85px; padding:0px!important;"  class="AXInput" /> ~ 
						<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 105px; padding:0px!important;"  class="AXInput"  />			
					</td>
				</tr>
			</tbody>
		</table>
		
		<div align="center" style="padding-top: 10px">
			<input type="button" id="btnWorkRegist" value="추가" onclick="addSubmit();" class="AXButton" style="display:none;">
			<input type="button" id="btnWorkModify" value="수정" onclick="modifySubmit();" style="display: none" class="AXButton">
			<input type="button" value="닫기" onclick="closeLayer();" class="AXButton">
		</div>
	</div>
</div>

<script>

var mode = "${mode}";
var jobID = "${jobID}";

var OrgMap_Open = function (){
	parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=orgCallBackMethod&type=A1&openerID=JobEditPop","520px","580px","iframe",true,null,null,true);
};

function orgCallBackMethod(data) {
	var uJson = $.parseJSON(data);
	if(uJson.item.length > 0){
		var userName = CFN_GetDicInfo(uJson.item[0].DN);
		var userCode = uJson.item[0].AN;
			
		$("#selectManagerInfo").attr("data-urcode", userCode).text(userName);
	}
};


var addSubmit = function() {
	var strWorkTitle = $("#txtWorkTitle").val();
	var strDivisionCode = $("#selDivision").val();
	var strUseYN = $("#selUseYN").val();
	var strManagerCode = $("#selectManagerInfo").attr("data-urcode");
	var strStartDate = $("#startdate").val();
	var strEndDate = $("#enddate").val();

	var iResult = validationCheck(strWorkTitle, strDivisionCode, strStartDate, strEndDate);

	if(iResult){
		// 입력
		Common.Confirm("등록하시겠습니까?", "알림", function(result) {
			if(result) {
				$.post('workreportjobwrite.do', {
					jobName : strWorkTitle,
					jobDivision : strDivisionCode,
					useYN : strUseYN,
					managerCode : strManagerCode,
					startDate : strStartDate,
					endDate : strEndDate
				}, function(d) {

					closeLayer();
					
					// 최신목록을 보여주기위해 전체 Data Rebind
					parent.bindGridData();
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("workreportjobwrite.do", response, status, error);
				});	
			}
		});
	}	
};


var modifySubmit = function() {
	var strJobId = $("#hidJobId").val();
	var strWorkTitle = $("#txtWorkTitle").val();
	var strDivisionCode = $("#selDivision").val();
	var strUseYN = $("#selUseYN").val();
	var strManagerCode = $("#selectManagerInfo").attr("data-urcode");
	var strStartDate = $("#startdate").val();
	var strEndDate = $("#enddate").val();
	
	var iResult = validationCheck(strWorkTitle, strDivisionCode, strStartDate, strEndDate);
	
	if(iResult){
		// 입력
		Common.Confirm("수정하시겠습니까?", "알림", function(result) {
			if(result) {
				$.post('workreportjobupdate.do', {
					jobName : strWorkTitle,
					jobDivision : strDivisionCode,
					useYN : strUseYN,
					managerCode : strManagerCode,
					jobId : strJobId,
					startDate : strStartDate,
					endDate : strEndDate
				}, function(d) {

					closeLayer();
					
					// 최신목록을 보여주기위해 전체 Data Rebind
					parent.bindGridData();
				});	
			}
		});
	}	
}

var validationCheck = function(pTitle,pDivision,pStartDate,pEndDate){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	// validation chk
	if(pTitle == "") {
		Common.Inform("업무명을 입력해 주세요.", "알림", function(){
			$("#txtWorkTitle").focus();
		});	
		return false;
	}
	
	if(pDivision == "") {
		Common.Inform("업무구분이 선택되지 않았습니다.", "알림");
		return false;
	}
	
	if(pStartDate == "" || pEndDate == "") {
		Common.Inform("기간이 지정되지 않았습니다.", "알림");
		return false;
	}
	
	return true;
};

var closeLayer = function() {
	parent.Common.close("JobEditPop");
};

var bindDropDownList = function(){
	var jQObj = $("#selDivision");
	$(jQObj).append("<option value=''>업무구분</option>");
	$.getJSON("getWorkReportDiv.do", {}, function(d){	
		var listData = d.list;
		$(listData).each(function(idx, data) {
			jQObj.append("<option value='" + data.code + "'>" + data.name + "</option>");
		});		
	});
};


var setDefaultData = function(){
	Common.Inform("사업관리시스템과 연동 시 \n사업관리시스템의 프로젝트코드 메뉴에서 등록하시기 바랍니다.");
	
	bindDropDownList();
	
	if(mode == "Reg"){
		$("#btnWorkRegist").show();
		$("#btnWorkModify").hide();
		
		$("#txtWorkTitle").val('');
		$("#selDivision").val('');
		$("#selUseYN").val('Y');
		$("#selectManagerInfo").attr("data-urcode", '').text('');
		$("#startdate").val('');
		$("#enddate").val('');
		$("#hidJobId").val('');
	}
	else if(mode == "Edit"){
		
		$("#btnWorkRegist").hide();
		$("#btnWorkModify").show();
		
		// 데이터 바인딩
		$.get('workreportjobselectone.do', {
			jobid : jobID
		}, function(d) {
			// 기존 데이터 바인딩
			var objJob = d.job;

			$("#txtWorkTitle").val(objJob.JobName);
			$("#selDivision").val(objJob.JobDivision);
			$("#selUseYN").val(objJob.IsUse);
			$("#selectManagerInfo").attr("data-urcode", objJob.ManagerCode).text(objJob.ManagerName);
			$("#startdate").val(objJob.StartDate);
			$("#enddate").val(objJob.EndDate);
			$("#hidJobId").val(objJob.JobID);
		});	
		
	}
};

$(function() {

	setDefaultData();
	
});

</script>
</body>
</html>