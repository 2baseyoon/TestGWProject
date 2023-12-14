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
	<input id="syncProperty" type="hidden" />
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 추가 -->
					<a class="btnTypeDefault  btnTypeBg"	onclick="ExchangeRate.exchangeRateAdd();"><spring:message code="Cache.ACC_btn_add"/></a>
					<!-- 삭제 -->
					<a class="btnTypeDefault"				onclick="ExchangeRate.exchangeRateDel();"><spring:message code="Cache.ACC_btn_delete"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"				onclick="ExchangeRate.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"		onclick="ExchangeRate.excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 동기화 -->
					<a class="btnTypeDefault"				onclick="ExchangeRate.exchangeRateSync();" id="btnSync"><spring:message code="Cache.ACC_btn_sync"/></a>
				</div>
				<!-- 상단 버튼 끝 -->
			</div>
			
			<!-- 검색 내용 -->
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type07">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_searchDate"/>	<!-- 조회일자 -->
							</span>
							<div id="ddArea" class="dateSel type02">
							</div>
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="ExchangeRate.searchList();"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span class="selectType02 listCount" id="listCount" onchange="ExchangeRate.searchList();">
					</span>
					<button class="btnRefresh" type="button" onclick="ExchangeRate.searchList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
	
<script>

	if (!window.ExchangeRate) {
		window.ExchangeRate = {};
	}
	
	(function(window) {
		var ExchangeRate = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
			
				pageInit : function() {
					var me = this;
					setPropertySyncType('ExchangeRate','syncProperty');
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
					var syncProperty	= accountCtrl.getInfo("syncProperty").val();
					
					if(syncProperty == "") {
						accountCtrl.getInfo("btnSync").css("display", "none");
					}
				},
		
				pageDatepicker : function(){
					makeDatepicker('ddArea','startDD','endDD','','','');
				},
				
				setSelectCombo : function(){
					var AXSelectMultiArr	= [	
								{'codeGroup':'listCountNum',		'target':'listCount',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
	   					]
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},
				
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
				},
				
				setHeaderData : function() {
					var me = this;
					
					me.params.headerData = [
						{
							key: 'chk',
							label: 'chk',
							width: '20', 
							align: 'center',
							formatter: 'checkbox'
						},
						{	
							key: 'YYYYMMDD', 
							label: "<spring:message code='Cache.ACC_lbl_date'/>",
							width: '70',
							align: 'center',
							formatter: function() {
								let YYYYMMDD = this.item.YYYYMMDD.replace(/(\d{4})(\d{2})(\d{2})/g, '$1-$2-$3');
								return `<a onclick='ExchangeRate.onCodeClick("${"${YYYYMMDD}"}"); return false;'>
											<font color='blue'>
												${'${YYYYMMDD}'}
											</font>
										</a>`;
							}
						}
					]
					
					$.ajax({
						type: "POST",
						url: "/account/baseCode/getCodeListByCodeGroup.do",
						async: false,
						data: {
							codeGroup : 'ExchangeNation',
							companyCode : sessionObj["DN_Code"] == "ORGROOT" ? "ALL" : sessionObj["DN_Code"]
						},
						success: function (data) {
							if(data.status == "SUCCESS"){
								if(data.list.length > 0) {
									$(data.list).each(function(i, obj){
										if(obj.IsUse == "Y" && obj.IsGroup == "N" && obj.Code != "KRW") {
											me.params.headerData.push({
												key: obj.Code,	
												label: obj.Code,	
												width: '50', 
												align: 'center'
											});
										}
									});
								}
							}
						},
						error: function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}
					});
					
					/* me.params.headerData = [	{	key:'chk',				label:'chk',	width:'20', align:'center',
													formatter:'checkbox'
												},
												{	key:'ExchangeRateDate',	label:"<spring:message code='Cache.ACC_lbl_date' />",		width:'70', align:'center' ,	//날짜
													formatter:function () {
														var rtStr =	""
															+	"<a onclick='ExchangeRate.onCodeClick("+ this.item.ExchangeRateID +"); return false;'>"
															+		"<font color='blue'>"
															+			this.item.ExchangeRateDate_VIEW
															+		"</font>"
															+	"</a>";
														return rtStr;
								            		}
							    				}
												,
												{	key:'USD',	label:'USD',	width:'50', align:'right'},
												{	key:'EUR',	label:'EUR',	width:'50', align:'right'},
												{	key:'AED',	label:'AED',	width:'50', align:'right'},
												{	key:'AUD',	label:'AUD',	width:'50', align:'right'},
												{	key:'BRL',	label:'BRL',	width:'50', align:'right'},
												{	key:'CAD',	label:'CAD',	width:'50', align:'right'},
												{	key:'CHF',	label:'CHF',	width:'50', align:'right'},
												{	key:'CNY',	label:'CNY',	width:'50', align:'right'},
												{	key:'JPY',	label:'JPY',	width:'50', align:'right'},
												{	key:'SGD',	label:'SGD',	width:'50', align:'right'}
											] */
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},
				
				searchList : function(YN){
					var me = this;
					me.setHeaderData();
					var stDt = accToString(accountCtrl.getInfo('startDD').val());
					var edDt = accToString(accountCtrl.getInfo('endDD').val());
					var exchangeRateDateStart = stDt.replaceAll(".", "");
					var exchangeRateDateFinish = edDt.replaceAll(".", "");
					
					var today = new Date();
					if(	accountCtrl.getInfo('endDD').val() == ""	||
						accountCtrl.getInfo('endDD').val() == null){
						exchangeRateDateFinish = today.toISOString().slice(0,10).replace(/-/g,"");
					}
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					// var ajaxUrl			= "/account/exchangeRate/getExchangeRatelist.do";
					var ajaxUrl	= "/account/exchangeRate/exchangesList.do";
					var ajaxPars		= {	"exchangeRateDateStart"		: exchangeRateDateStart,
							 				"exchangeRateDateFinish"	: exchangeRateDateFinish
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
				exchangeRateDel: function() {
					var me = this;
					
					var deleteObj = me.params.gridPanel.getCheckedList(0);
					if(deleteObj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noDataDelete' />");	//삭제할 항목을 선택해주세요
						return;
					} else {
						Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//삭제하시겠습니까
							if(result){
								/* var deleteSeq = "";
								for(var i=0; i<deleteObj.length; i++){
									if(i==0){
										deleteSeq = deleteObj[i].YYYYMMDD;
									}else{
										deleteSeq = deleteSeq + "," + deleteObj[i].YYYYMMDD;
									}
								} */
								
								fetch("/account/exchangeRate/exchangesRemove.do", {
									method: "DELETE",
									headers: {
										"Content-Type": "application/json"
									},
									body: JSON.stringify({
										"deleteObj": deleteObj
									})})
									.then((response) => response.json())
									.then((data) => {
										if(data.status == "SUCCESS"){
											Common.Inform("<spring:message code='Cache.ACC_msg_delComp' />");	//삭제가 완료되었습니다.
											ExchangeRate.searchList();
										}else{
											Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
										}
									})
									.catch ((error) => {
										coviCmn.traceLog(error);
										Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
				 					});
							}
						})
					}
				},
				/* exchangeRateDel : function(){
					var me = this;
					var deleteObj = me.params.gridPanel.getCheckedList(0);
					if(deleteObj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noDataDelete' />");	//삭제할 항목을 선택해주세요
						return;
					}else{
						
						Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//삭제하시겠습니까
							if(result){
								var deleteSeq = "";
								for(var i=0; i<deleteObj.length; i++){
									if(i==0){
										deleteSeq = deleteObj[i].ExchangeRateID;
									}else{
										deleteSeq = deleteSeq + "," + deleteObj[i].ExchangeRateID;
									}
								}
								$.ajax({
									url : "/account/exchangeRate/deleteExchangeRateInfo.do",
									type: "POST",
									data: {
										"deleteSeq" : deleteSeq
									},
									success:function (data){
										if(data.status == "SUCCESS"){
											Common.Inform("<spring:message code='Cache.ACC_msg_delComp' />");	//삭제가 완료되었습니다.
											ExchangeRate.searchList();
										}else{
											Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
										}
									},
									error:function (error){
										Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
									}				
								});
							}
						})
					}
				}, */
				
				excelDownload : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "저장", function(result){
			       		if(result){
							var headerName	= accountCommon.getHeaderNameForExcel(me.params.headerData);
							var headerKey	= accountCommon.getHeaderKeyForExcel(me.params.headerData);
							
							var stDt = accToString(accountCtrl.getInfo('startDD').val());
							var edDt = accToString(accountCtrl.getInfo('endDD').val());
							var start = stDt.replaceAll(".", "");
							var finish = edDt.replaceAll(".", "");
							var today		= new Date();
							
							if(	accountCtrl.getInfo('endDD').val() == ""	||
								accountCtrl.getInfo('endDD').val() == null){
								finish = today.toISOString().slice(0,10).replace(/-/g,"");
							}
							var headerType			= accountCommon.getHeaderTypeForExcel(me.params.headerData);
							var title 			= accountCtrl.getInfo("headerTitle").text();
							
							location.href	= "/account/exchangeRate/exchangeRateExcelDownload.do?"
											//+ "headerName="	+ encodeURI(headerName)	+ "&"
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName)) + "&"
											+ "headerKey="	+ encodeURIComponent(headerKey)		+ "&"
											+ "start="		+ encodeURI(start)			+ "&"
											+ "finish="		+ encodeURI(finish)		+ "&"
											//+ "title="		+ encodeURI(accountCtrl.getInfo("headerTitle").text())
											+ "title="			+ encodeURIComponent(encodeURIComponent(title))
											+ "&headerType=" + encodeURI(headerType);
						}
					});
				},
				
				exchangeRateAdd : function(){
					var mode		= "add"
					var popupID		= "ExchangeRatePopup";
					var openerID	= "ExchangeRate";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_exchangeRateAdd' />";	//환율정보등록
					var popupYN		= "N";
					var callBack	= "exchangeRatePopup_CallBack";
					var popupUrl	= "/account/exchangeRate/getExchangeRatePopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "mode="			+ mode;
					
					Common.open("", popupID, popupTit, popupUrl, "350px", "580px", "iframe", true, null, null, true);
				},
				
				onCodeClick : function(exchangeRateDate){
					var mode		= "modify"
					var popupID		= "ExchangeRatePopup";
					var openerID	= "ExchangeRate";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_exchangeRateModify' />";	//환율정보관리
					var popupYN		= "N";
					var callBack	= "exchangeRatePopup_CallBack";
					var popupUrl	= "/account/exchangeRate/getExchangeRatePopup.do?"
									+ "popupID="		+ popupID				+ "&"
									+ "openerID="		+ openerID				+ "&"
									+ "popupYN="		+ popupYN				+ "&"
									+ "callBackFunc="	+ callBack				+ "&"
									+ "exchangeRateDate="	+ exchangeRateDate	+ "&" 
									+ "mode="			+ mode;

					Common.open("", popupID, popupTit, popupUrl, "350px", "580px", "iframe", true, null, null, true);
				},
				/* onCodeClick : function(inputExchangeRateID){
					var mode		= "modify"
					var popupID		= "ExchangeRatePopup";
					var openerID	= "ExchangeRate";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_exchangeRateModify' />";	//환율정보관리
					var popupYN		= "N";
					var callBack	= "exchangeRatePopup_CallBack";
					var popupUrl	= "/account/exchangeRate/getExchangeRatePopup.do?"
									+ "popupID="		+ popupID				+ "&"
									+ "openerID="		+ openerID				+ "&"
									+ "popupYN="		+ popupYN				+ "&"
									+ "callBackFunc="	+ callBack				+ "&"
									+ "exchangeRateID="	+ inputExchangeRateID	+ "&" 
									+ "mode="			+ mode;

					Common.open("", popupID, popupTit, popupUrl, "350px", "580px", "iframe", true, null, null, true);
				}, */
				
				exchangeRatePopup_CallBack : function(){
					var me = this;
					me.searchList();
				},
				
				exchangeRateSync : function(){
					$.ajax({
						url	: "/account/exchangeRate/exchangeRateSync.do",
						type: "POST",
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_syncComp' />");	//동기화
								ExchangeRate.searchList('N');
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.	
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					});
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.ExchangeRate = ExchangeRate;
	})(window);
</script>