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
				<a class="btnTypeDefault btnTypeChk"	onclick="CorpCard.corpCardAddPopup()"><spring:message code="Cache.ACC_btn_add"/></a>
				<!-- 삭제 -->
				<a class="btnTypeDefault"				onclick="CorpCard.corpCardDel()"><spring:message code="Cache.ACC_btn_delete"/></a>
				<!-- 새로고침 -->
				<a class="btnTypeDefault"				onclick="CorpCard.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
				<!-- 동기화 -->
				<a class="btnTypeDefault"				onclick="CorpCard.corpCardSync();" id="btnSync"><spring:message code="Cache.ACC_btn_sync"/></a>
				<!-- 템플릿 다운로드 -->
				<a class="btnTypeDefault btnExcel" 		onclick="CorpCard.templateDownload();"><spring:message code="Cache.ACC_lbl_templateDownload"/></a>
				<!-- 엑셀 업로드 -->
				<a class="btnTypeDefault btnExcel" 		onclick="CorpCard.excelUpload();"><spring:message code="Cache.ACC_lbl_excelUpload"/></a>
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
						<span id="companyCode" class="selectType02" onchange="CorpCard.changeCompanyCode()">
						</span>
					</div>
					<div class="inPerTitbox">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">	<!-- 카드유형 -->
							<spring:message code="Cache.ACC_lbl_cardClass"/>
						</span>
						<span id="cardClass" class="selectType02">
						</span>
					</div>
					</div>
				</div>
				<div style="width:900px;">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">	<!-- 소유자 -->
							<spring:message code="Cache.ACC_lbl_cardOwner"/>
						</span>
						<div class="name_box_wrap">
							<span class="name_box" id="ownerUserName"></span>
							<a class="btn_del03" onclick="CorpCard.userCodeDel()"></a>
						</div>
						<a class="btn_search03" onclick="CorpCard.userCodeSearch()"></a>
						<input id="ownerUserCode" type="text" hidden>
					</div>
					<div class="inPerTitbox">
						<span class="bodysearch_tit">	<!-- 카드상태 -->
							<spring:message code="Cache.ACC_lbl_cardStatus"/>
						</span>
						<span id="cardStatus" class="selectType02">
						</span>
					</div>
				</div>
				<div style="width:900px;">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">	<!-- 카드번호 -->
							<spring:message code="Cache.ACC_lbl_cardNumber"/>
						</span>
						<input	id="cardNo" type="text" placeholder="" MaxLength="16"
								style="width:408px;"
								onkeydown="CorpCard.onenter(this)"
								onkeypress	= "return inputNumChk(event)"
								onkeyup	= "CorpCard.changeCardNo()">
					</div>
					<a class="btnTypeDefault  btnSearchBlue" onclick="CorpCard.searchList()"><spring:message code="Cache.ACC_btn_search"/></a>
				</div>
			</div>
		</div>
		<div class="inPerTitbox">
			<div class="buttonStyleBoxRight">	
				<span id="listCount" class="selectType02 listCount" onchange="CorpCard.searchList()">
				</span>
				<button class="btnRefresh" type="button" onclick="CorpCard.searchList()"></button>
			</div>
		</div>
		<div id="gridArea" class="pad10">
		</div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>
	
<script>

	if (!window.CorpCard) {
		window.CorpCard = {};
	}
	
	(function(window) {
		var CorpCard = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
				
				pageInit : function() {
					var me = this;
					setPropertySyncType('Corpcard','syncProperty');
					setHeaderTitle('headerTitle');
					me.setPageViewController();
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
				
				setSelectCombo : function(pCompanyCode){
					accountCtrl.getInfo("listCount").children().remove();
					accountCtrl.getInfo("cardStatus").children().remove();
					accountCtrl.getInfo("cardClass").children().remove();

					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "CorpCard.searchList()");
					accountCtrl.getInfo("cardStatus").addClass("selectType02");
					accountCtrl.getInfo("cardClass").addClass("selectType02");
					
					var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',	'target':'listCount',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'CardStatus',		'target':'cardStatus',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"} //전체
						,	{'codeGroup':'CardClass',		'target':'cardClass',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'CompanyCode',		'target':'companyCode',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
					]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				},
				
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("companyCode");
					accountCtrl.refreshAXSelect("cardStatus");
					accountCtrl.refreshAXSelect("cardClass");
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'chk',				label:'chk',	width:'20', align:'center',
													formatter:'checkbox'
												},
												{	key:'CompanyCode',		label : "<spring:message code='Cache.ACC_lbl_company' />",		width:'50',	align:'center',		//회사
													formatter: function() {
														return this.item.CompanyName;
													}
												},
												{	key:'CardCompanyName',	label:"<spring:message code='Cache.ACC_lbl_cardCompany' />",	width:'50', align:'center'},	//카드회사
												{	key:'CardNo',			label:"<spring:message code='Cache.ACC_lbl_cardNumber' />",		width:'70', align:'center',		//카드번호
													formatter:function () {
														var rtStr =	""
																	+	"<a onclick='CorpCard.corpCardUpdatePopup("+ this.item.CorpCardID +"); return false;'>"
																	+		"<font color='blue'>"
																	+			this.item.CardNo
																	+		"</font>"
																	+	"</a>";
														return rtStr;
													}
												},
												{	key:'CardStatusName',	label:"<spring:message code='Cache.ACC_lbl_cardStatus' />",		width:'50', align:'center'},	//카드상태
												{	key:'IssueDate',		label:"<spring:message code='Cache.ACC_lbl_issueDate' />",		width:'70', align:'center'},	//발급일자
												{	key:'PayDate',			label:"<spring:message code='Cache.ACC_lbl_payDate' />",		width:'70', align:'center'},	//결제일자
												{	key:'ExpirationDate',	label:"<spring:message code='Cache.ACC_lbl_expirationDate' />",	width:'70', align:'center'},	//만료일자
												{	key:'LimitAmount',		label:"<spring:message code='Cache.ACC_lbl_limitAmt' />",		width:'70', align:'center'},	//한도금액
												{	key:'OwnerUserNum',		label:"<spring:message code='Cache.ACC_lbl_ownerUserNumber' />",width:'70', align:'center'},	//소유자사번
												{	key:'OwnerUserName',	label:"<spring:message code='Cache.ACC_lbl_cardOwner' />",		width:'70', align:'center'},	//소유자
												{	key:'OwnerUserDept',	label:"<spring:message code='Cache.ACC_lbl_cardOwnerDept' />",	width:'70', align:'center'},		//소유자 부서
												{	key:'ReleaseYN',		label:"<spring:message code='Cache.ACC_lbl_cardReleaseAndReturn' />",	width:'50', align:'center',		//카드/불출
													formatter:function(){
														var ReturnCardText = "";
														var rtStr =	"";
														if(this.item.CardClass!="CCL3")//법인공용
															return rtStr; 
														
													 	if(this.item.ReleaseYN == "Y"){
															ReturnCardText = "<spring:message code='Cache.ACC_btn_return' />"; //반납
														}else{
													 		ReturnCardText = "<spring:message code='Cache.ACC_btn_release' />"; //불출
														} 
													 	
													 	if(this.item.ReleaseYN == "Y" ){
													 		rtStr = "<div class='btnTypeDefault' style='background:#4abde1; cursor: pointer;' onclick='CorpCard.corpCardReturnYnPopup(\"modify\", "+this.item.CorpCardID+", \"Return\")'>"
													 		      + ReturnCardText
																  +"</div>";
													 	}else{
													 		rtStr = "<div class='btnTypeDefault' style='background:#F38B3C; cursor: pointer;' onclick='CorpCard.corpCardReturnYnPopup(\"modify\", "+this.item.CorpCardID+", \"Release\")'>"
													 		      + ReturnCardText
																  +"</div>";
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
					
					var companyCode		= accountCtrl.getComboInfo("companyCode").val();
					var ownerUserCode	= accountCtrl.getInfo("ownerUserCode").val();
					var cardStatus		= accountCtrl.getComboInfo("cardStatus").val();
					var cardNo			= accountCtrl.getInfo("cardNo").val();
					var cardClass		= accountCtrl.getComboInfo("cardClass").val();
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/corpCard/getCorpCardList.do";
					var ajaxPars		= {	"companyCode"	: companyCode,
							 				"ownerUserCode"	: ownerUserCode,
							 				"cardStatus"	: cardStatus,
							 				"cardNo"		: cardNo,
							 				"cardClass"		: cardClass
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
										deleteSeq = deleteObj[i].CorpCardID;
									}else{
										deleteSeq = deleteSeq + "," + deleteObj[i].CorpCardID;
									}
								}
								
								CorpCard.params.gridPanel.removedList = deleteObj;
								
								$.ajax({
									url	:"/account/corpCard/deleteCorpCard.do",
									type: "POST",
									data: {
											"deleteSeq" : deleteSeq
									},
									success:function (data) {
										if(data.status == "SUCCESS"){
											Common.Inform("<spring:message code='Cache.ACC_msg_delComp' />");	//삭제를 완료하였습니다.
											CorpCard.searchList();
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
					var openerID	= "CorpCard";
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
					var popupTitText ="";
					var height = "";
					
					if(rMode == "Release"){
						popupTitText ="<spring:message code='Cache.ACC_lbl_cardRelease' />"; // 카드불출
						height = "380px";
					}else{
						popupTitText ="<spring:message code='Cache.ACC_lbl_cardReturn' />"; // 카드반납
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
					               
					
					Common.open("", popupID, popupTit, popupUrl, "500px", height, "iframe", true, null, null, true);
				},
				
				corpCardUpdatePopup : function(key){
					
					var mode		= "modify";
					var popupID		= "corpCardPopup";
					var openerID	= "CorpCard";
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
					var openerID	= "CorpCard";
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
					
					accountCtrl.getInfo("ownerUserCode").val(UserCode[0]);
					accountCtrl.getInfo("ownerUserName").text(userName[0]);
				},
				
				userCodeDel : function(){
					accountCtrl.getInfo("ownerUserCode").val('');
					accountCtrl.getInfo("ownerUserName").text('');
				},
		
				corpCardSync : function(){
					$.ajax({
						url	: "/account/corpCard/corpCardSync.do",
						type: "POST",
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_syncComp' />");	//동기화되었습니다
								CorpCard.searchList('N');
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
					var cardNo = accountCtrl.getInfo("cardNo").val();
						cardNo = getNumOnly(cardNo);
						accountCtrl.getInfo("cardNo").val(cardNo);
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
				},
				
				templateDownload : function() {
					location.href = "/account/corpCard/downloadTemplateFile.do";
				},
				
				excelUpload : function() {
					var popupID		= "CorpCardExcelPopup";
					var openerID	= "CorpCard";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_card' />"; //법인카드 사용내역
					var popupYN		= "N";
					var callBack	= "corpCardExcelPopup_CallBack";
					var popupUrl	= "/account/corpCard/CorpCardExcelPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack;
					
					Common.open("", popupID, popupTit, popupUrl, "500px", "220px", "iframe", true, null, null, true);
				},
				
				corpCardExcelPopup_CallBack : function(){
					var me = this;
					me.searchList();
				}
		}
		window.CorpCard = CorpCard;
	})(window);
	
</script>