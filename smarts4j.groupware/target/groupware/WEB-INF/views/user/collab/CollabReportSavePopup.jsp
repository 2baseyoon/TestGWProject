<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/collab_util.js"></script>
<body>	
<div class="collabo_popup_wrap">
<form id="form1">
	<div class="c_titBox">
		<h3 class="cycleTitle"><spring:message code='Cache.BizSection_Report' /> <spring:message code='Cache.lbl_detail' /></h3> <!-- 업무보고 상세 -->
	</div>
	<div class="collabo_table_wrap mb40">
		<table class="collabo_table">
			<colgroup>
				<col width="106">
				<col width="*">
				<col width="106">
				<col width="*">
			</colgroup>
			<tr>
				<th><spring:message code='Cache.ACC_lbl_projectName'/></th>
				<td colspan=3>${reportData.PrjName==''?'<spring:message code="Cache.lbl_MyWork" />':reportData.PrjName}</td> <!-- 내업무 -->
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_workname'/></th>
				<td colspan=3>${reportData.TaskName}</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.CPMail_Status'/></th>
				<td colspan=3>
					<div class="chkStyle10">
						<input type="checkbox" class="check_class" id="chk1" value="W" ${reportData.TaskStatus=='W'?'checked':'' }>
						<label for="chk1"><span class="s_check"></span><spring:message code='Cache.lbl_Ready' /></label> <!-- 대기 -->
					</div>
					<div class="chkStyle10">
						<input type="checkbox" class="check_class" id="chk3" value="P" ${reportData.TaskStatus=='P'?'checked':'' }>
						<label for="chk3"><span class="s_check"></span><spring:message code='Cache.lbl_Progress' /></label> <!-- 진행 -->
					</div>
					<div class="chkStyle10">
						<input type="checkbox" class="check_class" id="chk4" value="H" ${reportData.TaskStatus=='H'?'checked':'' }>
						<label for="chk4"><span class="s_check"></span><spring:message code='Cache.lbl_Hold' /></label> <!-- 보류 -->
					</div>
					<div class="chkStyle10">
						<input type="checkbox" class="check_class" id="chk5" value="C" ${reportData.TaskStatus=='C'?'checked':'' }>
						<label for="chk5"><span class="s_check"></span><spring:message code='Cache.lbl_Completed' /></label> <!-- 완료 -->
					</div>
			</tr>	
			<tr>	
				<th><spring:message code='Cache.lbl_TFProgressing'/></th>
				<td><input type="text" class="tx_status w100" id="progRate" name="progRate" value="${reportData.ProgRate }"/></td>
				<th><spring:message code='Cache.lbl_ProcessingTime'/></th>	<!-- 처리시간 -->
				<td><input type="text" class="tx_status w100" id="taskTime" name="taskTime" value="${reportData.TaskTime }"/></td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_Memo'/></th>
				<td colspan=3><textarea id="remark" name="remark">${reportData.Remark}</textarea></td>
			</tr>
		</table>

		<div class="popBtnWrap">
			<c:if test="${reportData.DaySeq !='' && reportData.DaySeq ne null  }">
				<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.lbl_SaveTask'/></a>
			</c:if>
			
			<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.lbl_Cancel'/></a>
		</div>
	</div>
</form>	
</div>
</body>
<script type="text/javascript">
var collabReportAdd = {
		objectInit : function(){			
			this.addEvent();
		},
		addEvent : function(){
			$("#btnSave").on('click', function(){
				if(!collabReportAdd.validationChk()) return;
				var reportData = collabReportAdd.getReportData();

				$.ajax({
					type:"POST",
					data: reportData,
					dataType: 'json',
					processData: false,
					contentType: false,
					url:"/groupware/collabReport/updateReportDay.do",
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>", "Confirmation Dialog", function (confirmResult) {
								parent.collabTodo.getUserReportDayList();
								parent.collabTodo.getUserReportWeek(1);
								Common.Close();
							});
						} else {
							Common.Error(data.message);
						}
					},
					error:function (request,status,error){
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
					}
				});
			});

			$(".check_class").click(function() {
				 $('.check_class').not(this).prop("checked", false);
			});

			
			$("#btnClose").on('click', function(){
				Common.Close();
			});

			$(document).on('click', '.ui-icon-close', function(e) {
				e.preventDefault();
				$(this).parent().remove();
			});

		},
		getReportData:function(){
			var formData = new FormData($('#form1')[0]);

			formData.append("taskStatus", $('.check_class:checked').val());
			formData.append("daySeq", "${reportData.DaySeq}");
			formData.append("taskSeq", "${reportData.TaskSeq}");

			return formData;
		},
		validationChk:function(){
			var returnVal= true;
			 	
			if ($('.check_class:checked').length == 0){
				Common.Warning("<spring:message code='Cache.msg_task_selectState'/>");
			    return false;
			}

			if ($('#progRate').val() == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterTheRequiredValue'/>".replace("{0}", "<spring:message code='Cache.lbl_TFProgressing' />"));
			    return false;
			}

			if(!(0 <= $("#progRate").val() && $("#progRate").val() <= 100)){
				Common.Warning("<spring:message code='Cache.msg_checkPercent'/>", "Warning Dialog") //진행율을 0~100 이하로 입력해주세요.
				return false;
			}
			
			if ($('#taskTime').val() == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterTheRequiredValue'/>".replace("{0}", "<spring:message code='Cache.lbl_ProcessingTime' />"));
			    return false;
			}
			
			return returnVal;
	 }	
}

$(document).ready(function(){
	collabReportAdd.objectInit();
});

</script>