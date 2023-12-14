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
					<a class="btnTypeDefault  btnTypeBg " 	onclick="VendorRequest.callAddPopup();"><spring:message code="Cache.btn_Add"/></a>
					<a class="btnTypeDefault" 				onclick="VendorRequest.deleteList();"><spring:message code="Cache.btn_delete"/></a>
					 -->
					<!-- 승인 -->
					<a class="btnTypeDefault btnTypeBg" href="#" 		onclick="VendorRequest.vendReq_vdAprvStat('E');"><spring:message code="Cache.ACC_btn_accept"/></a>
					<!-- 반려 -->
					<a class="btnTypeDefault" href="#" 		onclick="VendorRequest.vendReq_vdAprvStat('R');"><spring:message code="Cache.ACC_btn_reject"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"				onclick="VendorRequest.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀 다운로드 -->
					<a class="btnTypeDefault btnExcel" 		onclick="VendorRequest.saveExcel();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
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
							<span class="selectType02" id="vendorRequest_CompanyCode" onchange="VendorRequest.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 신청유형 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorRequestType"/></span>
							<span class="selectType02 " id="vendorRequest_inputApplicationType" >
							</span>	
						</div>
						<div class="inPerTitbox">
							<!-- 신청상태 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_requestStatus"/></span>
							<span class="selectType02 " id="vendorRequest_inputApplicationStatus" >
							</span>					
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<!-- 신규/변경 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_new"/>/<spring:message code="Cache.ACC_lbl_change"/></span>
							<span class="selectType02 " id="vendorRequest_inputIsNew" >
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 거래처명 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorName"/></span>
							<input id="vendorRequest_inputVendorName" type="text"
								onkeydown="VendorRequest.onenter()">							
						</div>
						<div class="inPerTitbox">
							<!-- 등록번호 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorRegistNumber"/></span>
							<input id="vendorRequest_inputVendorNo" type="text"
								onkeydown="VendorRequest.onenter()">
						</div>
						<a class="btnTypeDefault btnSearchBlue " onclick="VendorRequest.searchVendorRequestList();"><spring:message code="Cache.ACC_btn_search"/></a><!-- 버튼위치를 인라인으로 조정 -->
					</div>							
				</div>
			</div>
			<!-- ===================== -->
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight ">	
					<span class="selectType02 listCount" id="listCount" onchange="VendorRequest.searchVendorRequestList();">
					</span>
					<button class="btnRefresh" type="button" onclick="VendorRequest.searchVendorRequestList();"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
			
		</div>
		<!-- 컨텐츠 끝 -->
	</div>

<script>
		
	if (!window.VendorRequest) {
		window.VendorRequest = {};
	}
	
	(function(window) {
		var VendorRequest = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},

				pageInit : function() {
					var me = this;
					setHeaderTitle('headerTitle');
					me.setSelectCombo();
					me.setHeaderData();
					me.searchVendorRequestList('Y');
				},

				pageView : function() {
					var me = this;
					
					me.setHeaderData();
					me.refreshCombo();
					
					me.searchVendorRequestList();
				},

				setSelectCombo : function(pCompanyCode){
					accountCtrl.getInfo("listCount").children().remove();
					accountCtrl.getInfo("vendorRequest_inputApplicationType").children().remove();
					accountCtrl.getInfo("vendorRequest_inputApplicationStatus").children().remove();
					accountCtrl.getInfo("vendorRequest_inputIsNew").children().remove();

					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "VendorRequest.searchVendorRequestList();");
					accountCtrl.getInfo("vendorRequest_inputApplicationType").addClass("selectType02");
					accountCtrl.getInfo("vendorRequest_inputApplicationStatus").addClass("selectType02");
					accountCtrl.getInfo("vendorRequest_inputIsNew").addClass("selectType02");
					
					var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',				'target':'listCount',								'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'VendorApplicationType',		'target':'vendorRequest_inputApplicationType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"} //전체
						,	{'codeGroup':'ApplicationStatus',			'target':'vendorRequest_inputApplicationStatus',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'IsNewVendor',					'target':'vendorRequest_inputIsNew',				'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'CompanyCode',					'target':'vendorRequest_CompanyCode',				'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				},

				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("vendorRequest_CompanyCode");
					accountCtrl.refreshAXSelect("vendorRequest_inputApplicationType");
					accountCtrl.refreshAXSelect("vendorRequest_inputApplicationStatus");
					accountCtrl.refreshAXSelect("vendorRequest_inputIsNew");
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("vendorRequest_CompanyCode").val());
				},

				setHeaderData : function() {
					var me = this;
					me.params.headerData = [{ key:'chk',					label:'chk',																				width:'20', align:'center', formatter:'checkbox'},
											{ key:'CompanyName',			label : "<spring:message code='Cache.ACC_lbl_company' />",									width:'70',	align:'center'},	//회사
											{ key:'ApplicationTypeName',	label:"<spring:message code='Cache.ACC_lbl_vendorRequestType' />",							width:'70', align:'center'},	//신청유형
						        			{ key:'ApplicationStatusName',	label:"<spring:message code='Cache.ACC_lbl_requestStatus' />",								width:'70', align:'center'},	//신청상태
						        			{ key:'ApplicationTitle',		label:"<spring:message code='Cache.ACC_lbl_applicationTitle' />",							width:'70', align:'center',		//신청제목
						        				formatter:function () {
						        					var str = "<a onclick=\"VendorRequest.onVdClick('" 
							        								+ this.item.VendorApplicationID 
							        								+ "', '"
							        								+ this.item.ApplicationStatus
							        								+"')\"><font color='blue'><u>"
						        							+this.item.ApplicationTitle
						        								+"</u></font></a>";
								            		 return str
								            	}
						        			},
						        			{ key:'IsNewName',				label:"<spring:message code='Cache.ACC_lbl_new' />"+"/"+"<spring:message code='Cache.ACC_lbl_change' />",		width:'70', align:'center'},	//신규//변경
						        			{ key:'VendorNo',				label:"<spring:message code='Cache.ACC_lbl_vendorRegistNumber' />",							width:'70', align:'center'},	//등록번호
						        			{ key:'VendorName',				label:"<spring:message code='Cache.ACC_lbl_vendorName' />",									width:'70', align:'center'},	//거래처명
						        			{ key:'RegistDate',				label:"<spring:message code='Cache.ACC_lbl_applicationDay' />"+Common.getSession("UR_TimeZoneDisplay"),								width:'70', align:'center',
						        				formatter:function(){
						        					return CFN_TransLocalTime(this.item.RegistDate,_ServerDateSimpleFormat);
						        				}, dataType:'DateTime'	
						        			}]	//신청일
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},

				searchVendorRequestList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var searchVendorName		= accountCtrl.getInfo("vendorRequest_inputVendorName").val();
					var searchVendorNo			= accountCtrl.getInfo("vendorRequest_inputVendorNo").val().replaceAll("-", "");
					var searchApplicationType	= accountCtrl.getComboInfo("vendorRequest_inputApplicationType").val();
					var searchApplicationStatus	= accountCtrl.getComboInfo("vendorRequest_inputApplicationStatus").val();
					var searchIsNew				= accountCtrl.getComboInfo("vendorRequest_inputIsNew").val();
					var companyCode				= accountCtrl.getComboInfo("vendorRequest_CompanyCode").val();
					var pageSizeInfo			= accountCtrl.getComboInfo("listCount").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/baseInfo/searchVendorRequestList.do";
					var ajaxPars		= { "searchVendorName"			: searchVendorName,
											"searchVendorNo"			: searchVendorNo,
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
						Common.Error("<spring:message code='Cache.ACC_013'/>");	//임시저장상태인 항목만 삭제할 수 있습니다.
						return;
					}
					
					me.callDeleteVendorRequestList(vdAppList)

				},
				
				callDeleteVendorRequestList : function(vdAppList){
					$.ajax({
						type:"POST",
							url:"/account/baseInfo/deleteVendorRequestList.do",
						data:{
							"vdAppList" : vdAppList,
						},
						success:function (data) {
							if(data.result == "ok")
							{
								Common.Inform("<spring:message code='Cache.ACC_msg_delComp'/>");	//성공적으로 삭제하였습니다.
								VendorRequest.searchVendorRequestList();
							}
							else if(data.result == "F")
							{
								Common.Error("<spring:message code='Cache.ACC_013'/>");		//임시저장 상태인 항목만 삭제할 수 있습니다.
								VendorRequest.searchVendorRequestList();
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의바랍니다.
						}
					});
				},

				callAddPopup : function(){
					
					var isSearched	= "N";
					var popupID		= "VendorRequestPopup";
					var openerID	= "VendorRequest";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_vendorRequest'/>";	//거래처신청
					var popupYN		= "N";
					var changeSize	= "ChangePopupSize";
					var callBack	= "vendorRequestPopup_CallBack";
					var popupUrl	= "/account/baseInfo/callVendorRequestPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "changeSizeFunc="	+ changeSize+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "isSearched="		+ isSearched;
							
					Common.open("", popupID, popupTit, popupUrl, "900px", "400px", "iframe", true, null, null, true);
				},

				onVdClick : function(inputVendorAppID, ApplicationStatus){
					
					var isSearched	= "Y";
					var popupID		= "VendorRequestPopup";
					var openerID	= "VendorRequest";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_vendorRequest'/>";	//거래처신청
					var popupYN		= "N";
					var applicationStatus		= ApplicationStatus;
					var changeSize	= "ChangePopupSize";
					var callBack	= "vendorRequestPopup_CallBack";
					var popupUrl	= "/account/baseInfo/callVendorRequestPopup.do?"
									+ "popupID="				+ popupID			+ "&"
									+ "openerID="				+ openerID			+ "&"
									+ "popupYN="				+ popupYN			+ "&"
									+ "changeSizeFunc="			+ changeSize		+ "&"
									+ "callBackFunc="			+ callBack			+ "&"
									+ "vendorApplicationID="	+ inputVendorAppID	+ "&"
									+ "applicationStatus="	+ applicationStatus	+ "&"
									+ "isAdminMenu=Y&"
									+ "isSearched="				+ isSearched;
							
					Common.open("", popupID, popupTit, popupUrl, "900px", "620px", "iframe", true, null, null, true);
				},
				
				ChangePopupSize : function(popupID,popupW,popupH){
					accountCtrl.pChangePopupSize(popupID,popupW,popupH);
				},
				
				vendorRequestPopup_CallBack : function(){
					var me = this;
					me.searchVendorRequestList();
					//me.
				},
				
				saveExcel : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			      		if(result){
								var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerData);
								var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerData);
								var headerType		= accountCommon.getHeaderTypeForExcel(me.params.headerData);
								
								var searchType   			= me.searchedType;			
								var searchVendorName		= accountCtrl.getInfo("vendorRequest_inputVendorName").val();
								var searchVendorNo			= accountCtrl.getInfo("vendorRequest_inputVendorNo").val();
								var searchApplicationType	= accountCtrl.getComboInfo("vendorRequest_inputApplicationType").val();
								var searchApplicationStatus	= accountCtrl.getComboInfo("vendorRequest_inputApplicationStatus").val();
								var searchIsNew				= accountCtrl.getComboInfo("vendorRequest_inputIsNew").val();
								var companyCode				= accountCtrl.getComboInfo("vendorRequest_CompanyCode").val();
								var title 			= accountCtrl.getInfo("headerTitle").text();
								
								location.href = "/account/baseInfo/excelDownloadVenderRequestList.do?"
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

				vendReq_vdAprvStat : function(stat){
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
								&& item.ApplicationStatus != "S"){
							statCk = true
						}
					}
					
					var msg = ""
					

					if(statCk){
						msg = "<spring:message code='Cache.ACC_025' />"; //결재 진행중이 아닌 항목이 선택되었습니다.
						Common.Inform(msg);
						return;
					}
						
					
					if(stat=="E"){
						msg = "<spring:message code='Cache.ACC_msg_ckAccept' />";	//승인하시겠습니까?
					}else if(stat=="R"){
						msg = "<spring:message code='Cache.ACC_msg_ckReject' />";	//반려하시겠습니까?
					}
					if(appCk){

						msg = "<spring:message code='Cache.ACC_024' />" +"<br>"+  msg;	//하나의 전표에 여러 증빙이 있는 항목이 있습니다. 승인/반려시 전표의 모든 증빙이 같이 처리됩니다.
					}
					
			        Common.Confirm(msg, "Confirmation Dialog", function(result){
			       		if(result){

							var aprvObj = {
									setStatus : stat
							};
							aprvObj.aprvList = 	aprvobj
			       			me.vendReq_callVdAprvStatChange(aprvObj)
			       		}
			        });
				},
				
				vendReq_callVdAprvStatChange : function(aprvObj){
					var me = this;
					if(aprvObj == null ){
						return;
					}
					if(aprvObj.aprvList == null ){
						return;
					}
					
					$.ajax({
						type:"POST",
							url:"/account/baseInfo/vendAprvStatChange.do",
						data:{
							"aprvObj"	: JSON.stringify(aprvObj),
						},
						success:function (data) {
							if(data.result == "ok"){
								Common.Inform("<spring:message code='Cache.ACC_msg_processComplet'/>");//처리를 완료하였습니다.
								me.searchVendorRequestList();
							}
							else if(data.result == "st"){
								Common.Inform("<spring:message code='Cache.ACC_025'/>");	//결재 진행중이 아닌 항목이 선택되었습니다.
								me.searchVendorRequestList();
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				onenter : function(){
					var me = this;
					if(event.keyCode=="13"){
						me.searchVendorRequestList();
					}
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
				
				
		}
		window.VendorRequest = VendorRequest;
	})(window);
</script>