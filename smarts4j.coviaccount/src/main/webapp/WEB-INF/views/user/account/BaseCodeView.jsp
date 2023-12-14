<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.coviaccount.common.util.AccountUtil" %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/account/resources/script/user/baseCodeCommon.js<%=resourceVersion%>"></script>
<style>
.pad10 { padding:10px;}
</style>
	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<h2 class="title" id="baseCodeView_pageTitle"></h2>
	</div>
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<!-- 상단 버튼 시작 -->
			<div class="eaccountingTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					 <a class="btnTypeDefault"  	onclick="BaseCodeView<%=request.getParameter("viewCd") %>.searchBaseCode();"><spring:message code="Cache.ACC_btn_refresh"/></a>
					 
					<%
					String viewCD = request.getParameter("viewCd");
					AccountUtil accountUtil = new AccountUtil();
					String getProperty = accountUtil.getBaseCodeInfo("eAccSyncType", "BaseCode"+viewCD);
					if(getProperty==null){
						getProperty = "";
					}
					if(!"".equals(getProperty) || "OP".equals(viewCD)){
					%>
					<a class="btnTypeDefault"  	onclick="BaseCodeView<%=request.getParameter("viewCd") %>.syncData('<%=viewCD%>');"><spring:message code="Cache.ACC_btn_sync"/></a>
					<% 
					}
					%>
					 
				</div>
			</div>
			
			<div class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;"><!-- 항목 넓이를 인라인으로 조정 -->
						<div class="inPerTitbox">
							<!-- 회사 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_company"/></span>
							<span id="companyCode" class="selectType02" onchange="BaseCodeView<%=request.getParameter("viewCd") %>.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox" style='display: none;'>
							<!-- 코드그룹 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_codeGroup"/></span>
							<span id="searchCodeGroupCombo" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">	
							<!-- 코드명 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_codeNm"/></span>
							<input id="inputSearchText" class="sm" type="text" onkeydown="BaseCodeView<%=request.getParameter("viewCd") %>.onenter()">							
						</div>
						<a class="btnTypeDefault btnSearchBlue" onclick="BaseCodeView<%=request.getParameter("viewCd") %>.searchBaseCode();"><spring:message code="Cache.ACC_btn_search"/></a><!-- 버튼위치를 인라인으로 조정 -->
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span class="selectType02 listCount" id="listCount" onchange="BaseCodeView<%=request.getParameter("viewCd") %>.searchBaseCode();">
					</span>
					<button class="btnRefresh" type="button" onclick="accountCtrl.pageRefresh();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>

<script>

	if (!window.BaseCodeView) {
		window.BaseCodeView = {};
	}
	
	if (!window.BaseCodeView<%=request.getParameter("viewCd") %>) {
		window.BaseCodeView<%=request.getParameter("viewCd") %> = {};
	}
	
	/**
	특정 기초코드 조회용 목록
	(회사코드, 세금코드 등)
	*/
	(function(window) {
		
		var BaseCodeView = {
				pageInit : function() {
					window.BaseCodeView<%=request.getParameter("viewCd") %>.pageInit();
				},
				pageView : function(param) {
					var pageId = param.id;
					var idx = pageId.indexOf("BaseCodeView");
					var pageViewCd = pageId.substr(idx, 14);
					var viewCd = pageId.substr(idx+12, 2);
					if(window[pageViewCd] != null){
						if(typeof(window[pageViewCd]["pageView"]) == "function"){
							window[pageViewCd]["pageView"](viewCd);
						}
					}
				}
		}
		
		/**
		코드에 따라 분기
		*/
		var BaseCodeView<%=request.getParameter("viewCd") %> = {
				params	:{
					viewCd			: "<%=request.getParameter("viewCd") %>",
					pageGroupCode	: '',
					pageTitle		: '',
					gridPanel		: new coviGrid(),
					headerData		: []
				},
				
				pageInit : function() {
					var me = this;
					var pageGroupCode	= baseCodeCommon.getBaceCodeGrp(me.params.viewCd); 
					var pageTitle		= baseCodeCommon.getBaseCodeTitle(me.params.viewCd);
					
					var msg =  Common.getDic("ACC_msg_codeView"+me.params.viewCd);
					accountCtrl.getInfo("inputSearchText")[0].placeholder = msg

					me.params.pageTitle		= pageTitle;
					me.params.pageGroupCode	= pageGroupCode;
					
					accountCtrl.getInfo("baseCodeView_pageTitle")[0].innerHTML = me.params.pageTitle;
					
					me.setSelectCombo();
					me.setHeaderData();
					me.searchBaseCode('Y');
				},

				pageView : function(viewCd) {
					var me = this;
					me.setHeaderData();
					me.refreshCombo();
					
					var gridAreaID		= "gridArea";
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

				setSelectCombo : function(pCompanyCode){
					var me = this;
					
					accountCtrl.getInfo("searchCodeGroupCombo").children().remove();
					accountCtrl.getInfo("listCount").children().remove();
					
					accountCtrl.getInfo("searchCodeGroupCombo").addClass("selectType02");
					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "BaseCodeView"+me.params.viewCd+".searchBaseCode()");					
					
					accountCtrl.renderAXSelect('listCountNum','listCount','ko','','','',null,pCompanyCode);
					accountCtrl.renderAXSelectGrp('searchCodeGroupCombo','ko','','',me.params.pageGroupCode,'',pCompanyCode);

					if(pCompanyCode == undefined) {
						accountCtrl.renderAXSelect('CompanyCode', 'companyCode', 'ko','','','');
					}					
				},

				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("companyCode");
					accountCtrl.refreshAXSelect("searchCodeGroupCombo");
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
				},

				setHeaderData : function() {
					var me = this;
					var gridHeaderData	= baseCodeCommon.getGridHeader(me.params.viewCd);
					me.params.headerData = gridHeaderData;
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				/**
				목록조회
				*/
				searchBaseCode : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var searchText	= accountCtrl.getInfo("inputSearchText").val();
					var searchGrp	= accountCtrl.getComboInfo("searchCodeGroupCombo").val();
					var pageSize	= accountCtrl.getComboInfo("listCount").val();
					var companyCode	= accountCtrl.getComboInfo("companyCode").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/baseCode/searchBaseCodeView.do";
					var ajaxPars		= {	"searchText"	: searchText,
											"searchGrp"		: searchGrp,
											"pageSize"		: pageSize,
											"companyCode"	: companyCode
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
				
				
				/**
				코드 상세조회
				*/
				onCodeClick : function (inputBaseCodeID){
					var me = this;
					
					var baseCodeId	= inputBaseCodeID;
					var groupCode	= me.params.pageGroupCode;
					var popupID		= "callBaseCodeViewPopup";
					var openerID	= "BaseCodeView<%=request.getParameter("viewCd") %>";
					var popupTit	= me.params.pageTitle;
					var popupYN		= "N";
					var callBack	= "callBaseCodeViewPopup_CallBack";
					var popupUrl	= "/account/baseCode/callBaseCodeViewPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "baseCodeId="		+ baseCodeId+ "&"
									+ "groupCode="		+ groupCode;
					
					var xSize	= "";
					if(openerID == 'BaseCodeViewTC'){
						xSize = "350px"
					}else{
						xSize = "300px"
					}
					
					Common.open("", popupID, popupTit, popupUrl, "416px", xSize, "iframe", true, null, null, true);
				},
				
				callBaseCodeViewPopup_CallBack : function(){
					var me = this;
					me.searchBaseCode();
				},
				syncBaseCode : function(){
					var me = this;
					Common.Inform("<spring:message code='Cache.ACC_msg_syncIF' />");
				},
				onenter : function(){
					var me = this;
					if(event.keyCode=="13"){
						me.searchBaseCode();
					}
				},
				syncData : function(viewCd){
					var me = this;
					<%
					if(!"".equals(getProperty) || "OP".equals(viewCD)){
					%>
						$.ajax({
							type:"POST",
								url:"/account/baseCode/syncBaseCode.do",
							data:{
								"viewCd" : viewCd,
							},
							success:function (data) {
								if(data.result == "ok"){
									
								}
								else{
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
								}
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
							}
						});
					<%
					}%>
				}
		}
		window.BaseCodeView = BaseCodeView;
		window.BaseCodeView<%=request.getParameter("viewCd") %> = BaseCodeView<%=request.getParameter("viewCd") %>;
	})(window);
</script>