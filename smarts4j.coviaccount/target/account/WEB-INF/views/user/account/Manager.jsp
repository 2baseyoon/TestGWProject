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
					<a class="btnTypeDefault  btnTypeBg"	onclick="Manager.managerAdd();"><spring:message code="Cache.ACC_btn_add"/></a>
					<!-- 삭제 -->
					<a class="btnTypeDefault"				onclick="Manager.managerDel();"><spring:message code="Cache.ACC_btn_delete"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"				onclick="Manager.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"		onclick="Manager.excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
				</div>
				<!-- 상단 버튼 끝 -->				
			</div>
			
			<!-- 검색 내용 -->
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type07">
					<div style="width:1200px;">
						<div class="inPerTitbox">
							<!-- 회사 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_company"/></span>
							<span id="managerCompanyCode" class="selectType02" onchange="Manager.changeCompanyCode()">
							</span>
						</div>	
						<div class="inPerTitbox">
							<!-- 등록일 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_registDate"/></span>
							<div id="ddArea" class="dateSel type02">
							</div>
						</div>
						<div class="inPerTitbox">
							<!-- 구분 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_division"/></span>
							<span id="managerSearchType" class="selectType02">
							</span>
							<input onkeydown="Manager.onenter()" id="searchStr" type="text" placeholder="">
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="Manager.searchList();"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="Manager.searchList();">
					</span>
					<button class="btnRefresh" type="button" onclick="Manager.searchList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
	</div>
<script>
	
	if (!window.Manager) {
		window.Manager = {};
	}
	
	(function(window) {
		var Manager = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
			
				pageInit : function() {
					var me = this;
					setHeaderTitle('headerTitle');
					me.pageDatepicker();
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
		
				pageDatepicker : function(){
					makeDatepicker('ddArea','startDD','endDD','','','');
				},
				
				setSelectCombo : function(pCompanyCode){
					var AXSelectMultiArr	= [	
								{'codeGroup':'listCountNum',		'target':'listCount',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
							,	{'codeGroup':'managerSearchType',	'target':'managerSearchType',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"} //전체
							,	{'codeGroup':'CompanyCode',			'target':'managerCompanyCode',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
	   					]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				},
				
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("managerListCount");
					accountCtrl.refreshAXSelect("managerSearchType");
					accountCtrl.refreshAXSelect("managerCompanyCode");
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("managerCompanyCode").val());
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'chk',			label:'chk',		width:'20', align:'center',
													formatter:'checkbox'
												},
												{	key:'CompanyName',		label:"<spring:message code='Cache.ACC_lbl_company' />",			width:'50', align:'center'},	//회사
												{	key:'TaxMailAddress',	label:"<spring:message code='Cache.ACC_lbl_taxMail' />",			width:'70', align:'center'},	//담당자Email
												{	key:'DisplayName',		label:"<spring:message code='Cache.ACC_lbl_contactName' />",		width:'50', align:'center'		//담당자명
													,formatter:function () {
									            		 return "<a onclick=\"Manager.onUserClick('" + this.item.ManagerID + "');\"><font color='blue'><u>"+this.item.DisplayName+"</u></font></a>";
									            	}
												},
												{	key:'RegistDate',		label:"<spring:message code='Cache.ACC_lbl_registDate' />"+Common.getSession("UR_TimeZoneDisplay"),		width:'50', align:'center',
													formatter:function(){
														return CFN_TransLocalTime(this.item.RegistDate,_ServerDateSimpleFormat);
													}, dataType:'DateTime'
												}		//등록일자
											]
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var companyCode			= accountCtrl.getComboInfo("managerCompanyCode").val();
					var startDD 			= accToString(accountCtrl.getInfo('startDD').val());
					var endDD 				= accToString(accountCtrl.getInfo('endDD').val());					
					var searchStr			= accountCtrl.getInfo("searchStr").val();
					var managerSearchType	= accountCtrl.getComboInfo("managerSearchType").val();
					var pageSizeInfo		= accountCtrl.getComboInfo("managerListCount").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					
					var pageNoInfo		= accountCtrl.getGridViewPageNum(YN,gridPanel,pageSizeInfo);
					
					var ajaxUrl			= "/account/manager/getManagerlist.do";
					var ajaxPars		= {	"companyCode"		: companyCode,
											"startDD"			: startDD,
							 				"endDD"				: endDD,
							 				"searchStr"			: searchStr,
							 				"managerSearchType"	: managerSearchType,
							 				"pageSize"			: pageSizeInfo,
							 				"pageNo"			: pageNoInfo
					};
					
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
				
				excelDownload : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
							var headerName			= accountCommon.getHeaderNameForExcel(me.params.headerData);
							var headerKey 			= accountCommon.getHeaderKeyForExcel(me.params.headerData);

							var companyCode			= accountCtrl.getComboInfo("managerCompanyCode").val();
							var startDD 			= accToString(accountCtrl.getInfo('startDD').val());
							var endDD 				= accToString(accountCtrl.getInfo('endDD').val());
							var managerSearchType	= accountCtrl.getComboInfo("managerSearchType").val();	//구분
							var searchStr			= accountCtrl.getInfo("searchStr").val();	//조회문장
							var headerType			= accountCommon.getHeaderTypeForExcel(me.params.headerData);
							var title 				= accountCtrl.getInfo("headerTitle").text();
									
							var	locationStr		= "/account/manager/managerExcelDownload.do?"
												//+ "headerName="			+ encodeURI(headerName)
												+ "headerName="			+ encodeURIComponent(encodeURIComponent(headerName))
												+ "&headerKey="			+ encodeURI(headerKey)
												+ "&companyCode="		+ encodeURI(companyCode)
												+ "&startDD="			+ encodeURI(startDD)
												+ "&endDD="				+ encodeURI(endDD)
												+ "&managerSearchType="	+ encodeURI(managerSearchType)
												+ "&searchStr="			+ encodeURI(searchStr)
												//+ "&title="				+ encodeURI(accountCtrl.getInfo("headerTitle").text())
												+ "&title="				+ encodeURIComponent(encodeURIComponent(title))
												+ "&headerType=" + encodeURI(headerType);
							
							location.href = locationStr;
			       		}
					});
				},
				
				managerDel : function(){
					var me = this;
					var deleteObj = me.params.gridPanel.getCheckedList(0);
					if(deleteObj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noDataDelete' />");	//삭제할 항목을 선택하여 주십시오
						return;
					}else{
						Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){ //삭제하시겠습니까?
							if(result){
								var deleteSeq = "";
								for(var i=0; i<deleteObj.length; i++){
									if(i==0){
										deleteSeq = deleteObj[i].ManagerID;
									}else{
										deleteSeq = deleteSeq + "," + deleteObj[i].ManagerID;
									}
								}
								$.ajax({
									url : "/account/manager/deleteManagerInfo.do",
									type: "POST",
									data: {
										"deleteSeq" : deleteSeq
									},
									success:function (data){
										if(data.status == "SUCCESS"){
											Common.Inform("<spring:message code='Cache.ACC_msg_delComp' />");	//삭제를 완료하였습니다
											Manager.searchList();
										}else{
											Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
										}
									},
									error:function (error){
										Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
									}				
								});
							}
						})
					}
				},
				
				managerAdd : function(){
					var mode		= "add"
					var popupID		= "ManagerPopup";
					var openerID	= "Manager";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_manager' />";	//담당자
					var popupYN		= "N";
					var callBack	= "ManagerPopup_CallBack";
					var popupUrl	= "/account/manager/getManagerPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "mode="			+ mode;
					
					Common.open("", popupID, popupTit, popupUrl, "420px", "300px", "iframe", true, null, null, true);
				},
				
				onUserClick : function(ManagerID){
					var mode		= "view"
					var popupID		= "ManagerPopup";
					var openerID	= "Manager";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_manager' />";	//담당자
					var popupYN		= "N";
					var callBack	= "ManagerPopup_CallBack";
					var popupUrl	= "/account/manager/getManagerPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "ManagerID="	+ ManagerID	+ "&"
									+ "mode="			+ mode;
					
					Common.open("", popupID, popupTit, popupUrl, "420px", "300px", "iframe", true, null, null, true);
				},
				
				ManagerPopup_CallBack : function(){
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
		window.Manager = Manager;
	})(window);
</script>