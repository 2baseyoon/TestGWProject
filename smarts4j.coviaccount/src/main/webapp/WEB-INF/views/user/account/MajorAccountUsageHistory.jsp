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
					<a class="btnTypeDefault" onclick="MajorAccountUsageHistory.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"	onclick="MajorAccountUsageHistory.excelDownload()"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
				</div>
				<!-- 상단 버튼 끝 -->				
			</div>
			<div id="searchbar" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 회사 -->
								<spring:message code="Cache.ACC_lbl_company"/>
							</span>
							<span id="CompanyCode" name="searchParam" class="selectType02"></span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 전표년월 -->
								<spring:message code="Cache.ACC_slipYearMonth"/>
							</span>
							<input type="text" id="PostingDate" name="searchParam" class="W70" kind="date" date_selectType="m" style="width: 90px;"/>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 표준적요 -->
								<spring:message code="Cache.ACC_standardBrief"/>								
							</span>
							<select id="StandardBriefID" name="searchParam" class="selectType02"></select>
						</div>	
						<a href="#" class="btnTypeDefault btnSearchBlue" onclick="MajorAccountUsageHistory.searchList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="MajorAccountUsageHistory.searchList()"></span>
					<button class="btnRefresh" type="button" onclick="MajorAccountUsageHistory.searchList()"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

if (!window.MajorAccountUsageHistory) {
	window.MajorAccountUsageHistory = {};
}

(function(window) {
	var MajorAccountUsageHistory = {
			params	:{
				gridPanel	: new coviGrid(),
				headerData	: []
			},

			pageInit : function() {
				var me = this;
				setHeaderTitle('headerTitle');
				
				coviInput.setDate();
				
				var date = new Date();
				var lastDayOfMonth = new Date(date.getFullYear(), date.getMonth() , 1);
				var prevMonth = new Date (lastDayOfMonth.setDate(lastDayOfMonth.getDate() - 1));

				accountCtrl.getInfo("PostingDate").val(prevMonth.getFullYear() + "-" + XFN_AddFrontZero(prevMonth.getMonth()+1, 2));
				
				me.setSelectCombo();
				me.searchList('Y');
			},

			pageView : function() {
				var me = this;
				
				me.refreshCombo();
				me.searchList();
			},
			
			setSelectCombo : function(){
				var me = this;
				
				var AXSelectMultiArr	= [	
						{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
					,	{'codeGroup':'CompanyCode',		'target':'CompanyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':accComm.getCompanyCodeOfUser(sessionObj["UR_Code"])}
				]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				
				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getStandardBriefCtrlCombo.do",
					data:{
						"CompanyCode": accountCtrl.getComboInfo("CompanyCode").val()
					},
					async: false,
					success:function (data) {
						if(data.result == "ok"){
							var htmlStr = "<option value='' selected>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";
							for(var i = 0; i < data.list.length; i++){
								var item = data.list[i];
								if(item.IsUse != "N"){
									htmlStr = htmlStr + "<option value='"+ item.StandardBriefID + "'>" + item.StandardBriefName + "</option>";
								}
							}
							accountCtrl.getInfo("StandardBriefID").html(htmlStr);
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

			refreshCombo : function() {
				accountCtrl.refreshAXSelect("CompanyCode");
				accountCtrl.refreshAXSelect("listCount");
			},
			
			setHeaderData : function() {
				var me = this;
				me.params.headerData = [	{	key:'CompanyName',		label:"<spring:message code='Cache.ACC_lbl_company' />",	width:'100',		align:'center'},	//회사
											{	key:'ApplicationTitle',	label:"<spring:message code='Cache.ACC_lbl_title' />",		width:'200',		align:'left',		//제목
													formatter:function () {
														var rtStr =	""
																	+	"<a onclick=\"MajorAccountUsageHistory.openExpAppPopup('"+this.item.ExpenceApplicationID+"', '"+this.item.ProcessID+"', '"+this.item.FormInstID+"', '"+this.item.ApplicationStatus+"'); return false;\">"
																	+		"<font color='blue'>"
																	+			this.item.ApplicationTitle
																	+		"</font>"
																	+	"</a>";
														return rtStr;
													}
											},	
											{	key:'DeptName',			label:"<spring:message code='Cache.lbl_apv_writedept' />",	width:'100',		align:'center'},	//기안부서
											{	key:'UserName',			label:"<spring:message code='Cache.lbl_apv_writer' />",		width:'100',		align:'center'},	//기안자
											{	key:'PostingDate',		label:"<spring:message code='Cache.ACC_lbl_slipDate' />",	width:'100',		align:'center'},	//전표일자
				    						{	key:'CostCenterName',	label:"<spring:message code='Cache.ACC_lbl_costCenter' />",	width:'150',		align:'center'},	//코스트센터
				    						{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_account' />",	width:'150',		align:'center'},	//계정과목
				    						{	key:'StandardBriefName',label:"<spring:message code='Cache.ACC_standardBrief' />",	width:'150',		align:'center'},	//표준적요
				    						{	key:'TotalAmount',		label:"<spring:message code='Cache.ACC_lbl_totalAmount' />",width:'100',		align:'right', formatter:"money"},	//합계금액
				    						{	key:'Amount',			label:"<spring:message code='Cache.ACC_billReqAmt' />",		width:'100',		align:'right', formatter:"money"},	//청구금액
				    						{	key:'UsageComment',		label:"<spring:message code='Cache.ACC_lbl_useHistory2' />",width:'200',		align:'left'},		//적요				    						
				    					]
				
				// 관리항목 header 가져오기
				if(accountCtrl.getInfo("StandardBriefID").val() != "") {
					$.ajax({
						type:"POST",
						url:"/account/expenceApplication/getCtrlCodeHeader.do",
						data:{
							"StandardBriefID": accountCtrl.getInfo("StandardBriefID").val()
						},
						async: false,
						success:function (data) {
							if(data.result == "ok"){
								if(data.list != null && data.list.length > 0) {
									for(var i = 0; i < data.list.length; i++){
										var jsonData = {};
										jsonData.key = data.list[i].Code.replace(/\"/gi, "");
										jsonData.label = data.list[i].CodeName.replace(/\"/gi, "");
										jsonData.width = '100',
										jsonData.align = 'center';
										jsonData.sort = false;
										
										me.params.headerData.push(jsonData);
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
				var ajaxUrl			= "/account/expenceApplication/getMajorAccountUsageHistory.do";
				var ajaxPars		= {	
										"searchParam" : JSON.stringify(searchParam)
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
								,	"fitToWidth"	: false
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
						//AXSelect
						if(item.nodeName == "SELECT" && item.getAttribute("data-axbind") == "select") {
							id = $(item).parents("span").attr("id");
						}
						
						if(id == "PostingDate") {
							retVal[id] = item.value.replace(/\-/gi, '');
						} else {
							retVal[id] = item.value;
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
						var	locationStr		= "/account/expenceApplication/getMajorAccountUsageHistoryExcel.do?"
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
				CFN_OpenWindow("/account/expenceApplication/ExpenceApplicationViewPopup.do?mode=COMPLETE&processID="+ProcessID+"&forminstanceID="+FormInstID+"&ExpAppID="+ExpenceApplicationID+"&requestType=INVEST", "", 1070, (window.screen.height-100), "both");
			},
			
			refresh : function(){
				accountCtrl.pageRefresh();
			}
	}
	window.MajorAccountUsageHistory = MajorAccountUsageHistory;
})(window);

</script>