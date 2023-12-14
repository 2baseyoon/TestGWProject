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
			<!-- 상단 버튼 시작 -->
			<div class="eaccountingTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
				<!-- 
					<a class="btnTypeDefault  btnTypeBg " 	onclick="CardApplication.callAddPopup();"><spring:message code="Cache.ACC_btn_add"/></a>
					<a class="btnTypeDefault" 				onclick="CardApplication.deleteList();"><spring:message code="Cache.ACC_btn_delete"/></a>
					 -->
					<a class="btnTypeDefault btnTypeBg" href="#" onclick="CardApplication.cardApp_cardAprvStat('E');"><spring:message code="Cache.ACC_btn_accept"/></a>	<!-- 승인 -->
					<a class="btnTypeDefault" href="#" onclick="CardApplication.cardApp_cardAprvStat('R');"><spring:message code="Cache.ACC_btn_reject"/></a>	<!-- 반려 -->
					<a class="btnTypeDefault"				onclick="CardApplication.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a> <!-- 새로고침 -->
					<a class="btnTypeDefault btnExcel" 		onclick="CardApplication.saveExcel();"><spring:message code="Cache.ACC_btn_excelDownload"/></a> <!-- 엑셀 다운로드 -->
				</div>				
			</div>
			<!-- 상단 버튼 끝 -->
			<!-- ===================== -->
			
			<div class="bodysearch_Type01">
				<div class="inPerView type07">
					<div style="width:900px;"><!-- 항목 넓이를 인라인으로 조정 -->
						<div class="inPerTitbox">
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_companyCode"/></span>	<!-- 회사코드 -->
							<span id="CompanyCode" class="selectType02" onchange="CardApplication.searchCardApplicationList()">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_applicationTitle"/></span>	<!-- 신청제목 -->
							<input id="cardApp_inputApplicationTitle" type="text"
								onkeydown="CardApplication.onenter()">							
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_cardNumber"/></span>	<!-- 카드번호 -->
							<input id="cardApp_inputCardNo" type="text"
								onkeydown="CardApplication.onenter()">		
												
						</div>
						<a class="btnTypeDefault btnSearchBlue" onclick="CardApplication.searchCardApplicationList();" ><spring:message code="Cache.ACC_btn_search"/></a><!-- 버튼위치를 인라인으로 조정 -->
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight ">	
					<span class="selectType02 listCount" id="listCount" onchange="CardApplication.searchCardApplicationList()">
					</span>
					<button class="btnRefresh" type="button" onclick="CardApplication.searchCardApplicationList()"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
			<!-- 컨텐츠 끝 -->
		</div>
	</div>

<script>
	if (!window.CardApplication) {
		window.CardApplication = {};
	}
	
	(function(window) {
		var CardApplication = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},

				pageInit : function() {
					var me = this;
					setHeaderTitle('headerTitle');
					me.setSelectCombo();
					me.setHeaderData();
					me.searchCardApplicationList('Y');
				},

				pageView : function() {
					var me = this;
					
					me.setHeaderData();
					me.refreshCombo();
					
					me.searchCardApplicationList();
				},

				setSelectCombo : function(){
					// 로딩속도 개선
					var __AXSelectMultiArr = [
						{
							"codeGroup":"listCountNum"
							,"target":"listCount"
							,"lang":"ko"
							,"onchange":""
							,"oncomplete":""
							,"defaultVal":""
							,"useDefault":null
						},
						{
							"codeGroup":"CompanyCode"
							,"target":"CompanyCode"
							,"lang":"ko"
							,"onchange":""
							,"oncomplete":""
							,"defaultVal":""
							,"useDefault":null
						}
					];
					accountCtrl.renderAXSelectMulti(__AXSelectMultiArr, '');
				},

				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
				},

				//그리드 헤더 세팅
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [
						          			{ key:'chk',					label:'chk', 														width:'20', align:'center', formatter:'checkbox'},
											{ key:'CompanyName',			label : "<spring:message code='Cache.ACC_lbl_company' />",			width:'70',	align:'center'},	//회사
						        			{ key:'ApplicationTypeName',	label:"<spring:message code='Cache.ACC_lbl_vendorRequestType' />",	width:'70', align:'center'},	//신청유형
						        			{ key:'ApplicationStatusName',	label:"<spring:message code='Cache.ACC_lbl_requestStatus' />",		width:'70', align:'center'},	//신청상태
						        			{ key:'ApplicationTitle',		label:"<spring:message code='Cache.ACC_lbl_applicationTitle' />",	width:'70', align:'center',		//신청제목
						        				formatter:function () {
						        					var str = "<a onclick=\"CardApplication.onItemClick('" 
				        								+ this.item.CardApplicationID 
				        								+ "', '"
				        								+ this.item.ApplicationStatus
				        								+"')\"><font color='blue'><u>"
			        								+this.item.ApplicationTitle
			        								+"</u></font></a>";
								            		 return str
								            	}
						        			},
						        			{ key:'CardNo',					label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",			width:'70', align:'center'},	//카드번호
						        			{ key:'CardCompanyName',		label:"<spring:message code='Cache.ACC_lbl_cardCompany' />",		width:'70', align:'center'},	//카드회사
						        			{ key:'RegistDate',				label:"<spring:message code='Cache.ACC_lbl_applicationDay' />" +Common.getSession("UR_TimeZoneDisplay"),		width:'70', align:'center',
						        				formatter:function(){
						        					return CFN_TransLocalTime(this.item.RegistDate,_ServerDateSimpleFormat);
						        				}, dataType:'DateTime'	
						        			}]	//신청일
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},

				//목록 조회
				searchCardApplicationList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var pageSizeInfo			= accountCtrl.getComboInfo("listCount").val();
					var companyCode				= accountCtrl.getComboInfo("CompanyCode").val();
					var searchApplicationTitle	= accountCtrl.getInfo("cardApp_inputApplicationTitle").val();
					var searchCardNo			= accountCtrl.getInfo("cardApp_inputCardNo").val();
						
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/baseInfo/searchCardApplicationList.do";
					var ajaxPars		= {	"searchApplicationTitle"	: searchApplicationTitle,
											"searchCardNo"				: searchCardNo,
											"companyCode"				: companyCode,
											"pageSize"					: pageSizeInfo
					};
					
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
				//체크된 데이터 삭제
				deleteList : function(){
					var me = this;
					var grid = me.params.gridPanel;
					var deleteobj = grid.getCheckedList(0);

					var cardAppList = "";
					for(var i = 0; i < deleteobj.length; i++)	 {
						var item = deleteobj[i];
						
						cardAppList += item.CardApplicationID;
						if(i != deleteobj.length - 1){
							cardAppList += ",";
						}
					}

			        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//삭제하시겠습니까?
			       		if(result){
			       			me.callDeleteVendorList(cardAppList)
			       		}
			        });
					

				},
				//삭제로직 호출
				callDeleteVendorList : function(cardAppList){
					$.ajax({
						type:"POST",
							url:"/account/baseInfo/deleteCardApplicationList.do",
						data:{
							"cardAppList" : cardAppList,
						},
						success:function (data) {
							if(data.result == "ok")
							{
								Common.Inform("<spring:message code='Cache.ACC_msg_delComp'/>");	//삭제를 완료하였습니다
								CardApplication.searchCardApplicationList();
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				//신규추가팝업 호출
				callAddPopup : function(){
					var isNew		= "Y";
					var popupID		= "CardApplicationPopup";
					var openerID	= "CardApplication";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_cardApplication'/>";		//카드신청
					var popupYN		= "N";
					var changeSize	= "ChangePopupSize";
					var callBack	= "CardApplicationPopup_CallBack";
					var popupUrl	= "/account/baseInfo/callCardApplicationPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "changeSizeFunc="	+ changeSize+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "isNew="			+ isNew;
					Common.open(	"",popupID,popupTit,popupUrl,"800px","560px","iframe",true,null,null,true);
				},
				
				//상세조회팝업 호출
				onItemClick : function(inputCardApplicationID, ApplicationStatus){
					var isNew		= "N";
					var popupID		= "CardApplicationPopup";
					var openerID	= "CardApplication";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_cardApplication'/>";
					var popupYN		= "N";
					var applicationStatus		= ApplicationStatus;
					var callBack	= "CardApplicationPopup_CallBack";
					var changeSize	= "ChangePopupSize";
					var popupUrl	= "/account/baseInfo/callCardApplicationPopup.do?"
									+ "popupID="			+ popupID					+ "&"
									+ "openerID="			+ openerID					+ "&"
									+ "popupYN="			+ popupYN					+ "&"
									+ "changeSizeFunc="		+ changeSize				+ "&"
									+ "callBackFunc="		+ callBack					+ "&"
									+ "CardApplicationID="	+ inputCardApplicationID	+ "&"
									+ "applicationStatus="	+ applicationStatus	+ "&"
									+ "isAdminMenu=Y&"
									+ "isNew="				+ isNew;
					Common.open(	"",popupID,popupTit,popupUrl,"800px","600px","iframe",true,null,null,true);
				},
				
				//추가 후 재조회
				CardApplicationPopup_CallBack : function(){
					CardApplication.searchCardApplicationList()
				},
				
				//팝업크기 변경
				ChangePopupSize : function(popupID,popupW,popupH){
					accountCtrl.pChangePopupSize(popupID,popupW,popupH);
				},
				
				//엑셀 다운로드
				saveExcel : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
							var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerData);
							var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerData);
							var headerType		= accountCommon.getHeaderTypeForExcel(me.params.headerData);
							
							var companyCode				= accountCtrl.getComboInfo("CompanyCode").val();
							var searchApplicationTitle	= accountCtrl.getInfo("cardApp_inputApplicationTitle").val()
							var searchCardNo			= accountCtrl.getInfo("cardApp_inputCardNo").val();
							var title 			= accountCtrl.getInfo("headerTitle").text();
							
							location.href = "/account/baseInfo/excelDownloadCardApplicationList.do?"
									//+ "headerName="	+encodeURI(headerName)
									+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
									+ "&headerKey="	+ encodeURI(headerKey)
									+ "&headerType="	+ encodeURI(headerType)
									+ "&searchApplicationTitle="+encodeURI(searchApplicationTitle)
									+ "&searchCardNo="+encodeURI(searchCardNo)
									+ "&companyCode="+encodeURI(companyCode)
									//+ "&title="+encodeURI(accountCtrl.getInfo("headerTitle").text());
									+ "&title="			+ encodeURIComponent(encodeURIComponent(title));
			       		}
					});
				},

				//엑셀 다운로드용 그리드 헤더 
				getHeaderNameForExcel : function(){
					var me = this;
					var returnStr = "";
					var gridHeaderData = me.params.headerData;  
				   	for(var i=0;i<gridHeaderData.length; i++){
				   	   	if(gridHeaderData[i].display != false && gridHeaderData[i].label != 'chk'){
				   	   		if(gridHeaderData[i].key == 'IsFavorite')
				   	   			returnStr += "<spring:message code='Cache.ACC_lbl_favorite' />" + ";";
			   	   			else
								returnStr += gridHeaderData[i].label + ";";
				   	   	}
					}
					return returnStr;
				},
				
				//결재상태 변경
				cardApp_cardAprvStat : function(stat){
					var me = this;

					var aprvobj	= me.params.gridPanel.getCheckedList(0);
					
					if(aprvobj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata'/>");	//선택된 항목이 없습니다.
						return;
					}

					var appCk = false;
					var statCk = false;
					for(var i = 0; i < aprvobj.length; i++){
						var item = aprvobj[i];
						if(item.ApplicationStatus != "D"
								&&item.ApplicationStatus != "S"){
							statCk = true
						}
					}
					
					var msg = ""

					if(statCk){

						msg = "<spring:message code='Cache.ACC_025' />";		// 결재 진행중이 아닌 항목이 선택되었습니다.
						Common.Inform(msg);
						return;
					}
					
					if(stat=="E"){
						msg = "<spring:message code='Cache.ACC_msg_ckAccept' />";		// 승인하시겠습니가?
					}else if(stat=="R"){
						msg = "<spring:message code='Cache.ACC_msg_ckReject' />";		// 반려하시겠습니까?
					}
					if(appCk){

						msg = "<spring:message code='Cache.ACC_024' />" +"<br>"+  msg;	// 하나의 전표에 여러 증빙이 있는 항목이 있습니다. 승인/반려시 전표의 모든 증빙이 같이 처리됩니다.
					}
					
			        Common.Confirm(msg, "Confirmation Dialog", function(result){
			       		if(result){

							var aprvObj = {
									setStatus : stat
							};
							aprvObj.aprvList = 	aprvobj
			       			me.cardApp_callCardAprvStatChange(aprvObj)
			       		}
			        });
				},

				//결재상태 변경 호출
				cardApp_callCardAprvStatChange : function(aprvObj){
					var me = this;
					
					if(aprvObj == null ){
						return;
					}
					if(aprvObj.aprvList == null ){
						return;
					}
					
					$.ajax({
						type:"POST",
							url:"/account/baseInfo/cardAprvStatChange.do",
						data:{
							"aprvObj"	: JSON.stringify(aprvObj),
						},
						success:function (data) {
							if(data.result == "ok"){
								Common.Inform("<spring:message code='Cache.ACC_msg_processComplet'/>");		//처리를 완료하였습니다.
								me.searchCardApplicationList();
							}
							else if(data.result == "st"){
								Common.Inform("<spring:message code='Cache.ACC_025'/>");		// 결재 진행중이 아닌 항목이 선택되었습니다.
								me.searchVendorRequestList();
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				onenter : function(){
					var me = this;
					if(event.keyCode=="13"){
						me.searchCardApplicationList();
					}
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
				
				
		}
		window.CardApplication = CardApplication;
	})(window);
</script>