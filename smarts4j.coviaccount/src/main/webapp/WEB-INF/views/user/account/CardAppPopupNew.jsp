<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div>
	<form name="myForm" method="post">
	<table class="tableTypeRow">
		<colgroup>
			<col style="width: 20%;" />
			<col style="width: auto;" />
			<col style="width: 20%;" />
			<col style="width: auto;" />
		</colgroup>
		<tbody>
<%--
			<tr>				<!-- 카드번호 -->
				<th><spring:message code="Cache.ACC_lbl_cardNumber"/><span class="star"></span></th>
				<td>
					<div class="box">
						<div class="searchBox02">
							<span id="cardAppPopupLimitChange_inputCardNo" class="selectType02" onChange="CardApplicationPopup.onCardChange(this, 'cardAppPopupLimitChange')">
							</span>
						</div>	
					</div>
				</td>			<!-- 유효기간 -->
				<th><spring:message code="Cache.ACC_lbl_expiryDate"/></th>
				<td>
					<div class="box">
						<input id="cardAppPopupLimitChange_inputExpirationDate" type="text" disabled="true">
					</div>
				</td>
			</tr>
			<tr>				<!-- 현재한도금액 -->
				<th><spring:message code="Cache.ACC_lbl_limitAmt"/></th>
				<td>
					<div class="box">
						<input id="cardAppPopupLimitChange_inputCurrentAmount" type="text" disabled="true" style="text-align: right;">
					</div>
				</td>			<!-- 요청구분 -->
				<th><spring:message code="Cache.ACC_lbl_requestType"/></th>
				<td>
					<div class="box" >
						<input id="cardAppPopupLimitChange_inputLimitTypeView" type="text" disabled="true" disabled="true">
					</div>
					<div class="box" style="display:none" >
						<span id="cardAppPopupLimitChange_inputLimitType" class="selectType02" disabled="true">
						</span>
					</div>
				</td>
			</tr>
			<tr>				<!-- 변경한도금액 -->
				<th><spring:message code="Cache.ACC_lbl_changeLimitAmount"/><span class="star"></span></th>
				<td colspan="3">
					<div class="box">
						<span id="cardAppPopupLimitChange_inputApplicationAmountCombo" class="selectType02" 
						onChange="CardApplicationPopup.onAppAmtChange(this)" >
						</span>
						<input id="cardAppPopupLimitChange_inputApplicationAmount" type="text" style="text-align: right;" onkeyup = "removeChar(this)"
						 kind="money" money_max="99999999999" money_min="0" onChange="CardApplicationPopup.onAppAmtFieldChange(this)"  />
					</div>
				</td>
			</tr>
			<tr id="chgExpDateArea" style="display:none">
				<th><spring:message code="Cache.ACC_lbl_changeExpDate"/></th>
				<td>
					<div class="box">
						<div id="cardAppPopupLimitChange_inputChangeExpirationDate"></div>
					</div>
				</td>
			</tr>
		 --%>	
			 
			<tr style="height:150px">		<!-- 신청사유 -->
				<th><spring:message code="Cache.ACC_lbl_applicationReason"/></th>
				<td colspan="3">
					<div class="box" style="width:100%;">
						<textarea id="cardAppPopupNew_inputApplicationReason" row="10" style="height:135px" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
	</form>
</div>
<script>


//카드 신청 한도변경
	if (!window.CardAppPopupNew) {
		window.CardAppPopupNew = {};
	}	
	
	(function(window) {
		
		var CardAppPopupNew = {
						
				//화면에 값 세팅
				setCardNewissueData: function(data){
					var me = this;
					setFieldDataPopup("cardAppPopupNew_inputApplicationReason",data.ApplicationReason );
				},

				//화면값 획득
				getCardNewissueData : function(){
					CardApplicationPopup.params.pageDataObj.ApplicationClass 	= 'CO'
					CardApplicationPopup.params.pageDataObj.ApplicationReason	= getTxTFieldDataPopup("cardAppPopupNew_inputApplicationReason");
					return;
				},

			
		}
		window.CardApplicationPopup = $.extend(window.CardApplicationPopup, CardAppPopupNew);
	})(window);
	
</script>