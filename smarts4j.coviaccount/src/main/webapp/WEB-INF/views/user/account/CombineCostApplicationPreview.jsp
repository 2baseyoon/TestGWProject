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
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationPreview.comCostAppPreview_callEvidPreview()" name="comCostAppPreview_previewBtn">
				<spring:message code="Cache.ACC_btn_EvidPreview"/>
			</a>
		</div>
	</div>
	<div class="layer_divpop ui-draggable docPopLayer"  style="width:auto;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="rowTypeWrap formWrap tsize">
					<!-- 컨텐츠 시작 -->
					<div id="comCostAppPreview_contView">
						<div class="allMakeView">
							<div class="inpStyle01 allMakeTitle" style="display:none">
								<input type="hidden" class="inpStyle01" id="comCostAppPreview_PropertyBudget" tag="Budget">
							</div>
							<div class="taw_top">
								<p class="taw_top_title" name="ExpAppViewField" tag="ApplicationTitle">
								</p>
							</div>
						</div>
						<p class="eaccounting_name">		<!-- 신청자 -->
							<strong><spring:message code="Cache.ACC_lbl_applicator"/> :</strong> 
							<label id="comCostAppPreview_lblApplicator" name="ExpAppViewField" tag="RegisterName"></label>
						</p>
						<div class="inStyleSetting">	
							<div class="total_acooungting_wrap" id="comCostAppPreview_TotalWrap">
								<table class="total_acooungting_wrap_table">
									<tbody>
										<tr>
											<td class="acc_total_l">
												<table class="total_table_list">
													<tbody>
														<tr><td id="comCostAppPreview_EvidAmtArea"></td></tr>
														<tr><td id="comCostAppPreview_SBAmtArea"></td></tr>
														<tr style="display: none;"><td id="comCostAppPreview_AuditCntArea"></td></tr>
													</tbody>
												</table>
											</td>
											<td class="acc_total_r">
												<table class="total_table">
													<thead>
														<tr>
															<!-- 증빙총액 -->
															<th><spring:message code='Cache.ACC_lbl_eviTotalAmt'/><span id="comCostAppPreview_lblTotalCnt"></th>
															<!-- 청구금액 -->
															<th><spring:message code='Cache.ACC_billReqAmt'/></th>
														</tr>
													</thead>
													<tbody>
														<tr>
															<td><span class="tx_ta" name="comCostAppPreview_lblTotalAmt">0</span><spring:message code='Cache.ACC_krw'/></td>
															<td><span class="tx_ta" name="comCostAppPreview_lblBillReqAmt">0</span><spring:message code='Cache.ACC_krw'/></td>
														</tr>
													</tbody>
												</table>
											</td>
										</tr>
									</tbody>
								</table>
							</div>
							<div class="TaccWrap" style="height: 600px;">
								<div class="total_acooungting_write">
									<div class="total_acooungting_write_status" name="comCostAppPreview_evidListArea"></div>
								</div>
							</div>
						</div>
					</div>
					<!-- 컨텐츠 끝 -->
					<div class="e_formR" style="display: none; padding-left: 45px;" id="comCostAppPreview_evidPreview">
						<div class="e_formIarea">
							<div class="e_formRTitle">
								<span class="e_TitleText"></span>
								<span class="e_TitleBtn">
									<span class="pagecount"><span class="countB" id="comCostAppPreview_previewCurrentPage"></span>/<span id="comCostAppPreview_previewTotalPage"></span></span>
									<span class="pagingType01"><a onclick="accComm.accClickPaging(this);" class="pre"></a><a onclick="accComm.accClickPaging(this);" class="next"></a></span>
								</span>
							</div>
							<div class="e_formRCont" id="comCostAppPreview_evidContent" style="height: 670px;">
								<div class="billW" style="display: none; padding-top: 100px;"></div>
								<div class="invoice_wrap" style="width:910px; display: none;"></div>
								<input type="hidden" id="comCostAppPreview_hidReceiptID" value="">			
							</div>
							<div class="wordView" id="comCostAppPreview_fileContent" style="height: 670px;">
								<iframe id="comCostAppPreview_iframePreview" name="IframePreview" frameborder="0" width="100%" height="800px" scrolling="no" title=""></iframe>
								<input type="hidden" id="comCostAppPreview_previewVal" value="">						
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<!-- 전자결재 연동용 iframe -->
	<iframe id="goFormLink" src="" style="display: none;" title=""></iframe>
</body>
<script>
//증빙 조회 전용
if (!window.CombineCostApplicationPreview) {
	window.CombineCostApplicationPreview = {};
}

(function(window) {
	var CombineCostApplicationPreview = {
			
			pageOpenerIDStr : "openerID=CombineCostApplicationPreview&",
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
				
				setPropertySearchType('Budget','comCostAppPreview_PropertyBudget'); //예산관리 사용여부
				$("[name=comCostAppPreview_evidListArea]").html("");
				me.comCostAppPreview_FormInit();
				
				var parentID = "<%=request.getParameter("parentID") %>"
				if(parentID.indexOf("CombineCostApplication") > -1) {
					me.pageExpenceAppObj = parent[parentID].pageExpenceAppObj;
				} else {
					me.pageExpenceAppObj = parent[parentID].pageExpenceAppData; 
				}
				me.comCostAppPreview_comboDataInit();
				
				if(!$.isEmptyObject(me.pageExpenceAppObj)) {
					me.comCostAppPreview_searchPageData();
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
				if($("#comCostAppPreview_PropertyBudget").val() == "" || $("#comCostAppPreview_PropertyBudget").val() == "N") {
					$("[name=noBDArea]").remove();
					$("[name=colIOSBArea]").attr("colspan", Number($("[name=colIOSBArea]").attr("colspan")) - 1);
					$("[name=FileViewArea]").attr("colspan", Number($("[name=FileViewArea]").attr("colspan")) - 1);
				}
			},
			
			//콤보 데이터 조회
			comCostAppPreview_comboDataInit : function() {
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
							
							me.comCostAppPreview_makeCodeMap(me.pageCombiAppComboData.TaxTypeList, "TaxType", "Code", "CodeName");
							me.comCostAppPreview_makeCodeMap(me.pageCombiAppComboData.PayMethodList, "PayMethod", "Code", "CodeName");
							me.comCostAppPreview_makeCodeMap(me.pageCombiAppComboData.PayTypeList, "PayType", "Code", "CodeName");
							me.comCostAppPreview_makeCodeMap(me.pageCombiAppComboData.PayTargetList, "PayTarget", "Code", "CodeName");
							me.comCostAppPreview_makeCodeMap(me.pageCombiAppComboData.WHTaxList, "WHTax", "Code", "CodeName", true, true, false, false, true);
							me.comCostAppPreview_makeCodeMap(me.pageCombiAppComboData.ProvideeList, "Providee", "Code", "CodeName");
							me.comCostAppPreview_makeCodeMap(me.pageCombiAppComboData.BillTypeList, "BillType", "Code", "CodeName");
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
							me.comCostAppPreview_makeCodeMap(me.pageCombiAppComboData.TaxCodeList, "TaxCode", "Code", "CodeName");
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
			comCostAppPreview_makeCodeMap : function(List, name, dataField, labelField) {
				var me = this;
				for(var i = 0; i<List.length; i++){
					var item = List[i];
					
					//var evalStr = me.CODEMAPSTR+name+"Map[item[dataField]] = item";
					//eval(evalStr);
					me.pageCombiAppComboData[name+"Map"][item[dataField]] = item;
				}
			},
			
			//html폼 로드
			comCostAppPreview_FormInit : function() {
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
			comCostAppPreview_searchPageData : function() {
				var me = this;
				
				me.pageExpenceAppEvidList = me.pageExpenceAppObj.pageExpenceAppEvidList;

			   	for(var i=0;i<me.pageExpenceAppEvidList.length; i++){
			   		var item = me.pageExpenceAppEvidList[i];
					me.maxViewKeyNo++;
					item.ViewKeyNo = me.maxViewKeyNo;
			   	}

				fieldList =  $("[name=ExpAppViewField]");
			   	for(var i=0;i<fieldList.length; i++){
			   		var field = fieldList[i];
			   		var tag = field.getAttribute("tag")
			   		field.innerHTML = nullToBlank(me.pageExpenceAppObj[tag]);
			   	}
			   	
				me.comCostAppPreview_makeHtmlViewFormAll();
				me.comCostAppPreview_pageAmtSet();
			},

			//조회 폼 생성
			comCostAppPreview_makeHtmlViewFormAll : function(){
				var me = this;
				var proofCode = "";
				var tableStr = ""; 
				
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];
					
					var htmlStr = me.comCostAppPreview_makeViewHtmlForm(getItem, i+1);
					
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
					
				$("[name=comCostAppPreview_evidListArea]").html(tableStr);

				proofCode = "";
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];
					
					if(proofCode != getItem.ProofCode) {
						proofCode = getItem.ProofCode;
					} else {
						$("tr[name=headerArea][viewkeyno="+getItem.ViewKeyNo+"]").remove();
					}
					
					me.combiCostAppPreview_makeHtmlChkColspanApv($("[name=evidItemAreaApv][viewkeyno="+getItem.ViewKeyNo+"]"));

					if(isEmptyStr(getItem.TaxInvoiceID) && getItem.ProofCode=="TaxBill"){
						$("[name=noTaxIFView][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").remove();
					}
					
					if(getItem.docList != null){
						for(var y = 0; y<getItem.docList.length; y++){
							var getDoc = getItem.docList[y];
							var str = 						
								"<a href='javascript:void(0);' class='btn_File ico_doc' style='margin-right: 10px;' onClick=\"CombineCostApplicationPreview.combiCostAppPreview_LinkOpen('" + getDoc.ProcessID + "', '" + getDoc.forminstanceID + "', '" + getDoc.bstored + "', '" + getDoc.BusinessData2 + "')\">"+ getDoc.Subject+"</a>";
								var getStr = $("[name=DocViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
						}
					}
					
					if(getItem.fileList != null){
						for(var y = 0; y<getItem.fileList.length; y++){
							var fileInfo = getItem.fileList[y];
							var str = 						
								"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;' onClick=\"CombineCostApplicationPreview.combiCostAppPreview_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
								+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
								+"<a class='previewBtn' fileid='" + fileInfo.FileID + "' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accComm.accAttachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "','comCostAppPreview_','Preview',true);\"></a>";
								
								var getStr = $("[name=FileViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
						}
					}
				}
			},
			
			//===========
			//코드 맵 획득
			comCostAppPreview_getCodeMapInfo : function(codeMap, key, getField) {
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
			comCostAppPreview_makeViewHtmlForm : function(inputItem, rowNum) {
				var me = this;
				if(inputItem != null){

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
					
					var TaxCodeNm = me.comCostAppPreview_getCodeMapInfo(me.pageCombiAppComboData.TaxCodeMap, TC, 'CodeName')
					var TaxTypeNm = me.comCostAppPreview_getCodeMapInfo(me.pageCombiAppComboData.TaxTypeMap, TT, 'CodeName')
					var PayMethodNm = me.comCostAppPreview_getCodeMapInfo(me.pageCombiAppComboData.PayMethodMap, PM, 'CodeName')
					var PayTypeNm = me.comCostAppPreview_getCodeMapInfo(me.pageCombiAppComboData.PayTypeMap, PT, 'CodeName')
					var PayTargetNm = me.comCostAppPreview_getCodeMapInfo(me.pageCombiAppComboData.PayTargetMap, PG, 'CodeName')
					var ProvideeNm = me.comCostAppPreview_getCodeMapInfo(me.pageCombiAppComboData.ProvideeMap, PV, 'CodeName')
					var BillTypeNm = me.comCostAppPreview_getCodeMapInfo(me.pageCombiAppComboData.BillTypeMap, BT, 'CodeName')
					
					var DocNo = inputItem.DocNo;

					var divList = inputItem.divList;
					var divStr = "";
					var divStr2 = "";
					var appType = inputItem.ApplicationType;
					
					var addUsageComment = "";
					if(ProofCode == "CashBill") {
						addUsageComment = PayMethodNm;
					}
					
					if(divList != undefined) {
						for(var y = 0; y<divList.length; y++){
							var divItem = divList[y];
		
							var divValMap = {
									AccountName : nullToBlank(divItem.AccountName),
									StandardBriefName : nullToBlank(divItem.StandardBriefName),
									CostCenterName : nullToBlank(divItem.CostCenterName),
									IOName : nullToBlank(divItem.IOName),
									VendorName : nullToBlank(inputItem.VendorName),
									DocNo : nullToBlank(DocNo),
									UsageComment : nullToBlank(divItem.UsageComment),
									AddUsageComment : addUsageComment, //TODO: 부가적요 표시하기
									DivAmount : toAmtFormat(divItem.Amount)
							}
							var htmlDivFormStr = me.pageCombiAppFormList.DivViewFormStr;
							if(ProofCode == "TaxBill") { 
								htmlDivFormStr = me.pageCombiAppFormList.TaxBillDivViewFormStr;
							}
							htmlDivFormStr = me.comCostAppPreview_htmlFormSetVal(htmlDivFormStr, divValMap);
							
							if(ProofCode == "TaxBill") {
								divStr += "<tr>" + htmlDivFormStr + "</tr>";
							}  else {
								if(y == 0) {
									divStr = htmlDivFormStr;
								} else {
									divStr2 += "<tr>" + htmlDivFormStr + "</tr>"; //세부증빙 여러개일 경우 처리
								}
							}
						}
					} else {
						var divValMap = {
								AccountName : nullToBlank(inputItem.AccountName),
								StandardBriefName : nullToBlank(inputItem.StandardBriefName),
								CostCenterName : nullToBlank(inputItem.CostCenterName),
								IOName : nullToBlank(inputItem.IOName),
								VendorName : nullToBlank(inputItem.VendorName),
								DocNo : nullToBlank(DocNo),
								UsageComment : nullToBlank(inputItem.UsageComment),
								AddUsageComment : addUsageComment, //TODO: 부가적요 표시하기
								DivAmount : toAmtFormat(inputItem.Amount)
						}
						var htmlDivFormStr = me.pageCombiAppFormList.DivViewFormStr;
						htmlDivFormStr = me.comCostAppPreview_htmlFormSetVal(htmlDivFormStr, divValMap);
						divStr = htmlDivFormStr;
					}

					var valMap = {
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
							
							pageNm : "CombineCostApplicationPreview",
							MobileAppClick : "comCostAppPreview_MobileAppClick",
							FileID : nullToBlank(inputItem.FileID),
					}
					valMap.rowNum = rowNum;
					valMap.rowspan = (divList == undefined ? 1 : ProofCode == "TaxBill" ? divList.length+1 : divList.length);
					valMap.divApvArea = divStr;
					valMap.divApvArea2 = divStr2;
					
					var getForm = me.comCostAppPreview_htmlFormSetVal(formStr, valMap);
					getForm = me.comCostAppPreview_htmlFormDicTrans(getForm);
						
					return getForm;
				}
			},
			
			combiCostAppPreview_makeHtmlChkColspanApv : function(divObj) {
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
			   	if($("#comCostAppPreview_PropertyBudget").val() == "" || $("#comCostAppPreview_PropertyBudget").val() == "N") {
			   		$(divObj).find("[name=noBDArea]").remove();
					$(divObj).find("[name=slipArea]").attr("rowspan", "2");
				}
			},
			
			comCostAppPreview_htmlFormSetVal : function(inputStr, replaceMap){
				return accComm.accHtmlFormSetVal(inputStr, replaceMap);
			},

			comCostAppPreview_htmlFormDicTrans : function(inputStr) {
				return accComm.accHtmlFormDicTrans(inputStr);
			},

			//금액 정보 세팅
			comCostAppPreview_pageAmtSet : function() {
				var me = this;
				
				accComm.accPageAmtSet(me.pageExpenceAppEvidList, "comCostAppPreview_");
			},
			
			
			combiCostAppPreview_FileDownload : function(SavedName, FileName, FileID){
				accountFileCtrl.downloadFile(SavedName, FileName, FileID)
			},
			combiCostAppPreview_LinkOpen : function(ProcessId, forminstanceID, bstored, expAppID){
				accComm.accLinkOpen(ProcessId, forminstanceID, bstored, expAppID);
			},

			combiCostApp_onCardAppClick  : function(ReceiptID){
				var me = this;
				accComm.accCardAppClick(ReceiptID, me.pageOpenerIDStr);				
			},
			combiCostApp_onTaxBillAppClick  : function(TaxInvoiceID){
				var me = this;
				accComm.accTaxBillAppClick(TaxInvoiceID, me.pageOpenerIDStr);
			},
			comCostAppPreview_MobileAppClick : function(FileID){
				var me = this;
				accComm.accMobileReceiptAppClick(FileID, me.pageOpenerIDStr);
			},
			
			comCostAppPreview_callEvidPreview : function() {
				var me = this;
				
				accComm.accCallEvidPreview(false, "comCostAppPreview_", me.pageExpenceAppEvidList);
			}

	}
	window.CombineCostApplicationPreview = CombineCostApplicationPreview;
	CombineCostApplicationPreview.pageInit();
})(window);
	
</script>
