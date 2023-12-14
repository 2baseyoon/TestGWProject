<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	.pad10 { padding:10px;}
</style>

<div class="cRConTop titType">
	<h2 id="headerTitle" class="title"></h2>
</div>
<input id="syncProperty" type="hidden" />
<div class='cRContBottom mScrollVH'>
	<!-- 컨텐츠 시작 -->
	<div class="eaccountingCont">
		<div class="eaccountingTopCont">
			<!-- 상단 버튼 시작 -->
			<div class="pagingType02 buttonStyleBoxLeft">
				<!-- 엑셀 저장 -->
				<a class="btnTypeDefault btnExcel" onclick="EACTaxByCompanyList.excelDownload();"><spring:message code="Cache.ACC_btn_saveExcel"/></a>
			</div>
			<!-- 상단 버튼 끝 -->			
		</div>
		<!-- 검색 내용 -->
		<div id="topitembar02" class="bodysearch_Type01">
			<div class="inPerView type08">
				<div style="width:900px;">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">	<!-- 회사 -->
							<spring:message code="Cache.ACC_lbl_company"/>
						</span>
						<span id="companyCode_TaxByCompany" class="selectType02" onchange="EACTaxByCompanyList.changeCompanyCode()">
						</span>
					</div>
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code="Cache.ACC_lbl_postDate"/>	<!-- 전기일 -->
						</span>
						<div id="searchDateArea" class="dateSel type02">
						</div>
					</div>
				</div>
				<div style="width:900px;">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code="Cache.ACC_lbl_CompanyInfo"/>	<!-- 업체정보 -->
						</span>
						<span id="companyInfo" class="selectType02" style="margin-right: 14px; width: 110px;">
						</span>
						<input type="text" id="searchWord" style="width: 200px;">
					</div>
					<a class="btnTypeDefault btnSearchBlue" onclick="EACTaxByCompanyList.searchList();"><spring:message code="Cache.ACC_btn_search"/></a>
				</div>
			</div>
		</div>
		<div class="inPerTitbox">
			<div class="buttonStyleBoxRight">	
				<span class="selectType02 listCount" id="listCount" onchange="EACTaxByCompanyList.searchList();">
				</span>
				<button class="btnRefresh" type="button" onclick="EACTaxByCompanyList.searchList();"></button>
			</div>
		</div>
		<div id="taxCompanyGridArea" class="pad10">
		</div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>
	
<script>

	if (!window.EACTaxByCompanyList) {
		window.EACTaxByCompanyList = {};
	}
	
	(function(window) {
		var EACTaxByCompanyList = {
				params	: {
					gridPanel	: new coviGrid(),
					headerData	: []
				},
			
				pageInit : function() {
					var me = this;
					setHeaderTitle('headerTitle');
					me.setPageViewController();
					me.pageDatepicker();
					me.setSelectCombo();
					me.setHeaderData();
					me.searchList('Y');
				},
				
				pageView : function() {
					var me = this;
					
					me.setHeaderData();
					me.refreshCombo();
					me.searchList();
				},
				
				setPageViewController :function(){
					var syncProperty	= accountCtrl.getInfo("syncProperty").val();
					
					if(syncProperty == "") {
						accountCtrl.getInfo("btnSync").css("display", "none");
					}
				},
		
				pageDatepicker : function(){
					makeDatepicker('searchDateArea','sDate','eDate','','','');
				},
				
				setSelectCombo : function(){
					var AXSelectMultiArr	= [	
								{'codeGroup':'listCountNum',	'target':'listCount',					'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''},
								{'codeGroup':'CompanyCode',		'target':'companyCode_TaxByCompany',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''},
								{'codeGroup':'CompanyInfo',		'target':'companyInfo',					'lang':'ko',	'onchange':'',	'oncomplete':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}  //전체
	   					]
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},

				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode_TaxByCompany").val());
				},
				
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("companyCode_TaxByCompany");
					accountCtrl.refreshAXSelect("companyInfo");
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	/* {	key:'chk',					label:'chk',															width:'20', align:'center', formatter:'checkbox'}, */
												{	key:'KUNNR',				label:'<spring:message code="Cache.ACC_lbl_CompanyCode"/>',				width:'50', align:'center'}, // 업체코드
												{	key:'NAME1',				label:'<spring:message code="Cache.ACC_lbl_CompanyName"/>',				width:'50', align:'center'}, // 업체명
												{	key:'STCD2',				label:'<spring:message code="Cache.ACC_lbl_BusinessNumber"/>',			width:'50', align:'center'}, // 사업자번호
												{	key:'HWBAS',				label:'<spring:message code="Cache.ACC_lbl_TaxableStandardAmount"/>',	width:'50', align:'center',  // 과세표준액
													formatter: function(){
														return this.item.HWBAS.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
													}
												},
												{	key:'HWSTE',				label:'<spring:message code="Cache.ACC_lbl_taxValue"/>',				width:'50', align:'center',  // 세액
													formatter: function(){
														return this.item.HWSTE.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
													}
												},
												{	key:'RMWWR',				label:'<spring:message code="Cache.ACC_lbl_Sum"/>',						width:'50', align:'center',  // 합계
													formatter: function(){
														return this.item.RMWWR.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
													}
												},
												{	key:'SAP_COUNT',			label:'<spring:message code="Cache.ACC_lbl_NumberOfCase"/>',			width:'50', align:'center'}, // 건수
												{	key:'SUP_AMOUNT',			label:'<spring:message code="Cache.ACC_lbl_supplyValue"/>',				width:'50', align:'center',  // 공급가액
													formatter: function(){
														return this.item.SUP_AMOUNT.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
													}
												},
												{	key:'TAX_AMOUNT',			label:'<spring:message code="Cache.ACC_lbl_taxValue"/>',				width:'50', align:'center',  // 세액
													formatter: function(){
														return this.item.TAX_AMOUNT.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
													}
												},
												{	key:'TOTAL_AMOUNT',			label:'<spring:message code="Cache.ACC_lbl_Sum"/>',						width:'50', align:'center',  // 합계
													formatter: function(){
														return this.item.TOTAL_AMOUNT.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
													}
												},
												{	key:'BILL_COUNT',			label:'<spring:message code="Cache.ACC_lbl_NumberOfCase"/>',			width:'50', align:'center'} // 건수
											]
					
					var configObj = {
							targetID: "taxCompanyGridArea",
							height: "auto",
							listCountMSG: "<b>{listCount}</b>", 
							page : {
								pageNo: 1,
								pageSize: accountCtrl.getComboInfo("listCount").val()
							},
							paging: true,
							colHead: {
								rows: [
										[
											/* {	key:'chk',														rowspan:'2'}, */
											{	key:'KUNNR',													rowspan:'2'},
											{	key:'NAME1',													rowspan:'2'},
											{	key:'STCD2',													rowspan:'2'},
											{	key:'HWBAS',													rowspan:'2'},
											{	key:'HWSTE',													rowspan:'2'},
											{	key:'RMWWR',													rowspan:'2'},
											{	key:'SAP_COUNT',												rowspan:'2'},
											{	label:'<spring:message code="Cache.ACC_lbl_TaxInvoice"/>',		colspan:'4'} // 세금계산서
										],
										[
											{	key:'SUP_AMOUNT'},
											{	key:'TAX_AMOUNT'},
											{	key:'TOTAL_AMOUNT'},
											{	key:'BILL_COUNT'}
										]
									]
							},
							colGroup: me.params.headerData,
							body: {}
					}
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					
					gridPanel.setGridConfig(configObj);
					//accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(YN){
					var me				= this;
					me.setHeaderData();
					
					var companyCode		= accountCtrl.getComboInfo("companyCode_TaxByCompany").val();
					var stDt			= accToString(accountCtrl.getInfo('sDate').val());
					var edDt			= accToString(accountCtrl.getInfo('eDate').val());
					var sDate			= stDt.replaceAll(".", "-");
					var eDate			= edDt.replaceAll(".", "-");
					var searchType		= accountCtrl.getComboInfo("companyInfo").val();
					var searchWord		= accountCtrl.getInfo("searchWord").val();
					
					var today = new Date();
					if(	accountCtrl.getInfo('eDate').val() == ""	||
						accountCtrl.getInfo('eDate').val() == null){
						EACTaxByCompanyListDateFinish = today.toISOString().slice(0,10).replace(/-/g,"");
					}
					
					var gridAreaID		= "taxCompanyGridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/EACTax/getEACTaxByCompanyList.do";
					var ajaxPars		= {	"companyCode" :	companyCode,
											"sDate"	:		sDate,
							 				"eDate"	:		eDate,
							 				"searchType":	searchType,
							 				"searchWord":	searchWord
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
					}
					
					gridPanel.bindGrid({
		 				ajaxUrl	: ajaxUrl
		 			,	ajaxPars: ajaxPars
		 			,	onLoad:function(){
			 				coviInput.setSwitch();
			 				gridPanel.fnMakeNavi(gridParams.gridAreaID);
		 				}
					});
					
					//accountCtrl.setViewPageBindGrid(gridParams);
				},
				
				excelDownload : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save'/>", function(result){
			       		if(result){
							var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerData);
							var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerData);
							var stDt			= accToString(accountCtrl.getInfo('sDate').val());
							var edDt			= accToString(accountCtrl.getInfo('eDate').val());
							var sDate			= stDt.replaceAll(".", "-");
							var eDate			= edDt.replaceAll(".", "-");
							var today			= new Date();
							var searchType		= accountCtrl.getComboInfo("companyInfo").val();
							var searchWord		= accountCtrl.getInfo("searchWord").val();
							var companyCode		= accountCtrl.getComboInfo("companyCode_TaxByCompany").val();
							
							if(	accountCtrl.getInfo('eDate').val() == ""	||
								accountCtrl.getInfo('eDate').val() == null){
								finish = today.toISOString().slice(0,10).replace(/-/g,"");
							}
							var headerType		= accountCommon.getHeaderTypeForExcel(me.params.headerData);
							var title 			= accountCtrl.getInfo("headerTitle").text();
							
							location.href	= "/account/EACTax/EACTaxByCompanyListExcelDownload.do?"
											//+ "headerName="		+ encodeURI(headerName)		+ "&"
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName)) + "&"
											+ "headerKey="		+ encodeURI(headerKey)		+ "&"
											+ "sDate="			+ encodeURI(sDate)			+ "&"
											+ "eDate="			+ encodeURI(eDate)			+ "&"
											+ "searchType="		+ encodeURI(searchType)		+ "&"
											+ "searchWord="		+ encodeURI(searchWord)		+ "&"
											//+ "title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text()) + "&"
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title)) + "&"
											+ "companyCode="	+ encodeURI(companyCode)	+ "&"
											+ "headerType="		+ encodeURI(headerType);
						}
					});
				},
				
				EACTaxByCompanyListPopup_CallBack : function(){
					var me = this;
					me.searchList();
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.EACTaxByCompanyList = EACTaxByCompanyList;
	})(window);
</script>