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
	<div class="layer_divpop ui-draggable docPopLayer" style="width:700px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div id="gridArea" class="pad10">
				</div>
			</div>
		</div>
	</div>
</body>

<script>

	if (!window.PrivateCardSearchPopup) {
		window.PrivateCardSearchPopup = {};
	}
	
	(function(window) {
		var CompanyCode = CFN_GetQueryString("companyCode") == "undefined" ? "" : CFN_GetQueryString("companyCode");
		
		var PrivateCardSearchPopup = {
				params	:{
					gridPanel		: new coviGrid(),
					headerData		: [],
					bankData		: [],
					includeAccount	: CFN_GetQueryString("includeAccount")
				},
				
				pageInit : function(){
					var me = this;
					me.setHeaderData();
					me.searchList();
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	
											{ key:'CardNoView',			label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",				width:'70',		align:'center',	//카드번호
						        				formatter:function () {
								            		 return "<a onclick='PrivateCardSearchPopup.selectCode(\"" + this.item.CardNo 
								            				 + "\", \""+ this.item.CardNoView +"\"); '><font color='blue'><u>"+this.item.CardNoView+"</u></font></a>";
								            	}},
												{ key:'OwnerUserName',			label:"<spring:message code='Cache.ACC_lbl_cardOwner' />",		width:'70',		align:'center'},	//소유자
												{ key:'CardCompanyName',			label:"<spring:message code='Cache.ACC_lbl_cardCompany' />",	width:'70',		align:'center'},	//카드회사
										]
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(){
					var me = this;
					
					me.setHeaderData();
					
					var searchText	= $("#vendorSearchPopup_inputSearchText").val();
					var gridAreaID	= "gridArea";
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					var ajaxUrl		= "/account/CommonPopup/getPrivateCardPopupList.do";
					var ajaxPars	= {	
										"searchText"	: searchText,
										"companyCode"	: CompanyCode
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
				
				selectCode : function(CardNo, CardNoView){
					var me = this;
					var info = {	'CardNo'		: CardNo
								,	'CardNoView'		: CardNoView
					}
					try{
						accountCtrl.popupCallBackStrObj([info]);
					}catch (e) {
						coviCmn.traceLog(e);
						coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
					}
					me.closeLayer();
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
		window.PrivateCardSearchPopup = PrivateCardSearchPopup;
	})(window);

	PrivateCardSearchPopup.pageInit();
	
</script>