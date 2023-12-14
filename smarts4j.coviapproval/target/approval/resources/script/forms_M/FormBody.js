var g_szAcceptLang = "ko";
var m_oApvList;
var m_oRecList;
var sReceiveNo = "";
var g_BaseImgURL = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + "e-sign/ApprovalSign/BackStamp/";
var g_BaseFormURL = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + "e-sign/ApprovalForm/"; // 사용안함
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

// 에디터 유형 정의
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

/*******************************************/
//****** 양식 파일 내 공통 함수 정리 시작 *****
/********************************************/

// window.onload = initOnloadformedit;
function initOnloadformedit() {
    initialize();
}

function initialize() {
	// [2015-09-01 add] 기본 가로크기 유지
	if (!_mobile) {
		var vwidth = 790;
		$("form[id='menu']").css('min-width', vwidth - 20);
		$("#divMenu").closest("div").css('min-width', vwidth - 70);
		//$("#divMenu02").css('min-width', vwidth - 70);
	}

    //초기화
    initForm();

    //2012차기버전작업 : 결재선 함수 호출이 중복으로 호출 하여 수정함.
    if (getInfo("Request.mode") == "DRAFT"
            || getInfo("Request.mode") == "TEMPSAVE"
            || ((getInfo("Request.loct") == "APPROVAL" || getInfo("Request.loct") == "REDRAFT") && getInfo("Request.mode") == "REDRAFT")
            || (getInfo("Request.loct") == "REDRAFT" && getInfo("Request.mode") == "SUBREDRAFT" && getInfo("SchemaContext.scRecAssist.isUse") == "Y") //부서협조일경우 수신부서에서 열었을때 접수사용으로 되어 있으면 결재선을 그려 줘야함
        ) {

        if (getInfo("Request.reuse") != "P"
            && openMode != "W"
            && (getInfo("Request.editmode") != 'Y' || (getInfo("Request.editmode") == 'Y' && getInfo("Request.reuse") == "Y"))) {

            //설정된 결재선 가져오기
            //setDomainData();
        }
        else {
            //결재선 그리기
            initApvList();
        }
    } else {
        //결재선 그리기
        initApvList();
    }

    /*비사용
     * if (getInfo("legacydata") != "") {
        fnLegacy();
    }*/

}

function initForm() {

    initFields();
    //첨부쪽 처리
    /*G_displaySpnAttInfo(false);*/
    formDisplaySetFileInfo();

    //2012차기버전작업
    //2012차기버전작업
    //연결문서 관련
    try { G_displaySpnDocLinkInfo(); } catch (e) { mobile_comm_log(e); }
    
    /*비사용 - 프로세스 메뉴얼 기능 제외
     * try { if (getInfo("scPM") == "1") G_displaySpnPMLinkInfo((getInfo("scPMV") == "" ? null : getInfo("scPMV"))); } catch (e) { }*/

}

//에디터 타입 참조방식 변경 : KJW : 2014-04-23 : XFROM PRJ.
//읽기 / 쓰기 통합으로 수정
function initFields(szBody) {
    //debugger;

    //공통 처리 상단 시작
    if (typeof window.setLabel == "function") {
        setLabel()
    };

    setFields("dField");
    setFields("cField");

    //공통 처리 상단 끝

    //쓰기인 경우 시작
    if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") {
    	//lka 휴직서의 경우는 양식명이 텍스트가 아니라 select box라서 if문으로 아래 구문 제외시킴 20121121
        if (getInfo("FormInfo.FormPrefix") != "WF_FORM_LEAVE") {
            //양식명 옆의 버튼이 여기는 false, 양식별 template에서는 true 확인이 필요.
            //document.getElementById("headname").innerHTML = initheadname(getInfo("FormInfo.FormName"), false);
        	document.getElementById("headname").innerHTML = CFN_GetDicInfo(getInfo("FormInfo.FormName"));
        }

        /*document.getElementById("INITIATOR_INFO").value = getInfo("AppInfo.usnm");*/
        document.getElementById("AppliedDate").value = getInfo("AppInfo.svdt"); //formatDate(getInfo("AppInfo.svdt"), "D");

        //개별 양식 후처리로 이동
        //양식별 추가 정보 초기화
        //해당 함수가 존재하는지 확인 후 실행 : KJW : 2014.02.022 : XFORM PRJ.
        if (typeof setFormInfoDraft === 'function') {
            setFormInfoDraft();
        }

        //본문 내용
        //에디터 처리 별도 함수 구성 setEditor
        /*
        if (editortype.is('tagfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject !== undefined)) {

            if (document.getElementById("tbContentElement") == null) {
                if (getInfo("BodyContext") != undefined) {
                    setBodyContext(getInfo("BodyContext"));
                } else {
                    setBodyContext(getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8"));
                }
            }
        } else if (editortype.is('crosseditor') || (editortype.is('activesquaredefault') && window.ActiveXObject === undefined)) {

        }else {
        */ 
            if (getInfo("BodyContext") != undefined) {
                setBodyContext(getInfo("BodyContext"));
            } else {
                setBodyContext(getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8"));
            }
        /*}*/

    }//쓰기인 경우 끝
        //읽기인 경우 시작
    else {
        //settFields("tField");

        //document.getElementById("Subject").value = getInfo("FormInstanceInfo.Subject");
        //[2016-07-16] kimjh 미리보기시 <u>태그 삭제
    	document.getElementById("headname").innerHTML = CFN_GetDicInfo(getInfo("FormInfo.FormName"));

        //본문 내용
        /*
        if (getInfo("BodyContext") != undefined) {
            setBodyContext(getInfo("BodyContext"));
        } else {
            if (getInfo("FormInfo.BodyDefault") != "undefined") {
                setBodyContext(getInfo("FormInfo.BodyDefault"));
            }
        }
        */

    }//읽기인 경우 끝


    //하단 용도 불분명 확인 요
    /*
    if (getInfo("Request.reuse") == "P") {
        if (getInfo("BodyContext") != undefined) {
            setBodyContext(getInfo("BodyContext"));
        }
    }
    */


}

// initfields()에서 함수 존부를 체크하므로 setFormInfoDraft() 함수를 제거
// KJW : 2014.04.23 : XFORM PRJ.

function setTagFreeBug() {
    if (getInfo("BodyContext") != undefined) {     //기안,임시저장으로 저장된 값 setting        
        setBodyContext(getInfo("BodyContext"));
        try { G_displaySpnDocLinkInfo(); } catch (e) { mobile_comm_log(e); }
    } else {//양식 생성 시 입력한 본문내역 조회            
        if (getInfo("FormInfo.BodyDefault") != "undefined") {
            try { var dom = tbContentElement.getDom(); dom.body.innerHTML = getInfo("FormInfo.BodyDefault"); } catch (e) { mobile_comm_log(e); }
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

// editor type 참조 방법 수정 : KJW : 2014.04.23 : XFORM PRJ.
/*** 데이터 뿌려주기 - Value ***/
function innerHtmlData(nodeNm, nodeVal) {
    var dom;
    var commonEditorType = Common.getBaseConfig("EditorType");
    //쓰기 모드인 경우
    if (getInfo("Request.templatemode") == "Write") {

        if (document.getElementsByName(nodeNm)[0] != undefined) {
            // 첨부 처리
            // setForm_Attach 정의한 함수가 없음 아래 주석 처리
            /*
            if (nodeNm.indexOf("FORM_ATTACH") != -1) {
                setForm_Attach(nodeVal);
                document.getElementsByName(nodeNm)[0].value = nodeVal;
            }
            */
            // Radio 처리
            if (nodeNm.indexOf("OPT") != -1 || nodeNm.indexOf("RDO") != -1 || nodeNm.indexOf("RDV") != -1) {
                setRadio(nodeNm, nodeVal);
            }
                // checkbox 처리
            else if (nodeNm.indexOf("CHK") != -1) {
                setChk(nodeNm, nodeVal);
            }
                // 에디터 처리
            else if (nodeNm.indexOf("tbContentElement") != -1) {
                switch (commonEditorType) {
                    case editortypes['textarea']:
                        document.getElementById("txtareaBody").value = nodeVal;
                        break;
                    case editortypes['dhtml']: break;
                    case editortypes['tagfree']:
                        dom = document.tbContentElement.getDom();
                        dom.body.innerHTML = nodeVal.replace(/<br \/>/gi, "");
                        break;
                    case editortypes['xfree']:
                        tbContentElement.SetHtmlValue(nodeVal);
                        break;
                    case editortypes['tagfreenxfree']:
                        if (_ie) {
                            dom = document.tbContentElement.getDom();
                            dom.body.innerHTML = nodeVal.replace(/<br \/>/gi, "");
                        } else { tbContentElement.SetHtmlValue(nodeVal); }
                        break;
                    case editortypes['activesquare']:
                        document.tbContentElement.value = nodeVal;
                        break;
                    case editortypes["covieditor"]:
                        tbContentElement.setContent(nodeVal);
                        break;
                }
            }
                //이외의 후처리가 필요한 mField
            else {
                document.getElementsByName(nodeNm)[0].value = nodeVal;
            }
        }
        else {
            if (nodeNm.indexOf("tbContentElement") != -1) {
                switch (commonEditorType) {
                    case editortypes['textarea']:
                        document.getElementById("txtareaBody").value = nodeVal;
                        break;
                    case editortypes['dhtml']:
                        break;
                    case editortypes['tagfree']:
                        dom = document.tbContentElement.getDom();
                        dom.body.innerHTML = nodeVal.replace(/<br \/>/gi, "");
                        break;
                    case editortypes['xfree']:
                        tbContentElement.SetHtmlValue(nodeVal);
                        break;
                    case editortypes['tagfreenxfree']:
                        if (_ie) {
                            dom = document.tbContentElement.getDom();
                            dom.body.innerHTML = nodeVal.replace(/<br \/>/gi, "");
                        } else { tbContentElement.SetHtmlValue(nodeVal); }
                        break;
                    case editortypes['activesquare']: document.tbContentElement.value = nodeVal;
                        break;
                    case editortypes["covieditor"]:
                        tbContentElement.setContent(nodeVal);
                        break;
                }
            }
        }
    }
        // 읽기 모드인 경우
    else {
        if (document.getElementById(nodeNm) != undefined) {
            // radio
            if (nodeNm.indexOf("OPT") != -1) {
                setRadio(nodeNm, nodeVal);
            }
                // radio read
            else if (nodeNm.indexOf("RDO") != -1) {
                setRadioRead(nodeNm, nodeVal);
            }
                // 첨부, 주석처리
                /*
                else if (nodeNm.indexOf("FORM_ATTACH") != -1) {
                    setForm_Attach(nodeVal);
                }
                */
                // 에디터
            else if (nodeNm.indexOf("tbContentElement") != -1) {
                $("#tbContentElement").html(nodeVal); //.replace(/\n/gi, "<br \/>")
            }
                // 체크박스
            else if (nodeNm.indexOf("CHK") != -1) {
                setChkRead(nodeNm, nodeVal);
            } else {

                // 서버바인딩 테스트시 아래 주석 처리(2014-02-24 leesh)
                try {
                    document.getElementById(nodeNm).innerHTML = nodeVal.replace(/\n/gi, "<br \/>");
                } catch (e) {
                    document.getElementById(nodeNm).value = nodeVal;
                }
            }
        } else if (nodeNm.indexOf("RDV") != -1) {
            setRadioValueRead(nodeNm, nodeVal);
        }
    }
}

// editor data 처리를 위한 함수 추가
function setEditor() {
    //debugger;
    var dom;
    var commonEditorType = Common.getBaseConfig("EditorType");
    //쓰기 모드인 경우
    if (getInfo("Request.templatemode") == "Write") {

        switch (commonEditorType) {
            case editortypes['textarea']:
            	if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {
            		if (formJson.BodyContext.tbContentElement["#cdata-section"]) {
            			document.getElementById("txtareaBody").value = formJson.BodyContext.tbContentElement["#cdata-section"].replace(/<br \/>/gi, "").replace(/\\n/gi, "");
            		} else {
            			document.getElementById("txtareaBody").value = formJson.BodyContext.tbContentElement.replace(/<br \/>/gi, "").replace(/\\n/gi, "");
            		}
                } else {
                    if (getInfo("FormInfo.BodyDefault") != undefined) {
                        document.getElementById("txtareaBody").value = Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault"));	//getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8").replace(/\\n/gi, "");
                    }
                }
                break;
            case editortypes['dhtml']: break;
            case editortypes['tagfree']:
                if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {     //기안,임시저장으로 저장된 값 setting
                    dom = document.tbContentElement.getDom();
                	//dom.body.innerHTML = formJson.BodyContext.tbContentElement["#cdata-section"].replace(/<br \/>/gi, "").replace(/\\n/gi, "");
                    if (formJson.BodyContext.tbContentElement["#cdata-section"]) {
                    	document.getElementById('tbContentElement').HtmlValue = formJson.BodyContext.tbContentElement["#cdata-section"].replace(/<br \/>/gi, "").replace(/\\n/gi, "");
                    } else {
                    	document.getElementById('tbContentElement').HtmlValue = formJson.BodyContext.tbContentElement.replace(/<br \/>/gi, "").replace(/\\n/gi, "");
                    }
                    try { G_displaySpnDocLinkInfo(); } catch (e) { mobile_comm_log(e); }

                } else {//양식 생성 시 입력한 본문내역 조회            
                    if (getInfo("FormInfo.BodyDefault") != undefined) {
                        try {
                            var dom = document.tbContentElement.getDom();
                            //dom.body.innerHTML = getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8").replace(/\\n/gi, "");
                            document.getElementById('tbContentElement').HtmlValue = Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault"));	//getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8").replace(/\\n/gi, "");
                        } catch (e) { mobile_comm_log(e); }
                    }
                }
                //if (document.tbContentElement.ActiveTab > 0) window.setTimeout(setTagFreeBug, 500);
                break;
            case editortypes['xfree']:

            	if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {
            		if (formJson.BodyContext.tbContentElement["#cdata-section"]) {
            			document.getElementById('xFreeFrame').contentWindow.tbContentElement.setHtmlValue(formJson.BodyContext.tbContentElement["#cdata-section"].replace(/\\n/gi, ""));
            		} else {
            			document.getElementById('xFreeFrame').contentWindow.tbContentElement.setHtmlValue(formJson.BodyContext.tbContentElement.replace(/\\n/gi, ""));
            		}
                    try { G_displaySpnDocLinkInfo(); } catch (e) { mobile_comm_log(e); }
                } else {
                    if (getInfo("FormInfo.BodyDefault") != undefined) {
                        try {
                            document.getElementById('xFreeFrame').contentWindow.tbContentElement.setHtmlValue(Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault"))); //(getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8").replace(/\\n/gi, ""));
                        } catch (e) { mobile_comm_log(e); }
                    }
                }

                break;
            case editortypes['tagfreenxfree']:
                if (_ie) {
                    if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {     //기안,임시저장으로 저장된 값 setting
                        dom = document.tbContentElement.getDom();
                    	//dom.body.innerHTML = formJson.BodyContext.tbContentElement["#cdata-section"].replace(/<br \/>/gi, "").replace(/\\n/gi, "");
                        if (formJson.BodyContext.tbContentElement["#cdata-section"]) {
                        	document.getElementById('tbContentElement').HtmlValue = formJson.BodyContext.tbContentElement["#cdata-section"].replace(/<br \/>/gi, "").replace(/\\n/gi, "");
                        } else {
                        	document.getElementById('tbContentElement').HtmlValue = formJson.BodyContext.tbContentElement.replace(/<br \/>/gi, "").replace(/\\n/gi, "");
                        }
                        try { G_displaySpnDocLinkInfo(); } catch (e) { mobile_comm_log(e); }

                    } else {//양식 생성 시 입력한 본문내역 조회            
                        if (getInfo("FormInfo.BodyDefault") != undefined) {
                            try {
                                var dom = document.tbContentElement.getDom();
                                //dom.body.innerHTML = getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8").replace(/\\n/gi, "");
                                document.getElementById('tbContentElement').HtmlValue = Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault"));	//getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8").replace(/\\n/gi, "");
                            } catch (e) { mobile_comm_log(e); }
                        }
                    }
                    //if (document.tbContentElement.ActiveTab > 0) window.setTimeout(setTagFreeBug, 500);
                } else {
                	if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {
                		if (formJson.BodyContext.tbContentElement["#cdata-section"]) {
                			document.getElementById('xFreeFrame').contentWindow.tbContentElement.setHtmlValue(formJson.BodyContext.tbContentElement["#cdata-section"].replace(/\\n/gi, ""));
                		} else {
                			document.getElementById('xFreeFrame').contentWindow.tbContentElement.setHtmlValue(formJson.BodyContext.tbContentElement.replace(/\\n/gi, ""));
                		}
                        try { G_displaySpnDocLinkInfo(); } catch (e) { mobile_comm_log(e); }
                    } else {
                        if (getInfo("FormInfo.BodyDefault") != undefined) {
                            try {
                                document.getElementById('xFreeFrame').contentWindow.tbContentElement.setHtmlValue(Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault")));		//(getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8").replace(/\\n/gi, ""));
                            } catch (e) { mobile_comm_log(e); }
                        }
                    }
                }
                break;
            case editortypes['activesquare']:
            	if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {
            		if (formJson.BodyContext.tbContentElement["#cdata-section"]) {
            			document.tbContentElement.value = formJson.BodyContext.tbContentElement["#cdata-section"].replace(/<br \/>/gi, "").replace(/\\n/gi, "");
            		} else {
            			document.tbContentElement.value = formJson.BodyContext.tbContentElement.replace(/<br \/>/gi, "").replace(/\\n/gi, "");
            		}
                } else {
                    if (getInfo("FormInfo.BodyDefault") != undefined) {
                        document.tbContentElement.value = Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault"));	//getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8").replace(/\\n/gi, "");
                    }
                }
                break;
            case editortypes['dext5']:
            	// TODO: DEXT5 Test by Kyle 2015-07-30     
				try{
					
                if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {
                	if (formJson.BodyContext.tbContentElement["#cdata-section"]) {
                		coviEditor.setBody("dext5", 'tbContentElement', formJson.BodyContext.tbContentElement["#cdata-section"].replace(/\\n/gi, ""));
                		//document.getElementById('dext5Frame').contentWindow.DEXT5.setBodyValue(formJson.BodyContext.tbContentElement["#cdata-section"].replace(/\\n/gi, ""), 'dext5editor');
                	} else {
                		coviEditor.setBody("dext5", 'tbContentElement', formJson.BodyContext.tbContentElement.replace(/\\n/gi, ""));
                		//document.getElementById('dext5Frame').contentWindow.DEXT5.setBodyValue(formJson.BodyContext.tbContentElement.replace(/\\n/gi, ""), 'dext5editor');
                	}
                    try { G_displaySpnDocLinkInfo(); } catch (e) { mobile_comm_log(e); }
                } else {
                    if (getInfo("FormInfo.BodyDefault") != undefined) {
                    	coviEditor.setBody("dext5", 'tbContentElement', Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault")));
                            //document.getElementById('dext5Frame').contentWindow.DEXT5.setBodyValue(Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault")), 'dext5editor');		//(getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8").replace(/\\n/gi, ""), 'dext5editor');
                    }
                }
				} catch (e) {
					setTimeout("setEditor()", 100);
				}
                break;
            case editortypes['cheditor']:
                // TODO: ChEditor Test by Kyle 2015-08-04                
            	if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {
            		if (formJson.BodyContext.tbContentElement["#cdata-section"]) {
            			document.getElementById('cheditorFrame').contentWindow.myeditor.loadContents(formJson.BodyContext.tbContentElement["#cdata-section"].replace(/\\n/gi, ""));
            		} else {
            			document.getElementById('cheditorFrame').contentWindow.myeditor.loadContents(formJson.BodyContext.tbContentElement.replace(/\\n/gi, ""));
            		}

                    try { G_displaySpnDocLinkInfo(); } catch (e) { mobile_comm_log(e); }
                } else {
                    if (getInfo("FormInfo.BodyDefault") != undefined) {
                        try {
                            document.getElementById('cheditorFrame').contentWindow.myeditor.loadContents(Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault")));		//(getInfo("FormInfo.BodyDefault").replace("euc-kr", "utf-8").replace(/\\n/gi, ""));
                        } catch (e) { mobile_comm_log(e); }
                    }
                }
                break;
            case editortypes['synap']:  
				try{
					
                if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {
                	if (formJson.BodyContext.tbContentElement["#cdata-section"]) {
                		coviEditor.setBody("synap", 'tbContentElement', formJson.BodyContext.tbContentElement["#cdata-section"].replace(/\\n/gi, ""));
                	} else {
                		coviEditor.setBody("synap", 'tbContentElement', formJson.BodyContext.tbContentElement.replace(/\\n/gi, ""));
                	}
                    try { G_displaySpnDocLinkInfo(); } catch (e) { mobile_comm_log(e); }
                } else {
                    if (getInfo("FormInfo.BodyDefault") != undefined) {
                    	coviEditor.setBody("synap", 'tbContentElement', Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault")));
                    }
                }
				} catch (e) {
					setTimeout("setEditor()", 100);
				}
                break;
            case editortypes['ck']:  
				try{
					
                if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {
                	if (formJson.BodyContext.tbContentElement["#cdata-section"]) {
                		coviEditor.setBody("ck", 'tbContentElement', formJson.BodyContext.tbContentElement["#cdata-section"].replace(/\\n/gi, ""));
                	} else {
                		coviEditor.setBody("ck", 'tbContentElement', formJson.BodyContext.tbContentElement.replace(/\\n/gi, ""));
                	}
                    try { G_displaySpnDocLinkInfo(); } catch (e) { mobile_comm_log(e); }
                } else {
                    if (getInfo("FormInfo.BodyDefault") != undefined) {
                    	coviEditor.setBody("ck", 'tbContentElement', Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault")));
                    }
                }
				} catch (e) {
					setTimeout("setEditor()", 100);
				}
                break;
        }

    }
    else {// 읽기 모드인 경우
        var tbContent;
        if (typeof formJson.BodyContext.tbContentElement["#cdata-section"] != 'undefined') {
            tbContent = formJson.BodyContext.tbContentElement["#cdata-section"];
        }
        else if (typeof formJson.BodyContext.tbContentElement != 'undefined') {
            tbContent = formJson.BodyContext.tbContentElement;
        }
        else {
            tbContent = "error at setEditor().";
        }

        $("#tbContentElement").html(tbContent.replace(/\\n/gi, ""));
    }
}

//  dField, cField
// name-> id, id-> data-type, datafld->data-model 로 변경
// underscore로 binding이 일어나는 data와의 구분을 위한 data-binding attribute 추가
// CommonFields의 dField, cField && data-binding="post" 인 경우의 data 처리
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
            /*if ($(fld).attr('id') == 'POSITION' && getInfo($(fld).attr('id')) == "") {
                $(fld).val(getInfo($(fld).attr("data-model")));
            }*/

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

//  tField 처리 방식 그대로 유지
// name-> id, id-> data-type, datafld->data-model 로 변경
// select && mField|dField 는 읽기 모드에서 tField로 변경
// input && dField 는 읽기 모드에서 tField로 변경
function settFields(Fields) {

    try {
        var fld;
        var l_editor = "#editor";
        if (openMode == "P") {
            l_editor = CFN_GetCtrlById("editor");
        }

        $(l_editor).find("td[data-type='" + Fields + "'],span[data-type='" + Fields + "']").each(function (i, fld) {

            if ($(fld).attr("data-model") != "") {
                if (getInfo($(fld).attr("id")) != undefined) {
                    $(fld).text(getInfo($(fld).attr("id")));
                }
                else {
                    if (getInfo($(fld).attr("data-model")) != undefined) {
                        $(fld).text(getInfo($(fld).attr("data-model")));
                    }//oFormData에 없는 경우 BODY_CONTEXT에서 가져 오는 구문 추가
                    else if (typeof formJson.BodyContext[$(fld).attr("data-model")] != 'undefined') {
                        $(fld).text(formJson.BodyContext[$(fld).attr("data-model")]);
                    }
                    else {
                        $(fld).text('');
                    }
                }
            }
        });
    } catch (e) {
    	mobile_comm_log(e);
    }


}

//문서등급 조회
function getDocLevel(szCode) {
    var szName = '';
    /*보광그룹변경
    switch (szCode){
    case "10" : szName = "공개";break;
    case "20" : szName = "대외비";break;
    case "30" : szName = "중요";break;
    case "40" : szName = "극비";break;	
    }
    */

    //일반문서, 보안문서
    switch (szCode) {
        case "100": szName = Common.getDic("DOC_LEVEL_10"); break; //일반문서
        case "200": szName = Common.getDic("DOC_LEVEL_20"); break; //보안문서
        case "300": szName = Common.getDic("DOC_LEVEL_30"); break; //3등급
    }
    return szName;
}

//보존년한 조회
function getSaveTerm(szCode) {
    var szName = '';

    switch (szCode) {
        case "1":       //1년
        case "01":       //1년
            szName = Common.getDic("lbl_apv_year_1");
            break;
        case "3":       //3년
        case "03":       //3년
            szName = Common.getDic("lbl_apv_year_3");
            break;
        case "5":       //5년
        case "05":       //5년
            szName = Common.getDic("lbl_apv_year_5");
            break;
        case "7":       //7년
            szName = Common.getDic("lbl_apv_year_7");
            break;
        case "10":      //10년
            szName = Common.getDic("lbl_apv_year_10");
            break;
        case "20":      //20년
        	szName = Common.getDic("lbl_apv_year_20");
        	break;
        case "25":      //30년
        	szName = Common.getDic("lbl_apv_year_30");
        	break;
        case "30":      //준영구
        	szName = Common.getDic("lbl_apv_semiperm");
        	break;
        case "99":      //영구
        case "40":      //영구
            szName = Common.getDic("lbl_apv_permanence");
            break;
    }

    return szName;
}

/*** xml -> json***/
//name-> id, id-> data-type, datafld->data-model 로 변경
//정리
// xml -> json
function getFields(Fields) {
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

//문서등급(보안등급) create
function setDocLevel() {
    // 일반문서, 보안문서
    //makeCBOobject("10", "일반문서", DOC_LEVEL);
    //makeCBOobject("20", "보안문서", DOC_LEVEL);
    document.getElementById("DocLevel").options.length = 0;
    makeCBOobject("100", Common.getDic("DOC_LEVEL_10"), document.getElementById("DocLevel"));
    makeCBOobject("200", Common.getDic("DOC_LEVEL_20"), document.getElementById("DocLevel"));
    makeCBOobject("300", Common.getDic("DOC_LEVEL_30"), document.getElementById("DocLevel"));

    //setDefaultCBOobject((getInfo("FormInstanceInfo.DocLevel") == null ? "10" : getInfo("FormInstanceInfo.DocLevel")), DOC_LEVEL);
    //setDefaultCBOobject((getInfo("FormInstanceInfo.DocLevel") == null ? "10" : getInfo("FormInstanceInfo.DocLevel")), document.getElementById("DOC_LEVEL"));
    //setDefaultCBOobject(getInfo("FormInstanceInfo.DocLevel"), document.getElementById("DOC_LEVEL"));

    try {
        if (getInfo("FormInstanceInfo.DocLevel") != undefined) {
            setDefaultCBOobject(getInfo("FormInstanceInfo.DocLevel"), document.getElementById("DocLevel"));
        }
        else {
            /*setDefaultCBOobject(getInfo("SecurityGrade"), document.getElementById("DOC_LEVEL"));*/   //2012-04-02 HIW
        	setDefaultCBOobject(getInfo("ExtInfo.SecurityGrade"), document.getElementById("DocLevel"));
        }
        //1등급 기밀문서로 설정 안함
        //        if (document.getElementById("DOC_LEVEL").value == "100") {
        //            document.getElementById("chk_secrecy").checked = true;
        //            document.getElementById("chk_secrecy").value = "1";
        //        } else {
        //            document.getElementById("chk_secrecy").checked = false;
        //            document.getElementById("chk_secrecy").value = "0";
        //        }

    }
    catch (ex) { mobile_comm_log(ex); }
}

//보존년한 create
function setSaveTerm() {
    document.getElementById("SaveTerm").options.length = 0;
    makeCBOobject("1", Common.getDic("lbl_apv_year_1"), document.getElementById("SaveTerm")); 			//"1년"
    makeCBOobject("3", Common.getDic("lbl_apv_year_3"), document.getElementById("SaveTerm")); 			//"3년"
    makeCBOobject("5", Common.getDic("lbl_apv_year_5"), document.getElementById("SaveTerm")); 			//"5년"
    makeCBOobject("7", Common.getDic("lbl_apv_year_7"), document.getElementById("SaveTerm")); 			//"7년"
    makeCBOobject("10", Common.getDic("lbl_apv_year_10"), document.getElementById("SaveTerm"));  		//"10년"
    makeCBOobject("99", Common.getDic("lbl_apv_permanence"), document.getElementById("SaveTerm"));       //"영구"
    //setDefaultCBOobject(getInfo("FormInstanceInfo.SaveTerm"), document.getElementById("SAVE_TERM"));

    try {
        if (getInfo("FormInstanceInfo.SaveTerm") != undefined)
            setDefaultCBOobject(getInfo("FormInstanceInfo.SaveTerm"), document.getElementById("SaveTerm"));
        else
            /*setDefaultCBOobject(getInfo("PreservPeriod"), document.getElementById("SAVE_TERM"));*/  //2012-04-02 HIW
        	setDefaultCBOobject(getInfo("ExtInfo.PreservPeriod"), document.getElementById("SaveTerm"));
    }
    catch (ex) { mobile_comm_log(ex); }
}

//문서분류 대입 (2012-04-02 HIW)
function setDocClass() {
    try {
        //        document.getElementById("DOC_CLASS_NAME").value = getInfo("ExtInfo.DocClassNm");
        if (document.getElementById("DocClassName").value == "") {
            document.getElementById("DocClassName").value = getInfo("ExtInfo.DocClassName");
        }
        if (document.getElementById("DocClassID").value == "") {
            document.getElementById("DocClassID").value = getInfo("ExtInfo.DocClassID");
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

//name-> id, id-> data-type, datafld->data-model 로 변경
// xml -> json
function getChangeFormJSON() {
    var jsonObj = {};
    
    var sBodyContext = getBodyContext();
    
    /*
    // 외부 연동일 경우 HTML 통째로 저장
    if(getInfo("Request.isLegacy") == "Y")
    	sBodyContext = getInfo("BodyContext");
    else
    	sBodyContext = getBodyContext();*/
    
    
    if (JSON.stringify(makeNode("BodyContext", $.parseJSON(getInfo("BodyContext")))) != JSON.stringify(sBodyContext))
    	jsonObj = sBodyContext;
    //common fields( ex)cField, mField를 제외한 dField 화면에 보이지 않는 값)
    var l_editor = "#editor";
    if (openMode == "P") l_editor = CFN_GetCtrlById("editor");
    $(l_editor).find("input[data-type=dField], textarea[data-type=dField], checkbox[data-type=dField]", "radio[data-type=dField]").each(function (i, fld) {
        if ($(fld).attr("id") == "AttachFileInfo") {
            //첨부파일은 json 형식이라 비교문이 다름
            // Save Name 으로 비교
        	
        	var isFileModified = false;
            var oldFileInfo = "";
            var newFileInfo = "";
            
            /*oldFileInfo = (getInfo("FormInstanceInfo."+$(fld).attr("id")) == "") ? "" : JSON.stringify($.parseJSON(getInfo("FormInstanceInfo."+$(fld).attr("id"))));
            newFileInfo = ($(fld).val() == "") ? "" : JSON.stringify($.parseJSON($(fld).val()));*/
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
	            		isFileModified = !fileArrayCompare(arrOldNames, arrNewNames);
	            	}
            	}else{
            		isFileModified = true;
            	}
            }
            	
            if(typeof(oldFileInfo) != typeof(newFileInfo))
            	isFileModified = true;
            	
            if (isFileModified) {
            	//var fldVal = $(fld).val().replace(/[\r\n]/g, "\\n");
            	var fldVal = $(fld).val();
                $.extend(jsonObj, makeNode($(fld).attr("id"), fldVal));
            }
        } else if ($(fld).attr("id") == "ReceiptList") {
        	if($(fld).val() == "@@" && getInfo("FormInstanceInfo."+$(fld).attr("id")) == "") {
        	}
        	else {
        		if ($(fld).val() != getInfo("FormInstanceInfo."+$(fld).attr("id")) && !($(fld).val() == "" && getInfo("FormInstanceInfo."+$(fld).attr("id")) ==undefined)) {
    	            var fldVal = $(fld).val();
    	            $.extend(jsonObj, makeNode($(fld).attr("id"), fldVal));
                }	
        	}
        } else {
            if ($(fld).val() != getInfo("FormInstanceInfo."+$(fld).attr("id")) && !($(fld).val() == "" && getInfo("FormInstanceInfo."+$(fld).attr("id")) ==undefined)) {
	            var fldVal = $(fld).val();
	            $.extend(jsonObj, makeNode($(fld).attr("id"), fldVal));
            }
        }
    });

    $(l_editor).find("select[data-type=dField]").each(function (i, fld) {
        if (getInfo("FormInstanceInfo."+$(fld).attr("id")) != undefined && $(fld).val() != getInfo("FormInstanceInfo."+$(fld).attr("id"))) {
            if ($(fld).attr("tag") == "select") {
                $.extend(jsonObj, getSelRadio($(fld).attr("name")));
            } else {
            	$.extend(jsonObj, makeNode($(fld).attr("id"), $(fld).val()));
            }
        }
    });

    //smField, stField 처리 추가
    var subJsonObj = {};
    if (getInfo("SubTableInfo.MainTable") != "") {
        if (getInfo("Request.mode") == "DRAFT" && m_sReqMode == "TEMPSAVE" && getInfo("Request.templatemode") == "Read")// 회수일 경우 이전 값에서 가져 오기
        {
        	subJsonObj = formJson.BodyData; //getInfo("BodyData");
        }

            // [2015-01-20 modi] 읽기모드에서는 bodyinfo를 만들지 않도록
            //else if (getInfo("Request.mode") == "APPROVAL" && m_sReqMode == "APPROVE" && getInfo("Request.templatemode") == "Read") { // 편집없이 그냥 승인일 경우 그냥 넘기기
            //	subJSON = "";
            //}
        else if (getInfo("Request.templatemode") == "Read") {
        	subJsonObj = {};
        }
        else {
        	subJsonObj["BodyData"] = {};
            try {
            	subJsonObj["BodyData"]["MainTable"] = {};
            	
                var unFiltered = document.getElementsByTagName("*");
                for (let i = 0; i < unFiltered.length; i++) {
                    if (unFiltered[i].getAttribute("data-type") == "smField") {
                    	subJsonObj["BodyData"]["MainTable"] = $.extend(subJsonObj["BodyData"]["MainTable"], makeNodeByTypeForDB($(unFiltered[i]), "smField"));
                    }
                }
                /*subJsonObj += "</maintable>";*/
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
            }
        }
    }

    //last modifier info

    var _return = {};
    $.extend(jsonObj, subJsonObj);
    if (!$.isEmptyObject(jsonObj) || !$.isEmptyObject(subJsonObj)) {
        _return = $.extend({"LastModifierID" : getInfo("AppInfo.usid")}, {"FormData" : jsonObj });
    } else {
    	//_return = { "FormData" : jsonObj };
    	_return = {};
    }

    //apst 확인
    /*var sApvlist = $($.parseJSON(getApvList())).find("apvlist>steps");*/ 		//CFN_XmlToString($($.parseJSON(getApvList())).find("apvlist>steps")[0])
    var sApvlist = getApvList();
    if ((!(getInfo("ApprovalLine").replace("\r\n", "") == JSON.stringify(sApvlist))) || strApvLineYN == "Y") {
    	$.extend(_return, {"ChangeApprovalLine" : document.getElementById("APVLIST").value});
    }

    return _return;
}

function fileArrayCompare(arrayA, arrayB){
	if (arrayA.length != arrayB.length) { return false; }
    var a = jQuery.extend(true, [], arrayA);
    var b = jQuery.extend(true, [], arrayB);
    for (var i = 0, l = a.length; i < l; i++) {
        if (a[i] !== b[i]) { 
            return false;
        }
    }
    return true;
}


//컬럼형태로 저장되는 값들에 대한 처리, dField, smField, stField
function getFormJSON() {
    //placeholder에 대한 처리
    $("input").attr("placeholder", "");
    var returnObj = {};
    var bodyContextObj = {};
    
    if(getInfo("Request.isLegacy") == "Y" && (getInfo("Request.legacyDataType") == "ALL" || getInfo("Request.legacyDataType") == "HTML"))
    	bodyContextObj = { "BodyContext" : JSON.parse(getInfo("BodyContext")) };
    else
    	bodyContextObj = getBodyContext();
    
    var unFiltered = document.getElementsByTagName("*");
    for (i = 0; i < unFiltered.length; i++) {
        if (unFiltered[i].getAttribute("data-type") == "dField") {
        	$.extend(bodyContextObj, makeNode(unFiltered[i].getAttribute("id"), unFiltered[i].value));
        }
    }
    
    var subJsonObj = {};
    if (getInfo("SubTableInfo.MainTable") != "" && getInfo("SubTableInfo.MainTable") != undefined) {

        if (getInfo("Request.mode") == "DRAFT" && m_sReqMode == "TEMPSAVE" && getInfo("Request.templatemode") == "Read")// 회수일 경우 이전 값에서 가져 오기
        {
            subJsonObj = formJson.BodyData; //getInfo("BodyData");
        }else if (getInfo("Request.templatemode") == "Read") {		// [2015-01-20 add] 읽기모드에서는 bodyinfo를 만들지 않도록
            subJsonObj = {};
        }else {
        	subJsonObj["BodyData"] = {};
            try {
            	subJsonObj["BodyData"]["MainTable"] = {};
            	
                var unFiltered = document.getElementsByTagName("*");
                for (i = 0; i < unFiltered.length; i++) {
                    if (unFiltered[i].getAttribute("data-type") == "smField") {
                    	subJsonObj["BodyData"]["MainTable"] = $.extend(subJsonObj["BodyData"]["MainTable"], makeNodeByTypeForDB($(unFiltered[i]), "smField"));
                    }
                }
                /*subJsonObj += "</maintable>";*/
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
            }
        }
    }
    
    returnObj["FormData"] = $.extend(bodyContextObj, subJsonObj);
    
    return returnObj;
}

//에디터 타입 참조방식 변경 : KJW : 2014-04-23 : XFROM PRJ.
function getBodyContext() {
    //debugger;
    var ret = {};

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
        ret = {};
    }
    else {
        try {
            if (editortype.is('xfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject === undefined)) {
                //xfree iframe으로 변경
                document.getElementById("dhtml_body").value = document.getElementById('xFreeFrame').contentWindow.tbContentElement.getHtmlValue();
                UpdateImageData(); //이미지 업로드
            } else if (editortype.is('tagfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject !== undefined)) {
                document.getElementById("dhtml_body").value = document.tbContentElement.HtmlValue;
                UpdateImageData(); //이미지 업로드
            } else if (editortype.is('crosseditor') || (editortype.is('activesquaredefault') && window.ActiveXObject === undefined)) {
                document.getElementById("dhtml_body").value = tbContentElement.GetBodyValue();
                UpdateImageData(); //이미지 업로드
            } else if (editortype.is('activesquare') || (editortype.is('activesquaredefault') && window.ActiveXObject !== undefined)) {
                document.getElementById("dhtml_body").value = document.tbContentElement.value;
                UpdateImageData(); //이미지 업로드
                document.getElementById("dhtml_body").value = document.tbContentElement.value;
            } else if (editortype.is('textarea')) {
                document.getElementById("dhtml_body").value = document.getElementById("tbContentElement").value;
            }
            else if (editortype.is('dext5')) {
                // TODO: DEXT5 Test by Kyle 2015-07-30
                //document.getElementById("dhtml_body").value = document.getElementById('dext5Frame').contentWindow.DEXT5.getBodyValue();
            	document.getElementById("dhtml_body").value = coviEditor.getBody("dext5", 'tbContentElement');
            }
            else if (editortype.is('cheditor')) {
                // TODO: Cheditor Test by Kyle 2015-08-04
                document.getElementById("dhtml_body").value = document.getElementById('cheditorFrame').contentWindow.myeditor.getContents();
            }
            else if (editortype.is('synap')) {
            	document.getElementById("dhtml_body").value = coviEditor.getBody("synap", 'tbContentElement');
            }
            else if (editortype.is('ck')) {
            	document.getElementById("dhtml_body").value = coviEditor.getBody("ck", 'tbContentElement');
            }
        } catch (e) { mobile_comm_log(e); }
        var sBodyContext = makeBodyContext();
        
        var editorInlineImages = {};
        if( getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode")  == "TEMPSAVE" || getInfo("Request.editmode") == "Y"){
	    	if(sBodyContext.BodyContext.tbContentElement != undefined && getEditorImages() != ""){
	    		editorInlineImages["EditorInlineImages"] = getEditorImages();
	    	}
        }
        
        sBodyContext = $.extend(sBodyContext,editorInlineImages);
        
        /*ret = makeNode("BodyContext", sBodyContext);*/
        ret = sBodyContext;
    }
    
    return ret;
}

//에디터 타입 참조방식 변경 : KJW : 2014-04-23 : XFROM PRJ.
function getEditorImages() {
    //debugger;
    var ret = "";

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
        ret = "";
    }
    else {
        try {
            if (editortype.is('xfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject === undefined)) {
            	 // TODO 이미지 정보 조회 작업 
            } else if (editortype.is('tagfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject !== undefined)) {
            	 // TODO 이미지 정보 조회 작업 
            } else if (editortype.is('crosseditor') || (editortype.is('activesquaredefault') && window.ActiveXObject === undefined)) {
            	 // TODO 이미지 정보 조회 작업 
            } else if (editortype.is('activesquare') || (editortype.is('activesquaredefault') && window.ActiveXObject !== undefined)) {
            	 // TODO 이미지 정보 조회 작업 
            } else if (editortype.is('textarea')) {
            	 // TODO 이미지 정보 조회 작업 
            } else if (editortype.is('dext5')) {
            	ret =  coviEditor.getImages("dext5", 'tbContentElement');
            } else if (editortype.is('cheditor')) {
            	 // TODO 이미지 정보 조회 작업 
            } else if (editortype.is('synap')) {
            	ret =  coviEditor.getImages("synap", 'tbContentElement');
            } else if (editortype.is('ck')) {
            	ret =  coviEditor.getImages("ck", 'tbContentElement');
            }
        } catch (e) { mobile_comm_log(e); }
    }

    return ret;
}

/*
    event_noop()
    moved to form.refactor.deleted.js
    by KJW : 2014.04.21 : XFORM PRJ.
*/

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

/* 문서관리시스템 분류선택창 OPEN 시작 */
function OpenDocClass() {
    //debugger;
    if (m_oFormMenu.gDocboxMenu == "T") {
        var sUrl = "";
        sUrl = "admin/goDocTreePop.do";
        //sUrl = "/WebSite/Approval/DocBoxTreeSelect.aspx";
        //sUrl = "/WebSite/Approval/Record/Client/DocBoxTreeSelect.aspx";  //기록물철 분류팝업 (2013-10-14 HIW)
        var iWidth = 400; var iHeight = 400; var sSize = "fix";

        if (openMode == "L" || openMode == "P") {
            var nLeft = (screen.width - iWidth) / 2;
            var nTop = (screen.height - iHeight) / 2;
            var sWidth = iWidth.toString() + "px";
            var sHeight = iHeight.toString() + "px";
            var sLeft = nLeft.toString() + "px";
            var sTop = nTop.toString() + "px";
            parent.Common.ShowDialog("btn_Process", "btn_ProcessDocBox", Common.getDic("lbl_apv_docfoldername"), sUrl + "?openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");
        } else {
            CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
        }
    } else {
        var fdid = document.getElementById("DocClassID").value;
        //CFN_OpenWindow(Common.GetPgModule("Doc.DocTree") + "?doctype=doc&domainID=" + "" + "&fdid=" + fdid + "&system=Doc&viewType=Approval", "PopupDocClass", "290", "370", "fix");
        var sUrl = /*Common.GetPgModule("Doc.DocTree")*/"admin/goDocTreePop.do" + "?doctype=doc&domainID=" + getInfo("AppInfo.etid") + "&fdid=" + fdid + "&system=Doc&viewType=Approval";

        //if (location.href.indexOf("/Approval/ApprovalWrite") > -1) {
        //    return Common.ShowDialog("btn_Process", "LayerDocTree", "분류", sUrl, 290, 370, "iframe-ifNoScroll");
        if (openMode == "L") { //최우석
            parent.Common.ShowDialog("", "DivPop_" + openID, Common.getDic("lbl_apv_docfoldername"), sUrl + "&openID=" + openID, "331", "440", "iframe-ifNoScroll");
            
        } else {
        	CFN_OpenWindow(sUrl, "PopupDocClass", "331", "440", "fix");
        }//else
    }
}

/* 문서관리시스템 분류선택창 끝 */

/*******************************************
******** 양식 파일 내 공통 함수 정리 끝 *******
*******************************************/


/*******************************************
***** 양식 파일 내 연결문서 함수 정리 시작 *****
*******************************************/

function G_displaySpnDocLinkInfo() {//수정본
    var szdoclinksinfo = "";
    var szdoclinks = "";
    if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBAPPROVAL") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBREDRAFT") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "PCONSULT") || g_szEditable == true) {
        try { szdoclinks = document.getElementById("DocLinks").value; } catch (e) { mobile_comm_log(e); }
    } else {
        try { szdoclinks = document.getElementById("DocLinks").value; } catch (e) { mobile_comm_log(e); }
        if (szdoclinks == "") {
            /*BodyContext에 연결문서 정보 X
            var m_objXML = $.parseXML("" + getInfo("BodyContext"));
            if ($(m_objXML).find("DocLinks").length == 0) {
                szdoclinks = "";
            } else {
                szdoclinks = $(m_objXML).find("DocLinks").text();
            }*/
            try { document.getElementById("DocLinks").value = szdoclinks; } catch (e) { mobile_comm_log(e); }
            //szdoclinks = m_objXML.documentElement.selectSingleNode("DOCLINKS").text;
        }
    }
    //DOCLINKS 값에 undefined 가 들어 가서 오류남. 원인 찾기전 임시로 작성
    szdoclinks = szdoclinks.replace("undefined^", "");
    szdoclinks = szdoclinks.replace("undefined", "");
    if (szdoclinks != "") {
        var adoclinks = szdoclinks.split("^^^");
        for (var i = 0; i < adoclinks.length; i++) {

            var adoc = adoclinks[i].split("@@@");
            // var FormUrl = "http://" + document.location.host + "/WebSite/approval/forms/form.aspx";
            var FormUrl = document.location.protocol + "//" + document.location.host + "/approval/approval_Form.do";
            var bEdit = false;
            if (getInfo("Request.templatemode") == "Read") {
                bEdit = false
            } else {
                bEdit = true;
            }
            var iWidth = 790;
            if (IsWideOpenFormCheck(adoc[1])) {
                iWidth = 1070;
            }
            var iHeight = window.screen.height - 82;
            if (bEdit) {
                if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBAPPROVAL") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "PCONSULT") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBREDRAFT") || g_szEditable == true) {
                    szdoclinksinfo += "<input type=checkbox id='chkDoc' name='_" + adoc[0] + "' value='" + adoc[0] + "' class='td_check' style='float:none;'>";
                }
                szdoclinksinfo += "<span class='td_txt' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;float:none;'  onclick=\"CFN_OpenWindow('";
                szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=true";
                szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">" + adoc[2] + "</span><br />";
                // 연결문서 구분짓기 위한 Comma 추가 : 07. 6. 11. JSI
                // 연결문서 br처리 2016-05-09 KWR 처리내용 : <br />추가 , 인라인 style에 float:none; 추가
            } else {
                if (bDisplayOnly) {
                    szdoclinksinfo += adoc[2];
                } else {
                    szdoclinksinfo += "<span class='txt_gn11_blur' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;'  onclick=\"CFN_OpenWindow('";
                    szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=true&IsDocLink=Y";
                    szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">- " + adoc[2] + "</span><br />";
                }
                // 연결문서 구분짓기 위한 Comma 추가 : 07. 6. 11. JSI
                //if (i < adoclinks.length - 1) {
                //    szdoclinksinfo += ", ";
                //}
            }
        }

        // 조건문 추가 : 07. 7. 6. JSI
        if (bEdit) {
            if (szdoclinksinfo != "" && (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBAPPROVAL")) || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "PCONSULT") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBREDRAFT") || g_szEditable == true) {
                /*모바일이 아닐경우
                 * if (location.href.indexOf("Approval/ApprovalWrite") < 0) {*/
                    //szdoclinksinfo += "<a href='#' onclick='deletedocitem();'><font color='#009900'><b>" + m_oFormMenu.gLabel_link_delete + "<b></font></a>";
                    //szdoclinksinfo += "<div class='xbtn' style='float:right;' ><a href='#'  onclick='deletedocitem();' ><em class='btn_iws_l'><span class='btn_iws_r'><strong class='txt_btn_ws'><img src='/Images/Images/Approval/ico_x.gif' alt='' class='ico_btn' />" + Common.getDic("lbl_apv_link_delete") + "</strong></span></em></a></div>";			//m_oFormMenu.gLabel_link_delete
            	szdoclinksinfo += "<div class='xbtn' style='float:right;' ><input type='button' class='AXButton' value='연결삭제' onclick='deletedocitem();'></div>";
                /*}*/
            }
        }
    }
    document.getElementById("DocLinkInfo").innerHTML = szdoclinksinfo;
}



function InputDocLinks(szValue) {
    try {
        if (document.getElementById("DocLinks").value == "") {
            document.getElementById("DocLinks").value = szValue; G_displaySpnDocLinkInfo();
        }
        else {
            adddocitem(szValue);
        }
    }
    catch (e) {
    	mobile_comm_log(e);
    }
}
function adddocitem(szAddDocLinks) {
    //2013-07-10 YHM 연결문서정보 간소화
    //    var adoclinks = document.getElementById("DOCLINKS").value.split("^");
    //    var aadddoclinks = szAddDocLinks.split("^");
    var adoclinks = document.getElementById("DocLinks").value.split("^^^");
    var aadddoclinks = szAddDocLinks.split("^^^");
    var szdoclinksinfo = "";

    var tmp = "";
    for (var i = 0; i < aadddoclinks.length; i++) {
        if (aadddoclinks[i] != null) {
            var bexitdoclinks = false;
            for (var j = 0; j < adoclinks.length; j++) { if (aadddoclinks[i] == adoclinks[j]) { bexitdoclinks = true; } }
            if (!bexitdoclinks) adoclinks[adoclinks.length] = aadddoclinks[i];
        }
    }

    for (var k = 0; k < adoclinks.length; k++) {
        if (adoclinks[k] != null) {
            if (szdoclinksinfo != "") {
                //2013-07-10 YHM 연결문서정보 간소화
                //                szdoclinksinfo += "^" + adoclinks[k];
                szdoclinksinfo += "^^^" + adoclinks[k];
            } else {
                szdoclinksinfo += adoclinks[k];
            }
        }
    }
    document.getElementById("DocLinks").value = szdoclinksinfo;
    G_displaySpnDocLinkInfo();
}
function deletedocitem() {
    //2013-07-10 YHM 연결문서정보 간소화
    //    var adoclinks = document.getElementById("DOCLINKS").value.split("^");
    var adoclinks = document.getElementById("DocLinks").value.split("^^^");
    var szdoclinksinfo = "";
    var chkDoc = $("#DocLinkInfo").find("input[id='chkDoc']");
    var tmp = "";
    if (chkDoc.length > 0) {
        chkDoc.each(function (i, elm) {
            if ($(elm).is(":checked")) {
                tmp = $(elm)[0].value;
                for (var j = adoclinks.length - 1; j >= 0; j--) {
                    if (adoclinks[j] != null && adoclinks[j].indexOf(tmp) > -1) {
                        adoclinks[j] = null;
                    }
                }
            }
        });
    }
    for (var i = 0; i < adoclinks.length; i++) {
        if (adoclinks[i] != null) {
            if (szdoclinksinfo != "") {
                //2013-07-10 YHM 연결문서정보 간소화
                //                szdoclinksinfo += "^" + adoclinks[i];
                szdoclinksinfo += "^^^" + adoclinks[i];
            } else {
                szdoclinksinfo += adoclinks[i];
            }
        }
    }
    document.getElementById("DocLinks").value = szdoclinksinfo;
    G_displaySpnDocLinkInfo();
}

/*******************************************
***** 양식 파일 내 에디터 함수 정리 시작   *****
*******************************************/

////////////////////////////////////////////////////////////////////
//				에디터에 추가된 이미지, 업로드				      //	
////////////////////////////////////////////////////////////////////

var gz_Editor = "0";
//시스템 사용 에디터 0.TextArea, 1.DHtml, 2.TagFree, 3.XFree, 4.TagFree/XFree, 5.Activesquare, 6.CrossEditor, 7.ActivesquareDefault/CrossEditor

//에디터 타입 참조방식 변경 : 김진우 : 2014-04-23 : XFROM PRJ.
function UpdateImageData() {
    gz_Editor = editortype.is(); //getInfo("BaseConfig.editortype");
    var nfolder = "IMAGEATTACH";
    var n = -1;
    if (editortype.is('xfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject === undefined)) {
        // xfree iframe으로 변경
        //[2014-11-24 XFree2]
        document.getElementById("dhtml_body").value = document.getElementById('xFreeFrame').contentWindow.tbContentElement.getHtmlValue();
        n = document.getElementById("dhtml_body").value.indexOf('/FrontStorage/') + 1;
    } else if (editortype.is('tagfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject !== undefined)) {
        document.tbContentElement.SetDefaultTargetAs('_blank'); //link 변경
        document.getElementById("dhtml_body").value = document.tbContentElement.HtmlValue;
        n = document.getElementById("dhtml_body").value.indexOf('file:///');
    } else if (editortype.is('crosseditor') || (editortype.is('activesquaredefault') && window.ActiveXObject === undefined)) {
        //[2014-11-24 XFree2]
        document.getElementById("dhtml_body").value = document.getElementById('xFreeFrame').contentWindow.tbContentElement.getHtmlValue();
        n = document.getElementById("dhtml_body").value.indexOf(document.location.protocol + "//") + 1;
    } else if (editortype.is('activesquare') || (editortype.is('activesquaredefault') && window.ActiveXObject !== undefined)) {
        n = document.tbContentElement.GetFileNum(0);
    }

    if (n > 0) {
        EditorGetContent();
        if (hidContentMime != "") {
            // frontstorage에 있는 이미지를 BackStorage\Approval 로 이동
            var szRequestXml = "<?xml version='1.0'?>" +
								"<parameters>" +
									"<BodyContent><![CDATA[" + hidContentText + "]]></BodyContent>" +
									"<EditorContent><![CDATA[" + hidContentMime + "]]></EditorContent>" +
									"<ImageContent><![CDATA[" + hidContentImage + "]]></ImageContent>" +
									"<fiid><![CDATA[" + getInfo("FormInstanceInfo.FormInstID") + "]]></fiid>" +
                                "</parameters>";
            CFN_CallAjax("/WebSite/Approval/FileAttach/BodyImgMoveBAckStorage.aspx", szRequestXml, function (data) {
                event_attchSync(data);
            }, false, "xml");
        }
    }
}

function event_attchSync(dataresponseXML) {
    var xmlReturn = dataresponseXML;
    var errorNode = $(xmlReturn).find("response > error");
    if (errorNode.length > 0) {
        alert("AttachImage ERROR : " + errorNode[0].text);
        return;
    } else {
        document.getElementById("dhtml_body").value = $(xmlReturn).find("response > htmldata").text();
        if (editortype.is('xfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject === undefined)) {
            tbContentElement.SetHtmlValue(document.getElementById("dhtml_body").value);
        } else if (editortype.is('tagfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject !== undefined)) {
            document.tbContentElement.HtmlValue = document.getElementById("dhtml_body").value;
        } else if (editortype.is('crosseditor') || (editortype.is('activesquaredefault') && window.ActiveXObject === undefined)) {
            tbContentElement.SetBodyValue(document.getElementById("dhtml_body").value);
        } else if (editortype.is('activesquare') || (editortype.is('activesquaredefault') && window.ActiveXObject !== undefined)) {
            document.tbContentElement.value = document.getElementById("dhtml_body").value;
            //url변경
            var objDOM = document.tbContentElement.CreateDOM();
            objDOM.charset = "utf-8";
            var imgName = new Array;
            var szdate = getInfo("AppInfo.svdt").replace(/:/gi, "").replace(/오후/gi, "").replace(/오전/gi, "").replace(/ /gi, "");
            var g_szURL = "/GWStorage/e-sign/Approval/IMAGEATTACH"; //"http://" + document.location.host + 
            for (var i = 0; i < objDOM.images.length; i++) {
                var imgSrc = objDOM.images[i].src;
                imgSrc = imgSrc.toLowerCase();
                if (imgSrc.indexOf("file:///") > -1) { //backstorage/approval/attach== -1					
                    imgName[i] = imgSrc.substring(imgSrc.lastIndexOf('/') + 1, imgSrc.length);
                    objDOM.images[i].src = g_szURL + "/" + szdate + "_" + imgName[i];
                }
            }
            document.tbContentElement.Value = objDOM.body.innerHTML;
            document.tbContentElement.DeleteDOM(); // DOM 사용하고 난 후에는 삭제해주어야 한다.		                    
        }
    }
}

/*******************************************
***** 양식 파일 내 에디터 함수 정리 끝   *****
*******************************************/

/*******************************************
*** 양식 이름 옆 버튼 이벤트 처리 : 시작   *****
*******************************************/

//양식 이름 셋팅
function initheadname(szfmnm, bContextMenu) {
    var szheadname = szfmnm;
    return szheadname;
}

function AnchorPosition_getPageOffsetLeft(el) {
    var ol = el.offsetLeft;
    while ((el = el.offsetParent) != null) { ol += el.offsetLeft; }
    return ol;
}
function AnchorPosition_getPageOffsetTop(el) {
    var ot = el.offsetTop;
    while ((el = el.offsetParent) != null) { ot += el.offsetTop; }
    return ot;
}

//타양식으로 내용 복사 2008.05 강성채
function copyDiff(diffx, diffy, obj) {
    var sH = parseInt(document.body.scrollTop);
    var sW = parseInt(document.body.scrollLeft);

    document.getElementById("dropForm").style.Top = sH + diffy;
    document.getElementById("dropForm").style.Left = sW + diffx;

    document.getElementById("dropForm").style.display = (document.getElementById("dropForm").style.display == "block") ? "none" : "block";
    if (document.getElementById("dropForm").style.display == "block") {
        var oContextHTML = document.getElementById("nDropForm").document.getElementById("divDifferform");
        if (oContextHTML != null) {
            oContextHTML.style.display = "";

            var h = oContextHTML.offsetHeight;
            var w = oContextHTML.offsetWidth;
            document.getElementById("dropForm").style.width = w;
            document.getElementById("dropForm").style.height = h;
        }
    }
}

/*******************************************
*** 양식 이름 옆 버튼 이벤트 처리 : 끝   *****
*******************************************/
function getTaskID(strTaskID) {
    if (strTaskID != ';' && -1 != strTaskID.indexOf(';')) {
        $('#WORKREQUEST_ID').val(strTaskID.split(";")[1]);
        $('#WORKREQUEST_NAME').val(strTaskID.split(";")[0]);
    }
}

function getOSSelect(Sel_id, CodeGroup) {
    // data 예) Sel_id : 구분값
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

function openFileList_comment(pObj, idx, pGubun){
	if(!axf.isEmpty($(pObj).parent().find('.file_box').html())){
		$(pObj).parent().find('.file_box').remove();
		return false;
	}
	$('.file_box').remove();
	
	var vHtml = "<ul class='file_box'>";
	vHtml += "<li class='boxPoint'></li>";
	for(var i=0; i<g_commentAttachList[idx].length;i++){
		vHtml += "<li><a onclick='attachFileDownLoadCall_comment("+g_commentAttachList[idx][i].id+", \"" + g_commentAttachList[idx][i].savedname + "\", \"" + g_commentAttachList[idx][i].FileToken + "\")'>"+g_commentAttachList[idx][i].name+"</a></li>";
	}
	
	vHtml += "</ul>";
	$(pObj).parent().append(vHtml);
}
