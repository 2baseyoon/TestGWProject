<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>
	<input id="cardApplicationID"	type="hidden"/>
	<div class="layer_divpop ui-draggable docPopLayer" style="width:520px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style = "width: 150px;">
							<col style = "width: auto;">
						</colgroup>
						<tbody id="corpCardInfo">
							<tr>
								<th>	<!-- 카드번호 -->
									<spring:message code='Cache.ACC_lbl_cardNumber'/>
								</th>
								<td>
									<div class="box">
										<input id="cardNo"	type="text" disabled="true">
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 카드회사 -->
									<spring:message code='Cache.ACC_lbl_cardCompany'/>
								</th>
								<td>
									<div class="box">
										<input id="cardCompanyName"	type="text" disabled="true">
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 소유자 -->
									<spring:message code='Cache.ACC_lbl_cardOwner'/>
								</th>
								<td>
									<div class="box">
										<input id="registerName"	type="text" disabled="true">
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 사용여부 -->
									<spring:message code='Cache.ACC_lbl_isUse'/>
								</th>
								<td>
									<div class="box">
										<span id="isUse" class="selectType02">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 신청이유 -->
									<spring:message code='Cache.ACC_lbl_applicationReason'/>
								</th>
								<td>
									<div class="box">
										<textarea disabled="true" maxlength="255" rows="5" style="width: 90%" id="applicationReason" name="<spring:message code="Cache.lbl_Description"/>" class="AXTextarea av-required"></textarea>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="bottom">
					<a onclick="CardApplicationUserPopup.checkValidation();"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_modify'/></a>
					<a onclick="CardApplicationUserPopup.closeLayer();"			id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_close'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

if (!window.CardApplicationUserPopup) {
	window.CardApplicationUserPopup = {};
}	

(function(window) {
	
	var CardApplicationUserPopup = {
			
			popupInit : function(){
				var me = this;
				var param = location.search.substring(1).split('&');
				for(var i = 0; i < param.length; i++){
					var paramKey	= param[i].split('=')[0];
					var paramValue	= param[i].split('=')[1];
					$("#"+paramKey).val(paramValue);
				}
				
				me.setSelectCombo();
				me.getPopupInfo();
			},
			
			setSelectCombo : function(){
				accountCtrl.renderAXSelect('IsUse','isUse','ko','','','');
			},
			
			getPopupInfo : function(){
				var pCardApplicationID	= $("#cardApplicationID").val();
				$.ajax({
					url	:"/account/cardApplication/getCardApplicationDetail.do",
					type: "POST",
					data: {
							"cardApplicationID" : pCardApplicationID
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							var info = data.list[0];
							$("#cardApplicationID").val(info.CardApplicationID);
							$("#cardNo").val(info.CardNo);
							$("#cardCompanyName").val(info.CardCompanyName);
							$("#registerName").val(info.RegisterName);
							$("#isUse").bindSelectSetValue(info.IsUse)
							$("#applicationReason").val(info.ApplicationReason);;
						}else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			checkValidation : function(){
				var params	= new Object();
				var pCardApplicationID	= $("#cardApplicationID").val();
				var pIsUse				= $("#isUse").val();
				
				params.cardApplicationID	= pCardApplicationID;
				params.isUse				= pIsUse;
				
				$.ajax({
					url	:"/account/cardApplication/saveCardApplicationInfo.do",
					type		: "POST",
					data		: JSON.stringify(params),
					dataType	: "json",
					contentType	: "application/json",
					
					success:function (data) {
						if(data.status == "SUCCESS"){
							parent.Common.Inform("<spring:message code='Cache.msg_37'/>");	//저장되었습니다
							
							CardApplicationUserPopup.closeLayer();
							
							try{
								accountCtrl.popupCallBackStr([]);
							}catch (e) {
								coviCmn.traceLog(e);
								coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
							}
						}else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // data.message
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // error.message
					}
				});
			},
			
			closeLayer : function(){
				var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
				var popupID		= CFN_GetQueryString("popupID");
				
				if(isWindowed.toLowerCase() == "true") {
					window.close();
				} else {
					parent.Common.close(popupID);
				}
			}
	}
	window.CardApplicationUserPopup = CardApplicationUserPopup;
})(window);

CardApplicationUserPopup.popupInit();
	
</script>