<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
.pad10 { padding:10px;}
</style>
<body>
	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<h2 id="headerTitle" class="title"></h2>		
		
		<!-- 담당업무함을 사용자가 지정할 수 있도록 함. -->
		<div class="account_select_wrap">
			<span id="simpCardApp_chargeJobList" class="selectType02 size233" name="SimpCardAppInputField" tag="ChargeJob"></span>
		</div>							
	</div>
	<!-- 상단 버튼 시작 -->
	<div class="cRConTop">
		<div class="cRTopButtons">
			<a href="#" class="btnTypeDefault btnTypeChk" onClick="SimpleCorpCardApplication.simpCardApp_onSave('S')"  name="saveBtn">
				<!-- 신청 -->
				<spring:message code="Cache.ACC_btn_application"/>
			</a>
			<a href="#" class="btnTypeDefault" onClick="SimpleCorpCardApplication.simpCardApp_onSave('T')"  name="saveBtn">
				<!-- 임시저장 -->
				<spring:message code="Cache.ACC_btn_tempSave"/>
			</a>
			<a href="#" class="btnTypeDefault" onClick="SimpleCorpCardApplication.simpCardApp_onSave('E')"  name="afterSaveBtn" style="display:none">
				<!-- 저장 -->
				<spring:message code="Cache.ACC_btn_save"/>
			</a>					
			<a href="#" class="btnTypeDefault" onclick="SimpleCorpCardApplication.simpCardApp_showPreview()" name="previewBtn" style="display:none">
				<!-- 미리보기 -->
				<spring:message code="Cache.btn_preview"/>
			</a>
		</div>
	</div>
	<!-- 상단 버튼 끝 -->
	<div class="total_acooungting">						
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="allMakeView">
				<div class="inpStyle01 allMakeTitle">
					<input type="text" class="inpStyle01 HtmlCheckXSS ScriptCheckXSS" id="simpCardApp_ApplicationTitle" name="SimpCardAppInputField"
						onkeyup="SimpleCorpCardApplication.simpCardApp_setModified(true);"
						tag="ApplicationTitle" placeholder="<spring:message code='Cache.ACC_msg_noTitle'/>">	<!-- 제목을 입력하세요 -->
					<input type="hidden" id="simpCardApp_isSearched" name="SimpCardAppInputField" tag="isSearched">
					<input type="hidden" id="simpCardApp_isNew"  name="SimpCardAppInputField" tag="isNew">
					<input type="hidden" id="simpCardApp_ExpAppID"  name="SimpCardAppInputField" tag="ExpenceApplicationID">
					<input type="hidden" id="simpCardApp_PropertyBudget" name="SimpCardAppInputField" tag="Budget">
				</div>
			</div>
			<p class="eaccounting_name">
				<!-- 신청자 -->
				<strong><spring:message code="Cache.ACC_lbl_applicator"/> :</strong> 
				<label id="simpCardApp_lblApplicator"></label>
			</p>
			<div class="eaccountingCont_in">
				<div class="inStyleSetting">	
					<div class="total_acooungting_wrap" id="simpCardApp_TotalWrap">
						<table class="total_table">
							<thead>
								<tr>
									<th>
										<!-- 증빙총액 -->
										<spring:message code='Cache.ACC_lbl_eviTotalAmt'/>
									</th>
									<th>
										<!-- 청구금액 -->
										<spring:message code='Cache.ACC_billReqAmt'/>
									</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td>
										<!-- 원 -->
										<span class="tx_ta" name="simpCardApp_lblTotalAmt">0</span><spring:message code='Cache.ACC_krw'/>
									</td>
									<td>
										<span class="tx_ta" name="simpCardApp_lblBillReqAmt">0</span><spring:message code='Cache.ACC_krw'/>
									</td>
								</tr>
							</tbody>
						</table>
						<input type="hidden" id="simpCardApp_ExpAppTotamAmt"  name="SimpCardAppInputField" tag="TotalAmt">
						<input type="hidden" id="simpCardApp_ExpAppReqAmt"  name="SimpCardAppInputField" tag="ReqAmt">
					</div>	
					<div class="total_acooungting_info_wrap">
						<ul class="total_acooungting_info">
							<li>
								<dl>
									<!-- 코스트센터 -->
									<dt><spring:message code='Cache.ACC_lbl_costCenter'/> :</dt>
									<dd>
										<label id="simpCardApp_CCLabel"  name="SimpCardAppInputField" tag="CostCenterName"></label>
										<a href="#" class="btn_search" onclick="SimpleCorpCardApplication.simpCardApp_onCCSearch()"></a>
									</dd>
									<input type="hidden"  id="simpCardApp_CCCode" name="SimpCardAppInputField" tag="CostCenterCode">
								</dl>
							</li>
						</ul>
					</div>
					<div class="card_ea_wrap">
						<div class="card_ea_left">
							<div class="card_ea_left_top">
								<div class="dateSel type02">	
										
									<div id="simpCardApp_dateArea" class="dateSel type02" name="searchParam" fieldtype="Date"
										stfield="simpCardApp_dateArea_St" edfield="simpCardApp_dateArea_Ed" 
										stdatafield="UseDateSt" eddatafield="UseDateEd">
									</div>				
								</div>
								<div class="card_ea_left_select">
									<select class="selectType02" name="simpCardApp_cardSearchListCount">
										<option>15</option>
										<option>30</option>
										<option>45</option>
										<option>60</option>
									</select>
								</div>
							</div>
							<div class="card_ea_left_cont">
								<ul class="card_ea_left_cont_list" id="simpCardApp_CardInfoListArea" name="simpCardApp_CardInfoListArea">
								</ul>												
							</div>
							<!-- 페이징 시작 -->
							<div class="table_paging_wrap">									
								<div class="table_paging">
									<input type="button" class="paging_begin" onclick="SimpleCorpCardApplication.simpCardApp_onCardListPageSearch('First')">
									<input type="button" class="paging_prev"  onclick="SimpleCorpCardApplication.simpCardApp_onCardListPageSearch('Past')">
									<div class="goPage">
										<input type="text" name="simpCardApp_cardListPageNo">
										/ <span name="simpCardApp_cardListPageCount"></span>
										<input type="hidden" name="simpCardApp_cardListPageCountVal">
										<a href="#" class="btnGo" onclick="SimpleCorpCardApplication.simpCardApp_onCardListPageSearch('Go')">go</a>
									</div>
									<input type="button" class="paging_next" onclick="SimpleCorpCardApplication.simpCardApp_onCardListPageSearch('Next')">
									<input type="button" class="paging_end"  onclick="SimpleCorpCardApplication.simpCardApp_onCardListPageSearch('Last')">
								</div>					
								<div class="table_Status">
									<b name="simpCardApp_cardListCount"></b> <spring:message code='Cache.ACC_lbl_count'/>	<!-- 개 -->
								</div>
							</div>
							<!-- 페이징 끝 -->
						</div>
						<div class="card_ea_btn_wrap"  name="simpCardApp_AddBtnArea" style="width: 150px;">
						</div>
						<div class="card_ea_right" style="width: calc(100% - 450px);">
							<div class="card_ea_right_top">
								<!-- 법인카드 신청 내역 -->
								<p class="card_ea_right_title"><spring:message code='Cache.ACC_lbl_corpCardApplicationList'/></p>
								<div class="pagingType02 buttonStyleBoxRight">
									<a class="btnTypeDefault" href="#" onclick="SimpleCorpCardApplication.simpCardApp_deleteAddedItem()"><spring:message code='Cache.ACC_btn_delete'/></a>
								</div>
							</div>
							<div class="card_ea_right_cont">
								<ul class="card_ea_right_list" name="simpCardApp_AddListArea">
									
								</ul>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div name="simpCardApp_hiddenViewForm" style="display:none"></div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
</body>	
<script>


if (!window.SimpleCorpCardApplication) {
	window.SimpleCorpCardApplication = {};
}


(function(window) {
	var isUseIO = Common.getBaseConfig("IsUseIO");
	var isUseSB = Common.getBaseConfig("IsUseStandardBrief");
	var isUseBD = accountCtrl.getInfo("simpCardApp_PropertyBudget").val();
	
	var SimpleCorpCardApplication = {			
			pageOpenerIDStr : "openerID=SimpleCorpCardApplication&",
			KeyField : "ReceiptID",

			//좌측 카드 사용내역목록
			pageCardInfoList : [],
			//추가된 카드 목록
			pageCardAddList : [],
			//삭제할 카드 목록
			pageCardAddDeleted : [],
			//페이지 데이터 오브젝트
			pageSimpCardAppData : {},
			//카드 사용내역 정보
			pageCardInfoMap : {},
			//추가한 카드내역 맵
			pageCardAddMap : {},
			pageSimpCardFormList : { CardInfoForm : "",
										CardAddForm : "",
										CardViewForm : "",
										DivForm : "",
										},
			pageSimpCardComboData : {},
			tempVal : {},
			pageInfo : {},
			dataModified : false,
			openParam : {},
			
			pageInit : function(inputParam) {
				var me = this;
				setHeaderTitle('headerTitle');
				
				if(inputParam != null){
					me.openParam = inputParam;
				}

				var isSearch = "";
				var ExpAppId = "";
				if(inputParam != null){

					isSearch =inputParam.isSearch
					ExpAppId = inputParam.ExpAppId
				}
				makeDatepicker('simpCardApp_dateArea', 'simpCardApp_dateArea_St', 'simpCardApp_dateArea_Ed', null, null, 100);
				me.simpCardApp_fomInit();
				me.simpCardApp_onComboDataLoad();
				accComm.setDeadlineInfo();
				setPropertySearchType('Budget','SimpCardApp_PropertyBudget'); //예산관리 사용여부
				
				if(isSearch !="Y"){
					me.simpCardApp_setNew();
				}
				else{
					if(ExpAppId != null){
						me.simpCardApp_searchData(ExpAppId);
					}
				}

				me.setSelectCombo();
			},
			pageView : function(inputParam) {
				var me = this;
				if(inputParam != null){
					$.extend(me.openParam, inputParam);
				}

				var openType = "";
				var isSearch = "";
				var ExpAppId = "";

				accountCtrl.refreshAXSelect("simpCardApp_chargeJobList");

				if(inputParam != null){

					openType =inputParam.name
					isSearch =inputParam.isSearch
					ExpAppId = inputParam.ExpAppId
				}
				//탭이동일시 아무작업 안함
				if(openType == "tapDivTitle"){
					return;
				}
				
				//새로작성이면 작업 물어보고 
				else if(openType=="LeftSub"){

					if(me.dataModified){
						Common.Confirm("<spring:message code='Cache.ACC_msg_initDataCk' />", "Confirmation Dialog", function(result){	//작업중인 내용이 있습니다. 작업중인 내용을 지우고 새로 작성하시겠습니까?
							if(result){
								me.simpCardApp_setNew();
								
							}
						});
					}
					else{
						me.simpCardApp_setNew();
					}
				}
				else if(openType=="search"){
					if(ExpAppId != null){
						me.simpCardApp_dataInit();
						me.simpCardApp_searchData(ExpAppId);
					}
				}

			},
			
			//폼 데이터 세팅
			simpCardApp_fomInit : function() {
				var me = this;
				var formPath = Common.getBaseConfig("AccountApplicationFormPath");

				$.ajaxSetup({async:false});
				
				$.get(formPath + "SimpleCorpCardApplication_CardInfoForm.html" + resourceVersion, function(val){
					me.pageSimpCardFormList.CardInfoForm = val;
					me.simpCardApp_cardInfoCall();
				});
				$.get(formPath + "SimpleCorpCardApplication_CardAddForm.html" + resourceVersion, function(val){
					me.pageSimpCardFormList.CardAddForm = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_CorpCard_Apv.html" + resourceVersion, function(val){
					me.pageSimpCardFormList.CardViewForm = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_Div_Apv.html" + resourceVersion, function(val){
					me.pageSimpCardFormList.DivForm = val;
				});
			},
 	
			//폼에 세팅할 콤보 데이터 조회
			simpCardApp_onComboDataLoad : function() {
				var me = this;
				$.ajax({
					type:"POST",
						url:"/account/expenceApplication/getBriefCombo.do",
					data:{
						"isSimp": "Y"
					},
					success:function (data) {
						if(data.result == "ok"){
							me.pageSimpCardComboData.BriefList = data.list
							me.simpCardApp_makeCodeMap(data.list, "Brief", "StandardBriefID");
							me.simpCardApp_makeBtnArea();
							me.simpCardApp_FormComboInit();
						}
						else{
							//Common.Error("===ERR-1==<br>"+data.message);
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						//Common.Error("===ERR-2==<br>"+error.message);
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},

			//화면 데이터 초기화
			simpCardApp_dataInit : function() {
				var me = this;

				me.simpCardApp_setModified(false);

				me.pageSimpCardAppData = {}
				me.pageCardInfoList = []
				me.pageCardInfoMap = {}
				me.pageCardAddList = []
				me.pageCardAddDeleted = [];
				me.pageCardAddMap = {}

				if(me.pageSimpCardFormList.CardInfoForm != null){
					me.simpCardApp_cardInfoCall();
				}
				var fieldList =  accountCtrl.getInfoName("SimpCardAppInputField");
			   	for(var i=0;i<fieldList.length; i++){
			   		var field = fieldList[i];
			   		var tag = field.getAttribute("tag")
			   		
					var fieldType = field.tagName;
					if(fieldType=="INPUT"){
						field.value = "";
					} else if(fieldType=="LABEL"){
						field.innerHTML = "";
					}
			   	}
				
				me.simpCardApp_PageAmtSet();
			   	accountCtrl.getInfo("simpCardApp_lblApplicator").html(Common.getSession().USERNAME);
				accountCtrl.getInfoName("simpCardApp_AddListArea").html("");
			},

			//신규생성 화면으로 세팅
			simpCardApp_setNew : function() {
				var me = this;
				me.simpCardApp_dataInit()
				accountCtrl.getInfoStr("[name=SimpCardAppInputField][tag=isSearched]").val("N");
				accountCtrl.getInfoStr("[name=SimpCardAppInputField][tag=isNew]").val("Y");
				accountCtrl.getInfoName("saveBtn").css("display","");
				accountCtrl.getInfoName("afterSaveBtn").css("display","none");

				me.simpCardApp_cardInfoCall();
				$.ajax({
					url:"/account/expenceApplication/getUserCC.do",
					cache: false,
					data:{
					},
					success:function (data) {
						
						if(data.result == "ok"){
							var getData = data.CCInfo;
							if(getData != null){
							var labelField = accountCtrl.getInfoStr("[name=SimpCardAppInputField][tag=CostCenterName]");
							var cdField = accountCtrl.getInfoStr("[name=SimpCardAppInputField][tag=CostCenterCode]");
							labelField.html(getData.CostCenterName);
							cdField.val(getData.CostCenterCode);
						}
						}
						else{
							//Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					},
					error:function (error){
						//Common.Error("<spring:message code='Cache.ACC_msg_error' />");
					}
				});
			},

			//상세조회
			simpCardApp_searchData : function(ExpenceApplicationID) {
				var me = this;
				
				me.simpCardApp_dataInit();
				$.ajax({
					url:"/account/expenceApplication/searchExpenceApplication.do",
					cache: false,
					data:{
						ExpenceApplicationID : ExpenceApplicationID
					},
					success:function (data) {
						
						if(data.result == "ok"){
							var getData = data.data

							me.pageCardAddList =getData.pageExpenceAppEvidList;
							me.pageSimpCardAppData = getData;
							//setFieldData("comCostApp_ApplicationTitle", pageExpenceAppObj.ApplicationTitle );
							
							var fieldList =  accountCtrl.getInfoName("SimpCardAppInputField");
						   	for(var i=0;i<fieldList.length; i++){
						   		var field = fieldList[i];
						   		var tag = field.getAttribute("tag")
								var fieldType = field.tagName;
								if(fieldType=="INPUT"){
							   		field.value = nullToBlank(me.pageSimpCardAppData[tag]);
								} else if(fieldType=="LABEL"){
							   		field.innerHTML = nullToBlank(me.pageSimpCardAppData[tag]);
								}
						   	}
						   	accountCtrl.getInfo("simpCardApp_lblApplicator").html(me.pageSimpCardAppData["RegisterName"]);
							accountCtrl.getInfoStr("[name=SimpCardAppInputField][tag=isSearched]").val("Y");
							accountCtrl.getInfoStr("[name=SimpCardAppInputField][tag=isNew]").val("N");

							for(var i = 0; i<me.pageCardAddList.length; i++){
								var item = me.pageCardAddList[i];
								if(item.divList != null){
									item = $.extend(item, item.divList[0]);
								}
								me.pageCardAddMap[item.ReceiptID] = item;
							}
							
							me.simpCardApp_makeCardAddHTMLAll();
							me.simpCardApp_cardInfoCall();
							me.simpCardApp_makeViewForm();
							me.simpCardApp_PageAmtSet();

							if(me.openParam.isReview == "Y"){
								accountCtrl.getInfoName("saveBtn").css("display","none");
								accountCtrl.getInfoName("afterSaveBtn").css("display","");
							}
							else if(getData.ApplicationStatus != "T"){
								accountCtrl.getInfoName("saveBtn").css("display","none");
								accountCtrl.getInfoName("afterSaveBtn").css("display","none");
							}
							
							if(me.tempVal.saveType=="S"){
								var saveData = me.tempVal.saveData;
								me.tempVal = {};
								me.simpCardApp_AutoDraft(me.pageSimpCardAppData, ExpenceApplicationID);
							}else if(me.tempVal.saveType=="E"){
								me.tempVal = {};
								me.simpCardApp_ChangeBodyContext(me.pageSimpCardAppData);
							}

							me.simpCardApp_setModified(false);
						}
						else{
							//Common.Error("===ERR-5==<br>"+data.message);
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					},
					error:function (error){
						//Common.Error("===ERR-6==<br>"+error.message);
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");
					}
				});
			},
			
			//html 폼 생성
			simpCardApp_makeCardAddHTMLAll : function(){
				var me = this;
				
				for(var i = 0; i<me.pageCardAddList.length; i++){
					var getItem = me.pageCardAddList[i]
					me.simpCardApp_makeCardAddHTML(getItem);
				}
			},
			simpCardApp_makeCodeMap : function(List, name, dataField, labelField) {
				var me = this;
				if(List != null){
					//var evalStr = "me.pageSimpCardComboData['"+name+"Map'] = {}";
					//eval(evalStr);
					me.pageSimpCardComboData[name+"Map"] = {};
					for(var i = 0; i<List.length; i++){
						var item = List[i];
						//pageSimpCardComboData
						//evalStr = "me.pageSimpCardComboData['"+name+"Map'][item[dataField]] = item";
						//eval(evalStr);
						me.pageSimpCardComboData[name+"Map"][item[dataField]] = item;
					}
				}
			},
			//폼의 콤보데이터 초기화
			simpCardApp_FormComboInit : function(){
				var me = this
				for(var formNm in me.pageSimpCardFormList){
					var formStr = me.pageSimpCardFormList[formNm]

					BriefStr = me.simpCardApp_ComboDataMake(me.pageSimpCardComboData.BriefList, "StandardBriefID", "StandardBriefName");
					formStr = formStr.replace("@@{BriefOptions}", BriefStr);
					
					me.pageSimpCardFormList[formNm] = formStr
				}
			},
			simpCardApp_ComboDataMake : function(cdList, codeField, nameField) {
				if(codeField==null){
					codeField="Code"
				}
				if(nameField==null){
					nameField="CodeName"
				}
				var htmlStr = "<option value=''>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";	//선택
				for(var i = 0; i<cdList.length; i++){
					var getCd = cdList[i];
					if(getCd.IsUse == "Y"
						||getCd.IsUse == null){
						htmlStr = htmlStr + "<option value='"+ getCd[codeField] +"'>"+ getCd[nameField] +"</option>"
					}
				}
				return htmlStr;
			},
			
			//추가할 수 있는 카드목록 조회
			simpCardApp_cardInfoCall : function() {
				var me = this;
				var pageSize = accountCtrl.getInfoName("simpCardApp_cardSearchListCount").val();
				var pageNo = accountCtrl.getInfoName("simpCardApp_cardListPageNo").val();
				var pageCount = accountCtrl.getInfoName("simpCardApp_cardListPageCountVal").val();
				
				var stDt = accountCtrl.getInfo("simpCardApp_dateArea_St").val();
				var edDt = accountCtrl.getInfo("simpCardApp_dateArea_Ed").val();
				stDt = stDt.replaceAll(".", "");
				edDt = edDt.replaceAll(".", "");
				
				if(ckNaN(pageNo) > ckNaN(pageCount)){
					pageNo = ckNaN(pageCount);
					accountCtrl.getInfoName("simpCardApp_cardListPageNo").val(pageNo);
				}
				if(isEmptyStr(pageNo)
						|| ckNaN(pageNo) <1){
					pageNo = 1;
					accountCtrl.getInfoName("simpCardApp_cardListPageNo").val(1);
				}

				var addPageList = "";
				for(var i = 0; i<me.pageCardAddList.length; i++){
					var item = me.pageCardAddList[i];
					if(addPageList == ""){
						addPageList = item.ReceiptID;
					}else{
						addPageList = addPageList+","+item.ReceiptID;
					}
				}
				var ExpAppId = accountCtrl.getInfoStr("[name=SimpCardAppInputField][tag=ExpenceApplicationID]").val();
				
				$.ajax({
					type:"POST",
						url:"/account/expenceApplication/getSimpCardInfoList.do",
					data:{
						pageNo:pageNo,
						pageSize:pageSize,
						formStr:me.pageSimpCardFormList.CardInfoForm,
						ExpenceApplicationID : ExpAppId,
						addPageList : addPageList,
						StartDate : stDt,
						EndDate : edDt
					},
					success:function (data) {
						
						if(data.result == "ok"){
							var getStr = data.formStr
							var list = data.list
							var infoMap = data.infoMap
							var page = data.page
							me.simpCardApp_setListPageInfo(page);
							
							me.pageCardInfoList = list;
							me.pageCardInfoMap = infoMap;
							me.simpCardApp_makeCardInfoHTML(list);
						}
						else{
							//Common.Error("===ERR-7==<br>"+data.message);
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						//Common.Error("===ERR-8==<br>"+error.message);
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");
					}
				});
			},
			
			//카드 정보 html 생성
			simpCardApp_makeCardInfoHTML : function(inputList){
				var me = this;

				var arrCk = Array.isArray(inputList);
				if(!arrCk){
					return;
				}
				accountCtrl.getInfoName("simpCardApp_CardInfoListArea").html("");
				var formStr = me.pageSimpCardFormList.CardInfoForm;
				for(var i = 0; i<inputList.length; i++){
					var item = inputList[i];

					var valMap = {
							KeyNo : nullToBlank(item.ReceiptID),
							TotalAmount : toAmtFormat(nullToBlank(item.TotalAmount)),
							ProofDate : nullToBlank(item.ProofDate),
							ProofDateStr : nullToBlank(item.ProofDateStr),
							ProofTime : nullToBlank(item.ProofTime),
							ProofTimeStr : nullToBlank(item.ProofTimeStr),
							ReceiptID : nullToBlank(item.ReceiptID),
							StoreName : nullToBlank(item.StoreName).trim(),
					}
					var getForm = me.simpCardApp_htmlFormSetVal(formStr, valMap);
					getForm = me.simpCardApp_htmlFormDicTrans(getForm);

					getForm = me.simpCardApp_htmlFormDicTrans(getForm)
					accountCtrl.getInfoName("simpCardApp_CardInfoListArea").append(getForm);
				}
			},
			
			//페이징 처리
			simpCardApp_setListPageInfo : function(page){
				var me = this;
				accountCtrl.getInfoName("simpCardApp_cardListCount").html(page.listCount);
				accountCtrl.getInfoName("simpCardApp_cardListPageCount").html(page.pageCount);
				
				accountCtrl.getInfoName("simpCardApp_cardListPageCountVal").val(page.pageCount);
				accountCtrl.getInfoName("simpCardApp_cardListPageNo").val(page.pageNo);
			},
			
			//페이지 조회
			simpCardApp_onCardListPageSearch : function(type){
				var me = this;
				var pageNo = accountCtrl.getInfoName("simpCardApp_cardListPageNo").val();
				pageNo = ckNaN(pageNo);
				
				var pageCount = accountCtrl.getInfoName("simpCardApp_cardListPageCountVal").val();
				pageCount = ckNaN(pageCount);
				
				if(type=="Next"){
					if(pageNo < pageCount){
						pageNo ++ ;
					}
					else{
						pageNo = pageCount;
					}
				}else if(type=="Past"){
					pageNo --;
				}else if(type=="Last"){
					pageNo = pageCount;
				}else if(type=="First"){
					pageNo = 1;
				}
				accountCtrl.getInfoName("simpCardApp_cardListPageNo").val(pageNo);
				me.simpCardApp_cardInfoCall();
			},
			
			//조회된 카드사용내역 클릭 이벤트
			simpCardApp_cardInfoClick  : function(obj, ReceiptID){
				var me = this;

				var checkField = accountCtrl.getInfoName("simpCardApp_cardInfoCheck_"+ReceiptID);
				var checked = checkField.is(":checked");
				if(checked){
					checkField[0].checked = false;
				}else{
					checkField[0].checked = true;
				}
			},
			
			//표준적요 버튼목록 생성
			simpCardApp_makeBtnArea : function(){
				var me = this;
				var list = me.pageSimpCardComboData.BriefList;
				var btnStr = '<a href="#" class="card_ea_btn" onclick="SimpleCorpCardApplication.simpCardApp_cardInfoAdd(\'@@{id}\')">'
						+ '<span>@@{label}</span></a>\n';
				var setStr = "";
				for(var i = 0; i<list.length; i++){
					var item = list[i];
					var str = btnStr.replaceAll("@@{id}", item.StandardBriefID)
					str = str.replaceAll("@@{label}", item.StandardBriefName)
					//setStr = setStr + str;
					accountCtrl.getInfoName("simpCardApp_AddBtnArea").append(str);
				}
			},
			
			//증빙내역 추가
			simpCardApp_cardInfoAdd : function(StandardBriefID){
				var me = this;
				me.simpCardApp_setModified(true);
				
				var checkedList = accountCtrl.getInfoStr("[tag=cardInfoCheck]:checked");
				var addList = [];
				for(var i = 0; i<checkedList.length; i++){
					var checkedItem = checkedList[i];
					var getId = checkedItem.getAttribute("keyno");
					if(me.pageCardAddMap[getId] == null){
						var getItem = me.pageCardInfoMap[getId];
						
						if(getItem.isIF=="Y"){
							var copyObj = objCopy(getItem);
							getItem.oriIFData = copyObj;
						}
						
						getItem.StandardBriefID = StandardBriefID;
						
						me.simpCardApp_BriefValSet( getItem.ReceiptID, StandardBriefID);
						var amtVal = getItem.Amount;
						if(amtVal == null){
							amtVal = getItem.TotalAmount;
							getItem.Amount = getItem.TotalAmount;
						}
						me.pageCardAddMap[getItem.ReceiptID] = getItem;
						me.pageCardAddList.push(getItem);
						addList.push(getItem);
						me.simpCardApp_makeCardAddHTML(getItem, StandardBriefID);

						if(getItem.ExpenceApplicationListID != null){
							var idx = accFindIdx(me.pageCardAddDeleted, "ExpenceApplicationListID", getItem.ExpenceApplicationListID );
							if(idx>=0){
								me.pageCardAddDeleted.splice(idx,1);
							}
						}
						
					}
				}

//				me.simpCardApp_onSaveBackground("ADD", addList);
				me.simpCardApp_cardInfoCall();
				me.simpCardApp_PageAmtSet();
			},
			
			//증빙내역 html 생성
			simpCardApp_makeCardAddHTML : function(inputItem, inputBriefID ){
				var me = this;
				var formStr = me.pageSimpCardFormList.CardAddForm;
				
				var valMap = {
						KeyNo : nullToBlank(inputItem.ReceiptID),
						TotalAmount : toAmtFormat(inputItem.TotalAmount),
						ProofDateStr : nullToBlank(inputItem.ProofDateStr),
						ProofTimeStr : nullToBlank(inputItem.ProofTimeStr),
						StoreName : nullToBlank(inputItem.StoreName).trim(),
						ReceiptID : nullToBlank(inputItem.ReceiptID),
						CardApproveNo : nullToBlank(inputItem.CardApproveNo),
						AmountVal : toAmtFormat(inputItem.Amount),
						UsageCommentVal : nullToBlank(inputItem.UsageComment),
				}
				var getForm = me.simpCardApp_htmlFormSetVal(formStr, valMap);
				getForm = me.simpCardApp_htmlFormDicTrans(getForm);

				accountCtrl.getInfoName("simpCardApp_AddListArea").append(getForm);
				if(inputBriefID == null){
					inputBriefID = inputItem.StandardBriefID;
				}
				
				me.simpCardApp_BriefValSet( inputItem.ReceiptID, inputBriefID);
			},
			
			//증빙내역 삭제
			simpCardApp_deleteAddedItem : function(){
				var me = this;

				var checkedList = accountCtrl.getInfoStr("[tag=cardAddCheck]:checked");
				if(checkedList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");	//선택된 항목이 없습니다.
					return;
				}

		        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//삭제하시겠습니까?
		       		if(result){

						me.simpCardApp_setModified(true);

						//var delList = [];
						for(var i = 0; i<checkedList.length; i++){
							var checkedItem = checkedList[i];
							var targetNm = checkedItem.getAttribute("targetnm");
							var KeyNo = checkedItem.getAttribute("keyno");
							
							accountCtrl.getInfoName(targetNm).remove();
							var getItem = me.pageCardAddMap[KeyNo];

							if(getItem.ExpenceApplicationListID != null){
								me.pageCardAddDeleted.push(me.pageCardAddMap[KeyNo]);
								//delList.push(me.pageCardAddMap[KeyNo]);
							}
							delete me.pageCardAddMap[KeyNo]
							var idx = accFindIdx(me.pageCardAddList, "ReceiptID", KeyNo );
							
							if(idx>=0){
								me.pageCardAddList.splice(idx,1);
							}
						}
//						me.simpCardApp_onSaveBackground("DEL", delList);
						me.simpCardApp_PageAmtSet();
						me.simpCardApp_cardInfoCall();
		       		}
		        });
			},

			simpCardApp_onCCSearch : function(){
				var me = this;
				var popupID		=	"ccSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_costCenter'/>";	//코스트센터
				var popupName	=	"CostCenterSearchPopup";
				var callBack	=	"simpCardApp_SetCCVal";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"popupType="	+ (Common.getBaseConfig("IsUseIO") == "Y" ? "CC" : "") + 	"&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"600px","730px","iframe",true,null,null,true);
			},
			simpCardApp_SetCCVal : function(value){
				var me = this;
				if(value != null){
					me.simpCardApp_setModified(true);
					var labelField = accountCtrl.getInfoStr("[name=SimpCardAppInputField][tag=CostCenterName]");
					var cdField = accountCtrl.getInfoStr("[name=SimpCardAppInputField][tag=CostCenterCode]");
					labelField.html(value.CostCenterName);
					cdField.val(value.CostCenterCode);
				}
			},
			simpCardApp_ComboChange : function(obj, type, KeyNo) {
				var me = this;
				var val = obj.value;

				var pageList = me.pageCardAddList;
				
				for(var i = 0; i<pageList.length; i++){
					var item = pageList[i]
					if(item[me.KeyField] == KeyNo){
						item[type] = val;
						me.pageCardAddMap[KeyNo] = $.extend({}, item);
					}
				}

				if(type=="StandardBriefID"){
					
					me.simpCardApp_BriefValSet( KeyNo, val)
				}
			},

			simpCardApp_CallBriefPopup : function(KeyNo){
				var me = this;
				me.tempVal.KeyNo = KeyNo
				var popupID		=	"standardBriefSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_standardBrief'/>";	//표준적요
				var popupName	=	"StandardBriefSearchPopup";
				var callBack	=	"simpCardApp_SetBriefVal";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"1000px","700px","iframe",true,null,null,true);
			},
			simpCardApp_SetBriefVal : function(info){
				var me = this;
				var KeyNo = me.tempVal.KeyNo;
				var val = info.StandardBriefID;
				
				me.simpCardApp_BriefValSet(KeyNo, val)
			},
			simpCardApp_BriefValSet : function(KeyNo, StandardBriefID) {
				var me = this;
				me.simpCardApp_setModified(true);
				
				var pageList = me.pageCardAddList;

				var BriefMap = me.pageSimpCardComboData.BriefMap
				var getMap = BriefMap[StandardBriefID];
				if(getMap==null){
					getMap = {};
				}
				for(var i = 0; i<pageList.length; i++){
					var item = pageList[i]
					if(item[me.KeyField] == KeyNo){
						item["StandardBriefID"] = StandardBriefID;
						item["StandardBriefName"] = nullToBlank(getMap.StandardBriefName);

						item['TaxType'] = nullToBlank(getMap.TaxType);
						item['TaxCode'] = nullToBlank(getMap.TaxCode);
						item['AccountCode'] = nullToBlank(getMap.AccountCode);
						item['AccountName'] = nullToBlank(getMap.AccountName);
						item['StandardBriefDesc'] = nullToBlank(getMap.StandardBriefDesc);
						accountCtrl.getInfoStr("[name=BriefDecField][keyno="+KeyNo+"]").html(nullToBlank(getMap.StandardBriefDesc));
						if(nullToBlank(getMap.StandardBriefDesc) != '') {
							accountCtrl.getInfoStr("[name=BriefDecField][keyno="+KeyNo+"]").show();
						} else {
							accountCtrl.getInfoStr("[name=BriefDecField][keyno="+KeyNo+"]").hide();
						}
						accountCtrl.getInfoStr("[name=BriefSelectField][keyno="+KeyNo+"]").val(StandardBriefID);

						me.pageCardAddMap[KeyNo] = $.extend({}, item);
					}
				}
				
			}, 

			//필드 데이터값 획득
			simpCardApp_getExpAppField : function(){
				var me = this;
				
				var fieldList = accountCtrl.getInfoName("SimpCardAppInputField");
				var pageInfo = {};
				for(var i = 0; i<fieldList.length; i++){
					var field = fieldList[i];
					var tag = field.getAttribute("tag");
					var fieldType = field.tagName;
					if(fieldType=="INPUT"){
						pageInfo[tag] = field.value;
					} else if(fieldType=="LABEL"){
						pageInfo[tag] = field.innerHTML;
					}
				}
				var pageEvidList = me.pageCardAddList;
				
				me.pageExpenceAppEvidList = pageEvidList;
				pageInfo.pageExpenceAppEvidList = pageEvidList;
				pageInfo.pageExpenceAppEvidDeletedList = me.pageCardAddDeleted;
				

				pageInfo.ApplicationType 		= "SC";
				pageInfo.ApplicationStatus 		= "T";
				
				// 담당업무함을 사용자가 지정할 수 있도록 함.
				pageInfo.ChargeJob = accountCtrl.getComboInfo("simpCardApp_chargeJobList").val() + "@" + accountCtrl.getComboInfo("simpCardApp_chargeJobList").find("option:selected").text();
				
				me.pageSimpCardAppData = pageInfo;
				return pageInfo;
			},
			
			//데이터 저장
			simpCardApp_onSave : function(type){
				if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				
				var me = this;
				var getInfo = me.simpCardApp_getExpAppField();
				accComm.setDeadlineInfo();
				me.pageSimpCardAppData.saveType = type;

				if(type=="T"){
					me.pageSimpCardAppData.IsTempSave = "Y"
					me.pageSimpCardAppData.ApplicationStatus = 'T'
					me.tempVal.saveType="T";
				} else 	if(type=="E"){
					me.pageSimpCardAppData.IsTempSave = "Y"
					me.pageSimpCardAppData.ApplicationStatus = 'E'
					me.tempVal.saveType="E";
				} 
				else{
					me.pageSimpCardAppData.IsTempSave = "N"
					me.pageSimpCardAppData.ApplicationStatus = 'S'
					me.tempVal.saveType="S";
				}

				if(isEmptyStr(me.pageSimpCardAppData.ApplicationTitle)){
					Common.Inform("<spring:message code='Cache.ACC_msg_noTitle' />");	//제목을 입력해주세요.
					return;
				}
				if(me.pageSimpCardAppData.pageExpenceAppEvidList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noSaveData' />");	//저장할 데이터가 없습니다.
					return;
				}
				var totalAmt = ckNaN(accountCtrl.getInfoStr("[name=SimpCardAppInputField][tag=TotalAmt]").val());
				var reqAmt = ckNaN(accountCtrl.getInfoStr("[name=SimpCardAppInputField][tag=ReqAmt]").val());
				
				if(totalAmt< reqAmt){
					var msg = "<spring:message code='Cache.ACC_015' />";	//항목의 세부비용의 합계금액이 증빙금액보다 클 수 없습니다.
					Common.Inform(msg);
					return;
				}
				
				if(isEmptyStr(me.pageSimpCardAppData.CostCenterCode)){
					Common.Inform("<spring:message code='Cache.ACC_027' />");	// 코스트센터가 입력되지 않았습니다.
					return;
				}

				var valCk = false;
				var nanCk = false;
				var deadCk = false;
				var commCk = false;
				
			   	for(var i=0;i<me.pageCardAddList.length; i++){
			   		var evidItem = me.pageCardAddList[i]
			   		
			   		if(isEmptyStr(evidItem.AccountCode)
			   				||isEmptyStr(evidItem.StandardBriefName)){
			   			valCk = true;
						var msg = "<spring:message code='Cache.ACC_050' />";	//표준적요가 입력되지 않은 항목이 있습니다.
						Common.Inform(msg);
						return;
			   			break;
			   		}
			   		if(isEmptyStr(evidItem.UsageComment)){
			   			commCk = true;
						var msg = "<spring:message code='Cache.ACC_046' />";	//내역은 필수로 입력하여야 합니다.
						Common.Inform(msg);
						return;
			   			break;
			   		}
			   		
			   		// 마감일자 체크 주석처리
			   		/* if(accComm.accDeadlineCk(evidItem.ProofDate) == false){
			   			deadCk = true;
						var msg = "<spring:message code='Cache.ACC_044' />";	//경비 마감일이 넘긴 항목이 있습니다. 마감일은 @@{date}입니다.
						var deadline = accComm.getDeadlindDate();
						msg = msg.replace("@@{date}", deadline);
						Common.Inform(msg);
						return;
			   			break;
			   		} */
			   		
			   		var ckNaNVal = AmttoNumFormat(evidItem.Amount);
			   		caNaNVal = ckNaN(ckNaNVal);
			   		if(caNaNVal == 0){
			   			nanCk = true;
						var msg = "<spring:message code='Cache.ACC_lbl_amtValidateErr' />";	//청구금액이 0이거나 올바른 금액이 아닙니다.
						Common.Inform(msg);
						return;
			   			break;
			   		}

			   		var totalAmtVal = AmttoNumFormat(evidItem.TotalAmount);
			   		totalAmtVal = ckNaN(totalAmtVal);
			   		if(caNaNVal>totalAmtVal){
						var msg = "<spring:message code='Cache.ACC_051' />";	//청구금액은 증빙금액보다 작아야합니다.
						Common.Inform(msg);
						return;
			   			break;
			   		}
			   		
			   		evidItem.PostingDate = evidItem.ProofDate;
			   		evidItem.PostingDateStr = evidItem.ProofDateStr;
			   	}

			   	var msg = "<spring:message code='Cache.ACC_isSaveCk' />";	//저장하시겠습니까?
			   	if(type=="S"){
			   		msg = "<spring:message code='Cache.ACC_isAppCk' />";		//신청하시겠습니까?
			   	}
				Common.Confirm(msg, "Confirmation Dialog", function(result){
					if(result){
						me.simpCardApp_callExpAppSaveAjax(me.pageSimpCardAppData);
					}
				});
			},

			//자동저장기능 현재 미사용
			simpCardApp_onSaveBackground : function(){
				var me = this;
				var getInfo = me.simpCardApp_getExpAppField();
				
				//getInfosaveType = type;

				getInfo.IsTempSave = "Y";
				getInfo.ApplicationStatus = "T";
				//getInfo.ListOnly = "Y"
				
				me.simpCardApp_callExpAppSaveAjax(getInfo, true);
			},

			//저장로직 호출
			simpCardApp_callExpAppSaveAjax : function(data, isBK){
				var me = this;
				var ExpObj = data;
				$.ajax({
					type:"POST",
						url:"/account/expenceApplication/saveExpenceApplication.do",
					data:{
						saveObj : JSON.stringify(data),
					},
					success:function (data) {
						if(data.result == "ok"){
							
							var ExpAppID = data.getSavedKey;

							if(me.tempVal.saveType!="T"){
								me.tempVal.saveData = data;
							}
							else{
								Common.Inform("<spring:message code='Cache.ACC_msg_saveComp' />");	//저장되었습니다
							}
							me.simpCardApp_cardInfoCall();
							me.simpCardApp_searchData(ExpAppID);
							
						}
						else if(data.result == "D"){
							
							var duplObj = data.duplObj;
							var msg = "<spring:message code='Cache.ACC_msg_isExpAppDupl' />";	//이미 저장되어 있는 증빙이 추가되어있습니다.
							if(duplObj.CCCnt>0){
								msg = msg + "<br>" + "<spring:message code='Cache.ACC_lbl_CardApproNo' />";	//법인카드 승인번호
								msg = msg + " : " + duplObj.CCList
							}
							
							Common.Inform("<spring:message code='Cache.ACC_msg_isExpAppDupl' />");	//이미 저장되어 있는 증빙이 추가되었습니다.
						}
						else{
							//Common.Error("===ERR-9==<br>"+data.message);
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						//Common.Error("===ERR-10==<br>"+error.message);
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");
					}
				});
			},
			
			//법인카드 영수증 조회
			simpCardApp_cardAppClick  : function(ReceiptID){
				var me = this;
				accComm.accCardAppClick(ReceiptID, me.pageOpenerIDStr);
			},

			//입력창 변경시 이벤트
			simpCardApp_onInputFieldChange : function(obj, fieldNm) {
				var me = this; 
				me.simpCardApp_setModified(true);
				
				var getName = obj.name;
				var val = obj.value;
				var KeyNo = obj.getAttribute("keyno")

				me.simpCardApp_setFieldData(fieldNm, KeyNo, val);
				if(getName == "AmountField"
						||getName == "TotalAmountField"){
					val = val.replace(/[^0-9,.]/g, "");
					var numVal = ckNaN(AmttoNumFormat(val))
					if(numVal>99999999999){
						numVal = 99999999999;
					}
					val = Number(AmttoNumFormat(val))
					accountCtrl.getInfoStr("[name="+getName+"][keyno="+KeyNo+"]").val(toAmtFormat(numVal));
					if(getName=="TotalAmountField"){
						accountCtrl.getInfoStr("[name=AmountField][keyno="+KeyNo+"]").val(toAmtFormat(numVal));
					}
					me.simpCardApp_PageAmtSet();
				}
			},
			
			//필드에 값 세팅
			simpCardApp_setFieldData : function(fieldNm, KeyNo, Val){
				var me = this;
				var list = me.pageCardAddList;
				for(var i = 0; i<list.length; i++){
					var item = list[i];
					if(item[me.KeyField] == KeyNo){
						item[fieldNm] = Val;
						me.pageCardAddMap[KeyNo] = $.extend({}, item);
					}
				}
			},
			
			//합계금액 세팅
			simpCardApp_PageAmtSet : function() {
				var me= this;

				var toatalAmt = 0;
				var toatalReqAmt = 0;
				

				for(var i = 0; i<me.pageCardAddList.length; i++){
					var item = me.pageCardAddList[i];
					
					var itemTotalAmt = AmttoNumFormat(item.TotalAmount);
					var itemReqAmt = AmttoNumFormat(item.Amount);

					toatalAmt = toatalAmt + ckNaN(itemTotalAmt);
					toatalReqAmt = toatalReqAmt + ckNaN(itemReqAmt);
				}
				accountCtrl.getInfoName("simpCardApp_lblTotalAmt").html(toAmtFormat(toatalAmt));
				accountCtrl.getInfoName("simpCardApp_lblBillReqAmt").html(toAmtFormat(toatalReqAmt));

				accountCtrl.getInfoStr("[name=ExpAppInputField][tag=TotalAmt]").val(toatalAmt);
				accountCtrl.getInfoStr("[name=ExpAppInputField][tag=ReqAmt]").val(toatalReqAmt);
			},
			
			simpCardApp_htmlFormSetVal : function(inputStr, replaceMap){
				return accComm.accHtmlFormSetVal(inputStr, replaceMap);
			},
			simpCardApp_htmlFormDicTrans : function(inputStr){
				return accComm.accHtmlFormDicTrans(inputStr);
			},

			//결재용 뷰 폼 생성
			simpCardApp_makeViewForm : function (){
				var me = this;
				var proofCode = "";
				var tableStr = ""; 				

				accountCtrl.getInfoName("simpCardApp_hiddenViewForm").html("");
				accountCtrl.getInfoName("simpCardApp_hiddenViewForm").html($("#simpCardApp_TotalWrap")[0].outerHTML);
				
				for(var i = 0; i<me.pageCardAddList.length; i++){
					var getItem = me.pageCardAddList[i];

					var formStr = me.pageSimpCardFormList.CardViewForm;

					var addUsageComment = "";
					
					var divValMap = {
							AccountName : nullToBlank(getItem.AccountName),
							StandardBriefName : nullToBlank(getItem.StandardBriefName),
							CostCenterName : nullToBlank(getItem.CostCenterName),
							IOName : nullToBlank(getItem.IOName),
							UsageComment : nullToBlank(getItem.UsageComment),
							AddUsageComment : addUsageComment, //TODO: 부가적요 표시하기
							DivAmount : toAmtFormat(getItem.Amount)
					}
					var htmlDivFormStr = me.pageSimpCardFormList.DivForm;
					htmlDivFormStr = me.simpCardApp_htmlFormSetVal(htmlDivFormStr, divValMap);

					var valMap = {
							ViewKeyNo : nullToBlank(getItem.ViewKeyNo),
							ProofCode : nullToBlank(getItem.ProofCode),
							
							TotalAmount : toAmtFormat(nullToBlank(getItem.TotalAmount)),
							RepAmount : toAmtFormat(nullToBlank(getItem.RepAmount)),
							TaxAmount : toAmtFormat(nullToBlank(getItem.TaxAmount)),
							SupplyCost : nullToBlank(getItem.SupplyCost),
							Tax : nullToBlank(getItem.Tax),
							
							ProofDate : nullToBlank(getItem.ProofDateStr),
							PostingDate : nullToBlank(getItem.PostingDateStr),
							PayDate : nullToBlank(getItem.PayDateStr),
							ProofTime : nullToBlank(getItem.ProofTimeStr),
							
							StoreName : nullToBlank(getItem.StoreName).trim(),
							CardUID : nullToBlank(getItem.CardUID),
							CardApproveNo : nullToBlank(getItem.CardApproveNo),
							
							ReceiptID : nullToBlank(getItem.ReceiptID),
							
							TaxCodeNm : nullToBlank(getItem.TaxCodeName),
							TaxTypeNm : nullToBlank(getItem.TaxTypeName),
							
							VendorNo : nullToBlank(getItem.VendorNo),
							VendorName : nullToBlank(getItem.VendorName),
							
							pageNm : "SimpleCorpCardApplication",
					}
					valMap.rowNum = i+1;
					valMap.rowspan = 1;
					valMap.divApvArea = htmlDivFormStr;
					valMap.divApvArea2 = '';

					var getForm = me.simpCardApp_htmlFormSetVal(formStr, valMap);
					getForm = me.simpCardApp_htmlFormDicTrans(getForm);
					
					if(proofCode != getItem.ProofCode) {
						if(proofCode != "") {
							tableStr += '</tbody></table>';
						}
						proofCode = getItem.ProofCode;
						
						var title = Common.getDic('ACC_lbl_' + proofCode + 'UseInfo');
						tableStr += '<p class="taw_top_sub_title">'+title+'</p>'
									+ '<table class="acstatus_wrap">'
									+ '<tbody>'
									+ getForm
					} else {
						tableStr += getForm;
					}
				}

				accountCtrl.getInfoName("simpCardApp_hiddenViewForm").append(tableStr);
				
				proofCode = "";
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];
					
					if(proofCode != getItem.ProofCode) {
						proofCode = getItem.ProofCode;
					} else {
						accountCtrl.getInfoStr("tr[name=headerArea][viewkeyno="+getItem.ViewKeyNo+"]").remove();
					}
						
					me.simpCardApp_makeHtmlChkColspan(accountCtrl.getInfoStr("[name=evidItemAreaApv][viewkeyno="+getItem.ViewKeyNo+"]"));
					
					if((getItem.docList == null && getItem.fileList == null) 
							|| ((getItem.docList != null && getItem.docList.length == 0) && (getItem.fileList != null && getItem.fileList.length == 0))) {
						$("[name=fileDocAreaApv][viewkeyno=" + getItem.ViewKeyNo + "]").remove();
					} else {
						$("[name=evidItemAreaApv][viewkeyno=" + getItem.ViewKeyNo + "]").find("td").each(function(i, obj) { 
							if($(obj).attr("rowspan") != undefined) { 
								$(obj).attr("rowspan", Number($(obj).attr("rowspan"))+1) 
							} 
						});
						if(getItem.fileList != null){
							for(var y = 0; y < getItem.fileList.length; y++){
								var fileInfo = getItem.fileList[y];
								var str = 						
									"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;' onClick=\"SimpleCorpCardApplication.simpCardApp_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
									+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
									+"<a class='previewBtn' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accountFileCtrl.attachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "');\"></a>";
				
									var getStr = accountCtrl.getInfoStr("[name=FileViewArea][proofcode=CorpCard][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							}
						}
						
	
						if(getItem.uploadFileList != null){
							for(var y = 0; y < getItem.uploadFileList.length; y++){
								var fileInfo = getItem.uploadFileList[y];
								var str = 						
									"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;' >" + fileInfo.FileName  //onClick=\"SimpleCorpCardApplication.simpCardApp_FileDownload('"+fileInfo.SavedName+"','"+fileInfo.FileName+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
									+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>";
									
									var getStr = accountCtrl.getInfoStr("[name=FileViewArea][proofcode=CorpCard][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							}
						}
					}
				}
			},
			
			simpCardApp_makeHtmlChkColspan : function(divObj) {
				if(divObj == undefined)
					return;
				 
				if(isUseIO == "N"){
					$(divObj).find("[name=noIOArea]").remove();
					$(divObj).find("[name=accArea]").attr("rowspan", "2");
					/* $(divObj).find("[name=colIOSBArea]").attr("colspan", Number($(divObj).find("[name=colIOSBArea]").attr("colspan")) - 1);
					$(divObj).find("[name=FileViewArea]").attr("colspan", Number($(divObj).find("[name=FileViewArea]").attr("colspan")) - 1); */
				}
				if(isUseSB == "N") {
					$(divObj).find("[name=noSBArea]").remove();
					$(divObj).find("[name=ccArea]").attr("rowspan", "2");
					/* $(divObj).find("[name=colIOSBArea]").attr("colspan", Number($(divObj).find("[name=colIOSBArea]").attr("colspan")) - 1);
					$(divObj).find("[name=FileViewArea]").attr("colspan", Number($(divObj).find("[name=FileViewArea]").attr("colspan")) - 1); */
				}
			   	if(isUseBD == "" || isUseBD == "N") {
			   		$(divObj).find("[name=noBDArea]").remove();
					$(divObj).find("[name=slipArea]").attr("rowspan", "2");
			   		/* $(divObj).find("[name=colIOSBArea]").attr("colspan", Number($(divObj).find("[name=colIOSBArea]").attr("colspan")) - 1);
			   		$(divObj).find("[name=FileViewArea]").attr("colspan", Number($(divObj).find("[name=FileViewArea]").attr("colspan")) - 1); */
				}
			},			

			simpCardApp_FileDownload : function(SavedName, FileName, FileID){
				accountFileCtrl.downloadFile(SavedName, FileName, FileID)
			},
			
			//결재
			simpCardApp_AutoDraft : function(expObj, expAppId) {
				var me = this;
				var sessionObj = Common.getSession(); //전체호출
				
				var sKey = expAppId;
				var sSubject = expObj.ApplicationTitle;
				var sLogonId = sessionObj["USERID"];
				var sDeptId = sessionObj["DEPTID"];
				var sLegacyFormID = Common.getBaseConfig("LegacyFormIDForEAccount", sessionObj["DN_ID"]);
				var sDataType = "ALL"; //HTML, JSON, ALL
				var now = new Date();
				now = now.getFullYear() + '-' + XFN_AddFrontZero(now.getMonth() + 1) + '-' + XFN_AddFrontZero(now.getDate()) + " " 
						+ XFN_AddFrontZero(now.getHours()) + ":" + XFN_AddFrontZero(now.getMinutes()) + ":" + XFN_AddFrontZero(now.getSeconds());
				var sBodyContext = {
					LegacyFormID : sLegacyFormID,
					ERPKey : sKey,
					HTMLBody : me.simpCardApp_getHTMLBody(),
					JSONBody : expObj,
					InitiatedDate : now,
					InitiatorCodeDisplay : sessionObj["UR_Code"],
					InitiatorDisplay : sessionObj["UR_Name"],
					InitiatorOUDisplay : sessionObj["GR_Name"]
				};
				var nRuleItemId = me.simpCardApp_GetRuleItem();
				var apvLine = me.simpCardApp_GetApvLine(sLegacyFormID, nRuleItemId);	

				var formData = new FormData();
				formData.append("key", sKey);
				formData.append("subject", sSubject);
				formData.append("logonId", sLogonId);
				formData.append("deptId", sDeptId);
				formData.append("legacyFormID", sLegacyFormID);
				formData.append("apvline", JSON.stringify(apvLine));
				formData.append("bodyContext", JSON.stringify(sBodyContext));
				formData.append("attachFile[]", null);

				$.ajax({
					type:"POST",
					url:"/approval/legacy/draftForLegacy.do",
					contentType: false,
					processData: false,
					async:false,
					data:formData,
					success:function (data) {
						if(data.status == "SUCCESS") {
							Common.Inform("<spring:message code='Cache.ACC_msg_draftComplete' />"); //기안이 완료되었습니다.
						} else {
							Common.Error(data.message);							
						}
						//상신 후 화면 초기화
						me.simpCardApp_setNew();
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의바랍니다.
					}
				});
			},
			
			//수정
			simpCardApp_ChangeBodyContext : function(expObj) {
				var me = this;
				var sProcessID = expObj.ProcessID;
				var sUserCode = Common.getSession("UR_Code");
				var sBodyContext = {
					HTMLBody : me.simpCardApp_getHTMLBody(),
					JSONBody : expObj
				};

				var formData = new FormData();
				formData.append("processID", sProcessID);
				formData.append("userCode", sUserCode);
				formData.append("bodyContext", JSON.stringify(sBodyContext));

				$.ajax({
					type:"POST",
					url:"/approval/legacy/changeBodyContext.do",
					contentType: false,
					processData: false,
					data:formData,
					success:function (data) {
						Common.Inform("<spring:message code='Cache.ACC_msg_editComplete' />"); //수정이 완료되었습니다.
						//수정 후 화면 초기화
						me.simpCardApp_setNew();
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의바랍니다.
					}
				});
			},
			
			simpCardApp_GetRuleItem : function() {
				var chargeJob = accountCtrl.getComboInfo("simpCardApp_chargeJobList").val().replace("JF_ACCOUNT_","");
				var ruleItemId = 0;
				
				$.ajax({
					type:"POST",
					url:"/account/baseCode/getCodeListByCodeGroup.do",
					async:false,
					data:{
						codeGroup : 'ApvRule',
						companyCode : me.CompanyCode
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							if(data.list.length > 0) {
								$(data.list).each(function(i, obj){
									if(obj.IsUse == "Y" && obj.IsGroup == "N") {
										if(obj.Code.split('_')[0] == chargeJob) {
											ruleItemId = obj.Code.split('_')[1];
											return false;
										}
									}
								});
							}
						}
					},
					error:function (error){
						alert(error.message);
					}
				});
				
				return ruleItemId;
			},
			
			simpCardApp_GetApvLine : function(pLegacyFormID, pRuleItemID) {
				var apvLine = "";
				
				$.ajax({
					type:"POST",
					url:"/approval/legacy/getRuleApvLine.do",
					async:false,
					data:{
						legacyFormID : pLegacyFormID,
						ruleItemID : pRuleItemID
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							apvLine = data.result;
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의바랍니다.
					}
				});
				
				return apvLine;
			},
			
			simpCardApp_getHTMLBody : function() {
			    // 버튼 삭제, 체크박스 삭제
			    $("div[name=simpCardApp_hiddenViewForm] .acstatus_wrap").each(function(){ 
			    	$(this).find("input[type=checkbox]").parent().parent().remove();
			    });
			    
				return $("div[name=simpCardApp_hiddenViewForm]").html();
			},

			simpCardApp_setModified : function(val) {
				var me = this;
				me.dataModified = val;
			},
			//콤보 설정
			setSelectCombo : function(){
				var defaultVal = "";
				if(typeof SimpleCorpCardApplication != "undefined" && typeof SimpleCorpCardApplication.pageSimpCardAppData.ChargeJob != "undefined") {
					defaultVal = SimpleCorpCardApplication.pageSimpCardAppData.ChargeJob.split("@")[0];
				}
				
				var AXSelectMultiArr = [	
					{'codeGroup':'ChargeJobList_Expence', 'target':'simpCardApp_chargeJobList', 'lang':'ko', 'onchange':'', 'oncomplete':'', 'defaultVal': defaultVal}
				]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
			},
			
			simpCardApp_showPreview : function() {
				var me = this;
				me.simpCardApp_getExpAppField();
				
				//신청 건 미리보기
				Common.open("","ExpenceApplicationPreviewPopup","<spring:message code='Cache.btn_preview'/>",
					"/account/expenceApplication/ExpenceApplicationPreviewPopup.do?parentID=SimpleCorpCardApplication","1000px","800px","iframe",true,"450px","100px",true);
			}
	}
	window.SimpleCorpCardApplication = SimpleCorpCardApplication;
})(window);

</script>
	
	
	