<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" style="padding: 0px 24px 30px;">
	<div class="">
		<div class="top">						
			<div class="ulList type03">
				<ul>
					<c:forEach var="item" items="${result.list}">
						<input type="hidden" id="year" value="${item.YEAR}">
						<input type="hidden" id="urCode" value="${item.UR_Code}">
						<input type="hidden" id="oriVacDay" value="${item.LastVacDay == 0.0 && item.LongVacDay == 0.0 ? item.VacDay: item.LongVacDay}">
						<input type="hidden" id="UseStartDate" value="${item.UseStartDate}">
						<input type="hidden" id="UseEndDate" value="${item.UseEndDate}">
						<input type="hidden" id="RegisterCode" value="${item.RegisterCode}">
						<li class="listCol">
							<div><strong><spring:message code="Cache.lbl_dept" /></strong></div>
							<div>
								<input type="text" disabled class="inpFullSize" id="deptName" value="${item.DeptName}" readonly>
							</div>
						</li>								
						<li class="listCol">
							<div><strong><spring:message code="Cache.lbl_username" /></strong></div>
							<div>
								<input type="text" disabled class="inpFullSize" id="displayName" value="${item.DisplayName}" readonly>
							</div>
						</li>								
						<li class="listCol">
							<div><strong><spring:message code="Cache.lbl_JobLevel" /></strong></div>
							<div>
								<input type="text" disabled class="inpFullSize" id="jobPositionName" value="${item.JobPositionName}" readonly>
							</div>
						</li>								
						<c:if test="${item.LastVacDay > 0.0 }">
						<li class="listCol">
							<div><strong><spring:message code="Cache.lbl_vacationMsg64" /><spring:message code="Cache.VACATION_TYPE_VACATION_ANNUAL" /></strong></div> <!-- 이월연차 -->
							<div>
								<input type="text" disabled class="inpFullSize" id="LastVacDay" value="${item.LastVacDay}" readonly>
							</div>
						</li>								
						</c:if>
						<li class="listCol">
							<div><strong><spring:message code="Cache.lbl_TotalVacation" /></strong></div>
							<div>
								<input type="text" class="inpFullSize" id="vacDay" value="${item.LastVacDay == 0.0 && item.LongVacDay == 0.0 ? item.VacDay: item.LongVacDay}">
							</div>
						</li>
						<li class="listCol">
							<div><strong><spring:message code="Cache.lbl_Reason" /></strong></div> <!-- 사유 -->
							<div>
								<input type="text" class="inpFullSize" maxlength="480" id="vmComment">
							</div>
						</li>
					</c:forEach>								
				</ul>							
			</div>
		</div>
		<div class="bottom" style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="updateVacDay()"><spring:message code='Cache.btn_Modify' /></a>
			<a href="#" class="btnTypeDefault" onclick="closePopup();"><spring:message code='Cache.btn_Close' /></a>
		</div>
	</div>
</div>

<script>
	var grid = new coviGrid();
	
	initContent();

	function initContent() {
		
	}
	
	// 수정
	function updateVacDay() {
		var params = {
			year : $('#year').val(),
			urCode : $('#urCode').val(),
			vacDay : $('#vacDay').val(),
			oriVacDay :  $('#oriVacDay').val(),
			UseStartDate : $('#UseStartDate').val(),
			UseEndDate : $('#UseEndDate').val(),
			RegisterCode : $('#RegisterCode').val(),
			vmComment : $('#vmComment').val(),
			vacKind : "PUBLIC"
		};
		
      	Common.Confirm("<spring:message code='Cache.lbl_vacationMsg44' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : params,
					url : "/groupware/vacation/updateVacDay.do",
					success:function (data) {
						if (data.result == "ok") {
							if(data.status == 'SUCCESS') {
								Common.Inform("<spring:message code='Cache.lbl_vacationMsg45' />", "Inform", function() {
									closePopup();
									parent.$(".btnRefresh").trigger("click");
								});
			          		} else {
			          			Common.Warning("<spring:message code='Cache.msg_apv_030' />");
			          		}
						}
					},
					error:function(response, status, error) {
						CFN_ErrorAjax(url, response, status, error);
					}
				});
			} else {
				return false;
			}
		});		
	}

	// 닫기
	function closePopup() {
		parent.Common.Close("target_pop");
	}
	
</script>
