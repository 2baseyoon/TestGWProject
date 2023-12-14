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
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 추가 -->
					<!-- 새로고침 -->
					<a class="btnTypeDefault"			onclick="CardReceiptCancel.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 개인사용처리 -->
					<a class="btnTypeDefault"			onclick="CardReceiptCancel.cardReceiptPersonal()"	id="btnPersonal"><spring:message code="Cache.ACC_lbl_cardReceiptPersonal"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"	onclick="CardReceiptCancel.excelDownload()"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 배부할 사용자 선택 -->
					<a class="btnTypeDefault"			onclick="CardReceiptCancel.tossUserPopup()"		id="btnToss"><spring:message code="Cache.ACC_lbl_tossUser"/></a>
				</div>
				<!-- 상단 버튼 끝 -->				
			</div>
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 회사 -->
								<spring:message code="Cache.ACC_lbl_company"/>
							</span>
							<span id="companyCode" class="selectType02" style="width:240px;" onchange="CardReceiptCancel.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 소유자 -->
								<spring:message code="Cache.ACC_lbl_cardOwner"/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" id="cardUserName"></span>
								<a class="btn_del03" onclick="CardReceiptCancel.userCodeDel()"></a>
							</div>
							<a class="btn_search03" onclick="CardReceiptCancel.userCodeSearch()"></a>
							<input id="cardUserCode" type="text" hidden>
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 취소일자 -->
								<spring:message code="Cache.ACC_lbl_cancelDate"/>
							</span>
							<div id="approveDate" class="dateSel type02">
							</div>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 가맹점명 -->
								<spring:message code="Cache.ACC_lbl_franchiseCorpName"/>
							</span>
							<input onkeydown="CardReceiptCancel.onenter()" id="storeName" type="text" placeholder="">
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 카드번호 -->
								<spring:message code="Cache.ACC_lbl_cardNumber"/>
							</span>
							<input	id="cardNo" type="text" placeholder="" MaxLength="16"
									style="width:239px;"
									onkeypress = "return inputNumChk(event)"
									onkeydown = "CardReceiptCancel.onkey(this)"
									onkeyup	= "CardReceiptCancel.changeCardNo()">
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="CardReceiptCancel.searchList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="CardReceiptCancel.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="CardReceiptCancel.searchList()"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

	if (!window.CardReceiptCancel) {
		window.CardReceiptCancel = {};
	}
	
	(function(window) {
		var CardReceiptCancel = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},

				pageInit : function() {
					var me = this;
					setPropertySearchType('CardReceipt','searchProperty');
					setHeaderTitle('headerTitle');
					me.setPageViewController();
					me.pageDatepicker();
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

				setPageViewController :function(){
					var searchProperty	= accountCtrl.getInfo("searchProperty").val();
					
					if(	searchProperty == "SAP"){
						accountCtrl.getInfo("btnPersonal").css("display",	"none");
						accountCtrl.getInfo("btnToss").css("display",		"none");
						
					}else if(searchProperty == "SOAP"){
						accountCtrl.getInfo("btnPersonal").css("display",	"none");
						accountCtrl.getInfo("btnToss").css("display",		"none");
						
					}else{
						accountCtrl.getInfo("btnPersonal").css("display",	"");
						accountCtrl.getInfo("btnToss").css("display",		"");
						
					}
				},
				
				pageDatepicker : function(pCompanyCode){
					makeDatepicker('approveDate','approveDateS','approveDateE','','','');
				},
				
				setSelectCombo : function(pCompanyCode){
					accountCtrl.getInfo("listCount").children().remove();
					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "CardReceiptCancel.searchList()");
					
					var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
					]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				},

				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("companyCode");
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
				},

				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'chk',					label:'chk',		width:'20',		align:'center',
													formatter:'checkbox',
													disabled : function(){
							   							  var returnStr	= true;
							   							  var active	= this.item.Active;
							   							  if(active == 'N'){
							   								  returnStr = false;
							   							  }
							   							  return returnStr;
							   						}
												},
												{ 	key:'CompanyName',		label:"<spring:message code='Cache.ACC_lbl_company' />",			width:'100',	align:'center'},	//회사
												{	key:'CardNo',			label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",			width:'120',	align:'center'},	//카드번호
												{	key:'CardUserName',		label:"<spring:message code='Cache.ACC_lbl_cardOwner' />",			width:'50',		align:'center'},	//소유자
												{	key:'CardUserDept',		label:"<spring:message code='Cache.ACC_lbl_cardOwnerDept' />",		width:'50',		align:'center'},	//소유자 부서
												{	key:'ApproveNo',		label:"<spring:message code='Cache.ACC_lbl_confirmNum' />",			width:'50',		align:'center',		//승인번호
													formatter:function () {
														var rtStr =	""
																	+	"<a onclick='CardReceiptCancel.cardReceiptPopup(\""+ this.item.ReceiptID +"\"); return false;'>"
																	+		"<font color='blue'>"
																	+			this.item.ApproveNo
																	+		"</font>"
																	+	"</a>";
														return rtStr;
													}
												},
												{	key:'StoreName',		label:"<spring:message code='Cache.ACC_lbl_franchiseCorpName' />",	width:'100',		align:'center'},	//가맹점명
												{	key:'ForeignCurrency',	label:"<spring:message code='Cache.ACC_lbl_foreignCurrency' />",		width:'50',		align:'center'},	//통화
												{	key:'AmountWon',		label:"<spring:message code='Cache.ACC_lbl_amountWon' />",			width:'50',		align:'right'},		//이용금액
												{	key:'ApproveDate',		label:"<spring:message code='Cache.ACC_lbl_approveDate' />",			width:'50',		align:'center'},	//사용일자
												{	key:'ApproveTime',		label:"<spring:message code='Cache.ACC_lbl_approveTime' />",			width:'50',		align:'center'},	//사용시각
												{	key:'ActiveName',		label:"<spring:message code='Cache.ACC_lbl_processStatus' />",		width:'50',		align:'center'},	//처리상태
												{	key:'TossUserCode',		label:"<spring:message code='Cache.ACC_lbl_tossUserName' />",		width:'50',		align:'center'},	//전달대상
												{	key:'TossComment',		label:"<spring:message code='Cache.ACC_lbl_tossComment' />",			width:'50',		align:'center'}		//전달의견
				]
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},

				searchList : function(YN){
					var me = this;
					me.setHeaderData();
					
					var companyCode		= accountCtrl.getComboInfo("companyCode").val();
					var cardUserCode	= accountCtrl.getInfo("cardUserCode").val();
					var approveDateS	= accountCtrl.getInfo("approveDateS").val();
					var approveDateE	= accountCtrl.getInfo("approveDateE").val();
					var storeName		= accountCtrl.getInfo("storeName").val();
					var cardNo			= accountCtrl.getInfo("cardNo").val();
					
					/* if(cardNo.length > 0) {
						if(cardNo.length != 16){
							Common.Inform("<spring:message code='Cache.ACC_msg_ckCardNum' />");	///16자리의 카드번호를 입력해주세요.
							return;	
						}
					} */
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/cardReceipt/getCardReceiptCancelList.do";
					var ajaxPars		= {	"companyCode"	: companyCode,
							 				"cardUserCode"	: cardUserCode,
							 				"approveDateS"	: approveDateS,
							 				"approveDateE"	: approveDateE,
							 				"storeName"		: storeName,
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
				
				userCodeSearch : function(){
					var popupID		= "orgmap_pop";
					var openerID	= "CardReceiptCancel";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_orgChart' />";	//조직도
					var callBackFn	= "goOrgChart_CallBack";
					var type		= "B1";
					var popupUrl	= "/covicore/control/goOrgChart.do?"
									+ "popupID="		+ popupID		+ "&"
									+ "callBackFunc="	+ callBackFn	+ "&"
									+ "type="			+ type;
					
					window[callBackFn] = window[openerID][callBackFn];
					Common.open("", popupID, popupTit, popupUrl, "1000px","580px","iframe",true,null,null,true);
				},
				
				goOrgChart_CallBack : function(orgData){
					var items		= JSON.parse(orgData).item;
					var arr			= items[0];
					var userName	= arr.DN.split(';');
					var UserCode	= arr.UserCode.split(';');
					
					accountCtrl.getInfo("cardUserCode").val(UserCode[0]);
					accountCtrl.getInfo("cardUserName").text(userName[0]);
				},
				
				userCodeDel : function(){
					accountCtrl.getInfo("cardUserCode").val('');
					accountCtrl.getInfo("cardUserName").text('');
				},
				
				excelDownload : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
							var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerData);
							var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerData);
							var companyCode		= accountCtrl.getComboInfo("companyCode").val();
							var cardUserCode	= accountCtrl.getInfo("cardUserCode").val();
							var approveDateS	= accountCtrl.getInfo("approveDateS").val();
							var approveDateE	= accountCtrl.getInfo("approveDateE").val();
							var storeName		= accountCtrl.getInfo("storeName").val();
							var cardNo			= accountCtrl.getInfo("cardNo").val();
							var title 			= accountCtrl.getInfo("headerTitle").text();
	
							/* if(cardNo.length > 0) {
								if(cardNo.length != 16){
									Common.Inform("<spring:message code='Cache.ACC_msg_ckCardNum' />");	//16자리의 카드번호를 입력해주세요.
									return;	
								}
							} */
							
							var headerType			= accountCommon.getHeaderTypeForExcel(me.params.headerData);
							var	locationStr		= "/account/cardReceipt/cardReceiptCancelExcelDownload.do?"
												//+ "headerName="		+ encodeURI(headerName)
												+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
												+ "&headerKey="		+ encodeURI(headerKey)
												+ "&companyCode="	+ encodeURI(companyCode)
												+ "&cardUserCode="	+ encodeURI(cardUserCode)
												+ "&approveDateS="	+ encodeURI(approveDateS)
												+ "&approveDateE="	+ encodeURI(approveDateE)
												+ "&storeName="		+ encodeURI(storeName)
												+ "&cardNo="		+ encodeURI(cardNo)
												//+ "&title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text())
												+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
												+ "&headerType=" + encodeURI(headerType);
							
							location.href = locationStr;
			       		}
					});
				},
				
				cardReceiptPopup : function(key){
					var popupName	=	"CardReceiptPopup";
					var popupID		=	"cardReceiptPopup";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_cardReceiptInvoice' />";		//신용카드매출정보
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"receiptID="	+	key;
					Common.open("",popupID,popupTit,url,"320px", "510px","iframe",true,null,null,true);
				},
				
				cardReceiptPersonal : function(){
					var me = this;
					var chkList = me.params.gridPanel.getCheckedList(0);
					if(chkList.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");	// 선택된 항목이 없습니다.
						return;
					}
												//개인사용처리			       	///개인 사용
					Common.Confirm("<spring:message code='Cache.ACC_msg_personalUseYN' />", "<spring:message code='Cache.ACC_lbl_personalUse' />", function(result){	
			       		if(result){
							var params				= new Object();
							params.isPersonalUse	= 'Y';
							params.chkList			= chkList;
							
							$.ajax({
								url			: "/account/cardReceipt/saveCardReceiptPersonal.do",
								type		: "POST",
								data		: JSON.stringify(params),
								dataType	: "json",
								contentType	: "application/json",
								
								success:function (data) {
									if(data.status == "SUCCESS"){
										CardReceiptCancel.searchList();
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
				
				tossUserPopup : function() {
					var me = this;
					var chkList = me.params.gridPanel.getCheckedList(0);
					if(chkList.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noSelectCard' />");	//선택된 카드내역정보가 없습니다.
						return;
					}
					
					var popupName	= "TossUserPopup";
					var popupID		= "tossUserPopup";
					var openerID	= "CardReceiptCancel";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_tossUser' />";		//수신전달내역
					var popupYN		= "N";
					var callBack	= "tossUserPopup_CallBack";
					var url			= "/account/accountCommon/accountCommonPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "popupName="		+ popupName	+ "&"
									+ "callBackFunc="	+ callBack;
					Common.open("",popupID,popupTit,url,"520px", "230px","iframe",true,null,null,true);
				},
				
				tossUserPopup_CallBack : function(info){
					var me = this;
					var params	= new Object();
					var chkList	= me.params.gridPanel.getCheckedList(0);
					
					if(chkList.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_ckTossTarget' />");		//전달할 내역을 먼저 선택해주세요.
						return;
					}
					
					params.chkList		= chkList;
					params.tossUserCode	= info.tossSenderUserCode;	//전달받은사용자코드
					params.tossComment	= info.tossComment;			//전달시코멘트
					
					$.ajax({
						url			: "/account/cardReceipt/saveCardReceiptTossUser.do",
						type		: "POST",
						data		: JSON.stringify(params),
						dataType	: "json",
						contentType	: "application/json",
						
						success:function (data) {
							Common.close('tossUserPopup');
							
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_selectTaxInvoice' />");	//수신내역전달 사용자를 선택하였습니다.
								CardReceiptCancel.searchList();
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				changeCardNo : function(){
					var cardNo = getNumOnly(accountCtrl.getInfo("cardNo").val());
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
		window.CardReceiptCancel = CardReceiptCancel;
	})(window);	
</script>