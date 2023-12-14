<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div>
	<table class="tableTypeRow">
		<colgroup>
			<col style="width: 20%;" />
			<col style="width: auto;" />
			<col style="width: 20%;" />
			<col style="width: auto;" />
		</colgroup>
		<tbody>
			<tr>		<!-- 카드번호 -->
				<th><spring:message code="Cache.ACC_lbl_cardNumber"/><span class="star"></span></th>
				<td colspan="3">
					<div class="box">
						<div class="searchBox02">
							<span id="cardAppPopupClose_inputCardNo" class="selectType02" onChange="CardApplicationPopup.onCardChange(this, 'cardAppPopupClose')">
							</span>
						</div>	
					</div>
				</td>
			</tr>
			<tr>		<!-- 유효기간 -->
				<th><spring:message code="Cache.ACC_lbl_expiryDate"/></th>
				<td>
					<div class="box">
						<input id="cardAppPopupClose_inputExpirationDate" type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>	<!-- 현재한도금액 -->
				<th><spring:message code="Cache.ACC_lbl_limitAmt"/></th>
				<td>
					<div class="box">
						<input id="cardAppPopupClose_inputCurrentAmount" type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>
			</tr>
			<tr style="height:150px">	<!-- 신청사유 -->
				<th><spring:message code="Cache.ACC_lbl_applicationReason"/></th>
				<td colspan="3">
					<div class="box" style="width:100%;">
						<textarea id="cardAppPopupClose_inputApplicationReason" row="10" style="height:135px" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</div>
<script>
	//카드신청 해지
	if (!window.CardAppPopupClose) {
		window.CardAppPopupClose = {};
	}	

	(function(window) {
		
		var CardAppPopupClose = {
				closeComboInitComp : false,
				closeComboInit : function(inputCardList){
					var me = this;
					var cardList = inputCardList;
					/* if(cardList == null){
						return;
					}
					
					if(cardList.length==0){
						return;
					} */
					accountCtrl.createAXSelectData("cardAppPopupClose_inputCardNo",cardList, "<spring:message code='Cache.ACC_lbl_choice'/>", 'CardNo', 'CardNoView', null, null, null  )
					me.closeComboInitComp = true;										
				},
				
				closeComboRefresh : function(){
					var me = this;
					if(!me.closeComboInitComp){
						return
					}
					var list = "cardAppPopupClose_inputCardNo"
					accountCtrl.refreshAXSelect(list);
				},

				setCardCloseData : function(data){
					accountCtrl.getComboInfo("cardAppPopupClose_inputCardNo").bindSelectSetValue(data.CardNo);
					setFieldDataPopup("cardAppPopupClose_inputApplicationReason",data.ApplicationReason );
				},
				
				getCardCloseData : function(){
					CardApplicationPopup.params.pageDataObj.ApplicationClass	= 'CO'
					CardApplicationPopup.params.pageDataObj.CardNo 				= accountCtrl.getComboInfo("cardAppPopupClose_inputCardNo").val();
					CardApplicationPopup.params.pageDataObj.ApplicationReason	= getTxTFieldDataPopup("cardAppPopupClose_inputApplicationReason");
					return;
				},
				
				checkCardClose : function(){
					var msg = "<spring:message code='Cache.ACC_msg_case_2' />";	//[{0}] 필수 입력값 입니다.

					if(isEmptyStr(CardApplicationPopup.params.pageDataObj.CardNo)){
						msg = msg.replace("{0}", "<spring:message code='Cache.ACC_lbl_cardNumber' />");
						return msg;
					}
					return "";
				}
		}
		window.CardApplicationPopup = $.extend(window.CardApplicationPopup, CardAppPopupClose);
	})(window);
	
</script>