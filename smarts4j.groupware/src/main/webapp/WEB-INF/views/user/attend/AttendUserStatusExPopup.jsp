<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<% String approvalAppPath = PropertiesUtil.getGlobalProperties().getProperty("approval.app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
	.layer_divpop table,p {font-size:12px}
	.attTime {width:100%}
	#NextDayYn {display:inline-block;}
</style>
<body>
<!-- 연장근무 일정 수정 팝업 시작 -->
<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="" style="overflow:hidden; padding:0;">
		<div class="ATMgt_popup_wrap">
			<table id="exTable" class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0" >
				<colgroup>
					<col width='115px'/>
					<col width='230px'/>
					<col width='115px'/>
					<col />
				</colgroup>
				<tbody>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_Staff' /></td> 
						<td colspan='3'><p class="tx_company"></p></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_date' /></td> 
						<td colspan='3'>
							<div class="dateSel type02">
								<input class="adDate" readOnly data-axbind="date" date_separator="." type="text" id="AXInput-1" kind="date" style="width: 102px;text-align: left;"  >
							</div>
						</td>
					</tr>
				</tbody>
			</table>
			<div class="ATMgt_memo_wrap">
				<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
					<tbody>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Memo' /></td>
							<td><textarea class="ATMgt_Tarea" id="memo"></textarea></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom mtop20">
				
					<c:choose> 
						<c:when test='${mngType eq "Y"}'>
							<a href="#" class="btnTypeDefault btnTypeBg" id="cancelBtn"><spring:message code='Cache.btn_att_del'/></a>
							<a href="#" class="btnTypeDefault btnTypeBg" id="saveBtn"><spring:message code='Cache.btn_att_upd'/></a>
						</c:when>
						<c:otherwise>
							<a href="#" class="btnTypeDefault btnTypeBg" id="cancelBtn"><spring:message code='Cache.lbl_n_att_requestDelete'/></a>
							<a href="#" class="btnTypeDefault btnTypeBg" id="saveBtn"><spring:message code='Cache.lbl_n_att_requestModify'/></a>
						</c:otherwise>						
					</c:choose>
				
				
				<a href="#" class="btnTypeDefault" onclick="parent.Common.close('AttExInfoPopup');"><spring:message code='Cache.lbl_close'/></a>
			</div>
		</div>				
	</div>
</div>

<table id="exTempTable" style="display:none;">
	<tr>
		<td rowspan='2' class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_overTimeHours'/></td>
		<td>
			<!-- <input class="adDate" data-axbind="date" date_separator="." type="text" id="" kind="date" style="width: 102px;text-align: left;"  > -->
			<select id="at_startHour" class='attSel' style="width:40px">
				<c:forEach begin="01" end="12" var="hour">
					<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>"><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
				</c:forEach>
			</select>
			<span>:</span>
			<select id="at_startMin" class='attSel' style="width:40px">
				<c:forEach begin="00" end="59" var="min">
					<option value="<c:out value="${ min < 10 ? '0' : '' }${min}"/>"><c:out value="${ min < 10 ? '0' : '' }${min}" /></option>
				</c:forEach>
			</select>
			<select id="at_startAP">
				<option value="AM">AM</option>
				<option value="PM">PM</option>
			</select>
		</td>
		<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_ac_time'/></td>
		<td>
			<input type="text" id="at_acHour" style="width:40px" readonly>
			 : 
			<input type="text" id="at_acMin" style="width:40px" readonly>
		</td>
	</tr>
	<tr>
		<td  class="ATMgt_T_Time wd">
			<!-- <input class="adDate" data-axbind="date" date_separator="." type="text" id="" kind="date" style="width: 102px;text-align: left;" > -->
			<select id="at_endHour" class='attSel' style="width:40px">
				<c:forEach begin="00" end="12" var="hour">
					<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>"><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
				</c:forEach>
			</select>
			<span>:</span>
			<select id="at_endMin" class='attSel' style="width:40px">
				<c:forEach begin="00" end="59" var="min">
					<option value="<c:out value="${ min < 10 ? '0' : '' }${min}"/>"><c:out value="${ min < 10 ? '0' : '' }${min}" /></option>
				</c:forEach>
			</select>
			<select id="at_endAP">
				<option value="AM">AM</option>
				<option value="PM">PM</option>
			</select>
			<input type="checkbox" id="NextDayYn" value="Y">
			<label for="NextDayYn"><spring:message code='Cache.lbl_NextDay'/></label> 	
		</td>
		<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_ldleTime'/></td>
		<td>
			<!-- 시간 : 분 형식이 아닌 분으로만 사용
			<select id="at_idleHour" class='attSel' style="width:40px">
				<c:forEach begin="00" end="12" var="hour">
					<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>"><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
				</c:forEach>
			</select>
			<span>:</span>
			<select id="at_idleMin" class='attSel' style="width:40px">
				<c:forEach begin="00" end="59" var="min">
					<option value="<c:out value="${ min < 10 ? '0' : '' }${min}"/>"><c:out value="${ min < 10 ? '0' : '' }${min}" /></option>
				</c:forEach>
			</select>
			-->
			<input type="text" name="IdleTime" id="IdleTime" value="0" style="width:100%" />
		</td>
	</tr>
</table>
<!-- 연장근무 일정 수정 팝업 끝 -->	
<input type="hidden" id="userCode" value="" />
<input type="hidden" id="exHoSeq" value="" />
</body>
<script>
var data = ${exList};
var _mngType = "${mngType}";

$(document).ready(function(){
	
	init();
	coviInput.setDate();
});

function setRecognizedTime() { // 인정 시간 자동 계산 함수
	var startHour = Number($("#at_startHour").val()); // 야근시간 : 시작 시간
	var startMin = Number($("#at_startMin").val());  // 야근시간 : 시작 분
	var startAP = $("#at_startAP").val(); // 야근 시간 : 시작 AM or PM
	var endHour = Number($("#at_endHour").val()); // 야근시간 : 종료 시간
	var endMin = Number($("#at_endMin").val()); // 야근시간 : 종료 분
	var endAP = $("#at_endAP").val(); // 야근 시간 : 종료 AM or PM
	var idleTime = Number($("#IdleTime").val() == "" ? 0 : $("#IdleTime").val()); // 유휴시간
	
	if(startAP == "PM") startHour += 12;
	if(endAP == "PM") endHour += 12;
	if($("#NextDayYn").is(":checked")) endHour += 24; // 익일 체크박스 표시되어 있는 경우.
	
	if(startHour > endHour) {
		Common.Warning("<spring:message code='Cache.mag_Attendance81'/>"); // 종료시간이 시작시간보다 작을 수 없습니다.
		return false;
	}
	else if(startHour == endHour && startMin > endMin) {
		Common.Warning("<spring:message code='Cache.mag_Attendance81'/>"); // 종료시간이 시작시간보다 작을 수 없습니다.
		return false;
	}

	var acHour = endHour - startHour;
	var acMin = endMin - startMin;
	
	if(acHour * 60 + acMin < idleTime) {
		$("#IdleTime").val('');
		Common.Warning("<spring:message code='Cache.msg_idleTimeBig'/>"); // 유휴시간이 정해진 시간보다 더 크게 입력되었습니다.
		return false;
	}
	
	var idleHour = parseInt(idleTime / 60);
	var idleMin = idleTime % 60;
	
	acHour -= idleHour;
	acMin -= idleMin;
	
	if(acMin < 0) {
		acHour -= 1;
		acMin = 60 + acMin;
	}
	
 	$("#at_acHour").val(acHour.toString().padStart(2, '0'));
	$("#at_acMin").val(acMin.toString().padStart(2, '0'));
	
	return true;
}

function init(){
	
	// 연장근무가 취소신청되었으나 미승인 중일 경우 조회값이 없음. 취소신청을 알리고 화면 닫음.
	if (data === undefined || data.length === 0) {
		Common.Warning("<spring:message code='Cache.lbl_att_approval_cancel'/> <spring:message code='Cache.msg_Processing'/>");  	// 취소신청 처리중입니다.
		parent.Common.close('AttExInfoPopup');
		return;
	}
	
	var exList = data[0];
	$("#userCode").val(exList.UserCode);
	$("#exHoSeq").val(exList.ExHoSeq);
	$(".tx_company").html(exList.DisplayName);
	
	$("#AXInput-1").val(exList.TargetDate);
	$("#memo").val(exList.Etc);

	//alert(exList.IdleTime);
	$("#IdleTime").val(exList.IdleTime);
	/*
		연장 근무 지정일 중복 등록 가능하도록
		- ! 2020.05.11 중복등록 불가하도록 협의
	*/
	/* var axCnt = 2;
	for(var i=0;i<exList.length;i++){
		var exStTr = $("#exTempTable tr").eq(0).clone();
		var exEdTr = $("#exTempTable tr").eq(1).clone();
		
		exStTr.find(".adDate").eq(0).attr("id","AXInput-"+axCnt++);
		exStTr.find(".adDate").eq(0).val(exList[i].StartDate);
		exStTr.find("#at_startHour").val(exList[i].StartHour);
		exStTr.find("#at_startMin").val(exList[i].StartMin);
		exStTr.find("#at_startAP").val(exList[i].StartAP);
		
		exEdTr.find(".adDate").eq(0).attr("id","AXInput-"+axCnt++);
		exEdTr.find(".adDate").eq(0).val(exList[i].EndDate);
		exEdTr.find("#at_endHour").val(exList[i].EndHour);
		exEdTr.find("#at_endMin").val(exList[i].EndMin);
		exEdTr.find("#at_endAP").val(exList[i].EndAP);
		
		exStTr.find("#at_acHour").val(exList[i].AcHour);
		exStTr.find("#at_acMin").val(exList[i].AcMin);
		exEdTr.find("#at_idleHour").val(exList[i].IdleHour);
		exEdTr.find("#at_idleMin").val(exList[i].IdleMin);

		$("#exTable").append(exStTr);
		$("#exTable").append(exEdTr);
	} */
	
	var exStTr = $("#exTempTable tr").eq(0).clone();
	var exEdTr = $("#exTempTable tr").eq(1).clone();
	
	exStTr.find(".adDate").eq(0).attr("id","AXInput-1");
	exStTr.find(".adDate").eq(0).val(exList.TargetDate);
	
	exStTr.find("#at_startHour").val(exList.StartHour);
	exStTr.find("#at_startMin").val(exList.StartMin);
	exStTr.find("#at_startAP").val(exList.StartAP);
	
	exEdTr.find("#at_endHour").val(exList.EndHour);
	exEdTr.find("#at_endMin").val(exList.EndMin);
	exEdTr.find("#at_endAP").val(exList.EndAP);
	
	var ndYn = false;
	if(exList.StartDate.replaceAll(".","")<exList.EndDate.replaceAll(".","")){
		ndYn = true;
	}
	exEdTr.find("#NextDayYn").prop("checked",ndYn);
	
	exStTr.find("#at_acHour").val(exList.AcHour);
	exStTr.find("#at_acMin").val(exList.AcMin);
	// exEdTr.find("#at_idleHour").val(exList.IdleHour);
	// exEdTr.find("#at_idleMin").val(exList.IdleMin);

	$("#exTable").append(exStTr);
	$("#exTable").append(exEdTr);
	
	$("#at_startHour, #at_startMin, #at_startAP, #at_endHour, #at_endMin, #at_endAP, #IdleTime , #NextDayYn").change(function() {
		setRecognizedTime();
	});
	
	$("#saveBtn").on('click',function(){
		if(!setRecognizedTime()) {
			Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>"); // 오류가 발생하였습니다.
			return;
		}
		setUserExStatus('U');
	});
	
	$("#cancelBtn").on('click',function(){
		setUserExStatus('D');
	});
}

function setUserExStatus(gubun){
	
	var aJsonArray = new Array();
	
	var targetDate = AttendUtils.dateToDBFormat(new Date($("#AXInput-1").val()));
	
	var stTime = AttendUtils.timeToDBFormat($("#at_startHour").val(),$("#at_startMin").val(),'',$("#at_startAP").val(),'');
	var edTime = AttendUtils.timeToDBFormat($("#at_endHour").val(),$("#at_endMin").val(),'',$("#at_endAP").val(),'');
	var nextDayYn = $("#NextDayYn").is(':checked')?"Y":"N";
	var acTime = $("#at_acHour").val()+$("#at_acMin").val();
	
	var idleTime = $("#IdleTime").val(); //분 형태로만 사용
	var comment = $("#memo").val();
	var bfStartTime = AttendUtils.timeToDBFormat(data[0].StartHour,data[0].StartMin,'', data[0].StartAP,'');
	var bfEndTime = AttendUtils.timeToDBFormat(data[0].EndHour,data[0].EndMin,'', data[0].EndAP,'');
	
	var saveData = {"UserCode" : $("#userCode").val(),"ExHoSeq" : $("#exHoSeq").val(), "WorkDate":targetDate, "StartTime":stTime, "EndTime":edTime, "NextDayYn":nextDayYn, "IdleTime":idleTime, "AcTime":acTime , "BfStartTime": bfStartTime, "BfEndTime": bfEndTime};
	aJsonArray.push(saveData);

	var reqType = "${reqType}";
	var saveJson ={
			"ReqType":reqType,
			"ReqGubun":gubun,
			"Comment":comment,
			"ReqData":aJsonArray
	}
	
	var url = "";
	if(_mngType == "Y"){
		url = "/groupware/attendUserSts/setUserExHoInfo.do";
	}else{
		if(reqType=="O"){
			url = "/groupware/attendReq/requestOverTime.do";
		}else if(reqType="H"){
			url = "/groupware/attendReq/requestHolidayWork.do";
		}
	}
	
	//insert 호출		
	 $.ajax({
		type:"POST",
		contentType:'application/json; charset=utf-8',
		dataType   : 'json',
          url : url,
          data : JSON.stringify(saveJson),
          success : function(data){
          	if(data.status=='SUCCESS'){
            	Common.Inform("<spring:message code='Cache.msg_Been_saved'/>","Information",function(){ //저장되었습니다.
    				parent.refreshList();
    				parent.Common.close('AttExInfoPopup');
            	});
          	}else{
          		Common.Warning("<spring:message code='Cache.msg_sns_03'/>"+data.dupFlag);
            }	
          },
          error:function(response, status, error){
              //TODO 추가 오류 처리
              CFN_ErrorAjax(url, response, status, error);
          }
      });
}
</script>
