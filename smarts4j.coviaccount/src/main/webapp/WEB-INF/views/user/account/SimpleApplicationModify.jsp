<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'>
	<meta http-equiv='expires' content='0'>
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<style>
	.pad10 {
		padding: 10px;
	}
	.card_nea_right_list[name=simpleApplicationModify_AddListArea] li .cnrl_bot dl dd .searchBox02 .btnSearchType01 { right:0; background-position-x:8px !important; }
	.card_nea_right_list[name=simpleApplicationModify_AddListArea] li .cnrl_mid dl[name=CtrlArea] dd .searchBox02 .btnSearchType01 { right:0; background-position:8px -28px; background-size:auto 120px; }
	.card_nea_right_list[name=simpleApplicationModify_AddListArea] li .cnrl_mid dl.cnrl_mid_ta dd textarea { width:100% !important; height:40px; padding:2px 5px; text-indent:0; }
	.card_nea_right_list[name=simpleApplicationModify_AddListArea] li .card_nea_right_info .card_nea_right_info_p1 { margin:0 10px 0 0 !important; vertical-align:middle; }
	.card_nea_right_list[name=simpleApplicationModify_AddListArea] li .card_nea_right_info .tx_date .dateSel.type02 .icnDate { margin:-3px 0 0 -29px !important; }
	.card_nea_right_list[name=simpleApplicationModify_AddListArea] li .cnrl_bot .cnrl_bot_dl[name=DivAddArea] dt { display:none; }
	.card_nea_right_list[name=simpleApplicationModify_AddListArea] li .cnrl_bot .cnrl_bot_dl[name=DivAddArea] dd .searchBox02 input[type=text] { text-indent:0; padding:0 6px; }
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
							<div class="card_ea_right_cont">
								<ul class="card_nea_right_list" name="simpleApplicationModify_AddListArea">
								</ul>
							</div>
							<div style="margin-top: 10px; text-align: center;">
								<a href="#" class="btnTypeDefault btnTypeChk" onclick="SimpleApplicationModify.saveList();">
									<spring:message code="Cache.ACC_btn_save" />
								</a>
								<a href="#" class="btnTypeDefault" onclick="window.close(); ">
									<spring:message code="Cache.ACC_btn_cancel" />
								</a>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>

<script>
	let SimpleApplicationModify = new Object();

	window.addEventListener("load", function () {
		let isUseIO = Common.getBaseConfig("IsUseIO");
		let isUseSB = Common.getBaseConfig("IsUseStandardBrief");
		let isUseBD = "N";
		
		SimpleApplicationModify = {
			pageInit: async function () {
				this["pageExpenceAppObj"] = opener.CombineCostApplicationView.pageExpenceAppObj;
				this["pageExpenceAppEvidList"] = opener.CombineCostApplicationView.pageExpenceAppEvidList;
				this["pageExpenceAppTarget"] = JSON.parse(JSON.stringify(accFilter(opener.CombineCostApplicationView.pageExpenceAppEvidList, "ExpenceApplicationListID", new URLSearchParams(window.location.search).get('ExpAppListID'))));
				this["pageOpenerIDStr"] = `openerID=SimpleApplication${'${this["pageExpenceAppObj"].RequestType}'}&`;
				this["pageName"] = "SimpleApplicationModify",
				this.exchangeIsUse = accComm.getExchangeIsUse(this.pageExpenceAppObj.CompanyCode, this.pageExpenceAppObj.RequestType);
				
				accComm.getFormLegacyManageInfo(this.pageExpenceAppObj.RequestType, this.pageExpenceAppObj.CompanyCode, this.pageExpenceAppObj.ExpenceApplicationID);
				
				window["SimpleApplication" + this.pageExpenceAppObj.RequestType] = SimpleApplicationModify;
				
				await this.formInit();
				await this.comboInit();
				await this.defaultInit();
				await this.makeForm();
			},
			formInit: function () {
				this["formList"] = new Object();

				var htmlPath = Common.getBaseConfig("AccountApplicationFormPath");
				var htmlList = ["SimpleApplication_InputAddForm.html", "SimpleApplication_CorpCardAddForm.html", "SimpleApplication_Div.html", "SimpleApplication_DivAdd.html"];

				for (const element of htmlList) {
					fetch(htmlPath + element + resourceVersion).then((response) => response.text()).then((html) => {
						this["formList"][element] = html;
					});
				}
			},
			comboInit: async function () {
				this["comboData"] = new Object();
				// Form의 Html 데이터 세팅을 위한 기초코드
				// 사용여부 관계없이 전체 조회
				let codeGroups = ["TaxType", "WHTax", "PayMethod", "PayType", "PayTarget", "BizTripItem", "BillType", "CompanyCode", "InvestTarget", "InvestItem"];
				await accFetch("/account/accountCommon/getBaseCodeDataAll.do", "GET", {
					codeGroups: codeGroups.join(),
					CompanyCode: this.pageExpenceAppObj.CompanyCode
				}).then((json) => {
					if (json.result == "ok") {
						let codeList = json.list;
						for (const element of codeGroups) {
							this.comboData[element + "List"] = codeList[element];
							this.makeCodeMap(this.comboData[element + "List"], element, "Code");
						}
					} else {
						Common.Error(Common.getDic("ACC_msg_error")); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
				// 사용여부에 따라 조회
				let isUseCodeGroups = ["AccountCtrl", "ExchangeNation"];
				await accFetch("/account/accountCommon/getBaseCodeDataUseAll.do", "GET", {
					isUseCodeGroups: isUseCodeGroups.join(),
					CompanyCode: this.pageExpenceAppObj.CompanyCode
				}).then((json) => {
					if (json.result == "ok") {
						let codeList = json.list;
						for (const element of isUseCodeGroups) {
							this.comboData[element + "List"] = codeList[element];
							this.makeCodeMap(this.comboData[element + "List"], element, "Code");
						}
					} else {
						Common.Error(Common.getDic("ACC_msg_error")); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
				// TaxCode의 경우 covi_account4j_si.act_proof_tax_mapp의 테이블을 조인해서 가져오기 때문에 따로 가져오기
				await accFetch("/account/expenceApplication/getTaxCodeCombo.do", "GET", { CompanyCode: this.pageExpenceAppObj.CompanyCode }).then((json) => {
					if (json.result == "ok") {
						this.comboData["TaxCodeList"] = json.list;
						this.makeCodeMap(this.comboData["TaxCodeList"], "TaxCode", "Code");
					} else {
						Common.Error(Common.getDic("ACC_msg_error")); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
				// 표준적요 Combo를 위한 목록
				await accFetch("/account/expenceApplication/getBriefCombo.do", "GET", {
					isSimp: "Y",
					StandardBriefSearchStr: accComm[this.pageExpenceAppObj.RequestType].pageExpenceFormInfo.StandardBriefSearchStr,
					CompanyCode: this.pageExpenceAppObj.CompanyCode
				}).then((json) => {
					if (json.result == "ok") {
						this.comboData["BriefList"] = json.list;
						this.makeCodeMap(this.comboData["BriefList"], "Brief", "StandardBriefID");
						for (const element of this.comboData["BriefList"]) {
							element["Code"] = element["StandardBriefID"];
							element["CodeName"] = element["StandardBriefName"];
						}
					} else {
						Common.Error(Common.getDic("ACC_msg_error")); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
				// 폼 html Combo 세팅
				this.formComboInit();
			},
			//콤보데이터 html 생성
			makeComboOption: function (cdList, codeField, nameField, Type, attr, isNotContainEmpty) {
				if (cdList == null) { return; }
				if (codeField == null) { codeField = "Code"; }
				if (nameField == null) { nameField = "CodeName" };

				let htmlStr = "<option value=''>" + "<spring:message code='Cache.ACC_lbl_choice' />" + "</option>";

				if (isNotContainEmpty == "Y")
					htmlStr = "";
				for (let i = 0; i < cdList.length; i++) {
					let getCd = cdList[i];
					if (Type == null || getCd.Reserved1 == Type) {
						if (getCd.IsUse == "Y" || getCd.IsUse == null || getCd.IsUse == "") {
							if (attr == null) {
								htmlStr = htmlStr + "<option value='" + getCd[codeField] + "'>" + getCd[nameField] + "</option>"
							} else {
								htmlStr = htmlStr + "<option value='" + getCd[codeField] + "' " + attr + "='" + JSON.stringify(getCd) + "'>" + getCd[nameField] + "</option>"
							}
						}
					}
				}
				return htmlStr;
			},
			makeCodeMap: function (list, name, dataField) { // comboData의 Map 생성
				this.comboData[name + "Map"] = new Object();
				for (const element of list) {
					this.comboData[name + "Map"][element[dataField]] = element;
				}
			},
			formComboInit: function () { // html 로드
				for (const [key1, value1] of Object.entries(this["formList"])) {
					for (const [key2, value2] of Object.entries(this["comboData"])) {
						if (key2.indexOf("List") == -1) {
							continue;
						}
						this["formList"][key1] = this["formList"][key1].replace("@@{" + key2.replace("List", "Options") + "}", this.makeComboOption(this["comboData"][key2], "Code", "CodeName"));
					}
				}
			},
			defaultInit: function () { // 기본 값 생성
				this["defaultCC"] = new Object();

				accFetch("/account/expenceApplication/getUserCC.do", "GET", new Object()).then((json) => {
					if (json.result == "ok") {
						var getData = json.CCInfo;
						if (getData != null) {
							this.defaultCC["CostCenterCode"] = getData.CostCenterCode;
							this.defaultCC["CostCenterName"] = getData.CostCenterName;
						}
					}
				});
			},
			makeForm: async function () { // body의 html 생성
				let inputItem = this.pageExpenceAppTarget;
				// inputItem이 null인 경우가 존재하는지 의문
				if (inputItem == null) { return; }
				
				let proofCode = inputItem.ProofCode;
				let keyField = this.proofKey(inputItem.ProofCode);
				let formHtml = this.formList[inputItem.ProofCode == "CorpCard" ? "SimpleApplication_CorpCardAddForm.html" : "SimpleApplication_InputAddForm.html"];
				inputItem.KeyNo = inputItem[keyField];
				
				let valMap = {
					RequestType: this.pageExpenceAppObj.RequestType,
					KeyNo: inputItem[keyField],
					ProofCode: nullToBlank(inputItem.ProofCode),
					TotalAmount: toAmtFormat(nullToBlank(inputItem.TotalAmount)),
					ProofDateStr: nullToBlank(inputItem.ProofDateStr),
					ProofTimeStr: nullToBlank(inputItem.ProofTimeStr),
					ReceiptID: nullToBlank(inputItem.ReceiptID),
					StoreName: nullToBlank(inputItem.StoreName).trim(),
					CardUID: nullToBlank(inputItem.CardUID),
					CardApproveNo: nullToBlank(inputItem.CardApproveNo),
					PersonalCardNo: inputItem.PersonalCardNo,
					PersonalCardNoView: inputItem.PersonalCardNoView,
					PhotoDateStr: nullToBlank(inputItem.PhotoDateStr),
					FullPath: nullToBlank(inputItem.FullPath),
					FileID: nullToBlank(inputItem.FileID),
					SavedName: nullToBlank(inputItem.SavedName),
					FileName: nullToBlank(inputItem.FileName),
					VendorNo: nullToBlank(inputItem.VendorNo),
					VendorName: nullToBlank(inputItem.VendorName),
					Currency : nullToBlank(inputItem.Currency),
					ExchangeRate : nullToBlank(inputItem.ExchangeRate) == "" ? 0 : parseInt(inputItem.ExchangeRate),
					LocalAmount : nullToBlank(inputItem.LocalAmount) == "" ? 0 : parseInt(inputItem.LocalAmount),
					//세부증빙 영역
					Rownum: nullToBlank(inputItem.divList[0].Rownum),
					AmountVal: toAmtFormat(nullToBlank(inputItem.divList[0].Amount)),
					UsageCommentVal: nullToBlank(inputItem.divList[0].UsageComment).replace(/<br>/gi, '\r\n'),
					AccountCode: nullToBlank(inputItem.divList[0].AccountCode),
					StandardBriefID: nullToBlank(inputItem.divList[0].StandardBriefID),
					CostCenterCode: nullToBlank(inputItem.divList[0].CostCenterCode),
					CostCenterName: nullToBlank(inputItem.divList[0].CostCenterName)
				};
				
				valMap.DivInputArea = accComm.accHtmlFormSetVal(this.formList["SimpleApplication_Div.html"], valMap);
				document.querySelector("[name=simpleApplicationModify_AddListArea]").innerHTML = accComm.accHtmlFormDicTrans(accComm.accHtmlFormSetVal(formHtml, valMap));
				
				// 날짜 필드 생성
				this.makeDate(inputItem);
				// 표준적요 값 세팅
				await this.briefValSet(valMap.ProofCode, valMap.KeyNo, valMap.Rownum, inputItem.StandardBriefID);
				
				// 환종 환율 세팅
				if(this.exchangeIsUse == "Y" && valMap.ProofCode == "EtcEvid") {
					//입력 필드 show
					accountCtrl.getInfoStr(`span[name=EtcEvidField][proofcd="${'${valMap.ProofCode}'}"][keyno="${'${valMap.KeyNo}'}"]`).show();
					
					//환종 KRW 기본값 세팅
					//var CUField = accountCtrl.getInfoStr("[name=CurrencySelectField][proofcd="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"]");
					var CUField = document.querySelector(`[name=CurrencySelectField][proofcd="${'${valMap.ProofCode}'}"][keyno="${'${valMap.KeyNo}'}"]`);
					if (valMap.Currency == "") valMap.Currency = "KRW";
					CUField.value = valMap.Currency;
					this.setListVal(valMap.ProofCode, "Currency", valMap.KeyNo, valMap.Currency);
					
					// 값 세팅 시 (임시저장, 상신) change 이벤트로 인하여 덮어씌워지지 않도록 처리
					if (CUField.value != "KRW") {
						if (CUField.value == valMap.Currency) {
							accountCtrl.getInfoStr(`span[name=ExRateArea][proofcd="${'${valMap.ProofCode}'}"][keyno="${'${valMap.KeyNo}'}"]`).show();
						}
					}
				} else {
					accountCtrl.getInfoStr(`span[name=EtcEvidField][proofcd="${'${valMap.ProofCode}'}"][keyno="${'${valMap.KeyNo}'}"]`).hide();
				}
				
				// 법인카드/모바일영수증만 ReceiptField show
				if (valMap.ProofCode == "Receipt") {
					document.querySelector(`p[name=ReceiptField][proofcd="${'${valMap.ProofCode}'}"][keyno="${'${valMap.KeyNo}'}"]`).style.display = "";
				} else {
					if(valMap.ProofCode != "CorpCard") { // 법인카드의 경우 다른 html 파일 사용으로  ReceiptField가 존재 X
						document.querySelector(`p[name=ReceiptField][proofcd="${'${valMap.ProofCode}'}"][keyno="${'${valMap.KeyNo}'}"]`).style.display = "none";	
					}
				}
				
				// 세부증빙이 2개인 경우
				if (inputItem.divList != undefined && inputItem.divList.length > 1) {
					this.makeInputDivHtml(inputItem);
				}
				
				let item = inputItem;
				
				if (this.tempVal == null) {
					this.tempVal = new Object();
				}
				this.tempVal.ProofCode = item.ProofCode;
				this.tempVal.KeyNo = item.KeyNo;
				
				if(item.docList != null){
					this.linkComp(item.docList, true);	
				}
				
				item.fileMaxNo = 0;
				let setFileList = null;
				
				if (item.uploadFileList != null){
					setFileList = [].concat(item.uploadFileList);
				} else if (item.fileList != null) {
					setFileList = [].concat(item.fileList);
				}
				
				if (setFileList != null) {
					for (let y = 0; y<setFileList.length; y++){
						let fileItem = setFileList[y];
						item.fileMaxNo++;
						fileItem.fileNum = item.fileMaxNo;
					}
					
					this.uploadHTML(setFileList, item.KeyNo, item.ProofCode, false);
				}
				
				if(this.pageExpenceAppObj.RequestType == "INVEST") {	
					//$("[name=TotalAmountField]").attr("disabled", "disabled");
					//$("[name=AmountField]").attr("disabled", "disabled");
					
					let SBField = $("[name=BriefSelectField][proofcd=EtcEvid][keyno="+item.ExpAppEtcID+"]");
					SBField.attr("disabled", "disabled");
					SBField.siblings("button").remove();
					SBField.parents("div.searchBox02").removeClass("searchBox02");
				}	
				
				if(this.isModified) {
					// 수정 버튼 클릭 후 입력 값 바인딩 중 trigger를 통해 select box를 시스템에서 onchange할 때 
					// 기존 사용자가 입력했던 금액값들이 날라가는 현상 때문에 isModified일 경우 금액 자동 수정을 막아놓음
					// 하지만 그 후 사용자가 직접 select box 값을 바꿀 경우 정상 작동이 필요하므로 isModified를 false로 변경 
					this.isModified = false;
				}
			},
			proofKey: function (proofCode) { // 증빙별 고유 키
				let keyMap = {
					CorpCard: "CardUID",
					TaxBill: "TaxUID",
					CashBill: "CashUID",
					PrivateCard: "ExpAppPrivID",
					EtcEvid: "ExpAppEtcID",
					Receipt: "ReceiptID"
				};
				return keyMap[proofCode];
			},
			makeDate: function (getItem) {
				let dateList = document.querySelectorAll(`[name="SimpAppDateField"][proofcd="${'${getItem.ProofCode}'}"]`);

				for (const element of dateList) {
					let dataField = element.getAttribute("datafield");
					let areaID = element.id;
					let pd = getItem[dataField];

					makeDatepicker(areaID, areaID + "_Date", null, pd, null, 100);
				}
			},
			briefValSet: async function (ProofCode, KeyNo, Rownum, StandardBriefID) {
				let getItem = this.pageExpenceAppTarget;
				let getMap = this.comboData.BriefMap[StandardBriefID];
				if (getMap == null) {
					getMap = {};
				}

				for (let i = 0; i < getItem.divList.length; i++) {
					let divItem = getItem.divList[i];

					if(divItem.Rownum != Rownum) { continue; }

					getItem["StandardBriefID"] = nullToBlank(StandardBriefID);
					getItem["StandardBriefName"] = nullToBlank(getMap.StandardBriefName);
					getItem['TaxType'] = nullToBlank(getMap.TaxType);
					getItem['TaxCode'] = nullToBlank(getMap.TaxCode);
					getItem['AccountCode'] = nullToBlank(getMap.AccountCode);
					getItem['AccountName'] = nullToBlank(getMap.AccountName);
					getItem['StandardBriefDesc'] = nullToBlank(getMap.StandardBriefDesc);
					
					document.querySelector(`[name="BriefDecField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).innerHTML = nullToBlank(getMap.StandardBriefDesc);
					if(nullToBlank(getMap.StandardBriefDesc) != '') {
						document.querySelector(`[name="BriefDecField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).style.display = "";
					} else {
						document.querySelector(`[name="BriefDecField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).style.display = "none";
					}

					await accountCtrl._setCtrlField(this, nullToBlank(getMap.CtrlCode), KeyNo, Rownum, ProofCode, divItem);
					accountCtrl._onSaveJson(this, null, "CtrlArea", ProofCode, KeyNo, Rownum);
					
					let me = this;
					let BizTripItemItem = this.comboData.BizTripItemList.filter(function(o) {
						let Items = o.Reserved1;
						if (isEmptyStr(Items)) { return; }
						if (me.pageExpenceAppObj.RequestType == "OVERSEA" && (o.Code=='Toll'||o.Code=='Fuel'||o.Code=='Park')) { return; }
						return $.inArray(StandardBriefID.toString(), Items.split(",")) > -1;
					});

					//출장항목 선택가능항목 변경
					if(!jQuery.isEmptyObject(BizTripItemItem) && BizTripItemItem.length > 0){
						htmlStr = this.makeComboOption(BizTripItemItem, "Code", "CodeName", null, null, "Y");
						
						//D01 : 출장항목
						var D01Val = accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val();
						var D01Item = accFilter(BizTripItemItem, 'Code', D01Val);
						accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(htmlStr);
						if(jQuery.isEmptyObject(D01Item))
							D01Val = accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"] option:first").val()
						
						accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(D01Val).prop("selected", true);
						accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").trigger("onchange");
					}

					divItem["StandardBriefID"] = StandardBriefID;
					divItem["StandardBriefName"] = nullToBlank(getMap.StandardBriefName);
					divItem['TaxType'] = nullToBlank(getMap.TaxType);
					divItem['TaxCode'] = nullToBlank(getMap.TaxCode);
					divItem['AccountCode'] = nullToBlank(getMap.AccountCode);
					divItem['AccountName'] = nullToBlank(getMap.AccountName);
					divItem['StandardBriefDesc'] = nullToBlank(getMap.StandardBriefDesc);
					
					// 표준적요 데이터 세팅
					document.querySelector(`[name="BriefSelectField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).value = StandardBriefID;
					document.querySelector(`[name="DivAccCd"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).value = getMap.AccountCode;
					document.querySelector(`[name="DivAccNm"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).value = getMap.AccountName;
					
					this.setDivVal(ProofCode, KeyNo, Rownum, "AccountCode", getMap.AccountCode);
					this.setDivVal(ProofCode, KeyNo, Rownum, "AccountName", getMap.AccountName);
					this.setDivVal(ProofCode, KeyNo, Rownum, "StandardBriefID", StandardBriefID);
					this.setDivVal(ProofCode, KeyNo, Rownum, "StandardBriefName", getMap.StandardBriefName);
				}
			},
			setDivVal: function(ProofCode, KeyNo, Rownum, fieldNm, val) {
				let getItem = this.pageExpenceAppTarget;
				if (!isEmptyStr(getItem.KeyNo)){
					var divItem = accFilter(getItem.divList, "Rownum", Rownum);
					divItem[fieldNm] = val;
					if(fieldNm == "Amount") {
						getItem.Amount = val;
						getItem.divSum = 0;
						for(let i = 0; i < getItem.divList.length; i++) {
							getItem.divSum += Number(AmttoNumFormat(getItem.divList[i].Amount));
						}
					}
				}
			},
			setDivSBVal: function(info) {
				let proofCode = this.tempVal.ProofCode;
				let keyNo = this.tempVal.KeyNo;
				let rownum = this.tempVal.Rownum;
				delete this.tempVal;
				
				this.briefValSet(proofCode, keyNo, rownum, info.StandardBriefID);
			},
			simpApp_CallBriefPopup: function(ProofCode, KeyNo, Rownum) {
				let popupID			= "standardBriefSearchPopup";
				let popupTit		= "<spring:message code='Cache.ACC_standardBrief'/>";
				let popupName		= "StandardBriefSearchPopup";
				let callBack		= "setDivSBVal";
				let sbSearchStr 	= Base64.utf8_to_b64(accComm[this.pageExpenceAppObj.RequestType].pageExpenceFormInfo.StandardBriefSearchStr);
				let openerID 		= "SimpleApplication" + this.pageExpenceAppObj.RequestType;
				let includeAccount 	= "N";
				let companyCode 	= this.pageExpenceAppObj.CompanyCode;
				let windowPopupYN 	= "Y";
				let popupUrl 		= "/account/accountCommon/accountCommonPopup.do?"
									+ "popupID="				+ popupID		 + "&"
									+ "popupName="				+ popupName		 + "&"
									+ "callBackFunc="			+ callBack 		 + "&"
									+ "StandardBriefSearchStr="	+ sbSearchStr	 + "&"
									+ "openerID="				+ openerID		 + "&" 
									+ "includeAccount="			+ includeAccount + "&"
									+ "windowPopupYN="			+ windowPopupYN	 + "&"
									+ "companyCode="			+ companyCode
				
				this.tempVal = {
					ProofCode: 	ProofCode,
					KeyNo: 		KeyNo,
					Rownum: 	Rownum
				};
				
				CFN_OpenWindow(popupUrl, popupTit, 1000, 770, "both");
			}, 
			simpApp_onCCSearch: function(ProofCode, KeyNo, Rownum) {
				let popupID			= "ccSearchPopup";
				let popupTit		= "<spring:message code='Cache.ACC_lbl_costCenter'/>";
				let popupName		= "CostCenterSearchPopup";
				let callBack		= "setDivCCVal"; 
				let openerID		= "SimpleApplication" + this.pageExpenceAppObj.RequestType;
				let includeAccount	= "N";
				let companyCode		= this.pageExpenceAppObj.CompanyCode;
				let popupType 		= isUseIO == "Y" ? "CC" : "";
				let popupUrl		= "/account/accountCommon/accountCommonPopup.do?"
									+ "popupID="		+ popupID			+ "&"
									+ "popupName="		+ popupName			+ "&"
									+ "openerID="		+ openerID			+ "&" 
									+ "includeAccount="	+ includeAccount 	+ "&"
									+ "companyCode="	+ companyCode 		+ "&"
									+ "popupType="		+ popupType			+ "&"
									+ "callBackFunc="	+ callBack;
				
				this.tempVal = {
					ProofCode: 	ProofCode,
					KeyNo: 		KeyNo,
					Rownum: 	Rownum
				};
				
				Common.open("", popupID, popupTit, popupUrl, "600px", "730px", "iframe", true, null, null, true);
			},
			setDivCCVal: function(info) {
				let proofCode = this.tempVal.ProofCode;
				let keyNo = this.tempVal.KeyNo;
				let rownum = this.tempVal.Rownum;
				let idx = accFindIdx(this.pageExpenceAppTarget.divList, "Rownum", rownum);
				let elementName = {
					CodeField : idx > 0 ? "DivCCCd" : "CostCenterCode",
					NameField : idx > 0 ? "DivCCNm" : "CostCenterName"
				};
				delete this.tempVal;
				
				this.setDivVal(proofCode, keyNo, rownum, "CostCenterCode", info.CostCenterCode);
				this.setDivVal(proofCode, keyNo, rownum, "CostCenterName", info.CostCenterName);
				
				document.querySelector(`[name="${'${elementName.CodeField}'}"][proofcd="${'${proofCode}'}"][keyno="${'${keyNo}'}"][rownum="${'${rownum}'}"]`).value = info.CostCenterCode;
				document.querySelector(`[name="${'${elementName.NameField}'}"][proofcd="${'${proofCode}'}"][keyno="${'${keyNo}'}"][rownum="${'${rownum}'}"]`).value = info.CostCenterName;
			},
			simpApp_divAddOne: function(ProofCode, KeyNo) {
				let item = this.pageExpenceAppTarget;
				let usageComment = document.querySelector(`[name=UsageCommentField][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).value;
				
				if (item.divList == null) { item.divList = []; }
				
				let divItem = {
					ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID),
					ExpenceApplicationDivID : "",
					ViewKeyNo : item.ViewKeyNo,
					KeyNo : item.KeyNo,
					ProofCode : item.ProofCode,
					AccountCode :  "",
					AccountName : "",
					StandardBriefID :  "",
					StandardBriefName : "",
					CostCenterCode :  nullToBlank(this.defaultCC["CostCenterCode"]),
					CostCenterName :  nullToBlank(this.defaultCC["CostCenterName"]),
					IOCode : "",
					IOName : "",
					Amount : 0,
					UsageComment : usageComment,
					IsNew : true
				}
				
				let maxRN = ckNaN(item.maxRowNum);
				maxRN++;
				item.maxRowNum = maxRN;
				divItem.Rownum = maxRN;
				
				item.divList.push(divItem);
				this.makeInputDivHtml(divItem, null, true);
			},
			makeInputDivHtml: function(inputItem, isAll, isOne) {
				let me = this;
				let proofCode = inputItem.ProofCode;
				let keyField = me.proofKey(inputItem.ProofCode);
				let divList = inputItem.divList;
				let divAddArea = document.querySelector(`[name=DivAddArea][proofcd="${'${proofCode}'}"][keyno="${'${me.pageExpenceAppTarget[keyField]}'}"]`);
				let formStr = me.formList["SimpleApplication_DivAdd.html"];
				
				if (isAll) {
					divAddArea.innerHTML = "";
				}
				if (isOne) { //세부증빙 1건 신규 추가 시 inputItem 파라미터에 divItem을 넘겨줌
					divList = [];
					divList.push(inputItem);
				}
				
				divList.forEach(function(divItem, index) {
					let amtVal = divItem.Amount;
					
					if (!(index > 0 || isOne)) { return; }
					if (amtVal == null || amtVal == "") {
						amtVal = inputItem.ProofCode == "TaxBill" ? divItem.RepAmount : divItem.TotalAmount;
					}
					
					let valMap = {
						RequestType : me.pageExpenceAppObj.RequestType,
						ExpenceApplicationListID : nullToBlank(inputItem.ExpenceApplicationListID),
						ViewKeyNo : nullToBlank(inputItem.ViewKeyNo),
						KeyNo : me.pageExpenceAppTarget[keyField],
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
					
					if(divItem.ReservedStr2_Div != undefined && Object.keys(divItem.ReservedStr2_Div).length != 0)
						valMap.ReservedStr2_Div = Object.assign({}, divItem.ReservedStr2_Div);
					if(divItem.ReservedStr3_Div != undefined && Object.keys(divItem.ReservedStr3_Div).length != 0)
						valMap.ReservedStr3_Div = Object.assign({}, divItem.ReservedStr3_Div);
					
					let divHtml = document.createElement('div');
					divHtml.innerHTML = accComm.accHtmlFormDicTrans(accComm.accHtmlFormSetVal(formStr, valMap));
					divAddArea.appendChild(divHtml);
					
					me.briefValSet(valMap.ProofCode, valMap.KeyNo, valMap.Rownum, valMap.StandardBriefID);

			    	//관리항목 popup 처리
				    if(valMap.ReservedStr2_Div != undefined && Object.keys(valMap.ReservedStr2_Div).length > 0) {
					    me.tempVal = {
						    ProofCode : valMap.ProofCode
						    , KeyNo : valMap.KeyNo
						    , Rownum : valMap.Rownum
						};
			    		
			    		let ctrlType = Object.keys(valMap.ReservedStr2_Div);
			    		
			    		//출장항목 관련 관리항목 처리
			    		if(document.querySelectorAll(`[name="CtrlArea"][keyno="${'${valMap.KeyNo}'}"][rownum="${'${valMap.Rownum}'}"] select[code="D01"]`).length > 0) {
							let ctrlType = Object.keys(valMap.ReservedStr2_Div);
							
							if(valMap.ReservedStr3_Div != undefined && Object.keys(valMap.ReservedStr3_Div).length > 1) {
								let ctrlStr3 = valMap.ReservedStr3_Div[ctrlType[1]];
				            	if(ctrlStr3 != undefined && ctrlStr3 != "") {
				            		let strJson = typeof(ctrlStr3) == 'string' ? ctrlStr3 : JSON.stringify(ctrlStr3);
				            		let jsonDiv = JSON.parse(strJson);
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
			    		} else if(document.querySelectorAll(`[name="CtrlArea"][keyno="${'${valMap.KeyNo}'}"][rownum="${'${valMap.Rownum}'}"] input[code="C07"]`).length > 0) {
		            		let ctrlStr3 = valMap.ReservedStr3_Div['C07'];
			    			if(ctrlStr3 != undefined && ctrlStr3 != "") {
			    				let strJson = typeof(ctrlStr3) == 'string' ? ctrlStr3 : JSON.stringify(ctrlStr3);
			    				let jsonDiv = JSON.parse(strJson);
								me.tempVal.code = 'C07';
				            	
								me.SetAttendantCallBack(jsonDiv);
			    			}
			    		}
				    	delete this.tempVal;
			    	}
					divItem = $.extend({}, divItem, valMap);
				});
				
				if (isUseIO == "N") {
			   		document.querySelectorAll("[name=noIOArea]").forEach(e => e.style.display = 'none');
			   	}
			   	if (isUseSB == "N") {
			   		document.querySelectorAll("[name=noSBArea]").forEach(e => e.style.display = 'none');
			   	} else {
			   		document.querySelectorAll("[name=AccBtn]").forEach(e => e.remove());
			   		document.querySelectorAll("[name=DivAccNm]").forEach(e => e.style.width = '116px');
			   	}
			   	if (isUseBD == "" || isUseBD == "N") {
			   		document.querySelectorAll("[name=noBDArea]").forEach(e => e.style.display = 'none');
			   	}
			},
			simpApp_delSelectAddDiv: function(ProofCode, KeyNo) {
				let me = this;
				let targetRows = document.querySelectorAll("[name=DivCheck]:checked");
				let getItem = me.pageExpenceAppTarget;
				let divList = getItem.divList;
				
				if (targetRows.length == 0) {
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />"); //선택된 항목이 없습니다.
					return;
				}
				
				targetRows.forEach(function(row) {
					let Rownum = String(row.getAttribute('rownum'));
					let idx = accFindIdx(divList, "Rownum", Rownum);
					
					if (idx >= 0) {
						let divItem = divList[idx];
						//출장항목(일비, 유류비) 증빙분할 삭제 시 합계된 청구금액 빼기
						/* if(divItem.ReservedStr2_Div != undefined && Object.keys(divItem.ReservedStr2_Div).length != 0) {
							if('D02' in divItem.ReservedStr2_Div || 'D03' in divItem.ReservedStr2_Div || 'Z09' in divItem.ReservedStr2_Div) {
								let totalAmount = AmttoNumFormat(getItem.divSum);
								let delAmount = AmttoNumFormat(divItem.Amount);
								
								let tempTotalAmount = parseInt(totalAmount) - parseInt(delAmount);
								document.querySelector(`[name=TotalAmountField][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).value = tempTotalAmount;
								this.setListVal(ProofCode, KeyNo, Rownum, "TotalAmount", tempTotalAmount);
							}
						} */
						
						me.setDivVal(ProofCode, KeyNo, Rownum, "Amount", 0);
						divList.splice(idx,1);
						document.querySelector(`[name=DivRowDL][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).remove();
					}
				});
			},
			setListVal: function(ProofCode, fieldNm, KeyNo, val) {
				let getItem = this.pageExpenceAppTarget;
				getItem[fieldNm] = val;
			},
			findListItem: function(inputList, field, val) {
				let returnVal = Array.isArray(inputList) ? accFind(inputList, field, val) : null;
				return returnVal;
			},
			investTargetSet: function(ProofCode, KeyNo, InvestItem) {
				let me = this;
				
				let code = 'B01';//B01 : 경조항목
				let B01Val = document.querySelector(`[code="${'${code}'}"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).value;
				
				InvestItem = me.comboData.InvestTargetList.filter(function(o) {
					return $.inArray(B01Val.toString(), o.Reserved1.split(",")) > -1
				});
				
				code = 'B02';//B02 : 경조대상 
				var B02Val = document.querySelector(`[code="${'${code}'}"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).value;
				if(!jQuery.isEmptyObject(InvestItem)){
					htmlStr = me.comCostAppListEdit_ComboDataMake(InvestItem, "Code", "CodeName", null, "Y");
					document.querySelector(`[code="${'${code}'}"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).innerHTML = htmlStr;
					
					var Item = me.findListItem(InvestItem, 'Code', B02Val);
					if(jQuery.isEmptyObject(Item))
						// B02Val = $("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"] option:first").val()
						B02Val = document.querySelector(`[code="${'${code}'}"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"] option:first`).value;
					
					// $("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(B02Val).prop("selected", true);
					// $("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");
					document.querySelector(`[code="${'${code}'}"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).value = B02Val;
					document.querySelector(`[code="${'${code}'}"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).onchange();
				}
			},
			simpApp_ComboChange: async function(obj, type, ProofCode, KeyNo, Rownum) {
				let me = this;
				let val = obj.value;
				
				me.setListVal(ProofCode, type, KeyNo, val);
				
				var Item = me.pageExpenceAppTarget;

				if (type == "StandardBriefID"){
					me.setDivVal(ProofCode, KeyNo, Rownum, type, val);
					await me.briefValSet(ProofCode, KeyNo, Rownum, val);
					
					if(me.pageExpenceAppObj.RequestType == "INVEST") {
						me.investTargetSet(ProofCode, KeyNo, '');
					} else {
						let BizTripItemItem = me.comboData.BizTripItemList.filter(function(o) {
							let Items = o.Reserved1;
							if(isEmptyStr(Items))return false;
							if(me.requestType == "OVERSEA"&&(o.Code=='Toll'||o.Code=='Fuel'||o.Code=='Park'))return;
							return $.inArray(val.toString(),Items.split(",")) > -1
						});
					
						//출장항목 선택가능항목 변경
						if(!jQuery.isEmptyObject(BizTripItemItem) && BizTripItemItem.length > 0){
							let bizElement = document.querySelectorAll(`[code="D01"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`);
							if(bizElement.length > 0) {
								htmlStr = me.makeComboOption(BizTripItemItem, "Code", "CodeName",null,"Y");
								//D01 : 출장항목
								let D01Val = document.querySelector(`[code="D01"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).value;
								let D01Item = me.findListItem(BizTripItemItem, 'Code', D01Val);
								document.querySelector(`[code="D01"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).innerHTML = htmlStr;
								if(jQuery.isEmptyObject(D01Item))
									D01Val = document.querySelectorAll(`[code="D01"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"] option`)[0].value;
							
								// $("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(D01Val).prop("selected", true);
								// $("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").trigger("onchange");
								document.querySelector(`[code="D01"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).value = D01Val;
								document.querySelector(`[code="D01"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).onchange();
							}
						}
					}
				}
				
				if(me.pageExpenceAppObj.RequestType == "INVEST") {
					if(type=="InvestItem") {
						let getItem = me.findListItem(me.comboData.InvestItemList, 'Code', val);
						let desc = getItem.Reserved1;//경조항목 별 설명 
						desc = isEmptyStr(desc)?'':desc;
						
						let selector = `[name="BriefDecField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`;
						if(desc != '') {
							// $("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").show();
							// $("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").html(desc);
							document.querySelector(selector).style.display = "";
							document.querySelector(selector).innerHTML = desc;
						} else {
							// $("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").hide();
							document.querySelector(selector).style.display = "none";
						}
						
						me.investTargetSet(ProofCode, KeyNo, val); //경조항목 별 경조 대상 select box 바인딩
					} else if(type=="InvestTarget") {
						if(nullToBlank(me.tempVal.saveType) == "" && me.tempVal.isLoad) {
							let getItem = me.findListItem(me.comboData.InvestTargetList, 'Code', val);
							let amount = getItem.ReservedInt;
							amount = isEmptyStr(amount)?0:amount;
							
							
							// $("[name=TotalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(amount);
							// $("[name=TotalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]")[0].onkeyup();
							let totalSelector = `[name="BriefDecField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`;
							document.querySelector(totalSelector).value = amount;
							document.querySelector(totalSelector).onkeyup();
							me.setListVal(ProofCode, "TotalAmount", KeyNo, amount);
							
							// $("[name=AmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(amount);
							// $("[name=AmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]")[0].onkeyup();
							let amountSelector = `[name="BriefDecField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`;
							document.querySelector(amountSelector).value = amount;
							document.querySelector(amountSelector).onkeyup();
							me.comCostAppListEdit_setListVal(ProofCode, "Amount", KeyNo, amount);
						}
					}
				}
				
				if(type == "BizTripItem") {
					// var objTem = $("[tag=Amount][keyno="+KeyNo+"][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					// var tempObj = $.extend(true, {}, Item); 
					//Rownum = isEmptyStr(Item.divList[0].Rownum) ? 0 :Item.divList[0].Rownum;
					let selector = `[tag="Amount"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`;
					let objTem = document.querySelector(selector);
					let tempObj = accMerge({}, Item);
					var idx = accFindIdx(Item.divList, "Rownum", Rownum);
					Rownum = Item.divList[idx].Rownum;
					
					accountCtrl._modifyItemJson(me, 'D02', KeyNo, Rownum, ProofCode, Item.divList[idx], "DEL");
					accountCtrl._modifyItemJson(me, 'D03', KeyNo, Rownum, ProofCode, Item.divList[idx], "DEL");
					
					if(val == "Daily") {
						// $(objTem).attr("disabled", "disabled"); //일비는 청구금액 수동입력 불가능
						objTem.setAttribute("disabled", "disabled");
						
						Item.divList[idx].ReservedStr2_Div['D03'] = tempObj.ReservedStr2_Div['D03'] ;
						Item.divList[idx].ReservedStr2_Div['D03_desc'] = tempObj.ReservedStr2_Div['D03_desc'] ;
						Item.divList[idx].ReservedStr3_Div['D03'] = tempObj.ReservedStr3_Div['D03'] ;
						Item.divList[idx].ReservedStr3_Div['D03_desc'] = tempObj.ReservedStr3_Div['D03_desc'] ;						
						accountCtrl._modifyItemJson(me, 'D03', KeyNo, Rownum, ProofCode, Item.divList[idx], "ADD");
					} else {
						// $(objTem).removeAttr("disabled");
						objTem.removeAttribute("disabled");
						
						if(val == "Fuel") {
							Item.divList[idx].ReservedStr2_Div['D02'] = tempObj.ReservedStr2_Div['D02'] ;
							Item.divList[idx].ReservedStr2_Div['D02_desc'] = tempObj.ReservedStr2_Div['D02_desc'] ;
							Item.divList[idx].ReservedStr3_Div['D02'] = tempObj.ReservedStr3_Div['D02'] ;
							Item.divList[idx].ReservedStr3_Div['D02_desc'] = tempObj.ReservedStr3_Div['D02_desc'] ;							
							accountCtrl._modifyItemJson(me, 'D02', KeyNo, Rownum, ProofCode, Item.divList[idx], "ADD");
						}
					}
				}
				
				if(type=="Currency") {
					let exchangeRateField = document.querySelector(`[name="ExchangeRateField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`);
					let localAmountField = document.querySelector(`[name="LocalAmountField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`);
					
					if(val == "KRW") {
						document.querySelector(`span[name="ExRateArea"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).style.display = "none";
						
						// 환율 초기화
						exchangeRateField.value = 0;
						exchangeRateField.onblur();
						// 현지금액 초기화
						localAmountField.value = 0;
						localAmountField.onblur();
					} else {
						let proofDateField = document.querySelector(`[name="SimpAppDateField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`);
						let proofDate = proofDateField.querySelector("input[type=text]").value;
						
						// 환율, 현지금액 영역 show
						document.querySelector(`span[name=ExRateArea][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).style.display = "";
						
						// 증빙날짜 비어있을 때 오늘날짜
						if(proofDate == "") {
							let today = new Date().format('yyyy.MM.dd');
							let todayHidden = new Date(today).format("MM/dd/yyyy");
							
							proofDateField.querySelector("input[type=text]").value = today;
							proofDateField.querySelector("input[type=hidden]").value = todayHidden;
							proofDateField.onchange();
							
							proofDate = today;
						}
						
						// 환율 적용
						let exchangeRate = accComm.getExchangeRate(proofDate, val);
						exchangeRateField.value = exchangeRate == "" || exchangeRate == undefined ? 0 : exchangeRate;
						exchangeRateField.onblur();
						
						// 현지금액 비어있을 때 0원
						if(localAmountField.value == "") {
							localAmountField.value = 0;
							localAmountField.onblur();
						}
					}
				}
			},
			ctrlComboChange: function(obj) {
	            let type = obj.getAttribute("type");
	            let ProofCode = obj.getAttribute("proofcd");
	            let KeyNo = obj.getAttribute("keyno");
	            let Rownum = obj.getAttribute("Rownum");
	         	
	            this.simpApp_ComboChange(obj, type, ProofCode, KeyNo, Rownum);
			},
			setChkYN: function (obj) {
	            let me = this;
	            let val = obj.value;

	            if (val == "Y"){
	            	val = "";
	            } else{
	                val = "Y";
	            }
	            
	            obj.value = val;
	        },
			callBizTripPopup: function(element, name) {
	            let obj = element.previousElementSibling;

	            let ProofCode = obj.getAttribute("proofcd");
	            let KeyNo = obj.getAttribute("keyno");
	            let Rownum = obj.getAttribute("rownum");
	            let code = obj.getAttribute("code");
	            
	            let popupTit = name;
	            let popupID;
	            let popupName;
	            let callBack;
	            let width;
	            let height;
	            
	            this.tempVal = {
	            	KeyNo : KeyNo,
	            	ProofCode : ProofCode,
	            	Rownum : Rownum,
	            	code : code
	            };
	            
	            coviCmn.traceLog(this.tempVal);
	            
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
	            
	            let url = "/account/accountCommon/accountCommonPopup.do?"
					+	"popupID="		+	popupID		+	"&"
					+	"popupName="	+	popupName	+	"&"
					+	"parentNM="		+	this.pageName	+	"&"
					+	"jsonCode="		+	code		+	"&"
					+	"KeyNo="		+	KeyNo		+	"&"
					+	"ProofCode="	+	ProofCode	+	"&"
					+	"RequestType="	+	this.pageExpenceAppObj.RequestType	+	"&" 
					+	"Rownum="		+	Rownum			+	"&" 
					+	this.pageOpenerIDStr
					+	"includeAccount=N&"
					+	"IsEditPopup=Y&"
					+	"companyCode="	+	this.pageExpenceAppObj.CompanyCode	+ "&"
					+	"callBackFunc="	+	callBack;
	            
	            if(code == "D02") {
					url += "&CFN_OpenedWindow=true"
	            	CFN_OpenWindow(url, "", width, height, "both");
	            } else {
	            	Common.open("", popupID, popupTit, url, width, height, "iframe", true, null, null, true);
	            }
			},
			SetDistanceCallBack: function (info) {
	            let me = window.SimpleApplicationModify;
	            let ProofCode = me.tempVal.ProofCode;
	            let KeyNo = me.tempVal.KeyNo;
	            let Rownum = me.tempVal.Rownum;
	            let pageList = me.pageExpenceAppTarget;
	            let KeyField = me.proofKey(ProofCode);
	            let getItem =  me.pageExpenceAppTarget;
				
				let fuelList = Object.assign([], info['FuelExpenceAppEvidList']);
				
				let FuelRealPrice = 0;
				let totDistance = 0;
				let lastDate = '';
				
				let code = me.tempVal.code;
				let obj = document.querySelector(`input[code="${'${code}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`);
				let PopCode = {};
				let lastDateHidden = new Date(lastDate);
				let Distance;
						
				fuelList.forEach(function(item, idx) {
					item.BizTripDateStr = item.BizTripDate;
					item.BizTripDate = item.BizTripDate.replace(/\./gi, '');	
					FuelRealPrice += Number(item.FuelRealPrice);
					totDistance += Number(item.Distance);
					
				    if (Number(item.BizTripDate) > lastDate.replace(/\./gi, '')) {
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
	            
				document.querySelector(`[tag="Amount"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).value = FuelRealPrice;
				document.querySelector(`[tag="Amount"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).onblur();
				
				//divList 수정
				me.setDivVal(ProofCode, KeyNo, Rownum, "Amount", FuelRealPrice);
				//총합 계산
				me.setBizTripTotalAmount(ProofCode, KeyNo, Rownum, getItem, FuelRealPrice);
				
				document.querySelector(`[name="SimpAppDateField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"] input[type="text"]`).value = lastDate;
				document.querySelector(`[name="SimpAppDateField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"] input[type="hidden"]`).value = lastDateHidden;
				document.querySelector(`[name="SimpAppDateField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).onchange();
				
	            document.querySelector(`[code="${'${code}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"][popup="value"]`).value = Distance;
	            document.querySelector(`[code="${'${code}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"][popup="code"]`).value = PopCode;
	            
	            accountCtrl._onSaveJson(me, obj, "CtrlArea", ProofCode, KeyNo, Rownum);
				me.tempVal = {};
	        },
	        SetDailyCallBack : function(returnList) {
	        	let me = this;
	        	let ProofCode = me.tempVal.ProofCode;
	        	let KeyNo = me.tempVal.KeyNo;
	        	let Rownum = me.tempVal.Rownum;
 
	        	let getItem =me.pageExpenceAppTarget;
				
	        	let dailyList = Object.assign([], returnList['DailyExpenceAppEvidList']);
				
	        	let DailyAmount = 0;
	        	let commentHtml = "";
	        	let WorkingDays = 0;
	        	let lastDate = '';
				
	        	let code = me.tempVal.code; 
	        	let obj = document.querySelector(`input[code="${'${code}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`);
	        	
	        	let PopCode = {};
	        	let lastDateHidden = new Date(lastDate);
	        	
	        	dailyList.forEach(function(item, idx) {
	        		/* item.BizTripDateStStr = item.BizTripDateSt;
					item.BizTripDateSt = item.BizTripDateSt.replace(/\./gi, '');
					item.BizTripDateEdStr = item.BizTripDateEd;
					item.BizTripDateEd = item.BizTripDateEd.replace(/\./gi, ''); */
					item.BizTripDateStStr = item.BizTripDateSt.replace(/\./gi, '');
					item.BizTripDateEdStr = item.BizTripDateEd.replace(/\./gi, '');

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
				
				document.querySelector(`[tag="Comment"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).innerHTML = commentHtml;
				document.querySelector(`[tag="Comment"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).onkeyup();
				
				document.querySelector(`[tag="Amount"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).value = DailyAmount;
				document.querySelector(`[tag="Amount"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).onblur();
				
				//divList 수정
				me.setDivVal(ProofCode, KeyNo, Rownum, "Amount", DailyAmount);
				//총합 계산
				me.setBizTripTotalAmount(ProofCode, KeyNo, Rownum, getItem, DailyAmount);
				
				document.querySelector(`[name="SimpAppDateField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"] input[type="text"]`).value = lastDate;
				document.querySelector(`[name="SimpAppDateField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"] input[type="hidden"]`).value = lastDateHidden;
				document.querySelector(`[name="SimpAppDateField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).onchange();
		           
	            document.querySelector(`[code="${'${code}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"][popup="value"]`).value = WorkingDays;
	            document.querySelector(`[code="${'${code}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"][popup="code"]`).value = PopCode;

	            accountCtrl._onSaveJson(me, obj, "CtrlArea", ProofCode, KeyNo, Rownum);
				me.tempVal = {};
	        },
	        setBizTripTotalAmount : function(ProofCode, KeyNo, Rownum, item, amount) {
				let me = this;
				
				let TotalAmount = 0;
				for(let i = 0; i < item.divList.length; i++) {
					let divItem = item.divList[i];
				    if (divItem.ReservedStr2_Div != undefined) {
					    if ('D02' in divItem.ReservedStr2_Div || 'D03' in divItem.ReservedStr2_Div || 'Z09' in divItem.ReservedStr2_Div)
					    	TotalAmount += divItem.Amount;
				    }
				}
				
				let totalField;
				totalField = document.querySelectorAll(`[name="TotalAmountField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`);
				
				if(totalField.length > 0) {
					totalField.value = toAmtFormat(TotalAmount) 
					me.setListVal(ProofCode, "TotalAmount", KeyNo, TotalAmount);
				}
	        },
	        callAttendantPopup : function(element, name) { // 편익제공 팝업 오픈 함수
	        	let obj = element.previousElementSibling;

	        	let ProofCode = obj.getAttribute("proofcd");
	        	let KeyNo = obj.getAttribute("keyno");
	        	let Rownum = obj.getAttribute("rownum");
	        	let code = obj.getAttribute("code");

	            this.tempVal = {
	            	KeyNo : KeyNo,
	            	ProofCode : ProofCode,
	            	Rownum : Rownum,
	            	code : code
	            };

	            let popupTit = name;
	            let popupID;
	            let popupName;
	            let callBack;
	            let width;
	            let height;
	            
	            if(code=="C07") {//C07:tmap없는 유류비
		            popupID = "AttendantPopup";
		            popupName = "AttendantPopup";
		            callBack = "SetAttendantCallBack";
		            width = "1000px";
		            height = "550px";
	            }
	            
	            var url =	"/account/accountCommon/accountCommonPopup.do?"
						+	"popupID="		+	popupID			+	"&"
						+	"popupName="	+	popupName		+	"&"
						+	"parentNM="		+	this.pageName	+	"&"
						+	"jsonCode="		+	code			+	"&"
						+	"KeyNo="		+	KeyNo			+	"&"
						+	"ProofCode="	+	ProofCode		+	"&"
						+	"RequestType="	+	this.pageExpenceAppObj.RequestType	+	"&" 
						+	this.pageOpenerIDStr
						+	"includeAccount=N&"
						+	"IsEditPopup=Y&"
						+	"companyCode="	+	this.pageExpenceAppObj.CompanyCode	+ "&"
						+	"callBackFunc="	+	callBack;
	            
	            Common.open("", popupID, popupTit, url, width, height, "iframe", true, null, null, true);
	        },
	        SetAttendantCallBack : function(returnList) { // 편익제공 팝업 콜백 함수
	        	let me = this;
	        	let ProofCode = me.tempVal.ProofCode;
	        	let KeyNo = me.tempVal.KeyNo;
	        	let Rownum = me.tempVal.Rownum;
	        	let code = me.tempVal.code;
					            
	        	let obj = document.querySelector(`input[code="${'${code}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`);
	            
	        	let attendList = Object.assign([], returnList['AttendantList']);
	        	
	        	let PopCode = {};
	            PopCode['AttendantList'] = returnList['AttendantList'];
	            PopCode = JSON.stringify(PopCode);
	           
	            /* let displayText = $(attendList).length < 2 
									? $(attendList)[0].UserName 
									: "<spring:message code='Cache.msg_BesidesCount' />".replace("{0}", $(attendList)[0].UserName).replace("{1}", $(attendList).length-1); */
				
				let displayText = attendList.length < 2 ? attendList[0].UserName: Common.getDic("msg_BesidesCount").replace("{0}", attendList[0].UserName).replace("{1}", attendList.length - 1);
	           	
	            document.querySelector(`[code="${'${code}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"][popup="value"]`).value = displayText;
	            document.querySelector(`[code="${'${code}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"][popup="code"]`).value = PopCode;
	            
	            accountCtrl._onSaveJson(me, obj, "CtrlArea", ProofCode, KeyNo, Rownum);
				me.tempVal = {};
	        },
	        simpApp_divInputChange: function(obj, ProofCode, KeyNo, Rownum, jsonVal, type) {
				let fieldName = "";
				let value = "";
				
				if (jsonVal != undefined) {
					if (type == "1") {
						fieldName = "ReservedStr2_Div";
						value = jsonVal;
		            } else if (type == "2") {
		            	fieldName = "ReservedStr3_Div";
		            	value = jsonVal;
		            }
				} else {
					let getTag = obj.getAttribute("tag");
					fieldName = obj.getAttribute("datafield");
					value = obj.value;
					
					if (getTag == "Amount") {
						//마이너스, 최대값 처리
						value = (value.charAt(0) == "-") ? value.charAt(0) + value.substr(1).replace(/[^0-9,.]/g, "") : value.replace(/[^0-9,.]/g, "");
						
						let numVal = ckNaN(AmttoNumFormat(value));
						if (numVal > 99999999999) { numVal = 99999999999; }
						
						value = numVal;
						obj.value = toAmtFormat(numVal);
					} else if (getTag == "Comment") {
						value = value.replace(/(?:\r\n|\r|\n)/gi, '<br>');
					}
				}
				
				this.setDivVal(ProofCode, KeyNo, Rownum, fieldName, value);
			},
	        simpApp_copyDiv: function(ProofCode, KeyNo) {
				let me = this;
				let targetRow = document.querySelectorAll(`[name="DivCheck"][keyno="${'${KeyNo}'}"]:checked`);
				if (targetRow.length > 1) {
					Common.Inform("<spring:message code='Cache.msg_SelectOnlyOne' />"); //1개 항목만 선택하세요.
					return;
				}
				
				let item = me.pageExpenceAppTarget;
			    let copyRownum = targetRow.length == 0 ? item.divList[0].Rownum : parseInt(targetRow[0].getAttribute('rownum'));
				
				let ctrlList = "";
				let ctrlItem = document.querySelectorAll(`[name=CtrlArea][keyno="${'${KeyNo}'}"][rownum="${'${copyRownum}'}"] [id][code]`);
				
				ctrlItem.forEach(function(element, index) {
					let code = $(element).attr('code');
					
			    	if (ctrlList.indexOf(code) == -1) {
			        	if (index > 0) { ctrlList += "," };
			    		ctrlList += code;
			    	}
				});
				
				if (item.divList == null) { item.divList = []; }
			    
			    let idx = accFindIdx(item.divList, "Rownum", copyRownum);
				let divList = item.divList[idx];
				let divItem = {
					ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID),
					ExpenceApplicationDivID : "",
					ViewKeyNo : String(item.ViewKeyNo),
					KeyNo : String(item.KeyNo),
					ProofCode : item.ProofCode,
					AccountCode : nullToBlank(divList.AccountCode),
					AccountName : nullToBlank(divList.AccountName),
					StandardBriefID : nullToBlank(divList.StandardBriefID),
					StandardBriefName : nullToBlank(divList.StandardBriefName),
					StandardBriefDesc : nullToBlank(divList.StandardBriefDesc),
					CostCenterCode : nullToBlank(divList.CostCenterCode),
					CostCenterName : nullToBlank(divList.CostCenterName),
					IOCode : nullToBlank(divList.IOCode),
					IOName : nullToBlank(divList.IOName),
					Amount : nullToBlank(divList.Amount),
					UsageComment : nullToBlank(divList.UsageComment),
					IsNew : nullToBlank(divList.IsNew),
				    //관리항목 셋팅
					TaxType	: nullToBlank(item.TaxType),
					TaxCode	: nullToBlank(item.TaxCode),
					CtrlCode : nullToBlank(ctrlList)
				}
				
				let maxRN = ckNaN(item.maxRowNum);
				maxRN++;
				item.maxRowNum = maxRN;
				divItem.Rownum = maxRN;
				
				if(divList.ReservedStr2_Div != undefined && Object.keys(divList.ReservedStr2_Div).length != 0)
					divItem.ReservedStr2_Div = Object.assign({}, divList.ReservedStr2_Div);
				if(divList.ReservedStr3_Div != undefined && Object.keys(divList.ReservedStr3_Div).length != 0)
					divItem.ReservedStr3_Div = Object.assign({}, divList.ReservedStr3_Div);
				
				item.divList.push(divItem);
				me.makeCopyDivHtml(divItem, divItem.ProofCode, divItem.KeyNo, copyRownum);
	        },
	        makeCopyDivHtml: function (divItem, ProofCode, KeyNo, copyRownum) {
				let Rownum = divItem.Rownum;
				let divArea = document.querySelector(`[name="DivAddArea"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`);
				let formStr = this.formList["SimpleApplication_DivAdd.html"];
				
				if (nullToBlank(divItem.Amount) == "") { divItem.Amount = divItem.TotalAmount; }
				
				let valMap = {
					RequestType : this.pageExpenceAppObj.RequestType,
					ExpenceApplicationListID : nullToBlank(divItem.ExpenceApplicationListID),
					ExpenceApplicationDivID : "",
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
				
				let divHtml = document.createElement('div');
				divHtml.innerHTML = accComm.accHtmlFormDicTrans(accComm.accHtmlFormSetVal(formStr, valMap));
				divArea.appendChild(divHtml);
				
				//표준적요, 관리항목 셋팅
				this.tempVal = {
			    	ProofCode : ProofCode
			    	, KeyNo : KeyNo
			    	, Rownum : Rownum
			    };
				
				this.briefValSet(ProofCode, KeyNo, Rownum, valMap.StandardBriefID);
				
				let me = this;
				if(document.querySelectorAll(`[name="CtrlArea"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).length > 0) {
			    	//관리항목 input 값 셋팅
			    	me.setCtrlDivHtml(valMap);
			    	
			    	//관리항목 popup 처리
			    	if(valMap.ReservedStr2_Div != undefined && Object.keys(valMap.ReservedStr2_Div).length > 0) {
			    		let ctrlType = Object.keys(valMap.ReservedStr2_Div);
			    		
			    		//출장항목 관련 관리항목 처리
			    		if(document.querySelectorAll(`[name="CtrlArea"][keyno="${'${KeyNo}'}"][rownum="${'${copyRownum}'}"] select[code="D01"]`).length > 0) {
							document.querySelector(`select[code="${'${ctrlType[0]}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"][type="BizTripItem"]`).value
								= document.querySelector(`select[code="${'${ctrlType[0]}'}"][keyno="${'${KeyNo}'}"][rownum="${'${copyRownum}'}"][type="BizTripItem"]`).value;
							
							document.querySelector(`select[code="${'${ctrlType[0]}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"][type="BizTripItem"]`).onchange();
							
				            if(valMap.ReservedStr3_Div != undefined && Object.keys(valMap.ReservedStr3_Div).length > 1) {
			            		let ctrlStr3 = valMap.ReservedStr3_Div[ctrlType[1]];
			            		
				            	if(ctrlStr3 != undefined && ctrlStr3 != "") {
									let jsonDiv = JSON.parse(ctrlStr3);
									me.tempVal.code = ctrlType[1];
					            	
									if (ctrlType[1] == "D02") { me.SetDistanceCallBack(jsonDiv); }
									else if (ctrlType[1] == "D03") { me.SetDailyCallBack(jsonDiv); }
									else if (ctrlType[1] == "Z09") { me.SetDistanceCallBack(jsonDiv); }
									
									document.querySelector(`textarea[tag="Comment"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).innerHTML = valMap.UsageCommentVal;
									me.setDivVal(ProofCode, KeyNo, Rownum, "UsageComment", valMap.UsageCommentVal);
				            	}
							}
				        //편익제공 관련 관리항목 처리
			    		} else if(document.querySelectorAll(`[name="CtrlArea"][keyno="${'${KeyNo}'}"][rownum="${'${copyRownum}'}"] input[code="C07"]`).length > 0) {
			    			if(valMap.ReservedStr3_Div['C07'] != undefined || valMap.ReservedStr3_Div['C07'] != "") {
								let jsonDiv = JSON.parse(valMap.ReservedStr3_Div['C07']);
								me.tempVal.code = 'C07';
				            	
								me.SetAttendantCallBack(jsonDiv);
			    			}
			    		}
			    	}
			    }
			    
			    delete this.tempVal;
			    
			    //Amount 셋팅
			    this.setDivVal(ProofCode, KeyNo, Rownum, "Amount", valMap.Amount);
			    document.querySelector(`[name=DivAmountField][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][rownum="${'${Rownum}'}"]`).onblur();
				
				if (isUseIO == "N") {
			   		document.querySelectorAll("[name=noIOArea]").forEach(e => e.style.display = 'none');
			   	}
			   	if (isUseSB == "N") {
			   		document.querySelectorAll("[name=noSBArea]").forEach(e => e.style.display = 'none');
			   	} else {
			   		document.querySelectorAll("[name=AccBtn]").forEach(e => e.remove());
			   		document.querySelectorAll("[name=DivAccNm]").forEach(e => e.style.width = '116px');
			   	}
			   	if (isUseBD == "" || isUseBD == "N") {
			   		document.querySelectorAll("[name=noBDArea]").forEach(e => e.style.display = 'none');
			   	}
			},
			setCtrlDivHtml : function(divItem) {
				var ctrlCodeArr = divItem.CtrlCode.split(',');
				
				for(var i = 0; i < ctrlCodeArr.length; i++) {
					var ctrlVal = divItem.ReservedStr2_Div[ctrlCodeArr[i]];
					$("[name=CtrlArea] input[code="+ctrlCodeArr[i]+"][proofcd="+divItem.ProofCode+"][keyno="+divItem.KeyNo+"][rownum="+divItem.Rownum+"]").val(ctrlVal);
				}
			},
			saveList: function() {
				if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				
				let me = this;
				let Rownum = 0;
				
				// SC, EA일 경우 증빙 단의 세부증빙 데이터를 수정된 세부증빙 데이터로 재지정
				$.each(me.pageExpenceAppTarget.divList[0], function(key, value) {me.pageExpenceAppTarget[key] = value });
				
				let item = me.pageExpenceAppTarget;
				let divList = item.divList;
				let divSum = 0;

				let fileList = item.fileList;
				let uploadFileList = item.uploadFileList;
				let docList = item.docList;
				
				if(item.PostingDate == undefined || item.PostingDate == "") {
					item.PostingDate = item.ProofDate;
					item.PostingDateStr = item.ProofDateStr;
				}
				
				let dateInputList = document.querySelectorAll(`[name="DateArea"][proofcode="${'${item.ProofCode}'}"][keyno="${'${item.KeyNo}'}"]`);
				for(var i = 0; i < dateInputList.length; i++){
					let input = dateInputList[i];
					let dataField = input.getAttribute("datafield");
					let strVal = document.getElementById(`${'${input.id}'}_Date`).value;
					let val = strVal.replaceAll(".","");

					item[dataField] = val;
					item[dataField+"Str"] = strVal;
				}
				
				if(divList==null){
					Common.Inform("<spring:message code='Cache.ACC_019' />"); // 저장할 세부 항목이 없습니다.
					return;
				}
				if(divList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_019' />"); // 저장할 세부 항목이 없습니다.
					return;
				}
				if(isEmptyStr(item.TotalAmount)){
					Common.Inform("<spring:message code='Cache.ACC_052' />"); // 증빙금액이 입력되지 않은 항목이 있습니다.
					return;
				}				
				if(isEmptyStr(item.ProofDate)){
					Common.Inform("<spring:message code='Cache.ACC_053' />"); // 증빙일이 입력되지 않은 항목이 있습니다.
					return;
				}
		   		if(item.ProofCode == 'PrivateCard' && isEmptyStr(item.PersonalCardNo)){
					Common.Inform("<spring:message code='Cache.ACC_055' />"); // 개인카드 정보가 입력되지 않은 항목이 있습니다.
					return;
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
		   		
		   		let BriefMap = me.comboData.BriefMap;
		   		
		   		for (let y = 0; y < divList.length; y++) {
		   			let divItem = divList[y];
					let divAmt = divItem.Amount;
					
					divSum = divSum + ckNaN(AmttoNumFormat(divAmt));
					
					if(isUseSB == "Y" && isEmptyStr(divItem.StandardBriefID)){
						Common.Inform("<spring:message code='Cache.ACC_050' />"); // 표준적요가 입력되지 않은 항목이 있습니다.
						return;	
					}
					
					if(isEmptyStr(divItem.AccountCode)){
						Common.Inform("<spring:message code='Cache.ACC_060' />"); // 세부증빙에 계정과목이 입력되지 않은 항목이 있습니다.
						return;
					}
					
					if(isEmptyStr(divItem.CostCenterCode)){
						Common.Inform("<spring:message code='Cache.ACC_059' />"); // 세부증빙에 CostCenter가 입력되지 않은 항목이 있습니다.
						return;
					}
					
			   		if(isEmptyStr(divItem.UsageComment)){
						Common.Inform("<spring:message code='Cache.ACC_046' />"); // 내역은 필수로 입력하여야 합니다.
						return;
			   		}
			   		
			   		let getDivAmt = Number(AmttoNumFormat(nullToBlank(divItem.Amount)));
					if(isNaN(getDivAmt)){
						Common.Inform("<spring:message code='Cache.ACC_lbl_amtValidateErr' />"); // 청구금액이 [0]이거나 올바른 금액이 아닙니다.
						return;
					}
		   			
					let BriefInfo = BriefMap[divItem.StandardBriefID];
					if (BriefInfo.IsFile=='Y') {
						if ((!fileList || fileList.length == 0) && (!uploadFileList || uploadFileList.length == 0)) {
							let msg = "<spring:message code='Cache.ACC_msg_Require_AttchFile' />";//파일첨부 필수입니다
							Common.Inform(msg);
							return;
						}
					}
					if(BriefInfo.IsDocLink=='Y') {
						if (!docList || docList.length == 0) {
							let msg = "<spring:message code='Cache.ACC_msg_Require_DocLink' />";//문서연결 필수입니다
							Common.Inform(msg);
							return;
						}
					}
					
					// 관리항목 (ACC_CTRL) 필수체크 추가
					let reqchk = true;
					let selector = `input[keyno="${'${item.KeyNo}'}"][rownum="${'${divItem.Rownum}'}"][requiredVal=required][code],div[keyno="${'${item.KeyNo}'}"][rownum="${'${divItem.Rownum}'}"][requiredVal=required][code],select[keyno="${'${item.KeyNo}'}"][rownum="${'${divItem.Rownum}'}"][requiredVal=required][code]`;
					
					document.querySelectorAll(selector).forEach(function(element, i) {
						if (element.value == "" && element.getAttribute("viewtype") != "Date") {
							let msg = element.closest("dd").previousElementSibling.innerText + "<spring:message code='Cache.ACC_msg_required'/>";
							Common.Inform(msg);
							reqchk = false;
                            return false;
						} else {
							if (element.value == "") {
								let msg = element.closest("dd").previousElementSibling.innerText + "<spring:message code='Cache.ACC_msg_required' />"
								reqchk = false;
								return false;
							}
						}
					});
					
					if (!reqchk) return;
		   		}
		   		
		   		if (ckNaN(AmttoNumFormat(item.TotalAmount)) < divSum) {
					Common.Inform("<spring:message code='Cache.ACC_015' />"); // 항목의 세부비용의 합계금액이 증빙금액보다 클 수 없습니다.
					return;
				}
		   		
				item.divSum = divSum;
				
				// TODO: 예산 통제 추가				
				
				try {
					var targetObj = me.pageExpenceAppTarget; 
					accountCtrl.popupCallBackStrObj([targetObj]);
				} catch(e) {
					coviCmn.traceLog(e);
					coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
				}
				
				window.close(); 
			},
			linkComp: function(data, isSearched) {
				let me = window.SimpleApplicationModify;
				
				let list = typeof(data) == "string" ? data.split("^^^") : data;
				if (list == null){
					return;
				}
				
				let docList = [];
				
				let ProofCode = me.tempVal.ProofCode;
				let KeyNo = me.tempVal.KeyNo;
				
				let getItem = me.pageExpenceAppTarget;
				let pageDocList = getItem.docList;

				if (pageDocList == null){
					pageDocList = [];
				}
				
				for (let i = 0; i < list.length; i++){
					let docInfo = {};
					if(typeof(list[i]) == "string") {
						let tempList = list[i].split('@@@');
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
					let ckDocItem = {};
					if (!isSearched) {	
						ckDocItem = me.findListItem(pageDocList, "ProcessID", docInfo.ProcessID);
						if (ckDocItem == null) {
							ckDocItem = {};
						}
					}
					
					if (isEmptyStr(ckDocItem.ProcessID)){
						let info = Object.assign({}, docInfo)
						info.KeyNo = KeyNo;
						// 문서연결 팝업에서 선택할 때 동일한 문서(ProcessID 기준) 선택 시 1건만 들어가도록 처리
						let isDup = false;
						for (let j = 0; j < docList.length; j++) {
							if(info.ProcessID == docList[j].ProcessID) {
								isDup = true;
							} 
						}
	
						if(!isDup) {
							var docStr = "<div class='File_list' style='margin: 0px;' name='comCostApp"+ProofCode+"_DocItem_"+KeyNo+"_"+docInfo.ProcessID+"'>"
								+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"SimpleApplicationModify.docDelete('"+ProofCode+"','"+KeyNo+"','"+docInfo.ProcessID+"')\"></a>"
								+"<a href='javascript:void(0);' class='btn_File ico_doc' onClick=\"accComm.accLinkOpen('" + docInfo.ProcessID + "', '" + docInfo.forminstanceID + "', '" + docInfo.bstored + "', '" + docInfo.BusinessData2 + "')\">"
								+ nullToStr(docInfo.Subject, "("+"<spring:message code='Cache.ACC_lbl_noTitle' />"+")") 	+"</div>";
								
							docList.push(info);
								
							// $("[name=LinkArea]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"]").append(docStr);
							document.querySelector(`[name="LinkArea"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).style.display = "";
							document.querySelector(`[name="LinkArea"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).insertAdjacentHTML('beforeend', docStr);
						}
					}
				}
				
				if(!isSearched) {	
					if(getItem.docList == null || getItem.docList.length == 0){
						getItem.docList = docList;
					} else {
						let tempList = getItem.docList;
						let index = getItem.docList.length;
						for(let i = 0; i < docList.length; i++) {
							tempList[index + i] = docList[i];
						}
						getItem.docList = tempList;
					}
					
					if(getItem.docMaxNo==null){
						getItem.docMaxNo = 0;
					}
						
					for(let i = 0; i<docList.length; i++){
						let docItem = docList[i];
						getItem.docMaxNo++;
						docItem.docNum = getItem.docMaxNo;
					}
				}
				
				me.linkCk(ProofCode, KeyNo);
			},
			uploadHTML: function(data, KeyNo, ProofCode, isSearched) {
				let me = this;

				let list = data
				let fileList = [];
				let fileStr = "";
				
				if (list == null){
					return;
				}
				
				for(let i = 0; i<list.length; i++){
					let fileInfo = list[i];
					let info = Object.assign({}, fileInfo);
					info.KeyNo = KeyNo;
					
					// let fileHtmlStr = "<div class='File_list' style='margin: 0px;' name='comCostApp"+ProofCode+"_FileItem_"+KeyNo+"_"+fileInfo.fileNum+"'>"
					let fileHtmlStr = `<div class='File_list' style='margin: 0px;' name='comCostApp${'${ProofCode}'}_FileItem_${'${KeyNo}'}_${'${fileInfo.fileNum}'}'>`
					if (fileInfo.FileID != null){
						fileHtmlStr = fileHtmlStr+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"SimpleApplicationModify.fileDelete('"+ProofCode+"', '"+KeyNo+"','"+fileInfo.fileNum+"')\"></a>"
						+"<a href='javascript:void(0);' class='btn_File ico_file' onClick=\"accountFileCtrl.downloadFile('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
						+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
						+"<a class='previewBtn' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accountFileCtrl.attachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "');\"></a>";
						+"</div>";
					} else {
						fileHtmlStr = fileHtmlStr+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"SimpleApplicationModify.newFileDelete('"+ProofCode+"', '"+KeyNo+"','"+fileInfo.fileNum+"')\"></a>"
						+"<a href='javascript:void(0);' class='btn_File ico_file'>"+ fileInfo.FileName 
						+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a></div>";
					}
					
					// $("[name=LinkArea]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"]").append(fileHtmlStr);
					document.querySelector(`[name=LinkArea][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).insertAdjacentHTML('beforeend', fileHtmlStr);
				}
				
				me.linkCk(ProofCode, KeyNo);
			},
			linkCk: function(ProofCode, KeyNo) {
				let me = this;
				
				let ckVal = false;

				let item = me.pageExpenceAppTarget;
				let fList = []
				if (item.fileList != null){
					fList = fList.concat(item.fileList);
				}
				if (item.uploadFileList != null){
					fList = fList.concat(item.uploadFileList);
				}
				
				if (fList != null){
					if (fList.length != 0){
						ckVal = true;
					}
				}

				let dList = item.docList;
				if (dList != null){
					if (dList.length != 0){
						ckVal = true;
					}
				}
				
				let selector = `[name=LinkArea][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`; 
				if (ckVal){
					// $("[name=LinkArea]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"]").removeClass("border_none");
					// $("[name=LinkArea]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"]").show();\
					document.querySelector(selector).classList.remove("border_none");
					document.querySelector(selector).style.display = "";
				} else {
					// $("[name=LinkArea]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"]").addClass("border_none");
					document.querySelector(selector).classList.add("border_none");
				}
			},
			docDelete: function(ProofCode, KeyNo, docID) {
				let me = this;
				Common.Confirm("<spring:message code='Cache.ACC_lbl_DeleteDocLink' />", "Confirmation Dialog", function(result){
					if (result){
						let item = me.pageExpenceAppTarget;
						let docList = item.docList;
						let tempList = [];
						
						for (let i = 0; i < docList.length; i++){
							let docItem = docList[i];
							if (docItem.ProcessID != docID){
								tempList.push(docItem);											
							} else {
								// $("[name=comCostApp"+ProofCode+"_DocItem_"+KeyNo+"_"+docID+"]").remove();
								document.querySelector(`[name=comCostApp${'${ProofCode}'}_DocItem_${'${KeyNo}'}_${'${docID}'}]`).remove();
								
								if(item.deletedDoc == null){
									item.deletedDoc = [docItem];
								}else{
									item.deletedDoc.push(docItem);
								}
							}
						}
						item.docList = tempList;
						me.linkCk(ProofCode, KeyNo);
					}
				});
			},
			fileDelete: function(ProofCode, KeyNo, fileNum) {
				let me = this;
				
				Common.Confirm("<spring:message code='Cache.ACC_lbl_DeleteAttachFile' />", "Confirmation Dialog", function(result){	//파일을 삭제하시겠습니까?
					if(result){
						let item = me.pageExpenceAppTarget;
						let fileList = item.fileList;

						let idx = accFindIdx(fileList, "fileNum", fileNum);
						// $("[name=comCostApp"+ProofCode+"_FileItem_"+KeyNo+"_"+fileNum+"]").remove();
						document.querySelector(`[name=comCostApp${'${ProofCode}'}_FileItem_${'${KeyNo}'}_${'${fileNum}'}]`).remove();
						
						if(idx != -1){
							var fileItem = fileList[idx];
							fileList.splice(idx,1);
							if(item.deletedFile == null){
								item.deletedFile = [fileItem];
							}else{
								item.deletedFile.push(fileItem);
							}
						}
						me.linkCk(ProofCode, KeyNo);
					}
				});
			},
			newFileDelete : function(ProofCode, KeyNo, fileNum){
				let me = this;
				
				Common.Confirm("<spring:message code='Cache.ACC_lbl_DeleteAttachFile' />", "Confirmation Dialog", function(result){	// 파일을 삭제하시겠습니까?
					if(result){
						var item = me.pageExpenceAppTarget;
						
						var uploadFileList = item.uploadFileList;
						if(uploadFileList == null) {
							uploadFileList = item.fileList;
						}

						var idx = accFindIdx(uploadFileList, "fileNum", fileNum );
						// $("[name=comCostApp"+ProofCode+"_FileItem_"+KeyNo+"_"+fileNum+"]").remove();
						document.querySelector(`[name=comCostApp${'${ProofCode}'}_FileItem_${'${KeyNo}'}_${'${fileNum}'}]`).remove();
						
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
						
						me.linkCk(ProofCode, KeyNo);
					}
				});
			},
			simpApp_FileAttach: function(ProofCode, KeyNo) { 
				this.fileAttach(ProofCode, KeyNo); 
			},
			fileAttach : function(ProofCode, KeyNo) {
				let me = this;
				this.tempVal = {
					ProofCode : ProofCode,
					KeyNo	  : KeyNo
				}
				
				accountFileCtrl.callFileUpload(this, 'SimpleApplicationModify.fileCallback');
			},
			fileCallback: function(data) {
				let me = window.SimpleApplicationModify;

				let ProofCode = me.tempVal.ProofCode;
				let KeyNo = me.tempVal.KeyNo;
				
				let getItem = me.pageExpenceAppTarget;

				if (getItem.uploadFileList == null){
					getItem.uploadFileList = data;
				} else {
					let tempList = getItem.uploadFileList;
					let index = getItem.uploadFileList.length;
					for(let i = 0; i < data.length; i++) {
						tempList[index+i] = data[i];						
					}
					getItem.uploadFileList = tempList;
				}
				
				if (getItem.fileMaxNo==null){
					getItem.fileMaxNo = 0;
				}
				
				for (let i = 0; i<data.length; i++){
					let fileItem = data[i];
					getItem.fileMaxNo++;
					fileItem.fileNum = getItem.fileMaxNo;
				}
				accountFileCtrl.closeFilePopup();
				me.uploadHTML(data, KeyNo, ProofCode, false);
				me.linkCk(ProofCode, KeyNo);
			},
			simpApp_DocLink: function(ProofCode, KeyNo) { this.docLink(ProofCode, KeyNo); },
			docLink: function(ProofCode, KeyNo) {
				let me = this;
				me.tempVal = {
					ProofCode : ProofCode,
					KeyNo	  : KeyNo,
				}
				
				let url	= "/approval/goDocListSelectPage.do";
				let iWidth = 840, iHeight = 660, sSize = "fix";
				CFN_OpenWindow(url, "", iWidth, iHeight, sSize);
			},
			simpApp_billClick: function(ProofCode, ReceiptID, FileID) {
				let me = this;
				if(ProofCode == "CorpCard") {
					accComm.accCardAppClick(ReceiptID, me.pageOpenerIDStr);
				} else if(ProofCode == "Receipt") {
					accComm.accMobileReceiptAppClick(FileID, me.pageOpenerIDStr);
				}
			},
			simpApp_onIOSearch : function(ProofCode, KeyNo, Rownum) { this.comCostAppListEdit_callIOPopup(ProofCode, KeyNo, Rownum); },
			callIOPopup: function(ProofCode, KeyNo, Rownum) {
				let me = this;
				me.tempVal.ProofCode = ProofCode
				me.tempVal.KeyNo = KeyNo
				me.tempVal.Rownum = Rownum;
				let popupID		=	"ioSearchPopup";
				let popupTit	=	"<spring:message code='Cache.ACC_lbl_projectName' />";
				let popupName	=	"BaseCodeSearchPopup";
				let callBack	=	"setDivIOVal";
				let url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"companyCode="	+	me.pageExpenceAppObj.CompanyCode + "&"
								+	"codeGroup=IOCode&"
								+	"callBackFunc="	+	callBack;
				
				Common.open("", popupID, popupTit, url, "600px", "650px", "iframe", true, null,  null, true);
			},
			setDivIOVal: function(info) {
				let me = window.SimpleApplicationModify;

				let ProofCode = me.tempVal.ProofCode;
				let KeyNo = me.tempVal.KeyNo;
				let Rownum = me.tempVal.Rownum;
					
				// let cdField = $("[name=DivIOCd]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
				// let nmField = $("[name=DivIONm]["+me.pcFieldStr+"="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
				let cdField = document.querySelector(`[name="DivIOCd"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][keyno="${'${Rownum}'}"]`);
				let nmField = document.querySelector(`[name="DivIONm"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"][keyno="${'${Rownum}'}"]`);
				
				me.setDivVal(ProofCode, KeyNo, Rownum, "IOCode", info.Code);
				me.setDivVal(ProofCode, KeyNo, Rownum, "IOName", info.CodeName);
				
				// cdField.val(info.Code);
				// nmField.val(info.CodeName);
				cdField.value = info.Code;
				nmField.value = info.CodeName;
				
				me.tempVal = {};
			},
			simpApp_onDateChange: function(obj, KeyNo, ProofCode, Field) { this.changeDate(obj, KeyNo, ProofCode, Field); },
			changeDate : function(obj, KeyNo, ProofCode, Field) {
				let me = this;

				let pageList = me.pageExpenceAppTarget;
				let getId = obj.id
				let Strval = coviCtrl.getSimpleCalendar(getId);
				let val = Strval.replaceAll(".","");
				me.setListVal(ProofCode, Field, KeyNo, val);
				me.setListVal(ProofCode, Field+"Str", KeyNo, Strval);

				if (me.pageExpenceAppObj.RequestType == "BIZTRIP" || me.pageExpenceAppObj.RequestType == "OVERSEA") {
					if (field == 'ProofDate') {			
						//출장비 내역 가져오기
						opener.CombineCostApplicationView.comCostAppView_loadBizTripExpenceList();
					}
				}
				
				if(me.exchangeIsUse == "Y") {
					document.querySelector(`[name="CurrencySelectField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).onchange();
				}
			},
			simpApp_onInputFieldChange: function(obj, ProofCode, fieldNm) {
				let me = this;
				
				let getName = obj.name;
				let val = obj.value;
				let KeyNo = obj.getAttribute("keyno");
				let getItem = me.pageExpenceAppTarget;
				let Rownum = getItem.divList[0].Rownum;
				
				if(getName == "AmountField"
						|| getName == "TotalAmountField"
						|| getName == "TaxAmountField"
						|| getName == "ExchangeRateField"
						|| getName == "LocalAmountField"){
					val = val.replace(/[^0-9\-,.]/g, "");
					
					let numVal = ckNaN(AmttoNumFormat(val));
					if (numVal > 99999999999) { numVal = 99999999999; }
					
					val = Number(AmttoNumFormat(val));
					
					document.querySelector(`[name="${'${getName}'}"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).value = toAmtFormat(numVal);
					if(getName=="TotalAmountField"){
						document.querySelector(`[name=AmountField][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).value = toAmtFormat(numVal);
						me.setDivVal(ProofCode, KeyNo, Rownum, "Amount", val);
					}
					
					if(me.exchangeIsUse == "Y" && (getName=="ExchangeRateField" || getName=="LocalAmountField")){
						var calName = (getName == "ExchangeRateField" ? "LocalAmountField" : "ExchangeRateField");
						//var calVal =  Number(AmttoNumFormat($("[name="+calName+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val()));
						var calVal =  Number(AmttoNumFormat(document.querySelector(`[name="${'${calName}'}"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).value));
						//var curType = $("[name=CurrencySelectField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val();
						var curType = document.querySelector(`[name="CurrencySelectField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).value;
						var totalAmt = 0;
						
						//입력값 소수점 두자리  처리
						if (val % 1 > 0) { val = val.toFixed(2); };
						
						//$("[name="+Field+"][proofcode="+ProofCode+"][keyno="+KeyNo+"]").val(toAmtFormat(val));
						document.querySelector(`[name="${'${getName}'}"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).value = toAmtFormat(val);
						me.setDivVal(ProofCode, KeyNo, Rownum, getName, val);
						
						//증빙합계 소수점 두자리  처리
						totalAmt = val*calVal;
						//엔화 예외처리
						if (curType == "JPY") { totalAmt = totalAmt / 100 };
						if (totalAmt % 1 > 0) { totalAmt = totalAmt.toFixed(2); }
						
						document.querySelector(`[name="TotalAmountField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).value = toAmtFormat(totalAmt);
						document.querySelector(`[name="TotalAmountField"][proofcd="${'${ProofCode}'}"][keyno="${'${KeyNo}'}"]`).onblur();
					}
				}
				
				me.setListVal(ProofCode, fieldNm, KeyNo, val);
			}
		}
		window.SimpleApplicationModify = SimpleApplicationModify;
		SimpleApplicationModify.pageInit();
	});
	
	function InputDocLinks(szValue) {
	    try {
	    	window.SimpleApplicationModify.linkComp(szValue); 
	    	// szValue : [ProcessID(ProcessArchiveID)]@@@[FormPrefix]@@@[Subject]^^^[ProcessID(ProcessArchiveID)]@@@[FormPrefix]@@@[Subject]
	    	// ex) 2402569@@@WF_FORM_EACCOUNT_LEGACY@@@결재연동 1713^^^2400107@@@WF_FORM_EACCOUNT_LEGACY@@@통합 비용 신청 - 0706 #1
	    }
	    catch (e) {
	    }
	}
</script>