<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" style="padding: 20px 24px 30px;">
	<div class="">
		<div class="top">						
			<div class="ulList type03">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_dept" /></strong></div>
						<div>
							<input type="text" value="${result.list[0].DeptName}" readonly>
						</div>
					</li>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_username" /></strong></div>
						<div>
							<input type="text" value="${result.list[0].DisplayName}" readonly>
						</div>
					</li>
					<li class="listCol">
						<div><strong><spring:message code="Cache.VACATION_TYPE_VACATION_TYPE" /></strong></div>
						<div>
 							<select class="selectType01">
								<option>${result.list[0].VacYear}</option>
							</select>
							<select class="selectType01" id="selVacOffFlag" style="display:none;"></select>
							<select class="selectType01">
								<option>${result.list[0].VacFlagName}</option>
							</select>
						</div>
						<input type="hidden" id="vacDay" value="${result.list[0].VacDay}">
						<input type="hidden" id="processID" value="${result.list[0].ProcessID}">
						<input type="hidden" id="vacationInfoID" value="${result.list[0].VacationInfoID}">
					</li>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_apv_RequestDate" /></strong></div>
						<div>
							<div class="dateSel type02">											
								<input class="adDate" type="text" id="QSDATE1" value="${result.list[0].Sdate}" readonly>										
								<span>~</span>
								<input class="adDate" type="text" id="QEDATE1" value="${result.list[0].Edate}" readonly>
								<span id="aSpan"></span>
							</div>
						</div>
					</li>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_apv_CancelDate" /></strong></div>
						<div>
							<div class="dateSel type02">
								<input type="text" id="startDate" class="adDate" date_separator="-"/> ~ <input type="text" kind="twindate" date_startTargetID="startDate" id="endDate" date_separator="-" class="adDate" />
							</div>
						</div>
					</li>									
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_apv_CancelReason" /></strong></div>
						<div>
							<input type="text" class="inpFullSize HtmlCheckXSS ScriptCheckXSS" id="reason">
						</div>
					</li>
					<%-- <li class="listCol">
						<div><strong><spring:message code="Cache.lbl_apv_RefDocNo" /></strong></div>
						<div>
							<input type="text" class="HtmlCheckXSS ScriptCheckXSS"><a href="#" class="btnTypeDefault " onclick="openVacationCancelDocPopup()"><spring:message code="Cache.lbl_apv_doclink" /></a>
						</div>
					</li> --%>
				</ul>							
			</div>
		</div>
		<div class="bottom " style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="insertVacationCancel()"><spring:message code='Cache.btn_apv_approve_cancel' /></a>
			<a href="#" class="btnTypeDefault " onclick="Common.Close()"><spring:message code='Cache.btn_Close' /></a>
		</div>
	</div>
</div>
			
<script>
	var data = ${result.list[0]};
	var vacYear = data.VacYear;
	var urCode = data.UR_Code;
	var vacFlag = data.VacFlag;
	var vacOffFlag = data.VacOffFlag;
	var sDate = data.Sdate;
	var eDate = data.Edate;
	var formKey = new Array();
	
	initContent();

	function initContent() {
		$('#aSpan').html('(' + calcDays(sDate, eDate) + "<spring:message code='Cache.lbl_day'/>" + ')');
		
		$('#startDate').val(sDate.replaceAll(".", "-"));
		$('#endDate').val(eDate.replaceAll(".", "-"));
		
		if(vacOffFlag && vacOffFlag != "0") {
			$("#selVacOffFlag").append("<option>" + (vacOffFlag == "AM" ? "오전" : "오후") + "</option>").show();
		}
	}
	
	// 등록
 	function insertVacationCancel() {
 		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

 		var sDate =  $('#startDate').val();
 		var eDate =  $('#endDate').val();
		
		var params = {
			vacYear : vacYear,
			urCode : urCode,
			vacFlag : vacFlag,
			vacOffFlag : vacOffFlag,
			gubun: data.GUBUN,
			sDate : sDate,
			eDate : eDate,
			reason : $('#reason').val(),
			vacDay : -1 * parseFloat($("#vacDay").val()),
			processId : $("#processID").val(),
			vacationInfoID : $("#vacationInfoID").val()
		};
		if (formKey.length > 0) {
			params.workItemId = formKey[0].split(';')[0];
			params.processId = formKey[0].split(';')[1];
		} else {
			params.workItemId = "";
			params.processId = $("#processID").val();
		}

   		$.ajax({
			type : "POST",
			data : params,
			async: false,
			url : "/groupware/vacation/insertVacationCancel.do",
			success: function (list) {
				if(list.status == "SUCCESS"){
					if(list.data > 0){
						Common.Inform("<spring:message code='Cache.lbl_vacationMsg27' />", "Inform", function(){
							parent.Common.Close("target_pop");
							parent.vacationVacationCancelManager.search();
						});
					}else{
						Common.Warning("<spring:message code='Cache.msg_noCancelData' />"); // 취소할 데이터가 없습니다.
					}
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생헸습니다.
				}
			},
			error: function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
 	// 문서연결
	/* function openVacationCancelDocPopup() {
		CFN_OpenWindow("/groupware/vacation/goVacationCancelDocPopup.do?urCode="+urCode, "", 1100, 600, "resize");
	} */
 	
	// 날짜 계산
	function calcDays(sDate, eDate) {
		var days;
		
		if($("#vacDay").val() == "0.5") {
			days = "0.5";
		} else {
			days = new Date(new Date(eDate) - new Date(sDate)) / (1000 * 60 * 60 * 24) + 1;
		}
		
		return days;
	}
</script>
