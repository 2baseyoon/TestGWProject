var g_szAcceptLang = "ko";
var m_oApvList;
var m_oRecList;
var sReceiveNo = "";
var g_BaseImgURL = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + "e-sign/ApprovalSign/BackStamp/"; // 2022/05 이전 서명표시를 위해서만 사용
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
var lang = Common.getSession("lang");

//CB작업을 위해 추가
var m_oFormMenu = window;
try { if (m_oFormMenu == null) m_oFormMenu = parent.window; } catch (e) { coviCmn.traceLog(e); }

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

/*******************************************/
//****** 양식 파일 내 공통 함수 정리 시작 *****
/********************************************/

// window.onload = initOnloadformedit;
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
		$("#AttFileInfoList_Multi").hide();
	}
	
	/* 읽기모드, EDMS 문서연결 사용 시 목록 보여주기 */
	if(getInfo("Request.templatemode") == "Read"){
		if(Common.getBaseConfig("useEdmsConDoc") == "Y" && getInfo('ExtInfo.UseMultiEditYN') !== 'Y'){
			$("#EDMSDocLinkInfoList").show();
		}
		// 기록물철 데이터 조회
	    if(getInfo("SchemaContext.scRecordDocOpen.isUse") =="Y"){
	    	SelectRecordinfo();
	    }
	}
	
	// [2015-09-01 add] 기본 가로크기 유지
	if (!_mobile) {
		var vwidth = 790;
		$("form[id='menu']").css('min-width', vwidth - 20);
		$("#divMenu").closest("div").css('min-width', vwidth - 70);
		//$("#divMenu02").css('min-width', vwidth - 70);
	}

    //배포 사용시 수신확인 보이기
    if (getInfo("SchemaContext.scIPub.isUse") == "Y") {
        // document.getElementById("trRApvLine").style.display = "";
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
            setDomainData();
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

	/* 다안기안 사용 시 조회 처리 */
	initMultiEditInfo();
}

// 다안기안 사용 시 조회 처리
function initMultiEditInfo() {
	if(getInfo('ExtInfo.UseMultiEditYN') == "Y"){
		if (getInfo("Request.templatemode") == "Read") {
	        if (JSON.stringify(formJson.BodyData.SubTable1) != "{}") {
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
    					m_initMulti = true;
    					addTabClass(item.MULTI_DOC_TYPE, 'init');
        			}
        		});
        	}
        }
		
		if (isGovMulti()) {
			const rowSeq = CFN_GetQueryString('rowSeq') != '' && CFN_GetQueryString('rowSeq') != 'undefined' ? CFN_GetQueryString('rowSeq') : '';
			
			if (rowSeq != '') {
				$(formJson.BodyData.SubTable1).each(function(idx, item){
	 		    	var view = false;
	 		    	
					// 다안기안인 경우 여러 안에 같은 배포처가 들어가있을수 있으므로 선택했던 안만 볼 수 있도록 추가
					if (item != null && item.MULTI_ROWSEQ != null && rowSeq == item.MULTI_ROWSEQ){
	 					view = true;
	 				}
	 				
	 				if(!view){
	 					_func("#writeTab li[idx=" + (idx+1) + "]").remove();
	 				}
	 			});
			}
 			changeTab(_func("#writeTab li:first").attr("idx"),"init"); // 최초 로드시 1안으로 선택
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
 					_func("#writeTab li[idx=" + (idx+1) + "]").remove();
 				}
 			});
 			changeTab(_func("#writeTab li:first").attr("idx"),"init");
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
        	_func("#tbLinkInfo").find("tr[id$='_Multi']").show();
        }
        
        // 다안기안 + 문서유통시에는 다안기안용 연관문서 정보 보여준다.
        if (isGovMulti()) {
			_func("#tbLinkInfo").find("tr[id='DocLinkInfoList_Multi']").show();
			if (getInfo("Request.templatemode") == "Read") {
				_func("#tbLinkInfo").find("tr[id='AttFileInfoList_Multi']").show();
			}
			
			// 문서유통 메뉴에서 열었을때는 탭을 보여줄 필요가 없다.
			if (CFN_GetQueryString('rowSeq') != '' && CFN_GetQueryString('rowSeq') != 'undefined') {
				_func(".tabLine").hide();
			}
		}

        if(formJson.Request.readtype != "preview") {
        	formDisplaySetFileInfoMulti();	// 첨부파일 조회
        }
        
        formDisplaySetSubjectnfoMulti();	// 제목 조회
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
    		_func("#tbLinkInfo").find("tr[id*='List']:not([id$='_Multi']), tr[id='ReceiveLine_Multi']").hide();
        	
        } else {
    		_func("#tbLinkInfo").find("tr[id*='List']:not([id$='_Multi'])").hide();
        }
		
		_func('#tblFormSubject').hide();
	} else {
		_func("#DocLinkInfoList").show();
	}
}

function initForm() {

    initFields();
    //첨부쪽 처리
    if(getInfo('ExtInfo.UseMultiEditYN') != "Y") {
	    /*G_displaySpnAttInfo(false);*/
	    formDisplaySetFileInfo();
	
	    //2012차기버전작업
	    //2012차기버전작업
	    //연결문서 관련
	    try { docLinks.init(); } catch (e) { coviCmn.traceLog(e); } 
	    //EDMS 연결문서 관련
	    try { EDMSDocLinks.init(); } catch (e) { coviCmn.traceLog(e); } 
    }
    
    /*비사용 - 프로세스 메뉴얼 기능 제외
     * try { if (getInfo("scPM") == "1") G_displaySpnPMLinkInfo((getInfo("scPMV") == "" ? null : getInfo("scPMV"))); } catch (e) { coviCmn.traceLog(e); }*/

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
        settFields("tField");

        if (getInfo('ExtInfo.UseMultiEditYN') != "Y") {
        	document.getElementById("Subject").value = getInfo("FormInstanceInfo.Subject");
        }
        
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
        try { docLinks.init(); } catch (e) { coviCmn.traceLog(e); }
    } else {//양식 생성 시 입력한 본문내역 조회            
        if (getInfo("FormInfo.BodyDefault") != "undefined") {
            try { var dom = tbContentElement.getDom(); dom.body.innerHTML = getInfo("FormInfo.BodyDefault"); } catch (e) { coviCmn.traceLog(e); }
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
function setEditor(idx) {
    var dom;
    var commonEditorType = Common.getBaseConfig("EditorType");

	if(!idx) idx = "";
    
    //쓰기 모드인 경우
    if (getInfo("Request.templatemode") == "Write") {
    	var sBody = "";

         if (getInfo("BodyContext") != undefined && getInfo("BodyContext") != "{}") {
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
        			//sBody = formJson.BodyContext.tbContentElement.replace(/<br \/>/gi, "").replace(/\\n/gi, "");
        			sBody = formJson.BodyContext["tbContentElement"+idx].replace(/<br \/>/gi, "").replace(/\\n/gi, "");
        		}
            }

            try {
            	if(!(commonEditorType == editortypes['textarea'] || commonEditorType == editortypes['dhtml'] || commonEditorType == editortypes['activesquare'])) {
            		docLinks.init();
            	}
                        } catch (e) { coviCmn.traceLog(e); }
                } else {
                    if (getInfo("FormInfo.BodyDefault") != undefined) {
            	sBody = Base64.b64_to_utf8(getInfo("FormInfo.BodyDefault"));
                    }
                }

    	if(sBody) {
    		try{
    			switch (commonEditorType) {
		            case editortypes['textarea']:
		            	document.getElementById("txtareaBody" + idx).value = sBody;
		                break;
		            case editortypes['dhtml']: 
		            	break;
		            case editortypes['tagfree']:
		            	document.getElementById('tbContentElement' + idx).HtmlValue = sBody;
		                break;
		            case editortypes['xfree']:
		            	coviEditor.setBody("xfree", 'tbContentElement' + idx, sBody);
	                	break;
		            case editortypes['tagfreenxfree']:
		                if (_ie) {
				                	document.getElementById('tbContentElement' + idx).HtmlValue = sBody;
		                    } else {
				                	document.getElementById('xFreeFrame' + idx).contentWindow.tbContentElement.setHtmlValue(sBody);
		                }
		                break;
		            case editortypes['activesquare']:
		            	document.tbContentElement.value = sBody;
		                break;
		            case editortypes['dext5']:
                		coviEditor.setBody("dext5", 'tbContentElement' + idx, sBody);
		                break;
		            case editortypes['cheditor']:
		            	document.getElementById('cheditorFrame' + idx).contentWindow.myeditor.loadContents(sBody);
		                break;
		            case editortypes['synap']:  
	            		coviEditor.setBody("synap", 'tbContentElement' + idx, sBody);
		                break;
		            case editortypes['ck']:  
                		coviEditor.setBody("ck", 'tbContentElement' + idx, sBody);
		                break;
		            case editortypes['webhwpctrl']:  
						coviEditor.setBody("webhwpctrl", 'tbContentElement' + idx, sBody);
		                break;
		            case editortypes['covieditor']:
		            	coviEditor.setBody("covieditor", 'tbContentElement' + idx, sBody);
			            break;
		            case editortypes['keditor']:
                		coviEditor.setBody("keditor", 'tbContentElement' + idx, sBody);
		                break;
	            }
            } catch (e) {
				setTimeout("setEditor(" + idx + ")", 100);
            }
        }

		// 도움말 팝업이 있는경우 Focus 처리 . (IE 는 Rendering 이 느려 도움말팝업 후 에디터 포커스 됨.)
		//initHelpPopupOnLoad();// FormMenu.js
		
		if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE" || getInfo("ExtInfo.UseHWPEditYN") == "Y") {
        } else {
        	setOrgBodyContext();
        }

    } else {// 읽기 모드인 경우
        var tbContent;
		if(getInfo('ExtInfo.UseMultiEditYN') == "Y") {
			tbContent = Base64.b64_to_utf8(formJson.BodyData.SubTable1[idx-1].MULTI_BODY_CONTEXT_HTML);
		} else if(getInfo('ExtInfo.UseWebHWPEditYN') == "Y") {
			tbContent = Base64.b64_to_utf8(formJson.BodyContext.tbContentElement);
		} else if (typeof formJson.BodyContext.tbContentElement["#cdata-section"] != 'undefined') {
            tbContent = formJson.BodyContext.tbContentElement["#cdata-section"];
		} else if (typeof formJson.BodyContext.tbContentElement != 'undefined') {
            //tbContent = formJson.BodyContext.tbContentElement;
			tbContent = formJson.BodyContext["tbContentElement"+idx];
		} else {
            tbContent = "error at setEditor().";
        }

        //읽기모드인 경우 에디터 자체 여백 처리
        switch (commonEditorType) {
	    	case editortypes['xfree']:
	    	case editortypes['webhwpctrl']:
	    		$("#tbContentElement").css("padding","10px");
    			break;
        	case editortypes['dext5']:
				if(getInfo('ExtInfo.UseMultiEditYN') == "Y") {
		    		$(".table_form_info_draft").css("width","680px");
					$("#tbContentElement"+idx).css("padding","10px");
					$("#tbContentElement1 table").css("table-layout", "auto");
		        } else {
        			$(".table_form_info_draft").css("width","670px").css("margin","10px");
		        }
    			break;
            case editortypes['covieditor']:
                $(".table_form_info_draft").css("width","694.18px"); // 676.18(에디터에서 body width) + 18(padding 9 * 2) = 694.18px
	    		$("#tbContentElement").css("padding","9px");
        		break;
        }
		
        
        //$("[id='tbContentElement"+idx+"']").html(tbContent.replace(/\\n/gi, "").replace(/\/gwstorage\//gi, Common.getBaseConfig("BackStorage")));
		//프로젝트사이트에서 BackStorage경로에 gwstorage를 포함하여 계속 사용하여 replace가 두번치환하여 회사코드값이 두번 들어가는현상 수정_20210930
        // 이전 데이터를 위한 내용으로 신규문서와는 무관
		if(Common.getBaseConfig("BackStorage").indexOf("gwstorage") > -1){
			$("[id='tbContentElement"+idx+"']").html(tbContent.replace(/\\n/gi, ""));
		}else{
			$("[id='tbContentElement"+idx+"']").html(tbContent.replace(/\\n/gi, "").replace(/\/gwstorage\//gi, Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"))));
		}
           
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
    	coviCmn.traceLog(e);
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
    var l_selector = [];
    
    if (openMode == "P") {
    	l_selector.push(CFN_GetCtrlById("editor"));
    } else {
    	l_selector.push("#editor");
    }
    
    if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") {
    	l_selector.push(openMode == "P" ? CFN_GetCtrlById("reservedchk") : "#reservedchk");
    }

    $(l_selector.join(",")).find("*[data-type='" + Fields + "']").each(function (i, fld) {
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
		$.extend(radioVal, makeNode(selNm+ "_TEXT", obj[0].options[obj[0].selectedIndex].text));
    } else {
    	makeNode(selNm, makeNode(selNm, "0"));
		makeNode(selNm, makeNode(selNm + "_TEXT", ""));
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
    catch (ex) { coviCmn.traceLog(ex); }
}

//보존년한 create
function setSaveTerm() {
    document.getElementById("SaveTerm").options.length = 0;
    
    var oCodeList = Common.getBaseCode("SAVE_TERM");
    var Len = oCodeList.CacheData.length;
    var vCodeName = oCodeList.CacheData[0].Code;

    for (var i = 0; i < Len; i++) {
    	if(oCodeList.CacheData[i].Code != oCodeList.CacheData[i].CodeGroup){
    		makeCBOobject(oCodeList.CacheData[i].Code, CFN_GetDicInfo(oCodeList.CacheData[i].MultiCodeName, lang), document.getElementById("SaveTerm")); 			//"1년"
    	}
    }
    /*
    makeCBOobject("1", Common.getDic("lbl_apv_year_1"), document.getElementById("SaveTerm")); 			//"1년"
    makeCBOobject("3", Common.getDic("lbl_apv_year_3"), document.getElementById("SaveTerm")); 			//"3년"
    makeCBOobject("5", Common.getDic("lbl_apv_year_5"), document.getElementById("SaveTerm")); 			//"5년"
    makeCBOobject("7", Common.getDic("lbl_apv_year_7"), document.getElementById("SaveTerm")); 			//"7년"
    makeCBOobject("10", Common.getDic("lbl_apv_year_10"), document.getElementById("SaveTerm"));  		//"10년"
    makeCBOobject("99", Common.getDic("lbl_apv_permanence"), document.getElementById("SaveTerm"));       //"영구"
    //setDefaultCBOobject(getInfo("FormInstanceInfo.SaveTerm"), document.getElementById("SAVE_TERM"));
    */
    try {
        if (getInfo("FormInstanceInfo.SaveTerm") != undefined)
            setDefaultCBOobject(getInfo("FormInstanceInfo.SaveTerm"), document.getElementById("SaveTerm"));
        else
            /*setDefaultCBOobject(getInfo("PreservPeriod"), document.getElementById("SAVE_TERM"));*/  //2012-04-02 HIW
        	setDefaultCBOobject(getInfo("ExtInfo.PreservPeriod"), document.getElementById("SaveTerm"));
    }
    catch (ex) { coviCmn.traceLog(ex); }
}

//문서분류 대입 (2012-04-02 HIW)
function setDocClass() {
    try {
		if(getInfo("ExtInfo.EntDocClassID") == undefined || getInfo("ExtInfo.EntDocClassID") == ""){
	        if (document.getElementById("DocClassName") && document.getElementById("DocClassName").value == "") {
	            document.getElementById("DocClassName").value = getInfo("ExtInfo.DocClassName");
	        }
	        if (document.getElementById("DocClassID") && document.getElementById("DocClassID").value == "") {
	            document.getElementById("DocClassID").value = getInfo("ExtInfo.DocClassID");
	        }
		}else{//문서분류 계열사별 지정
			$(jQuery.parseJSON(getInfo("ExtInfo.EntDocClassID"))).each(function(i, item){
				if(item.EntCode == Common.getSession("DN_Code")){
					document.getElementById("DocClassID").value = item.docClassID;
					document.getElementById("DocClassName").value = item.docClassName;
				}
			});
		}
    }
    catch (ex) { coviCmn.traceLog(ex); }
}

function makeCBOobject(strcode, strname, cboObject) {
    try {
        var oOption = document.createElement("OPTION");
        cboObject.options.add(oOption);
        oOption.text = strname;
        oOption.value = strcode;
    } catch (e) { coviCmn.traceLog(e); }
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
    
    
    /*
    if (JSON.stringify(makeNode("BodyContext", $.parseJSON(getInfo("BodyContext")))) != JSON.stringify(sBodyContext)) {
    	jsonObj = sBodyContext;
    }
    */
    
    if(JSON.stringify(sBodyContext) != "{}") {
    	if(!orgBodyContext.BodyContext) {
    		orgBodyContext = getBodyContext();
    	} 
    	
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
            
            oldFileInfo = (getInfo("FormInstanceInfo."+$(fld).attr("id")) == undefined || getInfo("FormInstanceInfo."+$(fld).attr("id")) == "") ? "" : $.parseJSON(getInfo("FormInstanceInfo."+$(fld).attr("id")));
            newFileInfo = ($(fld).val() == "") ? "" : $.parseJSON($(fld).val());
            
            if(typeof(oldFileInfo) == "object" && typeof(newFileInfo) == "object" ){
            	var arrOldNames = new Array();
            	var arrNewNames = new Array();
            	
            	arrOldNames = $$(oldFileInfo).find("FileInfos").concat().attr("SavedName");
            	arrNewNames = $$(newFileInfo).find("FileInfos").concat().attr("SavedName");
            	
            	if(!arrNewNames)
            		arrNewNames = $$(newFileInfo).find("FileInfos").concat().attr("FileName");
            	
            	if( !arrOldNames || !arrNewNames ) {
            		isFileModified = false;
            	}
            	else {
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
            }
            	
            if(typeof(oldFileInfo) != typeof(newFileInfo))
            	isFileModified = true;
            	
            if (isFileModified) {
            	var fldVal = $(fld).val();
                $.extend(jsonObj, makeNode($(fld).attr("id"), fldVal));
            }
        } else if ($(fld).attr("id") == "ReceiptList" || $(fld).attr("id") == "ReceiveNames" || $(fld).attr("id") == "EntCode") {
        	if($(fld).val() == "@@" && getInfo("FormInstanceInfo."+$(fld).attr("id")) == "") {
        	}
        	else {
    			if ($(fld).val() != getInfo("FormInstanceInfo."+$(fld).attr("id")) && !($(fld).val() == "" && getInfo("FormInstanceInfo."+$(fld).attr("id")) == undefined)) {
    				var fldVal = $(fld).val();
    	            $.extend(jsonObj, makeNode($(fld).attr("id"), fldVal));						
    	            //수신처 수정 시 EntCode 넘기기
    	            $.extend(jsonObj, makeNode("EntCode", $("#EntCode").val()));
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
        if (getInfo("Request.mode") == "DRAFT" && m_sReqMode == "TEMPSAVE" && getInfo("Request.templatemode") == "Read") { // 회수일 경우 이전 값에서 가져 오기 
        	subJsonObj = formJson.BodyData; //getInfo("BodyData");
        } else if (getInfo("Request.templatemode") == "Read") {
        	subJsonObj = {};
        } else {
        	subJsonObj.prevBodyData = formJson.BodyData;
        	subJsonObj["BodyData"] = {};
            try {
            	subJsonObj["BodyData"]["MainTable"] = {};
            	
                var unFiltered = document.getElementsByTagName("*");
                for (var i = 0; i < unFiltered.length; i++) {
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
    
    // 수신부서 재기안 시 기록물철 추가
    if((getInfo('ExtInfo.UseMultiEditYN') != "Y" && getInfo("SchemaContext.scRecordDocOpen.isUse") == "Y" && $("#RECORD_DocInfo").val()!="" && getInfo("Request.mode")=="REDRAFT" && chkDivRec())
    	|| getInfo("Request.editmode") == "Y" && getInfo("SchemaContext.scRecordDocOpen.isUse") =="Y"){
    	subJsonObj["RecordDocInfo"] = {};
    	try{
        	var docinfo = $.parseJSON($("#RECORD_DocInfo").val());
        	subJsonObj["RecordDocInfo"] = $.extend(subJsonObj["RecordDocInfo"], docinfo );
    	}catch (e){
    		var a = e;
    	}
    }

    //last modifier info
    var _return = {};
    
    $.extend(jsonObj, subJsonObj);
    
    if (!$.isEmptyObject(jsonObj) || !$.isEmptyObject(subJsonObj)) {
        _return = $.extend({"LastModifierID" : getInfo("AppInfo.usid")}, {"FormData" : jsonObj });
    } else {
    	_return = {};
    }

    // 재기안 시 제외 결재선 변경사항 확인
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
    
    if(getInfo("Request.isLegacy") == "Y" && (getInfo("Request.legacyDataType") == "ALL" || getInfo("Request.legacyDataType") == "HTML")){
		// header,commonfield 등 공통 bodycontext 저장 필요
		//bodyContextObj = { "BodyContext" : JSON.parse(getInfo("BodyContext")) };
		bodyContextObj = getBodyContext();
		if(bodyContextObj && bodyContextObj.BodyContext) bodyContextObj = { "BodyContext" : $.extend(bodyContextObj.BodyContext,JSON.parse(getInfo("BodyContext"))) }
		else bodyContextObj = { "BodyContext" : JSON.parse(getInfo("BodyContext")) }; 
	}
    else {
    	bodyContextObj = getBodyContext();
	}
    
    // id 가 null 인 경우, 회수 시 오류 발생하여 수정함.
    $("*[data-type='dField']").each(function (i, obj) {
    	if ($(obj).attr("id") != null && $(obj).attr("id") != "") {
        	$.extend(bodyContextObj, makeNode($(obj).attr("id"), $(obj).val()));
        }
    });
    
    var subJsonObj = {};
    if ((getInfo("SubTableInfo.MainTable") != "" && getInfo("SubTableInfo.MainTable") != undefined) || (getInfo("SubTableInfo.SubTable1") != "" && getInfo("SubTableInfo.SubTable1") != undefined)) {

        if (getInfo("Request.mode") == "DRAFT" && m_sReqMode == "TEMPSAVE" && getInfo("Request.templatemode") == "Read")// 회수일 경우 이전 값에서 가져 오기
        {
        	subJsonObj["BodyData"] = formJson.BodyData; //getInfo("BodyData");
        }else if (getInfo("Request.templatemode") == "Read") {		// [2015-01-20 add] 읽기모드에서는 bodyinfo를 만들지 않도록
            subJsonObj = {};
        }else {
        	subJsonObj["BodyData"] = {};
            try {
				if (getInfo("SubTableInfo.MainTable") != "" && getInfo("SubTableInfo.MainTable") != undefined) {
	            	subJsonObj["BodyData"]["MainTable"] = {};
	            	
	                var unFiltered = document.getElementsByTagName("*");
	                for (var i = 0; i < unFiltered.length; i++) {
	                    if (unFiltered[i].getAttribute("data-type") == "smField") {
	                    	subJsonObj["BodyData"]["MainTable"] = $.extend(subJsonObj["BodyData"]["MainTable"], makeNodeByTypeForDB($(unFiltered[i]), "smField"));
	                    }
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
    
    if(getInfo('ExtInfo.UseMultiEditYN') != "Y" && getInfo("SchemaContext.scRecordDocOpen.isUse") == "Y" && $("#RECORD_DocInfo").val()!=""){
    	subJsonObj["RecordDocInfo"] = {};
    	try{
        	var docinfo = $.parseJSON($("#RECORD_DocInfo").val());
        	subJsonObj["RecordDocInfo"] = $.extend(subJsonObj["RecordDocInfo"], docinfo );
    	}catch (e){
    		var a = e;
    	}
    }
    
    returnObj["FormData"] = $.extend(bodyContextObj, subJsonObj);
    
    return returnObj;
}

//에디터 타입 참조방식 변경 : KJW : 2014-04-23 : XFROM PRJ.
function getBodyContext() {
    //debugger;
    var ret = {};

    if(isUseHWPEditor()) {
    	ret = getBodyContextHWP();
	} else if(getInfo('ExtInfo.UseMultiEditYN') == "Y") {
		ret = getBodyContextMulti();
	} else {
	    //읽기 모드 일 경우
	    if (getInfo("Request.templatemode") == "Read") {
	        ret = {};
	    }
	    else {
	        try {
	            if (editortype.is('xfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject === undefined)) {
	                //xfree iframe으로 변경
	                //document.getElementById("dhtml_body").value = document.getElementById('xFreeFrame').contentWindow.tbContentElement.getHtmlValue();
	                //UpdateImageData(); //이미지 업로드
	            	if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		document.getElementById("dhtml_body").value = coviEditor.getBody("xfree", 'tbContentElement', true);
	            	}
	            	else {
	            		document.getElementById("dhtml_body").value = coviEditor.getBody("xfree", 'tbContentElement');
	            	}
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
	            	
	            	if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		//document.getElementById("dhtml_body").value = coviEditor.getBody("dext5", 'tbContentElement', true);
	            		$("iframe[id^=tbContentElement]").each(function (i) {
	            		     var j = (i + 1) == 1 ? "" : (i + 1);
	            		     document.getElementById("dhtml_body"+j).value = coviEditor.getBody("dext5", 'tbContentElement'+j, true);  
	            		});
	            	}
	            	else {
	            		//document.getElementById("dhtml_body").value = coviEditor.getBody("dext5", 'tbContentElement');
	            		$("iframe[id^=tbContentElement]").each(function (i) {
	            		     var j = (i + 1) == 1 ? "" : (i + 1);
	            		     document.getElementById("dhtml_body"+j).value = coviEditor.getBody("dext5", 'tbContentElement'+j);  
	            		});	 
	            	}
	            }
	            else if (editortype.is('cheditor')) {
	                // TODO: Cheditor Test by Kyle 2015-08-04
	                document.getElementById("dhtml_body").value = document.getElementById('cheditorFrame').contentWindow.myeditor.getContents();
	            }
	            else if (editortype.is('synap')) {
	            	if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		document.getElementById("dhtml_body").value = coviEditor.getBody("synap", 'tbContentElement', true);
	            	}
	            	else {
	            		document.getElementById("dhtml_body").value = coviEditor.getBody("synap", 'tbContentElement');
	            	}
	            }
	            else if (editortype.is('ck')) {
	            	if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		document.getElementById("dhtml_body").value = coviEditor.getBody("ck", 'tbContentElement', true);
	            	}
	            	else {
	            		document.getElementById("dhtml_body").value = coviEditor.getBody("ck", 'tbContentElement');
	            	}
	            }
	            else if (editortype.is('webhwpctrl')) {
	            	if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		document.getElementById("dhtml_body").value = coviEditor.getBody("webhwpctrl", 'tbContentElement', true);
	            	}
	            	else {
	            		document.getElementById("dhtml_body").value = coviEditor.getBody("webhwpctrl", 'tbContentElement');
	            	}
	            }
	            else if (editortype.is('covieditor')) {
	                if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		$("iframe[id^=tbContentElement]").each(function (i) {
	            		     var j = (i + 1) == 1 ? "" : (i + 1);
	            		     document.getElementById("dhtml_body"+j).value = coviEditor.getBody("covieditor", 'tbContentElement'+j, true);  
	            		});
	                }
	                else {                	
	            		$("iframe[id^=tbContentElement]").each(function (i) {
	            		     var j = (i + 1) == 1 ? "" : (i + 1);
	            		     document.getElementById("dhtml_body"+j).value = coviEditor.getBody("covieditor", 'tbContentElement'+j);  
	            		});	                
	                }
	            }
	            else if (editortype.is('keditor')) {
	                // TODO: DEXT5 Test by Kyle 2015-07-30
	                //document.getElementById("dhtml_body").value = document.getElementById('dext5Frame').contentWindow.DEXT5.getBodyValue();
	            	
	            	if(m_sReqMode == "preview") { // 미리보기 예외처리
	            		document.getElementById("dhtml_body").value = coviEditor.getBody("keditor", 'tbContentElement', true);
	            	}
	            	else {
	            		document.getElementById("dhtml_body").value = coviEditor.getBody("keditor", 'tbContentElement');
	            	}
	            }
	        } catch (e) { coviCmn.traceLog(e); }
	        
	        var sBodyContext = makeBodyContext();
	        
	        if(getInfo("SchemaContext.scDistribution.isUse") =="Y"){//문서유통 사용
	        	sBodyContext = makeBodyContextDist();
	        }
	        
	        var editorInlineImages = {};
	        var editorBackgroundImage = {};
	        if( getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode")  == "TEMPSAVE" || getInfo("Request.editmode") == "Y"){
		        //에디터 이미지 처리
	        	var imgContentIdxArr = [];
		        
        		$("iframe[id^=tbContentElement]").each(function (i) {
	      		    var j = (i + 1) == 1 ? "" : (i + 1);
	      		    
				   	if(sBodyContext.BodyContext["tbContentElement"+j] != undefined) {
				   		//인라인
				   		if(getEditorImages("tbContentElement"+j) != "") {
					   		editorInlineImages["EditorInlineImages"+j] = getEditorImages("tbContentElement"+j);
					   		imgContentIdxArr.push(j);
				   		}
				   		//배경
				   		if(getEditorBackgroundImage("tbContentElement"+j) != "") {
					   		editorBackgroundImage["EditorBackgroundImage"+j] = getEditorBackgroundImage("tbContentElement"+j);
					   		imgContentIdxArr.push(j);
				   		}
				   	}
	      		});
	            
        		//이미지가 있는 에디터 인덱스 배열 저장 //중복 인덱스 제거
		   		editorInlineImages["EditorImagesContentIdx"] = Array.from(new Set(imgContentIdxArr));
		   		
			   	if(formJson.ExtInfo.MobileFormYN == "Y" && formJson.ExtInfo.UseEditYN == "Y") {
			   		if(sBodyContext.BodyContext.tbContentElement != undefined) {
			   			var editorContent_Text = coviEditor.getBodyText(editortype.name(), 'tbContentElement');
			   			sBodyContext["BodyContext"] = $.extend(sBodyContext["BodyContext"], {"tbContentElement_Text" : editorContent_Text});
			   		}
			   	}
			   	
			   	sBodyContext = $.extend(sBodyContext,editorInlineImages);
			   	sBodyContext = $.extend(sBodyContext,editorBackgroundImage);
		        
			   	/*ret = makeNode("BodyContext", sBodyContext);*/
			   	ret = sBodyContext;
	        }
	    }
	}
    return ret;
}

//에디터 타입 참조방식 변경 : KJW : 2014-04-23 : XFROM PRJ.
function getEditorImages(contentID) {
    //debugger;
    var ret = "";

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
        ret = "";
    }
    else {
        try {
            if (editortype.is('xfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject === undefined)) {
            	 ret =  coviEditor.getImages("xfree", 'tbContentElement');
            } else if (editortype.is('tagfree') || (editortype.is('tagfreenxfree') && window.ActiveXObject !== undefined)) {
            	 // TODO 이미지 정보 조회 작업 
            } else if (editortype.is('crosseditor') || (editortype.is('activesquaredefault') && window.ActiveXObject === undefined)) {
            	 // TODO 이미지 정보 조회 작업 
            } else if (editortype.is('activesquare') || (editortype.is('activesquaredefault') && window.ActiveXObject !== undefined)) {
            	 // TODO 이미지 정보 조회 작업 
            } else if (editortype.is('textarea')) {
            	 // TODO 이미지 정보 조회 작업 
            } else if (editortype.is('dext5')) {
            	ret =  coviEditor.getImages("dext5", contentID ? contentID : 'tbContentElement');
            }else if (editortype.is('cheditor')) {
            	 // TODO 이미지 정보 조회 작업 
            } else if (editortype.is('synap')) {
            	ret =  coviEditor.getImages("synap", 'tbContentElement');
            } else if (editortype.is('ck')) {
            	ret =  coviEditor.getImages("ck", 'tbContentElement');
            } else if (editortype.is('webhwpctrl')) {
            	ret =  coviEditor.getImages("webhwpctrl", 'tbContentElement');
            } else if (editortype.is('covieditor')) {
                ret =  coviEditor.getImages("covieditor", contentID ? contentID : 'tbContentElement');
            } else if (editortype.is('keditor')) {
                ret =  coviEditor.getImages("keditor", 'tbContentElement');
            }
        } catch (e) { coviCmn.traceLog(e); }
    }

    return ret;
}

//배경이미지 정보 - covieditor만 가능 2021-05-06
function getEditorBackgroundImage(contentID) {
    //debugger;
    var ret = "";

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
        ret = "";
    }
    else {
        try {
            if (editortype.is('covieditor')) {
                ret =  coviEditor.getBackgroundImage("covieditor", contentID ? contentID : 'tbContentElement');
                if(!ret) ret = "";
            } else {
                ret = "";
            }
        } catch (e) { coviCmn.traceLog(e); }
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
	var isEdmsPopup = false;
    if (m_oFormMenu.gDocboxMenu == "F") {
    	// EDMS 사용여부에 따라 문서관리 분류함 팝업을 선택.
    	if(getInfo("SchemaContext.scEdmsLegacy.isUse") == "Y"){
			isEdmsPopup = true;
    	}
    }
	if(isEdmsPopup == true){
		var sUrl = "/groupware/board/goSearchBoardTreePopup.do?bizSection=Doc&isEDMS=Y";// isEDMS 값에 따라 문서분류에서 승인프로세스 맵은 제외된다.
		var _win = this;
		var edmsPopupCallback = function(pFolderData){
			_win.$("#DocClassID").val(pFolderData.FolderID);
			_win.$("#DocClassName").val(pFolderData.DisplayName);
		};
		window._CallBackMethod = edmsPopupCallback;
		CFN_OpenWindow(sUrl + "", "PopupEdmsClass", "360", "505", "fix");
		
	}else{
		var fdid = document.getElementById("DocClassID").value;
		//var sUrl = "admin/goDocTreePop.do" + "?doctype=doc&domainID=" + getInfo("AppInfo.etid") + "&fdid=" + fdid + "&system=Doc&viewType=Approval";
		var sUrl = "manage/goDocTreePop.do?domainCode="+getInfo("AppInfo.etid")+"&EntName="+Base64.utf8_to_b64(getInfo("AppInfo.etnm"));

		if (openMode == "L") { //최우석
			parent.Common.ShowDialog("", "DivPop_" + openID, Common.getDic("lbl_apv_docfoldername"), sUrl + "&openID=" + openID, "331", "440", "iframe-ifNoScroll");
		} else {
			CFN_OpenWindow(sUrl, "PopupDocClass", "670", "562", "fix");
		}
	}
}

/* 문서관리시스템 분류선택창 끝 */

/*******************************************
******** 양식 파일 내 공통 함수 정리 끝 *******
*******************************************/


/*******************************************
***** 양식 파일 내 연결문서 함수 정리 시작 *****
*******************************************/
function DocLink(){
	
	var arrDocLink = [];
	var FormUrl = document.location.protocol + "//" + document.location.host + "/approval/approval_Form.do";
    var iHeight = window.screen.height - 82;
    var multiIdx;
	
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
        			businessData2 : adoc[6] || "", //ExpAppID
        			initiatorName : adoc[7] || "",
        			docNo : adoc[8] || "",
        			date : adoc[9] || ""
        		};
        	});
	    } else {
	    	arrDocLink = [];
	    }
	}
	
	var setValue = function(){
		var _temp = arrDocLink.map(function(docItem){ return docItem.processID + "@@@" + docItem.formPrefix + "@@@" + docItem.subject + "@@@" + docItem.forminstanceID + "@@@"+ docItem.bstored + "@@@" + docItem.businessData1 + "@@@" + docItem.businessData2 + "@@@" + docItem.initiatorName + "@@@" + docItem.docNo  + "@@@" + docItem.date; });
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
        	//문서연결 추가정보 사용 옵션
        	var oInfoOpt = Common.getBaseConfig('ApvDocListInfoOpt').split(';').map( function(opt) { return opt == 'Y' ? true : false; });
        	oInfoOpt = { "initiatorName": oInfoOpt[0] ? oInfoOpt[0] : false, "docNo": oInfoOpt[1] ? oInfoOpt[1] : false, "date": oInfoOpt[2] ? oInfoOpt[2] : false };
        	
            if (getInfo("Request.templatemode") == "Read") {
                bEdit = false
            } else {
                bEdit = true;
            }
	        
	        if (bEdit) {
	            var btnDiv = $("<div>").addClass("xbtn mb5 addDataBtn");
	            if ((getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBAPPROVAL")) || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "PCONSULT") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBREDRAFT") || g_szEditable == true) {
	        		btnDiv
	        			.append($("<input>", {"type": "button", "class" : "smButton ml5", "value" : Common.getDic("lbl_apv_link_delete"), "onClick" : "docLinks.deleteItem()"}))
	        			.append($("<input>", {"type": "button", "class" : "smButton ml5", "value" : "∧", "onClick" : "docLinks.moveItem('up')"}))
	        			.append($("<input>", {"type": "button", "class" : "smButton ml5", "value" : "∨", "onClick" : "docLinks.moveItem('down')"}))
	            }
	            $("#DocLinkInfo" + multiIdx).append(btnDiv);
	        }
	        
            var docTable =  $("<table>").addClass("tableStyle linePlus");
            
            //문서연결 - colgroup
        	var docColGroup = $("<colgroup>");
        	if(bEdit) 					docColGroup.append($("<col>", {"style": "width: 36px"}));
        	docColGroup.append($("<col>", {"style": "width: *"}));
        	if(oInfoOpt.initiatorName) 	docColGroup.append($("<col>", {"style": "width: 90px"}));
        	if(oInfoOpt.docNo) 			docColGroup.append($("<col>", {"style": "width: 160px"}));
        	if(oInfoOpt.date) 			docColGroup.append($("<col>", {"style": "width: 130px"}));
        	
            //문서연결 - header
            var docHead =  $("<thead>");
            var docThRow = $("<tr>");
            if(bEdit) 					docThRow.append($("<th>", {"scope": "col"}).append($("<input>", {"type":"checkbox", "onClick" : "docLinks.selectItemAll($(this).prop('checked'));"})));
            docThRow.append($("<th>", {"scope": "col"}).text(Common.getDic("lbl_apv_subject")));
        	if(oInfoOpt.initiatorName)	docThRow.append($("<th>", {"scope": "col"}).text(Common.getDic("lbl_apv_writer")));
        	if(oInfoOpt.docNo)			docThRow.append($("<th>", {"scope": "col"}).text(Common.getDic("lbl_apv_setschema_tab06")));
        	if(oInfoOpt.date)		docThRow.append($("<th>", {"scope": "col"}).text(Common.getDic("lbl_RepeateDate")));
            docHead.append(docThRow);
            
            //문서연결 - body
            var docBody =  $("<tbody>").addClass("fileInfo");
	        arrDocLink.map(function(docItem){
	            var docRow =  $("<tr>");
	            var iWidth = 790;
	            if (IsWideOpenFormCheck(docItem.formPrefix)) {
	                iWidth = 1070;
	            }
	            
	            //date 포맷, 타임존 설정
	            docItem.date = CFN_TransLocalTime(docItem.date,_ServerDateFormat);
	            
	            var url = FormUrl + "?mode=COMPLETE";
	       	 	url += "&processID=" + docItem.processID + "&forminstanceID=" 
	   	 		+ (typeof docItem.forminstanceID != "undefined" ? docItem.forminstanceID : "&archived=true") 
	   	 		+ "&bstored=" + (typeof docItem.bstored != "undefined" ? docItem.bstored : "false")
	   	 		+ "&ownerProcessId=" + (getInfo("ProcessInfo.ProcessID") == undefined ? "" : getInfo("ProcessInfo.ProcessID")); // 현문서 ProcessId [2021-01-22 add]
		        if(typeof docItem.businessData2 != "undefined" && docItem.businessData2 != "undefined")
		        	url += "&ExpAppID="+docItem.businessData2+"&taskID="; // 경비 팝업에서 필요한 파라미터 추가
	
	            if (bEdit) {
	            	//체크박스
	            	if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBAPPROVAL") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "PCONSULT") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBREDRAFT") || g_szEditable == true) {
	            		docRow.append($("<td>").append($("<input>", {"type":"checkbox", "id":"chkDoc", "name" : "_" + docItem.processID, "value" : docItem.processID, "class" : "td_check"})));
	            	}
	            	//제목
	            	docRow.append($("<td>").append($("<span>", {"class" : "td_txt","onmouseover":'this.style.color=\"#2f71ba\"', "onmouseout" : 'this.style.color=\"#111111\"', "style" : 'cursor:pointer;', "onClick" : "CFN_OpenWindow('"+url+"', '', '"+iWidth+"', '"+iHeight+"', 'scroll')"}).text(docItem.subject)));
	            	//기안자
	            	if(oInfoOpt.initiatorName) docRow.append($("<td>").text(CFN_GetDicInfo(docItem.initiatorName)));
	            	//문서번호
	            	if(oInfoOpt.docNo) docRow.append($("<td>").text(docItem.docNo));
	            	//일시
	            	if(oInfoOpt.date) docRow.append($("<td>").text(docItem.date));
	            } else {
	                if (bDisplayOnly) {
		            	//제목
	                	docRow.append($("<td>").text(docItem.subject));
		            	//기안자
		            	if(oInfoOpt.initiatorName) docRow.append($("<td>").text(CFN_GetDicInfo(docItem.initiatorName)));
		            	//문서번호
		            	if(oInfoOpt.docNo) docRow.append($("<td>").text(docItem.docNo));
		            	//일시
		            	if(oInfoOpt.date) docRow.append($("<td>").text(docItem.date));
	                } else {
		            	//제목
	                	docRow.append($("<td>").append($("<span>", {"class" : "txt_gn11_blur","onmouseover":'this.style.color=\"#2f71ba\"', "onmouseout" : 'this.style.color=\"#111111\"', "style" : 'cursor:pointer;', "onClick" : "CFN_OpenWindow('"+url+"', '', '"+iWidth+"', '"+iHeight+"', 'scroll')"}).text(docItem.subject)));
		            	//기안자
		            	if(oInfoOpt.initiatorName) docRow.append($("<td>").text(CFN_GetDicInfo(docItem.initiatorName)));
		            	//문서번호
		            	if(oInfoOpt.docNo) docRow.append($("<td>").text(docItem.docNo));
		            	//일시
		            	if(oInfoOpt.date) docRow.append($("<td>").text(docItem.date));
	                }
	            }

	            docRow.children().attr('style', 'text-align: center; border: none !important; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;').eq(bEdit ? 1 : 0).css('text-align', '');
	            docBody.append(docRow);
	            return docBody.html();
	        });
	        
        	docTable.append(docColGroup);
        	docTable.append(docHead);
        	docTable.append(docBody);
	        $("#DocLinkInfo" + multiIdx).append($("<div>").append(docTable));
        }
	}
	
	this.selectItemAll = function(mode){
		if(mode){
			$("#DocLinkInfo" + multiIdx).find("input[id='chkDoc']").prop("checked", true);
		} else {
			$("#DocLinkInfo" + multiIdx).find("input[id='chkDoc']").prop("checked", false);
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
	
	this.deleteItem = function(){
	    var chkDoc = $("#DocLinkInfo"+multiIdx).find("input[id='chkDoc']");
	    var tmp = "";
	    
	    if (chkDoc.length > 0) {
            for (var j = chkDoc.length - 1; j >= 0; j--) {
	            if ($(chkDoc).eq(j).is(":checked")) {
	            	arrDocLink.splice(j, 1);
	            }
            }
	        
		    setValue();
		    this.display();
	    }
	}
	
	this.moveItem = function(mode){
	    var docs =  $("#DocLinkInfo"+multiIdx).find("input[id='chkDoc']");
	    var chkDocs = $("#DocLinkInfo"+multiIdx).find("input[id='chkDoc']:checked");
	    var refreshIdx = [];
		var _moveItem;
		
		if(mode === "up") {
			if(docs.index(chkDocs.eq(0)) > 0){
				chkDocs.each(function(itemIdx, chkItem){
					var idx = docs.index(chkItem);
					if(idx > 0){
						_moveItem = arrDocLink[idx];
						arrDocLink.splice(idx, 1);
						arrDocLink.splice(idx - 1, 0, _moveItem);
						refreshIdx.push(idx - 1);
					}
				});
			}
		} else if(mode === "down"){
			if(docs.index(chkDocs.eq(chkDocs.length - 1)) < docs.length - 1){
				for(var itemIdx = chkDocs.length - 1; itemIdx >= 0; itemIdx --){
					var idx = docs.index(chkDocs.eq(itemIdx));
					if(idx < docs.length - 1){
						_moveItem = arrDocLink[idx];
						arrDocLink.splice(idx, 1);
						arrDocLink.splice(idx + 1, 0, _moveItem);
						refreshIdx.push(idx + 1);
					}
				}
			}
		}

		if(refreshIdx.length > 0){
		    setValue();
		    this.display();
		    
		    $(refreshIdx).each(function(idx, idxItem){
		    	$("#DocLinkInfo"+multiIdx).find("input[id='chkDoc']").eq(idxItem).prop("checked", true);
		    });		    
		}
	}
};

function EDMSDocLink(){
	
	var arrDocLink = [];
	
	this.init = function(){
		refresh();
        this.display();
	}
	
	var refresh = function(){
		var szdoclinksinfo = "";
	    var szdoclinks = "";
		
		if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBAPPROVAL") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBREDRAFT") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "PCONSULT") || g_szEditable == true) {
			try { szdoclinks = document.getElementById("EDMSDocLinks").value; } catch (e) { coviCmn.traceLog(e); }
		} else {
			try { szdoclinks = document.getElementById("EDMSDocLinks").value; } catch (e) { coviCmn.traceLog(e); }
			if (szdoclinks == "") {
				try { document.getElementById("EDMSDocLinks").value = szdoclinks; } catch (e) { coviCmn.traceLog(e); }
			}
		}
		
	    //DOCLINKS 값에 undefined 가 들어 가서 오류남. 원인 찾기전 임시로 작성
	    szdoclinks = szdoclinks.replace("undefined^", "");
	    szdoclinks = szdoclinks.replace("undefined", "");

	    if(szdoclinks){
	        var adoclinks = szdoclinks.split("^^^");
        	arrDocLink = adoclinks.map(function(docItem){
        		var adoc = docItem.split("@@@");
        		return {
        			bizSection : adoc[0] || "",
        			menuID : adoc[1] || 0,
        			version : adoc[2] || 0,
        			folderID : adoc[3],
        			messageID : adoc[4],
					subject : adoc[5],
					creatorName : adoc[6],
					number : adoc[7],
					createDate : adoc[8]
        		};
        	});
	    } else {
	    	arrDocLink = [];
	    }
	}
	
	var setValue = function(){
		var _temp = arrDocLink.map(function(docItem){ return docItem.bizSection + "@@@" + docItem.menuID + "@@@" + docItem.version + "@@@" + docItem.folderID + "@@@"+ docItem.messageID + "@@@"+ docItem.subject + "@@@"+ docItem.creatorName + "@@@"+ docItem.number + "@@@"+ docItem.createDate; });
		$("#EDMSDocLinks").val(_temp.join("^^^"));
	}
	
	this.display = function(){
		var bEdit = false;

        $("#EDMSDocLinkInfo").empty();
        
        if(arrDocLink.length > 0){
        	//EDMS 문서연결 추가정보 사용 옵션
        	var oInfoOpt = Common.getBaseConfig('ApvEdmsDocListInfoOpt').split(';').map( function(opt) { return opt == 'Y' ? true : false; });
        	oInfoOpt = { "creatorName": oInfoOpt[0] ? oInfoOpt[0] : false, "number": oInfoOpt[1] ? oInfoOpt[1] : false, "createDate": oInfoOpt[2] ? oInfoOpt[2] : false };
        	
            if (getInfo("Request.templatemode") == "Read") {
                bEdit = false
            } else {
                bEdit = true;
            }
	        
	        if (bEdit) {
	            var btnDiv = $("<div>").addClass("xbtn mb5 addDataBtn");
	            if ((getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBAPPROVAL")) || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "PCONSULT") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBREDRAFT") || g_szEditable == true) {
	        		btnDiv
	        			.append($("<input>", {"type": "button", "class" : "smButton ml5", "value" : Common.getDic("lbl_apv_link_delete"), "onClick" : "EDMSDocLinks.deleteItem()"}))
	        			.append($("<input>", {"type": "button", "class" : "smButton ml5", "value" : "∧", "onClick" : "EDMSDocLinks.moveItem('up')"}))
	        			.append($("<input>", {"type": "button", "class" : "smButton ml5", "value" : "∨", "onClick" : "EDMSDocLinks.moveItem('down')"}))
	            }
	            $("#EDMSDocLinkInfo").append(btnDiv);
	        }

            var docTable =  $("<table>").addClass("tableStyle linePlus");

            //EDMS 문서연결 - colgroup
        	var docColGroup = $("<colgroup>");
        	if(bEdit) 					docColGroup.append($("<col>", {"style": "width: 36px;"}));
        	docColGroup.append($("<col>", {"style": "width: *"}));
        	if(oInfoOpt.creatorName) 	docColGroup.append($("<col>", {"style": "width: 90px;"}));
        	if(oInfoOpt.number) 		docColGroup.append($("<col>", {"style": "width: 160px;"}));
        	if(oInfoOpt.createDate) 	docColGroup.append($("<col>", {"style": "width: 130px;"}));
        	
            //EDMS 문서연결 - header
            var docHead =  $("<thead>");
            var docThRow = $("<tr>");
            if(bEdit) 					docThRow.append($("<th>", {"scope": "col"}).append($("<input>", {"type":"checkbox", "onClick" : "EDMSDocLinks.selectItemAll($(this).prop('checked'));"})));
            docThRow.append($("<th>", {"scope": "col"}).text(Common.getDic("lbl_apv_subject")));
        	if(oInfoOpt.creatorName)	docThRow.append($("<th>", {"scope": "col"}).text(Common.getDic("lbl_Register")));
        	if(oInfoOpt.number)			docThRow.append($("<th>", {"scope": "col"}).text(Common.getDic("lbl_apv_setschema_tab06")));
        	if(oInfoOpt.createDate)		docThRow.append($("<th>", {"scope": "col"}).text(Common.getDic("lbl_RegistDateHour")));
            docHead.append(docThRow);
            
            //EDMS 문서연결 - body
            var docBody =  $("<tbody>");
	        arrDocLink.map(function(docItem){
	            var docRow =  $("<tr>");
	            
	            //date 포맷, 타임존 설정
	            docItem.createDate = CFN_TransLocalTime(docItem.createDate,_ServerDateFormat);
	            
	            if (bEdit) {
	            	//체크박스
	            	if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBAPPROVAL") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "PCONSULT") || (getInfo("Request.loct") == "APPROVAL" && getInfo("Request.mode") == "SUBREDRAFT") || g_szEditable == true) {
	            		docRow.append($("<td>").append($("<input>", {"type":"checkbox", "id":"chkDoc", "name" : "_" + docItem.messageID, "value" : docItem.messageID, "class" : "td_check"})));
	            	}
	            	//제목
	            	docRow.append($("<td>").append($("<span>", {"class" : "td_txt","onmouseover":'this.style.color=\"#2f71ba\"', "onmouseout" : 'this.style.color=\"#111111\"', "style" : 'cursor:pointer;', "onClick" : "EDMSDocLinks.viewPopup('"+docItem.bizSection+"','"+docItem.menuID+"','"+docItem.version+"','"+docItem.folderID+"','"+docItem.messageID+"')"}).text(docItem.subject)));
	            	//등록자
		            if(oInfoOpt.creatorName) docRow.append($("<td>").text(docItem.creatorName));
		            //문서번호
	            	if(oInfoOpt.number) docRow.append($("<td>").text(docItem.number));
	            	//등록일시
	            	if(oInfoOpt.createDate) docRow.append($("<td>").text(docItem.createDate));
	            } else {
	                if (bDisplayOnly) {
		            	//제목
	                	docRow.append($("<td>").append(docItem.subject));
	                	//등록자
			            if(oInfoOpt.creatorName) docRow.append($("<td>").text(docItem.creatorName));
			            //문서번호
		            	if(oInfoOpt.number) docRow.append($("<td>").text(docItem.number));
		            	//등록일시
		            	if(oInfoOpt.createDate) docRow.append($("<td>").text(docItem.createDate));
	                } else {
		            	//제목
	                	docRow.append($("<td>").append($("<span>", {"class" : "txt_gn11_blur","onmouseover":'this.style.color=\"#2f71ba\"', "onmouseout" : 'this.style.color=\"#111111\"', "style" : 'cursor:pointer;', "onClick" : "EDMSDocLinks.viewPopup('"+docItem.bizSection+"','"+docItem.menuID+"','"+docItem.version+"','"+docItem.folderID+"','"+docItem.messageID+"')"}).text(docItem.subject)));
	                	//등록자
			            if(oInfoOpt.creatorName) docRow.append($("<td>").text(docItem.creatorName));
			            //문서번호
		            	if(oInfoOpt.number) docRow.append($("<td>").text(docItem.number));
		            	//등록일시
		            	if(oInfoOpt.createDate) docRow.append($("<td>").text(docItem.createDate));
	                }
	            }

	            docRow.children().attr('style', 'text-align: center; border: none !important; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;').eq(bEdit ? 1 : 0).css('text-align', '');
	            docBody.append(docRow);
	            return docBody.html();
	        });

        	docTable.append(docColGroup);
        	docTable.append(docHead);
        	docTable.append(docBody);
	        $("#EDMSDocLinkInfo").append($("<div>").append(docTable));
        }
	}
	
	this.selectItemAll = function(mode){
		if(mode){
			$("#EDMSDocLinkInfo").find("input[id='chkDoc']").prop("checked", true);
		} else {
			$("#EDMSDocLinkInfo").find("input[id='chkDoc']").prop("checked", false);
		}
	}
	
	this.addItem = function(addItems){
		$.each(addItems, function(nIdx, newItem){
			var isDup = false;
			var param = {
        			bizSection : newItem.BizSection,
        			menuID : newItem.MenuID,
        			version : newItem.Version,
        			folderID : newItem.FolderID,
        			messageID : newItem.MessageID,
					subject : newItem.DisplayName,
					creatorName : newItem.CreatorName,
					number : newItem.Number,
					createDate : newItem.CreateDate
        		};
				
			//중복 제거
			$.each(arrDocLink, function(dIdx, docItem){
				if(docItem.messageID === param.messageID){
					isDup = true;
				}
			});
			
			if(!isDup){
				arrDocLink.push(param);
			}
		});

	    setValue();
	    this.display();
	}
	
	this.deleteItem = function(){
	    var chkDoc = $("#EDMSDocLinkInfo").find("input[id='chkDoc']");
	    var tmp = "";
	    
	    if (chkDoc.length > 0) {
            for (var j = chkDoc.length - 1; j >= 0; j--) {
	            if ($(chkDoc).eq(j).is(":checked")) {
	            	arrDocLink.splice(j, 1);
	            }
            }
	        
		    setValue();
		    this.display();
	    }
	}
	
	this.moveItem = function(mode){
	    var docs =  $("#EDMSDocLinkInfo").find("input[id='chkDoc']");
	    var chkDocs = $("#EDMSDocLinkInfo").find("input[id='chkDoc']:checked");
	    var refreshIdx = [];
		var _moveItem;
		
		if(mode === "up") {
			if(docs.index(chkDocs.eq(0)) > 0){
				chkDocs.each(function(itemIdx, chkItem){
					var idx = docs.index(chkItem);
					if(idx > 0){
						_moveItem = arrDocLink[idx];
						arrDocLink.splice(idx, 1);
						arrDocLink.splice(idx - 1, 0, _moveItem);
						refreshIdx.push(idx - 1);
					}
				});
			}
		} else if(mode === "down"){
			if(docs.index(chkDocs.eq(chkDocs.length - 1)) < docs.length - 1){
				for(var itemIdx = chkDocs.length - 1; itemIdx >= 0; itemIdx --){
					var idx = docs.index(chkDocs.eq(itemIdx));
					if(idx < docs.length - 1){
						_moveItem = arrDocLink[idx];
						arrDocLink.splice(idx, 1);
						arrDocLink.splice(idx + 1, 0, _moveItem);
						refreshIdx.push(idx + 1);
					}
				}
			}
		}

		if(refreshIdx.length > 0){
		    setValue();
		    this.display();
		    
		    $(refreshIdx).each(function(idx, idxItem){
		    	$("#EDMSDocLinkInfo").find("input[id='chkDoc']").eq(idxItem).prop("checked", true);
		    });		    
		}
	}
	
	this.viewPopup = function(pBizSection, pMenuID, pVersion, pFolderID, pMessageID){
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", pBizSection, pMenuID, pVersion, pFolderID, pMessageID);
		CFN_OpenWindow(url, "boardViewPop", "1080px", "600px", "fix");
	}
};

var docLinks = new DocLink();
var EDMSDocLinks = new EDMSDocLink();

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
            var g_szURL = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + "e-sign/Approval/IMAGEATTACH"; //"http://" + document.location.host + // CP에서는 고려되지 않음 추후 사용시 sys_storage정보를 이용해야됨 
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

function CoviWindow(fileName, windowName, theWidth, theHeight, etcParam) {
    var objNewWin;
    var x = theWidth;
    var y = theHeight;

    var sx = window.screen.width / 2 - x / 2;
    var sy = window.screen.height / 2 - y / 2 - 40;

    if (etcParam == 'fix') {
        etcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=0";
    }
    else if (etcParam == 'scroll') {
        etcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=1,resizable=1";
    }
    else if (etcParam == 'resize') {
        etcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=1";
    }

    if (sy < 0) {
        sy = 0;
    }

    var sz = ",top=" + sy + ",left=" + sx;

    if (windowName == "newMessageWindow" || windowName == "") {
        windowName = new String(Math.round(coviCmn.random() * 100000));
    }

    objNewWin = window.open(fileName, windowName, etcParam + ",width=" + x + ",height=" + y + sz);
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
	
	var $file_box = $("<ul>",{ "class" : "file_box" }).append( $("<li>",{ "class" : "boxPoint" }) );	
	$file_box.append(
		g_commentAttachList[idx].map( function( item,idx ){ return $("<li>").append(  $("<a>",{ "text" : item.name }).data('item',item)  ) })
	).find('a').on('click',function(){ 
		var obj = $(this).data('item');
		attachFileDownLoadCall_comment( obj.id, obj.savedname, obj.FileToken );
	});	
	$(pObj).parent().append($file_box);	
	
	/*var vHtml = "<ul class='file_box'>";
	vHtml += "<li class='boxPoint'></li>";
	
	for(var i=0; i<g_commentAttachList[idx].length;i++){
		vHtml += "<li><a onclick='attachFileDownLoadCall_comment("+g_commentAttachList[idx][i].id+", \"" + g_commentAttachList[idx][i].savedname + "\", \"" + g_commentAttachList[idx][i].FileToken + "\")'>"+g_commentAttachList[idx][i].name+"</a></li>";
	}	
	vHtml += "</ul>";
	$(pObj).parent().append(vHtml);*/
}

// 문서유통 단건 헤더 이벤트
function g_chkdocInfo(obj){
	if(getInfo("Request.templatemode") != "Read" || getInfo("Request.mode") == "REDRAFT"){
		var idx = '1';
		var id = $(obj).attr("id");
		var savedVal = "";
		
		if(id == "RELEASE_CHECK") {//공개여부
			savedVal = $(obj).val();
			
			if(savedVal == "1"){
				$("#RELEASE_CHECK").val(savedVal);
				$("#chk_secrecy").prop("checked", false);
				$("#RELEASE_CODE").hide();
			}else{
				$("#RELEASE_CHECK").val(savedVal);
				$("#chk_secrecy").prop("checked", "checked");
				$("#RELEASE_CODE").show();
			}
			if($("[name='MULTI_"+id+"']").length > 0) $("[name='MULTI_"+id+"']").eq(idx).val(savedVal); //document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
			$(obj).val(savedVal);
		}
		else if(id == "RELEASE_CHECK_rec") {//공개여부
			savedVal = $(obj).find('input:checked').val();
			
			if(savedVal == "1"){
				$("#RELEASE_CHECK_rec").val(savedVal);
				$("#chk_secrecy_rec").prop("checked", false);
			}else{
				$("#RELEASE_CHECK_rec").val(savedVal);
				$("#chk_secrecy_rec").prop("checked", "checked");
			}
			if($("[name='MULTI_"+id+"']").length > 0) $("[name='MULTI_"+id+"']").eq(idx).val(savedVal); //document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
			$(obj).val(savedVal);
		}
		else if(id == "CHK_MANUAL_APV"){
			savedVal = $(obj).is(":checked");
			$("#CHK_MANUAL_APV").val(savedVal ? "Y" : "N");
			if(savedVal == true){
				savedVal = 'Y';
				$("#CHK_MANUAL_APV").prop("checked", "checked");
				$("#MANUAL_APV").val("Y");
				$("#RECEIVE_CHECK").val("indoc"); //$("#RECEIVE_CHECK_indoc").prop("checked","checked");
				if($("[name='MULTI_RECEIVE_CHECK']").length > 0) $("[name='MULTI_RECEIVE_CHECK']").eq(idx).val("indoc"); //document.getElementsByName("MULTI_RECEIVE_CHECK")[idx].value = "indoc";
				$("#btMultiReceive").hide();
				$("#RECEIVE_CHECK").attr("disabled",true); // $("#RECEIVE_CHECK_indoc").attr("disabled",true); $("#RECEIVE_CHECK_else").attr("disabled",true);
				Common.Warning(Common.getDic("msg_selectPaperScanfile"));//종이접수문서 스캔 파일을 첨부하여 기안해야 합니다.
			}else{
				savedVal = 'N';
				$("#CHK_MANUAL_APV").prop("checked", false);
				$("#MANUAL_APV").val("N");
				$("#RECEIVE_CHECK").val("else"); //$("#RECEIVE_CHECK_else").prop("checked","checked");
				$("#btMultiReceive").show();
				$("#RECEIVE_CHECK").attr("disabled",true); // $("#RECEIVE_CHECK_indoc").attr("disabled",false); $("#RECEIVE_CHECK_else").attr("disabled",false);
			}
			if($("[name='MULTI_MANUAL_APV']").length > 0) $("[name='MULTI_MANUAL_APV']").eq(idx).val(savedVal); //document.getElementsByName("MULTI_MANUAL_APV")[idx].value = savedVal;
		}
		else if(id == "RECEIVE_CHECK"){
			savedVal= $(obj).val(); //$(obj).find("input:checked").val();
			if(savedVal == "indoc"){//내부결재
				//$("#btMultiReceive").hide();
				document.getElementById('RECEIVEGOV_NAMES').value = '';
				document.getElementById('ReceiveNames').value = '';
				document.getElementById('DocRecLine').value = '';
				$("#btRecDept").hide();	
				$("#ReceiveLine").hide();
			}
			else if(savedVal == "else"){//시행발송
				//$("#btMultiReceive").show();
				$("#btRecDept").show();
			}
			//document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
		}	
	}
}

function g_chkdocInfoHWP(obj){
	if(getInfo("Request.templatemode") != "Read" || getInfo("Request.mode") == "REDRAFT"){
		var idx = '1';
		var id = $(obj).attr("id");
		var savedVal = "";
		
		if(id == "RELEASE_CHECK") {//공개여부
			savedVal = $(obj).val(); //$(obj).find('input:checked').val();
			
			if(savedVal == "1"){
				$("#RELEASE_CHECK").val(savedVal);
				$("#chk_secrecy").prop("checked", false);
				$("#RELEASE_CODE").hide();
			}else{
				$("#RELEASE_CHECK").val(savedVal);
				$("#chk_secrecy").prop("checked", "checked");
				$("#RELEASE_CODE").show();
			}
			if($("[name='MULTI_"+id+"']").length > 0) $("[name='MULTI_"+id+"']").eq(idx).val(savedVal); //document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
			$(obj).val(savedVal);
		}
		else if(id == "RELEASE_CHECK_rec") {//공개여부
			savedVal = $(obj).find('input:checked').val();
			
			if(savedVal == "1"){
				$("#RELEASE_CHECK_rec").val(savedVal);
				$("#chk_secrecy_rec").prop("checked", false);
			}else{
				$("#RELEASE_CHECK_rec").val(savedVal);
				$("#chk_secrecy_rec").prop("checked", "checked");
			}
			if($("[name='MULTI_"+id+"']").length > 0) $("[name='MULTI_"+id+"']").eq(idx).val(savedVal); //document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
			$(obj).val(savedVal);
		}
		else if(id == "CHK_MANUAL_APV"){
			savedVal = $(obj).is(":checked");
			$("#CHK_MANUAL_APV").val(savedVal ? "Y" : "N");
			if(savedVal == true){
				savedVal = 'Y';
				$("#CHK_MANUAL_APV").prop("checked", "checked");
				$("#MANUAL_APV").val("Y");
				$("#RECEIVE_CHECK").val("indoc"); //$("#RECEIVE_CHECK_indoc").prop("checked","checked");
				if($("[name='MULTI_RECEIVE_CHECK']").length > 0) $("[name='MULTI_RECEIVE_CHECK']").eq(idx).val("indoc"); //document.getElementsByName("MULTI_RECEIVE_CHECK")[idx].value = "indoc";
				$("#btMultiReceive").hide();
				$("#RECEIVE_CHECK").attr("disabled",true); // $("#RECEIVE_CHECK_indoc").attr("disabled",true); $("#RECEIVE_CHECK_else").attr("disabled",true);
				Common.Warning(Common.getDic("msg_selectPaperScanfile"));//종이접수문서 스캔 파일을 첨부하여 기안해야 합니다.
			}else{
				savedVal = 'N';
				$("#CHK_MANUAL_APV").prop("checked", false);
				$("#MANUAL_APV").val("N");
				$("#RECEIVE_CHECK").val("else"); //$("#RECEIVE_CHECK_else").prop("checked","checked");
				$("#btMultiReceive").show();
				$("#RECEIVE_CHECK").attr("disabled",true); //$("#RECEIVE_CHECK_indoc").attr("disabled",false); $("#RECEIVE_CHECK_else").attr("disabled",false);
			}
			if($("[name='MULTI_MANUAL_APV']").length > 0) $("[name='MULTI_MANUAL_APV']").eq(idx).val(savedVal); //document.getElementsByName("MULTI_MANUAL_APV")[idx].value = savedVal;
		}
		else if(id == "RECEIVE_CHECK"){
			savedVal= $(obj).val(); //$(obj).find("input:checked").val();
			if(savedVal == "indoc"){//내부결재
				$("#btMultiReceive").hide();
				//$("#btRecDept").hide();	
			}
			else if(savedVal == "else"){//시행발송
				$("#btMultiReceive").show();
				//$("#btRecDept").show();
			}
			if($("[name='MULTI_"+id+"']").length > 0) $("[name='MULTI_"+id+"']").eq(idx).val(savedVal); // document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
		}	
	}
}