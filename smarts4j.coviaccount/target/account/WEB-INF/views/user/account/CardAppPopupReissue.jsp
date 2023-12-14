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
			<tr>				<!-- 재발급 구분 -->
				<th><spring:message code="Cache.ACC_lbl_cardReissueType"/><span class="star"></span></th>
				<td>
					<div class="box">
						<div class="searchBox02">
							<span>
								<span id="cardAppPopupReissue_inputReissuanceType" class="selectType02" >
								</span>
							</span>
						</div>	
					</div>
				</td>			<!-- 카드 번호 -->
				<th><spring:message code="Cache.ACC_lbl_cardNumber"/><span class="star"></span></th>
				<td>
					<div class="box">
						<div class="searchBox02">
							<span id="cardAppPopupReissue_inputCardNo" class="selectType02" onChange="CardApplicationPopup.onCardChange(this, 'cardAppPopupReissue')">
							</span>
						</div>	
					</div>
				</td>
			</tr>
			<tr>				<!-- 유효기간 -->
				<th><spring:message code="Cache.ACC_lbl_expiryDate"/></th>
				<td>
					<div class="box">
						<input id="cardAppPopupReissue_inputExpirationDate" type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>			<!-- 현재한도금액 -->
				<th><spring:message code="Cache.ACC_lbl_limitAmt"/></th>
				<td>
					<div class="box">
						<input id="cardAppPopupReissue_inputCurrentAmount" type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>
			</tr>
			<tr style="height:150px">	<!-- 신청사유 -->
				<th><spring:message code="Cache.ACC_lbl_applicationReason"/></th>
				<td colspan="3">
					<div class="box" style="width:100%;">
						<textarea id="cardAppPopupReissue_inputApplicationReason" row="10" style="height:135px" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</div>
<script>

//카드신청 재발급
	if (!window.CardAppPopupReissue) {
		window.CardAppPopupReissue = {};
	}

	(function(window) {
		
		var CardAppPopupReissue = {
				reissueComboInitComp : false,
				reissueComboInit : function(inputCardList){
					var me = this;
					var cardList = inputCardList;
					/* if(cardList == null){
						return;
					}
					if(cardList.length==0){
						return;
					} */
					
					accountCtrl.renderAXSelect('CardReissueType',	'cardAppPopupReissue_inputReissuanceType',	'ko','','','', "<spring:message code='Cache.ACC_lbl_choice'/>");
					accountCtrl.createAXSelectData("cardAppPopupReissue_inputCardNo",cardList, "<spring:message code='Cache.ACC_lbl_choice'/>", 'CardNo', 'CardNoView', null, null, null  )
					me.reissueComboInitComp = true;
				},
				
				
				reissueComboRefresh : function(){
					var me = this;
					if(!me.reissueComboInitComp){
						return
					}
					var list = "cardAppPopupReissue_inputReissuanceType,cardAppPopupReissue_inputCardNo"
					accountCtrl.refreshAXSelect(list);
				},

				setCardReissueData : function(data){
					accountCtrl.getComboInfo("cardAppPopupReissue_inputCardNo").bindSelectSetValue(data.CardNo);
					accountCtrl.getComboInfo("cardAppPopupReissue_inputReissuanceType").bindSelectSetValue(data.ReissuanceType);
					
					setFieldDataPopup("cardAppPopupReissue_inputApplicationReason",data.ApplicationReason );
				},
				
				getCardReissueData : function(){
					CardApplicationPopup.params.pageDataObj.ApplicationClass 	= 'CO'
					CardApplicationPopup.params.pageDataObj.CardNo 				= accountCtrl.getComboInfo("cardAppPopupReissue_inputCardNo").val();
					CardApplicationPopup.params.pageDataObj.ReissuanceType 		= accountCtrl.getComboInfo("cardAppPopupReissue_inputReissuanceType").val();
					CardApplicationPopup.params.pageDataObj.ApplicationReason 	= getTxTFieldDataPopup("cardAppPopupReissue_inputApplicationReason");
					return;
				},
				
				checkCardReissue : function(){
					var msg = "<spring:message code='Cache.ACC_msg_case_2' />";	//필수 입력값 입니다.

					if(isEmptyStr(CardApplicationPopup.params.pageDataObj.CardNo)){
						msg = msg.replace("{0}", "<spring:message code='Cache.ACC_lbl_cardNumber' />");		//카드번호
						return msg;
					}

					if(isEmptyStr(CardApplicationPopup.params.pageDataObj.ReissuanceType)){
						msg = msg.replace("{0}", "<spring:message code='Cache.ACC_lbl_cardReissueType' />");	//재발급 구분
						return msg;
					}
					return "";
				}
		}
		window.CardApplicationPopup = $.extend(window.CardApplicationPopup, CardAppPopupReissue);
	})(window);
	
</script>