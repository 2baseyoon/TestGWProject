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
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 새로고침 -->
					<a class="btnTypeDefault"			onclick="TaxInvoiceUser.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"	onclick="TaxInvoiceUser.excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 상계처리 -->
					<a class="btnTypeDefault"			onclick="TaxInvoiceUser.updateIsOffset('Y')"><spring:message code="Cache.ACC_lbl_offsetY"/></a>
					<!-- 상계처리 -->
					<a class="btnTypeDefault"			onclick="TaxInvoiceUser.updateIsOffset('N')"><spring:message code="Cache.ACC_lbl_offsetN"/></a>
					<!-- 전달 -->
					<a class="btnTypeDefault"			onclick="TaxInvoiceUser.tossUserPopup()"><spring:message code="Cache.ACC_lbl_tossUser"/></a>
				</div>
				<!-- 상단 버튼 끝 -->				
			</div>
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 회사 -->
								<spring:message code="Cache.ACC_lbl_company"/>
							</span>
							<span id="companyCode" class="selectType02" onchange="TaxInvoiceUser.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 구분 -->
								<spring:message code="Cache.ACC_lbl_division"/>
							</span>
							<span id="tiSearchType" class="selectType02" style ="margin-right:14px;width:110px">
							</span>
							<input id="searchStr" type="text" placeholder=""  style ="width:200px">
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 정산상태 -->
								<spring:message code="Cache.ACC_lbl_taxInvoice"/>
							</span>
							<span id="taxInvoiceActive" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 작성일 -->
								<spring:message code="Cache.ACC_lbl_writeDate"/>
							</span>
							<div id="writeDate" class="dateSel type02">
							</div>
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="TaxInvoiceUser.searchList();"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
						<span id="listCount" class="selectType02 listCount" onchange="TaxInvoiceUser.searchList();">
					</span>
					<button class="btnRefresh" type="button" onclick="TaxInvoiceUser.searchList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

if (!window.TaxInvoiceUser) {
	window.TaxInvoiceUser = {};
}

(function(window) {
	var TaxInvoiceUser = {
			params	:{
				gridPanel	: new coviGrid(),
				headerData	: []
			},

			pageInit : function(inputParam) {
				var me = this;
				setHeaderTitle('headerTitle');
				me.pageDatepicker();
				me.setSelectCombo();
				me.setHeaderData();

				var appstdt = null;
				var appeddt = null;
				
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
				makeDatepicker('writeDate','writeDateS','writeDateE','','','');
			},
			
			setSelectCombo : function(pCompanyCode){
				accountCtrl.getInfo("listCount").children().remove();
				accountCtrl.getInfo("tiSearchType").children().remove();
				accountCtrl.getInfo("taxInvoiceActive").children().remove();

				accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "TaxInvoiceUser.searchList();");
				accountCtrl.getInfo("tiSearchType").addClass("selectType02").css("margin-right", "14px").css("width", "110px");
				accountCtrl.getInfo("taxInvoiceActive").addClass("selectType02");
				
				var AXSelectMultiArr	= [	
						{'codeGroup':'listCountNum',		'target':'listCount',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
					,	{'codeGroup':'TiSearchType',		'target':'tiSearchType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"} //전체
					,	{'codeGroup':'TaxInvoiceActive',	'target':'taxInvoiceActive',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
					,	{'codeGroup':'CompanyCode',			'target':'companyCode',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
					]
				
				if(pCompanyCode != undefined) {
					AXSelectMultiArr.pop(); //CompanyCode 제외
				}
				
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
			},

			refreshCombo : function(){
				accountCtrl.refreshAXSelect("listCount");
				accountCtrl.refreshAXSelect("companyCode");
				accountCtrl.refreshAXSelect("tiSearchType");
				accountCtrl.refreshAXSelect("taxInvoiceActive");
			},
			
			changeCompanyCode : function() {
				var me = this;
				me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
			},

			setHeaderData : function() {
				var me = this;
				me.params.headerData = [	{	key:'chk',					label:'chk',										width:'20', 	align:'center', 
												formatter:'checkbox'                                                                                            
											},                 
											{ 	key:'CompanyName',			label:"<spring:message code='Cache.ACC_lbl_company' />",			width:'100',		align:'center'},	//회사
											{	key:'WriteDate',			label:"<spring:message code='Cache.ACC_lbl_writeDate' />",			width:'100',		align:'center'}, 	//작성일         
											{	key:'NTSConfirmNum',		label:"<spring:message code='Cache.ACC_lbl_confirmNum' />",			width:'200',		align:'center',  	//승인번호        
												formatter:function () {                                                                                                        
													var rtStr =	""                                                                                                             
																+	"<a onclick='TaxInvoiceUser.taxInvoicePop("+ this.item.TaxInvoiceID +"); return false;'>"                  
																+		"<font color='blue'>"                                                                                  
																+			this.item.NTSConfirmNum                                                                            
																+		"</font>"                                                                                              
																+	"</a>";                                                                                                    
													return rtStr;                                                                                                              
												}                                                                                                                              
											},                                                                                                                                 
											{	key:'InvoicerCorpName',		label:"<spring:message code='Cache.ACC_lbl_invoiceCorpName' />",	width:'200',	align:'center'}, 	//공급자 상호      
											{	key:'InvoicerCorpNum',		label:"<spring:message code='Cache.ACC_lbl_invoiceCorpNum' />",		width:'150',	align:'center'}, 	//공급자 사업자 번호  
											{	key:'InvoicerContactName',	label:"<spring:message code='Cache.ACC_lbl_contactName' />",		width:'100',	align:'center'}, 	//담당자명
											{	key:'ItemName',				label:"<spring:message code='Cache.ACC_lbl_itemName' />",			width:'200',	align:'center'},	//품명        
											{	key:'TotalAmount',			label:"<spring:message code='Cache.ACC_lbl_totalAmount' />",		width:'100',	align:'right'},  	//합계금액        
											{	key:'SupplyCostTotal',		label:"<spring:message code='Cache.ACC_lbl_supplyCost' />",			width:'100',	align:'right'},  	//공급액         
											{	key:'TaxTotal',				label:"<spring:message code='Cache.ACC_lbl_taxType' />",			width:'100',	align:'right'},  	//부가세         
											{	key:'InvoiceeEmail1',		label:"<spring:message code='Cache.ACC_lbl_invoiceEmail' />",		width:'200',	align:'center',
												formatter:function () {
													var mailStr = this.item.InvoiceeEmail1;
													if(this.item.InvoiceEmail2) mailStr += " / " + this.item.InvoiceEmail2;
													return mailStr;
												}
											}, 	//공급받는자Email  
											{	key:'TaxInvoiceActive',		label:"<spring:message code='Cache.ACC_lbl_taxInvoice' />",			width:'80',		align:'center'}, 	//정산상태        
											{	key:'Remark1',				label:'REMARK',														width:'100',	align:'center'},               
											{	key:'ModifyName',			label:"<spring:message code='Cache.ACC_lbl_modifyName' />",			width:'80',		align:'center', 	//수정/일반  
												formatter:function () {
													var rtStr =	""
																+	"<span title='" + (this.item.ModifyName == null ? "" : this.item.ModifyName) + "'>"
																+		(this.item.InvoiceType == null ? "" : this.item.InvoiceType) 
																+	"</span>";
													return rtStr;
												}
											},    
											{	key:'OrgNTSConfirmNum',		label:"<spring:message code='Cache.ACC_lbl_orgConfirmNum' />",		width:'200',	align:'center'}, 	//원승인번호       
											{	key:'TossUserName',			label:"<spring:message code='Cache.ACC_lbl_tossUserName' />",		width:'150',	align:'center'}  	//전달받은 사용자    
										]
				me.params.excelHeaderData = [
											{	key:'InvoiceEmail2',		label:"<spring:message code='Cache.ACC_lbl_invoiceEmail2' />",		width:'200',	align:'left'}		//공급받는자 E-mail(부)
										]
				me.params.excelHeaderData = [].concat(me.params.headerData, me.params.excelHeaderData);
				
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},

			searchList : function(YN){
				var me = this;
				
				me.setHeaderData();
				
				var companyCode			= accountCtrl.getComboInfo("companyCode").val();
				var taxInvoiceActive	= accountCtrl.getComboInfo("taxInvoiceActive").val();
				var writeDateS			= accountCtrl.getInfo("writeDateS").val();
				var writeDateE			= accountCtrl.getInfo("writeDateE").val();
				var searchType			= accountCtrl.getComboInfo("tiSearchType").val();
				var searchStr			= accountCtrl.getInfo("searchStr").val();
				
				var gridAreaID		= "gridArea";
				var gridPanel		= me.params.gridPanel;
				var gridHeader		= me.params.headerData;
				var ajaxUrl			= "/account/taxInvoice/getTaxInvoiceUserList.do";
				var ajaxPars		= {	"companyCode"		: companyCode,
						 				"taxInvoiceActive"	: taxInvoiceActive,
						 				"writeDateS"		: writeDateS,
						 				"writeDateE"		: writeDateE,
						 				"searchType"		:searchType,
						 				"searchStr"			:searchStr
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
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_taxInvoiceCash' />";	//전자세금계산서
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"taxInvoiceID="	+	key;
				Common.open("",popupID,popupTit,url,"980px", "720px","iframe",true,null,null,true);
			},
			
			excelDownload : function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
		       		if(result){
					var headerName			= accountCommon.getHeaderNameForExcel(me.params.excelHeaderData);
					var headerKey			= accountCommon.getHeaderKeyForExcel(me.params.excelHeaderData);
					var companyCode			= accountCtrl.getComboInfo("companyCode").val();
					var taxInvoiceActive	= accountCtrl.getComboInfo("taxInvoiceActive").val();
					var writeDateS			= accountCtrl.getInfo("writeDateS").val();
					var writeDateE			= accountCtrl.getInfo("writeDateE").val();
					var searchType			= accountCtrl.getComboInfo("tiSearchType").val();
					var searchStr			= accountCtrl.getInfo("searchStr").val();
					var title 			= accountCtrl.getInfo("headerTitle").text();
					
					var	locationStr		= "/account/taxInvoice/taxInvoiceExcelDownloadUser.do?"
										//+ "headerName="			+ encodeURI(headerName)
										+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
										+ "&headerKey="			+ encodeURI(headerKey)
										+ "&companyCode="		+ encodeURI(companyCode)
										+ "&taxInvoiceActive="	+ encodeURI(taxInvoiceActive)
										+ "&writeDateS="		+ encodeURI(writeDateS)
										+ "&writeDateE="		+ encodeURI(writeDateE)
										+ "&searchType="		+ encodeURI(searchType)
										+ "&searchStr="			+ encodeURI(searchStr)
										//+ "&title="				+ encodeURI(accountCtrl.getInfo("headerTitle").text());
										+ "&title="			+ encodeURIComponent(encodeURIComponent(title));
					location.href = locationStr;
				}
				});
			},
			
			updateIsOffset : function(key){
				var me = this;
				var params	= new Object();
				var chkList = me.params.gridPanel.getCheckedList(0);
				var msg		= "";
				
				for(var i = 0; i < chkList.length; i++) {
					if(chkList[i].TaxInvoiceActive == "상계" && key == 'Y') {
						Common.Warning("<spring:message code='Cache.ACC_lbl_confirmNum' />" + "[" + chkList[i].NTSConfirmNum + "] / " 
								+ "<spring:message code='Cache.ACC_lbl_invoiceCorpName' />" + "[" + chkList[i].InvoicerCorpName + "]" + " : " 
								+ "<spring:message code='Cache.ACC_lbl_CannotAskOffSetY' />"); // 이미 상계처리된 내역입니다.
						return;
					} else if(chkList[i].TaxInvoiceActive != "상계" && key == 'N') {
						Common.Warning("<spring:message code='Cache.ACC_lbl_confirmNum' />" + "[" + chkList[i].NTSConfirmNum + "] / " 
								+ "<spring:message code='Cache.ACC_lbl_invoiceCorpName' />" + "[" + chkList[i].InvoicerCorpName + "]" + " : " 
								+ "<spring:message code='Cache.ACC_lbl_CannotAskOffSetN' />"); // 상계취소처리는 상계처리된 내역만 가능합니다. 
						return;
					}					
				}
				
				if(key == 'Y'){
					msg = "<spring:message code='Cache.ACC_lbl_askOffsetY' />";	//상계처리하시겠습니까?
				}else{
					msg =  "<spring:message code='Cache.ACC_lbl_askOffsetN' />";	//상계취소처리하시겠습니까?
				}
				
				if(chkList.length > 0){
					
					params.key		= key;
					params.chkList	= chkList;
					
					Common.Confirm(msg, "<spring:message code='Cache.ACC_lbl_offset' />", function(result){	//상계
			       		if(result){
							$.ajax({
								url			: "/account/taxInvoice/saveIsOffset.do",
								type		: "POST",
								data		: JSON.stringify(params),
								dataType	: "json",
								contentType	: "application/json",
								
								success:function (data) {
									if(data.status == "SUCCESS"){
										TaxInvoiceUser.searchList();
									}else{
										Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
									}
								},
								error:function (error){
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // error.message
								}
							});
			       		}
					});
					
				}else{
					Common.Inform("<spring:message code='Cache.ACC_msg_chkData' />");	//내역을 먼저 선택해주세요.
				}
			},
			
			tossUserPopup : function(){
				var me = this;
				var chkList = me.params.gridPanel.getCheckedList(0);
				if(chkList.length == 0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");	//선택된 항목이 없습니다.
					return;
				}
				
				var popupName	= "TossUserPopup";
				var popupID		= "tossUserPopup";
				var openerID	= "TaxInvoiceUser";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_tossUser' />";	//수신내역전달
				var popupYN		= "N";
				var callBack	= "tossUserPopup_CallBack";
				var url			= "/account/accountCommon/accountCommonPopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "popupName="		+ popupName	+ "&"
								+ "callBackFunc="	+ callBack;
				
				Common.open(	"",popupID,popupTit,url,"520px", "230px","iframe",true,null,null,true);
			},
			
			tossUserPopup_CallBack : function(info){
				var me = this;
				var params	= new Object();
				var chkList	= me.params.gridPanel.getCheckedList(0);
				
				if(chkList.length == 0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noSelectCard' />");	//선택된 카드내역정보가 없습니다.
					return;
				}
				
				params.chkList		= chkList;
				params.tossUserCode	= info.tossSenderUserCode;	//전달받은사용자코드
				params.tossUserName	= info.tossSenderUserName;	//전달받은사용자이름
				params.tossComment	= info.tossComment;			//전달시코멘트
				
				$.ajax({
					url			: "/account/taxInvoice/saveTaxInvoiceTossUser.do",
					type		: "POST",
					data		: JSON.stringify(params),
					dataType	: "json",
					contentType	: "application/json",
					
					success:function (data) {
						Common.close('tossUserPopup');
						
						if(data.status == "SUCCESS"){
							Common.Inform(data.tossUserName + "<spring:message code='Cache.ACC_msg_sendCompleteTaxInvoice' />"); //*** 사용자에게 수신내역을 전달했습니다.
							TaxInvoiceUser.searchList();
						}else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가발생하였습니다. 관리자에게 문의바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
					}
				});
			},
			
			refresh : function(){
				accountCtrl.pageRefresh();
			}
	}
	window.TaxInvoiceUser = TaxInvoiceUser;
})(window);
	
</script>