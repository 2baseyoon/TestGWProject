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
					<!-- 추가 -->
					<a class="btnTypeDefault btnTypeChk"		onclick="StoreCategoryManage.StoreCategoryManagePopup()"><spring:message code="Cache.ACC_btn_add"/></a>
					<!-- 삭제 -->
					<a class="btnTypeDefault"					onclick="StoreCategoryManage.StoreCategoryManageDel()"><spring:message code="Cache.ACC_btn_delete"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"					onclick="StoreCategoryManage.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"			onclick="StoreCategoryManage.excelDownload()"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 엑셀업로드 -->
					<a class="btnTypeDefault btnExcel_upload"	onclick="StoreCategoryManage.excelUpload()"><spring:message code="Cache.ACC_lbl_excelUpload"/></a>
				</div>
				<!-- 상단 버튼 끝 -->
			</div>
			
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type07">
				
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 회사 -->
								<spring:message code="Cache.ACC_lbl_company"/>
							</span>
							<span id="CompanyCode" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 업종명 -->
								<spring:message code="Cache.ACC_lbl_vendorSectorName"/>
							</span>
							<input onkeydown="StoreCategoryManage.onenter()" id="CategoryName" type="text" placeholder="">
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 표준적요 -->
								<spring:message code="Cache.ACC_standardBrief"/>
							</span>
							<input onkeydown="StoreCategoryManage.onenter()" id="StandardBriefName" type="text" placeholder="">
						</div>
						<a class="btnTypeDefault  btnSearchBlue"	onclick="StoreCategoryManage.searchList()"><spring:message code='Cache.ACC_btn_search'/></a>
					</div>
					
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="StoreCategoryManage.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="StoreCategoryManage.searchList()"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>
	if (!window.StoreCategoryManage) {
		window.StoreCategoryManage = {};
	}
	
	(function(window) {
		var StoreCategoryManage = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
				
				pageInit : function() {
					var me = this;
					setHeaderTitle('headerTitle');
					me.setSelectCombo();
					me.setHeaderData();
					me.searchList();
				},
				
				pageView : function() {
					var me = this;
					
					me.setHeaderData();
					me.refreshCombo();
					
					me.searchList();
				},
				
				setSelectCombo : function(){
					var AXSelectMultiArr	= [
								{'codeGroup':'listCountNum',	'target':'listCount',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
							,	{'codeGroup':'CompanyCode',		'target':'CompanyCode',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						
						]
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},
				
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("CompanyCode");
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'chk',					label:'chk',										width:'20', align:'center',
													formatter:'checkbox'
												},
												{	key:'CompanyName'		,	label:"<spring:message code='Cache.ACC_lbl_companyName' />",				width:'70', align:'center'},
												{	key:'CategoryCode'		,	label:"<spring:message code='Cache.ACC_lbl_vendorSectorCode' />",			width:'70', align:'center'},
												{	key:'CategoryName'		,	label:"<spring:message code='Cache.ACC_lbl_vendorSectorName' />",			width:'70', align:'center'
												,	formatter:function () {
															var rtStr =	""
																+	"<a onclick='StoreCategoryManage.StoreCategoryManagePopup("+ this.item.CategoryID +"); return false;'>"
																+		"<font color='blue'>"
																+			this.item.CategoryName
																+		"</font>"
																+	"</a>";
													return rtStr;
												}},	
												{	key:'StandardBriefName'	,	label:"<spring:message code='Cache.ACC_standardBrief' />",			width:'70', align:'center'},	
												
												
											]
					me.params.headerDataExcel = [	{	key:'CompanyCode',		label:"<spring:message code='Cache.ACC_lbl_companyCode' />",				width:'70', align:'center'},	
					                             	{	key:'CompanyName',		label:"<spring:message code='Cache.ACC_lbl_companyName' />",				width:'70', align:'center'},	
					                             	{	key:'CategoryCode',		label:"<spring:message code='Cache.ACC_lbl_vendorSectorCode' />",			width:'70', align:'center'},	
													{	key:'CategoryName',		label:"<spring:message code='Cache.ACC_lbl_vendorSectorName' />",			width:'70', align:'center'},	
													{	key:'StandardBriefName'	,label:"<spring:message code='Cache.ACC_standardBrief' />",					width:'70', align:'left'},		
													
												]
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var CompanyCode	= accountCtrl.getComboInfo("CompanyCode").val();
					var CategoryName	= accountCtrl.getInfo("CategoryName").val();
					var StandardBriefName	= accountCtrl.getInfo("StandardBriefName").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/StoreCategoryManage/getStoreCategoryManagelist.do";
					var ajaxPars		= {	"CompanyCode"	: CompanyCode,
							 				"CategoryName"	: CategoryName,
							 				"StandardBriefName"	: StandardBriefName
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
					
					accountCtrl.setViewPageBindGrid(gridParams);
				},
				
				StoreCategoryManageDel : function(){
					var me = this;
					var deleteObj = me.params.gridPanel.getCheckedList(0);
					if(deleteObj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noDataDelete' />");	//삭제할 항목이 없습니다.
						return;
					}else{
						Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//삭제하시겠습니까?
							if(result){
								var deleteSeq = "";
								for(var i=0; i<deleteObj.length; i++){
									if(i==0){
										deleteSeq = deleteObj[i].CategoryID;
									}else{
										deleteSeq = deleteSeq + "," + deleteObj[i].CategoryID;
									}
								}
								$.ajax({
									url	:"/account/StoreCategoryManage/deleteStoreCategoryManageInfo.do",
									type: "POST",
									data: {
											"deleteSeq" : deleteSeq
									},
									success:function (data) {
										if(data.status == "SUCCESS"){
											Common.Inform("<spring:message code='Cache.ACC_msg_delComp' />");	//삭제를 완료하였습니다.
											StoreCategoryManage.refresh();
										}else{
											Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
										}
									},
									error:function (error){
										Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
									}
								});
							}
						})
					}
				},
				
				
				excelUpload : function(){
					var popupID		= "StoreCategoryManageExcelPopup";
					var openerID	= "StoreCategoryManage";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_vendorSectorName' />";	
					var popupYN		= "N";
					var callBack	= "StoreCategoryManageExcelPopup_CallBack";
					var popupUrl	= "/account/StoreCategoryManage/StoreCategoryManageExcelPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack;

					Common.open("", popupID, popupTit, popupUrl, "500px", "220px", "iframe", true, null, null, true);
				},
				
				StoreCategoryManageExcelPopup_CallBack : function(){
					var me = this;
					me.searchList();
				},
				
				excelDownload : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
							var headerName	= accountCommon.getHeaderNameForExcel(me.params.headerDataExcel);
							var headerKey	= accountCommon.getHeaderKeyForExcel(me.params.headerDataExcel);
							
							var CompanyCode			= accountCtrl.getComboInfo("CompanyCode").val();
							var CategoryName		= accountCtrl.getInfo("CategoryName").val();
							var StandardBriefName	= accountCtrl.getInfo("StandardBriefName").val();
							var headerType			= accountCommon.getHeaderTypeForExcel(me.params.headerDataExcel);
							var title 			= accountCtrl.getInfo("headerTitle").text();
							
							var	locationStr		= "/account/StoreCategoryManage/StoreCategoryManageExcelDownload.do?"
												//+ "headerName="			+ encodeURI(headerName)
												+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
												+ "&headerKey="			+ encodeURI(headerKey)
												+ "&CompanyCode="		+ encodeURI(CompanyCode)
												+ "&CategoryName="		+ encodeURI(CategoryName)
												+ "&StandardBriefName="	+ encodeURI(StandardBriefName)
												//+ "&title="				+ encodeURI(accountCtrl.getInfo("headerTitle").text())
												+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
												+ "&headerType=" 		+ encodeURI(headerType);
							
							location.href = locationStr;
						}
					});
				},
				
				StoreCategoryManagePopup : function(CategoryID){
					var popupID		= "StoreCategoryManagePopup";
					var openerID	= "StoreCategoryManage";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_StoreCategoryInfoAdd' />";	//업종정보등록
					var popupYN		= "N";
					var callBack	= "StoreCategoryManagePopup_CallBack";
					var popupUrl	= "/account/StoreCategoryManage/callStoreCategoryManagePopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "CategoryID="		+ CategoryID;
							
					Common.open("", popupID, popupTit, popupUrl, "460px", "300px", "iframe", true, null, null, true);
				},
				StoreCategoryManagePopup_CallBack : function(){
					var me = this;
					me.searchList();
				},
				
				onenter : function(){
					var me = this;
					if(event.keyCode=="13"){
						me.searchList();
					}
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.StoreCategoryManage = StoreCategoryManage;
	})(window);
</script>