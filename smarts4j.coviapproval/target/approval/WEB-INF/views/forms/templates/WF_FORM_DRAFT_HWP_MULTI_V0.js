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

function postRenderingForTemplate() {
    //debugger;
    //공통영역
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        LoadEditorHWP('divWebEditorContainer');

        try {
            HwpCtrl = document.getElementById("tbContentElement");
            if(HwpCtrl == undefined || HwpCtrl.length == 0) {
            	HwpCtrl = document.getElementById("tbContentElementFrame").contentWindow.HwpCtrl;
            } else {
            	HwpCtrl.RegisterModule("FilePathCheckDLL", "FilePathCheckerModuleCovision");
            }

            if (getInfo("Request.loct") != "REJECT" && getInfo("Request.loct") != "DRAFT") {
                document.getElementById("INITIATOR_DATE_INFO2").innerHTML = formatDate(formJson.AppInfo.COMPLETED_DATE, "D2"); //TODO: INITIATOR_DATE_INFO2? COMPLETED_DATE?
            } else {
                document.getElementById("TEMP_DOC_NO").innerHTML = "";
            }
        } catch (e) { coviCmn.traceLog(e); }

        //stField -> mField로 변경 해당 구문 필요 X
        /*if (formJson.BodyData != null && formJson.BodyData.SubTable1 != null && formJson.BodyData.SubTable1 != "") {
            var dataObj = removeSeperatorForMultiRow(formJson.BodyData.SubTable1);
            $(dataObj).each(function (i, item) {
                $("input[type='hidden'][name='ST_DOCTYPE']").val($(item)[0].ST_DOCTYPE);
                $("input[type='hidden'][name='ST_DOCNO']").val($(item)[0].ST_DOCNO);
                $("input[type='hidden'][name='ST_DESTINATION_DP']").val($(item)[0].ST_DESTINATION_DP);
                $("input[type='hidden'][name='ST_CC_DP']").val($(item)[0].ST_CC_DP);
                $("input[type='hidden'][name='ST_SEND_DP']").val($(item)[0].ST_SEND_DP);
                $("input[type='hidden'][name='ST_SUBJECT']").val($(item)[0].ST_SUBJECT);
                $("input[type='hidden'][name='ST_ATTACH_FILE_INFO']").val($(item)[0].ST_ATTACH_FILE_INFO);
                $("input[type='hidden'][name='ST_DOCLINKS']").val($(item)[0].ST_DOCLINKS);
                $("input[type='hidden'][name='ST_RECEIVE_NAMES']").val($(item)[0].ST_RECEIVE_NAMES);
                $("input[type='hidden'][name='ST_RECEIPT_LIST']").val($(item)[0].ST_RECEIPT_LIST);
                $("input[type='hidden'][name='ST_RECLINEOPD']").val($(item)[0].ST_RECLINEOPD);
                $("input[type='hidden'][name='ST_RECLINEOPDEDIT']").val($(item)[0].ST_RECLINEOPDEDIT);
                $("input[type='hidden'][name='ST_PROCESS_ID']").val($(item)[0].ST_PROCESS_ID);
                $("input[type='hidden'][name='ST_HWPDATA']").val($(item)[0].ST_HWPDATA);
                $("input[type='hidden'][name='ST_DOCNOREC']").val($(item)[0].ST_DOCNOREC);
                $("input[type='hidden'][name='ST_RESERVEDSTR_1']").val($(item)[0].ST_RESERVEDSTR_1);
                $("input[type='hidden'][name='ST_RESERVEDSTR_2']").val($(item)[0].ST_RESERVEDSTR_2);
                $("input[type='hidden'][name='ST_RESERVEDSTR_3']").val($(item)[0].ST_RESERVEDSTR_3);
                $("input[type='hidden'][name='ST_RESERVEDSTR_4']").val($(item)[0].ST_RESERVEDSTR_4); 
            });
        }*/
        
    	setItemNumber();
    }
    else {
        document.getElementById("tbInitiatorInfo").style.display = "";

        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        LoadEditorHWP('divWebEditorContainer');
        
        setItemNumber();
        
        if (formJson.Request.mode == "DRAFT") {
            var dateformat = document.getElementById("AppliedDate").value.replace(/([0-9]{4})-([0-9]{2})-([0-9]{2})/, "$1.$2.$3");
            document.getElementById("InitiatedDate").innerHTML = dateformat;
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("INITIATOR_DATE_INFO2").value = formatDate(formJson.AppInfo.svdt, "D").substring(0,5); // 재사용, 임시함에서 오늘날짜로 들어가게함.

            document.getElementById("INITIATOR_TEL").value = formJson.AppInfo.ustp;
            document.getElementById("INITIATOR_FAX").value = formJson.AppInfo.usfx;
            
            //TODO: Manager 구하는 aspx.cs -> controller로 변경 필요
            /*try {
                if (formJson.AppInfo.dpid_apv != null && formJson.AppInfo.dpid_apv != "") {
                    var szRequestXml = "<?xml version='1.0'?>" +
                                        "<parameters>" +
                                            "<dpid><![CDATA[" + formJson.AppInfo.dpid_apv + "]]></dpid>" +
                                        "</parameters>";
                    CFN_CallAjax("/WebSite/Approval/GetXMLManager.aspx", szRequestXml, function (data) { //TODO: GetXMLManager 구현
                        event_GetXMLManager(data);
                    }, false, "xml");
                }
            } catch (e) {
            }*/
            
            document.getElementById("INITIATOR_DEPT").value = m_oFormMenu.getLngLabel(formJson.AppInfo.dpdn_apv, false);
            document.getElementById("INITIATOR_CHARGE").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usdn, false);
            document.getElementById("INITIATOR_EMAIL").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usem, false);
            
            if (formJson.AppInfo.dpid_apv == "100990000") {
            	document.getElementById("MEMO").value = "노 사 발 전 위 원﹧";
            } else if (formJson.AppInfo.dpid_apv == "1584") {
            	document.getElementById("MEMO").value = "특허정보진흥센터소";
            } else {
                document.getElementById("MEMO").value = m_oFormMenu.getLngLabel(formJson.AppInfo.dpdn_apv, false);
            }
            try { document.getElementById("TEMP_DOC_NO").value = formJson.AppInfo.dpdn_apv + formatDate(formJson.AppInfo.svdt, "S").substring(2, 4); } catch (e) { coviCmn.traceLog(e); }
            
            document.getElementById("ST_DOCTYPE").value = "1"; //1: 대내문서, 2: 대외문서
            document.getElementById("ST_RESERVEDSTR_1").value = "공개"; //공개, 부분공개, 비공개
            document.getElementById("ST_RESERVEDSTR_2").value = "1등급"; //1~9 등급

        } else if (formJson.Request.mode == "TEMPSAVE") {
        	document.getElementById("INITIATOR_DATE_INFO2").value = formatDate(formJson.AppInfo.svdt, "D").substring(0, 5);
        	try { document.getElementById("TEMP_DOC_NO").value = formJson.AppInfo.dpdn_apv + formatDate(formJson.AppInfo.svdt, "S").substring(2, 4); } catch (e) { coviCmn.traceLog(e); }
        }
        
        //stField -> mField로 변경 해당 구문 필요 X
        /*if (formJson.BodyData != null && formJson.BodyData.SubTable1 != null && formJson.BodyData.SubTable1 != "") {
            var dataObj = removeSeperatorForMultiRow(formJson.BodyData.SubTable1);
            $(dataObj).each(function (i, item) {
                $("input[type='hidden'][name='ST_DOCTYPE']").val($(item)[0].ST_DOCTYPE);
                $("input[type='hidden'][name='ST_DOCNO']").val($(item)[0].ST_DOCNO);
                $("input[type='hidden'][name='ST_DESTINATION_DP']").val($(item)[0].ST_DESTINATION_DP);
                $("input[type='hidden'][name='ST_CC_DP']").val($(item)[0].ST_CC_DP);
                $("input[type='hidden'][name='ST_SEND_DP']").val($(item)[0].ST_SEND_DP);
                $("input[type='hidden'][name='ST_SUBJECT']").val($(item)[0].ST_SUBJECT);
                $("input[type='hidden'][name='ST_ATTACH_FILE_INFO']").val($(item)[0].ST_ATTACH_FILE_INFO);
                $("input[type='hidden'][name='ST_DOCLINKS']").val($(item)[0].ST_DOCLINKS);
                $("input[type='hidden'][name='ST_RECEIVE_NAMES']").val($(item)[0].ST_RECEIVE_NAMES);
                $("input[type='hidden'][name='ST_RECEIPT_LIST']").val($(item)[0].ST_RECEIPT_LIST);
                $("input[type='hidden'][name='ST_RECLINEOPD']").val($(item)[0].ST_RECLINEOPD);
                $("input[type='hidden'][name='ST_RECLINEOPDEDIT']").val($(item)[0].ST_RECLINEOPDEDIT);
                $("input[type='hidden'][name='ST_PROCESS_ID']").val($(item)[0].ST_PROCESS_ID);
                $("input[type='hidden'][name='ST_HWPDATA']").val($(item)[0].ST_HWPDATA);
                $("input[type='hidden'][name='ST_DOCNOREC']").val($(item)[0].ST_DOCNOREC);
                $("input[type='hidden'][name='ST_RESERVEDSTR_1']").val($(item)[0].ST_RESERVEDSTR_1);
                $("input[type='hidden'][name='ST_RESERVEDSTR_2']").val($(item)[0].ST_RESERVEDSTR_2);
                $("input[type='hidden'][name='ST_RESERVEDSTR_3']").val($(item)[0].ST_RESERVEDSTR_3);
                $("input[type='hidden'][name='ST_RESERVEDSTR_4']").val($(item)[0].ST_RESERVEDSTR_4); 
            });
        } else {
        }*/
    }

}

/*function event_GetXMLManager(dataresponseXML) {
    var xmlReturn = dataresponseXML;
    var errorNode = $(xmlReturn).find("response > error");
    if (errorNode.length > 0) {
        alert("Manager Info ERROR : " + errorNode[0].text);
        return;
    } else {
    	var sMGTI = "";
    	var sMGSIGN = "";
    	if (formJson.AppInfo.dpid == "100990000") {
    		sMGTI = "위원장";
    		sMGSIGN = "stamp2.jpg";
    	} else {
    		sMGTI = m_oFormMenu.getLngLabel($(xmlReturn).find("response > mgti").text().replace("&", ";"), true);
    		sMGSIGN = $(xmlReturn).find("response > mgrs").text();
    	}
    	document.getElementById("InitiatorMgr").value = sMGTI + " " + m_oFormMenu.getLngLabel($(xmlReturn).find("response > mgnm").text(), false);
    	document.getElementById("InitiatorMgrSign").value = sMGSIGN;
    }
}*/

function setLabel() {

}
function setFormInfoDraft() {

}

function checkForm(bTempSave) {
    if (bTempSave) {
    	if ($(objEditor)[0].MoveToField("SUBJECT")) {
	    	if ($(objEditor)[0].GetFieldText("SUBJECT") == "") {
	            var subject = CFN_GetDicInfo(getInfo("AppInfo.usnm")) + " - " + getInfo("FormInfo.FormName");
	            fnPutFieldText(iSelIdx, 'SUBJECT', subject);
	    	}
    	}
        return true;
    } else {
    	if (getInfo("Request.mode") == "DEPTDRAFT") {
    		return true;
    	} else {
    		var objEditor = $("#tbContentElement");
        	//[2016.09.09] 2MB 사이즈 제한 경고문 끝
            if ($(objEditor)[0].MoveToField("SUBJECT")) {
                document.getElementById("Subject").value = $(objEditor)[0].GetFieldText("SUBJECT");
            }
            if (document.getElementById("Subject").value == '') {
                Common.Warning('제목을 입력하세요.');
                //SUBJECT.focus();
                return false;
            }
            //필수 입력 필드 체크
            return EASY.check().result;
        }
    }
}


function setItemNumber() {
	createTableArea(0, "MASTERSIGN");
    if (formJson.AppInfo.dpid_apv == "100990000") {
    	fnPutFieldText(0, 'MEMO', "노 사 발 전 위 원﹧");
    } else if (formJson.AppInfo.dpid_apv == "1584") {
    	fnPutFieldText(0, 'MEMO', "특허정보진흥센터소");
    } else {
        fnPutFieldText(0, 'MEMO', m_oFormMenu.getLngLabel(formJson.AppInfo.dpdn_apv, false));
    }
    
    try {
        fnPutFieldText(0, 'RecLine_DP', "내부결재");
        fnPutFieldText(0, 'ITEMHEAD1AREA', " ");
    } catch (e) { coviCmn.traceLog(e); }
}

function setBodyContext(sBodyContext) {

}

//본문 XML로 구성
function makeBodyContext() {
    var bodyContextObj = {};
    var editorContent = {"tbContentElement" : document.getElementById("dhtml_body").value};
	
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
    return bodyContextObj;
}