<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.DicHelper
	, egovframework.coviframework.util.RedisDataUtil
	,egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	.pad10 { padding:10px;}
	
</style>
<%
String IsUseStandardBrief = RedisDataUtil.getBaseConfig("IsUseStandardBrief");
String StandardBriefTag = "";
if (!IsUseStandardBrief.equals("Y")) {
	out.println("<style>.StandardBrief{display:none}</style>");
	StandardBriefTag = ",display:false";
}
%>
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
					<a class="btnTypeDefault btnTypeChk"		onclick="BudgetRegist.openBudgetRegistAddPopup();"	id="btnAdd"><spring:message code="Cache.btn_Add"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"					onclick="BudgetRegist.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 예산삭제 -->
					<a class="btnTypeDefault"					onclick="BudgetRegist.deleteBudgetRegist()"><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_delete' /></a>
										
				</div>
				<!-- 상단 버튼 끝 -->
			
				<div class="buttonStyleBoxRight">	
					<!-- 엑셀업로드 -->
					<a class="btnTypeDefault btnExcel_upload"	onclick="BudgetRegist.uploadExcel();"	id="btnExcelUp"><spring:message code="Cache.lbl_ExcelUpload"/></a>
					<!-- 템플릿 다운로드 -->
					<a href="#" id="btnExcelTemplate" class="btnTypeDefault btnExcel" onclick="BudgetRegist.downloadTemplate();"><spring:message code='Cache.lbl_templatedownload'/></a>	
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"			onclick="BudgetRegist.downloadExcel();"><spring:message code="Cache.btn_ExcelDownload"/></a>
				</div>
			</div>
			
			<div id="searchBar1" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:100%;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.lbl_CorpName' />	<!-- 회사명 -->
							</span>
							<span id="companyCode" class="selectType02"></span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_division"/>	<!-- 구분 -->
							</span>
							<span id="searchType" class="selectType02"></span>
							<input onkeydown="BudgetRegist.onEnter()" id="searchStr" type="text" placeholder="">
						</div>
					</div>
					<div style="width:100%;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_apv_vacation_year' />	<!-- 예산년도 -->
							</span>
							<select  class="selectType02" id="fiscalYear"></select>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.lbl_Period' /><spring:message code="Cache.lbl_Division2"/>		<!-- 기한구분 -->
							</span>
							<span id="baseTerm" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit" style="width:90px">
								<spring:message code="Cache.ACC_lbl_DeptUser"/>	<!-- 부서/사용자  -->
							</span>
							<input id="costCenterName" class="sm" type="text" placeholder=""  onkeydown="BudgetRegist.onEnter()">
						</div>
					</div>
					<div style="width:100%;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.ACC_lbl_budgetType' />	<!-- 예산타입 -->
							</span>
							<span id="costCenterType" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_control"/>	<!-- 통제 -->
							</span>
							<span id="isControl" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit" style="width:90px">
								<spring:message code="Cache.ACC_lbl_isUse" />	<!-- 사용여부 -->
							</span>
							<span id="isUse" class="selectType02">
							</span>
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="BudgetRegist.searchList();"><spring:message code='Cache.ACC_btn_search'/></a><!-- 검색 -->
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="BudgetRegist.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="BudgetRegist.searchList();"></button>
				</div>
			</div>
			<div id="gaBudgetRegist" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

	if (!window.BudgetRegist) {
		window.BudgetRegist = {};
	}
	
	(function(window) {
		var BudgetRegist = {
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
				
				var gridAreaID		= "gaBudgetRegist";
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
			setSelectCombo : function(){
				var Today = new Date();
				var Year = Today.getFullYear()+1;
				var obj = accountCtrl.getInfo("fiscalYear");//$("#fiscalYear");
				
				for (var i = 0; i < 10; i++)
		        {
					var option = $("<option value="+Year+">"+Year+"</option>");
					obj.append(option);
					Year--;
		        }
				obj.val(Today.getFullYear());
				
				var AXSelectMultiArr	= [	
							{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':"<%=SessionHelper.getSession("DN_Code")%>"}
						,	{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'BaseTerm',		'target':'baseTerm',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'BudgetType',		'target':'costCenterType',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'IsUse',			'target':'isControl',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'amSearchType',	'target':'searchType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
					]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				accountCtrl.renderAXSelect("IsUse", "isUse", "ko", "","","","<spring:message code='Cache.ACC_lbl_comboAll' />");
				
				var targetComboID		= accountCtrl.getComboInfo("companyCode")[0].id;
				//$("#" + targetComboID).bindSelectRemoveOptions([{optionValue:'ALL', optionText:''}]);
			},
			
			refreshCombo : function(){
				accountCtrl.refreshAXSelect("listCount");
				accountCtrl.refreshAXSelect("baseTerm");
				accountCtrl.refreshAXSelect("isControl");
				accountCtrl.refreshAXSelect("isUse");
				accountCtrl.refreshAXSelect("searchType");
			},
			
			setHeaderData : function() {
				var me = this;
				me.params.headerData = [	
						   		             {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
						   		            {	key:'CompanyCodeName',	label:"<spring:message code='Cache.lbl_CorpName' />", width:'50', align:'center'},	//회사명 
				                        	{	key:'FiscalYear',	label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_apv_vacation_year' />", width:'50', align:'center'},	//예산년도
				                        	{	key:'CostCenterTypeName',		label:"<spring:message code='Cache.ACC_lbl_budgetType' />",		width:'50', align:'center'}, //예산타입
											{	key:'CostCenterName',		label:"<spring:message code='Cache.ACC_lbl_DeptUser' />",		width:'120', align:'left'	,	//부서/사용자
										    	formatter:function () {
								            		 return "<a onclick='BudgetRegist.openBudgetRegistChangePopup(\"Change\"," + this.item.RegistID + ")';><font color=blue><u>"+this.item.CostCenterName+"</u></font></a>";
								            	}
											},
											{	key:'AccountCode',	label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_lbl_accountCode' />",		width:'70', align:'center'},	//계정과목
											{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_lbl_account' />",		width:'70', align:'left',
										    	formatter:function () {
								            		 return "<a onclick='BudgetRegist.openBudgetRegistChangePopup(\"Change\"," + this.item.RegistID + ")';><font color=blue><u>"+this.item.AccountName+"</u></font></a>";
								            	}
											},	//계정이름
											{	key:'StandardBriefName',	label:"<spring:message code='Cache.ACC_lbl_standardBriefName' />",		width:'150', align:'left', sort:false <%=StandardBriefTag%>},	//표준적요
											{	key:'PeriodLabelName',		label:"<spring:message code='Cache.lbl_Period' /><spring:message code='Cache.lbl_SchDivision' />",		width:'70', align:'center', sort:false}	,	//기간구분
											{	key:'ValidTerm',			label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_Period' />",		width:'130', align:'center', sort:false},		//예산기간
											{	key:'BudgetAmount',	label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_invoice_amount' />",	width:'70', align:'right',	//예산금액
										    	formatter:function () {
								            		 return "<a onclick='BudgetRegist.openBudgetRegistChangePopup(\"Change\"," + this.item.RegistID + ")';><font color=blue><u>"+getAmountValue(this.item.BudgetAmount)+"</u></font></a>";
								            	}
											},
											{	key:'IsControl',			label:"<spring:message code='Cache.ACC_lbl_control' />",			width:'70', align:'center',		//통제유무
												formatter:function () {
														var col			= 'IsControl'
														var key			= 'c_'+this.item.RNum
														var value		= this.item.IsControl;
														var on_value	= 'Y';
														var off_value	= 'N';
														var onchangeFn	= 'BudgetRegist.changeFlag('+ JSON.stringify(this.item) +',\"'+this.item.IsControl+'\", \"C\")';
													return accountCtrl.getGridSwitch(col,key,value,on_value,off_value,onchangeFn);
												}
											},
											{	key:'IsUse',			label:"<spring:message code='Cache.lbl_Use' />",			width:'70', align:'center',		//사용유무
												formatter:function () {
														var col			= 'IsUse'
														var key			= this.item.RNum;
														var value		= this.item.IsUse;
														var on_value	= 'Y';
														var off_value	= 'N';
														var onchangeFn	= 'BudgetRegist.changeFlag('+ JSON.stringify(this.item)+',\"'+this.item.IsUse+'\", \"U\")';
													return accountCtrl.getGridSwitch(col,key,value,on_value,off_value,onchangeFn);
												}
											}
										]
				
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},
			
			searchList : function(YN){
				var me = this;
				me.setHeaderData();

				var companyCode		= accountCtrl.getComboInfo("companyCode").val();	//회사코드
				var fiscalYear		= accountCtrl.getInfo("fiscalYear").val();			//예산년도
				var costCenterName	= accountCtrl.getInfo("costCenterName").val();		//costcenter명
				var baseTerm		= accountCtrl.getComboInfo("baseTerm").val();		//기간
				var isControl		= accountCtrl.getComboInfo("isControl").val();		//통제여부
				var isUse			= accountCtrl.getComboInfo("isUse").val();			//사용 여부
				var costCenterType	= accountCtrl.getComboInfo("costCenterType").val();		//코스트스센터 구분

				var searchType		= accountCtrl.getComboInfo("searchType").val();		//구분
				var searchStr		= accountCtrl.getInfo("searchStr").val();			//조회문장
				
				var gridAreaID		= "gaBudgetRegist";
				var gridPanel		= me.params.gridPanel;
				var gridHeader		= me.params.headerData;
				var ajaxUrl			= "/account/budgetRegist/getBuggetRegistList.do";
				var ajaxPars		= {	"companyCode":companyCode
									,   "fiscalYear"	: fiscalYear//"2020"
					 				,	"costCenterName"	: costCenterName
					 				,	"baseTerm"	: baseTerm
					 				,	"isControl"		: isControl
					 				,	"isUse"			: isUse
									,   "costCenterType": costCenterType
					 				,	"searchType"	: searchType
					 				,	"searchStr"		: searchStr
					};
				
				var pageNoInfo	= 1;
				if(YN== 'Y'){
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
			openBudgetRegistAddPopup : function(){
				var popupID		= "BudgetRegistAddPopup";
				var openerID	= "BudgetRegist";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_Registor' />"+" ["+accountCtrl.getComboInfo("companyCode").find("option:selected").text() +"]";
				var popupYN		= "N";
				var companyCode	= accountCtrl.getComboInfo("companyCode").val();	//회사코드
				var callBack	= "BudgetRegist_CallBack";
				var popupUrl	= "/account/budgetRegist/BudgetRegistAddPopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "companyCode="    + companyCode+ "&"
								+ "callBackFunc="	+ callBack;
				
				Common.open("", popupID, popupTit, popupUrl, "600px", "600px", "iframe", true, null, null, true);
			},
			BudgetRegist_CallBack :function(){
				var me = this;
				me.searchList('Y');
			},
			openBudgetRegistChangePopup : function(chgType, registID){
				var popupID		= "BudgetRegistChangePopup";
				var openerID	= "BudgetRegist";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_change' />";	//계정관리
				var popupYN		= "N";
				var companyCode	= accountCtrl.getComboInfo("companyCode").val();	//회사코드
				var callBack	= "BudgetRegistChangePopup_CallBack";
				var popupUrl	= "/account/budgetRegist/BudgetRegistChangePopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "companyCode="    + companyCode+ "&"
								+ "chgType="        + chgType	+ "&"
								+ "registID="		+ registID	+ "&"
								+ "callBackFunc="	+ callBack;
				Common.open("", popupID, popupTit, popupUrl, "700px", "680px", "iframe", true, null, null, true);
			},
			BudgetRegistChangePopup_CallBack : function(){
				var me = this;
				me.searchList('Y');
			},
			changeFlag : function(key,sts, changeType){
				if(	key	== null || key	== '' ){
					return
				}

				var accountID	= key;
				var isFlag		= "";
				
				if(sts == 'Y'){
					isFlag = 'N'
				}else{
					isFlag = 'Y'
				}
				
				var companyCode     = key.CompanyCode;//회사코드
				var fiscalYear		= key.FiscalYear;	//예산년도
				var costCenter	    = key.CostCenter;	//costcenter
				var accountCode	    = key.AccountCode;	//costcenter
				var standardBriefID	= key.StandardBriefID;	//costcenter
				var baseTerm	    = key.BaseTerm;	//costcenter
				var periodLabel	    = key.PeriodLabel;	//costcenter
				var version	        = key.Version;	//costcenter

								
				
				$.ajax({
					url	: "/account/budgetRegist/changeFlag.do",
					type: "POST",
					data: {
							"companyCode" : companyCode
						,	"fiscalYear"  :fiscalYear
						,	"costCenter"  : costCenter
						,	"accountCode" : accountCode
						,   "standardBriefID" : standardBriefID
						,   "baseTerm"	  : baseTerm
						,   "periodLabel" : periodLabel
						,   "version"     : version
						,   "isFlag"      :isFlag
						,   "changeType"  :changeType
						,	"listPage"	: 'Y'
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_Changed'/>");	//저장되었습니다
							BudgetRegist.searchList('Y');
						}else{
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); 
					}
				});
			},			
			deleteBudgetRegist : function(){	// 삭제
				var me = this;
				var myGrid		= me.params.gridPanel;
				var deleteobj = myGrid.getCheckedList(0);
				var aJsonArray = new Array();
				if(deleteobj.length == 0){
					Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
					return;
				}else{
					for(var i=0; i<deleteobj.length; i++){
						var saveData = {"companyCode" : deleteobj[i].CompanyCode 
								, "fiscalYear":deleteobj[i].FiscalYear
								, "costCenter": deleteobj[i].CostCenter
								, "accountCode": deleteobj[i].AccountCode
								, "standardBriefID": deleteobj[i].StandardBriefID
								, "baseTerm"   : deleteobj[i].BaseTerm
								, "periodLabel": deleteobj[i].PeriodLabel
								, "version"    : deleteobj[i].Version};
                        aJsonArray.push(saveData);
                        
					}
					
					var aJson = { "deleteList": aJsonArray};
					$.ajax({
						type:"POST",
						data:{
							"deleteObj" : JSON.stringify(aJson)
						},
						url:"/account/budgetRegist/deleteBudgetRegist.do",
						success:function (data) {
							if(data.result == "ok"){
								Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_Deleted'/>");	//저장되었습니다.
								me.searchList('Y');
							
							}
							else{
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
						}
					});
				}
			},
			uploadExcel : function(){
				var popupID		= "BudgetRegistExcelPopup";
				var openerID	= "BudgetRegist";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_uploadFile' />";	//계정관리
				var popupYN		= "N";
				var callBack	= "budgetRegistExcelPopup_CallBack";
				var companyCode		= accountCtrl.getComboInfo("companyCode").val();	//회사코드

				var popupUrl	= "/account/budgetRegist/BudgetRegistExcelPopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "companyCode="+ companyCode+ "&"
								+ "callBackFunc="	+ callBack;
				
				Common.open("", popupID, popupTit, popupUrl, "500px", "260px", "iframe", true, null, null, true);
			},
			
			budgetRegistExcelPopup_CallBack : function(){
				var me = this;
				me.searchList('Y');
			},
			refresh : function(){
				accountCtrl.pageRefresh();
			},
			downloadTemplate:function(){
				Common.Confirm("<spring:message code='Cache.msg_bizcard_downloadTemplateFiles'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
		       		if(result){
		       			location.href = '/account/budgetRegist/downloadTemplate.do?';
		       		}
				});
			},
			downloadExcel: function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
		       		if(result){
						var headerName		= BudgetRegist.getHeaderNameForExcel(me.params.headerData);
						var headerKey		= BudgetRegist.getHeaderKeyForExcel(me.params.headerData);
						
						var companyCode		= accountCtrl.getComboInfo("companyCode").val();	//회사코드
						var fiscalYear		= accountCtrl.getInfo("fiscalYear").val();	//예산년도
						var costCenterName	= accountCtrl.getInfo("costCenterName").val();	//costcenter명
						var baseTerm		= accountCtrl.getComboInfo("baseTerm").val();	//기간
						var isControl		= accountCtrl.getComboInfo("isControl").val();		//통제여부
						var isUse			= accountCtrl.getComboInfo("isUse").val();			//사용 여부
						var costCenterType	= accountCtrl.getComboInfo("costCenterType").val();			//코스트스센터 구분

						var searchType		= accountCtrl.getComboInfo("searchType").val();		//구분
						var searchStr		= accountCtrl.getInfo("searchStr").val();			//조회문장
						var title 			= accountCtrl.getInfo("headerTitle").text();

						var	locationStr		= "/account/budgetRegist/downloadExcel.do?"
											//+ "headerName="		+ encodeURI(headerName)
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="		+ encodeURI(headerKey)
											//+ "&title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text())
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
											+ "&companyCode="   + companyCode
											+ "&fiscalYear="	+ fiscalYear
							 				+ "&costCenterName="+ encodeURIComponent(encodeURIComponent(costCenterName))
							 				+ "&baseTerm="	    + baseTerm
							 				+ "&isControl="		+ isControl
							 				+ "&isUse="			+ isUse
											+ "&costCenterType="+ costCenterType
							 				+ "&searchType="	+ searchType
							 				+ "&searchStr="		+ encodeURIComponent(encodeURIComponent(searchStr));
						location.href = locationStr;
		       		}
		       	});
			},
			onEnter : function(){
				var me = this;
				if(event.keyCode=="13"){
					me.searchList();
				}
			}
			,getHeaderNameForExcel:function (headerData){
				var returnStr	= "";
			   	for(var i=0;i<headerData.length; i++){
			   	   	if(headerData[i].display != false && headerData[i].label != 'chk'){
			   	   		returnStr += headerData[i].label + "†";
			   	   	}
				}
				return returnStr;
			},
			getHeaderKeyForExcel:function(headerData){
				var returnStr	= "";
			   	for(var i=0;i<headerData.length; i++){
			   	   	if(headerData[i].display != false && headerData[i].label != 'chk'){
						returnStr += headerData[i].key + ",";
			   	   	}
				}
				return returnStr;
			}
			
		}
		window.BudgetRegist = BudgetRegist;
	})(window);
</script>