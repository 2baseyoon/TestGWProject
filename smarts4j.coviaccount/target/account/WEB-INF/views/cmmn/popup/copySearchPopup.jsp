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
	<div class="layer_divpop ui-draggable docPopLayer" style="width:1000px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
					<div id="topitembar02" class="bodysearch_Type01">
						<div class="inPerView type07">
							<div style="width:800px;">
								<div class="inPerTitbox">
									<span class="bodysearch_tit">
										<!-- 작성일자 -->
										<spring:message code='Cache.ACC_lbl_writeDate'/>
									</span>
									<div id="ddArea" class="dateSel type02">
									</div>
								</div>
								<div class="inPerTitbox">
									<!-- 거래처명 -->
									<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorName"/></span>
									<input onkeydown="ListCopySelectPopup.onenter()" class="input_p100" id="vendorSearchPopup_inputSearchText" type="text" placeholder="">
								</div>
								<a class="btnTypeDefault  btnSearchBlue"	onclick="ListCopySelectPopup.searchList()"><spring:message code="Cache.ACC_btn_search"/></a>
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

	if (!window.ListCopySelectPopup) {
		window.ListCopySelectPopup = {};
	}
	
	(function(window) {
		var ListCopySelectPopup = {
				params	:{
					gridPanel		: new coviGrid(),
					headerData		: [],
					bankData		: [],
					includeAccount	: CFN_GetQueryString("includeAccount"),
					vendorNo		: CFN_GetQueryString("vendorNo"),
					proofCode		: CFN_GetQueryString("proofCode"),
					usid			: CFN_GetQueryString("usid"),
					companyCode		: CFN_GetQueryString("companyCode")
				},
				inputParams : {},
				
				pageInit : function(){
					var me = this;
					makeDatepicker("ddArea", "SDate", "EDate");

					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						me.inputParams[paramKey] = paramValue
					}
					
					
					me.setHeaderData();

					/* if(me.inputParams.hasOwnProperty("businessNumber")){
						$("#vendorSearchPopup_inputSearchText").val(me.inputParams["businessNumber"]);
					} */
					me.searchList();
				},
				
				setHeaderData : function() {
					var me = this;					
					me.params.headerData = [			 			
											{ key:'VendorName',			label:"<spring:message code='Cache.ACC_lbl_vendor' />",		width:'70',		align:'center'},	//거래처
											{ key:'VendorNo',			label:"<spring:message code='Cache.ACC_lbl_vendorCode' />",		width:'70',		align:'center'},	//거래처코드
											{ key:'ApplicationTitle',			label:"<spring:message code='Cache.ACC_lbl_title' />",		width:'70',		align:'center', 
												formatter:function () {
													var rtStr =	""
																+	"<a onclick='ListCopySelectPopup.clickLiskInfo(\""
																		+ this.item.ExpenceApplicationListID	+"\"" +	"); return false;'>"
																+		"<font color='blue'>"
																+			this.item.ApplicationTitle
																+		"</font>"
																+	"</a>";
													return rtStr;
												}
											
											
											},	// 제목
											{ key:'ProofCode',			label:"<spring:message code='Cache.ACC_lbl_proofType' />",	width:'70',		align:'center'},	// 증빙구분
											{ key:'TotalAmount',			label:"<spring:message code='Cache.ACC_lbl_totalAmount' />",	width:'70',		align:'center'},	//합꼐금액
											{ key:'ProofDate',				label:"<spring:message code='Cache.ACC_lbl_StatementGenerateDate' />",		width:'70',	align:'center'},		// 전표생얼일
											{ key:'DisplayName',				label:"<spring:message code='Cache.lbl_apv_doc03' />",		width:'70',	align:'center'},		// 작성자
						        				/* formatter:function () {
								            		 return "<a onclick='VendorSelectPopup.selectCode(\"" + this.item.VendorID + "\", \""+ this.item.VendorNo + "\", \""+ this.item.VendorName +"\"); return false;'><font color='blue'><u>"+this.item.VendorName+"</u></font></a>";
								            	}
											},
											{ key:'PaymentConditionName',	label:"<spring:message code='Cache.ACC_lbl_PayType' />",			width:'70',		align:'center'},	//지급조건 */
										]
										
				/* 	me.params.bankData	= [
											{ key:'BankName',			label:"<spring:message code='Cache.ACC_lbl_BankName' />",			width:'70', align:'center'},		//은행명
											{ key:'BankAccountNo',		label:"<spring:message code='Cache.ACC_lbl_BankAccount' />",			width:'70', align:'center'},		//은행계좌
										]
						
					if(VendorSelectPopup.params.includeAccount == 'Y'){
						me.params.headerData.concat(bankData);
					} */
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(){
					var me = this;
					me.setHeaderData();
					var searchText	= $("#vendorSearchPopup_inputSearchText").val();
					var SDate		= $("#SDate").val().replaceAll('.','');
					var EDate		= $("#EDate").val().replaceAll('.','');
					
					
					var gridAreaID	= "gridArea";
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					var ajaxUrl		= "/account/CommonPopup/getCopyPopupList.do";
					var ajaxPars	= {	"vendorName"	: searchText
										,"SDate" 		: SDate
										,"EDate"		: EDate
										,"proofCode"	: me.params.proofCode
										,"vendorNo"		: me.params.vendorNo
										,"usid"			: me.params.usid
										,"companyCode"	: me.params.companyCode
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
				
				clickLiskInfo : function(key){
					var me = this;
					var grid		= me.params.gridPanel;
					var list		= grid.list;
					var clickInfo	= {};
					
					for(var i=0; i<list.length; i++){
						var info = list[i];
						if(info.ExpenceApplicationListID == key){
							clickInfo = info;
							break;
						}
					}
					me.closeLayer();
					
					try{
						accountCtrl.popupCallBackStr([clickInfo]);
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
		window.ListCopySelectPopup = ListCopySelectPopup;
	})(window);

	ListCopySelectPopup.pageInit();
	
</script>