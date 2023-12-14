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
	<input id="saveProperty" type="hidden" />
	<input id="syncProperty" type="hidden" />
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 추가 -->
					<a class="btnTypeDefault  btnTypeBg"		onclick="CostCenter.costCenterAddPopup();"	id="btnAdd"><spring:message code='Cache.ACC_btn_add'/></a>
					<!-- 삭제 -->
					<a class="btnTypeDefault"					onclick="CostCenter.costCenterDel();"		id="btnDel"><spring:message code='Cache.ACC_btn_delete'/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"					onclick="CostCenter.refresh()"><spring:message code='Cache.ACC_btn_refresh'/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"			onclick="CostCenter.excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 엑셀업로드 -->
					<a class="btnTypeDefault btnExcel_upload"	onclick="CostCenter.excelUpload();"			id="btnExcelUp"><spring:message code="Cache.ACC_lbl_excelUpload"/></a>
					<!-- 동기화 -->
					<a class="btnTypeDefault"					onclick="CostCenter.costCenterSync();"		id="btnSync"><spring:message code="Cache.ACC_btn_sync"/></a>
				</div>
				<!-- 상단 버튼 끝 -->
			</div>
			<div id="searchbar1" class="bodysearch_Type01">
				<div class="inPerView type07">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.ACC_lbl_company'/> <!-- 회사 -->
							</span>
							<span id="companyCode" class="selectType02" onchange="CostCenter.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.ACC_lbl_division'/> <!-- 구분 -->
							</span>
							<span id="searchType" class="selectType02">
							</span>
							<input onkeydown="CostCenter.onenter()" id="searchStr" type="text" placeholder="">
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="CostCenter.searchList('Y');"><spring:message code='Cache.ACC_btn_search'/></a>
					</div>
				</div>
			</div>
			<div id="searchbar2" class="bodysearch_Type01">
				<div class="inPerView type07">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.ACC_lbl_costCenterType'/> <!-- CostCenter 구분 --> 
							</span>
							<input onkeydown="CostCenter.onenter()" id="soapCostCenterType" type="text" placeholder="">
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.ACC_lbl_costCenterName'/> <!-- CostCenter명 -->
							</span>
							<input onkeydown="CostCenter.onenter()" id="soapCostCenterName" type="text" placeholder="">
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="CostCenter.searchList('Y');"><spring:message code='Cache.ACC_btn_search'/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">
					<span id="listCount" class="selectType02 listCount" onchange="CostCenter.searchList('Y');">
					</span>
					<button class="btnRefresh" type="button" onclick="CostCenter.searchList('Y');"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>
	
	if (!window.CostCenter) {
		window.CostCenter = {};
	}
	
	(function(window) {
		var CostCenter = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
			
				pageInit : function() {
					var me = this;
					setPropertySearchType('CostCenter','searchProperty');
					setPropertySyncType('CostCenter','syncProperty');
					setHeaderTitle('headerTitle');
					
					accountCtrl.getInfo('saveProperty').val(Common.getBaseConfig("eAccCostCenterAutoCode"));
					
					me.setPageViewController();
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
					var searchProperty	= accountCtrl.getInfo("searchProperty").val();
					var syncProperty	= accountCtrl.getInfo("syncProperty").val();
					
					if(	searchProperty == "SAP"){
						accountCtrl.getInfo("btnAdd").css("display",		"none");
						accountCtrl.getInfo("btnDel").css("display",		"none");
						accountCtrl.getInfo("btnExcelUp").css("display",	"none");
						accountCtrl.getInfo("btnSync").css("display",		"none");
						accountCtrl.getInfo("searchbar2").show();
						accountCtrl.getInfo("searchbar1").hide();
						
					}else if(	searchProperty == "SOAP"){
						accountCtrl.getInfo("btnAdd").css("display",		"none");
						accountCtrl.getInfo("btnDel").css("display",		"none");
						accountCtrl.getInfo("btnExcelUp").css("display",	"none");
						accountCtrl.getInfo("btnSync").css("display",		"none");
						accountCtrl.getInfo("searchbar2").show();
						accountCtrl.getInfo("searchbar1").hide();
						
					}else{
						accountCtrl.getInfo("btnAdd").css("display",		"");
						accountCtrl.getInfo("btnDel").css("display",		"");
						accountCtrl.getInfo("btnExcelUp").css("display",	"");
						accountCtrl.getInfo("btnSync").css("display",		"");
						accountCtrl.getInfo("searchbar1").show();
						accountCtrl.getInfo("searchbar2").hide();
					}
					
					if(syncProperty == "") {
						accountCtrl.getInfo("btnSync").css("display", "none");
					}
				},
		
				setSelectCombo : function(pCompanyCode){
					accountCtrl.getInfo("listCount").children().remove();
					accountCtrl.getInfo("searchType").children().remove();
					
					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "CostCenter.searchList('Y');");
					accountCtrl.getInfo("searchType").addClass("selectType02");
					
					var AXSelectMultiArr	= [	
								{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
							,	{'codeGroup':'ccSearchType',	'target':'searchType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
							,	{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
	   				]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},
				
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("companyCode");
					accountCtrl.refreshAXSelect("searchType");
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
				},
				
				setHeaderData : function() {
					var me = this;
					var searchProperty	= accountCtrl.getInfo("searchProperty").val();
					
					if(searchProperty == "SAP"){
						me.params.headerData = [	{	key:'CostCenterCode',		label:"<spring:message code='Cache.ACC_lbl_costCenterCode' />",		width:'70', align:'center'},	//CostCenter코드
													{	key:'CostCenterName',		label:"<spring:message code='Cache.ACC_lbl_costCenterName' />",		width:'70', align:'center'}		//CostCenter명
												]
						
						me.params.headerDataExcel = [	{	key:'CostCenterCode',		label:"<spring:message code='Cache.ACC_lbl_costCenterCode' />",		width:'70', align:'center'},	//CostCenter코드
														{	key:'CostCenterName',		label:"<spring:message code='Cache.ACC_lbl_costCenterName' />",		width:'70', align:'center'}		//CostCenter명
												]
					}else if(searchProperty == "SOAP"){
						me.params.headerData = [	{	key:'CostCenterTypeName',	label:"<spring:message code='Cache.ACC_lbl_costCenterType' />",		width:'50', align:'center'}, //CostCenter구분
													{	key:'CostCenterCode',		label:"<spring:message code='Cache.ACC_lbl_costCenterCode' />",		width:'70', align:'center'}, //CostCenter코드
													{	key:'CostCenterName',		label:"<spring:message code='Cache.ACC_lbl_costCenterName' />",		width:'70', align:'center'}, //CostCenter명
													{	key:'UsePeriod',			label:"<spring:message code='Cache.ACC_lbl_usePeriod' />",			width:'70', align:'center'}, //사용기간
													{	key:'IsUse',				label:"<spring:message code='Cache.ACC_lbl_isUse' />",				width:'70', align:'center'}, //사용여부
													{	key:'RegisterName',			label:"<spring:message code='Cache.ACC_lbl_registerName' />",		width:'70', align:'center'}, //등록자
													{	key:'RegistDate',			label:"<spring:message code='Cache.ACC_lbl_registDate' />",			width:'70', align:'center'}	 //등록일자
												]
						
						me.params.headerDataExcel = [	{	key:'CostCenterTypeName',	label:"<spring:message code='Cache.ACC_lbl_costCenterType' />",	width:'50', align:'center'},	//CostCenter구분
														{	key:'CostCenterCode',		label:"<spring:message code='Cache.ACC_lbl_costCenterCode' />",	width:'70', align:'center'},	//CostCenter코드
														{	key:'CostCenterName',		label:"<spring:message code='Cache.ACC_lbl_costCenterName' />",	width:'70', align:'center'},	//CostCenter명
														{	key:'UsePeriod',			label:"<spring:message code='Cache.ACC_lbl_usePeriod' />",		width:'70', align:'center'},	//사용기간
														{	key:'IsUse',				label:"<spring:message code='Cache.ACC_lbl_isUse' />",			width:'70', align:'center'},	//사용여부
														{	key:'RegisterName',			label:"<spring:message code='Cache.ACC_lbl_registerName' />",		width:'70', align:'center'}, //등록자
														{	key:'RegistDate',			label:"<spring:message code='Cache.ACC_lbl_registDate' />",			width:'70', align:'center'}	 //등록일자
													]
					}else{
						me.params.headerData = [	{	key:'chk',					label:'chk',			width:'20', align:'center',
														formatter:'checkbox'
													},
													{	key:"CompanyName",			label:"<spring:message code='Cache.ACC_lbl_company' />",			width:'50',	align:'center'},	//회사
													{	key:'CostCenterTypeName',	label:"<spring:message code='Cache.ACC_lbl_costCenterType' />",		width:'50', align:'center'},	//CostCenter구분
													{	key:'CostCenterCode',		label:"<spring:message code='Cache.ACC_lbl_costCenterCode' />",		width:'70', align:'center',		//CostCenter코드
														formatter:function () {
															var rtStr =	""
																		+	"<a onclick='CostCenter.costCenterUpdatePopup(\""+ this.item.CostCenterID +"\",\""+ this.item.CostCenterType +"\"); return false;'>"
																		+		"<font color='blue'>"
																		+			this.item.CostCenterCode
																		+		"</font>"
																		+	"</a>";
															return rtStr;
														}
													},
													{	key:'CostCenterName',		label:"<spring:message code='Cache.ACC_lbl_costCenterName' />",		width:'70', align:'center'},	//CostCenter명
													{	key:'UsePeriod',			label:"<spring:message code='Cache.ACC_lbl_usePeriod' />",			width:'70', align:'center'},	//사용기간
													{	key:'IsUse',				label:"<spring:message code='Cache.ACC_lbl_isUse' />",				width:'30', align:'center',		//사용여부
														formatter:function () {
																var col			= 'IsUse'
																var key			= this.item.CostCenterID;
																var value		= this.item.IsUse;
																var on_value	= 'Y';
																var off_value	= 'N';
																var onchangeFn	= 'CostCenter.costCenterUpdateIsUse(\"'+ this.item.CostCenterCode +'\",\"'+this.item.IsUse+'\")';
															return accountCtrl.getGridSwitch(col,key,value,on_value,off_value,onchangeFn);
														}
													},
													{	key:'RegisterName',			label:"<spring:message code='Cache.ACC_lbl_registerName' />",		width:'70', align:'center'},	//등록자
													{	key:'RegistDate',			label:"<spring:message code='Cache.ACC_lbl_registDate' />"+Common.getSession("UR_TimeZoneDisplay"),			width:'70', align:'center',
								        				formatter:function(){
								        					return CFN_TransLocalTime(this.item.RegistDate,_ServerDateSimpleFormat);
								        				}, dataType:'DateTime'
													}		//등록일
												]
						
						me.params.headerDataExcel = [	{	key:'chk',					label:'chk',			width:'20', align:'center',
															formatter:'checkbox'
														},
														{	key:'CompanyCode',			label:"<spring:message code='Cache.ACC_lbl_company' />",		width:'50', align:'center'}, //회사
														{	key:'CostCenterTypeName',	label:"<spring:message code='Cache.ACC_lbl_costCenterType' />",	width:'50', align:'center'}, //CostCenter구분
														{	key:'CostCenterCode',		label:"<spring:message code='Cache.ACC_lbl_costCenterCode' />",	width:'70', align:'center'}, //CostCenter코드
														{	key:'CostCenterName',		label:"<spring:message code='Cache.ACC_lbl_costCenterName' />",	width:'70', align:'center'}, //CostCenter명
														{	key:'NameCode',				label:"<spring:message code='Cache.ACC_lbl_projectCode' />",	width:'70', align:'center'}, //프로젝트 코드
														{	key:'UsePeriod',			label:"<spring:message code='Cache.ACC_lbl_usePeriod' />",		width:'70', align:'center'}, //사용기간
														{	key:'IsUse',				label:"<spring:message code='Cache.ACC_lbl_isUse' />",			width:'30', align:'center'}, //사용여부
														{	key:'Description',			label:"<spring:message code='Cache.ACC_lbl_description' />",	width:'70', align:'center'}, //비고
														{	key:'IsPermanent',			label:"<spring:message code='Cache.ACC_lbl_permanentUse' />",	width:'70', align:'center'}, //영구사용
														{	key:'RegisterID',			label:"<spring:message code='Cache.ACC_lbl_registerName' />",	width:'70', align:'center'}, //등록자
														{	key:'RegistDate',			label:"<spring:message code='Cache.ACC_lbl_registDate' />"+Common.getSession("UR_TimeZoneDisplay"),	width:'70', align:'center',
									        				formatter:function(){
									        					return CFN_TransLocalTime(this.item.RegistDate,_ServerDateSimpleFormat);
									        				}, dataType:'DateTime'
														}		//등록일
													]
					}
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var searchType		= accountCtrl.getComboInfo("searchType").val();
					var searchStr		= accountCtrl.getInfo("searchStr").val();
					var companyCode		= accountCtrl.getComboInfo("companyCode").val();

					var searchProperty		= accountCtrl.getInfo("searchProperty").val();
					var soapCostCenterType	= accountCtrl.getInfo("soapCostCenterType").val();
					var soapCostCenterName	= accountCtrl.getInfo("soapCostCenterName").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/costCenter/getCostCenterlist.do";
					var ajaxPars		= {	"searchType"	: searchType
										,	"searchStr"		: searchStr
										,	"companyCode"	: companyCode
										,	"searchProperty"	: searchProperty
										,	"soapCostCenterType": soapCostCenterType
										,	"soapCostCenterName": soapCostCenterName
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
				
				costCenterDel : function(){
					var me = this;
					
					var deleteObj = me.params.gridPanel.getCheckedList(0);
					if(deleteObj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_nodataDelete' />");	//삭제할 항목을 선택해주세요.
						return;
					}else{
						
						Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//삭제하시겠습니까?
							if(result){
								var deleteSeq = "";
								for(var i=0; i<deleteObj.length; i++){
									if(i==0){
										deleteSeq = deleteObj[i].CostCenterID;
									}else{
										deleteSeq = deleteSeq + "," + deleteObj[i].CostCenterID;
									}
								}
								
								CostCenter.params.gridPanel.removedList = deleteObj;
								
								$.ajax({
									url	:"/account/costCenter/deleteCostCenterInfo.do",
									type: "POST",
									data: {
											"deleteSeq" : deleteSeq
									},
									success:function (data) {
										if(data.status == "SUCCESS"){
											Common.Inform("<spring:message code='Cache.ACC_msg_delComp' />");	//삭제되었습니다
											CostCenter.searchList('N');
										}else{
											Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의바랍니다.
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
				
				costCenterSync : function(){
					$.ajax({
						url	: "/account/costCenter/costCenterSync.do",
						type: "POST",
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_syncComp' />"); //동기화되었습니다
								CostCenter.searchList('N');
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 	
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}
					});
				},
				
				excelUpload : function(){
					var searchProperty	= accountCtrl.getInfo("searchProperty").val();
					var popupID		= "costCenterExcelPopup";
					var openerID	= "CostCenter";
					var popupTit	= "CostCenter Excel UpLoad";
					var popupYN		= "N";
					var callBack	= "costCenterExcelPopup_CallBack";
					var popupUrl	= "/account/costCenter/costCenterExcelPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack;
					
					Common.open("", popupID, popupTit, popupUrl, "500px", "220px", "iframe", true, null, null, true);
				},
				
				costCenterExcelPopup_CallBack : function(){
					var me = this;
					me.searchList();
				},
				
				excelDownload : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
							var headerName	= accountCommon.getHeaderNameForExcel(me.params.headerDataExcel);
							var headerKey	= accountCommon.getHeaderKeyForExcel(me.params.headerDataExcel);
							var searchType	= accountCtrl.getComboInfo("searchType").val();
							var searchStr	= accountCtrl.getInfo("searchStr").val();
							var companyCode	= accountCtrl.getComboInfo("companyCode").val();
							
							var searchProperty		= accountCtrl.getInfo("searchProperty").val();
							var soapCostCenterType	= accountCtrl.getInfo("soapCostCenterType").val();
							var soapCostCenterName	= accountCtrl.getInfo("soapCostCenterName").val();
							var headerType				= accountCommon.getHeaderTypeForExcel(me.params.headerDataExcel);
							var title 			= accountCtrl.getInfo("headerTitle").text();
							
							var	locationStr		= "/account/costCenter/costCenterExcelDownload.do?"
												//+ "headerName="		+ encodeURI(headerName)
												+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
												+ "&headerKey="		+ encodeURI(headerKey)
												+ "&searchType="	+ encodeURI(searchType)
												+ "&searchStr="		+ encodeURI(searchStr)
												+ "&companyCode="	+ encodeURI(companyCode)
												+ "&searchProperty="		+ encodeURI(searchProperty)
												+ "&soapCostCenterType="	+ encodeURI(soapCostCenterType)
												+ "&soapCostCenterName="	+ encodeURI(soapCostCenterName)
												//+ "&title="					+ encodeURI(accountCtrl.getInfo("headerTitle").text())
												+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
												+ "&headerType=" + encodeURI(headerType);
							
							location.href = locationStr;
						}
					});
				},
				
				changePopupSize : function(popupID,popupW,popupH){
					accountCtrl.pChangePopupSize(popupID,popupW,popupH);
				},
				
				costCenterAddPopup : function(){
					var mode		= "add";
					var type		= "USER"
					var popupID		= "costCenterPopup";
					var openerID	= "CostCenter";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_costCenterAdd' />"; //CostCenter등록
					var popupYN		= "N";
					var callBack	= "costCenterPopup_CallBack";
					var changeSize	= "changePopupSize"
					var saveProperty= accountCtrl.getInfo("saveProperty").val();
					var popupUrl	= "/account/costCenter/getCostCenterPopup.do?"
									+ "popupID="		+ popupID		+ "&"
									+ "openerID="		+ openerID		+ "&"
									+ "popupYN="		+ popupYN		+ "&"
									+ "callBackFunc="	+ callBack		+ "&"
									+ "changeSizeFunc="	+ changeSize	+ "&"
									+ "type="			+ type			+ "&"
									+ "saveProperty=" + saveProperty+ "&"
									+ "mode="			+ mode;
							
					Common.open("", popupID, popupTit, popupUrl, "650px", "500px", "iframe", true, null, null, true);
				},
				
				costCenterUpdatePopup : function(key,type){
					var mode		= "modify";
					var popupID		= "costCenterPopup";
					var openerID	= "CostCenter";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_costCenterManage' />"; //CostCenter관리
					var popupYN		= "N";
					var callBack	= "costCenterPopup_CallBack";
					var changeSize	= "changePopupSize"
					var popupUrl	= "/account/costCenter/getCostCenterPopup.do?"
									+ "popupID="		+ popupID		+ "&"
									+ "openerID="		+ openerID		+ "&"
									+ "popupYN="		+ popupYN		+ "&"
									+ "callBackFunc="	+ callBack		+ "&"
									+ "changeSizeFunc="	+ changeSize	+ "&"
									+ "costCenterID="	+ key			+ "&"
									+ "type="			+ type			+ "&"
									+ "mode="			+ mode;
					
					var popupH = '0px'
					if(type == 'PROJECT'){
						popupH = '550px';
					}else{
						popupH = '500px';
					}
					
					Common.open("", popupID, popupTit, popupUrl, "620px", popupH, "iframe", true, null, null, true);
				},
				
				costCenterPopup_CallBack : function(){
					var me = this;
					me.searchList();
				},
				
				costCenterUpdateIsUse : function(key,sts){
					
					if(	key	== null || key	== '' ||
						sts	== null	|| sts	== ''){
						return
					}
					
					var costCenterCode	= key;
					var isUse			= "";
					
					if(sts == 'Y'){
						isUse = 'N'
					}else{
						isUse = 'Y'
					}
					
					$.ajax({
						url	: "/account/costCenter/saveCostCenterInfo.do",
						type: "POST",
						data: {
								"costCenterCode"	: costCenterCode
							,	"isUse"			: isUse
							,	"listPage"		: 'Y'
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
								CostCenter.searchList('N');
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
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
						me.searchList('Y');
					}
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.CostCenter = CostCenter;
	})(window);
</script>