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
	<div class="layer_divpop ui-draggable docPopLayer" style="width:700px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent layerType02 boardReadingList">
				<div class="eaccountingCont">
					<div class="middle" style="margin-top:11px;">
						<div id="topitembar02" class="bodysearch_Type01">
							<div class="eaccountingTopCont">
							</div>
							<div class="inPerView type07">
								<div style="width:600px;">
									<div class="inPerTitbox">
										<span class="bodysearch_tit"><spring:message code='Cache.ACC_lbl_company'/></span> 
										<span id="companyCode" class="selectType02">
										</span>
									</div>
									<a class="btnTypeDefault  btnSearchBlue"	onclick="CorpCardListPopup.searchList();">
										<spring:message code="Cache.ACC_btn_search"/>
									</a>
								</div>
							</div>
						</div>
						<div class="tblList tblCont">					
							<div id="gridArea" class="pad10">
							</div>
						</div>
					</div>
					<div class="bottom">
						<div class="popBottom">
							<a href="#" class="btnTypeDefault btnTypeBg" onclick="CorpCardListPopup.corpCardConfirm();"><spring:message code='Cache.ACC_btn_confirm'/></a>	<!-- 확인 -->
							<a href="#" class="btnTypeDefault" onclick="Common.Close();"><spring:message code='Cache.ACC_btn_cancel'/></a>	<!-- 취소 -->
						</div>
					</div>
				</div>
			</div>
		</div>	
	</div>
</body>

<script>

if (!window.CorpCardListPopup) {
	window.CorpCardListPopup = {};
}

(function(window) {
	var CorpCardListPopup = {
			params	:{
				gridPanel	: new coviGrid(),
				headerData	: []
			},
			
			pageInit : function() {
				var me = this;
				$(".docPopLayer").attr("id", accountCtrl.getViewPageDivID());
				accountCtrl.renderAXSelect('CompanyCode', 'companyCode', 'ko','','','');
				me.setHeaderData();
				me.searchList('Y');
			},
			
			setHeaderData : function() {
				var me = this;
				me.params.headerData = [	{	key:'chk',				label:'chk',	width:'20', align:'center', formatter:"checkbox", disabled : function(){
													if(this.item.ReleaseYN == "Y"){
														return true;
													}else{
														return false;
													}
												 }
											},
											{	key:'CardCompanyName',	label:"<spring:message code='Cache.ACC_lbl_cardCompany' />",		width:'50', align:'center'},	//카드회사
											{	key:'CardNo',			label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",		width:'70', align:'center',		//카드번호
												formatter:function () {
													var rtStr =	""
																+	"<font color='blue'>"
																+		this.item.CardNo
																+	"</font>"
													return rtStr;
												}
											},
											{	key:'CardStatusName',	label:"<spring:message code='Cache.ACC_lbl_cardStatus' />",		width:'50', align:'center'},	//카드상태
											{	key:'IssueDate',		label:"<spring:message code='Cache.ACC_lbl_issueDate' />",		width:'70', align:'center'},	//발급일자
											{	key:'PayDate',			label:"<spring:message code='Cache.ACC_lbl_payDate' />",			width:'70', align:'center'},	//결제일자
											{	key:'ExpirationDate',	label:"<spring:message code='Cache.ACC_lbl_expirationDate' />",	width:'70', align:'center'},	//만료일자
											{	key:'LimitAmount',		label:"<spring:message code='Cache.ACC_lbl_limitAmt' />",		width:'70', align:'center'},	//한도금액
											{	key:'OwnerUserNum',		label:"<spring:message code='Cache.ACC_lbl_ownerUserNumber' />",	width:'70', align:'center'},	//소유자사번
											{	key:'OwnerUserName',	label:"<spring:message code='Cache.ACC_lbl_cardOwner' />",		width:'70', align:'center'},	//소유자
											{	key:'OwnerUserDept',	label:"<spring:message code='Cache.ACC_lbl_cardOwnerDept' />",	width:'70', align:'center'}		//소유자 부서
										]
				
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},
			
			searchList : function(YN){
				var me = this;
				
				me.setHeaderData();
				
				var companyCode		= accountCtrl.getComboInfo("companyCode").val();
				
				var gridAreaID		= "gridArea";
				var gridPanel		= me.params.gridPanel;
				var gridHeader		= me.params.headerData;
				var ajaxUrl			= "/account/corpCard/getCorpCardList.do";
				var ajaxPars		= {	"companyCode"	: companyCode,
						 				"ownerUserCode"	: "",
						 				"cardStatus"	: "",
						 				"cardNo"		: "",
						 				"cardClass"		: "CCL3"
					};
				
				var pageNoInfo		= accountCtrl.getGridViewPageNum(YN,gridPanel,10);
				
				var gridParams = {	"gridAreaID"	: gridAreaID
								,	"gridPanel"		: gridPanel
								,	"gridHeader"	: gridHeader
								,	"ajaxUrl"		: ajaxUrl
								,	"ajaxPars"		: ajaxPars
								,	"pageNoInfo"	: pageNoInfo
								,	"pageSizeInfo"	: 10
								,	"popupYN"		: "N"
				}

				accountCtrl.setViewPageBindGrid(gridParams);
			},
			
			corpCardConfirm : function(){
				var me = this;
				var chkList = me.params.gridPanel.getCheckedList(0);
				
				switch(chkList.length){
					case 0:
						Common.Warning("<spring:message code='Cache.ACC_msg_noselectdata' />"); // 선택된 항목이 없습니다.
						break;
					case 1:
						$(parent.document).find("#corpReturnYnPopup_if").contents().find("#cardNo").val(getCardNoValue(chkList[0].CardNo, '*'));
						$(parent.document).find("#corpReturnYnPopup_if").contents().find("#corpCardID").val(chkList[0].CorpCardID);
						Common.Close();
						break;
					default:
						Common.Warning("<spring:message code='Cache.msg_SelectOne' />"); // 한개만 선택되어야 합니다
						break;
				}
				
			},
			
			refresh : function(){
				accountCtrl.pageRefresh();
			}
			
	}
	window.CorpCardListPopup = CorpCardListPopup;
})(window);

CorpCardListPopup.pageInit();
</script>