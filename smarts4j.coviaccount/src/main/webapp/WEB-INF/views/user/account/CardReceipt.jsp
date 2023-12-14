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
	<input id="syncProperty"	type="hidden" />
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 추가 -->
					<!-- 새로고침 -->
					<a class="btnTypeDefault"			onclick="CardReceipt.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"	onclick="CardReceipt.excelDownload()"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"			onclick="CardReceipt.tossUserPopup()"		id="btnToss"><spring:message code="Cache.ACC_lbl_tossUser"/></a>
					<!-- 동기화 -->
					<a class="btnTypeDefault"			onclick="CardReceipt.cardReceiptSync();"	id="btnSync"><spring:message code="Cache.ACC_btn_sync"/></a>
					<!-- 템플릿 다운로드 -->
					<a class="btnTypeDefault btnExcel" onclick="CardReceipt.templateDownload();"><spring:message code="Cache.ACC_lbl_templateDownload"/></a>
					<!-- 엑셀 업로드 -->
					<a class="btnTypeDefault btnExcel" onclick="CardReceipt.excelUpload();"><spring:message code="Cache.ACC_lbl_excelUpload"/></a>
					<!-- 전체 미상신 알림전송 -->
					<a class="btnTypeDefault" onclick="CardReceipt.sendDelay(true);"><spring:message code="Cache.lbl_AccDelaySendAll"/></a>
					<!-- 선택 미상신 알림전송 -->
					<a class="btnTypeDefault" onclick="CardReceipt.sendDelay(false);"><spring:message code="Cache.lbl_AccDelaySendSelect"/></a>
				</div>
				<!-- 상단 버튼 끝 -->				
			</div>
			<div id="searchbar1" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 회사 -->
								<spring:message code="Cache.ACC_lbl_company"/>
							</span>
							<span id="companyCode" class="selectType02" onchange="CardReceipt.changeCompanyCode()">
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
							<span class="bodysearch_tit">	<!-- 소유자 -->
								<spring:message code="Cache.ACC_lbl_cardOwner"/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" id="cardUserName1"></span>
								<a class="btn_del03" onclick="CardReceipt.userCodeDel()"></a>
							</div>
							<a class="btn_search03" onclick="CardReceipt.userCodeSearch()"></a>
							<input id="cardUserCode1" type="text" hidden>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">		<!-- 사용일자 -->
								<spring:message code="Cache.ACC_lbl_approveDate"/>
							</span>
							<div id="approveDate1" class="dateSel type02">
							</div>
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">		<!-- 정산상태 -->
								<spring:message code="Cache.ACC_lbl_taxInvoice"/>
							</span>
							<span id="active" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">		<!-- 카드번호 -->
								<spring:message code="Cache.ACC_lbl_cardNumber"/>
							</span>
							<input	id="cardNo1" type="text" placeholder="" MaxLength="16"
									style="width:239px;"
									onkeypress	= "return inputNumChk(event)"
									onkeydown	="CardReceipt.onenter(this)"
									onkeyup	= "CardReceipt.changeCardNo()">
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">		<!-- 승인구분 -->
								<spring:message code="Cache.ACC_lbl_ApvGubun"/>
							</span>
							<span id="infoIndex" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">		<!-- 개인사용 -->
								<spring:message code="Cache.ACC_lbl_personalUse"/>
							</span>
							<span id="isPersonalUse" class="selectType02" style="width:239px;">
							</span>
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="CardReceipt.searchList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<div id="searchbar2" class="bodysearch_Type01">
				<div class="inPerView type06">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								소유자
							</span>
							<div class="name_box_wrap">
								<span class="name_box" id="cardUserName2"></span>
								<a class="btn_del03" onclick="CardReceipt.userCodeDel()"></a>
							</div>
							<a class="btn_search03" onclick="CardReceipt.userCodeSearch()"></a>
							<input id="cardUserCode2" type="text" hidden>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								사용일자
							</span>
							<div id="approveDate2" class="dateSel type02">
							</div>
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="CardReceipt.searchList()" style ="position:absolute;left:600px"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<div class="inPerTitbox">
								<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_cardNumber"/>
								</span>
								<input	id="cardNo2" type="text" placeholder="" MaxLength="16"
										style="width:239px;"
										onkeypress	= "return inputNumChk(event)"
										onkeydown	= "CardReceipt.onenter(this)"
										onkeyup	= "CardReceipt.changeCardNo()">
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
						<span id="listCount" class="selectType02 listCount" onchange="CardReceipt.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="CardReceipt.searchList()"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
	</div>
<script>

	if (!window.CardReceipt) {
		window.CardReceipt = {};
	}
	
	(function(window) {
		var CardReceipt = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},

				pageInit : function() {
					var me = this;
					setPropertySearchType('CardReceipt','searchProperty');
					setPropertySyncType('CardReceipt','syncProperty');
					setHeaderTitle('headerTitle');
					me.setPageViewController();
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

				setPageViewController :function(){
					var searchProperty	= accountCtrl.getInfo("searchProperty").val();
					var syncProperty	= accountCtrl.getInfo("syncProperty").val();
					
					if(	searchProperty == "SAP"){
						accountCtrl.getInfo("btnToss").css("display",		"none");
						accountCtrl.getInfo("btnSync").css("display",		"none");
						accountCtrl.getInfo("searchbar2").show();
						accountCtrl.getInfo("searchbar1").hide();
						
					}else if(searchProperty == "SOAP"){
						accountCtrl.getInfo("btnToss").css("display",		"none");
						accountCtrl.getInfo("btnSync").css("display",		"none");
						accountCtrl.getInfo("searchbar2").show();
						accountCtrl.getInfo("searchbar1").hide();
						
					}else{
						accountCtrl.getInfo("btnToss").css("display",		"");
						accountCtrl.getInfo("btnSync").css("display",		"");
						accountCtrl.getInfo("searchbar1").show();
						accountCtrl.getInfo("searchbar2").hide();
					}
					
					if(syncProperty == "") {
						accountCtrl.getInfo("btnSync").css("display", "none");
					}
				},
				
				pageDatepicker : function(){
					var dateInfo	= new Date();
					var currentDay  = dateInfo.format('yyyyMMdd');
					
					dateInfo.setMonth(dateInfo.getMonth() -1); 
					var prevDate = dateInfo.getFullYear() + ('0' + (dateInfo.getMonth() +  1 )).slice(-2) + ('0' + dateInfo.getDate()).slice(-2);
					
					makeDatepicker('approveDate1','approveDateS1','approveDateE1',prevDate,currentDay,'');
					makeDatepicker('approveDate2','approveDateS2','approveDateE2',prevDate,currentDay,'');
				},
				
				setSelectCombo : function(pCompanyCode){
					accountCtrl.getInfo("listCount").children().remove();
					accountCtrl.getInfo("active").children().remove();
					accountCtrl.getInfo("cardClass").children().remove();
					accountCtrl.getInfo("infoIndex").children().remove();
					accountCtrl.getInfo("isPersonalUse").children().remove();

					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "CardReceipt.searchList()");
					accountCtrl.getInfo("active").addClass("selectType02");
					accountCtrl.getInfo("cardClass").addClass("selectType02").css("width", "239px");
					accountCtrl.getInfo("infoIndex").addClass("selectType02");
					accountCtrl.getInfo("isPersonalUse").addClass("selectType02").css("width", "239px");
					
					var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'Active',			'target':'active',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'CardClass',		'target':'cardClass',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'InfoIndex',		'target':'infoIndex',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'IsUse',			'target':'isPersonalUse',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
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
					accountCtrl.refreshAXSelect("active");
					accountCtrl.refreshAXSelect("cardClass");
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
				},

				setHeaderData : function() {
					var me = this;
					
					var searchProperty	= accountCtrl.getInfo("searchProperty").val();
					
					if(searchProperty == 'SAP'){
						me.params.headerData = [	{	key:'ApproveDate',			label:"<spring:message code='Cache.ACC_lbl_approveDate' />",		width:'100',		align:'center'},	//사용일자
													{	key:'ApproveNo',			label:"<spring:message code='Cache.ACC_lbl_confirmNum' />",		width:'100',		align:'center',		//승인번호
														formatter:function () {
															var rtStr =	""
																		+	"<a onclick='CardReceipt.cardReceiptPopup(\""+ this.item.ApproveNo +"\"); return false;'>"
																		+		"<font color='blue'>"
																		+			this.item.ApproveNo
																		+		"</font>"
																		+	"</a>";
															return rtStr;
														}
													},
													{	key:'StoreName',			label:"<spring:message code='Cache.ACC_lbl_franchiseCorpName' />",	width:'150',		align:'left'},	//가맹점명
													{	key:'AmountWon',			label:"<spring:message code='Cache.ACC_lbl_amountWon' />",			width:'100',		align:'right'},	//이용금액
													{	key:'ForeignCurrency',		label:"<spring:message code='Cache.ACC_lbl_foreignCurrency' />",		width:'07',		align:'center'},//통화
													{	key:'CardNo',				label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",			width:'150',	align:'center'},//카드번호
													{	key:'CardUserCode',			label:"<spring:message code='Cache.ACC_lbl_cardUserCode' />",		width:'100',		align:'center'},//소유자ID
												]
					}else if(searchProperty == 'SOAP'){
						me.params.headerData = [	{	key:'ApproveDate',			label:"<spring:message code='Cache.ACC_lbl_approveDate' />",		width:'100',		align:'center'},	//사용일자
													{	key:'ApproveTime',			label:"<spring:message code='Cache.ACC_lbl_approveTime' />",		width:'100',		align:'center'},	//사용시각
													{	key:'ApproveNo',			label:"<spring:message code='Cache.ACC_lbl_confirmNum' />",		width:'100',		align:'center',		//승인번호
														formatter:function () {
															var rtStr =	""
																		+	"<a onclick='CardReceipt.cardReceiptPopup(\""+ this.item.ApproveNo +"\"); return false;'>"
																		+		"<font color='blue'>"
																		+			this.item.ApproveNo
																		+		"</font>"
																		+	"</a>";
															return rtStr;
														}
													},
													{	key:'StoreName',			label:"<spring:message code='Cache.ACC_lbl_franchiseCorpName' />",	width:'150',		align:'left'},	//가맹점명
													{	key:'AmountWon',			label:"<spring:message code='Cache.ACC_lbl_amountWon' />",			width:'100',		align:'right'},	//이용금액
													{	key:'ForeignCurrency',		label:"<spring:message code='Cache.ACC_lbl_foreignCurrency' />",		width:'70',		align:'center'},//통화
													{	key:'CardNo',				label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",			width:'150',	align:'center'},//카드번호
													{	key:'CardUserCode',			label:"<spring:message code='Cache.ACC_lbl_cardUserCode' />",		width:'100',		align:'center'},//소유자
												]
					}else{
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
													{ 	key:'CompanyName',			label : "<spring:message code='Cache.ACC_lbl_company' />",		width:'100',		align:'center'},		//회사
													{	key:'ActiveName',			label:"<spring:message code='Cache.ACC_lbl_taxInvoice' />",		width:'150',		align:'center'},	//정산상태
													{	key:'InfoIndex',			label:"<spring:message code='Cache.ACC_lbl_ApvGubun' />",		width:'100',		align:'center'},	//승인구분
													{	key:'IsPersonalUse',		label:"<spring:message code='Cache.ACC_lbl_personalUse' />",	width:'100',		align:'center'},	//개인사용
													{	key:'ApproveDate',			label:"<spring:message code='Cache.ACC_lbl_approveDate' />",	width:'100',		align:'center'},	//사용일자
													{	key:'ApproveTime',			label:"<spring:message code='Cache.ACC_lbl_approveTime' />",	width:'100',		align:'center'},	//사용시각
													{	key:'ApproveNo',			label:"<spring:message code='Cache.ACC_lbl_confirmNum' />",		width:'100',		align:'center',		//승인번호
														formatter:function () {
															var rtStr =	""
																		+	"<a onclick='CardReceipt.cardReceiptPopup(\""+ this.item.ReceiptID +"\"); return false;'>"
																		+		"<font color='blue'>"
																		+			this.item.ApproveNo
																		+		"</font>"
																		+	"</a>";
															return rtStr;
														}
													},
													{	key:'StoreName',			label:"<spring:message code='Cache.ACC_lbl_franchiseCorpName' />",	width:'200',	align:'left'},	//가맹점명
													{	key:'AmountWon',			label:"<spring:message code='Cache.ACC_lbl_amountWon' />",			width:'100',	align:'right'},	//이용금액
													{	key:'ForeignCurrency',		label:"<spring:message code='Cache.ACC_lbl_foreignCurrency' />",	width:'70',		align:'center'},//통화
													{	key:'CardNo',				label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",			width:'200',	align:'center'},//카드번호
													{	key:'CardUserCode',			label:"<spring:message code='Cache.ACC_lbl_cardUserCode' />",		width:'100',	align:'center'},//소유자ID
													{	key:'CardUserName',			label:"<spring:message code='Cache.ACC_lbl_cardOwner' />",			width:'100',	align:'center'},//소유자
													{	key:'CardUserDept',			label:"<spring:message code='Cache.ACC_lbl_cardOwnerDept' />",		width:'100',	align:'center'},//소유자 부서
													{	key:'TossSenderUserCode',	label:"<spring:message code='Cache.ACC_lbl_tossSenderUserCode' />",	width:'100',	align:'center'},//전달자ID
													{	key:'TossSenderUserName',	label:"<spring:message code='Cache.ACC_lbl_tossSenderUserName' />",	width:'100',	align:'center'},//전달자
													{	key:'TossUserCode',			label:"<spring:message code='Cache.ACC_lbl_tossUserCode' />",		width:'100',	align:'center'},//전달대상ID
													{	key:'TossUserName',			label:"<spring:message code='Cache.ACC_lbl_tossUserName' />",		width:'100',	align:'center'},//전달대상
													{	key:'TossComment',			label:"<spring:message code='Cache.ACC_lbl_tossComment' />",		width:'100',	align:'left'}//전달의견
												]
						
					}
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},

				searchList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var companyCode		= accountCtrl.getComboInfo("companyCode").val();
					var cardClass		= accountCtrl.getComboInfo("cardClass").val();
					var active			= accountCtrl.getComboInfo("active").val();
					var infoIndex		= accountCtrl.getComboInfo("infoIndex").val();
					var isPersonalUse	= accountCtrl.getComboInfo("isPersonalUse").val();
					var searchProperty	= accountCtrl.getInfo("searchProperty").val();
					
					if(searchProperty=='SOAP'){
						var cardUserCode	= accountCtrl.getInfo("cardUserCode2").val()
						var cardNo			= accountCtrl.getInfo("cardNo2").val();
						var approveDateS	= accountCtrl.getInfo("approveDateS2").val();
						var approveDateE	= accountCtrl.getInfo("approveDateE2").val();
					}else{
						var cardUserCode	= accountCtrl.getInfo("cardUserCode1").val();
						var cardNo			= accountCtrl.getInfo("cardNo1").val();
						var approveDateS	= accountCtrl.getInfo("approveDateS1").val();
						var approveDateE	= accountCtrl.getInfo("approveDateE1").val();
					}
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/cardReceipt/getCardReceiptList.do";
					var ajaxPars		= {	"searchProperty": searchProperty,
											"companyCode"	: companyCode,
							 				"cardClass"		: cardClass,
							 				"cardUserCode"	: cardUserCode,
							 				"approveDateS"	: approveDateS,
							 				"approveDateE"	: approveDateE,
							 				"active"		: active,
							 				"cardNo"		: cardNo,
							 				"infoIndex"		: infoIndex,
							 				"isPersonalUse" : isPersonalUse
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
									,	"fitToWidth"	: false
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
				},
				
				userCodeSearch : function(){
					var popupID		= "orgmap_pop";
					var openerID	= "CardReceipt";
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
					var searchProperty	= accountCtrl.getInfo("searchProperty").val();
					if(searchProperty == 'SOAP'){
						accountCtrl.getInfo('cardUserCode2').val(UserCode[0]);
						accountCtrl.getInfo('cardUserName2').text(userName[0]);
					}else{
						accountCtrl.getInfo('cardUserCode1').val(UserCode[0]);
						accountCtrl.getInfo('cardUserName1').text(userName[0]);
					}
				},
				
				userCodeDel : function(){
					var searchProperty	= accountCtrl.getInfo("searchProperty").val();
					if(searchProperty == 'SOAP'){
						accountCtrl.getInfo('cardUserCode2').val('');
						accountCtrl.getInfo('cardUserName2').text('');
					}else{
						accountCtrl.getInfo('cardUserCode1').val('');
						accountCtrl.getInfo('cardUserName1').text('');
					}
				},
				
				cardReceiptSync : function(){
					$.ajax({
						url	: "/account/cardReceipt/cardReceiptSync.do",
						type: "POST",
						data: {
							CompanyCode : accountCtrl.getComboInfo("companyCode").val()
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_syncComp' />");		//동기화되었습니다
								CardReceipt.searchList('N');
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />");	 // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");	 // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				excelDownload : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
				  		if(result){
							var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerData);
							var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerData);
							var companyCode		= accountCtrl.getComboInfo("companyCode").val();
							var cardClass		= accountCtrl.getComboInfo("cardClass").val();
							var active			= accountCtrl.getComboInfo("active").val();
							var infoIndex		= accountCtrl.getComboInfo("infoIndex").val();
							var isPersonalUse	= accountCtrl.getComboInfo("isPersonalUse").val();
							var searchProperty	= accountCtrl.getInfo("searchProperty").val();
							
							if(searchProperty=='SOAP'){
								var cardUserCode	= accountCtrl.getInfo("cardUserCode2").val()
								var cardNo			= accountCtrl.getInfo("cardNo2").val();
								var approveDateS	= accountCtrl.getInfo("approveDateS2").val();
								var approveDateE	= accountCtrl.getInfo("approveDateE2").val();
							}else{
								var cardUserCode	= accountCtrl.getInfo("cardUserCode1").val();
								var cardNo			= accountCtrl.getInfo("cardNo1").val();
								var approveDateS	= accountCtrl.getInfo("approveDateS1").val();
								var approveDateE	= accountCtrl.getInfo("approveDateE1").val();
							}
							var headerType			= accountCommon.getHeaderTypeForExcel(me.params.headerData);
							var title 				= accountCtrl.getInfo("headerTitle").text();
							
							var	locationStr		= "/account/cardReceipt/cardReceiptExcelDownload.do?"
												//+ "headerName="			+ encodeURI(headerName)
												+ "headerName="			+ encodeURIComponent(encodeURIComponent(headerName))
												+ "&headerKey="			+ encodeURIComponent(headerKey)
												+ "&companyCode="		+ encodeURIComponent(companyCode)
												+ "&cardClass="			+ encodeURIComponent(cardClass)
												+ "&cardUserCode="		+ encodeURIComponent(cardUserCode)
												+ "&approveDateS="		+ encodeURIComponent(approveDateS)
												+ "&approveDateE="		+ encodeURIComponent(approveDateE)
												+ "&active="			+ encodeURIComponent(active)
												+ "&searchProperty="	+ encodeURIComponent(searchProperty)
												+ "&cardNo="			+ encodeURIComponent(cardNo)
												+ "&infoIndex="			+ encodeURIComponent(infoIndex)
												+ "&isPersonalUse="		+ encodeURIComponent(isPersonalUse)
												//+ "&title="				+ encodeURI(accountCtrl.getInfo("headerTitle").text())
												+ "&title="				+ encodeURIComponent(encodeURIComponent(title))
												+ "&headerType=" 		+ encodeURIComponent(headerType);
						
							location.href = locationStr;
				       	}
					});
				},
				
				cardReceiptPopup : function(key){
					var popupName	=	"CardReceiptPopup";
					var popupID		=	"cardReceiptPopup";
					var openerID	= "CardReceipt";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_cardReceiptInvoice' />"; //신용카드 매출전표
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+ popupID	+ "&"
									+	"openerID="		+ openerID	+ "&"
									+	"popupName="	+ popupName	+ "&"
									+	"approveNo="	+ key		+ "&"
									+	"receiptID="	+ key;
					Common.open("",popupID,popupTit,url,"320px", "510px","iframe",true,null,null,true);
				},
				
				tossUserPopup : function(){
					var me = this;
					var chkList = me.params.gridPanel.getCheckedList(0);
					if(chkList.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noSelectCard' />");	//선택된 카드내역정보가 없습니다.
						return;
					}
					
					var popupName	= "TossUserPopup";
					var popupID		= "tossUserPopup";
					var openerID	= "CardReceipt";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_tossUser' />";	//수신내역전달
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
						Common.Inform("<spring:message code='Cache.ACC_msg_noSelectCard' />");
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
								CardReceipt.searchList();
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
					var me = this;
					var searchProperty	= accountCtrl.getInfo("searchProperty").val();
					var cardNo = "";
					if(searchProperty == 'SOAP'){
						cardNo = accountCtrl.getInfo("cardNo2").val();
						cardNo = getNumOnly(cardNo);
						accountCtrl.getInfo("cardNo2").val(cardNo);
					}else{
						cardNo = accountCtrl.getInfo("cardNo1").val();
						cardNo = getNumOnly(cardNo);
						accountCtrl.getInfo("cardNo1").val(cardNo);
					}
					
				},
				
				onenter : function(obj){
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
				},
				
				templateDownload : function() {
					location.href = "/account/cardReceipt/downloadTemplateFile.do";
				},
				
				excelUpload : function() {
					var popupID		= "CardReceiptExcelPopup";
					var openerID	= "CardReceipt";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_corpCardUseList' />"; //법인카드 사용내역
					var popupYN		= "N";
					var callBack	= "cardReceiptExcelPopup_CallBack";
					var popupUrl	= "/account/cardReceipt/CardReceiptExcelPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack;
					
					Common.open("", popupID, popupTit, popupUrl, "500px", "220px", "iframe", true, null, null, true);
				},
				cardReceiptExcelPopup_CallBack : function(){
					var me = this;
					me.searchList();
				},
				sendDelay: function(sendAll) { // 미상신 알림메일
					var me = this;
					Common.Confirm("<spring:message code='Cache.lbl_AccSendNotiCardAlert' /><br>"+	//법인카드,세금계산서의 미상신건들에 대한 알림 메일을 전송합니다.
								"<spring:message code='Cache.msg_apv_ConfirmSend' /> ", "Confirmation Dialog", function (confirmResult) {
						if (confirmResult) {
							//sendAll : true -> 전체 미상신 알림전송
							//			false -> 선택 미상신 알림전송
							var sendAlamList = [];
							if (!sendAll) {
								var checkList =  me.params.gridPanel.getCheckedList(0).filter(function(e) { return e.Active == "N" });
								//checkList.forEach(function(e) { sendAlamList.push("'"+e.ReceiptID+"'"); });
								checkList.forEach(function(e) { sendAlamList.push(e.ReceiptID); });
								
								if(sendAlamList.length == 0){
								    Common.Warning("<spring:message code='Cache.msg_noSelectDelayData' />"); //선택된 미상신내역이 없습니다.
									return;
								}
							}
							
							$.ajax({
								url		: "/account/doAutoDelayAlam.do",
								type	: "POST",
								data	:{
									"DirectSend"	: "Y",
									"SendType"		: "Card",
									"SendAlamList"	: sendAlamList.join(),
									companyCode		: accountCtrl.getComboInfo("companyCode").val()
								},
								success	:function (data) {
									if(data.status == "SUCCESS") {
										var msg = "<spring:message code='Cache.msg_sms_send_success' /> ["+data.data.sendCnt+"<spring:message code='Cache.ACC_lbl_items' />]"; // 전송을 완료했습니다 [0건]
										if(sendAll) msg += "\n["+data.data.sendDateRange+"]";
										
										Common.Inform(msg);
									} else {
										Common.Error("<spring:message code='Cache.CPMail_sendFalse_msg' />"); // 전송에 실패 하였습니다.
									}
								},
								error	:function (error){
									Common.Error("<spring:message code='Cache.CPMail_sendFalse_msg' />"); // 전송에 실패 하였습니다.
								}
							});
						}
					});	
				}
		}
		window.CardReceipt = CardReceipt;
	})(window);
</script>