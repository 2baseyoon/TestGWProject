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
					<!-- 삭제 -->
					<a class="btnTypeDefault" 			onclick="MobileReceipt.deleteMobileReceipt();"><spring:message code="Cache.ACC_lbl_delete"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"			onclick="MobileReceipt.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"	onclick="MobileReceipt.excelDownload()"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 추가 -->
					<a class="btnTypeDefault" style="display:none;" id="insertMobileReceiptBtn" onclick="MobileReceipt.insertMobileReceipt();">
						<spring:message code="Cache.ACC_btn_add"/>
					</a>
				</div>
				<!-- 상단 버튼 끝 -->				
			</div>
			<div id="searchbar" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 회사 -->
								<spring:message code="Cache.ACC_lbl_company"/>
							</span>
							<span id="companyCode" class="selectType02" onchange="MobileReceipt.changeCompanyCode()">
							</span>
						</div>						
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 정산상태 -->
								<spring:message code="Cache.ACC_lbl_taxInvoice"/>
							</span>
							<span id="active" class="selectType02" style="width:239px;">
							</span>
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 등록자 -->
								<spring:message code="Cache.ACC_lbl_registerName"/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" id="registerName"></span>
								<a class="btn_del03" onclick="MobileReceipt.userCodeDel()"></a>
							</div>
							<a class="btn_search03" onclick="MobileReceipt.userCodeSearch()"></a>
							<input id="registerID" type="text" hidden>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">		<!-- 촬영일자 -->
								<spring:message code="Cache.ACC_lbl_photoDate"/>
							</span>
							<div id="photoDate" class="dateSel type02">
							</div>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">		<!-- 구분 -->
								<spring:message code="Cache.ACC_lbl_division"/>
							</span>
							<span id="receiptType" class="selectType02" style="width: 100px;">
							</span>
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="MobileReceipt.searchList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="MobileReceipt.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="MobileReceipt.searchList()"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

if (!window.MobileReceipt) {
	window.MobileReceipt = {};
}

(function(window) {
	var MobileReceipt = {
			params	:{
				gridPanel	: new coviGrid(),
				headerData	: []
			},

			pageInit : function() {
				var me = this;
				setHeaderTitle('headerTitle');
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
				makeDatepicker('photoDate','photoDateS','photoDateE','','','');
			},
			
			setSelectCombo : function(pCompanyCode){
				accountCtrl.getInfo("listCount").children().remove();
				accountCtrl.getInfo("active").children().remove();
				accountCtrl.getInfo("receiptType").children().remove();

				accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "MobileReceipt.searchList()");
				accountCtrl.getInfo("active").addClass("selectType02").css("width", "239px");
				accountCtrl.getInfo("receiptType").addClass("selectType02").css("width", "100px");
				
				var AXSelectMultiArr	= [	
						{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
					,	{'codeGroup':'Active',			'target':'active',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
					,	{'codeGroup':'ReceiptType',		'target':'receiptType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
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
				accountCtrl.refreshAXSelect("receiptType");
			},
			
			changeCompanyCode : function() {
				var me = this;
				me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
			},
			
			setHeaderData : function() {
				var me = this;
				me.params.headerData = [	{	key:'chk',				label:'chk',		width:'20',		align:'center',
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
											{ 	key:'CompanyName',		label : "<spring:message code='Cache.ACC_lbl_company' />",			width:'50',		align:'center'},	//회사
				                        	{	key:'ActiveName',		label:"<spring:message code='Cache.ACC_lbl_processStatus' />",		width:'50',		align:'center'},	//처리상태
				    						{	key:'PhotoDateStr',		label:"<spring:message code='Cache.ACC_lbl_photoDate' />",			width:'50',		align:'center',
			                        		formatter:function(){
				                        			return this.item.PhotoDateStr;
				                        	}, dataType:'DateTime'
				    						},	//촬영일자
				    						{	key:'ReceiptTypeName',	label:"<spring:message code='Cache.ACC_lbl_division' />",			width:'50',		align:'center'},	//구분
				    						{	key:'UsageText',		label:"<spring:message code='Cache.ACC_useHistory' />",				width:'100',	align:'center',		//내역
				    							formatter:function () {
													var rtStr =	""
																+	"<a onclick='MobileReceipt.mobileReceiptPopup(\""+ this.item.ReceiptFileID +"\"); return false;'>"
																+		"<font color='blue'>"
																+			this.item.UsageText
																+		"</font>"
																+	"</a>";
													return rtStr;
												}
				    						},
				    						{	key:'RegisterName',		label:"<spring:message code='Cache.ACC_lbl_registerName' />",		width:'50',		align:'center'},	//등록자
				    						{	key:'RegisterDept',		label:"<spring:message code='Cache.ACC_lbl_registerDept' />",		width:'50',		align:'center'},	//등록자 부서
				    						{	key:'StandardBriefName',label:"<spring:message code='Cache.ACC_standardBrief' />",			width:'50',		align:'center'},	//표준적요
				    					]
				
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},

			searchList : function(YN){
				var me = this;
				
				me.setHeaderData();
				
				var companyCode	= accountCtrl.getComboInfo("companyCode").val();
				var active		= accountCtrl.getComboInfo("active").val();
				var receiptType	= accountCtrl.getComboInfo("receiptType").val();

				var photoDateS	= accountCtrl.getInfo("photoDateS").val().replace(/\./gi, '-');
				var photoDateE	= accountCtrl.getInfo("photoDateE").val().replace(/\./gi, '-');
				var userCode	= accountCtrl.getInfo("registerID").val();
				
				var gridAreaID		= "gridArea";
				var gridPanel		= me.params.gridPanel;
				var gridHeader		= me.params.headerData;
				var ajaxUrl			= "/account/mobileReceipt/getMobileReceiptList.do";
				var ajaxPars		= {	"companyCode"	: companyCode,
										"userCode"		: userCode,
										"photoDateS"	: photoDateS,
										"photoDateE"	: photoDateE,
		 								"active"		: active,
		 								"receiptType"	: receiptType,
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
				var openerID	= "MobileReceipt";
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
				var userCode	= arr.UserCode.split(';');
				accountCtrl.getInfo('registerID').val(userCode[0]);
				accountCtrl.getInfo('registerName').text(userName[0]);
			},
			
			userCodeDel : function(){
				accountCtrl.getInfo('registerID').val('');
				accountCtrl.getInfo('registerName').text('');
			},
			
			excelDownload : function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
		       		if(result){
						var headerName	= accountCommon.getHeaderNameForExcel(me.params.headerData);
						var headerKey	= accountCommon.getHeaderKeyForExcel(me.params.headerData);
						
						var companyCode	= accountCtrl.getComboInfo("companyCode").val();
						var receiptType	= accountCtrl.getComboInfo("receiptType").val();
						var active		= accountCtrl.getComboInfo("active").val();

						var photoDateS	= accountCtrl.getInfo("photoDateS").val().replace(/\./gi, '-');
						var photoDateE	= accountCtrl.getInfo("photoDateE").val().replace(/\./gi, '-');
						var userCode	= accountCtrl.getInfo("registerID").val();
						var headerType			= accountCommon.getHeaderTypeForExcel(me.params.headerData);
						var title 			= accountCtrl.getInfo("headerTitle").text();
						
						var	locationStr		= "/account/mobileReceipt/mobileReceiptExcelDownload.do?"
											//+ "headerName="		+ encodeURI(headerName)
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="		+ encodeURI(headerKey)
											+ "&companyCode="	+ encodeURI(companyCode)
											+ "&userCode="		+ encodeURI(userCode)
											+ "&photoDateS="	+ encodeURI(photoDateS)
											+ "&photoDateE="	+ encodeURI(photoDateE)
											+ "&active="		+ encodeURI(active)
											+ "&receiptType="	+ encodeURI(receiptType)
											//+ "&title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text())
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
											+ "&headerType=" + encodeURI(headerType);
						
						location.href = locationStr;
		       		}
				});
			},
			
			mobileReceiptPopup : function(FileID){
				var popupName	=	"FileViewPopup";
				var popupID		=	"FileViewPopup";
				var openerID	=	"MobileReceipt";
				var callBack	=	"zoomMobileReceiptPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup' />"; //영수증 보기
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+ popupID	+ "&"
								+	"popupName="	+ popupName	+ "&"
								+	"fileID="		+ FileID	+ "&"
								+	"openerID="		+ openerID	+ "&"
								+	"callBackFunc="	+	callBack;
				Common.open("",popupID,popupTit,url,"340px","500px","iframe",true,null,null,true);
			},
			
			zoomMobileReceiptPopup : function(info){
				var me = this;
				
				var popupID		=	"fileViewPopupZoom";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup'/>";	//영수증 보기
				var popupName	=	"FileViewPopup";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"fileID="		+	info.FileID	+	"&"					
								+	me.pageOpenerIDStr				+	"&"
								+	"zoom="			+	"Y"		
				Common.open(	"",popupID,popupTit,url,"490px","700px","iframe",true,null,null,true);
			},
			
			deleteMobileReceipt : function() {
				var me = this;
				var deleteObj = me.params.gridPanel.getCheckedList(0);
				if(deleteObj.length == 0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noDataDelete' />");	//삭제할 항목이 없습니다.
					return;
				}else{
					Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//삭제하시겠습니까?
						if(result){
							var deleteSeq = "";
							for(var i=0; i<deleteObj.length; i++){
								if(i==0){
									deleteSeq = deleteObj[i].ReceiptID;
								}else{
									deleteSeq = deleteSeq + "," + deleteObj[i].ReceiptID;
								}
							}
							$.ajax({
								url	:"/account/mobileReceipt/deleteMobileReceipt.do",
								type: "POST",
								data: {
										"deleteSeq" : deleteSeq
								},
								success:function (data) {
									if(data.status == "SUCCESS"){
										Common.Inform("<spring:message code='Cache.ACC_msg_delComp' />");	//삭제를 완료하였습니다.
										MobileReceipt.refresh();
									}else{
										Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
									}
								},
								error:function (error){
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
								}
							});
						}
					})
				}				
			},
			insertMobileReceipt: function() {
				var mode		= "add";
				var popupID		= "insertMobileReceipt";
				var openerID	= "MobileReceipt";
				var popupTit	= "<spring:message code='Cache.ACC_btn_add'/>";
				var popupYN		= "N";
				var callBack	= "insertMobileReceipt_callBack";
				var popupUrl	= "/account/mobileReceipt/insertMobileReceipt.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "callBackFunc="	+ callBack;
				
				Common.open("", popupID, popupTit, popupUrl, "700px", "600px", "iframe", true, null, null, true);
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
			}
	}
	window.MobileReceipt = MobileReceipt;
})(window);

</script>