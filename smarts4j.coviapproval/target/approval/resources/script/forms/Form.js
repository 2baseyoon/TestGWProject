
//Draft 양식을 위한 입력값 초기화 처리
function initFieldForDraft(obj) {
    
    var findFormat;
    findFormat = 'input[data-type="mField"],';
    findFormat += 'input[data-type="dField"],';
    findFormat += 'input[data-type="smField"],';
    findFormat += 'textarea[data-type="mField"],';
    findFormat += 'textarea[data-type="smField"]';

    obj.find(findFormat).not('[type="hidden"]').each(function () {
        if ($(this).is("textarea")) {
            $(this).text('');
        }
        else {
            if ($(this).attr('value').indexOf('{{ doc.') > -1) {
                $(this).attr('value', '');
            }
        }
    });

    return obj;
}

function validateUnderscore(template) {

    var strRet, formDataString;

    strRet = template;
    
    var t = typeof(formJson);
    if (t == "object" || formJson != null) { 
    	    	
    	var n, v, json = [], arr = (formJson && formJson.constructor == Array); 
    	for (n in formJson) { 
    	     v = formJson[n]; 
    	     t = typeof(v); 
    	     if (formJson.hasOwnProperty(n)) { 
    	        	v = '"' + v + '"'; 
    	        	
    	            json.push((arr ? "" : '"' + n + '":') + String(v));
    	  	 } 
    	}
    	formDataString = (arr ? "[" : "{") + String(json) + (arr ? "]" : "}"); 
    }
    
    //오류 발생 
    //formDataString = JSON.stringify(formJson);
    
    //ie8에서 양식필드id 한글로 명명했을때 오류처리
    formDataString = formDataString.replace(/\\u([a-z0-9]{4})/g, function ($0, $1) { return unescape('%u' + $1) });

    // 정규식 처리
    //var myString = "something format_abc";
    var myRegEx = /.*?{{ doc.(.*?) }}.*?/g;
    // Get an array containing the first capturing group for every match
    var matches = getMatches(strRet, myRegEx, 1);

    for (var i = 0; i < matches.length; i++) {

        if (!checkKeyExistInJson(matches[i], formDataString)) {
            strRet = strRet.replace('{{ doc.' + matches[i] + ' }}', '');
        }
    }

    return strRet;
}

function checkKeyExistInJson(key, targetString) {

    var bRet = false;

    /*var keys = [];
    keys = key.split('.');

    var tKey = keys[keys.length - 1];

    var doublePattern = "\"" + tKey + "\"";
    var singlePattern = "'" + tKey + "'";

    if (targetString.indexOf(doublePattern) > -1 || targetString.indexOf(singlePattern) > -1) {
        bRet = true;
    }*/
    
    if(getInfo(key) != undefined)
    	bRet = true;

    return bRet;
}

function getMatches(string, regex, index) {
    index || (index = 1); // default to the first capturing group
    var matches = [];
    var match;
    while (match = regex.exec(string)) {
        matches.push(match[index]);
    }
    return matches;
}

//값의 배열 여부를 조사하여, 배열이 아닐 경우 배열로 리턴
function validateArray(obj) {
    var ret = [];

    if (!$.isArray(obj)) {
        ret.push(obj);
    }
    else {
        ret = obj;
    }

    return ret;
}

function postJobForDynamicCtrl() {
    //refactoring - 성능 고려
    //data-element-type 속성을 가진(rField와 stField는 공통 컴포넌트에서 처리)
    var $selectedElms = $('#editor,#docInfoTB').find('[data-element-type]').not('[data-type="rField"],[data-type="stField"]')
    if ($selectedElms.length > 0) {
        $selectedElms.each(function (idx, elm) {
            var $elm = $(elm);
            var dataElmType = $elm.attr("data-element-type");
            var dataType = $elm.attr("data-type");

            //alert(dataElmType + ', ' + dataType);
            switch (dataElmType) {

                case "chk_d":
                    postChkJob($elm, dataElmType, dataType);
                    break;

                case "chk_v":
                    postChkJob($elm, dataElmType, dataType);
                    break;

                case "sel_d_v":
                    postSelJob($elm, dataElmType, dataType);
                    break;

                case "sel_d_t":
                    postSelJob($elm, dataElmType, dataType);
                    break;

                case "rdo_d":
                    postRdoJob($elm, dataElmType, dataType);
                    break;

                case "rdo_v":
                    postRdoJob($elm, dataElmType, dataType);
                    break;

                case "editor":
                    postEditorJob($elm);
                    break;

                case "textarea_linebreak":
                    postTextareaJob($elm, dataElmType, dataType);
                    break;

            }
        });
    }

}

function postTextareaJob(elm, dataElmType, dataType) {
    var txtData;
    txtData = postDataJob(elm, dataElmType, dataType);

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
        if (txtData != "" && typeof txtData != 'undefined') {
            //[2015-10-28 modi kh] modify textarea space format style s -----
            txtData = txtData.replace(/ /g, '&nbsp;');
            $(elm).css('display', 'inline-block');
            //e -------------------------------------------------------------

            elm.html(txtData.replace(/\n/gi, "<br \/>"));
        }
    }
    else {//임시 저장 처리

    }

}

function postDataJob(elm, dataElmType, dataType) {
    var retData;

    //data 처리
    try {
        switch (dataType) {
            case "mField":
                if (typeof formJson.BodyContext != 'undefined') {
                    // 체크박스의 경우
                    if (dataElmType.indexOf('chk') > -1) {
                        retData = validateArray(formJson.BodyContext[getNodeName(elm)]);
                    }
                    else if (dataElmType.indexOf('sel_d_t') > -1) {
                        retData = {};
                        retData["VALUE"] = formJson.BodyContext[getNodeName(elm)];
                        retData["TEXT"] = formJson.BodyContext[getNodeName(elm) + '_TEXT'];
                    }
                    else if (dataElmType.indexOf('rdo_v') > -1) {
                        retData = {};
                        retData["VALUE"] = formJson.BodyContext[getNodeName(elm)];
                        retData["TEXT"] = formJson.BodyContext[getNodeName(elm) + '_TEXT'];
                    }
                    else {
                        retData = formJson.BodyContext[getNodeName(elm)];
                    }
                }
                break;
            case "dField":
                if (typeof formJson.oFormData != 'undefined') {
                    // 체크박스의 경우
                    if (dataElmType.indexOf('chk') > -1) {
                        retData = validateArray(removeSeperatorForSingle(formJson.oFormData[getNodeName(elm)]));
                    }
                    else {
                        retData = formJson.oFormData[getNodeName(elm)];
                    }
                }
                break;
            case "smField": 
            	if (formJson.BodyData != null && formJson.BodyData.MainTable) {
                    // 체크박스의 경우
                    if (dataElmType.indexOf('chk') > -1) {
                        retData = validateArray(removeSeperatorForSingle(formJson.BodyData.MainTable[getNodeName(elm)]));
                    } else if (dataElmType.indexOf('sel_d_t') > -1) {			// [2015-01-28] smField select text
                        retData = {};
                        retData["VALUE"] = formJson.BodyData.MainTable[getNodeName(elm)];
                        retData["TEXT"] = elm.find("option[value='" + retData["VALUE"] + "']").text();
                    } else {
                        retData = formJson.BodyData.MainTable[getNodeName(elm)];
                    }
                }
                break;
            default:
                retData = "";
                break;
        }
    } catch (e) {
        alert("error at postDataJob : " + e.message);
    }

    return (retData == null) ? "" : retData;
}

function postEditorJob(elm) {
	var eIndex = elm.context.id.replace("divWebEditorContainer","");
	
	if(getInfo("ExtInfo.UseHWPEditYN") == "Y" || getInfo("ExtInfo.UseMultiEditYN") == "Y") return;
	// 한글 웹 기안기인 경우 웹 기안기를 띄우기 위해서 return
	if (getInfo("ExtInfo.UseWebHWPEditYN") == "Y") { return; }
	
    //읽기 처리
    if (getInfo("Request.templatemode") == "Read" && getInfo("FormInfo.FormPrefix") == "WF_FORM_EXTERNAL") {
        var replaceHtml = '';
        replaceHtml += '<table class="table_form_info_draft" cellpadding="0" cellspacing="0" style="width: 100%; margin-top: 5px; table-layout: fixed; min-height: 350px;">';
        replaceHtml += '    <tr>';
        replaceHtml += '        <td width="100%" height="100%" id="{0}" valign="top" style="padding:13px;padding-right:27px"></td>';
        replaceHtml += '    </tr>';
        replaceHtml += '</table>';

        //replacewith
        elm.replaceWith(replaceHtml.f("tbContentElement" + eIndex));
        //editor 내용 set
        setEditor(eIndex);
    }
    else if (getInfo("Request.templatemode") == "Read") {
    	var minHeight = Common.getBaseConfig("EditorMinHeight") == "" ? "580" : Common.getBaseConfig("EditorMinHeight");
    	
        var replaceHtml = '';
        replaceHtml += '<table class="table_form_info_draft" cellpadding="0" cellspacing="0" style="margin-top: 5px; table-layout: fixed; min-height: ' + minHeight + 'px; width:100%; border:hidden;">';
        replaceHtml += '    <tr>';
        replaceHtml += '        <td width="100%" height="100%" id="{0}" valign="top" style="padding:0px"></td>';// style="padding:13px;padding-right:27px"
        replaceHtml += '    </tr>';
        replaceHtml += '</table>';

        //replacewith
        elm.replaceWith(replaceHtml.f("tbContentElement" + eIndex));
        //editor 내용 set
        setEditor(eIndex);
    }
}

function postRdoJob(elm, dataElmType, dataType) {

    var rdoData;
    rdoData = postDataJob(elm, dataElmType, dataType);

    //읽기 처리
    if (getInfo("Request.templatemode") == "Read") {

        if (dataElmType == "rdo_d") {
            // radio 처리, rdo_d
            elm.find('input:radio').each(function () {
                // input radio -> span
                var replaceHtml = "<span>";
                if (rdoData != "" && typeof rdoData != 'undefined') {
                    // [2016-09-09 leesm] BC카드 Radio 분산으로 인해 Array로 데이터가 구성되므로 추가함
                    if (rdoData instanceof Array) {
                        if (rdoData[0] != "") {
                            if (rdoData[0] == $(this).val()) {
                                replaceHtml += "●";
                            }
                            else {
                                replaceHtml += "○";
                            }
                        }
                        else {
                            replaceHtml += "○";
                        }
                    }
                    else {
                        if (rdoData == $(this).val()) {
                            replaceHtml += "●";
                        }
                        else {
                            replaceHtml += "○";
                        }
                    }
                }
                else {
                    replaceHtml += "○";
                }
                replaceHtml += "</span>&nbsp;";

                //replacewith
                $(this).replaceWith(replaceHtml);

            });

        }
        else if (dataElmType == "rdo_v") {
            // radio 처리, rdo_v
            var replaceHtml = "<span>";
            if (rdoData != "" && typeof rdoData != 'undefined') {

                if (rdoData.hasOwnProperty('TEXT')) {
                    replaceHtml += typeof rdoData.TEXT != 'undefined' ? rdoData.TEXT : '';
                }
                else {
                    replaceHtml += rdoData;
                }
            }
            replaceHtml += "</span>";
            elm.replaceWith(replaceHtml);
        }

    } else {
        //임시저장 처리
        // select 처리
        if (rdoData != "" && typeof rdoData != 'undefined') {
            var rdoValue;
            if (rdoData.hasOwnProperty('VALUE')) {
                rdoValue = rdoData.VALUE;
            }
            else {
                rdoValue = rdoData;
            }

            if (typeof rdoValue != 'undefined') {
                elm.find('input:radio').each(function () {

                    if (rdoValue.indexOf($(this).val()) > -1) {
                        $(this).attr("checked", true);
                    }

                });
            }

        }

    }

}

function postSelJob(elm, dataElmType, dataType) {
    var selData = '';

    selData = postDataJob(elm, dataElmType, dataType);

    //읽기 처리
    if (getInfo("Request.templatemode") == "Read") {
        if (dataElmType == "sel_d_v") {         //특수한 경우 처리, SAVE_TERM, DOC_LEVEL
            var nodeName = getNodeName(elm);

            var replaceHtml = "<span>";

            if (nodeName == "SaveTerm") {
                replaceHtml += getSaveTerm(getInfo("FormInstanceInfo.SaveTerm"));
            }
            else if (nodeName == "DocLevel") {
                replaceHtml += getDocLevel(getInfo("FormInstanceInfo.DocLevel"));
            }
            else {
                if (selData != "" && typeof selData != 'undefined' && selData != null) {
                    if (selData != '0') {
                        replaceHtml += selData;
                    }
                }
            }

            replaceHtml += "</span>&nbsp;";

            //replacewith
            elm.replaceWith(replaceHtml);
        }
        else if (dataElmType == "sel_d_t") {
            var replaceHtml = "";

            replaceHtml += "<span>";

            if (selData != "" && typeof selData != 'undefined' && selData != null) {
                if (selData.hasOwnProperty('TEXT')) {
                    if (selData.VALUE != '0') {
                        if (typeof selData.TEXT != 'undefined') {
                            replaceHtml += selData.TEXT == null ? '' : selData.TEXT;
                        }
                        else {
                            replaceHtml += '';
                        }
                    }
                }
                else {
                    if (selData != '0') {
                        replaceHtml += selData;
                    }
                }
            }
            replaceHtml += "</span>&nbsp;";

            elm.replaceWith(replaceHtml);
        }

    }
    else {      //임시저장 처리
        if (selData != null && selData != "" && typeof selData != 'undefined') {        // select 처리
            var selValue;

            if (selData.hasOwnProperty('VALUE')) {
                selValue = selData.VALUE;
            }
            else {
                selValue = selData;
            }

            if (typeof selValue != 'undefined') {
                elm.find('option[value="' + selValue + '"]').attr('selected', true);
            }
        }
    }
}

function postChkJob(elm, dataElmType, dataType) {

    var chkData;
    chkData = postDataJob(elm, dataElmType, dataType);

    //읽기 처리
    if (getInfo("Request.templatemode") == "Read") {

        if (dataElmType == "chk_d") {

            elm.find('input:checkbox').each(function () {
                // input checkbox -> span
                var replaceHtml = "<span>";
                if (chkData != "" && typeof chkData != 'undefined') {

                    if ($.inArray($(this).val(), chkData) > -1) {
                        replaceHtml += "■";
                    }
                    else {
                        replaceHtml += "□";
                    }
                }
                else {
                    replaceHtml += "□";
                }

                replaceHtml += "</span>&nbsp;";

                //replacewith
                $(this).replaceWith(replaceHtml);
            });

        }
        else if (dataElmType == "chk_v") {

            // input checkbox -> span
            var replaceHtml = "<span>";

            if (chkData != "" && typeof chkData != 'undefined') {

                for (var i = 0; i < chkData.length; i++) {
                    replaceHtml += chkData[i];
                    if (i != (chkData.length - 1)) {
                        replaceHtml += ", ";
                    }
                }

            }
            replaceHtml += "</span>&nbsp;";

            //replacewith
            elm.replaceWith(replaceHtml);
        }

    } else {
        //임시저장 처리
        if (chkData != "" && typeof chkData != 'undefined') {
            elm.find('input:checkbox').each(function () {

                if ($.inArray($(this).val(), chkData) > -1) {
                    $(this).attr("checked", true);
                }

            });
        }
    }

}

function removeSeperatorForSingle(obj) {
    var ret;

    if (typeof obj != 'undefined' && obj != null) {
        if (obj.indexOf('|') > -1) {
            ret = obj.split('|');
        }
        else {
            ret = obj;
        }
    }
    
    return ret;
}

// json object의 값에 구분자를 포함한 경우 배열로 변환하는 함수
function removeSeperatorForMultiRow(jsonObj) {

    if (typeof jsonObj != 'undefined' && jsonObj != null) {
        //배열 형태이면 each를 두번
        if ($.isArray(jsonObj)) {
            $.each(jsonObj, function () {
            	var $row = this;
            	$.each(this, function (k, v) {
            		if (typeof v != 'undefined' && v != null) {
            			if (v.indexOf('|') > -1) {
            				var tempArr = v.split('|');
            				$row[k] = tempArr;
            			}
            		}
                });
            });
        }
        else {
            $.each(jsonObj, function (k, v) {
                //구분자 처리 가능한 값 '|'
                if (typeof v != 'undefined' && v != null) {
                    var $row = this;
                    if (v.indexOf('|') > -1) {
                        var tempArr = v.split('|');
                        $row[k] = tempArr;
                    }
                }
            });
        }
    }
    
    return jsonObj;
}

//특정 data 처리를 위한 함수
function commonDataChanger() {
    // 재사용 시 data 처리
    if (getInfo("Request.reuse") == "Y" || getInfo("Request.reuse") == "P") {
        if (getInfo("Request.mode") != "DRAFT" && getInfo("Request.mode") != "TEMPSAVE" && getInfo("Request.readtype") != "preview") { // 미리보기 창 예외
            setInfo("FormInstanceInfo.FormInstID", "");		// 비사용 getInfo("fiid_reuse"));
            setInfo("REPLY", "");
            setInfo("ProcessInfo.ProcessID", "");		// 비사용 getInfo("piid_spare"));
            setInfo("ProcessInfo.ProcessDescription", "");
            setInfo("Request.mode", "DRAFT");
            setInfo("Request.loct", "DRAFT");
            //document.getElementById("APVLIST").value = "";
            setInfo("FormInstanceInfo.DocNo", "");
            setInfo("FormInstanceInfo.ReceiveNo", "");
            setInfo("FormInstanceInfo.InitiatorID", getInfo("AppInfo.usid"));
            setInfo("FormInstanceInfo.InitiatorName", getInfo("AppInfo.usnm_multi"));
            setInfo("FormInstanceInfo.InitiatorUnitID", getInfo("AppInfo.dpid_apv"));
            setInfo("FormInstanceInfo.InitiatorUnitName", getInfo("AppInfo.dpdn_apv"));
            setInfo("Request.workitemID", ""); //201107 재사용으로 임시저장 시 결재선 저장을 위해 처리
            //의견부분 삭제 
            setInfo("JWF_Comment", "");
            //document.getElementById("APVLIST").value = getApvListReUse();
            //setInfo("ApprovalLine", document.getElementById("APVLIST").value);
            var reuseApv = getApvListReUse();
            //setInfo("APVLIST", reuseApv);
            setInfo("ApprovalLine", reuseApv);
        }
    }else if(CFN_GetQueryString("RequestFormInstID") != "" && CFN_GetQueryString("RequestFormInstID") != "undefined"){
    	var reuseApv = getApvListReUse();
        setInfo("ApprovalLine", reuseApv);
    }

    // 히스토리 기능을 위한 데이터 변환
    if (gIsHistoryView == 'true') {
        //히스토리 버젼이 0인 경우는 최종 버젼
        if (gHistoryRev != '0') {
            var editedData;
            if (parent != null) {
                editedData = parent.oFormJson[gHistoryRev];
                if (editedData != '' || editedData != null) {
                    setHistoryData(editedData, gHistoryRev);
                }
            }

        }

    }
    
}

/**
 * xml -> json
 */
function setHistoryData(eData, eRev) {
    setInfo("Request.mode", "COMPLETE");
    setInfo("Request.loct", "COMPLETE");
    try{
	    var jsonFormJSON = $.parseJSON(eData).NewDataSet.Table;
	    $.each(jsonFormJSON, function (idx, item) { 
	    	setInfo(item.FieldName, item.ModValue);
	    });
    } catch(e){ coviCmn.traceLog(e); }
}

function setHistoryMenu() {
//히스토리 보기 시 메뉴영역 그리지 않는다.
//    document.getElementById("divMenu").style.display = "none";
//    document.getElementById("divMenu02").style.display = "none";
//    //document.getElementById("AppLine").style.display = "none";
//    document.getElementById("secrecy").style.display = "none";

    initForm();
    var m_oApvList = $.parseJSON(getInfo("ApprovalLine"));
    //setInlineApvList(m_oApvList);
    var ApvLines = __setInlineApvList(m_oApvList);
    drawFormApvLinesAll(ApvLines);
}

//읽기 / 쓰기 양식 통합처리를 위한 공통 변환 함수
function commonReplace() {
    var fld;
    var l_editor = "#editor";
    
    //select 처리
    $(l_editor).find('select[data-type="mField"], select[data-type="dField"]').each(function (i, fld) {

        var attrs = {};
        attrs["id"] = $(fld).attr('id');
        attrs["data-type"] = "tField";
        attrs["data-model"] = $(fld).attr('id');
        
        changeElementType($(fld), "span", attrs);
    });

    //input, textarea 처리

}

//Element type을 newType에 new attribute로 바꾸는 함수
function changeElementType(elm, newType, newAttrs, newInnerHtml) {
    elm.replaceWith(function () {
        return $("<" + newType + "/>", newAttrs).append($(this).contents()).html(newInnerHtml);
    });
}

// array null 체크
function checkNullForArray(arr) {
    var newArray = [];
    for (var i = 0; i < arr.length; i++) {
        if (arr[i] != "" && arr[i] != null) {
            newArray.push(arr[i]);
        }
    }

    return newArray;
}

// jQuery string.format 처리
// 사용법 'this is {0}'.f('apple') => this is apple
String.prototype.format = String.prototype.f = function () {
    var s = this,
        i = arguments.length;

    while (i--) {
        s = s.replace(new RegExp('\\{' + i + '\\}', 'gm'), arguments[i]);
    }
    return s;
};

//Form Data 쪽 처리를 위해 추가한 함수
//json string 내의 parsing시 오류를 일으키는 문자 제거 -> 인코딩으로 주석
/*
function validateJsonStr(jsonStr) {
    return jsonStr
        .replace(/[\\]/g, '/')
        //.replace(/[\"]/g, '\\"')
        //.replace(/[\/]/g, '\\/')
        .replace(/[\b]/g, '')
        .replace(/[\f]/g, '')
        .replace(/[\n]/g, '')
        .replace(/[\r]/g, '')
        .replace(/[\t]/g, '');
}
*/
function escapeHtml(text) {
	if(typeof(text) == "string"){
	  return text
	      .replace(/&/g, "&amp;")
	      .replace(/</g, "&lt;")
	      .replace(/>/g, "&gt;")
	      .replace(/"/g, "&quot;")
	      .replace(/'/g, "&#039;");
	}else{
		return text;
	}
}

function decodeJsonObj(json) {
    var decodedObj = {};

    for (var key in json) {

        if (json[key] != null || json[key] != "") {

            var tempObj = {};
            var subJson = json[key];
            for (var subKey in subJson) {
                if (subJson[subKey] != null || subJson[subKey] != "") {
                    try {
                        tempObj[subKey] = Base64.decode(subJson[subKey]);
                    } catch (e) {
                        tempObj[subKey] = e.toString();
                    }
                }
            }

            decodedObj[key] = tempObj;
        }
    }

    return decodedObj;
}

//json object 병합
function mergeJsonObj(json1, json2) {
    var merged = {};
    for (var i in json1) {
        if (json1.hasOwnProperty(i))
            merged[i] = json1[i];
    }
    for (var i in json2) {
        if (json2.hasOwnProperty(i))
            merged[i] = json2[i];
    }

    return merged;
}

// Changes XML to JSON
function xmlToJson(xml) {

    var obj = {};
    if (xml.nodeType == 1) {
        if (xml.attributes.length > 0) {
            obj["@attributes"] = {};
            for (var j = 0; j < xml.attributes.length; j++) {
                var attribute = xml.attributes.item(j);
                obj["@attributes"][attribute.nodeName] = attribute.nodeValue;
            }
        }
    } else if (xml.nodeType == 3) {
        obj = xml.nodeValue;
    }
    if (xml.hasChildNodes()) {
        for (var i = 0; i < xml.childNodes.length; i++) {
            var item = xml.childNodes.item(i);
            var nodeName = item.nodeName;
            if (typeof (obj[nodeName]) == "undefined") {
                obj[nodeName] = xmlToJson(item);
            } else {
                if (typeof (obj[nodeName].push) == "undefined") {
                    var old = obj[nodeName];
                    obj[nodeName] = [];
                    obj[nodeName].push(old);
                }
                obj[nodeName].push(xmlToJson(item));
            }
        }
    }
    return obj;
}

//언어index 분기 처리
function returnLangUsingLangIdx(langIdx) {
    /*
    case "KO": szReturn = "0"; break;
    case "EN": szReturn = "1"; break;
    case "JA": szReturn = "2"; break;
    case "ZH": szReturn = "3"; break;
    
    */
    var retObj;

    switch (langIdx) {
        case 0:
            retObj = localLang_ko;
            break;
        case 1:
            retObj = localLang_en;
            break;
        case 2:
            retObj = localLang_ja;
            break;
        case 3:
            retObj = localLang_zh;
            break;
    }

    return retObj;
}

//HWP 에디터 사용 유무 리턴
function isUseHWPEditor() {
	return (getInfo("ExtInfo.UseHWPEditYN") == "Y" || getInfo("ExtInfo.UseWebHWPEditYN") == "Y") ? true : false;
}

//현재 선택한 안 데이터 저장
function saveCurMulti() {
	var curIdx = $("#writeTab li.on").attr("idx");
	saveCurMultiContext(curIdx);//현 탭 데이터 저장
}


//에디터 로딩
function LoadEditor(elm, idx, templateFile, doctype) {
	if(!idx) idx = "";

	// 다안기안 및 HWP 에디터 사용여부 체크
	if(isUseHWPEditor()) {
		if(getInfo('ExtInfo.UseMultiEditYN') == "Y") {
			LoadEditorHWP_Multi(elm, idx, templateFile, doctype);
		} else {
			LoadEditorHWP(elm);
		}
	} else if(getInfo('ExtInfo.UseMultiEditYN') == "Y" && getInfo("Request.templatemode") == "Read") {
		LoadEditor_Multi(elm, idx, templateFile, doctype);
	} else {
    //전자결재 양식이 Write 모드일때 BaseConfig의 에디터 로딩체크 기능 실행 여부 확인
    //Date : 2016-03-24
    //Author : YJYOO
    if (Common.getBaseConfig("CheckApprovalEditorLoad") == null || Common.getBaseConfig("CheckApprovalEditorLoad").toUpperCase() == "" || Common.getBaseConfig("CheckApprovalEditorLoad").toUpperCase() == "N") {
        //debugger;
        //0.TextArea, 1.DHtml, 2.TagFree, 3.XFree, 4.TagFree/XFree, 5.Activesquare, 6.CrossEditor, 7.ActivesquareDefault/CrossEditor
        //g_id = "tbContentElement";
        //gx_id = "tbContentElement";
        //g_editorTollBar = '0'; // 웹에디터 툴바 타입 설정 : 0-모든 툴바 표시 , 1-위쪽 툴바만 표시, 2-아래쪽 툴바만 표시
        //g_heigth = "400";

        //editor 영역
        switch (Common.getBaseConfig("EditorType")) {
            case "0":
	                $('#' + elm).html('<textarea id=\"' + g_id + idx + '\" name=\"' + g_id + idx + '\" style="width: 98%; height: ' + g_heigth + 'px;"></textarea>');
                break;
            case "1":
                break;
            case "2":
                //eHtml += '<script src="/WebSite/Common/ExControls/TagFree/tweditor.js" type="text/javascript"></script>';
                //eHtml += '<script language="javascript" for="' + g_id + '" event="OnControlInit">EditorSetContent();</script>';
                $('#' + elm).html(LoadtweditorForApproval())
	                    .append('<script language="javascript" for="' + g_id + idx + '" event="OnControlInit">setTimeout("setEditor(' + idx + ')", 1000);</script>');
                break;
            case "3":
                //eHtml += '<script src="/WebSite/Common/ExControls/XFree/XFreeEditor.js" type="text/javascript"></script>';
                /*$('#' + elm).append('<div id="hDivEditor" style="width: 100%; height:100%;"></div>')
                    .append('<iframe id="xFreeFrame" src="/WebSite/Approval/Forms/Templates/common/XFree.html" marginwidth="0" frameborder="0" scrolling="no" ></iframe>');

                //setTimeout("setEditor()", 1000);
                timerXFree = setInterval("setXFreeWhenAvailable()", 500);*/
            	
            	coviEditor.loadEditor(
                		elm,
        			{
        				editorType : "xfree",
	        				containerID : 'tbContentElement' + idx,
        				frameHeight : '600',
        				focusObjID : '',
        				onLoad: function(){
	        					setEditor(idx);
        				}
        			}
        		);
            	
                break;
            case "4":
                if (_ie) {
                    //eHtml += '<script src="/WebSite/Common/ExControls/TagFree/tweditor.js" type="text/javascript"></script>';
                    //eHtml += '<script language="javascript" for="' + g_id + '" event="OnControlInit">EditorSetContent();</script>';

                    $('#' + elm).html(LoadtweditorForApproval())
	                        .append('<script language="javascript" for="' + g_id + idx + '" event="OnControlInit">setTimeout("setEditor(' + idx + ')", 1000);</script>');
                }
                else {
                    //eHtml += '<script src="/WebSite/Common/ExControls/XFree/XFreeEditor.js" type="text/javascript"></script>';
                    //iFrame 방식
                    $('#' + elm).append('<div id="hDivEditor" style="width: 100%; height:100%;"></div>')
                        .append('<iframe id="xFreeFrame" src="/WebSite/Approval/Forms/Templates/common/XFree.html" marginwidth="0" frameborder="0" scrolling="no" ></iframe>');

                    //기존 방식 -> 화면 초기화 문제점 발생
                    //LoadXFreeEditor();

                    //setTimeout("setEditor()", 1000);
                    //[2015-06-26 modi kh] XFree Design에 기본 양식 포맷 내용 안보이는 현상 수정 - interval 100 -> 500
                    timerXFree = setInterval("setXFreeWhenAvailable()", 500);
                }
                break;
            case "5":
                break;
            case "6":
                break;
            case "7":
                break;
            case "8":
                coviEditor.loadEditor(
                		elm,
        			{
        				editorType : "dext5",
	        				containerID : 'tbContentElement' + idx,
        				frameHeight : '600',
        				focusObjID : '',
        				onLoad: function(){
	        					setEditor(idx);
        				}
        			}
        		);
                //setTimeout("setEditor()", 1000);
                break;
            case "9":
                // TODO: DEXT5 Test by Kyle 2015-08-04
                // ChEditor Loading
                $('#' + elm)
                        .append('<script type="text/javascript" src="/WebSite/Common/ExControls/Cheditor/cheditor.js"></script>')
                        .append('<iframe id="cheditorFrame" src="/WebSite/Approval/Forms/Templates/common/Cheditor.html" marginwidth="0" frameborder="0" scrolling="no" width="100%" height="500" ></iframe>')
	                        .append('<script language="javascript" for="' + g_id + idx + '" event="OnControlInit">setTimeout("setEditor(' + idx + ')", 1000);</script>');//width="730" height="600"
                break;
            case "10":
                coviEditor.loadEditor(
                		elm,
        			{
        				editorType : "synap",
	        				containerID : 'tbContentElement' + idx,
        				frameHeight : '600',
        				focusObjID : '',
        				onLoad: function(){
	        					setEditor(idx);
        				}
        			}
        		);
                break;
            case "11":
            	coviEditor.loadEditor(
            			elm,
            			{
            				editorType : "ck",
            				containerID : 'tbContentElement' + idx,
            				frameHeight : '600',
            				focusObjID : '',
            				onLoad: function(){
            					setEditor(idx);
            				}
            			}
            	);
            	break;
            case "12":
            	coviEditor.loadEditor(
            			elm,
            			{
            				editorType : "webhwpctrl",
            				containerID : 'tbContentElement' + idx,
            				frameHeight : '600',
            				focusObjID : '',
            				onLoad: function(){
            					setEditor(idx);
            				}
            			}
            	);
            	break;
            case "13":
                coviEditor.loadEditor(
                    elm,
                    {
                        editorType : "covieditor",
	                        containerID : 'tbContentElement' + idx,
                        frameHeight : '600',
                        focusObjID : '',
                        onLoad: function(){
	                            setEditor(idx);
                        }
                    }
                );
                break;
            case "14":
                coviEditor.loadEditor(
                    elm,
                    {
                        editorType : "keditor",
	                        containerID : 'tbContentElement' + idx,
                        frameHeight : '600',
                        focusObjID : '',
                        onLoad: function(){
	                            setEditor(idx);
                        }
                    }
                );
                break;
           default:
                break;
        }
    }
    else {
        //debugger;
        //0.TextArea, 1.DHtml, 2.TagFree, 3.XFree, 4.TagFree/XFree, 5.Activesquare, 6.CrossEditor, 7.ActivesquareDefault/CrossEditor
        //g_id = "tbContentElement";
        //gx_id = "tbContentElement";
        //g_editorTollBar = '0'; // 웹에디터 툴바 타입 설정 : 0-모든 툴바 표시 , 1-위쪽 툴바만 표시, 2-아래쪽 툴바만 표시
        //g_heigth = "400";

        //editor 영역
        switch (Common.getBaseConfig("EditorType")) {
            case "0":
	                $('#' + elm).html('<textarea id=\"' + g_id + idx + '\" name=\"' + g_id + idx + '\" style="width: 98%; height: ' + g_heigth + 'px;"></textarea>');
                break;
            case "1":
                break;
            case "2":
                //eHtml += '<script src="/WebSite/Common/ExControls/TagFree/tweditor.js" type="text/javascript"></script>';
                //eHtml += '<script language="javascript" for="' + g_id + '" event="OnControlInit">EditorSetContent();</script>';
                $('#' + elm).html(LoadtweditorForApproval())
	                    .append('<script language="javascript" for="' + g_id + idx + '" event="OnControlInit">setTimeout("setEditor(' + idx + ')", 1000);</script>');
                break;
            case "3":
                //eHtml += '<script src="/WebSite/Common/ExControls/XFree/XFreeEditor.js" type="text/javascript"></script>';
                $('#' + elm).append('<div id="hDivEditor" style="width: 100%; height:100%;"></div>')
                    .append('<iframe id="xFreeFrame" src="/WebSite/Approval/Forms/Templates/common/XFree.html" marginwidth="0" frameborder="0" scrolling="no" ></iframe>');

                //setTimeout("setEditor()", 1000);
                //timerXFree = setInterval("setXFreeWhenAvailable()", 500);
                break;
            case "4":
                if (_ie) {
                    //eHtml += '<script src="/WebSite/Common/ExControls/TagFree/tweditor.js" type="text/javascript"></script>';
                    //eHtml += '<script language="javascript" for="' + g_id + '" event="OnControlInit">EditorSetContent();</script>';

                    $('#' + elm).html(LoadtweditorForApproval())
	                        .append('<script language="javascript" for="' + g_id + idx + '" event="OnControlInit">setTimeout("setEditor(' + idx + ')", 1000);</script>');
                }
                else {
                    //eHtml += '<script src="/WebSite/Common/ExControls/XFree/XFreeEditor.js" type="text/javascript"></script>';
                    //iFrame 방식
                    $('#' + elm).append('<div id="hDivEditor" style="width: 100%; height:100%;"></div>')
                        .append('<iframe id="xFreeFrame" src="/WebSite/Approval/Forms/Templates/common/XFree.html" marginwidth="0" frameborder="0" scrolling="no" ></iframe>');

                    //기존 방식 -> 화면 초기화 문제점 발생
                    //LoadXFreeEditor();

                    //setTimeout("setEditor()", 1000);
                    //[2015-06-26 modi kh] XFree Design에 기본 양식 포맷 내용 안보이는 현상 수정 - interval 100 -> 500
                    //timerXFree = setInterval("setXFreeWhenAvailable()", 500);
                }
                break;
            case "5":
                break;
            case "6":
                break;
            case "7":
                break;
            case "8":
                // TODO: DEXT5 Test by Kyle 2015-07-30
                // DEXT5 Editor Loading
                $('#' + elm)
                        .append('<script type="text/javascript" src="/WebSite/Common/ExControls/dext5editor/js/dext5editor.js"></script> ')
                        .append('<iframe id="dext5Frame" src="/WebSite/Approval/Forms/Templates/common/Dext5.html" marginwidth="0" frameborder="0" scrolling="no" width="100%" height="600" ></iframe>')
                //.append('<script language="javascript" for="' + g_id + '" event="OnControlInit">setTimeout("setEditor()", 1000);function dext_editor_loaded_event(editor) {Common.AlertClose();}</script>');//width="730" height="600"
	                        .append('<script language="javascript" for="' + g_id + idx + '" event="OnControlInit">setTimeout("setEditor(' + idx + ')", 1000);</script>');//width="730" height="600"
                break;
            case "9":
                // TODO: DEXT5 Test by Kyle 2015-08-04
                // ChEditor Loading
                $('#' + elm)
                        .append('<script type="text/javascript" src="/WebSite/Common/ExControls/Cheditor/cheditor.js"></script>')
                        .append('<iframe id="cheditorFrame" src="/WebSite/Approval/Forms/Templates/common/Cheditor.html" marginwidth="0" frameborder="0" scrolling="no" width="100%" height="500" ></iframe>')
                        .append('<script language="javascript" for="' + g_id + '" event="OnControlInit">setTimeout("setEditor()", 1000);</script>');//width="730" height="600"
                break;
		    case "13":
                //covieditor  
		            break;
            case "14":
                // TODO: DEXT5 Test by Kyle 2015-07-30
                $('#' + elm)
                        .append('<script type="text/javascript" src="/WebSite/Common/ExControls/keditor/js/raonkeditor.js"></script> ')
                        .append('<iframe id="keditorFrame" src="/WebSite/Approval/Forms/Templates/common/Keditor.html" marginwidth="0" frameborder="0" scrolling="no" width="100%" height="600" ></iframe>')
                //.append('<script language="javascript" for="' + g_id + '" event="OnControlInit">setTimeout("setEditor()", 1000);function dext_editor_loaded_event(editor) {Common.AlertClose();}</script>');//width="730" height="600"
	                        .append('<script language="javascript" for="' + g_id + idx + '" event="OnControlInit">setTimeout("setEditor(' + idx + ')", 1000);</script>');//width="730" height="600"
                break;
            default:
                break;
        }
        //LoadEditor 호출 이후 Loading 창 발생
        if (Common.getBaseConfig("EditorType") == "2" || Common.getBaseConfig("EditorType") == "3" || Common.getBaseConfig("EditorType") == "4" || Common.getBaseConfig("EditorType") == "8"|| Common.getBaseConfig("EditorType") == "14") {
            Common.Loading("Loading...", function () {
                editorStatusCheck();
            }, 300);
        }
    }
}
	}
/*
* Editor 정상 로딩 여부 확인(TagFree / XFREE)
* Date : 2016-03-21
* Author : YJYOO
*/
function editorStatusCheck() {
    if (getInfo("BaseConfig.editortype") == "2") {//2.TagFree
        if (document.tbContentElement == null || document.tbContentElement.ActiveTab == undefined || document.tbContentElement.ActiveTab < 0) {
            setTimeout("editorStatusCheck()", 500);
        }
        else {
            Common.AlertClose();
            return true;
        }
    }
    else if (getInfo("BaseConfig.editortype") == "3") {//3.XFree
        if (document.getElementById('xFreeFrame').contentWindow == undefined || document.getElementById('xFreeFrame').contentWindow.isLoaded == undefined || !document.getElementById('xFreeFrame').contentWindow.isLoaded) {
            setTimeout("editorStatusCheck()", 500);
        }
        else {
            setTimeout("setEditor()", 500);
            Common.AlertClose();
            return true;
        }

    }
    else if (getInfo("BaseConfig.editortype") == "4") {//4.TagFree/XFree
        if (_ie) {
            if (document.tbContentElement == null || document.tbContentElement.ActiveTab == undefined || document.tbContentElement.ActiveTab < 0) {
                setTimeout("editorStatusCheck()", 500);
            }
            else {
                Common.AlertClose();
                return true;
            }
        }
        else {
            if (document.getElementById('xFreeFrame').contentWindow == undefined || document.getElementById('xFreeFrame').contentWindow.isLoaded == undefined || !document.getElementById('xFreeFrame').contentWindow.isLoaded) {
                setTimeout("editorStatusCheck()", 500);
            }
            else {
                setTimeout("setEditor()", 500);
                Common.AlertClose();
                return true;
            }
        }
    }
}

//XFree 에디터 data를 set하는 부분, try/catch 구문으로 에디터의 onload 시점을 판단
var timerXFree;
var timerXfreeCnt = 0;
function setXFreeWhenAvailable() {

    timerXfreeCnt++;

    try {
        // 기존의 var tempVal = document.getElementById('xFreeFrame').contentWindow.tbContentElement.getHtmlValue(); 부분을 주석처리함
        // Tagfree 사로 부터 Xfree 에디터가 로딩 완료되면 발생되는 onLoad 이벤트에서 할당받는 변수를 사용하도록 Guide함
        //var tempVal = document.getElementById('xFreeFrame').contentWindow.tbContentElement.getHtmlValue();
        if (document.getElementById('xFreeFrame').contentWindow.isLoaded){
            clearInterval(timerXFree);
            timerXfreeCnt = 0;
            setTimeout("setEditor()", 500);
        }
        else {
            if (timerXfreeCnt == 10) {
                clearInterval(timerXFree);
                timerXfreeCnt = 0;
            }
        }
    } catch (e) {
        if (timerXfreeCnt == 10) {
            clearInterval(timerXFree);
            timerXfreeCnt = 0;
        }
    }

}

//---------------------------- 이하 기존 함수-------------------------------------------------------

//주석 정리 : KJW : 2014.04.24 : XFORM PRJ.
//임시메모 divTempMemp의 focus() 이벤트에 연결
function dragApp() {
    document.oncontextmenu = function () { return true; }
    document.onselectstart = function () { return true; }
    document.ondragstart = function () { return true; }
}

function cTagreSize() {
    var obj_r = document.getElementById('pTag');
    var obj_c = document.getElementById('cTag');
    var obj_l = document.getElementById('lTag');
    var obj_lf = document.getElementById('lTag_f');
    var obj_aside = document.getElementById('divAside');
    var cHeight = $('.con_in').height() + 50;
    var oPHeight = 0;
    if (obj_l && obj_l.offsetHeight > cHeight) {
        if (obj_r) {
            if (obj_l.offsetHeight > obj_r.offsetHeight) {
                oPHeight = obj_l.offsetHeight;
            } else {
                oPHeight = obj_r.offsetHeight;
            }
        } else {
            //oPHeight = obj_l.offsetHeight;
        }
    } else if (obj_r && obj_c) {
        if (cHeight > obj_r.offsetHeight) {
            oPHeight = cHeight;
        } else {
            oPHeight = obj_r.offsetHeight;
        }
    } else if (obj_c) {
        oPHeight = cHeight;
    }

    if (obj_aside) {
        if (obj_aside.offsetHeight > oPHeight) {
            oPHeight = obj_aside.offsetHeight;
        }
    }

    if (obj_l) { obj_l.style.height = oPHeight + "px"; }
    if (obj_lf) { obj_lf.style.height = oPHeight + "px"; }
    if (obj_c) { obj_c.style.height = oPHeight + "px"; }
    if (obj_r) { obj_r.style.height = oPHeight + "px"; }
}

//로딩이미지 토글하기
function ToggleLoadingImage() {
    coviCmn.toggleLoadingOverlay();
}

function initOnloadformmenu_notelist() {	
    if (getInfo("Request.doclisttype") == "88") {
    	var params = {};
    	var govState = getInfo("Request.govstate");
    	document.getElementById("btPrint").style.display = "";
    	formDisplaySetFileInfo();
    	if(getInfo("Request.mode") =="GOVACCEPT") formDisplaySetUrlFileInfo();
    	/*
    	if(getInfo("ExtInfo.UseWebHWPEditYN") != "Y"){//웹한글 에디터는 출력미리보기 숨김
    		document.getElementById("btPrintView").style.display = "";
    	}
    	*/
        location.search && location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(str, key, value) { params[key] = value; });        
        
        if(  "SENDWAIT,ACK_REQRESEND,ACK_FAIL".indexOf( govState ) > -1 ) {
        	"req-resend" === params.docType && $("#btGovDocsReSend").show();
        }
        else if( govState === "SENDERROR" ){        	
        	$("#btGovDocsReqReSend").show();
        }
        else if( govState === "RECEIVEWAIT" ){        	
        	(params.statusCd === "send" || params.statusCd === "resend") && $("#btGovDocsReceipt,#btGovDocsReqReSend,#btGovDocsReject").show(); // 2022-11-01 btGovDocsReject 반송 버튼 추가
        	params.statusCd === "accept"	&& $("#btGovDocsManager").show(); //문서상태가 접수인 경우 배부 활성화
        	params.statusCd === "distribute" 	&& $("#btGovDocsManager").show(); //배부되어 배부완료된 문서도 재배부할 수 있음
        	params.statusCd === "distribute" 	&& $("#btGovDocsDistInfo").show(); //문서상태가 배부일경우 배부 활성화
        }else if( govState === "RECEIVEPROCESS" ){
        	//params.statusCd === "return" 	&& $("#btGovDocsManager").show();
        	params.statusCd === "distribute" 	&& $("#btGovDocsManager").show(); //배부되어 배부완료된 문서도 재배부할 수 있음
        	params.statusCd === "distribute" 	&& $("#btGovDocsDistInfo").show(); //배부이력
        }
        
	    if (formJson.BodyContext.RECEIVE_INFO != "" && formJson.BodyContext.RECEIVE_INFO != undefined) {   //대외수신처 영역
	    	$("#DistReceiveLine").show();
	    	$("#RECEIVEGOV_INFO").text();
	    	$("#tblDistDocProperties").show();
	    }
	    
	    $("#DocLinkInfoList").css("display","none");
        
    } else {
        if (getInfo("Request.mode") == "COMPLETE") {
            if (getInfo("FormInstanceInfo.InitiatorID") == getInfo("AppInfo.usid")) {
                //document.getElementById("btDocListDelete").style.display = "";
            }
        }
    }
    if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") {
		if(getInfo("Request.readtype") != "govpreviewWrite"){
        	$("#btDocListSave").show();
		}
    }

    if (getInfo("Request.loct") == "DRAFT" || getInfo("Request.loct") == "TEMPSAVE") {
        if (getInfo("SchemaContext.scCAt4.isUse") == "N" && getInfo("Request.readtype") != "govpreviewWrite") {
			$("#btDocLinked").show();
            //document.getElementById("btDocLink").style.display = "";
        }
    }

    if (getInfo("Request.loct") == "COMPLETE") {
        //document.getElementById("btOTrans").style.display = "";
    }

    m_oFormEditor = window.document;//parent.editor
    m_oFormReader = window.document;//parent.redear

    if (admintype != "ADMIN" && getInfo("Request.loct") == "APPROVAL" && (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "RECAPPROVAL")) {
    	setApvList();
    }
    else {
    	document.getElementById("APVLIST").value = getInfo("ApprovalLine");
    }
    //문서유통사용 & 웹한글기안기 사용시 
    if(getInfo("SchemaContext.scDistribution.isUse")=="Y" && getInfo("ExtInfo.UseWebHWPEditYN") == "Y") {
    	//문서정보 버튼표시
		document.getElementById("btDocInfo").style.display = "";
		//양식명 숨김
		$("#headname").hide();
	}
    
    if(getInfo("Request.readtype") =="govpreview" || getInfo("Request.readtype") =="govpreviewWrite"){
 	   document.getElementById("btExitPreView").style.display = "";
    }
    
    // 문서유통(수신) 문서일 경우 문서정보 숨김
    if(getInfo("ExtInfo.IsGovReceiveForm") == "Y") {
    	//문서정보 버튼표시
		document.getElementById("btDocInfo").style.display = "none";
    	displayDocInfo();
    }
}


//json object로 대체
//getInfo, setInfo 대체 방안
// sKey = $.level1.level2		ex) $.BodyContext.InitiatorDisplay
function getInfo(sKey) {
  try {
	  sKey = "$."+sKey;
      //return formJson.oFormData[sKey];
	  var isExitJsonValue = jsonPath(formJson, sKey).length == undefined ? false : true;
      var formJsonValue = isExitJsonValue ? jsonPath(formJson, sKey)[0] : jsonPath(formJson, sKey);
      
      if (formJsonValue === false && isExitJsonValue === false) {
    	  return undefined;
    	  
      }else if (formJsonValue.constructor === "".constructor) {
    	  
    	  return formJsonValue;
    	  
      }else if (formJsonValue.constructor === [].constructor || formJsonValue.constructor === {}.constructor || formJsonValue.constructor === true.constructor) {
          
    	  return JSON.stringify(formJsonValue);
    	  
      }else {
    	  return undefined;
      }

  }catch (e) {
	  return undefined;
  }
}

function setInfo(sKey, sValue, sException) {
	try {
		var sKeyArr = sKey.split('.');
	  
		switch(sKeyArr.length){
		case 0:
			return undefined;
		default:
			var findKey = sKey.replace(/\./g, ">");					// Jsoner 라이브러리를 통해 찾을 수 있게 변경
	  
			if(sKeyArr.length == 1){
				$$(formJson).attr(sKeyArr[0], sValue);
			}
			else if($$(formJson).find(findKey).exist()) { // 해당 키값이 있을 경우 formJson에 값을 세팅해줌
				$$(formJson).find(findKey.substring(0, findKey.lastIndexOf('>'))).attr(sKeyArr[sKeyArr.length-1], sValue);
			}
			else { // 해당 키값이 없을 경우, formJson에 상위 구조를 만들어준 후 값을 세팅
				var strKey = "";

				$(sKeyArr).each(function(i, key){
					strKey += ">"+key;
					var val;
					if(!$$(formJson).find(strKey).exist()){
						if(i != sKeyArr.length-1)
							val = {};
						else
							val = sValue;
						$$(formJson).find(strKey.substring(0, strKey.lastIndexOf('>'))).attr(key, val);
					}
	  		  	});
			} 
			break;
		}
	} catch (e) {
		if (sException == null) {
			return undefined;
		}
	}
}

function checkSingleDocRead(opener){
	var checkDocRead = 0;
	var doc_param = {};
	var doc_url = "";
	
	doc_param["ProcessID"] = getInfo('Request.processID');
	doc_param["FormInstID"] = getInfo('Request.forminstanceID');
	doc_param["businessData1"] = "APPROVAL";
	
	if(opener.mnid == 483){			//개인함 - 참조/회람
		doc_url = "user/selectApprovalTCInfoSingleDocRead.do";
	} else if(opener.mnid == 489){	//부서함 - 참조/회람
		doc_url = "user/selectDeptTCInfoSingleDocRead.do";
	} else {						//개인함 - 미결함, 부서함 - 수신함
		doc_url = "user/selectSingleDocreadData.do";
	}
		
	$.ajax({
		url: doc_url,
		data : doc_param,
		type:"post",
		async:false,
		success:function (data) {
			//메소드 호출마다 갱신되도록 수정
			checkDocRead = data.cnt;
		},
		error:function(response, status, error){
			CFN_ErrorAjax(doc_url, response, status, error);
		}
	});
	return checkDocRead;
}


function setSubjectHighlight(){
	
	//Form load 완료후 정상작동시 UnreadCount 갱신
	var openerObj;
	
	if(typeof opener != 'undefined' && opener != null){ //팝업 호출시 opener window 여부 확인
		openerObj = opener;
	}else if(typeof top != 'undefined' && top != null){ //미리보기시 top window 여부 확인
		openerObj = top;
	}else{
		return;
	}
	
	//페이지 갱신 method 확인
   	if(typeof openerObj.setDocreadCount !== 'undefined' && typeof openerObj.setDocreadCount === "function" && openerObj.setDocreadCount != null){
   		openerObj.setDocreadCount();

   		var readCnt = checkSingleDocRead(openerObj);
    	if(readCnt==0){
    		return;
   		}
   		var parent_formSubject = ".taTit[onclick^=onClick][onclick*=Button][onclick*=\"" + getInfo('Request.processID') + "\"]";
    	
    	if(getInfo('Request.workitemID') != ""){
    		parent_formSubject += "[onclick*=\"" + getInfo('Request.workitemID')+ "\"]";
    	}
    	if(getInfo('Request.performerID') != ""){
    		parent_formSubject += "[onclick*=\"" + getInfo('Request.performerID')+ "\"]";
    	}
    	if(getInfo('Request.userCode') != ""){    
    	    parent_formSubject += "[onclick*=\"" + getInfo('Request.userCode')+ "\"]";
    	}
    	
    	//단순히 인덱스로 구분하는 것이 아니라 제목으로 구분하고 css설정을 바꿔야 하기 때문에 regular expression을 이용하여 직접 접근 시도
	   	if(openerObj.$(parent_formSubject).css("font-weight") > 400){
	   		openerObj.$(parent_formSubject).css("font-weight", "400");
	   	}
   	}   	
}

//한글 기안기 추가

//문서유통>비공개 사유
function ShowPublicActionHelp() {
    var sTitle = "HELP";
    
    var sUrl2 = "form/goSecOptionHelpPopup.do";
    var iHeight = 530; var iWidth = 830;

    var nLeft = (screen.width - iWidth) / 2;
    var nTop = (screen.height - iHeight) / 2;
    var sWidth = iWidth.toString() + "px";
    var sHeight = iHeight.toString() + "px";
    var sLeft = nLeft.toString() + "px";
    var sTop = nTop.toString() + "px";

    CFN_OpenWindow(sUrl2, "", iWidth, iHeight, "resize");
}


function ChangePublicAction(dataInfo){
	var seldata = $(dataInfo).val();
	if(seldata == 1){
		$("input[name=SecurityOption1]").prop("checked",false);
		$("input[name=SecurityOption1]").prop("disabled", true);
	}else { 
		$("input[name=SecurityOption1]").prop("disabled",false);
	}
}

 

//binary데이터 웹한글 이미지 로딩 
function ConvertToBinaryToHWP(HwpCtrl, callBackFunc){	
	var popInfo =  m_arrConverImgArr.pop();
		
	if(popInfo != undefined){
		HwpCtrl.MoveToField(popInfo.IMGNAME, true, true, true);
		HwpCtrl.SetTextFile(popInfo.BINARYDATA,"HTML", "insertfile",function(data){
				 if(data.result) {
					ConvertToBinaryToHWP(HwpCtrl, callBackFunc);
				 }
		 });
	}
	else if(typeof callBackFunc == "function") {
		callBackFunc(HwpCtrl);
	}
	else{
		HwpCtrl.MoveToField("logo", true, false, false);
	}
}


function convertHTML( html ){	
	var filter = $.convertHWP(html);	
	filter.convertTHtoTD();
	filter.convertTableStyle();	
	var $ele = filter.getObj(); 
	//공백처리 임시로직
	$ele.find('br').replaceWith( $('<a>',{ name : "_blank" })  );
	
	var rtnHtml = filter.getHtml();
	switch (Common.getBaseConfig("EditorType")) {
		case editortypes["dext5"]: // 8
			var DEXT5 = document.getElementById("tbContentElementFrame").contentWindow.DEXT5;
			var rtn = $(DEXT5.convertHWPFilter( rtnHtml )).wrapAll('<div>').parent();
			//rtnHtml = rtn.html();
			$('[name=_blank]',rtn).replaceWith('&nbsp;');
			rtnHtml = rtn.html().replaceAll("&quot;","'");
			break;
		case editortypes["covieditor"]: // 13
			var _covi_editor = document.getElementById('tbContentElementFrame').contentWindow.COVIEDITOR;
			//rtnHtml = _covi_editor.docFilter(rtnHtml);
			var rtn = $(_covi_editor.docFilter(rtnHtml)).wrapAll('<div>').parent();
			$('[name=_blank]',rtn).replaceWith('&nbsp;');
			//rtnHtml = rtn.html().replaceAll("&quot;","'"); // 불필요함
			rtnHtml = rtn.html();
			break;
		default:
			Common.Error(Common.getDic("msg_apv_govBodyFilter")); // 문서유통용 본문필터가 없어 처리할 수 없습니다.
			break;
	}
	
	return rtnHtml;
}

//문서유통> 본문 XML로 구성
function makeBodyContextDist() {
    /*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";*/
	
    var bodyContextObj = {};
	var editorContent = {"tbContentElement" : convertHTML(document.getElementById("dhtml_body").value)};
	
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
	
	//대외수신처 + 수기 입력 수신처
	var receiveCodes = [];
	var receiveNames = [];	
	$("#RECEIVEGOV_NAMES").length > 0 && $("#RECEIVEGOV_NAMES").val().split(";").map(function(item,index){
		var size = item.split(':').length;
		receiveCodes = receiveCodes.concat( item.split(':')[1] );
		receiveNames = receiveNames.concat( item.split(':')[size-1] );	
		bodyContextObj.BodyContext.receiver = receiveCodes.join(';');
		bodyContextObj.BodyContext.receiverName = receiveNames.join(';');
		bodyContextObj.BodyContext.publicationCode = Array.prototype.slice.call( $("[name=SecurityOption1]") ).reduce( function(acc,cur,idx,arr){ return acc += cur.checked ? "Y" : "N" },""); 
		bodyContextObj.BodyContext.publicationValue = $("#Publication option:selected").text();
		bodyContextObj.BodyContext.SaveTerm = $("#Publication option:selected").val();
		bodyContextObj.BodyContext.RECEIVE_INFO = $("#RECEIVEGOV_NAMES").val();
	});
	bodyContextObj.BodyContext.publicationCode = $("#RELEASE_CHECK").val();
	if($("#RELEASE_CHECK").val()=="3"){
		bodyContextObj.BodyContext.publicationCode += Array.prototype.slice.call( $("[name=RELEASE_CODE]") ).reduce( function(acc,cur,idx,arr){ return acc += cur.checked ? "Y" : "N" },"");
	}
	if (getInfo("Request.isgovDocReply") == "Y") {
		bodyContextObj.BodyContext.govDocReply = "Y";
		bodyContextObj.BodyContext.govFormInstID = getInfo("Request.govFormInstID");
	}	
    return bodyContextObj;
}


function chkDivRec(){//수신부서 재기안 및 진행,완료 여부 체크 
	var m_tmpJSON = $.parseJSON(document.getElementById("APVLIST").value);
	var chkRec = "N";
	var appNum = 0;
	
	appNum = $$(m_tmpJSON).find("division").has("taskinfo[status='pending']").find("[divisiontype='receive'] > step").length;	
	appNum += $$(m_tmpJSON).find("division").has("taskinfo[status='completed']").find("[divisiontype='receive'] > step").length;
	
	if(appNum>0){
		return true
	}
	else{
		return false
	}
}

function getFileBinary(fileId,width,height) {
	var fileBinaryData = "";
	$.ajax({
		url	:"/approval/getFileBianary.do?",
		type: "POST",
		async: false,
		data: {
			fileId : fileId
		},
		success:function (data) {
			fileBinaryData = '<img width='+width+' height='+height+' src="data:image/png;base64,'+ data+ '">'; 
		},
		error:function (error){
			Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // error.message
		}
	});
	
	return  fileBinaryData;  
}

function getFileBinaryStamp(fileId,width,height) {
	var fileBinaryData = "";
	$.ajax({
		url	:"/approval/getFileBianary.do?",
		type: "POST",
		async: false,
		data: {
			fileId : fileId
		},
		success:function (data) {
			fileBinaryData = '<img class="imgtag" width='+width+' height='+height+' src="data:image/png;base64,'+ data+ '">'; 
		},
		error:function (error){
			Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // error.message
		}
	});
	
	return  fileBinaryData;  
}



