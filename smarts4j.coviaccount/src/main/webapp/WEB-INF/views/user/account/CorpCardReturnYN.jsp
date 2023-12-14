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
				<!-- 불출 -->
				<a class="btnTypeDefault  btnTypeBg"	onclick="CorpCardReturnYN.corpCardReturnYnPopup('add', 'R', 'Release')"><spring:message code="Cache.ACC_btn_release"/></a>
				<!-- 삭제 -->
				<a class="btnTypeDefault"				onclick="CorpCardReturnYN.corpCardDel()"><spring:message code="Cache.ACC_btn_delete"/></a>
				<!-- 새로고침 -->
				<a class="btnTypeDefault"				onclick="CorpCardReturnYN.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
				<!-- 동기화 -->
				<a class="btnTypeDefault"				onclick="CorpCardReturnYN.corpCardSync();" id="btnSync"><spring:message code="Cache.ACC_btn_sync"/></a>
			</div>
			<!-- 상단 버튼 끝 -->			
		</div>
		<div id="topitembar02" class="bodysearch_Type01">
			<div class="inPerView type08">
				<div style="width:900px;">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">	<!-- 회사 -->
							<spring:message code="Cache.ACC_lbl_company"/>
						</span>
						<span id="companyCode_RetutnYN" class="selectType02" onchange="CorpCardReturnYN.changeCompanyCode()">
						</span>
					</div>
					<div class="inPerTitbox" style="visibility: hidden;">
						<span class="bodysearch_tit">	<!-- 카드유형 -->
							<spring:message code="Cache.ACC_lbl_cardClass"/>
						</span>
						<span id="cardClass_RetutnYN" class="selectType02">
						</span>
					</div>
				</div>
				<div style="width:900px;">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">	<!-- 불출자 -->
							<spring:message code="Cache.ACC_lbl_ReleaseUser"/>
						</span>
						<div class="name_box_wrap">
							<span class="name_box" id="ownerUserName_RetutnYN"></span>
							<a class="btn_del03" onclick="CorpCardReturnYN.userCodeDel()"></a>
						</div>
						<a class="btn_search03" onclick="CorpCardReturnYN.userCodeSearch()"></a>
						<input id="releaseUserCode_RetutnYN" type="text" hidden>
					</div>
					<div class="inPerTitbox">
						<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_ReleaseDate"/></span>	<!-- 불출일자 -->
						<div id="cardReturn_Release_dateArea" class="dateSel type02"></div>	
					</div>
				</div>
				<div style="width:900px;">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">	<!-- 카드번호 -->
							<spring:message code="Cache.ACC_lbl_cardNumber"/>
						</span>
						<input	id="cardNo_RetutnYN" type="text" placeholder="" MaxLength="16"
								style="width:408px;"
								onkeydown="CorpCardReturnYN.onenter(this)"
								onkeypress	= "return inputNumChk(event)"
								onchange	= "CorpCardReturnYN.changeCardNo()">
					</div>
					<a class="btnTypeDefault  btnSearchBlue" onclick="CorpCardReturnYN.searchList()"><spring:message code="Cache.ACC_btn_search"/></a>
				</div>
			</div>
		</div>
		<div class="inPerTitbox">
			<div class="buttonStyleBoxRight">	
				<span id="listCount" class="selectType02 listCount" onchange="CorpCardReturnYN.searchList()">
				</span>
				<button class="btnRefresh" type="button" onclick="CorpCardReturnYN.searchList()"></button>
			</div>
		</div>
		<div id="gridArea" class="pad10">
		</div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>
	
<script>

	if (!window.CorpCardReturnYN) {
		window.CorpCardReturnYN = {};
	}
	
	(function(window) {
		var CorpCardReturnYN = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
				
				pageInit : function() {
					var me = this;
					setPropertySyncType('CorpCard','syncProperty');
					setHeaderTitle('headerTitle');
					makeDatepicker('cardReturn_Release_dateArea', 'cardReturn_Release_dateArea_St', 'cardReturn_Release_dateArea_Ed', '', '', '', '');
					me.setPageViewController();
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
				
				setPageViewController :function(){
					var syncProperty	= accountCtrl.getInfo("syncProperty").val();
					
					if(syncProperty == "") {
						accountCtrl.getInfo("btnSync").css("display", "none");
					}
				},
				
				setSelectCombo : function(pCompanyCode){
					accountCtrl.getInfo("listCount").children().remove();
					accountCtrl.getInfo("cardClass_RetutnYN").children().remove();
					
					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "CorpCardReturnYN.searchList()");
					accountCtrl.getInfo("cardClass_RetutnYN").addClass("selectType02");
					
					var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',	'target':'listCount',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'CardClass',		'target':'cardClass_RetutnYN',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"} //전체
						,	{'codeGroup':'CompanyCode',		'target':'companyCode_RetutnYN','lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
					]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode_RetutnYN").val());
				},
				
				setWorkplace : function(obj){
					var CorporationValue = obj.value;
					if(CorporationValue !== undefined){
						var MapperCode = Common.getSession("MapperCode");
						var exceptionW = new Object();
						var ExceptionCodeList = new Array();
						var isAuthorityUser = accountCtrl.checkAuthority(Common.getSession("USERID"),'2_Account_Manage');
						
						for(var i=0; i<Common.getBaseCode('Corporation').CacheData.length; i++){
							if(Common.getBaseCode('Corporation').CacheData[i].Code == CorporationValue){
								MapperCode = Common.getBaseCode('Corporation').CacheData[i].Reserved1;
							}
						}
						
						if(isAuthorityUser){
							for(var i=0; i<Common.getBaseCode('Workplace').CacheData.length; i++){
								if(CorporationValue!=""&&MapperCode == Common.getBaseCode('Workplace').CacheData[i].ReservedInt){
									ExceptionCodeList.push(Common.getBaseCode('Workplace').CacheData[i].Code);
								}
							}
						}else{
							ExceptionCodeList.push(Common.getSession("WorkPlaceUK"));
						} 
						
						exceptionW.type = "Code";
						exceptionW.check = "Contains";
						exceptionW.conditionList = ExceptionCodeList;
						
						if(isAuthorityUser){
							accountCtrl.renderAXSelectCommon('Workplace', 'BusinessGubun',  'ko','','','', "<spring:message code='Cache.ACC_lbl_comboAll' />", '', exceptionW, true);
						}else{
							accountCtrl.renderAXSelectCommon('Workplace', 'BusinessGubun',  'ko','','','', '','', exceptionW, true);
							
						} 
					}
				},
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("companyCode_RetutnYN");
					accountCtrl.refreshAXSelect("cardStatus_RetutnYN");
					accountCtrl.refreshAXSelect("cardClass_RetutnYN");
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'chk',				label:'chk',	width:'20', align:'center',
													formatter:'checkbox'
												},
												{	key:'CardCompanyName',	label:"<spring:message code='Cache.ACC_lbl_cardCompany' />",	width:'50', align:'center'},	//카드회사
												{	key:'CardNo',			label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",		width:'70', align:'center',		//카드번호
													formatter:function () {
														var rtStr =	""
																	+	"<a onclick='CorpCardReturnYN.corpCardUpdatePopup("+ this.item.CorpCardID +"); return false;'>"
																	+		"<font color='blue'>"
																	+			this.item.CardNo
																	+		"</font>"
																	+	"</a>";
														return rtStr;
													}
												},
												{	key:'OwnerUser_NM',		label:"<spring:message code='Cache.ACC_lbl_cardOwner' />",		width:'70', align:'center'},	//소유자
												{	key:'ReleaseDate',		label:"<spring:message code='Cache.ACC_lbl_ReleaseDate' />",	width:'70', align:'center'},	//불출일자
												{	key:'ReturnDate',		label:"<spring:message code='Cache.ACC_lbl_ReturnDate' />",		width:'70', align:'center',	//반납일자
													formatter:function () {
														if(this.item.ReturnDate == ""){
															var rtStr = "<div class='btnTypeDefault btnTypeBg' style='cursor: pointer;' onclick='CorpCardReturnYN.corpCardReturnYnPopup(\"modify\", "+this.item.CorpCardID+", \"Return\")'>"
														 		      + "<spring:message code='Cache.ACC_btn_return' />"
																	  + "</div>";
															return rtStr;
														}else{
															return this.item.ReturnDate;
														}
													}
												},
												{	key:'ReleaseReason',		label:"<spring:message code='Cache.ACC_lbl_cardReleaseReason' />",	width:'70', align:'center'},	//불출사유
												{	key:'ReleaseApprover_NM',	label:"<spring:message code='Cache.ACC_lbl_ReleaseApprover' />",	width:'70', align:'center'},	//불출 승인자
												{	key:'ReturnApprover_NM',	label:"<spring:message code='Cache.ACC_lbl_ReturnApprover' />",		width:'70', align:'center'},	//반납 승인자
												{	key:'ReleaseUser_NM',		label:"<spring:message code='Cache.ACC_lbl_ReleaseUser' />",		width:'70', align:'center'},	//불출자
												{	key:'DocLink',				label:"<spring:message code='Cache.lbl_apv_linkdoc' />",			width:'70', align:'center',		//연결문서
													formatter: function(){
														var rtStr = "";
														
														if(this.item.DocLink != null && this.item.DocLink != ""){
															var docInfo = this.item.DocLink.split("@@@");
															var funcStr = "/approval/approval_Form.do?mode=COMPLETE&processID=" + docInfo[0] + "&forminstanceID=" + (typeof docInfo[3] != "undefined" ? docInfo[3] : "&archived=true") + "&bstored" + (typeof docInfo[4] != "undefined" ? docInfo[4] : "false");
															
															if(typeof docInfo[6] != "undefined" && docInfo[6] != "undefined")
																funcStr += "&ExpAppID=" + docInfo[6] + "&taskID=";
															
															funcStr = "CFN_OpenWindow(\"" + funcStr + "\",\"\",790,998,\"scroll\")";
															rtStr = "<a class='btnTypeDefault' style='vertical-align:middle' onclick='"+funcStr+"'><spring:message code='Cache.lbl_apv_linkdoc' /></a>"; //연결문서
														}
														
														return rtStr;
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
					
					var companyCode		= accountCtrl.getComboInfo("companyCode_RetutnYN").val();
					var releaseUserCode	= accountCtrl.getInfo("releaseUserCode_RetutnYN").val();
					var cardStatus		= accountCtrl.getComboInfo("cardStatus_RetutnYN").val();
					var cardNo			= accountCtrl.getInfo("cardNo_RetutnYN").val();
					var cardClass		= accountCtrl.getComboInfo("cardClass_RetutnYN").val();
					var releaseSt		= accountCtrl.getInfo("cardReturn_Release_dateArea_St").val().replaceAll(".","");
					var releaseEd		= accountCtrl.getInfo("cardReturn_Release_dateArea_Ed").val().replaceAll(".","");
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/corpCard/getCorpCardHistoryList.do";
					var ajaxPars		= {	"companyCode"		: companyCode,
							 				"releaseUserCode"	: releaseUserCode,
							 				"cardStatus"		: cardStatus,
							 				"cardNo"			: cardNo,
							 				"cardClass"			: cardClass,
							 				"releaseSt" 		: releaseSt,
							 				"releaseEd" 		: releaseEd,
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
				
				corpCardDel : function(){
					var me = this;
					var deleteObj = me.params.gridPanel.getCheckedList(0);
					if(deleteObj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noDataDelete' />");	//삭제할 항목을 선택하여 주십시오.
						return;
					}else{
						Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//삭제하시겠습니까?
							if(result){
								var deleteSeq = "";
								for(var i=0; i<deleteObj.length; i++){
									if(i==0){
										deleteSeq = deleteObj[i].CorpCardReturnID;
									}else{
										deleteSeq = deleteSeq + "," + deleteObj[i].CorpCardReturnID;
									}
								}
								
								CorpCardReturnYN.params.gridPanel.removedList = deleteObj;
								
								$.ajax({
									url	:"/account/corpCard/deleteCorpCardReturnYN.do",
									type: "POST",
									data: {
											"deleteSeq" : deleteSeq
									},
									success:function (data) {
										if(data.status == "SUCCESS"){
											Common.Inform("<spring:message code='Cache.ACC_msg_delComp' />");	//삭제를 완료하였습니다.
											CorpCardReturnYN.searchList();
										}else{
											Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
										}
									},
									error:function (error){
										Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
									}
								});
							}
						})
					}
				},
				
				corpCardAddPopup : function(){
					var mode		= "add";
					var popupID		= "corpCardPopup";
					var openerID	= "CorpCardReturnYN";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_coprCardAdd' />";	//카드정보등록
					var popupYN		= "N";
					var callBack	= "corpCardPopup_CallBack";
					var popupUrl	= "/account/corpCard/getCorpCardPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "mode="			+ mode;
					
					Common.open("", popupID, popupTit, popupUrl, "830px", "720px", "iframe", true, null, null, true);
				},
				
				//불출 및 반납 
				corpCardReturnYnPopup : function(Key, corpCardID, rMode){
					var popupTitText = "";
					var height = "";
					
					if(rMode == "Release"){
						popupTitText = "<spring:message code='Cache.ACC_lbl_cardRelease' />"; // 카드불출
						height = "430px";
					}else{
						popupTitText = "<spring:message code='Cache.ACC_lbl_cardReturn' />"; // 카드반납
						height = "250px";
					}
					
					var mode		= Key;
					var popupID		= "corpReturnYnPopup";
					var openerID	= "CorpCardReturnYN";					
					var popupTit	= popupTitText;	
					var popupYN		= "N";
					var callBack	= "corpCardPopup_CallBack";
					var popupUrl	= "/account/corpCard/getCorpCardReturnYNPopup.do?"
									+ "popupID="		+ popupID		+ "&"
									+ "openerID="		+ openerID		+ "&"
									+ "popupYN="		+ popupYN		+ "&"
									+ "callBackFunc="	+ callBack		+ "&"
									+ "corpCardID="		+ corpCardID	+ "&"
									+ "mode="			+ mode;
					               
					
					Common.open("", popupID, popupTit, popupUrl, "510px", height, "iframe", true, null, null, true);
				},
				
				
				corpCardUpdatePopup : function(key){
					
					var mode		= "modify";
					var popupID		= "corpCardPopup";
					var openerID	= "CorpCardReturnYN";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_corpCardModify' />"; //카드정보
					var popupYN		= "N";
					var callBack	= "corpCardPopup_CallBack";
					var popupUrl	= "/account/corpCard/getCorpCardPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack	+ "&"
									+ "corpCardID="		+ key		+ "&"
									+ "mode="			+ mode;
					Common.open("", popupID, popupTit, popupUrl, "830px", "720px", "iframe", true, null, null, true);
				},
				
				corpCardPopup_CallBack : function(){
					var me = this
					me.searchList();
				},
				
				userCodeSearch : function(){
					var popupID		= "orgmap_pop";
					var openerID	= "CorpCardReturnYN";
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
					
					accountCtrl.getInfo("releaseUserCode_RetutnYN").val(UserCode[0]);
					accountCtrl.getInfo("ownerUserName_RetutnYN").text(userName[0]);
				},
				
				userCodeDel : function(){
					accountCtrl.getInfo("releaseUserCode_RetutnYN").val('');
					accountCtrl.getInfo("ownerUserName_RetutnYN").text('');
				},
		
				
				corpCardSync : function(){
					$.ajax({
						url	: "/account/corpCard/corpCardSync.do",
						type: "POST",
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_syncComp' />");	//동기화되었습니다
								CorpCardReturnYN.searchList('N');
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
					var cardNo = accountCtrl.getInfo("cardNo_RetutnYN").val();
						cardNo = getNumOnly(cardNo);
						accountCtrl.getInfo("cardNo_RetutnYN").val(cardNo);
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
		window.CorpCardReturnYN = CorpCardReturnYN;
	})(window);
	
</script>