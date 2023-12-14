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
		<div name="CCTabDiv" tabtype="C" class="l-contents-tabs__item l-contents-tabs__item--active">
			<a name="CCTabA" tabtype="C" class="l-contents-tabs__title"
				onclick="CostCenterSearchPopup.ccTabClick(this, 'C')">
				<div class="l-contents-tabs__title" >
					<!-- 코스트센터 -->
					<spring:message code='Cache.ACC_lbl_costCenter'/>
				</div>
			</a>
		</div>
		<div name="CCTabDiv" tabtype="F"  class="l-contents-tabs__item ">
			<a name="aCCTabA" tabtype="F" class="l-contents-tabs__title"
				onclick="CostCenterSearchPopup.ccTabClick(this, 'F')">
				<div  class="l-contents-tabs__title" >
					<!-- 즐겨찾기 -->
					<spring:message code='Cache.ACC_lbl_favorite'/>
				</div>
			</a>
		</div>
	</div>
	<div name="CCArea">
		<input id="searchProperty"	type="hidden" />
		<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:600px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
			<div class="divpop_contents">
				<div class="popContent">
					<div id="topitembar02" class="bodysearch_Type01">
						<div class="eaccountingTopCont">
						</div>
						<div class="inPerView type07">
							<div id="row1" style="width:600px;">
								<div class="inPerTitbox">
									<span id="searchType" class="selectType02">
									</span>
									<input onkeydown="CostCenterSearchPopup.onenter()" id="searchStr" type="text" placeholder="">
								</div>
								<a class="btnTypeDefault  btnSearchBlue"	onclick="CostCenterSearchPopup.searchList();"><spring:message code='Cache.ACC_btn_search'/></a>
							</div>
							<div id="row2" style="width:600px;">
								<div class="inPerTitbox">
									<span class="bodysearch_tit">
										<!-- CostCenter 명 -->
										<spring:message code='Cache.ACC_lbl_costCenterName'/>
									</span>
									<input onkeydown="CostCenter.onenter()" id="soapCostCenterName" type="text" placeholder="">
								</div>
								<a class="btnTypeDefault  btnSearchBlue"	onclick="CostCenterSearchPopup.searchList();"><spring:message code='Cache.ACC_btn_search'/></a>
							</div>
						</div>
					</div>
					<!-- 즐겨찾기 추가 -->
					<a class="btnTypeDefault btnTypeChk"	onclick='CostCenterSearchPopup.updateFavorite("A")'><spring:message code='Cache.ACC_btn_addFavorite'/></a>
					<div id="gridArea" class="pad10">
					</div>
				</div>
			</div>
		</div>
	</div>
	<div name="favCCArea" style="display:none">
		<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:600px;" 
		source="iframe" modallayer="false" layertype="iframe" pproperty="">
			<div class="divpop_contents">
				<div class="popContent">
					<!-- 즐겨찾기 삭제 -->
					<a class="btnTypeDefault btnTypeChk"	onclick='CostCenterSearchPopup.updateFavorite("D")'><spring:message code='Cache.ACC_btn_deleteFavorite'/></a>
					<div id="favGridArea" class="pad10">
					</div>
				</div>
			</div>
		</div>
	</div>
</body>

<script>
	
	if (!window.CostCenterSearchPopup) {
		window.CostCenterSearchPopup = {};
	}
	
	(function(window) {
		var CompanyCode = CFN_GetQueryString("companyCode") == "undefined" ? "" : CFN_GetQueryString("companyCode");
		
		var CostCenterSearchPopup = {
				params	:{
					gridPanel	: new coviGrid(),
					favGridPanel	: new coviGrid(),
					headerData	: [],
					favHeaderData	: []
				},
				
				pageInit : function(){
					var me = this;
					setPropertySearchType('CostCenter','searchProperty');
					me.setPageViewController();
					me.setSelectCombo();
					me.setHeaderData();
					me.searchList();
				},
				
				setSelectCombo : function(){
					accountCtrl.renderAXSelect('ccSearchType','searchType','ko','','','',"<spring:message code='Cache.ACC_lbl_comboAll' />",CompanyCode);//전체
				},
				
				setPageViewController :function(){
					
					if(CFN_GetQueryString("popupType") != "" && CFN_GetQueryString("popupType") == "IO") {
						$("a[name=CCTabA][tabtype=C]").find("div").text("<spring:message code='Cache.ACC_lbl_projectName' />");
						$("#row2").find("span.bodysearch_tit").text("<spring:message code='Cache.ACC_lbl_projectName' />");
					}
					
					var searchProperty	= $("#searchProperty").val();
					
					if(	searchProperty == "SAP"){
						//SAP가 추가될 경우 이곳에 정의
						$("#row2").show();
						$("#row1").hide();
						
					}else if(	searchProperty == "SOAP"){
						$("#row2").show();
						$("#row1").hide();
						
					}else{
						$("#row1").show();
						$("#row2").hide();
					}
				},
				
				setHeaderData : function() {
					var me = this;
					if(CFN_GetQueryString("popupType") != "" && CFN_GetQueryString("popupType") == "IO") {
					me.params.headerData = [	
												{	key:'chk',				label:'chk',							width:'20',	align:'center',	formatter:'checkbox'},
					    		          	   	{	key:'NameCode',			label:"<spring:message code='Cache.ACC_lbl_code' />",	width:'50', align:'center',	//IO 코드
													formatter:function () {
														var rtStr =	""
																	+	"<a onclick='CostCenterSearchPopup.clickCostCenterInfo(\""
																			+ this.item.CostCenterID	+"\",\""	
																			+ this.item.CompanyCode		+"\",\""
																			+ this.item.CompanyName		+"\",\""
																			+ this.item.CostCenterType	+"\",\""
																			+ this.item.CostCenterCode	+"\",\""
																			+ this.item.CostCenterName	+"\",\""
																			+ this.item.NameCode		+"\",\""
																			+ this.item.UsePeriodStart	+"\",\""
																			+ this.item.UsePeriodFinish	+"\",\""
																			+ this.item.IsPermanent		+"\",\""
																			+ this.item.IsUse			+"\",\""
																			+ this.item.Description		+"\""
																	+		"); return false;'>"
																	+		"<font color='blue'>"
																	+			this.item.NameCode
																	+		"</font>"
																	+	"</a>";
														return rtStr;
													}
												},
												{	key:'CostCenterName',	label:"<spring:message code='Cache.ACC_lbl_codeNm' />", 	width:'100', align:'left'}	//IO 명
											]
					} else {
					me.params.headerData = [	
												{	key:'chk',				label:'chk',											width:'20',	align:'center',	formatter:'checkbox'},
					    		          	   	{	key:'CostCenterCode',	label:"<spring:message code='Cache.ACC_lbl_costCenterCode' />",			width:'50', align:'center',	//CostCenter 코드
													formatter:function () {
														var rtStr =	""
																	+	"<a onclick='CostCenterSearchPopup.clickCostCenterInfo(\""
																			+ this.item.CostCenterID	+"\",\""	
																			+ this.item.CompanyCode		+"\",\""
																			+ this.item.CompanyName		+"\",\""
																			+ this.item.CostCenterType	+"\",\""
																			+ this.item.CostCenterCode	+"\",\""
																			+ this.item.CostCenterName	+"\",\""
																			+ this.item.NameCode		+"\",\""
																			+ this.item.UsePeriodStart	+"\",\""
																			+ this.item.UsePeriodFinish	+"\",\""
																			+ this.item.IsPermanent		+"\",\""
																			+ this.item.IsUse			+"\",\""
																			+ this.item.Description.replace(/\n/g, "")		+"\""
																	+		"); return false;'>"
																	+		"<font color='blue'>"
																	+			this.item.CostCenterCode
																	+		"</font>"
																	+	"</a>";
														return rtStr;
													}
												},
												{	key:'CostCenterName',	label:"<spring:message code='Cache.ACC_lbl_costCenterName' />",			width:'100', align:'left'}	//CostCenter 명
											]
					}
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(){
					var me = this;
					
					me.setHeaderData();
					
					var searchTypePop		= accountCtrl.getComboInfo("searchType").val();
					var searchStr			= $("#searchStr").val();
					var searchProperty		= $("#searchProperty").val();
					var soapCostCenterName	= $("#soapCostCenterName").val();
					
					var popupType		= CFN_GetQueryString("popupType");
					if(	popupType == undefined || popupType	== "undefined") {
						popupType = '';
					}
					
					var gridAreaID	= "gridArea";
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					var ajaxUrl		= "/account/accountCommon/getCostCenterSearchPopupList.do?";
					var ajaxPars	= {	"companyCode"			: CompanyCode
			 						,	"popupType"				: popupType
					 				,	"searchTypePop"			: searchTypePop
					 				,	"searchStr"				: searchStr
					 				,	"searchProperty"		: searchProperty
					 				,	"soapCostCenterName"	: soapCostCenterName
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
				clickCostCenterInfo : function(CostCenterID, CompanyCode, CompanyName, CostCenterType,
												CostCenterCode, CostCenterName, NameCode, UsePeriodStart,
												UsePeriodFinish, IsPermanent, IsUse, Description){
					var me = this;
					var info = {'CostCenterID'		: CostCenterID        
							,	'CompanyCode'		: CompanyCode          
							,	'CompanyName'		: CompanyName    
							,	'CostCenterType'	: CostCenterType      
							,	'CostCenterCode'	: CostCenterCode      
							,	'CostCenterName'	: CostCenterName      
							,	'NameCode'			: NameCode            
							,	'UsePeriodStart'	: UsePeriodStart      
							,	'UsePeriodFinish'	: UsePeriodFinish     
							,	'IsPermanent'		: IsPermanent         
							,	'IsUse'				: IsUse               
							,	'Description'		: Description
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
				

				ccTabClick : function(obj, type){
					var me = this;
					
					if(type=="C"){
						$("[name=CCTabDiv][tabtype=C]").addClass("l-contents-tabs__item--active");
						$("[name=CCTabDiv][tabtype=F]").removeClass("l-contents-tabs__item--active");
						$("[name=CCArea]").css("display", "");
						$("[name=favCCArea]").css("display", "none");
						
						
					}else if(type=="F"){
						$("[name=CCTabDiv][tabtype=C]").removeClass("l-contents-tabs__item--active");
						$("[name=CCTabDiv][tabtype=F]").addClass("l-contents-tabs__item--active");
						$("[name=CCArea]").css("display", "none");
						$("[name=favCCArea]").css("display", "");
						me.favSearchList();
					}
				},
				favSearchList : function(){
					var me = this;
					
					if(CFN_GetQueryString("popupType") != "" && CFN_GetQueryString("popupType") == "IO") {
						me.params.favHeaderData = [
							{ 	key:'chk',				label:'chk',							width:'20',	align:'center',	formatter:'checkbox'},
			          	   	{	key:'NameCode',	label:"<spring:message code='Cache.ACC_lbl_code' />",			width:'50', align:'center',	//IO 코드
								formatter:function () {
									var rtStr =	"<a onclick='CostCenterSearchPopup.clickCostCenterInfo(\""
														+ this.item.CostCenterID	+"\",\""	
														+ this.item.CompanyCode		+"\",\""
														+ this.item.CompanyName		+"\",\""
														+ this.item.CostCenterType	+"\",\""
														+ this.item.CostCenterCode	+"\",\""
														+ this.item.CostCenterName	+"\",\""
														+ this.item.NameCode		+"\",\""
														+ this.item.UsePeriodStart	+"\",\""
														+ this.item.UsePeriodFinish	+"\",\""
														+ this.item.IsPermanent		+"\",\""
														+ this.item.IsUse			+"\",\""
														+ this.item.Description		+"\""
												+		"); return false;'>"
												+		"<font color='blue'>"
												+			this.item.NameCode
												+		"</font>"
												+	"</a>";
									return rtStr;
								}
							},
							{	key:'CostCenterName',	label:"<spring:message code='Cache.ACC_lbl_codeNm' />",	width:'100', align:'left'}	//IO 명
						]
						
					} else {
						me.params.favHeaderData = [
							{ key:'chk',			label:'chk',								width:'20',		align:'center',	formatter:'checkbox'},
			          	   	{	key:'CostCenterCode',	label:"<spring:message code='Cache.ACC_lbl_costCenterCode' />",			width:'50', align:'center',	//CostCenter 코드
								formatter:function () {
									var rtStr =	""
												+	"<a onclick='CostCenterSearchPopup.clickCostCenterInfo(\""
														+ this.item.CostCenterID	+"\",\""	
														+ this.item.CompanyCode		+"\",\""
														+ this.item.CompanyName		+"\",\""
														+ this.item.CostCenterType	+"\",\""
														+ this.item.CostCenterCode	+"\",\""
														+ this.item.CostCenterName	+"\",\""
														+ this.item.NameCode		+"\",\""
														+ this.item.UsePeriodStart	+"\",\""
														+ this.item.UsePeriodFinish	+"\",\""
														+ this.item.IsPermanent		+"\",\""
														+ this.item.IsUse			+"\",\""
														+ this.item.Description		+"\""
												+		"); return false;'>"
												+		"<font color='blue'>"
												+			this.item.CostCenterCode
												+		"</font>"
												+	"</a>";
									return rtStr;
								}
							},
							{	key:'CostCenterName',	label:"<spring:message code='Cache.ACC_lbl_costCenterName' />",			width:'100', align:'left'}	//CostCenter 명
						]
					}
					
					var gridPanel		= me.params.favGridPanel;
					var gridHeader		= me.params.favHeaderData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);

					var gridAreaID		= "favGridArea";
					
					var popupType		= CFN_GetQueryString("popupType");
					if(	popupType == undefined || popupType	== "undefined") {
						popupType = '';
					}
					
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
					var ajaxUrl			= "/account/accountCommon/getFavoriteCostCenterSearchPopupList.do";
					var ajaxPars		= {
											"companyCode"	: CompanyCode,
											"popupType" 	: popupType
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
					 			url:"/account/accountCommon/setFavoriteCostCenterSearchPopupList.do",
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
		window.CostCenterSearchPopup = CostCenterSearchPopup;
	})(window);
	
	CostCenterSearchPopup.pageInit();
	
</script>