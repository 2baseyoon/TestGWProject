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
					<a class="btnTypeDefault"			onclick="SendDelayCorpCard.refresh()"><spring:message code='Cache.ACC_btn_refresh'/></a>
					<!-- 미상신 알림전송 -->
					<a class="btnTypeDefault" 			onclick="SendDelayCorpCard.sendDelay();"><spring:message code="Cache.lbl_AccDelaySend"/></a>
				</div>
				<!-- 상단 버튼 끝 -->	
				<div style="display: inline-block; padding-top: 20px;"">
					<input type="radio" id="Owner" name="sendMailType" value="Owner"/>
					<label for="invoice"><spring:message code='Cache.ACC_lbl_cardOwner' /></label>
					<input type="radio" id="Search" name="sendMailType" value="Search"/>
					<label for="manager"><spring:message code='Cache.lbl_Searcher' /></label>
					<input type="radio" id="Return" name="sendMailType" value="Return"/>
					<label for="tossuser"><spring:message code='Cache.ACC_lbl_ReleaseUser' /></label>
	            </div>			
			</div>
			
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 회사 -->
								<spring:message code='Cache.ACC_lbl_company'/>
							</span>
							<span id="companyCode" class="selectType02" onchange="CardReceiptUser.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox" style="display:none;">
							<span class="bodysearch_tit">	<!-- 정산상태 -->
								<spring:message code='Cache.ACC_lbl_taxInvoice'/>
							</span>
							<span id="active" class="selectType02" style="width:239px;">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 카드유형 -->
								<spring:message code="Cache.ACC_lbl_cardClass"/>
							</span>
							<span id="cardClass" class="selectType02" style="width:239px;">
							</span>
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 카드번호 -->
								<spring:message code='Cache.ACC_lbl_cardNumber'/>
							</span>
							<input	id="cardNo" type="text" placeholder="" MaxLength="16"
									style="width:239px;"
									onkeypress	= "return inputNumChk(event)"
									onkeydown	= "pressHan(this)"
									onkeyup	= "SendDelayCorpCard.changeCardNo()">
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 사용일자 -->
								<spring:message code='Cache.ACC_lbl_approveDate'/>
							</span>
							<div id="approveDate" class="dateSel type02">
							</div>
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="SendDelayCorpCard.searchList()"><spring:message code='Cache.ACC_btn_search'/></a>
					</div>
					<div style="width:900px; display: none;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 소유자 -->
								<spring:message code='Cache.ACC_lbl_cardOwner'/>
							</span>
							<input id="cardUserName" type="text" disabled="true">
							<input id="cardUserCode" type="hidden">
						</div>
						
					</div>
					<div style="width:900px; display: none;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 가맹점명 -->
								<spring:message code='Cache.ACC_lbl_franchiseCorpName'/>
							</span>
							<input id="storeName" type="text" placeholder="">
						</div>
						
						
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="SendDelayCorpCard.searchList();">
					</span>
					<button class="btnRefresh" type="button" onclick="SendDelayCorpCard.searchList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

	if (!window.SendDelayCorpCard) {
		window.SendDelayCorpCard = {};
	}
	
	(function(window) {
		var SendDelayCorpCard = {
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
					var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'Active',			'target':'active',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'CardClass',		'target':'cardClass',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						];
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},

				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("companyCode");
					accountCtrl.refreshAXSelect("active");
				},

				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'chk',					label:'chk', width:'20', align:'center', formatter:'checkbox'},
												{	key:'CNT',				label:"미사용건수",			width:'20',	align:'center'},	// 미사용건수
												{	key:'CardClass',			label:"카드유형",			width:'50',		align:'center'},	// 카드유형
												{	key:'CardNo',			label:"카드번호",		width:'50',		align:'center'},	// 카드번호
												{	key:'OwnerUser',			label:"소유자",			width:'50',		align:'center', style:'hidde', display: false},		// 소유자
												{	key:'UserName',			label:"소유자명",			width:'50',		align:'center'},		// 소유자
												
												{	key:'SearchUser',			label:"조회자",		width:'50',		align:'center', display: false},	// 조회자
												{	key:'SearchName',			label:"조회자명",		width:'50',		align:'center'},	// 조회자
												
											]
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},

				searchList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var companyCode		= accountCtrl.getComboInfo("companyCode").val();
					var cardClass		= accountCtrl.getComboInfo("cardClass").val();
					// var active			= accountCtrl.getComboInfo("active").val();
					// var infoIndex		= accountCtrl.getComboInfo("infoIndex").val();
					// var isPersonalUse	= accountCtrl.getComboInfo("isPersonalUse").val();
					var searchProperty	= accountCtrl.getInfo("searchProperty").val();
					var cardNo			= accountCtrl.getInfo("cardNo").val();
					var approveDateS	= accountCtrl.getInfo("approveDateS").val();
					var approveDateE	= accountCtrl.getInfo("approveDateE").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/cardReceipt/getSendDelayCorpCardList.do";
					var ajaxPars		= {	"companyCode"	: companyCode,
							 				"cardClass"		: cardClass,
							 				"approveDateS"	: approveDateS,
							 				"approveDateE"	: approveDateE,
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
				},
				sendDelay: function() {//미상신 알림메일
					var me = this;
					var sendMailType = $("[name=sendMailType]:checked").val();
					var chkList = me.params.gridPanel.getCheckedList(0);
					var params	= new Object();
					
					
					if(chkList.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_chkData' />"); //내역을 먼저 선택해주세요.
					}else{  
						if(sendMailType != "" && sendMailType != undefined ){	
							params.chkList	= chkList;
							
							params.companyCode = accountCtrl.getComboInfo("companyCode").val();
							params.approveDateS = accountCtrl.getInfo("approveDateS").val();
							params.approveDateE =  accountCtrl.getInfo("approveDateE").val();
							
							Common.Confirm("<spring:message code='Cache.msg_apv_ConfirmSend' /> ", "Confirmation Dialog", function (confirmResult) {
								if (confirmResult) {
									$.ajax({
										url			: "/account/doManualDelayAlamCorpCard.do",
										type		: "POST",
										data		:{"sendMailType": sendMailType
														, companyCode: accountCtrl.getComboInfo("companyCode").val()
														, "dataList" : JSON.stringify(params)
														
										},
										success:function (data) {
											if(data.status == "SUCCESS"){
												Common.Inform("<spring:message code='Cache.msg_sms_send_success' />"+"["+data.data.sendCnt+"]");	//전송을 완료했습니다
											}else{
												Common.Error("<spring:message code='Cache.CPMail_sendFalse_msg' />"); // 전송에 실패 하였습니다.
											}
										},
										error:function (error){
											Common.Error("<spring:message code='Cache.CPMail_sendFalse_msg' />"); // 전송에 실패 하였습니다.
										}
									});
								}
						    });	
						}else{
							Common.Warning("메일전송 대상을 선택해주세요.");
							return;
						}
				    }
				}
				
		}
		window.SendDelayCorpCard = SendDelayCorpCard;
	})(window);

</script>