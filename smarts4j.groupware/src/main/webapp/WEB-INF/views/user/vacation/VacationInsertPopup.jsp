<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent extensionAddPopup" style="padding: 20px 24px 30px;">
	<div class="">
		<div class="top" style="height:157px;">
			<div class="schShareList">
				<ul>
					<li class="listCol" id="listHeader">
						<div><span><spring:message code="Cache.lbl_dept" /></span></div>
						<div><span><spring:message code="Cache.lbl_username" /></span></div>
						<div><span><spring:message code="Cache.lbl_JobLevel" /></span></div>
						<div><span><spring:message code="Cache.lbl_apv_Vacation_days" /></span></div>
					</li>
					<li class="listCol" id="listColNotice">
						<div><span>조직도에서 연차 생성 대상을 선택해 주세요.</span></div>
					</li>
				</ul>
			</div>	
		</div>
		<div class="bottom" style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveVacation()"><spring:message code="Cache.btn_save" /></a>
			<a href="#" class="btnTypeDefault" onclick="parent.openOrgMapLayerPopup()"><spring:message code="Cache.lbl_apv_org" /></a>
			<a href="#" class="btnTypeDefault" onclick="javascript:Common.Close(); return false;"><spring:message code="Cache.lbl_close" /></a>
		</div>
	</div>
</div>

<script>
	var year = CFN_GetQueryString("year");
	
	initContent();

	function initContent(){
		
	}
	
	// 저장
	function saveVacation() {
		var tar = $('.listCol').not('#listHeader').not('#listColNotice');
		var tempObj = new Object();
		var vacationArr = new Array();
		
		if(tar.length < 1){
			Common.Warning("<spring:message code='Cache.lbl_apv_SelectEmployee'/>"); //등록할 직원을 선택하시기 바랍니다.
			return ;
		}
		
		$.each(tar, function (i, v) {
			tempObj = new Object();
			tempObj.urCode = $(v).attr('value');
			tempObj.vacDay = $(v).find('input').val() != "" ? $(v).find('input').val() : "0";
			tempObj.year = year;
			
			vacationArr.push(tempObj);
		});
		
       	Common.Confirm("<spring:message code='Cache.msg_155' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					contentType : 'application/json; charset=utf-8',
					data : JSON.stringify({vacations : vacationArr}),
					url : "/groupware/vacation/insertNextVacation.do",
					success:function (data) {
						if (data.result == "ok") {
							if(data.status == 'SUCCESS') {
								Common.Inform("<spring:message code='Cache.msg_37' />", "Inform", function() {
									parent.Common.Close("target_pop");
									
									parent.search();
								});
			          		} else {
			          			Common.Warning("<spring:message code='Cache.msg_apv_030' />");
			          		}
						} else {
							Common.Inform(data.message, "Inform", function() {
								parent.Common.Close("target_pop");
							});
						}
					},
					error:function(response, status, error) {
						CFN_ErrorAjax("/groupware/vacation/insertNextVacation.do", response, status, error);
					}
				});		 		
			} else {
				return false;
			}
		});
	}	
</script>
