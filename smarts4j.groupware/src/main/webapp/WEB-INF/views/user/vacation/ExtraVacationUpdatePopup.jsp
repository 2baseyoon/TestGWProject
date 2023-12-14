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
						<input type="hidden" id="year" value="${item.ExtVacYear}">
						<input type="hidden" id="vacKind" value="${item.ExtVacType}">
						<input type="hidden" id="urCode" value="${item.UR_Code}">
						<input type="hidden" id="extSdate" value="${item.ExtSdate}">
						<input type="hidden" id="extEdate" value="${item.ExtEdate}">
						<input type="hidden" id="registerCode" value="${item.RegisterCode}">
						<input type="hidden" id="oriExtVacDay" value="${item.ExtVacDay}">
						<li class="listCol">
							<div><strong><spring:message code="Cache.lbl_dept" /></strong></div>
							<div>
								<input type="text" class="inpFullSize" id="deptName" value="${item.DeptName}" readonly disabled>
							</div>
						</li>								
						<li class="listCol">
							<div><strong><spring:message code="Cache.lbl_username" /></strong></div>
							<div>
								<input type="text" class="inpFullSize" id="displayName" value="${item.DisplayName}" readonly disabled>
							</div>
						</li>
						<li class="listCol">
							<div><strong><spring:message code="Cache.lbl_JobLevel" /></strong></div>
							<div>
								<input type="text" class="inpFullSize" id="jobPositionName" value="${item.JobPositionName}" readonly disabled>
							</div>
						</li>
						<li class="listCol">
							<div><strong><spring:message code="Cache.VACATION_TYPE_VACATION_TYPE" /></strong></div>
							<div>
								<input type="text" class="inpFullSize"  value="${item.ExtVacName}" readonly disabled>
							</div>
						</li>
						<li class="listCol">
							<div><strong><spring:message code="Cache.lbl_expiryDate" /></strong></div>
							<div>
								<input type="text" style="width:45%;" id="sDate" value="${item.ExtSdate}" maxlength="8" readonly disabled>
								&nbsp;&nbsp;&nbsp;~&nbsp;&nbsp;&nbsp;
								<input type="text" style="width:45%;" id="eDate" value="${item.ExtEdate}" maxlength="8" readonly disabled>
							</div>
						</li>
						<li class="listCol">
							<div><strong><spring:message code="Cache.lbl_Vacation" /></strong></div>
							<div>
								<input type="text" class="inpFullSize" id="vacDay" value="${item.ExtVacDay}" maxlength="6">
							</div>
						</li>
						<li class="listCol">
							<div><strong><spring:message code="Cache.lbl_Reason" /></strong></div>
							<div>
								<input type="text" class="inpFullSize" id="comment" value="" maxlength="500">
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
			vacKind : $('#vacKind').val(),
			sDate : $('#sDate').val(),
			eDate : $('#eDate').val(),
			extSdate : $('#extSdate').val(),
			extEdate : $('#extEdate').val(),
			vacDay : $('#vacDay').val(),
			oriExtVacDay: $('#oriExtVacDay').val(),
			comment : $('#comment').val(),
			registerCode : $('#registerCode').val()
		};
		
      	Common.Confirm("<spring:message code='Cache.lbl_vacationMsg69' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : params,
					url : "/groupware/vacation/updateExtraVacDay.do",
					success:function (data) {
						if (data.result == "ok") {
							if(data.status == 'SUCCESS') {
								Common.Inform("<spring:message code='Cache.msg_Edited' />", "Inform", function() {
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
