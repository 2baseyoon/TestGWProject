//양식별 다국어 정의 부분
var localLang_ko = {
    localLangItems: {
    }
};

var localLang_en = {
    localLangItems: {
    }
};

var localLang_ja = {
    localLangItems: {
    }
};

var localLang_zh = {
    localLangItems: {
    }
};


//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();
    
    //지출형태 selectBox 셋팅
    getPayMethodSelect();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        //<!--loadMultiRow_Read-->
        
        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
        	//거래처 지급 내역
        	if(formJson.BodyContext.tblExpenceInfo != undefined) {
        		if(formJson.BodyContext.tblExpenceInfo.length == undefined && formJson.BodyContext.tblExpenceInfo.exp_app_list_ids == "") {
        			$("#tblExpenceInfo").hide();
        			$("#tblExpenceInfo").prev().hide();
        		} else {
        			XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblExpenceInfo), 'json', '#tblExpenceInfo', 'R');
        		}
	        }
        
        	//지출 보고 내역
	        if(formJson.BodyContext.tblReportInfo != undefined) {
	        	if(formJson.BodyContext.tblReportInfo.length == undefined && formJson.BodyContext.tblReportInfo.pay_method_code_rep == "") {
        			$("#tblReportInfo").hide();
        			$("#tblReportInfo").prev().hide();
	        	} else {
	        		XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblReportInfo), 'json', '#tblReportInfo', 'R');
	        	}
	            
	        }
	        
	        //직원 경비 내역
	        if(formJson.BodyContext.employee_sum == "") {
	        	$("#tblEmployeeInfo").hide();
	        	$("#tblEmployeeInfo").prev().hide();
	        }
	        
	        //추가 항목
	        if(formJson.BodyContext.tblAddInfo != undefined) {
	        	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblAddInfo), 'json', '#tblAddInfo', 'R');
	        } else {
	        	$("#tblAddInfo").hide();
	        	$("#tblAddInfo").prev().hide();
	        }
	        
	        //추가항목 - 계좌 간 이체
	        if(formJson.BodyContext.tblAccountInfo != undefined) {
	        	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblAccountInfo), 'json', '#tblAccountInfo', 'R');
	        } else {
	        	$("#tblAccountInfo").hide();
	        }
        }
        
        setReadData();
        
        $("input[type=button][name=list_doc]").val("세부내역 보기");
        $("input[type=button][name=apv_doc_rep]").val("결재문서 보기");
        $("[data-pattern=currency]").parent().css("text-align","right");

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usid"), false);
            document.getElementById("InitiatedDate").value = getInfo("AppInfo.svdt");
        }
        
        if (formJson && formJson.BodyContext && formJson.BodyContext.tblExpenceInfo){
        	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblExpenceInfo), 'json', '#tblExpenceInfo', 'W');
        } else {
        	XFORM.multirow.load('', 'json', '#tblExpenceInfo', 'W', { minLength: 1 });
        }
        
        if (formJson && formJson.BodyContext && formJson.BodyContext.tblReportInfo){
        	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblReportInfo), 'json', '#tblReportInfo', 'W');
        } else {
        	XFORM.multirow.load('', 'json', '#tblReportInfo', 'W', { minLength: 1 });
        }
        
        if (formJson && formJson.BodyContext && formJson.BodyContext.tblAddInfo){
        	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblAddInfo), 'json', '#tblAddInfo', 'W');
        } else {
        	XFORM.multirow.load('', 'json', '#tblAddInfo', 'W', { minLength: 0 });
        }
        
        if (formJson && formJson.BodyContext && formJson.BodyContext.tblAccountInfo){
        	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblAccountInfo), 'json', '#tblAccountInfo', 'W');
        }
        else {
            XFORM.multirow.load('', 'json', '#tblAccountInfo', 'W', { minLength: 0 });
        }
        
        if (formJson.Request.mode == "DRAFT" && formJson.Request.gloct == "") {
        	setData();
        }
        
        $(".table_3").find("input[type=text]").not("[name=usage_comment]").css("border", "0px");
    	
    	EASY.init();
    	
    	$("[name=amount_sum]").trigger("change");
    	$("[name=amount_sum_rep]").trigger("change");    	

    	//멀티로우 항목 삭제시 계산함수 호출.
    	$(".multi-row-del-auto").on("click", function(){ setAmount(); });
    }
}

function setLabel() {
}

function setFormInfoDraft() {
}

function checkForm(bTempSave) {
    if (bTempSave) {
        return true;
    } else {
        // 필수 입력 필드 체크
        return EASY.check().result;
    }
}

function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("tblExpenceInfo", "rField"));
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("tblReportInfo", "rField"));
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("tblAddInfo", "rField"));
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("tblAccountInfo", "rField"));
	$$(bodyContextObj["BodyContext"]).append("Subject", document.getElementById("Subject").value); 
    return bodyContextObj;
}

function getPayMethodSelect() {
	CFN_CallAjax("/approval/legacy/getBaseCodeList.do", {"CodeGroup":"PayMethod", "CompanyCode":getInfo("AppInfo.etid")}, function (data){ 
		receiveHTTPGetData_payMethod(data); 
	}, false, 'json');
}

function receiveHTTPGetData_payMethod(data) {
    var elmlist = data.list;

    $("select[data-node-name='pay_method_add']").append("<option value=''>선택</option>");
    
    $(elmlist).each(function (i, obj) {
    	if(obj.Code == "T") {
    		$("select[data-node-name='pay_method_acc']").append("<option value='" + obj.Code + "' selected>" + obj.CodeName + "</option>");
    	} else {
    		$("select[data-node-name='pay_method_add']").append("<option value='" + obj.Code + "'>" + obj.CodeName + "</option>");
    		$("select[data-node-name='pay_method_name']").append("<option value='" + obj.Code + "'>" + obj.CodeName + "</option>");
    	}
    });
}

var corpCardSum = 0;		//법인카드
var autoSum = 0;			//자동이체
var normalSum = 0;			//일반이체
var cashSum = 0;			//현금인출
var accountSum = 0;			//계좌간이체
var totalSum = 0; 		//합계금액

// 거래처 지급 내역 + 지출 보고 내역 + 직원 경비 내역만
var evidCnt = 0;

function setData() {	
	var realPayDate = CFN_GetQueryString("realPayDate");
	var standardBriefID = CFN_GetQueryString("standardBriefID");
	var expAppListIDs = CFN_GetQueryString("expAppListIDs");
	var openMode = CFN_GetQueryString("openMode");
	var companyCode = CFN_GetQueryString("companyCode");
	
	//BodyContext에 넣기 위해 hidden 값으로 저장
	document.getElementById("RealPayDate").value = realPayDate;
	document.getElementById("StandardBriefID").value = standardBriefID;
	document.getElementById("expAppListIDs").value = expAppListIDs; 
	document.getElementById("OpenMode").value = openMode; 
	
	document.getElementById("real_pay_date").value = (realPayDate.substring(0, 4) + '-' + realPayDate.substring(4, 6) + '-' + realPayDate.substring(6));
	document.getElementById("CompanyCode").value = companyCode;
	
	//거래처 지급 영역
	setCapitalVendor(realPayDate, standardBriefID, expAppListIDs, companyCode);
	
	//자금지출(전체)일 경우만 자금지출 보고 영역 셋팅
	if(openMode == "A") {  
		setCapitalReport(realPayDate, standardBriefID, expAppListIDs, companyCode);
	} else {
		$("#tblReportInfo").hide();
		$("#tblReportInfo").prev().hide();
	}
	
	//직원경비 영역
	setCapitalEmployee(realPayDate, standardBriefID, expAppListIDs, companyCode);
	
	/*if(openMode == "A" && evidCnt == 0) {
		Common.Warning("<spring:message code='Cache.ACC_msg_noDataCapitalSpending' />", "Warning", function() { window.close(); }); //입력하신 자금집행일에 해당하는 자금지출 대상 내역이 없습니다.
	}*/
	
	if(document.getElementById("expAppListIDs").value != "") {
		expAppListIDs = document.getElementById("expAppListIDs").value;
		if(expAppListIDs.charAt(expAppListIDs.length-1) == ",") {
			expAppListIDs = expAppListIDs.slice(0,-1);
		}
		 
		document.getElementById("expAppListIDs").value = expAppListIDs;
		document.getElementById("ERPKey").value = expAppListIDs;
	}		
	
	setAmountField();
}

function setCapitalVendor(realPayDate, standardBriefID, expAppListIDs, companyCode) {
	$.ajax({
		type:"POST",
		url:"/account/expenceApplication/getCapitalSpendingList.do",
		async: false,
		data:{
			"queryMode"			: "Vendor",
			"realPayDate"		: realPayDate,
			"standardBriefID"	: standardBriefID,
			"expAppListIDs"		: expAppListIDs,
			"companyCode"		: companyCode
		},
		success:function (data) {
			if(data.result == "ok"){
				evidCnt += data.list.length;
				
				if(data.list.length > 0) {									
					var dataList = data.list;
					
					if(document.getElementById("RealPayDate").value == "") { //지출결의(개별) 시 자금집행일 넘겨주지 않을 경우
						document.getElementById("RealPayDate").value = dataList[0].RealPayDate.replace(/\./gi, '');
						document.getElementById("real_pay_date").value = dataList[0].RealPayDate;
					}
					
					var listIds = "";
					for(var i = 0; i < dataList.length; i++) {
						var dataObj = dataList[i];

						if(i > 0) {
							$("#tblExpenceInfo .multi-row-add").trigger("click");
						}
						
						var amount = dataObj.RealPayAmountSum;
						if(dataObj.ProofCode == "TaxBill" && dataObj.TotalAmountSum != dataObj.RealPayAmountSum) {
							if(amount > 0) {
								amount = Math.floor(dataObj.RealPayAmountSum * 1.1);
							} else {
								amount = Math.ceil(dataObj.RealPayAmountSum * 1.1);
							}
						}
						
						var payMethod = dataObj.PayMethod;
						if(dataObj.PayMethod == null || dataObj.PayMethod == '') {
							payMethod = "C";
						}
						
						//$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=pay_method_name]").val(payMethodName);
						//$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=pay_method_code]").val(payMethod);
						$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=pay_method_name]").val(payMethod);
						$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=register_name]").val(dataObj.RegisterName);
						$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=register_id]").val(dataObj.RegisterID);
						$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=standard_brief_name]").val(dataObj.StandardBriefName);
						$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=standard_brief_code]").val(dataObj.StandardBriefID);
						$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=list_cnt]").val(dataObj.ListCnt);
						$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=vendor_name]").val(dataObj.VendorName);
						$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=vendor_no]").val(dataObj.VendorNo);
						$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=usage_comment]").val(dataObj.UsageComment);
						$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=amount_sum]").val(amount);
						
						if(dataObj.expAppListIDs != undefined && dataObj.expAppListIDs != "") {
							$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=exp_app_list_ids]").val(dataObj.expAppListIDs);
							listIds += dataObj.expAppListIDs + ",";
						} else {
							$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=list_doc]").remove();
							$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=exp_app_list_ids]").val("");
						}
						
						switch(payMethod) {
						case "D": //법인카드
							corpCardSum += Number(amount);
							break;
						case "A": //자동이체
							autoSum += Number(amount);
							break;
						case "C": //일반이체
							normalSum += Number(amount);
							break;
						case "G": //현금인출
							cashSum += Number(amount);
							break;
						default: //값이 없을 경우 일반이체에 sum
							normalSum += Number(amount);
							break;
						}
					}
					
					if(expAppListIDs == "") { //팝업 오픈 시 list id를 넘겨주지 않았을 경우
						document.getElementById("expAppListIDs").value += listIds;
					}
					
				} else {
					$("#tblVendorInfo").hide();
					$("#tblVendorInfo").prev().hide();
				}
			} 
		},
		error:function (error){
			Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
		}
	});
}

function setCapitalReport(realPayDate, standardBriefID, expAppListIDs) {
	$.ajax({
		type:"POST",
		url:"/account/expenceApplication/getCapitalSpendingList.do",
		async: false,
		data:{
			"queryMode"			: "Report",
			"realPayDate"		: realPayDate,
			"standardBriefID"	: standardBriefID
		},
		success:function (data) {
			if(data.result == "ok"){
				evidCnt += data.list.length;
				
				if(data.list.length > 0) {									
					var dataList = data.list;
					
					var listIds = "";
					for(var i = 0; i < dataList.length; i++) {
						var dataObj = dataList[i];

						if(i > 0) {
							$("#tblReportInfo .multi-row-add").trigger("click");
						}
						
						$("#tblReportInfo").find("tr.multi-row").eq(i).find("[name=pay_method_name_rep]").val("일반이체"); //하드코딩 제거
						$("#tblReportInfo").find("tr.multi-row").eq(i).find("[name=pay_method_code_rep]").val("C");
						$("#tblReportInfo").find("tr.multi-row").eq(i).find("[name=register_name_rep]").val(dataObj.InitiatorDisplay);
						$("#tblReportInfo").find("tr.multi-row").eq(i).find("[name=register_id_rep]").val(dataObj.InitiatorCodeDisplay);
						$("#tblReportInfo").find("tr.multi-row").eq(i).find("[name=subject_rep]").val(dataObj.Subject);
						$("#tblReportInfo").find("tr.multi-row").eq(i).find("[name=standard_brief_name_rep]").val(dataObj.StandardBriefName);
						$("#tblReportInfo").find("tr.multi-row").eq(i).find("[name=standard_brief_code_rep]").val(dataObj.StandardBriefID);
						$("#tblReportInfo").find("tr.multi-row").eq(i).find("[name=amount_sum_rep]").val(dataObj.RealPayAmount);
						
						if(dataObj.ProcessID != undefined && dataObj.ProcessID != "") {
							$("#tblReportInfo").find("tr.multi-row").eq(i).find("[name=process_id_rep]").val(dataObj.ProcessID);
						} else {
							$("#tblReportInfo").find("tr.multi-row").eq(i).find("[name=apv_doc_rep]").remove();
							$("#tblReportInfo").find("tr.multi-row").eq(i).find("[name=process_id_rep]").val("");
						}
						
						if(dataObj.expAppListIDs != undefined && dataObj.expAppListIDs != "") {
							listIds += dataObj.expAppListIDs + ",";
						}
						
						// 인사팀 지출보고는 일반이체
						normalSum += Number(dataObj.RealPayAmount);
					}
					
					if(expAppListIDs == "") { //팝업 오픈 시 list id를 넘겨주지 않았을 경우
						document.getElementById("expAppListIDs").value += listIds;
					}
				} else {
					$("#tblReportInfo").hide();
					$("#tblReportInfo").prev().hide();
				}
			}
		},
		error:function (error){
			Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
		}
	});
}

function setCapitalEmployee(realPayDate, standardBriefID, expAppListIDs, companyCode) {
	$.ajax({
		type:"POST",
		url:"/account/expenceApplication/getCapitalSpendingList.do",
		async: false,
		data:{
			"queryMode"			: "Employee",
			"realPayDate"		: realPayDate,
			"standardBriefID"	: standardBriefID,
			"expAppListIDs"		: expAppListIDs,
			"companyCode"		: companyCode
		},
		success:function (data) {
			if(data.result == "ok"){
				evidCnt += data.list.length;
				
				if(data.list.length > 0) {									
					var dataList = data.list;
					
					if(document.getElementById("RealPayDate").value == "") { //지출결의(개별) 시 자금집행일 넘겨주지 않을 경우
						document.getElementById("RealPayDate").value = dataList[0].RealPayDate.replace(/\./gi, '');
						document.getElementById("real_pay_date").value = dataList[0].RealPayDate;
					}
					
					var listIds = "";
					var EmployeeSum = 0;
					for(var i = 0; i < dataList.length; i++) {
						var dataObj = dataList[i];
						
						var idStr = dataObj.RequestType.toLowerCase();
						$("#"+idStr+"_employee").val(dataObj.RealPayAmountSum);
						
						if(dataObj.expAppListIDs != undefined && dataObj.expAppListIDs != "") {
							$("#"+idStr+"_exp_app_list_ids").val(dataObj.expAppListIDs);
							listIds += dataObj.expAppListIDs + ",";
						}
						
						EmployeeSum += Number(dataObj.RealPayAmountSum);
						
						// 직원경비는 일반이체
						normalSum += Number(dataObj.RealPayAmountSum);
					}
					
					if(expAppListIDs == "") { //팝업 오픈 시 list id를 넘겨주지 않았을 경우
						document.getElementById("expAppListIDs").value += listIds;
					}
					
					$("#employee_sum").val(EmployeeSum);
				} else {
					$("#tblEmployeeInfo").hide();
					$("#tblEmployeeInfo").prev().hide();
				}
			}
		},
		error:function (error){
			Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
		}
	});
}

function setReadData() {
	if(formJson.BodyContext.tblExpenceInfo != undefined && formJson.BodyContext.tblExpenceInfo.length > 0) {
		for(var i = 0; i < formJson.BodyContext.tblExpenceInfo.length; i++) {
			var expAppListIDs = formJson.BodyContext.tblExpenceInfo[i].exp_app_list_ids;
			if(expAppListIDs == '') {
				$("#tblExpenceInfo").find("tr.multi-row").eq(i).find("[name=list_doc]").remove();
			}
		}
	}
	if(formJson.BodyContext.tblReportInfo != undefined && formJson.BodyContext.tblReportInfo.length > 0) {
		for(var i = 0; i < formJson.BodyContext.tblReportInfo.length; i++) {
			var ProcessID = formJson.BodyContext.tblReportInfo[i].process_id_rep;
			if(ProcessID == '') {
				$("#tblReportInfo").find("tr.multi-row").eq(i).find("[name=apv_doc_rep]").remove();
			}
		}
	}
	
	// 직원경비내역 이체용 엑셀파일 다운로드
	if($("#normal_exp_app_list_ids").length > 0){
		
		var _expAppListIdArr = [];
		_expAppListIdArr.push($("#normal_exp_app_list_ids").val());
		_expAppListIdArr.push($("#project_exp_app_list_ids").val());
		_expAppListIdArr.push($("#entertain_exp_app_list_ids").val());
		_expAppListIdArr.push($("#biztrip_exp_app_list_ids").val());
		_expAppListIdArr.push($("#oversea_exp_app_list_ids").val());
		
		var _expAppListIDs = _expAppListIdArr.join(",");
		
		var $employeeExpTbl = $("table#tblEmployeeInfo");
		var $btn = $("<a id='btEATransferDown' class='btnType02 btnNormal' style='float:right;'>직원경비 이체자료 엑셀다운</a>");
		$employeeExpTbl.prev("p").append($btn);
		$btn.on("click", function(ev){
			fnAccountTransferDataDown(_expAppListIDs);
		});
	}
	
	// 거래처지급내역 이체자료다운로드. (회계팀 요청)
	if($("#tblExpenceInfo").find(".multi-row").length > 0) {
		var expListIDs = $("#tblExpenceInfo").find("[name=exp_app_list_ids]");
		var listIdArr = [];
		for(var i = 0; i < expListIDs.length; i++) {
			if(expListIDs[i].value && expListIDs[i].value != "") {
				listIdArr.push(expListIDs[i].value);
			}
		}
		var listIdStr = listIdArr.join(",");
		listIdArr = null;
		
		var $vendorExpTbl = $("table#tblExpenceInfo");
		var $btn = $("<a id='btEATransferDown2' class='btnType02 btnNormal' style='float:right;'>거래처지급내역 이체자료 엑셀다운</a>");
		$vendorExpTbl.prev("p").append($btn);
		$btn.on("click", function(ev){
			fnAccountTransferDataDown2(listIdStr);
		});
	}
}

//expListIDs 기준으로 이체데이터 엑셀다운로드
function fnAccountTransferDataDown(_expAppListIDs){

    var headerName = ["경비구분","부서명","사용자명","금액","은행명","계좌번호","예금주"];
    var headerKey = ["RequestTypeName","DeptName","UserName","RealPayAmount","BankName", "BankAccountNo","BankAccountName"];
    var headerType = ["", "", "", "Numeric", "", "", ""];

    var f = document.ExcelDownFrm;
    if(!f){
            $(document.body).append("<form name='ExcelDownFrm' method='POST' target='_blank' />");
            f = document.ExcelDownFrm;
            
		    $(f).append("<input type='hidden' name='headerName' />");
		    $(f).append("<input type='hidden' name='headerKey' />");
		    $(f).append("<input type='hidden' name='headerType' />");
		    $(f).append("<input type='hidden' name='expListIDs' />");
		    $(f).append("<input type='hidden' name='title' />");
    }
    f.action = "/account/accountPortal/employeeExpenceExcelDownload.do";
    f.headerName.value = headerName.join("†");
    f.headerKey.value = headerKey.join(",")
    f.headerType.value = headerType.join("|");
    f.expListIDs.value = _expAppListIDs;
    f.title.value = encodeURIComponent("직원경비_이체목록");

    f.submit();
}

// 거래처지급내역 이체자료다운로드
function fnAccountTransferDataDown2(_expAppListIDs) {
	var headerName = ["거래처명","금액","은행명","계좌번호","예금주"];
    var headerKey = ["VendorName","RealPayAmount","BankName", "BankAccountNo","BankAccountName"];
    var headerType = ["", "Numeric", "", "", ""];

    var f = document.ExcelDownFrm;
    if(!f){
            $(document.body).append("<form name='ExcelDownFrm' method='POST' target='_blank' />");
            f = document.ExcelDownFrm;
            
		    $(f).append("<input type='hidden' name='headerName' />");
		    $(f).append("<input type='hidden' name='headerKey' />");
		    $(f).append("<input type='hidden' name='headerType' />");
		    $(f).append("<input type='hidden' name='expListIDs' />");
		    $(f).append("<input type='hidden' name='title' />");
    }
    f.action = "/account/accountPortal/vendorExpenceExcelDownload.do";

    f.headerName.value = headerName.join("†");
    f.headerKey.value = headerKey.join(",")
    f.headerType.value = headerType.join("|");
    f.expListIDs.value = _expAppListIDs;
    f.title.value = encodeURIComponent("거래처지급_이체목록");

    f.submit();
}

function expAppListOpen(pObj) {
	var strExpAppListIDs = "";
	
	strExpAppListIDs = $(pObj).siblings("[tag=expAppListIDs]").val();
	
	if(strExpAppListIDs != "") {
		var sRequestType = "";
		var sURL = "/account/expenceApplication/ExpenceApplicationListViewPopup.do";
		var iWidth = 1070;
		var iHeight = 700;
		var iLeft = (window.screen.width / 2) - (iWidth / 2);
		var iTop= (window.screen.height / 2) - (iHeight / 2);
		
		var oForm = document.createElement("form");
		oForm.method = "POST";
		oForm.target = "form";
		oForm.action = sURL;
		oForm.style.display = "none";

		var oRequestType = document.createElement("input");
		var oExpAppListIDs = document.createElement("input");
			    
		oRequestType.type = "hidden";
		oExpAppListIDs.type = "hidden";
			    
		oRequestType.name = "RequestType";
		oExpAppListIDs.name = "expAppListIDs";
		
		if(pObj.name && pObj.name == 'list_doc') {
			oRequestType.value = "VENDOR";
		} else {
			if(pObj.id && pObj.id != "") {
				oRequestType.value = pObj.id.replace("_employee", "").toUpperCase();
			}
		}

		oExpAppListIDs.value = strExpAppListIDs;
		
		oForm.appendChild(oRequestType);
		oForm.appendChild(oExpAppListIDs);

		document.body.appendChild(oForm);
		
	    window.open("", "form", "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=1,width="+iWidth+",height="+iHeight+",left="+iLeft+",top="+iTop);
	    
	    oForm.submit();
	    oForm.remove();
	}
}

function apvLinkOpen(pObj) {
	var strProcessID = $(pObj).siblings("[name=process_id_rep]").val();
	
	if(strProcessID != "") {
		CFN_OpenWindow('/approval/approval_Form.do?mode=COMPLETE&processID='+strProcessID,'',1070, (window.screen.height - 100), 'scroll');
	}
}

var urName;
var urCode;
function OpenWinEmployee(pObj) {
	urName = $(pObj).parent().siblings("input[name=register_name_add]");
	urCode = $(pObj).parent().siblings("input[name=register_id_add]");
	
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B1","조직도",1000,580,"");
}

function Requester_CallBack(info) {
	var orgJson = $.parseJSON(info);
	var orgItem = orgJson.item[0];
	
	if(orgItem != undefined){
		$(urName).val(CFN_GetDicInfo(orgItem.DN));
		$(urCode).val(orgItem.AN);
	}
}


var sbName;
var sbCode;
function callStandardBriefPopup(pObj) {
	sbName = $(pObj).siblings("input[name=standard_brief_name_add]");
	sbCode = $(pObj).siblings("input[name=standard_brief_id_add]");
	
	Common.open("","standardBriefSearchPopup","표준적요",
			"/account/accountCommon/accountCommonPopup.do?popupID=standardBriefSearchPopup&popupName=StandardBriefSearchPopup&openerID=&callBackFunc=callStandardBriefCallBack",
			"1000px","700px","iframe",true,null,null,true);
}

function callStandardBriefCallBack(info) {
	sbName.val(info.StandardBriefName);
	sbCode.val(info.StandardBriefID);
}


var vdName;
var vdCode;
function callVendorPopup(pObj) {
	vdName = $(pObj).siblings("input[name=vendor_name_add]");
	vdCode = $(pObj).siblings("input[name=vendor_no_add]");

	
	Common.open("","vendorSearchPopup","거래처",
			"/account/accountCommon/accountCommonPopup.do?popupID=vendorSearchPopup&popupName=VendorSearchPopup&openerID=&isPE=N&callBackFunc=callVendorCallBack",
			"700px","630px","iframe",true,null,null,true);
}

function callVendorCallBack(info) {
	vdName.val(info.VendorName);
	vdCode.val(info.VendorNo);
}

function setAmount() {
	var corpCardSumAdd = 0;
	var autoSumAdd = 0;
	var normalSumAdd = 0;
	var cashSumAdd = 0;
	var accountSumAdd = 0;
	
	$("select[data-node-name^=pay_method]").each(function(i, obj) { 
		var payMethod = $(obj).val();
		var payAmount = $(obj).parent().parent().find("input[name*=amount_]").val();		
		
		switch(payMethod) {
		case "D": //법인카드
			corpCardSumAdd += Number(payAmount);
			break;
		case "A": //자동이체
			autoSumAdd += Number(payAmount);
			break;
		case "C": //일반이체
			normalSumAdd += Number(payAmount);
			break;
		case "G": //현금인출
			cashSumAdd += Number(payAmount);
			break;
		case "T": //계좌간이체
			accountSumAdd += Number(payAmount);
			break;
		}
	});
	
	// 직접 입력 항목(거래처 + 추가항목 + 계좌간이체) / 일반이체일 경우 + 직원 경비 내역 + 자금 지출 보고 내역
	corpCardSum = corpCardSumAdd;
	autoSum = autoSumAdd;
	normalSum = normalSumAdd + Number($("#employee_sum").val()) + Number($("#report_sum").val());
	cashSum = cashSumAdd;
	accountSum = accountSumAdd;
	
	setAmountField();
}

function setAmountField() {
	//지출형태 별 합계 영역
	$("#corpcard_sum").val(corpCardSum);
	$("#auto_sum").val(autoSum);
	$("#normal_sum").val(normalSum);
	$("#cash_sum").val(cashSum);
	$("#account_sum").val(accountSum);
	
	totalSum = Number(corpCardSum) + Number(autoSum) + Number(normalSum) + Number(cashSum) + Number(accountSum);
	
	$("#total_sum").val(totalSum);
	$("#total_pay_amount").val(totalSum);
	$("#TotalPayAmount").val(totalSum);
}

function setSame(obj, target) {	
	var myAmt = $(obj).val();
	$(obj).parent().parent().find("[name="+target+"]").val(myAmt);
	
	setAmount();
}