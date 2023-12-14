//양식별 다국어 정의 부분
var localLang_ko = {
    localLangItems: {
        selMessage: "●휴일이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_en = {
    localLangItems: {
        selMessage: "●vacation이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_ja = {
    localLangItems: {
        selMessage: "●休日이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_zh = {
    localLangItems: {
        selMessage: "●休日이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
    //debugger;
    //공통영역
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            //직무대행 버튼 $('#spanBtnForDeputy').hide();
            //문서분류 버튼 $('#spanBtnForDocClass').hide();
            //휴가명 설명 $('#spanVacType').hide();
            $(this).hide();
        });

        $("#select_project_name").attr('colspan', 2);
        $("#input_self").attr('colspan', 4);

        if ($("#select_project_name span").text() == "직접 입력") {
            $("#select_project_code_th").hide();
            $("#select_project_code").hide();
            $("#select_project_name_th").css("width", "12%");
            $("#select_project_name").hide();
            $("#input_self").show();
            $("#input_self").css("width", "88%");
            $("#input_self").css("border-top", "1px solid #c3d7df");
        }

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            //<span id="CommentList" data-mode="readOnly" ></span>
            $(this).hide();
        });

        getData("");

        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
            var dateformat = document.getElementById("AppliedDate").value.replace(/([0-9]{4})-([0-9]{2})-([0-9]{2})/, "$1.$2.$3");
            document.getElementById("initiated").innerHTML = dateformat;
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("InitiatedDate").value = formJson.AppInfo.svdt; // 재사용, 임시함에서 오늘날짜로 들어가게함.
            

            // 임시저장 또는 재사용 시 저장하였던 프로젝트명 가져오기
            if (formJson.Request.mode == "TEMPSAVE" || getInfo("Request.reuse") == "Y" || getInfo("Request.reuse") == "P" || getInfo("Request.reuse") == "YH") {
                if (formJson.BodyContext.PROJECT_NAME != undefined) {
                    $("#PROJECT_NAME").val(formJson.BodyContext.PROJECT_NAME);
                    PROJECTNAME();
                }
            }
        }
        else {
        	// 편집, 임시저장 또는 재사용 시 저장하였던 프로젝트명 가져오기
            if (formJson.Request.mode != "DRAFT") {
                if (formJson.BodyContext.PROJECT_NAME != undefined) {
                    $("#PROJECT_NAME").val(formJson.BodyContext.PROJECT_NAME);
                    PROJECTNAME();
                }
            }
        }
    }

    //setLabel과 setBodyContext 정리 후 상단으로 이동

}

function setLabel() {
    
}
function setFormInfoDraft() {
    
}

function checkForm(bTempSave) {
    if (bTempSave) {
        return true;
    } else {
        if (document.getElementById("SaveTerm").value == '') {
            alert('보존년한을 선택하세요.');
            return false;
        } else if (document.getElementById("email_1").value == '' && document.getElementById("name_1").value != "") {
            alert("담당자 이메일을 입력하세요");
            return false;
        } else if (document.getElementById("email_2").value == '' && document.getElementById("name_2").value != "") {
            alert("담당자 이메일을 입력하세요");
            return false;
        }
        else if (document.getElementById("Subject").value == "") {
            alert("제목을 입력하세요");
            return false;
        }
        //else if (document.getElementById("orderTotal").value == "₩0") {
        //    alert("발주금액을 입력하세요");
        //    return false;
        //}
        else {
            document.getElementById("hangeul").value = NumToHangul1(removeMoney(document.getElementById("orderTotal").value.numeric()));
            return EASY.check().result;
        }
    }
}

function setBodyContext(sBodyContext) {
    
}

function sumMoney() {
    var temp = 0;
    var temp1, temp2;
    var Totalcost = 0;

    for (var i = 1; i <= 10; i++) {
        temp1 = CR(document.getElementById("unitCost_" + i).value);
        temp2 = CR(document.getElementById("amount_" + i).value);
        if (!isNaN(parseFloat(temp1)) && !isNaN(parseFloat(temp2))) {
            Totalcost = parseFloat(temp1) * parseFloat(temp2);
        }
        if (Totalcost == 0) {
            Totalcost = "";
        }
        //document.getElementById("sum_" + i).value = CnvtComma(Totalcost);
        document.getElementById("sum_" + i).value = Totalcost;
        Totalcost = 0;
    }
    //totalMoney();
}

//본문 XML로 구성
function makeBodyContext() {
	/*
	var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";
	
	return sBodyContext;
	*/
	
    var bodyContextObj = {};
	
	bodyContextObj["BodyContext"] = getFields("mField");
    return bodyContextObj;
}

// 숫자를 한글로 변환
function NumToHangul1(chknum) {
    var isMinus = false;

    if (chknum.indexOf('-') > -1) {
        chknum = chknum.substring(1, chknum.length);
        isMinus = true;
    }

    var val = chknum;
    var won = new Array();
    var re = /^[1-9][0-9]*$/;
    var num = val.toString().split(',').join('');

    if (!re.test(num)) {
        return '0';
    }
    else {
        var price_unit0 = new Array('', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구');
        var price_unit1 = new Array('', '십', '백', '천');
        var price_unit2 = new Array('', '만', '억', '조', '경', '해', '시', '양', '구', '간', '정');
        for (i = num.length - 1; i >= 0; i--) {
            won[i] = price_unit0[num.substr(num.length - 1 - i, 1)];
            if (i > 0 && won[i] != '') {
                won[i] += price_unit1[i % 4];
            }
            if (i % 4 == 0) {
                won[i] += price_unit2[(i / 4)];
            }
        }
        for (i = num.length - 1; i >= 0; i--) {
            if (won[i].length == 2) won[i - i % 4] += '-';
            if (won[i].length == 1 && i > 0) won[i] = '';
            if (i % 4 != 0) won[i] = won[i].replace('일', '');
        }

        won = won.reverse().join('').replace(/-+/g, '');

        if (won.toString().substr(0, 1) == '십') {
            won = '일' + won;
        }

        if (isMinus)
            return '-' + won;
        else
            return "일금 " + won + " 원정";
    }
}

function removeMoney(i) {
    i = i.replace('￦', '');
    return i;
}

function CR(strSrc) {
    return (strSrc.replace(/,/g, ""));
}

/************************************************************************
함수명		: CnvtComma
작성목적	: 빠져나갈때 포맷주기(123456 => 123,456)
*************************************************************************/
function CnvtComma(num) {
    try {
        var ns = num.toString();
        var dp;

        if (isNaN(ns))
            return "";

        dp = ns.search(/\./);

        if (dp < 0) dp = ns.length;

        dp -= 3;

        while (dp > 0) {
            ns = ns.substr(0, dp) + "," + ns.substr(dp);
            dp -= 3;
        }
        return ns;
    }
    catch (ex) {
    	coviCmn.traceLog(ex);
    }
}

//기간에 대한 validation 처리 추가
function validateVacDate() {

    $('#tblVacInfo .multi-row').on('change', '[name=_MULTI_VACATION_EDT]', function () {
        var sdt = $(this).prev().prev().val().replace(/-/g, '');
        var edt = $(this).val().replace(/-/g, '');

        if (Number(sdt) > Number(edt)) {
            Common.Warning("시작일은 종료일보다 먼저 일 수 없습니다.");
            $(this).val('');
        }

        var selectedYear = document.getElementById("Sel_Year").value;
        var clickedYear = $(this).val().split('-')[0];

        if (selectedYear != clickedYear && clickedYear != '') {
            Common.Warning("연차년도와 동일 년도의 날짜로 선택하시기 바랍니다. ");
            $(this).val('');
        }

    });

    $('#tblVacInfo .multi-row').on('change', '[name=_MULTI_VACATION_SDT]', function () {
        var selectedYear = document.getElementById("Sel_Year").value;
        var clickedYear = $(this).val().split('-')[0];

        if (selectedYear != clickedYear && clickedYear != '') {
            Common.Warning("연차년도와 동일 년도의 날짜로 선택하시기 바랍니다. ");
            $(this).val('');
        }

    });

}

//기간에 대한 validation 처리 추가
function validateVacDate() {

	var sdt = $('#CONTRACT_SDT').val().replace(/-/g, '');
	var edt = $('#CONTRACT_EDT').val().replace(/-/g, '');

	if (Number(sdt) > Number(edt)) {
		Common.Warning("시작일은 종료일보다 먼저 일 수 없습니다.");
		$('#CONTRACT_EDT').val('')
	}

}

/* DB 데이터(프로젝트명)를 불러옴 */
function getData(pvalue) {
    var Sel_id = "PROJECT_NAME";
    
    /*var connectionname = "COVI_FLOW_SI_ConnectionString";
    var pXML = "dbo.usp_select_projectname_gw";
    var param_1 = "WF_FORM_DRAFT_ORDER";
    var aXML = "<param><name>appr_key</name><type>nvarchar</type><length>20</length><value><![CDATA[" + param_1 + "]]></value></param>";
    var sXML = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql><type>sp</type>" + aXML + "</Items>";
    var szURL = "../getXMLQuery.aspx";
    */
    
  	CFN_CallAjax("/approval/legacy/getProjectList.do", {"appr_key":"WF_FORM_DRAFT_ORDER"}, function (data){ 
    	receiveHTTPGetData_SapBaseCode_master(data, Sel_id, pvalue); 
    },false,'json');
}

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
    $("select[id=" + Sel_id + "]").eq(0).append("<option value='input_self'>직접 입력</option>");
}



function PROJECTNAME() {
    //var project_name = $('#PROJECT_CODE').val();
    //$("#SUBJECT").val(m_oFormMenu.getLngLabel(getInfo("fmnm") + " - " + project_name, false));
    var project_name = $('#PROJECT_NAME option:selected').text();
    if (project_name == "직접 입력") {
        $("#input_self").show();
        $("#PROJECT_NAME_INPUT").prop('required', true);
        $("#PROJECT_NAME_INPUT").addClass("input-required");
        $("#PROJECT_CODE").val("");
    } else {
        $("#input_self").hide();
        $("#PROJECT_NAME_INPUT").prop('required', false);
        $("#PROJECT_NAME_INPUT").removeClass("input-required");
        $("#PROJECT_CODE").val($("#PROJECT_NAME option:selected").val());
        if(formJson.Request.mode == "DRAFT"){
        	$("#Subject").val(m_oFormMenu.getLngLabel(getInfo("FormInfo.FormName") + " - " + project_name, false));
        }
        $("#projectName").val($("#PROJECT_NAME option:selected").text()); // [16-12-07] kimhs, 결재 완료 후 [발주서 인쇄] 시 프로젝트명 출력되도록 수정
    }
}

function PROJECTNAME_INPUT() {
    $("#Subject").val(m_oFormMenu.getLngLabel(getInfo("FormInfo.FormName") + " - " + $("#PROJECT_NAME_INPUT").val(), false));
    $("#projectName").val($("#PROJECT_NAME_INPUT").val()); // [16-12-07] kimhs, 결재 완료 후 [발주서 인쇄] 시 프로젝트명 출력되도록 수정
}