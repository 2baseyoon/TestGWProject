/* =================== 전역변수 START =================== */

// FormMenu.js
var m_evalJSON;
var g_szAcceptLang = "ko";
var m_sReqMode;
var m_oFormEditor;
var m_bApvDirty = false;
var m_bFrmExtDirty = false;
var m_bFrmInfoDirty = false;
var m_sOPubDocNO = "";
var m_sAddList = "";
var m_ibIdx = 0;
var m_bDeputy = false;
var m_oFormReader;
var m_bFileSave = true;
var m_CmtBln = true;
var m_ApvChangeMode = "";		//결재선변경 모드값
var m_wfid = "";                //현재결재자사번
var m_bTabForm = false;         //탭형태로 양식 open 여부
var m_FixApvLineData = null;    //지정결재선 필요 정보
var m_FixApvLineCTData = "";    //지정결재선 Controller 필요 정보
var m_FixApvLineDAF = null;     //지정결재선 DAF 필요 정보
var sLastComment = "";
var m_TempSave = false;
var m_TempSaveInfo = false;     //임시저장시 subject 자동 입력 되었는지 여부
var m_bTempFlag = false;        //임시로 flag 사용(공통)
var m_sTempString = "";         //임시로 string 사용(공통)

//대성 선결재 위해서 추가함
var m_ActiveTaskId = "";
var m_ApvPersonObj = {};
var m_ApvPersonCnt = 0;

var m_firstIDx = 1;//다안기안 1안

var a, ua = navigator.userAgent;

this.agent = {
    safari: ((a = ua.split('AppleWebKit/')[1]) ? (a.split('(')[0]).split('.')[0] : 0) >= 412,
    konqueror: ((a = ua.split('Konqueror/')[1]) ? a.split(';')[0] : 0) >= 3.4,
    mozes: ((a = ua.split('Gecko/')[1]) ? a.split(" ")[0] : 0) >= 20011128,
    opera: (!!window.opera) && (document.body.style.opacity == ""),
    msie: (!!window.ActiveXObject) ? (!!(new ActiveXObject("Microsoft.XMLHTTP"))) : (navigator.appName == 'Microsoft Internet Explorer') ? true : false
} //safari, konqueror, opera url 한글 인코딩 처리를 위해추가

var btoUtf = ((this.agent.safari || this.agent.konqueror || this.agent.opera) ? false : true);




// FormBody.js
var m_oApvList;
var m_oRecList;
var sReceiveNo = "";
var g_BaseImgURL = mobile_comm_getBaseConfig("BackStorage").replace("{0}", mobile_comm_getSession("DN_Code")) + "e-sign/ApprovalSign/BackStamp/"; // 2022/05 이전 서명표시를 위해서만 사용
var g_BaseFormURL = mobile_comm_getBaseConfig("BackStorage").replace("{0}", mobile_comm_getSession("DN_Code")) + "e-sign/ApprovalForm/"; // 사용안함
var g_BaseSender = "(주) 코 비 젼";
var g_BaseHeader = '"고객과 미래를 함께 합니다"';
var g_BaseORGNAME = '(주) 코 비 젼';
var elmComment; //	의견

var m_KMWebAttURL = '';
var m_sApvMode = "";
var m_print = false; //출력상태여부 - 출력형태로 할때 사용 
var bFileView = false;
var bPresenceView = true;
var bDisplayOnly = false;

//CB작업을 위해 추가
var m_oFormMenu = window;
try { if (m_oFormMenu == null) m_oFormMenu = parent.window; } catch (e) { mobile_comm_log(e); }

/*-----------------------------
editor type : X FORM PRJ.
-------------------------------*/

//에디터 유형 정의
var editortypes = {
	textarea: "0",
	dhtml: "1",
	tagfree: "2",
	xfree: "3",
	tagfreenxfree: "4",
	activesquare: "5",
	crosseditor: "6",
	activesquaredefault: "7"
	// TODO: DEXT5 Test by Kyle 2015-08-03
	, dext5: "8"
	, cheditor: "9"
	, synap: "10"
	, ck: "11"
	, webhwpctrl: "12"
	, covieditor: "13"
	, keditor: "14"
};

//에디터 참조 함수
var editortype = {
	getnum: function () {
		return getInfo("BaseConfig.editortype"); //에디터 타입 번호(Dictionary에서 참조)
	},
	//에디터 이름 반환
	getname: function (n) {
		if (!n) return null;
		var s = n.toString(),
			r;
		for (var i in editortypes) {
			if (editortypes[i] == s) {
				r = i;
				break;
			}
		}
	
		return ((r) ? r : null);
	},
	//숫자 여부 체크
	isNumber: function (n) {
		return !isNaN(parseFloat(n)) && isFinite(n);
	},
	//현재 에디터 번호 또는 에디터 유형 일치 여부를 true/false로 반환
	is: function (s) {
	
		var t = this.getnum(); //editor type number
		if (typeof t === 'undefined') t = '';
	
		if (typeof s === 'undefined') {
			return t; //현재 에디터 번호
		} else {
			if (!this.isNumber(s)) {
				return (t.toString() == editortypes[s]); //에디터 비교
			} else {
				return (t.toString() == s.toString()); //에디터 비교
			}
		}
	},
	//에디터 텍스트명
	name: function () {
		var r = this.getname(this.is());
		return (r) ? r : '';
	}
};

var aryComment = new Array();

/* =================== 전역변수 END =================== */







/* =================== Form.js START =================== */ 

function getInfo(sKey) {
	try {
		sKey = "$."+sKey;
		var isExitJsonValue = jsonPath(formJson, sKey).length == undefined ? false : true;
	    var formJsonValue = isExitJsonValue ? jsonPath(formJson, sKey)[0] : jsonPath(formJson, sKey);
	    
	    if (formJsonValue === false && isExitJsonValue === false) {
	    	return undefined;
	    } else if (formJsonValue.constructor === "".constructor) {
	  	  return formJsonValue;
	    }else if (formJsonValue.constructor === [].constructor || formJsonValue.constructor === {}.constructor || formJsonValue.constructor === true.constructor) {
	  	  return JSON.stringify(formJsonValue);
	    }else {
	  	  return undefined;
	    }
	} catch (e) {
		return undefined;
	}
}

function setInfo(sKey, sValue, sException) {
	try {
		var sKeyArr = sKey.split('.');

		switch (sKeyArr.length) {
		case 0:
			return undefined;
		default:
			var findKey = sKey.replace(/\./g, ">"); // Jsoner 라이브러리를 통해 찾을 수 있게 변경
			if ($$(formJson).find(findKey).exist()) // 해당 키값이 있을 경우 formJson에 값을 세팅해줌
				$$(formJson).find(findKey).parent().attr(sKeyArr[sKeyArr.length - 1], sValue);
			else { // 해당 키값이 없을 경우, formJson에 상위 구조를 만들어준 후 값을 세팅
				var strKey = "";
				if (sKeyArr.length == 1) {
					$$(formJson).attr(sKeyArr[0], sValue);
				}
				$(sKeyArr).each(function(i, key) {
					strKey += ">" + key;
					var val;
					if (!$$(formJson).find(strKey).exist()) {
						if (i != sKeyArr.length - 1)
							val = {};
						else
							val = sValue;
						$$(formJson).find(strKey.substring(0, strKey.lastIndexOf('>'))).attr(key,val);
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

function validateUnderscore(template) {

    var strRet, formDataString="";

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

function getMatches(string, regex, index) {
    index || (index = 1); // default to the first capturing group
    var matches = [];
    var match;
    while (match = regex.exec(string)) {
        matches.push(match[index]);
    }
    return matches;
}

function checkKeyExistInJson(key, targetString) {

    var bRet = false;
    
    if(getInfo(key) != undefined)
    	bRet = true;

    return bRet;
}

//jQuery string.format 처리
//사용법 'this is {0}'.f('apple') => this is apple
String.prototype.format = String.prototype.f = function () {
 var s = this,
     i = arguments.length;

 while (i--) {
     s = s.replace(new RegExp('\\{' + i + '\\}', 'gm'), arguments[i]);
 }
 return s;
};

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

function postJobForDynamicCtrl() {
    var $selectedElms = $('div#editor').find('[data-element-type]').not('[data-type="rField"],[data-type="stField"]')
    if ($selectedElms.length > 0) {
        $selectedElms.each(function (idx, elm) {
            var $elm = $(elm);
            var dataElmType = $elm.attr("data-element-type");
            var dataType = $elm.attr("data-type");

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
                    else if (dataElmType.indexOf('sel_d_t') > -1 || dataElmType.indexOf('rdo_v') > -1) {
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
            	if (formJson.BodyData != null) {
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
}

function postEditorJob(elm) {
	if(getInfo("ExtInfo.UseHWPEditYN") == "Y" || getInfo("ExtInfo.UseMultiEditYN") == "Y") return;
	
    //읽기 처리
    if (getInfo("Request.templatemode") == "Read" && getInfo("FormInfo.FormPrefix") == "WF_FORM_EXTERNAL") {
        var replaceHtml = '';
        replaceHtml += '<table class="table_form_info_draft" cellpadding="0" cellspacing="0" style="width: 100%; margin-top: 5px; table-layout: fixed; min-height: 350px;">';
        replaceHtml += '    <tr>';
        replaceHtml += '        <td width="100%" height="100%" id="{0}" valign="top" style="padding:13px;padding-right:27px"></td>';
        replaceHtml += '    </tr>';
        replaceHtml += '</table>';

        //replacewith
        elm.replaceWith(replaceHtml.f("tbContentElement"));
        //editor 내용 set
        setEditor();
    }
    else if (getInfo("Request.templatemode") == "Read") {
        var minHeight = mobile_comm_getBaseConfig("EditorMinHeight") == "" ? "580" : mobile_comm_getBaseConfig("EditorMinHeight");
        
        var replaceHtml = '';
        replaceHtml += '<table class="table_form_info_draft" cellpadding="0" cellspacing="0" style="margin-top: 5px; table-layout: fixed; min-height: ' + minHeight + 'px; width:100%; border:hidden;">';
        replaceHtml += '    <tr>';
        replaceHtml += '        <td width="100%" height="100%" id="{0}" valign="top" style="padding:0px"></td>';// style="padding:13px;padding-right:27px"
        replaceHtml += '    </tr>';
        replaceHtml += '</table>';

        //replacewith
        elm.replaceWith(replaceHtml.f("tbContentElement"));
        //editor 내용 set
        setEditor();
    }
    else {
    	if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {
    		if(formJson.BodyContext.tbContentElement_Text != undefined) {
            	$(elm).html(formJson.BodyContext.tbContentElement_Text.replace(/(<br>|<br\/>|<br \/>)/g, '\r\n'));
    		}
        }
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
    	//select 내 기본 option 값이 span으로 표시되어 삭제
    	$(elm).parent().find("span").remove();
    	
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

//언어 index 분기 처리
function returnLangUsingLangIdx(langIdx) {
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
		switch (mobile_comm_getBaseConfig("MobileEditorTypeApproval")) {
			case "1"://textarea
				var html = "";
				html += "<textarea id=\"MobileTextArea\" class=\"appforms_table_textarea\" style=\"width: 100%;\"></textarea>";
				$('#' + elm).html(html);
				setEditor();
				break;
		    case "2"://TinyMCE(기본)
				var html = "";
				html += "<iframe id=\"MobileEditorFrame\" src=\"/covicore/resources/script/mobileeditor/mobileeditor.html\" doctype=\"undefined\" marginwidth=\"0\" marginheight=\"0\" frameborder=\"0\" scrolling=\"no\" width=\"100%\" height=\"100%\" ></iframe>";
				$('#' + elm).html(html);
				setEditor();
				break;
		    default:
		        break;
		}
	}
}

//수신부서 재기안 및 진행,완료 여부 체크 
function chkDivRec(){
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

/* =================== Form.js END =================== */







/* =================== FormMenu.js START =================== */

//setPreView 함수 분리
function setPreViewData() {
	try {
     
		if(window.sessionStorage["formjson"] != undefined && _mobile) {
			var formJsonObj = JSON.parse(window.sessionStorage["formjson"]).FormData;
		} 
		if (!formJsonObj.hasOwnProperty("BodyContext") || $.isEmptyObject(formJsonObj.BodyContext)) {
			$.extend(formJsonObj, makeNode("BodyContext", getInfo("BodyContext")));
		}
      
		$.each(formJsonObj, function(key, value) {
			if(key == "BodyContext" || key == "BodyData"){
				setInfo(key, value);
			}else{
				setInfo("FormInstanceInfo."+key, value);
			}
		});
      
		if(formJson.Request.isMobile == "Y" && formJson.BodyContext.MobileBody != undefined){
        	$("#legacyFormDiv").html(formJson.BodyContext.MobileBody);
        }
        else if(formJson.BodyContext.HTMLBody != undefined){
        	$("#legacyFormDiv").html(formJson.BodyContext.HTMLBody);
        }

	} catch (e) {
		alert(e.message);
	}
}

function setPreViewPostRendering() {
    try {
        setInfo("FormInstanceInfo.InitiatedDate", getInfo("AppInfo.svdt"));
        g_szEditable = false;
        setInfo("Request.mode", "COMPLETE");
        setInfo("Request.loct", "COMPLETE");


        if(_mobile && window.sessionStorage["apvlist"] != undefined)
    		document.getElementById("APVLIST").value = window.sessionStorage["apvlist"];

        initOnloadformedit();

        var aBtn = document.getElementsByName("cbBTN");
        for (var i = 0; i < aBtn.length; i++) {
            aBtn[i].style.display = "none";
        }
    } catch (e) {
        alert(e.message);
    }
}

function initOnloadformmenu() {

    if (getInfo("SchemaContext.scCMB.isUse") == null || getInfo("SchemaContext.scCMB.isUse") == "N") {
        m_oFormEditor = window.document;//parent.editor
        m_oFormReader = window.document;//parent.redear

        if (admintype != "ADMIN" && getInfo("Request.loct") == "APPROVAL"
            && (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "AUDIT")) {
            setApvList();
        } else {
            document.getElementById("APVLIST").value = getInfo("ApprovalLine");
        }

        $("#RecDeptList").val(getInfo("FormInstanceInfo.ReceiveNames"));

        document.getElementById("SIGNIMAGETYPE").value = getInfo("AppInfo.usit");

    } 
    document.getElementsByTagName('title')[0].text = _strAppName + " - " + getInfo("FormInfo.FormName");
}

function getDisplayMode(sReadMode, sSchemaOption) {//스키마 옵션에 따른 버튼 활성화	
	if (getInfo("SchemaContext."+sSchemaOption+".isUse") == "Y") { return "Y"; } else { return "N"; }
}


var btDisplay = {
	"btModify" : "N",
	"btHold" : "N",
	"btRejectedto" : "N",
	"btLine" : "N",
	"btDeptLine" : "N",
	"btForward" : "N",
	"btWithdraw" : "N",
	"btAbort" : "N",
	"btApproveCancel" : "N",
	"btReUse" : "N",
	"btApproved" : "N",
	"btReject" : "N",
	"btDeptDraft" : "N",
	"btApprovedlast" : "N",
	"btRejectlast" : "N",
	"btRec" : "N",
	"btCAgree" : "N",
	"btCDisagree" : "N",
	"btConsultationCommentView" : "N",
	"btConsultReq" : "N",
	"btConsultReqCancel" : "N",
	"btConsultReqModify" : "N",
	"btReConsultReq" : "N"
};
function initBtn() {
	btDisplay = {
		"btModify" : "N",
		"btHold" : "N",
		"btRejectedto" : "N",
		"btLine" : "N",
		"btDeptLine" : "N",
		"btForward" : "N",
		"btWithdraw" : "N",
		"btAbort" : "N",
		"btApproveCancel" : "N",
		"btReUse" : "N",
		"btApproved" : "N",
		"btReject" : "N",
		"btDeptDraft" : "N",
		"btApprovedlast" : "N",
		"btRejectlast" : "N",
		"btRec" : "N",
		"btCAgree" : "N",
		"btCDisagree" : "N",
		"btConsultationCommentView" : "N",
		"btConsultReq" : "N",
		"btConsultReqCancel" : "N",
		"btConsultReqModify" : "N",
		"btReConsultReq" : "N"
	};
	var l_ActiveModule = mobile_approval_getActiveModule();
	var viewMode = "view";
    if(getInfo("Request.templatemode") == "Write") {
		viewMode = "write";
	}
    
    // 문서유통(수신) 문서일 경우 문서정보 숨김
    if(getInfo("ExtInfo.IsGovReceiveForm") == "Y") {
    	displayDocInfo();
    }
    
    switch (getInfo("Request.loct")) {
        case "PREAPPROVAL":
        	 // [2019-02-20 MOD] gbhwang 예고함 선결재 기능 추가 관련
            var oApvList = $.parseJSON(document.getElementById("APVLIST").value);
            var lastApproverCode = $$(oApvList).find("steps>division[divisiontype='send']>step[routetype='approve']").last().find("person").attr("code");
            
            // 최종결재자 중 허용된 사용자에 한하여 선결재 기능 사용 가능
            if(mobile_comm_getBaseConfig("PreApproverCode").indexOf(getInfo("AppInfo.usid")) > -1 && lastApproverCode == getInfo("AppInfo.usid")) {
            	btDisplay.btApprovedlast = "Y";
            	btDisplay.btRejectlast = "Y";
            }
        case "PROCESS":
        	if ((getInfo("Request.loct") == "PROCESS") && (getInfo("Request.mode") == "PROCESS" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "AUDIT") && getInfo("FormInstanceInfo.InitiatorID") == getInfo("AppInfo.usid") && getInfo("Request.subkind") == "T006") { //열람
        		m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
                var elmRoot = $(m_evalJSON).find("steps");
                var elmList = $$(elmRoot).find("division>step>ou>person").has("taskinfo[kind!='charge'])");
                var strDate;

                $$(m_evalJSON).find("division>step>ou>person").has("taskinfo[kind!='charge']").each(function (i, elm) {
                    var elmTaskInfo = $$(elm).find("taskinfo");
                    if ($$(elmTaskInfo).attr("datecompleted") != null) {
                        strDate = $$(elmTaskInfo).attr("datecompleted");
                    }
                });
                
                if (!strDate) {
					//수신처 담당자가 pending 상태일 때는 회수 안됨,수신처 수신함에 pending 일 경우 회수 안됨
					elmList = $$(m_evalJSON).find("division").has("taskinfo[status='pending']").find("[divisiontype='receive'] > step > ou");
					if (elmList.length > 0) {
						btDisplay.btWithdraw = "N"; //회수
					}else{
						btDisplay.btWithdraw = "Y";
					}
                }
                
                if (strDate != null && getInfo("SchemaContext.scDraftCancel.isUse") == "Y") {
                    	if(getInfo("Request.gloct") == "" && getInfo("Request.loct") == "PROCESS"){ //임시함에 저장 누락되는 현상 방지
                    		setInfo("Request.gloct", getInfo("Request.loct"));
                    	}
                       btDisplay.btAbort = "Y"; //기안취소
                    }
        	}else if (getInfo("SchemaContext.scApproveCancel.isUse") == "Y"
	            && (getInfo("Request.userCode") == getInfo("AppInfo.usid") || getInfo("ProcessInfo.DeputyID") == getInfo("AppInfo.usid"))
	            && (getInfo("Request.subkind") == "T000" || getInfo("Request.subkind") == "T004" || getInfo("Request.subkind") == "T016" || getInfo("Request.subkind") == "T017")
	            && (getInfo("Request.mode") == "PROCESS" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "AUDIT")
           ){
				m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
	            var elmRoot = $(m_evalJSON).find("steps");
	            var elmList = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step>ou>person>taskinfo[kind!='charge'][kind!='bypass'][kind!='review'][kind!='skip'][kind!='reference'], >step>ou>role>taskinfo[kind!='charge'][kind!='bypass'][kind!='review'][kind!='skip'][kind!='reference']");
	            var strDate;
	            var bCompleted = false; //사용자 결재완료여부
	            var bWICancel = false;  //승인취소 버튼 활성화 여부
	            
	            for(var i=elmList.concat().length; i>0; i--){
	            	var elmTaskInfo = elmList.concat().eq(i-1);
	                var elm = $$(elmTaskInfo).parent();
	                if ($$(elmTaskInfo).attr("status") == "inactive") {      //문서를 받지 않은 경우
	                } else {
	                    if ($$(elmTaskInfo).attr("status") == 'reserved') {  //보류
	                        bCompleted = true;
	                        bWICancel = false;
	                        break;
	                        //return false;
	                    } else if ($$(elmTaskInfo).attr("status") == 'pending') {    //대기 일반결재일때만 승인취소가능
	                        if ((($$(elm).parent()).parent()).attr("routetype") == "approve") {
	                            bCompleted = false;
	                        } else if ((($$(elm).parent()).parent()).attr("routetype") == "assist") {
	                            bCompleted = false;
	                        } else if ((($$(elm).parent()).parent()).attr("routetype") == "consult") {
	                            bCompleted = false;
	                        } else if ((($$(elm).parent()).parent()).attr("routetype") == "audit") {
	                            bCompleted = false;
	                        } else {
	                            bWICancel = false;
	                            break;
	                        }
	                    } else if (bCompleted == false && $$(elmTaskInfo).attr("datecompleted") != null) {
	                        if ($$(elm).parent().attr("wiid") == getInfo("Request.workitemID")) {
	                            bWICancel = true;
	                            break;
	                        }
	                        else {
	                            bWICancel = false;
	                            break;
	                        }
	                    } else {
	                        bWICancel = false;
	                        break;
	                    }
	                }
	            }
	
	            //병렬 유형의 결재자 승인 취소 버튼 제거
	        	if ($$(m_evalJSON).find("division").has("taskinfo[status='pending']").find("step[allottype='parallel']").has("ou[wiid='" + getInfo("Request.workitemID") + "'] > person > taskinfo[status='completed']").has("taskinfo[status='pending']").find("ou[wiid!='" + getInfo("Request.workitemID") + "'] > person").has("taskinfo[status='pending']").length > 0) {
	        		bWICancel = false;
	        	} else if ($$(m_evalJSON).find("division").has("taskinfo[status='pending']").find("step[allottype='parallel']").has("taskinfo[status='completed']").has("ou[wiid='" + getInfo("Request.workitemID") + "'] > person").next().find("ou > person > taskinfo[status='pending']").length > 0) {
	        		bWICancel = false;
	        	}
	            
	            if (getInfo("Request.mode") == "SUBAPPROVAL") {
	                elmList = $$(m_evalJSON).find("division").has("taskinfo[status='pending']").find(">step>ou").has("taskinfo[piid='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "']").find(">person>taskinfo[kind!='charge'][kind!='bypass'][kind!='review'][kind!='skip'][kind!='reference']");
	                if (elmList.length > 0) {
	                    bCompleted = false;
	                    jQuery.fn.reverse = [].reverse;
	                    for(var i=elmList.concat().length; i>0; i--){
	                    	var elmTaskInfo = elmList.concat().eq(i-1);
	                        var elm = $$(elmTaskInfo).parent();
	                        if ($$(elmTaskInfo).attr("status") == "inactive") {//문서를 받지 않은 경우
	                        } else {
	                            if ($$(elmTaskInfo).attr("status") == 'reserved') {//보류
	                                bCompleted = true;
	                                break;
	                            } else if ($$(elmTaskInfo).attr("status") == 'pending') {//대기 일반결재일때만 승인취소가능
	                                if (($$(elm).parent()).attr("routetype") != "approve") {
	                                    bWICancel = false;
	                                    break;
	                                } else {
	                                    bCompleted = false;
	                                }
	                            } else if (bCompleted == false && $$(elmTaskInfo).attr("datecompleted") != null && $$(elm).parent().attr("wiid") == getInfo("Request.workitemID")) {
	                                bWICancel = true;
	                                break;
	                            } else {
	                                bWICancel = false;
	                                break;
	                            }
	                        }
	                    }
	                } else {
	                    bWICancel = false;
	                }
	            }
	
	            //수신처 담당자가 pending 상태일 때는 회수 안됨
	            elmList = $$(m_evalJSON).find("division[divisiontype='receive']").has("taskinfo[status='pending']").find(">step>ou>person").has("taskinfo[kind='normal']");
	            if (elmList.length > 0) {
	                elmList = $$(m_evalJSON).find("division[divisiontype='receive']").has("taskinfo[status='pending']").find(">step>ou>person").has("taskinfo[kind='charge']");
	                if (elmList.length == 0) {
	                    bWICancel = false;
	                }
	            }
	            //수신처 수신함에 pending 일 경우 회수 안됨
	            elmList = $$(m_evalJSON).find("division[divisiontype='receive']").has("taskinfo[status='pending']").find(">step>ou");
	            if (elmList.length > 0) {
	                elmList = $$(m_evalJSON).find("division[divisiontype='receive']").has("taskinfo[status='pending']").find(">step>ou>person").has("taskinfo[kind='charge']");
	                if (elmList.length == 0) {
	                    bWICancel = false;
	                }
	            }
	            if (bWICancel) {
					btDisplay.btApproveCancel = "Y"; //승인취소
	            }
			}
			 break;
        case "COMPLETE":  
            if (getInfo("FormInfo.IsUse") == "N") {
            	btDisplay.btReUse = "N";
            }
            else if (getInfo("FormInstanceInfo.InitiatorID") == getInfo("AppInfo.usid")) {
                if ('COMPLETE' == getInfo("Request.loct") && getInfo("Request.gloct") != "") {        //[2015-05-22 modi kh] 완료함에서만 재사용 버튼 보여주기
                	// 재사용 추후 개발 필요
                	//btDisplay.btReUse = "Y";
                }
            }
        case "CANCEL":
        case "JOBDUTY":
        case "REVIEW":
        case "REJECT":
            displayBtn("N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", getInfo("Request.loct") == "COMPLETE" ? "Y" : "N", "N", "N", "Y");
            
            // 검토 요청
            initConsultationBtn("CommentView");
            break;
        case "DRAFT":
        case "PREDRAFT":
        case "TEMPSAVE":
            displayBtn("Y", "N", getDisplayMode(getInfo("Request.mode"), 'scEdms'), "N", "Y", "N", "N", "N", "N", "Y", "N", "Y", "Y", "N", "N", "Y", "Y");
            /*if (getInfo("ExtInfo.UseApproveSecret") == "Y") {
                document.getElementById("chk_secrecy").checked = true;
                document.getElementById("chk_secrecy").value = "1";
                document.getElementById("chk_secrecy").disabled = true;
            } else {
                document.getElementById("chk_secrecy").disabled = false;
            }
            document.getElementById("chk_urgent").disabled = false;*/
            break;
        case "REDRAFT":
        case "SHARER":
        case "APPROVAL":
            switch (getInfo("Request.mode")) {
                case "SHARER":
                case "APPROVAL": //일반결재
                    displayBtn("N", "N", "N", "N", "Y", "N", "Y", "N", "N", "N", "Y", "N", "N", "N", "N", "N", "Y"); //모든 결재자 첨부파일 추가
                    
                    
                    if (getInfo("SchemaContext.scCHBis.isUse") == "Y") {
                        var oApvList = $.parseJSON(document.getElementById("APVLIST").value);

                    	// "전결/후결/후열/결재안함"이 결재선 내 포함된 경우 편집 불가능하도록 처리
                        // 해당 결재유형 개발 시 조건 삭제 필요
                        if (!fn_GetReview() && $$(oApvList).find("division[divisiontype='send']>step[unittype='person']>ou").has("taskinfo[kind='authorize'], taskinfo[kind='review'], taskinfo[kind='bypass'], taskinfo[kind='skip']").length == 0) { 
                        	btDisplay.btModify = "Y"; 
                        }
                        else {
                        	btDisplay.btLine = "N";
                        	btDisplay.btModify = "N";
                        }
                    } else {
                    	btDisplay.btModify = "N";
                    }
                    // 전달 기능 모바일 내 미구현으로 인한 주석처리 (추후 개발 필요)
                    //if (getInfo("SchemaContext.scTransfer.isUse") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid")) btDisplay.btForward = "Y"; //전달버튼 활성화
                    
                  	//검토 진행 중 모바일 결재 진행 막기
                    initConsultationBtn("APPROVAL");
                    break;
                case "AUDIT": //감사
                case "PCONSULT": //개인합의				
                    displayBtn("N", "N", "N", "N", "Y", "N", "Y", "N", "N", "N", "Y", "N", "N", "Y", "Y", "N", "Y");
                    if (getInfo("SchemaContext.scTransfer.isUse") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid")) btDisplay.btForward = "Y"; //전달버튼 활성화
                    
                    //검토 진행 중 모바일 결재 진행 막기
                    initConsultationBtn("PCONSULT");
                    break;
                case "RECAPPROVAL": //수신결재				
                	btDisplay.btModify = (getInfo("SchemaContext.scRCHBis.isUse") == "Y") ? "Y" : "N";
                    displayBtn("N", "N", "N", "N", "N", "N", "Y", "N", "Y", "N", "Y", "N", "N", "N", "N", "N", "Y"); //모든 결재자 첨부파일 추가					

                    if (getInfo("SchemaContext.scTransfer.isUse") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid")) btDisplay.btForward = "Y"; //전달버튼 활성화
                    
                    initConsultationBtn("RECAPPROVAL");
                    break;
                case "SUBAPPROVAL": //부서합의내결재
                    if (getInfo("SchemaContext.scTransfer.isUse") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid")) btDisplay.btForward = "Y"; //전달버튼 활성화
                    displayBtn("N", "N", "N", "N", "N", "N", "Y", "N", "Y", "N", "Y", "N", "N", "Y", "Y", "N", "Y");

                    var oApvList = $.parseJSON(document.getElementById("APVLIST").value);
                    if ($$(oApvList).find("division:has(taskinfo[status='pending'])").find("step").has("taskinfo[status='pending']").attr("routetype") == "consult") {
                    	$("#"+l_ActiveModule+"_"+viewMode+"_btApproval").contents().filter(function(){ return this.nodeType === 3; }).replaceWith(mobile_comm_getDic("lbl_apv_agree")); //동의
                    	$("#"+l_ActiveModule+"_"+viewMode+"_btReject").contents().filter(function(){ return this.nodeType === 3; }).replaceWith(mobile_comm_getDic("lbl_apv_disagree")); //거부
                    }
                    break;
                case "DEPART": //부서
                    break;
                case "CHARGE": //담당자				
                    displayBtn("N", "N", "N", "N", "N", "N", "Y", "N", "N", "N", "Y", "N", "N", "Y", "Y", "N", "Y"); break;
                case "REDRAFT": //재기안
                    var sdisplay = "Y";
                    var sAttDisplay = "Y";
                    if (getInfo("Request.subkind") == "T008") {
                        displayBtn("N", "N", "N", "N", "Y", "N", "Y", "N", "N", "N", "Y", (getInfo("SchemaContext.scCHBis.isUse") == "Y") ? "Y" : "N", "N", "N", "N", "Y", "Y");
                    } else {
                        sAttDisplay = "";
                        //2009.02 : 문서관리자 권한 설정
                        if (getInfo("SchemaContext.scRec.isUse") == "Y") {
                            sdisplay = "N";
                            sAttDisplay = "N";
                            if (getInfo("AppInfo.usismanager") == "true" || getInfo("Request.usisdocmanager") == "true") { // || getInfo("dpisdocmanager") == "false") { - dpisdocmanager 비사용
                                if (getInfo("Request.userCode") == getInfo("ProcessInfo.UserCode")) {
                                	btDisplay.btRec = "Y";
                                    btDisplay.btReject = "Y";
                                } else {
                                	btDisplay.btRec = "N";
                                }
                            }
                        }
                        if (getInfo("SchemaContext.scRecBtn.isUse") == "Y") { sdisplay = "Y"; sAttDisplay = "Y"; }
                        if (getInfo("Request.loct") == "REDRAFT" && getInfo("Request.mode") == "REDRAFT") {//신청서 수신함 조회 시
                            displayBtn("N", "N", "N", "N", "N", "N", "Y", "N", "Y", "N", "Y", "N", "N", "N", "N", "Y", "Y"); //모든 결재자 첨부파일 추가					
                            //2009.02 : 문서관리자 권한 설정
                            if (getInfo("AppInfo.usismanager") == "true" || getInfo("Request.usisdocmanager") == "true"){ 
                                btDisplay.btLine = "N";
                                btDisplay.btDeptLine = "Y";
                                if (getInfo("SchemaContext.scRCHBis.isUse") == "Y") { btDisplay.btModify = "Y"; } //2009.01 광주은행 요청사항 접수상태서 내용 변경 가능하도록
                            } else {
                                btDisplay.btLine = "N";
                                btDisplay.btDeptLine = "N";
                            }
                        } else {
                            displayBtn("N", "N", "N", "N", "N", "N", "N", "N", sdisplay, "N", "N", sAttDisplay, "N", "Y", "Y", "Y", "Y");
                        }
                    }
                    btDisplay.btModify = (getInfo("SchemaContext.scRCHBis.isUse") == "Y") ? "Y" : "N";
                    if (getInfo("SchemaContext.scTransfer.isUse") == "Y" && getInfo("SchemaContext.pdefname.value").indexOf('Draft') == -1 && getInfo("Request.userCode") == getInfo("AppInfo.dpid")) btDisplay.btForward = "Y"; //전달버튼 활성화

                    break;
                case "SUBREDRAFT": //합의재기안
                    if (getInfo("SchemaContext.scTransfer.isUse") == "Y") btDisplay.btForward = "Y";
                    displayBtn("N", "N", "N", "N", "N", "N", "N", "N", "Y", "N", "N", "N", "N", "N", "Y", "Y", "Y");
                    if (getInfo("AppInfo.usismanager") == "true" || getInfo("Request.usisdocmanager") == "true"){ 
                        if (getInfo("SchemaContext.scTransfer.isUse") == "Y") btDisplay.btForward = "Y";
                       
                        btDisplay.btLine = "N"; //"결재선관리"
                        if (getInfo("SchemaContext.scRecAssist.isUse") == "Y") {
                            sdisplay = "N";
                            sAttDisplay = "N";
                            if (getInfo("Request.userCode") == getInfo("ProcessInfo.UserCode")) {
                            	btDisplay.btRec = "Y";
                                btDisplay.btReject = "Y";
                                
                                if (getInfo("ProcessInfo.SubKind") == "C") {
                                	$("#"+l_ActiveModule+"_"+viewMode+"_btReject").contents().filter(function(){ return this.nodeType === 3; }).replaceWith(mobile_comm_getDic("lbl_apv_disagree")); //거부
                                }
                            } else {
                            	btDisplay.btRec = "N";
                            }
                        }
                        displayBtn("N", "N", "N", "N", "N", "N", "Y", "N", "Y", "N", "N", "N", "N", "N", "Y", "Y", "Y");
                    } else if (getInfo("Request.subkind") == "T008") {
                        btDisplay.btLine = "N"; //"결재선관리"
                        displayBtn("N", "N", "N", "N", "N", "N", "N", "N", "Y", "N", "N", "N", "N", "N", "Y", "Y", "Y");
                    } else {
                        btDisplay.btLine = "N";
                        btDisplay.btDeptLine = "N";
                    }
                    break;
                case "CONSULT":
                    btDisplay.btCAgree = "Y";
                    btDisplay.btCDisagree = "Y";
                    //검토의견조회
                    btDisplay.btConsultationCommentView = "Y";
                	break;
            }

            if (getInfo("Request.templatemode") == "Write") {
                btDisplay.btModify = "N";
            }

            //20110318 확인결재추가
            if (getInfo("Request.subkind") == "T019") btDisplay.btModify = "N";
            //후결추가
            if (getInfo("Request.subkind") == "T005" || getInfo("Request.subkind") == "T018") {
                btDisplay.btHold = "N"; btDisplay.btRejectedto = "N"; btDisplay.btForward = "N";
                btDisplay.btModify = "N";
            }
            break;
    }
    
    // 모바일 전달기능 미구현 상태이므로 숨김. 2023.7
    btDisplay.btForward = "N";
    
    if (getInfo("Request.templatemode") == "Read") {
    	// 사용 가능한 버튼이 1개 이상인 경우에만 확장메뉴 조회 가능
    	for(var key in btDisplay) {
    		if(key !== "btApproved" && key !== "btReject" && key !== "btRec" && key !== "btDeptDraft" && key !== "btCAgree" && key !== "btCDisagree"){
	    		if(btDisplay[key] == "Y") {
	    			$("#approval_view_dropMenuBtn").show();
	    			break;
	    		}
    		}
    	}
    }
	
    // 승인 반려 버튼 활성화
	if(getInfo("Request.mode") == "PCONSULT" && getInfo("Request.subkind") == "T009") {
		$("#"+l_ActiveModule+"_"+viewMode+"_btApproval").contents().filter(function(){ return this.nodeType === 3; }).replaceWith(mobile_comm_getDic("lbl_apv_agree")); //합의
		$("#"+l_ActiveModule+"_"+viewMode+"_btReject").contents().filter(function(){ return this.nodeType === 3; }).replaceWith(mobile_comm_getDic("lbl_apv_disagree")); //거부
	}
	
	$("#"+l_ActiveModule+"_"+viewMode+"_btApproval").removeClass("full").hide();
	$("#"+l_ActiveModule+"_"+viewMode+"_btDeptDraft").removeClass("full").hide();
	$("#"+l_ActiveModule+"_"+viewMode+"_btRec").removeClass("full").hide();
	$("#"+l_ActiveModule+"_"+viewMode+"_btReject").removeClass("full").hide();
	$("#"+l_ActiveModule+"_"+viewMode+"_buttonarea").show();
	if(btDisplay.btApproved === "Y") {
		if(btDisplay.btReject === "N") {
			$("#"+l_ActiveModule+"_"+viewMode+"_btApproval").addClass("full").show();
		} else {
			$("#"+l_ActiveModule+"_"+viewMode+"_btApproval").show();
			$("#"+l_ActiveModule+"_"+viewMode+"_btReject").show();
		}
	} else if(btDisplay.btRec === "Y"){
		if(btDisplay.btReject === "N") {
			$("#"+l_ActiveModule+"_"+viewMode+"_btRec").addClass("full").show();
		} else {
			$("#"+l_ActiveModule+"_"+viewMode+"_btRec").show();
			$("#"+l_ActiveModule+"_"+viewMode+"_btReject").show();
		}
	} else if(btDisplay.btDeptDraft === "Y"){
		if(btDisplay.btReject === "N") {
			$("#"+l_ActiveModule+"_"+viewMode+"_btDeptDraft").addClass("full").show();
		} else {
			$("#"+l_ActiveModule+"_"+viewMode+"_btDeptDraft").show();
			$("#"+l_ActiveModule+"_"+viewMode+"_btReject").show();
		}
	} else if(btDisplay.btReject === "Y") {
		$("#"+l_ActiveModule+"_"+viewMode+"_btReject").addClass("full").show();
	} else if(btDisplay.btCAgree === "Y" && btDisplay.btCDisagree === "Y"){
		$("#approval_view_buttonarea").find("a:not(#"+l_ActiveModule+"_"+viewMode+"_btCAgree, #"+l_ActiveModule+"_"+viewMode+"_btCDisagree)").remove();
		$("#"+l_ActiveModule+"_"+viewMode+"_btCAgree").show();
		$("#"+l_ActiveModule+"_"+viewMode+"_btCDisagree").show();
	} else {
		$("#"+l_ActiveModule+"_"+viewMode+"_buttonarea").hide();
	}
}


//검토기능 버튼 처리
function initConsultationBtn(getMode) {
	// 검토 요청
	if(getInfo("SchemaContext.scConsultation.isUse") === "Y"){
	    var oCurr = $$($.parseJSON(getInfo("ApprovalLine"))).find("step > ou").concat().find("[wiid='" +getInfo("Request.workitemID")+ "']").find("person").concat().find("[code='"+getInfo("Request.userCode")+"']");
	    if(getMode == "PCONSULT"){
	    	oCurr = $$($.parseJSON(getInfo("ApprovalLine"))).find("step > ou").concat().find("[wiid='" +getInfo("Request.workitemID")+ "']").find("person[code='"+getInfo("Request.userCode")+"']");
	    }
	    
	    if(getMode == "CommentView" && (oCurr.find("consultation[status!='canceled']").length > 0 || getInfo("Request.subkind") === "T023")){
			//검토의견조회
			btDisplay.btConsultationCommentView = "Y";
		}else if(oCurr.find(">consultation[status!='canceled']").length > 0){
			var oConsultUserInfo = $$(oCurr.find(">consultation[status!='canceled']").concat().find(">consultusers > taskinfo")).json();
			if(!$.isArray(oConsultUserInfo)){ oConsultUserInfo = [].concat(oConsultUserInfo); }
			oConsultUserInfo = oConsultUserInfo.every(function(item){ return item.status === "completed"; });
			var oCurrStatus = oCurr.find(">taskinfo").attr("status");
    		//검토의견조회
    		btDisplay.btConsultationCommentView = "Y";
    		if(oCurrStatus !== "pending" && !oConsultUserInfo){
    			btDisplay.btModify = "N";
    			btDisplay.btLine = "N";
    			btDisplay.btApproved = "N";
    			btDisplay.btReject = "N";
    			btDisplay.btHold = "N";
				btDisplay.btRejectedto = "N";
				btDisplay.btForward = "N";
				btDisplay.btConsultReqCancel = "Y";
				btDisplay.btConsultReqModify = "Y";
        	} else {
        		strApvLineYN = "Y";
        		//재검토요청 보이기
        		var oConsultationInfo = $$(oCurr.find(">consultation[status!='canceled']").concat()).json();
        		if(!$.isArray(oConsultationInfo)){ oConsultationInfo = [].concat(oConsultationInfo); }
        		if( oConsultationInfo.every(function(item){ return item.status === "completed"; }) ){
        			btDisplay.btReConsultReq = "Y";
        		}
        	}
    	}else{
    		if(getInfo("Request.loct") == "APPROVAL") btDisplay.btConsultReq = "Y";
    	}
	}
}

function displayBtn(sDraft, schangeSave, sDoc, sPost, sLine, sRecDept, sAction, sDeptDraft, sDeptLine, sSave, sMail, sAttach, sPreview, sCommand, sRec, sTempMemo, sInfo) {
	btDisplay.btLine = sLine;
	btDisplay.btDeptDraft = sDeptDraft;
	btDisplay.btDeptLine = sDeptLine;
	
    //기밀문서 권한 지정
    /*if (getInfo("ProcessInfo.ProcessDescription.IsSecureDoc") == "Y") {
        document.getElementById("chk_secrecy").checked = true;
    }*/

    if (sAction == "Y")
    {
        var bReviewr = fn_GetReview();
        if (getInfo("Request.mode") == "SUBREDRAFT") {
        	var m_evalJSON_subRe = $.parseJSON(document.getElementById("APVLIST").value);
            var elmRoot_subRe = $$(m_evalJSON_subRe).find("steps");
            var elmRoot_subReOu = $$(elmRoot_subRe == undefined ? {} : elmRoot_subRe ).find("division").has(">taskinfo[status='pending']").find(">step[unittype='ou']>ou").has("taskinfo[status='pending'][piid='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "']");
            if ($$(elmRoot_subReOu).find("person").concat().length > 1) {
            	btDisplay.btRec = "N";
            	btDisplay.btApproved = "N";
            	btDisplay.btDeptDraft = "Y";
            } else {
            	if(getInfo("SchemaContext.scChrDraft.isUse") == "Y") {
                	btDisplay.btRec = "Y";
                	btDisplay.btApproved = "N";
            	} else if (getInfo("SchemaContext.scChrRedraft.isUse") == "Y") {
                	btDisplay.btRec = "N";
                	btDisplay.btApproved = "Y";
            	}
            	btDisplay.btDeptDraft = "N";
            }
        } else if (getInfo("Request.mode") == "REDRAFT") {
        	if(getInfo("SchemaContext.scRec.isUse") == "Y"){ // 접수/반려버튼 활성화
        		btDisplay.btRec = "Y";
                if (!bReviewr) btDisplay.btReject = "Y"
        	} else if(getInfo("SchemaContext.scChrRedraft.isUse") == "Y") { //담당자 재기안이고, 1인결재가 가능한 경우 결재버튼 활성화
                btDisplay.btApproved = "Y"
                if (!bReviewr) btDisplay.btReject = "Y"
            }

            {  
            	var m_evalJSON_receive = $.parseJSON(document.getElementById("APVLIST").value);
                var elmRoot_receive = $$(m_evalJSON_receive).find("steps");
                var elmRouCount_receive = $$(elmRoot_receive == undefined ? {} : elmRoot_receive ).find("division[divisiontype='receive'][oucode='" + getInfo("AppInfo.dpid_apv") + "']>ou>person>taskinfo[kind != 'charge']").length;
                if (elmRouCount_receive > 0) {
                	//재기안
                	btDisplay.btDeptDraft = "Y";
                	btDisplay.btApproved = "N";
                	btDisplay.btRec = "N";
                }
            }
        } else {
            //20110318 확인결재추가
            if (getInfo("Request.subkind") == "T019" || getInfo("Request.subkind") == "T005" || getInfo("Request.subkind") == "T018" || getInfo("Request.subkind") == "T020") {//확인결재
                btDisplay.btApproved = "Y"
            } else {
                btDisplay.btApproved = "Y"
                if (!fn_GetReview()) btDisplay.btReject = "Y"
            }
        }
        switch (getInfo("Request.mode")) {
            case "PCONSULT":
            case "SUBAPPROVAL": //합의부서내 결재
                if (getInfo("SchemaContext.scRJTO.isUse") == "Y" && fn_checkrejectedtoA()) { btDisplay.btRejectedto = "Y" }

                if (mobile_comm_getBaseConfig('useHold') == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid") && getInfo("Request.subkind") != "T019") { btDisplay.btHold = "Y"; }
                break;
            case "RECAPPROVAL": //수신부서내 결재
            case "APPROVAL":
                if (getInfo("SchemaContext.scRJTO.isUse") == "Y" && fn_checkrejectedtoA()) { if (!bReviewr) btDisplay.btRejectedto = "Y" }
                
                if (mobile_comm_getBaseConfig('useHold') == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid") && getInfo("Request.subkind") != "T019") { if (!bReviewr) btDisplay.btHold = "Y"; }
                break;
            case "CHARGE":
                break;
            case "REDRAFT":
                if (mobile_comm_getBaseConfig('useHold') == "Y" && getInfo("Request.subkind") == "T008" && getInfo("Request.loct") == "APPROVAL" && getInfo("Request.gloct") == "JOBFUNCTION") { btDisplay.btHold = "Y"; }
                break;
        }
    }
}

/*지정 반송 check*/
function fn_checkrejectedtoA() {
	if (getInfo("Request.subkind") == "T000") {
		var m_oApvList = $.parseJSON(document.getElementById("APVLIST").value);
		var elmRoot = $$(m_oApvList).find("steps");
		
		var oApprovedSteps;
		if (getInfo("Request.mode") == "RECAPPROVAL") {
			//oApprovedSteps = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step[routetype='approve'] > ou > person > taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][status='completed'][kind!='charge'] , > step[routetype='approve'] > ou > role > taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][status='completed'][kind!='charge'] ");
			oApprovedSteps = $$(elmRoot).find("division").has("taskinfo[status='pending']").find("> step[routetype='approve'] > ou > person > taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][kind!='conveyance'][status='completed']");
		} else if (getInfo("Request.mode") == "SUBAPPROVAL") { ///ou[taskinfo/@status='pending']/person[taskinfo/@kind='normal' and taskinfo/@status='inactive']
			oApprovedSteps = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step").has("taskinfo[status='pending']").find("ou").has("taskinfo[status='pending'][piid='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "']").find("> person > taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][kind!='conveyance'][status='completed']");
		} else {
			oApprovedSteps = $$(elmRoot).find("division").has("taskinfo[status='pending']").find("> step[routetype='approve'] > ou > person > taskinfo[kind!='charge'][kind!='review'][kind!='bypass'][kind!='skip'][kind!='conveyance'][status='completed']");
		}
		
		if (getInfo("SchemaContext.scRJTO.isUse") == "Y" && getInfo("SchemaContext.scRJTO.value") != "") {
			var iRJCnt = 0;
			var oRJSteps;
			
			if (getInfo("Request.mode") == "RECAPPROVAL") {
				oRJSteps = $$(elmRoot).find("division").has("taskinfo[status='pending']").find("> step[routetype='approve'] > ou > person > taskinfo[@rejectee='y']");
			} else if (getInfo("Request.mode") == "SUBAPPROVAL") {
				oRJSteps = $$(elmRoot).find("division").has("taskinfo[status='pending']").find("> step[routetype='consult'] > ou").has("taskinfo[status='pending'][piid='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "']").find("> person > taskinfo[rejectee='y'], > role > taskinfo[rejectee='y']");
			} else {
				oRJSteps = $$(elmRoot).find("division").has("taskinfo[status='pending']").find("step[routetype='approve']>ou").find("> person > taskinfo[rejectee='y'] , role > taskinfo[rejectee='y'] ")
			}
			
			iRJCnt = oRJSteps.length;
			if (iRJCnt >= parseInt(getInfo("SchemaContext.scRJTO.value"))) {
				return false;
			}
		}
		if (oApprovedSteps.length == 0) {
			return false;
		} else {
			var iApvCNT = 0;
			var szCode = "";
			var szName = "";
			
			$$(oApprovedSteps).concat().each(function (i, oTaskInfo) {
				var oStep = oTaskInfo.parent().parent().parent();
				if ($$(oStep).attr("allottype") != "parallel") {
					if ($$(oTaskInfo).attr("rejectee") != 'y') {
						iApvCNT++;
						szCode = $$(oTaskInfo).attr("wiid");
					}
				}
			});
			if (iApvCNT > 0) {
				return true;
			} else {
				return false;
			}
		}
	} else {
		return false;
	}
}

//후결여부 체크
function fn_GetReview() {
	
	var m_apvJSON = $.parseJSON(document.getElementById("APVLIST").value);
    var oReviewNode = $$(m_apvJSON).find("steps>division>step>ou>person").has("taskinfo[kind='review'][status='pending'])");
    if (oReviewNode.length != 0) {
        if (getInfo("AppInfo.usid") == $(oReviewNode).attr("code")) {
            return true
        }
    }
    return false;
}

function setApvList() {//대결일 경우 처리
    try {
    	var strApv = getInfo("ApprovalLine");
    	var jsonApv;

    	if(window.sessionStorage["open_mode"] == "APVLIST" && window.sessionStorage["processid"] == _mobile_approval_view.ProcessID && window.sessionStorage["apvlist"] != undefined) { //결재선 편집 후 재조회 시
    		strApv = window.sessionStorage["apvlist"];
        }

        jsonApv = $.parseJSON(strApv);
        
        if (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "AUDIT") { //기안부서결재선 및 수신부서 결재선
            var oFirstNode; //step에서 taskinfo select로 변경

            if (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL") {
                oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[routetype='approve']>ou>person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'],step[routetype='approve']>ou>role:has(person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'])");
                
                if (getInfo("Request.mode") == "SUBAPPROVAL"  && oFirstNode.length == 0) {
                	oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[routetype!='approve']>ou>person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'], step[routetype!='approve']>ou>role:has(person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'])");
                }
                if (oFirstNode.length == 0) { //편집 후 결재 시 대결 오류로 인하여 소스 추가
                    oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[routetype='approve']>ou>person[code='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'][kind='substitute']");
                }
                }
            else if (getInfo("Request.mode") == "RECAPPROVAL") {
                oFirstNode = $$(jsonApv).find("steps>division[divisiontype='receive']>taskinfo[status=pending]").parent().find("step[routetype='approve']>ou>person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'],step[routetype='approve']>ou>role:has(person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'])");
                if (oFirstNode.length == 0) { //편집 후 결재 시 대결 오류로 인하여 소스 추가
                    oFirstNode = $$(jsonApv).find("steps>division[divisiontype='receive']>taskinfo[status=pending]").parent().find("step[routetype='approve']>ou>person[code='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'][kind='substitute']");
                }
                }
            else if (getInfo("Request.mode") == "PCONSULT") {
                oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step>ou>person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'], step>ou>role>taskinfo:has(person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'])[status='pending']");
            } else if (getInfo("Request.mode") == "AUDIT") {
                oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[routetype='audit']>ou>person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'] > taskinfo[status='pending'],step[routetype='audit']>ou>role:has(person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'])");
            } else {
                oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[unittype='ou'][routetype='receive']>ou>person[code!='" + getInfo("AppInfo.usid") + "']>taskinfo[kind!='charge'][status='pending']");
            }
            if (oFirstNode.length != 0) {
            	alert(mobile_comm_getDic("msg_ApprovalDeputyWarning"));
            	
                m_bDeputy = true; m_bApvDirty = true; var elmOU; var elmPerson;
                switch (getInfo("Request.mode")) {
                    case "APPROVAL":
                    case "PCONSULT":
                    case "SUBAPPROVAL":
                    case "RECAPPROVAL":
                    case "AUDIT":
                        elmOU = $$(oFirstNode).parent().parent();
                        elmPerson = $$(oFirstNode).parent();
                        break;
                }
                var elmTaskInfo = $$(elmPerson).find("taskinfo");
                var skind = $$(elmTaskInfo).attr("kind");
                var sallottype = "serial";
                var elmStep = $$(elmOU).parent();
                try { if ($$(elmStep).attr("allottype") != null) sallottype = $$(elmStep).attr("allottype"); } catch (e) { mobile_comm_log(e); }
                //taskinfo kind에 따라 처리  일반결재 -> 대결, 대결->사용자만 변환, 전결->전결, 기존사용자는 결재안함으로
                switch (skind) {
                    case "substitute": //대결
                        if (getInfo("Request.mode") == "APPROVAL") {
                            $$(elmOU).attr("code", getInfo("AppInfo.dpid_apv"));
                            $$(elmOU).attr("name", getInfo("AppInfo.dpdn_apv"));
                        }
                        $$(elmPerson).attr("code", getInfo("AppInfo.usid"));
                        $$(elmPerson).attr("name", getInfo("AppInfo.usnm_multi"));
                        $$(elmPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
                        $$(elmPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
                        $$(elmPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
                        $$(elmPerson).attr("oucode", getInfo("AppInfo.dpid"));
                        $$(elmPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
                        $$(elmPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
                        $$(elmTaskInfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        break;
                    /*case "authorize"://전결 결재안함
                        $$(elmTaskInfo).attr("status", "completed");
                        $$(elmTaskInfo).attr("result", "skipped");
                        $$(elmTaskInfo).attr("kind", "skip");
                        $$(elmTaskInfo).remove("datereceived");
                        break;*/
                    case "consent": //합의 -> 후열
                    case "charge":  //담당 -> 후열
                    case "consult":
                    case "normal":  //일반결재 -> 후열
                    case "authorize"://전결 결재안함
                        $$(elmTaskInfo).attr("status", "inactive");
                        $$(elmTaskInfo).attr("result", "inactive");
                        $$(elmTaskInfo).attr("kind", "bypass");
                        $$(elmTaskInfo).remove("datereceived");
                        break;
                }
                if (skind == "authorize" || skind == "normal" || skind == "consent" || skind == "charge" || skind == "consult") {
                    var oStep = {};
                    var oOU = {};
                    var oPerson = {};
                    var oTaskinfo = {};
                    
                    $$(oTaskinfo).attr("status", "pending");
                    $$(oTaskinfo).attr("result", "pending");
                    //$$(oTaskinfo).attr("kind", (skind == "authorize") ? skind : "substitute");
                    $$(oTaskinfo).attr("kind", "substitute"); // 대결로 처리되는 경우 대결자 완료함에서 문서 열람이 가능해야 함!
                    $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                    
                    $$(oPerson).attr("code", getInfo("AppInfo.usid"));
                    $$(oPerson).attr("name", getInfo("AppInfo.usnm_multi"));
                    $$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
                    $$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
                    $$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
                    $$(oPerson).attr("oucode", getInfo("AppInfo.dpid"));
                    $$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
                    $$(oPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
                    
                    if(getInfo("Request.mode") == "SUBAPPROVAL") {
                    	$$(oPerson).attr("wiid", $$(elmPerson).attr("wiid"));
                    	$$(oPerson).attr("taskid", $$(elmPerson).attr("taskid"));
                    }
                    
                    $$(oPerson).append("taskinfo", oTaskinfo);
                    
                    $$(elmOU).append("person", oPerson);							// person이 object일 경우를 위해서 추가하여 배열로 만듬
                    
                    if(getInfo("Request.mode") == "SUBAPPROVAL") {
                    	// todo: person의 index 구하는 방법 변경할 수 있으면 다른방법으로 교체할 것
                    	$$(elmOU).find("person").json().splice(parseInt(oFirstNode.parent().path().substr(oFirstNode.parent().path().lastIndexOf("/")+8, 1)), 0, oPerson);
                    } else {
                    	$$(elmOU).find("person").json().splice(0, 0, oPerson);			// 다시 앞에 추가
                    }
                    $$(elmOU).find("person").concat().eq($$(elmOU).find("person").concat().length-1).remove();			// 배열로 만들기 위해서 추가했던 person을 지움
                    
                    if (skind == 'charge') {
                        oFirstNode = oStep;
                        
                        var oStep = {};
                        var oOU = {};
                        var oPerson = {};
                        var oTaskinfo = {};
                        
                        $$(oStep).attr("unittype", "person");
                        $$(oStep).attr("routetype", "approve");
                        $$(oStep).attr("name", mobile_comm_getDic("lbl_apv_writer"));		//gLabel__writer);
                        
                        $$(oOU).attr("code", getInfo("AppInfo.dpid_apv"));
                        $$(oOU).attr("name", getInfo("AppInfo.dpdn_apv"));
                        
                        $$(oPerson).attr("code", getInfo("AppInfo.usid"));
                        $$(oPerson).attr("name", getInfo("AppInfo.usnm_multi"));
                        $$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
                        $$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
                        $$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
                        $$(oPerson).attr("oucode", getInfo("AppInfo.dpid"));
                        $$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
                        $$(oPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
                        
                        $$(oTaskinfo).attr("status", "complete");
                        $$(oTaskinfo).attr("result", "complete");
                        $$(oTaskinfo).attr("kind", "charge");
                        $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        $$(oTaskinfo).attr("datecompleted", getInfo("AppInfo.svdt_TimeZone"));
                        
                        $$(oPerson).append("taskinfo", oTaskinfo);
                        
                        $$(oOU).append("person", oPerson);
                        
                        $$(oStep).append("ou", oOU);
                        
                        $$(jsonApv).find("steps>division").append("step", oStep);
                        $$(jsonApv).find("steps>division>step").json().splice(0, 0, oStep);
                        $$(jsonApv).find("steps>division>step").concat().eq($$(jsonApv).find("steps>division>step").concat().length-1).remove();
                    }
                }

                var oResult = $$(jsonApv).json();

                document.getElementById("APVLIST").value = JSON.stringify(oResult);
            }
            else {
                document.getElementById("APVLIST").value = strApv;
            }
        }
        else {
            document.getElementById("APVLIST").value = strApv;
        }
    }
    catch (e) {
        alert(e.message);
    }
}

function setDomainData() {
	/* 서버에서 만든 자동결재선 데이터 가져오기 처리 */
	var data = {};
	if(getInfo("WorkedAutoApprovalLine") != undefined)
		data = getInfo("WorkedAutoApprovalLine");
	/* 자동결재선 데이터를 파라미터로 넘김 */
	receiveApvHTTP(data);
}

function receiveApvHTTP(responseJSONdata) {
    if ($$(responseJSONdata) != null) {
        var errorNode = $$(responseJSONdata).find("error");
        if ($(errorNode).length > 0) {
            alert("Desc: " + errorNode.val());
        } else {
            var elmList = $$(responseJSONdata).find("steps");
            if (getInfo("Request.mode") == 'DRAFT' || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "REDRAFT" || (getInfo("Request.mode") == "SUBREDRAFT")) {
                var oApvList = $.parseJSON(document.getElementById("APVLIST").value);
                if (oApvList == null) {
                    alert(gMessage75); //"결재선 지정 오류"
                } else {
                    m_bApvDirty = true;
                    var oGetApvList = {};
                    if ($$(responseJSONdata).find("steps").exist()) {
                        // 2016.01.06 leesm 결재선 내 & 문자열로 인해 오류 발생으로 수정함
                        oGetApvList = $.parseJSON(responseJSONdata.replace(/&/gi, '&amp;'));
                    }
                    var oCurrentOUNode;
                    if (getInfo("Request.mode") == "REDRAFT") {
                        //담당부서 - 담당부서 및 담당업무 결재선 삭제할것 그 후로 기안자 결재선 입력할것
                    	oCurrentOUNode = $$(oApvList).find("steps > division").children().find("[divisiontype='receive']").has(">taskinfo[status='pending']");
                        if (oCurrentOUNode == null) {
                        	var oDiv = {};
                        	$$(oDiv).attr("taskinfo", {});
                        	$$(oDiv).attr("step", {});
                        	$$(oDiv).attr("divisiontype", "receive");
                        	$$(oDiv).attr("name", mobile_comm_getDic("lbl_apv_ChargeDept"));
                            $$(oDiv).attr("oucode", getInfo("AppInfo.dpid_apv"));
                            $$(oDiv).attr("ouname", getInfo("AppInfo.dpdn_apv"));
                        	
                            $$(oDiv).find("taskinfo").attr("status", "pending");
                            $$(oDiv).find("taskinfo").attr("result", "pending");
                            $$(oDiv).find("taskinfo").attr("kind", "receive");
                            $$(oDiv).find("taskinfo").attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        	
                        	$$(oApvList).find("division").push(oDiv);
                        	
                            oCurrentOUNode = $$(oApvList).find("steps > division:has(>taskinfo[status='pending'])[divisiontype='receive']");
                        }
                        var oRecOUNode = $$(oCurrentOUNode).find("step").has(">ou>taskinfo[status='pending']");
                        if (oRecOUNode.length != 0) $$(oCurrentOUNode).find("step").has(">ou>taskinfo[status='pending']").remove();
                        var oChargeNode = $$(oCurrentOUNode).find("step").has("ou>person>taskinfo[status='pending']");

                        //[2015-04-28 kh] 담당 수신자 대결
                        var isChkDeputy = false;

                        if (oChargeNode.length != 0) {
                            //[2015-04-28 kh] 담당 수신자 대결 S ----------------------------------------
                            var objDeputyOU = $$(oApvList).find("steps>division[divisiontype='receive']>step>ou");
                            var chkObjPersonNode = $$(objDeputyOU).find("person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "']").find(">taskinfo[status='pending']");
                            var chkObjRoleNode = $$(objDeputyOU).find("role:has(person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'])");

                            if (0 < (chkObjPersonNode.length + chkObjRoleNode.length)) {
                                isChkDeputy = true;
                            }
                            //[2015-04-28 kh] 담당 수신자 대결 E -----------------------------------------
                        	
                            var oRecApprovalNode = $$(oCurrentOUNode).find("step>ou>person>taskinfo[status='inactive']");
                            if (oRecApprovalNode.length != 0) {
                            	for(var i=0; i<oRecApprovalNode.length; i++){
                            		var RecApprovalNode = oRecApprovalNode.concat().eq(i);
                            		oCurrentOUNode.concat().eq(0).remove(RecApprovalNode.parent().parent().parent());
                            	}
                            	
                            }

                            //person의 takinfo가 inactive가 있는 경우 routetype을 변경함
                            var nodesInactives = $$(oCurrentOUNode).find("step[routetype='receive']").has("ou > person > taskinfo[status='inactive']");

                            $$(nodesInactives).each(function (i, nodesInactive) {
                                $$(nodesInactive).attr("unittype", "person");
                                $$(nodesInactive).attr("routetype", "approve");
                                $$(nodesInactive).attr("name", mobile_comm_getDic("lbl_apv_ChargeDept"));			//gLabel__ChargeDept
                            });
                        }

                        var oJFNode = $$(oCurrentOUNode).find("step").has("ou>role>taskinfo[status='pending'], ou>role>taskinfo[status='reserved']"); //201108
                        var bHold = false; //201108 보류여부
                        var oComment = null;
                        if (oJFNode.length != 0) {
                            var oHoldTaskinfo = $$(oJFNode).find("ou>role>taskinfo[status='reserved']");
                            if (oHoldTaskinfo.length != 0) {
                                bHold = true;
                                oComment = $$(oHoldTaskinfo).find("comment").json();
                                
                                // 보류한 사용자와 로그인한 사용자가 다른 경우
                                if($$(oComment).attr("reservecode") != undefined && $$(oComment).attr("reservecode") != getInfo("AppInfo.usid")) {
                                	alert(mobile_comm_getDic("msg_apv_holdOther")); // 해당 양식은 다른 사용자가 보류한 문서입니다.
                                	bHold = false;
                            	}
                            }
                            //$$(oCurrentOUNode).eq(0).remove($$(oJFNode).eq(0));
                            $$(oCurrentOUNode).eq(0).remove("step");
                        }

                        $$(oCurrentOUNode).attr("oucode", getInfo("AppInfo.dpid_apv"));
                        $$(oCurrentOUNode).attr("ouname", getInfo("AppInfo.dpdn_apv"));
                        
                        $$(oCurrentOUNode).find("[taskinfo]").attr("status", "pending");
                        $$(oCurrentOUNode).find("[taskinfo]").attr("result", "pending");
                        
                        var oStep = {};
                        var oOU = {};
                        var oPerson = {};
                        var oTaskinfo = {};

                        $$(oStep).attr("unittype", "person");
                        $$(oStep).attr("routetype", "approve");
                        $$(oStep).attr("name", mobile_comm_getDic("lbl_apv_ChargeDept"));	//gLabel__ChargeDept);
                        
                        $$(oOU).attr("code", getInfo("AppInfo.dpid_apv"));
                        $$(oOU).attr("name", getInfo("AppInfo.dpdn_apv"));
                        
                        $$(oPerson).attr("code", getInfo("AppInfo.usid"));
                        $$(oPerson).attr("name", getInfo("AppInfo.usnm_multi"));
                        $$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
                        $$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
                        $$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
                        $$(oPerson).attr("oucode", getInfo("AppInfo.dpid"));
                        $$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
                        $$(oPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
                        
                        $$(oTaskinfo).attr("status", (bHold == true ? "reserved" : "pending")); //201108
                        $$(oTaskinfo).attr("result", (bHold == true ? "reserved" : "pending")); //201108
                        $$(oTaskinfo).attr("kind", "charge");
                        $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        if (bHold) $$(oTaskinfo).append(oComment); //201108
                        
                        $$(oPerson).append("taskinfo", oTaskinfo);
                        
                        $$(oOU).append("person", oPerson);
                        
                        $$(oStep).append("ou", oOU);
                        
                        // 조건 추가 - charge가 있는 경우에만 실행
                        // receive division의 첫번째 step 교체
                        if($$(oCurrentOUNode).find("step > ou > person > taskinfo[kind='charge']").length > 0) {                        
                       		$$(oCurrentOUNode).append("step", oStep);
	                        $$(oCurrentOUNode).find("step").concat().eq(0).remove();
                        }
                        else {
                        	$$(oCurrentOUNode).append("step", oStep);
                        }
                        
                        //담당 수신자 대결 S ---------------------------------------------
                        if (isChkDeputy) {
                        	alert(mobile_comm_getDic("msg_ApprovalDeputyWarning"));
                        	
                            var objOriginalApprover = $$(oChargeNode).find('ou').find("person");
                            $$(objOriginalApprover).attr('title', $$(objOriginalApprover).attr('title'));
                            $$(objOriginalApprover).attr('level', $$(objOriginalApprover).attr('level'));
                            $$(objOriginalApprover).attr('position', $$(objOriginalApprover).attr('position'));

                            $$(objOriginalApprover).find('taskinfo').remove('datereceived');
                            $$(objOriginalApprover).find('taskinfo').attr('kind', 'bypass');
                            $$(objOriginalApprover).find('taskinfo').attr('result', 'inactive');
                            $$(objOriginalApprover).find('taskinfo').attr('status', 'inactive');
                            
                            // [2015-05-28 modi] 현재 대결인 division에만 추가하도록
                            //objDeputyOU = $(oApvList).find("steps > division[divisiontype='receive'] > step > ou");
                            //objDeputyOU = $$(oApvList).find("steps>division").has("taskinfo[status='pending']").find("step>ou");
                            //$$(objDeputyOU).append("person", $$(objOriginalApprover).json());
                            
                            // [2020-10-23] person 추가에서 step 추가로 변경
                            $$(oChargeNode).attr("routetype", "approve");
                            $$(oChargeNode).attr("name", "원결재자");
                        	$$(oCurrentOUNode).append("step", $$(oChargeNode).json());
                        }
                        //담당 수신자 대결 E ----------------------------------------------
                        
                        //2006.04.25 by wolf 퇴직자 및 인사정보 최신 적용을 위해 추가 예외사항생기더라도 기안/재기안자 결재선 디스플레이
                        document.getElementById("APVLIST").value = JSON.stringify(oApvList);

                        var nodesAllItems;
                        nodesAllItems = $$(oGetApvList).find("steps > division").children().find("[divisiontype='receive']").has(">taskinfo[status='pending']").has("step");

                        //재기안시 수신결재자 자동 지정
						var isRecApv = false;
						if ((getInfo("Request.mode") == "REDRAFT") && getInfo("Request.templatemode") == "Read"){
							// 타입별 수신결재자 가져오기
							var oaScPRecAV = [];
							if(getInfo("SchemaContext.scPRecA.isUse") == "Y" && getInfo("SchemaContext.scPRecA.value") != ""){
								var oScPRecAV = $.parseJSON(getInfo("SchemaContext.scPRecA.value"));
								oaScPRecAV = $$(oScPRecAV).find("autoApv").concat();
							}else if (getInfo("SchemaContext.scPRecAEnt.isUse") == "Y" && getInfo("SchemaContext.scPRecAEnt.value") != "") {
								var sEtId = (document.getElementById("EntCode") == undefined) ? getInfo("FormInstanceInfo.EntCode") : document.getElementById("EntCode").value;
					            var oScPRecAVEnt = $.parseJSON(getInfo("SchemaContext.scPRecAEnt.value"));
					            oaScPRecAV = $$(oScPRecAVEnt).find("ENT_" + sEtId + " > autoApv").concat();
							}else if (getInfo("SchemaContext.scPRecAReg.isUse") == "Y" && getInfo("SchemaContext.scPRecAReg.value") != "") {
								var oScPRecAVReg = $.parseJSON(getInfo("SchemaContext.scPRecAReg.value"));
								oaScPRecAV = $$(oScPRecAVReg).find("REG_" + getInfo("AppInfo.regionid") + " > autoApv").concat();
							}
							
							// 수신결재자 셋팅
							$$(oaScPRecAV).each(function (apvIdx, apvItem) {
								var oStepR = {};
                                var oOUR = {};
                                var oPersonR = {};
                                var oTaskinfoR = {};

                                $$(oStepR).attr("unittype", "person");
                                $$(oStepR).attr("routetype", "approve");
                                $$(oStepR).attr("name", "Normal");
                                
                                $$(oOUR).attr("code", $$(apvItem).find("item>item").concat().attr("RG"));
                                $$(oOUR).attr("name", $$(apvItem).find("item>item").concat().attr("RGNM"));
                                
                                $$(oPersonR).attr("code", $$(apvItem).find("item>item").concat().attr("AN"));
                                $$(oPersonR).attr("name", $$(apvItem).find("item>item").concat().attr("DN"));
                                $$(oPersonR).attr("position", $$(apvItem).find("item>item").concat().attr("po"));
                                $$(oPersonR).attr("title", $$(apvItem).find("item>item").concat().attr("tl"));
                                $$(oPersonR).attr("level", $$(apvItem).find("item>item").concat().attr("lv"));
                                $$(oPersonR).attr("oucode", $$(apvItem).find("item>item").concat().attr("RG"));
                                $$(oPersonR).attr("ouname", $$(apvItem).find("item>item").concat().attr("RGNM"));
                                $$(oPersonR).attr("sipaddress", $$(apvItem).find("item>item").concat().attr("MSN_SipAddress"));
                                
                                $$(oTaskinfoR).attr("status", "inactive");
                                $$(oTaskinfoR).attr("result", "inactive");
                                $$(oTaskinfoR).attr("kind", $$(apvItem).concat().attr("type"));
                                
                                $$(oPersonR).append("taskinfo", oTaskinfoR);
                                
                                $$(oOUR).append("person", oPersonR);
                                
                                $$(oStepR).append("ou", oOUR);
                                
								//수신자 퇴직자 처리
								var oStep = {};
								var oDivR = {};
								$$(oDivR).append("step", oStepR);
								$$(oStep).append("division",oDivR);
	                            var chkAbsentResult = chkAbsent(oStep);
	                        	if (chkAbsentResult != "") {
	                        		chkAbsentResult = chkAbsentResult.split("@@@");
	                        		var absentType = chkAbsentResult[0];
	                        		var absentMsg = chkAbsentResult[1];
	                        		var absentCode = chkAbsentResult[2].split(",");
	                        		alert(absentMsg);
	                        		if(absentType != "absent") {
										$$(oApvList).find("steps>division[divisiontype='receive']").has(">taskinfo[status='pending']").append("step", oStepR);
										isRecApv = true;
									}
	                            }else{
	                            	$$(oApvList).find("steps>division[divisiontype='receive']").has(">taskinfo[status='pending']").append("step", oStepR);
									isRecApv = true;
	                            }

                            });
						}
                        
                        if(!isRecApv) {
                            if (nodesAllItems.length > 0) {
                                var oSteps = $$(oGetApvList).find("steps");
                                var oCheckSteps = chkAbsent(oSteps);

                                if (oCheckSteps != "") {
                                    //담당 대결자 체크 필요 
                                    //1. 중복으로 들어가는 문제 검토 필요 (주석 처리)
                                    //2. chkAbsent(oSteps) 함수에서 퇴직자 정보 체크 한다 - 아래 appendChild 확인 필요
                                    //3. 담당수신자 지정 후 담당수신자를 대결 지정시 아래 로직을 거치면 중복으로 결재자가 들어간다
                                	var absentType = oCheckSteps.split("@@@")[0];
                                	var absentMsg = oCheckSteps.split("@@@")[1];
                                	var absentCode = oCheckSteps.split("@@@")[2].split(",");
                                	                            		
                            		alert(absentMsg);
                            		
                            		if(absentType == "change") {
                            			$$(oSteps).find("division").concat().has(">taskinfo[status='pending']").find("[divisiontype='receive'] > step[unittype='person']").has("ou>person>taskinfo[kind!='charge']").each(function (i, enodeItem) {
                            				var isChanged = false; //인사정보 변경 여부
                            				for(var j = 0; j < absentCode.length; j++) {
                            					if(absentCode[j] != "") {
	                            					if(absentCode[j] == $$(enodeItem).find("ou>person").attr("code")) {
	                            						isChanged = true;
	                            					}
                            					}
                            				}

                            				if(!isChanged) { //인사정보 변경되지 않은 결재자만 추가
                            					if(enodeItem.find("ou>person>taskinfo[kind='bypass']").length == 0) {
                            						$$(oApvList).find("division[divisiontype='receive']").has(">taskinfo[status='pending']").append("step", enodeItem.json());
                            					}
                            				}
                                        });
                            		}
                                } else {
                                    $$(oSteps).find("division").concat().has(">taskinfo[status='pending']").find("[divisiontype='receive'] > step[unittype='person']").has("ou>person>taskinfo[kind!='charge']").each(function (i, enodeItem) {
                    					if(enodeItem.find("ou>person>taskinfo[kind='bypass']").length == 0) {
                    						$$(oApvList).find("division[divisiontype='receive']").has(">taskinfo[status='pending']").append("step", enodeItem.json());
                    					}
                                    });
                                }
                            }
                        }
						if ($$(oApvList).find("division").has(">taskinfo[status='pending']").find("step").concat().length > 1) {
                            btDisplay.btDeptDraft = "Y";
                            btDisplay.btRec = "N";
							btDisplay.btApproved = "N";
                        }
                    } else if (getInfo("Request.mode") == "SUBREDRAFT") {
                        oCurrentOUNode = $$(oApvList).find("steps>division").has(">taskinfo[status='pending']");
                        var oOU = $$(oCurrentOUNode).find("step>ou").has("[code='" + getInfo("AppInfo.dpid_apv") + "']").has("taskinfo[status='pending']");

                        var oPerson = {};
                        var oTaskinfo = {};

                        $$(oPerson).attr("code", getInfo("AppInfo.usid"));
                        $$(oPerson).attr("name", getInfo("AppInfo.usnm_multi"));
                        $$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
                        $$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
                        $$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
                        $$(oPerson).attr("oucode", getInfo("AppInfo.dpid"));
                        $$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
                        $$(oPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
                        $$(oTaskinfo).attr("status", "inactive"); 
                        $$(oTaskinfo).attr("result", "inactive");
                        $$(oTaskinfo).attr("kind", "charge");
                        $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        
                        $$(oPerson).append("taskinfo", oTaskinfo)
                        
                        $$(oOU).append("person", oPerson);
                    } else {
                    	// 자동결재선 옵션처리
                		// 1. (기본) 최종결재선 불러온 후 자동결재선 적용 & 재사용인 경우 자동결재선 적용하지 않음
                		// 2. (옵션) 자동결재선 사용하는 경우 최종결재선 불러오지 않기 & 재사용인 경우에 결재선 초기화 후 자동결재선 적용
						// 임시저장 문서는 모두 자동결재선 적용하지 않음
                		var useAutoApvlineOption = mobile_comm_getBaseConfig("useAutoApvlineOption");
                		var bSetOption = false; 
                		
                		// 자동결재선 옵션 처리를 적용하면서 & 자동합의자, 자동결재자, 자동참조자, 자동참조사(사전) 이 설정되어 있는 경우
                		if(useAutoApvlineOption == "Y") {
                			if(getInfo("AutoApprovalLine.Agree.autoSet") == "Y" || getInfo("AutoApprovalLine.Approval.autoSet") == "Y"
                				|| getInfo("AutoApprovalLine.CCAfter.autoSet") == "Y" || getInfo("AutoApprovalLine.CCBefore.autoSet") == "Y") {
								// 자동결재선 옵션인경우(1), 재사용/임시저장이 아닌경우 최종결재선 삭제
								if((getInfo("Request.reuse") != "Y" && getInfo("Request.mode") != "TEMPSAVE")) oGetApvList = {};
                    			if(getInfo("Request.mode") != "TEMPSAVE") bSetOption = true; // 임시저장이 아닌경우 자동결재선 적용	
                			}
                		}else if(getInfo("Request.reuse") != "Y" && getInfo("Request.mode") != "TEMPSAVE"){ // 자동결재선 기본인경우(2), 재사용/임시저장이 아닌경우 자동결재선 적용(최종결재선에 추가)
							bSetOption = true;
						}
                		
                        if (bSetOption || getInfo("Request.reuse") != "Y") { //  && (CFN_GetQueryString("RequestFormInstID") == "" || CFN_GetQueryString("RequestFormInstID") == "undefined" )) {
                            if (getInfo("AppInfo.dpid") != getInfo("AppInfo.dpid_apv")) 
                            	$(oApvList).find("steps").attr("initiatoroucode", getInfo("AppInfo.dpid_apv"));
                            
                            var oSteps = {};
                            var oDiv = {};
                            var oDivTaskinfo = {};
                            var oStep = {};
                            var oOU = {};
                            var oPerson = {};
                            var oTaskinfo = {};
                            
                            $$(oDiv).attr("divisiontype", "send");
                            $$(oDiv).attr("name", mobile_comm_getDic("lbl_apv_circulation_sent"));
                            $$(oDiv).attr("oucode", getInfo("AppInfo.dpid_apv"));
                            $$(oDiv).attr("ouname", getInfo("AppInfo.dpdn_apv"));
                            
                            $$(oDivTaskinfo).attr("status", "inactive");
                            $$(oDivTaskinfo).attr("result", "inactive");
                            $$(oDivTaskinfo).attr("kind", "send");
                            $$(oDivTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                            
                            $$(oDiv).attr("taskinfo", oDivTaskinfo);
                            
                            $$(oStep).attr("unittype", "person");
                            $$(oStep).attr("routetype", "approve");
                            $$(oStep).attr("name", mobile_comm_getDic("lbl_apv_writer"));
                            
                            $$(oOU).attr("code", getInfo("AppInfo.dpid_apv"));
                            $$(oOU).attr("name", getInfo("AppInfo.dpdn_apv"));
                            
                            $$(oPerson).attr("code", getInfo("AppInfo.usid"));
                            $$(oPerson).attr("name", getInfo("AppInfo.usnm_multi"));
                            $$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
                            $$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
                            $$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
                            $$(oPerson).attr("oucode", getInfo("AppInfo.dpid"));
                            $$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
                            $$(oPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
                            
                            $$(oTaskinfo).attr("status", "inactive");
                            $$(oTaskinfo).attr("result", "inactive");
                            $$(oTaskinfo).attr("kind", "charge");
                            $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                            
                            $$(oPerson).attr("taskinfo", oTaskinfo);
                            
                            $$(oOU).attr("person", oPerson);
                            
                            $$(oStep).attr("ou", oOU);
                            
                            $$(oDiv).attr("step", oStep);
                            
                            $$(oSteps).attr("division", oDiv);
                            
                            oApvList = {"steps" : oSteps};
                            
                            $("#APVLIST").val(JSON.stringify(oApvList));
                        }
                        oCurrentOUNode = $$(oApvList).find("steps > division").has("taskinfo[status='inactive']").concat().eq(0);

                        var nodesAllItems = $$(oGetApvList).find("steps>division[divisiontype='send']>step");
                        if (nodesAllItems.exist() > 0) {
                            var oSteps = $$(oGetApvList).find("steps").concat().eq(0);
                            var oCheckSteps = chkAbsent(oSteps);
                            
                            if (oCheckSteps != "") {
                            	var absentType = oCheckSteps.split("@@@")[0];
                            	var absentMsg = oCheckSteps.split("@@@")[1];
                            	var absentCode = oCheckSteps.split("@@@")[2].split(",");
                            	                            		
                        		alert(absentMsg);
                        		
                        		if(absentType == "change") {
                            	$$(oSteps).find("division[divisiontype='send']>step").has("[unittype='person'],[unittype='role'],[unittype='ou']").each(function (i, enodeItem) {
                            			var isChanged = false; //인사정보 변경 여부
                        				for(var j = 0; j < absentCode.length; j++) {
                        					if(absentCode[j] != "") {
                            					if(absentCode[j] == $$(enodeItem).find("ou>person").attr("code")) {
                            						isChanged = true;
                            					}
                                        	}
                            			}
                                    	
                        				if(!isChanged) { //인사정보 변경되지 않은 결재자만 추가
                                        $$(oApvList).find("division[divisiontype='send']").append("step", enodeItem.json());
                                	}
                                });
                            }
                            } else {
                        		$$(oSteps).find("division[divisiontype='send']>step").has("[unittype='person'],[unittype='role'],[unittype='ou']").each(function (i, enodeItem) {
                                    $$(oApvList).find("division[divisiontype='send']").append("step", enodeItem.json());
                                });
                            }
                        }
                        //다시 확인
                        /*var nodesAllItems2 = $$(oGetApvList).find("steps > division[divisiontype='send'] > step");
                        if (nodesAllItems2.exist() > 0) {
                            var oSteps = $$(oGetApvList).find("steps").concat().eq(0);
                            $$(oSteps).find("division[divisiontype='send']>step[unittype='role']").each(function (i, enodeItem) {
                                $$(oApvList).find("division[divisiontype='send']").append("step", enodeItem.json());
                            });
                        }*/

                        
                        //부서장결재단계사용. 임시저장, 편집, 재사용시 진행하지 않음
                        if(getInfo("Request.mode") == "DRAFT" && getInfo("Request.reuse") != "Y"){
                            var nodesAllItems3 = $$(oGetApvList).find("steps > step[unittype='role']");
                            if (nodesAllItems3.length > 0) {
                                var oSteps = $$(oGetApvList).find("steps").concat().eq(0);
                                nodesAllItems3.each(function (i, enodeItem) {
                                    $$(oApvList).find("division[divisiontype='send']").append("step", enodeItem.json());
                                });
                            }
                        }

                        //양식 결재선에 수신처. (수신자, 수신부서)
	                    if (getInfo("SchemaContext.scPRec.isUse") == "Y" || getInfo("SchemaContext.scPRecEnt.isUse") == "Y" || getInfo("SchemaContext.scPRecReg.isUse") == "Y"
							|| getInfo("SchemaContext.scDRec.isUse") == "Y" || getInfo("SchemaContext.scDRecEnt.isUse") == "Y" || getInfo("SchemaContext.scDRecReg.isUse") == "Y") {
							var isRec = false;
							
							// 타입별 수신자 가져오기
							var oaScPRecV = [];
	                        if (getInfo("SchemaContext.scPRec.isUse") == "Y" && getInfo("SchemaContext.scPRec.value") != "") {
								var aScPRecVG = getInfo("SchemaContext.scPRec.value").split("||");
	                        	for(var i=0;i<aScPRecVG.length ; i++){                             
		                            //var aScPRecV = getInfo("SchemaContext.scPRec.value").split("@@");
		                        	var aScPRecV =aScPRecVG[i].split("@@");
		                            if (aScPRecV.length > 2){
	                                    var oScPRecV = $.parseJSON(aScPRecV[2]);
	                                    oaScPRecV.push($$(oScPRecV).find("item").concat().json());
	                                }
			                    }
							}else if (getInfo("SchemaContext.scPRecEnt.isUse") == "Y" && getInfo("SchemaContext.scPRecEnt.value") != "") {
								var sEtId = (document.getElementById("EntCode") == undefined) ? getInfo("FormInstanceInfo.EntCode") : document.getElementById("EntCode").value;
					            var oScPRecVGEnt = $.parseJSON(getInfo("SchemaContext.scPRecEnt.value"));
					            oaScPRecV = $$(oScPRecVGEnt).find("ENT_" + sEtId + " > item").json();
							}else if (getInfo("SchemaContext.scPRecReg.isUse") == "Y" && getInfo("SchemaContext.scPRecReg.value") != "") {
								var oScPRecVGReg = $.parseJSON(getInfo("SchemaContext.scPRecReg.value"));
								oaScPRecV = $$(oScPRecVGReg).find("REG_" + getInfo("AppInfo.regionid") + " > item").json();
							}
							
							// 수신자 셋팅
							$(oaScPRecV).each(function(idx,oRecPerson){
	                            var oStep = {};
	                            var oDivR = {};
	                            var oDivTaskinfoR = {};
	                            var oStepR = {};
	                            var oOUR = {};
	                            var oPersonR = {};
	                            var oTaskinfoR = {};
	                        	
	                            $$(oDivR).attr("divisiontype", "receive");
	                            $$(oDivR).attr("name", "담당결재");
	                            $$(oDivR).attr("oucode", $$(oRecPerson).attr("RG"));
	                            $$(oDivR).attr("ouname", $$(oRecPerson).attr("RGNM"));
	                            
	                            $$(oDivTaskinfoR).attr("status", "inactive");
	                            $$(oDivTaskinfoR).attr("result", "inactive");
	                            $$(oDivTaskinfoR).attr("kind", "receive");
	                            
	                            $$(oDivR).append("taskinfo", oDivTaskinfoR);
	                            
	                            $$(oStepR).attr("unittype", "person");
	                            $$(oStepR).attr("routetype", "receive");
	                            $$(oStepR).attr("name", "담당결재");
	                            
	                            // 공통 조직도 데이터 변경되면 수정 필요
	                            $$(oOUR).attr("code", $$(oRecPerson).attr("RG"));
	                            $$(oOUR).attr("name", $$(oRecPerson).attr("RGNM"));
	                            
	                            $$(oPersonR).attr("code", $$(oRecPerson).attr("AN"));
	                            $$(oPersonR).attr("name", $$(oRecPerson).attr("DN"));
	                            $$(oPersonR).attr("position", $$(oRecPerson).attr("po"));
	                            $$(oPersonR).attr("title", $$(oRecPerson).attr("tl"));
	                            $$(oPersonR).attr("level", $$(oRecPerson).attr("lv"));
	                            $$(oPersonR).attr("oucode", $$(oRecPerson).attr("RG"));
	                            $$(oPersonR).attr("ouname", $$(oRecPerson).attr("RGNM"));
	                            $$(oPersonR).attr("sipaddress", $$(oRecPerson).attr("SIP"));
	                            
	                            $$(oTaskinfoR).attr("status", "inactive");
	                            $$(oTaskinfoR).attr("result", "inactive");
	                            $$(oTaskinfoR).attr("kind", "charge");
	                            
	                            $$(oPersonR).append("taskinfo", oTaskinfoR);
	                            
	                            $$(oOUR).append("person", oPersonR);
	                            
	                            $$(oStepR).append("ou", oOUR);
	                            
	                            $$(oDivR).append("step", oStepR);
	                            
	                            $$(oStep).append("division",oDivR);
	        
	                            //수신자 퇴직자 처리
	                            var chkAbsentResult = chkAbsent(oStep);
	                        	if (chkAbsentResult != "") {
	                        		chkAbsentResult = chkAbsentResult.split("@@@");
	                        		var absentType = chkAbsentResult[0];
	                        		var absentMsg = chkAbsentResult[1];
	                        		var absentCode = chkAbsentResult[2].split(",");
	                        		alert(absentMsg);
	                        		if(absentType != "absent") {
										$$(oApvList).find("steps").append("division", oDivR);
										isRec = true;
									}
	                            }else{
	                            	$$(oApvList).find("steps").append("division", oDivR);
									isRec = true;
	                            }
							});
	
							// 타입별 수신부서 가져오기
							var oaScDRecV = [];
	                        if (getInfo("SchemaContext.scDRec.isUse") == "Y" && getInfo("SchemaContext.scDRec.value") != "") {
								var aScDRecVG = getInfo("SchemaContext.scDRec.value").split("||");
	                        	for(var i=0;i<aScDRecVG.length ; i++){                             
		                            //var aScPRecV = getInfo("SchemaContext.scPRec.value").split("@@");
		                        	var aScDRecV =aScDRecVG[i].split("@@");
		                            if (aScDRecV.length > 1){
	                                    var oScDRecV = {};
										oScDRecV.AN = aScDRecV[0];
										oScDRecV.DN = aScDRecV[1];
	                                    oaScDRecV.push(oScDRecV);
	                                }
			                    }
							}else if (getInfo("SchemaContext.scDRecEnt.isUse") == "Y" && getInfo("SchemaContext.scDRecEnt.value") != "") {
								var sEtId = (document.getElementById("EntCode") == undefined) ? getInfo("FormInstanceInfo.EntCode") : document.getElementById("EntCode").value;
					            var oScDRecVGEnt = $.parseJSON(getInfo("SchemaContext.scDRecEnt.value"));
					            oaScDRecV = $$(oScDRecVGEnt).find("ENT_" + sEtId + " > item").json();
							}else if (getInfo("SchemaContext.scDRecReg.isUse") == "Y" && getInfo("SchemaContext.scDRecReg.value") != "") {
								var oScDRecVGReg = $.parseJSON(getInfo("SchemaContext.scDRecReg.value"));
								oaScDRecV = $$(oScDRecVGReg).find("REG_" + getInfo("AppInfo.regionid") + " > item").json();
							}
							
							// 수신부서 셋팅
							$(oaScDRecV).each(function(idx,oRecDept){
	                            var oDivR = {};
	                            var oDivTaskinfoR = {};
	                            var oStepR = {};
	                            var oOUR = {};
	                            var oTaskinfoR = {};
	                        	
	                            $$(oDivR).attr("divisiontype", "receive");
	                            $$(oDivR).attr("name", "담당부서수신");
	                            $$(oDivR).attr("oucode", $$(oRecDept).attr("AN"));
	                            $$(oDivR).attr("ouname", $$(oRecDept).attr("DN"));
	                            
	                            $$(oDivTaskinfoR).attr("status", "inactive");
	                            $$(oDivTaskinfoR).attr("result", "inactive");
	                            $$(oDivTaskinfoR).attr("kind", "receive");
	                            
	                            $$(oDivR).append("taskinfo", oDivTaskinfoR);
	                            
	                            $$(oStepR).attr("unittype", "ou");
	                            $$(oStepR).attr("routetype", "receive");
	                            $$(oStepR).attr("name", "담당부서수신");
	                            
	                            // 공통 조직도 데이터 변경되면 수정 필요
	                            $$(oOUR).attr("code", $$(oRecDept).attr("AN"));
	                            $$(oOUR).attr("name", $$(oRecDept).attr("DN"));
	                            
	                            $$(oTaskinfoR).attr("status", "inactive");
	                            $$(oTaskinfoR).attr("result", "inactive");
	                            $$(oTaskinfoR).attr("kind", "normal");
	                            
	                            $$(oOUR).append("taskinfo", oTaskinfoR);
	                            
	                            $$(oStepR).append("ou", oOUR);
	                            
	                            $$(oDivR).append("step", oStepR);
	                            
	                            //수신부서 삭제된 부서 처리
	                            var oAbsentResult = chkAbsentGroupCall($$(oRecDept).attr("AN"));
								var aAbsentResult = oAbsentResult.map(g => g.GroupCode);
								if(aAbsentResult.includes($$(oRecDept).attr("AN"))){
									$$(oApvList).find("steps").append("division", oDivR);
									isRec = true;
								}else{
									var msg = Common.getDic("msg_apv_chkAbsentGroup") + '\n\n'; // 양식에 설정된 부서에 사용하지 않는 부서가 포함되어 적용되지 않습니다. 관리자에게 문의하세요.
									msg += Common.getDic("msg_apv_absentGroup") + " : " + mobile_comm_getDicInfo($$(oRecDept).attr("DN")); // 제외부서
									alert(msg);
								}
							});
							
							// 셋팅된 수신자,수신부서가 없으면 기존 결재선 유지
							if(!isRec){
								$$(oGetApvList).find("steps>division[divisiontype='receive']").has("step[routetype='receive']").has("step[unittype='ou'],[unittype='person']").each(function (i, enodeItem) {
	                                $$(enodeItem).find("person>taskinfo").attr("result", "inactive");
	                                $$(enodeItem).find("person>taskinfo").attr("status", "inactive");
	                                $$(enodeItem).find("person>taskinfo").remove("datereceived");
	                                $$(enodeItem.children().concat().eq(0)).attr("result", "inactive");
	                                $$(enodeItem.children().concat().eq(0)).attr("status", "inactive");
	                                $$(enodeItem.children().concat().eq(0)).remove("datereceived");
	                                //$$(oApvList).append(enodeItem.key(), enodeItem);
	                                $$(oApvList).find("steps").append("division", enodeItem.json());
	                            });
							}
	                    }

                        //참조자 출력
                        $$(oGetApvList).find("steps > ccinfo").concat().each(function (i, enodeItem) {
                            $$(oApvList).find("steps").append("ccinfo", enodeItem.json());
                        });
                          
                        //양식오픈시 최종결재선에 visible값이 n이면 결재라인에서 삭제 
                        if($$(oApvList).find("division[divisiontype='send'] > step > ou > person > taskinfo > [visible='n']").length > 0 ) {
                        	$$(oApvList).find("division[divisiontype='send']>step").has("[unittype='person'],[unittype='role'],[unittype='ou']").each(function (i, enodeItem) {
                        		if (i==0) $$(oApvList).find("division[divisiontype='send']").remove("step");
                        		
                        		if( !($$(enodeItem).find("ou>person>taskinfo>[visible='n']")).length > 0 ){
                        			$$(oApvList).find("division[divisiontype='send']").append("step", enodeItem.json());
                        		}
                        	});
                        }
                        // 재사용 인 경우에는 자동참조 등 자동결재선 뿌리지 않음(중복되기 때문)
                        if(bSetOption || (getInfo("Request.reuse") != "Y" && getInfo("Request.mode") != "TEMPSAVE")) {    
	                        //자동합의자
	                        if (getInfo("AutoApprovalLine.Agree.autoSet") == "Y") {
	                            if (getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != undefined) {
	                                var oAutoLineAgree = $.parseJSON(getInfo("AutoApprovalLine.Agree.WorkedApprovalLine"));
	                                if ($$(oAutoLineAgree).find("step").length > 0) {
	                                    var oAppList = $$(oApvList).find("steps>division[divisiontype='send']>step[routetype='assist'][unittype='person'], steps>division[divisiontype='send']>step[routetype='consult'][unittype='person']");
	                                    for (var i = 0; i < $$(oAppList).length; i++) {
	                                        var oChkNode = $$(oAutoLineAgree).find("step").has("ou>person[code='" + $$($$(oAppList).concat().eq(i)).find("ou > person").attr("code") + "']");
	                                        
	                                        if($$(oAutoLineAgree).find("step>ou").concat().length > 1) {
                                        		oChkNode = $$(oAutoLineAgree).find("step").find("ou").has("person[code='" + $$(oAppList).find("ou").concat().find("person").eq(i).attr("code") + "']");
	                                        if (oChkNode.length > 0) {
	                                            $$(oChkNode).remove();
	                                        }
	                                    }
	                                        else if (oChkNode.length > 0) {
	                                            $$(oChkNode).remove();
	                                        }
	                                    }

	                                    var oCheckSteps = chkAbsent(oAutoLineAgree, false, "autoline");

	                                    if (oCheckSteps != "") {
	                                    	var absentType = oCheckSteps.split("@@@")[0];
	                                    	var absentMsg = oCheckSteps.split("@@@")[1];
	                                    	var absentCode = oCheckSteps.split("@@@")[2].split(",");
	                                    	                            		
	                                		alert(absentMsg);
	                                		
	                                		if(absentType == "absent") {
	                                			$$(oAutoLineAgree).find("ou>person>taskinfo[kind!='charge']").parent().remove();
	                                		} else {
	                                			for(var i = 0; i < absentCode.length; i++) {
	                                				if(absentCode[i] != "") {
	                                					$$(oAutoLineAgree).find("ou>person[code='"+absentCode[i]+"']").remove();
	                                				}	
	                                			}
	                                		}
	                                    }
	                                    
	                                    // 기안자 (taskinfo가 charge) 바로 뒤에 자동합의자 데이터 넣기 위함 - 시작
	                                    var tempChargeObj = {"step" : $$(oApvList).find("steps>division>step").has("ou>person>taskinfo[kind='charge']").json()};
	                                    var tempChargePath = "";
	                                    
	                                    if($$(tempChargeObj.step).exist()){
	                                    	tempChargePath = $$(oApvList).find("steps>division>step").has("ou>person>taskinfo[kind='charge']").concat().eq(0).path();
	                                    	
	                                    	$$(oApvList).find("steps>division>step").has("ou>person>taskinfo[kind='charge']").remove();
	                                    	
	                                    	if($$(oAutoLineAgree).find("step").length > 0) {
	                                    		$$(tempChargeObj).append("step", $$(oAutoLineAgree).find("step").json());
	                                    	}
	                                    	
	                                    	if($$(oApvList).find(tempChargePath.replace(/\//gi, ">")).parent().find("step").length > 0)		// 기존 결재선이 기안자외에 결재선이 있을 경우
	                                    		if($$(oAutoLineAgree).find("step").length > 0) {
	                                    		$$(oApvList).find(tempChargePath.replace(/\//gi, ">")).parent().find("step").json().splice(0, 0, $$(tempChargeObj).find("step").json()[0], $$(tempChargeObj).find("step").json()[1]);
		                                    	}
	                                    		else {
	                                    			$$(oApvList).find(tempChargePath.replace(/\//gi, ">")).parent().find("step").json().splice(0, 0, $$(tempChargeObj).find("step").json());
	                                    		}
	                                    	else		// 기존 결재선이 기안자 외에 결재선이 없을 경우
	                                    		$$(oApvList).find(tempChargePath.replace(/\//gi, ">").replace("division>step", "division")).append("step", $$(tempChargeObj).find("step").json());
	                                    }
	                                    // 기안자 (taskinfo가 charge) 바로 뒤에 자동합의자 데이터 넣기 위함 - 끝
	                                }
	                            }
	                        }
	                        //자동결재자
	                        if (getInfo("AutoApprovalLine.Approval.autoSet") == "Y") {
	                            if (getInfo("AutoApprovalLine.Approval.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Approval.WorkedApprovalLine") != undefined) {
	                                var oAutoLineApproval = $.parseJSON(getInfo("AutoApprovalLine.Approval.WorkedApprovalLine"));
	                                if ($$(oAutoLineApproval).find("step").length > 0) {
	                                    var oAppList = $$(oApvList).find("steps>division[divisiontype='send']>step[name!='reference'][routetype='approve'][unittype='person']");
	                                    for (var i = 0; i < $$(oAppList).length; i++) {
	                                        var oChkNode = $$(oAutoLineApproval).find("step").has("ou > person[code='" + $$($$(oAppList).concat().eq(i)).find("ou > person").attr("code") + "']");
	                                        if (oChkNode.length > 0) {
	                                        	//$$(oChkNode).remove();
	                                        	$$(oAutoLineApproval).find("step").remove(oChkNode.index());
	                                        }
	                                    }

	                                    var oCheckSteps = chkAbsent(oAutoLineApproval, false, "autoline");

	                                    if (oCheckSteps != "") {
	                                    	var absentType = oCheckSteps.split("@@@")[0];
	                                    	var absentMsg = oCheckSteps.split("@@@")[1];
	                                    	var absentCode = oCheckSteps.split("@@@")[2].split(",");
	                                    	                            		
	                                		alert(absentMsg);
	                                		
	                                		if(absentType == "absent") {
	                                			$$(oAutoLineApproval).find("ou>person>taskinfo[kind!='charge']").parent().remove();
	                                		} else {
	                                			for(var i = 0; i < absentCode.length; i++) {
	                                				if(absentCode[i] != "") {
	                                					$$(oAutoLineApproval).find("ou>person[code='"+absentCode[i]+"']").remove();
	                                				}	
	                                			}
	                                		}
	                                    }
	                                    
	                                    $$(oAutoLineApproval).find("step").concat().each(function(i, elm){
	                                    	$$(oApvList).find("steps>division[divisiontype='send']").append("step", elm.json());
	                                    });
	                                }
	                            }
	                        }
	                        //자동참조자
	                        if (getInfo("AutoApprovalLine.CCAfter.autoSet") == "Y" && getInfo("Request.mode") != "TEMPSAVE") {
	
	                            if (getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != undefined) {
	                                var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine"));
	                                if ($$(oAutoLineCC).find("ccinfo").length > 0) {
	                                    $$(oApvList).find("steps>ccinfo[belongto='sender']").each(function (i, elm) {
	                                        var oChkNode = $$(oAutoLineCC).find("ccinfo[belongto='sender']").has(">ou>person[code='" + $$(elm).find("ou > person").attr("code") + "']");
	                                        if (oChkNode.length > 0) {
	                                        	//$$(oChkNode).remove();
	                                        	$$(oAutoLineCC).find("step").remove(oChkNode.index());
	                                        }
	                                        var oChkNode = $$(oAutoLineCC).find("ccinfo[belongto='sender']").has("> ou[code='" + $$(elm).find("ou").attr("code") + "']");
	                                        if (oChkNode.length > 0) {
	                                        	//$$(oChkNode).remove();
	                                        	$$(oAutoLineCC).find("step").remove(oChkNode.index());
	                                        }
	                                    });
	                                    
	                                    var oCheckSteps = chkAbsent(oAutoLineCC, false, "autoline");

	                                    if (oCheckSteps != "") {
	                                    	var absentType = oCheckSteps.split("@@@")[0];
	                                    	var absentMsg = oCheckSteps.split("@@@")[1];
	                                    	var absentCode = oCheckSteps.split("@@@")[2].split(",");
	                                    	                            		
	                                		alert(absentMsg);
	                                		
		                            		if(absentType == "absent") {
		                            	        $$(oAutoLineCC).find("ccinfo").remove();
		                            		} else {
		                            			for(var i = 0; i < absentCode.length; i++) {
		                            				if(absentCode[i] != "") {
		                            					$$(oAutoLineCC).find("ccinfo>ou>person[code='"+absentCode[i]+"']").parent().parent().remove();
		                            				}	
		                            			}
		                            		}	
	                                    }
	                                    
	                                    $$(oAutoLineCC).find("ccinfo").concat().attr("datereceived", "");
	                                    
	                                    $$(oAutoLineCC).find("ccinfo").concat().each(function(i, elm){
	                                    	$$(oApvList).find("steps").append("ccinfo", elm.json());
	                                    });
	                                }
	                            }
	                        }
	                        //자동참조자(사전)
	                        if (getInfo("AutoApprovalLine.CCBefore.autoSet") == "Y") {
	                            if (getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine") != undefined) {
	                                var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine"));
	                                if ($$(oAutoLineCC).find("ccinfo").length > 0) {
	                                    $$(oApvList).find("steps>ccinfo[belongto='sender'][beforecc='y']").each(function (i, elm) {
	                                        var oChkNode = $$(oAutoLineCC).find("ccinfo[belongto='sender'][beforecc='y']").has(">ou>person[code='" + $$(elm).find("ou > person").attr("code") + "']");
	                                        if (oChkNode.length > 0) {
	                                        	//$$(oChkNode).remove();
	                                        	$$(oAutoLineCC).find("step").remove(oChkNode.index());
	                                        }
	                                        var oChkNode = $$(oAutoLineCC).find("ccinfo[belongto='sender'][beforecc='y']").has(">ou[code='" + $$(elm).find("ou").attr("code") + "']");
	                                        if (oChkNode.length > 0) {
	                                        	//$$(oChkNode).remove();
	                                        	$$(oAutoLineCC).find("step").remove(oChkNode.index());
	                                        }
	                                    });
	                                    
	                                    var oCheckSteps = chkAbsent(oAutoLineCC, false, "autoline");

	                                    if (oCheckSteps != "") {
	                                    	var absentType = oCheckSteps.split("@@@")[0];
	                                    	var absentMsg = oCheckSteps.split("@@@")[1];
	                                    	var absentCode = oCheckSteps.split("@@@")[2].split(",");
	                                    	                            		
	                                		alert(absentMsg);
	                                		
		                            		if(absentType == "absent") {
		                            	        $$(oAutoLineCC).find("ccinfo").remove();
		                            		} else {
		                            			for(var i = 0; i < absentCode.length; i++) {
		                            				if(absentCode[i] != "") {
		                            					$$(oAutoLineCC).find("ccinfo>ou>person[code='"+absentCode[i]+"']").parent().parent().remove();
		                            				}	
		                            			}
		                            		}	
	                                    }
	                                    
	                                    $$(oAutoLineCC).find("ccinfo").concat().attr("datereceived", "");
	                                    
	                                    $$(oAutoLineCC).find("ccinfo").concat().each(function(i, elm){
	                                    	$$(oApvList).find("steps").append("ccinfo", elm.json());
	                                    });
	                                }
	                            }
	                        }
                        }
                    }

                    document.getElementById("APVLIST").value = JSON.stringify(oApvList);
                    
                    initApvList();
                }
            }
        }
    }
}

function chkAbsent(oSteps, isReuse, target) {
    var elmUsers;
    var sUsers = "";
    
    var person_str = "division>step>ou>person"; 
    if (target == "ccinfo") {
    	//참조자도 퇴직여부 확인
    	person_str = "ccinfo>ou>person";
    } else if (target == "autoline") {
    	//자동결재선 퇴직여부 확인 - 자동결재선은 steps가 아닌 step만을 넘김
    	person_str = "ou>person";
    }
    
    $$(oSteps).find(person_str).each(function (i, $$) {
        if (sUsers.length > 0) {
            var szcmpUsers = ";" + sUsers + ";";
            if (szcmpUsers.indexOf(";" + $$.concat().attr("code") + ";") == -1) { sUsers += ";" + $$.concat().attr("code"); }
        } else {
            sUsers += $$.concat().attr("code");
        }
    });
    
    var bReturn = "";
    
	if (sUsers != "") {
	    $.ajax({
	    	type:"POST",
	    	url:"/approval/apvline/checkAbsentMember.do",
	    	async:false,
	    	data:{
	    		"users":sUsers
	    	},
	    	success : function(data){
	              var sAbsentResult = "";
	              var sAbsentResultCode = "";
	              var sResult = "";
	              var sResultCode = "";
	              var oChkAbsentNode;
	    		  $$(oSteps).find(person_str).each(function (i, oUser) {
	    			  if($$(oUser).concat().length <= 1) { // 대결자 있는 경우 퇴사자로 인식하여 예외처리
		    			  sAbsentResult += m_oFormMenu.getLngLabel($$(oUser).concat().attr("name"), false) + ",";
		    			  sAbsentResultCode += m_oFormMenu.getLngLabel($$(oUser).concat().attr("code"), false) + ",";
		    			  sResult += m_oFormMenu.getLngLabel($$(oUser).concat().attr("name"), false) + ",";
		    			  sResultCode += m_oFormMenu.getLngLabel($$(oUser).concat().attr("code"), false) + ",";
		    			  
		                  $(data.list).each(function (idx, oChkAbsentNode) {
		                      if ($$(oChkAbsentNode).attr("PERSON_CODE") == $$(oUser).concat().attr("code")) { //재직자
		                          if ($$(oChkAbsentNode).attr("UNIT_CODE") == $$(oUser).concat().attr("oucode")) { //부서변경 없음
		                              oUser.concat().attr("oucode", $$(oChkAbsentNode).attr("UNIT_CODE"));
		                              oUser.concat().attr("ouname", $$(oChkAbsentNode).attr("UNIT_NAME"));
		                              oUser.concat().attr("position", $$(oChkAbsentNode).attr("JOBPOSITION_Z"));
		                              oUser.concat().attr("title", $$(oChkAbsentNode).attr("JOBTITLE_Z"));
		                              oUser.concat().attr("level", $$(oChkAbsentNode).attr("JOBLEVEL_Z"));
		                              sResult = sResult.replace(m_oFormMenu.getLngLabel($$(oUser).concat().attr("name"), false) + ",", "");
		                              sResultCode = sResultCode.replace(m_oFormMenu.getLngLabel($$(oUser).concat().attr("code"), false) + ",", "");
		                          }
		
		                          sAbsentResult = sAbsentResult.replace(m_oFormMenu.getLngLabel($$(oUser).concat().attr("name"), false) + ",", "");
		                          sAbsentResultCode = sAbsentResultCode.replace(m_oFormMenu.getLngLabel($$(oUser).concat().attr("code"), false) + ",", "");
		                      }
		                  });
	    			  }
	              });
	    		  if (sAbsentResult != "") {
	    			  var msg = mobile_comm_getDic("msg_apv_057").replace(/\\n/g, '\n'); //선택한 개인결재선 혹은 저장된 최종결재선에\n퇴직자가 포함되어 적용이 되지 않습니다.\n\n확인바랍니다.\n\n
	    			  if(isReuse) {
	    				  msg = mobile_comm_getDic("msg_apv_360").replace(/\\n/g, '\n'); //저장된 결재선에 퇴직자가 포함되어 적용이 되지 않습니다.
	    			  }
	    			  if(target == "autoline") {
	    				  msg = mobile_comm_getDic("msg_apv_361").replace(/\\n/g, '\n'); //자동결재선에 퇴직자가 포함되어 적용이 되지 않습니다.\n\n
	    			  }
	    			  if(target == "ccinfo") {
	    				  msg = msg.replace(mobile_comm_getDic("lbl_apv_approver"), mobile_comm_getDic("lbl_apv_cclisttitle")); //결재선 -> 참조목록
	    			  }
	    			  msg = msg + '\n' + mobile_comm_getDic("msg_apv_359") + " : " + sAbsentResult.substring(0, sAbsentResult.length - 1);
	                  bReturn = "absent@@@" + msg + "@@@" + sAbsentResultCode;
	              } else {
	                  if (sResult != "") {
		    			  var msg = mobile_comm_getDic("msg_apv_173").replace(/\\n/g, '\n'); //선택한 개인결재선 혹은 저장된 최종결재선의\n부서/인사정보가 최신정보와 일치하지 않아 적용이 되지 않습니다.\n\n---변경자--- \n\n
		    			  if(isReuse) {
		    				  msg = mobile_comm_getDic("msg_apv_357").replace(/\\n/g, '\n'); //저장된 결재선의 부서/인사정보가 최신정보와 일치하지 않아 제외됩니다.
		    			  }
		    			  if(target == "autoline") {
		    				  msg = mobile_comm_getDic("msg_apv_362").replace(/\\n/g, '\n'); //자동결재선의 부서/인사정보가 최신정보와 일치하지 않아 제외됩니다.
		    			  }
		    			  if(target == "ccinfo") {
		    				  msg = msg.replace(mobile_comm_getDic("lbl_apv_approver"), mobile_comm_getDic("lbl_apv_cclisttitle")); //결재선 -> 참조목록
		    			  }
		    			  msg = msg + '\n' + mobile_comm_getDic("msg_apv_358") + " : " + sResult.substring(0, sResult.length - 1);
		                  bReturn = "change@@@" + msg + "@@@" + sResultCode;
	                  } else {
	                      bReturn = "";
	                  }
	              }
	    	},
	    	error:function(response, status, error){
				mobile_comm_ajaxerror("/approval/apvline/checkAbsentMember.do", response, status, error);
			}
	    	
	    });
	}
   
    return bReturn;
}

/*-------------------------------------------------------
메뉴 버튼 이벤트 분기 처리 함수 : KJW : 2014.04.23 : XFORM PRJ.
---------------------------------------------------------*/

//메뉴 이벤트 분기 처리 오브젝트 : KJW : 2014.04.23 : XFORM PRJ.
var doButtonCase = {};

//메뉴 이벤트 공통 처리 오브젝트 : KJW : 2014.04.23 : XFORM PRJ.
var doButtonDefault = {
   sUrl: "",
   iWidth: "640",
   iHeight: "480",
   sSize: "fix",
   formNm: "", //not used
   m_evalJSON: "",
   elmlength: 0, //not used
   commentCount: 0, //not used
   elmComment: "",
   preProcess: function () {
       this.formNm = getInfo("FormInfo.FormPrefix")
       var filename = getInfo("FormInfo.FileName");
       if (typeof filename === 'undefined' || filename == '') return;

       if (getInfo("Request.templatemode") == "Read") {

           var m_evalJSON, elmlength, commentCount, elmComment;

           //[2014-12-24 modi]
           if ('' != document.getElementById("APVLIST").value) {
        	   m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
        	   elmlength = $$(m_evalJSON).find("steps > division > step").length;

               for (var k = 0; k < elmlength; k++) {
                   commentCount = 0;
                   elmComment = $$(m_evalJSON).find("steps > division > step > ou > person > taskinfo > comment");
                   if (elmComment != null) { ++commentCount; }
               }

               this.m_evalJSON = m_evalJSON;
               this.elmlength = elmlength;
               this.commentCount = commentCount;
               this.elmComment = elmComment;
           }
       }
   }

}

function doButtonAction(id) {

  //clone object
  var baseVariableObject = jQuery.extend(true, {}, doButtonDefault);

  //case 전 공통 처리
  baseVariableObject.preProcess();

  try {
      //버튼 분기 처리 함수 호출
      if (typeof doButtonCase[id] === 'function') {
          //필요한 경우 return 값 반환하여 처리
          var ret = doButtonCase[id](baseVariableObject);
      }

      //분기 처리 후 공통 처리
      //doButtonPostProcess(baseVariableObject);

  } catch (e) {
      alert(e.description);
      throw e;
  }

}

doButtonCase['btDraft'] = function (oBtn, oVar) {//기안하기
    
    //합의자 체크
    if (getInfo("AutoApprovalLine.Agree.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != undefined) {
            var oAutoLineAgree = $.parseJSON(getInfo("AutoApprovalLine.Agree.WorkedApprovalLine"));
            if ($$(oAutoLineAgree).find("step").concat().length > 0) {
                var jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                var oAppList = $$(jsonApv).find("steps>division[divisiontype='send']>step[routetype='assist'][unittype='person'], steps>division[divisiontype='send']>step[routetype='consult'][unittype='person']");
                for (var i = 0; i < $$(oAppList).find("ou>person").concat().length; i++) {
                    var oChkNode = $$(oAutoLineAgree).find("step>ou").has("person>[code='" + $$(oAppList).find("ou>person").concat().eq(i).attr("code") + "']");
                    if (oChkNode.length > 0) {
                        $$(oChkNode).remove();
                    }
                }
                if ($$(oAutoLineAgree).find("step>ou>person").concat().length > 0) {
                    var sAlert = "[";
                    $$(oAutoLineAgree).find("step>ou>person").concat().each(function(i, elm){
                    	if (i > 0) sAlert += ", ";
                        sAlert += getLngLabel(elm.attr("name"), false);
                        sAlert += " " + getLngLabel(elm.attr("position"), true);
                    });
                    
                    sAlert += "]";
                    sAlert = mobile_comm_getDic("msg_apv_autoChkAgree").replace("{0}", sAlert);
                    
                    alert(sAlert);
                    mobile_approval_disableBtns(false, false);
                    mobile_comm_hideload();
            		
                    return;
                }
            }
        }
    }
    //결재자 체크
    if (getInfo("AutoApprovalLine.Approval.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.Approval.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Approval.WorkedApprovalLine") != undefined) {
            var oAutoLineApproval = $.parseJSON(getInfo("AutoApprovalLine.Approval.WorkedApprovalLine"));
            if ($$(oAutoLineApproval).find("step").concat().length > 0) {
                var jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                var oAppList = $$(jsonApv).find("steps>division[divisiontype='send']>step[name!='reference'][routetype='approve'][unittype='person']");
                for (var i = 0; i < $$(oAppList).concat().length; i++) {
                    var oChkNode = $$(oAutoLineApproval).find("step").concat().has("ou > person[code='" + $$($$(oAppList).concat().eq(i)).find("ou > person").attr("code") + "']");
                    if (oChkNode.length > 0) {
                        //$$(oChkNode).remove();
                    	$$(oAutoLineApproval).find("step").remove(oChkNode.index());
                    }
                }
                if ($$(oAutoLineApproval).find("step").concat().length > 0) {
                    var sAlert = "[";
                    for (var i = 0; i < $$(oAutoLineApproval).find("step").concat().length; i++) {
                        if (i > 0) sAlert += ", ";
                        sAlert += getLngLabel($$($$(oAutoLineApproval).find("step").concat().eq(i)).find("ou > person").attr("name"), false);
                        sAlert += " " + getLngLabel($$($$(oAutoLineApproval).find("step").concat().eq(i)).find("ou > person").attr("position"), true);
                    }
                    sAlert += "]";
                    sAlert = mobile_comm_getDic("msg_apv_autoChkApproval").replace("{0}", sAlert);
                    
                    alert(sAlert);
                    mobile_approval_disableBtns(false, false);
                    mobile_comm_hideload();
            		
                    return;
                }
            }
        }
    }
    //참조자 체크
    if (getInfo("AutoApprovalLine.CCAfter.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != undefined) {
            var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine"));
            if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
                var jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                var oAppList = $$(jsonApv).find("steps > ccinfo > ou > person");
                for (var i = 0; i < $$(oAppList).concat().length; i++) {
                    var oChkNode = $$(oAutoLineCC).find("ccinfo").has("ou > person[code='" + $$($$(oAppList).concat().eq(i)).attr("code") + "']");
                    if (oChkNode.length > 0) {
                        //$$(oChkNode).remove();
                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
                    }
                }
                oAppList = $$(jsonApv).find("steps > ccinfo > ou").not("person");
                for (var i = 0; i < $$(oAppList).concat().length; i++) {
                    var oChkNode = $$(oAutoLineCC).find("ccinfo").has("ou[code='" + $$($$(oAppList).concat().eq(i)).attr("code") + "']").not("person");
                    if (oChkNode.length > 0) {
                    	//$$(oChkNode).remove();
                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
                    }
                }
                if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
                    var sAlert = "[";
                    for (var i = 0; i < $$(oAutoLineCC).find("ccinfo").concat().length; i++) {
                        if (i > 0) sAlert += ", ";
                        if ($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").length == 0) {
                            sAlert += getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou").attr("name"), false);
                        } else {
                            sAlert += getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("name"), false);
                            sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("position"), true);
                        }
                    }
                    sAlert += "]";
                    sAlert = mobile_comm_getDic("msg_apv_autoChkCC").replace("{0}", sAlert);
                    
                    alert(sAlert);
                    mobile_approval_disableBtns(false, false);
                    mobile_comm_hideload();
                    
                    return;
                }
            }
        }
    }
    //참조자 체크(사전)
    if (getInfo("AutoApprovalLine.CCBefore.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine") != undefined) {
            var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine"));
            if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
                var jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                var oAppList = $$(jsonApv).find("steps > ccinfo > ou > person");
                for (var i = 0; i < $$(oAppList).concat().length; i++) {
                    var oChkNode = $$(oAutoLineCC).find("ccinfo").has("ou > person[code='" + $$($$(oAppList).concat().eq(i)).attr("code") + "']");
                    if (oChkNode.length > 0) {
                    	//$$(oChkNode).remove();
                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
                    }
                }
                oAppList = $$(jsonApv).find("steps > ccinfo > ou").not("person");
                for (var i = 0; i < $$(oAppList).concat().length; i++) {
                    var oChkNode = $$(oAutoLineCC).find("ccinfo").has("ou[code='" + $$($$(oAppList).concat().eq(i)).attr("code") + "']").not("person");
                    if (oChkNode.length > 0) {
                    	//$$(oChkNode).remove();
                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
                    }
                }
                if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
                    var sAlert = "[";
                    for (var i = 0; i < $$(oAutoLineCC).find("ccinfo").concat().length; i++) {
                        if (i > 0) sAlert += ", ";
                        if ($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").length == 0) {
                            sAlert += getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou").attr("name"), false);
                        } else {
                            sAlert += getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("name"), false);
                            sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("position"), true);
                        }
                    }
                    sAlert += "]";
                    sAlert = mobile_comm_getDic("msg_apv_autoChkCC").replace("{0}", sAlert);
                    
                    alert(sAlert);
                    mobile_approval_disableBtns(false, false);
                    mobile_comm_hideload();
                    
                    return;
                }
            }
        }
    }
    m_sReqMode = "DRAFT";
    
    //CommentWrite.do
    if (evaluateForm()) {
    	var jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
        var eml = $$(jsonApv).find("steps>division[divisiontype='send']>step>ou>person>taskinfo[kind='charge']");
		/* 엔진에서 처리하도록 변경
        if (document.getElementById("ACTIONCOMMENT").value != "") {
        	//결재선에 <comment> 추가 후 의견 저장
        	var oComment = { "comment" : {"#text" : document.getElementById("ACTIONCOMMENT").value} } ;
        	var oCommentNode = oComment.comment;
        	if (eml.length > 0) {
        		var emlComment = $$(eml).find("comment");
        		if ($$(emlComment).length > 0) {
        			var delemlComment = eml.concat().eq(0).remove(emlComment.concat().eq(0));
        		}
        		$$(eml).append("comment", oCommentNode);
        	}
            
        	document.getElementById("APVLIST").value = JSON.stringify($$(jsonApv).concat().eq(0).json());
        }
		*/
        if(getInfo("AppInfo.usit") != ""){
        	$$(eml).attr("customattribute1", getInfo("AppInfo.usit"));
        	document.getElementById("APVLIST").value = JSON.stringify($$(jsonApv).concat().eq(0).json());
        }
        
        requestProcess("DRAFT");
    }
    else {
    	mobile_approval_disableBtns(false, false);
		mobile_comm_hideload();		
    }
}

doButtonCase['btSave'] = function (oBtn, oVar) {//임시저장
    if (document.getElementById("Subject").value == "") {
        var subject = mobile_comm_getDicInfo(getInfo("AppInfo.usnm_multi")) + " - " + CFN_GetDicInfo(getInfo("FormInfo.FormName"));
        document.getElementById("Subject").value = subject;
        m_TempSaveInfo = true;
        m_TempSave = true;
    }
    setFormAttachFileInfo();
    
    m_sReqMode = "TEMPSAVE";
    requestProcess("TEMPSAVE");
}

doButtonCase['btForward'] = function (oBtn, oVar) {//문서전달
	if(confirm(mobile_comm_getDic("msg_apv_197"))) {
		if ((getInfo("Request.loct") == "REDRAFT") && (getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT")) { m_sAddList = 'chargegroup'; } else { m_sAddList = 'charge'; }
        document.getElementById("ACTIONINDEX").value = "FORWARD";
        mobile_approval_openOrg(m_sAddList);
	}
}

doButtonCase['btApproved'] = function (oBtn, oVar) {//승인
    m_sReqMode = "APPROVE";
    
    if(getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "AUDIT")
    	document.getElementById("ACTIONINDEX").value = "APPROVAL";		//"approve";
	else if(getInfo("Request.mode") == "PCONSULT")
		document.getElementById("ACTIONINDEX").value = "AGREE";

    if(evaluateForm()) {
    	requestProcess("APPROVE");
    }
    else {
    	mobile_approval_disableBtns(false, false);
		mobile_comm_hideload();
    }
}

doButtonCase['btReject'] = function (oBtn, oVar) {//반려
	if(getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT")
		m_sReqMode = "CHARGE";
	else
		m_sReqMode = "APPROVE";
    
    if(getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "RECAPPROVAL"  || getInfo("Request.mode") == "AUDIT")    	
    	document.getElementById("ACTIONINDEX").value = "REJECT";		 //"reject";
	else if(getInfo("Request.mode") == "PCONSULT")
		document.getElementById("ACTIONINDEX").value = "DISAGREE";

    if(evaluateForm()) {
    	requestProcess("APPROVE");
    }
    else {
    	mobile_approval_disableBtns(false, false);
		mobile_comm_hideload();
    }
}

//대성, 최종결재자 사전승인
doButtonCase['btApprovedlast'] = function (oBtn, oVar) {//승인
	m_sReqMode = "APPROVAL";

	var m_evalJSON_tmp = $.parseJSON(document.getElementById("APVLIST").value);
	var elmRoot = $(m_evalJSON_tmp).find("steps");
	m_ApvPersonObj = $$(elmRoot).find("division>step>ou>person").has("taskinfo[status='pending'], taskinfo[status='inactive']");
	
	m_ApvPersonCnt = m_ApvPersonObj.length - 1;

	autoAllApproved();
}

doButtonCase['btRejectlast'] = function (oBtn, oVar) {//반려
	m_sReqMode = "REJECT";
	
	// 선반려의 경우, 최종결재자 이전은 승인, 최종결재자는 반려처리한다.
	var m_evalJSON_tmp = $.parseJSON(document.getElementById("APVLIST").value);
	var elmRoot = $(m_evalJSON_tmp).find("steps");
	m_ApvPersonObj = $$(elmRoot).find("division>step>ou>person").has("taskinfo[status='pending'], taskinfo[status='inactive']");
		
	m_ApvPersonCnt = m_ApvPersonObj.length - 1;
	  
	autoAllApproved();
}

doButtonCase['btHold'] = function (oBtn, oVar) {//보류	
    m_sReqMode = "RESERVE";
    document.getElementById("ACTIONINDEX").value = "RESERVE";	//"reserve";
	requestProcessReserve();  
}

/*doButtonCase['btRejectedto'] = function (oBtn, oVar) {//지정반송
    m_sReqMode = "APPROVE";
    document.getElementById("ACTIONINDEX").value = "REJECTTO"//"rejectedto";
    //지정반송가능여부 체크	if (fn_checkrejectedtoA())
    if (evaluateForm()) {
    	var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 433, "resize");
    	
    	var commonWritePopupOnload = function(){
    		commonWritePopup.$("input#commentOK").click(function(){
    			if(commentPopupReturnValue){
    				requestProcess("APPROVE");
    		    }
    	    });
    	};
    	
    	var pollTimer = window.setInterval(function() {
    	    if (commonWritePopup.document.getElementById("commentOK") != null || commonWritePopup.document.getElementById("commentOK") != undefined) {
    	        window.clearInterval(pollTimer);
    	        commonWritePopupOnload();
    	    }
    	}, 200);
    } else {
        document.getElementById("ACTIONINDEX").value = "";
    }
}*/

doButtonCase['btWithdraw'] = function (oBtn, oVar) {//회수
	if(confirm(mobile_comm_getDic("msg_apv_391"))) {
		requestProcess("WITHDRAW");
	} else {
		return;
	}
}

doButtonCase['btAbort'] = function (oBtn, oVar) {//취소
	requestProcess("ABORT");
}

doButtonCase['btApproveCancel'] = function (oBtn, oVar) {//승인취소
	if(confirm(mobile_comm_getDic("msg_apv_390"))) {
		document.getElementById("ACTIONINDEX").value = "approve";
		requestProcess("APPROVECANCEL");
	} else {
		return;
	}
}

doButtonCase['btDeptdraft'] = function (oBtn, oVar) {//재기안 2007.07 기안과 UI 통일	requestProcess("RECREATE");break;
    m_sReqMode = "DEPTDRAFT";

    if(evaluateForm()) {
		document.getElementById("ACTIONINDEX").value = "REDRAFT";		//"approve";
	    requestProcess("RECREATE");
    }
    else {
    	mobile_approval_disableBtns(false, false);
		mobile_comm_hideload();		
    }
}

doButtonCase['btRec'] = function (oBtn, oVar) {//재기안 2007.07 기안과 UI 통일	requestProcess("RECREATE");break;
    m_sReqMode = "DEPTDRAFT";
	if(getInfo("Request.mode") == "SUBREDRAFT") { // 부서합의인 경우 REDRAFT로 넘어가도록 함.
		document.getElementById("ACTIONINDEX").value = "REDRAFT";
	} else {
		document.getElementById("ACTIONINDEX").value = "APPROVAL";		//"approve";	
	}
	
    if(evaluateForm()) {
    	requestProcess("RECREATE");
    }
    else {
    	mobile_approval_disableBtns(false, false);
    	mobile_comm_hideload();
    }
}

doButtonCase['btCAgree'] = function (oBtn, oVar) {
	var sAddage = {};
	$.extend(sAddage, getDefaultJSON());
	// id 가 null 인 경우, 회수 시 오류 발생하여 수정함.
    $("*[data-type='dField']").each(function (i, obj) {
    	if ($(obj).attr("id") != null && $(obj).attr("id") != "") {
        	$.extend(sAddage, makeNode($(obj).attr("id"), $(obj).val()));
        }
    });
	$.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
	$.extend(sAddage, makeNode("actionUser", getInfo("Request.userCode")));
	$.extend(sAddage, makeNode("workitemID", getInfo("Request.workitemID")));
	$.extend(sAddage, makeNode("actionMode", "AGREE"));
	
    try {
    	$.ajax({
    		url:"/approval/consultation.do",
    		data: {
    			"formObj" : Base64.utf8_to_b64(JSON.stringify(sAddage))
    		},
    		type:"post",
    		dataType : "json",
    		success:function (res) {
    			callProcessEndScriptFunction(res);
    		},
    		error:function(response, status, error){
				mobile_comm_ajaxerror("/approval/consultation.do", response, status, error);
			}
    	});
	} catch (e) {
		alert(e.message);
	}
}

doButtonCase['btCDisagree'] = function (oBtn, oVar) {
	var sAddage = {};
	$.extend(sAddage, getDefaultJSON("CONSULTATION"));
	// id 가 null 인 경우, 회수 시 오류 발생하여 수정함.
    $("*[data-type='dField']").each(function (i, obj) {
    	if ($(obj).attr("id") != null && $(obj).attr("id") != "") {
        	$.extend(sAddage, makeNode($(obj).attr("id"), $(obj).val()));
        }
    });
	$.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
	$.extend(sAddage, makeNode("actionUser", getInfo("Request.userCode")));
	$.extend(sAddage, makeNode("workitemID", getInfo("Request.workitemID")));
	$.extend(sAddage, makeNode("actionMode", "DISAGREE"));
	
    try {
    	$.ajax({
    		url:"/approval/consultation.do",
    		data: {
    			"formObj" : Base64.utf8_to_b64(JSON.stringify(sAddage))
    		},
    		type:"post",
    		dataType : "json",
    		success:function (res) {
    			callProcessEndScriptFunction(res);
    		},
    		error:function(response, status, error){
				mobile_comm_ajaxerror("/approval/consultation.do", response, status, error);
			}
    	});
	} catch (e) {
		alert(e.message);
	}
}

doButtonCase['btConsultationCommentView'] = function (oBtn, oVar) {
	var ApprovalLine = $.parseJSON(getInfo("ApprovalLine"));
	var requester;
	if(getInfo("Request.subkind") === "T023"){
		requester = $$(ApprovalLine).find("step > ou").concat().find("person").concat().find(">consultation[status!='canceled']").concat().find(">consultusers").concat().find("[wiid='"+getInfo("Request.workitemID")+"']").parent().parent();
	} else {
		requester = $$(ApprovalLine).find("step > ou").concat().find("[wiid='" +getInfo("Request.workitemID")+ "']").find("person").concat().find("[code='"+getInfo("Request.userCode")+"']");
	}
	
	var tb = $('#approval_view_consultation_comment_view').find("table.approval_table > tbody").empty();
	
	var jsonConsultation = requester.find(">consultation[status!='canceled']").concat().json();
	if(!$.isArray(jsonConsultation)){
		jsonConsultation = [].concat(jsonConsultation);
	}
	
	for(i=0; i<jsonConsultation.length; i++){
		var item = jsonConsultation[i];
		var consultReqUser = {
			reqSeq : i+1,
			UserName : requester.json().name,
			DeptName : requester.json().ouname,
			result : mobile_comm_getDic("lbl_Request"),  // 요청
			datecompleted : item.daterequested,
			WorkItemID : requester.parent().attr("wiid"),
			comment : $$(item.consultcomment).length > 0 ? Base64.b64_to_utf8($$(item.consultcomment).attr("#text")) : ""
		};
		tb.append($("<tr>")
			.append($("<td>").text(consultReqUser.reqSeq))
			.append($("<td>").html( ((consultReqUser.DeptName) ? "(" + mobile_comm_getDicInfo(consultReqUser.DeptName) + ")<br/>" : "")
				+ mobile_comm_getDicInfo(consultReqUser.UserName) ))
			.append($("<td>").text(consultReqUser.result))
			.append($("<td>").text(consultReqUser.datecompleted))
			.append($("<td style=\"word-wrap:break-word;\">").text(consultReqUser.comment))
		);
		
		var pConsultUsers = $$(item).find(">consultusers").concat().json();
		if(!$.isArray(pConsultUsers)){
			pConsultUsers = [].concat(pConsultUsers);
		}
		for(j=0; j<pConsultUsers.length; j++){
			var jtem = pConsultUsers[j];
			var person = {
					reqSeq : i+1,
					UserName : $$(jtem).attr("name"),
					DeptName : $$(jtem).attr("ouname"),
					result : $$(jtem).find(">taskinfo").attr("result"),
					datecompleted : $$(jtem).find(">taskinfo").attr("datecompleted"),
					WorkItemID : $$(jtem).attr("wiid"),
					comment : $$(jtem).find(">taskinfo").find("comment").length > 0 ? Base64.b64_to_utf8($$(jtem).find(">taskinfo").find("comment").attr("#text")) : "",
					comment_fileinfo : $$(jtem).find(">taskinfo").find("comment_fileinfo").json()
			};

			var strResult = "";
			switch(person.result)
			{
				case "disagreed":
					strResult = mobile_comm_getDic("lbl_apv_disagree"); // 거부
					break;
				case "agreed":
					strResult = mobile_comm_getDic("lbl_apv_agree");  // 동의
					break;
				default:
					strResult = mobile_comm_getDic("lbl_apv_inactive"); // 대기
					break;
			}
			
			tb.append($("<tr>")
				.append($("<td>").text(person.reqSeq))
				.append($("<td>").html( ((person.DeptName) ? "(" + mobile_comm_getDicInfo(person.DeptName) + ")<br/>" : "")
					+ mobile_comm_getDicInfo(person.UserName) ))
				.append($("<td>").text(strResult))
				.append($("<td>").text(person.datecompleted))
				.append($("<td style=\"word-wrap:break-word;\">").text(person.comment))
			);
		}
	}
	
	$(".mobile_popup_btn a", "#approval_view_consultation_comment_view").click(function(){
		$("#approval_view_consultation_comment_view").hide();
	});
	$("#approval_view_consultation_comment_view").show();
}

//검토 요청
doButtonCase['btConsultReq'] = function (oBtn, oVar) {
	mobile_funConsultReq('ConsultReq');
}

doButtonCase['btReConsultReq'] = function (oBtn, oVar) {
	mobile_funConsultReq('ReConsultReq');
}

function mobile_funConsultReq(consultParamData){
	var pStrItemInfo = '{"item":[' + window.sessionStorage["userinfo"] + ']}';
	var oJSON = $.parseJSON(pStrItemInfo);
	oJSON.item = oJSON.item.filter(function(item) { if(item.AN !== getInfo("Request.userCode")) return item; });
	  
	var sAddage = {};
	$.extend(sAddage, getDefaultJSON("CONSULTATION"));
	// id 가 null 인 경우, 회수 시 오류 발생하여 수정함.
	$("*[data-type='dField']").each(function (i, obj) {
		if ($(obj).attr("id") != null && $(obj).attr("id") != "") {
	    	$.extend(sAddage, makeNode($(obj).attr("id"), $(obj).val()));
	    }
	});
	$.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
	$.extend(sAddage, makeNode("actionUser", getInfo("Request.userCode")));
	$.extend(sAddage, makeNode("workitemID", getInfo("Request.workitemID")));
	$.extend(sAddage, makeNode("consultUsers",oJSON.item));
	$.extend(sAddage, makeNode("mode", consultParamData));
	
	try {
		$.ajax({
			url:"/approval/consultationRequst.do",
			data: {
				"formObj" : Base64.utf8_to_b64(JSON.stringify(sAddage))
			},
			type:"post",
			dataType : "json",
			success:function (res) {
				btDisplay.btConsultReq = "N";
				callProcessEndScriptFunction(res);
				//ToggleLoadingImage();
			},
			error:function(response, status, error){
				alert("consultationRequst.do", response, status, error);
			}
		});
	} catch (e) {
		alert(e.message);
	}
}

doButtonCase['btConsultReqCancel'] = function (oBtn, oVar) {
	var sAddage = {};
	$.extend(sAddage, getDefaultJSON("CONSULTATION"));
	// id 가 null 인 경우, 회수 시 오류 발생하여 수정함.
	$("*[data-type='dField']").each(function (i, obj) {
		if ($(obj).attr("id") != null && $(obj).attr("id") != "") {
	    	$.extend(sAddage, makeNode($(obj).attr("id"), $(obj).val()));
	    }
	});
	$.extend(sAddage, makeNode("actionUser", getInfo("Request.userCode")));
	$.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
	$.extend(sAddage, makeNode("workitemID", getInfo("Request.workitemID")));
	$.extend(sAddage, makeNode("deleteInfos", ConsultPendingUsers()));
			        	
	try {
		$.ajax({
			url:"/approval/consultationRequstCancel.do",
			data: {
				"formObj" : Base64.utf8_to_b64(JSON.stringify(sAddage))
			},
			type:"post",
			dataType : 'json',
			success:function (res) {
				callProcessEndScriptFunction(res);
				//ToggleLoadingImage();
			},
			error:function(response, status, error){
				alert("consultationRequstCancel.do", response, status, error);
			}
	    });
	} catch (e) {
		alert(e.message);
	}
}


doButtonCase['btConsultReqModify'] = function (oBtn, oVar) {
	//callback 호출시 userParams 초기화!!
	window.sessionStorage["userParams"] = "";
	
	if(confirm(Common.getDic("msg_modifyConsultToUsers"))) {//검토자를 변경하시겠습니까?
		mobile_approval_formjsonload();
		var pStrItemInfo = '{"item":[' + window.sessionStorage["userinfo"] + ']}';
		var oJSON = $.parseJSON(pStrItemInfo);
		var currSelectUser = oJSON.item.map(function(item) {return item.AN});
		var pendingUsersJson = ConsultPendingUsers();
		var arrOrgUserCode = pendingUsersJson.map(function(item){ return $$(item).attr("code") }).join();
		
		var deleteInfos = pendingUsersJson.filter(function(item) { if(!currSelectUser.join().includes(item.code)) return item; });
		oJSON.item = oJSON.item.filter(function(item) { if(item.AN !== getInfo("Request.userCode") && !(arrOrgUserCode.includes(item.AN))) return item; });
		
		if(currSelectUser.length > 0){
			var sAddage = {};
			$.extend(sAddage, getDefaultJSON("CONSULTATION"));
			// id 가 null 인 경우, 회수 시 오류 발생하여 수정함.
		    $("*[data-type='dField']").each(function (i, obj) {
		    	if ($(obj).attr("id") != null && $(obj).attr("id") != "") {
		        	$.extend(sAddage, makeNode($(obj).attr("id"), $(obj).val()));
		        }
		    });
			$.extend(sAddage, makeNode("actionUser", getInfo("Request.userCode")));
			$.extend(sAddage, makeNode("workitemID", getInfo("Request.workitemID")));
			$.extend(sAddage, makeNode("consultUsers", oJSON.item));
			$.extend(sAddage, makeNode("deleteInfos", deleteInfos));
			$.extend(sAddage, makeNode("mode","ConsultReqModify"));
			$.extend(sAddage, makeNode("FormName", getInfo("FormInfo.FormName")));
			
		    try {
		    	$.ajax({
		    		url:"/approval/consultationRequst.do",
		    		data: {
		    			"formObj" : Base64.utf8_to_b64(JSON.stringify(sAddage))
		    		},
		    		type:"post",
		    		dataType : "json",
		    		success:function (res) {
		    			btDisplay.btConsultReq = "N";
		    			callProcessEndScriptFunction(res);
		    		},
		    		error:function(response, status, error){
						CFN_ErrorAjax("consultationRequst.do", response, status, error);
					}
		    	});
			} catch (e) {
				alert(e.message);
			}
		} else {
			alert(Common.getDic("msg_apv_noSelectedConsultUsers"));//"검토를 요청할 사용자가 선택되지 않았습니다."
		}
    }
}

function ConsultPendingUsers(){
	var oCurr = $$($.parseJSON(getInfo("ApprovalLine"))).find("step > ou").concat().find("[wiid='" +getInfo("Request.workitemID")+ "']").find("person").concat().find("[code='"+getInfo("Request.userCode")+"']");
	var jsonConsultationUser;
	if(oCurr.find("consultation[status='pending']").length > 0){
		jsonConsultationUser = $$(oCurr.find(">consultation[status='pending']").find(">consultusers").concat()).json();
		if(!$.isArray(jsonConsultationUser)){
			jsonConsultationUser = [].concat(jsonConsultationUser);
		}
	}
	return jsonConsultationUser;
}

var _AutoCmm = false;
function requestProcess(sReqMode) {
    m_sReqMode = sReqMode;

    requestProcessDetail(sReqMode);
}

function requestProcessReserve(){
	var l_ActiveModule = mobile_approval_getActiveModule();
	var sAddage = {};
	
	$.extend(sAddage, makeNode("actionMode", document.getElementById("ACTIONINDEX").value));
	$.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
	$.extend(sAddage, makeNode("actionUser", getInfo("Request.userCode"))); // 담당업무함 처리하기 위해 추가함.

    var viewMode;
    if(getInfo("Request.templatemode") == "Write") {
		viewMode = "write";
	} else {
		viewMode = "view";
	}
    
    //FIDO 파라미터 추가 2021-01-18 dgkim
    $.extend(sAddage, makeNode("g_authKey"	,  	typeof _mobile_fido_authKey  	=== "undefined" ? "" 	: _mobile_fido_authKey  ));
    $.extend(sAddage, makeNode("g_authToken",  	typeof _mobile_fido_authToken === "undefined" ? "" 	: _mobile_fido_authToken ));
    $.extend(sAddage, makeNode("g_password",  	aesUtil.encrypt(proaas, proaaI, proaapp, $("#" + l_ActiveModule +"_" + viewMode + "_inputpassword").val())) );
    $.extend(sAddage, makeNode("formID", getInfo("FormInfo.FormID")));

	var defaultJSON;
    var sJsonData;
    
    defaultJSON = getDefaultJSON();
    
    sJsonData= $.extend(defaultJSON, sAddage);
    
    var formData = new FormData();
    // 양식 기안 및 승인 정보
	formData.append("formObj", Base64.utf8_to_b64(JSON.stringify(sJsonData)));
    
    try {
    	$.ajax({
    		url:"/approval/reserve.do",
    		data: formData,
    		type:"post",
    		dataType : 'json',
    		processData : false,
	        contentType : false,
    		success:function (res) {
    			// 성공했을 경우 보류 알림 발송
    			callProcessEndScriptFunction(res);
    		},
    		error:function(response, status, error){
				mobile_comm_ajaxerror("/approval/reserve.do", response, status, error);
			}
    	});
    } catch (e) {
        alert(e.message);
    }
}

function requestProcessDetail(sReqMode) {
    try {
        var sTargetURL = "draft.do";
        var sMsgTitle;
        var sAddage = {};
        var aReqForm = getInfo("FormInfo.FormPrefix").split("_");
        m_bFileSave = true;
        
        // XForm 저장연동 (장용욱:20160323)              
        var writelink_count = 0;        // XForm 저장연동 여부
        var extdatatype = "";
        var boolerror = false;
        
        var l_ActiveModule = mobile_approval_getActiveModule();
                

        // 데이터베이스 연동
        $('*[ext-data-type1="writelink_d_text"]').each(function () {            
            writelink_count = writelink_count + 1;
            extdatatype = "writelink_d_text";
        });        
        if (writelink_count > 0) {
            boolerror = fn_writelink(extdatatype);
            // 에러발생 시 승인처리 안됨
            if (boolerror) {
                return;
            }
            writelink_count = 0;            
        }
        
        // 웹서비스 연동
        $('*[ext-data-type1="writelink_w_text"]').each(function () {            
            writelink_count = writelink_count + 1;
            extdatatype = "writelink_w_text";
        });
        if (writelink_count > 0) {
            boolerror = fn_writelink(extdatatype);
            // 에러발생 시 승인처리 안됨
            if (boolerror) {
                return;
            }
            writelink_count = 0;            
        }

        // SAP 연동
        $('*[ext-data-type1="writelink_s_text"]').each(function () {            
            writelink_count = writelink_count + 1;
            extdatatype = "writelink_s_text";
        });
        if (writelink_count > 0) {
            boolerror = fn_writelink(extdatatype);
            // 에러발생 시 승인처리 안됨
            if (boolerror) {
                return;
            }
            writelink_count = 0;
        }

        var viewMode;
        if(getInfo("Request.templatemode") == "Write") {
    		viewMode = "write";
    	} else {
    		viewMode = "view";
    	}
        
        //FIDO 파라미터 추가 2021-01-18 dgkim aesUtil.encrypt(proaas, proaaI, proaapp, $("#account_" + viewMode + "_inputpassword").val())
        $.extend(sAddage, makeNode("g_authKey"	,  	typeof _mobile_fido_authKey  	=== "undefined" ? "" 	: _mobile_fido_authKey  ));
        $.extend(sAddage, makeNode("g_authToken",  	typeof _mobile_fido_authToken === "undefined" ? "" 	: _mobile_fido_authToken ));
        $.extend(sAddage, makeNode("g_password",  	aesUtil.encrypt(proaas, proaaI, proaapp, $("#" + l_ActiveModule +"_" + viewMode + "_inputpassword").val())) );
        $.extend(sAddage, makeNode("formID", getInfo("FormInfo.FormID")));
        $.extend(sAddage, makeNode("formDraftkey", formDraftkey));
        
        $.extend(sAddage, makeNode("isMobile", "Y"));
        switch (sReqMode) {
            case "DRAFT": //"기안"
                sMsgTitle = mobile_comm_getDic("lbl_apv_Draft");

                $.extend(sAddage, makeNode("Priority", "3")); //(document.getElementById("chk_urgent").checked == true) ? "5" : "3"));
                $.extend(sAddage, makeNode("actionMode", document.getElementById("ACTIONINDEX").value));
                $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
                $.extend(sAddage, makeNode("signimagetype", document.getElementById("SIGNIMAGETYPE").value));
                
                $.extend(sAddage, getFormJSON());
                
                m_bFrmExtDirty = true;

                break;
            case "FORWARD":		// 전달
            case "CHARGE": //"담당자 지정"
                sMsgTitle = mobile_comm_getDic("lbl_apv_Charger");		//gLabel__Charger;
                var szdoclisttype = "2";
                if (getInfo("SchemaContext.scChgr.isUse") == "Y"
                    || getInfo("SchemaContext.scChgrEnt.isUse") == "Y"
                    || getInfo("SchemaContext.scChgrReg.isUse") == "Y"
                    || getInfo("SchemaContext.scDRec.isUse") == "Y"
					|| getInfo("SchemaContext.scDRecEnt.isUse") == "Y"
					|| getInfo("SchemaContext.scDRecReg.isUse") == "Y"
                    || getInfo("SchemaContext.scChgrOU.isUse") == "Y"
                    || getInfo("SchemaContext.scChgrOUEnt.isUse") == "Y"
                    || getInfo("SchemaContext.scChgrOUReg.isUse") == "Y") {
                	szdoclisttype = "6";
                }
                
                $.extend(sAddage, makeNode("actionMode", document.getElementById("ACTIONINDEX").value));
                $.extend(sAddage, makeNode("actionComment", ""));
                $.extend(sAddage, makeNode("CHARGEID", document.getElementById("CHARGEID").value));
                $.extend(sAddage, makeNode("CHARGENAME", document.getElementById("CHARGENAME").value));
                $.extend(sAddage, makeNode("CHARGEOUID", document.getElementById("CHARGEOUID").value));
                
                if((getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT") && document.getElementById("ACTIONINDEX").value == "CHARGE"){
                	$.extend(sAddage, getChangeFormJSON());
                }
                
                // 전달의 경우 performer 및 결재선 정보를 update하며, 이력은 결재선을 통해 확인할 수 있음.
                if(document.getElementById("ACTIONINDEX").value == "FORWARD"){
                	$.extend(sAddage, makeNode("WorkitemID", getInfo('Request.workitemID')));

                	sTargetURL = "forward.do";
                }
                
                m_bFrmExtDirty = true;
                break;
            case "RECREATE": //"재기안"
                sMsgTitle = mobile_comm_getDic("lbl_apv_redraft");			//gLabel__redraft;
                var szdoclisttype = "2";
                if (getInfo("SchemaContext.scChgr.isUse") == "Y"
                    || getInfo("SchemaContext.scChgrEnt.isUse") == "Y"
                    || getInfo("SchemaContext.scChgrReg.isUse") == "Y"
                    || getInfo("SchemaContext.scDRec.isUse") == "Y"
					|| getInfo("SchemaContext.scDRecEnt.isUse") == "Y"
					|| getInfo("SchemaContext.scDRecReg.isUse") == "Y"
                    || getInfo("SchemaContext.scChgrOU.isUse") == "Y"
                    || getInfo("SchemaContext.scChgrOUEnt.isUse") == "Y"
                    || getInfo("SchemaContext.scChgrOUReg.isUse") == "Y"
                    || getInfo("SchemaContext.scPRec.isUse") == "Y"
					|| getInfo("SchemaContext.scPRecEnt.isUse") == "Y"
					|| getInfo("SchemaContext.scPRecReg.isUse") == "Y") {
                    szdoclisttype = "6";
                }

                if (document.getElementById("SIGNIMAGETYPE").value == "") {
                    document.getElementById("SIGNIMAGETYPE").value = getInfo("AppInfo.usit");
                }

                $.extend(sAddage, makeNode("Priority", "3")); //(document.getElementById("chk_urgent").checked == true) ? "5" : "3"));
                $.extend(sAddage, makeNode("dpid", getInfo("AppInfo.dpid")));
                $.extend(sAddage, makeNode("dpid_apv", getInfo("AppInfo.dpid")));
                $.extend(sAddage, makeNode("dpdsn", getInfo("AppInfo.dpdsn")));
                $.extend(sAddage, makeNode("actionMode", document.getElementById("ACTIONINDEX").value));
                $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
                $.extend(sAddage, makeNode("signimagetype", document.getElementById("SIGNIMAGETYPE").value));
                $.extend(sAddage, makeNode("doclisttype", szdoclisttype));
                $.extend(sAddage, getChangeFormJSON());
                $.extend(sAddage, makeNode("islast", getIsLast()));

                m_bFrmExtDirty = true;
                if (getInfo("REQ_RESPONSE") == "Y") m_bFrmInfoDirty = true;
                break;
            case "APPROVE": //"결재"
                sMsgTitle = mobile_comm_getDic("lbl_apv_app");
                
                $.extend(sAddage, makeNode("usem", getInfo("AppInfo.usem")));				// 이메일
                $.extend(sAddage, makeNode("dpid", getInfo("AppInfo.dpid")));
                $.extend(sAddage, makeNode("dpid_apv", getInfo("AppInfo.dpid_apv")));
                $.extend(sAddage, makeNode("dpdsn",  getInfo("AppInfo.dpdsn")));
                $.extend(sAddage, makeNode("usid", getInfo("AppInfo.usid")));
                $.extend(sAddage, makeNode("usdn", getInfo("AppInfo.usnm")));
                $.extend(sAddage, makeNode("deputy", (m_bDeputy) ? "true" : "false"));
                $.extend(sAddage, makeNode("actionMode", document.getElementById("ACTIONINDEX").value));
                $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
                $.extend(sAddage, makeNode("signimagetype", document.getElementById("SIGNIMAGETYPE").value));
                $.extend(sAddage, makeNode("doclisttype", "1"));
            	$.extend(sAddage, getChangeFormJSON());
            	$.extend(sAddage, makeNode("islast", getIsLast()));
                
                if (getInfo("Request.mode") == 'APPROVAL' || getInfo("Request.mode") == 'RECAPPROVAL') m_bFrmExtDirty = true; //결재,수신결재일경우만넘김																				

                m_bFrmExtDirty = true;
                m_bFrmInfoDirty = true;
                
                break;
            case "TEMPSAVE": //"임시함"	
                sMsgTitle = mobile_comm_getDic("lbl_apv_composing");
                sTargetURL = "tempSave.do";
                
                $.extend(sAddage, makeNode("FileName", getInfo("FormInfo.FileName")));
                $.extend(sAddage, getFormJSON());
                
                if (m_TempSaveInfo == true) {
                    document.getElementById("Subject").value = "";
                }
                
                m_TempSaveInfo = false;
                m_TempSave = true;
                m_bFrmExtDirty = true;
                break;
            case "WITHDRAW": //"결재문서 회수"
                sMsgTitle = mobile_comm_getDic("lbl_apv_Doc_back");		//gLabel__Doc_back;
                
                $.extend(sAddage, makeNode("usid", getInfo("AppInfo.usid")));
                $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
                $.extend(sAddage, makeNode("actionMode", "WITHDRAW"));
                $.extend(sAddage, getInfoBodyContext());
                break;
            case "ABORT": //"결재문서 취소"
                sMsgTitle = mobile_comm_getDic("lbl_apv_Doc_cancel");		//gLabel__Doc_cancel;
                
                $.extend(sAddage, makeNode("usid", getInfo("AppInfo.usid")));
                $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
                $.extend(sAddage, makeNode("actionMode", "ABORT"));
                $.extend(sAddage, getInfoBodyContext());
                break;
            case "APPROVECANCEL": //"승인 취소"
                sMsgTitle = mobile_comm_getDic("lbl_apv_Approve_cancel");		//gLabel__Approve_cancel;
                
                $.extend(sAddage, makeNode("usid", getInfo("AppInfo.usid")));
                $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
                $.extend(sAddage, makeNode("actionMode", "APPROVECANCEL"));
                break;
            default:
                alert("[" + sReqMode + "]" + mobile_comm_getDic("msg_apv_072")); //는 지정되지 않은 모드입니다.
                return;
        }
        try {
            if (m_bFileSave == true) {
                if (getInfo("Request.mode") == "PREDRAFT") { setInfo("Request.mode", "DRAFT"); }

                var defaultJSON;
                var sJsonData;
                
                defaultJSON = getDefaultJSON(sReqMode);
                sJsonData= $.extend(defaultJSON, sAddage);
                
                var formData = new FormData();
                // 양식 기안 및 승인 정보
        		formData.append("formObj", Base64.utf8_to_b64(JSON.stringify(sJsonData)));
                
                // 파일정보
                for (var i = 0; i < mobile_obj_filelist.length; i++) {
                    if (typeof mobile_obj_filelist[i] == 'object') {
                        formData.append("fileData[]", mobile_obj_filelist[i]);
                    }
                }
                
                if(sTargetURL.indexOf("/approval/") < 0)
                	sTargetURL = "/approval/" + sTargetURL;
                
                try {
                	$.ajax({
                		url:sTargetURL,
                		data: formData,
                		type:"post",
                		dataType : 'json',
                		processData : false,
            	        contentType : false,
                		success:function (res) {
                			callProcessEndScriptFunction(res, sReqMode);
                		},
                		error:function(response, status, error){
            				mobile_comm_ajaxerror(sTargetURL, response, status, error);
            			}	
                	});
                } catch (e) {
                    alert(e.message);
                }
            } else {
                alert(mobile_comm_getDic("msg_apv_203")); //"첨부파일이 정상적으로 처리되지 않았습니다."
            }
        } catch (e) {
            alert(mobile_comm_getDic("msg_apv_073") + "\nDesc:" + e.message + "\nError number: " + e.stack); //"저장하지 못했습니다."
        }
    } catch (e) {
    	alert("Desc:" + e.message + "\nError number: " + e.stack);
    }
}

function getLngLabel(szLngLabel, szType, szSplit) {
    var rtnValue = "";
    if(szLngLabel != undefined){
	    if (szSplit != null) {
	        var ary = szLngLabel.split(";");
	        if (szSplit) { ary = szLngLabel.split(szSplit); }
	        var sValue02 = "";
	        for (var i = 0; i < ary.length; i++) {
	            sValue02 = sValue02 + ary[i] + ";";
	        }
	        if (szType) {
	            sValue02 = szLngLabel.substring(sValue.indexOf(";") + 1);
	        }
	        return mobile_comm_getDicInfo(sValue02);
	    } else {
	        var sValue02 = szLngLabel;
	        if (szType) {
	            sValue02 = szLngLabel.substring(szLngLabel.indexOf(";") + 1);
	        }
	        return mobile_comm_getDicInfo(sValue02);
	    }
    }
}

//대성: 수동 결재 함수 추가 - 관리자 소스 복사함 ==========================================
function autoAllApproved() {
	mobile_comm_showload()
	
	getActTasks();
	
	setTimeout(function() {
		var taskID = m_ActiveTaskId;
		if(taskID != "") {
			var sAction = "";
			var sComment = "";
			var sSign = "";
			
			if(m_sReqMode == "REJECT" && m_ApvPersonCnt == 0) { // 최종 반려자.
				sAction = "REJECT";
			}
			else {
				sAction = "APPROVAL";
			}
			
			if(m_ApvPersonCnt == 0) { // 최종결재자는 서명이미지가 보여야 함.
				sSign = getUserSignInfo(m_ApvPersonObj.concat().eq(m_ApvPersonObj.length - 1).attr("code")); // 최종결재자는 싸인이 필요함.
				sComment = Base64.utf8_to_b64(document.getElementById("approval_view_inputcomment").value);
			}
			else {
				// sSign = "nosign"; // 서명이미지와 사용자명 표시하지 않는 경우에 활성화
				sSign = getUserSignInfo(m_ApvPersonObj.concat().eq(m_ApvPersonObj.length - m_ApvPersonCnt).attr("code")); // 최종결재자는 싸인이 필요함.
				sComment = Base64.utf8_to_b64("");
			}
			
			// 일반결재
		    var sJsonData = {};
		    
		    $.extend(sJsonData, {"mode": "APPROVAL"});
		    $.extend(sJsonData, {"subkind": "T006"});
		    $.extend(sJsonData, {"taskID": taskID});
	    	$.extend(sJsonData, {"FormInstID" : getInfo("FormInstanceInfo.FormInstID")});
		    $.extend(sJsonData, {"actionMode": sAction});
		    $.extend(sJsonData, {"actionComment": sComment});
		    $.extend(sJsonData, {"signimagetype" : sSign});
		    
		    var formData = new FormData();
		    // 양식 기안 및 승인 정보
			formData.append("formObj", Base64.utf8_to_b64(JSON.stringify(sJsonData)));
		        
		    callRestAPI(formData);
		} 
		else {
			alert(mobile_comm_getDic("msg_apv_alert_006")); //성공적으로 처리 되었습니다.
	 		mobile_comm_back();
		}
	}, 500);
}

//get tasks
function getActTasks(){
	$.ajax({
	    url: "/approval/admin/getacttasks.do",
	    type: "POST",
	    data: {
			"piid" : getInfo("ProcessInfo.ProcessID")
		},
		async:false,
	    success: function (res) {
	    	if(res.list != undefined) {
	    		getActTasksSuccessCallback(res.list.data);
	    	}
	    	else {
	    		m_ActiveTaskId = "";	
	    	}
      },
      error:function(response, status, error){
			mobile_comm_ajaxerror("getacttasks.do", response, status, error);
		}
	});
	
}

function getActTasksSuccessCallback(data){
	m_ActiveTaskId = "";
	$.each(data,function(i,obj) {
		m_ActiveTaskId = validateJsonVal(obj.id);
		return false; // 1개씩 처리함.
	});
}

//엔진 호출하기
function callRestAPI(formData){
	$.ajax({
		url:"/approval/draft.do",
		data: formData,
		type:"post",
		dataType : 'json',
		processData : false,
        contentType : false,
	    success: function (res) {
	    	if(res.status == 'SUCCESS'){
	    		m_ApvPersonCnt--;
	    		autoAllApproved();
	    	} else if(res.status == 'FAIL'){
	    		alert(res.message);
	    	}
	    },
	    error:function(response, status, error){
			mobile_comm_ajaxerror("draft.do", response, status, error);
		}
	});
}

function getUserSignInfo(usercode){
	var retVal = "";
	
	$.ajax({
	    url: "/approval/mobile/user/getUserSignInfo.do",
	    type: "POST",
	    data: {
			"UserCode" : usercode
		},
		async:false,
	    success: function (res) {
	    	if(res.status == 'SUCCESS'){
	    		retVal = res.data;
	    	} else if(res.status == 'FAIL'){
	    		alert(res.message);
	    	}
        },
        error:function(response, status, error){
			mobile_comm_ajaxerror("getUserSignInfo.do", response, status, error);
		}
	});
	
	return retVal;
}

function validateJsonVal(val){
	var ret;
	if (typeof(val) != 'undefined' && val != null)
	{
	    ret = val;
	} else {
		ret = '';
	}
	
	return ret;
}

//엔진 호출 후 스크립트 처리 (구 receiveProcessHTTP, fnformmenuCallBack 함수 처리 등)
function callProcessEndScriptFunction(res, sReqMode) {
	if (res.status == "SUCCESS" || (res.status == "FAIL" && res.message.indexOf("NOTASK")>-1)) {
		if(res.status == "FAIL"){
			res.message = mobile_comm_getDic("msg_apv_notask");
			alert(res.message);
			mobile_approval_disableBtns(false, false);
			mobile_comm_hideload();
		}
		else {
			alert(res.message);
			
			if(_mobile_approval_view.isViewPanel) {
				mobile_comm_hideload();
				parent.mobile_approval_ClickFirstList();
				return;
			}
			
			isLoad = "N";
			var jobBizCode = ((_mobile_approval_view.Gloct == "JOBFUNCTION" || _mobile_approval_view.Gloct == "BizDoc") && _mobile_approval_view.UserCode) ? _mobile_approval_view.UserCode : "";
			window.location.href = "/approval/mobile/approval/list.do?mode=" + (sReqMode == "DRAFT" ? _mobile_approval_write.ListMode : _mobile_approval_view.ListMode) + "&jobBizCode=" + jobBizCode;
		}
	}else {
		// 엔진쪽에서 Transaction lock (일시적) 인경우, 병렬합의자 동시 액션등.
		if(/VariableInstanceEntity(.)+ was updated by another transaction concurrently/g.test(res.message)){
			res.message = mobile_comm_getDic("msg_apv_tasklocked");
		}
		alert(mobile_comm_getDic("msg_apv_030") + " : " + res.message);
		mobile_approval_disableBtns(false, false);
		mobile_comm_hideload();		
		//mobile_comm_back();
	}
}


//1인결재 및 담당자 추가 관련 수정 20006.08 by sunny
function evaluateForm() {
    switch (getInfo("FormInfo.FormPrefix")) {
        case "DRAFT":
            if ((getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "DRAFT") && document.getElementById("Subject").value == "") {
                alert(gMessage28); return false; //"제목을 입력하세요."
            }            
        case "REQUEST":
        default:
            //첨부파일 처리
        	if(getInfo("Request.editmode") == "Y" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "DRAFT")
        		setFormAttachFileInfo();

            if (m_sReqMode != "TEMPSAVE" && m_sReqMode != "APPROVE" && m_sReqMode != "DEPTDRAFT") {
                m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
                var elmRoot = $$(m_evalJSON).find("steps");
                var elmList;
                
                if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") {
                    elmList = $$(elmRoot).find("division").has("taskinfo[status='inactive']").find(">step[routetype='approve']>ou>person,>step[routetype='approve']>ou>role").has("taskinfo[kind!='charge']");
                } else if (getInfo("Request.mode") == "REDRAFT") {
                    if (m_sReqMode == "CHARGE") {
                        elmList = $$(elmRoot).find("division[divisiontype='receive']>step");
                    } else {
                        elmList = $$(elmRoot).find("division[divisiontype='receive']>step[routetype='approve']>ou>person,division[divisiontype='receive']>step[routetype='approve']>ou>role").has("taskinfo[kind!='charge']");
                    }
                } else if (getInfo("Request.mode") == "SUBREDRAFT") {
                	if (m_sReqMode == "CHARGE") {
                        elmList = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step>ou").has("taskinfo[processID='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "'],[execid='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "']");
                    } else {
                        elmList = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step>ou").has("taskinfo[processID='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "'],[execid='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "']").find(">person,>role").has("taskinfo[kind!='charge']");
                    }
                } else {
                    elmList = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step[routetype='approve']>ou>person,>step[routetype='approve']>ou>role").has("taskinfo[kind!='charge']");
                }

				// scCHLimit 결재자수 제한
				if (getInfo("SchemaContext.scCHLimit.isUse") == "Y" && getInfo("SchemaContext.scCHLimit.value") != '') {
			    	var $$_elmApprove = elmRoot.find("division[divisiontype='"+(m_sApvMode == "REDRAFT" ? "receive" : "send")+"']>step").concat().has("[routetype='approve'][unittype='role'],[routetype='approve'][unittype='person']").has("ou>person>taskinfo[kind!='charge'],ou>role>taskinfo[kind!='charge']");
			        if ($$_elmApprove.length > parseInt(getInfo("SchemaContext.scCHLimit.value"))) {
			        	Common.Warning(Common.getDic("msg_apv_050").replace('~', getInfo("SchemaContext.scCHLimit.value")));
			            return false;
			        }
				}
				
                if ((getInfo("SchemaContext.scPAgr.isUse") == "Y" || getInfo("SchemaContext.scPAgrSEQ.isUse") == "Y" )&& (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT")) {
                    var $$_elmConsult = $$(elmRoot).find("division>step[routetype='consult'][unittype='person']");
                    if (!$$_elmConsult.exist()) {
                        if (getInfo("SchemaContext.scDAgr.isUse") == "Y") {
                            if (!chkConsultAppLine($$(elmRoot))) return false;
                        }
                    } else {
                        if (getInfo("SchemaContext.scACLimit.isUse") == "Y" && getInfo("SchemaContext.scACLimit.value") != '' && $$_elmConsult.find("ou").concat().length > parseInt(getInfo("SchemaContext.scACLimit.value"))) {
                            Common.Warning( Common.getDic("msg_apv_051").replace('~ ',getInfo("SchemaContext.scACLimit.value")) ); //결재선에서 합의자수 ~ 명을 초과할 수 없습니다.
                            return false;
                        } else {
                            if (!chkConsultAppLine($$(elmRoot))) return false;
                        }
                    }
                }

                if (elmList.length == 0 && admintype != "ADMIN") {
                    //임시저장시 1인결재일 가능 
                    if (getInfo("SchemaContext.scChrDraft.isUse") == "Y" && (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE")) {
                        if (!confirm(mobile_comm_getDic("msg_apv_198"))) return false;
                    } else if (getInfo("SchemaContext.scChrRedraft.isUse") == "Y" && getInfo("Request.mode") == "REDRAFT") {
                        if (!confirm(mobile_comm_getDic("msg_apv_198"))) return false;
                    } else {
                        alert(mobile_comm_getDic("msg_apv_029")); //"결재선이 지정되지 않았습니다."
                        return false;
                    }
                }

                var elmRecList = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step[routetype='approve']>ou>person,>step[routetype='approve']>ou>role").has("taskinfo[kind!='charge']");
                if ((getInfo("SchemaContext.scDRec.isUse") == "Y" || getInfo("SchemaContext.scDRecEnt.isUse") == "Y" || getInfo("SchemaContext.scDRecReg.isUse") == "Y") && (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "APPROVAL")) {
                    var elmOu = $$(elmRoot).find("division>step[routetype='receive']>ou");
                    if (elmOu.length == 0) {
                        if (confirm(mobile_comm_getDic("msg_apv_199"))) return checkForm((m_sReqMode == "TEMPSAVE" ? true : false)); //"경유부서 없이 진행하시겠습니까?"
                    } else {
                    }
                }

                if ((getInfo("SchemaContext.scPRec.isUse") == "Y" || getInfo("SchemaContext.scPRecEnt.isUse") == "Y" || getInfo("SchemaContext.scPRecReg.isUse") == "Y") && (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "APPROVAL")) {
                    var elmOu = $$(elmRoot).find("division>step[routetype='receive']>ou>person");

                    if (elmOu.length == 0) {
                        if (getInfo("SchemaContext.scPRec.value") == "select") {
                            if (!confirm(mobile_comm_getDic("msg_apv_201"))) return false; //"담당자 지정없이 진행하시겠습니까?"
                        } else {
                            if ((getInfo("SchemaContext.scDRec.isUse") == "Y" || getInfo("SchemaContext.scDRecEnt.isUse") == "Y" || getInfo("SchemaContext.scDRecReg.isUse") == "Y") && (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "APPROVAL")) {
                                elmOu = $$(elmRoot).find("division>step[routetype='receive']");
                                if (elmOu.length == 0) {
                                    alert(mobile_comm_getDic("msg_apv_181")); //"담당자를 지정하십시요"
                                    return false;
                                }
                            } else {
                                alert(mobile_comm_getDic("msg_apv_181")); //"담당자를 지정하십시요"
                                return false;
                            }
                        }
                    } else {
                        //담당업무를 1개만 지정하도록 수정
                        var elmReceive = $$(elmRoot).find("division>step[unittype='person'][routetype='receive']");

                        //한번에 두개 이상의 담당업무를 지정 할 경우 Check
                        if (elmReceive.length > 0) {
                            var ouReceive = $$(elmReceive).concat().eq(0).find("person");
                        }
                    }
                }
                //문서이관 관련 check
                if (getInfo("SchemaContext.scEdmsLegacy.isUse") == "Y" && m_sReqMode == "DRAFT" && (document.getElementById("DocLevel").value == "" || document.getElementById("SaveTerm").value == "" || document.getElementById("DocClassName").value == "")) {
                    alert(mobile_comm_getDic("msg_apv_202")); //"문서관리시스템 이관을 위한 문서정보를 입력하십시오."
                    return false;
                }
                if((getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT") && getInfo("Request.editmode") != "Y")
                	return true;
                else
                	return checkForm((m_sReqMode == "TEMPSAVE" ? true : false));
            } else {
                //수신부서 1인결재 확인
                if ((m_sReqMode == "APPROVE" || m_sReqMode == "DEPTDRAFT") && (getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT")
                    && document.getElementById("ACTIONINDEX").value != "REJECT" && document.getElementById("ACTIONINDEX").value != "RESERVE" && document.getElementById("ACTIONINDEX").value != "REJECTTO") { // [2015-07-21 han modi] 부서수신함/담당업무함 관련 조건추가 (dobuttoncase 에서 m_sReqMode=approve로 넘어와서)
                	m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
                    var elmRoot = $$(m_evalJSON).find("steps");
                    var elmList;

                    if (getInfo("Request.mode") == "REDRAFT") {
                        if (m_sReqMode == "CHARGE") {
                            elmList = $$(elmRoot).find("division[divisiontype='receive']>step");
                        } else {
                            elmList = $$(elmRoot).find("division[divisiontype='receive']>step[routetype='approve']>ou>person,division[divisiontype='receive']>step[routetype='approve']>ou>role").has("taskinfo[kind!='charge']");
                        }
                    } else if (getInfo("Request.mode") == "SUBREDRAFT") {
                        if (m_sReqMode == "CHARGE") {
                            elmList = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step>ou").has("taskinfo[processID='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "'],[execid='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "']");
                        } else {
                            elmList = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step>ou").has("taskinfo[processID='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "'],[execid='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "']").find(">person,>role").has("taskinfo[kind!='charge']");
                        }
                    } else {
                        elmList = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step[routetype='approve']>ou>person,>step[routetype='approve']>ou>role").has("taskinfo[kind!='charge']");
                    }

                    if (elmList.length == 0 && admintype != "ADMIN") {
                    	if (getInfo("Request.mode") == "REDRAFT" && (getInfo("SchemaContext.scChrRedraft.isUse") == "Y")) { // || getInfo("Request.subkind") == "T008"
                            if (!confirm(mobile_comm_getDic("msg_apv_198"))) return false;
                        } else if (getInfo("Request.mode") == "SUBREDRAFT" && getInfo("SchemaContext.scChrDraft.isUse") == "Y" && getInfo("SchemaContext.scRecAssist.isUse") == "Y") {
                        	// 부서합의(협조)인 경우 1인결재 & 접수 기능 사용 시 전결처리 가능하도록 수정함.
                            if (!confirm(mobile_comm_getDic("msg_apv_198"))) return false;
                        } else {
                            alert(mobile_comm_getDic("msg_apv_029")); //"결재선이 지정되지 않았습니다."
                            return false;
                        }
                    }
                }

                if (getInfo("Request.editmode") == "Y") {
                    return checkForm((m_sReqMode == "TEMPSAVE" ? true : false));
                } else {
					var isDeploy = false;
					if(getInfo("SchemaContext.pdef.value").toLowerCase().indexOf("draft") > -1 
						&& formJson.ApprovalLine && $$(formJson.ApprovalLine).find("division").has("taskinfo[status='pending']").find("[divisiontype='receive']").length > 0){
							isDeploy = true;
					}
						
					// 배포처일땐 제외, 후결 제외
					if(!isDeploy && getInfo("ProcessInfo.SubKind") != "T005"){
	                    if (getInfo("SchemaContext.scCheckApproval.isUse") == "Y") {
	                        return checkForm((m_sReqMode == "TEMPSAVE" ? true : false));
	                    }else if(typeof checkFormForRead == "function"){ // 읽기모드 validation함수 추가
							return checkFormForRead();
						}
					}
                    return true;
                }
            }
	}
}

function chkConsultAppLine($$_elmRoot) {
    var $$_emlSteps = $$_elmRoot.find("division>step");
    //발신,수신체크
    if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT") {
        $$_emlSteps = $$_elmRoot.find("division[divisiontype='send']>step");
    } else if (getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "RECAPPROVAL") {
        $$_emlSteps = $$_elmRoot.find("division:has(>taskinfo[status='pending'])>step");
    }
    var emlStep;
    var $$_elmList = $$_elmRoot.find("division>step[unittype='person'][routetype='approve'],step[unittype='role'][routetype='approve']>ou>person,role");
    //발신,수신체크
    if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT") {
        $$_elmList = $$_elmRoot.find("division[divisiontype='send']>step[unittype='person'][routetype='approve'],step[unittype='role'][routetype='approve']>ou>person,role");
    } else if (getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "RECAPPROVAL") {
        $$_elmList = $$_elmRoot.find("division:has(>taskinfo[status='pending'])>step[unittype='person'][routetype='approve'],step[unittype='role'][routetype='approve']>ou>person,role");
    }
    var $$_elm, $$_elmTaskInfo;
    var HasApprover = false;
    var HasConsult = false;
    var HadReviewer = false;
    var PreConsult = false;
    var EndReviewer = false;
    var CurConsult = false;
    var CurAssist = false;

    $$_emlSteps.concat().each(function (i, $$_emlStep) {
        if ($$_emlStep.attr("routetype") == "consult" || $$_emlStep.attr("routetype") == "assist" || $$_emlStep.attr("routetype") == "audit") HasConsult = true; //감사관련 수정
        if (i == $$_emlSteps.valLength() - 2 && $$_emlStep.attr("routetype") == "consult") PreConsult = true;
        if (i == $$_emlSteps.valLength() - 1 && $$_emlStep.attr("routetype") == "consult") CurConsult = true;
        if (i == $$_emlSteps.valLength() - 1 && $$_emlStep.attr("routetype") == "assist") CurAssist = true;
    });

    $$_elmList.concat().each(function (j, $$_elm) {
        $$_elmTaskInfo = $$_elm.find("taskinfo");
        if (j == $$_elmList.length - 1 && $$_elmTaskInfo.attr("kind") == "review") EndReviewer = true;
    });

    if (HasConsult) {
        if (HasApprover == true) {
            return true;
        } else {
            if (PreConsult && EndReviewer) {
                Common.Warning(Common.getDic("msg_apv_058")); //최종결재자가 후결인 경우에 전 결재자는 합의일 수 없습니다.
                return false;
            } else {
                if (CurConsult) {
                    Common.Warning(Common.getDic("msg_apv_setFormRuleErrorMsg")); //합의(순차,병렬)과 협조(순차,병렬)은 마지막에 올 수 없습니다.<br>결재자를 추가적으로 지정해주세요.
                    return false;
                }
                else { return true; }
            }
        }
    } else {
        return true;
    }
}

function getDefaultJSON(sReqMode) {
    var jsonObj = {};
    $.extend(jsonObj, makeNode("processID", (m_sReqMode == "TEMPSAVE" ||  m_sReqMode == "DRAFT" ? "" : getInfo("ProcessInfo.ProcessID"))));				//$.extend(jsonObj, makeNode("processID", (m_sReqMode == "TEMPSAVE" ? "" : null)));
    $.extend(jsonObj, makeNode("parentprocessID", (m_sReqMode == "TEMPSAVE" ||  m_sReqMode == "DRAFT" ? "" : getInfo("ProcessInfo.ParentProcessID"))));
    $.extend(jsonObj, makeNode("processName", (m_sReqMode == "TEMPSAVE" ||  m_sReqMode == "DRAFT" ? "" : getInfo("ProcessInfo.ProcessName"))));
    
    //기안 취소 / 회수 일 경우 현재 pending 인 결재자의 taskid 넘기기
    if(sReqMode == "ABORT" || sReqMode == "WITHDRAW" || sReqMode == "APPROVECANCEL"){
    	var taskid = "";
    	var apvLineObj = $.parseJSON(getInfo("ApprovalLine"));
    	
    	taskid = $$(apvLineObj).find("division>step>ou").has("taskinfo[status='pending'],[status='reserved']").concat().eq(0).attr("taskid");
    	$.extend(jsonObj, makeNode("taskID", taskid));
    	
    }else{
    	$.extend(jsonObj, makeNode("taskID", getInfo("ProcessInfo.TaskID") == undefined ? "" : getInfo("ProcessInfo.TaskID")));
    }
	
    $.extend(jsonObj, makeNode("processDefinitionID", getInfo("SchemaContext.pdef.value")));
	$.extend(jsonObj, makeNode("subkind", getInfo("Request.subkind")));
	$.extend(jsonObj, makeNode("performerID"));
	$.extend(jsonObj, ((getInfo("Request.subkind") == "T008" && getInfo("Request.mode") != "DRAFT") ? makeNode("mode", "REDRAFT") : makeNode("mode", getInfo("Request.mode"))));
	$.extend(jsonObj, makeNode("gloct", getInfo("Request.gloct")));
	$.extend(jsonObj, makeNode("dpid", getInfo("AppInfo.dpid")));
	$.extend(jsonObj, makeNode("usid", getInfo("AppInfo.usid")));
	$.extend(jsonObj, makeNode("sabun"));
	$.extend(jsonObj, makeNode("dpid_apv", getInfo("AppInfo.dpid_apv")));
	$.extend(jsonObj, makeNode("dpdn_apv", (getInfo("AppInfo.dpdn_apv") == undefined ? "" : getInfo("AppInfo.dpdn_apv")).replace("&", "&amp;")));
	$.extend(jsonObj, makeNode("usdn", getInfo("AppInfo.usnm")));
	$.extend(jsonObj, makeNode("dpdsn")); 
	$.extend(jsonObj, makeNode("FormID", getInfo("FormInfo.FormID"))); 
	$.extend(jsonObj, makeNode("FormName", getInfo("FormInfo.FormName"))); 
	$.extend(jsonObj, makeNode("FormPrefix", getInfo("FormInfo.FormPrefix")));
	$.extend(jsonObj, makeNode("BodyType", getInfo("FormInfo.BodyType")));
	$.extend(jsonObj, makeNode("Revision", getInfo("FormInfo.Revision"))); 
	$.extend(jsonObj, makeNode("FormInstID", getInfo("FormInstanceInfo.FormInstID"))); 
	$.extend(jsonObj, makeNode("formtempID")); 
	$.extend(jsonObj, makeNode("UserCode"));
	$.extend(jsonObj, makeNode("SchemaID", getInfo("FormInfo.SchemaID")));
	$.extend(jsonObj, makeNode("FileName", getInfo("FormInfo.FileName"))); 
	$.extend(jsonObj, makeNode("FormTempInstBoxID", getInfo("Request.formtempID")));
	$.extend(jsonObj, makeNode("FormInstID_response"));
	$.extend(jsonObj, makeNode("FormInstID_spare"));
	$.extend(jsonObj, makeNode("editMode", getInfo("Request.editmode")));
		
	$.extend(jsonObj, {"ProcessDescription" : getFormInfosJSON()});
	$.extend(jsonObj, {"ApprovalLine" : getApvList()});
	
    if (getInfo("Request.subkind") == "T005" || getInfo("Request.subkind") == "T018") {
    } else {
    	$.extend(jsonObj, (m_bFrmExtDirty ? { "FormInfoExt" : getFormInfoExtJSON()} : { "FormInfoExt" : {}})); // T005 후결, T018 공람
    }
	
    return jsonObj;
}

function makeNode(sName, vVal) {
    var jsonObj = {};
    
    if(vVal == null || vVal == undefined){
    	vVal = "";
    }
    
    jsonObj[sName] = vVal;
    
    return jsonObj;
}

function getFormInfosJSON() {
    var forminfos = getProcessDescription();
    return forminfos;
}

function getProcessDescription() {
    var m_oFormInfos = {
    		"FormInstID" : "",
    		"FormID" : getInfo("FormInfo.FormID"),
    		"FormName" : getInfo("FormInfo.FormName"), 
    		"FormSubject" :  ((document.getElementById("Subject") == undefined) ? getInfo("FormInstanceInfo.Subject") : document.getElementById("Subject").value),
    		"IsSecureDoc" : "N", //(document.getElementById("chk_secrecy").checked == true) ? "Y" : "N",
    		"IsFile" : "",
    		"FileExt" : "",
    		"IsComment" : "",					// 임의로 N
    		"ApproverCode" : "",
    		"ApproverName" : "",
    		"ApprovalStep" : "",
    		"ApproverSIPAddress" : "",
    		"IsReserved" : "N",
    		"ReservedGubun" : "",
    		"ReservedTime" : "",
    		"Priority" : "3", //(document.getElementById("chk_urgent").checked == true) ? "5" : "3",
    		"IsModify" : "N"
    	};
    
    //첨부파일 유무 확인
    var sIsFile = "N";
    if (document.getElementById("AttachFileInfo").value != "") {
        var oIsFile = $.parseJSON(document.getElementById("AttachFileInfo").value);
        sIsFile = (oIsFile.FileInfos != undefined && oIsFile.FileInfos.length > 0) ? "Y" : "N";													// 첨부파일 JSON 형태가 변함됨에 따라 변경
    }
    m_oFormInfos.IsFile = sIsFile;
    
    //첨부파일 확장자
    m_oFormInfos.FileExt = "";		/*XFN_GetFileExt()*/					// 첨부파일(FormAttach.js) 소스 생성된 이후 수정

    //의견갯수
    var iCommentCount = "N";
    if (document.getElementById("APVLIST").value != "") {
        iCommentCount = $$($.parseJSON(document.getElementById("APVLIST").value)).find("step").concat().find("comment").length > 0 ? "Y" : "N";
    }
    m_oFormInfos.IsComment = iCommentCount;
    
    return m_oFormInfos;
}

//xml -> json
function getApvList() {
	var jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
	
    if (m_sReqMode == "RECREATE" && getInfo("SchemaContext.scRec.isUse") == "Y") {
        var oFirstNode = $$(jsonApv).find("steps>division").has("taskinfo[status='pending']").has("[divisiontype='receive'][oucode='" + getInfo("AppInfo.dpid_apv") + "']");
        if (oFirstNode.length == 0) {
        	
        	var oDiv = {};
            var oStep = {};
            var oOU = {};
            var oTaskinfo = {};
            
            $$(oTaskinfo).attr("status", "pending");
            $$(oTaskinfo).attr("result", "pending");
            $$(oTaskinfo).attr("kind", "normal");
            $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
            
            $$(oOU).append("taskinfo", oTaskinfo);
            
            $$(oOU).attr("code", getInfo("AppInfo.dpid_apv"));
            $$(oOU).attr("name", getInfo("AppInfo.dpdn_apv"));
            
            $$(oStep).append("ou", oOU);
            
            $$(oStep).attr("unittype", "person");//ou
            $$(oStep).attr("routetype", "approve"); //receive
            $$(oStep).attr("name", mobile_comm_getDic("lbl_apv_ChargeDept_Rec"));		//gLabel__ChargeDept_Rec);
            
            $$(oDiv).append("step", oStep);
            $$(jsonApv).find("steps").append("division", oDiv);
            
            oFirstNode = $$(jsonApv).find("steps>division").has("taskinfo[status='pending']").has("[divisiontype='receive'][oucode='" + getInfo("AppInfo.dpid_apv") + "']").find(">step>ou");
        }
        if ($$(oFirstNode).find("person[code='" + getInfo("AppInfo.usid") + "']>taskinfo[kind='charge']") == null) {
            /*var oPerson = jsonApv.createElement("person");
            var oTaskinfo = jsonApv.createElement("taskinfo");*/
        	
        	var oPerson = {};
            var oTaskinfo = {};
            
            $$(oTaskinfo).attr("status", "pending");
            $$(oTaskinfo).attr("result", "pending");
            $$(oTaskinfo).attr("kind", "charge");
            $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
            
            $$(oPerson).append("taskinfo", oTaskinfo);
            
            $$(oPerson).attr("code", getInfo("AppInfo.usid"));
            $$(oPerson).attr("name", getInfo("AppInfo.usnm_multi"));
            $$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
            $$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
            $$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
            $$(oPerson).attr("oucode", getInfo("AppInfo.dpid"));
            $$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
            $$(oPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
            
            $$(jsonApv).find("steps>division").has("taskinfo[status='pending'][divisiontype='receive'][oucode='" + getInfo("AppInfo.dpid_apv") + "']").find(">step>ou)").append("person", oPerson);
            
        }

    }
    //2006.9.20 김현태 결재선 임시 저장 관련 수정 - 기안자만 있는 경우 넘기지 결재선을 넘기지 않는다.
    // 회수 및 기안취소 포함
    if (m_sReqMode == "TEMPSAVE" || m_sReqMode == "WITHDRAW" || m_sReqMode == "ABORT") {
        var oFirstNodeList = $$(jsonApv).find("steps>division>step>ou>person");
        // 2013.08.08 : yu2mi : 기안자만 있는 경우 초기화  시키는데, 그럴경우 추가된 참조자도 사라짐.*/
        var oCurrentDivNode = $$(jsonApv).find("steps>division[divisiontype='send']");
        var oChargeNode = $$(oCurrentDivNode).find("step").has("ou>person>taskinfo[kind='charge']");
        
        if (oChargeNode.length != 0)
        	$$(oCurrentDivNode).find("step").has("ou>person>taskinfo[kind='charge']").remove();
        
        var oCurrentDivTaskinfo = $$(oCurrentDivNode).find("taskinfo");
        $$(oCurrentDivTaskinfo).attr("status", "inactive");
        $$(oCurrentDivTaskinfo).attr("result", "inactive");
        
        try { $$(oCurrentDivTaskinfo).remove("datereceived"); } catch (e) { mobile_comm_log(e); }
        try { $$(oCurrentDivTaskinfo).remove("datecompleted"); } catch (e) { mobile_comm_log(e); }
        try { $$(oCurrentDivTaskinfo).remove("customattribute1"); } catch (e) { mobile_comm_log(e); }
        try { $$(oCurrentDivTaskinfo).remove("wiid"); } catch (e) { mobile_comm_log(e); }
        try { $$(oCurrentDivTaskinfo).remove("mobileType"); } catch (e) { mobile_comm_log(e); }
        //try { $$(oCurrentDivNode).find("taskinfo>comment").parent().concat().eq(0).remove($$(oCurrentDivNode).find("taskinfo>comment").concat().eq(0)); } catch (e) { }
        try { $$(oCurrentDivNode).find("step").concat().find("person").concat().find("taskinfo>comment").remove(); } catch (e) { mobile_comm_log(e); }
        
        //그외 노드의 경우 status result datereceived
        var oTaskinfos = $$(oCurrentDivNode).find("step>ou>person>taskinfo");
        $$(oTaskinfos).each(function (i, elm) {
            $$(elm).attr("status", "inactive");
            $$(elm).attr("result", "inactive");
            $$(elm).remove("datereceived");
            $$(elm).remove("datecompleted");
            $$(elm).remove("mobileType");
        });
        oTaskinfos = $$(oCurrentDivNode).find("step>taskinfo");
        $$(oTaskinfos).each(function (i, elm) {
            $$(elm).attr("status", "inactive");
            $$(elm).attr("result", "inactive");
            $$(elm).remove("datereceived");
            $$(elm).remove("datecompleted");
        });
        
        $$(oCurrentDivNode).find("step>ou").concat().each(function(i, elm){
        	$$(elm).remove("widescid");
            $$(elm).remove("pfid");
            $$(elm).remove("taskid");
            $$(elm).remove("wiid");
        });
        
        //참조 셋팅 yu2mi: 2013-08-07
        var oCcinfo = $$(jsonApv).find("steps>ccinfo");
        try {
        	if(oCcinfo.exist()){
	            $$(oCcinfo).concat().each(function (i, elm) {
	                $$(elm).attr("datereceived", "");
	            });
        	}
        } catch (e) { mobile_comm_log(e); }
    }
    return jsonApv;
}


function getFormInfoExtJSON() {
    var forminfoext = {};
   
    $.extend(forminfoext, makeNode("scOPub", (getInfo("SchemaContext.scOPub.isUse") == 'Y' ? "True" : "False")));	/*대외공문*/
    $.extend(forminfoext, makeNode("scIPub", (getInfo("SchemaContext.scIPub.isUse") == "Y" ? "True" : "False")));
    
    //각 부서함들 저장여부 설정
    $.extend(forminfoext, makeNode("scABox", getInfo("SchemaContext.scABox.isUse")));
	$.extend(forminfoext, makeNode("scSBox", getInfo("SchemaContext.scSBox.isUse")));
    $.extend(forminfoext, makeNode("scRPBox", getInfo("SchemaContext.scRPBox.isUse")));
    $.extend(forminfoext, makeNode("scJFBox", getInfo("SchemaContext.scJFBox.isUse")));
    $.extend(forminfoext, makeNode("scJFBoxV", getInfo("SchemaContext.scJFBox.value")));
    $.extend(forminfoext, makeNode("scAutoReview", getInfo("SchemaContext.scAutoReview.isUse")));
    
    if (getInfo("SchemaContext.scOPub.isUse") == 'Y' && getInfo("SchemaContext.scOPub.value") != "") {
    	$.extend(forminfoext, makeNode("outerpub_doctype", getInfo("SchemaContext.scOPub.value")));
    }

    if (getInfo("SchemaContext.scIPub.isUse") == "Y" || getInfo("SchemaContext.scOPub.isUse") == 'Y') {
		$.extend(forminfoext, makeNode("ReceiptList", (getInfo("SchemaContext.scOPub.isUse") == '1' ? "" : document.getElementById("ReceiptList").value)));
		$.extend(forminfoext,makeNode("ReceiveNames", (document.getElementById("ReceiveNames").value)));
    } else { 
    	$.extend(forminfoext, makeNode("ReceiptList", ""));
    	$.extend(forminfoext,makeNode("ReceiveNames", ""));
    }

    // (본사운영) 대외공문품의서 s
    if (getInfo("FormInfo.FormPrefix") == "WF_FORM_EXTERNAL") {
        var strRegistratorName = "";
        try {
            if (getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "DRAFT") {
                strRegistratorName = $("#NO").val();
            } else {
                strRegistratorName = $("#NO").html();
            }
            $.extend(forminfoext, makeNode("RegistratorName", ((strRegistratorName != "") ? strRegistratorName : '')));
        }
        catch (ex) { mobile_comm_log(ex); }
    }
    
    $.extend(forminfoext, makeNode("IsUseDocNo", getInfo("SchemaContext.scDNum.isUse") == "Y" ? "True" : "False"));
    $.extend(forminfoext, makeNode("scEdmsLegacy", getInfo("SchemaContext.scEdmsLegacy.isUse") == "Y" ? "True" : "False"));
    $.extend(forminfoext, makeNode("scPubOpenDoc", getInfo("SchemaContext.scPubOpenDoc.isUse") == "Y" ? "True" : "False"));
    $.extend(forminfoext, makeNode("scRecordDocOpen", getInfo("SchemaContext.scRecordDocOpen.isUse") == "Y" ? "True" : "False"));
   
    var sdocinfo = {};
    
    $.extend(sdocinfo, makeNode("DocNo", (document.getElementById("DocNo") == undefined) ? '' : document.getElementById("DocNo").value));
    $.extend(sdocinfo, makeNode("ReceiveNo", (document.getElementById("ReceiveNo") == undefined) ? '' : getReceiveNo())); 
    $.extend(sdocinfo, makeNode("dpdsn", getInfo("AppInfo.dpdsn"))); 
    $.extend(sdocinfo, makeNode("DocClassID", (document.getElementById("DocClassID") == undefined) ? '' : document.getElementById("DocClassID").value));
    $.extend(sdocinfo, makeNode("DocClassName", (document.getElementById("DocClassName") == undefined) ? '' : document.getElementById("DocClassName").value));
    $.extend(sdocinfo, makeNode("SaveTerm", (document.getElementById("SaveTerm") == undefined) ? '' : document.getElementById("SaveTerm").value));
    $.extend(sdocinfo, makeNode("AppliedYear", (document.getElementById("AppliedDate") == undefined) ? '' : getFiscalYear(document.getElementById("AppliedDate").value)));
    $.extend(sdocinfo, makeNode("AppliedDate", (document.getElementById("AppliedDate") == undefined) ? '' : document.getElementById("AppliedDate").value));
    $.extend(sdocinfo, makeNode("DocLevel", (document.getElementById("DocLevel") == undefined) ? '' : document.getElementById("DocLevel").value));
    $.extend(sdocinfo, makeNode("IsPublic", (document.getElementById("IsPublic") == undefined) ? '' : ((document.getElementById("IsPublic").value == mobile_comm_getDic("lbl_apv_open")) ? 'Y' : 'N')));
    $.extend(sdocinfo, makeNode("deptcode", getInfo("AppInfo.dpid")));
    $.extend(sdocinfo, makeNode("deptpath", getInfo("AppInfo.grfullname")));
    
    $.extend(sdocinfo, makeNode("AttachFile", ""));
    
    $.extend(forminfoext, {"DocInfo" : sdocinfo});

    $.extend(forminfoext, makeNode("JFID", getJFID()));			//담당자처리
    $.extend(forminfoext, makeNode("ChargeOU", getChargeOU()));
    $.extend(forminfoext, makeNode("ChargePerson", getChargePerson()));
    $.extend(forminfoext, makeNode("rejectedto", (getInfo("SchemaContext.scRJTO.isUse") == "Y" ? 'true' : 'false')));
    $.extend(forminfoext, makeNode("IsLegacy", (getInfo("SchemaContext.scLegacy.isUse") == "Y" ? getInfo("SchemaContext.scLegacy.value") : "")));
    
    $.extend(forminfoext, makeNode("entcode", (document.getElementById("EntCode") == undefined) ? getInfo("FormInstanceInfo.EntCode") : document.getElementById("EntCode").value));
    $.extend(forminfoext, makeNode("entname", (document.getElementById("EntName") == undefined) ? getInfo("FormInstanceInfo.EntName") : document.getElementById("EntName").value));
    $.extend(forminfoext, makeNode("docnotype", getInfo("SchemaContext.scDNum.value")));
    $.extend(forminfoext, makeNode("ConsultOK", (getInfo("SchemaContext.scConsultOK.isUse") == "Y" ? 'true' : 'false')));
    $.extend(forminfoext, makeNode("IsSubReturn", (getInfo("SchemaContext.scDCooReturn.isUse") == "Y" ? 'true' : 'false')));
    $.extend(forminfoext, makeNode("IsDeputy", (gDeputyType == "T" ? 'true' : 'false')));
    
    $.extend(forminfoext, makeNode("IsReUse", getInfo("Request.reuse")));
    $.extend(forminfoext, makeNode("scDocBoxRE", getInfo("SchemaContext.scDocBoxRE.isUse")));
    $.extend(forminfoext, makeNode("nCommitteeCount", "2"));
    
    $.extend(forminfoext, makeNode("IsReserved", "False"));		/* 예약 비사용 (document.getElementById("chk_reserved").checked == true) ? "True" : "False"));*/		//예약여부
    $.extend(forminfoext, makeNode("scASSBox", getInfo("SchemaContext.scASSBox.isUse")));			//개인합의 부서함저장
    $.extend(forminfoext, makeNode("scPreDocNum", getInfo("SchemaContext.scPreDocNum.isUse")));			//문서번호선발번
    $.extend(forminfoext, makeNode("scDistDocNum", getInfo("SchemaContext.scDistDocNum.isUse")));		//수신처 문서번호 발번
    $.extend(forminfoext, makeNode("scBatchPub", getInfo("SchemaContext.scBatchPub.isUse")));			//일괄배포 사용

    //문서번호발번정규식추가 2019.08.26
    $.extend(forminfoext, makeNode("scDNumExt", (getInfo("SchemaContext.scDNumExt.isUse")=="Y")?getInfo("SchemaContext.scDNumExt.value"):''));
    $.extend(forminfoext, makeNode("RuleItemInfo", (document.getElementById("RuleItemInfo") == undefined) ? '' : document.getElementById("RuleItemInfo").value));
    // 다안기안 옵션 사용 여부 추가
    $.extend(forminfoext, makeNode("IsUseMultiEdit", getInfo('ExtInfo.UseMultiEditYN')));
    // 문서유통 옵션 추가
    $.extend(forminfoext, makeNode("IsUseWebHWPEditYN", getInfo('ExtInfo.UseWebHWPEditYN')));
    $.extend(forminfoext, makeNode("scDistribution", getInfo("SchemaContext.scDistribution.isUse")));
    $.extend(forminfoext, makeNode("IsGovMulti", isGovMulti()));
    $.extend(forminfoext, makeNode("SubTable1", getInfo('ExtInfo.SubTable1'))); 
    $.extend(forminfoext, makeNode("MainTable", getInfo('ExtInfo.MainTable'))); 
    return forminfoext;
}

function getJFID() {
    var _return = "";
	if($("#RuleChargeJob").val()){ // 전결규정에서 변경한 담당업무 정보
		_return = $("#RuleChargeJob").val();
	} else if (getInfo("SchemaContext.scChgr.isUse") == "Y") {
        _return = getInfo("SchemaContext.scChgr.value");
    } else if (getInfo("SchemaContext.scChgrEnt.isUse") == "Y") {
        if (getInfo("SchemaContext.scChgrEnt.value") != "") {
            var sEtId = (document.getElementById("EntCode") == undefined) ? getInfo("FormInstanceInfo.EntCode") : document.getElementById("EntCode").value;            
            var oChgrEntV = $.parseJSON(getInfo("SchemaContext.scChgrEnt.value"));
            if ($$(oChgrEntV).attr("ENT_" + sEtId) != undefined) {
                _return = $$(oChgrEntV).attr("ENT_" + sEtId);
            }
        }
    } else if (getInfo("SchemaContext.scChgrReg.isUse") == "Y") {
        if (getInfo("SchemaContext.scChgrReg.value") != "") {
        	var oChgrRegV = $.parseJSON(getInfo("SchemaContext.scChgrReg.value"));
            if ($$(oChgrRegV).attr("REG_" + getInfo("AppInfo.regionid")) != undefined) {
                _return = $$(oChgrRegV).attr("REG_" + getInfo("AppInfo.regionid"));
            }
        }
    }

    return _return;
}

function getChargeOU() {
    var _return = "";
    if (getInfo("SchemaContext.scChgrOU.isUse") == "Y") {
		_return = chkAbsentGroup(getInfo("SchemaContext.scChgrOU.value"));
    	if (_return.indexOf('@@@') > -1) {
    		aChrgOU = _return.split('@@@');
    		_return = aChrgOU[0];
    		if (getInfo('Request.templatemode') == 'Write') alert(aChrgOU[1]);
    	}
    } else if (getInfo("SchemaContext.scChgrOUEnt.isUse") == "Y") {
        if (getInfo("SchemaContext.scChgrOUEnt.value") != "") {
            var sEtId = (document.getElementById("EntCode") == undefined) ? getInfo("FormInstanceInfo.EntCode") : document.getElementById("EntCode").value;
            var oChgrOUEntV = $.parseJSON(getInfo("SchemaContext.scChgrOUEnt.value"));
            if ($$(oChgrOUEntV).find("ENT_" + sEtId + " > item").length > 0) {
            	$$(oChgrOUEntV).find("ENT_" + sEtId + ">item").concat().each(function (i, element) {
            		if (i > 0) _return += "^";
            		_return = $$(element).attr("AN") + "@" + $$(element).attr("DN");
            	});
            }
            
        }
    } else if (getInfo("SchemaContext.scChgrOUReg.isUse") == "Y") {
        if (getInfo("SchemaContext.scChgrOUReg.value") != "") {
        	var oChgrOURegV = $.parseJSON(getInfo("SchemaContext.scChgrOUReg.value"));
            if ($(oChgrOURegV).find("R > REG_" + getInfo("AppInfo.regionid") + " > items > item").length > 0) {
                $(oChgrOURegV).find("R > REG_" + getInfo("AppInfo.regionid") + " > items > item").each(function (i, element) {
                    if (i > 0) _return += "^";
                    _return += $(element).find("AN").text() + "@" + $(element).find("DN").text();
                });
            }
        }
    }
    return _return;
}
function chkAbsentGroup(scGroups) {
	var resultGroup = "";
	var aResultGroup = []; //사용부서
	var aExceptGroup = []; //제외부서
	var aGroup = scGroups.split("^"); //부서
	var aGroupInfo = []; //부서정보
	
	//담당부서 객체배열 생성
	aGroup.forEach(function(sGroup) {
		var oInfo = {
				"GroupCode" : sGroup.split("@")[0],
				"GroupMultiName" : sGroup.split("@")[1]
		};
		aGroupInfo.push(oInfo);
	});
	
	if (aGroupInfo.length > 0) {
		var existGroups = chkAbsentGroupCall(aGroupInfo.map(g => g.GroupCode).join(';'));
		var aChkGroupCode = existGroups.map(g => g.GroupCode);
	    		
		$(aGroupInfo).each(function (idx, oInfo) {
			if (aChkGroupCode.includes(oInfo.GroupCode)) {
				var sGroup = oInfo.GroupCode + "@" + oInfo.GroupMultiName;
				aResultGroup.push(sGroup);
				return true;
			}
			aExceptGroup.push(mobile_comm_getDicInfo(oInfo.GroupMultiName));
		});
		
		resultGroup = aResultGroup.join('^');
			
		//제외부서 alert
		if(aExceptGroup.length > 0) {
			var msg = mobile_comm_getDic("msg_apv_chkAbsentGroup") + '\n\n';
			msg += mobile_comm_getDic("msg_apv_absentGroup") + " : " + aExceptGroup.join(', ');
			resultGroup += "@@@" + msg;
		}
	}
	
	return resultGroup;
}
// pGroups : existGroupCode;noneGroupcode;existGroupCode
// return : [{GroupCode:"existGroupCode..",MultiDisplayName:"name..."},{GroupCode:"existGroupCode..",MultiDisplayName:"name..."}]
function chkAbsentGroupCall(pGroups) {
	var rtnGroups = [];
	
	if(pGroups){
		$.ajax({
			type : "POST",
			url : "/approval/apvline/checkAbsentGroup.do",
			async : false,
			data : {
				"groups" : pGroups
			},
			success : function(data) {
				rtnGroups = data.list;
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("/approval/apvline/checkAbsentGroup.do", response, status, error);
			}
		});
	}
	
	return rtnGroups;
}

function getChargePerson() {
    var _return = "";
    if (getInfo("SchemaContext.scChgrPerson.isUse") == "Y") {
        var chargePersonValue = getInfo("SchemaContext.scChgrPerson.value");
        var retChgrPerson = '';
        
        if ('' != chargePersonValue) {
            var oChargePerson = $.parseJSON(chargePersonValue.substring(chargePersonValue.indexOf('<items>')));

            if ($(oChargePerson).find('items > item').length > 0) {
                $(oChargePerson).find('items > item').each(function (i, element) {
                    if (i > 0) {
                        retChgrPerson += "^";
                    }

                    retChgrPerson += $(element).find('AN').text()
                        + '@' + $(element).find('DN').text()
                        + '@' + $(element).find('GR_Code').text()
                    ;
                });
            }
        }

        _return = retChgrPerson;
    }
    return _return;
}

function getFiscalYear(sApplyDate) {
    var sFiscalYear = "";
    sFiscalYear = sApplyDate.substring(0, 4)
    return sFiscalYear;
}

function getHasReceiveno() {
    var sRtn = "false";
    //신청서-담당업무확정에 대해서는 수신대장 보관하지 않음
    if (getInfo("SchemaContext.scChgr.isUse") == "Y") { sRtn = "false"; } else { sRtn = "true"; }
    return sRtn;
}

//후결여부 체크
//최종결재여부 체크
function getIsLast() {
  var sRtn = "";
  var m_oApvList = $.parseJSON(document.getElementById("APVLIST").value);

  var oPendingSteps = $$(m_oApvList).find("steps > division > step > ou > person > taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][status='pending'],steps > division > step > ou > person > taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][status='reserved']");
  var oinActiveSteps = $$(m_oApvList).find("steps > division > step > ou > person > taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][status='inactive']");
  if ((oPendingSteps.length == 1) && (oinActiveSteps.length == 0)) {
      sRtn = "true";
  } else {
      sRtn = "false";
  }
  if (sRtn == "false") {
      switch (getInfo("Request.mode")) {
          case "PCONSULT":
              if (getInfo("Request.mode") == "PCONSULT" && getInfo("Request.subkind") == "T004" && document.getElementById("ACTIONINDEX").value == 'REJECT') { //합의 반려 가능
                  sRtn = "true";
              }
              break;
          default:
              if (document.getElementById("ACTIONINDEX").value == 'REJECT') { //결재 반려 가능
                  sRtn = "true";
              }
              break;
      }
  }
  return sRtn;
}

//양식 내역 보내기
function getInfoBodyContext() {
    var formJsonObj = getFormJSON();
    
	// FileName encoding
	var sFileInfo = formJsonObj.FormData.AttachFileInfo;
	if(sFileInfo){
		var oFileInfo = $.parseJSON(sFileInfo);
		if(oFileInfo.FileInfos){
			$.each(oFileInfo.FileInfos, function(i,item){
				if(item.FileName) item.FileName = encodeURIComponent(item.FileName);
			});
			formJsonObj.FormData.AttachFileInfo = JSON.stringify(oFileInfo);
		}
	}
	
    if (!formJsonObj.hasOwnProperty("BodyContext") || $.isEmptyObject(formJsonObj.BodyContext)) {
    	$.extend(formJsonObj, makeNode("BodyContext", getInfo("BodyContext")));
    }
    return formJsonObj;
}

//다안기안 + 문서유통 문서 여부
function isGovMulti(obj) {
	return ((getInfo("ExtInfo.UseWebHWPEditYN") == "Y" || getInfo("ExtInfo.UseEditYN") == "Y") && getInfo("ExtInfo.UseMultiEditYN") == "Y" && getInfo("SchemaContext.scDistribution.isUse") == "Y") ? true : false;
}

//접수대기문서정보
function displayDocInfo() {
	if(document.getElementById("docInfoTB") != null) {
		if(document.getElementById("docInfoTB").style.display == "") {
			document.getElementById("docInfoTB").style.display = "none";
		}else {
			document.getElementById("docInfoTB").style.display = "";
		}
	}
}

/* =================== FormMenu.js END =================== */






/* =================== FormBody.js START =================== */

//컬럼형태로 저장되는 값들에 대한 처리, dField, smField, stField
function getFormJSON() { 
    //placeholder에 대한 처리
    $("input").attr("placeholder", "");
    var returnObj = {};
    var bodyContextObj = {};
    
    if(getInfo("Request.isLegacy") == "Y" && getInfo("BodyContext.HTMLBody") != undefined && getInfo("BodyContext.HTMLBody") != "")
    	bodyContextObj = { "BodyContext" : JSON.parse(getInfo("BodyContext")) };
    else
    	bodyContextObj = getBodyContext();
    
    var unFiltered = document.getElementsByTagName("*");
    for (var i = 0; i < unFiltered.length; i++) {
        if (unFiltered[i].getAttribute("data-type") == "dField") {
        	$.extend(bodyContextObj, makeNode(unFiltered[i].getAttribute("id"), unFiltered[i].value));
        }
    }
    var subJsonObj = {};
    if (getInfo("SubTableInfo.MainTable") != "" && getInfo("SubTableInfo.MainTable") != undefined) {

        if (getInfo("Request.mode") == "DRAFT" && m_sReqMode == "TEMPSAVE" && getInfo("Request.templatemode") == "Read") { // 회수일 경우 이전 값에서 가져 오기 
            subJsonObj = formJson.BodyData;
        } else if (getInfo("Request.templatemode") == "Read") {		// [2015-01-20 add] 읽기모드에서는 bodyinfo를 만들지 않도록
            subJsonObj = {};
        } else {
        	subJsonObj["BodyData"] = {};
            /*try {
            	subJsonObj["BodyData"]["MainTable"] = {};
            	
                var unFiltered = document.getElementsByTagName("*");
                for (i = 0; i < unFiltered.length; i++) {
                    if (unFiltered[i].getAttribute("data-type") == "smField") {
                    	subJsonObj["BodyData"]["MainTable"] = $.extend(subJsonObj["BodyData"]["MainTable"], makeNodeByTypeForDB($(unFiltered[i]), "smField"));
                    }
                }
                if (getInfo("SubTableInfo.SubTable1") != "" && getInfo("SubTableInfo.SubTable1") != undefined) {
                	subJsonObj["BodyData"] = $.extend(subJsonObj["BodyData"], getMultiRowFieldsForDB("SubTable1", "stField"));
                }
                if (getInfo("SubTableInfo.SubTable2") != "" && getInfo("SubTableInfo.SubTable2") != undefined) {
                	subJsonObj["BodyData"] = $.extend(subJsonObj["BodyData"], getMultiRowFieldsForDB("SubTable2", "stField"));
                }
                if (getInfo("SubTableInfo.SubTable3") != "" && getInfo("SubTableInfo.SubTable3") != undefined) {
                	subJsonObj["BodyData"] = $.extend(subJsonObj["BodyData"], getMultiRowFieldsForDB("SubTable3", "stField"));
                }
                if (getInfo("SubTableInfo.SubTable4") != "" && getInfo("SubTableInfo.SubTable4") != undefined) {
                	subJsonObj["BodyData"] = $.extend(subJsonObj["BodyData"], getMultiRowFieldsForDB("SubTable4", "stField"));
                }
            } catch (e) {
                var a = e;
            }*/
        }
    }
    returnObj["FormData"] = $.extend(bodyContextObj, subJsonObj);
    
    return returnObj;
}

function getChangeFormJSON() {
    var jsonObj = {};
    
    var sBodyContext = getBodyContext();
    /*
    if (JSON.stringify(makeNode("BodyContext", $.parseJSON(getInfo("BodyContext")))) != JSON.stringify(sBodyContext))
    	jsonObj = sBodyContext;
    */
    
    if(JSON.stringify(sBodyContext) != "{}") {
        $.each($.parseJSON(getInfo("BodyContext")), function(key, value) {
        	if(key.indexOf("tbContentElement") > -1) {
        		if(sBodyContext.BodyContext[key] != orgBodyContext.BodyContext[key]) {
        			jsonObj = sBodyContext;
                    return false;
        		}
        	} else if(sBodyContext.BodyContext.hasOwnProperty(key)){
                if(JSON.stringify(sBodyContext.BodyContext[key]) != JSON.stringify(value)){
                    jsonObj = sBodyContext;
                    return false;
                }
            }
        });
    }
    
    var l_editor = "#editor";
    if (openMode == "P") l_editor = CFN_GetCtrlById("editor");
    $(l_editor).find("input[data-type=dField], textarea[data-type=dField], checkbox[data-type=dField]", "radio[data-type=dField]").each(function (i, fld) {
        if ($(fld).attr("id") == "AttachFileInfo") {
        	
        	var isFileModified = false;
            var oldFileInfo = "";
            var newFileInfo = "";
            
            oldFileInfo = (getInfo("FormInstanceInfo."+$(fld).attr("id")) == undefined || getInfo("FormInstanceInfo."+$(fld).attr("id")) == "") ? "" : $.parseJSON(getInfo("FormInstanceInfo."+$(fld).attr("id")));
            newFileInfo = ($(fld).val() == "") ? "" : $.parseJSON($(fld).val());
            
            if(typeof(oldFileInfo) == "object" && typeof(newFileInfo) == "object" ){
            	var arrOldNames = new Array();
            	var arrNewNames = new Array();
            	
            	arrOldNames = $$(oldFileInfo).find("FileInfos").concat().attr("SavedName");
            	arrNewNames = $$(newFileInfo).find("FileInfos").concat().attr("SavedName");
            	
            	if(typeof arrOldNames.length == "number" && arrNewNames != undefined){
	            	if(arrOldNames.length != arrNewNames.length)
	            		isFileModified = true;
	            	else{
	            		isFileModified = !arrayCompare(arrOldNames, arrNewNames);
	            	}
            	}else{
            		isFileModified = true;
            	}
            }
            	
            if(typeof(oldFileInfo) != typeof(newFileInfo))
            	isFileModified = true;
            	
            if (isFileModified) {
            	var fldVal = $(fld).val();
                $.extend(jsonObj, makeNode($(fld).attr("id"), fldVal));
            }
        } else {
            if ($(fld).val() != getInfo("FormInstanceInfo."+$(fld).attr("id")) && !($(fld).val() == "" && getInfo("FormInstanceInfo."+$(fld).attr("id")) ==undefined)) {
            	var fldVal = $(fld).val();
                $.extend(jsonObj, makeNode($(fld).attr("id"), fldVal));
            }
        }
    });

    $(l_editor).find("select[data-type=dField]").each(function (i, fld) {
        if ($(fld).val() != getInfo("FormInstanceInfo."+$(fld).attr("id"))) {
            if ($(fld).attr("tag") == "select") {
                $.extend(jsonObj, getSelRadio($(fld).attr("name")));
            } else {
            	$.extend(jsonObj, makeNode($(fld).attr("id"), $(fld).val()));
            }
        }
    });

    //body_context & specfic fields	
    //receive no process//
    if ((getInfo("Request.mode") == "REDRAFT") && (m_oFormMenu.getHasReceiveno() == "true")) {
        $.extend(jsonObj, makeNode("ReceiveNo", getInfo("FormInstanceInfo.ReceiveNo")));
        if(jsonObj.hasOwnProperty("InitiatorUnitID"))
        	$.extend(jsonObj, makeNode("InitiatorUnitID", getInfo("FormInstanceInfo.InitiatorUnitID")));
    }

    //smField, stField 처리 추가
    var subJsonObj = {};
    if (getInfo("SubTableInfo.MainTable") != "") {
        if (getInfo("Request.mode") == "DRAFT" && m_sReqMode == "TEMPSAVE" && getInfo("Request.templatemode") == "Read")// 회수일 경우 이전 값에서 가져 오기
        {
        	subJsonObj = formJson.BodyData; 
        }
        else if (getInfo("Request.templatemode") == "Read") {
        	subJsonObj = {};
        }
        else {
        	subJsonObj = {};
            /*try {
            	subJsonObj["BodyData"]["MainTable"] = {};
            	
                var unFiltered = document.getElementsByTagName("*");
                for (i = 0; i < unFiltered.length; i++) {
                    if (unFiltered[i].getAttribute("data-type") == "smField") {
                    	subJsonObj["BodyData"]["MainTable"] = $.extend(subJsonObj["BodyData"]["MainTable"], makeNodeByTypeForDB($(unFiltered[i]), "smField"));
                    }
                }
                ssubJsonObj += "</maintable>";
                if (getInfo("SubTableInfo.SubTable1") != "" && getInfo("SubTableInfo.SubTable1") != undefined) {
                	subJsonObj["BodyData"] = $.extend(subJsonObj["BodyData"], getMultiRowFieldsForDB("SubTable1", "stField"));
                }
                if (getInfo("SubTableInfo.SubTable2") != "" && getInfo("SubTableInfo.SubTable2") != undefined) {
                	subJsonObj["BodyData"] = $.extend(subJsonObj["BodyData"], getMultiRowFieldsForDB("SubTable2", "stField"));
                }
                if (getInfo("SubTableInfo.SubTable3") != "" && getInfo("SubTableInfo.SubTable3") != undefined) {
                	subJsonObj["BodyData"] = $.extend(subJsonObj["BodyData"], getMultiRowFieldsForDB("SubTable3", "stField"));
                }
                if (getInfo("SubTableInfo.SubTable4") != "" && getInfo("SubTableInfo.SubTable4") != undefined) {
                	subJsonObj["BodyData"] = $.extend(subJsonObj["BodyData"], getMultiRowFieldsForDB("SubTable4", "stField"));
                }
                
                if($.isEmptyObject(subJsonObj.BodyData.MainTable)){
                	subJsonObj = {};
                }
            } catch (e) {
                var a = e;
            }*/
        }
    }

    var _return = {};
    $.extend(jsonObj, subJsonObj);
    if (!$.isEmptyObject(jsonObj) || !$.isEmptyObject(subJsonObj)) {
        _return = $.extend({"LastModifierID" : getInfo("AppInfo.usid")}, {"FormData" : jsonObj });
    } else {
    	_return = {};
    }

    //apst 확인
    var sApvlist = getApvList();
    if ((!(getInfo("ApprovalLine").replace("\r\n", "") == JSON.stringify(sApvlist))) || strApvLineYN == "Y") {
    	$.extend(_return, {"ChangeApprovalLine" : document.getElementById("APVLIST").value});
    }

    return _return
}

//에디터 타입 참조방식 변경 : KJW : 2014-04-23 : XFROM PRJ.
function getBodyContext() {
    var ret = {};

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
        ret = {};
    }
    else {
        var sBodyContext = makeBodyContext();
        
        var editorInlineImages = {};
        var editorBackgroundImage = {};
        if( getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode")  == "TEMPSAVE" || getInfo("Request.editmode") == "Y"){
	    	if(sBodyContext.BodyContext.tbContentElement != undefined && getEditorImages() != ""){
	    		editorInlineImages["EditorInlineImages"] = getEditorImages();
	    	}

            if(sBodyContext.BodyContext.tbContentElement != undefined && getEditorBackgroundImage() != ""){
                editorBackgroundImage["EditorBackgroundImage"] = getEditorBackgroundImage();
            }
	        
	        var sBodyContext = makeBodyContext();
	        var editorInlineImages = {};
		        
		   if( getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode")  == "TEMPSAVE" || getInfo("Request.editmode") == "Y"){
			   	if(sBodyContext.BodyContext.tbContentElement != undefined && getEditorImages() != ""){
			   		editorInlineImages["EditorInlineImages"] = getEditorImages();
			   	}
		   }
	       sBodyContext = $.extend(sBodyContext,editorInlineImages);
	       sBodyContext = $.extend(sBodyContext,editorBackgroundImage);
	       
	       ret = sBodyContext;
        }
        
        ret = sBodyContext;
    }

    return ret;
}

function initOnloadformedit() {
    initialize();
}

function initialize() {

	/* FormCommonField.html 읽음 처리*/
	if(getInfo("Request.mode") != "DRAFT" && getInfo("Request.mode") != "TEMPSAVE"){
		$("#InitiatorName").attr("data-model", "FormInstanceInfo.InitiatorName");
		$("#InitiatorID").attr("data-model", "FormInstanceInfo.InitiatorID");
		$("#InitiatorUnitName").attr("data-model", "FormInstanceInfo.InitiatorUnitName");
		$("#InitiatorUnitID").attr("data-model", "FormInstanceInfo.InitiatorUnitID");
		
		$("#EntCode").attr("data-model", "FormInstanceInfo.EntCode");
		$("#EntName").attr("data-model", "FormInstanceInfo.EntName");
	}
	
	/* 쓰기모드일 경우, 첨부파일 목록 숨기기 */
	if(getInfo("Request.templatemode") == "Write"){
		$("#AttFileInfoList").hide();
	}

    //초기화
    initForm();

    //2012차기버전작업 : 결재선 함수 호출이 중복으로 호출 하여 수정함.
    if (getInfo("Request.mode") == "DRAFT"
            || getInfo("Request.mode") == "TEMPSAVE"
            || ((getInfo("Request.loct") == "APPROVAL" || getInfo("Request.loct") == "REDRAFT") && getInfo("Request.mode") == "REDRAFT")
            || (getInfo("Request.loct") == "REDRAFT" && getInfo("Request.mode") == "SUBREDRAFT") //부서협조일경우 수신부서에서 열었을때 접수사용으로 되어 있으면 결재선을 그려 줘야함
        ) {

		// 모바일은 편집모드일때도 결재선을 다시조회하기 때문에 조건 제거
		// && (getInfo("Request.editmode") != 'Y' || (getInfo("Request.editmode") == 'Y' && getInfo("Request.reuse") == "Y"))
        if (getInfo("Request.reuse") != "P"
            && openMode != "W") {

            //설정된 결재선 가져오기
            setDomainData();
        }
        else {
            //결재선 그리기
            initApvList();
        }
    } else {
        initApvList();
    }

	/* 다안기안 사용 시 조회 처리 */
	initMultiEditInfo();
}

//다안기안 사용 시 조회 처리
function initMultiEditInfo() {
	if(getInfo('ExtInfo.UseMultiEditYN') == "Y"){
		if (getInfo("Request.templatemode") == "Read") {
	        if (JSON.stringify(formJson.BodyData) != "{}") {
	            XFORM.multirow.load(JSON.stringify(formJson.BodyData.SubTable1), 'json', '#SubTable1', 'R');            
	        } else {
	            XFORM.multirow.load('', 'json', '#SubTable1', 'R');
	        }
		} else {
			// 발신명의 세팅
			if (isGovMulti()) {
				// 문서유통 + 다안기안
				setSenderMaster();
			} else {
	    		getSenderList();
	        }
	        
	        if (JSON.stringify(formJson.BodyContext) != "{}") {
	            XFORM.multirow.load(JSON.stringify(formJson.BodyData.SubTable1), 'json', '#SubTable1', 'W');            

				$(formJson.BodyData.SubTable1).each(function(idx, item){
					if(formJson.BodyData.SubTable1[idx] != null && formJson.BodyData.SubTable1[idx].MULTI_ATTACH_FILE != ""){
						$('#SubTable1 .multi-row').find('[name=MULTI_ATTACH_FILE]').eq(idx).val(JSON.stringify(formJson.BodyData.SubTable1[idx].MULTI_ATTACH_FILE));
					}
				});
	        } else {
	            XFORM.multirow.load('', 'json', '#SubTable1', 'W', { minLength: 1 });
	        }
		}
		
	 	if (formJson.Request.gloct != "DRAFT") {
	     	if(formJson.BodyData.SubTable1 != null){
	     		$(formJson.BodyData.SubTable1).each(function(i, item){
	     			if(i != 0){
	     				addTabClass(item.MULTI_DOC_TYPE, 'init');
	     			}
	     		});
	     	}
	     }
		
	 	if (isGovMulti()) {
			const rowSeq = mobile_comm_getQueryString('rowSeq') != '' && mobile_comm_getQueryString('rowSeq') != 'undefined' ? mobile_comm_getQueryString('rowSeq') : '';
			
			if (rowSeq != '') {
				$(formJson.BodyData.SubTable1).each(function(idx, item){
	 		    	var view = false;
	 		    	
					// 다안기안인 경우 여러 안에 같은 배포처가 들어가있을수 있으므로 선택했던 안만 볼 수 있도록 추가
					if (item != null && item.MULTI_ROWSEQ != null && rowSeq == item.MULTI_ROWSEQ){
	 					view = true;
	 				}
	 				
	 				if(!view){
	 					$("#writeTab li[idx=" + (idx+1) + "]").remove();
	 				}
	 			});
			}
 			changeTab($("#writeTab li:first").attr("idx"),"init"); // 최초 로드시 1안으로 선택
		} else if(getInfo('ProcessInfo.SubKind') == "R"){ // 수신부서 화면표시 (수신지정된 안건만 표시함)
			$(formJson.BodyData.SubTable1).each(function(idx, item){
		    	var view = false;
		    	
				if(formJson.BodyData.SubTable1[idx] != null && formJson.BodyData.SubTable1[idx].MULTI_RECEIPTLIST != null && formJson.BodyData.SubTable1[idx].MULTI_RECEIPTLIST != ""){
					var RecList = formJson.BodyData.SubTable1[idx].MULTI_RECEIPTLIST.split(';');
					for(var i = 0; i < RecList.length; i++){
						if(RecList[i].split('|')[0] == getInfo('AppInfo.dpid')){
							view = true;
							break;
						}
					}
				}
				
				if(!view){
					$("#writeTab li[idx=" + (idx+1) + "]").remove();
				} else {
			    	changeTab((idx+1),"init");
				}
			});
	    } else {
	    	// 기록물 다안문항 권한 체크
			const govRecordRowSeq = $.trim(getInfo("Request.govrecordrowseq"));
    		if (govRecordRowSeq != '') {
				document.querySelectorAll('#writeTab > li').forEach((li, idx) => { 
					if ((idx + 1) != Number(govRecordRowSeq)) li.style.display = 'none';
					else li.classList = '';
				});
				if (!$('#writeTab > li:visible').hasClass('on')) {
					changeTab($('#writeTab > li:visible').attr('idx'));
				}
			} else {
 	    		changeTab(1, "init");
 	    	}
	    }
     
	    if(!isUseHWPEditor() && !isGovMulti()) {
	    	$("#tbLinkInfo").find("tr[id$='_Multi']").show();
	    }
        
        // 다안기안 + 문서유통시에는 다안기안용 연관문서 정보 보여준다.
        if (isGovMulti()) {
			$("#tbLinkInfo").find("tr[id='DocLinkInfoList_Multi']").show();
			if (getInfo("Request.templatemode") == "Read") {
				$("#tbLinkInfo").find("tr[id='AttFileInfoList_Multi']").show();
			}
			
			// 문서유통 메뉴에서 열었을때는 탭을 보여줄 필요가 없다.
			if (CFN_GetQueryString('rowSeq') != '' && CFN_GetQueryString('rowSeq') != 'undefined') {
				$(".tabLine").hide();
			}
		}
	     
	    formDisplaySetSubjectnfoMulti();	// 제목 조회
	    formDisplaySetReceiveInfoMulti();	// 수신처 조회
	    formDisplaySetDocLinkInfoMulti();	// 연결문서 조회
	    // 문서유통 조회
        if(isGovMulti()){
            formDisplaySetReceiveInfoMulti();	// 수신처 조회
        }
        // 기록물철 조회
        if(getInfo("SchemaContext.scRecordDocOpen.isUse") =="Y"){
            formDisplaySetRecordInfoMulti();	
        }
        
        // 문서유통 다안기안 웹에디터 사용
        if ( isGovMulti() && getInfo("ExtInfo.UseEditYN") == "Y"){
        	// 수신주소
        	formDisplaySetDocRecLineList_Multi();
        	// 제목
        	formDisplaySetSubjectList_Multi(); 
        	// 전화번호
        	formDisplaySetPhoneNumList_Multi();
        	// 팩스번호
        	formDisplaySetFaxNumList_Multi();
        	// 홈페이지
        	formDisplaySetHomePageList_Multi()
        	// 이메일
        	formDisplaySetEmailList_Multi();
        	// 우편번호
        	formDisplaySetZipCodeList_Multi();
        	// 주소
        	formDisplaySetAddressList_Multi();
        }
	     
	    if($$(m_oApvList).find("steps>division[processID=" + getInfo("ProcessInfo.ProcessID") + "]").attr("divisiontype") == "receive") {
	    	$("#tbLinkInfo").find("tr[id*='List']:not([id$='_Multi']), tr[id='ReceiveLine_Multi']").hide();
	    } else {
	    	$("#tbLinkInfo").find("tr[id*='List']:not([id$='_Multi'])").hide();
	    }
		
	    $("#AttFileInfoList_Multi").remove();
		$('#tblFormSubject').hide();
	} else {
		$("#DocLinkInfoList").show();
	}
}

function initForm() {
    initFields();

    try { 
        // 연결문서 조회
		docLinks.init();
    } catch (e) { mobile_comm_log(e); }
}

//에디터 타입 참조방식 변경 : KJW : 2014-04-23 : XFROM PRJ.
//읽기 / 쓰기 통합으로 수정
function initFields(szBody) {
  //공통 처리 상단 시작
  if (typeof window.setLabel == "function") {
      setLabel()
  };

  setFields("dField");
  setFields("cField");

  //기타 필드 채우기
  if (getInfo("Request.templatemode") == "Write" && getInfo("SchemaContext.scCMB.isUse") == "N") {
      setSaveTerm();  //보존년한 create	
      setDocLevel();  // 보안등급 create
      if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") {
          setDocClass();  //문서분류 대입 (2012-04-02 HIW)
      }
  }
  //공통 처리 상단 끝

  //쓰기인 경우 시작
  if (getInfo("Request.templatemode") == "Write") {
	  // 모바일 내 양식명 표시하지 않음
      /*if (getInfo("FormInfo.FormPrefix") != "WF_FORM_LEAVE") {
          document.getElementById("headname").innerHTML = getInfo("FormInfo.FormName"); //initheadname(getInfo("FormInfo.FormName"), false);
      }*/

	  if(getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") {
	      document.getElementById("AppliedDate").value = getInfo("AppInfo.svdt"); 

	      if (typeof setFormInfoDraft === 'function') {
	          setFormInfoDraft();
	      }

	      if (getInfo("BodyContext") != undefined) {
	          setBodyContext(getInfo("BodyContext"));
	      } else {
	          setBodyContext(getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8"));
	      }
	  }
  }//쓰기인 경우 끝
  //읽기인 경우 시작
  else {
      settFields("tField");

      $("#Subject").html(mobile_approval_replaceCharacter(getInfo("FormInstanceInfo.Subject")));
      $("#headname").html(mobile_comm_getDicInfo(getInfo("FormInfo.FormName")));
  }//읽기인 경우 끝

}

function setFields(Fields) {
    //debugger;
    var fld;
    var l_editor = "#editor";
    if (openMode == "P") {
        l_editor = CFN_GetCtrlById("editor");
    }

    //type이 Fields, data-binding="post"인 input, textarea 태그에 대한 처리
    $(l_editor).find("input[data-type='" + Fields + "'], textarea[data-type='" + Fields + "']").filter('*[data-binding="post"]').each(function (i, fld) {

        if ($(fld).attr("data-model") != null) {

            //id -> data-model
            if (getInfo($(fld).attr('id')) != undefined) {
                $(fld).val(getInfo($(fld).attr('id')));
            } else {
                if ((getInfo($(fld).attr("data-model")) != undefined)) {
                    $(fld).val(getInfo($(fld).attr("data-model")));
                } else {
                    $(fld).val('');
                }
            }

        }

        if ($(fld).attr('id') != null) {
            //미확인 일부 양식에서 사용 추측, 확인 후 이동 할 것
        	
            //CommonFields에서 처리
            if ($(fld).attr('id') == 'InitiatorName' && getInfo($(fld).attr('id')) == "") {
                $(fld).val(getInfo($(fld).attr("data-model")));
            }
            if ($(fld).attr('id') == 'InitiatorID' && getInfo($(fld).attr('id')) == "") {
                $(fld).val(getInfo($(fld).attr("data-model")));
            }
        }
    });

}

function settFields(Fields) {

	try {
		var fld;
		var l_editor = "#editor";
		if (openMode == "P") {
			l_editor = CFN_GetCtrlById("editor");
		}

		$(l_editor).find("td[data-type='" + Fields + "'],span[data-type='" + Fields + "']").each(function(i, fld) {

			if ($(fld).attr("data-model") != "") {
				if (getInfo($(fld).attr("id")) != undefined) {
					$(fld).text(getInfo($(fld).attr("id")));
				} else {
					if (getInfo($(fld).attr("data-model")) != undefined) {
						$(fld).text(getInfo($(fld).attr("data-model")));
					}//oFormData에 없는 경우 BODY_CONTEXT에서 가져 오는 구문 추가
					else if (typeof formJson.BodyContext[$(fld).attr("data-model")] != 'undefined') {
						$(fld).text(formJson.BodyContext[$(fld).attr("data-model")]);
					} else {
						$(fld).text('');
					}
				}
			}
		});
	} catch (e) {
		mobile_comm_log(e);
	}

}

//문서등급(보안등급) create
function setDocLevel() {
  // 일반문서, 보안문서
  document.getElementById("DocLevel").options.length = 0;
  makeCBOobject("100", mobile_comm_getDic("DOC_LEVEL_10"), document.getElementById("DocLevel"));
  makeCBOobject("200", mobile_comm_getDic("DOC_LEVEL_20"), document.getElementById("DocLevel"));
  makeCBOobject("300", mobile_comm_getDic("DOC_LEVEL_30"), document.getElementById("DocLevel"));

  try {
      if (getInfo("FormInstanceInfo.DocLevel") != undefined) {
          setDefaultCBOobject(getInfo("FormInstanceInfo.DocLevel"), document.getElementById("DocLevel"));
      }
      else {
      	setDefaultCBOobject(getInfo("ExtInfo.SecurityGrade"), document.getElementById("DocLevel"));
      }
  }
  catch (ex) { mobile_comm_log(ex); }
}

//보존년한 create
function setSaveTerm() {
    document.getElementById("SaveTerm").options.length = 0;
    makeCBOobject("1", mobile_comm_getDic("lbl_apv_year_1"), document.getElementById("SaveTerm")); 			//"1년"
    makeCBOobject("3", mobile_comm_getDic("lbl_apv_year_3"), document.getElementById("SaveTerm")); 			//"3년"
    makeCBOobject("5", mobile_comm_getDic("lbl_apv_year_5"), document.getElementById("SaveTerm")); 			//"5년"
    makeCBOobject("7", mobile_comm_getDic("lbl_apv_year_7"), document.getElementById("SaveTerm")); 			//"7년"
    makeCBOobject("10", mobile_comm_getDic("lbl_apv_year_10"), document.getElementById("SaveTerm"));  		//"10년"
    makeCBOobject("99", mobile_comm_getDic("lbl_apv_permanence"), document.getElementById("SaveTerm"));       //"영구"

    try {
        if (getInfo("FormInstanceInfo.SaveTerm") != undefined)
            setDefaultCBOobject(getInfo("FormInstanceInfo.SaveTerm"), document.getElementById("SaveTerm"));
        else
        	setDefaultCBOobject(getInfo("ExtInfo.PreservPeriod"), document.getElementById("SaveTerm"));
    }
    catch (ex) { mobile_comm_log(ex); }
}

//문서등급 조회
function getDocLevel(szCode) {
	var szName = '';
	
	//일반문서, 보안문서
	switch (szCode) {
	    case "100": szName = mobile_comm_getDic("DOC_LEVEL_10"); break;
	    case "200": szName = mobile_comm_getDic("DOC_LEVEL_20"); break;
	    case "300": szName = mobile_comm_getDic("DOC_LEVEL_30"); break;
	}
	return szName;
}

//보존년한 조회
function getSaveTerm(szCode) {
  var szName = '';

  switch (szCode) {
      case "1":       //1년
          szName = mobile_comm_getDic("lbl_apv_year_1");
          break;
      case "3":       //3년
          szName = mobile_comm_getDic("lbl_apv_year_3");
          break;
      case "5":       //5년
          szName = mobile_comm_getDic("lbl_apv_year_5");
          break;
      case "7":       //7년
          szName = mobile_comm_getDic("lbl_apv_year_7");
          break;
      case "10":      //10년
          szName = mobile_comm_getDic("lbl_apv_year_10");
          break;
      case "99":      //영구
          szName = mobile_comm_getDic("lbl_apv_permanence");
          break;
  }

  return szName;
}

function getFields(Fields) {
    //debugger;
	var fieldObj = {};
    var fld;
    var l_editor = "#editor";
    if (openMode == "P") l_editor = CFN_GetCtrlById("editor");

    $(l_editor).find("*[data-type='" + Fields + "']").each(function (i, fld) {

        var $fld = $(fld);
        $.extend(fieldObj, makeNodeByType($fld, Fields, i));
    });
    

    return fieldObj;
}

// [220119 mod] 함수명 변경 (makeMultiRowXml -> makeMultiRowJson)
function makeMultiRowJson(row, Fields, rowSeq) {
    var $$_sText = $$({});

    row.find("*[data-type='" + Fields + "']").each(function (i, fld) {

        var $fld = $(fld);
        $$_sText.append(makeNodeByType($fld, Fields, rowSeq));

    });

    return $$_sText.json();
}

/*** form data table -> xml ***/
function getMultiRowFields(objName, Fields) {
    var $$_sText = $$({});
    var $rows;
    var iRowSeq = 0;
    if (Fields == null) Fields = "rField";
    //template가 복수인 경우
    var $table = $("#" + objName);
    var multirowTmplCnt = $table.find(".multi-row-template").length;

    //:nth-child(3n+1)
    if (multirowTmplCnt == 1) {
        $rows = $table.find('.multi-row');
        $.each($rows, function () {//
            ++iRowSeq;
            var $row = $(this);
            $$_sText.append(objName,makeMultiRowJson($row, Fields, iRowSeq.toString()));
        });
    } else { //multi-template
        $rows = $table.find('.multi-row').nth(multirowTmplCnt + 'n');
        $.each($rows, function () {//
            ++iRowSeq;
            var $row = $(this);
            var rows = $row.nextAll().andSelf().slice(0, multirowTmplCnt);
            $$_sText.append(objName,makeMultiRowJson(rows, Fields, iRowSeq.toString()));
        });
    }

    return $$_sText.json();
}

function getNodeName(obj) {
    var ret;

    var $name = obj.attr("name");
    var $id = obj.attr("id");
    var $nodeName = obj.attr("data-node-name");

    if (typeof $name != 'undefined' && $name != "") {
        ret = $name;
    }
    else if (typeof $id != 'undefined') {
        ret = $id;
    }
    else if (typeof $nodeName != 'undefined') {
        ret = $nodeName;
    }

    return ret;
}

/*** form data table -> xml -> json***/
function getMultiRowFieldsForDB(objName, Fields) {
    //var sText = "";
    var resultObj = {};
    var $rows;
    var iRowSeq = 0;
    if (Fields == null) Fields = "rField";
    //template가 복수인 경우
    var $table = $("#" + objName);
    var multirowTmplCnt = $table.find(".multi-row-template").length;

    //multirowTmplCnt = multirowTmplCnt / 6;

    //:nth-child(3n+1)
   
    //:nth-child(3n+1)
    resultObj[objName] = new Array;
    
    if (multirowTmplCnt == 1) {
        $rows = $table.find('.multi-row');
        $.each($rows, function () {//
            var $row = $(this);
            var forEachResultObj = {};
            /*sText += "<" + objName + ">";*/
            //resultObj[objName] = {};
            ++iRowSeq;
            /*sText += "<ROWSEQ>" + iRowSeq.toString() + "</ROWSEQ>";
            sText += makeMultiRowJSONForDB($row, Fields, iRowSeq.toString());
            sText += "</" + objName + ">";*/
            forEachResultObj = $.extend(forEachResultObj, {"ROWSEQ" : iRowSeq.toString()});
            forEachResultObj = $.extend(forEachResultObj, makeMultiRowJSONForDB($row, Fields, iRowSeq.toString()));
            
            resultObj[objName].push(forEachResultObj);
        });
    } else { //multi-template
    	var nonRowCnt =  $table.find("tr:not(.multi-row):not(.multi-row-template)").length
    	var spaceCnt = multirowTmplCnt + nonRowCnt + 1;
    	
    	$rows = $table.find('tr:nth-child(' + multirowTmplCnt + 'n+'+ spaceCnt  +' )');
        //$rows = $table.find('.multi-row:nth-child(' + multirowTmplCnt + 'n)'); // Jquery : class 지정 후 nth-child 사용할 경우 class가 먹지 않는 오류로 select 문구 변경
        $.each($rows, function () {//
            var $row = $(this);
            
            var rows = $row.nextAll().andSelf().slice(0, multirowTmplCnt);
            //var rows = $row.prevAll('.multi-row').andSelf().slice(iRowSeq * multirowTmplCnt);
            
            var forEachResultObj = {};
            /*sText += "<" + objName + ">";*/
            //resultObj[objName] = {};
            ++iRowSeq;
            /*sText += "<ROWSEQ>" + iRowSeq.toString() + "</ROWSEQ>";
            sText += makeMultiRowJSONForDB(rows, Fields, iRowSeq.toString());
            sText += "</" + objName + ">";*/
            forEachResultObj = $.extend(forEachResultObj, {"ROWSEQ" : iRowSeq.toString()});
            forEachResultObj = $.extend(forEachResultObj, makeMultiRowJSONForDB(rows, Fields, iRowSeq.toString()));
            
            resultObj[objName].push(forEachResultObj);
        });
    }
  //  alert(sText);
    return resultObj;
} 

/* makeMultiRowXMLForDB
 * xml -> json
 * */
function makeMultiRowJSONForDB(row, Fields, rowSeq) {
    var resultObj = {};

    row.find("*[data-type='" + Fields + "']").each(function (i, fld) {

        var $fld = $(fld);
        $.extend(resultObj, makeNodeByTypeForDB($fld, Fields, rowSeq));

    });

    return resultObj;
}

// DB 컬럼형태로 저장되는 값들에 대한 태그별 분기 처리
function makeNodeByType($fld, dataType, index) {
    //var sText = '';
    var resultObj = {};
    //var $fld = $(elm);

    //tagName에 따른 처리
    var $tag = $fld.prop("tagName").toLowerCase();

    if ($tag == "input") {
        var $type = $fld.attr('type');

        if (typeof $type != 'undefined') {
            if ($type.toLowerCase() == "text") {
            	$.extend(resultObj, makeNode(getNodeName($fld), $fld.val()));
                //sText += '"' + getNodeName($fld) + '" : "' + $fld.val() + '"'; //makeNode(getNodeName($fld), $fld.val());
            }
            else if ($type.toLowerCase() == "checkbox") {
            	
            	$.extend(resultObj, getRadio(getNodeName($fld)));
                //sText += getRadio(getNodeName($fld));
            }
            else if ($type.toLowerCase() == "radio") {
            	$.extend(resultObj, getRadio(getNodeName($fld)));
                
            	//sText += getRadio(getNodeName($fld));
            }
            else if ($type.toLowerCase() == "hidden") {
            	$.extend(resultObj, makeNode(getNodeName($fld), $fld.val()));
                /*sText += makeNode(getNodeName($fld), $fld.val());*/
            }
            else {
            	$.extend(resultObj, makeNode(getNodeName($fld), $fld.val()));
                /*sText += makeNode(getNodeName($fld), $fld.val());*/
            }
        }
    }
    else if ($tag == "textarea") {
    	//var textareaVal = $fld.val().replace(/[\r\n]/g, '\\n');
    	
    	$.extend(resultObj, makeNode(getNodeName($fld), $fld.val()));
       /* sText += makeNode(getNodeName($fld), $fld.val());*/
    }
    else if ($tag == "select") {
    	$.extend(resultObj, getSelRadio($fld));
        /*sText += getSelRadio($fld);*/
    }
    else if ($tag == "span") {      //[2016-05-12 modi kh] save span mField add
        if ($fld.find("input").length == 0) { // 체크박스, 라디오박스 제외
        	$.extend(resultObj, makeNode(getNodeName($fld), $fld.text()));
            /*sText += makeNode(getNodeName($fld), $fld.text());*/
        }
    }

    //data-element-type에 따른 처리
    var $dataElmType = $fld.attr('data-element-type');

    if (typeof $dataElmType != 'undefined') {
        //체크박스면
        if ($dataElmType.indexOf("chk") > -1) {
        	$.extend(resultObj, getCheckBoxForMulti(getNodeName($fld), dataType, index));
            /*sText += getCheckBoxForMulti(getNodeName($fld), dataType, index);*/
        }//radio 면
        else if ($dataElmType.indexOf("rdo") > -1) {
        	$.extend(resultObj, getRadioTextValueForMulti(getNodeName($fld), dataType, index));
            /*sText += getRadioTextValueForMulti(getNodeName($fld), dataType, index);*/
        }

    }

    return resultObj;
}

function makeNode(sName, vVal) {
    var jsonObj = {};
    
    if(vVal == null || vVal == undefined){
    	vVal = "";
    }
    
    jsonObj[sName] = vVal;
    
    return jsonObj;
}

// DB 컬럼형태로 저장되는 값들에 대한 태그별 분기 처리
function makeNodeByTypeForDB($fld, dataType, rowSeq) {
    var sText = '';
    var returnObj = {};
    //var $fld = $(elm);

    //tagName에 따른 처리
    var $tag = $fld.prop("tagName").toLowerCase();

    if ($tag == "input") {
        var $type = $fld.attr('type');

        if (typeof $type != 'undefined') {
            if ($type.toLowerCase() == "text") {
            	$.extend(returnObj, makeNode(getNodeName($fld), $fld.val()));
                /*sText += makeNode(getNodeName($fld), $fld.val(), null, true);*/
            }
            else if ($type.toLowerCase() == "checkbox") {
            	$.extend(returnObj, getCheckBoxForDB(getNodeName($fld), "|", dataType, rowSeq));
                /*sText += getCheckBoxForDB(getNodeName($fld), "|", dataType, rowSeq);*/
            }
            else if ($type.toLowerCase() == "radio") {
            	$.extend(returnObj, getRadioForDB(getNodeName($fld), dataType, rowSeq));
                /*sText += getRadioForDB(getNodeName($fld), dataType, rowSeq);*/
            }
            else if ($type.toLowerCase() == "hidden") {
            	$.extend(returnObj, makeNode(getNodeName($fld), $fld.val()));
                /*sText += makeNode(getNodeName($fld), $fld.val());*/
            }
            else {
            	$.extend(returnObj, makeNode(getNodeName($fld), $fld.val()));
                /*sText += makeNode(getNodeName($fld), $fld.val());*/
            }
        }
    }
    else if ($tag == "textarea") {
    	//var textareaVal = $fld.val().replace(/[\r\n]/g, "\\n");
    	var textareaVal = $fld.val();
    	$.extend(returnObj, makeNode(getNodeName($fld), textareaVal));
        /*sText += makeNode(getNodeName($fld), $fld.val());*/
    }
    else if ($tag == "select") {
    	$.extend(returnObj, getSelRadioForDB($fld));
        /*sText += getSelRadioForDB($fld);*/
    }
    else if ($tag == "span"){
    	$.extend(returnObj, makeNode(getNodeName($fld), $fld.text()));
    }

    //data-element-type에 따른 처리
    var $dataElmType = $fld.attr('data-element-type');

    if (typeof $dataElmType != 'undefined') {
        //체크박스면
        if ($dataElmType.indexOf("chk") > -1) {
        	$.extend(returnObj, getCheckBoxForDB(getNodeName($fld), "|", dataType, rowSeq));
            /*sText += getCheckBoxForDB(getNodeName($fld), "|", dataType, rowSeq);*/
        }//radio 면
        else if ($dataElmType.indexOf("rdo") > -1) {
        	$.extend(returnObj, getRadioForDB(getNodeName($fld), dataType, rowSeq));
            /*sText += getRadioForDB(getNodeName($fld), dataType, rowSeq);*/
        }

    }

    return returnObj;
}

/*** xml -> json
 *  checkbox 값 가져오기***/
function getCheckBoxForDB(chkNm, seperator, dataType, rowSeq) {
    var ret = {};
    var vals = "";
    var indexedName = chkNm + "_" + rowSeq;

    if (dataType == "smField") {
        for (var i = 0; i < document.getElementsByName(chkNm).length; i++) {
            if (document.getElementsByName(chkNm)[i].checked) {
                // 구분자를 넣는 형태
                vals += document.getElementsByName(chkNm)[i].value + seperator;
            }
        }
    }
    else if (dataType == "stField") {
        for (var i = 0; i < document.getElementsByName(indexedName).length; i++) {
            if (document.getElementsByName(indexedName)[i].checked) {
                vals += document.getElementsByName(indexedName)[i].value + seperator;
            }
        }
    }

    /*ret += makeNode(chkNm, vals.slice(0, -1));*/
    $.extend(ret, makeNode(chkNm, vals.slice(0, -1)));
    return ret;
}

/*** xml -> json
 *  Radio Button 값 가져오기***/
function getRadioForDB(radioNm, dataType, rowSeq) {
    var radioVal = {};
    var indexedName = radioNm + "_" + rowSeq;
    if (dataType == "smField") {
        for (var i = 0; i < document.getElementsByName(radioNm).length; i++) {
            if (document.getElementsByName(radioNm)[i].checked) {
                $.extend(radioVal, makeNode(radioNm, document.getElementsByName(radioNm)[i].value));
            }
        }
    }
    else if (dataType == "stField") {
        for (var i = 0; i < document.getElementsByName(indexedName).length; i++) {
           // alert($('input[name="' +  indexedName + '"]').eq(i).is(':checked'));
            if (document.getElementsByName(indexedName)[i].checked) {
            	$.extend(radioVal, makeNode(radioNm, document.getElementsByName(indexedName)[i].value));
            }
        }
    }

    return radioVal;
}

/*** xml -> json
 *  Radio Button 값 가져오기***/
function getRadio(radioNm) {
    //var radioVal = "";
    var radioObj = {};
    for (var i = 0; i < document.getElementsByName(radioNm).length; i++) {
        if (document.getElementsByName(radioNm)[i].checked) {
        	radioObj[radioNm] = document.getElementsByName(radioNm)[i].value;
        }
    }
    //radioVal = JSON.stringify(radioObj);
    
    return radioObj;
}

/*** xml -> json
 *  checkbox 값 가져오기***/
function getCheckBoxForMulti(chkNm, dataType, rowSeq) {
    var vals = {};
    var indexedName = chkNm + "_" + rowSeq;

    if (dataType == "mField") {
        for (var i = 0; i < document.getElementsByName(chkNm).length; i++) {
            if (document.getElementsByName(chkNm)[i].checked) {
            	vals = $$(vals).append(chkNm,document.getElementsByName(chkNm)[i].value).json()
            	//$.extend(vals, makeNode(chkNm, document.getElementsByName(chkNm)[i].value));
            }
        }
    }
    else if (dataType == "rField") {
        for (var i = 0; i < document.getElementsByName(indexedName).length; i++) {
            if (document.getElementsByName(indexedName)[i].checked) {
            	$.extend(vals, makeNode(chkNm, document.getElementsByName(indexedName)[i].value));
            }
        }
    }

    return vals;
}

/***xml -> json */
//radio 값 구분하여 가져 오기
function getRadioTextValueForMulti(radioNm, dataType, rowSeq) {
    //debugger;
    var radioVal = {};
    var indexedName = radioNm + "_" + rowSeq;

    if (dataType == "mField") {
        for (var i = 0; i < document.getElementsByName(radioNm).length; i++) {
            if (document.getElementsByName(radioNm)[i].checked) {
            	$.extend(radioVal, makeNode(radioNm, document.getElementsByName(radioNm)[i].value));
            	$.extend(radioVal, makeNode(radioNm + "_TEXT", document.getElementsByName(radioNm)[i].getAttribute('data-text')));
            }
        }
    }
    else if (dataType == "rField") {
        for (var i = 0; i < document.getElementsByName(indexedName).length; i++) {
            if (document.getElementsByName(indexedName)[i].checked) {
            	$.extend(radioVal, makeNode(radioNm, document.getElementsByName(indexedName)[i].value));
            	$.extend(radioVal, makeNode(radioNm + "_TEXT", document.getElementsByName(indexedName)[i].getAttribute('data-text')));
            }
        }
    }

    return radioVal;
}

/** xml -> json
 *  SELECT BOX VALUE 가져오기 **/
function getSelRadioForDB(obj) {
    var radioVal = {};
    var selNm = getNodeName(obj);

    if (obj[0].selectedIndex > -1) {
    	$.extend(radioVal, makeNode(selNm, obj[0].options[obj[0].selectedIndex].value));
    } else {
    	makeNode(selNm, makeNode(selNm, "0"));
    }
    return radioVal;
}

/** xml -> json
 *  SELECT BOX VALUE 가져오기 **/
function getSelRadio(obj) {
    var radioObj = {};
    //var selNm = obj.attr("name");
    var selNm = getNodeName(obj);
    if (obj[0].selectedIndex > -1) {
    	$.extend(radioObj, makeNode(selNm, obj[0].options[obj[0].selectedIndex].value));
    	$.extend(radioObj, makeNode(selNm + "_TEXT", obj[0].options[obj[0].selectedIndex].text));
    } else {
    	$.extend(radioObj, makeNode(selNm, ""));
    	$.extend(radioObj, makeNode(selNm + "_TEXT", ""));
    }
    return radioObj;
}

/*** 라디오 버튼 value display ***/
function setRadio(szname, szvalue) {
    var objrdo = document.getElementsByName(szname);
    for (var i = 0; i < objrdo.length; i++) {
        if (objrdo[i].value == szvalue) objrdo[i].checked = true;
    }
}

/*** 라디오 버튼 value display read 페이지용(RDO)***/
function setRadioRead(szname, szvalue) {
    if (document.getElementsByName(szname)[Number(szvalue)] != null) {
        document.getElementsByName(szname)[Number(szvalue)].innerHTML = "●";
    }
}

/*** 라디오 버튼 value가 의미있는 값일 경우 display read 페이지용(RDV) ***/
function setRadioValueRead(szname, szvalue) {
    if (document.getElementsByName(szname + "_" + szvalue)[0] != null) {
        document.getElementsByName(szname + "_" + szvalue)[0].innerHTML = "●";
    }
}

/*** single 라디오 버튼 value display ***/
function setChk(szname, szvalue) {
    var objrdo = document.getElementsByName(szname)[0];
    if (objrdo.value == szvalue) objrdo.checked = true;
}

/*** single 라디오 버튼 value display read 페이지용(CHK)***/
function setChkRead(szname, szvalue) {
    var objrdo = document.getElementById(szname);
    if (szvalue == 1) objrdo.innerHTML = "■";
}

//문서분류 대입 (2012-04-02 HIW)
function setDocClass() {
    try {
        if (document.getElementById("DocClassName").value == "") {
            document.getElementById("DocClassName").value = getInfo("ExtInfo.DocClassName");
            document.getElementById("approval_write_DocClassName").innerText = getInfo("ExtInfo.DocClassName");
        }
        if (document.getElementById("DocClassID").value == "") {
            document.getElementById("DocClassID").value = getInfo("ExtInfo.DocClassId");
        }
    }
    catch (ex) { mobile_comm_log(ex); }
}

function makeCBOobject(strcode, strname, cboObject) {
    try {
        var oOption = document.createElement("OPTION");
        cboObject.options.add(oOption);
        oOption.text = strname;
        oOption.value = strcode;
    } catch (e) { mobile_comm_log(e); }
    return;
}
function setDefaultCBOobject(strcode, cboObject) {
    if (strcode == '' || strcode == null) strcode = '1';
    for (var i = 0; i < cboObject.length; i++) {
        if (cboObject.options[i].value == strcode) {
            cboObject.options[i].selected = true;
        }
    }
}

function setBodyContext(bodyJson) {
    //data를 가져온 후 재처리가 필요한 경우를 대비
    try {

    	if(typeof(bodyJson) == "string"){
    		bodyJson = $.parseJSON(bodyJson);
    	}
    	
        setInfo("BodyContext", bodyJson);

        if (typeof formJson.BodyContext != 'undefined' && formJson.BodyContext != null && formJson.BodyContext !="{}") {
            $.each(formJson.BodyContext, function (key, value) {
                var $target;
                //key를 id로 가지는 element가 존재하면
                if ($('#' + key).length) {
                    //span 태그 mField로 데이터 바인딩시 [2016-05-17 kimjh modi]
                    if ($('#' + key)[0].nodeName == "SPAN") {
                        $('#' + key).text(value);
                    } else {
                        $('#' + key).val(value);
                    }
                }
            });

            //후처리 재실행
            postJobForDynamicCtrl();
        }
    } catch (e) {
        alert("Error at setBodyContext");
    }
}

//editor data 처리를 위한 함수 추가
function setEditor(idx) {
  var dom;
  var commonEditorType = mobile_comm_getBaseConfig("EditorType");

  if(!idx) idx = "";
  
  //쓰기 모드인 경우
  if (getInfo("Request.templatemode") == "Write") {
	  var sBody = "";
	  commonEditorType = mobile_comm_getBaseConfig("MobileEditorTypeApproval");
	  if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {
		  if(commonEditorType == "1") {
			  if(formJson.BodyContext.tbContentElement_Text != undefined) {
				  sBody = formJson.BodyContext.tbContentElement_Text.replace(/(<br>|<br\/>|<br \/>)/g, '\r\n');
			  }
		  } else {
			  if(getInfo('ExtInfo.UseMultiEditYN') == "Y") {
				  if($(formJson.BodyData.SubTable1)[idx-1] != undefined) {
					  sBody = Base64.b64_to_utf8($(formJson.BodyData.SubTable1)[idx-1].MULTI_BODY_CONTEXT_HTML);
				  } else if (getInfo("FormInfo.BodyDefault") != undefined) {
					  sBody = Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault"));
				  }
	          } else {
	              if (formJson.BodyContext.tbContentElement["#cdata-section"]) {
	            	  sBody = formJson.BodyContext.tbContentElement["#cdata-section"].replace(/<br \/>/gi, "").replace(/\\n/gi, "");
	              } else {
	            	  sBody = formJson.BodyContext.tbContentElement.replace(/<br \/>/gi, "").replace(/\\n/gi, "");
	              }
	          }
		  }
	  } else {
		  if (getInfo("FormInfo.BodyDefault") != undefined) {
			  sBody = Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault"));
          }
	  }
	  
	  switch (commonEditorType) {
	  	case "2"://TinyMCE(기본)
			$('#MobileEditorFrame').load(function () {
		    	setTimeout(function(){
					mobileEditor.setBody(sBody);
				},100);
			});
			break;
		case "1"://textarea
			$("#MobileTextArea").html(sBody);
			break;
		default:
			break;
	  }
  } else { // 읽기 모드인 경우
	  var tbContent;
      if(getInfo('ExtInfo.UseMultiEditYN') == "Y") {
    	  tbContent = Base64.b64_to_utf8(formJson.BodyData.SubTable1[idx-1].MULTI_BODY_CONTEXT_HTML);
      } else if (typeof formJson.BodyContext.tbContentElement["#cdata-section"] != 'undefined') {
    	  tbContent = formJson.BodyContext.tbContentElement["#cdata-section"];
      } else if (typeof formJson.BodyContext.tbContentElement != 'undefined') {
          tbContent = formJson.BodyContext.tbContentElement;
      } else {
          tbContent = "error at setEditor().";
      }

      //읽기모드인 경우 에디터 자체 여백 처리
      switch (commonEditorType) {
      	case "3":	//xfree
    	case "12":	//webhwpctrl
    		$("#tbContentElement").css("padding","10px");
  			break;
      	case "8":	//dext5
      		if(getInfo('ExtInfo.UseMultiEditYN') == "Y") {
  	    		$(".table_form_info_draft").css("width","680px");
  				$("#tbContentElement"+idx).css("padding","10px");
  				$("#tbContentElement1 table").css("table-layout", "auto");
  	        } else {
        		$(".table_form_info_draft").css("width","670px").css("margin","10px");
			}
      		break;
      }

      	// 이전 데이터를 위한 내용으로 신규문서와는 무관
      	//$("[id='tbContentElement"+idx+"']").html(mobile_approval_replaceContent(tbContent.replace(/\\n/gi, "").replace(/\/gwstorage\//gi, Common.getBaseConfig("BackStorage"))));
		//프로젝트사이트에서 BackStorage경로에 gwstorage를 포함하여 계속 사용하여 replace가 두번치환하여 회사코드값이 두번 들어가는현상 수정_20210930 (Pc수정사항 모바일 적용)
		if(Common.getBaseConfig("BackStorage").indexOf("gwstorage") > -1){
			$("[id='tbContentElement"+idx+"']").html(mobile_approval_replaceContent(tbContent.replace(/\\n/gi, "")));
		}else{
			$("[id='tbContentElement"+idx+"']").html(mobile_approval_replaceContent(tbContent.replace(/\\n/gi, "").replace(/\/gwstorage\//gi, Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")))));
		}
		
  }
}

function getEditorImages() {
    var ret = "";

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
        ret = "";
    }
    else {
        try {
        	switch (mobile_comm_getBaseConfig("MobileEditorTypeApproval")) {//TinyMCE(기본)
	    		case "2":
	    			ret = mobileEditor.getImages();
	    			break;
	    		case "1"://textarea
	    		default:
	    			ret = "";
	    			break;
	    	}
        } catch (e) { mobile_comm_log(e); }
    }

    return ret;
}

function getEditorBackgroundImage() {
    var ret = "";

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
        ret = "";
    }
    else {
        try {
        	switch (mobile_comm_getBaseConfig("MobileEditorTypeApproval")) {
	    		case "2"://TinyMCE(기본)
	    			ret = mobileEditor.getBackgroundImage();
	    			break;
	    		case "1"://textarea
	    		default:
	    			ret = "";
	    			break;
	    	}
        } catch (e) { mobile_comm_log(e); }
    }

    return ret;
}

function getEditorBody() {
    var ret = "";

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
        ret = "";
    }
    else {
        try {
        	switch (mobile_comm_getBaseConfig("MobileEditorTypeApproval")) {
    			case "1"://textarea
    				ret = $("#MobileTextArea").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />');
	    			break;
	    		case "2": //TinyMCE(기본)
	    			ret = mobileEditor.getBody();
	    			break;
	    		default:
	    			ret = "";
	    			break;
	    	}
        } catch (e) { mobile_comm_log(e); }
    }

    return ret;
}

function getEditorBodyText() {
    var ret = "";

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
        ret = "";
    }
    else {
        try {
        	switch (mobile_comm_getBaseConfig("MobileEditorTypeApproval")) {
    			case "1"://textarea
    				ret = $("#MobileTextArea").val();
	    			break;
	    		case "2": //TinyMCE(기본)
	    			ret = mobileEditor.getBodyText();
	    			break;
	    		default:
	    			ret = "";
	    			break;
	    	}
        } catch (e) { mobile_comm_log(e); }
    }

    return ret;
}

//수신처 관련 시작
function getReceiveNo() {
    var strRecDeptNo = document.getElementById("ReceiveNo").value;
    if (strRecDeptNo != "") {
        var iFIndex = strRecDeptNo.indexOf('[' + getInfo("AppInfo.dpid") + ']');
        if (iFIndex != -1) {
            var iLIndex = strRecDeptNo.indexOf(';', iFIndex);
            var iMIndex = strRecDeptNo.indexOf(']', iFIndex);
            return strRecDeptNo.substring(iMIndex + 1, iLIndex);
        } else { return ""; }
    } else { return ""; }
}

function getNodeName(obj) {
    var ret;

    var $name = obj.attr("name");
    var $id = obj.attr("id");
    var $nodeName = obj.attr("data-node-name");

    if (typeof $name != 'undefined' && $name != "") {
        ret = $name;
    }
    else if (typeof $id != 'undefined') {
        ret = $id;
    }
    else if (typeof $nodeName != 'undefined') {
        ret = $nodeName;
    }

    return ret;
}

/*******************************************
***** 양식 파일 내 연결문서 함수 정리 시작 *****
*******************************************/
function DocLink(){
	
	var arrDocLink = [];
	var FormUrl = "";
    var multiIdx;
    var bUseTotalApproval = mobile_comm_getBaseConfig("useTotalApproval");
	
	this.init = function(idx){
		if(!idx) multiIdx = "";
		else {
			if(document.getElementsByName("MULTI_LINK_DOC").length > 0) multiIdx = idx;
			else multiIdx = "";
		}
		
		refresh();
        this.display();
	}
	
	var refresh = function(){
		var szdoclinksinfo = "";
	    var szdoclinks = "";
		
		if(multiIdx) {
			szdoclinks = document.getElementsByName("MULTI_LINK_DOC")[multiIdx] ? document.getElementsByName("MULTI_LINK_DOC")[multiIdx].value : '';
		} else {
		    if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBAPPROVAL") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBREDRAFT") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "PCONSULT") || g_szEditable == true) {
		        try { szdoclinks = document.getElementById("DocLinks").value; } catch (e) { coviCmn.traceLog(e); }
		    } else {
		        try { szdoclinks = document.getElementById("DocLinks").value; } catch (e) { coviCmn.traceLog(e); }
		        if (szdoclinks == "") {
		            try { document.getElementById("DocLinks").value = szdoclinks; } catch (e) { coviCmn.traceLog(e); }
		        }
		    }
		}
				
	    //DOCLINKS 값에 undefined 가 들어 가서 오류남. 원인 찾기전 임시로 작성
		szdoclinks = szdoclinks || "";
	    szdoclinks = szdoclinks.replace("undefined^", "");
	    szdoclinks = szdoclinks.replace("undefined", "");

	    if(szdoclinks){
	        var adoclinks = szdoclinks.split("^^^");
        	arrDocLink = adoclinks.map(function(docItem){
        		var adoc = docItem.split("@@@");
        		return {
        			processID : adoc[0] || 0,
        			formPrefix : adoc[1] || "",
        			subject : adoc[2] || "",
        			forminstanceID : adoc[3],
        			bstored : adoc[4],
        			businessData1 : adoc[5] || "",
        			businessData2 : adoc[6] || "" //ExpAppID
        		};
        	});
	    } else {
	    	arrDocLink = [];
	    }
	}
	
	var setValue = function(){
		var _temp = arrDocLink.map(function(docItem){ return docItem.processID + "@@@" + docItem.formPrefix + "@@@" + docItem.subject + "@@@" + docItem.forminstanceID + "@@@"+ docItem.bstored + "@@@" + docItem.businessData1 + "@@@" + docItem.businessData2; });
		if(multiIdx) {
			$("[name='MULTI_LINK_DOC']").eq(multiIdx).val(_temp.join("^^^"));
		} else {
			$("#DocLinks").val(_temp.join("^^^"));
		}
	}
	
	this.display = function(){
		var bEdit = false;

        $("#DocLinkInfo" + multiIdx).empty();
        
        if(arrDocLink.length > 0){
            if (getInfo("Request.templatemode") == "Read") {
                bEdit = false
            } else {
                bEdit = true;
            }
	        
	        $("#DocLinkInfo" + multiIdx).append(arrDocLink.map(function(docItem){
	            var docDiv =  $("<div>");
	            
	            if(bUseTotalApproval == "Y" && docItem.businessData1 == "ACCOUNT") {
	            	FormUrl = "/account/mobile/account/view.do";
	            } else {
	            	FormUrl = "/approval/mobile/approval/view.do";
	            }
	            
	            var url = FormUrl + "?mode=COMPLETE";
	       	 	url += "&processID=" + docItem.processID + "&forminstanceID=" 
	   	 		+ (typeof docItem.forminstanceID != "undefined" ? docItem.forminstanceID : "&archived=true") 
	   	 		+ "&bstored=" + (typeof docItem.bstored != "undefined" ? docItem.bstored : "false")
	   	 		+ "&ownerProcessId=" + (getInfo("ProcessInfo.ProcessID") == undefined ? "" : getInfo("ProcessInfo.ProcessID")); // 현문서 ProcessId [2021-01-22 add]
		        if(typeof docItem.businessData2 != "undefined" && docItem.businessData2 != "undefined")
		        	url += "&ExpAppID="+docItem.businessData2+"&taskID="; // 경비 팝업에서 필요한 파라미터 추가
	
	            if (!bEdit) {
	                if (bDisplayOnly) {
	                	docDiv.append(mobile_approval_replaceCharacter(docItem.subject));
	                } else {                                   	 
	               	 	docDiv
	               	 		.append($("<span>", {"class" : "txt_gn11_blur","onmouseover":'this.style.color=\"#2f71ba\"', "onmouseout" : 'this.style.color=\"#111111\"', "style" : 'cursor:pointer;', "onClick" : "mobile_approval_openDocLink('"+url+"','"+docItem.formPrefix+"')"})
	               			.text("- " + mobile_approval_replaceCharacter(docItem.subject))).append($("<br>"));
	                }
	            }
	            
	            return docDiv.html();
	        }));

        	$("#label_DocLinkInfo").hide();
	        $("#approval_write_DocLinkInfo").html(arrDocLink.map(function(docItem){
	            var docDiv =  $("<div>");                               	 
           	 	docDiv
           	 		.append($("<a>", {"class" : "btn_add_docs ui-link", "value" : docItem.processID, "onClick" : "docLinks.deleteItem(this);"})
           			.text(mobile_approval_replaceCharacter(docItem.subject)));
	            
	            return docDiv.html();
	        })).show();
        } else {
        	$("#label_DocLinkInfo").show();
        	$("#approval_write_DocLinkInfo").hide();
        }
	}
	
	this.addItem = function(addItems){
		//중복 제거
		$.each(arrDocLink, function(dIdx, docItem){
			$.each(addItems, function(nIdx, newItem){
				if(newItem && docItem.processID === newItem.processID){
					addItems.splice(nIdx, 1);
				}
			});
		});
		
		if(addItems.length > 0)
			arrDocLink.push.apply(arrDocLink, JSON.parse(JSON.stringify(addItems)));
		
	    setValue();
	    this.display();
	}
	
	this.deleteItem = function(obj){
	    var tmp = $(obj).attr("value");
	    
	    $("#DocLinkInfo").find("input[id='chkDoc'][name='_" + tmp + "']").prop("checked", true); //양식의 실제 연관문서 영역
	    $(obj).remove();
	    
        for (var j = arrDocLink.length - 1; j >= 0; j--) {
            if (arrDocLink[j].processID == tmp) {
            	arrDocLink.splice(j, 1);
            }
        }
        
	    setValue();
	    this.display();
	}
};

var docLinks = new DocLink();

// 연결문서 조회
// TO-DO: 추후 연결문서 조회 후 이전 결재문서로 돌아갈 수 있도록 보완 필요
function mobile_approval_openDocLink(pUrl, formPrefix) {
	var path = window.parent.location.pathname;
	
	//포탈 미결문서탭
	if(path.indexOf('portal') > -1) {
		if(confirm(mobile_comm_getDic("msg_apv_openDocLink"))) { //조회중인 현재 페이지를 닫고 요청하신 연결문서의 조회 페이지로 이동합니다.
			window.parent.mobile_portal_goDetail(pUrl, 'Y');
			return;
		}
	}
	
	//결재
	if(path.indexOf('approval') > -1) {
		//미리보기
		if($('#approval_preview_showContent').length > 0) {
			mobile_approval_goView(pUrl, formPrefix);
			return;
		}
		
		//문서조회
		/*if(confirm(mobile_comm_getDic("msg_apv_openDocLink"))) { //조회중인 현재 페이지를 닫고 요청하신 연결문서의 조회 페이지로 이동합니다.
			window.parent.mobile_comm_back(pUrl);
			return;
		}*/
		pUrl += "&isDocLinked=Y";
		mobile_approval_popupMove(pUrl);
	}
}

// 모바일 양식 작성 시 라디오/체크박스 생성
function mobile_approval_loadCheckBoxAndRadio(pTable) {
	if($(pTable).length > 0) {
		$(pTable).trigger("create"); // 특정 테이블만 생성
	}
	else {
		$(".appforms_cont").trigger("create"); // 결재양식 전체 영역에 대하여 생성
	}
}

// 멀티로우 테이블 내 라디오/체크박스 로드
function mobile_approval_setMultiCheckAndRadio() {
	$(".multi-row-table").each(function(i, oTable) {
    	$(oTable).find(".multi-row").each(function(j, oRow) {
        	var chkSeq = j + 1;
        	
    		$(oRow).find("input[type='checkbox'], input[type='radio']").each(function(k, oElm) {
            	var chkID = "";
            	
            	if($(oElm).attr("name") != undefined && $(oElm).attr("name") != "") {
            		chkID = $(oElm).attr("name");
            	}
            	else if($(oElm).hasClass("multi-row-selector")){
            		chkID = "selector";
            	}
            	
            	chkID += "_" + chkSeq + "_" + k;
            	
            	$(oElm).attr("id", chkID);
            	$(oElm).attr("seq", chkSeq);
            	$(oElm).prev("label").attr("for", chkID);
    		});
        });
	});
}

// 멀티로우 테이블 내 행 추가 시 라디오/체크박스 로드
function mobile_approval_addMultiCheckAndRadio($rows) {
	var oTable = $rows.eq(0).closest(".multi-row-table");
	
    // $rows는 추가된 행 개체    
    $rows.each(function(i, oRow) {
    	var chkSeq = $(oTable).find(".multi-row-selector").length - 1;
    	
    	$(oRow).find("input[type='checkbox'], input[type='radio']").each(function(k, oElm) {
        	var chkID = "";
        	
        	if($(oElm).attr("name") != undefined && $(oElm).attr("name") != "") {
        		chkID = $(oElm).attr("name");
        	}
        	else if($(oElm).hasClass("multi-row-selector")){
        		chkID = "selector";
        	}
        	
        	chkID += "_" + chkSeq + "_" + k;
        	
        	$(oElm).attr("id", chkID);
        	$(oElm).attr("seq", chkSeq);
        	$(oElm).prev("label").attr("for", chkID);
		});
    });
    
    // 모바일 내 멀티로우 체크박스 사용을 위한 처리
    mobile_approval_loadCheckBoxAndRadio(oTable);
}

// 모바일 양식 작성 시 멀티로우 전체선택 이벤트 관련 함수
function mobile_approval_multiRowSelectAll(obj) {
	var targetRow = $(obj).closest("table").find(".multi-row").not(".pattern-skip");
	
	$(targetRow).find(".multi-row-selector").prop("checked", $(obj).is(":checked")).checkboxradio('refresh');
}

// VM 신청서 관련 Start

function getOSSelect(Sel_id, CodeGroup) {
    // data 예) Sel_id : 구분값
   /* var connectionname = "COVI_FLOW_SI_ConnectionString";
    var pXML = "dbo.USP_FORM_BASE_OS_S";
   //var Sel_id = Sel_id.name;
    var aXML = "<param><name>GUBUN</name><type>varchar</type><length>100</length><value><![CDATA[" + GUBUN + "]]></value></param>";
    var sXML = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql><type>sp</type>" + aXML + "</Items>";
    var szURL = "../getXMLQuery.aspx";
    */
	CFN_CallAjax("/approval/legacy/getFormBaseOS.do", {"CodeGroup":CodeGroup}, function (data){ 
		receiveHTTPGetData_OSSelect_master(data, Sel_id); 
	}, false, 'json');
}



function receiveHTTPGetData_OSSelect_master(responseJSONdata, Sel_id) {
    var jsonReturn = responseJSONdata;
    var elmlist = jsonReturn.Table;
    var Codegrp = '';

    $("select[name='" + Sel_id + "']")[0].options.length = 0;
    $("select[name='" + Sel_id + "']").append("<option value=''>선택</option>");
    $(elmlist).each(function () {
        $("select[name='" + Sel_id + "']").append("<option value='" + this.CODE_VALUE + "'>" + this.CODE_VALUE + "</option>");
    });
}

//VM 신청서 관련 End

/* =================== FormBody.js END =================== */







/* =================== FormApvLine.js START =================== */


/* =================== FormApvLine.js END =================== */






/* =================== FormAttach.js START =================== */

//formInstance의 attachfileinfo 컬럼 값을 세팅
function setFormAttachFileInfo(bPlain) {

	var strOldAttachFileInfo = getInfo("FormInstanceInfo.AttachFileInfo");
	var oldAttachFileInfoLength = 0;
	var oldAttachFileInfoArr = new Array();
	var formAttachFileInfoObj = {};
	var objArr = new Array();
	var fileSeq = 0;

	if (strOldAttachFileInfo != "" && strOldAttachFileInfo != undefined) {
		oldAttachFileInfoLength = $$(strOldAttachFileInfo).json().FileInfos.length;
		oldAttachFileInfoArr = $$(strOldAttachFileInfo).json().FileInfos;
	}

	var fileInfos = $.parseJSON(getInfo("FileInfos"));

	if ($("#mobile_attach_uplodedfiles").find("li").length > 0) {
		$("#mobile_attach_uplodedfiles").find("li").each(function(i, checkObj) {
			var obj = {};
			var strArrObj = $(checkObj).attr("value").split(":");
			
			if (strArrObj[2] == "OLD" || strArrObj[2] == "REUSE") {
				$(fileInfos).each(function(j, oldObj) {
					// 유지되는 파일은 파일정보를 그대로 가진다.
					if (oldObj.SavedName == strArrObj[3]) {
						if(!bPlain) oldObj.FileName = encodeURIComponent(oldObj.FileName); // 미리보기시 인코딩 안함
						objArr.push(oldObj);
						fileSeq++;
					}
				});
			} else if (strArrObj[2] == "NEW") {
				var strFormInstID = getInfo("FormInstanceInfo.FormInstID") == undefined ? "" : getInfo("FormInstanceInfo.FormInstID");
				
				$$(obj).append("ID", strFormInstID + "_" + fileSeq);
				$$(obj).append("FileName", (bPlain ? strArrObj[1] : encodeURIComponent(strArrObj[1]))); // 미리보기시 인코딩 안함
				$$(obj).append("Type", strArrObj[2]);
				$$(obj).append("AttachType", strArrObj[4]);
				$$(obj).append("UserCode", getInfo("AppInfo.usid"));
				if(strArrObj.length > 6) $$(obj).append("OriginID", strArrObj[6]); // edms 원파일 fileid
				
				if(strArrObj[4] == "webhard") {
					$$(obj).append("SavedName", strArrObj[3]);
				}
				
				objArr.push(obj);
			}
		});
	}

	if (objArr.length > 0) {
		$$(formAttachFileInfoObj).append("FileInfos", objArr);
		$("#AttachFileInfo").val(JSON.stringify($$(formAttachFileInfoObj).json()));
	} else {
		$("#AttachFileInfo").val("");
	}
}

//편집모드일 경우, 기존 파일 정보 수정
function mobile_approval_editAttachFileInfo() {
	var fileInfos = $.parseJSON(getInfo("FileInfos"));
	
	if ($("#AttachFileInfo").val() != "") {
		var attachInfos = $.parseJSON($("#AttachFileInfo").val());

		// 재사용, 임시저장일 경우 정보에 reuse로 변경
		if ((getInfo("Request.mode") == "DRAFT" && getInfo("Request.gloct") == "COMPLETE") || (getInfo("Request.mode") == "DRAFT" && getInfo("Request.gloct") == "REJECT") || (getInfo("Request.mode") == "TEMPSAVE")) {
			$$(attachInfos).find("FileInfos").concat().attr("Type", "REUSE");
			$("#AttachFileInfo").val(JSON.stringify($$(attachInfos).json()));
			setInfo("FormInstanceInfo.AttachFileInfo", JSON.stringify($$(attachInfos).json()));
		}
	}

	//첨부파일 업로드 컨트롤 html 바인딩 호출
	mobile_comm_uploadhtml(formJson.FileInfos);
}

/* =================== FormAttach.js END =================== */