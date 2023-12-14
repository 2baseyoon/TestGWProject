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
					<a class="btnTypeDefault"	onclick="Audit.refresh()"><spring:message code='Cache.ACC_btn_refresh'/></a>
				</div>
			</div>
			<div class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 회사코드 -->
								<spring:message code="Cache.ACC_lbl_companyCode"/>
							</span>
							<span id="companyCode" class="selectType02" onchange="Audit.searchList();">
							</span>
						</div>
					</div>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
	</div>
<script>
	if (!window.Audit) {
		window.Audit = {};
	}
	
	(function(window) {
		var Audit = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
			
				pageInit : function() {
					var me = this;
					setHeaderTitle('headerTitle');
					
					accountCtrl.renderAXSelect('CompanyCode','companyCode','ko','','','');
					
					me.setHeaderData();
					me.searchList('Y');
				},
				
				pageView : function() {
					var me = this;
					
					me.setHeaderData();
					me.searchList();
				},
				
				setHeaderData : function() {
					
					var me = this;
					me.params.headerData = [	{	key:'AuditNum',			label:"<spring:message code='Cache.ACC_lbl_no' />",				width:'20',		align:'center'},	//순번
												{	key:'CompanyCode',		label:"<spring:message code='Cache.ACC_lbl_company' />",		width:'50',		align:'center',		//회사
													formatter: function() {
														return this.item.CompanyName;
													}
												},
												{	key:'StdType',			label:"<spring:message code='Cache.ACC_lbl_standardType' />",	width:'50',		align:'center'},	//기준유형
												{	key:'RuleCode',			label:"<spring:message code='Cache.ACC_lbl_ruleCode' />",		width:'50',		align:'center'},	//규칙코드
					        					{	key:'RuleName',			label:"<spring:message code='Cache.ACC_lbl_ruleName' />",		width:'50',		align:'center',		//규칙명
													formatter:function () {
														var rtStr =	""
																	+	"<a onclick='Audit.auditUpdatePopup(\""+ this.item.AuditID +"\",\""+this.item.RuleCode+"\"); return false;'>"
																	+		"<font color='blue'>"
																	+			this.item.RuleName
																	+		"</font>"
																	+	"</a>";
														return rtStr;
													}
					        					},
					        					{	key:'RuleDescription',	label:"<spring:message code='Cache.ACC_lbl_ruleDesc' />",			width:'70',		align:'left'},		//규칙설명
					        					{	key:'StdDescription',	label:"<spring:message code='Cache.ACC_lbl_standardDesc' />",		width:'70',		align:'left'},		//기준설명
					        					{	key:'ApplicationColor',	label:"<spring:message code='Cache.ACC_lbl_applicationColor' />",	width:'30',		align:'center'},	//적용사항
												{	key:'IsUse',			label:"<spring:message code='Cache.ACC_lbl_isUse' />",				width:'20',		align:'center',		//사용여부
													formatter:function () {
														var col			= 'IsUse'
														var key			= this.item.AuditID;
														var value		= this.item.IsUse;
														var on_value	= 'Y';
														var off_value	= 'N';
														var onchangeFn	= 'Audit.auditUpdateIsUse(\"'+ this.item.AuditID +'\",\"'+this.item.IsUse+'\")';
														return accountCtrl.getGridSwitch(col,key,value,on_value,off_value,onchangeFn);
													}
												}
											]
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var companyCode	= accountCtrl.getComboInfo("companyCode").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/audit/getAuditList.do";
					var ajaxPars		= {"companyCode" : companyCode};
					
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
									,	"pagingTF"		: false
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
				},
				
				auditUpdatePopup : function(key,ruleCode){
					var companyCode	= accountCtrl.getComboInfo("companyCode").val();
					
					var popupID		= "AuditPopup";
					var openerID	= "Audit";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_auditPopup' />";
					var popupYN		= "N";
					var callBack	= "auditPopup_CallBack";
					var popupUrl	= "/account/audit/getAuditPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "ruleCode="		+ ruleCode	+ "&"
									+ "companyCode="	+ companyCode	+ "&"
									+ "auditID="		+ key;
					
					Common.open("", popupID, popupTit, popupUrl, "630px", "580px", "iframe", true, null, null, true);
				},
				
				auditPopup_CallBack : function(){
					var me = this;
					me.searchList();
				},
				
				auditUpdateIsUse : function(key,sts){
					if(	key	== null || key	== '' ||
						sts	== null	|| sts	== ''){
						return
					}
					
					var auditID	= key;
					var isUse	= "";
					
					if(sts == 'Y'){
						isUse = 'N'
					}else{
						isUse = 'Y'
					}
					
					$.ajax({
						url	: "/account/audit/saveAuditInfo.do",
						type: "POST",
						data: {
								"auditID"	: auditID
							,	"isUse"		: isUse
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다.
								Audit.searchList('N');
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.	
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.Audit = Audit;
	})(window);
</script>