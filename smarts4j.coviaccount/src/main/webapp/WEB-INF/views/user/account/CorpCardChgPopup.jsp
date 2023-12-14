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
	<input id="corpCardID"	type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style = "width: 120px;">
							<col style = "width: auto;">
						</colgroup>
						<tbody id="corpCardInfo">
							<tr>
								<th>	<!-- 카드번호 -->
									<spring:message code='Cache.ACC_lbl_cardNumber'/>
								</th>
								<td>
									<div class="box">
										<input id="cardNo" type="text" MaxLength="16" disabled='true' class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 카드번호변경 -->
									<spring:message code='Cache.ACC_lbl_changeCard'/>
								</th>
								<td>
									<div class="box">
										<input	id="cardNoChg" type="text"
												onkeypress	= "return inputNumChk(event)"
												onkeydown	= "pressHan(this)"
												onkeyup	= "CorpCardChgPopup.changeCardNo()"
												class		= "HtmlCheckXSS ScriptCheckXSS">					<!-- 중복체크 -->
										<a id="cardNoChgBtn" class="btnTypeDefault" onclick="CorpCardChgPopup.cardNoChg()"><spring:message code='Cache.ACC_lbl_ckExist'/></a>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="bottom">
					<a onclick="CorpCardChgPopup.checkValidation();"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save' /></a>
					<a onclick="CorpCardChgPopup.closeLayer();"			id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

	if (!window.CorpCardChgPopup) {
		window.CorpCardChgPopup = {};
	}

	(function(window) {
		var CorpCardChgPopup = {
				
				params : {
					_cardNoChgChk	: "fail",
					_cardNoChg		: 0
				},
				
				popupInit : function(){
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						$("#"+paramKey).val(paramValue);
					}
				},
				
				cardNoChg : function(){
					var cardNoChgVal = $('#cardNoChg').val().replaceAll('-','');
					var regExp = /^[0-9]+$/;
					
					if(cardNoChgVal.length < 15 || cardNoChgVal.length > 16){
						Common.Inform("<spring:message code='Cache.ACC_msg_ckCardNum' />");	//16자리의 카드번호를 입력해주세요.
						return;	
					}
					
					if (regExp.test(cardNoChgVal)){
						$.ajax({
							url	:"/account/corpCard/getCardNoChk.do",
							type: "POST",
							data: {
									"cardNo" : cardNoChgVal
							},
							success:function (data) {
								if(data.status == "SUCCESS"){
									
									CorpCardChgPopup.params._cardNoChgChk	= data.result;
									CorpCardChgPopup.params._cardNoChg		= cardNoChgVal;
									
									if(data.result == "ok"){
										Common.Inform("<spring:message code='Cache.ACC_msg_cardNumY' />"); //등록 가능한 카드번호입니다.
									}else{
										Common.Inform("<spring:message code='Cache.ACC_msg_cardNumN' />"); //이미 등록된 카드번호입니다.
									}
								}else{
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
								}
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						});
					}else{
						Common.Inform("<spring:message code='Cache.ACC_msg_reCardNum' />");	//카드번호를 다시 입력하세요.
					}
				},
				
				checkValidation : function(){
				    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				    
					var me = this;
					var params			= new Object();
					
					var cardNoRegExp	= /^[0-9]+$/;
					var corpCardID		= $("#corpCardID").val();	//카드관리 ID
					var cardNoChgVal	= $('#cardNoChg').val().replaceAll('-','');
					
					if(cardNoChgVal == null || cardNoChgVal==''){
						Common.Inform("<spring:message code='Cache.ACC_msg_noDataCardNum' />");	//카드번호를 입력하세요.
						return;
					}
					
					if (cardNoRegExp.test(cardNoChgVal)){
						if(me.params._cardNoChgChk == "fail"){
							Common.Inform("<spring:message code='Cache.ACC_msg_ckExistCardNum' />")	//카드번호 중복 여부를 확인하세요.
							return;
						}else{
							if(cardNoChgVal != me.params._cardNoChg){
								Common.Inform("<spring:message code='Cache.ACC_msg_ckExistCardNum' />")	//카드번호 중복 여부를 확인하세요.
								return;
							}
						}
					}else{
						Common.Inform("<spring:message code='Cache.ACC_msg_reCardNum' />");	//카드번호를 다시 입력하세요.
						return;
					}
					
					params.corpCardID	= corpCardID;
					params.cardNoChgVal	= cardNoChgVal;
					
					$.ajax({
						url			: "/account/corpCard/updateCorpCardNo.do",
						type		: "POST",
						data		: JSON.stringify(params),
						dataType	: "json",
						contentType	: "application/json",
						success:function (data) {
							if(data.status == "SUCCESS"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다.
								
								CorpCardChgPopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([params]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
								
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				changeCardNo : function(){
					var cardNoChg = $('#cardNoChg').val();
						cardNoChg = getCardNoValue(cardNoChg,'');
					$('#cardNoChg').val(cardNoChg);
				},
				
				closeLayer : function() {
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				}
		}
		window.CorpCardChgPopup = CorpCardChgPopup;
	})(window);
	
	CorpCardChgPopup.popupInit();
	
</script>