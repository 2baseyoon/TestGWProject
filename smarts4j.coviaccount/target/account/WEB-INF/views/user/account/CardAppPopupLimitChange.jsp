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
						<input id="cardAppPopupLimitChange_inputExpirationDate" type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>
			</tr>
			<tr>				<!-- 현재한도금액 -->
				<th><spring:message code="Cache.ACC_lbl_limitAmt"/></th>
				<td>
					<div class="box">
						<input id="cardAppPopupLimitChange_inputCurrentAmount" type="text" disabled="true" style="text-align: right;" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>			<!-- 요청구분 -->
				<th><spring:message code="Cache.ACC_lbl_requestType"/></th>
				<td>
					<div class="box" >
						<input id="cardAppPopupLimitChange_inputLimitTypeView" type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
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
						onchange="CardApplicationPopup.onAppAmtChange(this)" >
						</span>
						<input id="cardAppPopupLimitChange_inputApplicationAmount" type="text" style="text-align: right;" 
						onkeyup = "removeChar(this); CardApplicationPopup.onAppAmtFieldChange(this);"
						 kind="money" money_max="99999999999" money_min="0" value="0" class="HtmlCheckXSS ScriptCheckXSS" />
						<label><spring:message code='Cache.ACC_msg_limitAmount'/></label> <!-- * 한도금액을 작성하지 않을 경우 한도없는 카드로 분류됩니다. -->
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
			<tr style="height:150px">		<!-- 신청사유 -->
				<th><spring:message code="Cache.ACC_lbl_applicationReason"/></th>
				<td colspan="3">
					<div class="box" style="width:100%;">
						<textarea id="cardAppPopupLimitChange_inputApplicationReason" row="10" style="height:135px" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
	</form>
</div>
<script>


//카드 신청 한도변경
	if (!window.CardApplicationPopup) {
		window.CardApplicationPopup = {};
	}	
	
	(function(window) {
		
		var CardAppPopupLimitChange = {
				limitChangeComboInitComp : false,
				limitChangeComboInit : function(inputCardList){
					var me = this;
					var cardList = inputCardList;
					/* if(cardList == null){
						return;
					}
					
					if(cardList.length==0){
						return;
					} */
						
					accountCtrl.renderAXSelect('CardLimitAmount',	'cardAppPopupLimitChange_inputApplicationAmountCombo',	'ko','','','', "<spring:message code='Cache.ACC_lbl_directInput' />");	//직접입력
					accountCtrl.renderAXSelect('CardLimitType',		'cardAppPopupLimitChange_inputLimitType',				'ko','','','', ' ');
					accountCtrl.createAXSelectData("cardAppPopupLimitChange_inputCardNo",cardList, "<spring:message code='Cache.ACC_lbl_choice'/>", 'CardNo', 'CardNoView', null, null, null  )
					me.limitChangeComboInitComp = true;
					
					makeDatepicker("cardAppPopupLimitChange_inputChangeExpirationDate", "cardAppPopupLimitChange_inputChangeExpirationDate_Date")
					
				},

				limitChangeComboRefresh : function(){
					var me = this;
					if(!me.limitChangeComboInitComp){
						return
					}
					accountCtrl.refreshAXSelect('cardAppPopupLimitChange_inputApplicationAmountCombo');
					accountCtrl.refreshAXSelect('cardAppPopupLimitChange_inputLimitType');
					accountCtrl.refreshAXSelect('cardAppPopupLimitChange_inputCardNo');
				},
				
				//amt 변경시 숫자 체크
				onAppAmtChange : function(obj){
					if(obj != null){
						if(obj.value != null){
							var val = obj.value;
							if(val==""){
								$("#cardAppPopupLimitChange_inputApplicationAmount").attr('disabled',false);
								accountCtrl.getComboInfo("cardAppPopupLimitChange_inputLimitType").bindSelectSetValue("");
								setFieldDataPopup("cardAppPopupLimitChange_inputLimitTypeView", $("#cardAppPopupLimitChange_inputLimitType option:selected").text())
								
							}else{
								$("#cardAppPopupLimitChange_inputApplicationAmount").attr('disabled',true);
								var amtVal = val.substr(3,val.length);
								
								var setAmtVal = toAmtFormat(amtVal);
								setFieldDataPopup("cardAppPopupLimitChange_inputApplicationAmount",setAmtVal );

								var curAmt = getTxTFieldDataPopup("cardAppPopupLimitChange_inputCurrentAmount");
								curAmt = AmttoNumFormat(curAmt);

							}
							CardApplicationPopup.setLmtTyp();
						}
					}
				},
				
				//한도 증감 체크
				setLmtTyp : function(){
					var amtVal = getTxTFieldDataPopup("cardAppPopupLimitChange_inputApplicationAmount");
						amtVal = AmttoNumFormat(amtVal);

					var curAmt = getTxTFieldDataPopup("cardAppPopupLimitChange_inputCurrentAmount");
						curAmt = AmttoNumFormat(curAmt);
						$("#chgExpDateArea").css("display", "none");
					
					if(accountCtrl.getComboInfo("cardAppPopupLimitChange_inputCardNo").val() == ""){
						accountCtrl.getComboInfo("cardAppPopupLimitChange_inputLimitType").bindSelectSetValue("");
						setFieldDataPopup("cardAppPopupLimitChange_inputLimitTypeView", "");
						setFieldDataPopup("cardAppPopupLimitChange_inputChangeExpirationDate_Date","" );
						return;
					}
					
					// 0이면 한도없는카드 이므로 증액, 감액 조건 변경
					var chkAmtEmpty = amtVal!=0 && curAmt!=0
					if((chkAmtEmpty && ckNaN(amtVal) > ckNaN(curAmt)) || (amtVal==0 && curAmt!=0)){
						accountCtrl.getComboInfo("cardAppPopupLimitChange_inputLimitType").bindSelectSetValue("Up");
						setFieldDataPopup("cardAppPopupLimitChange_inputLimitTypeView", $("#cardAppPopupLimitChange_inputLimitType option:selected").text())
						$("#chgExpDateArea").css("display", "");
					}else if((chkAmtEmpty && ckNaN(amtVal) < ckNaN(curAmt)) || (curAmt==0 && amtVal!=0)){
						accountCtrl.getComboInfo("cardAppPopupLimitChange_inputLimitType").bindSelectSetValue("Dwn");
						setFieldDataPopup("cardAppPopupLimitChange_inputLimitTypeView", $("#cardAppPopupLimitChange_inputLimitType option:selected").text());
						setFieldDataPopup("cardAppPopupLimitChange_inputChangeExpirationDate_Date","" );
					}else{
						accountCtrl.getComboInfo("cardAppPopupLimitChange_inputLimitType").bindSelectSetValue("");
						setFieldDataPopup("cardAppPopupLimitChange_inputLimitTypeView", "");
						setFieldDataPopup("cardAppPopupLimitChange_inputChangeExpirationDate_Date","" );
					}
				},
				
				//숫자필드 값변경
				onAppAmtFieldChange : function(obj){
					var objVal = obj.value;
					var objVal = objVal.replace(/[^0-9,]/g, "");
					obj.value = objVal;
					
					CardApplicationPopup.setLmtTyp();
				},
				
				//화면에 값 세팅
				setCardLimitChangeData : function(data){
					var me = this;
					accountCtrl.getComboInfo("cardAppPopupLimitChange_inputCardNo").bindSelectSetValue(data.CardNo);
					accountCtrl.getComboInfo("cardAppPopupLimitChange_inputLimitType").bindSelectSetValue(data.LimitType);
					setFieldDataPopup("cardAppPopupLimitChange_inputLimitTypeView", $("#cardAppPopupLimitChange_inputLimitType option:selected").text());

					accountCtrl.getComboInfo("cardAppPopupLimitChange_inputApplicationAmountCombo").bindSelectSetValue(data.LimitAmountType);
					
					setFieldDataPopup("cardAppPopupLimitChange_inputApplicationAmount", toAmtFormat(data.ApplicationAmount) );
					setFieldDataPopup("cardAppPopupLimitChange_inputApplicationReason",data.ApplicationReason );
					setFieldDataPopup("cardAppPopupLimitChange_inputChangeExpirationDate_Date",data.ChangeExpirationDate);
					if(data.LimitType == "Up"){
						$("#chgExpDateArea").css("display", "");
					}else{
						$("#chgExpDateArea").css("display", "none");
					}
					me.setLmtTyp();
				},

				//화면값 획득
				getCardLimitChangeData : function(){
					CardApplicationPopup.params.pageDataObj.ApplicationClass 	= 'CO'
					CardApplicationPopup.params.pageDataObj.CardNo 			= accountCtrl.getComboInfo("cardAppPopupLimitChange_inputCardNo").val();
					CardApplicationPopup.params.pageDataObj.ExpirationDate 	= getTxTFieldDataPopup("cardAppPopupLimitChange_inputExpirationDate");
					
					CardApplicationPopup.params.pageDataObj.LimitAmountType = accountCtrl.getComboInfo("cardAppPopupLimitChange_inputApplicationAmountCombo").val();
					
					var getDate = getTxTFieldDataPopup("cardAppPopupLimitChange_inputChangeExpirationDate_Date");
					CardApplicationPopup.params.pageDataObj.ChangeExpirationDateStr 	= getDate;
					CardApplicationPopup.params.pageDataObj.ChangeExpirationDate 	= getDate.replaceAll(".", "");

					var curAmt = getTxTFieldDataPopup("cardAppPopupLimitChange_inputCurrentAmount");
						curAmt = AmttoNumFormat(curAmt);
						
						CardApplicationPopup.params.pageDataObj.CurretnAmt 	= curAmt;
						CardApplicationPopup.params.pageDataObj.LimitType 	= accountCtrl.getComboInfo("cardAppPopupLimitChange_inputLimitType").val();
					
					var lmtAmt = getTxTFieldDataPopup("cardAppPopupLimitChange_inputApplicationAmount");
						lmtAmt = AmttoNumFormat(lmtAmt);
						
						CardApplicationPopup.params.pageDataObj.ApplicationAmount	= lmtAmt;
						CardApplicationPopup.params.pageDataObj.ApplicationReason	= getTxTFieldDataPopup("cardAppPopupLimitChange_inputApplicationReason");
					return;
				},

				//저장전 필수체크
				checkCardLimitChange : function(){
					var msg = "<spring:message code='Cache.ACC_msg_case_2' />";	//필수 입력값 입니다.

					if(isEmptyStr(CardApplicationPopup.params.pageDataObj.CardNo)){
						//msg = "<spring:message code='Cache.lbl_cardNo'/>" + msg;
						msg = msg.replace("{0}", "<spring:message code='Cache.ACC_lbl_cardNumber' />");		//카드번호
						return msg;
					}

					/* if(isEmptyStr(CardApplicationPopup.params.pageDataObj.ApplicationAmount)){
						msg = msg.replace("{0}", "<spring:message code='Cache.ACC_lbl_changeLimitAmount' />");	//변경한도금액
						return msg;
					} */
					
					if(isEmptyStr(CardApplicationPopup.params.pageDataObj.LimitType)
						||	CardApplicationPopup.params.pageDataObj.ApplicationAmount == CardApplicationPopup.params.pageDataObj.CurretnAmt
						){
						msg = "<spring:message code='Cache.ACC_037' />";		//동일한 금액으로 변경을 신청할 수 없습니다.
						return msg;
					}
					
					return "";
				}
		}
		window.CardApplicationPopup = $.extend(window.CardApplicationPopup, CardAppPopupLimitChange);
	})(window);
	
</script>