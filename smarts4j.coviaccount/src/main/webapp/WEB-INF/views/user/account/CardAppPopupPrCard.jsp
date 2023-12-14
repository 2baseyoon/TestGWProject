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
			<tr>		<!-- 카드번호 -->
				<th><spring:message code="Cache.ACC_lbl_cardNumber"/><span class="star"></span></th>
				<td>
					<div class="box">
						<div class="searchBox02">
							<span>
								<input id="cardAppPopupPrCard_inputCardNoView" type="text" class="HtmlCheckXSS ScriptCheckXSS"
								onkeypress="return inputNumChk(event)" onkeydown="pressHan(this)" onkeyup="CardApplicationPopup.prCardCardNoChg(this)">
								<input id="cardAppPopupPrCard_inputCardNo" name="cardAppPopupPrCard_inputCardNo" type="hidden" >
							</span>
						</div>	
					</div>
				</td>	<!-- 카드회사 -->
				<th><spring:message code="Cache.ACC_lbl_cardCompany"/></th>
				<td>
					<div class="box">
						<span id="cardAppPopupPrCard_inputCardCompany" class="selectType02" >
						</span>
					</div>
				</td>
			</tr>
			<tr style="height:150px">	<!-- 신청사유 -->
				<th><spring:message code="Cache.ACC_lbl_applicationReason"/></th>
				<td colspan="3">
					<div class="box" style="width:100%;">
						<textarea id="cardAppPopupPrCard_inputApplicationReason" row="10" style="height:135px" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
	</form>
</div>
<script>

	//카드신청 개인카드
	if (!window.CardAppPopupPrCard) {
		window.CardAppPopupPrCard = {};
	}	

	(function(window) {
		
		var CardAppPopupPrCard = {
				prCardComboInitComp : false,
				prCardComboInit : function(){
					var me = this;
					accountCtrl.renderAXSelect('CardCompany',	'cardAppPopupPrCard_inputCardCompany',	'ko','','','');
					me.prCardComboInitComp = true;
				},
				
				prCardComboRefresh : function(){
					var me = this;
					if(!me.prCardComboInitComp){
						return
					}
					var list = "cardAppPopupPrCard_inputCardCompany"
					accountCtrl.refreshAXSelect(list);
				},
				
				//화면 필드에 값 세팅
				setPrCardData : function(data){
					var me = this;
					accountCtrl.getComboInfo("cardAppPopupPrCard_inputCardCompany").bindSelectSetValue(data.CardCompany);
					setFieldDataPopup("cardAppPopupPrCard_inputApplicationReason",data.ApplicationReason );
					setFieldDataPopup("cardAppPopupPrCard_inputCardNo",data.CardNo );

					var cdNumStr = me.prCardMakeCardNoFormat(data.CardNo); 
					setFieldDataPopup("cardAppPopupPrCard_inputCardNoView", cdNumStr );
				},
				
				//화면 필드값 획득
				getPrCardData : function(){
					CardApplicationPopup.params.pageDataObj.ApplicationClass 	= 'PE'
					CardApplicationPopup.params.pageDataObj.CardNo 				= getTxTFieldDataPopup("cardAppPopupPrCard_inputCardNo");
					CardApplicationPopup.params.pageDataObj.CardCompany 		= accountCtrl.getComboInfo("cardAppPopupPrCard_inputCardCompany").val();
					CardApplicationPopup.params.pageDataObj.ApplicationReason	= getTxTFieldDataPopup("cardAppPopupPrCard_inputApplicationReason");
					return;
				},

				//저장전 체크
				checkPrCard : function(){
					var msg = "<spring:message code='Cache.ACC_msg_case_2' />";

					if(isEmptyStr(CardApplicationPopup.params.pageDataObj.CardNo)){
						msg = msg.replace("{0}", "<spring:message code='Cache.ACC_lbl_cardNumber' />");
						return msg;
					}

					 if((CardApplicationPopup.params.pageDataObj.CardNo).length < 15 || (CardApplicationPopup.params.pageDataObj.CardNo).length > 16){
						 msg = "<spring:message code='Cache.ACC_msg_ckCardNum' />";	//16자리의 카드번호를 입력해주세요.
						 return msg;
					 } 	

					
					return "";
				},
				
				//카드번호 체크
				prCardCardNoChg : function(obj){
					var me = this;
					if(obj.value){
						var val = obj.value.toString().replace(/[^0-9]/g, "").substr(0,16);
						val = isNaN(val) ? "" : val;
						obj.value = getCardNoValue(val, '');
						
						$("[name=cardAppPopupPrCard_inputCardNo]").val(val);
					}
				}
		}
		window.CardApplicationPopup = $.extend(window.CardApplicationPopup, CardAppPopupPrCard);
	})(window);
	

</script>