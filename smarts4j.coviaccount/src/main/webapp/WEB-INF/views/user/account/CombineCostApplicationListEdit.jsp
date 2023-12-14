<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>
<style>
.pad10 { padding:10px;}
</style>
<body>
	<div class="divpop_contents">
		<div class="popContent form_box">
			<div class="rowTypeWrap formWrap tsize">
				<input type="hidden" id="comCostAppListEdit_PropertyBudget" tag="Budget">
				<!-- 컨텐츠 시작 -->
				<div class="eaccountingCont">
					<div class="eaccountingCont_in">
						<div class="inStyleSetting">	
							<div> <!-- class="card_nea_wrap" -->
								<ul class="card_nea_right_list" name="comCostAppListEdit_AddListArea"></ul>
							</div>
							<div style="margin-top: 10px; text-align: center;">
							    <a href="#" class="btnTypeDefault btnTypeChk" onclick="CombineCostApplicationListEdit.comCostAppListEdit_saveList()"><spring:message code="Cache.ACC_btn_save"/></a>
							    <a href="#" class="btnTypeDefault" onclick="CombineCostApplicationListEdit.comCostAppListEdit_closePopup()"><spring:message code="Cache.ACC_btn_cancel"/></a>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
<script>

//증빙 편집 전용
if (!window.CombineCostApplicationListEdit) {
	window.CombineCostApplicationListEdit = {};
}

(function(window) {
	var isUseIO = Common.getBaseConfig("IsUseIO");
	var isUseSB = Common.getBaseConfig("IsUseStandardBrief");
	var isUseBD = "N";

	var ExpAppListID = "<%=request.getParameter("ExpAppListID") %>";

	var AppType = "<%=request.getParameter("AppType") %>";
	var RequestType = "<%=request.getParameter("RequestType") %>";
	var ProofCode = "<%=request.getParameter("ProofCode") %>";
	var ViewKeyNo = "<%=request.getParameter("ViewKeyNo") %>";
	var CompanyCode = "<%=request.getParameter("CompanyCode") %>";
	
	var CombineCostApplicationListEdit = {			
			pageOpenerIDStr : "openerID=CombineCostApplicationListEdit&",
			pageName : "CombineCostApplicationListEdit",
			ApplicationType : "",
			pageCombiAppFormList : {
									CorpCardInputFormStr	: "",
									TaxBillInputFormStr		: "",
									PaperBillInputFormStr	: "",
									CashBillInputFormStr	: "",
									PrivateCardInputFormStr : "",
									EtcEvidInputFormStr		: "",
									ReceiptInputFormStr 	: "",
									InputInputFormStr 		: "",
									DivInputFormStr			: "",
									DivAddInputFormStr		: "",
									DocLinkInputFormStr		: "",
									VendorInputFormStr		: "",
									TaxBillItemInputFormStr	: ""
			},

			pageCombiAppComboData : {
				AccountCtrlList		: [],
				TaxTypeList			: [],
				TaxCodeList			: [],
				WHTaxList			: [],
				PayMethodList		: [],
				PayTypeList			: [],
				PayTargetList		: [],
				BankAccountList		: [],
				ProvideeList		: [],
				BillTypeList		: [],
				BriefList			: [],
				BizTripItemList 	: [],
				InvestItemList 		: [],
				InvestTargetList	: [],
				ExchangeNationList	: [],

				AccountCtrlMap		: {},
				TaxTypeMap			: {},
				TaxCodeMap			: {},
				WHTaxMap			: {},
				PayMethodMap		: {},
				PayTypeMap			: {},
				PayTargetMap		: {},
				AccountInfoMap		: {},
				ProvideeMap			: {},
				BillTypeMap			: {},
				BriefMap			: {},
				BizTripItemMap		: {},				
				InvestItemMap		: {},
				InvestTargetMap		: {},
				ExchangeNationMap	: {},
				
				DefaultCC			: {},
			},
			tempVal : {},
			openParam : {},
			isModified : true,
			
			fileName : '',

			pageExpenceAppEvidList : [],
			pageExpenceAppTarget : {},
			pageExpenceAppObj : {},
			
			appType : '',
			requestType : '',
			proofCode : '',
			pcFieldStr : '',
			CompanyCode : '',

			pageInit : function(inputParam) {
				var me = this;

				me.tempVal.isLoad = false;
				
				setPropertySearchType('Budget','comCostAppListEdit_PropertyBudget'); //예산관리 사용여부				
				isUseBD = $("#comCostAppListEdit_PropertyBudget").val();
				
				if(ExpAppListID == "") {
					me.appType = AppType;
					me.requestType = RequestType;
					me.proofCode = ProofCode;
					me.CompanyCode = CompanyCode;
					
					me.openParam.mode = "W"; //Write - 작성 페이지에서 띄움
				} else {
					me.pageExpenceAppObj = opener.CombineCostApplicationView.pageExpenceAppObj;
					me.pageExpenceAppObj.isNew = "N";
					me.pageExpenceAppObj.isSearched = "Y";
					
					me.appType = me.pageExpenceAppObj.ApplicationType;
					me.requestType = me.pageExpenceAppObj.RequestType;
					me.CompanyCode = me.pageExpenceAppObj.CompanyCode;
					
					me.openParam.mode = "R"; //Read - 조회 페이지에서 띄움
				}
				
				me.exchangeIsUse = accComm.getExchangeIsUse(me.CompanyCode, me.requestType);
				
				switch(me.appType) {
				case "CO": me.fileName = "CombineCostApplication"; break;
				case "SC": me.fileName = "SimpleApplication"; break;
				}
				me.ApplicationType = me.appType;
				me.fileName = me.fileName + me.requestType;
				window[me.fileName] = CombineCostApplicationListEdit;
				
				if(me.openParam.mode == "R") {
					me.fileName = "CombineCostApplicationView";
				}

				me.pageExpenceAppEvidList = opener[me.fileName].pageExpenceAppEvidList;
				
				if(me.openParam.mode == "W") {					
					me.pageExpenceAppTarget = JSON.parse(JSON.stringify(opener[me.fileName].combiCostApp_findListItem(me.pageExpenceAppEvidList, "ViewKeyNo", ViewKeyNo)));
					ExpAppListID = me.pageExpenceAppTarget.ExpenceApplicationListID;
					var __expAppStatus = ""; 
					if(opener[me.fileName].pageExpenceAppObj){
						__expAppStatus = opener[me.fileName].pageExpenceAppObj.ApplicationStatus;
					}
					
					if(me.pageExpenceAppTarget.ExpenceApplicationID && me.pageExpenceAppTarget.ExpenceApplicationID != "" && __expAppStatus != "T") {
						accComm.getFormLegacyManageInfo(me.requestType, me.CompanyCode, me.pageExpenceAppTarget.ExpenceApplicationID);
					}else{
						accComm.getFormManageInfo(me.requestType, me.CompanyCode);
					}
				} else {
					$(me.pageExpenceAppEvidList).each(function(i, obj){
						if(obj.ExpenceApplicationListID == ExpAppListID){
							me.pageExpenceAppTarget = JSON.parse(JSON.stringify(obj));
							me.proofCode = obj.ProofCode;
							if(me.appType == "SC" && me.proofCode != "CorpCard"){
								me.proofCode = "Input";
							}
						}
					});
					accComm.getFormLegacyManageInfo(me.requestType, me.CompanyCode, me.pageExpenceAppObj.ExpenceApplicationID);
				}

				me.pcFieldStr = me.appType == "CO" ? "proofcode" : "proofcd";
				
				me.comCostAppListEdit_FormInit();
				me.comCostAppListEdit_comboDataInit();
				me.comCostAppListEdit_getDefaultCC();
				
				me.comCostAppListEdit_makeInputHtmlForm();
				
				if(isUseIO == "N"){
					$("[name=noIOArea]").remove();
					$("[name=colIOSBArea]").attr("colspan", Number($("[name=colIOSBArea]").attr("colspan")) - 1);
					$("[name=FileViewArea]").attr("colspan", Number($("[name=FileViewArea]").attr("colspan")) - 1);
				}
				if(isUseSB == "N") {
					$("[name=noSBArea]").remove();
					$("[name=colIOSBArea]").attr("colspan", Number($("[name=colIOSBArea]").attr("colspan")) - 1);
					$("[name=FileViewArea]").attr("colspan", Number($("[name=FileViewArea]").attr("colspan")) - 1);
				}
				if($("#comCostAppListEdit_PropertyBudget").val() == "" || $("#comCostAppListEdit_PropertyBudget").val() == "N") {
					$("[name=noBDArea]").remove();
					$("[name=colIOSBArea]").attr("colspan", Number($("[name=colIOSBArea]").attr("colspan")) - 1);
					$("[name=FileViewArea]").attr("colspan", Number($("[name=FileViewArea]").attr("colspan")) - 1);
				}
				
				me.tempVal.isLoad = true;
			},
			
			pageView : function() {
				var me = this;
			},
			
			//콤보 데이터 조회
			comCostAppListEdit_comboDataInit : function() {
				var me = this;
				//관리항목 조회
				$.ajax({
					type:"POST",
						url:"/account/accountCommon/getBaseCodeData.do",
					data:{
						codeGroups : "AccountCtrl",
						CompanyCode : me.CompanyCode
					},
					async: false,
					success:function (data) {
						if(data.result == "ok"){
							var codeList = data.list;
							if(codeList.hasOwnProperty('AccountCtrl'))
							{
								me.pageCombiAppComboData.AccountCtrlList = codeList.AccountCtrl;
								me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.AccountCtrlList, "AccountCtrl", "Code", "CodeName");
							}
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
				//환종 조회
				if(me.exchangeIsUse == "Y") {
					$.ajax({
						type:"POST",
							url:"/account/accountCommon/getBaseCodeData.do",
						data:{
							codeGroups : "ExchangeNation",
							CompanyCode : me.CompanyCode
						},
						async: false,
						success:function (data) {
							if(data.result == "ok"){
								var codeList = data.list;
								if(codeList.hasOwnProperty('ExchangeNation'))
								{
									me.pageCombiAppComboData.ExchangeNationList = codeList.ExchangeNation;
									me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.ExchangeNationList, "ExchangeNation", "Code", "CodeName");
								}
							}
							else{
								Common.Error(data);
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				}
				$.ajax({
					type:"POST",
					url:"/account/accountCommon/getBaseCodeDataAll.do",
					data:{
						codeGroups : "TaxType,WHTax,PayMethod,PayType,PayTarget,BizTripItem,BillType,CompanyCode,InvestTarget,InvestItem",
						CompanyCode : me.CompanyCode
					},
					async:false,					
					success:function (data) {
						if(data.result == "ok"){
							var codeList = data.list
							me.pageCombiAppComboData.TaxTypeList = codeList.TaxType;
							
							for(var i = 0; i < codeList.PayMethod.length; i++) {
								if(codeList.PayMethod[i].Code == "T") {
									codeList.PayMethod.splice(i);
								}
							}
							
							me.pageCombiAppComboData.PayMethodList = codeList.PayMethod;
							me.pageCombiAppComboData.PayTypeList = codeList.PayType;
							me.pageCombiAppComboData.PayTargetList = codeList.PayTarget;
							me.pageCombiAppComboData.WHTaxList = codeList.WHTax;							
							me.pageCombiAppComboData.ProvideeList = codeList.CompanyCode;
							me.pageCombiAppComboData.BillTypeList = codeList.BillType;
							me.pageCombiAppComboData.BizTripItemList = codeList.BizTripItem;
							me.pageCombiAppComboData.InvestTargetList = codeList.InvestTarget;
							me.pageCombiAppComboData.InvestItemList = codeList.InvestItem;
							
							me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.TaxTypeList, "TaxType", "Code", "CodeName");
							me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.PayMethodList, "PayMethod", "Code", "CodeName");
							me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.PayTypeList, "PayType", "Code", "CodeName");
							me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.PayTargetList, "PayTarget", "Code", "CodeName");
							me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.ProvideeList, "Providee", "Code", "CodeName");
							me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.BillTypeList, "BillType", "Code", "CodeName");
							me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.WHTaxList, "WHTax", "Code", "CodeName");
							me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.BizTripItemList, "BizTripItem", "Code", "CodeName");
							me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.InvestTargetList, "InvestTarget", "Code", "CodeName");
							me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.InvestItemList, "InvestItem", "Code", "CodeName");
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});

				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getTaxCodeCombo.do",
					data:{
						CompanyCode : me.CompanyCode
					},
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							me.pageCombiAppComboData.TaxCodeList = data.list
							me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.TaxCodeList, "TaxCode", "Code", "CodeName");
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error(error.message);
					}
				});

				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getUserBankAccount.do",
					data:{
					},
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							me.pageCombiAppComboData.BankAccountList = data.list;
							me.comCostAppListEdit_makeCodeMap(me.pageCombiAppComboData.BankAccountList, "AccountInfo", "BankAccountNo", "BankAccountView");
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});
				
				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getBriefCombo.do",
					data:{
						"isSimp": "Y",
						"StandardBriefSearchStr": accComm[me.requestType].pageExpenceFormInfo.StandardBriefSearchStr,
						"CompanyCode": me.CompanyCode
					},
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							me.pageCombiAppComboData.BriefList = data.list
							me.comCostAppListEdit_makeCodeMap(data.list, "Brief", "StandardBriefID");
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});

				me.comCostAppListEdit_FormComboInit();
			},

			CODEMAPSTR : "me.pageCombiAppComboData.",
			comCostAppListEdit_makeCodeMap : function(List, name, dataField, labelField) {
				var me = this;
				if(List != null){
					//var evalStr = me.CODEMAPSTR+name+"Map = {}";
					//eval(evalStr);
					me.pageCombiAppComboData[name+"Map"] = {};
					for(var i = 0; i<List.length; i++){
						var item = List[i];
						
						//var evalStr = me.CODEMAPSTR+name+"Map[item[dataField]] = item";
						//eval(evalStr);
						me.pageCombiAppComboData[name+"Map"][item[dataField]] = item;
					}
				}
			},
			
			//폼의 콤보데이터 세팅
			comCostAppListEdit_FormComboInit : function(){
				var me = this
				
				var PayMethodOptionsStr = me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.PayMethodList, "Code", "CodeName", null, null);
				var PayTypeOptionsStr = me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.PayTypeList, "Code", "CodeName", null, null);
				var PayTargetOptionsStr = me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.PayTargetList, "Code", "CodeName", null, null);
				
				var TaxTypeOptionsStr = me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.TaxTypeList, "Code", "CodeName", null, null);				
				var IncomeTaxOptionStrEE = me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.WHTaxList, "Code", "CodeName", "E1", "tag");
				var LocalTaxOptionStrEE = me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.WHTaxList, "Code", "CodeName", "E2", "tag");
				var BankAccountOptionsStr = me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.BankAccountList, "BankAccountNo", "BankAccountView", null, "data");

				var ProvideeOptionsStr = me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.ProvideeList);
				var BillTypeOptionsStr = me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.BillTypeList);
				
				var StandardBriefOptionStr = me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.BriefList, "StandardBriefID", "StandardBriefName", null, null);
				
				var InvestStr = me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.InvestItemList, "InvestCode", "InvestCodeName", null, null);
				var BizTripItemStr = me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.BizTripItemList, "Code", "CodeName", null, null);
				
				var ExchangeNationOptionsStr =  me.exchangeIsUse == "Y" ? me.comCostAppListEdit_ComboDataMake(me.pageCombiAppComboData.ExchangeNationList, "Code", "CodeName") : "";
				
				for(var formNm in me.pageCombiAppFormList){
					var formStr = me.pageCombiAppFormList[formNm];

					formStr = formStr.replace("@@{PayMethodOptions}", PayMethodOptionsStr);
					formStr = formStr.replace("@@{PayTypeOptions}", PayTypeOptionsStr);
					formStr = formStr.replace("@@{PayTargetOptions}", PayTargetOptionsStr);
					
					formStr = formStr.replace("@@{TaxTypeOptions}", TaxTypeOptionsStr);
					formStr = formStr.replace("@@{IncomeTaxOptions}", IncomeTaxOptionStrEE);
					formStr = formStr.replace("@@{LocalTaxOptions}", LocalTaxOptionStrEE);
					formStr = formStr.replace("@@{BankAccountOptions}", BankAccountOptionsStr);

					formStr = formStr.replace("@@{ProvideeOptions}", ProvideeOptionsStr);
					formStr = formStr.replace("@@{BillTypeOptions}", BillTypeOptionsStr);
					
					formStr = formStr.replace("@@{BriefOptions}", StandardBriefOptionStr);
					
					formStr = me.exchangeIsUse == "Y" ? formStr.replace("@@{ExchangeNationOptions}", ExchangeNationOptionsStr) : formStr;
					
					if(me.requestType == "INVEST" && me.pageCombiAppComboData.InvestItemList != null){
						formStr = formStr.replace("@@{InvestItemOptions}", InvestStr);
					}
					if((me.requestType == "BIZTRIP" || me.requestType == "OVERSEA") && me.pageCombiAppComboData.BizTripItemList != null){
						formStr = formStr.replace("@@{BizTripItemOptions}", BizTripItemStr);
					}
					me.pageCombiAppFormList[formNm] = formStr;
				}
			},
			
			//콤보데이터 html 생성
			comCostAppListEdit_ComboDataMake : function(cdList, codeField, nameField, Type, attr,isNotContainEmpty) {
				if(cdList==null){
					return;
				}
				if(codeField==null) codeField="Code";
				if(nameField==null) nameField="CodeName";
				
				var htmlStr = "<option value=''>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";
				if(isNotContainEmpty=="Y")
					htmlStr = "";;
				for(var i = 0; i<cdList.length; i++){
					var getCd = cdList[i];
					if(Type == null || getCd.Reserved1 == Type){
						if(getCd.IsUse == "Y" || getCd.IsUse == null || getCd.IsUse == ""){
							if(attr == null) {
								htmlStr = htmlStr + "<option value='"+ getCd[codeField] +"'>"+ getCd[nameField] +"</option>"
							} else {
								htmlStr = htmlStr + "<option value='"+ getCd[codeField] +"' "+attr+"='" + JSON.stringify(getCd) + "'>"+ getCd[nameField] +"</option>"
							}
						}
					}
				}
				return htmlStr;
			},
			
			comCostAppListEdit_getDefaultCC : function() {
				var me = this;
				$.ajax({
					url:"/account/expenceApplication/getUserCC.do",
					cache: false,
					data:{
					},
					success:function (data) {
						if(data.result == "ok"){
							var getData = data.CCInfo
							if(getData != null){
								me.pageCombiAppComboData.DefaultCC.CostCenterCode = getData.CostCenterCode;
								me.pageCombiAppComboData.DefaultCC.CostCenterName = getData.CostCenterName;
							}
						}
					},
					error:function (error){
					}
				});
			},
			
			//html폼 로드
			comCostAppListEdit_FormInit : function() {
				var me = this;
				var formPath = Common.getBaseConfig("AccountApplicationFormPath");
				
				$.ajaxSetup({async:false});

				if(me.appType == "CO") {
					$.get(formPath + "CombiCostApp_InputForm_"+me.proofCode+".html" + resourceVersion, function(val){
						me.pageCombiAppFormList[me.proofCode+"InputFormStr"] = val;
					});
					$.get(formPath + "CombiCostApp_InputForm_DivTableForm.html" + resourceVersion, function(val){
						me.pageCombiAppFormList.DivInputFormStr = val;
					});
					$.get(formPath + "CombiCostApp_InputForm_DocLink.html" + resourceVersion, function(val){
						me.pageCombiAppFormList.DocLinkInputFormStr = val;
					});
					$.get(formPath + "CombiCostApp_InputForm_Vendor.html" + resourceVersion, function(val){
						me.pageCombiAppFormList.VendorInputFormStr = val;
					});
					$.get(formPath + "CombiCostApp_InputForm_TaxBillItem.html" + resourceVersion, function(val){
						me.pageCombiAppFormList.TaxBillItemInputFormStr = val;
					});
				} else if(me.appType == "SC") {
					$.get(formPath + "SimpleApplication_"+me.proofCode+"AddForm.html" + resourceVersion, function(val){
						me.pageCombiAppFormList[me.proofCode+"InputFormStr"] = val;
					});
					$.get(formPath + "SimpleApplication_Div.html" + resourceVersion, function(val){
						me.pageCombiAppFormList.DivInputFormStr = val;
					});
					$.get(formPath + "SimpleApplication_DivAdd.html" + resourceVersion, function(val){
						me.pageCombiAppFormList.DivAddInputFormStr = val;
					});
				}
			},

			
			//===========
			//코드 맵 획득
			comCostAppListEdit_getCodeMapInfo : function(codeMap, key, getField) {
				var me = this;
				var retVal = "";
				
				if(codeMap != null && key != null && getField != null) {
					if(codeMap[key] != null){
						retVal = codeMap[key][getField]	
					}
				}
				return retVal
			},
			
			//html 폼의 html 생성 생성
			comCostAppListEdit_makeInputHtmlForm : function() {
				var me = this;
				var inputItem = me.pageExpenceAppTarget;
				
				if(inputItem != null){					
					var ProofCode = inputItem.ProofCode;
					var KeyField = me.comCostAppListEdit_getProofKey(ProofCode);
					var formStr = me.pageCombiAppFormList[me.proofCode+"InputFormStr"];
					
					inputItem.KeyNo = inputItem[KeyField];					
					if(nullToBlank(inputItem.KeyNo) == "") {
						inputItem.KeyNo = inputItem.ViewKeyNo;
					}					
					
					if(nullToBlank(inputItem.IncomeTax) != "") {
						inputItem.IncomTax = inputItem.IncomeTax;
					}

					if(nullToBlank(inputItem.RepAmount) == "") {
						inputItem.RepAmount = inputItem.TotalAmount;
					}
					
					if(nullToBlank(inputItem.TaxAmount) == "") {
						inputItem.TaxAmount = 0;
					}
					
					inputItem.AccountBankName = accComm.getBaseCodeName("Bank", nullToBlank(inputItem.AccountBank), me.CompanyCode);
					
					if(inputItem.AccountBankName == "") {
						inputItem.AccountBankName = inputItem.AccountBank;
					} 
					
					var valMap = {
							RequestType : me.requestType,
							ExpenceApplicationListID : nullToBlank(inputItem.ExpenceApplicationListID),
							
							KeyNo : nullToBlank(inputItem.KeyNo),
							ProofCode : nullToBlank(inputItem.ProofCode),
							TotalAmount : toAmtFormat(nullToBlank(inputItem.TotalAmount)),
							
							ProofDateStr : nullToBlank(inputItem.ProofDateStr),
							ProofTimeStr : nullToBlank(inputItem.ProofTimeStr),
							ProofDate : nullToBlank(inputItem.ProofDateStr),
							ProofTime : nullToBlank(inputItem.ProofTimeStr),
							
							CostCenterCode : nullToBlank(inputItem.CostCenterCode),
							CostCenterName : nullToBlank(inputItem.CostCenterName),
							
							Currency : nullToBlank(inputItem.Currency),
							ExchangeRate : nullToBlank(inputItem.ExchangeRate) == "" ? 0 : parseInt(inputItem.ExchangeRate),
							LocalAmount : nullToBlank(inputItem.LocalAmount) == "" ? 0 : parseInt(inputItem.LocalAmount),
							
							//거래처정보
							TaxType : nullToBlank(inputItem.TaxType),
							TaxCode : nullToBlank(inputItem.TaxCode),
							PayMethod : nullToBlank(inputItem.PayMethod),
							PayType : nullToBlank(inputItem.PayType),
							PayTarget : nullToBlank(inputItem.PayTarget),
							AlterPayeeNo : nullToBlank(inputItem.AlterPayeeNo),
							AlterPayeeName : nullToBlank(inputItem.AlterPayeeName),
							VendorNo : nullToBlank(inputItem.VendorNo),
							VendorName : nullToBlank(inputItem.VendorName),
							VendorID : nullToBlank(inputItem.VendorID),
							BusinessNumber : nullToBlank(inputItem.BusinessNumber),
							AccountInfo : nullToBlank(inputItem.AccountInfo),
							AccountHolder : nullToBlank(inputItem.AccountHolder),
							AccountBank : nullToBlank(inputItem.AccountBank),
							AccountBankName : nullToBlank(inputItem.AccountBankName),
							
							//기타증빙
							IsWithholdingTax : nullToBlank(inputItem.IsWithholdingTax),
							IncomTax: nullToBlank(inputItem.IncomTax),
							LocalTax: nullToBlank(inputItem.LocalTax),
							EmpInsurance: toAmtFormat(nullToBlank(inputItem.EmpInsurance)),
							AccidInsurance: toAmtFormat(nullToBlank(inputItem.AccidInsurance)),
							WorkingDay: toAmtFormat(nullToBlank(inputItem.WorkingDay)),
							ActualDay: toAmtFormat(nullToBlank(inputItem.ActualDay)),
							
							//법인카드
							ReceiptID : nullToBlank(inputItem.ReceiptID),								
							StoreName : nullToBlank(inputItem.StoreName).trim(),
							CardUID : nullToBlank(inputItem.CardUID),
							CardApproveNo : nullToBlank(inputItem.CardApproveNo),
							RepAmount : toAmtFormat(nullToBlank(inputItem.RepAmount)),
							TaxAmount : toAmtFormat(nullToBlank(inputItem.TaxAmount)),
							ServiceAmount : toAmtFormat(nullToBlank(inputItem.ServiceAmount)),

							//현금영수증
							CashBillID : nullToBlank(inputItem.CashBillID),
							CashUID : nullToBlank(inputItem.CashUID),
							CashNTSConfirmNum : nullToBlank(inputItem.CashNTSConfirmNum),
							FranchiseCorpName : nullToBlank(inputItem.FranchiseCorpName),
							
							//전자세금계산서
							TaxUID : nullToBlank(inputItem.TaxUID),
							TaxNTSConfirmNum : nullToBlank(inputItem.TaxNTSConfirmNum),
							Tax : toAmtFormat(nullToBlank(inputItem.Tax)),
							SupplyCost : toAmtFormat(nullToBlank(inputItem.SupplyCost)),
							WriteDate : nullToBlank(inputItem.FormatWriteDate),
							Remark : nullToBlank(inputItem.Remark),
							ItemName : nullToBlank(inputItem.ItemName),
							InvoicerCorpNum : nullToBlank(inputItem.InvoicerCorpNum),
							InvoicerCorpName : nullToBlank(inputItem.InvoicerCorpName),
							InvoicerCEOName : nullToBlank(inputItem.InvoicerCEOName),
							InvoicerAddr : nullToBlank(inputItem.InvoicerAddr),
							InvoicerBizType : nullToBlank(inputItem.InvoicerBizType),
							InvoicerBizClass : nullToBlank(inputItem.InvoicerBizClass),
							InvoiceeCorpNum : nullToBlank(inputItem.InvoiceeCorpNum),
							InvoiceeCorpName : nullToBlank(inputItem.InvoiceeCorpName),
							InvoiceeCEOName : nullToBlank(inputItem.InvoiceeCEOName),
							InvoiceeAddr : nullToBlank(inputItem.InvoiceeAddr),
							InvoiceeBizType : nullToBlank(inputItem.InvoiceeBizType),
							InvoiceeBizClass : nullToBlank(inputItem.InvoiceeBizClass),
							
							//종이세금계산서
							ProviderName : nullToBlank(inputItem.ProviderName),
							ProviderNo : nullToBlank(inputItem.ProviderNo),
							Providee : nullToBlank(inputItem.Providee),
							BillType : nullToBlank(inputItem.BillType),
							
							//개인카드
							PersonalCardNo : nullToBlank(inputItem.PersonalCardNo),
							PersonalCardNoView : nullToBlank(inputItem.PersonalCardNoView),
							
							//모바일 영수증
							PhotoDateStr : nullToBlank(inputItem.PhotoDateStr),
							FullPath : nullToBlank(inputItem.FullPath),
							FileID : nullToBlank(inputItem.FileID),
							SavedName : nullToBlank(inputItem.SavedName),
							FileName : nullToBlank(inputItem.FileName),

							//세부증빙 영역
							Rownum : nullToBlank(inputItem.divList[0].Rownum),
							AmountVal : toAmtFormat(nullToBlank(inputItem.Amount)),
							UsageCommentVal : nullToBlank(inputItem.UsageComment).replace(/<br>/gi, '\r\n'),
							AccountCode : nullToBlank(inputItem.AccountCode),
							StandardBriefID : nullToBlank(inputItem.StandardBriefID),
							
							SupplyAmountVal : toAmtFormat(nullToBlank(inputItem.RepAmount)),
							TaxAmountVal : toAmtFormat(nullToBlank(inputItem.TaxAmount)),
							accCDVal : nullToBlank(inputItem.AccountCode),
							accNMVal : nullToBlank(inputItem.AccountName),
							SBCDVal : nullToBlank(inputItem.StandardBriefID),
							SBNMVal : nullToBlank(inputItem.StandardBriefName),
							CCCDVal : nullToBlank(inputItem.CostCenterCode),
							CCNMVal : nullToBlank(inputItem.CostCenterName),
					}
					if(ProofCode == "TaxBill") {
						valMap.payMsg = "<spring:message code='Cache.ACC_lbl_payBill' />";
						if(inputItem.PurposeType == "01") {
							valMap.payMsg = "<spring:message code='Cache.ACC_lbl_payBill2' />";
						}
					}
					
					var DivInputAreaStr = me.comCostAppListEdit_htmlFormSetVal(me.pageCombiAppFormList.DivInputFormStr, valMap);
					valMap.DivInputArea = DivInputAreaStr;

					var DocLinkInputAreaStr = me.comCostAppListEdit_htmlFormSetVal(me.pageCombiAppFormList.DocLinkInputFormStr, valMap);
					valMap.DocLinkInputArea = DocLinkInputAreaStr;
					
					var VendorInputAreaStr = me.comCostAppListEdit_htmlFormSetVal(me.pageCombiAppFormList.VendorInputFormStr, valMap);
					valMap.VendorInputArea = VendorInputAreaStr;
					
					var getForm = me.comCostAppListEdit_htmlFormSetVal(formStr, valMap);
					getForm = me.comCostAppListEdit_htmlFormDicTrans(getForm);

					$("[name=comCostAppListEdit_AddListArea]").append(getForm);
					
					// 날짜 필드 생성
					me.comCostAppListEdit_makeDateField(ProofCode, inputItem);
					
					// 환종 환율 추가
					if(me.exchangeIsUse == "Y" && ProofCode == "EtcEvid") {
						//입력 필드 show
						$("span[name=EtcEvidField]["+me.pcFieldStr+"="+ProofCode+"][keyno="+inputItem.KeyNo+"]").show();
						
						//환종 KRW 기본값 세팅
						var CUField = $("[name=CurrencySelectField]["+me.pcFieldStr+"="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"]");
						if (valMap.Currency == "") valMap.Currency = "KRW";
						CUField.val(valMap.Currency);
						me.comCostAppListEdit_setListVal(valMap.ProofCode, "Currency", valMap.KeyNo, valMap.Currency);
						
						// 값 세팅 시 (임시저장, 상신) change 이벤트로 인하여 덮어씌워지지 않도록 처리
						if (CUField.val() != "KRW") {
							if (CUField.val() == valMap.Currency) {
								$("span[name=ExRateArea]["+me.pcFieldStr+"="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"]").show();
							}
						}
					} else {
						$("span[name=EtcEvidField]["+me.pcFieldStr+"="+ProofCode+"][keyno="+inputItem.KeyNo+"]").hide();
					}
				
					// 표준적요 값 세팅
					me.comCostAppListEdit_BriefValSet(ProofCode, valMap.KeyNo, valMap.Rownum, inputItem.StandardBriefID);
										
					if(me.appType == "CO") {
						$("[name=comCostAppListEdit_AddListArea]").find("table").css("font-size" ,"14px");
						if(ProofCode == "EtcEvid") {
							$("[name=comCostAppListEdit_AddListArea]").find("li").css("font-size" ,"14px");
						}
						
						if(valMap.VendorID != "") {
							var tempObj = {};
							tempObj.KeyNo = valMap.KeyNo;
							tempObj.ProofCode = valMap.ProofCode;
							tempObj.VendorID = valMap.VendorID;
							tempObj.PayMethod = valMap.PayMethod;
							tempObj.PayType = valMap.PayType;
							tempObj.AccountInfo = valMap.AccountInfo;
							tempObj.AccountHolder = valMap.AccountHolder;
							tempObj.AccountBank = valMap.AccountBank;
							tempObj.AccountBankName = valMap.AccountBankName;
							me.comCostAppListEdit_getVendorInfo(tempObj);
						}
						
						if(valMap.IsWithholdingTax != "" && valMap.IsWithholdingTax == "Y") {
							$("#combiCostApp"+valMap.ProofCode+"_inputEvidTypeY_"+valMap.KeyNo).trigger("click");
						}
					}
					
					if(me.appType == "CO") {
						var selectFieldList = $("[name=ComboSelect]["+me.pcFieldStr+"="+inputItem.ProofCode+"][keyno="+inputItem.KeyNo+"]");
						for(var y = 0; y<selectFieldList.length; y++){
							var field = selectFieldList[y];

							var dataField = field.getAttribute("field");
							
							if(dataField == "AccountInfo") {
								var accVal = "DirectInput";
								
								for(var a = 0; a < $(field).find("option").length; a++) {
									if($(field).find("option").eq(a).val() == inputItem[dataField]) {
										accVal = inputItem[dataField];
										break;
									} 
								}
								
								field.value=nullToBlank(accVal);
							} else {
								field.value=nullToBlank(inputItem[dataField]);
							}
							
							if(field.onchange!=null){
								field.onchange();
							}
						}					
						
						if(inputItem.ProofCode == "EtcEvid") {
							me.combiCostAppEE_etcEvidTypeChange(null, inputItem.KeyNo, inputItem.IsWithholdingTax);
						}
						
						if(inputItem.ProofCode == "TaxBill") {
							var ItemList = me.getItemInfo(valMap.TaxUID);
							
							//품목 영수증, 세부증빙 생성
							if(ItemList.length > 0) {
								var itemTable = $("#combiCostAppTaxBill_listArea_"+valMap.KeyNo).find("[name=invoiceItemTable]");
								
								$(itemTable).css("display","");
								
								ItemList.map(function(val) {
									var TaxBillItemInputFormStr = me.comCostAppListEdit_htmlFormSetVal(me.pageCombiAppFormList.TaxBillItemInputFormStr, val);
									TaxBillItemInputFormStr = me.comCostAppListEdit_htmlFormDicTrans(TaxBillItemInputFormStr);
									$(itemTable).append(TaxBillItemInputFormStr);
								});
								
								$(itemTable).find("tr:first-child td:last-child").attr("rowspan", ItemList.length+1);
							}
						}
					} else if(me.appType == "SC") {
						// 법인카드/모바일영수증만 ReceiptField show
						if(ProofCode == "CorpCard" || ProofCode == "Receipt") {
							$("p[name=ReceiptField][proofcd="+ProofCode+"][keyno="+inputItem.KeyNo+"]").show();
						} else {
							$("p[name=ReceiptField][proofcd="+ProofCode+"][keyno="+inputItem.KeyNo+"]").hide();
						}
					}
					
					// CombineCostApplication이거나 세부 증빙이 2개 이상일 경우
					if(me.appType == "CO" || (inputItem.divList != undefined && inputItem.divList.length > 1)) {
						me.comCostAppListEdit_makeInputDivHtmlAdd(inputItem);
					}
				
					var item = inputItem;
					me.tempVal.ProofCode = item.ProofCode;
					me.tempVal.KeyNo = item.KeyNo;
					
					if(item.docList != null){
						me.comCostAppListEdit_LinkComp(item.docList, true);	
					}
					
					item.fileMaxNo = 0;
					var setFileList = null;
					
					if(item.uploadFileList != null){
						setFileList = [].concat(item.uploadFileList);
					} else if(item.fileList != null) {
						setFileList = [].concat(item.fileList);
					}
					
					if(setFileList != null) {
						for(var y = 0; y<setFileList.length; y++){
							var fileItem = setFileList[y];
							item.fileMaxNo++;
							fileItem.fileNum = item.fileMaxNo;
						}
						me.comCostAppListEdit_UploadHTML(setFileList, item.KeyNo, item.ProofCode, false);
					}
					
					if(me.requestType == "INVEST") {	
						//$("[name=TotalAmountField]").attr("disabled", "disabled");
						//$("[name=AmountField]").attr("disabled", "disabled");
						
						var SBField = $("[name=BriefSelectField][proofcd=EtcEvid][keyno="+item.ExpAppEtcID+"]");
						SBField.attr("disabled", "disabled");
						SBField.siblings("button").remove();
						SBField.parents("div.searchBox02").removeClass("searchBox02");
					}	
					
					if(me.isModified) {
						// 수정 버튼 클릭 후 입력 값 바인딩 중 trigger를 통해 select box를 시스템에서 onchange할 때 
						// 기존 사용자가 입력했던 금액값들이 날라가는 현상 때문에 isModified일 경우 금액 자동 수정을 막아놓음
						// 하지만 그 후 사용자가 직접 select box 값을 바꿀 경우 정상 작동이 필요하므로 isModified를 false로 변경 
						me.isModified = false;
					}				
				}
			},
			
			getItemInfo : function(TaxInvoiceID) {
				var ItemList = new Array();
				
				$.ajax({
					type:"POST",
						url:"/account/expenceApplication/getTaxBillItemInfo.do",
					data:{
						taxBillID: TaxInvoiceID
					},
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							(data.list).forEach(function(item) {
								var purchaseDate = item.PurchaseDT;
								purchaseDate = [purchaseDate.substr(0,4), purchaseDate.substr(4,2), purchaseDate.substr(6,2)].join(".");
								
								var itemInfo = {
										ItemName 	: item.ItemName,
										PurchaseDT	: purchaseDate,
										Qty			: toAmtFormat(nullToBlank(item.Qty)),
										UnitCost	: toAmtFormat(nullToBlank(item.UnitCost)),
										SupplyCost	: toAmtFormat(nullToBlank(item.SupplyCost)),
										Tax			: toAmtFormat(nullToBlank(item.Tax)),
										Remark		: item.Remark
								}
								
								ItemList.push(itemInfo);
							});
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});
				
				return ItemList;
			},	
 
			comCostAppListEdit_BriefValSet : function(ProofCode, KeyNo, Rownum, StandardBriefID) {
				var me = this;

				var getItem = me.pageExpenceAppTarget;

				var BriefMap = me.pageCombiAppComboData.BriefMap
				var getMap = BriefMap[StandardBriefID];
				if(getMap==null){
					getMap = {};
				}
			
				if(me.appType == "CO") return; //통합비용신청은 실행할 필요 X
				
				var divList = getItem.divList;
				for(var j = 0; j < divList.length; j++) {
					var divItem = divList[j];
					if(divItem.Rownum == Rownum){
						//if(j == 0) {
							getItem["StandardBriefID"] = StandardBriefID;
							getItem["StandardBriefName"] = nullToBlank(getMap.StandardBriefName);
	
							getItem['TaxType'] = nullToBlank(getMap.TaxType);
							getItem['TaxCode'] = nullToBlank(getMap.TaxCode);
							getItem['AccountCode'] = nullToBlank(getMap.AccountCode);
							getItem['AccountName'] = nullToBlank(getMap.AccountName);
							getItem['StandardBriefDesc'] = nullToBlank(getMap.StandardBriefDesc);
							
							// 오류오류
							$("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(nullToBlank(getMap.StandardBriefDesc));
							if(nullToBlank(getMap.StandardBriefDesc) != '') {
								$("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").show();
							} else {
								$("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").hide();
							}

							accountCtrl._setCtrlField(me, nullToBlank(getMap.CtrlCode), KeyNo, Rownum, ProofCode,divItem);
							accountCtrl._onSaveJson(me,null, "CtrlArea", ProofCode, KeyNo, Rownum);
							
							var BizTripItemItem = me.pageCombiAppComboData.BizTripItemList.filter(function(o) {
								var Items = o.Reserved1;
								if(isEmptyStr(Items))return false;
								if(me.requestType == "OVERSEA"&&(o.Code=='Toll'||o.Code=='Fuel'||o.Code=='Park'))return;
								return $.inArray(StandardBriefID.toString(),Items.split(",")) > -1
							});
					 		//출장항목 선택가능항목 변경
							if(!jQuery.isEmptyObject(BizTripItemItem)&&BizTripItemItem.length>0){
								htmlStr = me.comCostAppListEdit_ComboDataMake(BizTripItemItem, "Code", "CodeName",null,null,"Y");
								
								//D01 : 출장항목
								var D01Val = accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val();
								var D01Item = me.comCostAppListEdit_findListItem(BizTripItemItem, 'Code', D01Val);
								accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(htmlStr);
								if(jQuery.isEmptyObject(D01Item))
									D01Val = accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"] option:first").val()
								
								accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(D01Val).prop("selected", true);
								accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").trigger("onchange");
							}
						//}

						divItem["StandardBriefID"] = StandardBriefID;
						divItem["StandardBriefName"] = nullToBlank(getMap.StandardBriefName);

						divItem['TaxType'] = nullToBlank(getMap.TaxType);
						divItem['TaxCode'] = nullToBlank(getMap.TaxCode);
						divItem['AccountCode'] = nullToBlank(getMap.AccountCode);
						divItem['AccountName'] = nullToBlank(getMap.AccountName);
						divItem['StandardBriefDesc'] = nullToBlank(getMap.StandardBriefDesc);
						
						$("[name=BriefSelectField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(StandardBriefID);
						$("[name=DivAccCd][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(getMap.AccountCode);
						$("[name=DivAccNm][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(getMap.AccountName);
						
						me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "AccountCode", getMap.AccountCode);
						me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "AccountName", getMap.AccountName);
						me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "StandardBriefID", StandardBriefID);
						me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "StandardBriefName", getMap.StandardBriefName);
						
						if(me.requestType == "SELFDEVELOP") {
							me.comCostAppListEdit_SelfDevelopDetailSet(ProofCode, KeyNo, Rownum, getMap.StandardBriefName);
						}
					}
				}
			}, 
			
			comCostAppListEdit_BriefValSetCO : async function(ProofCode, KeyNo, Rownum, StandardBriefID,divItem) {
				var me = this;

				var BriefMap = me.pageCombiAppComboData.BriefMap
				var getMap = BriefMap[divItem.StandardBriefID];
				if(getMap==null){
					getMap = {};
				}
				if(me.appType == "CO") {
					await accountCtrl._setCtrlField(me, nullToBlank(getMap.CtrlCode), KeyNo, Rownum, ProofCode,divItem);
					accountCtrl._onSaveJson(me, null, "CtrlArea", ProofCode, KeyNo,Rownum);
				}
			}, 
			
			
			//업체 선택 팝업 호출
			combiCostApp_callVendorPopup : function(ProofCode, KeyNo, BusinessNumber, isAlterPayee, isProvider) { var me = this; me.comCostAppListEdit_callVendorPopup(ProofCode, KeyNo, BusinessNumber, isAlterPayee, isProvider); },
			comCostAppListEdit_callVendorPopup : function(ProofCode, KeyNo, BusinessNumber, isAlterPayee, isProvider) {
				var me = this;
				
				me.tempVal.ProofCode = ProofCode;
				me.tempVal.KeyNo = KeyNo;
				me.tempVal.isAlterPayee = isAlterPayee;
				me.tempVal.isProvider = isProvider;
				
				var isPE = "N";
				if(ProofCode=="EtcEvid"){
					isPE = $("[name=etcEvidRadio][keyno="+KeyNo+"]:checked").val();
				}
				
				var popupID		=	"vendorSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_vendor'/>";
				var popupName	=	"VendorSearchPopup";
				var callBack	=	"comCostAppListEdit_getVendorInfo";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"isPE="	+	isPE	+	"&"
								+	me.pageOpenerIDStr
								+	"companyCode="	+	me.CompanyCode + "&"
								+	"callBackFunc="	+	callBack;
				if(typeof(BusinessNumber) != "undefined"){
					url += "&businessNumber=" + BusinessNumber;
				}
				Common.open(	"",popupID,popupTit,url,"700px","630px","iframe",true,null,null,true);
			},

			//업체의 추가정보 조회
			comCostAppListEdit_getVendorInfo : function(obj) {
				var me = this;
				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				var isAlterPayee = me.tempVal.isAlterPayee;
				var isProvider = me.tempVal.isProvider;
				
				// 업체 자동 바인딩 시 호출하면 tempObj가 없으므로, 호출 시 KeyNo와 ProofCode 같이 넘겨줌.
				if(nullToBlank(ProofCode) == "") {
					ProofCode = obj.ProofCode;
				}
				if(nullToBlank(KeyNo) == "") {
					KeyNo = obj.KeyNo;
				}
				
				// 업체의 은행계좌 정보 초기화
				me.comCostAppListEdit_initAccountInfo(ProofCode, KeyNo);
				
				$.ajax({
					url:"/account/baseInfo/searchVendorDetail.do",
					cache: false,
					data:{
						VendorID : obj.VendorID
					},
					success:function (data) {
						if(data.result == "ok"){
							var vdInfo = data.data;
							
							if(isAlterPayee) {
								me.comCostAppListEdit_setListVal(ProofCode, "AlterPayeeNo", KeyNo, vdInfo.BusinessNumber);
								me.comCostAppListEdit_setListVal(ProofCode, "AlterPayeeName", KeyNo, vdInfo.VendorName);
	
								var nmField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AlterPayeeName]");
								var cdField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AlterPayeeNo]");
								
								nmField.val(vdInfo.VendorName);
								cdField.val(vdInfo.BusinessNumber);
							} else {
								if(isProvider) {
									me.comCostAppListEdit_setListVal(ProofCode, "ProviderNo", KeyNo, vdInfo.BusinessNumber);
									me.comCostAppListEdit_setListVal(ProofCode, "ProviderName", KeyNo, vdInfo.VendorName);
		
									var nmField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=ProviderName]");
									var cdField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=ProviderNo]");
									
									nmField.val(vdInfo.VendorName);
									cdField.val(vdInfo.BusinessNumber);		
								}
								me.comCostAppListEdit_setListVal(ProofCode, "VendorID", KeyNo, vdInfo.VendorID);
								me.comCostAppListEdit_setListVal(ProofCode, "VendorNo", KeyNo, vdInfo.VendorNo);
								me.comCostAppListEdit_setListVal(ProofCode, "VendorName", KeyNo, vdInfo.VendorName);
								me.comCostAppListEdit_setListVal(ProofCode, "BusinessNumber", KeyNo, vdInfo.BusinessNumber);
	
								var nmField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=VendorName]");
								var vnField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=VendorNo]");
								
								nmField.val(vdInfo.VendorName);
								vnField.val(vdInfo.BusinessNumber);
								
								// 은행계좌 정보 세팅
								me.comCostAppListEdit_setAccountInfo(vdInfo, ProofCode, KeyNo, obj.AccountInfo, obj.AccountHolder, obj.AccountBank, obj.AccountBankName);
								
								if(ProofCode == "EtcEvid" || ProofCode == "CashBill" || ProofCode == "TaxBill" || ProofCode == "PaperBill"){	
									// 지급조건, 지급방법
									var payMethod = $("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=PayMethod]");
									var payType = $("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=PayType]");

									var payMethodStr = (obj.PayMethod == undefined ? nullToBlank(vdInfo.PaymentMethod) : obj.PayMethod);
									var payTypeStr = (obj.PayType == undefined ? nullToBlank(vdInfo.PaymentCondition) : obj.PayType);
									
									payMethod.val(payMethodStr);
									payType.val(payTypeStr);
									
									me.comCostAppListEdit_setListVal(ProofCode, "PayMethod", KeyNo, payMethodStr);
									me.comCostAppListEdit_setListVal(ProofCode, "PayType", KeyNo, payTypeStr);
								}
							}
							
							me.tempVal = {};
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});
			},
			
			//업체의 은행계좌 정보  초기화
			comCostAppListEdit_initAccountInfo : function(pProofCode, pKeyNo) {
				var me = this;
				var accInfo = $("[name=ComboSelect][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountInfo]");
				var accHolder = $("[name=CombiCostInputField][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountHolder]");
				var accBank = $("[name=CombiCostInputField][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountBank]");
				var accBankName = $("[name=CombiCostInputField][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountBank]");
				
				// 기존에 조회한 은행계좌 삭제
				if(pProofCode == "EtcEvid" || pProofCode == "CashBill" || pProofCode == "TaxBill" || pProofCode == "PaperBill"){
					accInfo.find("option[value!=''][value!='DirectInput']").remove();

					accInfo.find("option:first").prop("selected", true);
					accHolder.val("");
					accBank.val("");
					accBankName.val("");
					
					me.comCostAppListEdit_setListVal(pProofCode, "AccountInfo", pKeyNo, "");
					me.comCostAppListEdit_setListVal(pProofCode, "AccountHolder", pKeyNo, "");
					me.comCostAppListEdit_setListVal(pProofCode, "AccountBank", pKeyNo, "");
					me.comCostAppListEdit_setListVal(pProofCode, "AccountBankName", pKeyNo, "");
					
					accInfo.trigger("change");
				}
			},
				
			//업체의 은행계좌 정보 세팅
			comCostAppListEdit_setAccountInfo : function(pVendorInfo, pProofCode, pKeyNo, pAccountInfo, pAccountHolder, pAccountBank, pAccountBankName) {
				var me = this;
				
				if((pVendorInfo.BankAccountNo != undefined && pVendorInfo.BankAccountNo != "") || (pAccountInfo != undefined && pAccountInfo != "")) {
					var accInfo = $("[name=ComboSelect][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountInfo]");
					var accHolder = $("[name=CombiCostInputField][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountHolder]");
					var accBank = $("[name=CombiCostInputField][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountBank]");
					var accBankName = $("[name=CombiCostInputField][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountBankName]");
					
					var accInfoStr = "";
					var accHolderStr = "";
					var accBankStr = "";
					var accBankNameStr = "";
					
					var sHtml = "";
					
					for(var i = 0; i < pVendorInfo.BankAccountNo.split(",").length; i++) {
						sHtml += "<option value='" + pVendorInfo.BankAccountNo.split(",")[i] + "' index='" + i + "' data='" + JSON.stringify(pVendorInfo) + "'>" 
							+ pVendorInfo.BankAccountNo.split(",")[i] + "</option>";
					}
					
					accInfo.append(sHtml);
					
					accInfoStr = (pAccountInfo ? pAccountInfo : pVendorInfo.BankAccountNo.split(",")[0]);
					accHolderStr = (pAccountHolder ? pAccountHolder : pVendorInfo.BankAccountName.split(",")[0]);
					accBankStr = (pAccountBank ? pAccountBank : pVendorInfo.BankCode.split(",")[0]);
					accBankNameStr = (pAccountBankName ? pAccountBankName : pVendorInfo.BankName.split(",")[0]);
					
					accInfo.val(accInfoStr);
					accHolder.val(accHolderStr);
					accBank.val(accBankStr);
					accBankName.val(accBankNameStr);
					
					me.comCostAppListEdit_setListVal(pProofCode, "AccountInfo", pKeyNo, accInfoStr);
					me.comCostAppListEdit_setListVal(pProofCode, "AccountHolder", pKeyNo, accHolderStr);
					me.comCostAppListEdit_setListVal(pProofCode, "AccountBank", pKeyNo, accBankStr);
					me.comCostAppListEdit_setListVal(pProofCode, "AccountBankName", pKeyNo, accBankNameStr);
				}
			},

			
			combiCostApp_callBankPopup : function(ProofCode, KeyNo) {
				var me = this;
				var popupID		=	"bankSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_bankSelect'/>";
				var popupName	=	"BankSearchPopup";
				var callBack	=	"combiCostApp_setBankInfo";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
					+	"popupID="		+	popupID		+	"&"
					+	"popupName="	+	popupName	+	"&"
					+	me.pageOpenerIDStr
					+	"companyCode="	+	me.CompanyCode	+ "&"
					+	"callBackFunc="	+	callBack;
				
				me.tempVal.ProofCode = ProofCode;
				me.tempVal.KeyNo = KeyNo;
				
				Common.open(	"",popupID,popupTit,url,"350px","400px","iframe",true,null,null,true);
			},
			
			combiCostApp_setBankInfo : function(obj) {
				var me = this;
				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;

				$("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountBank]").val(obj.Code);
				$("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountBankName]").val(obj.CodeName);

				me.comCostAppListEdit_setListVal(ProofCode, "AccountBank", KeyNo, obj.Code);
				me.comCostAppListEdit_setListVal(ProofCode, "AccountBankName", KeyNo, obj.CodeName);
			},

			combiCostApp_changeDate : function(obj, ProofCode, KeyNo, Field){ var me = this; me.comCostAppListEdit_changeDate(obj, KeyNo, ProofCode, Field); },
			simpApp_onDateChange : function(obj, KeyNo, ProofCode, Field) { var me = this; me.comCostAppListEdit_changeDate(obj, KeyNo, ProofCode, Field); },
			comCostAppListEdit_changeDate : function(obj, KeyNo, ProofCode, Field){
				var me = this;

				var pageList = me.pageExpenceAppTarget;
				var getId = obj.id
				var Strval = coviCtrl.getSimpleCalendar(getId);
				var val = Strval.replaceAll(".","");
				me.comCostAppListEdit_setListVal(ProofCode, Field, KeyNo, val);
				me.comCostAppListEdit_setListVal(ProofCode, Field+"Str", KeyNo, Strval);

				if(me.requestType == "BIZTRIP" || me.requestType == "OVERSEA") {
					if(field == 'ProofDate') {			
						//출장비 내역 가져오기
						opener[me.fileName].comCostAppView_loadBizTripExpenceList();
					}
				}
				
				if(me.exchangeIsUse == "Y") {
					$("[name=CurrencySelectField]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");
				}
				
				// 외주용역 당월 전체일수 입력
				if(ProofCode == "EtcEvid" && me.requestType == "OUTSOURCING" && $("[name=etcEvidRadio][keyno="+KeyNo+"]:checked").val() == "Y"){
					var workingDay = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=WorkingDay]");
					var arrVal = Strval.split(".");
					if(Field == "ProofDate" && workingDay.length && arrVal.length > 2){
						var wDay = new Date(arrVal[0],arrVal[1],0).getDate();
						workingDay.val(toAmtFormat(wDay));
						//me.comCostAppListEdit_setListVal(ProofCode, "WorkingDay", KeyNo, wDay);
						me.combiCostApp_InputValChange(workingDay[0], ProofCode, KeyNo, "WorkingDay");
					}
				}
				
			},
			
			combiCostApp_InputValChange : function(obj, ProofCode, KeyNo, Field) {
				var me = this;
				
				var val = obj.value;
				var getItem = me.pageExpenceAppTarget;

				var getId = obj.id;
				var getTag = obj.getAttribute("tag");
				var field = obj.getAttribute("datafield");
				if(getTag == "Amount"){
					val = val.replace(/[^0-9\-,.]/g, "");					
					var numVal = ckNaN(AmttoNumFormat(val));
					if(numVal>99999999999){
						numVal = 99999999999;
					}
					val = numVal;
					obj.value = toAmtFormat(numVal);
					
					if(ProofCode == "CorpCard") {
						var repAmountField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=RepAmount]");
						var totalAmountVal = $(obj).parents("li").find(".tx_ta").text().replace(/,/gi, "");
						var repAmountVal = totalAmountVal - numVal;
						repAmountField.val(toAmtFormat(repAmountVal));
						me.comCostAppListEdit_setListVal(ProofCode, "RepAmount", KeyNo, repAmountVal);
					}
					
					if(ProofCode == "EtcEvid") {
						//var totalAmount = val;
						var totalAmount = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TotalAmount]").val().replace(/,/gi, "")*1;
						numVal = totalAmount;
						// 외주용역 비용정산의 원천세의 경우만 고용보험/산재보험 추가
						if(me.requestType == "OUTSOURCING" && $("[name=etcEvidRadio][keyno="+KeyNo+"]:checked").val() == "Y"){
							if(Field == "EmpInsurance" || Field == "AccidInsurance"){
								var empInsurance = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=EmpInsurance]");
								var empInsuranceVal = (empInsurance.length) ? Number(empInsurance.val().replace(/,/gi, '')) : 0;
								var accidInsurance = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccidInsurance]");
								var accidInsuranceVal = (accidInsurance.length) ? Number(accidInsurance.val().replace(/,/gi, '')) : 0;
								numVal = numVal - (empInsuranceVal + accidInsuranceVal);
							}else{
								// 221017 고용보험 : ((합계금액-(합계금액*15.7%))*1.6%)/2 , 합계금액이 1330000 보다 작으면 1330000 으로 계산
								// 221104 고용보험 : ((합계금액*1.6%)/2), 합계금액이 1330000 보다 작으면 1330000 으로 계산
								var empInsurance = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=EmpInsurance]");
								if(empInsurance.length){
									var empInsuranceVal = 0;
									var empBaseAmt = Common.getBaseConfig("EmpInsurBaseAmt")*1; // 외주용역 고용보험 계산 기준금액(1330000)
									var empRate = Common.getBaseConfig("EmpInsurRate")*1; // 외주용역 고용보험 계산 비율(1.6%/2 = 0.008)
									if(!empRate) empRate = 1;
									// 합계금액이 +/-일때 별도처리 , 합계금액이 0이면 0으로처리
									if(totalAmount > 0){
										if(empBaseAmt && totalAmount < empBaseAmt) empInsuranceVal = empBaseAmt*empRate;
										else empInsuranceVal = totalAmount*empRate; 
									} else if(totalAmount < 0){
										empBaseAmt = -empBaseAmt;
										if(empBaseAmt && totalAmount > empBaseAmt) empInsuranceVal = empBaseAmt*empRate;
										else empInsuranceVal = totalAmount*empRate; 
									}
									empInsuranceVal = empInsuranceVal - empInsuranceVal % 10;
									empInsurance.val(toAmtFormat(empInsuranceVal));
									me.comCostAppListEdit_setListVal(ProofCode, "EmpInsurance", KeyNo, empInsuranceVal);
									numVal = numVal - empInsuranceVal;
								}
								// 220715 산재보험 : 합계금액이 3,937,500원 보다 작으면 합계금액*5.8/1000/2, 크면 3,937,500*5.8/1000/2
								// 221104 산재보험 : (3,937,500/당 월 전체 일 수*(실제 근무일 수)*0.58%)/2
								// 230802 산재보험 : (합계금액/당 월 전체 일수*(실제 근무일 수)*0.58%)/2
								//                >> 230802 처리 : 추후 변경을 위해 기준금액 설정(AccidInsurBaseAmt)을 0으로 바꾸고 기준금액 0이면 합계금액을 이용하도록 변경
								var accidInsurance = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccidInsurance]");
								var workingDay = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=WorkingDay]");
								var actualDay = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=ActualDay]");
								if(accidInsurance.length && workingDay.length && actualDay.length){
									if(Field == "WorkingDay" || Field == "ActualDay"){ // 일수 값 제어(마이너스,31일 초과)
										var tmpObj = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field="+Field+"]");
										var tmpVal = (tmpObj.length) ? Number(tmpObj.val().replace(/,/gi, '')) : 0;
										if(tmpVal < 0) tmpVal = tmpVal*-1;
										if(tmpVal > 31) tmpVal = 31;
										tmpObj.val(toAmtFormat(tmpVal));
										me.comCostAppListEdit_setListVal(ProofCode, Field, KeyNo, tmpVal);
									}
									var workingDayVal = Number(workingDay.val().replace(/,/gi, ''));
									var actualDayVal = Number(actualDay.val().replace(/,/gi, ''));
									var accidInsuranceVal = 0;
									if(workingDayVal && actualDayVal){ // 일수가 없으면 0으로 처리
										var accidBaseAmt = Common.getBaseConfig("AccidInsurBaseAmt")*1; // 외주용역 산재보험 계산 기준금액(3937500)
										var accidRate = Common.getBaseConfig("AccidInsurRate")*1; // 외주용역 산재보험 계산 비율(0.58%/2 = 0.0029)
										if(!accidRate) accidRate = 1;
										if(!accidBaseAmt) accidBaseAmt = totalAmount; // 기준금액이 0이면 합계금액 이용
										accidInsuranceVal = accidBaseAmt/workingDayVal*actualDayVal*accidRate;
									}
									accidInsuranceVal = accidInsuranceVal - accidInsuranceVal % 10;
									accidInsurance.val(toAmtFormat(accidInsuranceVal));
									me.comCostAppListEdit_setListVal(ProofCode, "AccidInsurance", KeyNo, accidInsuranceVal);
									numVal = numVal - accidInsuranceVal;
								}
							}
						}
						if($("select[id*=incomTax]").find("option:selected").val() != "") {
							var incomTaxAmountField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=IncomTaxAmt]");
							var incomTax = JSON.parse($("select[id*=incomTax]").find("option:selected").attr("tag")).ReservedFloat;
							var incomTaxAmount = totalAmount * incomTax / 100;
							incomTaxAmount = incomTaxAmount - incomTaxAmount % 10;
							incomTaxAmountField.val(toAmtFormat(incomTaxAmount));
							me.comCostAppListEdit_setListVal(ProofCode, "IncomTaxAmt", KeyNo, incomTaxAmount);
							numVal = numVal - incomTaxAmount;
						}
						if($("select[id*=localTax]").find("option:selected").val() != "") {
							var localTaxAmountField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=LocalTaxAmt]");
							var localTax = JSON.parse($("select[id*=localTax]").find("option:selected").attr("tag")).ReservedFloat;
							var localTaxAmount = totalAmount * localTax / 100;
							localTaxAmount = localTaxAmount - localTaxAmount % 10;
							localTaxAmountField.val(toAmtFormat(localTaxAmount));
							me.comCostAppListEdit_setListVal(ProofCode, "LocalTaxAmt", KeyNo, localTaxAmount);
							numVal = numVal - localTaxAmount;
						}
						if(Field == "TotalAmount") {
							var repAmountField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=RepAmount]");
							repAmountField.val(toAmtFormat(totalAmount));
							me.comCostAppListEdit_setListVal(ProofCode, "RepAmount", KeyNo, totalAmount);
						}
						if((Field == "ExchangeRate" || Field == "LocalAmount") && me.exchangeIsUse == "Y"){
							var calName = (Field == "ExchangeRate" ? "LocalAmountField" : "ExchangeRateField");
							var calVal =  Number(AmttoNumFormat($("[name="+calName+"][proofcode="+ProofCode+"][keyno="+KeyNo+"]").val()));
							var curType = $("[name=CurrencySelectField][proofcode="+ProofCode+"][keyno="+KeyNo+"]").val();
							var totalAmount = 0;
							
							//입력값 소수점 두자리  처리
							if (val % 1 > 0) { val = val.toFixed(2); }
							
							$("[name="+Field+"][proofcode="+ProofCode+"][keyno="+KeyNo+"]").val(toAmtFormat(val));
							me.comCostAppListEdit_setListVal(ProofCode, KeyNo, Field, val);
							
							totalAmount = Number(val*calVal);
							//엔화 예외처리
							if (curType == "JPY") { totalAmount = totalAmount / 100; }
							//증빙합계 소수점 두자리  처리
							if (totalAmount % 1 > 0) { totalAmount = totalAmount.toFixed(2); }
							
							$("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TotalAmount]").val(toAmtFormat(totalAmount));
							$("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TotalAmount]").trigger("onblur");
						}
					}
					
					if(ProofCode == "PaperBill") {
						if(Field == "TaxAmount" || Field == "TotalAmount") {
							var totalAmount = AmttoNumFormat($("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TotalAmount]").val());
							var taxAmount = AmttoNumFormat($("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxAmount]").val());
							var setVal = (Field == "TaxAmount" ? (totalAmount - numVal) : (numVal - taxAmount));
							
							var repAmountField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=RepAmount]");
							repAmountField.val(toAmtFormat(setVal));
							me.comCostAppListEdit_setListVal(ProofCode, "RepAmount", KeyNo, setVal);
							
							var divList = getItem.divList;
							if(divList != null){
								if(divList.length==1){
									var divItem = divList[0];
									me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, divItem.Rownum, "Amount", setVal);
									
									var amtField = $("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+divItem.Rownum+"][datafield=Amount]")
									amtField.val(toAmtFormat(setVal));
								}
							}
						}
					}
					
					if((ProofCode=="EtcEvid" || ProofCode=="PrivateCard"  || ProofCode=="Receipt") && (Field == "TotalAmount" || Field == "EmpInsurance" || Field == "AccidInsurance" || Field == "WorkingDay" || Field == "ActualDay")){						
						var divList = getItem.divList;
						if(divList != null){
							if(divList.length==1){
								var divItem = divList[0];
								me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, divItem.Rownum, "Amount", numVal);
								
								var amtField = $("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+divItem.Rownum+"][datafield=Amount]")
								amtField.val(toAmtFormat(numVal));
							}
						}
					}
					
				}
				me.comCostAppListEdit_setListVal(ProofCode, Field, KeyNo, val);
			},
			
			simpApp_onInputFieldChange : function(obj, ProofCode, fieldNm) {
				var me = this; 
				
				var getName = obj.name;
				var val = obj.value;
				var KeyNo = obj.getAttribute("keyno");
				
				var getItem = me.pageExpenceAppTarget;
				var Rownum = getItem.divList[0].Rownum;

				if(getName == "AmountField"
						|| getName == "TotalAmountField"
						|| getName ==  "TaxAmountField"){
					val = val.replace(/[^0-9\-,.]/g, "");
					var numVal = ckNaN(AmttoNumFormat(val))
					if(numVal>99999999999){
						numVal = 99999999999;
					}
					val = Number(AmttoNumFormat(val));
					
					$("[name="+getName+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(toAmtFormat(numVal));
					if(getName=="TotalAmountField"){
						$("[name=AmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(toAmtFormat(numVal));
						me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "Amount", val);
					}
				}

				me.comCostAppListEdit_setListVal(ProofCode, fieldNm, KeyNo, val);
			},
			
			combiCostApp_ComboChange : function(obj, ProofCode, KeyNo, Field, Rownum) {
				var me = this;
				
				var val = obj.value;
				var getItem = me.pageExpenceAppTarget;

				me.comCostAppListEdit_setListVal(ProofCode, Field, KeyNo, val);

				if(Field=="TaxType"){
					var TCList = me.pageCombiAppComboData.TaxCodeList;
					var TaxCodeOption = me.comCostAppListEdit_MakeTCData(ProofCode, TCList, val);
					
					var TCField = $("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxCode]");
					TCField.html(TaxCodeOption);
					if($(TCField).find("option").length == 2) {
						$(TCField).find("option").eq(1).attr("selected", "selected");
						$(TCField).trigger("change");
					}
				}
				
				if(Field=="IncomTax" || Field=="LocalTax"){
					var taxField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field="+Field+"Amt]");
					var totalAmount = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TotalAmount]").val().replace(/,/gi, '');
					var taxAmount = 0;
					var amount = 0;
					
					if($(obj).val() == "") {
						taxField.val(0);
						me.comCostAppListEdit_setListVal(ProofCode, Field+"Amt", KeyNo, 0);
					} else {
						var tax = JSON.parse($(obj).find("option:selected").attr("tag")).ReservedFloat;
						taxAmount = totalAmount * tax / 100;
						taxAmount = taxAmount - taxAmount % 10;
						taxField.val(toAmtFormat(taxAmount));
						me.comCostAppListEdit_setListVal(ProofCode, Field+"Amt", KeyNo, taxAmount);
					}
					
					// 청구금액 & 공급가액 에 합계금액 - (소득세 + 지방세) 값 바인딩
					var incomTaxAmount = Number($("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=IncomTaxAmt]").val().replace(/,/gi, ''));
					var localTaxAmount = Number($("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=LocalTaxAmt]").val().replace(/,/gi, ''));
					amount = totalAmount - (incomTaxAmount + localTaxAmount);

					// 외주용역 비용정산의 원천세의 경우만 고용보험/산재보험 추가
					if(me.requestType == "OUTSOURCING" && $("[name=etcEvidRadio][keyno="+KeyNo+"]:checked").val() == "Y"){
						var empInsurance = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=EmpInsurance]");
						var empInsuranceVal = (empInsurance.length) ? Number(empInsurance.val().replace(/,/gi, '')) : 0;
						var accidInsurance = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccidInsurance]");
						var accidInsuranceVal = (accidInsurance.length) ? Number(accidInsurance.val().replace(/,/gi, '')) : 0;
						amount = amount - (empInsuranceVal + accidInsuranceVal);
					}
					if(!me.isModified) {
						//첫번째 세부증빙 청구금액 값 바인딩 (input & div json object)
						var divList = getItem.divList;
						if(divList != null){
							var divItem = divList[0];
							me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, divItem.Rownum, "Amount", amount);
							var amtField = $("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+divItem.Rownum+"][datafield=Amount]");
							amtField.val(toAmtFormat(amount));
						}
	
						//공급가액 값 바인딩 (input & list json object)
						me.comCostAppListEdit_setListVal(ProofCode, "RepAmount", KeyNo, totalAmount);
						var repField = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=RepAmount]");
						repField.val(toAmtFormat(totalAmount));
					}
					
					if(Field == "IncomTax") {
						me.comCostAppListEdit_setListVal(ProofCode, "IncomeTax", KeyNo, val);
					}
				}
				
				if(Field=="AccountInfo") {
					if(val == "DirectInput") {
						$("[name=BankInputArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").show();
						$("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountInfo]").parents("td").removeAttr("colspan");
						$("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountHolder]").removeAttr("disabled");
						
						//기존에 직접 입력된 계좌번호 데이터 다시 바인딩
						if($("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountInfo]").val() != "") {
							$("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountInfo]").trigger("onkeyup");
						}
					} else {
						$("[name=BankInputArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").hide();
						$("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountInfo]").parents("td").attr("colspan", "3");
						$("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountHolder]").attr("disabled", "disabled");

						var accHolder = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountHolder]");
						var accBank = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountBank]");
						var accBankName = $("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountBankName]");
						
						var accHolderStr = "";
						var accBankStr = "";
						var accBankNameStr = "";
						
						if($(obj).find("option:selected").attr("data") != undefined) {
							var bankInfo = JSON.parse($(obj).find("option:selected").attr("data"));
							
							if(ProofCode == "CorpCard") {
								accHolderStr = bankInfo.BankAccountName;
								accBankStr = bankInfo.BankCode;
								accBankNameStr = bankInfo.BankName;
							} else {
								var index = $(obj).find("option:selected").attr("index");
								
								accHolderStr = bankInfo.BankAccountName.split(",")[index];
								accBankStr = bankInfo.BankCode.split(",")[index];
								accBankNameStr = bankInfo.BankName.split(",")[index];
							}
						}
						
						accHolder.val(accHolderStr);
						accBank.val(accBankStr);
						accBankName.val(accBankNameStr);
						
						me.comCostAppListEdit_setListVal(ProofCode, "AccountHolder", KeyNo, accHolderStr);
						me.comCostAppListEdit_setListVal(ProofCode, "AccountBank", KeyNo, accBankStr);
						me.comCostAppListEdit_setListVal(ProofCode, "AccountBankName", KeyNo, accBankNameStr);
					}
				}
				
				if(Field=="BizTripItem") {
					var objTem = $("[name=DivAmountField][keyno="+KeyNo+"][proofcode="+ProofCode+"][rownum='"+Rownum+"']");
					var tempObj = $.extend(true, {}, getItem); 
					
					accountCtrl._modifyItemJson(me, 'D02', KeyNo, Rownum, ProofCode, me.comCostAppListEdit_findListItem(getItem.divList, "Rownum", Rownum), "DEL");//유류비
					accountCtrl._modifyItemJson(me, 'D03', KeyNo, Rownum, ProofCode, me.comCostAppListEdit_findListItem(getItem.divList, "Rownum", Rownum), "DEL");//일비
					
					if(val == "Daily") {
						$(objTem).attr("disabled", "disabled"); //일비는 청구금액 수동입력 불가능
						getItem = tempObj;
						accountCtrl._modifyItemJson(me, 'D03', KeyNo, Rownum, ProofCode, me.comCostAppListEdit_findListItem(tempObj.divList, "Rownum", Rownum), "ADD");
					} else {
						$(objTem).removeAttr("disabled");
						
						if(val == "Fuel") {
							getItem = tempObj;
							accountCtrl._modifyItemJson(me, 'D02', KeyNo, Rownum, ProofCode, me.comCostAppListEdit_findListItem(tempObj.divList, "Rownum", Rownum), "ADD");
						}
					}
				}
				
				if(Field=="Currency") {
					var exchangeRateField = $("[name=ExchangeRateField][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
					var localAmountField = $("[name=LocalAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
					
					if(val == "KRW") {
						$("span[name=ExRateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").hide();
						
						// 환율 초기화
						exchangeRateField.val(0);
						exchangeRateField.trigger("onblur");
						// 현지금액 초기화
						localAmountField.val(0);
						localAmountField.trigger("onblur");
					} else {
						var proofDateField = $("[name=DateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
						var proofDate = proofDateField.find("input[type=text]").val();
						
						// 환율, 현지금액 영역 show
						$("span[name=ExRateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").show();
						
						// 증빙날짜 비어있을 때 오늘날짜
						if(proofDate == "") {
							var today = new Date().format('yyyy.MM.dd');
							var todayHidden = new Date(today).format("MM/dd/yyyy");
							
							proofDateField.find("input[type=text]").val(today);
							proofDateField.find("input[type=hidden]").val(todayHidden);
							proofDateField.trigger("onchange");
							
							proofDate = today;
						}
						
						// 환율 적용
						var exchangeRate = accComm.getExchangeRate(proofDate, val);
						exchangeRateField.val(exchangeRate == "" || exchangeRate == undefined ? 0 : exchangeRate);
						exchangeRateField.trigger("onblur");
						
						// 현지금액 비어있을 때 0원
						if(localAmountField.val() == "") {
							localAmountField.val(0);
							localAmountField.trigger("onblur");
						}
					}
				}
			},
			
			simpApp_ComboChange : function(obj, type, ProofCode, KeyNo, Rownum) {
				var me = this;
				var val = obj.value;

				me.comCostAppListEdit_setListVal(ProofCode, type, KeyNo, val);
				
				var Item = me.pageExpenceAppTarget;

				if(type == "StandardBriefID"){
					me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, type, val);
					me.comCostAppListEdit_BriefValSet(ProofCode, KeyNo, Rownum, val);
					
					if(me.requestType=="INVEST") {
						me.comCostAppListEdit_InvestTargetSet(ProofCode, KeyNo, '');
					} else {
						var BizTripItemItem = me.pageCombiAppComboData.BizTripItemList.filter(function(o) {
							var Items = o.Reserved1;
							if(isEmptyStr(Items))return false;
							if(me.requestType == "OVERSEA"&&(o.Code=='Toll'||o.Code=='Fuel'||o.Code=='Park'))return;
							return $.inArray(val.toString(),Items.split(",")) > -1
						});
					
					
						//출장항목 선택가능항목 변경
						if(!jQuery.isEmptyObject(BizTripItemItem)&&BizTripItemItem.length>0){
							htmlStr = me.comCostAppListEdit_ComboDataMake(BizTripItemItem, "Code", "CodeName",null,"Y");
							//D01 : 출장항목
							var D01Val = $("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val();
							var D01Item = me.comCostAppListEdit_findListItem(BizTripItemItem, 'Code', D01Val);
							$("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(htmlStr);
							if(jQuery.isEmptyObject(D01Item))
								D01Val = $("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"] option:first").val()
							
							$("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(D01Val).prop("selected", true);
							$("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").trigger("onchange");
						}
					}
				}
				
				if(me.requestType=="INVEST") {
					if(type=="InvestItem") {
						var getItem = me.comCostAppListEdit_findListItem(me.pageCombiAppComboData.InvestItemList, 'Code', val);
						var desc = getItem.Reserved1;//경조항목 별 설명 
						desc = isEmptyStr(desc)?'':desc;
						
						if(desc != '') {
							$("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").show();
							$("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").html(desc);
						} else {
							$("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").hide();
						}
						
						me.comCostAppListEdit_InvestTargetSet(ProofCode, KeyNo, val); //경조항목 별 경조 대상 select box 바인딩
					} else if(type=="InvestTarget") {
						if(nullToBlank(me.tempVal.saveType) == "" && me.tempVal.isLoad) {
							var getItem = me.comCostAppListEdit_findListItem(me.pageCombiAppComboData.InvestTargetList, 'Code', val);
							var amount = getItem.ReservedInt;
							amount = isEmptyStr(amount)?0:amount;
							
							$("[name=TotalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(amount);
							$("[name=TotalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]")[0].onkeyup();
							me.comCostAppListEdit_setListVal(ProofCode, "TotalAmount", KeyNo, amount);
							
							$("[name=AmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(amount);
							$("[name=AmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]")[0].onkeyup();
							me.comCostAppListEdit_setListVal(ProofCode, "Amount", KeyNo, amount);
						}
					}
				}
				if(type=="BizTripItem") {
					var objTem = $("[name=AmountField][keyno="+KeyNo+"][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					var tempObj = $.extend(true, {}, Item); 
					//Rownum = isEmptyStr(Item.divList[0].Rownum) ? 0 :Item.divList[0].Rownum;
					var idx = accFindIdx(Item.divList, "Rownum", Rownum);
					Rownum = Item.divList[idx].Rownum;
					
					accountCtrl._modifyItemJson(me, 'D02', KeyNo, Rownum, ProofCode, Item.divList[idx], "DEL");
					accountCtrl._modifyItemJson(me, 'D03', KeyNo, Rownum, ProofCode, Item.divList[idx], "DEL");
					
					if(val == "Daily") {
						$(objTem).attr("disabled", "disabled"); //일비는 청구금액 수동입력 불가능
						
						Item.divList[idx].ReservedStr2_Div['D03'] = tempObj.ReservedStr2_Div['D03'] ;
						Item.divList[idx].ReservedStr2_Div['D03_desc'] = tempObj.ReservedStr2_Div['D03_desc'] ;
						Item.divList[idx].ReservedStr3_Div['D03'] = tempObj.ReservedStr3_Div['D03'] ;
						Item.divList[idx].ReservedStr3_Div['D03_desc'] = tempObj.ReservedStr3_Div['D03_desc'] ;						
						accountCtrl._modifyItemJson(me, 'D03', KeyNo, Rownum, ProofCode, Item.divList[idx], "ADD");
					} else {
						$(objTem).removeAttr("disabled");
						
						if(val == "Fuel") {
							Item.divList[idx].ReservedStr2_Div['D02'] = tempObj.ReservedStr2_Div['D02'] ;
							Item.divList[idx].ReservedStr2_Div['D02_desc'] = tempObj.ReservedStr2_Div['D02_desc'] ;
							Item.divList[idx].ReservedStr3_Div['D02'] = tempObj.ReservedStr3_Div['D02'] ;
							Item.divList[idx].ReservedStr3_Div['D02_desc'] = tempObj.ReservedStr3_Div['D02_desc'] ;							
							accountCtrl._modifyItemJson(me, 'D02', KeyNo, Rownum, ProofCode, Item.divList[idx], "ADD");
						}
					}
				}
			},
			
			//세금코드는 증빙유형과 세금유형에 따라 동적 생성
			comCostAppListEdit_MakeTCData : function(ProofCode, cdList, deduct) {
				var htmlStr = "<option value=''>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";	//선택
				if(deduct != "deduct" && deduct != "induct"){
					htmlStr = "<option value=''>"+ "<spring:message code='Cache.ACC_040' />" +"</option>";	//세금유형을 선택하세요.
					return htmlStr;
				}
				var deductYN = (deduct=="deduct")?"Y":"N"
				for(var i = 0; i < cdList.length; i++){
					var getCd = cdList[i];
					if(getCd.ProofCode == ProofCode && getCd.DeductionType == deductYN){
						htmlStr = htmlStr + "<option value='"+ getCd.Code +"'>"+ getCd.CodeName +"</option>"
					}
				}
				return htmlStr;
			},
			
			comCostAppListEdit_InvestTargetSet : function(ProofCode, KeyNo, InvestItem) {
				var me = this;
				
				var code = 'B01';//B01 : 경조항목
				var B01Val = $("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val();
				var InvestItem = me.pageCombiAppComboData.InvestTargetList.filter(function(o) {
									return $.inArray(B01Val.toString(), o.Reserved1.split(",")) > -1
								});
				
				code = 'B02';//B02 : 경조대상 
				var B02Val = $("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val();
				if(!jQuery.isEmptyObject(InvestItem)){
					htmlStr = me.comCostAppListEdit_ComboDataMake(InvestItem, "Code", "CodeName", null, "Y");
					$("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").html(htmlStr);
					
					var Item = me.comCostAppListEdit_findListItem(InvestItem, 'Code', B02Val);
					if(jQuery.isEmptyObject(Item))
						B02Val = $("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"] option:first").val()
					
					$("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(B02Val).prop("selected", true);
					$("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");
				}
			},
			
			comCostAppListEdit_findListItem : function(inputList, field, val) {
				var retVal = null;
				var arrCk = Array.isArray(inputList);
				if(arrCk){
					retVal = accFind(inputList, field, val);
				}
				return retVal
			},
			
			comCostAppListEdit_setListVal : function(ProofCode, fieldNm, KeyNo, val) {
				var me = this;
				var getItem = me.pageExpenceAppTarget;
				getItem[fieldNm] = val;
			},
			
			//세부증빙 list에 값 세팅
			comCostAppListEdit_setDivVal : function(ProofCode, KeyNo, Rownum, fieldNm, val) {
				var me = this;
				
				var getItem = me.pageExpenceAppTarget;
				if(!isEmptyStr(getItem.KeyNo)){
					var divItem = me.comCostAppListEdit_findListItem(getItem.divList, "Rownum", Rownum);
					divItem[fieldNm] = val;
					if(fieldNm == "Amount") {
						getItem.Amount = val;
						getItem.divSum = 0;
						for(var i = 0; i < getItem.divList.length; i++) {
							getItem.divSum += Number(AmttoNumFormat(getItem.divList[i].Amount));
						}
					}
				}
			},
			
			combiCostApp_divInputChange : function(obj, ProofCode, KeyNo, Rownum, jsonVal, type) { var me = this; me.comCostAppListEdit_divInputChange(obj, ProofCode, KeyNo, Rownum, jsonVal, type); },
			simpApp_divInputChange : function(obj, ProofCode, KeyNo, Rownum, jsonVal, type) { var me = this; me.comCostAppListEdit_divInputChange(obj, ProofCode, KeyNo, Rownum, jsonVal, type); },
			comCostAppListEdit_divInputChange : function(obj, ProofCode, KeyNo, Rownum, jsonVal, type) {
				var me = this;
				var field;
				var val;
				if(jsonVal != undefined )
				{
					if(type == "1"){
	                   	field = "ReservedStr2_Div";
						val = jsonVal;
		            }else if(type == "2"){
		               	field = "ReservedStr3_Div";
		                val = jsonVal;
		            }
				}
				else{
					var getName = obj.name;
					var getId = obj.id
					var getTag = obj.getAttribute("tag");
					field = obj.getAttribute("datafield");
					
					val = obj.value;

					if(getTag == "Amount"){
						val = val.charAt(0) == "-" ? val.charAt(0) + val.substr(1).replace(/[^0-9,.]/g, "") : val.replace(/[^0-9,.]/g, "");
						var numVal = ckNaN(AmttoNumFormat(val));
						if(numVal>99999999999){
							numVal = 99999999999;
						}
						val = numVal;
						obj.value = toAmtFormat(numVal);
					} else if(getTag == "Comment") {
						val = val.replace(/(?:\r\n|\r|\n)/gi, '<br>');
					}
				}
				me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, field, val);
			},
			
			//세부증빙(증빙분할) 복사 - SC
			simpApp_copyDiv : function(ProofCode, KeyNo) { var me = this; me.comSimpAppListEdit_divCopy(ProofCode, KeyNo); },
			simpApp_updateCopyDivHtml : function(divItem, ProofCode, KeyNo, copyRownum) { var me = this; me.comSimpAppListEdit_updateInputDivHtml(divItem, ProofCode, KeyNo, copyRownum); },
			
			comSimpAppListEdit_divCopy : function (ProofCode, KeyNo) {
				var me = this;
				
				var targetRow = $("[name=DivCheck][keyno="+KeyNo+"]:checked");
				if(targetRow.length>1){
					Common.Inform("<spring:message code='Cache.msg_SelectOnlyOne' />"); //1개 항목만 선택하세요.
					return;
				}
				
				var item = me.pageExpenceAppTarget;
			    var copyRownum = targetRow.length == 0 ? item.divList[0].Rownum : parseInt(targetRow.attr('rownum'));
				var oriTempVal = Object.assign({}, me.tempVal);
				
				var ctrlList = "";
				var ctrlItem = $("[name=CtrlArea][keyno="+KeyNo+"][rownum="+copyRownum+"] [id][code]");
			    $.each(ctrlItem, function(i, item) {
			    	var itemVal = $(item).attr('code');
			    	if(ctrlList.indexOf(itemVal) == -1) {
			        	if(i > 0) ctrlList += ",";
			    		ctrlList += itemVal;
			    	}
			    });
			    
				var idx = accFindIdx(item.divList, "Rownum", copyRownum);
				
				var divList = item.divList[idx];
				var divItem = {
						ExpenceApplicationDivID : ""
						, ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID)
						
						, AccountCode : nullToBlank(divList.AccountCode)
						, AccountName : nullToBlank(divList.AccountName)
						, StandardBriefID : nullToBlank(divList.StandardBriefID)
						, StandardBriefName : nullToBlank(divList.StandardBriefName)
						, StandardBriefDesc : nullToBlank(divList.StandardBriefDesc)
						, CostCenterCode : nullToBlank(divList.CostCenterCode)
						, CostCenterName : nullToBlank(divList.CostCenterName)
						, IOCode : nullToBlank(divList.IOCode)
						, IOName : nullToBlank(divList.IOName)
						, Amount : nullToBlank(divList.Amount)
						, UsageComment : nullToBlank(divList.UsageComment)
						, IsNew : nullToBlank(divList.IsNew)
						
						, ViewKeyNo : String(item.ViewKeyNo)
						, KeyNo : String(item.KeyNo)
						, ProofCode : item.ProofCode
						
				        //관리항목 셋팅
						, TaxType	: nullToBlank(item.TaxType)
						, TaxCode	: nullToBlank(item.TaxCode)
						, CtrlCode	: nullToBlank(ctrlList)
				}
				
				var maxRN = ckNaN(item.maxRowNum);
				maxRN++;
				item.maxRowNum = maxRN;
				divItem.Rownum = maxRN;

				if(divList.ReservedStr2_Div != undefined && Object.keys(divList.ReservedStr2_Div).length != 0)
					divItem.ReservedStr2_Div = Object.assign({}, divList.ReservedStr2_Div);
				if(divList.ReservedStr3_Div != undefined && Object.keys(divList.ReservedStr3_Div).length != 0)
					divItem.ReservedStr3_Div = Object.assign({}, divList.ReservedStr3_Div);
				
				item.divList.push(divItem);
				me.simpApp_updateCopyDivHtml(divItem, divItem.ProofCode, divItem.KeyNo, copyRownum);
				
				me.tempVal = oriTempVal;
			},
			comSimpAppListEdit_updateInputDivHtml : function (divItem, ProofCode, KeyNo, copyRownum) {
				var me = this;
				var Rownum = divItem.Rownum;
				var divArea = $("[name=DivAddArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]");
				
				var formStr = me.pageCombiAppFormList.DivAddInputFormStr;

				if(nullToBlank(divItem.Amount) == ""){
					divItem.Amount = divItem.TotalAmount;
				}
				
				var valMap = {
						ExpenceApplicationDivID : "",
						ExpenceApplicationListID : nullToBlank(divItem.ExpenceApplicationListID),
						
						ViewKeyNo : nullToBlank(divItem.ViewKeyNo),
						KeyNo : nullToBlank(divItem.KeyNo),
						ProofCode : nullToBlank(divItem.ProofCode),
						Rownum : nullToBlank(divItem.Rownum),
						
						Amount : nullToBlank(divItem.Amount),
						AmountVal : nullToBlank(divItem.Amount),
						
						accCDVal : nullToBlank(divItem.AccountCode),
						accNMVal : nullToBlank(divItem.AccountName),
						AccountCode : nullToBlank(divItem.AccountCode),
						AccountName : nullToBlank(divItem.AccountName),
						
						SBCDVal : nullToBlank(divItem.StandardBriefID),
						SBNMVal : nullToBlank(divItem.StandardBriefName),
						StandardBriefID : nullToBlank(divItem.StandardBriefID),
						StandardBriefName : nullToBlank(divItem.StandardBriefName),
						StandardBriefDesc : nullToBlank(divItem.StandardBriefDesc),
						
						CCCDVal : nullToBlank(divItem.CostCenterCode),
						CCNMVal : nullToBlank(divItem.CostCenterName),
						CostCenterCode : nullToBlank(divItem.CostCenterCode),
						CostCenterName : nullToBlank(divItem.CostCenterName),
						
						IOCDVal : nullToBlank(divItem.IOCode),
						IONMVal : nullToBlank(divItem.IOVal),
						
						UsageCommentVal : nullToBlank(divItem.UsageComment).replace(/<br>/gi, '\r\n'),
						
						RequestType : me.requestType,
						
						SelfDevelopDetail : nullToBlank(divItem.SelfDevelopDetail),
						
						//관리항목
						TaxType : nullToBlank(divItem.TaxType),
						TaxCode : nullToBlank(divItem.TaxCode),
						CtrlCode : nullToBlank(divItem.CtrlCode)
				}
				
				if(divItem.ReservedStr2_Div != undefined && Object.keys(divItem.ReservedStr2_Div).length > 0)
					valMap.ReservedStr2_Div = Object.assign({}, divItem.ReservedStr2_Div);
				if(divItem.ReservedStr3_Div != undefined && Object.keys(divItem.ReservedStr3_Div).length > 0)
					valMap.ReservedStr3_Div = Object.assign({}, divItem.ReservedStr3_Div);
				
				var getForm = me.comCostAppListEdit_htmlFormSetVal(formStr, valMap);
				getForm = me.comCostAppListEdit_htmlFormDicTrans(getForm);
				divArea.append(getForm);
				
				//표준적요, 관리항목 셋팅
				var targetObj = {
			    	ProofCode : ProofCode
			    	, KeyNo : KeyNo
			    	, Rownum : Rownum
			    };
				
				me.tempVal = Object.assign({}, targetObj);
				me.comCostAppListEdit_BriefValSet(ProofCode, KeyNo, Rownum, valMap.StandardBriefID);
				
			    if($("[name=CtrlArea][keyno="+KeyNo+"][rownum="+Rownum+"]").length > 0) {
			    	//관리항목 input 값 셋팅
			    	me.comCostAppListEdit_setCtrlDivHtml(valMap);
			    	
			    	//관리항목 popup 처리
			    	if(valMap.ReservedStr2_Div != undefined && Object.keys(valMap.ReservedStr2_Div).length > 0) {
			    		var ctrlType = Object.keys(valMap.ReservedStr2_Div);
			    		
			    		//출장항목 관련 관리항목 처리
			    		if($("[name=CtrlArea][keyno="+KeyNo+"][rownum="+copyRownum+"] select[code=D01]").length > 0) {
							$("select[code="+ctrlType[0]+"][keyno="+KeyNo+"][rownum="+Rownum+"][type=BizTripItem]").val($("select[code="+ctrlType[0]+"][keyno="+KeyNo+"][rownum="+copyRownum+"][type=BizTripItem]").val());
							$("select[code="+ctrlType[0]+"][keyno="+KeyNo+"][rownum="+Rownum+"][type=BizTripItem]").trigger("onchange");
							
				            if(valMap.ReservedStr3_Div != undefined && Object.keys(valMap.ReservedStr3_Div).length > 1) {
			            		var ctrlStr3 = valMap.ReservedStr3_Div[ctrlType[1]];
			            		
				            	if(ctrlStr3 != undefined && ctrlStr3 != "") {
									var jsonDiv = JSON.parse(ctrlStr3);
									targetObj.code = ctrlType[1];
									me.tempVal = Object.assign({}, targetObj);
					            	
									if(ctrlType[1] == "D02") {
										me.SetDistanceCallBack(jsonDiv);
									} else if(ctrlType[1] == "D03") {
										me.SetDailyCallBack(jsonDiv);
									} else if(ctrlType[1] == "Z09") {
										me.SetDistanceCallBack(jsonDiv);
									}
									
									$("textarea[tag=Comment][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(valMap.UsageCommentVal);
									me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "UsageComment", valMap.UsageCommentVal);
				            	}
							}
				        //편익제공 관련 관리항목 처리
			    		} else if($("[name=CtrlArea][keyno="+KeyNo+"][rownum="+copyRownum+"] input[code=C07]").length > 0) {
			    			if(valMap.ReservedStr3_Div['C07'] != undefined || valMap.ReservedStr3_Div['C07'] != "") {
								var jsonDiv = JSON.parse(valMap.ReservedStr3_Div['C07']);
								targetObj.code = 'C07';
								me.tempVal = Object.assign({}, targetObj);
				            	
								me.SetAttendantCallBack(jsonDiv);
			    			}
			    		}
			    	}
			    }
			    
			    //Amount 셋팅
			    me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "Amount", valMap.Amount);
			    $("[name=DivAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"][Rownum="+Rownum+"]").trigger('onblur');
				
				if(isUseIO == "N") {
			   		$("[name=noIOArea]").hide();
			   	}
			   	if(isUseSB == "N") {
			   		$("[name=noSBArea]").hide();
			   	} else {
			   		$("[name=AccBtn]").remove();
			   		$("[name=DivAccNm]").css("width", "116px");
			   	}
			   	if(isUseBD == "" || isUseBD == "N") {
			   		$("[name=noBDArea]").hide();
			   	}
			},
			
			//세부증빙(증빙분할) 삭제
			simpApp_delSelectAddDiv : function(ProofCode, KeyNo) { var me = this; me.comCostAppListEdit_delSelectAddDiv(ProofCode, KeyNo); },
			
			comCostAppListEdit_delSelectAddDiv : function(ProofCode, KeyNo) {
				var me = this;
				
				var targetRow = $('[name=DivCheck]:checked');
				if(targetRow.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />"); //선택된 항목이 없습니다.
					return;
				}
				
				var getItem = me.pageExpenceAppTarget;
				var divList = getItem.divList;
				
				var Rownum = '';
				for(var i = 0; i < targetRow.length; i++) {
					Rownum = String(targetRow.eq(i).attr('rownum'));
					
					var idx = accFindIdx(divList, "Rownum", Rownum);
					if(idx >= 0){
						//출장항목(일비, 유류비) 증빙분할 삭제 시 합계된 청구금액 빼기
					    if(divList[idx].ReservedStr2_Div != undefined) {
							if('D02' in divList[idx].ReservedStr2_Div || 'D03' in divList[idx].ReservedStr2_Div || 'Z09' in divList[idx].ReservedStr2_Div) {
								var totalAmount = AmttoNumFormat(getItem.divSum);
								var delAmount = AmttoNumFormat(divList[idx].Amount);
								
								var tempTotalAmount = parseInt(totalAmount) - parseInt(delAmount);
								$("[name=TotalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(tempTotalAmount);
								me.comCostAppListEdit_setListVal(ProofCode, "TotalAmount", KeyNo, tempTotalAmount);
							}
					    }
						
						me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "Amount", 0);
						//me.simpApp_pageAmtSet();
						
						divList.splice(idx,1);
						
						$("[name=DivRowDL][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").remove();
					}
				}
			},
			
			//세부증빙(증빙분할) 복사 - CO
			combiCostApp_divCopy : function(ProofCode, KeyNo) { var me = this; me.comCostAppListEdit_copyDiv(ProofCode, KeyNo); },
			combiCostApp_updateInputDivHtml : function(divItem, ProofCode, KeyNo, copyRownum) { var me = this; me.comCostAppListEdit_updateCopyDivHtml(divItem, ProofCode, KeyNo, copyRownum); },
			
			comCostAppListEdit_copyDiv : function (ProofCode, KeyNo) {
				var me = this;
				
				var targetRow = $("[name=DivCheck][keyno="+KeyNo+"]:checked");
				if(targetRow.length>1){
					Common.Inform("<spring:message code='Cache.msg_SelectOnlyOne' />"); //1개 항목만 선택하세요.
					return;
				}
				
				var item = me.pageExpenceAppTarget;
			    var copyRownum = targetRow.length == 0 ? item.divList[0].Rownum : parseInt(targetRow.attr('rownum'));
				var oriTempVal = Object.assign({}, me.tempVal);
				
				if(item.divList == null){
					item.divList = [];
				}
				
				var ctrlList = "";
				var ctrlItem = $("[name=CtrlArea][keyno="+KeyNo+"][rownum="+copyRownum+"] [id][code]");
			    $.each(ctrlItem, function(i, item) {
			    	var itemVal = $(item).attr('code');
			    	if(ctrlList.indexOf(itemVal) == -1) {
			        	if(i > 0) ctrlList += ",";
			    		ctrlList += itemVal;
			    	}
			    });
			    
				var idx = accFindIdx(item.divList, "Rownum", copyRownum);
				
				var divList = item.divList[idx];
				var divItem = {
						ExpenceApplicationDivID : ""
						, ExpenceApplicationListID : nullToBlank(divList.ExpenceApplicationListID)
						
						, AccountCode : nullToBlank(divList.AccountCode)
						, AccountName : nullToBlank(divList.AccountName)
						, StandardBriefID : nullToBlank(divList.StandardBriefID)
						, StandardBriefName : nullToBlank(divList.StandardBriefName)
						, StandardBriefDesc : nullToBlank(divList.StandardBriefDesc)
						, CostCenterCode : nullToBlank(divList.CostCenterCode)
						, CostCenterName : nullToBlank(divList.CostCenterName)
						, IOCode : nullToBlank(divList.IOCode)
						, IOName : nullToBlank(divList.IOName)
						, Amount : nullToBlank(divList.Amount)
						, UsageComment : nullToBlank(divList.UsageComment)
						, IsNew : nullToBlank(divList.IsNew)
						
						, ViewKeyNo : String(item.ViewKeyNo)
						, KeyNo : String(item.KeyNo)
						, ProofCode : item.ProofCode
						
			            //관리항목 셋팅
						, TaxType	: nullToBlank(item.TaxType)
						, TaxCode	: nullToBlank(item.TaxCode)
						, CtrlCode	: nullToBlank(ctrlList)
				}
				
				var maxRN = ckNaN(item.maxRowNum);
				maxRN++;
				item.maxRowNum = maxRN;
				divItem.Rownum = maxRN;
				
				if(divList.ReservedStr2_Div != undefined && Object.keys(divList.ReservedStr2_Div).length > 0)
					divItem.ReservedStr2_Div = Object.assign({}, divList.ReservedStr2_Div);
				if(divList.ReservedStr3_Div != undefined && Object.keys(divList.ReservedStr3_Div).length > 0)
					divItem.ReservedStr3_Div = Object.assign({}, divList.ReservedStr3_Div);
				
				item.divList.push(divItem);
				me.combiCostApp_updateInputDivHtml(divItem, divItem.ProofCode, divItem.KeyNo, copyRownum);    
				
				me.tempVal = oriTempVal;
			},
			comCostAppListEdit_updateCopyDivHtml : function (divItem, ProofCode, KeyNo, copyRownum) {
				var me = this;
				var Rownum = divItem.Rownum;
				var divArea = $("[name=DivBodyArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
				
				var formStr = me.pageCombiAppFormList.DivInputFormStr;
				
				if(nullToBlank(divItem.Amount) == ""){
					if(ProofCode == "TaxBill") {
						divItem.Amount = divItem.RepAmount;
					} else {
						divItem.Amount = divItem.TotalAmount;
					}
				}
				
				var valMap = {
						ExpenceApplicationDivID : "",
						ExpenceApplicationListID : nullToBlank(divItem.ExpenceApplicationListID),
						
						ViewKeyNo : nullToBlank(divItem.ViewKeyNo),
						KeyNo : nullToBlank(divItem.KeyNo),
						ProofCode : nullToBlank(divItem.ProofCode),
						Rownum : nullToBlank(divItem.Rownum),

						Amount : nullToBlank(divItem.Amount),
						AmountVal : toAmtFormat(divItem.Amount),
						
						accCDVal : nullToBlank(divItem.AccountCode),
						accNMVal : nullToBlank(divItem.AccountName),
						AccountCode : nullToBlank(divItem.AccountCode),
						AccountName : nullToBlank(divItem.AccountName),
						
						SBCDVal : nullToBlank(divItem.StandardBriefID),
						SBNMVal : nullToBlank(divItem.StandardBriefName),
						StandardBriefID : nullToBlank(divItem.StandardBriefID),
						StandardBriefName : nullToBlank(divItem.StandardBriefName),
						StandardBriefDesc : nullToBlank(divItem.StandardBriefDesc),
						
						CCCDVal : nullToBlank(divItem.CostCenterCode),
						CCNMVal : nullToBlank(divItem.CostCenterName),
						CostCenterCode : nullToBlank(divItem.CostCenterCode),
						CostCenterName : nullToBlank(divItem.CostCenterName),
						
						IOCDVal : nullToBlank(divItem.IOCode),
						IONMVal : nullToBlank(divItem.IOName),
						
						UsageCommentVal : nullToBlank(divItem.UsageComment).replace(/<br>/gi, '\r\n'),

						RequestType: me.requestType,
						
						SelfDevelopDetail : nullToBlank(divItem.SelfDevelopDetail),
						
			            //관리항목 셋팅
						TaxType : nullToBlank(divItem.TaxType),
						TaxCode : nullToBlank(divItem.TaxCode),
						CtrlCode : nullToBlank(divItem.CtrlCode)
				}
				
				if(divItem.ReservedStr2_Div != undefined && Object.keys(divItem.ReservedStr2_Div).length > 0)
					valMap.ReservedStr2_Div = Object.assign({}, divItem.ReservedStr2_Div);
				if(divItem.ReservedStr3_Div != undefined && Object.keys(divItem.ReservedStr3_Div).length > 0)
					valMap.ReservedStr3_Div = Object.assign({}, divItem.ReservedStr3_Div);
				
				var getForm = me.comCostAppListEdit_htmlFormSetVal(formStr, valMap);
				getForm = me.comCostAppListEdit_htmlFormDicTrans(getForm);
				divArea.append(getForm);
				
				//표준적요, 관리항목 셋팅
			    var targetObj = {
			    	ProofCode : ProofCode
			    	, KeyNo : KeyNo
			    	, Rownum : Rownum
			    };
				
				me.tempVal = Object.assign({}, targetObj);
				me.comCostAppListEdit_BriefValSetCO(ProofCode, KeyNo, Rownum, valMap.StandardBriefID, valMap);
				
			    if($("[name=CtrlArea][keyno="+KeyNo+"][rownum="+Rownum+"]").length > 0) {
			    	//관리항목 input 값 셋팅
			    	me.comCostAppListEdit_setCtrlDivHtml(valMap);
			    	
			    	//관리항목 popup 처리
			    	if(valMap.ReservedStr2_Div != undefined && Object.keys(valMap.ReservedStr2_Div).length > 0) {
						var ctrlType = Object.keys(valMap.ReservedStr2_Div);
			    		
			    		//출장항목 관련 관리항목 처리
			    		if($("[name=CtrlArea][keyno="+KeyNo+"][rownum="+copyRownum+"] select[code=D01]").length > 0) {
							$("[code="+ctrlType[0]+"][keyno="+KeyNo+"][rownum="+Rownum+"][tag=select]").val($("[code="+ctrlType[0]+"][keyno="+KeyNo+"][rownum="+copyRownum+"][tag=select]").val());
							$("[code="+ctrlType[0]+"][keyno="+KeyNo+"][rownum="+Rownum+"][tag=select]").trigger("onchange");
							
				            if(valMap.ReservedStr3_Div != undefined && Object.keys(valMap.ReservedStr3_Div).length > 1) {
			            		var ctrlStr3 = valMap.ReservedStr3_Div[ctrlType[1]];
			            		
				            	if(ctrlStr3 != undefined && ctrlStr3 != "") {
									var jsonDiv = JSON.parse(ctrlStr3);
									targetObj.code = ctrlType[1];
									me.tempVal = Object.assign({}, targetObj);
					            	
									if(ctrlType[1] == "D02") {
										me.SetDistanceCallBack(jsonDiv);
									} else if(ctrlType[1] == "D03") {
										me.SetDailyCallBack(jsonDiv);
									} else if(ctrlType[1] == "Z09") {
										me.SetDistanceCallBack(jsonDiv);
									}
									
									$("textarea[tag=Comment][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(valMap.UsageCommentVal);
									me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "UsageComment", valMap.UsageCommentVal);
				            	}
							}
				        //편익제공 관련 관리항목 처리
			    		} else if($("[name=CtrlArea][keyno="+KeyNo+"][rownum="+copyRownum+"] input[code=C07]").length > 0) {
		            		var ctrlStr3 = valMap.ReservedStr3_Div['C07'];
		            		
			    			if(ctrlStr3 != undefined && ctrlStr3 != "") {
			    				var strJson = typeof(ctrlStr3) == 'string' ? ctrlStr3 : JSON.stringify(ctrlStr3);
								var jsonDiv = JSON.parse(strJson);
								targetObj.code = 'C07';
								me.tempVal = Object.assign({}, targetObj);
				            	
								me.SetAttendantCallBack(jsonDiv);
			    			}
			    		}
			    	}
			    }
			    
			    if(isUseIO == "N") {
			   		$("[name=noIOArea]").hide();
			   	}
			   	if(isUseSB == "N") {
			   		$("[name=noSBArea]").hide();
			   	} else {
			   		$(".total_acooungting_table th[name=noSBArea]").prev().find("span").remove();
			   		var accNM =  $("[name=DivAccNm][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
			   		$(accNM).parent().find("button").remove();
			   	}
			   	if(isUseBD == "" || isUseBD == "N") {
			   		$("[name=noBDArea]").hide();
			   	}
			},
			
			//세부증빙 관리항목 값 셋팅
			comCostAppListEdit_setCtrlDivHtml : function(divItem) {
				var ctrlCodeArr = divItem.CtrlCode.split(',');
				
				for(var i = 0; i < ctrlCodeArr.length; i++) {
					var ctrlVal = divItem.ReservedStr2_Div[ctrlCodeArr[i]];
					$("[name=CtrlArea] input[code="+ctrlCodeArr[i]+"][proofcd="+divItem.ProofCode+"][keyno="+divItem.KeyNo+"][rownum="+divItem.Rownum+"]").val(ctrlVal);
				}
			},
			
			//세부증빙(증빙분할) 추가
			combiCostApp_divAddOne : function(ProofCode, KeyNo) { var me = this; me.comCostAppListEdit_divAddOne(ProofCode, KeyNo); },
			simpApp_divAddOne : function(ProofCode, KeyNo) { var me = this; me.comCostAppListEdit_divAddOne(ProofCode, KeyNo); },
			comCostAppListEdit_divAddOne : function(ProofCode, KeyNo) {				
				var me = this;
				var item = me.pageExpenceAppTarget;
				
				var usageComment = "";
				if(me.appType != "CO")
					usageComment = $("[name=UsageCommentField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum=0]").val()
				
				if(item.divList == null){
					item.divList = [];
				}

				var divItem = {
						ExpenceApplicationDivID : ""
						, AccountCode :  ""
						, AccountName : ""
						, StandardBriefID :  ""
						, StandardBriefName : ""
						, CostCenterCode :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterCode)
						, CostCenterName :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterName)
						, IOCode : ""
						, IOName : ""
						, Amount : 0
						, UsageComment : usageComment
						, IsNew : true
						
						, ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID)
						, ViewKeyNo : item.ViewKeyNo
						, KeyNo : item.KeyNo
						, ProofCode : item.ProofCode
				}
				var maxRN = ckNaN(item.maxRowNum);
				maxRN++;
				item.maxRowNum = maxRN;
				divItem.Rownum = maxRN;
				
				item.divList.push(divItem);
				me.comCostAppListEdit_makeInputDivHtmlAdd(divItem, null, true);
			},
			
			//세부증빙 추가 
			combiCostApp_divAddSub : function (ProofCode, KeyNo, Type) { var me = this; me.comCostAppListEdit_divAddSub(ProofCode, KeyNo, Type); },
			comCostAppListEdit_divAddSub : function (ProofCode, KeyNo, Type) {
				var me = this;
				
				// 금액 세팅
				var subAmount;
								
				// 계정과목 표준적요 코드 가져오기				
				var codeSet = me.comCostAppListEdit_SubCodeSet(Type);
				
				accountID = codeSet.SubCodeSet[0].AccountID;
                accountCode = codeSet.SubCodeSet[0].AccountCode;
                accountName = codeSet.SubCodeSet[0].AccountName;
                standardBriefID = codeSet.SubCodeSet[0].StandardBriefID;
                standardBriefName =  codeSet.SubCodeSet[0].StandardBriefName;
				
				var item = me.pageExpenceAppTarget;
				if(item.KeyNo == KeyNo){
					if(item.divList == null){
						item.divList = [];
					}
					
					if(Type == "TaxCodeSet") {	// 부가세추가버튼
						subAmount = item.TaxAmount;					
					} else if (Type == "IncomeTaxCodeSet") {	// 어떤애는 income 이고 어떤애는 ioncom 이고 맨뒤에 e가 있다 없다함... 장난치나......
						subAmount = item.IncomTaxAmt;
					} else if (Type == "LocalTaxCodeSet") {
						subAmount = item.LocalTaxAmt;
					} else { 
						subAmount = 0;
					}
					
					// 부가세가 0일 경우에는 생성안되게 합니당
					if (subAmount == 0 || subAmount == undefined) {
						// Common.Inform("<spring:message code='Cache.ACC_msg_" + Type + "' />");  // 부가세가 0원이라 추가하면 안된다.
						Common.Inform(Common.getDic("ACC_msg_" + Type));
						return;
					}
					
					var divList = item.divList;

					// 부가세가 이미 만들어져있으면 안되게
					// 부가세 있는거 체크하기
					for (var y = 0; y < divList.length; y++) {
						var divItem = divList[y];
						
						if (divItem.StandardBriefID == standardBriefID) {
							// Common.Inform("<spring:message code='Cache.ACC_msg_" + Type + "dup' />");  // 부가세가 0원이라 추가하면 안된다.
							Common.Inform(Common.getDic("ACC_msg_" + Type + "Dup")); // 부가세가 이미 추가되어있습니다.
							return;
						}
					}

					var divItem = {
							ExpenceApplicationDivID : ""
							, AccountCode :  accountCode
							, AccountName : accountName
							, StandardBriefID :  standardBriefID
							, StandardBriefName : standardBriefName
							, CostCenterCode :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterCode)
							, CostCenterName :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterName)
							, IOCode : ""
							, IOName : ""
							, Amount : subAmount
							, UsageComment : ""
							, IsNew : true
							
							, ExpenceApplicationListID : item.ExpenceApplicationListID
							, ViewKeyNo : item.ViewKeyNo
							, KeyNo : item.KeyNo
							, ProofCode : item.ProofCode
					}
					var maxRN = ckNaN(item.maxRowNum);
					maxRN++;
					item.maxRowNum = maxRN;
					divItem.Rownum = maxRN;
					
					item.divList.push(divItem);
					me.comCostAppListEdit_makeInputDivHtmlAdd(divItem, null, true);
					
					$("[name=DivSBCd][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+maxRN+"]").siblings("button").remove();
				}
			},
			
			comCostAppListEdit_SubCodeSet : function (pType) {
				var me = this;
				var rslt;
				$.ajax({
					type:"POST",
						url:"/account/accountCommon/getBaseCodeSubSet.do",
					data:{
						codeGroups: pType,
						CompanyCode : me.CompanyCode
					},
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							var codeList = data.list;
							
							rslt = codeList;
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});
				
				return rslt;
			}, 
						
			//세부증빙부분의 html 추가
			comCostAppListEdit_makeInputDivHtmlAdd : function(inputItem, isAll, isOne) {
				var me = this;
				var ProofCode = inputItem.ProofCode;
				var KeyNo = inputItem.KeyNo;
				
				var divArea = null;
				var formStr = "";
				if(me.appType == "CO") {
					divArea = $("[name=DivBodyArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]")
					formStr = me.pageCombiAppFormList.DivInputFormStr;
				} else {
					divArea = $("[name=DivAddArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]");
					formStr = me.pageCombiAppFormList.DivAddInputFormStr;
				}
				
				if(isAll){
					divArea.html("");
				}
				
				var divList = inputItem.divList;
				
				if(isOne) { //세부증빙 1건 신규 추가 시 inputItem 파라미터에 divItem을 넘겨줌
					divList = [];
					divList.push(inputItem);
				}
				
				for(var y = 0; y < divList.length; y++){
					var divItem = divList[y];
					
					if(me.appType == "CO" || y > 0 || isOne) {
						var amtVal = divItem.Amount;
						if(amtVal == null || amtVal == ""){
							if(inputItem.ProofCode == "TaxBill") {
								amtVal = divItem.RepAmount;
							} else {
								amtVal = divItem.TotalAmount;
							}
						}
						
						var valMap = {
								RequestType : me.requestType,
								ExpenceApplicationListID : nullToBlank(inputItem.ExpenceApplicationListID),
								ViewKeyNo : nullToBlank(inputItem.ViewKeyNo),
								KeyNo : nullToBlank(inputItem.KeyNo),
								ProofCode : nullToBlank(inputItem.ProofCode),
								Rownum : nullToBlank(divItem.Rownum),
								
								AmountVal : toAmtFormat(amtVal),
								
								accCDVal : nullToBlank(divItem.AccountCode),
								accNMVal : nullToBlank(divItem.AccountName),
								AccountCode : nullToBlank(divItem.AccountCode),
								AccountName : nullToBlank(divItem.AccountName),
								
								SBCDVal : nullToBlank(divItem.StandardBriefID),
								SBNMVal : nullToBlank(divItem.StandardBriefName),
								StandardBriefID : nullToBlank(divItem.StandardBriefID),
								StandardBriefName : nullToBlank(divItem.StandardBriefName),
								StandardBriefDesc : nullToBlank(divItem.StandardBriefDesc),
								
								CCCDVal : nullToBlank(divItem.CostCenterCode),
								CCNMVal : nullToBlank(divItem.CostCenterName),
								CostCenterCode : nullToBlank(divItem.CostCenterCode),
								CostCenterName : nullToBlank(divItem.CostCenterName),
								
								IOCDVal : nullToBlank(divItem.IOCode),
								IONMVal : nullToBlank(divItem.IOName),
								UsageCommentVal : nullToBlank(divItem.UsageComment).replace(/<br>/gi, '\r\n'),
								
								SelfDevelopDetail : nullToBlank(divItem.SelfDevelopDetail),

								//관리항목 세팅
								TaxType : nullToBlank(divItem.TaxType),
								TaxCode : nullToBlank(divItem.TaxCode),
								CtrlCode : nullToBlank(divItem.CtrlCode)
						}
						
						if(divItem.ReservedStr2_Div != undefined && divItem.ReservedStr2_Div != "")
							valMap.ReservedStr2_Div = Object.assign({}, divItem.ReservedStr2_Div);
						if(divItem.ReservedStr3_Div != undefined && divItem.ReservedStr3_Div != "")
							valMap.ReservedStr3_Div = Object.assign({}, divItem.ReservedStr3_Div);
						
						var getForm = me.comCostAppListEdit_htmlFormSetVal(formStr, valMap);
						getForm = me.comCostAppListEdit_htmlFormDicTrans(getForm);
						
						divArea.append(getForm);
						
						me.comCostAppListEdit_BriefValSet(ProofCode, KeyNo, divItem.Rownum, divItem.StandardBriefID);
						me.comCostAppListEdit_BriefValSetCO(ProofCode, KeyNo, divItem.Rownum, divItem.StandardBriefID, divItem);
						
				    	//관리항목 popup 처리
				    	if(valMap.ReservedStr2_Div != undefined && Object.keys(valMap.ReservedStr2_Div).length > 0) {
				    		var oriTempVal = Object.assign({}, me.tempVal);
				    		
						    me.tempVal = {
							    ProofCode : ProofCode
							    , KeyNo : KeyNo
							    , Rownum : divItem.Rownum
							};
				    		
				    		//출장항목 관련 관리항목 처리
				    		if('D01' in valMap.ReservedStr2_Div) {
								var ctrlType = Object.keys(valMap.ReservedStr2_Div);
								
								if(valMap.ReservedStr3_Div != undefined && Object.keys(valMap.ReservedStr3_Div).length > 1) {
				            		var ctrlStr3 = valMap.ReservedStr3_Div[ctrlType[1]];
				            		
					            	if(ctrlStr3 != undefined && ctrlStr3 != "") {
					    				var strJson = typeof(ctrlStr3) == 'string' ? ctrlStr3 : JSON.stringify(ctrlStr3);
										var jsonDiv = JSON.parse(strJson);
										me.tempVal.code = ctrlType[1];
						            	
										if(ctrlType[1] == "D02") {
											me.SetDistanceCallBack(jsonDiv);
										} else if(ctrlType[1] == "D03") {
											me.SetDailyCallBack(jsonDiv);
										} else if(ctrlType[1] == "Z09") {
											me.SetDistanceCallBack(jsonDiv);
										}
					            	}
								}
					        //편익제공 관련 관리항목 처리
				    		} else if('C07' in valMap.ReservedStr2_Div) {
			            		var ctrlStr3 = valMap.ReservedStr3_Div['C07'];
			            		
				    			if(ctrlStr3 != undefined && ctrlStr3 != "") {
				    				var strJson = typeof(ctrlStr3) == 'string' ? ctrlStr3 : JSON.stringify(ctrlStr3);
									var jsonDiv = JSON.parse(strJson);
									me.tempVal.code = 'C07';
					            	
									me.SetAttendantCallBack(jsonDiv);
				    			}
				    		}
				    		
				    		me.tempVal = Object.assign({}, oriTempVal);
				    	}
						
						divItem = $.extend({}, divItem, valMap);
					}
				}
				
				if(isUseIO == "N") {
			   		$("[name=noIOArea]").hide();
			   	}
			   	if(isUseSB == "N") {
			   		$("[name=noSBArea]").hide();
			   	} else {
			   		if(me.appType == "CO") {
			   			if($(".total_acooungting_table th[name=noSBArea]").find("span").length == 0) {
				   			$(".total_acooungting_table th[name=noSBArea]").append("<span class='star'></span>");
				   		}
				   		$(".total_acooungting_table th[name=noSBArea]").prev().find("span").remove();
				   		var accNM =  $("[name=DivAccNm][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
				   		$(accNM).each(function(i, obj) { $(obj).siblings("button").remove() });
			   		} else {
				   		$("[name=AccBtn]").remove();
				   		$("[name=DivAccNm]").css("width", "116px");
			   		}
			   	}
			   	if(isUseBD == "" || isUseBD == "N") {
			   		$("[name=noBDArea]").hide();
			   	}
			},	
			
			//세부증빙 삭제 - SimpleApplication
			simpApp_delAddDiv : function(ProofCode, KeyNo, Rownum) {
				var me = this;

				var getItem = me.pageExpenceAppTarget;
				var divList = getItem.divList;
				var idx = accFindIdx(divList, "Rownum", Rownum);
				if(idx >= 0){
					divList.splice(idx,1);
				}
				$("[name=DivRowDL][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").remove();
			},
			
			//세부증빙 삭제 - CombineCostApplication
			combiCostApp_divDelete : function(ProofCode, KeyNo) {
				var me = this;

				var fieldList =  $("[name=DivCheck][proofcode="+ProofCode+"][keyno="+KeyNo+"]:checked");
				var fieldMaxList =  $("[name=DivCheck][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
				if(fieldList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");
					return;
				}
				if(fieldList.length == fieldMaxList.length){
					Common.Inform("<spring:message code='Cache.ACC_045' />");
					return;
				}
		        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){
		       		if(result){
					   	for(var i=0;i<fieldList.length; i++){
					   		var checkedItem = fieldList[i];
							var Rownum = checkedItem.getAttribute("rownum");
							
							var getItem = me.pageExpenceAppTarget;
							var divList = getItem.divList;
							var idx = accFindIdx(divList, "Rownum", Rownum );
							if(idx>=0){
								//출장항목(일비, 유류비) 증빙분할 삭제 시 합계된 청구금액 빼기
					    		if(divList[idx].ReservedStr2_Div != undefined) {
						    		if('D02' in divList[idx].ReservedStr2_Div || 'D03' in divList[idx].ReservedStr2_Div || 'Z09' in divList[idx].ReservedStr2_Div) {
										var totalAmount = AmttoNumFormat(accountCtrl.getInfoStr("[name=CombiCostInputField][tag=Amount][proofcode="+ProofCode+"][keyno="+KeyNo+"]").val());
										var delAmount = AmttoNumFormat(divList[idx].Amount);
										
										accountCtrl.getInfoStr("[name=CombiCostInputField][tag=Amount][proofcode="+ProofCode+"][keyno="+KeyNo+"]").val(toAmtFormat(parseInt(totalAmount) - parseInt(delAmount)));
									}
					    		}
								
								divList.splice(idx,1);
							}
							$("[name=DivRowTR][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").remove();
					   	}
		       		}
		        });
			},
			
			//날짜필드 생성
			comCostAppListEdit_makeDateField : function(ProofCode, getItem) {
				var me = this;

				var KeyNo = getItem.KeyNo;
				
				var dateInputList = [];
				if(me.appType == "CO") {
					dateInputList = $("[name=DateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
				} else if(me.appType == "SC") {
					dateInputList = $("[name=SimpAppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]");	
				}

				for(var y = 0; y < dateInputList.length; y++){
					var input = dateInputList[y];
					var dataField = input.getAttribute("datafield");
					var areaID = input.id;
					var pd = getItem[dataField];

					makeDatepicker(areaID, areaID+"_Date", null, pd, null, 100);
					if(!isEmptyStr(pd)){
						me.comCostAppListEdit_setListVal(ProofCode, 'ProofDate', KeyNo, pd);
						me.comCostAppListEdit_setListVal(ProofCode, 'ProofDateStr', KeyNo, pd.substring(0, 4)+"."+pd.substring(4, 6)+"."+pd.substring(6, 8));
					}
				}
			},
			
			//계정 입력 팝업 호출
			combiCostApp_callAccountPopup : function(ProofCode, KeyNo, Rownum) { var me = this; me.comCostAppListEdit_callAccountPopup(ProofCode, KeyNo, Rownum); },
			simpApp_CallAccountPopup : function(ProofCode, KeyNo, Rownum) { var me = this; me.comCostAppListEdit_callAccountPopup(ProofCode, KeyNo, Rownum); },
			comCostAppListEdit_callAccountPopup : function(ProofCode, KeyNo, Rownum) {
				var me = this;
				me.tempVal.ProofCode = ProofCode;
				me.tempVal.KeyNo = KeyNo;
				me.tempVal.Rownum = Rownum;
				
				var popupID		=	"accountSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_account'/>";
				var popupName	=	"AccountSearchPopup";
				var callBack	=	"comCostAppListEdit_setDivAccVal";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"companyCode="	+	me.CompanyCode + "&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"740px","690px","iframe",true,null,null,true);
			},
			
			//계정과목 값 세팅
			comCostAppListEdit_setDivAccVal : function(info){
				var me = this;
				var KeyNo = me.tempVal.KeyNo;
				var ProofCode = me.tempVal.ProofCode;
				var Rownum = me.tempVal.Rownum;
				
				var cdField = $("[name=DivAccCd]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
				var nmField = $("[name=DivAccNm]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
								
				me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "AccountCode", info.AccountCode);
				me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "AccountName", info.AccountName);
				
				cdField.val(info.AccountCode);
				nmField.val(info.AccountName);
				
				me.tempVal = {};
			},
			
			combiCostApp_callStandardBriefPopup : function(ProofCode, KeyNo, Rownum) { var me = this; me.comCostAppListEdit_callBriefPopup(ProofCode, KeyNo, Rownum); },
			simpApp_CallBriefPopup : function(ProofCode, KeyNo, Rownum) { var me = this; me.comCostAppListEdit_callBriefPopup(ProofCode, KeyNo, Rownum); },
			comCostAppListEdit_callBriefPopup : function(ProofCode, KeyNo, Rownum) {
				var me = this;
				me.tempVal.ProofCode = ProofCode;
				me.tempVal.KeyNo = KeyNo;
				me.tempVal.Rownum = Rownum;
				
				var popupID		=	"standardBriefSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_standardBrief'/>";
				var popupName	=	"StandardBriefSearchPopup";
				var callBack	=	"comCostAppListEdit_setDivSBVal";
				/* var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"StandardBriefSearchStr="	+	Base64.utf8_to_b64(accComm[me.requestType].pageExpenceFormInfo.StandardBriefSearchStr)	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"companyCode="	+	me.CompanyCode + "&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"1000px","700px","iframe",true,null,null,true); */
				CFN_OpenWindow("/account/accountCommon/accountCommonPopup.do?"
						+	"popupID="		+	popupID		+	"&"
						+	"popupName="	+	popupName	+	"&"
						+	"StandardBriefSearchStr="	+	Base64.utf8_to_b64(accComm[me.requestType].pageExpenceFormInfo.StandardBriefSearchStr)	+	"&"
						+	me.pageOpenerIDStr
						+	"includeAccount=N&"
						+	"companyCode="	+	me.CompanyCode + "&"
						+	"windowPopupYN=" + "Y" + "&"
						+	"callBackFunc="	+	callBack
						, "", 1000, 770, "both");

			},
			
			comCostAppListEdit_setDivSBVal : function(info){
				var me = this;
				var KeyNo = me.tempVal.KeyNo;
				var ProofCode = me.tempVal.ProofCode;
				var Rownum = me.tempVal.Rownum;

				var BriefMap = me.pageCombiAppComboData.BriefMap;
				var Item = BriefMap[info.StandardBriefID];
				if(me.appType == "CO") {
					if($("[name=DivSBCd][proofcode="+ProofCode+"][keyno="+KeyNo+"]").attr('rownum')==Rownum)
					{
						$("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxType]").val(Item.TaxType);
						$("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxType]").change();
						$("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxCode]").val(Item.TaxCode);
						$("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxCode]").change();
					}
					
					//표준적요
					var sbCdField = $("[name=DivSBCd][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					var sbNmField = $("[name=DivSBNm][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					
					me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "StandardBriefID", info.StandardBriefID);
					me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "StandardBriefName", info.StandardBriefName);
					
					sbCdField.val(info.StandardBriefID);
					sbNmField.val(info.StandardBriefName);
					
					//계정과목
					var accCdField = $("[name=DivAccCd][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					var accNmField = $("[name=DivAccNm][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					
					me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "AccountCode", info.AccountCode);
					me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "AccountName", info.AccountName);
					
					accCdField.val(info.AccountCode);
					accNmField.val(info.AccountName);
					me.comCostAppListEdit_BriefValSetCO(ProofCode, KeyNo, Rownum, info.StandardBriefID,info);
				} else {
					me.comCostAppListEdit_BriefValSet(ProofCode, KeyNo, Rownum, info.StandardBriefID);
				}
				
				me.tempVal = {};
			},
			
			combiCostApp_callCostCenterPopup : function(ProofCode, KeyNo, Rownum) { var me = this; me.comCostAppListEdit_callCostCenterPopup(ProofCode, KeyNo, Rownum); },
			simpApp_onCCSearch : function(ProofCode, KeyNo, Rownum){ var me = this; me.comCostAppListEdit_callCostCenterPopup(ProofCode, KeyNo, Rownum); },
			comCostAppListEdit_callCostCenterPopup : function(ProofCode, KeyNo, Rownum) {
				var me = this;
				me.tempVal.ProofCode = ProofCode
				me.tempVal.KeyNo = KeyNo
				me.tempVal.Rownum = Rownum
				var popupID		=	"ccSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_costCenter'/>";
				var popupName	=	"CostCenterSearchPopup";
				var callBack	=	"comCostAppListEdit_setDivCCVal";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"companyCode="	+	me.CompanyCode + "&"
								+	"popupType="	+ (Common.getBaseConfig("IsUseIO") == "Y" ? "CC" : "") + 	"&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"600px","730px","iframe",true,null,null,true);
			},
			
			comCostAppListEdit_setDivCCVal : function(info) {
				var me = this;

				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				var Rownum = me.tempVal.Rownum;
					
				var cdField = $("[name=DivCCCd]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
				var nmField = $("[name=DivCCNm]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
				
				me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "CostCenterCode", info.CostCenterCode);
				me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "CostCenterName", info.CostCenterName);
				
				cdField.val(info.CostCenterCode);
				nmField.val(info.CostCenterName);

				me.tempVal = {};
			},

			combiCostApp_callIOPopup : function(ProofCode, KeyNo, Rownum) { var me = this; me.comCostAppListEdit_callIOPopup(ProofCode, KeyNo, Rownum); },
			simpApp_onIOSearch : function(ProofCode, KeyNo, Rownum){ var me = this; me.comCostAppListEdit_callIOPopup(ProofCode, KeyNo, Rownum); },
			comCostAppListEdit_callIOPopup : function(ProofCode, KeyNo, Rownum) {
				var me = this;
				me.tempVal.ProofCode = ProofCode
				me.tempVal.KeyNo = KeyNo
				me.tempVal.Rownum = Rownum;
				var popupID		=	"ioSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_projectName' />";
				var popupName	=	"BaseCodeSearchPopup";
				var callBack	=	"comCostAppListEdit_setDivIOVal";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"companyCode="	+	me.CompanyCode + "&"
								+	"codeGroup=IOCode&"
								+	"callBackFunc="	+	callBack;
				
				Common.open(	"",popupID,popupTit,url,"600px","650px","iframe",true,null,null,true);
			},
			
			comCostAppListEdit_setDivIOVal : function(info) {
				var me = this;

				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				var Rownum = me.tempVal.Rownum;
					
				var cdField = $("[name=DivIOCd]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
				var nmField = $("[name=DivIONm]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
				
				me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "IOCode", info.Code);
				me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "IOName", info.CodeName);
				
				cdField.val(info.Code);
				nmField.val(info.CodeName);

				me.tempVal = {};
			},
						
			//문서 연결 팝업
			combiCostApp_DocLink : function(ProofCode, KeyNo) { var me = this; me.comCostAppListEdit_DocLink(ProofCode, KeyNo); },
			simpApp_DocLink : function(ProofCode, KeyNo) { var me = this; me.comCostAppListEdit_DocLink(ProofCode, KeyNo); },
			comCostAppListEdit_DocLink : function(ProofCode, KeyNo) {
				var me = this;
				
				me.tempVal.ProofCode = ProofCode;				
				me.tempVal.KeyNo = KeyNo;
				
				var url	= "/approval/goDocListSelectPage.do";
				var iWidth = 840, iHeight = 660, sSize = "fix";
				CFN_OpenWindow(url, "", iWidth, iHeight, sSize);
			},
			
			comCostAppListEdit_LinkComp : function(data, isSearched) {
				var me = window.CombineCostApplicationListEdit;
				
				var list = typeof(data) == "string" ? data.split("^^^") : data;
				if(list == null){
					return;
				}
				
				var docList = [];
				
				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				
				var getItem = me.pageExpenceAppTarget;
				var pageDocList = getItem.docList;

				if(pageDocList == null){
					pageDocList = [];
				}
				
				for(var i = 0; i<list.length; i++){
					var docInfo = {};
					if(typeof(list[i]) == "string") {
						var tempList = list[i].split('@@@');
						docInfo.ProcessID = tempList[0];
						docInfo.FormPrefix = tempList[1];
						docInfo.Subject = tempList[2];
						docInfo.forminstanceID = tempList[3];
						docInfo.bstored = tempList[4];
						docInfo.BusinessData1 = tempList[5];
						docInfo.BusinessData2 = tempList[6];
					} else {
						docInfo = list[i];
					}		
					
					// 기존에 추가된 연결문서와 중복 체크
					var ckDocItem = {};
					if(!isSearched) {	
						ckDocItem = me.comCostAppListEdit_findListItem(pageDocList, "ProcessID", docInfo.ProcessID);
						if(ckDocItem == null) {
							ckDocItem = {};
						}
					}
					
					if(isEmptyStr(ckDocItem.ProcessID)){
						var info = $.extend({}, docInfo);
						info.KeyNo = KeyNo;
	
						// 문서연결 팝업에서 선택할 때 동일한 문서(ProcessID 기준) 선택 시 1건만 들어가도록 처리
						var isDup = false;
						for(var j = 0; j < docList.length; j++) {
							if(info.ProcessID == docList[j].ProcessID) {
								isDup = true;
							} 
						}
	
						if(!isDup) {
							var docStr = "<div class='File_list' style='margin: 0px;' name='comCostApp"+ProofCode+"_DocItem_"+KeyNo+"_"+docInfo.ProcessID+"'>"
								+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"CombineCostApplicationListEdit.comCostAppListEdit_DocDelete('"+ProofCode+"','"+KeyNo+"','"+docInfo.ProcessID+"')\"></a>"
								+"<a href='javascript:void(0);' class='btn_File ico_doc' onClick=\"CombineCostApplicationListEdit.comCostAppListEdit_LinkOpen('" + docInfo.ProcessID + "', '" + docInfo.forminstanceID + "', '" + docInfo.bstored + "', '" + docInfo.BusinessData2 + "')\">"
								+ nullToStr(docInfo.Subject, "("+"<spring:message code='Cache.ACC_lbl_noTitle' />"+")") 	+"</div>";
	
								
							docList.push(info);
								
							$("[name=LinkArea]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"]").append(docStr);
						}
					}
				}

				if(!isSearched) {	
					if(getItem.docList == null || getItem.docList.length == 0){
						getItem.docList = docList;
					} else {
						var tempList = getItem.docList;
						var index = getItem.docList.length;
						for(var i = 0; i < docList.length; i++) {
							tempList[index + i] = docList[i];
						}
						getItem.docList = tempList;
					}
					
					if(getItem.docMaxNo==null){
						getItem.docMaxNo = 0;
					}
						
					for(var i = 0; i<docList.length; i++){
						var docItem = docList[i];
						getItem.docMaxNo++;
						docItem.docNum = getItem.docMaxNo;
					}
				}
				
				me.comCostAppListEdit_linkCk(ProofCode, KeyNo);
			},
			

			//결재문서 연결 삭제
			comCostAppListEdit_DocDelete : function(ProofCode, KeyNo, docID){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_lbl_DeleteDocLink' />", "Confirmation Dialog", function(result){
					if(result){
						var item = me.pageExpenceAppTarget;
						var docList = item.docList;
						var tempList = [];
						
						for(var i = 0; i < docList.length; i++){
							var docItem = docList[i];
							if(docItem.ProcessID != docID){
								tempList.push(docItem);											
							} else {
								$("[name=comCostApp"+ProofCode+"_DocItem_"+KeyNo+"_"+docID+"]").remove();
								
								if(item.deletedDoc == null){
									item.deletedDoc = [docItem];
								}else{
									item.deletedDoc.push(docItem);
								}
							}
						}
						
						item.docList = tempList;
						me.comCostAppListEdit_linkCk(ProofCode, KeyNo);
					}
				});
			},
			
			
			combiCostApp_FileAttach : function(ProofCode, KeyNo) { var me = this; me.comCostAppListEdit_FileAttach(ProofCode, KeyNo); },
			simpApp_FileAttach : function(ProofCode, KeyNo) { var me = this; me.comCostAppListEdit_FileAttach(ProofCode, KeyNo); },
			comCostAppListEdit_FileAttach : function(ProofCode, KeyNo) {
				var me = this;
				me.tempVal.ProofCode = ProofCode;
				me.tempVal.KeyNo = KeyNo;
				
				accountFileCtrl.callFileUpload(this, 'CombineCostApplicationListEdit.comCostAppListEdit_FileCallback');
			},
			
			comCostAppListEdit_FileCallback : function(data) {
				var me = window.CombineCostApplicationListEdit;

				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				
				var getItem = me.pageExpenceAppTarget;

				if(getItem.uploadFileList == null){
					getItem.uploadFileList = data;
				}else{
					var tempList = getItem.uploadFileList;
					var index = getItem.uploadFileList.length;
					for(var i = 0; i < data.length; i++) {
						tempList[index+i] = data[i];						
					}
					getItem.uploadFileList = tempList;
				}
				
				if(getItem.fileMaxNo==null){
					getItem.fileMaxNo = 0;
				}
				
				for(var i = 0; i<data.length; i++){
					var fileItem = data[i];
					getItem.fileMaxNo++;
					fileItem.fileNum = getItem.fileMaxNo;
				}
				accountFileCtrl.closeFilePopup();
				me.comCostAppListEdit_UploadHTML(data, KeyNo, ProofCode, false);
				me.comCostAppListEdit_linkCk(ProofCode, KeyNo);
			},

			comCostAppListEdit_UploadHTML : function(data, KeyNo, ProofCode, isSearched) {
				var me = window.CombineCostApplicationListEdit;

				var list = data
				var fileList = [];
				var fileStr = "";
				
				if(list==null){
					return;
				}
				
				for(var i = 0; i<list.length; i++){
					var fileInfo = list[i];
					var info = $.extend({}, fileInfo);
					info.KeyNo = KeyNo
					
					var fileHtmlStr = "<div class='File_list' style='margin: 0px;' name='comCostApp"+ProofCode+"_FileItem_"+KeyNo+"_"+fileInfo.fileNum+"'>"
					if(fileInfo.FileID != null){
						fileHtmlStr = fileHtmlStr+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"CombineCostApplicationListEdit.comCostAppListEdit_FileDelete('"+ProofCode+"', '"+KeyNo+"','"+fileInfo.fileNum+"')\"></a>"
						+"<a href='javascript:void(0);' class='btn_File ico_file' onClick=\"CombineCostApplicationListEdit.comCostAppListEdit_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
						+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
						+"<a class='previewBtn' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accountFileCtrl.attachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "');\"></a>";
						+"</div>";
					}else{
						fileHtmlStr = fileHtmlStr+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"CombineCostApplicationListEdit.comCostAppListEdit_NewFileDelete('"+ProofCode+"', '"+KeyNo+"','"+fileInfo.fileNum+"')\"></a>"
						+"<a href='javascript:void(0);' class='btn_File ico_file'>"+ fileInfo.FileName 
						+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a></div>";
					}
					
					$("[name=LinkArea]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"]").append(fileHtmlStr);
				}
				
				me.comCostAppListEdit_linkCk(ProofCode, KeyNo);
			},
			
			comCostAppListEdit_FileDelete : function(ProofCode, KeyNo, fileNum){
				var me = this;
				
				Common.Confirm("<spring:message code='Cache.ACC_lbl_DeleteAttachFile' />", "Confirmation Dialog", function(result){	//파일을 삭제하시겠습니까?
					if(result){
						var item = me.pageExpenceAppTarget;
						var fileList = item.fileList;

						var idx = accFindIdx(fileList, "fileNum", fileNum);
						$("[name=comCostApp"+ProofCode+"_FileItem_"+KeyNo+"_"+fileNum+"]").remove();
						
						if(idx != -1){
							var fileItem = fileList[idx];
							fileList.splice(idx,1);
							if(item.deletedFile == null){
								item.deletedFile = [fileItem];
							}else{
								item.deletedFile.push(fileItem);
							}
						}
						me.comCostAppListEdit_linkCk(ProofCode, KeyNo);
					}
				});
			},
			
			comCostAppListEdit_NewFileDelete : function(ProofCode, KeyNo, fileNum){
				var me = this;
				
				Common.Confirm("<spring:message code='Cache.ACC_lbl_DeleteAttachFile' />", "Confirmation Dialog", function(result){	//파일을 삭제하시겠습니까?
					if(result){
						var item = me.pageExpenceAppTarget;
						
						var uploadFileList = item.uploadFileList;
						if(uploadFileList == null) {
							uploadFileList = item.fileList;
						}

						var idx = accFindIdx(uploadFileList, "fileNum", fileNum );
						$("[name=comCostApp"+ProofCode+"_FileItem_"+KeyNo+"_"+fileNum+"]").remove();
						
						if(idx != -1){
							var tempList = [];
							for(var i = 0; i < uploadFileList.length; i++) {
								if(i != idx) {
									tempList.push(uploadFileList[i]);
								}
							}
							if(tempList.length == 0) tempList = null;
							
							if(item.uploadFileList != null) {
								item.uploadFileList = tempList;
							} else {
								item.fileList = tempList;
							}
						}
						
						me.comCostAppListEdit_linkCk(ProofCode, KeyNo);
					}
				});
			},
			
			//추가된 파일과 문서연결 유무로 class 변경
			comCostAppListEdit_linkCk : function(ProofCode, KeyNo) {
				var me = this;
				
				var ckVal = false;

				var item = me.pageExpenceAppTarget;
				var fList = []
				if(item.fileList != null){
					fList = fList.concat(item.fileList);
				}
				if(item.uploadFileList != null){
					fList = fList.concat(item.uploadFileList);
				}
				
				if(fList != null){
					if(fList.length != 0){
						ckVal = true;
					}
				}

				var dList = item.docList;
				if(dList != null){
					if(dList.length != 0){
						ckVal = true;
					}
				}
				
				if(ckVal){
					$("[name=LinkArea]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"]").removeClass("border_none");
					$("[name=LinkArea]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"]").show();
				}else{
					$("[name=LinkArea]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"]").addClass("border_none");
				}
			},
			
			comCostAppListEdit_htmlFormSetVal : function(inputStr, replaceMap){
				return accComm.accHtmlFormSetVal(inputStr, replaceMap);
			},

			comCostAppListEdit_htmlFormDicTrans : function(inputStr) {
				return accComm.accHtmlFormDicTrans(inputStr);
			},
			
			comCostAppListEdit_FileDownload : function(SavedName, FileName, FileID){
				accountFileCtrl.downloadFile(SavedName, FileName, FileID)
			},
			
			comCostAppListEdit_LinkOpen : function(ProcessId, forminstanceID, bstored, expAppID){
				accComm.accLinkOpen(ProcessId, forminstanceID, bstored, expAppID);
			},
			
			//증빙별 고유 키
			comCostAppListEdit_getProofKey : function(ProofCode){
				var KeyField = "";
				if(ProofCode=='CorpCard'){
					KeyField = "CardUID";
				}else if(ProofCode=='TaxBill'){
					KeyField = "TaxUID";
				}else if(ProofCode=='CashBill'){
					KeyField = "CashUID";
				}else if(ProofCode=='PrivateCard'){
					KeyField = "ExpAppPrivID";
				}else if(ProofCode=='EtcEvid'){
					KeyField = "ExpAppEtcID";
				}else if(ProofCode=='Receipt'){
					KeyField = "ReceiptID";
				}
				return KeyField
			},

			//법인카드영수증 조회
			combiCostApp_onCardAppClick  : function(ReceiptID){
				var me = this;
				accComm.accCardAppClick(ReceiptID, me.pageOpenerIDStr);
			},

			//세금계산서 조회
			combiCostApp_onTaxBillAppClick  : function(TaxInvoiceID){
				var me = this;
				accComm.accTaxBillAppClick(TaxInvoiceID, me.pageOpenerIDStr);				
			},
			
			//모바일영수증 조회
			comCostAppListEdit_MobileAppClick : function(FileID){
				var me = this;
				accComm.accMobileReceiptAppClick(FileID, me.pageOpenerIDStr);
			},
			
			comCostAppListEdit_getStr : function(key) {
				var rtValue = "";
				if(key == null || key == 'undefined'){
					rtValue = "";
				}else{
					rtValue = key;
				}
				return rtValue;				
			},
			
			comCostAppListEdit_getNum : function(key) {
				var reg	= /^[0-9]+$/;
				if (reg.test(key)){
					rtValue = key;
				}else{
					rtValue = 0;
				}
				return rtValue;				
			},
			
			combiCostAppEE_etcEvidTypeChange : function(obj, KeyNo, inputVal) {
				var me = this;
				var val = "";
				if(obj == null){
					if(inputVal != null) {
						val = inputVal;			
					} else {
						val = $("[name=etcEvidRadio][keyno="+KeyNo+"]:checked").val();
					}
				} else {
					val = $(obj).val();
				}

				var item = me.pageExpenceAppTarget;
				item.IsWithholdingTax = val;
				
				if(val=="N") {
					$("[tag=TaxArea][keyno="+KeyNo+"]").css("display", "none");
					$("[tag=TaxVal]").val("");
					$("[tag=InsureArea][keyno="+KeyNo+"]").css("display", "none");
					$("[tag=InsureArea][keyno="+KeyNo+"]").find("[tag=Amount]").val("");
					item.IncomTax = "";
					item.IncomTaxAmt = 0;
					item.IncomeTax = "";
					item.LocalTax = "";
					item.LocalTaxAmt = 0;
					item.EmpInsurance = 0;
					item.AccidInsurance = 0;
					item.WorkingDay = 0;
					item.ActualDay = 0;
					
					// 버튼 추가 컨트롤 추가
					$("[name=IncomeTax]").hide();
                    $("[name=NormalTax]").show();
				} else if(val=="Y") {
					$("[tag=TaxArea][keyno="+KeyNo+"]").css("display", "");
					
					// 버튼 추가 컨트롤 추가
					$("[name=IncomeTax]").show();
                    $("[name=NormalTax]").hide();
                    
					if(me.requestType == "OUTSOURCING") {
						// 외주용역비용정산 & 기타증빙_원천세 > 지급방법/지급대상 default 값 세팅
						$("[name=ComboSelect][field=PayMethod][proofcode=EtcEvid][keyno="+KeyNo+"]").val("C").trigger("change");
						$("[name=ComboSelect][field=PayTarget][proofcode=EtcEvid][keyno="+KeyNo+"]").val("Vendor").trigger("change");
						$("[name=ComboSelect][field=TaxType][proofcode=EtcEvid][keyno="+KeyNo+"]").attr("disabled", "disabled");
						$("[name=ComboSelect][field=TaxCode][proofcode=EtcEvid][keyno="+KeyNo+"]").attr("disabled", "disabled");
						// 외주용역비만 고용보험,산재보험 추가
						$("[tag=InsureArea][keyno="+KeyNo+"]").css("display", "");
						// 수정시에는 변경없이 기존값 유지
						/*var objTotalAmount = $("[name=CombiCostInputField][proofcode=EtcEvid][keyno="+KeyNo+"][field=TotalAmount]");
						var totalAmount = objTotalAmount.val().replace(/,/gi, "");
						if(obj != null && totalAmount) objTotalAmount.trigger("keyup");*/
					}else{
						$("[tag=InsureArea][keyno="+KeyNo+"]").css("display", "none");
						$("[tag=InsureArea][keyno="+KeyNo+"]").find("[tag=Amount]").val("");
						item.EmpInsurance = 0;
						item.AccidInsurance = 0;
						item.WorkingDay = 0;
						item.ActualDay = 0;
					}
				}
			},
			
			comCostAppListEdit_saveList : function() {
				if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				
				var me = this;
				var Rownum = 0;
				
				//SC, EA일 경우 증빙 단의 세부증빙 데이터를 수정된 세부증빙 데이터로 재지정
				if(me.appType != "CO") {
					$.each(me.pageExpenceAppTarget.divList[0], function(key, value) {me.pageExpenceAppTarget[key] = value });
				}
				
				var item = me.pageExpenceAppTarget;
				var divList = item.divList;
				var divSum = 0;
				
				var fileList = item.fileList;
				var uploadFileList = item.uploadFileList;
				var docList = item.docList;
				
				if(item.PostingDate == undefined || item.PostingDate == "") {
					item.PostingDate = item.ProofDate;
					item.PostingDateStr = item.ProofDateStr;
				}
				
				var dateInputList = $("[name=DateArea][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]");
				for(var i = 0; i < dateInputList.length; i++){
					var input = dateInputList[i];
					var dataField = input.getAttribute("datafield");
					var strVal = $("#"+input.id+"_Date").val();
					var val = strVal.replaceAll(".","");

					item[dataField] = val;
					item[dataField+"Str"] = strVal;
				}
				
				if(divList==null){
					Common.Inform("<spring:message code='Cache.ACC_019' />");
					return;
				}
				if(divList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_019' />");
					return;
				}
				if(isEmptyStr(item.TotalAmount)){
					Common.Inform("<spring:message code='Cache.ACC_052' />");
					return;
				}				
				if(isEmptyStr(item.ProofDate)){
					Common.Inform("<spring:message code='Cache.ACC_053' />");
					return;
				}
		   		if(item.ProofCode == 'PrivateCard' && isEmptyStr(item.PersonalCardNo)){
					Common.Inform("<spring:message code='Cache.ACC_055' />");
					return;
			  	}
				
				//톻합비용신청일때만
				if(me.appType == "CO") {
					if(item.ProofCode == "EtcEvid" && Common.getBaseConfig("useWriteVendor", sessionObj["DN_ID"]) == "Y") {
						if(isEmptyStr(item.VendorNo)){
							Common.Inform("<spring:message code='Cache.ACC_msg_emptyVendorNo' />"); //사업자번호가 입력되지 않았으므로 저장 시 자동으로 사업자번호가 발번됩니다.
						}
						if(isEmptyStr(item.VendorName)){ 
							Common.Inform("<spring:message code='Cache.ACC_msg_emptyVendorName' />"); //거래처명이 입력되지 않은 항목이 있습니다.
							return;
						}
					} else {
						if(isEmptyStr(item.VendorNo)){
							Common.Inform("<spring:message code='Cache.ACC_054' />");
							return;
						}
					}			
				}
				
				// 환율 관련 체크
				if (me.exchangeIsUse == "Y" && item.ProofCode == "EtcEvid") {
					if (item.Currency == "") {
						Common.Inform("<spring:message code='Cache.ACC_msg_Require_Currency' />"); //환종은 필수로 입력하여야 합니다.
						return;
					}
					
					if (item.Currency != "KRW") {
				   		var getExchangeRate = nullToBlank(item.ExchangeRate);
				   		getExchangeRate = Number(AmttoNumFormat(getExchangeRate));
				   		
						if (getExchangeRate == "" || isNaN(getExchangeRate) || getExchangeRate == 0) {
							Common.Inform("<spring:message code='Cache.ACC_msg_Require_ExchangeRate' />"); //환율은 필수로 입력하여야 합니다.
							return;
						}
						
				   		var getLocalAmount = nullToBlank(item.LocalAmount);
				   		getLocalAmount = Number(AmttoNumFormat(getLocalAmount));
				   		
						if (getLocalAmount == "" || isNaN(getLocalAmount) || getLocalAmount == 0) {
							Common.Inform("<spring:message code='Cache.ACC_msg_Require_LocalAmount' />"); //현지금액은 필수로 입력하여야 합니다.
							return;
						}
					}
				}

				var BriefMap = me.pageCombiAppComboData.BriefMap;
				
				for(var y = 0; y < divList.length; y++){
					var divItem = divList[y];
					var divAmt = divItem.Amount;

					// 통합비용 신청(CO)의 경우 세부증빙별 관리항목 지정 가능 
					/* if(me.appType != "CO") {
				   	  	divItem.ReservedStr2_Div = divList[0].ReservedStr2_Div;
	                    divItem.ReservedStr3_Div = divList[0].ReservedStr3_Div;
					} */
					
					divSum = divSum+ckNaN(AmttoNumFormat(divAmt));

					var BriefInfo = BriefMap[divItem.StandardBriefID];
					if(BriefInfo.IsFile=='Y'){
						if ((!fileList || fileList.length == 0) && (!uploadFileList || uploadFileList.length == 0)) {
							var msg = "<spring:message code='Cache.ACC_msg_Require_AttchFile' />";//파일첨부 필수입니다
							Common.Inform(msg);
							return;
							break;
						}
					}
					
					if(BriefInfo.IsDocLink=='Y'){
						if (!docList || docList.length == 0) {
							var msg = "<spring:message code='Cache.ACC_msg_Require_DocLink' />";//문서연결 필수입니다
							Common.Inform(msg);
							return;
							break;
						}
					}
					
					if(isUseSB == "Y" && isEmptyStr(divItem.StandardBriefID)){
						Common.Inform("<spring:message code='Cache.ACC_050' />");
						return;	
					}
					
					if(isEmptyStr(divItem.AccountCode)){
						Common.Inform("<spring:message code='Cache.ACC_060' />");
						return;
					}
					
					if(isEmptyStr(divItem.CostCenterCode)){
						Common.Inform("<spring:message code='Cache.ACC_059' />");
						return;
					}
					
			   		if(isEmptyStr(divItem.UsageComment)){
						Common.Inform("<spring:message code='Cache.ACC_046' />");
						return;
			   		}
			   		
					var getDivAmt = nullToBlank(divItem.Amount);
					getDivAmt = Number(AmttoNumFormat(getDivAmt));
					if(isNaN(getDivAmt)){
						Common.Inform("<spring:message code='Cache.ACC_lbl_amtValidateErr' />");
						return;
					}

					//관리항목 (ACC_CTRL) 필수체크 추가
                    var reqchk = true;
                    $("input[keyno=" + item.KeyNo + "][rownum=" + divItem.Rownum + "][requiredVal=required][code],div[keyno=" + item.KeyNo + "][rownum=" + divItem.Rownum + "][requiredVal=required][code],select[keyno=" + item.KeyNo + "][rownum=" + divItem.Rownum + "][requiredVal=required][code]").each(function(i, item){
                        if($(item).val() == "" && $(item).attr("viewtype") != "Date"){
                            var msg = $(item).closest("dd").prev().text() + "<spring:message code='Cache.ACC_msg_required' />"
                            Common.Inform(msg);

                            reqchk = false;
                            return false;
                        }else{
                            if($(item).find("input[code]").val() == ""){
                                var msg = $(item).closest("dd").prev().text() + "<spring:message code='Cache.ACC_msg_required' />"
                                Common.Inform(msg);

                                reqchk = false;
                                return false;
                            }
                        }
                    });
                    if(!reqchk) return;
				}
				
				if(ckNaN(AmttoNumFormat(item.TotalAmount)) < divSum){
					Common.Inform("<spring:message code='Cache.ACC_015' />");
					return;
				}
				
				if(me.appType == "CO" && item.ProofCode == "TaxBill") {
				    if(ckNaN(AmttoNumFormat(item.TotalAmount)) != divSum + Number(item.TaxAmount)){
					    var msg = "전체 청구금액과 세액의 합이 합계금액과 다릅니다.";
						Common.Inform(msg);
						return;
					} else {
						divSum = divSum + item.TaxAmount; //상단 청구금액 표시에는 전체 청구금액 + 세액으로 표시되도록
					}
				}
				
				item.divSum = divSum;
				
				//TODO: 예산 통제 추가				
				
				try{
					var targetObj = me.pageExpenceAppTarget; 
					accountCtrl.popupCallBackStrObj([targetObj]);
				}catch (e) {
					coviCmn.traceLog(e);
					coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
				}
				
				window.close(); 
			},
			
			comCostAppListEdit_closePopup : function() {
				window.close(); 
			},
			
			ctrlComboChange: function(obj){
				var me = this;
				var type = $(obj).attr("type");
				var ProofCode = $(obj).attr("proofcd");
	            var KeyNo = $(obj).attr("keyno");
	            var Rownum = $(obj).attr("Rownum");
	         
	            if(me.ApplicationType=='SC')me.simpApp_ComboChange(obj, type, ProofCode, KeyNo, Rownum);
	            else if(me.ApplicationType=='CO')me.combiCostApp_ComboChange(obj, ProofCode, KeyNo, type, Rownum);
			},
			setChkYN: function (obj) {
	            var me = this;
	            var val = $(obj).val();

	            if(val == "Y"){
	                val = "";
	            }else{
	                val = "Y";
	            }
	            
	            obj.value = val;
	        },

			callBizTripPopup : function(obj, name) {
				var me = this;
	            var obj = $(obj).prev();

				var ProofCode = $(obj).attr("proofcd");
	            var KeyNo = $(obj).attr("keyno");
	            var Rownum = $(obj).attr("rownum");
	            var code = $(obj).attr("code");
	            
	            var popupTit = name;
	            var popupID;
	            var popupName;
	            var callBack;
	            var width;
	            var height;
	            
	            me.tempVal.KeyNo = KeyNo;
	            me.tempVal.ProofCode = ProofCode;
	            me.tempVal.Rownum = Rownum;
	            me.tempVal.code = code;

	            if(code == "D02") {
	            	//D02: 유류비
		            popupID = "DistancePopup";
		            popupName = "DistancePopup";
		            callBack = "SetDistanceCallBack";
		            width = "1000px";
		            height = "800px";
	            } else if(code == "D03") {
	            	//D03: 일비 
            	  	popupID = "DailyPopup";
		            popupName = "DailyPopup";
		            callBack = "SetDailyCallBack";
		            width = "550px";
		            height = "400px";
	            } else if(code == "Z09") {
	            	//Z09: tmap 없는 유류비
		            popupID = "DistancePopup";
		            popupName = "DistancePopup";
		            callBack = "SetDistanceCallBack";
		            width = "1000px";
		            height = "550px";
	            }
	            
	            var url =	"/account/accountCommon/accountCommonPopup.do?"
						+	"popupID="		+	popupID		+	"&"
						+	"popupName="	+	popupName	+	"&"
						+	"parentNM="		+	me.pageName	+	"&"
						+	"jsonCode="		+	code		+	"&"
						+	"KeyNo="		+	KeyNo		+	"&"
						+	"ProofCode="	+	ProofCode	+	"&"
						+	"RequestType="	+	me.requestType	+	"&" 
						+	"Rownum="		+	Rownum			+	"&" 
						+	me.pageOpenerIDStr
						+	"includeAccount=N&"
						+	"IsEditPopup=Y&"
						+	"companyCode="	+	me.CompanyCode	+ "&"
						+	"callBackFunc="	+	callBack;
	            
	            Common.open("", popupID, popupTit, url, width, height, "iframe", true, null, null, true);
			},
			
			SetDistanceCallBack: function (info) {
	            var me = this;
				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				var Rownum = me.tempVal.Rownum;
				var pageList = me.pageExpenceAppTarget;
				var KeyField = me.comCostAppListEdit_getProofKey(ProofCode);
				var getItem =  me.pageExpenceAppTarget;
				
				var fuelList = $.extend(true,[],info['FuelExpenceAppEvidList']);
				
				var FuelRealPrice = 0;
				var totDistance = 0;
				var lastDate = '';
				
	            var code = me.tempVal.code;
	            var obj = $("input[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']");
	            var PopCode = {};
				var lastDateHidden = new Date(lastDate);
	            var Distance;
				
				$(fuelList).each(function(idx,item){
					item.BizTripDateStr = item.BizTripDate;
					item.BizTripDate = item.BizTripDate.replace(/\./gi, '');	
					FuelRealPrice += Number(item.FuelRealPrice);
					totDistance += Number(item.Distance);
					
				    if(Number(item.BizTripDate) > lastDate.replace(/\./gi, '')) {
				    	lastDate = item.BizTripDateStr;
				    }
				});				

				lastDateHidden.format("MM/dd/yyyy");
				
	            PopCode['Distance'] = info['Distance'];
	            PopCode['FuelExpenceAppEvidList'] = info['FuelExpenceAppEvidList'];
	            PopCode = JSON.stringify(PopCode);
	            
	            Distance = toAmtFormat(totDistance);
	            
	            if(code!='D02') {
	            	Distance = toAmtFormat(totDistance);
	            }
	            
				if(me.ApplicationType == 'CO') {
					$("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(FuelRealPrice);
					$("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();
					
					//divList 수정
					me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "Amount", FuelRealPrice);
					
					//총합 계산
					me.setBizTripTotalAmount(ProofCode, KeyNo, Rownum, getItem, FuelRealPrice);
					
					$("[name=DateArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=text]").val(lastDate);
					$("[name=DateArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=hidden]").val(lastDateHidden);
					$("[name=DateArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");
				} else {
					$("[tag=Amount][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(FuelRealPrice);
					$("[tag=Amount][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();
					
					//divList 수정
					me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "Amount", FuelRealPrice);
					
					//총합 계산
					me.setBizTripTotalAmount(ProofCode, KeyNo, Rownum, getItem, FuelRealPrice);
					
					$("[name$=AppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=text]").val(lastDate);
					$("[name$=AppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=hidden]").val(lastDateHidden);
					$("[name$=AppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");
				}

	            $("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='value']").val(Distance);
	            $("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='code']").val(PopCode);
	            
	            accountCtrl._onSaveJson(me, obj, "CtrlArea", ProofCode, KeyNo, Rownum);
	            
				me.tempVal = {};
	        },

			SetDailyCallBack : function(returnList){
				var me = this;
				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				var Rownum = me.tempVal.Rownum;
 
				var getItem =me.pageExpenceAppTarget;
				
				var dailyList = $.extend(true,[],returnList['DailyExpenceAppEvidList']);
				
				var DailyAmount = 0;
				var commentHtml = "";
				var WorkingDays = 0;
				var lastDate = '';
				
	            var code = me.tempVal.code; 
	            var obj = $("input[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']");
	            var PopCode = {};
				var lastDateHidden = new Date(lastDate);
				
				$(dailyList).each(function(idx,item){
					item.BizTripDateStStr = item.BizTripDateSt;
					item.BizTripDateSt = item.BizTripDateSt.replace(/\./gi, '');
					item.BizTripDateEdStr = item.BizTripDateEd;
					item.BizTripDateEd = item.BizTripDateEd.replace(/\./gi, '');

					DailyAmount += Number(item.DailyAmount);
					WorkingDays += Number(item.WorkingDays);
					
					commentHtml += item.BizTripDateSt + " ~ " + item.BizTripDateEd + "(" + item.DailyTypeNM + ") " + toAmtFormat(item.DailyAmount) + "<spring:message code='Cache.ACC_krw'/>" + " \n";
				    
				    if(Number(item.BizTripDateEd.replace(/\./gi, '')) > lastDate.replace(/\./gi, '')) {
				    	lastDate = item.BizTripDateEdStr;
				    }				    
				});				

				lastDateHidden.format("MM/dd/yyyy");
	            
	            PopCode['DailyExpenceAppEvidList'] = returnList['DailyExpenceAppEvidList'];
	            PopCode = JSON.stringify(PopCode);		
				
				if(me.ApplicationType == 'CO') {
					$("[name=DivCommentField][datafield=UsageComment][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(commentHtml);
					$("[name=DivCommentField][datafield=UsageComment][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();

					$("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(DailyAmount);
					$("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();
					
					//divList 수정
					me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "Amount", DailyAmount);
					
					//총합 계산
					me.setBizTripTotalAmount(ProofCode, KeyNo, Rownum, getItem, DailyAmount);
					
					$("[name=DateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=text]").val(lastDate);
					$("[name=DateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=hidden]").val(lastDateHidden);
					$("[name=DateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");
				} else {
					$("[tag=Comment][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(commentHtml);
					$("[tag=Comment][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();
					
					$("[tag=Amount][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(DailyAmount);
					$("[tag=Amount][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();
					
					//divList 수정
					me.comCostAppListEdit_setDivVal(ProofCode, KeyNo, Rownum, "Amount", DailyAmount);
					
					//총합 계산
					me.setBizTripTotalAmount(ProofCode, KeyNo, Rownum, getItem, DailyAmount);
					
					$("[name$=AppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=text]").val(lastDate);
					$("[name$=AppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=hidden]").val(lastDateHidden);
					$("[name$=AppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");
				}
		           
	            $("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='value']").val(WorkingDays);
	            $("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='code']").val(PopCode);

	            accountCtrl._onSaveJson(me, obj, "CtrlArea", ProofCode, KeyNo, Rownum);
				me.tempVal = {};
			},
			
			//출장항목(일비,유류비) 총액 계산
			setBizTripTotalAmount : function(ProofCode, KeyNo, Rownum, item, amount) {
				var me = this;
				
				var TotalAmount = 0;
				for(var i = 0; i < item.divList.length; i++) {
				    var divItem = item.divList[i];
				    if(divItem.ReservedStr2_Div != undefined) {
					    if('D02' in divItem.ReservedStr2_Div || 'D03' in divItem.ReservedStr2_Div || 'Z09' in divItem.ReservedStr2_Div)
					    	TotalAmount += divItem.Amount;
				    }
				}
				
				var totalField;
				if(me.appType == "CO") {
					totalField = $("[name=CombiCostInputField][field=TotalAmount][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
				} else {
					totalField = $("[name=TotalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]");;
				}
				
				if(totalField.length > 0) {
					totalField.val(toAmtFormat(TotalAmount));
					me.comCostAppListEdit_setListVal(ProofCode, "TotalAmount", KeyNo, TotalAmount);
				}
			},
			
			//편익제공 팝업 오픈
			callAttendantPopup : function(obj, name) {
				var me = this;
	            var obj = $(obj).prev();

				var ProofCode = $(obj).attr("proofcd");
	            var KeyNo = $(obj).attr("keyno");
	            var Rownum = $(obj).attr("rownum");
	            var code = $(obj).attr("code");
	            
	            me.tempVal.KeyNo = KeyNo;
	            me.tempVal.ProofCode = ProofCode;
	            me.tempVal.Rownum = Rownum;
	            me.tempVal.code = code;

	            var popupTit = name;
	            var popupID;
	            var popupName;
	            var callBack;
	            var width;
	            var height;
	            
	            if(code=="C07") {//C07:tmap없는 유류비
		            popupID = "AttendantPopup";
		            popupName = "AttendantPopup";
		            callBack = "SetAttendantCallBack";
		            width = "1000px";
		            height = "550px";
	            }
	            
	            var url =	"/account/accountCommon/accountCommonPopup.do?"
						+	"popupID="		+	popupID		+	"&"
						+	"popupName="	+	popupName	+	"&"
						+	"parentNM="		+	me.pageName	+	"&"
						+	"jsonCode="		+	code		+	"&"
						+	"KeyNo="		+	KeyNo		+	"&"
						+	"ProofCode="	+	ProofCode	+	"&"
						+	"RequestType="	+	me.requestType	+	"&" 
						+	me.pageOpenerIDStr
						+	"includeAccount=N&"
						+	"companyCode="	+	me.CompanyCode	+ "&"
						+	"callBackFunc="	+	callBack;
	            
	            Common.open("", popupID, popupTit, url, width, height, "iframe", true, null, null, true);
			},
			
			SetAttendantCallBack : function(returnList) {
				var me = this;
				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				var Rownum = me.tempVal.Rownum;
				var code = me.tempVal.code;
					            
	            var obj = $("input[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']");
	            
	            var attendList = $.extend(true,[],returnList['AttendantList']);
	            var PopCode = {};
	            PopCode['AttendantList'] = returnList['AttendantList'];
	            PopCode = JSON.stringify(PopCode);
	           
				var displayText = $(attendList).length < 2 
									? $(attendList)[0].UserName 
									: "<spring:message code='Cache.msg_BesidesCount' />".replace("{0}", $(attendList)[0].UserName).replace("{1}", $(attendList).length-1);
	           	
				$("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='value']").val(displayText);
	            $("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='code']").val(PopCode);
	            
	            accountCtrl._onSaveJson(me, obj, "CtrlArea", ProofCode, KeyNo, Rownum);
				me.tempVal = {};
			}
	}
	window.CombineCostApplicationListEdit = CombineCostApplicationListEdit;
	CombineCostApplicationListEdit.pageInit();
})(window);	

function InputDocLinks(szValue) {
    try {
    	window.CombineCostApplicationListEdit.comCostAppListEdit_LinkComp(szValue); 
    	// szValue : [ProcessID(ProcessArchiveID)]@@@[FormPrefix]@@@[Subject]^^^[ProcessID(ProcessArchiveID)]@@@[FormPrefix]@@@[Subject]
    	// ex) 2402569@@@WF_FORM_EACCOUNT_LEGACY@@@결재연동 1713^^^2400107@@@WF_FORM_EACCOUNT_LEGACY@@@통합 비용 신청 - 0706 #1
    }
    catch (e) {
    	coviCmn.traceLog(e);
    }
}
</script>
