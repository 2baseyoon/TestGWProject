<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

	<style>
		.pad10 { padding:10px;}
	</style>
	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<h2 id="headerTitle" class="title"></h2>
	</div>
	<input id="searchProperty"	type="hidden" />
	<input id="syncPropertyTax" type="hidden" />
	<input id="syncPropertyCash" type="hidden" />
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 새로고침 -->
					<a class="btnTypeDefault"			onclick="SendDelayTax.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 미상신 알림전송 -->
					<a class="btnTypeDefault" 			onclick="SendDelayTax.sendDelay();"><spring:message code="Cache.lbl_AccDelaySend"/></a>
				</div>
				<!-- 상단 버튼 끝 -->
			<div style="padding-top:5px; display: inline-block; padding-top: 20px;">
				<input type="radio" id="invoice" name="sendMailType" value="invoice"/>
				<label for="invoice"><spring:message code='Cache.ACC_lbl_invoiceUser' /></label>
				<input type="radio" id="manager" name="sendMailType" value="manager"/>
				<label for="manager"><spring:message code='Cache.ACC_lbl_manager' /></label>
				<input type="radio" id="tossuser" name="sendMailType" value="tossuser"/>
				<label for="tossuser"><spring:message code='Cache.ACC_lbl_tossUserName' /></label>
            </div>				
			</div>
			<div id="searchbar1" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 회사 -->
								<spring:message code='Cache.ACC_lbl_company'/>
							</span>
							<span id="companyCode" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 구분 -->
								<spring:message code='Cache.ACC_lbl_division'/>
							</span>
							<span id="taxMailSearchType" class="selectType02" style ="margin-right:14px;width:110px">
							</span>
							<input onkeydown="SendDelayTax.onenter()" id="searchStr" type="text" placeholder="" style ="width:200px">
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 작성일 -->
								<spring:message code='Cache.ACC_lbl_writeDate'/> 
							</span>
							<div id="writeDate1" class="dateSel type02" style="padding-right: 7px;">
							</div>
						</div>						
						<a class="btnTypeDefault  btnSearchBlue" onclick="SendDelayTax.searchList();"><spring:message code='Cache.ACC_btn_search'/></a><!-- 검색 -->
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="SendDelayTax.searchList();">
					</span>
					<button class="btnRefresh" type="button" onclick="SendDelayTax.searchList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

if (!window.SendDelayTax) {
	window.SendDelayTax = {};
}

(function(window) {
	var SendDelayTax = {
			params	:{
				gridPanel	: new coviGrid(),
				headerData	: []
			},

			pageInit : function(inputParam) {
				var me = this;
				setPropertySearchType('TaxInvoice','searchProperty');
				setPropertySyncType('TaxInvoice','syncPropertyTax');
				setPropertySyncType('CashBill','syncPropertyCash');
				setHeaderTitle('headerTitle');
				me.pageDatepicker();
				me.setSelectCombo();
				//me.setHeaderData();

				var appstdt = null;
				var appeddt = null;
				if(inputParam != null){
					if(inputParam.callType=="Portal"){
						/* var nowDate = new Date();
						var firstDate = new Date(nowDate.getFullYear(), nowDate.getMonth(), 1);
						var lastDate = new Date(nowDate.getFullYear(), nowDate.getMonth()+1, 0);
						accountCtrl.getInfo("writeDateS").val(firstDate.format("yyyy.MM.dd"));
						accountCtrl.getInfo("writeDateE").val(lastDate.format("yyyy.MM.dd")); */
					}
				}
				
				me.searchList('Y');
			},

			pageView : function(inputParam) {
				var me = this;
				
				me.setHeaderData();
				me.refreshCombo();
				
				var gridAreaID		= "gridArea";
				var gridPanel		= me.params.gridPanel;
				var pageNoInfo		= me.params.gridPanel.page.pageNo;
				var pageSizeInfo	= accountCtrl.getComboInfo("listCount").val();
				
				var gridParams		= {	"gridAreaID"	: gridAreaID
									,	"gridPanel"		: gridPanel
									,	"pageNoInfo"	: pageNoInfo
									,	"pageSizeInfo"	: pageSizeInfo
									,	"fitToWidth"	: false
				}
				
				accountCtrl.refreshGrid(gridParams);
				me.searchList();
			},


			
			pageDatepicker : function(){
				makeDatepicker('writeDate1','writeDateS','writeDateE','','','');						
			},
			
			setSelectCombo : function(){
				var AXSelectMultiArr	= [	
						{'codeGroup':'listCountNum',		'target':'listCount',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
					,	{'codeGroup':'CompanyCode',			'target':'companyCode',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"} //전체
					,	{'codeGroup':'TaxMailSearchType',	'target':'taxMailSearchType',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"} //전체
					]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
			},

			refreshCombo : function(){
				accountCtrl.refreshAXSelect("listCount");
				accountCtrl.refreshAXSelect("companyCode");
				accountCtrl.refreshAXSelect("taxMailSearchType");
			},

			setHeaderData : function() {
				var me = this;
				
				var searchProperty	= accountCtrl.getInfo("searchProperty").val();
				
				me.params.headerData = [	{	key:'chk',					label:'chk',			width:'20', 	align:'center',
												formatter:'checkbox'
											},
											{	key:'InvoicerCorpName',		label:"<spring:message code='Cache.ACC_lbl_invoiceCorpName' />",	width:'250',	align:'left'},		//공급자상호        
											{	key:'InvoicerCorpNum',		label:"<spring:message code='Cache.ACC_lbl_invoiceCorpNum' />",		width:'100',	align:'center'},	//공급자 사업자 번호
											{	key:'NTSConfirmNum',		label:'승인번호',			width:'100',		align:'center',
												formatter:function () {
													var rtStr =	""
																+	"<a onclick='SendDelayTax.taxInvoicePop("+ this.item.TaxInvoiceID +"); return false;'>"
																+		"<font color='blue'>"
																+			this.item.NTSConfirmNum
																+		"</font>"
																+	"</a>";
													return rtStr;
												}
											},
											{	key:'WriteDate',			label:'작성일',			width:'100',		align:'center'},
											{	key:'InvoiceInfo',		    label:"<spring:message code='Cache.ACC_lbl_invoiceUser' />",		width:'250',	align:'left'},		//공급받는자Email   
											{	key:'ManagerInfo',			label:"<spring:message code='Cache.ACC_lbl_manager' />",			width:'250',	align:'left',
												formatter:function () {
													var managerStr = this.item.ManagerInfo;
													var managerStrSp = managerStr.split(",");
													var rtStr =	""
													for (var i = 0; i < managerStrSp.length; i++) {
														if(i == 0){
															rtStr += managerStrSp[i];	
														}else{
															rtStr += "<br>" + managerStrSp[i];	
														}
													}
													return rtStr;
												}	
											},	//담당자
											
											{	key:'TossUserInfo',			label:"<spring:message code='Cache.ACC_lbl_tossUserName' />",		width:'250',	align:'left'}		//전달받은 사용자
										]
				
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},

			searchList : function(YN){
				var me = this;
				
				me.setHeaderData();
				
				var companyCode			= accountCtrl.getComboInfo("companyCode").val();
				var writeDateS			= accountCtrl.getInfo("writeDateS").val();
				var writeDateE			= accountCtrl.getInfo("writeDateE").val();
				var searchType			= accountCtrl.getComboInfo("taxMailSearchType").val();
				var searchStr			= accountCtrl.getInfo("searchStr").val();
				var searchProperty		= accountCtrl.getInfo("searchProperty").val();
				
				var gridAreaID		= "gridArea";
				var gridPanel		= me.params.gridPanel;
				var gridHeader		= me.params.headerData;
				var ajaxUrl			= "/account/sendDelayTax/getSendDelayTaxList.do";
				var ajaxPars		= {	"searchProperty"	: searchProperty,
										"companyCode"		: companyCode,
						 				"writeDateS"		: writeDateS,
						 				"writeDateE"		: writeDateE,
						 				"searchType"		: searchType,
						 				"searchStr"			: searchStr
				};
				
				var pageSizeInfo	= accountCtrl.getComboInfo("listCount").val();
				var pageNoInfo		= accountCtrl.getGridViewPageNum(YN,gridPanel,pageSizeInfo);
				
				var gridParams = {	"gridAreaID"	: gridAreaID
								,	"gridPanel"		: gridPanel
								,	"gridHeader"	: gridHeader
								,	"ajaxUrl"		: ajaxUrl
								,	"ajaxPars"		: ajaxPars
								,	"pageNoInfo"	: pageNoInfo
								,	"pageSizeInfo"	: pageSizeInfo
								,	"popupYN"		: "N"
								,	"fitToWidth"	: false
				}
				
				accountCtrl.setViewPageBindGrid(gridParams);
			},
			
			taxInvoicePop : function(key){
				var popupName	=	"TaxInvoicePopup";
				var popupID		=	"taxInvoicePopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_taxInvoiceCash' />"; //전자세금계산서
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"taxInvoiceID="	+	key;
				Common.open("",popupID,popupTit,url,"980px", "720px","iframe",true,null,null,true);
			},
			
			onenter : function(){
				var me = this;
				if(event.keyCode=="13"){
					me.searchList();
				}
			},
			
			refresh : function(){
				accountCtrl.pageRefresh();
			},
			
			sendDelay: function() {//미상신 알림메일
				var me = this;
				var sendMailType = $("[name=sendMailType]:checked").val();
				var chkList = me.params.gridPanel.getCheckedList(0);
				var params	= new Object();
				
				if(chkList.length == 0){
					Common.Warning("<spring:message code='Cache.ACC_msg_chkData' />"); //내역을 먼저 선택해주세요.
				}else{  
					if(sendMailType != "" && sendMailType != undefined ){	
						params.chkList	= chkList;
						Common.Confirm("<spring:message code='Cache.msg_apv_ConfirmSend' /> ", "Confirmation Dialog", function (confirmResult) {
							if (confirmResult) {
								$.ajax({
									url			: "/account/doManualDelayAlam.do",
									type		: "POST",
									data		:{"sendMailType": sendMailType, companyCode: accountCtrl.getComboInfo("companyCode").val(), "dataList" : JSON.stringify(params)},
									success:function (data) {
										if(data.status == "SUCCESS"){
											Common.Inform("<spring:message code='Cache.msg_sms_send_success' />"+"["+data.data.sendCnt+"]");	//전송을 완료했습니다
										}else{
											Common.Error("<spring:message code='Cache.CPMail_sendFalse_msg' />"); // 전송에 실패 하였습니다.
										}
									},
									error:function (error){
										Common.Error("<spring:message code='Cache.CPMail_sendFalse_msg' />"); // 전송에 실패 하였습니다.
									}
								});
							}
					    });	
					}else{
						Common.Warning("메일전송 대상을 선택해주세요.");
						return;
					}
			    }
			}
		}
	window.SendDelayTax = SendDelayTax;
})(window);

	
	
</script>