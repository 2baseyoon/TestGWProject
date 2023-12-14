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
	<input id="syncProperty" type="hidden" />
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 추가 -->
					<a class="btnTypeDefault btnTypeChk"		onclick="FormManage.formManageAddPopup();"	id="btnAdd"><spring:message code="Cache.ACC_btn_add"/></a>
					<!-- 삭제 -->
					<a class="btnTypeDefault"					onclick="FormManage.formManageDel();"	id="btnDel"><spring:message code="Cache.ACC_btn_delete"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"					onclick="FormManage.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"			onclick="FormManage.excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 엑셀업로드 -->
					<a class="btnTypeDefault btnExcel_upload"	onclick="FormManage.excelUpload();"	id="btnExcelUp"><spring:message code="Cache.ACC_lbl_excelUpload"/></a>
				</div>
				<!-- 상단 버튼 끝 -->
			</div>
			
			<div id="searchBar1" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_companyCode"/>	<!-- 회사코드 -->
							</span>
							<span id="companyCode" class="selectType02" onchange="FormManage.changeCompanyCode()">
							</span>
						</div>	
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_division"/>	<!-- 구분 -->
							</span>
							<span id="searchType" class="selectType02">
							</span>
							<input onkeydown="FormManage.onenter()" id="searchStr" type="text" placeholder="">
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_isUse"/>	<!-- 사용여부 -->
							</span>
							<span id="isUse" class="selectType02">
							</span>
						</div>	
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_requestType"/>		<!-- 신청유형 -->
							</span>
							<span id="expAppType" class="selectType02" style="width: 309px;">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.lbl_menuType"/>		<!-- 메뉴유형 -->
							</span>
							<span id="menuType" class="selectType02">
							</span>
						</div>					
						<a class="btnTypeDefault  btnSearchBlue" onclick="FormManage.searchList();"><spring:message code='Cache.ACC_btn_search'/></a><!-- 검색 -->
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="FormManage.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="FormManage.searchList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>
		
	if (!window.FormManage) {
		window.FormManage = {};
	}
	
	(function(window) {
		var FormManage = {
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
			
			setSelectCombo : function(pCompanyCode){
				accountCtrl.getInfo("listCount").children().remove();
				accountCtrl.getInfo("expAppType").children().remove();
				accountCtrl.getInfo("menuType").children().remove();
				accountCtrl.getInfo("isUse").children().remove();
				accountCtrl.getInfo("searchType").children().remove();

				accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "BizTrip.searchList()");
				accountCtrl.getInfo("expAppType").addClass("selectType02").css("width", "309px");
				accountCtrl.getInfo("menuType").addClass("selectType02");
				accountCtrl.getInfo("isUse").addClass("selectType02");
				accountCtrl.getInfo("searchType").addClass("selectType02");
					
				var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'ExpAppType',		'target':'expAppType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"} //전체
						,	{'codeGroup':'MenuType',		'target':'menuType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'IsUse',			'target':'isUse',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'fmSearchType',	'target':'searchType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
					]
				
				if(pCompanyCode != undefined) {
					AXSelectMultiArr.pop(); //CompanyCode 제외
				}
				
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
			},
			
			refreshCombo : function(){
				accountCtrl.refreshAXSelect("companyCode");
				accountCtrl.refreshAXSelect("expAppType");
				accountCtrl.refreshAXSelect("menuType");
				accountCtrl.refreshAXSelect("isUse");
				accountCtrl.refreshAXSelect("searchType");
			},
			
			changeCompanyCode : function() {
				var me = this;
				me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
			},
			
			setHeaderData : function() {
				var me = this;
				
				me.params.headerData = [	{	key:'chk',				label:'chk', width:'20', align:'center', formatter:'checkbox'},
											{	key:'CompanyName',		label:"<spring:message code='Cache.ACC_lbl_company' />",			width:'70', align:'center'},	//회사명
											{	key:'FormCode',			label:"<spring:message code='Cache.ACC_lbl_formCode' />",			width:'70', align:'center',		//비용신청서 코드
												formatter:function () {
													var rtStr =	""
																+	"<a onclick='FormManage.formManageDetailPopup(\""+ this.item.ExpenceFormID +"\",\""+this.item.FormCode+"\"); return false;'>"
																+		"<font color='blue'>"
																+			this.item.FormCode
																+		"</font>"
																+	"</a>";
													return rtStr;
												}
											},
											{	key:'FormName',			label:"<spring:message code='Cache.ACC_lbl_formName' />",			width:'70', align:'center'},	//비용신청서 이름
											{	key:'ExpAppTypeName',	label:"<spring:message code='Cache.ACC_lbl_requestType' />",		width:'70', align:'center'},	//신청유형
											{	key:'MenuTypeName',		label:"<spring:message code='Cache.lbl_menuType' />",				width:'70', align:'center'},	//메뉴유형
											{	key:'IsUse',			label:"<spring:message code='Cache.ACC_lbl_isUse' />",				width:'70', align:'center',		//사용여부
												formatter:function () {
														var col			= 'IsUse'
														var key			= this.item.ExpenceFormID;
														var value		= this.item.IsUse;
														var on_value	= 'Y';
														var off_value	= 'N';
														var onchangeFn	= 'FormManage.formManageIsUse(\"'+ this.item.ExpenceFormID +'\",\"'+this.item.IsUse+'\")';
													return accountCtrl.getGridSwitch(col,key,value,on_value,off_value,onchangeFn);
												}
											},
											{	key:'SortKey',			label:"<spring:message code='Cache.ACC_lbl_sortOrder'/>",			width:'50',	align:'center'},	//정렬순서
											{	key:'ModifierName',		label:"<spring:message code='Cache.ACC_lbl_modifier' />",			width:'70', align:'center'},	//수정자
											{	key:'ModifyDate',		label:"<spring:message code='Cache.ACC_lbl_modifyDate' />",			width:'70', align:'center'},	//수정일자
										]
				
				
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},
			
			searchList : function(YN){
				var me = this;
				
				me.setHeaderData();

				var searchType		= accountCtrl.getComboInfo("searchType").val();		//구분
				var searchStr		= accountCtrl.getInfo("searchStr").val();			//조회문장
				var companyCode		= accountCtrl.getComboInfo("companyCode").val();	//회사코드
				var expAppType		= accountCtrl.getComboInfo("expAppType").val();		//신청유형
				var menuType		= accountCtrl.getComboInfo("menuType").val();		//메뉴유형
				var isUse			= accountCtrl.getComboInfo("isUse").val();			//사용여부
				
				var gridAreaID		= "gridArea";
				var gridPanel		= me.params.gridPanel;
				var gridHeader		= me.params.headerData;
				var ajaxUrl			= "/account/formManage/getFormManagelist.do";
				var ajaxPars		= {	
	 				"searchType"		: searchType
	 				,	"searchStr"		: searchStr
	 				,	"companyCode"	: companyCode
	 				,	"expAppType"	: expAppType
					,	"menuType"		: menuType
	 				,	"isUse"			: isUse
				};
				
				var pageNoInfo	= 1;
				if(YN == 'Y'){
					pageNoInfo	= me.params.gridPanel.page.pageNo;
				}
				
				var pageSizeInfo	= accountCtrl.getComboInfo("listCount").val();
				
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
			
			formManageDel : function(){
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
									deleteSeq = deleteObj[i].ExpenceFormID;
								}else{
									deleteSeq = deleteSeq + "," + deleteObj[i].ExpenceFormID;
								}
							}
							$.ajax({
								url	:"/account/formManage/deleteFormManageInfo.do",
								type: "POST",
								data: {
										"deleteSeq" : deleteSeq
								},
								success:function (data) {
									if(data.status == "SUCCESS"){
										Common.Inform("<spring:message code='Cache.ACC_msg_delComp' />")		//삭제되었습니다.
										FormManage.searchList();
									}else{
										Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 		//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
									}
								},
								error:function (error){
									Common.Error("<spring:message code='Cache.ACC_msg_error' />");
								}
							});
						}
					})
				}
			},
			
			excelUpload : function(){
				var popupID		= "formManageExcelPopup";
				var openerID	= "FormManage";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_accountModify' />";	//계정관리
				var popupYN		= "N";
				var callBack	= "formManageExcelPopup_CallBack";
				var popupUrl	= "/account/formManage/formManageExcelPopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "callBackFunc="	+ callBack;
				
				Common.open("", popupID, popupTit, popupUrl, "500px", "220px", "iframe", true, null, null, true);
			},
			
			formManageExcelPopup_CallBack : function(){
				var me = this;
				me.searchList();
			},
			
			excelDownload : function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
		       		if(result){
						var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerData);
						var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerData);
						var searchType		= accountCtrl.getComboInfo("searchType").val();		//구분
						var searchStr		= accountCtrl.getInfo("searchStr").val();			//조회문장
						var companyCode		= accountCtrl.getComboInfo("companyCode").val();	//회사코드
						var expAppType		= accountCtrl.getComboInfo("expAppType").val();		//신청유형
						var menuType		= accountCtrl.getComboInfo("menuType").val();		//메뉴유형
						var isUse			= accountCtrl.getComboInfo("isUse").val();			//사용여부
						var title 			= accountCtrl.getInfo("headerTitle").text();
						var	locationStr		= "/account/formManage/formManageExcelDownload.do?"
											//+ "headerName="		+ headerName
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="		+ headerKey
											+ "&searchType="	+ searchType
											+ "&searchStr="		+ searchStr
											+ "&companyCode="	+ companyCode
											+ "&expAppType="	+ expAppType
											+ "&menuType="		+ menuType
											+ "&isUse="			+ isUse
											//+ "&title="			+ accountCtrl.getInfo("headerTitle").text();
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title));
						
						location.href = locationStr;
		       		}
		       	});
			},
			
			formManageAddPopup : function(){
				var mode		= "add";
				var popupID		= "formManagePopup";
				var openerID	= "FormManage";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_expenceFormAdd' />";
				var popupYN		= "N";
				var callBack	= "formManage_CallBack";
				var popupUrl	= "/account/formManage/getFormManagePopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "callBackFunc="	+ callBack	+ "&"
								+ "mode="			+ mode;
				
				Common.open("", popupID, popupTit, popupUrl, "850px", "690px", "iframe", true, null, null, true);
			},
			
			formManageDetailPopup : function(key,code){
				var mode		= "modify";
				var popupID		= "formManagePopup";
				var openerID	= "FormManage";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_expenceFormEdit' />";
				var popupYN		= "N";
				var callBack	= "formManage_CallBack";
				var popupUrl	= "/account/formManage/getFormManagePopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "callBackFunc="	+ callBack	+ "&"
								+ "expenceFormID="	+ key		+ "&"
								+ "formCode="		+ code		+ "&"
								+ "mode="			+ mode;
				
				Common.open("", popupID, popupTit, popupUrl, "850px", "690px", "iframe", true, null, null, true);
			},
			
			formManage_CallBack :function(){
				var me = this;
				me.searchList();
			},
			
			formManageIsUse : function(key,sts){
				
				if(	key	== null || key	== '' ||
					sts	== null	|| sts	== ''){
					return
				}
				
				var expenceFormID	= key;
				var isUse		= "";
				
				if(sts == 'Y'){
					isUse = 'N'
				}else{
					isUse = 'Y'
				}
				
				$.ajax({
					url	: "/account/formManage/saveFormManageInfo.do",
					type: "POST",
					data: {
							"expenceFormID"	: expenceFormID
						,	"isUse"		: isUse
						,	"listPage"	: 'Y'
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							//Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
							FormManage.searchList();
						}else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
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
					me.searchList();
				}
			},
			
			refresh : function(){
				accountCtrl.pageRefresh();
			}
		}
		window.FormManage = FormManage;
	})(window);
</script>