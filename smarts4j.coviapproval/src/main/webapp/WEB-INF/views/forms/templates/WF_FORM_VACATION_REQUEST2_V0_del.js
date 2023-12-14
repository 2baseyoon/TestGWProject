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

var vacday = "", atot = "", appday = "", appdayca = "", useday = "";

//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
    //select box binding
    getBaseCode();
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
        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
            $('#spanSelYear').html('&nbsp;년');
        }
        else {
            $('#spanSelYear').html('&nbsp;&nbsp;&nbsp;');
        }

        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'R');
        }

        //특정 디자인 수정
        $('#VAC_REASON').removeAttr('style');


    }
    else {
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
                getData();
            }
            else {

                if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
                    XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'W');
                    getData();
                    tempGetSum();
                }
            }

        }

        if (JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'W');
        }
        else {
            XFORM.multirow.load('', 'json', '#tblVacInfo', 'W', { minLength: 1 });
        }
        
        // 편집모드일 경우, 반차에 대한 처리
        $("select[name=VACATION_TYPE]").each(function(i, obj){
        	if($(obj).val() == "VACATION_OFF"){
        		$($(obj).parent().parent()).find("input[name=_MULTI_DAYS]").attr("class", "sum-table-cell");
        		$($(obj).parent().parent()).find("input[name=_MULTI_DAYS]").removeAttr("data-period-ref");
        		$($(obj).parent().parent()).find("input[name=_MULTI_DAYS]").removeAttr("data-pattern");
        	}
        });

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
    	if(document.getElementsByName("_MULTI_VACATION_SDT").length <= 1){
    		Common.Warning("휴가 기간을 입력해주세요.");
    		return false;
    	}
    	
        // [2017-01-04 add] gbhwang 사용할 연차의 연도와 휴가 신청 기간의 연도 비교
        var isSame = true; // 사용할 연차의 연도와 휴가 신청 기간의 연도 동일 여부
        $("[name*=_MULTI_VACATION_]").each(function () {
            if ($(this).val() != "") {
                if ($(this).val().substring(0, 4) != $("#Sel_Year").val()) {
                    isSame = false;
                    return false;
                }
            }
        });

        if (!isSame) {
            Common.Warning("사용할 연차의 연도와 입력하신 기간의 연도가 상이합니다.");
            return false;
        }

        //[2016-06-29 modi kimjh] - 선연차, 연차 같이 사용
        //잔여 연차 일보다 신청 일수가 더 많을때
        
        //var oCodeList = Common.GetBaseCode("VACATION_TYPE"); 기초 코드가 개발되면 변경
        var oCodeList = $.parseJSON('{"CacheData":[{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_ANUUAL","Reserved1":"+","Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986212513)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREANUUAL","Reserved1":"+","Reserved2":"1","Reserved3":null,"ReservedInt":null,"CodeName":"선연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986332707)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREOFF","Reserved1":"+","Reserved2":"1","Reserved3":"0.5","ReservedInt":null,"CodeName":"선반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986256220)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_CONGRATULATIONS","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"경조","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1453857355243)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OFF","Reserved1":"+","Reserved2":null,"Reserved3":"0.5","ReservedInt":null,"CodeName":"반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451987876890)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OTHER","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"기타","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986308353)/"}]}');
        var CodeLen = oCodeList.CacheData.length;
        var Slen = $("select[name=VACATION_TYPE]").length;
        var sValue = 0.0; //선연차, 선번차 값 구하기
        var eValue = 0.0;//반차, 연차 값 구하기
        var eCodeName = "";
        for (var i = 1; i < Slen; i++) {
            for (var j = 0; j < CodeLen; j++) {
                if ($("select[name=VACATION_TYPE]").eq(i).val() == oCodeList.CacheData[j].Code) { // select box의 값과 code의 값이 같은지 비교
                    if (oCodeList.CacheData[j].Reserved1 == "+" && oCodeList.CacheData[j].Reserved2 != null) { //선연차, 선반차 일수 넣기
                        eCodeName += (eCodeName.indexOf(oCodeList.CacheData[j].CodeName) < 0 ? oCodeList.CacheData[j].CodeName + "," : "");
                        sValue += parseFloat($("input[name=_MULTI_DAYS]").eq(i).val());
                    }
                    if (oCodeList.CacheData[j].Reserved1 == "+" && oCodeList.CacheData[j].Reserved2 == null) { //그 외 가감 연차 일수 넣기

                        eValue += parseFloat($("input[name=_MULTI_DAYS]").eq(i).val());
                    }
                }
            }
        }
        if (parseFloat($('#USE_DAYS').val()) < eValue && $('#USE_DAYS').val() > 0) { //
            Common.Warning(Common.getDic("msg_apv_chk_remain_vacation")); //잔여 연차일을 초과하였습니다.
            return false;
        }
        if (sValue > 0.0 && parseFloat($('#USE_DAYS').val()) > eValue) {
            Common.Warning(Common.getDic("lbl_apv_vacation_remaining") + " [" + eCodeName.slice(0, -1) + "] " + Common.getDic("lbl_apv_vacation_remainingText"));
            //잔여 연차가 있을 경우 --- 를 선택하실 수 없습니다.
            return false;
        }
        if (document.getElementById("SaveTerm").value == '') {
            Common.Warning(Common.getDic("lbl_apv_InputRetention")); //보존년한을 선택하세요.
            return false;
        }
        else if (document.getElementById("NUMBER").value == '') {
            Common.Warning(Common.getDic("msg_apv_chk_emergency_contact")); //비상연락처를 입력해주세요.
            return false;
        }
        else {
            if (TermCheck()) {
                return EASY.check().result;
            }
            else {
                Common.Warning(Common.getDic("lbl_apv_vacation_remainingCheck"));//입력하신 기간 확인 후 기안 하시기 바랍니다.
            }
        }
    }

}

function setBodyContext(sBodyContext) {
}
//기간에 대한 validation 처리 추가
function validateVacDate() {

    $('#tblVacInfo').on('change', '.multi-row [name=_MULTI_VACATION_EDT]', function () {
        var sdt = $(this).prev().prev().val().replace(/-/g, '');
        var edt = $(this).val().replace(/-/g, '');

        if (Number(sdt) > Number(edt)) {
            Common.Warning("시작일 보다 종료일이 먼저일 수 없습니다");
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
    $('#_MULTI_TOTAL_DAYS').val(formJson.BodyContext._MULTI_TOTAL_DAYS);

}

function calSDATEEDATE(obj) {
    // 현재 객채(input) 에서 제일 가까이 있는 tr을 찾음
    //   var tmpObj = $(obj).closest("tr");
    var m_index;
    if (obj.name == "_MULTI_VACATION_EDT") {
        m_index = $("input[name=_MULTI_VACATION_EDT]").index(obj);
    } else {
        m_index = $("input[name=_MULTI_VACATION_SDT]").index(obj);
    }

    if ($("select[name=VACATION_TYPE]").eq(m_index).val == null) {
        alert(i + "번째 휴가 유형이 입력되지 않았습니다.");
    }

    if ($("input[name=_MULTI_VACATION_SDT]").eq(m_index).val() != "" && $("input[name=_MULTI_VACATION_EDT]").eq(m_index).val() != "") {
        var SDATE = $("input[name=_MULTI_VACATION_SDT]").eq(m_index).val().split('-');
        var EDATE = $("input[name=_MULTI_VACATION_EDT]").eq(m_index).val().split('-');

        var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        var tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);

        //반차일 경우
        if (document.getElementsByName("VACATION_TYPE")[m_index].value == "VACATION_BEFOREOFF" || document.getElementsByName("VACATION_TYPE")[m_index].value == "VACATION_OFF") {
            if (obj.name == "_MULTI_VACATION_EDT") {
                document.getElementsByName("_MULTI_VACATION_SDT")[m_index].value = document.getElementsByName("_MULTI_VACATION_EDT")[m_index].value;
            } else {
                document.getElementsByName("_MULTI_VACATION_EDT")[m_index].value = document.getElementsByName("_MULTI_VACATION_SDT")[m_index].value;
            }
        } else {
            if (tmpday < 0) {
                alert("이전 일보다 전 입니다. 확인하여 주십시오.");
                $("input[name=_MULTI_VACATION_EDT]").eq(m_index).val("");
                $("input[name=_MULTI_DAYS]").eq(m_index).val("");
                EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
            }
            //else {
            //    //잔여 연차 초과시
            //    var ch = checkTotalDays();
            //    if (ch == false) {
            //        $("input[name=_MULTI_VACATION_EDT]").eq(m_index).val("");
            //        $("input[name=_MULTI_DAYS]").eq(m_index).val("");
            //        EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
            //        Common.Warning(Common.getDic("msg_apv_chk_remain_vacation")); //잔여 연차일을 초과하였습니다.
            //    }
            //}
        }
    }
}


var selectboxYear;

function getData() {
	/*
    var pXML = "VM_PlanApvForm_R";
    var aXML = "<param><name>UR_CODE</name><type>nvarchar</type><length>50</length><value><![CDATA[" + getInfo("usid") + "]]></value></param>";
    aXML += "<param><name>year</name><type>varchar</type><length>4</length><value><![CDATA[" + document.getElementById("Sel_Year").value + "]]></value></param>";
    var connectionname = "COVI_FLOW_SI_ConnectionString";
    var sXML = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql><type>sp</type>" + aXML + "</Items>";
    var szURL = "../getXMLQuery.aspx";

    CFN_CallAjax(szURL, sXML, function (data) {
        receiveHTTPGetData(data);
    }, false, "xml");
    */
	 CFN_CallAjax("/approval/legacy/getVacationData.do", {"UR_CODE":getInfo("AppInfo.usid"),"year":document.getElementById("Sel_Year").value}, function (data){ 
    	 receiveHTTPGetData(data);
	}, false, 'json');
}

function initVacInfoTable(obj) {
    var oHtml = '';
    var m_index = $("select[name=VACATION_TYPE]").index(obj);

    // 그룹코드와 비사용중인 코드를 제외한 모든 코드를 가져옴.
    // var oCodeList = Common.GetBaseCode("VACATION_TYPE"); 기초 코드 개발 완료 후 변경 (하드코딩 삭제)
    var oCodeList = $.parseJSON('{"CacheData":[{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_ANUUAL","Reserved1":"+","Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986212513)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREANUUAL","Reserved1":"+","Reserved2":"1","Reserved3":null,"ReservedInt":null,"CodeName":"선연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986332707)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREOFF","Reserved1":"+","Reserved2":"1","Reserved3":"0.5","ReservedInt":null,"CodeName":"선반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986256220)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_CONGRATULATIONS","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"경조","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1453857355243)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OFF","Reserved1":"+","Reserved2":null,"Reserved3":"0.5","ReservedInt":null,"CodeName":"반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451987876890)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OTHER","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"기타","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986308353)/"}]}');
    var CodeLen = oCodeList.CacheData.length;

    //multirow 삭제
    //잔여연차 존재 시 선연차 사용 금지
    if (parseFloat($("#USE_DAYS").val()) - parseFloat($("#_MULTI_TOTAL_DAYS").val()) > 0.0) {
        for (var i = 0; i < CodeLen ; i++) {
            if (document.getElementsByName("VACATION_TYPE")[m_index].value == oCodeList.CacheData[i].Code) {
                if (oCodeList.CacheData[i].Reserved2 == null) { //선연차인지 비교
                }
                else {
                    alert("잔여 연차가 있을 경우 [" + oCodeList.CacheData[i].CodeName + "]를 선택하실 수 없습니다.");
                    document.getElementsByName("VACATION_TYPE")[m_index].value = "";
                    document.getElementsByName("_MULTI_DAYS")[m_index].value = "";
                    document.getElementsByName("_MULTI_VACATION_SDT")[m_index].value = "";
                    document.getElementsByName("_MULTI_VACATION_EDT")[m_index].value = "";
                    return;
                }
            }
        }

    }

    //반차일경우
    var halfvac = false;

    for (var i = 0; i < CodeLen ; i++) {
        if (document.getElementsByName("VACATION_TYPE")[m_index].value == oCodeList.CacheData[i].Code) {
            if (oCodeList.CacheData[i].Reserved3 != null && parseInt(oCodeList.CacheData[i].Reserved3) <= 0) {
                halfvac = true;
                break;
            }
        }
    }

    if (halfvac) {
        oHtml += '<tr class="multi-row halfvac">';
        oHtml += '<td>';
        oHtml += '<input type="checkbox" class="multi-row-selector" />&nbsp;';
        oHtml += '<select data-type="rField" name="VACATION_TYPE" data-element-type="sel_d_v" style="width:10%;" onchange="initVacInfoTable(this);" required title="휴가유형">&nbsp;'; //셀렉트 박스
        for (var j = 0; j < CodeLen; j++) {
            if (document.getElementsByName("VACATION_TYPE")[m_index].value == oCodeList.CacheData[j].Code) {
                oHtml += "<option value='" + oCodeList.CacheData[j].Code + "' selected>" + oCodeList.CacheData[j].CodeName + "</option>";
            } else {
                oHtml += "<option value='" + oCodeList.CacheData[j].Code + "'>" + oCodeList.CacheData[j].CodeName + "</option>";
            }
        }
        oHtml += '</select> ';
        oHtml += '<input type="text" name="_MULTI_VACATION_SDT" data-type="rField" readonly="" data-pattern="date" title="시작일" onchange="calSDATEEDATE(this);" required/> ';
        oHtml += '<span>&nbsp;~&nbsp;</span>';
        oHtml += ' <input type="text" name="_MULTI_VACATION_EDT" data-type="rField" readonly="" data-pattern="date" title="종료일" onchange="calSDATEEDATE(this);" required />&nbsp;';
        oHtml += ' <b>(</b><input type="text" name="_MULTI_DAYS" data-type="rField" value="' + oCodeList.CacheData[i].Reserved3 + '" style="border:0px solid;width:27px;font-weight:bold;" readonly="readonly" class="sum-table-cell"/><b>일)</b>';
        oHtml += '</td>';
        oHtml += '</tr>';

        $('#tblVacInfo').find("tr").eq(m_index + 1).after(oHtml);
        $('#tblVacInfo').find("tr").eq(m_index + 1).remove();

        EASY.pattern($('#tblVacInfo'));

        $('#tblVacInfo .halfvac').on('change', '[name=_MULTI_VACATION_SDT]', function () {
            $(this).next().next().val($(this).val());

        });

        // [2017-01-03 gbhwang] 연차 -> 반차 변경 시 기존 계산된 값에 선반차/반차(0.5) 누적 수정
        //$("input[name=TOT_MULTI_TOTAL_DAYS]").val($("input[name=TOT_MULTI_TOTAL_DAYS]").val() == "" ? parseFloat(oCodeList.CacheData[i].Reserved3) : parseFloat($("input[name=TOT_MULTI_TOTAL_DAYS]").val()) + parseFloat(oCodeList.CacheData[i].Reserved3));
        var sum = 0.0;
        $("input[name=_MULTI_DAYS]").each(function (i) {
            if ($(this).val() == "") {
                return true;
            }

            sum += parseFloat($(this).val());
        });
        $("input[name=TOT_MULTI_TOTAL_DAYS]").val(sum);
    }
        //반차가 아닐때
    else {

        document.getElementsByName("_MULTI_DAYS")[m_index].value = "";

        oHtml += '<tr class="multi-row multi-period">';
        oHtml += '<td>';
        oHtml += '<input type="checkbox" class="multi-row-selector" />&nbsp;';
        oHtml += '<select data-type="rField" name="VACATION_TYPE" data-element-type="sel_d_v" style="width:10%;" onchange="initVacInfoTable(this);" required title="휴가유형">'; //셀렉트 박스
        for (var j = 0; j < CodeLen; j++) {
            if (document.getElementsByName("VACATION_TYPE")[m_index].value == oCodeList.CacheData[j].Code) {
                oHtml += "<option value='" + oCodeList.CacheData[j].Code + "' selected>" + oCodeList.CacheData[j].CodeName + "</option>";
            } else {
                oHtml += "<option value='" + oCodeList.CacheData[j].Code + "'>" + oCodeList.CacheData[j].CodeName + "</option>";
            }
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
}

function receiveHTTPGetData(responseXMLdata) {
	var xmlReturn = responseXMLdata;
	var elmlist = responseXMLdata.Table;

	$(elmlist).each(function () {
	    vacday = this.VACDAY //총 연차
	    atot = this.ATot //잔여연차
	    appday = this.DAYSREQ //신청연차
	    appdayca = this.DAYSCAN //취소연차
	    useday = this.USEDAYS //사용연차
	    
	    if (atot == "") atot = "0.0";
	});

    if (vacday == "") {
        Common.Warning("해당 년도의 연차 사용 가능 일수가 등록되지 않았습니다. 관리자에게 문의하세요."); //잔여휴가일이 없습니다. 기안할 수 없습니다.
        $("[id=VAC_DAYS]").val("0");
        $("[id=USE_DAYS]").val("0");

    } else if (parseFloat(atot) <= 0) {
        Common.Warning(Common.getDic("msg_apv_chk_vacation")); //잔여 휴가일이 없습니다. 
        $("[id=VAC_DAYS]").val(parseFloat(vacday) + "일 (사용 연차 : " + (parseFloat(useday)) + ")");
        if (parseFloat(vacday) - (parseFloat(useday)) < 0) {
            Common.Warning("잔여 연차가 없습니다. 관리자에게 문의 하시기 바랍니다.");
            $("[id=USE_DAYS]").val(parseFloat(atot));
        } else {
            $("[id=USE_DAYS]").val(parseFloat(atot));
        }
    }
    else {
        $("[id=VAC_DAYS]").val(parseFloat(vacday) + "일 (사용 연차 : " + (parseFloat(useday)) + ")");
        if (parseFloat(vacday) - parseFloat(atot) < 0) {
            Common.Warning("잔여 연차가 없습니다. 관리자에게 문의 하시기 바랍니다.");
            $("[id=USE_DAYS]").val(parseFloat(atot));
        } else {
            $("[id=USE_DAYS]").val(parseFloat(atot));
        }
    }
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
   /*
   	var oXmlOrgMap = $.parseXML("<?xml version='1.0' encoding='utf-8'?>" + pStrItemInfo);
    var l_User = $(oXmlOrgMap).find('ItemInfo[type=User]').eq(0);

    if (getInfo("usid") != $(l_User).find("UR_Code").eq(0).text()) {
        objTxtSelect.value = CFN_GetDicInfo($(l_User).find('ExDisplayName').eq(0).text());
        document.getElementById("DEPUTY_CODE").value = $(l_User).find("EmpNo").eq(0).text();
    }
    else {
        alert('직무대행자로 본인이 선택되었습니다.\r\n다시 선택하세요');
        OpenWinEmployee('DEPUTY_NAME');
    }
    */
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

function getBaseCode() {
    // 그룹코드와 비사용중인 코드를 제외한 모든 코드를 가져옴.
    //var oCodeList = Common.GetBaseCode("VACATION_TYPE"); 기초 코드 개발 완료후 변경
    var oCodeList = $.parseJSON('{"CacheData":[{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_ANUUAL","Reserved1":"+","Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986212513)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREANUUAL","Reserved1":"+","Reserved2":"1","Reserved3":null,"ReservedInt":null,"CodeName":"선연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986332707)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREOFF","Reserved1":"+","Reserved2":"1","Reserved3":"0.5","ReservedInt":null,"CodeName":"선반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986256220)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_CONGRATULATIONS","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"경조","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1453857355243)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OFF","Reserved1":"+","Reserved2":null,"Reserved3":"0.5","ReservedInt":null,"CodeName":"반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451987876890)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OTHER","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"기타","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986308353)/"}]}');
    var Len = oCodeList.CacheData.length;
    var vCodeName = oCodeList.CacheData[0].Code;

    $("select[name=VACATION_TYPE] option").remove();

    for (var i = 0; i < Len; i++) {

        $("select[name=VACATION_TYPE]").append("<option value='" + oCodeList.CacheData[i].Code + "'>" + oCodeList.CacheData[i].CodeName + "</option>");
    }
}

function checkTotalDays() {
    //잔여 연차 일보다 신청 일수가 더 많을때
    // var oCodeList = Common.GetBaseCode("VACATION_TYPE"); 기초 코드 개발 완료후 하드 코딩 삭제
    var oCodeList = $.parseJSON('{"CacheData":[{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_ANUUAL","Reserved1":"+","Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986212513)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREANUUAL","Reserved1":"+","Reserved2":"1","Reserved3":null,"ReservedInt":null,"CodeName":"선연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986332707)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREOFF","Reserved1":"+","Reserved2":"1","Reserved3":"0.5","ReservedInt":null,"CodeName":"선반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986256220)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_CONGRATULATIONS","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"경조","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1453857355243)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OFF","Reserved1":"+","Reserved2":null,"Reserved3":"0.5","ReservedInt":null,"CodeName":"반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451987876890)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OTHER","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"기타","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986308353)/"}]}');
    var CodeLen = oCodeList.CacheData.length;
    var Slen = $("select[name=VACATION_TYPE]").length;
    var sValue = 0.0; //총 가감
    for (var i = 1; i < Slen; i++) {
        for (var j = 0; j < CodeLen; j++) {
            if ($("select[name=VACATION_TYPE]").eq(i).val() == oCodeList.CacheData[j].Code) { // select box의 값과 code의 값이 같은지 비교
                if (oCodeList.CacheData[j].Reserved1 == "+" && oCodeList.CacheData[j].Reserved2 == null) { //가감이 있는지 없는지 비교
                    sValue += parseFloat($("input[name=_MULTI_DAYS]").eq(i).val());
                }
            }
        }
    }

    //총 잔여연차보다 신청연차가 더 많을때
    if (parseFloat(document.getElementById("USE_DAYS").value) - parseFloat(document.getElementById("_MULTI_TOTAL_DAYS").value) < 0 && parseFloat(document.getElementById("USE_DAYS").value) - sValue < 0) {
        return false;
    } else {
        return true;
    }
}

