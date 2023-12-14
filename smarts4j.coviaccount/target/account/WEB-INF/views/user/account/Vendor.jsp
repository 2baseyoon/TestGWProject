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
	<input id="syncProperty" type="hidden" />
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<!-- 상단 버튼 시작 -->
			<div class="eaccountingTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					<a class="btnTypeDefault  btnTypeBg " 	onclick="Vendor.callAddPopup();"><spring:message code="Cache.ACC_btn_add"/></a>
					<a class="btnTypeDefault" 				onclick="Vendor.deleteList();"><spring:message code="Cache.ACC_btn_delete"/></a>
					<a class="btnTypeDefault"				onclick="Vendor.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>		
					<a class="btnTypeDefault btnExcel" 		onclick="Vendor.saveExcel();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- <a class="btnTypeDefault btnExcel" 		onclick="Vendor.template();"><spring:message code="Cache.btn_TemplateDownload"/></a> -->
					<a class="btnTypeDefault btnExcel_upload" onclick="Vendor.callUploadPopup();"><spring:message code="Cache.ACC_lbl_excelUpload"/></a>
					<a class="btnTypeDefault"					onclick="Vendor.VendorSync();" id="btnSync"><spring:message code="Cache.ACC_btn_sync"/></a> <!-- 동기화 -->
				</div>
			</div>
			<!-- 상단 버튼 끝 -->
			<!-- ===================== -->
			
			<div class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:670px;"><!-- 항목 넓이를 인라인으로 조정 -->
						<div class="inPerTitbox">
							<!-- 회사 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_company"/></span>
							<span id="vendor_inputCompanyCode" class="selectType02" onchange="Vendor.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">	
							<!-- 업종 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorSector"/></span>
							<input id="vendor_inputSector" type="text"
								onkeydown="Vendor.onenter()">							
						</div>
					</div>
					<div style="width:670px;">
						<div class="inPerTitbox">
							<!-- 사업자번호 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_BusinessNumber"/></span>
							<input id="vendor_inputVendorNo" type="text"
								onkeydown="Vendor.onenter()">
						</div>
						<div class="inPerTitbox">
							<!-- 업태 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_business"/></span>
							<input id="vendor_inputIndustry" type="text"
								onkeydown="Vendor.onenter()">
						</div>
					</div>							
					<div style="width:670px;">
						<div class="inPerTitbox">
							<!-- 사업자번호 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorName"/></span>
							<input id="vendor_inputVendorName" type="text"
								onkeydown="Vendor.onenter()" style="width: 408px;">
						</div>
						<a class="btnTypeDefault btnSearchBlue" onclick="Vendor.searchVendorList();"><spring:message code="Cache.ACC_btn_search"/></a><!-- 버튼위치를 인라인으로 조정 -->
					</div>						
				</div>
			</div>
			<!-- ===================== -->
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight ">	
					<span class="selectType02 listCount" id="listCount" onchange="Vendor.searchVendorList();">
					</span>
					<button class="btnRefresh" type="button" onclick="Vendor.searchVendorList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
			
		</div>
		<!-- 컨텐츠 끝 -->
	</div>

<script>
		
	if (!window.Vendor) {
		window.Vendor = {};
	}
	
	(function(window) {
		var Vendor = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},

				pageInit : function() {
					var me = this;
					setPropertySyncType('Vendor','syncProperty');
					setHeaderTitle('headerTitle');
					me.setPageViewController();
					me.setSelectCombo();
					me.setHeaderData();
					me.searchVendorList('Y');
				},

				pageView : function() {
					var me = this;
					
					me.setHeaderData();
					me.refreshCombo();
					
					me.searchVendorList();
				},
				
				setPageViewController :function(){
					var syncProperty	= accountCtrl.getInfo("syncProperty").val();
										
					if(syncProperty == "") {
						accountCtrl.getInfo("btnSync").css("display", "none");
					}
				},

				setSelectCombo : function(pCompanyCode){
					accountCtrl.getInfo("listCount").children().remove();
					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "Vendor.searchVendorList();");
					
					var AXSelectMultiArr	= [	
                 		{'codeGroup':'listCountNum',	'target':'listCount',					'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
                 	,	{'codeGroup':'CompanyCode',		'target':'vendor_inputCompanyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
                 	]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				},

				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("vendor_inputCompanyCode");
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("vendor_inputCompanyCode").val());
				},

				setHeaderData : function() {
					var me = this;
					me.params.headerData = [
						          			{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
						        			{ key:'CompanyName',		label:"<spring:message code='Cache.ACC_lbl_company' />",			width:'70', align:'center'},	//회사
						        			{ key:'VendorTypeName',		label:"<spring:message code='Cache.ACC_lbl_vendorType' />",			width:'70', align:'center'},	//거래처 구분
						        		/* 	{ key:'VendorNo',			label:"<spring:message code='Cache.ACC_lbl_BusinessNumber' />",		width:'70', align:'center'},	//사업자번호 */
						        			{ key:'BusinessNumber',		label:"<spring:message code='Cache.ACC_lbl_BusinessNumber' />" + "(" + "<spring:message code='Cache.ACC_lbl_registrationNumber' />" + ")",		width:'100', align:'center'},	//사업자번호
						        			{ key:'VendorName',			label:"<spring:message code='Cache.ACC_lbl_vendorName' />",			width:'110', align:'center',	//거래처명
						        				formatter:function () {
								            		 return "<a onclick='Vendor.onVdClick(" + this.item.VendorID+",\""+this.item.VendorType+"\"); return false;'><font color='blue'><u>"+this.item.VendorName+"</u></font></a>";
								            	}																							
						        			
						        			},
						        			{ key:'Sector',				label:"<spring:message code='Cache.ACC_lbl_vendorSector' />",		width:'110', align:'center'},	//업종
						        			{ key:'Industry',			label:"<spring:message code='Cache.ACC_lbl_business' />",			width:'110', align:'center'},	//업태
						        			{ key:'VendorStatusName',	label:"<spring:message code='Cache.ACC_lbl_status' />",				width:'110', align:'center'},	//상태
						        			{ key:'RegistDate',			label:"<spring:message code='Cache.ACC_lbl_registDate' />"+Common.getSession("UR_TimeZoneDisplay"),			width:'110', align:'center',
						        				formatter:function(){
						        					return CFN_TransLocalTime(this.item.RegistDate,_ServerDateSimpleFormat);
						        				}, dataType:'DateTime'
						        			}]	//등록일자
					
					me.params.headerDataExcel = [
					    					{ key:'CompanyCode',		label:"<spring:message code='Cache.ACC_lbl_companyCode' />",		width:'70', align:'center'},
						        			{ key:'CompanyName',		label:"<spring:message code='Cache.ACC_lbl_companyName' />",		width:'70', align:'center'},
						        			{ key:'VendorTypeName',		label:"<spring:message code='Cache.ACC_lbl_vendorType' />",			width:'70', align:'center'},
						        			/* { key:'VendorNo',		label:"<spring:message code='Cache.ACC_lbl_BusinessNumber' />",		width:'70', align:'center'}, */
						        			{ key:'BusinessNumber',		label:"<spring:message code='Cache.ACC_lbl_BusinessNumber' />" + "(" + "<spring:message code='Cache.ACC_lbl_registrationNumber' />" + ")",		width:'70', align:'center'},
						        			{ key:'CorporateNo',		label:"<spring:message code='Cache.ACC_lbl_CorporateNumber' />",	width:'70', align:'center'},
						        			{ key:'VendorName',	label:"<spring:message code='Cache.ACC_lbl_vendorName' />",					width:'110', align:'center'},
						        			{ key:'CEOName',	label:"<spring:message code='Cache.ACC_lbl_storeRepresentative' />",		width:'110', align:'center'},
						        			{ key:'Sector',	label:"<spring:message code='Cache.ACC_lbl_vendorSector' />",					width:'110', align:'center'},
						        			{ key:'Industry',	label:"<spring:message code='Cache.ACC_lbl_business' />",					width:'110', align:'center'},
						        			{ key:'Address',	label:"<spring:message code='Cache.ACC_lbl_address' />",					width:'110', align:'center'},
						        			{ key:'BankCode',	label:"<spring:message code='Cache.ACC_lbl_bankCode' />",					width:'110', align:'center'},
						        			{ key:'BankName',	label:"<spring:message code='Cache.ACC_lbl_BankName' />",					width:'110', align:'center'},
						        			{ key:'BankAccountNo',	label:"<spring:message code='Cache.ACC_lbl_BankAccount' />",			width:'110', align:'center'},
						        			{ key:'BankAccountName',	label:"<spring:message code='Cache.ACC_lbl_BankAccountHolder' />",	width:'110', align:'center'},
						        			{ key:'PaymentTypeName',	label:"<spring:message code='Cache.ACC_lbl_PayType' />",			width:'110', align:'center'},
						        			{ key:'PaymentMethodName',	label:"<spring:message code='Cache.ACC_lbl_pay' />",				width:'110', align:'center'},
						        			{ key:'VendorStatusName',	label:"<spring:message code='Cache.ACC_lbl_status' />",				width:'110', align:'center'},
						        			{ key:'IncomTaxName',	label:"<spring:message code='Cache.ACC_lbl_incomTax' />",				width:'110', align:'center'},
						        			{ key:'LocalTaxName',	label:"<spring:message code='Cache.ACC_lbl_localTax' />",				width:'110', align:'center'},
						        			{ key:'RegistDate',	label:"<spring:message code='Cache.ACC_lbl_registDate' />"+Common.getSession("UR_TimeZoneDisplay"), dataType:'DateTime',		width:'110', align:'center'}]
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},

				searchVendorList : function(YN){
					var me = this;
					
					me.setHeaderData();
					var searchCompanyCode	= accountCtrl.getComboInfo("vendor_inputCompanyCode").val();
					var searchSector		= accountCtrl.getInfo("vendor_inputSector").val();
					var searchVendorNo		= accountCtrl.getInfo("vendor_inputVendorNo").val();
					var searchIndustry		= accountCtrl.getInfo("vendor_inputIndustry").val();
					var searchVendorName	= accountCtrl.getInfo("vendor_inputVendorName").val();
					var pageSizeInfo		= accountCtrl.getComboInfo("listCount").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/baseInfo/searchVendorList.do";
					var ajaxPars		= {	"searchCompanyCode" : searchCompanyCode,
											"searchSector"		: searchSector,
											"searchVendorNo"	: searchVendorNo,
											"searchIndustry"	: searchIndustry,
											"searchVendorName"	: searchVendorName,
											"pageSize"			: pageSizeInfo
					};
					
					var pageNoInfo		= accountCtrl.getGridViewPageNum(YN,gridPanel,pageSizeInfo);
					
					var gridParams = {	"gridAreaID"	: gridAreaID
									,	"gridPanel"		: gridPanel
									,	"gridHeader"	: gridHeader
									,	"ajaxUrl"		: ajaxUrl
									,	"ajaxPars"		: ajaxPars
									,	"pageNoInfo"	: pageNoInfo
									,	"pageSizeInfo"	: pageSizeInfo
									,	"popupYN"		: "N"
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
				},
				
				deleteList : function(){
					var me = this;
					var grid = me.params.gridPanel;
					var deleteobj = grid.getCheckedList(0);

					var vdList = "";
					for(var i = 0; i < deleteobj.length; i++)	 {
						var item = deleteobj[i];
						
						vdList += item.VendorID;
						if(i != deleteobj.length - 1){
							vdList += ",";
						}
					}
					
					if (deleteobj.length == 0) {
						Common.Inform("<spring:message code='Cache.ACC_msg_noDataDelete' />");	//삭제할 항목이 없습니다.
						return;
					}else {
				        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//선택한 항목을 삭제하시겠습니까?
				       		if(result){
								Vendor.callDeleteVendorList(vdList)
				       		}
				        });
					}
				},
				
				callDeleteVendorList : function(vdList){

					$.ajax({
						type:"POST",
							url:"/account/baseInfo/deleteVendorList.do",
						data:{
							"vdList" : vdList,
						},
						success:function (data) {
							if(data.result == "ok")
							{
								Common.Inform("<spring:message code='Cache.ACC_msg_delComp'/>");	//성공적으로 삭제를 하였습니다.
								Vendor.searchVendorList();
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의바랍니다.
						}
					});
				},

				saveExcel : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
								var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerDataExcel);
								var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerDataExcel);
								var searchCompanyCode	= accountCtrl.getComboInfo("vendor_inputCompanyCode").val();
								var searchSector		= accountCtrl.getInfo("vendor_inputSector").val();
								var searchVendorNo		= accountCtrl.getInfo("vendor_inputVendorNo").val();
								var searchIndustry		= accountCtrl.getInfo("vendor_inputIndustry").val();
								var searchVendorName	= accountCtrl.getInfo("vendor_inputVendorName").val();
								var searchType   = me.searchedType;
								var headerType		= accountCommon.getHeaderTypeForExcel(me.params.headerDataExcel);
								var title 			= accountCtrl.getInfo("headerTitle").text();
			
								location.href = "/account/baseInfo/excelDownloadVenderList.do?"
										//+ "headerName="	+encodeURI(headerName)
										+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
										+ "&headerKey="	+ encodeURIComponent(headerKey)
										+ "&searchCompanyCode=" + encodeURI(searchCompanyCode)
										+ "&searchSector=" + encodeURI(searchSector)
										+ "&searchVendorNo=" + encodeURI(searchVendorNo)
										+ "&searchIndustry=" + encodeURI(searchIndustry)
										+ "&searchVendorName=" + encodeURI(searchVendorName)
										+ "&searchType="+encodeURI(searchType)
										//+ "&title="+encodeURI(accountCtrl.getInfo("headerTitle").text())
										+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
										+ "&headerType="+encodeURI(headerType);
			       		}
					});
				},

				template : function(){

					Common.Confirm("<spring:message code='Cache.ACC_msg_downloadTemplateFiles'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
			       			location.href = '/account/baseInfo/excelTemplateDownloadVendorList.do?';
			       		}
					});
				},
				
				callAddPopup : function(){
					var isNew		= "Y";
					var popupID		= "vendorPopup";
					var openerID	= "Vendor";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_vendorManage'/>";	//거래처 관리
					var popupYN		= "N";
					var changeSize	= "ChangePopupSize";
					var callBack	= "vendorPopup_CallBack";
					var popupUrl	= "/account/baseInfo/callVendorPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "changeSizeFunc="	+ changeSize+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "isNew="			+ isNew;
					
					Common.open("", popupID, popupTit, popupUrl, "900px", "650px", "iframe", true, null, null, true);
				},

				onVdClick : function(VendorID, VendorType){
					var isNew		= "N";
					var popupID		= "vendorPopup";
					var openerID	= "Vendor";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_vendorManage'/>";	//거래처 관리
					var popupYN		= "N";
					var changeSize	= "ChangePopupSize";
					var callBack	= "vendorPopup_CallBack";
					var popupUrl	= "/account/baseInfo/callVendorPopup.do?"
									+ "popupID="		+ popupID		+ "&"
									+ "openerID="		+ openerID		+ "&"
									+ "popupYN="		+ popupYN		+ "&"
									+ "changeSizeFunc="	+ changeSize	+ "&"
									+ "callBackFunc="	+ callBack		+ "&"
									+ "vendorId="		+ VendorID		+ "&"
									+ "vendorType="		+ VendorType	+ "&"
									+ "isNew="			+ isNew;
					
					Common.open("", popupID, popupTit, popupUrl, "900px", "650px", "iframe", true, null, null, true);
				},
				
				vendorPopup_CallBack : function(){
					var me = this;
					me.searchVendorList();
				},
				
				ChangePopupSize : function(popupID,popupW,popupH){
					accountCtrl.pChangePopupSize(popupID,popupW,popupH);
				},
				
				callUploadPopup : function(){
					
					var popupID		= "vendorExcelPopup";
					var openerID	= "Vendor";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_vendorExcel' />";	//거래처 등록 Excel upload
					var popupYN		= "N";
					var callBack	= "VendorExcelPopup_CallBack";
					var popupUrl	= "/account/baseInfo/vendorExcelPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack;
					Common.open("", popupID, popupTit, popupUrl, "500px", "230px", "iframe", true, null, null, true);
				},
				
				VendorExcelPopup_CallBack : function(){
					var me = this;
					me.searchVendorList();
				},
				
				VendorSync : function(){
					$.ajax({
						url	: "/account/baseInfo/vendorSync.do",
						type: "POST",
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_syncComp' />");	//동기화 되었습니다.
								Vendor.searchVendorList('N');
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}
					});
				},
				onenter : function(){
					var me = this;
					if(event.keyCode=="13"){
						me.searchVendorList();
					}
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.Vendor = Vendor;
	})(window);
</script>