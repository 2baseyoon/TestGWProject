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
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();

    //Subject 숨김처리
    $('#tblFormSubject').hide();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
            getBaseCode();
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'R', { minLength: 1 });

            // [2016-01-05] gbhwang 'VACATION_OTHER|VACATION_OTHER'와 같이 VACATION_TYPE의 값이 배열인 경우 '연차'로 보이는 오류 수정
            if (typeof formJson.BodyContext.tblVacInfo.VACATION_TYPE != 'String') {
                $("span[name=VACATION_TYPE]").html(formJson.BodyContext.tblVacInfo.VACATION_TYPE_TEXT);
            }
        } else {
            getBaseCode();
            XFORM.multirow.load('', 'json', '#tblVacInfo', 'R');
        }


    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
        // 에디터 처리


        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
        	document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);
            document.getElementById("InitiatedDate").value = formJson.AppInfo.svdt; // 재사용, 임시함에서 오늘날짜로 들어가게함.
            
            if (CFN_GetQueryString("RequestFormInstID") != "undefined") {
                // [2017-01-10 add]
                $("#HID_REQUEST_FIID").val(CFN_GetQueryString("RequestFormInstID"));
                getVacationpRequestDate();
            } else {
                getBaseCode();
                if (formJson.Request.mode == "DRAFT" && formJson.Request.gloct == "") {
                    XFORM.multirow.load("", 'json', '#tblVacInfo', 'W', { minLength: 1 });
                }
                else {

                    if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
                        XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'W', { minLength: 1 });
                    }
                }
            }
            getData();
        } else {
            if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
                // [2016-01-05 add] gbhwang 수신부서 내용변경하는 경우 select box값이 로딩되지 않으므로 호출
                getBaseCode();
                XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'W', { minLength: 1 });

                // [2016-01-05 add] gbhwang 'VACATION_OTHER|VACATION_OTHER'와 같이 VACATION_TYPE의 값이 배열인 경우 '연차'로 보이는 오류 수정
                if (typeof formJson.BodyContext.tblVacInfo.VACATION_TYPE != 'String') {
                    $("select[name=VACATION_TYPE]").val(formJson.BodyContext.tblVacInfo.VACATION_TYPE[0]);
                }
            }
        }


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
    	
        // [2017-01-04 add] gbhwang 연차, 반차, 선연차, 선반차 외 사용 연차가 없어도 기안 가능하도록 조건 체크
        var canDraft = true; // 기안 가능 여부
        
        //var oCodeList = Common.GetBaseCode("VACATION_TYPE"); 기초 설정이 개발되면 변경
        var oCodeList = $.parseJSON('{"CacheData":[{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_ANUUAL","Reserved1":"+","Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986212513)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREANUUAL","Reserved1":"+","Reserved2":"1","Reserved3":null,"ReservedInt":null,"CodeName":"선연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986332707)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREOFF","Reserved1":"+","Reserved2":"1","Reserved3":"0.5","ReservedInt":null,"CodeName":"선반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986256220)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_CONGRATULATIONS","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"경조","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1453857355243)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OFF","Reserved1":"+","Reserved2":null,"Reserved3":"0.5","ReservedInt":null,"CodeName":"반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451987876890)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OTHER","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"기타","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986308353)/"}]}');
        

        $(".multi-row").find("select[name='VACATION_TYPE'] option:selected").each(function (i) {
            for (var i = 0; i < oCodeList.CacheData.length ; i++) {
                if ($(this).val() == oCodeList.CacheData[i].Code) {
                    if (oCodeList.CacheData[i].Reserved1 == "+") {
                        canDraft = false;
                        break;
                    }
                }
            }
            if (!canDraft) {
                return false;
            }
        });

        // [2017-01-05 add] gbhwang 사용할 연차의 연도와 휴가 신청 기간의 연도 비교
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
            Common.Warning("취소할 연차의 연도와 입력하신 기간의 연도가 상이합니다.");
            return false;
        }

        // 필수 입력 필드 체크
        if (document.getElementById("USE_DAYS").value == "" || parseFloat(document.getElementById("USE_DAYS").value) > parseFloat($("#TotalVac").val())) {
            var len = $("select[name=VACATION_TYPE]").length;
            for (var i = 1; i < len; i++) {
                if ($("select[name=VACATION_TYPE]").eq(i).val() == "반차" || $("select[name=VACATION_TYPE]").eq(i).val() == "연차") {
                    Common.Warning("총 연차일을 초과하였습니다. ");
                    return false;
                }
            }
        }
        // [2017-01-04 gbhwang] 연차, 반차, 선연차, 선반차 제외 경우 사용 연차가 없어도 기안 가능하도록 조건 추가
        else if (parseInt(useday) == 0 && !canDraft) {
        	var noVacation = false;
        	var len = $("select[name=VACATION_TYPE]").length;
            for (var i = 1; i < len; i++) {
                if ($("select[name=VACATION_TYPE]").eq(i).val() == "반차" || $("select[name=VACATION_TYPE]").eq(i).val() == "연차") {
                	noVacation = true;
                }
            }
        	if(noVacation){
	            Common.Warning("연차와 반차에 대해서, 해당 년도의 연차 취소 가능 일수가 없습니다.");
	            return false;
        	}
        }
        if (TermCheck()) {
            return EASY.check().result;
        }
        else {
            alert("입력하신 기간 확인 후 기안 하시기 바랍니다.");
        }
    }
}

function setBodyContext(sBodyContext) {
}


//본문 XML로 구성
function makeBodyContext() {
  /*  var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + getMultiRowFields("tblVacInfo", "rField") + "</BODY_CONTEXT>";
    return sBodyContext;*/
    
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
        var vFirst_S_Date = new Date(vFirst_S_Year, vFirst_S_Mon, vFirst_S_day);

        vFirst_E = $("input[name=_MULTI_VACATION_EDT]").eq(i).val(); //첫번째 행 종료일
        var vFirst_E_Year = vFirst_E.split("-")[0];
        var vFirst_E_Mon = vFirst_E.split("-")[1];
        var vFirst_E_day = vFirst_E.split("-")[2];
        var vFirst_E_Date = new Date(vFirst_E_Year, vFirst_E_Mon, vFirst_E_day);


        for (var j = i + 1; j < len; j++) {
            vSecon_S = $("input[name=_MULTI_VACATION_SDT]").eq(j).val();
            var vSecon_S_Year = vSecon_S.split("-")[0];
            var vSecon_S_Mon = vSecon_S.split("-")[1];
            var vSecon_S_day = vSecon_S.split("-")[2];
            var vSecon_S_Date = new Date(vSecon_S_Year, vSecon_S_Mon, vSecon_S_day);

            vSecon_E = $("input[name=_MULTI_VACATION_EDT]").eq(j).val();
            var vSecon_E_Year = vSecon_E.split("-")[0];
            var vSecon_E_Mon = vSecon_E.split("-")[1];
            var vSecon_E_day = vSecon_E.split("-")[2];
            var vSecon_E_Date = new Date(vSecon_E_Year, vSecon_E_Mon, vSecon_E_day);

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

function getVacationpRequestDate() {
	/*
    var connectionname = "FORM_INST_ConnectionString";
    var pXML = "SELECT FORM_INST_ID,SUBJECT,BODY_CONTEXT FROM [COVI_FLOW_FORM_INST].[dbo].[WF_FORM_INSTANCE] where FORM_INST_ID='" + $("#HID_REQUEST_FIID").val() + "' ";
    var aXML = "";
    var sXML = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql>" + aXML + "</Items>";

    var szURL = "../GetXMLQuery.aspx";
    CFN_CallAjax(szURL, sXML, function (data) {
        receiveHTTPState(data);
    }, false, "xml");
    */
	
	CFN_CallAjax("/approval/legacy/getFormInstData.do", {"FormInstID":$("#HID_REQUEST_FIID").val()}, function (data){ 
		receiveHTTPState(data); 
	}, false, 'json');

}

function receiveHTTPState(dataresponseXML) {
	
    var xmlReturn = dataresponseXML.Table;
    var errorNode = dataresponseXML.error;
    if (errorNode != null && errorNode != undefined) {
        Common.Error("Desc: " + $(errorNode).text());
    } else {
        $(xmlReturn).each(function (i, elm) {
            SetData(elm.BodyContext);
        });
    }
}

// 리턴받은 XML을 json으로 변환 후 일반데이터와 멀티로우 데이터를 매핑시켜주는 작업
// 파라미터
// pData : XML 데이터
function SetData(pData) {
   /* var pBodyData_xml = XFN_ChangeOutputValue(pData); //.toString().replace(/<!\[CDATA\[/gi, "").replace(/\]\]>/gi, "")
    var x2js = new X2JS();

    var jsonObj = x2js.xml_str2json(pData); // xml을 json으로 변경하기
    var ones = $(pBodyData_xml).children().not("tblVacInfo")*/
	
	 var jsonObj = $.parseJSON(Base64.b64_to_utf8(pData)); // xml을 json으로 변경하기
	 var ones = $$(Base64.b64_to_utf8(pData)).remove("tblVacInfo").json();
	
    // 그룹코드와 비사용중인 코드를 제외한 모든 코드를 가져옴.
    //var oCodeList = Common.GetBaseCode("VACATION_TYPE"); 기초 설정이 개발되면 변경
    var oCodeList = $.parseJSON('{"CacheData":[{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_ANUUAL","Reserved1":"+","Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986212513)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREANUUAL","Reserved1":"+","Reserved2":"1","Reserved3":null,"ReservedInt":null,"CodeName":"선연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986332707)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREOFF","Reserved1":"+","Reserved2":"1","Reserved3":"0.5","ReservedInt":null,"CodeName":"선반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986256220)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_CONGRATULATIONS","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"경조","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1453857355243)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OFF","Reserved1":"+","Reserved2":null,"Reserved3":"0.5","ReservedInt":null,"CodeName":"반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451987876890)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OTHER","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"기타","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986308353)/"}]}');
    
    var Len = oCodeList.CacheData.length;
    var vCodeName = oCodeList.CacheData[0].Code;

    var i;

    // 최 하위노드를 찾아서 mField 에 매핑tblVacInfo
    GetLastNode(ones);

    //멀티로우 Table 값 매핑
    XFORM.multirow.load(JSON.stringify(jsonObj.tblVacInfo), "json", "#tblVacInfo", 'W');

    //총 일 구하기
    var list = $.parseJSON(JSON.stringify(jsonObj.tblVacInfo));
    var listLen = list.length;
    if (listLen == undefined) {
        listLen = 1;
    }
    var contentStr = 0;
    var sValue = '';
    if (listLen == 1) {
        contentStr += parseFloat($.parseJSON(JSON.stringify(jsonObj.tblVacInfo._MULTI_DAYS)));
        // contentStr += parseFloat(list._MULTI_DAYS);
        sValue = $.parseJSON(JSON.stringify(jsonObj.tblVacInfo.VACATION_TYPE));
        for (var j = 0; j < Len; j++) {
            if ($("input[name=VACATION_TYPE]").eq(1).val() == oCodeList.CacheData[j].Code) {
                $("select[name=VACATION_TYPE]").eq(1).append("<option value='" + oCodeList.CacheData[j].Code + "' selected>" + oCodeList.CacheData[j].CodeName + "</option>");
            } else {
                $("select[name=VACATION_TYPE]").eq(1).append("<option value='" + oCodeList.CacheData[j].Code + "'>" + oCodeList.CacheData[j].CodeName + "</option>");
            }
        }

    } else {
        for (i = 0; i < listLen; i++) {
            contentStr += parseFloat(list[i]._MULTI_DAYS);
            for (var j = 0; j < Len; j++) {
                if ($("input[name=VACATION_TYPE]").eq(i + 1).val() == oCodeList.CacheData[j].Code) {
                    $("select[name=VACATION_TYPE]").eq(i + 1).append("<option value='" + oCodeList.CacheData[j].Code + "' selected>" + oCodeList.CacheData[j].CodeName + "</option>");
                } else {
                    $("select[name=VACATION_TYPE]").eq(i + 1).append("<option value='" + oCodeList.CacheData[j].Code + "'>" + oCodeList.CacheData[j].CodeName + "</option>");
                }
            }
        }
    }
    $("#_MULTI_TOTAL_DAYS").val(contentStr);
}

function GetLastNode(obj) {
	
	for(var key in obj){
		if($$(obj).find(key).valLength()>0){
			GetLastNode($$(obj).find(key).json());
		}else{
			$("[id=" + key.toUpperCase() + "]").val($$(obj).attr(key));
	        $("[id=" + key.toUpperCase() + "]").text($$(obj).attr(key));
		}
		
	}
	
   /*$(obj).each(function () {
        if ($(this).children().length > 0) {
            GetLastNode($(this).children());
        }
        else {
            $("[id=" + this.tagName + "]").val($(this).text());
            $("[id=" + this.tagName + "]").text($(this).text());
        }
    });*/
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


//휴가 정보 초기화
function initVacInfoTable(obj) {
    var oHtml = '';
    var m_index = $("select[name=VACATION_TYPE]").index(obj);

    //alert(document.getElementsByName("VACATION_TYPE")[m_index]);
    // alert($("select[name=VACATION_TYPE]").eq(m_index).option.Index($("select[name=VACATION_TYPE]").eq(m_index).option.selected));

    // 그룹코드와 비사용중인 코드를 제외한 모든 코드를 가져옴.
    //var oCodeList = Common.GetBaseCode("VACATION_TYPE"); 기초 설정이 개발되면 변경
    var oCodeList = $.parseJSON('{"CacheData":[{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_ANUUAL","Reserved1":"+","Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986212513)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREANUUAL","Reserved1":"+","Reserved2":"1","Reserved3":null,"ReservedInt":null,"CodeName":"선연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986332707)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREOFF","Reserved1":"+","Reserved2":"1","Reserved3":"0.5","ReservedInt":null,"CodeName":"선반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986256220)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_CONGRATULATIONS","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"경조","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1453857355243)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OFF","Reserved1":"+","Reserved2":null,"Reserved3":"0.5","ReservedInt":null,"CodeName":"반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451987876890)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OTHER","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"기타","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986308353)/"}]}');
   
    var CodeLen = oCodeList.CacheData.length;

    //multirow 삭제
    //if (parseFloat($("#USE_DAYS").val()) >= 0.5 && (document.getElementsByName("VACATION_TYPE")[m_index].value == "VACATION_OFF" || document.getElementsByName("VACATION_BEFOREANNUAL")[m_index].value == "선연차")) {
    //    alert("잔여 연차가 있을 경우 [" + document.getElementsByName("VACATION_TYPE")[m_index].value + "]를 선택하실 수 없습니다.");
    //    document.getElementsByName("VACATION_TYPE")[m_index].value = "연차";
    //    document.getElementsByName("_MULTI_DAYS")[m_index].value = "";
    //    return;
    //}

    var halfvac = false;

    for (var i = 0; i < CodeLen ; i++) {
        if ($("select[name=VACATION_TYPE]").eq(m_index).val() == oCodeList.CacheData[i].Code) {
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
        oHtml += '<select data-type="rField" name="VACATION_TYPE" data-element-type="sel_d_v" style="width:10%;" onchange="initVacInfoTable(this);" required title="휴가유형">'; //셀렉트 박스
        for (var j = 0; j < CodeLen; j++) {
            if ($("select[name=VACATION_TYPE]").eq(m_index).val() == oCodeList.CacheData[j].Code) {
                oHtml += "<option value='" + oCodeList.CacheData[j].Code + "' selected>" + oCodeList.CacheData[j].CodeName + "</option>";
            } else {
                oHtml += "<option value='" + oCodeList.CacheData[j].Code + "'>" + oCodeList.CacheData[j].CodeName + "</option>";
            }
        }

        oHtml += '<input type="text" name="_MULTI_VACATION_SDT" data-type="rField" readonly="" data-pattern="date" title="시작일" onchange="calSDATEEDATE(this);" required/> ';
        oHtml += '<span>&nbsp;~&nbsp;</span>';
        oHtml += ' <input type="text" name="_MULTI_VACATION_EDT" data-type="rField" readonly="" data-pattern="date" title="종료일" onchange="calSDATEEDATE(this);" required />&nbsp;';
        oHtml += ' <b>(</b>-<input type="text" name="_MULTI_DAYS" data-type="rField" value="' + oCodeList.CacheData[i].Reserved3 + '" style="border:0px solid;width:27px;font-weight:bold;" readonly="readonly" class="sum-table-cell"/><b>일)</b>';
        oHtml += '</td>';
        oHtml += '</tr>';

        $('#tblVacInfo').find("tr").eq(m_index + 1).after(oHtml);
        $('#tblVacInfo').find("tr").eq(m_index + 1).remove();

        EASY.pattern($('#tblVacInfo'));

        $('#tblVacInfo .halfvac').on('change', '[name=_MULTI_VACATION_SDT]', function () {
            $(this).next().next().val($(this).val());

        });

        // [2017-01-04 gbhwang] 연차 -> 반차 변경 시 기존 계산된 값에 선반차/반차(0.5) 누적 수정
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

    else {

        document.getElementsByName("_MULTI_DAYS")[m_index].value = "";

        oHtml += '<tr class="multi-row multi-period">';
        oHtml += '<td>';
        oHtml += '<input type="checkbox" class="multi-row-selector" />&nbsp;';
        oHtml += '<select data-type="rField" name="VACATION_TYPE" data-element-type="sel_d_v" style="width:10%;" onchange="initVacInfoTable(this);" required title="휴가유형">'; //셀렉트 박스
        for (var j = 0; j < CodeLen; j++) {
            if ($("select[name=VACATION_TYPE]").eq(m_index).val() == oCodeList.CacheData[j].Code) {
                oHtml += "<option value='" + oCodeList.CacheData[j].Code + "' selected>" + oCodeList.CacheData[j].CodeName + "</option>";
            } else {
                oHtml += "<option value='" + oCodeList.CacheData[j].Code + "'>" + oCodeList.CacheData[j].CodeName + "</option>";
            }
        }
        oHtml += '</select> ';
        oHtml += '<input type="text" name="_MULTI_VACATION_SDT" data-type="rField" readonly="" data-pattern="date" title="시작일" onchange="calSDATEEDATE(this);" required/> ';
        oHtml += '<span>&nbsp;~&nbsp;</span>';
        oHtml += ' <input type="text" name="_MULTI_VACATION_EDT" data-type="rField" readonly="" data-pattern="date" title="종료일" onchange="calSDATEEDATE(this);" required />&nbsp;';
        oHtml += ' <b>(</b>-<input type="text" name="_MULTI_DAYS" data-type="rField" class="sum-table-cell" value="" data-pattern="period" data-period-ref="_MULTI_VACATION_SDT,_MULTI_VACATION_EDT,1" style="border:0px solid;width:20px;font-weight:bold;" readonly="readonly" /><b>일)</b>';
        oHtml += '</td>';
        oHtml += '</tr>';

        $('#tblVacInfo').find("tr").eq(m_index + 1).after(oHtml);
        $('#tblVacInfo').find("tr").eq(m_index + 1).remove();
        EASY.pattern($('#tblVacInfo'));
    }
}

function calSDATEEDATE(obj) {
    // 현재 객채(input) 에서 제일 가까이 있는 tr을 찾음
    var tmpObj = $(obj).closest("tr");
    var m_index = $("input[name=_MULTI_VACATION_EDT]").index(obj);
    if ($(tmpObj).find("input[name=_MULTI_VACATION_SDT]").eq(m_index).val() != "" && $(tmpObj).find("input[name=_MULTI_VACATION_EDT]").eq(m_index).val() != "") {
        var SDATE = $("input[name=_MULTI_VACATION_SDT]").eq(m_index).val().split('-');
        var EDATE = $("input[name=_MULTI_VACATION_EDT]").eq(m_index).val().split('-');

        var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        var tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
        if (tmpday < 0) {
            alert("이전 일보다 전 입니다. 확인하여 주십시오.");
            $("input[name=_MULTI_VACATION_EDT]").eq(m_index).val("");
            $("input[name=_MULTI_DAYS]").eq(m_index).val("");
            EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
        }

        if (document.getElementsByName("VACATION_TYPE")[m_index].value == "VACATION_BEFOREOFF" || document.getElementsByName("VACATION_TYPE")[m_index].value == "VACATION_OFF") {

            if (parseInt(document.getElementsByName("_MULTI_VACATION_EDT")[m_index].value) >= parseInt(document.getElementsByName("_MULTI_VACATION_SDT")[m_index].value)) {
                alert("시작일 보다 종료일이 먼저일 수 없습니다. ");
                document.getElementsByName("_MULTI_VACATION_EDT")[m_index].value = "";
                document.getElementsByName("_MULTI_VACATION_SDT")[m_index].value = "";
                // EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
            }
        }

    }
}

function getBaseCode() {
    // 그룹코드와 비사용중인 코드를 제외한 모든 코드를 가져옴.
    //var oCodeList = Common.GetBaseCode("VACATION_TYPE"); 기초 설정이 개발되면 변경
    var oCodeList = $.parseJSON('{"CacheData":[{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_ANUUAL","Reserved1":"+","Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986212513)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREANUUAL","Reserved1":"+","Reserved2":"1","Reserved3":null,"ReservedInt":null,"CodeName":"선연차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986332707)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_BEFOREOFF","Reserved1":"+","Reserved2":"1","Reserved3":"0.5","ReservedInt":null,"CodeName":"선반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986256220)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_CONGRATULATIONS","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"경조","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1453857355243)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OFF","Reserved1":"+","Reserved2":null,"Reserved3":"0.5","ReservedInt":null,"CodeName":"반차","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451987876890)/"},{"BizSection":"Approval","CodeGroup":"VACATION_TYPE","Code":"VACATION_OTHER","Reserved1":null,"Reserved2":null,"Reserved3":null,"ReservedInt":null,"CodeName":"기타","SortKey":0,"Description":"","IsUse":"Y","ModifyDate":"/Date(1451986308353)/"}]}');
   
    var Len = oCodeList.CacheData.length;

    $("select[name=VACATION_TYPE] option").remove();

    for (var i = 0; i < Len; i++) {

        $("select[name=VACATION_TYPE]").append("<option value='" + oCodeList.CacheData[i].Code + "'>" + oCodeList.CacheData[i].CodeName + "</option>");
    }
}

function getData() {
	
   /* var pXML = "VM_PlanApvForm_R";
    var aXML = "<param><name>UR_CODE</name><type>nvarchar</type><length>50</length><value><![CDATA[" + getInfo("usid") + "]]></value></param>";
    aXML += "<param><name>year</name><type>varchar</type><length>4</length><value><![CDATA[" + document.getElementById("Sel_Year").value + "]]></value></param>";
    var connectionname = "COVI_FLOW_SI_ConnectionString";
    var sXML = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql><type>sp</type>" + aXML + "</Items>";
    var szURL = "../getXMLQuery.aspx";

    CFN_CallAjax(szURL, sXML, function (data) {
        receiveHTTPGetData(data);
    }, false, "xml");*/
    
    CFN_CallAjax("/approval/legacy/getVacationData.do", {"UR_CODE":getInfo("AppInfo.usid"),"year":document.getElementById("Sel_Year").value}, function (data){ 
    	 receiveHTTPGetData(data);
	}, false, 'json');
 
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

    $("#TotalVac").val(atot);
    if (vacday == "") {
        //Common.Warning("해당 년도의 연차 사용 가능 일수가 등록되지 않았습니다. 관리자에게 문의하세요."); //잔여휴가일이 없습니다. 기안할 수 없습니다.
        $("[id=VAC_DAYS]").val("0");
        $("[id=USE_DAYS]").val("0");

    } else if (parseFloat(useday) <= 0) {

        $("[id=VAC_DAYS]").val(parseFloat(vacday) + "일 (사용 연차 : " + (parseFloat(useday)) + ")");
        if (parseFloat(useday) == 0) {
            Common.Warning("취소할 사용 연차가 없습니다.");
            $("[id=USE_DAYS]").val(parseFloat(atot));
        } else {
            $("[id=USE_DAYS]").val(parseFloat(atot));
        }
    }
    else {
        $("[id=VAC_DAYS]").val(parseFloat(vacday) + "일 (사용 연차 : " + (parseFloat(useday)) + ")");
        $("[id=USE_DAYS]").val(parseFloat(atot));
    }
}