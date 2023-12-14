<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<style>
	.pad10 { padding:10px;}
</style>

<body>
	<div class="l-contents-tabs">
		<div name="accTabDiv" tabtype="A" class="l-contents-tabs__item l-contents-tabs__item--active">
			<a name="accTabA" tabtype="A" class="l-contents-tabs__title"
				onclick="AccountSearchPopup.accTabClick(this, 'A')">
				<div class="l-contents-tabs__title" >
					<!-- 계정과목 -->
					<spring:message code='Cache.ACC_lbl_account'/>
				</div>
			</a>
		</div>
		<div name="accTabDiv" tabtype="F"  class="l-contents-tabs__item ">
			<a name="accTabA" tabtype="F" class="l-contents-tabs__title"
				onclick="AccountSearchPopup.accTabClick(this, 'F')">
				<div  class="l-contents-tabs__title" >
					<!-- 즐겨찾기 -->
					<spring:message code='Cache.ACC_lbl_favorite'/>
				</div>
			</a>
		</div>
	</div>
	<div name="accArea">
		<input id="searchProperty"	type="hidden" />
		<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:700px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
			<div class="divpop_contents">
				<div class="popContent">
					<div id="topitembar02" class="bodysearch_Type01">
						<div class="eaccountingTopCont">
							<div class="buttonStyleBoxRight">	
							</div>
						</div>
						<div class="inPerView type07">
							<div style="width:700px;">
								<div class="inPerTitbox">
									<span id="accountClass" class="selectType02">
									</span>
								</div>
								<div class="inPerTitbox">
									<span id="amSearchTypePop" class="selectType02">
									</span>
									<input onkeydown="AccountSearchPopup.onenter()" id="searchStr" type="text" placeholder="">
								</div>
								<a class="btnTypeDefault  btnSearchBlue"	onclick='AccountSearchPopup.searchList()'><spring:message code='Cache.ACC_btn_search'/></a>
							</div>
						</div>
					</div>
					<!-- 즐겨찾기 추가 -->
					<a class="btnTypeDefault btnTypeChk"	onclick='AccountSearchPopup.updateFavorite("A")'><spring:message code='Cache.ACC_btn_addFavorite'/></a>
					<div id="gridArea" class="pad10">
					</div>
				</div>
			</div>
		</div>
	</div>
	<div name="favAccArea" style="display:none">
		<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:700px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
			<div class="divpop_contents">
				<div class="popContent">
					<!-- 즐겨찾기 삭제 -->
					<a class="btnTypeDefault btnTypeChk"	onclick='AccountSearchPopup.updateFavorite("D")'><spring:message code='Cache.ACC_btn_deleteFavorite'/></a>
					<div id="favGridArea" class="pad10">
					</div>
				</div>
			</div>
		</div>
	</div>
</body>

<script>
//BizCardFavoriteList.jsp	
	if (!window.AccountSearchPopup) {
		window.AccountSearchPopup = {};
	}
	
	(function(window) {
		var CompanyCode = CFN_GetQueryString("companyCode") == "undefined" ? "" : CFN_GetQueryString("companyCode");
		
		var AccountSearchPopup = {
				params	:{
					gridPanel	: new coviGrid(),
					favGridPanel	: new coviGrid(),
					headerData	: [],
					favHeaderData	: []
				},
				
				pageInit : function(){
					var me = this;
					setPropertySearchType('AccountManage','searchProperty');
					me.setPageViewController();
					me.setSelectCombo();
					me.setHeaderData();
					me.searchList();
				},
				
				setPageViewController :function(){
					var searchProperty	= $("#searchProperty").val();
					
					if(searchProperty == "SAP"){
						//SAP가 추가될 경우 이곳에 정의
						$("#accountClass").css("display", "none");
					}else if(searchProperty == "SOAP"){
						$("#accountClass").css("display", "none");
					}else{
						$("#accountClass").css("display", "");
					}
				},
				
				setSelectCombo : function(){
					var AXSelectMultiArr	= []
					var searchProperty		= $("#searchProperty").val();
					
					if(searchProperty == "SAP"){
						AXSelectMultiArr	= [	{'codeGroup':'amSearchTypePop',	'target':'amSearchTypePop',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
							               	]
					}else if(searchProperty == "SOAP"){
						AXSelectMultiArr	= [	{'codeGroup':'amSearchTypePop',	'target':'amSearchTypePop',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
							               	]
					}else{
						AXSelectMultiArr	= [	
												{'codeGroup':'AccountClass',	'target':'accountClass',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"} //전체
											,	{'codeGroup':'amSearchTypePop',	'target':'amSearchTypePop',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
											]			
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, CompanyCode);
				},
				
				setHeaderData : function() {
					var me = this;
					var searchProperty	= $("#searchProperty").val();
					
					if(searchProperty == "SAP"){
						me.params.headerData = [	{ key:'chk',			label:'chk',								width:'20',		align:'center',	formatter:'checkbox'},
						                        	{	key:'AccountCode',		label:"<spring:message code='Cache.ACC_lbl_accountCode' />",	width:'70', align:'center',	//계정코드
						    							formatter:function () {
						    								var rtStr =	""
						    											+	"<a onclick='AccountSearchPopup.clickAccountInfo(\""
				    													+			this.item.AccountID			+"\",\""
				    													+			this.item.AccountCode		+"\",\""
				    													+			this.item.AccountName		+"\""
						    											+		"); return false;'>"
						    											+		"<font color='blue'>"
						    											+			this.item.AccountCode
						    											+		"</font>"
						    											+	"</a>";
						    								return rtStr;
						    							}
						    						},
						    						{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_accountName' />",		width:'70', align:'left'}	//계정이름
						    					]
					}else if(searchProperty == "SOAP"){
						me.params.headerData = [	{ key:'chk',			label:'chk',								width:'20',		align:'center',	formatter:'checkbox'},
						                        	{	key:'AccountCode',		label:"<spring:message code='Cache.ACC_lbl_accountCode' />",	width:'70', align:'center',
						    							formatter:function () {
						    								var rtStr =	""
						    											+	"<a onclick='AccountSearchPopup.clickAccountInfo(\""
				    													+			this.item.AccountID			+"\",\""
				    													+			this.item.AccountCode		+"\",\""
				    													+			this.item.AccountName		+"\""
						    											+		"); return false;'>"
						    											+		"<font color='blue'>"
						    											+			this.item.AccountCode
						    											+		"</font>"
						    											+	"</a>";
						    								return rtStr;
						    							}
						    						},
						    						{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_accountName' />",		width:'70', align:'left'}
						    					]
					}else{
						me.params.headerData = [	{ key:'chk',			label:'chk',								width:'20',		align:'center',	formatter:'checkbox'},
						                        	{	key:'CompanyName',	label:"<spring:message code='Cache.ACC_lbl_company' />",		width:'70', align:'left'},
						    		          	   	{	key:'AccountCode',		label:"<spring:message code='Cache.ACC_lbl_accountCode' />",	width:'70', align:'center',
						    							formatter:function () {
						    								var rtStr =	""
						    											+	"<a onclick='AccountSearchPopup.clickAccountInfo(\""
				    													+			this.item.AccountID			+"\",\""
				    													+			this.item.AccountCode		+"\",\""
				    													+			this.item.AccountName		+"\""
						    											+		"); return false;'>"
						    											+		"<font color='blue'>"
						    											+			this.item.AccountCode
						    											+		"</font>"
						    											+	"</a>";
						    								return rtStr;
						    							}
						    						},
						    						{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_accountName' />",		width:'70', align:'left'},
						    					]
					}
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(){
					var me = this;
					
					me.setHeaderData();
					
					var accountClass	= accountCtrl.getComboInfo("accountClass").val();
					var amSearchTypePop	= accountCtrl.getComboInfo("amSearchTypePop").val();
					var searchStr		= $("#searchStr").val();
					var searchProperty	= $("#searchProperty").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/accountCommon/getAccountSearchPopupList.do";
					var ajaxPars		= {	"accountClass"		: accountClass
				 		 				,	"amSearchTypePop"	: amSearchTypePop
				 		 				,	"searchStr"			: searchStr
				 		 				,	"searchProperty"	: searchProperty
				 		 				,	"companyCode"		: CompanyCode
					};
					
					var pageSizeInfo	= 200;
					var pageNoInfo		= 1;
					
					var gridParams = {	"gridAreaID"	: gridAreaID
									,	"gridPanel"		: gridPanel
									,	"gridHeader"	: gridHeader
									,	"ajaxUrl"		: ajaxUrl
									,	"ajaxPars"		: ajaxPars
									,	"pageNoInfo"	: pageNoInfo
									,	"pageSizeInfo"	: pageSizeInfo
									,	"popupYN"		: 'Y'
									, 	"pagingTF"		: false
									,	"height"		: "480px"
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
					
					accountCtrl.setGridBodyOption(gridPanel, ajaxUrl, ajaxPars);
				},
				
				clickAccountInfo : function(AccountID,AccountCode,AccountName){
					var me = this;
					var info = {
							'AccountID'			: AccountID
						,	'AccountCode'		: AccountCode
						,	'AccountName'		: AccountName
					}
					
					me.closeLayer();
					
					try{
						accountCtrl.popupCallBackStr([info]);
					}catch (e) {
						coviCmn.traceLog(e);
						coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
					}
				},
				
				closeLayer : function() {
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				},
				
				onenter : function(){
					var me = this;
					if(event.keyCode=="13"){
						me.searchList();
					}
				},
				accTabClick : function(obj, type){
					var me = this;
					
					if(type=="A"){
						$("[name=accTabDiv][tabtype=A]").addClass("l-contents-tabs__item--active");
						$("[name=accTabDiv][tabtype=F]").removeClass("l-contents-tabs__item--active");
						$("[name=accArea]").css("display", "");
						$("[name=favAccArea]").css("display", "none");
						accountCtrl.refreshAXSelect('AccountClass,amSearchTypePop');						
					}else if(type=="F"){
						$("[name=accTabDiv][tabtype=A]").removeClass("l-contents-tabs__item--active");
						$("[name=accTabDiv][tabtype=F]").addClass("l-contents-tabs__item--active");
						$("[name=accArea]").css("display", "none");
						$("[name=favAccArea]").css("display", "");
						me.favSearchList();
					}
				},
				favSearchList : function(){
					var me = this;

					me.params.favHeaderData = [
						{ key:'chk',			label:'chk',										width:'20',		align:'center',	formatter:'checkbox'},
						{	key:'CompanyName',	label:"<spring:message code='Cache.ACC_lbl_company' />",			width:'70', align:'left'},//회사
		          	   	{	key:'AccountCode',		label:"<spring:message code='Cache.ACC_lbl_accountCode' />",		width:'70', align:'center',//계정코드
							formatter:function () {
								var rtStr =	""
											+	"<a onclick='AccountSearchPopup.clickAccountInfo(\""
											+			this.item.AccountID			+"\",\""
											+			this.item.AccountCode		+"\",\""
											+			this.item.AccountName		+"\""
											+		"); return false;'>"
											+		"<font color='blue'>"
											+			this.item.AccountCode
											+		"</font>"
											+	"</a>";
								return rtStr;
							}
						},
						{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_accountName' />",		width:'70', align:'left'},//계정이름
					]
					
					var gridPanel		= me.params.favGridPanel;
					var gridHeader		= me.params.favHeaderData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);

					var gridAreaID		= "favGridArea";
					
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
					var ajaxUrl			= "/account/accountCommon/getFavoriteAccountSearchPopupList.do";
					var ajaxPars		= {"companyCode" : CompanyCode};
					
					var pageSizeInfo	= 200;
					var pageNoInfo		= 1;
					
					var gridParams = {	"gridAreaID"	: gridAreaID
									,	"gridPanel"		: gridPanel
									,	"gridHeader"	: gridHeader
									,	"ajaxUrl"		: ajaxUrl
									,	"ajaxPars"		: ajaxPars
									,	"pageNoInfo"	: pageNoInfo
									,	"pageSizeInfo"	: pageSizeInfo
									,	"popupYN"		: 'Y'
									, 	"pagingTF"		: false
									,	"height"		: "480px"
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
					
					accountCtrl.setGridBodyOption(gridPanel, ajaxUrl, ajaxPars);
				},
					
				updateFavorite : function(updateType){
					var me = this;
					
					var grid = null;
					var check_msg = "";
					var msg = "";
					if(updateType=="A"){
						grid = me.params.gridPanel;
						check_msg = "ACC_msg_noDataInsert";
						msg = "ACC_msg_insertFavorite";
					}else if(updateType=="D"){
						grid = me.params.favGridPanel;
						check_msg = "ACC_msg_noDataDelete";
						msg = "ACC_msg_deleteFavorite";
					}
					
					var checkList	= grid.getCheckedList(0);
							
					if(checkList.length == 0){
						Common.Inform(Common.getDic(check_msg));	//추가/삭제할 항목을 선택해주세요
						return;
					} else {
						//즐겨찾기를 추가/삭제하시겠습니까?
						Common.Confirm(Common.getDic(msg), "Confirmation Dialog", function(result){
							if(result){								
							var obj = {};
							obj.checkList = checkList;
							obj.updateType = updateType;
							
							$.ajax({
								type:"POST",
					 			url:"/account/accountCommon/setFavoriteAccountSearchPopupList.do",
								data:{
									"saveObj"		: JSON.stringify(obj),
								},
								success:function (data) {
									if(data.result == "ok"){
										Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다.
										me.favSearchList();
									}
								},
								error:function (error){
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
								}
							});
						}
					});
					}
				},
		}
		window.AccountSearchPopup = AccountSearchPopup;
	})(window);
	
	AccountSearchPopup.pageInit();

</script>