
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
			</div>
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 회사 -->
								<spring:message code='Cache.ACC_lbl_company'/>
							</span>
							<span id="companyCode" class="selectType02" name="searchParam" tag="companyCode" onchange="CardCompare.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 사용일자 -->
								<spring:message code='Cache.ACC_lbl_approveDate'/>
							</span>
							<div id="useDate" class="dateSel type02">
							</div>
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="CardCompare.searchList();"><spring:message code='Cache.ACC_btn_search'/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="CardCompare.searchList();">
					</span>
					<button class="btnRefresh" type="button" onclick="CardCompare.searchList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

	if (!window.CardCompare) {
		window.CardCompare = {};
	}
	
	(function(window) {
		var CardCompare = {
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
					makeDatepicker('useDate','useDateS','useDateE','','','');
				},
				
				setSelectCombo : function(pCompanyCode){
					var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}	//전체
						
						]
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
					
					
					if(pCompanyCode == undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
				},
				
				
				changeCompanyCode : function (){
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());	
				},
				
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("companyCode");
				},

				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'CARDNO',				label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",			width:'200',	align:'center'},	//카드번호
												{	key:'CARDCLASS',			label:"<spring:message code='Cache.ACC_lbl_cardClass' />",			width:'150',		align:'center'},	//카드유형
												//{	key:'OWNERUSERCODE',		label:"<spring:message code='Cache.ACC_lbl_cardOwner' />",			width:'150',		align:'center'},	//소유자코드
												{	key:'DISPLAYNAME',			label:"<spring:message code='Cache.ACC_lbl_cardOwner' />",			width:'150',		align:'center'},	//소유자
												{	key:'AMT_TOT',				label:"<spring:message code='Cache.ACC_lbl_TotAmt' />",				width:'150',		align:'right'},	//총액
												{	key:'AMT_USE_N',			label:"<spring:message code='Cache.ACC_lbl_NoUseAmt' />",			width:'150',		align:'right'},	//미신청금액
												{	key:'AMT_USE_Y',			label:"<spring:message code='Cache.ACC_lbl_applicationAmt' />",		width:'150',		align:'right'},	//신청금액
												{	key:'AMT_USE_P',			label:"<spring:message code='Cache.ACC_lbl_PersonalAmt' />",		width:'150',		align:'right'}		//개인사용금액
											]
					
					var gridPanel	= me.params.gridPanel; 
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},

				searchList : function(YN){
					var me = this;
					me.setHeaderData();
					
					var companyCode		= accountCtrl.getComboInfo("companyCode").val();
					var useDateS		= accountCtrl.getInfo("useDateS").val();
					var useDateE		= accountCtrl.getInfo("useDateE").val();
					useDateS = useDateS.replace(/\./gi, '');
					useDateE = useDateE.replace(/\./gi, '');
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/cardReceipt/getCardCompare.do";
					var ajaxPars		= {	"companyCode"	: companyCode,
							 				"useDateS"		: useDateS,
							 				"useDateE"		: useDateE
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
				
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.CardCompare = CardCompare;
	})(window);

</script>