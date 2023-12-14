<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.DicHelper
	, egovframework.coviframework.util.RedisDataUtil
	, egovframework.coviframework.util.StringUtil
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

String authMode = StringUtil.replaceNull(request.getParameter("Auth"),"M");
if (authMode.equals("M")) {
	out.println("<style>#account_BudgetUseaccountuserAccountMViewArea .costTypeCls{display:none}</style>");
}
%>
<input id="authMode" type="hidden"  value="<%=authMode%>">
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
					<a class="btnTypeDefault  btnTypeBg"		onclick="BudgetUse.openAddPopup();"	id="btnAdd" style="display:none"><spring:message code="Cache.btn_Add"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"					onclick="BudgetUse.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
				</div>
				<div class="buttonStyleBoxRight">	
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"			onclick="BudgetUse.downloadExcel();"><spring:message code="Cache.btn_ExcelDownload"/></a>
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
							<input onkeydown="BudgetUse.onEnter()" id="searchStr" type="text" placeholder="">
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
								<spring:message code='Cache.ACC_lbl_budgetType' />	<!-- 예산타입 -->
							</span>
							<span id="costCenterType" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit costTypeCls" style="width:90px">
								<spring:message code="Cache.ACC_lbl_DeptUser"/>	<!-- 부서/사용자  -->
							</span>
							<input onkeydown="BudgetUse.onEnter()" id="costCenterName" class="sm costTypeCls" type="text" placeholder="">
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="BudgetUse.searchList();"><spring:message code='Cache.ACC_btn_search'/></a><!-- 검색 -->
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="BudgetUse.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="BudgetUse.searchList();"></button>
				</div>
			</div>
			<div id="gaBudgetUse" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>
	if (!window.BudgetUse) 
	{
		window.BudgetUse = {};
	}
	
	(function(window) {
		var BudgetUse = {
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
				
				var gridAreaID		= "gaBudgetUse";
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
										,	{'codeGroup':'amSearchType',	'target':'searchType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
										,	{'codeGroup':'BudgetType',		'target':'costCenterType',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
									]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				var targetComboID		= accountCtrl.getComboInfo("companyCode")[0].id;
				//$("#" + targetComboID).bindSelectRemoveOptions([{optionValue:'ALL', optionText:''}]);
			},
			refreshCombo : function(){
				accountCtrl.refreshAXSelect("listCount");
				accountCtrl.refreshAXSelect("searchType");
			},
			
			setHeaderData : function() {
				var me = this;
				me.params.headerData = [	{	key:'CompanyCodeName',	label:"<spring:message code='Cache.lbl_CorpName' />", width:'50', align:'center'},	//회사명 
											{	key:'FiscalYear',	label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_apv_vacation_year' />", width:'50', align:'center'},	//예산년도
											{	key:'CostCenterTypeName',		label:"<spring:message code='Cache.ACC_lbl_budgetType' />",		width:'50', align:'center'}, //예산타입
											{	key:'CostCenterName',		label:"<spring:message code='Cache.ACC_lbl_DeptUser' />",		width:'120', align:'left'}	,	//부서/사용자
											{	key:'AccountCode',	label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_lbl_accountCode' />",		width:'70', align:'center'},	//계정과목
											{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_lbl_account' />",		width:'70', align:'left'},	//계정이름
											{	key:'StandardBriefName',	label:"<spring:message code='Cache.ACC_lbl_standardBriefName' />",		width:'150', align:'left', sort:false <%=StandardBriefTag%>},	//계정이름
											{	key:'ExecuteDate',	label:"<spring:message code='Cache.ACC_lbl_realPayDate' />",		width:'70', align:'center'},	//이용일
											{	key:'UsedAmount',	label:"<spring:message code='Cache.lbl_invoice_amount' />",	width:'70', align:'right', formatter:function () {
								                	return String.format("<a onclick=\"BudgetUse.openDetailPopup('{0}')\"><font color=blue><u>"+getAmountValue(this.item.UsedAmount)+"</u></font></a>",this.item.ProcessID); }
								              },	//금액
											{	key:'Description',		label:"<spring:message code='Cache.ACC_lbl_useHistory2' />",		width:'120', align:'left'}	,	//적요
											{	key:'Status',			label:"<spring:message code='Cache.lbl_Status' />",			width:'70', align:'center',
												/*editor: {
					                                type: "select",
					                                optionValue: "Code",
					                                optionText: "CodeName",
					                                options:[
					                                    {CodeName:"반려" , Code: "R"},
					                                    {CodeName:"가집행", Code: "P"},
					                                    {CodeName:"집행", Code: "C"}]
					                                , beforeUpdate: function(val){ // 수정이 되기전 value를 처리 할 수 있음.
														return val;
					                                }, afterUpdate: function(val){ // 수정이 처리된 후
														BudgetUse.changeStatus(this.item.ExecuteID, val);
					                                }

					                            },*/
					                            formatter: function(val){
					                            	switch (this.item.Status)
					                            	{
						                            	case "R":return "반려";break;
						                            	case "P":return "가집행";break;
						                            	case "C":return "집행";break;
						                            	default:return "취소";break;
					                            	}
					                            }
											}		//상태
										]
				
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},
			
			searchList : function(YN){
				var me = this;
				me.setHeaderData();

				var authMode		= accountCtrl.getInfo("authMode").val();	//
				var companyCode		= accountCtrl.getComboInfo("companyCode").val();	//회사코드
				var fiscalYear		= accountCtrl.getInfo("fiscalYear").val();	//예산년도
				var costCenterName	= accountCtrl.getInfo("costCenterName").val();	//costcenter명
				var costCenterType	= accountCtrl.getComboInfo("costCenterType").val();			//코스트스센터 구분

				var searchType		= accountCtrl.getComboInfo("searchType").val();		//구분
				var searchStr		= accountCtrl.getInfo("searchStr").val();			//조회문장
				
				var gridAreaID		= "gaBudgetUse";
				var gridPanel		= me.params.gridPanel;
				var gridHeader		= me.params.headerData;
				var ajaxUrl			= "/account/budgetUse/getBudgetExecuteList.do";
				var ajaxPars		= {	"companyCode":companyCode
									,	"fiscalYear"	: fiscalYear//"2020"
					 				,	"costCenterName"	: costCenterName
									,   "costCenterType": costCenterType
					 				,	"searchType"	: searchType
					 				,	"searchStr"		: searchStr
					 				,   "authMode"      : authMode
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
			changeStatus: function(key,sts, changeType){
				if(	key	== null || key	== '' ){
					return
				}

				var executeID	= key;
				var isFlag		= "";
				
				if(sts == 'Complet'){
					isFlag = 'N'
				}else{
					isFlag = 'Y'
				}
				
				var executeID		= key;	//키
				var status	    = sts;	//costcenter
				
				$.ajax({
					url	: "/account/budgetUse/changeStatus.do",
					type: "POST",
					data: {
							"executeID"  :executeID
						,	"status"  : status
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_Changed'/>");	//저장되었습니다
							BudgetUse.searchList('Y');
						}else{
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); 
					}
				});
			},	
			openAddPopup : function(){
				var mode		= "add";
				var popupID		= "BudgetUseAddPopup";
				var openerID	= "BudgetUse";
				var popupTit	= "<spring:message code='Cache.ACC_msg_usePurpose' /><spring:message code='Cache.lbl_Registor' />";
				var popupYN		= "N";
				var costCenterType	= accountCtrl.getComboInfo("costCenterType").val();			//코스트스센터 구분
				var callBack	= "BudgetUse_CallBack";
				var popupUrl	= "/account/budgetUse/BudgetUseAddPopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "companyCode="    + accountCtrl.getComboInfo("companyCode").val() + "&"
								+ "costCenterType=" + costCenterType+ "&"
								+ "callBackFunc="	+ callBack	+ "&"
								+ "mode="			+ mode;
				
				Common.open("", popupID, popupTit, popupUrl, "600px", "650px", "iframe", true, null, null, true);
			},
			BudgetUse_CallBack :function(){
				var me = this;
				me.searchList('Y');
			},
			downloadExcel: function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
		       		if(result){
						var headerName		= BudgetUse.getHeaderNameForExcel(me.params.headerData);

						var headerKey		= BudgetUse.getHeaderKeyForExcel(me.params.headerData);
						
						var authMode		= accountCtrl.getInfo("authMode").val();	//
						var fiscalYear		= accountCtrl.getInfo("fiscalYear").val();	//예산년도
						var costCenterName	= accountCtrl.getInfo("costCenterName").val();	//costcenter명
						var costCenterType	= accountCtrl.getComboInfo("costCenterType").val();			//코스트스센터 구분

						var searchType		= accountCtrl.getComboInfo("searchType").val();		//구분
						var searchStr		= accountCtrl.getInfo("searchStr").val();			//조회문장
						var title 			= accountCtrl.getInfo("headerTitle").text();

						var	locationStr		= "/account/budgetUse/downloadExcel.do?"
											//+ "headerName="		+ encodeURI(headerName)
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="		+ encodeURIComponent(headerKey)
											//+ "&title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text())
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
											+ "&companyCode="   + accountCtrl.getComboInfo("companyCode").val()
											+ "&fiscalYear="	+ fiscalYear
							 				+ "&costCenterName="+ encodeURIComponent(encodeURIComponent(costCenterName))
											+ "&costCenterType="+ costCenterType
							 				+ "&searchType="	+ searchType
							 				+ "&searchStr="		+ encodeURIComponent(encodeURIComponent(searchStr))
							 				+ "&authMode="+authMode;
						location.href = locationStr;
		       		}
		       	});
			},
			refresh : function(){
				accountCtrl.pageRefresh();
			},

			onEnter : function(){
				var me = this;
				if(event.keyCode=="13"){
					me.searchList();
				}
			},
			openDetailPopup:function(key){
				if (key == "null"){
					Common.Error("<spring:message code='Cache.msg_apv_082' />"); 
					return;
				}
				
				var popupName	=	"FileViewPopup";
				var popupID		=	"FileViewPopup";
				var openerID	=	"MobileReceipt";
				var popupTit	=	""; 
				var url			=	"/approval/approval_Form.do?"
								+	"popupID="		+ popupID	+ "&"
								+	"popupName="	+ popupName	+ "&"
								+	"processID="	+ key	+ "&"
								+	"openerID="		+ openerID	;
				Common.open("",popupID,popupTit,url,"1070","800px","iframe",true,null,null,true);
			},
			getHeaderNameForExcel: function(headerData) {
				var returnStr	= "";
			   	for(var i=0;i<headerData.length; i++){
			   	   	if(headerData[i].display != false && headerData[i].label != 'chk'){
			   	   		returnStr += headerData[i].label + "†";
			   	   	}
				}
				return returnStr;
			},
			getHeaderKeyForExcel: function(headerData) {
				var returnStr	= "";
			   	for(var i=0;i<headerData.length; i++){
			   	   	if(headerData[i].display != false && headerData[i].label != 'chk'){
						returnStr += headerData[i].key + ",";
			   	   	}
				}
				return returnStr;
			}

		}
		window.BudgetUse= BudgetUse;
	})(window);
</script>