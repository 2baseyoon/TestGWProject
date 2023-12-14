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
	<input id="saveProperty" type="hidden" />
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<a class="btnTypeDefault"					onclick="InterfaceLogView.refresh()"><spring:message code='Cache.ACC_btn_refresh'/></a>
				</div>
				<!-- 상단 버튼 끝 -->				
			</div>
			<div class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 회사 -->
								<spring:message code="Cache.ACC_lbl_company"/>
							</span>
							<span id="ifCompanyCode" class="selectType02" onchange="InterfaceLogView.changeCompanyCode()">
							</span>
						</div>	
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!--  인터페이스대상종류	-->
								<spring:message code='Cache.ACC_lbl_interfaceTargetType'/>
							</span>
							<input onkeydown="InterfaceLogView.onenter()" id="ifTargetType" type="text" placeholder="">
						</div>						
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 인터페이스메소드명 -->
								<spring:message code='Cache.ACC_lbl_interfaceMethodName'/>
							</span>
							<input onkeydown="InterfaceLogView.onenter()" id="ifMethodName" type="text" placeholder="">
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 인터페이스 전송방향 -->
								<spring:message code='Cache.ACC_interfaceRecvType'/>
							</span>
							<span id="interfaceRecvType" class="selectType02">
							</span>
						</div>						
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 인터페이스 방식종류 -->
								<spring:message code='Cache.ACC_lbl_interfaceType'/>
							</span>
							<span id="interfaceType" class="selectType02">
							</span>
						</div>						
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 인터페이스 상태 -->
								<spring:message code='Cache.ACC_lbl_interfaceStatus'/>
							</span>
							<span id="interfaceStatus" class="selectType02">
							</span>
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="InterfaceLogView.searchList('Y');"><spring:message code='Cache.ACC_btn_search'/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">
					<span id="listCount" class="selectType02 listCount" onchange="InterfaceLogView.searchList('Y');">
					</span>
					<button class="btnRefresh" type="button" onclick="InterfaceLogView.searchList('Y');"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>
	
	if (!window.InterfaceLogView) {
		window.InterfaceLogView = {};
	}
	
	(function(window) {
		var InterfaceLogView = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
			
				pageInit : function() {
					var me = this;
					setHeaderTitle('headerTitle');
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
				
				setSelectCombo : function(pCompanyCode){
					accountCtrl.getInfo("listCount").children().remove();
					accountCtrl.getInfo("interfaceRecvType").children().remove();
					accountCtrl.getInfo("interfaceStatus").children().remove();
					accountCtrl.getInfo("interfaceType").children().remove();

					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "InterfaceLogView.searchList('Y');");
					accountCtrl.getInfo("interfaceRecvType").addClass("selectType02");
					accountCtrl.getInfo("interfaceStatus").addClass("selectType02");
					accountCtrl.getInfo("interfaceType").addClass("selectType02");
					
					var AXSelectMultiArr	= [	
								{'codeGroup':'listCountNum',		'target':'listCount',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
							,	{'codeGroup':'InterfaceRecvType',	'target':'interfaceRecvType',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
							,	{'codeGroup':'InterfaceStatus',		'target':'interfaceStatus',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
							,	{'codeGroup':'InterfaceType',		'target':'interfaceType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
							,	{'codeGroup':'CompanyCode',			'target':'ifCompanyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
	   					]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("ifCompanyCode").val());
				},
				
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("interfaceRecvType");
					accountCtrl.refreshAXSelect("interfaceStatus");
					accountCtrl.refreshAXSelect("interfaceType");
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:"CompanyName",		label:"<spring:message code='Cache.ACC_lbl_company' />",				width:'70',align:'center'}	//회사
											,	{	key:'IfTargetType',		label:"<spring:message code='Cache.ACC_lbl_interfaceTargetType' />",	width:'70',align:'left'}	//인터페이스대상종류
											,	{	key:'IfMethodName',		label:"<spring:message code='Cache.ACC_lbl_interfaceMethodName' />",	width:'70',align:'left'}	//인터페이스메소드명
											,	{	key:'IfRecvTypeName',	label:"<spring:message code='Cache.ACC_interfaceRecvType' />",			width:'70',align:'center'}	//인터페이스전송방향
											,	{	key:'IfTypeName',		label:"<spring:message code='Cache.ACC_lbl_interfaceType' />",			width:'70',align:'center'}	//인터페이스방식종류
											,	{	key:'IfCnt',			label:"<spring:message code='Cache.ACC_lbl_interfaceCount' />",			width:'70',align:'right'}	//인터페이스처리건수
											,	{	key:'IfStatusName',		label:"<spring:message code='Cache.ACC_lbl_interfaceStatus' />",		width:'70',align:'center'}	//인터페이스상태
											,	{	key:'ErrorLog',			label:"<spring:message code='Cache.ACC_lbl_errorLog' />",				width:'70',align:'left'}	//에러로그
											,	{	key:'InterfaceDate',	label:"<spring:message code='Cache.ACC_lbl_interfaceDate' />",			width:'70',align:'center'}	//실행일시
											]
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var ifCompanyCode		= accountCtrl.getComboInfo("ifCompanyCode").val();
					var ifTargetType		= accountCtrl.getInfo("ifTargetType").val();
					var ifMethodName		= accountCtrl.getInfo("ifMethodName").val();
					var interfaceRecvType	= accountCtrl.getComboInfo("interfaceRecvType").val();
					var interfaceStatus		= accountCtrl.getComboInfo("interfaceStatus").val();
					var interfaceType		= accountCtrl.getComboInfo("interfaceType").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/accountCommon/getInterfaceLogViewList.do";
					var ajaxPars		= {	"companyCode"		: ifCompanyCode
										,	"ifTargetType"		: ifTargetType
										,	"ifMethodName"		: ifMethodName
										,	"interfaceRecvType"	: interfaceRecvType
										,	"interfaceStatus"	: interfaceStatus
										,	"interfaceType"		: interfaceType
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
		window.InterfaceLogView = InterfaceLogView;
	})(window);
</script>