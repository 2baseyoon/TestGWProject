<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

	<style>
		.pad10 { padding:10px;}
	</style>
	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<h2 class="title">개인카드</h2>
	</div>
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 새로고침 -->
					<a class="btnTypeDefault"			onclick="CardApplicationUser.Refresh()"><spring:message code="Cache.btn_Refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"	onclick="CardApplicationUser.ExcelDownload();"><spring:message code="Cache.btn_ExcelDownload"/></a>
				</div>
				<!-- 상단 버튼 끝 -->
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="CardApplicationUser.searchList();">
					</span>
					<button class="btnRefresh" type="button" onclick="CardApplicationUser.searchList();"></button>
				</div>
			</div>
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type06">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 회사 -->
								<spring:message code="Cache.ACC_lbl_company"/>
							</span>
							<span id="companyCode" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 소유자 -->
								<spring:message code="Cache.ACC_lbl_cardOwner"/>
							</span>
							<div class="autoCompleteCustom bodysearch">
								<div class="ui-autocomplete-multiselect ui-state-default ui-widget">
									<div class="ui-autocomplete-multiselect-item">
										<span id="registerName">
										</span>
										<span class="ui-icon ui-icon-close" onclick="CardApplicationUser.userCodeDel()"></span>
									</div>
								</div>
								<a class="btnMoreStyle02" onclick="CardApplicationUser.userCodeSearch()"></a>
							</div>
							<input id="registerCode" type="text" hidden>
						</div>
						<a class="btnTypeDefault  btnSearchBlue"	style ="position:absolute;left:530px"	onclick="CardApplicationUser.searchList();"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 카드번호 -->
								<spring:message code="Cache.ACC_lbl_cardNumber"/>
							</span>
							<input	id="cardNo" type="text" placeholder="" MaxLength="16"
									onkeypress	= "return inputNumChk(event)"
									onkeydown	= "pressHan(this)"
									onkeyup	= "CardApplicationUser.changeCardNo()">
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 사용여부 -->
								<spring:message code="Cache.ACC_lbl_isUse" />
							</span>
							<span id="isUse" class="selectType02">
							</span>
						</div>
					</div>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

	
	if (!window.CardApplicationUser) {
		window.CardApplicationUser = {};
	}
	
	(function(window) {
		var CardApplicationUser = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},

				pageInit : function() {
					var me = this;
					me.setSelectCombo();
					me.setHeaderData();
					me.searchList('Y');
				},

				pageView : function() {
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

				setSelectCombo : function(){
					var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',	'target':'listCount',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'CompanyCode',		'target':'companyCode',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"} //전체
						,	{'codeGroup':'IsUse',			'target':'isUse',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
					]
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},

				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("companyCode");
					accountCtrl.refreshAXSelect("isUse");
				},

				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'CardNo',			label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",	width:'80',	align:'center',		//카드번호
													formatter:function () {
														var rtStr =	""
																	+	"<a onclick='CardApplicationUser.cardApplicationUserPopup(\""+ this.item.CardApplicationID +"\"); return false;'>"
																	+		"<font color='blue'>"
																	+			this.item.CardNo
																	+		"</font>"
																	+	"</a>";
														return rtStr;
													}
												},
												{	key:'CardCompanyName',	label:"<spring:message code='Cache.ACC_lbl_cardCompany' />",	width:'50',		align:'center'},	//카드회사
												{	key:'RegisterName',		label:"<spring:message code='Cache.ACC_lbl_cardOwner' />",	width:'50',		align:'center'},	//소유자
												{	key:'RegistDate',		label:"<spring:message code='Cache.ACC_lbl_requestDate' />" +Common.getSession("UR_TimeZoneDisplay",	width:'50',		align:'center',
														formatter:function(){
															return CFN_TransLocalTime(this.item.RegistDate,_ServerDateSimpleFormat);
													}
												},	//신청일자
												{	key:'IsUse',			label:"<spring:message code='Cache.ACC_lbl_isUse' />",		width:'50',		align:'center',		//사용여부
														formatter:function () {
															var col			= 'IsUse'
															var key			= this.item.CardApplicationID;
															var value		= this.item.IsUse;
															var on_value	= 'Y';
															var off_value	= 'N';
															var onchangeFn	= 'CardApplicationUser.updateCardApplicationUseYN(\"'+ this.item.CardApplicationID +"\",\""+ this.item.IsUse +'\")';
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
					
					var companyCode		= accountCtrl.getComboInfo("companyCode").val();
					var registerCode	= accountCtrl.getInfo("registerCode").val();
					var cardNo			= accountCtrl.getInfo("cardNo").val();
					var isUse			= accountCtrl.getComboInfo("isUse").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/cardApplication/getCardApplicationList.do";
					var ajaxPars		= {	"companyCode"	: companyCode,
							 				"registerCode"	: registerCode,
							 				"cardNo"		: cardNo,
							 				"isUse"			: isUse
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
					var openerID	= "CardApplicationUser";
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
					
					accountCtrl.getInfo("registerCode").val(UserCode[0]);
					accountCtrl.getInfo("registerName").text(userName[0]);
				},
				
				userCodeDel : function(){
					accountCtrl.getInfo("registerCode").val('');
					accountCtrl.getInfo("registerName").text('');
				},
				
				cardApplicationUserPopup : function(key){
					var popupID		= "CardApplicationUserPopup";
					var openerID	= "CardApplicationUser";
					var popupTit	= "<spring:message code='Cache.ACC_014' />";	//개인카드 정보 수정
					var popupYN		= "N";
					var callBack	= "CardApplicationUserPopup_CallBack";
					var popupUrl	= "/account/cardApplication/getCardApplicationUserPopup.do?"
									+ "popupID="			+ popupID	+ "&"
									+ "openerID="			+ openerID	+ "&"
									+ "popupYN="			+ popupYN	+ "&"
									+ "callBackFunc="		+ callBack	+ "&"
									+ "cardApplicationID="	+ key;
							
					Common.open("", popupID, popupTit, popupUrl, "550px", "420px", "iframe", true, null, null, true);
					
				},
				
				CardApplicationUserPopup_CallBack : function(){
					var me = this;
					me.searchList();
				},
				
				updateCardApplicationUseYN : function(key,YN){
					var pYN = ""
					
					if(YN == 'Y'){
						pYN = 'N'
					}else{
						pYN = 'Y'
					}
					
					var params	= new Object();
					
					params.cardApplicationID	= key;
					params.isUse				= pYN;
					
					$.ajax({
						url	:"/account/cardApplication/saveCardApplicationInfo.do",
						type		: "POST",
						data		: JSON.stringify(params),
						dataType	: "json",
						contentType	: "application/json",
						
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.msg_37'/>");		//저장되었습니다
								CardApplicationUser.searchList();
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				ExcelDownload : function(){
					var me = this;
					
					Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
							var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerData);
							var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerData);
							var companyCode		= accountCtrl.getComboInfo("companyCode").val();
							var registerCode	= accountCtrl.getInfo("registerCode").val();
							var cardNo			= accountCtrl.getInfo("cardNo").val();
							var isUse			= accountCtrl.getComboInfo("isUse").val();
							var headerType	= accountCommon.getHeaderTypeForExcel(me.params.headerData);
							
							var	locationStr		= "/account/cardApplication/cardApplicationExcelDownload.do?"
												+ "headerName="		+ encodeURI(headerName)
												+ "&headerKey="		+ encodeURI(headerKey)
												+ "&companyCode="	+ encodeURI(companyCode)
												+ "&registerCode="	+ encodeURI(registerCode)
												+ "&cardNo="		+ encodeURI(cardNo)
												+ "&isUse="			+ encodeURI(isUse)
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
				
				Refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.CardApplicationUser = CardApplicationUser;
	})(window);
</script>