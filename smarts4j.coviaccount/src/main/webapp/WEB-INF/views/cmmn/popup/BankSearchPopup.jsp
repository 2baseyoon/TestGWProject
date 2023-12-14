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
	<div class="layer_divpop ui-draggable docPopLayer" style="width:350px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
					<div id="topitembar02" class="bodysearch_Type01">
						<div class="inPerView type07">
							<div style="width:300px;">
								<div class="inPerTitbox">
									<input onkeydown="BankSearchPopup.onenter()" class="input_p100" id="bankSearchPopup_inputSearchText" type="text" placeholder="">
								</div>
								<a class="btnTypeDefault  btnSearchBlue"	onclick="BankSearchPopup.searchList();"><spring:message code="Cache.ACC_btn_search"/></a>
							</div>
						</div>
					</div>
					<div id="gridArea" class="pad10">
					</div>
			</div>
		</div>
	</div>
</body>

<script>

	if (!window.BankSearchPopup) {
		window.BankSearchPopup = {};
	}
	
	(function(window) {
		var CompanyCode = CFN_GetQueryString("companyCode") == "undefined" ? "" : CFN_GetQueryString("companyCode");
		
		var BankSearchPopup = {
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
					me.params.headerData = [{ key:'Code',		label:"<spring:message code='Cache.ACC_lbl_bankCode' />",	width:'30', align:'center',//은행코드
						        				formatter:function () {
								            		 return "<a onclick='BankSearchPopup.selectCode(\"" + this.item.Code + "\", \""+ this.item.CodeName +"\"); return false;'><font color='blue'><u>"+this.item.Code+"</u></font></a>";
								            	}
							          	 	},
							          	   	{ key:'CodeName',	label:"<spring:message code='Cache.ACC_lbl_BankName' />",	width:'70', align:'center'},//은행명
										]
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(){
					var me = this;
					
					me.setHeaderData();
					
					var searchText		= $("#bankSearchPopup_inputSearchText").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/CommonPopup/getBankCodeList.do";
					var ajaxPars		= {	
											"searchText"	: searchText,
											"companyCode"	: CompanyCode
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
									,	"height"		: "250px"
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
					
					accountCtrl.setGridBodyOption(gridPanel, ajaxUrl, ajaxPars);
				},
				
				selectCode : function(Code, CodeName){
					var me = this;
					var info = {	'Code'		: Code
								,	'CodeName'	: CodeName
					}
					
					me.closeLayer();
					try{
						accountCtrl.popupCallBackStr([info]);
					}catch (e) {
						coviCmn.traceLog(e);
						coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
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
		window.BankSearchPopup = BankSearchPopup;
	})(window);
	
	BankSearchPopup.pageInit();
</script>