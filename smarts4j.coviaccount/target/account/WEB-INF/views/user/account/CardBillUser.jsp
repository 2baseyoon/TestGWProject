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
					<a class="btnTypeDefault"			onclick="CardBillUser.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"	onclick="CardBillUser.excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
				</div>
				<!-- 상단 버튼 끝 -->
				<div class="buttonStyleBoxRight">	
					<span id="cardBillUserListCount" class="selectType02 listCount" onchange="CardBillUser.searchList();">
					</span>
					<button class="btnRefresh" type="button" onclick="CardBillUser.searchList();"></button>
				</div>
			</div>
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type07">
					<div style="width:1000px;">
						<div class="inPerTitbox">
							<!-- 회사 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_company"/></span>
							<span id="cardBillUserCompanyCode" class="selectType02">
							</span>
						</div>	
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 청구년월 -->
								<spring:message code="Cache.ACC_lbl_expenseDate"/>
							</span>
							<select id="approveDateYY" style="width:80px;">
							</select>
							<select id="approveDateMM" style="width:80px;">
							</select>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 카드번호 -->
								<spring:message code="Cache.ACC_lbl_cardNumber"/>
							</span>
							<input	id="cardBillUserCardNo" type="text" MaxLength="16"
									onkeypress	= "return inputNumChk(event)"
									onkeydown	= "CardBillUser.onkey(this)"
									onkeyup	= "CardBillUser.changeCardNo()">
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="CardBillUser.searchList()"><spring:message code='Cache.ACC_btn_search'/></a>
					</div>
				</div>
			</div>
			<div>			<!-- 월 청구금액 총계 -->
				<spring:message code="Cache.ACC_mmSumAmountWon"/> <span id="mmSumAmountWon"></span>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

	if (!window.CardBillUser) {
		window.CardBillUser = {};
	}
	
	(function(window) {
		var CardBillUser = {
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

				setSelectCombo : function(){
					accountCtrl.renderAXSelect('listCountNum',	'cardBillUserListCount',	'ko','','','');
					accountCtrl.renderAXSelect('CompanyCode',	'cardBillUserCompanyCode',	'ko','','','');
					
					accountCtrl.getInfo("approveDateYY").children().remove();
					accountCtrl.getInfo("approveDateMM").children().remove();
					
					var appendHtmlYY	= "";
					var appendHtmlMM	= "";
					var now = new Date();
					var nowYY	= now.getFullYear();
					var nowMM	= now.getMonth();
					var startYY	= nowYY - 10;
					var endYY	= nowYY + 10;
					
					if(nowMM < 10){
						nowMM = "0"+nowMM;
					}
					
					for(var i=startYY; i<=endYY; i++){
						appendHtmlYY	+=	"<option value=\""+i+"\">"
										+		i
										+	"</option>";
					}
					
					for(var i=0; i<12; i++){
						var info = i+1;
						if(info < 10){
							info = "0"+info;
						}
						
						appendHtmlMM	+=	"<option value=\""+info+"\">"
										+		info
										+	"</option>";
					}
					
					accountCtrl.getInfo("approveDateYY").append(appendHtmlYY);
					accountCtrl.getInfo("approveDateMM").append(appendHtmlMM);
					accountCtrl.getInfo("approveDateYY").val(nowYY);
					accountCtrl.getInfo("approveDateMM").val(nowMM);
				},

				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
				},

				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	
												{ 	key:'CompanyName',		label : "<spring:message code='Cache.ACC_lbl_company' />",			width:'100',	align:'center'},		//회사
												{	key:'CardNo',			label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",			width:'150',	align:'center'},	//카드번호
					    						{	key:'ApproveNo',		label:"<spring:message code='Cache.ACC_lbl_confirmNum' />",			width:'50',		align:'center'},	//승인번호
					    						{	key:'ApproveDate',		label:"<spring:message code='Cache.ACC_lbl_approveDate' />",		width:'50',		align:'center'},	//사용일자
					    						{	key:'StoreName',		label:"<spring:message code='Cache.ACC_lbl_franchiseCorpName' />",	width:'50',		align:'center'},	//가맹점명
					    						{	key:'ForeignCurrency',	label:"<spring:message code='Cache.ACC_lbl_foreignCurrency' />",	width:'50',		align:'center'},	//통화
					    						{	key:'AmountWon',		label:"<spring:message code='Cache.ACC_lbl_amountWon' />",			width:'50',		align:'center'},	//이용금액
					    						{	key:'CountryIndexName',	label:"<spring:message code='Cache.ACC_lbl_countryIndex' />",		width:'50',		align:'center'}		//해외구분
					    					]
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},

				searchList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var regExp		= /^[0-9]+$/;
					var approveDate	= accountCtrl.getInfo("approveDateYY").val() + accountCtrl.getInfo("approveDateMM").val();
					var cardNo		= accountCtrl.getInfo("cardBillUserCardNo").val();
					var companyCode = accountCtrl.getComboInfo("cardBillUserCompanyCode").val();
					
					if(cardNo.length > 0){
						if (!regExp.test(cardNo)){
							Common.Inform("<spring:message code='Cache.ACC_msg_reCardNum' />");		//카드번호를 다시 입력하세요.
							return
						}
					}
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/cardBill/getCardBillUserList.do";
					var ajaxPars		= {	"approveDate"	: approveDate,
			 								"cardNo"		: cardNo,
			 								"companyCode"	: companyCode
					};
					
					var pageSizeInfo	= accountCtrl.getComboInfo("cardBillUserListCount").val();
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
					me.setSumAmountWon(approveDate,cardNo,companyCode);
				},
				
				setSumAmountWon : function(approveDate,cardNo,companyCode){
					var me = this;
					$.ajax({
						url	: "/account/cardBill/getCardBillmmSumAmountWonUser.do",
						type: "POST",
						data: {	"approveDate"	: approveDate,
								"cardNo"		: cardNo,
								"companyCode"	: companyCode
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								accountCtrl.getInfo('mmSumAmountWon').text(data.sum[0].AmountWon);
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				excelDownload : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
							var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerData);
							var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerData);
							var regExp		= /^[0-9]+$/;
							
							var approveDate	= accountCtrl.getInfo("approveDateYY").val() + accountCtrl.getInfo("approveDateMM").val();
							var cardNo		= accountCtrl.getInfo("cardBillUserCardNo").val();
							var companyCode = accountCtrl.getComboInfo("cardBillUserCompanyCode").val();
							var title 			= accountCtrl.getInfo("headerTitle").text();
							
							if(cardNo.length > 0){
								if (!regExp.test(cardNo)){
									Common.Inform("<spring:message code='Cache.ACC_msg_reCardNum' />");	//카드번호를 다시 입력하세요
									return
								}
							}
							var headerType			= accountCommon.getHeaderTypeForExcel(me.params.headerData);
							
							var	locationStr		= "/account/cardBill/cardBillUserExcelDownload.do?"
												//+ "headerName="		+ encodeURI(headerName)
												+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
												+ "&headerKey="		+ encodeURI(headerKey)
												+ "&approveDate="	+ encodeURI(approveDate)
												+ "&cardNo="		+ encodeURI(cardNo)
												+ "&companyCode="	+ encodeURI(companyCode)
												//+ "&title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text())
												+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
												+ "&headerType=" + encodeURI(headerType);
							
							location.href = locationStr;
			       		}
					});
				},
				
				changeCardNo : function(){
					var me = this;
					var cardNo = accountCtrl.getInfo("cardNo").val();
						cardNo = getNumOnly(cardNo);
						accountCtrl.getInfo("cardNo").val(cardNo);
				},
				
				onkey : function(obj){
					var me = this;
					if(event.keyCode=="13"){
						me.searchList();
					}else{
						if(	event.keyCode == 8	||
							event.keyCode == 9	||
							event.keyCode == 37	||
							event.keyCode == 39	||
							event.keyCode == 46){
							return
						}else{
							obj.value = obj.value.replace(/[^0-9]/gi,'');
						}
					}
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.CardBillUser = CardBillUser;
	})(window);	
</script>