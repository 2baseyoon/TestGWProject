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
		id="testpopup_p" style="width: 700px;" source="iframe"
		modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent ">
			
				<div id="topitembar02" class="bodysearch_Type01">
					<div class="eaccountingTopCont">
					</div>
					<div class="inPerView type07">
						<div style="width:600px;">
							<div class="inPerTitbox">
								<span class="bodysearch_tit">
									<!-- 제목 -->
									<spring:message code='Cache.ACC_lbl_title'/>
								</span> 
								<input id="searchAppTitle" name="searchField" datafield="ApplicationTitle" type="text" placeholder="">
							</div>
							<a class="btnTypeDefault  btnSearchBlue"	onclick="ExpAppDocLinkMulti.searchList();">
								<spring:message code='Cache.ACC_btn_search'/>
							</a>
						</div>
					</div>
				</div>
			
				<div id="gridArea" class="pad10" >
				</div>
			
				<div class="bottom">
					<a onclick="ExpAppDocLinkMulti.sendDocList();"	id="btnSave"	class="btnTypeDefault btnThemeLine">
						<!-- 완료 -->
						<spring:message code='Cache.ACC_btn_confirm'/>
					</a>
					<a onclick="ExpAppDocLinkMulti.closeLayer();"	id="btnClose"	class="btnTypeDefault">
						<spring:message code='Cache.ACC_btn_close'/>
					</a>
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
	if (!window.ExpAppDocLinkMulti) {
		window.ExpAppDocLinkMulti = {};
	}
	
	(function(window) {
		var ExpAppDocLinkMulti = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
				
				pageInit : function(){
					var me = this;
					me.setHeaderData();
					me.searchList();
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'chk',					label:'chk',	width:'20',	align:'center',
									       			formatter:'checkbox'
									       		},
								          	   //	{	key:'ApplicationTitle',		label:'제목',		width:'80',	align:'center'},
								          	   	

												{ key:'ApplicationTitle',		label : "<spring:message code='Cache.ACC_lbl_title' />",				width:'70', align:'center'		//제목
													, formatter:function () {
														var title = "("+"<spring:message code='Cache.ACC_lbl_noTitle' />"+")";

														if(!isEmptyStr(this.item.ApplicationTitle)){
															title = this.item.ApplicationTitle;
														}

														return title;
													}
												},
								          	   	
								          	   	
												{	key:'ApplicationTypeName',		label:"<spring:message code='Cache.ACC_lbl_evidType' />",	width:'60',	align:'center'},	//증빙유형
												{	key:'ApplicationStatusName',	label:"<spring:message code='Cache.ACC_lbl_evidStatus' />",	width:'60',	align:'center'},	//증빙상태
												{	key:'RegisterID',				label:"<spring:message code='Cache.ACC_lbl_registerName' />",width:'60',	align:'center'},	//등록자
											]
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(){
					var me = this;
					
					me.setHeaderData();
		 			
					var pageSizeInfo	= 10;
					
					var appTitle = $("#searchAppTitle").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/accountCommon/getExpAppDocList.do";
					var ajaxPars		= {	"pageSize":pageSizeInfo
											, ApplicationTitle : appTitle
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
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
				},
				
				sendDocList : function(){
					var me = this;
					var docObj = me.params.gridPanel.getCheckedList(0);
					if(docObj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noSaveData' />");
						return;
					}else{
						var obj = [];
						for(var i=0; i<docObj.length; i++){
							obj.push(docObj[i]);
						}
						me.closeLayer();
						
						try{
							accountCtrl.popupCallBackStr([obj]);
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
				}
		}
		window.ExpAppDocLinkMulti = ExpAppDocLinkMulti;
	})(window);
	
	ExpAppDocLinkMulti.pageInit();
</script>
