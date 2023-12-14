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
					<!-- 새로고침 -->
					<a class="btnTypeDefault"			onclick="CardReceiptUserPersonalUse.refresh()"><spring:message code='Cache.ACC_btn_refresh'/></a>
					<!-- 개인사용처리취소 -->
					<a class="btnTypeDefault"			onclick="CardReceiptUserPersonalUse.cardReceiptPersonal()"><spring:message code='Cache.ACC_lbl_personalUseCancel'/></a>
				</div>
				<!-- 상단 버튼 끝 -->				
			</div>
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 회사 -->
								<spring:message code='Cache.ACC_lbl_company'/>
							</span>
							<span id="companyCode" class="selectType02" onchange="CardReceiptUserPersonalUse.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 정산상태 -->
								<spring:message code='Cache.ACC_lbl_taxInvoice'/>
							</span>
							<span id="active" class="selectType02" style="width:239px;">
							</span>
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 소유자 -->
								<spring:message code='Cache.ACC_lbl_cardOwner'/>
							</span>
							<input id="cardUserName" type="text" disabled="true">
							<input id="cardUserCode" type="hidden">
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 사용일자 -->
								<spring:message code='Cache.ACC_lbl_approveDate'/>
							</span>
							<div id="approveDate" class="dateSel type02">
							</div>
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 가맹점명 -->
								<spring:message code='Cache.ACC_lbl_franchiseCorpName'/>
							</span>
							<input id="storeName" type="text" placeholder="">
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 카드번호 -->
								<spring:message code='Cache.ACC_lbl_cardNumber'/>
							</span>
							<input	id="cardNo" type="text" placeholder="" MaxLength="16"
									style="width:239px;"
									onkeypress	= "return inputNumChk(event)"
									onkeydown	= "pressHan(this)"
									onkeyup	= "CardReceiptUserPersonalUse.changeCardNo()">
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="CardReceiptUserPersonalUse.searchList()"><spring:message code='Cache.ACC_btn_search'/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="CardReceiptUserPersonalUse.searchList();">
					</span>
					<button class="btnRefresh" type="button" onclick="CardReceiptUserPersonalUse.searchList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

	if (!window.CardReceiptUserPersonalUse) {
		window.CardReceiptUserPersonalUse = {};
	}
	
	(function(window) {
		var CardReceiptUserPersonalUse = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},

				pageInit : function() {
					var me = this;
					setHeaderTitle('headerTitle');
					accountCtrl.getInfo("cardUserName").val(Common.getSession().USERNAME);
					accountCtrl.getInfo("cardUserCode").val(Common.getSession().USERID);
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
					makeDatepicker('approveDate','approveDateS','approveDateE','','','');
				},
				
				setSelectCombo : function(pCompanyCode){
					accountCtrl.getInfo("listCount").children().remove();
					accountCtrl.getInfo("active").children().remove();

					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "CardReceiptUserPersonalUse.searchList()");
					accountCtrl.getInfo("active").addClass("selectType02").css("width", "239px");
					
					var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'Active',			'target':'active',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}	//전체
						,	{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
				},

				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("companyCode");
					accountCtrl.refreshAXSelect("active");
				},

				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'chk',					label:'chk', width:'20', align:'center', formatter:'checkbox'},
												{ 	key:'CompanyCode',			label : "<spring:message code='Cache.ACC_lbl_company' />",			width:'100',	align:'center',		//회사
													formatter: function() {
														return this.item.CompanyName;
													}
												},	   
												{	key:'CardNo',				label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",			width:'120',	align:'center'},	//카드번호
												{	key:'CardUserName',			label:"<spring:message code='Cache.ACC_lbl_cardOwner' />",			width:'50',		align:'center'},	//소유자
												{	key:'CardUserDept',			label:"<spring:message code='Cache.ACC_lbl_cardOwnerDept' />",		width:'50',		align:'center'},	//소유자 부서
												{	key:'ApproveNo',			label:"<spring:message code='Cache.ACC_lbl_confirmNum' />",			width:'50',		align:'center',		//승인번호
													formatter:function () {
														var rtStr =	""
																	+	"<a onclick='CardReceiptUserPersonalUse.cardReceiptPopup(\""+ this.item.ReceiptID +"\"); return false;'>"
																	+		"<font color='blue'>"
																	+			this.item.ApproveNo
																	+		"</font>"
																	+	"</a>";
														return rtStr;
													}
												},
												{	key:'StoreName',			label:"<spring:message code='Cache.ACC_lbl_franchiseCorpName' />",	width:'100',	align:'center'},	//가맹점명
												{	key:'AmountWon',			label:"<spring:message code='Cache.ACC_lbl_UsedAmt' />",			width:'50',		align:'right'},		//사용금액
												{	key:'ForeignCurrency',		label:"<spring:message code='Cache.ACC_lbl_foreignCurrency' />",	width:'50',		align:'center'},	//통화
												{	key:'ApproveDate',			label:"<spring:message code='Cache.ACC_lbl_approveDate' />",		width:'50',		align:'center'},	//사용일자
												{	key:'ApproveTime',			label:"<spring:message code='Cache.ACC_lbl_approveTime' />",		width:'50',		align:'center'},	//사용시각
												{	key:'IsPersonalUseName',	label:"<spring:message code='Cache.ACC_lbl_status' />",				width:'50',		align:'center'}		//상태
											]
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},

				searchList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var companyCode		= accountCtrl.getComboInfo("companyCode").val();
					var storeName		= accountCtrl.getInfo("storeName").val();
					var cardUserCode	= accountCtrl.getInfo("cardUserCode").val();
					var approveDateS	= accountCtrl.getInfo("approveDateS").val();
					var approveDateE	= accountCtrl.getInfo("approveDateE").val();
					var active			= accountCtrl.getComboInfo("active").val();
					var cardNo			= accountCtrl.getInfo("cardNo").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/cardReceipt/getCardReceiptUserPersonalUseList.do";
					var ajaxPars		= {	"companyCode"	: companyCode,
							 				"storeName"		: storeName,
							 				"cardUserCode"	: cardUserCode,
							 				"approveDateS"	: approveDateS,
							 				"approveDateE"	: approveDateE,
							 				"active"		: active,
							 				"cardNo"		: cardNo
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
				
				cardReceiptPopup : function(key){
					var popupName	=	"CardReceiptPopup";
					var popupID		=	"cardReceiptPopup";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_cardReceiptInvoice' />";	//신용카드매출전표
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"receiptID="	+	key;
					Common.open(	"",popupID,popupTit,url,"320px", "510px","iframe",true,null,null,true);
				},
				
				cardReceiptPersonal  : function(){
					var me = this;
					var chkList = me.params.gridPanel.getCheckedList(0);
					if(chkList.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noSelectCard' />");	//선택한 카드내역정보가 없습니다.
						return;
					}
					
					Common.Confirm("<spring:message code='Cache.ACC_msg_personalUseCancelYN' />", "<spring:message code='Cache.ACC_lbl_personalUse' />", function(result){	//개인사용처리를 취소하시겠습니까?? | 개인사용
			       		if(result){
							var params				= new Object();
							params.isPersonalUse	= 'N';
							params.chkList			= chkList;
							
							$.ajax({
								url			: "/account/cardReceipt/saveCardReceiptPersonal.do",
								type		: "POST",
								data		: JSON.stringify(params),
								dataType	: "json",
								contentType	: "application/json",
								
								success:function (data) {
									if(data.status == "SUCCESS"){
										CardReceiptUserPersonalUse.searchList();
									}else{
										Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
									}
								},
								error:function (error){
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
								}
							});
			       		}
					});
				},
				
				changeCardNo : function(){
					var me = this;
					var cardNo = accountCtrl.getInfo("cardNo").val();
						cardNo = getNumOnly(cardNo);
						accountCtrl.getInfo("cardNo").val(cardNo);
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.CardReceiptUserPersonalUse = CardReceiptUserPersonalUse;
	})(window);

</script>