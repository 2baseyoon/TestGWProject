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
					<div id="topitembar02" class="bodysearch_Type01">
						<div class="inPerView type07">
							<div style="width:350px;">
								<div class="inPerTitbox">
									<!-- 거래처명 -->
									<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorName"/></span>
									<input onkeydown="VendorSelectPopup.onenter()" class="input_p100" id="vendorSearchPopup_inputSearchText" type="text" placeholder="">
								</div>
								<a class="btnTypeDefault  btnSearchBlue"	onclick="VendorSelectPopup.searchList()"><spring:message code="Cache.ACC_btn_search"/></a>
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

	if (!window.VendorSelectPopup) {
		window.VendorSelectPopup = {};
	}
	
	(function(window) {
		var VendorSelectPopup = {
				params	:{
					gridPanel		: new coviGrid(),
					headerData		: [],
					bankData		: [],
					includeAccount	: CFN_GetQueryString("includeAccount")
				},
				inputParams : {},
				
				pageInit : function(){
					var me = this;

					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						me.inputParams[paramKey] = paramValue
					}
					
					
					me.setHeaderData();

					if(me.inputParams.hasOwnProperty("businessNumber")){
						$("#vendorSearchPopup_inputSearchText").val(me.inputParams["businessNumber"]);
					}
					me.searchList();
				},
				
				setHeaderData : function() {
					var me = this;
					if(me.inputParams.isPE == "Y") {
						me.params.headerData = [	
												{ key:'VendorTypeName',			label:"<spring:message code='Cache.ACC_lbl_vendorType' />",			width:'70',		align:'center'},	//거래처구분
												{ key:'VendorNo',				label:"<spring:message code='Cache.ACC_lbl_registrationNumber' />",	width:'70',		align:'center'},	//주민등록번호
												{ key:'VendorNo',				label:"<spring:message code='Cache.ACC_lbl_vendorName' />",			width:'110',	align:'center',		//거래처명
							        				formatter:function () {
									            		 return "<a onclick='VendorSelectPopup.selectCode(\"" + this.item.VendorID + "\", \""+ this.item.VendorNo + "\", \""+ this.item.VendorName +"\"); return false;'><font color='blue'><u>"+this.item.VendorName+"</u></font></a>";
									            	}
												},
												{ key:'PaymentConditionName',	label:"<spring:message code='Cache.ACC_lbl_PayType' />",			width:'70',		align:'center'},		//지급조건
											]
					} else {
						me.params.headerData = [	
												{ key:'VendorTypeName',			label:"<spring:message code='Cache.ACC_lbl_vendorType' />",		width:'70',		align:'center'},	//거래처구분
												{ key:'CorporateNo',			label:"<spring:message code='Cache.ACC_lbl_CorporateNumber' />",	width:'70',		align:'center'},	//법인번호
												{ key:'BusinessNumber',			label:"<spring:message code='Cache.ACC_lbl_BusinessNumber' />",	width:'70',		align:'center'},	//사업자번호
												{ key:'VendorNo',				label:"<spring:message code='Cache.ACC_lbl_vendorName' />",		width:'110',	align:'center',		//거래처명
							        				formatter:function () {
									            		 return "<a onclick='VendorSelectPopup.selectCode(\"" + this.item.VendorID + "\", \""+ this.item.VendorNo + "\", \""+ this.item.VendorName +"\"); return false;'><font color='blue'><u>"+this.item.VendorName+"</u></font></a>";
									            	}
												},
												{ key:'PaymentConditionName',	label:"<spring:message code='Cache.ACC_lbl_PayType' />",			width:'70',		align:'center'},	//지급조건
											]
					}
					
					me.params.bankData	= [
											{ key:'BankName',			label:"<spring:message code='Cache.ACC_lbl_BankName' />",			width:'70', align:'center'},		//은행명
											{ key:'BankAccountNo',		label:"<spring:message code='Cache.ACC_lbl_BankAccount' />",			width:'70', align:'center'},		//은행계좌
										]
						
					if(VendorSelectPopup.params.includeAccount == 'Y'){
						me.params.headerData.concat(bankData);
					}
					
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
					var ajaxUrl		= "/account/CommonPopup/getVendorPopupList.do";
					var ajaxPars	= {	"searchText"	: searchText
										,"isPE" 		: nullToBlank(me.inputParams.isPE)
										,"companyCode"	: nullToBlank(me.inputParams.companyCode)
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
				
				selectCode : function(ID, Num, Name){
					var me = this;
					var info = {	'VendorID'		: ID
								,	'VendorNo'		: Num
								,	'VendorName'	: Name
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
				},
				
				onenter : function(){
					var me = this;
					if(event.keyCode=="13"){
						me.searchList();
					}
				}
		}
		window.VendorSelectPopup = VendorSelectPopup;
	})(window);

	VendorSelectPopup.pageInit();
	
</script>