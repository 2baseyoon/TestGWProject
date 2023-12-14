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
					<!-- 새로고침 -->
					<a class="btnTypeDefault"			onclick="InvestUseList.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"	onclick="InvestUseList.excelDownload()"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
				</div>
				<!-- 상단 버튼 끝 -->				
			</div>
			<div id="searchbar" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<!-- 회사 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_company"/></span>
							<span id="invUse_CompanyCode" class="selectType02" name="searchParam" tag="companyCode" onchange="InvestUseList.changeCompanyCode()">
							</span>
						</div>	
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 부서 -->
								<spring:message code="Cache.ACC_lbl_dept"/>								
							</span>
							<input type="text" id="invUse_DeptName" name="searchParam" tag="DeptName">
						</div>						
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 기안자 -->
								<spring:message code="Cache.ACC_lbl_aprvWriter"/>
							</span>
							<input type="text" id="invUse_UserName" name="searchParam" tag="UserName">
						</div>
					</div>
					<div style="width:1200px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">		<!-- 증빙일자 -->
								<spring:message code="Cache.ACC_lbl_proofDate"/>
							</span>
							<div id="invUse_ProofDate" name="searchParam" class="dateSel type02" tag="ProofDate">
							</div>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">		<!-- 지급희망일 -->
								<spring:message code="Cache.ACC_lbl_payDay"/>
							</span>
							<div id="invUse_PayDate" name="searchParam" class="dateSel type02" tag="PayDate">
							</div>
						</div>
						<div class="inPerTitbox" style="display:none; /* act_investigation 미사용으로 검색할수 있는 구조가 아님. */">
							<span class="bodysearch_tit">	<!-- 경조항목 -->
								<spring:message code="Cache.ACC_InvestItem"/>								
							</span>
							<select id="invUse_InvestItem" name="searchParam" class="selectType02" onchange="InvestUseList.changeInvestItem();" tag="InvestItem"></select>
						</div>						
						<div class="inPerTitbox" style="display:none; /* act_investigation 미사용으로 검색할수 있는 구조가 아님. */">
							<span class="bodysearch_tit">	<!-- 경조대상 -->
								<spring:message code="Cache.ACC_InvestTarget"/>
							</span>
							<select id="invUse_InvestTarget" name="searchParam" class="selectType02" tag="InvestTarget"></select>
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="InvestUseList.searchList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="invUse_ListCount" class="selectType02 listCount" onchange="InvestUseList.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="InvestUseList.searchList()"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

if (!window.InvestUseList) {
	window.InvestUseList = {};
}

(function(window) {
	var InvestUseList = {
			params	:{
				gridPanel	: new coviGrid(),
				headerData	: []
			},

			pageInit : function() {
				var me = this;
				setHeaderTitle('headerTitle');

				makeDatepicker('invUse_ProofDate','ProofDate', null, null, null, 151);
				makeDatepicker('invUse_PayDate','PayDate', null, null, null, 151);
				
				me.setSelectCombo();
				me.searchList('Y');
			},

			pageView : function() {
				var me = this;
				
				me.refreshCombo();
				me.searchList();
			},
			
			setSelectCombo : function(pCompanyCode){
				var me = this;

				accountCtrl.getInfo("invUse_ListCount").children().remove();
				
				accountCtrl.getInfo("invUse_ListCount").addClass("selectType02").addClass("listCount").attr("onchange", "InvestUseList.searchList()");
				
				var AXSelectMultiArr	= [	
						{'codeGroup':'listCountNum',	'target':'invUse_ListCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''},
						{'codeGroup':'CompanyCode',		'target':'invUse_CompanyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
				]
				
				if(pCompanyCode != undefined) {
					AXSelectMultiArr.pop(); //CompanyCode 제외
				}
				
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				
				var companyCode = pCompanyCode == undefined ? "" : pCompanyCode;
				
				$.ajax({
					type:"POST",
					url:"/account/investigation/getInvestItemCombo.do",
					data:{
						CompanyCode : companyCode
					},
					async: false,
					success:function (data) {
						if(data.result == "ok"){
							var htmlStr = "<option value='' selected>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";
							for(var i = 0; i < data.list.length; i++){
								var item = data.list[i];
								if(item.IsUse != "N"){
									htmlStr = htmlStr + "<option value='"+ item.InvestCode + "'>" + item.InvestCodeName + "</option>";
								}
							}
							accountCtrl.getInfo("invUse_InvestItem").html(htmlStr);
							
							me.changeInvestItem(companyCode);
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			changeInvestItem : function(pCompanyCode) {
				var me = this;
				var htmlStr = "<option value=''>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";
				
				var itemVal = accountCtrl.getInfo("invUse_InvestItem").val();
				var companyCode = (pCompanyCode == undefined ? accountCtrl.getComboInfo("invUse_CompanyCode").val() : pCompanyCode);
				
				if(itemVal != "") {
					$.ajax({
						type:"POST",
						url:"/account/investigation/getInvestTargetCombo.do",
						data:{
							InvestCodeGroup : itemVal,
							CompanyCode : companyCode
						},
						async: false,
						success:function (data) {
							if(data.result == "ok"){							
								for(var i = 0; i < data.list.length; i++){
									var item = data.list[i];
									if(item.IsUse != "N"){
										htmlStr = htmlStr + "<option value='"+ item.InvestCode + "'>" + item.InvestCodeName + "</option>";
									}
								}
							}
							else{
								Common.Error(data);
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				}
				
				accountCtrl.getInfo("invUse_InvestTarget").html(htmlStr);
			},

			refreshCombo : function(){
				accountCtrl.refreshAXSelect("invUse_ListCount");
			},
			
			changeCompanyCode : function() {
				var me = this;
				me.setSelectCombo(accountCtrl.getComboInfo("invUse_CompanyCode").val());
			},
			
			setHeaderData : function() {
				var me = this;
				me.params.headerData = [	
											{ 	key:'CompanyCode',		label : "<spring:message code='Cache.ACC_lbl_company' />",		width:'50',		align:'center',		//회사
												formatter: function() {
													return this.item.CompanyName;
												}
											},	
											{	key:'ApplicationTitle',	label:"<spring:message code='Cache.ACC_lbl_title' />",			width:'100',		align:'center',		//제목
													formatter:function () {
														var rtStr =	""
																	+	"<a onclick=\"InvestUseList.openExpAppPopup('"+this.item.ExpenceApplicationID+"', '"+this.item.ProcessID+"', '"+this.item.FormInstID+"', '"+this.item.ApplicationStatus+"'); return false;\">"
																	+		"<font color='blue'>"
																	+			this.item.ApplicationTitle
																	+		"</font>"
																	+	"</a>";
														return rtStr;
													}
											},	
											{	key:'ProofDateStr',		label:"<spring:message code='Cache.ACC_lbl_proofDate' />",		width:'50',		align:'center'},	//증빙일자
				    						{	key:'PayDateStr',		label:"<spring:message code='Cache.ACC_lbl_payDay' />",			width:'50',		align:'center'},	//지급희망일
				    						{	key:'DeptName',			label:"<spring:message code='Cache.ACC_lbl_dept' />",			width:'50',		align:'center'},	//부서
				    						{	key:'UserName',			label:"<spring:message code='Cache.ACC_lbl_aprvWriter' />",		width:'50',		align:'center'},	//기안자
				    						{	key:'JobLevelName',		label:"<spring:message code='Cache.lbl_JobLevel' />",			width:'50',		align:'center'},	//직급
				    						//{	key:'InvestItemName',	label:"<spring:message code='Cache.ACC_InvestItem' />",			width:'50',		align:'center'},	//경조항목
				    						//{	key:'InvestTargetName',	label:"<spring:message code='Cache.ACC_InvestTarget' />",		width:'50',		align:'center'},	//경조대상
				    						{	key:'TotalAmount',		label:"<spring:message code='Cache.ACC_lbl_totalAmount' />",	width:'50',		align:'right', formatter:"money"}	//합계금액
				    						
				    					]
				
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},

			searchList : function(YN){
				var me = this;
				
				me.setHeaderData();
				
				var searchParam = me.getSearchParam();
				
				var gridAreaID		= "gridArea";
				var gridPanel		= me.params.gridPanel;
				var gridHeader		= me.params.headerData;
				var ajaxUrl			= "/account/investigation/getInvestigationUseList.do";
				var ajaxPars		= {	
										"searchParam" : JSON.stringify(searchParam)
									};
				
				var pageSizeInfo	= accountCtrl.getComboInfo("invUse_ListCount").val();
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
			
			getSearchParam : function() {
				var me = this;
				
				var searchParam	= accountCtrl.getInfoName("searchParam");
				
				var retVal = {};
				for(var i=0; i < searchParam.length; i++){
					var item = searchParam[i];
					if(item != null){
						var id = item.getAttribute("id");
						var tag = item.getAttribute("tag");
						if(item.tagName == "DIV"){
							if(tag.indexOf("Date")) {
								retVal[tag] = accountCtrl.getInfo(tag).val().replace(/\./gi, '');
							}
						} else {
							retVal[tag] = item.value;
						}
					}
				}
				
				return retVal;
			},
			
			excelDownload : function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
		       		if(result){
						var headerName	= accountCommon.getHeaderNameForExcel(me.params.headerData);
						var headerKey	= accountCommon.getHeaderKeyForExcel(me.params.headerData);
						var headerType	= accountCommon.getHeaderTypeForExcel(me.params.headerData);
						
						var searchParam = me.getSearchParam();
						var title 			= accountCtrl.getInfo("headerTitle").text();
						var	locationStr		= "/account/investigation/getInvestigationUseListExcel.do?"
											//+ "headerName="		+ encodeURI(headerName)
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="		+ encodeURI(headerKey)
											+ "&searchParam="	+ encodeURI(JSON.stringify(searchParam))
											//+ "&title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text())
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
											+ "&headerType=" 	+ encodeURI(headerType);
						
						location.href = locationStr;
		       		}
				});
			},
			
			openExpAppPopup : function(ExpenceApplicationID, ProcessID, FormInstID, ApplicationStatus){
				var mode = "PROCESS";
				if(ApplicationStatus == "E")
					mode = "COMPLETE";
				else if(ApplicationStatus == "R")
					mode = "REJECT";
				
				CFN_OpenWindow("/account/expenceApplication/ExpenceApplicationViewPopup.do?mode="+mode+"&processID="+ProcessID+"&forminstanceID="+FormInstID+"&ExpAppID="+ExpenceApplicationID+"&requestType=INVEST", "", 1070, (window.screen.height-100), "both");
			},
			
			refresh : function(){
				accountCtrl.pageRefresh();
			}
	}
	window.InvestUseList = InvestUseList;
})(window);

</script>