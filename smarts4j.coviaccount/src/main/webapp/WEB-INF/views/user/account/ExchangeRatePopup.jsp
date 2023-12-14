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
	<input id="mode"			type="hidden" />
	<input id="exchangeRateID"  type="hidden" />
	<div class="layer_divpop ui-draggable popBizRegisterAnn" id="" style="width:350px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="rowTypeWrap formWrap tsize" id="exchangesDiv">
					<dl>
						<dt>
							<spring:message code="Cache.ACC_lbl_date"/>
							<span class="star"></span>
						</dt>
						<dd>
							<div class="box">
								<div id="exchangeRateDateArea" class="dateSel type02" style="width:110px">
								</div>
							</div>
						</dd>
					</dl>
					<dl>
						<div class="border" style="border-bottom:1px dotted grey">
						
						</div>
					</dl>
					<!-- <dl>
						<dt>
							USD
						</dt>
						<dd>
							<div class="box">
								<input id="usd" type="text" placeholder="" style="width: 110px; text-align: right; padding-right: 5px;" 
									onkeyup="ExchangeRatePopup.setAmt(this);"/>							
							</div>
						</dd>
					</dl>
					<dl>
						<dt>
							EUR
						</dt>
						<dd>
							<div class="box">
								<input id="eur" type="text" placeholder="" style="width: 110px; text-align: right; padding-right: 5px;"
									onkeyup="ExchangeRatePopup.setAmt(this);"/>
							</div>
						</dd>
					</dl>
					<dl>
						<dt>
							AED
						</dt>
						<dd>
							<div class="box">
								<input id="aed" type="text" placeholder="" style="width: 110px; text-align: right; padding-right: 5px;"
									onkeyup="ExchangeRatePopup.setAmt(this);"/>
							</div>
						</dd>
					</dl>
					<dl>
						<dt>
							AUD
						</dt>
						<dd>
							<div class="box">
								<input id="aud" type="text" placeholder="" style="width: 110px; text-align: right; padding-right: 5px;"
									onkeyup="ExchangeRatePopup.setAmt(this);"/>
							</div>
						</dd>
					</dl>
					<dl>
						<dt>
							BRL
						</dt>
						<dd>
							<div class="box">
								<input id="brl" type="text" placeholder="" style="width: 110px; text-align: right; padding-right: 5px;"
									onkeyup="ExchangeRatePopup.setAmt(this);"/>
							</div>
						</dd>
					</dl>
					<dl>
						<dt>
							CAD
						</dt>
						<dd>
							<div class="box">
								<input id="cad" type="text" placeholder="" style="width: 110px; text-align: right; padding-right: 5px;"
									onkeyup="ExchangeRatePopup.setAmt(this);"/>
							</div>
						</dd>
					</dl>
					<dl>
						<dt>
							CHF
						</dt>
						<dd>
							<div class="box">
								<input id="chf" type="text" placeholder="" style="width: 110px; text-align: right; padding-right: 5px;"
									onkeyup="ExchangeRatePopup.setAmt(this);"/>
							</div>
						</dd>
					</dl>
					<dl>
						<dt>
							CNY
						</dt>
						<dd>
							<div class="box">
								<input id="cny" type="text" placeholder="" style="width: 110px; text-align: right; padding-right: 5px;"
									onkeyup="ExchangeRatePopup.setAmt(this);"/>
							</div>
						</dd>
					</dl>
					<dl>
						<dt>
							JPY
						</dt>
						<dd>
							<div class="box">
								<input id="jpy" type="text" placeholder="" style="width: 110px; text-align: right; padding-right: 5px;"
									onkeyup="ExchangeRatePopup.setAmt(this);"/>
							</div>
						</dd>
					</dl>
					<dl>
						<dt>
							SGD
						</dt>
						<dd>
							<div class="box">
								<input id="sgd" type="text" placeholder="" style="width: 110px; text-align: right; padding-right: 5px;"
									onkeyup="ExchangeRatePopup.setAmt(this);"/>
							</div>
						</dd>
					</dl> -->
				</div>
				<div class="popBtnWrap bottom">
					<a onclick="ExchangeRatePopup.checkValidation();"	id="btnSave"	class="btnTypeDefault btnThemeLine"><spring:message code="Cache.ACC_btn_save"/></a>
					<a onclick="ExchangeRatePopup.closeLayer();"		id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>
				</div>
			</div>
		</div>
	
	
	</div>
 
</body>

<script>
	if (!window.ExchangeRatePopup) {
		window.ExchangeRatePopup = {};
	}	
	
	(function(window) {
		
		var ExchangeRatePopup = {
				
				popupInit : function(){
					var me = this;
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						$("#"+paramKey).val(paramValue);
					}
					
					me.pageDatepicker();
					me.setPopupEdit();
					me.setExchangesDiv();
					me.getPopupInfo();
				},
				
				pageDatepicker : function(){
					makeDatepicker('exchangeRateDateArea','exchangeRateDate','','','','');
				},
				setPopupEdit : function(){
					var mode = $("#mode").val();
					var exchangeRateID = $("#exchangeRateID").val();
					if (mode == 'modify') {
						const exchangeRateDate = new URL(location.href).searchParams.get("exchangeRateDate");
						$("#exchangeRateDate").val(exchangeRateDate);
						$("#exchangeRateDate").attr("disabled", true);
						$(".icnDate").hide();
					}
				},
				getPopupInfo : function(){
					let mode = document.getElementById("mode").value;
					
					if (mode == "modify") {
						fetch("/account/exchangeRate/exchangesRead.do", {
							method: "POST",
							headers: {
								"Content-Type": "application/json"
							},
							body: JSON.stringify({
								"exchangeRateDate": document.getElementById("exchangeRateDate").value.replace(/-/g, "")
							})})
							.then((response) => response.json())
		 					.then((data) => {
		 						if (data.status == "SUCCESS") {
									let keys = Object.keys(data.dto).filter(key => key != "YYYYMMDD" && key != "KRW");
									
									for (let i = 0; i < keys.length; i++) {
										document.getElementById(keys[i]).value = data.dto[keys[i]];
									}
								} else {
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의바랍니다.
								}
		 					})
		 					.catch ((error) => {
								coviCmn.traceLog(error);
								coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
		 					});
					}
				},
				/* getPopupInfo : function(){
					var mode = $("#mode").val();
					var exchangeRateID = $("#exchangeRateID").val();
	
					if (mode == 'modify') {
						$.ajax({
							url : "/account/exchangeRate/getExchangeRatePopupInfo.do",
							type : "POST",
							data : {
								"exchangeRateID" : exchangeRateID
							},
							success : function(data) {
								if (data.result == "ok") {
									var info = data.list[0];
									$("#exchangeRateID").val(info.ExchangeRateID);
									$("#exchangeRateDate").val(info.ExchangeRateDate);
									$("#usd").val(toAmtFormat(info.USD));
									$("#eur").val(toAmtFormat(info.EUR));
									$("#aed").val(toAmtFormat(info.AED));
									$("#aud").val(toAmtFormat(info.AUD));
									$("#brl").val(toAmtFormat(info.BRL));
									$("#cad").val(toAmtFormat(info.CAD));
									$("#chf").val(toAmtFormat(info.CHF));
									$("#cny").val(toAmtFormat(info.CNY));
									$("#jpy").val(toAmtFormat(info.JPY));
									$("#sgd").val(toAmtFormat(info.SGD));
								}
							},
							error : function(error) {
								Common.Error("<spring:message code='Cache.ACC_msg_error' />");
							}
						});
					}
				}, */
				setExchangesDiv: function() {
					let exchangesDiv = document.getElementById("exchangesDiv");
					let exchangesList = new Array();
					$.ajax({
						type: "POST",
						url: "/account/baseCode/getCodeListByCodeGroup.do",
						async: false,
						data: {
							codeGroup : 'ExchangeNation',
							companyCode : sessionObj["DN_Code"] == "ORGROOT" ? "ALL" : sessionObj["DN_Code"]
						},
						success: function (data) {
							if(data.status == "SUCCESS"){
								if(data.list.length > 0) {
									$(data.list).each(function(i, obj){
										if(obj.IsUse == "Y" && obj.IsGroup == "N" && obj.Code != "KRW") {
											exchangesList.push(obj);
										}
									});
								}
							}
						},
						error: function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}
					});
					
					for (let i = 0; i < exchangesList.length; i++) {
						let code = exchangesList[i].Code;
						let newTag = document.createElement("dl");
						
						newTag.innerHTML = `<dt>
												${'${code}'}
											</dt>
											<dd>
												<div class="box">
													<input id="${'${code}'}" class="exchangesPrice" type="text" placeholder="" style="width: 110px; text-align: right; padding-right: 5px;" onkeyup="ExchangeRatePopup.setAmt(this);"/>
												</div>
											</dd>`;
											
						exchangesDiv.appendChild(newTag);
					}
				},
				checkValidation : function(){

					var exchangeRateID		= $("#exchangeRateID").val();
					var stDt = $("#exchangeRateDate").val();
					var exchangeRateDate = stDt.replaceAll(".", "");
					
					var today = new Date();
					/* var usd = $("#usd").val().replace(/\,/gi, "");
					var eur = $("#eur").val().replace(/\,/gi, "");
					var aed = $("#aed").val().replace(/\,/gi, "");
					var aud = $("#aud").val().replace(/\,/gi, "");
					var brl = $("#brl").val().replace(/\,/gi, "");
					var cad = $("#cad").val().replace(/\,/gi, "");
					var chf = $("#chf").val().replace(/\,/gi, "");
					var cny = $("#cny").val().replace(/\,/gi, "");
					var jpy = $("#jpy").val().replace(/\,/gi, "");
					var sgd = $("#sgd").val().replace(/\,/gi, ""); */
					
					if (exchangeRateDate == null || isEmptyStr(exchangeRateDate)) {
						Common.Inform("<spring:message code='Cache.ACC_msg_selectDate' />");	//날짜를 선택해 주세요.
						return;
					}
					
					if (exchangeRateDate > today.toISOString().slice(0, 10).replace(/-/g,"")) {
						Common.Inform("<spring:message code='Cache.ACC_msg_dateError' />"	//입력 가능 날짜를 초과하였습니다.
								+ today.toISOString().slice(0, 10).replace(/-/g, "") + ')');
						return;
					}
					
					/* if (	isNaN(usd) || isNaN(eur) || isNaN(aed) || isNaN(aud) || isNaN(brl)||
							isNaN(cad) || isNaN(chf) || isNaN(cny) || isNaN(jpy) || isNaN(sgd)){
						Common.Inform("<spring:message code='Cache.ACC_msg_isNaN' />");		//숫자만 입력해주세요
						return;
					} */
					
					let exchangesPrice = document.getElementsByClassName("exchangesPrice");
					let exchanges = new Object();
					for (let i = 0; i < exchangesPrice.length; i++) {
						let price = exchangesPrice[i].value.replace(/\,/gi, "");
						
						if(isNaN(price)) {
							Common.Inform("<spring:message code='Cache.ACC_msg_isNaN' />"); //숫자만 입력해주세요
							return;
						}
						exchanges[exchangesPrice[i].id] = price;
					}
					
					
					var mode = $("#mode").val();
					if (mode == 'modify') {
						this.exchangesModify(exchangeRateDate, exchanges);
					} else {
						this.exchangesRegister(exchangeRateDate, exchanges);
					}
				},
				closeLayer : function(){
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				},
				setAmt : function(obj) {
					var val = obj.value.replaceAll(",", "");
					var newVal = "";
					for(var i = 0; i < val.length; i++){
						if(!isNaN(val.charAt(i) + "0")){
							newVal += val.charAt(i);
						}
					}
					obj.value = toAmtFormat(newVal);
				},
				exchangesRegister: function(exchangeRateDate, exchanges) {
					fetch("/account/exchangeRate/exchangesRegister.do", {
						method: "POST",
						headers: {
							"Content-Type": "application/json"
						},
						body: JSON.stringify({
							"exchangeRateDate": exchangeRateDate.replace(/-/g, ""),
							"exchanges": exchanges
						})})
						.then((response) => response.json())
	 					.then((data) => {
	 						if (data.status == "SUCCESS") {
								if (data.result == 'code') {
									Common.Inform("<spring:message code='Cache.ACC_msg_existDate' />");	//이미 존재하는 날짜입니다.
								} else {
									parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
									ExchangeRatePopup.closeLayer();
	
									try{
										accountCtrl.popupCallBackStr([]);
									}catch (e) {
										coviCmn.traceLog(e);
										coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
									}
								}
							} else {
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의바랍니다.
							}
	 					})
						.catch (() => {
							coviCmn.traceLog(e);
							coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
	 					});
				},
				exchangesModify: function(exchangeRateDate, exchanges) {
					fetch("/account/exchangeRate/exchangesModify.do", {
						method: "PUT",
						headers: {
							"Content-Type": "application/json"
						},
						body: JSON.stringify({
							"exchangeRateDate": exchangeRateDate.replace(/-/g, ""),
							"exchanges": exchanges
						})})
						.then((response) => response.json())
	 					.then((data) => {
	 						if (data.status == "SUCCESS") {
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
								ExchangeRatePopup.closeLayer();

								try{
									accountCtrl.popupCallBackStr([]);
								}catch (error) {
									coviCmn.traceLog(error);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
							} else {
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의바랍니다.
							}
	 					})
						.catch ((error) => {
							coviCmn.traceLog(error);
							coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
	 					});
				}
		}
		window.ExchangeRatePopup = ExchangeRatePopup;
	})(window);
	
ExchangeRatePopup.popupInit();

</script>
