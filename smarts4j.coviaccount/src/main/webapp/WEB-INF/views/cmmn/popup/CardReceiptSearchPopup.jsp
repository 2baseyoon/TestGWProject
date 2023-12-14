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

<style>
	.pad10 {padding:10px;}
</style>
<body>
	<input id="searchProperty"	type="hidden" />
	<div class="Layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width: auto;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<div class="eaccountingCont">
						<!-- 검색 내용 -->
						<div id="topitembar02" class="bodysearch_Type01">
							<div class="inPerView type07">
								<div style="width: 1200px;">
									<div class="inPerTitbox">
										<!-- 이용일자 -->
										<span class="bodysearch_tit"> <spring:message code='Cache.ACC_lbl_useDate'/> </span>
										<div id="ddArea" class="dateSel type02">
										</div>
									</div>
									<div id="storeNameArea" class="inPerTitbox">
										<span class="bodysearch_tit"> <spring:message code='Cache.ACC_lbl_franchiseCorpName'/> </span> 
										<input onkeydown="CardReceiptSearchPopup.onenter()"	id="storeName" type="text" placeholder="">
									</div>
									<div class="inPerTitbox">
										<!-- 카드번호 -->
										<span class="bodysearch_tit"> <spring:message code='Cache.ACC_lbl_cardNumber'/> </span> 
										<input id="cardNo" onkeydown="CardReceiptSearchPopup.onenter()"	type="text" placeholder="" style="display:none"> 
										<span class="selectType02 size233" style="width: 190px;" id="cardNoSelect" onChange="CardReceiptSearchPopup.onenter()">
										</span>
									</div>
									<div class="inPerTitbox">
										<!-- 승인번호 -->
										<span class="bodysearch_tit"> <spring:message code='Cache.ACC_lbl_confirmNum'/> </span> 
										<input id="approveNo" style="width: 120px;" onkeydown="CardReceiptSearchPopup.onenter()"	type="text" placeholder="">
									</div>
									<a class="btnTypeDefault  btnSearchBlue" onclick="CardReceiptSearchPopup.searchList();"><spring:message code='Cache.ACC_btn_search'/></a>
								</div>
							</div>
						</div>
						<div style="margin-top: -7px;">
							<a href="#" class="btnTypeDefault" onclick="CardReceiptSearchPopup.cardReceiptPersonal()"><spring:message code="Cache.ACC_lbl_personalUse"/></a> <!-- 개인사용 -->
						</div>
						<div id="gridArea" class="pad10">
						</div>
					</div>
				</div>
				<div class="popBtnWrap bottom">
					<!-- 확인 -->
					<a onclick="CardReceiptSearchPopup.saveCardReceipt();"	id="btnSave"	class="btnTypeDefault btnThemeLine"><spring:message code='Cache.ACC_btn_confirm'/></a>
					<!-- 닫기 -->
					<a onclick="CardReceiptSearchPopup.closeLayer();"		id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_close'/></a>
				</div>
			</div>
		</div>
	</div>
</body>

<script>
	
	if (!window.CardReceiptSearchPopup) {
		window.CardReceiptSearchPopup = {};
	}
	
	(function(window) {
		var CardReceiptSearchPopup = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
				inputParams : {},
				searchParam : {},
				
				pageInit : function(){
					var me = this;
					
					makeDatepicker("ddArea", "startDD", "endDD");
					setPropertySearchType('CardReceipt','searchProperty');
					me.setPageViewController();
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						me.inputParams[paramKey] = paramValue
					}
					
					if(me.inputParams.openerID != null
							||me.inputParams.paramsetFunc != null){
						if(parent[me.inputParams.openerID] != null){
							var pa = parent[me.inputParams.openerID];
							if(typeof(pa[me.inputParams.paramsetFunc])=="function"){
								me.searchParam = pa[me.inputParams.paramsetFunc]("CorpCard");
							}
						}
					}
					me.setComboDataLoad();
					me.setHeaderData();
					me.searchList();
				},
				//폼에 세팅할 콤보 데이터 조회
				setComboDataLoad : function() {
					var me = this;
					//카드목록 조회
					$.ajax({
						type:"POST",
						url:"/account/expenceApplication/getCardList.do",
						async:false,
						data:{
							"UR_Code"			: me.inputParams['Sub_UR_Code']
 						,	"RequestType"		: me.inputParams['RequestType']
 						,	"CompanyCode"		: me.inputParams['CompanyCode']
						},
						success:function (data) {
							if(data.result == "ok"){
								if(data.list.length > 0) {
									accountCtrl.createAXSelectData("cardNoSelect",data.list, null, 'CorpCardID', 'CorpCardName', null, null, null  );
								} else {
									$("#cardNoSelect").parent().hide();
								}
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				setPageViewController : function() {
					var searchProperty	= $("#searchProperty").val();
					
					if(searchProperty == "SAP"){
						$("#storeNameArea").css("display",		"none");
					}else if(searchProperty == "SOAP"){
						$("#storeNameArea").css("display",		"none");
					}else{
						$("#storeNameArea").css("display",		"");
					}
				},
				
				setHeaderData : function() {
					var me = this;


					var searchProperty	= $('#searchProperty').val();
					if(searchProperty == 'SAP'){
						me.params.headerData = [	{	key:'chk',			label:'chk',		width:'20',		align:'center',
														formatter:'checkbox'
													},
													{	key:'CardNo',		label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",			width:'60',	align:'center'},//카드번호
													{	key:'ApproveDate',	label:"<spring:message code='Cache.ACC_lbl_approveDate' />",			width:'80',	align:'center'},	//사용일자
													{	key:'ApproveNo',	label:"<spring:message code='Cache.ACC_lbl_confirmNum' />",			width:'50',		align:'center'},//승인번호
													{	key:'StoreName',	label:"<spring:message code='Cache.ACC_lbl_franchiseCorpName' />",	width:'100',		align:'left'},	//가맹점명
													{	key:'AmountWon',	label:"<spring:message code='Cache.ACC_lbl_totalAmount' />",			width:'50',		align:'right'},	//합계금액
													{	key:'RepAmount',	label:"<spring:message code='Cache.ACC_lbl_supplyValue' />",			width:'50',		align:'right'},	//공급가액
													{	key:'TaxAmount',	label:"<spring:message code='Cache.ACC_lbl_taxType' />",				width:'50',		align:'right'}	//부가세
												]
					}else{
						me.params.headerData = [	{	key:'chk',			label:'chk',		width:'20',		align:'center',
													formatter:'checkbox'
												},
												{	key:'CardNo',		label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",				width:'60',	align:'center'},//카드번호
												{	key:'ApproveDate',	label:"<spring:message code='Cache.ACC_lbl_useDate' />",					width:'80',	align:'center'},//이용일자
												{	key:'ApproveNo',	label:"<spring:message code='Cache.ACC_lbl_confirmNum' />",				width:'50',		align:'center'},//승인번호
												{	key:'StoreName',	label:"<spring:message code='Cache.ACC_lbl_franchiseCorpName' />",		width:'100',		align:'left'},	//가맹점명
												{	key:'AmountWon',	label:"<spring:message code='Cache.ACC_lbl_amountWon' />",				width:'50',		align:'right'},	//이용금액
												{	key:'RepAmount',	label:"<spring:message code='Cache.ACC_lbl_repAmount' />",				width:'50',		align:'right'},	//판매금액
												{	key:'TaxAmount',	label:"<spring:message code='Cache.ACC_lbl_taxType' />",					width:'50',		align:'right'},	//부가세												
												{	key:'InfoType',		label:"<spring:message code='Cache.ACC_lbl_cancelYN' />",				width:'50',		align:'center'},	//취소유무
												{	key:'ReceiptID',	label:"<spring:message code='Cache.lbl_view' />",					width:'50',		align:'center', sort:false,	//상세보기 팝업
													formatter:function () {
														var rtStr =	""
															+	"<a class='btn_Bill' onclick='CardReceiptSearchPopup.clickCardReceiptPopup(\""
																+ this.item.ReceiptID	+"\""
															+		"); return false;'>"
															+	"</a>";
														return rtStr;
													}
												}
											]
					}
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(){
					var me = this;
					
					me.setHeaderData();
					
					var startDD			= $('#startDD').val().replaceAll('.','');
					var endDD			= $('#endDD').val().replaceAll('.','');	
					var storeName		= $('#storeName').val();
					var cardNo			= $('#cardNo').val();
					var cardID			= accountCtrl.getComboInfo("cardNoSelect").val()
					var approveNo		= $('#approveNo').val();
					var searchProperty	= $('#searchProperty').val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/accountCommon/getCardReceiptSearchPopupList.do";
					var ajaxPars		= {	"ExpAppID"			: me.searchParam.ExpAppID
						 				,	"idStr"				: me.searchParam.idStr
						 				,	"startDD"			: startDD
						 				,	"endDD"				: endDD
					 					,	"storeName"			: storeName
				 						,	"cardNo"			: cardNo
				 						,	"approveNo"			: approveNo
				 						,	"searchProperty"	: searchProperty
				 						,	"cardID"			: cardID
				 				};
					
					var pageSizeInfo	= 200;
					var pageNoInfo		= 1;
					
					var gridParams = {	"gridAreaID"	: gridAreaID
									,	"gridPanel"		: gridPanel
									,	"gridHeader"	: gridHeader
									,	"ajaxUrl"		: ajaxUrl
									,	"ajaxPars"		: ajaxPars
									,	"pageNoInfo"	: pageNoInfo
									,	"pageSizeInfo"	: pageSizeInfo
									,	"popupYN"		: 'Y'
									, 	"pagingTF"		: false
									,	"height"		: "480px"
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
					
					accountCtrl.setGridBodyOption(gridPanel, ajaxUrl, ajaxPars);
				},
				
				saveCardReceipt : function(){
					var me = this;
					var cardReceiptObj = me.params.gridPanel.getCheckedList(0);
					if(cardReceiptObj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noSaveData' />");		//저장할 데이터가 없습니다.
						return;
					}else{
						me.closeLayer();
						
						try{
							accountCtrl.popupCallBackStr([cardReceiptObj]);
						}catch (e) {
							coviCmn.traceLog(e);
							coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
						}
					}
				},
				
				cardReceiptPersonal : function(){
					var me = this;
					var chkList = me.params.gridPanel.getCheckedList(0);
					if(chkList.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");	// 선택된 항목이 없습니다.
						return;
					}
					
					Common.Confirm("<spring:message code='Cache.ACC_msg_personalUseYN' />", "<spring:message code='Cache.ACC_lbl_personalUse' />", function(result){	
			       		if(result){
							var params				= new Object();
							params.isPersonalUse	= 'Y';
							params.chkList			= chkList;
							
							$.ajax({
								url			: "/account/cardReceipt/saveCardReceiptPersonal.do",
								type		: "POST",
								data		: JSON.stringify(params),
								dataType	: "json",
								contentType	: "application/json",
								
								success:function (data) {
									if(data.status == "SUCCESS"){
										me.searchList();
									}else{
										Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
									}
								},
								error:function (error){
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
								}
							});
			       		}
					});
				},
				
				clickCardReceiptPopup : function(ReceiptID) {
					var me = this;
					accComm.accCardAppClick(ReceiptID, "openerID=CardReceiptSearchPopup&");					
				},
				
				closeLayer : function() {
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				},
				
				onenter : function(){
					var me = this;
					if(event.keyCode=="13"){
						me.searchList();
					}
				}
		}
		window.CardReceiptSearchPopup = CardReceiptSearchPopup;
	})(window);
	
	CardReceiptSearchPopup.pageInit();
</script>
