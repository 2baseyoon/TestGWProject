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
					<a class="btnTypeDefault btnTypeChk"		onclick="AccountManage.accountManageAddPopup();"	id="btnAdd"><spring:message code="Cache.ACC_btn_add"/></a>
					<!-- 삭제 -->
					<a class="btnTypeDefault"					onclick="AccountManage.accountManageDel();"	id="btnDel"><spring:message code="Cache.ACC_btn_delete"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"					onclick="AccountManage.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"			onclick="AccountManage.excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 엑셀업로드 -->
					<a class="btnTypeDefault btnExcel_upload"	onclick="AccountManage.excelUpload();"	id="btnExcelUp"><spring:message code="Cache.ACC_lbl_excelUpload"/></a>
					<!-- 동기화 -->
					<a class="btnTypeDefault"					onclick="AccountManage.accountManageSync();"	id="btnSync"><spring:message code="Cache.ACC_btn_sync"/></a>
				</div>
				<!-- 상단 버튼 끝 -->
			</div>
			
			<div id="searchBar1" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_company"/>	<!-- 회사 -->
							</span>
							<span id="companyCode" class="selectType02" onchange="AccountManage.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_accountClass"/>		<!-- 계정유형 -->
							</span>
							<span id="accountClass" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_division"/>	<!-- 구분 -->
							</span>
							<span id="searchType" class="selectType02">
							</span>
							<input onkeydown="AccountManage.onenter()" id="searchStr" type="text" placeholder="">
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_taxType"/>		<!-- 부가세 -->
							</span>
							<span id="taxType" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_taxCode"/>		<!-- 과세유형 -->
							</span>
							<span id="taxCode" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_isUse"/>	<!-- 사용여부 -->
							</span>
							<span id="isUse" class="selectType02">
							</span>
						</div>						
						<a class="btnTypeDefault  btnSearchBlue" onclick="AccountManage.searchList();"><spring:message code='Cache.ACC_btn_search'/></a><!-- 검색 -->
					</div>
				</div>
			</div>
			<div id="searchBar2" class="bodysearch_Type01">
				<div class="inPerView type07">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_accountCode"/>	<!-- 계정코드 -->
							</span>
							<input onkeydown="AccountManage.onenter()" id="soapAccountCD" type="text" placeholder="">
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_accountName"/>	<!-- 계정이름 -->
							</span>
							<input onkeydown="AccountManage.onenter()" id="soapAccountCN" type="text" placeholder="">
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="AccountManage.searchList();"><spring:message code="Cache.ACC_btn_search"/></a>	<!-- 검색 -->
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="AccountManage.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="AccountManage.searchList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>
		
	if (!window.AccountManage) {
		window.AccountManage = {};
	}
	
	(function(window) {
		var AccountManage = {
			params	:{
				gridPanel	: new coviGrid(),
				headerData	: []
			},
			
			pageInit : function() {
				var me = this;
				setPropertySearchType('AccountManage','searchProperty');
				setPropertySyncType('AccountManage','syncProperty');
				setHeaderTitle('headerTitle');
				me.setPageViewController();
				me.setSelectCombo();
				me.setHeaderData();
				me.searchList();
			},
			
			pageView : function() {
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
				}
				
				accountCtrl.refreshGrid(gridParams);
			},
			
			setPageViewController :function(){
				var searchProperty	= accountCtrl.getInfo("searchProperty").val();
				var syncProperty	= accountCtrl.getInfo("syncProperty").val();
				
				if(	searchProperty == "SAP"){
					//SAP가 추가될 경우 이곳에 정의
					accountCtrl.getInfo("btnAdd").css("display",		"none");
					accountCtrl.getInfo("btnDel").css("display",		"none");
					accountCtrl.getInfo("btnExcelUp").css("display",	"none");
					accountCtrl.getInfo("btnSync").css("display",		"none");
					accountCtrl.getInfo("searchBar1").css("display",	"none");
					accountCtrl.getInfo("searchBar2").css("display",	"");
					
				}else if(searchProperty == "SOAP"){
					accountCtrl.getInfo("btnAdd").css("display",		"none");
					accountCtrl.getInfo("btnDel").css("display",		"none");
					accountCtrl.getInfo("btnExcelUp").css("display",	"none");
					accountCtrl.getInfo("btnSync").css("display",		"none");
					accountCtrl.getInfo("searchBar1").css("display",	"none");
					accountCtrl.getInfo("searchBar2").css("display",	"");
					
				}else{
					accountCtrl.getInfo("btnAdd").css("display",		"");
					accountCtrl.getInfo("btnDel").css("display",		"");
					accountCtrl.getInfo("btnExcelUp").css("display",	"");
					accountCtrl.getInfo("btnSync").css("display",		"");
					accountCtrl.getInfo("searchBar1").css("display",	"");
					accountCtrl.getInfo("searchBar2").css("display",	"none");
				}
				
				if(syncProperty == "") {
					accountCtrl.getInfo("btnSync").css("display", "none");
				}
			},
			
			setSelectCombo : function(pCompanyCode){
				accountCtrl.getInfo("listCount").children().remove();
				accountCtrl.getInfo("accountClass").children().remove();
				accountCtrl.getInfo("TaxType").children().remove();
				accountCtrl.getInfo("TaxCode").children().remove();
				accountCtrl.getInfo("isUse").children().remove();
				accountCtrl.getInfo("searchType").children().remove();

				accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "AccountManage.searchList()");
				accountCtrl.getInfo("accountClass").addClass("selectType02");
				accountCtrl.getInfo("TaxType").addClass("selectType02");
				accountCtrl.getInfo("TaxCode").addClass("selectType02");
				accountCtrl.getInfo("isUse").addClass("selectType02");
				accountCtrl.getInfo("searchType").addClass("selectType02");
				
				var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'AccountClass',	'target':'accountClass',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"} //전체
						,	{'codeGroup':'TaxType',			'target':'taxType',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'TaxCode',			'target':'taxCode',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'IsUse',			'target':'isUse',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'amSearchType',	'target':'searchType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
					]
				
				if(pCompanyCode != undefined) {
					AXSelectMultiArr.pop(); //CompanyCode 제외
				}
				
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
			},
			
			refreshCombo : function(){
				accountCtrl.refreshAXSelect("accountClass");
				accountCtrl.refreshAXSelect("companyCode");
				accountCtrl.refreshAXSelect("isUse");
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
					me.params.headerData = [	{	key:'AccountCode',		label:"<spring:message code='Cache.ACC_lbl_accountCode' />",		width:'70', align:'center'},	//계정코드
												{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_accountName' />",		width:'70', align:'left'}		//계정이름
											]
				}else if(searchProperty == "SOAP"){
					me.params.headerData = [	{	key:'AccountCode',		label:"<spring:message code='Cache.ACC_lbl_accountCode' />",		width:'70', align:'center'},	//계정코드
												{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_accountName' />",		width:'70', align:'left'},		//계정이름
												{	key:'AccountShortName',	label:"<spring:message code='Cache.ACC_lbl_shortName' />",		width:'70', align:'left'},		//단축명
												{	key:'AccountClassName',	label:"<spring:message code='Cache.ACC_lbl_accountClass' />",	width:'70', align:'center'},	//계정유형
												{	key:'IsUse',			label:"<spring:message code='Cache.ACC_lbl_isUse' />",			width:'70', align:'center'},	//사용여부
												{	key:'RegistDate',		label:"<spring:message code='Cache.ACC_lbl_registDate' />",		width:'70', align:'center'}		//등록일자
											]
				}else{
					me.params.headerData = [	{	key:'chk',				label:'chk',		width:'20', align:'center',
													formatter:'checkbox'
												},
												{	key:'CompanyName',		label:"<spring:message code='Cache.ACC_lbl_company' />",			width:'50', align:'center'},	//회사
												{	key:'AccountCode',		label:"<spring:message code='Cache.ACC_lbl_accountCode' />",		width:'70', align:'center',		//계정코드
													formatter:function () {
														var rtStr =	""
																	+	"<a onclick='AccountManage.accountManagePopup(\""+ this.item.AccountID +"\",\""+this.item.AccountCode+"\"); return false;'>"
																	+		"<font color='blue'>"
																	+			this.item.AccountCode
																	+		"</font>"
																	+	"</a>";
														return rtStr;
													}
												},
												{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_accountName' />",	width:'70', align:'center'},	//계저이름
												{	key:'AccountShortName',	label:"<spring:message code='Cache.ACC_lbl_shortName' />",		width:'70', align:'center'},	//단축명
												{	key:'AccountClassName',	label:"<spring:message code='Cache.ACC_lbl_accountClass' />",	width:'70', align:'center'},	//계정유형
												{	key:'TaxTypeName',		label:"<spring:message code='Cache.ACC_lbl_taxType' />",		width:'70', align:'center'},	//부가세
												{	key:'TaxCodeName',		label:"<spring:message code='Cache.ACC_lbl_taxCode' />",		width:'70', align:'center'},	//과세유형
												{	key:'IsUse',			label:"<spring:message code='Cache.ACC_lbl_isUse' />",			width:'70', align:'center',		//사용여부
													formatter:function () {
															var col			= 'IsUse'
															var key			= this.item.AccountID;
															var value		= this.item.IsUse;
															var on_value	= 'Y';
															var off_value	= 'N';
															var onchangeFn	= 'AccountManage.accountManageIsUse(\"'+ this.item.AccountID +'\",\"'+this.item.IsUse+'\")';
														return accountCtrl.getGridSwitch(col,key,value,on_value,off_value,onchangeFn);
													}
												},
												{	key:'RegistDate',		label:"<spring:message code='Cache.ACC_lbl_registDate' />"+Common.getSession("UR_TimeZoneDisplay"),		width:'70', align:'center',
							        				formatter:function(){
							        					return CFN_TransLocalTime(this.item.RegistDate,_ServerDateSimpleFormat);
							        				}, dataType:'DateTime'													
												}		//등록일자
											];
					me.params.headerDataExcel = [	{	key:'CompanyName',		label:"<spring:message code='Cache.ACC_lbl_company' />",		width:'50', align:'center'},	//회사
													{	key:'AccountCode',		label:"<spring:message code='Cache.ACC_lbl_accountCode' />",	width:'70', align:'center'},	//계정코드
													{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_accountName' />",	width:'70', align:'center'},	//계저이름
													{	key:'AccountShortName',	label:"<spring:message code='Cache.ACC_lbl_shortName' />",		width:'70', align:'center'},	//단축명
													{	key:'AccountClassName',	label:"<spring:message code='Cache.ACC_lbl_accountClass' />",	width:'70', align:'center'},	//계정유형
													{	key:'TaxTypeName',		label:"<spring:message code='Cache.ACC_lbl_taxType' />",		width:'70', align:'center'},	//부가세
													{	key:'TaxCodeName',		label:"<spring:message code='Cache.ACC_lbl_taxCode' />",		width:'70', align:'center'},	//과세유형
													{	key:'TaxType',			label:"<spring:message code='Cache.ACC_lbl_taxType' />"+"(<spring:message code='Cache.lbl_apv_Code' />)",		width:'70', align:'center'},	//부가세(코드)
													{	key:'TaxCode',			label:"<spring:message code='Cache.ACC_lbl_taxCode' />"+"(<spring:message code='Cache.lbl_apv_Code' />)",		width:'70', align:'center'},	//과세유형(코드)
													{	key:'IsUse',			label:"<spring:message code='Cache.ACC_lbl_isUse' />",			width:'70', align:'center'},	//사용여부
													{	key:'RegistDate',		label:"<spring:message code='Cache.ACC_lbl_registDate' />"+Common.getSession("UR_TimeZoneDisplay"),			width:'70', align:'center'}	//등록일자
												]
				}
				
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},
			
			searchList : function(YN){
				var me = this;
				
				me.setHeaderData();
				
				var companyCode		= accountCtrl.getComboInfo("companyCode").val();	//회사 코드
				var accountClass	= accountCtrl.getComboInfo("accountClass").val();	//계정유형
				var searchType		= accountCtrl.getComboInfo("searchType").val();		//구분
				var taxType			= accountCtrl.getComboInfo("taxType").val();		//부가세
				var taxCode			= accountCtrl.getComboInfo("taxCode").val();		//과세유형
				var isUse			= accountCtrl.getComboInfo("isUse").val();			//사용 여부
				var searchStr		= accountCtrl.getInfo("searchStr").val();			//조회문장
				
				var searchProperty	= accountCtrl.getInfo("searchProperty").val();
				var soapAccountCD	= accountCtrl.getInfo("soapAccountCD").val();
				var soapAccountCN	= accountCtrl.getInfo("soapAccountCN").val();
				
				var gridAreaID		= "gridArea";
				var gridPanel		= me.params.gridPanel;
				var gridHeader		= me.params.headerData;
				var ajaxUrl			= "/account/accountManage/getAccountManagelist.do";
				var ajaxPars		= {	"searchProperty": searchProperty
									,	"companyCode"	: companyCode
									,	"accountClass"	: accountClass
					 				,	"searchType"	: searchType
					 				,	"taxCode"		: taxCode
					 				,	"taxType"		: taxType
					 				,	"isUse"			: isUse
					 				,	"searchStr"		: searchStr
					 				,	"soapAccountCD"	: soapAccountCD
					 				,	"soapAccountCN"	: soapAccountCN
					};
				
				var pageNoInfo	= 1;
				if(YN= 'Y'){
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
			
			accountManageDel : function(){
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
									deleteSeq = deleteObj[i].AccountID;
								}else{
									deleteSeq = deleteSeq + "," + deleteObj[i].AccountID;
								}
							}
							$.ajax({
								url	:"/account/accountManage/deleteAccountManageInfo.do",
								type: "POST",
								data: {
										"deleteSeq" : deleteSeq
								},
								success:function (data) {
									if(data.status == "SUCCESS"){
										Common.Inform("<spring:message code='Cache.ACC_msg_delComp' />")		//삭제되었습니다.
										AccountManage.searchList();
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
				var popupID		= "accountManageExcelPopup";
				var openerID	= "AccountManage";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_accountModify' />";	//계정관리
				var popupYN		= "N";
				var callBack	= "accountManageExcelPopup_CallBack";
				var popupUrl	= "/account/accountManage/accountManageExcelPopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "callBackFunc="	+ callBack;
				
				Common.open("", popupID, popupTit, popupUrl, "500px", "220px", "iframe", true, null, null, true);
			},
			
			accountManageExcelPopup_CallBack : function(){
				var me = this;
				me.searchList();
			},
			
			accountManageSync : function(){
				$.ajax({
					url	: "/account/accountManage/accountManageSync.do",
					type: "POST",
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.ACC_msg_syncComp' />");	//동기화되었습니다.
							AccountManage.searchList('N');
						}else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");		//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
					}
				});
			},
			
			excelDownload : function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
		       		if(result){
						var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerDataExcel);
						var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerDataExcel);
						var companyCode		= accountCtrl.getComboInfo("companyCode").val();	//회사 코드
						var accountClass	= accountCtrl.getComboInfo("accountClass").val();	//계정유형
						var searchType		= accountCtrl.getComboInfo("searchType").val();		//구분
						var taxCode			= accountCtrl.getComboInfo("taxCode").val();		//부가세
						var taxType			= accountCtrl.getComboInfo("taxType").val();		//과세유형
						var isUse			= accountCtrl.getComboInfo("isUse").val();			//사용 여부
						var searchStr		= accountCtrl.getInfo("searchStr").val();			//조회문장
						var searchProperty	= accountCtrl.getInfo("searchProperty").val();
						var soapAccountCD	= accountCtrl.getInfo("soapAccountCD").val();
						var soapAccountCN	= accountCtrl.getInfo("soapAccountCN").val();
						var headerType = accountCommon.getHeaderTypeForExcel(me.params.headerDataExcel);   //그리드에 정의된 데이타타입 가져오기
						var title 			= accountCtrl.getInfo("headerTitle").text();
						
						var	locationStr		= "/account/accountManage/accountManageExcelDownload.do?"
											//+ "headerName="		+ encodeURI(headerName)
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="		+ encodeURI(headerKey)
											+ "&companyCode="	+ encodeURI(companyCode)
											+ "&accountClass="	+ encodeURI(accountClass)
											+ "&searchType="	+ encodeURI(searchType)
											+ "&taxCode="		+ encodeURI(taxCode)
											+ "&taxType="		+ encodeURI(taxType)
											+ "&isUse="			+ encodeURI(isUse)
											+ "&searchProperty="+ encodeURI(searchProperty)
											+ "&searchStr="		+ encodeURI(searchStr)
											+ "&soapAccountCD="	+ encodeURI(soapAccountCD)
											+ "&soapAccountCN="	+ encodeURI(soapAccountCN)
											//+ "&title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text())
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
											+ "&headerType=" + encodeURI(headerType);
						
						location.href = locationStr;
		       		}
		       	});
			},
			
			accountManageAddPopup : function(){
				var mode		= "add";
				var popupID		= "accountPopup";
				var openerID	= "AccountManage";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_accountAdd' />";
				var popupYN		= "N";
				var callBack	= "accountManage_CallBack";
				var popupUrl	= "/account/accountManage/getAccountManagePopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "callBackFunc="	+ callBack	+ "&"
								+ "mode="			+ mode;
				
				Common.open("", popupID, popupTit, popupUrl, "520px", "600px", "iframe", true, null, null, true);
			},
			
			accountManagePopup : function(key,code){
				var mode		= "modify";
				var popupID		= "accountPopup";
				var openerID	= "AccountManage";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_accountModify' />";
				var popupYN		= "N";
				var callBack	= "accountManage_CallBack";
				var popupUrl	= "/account/accountManage/getAccountManagePopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "callBackFunc="	+ callBack	+ "&"
								+ "accountID="		+ key		+ "&"
								+ "mode="			+ mode;
				
				Common.open("", popupID, popupTit, popupUrl, "520px", "600px", "iframe", true, null, null, true);
			},
			
			accountManage_CallBack :function(){
				var me = this;
				me.searchList();
			},
			
			accountManageIsUse : function(key,sts){
				
				if(	key	== null || key	== '' ||
					sts	== null	|| sts	== ''){
					return
				}
				
				var accountID	= key;
				var isUse		= "";
				
				if(sts == 'Y'){
					isUse = 'N'
				}else{
					isUse = 'Y'
				}
				
				$.ajax({
					url	: "/account/accountManage/saveAccountManageInfo.do",
					type: "POST",
					data: {
							"accountID"	: accountID
						,	"isUse"		: isUse
						,	"listPage"	: 'Y'
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
							AccountManage.searchList();
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
		window.AccountManage = AccountManage;
	})(window);
</script>