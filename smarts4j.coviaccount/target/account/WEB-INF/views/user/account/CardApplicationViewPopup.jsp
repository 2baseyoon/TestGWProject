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
	<div class="layer_divpop ui-draggable docPopLayer" id="vendorPopup" style="width:800px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<table class="tableTypeRow">
					<colgroup>
						<col style="width: 17%;" />
						<col style="width: auto;" />
						<col style="width: 17%;" />
						<col style="width: auto;" />
					</colgroup>
					<tbody>
						<tr>			<!-- 제목 -->
							<th><spring:message code="Cache.ACC_lbl_title"/></th>
							<td colspan="3">
								<div class="box">
									<label name="labelCardAppViewMain" datafield="ApplicationTitle"></label>
								</div>
							</td>
						</tr>
						<tr>			<!-- 신청유형 -->
							<th><spring:message code="Cache.ACC_lbl_vendorRequestType"/></th>
							<td >
								<div class="box">
									<label name="labelCardAppViewMain" datafield="ApplicationTypeName"></label>
								</div>
							</td>		<!-- 등록자 -->
							<th><spring:message code="Cache.ACC_lbl_registerName"/></th>
							<td >
								<div class="box">
									<label name="labelCardAppViewMain" datafield="RegisterName"></label>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
				<div style="height:10px">
				</div>
				<div class="middle">
						<jsp:include page="CardApplicationViewPopupTables.jsp" ></jsp:include>
				</div>
				
				<input type="hidden" id="cardApplicationViewPopup_inputCardApplicationID" >
				<input type="hidden" id="cardApplicationViewPopup_inputIsNew" >
				<div class="popBtnWrap bottom">

					<%
						String isAM = (String)request.getAttribute("isAM");
						if("Y".equals(isAM)){
					%>
					<a onclick="CardApplicationViewPopup.onAprvChange('E');" name='aprvBtn' style="display:none" class='btnTypeDefault btnTypeChk'>
						<spring:message code='Cache.ACC_btn_accept' />
					</a>
					
					<a onclick="CardApplicationViewPopup.onAprvChange('R');" name='aprvBtn' style="display:none" class='btnTypeDefault btnTypeChk'>
						<spring:message code='Cache.ACC_btn_reject' />
					</a>
					<% 
						}
					%>
					<a onclick='CardApplicationViewPopup.onAprvCancel();' name='aprvBtn' style="display:none"  class='btnTypeDefault btnTypeChk'>
						<spring:message code='Cache.ACC_btn_applicationCancel' />
					</a>

					<a onclick="CardApplicationViewPopup.closeLayer();"				id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel' /></a>
				</div>
			</div>
		</div>		
	</div>
</body>
<script>
	//카드 신청 조회전용
	if (!window.CardApplicationViewPopup) {
		window.CardApplicationViewPopup = {};
	}
	
	(function(window) {
		var CardApplicationViewPopup = {
				
				params : {
					pageDataObj				: {},
					pageCardApplicationID	: "${CardApplicationID}",
					cardList				: [],
					cardMap					: {}
				},
				
				popupInit : function(){
					var me = this;
					setFieldDataPopup("cardApplicationViewPopup_inputIsNew", "${isNew}");

					me.setInit();
				},

				setInit : function(){
					var me = this;
					var getCardApplicationID = "${CardApplicationID}";
					me.searchDetailData(getCardApplicationID);
					
					$("#limitChangeArea").css("display",	"none");
					$("#cardReissueArea").css("display",	"none");
					$("#cardCloseArea").css("display",		"none");
					$("#publidCardArea").css("display",		"none");
					$("#prCardArea").css("display",			"none");
					$("#newCardArea").css("display",		"none");
				},
				
				//상세정보 조회
				searchDetailData : function(getCardApplicationID){
					var me = this;
					var searchCardApplicationID = getCardApplicationID;
					setFieldDataPopup("cardApplicationViewPopup_inputCardApplicationID", me.params.pageCardApplicationID);

					$.ajaxSetup({
						cache : false
					});
					
					$.getJSON('/account/baseInfo/searchCardApplicationDetail.do', {CardApplicationID : getCardApplicationID}
						, function(r) {
							if(r.result == "ok"){
								var data = r.data

								me.params.pageDataObj = data;
								me.setLabelField(data, "labelCardAppViewMain");

								var ApplicationType = data.ApplicationType
								if(ApplicationType == "CoCardLimitChange"){
									me.setLabelField(data, "labelLimitChange");
								}else if(ApplicationType == "CoCardReissue"){
									me.setLabelField(data, "labelCardReissue");
								}else if(ApplicationType == "CoCardClose"){
									me.setLabelField(data, "labelCardClose");
								}else if(ApplicationType == "PublicCardRequest"){
									me.setLabelField(data, "labelPublicCard");
								}else if(ApplicationType == "PrCardApp"){
									me.setLabelField(data, "labelPrCard");
								}else if(ApplicationType == "CoCardNewissue"){
									me.setLabelField(data, "labelNewCard");
								}

								if(data.ApplicationStatus =="S"){
									$("[name=aprvBtn]").css("display", "");
								}
								me.appTypeChange(data);
								
								return;
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />");
							}
						}).error(function(response, status, error){
					});
				},

				//유형에 따라 화면 설정
				appTypeChange : function(input){
					var me = this;
					var val = input.ApplicationType;
					var popupH = '0px';
					if(val == "CoCardLimitChange"){
						$("#limitChangeArea").css("display",	"");
						$("#cardReissueArea").css("display",	"none");
						$("#cardCloseArea").css("display",		"none");
						$("#publidCardArea").css("display",		"none");
						$("#prCardArea").css("display",			"none");
						$("#newCardArea").css("display",		"none");
						popupH= '480px';
						
						if(input.LimitType=="Up"){
							$("#chgExpDateArea").css("display",			"");
							popupH= '500px';
						}
					}else if(val == "CoCardReissue"){
						$("#limitChangeArea").css("display",	"none");
						$("#cardReissueArea").css("display",	"");
						$("#cardCloseArea").css("display",		"none");
						$("#publidCardArea").css("display",		"none");
						$("#prCardArea").css("display",			"none");
						$("#newCardArea").css("display",		"none");
						popupH = '460px';
						
					}else if(val == "CoCardClose"){
						$("#limitChangeArea").css("display",	"none");
						$("#cardReissueArea").css("display",	"none");
						$("#cardCloseArea").css("display",		"");
						$("#publidCardArea").css("display",		"none");
						$("#prCardArea").css("display",			"none");
						$("#newCardArea").css("display",		"none");
						popupH = '460px';
						
					}else if(val == "PublicCardRequest"){
						$("#limitChangeArea").css("display",	"none");
						$("#cardReissueArea").css("display",	"none");
						$("#cardCloseArea").css("display",		"none");
						$("#publidCardArea").css("display",		"");
						$("#prCardArea").css("display",			"none");
						$("#newCardArea").css("display",		"none");
						popupH = '460px';
						
					}else if(val == "PrCardApp"){
						$("#limitChangeArea").css("display",	"none");
						$("#cardReissueArea").css("display",	"none");
						$("#cardCloseArea").css("display",		"none");
						$("#publidCardArea").css("display",		"none");
						$("#prCardArea").css("display", "");
						$("#newCardArea").css("display",		"none");
						popupH = '430px';
					}
					else if(val == "CoCardNewissue"){
						$("#limitChangeArea").css("display",	"none");
						$("#cardReissueArea").css("display",	"none");
						$("#cardCloseArea").css("display",		"none");
						$("#publidCardArea").css("display",		"none");
						$("#prCardArea").css("display", "none");
						$("#newCardArea").css("display",		"");
						popupH = '430px';
					}
					accountCtrl.changePopupSize('',popupH);
				},

				//카드 신청정보 저장, 조회전용 화면에선 미사용
				saveCardRequestData : function(){
					var me = this;
					$.ajax({
						type:"POST",
							url:"/account/baseInfo/saveCardApplicationData.do",
						data:{
							"cardAppObj" : JSON.stringify(me.params.pageDataObj),
						},
						success:function (data) {
							if(data.result == "ok"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다.
								
								me.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e){
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
								
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				//법인카드 변경시 설정, 조회전용 화면에선 미사용
				onCardChange : function(data, page){
					var me = this;
					var cardNo = null;
					if(data == null){
						cardNo = getTxTFieldDataPopup("cardAppPopupLimitChange_inputCardNo");
					}else{
						var cardNo = data.value;
					}
					
					if(!isEmptyStr(cardNo)){
						var cardLA = me.params.cardMap["cardLA_"+cardNo ];
						cardLA = toAmtFormat(cardLA)
						setFieldDataPopup(page+"_inputExpirationDate",	me.params.cardMap["cardED_"+cardNo ]);
						setFieldDataPopup(page+"_inputCurrentAmount",	cardLA);
					}else{
						setFieldDataPopup(page+"_inputExpirationDate",	"");
						setFieldDataPopup(page+"_inputCurrentAmount",	"");
					}
					
					if(page=="cardAppPopupLimitChange"){
						me.setLmtTyp();
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
				
				//==============================
					

				//라벨에 값 세팅
				setLabelField : function(inputData, labelNm){
					var me = window.VendorRequestViewPopup;
					if(inputData==null){
						return;
					}
					
					if(labelNm ==null){
						labelNm = "labelCardAppViewMain"
					}
					var labelList = $("label[name="+labelNm+"]")
				   	for(var i=0;i<labelList.length; i++){
				   		var getLabel = labelList[i];
				   		var field = getLabel.getAttribute("datafield");
				   		var tag = getLabel.getAttribute("tag");
				   		var val = nullToBlank(inputData[field])
				   		if(tag=="Amt"){
				   			val = toAmtFormat(val);
				   		}
				   		getLabel.innerHTML = val;
				   	}
				},
				
				//신청취소
				onAprvCancel : function(){
					var me = this;
					
					var getStat = me.params.pageDataObj.ApplicationStatus;
					if(getStat != 'D'
							&& getStat != 'S'){
						Common.Inform("<spring:message code='Cache.ACC_038'/>")		//신청상태가 아닌 항목입니다.
						return;
					}
					var aprvObj = {
							setStatus : 'T'
					};
					aprvObj.aprvList = 	[me.params.pageDataObj]
					
			        Common.Confirm("<spring:message code='Cache.ACC_039'/>", "Confirmation Dialog", function(result){	//신청취소 하시겠습니까?
			       		if(result){
							
							$.ajax({
								type:"POST",
									url:"/account/baseInfo/cardAprvStatChange.do",
								data:{
									"aprvObj"	: JSON.stringify(aprvObj),
								},
								success:function (data) {
									if(data.result == "ok"){
										parent.Common.Inform("<spring:message code='Cache.ACC_msg_processComplet'/>");	//처리를 완료하였습니다.
										try{
											accountCtrl.popupCallBackStr([]);
										}catch (e){
											coviCmn.traceLog(e);
											coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
										}
										me.closeLayer();
										
									}
								},
								error:function (error){
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
								}
							});
			       		}
			        });
				},

				//결제상태 변경
				onAprvChange : function(stat){
					<%
					//관리자와 사용자를 구분해서 화면 구성
					if("Y".equals(isAM)){
					%>
					var me = this;
					
					var getStat = me.params.pageDataObj.ApplicationStatus;
					if(getStat != 'D'
							&& getStat != 'S'){
						Common.Inform("<spring:message code='Cache.ACC_038'/>")		//신청상태가 아닌 항목입니다.
						return;
					}
					
					var aprvObj = {
							setStatus : stat
					};
					aprvObj.aprvList = 	[me.params.pageDataObj]
					if(stat=="E"){
						msg = "<spring:message code='Cache.ACC_msg_ckAccept' />";		//승인하시겠습니까?
					}else if(stat=="R"){
						msg = "<spring:message code='Cache.ACC_msg_ckReject' />";		//반려하시겠습니까?
					}
					
			        Common.Confirm(msg, "Confirmation Dialog", function(result){
			       		if(result){
							
							
							$.ajax({
								type:"POST",
									url:"/account/baseInfo/cardAprvStatChange.do",
								data:{
									"aprvObj"	: JSON.stringify(aprvObj),
								},
								success:function (data) {
									if(data.result == "ok"){
										parent.Common.Inform("<spring:message code='Cache.ACC_msg_processComplet'/>");	//처리를 완료하였습니다.
										try{
											accountCtrl.popupCallBackStr([]);
										}catch (e){
											coviCmn.traceLog(e);
											coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
										}
										me.closeLayer();
										
									//	Common.Inform("<spring:message code='Cache.ACC_msg_processComplet'/>");
									//	me.closeLayer();
									}
								},
								error:function (error){
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
								}
							});
			       		}
			        });
					<% 
						}
					%>
				}
				
				
		}
		window.CardApplicationViewPopup = $.extend(window.CardApplicationViewPopup, CardApplicationViewPopup);
	})(window);
	
	CardApplicationViewPopup.popupInit();
	
</script>