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
				<!-- 전표 가져오기 -->
				<a class="btnTypeDefault  btnTypeBg"	onclick="EACTaxMapList.openPopup('UP');"><spring:message code="Cache.ACC_btn_importStatement"/></a>
				<!-- 엑셀 저장 -->
				<a class="btnTypeDefault btnExcel"		onclick="EACTaxMapList.excelDownload();"><spring:message code="Cache.ACC_btn_saveExcel"/></a>
				<!-- 자동맵핑 -->
				<a class="btnTypeDefault"				onclick="EACTaxMapList.openPopup('MAPPING')"><spring:message code="Cache.ACC_btn_AutomaticMapping"/></a>
				<!-- 초기화 -->
				<a class="btnTypeDefault"				onclick="EACTaxMapList.openPopup('INITIAL');"><spring:message code="Cache.ACC_btn_reset"/></a>
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
						<span id="companyCode_TaxMap" class="selectType02" onchange="EACTaxMapList.changeCompanyCode()"></span>
					</div>
				</div>
				<div style="width:900px;">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code="Cache.ACC_lbl_postDate"/>	<!-- 전기일 -->
						</span>
						<div id="searchDateArea" class="dateSel type02">
						</div>
					</div>
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code="Cache.ACC_lbl_MappingStatus"/>	<!-- 맵핑여부 -->
						</span>
						<span id="useMapping" class="selectType02">
						</span>
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
					<a class="btnTypeDefault btnSearchBlue" onclick="EACTaxMapList.searchList();"><spring:message code="Cache.ACC_btn_search"/></a>	<!-- 검색 -->
				</div>
			</div>
		</div>
		<div class="inPerTitbox">
			<div class="buttonStyleBoxRight">	
				<span class="selectType02 listCount" id="listCount" onchange="EACTaxMapList.searchList();">
				</span>
				<button class="btnRefresh" type="button" onclick="EACTaxMapList.searchList();"></button>
			</div>
		</div>
		<div id="taxMapGridArea" class="pad10">
		</div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>
	
<script>

	if (!window.EACTaxMapList) {
		window.EACTaxMapList = {};
	}
	
	(function(window) {
		var EACTaxMapList = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: [],
					BELNR		: ""
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
								{'codeGroup':'listCountNum',	'target':'listCount',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''},
								{'codeGroup':'CompanyCode',		'target':'companyCode_TaxMap',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''},
								{'codeGroup':'UseMapping',		'target':'useMapping',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}, //전체
								{'codeGroup':'CompanyInfo',		'target':'companyInfo',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}  //전체
	   					]
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode_TaxMap").val());
				},
				
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("companyCode_TaxMap");
					accountCtrl.refreshAXSelect("useMapping");
					accountCtrl.refreshAXSelect("companyInfo");
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	/* {	key:'chk',					label:'chk',															width:'20', align:'center', formatter:'checkbox'}, */
												{	key:'BUPLA',				label:'<spring:message code="Cache.ACC_lbl_PlaceOfBusiness"/>',			width:'50', align:'center'}, // 사업장
												{	key:'BELNR_KIND_NAME',		label:'<spring:message code="Cache.ACC_lbl_BusinessDivision"/>',		width:'50', align:'center'}, // 업무구분
												{	key:'KUNNR',				label:'<spring:message code="Cache.ACC_lbl_CompanyCode"/>',				width:'50', align:'center'}, // 업체코드
												{	key:'NAME1',				label:'<spring:message code="Cache.ACC_lbl_CompanyName"/>',				width:'50', align:'center'}, // 업체명
												{	key:'STCD2',				label:'<spring:message code="Cache.ACC_lbl_BusinessNumber"/>',			width:'50', align:'center'}, // 사업자번호
												{	key:'BUDAT',				label:'<spring:message code="Cache.ACC_lbl_postDate"/>',				width:'50', align:'center'}, // 전기일
												{	key:'BELNR',				label:'<spring:message code="Cache.ACC_lbl_docNo"/>',					width:'50', align:'center'}, // 전표번호
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
												{	key:'APPROVE_ID',			label:'<spring:message code="Cache.ACC_lbl_confirmNum"/>',				width:'50', align:'center'}, // 승인번호
												{	key:'MAPPING',				label:' ',																width:'30', align:'center', 
													formatter: function(){
														if(this.item.MAPPING == 'N'){
															return "<button class='btnSearchType01' onclick='EACTaxMapList.openTaxPop(this);' style='width: 30px;'></button>";
														}
														return "";
													}
												},
												{	key:'WriteDate',			label:'<spring:message code="Cache.ACC_lbl_CreateDate"/>',			width:'50', align:'center'}, // 작성일자
												{	key:'InvoicerCorpNum',		label:'<spring:message code="Cache.ACC_lbl_BusinessNumber"/>',		width:'50', align:'center'}, // 사업자번호
												{	key:'InvoicerCorpName',		label:'<spring:message code="Cache.ACC_lbl_CompanyName"/>',			width:'50', align:'center'}, // 업체명
												{	key:'SupplyCostTotal',		label:'<spring:message code="Cache.ACC_lbl_supplyValue"/>',			width:'50', align:'center',	 // 공급가액
													formatter: function(){
														return this.item.SupplyCostTotal.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
													}
												},
												{	key:'TaxTotal',				label:'<spring:message code="Cache.ACC_lbl_taxValue"/>',			width:'50', align:'center',  // 세액
													formatter: function(){
														return this.item.TaxTotal.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
													}
												},
												{	key:'TotalAmount',			label:'<spring:message code="Cache.ACC_lbl_Sum"/>',					width:'50', align:'center',  // 합계
													formatter: function(){
														return this.item.TotalAmount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
													}
												}
											]
					
					var configObj = {
							targetID: "taxMapGridArea",
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
											/* {	key:'chk',																rowspan:'2'}, */
											{	key:'BUPLA',															rowspan:'2'},
											{	key:'BELNR_KIND_NAME',													rowspan:'2'},
											{	key:'KUNNR',															rowspan:'2'},
											{	key:'NAME1',															rowspan:'2'},
											{	key:'STCD2',															rowspan:'2'},
											{	label:'<spring:message code="Cache.ACC_lbl_SAPStatement"/>',			colspan:'5'}, // SAP전표
											{	label:'<spring:message code="Cache.ACC_lbl_businessTaxInvoice"/>',		colspan:'8'}  // 사업자세금계산서
										],
										[
											{	key:'BUDAT'},
											{	key:'BELNR'},
											{	key:'HWBAS'},
											{	key:'HWSTE'},
											{	key:'RMWWR'},
											{	key:'APPROVE_ID'},
											{	key:'MAPPING'},
											{	key:'WriteDate'},
											{	key:'InvoicerCorpNum'},
											{	key:'InvoicerCorpName'},
											{	key:'SupplyCostTotal'},
											{	key:'TaxTotal'},
											{	key:'TotalAmount'}
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
					
					var companyCode		= accountCtrl.getComboInfo("companyCode_TaxMap").val();
					var stDt			= accToString(accountCtrl.getInfo('sDate').val());
					var edDt			= accToString(accountCtrl.getInfo('eDate').val());
					var sDate			= stDt.replaceAll(".", "-");
					var eDate			= edDt.replaceAll(".", "-");
					var useMapping		= accountCtrl.getComboInfo("useMapping").val();
					var searchType		= accountCtrl.getComboInfo("companyInfo").val();
					var searchWord		= accountCtrl.getInfo("searchWord").val();
					var today			= new Date();
					
					if(	accountCtrl.getInfo('eDate').val() == ""	||
						accountCtrl.getInfo('eDate').val() == null){
						EACTaxMapListDateFinish = today.toISOString().slice(0,10).replace(/-/g,"");
					}
					
					var gridAreaID		= "taxMapGridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/EACTax/getEACTaxMapList.do";
					var ajaxPars		= {	"companyCode" :	companyCode,
											"sDate"	:		sDate,
							 				"eDate"	:		eDate,
							 				"useMapping":	useMapping,
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
							var useMapping		= accountCtrl.getComboInfo("useMapping").val();
							var searchType		= accountCtrl.getComboInfo("companyInfo").val();
							var searchWord		= accountCtrl.getInfo("searchWord").val();
							var companyCode		= accountCtrl.getComboInfo("companyCode_TaxMap").val();
							
							if(	accountCtrl.getInfo('eDate').val() == ""	||
								accountCtrl.getInfo('eDate').val() == null){
								finish = today.toISOString().slice(0,10).replace(/-/g,"");
							}
							var headerType		= accountCommon.getHeaderTypeForExcel(me.params.headerData);
							var title 			= accountCtrl.getInfo("headerTitle").text();
							
							location.href	= "/account/EACTax/EACTaxMapListExcelDownload.do?"
											//+ "headerName="		+ encodeURI(headerName)		+ "&"
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName)) + "&"
											+ "headerKey="		+ encodeURI(headerKey)		+ "&"
											+ "sDate="			+ encodeURI(sDate)			+ "&"
											+ "eDate="			+ encodeURI(eDate)			+ "&"
											+ "useMapping="		+ encodeURI(useMapping)		+ "&"
											+ "searchType="		+ encodeURI(searchType)		+ "&"
											+ "searchWord="		+ encodeURI(searchWord)		+ "&"
											+ "companyCode="	+ encodeURI(companyCode)	+ "&"
											+ "title="			+ encodeURIComponent(encodeURIComponent(title)) + "&"
											+ "headerType="		+ encodeURI(headerType);
						}
					});
				},
				
				EACTaxMapListPopup_CallBack : function(){
					var me = this;
					me.searchList();
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				},
				
				openPopup : function(mode){
					var popupID		= "EACTaxPopup";
					var openerID	= "EACTaxMapList";
					var popupYN		= "N";
					var callBack	= "EACTaxPopup_CallBack";
					var popupTit	= "";
					var popupUrl	= "/account/EACTax/getEACTaxPopup.do?"
									+ "popupID="		+ popupID		+ "&"
									+ "openerID="		+ openerID		+ "&"
									+ "popupYN="		+ popupYN		+ "&"
									+ "callBackFunc="	+ callBack		+ "&"
									+ "mode="			+ mode;
					
					switch(mode){
						case "UP":
							popupTit = "<spring:message code='Cache.ACC_btn_importStatement'/>"; // 전표 가져오기
							break;
						case "MAPPING":
							popupTit = "<spring:message code='Cache.ACC_btn_AutomaticMapping'/>"; // 자동맵핑
							break;
						case "INITIAL":
							popupTit = "<spring:message code='Cache.ACC_btn_reset'/>"; // 초기화
							break;
					}
					
					Common.open("", popupID, popupTit, popupUrl, "480px", "300px", "iframe", true, null, null, true);
				},
				
				EACTaxPopup_CallBack : function(){
					var me = this;
					me.searchList();
				}, 
				
				openTaxPop : function(obj){
					var me		= this;
					var row		= $(obj).parent().parent().parent();
					var idx		= $(".AXGridBody tbody").eq(1).find("tr").index(row);
					var cno		= "";

					$.each(me.params.gridPanel.getList(true), function(i,obj){
						if(i == idx){
							me.params.BELNR		= obj.BELNR
							cno					= obj.STCD2
						}
					});
		            
		            var popupID		=	"taxinvoiceSearchPopup";
		            var openerID	= 	"EACTaxMapList";
					var popupTit	=	"<spring:message code='Cache.ACC_btn_taxBillLoad'/>";
					var popupName	=	"TaxinvoiceSearchPopup";
					var callBack	= 	"EACTaxSearchPopup_CallBack";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"openerID="		+	openerID	+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"includeAccount=N&"
									+	"cno="			+	cno			+	"&"
									+	"callBackFunc="	+	callBack;
									
					Common.open("", popupID, popupTit, url, "1200px", "630px", "iframe", true, null, null, true);
				},
				
				EACTaxSearchPopup_CallBack : function(val){
					var me = this;
					
					if (me.params.BELNR && val && val.TaxInvoiceID) {
		                var taxId = val.TaxInvoiceID;
		                me.registTaxMap(taxId, me.params.BELNR);
	                    Common.Inform("<spring:message code='Cache.ACC_msg_processComplet' />", "<spring:message code='Cache.ACC_lbl_autoCheckOfBill' />", function(){me.searchList();}); //처리를 완료하였습니다., 계산서 자동 대사
		            }
				},

				registTaxMap : function(tID, sID){
					var me = this;
					
					$.ajax({
						url : "/account/EACTax/registTaxMap.do",
						type: "POST",
						data: {
							"tID":	tID,
							"sID":	sID,
							"userCode":	Common.getSession("UR_ID")
						},
						success: function(data){
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_processComplet' />", "<spring:message code='Cache.ACC_lbl_autoCheckOfBill' />", function(){me.searchList();}); //처리를 완료하였습니다., 계산서 자동 대사
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
							}
						},
						error: function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}				
					});
				}
		}
		window.EACTaxMapList = EACTaxMapList;
	})(window);
</script>