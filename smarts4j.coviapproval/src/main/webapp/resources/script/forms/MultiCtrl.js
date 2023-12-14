//* 프로그램 저작권 정보
// 이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
// (주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
// (주)코비젼의 지적재산권 침해에 해당됩니다.
// (Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
//
// You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
// as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
// owns the intellectual property rights in and to this program.
// (Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

///<creator>기술연구소</creator> 
///<createDate>2021.03.16</createDate> 
///<lastModifyDate>2021.03.16</lastModifyDate> 
///<version>1.0.0</version>
///<summary> 
///
///</summary>
//*/

var l_Clsid = "BD9C32DE-3155-4691-8972-097D53B10052";
var l_Env = "/WebSite/Common/ExControls/TagFree/";
var g_id = "tbContentElement";
var gx_id = "tbContentElement";

var gx_cnt1 = 0;//초기 안세팅 check
var gx_cnt2 = 0;
var gx_cnt3 = 0;
var gx_cnt4 = 0;
var gx_cnt5 = 0;
var gx_cnt6 = 0;
var gx_cnt7 = 0;
var gx_cnt8 = 0;
var gx_cnt9 = 0;
var gx_cnt10 = 0;

var isAdmPage = 'N';
if ("undefined" != typeof (gIsAdmPage)) {
    isAdmPage = gIsAdmPage;
}

function LoadtweditorForApproval() {
    try {
        if (getInfo("Request.templatemode") != "Write") {
            g_heigth = "1000";
        }
    } catch (e) {
        g_heigth = "1000";
    }
    var oHtml = '';
    if (g_id == "tbContentElement") {
        oHtml += '<table class="table_4" summary="Contents" cellpadding="0" cellspacing="0" id="tbEditer">';

        //[2012-07-25 add] add html control S ----------------------------------
        if ("Y" == isAdmPage) {
            oHtml += '    <tr id="trControl"style="display:none;">';
            oHtml += '        <td width="100%" height="30px" style="vertical-align:middle;">';
            oHtml += 'Add Control : ';
            oHtml += '<a href=\'javascript:AddControl("text");\'><img src="/images/images/approval/editor_text.png" alt="TextBox" title="TextBox" /></a>';
            oHtml += '<a href=\'javascript:SetControlOption("text");\'><strong>[O]</strong>&nbsp;&nbsp;';
            oHtml += '<a href=\'javascript:AddControl("check");\'><img src="/images/images/approval/editor_check.png" alt="CheckBox" title="CheckBox" /></a>';
            oHtml += '<a href=\'javascript:SetControlOption("check");\'><strong>[O]</strong>&nbsp;&nbsp;';
            oHtml += '<a href=\'javascript:AddControl("radio");\'><img src="/images/images/approval/editor_radio.png" alt="RadioButton" title="RadioButton" /></a>';
            oHtml += '<a href=\'javascript:SetControlOption("radio");\'><strong>[O]</strong>&nbsp;&nbsp;';
            oHtml += '<a href=\'javascript:AddControl("select");\'><img src="/images/images/approval/editor_combo.png" alt="SelectBox" title="SelectBox" /></a>';
            oHtml += '<a href=\'javascript:SetControlOption("select");\'><strong>[O]</strong>&nbsp;&nbsp;';
            oHtml += '        </td>';
            oHtml += '    </tr>	';
        }
        //[2012-07-25 add] add html control E ----------------------------------

        oHtml += '    <tr>';
        oHtml += '        <td width="100%" height="362px">';
    }
    oHtml += '<object ID="' + g_id + '" width="100%" height="' + g_heigth + 'px" CLASSID="CLSID:' + l_Clsid + '" >';
    oHtml += '<PARAM name="_Version" value="65537"/>';
    oHtml += '<PARAM name="_ExtentX" value="24950"/>';
    oHtml += '<PARAM name="_ExtentY" value="9234"/>';
    oHtml += '<PARAM name="_StockProps" value="0"/>';
    oHtml += '<PARAM name="FILENAME" value=""/>';
    oHtml += '<PARAM name="TOOLBAR_MENU" value="0"/>';
    oHtml += '<PARAM name="TOOLBAR_STANDARD" value="0"/>';
    oHtml += '<PARAM name="TOOLBAR_FORMAT" value="0"/>';
    oHtml += '<PARAM name="TOOLBAR_DRAW" value="0"/>';
    oHtml += '<PARAM name="TOOLBAR_TABLE" value="0"/>';
    oHtml += '<PARAM name="TOOLBAR_IMAGE" value="0"/>';
    oHtml += '<PARAM name="TOOLBAR_HEADER_FOOTER" value="0"/>';
    oHtml += '<PARAM name="SHOW_TOOLBAR" value="0"/>';
    oHtml += '<PARAM name="SHOW_STATUSBAR" value="0"/>';
    oHtml += '</object>';

    if (g_id == "tbContentElement") {
        oHtml += '        </td>';
        oHtml += '    </tr>	';
        //oHtml += '    <tr>';
        //oHtml += '        <td  style="height:30px; background:#f3f3f3; text-align:center;">';
        //oHtml += '            <table class="editor_size" cellpadding="0" cellspacing="0">';
        //oHtml += '			  <tr>';
        //oHtml += '                <td style="height:11px; text-align:center;"><a href=\'javascript:PlusMinusEditorHeight("minus");\'><img src="/images/images/approval/editor_minus.gif" width="25" alt="minus" title="minus" /></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>';
        //oHtml += '                <td style="height:11px; text-align:center;"><a href=\'javascript:PlusMinusEditorHeight("plus");\'><img src="/images/images/approval/editor_plus.gif" width="25" alt="plus" title="plus" /></a></td></tr>';
        //oHtml += '            </table>';
        //oHtml += '        </td>';
        //oHtml += '    </tr>	';
        oHtml += '</table>';
    }
    return oHtml;
}

function LoadtweditorForApprovalMulti(idx, doctype) {
    var sHtml = '';
    var minHeight = Common.getBaseConfig("EditorMinHeight") == "" ? "580" : Common.getBaseConfig("EditorMinHeight");
	
    sHtml += '<table class="table_form_info_draft" cellpadding="0" cellspacing="0" style="margin-top: 5px; table-layout: fixed; min-height: ' + minHeight + 'px; width:100%; border:hidden;">';
    sHtml += '    <tr>';
    sHtml += '        <td width="100%" height="100%" id="' + (g_id + idx) + '" doctype="' + doctype + '" valign="top" style="padding:0px"></td>';
    sHtml += '    </tr>';
    sHtml += '</table>';
    
    return sHtml;
}

//편집기 높이조정
var ntbContentElementHeight = 600;
if (document.tbContentElement != undefined) {
    ntbContentElementHeight = parseInt(document.tbContentElement.height);
}
function PlusMinusEditorHeight(pMode) {
    if ((pMode == "plus" && document.tbContentElement.height >= parseInt(g_heigth)) || (pMode == "minus" && document.tbContentElement.height > parseInt(g_heigth))) {
        if (pMode == "minus") {
            if (parseInt(document.tbContentElement.height) + -parseInt(200) >= ntbContentElementHeight - 600) document.tbContentElement.height = parseInt(document.tbContentElement.height) + -parseInt(200);
        } else {
            if (parseInt(document.tbContentElement.height) + parseInt(200) <= ntbContentElementHeight + 600) document.tbContentElement.height = parseInt(document.tbContentElement.height) + parseInt(200);
        }
        try { cTagreSize(); } catch (e) { coviCmn.traceLog(e); } //design조정
    }
}

function PlusMinusEditorHeightMulti(pMode, idx) {
    var objEditor = $("#tbContentElement"+idx);
    if ((pMode == "plus" && $(objEditor)[0].height >= parseInt(g_heigth)) || (pMode == "minus" && $(objEditor)[0].height > parseInt(g_heigth))) {
        if (pMode == "minus") {
            if (parseInt($(objEditor)[0].height) + -parseInt(200) >= ntbContentElementHeight - 600) $(objEditor)[0].height = parseInt($(objEditor)[0].height) + -parseInt(200);
        } else {
            if (parseInt($(objEditor)[0].height) + parseInt(200) <= ntbContentElementHeight + 600) $(objEditor)[0].height = parseInt($(objEditor)[0].height) + parseInt(200);
        }
        try { cTagreSize(); } catch (e) { coviCmn.traceLog(e); } //design조정
    }
}

//[2012-07-25 추가] 에디터에 컨트롤 추가 S ------------------------------------------------
var idxControl = 0;
var firstLoad = true;
function AddControl(argContNm) {
    var twe = document.tbContentElement;       //editor object
    var insertTag = '';                        //html control tag string
    var optionAttr = '';                       //html control option tag
    var optionFont = '';                       //check box and radio button text style, class

    //고유한 name 부여를 위한 index hidden value
    var editorForm = twe.GetDOM();
    if (null != editorForm.getElementById("hdnIdxCnt")) {
        var tmpIdx = editorForm.getElementById("hdnIdxCnt").value;
        idxControl = parseInt(tmpIdx);
        idxControl++;

        editorForm.getElementById("hdnIdxCnt").value = idxControl.toString();
    }
    else {
        twe.InsertHtml('<input type="hidden" id="hdnIdxCnt" value="1" />');
        idxControl++;
    }

    //해당 컨트롤 추가
    var arrTxtOption = new Array();
    if ("text" == argContNm) {         //Text Box
        arrTxtOption[0] = $('#hdnHtmlControlOptVal_0').val();  //width
        arrTxtOption[1] = $('#hdnHtmlControlOptVal_1').val();  //Height
        arrTxtOption[2] = $('#hdnHtmlControlOptVal_2').val();  //MultiLine
        arrTxtOption[3] = $('#hdnHtmlControlOptVal_3').val();  //Default Value
        arrTxtOption[4] = $('#hdnHtmlControlOptVal_4').val();  //class
        arrTxtOption[5] = $('#hdnHtmlControlOptVal_5').val();  //style

        optionAttr = ' style="width:' + arrTxtOption[0] + 'px; ';
        optionAttr += 'height:' + arrTxtOption[1] + 'px; ';
        optionAttr += arrTxtOption[5] + '"';
        optionAttr += ' class="' + arrTxtOption[4] + '"';

        if ('false' == arrTxtOption[2]) {  //TextBox
            optionAttr += ' value="' + arrTxtOption[3] + '"';
            insertTag = '<input type="text" id="mField" name="editorTxt_' + idxControl.toString() + '" ' + optionAttr + ' />';
        }
        else {                             //textarea
            insertTag = '<textarea id="mField" name="editorTxt_' + idxControl.toString() + '" ' + optionAttr + ' >' + arrTxtOption[3] + '</textarea>';
        }
    }
    else if ("check" == argContNm) {   //Check Box
        arrTxtOption[0] = $('#hdnChkOptVal_0').val();  //checked
        arrTxtOption[1] = $('#hdnChkOptVal_1').val();  //class
        arrTxtOption[2] = $('#hdnChkOptVal_2').val();  //style

        if ("true" == arrTxtOption[0]) {
            optionAttr = ' checked';
        }

        optionFont = ' class="' + arrTxtOption[1] + '" ';
        optionFont += ' style="' + arrTxtOption[2] + '" ';

        insertTag = '<input class="input_check" type="checkbox" id="mField" value="' + idxControl.toString() + '" name="editorChk_' + idxControl.toString() + '" ' + optionAttr + ' />';
        insertTag += '<span ' + optionFont + '>Chk_1</span>';
    }
    else if ("radio" == argContNm) {   //Radio Button
        arrTxtOption[0] = $('#hdnRdoOptVal_0').val();  //checked
        arrTxtOption[1] = $('#hdnRdoOptVal_1').val();  //class
        arrTxtOption[2] = $('#hdnRdoOptVal_2').val();  //style

        if ("true" == arrTxtOption[0]) {
            optionAttr = ' checked';
        }

        optionFont = ' class="' + arrTxtOption[1] + '" ';
        optionFont += ' style="' + arrTxtOption[2] + '" ';

        insertTag = '<input class="input_check" type="radio" id="mField" value="' + idxControl.toString() + '" name="editorRdo_' + idxControl.toString() + '" ' + optionAttr + ' />';
        insertTag += '<span ' + optionFont + '>Rdo_1</span>';
    }
    else if ("select" == argContNm) {  //Select Box
        arrTxtOption[0] = $('#hdnSelOptVal_0').val();  //width
        arrTxtOption[1] = $('#hdnSelOptVal_1').val();  //key
        arrTxtOption[2] = $('#hdnSelOptVal_2').val();  //value

        var arrKey = new Array();
        var arrVal = new Array();

        if (-1 != arrTxtOption[1].indexOf('[|^|]') && -1 != arrTxtOption[2].indexOf('[|^|]')) {
            arrKey = arrTxtOption[1].split('[|^|]');
            arrVal = arrTxtOption[2].split('[|^|]');
        }
        else if ('' != arrTxtOption[1] && '' != arrTxtOption[2]) {
            arrKey[0] = arrTxtOption[1];
            arrVal[0] = arrTxtOption[2];
        }

        if ('' != arrTxtOption[0]) {
            optionAttr = ' style="width:' + arrTxtOption[0] + '; "';
        }

        insertTag = '<select id="mField" name="editorCbo_' + idxControl.toString() + '" ' + optionAttr + ' >';

        if (0 < arrKey.length) {
            insertTag += '<option value="0">Choose Item</option>';

            for (var i = 0; i < arrKey.length; i++) {
                if ('' != arrVal[i] && '' != arrKey[i]) {
                    insertTag += '<option value="' + arrVal[i] + '" >' + arrKey[i] + '</option>';
                }
            }
        }
        else {
            insertTag += '<option value="0">No Data</option>';
        }


        insertTag += '</select>';
    }

    arrTxtOption = null;
    twe.InsertHtml(insertTag);
    twe.focus();
}


function AddControl_Multi(argContNm, idx) {
    var twe = document.tbContentElement+idx;       //editor object
    var insertTag = '';                        //html control tag string
    var optionAttr = '';                       //html control option tag
    var optionFont = '';                       //check box and radio button text style, class

    //고유한 name 부여를 위한 index hidden value
    var editorForm = twe.GetDOM();
    if (null != editorForm.getElementById("hdnIdxCnt")) {
        var tmpIdx = editorForm.getElementById("hdnIdxCnt").value;
        idxControl = parseInt(tmpIdx);
        idxControl++;

        editorForm.getElementById("hdnIdxCnt").value = idxControl.toString();
    }
    else {
        twe.InsertHtml('<input type="hidden" id="hdnIdxCnt" value="1" />');
        idxControl++;
    }

    //해당 컨트롤 추가
    var arrTxtOption = new Array();
    if ("text" == argContNm) {         //Text Box
        arrTxtOption[0] = $('#hdnHtmlControlOptVal_0').val();  //width
        arrTxtOption[1] = $('#hdnHtmlControlOptVal_1').val();  //Height
        arrTxtOption[2] = $('#hdnHtmlControlOptVal_2').val();  //MultiLine
        arrTxtOption[3] = $('#hdnHtmlControlOptVal_3').val();  //Default Value
        arrTxtOption[4] = $('#hdnHtmlControlOptVal_4').val();  //class
        arrTxtOption[5] = $('#hdnHtmlControlOptVal_5').val();  //style

        optionAttr = ' style="width:' + arrTxtOption[0] + 'px; ';
        optionAttr += 'height:' + arrTxtOption[1] + 'px; ';
        optionAttr += arrTxtOption[5] + '"';
        optionAttr += ' class="' + arrTxtOption[4] + '"';

        if ('false' == arrTxtOption[2]) {  //TextBox
            optionAttr += ' value="' + arrTxtOption[3] + '"';
            insertTag = '<input type="text" id="mField" name="editorTxt_' + idxControl.toString() + '" ' + optionAttr + ' />';
        }
        else {                             //textarea
            insertTag = '<textarea id="mField" name="editorTxt_' + idxControl.toString() + '" ' + optionAttr + ' >' + arrTxtOption[3] + '</textarea>';
        }
    }
    else if ("check" == argContNm) {   //Check Box
        arrTxtOption[0] = $('#hdnChkOptVal_0').val();  //checked
        arrTxtOption[1] = $('#hdnChkOptVal_1').val();  //class
        arrTxtOption[2] = $('#hdnChkOptVal_2').val();  //style

        if ("true" == arrTxtOption[0]) {
            optionAttr = ' checked';
        }

        optionFont = ' class="' + arrTxtOption[1] + '" ';
        optionFont += ' style="' + arrTxtOption[2] + '" ';

        insertTag = '<input class="input_check" type="checkbox" id="mField" value="' + idxControl.toString() + '" name="editorChk_' + idxControl.toString() + '" ' + optionAttr + ' />';
        insertTag += '<span ' + optionFont + '>Chk_1</span>';
    }
    else if ("radio" == argContNm) {   //Radio Button
        arrTxtOption[0] = $('#hdnRdoOptVal_0').val();  //checked
        arrTxtOption[1] = $('#hdnRdoOptVal_1').val();  //class
        arrTxtOption[2] = $('#hdnRdoOptVal_2').val();  //style

        if ("true" == arrTxtOption[0]) {
            optionAttr = ' checked';
        }

        optionFont = ' class="' + arrTxtOption[1] + '" ';
        optionFont += ' style="' + arrTxtOption[2] + '" ';

        insertTag = '<input class="input_check" type="radio" id="mField" value="' + idxControl.toString() + '" name="editorRdo_' + idxControl.toString() + '" ' + optionAttr + ' />';
        insertTag += '<span ' + optionFont + '>Rdo_1</span>';
    }
    else if ("select" == argContNm) {  //Select Box
        arrTxtOption[0] = $('#hdnSelOptVal_0').val();  //width
        arrTxtOption[1] = $('#hdnSelOptVal_1').val();  //key
        arrTxtOption[2] = $('#hdnSelOptVal_2').val();  //value

        var arrKey = new Array();
        var arrVal = new Array();

        if (-1 != arrTxtOption[1].indexOf('[|^|]') && -1 != arrTxtOption[2].indexOf('[|^|]')) {
            arrKey = arrTxtOption[1].split('[|^|]');
            arrVal = arrTxtOption[2].split('[|^|]');
        }
        else if ('' != arrTxtOption[1] && '' != arrTxtOption[2]) {
            arrKey[0] = arrTxtOption[1];
            arrVal[0] = arrTxtOption[2];
        }

        if ('' != arrTxtOption[0]) {
            optionAttr = ' style="width:' + arrTxtOption[0] + '; "';
        }

        insertTag = '<select id="mField" name="editorCbo_' + idxControl.toString() + '" ' + optionAttr + ' >';

        if (0 < arrKey.length) {
            insertTag += '<option value="0">Choose Item</option>';

            for (var i = 0; i < arrKey.length; i++) {
                if ('' != arrVal[i] && '' != arrKey[i]) {
                    insertTag += '<option value="' + arrVal[i] + '" >' + arrKey[i] + '</option>';
                }
            }
        }
        else {
            insertTag += '<option value="0">No Data</option>';
        }


        insertTag += '</select>';
    }

    arrTxtOption = null;
    twe.InsertHtml(insertTag);
    twe.focus();
}

function SetControlOption(argType) {
    var l_url = "HtmlControlOption.aspx?cType=" + argType;
    var divHeight = "200px";
    var divWidth = "370px";

    if ("text" == argType) {         //Text Box
        divHeight = "290px";
    }
    else if ("check" == argType) {   //Check Box
        //설정 항목이 늘어나면 높이 변경
    }
    else if ("radio" == argType) {   //Radio Button
        //설정 항목이 늘어나면 높이 변경
    }
    else if ("select" == argType) {  //Select Box
        divHeight = "350px";
        divWidth = "390px";
    }

    Common.showDialog("", "divHtmlControlOption", "Select Control Option", l_url, divWidth, divHeight, "iframe");
}

function LoadEditor_Multi(elm, idx, doctype) {
	if(!doctype) doctype = "normal";

     $('#' + elm).html(LoadtweditorForApprovalMulti(idx, doctype)).append("<script language='javascript' for='" + g_id+idx + "' event='OnControlInit'>setTimeout('setEditor(" + idx + ")', 0);</script>");
}

function getBodyContextMulti() {
    var ret = {};
    
    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
        ret = {};
    } else {
    	try {
			$("[id^=tbContentElement]").each(function(idx, item){
	    		var strHTML = "";
				
				if (editortype.is('xfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject === undefined)) {
	            	if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		strHTML = coviEditor.getBody("xfree", 'tbContentElement' + (idx+1), true);
	            	} else {
	            		strHTML = coviEditor.getBody("xfree", 'tbContentElement' + (idx+1));
	            	}
	            } else if (editortype.is('tagfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject !== undefined)) {
	            	strHTML = document.getElementById("tbContentElement" + (idx+1)).HtmlValue;
	            } else if (editortype.is('crosseditor') || (editortype.is('activesquaredefault') && window.ActiveXObject === undefined)) {
	            	strHTML = document.getElementById("tbContentElement" + (idx+1)).GetBodyValue();
	            } else if (editortype.is('activesquare') || (editortype.is('activesquaredefault') && window.ActiveXObject !== undefined)) {
	            	strHTML = document.getElementById("tbContentElement" + (idx+1)).value;
	            } else if (editortype.is('textarea')) {
	            	strHTML = document.getElementById("tbContentElement" + (idx+1)).value;
	            } else if (editortype.is('dext5')) {
	            	if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		strHTML = coviEditor.getBody("dext5", 'tbContentElement' + (idx+1), true);
	            	} else {
	            		strHTML = coviEditor.getBody("dext5", 'tbContentElement' + (idx+1));
	            	}
	            } else if (editortype.is('cheditor')) {
	            	strHTML = document.getElementById('cheditorFrame').contentWindow.myeditor.getContents();
	            } else if (editortype.is('synap')) {
	            	if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		strHTML = coviEditor.getBody("synap", 'tbContentElement' + (idx+1), true);
	            	} else {
	            		strHTML = coviEditor.getBody("synap", 'tbContentElement' + (idx+1));
	            	}
	            } else if (editortype.is('ck')) {
	            	if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		strHTML = coviEditor.getBody("ck", 'tbContentElement' + (idx+1), true);
	            	} else {
	            		strHTML = coviEditor.getBody("ck", 'tbContentElement' + (idx+1));
	            	}
	            } else if (editortype.is('webhwpctrl')) {
	            	if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		strHTML = coviEditor.getBody("webhwpctrl", 'tbContentElement' + (idx+1), true);
	            	} else {
	            		strHTML = coviEditor.getBody("webhwpctrl", 'tbContentElement' + (idx+1));
	            	}
	            } else if (editortype.is('covieditor')) {
	            	if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		strHTML = coviEditor.getBody("covieditor", 'tbContentElement' + (idx+1), true);
	            	} else {
	            		strHTML = coviEditor.getBody("covieditor", 'tbContentElement' + (idx+1));
	            	}
	            }
				
				strHTML = Base64.utf8_to_b64(strHTML);
				
				if(strHTML == "") { //탭 비활성화 시 본문 로드되지 않아 추가
					strHTML = formJson.BodyData.SubTable1[idx].MULTI_BODY_CONTEXT_HTML;
				}
				
				$('#SubTable1 .multi-row').find('[name=MULTI_BODY_CONTEXT_HTML]').eq(idx).val(strHTML);
			});
    	} catch (e) {
    		throw new Error(e);
    	}
    	
        var sBodyContext = makeBodyContext();
        
        if(getInfo("SchemaContext.scDistribution.isUse") =="Y"){//문서유통 사용
        	sBodyContext = makeBodyContextDist();
        }

        ret = sBodyContext;
    }

    return ret;
}

function event_getDocHTML(dataresponseXML) {
    var xmlReturn = dataresponseXML;
    var errorNode = $(xmlReturn).find("response > error");
    if (errorNode.length > 0) {
        alert("AttachImage ERROR : " + errorNode[0].text);
        return;
    } else {
        document.getElementById("dhtml_body").value = $(xmlReturn).find("response > htmldata").text();
    }
}

function UpdateImageDataMulti(obj, idx) {
    gz_Editor = editortype.is();
    var nfolder = "IMAGEATTACH";
    var n = -1;

    n = hidContentHtml.indexOf('file:///');

    if (n > 0) {
        if (hidContentMime != "") {
            // frontstorage에 있는 이미지를 BackStorage\Approval 로 이동
            var szRequestXml = "<?xml version='1.0'?>" +
								"<parameters>" +
									"<BodyContent><![CDATA[" + hidContentHtml + "]]></BodyContent>" +
									"<EditorContent><![CDATA[" + hidContentMime + "]]></EditorContent>" +
									"<ImageContent><![CDATA[" + hidContentImage + "]]></ImageContent>" +
									"<fiid><![CDATA[" + getInfo("FormInfo.FormID") + "]]></fiid>" +
									"<itemnum><![CDATA[" + "]]></itemnum>" +
                                "</parameters>";
            CFN_CallAjax("/WebSite/Approval/FileAttach/BodyImgMoveBAckStorageHWP.aspx", szRequestXml, function (data) {
                event_attchSyncMulti(data, obj, idx);
            }, false, "xml");
        }
    }
}

//=== 여기서 부터 새로 생성
//에디터 모드
function SetHwpEditMode(MultiCtrl, sMode) {
    var sKind;
    switch (sMode) {
        case "read": sKind = 0; break; //읽기 전용
        case "edit": sKind = 1; break; //입력
        case "form": sKind = 2; break; //양식폼 - 누름틀만 활성화
        default:
            sKind = 0; break; //읽기 전용
    }
    MultiCtrl.EditMode = sKind;
}

function CFN_GetQueryString(pParamName) {
	var _QureyObject = {};
	if (_QureyObject[pParamName] == "undefined" || _QureyObject[pParamName] == null) {
		var queryString = location.search.replace('?', '').split('&');
		for (var i = 0; i < queryString.length; i++) {
			var name = queryString[i].split('=')[0];
			var value = queryString[i].split('=')[1];
			_QureyObject[name] = value;
		}
		if (_QureyObject[pParamName] == "undefined" || _QureyObject[pParamName] == null) {
			return "undefined";
		} else {
			try {
				return _QureyObject[pParamName];
			} finally {
				_QureyObject = null;
			}
		}
	} else {
		try {
			return _QureyObject[pParamName];
		} finally {
			_QureyObject = null;
		}
	}
}