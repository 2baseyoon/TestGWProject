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
			<tr>		<!-- 시작일 -->
				<th><spring:message code="Cache.ACC_lbl_startDate"/><span class="star"></span></th>
				<td>
					<div class="box">
						<div id="cardAppPopupPublicCard_inputStartDate_AREA" class="dateSel type02" 
							name="dateField" datefield="startDate" targetfield="endDate"
							onchange="CardApplicationPopup.cardAppPopupPublicCard_dateChange(this)">
						</div>
					</div>
				</td>	<!-- 종료일 -->
				<th><spring:message code="Cache.ACC_lbl_endDate"/><span class="star"></span></th>
				<td>
					<div class="box">
						<div id="cardAppPopupPublicCard_inputEndDate_AREA" class="dateSel type02"
							name="dateField" datefield="endDate" targetfield="startDate"
							onchange="CardApplicationPopup.cardAppPopupPublicCard_dateChange(this)">
					</div>
				</td>
			</tr>
			<tr>		<!-- 신청금액 -->
				<th><spring:message code="Cache.ACC_lbl_applicationAmt"/><span class="star"></span></th>
				<td>
					<div class="box">
						<input id="cardAppPopupPublicCard_inputApplicationAmount" type="text" kind="money" money_max="99999999999" money_min="0"  
							onchange="CardApplicationPopup.onPublicAmtFieldChange(this)" onkeyup = "removeChar(this)"
							style="text-align: right;"  class="HtmlCheckXSS ScriptCheckXSS" />
					</div>
				</td>
			</tr>
			<tr style="height:150px">	<!-- 신청사유 -->
				<th><spring:message code="Cache.ACC_lbl_applicationReason"/></th>
				<td colspan="3">
					<div class="box" style="width:100%;">
						<textarea id="cardAppPopupPublicCard_inputApplicationReason" row="10" style="height:135px" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</div>
<script>

	//카드신청 공용카드
	if (!window.CardAppPopupPublicCard) {
		window.CardAppPopupPublicCard = {};
	}	

	(function(window) {
		
		var CardAppPopupPublicCard = {
				
				pageDatepicker : function(){
					makeDatepicker('cardAppPopupPublicCard_inputStartDate_AREA','cardAppPopupPublicCard_inputStartDate','','','','');
					makeDatepicker('cardAppPopupPublicCard_inputEndDate_AREA','cardAppPopupPublicCard_inputEndDate','','','','');
				},
				
				//화면 필드값 세팅
				setPublicCardData : function(data){
					setFieldDataPopup("cardAppPopupPublicCard_inputStartDate",data.ApplicationStartDate );
					setFieldDataPopup("cardAppPopupPublicCard_inputEndDate",data.ApplicationFinishDate );

					var setAmtVal = toAmtFormat(data.ApplicationAmount);
					setFieldDataPopup("cardAppPopupPublicCard_inputApplicationAmount",setAmtVal );
					setFieldDataPopup("cardAppPopupPublicCard_inputApplicationReason",data.ApplicationReason );
				},
				
				//필드값 획득
				getPublicCardData : function(){
					CardApplicationPopup.params.pageDataObj.ApplicationClass 		= 'CO';
					var stDate = getTxTFieldDataPopup("cardAppPopupPublicCard_inputStartDate");
					var edDate = getTxTFieldDataPopup("cardAppPopupPublicCard_inputEndDate");

					CardApplicationPopup.params.pageDataObj.ApplicationStartDateStr 	= stDate
					CardApplicationPopup.params.pageDataObj.ApplicationStartDate 	= stDate.replaceAll(".", "");
					CardApplicationPopup.params.pageDataObj.ApplicationFinishDateStr 	= edDate
					CardApplicationPopup.params.pageDataObj.ApplicationFinishDate 	= edDate.replaceAll(".", "");
					
					var appamt = getTxTFieldDataPopup("cardAppPopupPublicCard_inputApplicationAmount");
					appamt = AmttoNumFormat(appamt);//
					CardApplicationPopup.params.pageDataObj.ApplicationAmount 		= appamt;
					CardApplicationPopup.params.pageDataObj.ApplicationReason 		= getTxTFieldDataPopup("cardAppPopupPublicCard_inputApplicationReason");
					return;
				},

				//필스체크
				checkPublicCard : function(){
					var msg = "<spring:message code='Cache.ACC_msg_case_2' />";	//필수 입력값 입니다.

					if(isEmptyStr(CardApplicationPopup.params.pageDataObj.ApplicationStartDate)){
						msg = msg.replace("{0}", "<spring:message code='Cache.ACC_lbl_startDate' />");		//시작일
						return msg;
					}
					if(isEmptyStr(CardApplicationPopup.params.pageDataObj.ApplicationFinishDate)){
						msg = msg.replace("{0}", "<spring:message code='Cache.ACC_lbl_endDate' />");			//종료일
						return msg;
					}
					if(isEmptyStr(CardApplicationPopup.params.pageDataObj.ApplicationAmount)){
						msg = msg.replace("{0}", "<spring:message code='Cache.ACC_lbl_applicationAmt' />");	//변경금액
						return msg;
					}

					if(CardApplicationPopup.params.pageDataObj.ApplicationStartDate > CardApplicationPopup.params.pageDataObj.ApplicationFinishDate){
						msg = "<spring:message code='Cache.ACC_031' />";		// 시작일자가 종료일자보다 큽니다.
						return msg;
					}
					
					return "";
				},
				cardAppPopupPublicCard_dateChange : function(obj){
					var me = this;
				},

				//숫자필드 값변경
				onPublicAmtFieldChange : function(obj){
					var objVal = obj.value;
					var objVal = objVal.replace(/[^0-9,]/g, "");
					obj.value = objVal;
					
					CardApplicationPopup.setLmtTyp();
				},
		}
		window.CardApplicationPopup = $.extend(window.CardApplicationPopup, CardAppPopupPublicCard);
	})(window);
	
</script>