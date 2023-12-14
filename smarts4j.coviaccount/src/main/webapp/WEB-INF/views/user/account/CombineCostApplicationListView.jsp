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
	<!-- 상단 버튼 시작 -->
	<div class="cRConTop" name="aprvBtnArea">
		<div class="cRTopButtons">	
			<!-- 증빙 미리보기 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationListView.comCostAppListView_callEvidPreview()" name="comCostAppListView_previewBtn">
				<spring:message code="Cache.ACC_btn_EvidPreview"/>
			</a>
		</div>
	</div>
	<div class="layer_divpop ui-draggable docPopLayer"  style="width:auto;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent form_box">
				<div class="rowTypeWrap formWrap tsize">
					<!-- 컨텐츠 시작 -->
					<div id="comCostAppListView_contView">
						<div class="allMakeView">
							<div class="inpStyle01 allMakeTitle" style="display:none">
								<input type="hidden" class="inpStyle01" id="comCostAppListView_PropertyBudget" tag="Budget">
							</div>
						</div>
						<div class="inStyleSetting">	
							<div class="TaccWrap" style="height: 600px;">
								<div class="total_acooungting_write">
									<div class="total_acooungting_write_status" name="comCostAppListView_evidListArea"></div>
								</div>
							</div>
						</div>
					</div>
					<!-- 컨텐츠 끝 -->
					<div class="e_formR" style="display: none; padding-left: 45px;" id="comCostAppListView_evidPreview">
						<div class="e_formIarea">
							<div class="e_formRTitle">
								<span class="e_TitleText"></span>
								<span class="e_TitleBtn">
									<span class="pagecount"><span class="countB" id="comCostAppListView_previewCurrentPage"></span>/<span id="comCostAppListView_previewTotalPage"></span></span>
									<span class="pagingType01"><a onclick="accComm.accClickPaging(this);" class="pre"></a><a onclick="accComm.accClickPaging(this);" class="next"></a></span>
								</span>
							</div>
							<div class="e_formRCont" id="comCostAppListView_evidContent" style="height: 670px;">
								<div class="billW" style="display: none; padding-top: 100px;"></div>
								<div class="invoice_wrap" style="width:910px; display: none;"></div>
								<input type="hidden" id="comCostAppListView_hidReceiptID" value="">			
							</div>
							<div class="wordView" id="comCostAppListView_fileContent" style="height: 670px;">
								<iframe id="comCostAppListView_iframePreview" name="IframePreview" frameborder="0" width="100%" height="800px" scrolling="no" title=""></iframe>
								<input type="hidden" id="comCostAppListView_previewVal" value="">						
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
<script>
//증빙 조회 전용
if (!window.CombineCostApplicationListView) {
	window.CombineCostApplicationListView = {};
}

(function(window) {
	var requestType = "<%=request.getParameter("RequestType") %>";
	var CombineCostApplicationListView = {			
			pageOpenerIDStr : "openerID=CombineCostApplicationListView&",
			pageCombiAppFormList : {
					CorpCardViewFormStr		: "",
					DivViewFormStr			: "",
					TaxBillViewFormStr		: "",
					TaxBillDivViewFormStr	: "",
					PaperBillViewFormStr	: "",
					CashBillViewFormStr		: "",
					PrivateCardViewFormStr		: "",
					EtcEvidViewFormStr		: "",
					ReceiptViewFormStr		: "",
			},

			pageCombiAppComboData : {
				TaxTypeList		: [],
				TaxCodeList		: [],
				WHTaxList		: [],
				PayMethodList	: [],
				PayTypeList		: [],
				PayTargetList	: [],
				ProvideeList	: [],
				BillTypeList	: [],
				TaxTypeMap		: {},
				TaxCodeMap		: {},
				WHTaxMap		: {},
				PayMethodMap	: {},
				PayTypeMap		: {},
				PayTargetMap	: {},
				ProvideeMap		: {},
				BillTypeMap		: {},
			},

			pageExpenceAppEvidList : [],
			pageExpenceAppObj : {},

			pageInit : function(inputParam) {
				var me = this;
				
				setPropertySearchType('Budget','comCostAppListView_PropertyBudget'); //예산관리 사용여부
				
				$("[name=comCostAppListView_evidListArea]").html("");
				me.comCostAppListView_FormInit();
				
				var expAppListIDs = "<%=request.getParameter("expAppListIDs") %>";
				if(expAppListIDs != "null"){
					me.comCostAppListView_searchData(expAppListIDs);
				}
				
				if(Common.getBaseConfig("IsUseIO") == "N"){
					$("[name=noIOArea]").remove();
					$("[name=colIOSBArea]").attr("colspan", Number($("[name=colIOSBArea]").attr("colspan")) - 1);
					$("[name=FileViewArea]").attr("colspan", Number($("[name=FileViewArea]").attr("colspan")) - 1);
				}
				if(Common.getBaseConfig("IsUseStandardBrief") == "N") {
					$("[name=noSBArea]").remove();
					$("[name=colIOSBArea]").attr("colspan", Number($("[name=colIOSBArea]").attr("colspan")) - 1);
					$("[name=FileViewArea]").attr("colspan", Number($("[name=FileViewArea]").attr("colspan")) - 1);
				}
				if($("#comCostAppListView_PropertyBudget").val() == "" || $("#comCostAppListView_PropertyBudget").val() == "N") {
					$("[name=noBDArea]").remove();
					$("[name=colIOSBArea]").attr("colspan", Number($("[name=colIOSBArea]").attr("colspan")) - 1);
					$("[name=FileViewArea]").attr("colspan", Number($("[name=FileViewArea]").attr("colspan")) - 1);
				}
			},
			pageView : function() {
				var me = this;
			},
			
			//콤보 데이터 조회
			comCostAppListView_comboDataInit : function() {
				var me = this;
				$.ajax({
					type:"POST",
					url:"/account/accountCommon/getBaseCodeDataAll.do",
					data:{
						codeGroups : "TaxType,WHTax,PayMethod,PayType,PayTarget,BillType,CompanyCode",
						CompanyCode : me.pageExpenceAppObj.CompanyCode
					},
					
					success:function (data) {
						if(data.result == "ok"){
							var codeList = data.list
							me.pageCombiAppComboData.TaxTypeList = codeList.TaxType;
							me.pageCombiAppComboData.PayMethodList = codeList.PayMethod;
							me.pageCombiAppComboData.PayTypeList = codeList.PayType;
							me.pageCombiAppComboData.PayTargetList = codeList.PayTarget;

							me.pageCombiAppComboData.WHTaxList = codeList.WHTax;
							
							me.pageCombiAppComboData.ProvideeList = codeList.CompanyCode;
							me.pageCombiAppComboData.BillTypeList = codeList.BillType;
							
							me.comCostAppListView_makeCodeMap(me.pageCombiAppComboData.TaxTypeList, "TaxType", "Code", "CodeName");
							me.comCostAppListView_makeCodeMap(me.pageCombiAppComboData.PayMethodList, "PayMethod", "Code", "CodeName");
							me.comCostAppListView_makeCodeMap(me.pageCombiAppComboData.PayTypeList, "PayType", "Code", "CodeName");
							me.comCostAppListView_makeCodeMap(me.pageCombiAppComboData.PayTargetList, "PayTarget", "Code", "CodeName");
							me.comCostAppListView_makeCodeMap(me.pageCombiAppComboData.WHTaxList, "WHTax", "Code", "CodeName", true, true, false, false, true);
							me.comCostAppListView_makeCodeMap(me.pageCombiAppComboData.ProvideeList, "Providee", "Code", "CodeName");
							me.comCostAppListView_makeCodeMap(me.pageCombiAppComboData.BillTypeList, "BillType", "Code", "CodeName");
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
						CompanyCode : me.pageExpenceAppObj.CompanyCode
					},
					success:function (data) {
						if(data.result == "ok"){
							me.pageCombiAppComboData.TaxCodeList = data.list
							me.comCostAppListView_makeCodeMap(me.pageCombiAppComboData.TaxCodeList, "TaxCode", "Code", "CodeName");
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error(error.message);
					}
				});
			},

			CODEMAPSTR : "me.pageCombiAppComboData.",
			comCostAppListView_makeCodeMap : function(List, name, dataField, labelField) {
				var me = this;
				for(var i = 0; i<List.length; i++){
					var item = List[i];
					
					//var evalStr = me.CODEMAPSTR+name+"Map[item[dataField]] = item";
					//eval(evalStr);
					me.pageCombiAppComboData[name+"Map"][item[dataField]] = item;
				}
			},
			
			//html폼 로드
			comCostAppListView_FormInit : function() {
				var me = this;
				var formPath = Common.getBaseConfig("AccountApplicationFormPath");
				
				$.ajaxSetup({async:false});
				
				$.get(formPath + "CombiCostApp_ViewForm_CorpCard_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.CorpCardViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_Div_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.DivViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_TaxBill_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.TaxBillViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_TaxBillDiv_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.TaxBillDivViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_PaperBill_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.PaperBillViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_CashBill_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.CashBillViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_PrivateCard_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.PrivateCardViewFormStr = val;
				});				
				$.get(formPath + "CombiCostApp_ViewForm_EtcEvid_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.EtcEvidViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_Receipt_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.ReceiptViewFormStr = val;
				});
			},

			maxViewKeyNo : 0,
			//상세정보 조회
			comCostAppListView_searchData : function(expAppListIDs) {
				var me = this;
				$.ajax({
					url:"/account/expenceApplication/searchExpenceApplicationByListIDs.do",
					cache: false,
					data:{
						expAppListIDs : expAppListIDs
					},
					type:'POST',
					success:function (data) {
						
						if(data.result == "ok"){
							me.pageExpenceAppEvidList = data.data.pageExpenceAppEvidList;
							// requestType = "";

						   	for(var i=0;i<me.pageExpenceAppEvidList.length; i++){
						   		var item = me.pageExpenceAppEvidList[i];
								me.maxViewKeyNo++;
								item.ViewKeyNo = me.maxViewKeyNo;
								
								if(requestType == "INVEST") {
									item.InvestItem = item.ReservedStr1;
									item.InvestTarget = item.ReservedStr2;
								}
								if(requestType == "BIZTRIP" || requestType == "OVERSEA") {
									item.BizTripItem = item.ReservedStr1;
									item.BizTripItemNM = item.ReservedStr2;
								}
								if(requestType == "SELFDEVELOP") {
									for(var j = 0; j < item.divList.length; j++) {
										item.divList[j].SelfDevelopDetail = item.divList[j].ReservedStr1_Div;
									}
									item.SelfDevelopDetail = item.ReservedStr1_Div;
								} else if(requestType == "ENTERTAIN") {
									item.EntertainVendor = item.ReservedStr1;
									item.EntertainPurpose = item.ReservedStr2;
									item.InsideAttendantName = item.ReservedStr3;
									item.OutsideAttendantName = item.ReservedStr4;
									item.InsideAttendantNum = item.ReservedInt1;
									item.OutsideAttendantNum = item.ReservedInt2;
								}
						   	}
						   	
							me.pageExpenceAppObj = data.data;
							me.pageExpenceAppObj.isNew = "N";
							me.pageExpenceAppObj.isSearched = "Y"

							me.comCostAppListView_comboDataInit();
							me.comCostAppListView_makeHtmlViewFormAll();
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},

			//조회 폼 생성
			comCostAppListView_makeHtmlViewFormAll : function(){
				var me = this;
				var proofCode = "";
				var tableStr = ""; 
				
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];
					
					var htmlStr = me.comCostAppListView_makeViewHtmlForm(getItem, i+1);
					
					if(proofCode != getItem.ProofCode) {
						if(proofCode != "") {
							tableStr += '</tbody></table>';
						}
						proofCode = getItem.ProofCode;
						
						var title = Common.getDic('ACC_lbl_' + proofCode + 'UseInfo');
						tableStr += '<p class="taw_top_sub_title">'+title+'</p>'
									+ '<table class="acstatus_wrap">'
									+ '<tbody>'
									+ htmlStr
					} else {
						tableStr += htmlStr;
					}
				}
					
				$("[name=comCostAppListView_evidListArea]").html(tableStr);
				if(requestType != 'VENDOR'){
					$("[name=DivViewArea]").hide(); // 상세 지급정보표시용
				}

				proofCode = "";
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];
					
					if(proofCode != getItem.ProofCode) {
						proofCode = getItem.ProofCode;
					} else {
						$("tr[name=headerArea][viewkeyno="+getItem.ViewKeyNo+"]").remove();
					}
					
					me.comCostAppListView_makeHtmlChkColspanApv($("[name=evidItemAreaApv][viewkeyno="+getItem.ViewKeyNo+"]"));

					if(isEmptyStr(getItem.TaxInvoiceID) && getItem.ProofCode=="TaxBill"){
						$("[name=noTaxIFView][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").remove();
					}
					
					if(!isEmptyStr(getItem.PayMethod)) {
						 $("[name=PayArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").show();
					}
					
					if((getItem.docList == null && getItem.fileList == null) 
							|| ((getItem.docList != null && getItem.docList.length == 0) && (getItem.fileList != null && getItem.fileList.length == 0))) {
						$("[name=fileDocAreaApv][viewkeyno=" + getItem.ViewKeyNo + "]").remove();
					} else {
						$("[name=evidItemAreaApv][viewkeyno=" + getItem.ViewKeyNo + "]").find("td").each(function(i, obj) { 
							if($(obj).attr("rowspan") != undefined) { 
								$(obj).attr("rowspan", Number($(obj).attr("rowspan"))+1) 
							} 
						});
						
						if(getItem.docList != null){
							for(var y = 0; y<getItem.docList.length; y++){
								var getDoc = getItem.docList[y];
								var str = 						
									"<a href='javascript:void(0);' class='btn_File ico_doc' style='margin-right: 10px;' onClick=\"CombineCostApplicationListView.comCostAppListView_LinkOpen('" + getDoc.ProcessID + "', '" + getDoc.forminstanceID + "', '" + getDoc.bstored + "', '" + getDoc.BusinessData2 + "')\">"+ getDoc.Subject+"</a>";
									var getStr = $("[name=DocViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							}
						}
						
						if(getItem.fileList != null){
							for(var y = 0; y<getItem.fileList.length; y++){
								var fileInfo = getItem.fileList[y];
								var str = 						
									"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;' onClick=\"CombineCostApplicationListView.comCostAppListView_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
									+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
									+"<a class='previewBtn' fileid='" + fileInfo.FileID + "' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accComm.accAttachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "','comCostAppListView_','ListView',true);\"></a>";
									
									var getStr = $("[name=FileViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							}
						}
					}
				}
			},
			
			//===========
			//코드 맵 획득
			comCostAppListView_getCodeMapInfo : function(codeMap, key, getField) {
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
			comCostAppListView_makeViewHtmlForm : function(inputItem, rowNum) {
				var me = this;
				if(inputItem != null){
					var CompanyCode = me.pageExpenceAppObj.CompanyCode;

					var ProofCode = inputItem.ProofCode;
					var ViewKeyNo = inputItem.ViewKeyNo;
					var formStr = me.pageCombiAppFormList[ProofCode+"ViewFormStr"];

					var TC = nullToBlank(inputItem.TaxCode)
					var TT = nullToBlank(inputItem.TaxType)
					var PM = nullToBlank(inputItem.PayMethod)
					var PT = nullToBlank(inputItem.PayType)
					var PG = nullToBlank(inputItem.PayTarget)
					var PV = nullToBlank(inputItem.Providee)
					var BT = nullToBlank(inputItem.BillType)
					
					var TaxCodeNm = me.comCostAppListView_getCodeMapInfo(me.pageCombiAppComboData.TaxCodeMap, TC, 'CodeName')
					var TaxTypeNm = me.comCostAppListView_getCodeMapInfo(me.pageCombiAppComboData.TaxTypeMap, TT, 'CodeName')
					var PayMethodNm = me.comCostAppListView_getCodeMapInfo(me.pageCombiAppComboData.PayMethodMap, PM, 'CodeName')
					var PayTypeNm = me.comCostAppListView_getCodeMapInfo(me.pageCombiAppComboData.PayTypeMap, PT, 'CodeName')
					var PayTargetNm = me.comCostAppListView_getCodeMapInfo(me.pageCombiAppComboData.PayTargetMap, PG, 'CodeName')
					var ProvideeNm = me.comCostAppListView_getCodeMapInfo(me.pageCombiAppComboData.ProvideeMap, PV, 'CodeName')
					var BillTypeNm = me.comCostAppListView_getCodeMapInfo(me.pageCombiAppComboData.BillTypeMap, BT, 'CodeName')
					
					var DocNo = inputItem.DocNo;

					var divList = inputItem.divList;
					var divStr = "";
					var divStr2 = "";
					var appType = inputItem.ApplicationType
					for(var y = 0; y<divList.length; y++){
						var divItem = divList[y];
						
						var addUsageComment = "";
						var detailType = ""; //자기개발비, 경조사비
						if(requestType == "ENTERTAIN") {
							addUsageComment += inputItem.EntertainVendor + "<br>" 
											+ inputItem.InsideAttendantNum + "명(" + inputItem.InsideAttendantName + ") / "
											+ inputItem.OutsideAttendantNum + "명(" + inputItem.OutsideAttendantName + ")";
						} else if(requestType == "SELFDEVELOP") {
							if(divItem.StandardBriefName.indexOf("직무") > -1)  {
								detailType += accComm.getBaseCodeName("JobDevelopmentDetail", inputItem.SelfDevelopDetail, CompanyCode);
							} else {
								detailType += accComm.getBaseCodeName("SelfDevelopmentDetail", inputItem.SelfDevelopDetail, CompanyCode);
							}
						} else if(requestType == "INVEST") {
							detailType += accComm.getBaseCodeName(requestType, inputItem.InvestItem, CompanyCode)
											+ " (" + accComm.getBaseCodeName(requestType, inputItem.InvestTarget, CompanyCode) + ")";
						}
						
						var divValMap = {
								AccountName : nullToBlank(divItem.AccountName),
								StandardBriefName : nullToBlank(divItem.StandardBriefName),
								CostCenterName : nullToBlank(divItem.CostCenterName),
								IOName : nullToBlank(divItem.IOName),
								VendorName : nullToBlank(inputItem.VendorName),
								DocNo : nullToBlank(DocNo),
								UsageComment : nullToBlank(divItem.UsageComment),
								AddUsageComment : addUsageComment, //TODO: 부가적요 표시하기
								DetailType : detailType,
								DivAmount : toAmtFormat(divItem.Amount)
						}
						var htmlDivFormStr = me.pageCombiAppFormList.DivViewFormStr;
						if(ProofCode == "CorpCard"){
							htmlDivFormStr = htmlDivFormStr.replace("name=\"noBankArea\"", "name=\"noBankArea\" style=\"display:none;\"");
						}
						htmlDivFormStr = me.comCostAppListView_htmlFormSetVal(htmlDivFormStr, divValMap);
						
						if(y == 0) {
							divStr = htmlDivFormStr;
						} else {
							divStr2 += "<tr>" + htmlDivFormStr + "</tr>"; //세부증빙 여러개일 경우 처리
						}
					}

					// code to name
					inputItem.AccountBankName = accComm.getBaseCodeName("Bank", nullToBlank(inputItem.AccountBank), CompanyCode);
					
					var valMap = {
							ExpenceApplicationListID : nullToBlank(inputItem.ExpenceApplicationListID),
							
							ViewKeyNo : nullToBlank(inputItem.ViewKeyNo),
							ProofCode : nullToBlank(inputItem.ProofCode),
							
							TotalAmount : toAmtFormat(nullToBlank(inputItem.TotalAmount)),							
							RepAmount : toAmtFormat(nullToBlank(inputItem.RepAmount)),
							TaxAmount : toAmtFormat(nullToBlank(inputItem.TaxAmount)),
							SupplyCost : toAmtFormat(nullToBlank(inputItem.SupplyCost)),
							Tax : toAmtFormat(nullToBlank(inputItem.Tax)),
							
							ProofDate : nullToBlank(inputItem.ProofDateStr),
							ProofTime : nullToBlank(inputItem.ProofTimeStr),
							PostingDate : nullToBlank(inputItem.PostingDateStr),
							PayDate : nullToBlank(inputItem.PayDateStr),
							
							StoreName : nullToBlank(inputItem.StoreName).trim(),
							CardUID : nullToBlank(inputItem.CardUID),
							CardApproveNo : nullToBlank(inputItem.CardApproveNo),
							
							ReceiptID : nullToBlank(inputItem.ReceiptID),
							
							TaxInvoiceID : nullToBlank(inputItem.TaxInvoiceID),
							TaxUID : nullToBlank(inputItem.TaxUID),
							CashUID : nullToBlank(inputItem.CashUID),
							InvoicerCorpNum : nullToBlank(inputItem.InvoicerCorpNum),
							TaxNTSConfirmNum : nullToBlank(inputItem.TaxNTSConfirmNum),
							CashNTSConfirmNum : nullToBlank(inputItem.CashNTSConfirmNum),
							BankName : nullToBlank(inputItem.BankName),
							BankAccountNo : nullToBlank(inputItem.BankAccountNo),

							FranchiseCorpName : nullToBlank(inputItem.FranchiseCorpName),
							PersonalCardNo : nullToBlank(inputItem.PersonalCardNo),
							PersonalCardNoView : nullToBlank(inputItem.PersonalCardNoView),

							VendorNo : nullToBlank(inputItem.VendorNo),
							VendorName : nullToBlank(inputItem.VendorName),
							TaxCodeNm : TaxCodeNm,
							TaxTypeNm : TaxTypeNm,
							PayMethod : PayMethodNm,
							PayType : PayTypeNm,
							PayTarget : PayTargetNm,
							PaymentConditionName : nullToBlank(inputItem.PaymentConditionName),

							ProviderName : nullToBlank(inputItem.ProviderName),
							ProviderNo : nullToBlank(inputItem.ProviderNo),
							Providee : ProvideeNm,
							BillType : BillTypeNm,
							
							IsWithholdingTax : nullToBlank(inputItem.IsWithholdingTax),
							IncomTax: nullToBlank(inputItem.IncomTax),
							LocalTax: nullToBlank(inputItem.LocalTax),
							
							pageNm : "CombineCostApplicationListView",
							MobileAppClick : "comCostAppListView_MobileAppClick",
							FileID : nullToBlank(inputItem.FileID),
							
							BankInfo : nullToBlank(me.comCostAppListView_makeBankInfoStr(inputItem))
					}
					valMap.rowNum = rowNum;
					valMap.rowspan = divList.length;
					valMap.divApvArea = divStr;
					valMap.divApvArea2 = divStr2;
					
					var getForm = me.comCostAppListView_htmlFormSetVal(formStr, valMap);
					getForm = me.comCostAppListView_htmlFormDicTrans(getForm);
						
					return getForm;
				}
			},
			
			comCostAppListView_makeHtmlChkColspanApv : function(divObj) {
				if(divObj == undefined)
					return;
				
				if(Common.getBaseConfig("IsUseIO") == "N"){
					$(divObj).find("[name=noIOArea]").remove();
					$(divObj).find("[name=accArea]").attr("rowspan", "2");
				}
				if(Common.getBaseConfig("IsUseStandardBrief") == "N") {
					$(divObj).find("[name=noSBArea]").remove();
					$(divObj).find("[name=ccArea]").attr("rowspan", "2");
				}
			   	if($("#comCostAppListView_PropertyBudget").val() == "" || $("#comCostAppListView_PropertyBudget").val() == "N") {
			   		$(divObj).find("[name=noBDArea]").remove();
					$(divObj).find("[name=slipArea]").attr("rowspan", "2");
				}
			},
			

			comCostAppListView_htmlFormSetVal : function(inputStr, replaceMap){
				return accComm.accHtmlFormSetVal(inputStr, replaceMap);
			},

			comCostAppListView_htmlFormDicTrans : function(inputStr) {
				return accComm.accHtmlFormDicTrans(inputStr);
			},
			
			comCostAppListView_FileDownload : function(SavedName, FileName, FileID){
				accountFileCtrl.downloadFile(SavedName, FileName, FileID)
			},
			comCostAppListView_LinkOpen : function(ProcessId, forminstanceID, bstored, expAppID){
				accComm.accLinkOpen(ProcessId, forminstanceID, bstored, expAppID);
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
			//지급정보 세부조회
			combiCostApp_onDivDetailClick  : function(ExpListID){
				var me = this;
				accComm.accCombineCostDetClick(ExpListID, me.pageOpenerIDStr, "CO", requestType);
			},
			//모바일영수증 조회
			comCostAppListView_MobileAppClick : function(FileID){
				var me = this;
				accComm.accMobileReceiptAppClick(FileID, me.pageOpenerIDStr);	
			},
			
			comCostAppListView_callEvidPreview : function() {
				var me = this;
				accComm.accCallEvidPreview(false, "comCostAppListView_", me.pageExpenceAppEvidList);
			},
			
			
			// 거래처비용정산 : 은행계좌 정보 추가표시.
			comCostAppListView_makeBankInfoStr : function(item) {
				var BankInfo = ""; // 신한 123-22222-65214 홍길동
				if(item.AccountBankName && item.AccountBankName != ""){
					BankInfo += item.AccountBankName;
				}else if(item.BankName && item.BankName != ""){
					BankInfo += item.BankName;
				}
				if(item.AccountInfo){
					BankInfo += "<br>" + item.AccountInfo;
				}
				if(item.AccountHolder){
					BankInfo += "<br>" + item.AccountHolder; //예금주
				}
				return BankInfo;
			},
	}
	window.CombineCostApplicationListView = CombineCostApplicationListView;
	CombineCostApplicationListView.pageInit();
})(window);	
</script>
