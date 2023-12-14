<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop popContent ui-draggable" style="padding: 20px 24px 30px;">
	<div class="">
		<div class="top" style="height:150px;">
		
			<div class="ulList">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_vacationMsg49" /></strong></div>	<!-- 촉진유형 -->
						<div>
							<select class="selectType02" id="seColumn" style="width:200px;"></select>
						</div>
					</li>
					<!-- <li class="listCol">
						<div><strong>촉진찻수</strong></div>
						<div></div>
					</li> -->
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_vacationMsg50" /></strong></div>	<!-- 촉진월 -->
						<div>
							<input type="text" id="reqMonth" value="<fmt:formatNumber value="${result.ReqMonth }"/>" class="onlydecimal" style="width:50px;" maxlength="6" /> <spring:message code="Cache.lbl_before_month" /><!-- 개월전 -->
						</div>
					</li>											
					<li class="listCol">		
						<div><strong><spring:message code="Cache.lbl_vacationMsg51" /></strong></div>	<!-- 촉진기간 -->
						<div>
							<input type="text" id="reqTermDay" value="${result.ReqTermDay }" class="onlyNum" style="width:50px;" maxlength="2" /> <spring:message code="Cache.lbl_day" />	<!-- 일 -->
						</div>
					</li>	
					<!-- <li class="listCol">		
						<div><strong>정렬</strong></div>
						<div></div>
					</li> -->
				</ul>
			</div>
			
			<c:set var="reqOrd" value="0" />
			<c:if test="${result.ReqOrd ne null}"><c:set var="reqOrd" value="${result.ReqOrd}" /></c:if> 
			<input type="hidden" id="reqOrd" value="${reqOrd }" readonly class="onlyNum" style="width:50px;" maxlength="1" />
			<input type="hidden" id="reqOrder" value="${result.ReqOrder }" readonly class="onlyNum" style="width:50px;" maxlength="2" />	<!-- 정렬 -->
			
		</div>
		<div class="bottom" style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveVacation()"><spring:message code="Cache.btn_save" /></a>
			<a href="#" class="btnTypeDefault" onclick="javascript:Common.Close(); return false;"><spring:message code="Cache.lbl_close" /></a>
		</div>
	</div>
</div>

<script>

	initContent();

	function initContent(){
		
		coviCtrl.renderAXSelect('VacationPromotionDate', 'seColumn', lang, '', '','${result.ReqType }',false);
		$("#seColumn").bindSelectDisabled(true);
		
		onlyNumber($(".onlyNum"));
		onlyDecimal($(".onlydecimal"));
		
		//촉진찻수
		$('#seColumn' ).on( 'change', function(e){
			var reqType = $('#seColumn').val();
			
			var arr0 = new Array('Code1','Code4');
			var arr1 = new Array('Code2','Code5','Code7');
			var arr2 = new Array('Code3','Code6','Code8');
			
			var reqOrd = "";
			if(arr0.indexOf(reqType) > -1) reqOrd = "0"; 
			else if(arr1.indexOf(reqType) > -1) reqOrd = "1";
			else if(arr2.indexOf(reqType) > -1) reqOrd = "2";
			
			$('#reqOrd').val(reqOrd);
		});
	}
	
	// 저장
	function saveVacation() {
		
		var params = {
				reqType : $('#seColumn').val(),
				reqOrd : $('#reqOrd').val(),
				reqMonth : $('#reqMonth').val(),
				reqTermDay : $('#reqTermDay').val(),
				reqOrder : $('#reqOrder').val()
			};
		
      	Common.Confirm("<spring:message code='Cache.lbl_vacationMsg44' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
		 		$.ajax({
					type : "POST",
					data : params,
					url : "/groupware/vacation/updateVacationPromotionDate.do",
					success:function (data) {
						if (data.result == "ok") {
							if(data.status == 'SUCCESS') {
								Common.Inform("<spring:message code='Cache.lbl_vacationMsg45' />", "Inform", function() {
									closePopup();
									parent.search();
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
