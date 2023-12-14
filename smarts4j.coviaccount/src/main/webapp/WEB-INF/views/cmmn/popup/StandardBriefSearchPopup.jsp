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
	.pad10 {padding:10px;}
</style>
<body>
	<div class="l-contents-tabs">
		<div name="sbTabDiv" tabtype="A" class="l-contents-tabs__item">
			<a name="sbTabA" tabtype="A" class="l-contents-tabs__title"
				onclick="StandardBriefSearchPopup.sbTabClick(this, 'A')">
				<div class="l-contents-tabs__title" >
					<!-- 표준적요 -->
					<spring:message code='Cache.ACC_standardBrief'/>
				</div>
			</a>
		</div>
		<div name="sbTabDiv" tabtype="F"  class="l-contents-tabs__item l-contents-tabs__item--active">
			<a name="sbTabA" tabtype="F" class="l-contents-tabs__title"
				onclick="StandardBriefSearchPopup.sbTabClick(this, 'F')">
				<div  class="l-contents-tabs__title" >
					<!-- 즐겨찾기 -->
					<spring:message code='Cache.ACC_lbl_favorite'/>
				</div>
			</a>
		</div>
	</div>
	<div name="sbArea">
		<div class="Layer_divpop ui-draggable docPopLayer" style="width:auto;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
			<div class="divpop_contents">
				<div class="popContent">
					<div class="middle">
						<div class="eaccountingCont">
							<div id="topitembar02" class="bodysearch_Type01">
								<div class="inPerView type07">
									<div style="width:900px;">
										<div class="inPerTitbox">
											<span id="sbSearchTypePop" class="selectType02">
											</span>
											<input onkeydown="StandardBriefSearchPopup.onenter()" id="searchStr" type="text" placeholder="">
										</div>
										<a class="btnTypeDefault  btnSearchBlue"	onclick="StandardBriefSearchPopup.searchList();"><spring:message code='Cache.ACC_btn_search'/></a>
									</div>
								</div>
							</div>
							<!-- 즐겨찾기 추가 -->
							<a class="btnTypeDefault btnTypeChk"	onclick='StandardBriefSearchPopup.updateFavorite("A")'><spring:message code='Cache.ACC_btn_addFavorite'/></a>
							<div id="gridArea" class="pad10">
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div name="favSbArea" style="display:none">
		<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:700px;" source="iframe" modallayer="false" layertype="iframe" property="">
			<div class="divpop_contents">
				<div class="popContent">
					<div class="middle">
						<div class="eaccountingCont">
							<!-- 즐겨찾기 삭제 -->
							<a class="btnTypeDefault btnTypeChk"	onclick='StandardBriefSearchPopup.updateFavorite("D")'><spring:message code='Cache.ACC_btn_deleteFavorite'/></a>
							<div id="favGridArea" class="pad10">
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
<script>

	if (!window.StandardBriefSearchPopup) {
		window.StandardBriefSearchPopup = {};
	}
	
	(function(window) {
		var CompanyCode = CFN_GetQueryString("companyCode") == "undefined" ? "" : CFN_GetQueryString("companyCode");
		var requestType;
		
		if(opener) 		requestType = opener.CFN_GetQueryString("requesttype");
		else if(parent)	requestType = parent.CFN_GetQueryString("requesttype");
		else			requestType = CFN_GetQueryString("requesttype");
		
		var StandardBriefSearchPopup = {
				params	:{
					gridPanel	: new coviGrid(),
					favGridPanel	: new coviGrid(),
					headerData	: [],
					favHeaderData	: []
				},
				
				pageInit : function(){
					var me = this;					
					me.setSelectCombo();
					me.setHeaderData();
					me.searchList();
					
					me.sbTabClick('', 'F');
					parent.$("#standardBriefSearchPopup_container .divpop_body").css("padding", "0");
				},
				
				setSelectCombo : function(){
					accountCtrl.renderAXSelect('sbSearchTypePop',	'sbSearchTypePop',	'ko','','','',"<spring:message code='Cache.ACC_lbl_comboAll' />", CompanyCode);
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'chk',					label:'chk',											width:'10',	align:'center',	formatter:'checkbox'},
					                        	{	key:'AccountCode',			label:"<spring:message code='Cache.ACC_lbl_accountCode' />",				width:'20', align:'center'},	//계정코드
					    		          	 	{	key:'AccountName',			label:"<spring:message code='Cache.ACC_lbl_accountName' />",				width:'20', align:'left'},	//계정명
					    		          	   	{	key:'StandardBriefName',	label:"<spring:message code='Cache.ACC_standardBrief' />",				width:'20', align:'left',		//표준적요
					    			          	   	formatter:function () {
					    								var rtStr =	""
					    											+	"<a onclick='StandardBriefSearchPopup.clickStandardBriefInfo(\""
					    													+ this.item.AccountCode			+"\",\""
					    													+ this.item.AccountName 		+"\",\""
					    													+ this.item.TaxType 			+"\",\""
					    													+ this.item.TaxCode 			+"\",\""
					    													+ this.item.StandardBriefName	+"\",\""
					    													+ this.item.StandardBriefDesc	+"\",\""
					    													+ this.item.StandardBriefID		+"\",\""
					    													+ this.item.CtrlCode			+"\""
					    											+		"); return false;'>"
					    											+		"<font color='blue'>"
					    											+			this.item.StandardBriefName
					    											+		"</font>"
					    											+	"</a>";
					    								return rtStr;
					    							}
					    		          	 	},
					    		          	 	{	key:'StandardBriefDesc',	label:"<spring:message code='Cache.ACC_lbl_standardBriefDesc' />",		width:'70', align:'left'}		//표준적요설명	
											]
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(){
					var me = this;
					
					me.setHeaderData();
		 			
					var sbSearchTypePop	= accountCtrl.getComboInfo("sbSearchTypePop").val();	//구분
					var searchStr		= $("#searchStr").val();		//조회문장
					
					var standardBriefSearchStr = "";
					if (requestType != "undefined" && (opener || parent)) {
						var commObj = opener ? opener.accComm[requestType]
											 : parent.accComm[requestType];
						if (commObj) standardBriefSearchStr = commObj.pageExpenceFormInfo.StandardBriefSearchStr;
					}
					
					var gridAreaID	= "gridArea";
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					var ajaxUrl		= "/account/accountCommon/getStandardBriefSearchPopupList.do";
					var ajaxPars	= {	
										"sbSearchTypePop"	: sbSearchTypePop
						 			,	"searchStr"			: searchStr
						 			,	"StandardBriefSearchStr" : standardBriefSearchStr
						 			,	"companyCode"		: CompanyCode
									};
					
					var pageNoInfo		= 1;
					var pageSizeInfo	= 200;
					
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
								
				clickStandardBriefInfo : function(AccountCode,AccountName,TaxType,TaxCode,StandardBriefName,StandardBriefDesc,StandardBriefID,CtrlCode){
					var me = this;
					var info = {
							'AccountCode'			: AccountCode
						,	'AccountName'			: AccountName
						,	'TaxType'				: TaxType
						,	'TaxCode'				: TaxCode
						,	'StandardBriefName'		: StandardBriefName
						,	'StandardBriefDesc'		: StandardBriefDesc
						,	'StandardBriefID'		: StandardBriefID
						,	'CtrlCode'				: CtrlCode
					}
					
					me.closeLayer();
					
					var windowPopupYN = CFN_GetQueryString("windowPopupYN") == "undefined" ? "N" : CFN_GetQueryString("windowPopupYN");
					
					try{
						accountCtrl.popupCallBackStr([info]);
						
						if(windowPopupYN == "Y") {
							window.close();
						}
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
				
				sbTabClick : function(obj, type){
					var me = this;
					
					if(type=="A"){
						$("[name=sbTabDiv][tabtype=A]").addClass("l-contents-tabs__item--active");
						$("[name=sbTabDiv][tabtype=F]").removeClass("l-contents-tabs__item--active");
						$("[name=sbArea]").css("display", "");
						$("[name=favSbArea]").css("display", "none");
						accountCtrl.refreshAXSelect('sbSearchTypePop');
						me.searchList();
					}else if(type=="F"){
						$("[name=sbTabDiv][tabtype=A]").removeClass("l-contents-tabs__item--active");
						$("[name=sbTabDiv][tabtype=F]").addClass("l-contents-tabs__item--active");
						$("[name=sbArea]").css("display", "none");
						$("[name=favSbArea]").css("display", "");
						me.favSearchList();
					}
				},
				
				favSearchList : function(){
					var me = this;

					me.params.favHeaderData = [	{	key:'chk',					label:'chk',											width:'10',	align:'center',	formatter:'checkbox'},
					                        	{	key:'AccountCode',			label:"<spring:message code='Cache.ACC_lbl_accountCode' />",				width:'20', align:'center'},	//계정코드
					    		          	 	{	key:'AccountName',			label:"<spring:message code='Cache.ACC_lbl_accountName' />",				width:'20', align:'left'},	//계정명
					    		          	   	{	key:'StandardBriefName',	label:"<spring:message code='Cache.ACC_standardBrief' />",				width:'20', align:'left',		//표준적요
					    			          	   	formatter:function () {
					    								var rtStr =	""
					    											+	"<a onclick='StandardBriefSearchPopup.clickStandardBriefInfo(\""
					    													+ this.item.AccountCode			+"\",\""
					    													+ this.item.AccountName 		+"\",\""
					    													+ this.item.TaxType 			+"\",\""
					    													+ this.item.TaxCode 			+"\",\""
					    													+ this.item.StandardBriefName	+"\",\""
					    													+ this.item.StandardBriefDesc	+"\",\""
					    													+ this.item.StandardBriefID		+"\",\""
					    													+ this.item.CtrlCode			+"\""
					    											+		"); return false;'>"
					    											+		"<font color='blue'>"
					    											+			this.item.StandardBriefName
					    											+		"</font>"
					    											+	"</a>";
					    								return rtStr;
					    							}
					    		          	 	},
					    		          	 	{	key:'StandardBriefDesc',	label:"<spring:message code='Cache.ACC_lbl_standardBriefDesc' />",		width:'70', align:'left'}		//표준적요설명
					]
					
					var gridPanel		= me.params.favGridPanel;
					var gridHeader		= me.params.favHeaderData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);

					var gridAreaID		= "favGridArea";

					var standardBriefSearchStr = "";
					if (requestType != "undefined" && (opener || parent)) {
						var commObj = opener ? opener.accComm[requestType]
											 : parent.accComm[requestType];
						if (commObj) standardBriefSearchStr = commObj.pageExpenceFormInfo.StandardBriefSearchStr;
					}
					
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
					var ajaxUrl			= "/account/accountCommon/getFavoriteStandardBriefSearchPopupList.do";
					var ajaxPars	= {	
										"StandardBriefSearchStr" : standardBriefSearchStr,
			 							"companyCode" : CompanyCode
									};
					
					var pageNoInfo		= 1;
					var pageSizeInfo	= 200;
					
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
					}else if(updateType=="D") {
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
						 			url:"/account/accountCommon/setFavoriteStandardBriefSearchPopupList.do",
									data:{
										"saveObj"		: JSON.stringify(obj),
									},
									success:function (data) {
										if(data.result == "ok"){
											Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다.
											me.favSearchList();
											me.searchList();
										}
									},
									error:function (error){
										Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
									}
								});
							}
						});
					}
				}
		}
		window.StandardBriefSearchPopup = StandardBriefSearchPopup;
	})(window);
	
	StandardBriefSearchPopup.pageInit();
</script>