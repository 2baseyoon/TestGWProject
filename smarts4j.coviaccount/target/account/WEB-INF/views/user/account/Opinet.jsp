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
					<!-- 새로고침 -->
					<a class="btnTypeDefault" onclick="Opinet.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 동기화 -->
					<a class="btnTypeDefault" onclick="Opinet.opinetSync();" id="btnSync"><spring:message code="Cache.ACC_btn_sync"/></a>
				</div>
				<!-- 상단 버튼 끝 -->
			</div>
			
			<!-- 검색 내용 -->
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit"> 
								<spring:message code="Cache.ACC_lbl_division"/>	<!-- 구분 -->
							</span>
							<select id="prodcd" class="selectType02">
								<!-- prodcd - B034: 고급휘발유, B027: 보통휘발유, D047: 자동차경유, C004: 실내등유, K015: 자동차부탄 -->
								<option value="">전체</option>
								<option value="B034">고급휘발유</option>
								<option value="B027">보통휘발유</option>
								<option value="D047">자동차경유</option>
								<option value="C004">실내등유</option>
								<option value="K015">자동차부탄</option>
							</select>
							<!-- <span id="prodcd" class="selectType02" tag="prodcd">
							</span> -->
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_date"/>	<!-- 조회일자 -->
							</span>
							<div id="ddArea" class="dateSel type02">
							</div>
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="Opinet.searchList();"><spring:message code="Cache.ACC_btn_search"/></a>
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
		window.Opinet = {};
	}
	
	(function(window) {
		var Opinet = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
			
				pageInit : function() {
					var me = this;
					//setPropertySyncType('ExchangeRate','syncProperty');
					setHeaderTitle('headerTitle');
					//me.setPageViewController();
					me.pageDatepicker();
					me.setSelectCombo();
					// me.setHeaderData();
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
							{'codeGroup':'listCountNum',		'target':'listCount',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''},
							{
								'codeGroup': 'prodcd',
								'target':'prodcd',
								'lang':'ko',
								'onchange':'',
								'oncomplete':'',
								'defaultVal':'',
								'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll'/>"
							}
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
							key: "SEQ",
							display: false
						},
						{
							key: "PRODCD",
							display: false
						},
						{
							key: "PRODNM",
							label: "<spring:message code='Cache.ACC_lbl_division'/>",
							width: "70",
							align: "center",
							formatter: function() {
								// prodcd - B034: 고급휘발유, B027: 보통휘발유, D047: 자동차경유, C004: 실내등유, K015: 자동차부탄
								var prodcd = {
									"B034": "고급휘발유",
									"B027": "보통휘발유",
									"D047": "자동차경유",
									"C004": "실내등유",
									"K015": "자동차부탄"
								}
							
								return prodcd[this.item.PRODCD];
							}
						},
						{
							key: "YYYYMMDD",
							label: "<spring:message code='Cache.ACC_lbl_date'/>",
							width: "70",
							align: "center",
							formatter:function(){
			            		return CFN_TransLocalTime(this.item.YYYYMMDD, _ServerDateSimpleFormat);
			            	},
			            	dataType:'DateTime'
						},
						{
							key: "PRICE",
							label: "<spring:message code='Cache.ACC_lbl_amt'/>",
							width: "70",
							align: "center"
						}
					]
					
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
					/* if(	accountCtrl.getInfo('endDD').val() == ""	||
						accountCtrl.getInfo('endDD').val() == null){
						exchangeRateDateFinish = today.toISOString().slice(0,10).replace(/-/g,"");
					} */
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/opinet/getList.do";
					var ajaxPars		= {	"startDD"		: exchangeRateDateStart,
							 				"endDD"	: exchangeRateDateFinish,
							 				// "prodcd": accountCtrl.getComboInfo('prodcd').val()
							 				"prodcd": accountCtrl.getInfo('prodcd').val()
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
				
				exchangeRateDel : function(){
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
				},
				
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
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "headerKey="	+ encodeURI(headerKey)		+ "&"
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
				
				onCodeClick : function(inputExchangeRateID){
					
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
				},
				
				exchangeRatePopup_CallBack : function(){
					var me = this;
					me.searchList();
				},
				
				opinetSync : function(){
					$.ajax({
						url	: "/account/opinet/getSync.do",
						type: "POST",
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_syncComp' />");	//동기화
								Opinet.searchList('N');
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
		window.Opinet = Opinet;
	})(window);
</script>