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
					<a class="btnTypeDefault  btnTypeBg " 	onclick="CardApplicationUser.callAddPopup();"><spring:message code="Cache.ACC_btn_add"/></a> <!-- 추가 -->
					<a class="btnTypeDefault" 				onclick="CardApplicationUser.deleteList();"><spring:message code="Cache.ACC_btn_delete"/></a> <!-- 삭제 -->
					<a class="btnTypeDefault"				onclick="CardApplicationUser.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a> <!-- 새로고침 -->
					<a class="btnTypeDefault btnExcel" 		onclick="CardApplicationUser.saveExcel();"><spring:message code="Cache.ACC_btn_excelDownload"/></a> <!-- 엑셀 다운로드 -->
				</div>
			</div>
			<!-- 상단 버튼 끝 -->
			<!-- ===================== -->
			
			<div class="bodysearch_Type01">
				<div class="inPerView type07">
					<div style="width:900px;"><!-- 항목 넓이를 인라인으로 조정 -->
						<div class="inPerTitbox">
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_companyCode"/></span>	<!-- 회사코드 -->
							<span id="CompanyCode" class="selectType02" onchange="CardApplicationUser.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">		<!-- 신청제목 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_applicationTitle"/></span>
							<input id="cardApp_inputApplicationTitle" type="text"
								onkeydown="CardApplicationUser.onenter()">							
						</div>
						<div class="inPerTitbox">		<!-- 카드번호 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_cardNumber"/></span>
							<input id="cardApp_inputCardNo" type="text"
								onkeydown="CardApplicationUser.onkey(this)">		
												
						</div>
						<a class="btnTypeDefault btnSearchBlue" onclick="CardApplicationUser.searchCardApplicationUserList();" ><spring:message code="Cache.ACC_btn_search"/></a><!-- 버튼위치를 인라인으로 조정 -->
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight ">	
					<span class="selectType02 listCount" id="listCount" onchange="CardApplicationUser.searchCardApplicationUserList();">
					</span>
					<button class="btnRefresh" type="button" onclick="CardApplicationUser.searchCardApplicationUserList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		<!-- 컨텐츠 끝 -->
		</div>
	</div>

<script>
//카드신청 유저용
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
					setHeaderTitle('headerTitle');
					me.setSelectCombo();
					me.setHeaderData();
					me.searchCardApplicationUserList('Y');
				},

				pageView : function() {
					var me = this;
					
					me.setHeaderData();
					me.refreshCombo();
					
					me.searchCardApplicationUserList();
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("CompanyCode").val());
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

				setHeaderData : function() {
					var me = this;
					me.params.headerData = [
						          			{ key:'chk',					label:'chk', 														width:'20', align:'center', formatter:'checkbox'},
											{ key:'CompanyName',			label : "<spring:message code='Cache.ACC_lbl_company' />",			width:'70',	align:'center'},		//회사
						        			{ key:'ApplicationTypeName',	label:"<spring:message code='Cache.ACC_lbl_vendorRequestType' />",	width:'70', align:'center'},	//신청유형
						        			{ key:'ApplicationStatusName',	label:"<spring:message code='Cache.ACC_lbl_requestStatus' />",		width:'70', align:'center'},	//신청상태
						        			{ key:'ApplicationTitle',		label:"<spring:message code='Cache.ACC_lbl_applicationTitle' />",	width:'70', align:'center',		//신청제목
						        				formatter:function () {
						        					var str = "<a onclick=\"CardApplicationUser.onItemClick('" 
				        								+ this.item.CardApplicationID 
				        								+ "', '"
				        								+ this.item.ApplicationStatus
				        								+"')\"><font color='blue'><u>"
			        								+this.item.ApplicationTitle
			        								+"</u></font></a>";
								            		 return str
								            	}
						        			},
						        			{ key:'CardNo',					label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",				width:'70', align:'center'},	//카드번호
						        			{ key:'CardCompanyName',		label:"<spring:message code='Cache.ACC_lbl_cardCompany' />",				width:'70', align:'center'},	//카드회사
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
				searchCardApplicationUserList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var pageSizeInfo			= accountCtrl.getComboInfo("listCount").val();
					var companyCode				= accountCtrl.getComboInfo("CompanyCode").val();
					var searchApplicationTitle	= accountCtrl.getInfo("cardApp_inputApplicationTitle").val()
					var searchCardNo			= accountCtrl.getInfo("cardApp_inputCardNo").val();
						
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/baseInfo/searchCardApplicationUserList.do";
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
				
				//체크된 삭제 목록
				deleteList : function(){
					var me = this;
					var grid = me.params.gridPanel;
					var deleteobj = grid.getCheckedList(0);

					if(deleteobj.length==0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");	//선택된 항목이 없습니다.
						return;
					}
					
					var cardAppList = "";
					var stCk = false;
					for(var i = 0; i < deleteobj.length; i++)	 {
						var item = deleteobj[i];
						
						cardAppList += item.CardApplicationID;
						if(i != deleteobj.length - 1){
							cardAppList += ",";
						}
						if(item.ApplicationStatus != "T"){
							stCk = true;
						}
					}

					if(stCk){
						Common.Inform("<spring:message code='Cache.ACC_013'/>"); //임시저장상태인 항목만 삭제가 가능합니다.
						return;
					}
			        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){ //삭제하시겠습니까?
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
								Common.Inform("<spring:message code='Cache.ACC_msg_delComp'/>");	// 삭제를 완료하였습니다.
								CardApplicationUser.searchCardApplicationUserList();
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				//추가팝업 호출
				callAddPopup : function(){
					var isNew		= "Y";
					var popupID		= "CardApplicationPopup";
					var openerID	= "CardApplicationUser";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_cardApplication'/>";	//카드신청
					var popupYN		= "N";
					var changeSize	= "ChangePopupSize";
					var callBack	= "CardApplicationUserPopup_CallBack";
					var popupUrl	= "/account/baseInfo/callCardApplicationPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "changeSizeFunc="		+ changeSize				+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "isNew="			+ isNew;
					Common.open(	"",popupID,popupTit,popupUrl,"800px","600px","iframe",true,null,null,true);
				},

				//상세조회 호출
				onItemClick : function(inputCardApplicationID, ApplicationStatus){
					var isNew		= "N";
					var popupID		= "CardApplicationPopup";
					var openerID	= "CardApplicationUser";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_cardApplication'/>";	//카드신청
					var popupYN		= "N";
					var applicationStatus		= ApplicationStatus;
					var changeSize	= "ChangePopupSize";
					var callBack	= "CardApplicationUserPopup_CallBack";
					var popupUrl	= "/account/baseInfo/callCardApplicationPopup.do?"
									+ "popupID="			+ popupID					+ "&"
									+ "openerID="			+ openerID					+ "&"
									+ "popupYN="			+ popupYN					+ "&"
									+ "changeSizeFunc="		+ changeSize				+ "&"
									+ "callBackFunc="		+ callBack					+ "&"
									+ "CardApplicationID="	+ inputCardApplicationID	+ "&"
									+ "applicationStatus="	+ applicationStatus	+ "&"
									+ "isNew="				+ isNew;
					Common.open(	"",popupID,popupTit,popupUrl,"800px","600px","iframe",true,null,null,true);
				},
				
				CardApplicationUserPopup_CallBack : function(){
					CardApplicationUser.searchCardApplicationUserList()
				},

				//팝업 사이즈 변경
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
					var searchApplicationTitle	= accountCtrl.getInfo("cardApp_inputApplicationTitle").val();
					var searchCardNo			= accountCtrl.getInfo("cardApp_inputCardNo").val();
					var title 			= accountCtrl.getInfo("headerTitle").text();
					
					location.href = "/account/baseInfo/excelDownloadCardApplicationUserList.do?"
							//+ "headerName="	+ encodeURI(headerName)
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
				
				onkey : function(obj){
					var me = this;
					if(event.keyCode=="13"){
						me.searchCardApplicationUserList();
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
						me.searchCardApplicationUserList();
					}
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
				
				
		}
		window.CardApplicationUser = CardApplicationUser;
	})(window);
</script>