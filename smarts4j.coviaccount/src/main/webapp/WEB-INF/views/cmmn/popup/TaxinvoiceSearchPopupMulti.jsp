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
	.pad10 { padding:10px;}
</style>

<body>
	<input id="searchProperty"	type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:auto;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<div class="eaccountingCont">
						<div id="topitembar02" class="bodysearch_Type01">
							<div class="inPerView type07">
								<div style="width:900px;">
									<div class="inPerTitbox">
										<span class="bodysearch_tit">
											<!-- 작성일 -->
											<spring:message code='Cache.ACC_lbl_writeDate'/>
										</span>
										<input type="text" id="writeDateS"	style="width: 110px" class="adDate" /> ~ 
										<input type="text" id="writeDateE"	style="width: 110px" class="adDate"	kind="twindate" date_startTargetID="writeDateS"/>
									</div>
									<div class="inPerTitbox">
										<span class="bodysearch_tit">
											<!-- 구분 -->
											<spring:message code='Cache.ACC_lbl_division'/>
										</span>
										<span id="tiSearchTypePop" class="selectType02">
										</span>
										<input onkeydown="TaxinvoiceSearchPopupMulti.onenter()" id="searchStr" type="text" placeholder="">
									</div>
									<div class="inPerTitbox">
										<span class="bodysearch_tit">
											E-Mail
										</span>
										<input onkeydown="TaxinvoiceSearchPopupMulti.onenter()" id="invoiceeEmail1" type="text" placeholder="">
									</div>
									<a class="btnTypeDefault  btnSearchBlue"	onclick="TaxinvoiceSearchPopupMulti.searchList();"><spring:message code='Cache.ACC_btn_search'/></a>
								</div>
							</div>
							<div class="eaccountingTopCont">
							</div>
						</div>
						<div id="gridArea" class="pad10">
						</div>
					</div>
					
					<div class="popBtnWrap bottom">
						<a onclick="TaxinvoiceSearchPopupMulti.sendTaxBill();"	id="btnSave"	class="btnTypeDefault btnThemeLine"><spring:message code='Cache.ACC_btn_confirm'/></a>
						<a onclick="TaxinvoiceSearchPopupMulti.closeLayer();"	id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_close'/></a>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>

<script>
	if (!window.TaxinvoiceSearchPopupMulti) {
		window.TaxinvoiceSearchPopupMulti = {};
	}
	
	(function(window) {
		var TaxinvoiceSearchPopupMulti = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
				
				pageInit : function(){
					var me = this;
					setPropertySearchType('Taxinvoice','searchProperty');
					me.setSelectCombo();
					me.setHeaderData();
					me.searchList();
				},
				
				setSelectCombo : function(){
					accountCtrl.renderAXSelect('tiSearchTypePop',	'tiSearchTypePop',	'ko','','','',"<spring:message code='Cache.ACC_lbl_comboAll' />");
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'chk',					label:'chk',		width:'20',		align:'center',
									       			formatter:'checkbox'
									       		},
								          	   	{	key:'NTSConfirmNum',			label:"<spring:message code='Cache.ACC_lbl_confirmNum' />",			width:'80',		align:'center'},//승인번호
												{	key:'FormatWriteDate',			label:"<spring:message code='Cache.ACC_lbl_writeDate' />",			width:'80',		align:'center'},//작성일
												{	key:'InvoicerCorpNum',			label:"<spring:message code='Cache.ACC_lbl_BusinessNumber' />",		width:'120',	align:'center'},//사업자번호
												{	key:'InvoicerCorpName',			label:"<spring:message code='Cache.ACC_lbl_franchiseCorpName' />",	width:'100',	align:'center'},//가맹점명
												{	key:'FormatTotalAmount',		label:"<spring:message code='Cache.ACC_lbl_totalAmount' />",			width:'100',	align:'right'},//합계금액
												{	key:'FormatSupplyCostTotal',	label:"<spring:message code='Cache.ACC_lbl_supplyValue' />",			width:'100',	align:'right'},//공급가액
												{	key:'FormatTaxTotal',			label:"<spring:message code='Cache.ACC_lbl_taxType' />",				width:'100',	align:'right'}//부가세
											]
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(){
					var me = this;
					
					me.setHeaderData();
		 			
					var writeDateS		= $("#writeDateS").val();
					var writeDateE		= $("#writeDateE").val();
					var tiSearchTypePop	= $("#tiSearchTypePop").val();
					var searchStr		= $("#searchStr").val();
					var invoiceeEmail1	= $("#invoiceeEmail1").val();
					var searchProperty	= $("#searchProperty").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/accountCommon/getTaxinvoiceSearchPopupList.do";
					var ajaxPars		= {	"popupName"			: "TaxinvoiceSearchPopup"
						 				,	"pageing"			: "Y"
						 				,	"writeDateS"		: writeDateS
						 				,	"writeDateE"		: writeDateE
						 				,	"tiSearchTypePop"	: tiSearchTypePop
						 				,	"searchStr"			: searchStr
						 				,	"invoiceeEmail1"	: invoiceeEmail1
						 				,	"searchProperty"	: searchProperty
					};
					
					var pageNoInfo		= 1;
					var pageSizeInfo	= 200;
					
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
				
				sendTaxBill : function(){
					var me = this;
					var taxBillObj = me.params.gridPanel.getCheckedList(0);
					if(taxBillObj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noSaveData' />");
						return;
					}else{
						var taxBillSeq = "";
						for(var i=0; i<taxBillObj.length; i++){
							if(i==0){
								taxBillSeq = taxBillObj[i].TaxInvoiceID;
							}else{
								taxBillSeq = taxBillSeq + "," + taxBillObj[i].TaxInvoiceID;
							}
						}
						me.closeLayer();
						
						try{
							accountCtrl.popupCallBackStr([taxBillSeq]);
						}catch (e) {
							coviCmn.traceLog(e);
							coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
						}
					}
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
		window.TaxinvoiceSearchPopupMulti = TaxinvoiceSearchPopupMulti;
	})(window);
	
	TaxinvoiceSearchPopupMulti.pageInit();
	
</script>