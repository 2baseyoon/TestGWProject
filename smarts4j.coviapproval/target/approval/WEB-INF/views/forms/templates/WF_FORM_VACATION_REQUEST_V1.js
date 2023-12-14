//양식별 다국어 정의 부분
var localLang_ko = {
    localLangItems : {
        selMessage: "●휴일이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_en = {
    localLangItems : {
        selMessage: "●vacation이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_ja = {
    localLangItems : {
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
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();

    //Subject 숨김처리
    $('#tblFormSubject').hide();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });

        //년도 선택 select 뒤
        if (typeof formJson.BodyContext != 'undefined') {
            $('#spanSelYear').html('&nbsp;년');
        }
        else {
            $('#spanSelYear').html('&nbsp;&nbsp;&nbsp;');
        }

        // table 개선 작업으로 임시 주석 처리
        //table
        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'R');
        }

        //특정 디자인 수정
        $('#VAC_REASON').removeAttr('style');

    }
    else {
        //debugger;

        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        //쓰기일 경우 후처리로 아래와 같이 값 변경
        //비상연락은 DB사용자 정보에서 가져오기
        //JAVA 버전에서는 세션에 사용자 번호가 들어오면 세션값으로 대체 
        //var phonNum = Common.GetObjectInfo('UR', formJson.oFormData.usid, 'AD_Mobile').Table[0].AD_Mobile;
        //document.getElementById("NUMBER").value = phonNum;

        //년도 선택 select 뒤
        $('#spanSelYear').html('&nbsp;&nbsp;&nbsp;');

        document.getElementById("InitiatedDate").value = formJson.AppInfo.svdt; // 재사용, 임시함에서 오늘날짜로 들어가게함.

      
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.dpnm, false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usnm, false);


            if (formJson.Request.mode == "DRAFT" && formJson.Request.gloct == "") {
                //JSON DATA
                //  var json_multi_data = '[{"_MULTI_VACATION_SDT":"","_MULTI_VACATION_EDT":"","_MULTI_DAYS":""}]';
                // XFORM.multirow.load(json_multi_data, 'json', '#tblVacInfo', 'W');
                //기간에 대한 validation 처리 추가
                validateVacDate();
                getData();
            }
            else {

                if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
                    XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'W');
                    getData();
                    //임시 기간 합 삽입처리
                    tempGetSum();
                }
            }

        }

        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined && JSON.stringify(formJson.BodyContext.tblVacInfo) != "{}" && formJson.BodyContext.tblVacInfo != undefined ) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'W');
        }
        else {
            XFORM.multirow.load('', 'json', '#tblVacInfo', 'W', { minLength: 1 });
        }
        //        else {

        //            if (typeof formJson.BodyContext != 'undefined') {
        //                XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'W');
        //                getData();
        //                //임시 기간 합 삽입처리
        //                tempGetSum();
        //            }
        //        }

    }

}

function setLabel() {

}

function setFormInfoDraft() {

}

function checkForm(bTempSave) {
    if (document.getElementById("Subject").value == "") {
        document.getElementById("Subject").value = CFN_GetDicInfo(getInfo("AppInfo.usnm")) + " - " + getInfo("FormInfo.FormName");
    }

    if (bTempSave) {
        return true;
    } else {
        //잔여 휴가일 체크 임시 주석 처리
        //테스트 후 살릴 것
        
        //        if ((document.getElementById("USE_DAYS").value == "" || document.getElementById("USE_DAYS").value <= 0)
        //            && (document.getElementsByName("VACATION_TYPE").value == "반차" || document.getElementById("VACATION_TYPE").value == "연차")) {
        //            Common.Warning(Common.GetDic("msg_apv_chk_vacation")); //잔여휴가일이 없습니다. 기안할 수 없습니다.
        //            return false;
        //        }else if ((parseFloat(document.getElementById("USE_DAYS").value) < parseFloat(document.getElementById("_MULTI_TOTAL_DAYS").value))
        //            && (document.getElementById("VACATION_TYPE").value != "경조" && document.getElementById("VACATION_TYPE").value != "기타")) {
        //            Common.Warning(Common.GetDic("msg_apv_chk_remain_vacation")); //잔여 연차일을 초과하였습니다.
        //            return false;
        //        }
        if (document.getElementById("USE_DAYS").value == "" || document.getElementById("USE_DAYS").value <= 0) {
            let len = $("select[name=VACATION_TYPE]").length;
            for (let i = 1; i < len; i++) {
                if ($("select[name=VACATION_TYPE]").eq(i).val() == "반차" || $("select[name=VACATION_TYPE]").eq(i).val() == "연차") {
                    Common.Warning(Common.GetDic("msg_apv_chk_vacation"));
                    return false;
                }
            }
        }else if(parseFloat(document.getElementById("USE_DAYS").value) < parseFloat(document.getElementById("_MULTI_TOTAL_DAYS").value)){
            let len = $("select[name=VACATION_TYPE]").length;
            for (let i = 1; i < len; i++) {
                if ($("select[name=VACATION_TYPE]").eq(i).val() != "경조" || $("select[name=VACATION_TYPE]").eq(i).val() != "기타") {
                    Common.Warning(Common.GetDic("msg_apv_chk_remain_vacation")); //잔여 연차일을 초과하였습니다.
                    return false;
                }
            }
        }else if (document.getElementById("DocClassName").value == '') {
            Common.Warning("문서분류를 입력하세요."); //제목을 입력하세요.
            //SUBJECT.focus();
            return false;
        } else if (document.getElementById("SaveTerm").value == '') {
            Common.Warning(Common.getDic("lbl_apv_InputRetention")); //보존년한을 선택하세요.
            return false;
        } //else if (document.getElementById("VAC_REASON").value == '') {
            //Common.Warning(Common.GetDic("msg_apv_chk_reason")); //사유를 입력해주세요.
            //return false;
            //}
        else if (document.getElementById("NUMBER").value == '') {
            Common.Warning(Common.getDic("msg_apv_chk_emergency_contact")); //비상연락처를 입력해주세요.
            return false;
        } //else if (document.getElementById("DEPUTY_NAME").value == '') {
            //Common.Warning(Common.GetDic("msg_apv_chk_job_agent")); //직무대행자를 입력해주세요.
            //return false;
            //}
        else {
            if (TermCheck()) {
                return EASY.check().result;
            }
            else {
                alert("입력하신 기간 확인 후 기안 하시기 바랍니다.");
            }
        }
        /*else if (sameYear()) {  //선택한 년도와 달력의 년도가 다른 경우
            //Common.Warning(Common.GetDic("msg_apv_chk_job_agent")); //직무대행자를 입력해주세요.
            Common.Warning("연차년도와 동일 년도의 날짜로 선택하시기 바랍니다. ");
            //totalDays();
            return false;

        } else {
            for (var i = 1; i < document.getElementsByName("_MULTI_VACATION_SDT").length; i++) {
                if (document.getElementById("VACATION_TYPE").value != "반차" && document.getElementById("VACATION_TYPE").value != "선반차") {
                    if (document.getElementsByName("_MULTI_VACATION_SDT")[i].value == "" || document.getElementsByName("_MULTI_VACATION_EDT")[i].value == "") {
                        Common.Warning(Common.GetDic("msg_apv_chk_vacation_time")); //휴가기간을 선택해주세요.
                        return false;
                    }
                }
                else {
                    if (document.getElementsByName("_MULTI_VACATION_SDT")[i].value == "") {
                        Common.Warning(Common.GetDic("msg_apv_chk_vacation_time")); //휴가기간을 선택해주세요.
                        return false;
                    }
                    else if (document.getElementById("VACATION_TYPE").value == "반차" || document.getElementById("VACATION_TYPE")[0].value == "선반차") {
                        document.getElementsByName("_MULTI_VACATION_EDT")[0].value = document.getElementsByName("_MULTI_VACATION_SDT")[0].value;
                    }
                }
            }

            return true;
        }
        */

    }
}

//기간에 대한 validation 처리 추가
function validateVacDate() {

    $('#tblVacInfo').on('change', '.multi-row [name=_MULTI_VACATION_EDT]', function () {
        var sdt = $(this).prev().prev().val().replace(/-/g, '');
        var edt = $(this).val().replace(/-/g, '');

        if (Number(sdt) > Number(edt)) {
            Common.Warning("시작일은 종료일보다 먼저 일 수 없습니다.");
            $(this).val('');
            $(this).parent().find('[name=_MULTI_DAYS]').val(''); //입력된 기간 일수 제거
            EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
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


//휴가일수 합 가져오기
function tempGetSum() {
    //var GetSum = $('#MULTI_TOTAL_DAYS').val();
    //totalPoints += $(this).val();
    //alert(totalPoints);
    $('#_MULTI_TOTAL_DAYS').val(formJson.BodyContext._MULTI_TOTAL_DAYS);

}

function calSDATEEDATE(obj) {
    // 현재 객채(input) 에서 제일 가까이 있는 tr을 찾음
    var tmpObj = $(obj).closest("tr");
    var m_index = $("input[name=_MULTI_VACATION_EDT]").index(obj);
    if ($(tmpObj).find("input[name=_MULTI_VACATION_SDT]").val() != "" && $(tmpObj).find("input[name=_MULTI_VACATION_EDT]").val() != "") {
        var SDATE = $(tmpObj).find("input[name=_MULTI_VACATION_SDT]").val().split('-');
        var EDATE = $(tmpObj).find("input[name=_MULTI_VACATION_EDT]").val().split('-');

        var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        var tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
        if (tmpday < 0) {
            alert("이전 일보다 전 입니다. 확인하여 주십시오.");
            $(tmpObj).find("input[name=_MULTI_VACATION_EDT]").val("");
            $(tmpObj).find("input[name=_MULTI_DAYS]").val("");
            EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
        }

        if (document.getElementsByName("VACATION_TYPE")[m_index].value == "반차" || document.getElementsByName("VACATION_TYPE")[m_index].value == "선반차") {

            if (parseInt(document.getElementsByName("_MULTI_VACATION_EDT")[m_index].value) >= parseInt(document.getElementsByName("_MULTI_VACATION_SDT")[m_index].value)) {
                alert("시작일 보다 종료일이 먼저일 수 없습니다. ");
                document.getElementsByName("_MULTI_VACATION_EDT")[m_index].value = "";
                document.getElementsByName("_MULTI_VACATION_SDT")[m_index].value = "";
                // EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
            }
        }

    }
}
var selectboxYear;
function getData() {

    /*//  if (document.getElementById("VACATION_TYPE").value == "연차" || document.getElementById("VACATION_TYPE").value == "반차") {
    var pXML = "usp_mcd_vacation_plan_apvForm_select";
    var aXML = "<param><name>UR_CODE</name><type>nvarchar</type><length>50</length><value><![CDATA[" + getInfo("usid") + "]]></value></param>";
    //   if (document.getElementById("VACATION_TYPE").value == "선연차" || document.getElementById("VACATION_TYPE").value == "선반차") {
    //   aXML += "<param><name>year</name><type>varchar</type><length>4</length><value><![CDATA[" + parseInt(document.getElementById("Sel_Year").value) + 1 + "]]></value></param>";
    // }
    //else {
    aXML += "<param><name>year</name><type>varchar</type><length>4</length><value><![CDATA[" + document.getElementById("Sel_Year").value + "]]></value></param>";
    //}
    var connectionname = "COVI_FLOW_SI_ConnectionString";
    var sXML = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql><type>sp</type>" + aXML + "</Items>";
    var szURL = "../getXMLQuery.aspx";

    CFN_CallAjax(szURL, sXML, function (data) {
        receiveHTTPGetData(data);
    }, false, "xml");*/
}
//else {
//    document.getElementById("VAC_DAYS").value = "";
//   document.getElementById("USE_DAYS").value = "";
// }
//}

//휴가 정보 초기화
function initVacInfoTable(obj) {
    var oHtml = '';
    var m_index = $("select[name=VACATION_TYPE]").index(obj);

    //multirow 삭제
    if (parseFloat($("#USE_DAYS").val()) >= 0.5 && (document.getElementsByName("VACATION_TYPE")[m_index].value == "선반차" || document.getElementsByName("VACATION_TYPE")[m_index].value == "선연차")) {
        alert("잔여 연차가 있을 경우 [" + document.getElementsByName("VACATION_TYPE")[m_index].value + "]를 선택하실 수 없습니다.");
        document.getElementsByName("VACATION_TYPE")[m_index].value = "연차";
        document.getElementsByName("_MULTI_DAYS")[m_index].value = "";
        return;
    }
    if (document.getElementsByName("VACATION_TYPE")[m_index].value == "반차" || document.getElementsByName("VACATION_TYPE")[m_index].value == "선반차") {

        oHtml += '<tr class="multi-row halfvac">';
        oHtml += '<td>';
        oHtml += '<input type="checkbox" class="multi-row-selector" />&nbsp;';
        oHtml += '<select data-type="rField" name="VACATION_TYPE" data-element-type="sel_d_v" style="width:10%;" onchange="initVacInfoTable(this);">'; //셀렉트 박스
        oHtml += '<option value="연차">연차</option>';

        if (document.getElementsByName("VACATION_TYPE")[m_index].value == "반차") {
            oHtml += '<option value="반차" selected>반차</option>';
        } else {
            oHtml += '<option value="반차">반차</option>';
        }
        oHtml += '<option value="선연차">선연차</option>';

        if (document.getElementsByName("VACATION_TYPE")[m_index].value == "선반차") {
            oHtml += '<option value="선반차" selected>선반차</option>';
        } else {
            oHtml += '<option value="선반차">선반차</option>';
        }
        oHtml += '<option value="경조">경조</option>';
        oHtml += '<option value="기타">기타</option>';
        oHtml += '</select> ';
        oHtml += '<input type="text" name="_MULTI_VACATION_SDT" data-type="rField" readonly="" data-pattern="date" title="시작일" onchange="calSDATEEDATE(this);" required/> ';
        oHtml += '<span>&nbsp;~&nbsp;</span>';
        oHtml += ' <input type="text" name="_MULTI_VACATION_EDT" data-type="rField" readonly="" data-pattern="date" title="종료일" onchange="calSDATEEDATE(this);" required />&nbsp;';
        oHtml += ' <b>(</b><input type="text" name="_MULTI_DAYS" data-type="rField" value="0.5" style="border:0px solid;width:20px;font-weight:bold;" readonly="readonly" class="sum-table-cell"/><b>일)</b>';
        oHtml += '</td>';
        oHtml += '</tr>';

        $('#tblVacInfo').find("tr").eq(m_index + 1).after(oHtml);
        $('#tblVacInfo').find("tr").eq(m_index + 1).remove();

        EASY.pattern($('#tblVacInfo'));

        $('#tblVacInfo .halfvac').on('change', '[name=_MULTI_VACATION_SDT]', function () {
            $(this).next().next().val($(this).val());

        });
        
        // [2017-01-03 modi] gbhwang
        //$("input[name=TOT_MULTI_TOTAL_DAYS]").val($("input[name=TOT_MULTI_TOTAL_DAYS]").val() == "" ? 0.5 : parseFloat($("input[name=TOT_MULTI_TOTAL_DAYS]").val()) + 0.5);
        var sum = 0.0;
        $("input[name=_MULTI_DAYS]").each(function (i) {
            if ($(this).val() == "") {
                return true;
            }

            sum += parseFloat($(this).val());
        })
        $("input[name=TOT_MULTI_TOTAL_DAYS]").val(sum);
    }

    else {

        document.getElementsByName("_MULTI_DAYS")[m_index].value = "";

        oHtml += '<tr class="multi-row multi-period">';
        oHtml += '<td>';
        oHtml += '<input type="checkbox" class="multi-row-selector" />&nbsp;';
        oHtml += '<select data-type="rField" name="VACATION_TYPE" data-element-type="sel_d_v" style="width:10%;" onchange="initVacInfoTable(this);">'; //셀렉트 박스

        if (document.getElementsByName("VACATION_TYPE")[m_index].value == "반차") {
            oHtml += '<option value="연차" selected>연차</option>';
        } else {
            oHtml += '<option value="연차">연차</option>';
        }
        oHtml += '<option value="반차">반차</option>';
        if (document.getElementsByName("VACATION_TYPE")[m_index].value == "선연차") {
            oHtml += '<option value="선연차" selected>선연차</option>';
        } else {
            oHtml += '<option value="선연차">선연차</option>';
        }
        oHtml += '<option value="선반차">선반차</option>';
        if (document.getElementsByName("VACATION_TYPE")[m_index].value == "경조") {
            oHtml += '<option value="경조" selected>경조</option>';
        } else {
            oHtml += '<option value="경조">경조</option>';
        }
        if (document.getElementsByName("VACATION_TYPE")[m_index].value == "기타") {
            oHtml += '<option value="기타" selected>기타</option>';
        } else {
            oHtml += '<option value="기타">기타</option>';
        }
        oHtml += '</select> ';
        oHtml += '<input type="text" name="_MULTI_VACATION_SDT" data-type="rField" readonly="" data-pattern="date" title="시작일" onchange="calSDATEEDATE(this);" required/> ';
        oHtml += '<span>&nbsp;~&nbsp;</span>';
        oHtml += ' <input type="text" name="_MULTI_VACATION_EDT" data-type="rField" readonly="" data-pattern="date" title="종료일" onchange="calSDATEEDATE(this);" required />&nbsp;';
        oHtml += ' <b>(</b><input type="text" name="_MULTI_DAYS" data-type="rField" class="sum-table-cell" value="" data-pattern="period" data-period-ref="_MULTI_VACATION_SDT,_MULTI_VACATION_EDT,1" style="border:0px solid;width:20px;font-weight:bold;" readonly="readonly" /><b>일)</b>';
        oHtml += '</td>';
        oHtml += '</tr>';

        $('#tblVacInfo').find("tr").eq(m_index + 1).after(oHtml);
        $('#tblVacInfo').find("tr").eq(m_index + 1).remove();
        EASY.pattern($('#tblVacInfo'));
    }

    //   
    //    $('#tblVacInfo .multi-row').remove();
    //    if (document.getElementsByName("VACATION_TYPE")[0].value == "반차" || document.getElementsByName("VACATION_TYPE")[0].value == "선반차") {
    //        oHtml += '<tr class="multi-row halfvac">';
    //        oHtml += '<td>';
    //        oHtml += '<input type="text" name="_MULTI_VACATION_SDT" data-type="rField" readonly="" data-pattern="date" required/>';
    //        oHtml += '<span>&nbsp;~&nbsp;</span>';
    //        oHtml += '<input type="text" name="_MULTI_VACATION_EDT" data-type="rField" readonly="readonly" required/>&nbsp;';
    //        oHtml += '<input type="text" name="_MULTI_DAYS" data-type="rField" value="0.5" style="border:0px solid;width:20px;"/>';
    //        oHtml += '</td>';
    //        oHtml += '</tr>';

    //        $('#tblVacInfo').append(oHtml);

    //        EASY.pattern($('#tblVacInfo'));

    //        //반차일 경우 초기일 종료일에 복사
    //        $('#tblVacInfo .halfvac').on('change', '[name=_MULTI_VACATION_SDT]', function () {
    //            $(this).next().next().val($(this).val());
    //           
    //           // $("input[name=_MULTI_VACATION_EDT").val($("input[name=_MULTI_VACATION_SDT").val());
    //            $("#_MULTI_TOTAL_DAYS").val(0.5);

    //        });

    //        $('#tblVacInfo .multi-row-add').hide();
    //        $('#tblVacInfo .multi-row-del').hide();
    //        getData();
    //    }
    //    else {
    //     $('#tblVacInfo .multi-row-add').show();
    //     $('#tblVacInfo .multi-row-del').show();
    //     var json_multi_data = '[{"VACATION_TYPE":"'+document.getElementsByName("VACATION_TYPE")[0].value +'","_MULTI_VACATION_SDT":"","_MULTI_VACATION_EDT":"","_MULTI_DAYS":""}]';

    //     XFORM.multirow.load(json_multi_data, 'json', '#tblVacInfo', 'W');
    //        EASY.pattern($('#tblVacInfo'));
    //        validateVacDate();
    //        getData();
    //    }
}

function receiveHTTPGetData(responseXMLdata) {
   /* var xmlReturn = responseXMLdata;
    var elmlist = $(xmlReturn).find("response > NewDataSet > Table");
    var vacday = "", atot = "", appday = "", appdayca = "", useday = "";
    $(elmlist).each(function () {
        vacday = $(this).find("VACDAY").text();//총 연차
        atot = $(this).find("ATot").text(); //잔여연차
        appday = $(this).find("DAYSREQ").text();//신청연차
        appdayca = $(this).find("DAYSCAN").text(); //취소연차
        useday = $(this).find("USEDAYS").text(); //취소연차

        if (atot == "") atot = "0.0";
    });

    if (vacday == "") {
        Common.Warning("해당 년도의 연차 사용 가능 일수가 등록되지 않았습니다. 관리자에게 문의하세요."); //잔여휴가일이 없습니다. 기안할 수 없습니다.
        $("[id=VAC_DAYS]").val("0");
        $("[id=USE_DAYS]").val("0");

    } else if (parseFloat(vacday - atot) <= 0) {
        Common.Warning(Common.GetDic("msg_apv_chk_vacation"));
        $("[id=VAC_DAYS]").val(parseFloat(vacday) + "일 (사용 연차 : " + (parseFloat(atot)) + ")");
        if (parseFloat(vacday) - (parseFloat(useday)) < 0) {
            Common.Warning("잔여 연차가 없습니다. 관리자에게 문의 하시기 바랍니다.");
            $("[id=USE_DAYS]").val("");
        } else {
            $("[id=USE_DAYS]").val(parseFloat(vacday) - (atot));
        }
    }
    else {
        $("[id=VAC_DAYS]").val(parseFloat(vacday) + "일 (사용 연차 : " + (parseFloat(atot)) + ")");
        if (parseFloat(vacday) - parseFloat(atot) < 0) {
            Common.Warning("잔여 연차가 없습니다. 관리자에게 문의 하시기 바랍니다.");
            $("[id=USE_DAYS]").val("");
        } else {
            $("[id=USE_DAYS]").val(parseFloat(vacday) - (atot));
        }
    }*/
}

//USE_DAY 가져오는 함수 끝 여기서 부터 선연차, 선반차 가져오는 함수 시작해야함

var objTxtSelect;
function OpenWinEmployee(szObject) {
    objTxtSelect = document.getElementById(szObject);
    objTxtSelect.value = "";
    
    /* 
    var sType = "B1";
    var sGroup = "N";
    var sTarget = "Y";
    var sCompany = "Y";
    var sSearchType = "";
    var sSearchText = "";
    var sSubSystem = "";
    XFN_OrgMapShow_WindowOpen("REQUEST_TEAM_LEADER", "bodytable_content", objTxtSelect.id, openID, "Requester_CallBack", sType, sGroup, sCompany, sTarget, sSubSystem, sSearchType, sSearchText);
	*/
   
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B1","조직도",1000,580,"");

}

function Requester_CallBack(pStrItemInfo) {
    var oJsonOrgMap = $.parseJSON(pStrItemInfo);
    var I_User = oJsonOrgMap.item[0];
 	
    if(I_User != undefined){
     if (getInfo("AppInfo.usid") != I_User.AN) {
         objTxtSelect.value = CFN_GetDicInfo(I_User.DN);
         document.getElementById("DEPUTY_CODE").value = I_User.EmpNo;
     }
     else {
         alert('직무대행자로 본인이 선택되었습니다.\r\n다시 선택하세요');
         //OpenWinEmployee();
     }
    }
}

function setBodyContext(sBodyContext) {
    
}

//본문 XML로 구성
function makeBodyContext() {

   	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("tblVacInfo", "rField"));
    return bodyContextObj;
}



//기간 체크
function TermCheck() {
    var vFirst_S = '';
    var vFirst_E = '';
    var vSecon_S = '';
    var vSecon_E = '';

    var ret = true;

    var len = $("input[name=_MULTI_VACATION_SDT]").length;


    for (var i = 1; i < len; i++) {

        if (ret == false) {
            break;
        }

        vFirst_S = $("input[name=_MULTI_VACATION_SDT]").eq(i).val(); //첫번째 행 시작일
        var vFirst_S_Year = vFirst_S.split("-")[0];
        var vFirst_S_Mon = vFirst_S.split("-")[1];
        var vFirst_S_day = vFirst_S.split("-")[2];
        var vFirst_S_Date = new Date(vFirst_S_Year, Number(vFirst_S_Mon)-1, vFirst_S_day);

        vFirst_E = $("input[name=_MULTI_VACATION_EDT]").eq(i).val(); //첫번째 행 종료일
        var vFirst_E_Year = vFirst_E.split("-")[0];
        var vFirst_E_Mon = vFirst_E.split("-")[1];
        var vFirst_E_day = vFirst_E.split("-")[2];
        var vFirst_E_Date = new Date(vFirst_E_Year, Number(vFirst_E_Mon)-1, vFirst_E_day);


        for (var j = i + 1; j < len; j++) {
            vSecon_S = $("input[name=_MULTI_VACATION_SDT]").eq(j).val();
            var vSecon_S_Year = vSecon_S.split("-")[0];
            var vSecon_S_Mon = vSecon_S.split("-")[1];
            var vSecon_S_day = vSecon_S.split("-")[2];
            var vSecon_S_Date = new Date(vSecon_S_Year, Number(vSecon_S_Mon)-1, vSecon_S_day);

            vSecon_E = $("input[name=_MULTI_VACATION_EDT]").eq(j).val();
            var vSecon_E_Year = vSecon_E.split("-")[0];
            var vSecon_E_Mon = vSecon_E.split("-")[1];
            var vSecon_E_day = vSecon_E.split("-")[2];
            var vSecon_E_Date = new Date(vSecon_E_Year, Number(vSecon_E_Mon)-1, vSecon_E_day);

            if (
           (vSecon_S_Date <= vFirst_S_Date && vSecon_E_Date >= vFirst_E_Date) ||
           (vSecon_S_Date <= vFirst_E_Date && vSecon_E_Date >= vFirst_E_Date) ||
           (vSecon_S_Date >= vFirst_S_Date && vSecon_E_Date <= vFirst_E_Date) ||
           (vSecon_S_Date <= vFirst_S_Date && vSecon_E_Date >= vFirst_E_Date)) {
                ret = false;
                break;
            }
        }

    }

    return ret;

}