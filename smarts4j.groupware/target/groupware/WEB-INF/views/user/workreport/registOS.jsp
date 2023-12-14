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

<div id="osRegistBox">
	<div style="padding:10px;">
		<input type="hidden" value="" id="hidOUR_Code" />
		<table class="AXFormTable">
			<colgroup>
				<col width="100px">
				<col width="50%">
				<col width="100px">
				<col width="50%">
			</colgroup>
			<tbody>
				<tr>
					<th>
						<span><font color="red">* </font></span>
						이름
					</th>
					<td colspan="3">
						<input type="text" class="AXInput W300 HtmlCheckXSS ScriptCheckXSS" style="width:370px;" id="txtName"/>
					</td>
				</tr>
				<tr>
					<th>
						<span><font color="red">* </font></span>
						등급
					</th>
					<td>
						<select id="selGrade" style="width:128px; height:20px;">
							<option value='S'>특급</option>
							<option value='H'>고급</option>
							<option value='M'>중급</option>
							<option value='N'>초급</option>
						</select>
					</td>
					<th>나이</th>
					<td>
						<input type="text" class="AXInput W100 HtmlCheckXSS ScriptCheckXSS" maxlength="3" mode="moneyint" style="width:128px;" id="txtAge"/>
					</td>
				</tr>
				<tr>
					<th><span><font color="red">* </font></span>1차 담당자</th>
					<td>
						<span id="selectFirstManagerInfo" style="font-weight:600;"></span>
						<input id="btnFM" type="button" class="AXButton" value="<spring:message code='Cache.lbl_DeptOrgMap'/>" onclick="OrgMap_Open('F')"/>
					</td>
					<th>2차 담당자</th>
					<td>
						<span id="selectSecondManagerInfo" style="font-weight:600;"></span>
						<input id="btnSM"  type="button" class="AXButton" value="<spring:message code='Cache.lbl_DeptOrgMap'/>" onclick="OrgMap_Open('S')"/>
					</td>
				</tr>
				<tr>
					<th><span><font color="red">* </font></span>프로젝트</th>
					<td colspan="3">
						<input type="text" class="AXInput W300 HtmlCheckXSS ScriptCheckXSS" style="width:370px;" id="txtProject"/>
					</td>
				</tr>
				<tr>
					<th>프로젝트 역할</th>
					<td colspan="3">
						<input type="text" class="AXInput W300 HtmlCheckXSS ScriptCheckXSS" style="width:370px;" id="txtProjectRole"/>
					</td>
				</tr>
				<tr>
					<th>진행 상태</th>
					<td>
						<select id="selStatus" style="width:128px; height:20px;"  ></select>
					</td>
					<th>지방프로젝트</th>
					<td>
						<select id="selExPrjYN" style="width:128px; height:20px;">
							<option value="Y">Y</option>
							<option value="N" selected>N</option>
						</select>
					</td>
				</tr>
				<tr>
					<th><span><font color="red">* </font></span>계약기간</th>
					<td colspan="3">
						<input type="text" id="startdate_01" style="width: 85px; padding:0px!important;"  class="AXInput" /> ~ 
						<input type="text" kind="twindate" date_startTargetID="startdate_01" id="enddate_01" style="width: 105px; padding:0px!important;"  class="AXInput"  />			
					</td>
				</tr>
			</tbody>
		</table>
		
		<div align="center" style="padding-top: 10px">
			<input type="button" id="btnOSAdd" value="추가" onclick="addOutsourcing();" class="AXButton" style="display:none;">
			<input type="button" id="btnOSMod" value="수정" onclick="addOutsourcing();" style="display: none" class="AXButton">
			<input type="button" value="닫기" onclick="closeLayer('OutsourcingRegistPop');" class="AXButton">
		</div>
	</div>
</div>
<script>

var mode = "${mode}";
var urcode = "${urcode}";


var OrgMap_Open = function (pType){
	
	if(pType == "F"){
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=orgCallBackMethodF&type=A1&openerID=OutsourcingRegistPop","520px","580px","iframe",true,null,null,true);
	}
	else if(pType == "S"){
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=orgCallBackMethodS&type=A1&openerID=OutsourcingRegistPop","520px","580px","iframe",true,null,null,true);
	}
	
};

var orgCallBackMethodF = function(data) {
	var uJson = $.parseJSON(data);
	var userName = CFN_GetDicInfo(uJson.item[0].DN);
	var userCode = uJson.item[0].AN;
		
	$("#selectFirstManagerInfo").attr("data-urcode", userCode).text(userName);
};

var orgCallBackMethodS = function(data) {
	var uJson = $.parseJSON(data);
	var userName = CFN_GetDicInfo(uJson.item[0].DN);
	var userCode = uJson.item[0].AN;
		
	$("#selectSecondManagerInfo").attr("data-urcode", userCode).text(userName);
};

//외주직원 등록/수정
var addOutsourcing = function() {
	var strText = mode == "Reg" ? "등록" : "수정";
	var strURCode = $("#hidOUR_Code").val();
	var strName = $("#txtName").val();
	var strGrade = $("#selGrade").val();
	var strAge = $("#txtAge").val();
	var strFirstManagerCode = $("#selectFirstManagerInfo").attr("data-urcode");
	var strFirstManagerName = $("#selectFirstManagerInfo").text();
	var strSecondManagerCode = $("#selectSecondManagerInfo").attr("data-urcode");
	var strSecondManagerName = $("#selectSecondManagerInfo").text();
	var strJobNames = $("#txtProject").val();
	var strRole = $("#txtProjectRole").val();
	var strStatus = $("#selStatus").val();
	var strStartDate = $("#startdate_01").val();
	var strEndDate = $("#enddate_01").val();

	var strExPrjYN = $("#selExPrjYN").val();
	
	var iResult = validationCheck(strName,strFirstManagerName,strJobNames,strStartDate,strEndDate);

	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	if(iResult){		
		Common.Confirm(strText + "하시겠습니까?", "알림", function(result) {
			if(result) {
				$.post('workreportoutsourcingset.do', {
					mode : mode,
					urcode : strURCode,
					name : strName,
					grade : strGrade,
					age : strAge,
					fmCode : strFirstManagerCode,
					fmName : strFirstManagerName,
					smCode : strSecondManagerCode,
					smName : strSecondManagerName,
					jobName : strJobNames,
					role : strRole,
					status : strStatus,
					startdate : strStartDate,
					enddate : strEndDate,
					exPrjYn : strExPrjYN 
				}, function(d) {
					if(d.result == "success") {
						closeLayer("OutsourcingRegistPop");
						parent.bindGridData();
					}
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("workreportoutsourcingset.do", response, status, error);
				});
			}
		});
	}
};

var validationCheck = function(pName,pManager,pJobName,pStartDate,pEndDate){

	// validation chk
	if(pName == "") {		
		Common.Inform("이름을 입력해 주세요.", "알림", function(){
			$("#txtName").focus();			
		});	
		return false;
	}	
	if(pManager == "") {
		Common.Inform("1차 담당자를 지정해 주세요.", "알림");
		return false;
	}
	if(pJobName == "") {
		Common.Inform("프로젝트를 입력해 주세요.", "알림");
		return false;
	}
	if(pStartDate == "" && pEndDate == "") {
		Common.Inform("계약기간을 지정해 주세요..", "알림");
		return false;
	}
	
	return true;
}

var closeLayer = function(pId) {
	parent.Common.close(pId);
};

$(function() {
	
	//진행상태 바인딩
	//B:진행전, I:진행중, C:완료)
	$("#selStatus").append("<option value='B' selected='selected'>진행전</option>");
	$("#selStatus").append("<option value='I'>진행중</option>");
	$("#selStatus").append("<option value='C'>완   료</option>");
	
	//등급 바인딩
	var jQObj = $("#selGrade");
	
	/*
	$.getJSON("getOSGradeList.do", {}, function(d){	
		var listData = d.list;
	
		var name = "";
		$(listData).each(function(idx, data) {	
			switch(data.GradeKind.toString()){			
				case 'S' : name ="특급"; break;
				case 'H' : name ="고급"; break;
				case 'M' : name ="중급"; break;
				case 'N' : name ="초급"; break;				
			}
			jQObj.append("<option value='" + data.GradeKind.toString() + "'>" + name + "</option>");
		});
		
	});
	*/
	
	
	if(mode == "Reg"){
		$("#btnOSAdd").show();
		$("#btnOSMod").hide();
		$("#txtName").text("");
		$("#txtAge").text("");
		$("#selectProjectInfo").text("");
		$("#selectFirstManagerInfo").text("");
		$("#selectSecondManagerInfo").text("");
	}
	else if(mode =="Edit"){
		$("#btnOSAdd").hide();
		$("#btnOSMod").show();

		$.getJSON("getOutsourcingDetail.do", {urcode : urcode}, function(d) {
			var resultList = d.list;
			var shtml = "";
			var sURCode = "";
			var sName = "";
			var sGrade = "";
			var sAge = "";
			var sFMCode = "";
			var sFMName = "";
			var sSMCode = "";
			var sSMName = "";		
			var sJobName = "";
			var sRole = "";
			var sStatus = "";
			var sStartDate = "";
			var sEndDate = "";
			var sExProjectYN = "";
			
			$(resultList).each(function(idx, data) {
				sURCode = data.OUR_Code;
				sName = data.Name;
				sGrade = data.GradeKind;
				sAge = data.Age;
				sFMCode = data.FirstCode;
				sFMName = data.FirstName;
				sSMCode = data.SecondCode;
				sSMName = data.SecondName;
				sJobName = data.WorkSubject;
				sRole = data.Role;
				sStatus = data.ContractState;
				sStartDate = data.ContractStartDate;
				sEndDate = data.ContractEndDate;
				sExProjectYN = data.ExProjectYN;
			});

			$("#hidOUR_Code").val(sURCode);
			$("#txtName").val(sName);
			$("#txtAge").val(sAge);
			$("#selGrade").val(sGrade).attr("selected","selected");
			$("#txtProject").val(sJobName);
			$("#selectFirstManagerInfo").text(sFMName);
			$("#selectFirstManagerInfo").attr("data-urcode",sFMCode);
			$("#selectSecondManagerInfo").text(sSMName);
			$("#selectSecondManagerInfo").attr("data-urcode",sSMCode);
			$("#txtProjectRole").val(sRole);
			$("#selStatus").val(sStatus).attr("selected","selected");
			$("#startdate_01").val(sStartDate);
			$("#enddate_01").val(sEndDate);
			$("#selExPrjYN").val(sExProjectYN);
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getOutsourcingDetail.do", response, status, error);
		});
	}	
});

</script>
</body>
</html>