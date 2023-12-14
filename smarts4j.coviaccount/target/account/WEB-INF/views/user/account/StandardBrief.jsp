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
					<!-- 추가 -->
					<a class="btnTypeDefault btnTypeChk"		onclick="StandardBrief.standardBriefAddPopup()"><spring:message code="Cache.ACC_btn_add"/></a>
					<!-- 삭제 -->
					<a class="btnTypeDefault"					onclick="StandardBrief.standardBriefDel()"><spring:message code="Cache.ACC_btn_delete"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"					onclick="StandardBrief.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"			onclick="StandardBrief.excelDownload()"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 엑셀업로드 -->
					<a class="btnTypeDefault btnExcel_upload"	onclick="StandardBrief.excelUpload()"><spring:message code="Cache.ACC_lbl_excelUpload"/></a>
				</div>
				<!-- 상단 버튼 끝 -->
			</div>
			
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type07">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 회사 -->
								<spring:message code="Cache.ACC_lbl_company"/>
							</span>
							<span id="companyCode" class="selectType02" onchange="StandardBrief.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 구분 -->
								<spring:message code="Cache.ACC_lbl_division"/>
							</span>
							<span id="searchType" class="selectType02">
							</span>
							<input onkeydown="StandardBrief.onenter()" id="searchStr" type="text" placeholder="">
						</div>
						<a class="btnTypeDefault  btnSearchBlue"	onclick="StandardBrief.searchList()"><spring:message code='Cache.ACC_btn_search'/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="StandardBrief.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="StandardBrief.searchList()"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>
	if (!window.StandardBrief) {
		window.StandardBrief = {};
	}
	
	(function(window) {
		var StandardBrief = {
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
					accountCtrl.getInfo("searchType").children().remove();

					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "StandardBrief.searchList()");
					accountCtrl.getInfo("searchType").addClass("selectType02");
					
					var AXSelectMultiArr	= [
								{'codeGroup':'listCountNum',	'target':'listCount',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
							,	{'codeGroup':'sbSearchType',	'target':'searchType',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"} //전체
							,	{'codeGroup':'CompanyCode',		'target':'companyCode',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
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
					me.params.headerData = [	{	key:'chk',					label:'chk',														width:'20', align:'center',
													formatter:'checkbox'
												},
												{	key:'CompanyCode',		label:"<spring:message code='Cache.ACC_lbl_companyCode' />",			width:'70',	align:'center', display: false},		//회사코드
												{	key:'CompanyName',		label:"<spring:message code='Cache.ACC_lbl_company' />",				width:'70',	align:'center'},		//회사
												{	key:'AccountCode',			label:"<spring:message code='Cache.ACC_lbl_accountCode' />",		width:'70', align:'center',		//계정코드
													formatter:function () {
														var rtStr =	""
																	+	"<a onclick='StandardBrief.standardBriefPopup("+ this.item.AccountID +"); return false;'>"
																	+		"<font color='blue'>"
																	+			this.item.AccountCode
																	+		"</font>"
																	+	"</a>";
														return rtStr;
													}
												},
												{	key:'AccountName',			label:"<spring:message code='Cache.ACC_lbl_accountName' />",		width:'70', align:'center'},		//계정명
												{	key:'StandardBriefName',	label:"<spring:message code='Cache.ACC_standardBrief' />",			width:'200', align:'center'},		//표준적요
												{	key:'RegistDate',			label:"<spring:message code='Cache.ACC_lbl_registDate' />"+Common.getSession("UR_TimeZoneDisplay"),			width:'70', align:'center',
													formatter:function(){
														return CFN_TransLocalTime(this.item.RegistDate,_ServerDateSimpleFormat);
													}, dataType:'DateTime'
												}		//등록일자
											]
					me.params.excelHeaderData = [	{	key:'chk',				label:'chk',		width:'20', align:'center',
														formatter:'checkbox'
													},
													{	key:'AccountCode',		label:"<spring:message code='Cache.ACC_lbl_accountCode' />",		width:'70', align:'center'},	//계정코드
													{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_accountName' />",		width:'70', align:'center'},	//계정이름
													{	key:'StandardBriefName',label:"<spring:message code='Cache.ACC_standardBrief' />",			width:'70', align:'center'},	//표준적요
													{	key:'StandardBriefDesc',label:"<spring:message code='Cache.ACC_lbl_standardBriefDesc' />",	width:'70', align:'left'},		//표준적요설명
													{	key:'IsUse',			label:"<spring:message code='Cache.ACC_lbl_isUse' />",				width:'70', align:'center'},	//사용여부
													{	key:'IsUseSimp',		label:"<spring:message code='Cache.ACC_lbl_simpleApplication' />",	width:'70', align:'center'},	//간편신청
													{	key:'RegistDate',		label:"<spring:message code='Cache.ACC_lbl_registDate' />"+Common.getSession("UR_TimeZoneDisplay"), dataType:'DateTime',			width:'70', align:'center'},		//등록일
													{	key:'CompanyCode',		label:"<spring:message code='Cache.ACC_lbl_companyCode' />",			width:'70',	align:'center'},	//회사코드
													{	key:'CompanyName',		label:"<spring:message code='Cache.ACC_lbl_companyName' />",			width:'70',	align:'center'}		//회사명
												]
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var companyCode	= accountCtrl.getComboInfo("companyCode").val();
					var searchType	= accountCtrl.getComboInfo("searchType").val();
					var searchStr	= accountCtrl.getInfo("searchStr").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/standardBrief/getStandardBrieflist.do";
					var ajaxPars		= {	"companyCode"	: companyCode,
							 				"searchType"	: searchType,
							 				"searchStr"		: searchStr
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
				
				standardBriefDel : function(){
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
									url	:"/account/standardBrief/deleteStandardBriefInfoByAccountID.do",
									type: "POST",
									data: {
											"deleteSeq" : deleteSeq
									},
									success:function (data) {
										if(data.status == "SUCCESS"){
											Common.Inform("<spring:message code='Cache.ACC_msg_delComp' />");	//삭제를 완료하였습니다.
											StandardBrief.refresh();
										}else{
											Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
										}
									},
									error:function (error){
										Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
									}
								});
							}
						})
					}
				},
				
				excelUpload : function(){
					/* var popID	= "standardBriefExcelPopup";
					var popTit	= "<spring:message code='Cache.ACC_standardBrief' />");
					var popUrl	= "/account/standardBrief/standardBriefExcelPopup.do";
					
					Common.open("", popID, popTit, popUrl, "500px", "220px", "iframe", true, null, null, true); */
					
					var popupID		= "standardBriefExcelPopup";
					var openerID	= "StandardBrief";
					var popupTit	= "<spring:message code='Cache.ACC_standardBrief' />";	//표준적요
					var popupYN		= "N";
					var callBack	= "standardBriefExcelPopup_CallBack";
					var popupUrl	= "/account/standardBrief/standardBriefExcelPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack;

					Common.open("", popupID, popupTit, popupUrl, "500px", "220px", "iframe", true, null, null, true);
				},
				
				standardBriefExcelPopup_CallBack : function(){
					var me = this;
					me.searchList();
				},
				
				excelDownload : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
							var headerName	= accountCommon.getHeaderNameForExcel(me.params.excelHeaderData);
							var headerKey	= accountCommon.getHeaderKeyForExcel(me.params.excelHeaderData);
							var companyCode	= accountCtrl.getComboInfo("companyCode").val();	//회사 코드
							var searchType	= accountCtrl.getComboInfo("searchType").val();	//구분
							var searchStr	= accountCtrl.getInfo("searchStr").val();	//조회문장
							var headerType			= accountCommon.getHeaderTypeForExcel(me.params.excelHeaderData);
							var title 		= accountCtrl.getInfo("headerTitle").text();
							var	locationStr		= "/account/standardBrief/standardBriefExcelDownload.do?"
												//+ "headerName="		+ encodeURI(headerName)
												+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
												+ "&headerKey="		+ encodeURI(headerKey)
												+ "&companyCode="	+ encodeURI(companyCode)
												+ "&searchType="	+ encodeURI(searchType)
												+ "&searchStr="		+ encodeURI(searchStr)
												//+ "&title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text())
												+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
												+ "&headerType=" + encodeURI(headerType);
							
							location.href = locationStr;
						}
					});
				},
				
				standardBriefAddPopup : function(){
					var mode		= "add";
					var popupID		= "standardBriefPopup";
					var openerID	= "StandardBrief";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_standardBriefAdd' />";	//표준적요등록
					var popupYN		= "N";
					var callBack	= "standardBriefPopup_CallBack";
					var popupUrl	= "/account/standardBrief/getStandardBriefPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "mode="			+ mode;
							
					Common.open("", popupID, popupTit, popupUrl, "1000px", "490px", "iframe", true, null, null, true);
				},
				
				standardBriefPopup : function(key){
					var mode		= "modify";
					var popupID		= "standardBriefPopup";
					var openerID	= "StandardBrief";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_standardBriefModify' />";	//표준적요 관리
					var popupYN		= "N";
					var callBack	= "standardBriefPopup_CallBack";
					var popupUrl	= "/account/standardBrief/getStandardBriefPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "accountID="		+ key		+ "&"
									+ "mode="			+ mode;
							
					Common.open("", popupID, popupTit, popupUrl, "1000px", "490px", "iframe", true, null, null, true);
				},
				
				standardBriefPopup_CallBack : function(){
					var me = this;
					me.searchList();
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
		window.StandardBrief = StandardBrief;
	})(window);
</script>