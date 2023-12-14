<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
.btnUserRemove {background:#364d5d url('/HtmlSite/smarts4j_n/covicore/resources/images/common/bul_photo_remove.png') no-repeat center center;}
.pad10 { padding:10px;}
</style>



	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<!-- 개인카드 -->
		<h2 class="title"><spring:message code="Cache.ACC_lbl_privateCard"/></h2>
	</div>
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<!-- 상단 버튼 시작 -->
			<div class="eaccountingTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					<a class="btnTypeDefault" 				onclick="PrivateCardView.searchPrivateCardViewList();"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<a class="btnTypeDefault btnExcel" 		onclick="PrivateCardView.saveExcel();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					
				</div>
				<div class="buttonStyleBoxRight ">	
					<span class="selectType02 listCount" id="listCount" onchange="PrivateCardView.searchPrivateCardViewList();">
					</span>
					<button class="btnRefresh" type="button" onclick="PrivateCardView.searchPrivateCardViewList();"></button>
				</div>
	
			</div>
			<!-- 상단 버튼 끝 -->
			<!-- ===================== -->
			
			<div class="bodysearch_Type01">
				<div class="inPerView type06">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<!-- 회사 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_company"/></span>
							<span id="priCardView_inputCompanyCode" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 소유자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_cardOwner"/></span>
							
							<input id="priCardView_inputCardOwner" type="hidden">
							<input id="priCardView_inputCardOwnerName" type="text">
							<button class="btnSearchType01" type="button" onclick="PrivateCardView.callUserPopup();"></button>
							<button class="btnUserRemove" type="button" onclick="PrivateCardView.deleteUserSearchData();" ></button>
						</div>
						<a class="btnTypeDefault btnSearchBlue" onclick="PrivateCardView.searchPrivateCardViewList();"  style="position:absolute;left:530px;" ><spring:message code="Cache.ACC_btn_search"/></a><!-- 버튼위치를 인라인으로 조정 -->
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<!-- 카드번호 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_cardNumber"/></span>
							<input id="priCardView_inputCardNo" type="text">		
						</div>
						<div class="inPerTitbox">
							<!-- 사용여부 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_isUse"/></span>
							<select class="selectType02 listCount" id="priCardView_inputIsUse">
								<!-- 전체 -->
								<option value=""><spring:message code="Cache.ACC_lbl_comboAll"/></option>
								<!-- 사용 -->
								<option value="Y"><spring:message code="Cache.ACC_lbl_isUse_Y"/></option>
								<!-- 사용안함 -->
								<option value="N"><spring:message code="Cache.ACC_lbl_noUse"/></option>
							</select>			
						</div>
					</div>
				</div>
			</div>
			
		<div id="gridArea" class="pad10">
		</div>
			
		<!-- 컨텐츠 끝 -->
	</div>

<script>

	if (!window.PrivateCardView) {
		window.PrivateCardView = {};
	}
	
	(function(window) {
		var PrivateCardView = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},

				pageInit : function() {
					var me = this;
					me.setSelectCombo();
					me.setHeaderData();
					me.searchPrivateCardViewList('Y');
				},

				pageView : function() {
					var me = this;
					
					me.setHeaderData();
					me.refreshCombo();
					
					me.searchPrivateCardViewList();
				},

				setSelectCombo : function(){
					var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',	'target':'listCount',						'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'CompanyCode',		'target':'priCardView_inputCompanyCode',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						]
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},

				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("priCardView_inputCompanyCode");
					accountCtrl.refreshAXSelect("priCardView_inputIsUse");
				},

				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{ key:'CardNo',				label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",		width:'70', align:'center', //카드번호
								        				formatter:function () {
										            		 return "<a onclick='PrivateCardView.onItemClick(" + this.item.CardApplicationID + "); return false;'><font color='blue'><u>"+this.item.CardNo+"</u></font></a>";
										            	}},
								       			{ key:'CardCompanyName',	label:"<spring:message code='Cache.ACC_lbl_cardCompany' />",		width:'70', align:'center'}, //카드회사
								       			{ key:'RegisterName',		label:"<spring:message code='Cache.ACC_lbl_cardOwner' />",			width:'70', align:'center'}, //소유자
								       			{ key:'RegistDate',			label:"<spring:message code='Cache.ACC_lbl_RequestDate' />" +Common.getSession("UR_TimeZoneDisplay"),		width:'70', align:'center',
								       				formatter:function(){
								       					return CFN_TransLocalTime(this.item.RegistDate,_ServerDateSimpleFormat);
								       				}, dataType:'DateTime'
								       			}, //요청일자
								       			{ key:'IsUseView',			label:"<spring:message code='Cache.ACC_lbl_isUse' />",			width:'70', align:'center'}	 //사용여부
											]
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},

				searchPrivateCardViewList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var searchCompanyCode	= accountCtrl.getComboInfo("priCardView_inputCompanyCode").val();
					var searchCardOwner		= accountCtrl.getInfo("priCardView_inputCardOwner").val();
					var searchCardNo		= accountCtrl.getInfo("priCardView_inputCardNo").val();
					var searchIsUse			= accountCtrl.getComboInfo("priCardView_inputIsUse").val();
					var pageSizeInfo		= accountCtrl.getComboInfo("listCount").val();
						
					
					var searchType	= accountCtrl.getComboInfo("searchType").val();
					var searchStr	= accountCtrl.getInfo("searchStr").val();
					var companyCode	= accountCtrl.getComboInfo("companyCode").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/baseInfo/searchPrivateCardViewList.do";
					var ajaxPars		= {	"searchCompanyCode"	: searchCompanyCode,
											"searchCardOwner"	: searchCardOwner,
											"searchCardNo"		: searchCardNo,
											"searchIsUse"		: searchIsUse,
											"pageSize"			: pageSizeInfo
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
				
				onItemClick : function(inputCardApplicationID){
					var isNew		= 'N'
					var popupID		= "PrivateCardViewPopup";
					var openerID	= "PrivateCardView";
					var popupTit	= "<spring:message code='Cache.ACC_014'/>";	//개인카드 정보 수정
					var popupYN		= "N";
					var callBack	= "PrivateCardView_CallBack";
					var popupUrl	= "/account/baseInfo/callPrivateCardViewPopup.do?"
									+ "popupID="			+ popupID	+ "&"
									+ "openerID="			+ openerID	+ "&"
									+ "popupYN="			+ popupYN	+ "&"
									+ "callBackFunc="		+ callBack	+ "&"
									+ "isNew="				+ isNew	+ "&"
									+ "CardApplicationID="	+ inputCardApplicationID;
					Common.open("", popupID, popupTit, popupUrl, "416px", "450px", "iframe", true, null, null, true);
				},

				PrivateCardView_CallBack : function(){
					var me = this;
					me.searchPrivateCardViewList();
				},
				
				callUserPopup : function(){
					var popupID		= "orgmap_pop";
					var openerID	= "PrivateCardView";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_orgChart' />";	//조직도
					var callBackFn	= "userSelect";
					var type		= "B1";
					var popupUrl	= "/covicore/control/goOrgChart.do?"
									+ "popupID="		+ popupID		+ "&"
									+ "callBackFunc="	+ callBackFn	+ "&"
									+ "type="			+ type;
					
					window[callBackFn] = window[openerID][callBackFn];
					Common.open("", popupID, popupTit, popupUrl, "1000px","580px","iframe",true,null,null,true);
				},
				
				userSelect : function(orgData){
					var items = JSON.parse(orgData).item;
					var usrNm = items[0].DN.split(';');
					var usrCD = items[0].UserCode

					accountCtrl.getInfo("priCardView_inputCardOwner").val(usrCD);
					accountCtrl.getInfo("priCardView_inputCardOwnerName").val(usrNm[0]);
				},
				
				deleteUserSearchData : function(){

					accountCtrl.getInfo("priCardView_inputCardOwner").val("");
					accountCtrl.getInfo("priCardView_inputCardOwnerName").val("");
				},

				saveExcel : function(){
					var me = this;
					var headerName = me.getHeaderNameForExcel();
					location.href = "/account/baseInfo/excelDownloadPriCard.do?headerName="+headerName;

				},

				getHeaderNameForExcel : function(){
					var me = this;
					var returnStr = "";
					var gridHeaderData = me.params.headerData;
				   	for(var i=0;i<gridHeaderData.length; i++){
				   	   	if(gridHeaderData[i].display != false && gridHeaderData[i].label != 'chk'){
				   	   		if(gridHeaderData[i].key == 'IsFavorite')
				   	   			returnStr += "<spring:message code='Cache.ACC_lbl_favorite' />" + ";";	//즐겨찾기
			   	   			else
								returnStr += gridHeaderData[i].label + ";";
				   	   	}
					}
					
					return returnStr;
				}
		}
		window.PrivateCardView = PrivateCardView;
	})(window);
	
</script>