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
					<a class="btnTypeDefault  btnTypeBg " 	onclick="VendorRequestUser.callAddPopup();"><spring:message code="Cache.ACC_btn_add"/></a>
					<a class="btnTypeDefault" 				onclick="VendorRequestUser.deleteList();"><spring:message code="Cache.ACC_btn_delete"/></a>		
					<a class="btnTypeDefault"				onclick="VendorRequestUser.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>			
					<a class="btnTypeDefault btnExcel" 		onclick="VendorRequestUser.saveExcel();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
				</div>
			</div>
			<!-- 상단 버튼 끝 -->
			<!-- ===================== -->
			
			<div class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;"><!-- 항목 넓이를 인라인으로 조정 -->
						<div class="inPerTitbox">
							<!-- 회사코드 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_companyCode"/></span>	
							<span class="selectType02" id="vendorRequestUser_CompanyCode" onchange="VendorRequestUser.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 신청유형 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorRequestType"/></span>
							<span class="selectType02 " id="vendorRequestUser_inputApplicationType" >
							</span>	
						</div>
						<div class="inPerTitbox">
							<!-- 신청상태 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_requestStatus"/></span>
							<span class="selectType02 " id="vendorRequestUser_inputApplicationStatus" >
							</span>					
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<!-- 신규/변경 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_new"/>/<spring:message code="Cache.ACC_lbl_change"/></span>
							<span class="selectType02 " id="vendorRequestUser_inputIsNew" >
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 거래처명 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorName"/></span>
							<input id="vendorRequestUser_inputVendorName" type="text"
								onkeydown="VendorRequestUser.onenter()">							
						</div>
						<div class="inPerTitbox">
							<!-- 등록번호 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorRegistNumber"/></span>
							<input id="vendorRequestUser_inputVendorNo" type="text"
								onkeydown="VendorRequestUser.onenter()">
						</div>
						<a class="btnTypeDefault btnSearchBlue " onclick="VendorRequestUser.searchVendorRequestUserList();"><spring:message code="Cache.ACC_btn_search"/></a><!-- 버튼위치를 인라인으로 조정 -->
					</div>							
				</div>
			</div>
			<!-- ===================== -->
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight ">	
					<span class="selectType02 listCount" id="listCount" onchange="VendorRequestUser.searchVendorRequestUserList();">
					</span>
					<button class="btnRefresh" type="button" onclick="VendorRequestUser.searchVendorRequestUserList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
			
		</div>
		<!-- 컨텐츠 끝 -->
	</div>

<script>
		
	if (!window.VendorRequestUser) {
		window.VendorRequestUser = {};
	}
	
	(function(window) {
		var VendorRequestUser = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},

				pageInit : function() {
					var me = this;
					setHeaderTitle('headerTitle');
					me.setSelectCombo();
					me.setHeaderData();
					me.searchVendorRequestUserList('Y');
				},

				pageView : function() {
					var me = this;
					
					me.setHeaderData();
					me.refreshCombo();
					
					me.searchVendorRequestUserList();
				},

				setSelectCombo : function(pCompanyCode){
					accountCtrl.getInfo("listCount").children().remove();
					accountCtrl.getInfo("vendorRequestUser_inputApplicationType").children().remove();
					accountCtrl.getInfo("vendorRequestUser_inputApplicationStatus").children().remove();
					accountCtrl.getInfo("vendorRequestUser_inputIsNew").children().remove();

					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "VendorRequestUser.searchVendorRequestUserList();");
					accountCtrl.getInfo("vendorRequestUser_inputApplicationType").addClass("selectType02");
					accountCtrl.getInfo("vendorRequestUser_inputApplicationStatus").addClass("selectType02");
					accountCtrl.getInfo("vendorRequestUser_inputIsNew").addClass("selectType02");
					
					var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',			'target':'listCount',									'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'VendorApplicationType',	'target':'vendorRequestUser_inputApplicationType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}	//전체
						,	{'codeGroup':'ApplicationStatus',		'target':'vendorRequestUser_inputApplicationStatus',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'IsNewVendor',				'target':'vendorRequestUser_inputIsNew',				'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'CompanyCode',				'target':'vendorRequestUser_CompanyCode',				'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						]

					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				},

				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("vendorRequestUser_CompanyCode");
					accountCtrl.refreshAXSelect("vendorRequestUser_inputApplicationType");
					accountCtrl.refreshAXSelect("vendorRequestUser_inputApplicationStatus");
					accountCtrl.refreshAXSelect("vendorRequestUser_inputIsNew");
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("vendorRequestUser_CompanyCode").val());
				},

				setHeaderData : function() {
					var me = this;
					me.params.headerData = [{ key:'chk',					label:'chk',																				width:'20', align:'center', formatter:'checkbox'},
											{ key:'CompanyName',			label : "<spring:message code='Cache.ACC_lbl_company' />",									width:'70',	align:'center'},		//회사
						        			{ key:'ApplicationTypeName',	label:"<spring:message code='Cache.ACC_lbl_vendorRequestType' />",							width:'70', align:'center'},	//신청유형
						        			{ key:'ApplicationStatusName',	label:"<spring:message code='Cache.ACC_lbl_requestStatus' />",								width:'70', align:'center'},	//신청상태
						        			{ key:'ApplicationTitle',		label:"<spring:message code='Cache.ACC_lbl_applicationTitle' />",							width:'70', align:'center',		//신청제목
						        				formatter:function () {
						        					var str = "<a onclick=\"VendorRequestUser.onVdClick('" 
				        								+ this.item.VendorApplicationID 
				        								+ "', '"
				        								+ this.item.ApplicationStatus
				        								+"')\"><font color='blue'><u>"
			        								+this.item.ApplicationTitle
			        								+"</u></font></a>";
								            		 return str
								            	}
						        			},
						        			{ key:'IsNewName',				label:"<spring:message code='Cache.ACC_lbl_new' />"+"/"+"<spring:message code='Cache.ACC_lbl_change' />",		width:'70', align:'center'},	//신규/변경
						        			{ key:'VendorNo',				label:"<spring:message code='Cache.ACC_lbl_vendorRegistNumber' />",							width:'70', align:'center'},	//등록번호
						        			{ key:'VendorName',				label:"<spring:message code='Cache.ACC_lbl_vendorName' />",									width:'70', align:'center'},	//거래처명
						        			{ key:'RegistDate',				label:"<spring:message code='Cache.ACC_lbl_applicationDay' />" +Common.getSession("UR_TimeZoneDisplay"),								width:'70', align:'center',
						        				formatter:function(){
						        					return CFN_TransLocalTime(this.item.RegistDate,_ServerDateSimpleFormat);
						        				}, dataType:'DateTime'
						        			}]	//신청일
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},

				searchVendorRequestUserList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var searchVendorName		= accountCtrl.getInfo("vendorRequestUser_inputVendorName").val();
					var searchVendorNo			= accountCtrl.getInfo("vendorRequestUser_inputVendorNo").val().replaceAll("-", "");
					var searchApplicationType	= accountCtrl.getComboInfo("vendorRequestUser_inputApplicationType").val();
					var searchApplicationStatus	= accountCtrl.getComboInfo("vendorRequestUser_inputApplicationStatus").val();
					var searchIsNew				= accountCtrl.getComboInfo("vendorRequestUser_inputIsNew").val();
					var companyCode				= accountCtrl.getComboInfo("vendorRequestUser_CompanyCode").val();
					var pageSizeInfo			= accountCtrl.getComboInfo("listCount").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/baseInfo/searchVendorRequestUserList.do";
					var ajaxPars		= {	"searchVendorName":searchVendorName,
											"searchVendorNo":searchVendorNo,
											"searchApplicationType"		: searchApplicationType,
											"searchApplicationStatus"	: searchApplicationStatus,
											"searchIsNew"				: searchIsNew,
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
				
				deleteList : function(){
					var me = this;
					var grid = me.params.gridPanel;
					var deleteobj = grid.getCheckedList(0);

					if(deleteobj.length==0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");	//선택된 항목이 없습니다.
						return;
					}
					var stCk = false;
					var vdAppList = "";
					for(var i = 0; i < deleteobj.length; i++)	 {
						var item = deleteobj[i];
						
						vdAppList += item.VendorApplicationID;
						if(i != deleteobj.length - 1){
							vdAppList += ",";
						}
						if(item.ApplicationStatus != "T"){
							stCk = true;
						}
					}
					
					if(stCk){
						Common.Inform("<spring:message code='Cache.ACC_013'/>"); //임시저장상태인 항목만 삭제가 가능합니다.
						return;
					}

			        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//삭제하시겠습니까?
			       		if(result){
							me.callDeleteVendorRequestUserList(vdAppList)
			       		}
			        });

				},
				
				callDeleteVendorRequestUserList : function(vdAppList){

					$.ajax({
						type:"POST",
							url:"/account/baseInfo/deleteVendorRequestList.do",
						data:{
							"vdAppList" : vdAppList,
						},
						success:function (data) {
							if(data.result == "ok")
							{
								Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//성공적으로 삭제하였습니다.
								VendorRequestUser.searchVendorRequestUserList();
							}
							else if(data.result == "F")
							{
								Common.Error("<spring:message code='Cache.ACC_013'/>");	//임시저장상태인 항목만 삭제가 가능합니다.
								VendorRequestUser.searchVendorRequestUserList();
							}
						},
						error:function (error){
							Common.Error(error.message);
						}
					});
				},

				callAddPopup : function(){
					
					var isSearched	= "N";
					var popupID		= "VendorRequestPopup";
					var openerID	= "VendorRequestUser";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_vendorRequest'/>";	//거래처 신청
					var popupYN		= "N";
					var changeSize	= "ChangePopupSize";
					var callBack	= "VendorRequestUserPopup_CallBack";
					var popupUrl	= "/account/baseInfo/callVendorRequestPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "changeSizeFunc="	+ changeSize+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "isSearched="		+ isSearched;
							
					Common.open("", popupID, popupTit, popupUrl, "900px", "650px", "iframe", true, null, null, true);
				},

				onVdClick : function(inputVendorAppID, ApplicationStatus){
					var isSearched	= "Y";
					var popupID		= "VendorRequestPopup";
					var openerID	= "VendorRequestUser";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_vendorRequest'/>";	//거래처 신청
					var popupYN		= "N";
					var applicationStatus		= ApplicationStatus;
					var changeSize	= "ChangePopupSize";
					var callBack	= "VendorRequestUserPopup_CallBack";
					var popupUrl	= "/account/baseInfo/callVendorRequestPopup.do?"
									+ "popupID="				+ popupID			+ "&"
									+ "openerID="				+ openerID			+ "&"
									+ "popupYN="				+ popupYN			+ "&"
									+ "changeSizeFunc="	+ changeSize+ "&"
									+ "callBackFunc="			+ callBack			+ "&"
									+ "vendorApplicationID="	+ inputVendorAppID	+ "&"
									+ "applicationStatus="	+ applicationStatus	+ "&"
									+ "isSearched="				+ isSearched;
							
					Common.open("", popupID, popupTit, popupUrl, "900px", "650px", "iframe", true, null, null, true);
				},
				
				VendorRequestUserPopup_CallBack : function(){
					var me = this;
					me.searchVendorRequestUserList();
					//me.
				},
				
				ChangePopupSize : function(popupID,popupW,popupH){
					accountCtrl.pChangePopupSize(popupID,popupW,popupH);
				},
				
				saveExcel : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
							var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerData);
							var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerData);
							
							var searchType   			= me.searchedType;
							var searchVendorName		= accountCtrl.getInfo("vendorRequestUser_inputVendorName").val()
							var searchVendorNo			= accountCtrl.getInfo("vendorRequestUser_inputVendorNo").val()
							var searchApplicationType	= accountCtrl.getComboInfo("vendorRequestUser_inputApplicationType").val()
							var searchApplicationStatus	= accountCtrl.getComboInfo("vendorRequestUser_inputApplicationStatus").val()
							var searchIsNew				= accountCtrl.getComboInfo("vendorRequestUser_inputIsNew").val();
							var companyCode				= accountCtrl.getComboInfo("vendorRequestUser_CompanyCode").val();
							var headerType				= accountCommon.getHeaderTypeForExcel(me.params.headerData);
							var title 			= accountCtrl.getInfo("headerTitle").text();
		
							location.href = "/account/baseInfo/excelDownloadVenderRequestUserList.do?"
											+ "searchVendorName="		+ encodeURI(nullToBlank(searchVendorName))
											+ "&searchVendorNo="		+ encodeURI(nullToBlank(searchVendorNo))
											+ "&searchApplicationType="	+ encodeURI(nullToBlank(searchApplicationType))
											+ "&searchApplicationStatus="+ encodeURI(nullToBlank(searchApplicationStatus))
											+ "&searchIsNew="			+ encodeURI(nullToBlank(searchIsNew))
											+ "&companyCode="			+ encodeURI(companyCode)
											//+ "&headerName="			+ encodeURI(headerName)
											+ "&headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="				+ encodeURI(headerKey)
											+ "&searchType="			+ encodeURI(searchType)
											//+ "&title="					+ encodeURI(accountCtrl.getInfo("headerTitle").text())
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
											+ "&headerType="			+ encodeURI(headerType);
			       		}
					});
				},
				onenter : function(){
					var me = this;
					if(event.keyCode=="13"){
						me.searchVendorRequestUserList();
					}
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.VendorRequestUser = VendorRequestUser;
	})(window);
</script>