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
	<div class="Layer_divpop ui-draggable docPopLayer"
		id="testpopup_p" style="width: auto;" source="iframe"
		modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<div class="eaccountingCont">
						<!-- 검색 내용 -->
						<div id="topitembar02" class="bodysearch_Type01">
							<div class="inPerView type07">
								<div style="width: 1200px;">
									<div class="inPerTitbox">
										<span class="bodysearch_tit">
											<!-- 거래일시 -->
											<spring:message code='Cache.ACC_lbl_tradeDT'/>
										</span>
										<div id="ddArea" class="dateSel type02">
										</div>
									</div>
									<div class="inPerTitbox">
										<span class="bodysearch_tit">
											<!-- 승인번호 -->
											<spring:message code='Cache.ACC_lbl_confirmNum'/>
										</span> 
										<input onkeydown="CashBillSearchPopup.onenter()" id="confirmNum" type="text" placeholder="">
									</div>
									<div class="inPerTitbox">
										<span class="bodysearch_tit">
											<!-- 가맹점명 -->
											<spring:message code='Cache.ACC_lbl_franchiseCorpName'/>
										</span> 
										<input onkeydown="CashBillSearchPopup.onenter()" id="franchiseCorpName" type="text" placeholder="">
									</div>
									<div class="inPerTitbox">
										<span class="bodysearch_tit">
											<!-- 사업자번호 -->
											<spring:message code='Cache.ACC_lbl_BusinessNumber'/>
										</span> 
										<input onkeydown="CashBillSearchPopup.onenter()" id="franchiseCorpNum" type="text" placeholder="">
									</div>
									<a class="btnTypeDefault  btnSearchBlue"
										onclick="CashBillSearchPopup.searchList();"><spring:message code='Cache.ACC_btn_search'/></a>
								</div>
							</div>
						</div>
						<div id="gridArea" class="pad10">
						</div>
					</div>
				</div>
				<div class="popBtnWrap bottom">
					<!-- 확인 -->
					<a onclick="CashBillSearchPopup.sendCashBill();"	id="btnSave"	class="btnTypeDefault btnThemeLine"><spring:message code='Cache.ACC_btn_confirm'/></a>
					<!-- 닫기 -->
					<a onclick="CashBillSearchPopup.closeLayer();"		id="btnClose"	class="btnTypeDefault"><spring:message code= 'Cache.ACC_btn_close'/></a>
				</div>
			</div>
		</div>
	</div>
</body>

<script>

	/*
	NTSConfirmNum
	TradeDT
	TradeType
	SupplyCost
	Tax
	ServiceFree
	TotalAmount
	FranchiseCorpName
	CashBillID
	
	현금영수증 승인번호
	거래일시
	승인 / 취소
	공급가액
	세금
	서비스금액
	거래금액
	발행자명
	*/
	if (!window.CashBillSearchPopup) {
		window.CashBillSearchPopup = {};
	}
	
	(function(window) {
		var CashBillSearchPopup = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
				inputParams : {},
				searchParam : {},
				
				pageInit : function(){
					var me = this;
					makeDatepicker("ddArea", "startDD", "endDD");
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
								me.searchParam = pa[me.inputParams.paramsetFunc]("CashBill");
							}
						}
					}
					me.setHeaderData();
					me.searchList();
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'chk',					label:'chk',									width:'20',		align:'center',
													formatter:'checkbox'
												},
												{	key:'NTSConfirmNum',		label:"<spring:message code='Cache.ACC_lbl_confirmNum' />",			width:'100',	align:'center'},//승인번호
												{	key:'FranchiseCorpName',	label:"<spring:message code='Cache.ACC_lbl_franchiseCorpName' />",	width:'50',		align:'center'},//발행자명
												{	key:'TradeType',			label:"<spring:message code='Cache.ACC_lbl_tradeType' />",			width:'50',		align:'center'},//거래구분
												{	key:'SupplyCost',			label:"<spring:message code='Cache.ACC_lbl_supplyValue' />",			width:'50',		align:'center',//공급가액
													formatter: function () { return toAmtFormat(this.item.SupplyCost); }
												},
												{	key:'Tax',					label:"<spring:message code='Cache.ACC_lbl_taxValue' />",			width:'50',		align:'center',//세액
													formatter: function () { return toAmtFormat(this.item.Tax); }	
												},
												{	key:'TotalAmount',			label:"<spring:message code='Cache.ACC_lbl_totalAmount' />",			width:'50',		align:'center',//합계금액
													formatter: function () { return toAmtFormat(this.item.TotalAmount); }		
												},
												{	key:'TradeDT',				label:"<spring:message code='Cache.ACC_lbl_tradeDT' />",					width:'150',	align:'center',//거래일시
													formatter: function () { return accComm.accFormatDate(this.item.TradeDT); }	
												},
												{	key:'CashBillID',			label:'CashBillID',									width:'50',		align:'center', display:false}
											]
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(){
					var me = this;
					
					me.setHeaderData();
					var startDD			= $('#startDD').val().replaceAll('.','');
					var endDD			= $('#endDD').val().replaceAll('.','');	
					var confirmNum		= $('#confirmNum').val();
					var franchiseCorpName		= $('#franchiseCorpName').val();
					var franchiseCorpNum		= $('#franchiseCorpNum').val();
					var pageSizeInfo	= 200;
					
					var gridAreaID	= "gridArea";
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					var ajaxUrl		= "/account/accountCommon/getCashBillPopupList.do";
					var ajaxPars	= {	"startDD"	: startDD,
										"endDD"		: endDD,
										"confirmNum": confirmNum,
										"franchiseCorpName": franchiseCorpName,
										"franchiseCorpNum": franchiseCorpNum,
										"pageSize"	: pageSizeInfo,
					 					"ExpAppID"	: me.searchParam.ExpAppID,
					 					"idStr"	: me.searchParam.idStr
									};
					
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
				
				sendCashBill : function(){
					var me = this;
					var cashBillObj = me.params.gridPanel.getCheckedList(0);
					if(cashBillObj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noSaveData' />");
						return;
					}else{
						var cashBillSeq = "";
						for(var i=0; i<cashBillObj.length; i++){
							if(i==0){
								cashBillSeq = cashBillObj[i].CashBillID;
							}else{
								cashBillSeq = cashBillSeq + "," + cashBillObj[i].CashBillID;
							}
						}
						
						me.closeLayer();
						
						try{
							accountCtrl.popupCallBackStr([cashBillSeq]);
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
		window.CashBillSearchPopup = CashBillSearchPopup;
	})(window);
	
	CashBillSearchPopup.pageInit();
</script>
