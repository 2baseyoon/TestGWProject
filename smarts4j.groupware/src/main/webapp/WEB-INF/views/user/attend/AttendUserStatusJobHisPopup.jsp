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
</style>
<body>	
<!-- 외근기록 수정 팝업 시작 -->
<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="" style="overflow:hidden; padding:0;">
		<div class="ATMgt_popup_wrap">
			<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
				<tbody>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_worktype' />/<spring:message code='Cache.lbl_SmartDept' /></td>
						<td><p class="tx_dept"></p></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_Staff' /></td>
						<td><p class="tx_company"></p></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_selectWorkSchTemp' /></td>
						<td><p class="tx_template"></p></td>
					</tr>
					<tr> 
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_date' /></td>
						<td><div class="dateSel type02"><input class="adDate" readOnly data-axbind="date" date_separator="."  type="text" id="AXInput-1" kind="date" ></div></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_806_h_3' /></td> 
						<td>
							<select id="tx_jobSts"></select>
						</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_applicationTime' /></td> 
						<td>
							<div class="ATMgt_T_Time">
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
								
								<span>~</span>
								
								<select id="at_endHour" class='attSel' style="width:40px">
									<c:forEach begin="01" end="12" var="hour">
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
							</div>
						</td>
					</tr>
					<!-- <tr>
						<td class="ATMgt_T_th">위치</td>
						<td><a href="#" class="popup_map_img"><img src="/HtmlSite/smarts4j_n/AttendanceManagement/resources/images/img_map.jpg" alt=""></a></td>
					</tr> -->
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Memo' /></td>
						<td><textarea class="ATMgt_Tarea" id="memo"></textarea></td>
					</tr>
				</tbody>
			</table>
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
				<a href="#" class="btnTypeDefault" onclick="parent.Common.close('AttJobHisInfoPopup');"><spring:message code='Cache.lbl_close'/></a>
			</div>
		</div>				
	</div>
</div>
<!-- 외근기록 수정 팝업 끝 -->
<input type="hidden" id="userCode" value="" />

</body>
<script>
var data = ${data};
var _mngType = "${mngType}";

$(document).ready(function(){
	init();
	coviInput.setDate();
});

function init(){
	var userAtt = data.userAtt;
	var jobHistory = data.jobHistory;
	var jobStsList = data.jobStsList;
	
	$(".tx_dept").html(userAtt.DeptName);
	$(".tx_company").html(userAtt.DisplayName);
	$(".tx_template").html(userAtt.SchName);
	$(".adDate").val(userAtt.TargetDate);
	
	var jobStsHtml = "";
	for(var i=0;i<jobStsList.length;i++){
		if(_mngType != "Y"){
			if(jobStsList[i].JobStsSeq == jobHistory.JobStsSeq){
				jobStsHtml += "<option value='"+jobStsList[i].JobStsSeq+"' >";
				jobStsHtml += jobHistory.JobStsName;
				if(jobStsList[i].JobStsName!=jobHistory.JobStsName){
					jobStsHtml += "["+jobStsList[i].JobStsName+"]";
				}
				jobStsHtml += "</option>";
			}
		}else{
			jobStsHtml += "<option value='"+jobStsList[i].JobStsSeq+"' ";
			if(jobStsList[i].ValidYn != "Y"){
				jobStsHtml += "disabled";
			}
			jobStsHtml += ">";
			jobStsHtml += jobStsList[i].JobStsName+"</option>";
		}
	}
	$("#tx_jobSts").html(jobStsHtml);
	$("#tx_jobSts").val(jobHistory.JobStsSeq);
	
	$("#at_startHour").val(jobHistory.v_StartHour);
	$("#at_startMin").val(jobHistory.v_StartMin);
	$("#at_startAP").val(jobHistory.v_StartAP);
	
	$("#at_endHour").val(jobHistory.v_EndHour);
	$("#at_endMin").val(jobHistory.v_EndMin);
	$("#at_endAP").val(jobHistory.v_EndAP);
	
	$("#userCode").val(userAtt.UserCode);
	
	$(".ATMgt_Tarea").val(jobHistory.Etc);
	
	//변경사항 저장
	$("#saveBtn").on('click',function(){
		setUserJobHistory('U');
	});
	$("#cancelBtn").on('click',function(){
		setUserJobHistory('D');
	});
}

function setUserJobHistory(gubun){
	//if(jobHisValidCheck()){ }	//validation 추가
	var aJsonArray = new Array();
	
	var targetDate = AttendUtils.dateToDBFormat(new Date($("#AXInput-1").val()));
	
	var stTime = AttendUtils.timeToDBFormat($("#at_startHour").val(),$("#at_startMin").val(),'',$("#at_startAP").val(),'');
	var edTime = AttendUtils.timeToDBFormat($("#at_endHour").val(),$("#at_endMin").val(),'',$("#at_endAP").val(),'');
	var jobStsSeq = $("#tx_jobSts").val()==null?data.jobHistory.JobStsSeq:$("#tx_jobSts").val();
	var jobStsName = $("#tx_jobSts :selected").html();
	var jobStsHisSeq = data.jobHistory.JobStsHisSeq;
	var comment = $("#memo").val();

	var saveData = {"UserCode" : $("#userCode").val(), "JobStsHisSeq":jobStsHisSeq, "JobStsSeq":jobStsSeq, "JobStsName": jobStsName, "WorkDate":targetDate, "StartTime":stTime, "EndTime":edTime
			, "BfStartTime":data.jobHistory.StartTime, "BfEndTime":data.jobHistory.EndTime};
    aJsonArray.push(saveData);

	var saveJson ={
			"ReqType":"J",
			"ReqGubun":gubun,
			"Comment":comment,
			"ReqData":aJsonArray
	}
	
	
	
	var url = "";
	if(_mngType == "Y"){
		url = "/groupware/attendUserSts/setUserJobHisInfo.do";
	}else{
		url = "/groupware/attendReq/requestJobStatus.do";
	}

	//insert 호출		
	$.ajax({
		type:"POST",
		contentType:"application/json; charset=utf-8",
		dataType   : "json",
           url : url,
           data : JSON.stringify(saveJson),
           success : function(data){	
           	if(data.status=='SUCCESS'){
           		Common.Inform("<spring:message code='Cache.msg_Been_saved'/>","Information",function(){ //저장되었습니다.
           			if (parent.$("#AttendMyStstusPopup_if").length > 0) {
           				parent.$("#AttendMyStstusPopup_if")[0].contentWindow.refreshList();	
           			} else {
           				parent.refreshList();
           			}
    				parent.Common.close('AttJobHisInfoPopup');
            	});
           	}else{
           		Common.Warning("<spring:message code='Cache.msg_att_overlapping'/>"); 
           	}
           },
           error:function(response, status, error){
               //TODO 추가 오류 처리
               CFN_ErrorAjax("attendReq/requestJobStatus.do", response, status, error);
           }
       });
	
}


function jobHisValidCheck(){
	
}


</script>
