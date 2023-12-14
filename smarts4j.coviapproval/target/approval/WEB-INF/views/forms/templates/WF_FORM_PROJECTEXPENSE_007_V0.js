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

/* 전역변수 */
var loadForm = true; // 양식 최초 로딩 여부


//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        //<!--loadMultiRow_Read-->
		
        if (JSON.stringify(formJson.BodyContext) != "{}") {

            //멀티로우
            hasBodyContext(formJson.BodyContext.TBL_TRAFFIC, "TBL_TRAFFIC", "R");
            hasBodyContext(formJson.BodyContext.TBL_LODGE, "TBL_LODGE", "R");
            hasBodyContext(formJson.BodyContext.TBL_OUTINGS, "TBL_OUTINGS", "R");
            hasBodyContext(formJson.BodyContext.TBL_EATING, "TBL_EATING", "R");
            hasBodyContext(formJson.BodyContext.TBL_WORKING, "TBL_WORKING", "R");
            hasBodyContext(formJson.BodyContext.TBL_ETC, "TBL_ETC", "R");
        }

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
			
        // 프로젝트명 셀렉트박스 옵션 가져오기
        getData(""); // 조건에 상관없이 가져와야 하므로

        // 에디터 처리
        //<!--AddWebEditor-->
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
			document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usid"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("InitiatedDate").value = getInfo("AppInfo.svdt");
			
            if (formJson.Request.mode == "DRAFT") {
                ExpenseSetting("0");
            }

			 // 임시저장 또는 재사용 시 저장하였던 프로젝트명 가져오기
            if (formJson.Request.mode == "TEMPSAVE" || getInfo("Request.reuse") == "Y" || getInfo("Request.reuse") == "P" || getInfo("Request.reuse") == "YH") {
                if (formJson.BodyContext.PROJECT_NAME != undefined) {
                    $("#PROJECT_NAME").val(formJson.BodyContext.PROJECT_NAME);
                }
            }

        }
        // 편집, 임시저장 또는 재사용 시 저장하였던 프로젝트명 가져오기
        if (formJson.Request.mode != "DRAFT") {
            if (formJson.BodyContext.PROJECT_NAME != undefined) {
                $("#PROJECT_NAME").val(formJson.BodyContext.PROJECT_NAME);     
            }
        }
     
        //<!--loadMultiRow_Write-->
        if (JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_TRAFFIC), 'json', '#TBL_TRAFFIC', 'W');
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_LODGE), 'json', '#TBL_LODGE', 'W');
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_OUTINGS), 'json', '#TBL_OUTINGS', 'W');
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_EATING), 'json', '#TBL_EATING', 'W');
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_WORKING), 'json', '#TBL_WORKING', 'W');
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_ETC), 'json', '#TBL_ETC', 'W');

            // 임시저장 후 로딩 시 활성화 여부 체크
            $("#TBL_TRAFFIC").find(".multi-row").each(function (i) {
                changeTrafficType($("#TBL_TRAFFIC").find(".multi-row").eq(0).find("select[name=TRAFFIC_TYPE]"));
            });
        } else {
            XFORM.multirow.load('', 'json', '#TBL_TRAFFIC', 'W', { minLength: 1 });
            XFORM.multirow.load('', 'json', '#TBL_LODGE', 'W', { minLength: 1 });
            XFORM.multirow.load('', 'json', '#TBL_OUTINGS', 'W', { minLength: 1 });
            XFORM.multirow.load('', 'json', '#TBL_EATING', 'W', { minLength: 1 });
            XFORM.multirow.load('', 'json', '#TBL_WORKING', 'W', { minLength: 1 });
            XFORM.multirow.load('', 'json', '#TBL_ETC', 'W', { minLength: 1 });
		}
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
    	if (!chkRequestYM()) {
            return false;
        }

        // 해당 행 데이터 입력 여부에 따라 입력 필드 모두 required 속성 주기
        $(".multi-row").each(function (i) {
            $(this).find("input[type='text'], select").each(function () {
                if ($(this).val() != "") {
                    $(this).closest("tr").find("input:enabled[type='text'], select").not("[name*='OTHER_CHARGE']").each(function (i) {
                        $(this).attr("required", "required");
                    });
                    return false;
                }
            });
        });
        
        // 필수 입력 필드 체크
        return EASY.check().result;
    }

}

/* 청구년월 선택에 따른 지출일 유효성 체크 */
function chkRequestYM() {
    var chkFail = true;
    
    // 청구년월 선택에 따른 지출일 유효성 체크
    $("[name*=DATE]").each(function (i, obj) {
        if ($(obj).val() != "") {
            if ($(obj).val().substring(5, 7) != getMonthFromRequestYM($("#REQUEST_YM").val())) {
                Common.Warning($(obj).attr("title") + "이 청구월에 포함되지 않습니다.<br/>다시 확인하여 입력해주시길 바랍니다.");
                chkFail = false;
            }
            else if ($(obj).val().substring(0, 4) != getYearFromRequestYM($("#REQUEST_YM").val())) {
                Common.Warning($(obj).attr("title") + "의 연도가 청구연도와 동일하지 않습니다.<br/>다시 확인하여 입력해주시길 바랍니다.");
                chkFail = false;
            }
            if (!chkFail) {
                return false;
            }
        }
    });

    return chkFail;
}

function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
    /*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";*/
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");

	// 해당 경비의 지출일을 입력한 경우에만 BODY_CONTEXT 구성
    $(".multi-row-table").each(function (i) {
        var tblname = $(this).attr("id");
        $(this).find("select:visible,input:visible").not("[type=checkbox]").each(function(idx,obj){
        	if($(obj).val()!=''){
        		$$(bodyContextObj["BodyContext"]).append(getMultiRowFields(tblname, "rField"));               
                return false;
        	}
        });
  
       /* 지출일이외에 무엇이라도 입력하면 BodyContext 구성하도록 변경
        $(this).find(".multi-row").not(".pattern-skip").each(function (i) {
            if ($(this).find("[name*='DATE']").eq(0).val() != "") {
           		$$(bodyContextObj["BodyContext"]).append(getMultiRowFields(tblname, "rField"));               
                return false;
            }
        });*/
    });
    
    return bodyContextObj;
}

/* BODY_CONTEXT 보유 여부에 따른 테이블 disply 여부 결정 */
function hasBodyContext(bodyContext, tblName, pageMode) {
    if (JSON.stringify(bodyContext) != "{}" && JSON.stringify(bodyContext) != undefined) {
        XFORM.multirow.load(JSON.stringify(bodyContext), 'json', "#" + tblName, pageMode);
    }
    else {
        $("#" + tblName).css("display", "none");
    }
}

/* DB 데이터(프로젝트명)를 불러오기 */
function getData(pvalue) {
	var Sel_id = "PROJECT_NAME";
    /*
    var connectionname = "COVI_FLOW_SI_ConnectionString";
    var pXML = "dbo.usp_select_projectname_gw";
    var param_1 = "WF_FORM_PROJECTEXPENSE_007";
    var aXML = "<param><name>appr_key</name><type>nvarchar</type><length>20</length><value><![CDATA[" + param_1 + "]]></value></param>";
    var sXML = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql><type>sp</type>" + aXML + "</Items>";
    var szURL = "../getXMLQuery.aspx";


    CFN_CallAjax(szURL, sXML, function (data) {
        receiveHTTPGetData_SapBaseCode_master(data, Sel_id, pvalue);
    }, false, "xml");
    */
	CFN_CallAjax("/approval/legacy/getProjectList.do", {"appr_key":"WF_FORM_PROJECTEXPENSE_007"}, function (data){ 
		receiveHTTPGetData_SapBaseCode_master(data, Sel_id, pvalue); 
	}, false, 'json');
}

/* getData()의 CallBack 함수 */
function receiveHTTPGetData_SapBaseCode_master(responseXMLdata, Sel_id, pvalue) {
    var xmlReturn = responseXMLdata;
    var elmlist = xmlReturn.Table;
    var Codegrp = '';

    $("select[id=" + Sel_id + "]").eq(0).append("<option value=''>선택</option>");
    $(elmlist).each(function () {
        //JOB_STATE_CD = G:회사일반 , P:프로젝트 , R:내부개발 , C:고객지원 , S:세일즈
        if (this.JOB_STATE_CD == "P") {
            $("select[id=" + Sel_id + "]").eq(0).append("<option value='" + this.JOB_NO + "'>" + this.JOB_NM + "</option>");
        }
    });
}
/* 프로젝트 명이 바뀔 때마다 제목 변경 */
function changeTitle() {
    var proName = $("#EXPENSE_BASIC_INFO").find("select[id=PROJECT_NAME] option:selected").text();

    // 프로젝트명 선택값이 '선택'일 경우
    if (proName == $("#EXPENSE_BASIC_INFO").find("select[id=PROJECT_NAME] option:eq(0)").text()) {
        proName = "";
    }
    if (formJson.Request.mode == "DRAFT" ){    	
    	document.getElementById("Subject").value = "[프로젝트 경비청구] " + $("#EXPENSE_BASIC_INFO").find("input[id=REQUEST_YM]").val() + " " + proName + " 프로젝트";
    }
}

/* 교통비 차종구분 선택값에 따른 셀 활성화 여부 체크*/
function changeTrafficType(obj) {
    var trobj = $(obj).closest("tr");
    var driveVal = "DRIVE";

    if ($(trobj).find("select[name='TRAFFIC_TYPE']").val() == driveVal) {
        $(trobj).find("input[name='TRAFFIC_DISTANCE']").removeAttr("disabled");
        $(trobj).find("input[name='TRAFFIC_CHARGE']").removeAttr("disabled");
    }
    else {
        if ($(trobj).find("input[name='TRAFFIC_CHARGE']").val() != "") {
            var trafficCharge = $(trobj).find("input[name='TRAFFIC_CHARGE']").val();
            var requestCharge = $(trobj).find("input[name='REQUEST_AMOUNT_TRAFFIC']").val();
            $(trobj).find("input[name='REQUEST_AMOUNT_TRAFFIC']").val(requestCharge - trafficCharge);
        }

        $(trobj).find("input[name='TRAFFIC_DISTANCE']").val("");
        $(trobj).find("input[name='TRAFFIC_DISTANCE']").attr("disabled", "disabled");
        $(trobj).find("input[name='TRAFFIC_CHARGE']").val("");
        $(trobj).find("input[name='TRAFFIC_CHARGE']").attr("disabled", "disabled");
    }
}

/* 운행거리에 따른 운행요금 계산 */
function calcTrafficCharge(obj) {
    var trobj = $(obj).closest("tr");
    var disPerPay = 250; // [2017-03-15] yjlee 300->250원으로 변경

    if ($(trobj).find("input[name='TRAFFIC_DISTANCE']").val() != "") {
        $(trobj).find('input[name="TRAFFIC_CHARGE"]').val($(obj).val() * disPerPay);
    }
    else {
        $(trobj).find('input[name="TRAFFIC_DISTANCE"]').val(0);
        $(trobj).find('input[name="TRAFFIC_CHARGE"]').val(0);
    }

    EASY.triggerFormChanged(); // 합계 초기화
}

/* 청구년월, 지출일, 제목 세팅 */
function ExpenseSetting(objType) {
    // 0 : REQUEST_YM, 1 : PROJECT_NAME
    if (objType == "0") {
    	setRequestYM();
    	setHidRequestYM();
    }

    changeTitle();
}

/* 청구년월 값에 따른 히든필드 값 변경 */
function setHidRequestYM() {
    var year = getYearFromRequestYM($("#REQUEST_YM").val());
    var month = getMonthFromRequestYM($("#REQUEST_YM").val());

    $("#REQUEST_Y").val(year);
    $("#REQUEST_M").val(month);
}

/* 청구년월 값 변경 */
function setRequestYM() {
    var year, month;

    if (loadForm) {
        var dateArr = formatDate(formJson.AppInfo.svdt, "M").split('.');
        year = dateArr[0];
        month = dateArr[1] - 1;

        loadForm = false;
    }
    else {
    	  year = getYearFromRequestYM($("#REQUEST_YM").val());
          month = getMonthFromRequestYM($("#REQUEST_YM").val());
    }

    $("#hd_TDATE").val((year + "-" + month).newDate().yyyymmdd());
    $("#REQUEST_YM").val($("#hd_TDATE").val().replace(/([0-9]{4})-([0-9]{2})-([0-9]{2})/, "$1년 $2월"));

    chkChangeDate();
}

/* 지출일 변경 여부 체크 */
function chkChangeDate() {
    var hasNotValue = true;

    $("input[name*='DATE']").each(function () {
        if ($(this).val() != "") {
            hasNotValue = false;
            return false;
        }
    });

    if (hasNotValue) {
        setExpenseDate();
    }
    else {
        Common.Confirm("작성된 지출일을 초기화하시겠습니까?", "청구년월 변경", function (responseConfirm) {
            if (responseConfirm) {
                setExpenseDate();
            }
        });
    }
}

/* 청구년월 선택에 따른 경비 지출일 초기화 */
function setExpenseDate(year, month) {
    var minDate = $("#hd_TDATE").val();
    var maxDate = new Date(minDate.split('-')[0], minDate.split('-')[1], 0).yyyymmdd();

    $("[name*=DATE]").each(function (i, obj) {
        if ($(this).val() != "") {
            $(this).val("");
        }
        
        // 달력 세팅 문제에 따른 주석 처리
        //$(this).attr("data-date-min", minDate);
        //$(this).attr("data-date-max", maxDate);
    });
}

/* 청구년월로부터 연도 리턴 */
function getYearFromRequestYM(str) {
    return str.substring(0, 4);
}

/* 청구년월로부터 월 리턴 */
function getMonthFromRequestYM(str) {
    return str.substring(6, 8);
}