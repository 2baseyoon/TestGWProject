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

// 대성 선결재 위해서 추가함
var m_ActiveTaskId = "";
var m_ApvPersonObj = {};
var m_ApvPersonCnt = 0;

var m_arrConverImgArr = []; //웹한글 이미지 변환
var m_initMulti = false;//다안기안 초기 로딩 체크
var m_firstIDx = 1;//다안기안 1안
var m_legacyChked = 0;//문서유통 기안시 xml사이즈 체크여부 

var a, ua = navigator.userAgent;

this.agent = {
    safari: ((a = ua.split('AppleWebKit/')[1]) ? (a.split('(')[0]).split('.')[0] : 0) >= 412,
    konqueror: ((a = ua.split('Konqueror/')[1]) ? a.split(';')[0] : 0) >= 3.4,
    mozes: ((a = ua.split('Gecko/')[1]) ? a.split(" ")[0] : 0) >= 20011128,
    opera: (!!window.opera) && (document.body.style.opacity == ""),
    msie: (!!window.ActiveXObject) ? (!!(new ActiveXObject("Microsoft.XMLHTTP"))) : (navigator.appName == 'Microsoft Internet Explorer') ? true : false
} //safari, konqueror, opera url 한글 인코딩 처리를 위해추가

var btoUtf = ((this.agent.safari || this.agent.konqueror || this.agent.opera) ? false : true);
var sessionObjFormMenu = Common.getSession(); //전체호출

function initOnloadformmenu() {
	
    /* 보존년한 변경 미구현
    if ('DELETE_TARGET_DEPART' == getInfo("Request.gloct")) {
        $('#btPreserveDateUpdate').show();
    }
    */

    //재사용버튼 클릭으로 들어오는 경우 처리
    //Forms.js commonDataChanger()로 재사용시 데이터 처리 이동
    if (getInfo("Request.reuse") == "Y" || getInfo("Request.reuse") == "P" || getInfo("Request.reuse") == "YH") {
        if (getInfo("Request.mode") != "DRAFT" && getInfo("Request.mode") != "TEMPSAVE") {
            m_sReqMode = "DRAFT";
        }

        document.getElementById("btReUse").style.display = "none";
        document.getElementById("btPrint").style.display = "none"; 
        document.getElementById("btCommentView").style.display = "none";
        document.getElementById("btCirculate").style.display = "none"; 
        document.getElementById("btCirculate_View").style.display = "none"; 
        document.getElementById("btHistory").style.display = "none"; 
        document.getElementById("btReceiptView").style.display = "none"; 
        document.getElementById("btPcSave").style.display = "none"; 
        document.getElementById("btPrintView").style.display = "none"; 
        document.getElementById("btMailSend").style.display = "none";

        //연결문서 & 업무메뉴얼 연결
        if (getInfo("Request.loct") != "DRAFT" && getInfo("Request.loct") != "TEMPSAVE") {
        }
        else {
            document.getElementById("btDocLinked").style.display = "";
            
            if(getInfo("SchemaContext.scRecordDocOpen.isUse") =="Y" && document.getElementById("btRecordDoc")){//기록물철
            	document.getElementById("btRecordDoc").style.display = "";
            }
            
            if(getInfo("SchemaContext.scDistribution.isUse") =="Y" && document.getElementById("tblDistDocProperties")){//문서유통>공개/비공개
            	document.getElementById("tblDistDocProperties").style.display = "";
            }
        }

        if (g_szEditable) {
            document.getElementById("btDocLinked").style.display = ""; 
            document.getElementById("btPreView").style.display = ""; 
        }
    }

    if (getInfo("Request.loct") != "DRAFT" && getInfo("Request.loct") != "TEMPSAVE") {
    }
    else {
        document.getElementById("btDocLinked").style.display = "";
        // 전결규정   Common.getBaseConfig("IS_RULEAPV") == "Y" ??
        
        if (Common.getBaseConfig("RuleBtnApvMgr") != "Y") { //전결규정 버튼을 결재선 팝업 내에서 표시할 것인지
        	var ruleitemlist = getInfo("ExtInfo.RuleItemLists");
        	if (ruleitemlist != "" && ruleitemlist != "[]" && ruleitemlist != undefined) {
				// 본인 회사 기준 체크
				var oTemp = JSON.parse(ruleitemlist).filter(function(rule) {
					return rule.DNCode == Common.getSession("DN_Code");
				});
				// 그룹사 기준 체크 > 전결규정 팝업에서 본인회사것만 나오므로 통일
				/*
				if (oTemp.length == 0) {
					oTemp = JSON.parse(ruleitemlist).filter(function(rule) {
						return rule.DNCode == "ORGROOT";
					});
				}
				*/
				if(oTemp.length > 0) document.getElementById("btnRuleApv").style.display = "";
        	}
    	}
        
        if(getInfo("SchemaContext.scRecordDocOpen.isUse") =="Y" && document.getElementById("btRecordDoc")){//기록물철
        	document.getElementById("btRecordDoc").style.display = "";
        }
        
        if(getInfo("SchemaContext.scDistribution.isUse") =="Y" && document.getElementById("tblDistDocProperties")){//문서유통>공개/비공개
        	document.getElementById("tblDistDocProperties").style.display = "";
        }
    }

    if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") {
        g_szEditable = true;
    }
    else if (getInfo("Request.editmode") == "Y") {
        g_szEditable = true;
    }

    if (g_szEditable) {
        document.getElementById("btDocLinked").style.display = "";
        document.getElementById("btPreView").style.display = "";
        
        if(getInfo("SchemaContext.scRecordDocOpen.isUse") =="Y"){//기록물철
        	document.getElementById("btRecordDoc").style.display = "";
        }
        
        if(getInfo("SchemaContext.scDistribution.isUse") =="Y"){//문서유통>공개/비공개
        	//document.getElementById("tblDistDocProperties").style.display = "";
        }
    }

    if (getInfo("SchemaContext.scCMB.isUse") == null || getInfo("SchemaContext.scCMB.isUse") == "N") {
        m_oFormEditor = window.document;//parent.editor
        m_oFormReader = window.document;//parent.redear

        if (admintype != "ADMIN" && getInfo("Request.loct") == "APPROVAL"
            && (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "AUDIT" )) {
            setApvList();
        }
        else {
            document.getElementById("APVLIST").value = getInfo("ApprovalLine");
        }

        $("#RecDeptList").val(getInfo("FormInstanceInfo.ReceiveNames"));

        /*비사용 if (getInfo("SchemaContext.scSign.isUse") == "Y") {*/
            document.getElementById("SIGNIMAGETYPE").value = getInfo("AppInfo.usit");
        /*}*/

        initBtn();

        if ((getInfo("Request.loct") == "MONITOR") || (getInfo("Request.loct") == "PREAPPROVAL") || (getInfo("Request.loct") == "PROCESS") || (getInfo("Request.loct") == "COMPLETE") && (getInfo("Request.mode") != "REJECT")) {
            if ((getInfo("Request.loct") == "PROCESS") && (getInfo("Request.mode") == "PROCESS" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "AUDIT") && getInfo("FormInstanceInfo.InitiatorID") == getInfo("AppInfo.usid") && getInfo("Request.subkind") == "T006") {
            	m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
                var elmRoot = $(m_evalJSON).find("steps");
                var elmList = $$(elmRoot).find("division>step>ou>person").has("taskinfo[kind!='charge'])");
                var strDate;

                //처리부서로 넘어가도 취소가 가능하나 기존 제품 기준 취소 버튼이 보이지 않는 것이 맞아 해당 버튼 숨김 [21-01-18 수정] 
                $$(m_evalJSON).find("division[divisiontype='send']:has(taskinfo[status='pending'])>step>ou>person").concat().each(function (i, elm) {
                	if(i > 0){
	                    var elmTaskInfo = $$(elm).find("taskinfo");
	                    if($$(elmTaskInfo).attr("kind") == "conveyance" && strDate == null ) {

	                    } else if ($$(elmTaskInfo).attr("datecompleted") != null) {
	                        strDate = $$(elmTaskInfo).attr("datecompleted");
	                    }
                	}
                });

                //사용자 문서 조회 및 수정
                //관리자 모드가 아닐때
                if (admintype != "ADMIN") {
                    if (strDate == null) {
                        if (getInfo("Request.gloct") != "DEPART") {					//부서진행함 - 조건 없이 실행하던걸 if추가하여 안에 넣음
                        	if(getInfo("Request.gloct") == "" && getInfo("Request.loct") == "PROCESS") // 임시함에 저장 누락되는 현상 방지
                        		setInfo("Request.gloct", getInfo("Request.loct"));
                        		
                            document.getElementById("btWithdraw").style.display = ""; //회수
                        }

                        //수신처 담당자가 pending 상태일 때는 회수 안됨,수신처 수신함에 pending 일 경우 회수 안됨
                        elmList = $$(m_evalJSON).find("division").has("taskinfo[status='pending']").find("[divisiontype='receive'] > step > ou");

                        if (elmList.length > 0) {
                            document.getElementById("btWithdraw").style.display = "none"; //회수
                        }

                    } else if (strDate != null && getInfo("SchemaContext.scDraftCancel.isUse") == "Y") {
                    	// 진행 단계 관계 없이 [기안취소] 가능하도록 조건문 제거함. 
                    	if(getInfo("Request.gloct") == "" && getInfo("Request.loct") == "PROCESS") // 임시함에 저장 누락되는 현상 방지
                    		setInfo("Request.gloct", getInfo("Request.loct"));
                    	
                        document.getElementById("btAbort").style.display = "";		 //진행 중 문서도 취소가 됨
                    }
                }
                //강제합의
                var elmAssist = $(m_evalJSON).find("division:has(taskinfo[status='pending']) > step[routetype='assist'][@unittype='ou']:has(taskinfo[status='pending'])");
                if (elmAssist.length > 0 && getInfo("SchemaContext.scForcedConsent.isUse") == "Y") {
                    if (addDate("d", getInfo("SchemaContext.scForcedConsent.value"), getInfo("FormInstanceInfo.InitiatedDate"), "-") <= getInfo("AppInfo.svdt").substring(0, 10)) {
                        document.getElementById("btForcedConsent").style.display = "";
                    }
                }
                //합의부서 삭제 - 
                elmAssist = $(m_evalJSON).find("division:has(taskinfo[status='pending']) > step:has(taskinfo[status='pending'])[routetype='assist'][unittype='ou'] > ou:has(taskinfo[status='pending'])");
                if (getInfo("SchemaContext.scDCooRemove.isUse") == "Y" && elmAssist.length > 0) {
                    var bPendigOUs = false;

                    $(m_evalJSON).find("division:has(taskinfo[status='pending']) > step:has(taskinfo[status='pending'])[routetype='assist'][unittype='ou'] > ou:has(taskinfo[status='pending'])").each(function (i, elmaOU) {
                        var elmaPerson = $(elmaOU).find("person");
                        if (elmaPerson.length == 0) {
                            bPendigOUs = true;
                        }
                    });
                }
            }
        }
        if (getInfo("Request.subkind") == "MONITOR") {
            document.getElementById("btRecDept").style.display = "none"; document.getElementById("btPrint").style.display = "none"; document.getElementById("btReUse").style.display = "none"; document.getElementById("btCirculate").style.display = "none";
            switch (getInfo("Request.loct")) {
                case "PREAPPROVAL": document.getElementById("btMonitor").style.display = "none"; break;
                case "COMPLETE": document.getElementById("btMonitor").style.display = ""; break; //"미확인 닫기"
            }
        }

        //승인취소 버튼 활성화, 본인 결재 다음에 일반 결재가 있으면서 결재를 하지 않았을 경우 해당
        if (getInfo("SchemaContext.scApproveCancel.isUse") == "Y"
            && getInfo("Request.loct") == "PROCESS"
            && (getInfo("Request.userCode") == getInfo("AppInfo.usid") || getInfo("ProcessInfo.DeputyID") == getInfo("AppInfo.usid"))
            && (getInfo("Request.subkind") == "T000" || getInfo("Request.subkind") == "T004" || getInfo("Request.subkind") == "T016" || getInfo("Request.subkind") == "T017")
            && (getInfo("Request.mode") == "PROCESS" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "AUDIT")
           ) {
        	m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
            var elmRoot = $(m_evalJSON).find("steps");
            var elmList = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step>ou>person>taskinfo[kind!='charge'][kind!='bypass'][kind!='review'][kind!='skip'][kind!='reference'], >step>ou>role>taskinfo[kind!='charge'][kind!='bypass'][kind!='review'][kind!='skip'][kind!='reference']");
            var strDate;
            var bCompleted = false; //사용자 결재완료여부
            var bWICancel = false;  //승인취소 버튼 활성화 여부

            //jQuery.fn.reverse = [].reverse;
            //$(elmList.concat().json()).reverse().each(function (i, elmTaskInfo) {       //foreach거꾸로하기
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
                document.getElementById("btApproveCancel").style.display = "";
            }
        }

       /* if (getInfo("Request.reuse") != "N") setTimeout(commentOpen, 1000); 임의로 주석*/

        if (getInfo("Request.reuse") == "N") document.getElementById("btModify").style.display = "none";
        
        // 재기안회수 별도 개발 X. 부서내반송 버튼 이용
        // 수신처 담당자일 경우에만 재기안회수 버튼 활성화 , 부서합의류(Subprocess) 재기안회수 추가
        if (getInfo("ProcessInfo.SubKind") == "T006" && getInfo("Request.loct") == "PROCESS" && (getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL")) {
        	var m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
        	
        	var elmRoot = $$(m_evalJSON).find("steps");
            var elmList = $$([]);
			if(getInfo("Request.mode") == "SUBAPPROVAL"){ // 부서합의류(Subprocess)
				elmList = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step>ou").has("taskinfo[status='pending'][piid='" + getInfo("ProcessInfo.ProcessID") + "']").find(">person").has("taskinfo[kind='charge']");
			} else {
				elmList = $$(elmRoot).find("division[divisiontype='receive']").has("taskinfo[status='pending']").find(">step>ou>person").has("taskinfo[kind='charge']");
			}

            if (elmList && elmList.length > 0) {
                if ($$(elmList).attr("code") == getInfo("AppInfo.usid")) {
                	document.getElementById("btRejectedtoDept").value = Common.getDic("btn_apv_RedraftWithdraw");
                    document.getElementById("btRejectedtoDept").style.display = "";
                }
            }
        }
        
        //현결재자 변경 후 후결 셋팅
        if (getInfo("SchemaContext.scChangeReview.isUse") == "Y") // 특정 양식만
        {
            if (getInfo("Request.subkind") == "T006") //기안자
            {
                if (getInfo("Request.loct") == "PROCESS" && getInfo("Request.mode") == "PROCESS") { //진행함에서 현재결재자가 일반결재일 경우
                    var m_evalXMLChangeReview = $.parseXML(document.getElementById("APVLIST").value);
                    var elmRootChangeReview = $(m_evalXMLChangeReview).find("steps");

                    var elmApprover = $(elmRootChangeReview).find("division[divisiontype='send']:has(>taskinfo[status = 'pending' ]) > step > ou > person:has(taskinfo[kind='normal'][status='pending'])");
                    if (elmApprover.length == 1) document.getElementById("btApproverChangeReview").style.display = "";
                }

                if (getInfo("Request.loct") == "PROCESS" && getInfo("Request.mode") == "PCONSULT") { //진행함에서 현재결재자가 협조일 경우
                    var m_evalXMLChangeDeputy = $.parseXML(document.getElementById("APVLIST").value);
                    var elmRootChangeDeputy = $(m_evalXMLChangeDeputy).find("steps");

                    var elmApprover = $(elmRootChangeDeputy).find("division[divisiontype='send']:has(>taskinfo[status = 'pending' ]) > step[routetype='consult']:has(>taskinfo[status = 'pending' ]) > ou > person:has(taskinfo[kind='consult'][status='pending'])");
                }
            }
        }
    } else {
        //사용자 문서 조회 및 수정
        //관리자 모드가 아닐때
        if (admintype != "ADMIN") {
            //Legacy일경우 
            switch (getInfo("Request.loct")) {
                case "DRAFT":
                    document.getElementById("btDraft").style.display = "";	// "기안하기"
                    document.getElementById("btLine").style.display = "";	  // "결재선관리"
                    break;
                default:
                    document.getElementById("btLine").style.display = "";		// "결재선관리"
                    break;
            }
        }
    }
    
    //if(getInfo('ExtInfo.UseEditYN')=="N") initHelpPopupOnLoad();
    initHelpPopupOnLoad();

    //연속결재 특정 버튼 hide
    if (CFN_GetQueryString("bserial") == "true") {
        try {
        	$(".topWrap").find("input[name=cbBTN]").each(function () {
                var id = $(this).attr("id");
                switch (id) {
                	case "btRec":
                    case "btApproved":
                    case "btReject":
                    case "btLine":
                    //case "btDeptLine":
                    //case "btRejectedto":
                    //case "btRejectedtoDept":
                    //case "btHold": // 보류기능 지원하지 않음. todo
                    case "btSerialCancel":
                    case "btCAgree":
                    case "btCDisagree":	
                    case "btConsultReq":
                    case "btConsultReqCancel":
                        break;
                    default:
                        $(this).hide();
                        break;
                }
            });
        } catch (e) {
			coviCmn.traceLog(e);
        }
    }

    //양식팝업창 title 변경
    document.getElementsByTagName('title')[0].text = _strAppName + " - " + CFN_GetDicInfo(getInfo("FormInfo.FormName"));
}

function initHelpPopupOnLoad() {
	//도움말 팝업
    try {
        if ((getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") && getInfo("ExtInfo.UseDocHelpApproval") == "Y") {
            $("#trHelpApproval").css("display", "");
            document.getElementById("HelpApproval").innerHTML = getInfo("FormInfo.FormHelperContext");
            $('#HelpApproval').children().css('min-height','');
        }
        if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") {
            setTimeout("helpOpen('popup');", 100);
        }
    } catch (e) {
		coviCmn.traceLog(e);
    }  
}

//양식에 필요한 정보 팝업(팝업공지, 양식도움말 등을 띄운다)
function helpOpen(type) {
    var sTitle = "";
    if (type == "popup") {
        if (getInfo("ExtInfo.UseDocPopupApproval") != "Y") {
            return;
        } else {
            sTitle = Common.getDic("lbl_NoticePopup");
        }
    } else if (type == "popupbtn") {
        if (getInfo("ExtInfo.UseDocPopupBtn") != "Y") {
            return;
        } else {
            sTitle = Common.getDic("lbl_NoticePopup");
        }
    } else if (type == "help") {
        if (getInfo("ExtInfo.UseDocHelpApproval") != "Y") {
            return;
        } else {
            sTitle = Common.getDic("lbl_apv_formcreate_LCODE28");
        }
    } else {
        return;
    }
    var sUrl2 = "form/goHelpPopup.do?type=" + type;
    var iHeight = 400; var iWidth = 600;

    CFN_OpenWindow(sUrl2, "", iWidth, iHeight, "resize");
}

function commentOpen() {//미결 혹은 재기안으로 문서를 열 경우 의견이 있는 경우 의견 창 display
	if (getInfo("Request.loct") == "APPROVAL" || getInfo("Request.loct") == "REDRAFT") {
        m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
        var elmRoot = $$(m_evalJSON).find("steps");
        var elmList = $$(elmRoot).find("division > step > ou > person > taskinfo > comment,division > step > ou > role > taskinfo > comment");
        if (elmList.length > 0) {
            //의견이 있을 경우 깜빡이게 처리
            $("#btCommentView").attr("class", "opinion_view");
        }
    }
}
function setApvDirty() { m_bApvDirty = true; }

function setApvChangeMode(pMode) { m_ApvChangeMode = pMode; }	//결재선변경 모드

//setPreView 함수 분리
function setPreViewData() {
    try {
    	var formJsonObj;
		var apvLineObj;
        //if (CFN_GetQueryString("openID") == getInfo("FormInfo.FormID")) {//Layer popup 실행일 경우 queryString으로 openID를 넘김
        if (CFN_GetQueryString("editMode") == 'Y' && CFN_GetQueryString("CFN_OpenWindowName") == 'undefined') {//Layer popup 실행일 경우 완료함, 편집함에서 미리보기 할 경우 
            openID = CFN_GetQueryString("openID");
            if ($("#" + openID + "_if", parent.document).length > 0) {
                m_oInfoSrc = $("#" + openID + "_if", parent.document)[0].contentWindow;
                formJsonObj = m_oInfoSrc.getFormJSON().FormData;
				apvLineObj = m_oInfoSrc.getApvList(); //getDefaultJSON()
            }
        } else if (openMode == "L") {//Layer popup 실행일 경우 queryString으로 openID를 넘김
            var openID = getInfo("FormInfo.FormID");
            if ($("#" + openID + "_if", parent.document).length > 0) {
                m_oInfoSrc = $("#" + openID + "_if", parent.document)[0].contentWindow;
                formJsonObj = m_oInfoSrc.getFormJSON().FormData;
				apvLineObj = m_oInfoSrc.getApvList(); //getDefaultJSON()
            }
        } else {
        	if(opener != null) {
        		formJsonObj = opener.getFormJSON().FormData;
				apvLineObj = opener.getApvList(); //getDefaultJSON()
        	} else if(window.sessionStorage["formjson"] != undefined && _mobile) {
        		formJsonObj = JSON.parse(window.sessionStorage["formjson"]).FormData;
				apvLineObj = JSON.parse(window.sessionStorage["formjson"]).ApprovalLine;
        	}
        }
        if (!formJsonObj.hasOwnProperty("BodyContext") || $.isEmptyObject(formJsonObj.BodyContext)) {
        	$.extend(formJsonObj, makeNode("BodyContext", getInfo("BodyContext")));
        }
        
        $.each(formJsonObj, function(key, value) {
        	// 속도이슈 문제로 예외처리함.
        	if(key == "BodyContext" || key == "BodyData"){
        		//setInfo(key, value);
        	}else{
        		setInfo("FormInstanceInfo."+key, value);
        		if(key == "AttachFileInfo"){ // 미리보기시 수정된 첨부파일정보 표시
        			var tmpAttachStr = value;
        			try{
        				var tmpAttachObj = $.parseJSON(tmpAttachStr);
        				setInfo("FileInfos", JSON.stringify(tmpAttachObj.FileInfos));
        			}catch (e) {
        				setInfo("FileInfos","[]");
        		    }
        		}
        	}
        });

		if(typeof formJsonObj.BodyContext != "undefined") {
        	setInfo("BodyContext", formJsonObj.BodyContext);
        }
        if(typeof formJsonObj.BodyData != "undefined") {
        	setInfo("BodyData", formJsonObj.BodyData);
        }

        // 대외공문 미리보기(작성창)
        if( getInfo("SchemaContext.scDistribution.isUse")=="Y" && getInfo("ExtInfo.UseEditYN") == "Y" && formJsonObj.BodyContext   ){
			// opener에서 만든 json(apvLineObj)을 그대로 사용하면 추후 getInfo("ApprovalLine") 할 경우 [formJsonValue.constructor === {}.constructor] 조건이 맞지 않아 undefined 을 리턴하므로 다시한번 변환
			setInfo("ApprovalLine", $.parseJSON(JSON.stringify(apvLineObj)));
        	setGovViewWrite(formJson);
        }
        
        if(formJson.Request.isMobile == "Y" && formJson.BodyContext.MobileBody != undefined){
        	$("#legacyFormDiv").html(formJson.BodyContext.MobileBody);
        }
        else if(formJson.BodyContext.HTMLBody != undefined){
        	$("#legacyFormDiv").html(formJson.BodyContext.HTMLBody);
        }
        return formJsonObj;
    } catch (e) {
        coviCmn.traceLog(e);
    }

}

function setPreViewPostRendering() {
    try {
        setInfo("FormInstanceInfo.InitiatedDate", getInfo("AppInfo.svdt"));
        g_szEditable = false;
        setInfo("Request.mode", "COMPLETE");
        setInfo("Request.loct", "COMPLETE");


        if (CFN_GetQueryString("openID") == getInfo("FormInfo.FormID") || CFN_GetQueryString("editMode") == 'Y' && CFN_GetQueryString("CFN_OpenWindowName") == 'undefined') {
            document.getElementById("APVLIST").value = m_oInfoSrc.document.getElementById("APVLIST").value;

        } else {
        	if(opener != null)
        		document.getElementById("APVLIST").value = opener.document.getElementById("APVLIST").value;
        	else if(_mobile && window.sessionStorage["apvlist"] != undefined)
        		document.getElementById("APVLIST").value = window.sessionStorage["apvlist"];
        }

        initOnloadformedit();

        var aBtn = document.getElementsByName("cbBTN");
        for (var i = 0; i < aBtn.length; i++) {
            aBtn[i].style.display = "none";
        }

        //대외공문 미리보기 창,readtype = print 조건 추가
        if (getInfo("Request.readtype") != "Pubpreview" && getInfo("Request.readtype") != "Print") {
            document.getElementById("btPrint").style.display = "";
            if (getInfo("Request.readtype") != "preview" && getInfo("SchemaContext.scOPub.isUse") == "Y") { //버튼 위치 이동
                //대외공문 기안시 보여줄 버튼 추가 
                document.getElementById("btOTrans").style.display = "";
            }
        }else if (getInfo("Request.readtype") == "Pubpreview" || getInfo("Request.readtype") == "Print") {
            //대외공문미리보기 일경우 양식명, 결재선, 참고정보 display:none;
            document.getElementById("divMenu02").style.display = "none";
            document.getElementById("formlogo").style.display = "none";
            document.getElementById("AppLine").style.display = "none";
            document.getElementById("AppLineListType").style.display = "none";
            document.getElementById("AssistLine").style.display = "none";
            document.getElementById("tbLinkInfo").style.display = "none";
        }

        document.getElementById("btExitPreView").style.display = "";
        
        if(getInfo('ExtInfo.UseMultiEditYN') == "Y" && getInfo('ExtInfo.UseHWPEditYN') == "Y"){
			$('.fsbTop').hide();
     	}
    } catch (e) {
        alert(e.message);
    }
}

//미리보기 창에서 하던 함수를 수정함
function setPreView() {
    var formJsonObj = opener.getFormJSON();
    if (!formJsonObj.hasOwnProperty("BodyContext") || $.isEmptyObject(formJsonObj.BodyContext)) {
    	$.extend(formJsonObj, makeNode("BodyContext", getInfo("BodyContext")));
    }
    
    $.each(formJsonObj, function(key, value) {
    	if(key == "BodyData"){
    		setInfo(key, JSON.stringify(value));
    	}else{
    		setInfo(key, value);
    	}
    });

    setInfo("FormInstanceInfo.InitiatedDate", getInfo("AppInfo.svdt"));
    g_szEditable = false;
    setInfo("Request.mode", "COMPLETE");
    setInfo("Request.loct", "COMPLETE");
    document.getElementById("APVLIST").value = opener.document.getElementById("APVLIST").value;

    initOnloadformedit();

    var aBtn = document.getElementsByName("cbBTN");

    for (var i = 0; i < aBtn.length; i++) {
        aBtn[i].style.display = "none";
    }
    
    //대외공문 미리보기 창,readtype = print 조건 추가
    if (getInfo("Request.readtype") != "Pubpreview" && getInfo("Request.readtype") != "Print") {
        document.getElementById("btPrint").style.display = "";
        if (getInfo("Request.readtype") != "preview" && getInfo("SchemaContext.scOPub.isUse") == "Y") { //버튼 위치 이동
            //대외공문 기안시 보여줄 버튼 추가 
            document.getElementById("btOTrans").style.display = "";
        }
    } else if (getInfo("Request.readtype") == "Pubpreview" || getInfo("Request.readtype") == "Print") {
        //대외공문미리보기 일경우 양식명, 결재선, 참고정보 display:none;
        document.getElementById("divMenu02").style.display = "none";
        document.getElementById("formlogo").style.display = "none";
        document.getElementById("AppLine").style.display = "none";
        document.getElementById("AppLineListType").style.display = "none";
        document.getElementById("AssistLine").style.display = "none";
        document.getElementById("tbLinkInfo").style.display = "none";
    }

    document.getElementById("btExitPreView").style.display = "";

    clearInterval(timerID);
}

function setGovView() {
	// 발송대기메뉴 && (실패||대기) --> 수동발송 버튼 활성화
    initOnloadformmenu_notelist();
    postJobForDynamicCtrl();
    if(CFN_GetQueryString("docType")=="wait") hasGovAdmin();
}

function hasGovAdmin(){
	$.ajax({
		url: '/approval/user/getGovDocManager.do',
		type: 'POST',
		data: {'UserId': Common.getSession("UR_Code")},
		async: false,
		success: function(data){
			if(data.Cnt >0){
				$("#btGovDocsSend").show();
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax(url, response, status, error);
		},
	});
}

function setGovViewWrite(pFormJson){		
	//다른 ajax호출로 프로그레스가 사라지므로, 결재용 프로그레스 사용
	ToggleLoadingImage();
	$("#bodytable").hide();
	$.ajax({
		url: "/approval/govDocs/preview.do",
		type:"POST",
		data: {
			formJson : JSON.stringify(pFormJson)
		},		
		success:function (data) {
			$("#govFormDiv").empty().append(data.content);			
			ToggleLoadingImage();
			$("#bodytable").show();
		},
		error:function(response, status, error){ 
			ToggleLoadingImage();
			//$("#bodytable").show();
			CFN_ErrorAjax("/approval/govDocs/preview.do", response, status, error);
		}
	});
}

function setOpenWindowData() {
    try {
        //작성창 조회창 구분에 따른 값 가져오기 처리
        if (getInfo("Request.templatemode") == "Write") {
            var formJsonObj = getFormJSON();
            
            if (!formJsonObj.hasOwnProperty("BodyContext") || $.isEmptyObject(formJsonObj.BodyContext)) {
            	$.extend(formJsonObj, makeNode("BodyContext", getInfo("BodyContext")));
            }
            
            $.each(formJsonObj, function(key, value) {
            	if(key == "BodyData"){
            		setInfo(key, JSON.stringify(value));
            	}else{
            		setInfo(key, value);
            	}
            });
            
        }
    } catch (e) {
        alert(e.message);
    }
}

function setOpenWindowPostRendering() {
    try {
        document.getElementById("APVLIST").value = $("textarea[name=APVLIST]", opener.document).val();  //HIW

        initOnloadformedit();

        if (opener.openID != null && opener.openMode == "L") {
            opener.parent.Common.Close(opener.openID);
        } else {
            //작성이외의 LayerPopup에서 새창 떳을때 opener가 사라져, destination 상실 보완
            opener.openID = getInfo("FormInfo.FormID") + getInfo("ProcessInfo.ProcessID") + getInfo("FormInstanceInfo.FormInstID");
            opener.parent.Common.Close(opener.openID);
        }
    } catch (e) {
        alert(e.message);
    }
}

//분리
function setOpenWindow() {
    //작성창 조회창 구분에 따른 값 가져오기 처리
    if (getInfo("Request.templatemode") == "Write") {
    	var formJsonObj = getFormJSON();
    	

        if (!formJsonObj.hasOwnProperty("BodyContext") || $.isEmptyObject(formJsonObj.BodyContext)) {
        	$.extend(formJsonObj, makeNode("BodyContext", getInfo("BodyContext")));
        }
        
        $.each(formJsonObj, function(key, value) {
        	if(key == "BodyData"){
        		setInfo(key, JSON.stringify(value));
        	}else{
        		setInfo(key, value);
        	}
        });

        document.getElementById("APVLIST").value = $("textarea[name=APVLIST]", opener.document).val();  //HIW

        initOnloadformedit();
    }
    clearInterval(timerID1);
    if (opener.openID != null && opener.openMode == "L") {
        opener.parent.Common.Close(opener.openID);
    } else {
        //20120125 By ssuby 새창열릴때 기존 reload대신 opner인 Layer창만 닫는 처리로 변경
        opener.openID = getInfo("FormInfo.FormID") + getInfo("ProcessInfo.ProcessID") + getInfo("FormInstanceInfo.FormInstID");
        opener.parent.Common.Close(opener.openID);
    }
}
function initBtn() {
	// 다안기안 버튼 조회 처리
	initMultiEditBtn();
	
    if (getInfo("Request.readtype") == "preview" || getInfo("Request.readtype") == "govpreview" || getInfo("Request.readtype") == "govpreviewWrite") //미리보기 창인지 검증
    {
        document.getElementById("btHistory").style.display = "none";
        try { document.getElementById("btPreView").style.display = "none";  } catch (e) { coviCmn.traceLog(e); }

        return;
    }

    //readtype = print 조건 추가
    if (getInfo("Request.readtype") == "Pubpreview" || getInfo("Request.readtype") == "Print") // 대외공문 미리보기 창인지 검증
    {
        document.getElementById("btHistory").style.display = "none";
        try {
            document.getElementById("btPreView").style.display = "none";
            document.getElementById("btPM").style.display = "none";
        } catch (e) { coviCmn.traceLog(e); }

        return;
    }

    if (getInfo("ExtInfo.UseDocPopupBtn") == "Y") {
    	document.getElementById("btDocPopup").style.display = "";
    }
    
 	if (getInfo('ExtInfo.UseHWPEditYN') == "Y" && $("#writeTab li.on").length > 0) {
 		document.getElementById("btSummaryPopup").style.display = "";
 		document.getElementById("btDocLinked").style.display = "none";
 	}
 	
 	// 문서유통사용 & 웹한글기안기 사용시 문서정보 & 요약전버튼 표시 & 문서유통(수신) 문서일 경우 표시 안함
    if(getInfo("SchemaContext.scDistribution.isUse")=="Y" && getInfo("ExtInfo.UseWebHWPEditYN") == "Y" && getInfo("ExtInfo.IsGovReceiveForm") != "Y") {
		document.getElementById("btDocInfo").style.display = "";
		document.getElementById("btSummaryPopup").style.display = "";
	}
    
    /* 문서유통(수신) 문서일 경우 문서정보 숨김
    if(getInfo("ExtInfo.IsGovReceiveForm") == "Y") {
    	displayDocInfo();
    }
    */
	
	// 문서유통사용 & 웹에디터 사용시 문서정보&요약전버튼 표시
    if(getInfo("SchemaContext.scDistribution.isUse")=="Y" && getInfo("ExtInfo.UseEditYN") == "Y") {
		document.getElementById("btDocInfo").style.display = "";
	}
    
    // 기록물철 다안기안 사용 시 
    if(getInfo("ExtInfo.UseMultiEditYN")=="Y" && getInfo("ExtInfo.UseEditYN") == "Y" && getInfo("SchemaContext.scRecordDocOpen.isUse")=="Y" ){
		$("#btRecieveIn").hide(); // FormHeaderMulti(문서유통X,다안기안O) 에만 있는 버튼
		$("#ReceiveLine_Multi").hide();
    }

 	//formmenu의 EDMS버튼
 	if(Common.getBaseConfig("useEdmsConDoc") == "Y" && getInfo('ExtInfo.UseMultiEditYN') !== 'Y') {
 		if(getInfo("Request.templatemode") == "Write") {
 			$("#btEDMSDocLinked").show();
 		}
 		$("#EDMSDocLinkInfoList").show();
	}

    // 문서유통사용 = Y이면 "" or 배포사용 & 수신처개별버튼사용 = Y면 ""
    // 2022-11-22 문서유통+다안기안이면 수신처 버튼 숨김(아래에 안 마다 따로 표현)
    // var strRecDept = (getDisplayMode(getInfo("Request.mode"), 'scIPub') == "none") ? "none" : getDisplayMode(getInfo("Request.mode"), 'scDeployBtn');
    var strRecDept = (getDisplayMode(getInfo("Request.mode"), 'scDistribution') == "" && getInfo("ExtInfo.UseMultiEditYN") == "Y") ? "none" : (getDisplayMode(getInfo("Request.mode"), 'scDistribution') == "") ? "" : (getDisplayMode(getInfo("Request.mode"), 'scIPub') == "none") ? "none" : getDisplayMode(getInfo("Request.mode"), 'scDeployBtn');
    
    if(strRecDept === "") {
    	if(getInfo("SchemaContext.scNCHAis.isUse") && getInfo("SchemaContext.scNCHAis.isUse") == "Y" && (getInfo("Request.mode") != "DRAFT" && getInfo("Request.mode") != "TEMPSAVE" && getInfo("Request.mode") != "REDRAFT" && getInfo("Request.mode") != "SUBREDRAFT")) strRecDept = "none"; 
    }
    var strPrint = "none";
    var bPrintUseYN = Common.getBaseConfig("isUseSavePC");
    
    document.getElementById("chk_urgent").disabled = true; 
    document.getElementById("chk_secrecy").disabled = true;
    
    if(document.getElementById("chk_reserved_draft")){
    	document.getElementById("chk_reserved_draft").disabled = true;
    }
    if(document.getElementById("chk_reserved_dist")){
    	document.getElementById("chk_reserved_dist").disabled = true;
    }
    switch (getInfo("Request.loct")) {
        case "ADMIN":
        	// 관리자 내용변경 체크에 따른 표시
        	if(getInfo("SchemaContext.scADMCHBis.isUse") == "Y") {
        		document.getElementById("btModify").style.display = ""; //문서편집
        	}
            if (getInfo("Request.editmode") == "Y") {
                //관리자모드이고 편집모드이면 저장 버튼 보인다. 
                document.getElementById("btchangeSave").style.display = "";
                document.getElementById("btModify").style.display = "none";
            }
        	if(getInfo("SchemaContext.scADMDocPnt.isUse") == "Y") {
        		document.getElementById("btPrint").style.display = ""; 
        	}
            //기밀문서 권한 지정
            if (getInfo("ProcessInfo.ProcessDescription.IsSecureDoc") == "Y") {
                document.getElementById("chk_secrecy").checked = true;
            }
            break;
        case "PUB":
            document.getElementById("btPrint").style.display = "";
            break;
        case "PREAPPROVAL":
            // [2019-02-20 MOD] gbhwang 예고함 선결재 기능 추가 관련
            var oApvList = $.parseJSON(document.getElementById("APVLIST").value);
            var lastApproverCode = $$(oApvList).find("steps>division[divisiontype='send']>step[routetype='approve']").last().find("person").attr("code");
            
            // 최종결재자 중 허용된 사용자에 한하여 선결재 기능 사용 가능
            if(Common.getBaseConfig("PreApproverCode").indexOf(getInfo("AppInfo.usid")) > -1 && lastApproverCode == getInfo("AppInfo.usid")) {
                document.getElementById("btApprovedLast").style.display = "";
                document.getElementById("btRejectLast").style.display = "";
            }
        case "PROCESS":
        case "COMPLETE":
            if (getInfo("Request.loct") == "COMPLETE" && getInfo("Request.subkind") != "T010") { document.getElementById("btCirculate").style.display = ""; document.getElementById("btCirculate_View").style.display = ""; }
            if (getInfo("Request.loct") == "COMPLETE" && getInfo('ExtInfo.UseMultiEditYN') != "Y") {
                document.getElementById("btPcSave").style.display = (bPrintUseYN == "Y") ? "" : "none";
                if(Common.getSession('UR_AssignedBizSection').includes('Mail')){
                    document.getElementById("btMailSend").style.display = (bMailUse == "True") ? "" : "none"
                }
            };

            /*if (getInfo("Request.gloct") == "SHARER") document.getElementById("btShared").style.display = "";*/
            
            if (getInfo("SchemaContext.scOPub.isUse") == "Y" && getInfo("Request.loct") == "COMPLETE") {   //[2018-10-01 yjlee] 완료함에서만 대외공문 보여주도록 변경
                //대외공문 완료함에서 보여줄 버튼 
            	if(getInfo("SchemaContext.scDistribution.isUse")!="Y" && getInfo("ExtInfo.UseEditYN") == "Y") document.getElementById("btOTrans").style.display = "";
            }

            //(본사운영) 발주 버튼
            if ((getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_ORDER" )
            //if ((getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_ORDER" || getInfo("FormInfo.FormPrefix") == "WF_FORM_BIZMNT_BUYORDERS")
            		&& (getInfo("Request.gloct") == "BizDoc" || getInfo("Request.gloct") == "JOBFUNCTION")) {
                //발주품의 완료함에서 보여줄 버튼 
                document.getElementById("btPurchaseOrder").style.display = "";
            }

            //(본사운영) 외주 버튼
			if ((getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_OUTSOURCING" )
            //if ((getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_OUTSOURCING" || getInfo("FormInfo.FormPrefix") == "WF_FORM_BIZMNT_BUYOUTSOURCING")
            		&& (getInfo("Request.gloct") == "BizDoc" || getInfo("Request.gloct") == "JOBFUNCTION")) {
                document.getElementById("btPrintContract").style.display = "";
            }

            //(본사운영) 라이선스 버튼
            if (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_License") {
                document.getElementById("btPrintLicense").style.display = "";
            }
            
            if (getInfo("Request.mode") == "COMPLETE" && getInfo("FormInstanceInfo.InitiatorID") == getInfo("AppInfo.usid")) {
            	switch(getInfo("FormInfo.FormPrefix"))
            	{
            		case "WF_FORM_VACATION_REQUEST2": //(본사운영) 휴가취소신청서
            			document.getElementById("btVacationCancle").style.display = ""; //휴가취소신청서
            			break;
            		case "WF_FORM_WORK_SCHEDULE": //근무일정 변경 신청서
            			document.getElementById("btWorkSchChange").style.display = "";
            			break;
            		case "WF_OTHER_WORK": //기타근무 변경 신청서
            			document.getElementById("btOtherWorkChange").style.display = "";
            			break;
            		case "WF_FORM_OVERTIME_WORK": //연장근무 변경 신청서
            			document.getElementById("btOvertimeWorkChange").style.display = "";
            			break;
            		case "WF_FORM_HOLIDAY_WORK": //휴일 근무 변경 신청서
            			document.getElementById("btHolidayWorkChange").style.display = "";
            			break;
            		case "WF_FROM_BIZTRIP_REQUEST": //(본사운영) 출장복명서 작성 (btBizrip)
            			document.getElementById("btBizrip").style.display = "";
            			break;
            		case "WF_FORM_CONTRACT_DRAT": //집행계획서 작성 버튼 (본사운영 - 수주보고 양식)
            			document.getElementById("btnExecPlan").style.display = "";
            			break;
            	}
            }            
            //문서24 발신자가 개인일경우 수신처리함에서 회신
            if (getInfo("Request.gloct") == "DEPART" && (getInfo("BodyContext.sender") != undefined && getInfo("BodyContext.sender").substring(0,2) == "MA")){
            	document.getElementById("btGovDocsReply").style.display = "";
            }    
        case "CANCEL":
        case "JOBDUTY":
        case "REVIEW":
        case "REJECT":
            displayBtn("none", "none", "none", "none", "", "none", "none", "none", "none", "none", "none", "none", "none", getInfo("Request.loct") == "COMPLETE" ? "" : "none", "none", "none", "");
            strPrint = "";
            document.getElementById("btPrintView").style.display = "none";
            document.getElementById("btPrint").style.display = strPrint; //출력
            if ((getInfo("Request.gloct") == "COMPLETE" || getInfo("Request.gloct") == "REJECT") 
            && getInfo("FormInstanceInfo.InitiatorID") == getInfo("AppInfo.usid")
            && getInfo("AppInfo.hasWriteAuth") === 'true') {
            	 document.getElementById("btReUse").style.display = "";
                //수신부서 재사용 버튼
               /* if ('' !== document.getElementById("APVLIST").value) {
                	m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
                    var elmRoot = $(m_evalJSON).find("steps");
                    var elmRouCount = $(elmRoot).find("division[divisiontype='receive'][oucode='" + getInfo("AppInfo.dpid_apv") + "']:has(taskinfo[status='rejected'])").length;

                    if (elmRouCount > 0) {
                        document.getElementById("btReUse").style.display = "";
                    }

                }*/
            }
            if (getInfo("FormInfo.IsUse") == "N") { document.getElementById("btReUse").style.display = "none"; }

            document.getElementById("btCommentView").style.display = "";

            if ((getInfo("Request.loct") == "COMPLETE") && getInfo("Request.mode") == "COMPLETE") { if (getInfo("SchemaContext.scIPub.isUse") == "Y" || getInfo("SchemaContext.scOPub.isUse") == 'Y') { document.getElementById("btReceiptView").style.display = ""; } }
            
            //의견버튼 추가 : 완료된 문서, 진행중인 문서에 기안자+결재자에 한해서 의견 추가 / 참조자 의견 추가
            var subKindArr = ["T000", "T004", "T006", "T009", "T016"];
            if( ((getInfo("Request.loct") == "COMPLETE" && getInfo("Request.mode") == "COMPLETE") && (getInfo("SchemaContext.scCmtAdd.isUse") == "Y" && subKindArr.includes(getInfo("Request.subkind"))))
            	|| ((getInfo("Request.loct") == "PROCESS" && getInfo("Request.mode") == "PROCESS") && (getInfo("SchemaContext.scPrcCmtAdd.isUse") == "Y" && subKindArr.includes(getInfo("Request.subkind"))))
            	|| (getInfo("SchemaContext.scCCpersonCmtAdd.isUse") == "Y" && $$($.parseJSON(getInfo("ApprovalLine"))).find("steps>ccinfo>ou>person[code='"+Common.getSession("UR_Code")+"']").length > 0) ){
            	document.getElementById("btComment").style.display = ""; document.getElementById("btCommentView").style.display = "";
            }
            
            // 연동 양식 재사용 버튼 숨김처리
            if (getInfo("Request.isLegacy") == "Y") {
            	document.getElementById("btReUse").style.display = "none";
            }
            
            // 검토 요청
        	initConsultationBtn("CommentView");

            break;
        case "DRAFT":
        case "PREDRAFT":
        case "TEMPSAVE":
            displayBtn("", "none", getDisplayMode(getInfo("Request.mode"), 'scEdms'), "none", "", strRecDept, "none", "none", "none", "", "none", "", "", "none", "none", "", "");
            if (getInfo("ExtInfo.UseApproveSecret") == "Y") {
                document.getElementById("chk_secrecy").checked = true;
                document.getElementById("chk_secrecy").value = "1";
                document.getElementById("chk_secrecy").disabled = true;
            } else {
                document.getElementById("chk_secrecy").disabled = false;
            }
            document.getElementById("chk_urgent").disabled = false;
            /* 추가의견 */
            document.getElementById("btComment").style.display = "none"; 
            document.getElementById("btHistory").style.display = "none"; 

        	// 연동 양식 임시저장 버튼 숨김처리
            if (getInfo("Request.isLegacy") == "Y") {
            	document.getElementById("btSave").style.display = "none";
            }
            
            //즐겨찾기 여부 확인을 Ajax 처리하지 않고 서버에서 변수로 처리
            if (gFormFavoriteYN == "Y") {
                document.getElementById("favorformadd").style.display = "none";
                document.getElementById("favorformdelete").style.display = "";
            } else {
                document.getElementById("favorformadd").style.display = "";
                document.getElementById("favorformdelete").style.display = "none";
            }

            //예약발송,배포 활성화 (옵션 - 스키마) / 작성모드에서 옵션 활성.
            $("#reservedDraft,#reservedDist,#reservedDraftChk,#reservedDistChk").hide();
            if (getInfo("SchemaContext.scReserveDraft.isUse") == "Y") {
            	if (getInfo("Request.readtype") != "preview" && getInfo("Request.templatemode") != "Read") {
            		$("#divMenu02").hide();
            		$("#reservedDraft,#reservedDraftChk").show();
            		$("#chk_reserved_draft").attr("disabled", false);
            	}
            }
            if(getInfo("SchemaContext.scReserveDist.isUse") == "Y"){
            	if (getInfo("Request.readtype") != "preview" && getInfo("Request.templatemode") != "Read") {
            		$("#divMenu02").hide();
            		$("#reservedDist,#reservedDistChk").show();
            		$("#chk_reserved_dist").attr("disabled", false);
            	}
            }
            
            if(getInfo("SchemaContext.scReserveDraft.isUse") == "Y" || getInfo("SchemaContext.scReserveDist.isUse") == "Y"){
            	var hours = "", minutes = "";
            	
            	for(var i = 0; i < 24; i++) {
            		var txt = (i < 10) ? '0' + i : i + '';
            		hours += "<option value='"+txt+"'>"+ txt + "</option>"
            	}
            	
            	for(var i = 0; i < 60; i++) {
            		if(i%10 == 0){
            			var txt = (i < 10) ? '0' + i : i + '';
            			minutes += "<option value='"+txt+"'>"+ txt + "</option>"
            		}
            	}
            	
            	$('#reservedHour,#distReservedHour').html(hours);
            	$('#reservedMin,#distReservedMin').html(minutes);
            	
            	if(getInfo("Request.mode") == "TEMPSAVE") {
                	$("#reservedHour").val(getInfo("BodyContext.reservedHour"));
                	$("#reservedMin").val(getInfo("BodyContext.reservedMin"));
                	$("#distReservedHour").val(getInfo("BodyContext.distReservedHour"));
                	$("#distReservedMin").val(getInfo("BodyContext.distReservedMin"));
            	}
            }

			// 관리자페이지 임시저장문서보기 : 상단 버튼영역 비활성화
			if(getInfo("Request.mode") == "TEMPSAVE" && getInfo("Request.gloct") == "ADMTEMPSAVE"){
				$("#div_formmenu").find("input[type='button'],input[type='checkbox'],a").prop("onclick",null).off("click");
			}
			
            break;
        case "COMMENT" : //수신처의견보기
            document.getElementById("btCommentView").style.display = "";
            break;
        case "REDRAFT":
        case "SHARER":
        case "APPROVAL":
            switch (getInfo("Request.mode")) {
                case "SHARER":
                case "APPROVAL": //일반결재
                    displayBtn("none", "none", "none", "none", "", strRecDept, "", "none", "none", "none", "", "none", "none", "none", "none", "none", ""); //모든 결재자 첨부파일 추가				
                    document.getElementById("btCommentView").style.display = ""; 

                    // 스키마 체크, 배포 부서에서 편집 X
                    if (getInfo("SchemaContext.scCHBis.isUse") == "Y") {
                        if (!fn_GetReview()) { document.getElementById("btModify").style.display = ""; }
                        if (getInfo("Request.editmode") == "Y" && getInfo("SchemaContext.scCHBSaveBtn.isUse") == "Y") {
                            //편집모드이면 저장 버튼 보인다. 
                            document.getElementById("btchangeSave").style.display = "";
                            document.getElementById("btModify").style.display = "none";
                        }
                    } else {
                        document.getElementById("btModify").style.display = "none";
                    }
                    if (getInfo("SchemaContext.scTransfer.isUse") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid")) document.getElementById("btForward").style.display = ""; //전달버튼 활성화
                    
                    initConsultationBtn("APPROVAL");
                    break;
                case "AUDIT": //감사
                    document.getElementById("btCommentView").style.display = ""; 
                    displayBtn("none", "none", "none", "none", "", "none", "", "none", "none", "none", "", "none", "none", "", "", "none", "");
                    break;                	
                case "PCONSULT": //개인합의				
                    document.getElementById("btCommentView").style.display = ""; 
                    displayBtn("none", "none", "none", "none", "", "none", "", "none", "none", "none", "", "none", "none", "", "", "none", "");
                    if (getInfo("SchemaContext.scTransfer.isUse") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid")) document.getElementById("btForward").style.display = ""; //전달버튼 활성화
                    
                    initConsultationBtn("PCONSULT");
                    break;
                case "RECAPPROVAL": //수신결재				
                    document.getElementById("btCommentView").style.display = ""; 
                    if (getInfo("SchemaContext.scRCHBis.isUse") == "Y" && getInfo("SchemaContext.pdef.value").toLowerCase().indexOf("request") > -1) {
                    	document.getElementById("btModify").style.display = "";
                        if (getInfo("Request.editmode") == "Y" && getInfo("SchemaContext.scCHBSaveBtn.isUse") == "Y") {
                            //편집모드이면 저장 버튼 보인다. 
                            document.getElementById("btchangeSave").style.display = "";
                            document.getElementById("btModify").style.display = "none";
                        }
                    }
                    displayBtn("none", "none", "none", "none", "none", "none", "", "none", "", "none", "", "none", "none", "none", "none", "none", ""); //모든 결재자 첨부파일 추가					

                    if (getInfo("SchemaContext.scTransfer.isUse") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid")) document.getElementById("btForward").style.display = ""; //전달버튼 활성화

                    initConsultationBtn("RECAPPROVAL");
                    break;
                case "SUBAPPROVAL": //부서합의내결재
                    if (getInfo("SchemaContext.scTransfer.isUse") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid")) document.getElementById("btForward").style.display = ""; //전달버튼 활성화
                    displayBtn("none", "none", "none", "none", "none", "none", "", "none", "", "none", "", "none", "none", "", "", "none", ""); break;
                case "DEPART": //부서
                    break;
                case "CHARGE": //담당자				
                    document.getElementById("btCommentView").style.display = ""; 
                    displayBtn("none", "none", "none", "none", "none", "none", "", "none", "none", "none", "", "none", "none", "", "", "none", ""); break;
                case "REDRAFT": //재기안
                    var sdisplay = "";
                    var sAttDisplay = "";
                    if (getInfo("Request.subkind") == "T008") {
                        displayBtn("none", "none", "none", "none", "", "none", "", "none", "none", "none", "", (getInfo("SchemaContext.scCHBis.isUse") == "Y") ? "" : "none", "none", "none", "none", "", "");
                    } else {
                        sAttDisplay = "";
                        //문서관리자 권한 설정
                        if (getInfo("SchemaContext.scRec.isUse") == "Y") {
                            sdisplay = "none";
                            sAttDisplay = "none";
                            if (getInfo("AppInfo.usismanager") == "true" || getInfo("Request.usisdocmanager") == "true"
                            	|| (Common.getBaseConfig("IsUseDeptReceiptManager") == "Y" && (Common.getBaseConfig("WorkReportTMJobTitle").indexOf(Common.getSession("UR_JobTitleCode")) != -1 || chkDocManager()))) { // || getInfo("dpisdocmanager") == "false") { - dpisdocmanager 비사용
                                if (getInfo("Request.userCode") == getInfo("ProcessInfo.UserCode")) {
                                    document.getElementById("btRec").style.display = "";
                                    document.getElementById("btReject").style.display = "";
                                } else {
                                    document.getElementById("btRec").style.display = "none";
                                }
                            }
                        }
                        if (getInfo("SchemaContext.scRecBtn.isUse") == "Y") { sdisplay = ""; sAttDisplay = ""; document.getElementById("btCharge").style.display = ""; }
                        if (getInfo("Request.loct") == "REDRAFT" && getInfo("Request.mode") == "REDRAFT") {//신청서 수신함 조회 시
                            displayBtn("none", "none", "none", "none", "none", "none", "", "none", "", "none", "", "none", "none", "none", "none", "", ""); //모든 결재자 첨부파일 추가					

                            //문서관리자 권한 설정
                            if (getInfo("AppInfo.usismanager") == "true" || getInfo("Request.usisdocmanager") == "true"
                            	|| (Common.getBaseConfig("IsUseDeptReceiptManager") == "Y" && (Common.getBaseConfig("WorkReportTMJobTitle").indexOf(Common.getSession("UR_JobTitleCode")) != -1 || chkDocManager()))){ // || getInfo("dpisdocmanager") == "false") { - dpisdocmanager 비사용
                                if (getInfo("SchemaContext.scRecBtn.isUse") == "Y") document.getElementById("btCharge").style.display = "";
                                document.getElementById("btLine").style.display = "none";
                                document.getElementById("btDeptLine").style.display = "";
                                if (getInfo("SchemaContext.scRCHBis.isUse") == "Y" && getInfo("SchemaContext.pdef.value").toLowerCase().indexOf("request") > -1) {
                                	document.getElementById("btModify").style.display = "";
                                    if (getInfo("Request.editmode") == "Y" && getInfo("SchemaContext.scCHBSaveBtn.isUse") == "Y") {
                                        //편집모드이면 저장 버튼 보인다. 
                                        document.getElementById("btchangeSave").style.display = "";
                                        document.getElementById("btModify").style.display = "none";
                                    }
                                } 
                            } else {
                                document.getElementById("btCharge").style.display = "none";
                                document.getElementById("btLine").style.display = "none";
                                document.getElementById("btDeptLine").style.display = "none";
                            }
                            
                            if(getInfo("SchemaContext.scRecordDocOpen.isUse") =="Y" && document.getElementById("btRecordDoc")){
                            	document.getElementById("btRecordDoc").style.display = "";
                        	}
                            
                        } else {
                            displayBtn("none", "none", "none", "none", "none", "none", "none", "none", sdisplay, "none", "none", sAttDisplay, "none", "", "", "", "");
                        }
                    }
                    document.getElementById("btCommentView").style.display = "";
                    if (getInfo("SchemaContext.scRCHBis.isUse") == "Y" && getInfo("SchemaContext.pdef.value").toLowerCase().indexOf("request") > -1) {
                    	document.getElementById("btModify").style.display = "";
                        if (getInfo("Request.editmode") == "Y" && getInfo("SchemaContext.scCHBSaveBtn.isUse") == "Y") {
                            //편집모드이면 저장 버튼 보인다. 
                            document.getElementById("btchangeSave").style.display = "";
                            document.getElementById("btModify").style.display = "none";
                        }
                    }
                    if (getInfo("SchemaContext.scTransfer.isUse") == "Y" && getInfo("SchemaContext.pdefname.value").indexOf('Draft') == -1 && getInfo("Request.userCode") == getInfo("AppInfo.dpid")) document.getElementById("btForward").style.display = ""; //전달버튼 활성화

                    break;
                case "SUBREDRAFT": //합의재기안
                    document.getElementById("btCharge").style.display = ""; 
                    if (getInfo("SchemaContext.scTransfer.isUse") == "Y") document.getElementById("btForward").style.display = "";
                    displayBtn("none", "none", "none", "none", "none", "none", "none", "none", "", "none", "none", "none", "none", "none", "", "", "");
                    if (getInfo("AppInfo.usismanager") == "true" || getInfo("Request.usisdocmanager") == "true"
                    	|| (Common.getBaseConfig("IsUseDeptReceiptManager") == "Y" && (Common.getBaseConfig("WorkReportTMJobTitle").indexOf(Common.getSession("UR_JobTitleCode")) != -1 || chkDocManager()))){ // || getInfo("dpisdocmanager") == "false") {  - dpisdocmanager 비사용
                        if (getInfo("SchemaContext.scTransfer.isUse") == "Y") document.getElementById("btForward").style.display = "";
                        if (getInfo("SchemaContext.scRecBtn.isUse") == "Y") document.getElementById("btCharge").style.display = "";
                        else document.getElementById("btCharge").style.display = "none";
                        document.getElementById("btLine").style.display = "none"; //"결재선관리"
                        if (getInfo("SchemaContext.scRecAssist.isUse") == "Y") {
                            sdisplay = "none";
                            sAttDisplay = "none";
                            if (getInfo("Request.userCode") == getInfo("ProcessInfo.UserCode")) {
                                document.getElementById("btRec").style.display = "";
                                document.getElementById("btReject").style.display = "";
                                
                                if (getInfo("ProcessInfo.SubKind") == "C") {
                                	document.getElementById("btReject").value = Common.getDic("lbl_apv_disagree");
                                }
                            } else {
                                document.getElementById("btRec").style.display = "none";
                            }
                        }
                        displayBtn("none", "none", "none", "none", "none", "none", "none", "none", "", "none", "none", "none", "none", "none", "", "", "");
                    } else if (getInfo("Request.subkind") == "T008") {
                        document.getElementById("btCharge").style.display = "";
                        document.getElementById("btLine").style.display = "none"; //"결재선관리"
                        displayBtn("none", "none", "none", "none", "none", "none", "none", "none", "", "none", "none", "none", "none", "none", "", "", "");
                    } else {
                        document.getElementById("btCharge").style.display = "none";
                        document.getElementById("btLine").style.display = "none";
                        document.getElementById("btDeptLine").style.display = "none";
                    }
                    break;
                case "CONSULT":
                case "CONSULTATION":
                	document.getElementById("btCAgree").style.display = ""; 
                	document.getElementById("btCDisagree").style.display = "";
            		//검토의견조회
            		document.getElementById("btConsultationCommentView").style.display = "";
                	break;
                /*
				 * 시행문변환 관련 비사용 case "TRANS": //변환 displayBtnTrans(); break;
				 */
            }

            if (getInfo("Request.templatemode") == "Write") {
                document.getElementById("btModify").style.display = "none";
            } else {
            	document.getElementById("btPrint").style.display = ""; //출력
            }

            //확인결재추가
            if (getInfo("Request.subkind") == "T019") document.getElementById("btModify").style.display = "none";
            //후결추가
            if (getInfo("Request.subkind") == "T005" || getInfo("Request.subkind") == "T018") {
                document.getElementById("btHold").style.display = "none"; document.getElementById("btRejectedto").style.display = "none"; document.getElementById("btForward").style.display = "none";
                document.getElementById("btModify").style.display = "none";
                document.getElementById("btLine").style.display = "";//"결재선관리"
                document.getElementById("btDeptLine").style.display = "none";//"결재선지정"
                document.getElementById("btRejectedtoDept").style.display = "none";
            }
            break;

    }
    if (getInfo("Request.loct") == "CCINFO" && getInfo('ExtInfo.UseMultiEditYN') != "Y") {
        document.getElementById("btPcSave").style.display = (bPrintUseYN == "Y") ? "" : "none";
    }
    if (getInfo('ExtInfo.UseMultiEditYN') == "Y") {
    	document.getElementById("btHistory").style.display = "none";
    }
    if (getInfo("SchemaContext.scSecrecy.isUse") == "Y") { document.getElementById("secrecy").style.display = ""; }
    
    //수신 시에 담당자지정 버튼은 스키마에 담당자 또는 담당부서가 지정되어 있는 경우에 한함.
    //다중 수신 시에 타부서 담당자로 담당자를 지정하는 경우에는 지정된 담당자가 자신이 처리해야할
    //수신부서 정보를 찾아오지 못하기 때문(자신이 처리해야 할 수신부서 정보는 자신이 속한 결재조직의
    //코드로 찾아옴). 
    if (getInfo("Request.mode") == "REDRAFT" && (getInfo("SchemaContext.scChgr.isUse") == "Y" || getInfo("SchemaContext.scChgrOU.isUse") == "Y")) {
        //btCharge.style.display = "";
    }

    //관리자
    if (admintype == "ADMIN") {
        switch (getInfo("Request.loct")) {
            case "PREAPPROVAL":
            case "APPROVAL":
            case "PROCESS":
                if (getInfo("Request.mode") == "PROCESS") {
                	m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
                    var elmRoot = $(m_evalJSON).find("steps");
                    var strDate;
                    //합의부서 삭제 - 
                    var elmAssist = $(elmRoot).find("division:has(taskinfo[status='pending']) > step:has(taskinfo[status='pending'])[routetype='assist'][unittype='ou'] > ou:has(taskinfo[status='pending'])");
                    if (getInfo("SchemaContext.scDCooRemove.isUse") == "Y" && elmAssist.length > 0) {
                        var bPendigOUs = false;
                        $(elmAssist).each(function (ia, elmaOU) {
                            var elmaPerson = $(elmaOU).find("person");
                            if (elmaPerson.length == 0) {
                                bPendigOUs = true; return false;
                            }
                        });
                    }
                } else {
					// 결재선변경
                    if (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL") {
                        //if(getInfo("Request.userCode")==getInfo("ProcessInfo.UserCode")) btForward.style.display = "";
                    }
                }
                /*기안취소(관리자)버튼 비사용 document.getElementById("btAdminAbort").style.display = ""; *///관리자 강제 취소 - 진행 중 문서도 취소가 됨
                break;

        }
        document.getElementById("btModify").style.display = "";//문서편집
        /*문서삭제 버튼 비사용 document.getElementById("btDeleteDoc").style.display = "";*///문서삭제
        if ((getInfo("Request.loct") == "COMPLETE" && getInfo("Request.mode") == "COMPLETE") || (getInfo("Request.loct") == "REDRAFT")) { if (getInfo("SchemaContext.scIPub.isUse") == "Y" || getInfo("SchemaContext.scOPub.isUse") == 'Y') { document.getElementById("btReceiptView").style.display = ""; } }

        //hjw modi 관리자>사용자문서보기에서 버튼 숨기기
        document.getElementById("btPreList").style.display = "none";        //이전
        document.getElementById("btNextList").style.display = "none";       //다음
        document.getElementById("btModify").style.display = "none";         //편집
        document.getElementById("btMailSend").style.display = "none";  //메일보내기
        /* 추가의견 */
        document.getElementById("btComment").style.display = "none";  //의견
        document.getElementById("btMailSend").style.display = "none";  //메일보내기
        document.getElementById("btReUse").style.display = "none";  //재사용
    }

    if ((admintype == "ADMIN") && (getInfo("Request.loct") == "APPROVAL" || getInfo("Request.loct") == "REDRAFT") && (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "SUBREDRAFT" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "RECAPPROVAL")) {
        document.getElementById("btForward").style.display = "";
    }

    // 읽기/쓰기모드 버튼제어
    if(getInfo("Request.templatemode") == "Read"){
    }else{
    	$("#btHold,#btForward,#btPrint").hide();
    }
    
    if (openMode == "L" || openMode == "P" || CFN_GetQueryString("listpreview") == "Y") document.getElementById("btNewFormWindow").style.display = "";
    if (getInfo("Request.readtype") == "openwindow") //새창보기
    {
        return;
    }
    
    // e-Accounting 증빙 미리보기(모아보기) 버튼 display
    if(getInfo("FormInfo.FormPrefix").indexOf("WF_FORM_EACCOUNT_LEGACY") > -1) {
    	document.getElementById("btEvidPreview").style.display = "";
    	document.getElementById("btPrintEvid").style.display = "";
    	document.getElementById("btDownloadEvidFile").style.display = "";
    }
    
	// 공문 미리보기 시점에 상관없이 가능하도록
	if(getInfo("SchemaContext.scDistribution.isUse")=="Y" && getInfo("ExtInfo.UseEditYN") == "Y") document.getElementById("btOTransView").style.display = "";
	
    // 문서유통 + 다안기안 처리
    if (isGovMulti() || isUseHWPEditor()) {
		// 미리보기 숨김처리
		document.getElementById("btPreView").style.display = "none";
		// 대외공문 숨김처리
		document.getElementById("btOTrans").style.display = "none";
		// 다안기안 작성창에서는 공문 미리보기 숨기기
		if (getInfo("Request.templatemode") == "Write") document.getElementById("btOTransView").style.display = "none";
	}
    
    // 문서내 결재선 수신처 버튼 숨김처리
    if (getInfo('SchemaContext.scFormAddInApvLine.isUse') == 'Y' && getInfo('Request.templatemode') == 'Write') {
    	document.getElementById("btRecDept").style.display = "none";
    }

    try {
        if (openMode == "L") {
            if (openID != "") {//Layer popup 실행
                var openID = CFN_GetQueryString("openID");
                if ($("#" + openID + "_if", parent.document).length > 0) {
                    m_oInfoSrc = $("#" + openID + "_if", parent.document)[0].contentWindow;
                } else { //바닥 popup
                    m_oInfoSrc = parent;
                }
            } else {
                m_oInfoSrc = top.opener;
            }

            if (m_oInfoSrc.location.href.toUpperCase().indexOf("/APPROVAL_APPROVALLIST.DO") > -1
            	|| m_oInfoSrc.location.href.toUpperCase().indexOf("/APPROVAL_DEPTDRAFTCOMPLETELIST.DO") > -1) {
                if (m_oInfoSrc.strPiid_List != "") {
                    document.getElementById("btPreList").style.display = "";
                    document.getElementById("btNextList").style.display = "";
                }
            }

        }
        else if (opener != null && admintype != "ADMIN") {   //hjw modi 관리자>사용자문서보기에서 버튼 숨기기
            if (opener.location.href.toUpperCase().indexOf("/APPROVAL_APPROVALLIST.DO") > -1
            	|| opener.location.href.toUpperCase().indexOf("/APPROVAL_DEPTDRAFTCOMPLETELIST.DO") > -1) {
                if (opener.strPiid_List != "") {
                    document.getElementById("btPreList").style.display = "";
                    document.getElementById("btNextList").style.display = "";
                }
            }
        }
        
        
        if(getInfo("Request.mode") =="GOVACCEPT"){//문서유통 접수대기
        	if(getInfo("ExtInfo.UseWebHWPEditYN")=="Y"){
        		document.getElementById("btPrintView").style.display = "none"; 
        	}
        }
        
    } catch (e) { coviCmn.traceLog(e); }
}

//검토기능 버튼 처리
function initConsultationBtn(getMode) {
	// 검토 요청
    var oCurr = $$($.parseJSON(getInfo("ApprovalLine"))).find("step > ou").concat().find("[wiid='" +getInfo("Request.workitemID")+ "']").find("person").concat().find("[code='"+getInfo("Request.userCode")+"']");
    if(getMode == "PCONSULT"){
    	oCurr = $$($.parseJSON(getInfo("ApprovalLine"))).find("step > ou").concat().find("[wiid='" +getInfo("Request.workitemID")+ "']").find("person[code='"+getInfo("Request.userCode")+"']");
    }
    
    if(getMode == "CommentView" && (oCurr.find(">consultation[status!='canceled']").length > 0 || getInfo("Request.subkind") === "T023")){
		//검토의견조회
		document.getElementById("btConsultationCommentView").style.display = "";
	} else if(oCurr.find(">consultation[status!='canceled']").length > 0){
		var oConsultUserInfo = $$(oCurr.find(">consultation[status!='canceled']").concat().find(">consultusers > taskinfo")).json();
		if(!$.isArray(oConsultUserInfo)){ oConsultUserInfo = [].concat(oConsultUserInfo); }
		oConsultUserInfo = oConsultUserInfo.every(function(item){ return item.status === "completed"; });
		var oCurrStatus = oCurr.find(">taskinfo").attr("status");
		
		document.getElementById("btConsultReq").style.display = "none";
		//검토의견조회
		document.getElementById("btConsultationCommentView").style.display = "";
		if(oCurrStatus !== "pending" && !oConsultUserInfo){
    		// 편집,  승인, 반려, 보류, 결재선 버튼 숨김.
			document.getElementById("btModify").style.display = "none";
			document.getElementById("btApproved").style.display = "none";
			document.getElementById("btReject").style.display = "none";
			document.getElementById("btRejectedto").style.display = "none";
			document.getElementById("btHold").style.display = "none";
			document.getElementById("btRejectedtoDept").style.display = "none";
			//document.getElementById("btShared").style.display = "none";
			document.getElementById("btLine").style.display = "none";
			document.getElementById("btDeptLine").style.display = "none";
			document.getElementById("btRecDept").style.display = "none";
			document.getElementById("btForward").style.display = "none";
    		// 검토요청취소 버튼 보이기
    		document.getElementById("btConsultReqCancel").style.display = "";
    		document.getElementById("btConsultReqModify").style.display = "";
    	} else {
    		strApvLineYN = "Y";
    		//재검토요청 보이기
    		var oConsultationInfo = $$(oCurr.find(">consultation[status!='canceled']").concat()).json();
    		if(!$.isArray(oConsultationInfo)){ oConsultationInfo = [].concat(oConsultationInfo); }
    		if( oConsultationInfo.every(function(item){ return item.status === "completed"; }) ){
    			document.getElementById("btReConsultReq").style.display = "";
    		}
    	}
	} else {
        if(getInfo("SchemaContext.scConsultation.isUse") === "Y" && getInfo("Request.loct") == "APPROVAL"){
        	document.getElementById("btConsultReq").style.display = "";
        }
	}
}

//다안기안 버튼 조회 처리
function initMultiEditBtn() {
	// 다안기안 사용 시
	if (getInfo('ExtInfo.UseMultiEditYN') == "Y") {
		var m_oApvList = $.parseJSON(document.getElementById("APVLIST").value);
		
    	if($$(m_oApvList).find("steps>division[processID=" + getInfo("ProcessInfo.ProcessID") + "]").attr("divisiontype") == "receive") {
        	if(formJson.Request.mode == "REDRAFT") {
        		_func("#buttonDist").show();
        	}
        	
        	_func(".tabLine").hide();
        	_func("#tblFormSubjectMulti").addClass("mt10");
        } else {
        	// 수신처 관련 옵션 미사용 시 버튼 숨김 처리
    		if(!(getInfo("SchemaContext.scIPub.isUse") == "Y" || getInfo("SchemaContext.scOPub.isUse") == "Y" || getInfo("SchemaContext.scBatchPub.isUse") == "Y")) {
    			_func("div[id='buttonIn']").find("input[id^='btReceive']").hide();
    		}
        }
		
		// HWP 에디터 사용 시 전용 버튼 사용
		if(isUseHWPEditor()) {
			_func("#divHWPSender").show();
			_func("#btSummaryPopup").show();
			_func("#btInputHWPContent").show();
		}
		
		if(getInfo("ExtInfo.UseEditYN") == "Y"){
			_func("#divSender").show();
		}
		
		_func("#btDocLinked").hide();
	}
}

function displayBtn(sDraft, schangeSave, sDoc, sPost, sLine, sRecDept, sAction, sDeptDraft, sDeptLine, sSave, sMail, sAttach, sPreview, sCommand, sRec, sTempMemo, sInfo) {
    document.getElementById("btDraft").style.display = sDraft;//"기안하기"
    document.getElementById("btLine").style.display = sLine;//"결재선관리"
    document.getElementById("btRecDept").style.display = sRecDept;//"수신처지정"
    document.getElementById("btDeptDraft").style.display = sDeptDraft; //"재기안"
    document.getElementById("btDeptLine").style.display = sDeptLine; //"내부결재선관리"
    if (getInfo("Request.isTempSaveBtn") != "N") {
        document.getElementById("btSave").style.display = sSave; //"임시저장"
    } else {
        document.getElementById("btSave").style.display = "none"; //"임시저장"
    }

    document.getElementById("btPreView").style.display = sPreview;//"미리보기"

    if (g_szEditable) document.getElementById("btPreView").style.display = "";

    // 기밀문서 사용여부 지정
    if (getInfo("ProcessInfo.ProcessDescription.IsSecureDoc") == "Y" || (getInfo("Request.mode") == "TEMPSAVE" && $("#TempUseScrecy").val() === "true")) {
    	$("#chk_secrecy").prop("checked", true);
    }

    // 긴급결재 사용여부 지정
    document.getElementById("urgent").style.display = "";
    
    if (getInfo("ProcessInfo.ProcessDescription.Priority") == "5" || (getInfo("Request.mode") == "TEMPSAVE" && $("#TempUseUrgent").val() === "true")) {
    	$("#chk_urgent").prop("checked", true);
    }

    // 예약기안, 예약배포 사용여부 지정
    if (getInfo("Request.mode") == "TEMPSAVE") {
    	$("#chk_reserved_draft").prop("checked", ($("#TempUseReserveDraft").val() === "true"));
    	$("#chk_reserved_dist").prop("checked", ($("#TempUseReserveDist").val() === "true"));
    	
    	if ($("#chk_reserved_draft").is(":checked") || $("#chk_reserved_dist").is(":checked")) {
    		chk_reserved_onclick();
    	}
    }
    // 게시등록
    if (getInfo("Request.mode") == "COMPLETE" && Common.getBaseConfig("useApprovalBtnTransfer") == 'Y') {
		document.getElementById("btApprovalTransfer").style.display = "";
	}
    //업무등록
	if(getInfo("Request.mode") == "COMPLETE" && Common.getBaseConfig("isUseCollabApproval") == "Y") {
		document.getElementById("btApprovalTransferCollab").style.display = "";
	}
    if (sAction == "") {
        var bReviewr = fn_GetReview();
        if (getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT") {
    		if(getInfo("SchemaContext.scRec.isUse") == "Y"){ // 접수/반려버튼 활성화
                document.getElementById("btRec").style.display = "";
                if (!bReviewr) document.getElementById("btReject").style.display = "";
    		} else if(getInfo("SchemaContext.scChrRedraft.isUse") == "Y"){ // 수신부서 1인결재 승인/반려 버튼 활성화
                document.getElementById("btApproved").style.display = "";
                if (!bReviewr) document.getElementById("btReject").style.display = "";
    		}

    		{   //수신함 편집 버튼 클릭시 재기안 버튼 처리
            	var m_evalJSON_receive = $.parseJSON(document.getElementById("APVLIST").value);
                var elmRoot_receive = $$(m_evalJSON_receive).find("steps");
                var elmRouCount_receive = $$(elmRoot_receive).find("division[divisiontype='receive'][oucode='" + getInfo("AppInfo.dpid_apv") + "']>ou>person>taskinfo[kind != 'charge']").length;
                if (elmRouCount_receive > 0) {
                    document.getElementById("btDeptDraft").style.display = "";
                    document.getElementById("btRec").style.display = "none";
                    document.getElementById("btApproved").style.display = "none";
                }
            }
        }  else {
            //확인결재추가
            if (getInfo("Request.subkind") == "T019" || getInfo("Request.subkind") == "T005" || getInfo("Request.subkind") == "T020" || getInfo("Request.subkind") == "T018") {//확인결재
            	document.getElementById("btApproved").value = Common.getDic("lbl_apv_Confirm");
                document.getElementById("btApproved").style.display = "";
            } else if (getInfo("Request.mode") == "RECAPPROVAL") {
	        	// [20-01-16] kimhs, 나의 결재현황에서 수신받은 문서에 대해 무조건 [승인]/[반려]가 표시되는 오류 수정
	        	// [20-02-11] 대결자 비교 조건 추가
	        	if(getInfo("ProcessInfo.ProcessDescription.ApproverCode") == getInfo("AppInfo.usid")
	        			|| getInfo("ProcessInfo.DeputyID") == getInfo("AppInfo.usid")) {
	    			document.getElementById("btApproved").style.display = "";
	                if (!fn_GetReview()) document.getElementById("btReject").style.display = "";
	    		}
            } else {
                document.getElementById("btApproved").style.display = "";
                if (!fn_GetReview()) document.getElementById("btReject").style.display = "";
            }
        }
        switch (getInfo("Request.mode")) {
            case "AUDIT":
                if (Common.getBaseConfig("useHold") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid")) { document.getElementById("btHold").style.display = ""; }
                if (getInfo("SchemaContext.scRJTO.isUse") == "Y" && fn_checkrejectedtoA()) { document.getElementById("btRejectedto").style.display = ""; }
                break;
            case "PCONSULT":
                if (getInfo("Request.subkind") == "T009") {
                	document.getElementById("btApproved").value = Common.getDic("lbl_apv_agree");
                    document.getElementById("btReject").value = Common.getDic("lbl_apv_disagree");
                    //합의자 결재시 : 동의, 거부, 보류 옵션 처리
                    var getApvAgrOpt = Common.getBaseConfig("ApvAgreementOpt");
                    if (getApvAgrOpt.length > 0){
                    	var arrApvOpt = getApvAgrOpt.split(";");
                    	document.getElementById("btApproved").style.display = arrApvOpt[0] == "N" ? "" : "none";
                    	document.getElementById("btReject").style.display = arrApvOpt[1] == "N" ? "" : "none";
                    	document.getElementById("btHold").style.display = arrApvOpt[2] == "N" ? "" : "none";
                    }
                }
                if (getInfo("SchemaContext.scRJTO.isUse") == "Y" && fn_checkrejectedtoA()) { document.getElementById("btRejectedto").style.display = ""; }
                if (Common.getBaseConfig("useHold") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid") && getInfo("Request.subkind") != "T019") { document.getElementById("btHold").style.display = ""; }
                break;
            case "SUBAPPROVAL": //합의부서내 결재
                if (getInfo("SchemaContext.scRJTO.isUse") == "Y" && fn_checkrejectedtoA()) { document.getElementById("btRejectedto").style.display = ""; }

                if (Common.getBaseConfig("useHold") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid") && getInfo("Request.subkind") != "T019") { document.getElementById("btHold").style.display = ""; }
                if (getInfo("SchemaContext.scRJTODept.isUse") == "Y") { if (!bReviewr) document.getElementById("btRejectedtoDept").style.display = ""; } //2013.12.18 부서내반송 버튼 display
                
                var m_oApvList = $.parseJSON(document.getElementById("APVLIST").value);
                if ($$(m_oApvList).find("division:has(taskinfo[status='pending'])").find("step").has("taskinfo[status='pending']").attr("routetype") == "consult") {
                	document.getElementById("btApproved").value = Common.getDic("lbl_apv_agree");
                    document.getElementById("btReject").value = Common.getDic("lbl_apv_disagree");
                }
                
                break;
            case "RECAPPROVAL": //수신부서내 결재
                if (getInfo("SchemaContext.scRJTO.isUse") == "Y" && fn_checkrejectedtoA()) { if (!bReviewr) document.getElementById("btRejectedto").style.display = ""; }
                if (getInfo("SchemaContext.scRJTODept.isUse") == "Y") { if (!bReviewr) document.getElementById("btRejectedtoDept").style.display = ""; }

                if (Common.getBaseConfig("useHold") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid") && getInfo("Request.subkind") != "T019") { if (!bReviewr) document.getElementById("btHold").style.display = ""; }
                break;
            case "APPROVAL":
                if (getInfo("SchemaContext.scRJTO.isUse") == "Y" && fn_checkrejectedtoA()) { if (!bReviewr) document.getElementById("btRejectedto").style.display = ""; }

                if (Common.getBaseConfig("useHold") == "Y" && getInfo("Request.userCode") == getInfo("AppInfo.usid") && getInfo("Request.subkind") != "T019") { if (!bReviewr) document.getElementById("btHold").style.display = ""; }
                break;
            case "CHARGE":
                break;
            case "REDRAFT":
                if (Common.getBaseConfig("useHold") == "Y" && getInfo("Request.subkind") == "T008" && getInfo("Request.loct") == "APPROVAL" && getInfo("Request.gloct") == "JOBFUNCTION") { document.getElementById("btHold").style.display = ""; }
                break;
        }
    }
    //사용자 문서 조회 및 수정
    if (admintype == "ADMIN") {
        if (getInfo("Request.loct") == "PREAPPROVAL" || getInfo("Request.loct") == "APPROVAL" || getInfo("Request.loct") == "PROCESS" || getInfo("Request.loct") == "COMPLETE" || getInfo("Request.loct") == "REJECT") {
            document.getElementById("btModify").style.display = "";	//편집버튼 활성화

            switch (getInfo("Request.mode")) {
                case "PREAPPROVAL": //예고함
                    break;
                case "PROCESS":			//진행함
                    if (getInfo("Request.gloct") != "DEPART") {		//부서진행함 - 조건 없이 실행하던걸 if추가하여 안에 넣음
                        btWithdraw.style.display = "none";
                    }
                    break;
                case "COMPLETE":		//완료함				    
                    break;
                case "REJECT":			//부결함
                    break;
            }
        }
    }
}

function getDisplayMode(sReadMode, sSchemaOption) {//스키마 옵션에 따른 버튼 활성화	
	if (getInfo("SchemaContext."+sSchemaOption+".isUse") == "Y") { return ""; } else { return "none"; }
}
function disableBtns(bDisable) {
	document.querySelectorAll(".topWrap > input[type='button']").forEach(function(item, idx) { item.disabled = bDisable; });
}

//양식별 유효성 체크 전 공통 로직 처리
function checkFormComm() {
	// 다안기안 여부 체크
	if(getInfo('ExtInfo.UseMultiEditYN') == "Y") {
    	setMultiDraftDocSubject();
    	
		if(isUseHWPEditor()) {
			return checkForm_HWPMulti() && checkForm((m_sReqMode == "TEMPSAVE" ? true : false)); //"경유부서 없이 진행하시겠습니까?"
		} else {
        	return checkForm_Multi() && checkForm((m_sReqMode == "TEMPSAVE" ? true : false)); //"경유부서 없이 진행하시겠습니까?"
		}
	} else {
    	return checkForm((m_sReqMode == "TEMPSAVE" ? true : false)); //"경유부서 없이 진행하시겠습니까?"
	}
}

//1인결재 및 담당자 추가 관련 수정
function evaluateForm() {
    var truthBeTold = false;
    var ck = 0;
    
    switch (getInfo("FormInfo.FormPrefix")) {
        case "DRAFT":
        case "OUTERPUBLISH":
            if ((getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "DRAFT") && document.getElementById("Subject").value == "") {
                Common.Warning(gMessage28); return false; //"제목을 입력하세요."
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
                    
                // 개인협조 및 부서협조 체크 마지막 결재선 체크
                var oLastAppSteps = $$(elmRoot).find("division>step").concat().has("[routetype=assist']").last();
                if( oLastAppSteps.length >0 && parseInt(oLastAppSteps.index()) == $$(elmRoot).find("division>step").concat().length - 1 && getInfo("SchemaContext.scLastAssistDraft.isUse") != "Y" ){
                	Common.Warning(Common.getDic("msg_apv_setFormRuleErrorMsg")); //합의(순차,병렬)과 협조(순차,병렬)은 마지막에 올 수 없습니다.<br>결재자를 추가적으로 지정해주세요.
                	return false;
                }
                
                // 개인합의 합의자수 및 마지막 결재선 체크
                if ((getInfo("SchemaContext.scPCoo.isUse") == "Y" || getInfo("SchemaContext.scPCooPL.isUse") == "Y") && (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT")) {
                	if (!chkConsultAppLine($$(elmRoot))) return false;
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
                if (getInfo("SchemaContext.scDAgr.isUse") == "Y" && (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT")) {
                    var $$_elmConsult = $$(elmRoot).find("division>step[routetype='consult'][unittype='ou']");
                    if (!$$_elmConsult.exist()) {
                        if (getInfo("SchemaContext.scPAgr.isUse") == "Y") {
                            if (!chkConsultAppLine($$(elmRoot))) return false;
                        }
                    }
                }

                if (elmList.length == 0 && admintype != "ADMIN") {  
                    //임시저장시 1인결재일 가능 
                    if (getInfo("SchemaContext.scChrDraft.isUse") == "Y" && (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE")) {
                        if (!confirm(Common.getDic("msg_apv_198"))) return false;
                    } else if (getInfo("SchemaContext.scChrRedraft.isUse") == "Y" && getInfo("Request.mode") == "REDRAFT") {
                        if (!confirm(Common.getDic("msg_apv_198"))) return false;
                    } else {
                        Common.Warning(Common.getDic("msg_apv_029")); //"결재선이 지정되지 않았습니다."
                        return false;
                    }
                }
                	
                var ck = 0;
                if((getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_OUTSOURCING" || getInfo("FormInfo.FormPrefix") == "WF_FORM_BIZMNT_BUYOUTSOURCING")
                		&& getInfo("Request.mode") == "DRAFT" ){
               	 
                    $("input[name^='unitPrice']").each(function (){
                    	
	                   	 if($(this).hasClass("pattern-active") && (this.value =="" || this.value == null )){
	                   		 ck = 1;
	                   	 }
                    });
                 }
               
                 if(ck == "1"){
              	 	Common.Warning("단가를 입력하세요"); return false; 
                 }
                
                //예약배포/예약기안시 validation 체크 (10분이후 시간부터만 가능하도록)
                if ((getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") && (getInfo("SchemaContext.scReserveDraft.isUse") == "Y" || getInfo("SchemaContext.scReserveDist.isUse") == "Y")) {
                	 
                	var objToday, todayYear, todayMonth, todayDay, todayHour, todayMinute, tmpTodayStr, tmpReservedStr;
					
					if(!Common.getBaseConfig("useTimeZone") == "Y"){
		        		objToday = new Date(Date.parse(new Date()) + 1000 * 60 * 10);
					}else{
						objToday = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
					}
                	
	        		todayYear = objToday.getFullYear() + "";
	
	        		todayMonth = objToday.getMonth() + 1;
	        		todayMonth = (todayMonth < 10) ? "0" + todayMonth : todayMonth + "";
	
	        		todayDay = objToday.getDate();
	        		todayDay = (todayDay < 10) ? "0" + todayDay : todayDay + "";
	
	        		todayHour = objToday.getHours();
	        		todayHour = (todayHour < 10) ? "0" + todayHour : todayHour + "";
	
	        		todayMinute = objToday.getMinutes();
	        		todayMinute = (todayMinute < 10) ? "0" + todayMinute : todayMinute + "";
	
	        		tmpTodayStr = todayYear + todayMonth + todayDay + todayHour + todayMinute;
	        		
                	if ($("#chk_reserved_draft").is(":checked")) {
                		 if ($("#reservedDate").val() == "") {
                            alert(Common.getDic("msg_ApvNoReserveDraftDate")); // 예약기안 날짜를 입력해주세요. 
                            return false;
                		 }
                		 tmpReservedStr = $("#reservedDate").val().replace(/-/g, "").replace(/\./g, "") + $("#reservedHour").val() + $("#reservedMin").val();
                		 if (tmpReservedStr <= tmpTodayStr) {
                			 alert(Common.getDic("msg_ApvReserveDraftDate_01")); // 현재 시간으로부터 10분 이후 시간에만 예약 가능 합니다.
                			 return false;
                		 }
                	 }
                	 if ($("#chk_reserved_dist").is(":checked")) {
                		 if ($("#distReservedDate").val() == "") {
                             alert(Common.getDic("msg_ApvNoReserveDistDate")); // 예약배포 날짜를 입력해주세요. 
                             return false;
                 		 }
                 		 tmpReservedStr = $("#distReservedDate").val().replace(/-/g, "").replace(/\./g, "") + $("#distReservedHour").val() + $("#distReservedMin").val();
                 		 if (tmpReservedStr <= tmpTodayStr) {
                 			 alert(Common.getDic("msg_ApvReserveDraftDate_01")); // 현재 시간으로부터 10분 이후 시간에만 예약 가능 합니다.
                 			 return false;
                 		 }
                	 }
                	 // both. 
                	 if ($("#chk_reserved_draft").is(":checked") && $("#chk_reserved_dist").is(":checked")) {
                		 var tmpReservedDraftStr = $("#reservedDate").val().replace(/-/g, "").replace(/\./g, "") + $("#reservedHour").val() + $("#reservedMin").val();
                		 var tmpReservedDistStr = $("#distReservedDate").val().replace(/-/g, "").replace(/\./g, "") + $("#distReservedHour").val() + $("#distReservedMin").val();
                		 
                		 if(tmpReservedDistStr <= tmpReservedDraftStr){
                 			 alert(Common.getDic("msg_ApvReserveDraftDate_02")); // 예약배포 시간은 예약기안 시간 이후여야 합니다.
                 			 return false;
                		 }
                	 }
                }// end Reserved info. check

                var elmRecList = $$(elmRoot).find("division").has("taskinfo[status='pending']").find(">step[routetype='approve']>ou>person,>step[routetype='approve']>ou>role").has("taskinfo[kind!='charge']");
                if ((getInfo("SchemaContext.scDRec.isUse") == "Y" || getInfo("SchemaContext.scDRecEnt.isUse") == "Y" || getInfo("SchemaContext.scDRecReg.isUse") == "Y") && (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "APPROVAL")) {
                    var elmOu = $$(elmRoot).find("division>step[routetype='receive']>ou");
                    if (elmOu.length == 0 && !(getInfo("SchemaContext.scChgrOU.isUse") == "Y" && getInfo("SchemaContext.scChgrOU.value") != "")) {
                        if (!confirm(Common.getDic("msg_apv_199"))) return false;
                        else return checkFormComm(); //"경유부서 없이 진행하시겠습니까?"
                    } else {
                        //
                    }
                }

                if ((getInfo("SchemaContext.scPRec.isUse") == "Y" || getInfo("SchemaContext.scPRecEnt.isUse") == "Y" || getInfo("SchemaContext.scPRecReg.isUse") == "Y") && (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "APPROVAL")) {
                    var elmOu = $$(elmRoot).find("division>step[routetype='receive']>ou>person");

                    if (elmOu.length == 0) {
                        if (getInfo("SchemaContext.scPRec.value") == "select") {
                            if (!confirm(Common.getDic("msg_apv_201"))) return false; //"담당자 지정없이 진행하시겠습니까?"
                        } else {
                            if ((getInfo("SchemaContext.scDRec.isUse") == "Y" || getInfo("SchemaContext.scDRecEnt.isUse") == "Y" || getInfo("SchemaContext.scDRecReg.isUse") == "Y") && (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "APPROVAL")) {
                                elmOu = $$(elmRoot).find("division>step[routetype='receive']");
                                if (elmOu.length == 0) {
                                    alert(Common.getDic("msg_apv_074")); //"수신처가 없습니다. 수신처를 지정하십시요."
                                    return false;
                                }
                            } else {
                                alert(Common.getDic("msg_apv_181")); //"담당자를 지정하십시요"
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
                    Common.Warning(Common.getDic("msg_apv_202")); //"문서관리시스템 이관을 위한 문서정보를 입력하십시오."
                    return false;
                }
                if((getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT") && getInfo("Request.editmode") != "Y")
                	return true;
                else
                	return checkFormComm();
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
                    	if (getInfo("Request.mode") == "REDRAFT" && (getInfo("SchemaContext.scChrRedraft.isUse") == "Y")) {// || getInfo("Request.subkind") == "T008"
                            if (!confirm(Common.getDic("msg_apv_198"))) return false;
                        } else if (getInfo("Request.mode") == "SUBREDRAFT" && getInfo("SchemaContext.scChrDraft.isUse") == "Y" && getInfo("SchemaContext.scRecAssist.isUse") == "Y") {
                        	// 부서합의(협조)인 경우 1인결재 & 접수 기능 사용 시 전결처리 가능하도록 수정함.
                            if (!confirm(Common.getDic("msg_apv_198"))) return false;
                        } else {
                            Common.Warning(Common.getDic("msg_apv_029")); //"결재선이 지정되지 않았습니다."
                            return false;
                        }
                    }
                }

                if (getInfo("Request.editmode") == "Y") {
                    return checkFormComm();
                } else {
					var isDeploy = false;
					if(getInfo("SchemaContext.pdef.value").toLowerCase().indexOf("draft") > -1 
						&& formJson.ApprovalLine && $$(formJson.ApprovalLine).find("division").has("taskinfo[status='pending']").find("[divisiontype='receive']").length > 0){
							isDeploy = true;
					}
						
					// 배포처일땐 제외, 후결 제외
					if(!isDeploy && getInfo("ProcessInfo.SubKind") != "T005"){
	                    if (getInfo("SchemaContext.scCheckApproval.isUse") == "Y") {
	                        return checkFormComm();
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
    // 진행함에서 부서내반송 클릭하는 경우 => 재기안 회수 처리.
    if(sReqMode == "ABORT" || sReqMode == "WITHDRAW" || sReqMode == "APPROVECANCEL"
    	|| (getInfo("ProcessInfo.SubKind") == "T006" && getInfo("Request.loct") == "PROCESS" 
			&& (getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL") && document.getElementById("ACTIONINDEX").value == "REJECTTODEPT")
	){
    	var taskid = "";
    	var apvLineObj = $.parseJSON(getInfo("ApprovalLine"));
    	
    	var ou = $$("{}"); 
		if(getInfo("Request.mode") == "SUBAPPROVAL"){ // 부서합의류(Subprocess)
			ou = $$(apvLineObj).find("division>step>ou").has("taskinfo[status='pending'][piid='" + getInfo("ProcessInfo.ProcessID") + "'],taskinfo[status='reserved'][piid='" + getInfo("ProcessInfo.ProcessID") + "']").concat().last().eq(0);
		}else{
			ou = $$(apvLineObj).find("division>step>ou").has("taskinfo[status='pending'],taskinfo[status='reserved']").concat().last().eq(0);
		}

    	var unittype = $$(ou).parent().attr("unittype");
    	
    	if(unittype == "ou" && $$(ou).find("person").has("taskinfo[status='pending'],[status='reserved']").concat().eq(0).length > 0)
    		taskid = $$(ou).find("person").has("taskinfo[status='pending'],[status='reserved']").concat().eq(0).attr("taskid");
    	else
    		taskid = $$(ou).attr("taskid");
    	
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
	//$.extend(jsonObj, makeNode("dpdn_apv", (getInfo("AppInfo.dpnm_multi") == undefined ? "" : getInfo("AppInfo.dpnm_multi")).replace("&", "&amp;")));
	$.extend(jsonObj, makeNode("dpdn_apv", getInfo("AppInfo.dpdn_apv")));
	$.extend(jsonObj, makeNode("usdn", getInfo("AppInfo.usnm_multi")));
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
    
    $.extend(jsonObj, {"AttachFileSeq" : $("#hidFileSeq").val()});
	
    return jsonObj;
}

/*** xml -> json **/
function setForwardApvList(elmRoot) {//전달일 경우 처리
    try {
        var jsonApv = $.parseJSON(getInfo("ApprovalLine"));
        if (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL") { //기안부서결재선 및 수신부서 결재선
            var oFirstNode;
            if (admintype == "ADMIN") {
                if (getInfo("Request.mode") == "APPROVAL") {
                	oFirstNode = $$(jsonApv).find("steps>division>step:has([routetype='approve']):has(taskinfo[status='pending'])").find(">ou>person[code='" + getInfo("Request.userCode") + "']>taskinfo[status='pending'], >ou>role:has(person[code='" + getInfo("Request.userCode") + "'])>taskinfo[status='pending']");
                } else if (getInfo("Request.mode") == "PCONSULT") {
                    oFirstNode = $$(jsonApv).find("steps>division>step").has("taskinfo[status='pending']").find(">ou>person[code='" + getInfo("Request.userCode") + "']>taskinfo[status='pending'], >ou>role:has(person[code='" + getInfo("Request.userCode") + "'])>taskinfo[status='pending']");
                } else if (getInfo("Request.mode") == "SUBAPPROVAL") {
                    oFirstNode = $$(jsonApv).find("steps>division>step").has("taskinfo[status='pending']").find("ou").has("taskinfo[piid='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "']").find(">person[code='" + getInfo("Request.userCode") + "']>taskinfo[status='pending'], >role:has(person[code='" + getInfo("Request.userCode") + "'])>taskinfo[status='pending']");
                } else {
                    oFirstNode = $$(jsonApv).find("steps>division>step[unittype='ou'][routetype='receive']>ou>person[code='" + getInfo("AppInfo.usid") + "']>taskinfo[kind!='charge'][status='pending']");
                }
            } else {
                if (getInfo("Request.mode") == "APPROVAL") {
                	oFirstNode = $$(jsonApv).find("steps>division>step:has([routetype='approve']):has(taskinfo[status='pending'])>ou").find(">person[code='" + getInfo("Request.userCode") + "']>taskinfo[status='pending'], >role:has(person[code='" + getInfo("Request.userCode") + "'])>taskinfo[status='pending']");
                } else if(getInfo("Request.mode") == "RECAPPROVAL") {
                	oFirstNode = $$(jsonApv).find("steps>division>step:has([routetype='approve'])>ou").find(">person[code='" + getInfo("Request.userCode") + "']>taskinfo[status='pending'], > role:has(person[code='" + getInfo("Request.userCode") + "'])>taskinfo[status='pending']");
                } else if (getInfo("Request.mode") == "PCONSULT") {
                    oFirstNode = $$(jsonApv).find("steps>division>step:has(taskinfo[status='pending'])>ou").find(">person[code='" + getInfo("Request.userCode") + "'][code='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'], >role:has(person[code='" + getInfo("Request.userCode") + "'][code='" + getInfo("AppInfo.usid") + "'])>taskinfo[status='pending']");
                } else if (getInfo("Request.mode") == "SUBAPPROVAL") {
                    oFirstNode = $$(jsonApv).find("steps>division>step:has(taskinfo[status='pending'])>ou").has("taskinfo[piid='" + getInfo("ProcessInfo.ProcessID").toUpperCase() + "']").find(">person[code='" + getInfo("Request.userCode") + "'][code='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'], >role:has(person[code='" + getInfo("Request.userCode") + "'][code='" + getInfo("AppInfo.usid") + "'])>taskinfo[status='pending']");
                } else {
                    oFirstNode = $$(jsonApv).find("steps>division>step[unittype='ou'][routetype='receive']>ou>person[code='" + getInfo("AppInfo.usid") + "']>taskinfo[kind!='charge'][status='pending']");
                }
            }
            if (oFirstNode.length > 0) {
                m_bDeputy = true; 
                m_bApvDirty = true; 
                var elmOU; 
                var elmPerson; 
                var elmInactivePerson;
                
                //원결재자 정보
                var oConveyance;
                var oWiid;
                var oWidescid;
                var oPfid; 
                var oTaskid;
                
                elmOU = $$(oFirstNode).parent().parent();
                elmPerson = $$(oFirstNode);
                
                switch (getInfo("Request.mode")) {
                    case "APPROVAL":
                    case "PCONSULT":
                        //
                        break;
                    case "SUBAPPROVAL":
                        elmInactivePerson = $$(elmOU).find("person").has("taskinfo[status='inactive']");                      
                        break;
                    case "RECAPPROVAL":
                        //
                        break;
                }


                var elmTaskInfo = $$(elmPerson).find("taskinfo");
                var skind = $$(oFirstNode).attr("kind");
                //taskinfo kind 현재 결재자의 kind=conveyance, 다음 결재자는 원결재자의 kind를 받는다.
                $$(oFirstNode).attr("status", "completed");
                $$(oFirstNode).attr("result", "completed");
                $$(oFirstNode).attr("kind", "conveyance");
                $$(oFirstNode).attr("datecompleted", CFN_TransServerTime(CFN_GetLocalCurrentDate()));
                if (admintype == "ADMIN") {
                    $$(oFirstNode).attr("visible", "n");
                }
                //전달받은 사용자 결재선 생성
                var oStep = {};
                var oOU = {};
                var oPerson = {};
                var oTaskinfo = {};
                

                
                $$(oTaskinfo).attr("status", "pending");
                $$(oTaskinfo).attr("result", "pending");
                $$(oTaskinfo).attr("kind", skind);
                $$(oTaskinfo).attr("datereceived", CFN_TransServerTime(CFN_GetLocalCurrentDate()));
                
                $$(oPerson).attr("code", $$(elmRoot).find("item").concat().eq(0).attr("AN"));
                $$(oPerson).attr("name", $$(elmRoot).find("item").concat().eq(0).attr("DN"));
                $$(oPerson).attr("position", $$(elmRoot).find("item").concat().eq(0).attr("po"));
                $$(oPerson).attr("title", $$(elmRoot).find("item").concat().eq(0).attr("tl"));
                $$(oPerson).attr("level", $$(elmRoot).find("item").concat().eq(0).attr("lv"));
                $$(oPerson).attr("oucode", $$(elmRoot).find("item").concat().eq(0).attr("RG"));
                $$(oPerson).attr("ouname", $$(elmRoot).find("item").concat().eq(0).attr("RGNM"));
                $$(oPerson).attr("sipaddress", $$(elmRoot).find("item").concat().eq(0).attr("SIP"));
                
                if(getInfo("Request.mode")=="SUBAPPROVAL"){
                    oConveyance = $$(jsonApv).find("steps>division>step[unittype='ou']>ou>person[code='" + getInfo("Request.userCode") + "']:has(taskinfo[kind='conveyance'][status='completed'])");
                    oWiid = oConveyance.attr("wiid");
                    oWidescid = oConveyance.attr("widescid");
                    oPfid = oConveyance.attr("pfid");
                    oTaskid = oConveyance.attr("taskid");  
                    
                    $$(oPerson).attr("wiid",oWiid);
                    $$(oPerson).attr("widescid",oWidescid);
                    $$(oPerson).attr("pfid",oPfid);
                    $$(oPerson).attr("taskid",oTaskid);
                }

                
                if (getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL") {
                    if (elmInactivePerson != null) {
                    	$$(elmOU).append("person", oPerson);
                        //$$(elmOU).find("people").json().splice(0, 0, oPerson);
                    	//$$(elmOU).find("people").concat().eq($$(elmOU).find("people").concat().length-1).remove();  
                    	$$(elmOU).find("person").json().splice(parseInt(oFirstNode.parent().path().substr(oFirstNode.parent().path().lastIndexOf("/")+8, 1)), 1, oPerson);
                    	$$(elmOU).find("person").concat().eq($$(elmOU).find("person").concat().length-1).remove();			// 배열로 만들기 위해서 추가했던 person을 지움               
                        $$(oPerson).append("taskinfo", oTaskinfo);
                    } else {
                        $$(elmOU).append("person", oPerson);
                        $$(oPerson).append("taskinfo", oTaskinfo);
                    }
                } else {
                    $$(elmOU).append("person", oPerson);
                    $$(oPerson).append("taskinfo", oTaskinfo);
                }
                
                var oResult = $$(jsonApv);

                document.getElementById("APVLIST").value = JSON.stringify(oResult.json());
                
            } else { document.getElementById("APVLIST").value = getInfo("ApprovalLine"); }
        } else if((getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT") && document.getElementById("ACTIONINDEX").value == "FORWARD"){		// 수신부서 전달
        	var oFirstNode;
        	
        	if(getInfo("Request.mode") == "REDRAFT"){
        		oFirstNode = $$(jsonApv).find("steps>division>step").has("[routetype='receive'],[routetype='approve']").find("ou[code='" + getInfo("AppInfo.dpid") + "']").has("taskinfo[status='pending']");
        	}else if(getInfo("Request.mode") == "SUBREDRAFT"){
        		oFirstNode = $$(jsonApv).find("steps>division").find("step").has("[routetype='assist'],[routetype='consult'],[routetype='audit']").find(">ou[code='" + getInfo("AppInfo.dpid") + "']").has(">taskinfo[status='pending']");
        	}
        	
        	$$(oFirstNode).attr("code", document.getElementById("CHARGEID").value);
        	$$(oFirstNode).attr("name", document.getElementById("CHARGENAME").value);
        	
        	document.getElementById("APVLIST").value = JSON.stringify($$(jsonApv).json());
        	
        } else if((getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT") && document.getElementById("ACTIONINDEX").value == "CHARGE"){		// 부서 수신 시 담당자 설정
        	
        	var pendingOU;
        	
        	if(getInfo("Request.mode") == "REDRAFT"){
        		pendingOU = $$(jsonApv).find("steps>division>step").has("[routetype='receive'],[routetype='approve']").find("ou[code='" + getInfo("AppInfo.dpid") + "']").has("taskinfo[status='pending']");
        		
        		$$(pendingOU).remove("wiid");
        		$$(pendingOU).remove("widescid");
        		$$(pendingOU).remove("taskid");
        		$$(pendingOU).remove("pfid");
        		
        		$$(pendingOU).parent().attr("unittype", "person");
        		$$(pendingOU).parent().attr("routetype", "approve");
        	}else if(getInfo("Request.mode") == "SUBREDRAFT"){
        		pendingOU = $$(jsonApv).find("steps>division").find("step").has("[routetype='assist'],[routetype='consult'],[routetype='audit']").find(">ou[code='" + getInfo("AppInfo.dpid") + "']").has(">taskinfo[status='pending']");
        	}
    		var chargePerson = {};
    		var chargeTaskinfo = {};
    		
    		$$(chargeTaskinfo).attr("status", "pending");
            $$(chargeTaskinfo).attr("result", "pending");
            $$(chargeTaskinfo).attr("kind", "charge");
            $$(chargeTaskinfo).attr("datereceived", CFN_TransServerTime(CFN_GetLocalCurrentDate()));
            
            $$(chargePerson).attr("code", $$(elmRoot).find("item").concat().eq(0).attr("AN"));
            $$(chargePerson).attr("name", $$(elmRoot).find("item").concat().eq(0).attr("DN"));
            $$(chargePerson).attr("position", $$(elmRoot).find("item").concat().eq(0).attr("po"));
            $$(chargePerson).attr("title", $$(elmRoot).find("item").concat().eq(0).attr("tl"));
            $$(chargePerson).attr("level", $$(elmRoot).find("item").concat().eq(0).attr("lv"));
            $$(chargePerson).attr("oucode", $$(elmRoot).find("item").concat().eq(0).attr("RG"));
            $$(chargePerson).attr("ouname", $$(elmRoot).find("item").concat().eq(0).attr("RGNM"));
            $$(chargePerson).attr("sipaddress", $$(elmRoot).find("item").concat().eq(0).attr("SIP"));
            
            $$(chargePerson).append("taskinfo", chargeTaskinfo);
            
            $$(pendingOU).append("person", chargePerson);
        	
        	document.getElementById("APVLIST").value = JSON.stringify($$(jsonApv).json());
        	
        }else { document.getElementById("APVLIST").value = getInfo("ApprovalLine"); }
    } catch (e) { alert(e.message); }
}


/**
 * xml -> json
 */
function setApvList() {//대결일 경우 처리
    try {
        var jsonApv = $.parseJSON(getInfo("ApprovalLine"));

        if (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "AUDIT" ) { //기안부서결재선 및 수신부서 결재선
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
            	Common.Warning(Common.getDic("msg_ApprovalDeputyWarning"));
            	
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
                try { if ($$(elmStep).attr("allottype") != null) sallottype = $$(elmStep).attr("allottype"); } catch (e) { coviCmn.traceLog(e); }
                //taskinfo kind에 따라 처리  일반결재 -> 대결, 대결->사용자만 변환, 전결->전결, 기존사용자는 결재안함으로
                // [19-08-19] kimhs, 전결을 유지하는 경우 원결재자가 완료함에서 문서 열람 불가함. 대결로 변경처리함.
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
                        $$(oStep).attr("name", Common.getDic("lbl_apv_writer"));
                        
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
                        
                        //$$(jsonApv).find("steps>division").insertBefore(oStep, elmStep);
                    }
                }

                var oResult = $$(jsonApv).json();

                document.getElementById("APVLIST").value = JSON.stringify(oResult);
            }
            else {
                document.getElementById("APVLIST").value = getInfo("ApprovalLine");
            }
        }
        else {
            document.getElementById("APVLIST").value = getInfo("ApprovalLine");
        }
    }
    catch (e) {
        alert(e.message);
    }
}

// xml -> json
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
            $$(oStep).attr("name", Common.getDic("lbl_apv_ChargeDept_Rec"));		
            
            $$(oDiv).append("step", oStep);
            $$(jsonApv).find("steps").append("division", oDiv);
            
            oFirstNode = $$(jsonApv).find("steps>division").has("taskinfo[status='pending']").has("[divisiontype='receive'][oucode='" + getInfo("AppInfo.dpid_apv") + "']").find(">step>ou");
        }
        if ($$(oFirstNode).find("person[code='" + getInfo("AppInfo.usid") + "']>taskinfo[kind='charge']") == null) {
        	
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

        /*비사용
         * if (getInfo("Request.subkind") == "RE") {//공람으로 저장일 경우 다음 결재자 삭제
            var oApprovalNode = $$(jsonApv).find("steps>division").has("taskinfo[status='pending'])[divisiontype='receive'][oucode='" + getInfo("AppInfo.dpid_apv") + "']").find(">step").has(">ou>person>taskinfo[kind!='charge']");
            if (oApprovalNode.length > 0) {
                oApprovalNode.each(function (i, elm) {
                    $$(jsonApv).find("steps>division").has("taskinfo[status='pending']").has("[divisiontype='receive'][oucode='" + getInfo("AppInfo.dpid_apv") + "']").removeChild(elm);
                });
            }
            $(jsonApv).find("apvlist > steps > division:has(taskinfo[status='pending'])[divisiontype='receive'][oucode='" + getInfo("AppInfo.dpid_apv") + "'] > step > ou > person[code='" + getInfo("AppInfo.usid") + "'] > taskinfo[kind='charge']").attr("visible", "n");
        }*/
    }
    //결재선 임시 저장 관련 수정 - 기안자만 있는 경우 넘기지 결재선을 넘기지 않는다.
    // 회수 및 기안취소 포함
    if (m_sReqMode == "TEMPSAVE" || m_sReqMode == "WITHDRAW" || m_sReqMode == "ABORT") {
        var oFirstNodeList = $$(jsonApv).find("steps>division>step>ou>person");
        //기안자만 있는 경우 초기화  시키는데, 그럴경우 추가된 참조자도 사라짐.*/
        var oCurrentDivNode = $$(jsonApv).find("steps>division[divisiontype='send']");
        var oChargeNode = $$(oCurrentDivNode).find("step").has("ou>person>taskinfo[kind='charge']");
        
        if (oChargeNode.length != 0)
        	$$(oCurrentDivNode).find("step").has("ou>person>taskinfo[kind='charge']").concat().eq(0).remove();
        
        var oCurrentDivTaskinfo = $$(oCurrentDivNode).find("taskinfo");
        $$(oCurrentDivTaskinfo).attr("status", "inactive");
        $$(oCurrentDivTaskinfo).attr("result", "inactive");
        
        try { $$(oCurrentDivTaskinfo).remove("datereceived"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivTaskinfo).remove("datecompleted"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivTaskinfo).remove("customattribute1"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivTaskinfo).remove("wiid"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivTaskinfo).remove("mobileType"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivNode).find("step").concat().find("person").concat().find("taskinfo>comment").remove(); } catch (e) { coviCmn.traceLog(e); }
        
        //그외 노드의 경우 status result datereceived
        /*var oTaskinfos = $$(oCurrentDivNode).find("step>ou>person>taskinfo");
        $$(oTaskinfos).each(function (i, elm) {
            $$(elm).attr("status", "inactive");
            $$(elm).attr("result", "inactive");
            $$(elm).remove("datereceived");
            $$(elm).remove("datecompleted");
            $$(elm).remove("mobilegubun");
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
        });*/
        
        $$(oCurrentDivNode).find("step").concat().each(function(i, elm){
        	if ($$(elm).attr("unittype") == "ou") {
                var oOU = $$(elm).find("ou");
                $$(oOU).concat().each(function (i, ouNode) {
                    $$(ouNode).children().remove();
                	
                    var newOuTaskinfo = {};
                    
                    if ($$(elm).attr("routetype") == "consult") { $$(newOuTaskinfo).attr("kind", "consult"); }
                    else if ($$(elm).attr("routetype") == "assist") { $$(newOuTaskinfo).attr("kind", "assist"); }
                    else { $$(newOuTaskinfo).attr("kind", "normal"); }

                    $$(ouNode).append("taskinfo", newOuTaskinfo);
                });
                $$(elm).find("taskinfo").remove("datereceived");
            }
        	
        	var oOU = $$(elm).find("ou").concat();
        	
        	$$(oOU).concat().each(function(i, ouObj){
	        	// 엔진에서 작성되는 값들 지우기
		        $$(ouObj).remove("pfid");
		        $$(ouObj).remove("taskid");
		        $$(ouObj).remove("widescid");
		        $$(ouObj).remove("wiid");
		
		        //division/step/ou/taskinfo
		        var oOUTaskinfo = $$(ouObj).find("taskinfo");
		        if ($$(oOUTaskinfo).length != 0) {
		            $$(oOUTaskinfo).attr("status", "inactive");
		            $$(oOUTaskinfo).attr("result", "inactive");
		            $(oOUTaskinfo).attr("datereceived", "");
		
		            if ($$(oOUTaskinfo).attr("datecompleted")) { $$(oOUTaskinfo).remove("datecompleted"); }
		            if ($$(oOUTaskinfo).attr("wiid")) { $$(oOUTaskinfo).remove("wiid"); }
		
		            if ($$(oOUTaskinfo).find("comment").concat().eq(0)) { $$(oOUTaskinfo).find("comment").remove(); }
		            if ($$(oOUTaskinfo).find("comment_fileinfo").concat().eq(0)) { $$(oOUTaskinfo).find("comment_fileinfo").remove(); }
		            if ($$(oOUTaskinfo).find("consultcomment").concat().eq(0)) { $$(oOUTaskinfo).find("consultcomment").remove(); }
		            
		            $$(oOUTaskinfo).remove("datereceived");
		        }
		        //division/step/person/taskinfo
		        if($$(ouObj).find("person").concat().length > 1) {
		        	$$(ouObj).find("person > taskinfo[kind='conveyance']").each(function(){ 
		        		$$(ouObj).find("person > taskinfo[kind='conveyance']").eq(0).parent().remove(); 
		        	});
	        		
	        		if($$(ouObj).find("person").concat().length == 1) {
	        			$$(ouObj).attr("person", $$(ouObj).find("person").json()[0]);
	        		}
		        }
		        
		        var oPersonTaskinfo = $$(ouObj).find("person>taskinfo");
		        if ($$(oPersonTaskinfo).length != 0) {
		            $$(oPersonTaskinfo).attr("status", "inactive");
		            $$(oPersonTaskinfo).attr("result", "inactive");
		            if ($$(oPersonTaskinfo).attr("kind") == "charge") $$(oPersonTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
		            else $$(oPersonTaskinfo).attr("datereceived", "");
		            
		            if ($$(oPersonTaskinfo).attr("datecompleted")) { $$(oPersonTaskinfo).remove("datecompleted"); }
		            if ($$(oPersonTaskinfo).attr("wiid")) { $$(oPersonTaskinfo).remove("wiid"); }
		            if ($$(oPersonTaskinfo).attr("customattribute1")) { $$(oPersonTaskinfo).remove("customattribute1"); }
		            if ($$(oPersonTaskinfo).attr("mobileType")) { $$(oPersonTaskinfo).remove("mobileType"); }
		
		            if ($$(oPersonTaskinfo).find("comment").concat().eq(0).json()) { $$(oPersonTaskinfo).find("comment").remove(); }
		            if ($$(oPersonTaskinfo).find("comment_fileinfo").concat().eq(0).json()) { $$(oPersonTaskinfo).find("comment_fileinfo").remove(); }
		        }
		        
		        $$(ouObj).find("person>consultation").remove();
        	});
        });
        
        //참조 셋팅
        var oCcinfo = $$(jsonApv).find("steps>ccinfo");
        try {
        	if(oCcinfo.exist()){
	            $$(oCcinfo).concat().each(function (i, elm) {
	                $$(elm).attr("datereceived", "");
	            });
        	}
        } catch (e) { coviCmn.traceLog(e); }
    }
    return jsonApv;
}

/**
 * xml -> json
 */
function getApvListReUse() {
    var jsonApv = $.parseJSON(getInfo("ApprovalLine"));
    var elmRoot = $$(jsonApv).find("steps");
    
    $$(elmRoot).attr("status", "inactive");

    if ($$(elmRoot).attr("datecreated")) { $$(elmRoot).remove("datecreated"); }
    if ($$(elmRoot).attr("datecompleted")) { $$(elmRoot).remove("datecompleted"); }
    if ($$(elmRoot).attr("result")) { $$(elmRoot).remove("result"); }

    var elmList = $$(elmRoot).find("division").concat().eq(0);  //기안부서만(:first-child)
    var oCCinfo = $$(elmRoot).find("ccinfo").concat();   //참조

    //지정반려 시 필요없는 결재선 지우기
    //$$(elmList).find("step").has("ou>person>taskinfo[rejectee='y']").remove();
    var cnt = $$(elmList).find("step").concat().length;
    var rmvCnt = 0;
    for(var i=0; i<cnt; i++){
    	var oStep = $$(elmList).find("step").concat().eq(i-rmvCnt);
    	
    	if($$(oStep).find("ou>person>taskinfo").attr("rejectee") == "y") {
    		$$(oStep).remove();
    		rmvCnt++;
    	}
    }
    
    // 엔진에서 작성되는 값들 지우기
    $$(elmList).remove("processDescID");
    $$(elmList).remove("processID");

    //division/taskinfo
    var oDivTaskinfo = $$(elmList).find("taskinfo");
    $$(oDivTaskinfo).attr("status", "inactive");
    $$(oDivTaskinfo).attr("result", "inactive");
    $$(oDivTaskinfo).attr("datereceived", "");
    if ($$(oDivTaskinfo).attr("datecompleted")) { $$(oDivTaskinfo).remove("datecompleted"); }

    $$(elmRoot).children().remove().append("division", $$(elmList).json()); //모두 지우고 기안부서만 남김.

    //division/step	    
    var oDivStep = $$(elmRoot).find("division>step");
    $$(oDivStep).concat().each(function (j, elm2) {
        //기안자가 겸직변경 했을 경우를 대비해 결재선 재정비
        //division/step/ou
        var oOU = $$(elm2).find("ou").concat();
        
        if ($$(oOU).length == 1 && j == 0 && $$(oOU).find("person>taskinfo").attr("kind") == "charge") {
            $$(oOU).attr("code", getInfo("AppInfo.dpid_apv"));    //겸직처리를 위해 수정
            $$(oOU).attr("name", getInfo("AppInfo.dpdn_apv"));    //겸직처리를 위해 수정

            //division
            $$(oOU).closest("division").attr("oucode", getInfo("AppInfo.dpid_apv"));
            $$(oOU).closest("division").attr("ouname", getInfo("AppInfo.dpdn_apv"));

            //steps
            $$(elmRoot).attr("initiatoroucode", getInfo("AppInfo.dpid_apv"));
            
            var oPerson = $$(oOU).find("person");
            $$(oPerson).attr("code", getInfo("AppInfo.usid"));
            $$(oPerson).attr("name", getInfo("AppInfo.usnm_multi"));
            $$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
            $$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
            $$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
            $$(oPerson).attr("oucode", getInfo("AppInfo.dpid"));  //겸직처리를 위해 수정
            $$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));  //겸직처리를 위해 수정
        }
        
        //부서협조/합의인 경우 ou 하위 결재선 삭제후 ou taskinfo 생성
        if ($$(elm2).attr("unittype") == "ou") {
            var oOU = $$(elm2).find("ou");
            $$(oOU).concat().each(function (i, ouNode) {
                $$(ouNode).children().remove();
            	
                var newOuTaskinfo = {};
                
                if ($$(elm2).attr("routetype") == "consult") { $$(newOuTaskinfo).attr("kind", "consult"); }
                else if ($$(elm2).attr("routetype") == "assist") { $$(newOuTaskinfo).attr("kind", "assist"); }
                else { $$(newOuTaskinfo).attr("kind", "normal"); }

                $$(ouNode).append("taskinfo", newOuTaskinfo);
            });
            $$(elm2).find("taskinfo").remove("datereceived");
        }
        
    	$$(oOU).concat().each(function(i, ouObj){
	        // 엔진에서 작성되는 값들 지우기
	        $$(ouObj).remove("pfid");
	        $$(ouObj).remove("taskid");
	        $$(ouObj).remove("widescid");
	        $$(ouObj).remove("wiid");
	
	        //division/step/ou/taskinfo
	        var oOUTaskinfo = $$(ouObj).find("taskinfo");
	        if ($$(oOUTaskinfo).length != 0) {
	            $$(oOUTaskinfo).attr("status", "inactive");
	            $$(oOUTaskinfo).attr("result", "inactive");
	            $(oOUTaskinfo).attr("datereceived", "");
	
	            if ($$(oOUTaskinfo).attr("datecompleted")) { $$(oOUTaskinfo).remove("datecompleted"); }
	            if ($$(oOUTaskinfo).attr("wiid")) { $$(oOUTaskinfo).remove("wiid"); }
	
	            if ($$(oOUTaskinfo).find("comment").concat().eq(0)) { $$(oOUTaskinfo).find("comment").remove(); }
	            if ($$(oOUTaskinfo).find("comment_fileinfo").concat().eq(0)) { $$(oOUTaskinfo).find("comment_fileinfo").remove(); }
	            
	            $$(oOUTaskinfo).remove("datereceived");
	        }
	        //division/step/person/taskinfo
	        if($$(ouObj).find("person").concat().length > 1) {
	        	$$(ouObj).find("person > taskinfo[kind='conveyance']").each(function(){ 
	        		$$(ouObj).find("person > taskinfo[kind='conveyance']").eq(0).parent().remove(); 
	        	});
        		
        		if($$(ouObj).find("person").concat().length == 1) {
        			$$(ouObj).attr("person", $$(ouObj).find("person").json()[0]);
        		}
	        }
	        
	        var oPersonTaskinfo = $$(ouObj).find("person>taskinfo");
	        if ($$(oPersonTaskinfo).length != 0) {
	            $$(oPersonTaskinfo).attr("status", "inactive");
	            $$(oPersonTaskinfo).attr("result", "inactive");
	            if ($$(oPersonTaskinfo).attr("kind") == "charge") $$(oPersonTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
	            else $$(oPersonTaskinfo).attr("datereceived", "");
	            
	            if ($$(oPersonTaskinfo).attr("datecompleted")) { $$(oPersonTaskinfo).remove("datecompleted"); }
	            if ($$(oPersonTaskinfo).attr("wiid")) { $$(oPersonTaskinfo).remove("wiid"); }
	            if ($$(oPersonTaskinfo).attr("customattribute1")) { $$(oPersonTaskinfo).remove("customattribute1"); }
	            if ($$(oPersonTaskinfo).attr("mobileType")) { $$(oPersonTaskinfo).remove("mobileType"); }
	
	            if ($$(oPersonTaskinfo).find("comment").concat().eq(0).json()) { $$(oPersonTaskinfo).find("comment").remove(); }
	            if ($$(oPersonTaskinfo).find("comment_fileinfo").concat().eq(0).json()) { $$(oPersonTaskinfo).find("comment_fileinfo").remove(); }
	        }
        });
    });

    if(oCCinfo.exist()){
    	$$(oCCinfo).attr("datereceived", "");
        //참조 부서 추가
        $$(elmRoot).append("ccinfo", oCCinfo.json());
    }

    //대결자 결재로 인해 후열된 원결재자 결재선 복귀 
    var bypassElmList = $$(elmRoot).find("division>step>ou>person>taskinfo[kind='bypass']"); //후열
    $$(bypassElmList).attr("kind", "normal"); //kind bypass -> normal
    var duputyElmList = $$(elmRoot).find("division>step>ou>person>taskinfo[kind='substitute']"); //대결자삭제
    duputyElmList.parent().remove();

    //재사용결재선 퇴직자
    //임의 주석
    var chkAbsentResult = chkAbsent(elmRoot, true);
	if (chkAbsentResult != "") {
		chkAbsentResult = chkAbsentResult.split("@@@");
		var absentType = chkAbsentResult[0];
		var absentMsg = chkAbsentResult[1];
		var absentCode = chkAbsentResult[2].split(",");
		
		alert(absentMsg);
		
		if(absentType == "absent") {
        	$$(elmRoot).find("division>step>ou>person>taskinfo[kind!='charge']").parent().remove();
		} else {
			for(var i = 0; i < absentCode.length; i++) {
				if(absentCode[i] != "") {
					$$(elmRoot).find("division>step>ou>person[code='"+absentCode[i]+"']").remove();
				}	
			}
		}
    }
	
	//재사용결재선 퇴직자 - 참조
	var chkAbsentCCInfo = chkAbsent(elmRoot, true, "ccinfo");
	if (chkAbsentCCInfo != "") {
		chkAbsentCCInfo = chkAbsentCCInfo.split("@@@");
		absentType = chkAbsentCCInfo[0];
		absentMsg = chkAbsentCCInfo[1];
		absentCode = chkAbsentCCInfo[2].split(",");

		alert(absentMsg);
		
		if(absentType == "absent") {
	        $$(elmRoot).find("ccinfo").remove();
		} else {
			for(var i = 0; i < absentCode.length; i++) {
				if(absentCode[i] != "") {
					$$(elmRoot).find("ccinfo>ou>person[code='"+absentCode[i]+"']").parent().parent().remove();
   				}
			}
		}	
	}
	
    var returnObj = {"steps" : elmRoot.json()};
    return returnObj;
}

function getFormInfosJSON() {
    var forminfos = getProcessDescription();
    return forminfos;
}

function getProcessDescription() {
    var m_oFormInfos = {
    		"FormInstID" : (getInfo("ProcessInfo.ProcessDescription.FormInstID") == undefined ? "" : getInfo("ProcessInfo.ProcessDescription.FormInstID")),
    		"FormID" : getInfo("FormInfo.FormID"),
    		"FormName" : getInfo("FormInfo.FormName"), 
    		"FormSubject" :  ((document.getElementById("Subject") == undefined) ? getInfo("FormInstanceInfo.Subject") : document.getElementById("Subject").value),
    		"IsSecureDoc" : (document.getElementById("chk_secrecy").checked == true) ? "Y" : "N",
    		"IsFile" : "",
    		"FileExt" : "",
    		"IsComment" : "",					// 임의로 N
    		"ApproverCode" : (getInfo("ProcessInfo.ProcessDescription.ApproverCode") == undefined ? "" : getInfo("ProcessInfo.ProcessDescription.ApproverCode")),
    		"ApproverName" : (getInfo("ProcessInfo.ProcessDescription.ApproverName") == undefined ? "" : getInfo("ProcessInfo.ProcessDescription.ApproverName")),
    		"ApprovalStep" : (getInfo("ProcessInfo.ProcessDescription.ApprovalStep") == undefined ? "" : getInfo("ProcessInfo.ProcessDescription.ApprovalStep")),
    		"ApproverSIPAddress" : (getInfo("ProcessInfo.ProcessDescription.ApproverSIPAddress") == undefined ? "" : getInfo("ProcessInfo.ProcessDescription.ApproverSIPAddress")),
    		"IsReserved" : "N",
    		
    		// Reserved(Draft/Dist) info.
    		"IsDraftReserved" : $("#chk_reserved_draft").is(":checked") ? "Y" : "N",
    		"DraftReservedTime" : $("#chk_reserved_draft").is(":checked") ? $("#reservedDate").val().replace(/-/g, "").replace(/\./g, "") + $("#reservedHour").val() + $("#reservedMin").val() : "",
    		"IsDistReserved" : $("#chk_reserved_dist").is(":checked") ? "Y" : "N",
    		"DistReservedTime" : $("#chk_reserved_dist").is(":checked") ? $("#distReservedDate").val().replace(/-/g, "").replace(/\./g, "") + $("#distReservedHour").val() + $("#distReservedMin").val() : "",
    		"ReservedTimeZone" : Common.getSession("UR_TimeZone"),
    		
    		"Priority" : (document.getElementById("chk_urgent").checked == true) ? "5" : "3",
    		"IsModify" : (getInfo("ProcessInfo.ProcessDescription.IsModify") == undefined ? "N" : getInfo("ProcessInfo.ProcessDescription.IsModify"))
    	};
    
    //첨부파일 유무 확인
    var sIsFile = "N";
    if (document.getElementById("AttachFileInfo").value != "") {
        var oIsFile = $.parseJSON(document.getElementById("AttachFileInfo").value);
        sIsFile = (oIsFile.FileInfos != undefined && oIsFile.FileInfos.length > 0) ? "Y" : "N";													// 첨부파일 JSON 형태가 변함됨에 따라 변경
    }
    // 다안기안 첨부파일 유무 확인
    if(getInfo("Request.templatemode") == "Read"){
        $(formJson.BodyData.SubTable1).each(function(idx, item){
            if ((item.MULTI_ATTACH_FILE != null && item.MULTI_ATTACH_FILE != "") && sIsFile == "N") {
                var oIsFile = item.MULTI_ATTACH_FILE;
                sIsFile = (oIsFile.FileInfos != undefined && oIsFile.FileInfos.length > 0) ? "Y" : "N";													// 첨부파일 JSON 형태가 변함됨에 따라 변경
            }
        });
    } else {
        $('#SubTable1 .multi-row').find('[name=MULTI_ATTACH_FILE]').each(function(idx, item){
            if (($(item).val() != "" && $(item).val() != "undefined") && sIsFile == "N") {
                var oIsFile = $.parseJSON($(item).val());
                sIsFile = (oIsFile.FileInfos != undefined && oIsFile.FileInfos.length > 0) ? "Y" : "N";													// 첨부파일 JSON 형태가 변함됨에 따라 변경
            }
        });
    }
    m_oFormInfos.IsFile = sIsFile;
    
    //첨부파일 확장자
    m_oFormInfos.FileExt = "";		/*XFN_GetFileExt()*/					// 첨부파일(FormAttach.js) 소스 생성된 이후 수정

    //의견갯수
    var iCommentCount = "N";
    if (document.getElementById("APVLIST").value != "") {
        iCommentCount = $$($.parseJSON(document.getElementById("APVLIST").value)).find("step").concat().find("comment").length > 0 ? "Y" : "N";
        
        // 의견 첨부가 있는 경우
        var oCommentFile = $$($.parseJSON(document.getElementById("APVLIST").value)).find("step").concat().find("comment_fileinfo");
        if(oCommentFile.length > 0) {
        	m_oFormInfos.commentFileInfos = JSON.stringify($$(oCommentFile).json());
        }
    }
    m_oFormInfos.IsComment = iCommentCount;
    
    // 리스트에 항목 추가표시해야 하는 경우 커스털할 것
    m_oFormInfos.BusinessData1 = "APPROVAL";
    m_oFormInfos.BusinessData2 = ""; //수협(문서유통&다안기안&한글웹기안기) subTable의 rowSeq 자리로 사용
    m_oFormInfos.BusinessData3 = "";
    m_oFormInfos.BusinessData4 = "";
    m_oFormInfos.BusinessData5 = "";
    m_oFormInfos.BusinessData6 = "";
    m_oFormInfos.BusinessData7 = "";
    m_oFormInfos.BusinessData8 = "";
    m_oFormInfos.BusinessData9 = "";
    m_oFormInfos.BusinessData10 = "";
    
    if(formJson.BodyContext.LegacyFormID != undefined) {
    	//기타 다른 연동 시스템이 있을 경우 아래와 같이 구분값 지정하여 BusinessData1에 바인딩
    	if(formJson.BodyContext.LegacyFormID.indexOf("EACCOUNT") > -1) { //e-Accounting
    		m_oFormInfos.BusinessData1 = "ACCOUNT";
    		m_oFormInfos.BusinessData2 = formJson.BodyContext.ERPKey;
    		var amountSum = 0;
    		for(var i = 0; i < formJson.BodyContext.JSONBody.pageExpenceAppEvidList.length; i++) {
    			var obj = formJson.BodyContext.JSONBody.pageExpenceAppEvidList[i];
    			amountSum += obj.divSum;
    		}
    		m_oFormInfos.BusinessData3 = amountSum+"";
    		m_oFormInfos.BusinessData4 = formJson.BodyContext.JSONBody.pageExpenceAppEvidList[0].divList[0].UsageComment;
    	}
    }
    
    return m_oFormInfos;
}

function getFormInfoExtJSON() {
    var forminfoext = {};
    
    /* 각 양식으로 내려보낼것 forminfoext = m_oFormEditor.getFormInfoExtXML();*/
       
    $.extend(forminfoext, makeNode("scOPub", (getInfo("SchemaContext.scOPub.isUse") == 'Y' ? "True" : "False")));	/*대외공문*/
    $.extend(forminfoext, makeNode("scIPub", (getInfo("SchemaContext.scIPub.isUse") == "Y" ? "True" : "False")));
    
   /*특정 양식값 비사용 + makeNode("innerpost", (getInfo("FormInfo.FormPrefix") == 'WF_PUBLIC_BOARD' ? "True" : "False"));*/
    //각 부서함들 저장여부 설정
    $.extend(forminfoext, makeNode("scABox", getInfo("SchemaContext.scABox.isUse")));
    $.extend(forminfoext, makeNode("scSBox", getInfo("SchemaContext.scSBox.isUse")));
    $.extend(forminfoext, makeNode("scRPBox", getInfo("SchemaContext.scRPBox.isUse")));
    $.extend(forminfoext, makeNode("scJFBox", getInfo("SchemaContext.scJFBox.isUse")));
    $.extend(forminfoext, makeNode("scJFBoxV", getInfo("SchemaContext.scJFBox.value")));
    $.extend(forminfoext, makeNode("scAutoReview", getInfo("SchemaContext.scAutoReview.isUse")));
    
    /*합의함 저장(스키마) 비사용 + makeNode("scCBox", getInfo("scCBox"))*/ /* 합의처리함 저장(스키마) 비사용+ makeNode("scCPBox", getInfo("scCPBox"))*/ /*일상감사수신함 저장(스키마) 비사용 + makeNode("scGARBox", getInfo("scGARBox"))*/
    /*일상감사처리함 사용(스키마) 비사용 + makeNode("scGAPBox", getInfo("scGAPBox"))*/ /*재경감사처리함 저장(스키마) 비사용 + makeNode("scSAPBox", getInfo("scSAPBox"))*/ /*특별감사수신함 저장(스키마) 비사용 + makeNode("scSARBox", getInfo("scSARBox"))*/ /*특별감사처리함 저장(스키마) 비사용 + makeNode("scFAPBox", getInfo("scFAPBox"))*/
    
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
        catch (ex) { coviCmn.traceLog(e); }
    }
    
    $.extend(forminfoext, makeNode("IsUseDocNo", getInfo("SchemaContext.scDNum.isUse") == "Y" ? "True" : "False"));
    $.extend(forminfoext, makeNode("scEdmsLegacy", getInfo("SchemaContext.scEdmsLegacy.isUse") == "Y" ? "True" : "False"));
    $.extend(forminfoext, makeNode("scPubOpenDoc", getInfo("SchemaContext.scPubOpenDoc.isUse") == "Y" ? "True" : "False"));
    $.extend(forminfoext, makeNode("scRecordDocOpen", getInfo("SchemaContext.scRecordDocOpen.isUse") == "Y" ? "True" : "False"));
    
    //"수신공문품의서" 발신번호,발신처(기안자 입력) e
    /*특정양식값 makeNode("sealauthority", m_sReqMode == "SIGN" ? (getInfo("AppInfo.dpid_apv") + ';' + getInfo("AppInfo.dpdsn")) : '')*/
    /*문서이관> EDMS연동(스키마) 비사용 + makeNode("scEdms", getInfo("scEdms") == '1' ? "True" : "False")*/
    /*문서이관> EDMS연동(스키마) 비사용 + makeNode("scEdmsLegacy", getInfo("scEdmsLegacy") == '1' ? "True" : "False")*/ //2006.08추가 by sunny
    /* 문서종류 (스키마) 비사용 + makeNode("docclass", getInfo("scDocClassV"))*/
   
    var sdocinfo = {}; /*makeNode("outerpubdocno", m_sOPubDocNO)*/ //외부공문번호 넣어줄것
    
    $.extend(sdocinfo, makeNode("DocNo", (document.getElementById("DocNo") == undefined) ? '' : document.getElementById("DocNo").value));
    $.extend(sdocinfo, makeNode("ReceiveNo", (document.getElementById("ReceiveNo") == undefined) ? '' : getReceiveNo())); 
    $.extend(sdocinfo, makeNode("dpdsn", getInfo("AppInfo.dpdsn"))); 
    $.extend(sdocinfo, makeNode("DocClassID", (document.getElementById("DocClassID") == undefined) ? '' : document.getElementById("DocClassID").value));
    $.extend(sdocinfo, makeNode("DocClassName", (document.getElementById("DocClassName") == undefined) ? '' : document.getElementById("DocClassName").value));
    $.extend(sdocinfo, makeNode("SaveTerm", (document.getElementById("SaveTerm") == undefined) ? '' : document.getElementById("SaveTerm").value));
    $.extend(sdocinfo, makeNode("AppliedYear", (document.getElementById("AppliedDate") == undefined) ? '' : getFiscalYear(document.getElementById("AppliedDate").value)));
    $.extend(sdocinfo, makeNode("AppliedDate", (document.getElementById("AppliedDate") == undefined) ? '' : document.getElementById("AppliedDate").value));
    $.extend(sdocinfo, makeNode("DocLevel", (document.getElementById("DocLevel") == undefined) ? '' : document.getElementById("DocLevel").value));
    $.extend(sdocinfo, makeNode("IsPublic", (document.getElementById("IsPublic") == undefined) ? '' : ((document.getElementById("IsPublic").value == Common.getDic("lbl_apv_open")) ? 'Y' : 'N')));
    $.extend(sdocinfo, makeNode("deptcode", getInfo("AppInfo.dpid")));
    $.extend(sdocinfo, makeNode("deptpath", getInfo("AppInfo.grfullname")));
    
    $.extend(sdocinfo, makeNode("AttachFile", ""));
    /*+ "<attach>" + (m_sReqMode == "TEMPSAVE" ? "" : getFormInfoExtAttachXML()) + "</attach>"*/	//첨부파일path.		첨부파일(FormAttach.js) 소스 생성된 이후 수정
    
    /* + makeNode("circulation", (getInfo("SchemaContext.scOPub.isUse") == '1' ? '1' : '1'))*/
    /* 필드가 없음 + makeNode("sentunitname", (document.getElementById("SENT_OU_NAME") == undefined) ? '' : document.getElementById("SENT_OU_NAME").value)*/
    /* 필드가 없음 + makeNode("regcomment", (document.getElementById("REGISTRATION_COMMENT") == undefined) ? '' : document.getElementById("REGISTRATION_COMMENT").value);*/
    /* 사업장 코드 비사용 +makeNode("sel_entpart", (document.getElementById("SEL_ENTPART") == undefined) ? '' : document.getElementById("SEL_ENTPART").value);*/
    
    $.extend(forminfoext, {"DocInfo" : sdocinfo});

    $.extend(forminfoext, makeNode("JFID", getJFID()));			//담당자처리
    /* 비사용 (스키마 없음) + makeNode("IsChargeConfirm", (getInfo("scChgrConf") == '1' ? 'true' : 'false'))//담당자 확인 */
    $.extend(forminfoext, makeNode("ChargeOU", getChargeOU()));
    $.extend(forminfoext, makeNode("ChargePerson", getChargePerson()));
    $.extend(forminfoext, makeNode("rejectedto", (getInfo("SchemaContext.scRJTO.isUse") == "Y" ? 'true' : 'false')));
    
    /* 필드가 없음 $.extend(forminfoext, makeNode("WORKREQUEST_ID", (document.getElementById("WORKREQUEST_ID") == undefined) ? '' : document.getElementById("WORKREQUEST_ID").value));*/
    /* 레포트 생성(스키마) 비사용 + makeNode("MakeReport", (getInfo("scMRPT") == '1' ? getInfo("scMRPTV") : ''))*/
    /* 필드가 없음 + makeNode("parentfiid", (document.getElementById("REPLY_PARENT_FORM_INST_ID") == undefined) ? "" : document.getElementById("REPLY_PARENT_FORM_INST_ID").value)*/
    $.extend(forminfoext, makeNode("IsLegacy", (getInfo("SchemaContext.scLegacy.isUse") == "Y" ? getInfo("SchemaContext.scLegacy.value") : "")));
    
    $.extend(forminfoext, makeNode("entcode", (document.getElementById("EntCode") == undefined) ? getInfo("FormInstanceInfo.EntCode") : document.getElementById("EntCode").value));
    $.extend(forminfoext, makeNode("entname", (document.getElementById("EntName") == undefined) ? getInfo("FormInstanceInfo.EntName") : document.getElementById("EntName").value));
    $.extend(forminfoext, makeNode("docnotype", getInfo("SchemaContext.scDNum.value")));
    $.extend(forminfoext, makeNode("ConsultOK", (getInfo("SchemaContext.scConsultOK.isUse") == "Y" ? 'true' : 'false')));
    $.extend(forminfoext, makeNode("IsSubReturn", (getInfo("SchemaContext.scDCooReturn.isUse") == "Y" ? 'true' : 'false')));
    /* 모바일결재(스키마) 비사용+ makeNode("IsMobile", (getInfo("scMobile") == "1" ? 'true' : 'false'))*/
    $.extend(forminfoext, makeNode("IsDeputy", (gDeputyType == "T" ? 'true' : 'false')));
    /*자동결재선 (스키마) 비사용
     * + makeNode("scAutoCmm", getInfo("scAutoCmm"))
     * + makeNode("scAutoCmmV", getInfo("scAutoCmmV"))*/
    
    $.extend(forminfoext, makeNode("IsReUse", getInfo("Request.reuse")));
    $.extend(forminfoext, makeNode("scDocBoxRE", getInfo("SchemaContext.scDocBoxRE.isUse")));
    $.extend(forminfoext, makeNode("nCommitteeCount", "2"));
    
    /* 기록물철 비사용 + makeNode("RecDocFolderKind", $("#hidRecDocFolderKind").val())*/   //SAP양식여부(SAP양식:SAP , 일반양식:GW)
    /* 기록물철 비사용 + makeNode("RecDocFolderID", $("#hidRecDocFolderID").val())*/   //기록물철 분류폴더ID 
    
    $.extend(forminfoext, makeNode("IsReserved", "False"));		/* 예약 비사용 (document.getElementById("chk_reserved").checked == true) ? "True" : "False"));*/		//예약여부
    $.extend(forminfoext, makeNode("scASSBox", getInfo("SchemaContext.scASSBox.isUse")));			//개인합의 부서함저장
    $.extend(forminfoext, makeNode("scPreDocNum", getInfo("SchemaContext.scPreDocNum.isUse")));			//문서번호선발번
    $.extend(forminfoext, makeNode("scDistDocNum", getInfo("SchemaContext.scDistDocNum.isUse")));		//수신처 문서번호 발번
    $.extend(forminfoext, makeNode("scBatchPub", getInfo("SchemaContext.scBatchPub.isUse")));			//일괄배포 사용
    
    /*예약발송, 예약배포(스키마) 비사용
     * if (document.getElementById("chk_reserved").checked == true) {
        forminfoext += makeNode("ReservedGubun", document.getElementById("select_reserved").value) //예약발송,배포 구분
        + makeNode("ReservedTime", document.getElementById("ReservedTime").value + " " + document.getElementById("selThisHour").value + ":" + document.getElementById("selThisMin").value);  //예약일자,시간
    }*/
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
            		_return += $$(element).attr("AN") + "@" + $$(element).attr("DN");
            	});
            }
            
        }
    } else if (getInfo("SchemaContext.scChgrOUReg.isUse") == "Y") {
        if (getInfo("SchemaContext.scChgrOUReg.value") != "") {
        	var oChgrOURegV = $.parseJSON(getInfo("SchemaContext.scChgrOUReg.value"));
            if ($(oChgrOURegV).find("REG_" + getInfo("AppInfo.regionid") + " > items > item").length > 0) {
                $(oChgrOURegV).find("REG_" + getInfo("AppInfo.regionid") + " > items > item").each(function (i, element) {
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
			aExceptGroup.push(CFN_GetDicInfo(oInfo.GroupMultiName));
		});
		
		resultGroup = aResultGroup.join('^');
			
		//제외부서 alert
		if(aExceptGroup.length > 0) {
			var msg = Common.getDic("msg_apv_chkAbsentGroup") + '\n\n';
			msg += Common.getDic("msg_apv_absentGroup") + " : " + aExceptGroup.join(', ');
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
			url : "apvline/checkAbsentGroup.do",
			async : false,
			data : {
				"groups" : pGroups
			},
			success : function(data) {
				rtnGroups = data.list;
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("apvline/checkAbsentGroup.do", response, status, error);
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
        	
        	var oChargePerson = $.parseJSON(chargePersonValue.split("@@")[2]);

            if ($$(oChargePerson).find('item').length > 0) {
                $$(oChargePerson).find('item').each(function (i, element) {
                    if (i > 0) {
                        retChgrPerson += "^";
                    }

                    retChgrPerson += $$(element).attr('AN')
                        + '@' + $$(element).attr('DN')
                        + '@' + $$(element).attr('GR_Code')
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

// 엔진 호출 후 스크립트 처리 (구 receiveProcessHTTP, fnformmenuCallBack 함수 처리 등)
function callProcessEndScriptFunction(res, sReqMode) {
	// 오류 발생했을 경우에만 버튼 활성화되도록 위치 옮김
	// 의견 팝업이 2번 뜨는 현상 발생 방지
	//disableBtns(false);
	//ToggleLoadingImage();
	if (res.status == "SUCCESS") {
		if (CFN_GetQueryString("isMobile") == "Y" || _mobile) {
			alert(res.message);
			window.location.href = "list.do?mode=Approval";			//새로운 모바일 URL
			//window.location.href = "mobile/MobileApprovalList.do?mode=Approval";
		}else{
			Common.Inform(res.message, 'Information Dialog', function() { 
				//if (sReqMode != "DRAFT" && sReqMode != "TEMPSAVE") {
				if(getInfo("Request.mode") != "DRAFT"){
					if (CFN_GetQueryString("listpreview") == "Y") { // 결재함 새로고침
						var parentObj = parent.parent;
						parentObj.CoviMenu_GetContent(parentObj.location.href.replace(parentObj.location.origin, ""),false);
					} else if (CFN_GetQueryString("openMode") == "B") {
						opener.parent.parent.location.reload();
						Common.Close();
					} else if(opener != undefined && opener.setDocreadCount != undefined && opener.ListGrid != undefined && opener.location.href.toLowerCase().indexOf("home.do") == -1){
						var isEnd = false;
						if (opener.strPiid_List != '' && opener.strPiid_List != undefined) { // 일괄 확인 처리
							isEnd = true;
							if (!fnGoPreNextList('btNextList')) {
								isEnd = fnGoPreNextList('btPreList');
							}
							opener.strPiid_List = opener.strPiid_List.replace(getInfo("Request.processID") + ";", "");
							opener.strWiid_List = opener.strWiid_List.replace(getInfo("Request.workitemID") + ";", "");
							opener.strFiid_List = opener.strFiid_List.replace(getInfo("Request.forminstanceID") + ";", "");
							opener.strPtid_List = opener.strPtid_List.replace(getInfo("Request.userCode") + ";", "");
							
							opener.strBizData2_List = opener.strBizData2_List.replace(CFN_GetQueryString("ExpAppID") + ";", "");
							opener.strTaskID_List = opener.strTaskID_List.replace(CFN_GetQueryString("taskID") + ";", "");
						} 
						
						// 함별 카운트가 실시간으로 변경되면 해당 switch문 제거
						/*switch (formJson.Request.gloct) {
						case "APPROVAL":
						case "PREAPPROVAL":
						case "PROCESS":
						case "COMPLETE":
						case "REJECT":
						case "TEMPSAVE":
						case "TCINFO": // 개인결재함
							opener.setDocreadCount('USER');
							//opener.setSubMenu();
							break;
						case "DEPART": // 부서함
							opener.setDocreadCount('DEPT');
							//opener.setSubMenu();
							break;
						case "JOBFUNCTION": // 담당업무함
							opener.setDocreadCount();
						}*/
						
						opener.setDocreadCount();
						
						opener.ListGrid.reloadList(); //Grid만 reload되도록 변경
						
						if(opener.ListGrid.page.pageSize * (opener.ListGrid.page.pageNo-1) == (opener.ListGrid.page.listCount-1) ){
							opener.$("input[id=AXPaging][value="+(opener.ListGrid.page.pageNo-1)+"]").click();
						}
						
						if (!isEnd) {
							Common.Close();
						}
					}else{
						if(opener.setDocreadCount != undefined) {
							opener.setDocreadCount();
						}
						if(opener.location.href.toLowerCase().indexOf("home.do") == -1){
							if(opener.apvRefreshPortal != undefined) opener.apvRefreshPortal();
							else opener.location.reload();
						}else{
							opener.CoviMenu_GetContent(opener.location.href.replace(opener.location.origin, ""),false);		//opener.location.reload();
						}
						Common.Close();
					}
				} else if(sReqMode == "DOCLISTSAVE") { // 문서유통: 오프라인 저장 시 새로고침
					if(opener.setDocreadCount != undefined) {
						opener.setDocreadCount();
					}
					opener.CoviMenu_GetContent(opener.location.href.replace(opener.location.origin, ""),false);		//opener.location.reload();
					Common.Close();
				} else{
					try {
						if(sReqMode == "DRAFT") {
							opener.setDocreadCount('USER');
							if(getInfo("Request.isgovDocReply") == "Y"){ opener.close(); }
						}
						
						// 사업관리 시스템, 기안 이후 버튼 새로 그리기
						if(opener.location.href.indexOf("bizmnt") > -1 && typeof opener.callSelectDetailAjax == "function") {
							opener.callSelectDetailAjax();
						}
					} catch(e) { coviCmn.traceLog(e); }
					
					if(CFN_GetQueryString("CFN_OpenWindowName") != "undefined")
						Common.Close();
					else
						window.close();
				}
			}); // 완료되었습니다.
		}
	}else {
		//FAIL
		disableBtns(false);
		if(res.message.indexOf("NOTASK")>-1){
			res.message = Common.getDic("msg_apv_notask");
		}
		// 엔진쪽에서 Transaction lock (일시적) 인경우, 병렬합의자 동시 액션등.
		if(/VariableInstanceEntity(.)+ was updated by another transaction concurrently/g.test(res.message)){
			res.message = Common.getDic("msg_apv_tasklocked");
		}
		
		if(getInfo("Request.mode") != "DRAFT"){
			if (CFN_GetQueryString("openMode") == "B") { // 결재함 새로고침
				opener.parent.parent.location.reload();
			} else if(opener != undefined && opener.setDocreadCount != undefined && opener.ListGrid != undefined && opener.location.href.toLowerCase().indexOf("home.do") == -1){
				opener.setDocreadCount();
				
				opener.ListGrid.reloadList(); //Grid만 reload되도록 변경
				
				if(opener.ListGrid.page.pageSize * (opener.ListGrid.page.pageNo-1) == (opener.ListGrid.page.listCount-1) ){
					opener.$("input[id=AXPaging][value="+(opener.ListGrid.page.pageNo-1)+"]").click();
				}
			}
		}
		
		if (CFN_GetQueryString("isMobile") == "Y" || _mobile) {
			alert(res.message);
		}else{
			Common.Error(res.message, null, function(){
				if(getInfo("Request.mode") != "DRAFT" && getInfo("Request.mode") != "TEMPSAVE"){
					if (CFN_GetQueryString("listpreview") == "Y") {
						var parentObj = parent.parent;
						parentObj.CoviMenu_GetContent(parentObj.location.href.replace(parentObj.location.origin, ""),false);
					}
					location.href = location.href.replace("#", "").replace("&editMode=", "").replace("&editMode=Y", "") + "&editMode=N";
				}
			}); //오류가 발생했습니다.
		}
	}
}


/*
    event_noop()
    moved to form.refactor.deleted.js
    by KJW : 2014.04.22 : XFORM PRJ.
*/

// 문서유통+다안기안 한글 에디터 저장
let bCompleteSaveWebHWPMultiContext = false;
function saveWebHWPMultiContext(idx, sReqMode, callBackFunc) {
	HwpCtrl = document.getElementById('tbContentElement' + idx);
    if(HwpCtrl == null && webHwpYN == "Y") {
    	HwpCtrl = document.getElementById('tbContentElement' + idx + 'Frame').contentWindow.HwpCtrl;
    }
    if(HwpCtrl != null) {
		// 안 넘버를 MULTI_ROWSEQ 컬럼에 대입
	    if (document.getElementsByName('MULTI_ROWSEQ')[idx]) {
			document.getElementsByName('MULTI_ROWSEQ')[idx].value = idx;
		}
		
		// 에디터에 있는 제목을 MULTI_TITLE 컬럼에 대입
	    if (document.getElementsByName('MULTI_TITLE')[idx]) {
			document.getElementsByName('MULTI_TITLE')[idx].value = HwpCtrl.GetFieldText("doctitle");
		}
		
		// 공개/비공개 에디터에 표시
		const savedVal = $('input:radio[name="RELEASE_CHECK"]:checked').val();
        if (savedVal != undefined) {
			if (savedVal == "1") {
				HwpCtrl.PutFieldText("publication", Common.getDic("lbl_apv_open")); // 공개
			} else {
				HwpCtrl.PutFieldText("publication", Common.getDic("lbl_Private")); // 비공개
			}
		}
		
        HwpCtrl.MoveToField("body", true, true, true);
    	HwpCtrl.GetTextFile("HTML", "saveblock", function(body) {
			var strBODY = Base64.utf8_to_b64(body);
			document.getElementsByName("MULTI_BODY")[idx].value = strBODY;
			
			// 전체 선택을 해제
			HwpCtrl.Run("Cancel");
    		
		    HwpCtrl.GetTextFile("HWPML2X", "", function(data) {	
				var strHWP = Base64.utf8_to_b64(data);
				document.getElementsByName("MULTI_BODY_CONTEXT_HWP")[idx].value = strHWP;
				
				if (document.querySelectorAll('[id*=tbContentElement]').length == idx) {
					bCompleteSaveWebHWPMultiContext = true;
				}
				
				if (bCompleteSaveWebHWPMultiContext) {
					bCompleteSaveWebHWPMultiContext = false;
					callBackFunc(sReqMode);
				} else {
					saveWebHWPMultiContext(++idx, sReqMode, callBackFunc);
				}
			});
		});
	}
}

//다안기안 현재 열려있는 Tab 데이터 저장,ysyi
function saveCurWebHWPMultiContext(sReqMode) {
	let curIdx = $("#writeTab li.on").attr("idx");
	const firstIdx =1;
	
	HwpCtrl = document.getElementById('tbContentElement' + firstIdx);
    if(HwpCtrl == null && webHwpYN == "Y") {
    	HwpCtrl = document.getElementById('tbContentElement' + firstIdx + 'Frame').contentWindow.HwpCtrl;
    }
    if(HwpCtrl != null) {
		// 안 넘버를 MULTI_ROWSEQ 컬럼에 대입
	    if (document.getElementsByName('MULTI_ROWSEQ')[curIdx]) {
			document.getElementsByName('MULTI_ROWSEQ')[curIdx].value = curIdx;
		}
		
		// 에디터에 있는 제목을 MULTI_TITLE 컬럼에 대입
	    if (document.getElementsByName('MULTI_TITLE')[curIdx]) {
			document.getElementsByName('MULTI_TITLE')[curIdx].value = HwpCtrl.GetFieldText("doctitle");
		}
		
		// 공개/비공개 에디터에 표시
		const savedVal = $('input:radio[name="RELEASE_CHECK"]:checked').val();
        if (savedVal != undefined) {
			if (savedVal == "1") {
				HwpCtrl.PutFieldText("publication", Common.getDic("lbl_apv_open")); // 공개
			} else {
				HwpCtrl.PutFieldText("publication", Common.getDic("lbl_Private")); // 비공개
			}
		}
        
        HwpCtrl.MoveToField("body", true, true, true);
    	HwpCtrl.GetTextFile("HTML", "saveblock", function(body) {
			var strBODY = Base64.utf8_to_b64(body);
			document.getElementsByName("MULTI_BODY")[curIdx].value = strBODY;
			
			// 전체 선택을 해제
			HwpCtrl.Run("Cancel");
			
		    HwpCtrl.GetTextFile("HWPML2X", "", function(data) {	
				var strHWP = Base64.utf8_to_b64(data);
				document.getElementsByName("MULTI_BODY_CONTEXT_HWP")[curIdx].value = strHWP;		
				
				requestProcessDetail(sReqMode);
			});
		});
	}else{
		// 안 넘버를 MULTI_ROWSEQ 컬럼에 대입
	    if (document.getElementsByName('MULTI_ROWSEQ')[curIdx]) {
			document.getElementsByName('MULTI_ROWSEQ')[curIdx].value = curIdx;
		}
		
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
}


//다안기안 탭선택시 안별 데이터 저장
function saveCurMultiContext(idx) {
	
	if (isUseHWPEditor()){
		HwpCtrl = document.getElementById('tbContentElement' + m_firstIDx);
		
	    if(HwpCtrl == null && typeof webHwpYN != 'undefined') {
	    	if (webHwpYN == "Y") HwpCtrl = document.getElementById('tbContentElement' + m_firstIDx + 'Frame').contentWindow.HwpCtrl;
	    }
		
	    if(HwpCtrl != null) {
			// 안 넘버를 MULTI_ROWSEQ 컬럼에 대입
		    if (document.getElementsByName('MULTI_ROWSEQ')[idx]) {
				document.getElementsByName('MULTI_ROWSEQ')[idx].value = idx;
			}
			
			// 에디터에 있는 제목을 MULTI_TITLE 컬럼에 대입
		    if (document.getElementsByName('MULTI_TITLE')[idx]) {
				document.getElementsByName('MULTI_TITLE')[idx].value = HwpCtrl.GetFieldText("doctitle");
			}
			
			// 공개/비공개 에디터에 표시
			const savedVal = $('input:radio[name="RELEASE_CHECK"]:checked').val();
	        if (savedVal != undefined) {
				if (savedVal == "1") {
					HwpCtrl.PutFieldText("publication", Common.getDic("lbl_apv_open")); // 공개
				} else {
					HwpCtrl.PutFieldText("publication", Common.getDic("lbl_Private")); // 비공개
				}
			}
		}
	}else{
		if (document.getElementsByName('MULTI_ROWSEQ')[idx]) {
			document.getElementsByName('MULTI_ROWSEQ')[idx].value = idx;
		}
	}
}

var _AutoCmm = false;
function requestProcess(sReqMode) {
    m_sReqMode = sReqMode;
    /*
    // 양식프로세스 > 결재유형옵션 > 문서유통 == Y
    if (getInfo("SchemaContext.scDistribution.isUse") == "Y") {
    	// 문서유통 + 한글웹기안기
    	if(getInfo("ExtInfo.UseWebHWPEditYN") == "Y"){
			// 다안기안
			if (isGovMulti()) {
				getInfo("Request.templatemode") == "Write" ? saveWebHWPMultiContext(1, sReqMode, requestProcessDetail) : requestProcessDetail(sReqMode);
			} else {
				HwpCtrl.GetTextFile("HWPML2X", "", function(data) {	
					var strHWP = Base64.utf8_to_b64(data);
					document.getElementById("BODY_CONTEXT_HWP").value = strHWP;
					requestProcessDetail(sReqMode);
				});
			}
		// 문서유통 + 웹에디터
    	}else if(getInfo("ExtInfo.UseWebHWPEditYN") == "Y"){
    		// 다안기안
    		// 체크필요 : 다안기안
			if (isGovMulti()) {
				getInfo("Request.templatemode") == "Write" ? saveWebHWPMultiContext(1, sReqMode, requestProcessDetail) : requestProcessDetail(sReqMode);
			} else {
				//HwpCtrl.GetTextFile("HWPML2X", "", function(data) {	
				//	var strHWP = Base64.utf8_to_b64(data);
				//	document.getElementById("BODY_CONTEXT_HWP").value = strHWP;
					requestProcessDetail(sReqMode);
				//});
			}
    	}else{
			requestProcessDetail(sReqMode);
    	}
	// 웹한글기안기만 사용
    } else if(getInfo("ExtInfo.UseWebHWPEditYN") == "Y") {
		HwpCtrl.GetTextFile("HWPML2X", "", function(data) {	
			var strHWP = Base64.utf8_to_b64(data);
			document.getElementById("BODY_CONTEXT_HWP").value = strHWP;
			requestProcessDetail(sReqMode);
		});
	} else {
    	requestProcessDetail(sReqMode);
    }*/

    
    // 승인자 내용변경 저장 - 승인/재기안 시 중복저장 체크
    if ((sReqMode == "APPROVE" || sReqMode == "RECREATE" || sReqMode == "REDRAFT") && getInfo("Request.editmode") == "Y"
    		&& getInfo("SchemaContext.scCHBSaveBtn.isUse") == "Y" && (getInfo("SchemaContext.scCHBis.isUse") == "Y" || getInfo("SchemaContext.scRCHBis.isUse") == "Y")) {
		if(chkBeforeEdited()) {
			Common.Inform(Common.getDic("msg_apv_chkBeforeEdited")); //이전에 문서가 수정되어 저장할 수 없습니다. 문서를 다시 열어주세요.
			return;
		}
    }
    
    // 양식프로세스 > 결재유형옵션 > 문서유통 == Y && 양식 > 양식본문정보 > 한글웹기안기 == Y
    if (getInfo("ExtInfo.UseWebHWPEditYN") == "Y" && getInfo("SchemaContext.scDistribution.isUse") == "Y") {
		// 다안기안인 경우
		if (isGovMulti()) {
			if (getInfo("Request.templatemode") == "Write") {
				//saveWebHWPMultiContext(1, sReqMode, requestProcessDetail);
				saveCurWebHWPMultiContext(sReqMode);
			} else {
				requestProcessDetail(sReqMode);
			}
		} else {
			HwpCtrl.MoveToField("body", true, true, true);
	    	HwpCtrl.GetTextFile("HTML", "saveblock", function(body) {
				var strBODY = Base64.utf8_to_b64(body);
				document.getElementById("BODY").value = strBODY;
				
				// 전체 선택을 해제
				HwpCtrl.Run("Cancel");

				HwpCtrl.GetTextFile("HWPML2X", "", function(data) {	
					var strHWP = Base64.utf8_to_b64(data);
					document.getElementById("BODY_CONTEXT_HWP").value = strHWP;
					requestProcessDetail(sReqMode);
				});
			});
		}
    } else if(getInfo("ExtInfo.UseWebHWPEditYN") == "Y") {
		HwpCtrl.MoveToField("body", true, true, true);
    	HwpCtrl.GetTextFile("HTML", "saveblock", function(body) {
			var strBODY = Base64.utf8_to_b64(body);
			document.getElementById("BODY").value = strBODY;
			
			// 전체 선택을 해제
			HwpCtrl.Run("Cancel");

			HwpCtrl.GetTextFile("HWPML2X", "", function(data) {	
				var strHWP = Base64.utf8_to_b64(data);
				document.getElementById("BODY_CONTEXT_HWP").value = strHWP;
				requestProcessDetail(sReqMode);
			});
		});
	} else {
    	requestProcessDetail(sReqMode);
    }
}
function requestProcessReserve(){
	//ToggleLoadingImage();
	var sAddage = {};
	
	sAddage = $.extend(sAddage, makeNode("actionMode", document.getElementById("ACTIONINDEX").value));
	sAddage = $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
	sAddage = $.extend(sAddage, makeNode("actionUser", getInfo("Request.userCode"))); // 담당업무함 처리하기 위해 추가함.

    //FIDO 파라미터 추가 2021-01-18 dgkim
    $.extend(sAddage, makeNode("g_authKey"	,  	typeof _g_authKey  	=== "undefined" ? "" 	: _g_authKey  ));
    $.extend(sAddage, makeNode("g_authToken",  	typeof _g_authToken === "undefined" ? "" 	: _g_authToken ));
    $.extend(sAddage, makeNode("g_password",  	typeof _g_password  === "undefined" ? ""	: _g_password ));
    _g_authKey = "";
    _g_authToken = "";
    _g_password = "";
    $.extend(sAddage, makeNode("formID", getInfo("FormInfo.FormID")));
    $.extend(sAddage, makeNode("formDraftkey", formDraftkey));
    
	var defaultJSON;
    var sJsonData;
    
    defaultJSON = getDefaultJSON();
    
    sJsonData= $.extend(defaultJSON, sAddage);
    
    if(getInfo("Request.editmode") == "Y") {
		setFormAttachFileInfo();
		$.extend(sJsonData, getChangeFormJSON());
    }
    
    var formData = new FormData();
    // 양식 기안 및 승인 정보
    formData.append("formObj", Base64.utf8_to_b64(JSON.stringify(sJsonData)));

    
    // 파일정보
    for (var i = 0; i < l_aObjFileList.length; i++) {
        if (typeof l_aObjFileList[i] == 'object') {
            formData.append("fileData[]", l_aObjFileList[i]);
        }
    }
    
    // 다안기안 멀티 첨부
    if(getInfo("ExtInfo.UseMultiEditYN") == "Y") {
        // 파일정보
        for (var i = 0; i < l_aObjFileListMultiArr.length; i++) {
        	if(l_aObjFileListMultiArr[i] != null){
                for (var j = 0; j < l_aObjFileListMultiArr[i].length; j++) {
                    if (typeof l_aObjFileListMultiArr[i][j] == 'object') {
                    	formData.append("MultifileData_" + (i+1), l_aObjFileListMultiArr[i][j]);
                    }
                }
        	}
        }
    }
    
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
    			//ToggleLoadingImage();
				CFN_ErrorAjax("reserve.do", response, status, error);
			}
    	});
    } catch (e) {
    	//ToggleLoadingImage();
        Common.Error(e.message);
    }
}

function requestProcessDetail(sReqMode) {
    try {
        disableBtns(true);
        //ToggleLoadingImage();
        var sTargetURL = "draft.do";
        var sMsgTitle;
        var sAddage = {};
        var aReqForm = getInfo("FormInfo.FormPrefix").split("_");
        m_bFileSave = true;
        

        // XForm 저장연동              
        var writelink_count = 0;        // XForm 저장연동 여부
        var extdatatype = "";
        var boolerror = false;
                

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

        //FIDO 파라미터 추가 2021-01-18 dgkim
        $.extend(sAddage, makeNode("g_authKey"	,  	typeof _g_authKey  	=== "undefined" ? "" 	: _g_authKey  ));
        $.extend(sAddage, makeNode("g_authToken",  	typeof _g_authToken === "undefined" ? "" 	: _g_authToken ));
        $.extend(sAddage, makeNode("g_password",  	typeof _g_password  === "undefined" ? ""	: _g_password ));
        _g_authKey = ""; 
        _g_authToken = "";
        _g_password = "";
        $.extend(sAddage, makeNode("formID", getInfo("FormInfo.FormID")));
        $.extend(sAddage, makeNode("formDraftkey", formDraftkey));
        
        switch (sReqMode) {
            case "DRAFT": //"기안"
                sMsgTitle = Common.getDic("lbl_apv_charge_apvline");

                //XFN_FileSave();				첨부파일(FormAttach.js) 소스 생성된 이후 수정

                $.extend(sAddage, makeNode("Priority", (document.getElementById("chk_urgent").checked == true) ? "5" : "3"));
                $.extend(sAddage, makeNode("actionMode", document.getElementById("ACTIONINDEX").value));
                $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
                $.extend(sAddage, makeNode("actionComment_Attach", document.getElementById("ACTIONCOMMENT_ATTACH").value));
                $.extend(sAddage, makeNode("signimagetype", document.getElementById("SIGNIMAGETYPE").value));
                
                $.extend(sAddage, getFormJSON());
                
                m_bFrmExtDirty = true;

                break;
            case "CHANGEAPV": //"결재선변경" - 미구현
                sMsgTitle = gLabel__changeapprover;

                m_bFileSave = true;
                sTargetURL = "ReassignApvList.aspx";
                sAddage = getChangeFormXML() + makeNode("PIID", getInfo("ProcessInfo.ProcessID")) + makeNode("admintype", admintype);

                m_bFrmExtDirty = true;
                break;
            case "BYPASS": //"결재선변경" - 미구현
                sMsgTitle = gLabel__changeapprover;

                m_bFileSave = true;
                sTargetURL = "ReassignApvList.aspx";
                sAddage = makeNode("PIID", getInfo("ProcessInfo.ProcessID")) + makeNode("wfid", m_wfid) + makeNode("name", "", null, true);

                m_bFrmExtDirty = true;
                break;
            case "FORWARD":		// 전달
            case "CHARGE": //"담당자 지정"
                sMsgTitle = Common.getDic("lbl_apv_Charger");	
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
                $.extend(sAddage, makeNode("actionComment_Attach", document.getElementById("ACTIONCOMMENT_ATTACH").value));
                $.extend(sAddage, makeNode("CHARGEID", document.getElementById("CHARGEID").value));
                $.extend(sAddage, makeNode("CHARGENAME", document.getElementById("CHARGENAME").value));
                $.extend(sAddage, makeNode("CHARGEOUID", document.getElementById("CHARGEOUID").value));
                
                if((getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT") && document.getElementById("ACTIONINDEX").value == "CHARGE"){
                	$.extend(sAddage, getChangeFormJSON());
                }
                
                // 전달의 경우 performer 및 결재선 정보를 update하며, 이력은 결재선을 통해 확인할 수 있음.
                if(document.getElementById("ACTIONINDEX").value == "FORWARD"){
                	$.extend(sAddage, makeNode("WorkitemID", getInfo('Request.workitemID')));

                	// 편집후 전달시 첨부파일,본문등 변경사항 저장
                    if(getInfo("Request.editmode") == "Y") {
                		setFormAttachFileInfo();
                		$.extend(sAddage, getChangeFormJSON());
                    }
                    
                	sTargetURL = "forward.do";
                }
                
                m_bFrmExtDirty = true;
                break;
            case "RECREATE": //"재기안"
                sMsgTitle = Common.getDic("lbl_apv_redraft");	
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

                //XFN_FileSave();

                if (document.getElementById("SIGNIMAGETYPE").value == "") {
                    document.getElementById("SIGNIMAGETYPE").value = getInfo("AppInfo.usit");
                }

                $.extend(sAddage, makeNode("Priority", (document.getElementById("chk_urgent").checked == true) ? "5" : "3"));
                $.extend(sAddage, makeNode("dpid", getInfo("AppInfo.dpid")));
                $.extend(sAddage, makeNode("dpid_apv", getInfo("AppInfo.dpid")));
                $.extend(sAddage, makeNode("dpdsn", getInfo("AppInfo.dpdsn")));
                $.extend(sAddage, makeNode("actionMode", document.getElementById("ACTIONINDEX").value));
                $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
                $.extend(sAddage, makeNode("actionComment_Attach", document.getElementById("ACTIONCOMMENT_ATTACH").value));
                $.extend(sAddage, makeNode("signimagetype", document.getElementById("SIGNIMAGETYPE").value));
                /*비사용 $.extend(sAddage, makeNode("isissuedocno", getIsIssueDocNo()));*/
                $.extend(sAddage, makeNode("doclisttype", szdoclisttype));
                $.extend(sAddage, /*((getInfo("REQ_RESPONSE") == "Y") ? getFormJSON() : */ getChangeFormJSON()/*)*/);
                $.extend(sAddage, makeNode("islast", getIsLast())); 

                m_bFrmExtDirty = true;
                if (getInfo("REQ_RESPONSE") == "Y") m_bFrmInfoDirty = true;
                break;
            case "APPROVE": //"결재"
                sMsgTitle = Common.getDic("btn_apv_approval2");

                //XFN_FileSave();				첨부파일(FormAttach.js) 소스 생성된 이후 수정
                
                //$.extend(sAddage, makeNode("Priority", (document.getElementById("chk_urgent").checked == true) ? "5" : "3"));
                $.extend(sAddage, makeNode("usem", getInfo("AppInfo.usem")));				// 이메일
                $.extend(sAddage, makeNode("dpid", getInfo("AppInfo.dpid")));
                $.extend(sAddage, makeNode("dpid_apv", getInfo("AppInfo.dpid_apv")));
                $.extend(sAddage, makeNode("dpdsn",  getInfo("AppInfo.dpdsn")));
                $.extend(sAddage, makeNode("usid", getInfo("AppInfo.usid")));
                $.extend(sAddage, makeNode("usdn", getInfo("AppInfo.usnm")));
                $.extend(sAddage, makeNode("deputy", (m_bDeputy) ? "true" : "false"));
                $.extend(sAddage, makeNode("actionMode", document.getElementById("ACTIONINDEX").value));
                $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
                $.extend(sAddage, makeNode("actionComment_Attach", document.getElementById("ACTIONCOMMENT_ATTACH").value));
                $.extend(sAddage, makeNode("signimagetype", document.getElementById("SIGNIMAGETYPE").value));
                /*비사용 $.extend(sAddage, makeNode("isissuedocno", getIsIssueDocNo()));*/
                $.extend(sAddage, makeNode("doclisttype", "1"));
                //if(CFN_GetQueryString("isMobile") != "Y"){
                	$.extend(sAddage, getChangeFormJSON());
                	$.extend(sAddage, makeNode("islast", getIsLast()));
                //}
                
                if (getInfo("Request.mode") == 'APPROVAL' || getInfo("Request.mode") == 'RECAPPROVAL' /*비사용 || getIsIssueDocNo() == "true"*/) m_bFrmExtDirty = true; //결재,수신결재일경우만넘김																				

                m_bFrmExtDirty = true;
                m_bFrmInfoDirty = true;
                //
                
                /*자동결재(스키마) 비사용
                m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
                var elmRoot = $$(m_evalJSON).find("steps");
                var oRecSteps = $$(elmRoot).find("division:has(taskinfo[status='pending'])[divisiontype='receive'] > step > ou > person > taskinfo[kind!='review'][kind!='bypass'][kind!='skip' ]"); // ) or (@routetype!='review' and  @unittype='ou' and taskinfo/@status='inactive')) or @status='inactive' ]
                var oinaciveRecSteps = $$(elmRoot).find("division:has(taskinfo[status='pending'])[divisiontype='receive'] > step[routetype!='review'][unittype='person'] > ou > person > taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][status='inactive'], division:has(taskinfo[status='pending'])[divisiontype='receive'] > step[routetype!='review'][unittype='ou'] > ou:has(taskinfo[status='inactive']) > person > taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][status='inactive']");
                
                 * if (getInfo("scAutoCmm") == "1" && oRecSteps.length == getInfo("scAutoCmmV") && oinaciveRecSteps.length == 1) {
                    Common.Confirm(gMessage324, "Confirmation Dialog", function (result) {
                        if (result) {
                        } else {
                            _AutoCmm = true;
                        }
                    });
                }*/
                break;
            case "TEMPSAVE": //"임시함"					
            	
            	//XFN_FileSave();

                sMsgTitle = Common.getDic("lbl_apv_composing");
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
                sMsgTitle = Common.getDic("lbl_apv_Doc_back");
                
                $.extend(sAddage, makeNode("usid", getInfo("AppInfo.usid")));
                $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
                $.extend(sAddage, makeNode("actionComment_Attach", document.getElementById("ACTIONCOMMENT_ATTACH").value));
                $.extend(sAddage, makeNode("actionMode", "WITHDRAW"));
                $.extend(sAddage, getInfoBodyContext());
                break;
            case "ABORT": //"결재문서 취소"
                sMsgTitle = Common.getDic("lbl_apv_Doc_cancel");
                
                $.extend(sAddage, makeNode("usid", getInfo("AppInfo.usid")));
                $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
                $.extend(sAddage, makeNode("actionComment_Attach", document.getElementById("ACTIONCOMMENT_ATTACH").value));
                $.extend(sAddage, makeNode("actionMode", "ABORT"));
                $.extend(sAddage, getInfoBodyContext());
                break;
            case "APPROVECANCEL": //"승인 취소"
                sMsgTitle = Common.getDic("lbl_apv_Approve_cancel");
                
                $.extend(sAddage, makeNode("usid", getInfo("AppInfo.usid")));
                $.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
                $.extend(sAddage, makeNode("actionComment_Attach", document.getElementById("ACTIONCOMMENT_ATTACH").value));
                $.extend(sAddage, makeNode("actionMode", "APPROVECANCEL"));
                //$.extend(sAddage, getInfoBodyContext());
                break;
            case "MONITOR": //"결재문서 확인" - 미구현
                sMsgTitle = gLabel__Doc_OK;
                sTargetURL = "../InstMgr/switchMonitorOK.aspx";
                break;
            case "DELETEDOC":   //결재문서삭제 - 미구현
                sMsgTitle = "결재문서 삭제";
                m_bFileSave = true; sTargetURL = "../InstMgr/switchFT2Del.aspx";
                if (getInfo("Request.mode") == "TEMPSAVE") {//회수문서 삭제
                    sAddage = makeNode("item", getInfo("Request.formtempID"))
                    + makeNode("fitn", getInfo("Request.forminstancetablename"))
                    /*기간연동(스키마) 비사용 + makeNode("IsLegacy", (getInfo("scLegacy") == "1" ? getInfo("scLegacyV") : 'false'))*/
                    + makeNode("deltype", "WITHDRAW")
                    + getInfoBodyContext();
                } else if (getInfo("Request.mode") == "COMPLETE" && getInfo("Request.loct") == "REJECT") {
                    sAddage = makeNode("item", getInfo("ProcessInfo.ProcessID"))
                    /* 기간연동(스키마) 비사용 + makeNode("IsLegacy", (getInfo("scLegacy") == "1" ? getInfo("scLegacyV") : 'false'))*/
                    + makeNode("deltype", "REJECT")
                    + getInfoBodyContext();
                }
                else {
                    sAddage = makeNode("usid")
                    + makeNode("DOC_NO", (document.getElementById("DOC_NO") == undefined) ? "" : document.getElementById("DOC_NO").value)
                    /*비사용 (스키마 없음) + makeNode("OfficialDocNo", getInfo("scOfficialDocNo"))*/;
                }
                break;
            case "FORCEDCONSENT": //강제합의-미구현
                sMsgTitle = "결재문서 삭제";
                m_bFileSave = true; sTargetURL = "../InstMgr/ForcedConsent.aspx";
                sAddage = makeNode("usid");
                 sAddage = makeNode("PARENT_PROCESS_ID", getInfo("ProcessInfo.ParentProcessID"));
                break;
            case "CHANGEREVIEW": //현결재자 변경 후 후결 셋팅 -미구현
                m_sReqMode = "CHANGEREVIEW"
                sMsgTitle = "";
                sAddage = makeNode("ChangeReviewXml", document.getElementById("CHANGEREVIEWXML").value, null, false);
                sAddage += makeNode("ChangeReview", m_bTempFlag, null, false);
                sTargetURL = "../InstMgr/switchWI2ReassignNReview.aspx";
                break;
            case "DOCLISTSAVE": //문서대장 등록
            	$.extend(sAddage, makeNode("actionMode", document.getElementById("ACTIONINDEX").value));
            	
            	$.extend(sAddage, getFormJSON());
            	$.extend(sAddage, getDocListJSON());
            	
            	sTargetURL = "offlineSave.do";
                break;
            default:
                alert("[" + sReqMode + "]" + Common.getDic("msg_apv_072")); //는 지정되지 않은 모드입니다.
                return;
        }
        try {
            if (m_bFileSave == true) {
                if (getInfo("Request.mode") == "PREDRAFT") { setInfo("Request.mode", "DRAFT"); }

                var defaultJSON;
                var sJsonData;
                
                defaultJSON = getDefaultJSON(sReqMode);
                sJsonData= $.extend(defaultJSON, sAddage);
                /*비사용
                 * if (_AutoCmm) {
                    defaultJSON.FormInfoExt.scAutoCmm = 0;
                }*/
                
                var formData = new FormData();
                // 양식 기안 및 승인 정보
                formData.append("formObj", Base64.utf8_to_b64(JSON.stringify(sJsonData)));
                
                // 파일정보
                for (var i = 0; i < l_aObjFileList.length; i++) {
                    if (typeof l_aObjFileList[i] == 'object') {
                        formData.append("fileData[]", l_aObjFileList[i]);
                    }
                }
                
                // 다안기안 멀티 첨부
                if(getInfo("ExtInfo.UseMultiEditYN") == "Y") {
                    // 파일정보
                    for (var i = 0; i < l_aObjFileListMultiArr.length; i++) {
                    	if(l_aObjFileListMultiArr[i] != null){
                            for (var j = 0; j < l_aObjFileListMultiArr[i].length; j++) {
                                if (typeof l_aObjFileListMultiArr[i][j] == 'object') {
                                	formData.append("MultifileData_" + (i+1), l_aObjFileListMultiArr[i][j]);
                                }
                            }
                    	}
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
                			disableBtns(false);
                			//ToggleLoadingImage();
            				CFN_ErrorAjax(sTargetURL, response, status, error);
            			}	
                	});
                } catch (e) {
                	disableBtns(false);
                    Common.Error(e.message);
                }
            } else {
                disableBtns(false);
                Common.Error(Common.getDic("msg_apv_203")); //"첨부파일이 정상적으로 처리되지 않았습니다."
            }
        } catch (e) {
            disableBtns(false);
            Common.Error(Common.getDic("msg_apv_073") + "\nDesc:" + e.message + "\nError number: " + e.stack); //"저장하지 못했습니다."
            //ToggleLoadingImage()
        }
    } catch (e) {
    	Common.Error("Desc:" + e.message + "\nError number: " + e.stack);
    	//ToggleLoadingImage();
    }
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

            if ('' != document.getElementById("APVLIST").value) {
            	m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
                elmlength = 
                	$$(m_evalJSON).find("steps > division > step").length;

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

var printDiv;
//메뉴 이벤트 처리 Main function : KJW : 2014.04.23 : XFORM PRJ.
//의견창 타이틀
var commentPopupTitle = '';
var commentPopupButtonID = '';
//var commentPopupReturnValue = false;
var commonWritePopupOnload;

function doButtonAction(obj) {
	if (!isGovMulti()) {
		if(getInfo('ExtInfo.UseMultiEditYN') == "Y") { //다안기안일 경우만
			if(typeof(setHwpContent) === "function") {
				if(getInfo("ExtInfo.UseWebHWPEditYN") == "Y") {
					if(setHwpContent(arguments, arguments.callee)) return;
				}
			}
		}
	}
	
    commentPopupTitle = $(obj).val();		//$(obj).find('span').eq(0).text();
    commentPopupButtonID = $(obj).attr("id");

    //연속결재의 경우 바로 실행하지 않고 클릭한 버튼 값을 저장한다.
    //if (CFN_GetQueryString("bserial") == "true" && $(".topWrap").find("#" + $(obj).attr('id')).length > 0) {
    if (commentPopupButtonID != "btLine" && CFN_GetQueryString("bserial") == "true" && $(".topWrap").find("input[type='button'][id='" + $(obj).attr('id') + "']").length > 0) {
    	if(commentPopupButtonID == "btConsultReq" || commentPopupButtonID == "btConsultReqCancel") {
    		if (typeof doButtonCase[obj.id] === 'function') {
	            doButtonCase[obj.id]($(obj), baseVariableObject);
	        }
    	} else {
            parent.setStateSerialApprovalList($(obj).attr('id'), $(obj).val(), getInfo("Request.mode"), "");
    	}
    } else {
	    //clone object
	    var baseVariableObject = jQuery.extend(true, {}, doButtonDefault);
	
	
	    //case 전 공통 처리
	    baseVariableObject.preProcess();
	
	    if (typeof _ieOrgVer === 'undefined') return;
	
	    if (_ieOrgVer < 8) {
	        Common.Warning(Common.getDic("msg_apv_ieversionCheck"));
	        return;
	    }
	
	    try {
	        //버튼 분기 처리 함수 호출
	        if (typeof doButtonCase[obj.id] === 'function') {
	            //필요한 경우 return 값 반환하여 처리
	            var ret = doButtonCase[obj.id]($(obj), baseVariableObject);
	        }
	
	        //분기 처리 후 공통 처리
	        doButtonPostProcess(baseVariableObject);
	
	    } catch (e) {
	        alert(e.description);
	        throw e;
	    }
    }

}

//메뉴 이벤트 분기 처리 후 공통 처리 함수 : KJW : 2014.04.23 : XFORM PRJ.
function doButtonPostProcess(retVariableObject) {
    var sUrl = retVariableObject.sUrl,
        iWidth = retVariableObject.iWidth,
        iHeight = retVariableObject.iHeight,
        sSize = retVariableObject.sSize,
        formNm = retVariableObject.formNm,
        m_evalJSON = retVariableObject.m_evalJSON,
        elmlength = retVariableObject.elmlength,
        commentCount = retVariableObject.commentCount,
        elmComment = retVariableObject.elmComment;
    
    $('#result2').append('POST > iWidth:' + iWidth).append('<br>');

    if (sUrl != null && sUrl != '') {
        if (sUrl.indexOf("ApvlineMgr") > -1) {
            //alert('ApvlineMgr');
            if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "REDRAFT") { iWidth = 1019; iHeight = 643; }
            else { iWidth = 800; iHeight = 643; }
            if (openMode == "L" || openMode == "P") {
                var nLeft = (screen.width - iWidth) / 4;
                var nTop = (screen.height - iHeight) / 4;
                var sWidth = iWidth.toString() + "px";
                var sHeight = iHeight.toString() + "px";

                if (sUrl.indexOf('\?') > -1) // 파라미터 여러개일 경우 &로 연결
                    parent.Common.ShowDialog("btLine", "btLine" + getInfo("FormInstanceInfo.FormInstID"), $("#btLine").text() + "|||" + gLabel_apvlinecomment, sUrl + "&openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");
                else
                    parent.Common.ShowDialog("btLine", "btLine" + getInfo("FormInstanceInfo.FormInstID"), $("#btLine").text() + "|||" + gLabel_apvlinecomment, sUrl + "?openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");
            } else {
                CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
            }
        } else if (sUrl.indexOf("ApvInfo") > -1) {
            if (openMode == "L" || openMode == "P") {
                var nLeft = (screen.width - iWidth) / 4;
                var nTop = (screen.height - iHeight) / 4;
                var sWidth = iWidth.toString() + "px";
                var sHeight = iHeight.toString() + "px";

                parent.Common.ShowDialog("btLine", "DivPop_" + openID, $("#btLine").text(), sUrl + "&openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 레이블 수정 필요.
            } else {
                CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
            }
        } else if (sUrl.indexOf("comment_view") > -1) {
            if (openMode == "L" || openMode == "P") {

                //의견창위치 화면 중앙으로 맞추기
                var nLeft = (screen.width - iWidth) / 2;
                var nTop = (screen.height - iHeight) / 2;
                var sWidth = iWidth.toString() + "px";
                var sHeight = iHeight.toString() + "px";
                parent.Common.ShowDialog("btCommentView", "DivPop_" + openID, $("#btCommentView").text(), sUrl + "&openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 레이블 수정 필요.
            } else {
                CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
            }
        } else if (sUrl.indexOf("ApvActBasic") > -1) {
            if (openMode == "L" || openMode == "P" || navigator.userAgent.toString().indexOf("COVI_HYBRID", 0) > -1) {
                var nLeft = (screen.width - iWidth) / 2;
                var nTop = (screen.height - iHeight) / 2;
                var sWidth = iWidth.toString() + "px";
                var sHeight = iHeight.toString() + "px";
                var sActIndx = "";
                var sTitle = ""
                if (document.getElementById("ACTIONINDEX").value == "") { sActIndx = "" }
                else { sActIndx = document.getElementById("ACTIONINDEX").value; }
                if (sActIndx == "reject") { sTitle = $("#btReject").text(); }
                else { sTitle = $("#btApproved").text(); }

                if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") {
                    parent.Common.ShowDialog("btapproved", "DivPop_btapproved", sTitle, sUrl + "&openID=" + openID + "&actionIndx=" + sActIndx, sWidth, sHeight, "iframe-ifNoScroll");    // 기안, 임시저장 시 openID 처리용
                } else {
                    if (sUrl.indexOf("?") > -1) {
                        parent.Common.ShowDialog("btapproved", "DivPop_btapproved", sTitle, sUrl + "&openID=" + openID + "&actionIndx=" + sActIndx, sWidth, sHeight, "iframe-ifNoScroll");    // 승인 등의 openID 처리 용
                    } else {
                        parent.Common.ShowDialog("btapproved", "DivPop_btapproved", sTitle, sUrl + "?openID=" + openID + "&actionIndx=" + sActIndx, sWidth, sHeight, "iframe-ifNoScroll");    // 승인 등의 openID 처리 용
                    }
                }
            } else {
                // 모바일에서 기안할 경우 레이어팝업으로 변경
                CFN_OpenWindow(sUrl, "CommentWrite", iWidth, iHeight, sSize);
            }
        } else if (sUrl.indexOf("comment_") > -1
                   || sUrl.indexOf("CirculationMgr") > -1
                   || sUrl.indexOf("Circulation_Read_View") > -1
                   || sUrl.indexOf("ReceiptList") > -1
                   || sUrl.indexOf("HistoryList") > -1
                   || sUrl.indexOf("selectOUs") > -1
                   || sUrl.indexOf("ApvprocessDraft") > -1) {
            if (openMode == "L" || openMode == "P") {
                var nLeft = (screen.width - iWidth) / 2;
                var nTop = (screen.height - iHeight) / 2;
                var sWidth = iWidth.toString() + "px";
                var sHeight = iHeight.toString() + "px";
                if (sUrl.indexOf("ReceiptList") > -1) {
                    parent.Common.ShowDialog("", "DivPop_ReceiptList", Common.getDic("lbl_apv_receipt_view"), sUrl + "&openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 레이블 수정 필요.
                } else if (sUrl.indexOf("HistoryList") > -1) {
                    parent.Common.ShowDialog("", "DivPop_ReceiptList", $("#btHistory").text(), sUrl + "&openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 히스트로 제목 필요.
                } else if (sUrl.indexOf("comment_") > -1) {
                    parent.Common.ShowDialog("", "DivPop_" + openID, Common.getDic("lbl_apv_comment"), sUrl + "&openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 완료함_의견 제목 필요.
                } else if (sUrl.indexOf("CirculationMgr") > -1) {   
                    parent.Common.ShowDialog("", "DivPop_" + openID, Common.getDic("lbl_apv_setschema_Circulation"), sUrl + "&openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 완료함_회람 제목 필요.
                } else if (sUrl.indexOf("Circulation_Read_View") > -1) {
                    parent.Common.ShowDialog("", "DivPop_" + openID, Common.getDic("MsgApprovalState_ApprovalConsulted"), sUrl + "&openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 완료함_참조/회람 제목 필요.
                }
                else {
                    if (sUrl.indexOf("?") > -1) {
                        parent.Common.ShowDialog("", "DivPop_" + openID, commentPopupTitle, sUrl + "&openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 레이블 수정 필요.
                    } else {
                        parent.Common.ShowDialog("", "DivPop_" + openID, commentPopupTitle, sUrl + "?openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 레이블 수정 필요.ReSize
                    }
                }
            } else {
                CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
            }
        } else if(sUrl.indexOf("Print.do") > -1 && retVariableObject.printMode == "IFRAME") {
        	// Popup 방식일 경우 크롬에서 "시스템 대화상자를 사용하여 인쇄" 기능사용시 창이 닫히는 증상이 있어 Iframe 으로 변경
        	if($("iframe#printIfr").length == 0) {
        		$(document.body).append("<iframe style='width:0px;height:0px;position:absolute;' id='printIfr'>");
        	}
        	$("iframe#printIfr").prop("src", sUrl);
        } else {
            if (openMode == "L" || openMode == "P") {
                var nLeft = (screen.width - iWidth) / 2;
                var nTop = (screen.height - iHeight) / 2;
                var sWidth = iWidth.toString() + "px";
                var sHeight = iHeight.toString() + "px";
                if (sUrl.indexOf("ReceiptList") > -1) {
                    parent.Common.ShowDialog("", "DivPop_ReceiptList", commentPopupTitle, sUrl + "&openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 레이블 수정 필요.
                } else {
                    if (sUrl == "Print.do" || sUrl == "PrintForm.do") {
                        CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
                    }else if (sUrl.indexOf("Pubpreview") > -1) { 
                        parent.Common.ShowDialog("", "DivPop_" + openID, Common.getDic("lbl_apv_OTransPV"), sUrl + "&openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 대외공문 미리보기 
                    } else if (sUrl.indexOf("?") > -1) {
                        parent.Common.ShowDialog("", "DivPop_" + openID, commentPopupTitle, sUrl + "&openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 레이블 수정 필요.
                    } else {
                        parent.Common.ShowDialog("", "DivPop_" + openID, commentPopupTitle, sUrl + "?openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 레이블 수정 필요.ReSize
                    }
                }
            } else {
            	if(getInfo("SchemaContext.scDistribution.isUse") == "Y"){//대외수신처
            		iHeight += 30;
            	}
            	CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
            }
            //CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
        }
    }

}

/*-------------------------------------------------------
 메뉴 버튼 이벤트 분기 처리 함수 : KJW : 2014.04.23 : XFORM PRJ.
--------------------------------------------------------- 
[버튼 이벤트 처리 방법] 
버튼이 추가되면 아래의 구문을 추가한다.
기존의 switch case 에 정의되는 것이 독립한 함수로 분화한 형태로 사용.

doButtonCase['버튼 아이디'] = function (oBtn, oVar) {
    // 처리 구문
}
--------------------------------------------------------- 
[파라미터]
oBtn :	이벤트가 발생한 개체로 jquery 개체.
		예) oBtn.css('border', 'solid 1px #f00');

oVar :	버튼 이벤트 처리에 사용되는 공통 variable을 담은 오브젝트. 
		아래는 참조 가능한 속성

		sUrl : "",
		iWidth : "640",
		iHeight : "480",
		sSize : "fix",
		formNm : "",
		m_evalXML : "",
		elmlength : 0,
		commentCount : 0,
		elmComment : "",
		preProcess : function()
--------------------------------------------------------------
 분기 처리 함수 <시작> : KJW : 2014.04.23 : XFORM PRJ.
-------------------------------------------------------------*/
doButtonCase['bt_receive_cc'] = function (oBtn, oVar) {//수신/참조
    receiveOpen();
}

doButtonCase['btreceive'] = function (oBtn, oVar) {//수신
    oVar.iWidth = 400; oVar.iHeight = 400;
    receiveOpen();
}

doButtonCase['btCC'] = function (oBtn, oVar) {//참조
    oVar.iWidth = 400; oVar.iHeight = 400;
    ccOpen();
}

doButtonCase['btCirculate'] = function (oBtn, oVar) {//회람
	oVar.iWidth = 1016; oVar.iHeight = 585;
    oVar.sUrl = "goCirculationMgrListpage.do?piid="+getInfo("ProcessInfo.ProcessID") + "&fiid=" + getInfo("FormInstanceInfo.FormInstID") + "&openDo=Circulate&openType=C&pState=528";
}

/**
 * xml -> json
 */
doButtonCase['btDraft'] = function (oBtn, oVar) {//기안하기
	if (!bool_ApvValidationCheck()) {
		return;
	}
    
    // 양식내 결재선 사용시 기안전에 결재선 재 정리
	if (getInfo('SchemaContext.scFormAddInApvLine.isUse') == 'Y' && getInfo('Request.templatemode') == 'Write') {
		if (!addInApvLine.setAppLineData(true)) return;
	}
	
    //결재선 필수체크
	if(chkAutoApprovalLine()) return;
	
	//결재선 추가체크 (기안 전 결재선 validation 체크)
	if(chkAutoValApprovalLine()) return;
	
	//문서유통 제목값셋팅
	//2022-11-28 수정 => 문서유통+다안기안일때는 제목이 문서안에 있어서 세팅 할 필요 없음
	if (!isGovMulti()) {
		if(isUseHWPEditor() && getInfo("SchemaContext.scDistribution.isUse")=="Y") {
			document.getElementById("Subject").value = HwpCtrl.GetFieldText('doctitle');		
		}
	}
	
	if(isGovMulti()) { 
		saveCurMulti();
		//시행발송 경우 수신처 지정 체크(필수임)
		var chkMulCount = $("#writeTab li").length;
		var tmpMulti="";
		for(var i = 1; i < chkMulCount+1; i++) {
           if($('[name=MULTI_APV_RECEIVER_TYPE]').eq(i).val() == "else"){//시행발송 경우
        	   if($('[name=MULTI_RECEIVENAMES]').eq(i).val()=="" ){
        		   tmpMulti += i +', ';
        	   }
           }			
		}	
        if (tmpMulti != ''){
 		   alert("[시행발송] 경우 [수신처]는 필수로 지정하셔야 합니다.\n[" + tmpMulti.slice(0,-2) + "] 안 수신처 지정하세요. ")
 		   return;
        }
		
	}else if(getInfo("SchemaContext.scDistribution.isUse")=="Y"){
		// 단건 문서유통
		//var receiveType = $("#RECEIVE_CHECK").find("input:checked").val(); // 시행발송
		var receiveType = $("#RECEIVE_CHECK").val(); // 시행발송
		
		if(receiveType == "else"){
			var receiveGovType = document.getElementById('RECEIVEGOV_TYPE').value; // 한글
			var receiveName = document.getElementById("ReceiveNames").value; // 일반에디터

			if (receiveGovType.length== 0 && receiveName.length == 0){
		 		   alert("[시행발송] 경우 [수신처]는 필수로 지정하셔야 합니다.");
		 		   return;
		    }
		}
	}
	
	if(getInfo("SchemaContext.scDistribution.isUse")=="Y"){
		if(document.getElementById("SENDERMASTER").value.length == ''){
			alert("인장을 선택해주세요.");
		 	return;
		}
	}
	
	// 기록물철 단건
	if(getInfo("SchemaContext.scRecordDocOpen.isUse") =="Y" && getInfo("ExtInfo.UseMultiEditYN") != "Y"){
		var recordSubject = $('#RECORD_SUBJECT').val();

		if(recordSubject.length == 0){
			alert("기록물철을 선택하세요.");
	 	   return;
		}
	}
	
	//문서유통 & 웹기안기 & 다안기안 수신처합치기 (formInstanc names,list용)
	if(isGovMulti()) { 
		mergeMultiRec();
	}
	
    m_sReqMode = "DRAFT";
    
    //CommentWrite.do
    if (evaluateForm()) {
    	if(_mobile) {
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
            			$$(emlComment).remove();
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
    	} else {
 		    var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 349, "resize");
		    
		    commonWritePopupOnload = function(){
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
	                		$$(emlComment).remove();
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
		    };
    	}
    }
    
}

doButtonCase['btLine'] = function (oBtn, oVar) {//결재선관리
    // 동시결재자 결재선변경 방지
	//user/ApprovalDetailList.do?FormInstID=358&ProcessID=1365162

	// 양식내 결재선 사용시 결재선 변경은 편집 모드일때만 가능
	if (getInfo('SchemaContext.scFormAddInApvLine.isUse') == 'Y' && getInfo('Request.templatemode') == 'Read') {
		oVar.iHeight = 310; oVar.iWidth = 690;
        oVar.sUrl = "user/ApprovalDetailList.do?ProcessID=" + getInfo("ProcessInfo.ProcessID") + "&FormInstID=" + getInfo("FormInstanceInfo.FormInstID");
        oVar.sSize = "scroll";
	} else {
	    var oApproveStep;
	    if (getInfo("Request.mode") == "APPROVAL") {
	        var jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
	        oApproveStep = $$(jsonApv).find("steps>division").has("taskinfo[status='pending']").find(">step").has("ou>person[code='" + getInfo("AppInfo.usid") + "']").has("ou>person>taskinfo[status='pending'])");
	    }
	
	    if  (((getInfo("Request.loct") == "MONITOR") || (getInfo("Request.loct") == "PREAPPROVAL") || (getInfo("Request.loct") == "PROCESS") || (getInfo("Request.loct") == "REVIEW") || (getInfo("Request.loct") == "COMPLETE") || (getInfo("Request.mode") == "REJECT") || (getInfo("Request.mode") == "JOBDUTY") || (getInfo("Request.mode") == "PCONSULT") || (getInfo("Request.subkind") == "T019") || (getInfo("Request.subkind") == "T005") || (getInfo("Request.subkind") == "T018")) //20110318확인결재추가-확인결재자 결재선변경권한없음
	    	|| (oApproveStep && oApproveStep.attr("routetype") == "approve" && oApproveStep.attr("allottype") == "parallel") // 동시결재자 결재선변경 방지 [2015-11-24]
	    	|| (getInfo("SchemaContext.scNCHAis.isUse") && getInfo("SchemaContext.scNCHAis.isUse") == "Y" && (getInfo("Request.mode") != "DRAFT" && getInfo("Request.mode") != "TEMPSAVE" && getInfo("Request.mode") != "REDRAFT" && getInfo("Request.mode") != "SUBREDRAFT"))){ 
	        oVar.iHeight = 310; oVar.iWidth = 690;
	        oVar.sUrl = "user/ApprovalDetailList.do?ProcessID=" + getInfo("ProcessInfo.ProcessID") + "&FormInstID=" + getInfo("FormInstanceInfo.FormInstID");
	        oVar.sSize = "scroll";
	    } else {
			// 양식내 결재선 사용시 결재선 팝업창 열기전에 결재선 재 정리
			if (getInfo('SchemaContext.scFormAddInApvLine.isUse') == 'Y') {
				addInApvLine.setAppLineData();
			}
			
	    	oVar.iHeight = 562; oVar.iWidth = 1100;
	    	oVar.sUrl = "/approval/approvalline.do";
	    	oVar.sSize = "scrollbars=no,toolbar=no,resizable=no";
	    }
    }
}

doButtonCase['btRecDept'] = function (oBtn, oVar) {//결재선관리
	oVar.iHeight = 580; oVar.iWidth = 1110;
	//문서유통사용
	if(getInfo("SchemaContext.scDistribution.isUse") == "Y") {
		oVar.sUrl = "/approval/ReceiveManagerPopup.do?AllCompany=Y";
		oVar.iHeight = 630;
	//개별수신처사용 
	} else {
		oVar.sUrl = "/approval/deployline.do?AllCompany=Y";
	}
}

doButtonCase['btDeptDraft'] = function (oBtn, oVar) {//재기안 기안과 UI 통일
    m_sReqMode = "DEPTDRAFT";
    
    // 기록물철 단건
	if(getInfo("SchemaContext.scRecordDocOpen.isUse") =="Y" && getInfo("ExtInfo.UseMultiEditYN") != "Y"){
		var recordSubject = $('#RECORD_SUBJECT').val();

		if(recordSubject.length == 0){
			alert("기록물철을 선택하세요.");
	 	   return;
		}
	}
    
    if (evaluateForm()) {
    	var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 549, "resize");
	    /*ie 에서 unload가 동작하지 않음
	     $(commonWritePopup).unload(function(){
	    	if(commentPopupReturnValue){
			    document.getElementById("ACTIONINDEX").value = "REDRAFT";		//"approve";
			    requestProcess("RECREATE");
	    	}
	    });*/
    	
    	commonWritePopupOnload = function(){
			document.getElementById("ACTIONINDEX").value = "REDRAFT";		//"approve";
		    requestProcess("RECREATE");
    	};
    }
}

doButtonCase['btCharge'] = function (oBtn, oVar) {//재기안담당자 지정
	document.getElementById("ACTIONINDEX").value = "CHARGE";
    m_sAddList = 'charge'; Open_Forward(m_sAddList);
}

doButtonCase['btDeptLine'] = function (oBtn, oVar) {//재기안결재선관리
	var sUrl = "/approval/approvalline.do";
	var iWidth = 1100;
	var iHeight = 580;
	var sSize = "scrollbars=no,toolbar=no,resizable=no";
	if(getInfo("SchemaContext.scNCHAis.isUse") && getInfo("SchemaContext.scNCHAis.isUse") == "Y" && (getInfo("Request.mode") != "DRAFT" && getInfo("Request.mode") != "TEMPSAVE" && getInfo("Request.mode") != "REDRAFT" && getInfo("Request.mode") != "SUBREDRAFT")) {
		sUrl = "user/ApprovalDetailList.do?ProcessID=" + getInfo("ProcessInfo.ProcessID") + "&FormInstID=" + getInfo("FormInstanceInfo.FormInstID");
		iHeight = 310;
		iWidth = 690;
		sSize = "scroll";	    
	}
	CFN_OpenWindow(sUrl,"ApprovalLineMgr",iWidth,iHeight,sSize); 
}

doButtonCase['btPreView'] = function (oBtn, oVar) {//미리보기
	// 첨부파일 세팅
	//setFormAttachFileInfo();
	m_sReqMode = "preview"; // 미리보기 예외처리 값 구분
	
    (window.navigator.userAgent.toLowerCase().indexOf('firefox') > -1) ? oVar.sSize = "scroll" : oVar.sSize = "fix";

    oVar.iWidth = 790;
    //가로양식
    if (IsWideOpenFormCheck(getInfo("FormInfo.FormPrefix"), getInfo("FormInfo.FormID"))) {
        oVar.iWidth = 1070;
    }
    oVar.iHeight = window.screen.height - 82;
    oVar.sUrl = String(document.location.href);
    if(getInfo("Request.mode") == "DRAFT" && getInfo("Request.reuse")){
    	var tmpUrl = String(document.location.href);
    	if(tmpUrl.indexOf("?") > -1 && formJson && formJson.FormInfo && formJson.FormInfo.FormID){
    		tmpUrl = tmpUrl.substring(0,tmpUrl.indexOf("?"));
    		tmpUrl = tmpUrl + "?mode=DRAFT&formID=" + formJson.FormInfo.FormID;
    		oVar.sUrl = tmpUrl; 
    	}
    }
    setFormAttachFileInfo(true); // 변경된 첨부파일정보 저장
    oVar.sUrl = oVar.sUrl.replace("FormWrite", "Form"); //바닥 작성창에서 Open할 경우
    if (oVar.sUrl.lastIndexOf("#") == (oVar.sUrl.length - 1)) { oVar.sUrl = oVar.sUrl.substring(0, oVar.sUrl.lastIndexOf("#")); } //url에 #이 포함되어 있음 제거처리
    oVar.sUrl = oVar.sUrl + "&Readtype=preview";
    if(CFN_GetQueryString("openID") != "undefined" ){
        oVar.sUrl = oVar.sUrl.split('&');
        oVar.sUrl = oVar.sUrl[0] + oVar.sUrl[1] + oVar.sUrl[2] + oVar.sUrl[3];
    }
}

doButtonCase['btPrint'] = function (oBtn, oVar) {//인쇄
	if(isUseHWPEditor()){
		if(getInfo('ExtInfo.UseMultiEditYN') == "Y") {
			var idx = $("#writeTab li.on").attr('idx');
			
			if(getInfo('ExtInfo.UseWebHWPEditYN') == "Y") {
				document.getElementById("tbContentElement" + m_firstIDx + "Frame").contentWindow.HwpCtrl.PrintDocument();
			} else {
				document.getElementById("tbContentElement" + idx).PrintDocument();
			}
		} else {
			if(getInfo('ExtInfo.UseWebHWPEditYN') == "Y") {
				document.getElementById("tbContentElementFrame").contentWindow.HwpCtrl.PrintDocument();
			} else {
				document.getElementById("tbContentElement").PrintDocument();
			}
		}
	} else {
	    /*
	    if ((oVar.elmComment && oVar.elmComment.length == 0) || typeof oVar.elmComment == "undefined"){
	        try { document.getElementById("CommentList").style.display = "none"; } catch (e) { }
	    }
	    */
	    m_CmtBln = false;
	    bPresenceView = false;
	    //__displayApvList(oVar.m_evalJSON);
	    printDiv = "<html><body>" + getBodyHTML() + "</body></html>";
	    if (!_ie) {
	        oVar.iWidth = 1000; oVar.iHeight = 700;
	    } else {
	        oVar.iWidth = 100; oVar.iHeight = 100;
	    }
	
	    gPrintType = "0";
	
	    if (gPrintType == "0") {
	        oVar.sUrl = "form/Print.do";
	        oVar.printMode = "IFRAME"; // IFRAME/POPUP
	    } else if (gPrintType == "1") {
	        m_oFormReader.print_part('editor');
	    }
	    m_CmtBln = true;
	    bPresenceView = true;
	   // __displayApvList(oVar.m_evalJSON);
	}
}

doButtonCase['btPrintView'] = function (oBtn, oVar) {//인쇄미리보기
    if (!_ie && (getInfo("FormInfo.FormPrefix") == "OFFICAL_DOCUMENT_02" || getInfo("FormInfo.FormPrefix") == "OFFICAL_DOCUMENT_01")) {
        alert("[대외공문]인쇄는 IE 에서만 지원 가능합니다.");
    } else {

        if (getInfo("SchemaContext.scOPub.isUse") == "Y") {
            try {
                if (document.getElementById("rowcnt_doc").value != "0") {
                    document.getElementById("ADD_rowCnt_Doc").style.height = (document.getElementById("rowcnt_doc").value * 50) + "px";
                }
            } catch (e) { coviCmn.traceLog(e); }
            try { document.getElementById("CommentList").style.display = "none"; document.getElementById("CCLine").style.display = "none"; } catch (e) { coviCmn.traceLog(e); }

            printDiv = "<html><body>" + getBodyHTML() + "</body></html>";

        }else {
            if (oVar.elmComment.length == 0) {
                try { document.getElementById("CommentList").style.display = "none"; } catch (e) { coviCmn.traceLog(e); }
            }

            printDiv = "<html><body>" + getBodyHTML() + "</body></html>";
        }

        m_CmtBln = false;
        m_oFormEditor.bPresenceView = false;
//        __displayApvList(oVar.m_evalJSON);
        oVar.iWidth = 800; oVar.iHeight = 700;

        gPrintType = "0";
        if (gPrintType == "0") {
            oVar.sUrl = "form/PrintForm.do";
        } else if (gPrintType == "1") {
            m_oFormReader.print_part('editor');
        }
        m_CmtBln = true;
        m_oFormEditor.bPresenceView = true;
//        __displayApvList(oVar.m_evalJSON);
        //displayApvList(oVar.m_evalJSON);
    }

}
//(본사운영) 외주 버튼
doButtonCase['btPrintContract'] = function (oBtn, oVar) {// 발주, 외주 인쇄미리보기
    doButtonCase['btPurchaseOrder'](oBtn, oVar);
}

//(본사운영) 발주 버튼
doButtonCase['btPurchaseOrder'] = function (oBtn, oVar) {// 발주, 외주 인쇄미리보기
    /*if (!_ie && (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_ORDER" || getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_OUTSOURCING")) {
        alert("[발주품의]인쇄는 IE 에서만 지원 가능합니다.");
    } else {*/

	if (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_ORDER" || getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_OUTSOURCING"
    	|| getInfo("FormInfo.FormPrefix") == "WF_FORM_BIZMNT_BUYORDERS" || getInfo("FormInfo.FormPrefix") == "WF_FORM_BIZMNT_BUYOUTSOURCING") {
            try {
                if (document.getElementById("rowcnt_doc").value != "0") {
                    document.getElementById("ADD_rowCnt_Doc").style.height = (document.getElementById("rowcnt_doc").value * 50) + "px";
                }
            } catch (e) { coviCmn.traceLog(e); }
            try { document.getElementById("CommentList").style.display = "none"; document.getElementById("CCLine").style.display = "none"; } catch (e) { coviCmn.traceLog(e); }

            printDiv = "<html><body>" + getBodyHTML() + "</body></html>";

        }
        else {
            if (oVar.elmComment.length == 0) {
                try { document.getElementById("CommentList").style.display = "none"; } catch (e) { coviCmn.traceLog(e); }
            }

            printDiv = "<html><body>" + getBodyHTML() + "</body></html>";
        }

        m_CmtBln = false;
        bPresenceView = false;
        //__displayApvList(oVar.m_evalJSON);
        oVar.iWidth = 800; oVar.iHeight = 700;

        gPrintType = "0";
        if (gPrintType == "0") {
        	if (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_ORDER" || getInfo("FormInfo.FormPrefix") == "WF_FORM_BIZMNT_BUYORDERS") {
            	CoviWindow("/approval/goOrder.do", "Order", "800", "700", "scroll");
            }
            else if (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_OUTSOURCING" || getInfo("FormInfo.FormPrefix") == "WF_FORM_BIZMNT_BUYOUTSOURCING") {
            	CoviWindow("/approval/goOutsourcing.do", "Outsourcing", "800", "700", "scroll");
            }
        } else if (gPrintType == "1") {
            m_oFormReader.print_part('editor');
        }
        m_CmtBln = true;
        bPresenceView = true;
       // __displayApvList(oVar.m_evalJSON);
    //}
}

//(본사운영) 라이선스 버튼 비사용
doButtonCase['btPrintLicense'] = function (oBtn, oVar) {// 라이센스 인쇄미리보기
//    if (!_ie && (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_License")) {
//        alert("[라이센스]인쇄는 IE 에서만 지원 가능합니다.");
//    } else {

        if (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_License") {
            try {
                if (document.getElementById("rowcnt_doc").value != "0") {
                    document.getElementById("ADD_rowCnt_Doc").style.height = (document.getElementById("rowcnt_doc").value * 50) + "px";
                }
            } catch (e) { coviCmn.traceLog(e); }
            try { document.getElementById("CommentList").style.display = "none"; document.getElementById("CCLine").style.display = "none"; } catch (e) { coviCmn.traceLog(e); }

            printDiv = "<html><body>" + getBodyHTML() + "</body></html>";

        }
        else {
            if (oVar.elmComment.length == 0) {
                try { document.getElementById("CommentList").style.display = "none"; } catch (e) { coviCmn.traceLog(e); }
            }

            printDiv = "<html><body>" + getBodyHTML() + "</body></html>";
        }

        m_CmtBln = false;
        m_oFormEditor.bPresenceView = false;
        //__displayApvList(oVar.m_evalJSON);
        oVar.iWidth = 800; oVar.iHeight = 700;

        gPrintType = "0";
        if (gPrintType == "0") {
            if (getInfo("FormInfo.FormPrefix") == "WF_FORM_DRAFT_License") {
            	CoviWindow("/approval/goSoftwareView.do", "Software", "700", "900", "scroll");
            }
        } else if (gPrintType == "1") {
            m_oFormReader.print_part('editor');
        }
        m_CmtBln = true;
        m_oFormEditor.bPresenceView = true;
        //__displayApvList(oVar.m_evalJSON);
    //}
}

doButtonCase['btPrintEvid'] = function (oBtn, oVar) {//증빙 일괄출력
    printDiv = "<html><body>" + getEvidHTMLEAccount() + "</body></html>";
    
    if (!_ie) {
        oVar.iWidth = 1000; oVar.iHeight = 700;
    } else {
        oVar.iWidth = 100; oVar.iHeight = 100;
    }
    
    oVar.sUrl = "form/Print.do";
}

doButtonCase['btDownloadEvidFile'] = function (oBtn, oVar) {//증빙별 첨부 일괄저장
	var fileList = [];
	$(formJson.BodyContext.JSONBody.pageExpenceAppEvidList).each(function(i, obj) {
	    fileList = $.merge(fileList, obj.fileList);
	});
	
    Common.downloadAll(fileList);
}

doButtonCase['btHistory'] = function (oBtn, oVar) {//히스토리				
    var vwidth = 790;
    //가로양식
    if (IsWideOpenFormCheck(getInfo("FormInfo.FormPrefix"), getInfo("FormInfo.FormID"))) {
        vwidth = 1070;
    }

    oVar.iWidth = 857;
    var vheight = (window.screen.height - 100);
    oVar.iHeight = vheight;
    oVar.sSize= "scroll";
    
    oVar.sUrl = "goHistoryListPage.do?ProcessID=" + getInfo("ProcessInfo.ProcessID") + "&FormInstID=" + getInfo("FormInstanceInfo.FormInstID") + "&FormPrefix=" + getInfo("FormInfo.FormPrefix") + "&Revision=" + getInfo("FormInfo.Revision");
    
}

doButtonCase['btSave'] = function (oBtn, oVar) {//임시저장
	if(isGovMulti()) {
		mergeMultiRec();
	}
    if (document.getElementById("Subject").value == "") {
        var subject = CFN_GetDicInfo(getInfo("AppInfo.usnm_multi")) + " - " + CFN_GetDicInfo(getInfo("FormInfo.FormName"));
        document.getElementById("Subject").value = subject;
        // HwpCtrl.PutFieldText("doctitle", subject);
        m_TempSaveInfo = true;
        m_TempSave = true;
    }
    
    // 양식내 결재선 사용시 임시저장전에 결재선 재 정리
	if (getInfo('SchemaContext.scFormAddInApvLine.isUse') == 'Y' && getInfo('Request.templatemode') == 'Write') {
		if (!addInApvLine.setAppLineData(true)) return;
	}
	
    if(getInfo('ExtInfo.UseHWPEditYN') == "Y" && $('#tbContentElement1').length > 0) {
    	if($('#tbContentElement1')[0].GetFieldText("SUBJECT") != ""){
    		$('#Subject').val($('#tbContentElement1')[0].GetFieldText("SUBJECT"));	// 1안의 제목을 결재문서 제목으로 사용함
    	}
    }
    setFormAttachFileInfo();
    
    m_sReqMode = "TEMPSAVE";
    requestProcess("TEMPSAVE");
}

doButtonCase['btModify'] = function (oBtn, oVar) {//수정
	var isApvLineChg = "N";
	//결재선이 수정되었을 경우 마킹값 넘김
	if(getInfo("ApprovalLine") != $("#APVLIST").val()){
		isApvLineChg = "Y";
	}
	
    var submitForm = document.createElement("FORM");
    document.body.appendChild(submitForm);
    submitForm.method = "POST";
    submitForm.name = "DocModify";
    var newElement = document.createElement("TEXTAREA");
    submitForm.appendChild(newElement);
    newElement.id = 'DocModifyApvLine';
    newElement.name = 'DocModifyApvLine';
    newElement.value = document.getElementById("APVLIST").value;
    newElement.style.display = 'none';
    submitForm.target = "_self";
    submitForm.action = window.location.href.replace("#", "").replace("&editMode=", "").replace("&editMode=N", "").replace("&reuse=", "") + "&editMode=Y&reuse=&isApvLineChg="+isApvLineChg;
    submitForm.submit();
}

doButtonCase['btchangeSave'] = function (oBtn, oVar) {//수정저장
	setFormAttachFileInfo();
	if(getInfo("SchemaContext.scWFPwd.isUse") == "Y" && chkUsePasswordYN()){
    	Common.Password(Common.getDic("_approval_EditSavePW"), null, Common.getDic("lbl_apv_ApvPwd_Check"), function (apvToken) {
			if (apvToken) {
				if (apvToken.indexOf("e1Value:") > -1) { //생체인증 처리  
					this.fidoCallBack = function(){
						changeFormdata();
					}
					Common.open("", "checkFido", Common.getDic("lbl_RequestUserAuth"), "/covicore/control/checkFido.do?logonID="+Common.getSession("UR_Code")+"&authType=Approval", "400px", "510px", "iframe", true, null, null, true); //사용자 본인인증 요청
				}else{
					if(chkCommentWrite(apvToken)){
						_g_password = aesUtil.encrypt(proaas, proaaI, proaapp, apvToken);
						// 결재 진행
						changeFormdata();
					}else{
						// 비밀번호 틀림
						Common.Warning(Common.getDic("msg_PasswordChange_02"));
					}
				}
			}
		});
		
		  // 생체인증 버튼 제어
        if (useFido == "Y") {
            setTimeout(function () {
                var oTargetObj = $("#alert_container").find("#popup_e1")
                $(oTargetObj).find("strong").text(Common.getDic("lbl_Biometrics"));
                $(oTargetObj).show();
            }, 350);
        }
 	}else{
    	changeFormdata();
 	}
}

doButtonCase['btTrans'] = function (oBtn, oVar) {//내부결재선관리
    if (getInfo("SchemaContext.scIPub.isUse") == "Y") {
        Common.Confirm(gMessage100, "Confirmation Dialog", function (result) { //"의견을 포함하여 인쇄하시겠습니까?\n [확인]->[의견포함],\n [닫기]->[의견미포함]"
            m_oFormEditor.initEnforceForm();
        });
    } else { m_oFormEditor.initEnforceForm(); }
}

doButtonCase['btOTrans'] = function (oBtn, oVar) {//대외공문변환				
	/*if (!_ie && getInfo("FormInfo.FormPrefix") == "WF_FORM_EXTERNAL"){ //(getInfo("FormInfo.FormPrefix") == "OFFICAL_DOCUMENT_02" || getInfo("FormInfo.FormPrefix") == "OFFICAL_DOCUMENT_01")) {
        alert("[대외공문]인쇄는 IE 에서만 지원 가능합니다.");
        return false;
    }*/
    try {
        if (document.getElementById("rowcnt_doc").value != "0") {
            document.getElementById("ADD_rowCnt_Doc").style.height = (document.getElementById("rowcnt_doc").value * 50) + "px";
        }
    } catch (e) { coviCmn.traceLog(e); }
    try {
        document.getElementById("CommentList").style.display = "none"; 
        document.getElementById("CCLine").style.display = "none";
        document.getElementById("AssistLine").style.display = "none";
        document.getElementById("AppLine").style.display = "none";
        
        // 리스트형 결재선인 경우 대비
        document.getElementById("AppLineListType").style.display = "none";
    } catch (e) { coviCmn.traceLog(e); }

    printDiv = "<html><body>" + getBodyHTML("PUB") + "</body></html>";

    m_CmtBln = false;
    bPresenceView = false;
    if (CFN_GetQueryString("menukind") != "notelist") __displayApvList(oVar.m_evalJSON);

    oVar.sSize = "fix";
    oVar.iWidth = 810;
    oVar.iHeight = window.screen.height - 82

    gPrintType = "0";

    if (gPrintType == "0") {
    	if(_ie)
    		oVar.sUrl = "form/PrintForm.do";
    	else
    		oVar.sUrl = "form/Print.do";
    } else if (gPrintType == "1") {
        m_oFormReader.print_part('editor');
    }
    m_CmtBln = true;
    bPresenceView = true;
    if (CFN_GetQueryString("menukind") != "notelist") __displayApvList(oVar.m_evalJSON);
}

doButtonCase['btAdd'] = function (oBtn, oVar) {//다안기안 안건추가
    m_oFormEditor.AddBody();
}

doButtonCase['btDelete'] = function (oBtn, oVar) {//다안기안 안건삭제
    m_oFormEditor.DeleteBody();
}

doButtonCase['btWithdraw'] = function (oBtn, oVar) {//회수
	if(CFN_GetQueryString("isMobile") == "Y" || _mobile) {
		if(confirm(mobile_comm_getDic("msg_apv_391"))) {
			requestProcess("WITHDRAW");
		} else {
			return;
		}
	} else {
	    Common.Confirm(Common.getDic("msg_apv_391"), "Confirmation Dialog", function (result) {
	        if (result) {
	            requestProcess("WITHDRAW");
	        }
	        else {
	            return;
	        }
	    });
	}
}

doButtonCase['btAbort'] = function (oBtn, oVar) {//취소

	if(CFN_GetQueryString("isMobile") == "Y" || _mobile) {
		requestProcess("ABORT");	
	} else {
		var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 349, "resize");
	    /*ie 에서 unload가 동작하지 않음
	     $(commonWritePopup).unload(function(){
	    	if(commentPopupReturnValue){
	    		requestProcess("ABORT");
	    	}
	    });*/
		
		commonWritePopupOnload = function(){
			requestProcess("ABORT");
		};	
	}
}

doButtonCase['btApproveCancel'] = function (oBtn, oVar) {//승인취소
	if(CFN_GetQueryString("isMobile") == "Y" || _mobile) {
		if(confirm(mobile_comm_getDic("msg_apv_390"))) {
			document.getElementById("ACTIONINDEX").value = "approve";
			requestProcess("APPROVECANCEL");
		} else {
			return;
		}
	} else {
	    Common.Confirm(Common.getDic("msg_apv_390"), "Confirmation Dialog", function (result) {
	        if (result) {
	            document.getElementById("ACTIONINDEX").value = "approve";
	            requestProcess('APPROVECANCEL');
	        }
	        else {
	            return;
	        }
	    });
	}
}
doButtonCase['btMonitor'] = function (oBtn, oVar) {//현황
    requestProcess("MONITOR");
}

doButtonCase['btRec'] = function (oBtn, oVar) {//접수
	m_sReqMode = "DEPTDRAFT";
	if(getInfo("Request.mode") == "SUBREDRAFT") { // 부서합의인 경우 REDRAFT로 넘어가도록 함.
		document.getElementById("ACTIONINDEX").value = "REDRAFT";
	} else {
		document.getElementById("ACTIONINDEX").value = "APPROVAL";		//"approve";	
	}
	
	// 문서유통(수신) 문서인 경우 발신부서 결재라인 제거 (결재선을 지정했을 때에는 자동으로 삭제됨. 전결 처리시에만 문제)
	if (getInfo("ExtInfo.IsGovReceiveForm") == "Y" && $$(m_oApvList).find("steps > division[divisiontype='send']").length > 0) {
		$$(m_oApvList).find("steps > division[divisiontype='send']").remove();
		document.getElementById("APVLIST").value = JSON.stringify(m_oApvList);
	}

	if(evaluateForm()){
		if(getInfo("SchemaContext.scWFPwd.isUse") == "Y" && chkUsePasswordYN()){
	    	Common.Password(Common.getDic("msg_apv_recInputApvPW"), null, Common.getDic("lbl_apv_ApvPwd_Check"), function (apvToken) {
				if (apvToken) {
					if (apvToken.indexOf("e1Value:") > -1) { //생체인증 처리  
						this.fidoCallBack = function(){
							var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 549, "resize");
					    	commonWritePopupOnload = function(){
								requestProcess("RECREATE");
					    	};
						}
						Common.open("", "checkFido", Common.getDic("lbl_RequestUserAuth"), "/covicore/control/checkFido.do?logonID="+Common.getSession("UR_Code")+"&authType=Approval", "400px", "510px", "iframe", true, null, null, true); //사용자 본인인증 요청
					}else{
						if(chkCommentWrite(apvToken)){
							_g_password = aesUtil.encrypt(proaas, proaaI, proaapp, apvToken);
							// 결재 진행
							var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 549, "resize");
					    	commonWritePopupOnload = function(){
								requestProcess("RECREATE");
					    	};
						}else{
							// 비밀번호 틀림
							Common.Warning(Common.getDic("msg_PasswordChange_02"));
						}
					}
				}
			});
		
	    	// 생체인증 버튼 제어
	        if (useFido == "Y") {
	            setTimeout(function () {
	                var oTargetObj = $("#alert_container").find("#popup_e1")
	                $(oTargetObj).find("strong").text(Common.getDic("lbl_Biometrics"));
	                $(oTargetObj).show();
	            }, 350);
	        }
	    }else {
	    	var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 549, "resize");
	    	commonWritePopupOnload = function(){
				requestProcess("RECREATE");
	    	};
	    }
	}
}

doButtonCase['btReUse'] = function (oBtn, oVar) {//재사용
    if (window.location.href.substr(-1) === "#") {
        // script 실행후 url뒤에 붙어있는 #제거 
    	window.location.href = window.location.href.substring(0, window.location.href.length - 1).replace("&editMode=", "").replace("&editMode=N", "").replace("&reuse=", "") + "&editMode=Y&reuse=Y";
    } else {
    	window.location.href = window.location.href.replace("&editMode=", "").replace("&editMode=N", "").replace("&reuse=", "") + "&editMode=Y&reuse=Y";
    }
    return false;
}

//(본사운영) 출장복명서 작성 (btBizrip)
doButtonCase['btBizrip'] = function (oBtn, oVar) {
    window.location.href = "approval_Form.do?formPrefix=WF_FROM_BIZTRIP_REPORT&mode=DRAFT&RequestFormInstID=" + getInfo("FormInstanceInfo.FormInstID");
}

//(본사운영) 프로젝트 집행계획서 작성
doButtonCase['btnExecPlan'] = function (oBtn, oVar) {
    window.location.href = "approval_Form.do?formPrefix=WF_FORM_PROJECT_EXECPLAN&mode=DRAFT&RequestFormInstID=" + getInfo("FormInstanceInfo.FormInstID");
}

//(본사운영) 휴가취소 신청서 버튼
doButtonCase['btVacationCancle'] = function (oBtn, oVar) {

    var VacationCancelForm = Common.getBaseConfig("VacationForm").toString().split("^")[0];

    var strURL = "approval_Form.do?formPrefix=" + VacationCancelForm + "&mode=DRAFT&RequestFormInstID=" + getInfo("FormInstanceInfo.FormInstID");

    var iWidth = 790;
    var iHeight = window.screen.height - 82;

    CFN_OpenWindow(strURL, "VacForm", iWidth, iHeight, "fix");
}

doButtonCase['btReceiptView'] = function (oBtn, oVar) {//수신현황조회
    oVar.iHeight = 480; oVar.iWidth = 1040;
    oVar.sSize = "scrollbars=no";
    
    oVar.sUrl = "goReceiptReadListPage.do?ParentProcessID=" + getInfo("ProcessInfo.ProcessID") + "&ProcessID=" + getInfo("ProcessInfo.ProcessID") + "&FormInstID=" + getInfo("FormInstanceInfo.FormInstID"); //+ "&getInfoValue=" + getInfoValue;   
}

doButtonCase['btForward'] = function (oBtn, oVar) {//문서전달
	var sMessage = Common.getDic("msg_apv_197");
	
	// 보류된 문서인지 체크 - 보류 문서는 전달 시, 보류 내용 사라짐
	if(getInfo("ProcessInfo.ProcessDescription.IsReserved") == "Y") {
		sMessage = Common.getDic("msg_apv_holdForward") + "\n" + sMessage; // 해당 양식은 보류된 문서입니다. [확인]을 누르면 보류를 취소하고 전달합니다.
		
		// 보류 결재선 초기화 처리
    	var oApvList = $.parseJSON(document.getElementById("APVLIST").value);
    	var oCurrentOUNode = $$(oApvList).find("steps > division:has(>taskinfo[status='pending'])");

    	var oPendingNode = $$(oCurrentOUNode).find("step").find("ou>person>taskinfo[status='reserved']");
        if (oPendingNode.length != 0) {
        	$$(oPendingNode).attr("status", "pending");
        	$$(oPendingNode).attr("result", "pending");
        	
        	$$(oPendingNode).find("comment").remove(); // 보류 의견 삭제
        	
        	//document.getElementById("APVLIST").value = JSON.stringify(oApvList);
        	setInfo("ApprovalLine", oApvList);
        }
	}
	
	//window.open의 경우 예외 처리 
    if (openMode == "L" || openMode == "P") {
        Common.Confirm(sMessage, "Confirmation Dialog", function (result) {		//gMessage197
            if (result) {
                if ((getInfo("Request.loct") == "REDRAFT") && (getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT")) { m_sAddList = 'chargegroup'; } else { m_sAddList = 'charge'; } Open_Forward(m_sAddList);
            }
            else {

            }
        });
    } else {
    	if(CFN_GetQueryString("isMobile") != "Y" && !_mobile){    		
	        Common.Confirm(sMessage, "Confirmation Dialog", function (result) {		//gMessage197
	            if (result) {
	                if ((getInfo("Request.loct") == "REDRAFT") && (getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT")) { m_sAddList = 'chargegroup'; } else { m_sAddList = 'charge'; }
	                document.getElementById("ACTIONINDEX").value = "FORWARD";
	                Open_Forward(m_sAddList);
	            }
	            else {
	
	            }
	        });
    	} else {
    		if(confirm(mobile_comm_getDic("msg_apv_197"))) {
    			if ((getInfo("Request.loct") == "REDRAFT") && (getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT")) { m_sAddList = 'chargegroup'; } else { m_sAddList = 'charge'; }
                document.getElementById("ACTIONINDEX").value = "FORWARD";
                mobile_approval_openOrg(m_sAddList);
    		}
    	}
    }
}

doButtonCase['btApproved'] = function (oBtn, oVar) {//승인
    m_sReqMode = "APPROVE";
    
    // 양식내 결재선 사용시 승인전에 결재선 재 정리
	if (getInfo('SchemaContext.scFormAddInApvLine.isUse') == 'Y' && getInfo('Request.templatemode') == 'Write') {
		if (!addInApvLine.setAppLineData(true)) return;
	}
    
    if(getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "AUDIT")
    	document.getElementById("ACTIONINDEX").value = "APPROVAL";		//"approve";
	else if(getInfo("Request.mode") == "PCONSULT")
		document.getElementById("ACTIONINDEX").value = "AGREE";
    
    if(CFN_GetQueryString("isMobile") != "Y"){
	    if (evaluateForm()) {
	    	var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 549, "resize");
	    	
	    	commonWritePopupOnload = function(){
	    		requestProcess("APPROVE");
	    	};
	    }
	}else{
        requestProcess("APPROVE");
	}
}

doButtonCase['btReject'] = function (oBtn, oVar) {//반려
	if(getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT")
		m_sReqMode = "CHARGE";
	else
		m_sReqMode = "APPROVE";
    
    // 양식내 결재선 사용시 반려전에 결재선 재 정리
	if (getInfo('SchemaContext.scFormAddInApvLine.isUse') == 'Y' && getInfo('Request.templatemode') == 'Write') {
		if (!addInApvLine.setAppLineData(true)) return;
	}
    
	if(getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "RECAPPROVAL"  || getInfo("Request.mode") == "AUDIT")
    	document.getElementById("ACTIONINDEX").value = "REJECT";		 //"reject";
	else if(getInfo("Request.mode") == "PCONSULT")
		document.getElementById("ACTIONINDEX").value = "DISAGREE";
    
    if(CFN_GetQueryString("isMobile") != "Y"){
	    if (evaluateForm()) {
	    	var popupHeight = 349;
	    	if(Common.getBaseConfig("useRejectCommentAttach") == "Y") {
	    		popupHeight = 549;
	    	}
	    	var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, popupHeight, "resize");
	    	
	    	commonWritePopupOnload = function(){
				requestProcess("APPROVE");
	    	};
	    }
    }else{
    	requestProcess("APPROVE");
    }
    //반려
}

//대성, 최종결재자 사전승인
doButtonCase['btApprovedLast'] = function (oBtn, oVar) {//승인
	m_sReqMode = "APPROVAL";

	var m_evalJSON_tmp = $.parseJSON(document.getElementById("APVLIST").value);
    var elmRoot = $(m_evalJSON_tmp).find("steps");
    m_ApvPersonObj = $$(elmRoot).find("division>step>ou>person").has("taskinfo[status='pending'], taskinfo[status='inactive']");
	
    m_ApvPersonCnt = m_ApvPersonObj.length - 1;
	
    var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 549, "resize");
	
	commonWritePopupOnload = function(){
		autoAllApproved();
	};
}

doButtonCase['btRejectLast'] = function (oBtn, oVar) {//반려
	m_sReqMode = "REJECT";
	
	// 양식내 결재선 사용시 반려전에 결재선 재 정리
	if (getInfo('SchemaContext.scFormAddInApvLine.isUse') == 'Y' && getInfo('Request.templatemode') == 'Write') {
		if (!addInApvLine.setAppLineData(true)) return;
	}
	
	// 선반려의 경우, 최종결재자 이전은 승인, 최종결재자는 반려처리한다.
	var m_evalJSON_tmp = $.parseJSON(document.getElementById("APVLIST").value);
    var elmRoot = $(m_evalJSON_tmp).find("steps");
    m_ApvPersonObj = $$(elmRoot).find("division>step>ou>person").has("taskinfo[status='pending'], taskinfo[status='inactive']");
	
    m_ApvPersonCnt = m_ApvPersonObj.length - 1;
    
	var popupHeight = 349;
	if(Common.getBaseConfig("useRejectCommentAttach") == "Y") {
		popupHeight = 549;
	}
    var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, popupHeight, "resize");
	
	commonWritePopupOnload = function(){
		autoAllApproved();
	};
}

doButtonCase['btHold'] = function (oBtn, oVar) {//보류	
    m_sReqMode = "RESERVE";
    document.getElementById("ACTIONINDEX").value = "RESERVE";	//"reserve";
    if(CFN_GetQueryString("isMobile") != "Y"){
		var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 349, "resize");
		
		commonWritePopupOnload = function(){
			requestProcessReserve();
		};
    } else {
		requestProcessReserve();    	
    }
}

doButtonCase['btRejectedto'] = function (oBtn, oVar) {//지정반송
    m_sReqMode = "APPROVE";
    document.getElementById("ACTIONINDEX").value = "REJECTTO"; //"rejectedto";
    
    // 양식내 결재선 사용시 반려전에 결재선 재 정리
	if (getInfo('SchemaContext.scFormAddInApvLine.isUse') == 'Y' && getInfo('Request.templatemode') == 'Write') {
		if (!addInApvLine.setAppLineData(true)) return;
	}
	
    //지정반송가능여부 체크	if (fn_checkrejectedtoA())
    if (evaluateForm()) {
    	var popupHeight = 349;
    	if(Common.getBaseConfig("useRejectCommentAttach") == "Y") {
    		popupHeight = 549;
    	}
    	var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, popupHeight, "resize");
    	
    	commonWritePopupOnload = function(){
			requestProcess("APPROVE");
    	};
    } else {
        document.getElementById("ACTIONINDEX").value = "";
    }
}

doButtonCase['btRejectedtoDept'] = function (oBtn, oVar) {//부서 내 반송(수신함으로)
	m_sReqMode = "APPROVE";
    document.getElementById("ACTIONINDEX").value = "REJECTTODEPT"; //"rejectedtodept";
    
    if (evaluateForm()) {
    	var popupHeight = 349;
    	if(Common.getBaseConfig("useRejectCommentAttach") == "Y") {
    		popupHeight = 549;
    	}
    	var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, popupHeight, "resize");
    	
    	commonWritePopupOnload = function(){
			requestProcess("APPROVE");
    	};
    } else {
        document.getElementById("ACTIONINDEX").value = "";
    }
}

/* 추가의견 */
doButtonCase['btComment'] = function (oBtn, oVar) {
	CFN_OpenWindow("CommentWrite.do?reqType="+"completeComment", "", 540, 549, "resize");
}

doButtonCase['btCommentView'] = function (oBtn, oVar) {
    oVar.iHeight = 500; oVar.iWidth = 540;
    $("#btCommentView").attr("class", "");
    var isArchived = CFN_GetQueryString("archived");
    var isBstored = CFN_GetQueryString("bstored");
    if(isArchived == "undefined" || isArchived == "") isArchived = "false";
    if(isBstored == "undefined" || isBstored == "") isBstored = "false";
    var sUrl = "goCommentViewPage.do";
    
    sUrl += "?FormInstID=" + getInfo("FormInstanceInfo.FormInstID");
    sUrl += "&ProcessID=" + getInfo("ProcessInfo.ProcessID");
    sUrl += "&archived=" + isArchived;
    sUrl += "&bstored=" + isBstored;
    
    oVar.sUrl = sUrl;
}

doButtonCase['btCirculate_View'] = function (oBtn, oVar) {
    oVar.iHeight = 480; oVar.iWidth = 1040;
    oVar.sUrl = "goCirculationReadListPage.do?FormInstID=" + getInfo("FormInstanceInfo.FormInstID");
}

//PC저장
doButtonCase['btPcSave'] = function (oBtn, oVar) {
	return PcSave(oVar, false);
}

//결재문서 PC저장
function PcSave(oVar, bmail) {
	//양식 특정함수 포함된 내역 빼기
    bDisplayOnly = true;
    bPresenceView = false;
    
    printDiv = getBodyHTML("PcSave");

    if(IsWideOpenFormCheck(getInfo("FormInfo.FormPrefix"), getInfo("FormInfo.FormID")) == true){
    	oVar.iWidth = 1070;
	}else{
		oVar.iWidth = 790;
	}
    oVar.iHeight = 350;

    var fileName = getInfo("FormInstanceInfo.Subject");
    
    if(fileName == ""){
    	fileName = getInfo("FormInfo.FormName");
    }else{
    	fileName += "_"+getInfo("FormInstanceInfo.DocNo");
    }
    
	oVar.sUrl = "";
    if(bmail) {
    	var useFileID = "N";
    	if(Common.getBaseConfig("isUseExchMail") == "Y") {
    		useFileID = "Y";
    	}
    	
    	// 팝업 띄우지 않고 ajax 호출
    	Common.Progress(Common.getDic("msg_pdf_converting"));//"PDF 변환중입니다. 잠시만 기다려주세요.";
    	$.ajax({
    		url:"common/createPdf.do",
    		type:"post",
    		disableProgress:true,
    		data: {
    			"filename": encodeURIComponent(fileName),
    			"fiid": getInfo("FormInstanceInfo.FormInstID"),
    			"txtHtml": printDiv.replace("<thead>","")/*.replace("min-height","height")*/,
    			"useFileID": useFileID
    		},
    		async:true,
    		success:function (data) {
    			if(data.status == "SUCCESS"){
					setTimeout(function(){Common.AlertClose();});
    				setInfo("savePdfInfo", data);
    				CallBackSendMailInBody();
    			}
    		},
    		error:function(response, status, error){
    			setTimeout(function(){Common.AlertClose();});
    			CFN_ErrorAjax("common/createPdf.do", response, status, error);
    		}
    	});
    }
    else {
		// 변환시간이 소요될 경우 대비하여 서버응답(다운로드)시작 전까지 Progress 처리를 위해 XMLHttpRequest 사용함.
		var downloadType = "AJAX"; // AJAX/FORM
		var url  = "";
		if(Common.getBaseConfig("ApprovalPCSaveOption") === "ALL"){	  
	    	url = "common/createPCSaveZip.do";
		} else {
			url = "/approval/common/printPdf.do";	    	
    	}
		if(downloadType == "AJAX") {	
	    	Common.Progress(Common.getDic("msg_pdf_converting"));//"PDF 변환중입니다. 잠시만 기다려주세요.";
	    	
		    var form = new FormData();
			form.append("filename" , fileName);
			form.append("fiid" , getInfo("FormInstanceInfo.FormInstID"));
			form.append("txtHtml" , printDiv.replace("<thead>","")/*.replace("min-height","height")*/);
			form.append("bstored" , CFN_GetQueryString("bstored"));
			
		    var xhr = new XMLHttpRequest();
		    xhr.onreadystatechange = function() {
		        if(xhr.readyState == 4) {
					setTimeout(function(){Common.AlertClose();});
		            if(xhr.status == 200) {
				      	var blob = xhr.response;
				      	//파일저장
				      	var fileName = "Download_PDF";
				      	var disposition = xhr.getResponseHeader("Content-Disposition");
						if (disposition && disposition.indexOf("attachment") !== -1) {
						    var filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/;
						    var matches = filenameRegex.exec(disposition);
						
						    if (matches != null && matches[1]) {
						        fileName = decodeURI(matches[1].replace(/['"]/g, ""));
						    }
						}

			        	var link = document.createElement('a'); 
			        	link.href = window.URL.createObjectURL(blob); 
			        	link.download = fileName;
			        	link.click();
			        	link.remove();
				      	
		            }
		        } else if(xhr.readyState == 2) {
		            if(xhr.status == 200) {
		                xhr.responseType = "blob";
		            } else {
		                xhr.responseType = "text";
		            }
		        }
		    };
		    xhr.open("POST", url, true);
		    xhr.send(form);
		}else{
			//  일반다운로드, 서버에서 파일생성완료 전까지 Inticator  없이 대기한다.
	    	var _form = $("<form>", {method : "post"});
	    	$(_form).attr("action", url).hide();
	    	$(_form)
	    		.append($("<input>",{type : "hidden"}).prop("name", "filename").val(fileName))
	    		.append($("<input>",{type : "hidden"}).prop("name", "fiid").val(getInfo("FormInstanceInfo.FormInstID")))
	    		.append($("<input>",{type : "hidden"}).prop("name", "txtHtml").val(printDiv.replace("<thead>","")/*.replace("min-height","height")*/))
	    		.append($("<input>",{type : "hidden"}).prop("name", "bstored").val(CFN_GetQueryString("bstored")));
	    	$("body").append(_form);
	    	$(_form).submit();
	    	$(_form).remove();
			
		}
    }
    
    //다시 올려주기
    bDisplayOnly = false;
    bPresenceView = true;

    return false;
}

/*검토 Start*/
//검토 요청
doButtonCase['btConsultReq'] = function (oBtn, oVar) {
	var sCallType = "B9"; //B1:사용자 선택(3열-1명만),C1:그룹 선택(3열-1개만)
	var sTarget = "U"; //U:사용자,D:부서
	if (openMode == "L") {
		parent._CallBackMethod2 = callBack_ConsultReq;
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&szObject=&type="+sCallType+"&setParamData=_setParamdata","1060px","580px","iframe",true,null,null,true); 
	} else {
		CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=callBack_ConsultReq&szObject=&type="+sCallType+"&setParamData=_setParamdata", "", "1060px", "580px");
	}
}

//검토 요청 취소
doButtonCase['btConsultReqCancel'] = function (oBtn, oVar) {
	 var confirmMsg = Common.getDic("msg_apv_cancelConsultation");
	    Common.Confirm(confirmMsg, "", function (result) {
	        if (result) {
	        	if(CFN_GetQueryString("bserial") == "true") {
	        		parent.setStateSerialApprovalList("btConsultReqCancel", $("#btConsultReqCancel").val(), getInfo("Request.mode"), "");
	        	} else {
		        	var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 349, "resize");
		        	
		        	commonWritePopupOnload = function(){
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
		                			CFN_ErrorAjax("consultationRequstCancel.do", response, status, error);
		            			}
			            	});
			    		} catch (e) {
			    			Common.Error(e.message);
			    		}
		        	};
	        	}
	        } else {
	            return;
	        }
	    });
}

doButtonCase['btCAgree'] = function (oBtn, oVar) {
	var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 549, "resize");
	
	commonWritePopupOnload = function(){
  	var sAddage = {};
  	$.extend(sAddage, getDefaultJSON("CONSULTATION"));
  	// id 가 null 인 경우, 회수 시 오류 발생하여 수정함.
      $("*[data-type='dField']").each(function (i, obj) {
      	if ($(obj).attr("id") != null && $(obj).attr("id") != "") {
          	$.extend(sAddage, makeNode($(obj).attr("id"), $(obj).val()));
          }
      });
  	$.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
  	$.extend(sAddage, makeNode("actionComment_Attach", document.getElementById("ACTIONCOMMENT_ATTACH").value));
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
      			//ToggleLoadingImage();
      		},
      		error:function(response, status, error){
  				CFN_ErrorAjax("consultation.do", response, status, error);
  			}
      	});
		} catch (e) {
			Common.Error(e.message);
		}
	};
}

doButtonCase['btCDisagree'] = function (oBtn, oVar) {
	var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 549, "resize");
	
	commonWritePopupOnload = function(){
  	var sAddage = {};
  	$.extend(sAddage, getDefaultJSON("CONSULTATION"));
  	// id 가 null 인 경우, 회수 시 오류 발생하여 수정함.
      $("*[data-type='dField']").each(function (i, obj) {
      	if ($(obj).attr("id") != null && $(obj).attr("id") != "") {
          	$.extend(sAddage, makeNode($(obj).attr("id"), $(obj).val()));
          }
      });
  	$.extend(sAddage, makeNode("actionComment", document.getElementById("ACTIONCOMMENT").value));
  	$.extend(sAddage, makeNode("actionComment_Attach", document.getElementById("ACTIONCOMMENT_ATTACH").value));
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
      			//ToggleLoadingImage();
      		},
      		error:function(response, status, error){
  				CFN_ErrorAjax("consultation.do", response, status, error);
  			}
      	});
		} catch (e) {
			Common.Error(e.message);
		}
	};
}

doButtonCase['btConsultationCommentView'] = function (oBtn, oVar) {
  oVar.iHeight = 420; oVar.iWidth = 820;
  var isArchived = CFN_GetQueryString("archived");
  if(isArchived == "undefined" || isArchived == "") isArchived = "false";
  
  var sUrl = "goConsultationCommentViewPage.do";
  
  sUrl += "?FormInstID=" + getInfo("FormInstanceInfo.FormInstID");
  sUrl += "&ProcessID=" + getInfo("FormInstanceInfo.ProcessID");
  sUrl += "&WorkItemID=" + getInfo("Request.workitemID");
  sUrl += "&archived=" + isArchived;
  sUrl += "&Subkind=" + getInfo("Request.subkind");
	sUrl += "&UserCode=" + getInfo("Request.userCode");
  
  oVar.sUrl = sUrl;
}

//검토자 변경
doButtonCase['btConsultReqModify'] = function (oBtn, oVar) {
	var sCallType = "B9"; //B1:사용자 선택(3열-1명만),C1:그룹 선택(3열-1개만)
	var sTarget = "U"; //U:사용자,D:부서
	
	var userParams = ConsultPendingUsers();
	userParams = { selected : userParams.map(function(item){ return $$(item).attr("code") }).join(";") };
	
	if (openMode == "L") {
		parent._CallBackMethod2 = callBack_ConsultReqModify;
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&szObject=&type="+sCallType+"&setParamData=_setParamdata&userParams="+encodeURIComponent(JSON.stringify(userParams)),"1060px","580px","iframe",true,null,null,true); 
	} else {
		CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=callBack_ConsultReqModify&szObject=&type="+sCallType+"&setParamData=_setParamdata&userParams="+encodeURIComponent(JSON.stringify(userParams)), "", "1060px", "580px");
	}
}

//재검토요청
doButtonCase['btReConsultReq'] = function (oBtn, oVar) {
	var sCallType = "B9"; //B1:사용자 선택(3열-1명만),C1:그룹 선택(3열-1개만)
	var sTarget = "U"; //U:사용자,D:부서
	if (openMode == "L") {
		parent._CallBackMethod2 = callBack_ReConsultReq;
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&szObject=&type="+sCallType+"&setParamData=_setParamdata","1060px","580px","iframe",true,null,null,true); 
	} else {
		CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=callBack_ReConsultReq&szObject=&type="+sCallType+"&setParamData=_setParamdata", "", "1060px", "580px");
	}
}

function callBack_ConsultReq(pStrItemInfo) {
	funConsultReq(pStrItemInfo, 'ConsultReq');
}

function callBack_ReConsultReq(pStrItemInfo) {
	funConsultReq(pStrItemInfo, 'ReConsultReq');
}

function funConsultReq(pStrItemInfo, consultParamData){
	var oJSON = $.parseJSON(pStrItemInfo);
	oJSON.item = oJSON.item.filter(function(item) { if(item.AN !== getInfo("Request.userCode")) return item; });
  
	if(oJSON.item.length > 0){
	    var chargers = oJSON.item.map(function(item, idx){ return CFN_GetDicInfo(item.DN); }).join();
	    var confirmMsg = Common.getDic("msg_requestConsultToUsers").replace("{0}", chargers); //"다음 결재자들에게 검토 요청을 하시겠습니까?\n[{0}]".replace("{0}", chargers);
	    Common.Confirm(confirmMsg, "", function (result) {
	        if (result) {
	        	if(CFN_GetQueryString("bserial") == "true") {
	        		parent.setStateSerialApprovalList("btConsultReq", $("#btConsultReq").val(), getInfo("Request.mode"), oJSON.item);
	        	} else {
		        	// 의견 작성
		        	var commonWritePopup = CFN_OpenWindow("CommentWrite.do", "", 540, 349, "resize");
			    	
			    	commonWritePopupOnload = function(){
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
			        	$.extend(sAddage, makeNode("consultUsers", oJSON.item));
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
			            			document.getElementById('btConsultReq').style.display = "none";
			            			callProcessEndScriptFunction(res);
			            			//ToggleLoadingImage();
			            		},
			            		error:function(response, status, error){
			        				CFN_ErrorAjax("consultationRequst.do", response, status, error);
			        			}
			            	});
			    		} catch (e) {
			    			Common.Error(e.message);
			    		}
			    	};
	        	}
	        } else {
	            return;
	        }
	    });
	} else {
		Common.Warning(Common.getDic("msg_apv_noSelectedConsultUsers"));//"검토를 요청할 사용자가 선택되지 않았습니다."
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

function callBack_ConsultReqModify(pStrItemInfo) {
	var oJSON = $.parseJSON(pStrItemInfo);
	var currSelectUser = oJSON.item.map(function(item) {return item.AN});
	var pendingUsersJson = ConsultPendingUsers();
	var arrOrgUserCode = pendingUsersJson.map(function(item){ return $$(item).attr("code") }).join();
	
	var deleteInfos = pendingUsersJson.filter(function(item) { if(!currSelectUser.join().includes(item.code)) return item; });
	oJSON.item = oJSON.item.filter(function(item) { if(item.AN !== getInfo("Request.userCode") && !(arrOrgUserCode.includes(item.AN))) return item; });

	if(currSelectUser.length > 0){
		var confirmMsg = Common.getDic("msg_modifyConsultToUsers"); //검토자를 변경하시겠습니까?
	    Common.Confirm(confirmMsg, "", function (result) {
	    	if (result) {
	        	if(CFN_GetQueryString("bserial") == "true") {
	        		parent.setStateSerialApprovalList("btConsultReq", $("#btConsultReq").val(), getInfo("Request.mode"), oJSON.item);
	        	} else {
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
		            			document.getElementById('btConsultReq').style.display = "none";
		            			callProcessEndScriptFunction(res);
		            			//ToggleLoadingImage();
		            		},
		            		error:function(response, status, error){
		        				CFN_ErrorAjax("consultationRequst.do", response, status, error);
		        			}
		            	});
		    		} catch (e) {
		    			Common.Error(e.message);
		    		}
	        	}
	        } else {
	            return;
	        }
	    });
	} else {
		Common.Warning(Common.getDic("msg_apv_noSelectedConsultUsers"));//"검토를 요청할 사용자가 선택되지 않았습니다."
	}
}

// 메일보내기
function CallBackSendMailInBody() {
	//ToggleLoadingImage();
    
	if(Common.getBaseConfig("isUseExchMail") == "Y") {
		// 파일 리스트 세팅
		var fileArray = new Array();
		var approvalData = getAttachFileBody();
		
		// 첨부 파일
		$(approvalData.AttachFileInfo).each(function(nIdx, value) {
			fileArray.push(exch_fileList(value));
		});
		
		// 전송 데이터 세팅
		MailJsonData = {
		  "Token": GetEncryptToken(), // 인증용 JWT 토큰
		  "Subject": approvalData.subject, // 메일 제목
		  "Body": "", // 메일 본문
		  "To": [], // 받는 사람
		  "Cc": [], // 참조
		  "Bcc": [], // 숨은 참조
		  "Attachment": fileArray // 첨부 파일
		};
		
		exch_mailSend(MailJsonData);
	} else {
		window.open("/mail/bizcard/goMailWritePopup.do?"
	            +"callBackFunc=mailWritePopupCallback"
	            +"&callMenu=" + "Approval"
	            + "&userMail=" + Common.getSession("UR_Mail") + "&inputUserId=" + Common.getSession("DN_Code") + "_" + Common.getSession("UR_Code") + "&popup=Y",
	            "ApprovalWritePopup", "height=800, width=1000, resizable=yes");
	}
}

function exch_fileList(value) {
	var origin = $(location).attr('origin');
	
	fileItem = new Object();
	fileItem.Name = value.fileName;
	fileItem.Url = origin + "/groupware/portal/exchFileDown.do?fileID="+value.fileID;
	fileItem.IsInline = "N";
	
	return fileItem;
}

// 메일보내기에 넘겨 줄 첨부파일 정보(본문 pdf + 기존 첨부)
function getAttachFileBody() {
	var result = {};
	var arrFileInfo = new Array();
	
	/* fileid로 경로 조회하도록 변경
	var strOS = Common.getGlobalProperties("Globals.OsType");
	var attachRootPath = "";
	
	if (strOS == "UNIX") {
		attachRootPath = Common.getGlobalProperties("attachUNIX.path");
	} else {
		attachRootPath = Common.getGlobalProperties("attachWINDOW.path");
	}
	attachRootPath = attachRootPath + Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
	
	var baseSavePath = attachRootPath + Common.getBaseConfig("ApprovalAttach_SavePath");
	*/
    var strFileinfo = getInfo("FormInstanceInfo.AttachFileInfo");
    if (strFileinfo != "" && strFileinfo != undefined) {
        var oFileinfo = $.parseJSON(getInfo("FileInfos"));
        
        $(oFileinfo).each(function(j, obj) {
        	var oFileInfoList = {};
			oFileInfoList.fileName = obj.FileName;
            oFileInfoList.saveFileName = obj.SavedName;
            //oFileInfoList.savePath = baseSavePath + obj.FilePath;
            oFileInfoList.savePath = "";
            oFileInfoList.fileID = obj.FileID;
            oFileInfoList.fileSize = obj.Size;
            
            arrFileInfo.push(oFileInfoList);
		});
    }
    
    var objPdfInfo = $.parseJSON(getInfo("savePdfInfo"));
    objPdfInfo.fileName = decodeURIComponent(objPdfInfo.fileName);
    	
    arrFileInfo.push(objPdfInfo); // pdf 정보
    
    result.subject = getInfo("FormInstanceInfo.Subject");
    result.AttachFileInfo = arrFileInfo; // array 안에 json
    
    return result;
}

/*
 * 기안취소(관리자) 비사용 doButtonCase['btAdminAbort'] = function (oBtn, oVar) {//관리자
 * 강제기안취소200808 requestProcess("WITHDRAW"); }
 */

/*
 * 문서삭제 버튼 비사용 doButtonCase['btDeleteDoc'] = function (oBtn, oVar) {//문서삭제200808
 * requestProcess("DELETEDOC"); }
 */

doButtonCase['btForcedConsent'] = function (oBtn, oVar) {//강제합의200808
    Common.Confirm(gMessage77, "Confirmation Dialog", function (result) {
        if (result) {
            forcedConsent();
        } else {
            return;
        }
    });
}

doButtonCase['btMailSend'] = function (oBtn, oVar) {
	//ToggleLoadingImage();
    PcSave(oVar, true);
    
    // async 처리
	// CallBackSendMailInBody();
}

doButtonCase['btShared'] = function (oBtn, oVar) {  //참조 확인 버튼 Event
    // 미구현
}

doButtonCase['btApproverChangeReview'] = function (oBtn, oVar) {// btApproverChangeReview
    m_sAddList = 'ChangeReview';
    Open_Forward(m_sAddList);
}

doButtonCase['btPreList'] = function (oBtn, oVar) {
    fnGoPreNextList('btPreList');
}

doButtonCase['btNextList'] = function (oBtn, oVar) {
    fnGoPreNextList('btNextList');
}

doButtonCase['btDocListSave'] = function (oBtn, oVar) {//문서대장 저장
    if (document.getElementById("Subject").value == "") {
        var subject = CFN_GetDicInfo(getInfo("AppInfo.usnm_multi")) + " - " + CFN_GetDicInfo(getInfo("FormInfo.FormName"));
        document.getElementById("Subject").value = subject;
    }
    
    setFormAttachFileInfo();
    
    document.getElementById("ACTIONINDEX").value = "DOCLISTSAVE";
    requestProcess("DOCLISTSAVE");
}

doButtonCase['btExitPreView'] = function (oBtn, oVar) {  // 기존 미리보기 창의 top.colose 에서 레이어 팝업 or 윈도우 팝업을 구분 하여 닫기 
    if (CFN_GetQueryString("openID") == getInfo("FormInfo.FormID") || (CFN_GetQueryString("editMode") == 'Y') && CFN_GetQueryString("CFN_OpenWindowName") == 'undefined') {
        var openName = CFN_GetQueryString("openID");
        parent.Common.Close("DivPop_" + openName);
    } else {
        window.close();
    }
}

doButtonCase['btnRuleApv'] = function (oBtn, oVar) {  //
    oVar.iHeight = 400; oVar.iWidth = 1000;
    oVar.sSize = "scroll";
    oVar.sUrl = "/approval/getApprovalLinePopup.do";
}

doButtonCase['btGovRecDept'] = function (oBtn, oVar) {//대외수신처관리
	oVar.iHeight = 580; oVar.iWidth = 1110;
	oVar.sUrl = "/approval/govdoc/deployline.do?itemnum=999";
}

doButtonCase['btEvidPreview'] = function (oBtn, oVar) {
	//e-Accounting 증빙 미리보기 영역 show/hide
	evidPreviewEAccount();
}

//근무일정 변경 신청서 버튼
doButtonCase['btWorkSchChange'] = function (oBtn, oVar) {
    var strURL = "approval_Form.do?formPrefix=" + getInfo("FormInfo.FormPrefix") + "&mode=DRAFT&RequestFormInstID=" + getInfo("FormInstanceInfo.FormInstID") + "&RequestProcessID=" + getInfo("FormInstanceInfo.ProcessID");

    var iWidth = 790;
    var iHeight = window.screen.height - 82;

    CFN_OpenWindow(strURL, "WorkSchForm", iWidth, iHeight, "fix");
}

//기타근무 변경 신청서 버튼
doButtonCase['btOtherWorkChange'] = function (oBtn, oVar) {
	var strURL = "approval_Form.do?formPrefix=" + getInfo("FormInfo.FormPrefix") + "&mode=DRAFT&RequestFormInstID=" + getInfo("FormInstanceInfo.FormInstID") + "&RequestProcessID=" + getInfo("FormInstanceInfo.ProcessID");
	
	var iWidth = 790;
	var iHeight = window.screen.height - 82;
	
	CFN_OpenWindow(strURL, "OtherWorkForm", iWidth, iHeight, "fix");
}

//연장근무 변경 신청서 버튼
doButtonCase['btOvertimeWorkChange'] = function (oBtn, oVar) {
	var strURL = "approval_Form.do?formPrefix=" + getInfo("FormInfo.FormPrefix") + "&mode=DRAFT&RequestFormInstID=" + getInfo("FormInstanceInfo.FormInstID") + "&RequestProcessID=" + getInfo("FormInstanceInfo.ProcessID");
	
	var iWidth = 790;
	var iHeight = window.screen.height - 82;
	
	CFN_OpenWindow(strURL, "OvertimeWorkForm", iWidth, iHeight, "fix");
}

//휴일근무 변경 신청서 버튼
doButtonCase['btHolidayWorkChange'] = function (oBtn, oVar) {
	var strURL = "approval_Form.do?formPrefix=" + getInfo("FormInfo.FormPrefix") + "&mode=DRAFT&RequestFormInstID=" + getInfo("FormInstanceInfo.FormInstID") + "&RequestProcessID=" + getInfo("FormInstanceInfo.ProcessID");
	
	var iWidth = 790;
	var iHeight = window.screen.height - 82;
	
	CFN_OpenWindow(strURL, "HolidayWorkForm", iWidth, iHeight, "fix");
}

/**문서유통 함수 시작**/
var bCompensate,sParam;

doButtonCase['btGovDocsSend'] = function (oBtn, oVar) {// 전자문서발송
    Common.Confirm("전자문서 형태로 발송합니다.", "Confirmation Dialog", function (result) { result && callPacker() });
}

doButtonCase['btGovDocsReSend'] = function (oBtn, oVar) {// 전자문서 재발송
	Common.Confirm("전자문서 형태로 재발송합니다.", "Confirmation Dialog", function (result) { result && callPacker("resend") });	
}

doButtonCase['btGovSendCancel'] = function (oBtn, oVar) {//발송취소
    Common.Confirm("발송 취소를 합니다.<br />발송취소하더라도, 해당 문서는 [발송완료]메뉴로 이동합니다.", "Confirmation Dialog", function (result) {
        if (result) {
			//미구현
            //GovDocsCirculation("SENDABORT", "send");
        } else {
            return;
        }
    });
}

doButtonCase['btGovDocsOffline'] = function (oBtn, oVar) {//Offline

    Common.Confirm("offline으로 인쇄하여 발송하겠다는 의미입니다.<br />발송했다고 보고, 해당 문서는 [발송완료]메뉴로 이동합니다. ", "Confirmation Dialog", function (result) {
        if (result) {
			//미구현
            //GovDocsCirculation("SENDOFFLINE", "send");
			// 새 창을 띄어 진행
        } else {
            return;
        }
    });
}

//대외공문 반송처리
doButtonCase['btRejectOut'] = function (oBtn, oVar) {// 반송
	document.getElementById("ACTIONINDEX").value = "REJECT";
	
    if(CFN_GetQueryString("isMobile") != "Y"){
	    // if (evaluateForm()) {
	    	Common.Confirm("반송하시겠습니까?", "Confirmation Dialog", function (result) {
	            if (result) {
	            	requestProcess("APPROVE");
	            	
	            	// GOV_RECEIVE 테이블 상태 업데이트
	            	updateGovStatusFromApproval();
	            } else {
	                return;
	            }
	        });
	    	
	    // }
    }else{
    	requestProcess("APPROVE");
    }
    // 반려
}

//문서유통 배부함 상태 업데이트
function updateGovStatusFromApproval() {
	var userid = Common.getSession("USERID");
	var docURL = location.href;
	var sendData = {			
			formInstId 	: formJson.FormInstanceInfo.FormInstID												
			,status		: "return"			
			,URCode		: userid
			,docURL		: docURL
		};		
	$.ajax({
		url: "user/updateGovReceiveStatus.do",
		type:"POST",
		data: sendData,		
		success:function (res) {
		},
		error:function(response, status, error){
			// 알림메일 발송 실패 시, 사용자한테 오류메세지 띄우지 않고 진행되도록 함.
			// CFN_ErrorAjax("legacy/setmessage.do", response, status,
			// error);
		}	
		// success:function (data) { deferred.resolve(data);},
		// error:function(response, status, error){ deferred.reject(status); }
	});				
	
}

doButtonCase['btGovDocsDist'] = function (oBtn, oVar) {
    XFN_OrgMapShow_WindowOpen("btSend", "popBody", "txtItem", "wReceive", "OrgMap_CallBack_GovDocsDist", "C9", "Y", "Y", "D", "Approval", "", "");
}

doButtonCase['btGovDocsReceipt'] = function (oBtn, oVar) {//접수	
	govDocAccept();
}

doButtonCase['btGovDocsReject'] = function (oBtn, oVar) {//반송	
	govDocReject();
}
doButtonCase['btGovDocsDeny'] = function (oBtn, oVar) { govDocDeny(); }
doButtonCase['btGovDocsReqReSend'] = function (oBtn, oVar) { govDocReqResend(); }
doButtonCase['btGovDocsManager'] = function (oBtn, oVar) { btSend_Click(); } //배부
doButtonCase['btGovDocsReply'] = function (oBtn, oVar) { govDocReply(); }
doButtonCase['btGovDocsDistInfo'] = function (oBtn, oVar) { govDocDistInfo(); } //배부이력

doButtonCase['btGovDocsManagerReturn'] = function (oBtn, oVar) {//담당반려

    var msg = "반려 하시겠습니까?";

    //대외공문 접수처리 - 수신처로 ACK_RECEIVEACCEPT or ACK_RECEIVEABORT 를 전송하고, WF_PROCESSGOV_RECEIVE 업데이트.
    Common.Confirm(msg, "Confirmation Dialog", function (result) {
        if (result) {
			// 미구현
        } else {
            return;
        }
    });

}

doButtonCase['btOTransView'] = function (oBtn, oVar) { // 대외공문변환	
    (window.navigator.userAgent.toLowerCase().indexOf('firefox') > -1) ? oVar.sSize = "scroll" : oVar.sSize = "fix";

    oVar.iWidth = 790;
    //가로양식
    if (IsWideOpenFormCheck(getInfo("FormInfo.FormPrefix"), getInfo("FormInfo.FormID"))) {
        oVar.iWidth = 1070;
    }
    oVar.iHeight = window.screen.height - 82;
    oVar.sUrl = String(document.location.href);

	var addParam,readType;
	if (getInfo("Request.templatemode") == "Read"){
		addParam = "?mode=COMPLETE&processID=" + formJson.FormInstanceInfo.ProcessID;
		readType = "govpreview";
	}else{
		addParam = "?mode=DRAFT&formID=" + formJson.FormInfo.FormID;
		readType = "govpreviewWrite";
	}
	
    if(getInfo("Request.mode") == "DRAFT" && getInfo("Request.reuse")){
    	var tmpUrl = String(document.location.href);
    	if(tmpUrl.indexOf("?") > -1 && formJson && formJson.FormInfo && formJson.FormInfo.FormID){
    		tmpUrl = tmpUrl.substring(0,tmpUrl.indexOf("?")) + addParam;
    		oVar.sUrl = tmpUrl; 
    	}
    }
    setFormAttachFileInfo(true); // 변경된 첨부파일정보 저장
    oVar.sUrl = oVar.sUrl.replace("FormWrite", "Form"); //바닥 작성창에서 Open할 경우
    if (oVar.sUrl.lastIndexOf("#") == (oVar.sUrl.length - 1)) { oVar.sUrl = oVar.sUrl.substring(0, oVar.sUrl.lastIndexOf("#")); } //url에 #이 포함되어 있음 제거처리
    oVar.sUrl = oVar.sUrl + "&Readtype=" + readType;
    if(CFN_GetQueryString("openID") != "undefined" ){
        oVar.sUrl = oVar.sUrl.split('&');
        oVar.sUrl = oVar.sUrl[0] + oVar.sUrl[1] + oVar.sUrl[2] + oVar.sUrl[3];
    }
}

/**문서유통 함수 끝**/



//게시등록
doButtonCase['btApprovalTransfer'] = function (oBtn, oVar) {
	const url = '/groupware/board/goBoardTransferPopup.do?callType=approvalTransfer';
	const iWidth = 350;
	const iHeight = 480;
	CFN_OpenWindow(url, 'ApprovalTransfer_' + getInfo('FormInstanceInfo.FormInstID'), iWidth, iHeight, 'fix');
}

//업무등록
doButtonCase['btApprovalTransferCollab'] = function (oBtn, oVar) {
	// 프로젝트 선택
	window.addEventListener( 'message', collabSelectCallback );
		collabUtil.openProjectAllocPopup(0, "N", "appCollabSelectCallback");
}

function collabSelectCallback(ev){
	if( ev.data.functionName != 'appCollabSelectCallback' ) {
        return;
    }
	window.removeEventListener( 'message', collabSelectCallback );
	
	setTimeout(function(){
		var json = {};
		json.formInstanceId = getInfo("FormInstanceInfo.FormInstID");
		json.processId = getInfo("FormInstanceInfo.ProcessID");
		var _data = Base64.utf8_to_b64(JSON.stringify(json));
		
		var _fileInfo = Base64.utf8_to_b64(getInfo("FormInstanceInfo.AttachFileInfo.FileInfos"));
		
		collabUtil.openTaskAddPopupFromApproval("CollabTaskAddPopup", "callbackTaskSave", "", ev.data.params.PrjType, ev.data.params.PrjSeq, ev.data.params.SectionSeq, encodeURIComponent(ev.data.params.PrjName), encodeURIComponent(ev.data.params.SectionName), "", "Approval", getInfo("FormInstanceInfo.Subject"), _data, _fileInfo);
	}, 0);
}
/*-----------------------------------------------------------
 분기 함수 <끝> : KJW : 2014.04.23 : XFORM PRJ.
-------------------------------------------------------------*/

function Open_Forward(sMode) {
    var sCallType = "B1"; //B1:사용자 선택(3열-1명만),C1:그룹 선택(3열-1개만)
    var sTarget = "U"; //U:사용자,D:부서
    switch (sMode) {
        case "charge": sCallType = "B1"; break;
        case "chargegroup": sCallType = "C1"; sTarget = "D"; break;
        case "ChangeReview": sCallType = "B1"; break;

        default: break;
    }
    if (openMode == "L") {
    	parent._CallBackMethod2 = OrgMap_CallBack_Form;
    	parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&szObject=&type="+sCallType+"&setParamData=_setParamdata","1060px","580px","iframe",true,null,null,true); 
    } else {
    	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=OrgMap_CallBack_Form&szObject=&type="+sCallType+"&setParamData=_setParamdata", "", "1060px", "580px");
    }
}

//결재선변경
function changeApvList() {
    try {
        requestProcess("CHANGEAPV");
    } catch (e) {
        alert("Error number: " + e.number);
    }
}

//강제합의
function forcedConsent() {
    try {
        requestProcess("FORCEDCONSENT");
    } catch (e) {
        alert("Error number: " + e.number);
    }
}

function changeFormdata() {
	var jsonObj = {};
    var formJsonObj = getChangeFormJSON();
    
    $.extend(jsonObj, makeNode("g_authKey"	,  	typeof _g_authKey  	=== "undefined" ? "" 	: _g_authKey  ));
    $.extend(jsonObj, makeNode("g_authToken",  	typeof _g_authToken === "undefined" ? "" 	: _g_authToken ));
    $.extend(jsonObj, makeNode("g_password",  	typeof _g_password  === "undefined" ? ""	: _g_password ));    
    $.extend(jsonObj, makeNode("actionMode", ""));
    $.extend(jsonObj, makeNode("actionComment", ""));
    $.extend(jsonObj, makeNode("adminType", "ADMIN"));
    $.extend(jsonObj, getDefaultJSON());
    $.extend(jsonObj, formJsonObj);
    $.extend(jsonObj, makeNode("formID", getInfo("FormInfo.FormID")));
    
    // 승인자 내용변경 저장버튼 활성화
    if (jsonObj.editMode == "Y" && getInfo("SchemaContext.scCHBSaveBtn.isUse") == "Y" && (getInfo("SchemaContext.scCHBis.isUse") == "Y" || getInfo("SchemaContext.scRCHBis.isUse") == "Y")) {
    	Common.Confirm(Common.getDic("msg_apv_confirm_scCHBSaveBtn"), "Confirmation Dialog", function(result){
    		if(!result) return;
    		
    		// 저장 시 중복저장 체크
    		if(chkBeforeEdited()) {
    			Common.Inform(Common.getDic("msg_apv_chkBeforeEdited")); //이전에 문서가 수정되어 저장할 수 없습니다. 문서를 다시 열어주세요.
    			return;
    		}
			
    		if(getInfo("Request.mode") == "REDRAFT" && jsonObj.ChangeApprovalLine) {
    			Common.Inform(Common.getDic("msg_apv_receiveApvEditInfo"), "Information", function(result){ //수신처의 결재선 수정사항은 반영되지 않습니다.
    				if(!result) return;
    				
    				delete jsonObj.ChangeApprovalLine;
    				jsonObj.btnFlag = "EDIT";
    				jsonObj.ProcessDescription.IsModify = "Y";
    				changeFormDataExecute(jsonObj);
				});
    		} else {
    			jsonObj.btnFlag = "EDIT";
    			jsonObj.ProcessDescription.IsModify = "Y";
    			changeFormDataExecute(jsonObj);
    		}
    	});
    } else {
        changeFormDataExecute(jsonObj);
    }
}

function chkBeforeEdited() {
	var edited = false;
	var formInstID = getInfo("FormInstanceInfo.FormInstID");
	var dateStr = getInfo("FormInstanceInfo.LastModifiedDate") ? getInfo("FormInstanceInfo.LastModifiedDate") : getInfo("FormInstanceInfo.InitiatedDate");
	var formOpenDate = new Date(dateStr);
	
    try {
    	$.ajax({
    		url: "/approval/chkBeforeEdited.do",
    		data: { "FormInstID": formInstID },
    		type: "post",
			async: false,
    		success: function(res) {
    			if(res.status == "SUCCESS") {
    				if(res.data) {
    					// if (LastModifiedDate == null) return InitiatedDate;
    					var formLastModDate = new Date(res.data.LastModifiedDate);
    					if(formOpenDate < formLastModDate) edited = true;
    				}
    			} else {
        			Common.Error(Common.getDic("msg_apv_030"));
    			}
    		},
    		error: function(response, status, error) {
				CFN_ErrorAjax("chkEdited.do", response, status, error);
			}
    	});
    } catch (e) {
        Common.Error(e.message);
    }
    
    return edited;
}

function changeFormDataExecute(jsonObj) {
    var formData = new FormData();
    // 양식 기안 및 승인 정보
    formData.append("formObj", Base64.utf8_to_b64(JSON.stringify(jsonObj)));
    
    // 파일정보
    for (var i = 0; i < l_aObjFileList.length; i++) {
    	//alert(typeof l_aObjFileList[i]);
        if (typeof l_aObjFileList[i] == 'object') {
            formData.append("fileData[]", l_aObjFileList[i]);
        }
    }
    
    // 다안기안 멀티 첨부
    if(getInfo("ExtInfo.UseMultiEditYN") == "Y") {
        // 파일정보
        for (var i = 0; i < l_aObjFileListMultiArr.length; i++) {
        	if(l_aObjFileListMultiArr[i] != null){
                for (var j = 0; j < l_aObjFileListMultiArr[i].length; j++) {
                    if (typeof l_aObjFileListMultiArr[i][j] == 'object') {
                    	formData.append("MultifileData_" + (i+1), l_aObjFileListMultiArr[i][j]);
                    }
                }
        	}
        }
    }
    
    try {
    	$.ajax({
    		url:"draft.do",
    		data: formData,
    		type:"post",
    		dataType : 'json',
    		processData : false,
	        contentType : false,
    		success:function (res) {
    			if(res.status == "SUCCESS")
    				Common.Inform(Common.getDic("ACC_msg_editComplete"), "Information", function(){
    					Common.Close();
    					//opener.CoviMenu_GetContent(opener.location.href.replace(opener.location.origin, ""),false);	//opener.location.reload();
    					if(opener.ListGrid  && opener.ListGrid.bindGrid && opener.ListGrid.listData){
							opener.ListGrid.bindGrid(opener.ListGrid.listData);
						}else if(opener.Refresh){
							opener.Refresh();
						}else{
							opener.CoviMenu_GetContent(opener.location.href.replace(opener.location.origin, ""),false);
						}
    				});
    			else
    				Common.Error(Common.getDic("msg_apv_073")); //"저장하지 못했습니다."
    		},
    		error:function(response, status, error){
				CFN_ErrorAjax("draft.do", response, status, error);
			}
    	});
    } catch (e) {
        Common.Error(e.message);
    }
}

function OrgMap_CallBack_Form(pStrItemInfo) {
    var oJSON = $.parseJSON(pStrItemInfo);
    insertToList(oJSON);
}

function insertToList(oList) {
    if (m_sAddList == 'charge' || m_sAddList == 'chargegroup') {
        var m_oChargeList = oList;
        var elmRoot = $$(m_oChargeList);
        var elmlist = $$(m_oChargeList).find("item");
		var elmCnt = elmlist.concat().length;
        if (elmCnt == 0) {
            Common.Inform(Common.getDic("msg_apv_selectCharge")); // 결재권한자(개인/부서)를 선택해 주세요.
            return false;
        } else if (elmCnt > 1) {
        	Common.Inform(Common.getDic("msg_apv_selectChargeOne")); // 결재권한자(개인/부서) 항목은 1개만 선택해 주세요.
            return false;
        } else {
            try { document.getElementById("CHARGEID").value = $$(elmRoot).find("item").concat().eq(0).attr("AN"); } catch (e) { coviCmn.traceLog(e); }
            try { document.getElementById("CHARGENAME").value = $$(elmRoot).find("item").concat().eq(0).attr("DN"); } catch (e) { coviCmn.traceLog(e); }
            try { document.getElementById("CHARGEOUID").value = $$(elmRoot).find("item").concat().eq(0).attr("RG"); } catch (e) { coviCmn.traceLog(e); }
            
            var actionKind = "";
            var changeApvLineObj = getChangeFormJSON();
            if($$(changeApvLineObj).attr("ChangeApprovalLine") != "" && $$(changeApvLineObj).attr("ChangeApprovalLine") != undefined){
            	if((getInfo("Request.mode") == "REDRAFT" || getInfo("Request.mode") == "SUBREDRAFT") && document.getElementById("ACTIONINDEX").value == "CHARGE"){
            		actionKind = "CHARGE";
            	}else{
            		actionKind = "FORWARD";
            	}
            }else{
            	actionKind = "CHARGE";
            }
            	
            var confirmMessage = CFN_GetDicInfo(document.getElementById("CHARGENAME").value) + " " + Common.getDic("msg_apv_ChargeConfirm"); // " 담당자로 지정 하시겠습니까?"; //
            if(CFN_GetQueryString("isMobile") == "Y" || _mobile) {
            	if(confirm(confirmMessage)) {
            		setForwardApvList(elmRoot);
            		requestProcess(actionKind);
				}
            } else {
	            Common.Confirm(confirmMessage, "Confirmation Dialog", function (result) {
	                if (result) {
	                	setForwardApvList(elmRoot);
	                    requestProcess(actionKind);
	                }
	            });
            }
        }
    } else if (m_sAddList == 'ChangeReview') {
        var elmRoot = $$(oList).find("items");
        var elmlist = $$(elmRoot).find("item");
		var elmCnt = elmlist.concat().length;
        if (elmCnt == 0) {
            Common.Inform(Common.getDic("msg_apv_changereview_01")); //'선택한 사람이 없습니다.'
            return false;
        } else {
            try { document.getElementById("CHANGEREVIEWXML").value = JSON.stringify(elmRoot[0]) } catch (e) { coviCmn.traceLog(e); }

            var confirmMessage = Common.getDic("msg_apv_changereview_02"); // "원 결재자를 후결로 추가 하시겠습니까?"; //
            Common.Confirm(confirmMessage, "Confirmation Dialog", function (result) {
                m_bTempFlag = result;
                setForwardApvList(elmRoot);
                requestProcess('CHANGEREVIEW');
            });
        }
    } else if (m_sAddList == 'request' || m_sAddList == 'study') {
        var m_oRequestList = oList;
        var elmRoot = $$(m_oRequestList).find("items");
        var elmlist = $$(elmRoot).find("item");
		var elmCnt = elmlist.concat().length;
        if (elmCnt == 0) {
            Common.Inform(Common.getDic("msg_apv_selectCharge")); // 결재권한자(개인/부서)를 선택해 주세요.
            return false;
        } else if (elmCnt > 1) {
        	Common.Inform(Common.getDic("msg_apv_selectChargeOne")); // 결재권한자(개인/부서) 항목은 1개만 선택해 주세요.
            return false;
        } else { setRequestPersonInfo(elmRoot, false, m_sAddList); }
    }
}

function getHasReceiveno() {
    var sRtn = "false";
    //신청서-담당업무확정에 대해서는 수신대장 보관하지 않음
    if (getInfo("SchemaContext.scChgr.isUse") == "Y") { sRtn = "false"; } else { sRtn = "true"; }
    return sRtn;
}

function setDomainData() {
    /*자동 결재선 처리, 서버에서 진행됨*/
	
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
            if (getInfo("Request.mode") == 'DRAFT' || getInfo("Request.mode") == "TEMPSAVE" || getInfo("Request.mode") == "REDRAFT" || (getInfo("Request.mode") == "SUBREDRAFT" && getInfo("SchemaContext.scRecAssist.isUse") == "Y")) {
                var oApvList = $.parseJSON(document.getElementById("APVLIST").value);
                if (oApvList == null) {
                    alert(gMessage75); //"결재선 지정 오류"
                } else {
                    m_bApvDirty = true;
                    var oGetApvList = {};
                    if ($$(responseJSONdata).find("steps").exist()) {
                        //결재선 내 & 문자열로 인해 오류 발생으로 수정함
                        oGetApvList = $.parseJSON(responseJSONdata.replace(/&/gi, '&amp;'));
                    }
                    var oCurrentOUNode;
                    if (getInfo("Request.mode") == "REDRAFT") {
                        //담당부서 - 담당부서 및 담당업무 결재선 삭제할것 그 후로 기안자 결재선 입력할것
                        /*oCurrentOUNode = $$(oApvList).find("steps > division:has(>taskinfo[status='pending'])[divisiontype='receive']");*/
                    	oCurrentOUNode = $$(oApvList).find("steps > division").children().find("[divisiontype='receive']").has(">taskinfo[status='pending']");
                        if (oCurrentOUNode == null) {
                        	var oDiv = {};
                        	$$(oDiv).attr("taskinfo", {});
                        	$$(oDiv).attr("step", {});
                        	$$(oDiv).attr("divisiontype", "receive");
                        	$$(oDiv).attr("name", Common.getDic("lbl_apv_ChargeDept"));
                            $$(oDiv).attr("oucode", getInfo("AppInfo.dpid_apv"));
                            $$(oDiv).attr("ouname", getInfo("AppInfo.dpdn_apv"));
                        	
                            $$(oDiv).find("taskinfo").attr("status", "pending");
                            $$(oDiv).find("taskinfo").attr("result", "pending");
                            $$(oDiv).find("taskinfo").attr("kind", "receive");
                            $$(oDiv).find("taskinfo").attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        	
                        	$$(oApvList).find("division").push(oDiv);
                        	
                            oCurrentOUNode = $$(oApvList).find("steps > division:has(>taskinfo[status='pending'])[divisiontype='receive']");
                        }
                        var oRecOUNode = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']");	//$$(oCurrentOUNode).find("step:has(ou>taskinfo[status='pending'])");
                        var tempOu = null;
                        if (oRecOUNode.length != 0 && $$(oRecOUNode).find("ou").hasChild("person").length == 0) {
                        	tempOu = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']");
                        	$$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']").remove();
                        }
                        /*var oChargeNode = $$(oCurrentOUNode).find("step:has(ou>person>taskinfo[status='pending'])");*/
                        var oChargeNode = $$(oCurrentOUNode).find("step").has("ou>person>taskinfo[status='pending']");

                        //담당 수신자 대결
                        var isChkDeputy = false;

                        if (oChargeNode.length != 0) {
                            //담당 수신자 대결 S ----------------------------------------
                            var objDeputyOU = $$(oApvList).find("steps>division[divisiontype='receive']>step>ou");
                            var chkObjPersonNode = $$(objDeputyOU).find("person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "']").find(">taskinfo[status='pending']");
                            var chkObjRoleNode = $$(objDeputyOU).find("role:has(person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'])");

                            if (0 < (chkObjPersonNode.length + chkObjRoleNode.length)) {
                                isChkDeputy = true;
                            }
                            //담당 수신자 대결 E -----------------------------------------
                        	
                            var oRecApprovalNode = $$(oCurrentOUNode).find("step>ou>person>taskinfo[status='inactive']");
                            if (oRecApprovalNode.length != 0) {
                            	for(var i=0; i<oRecApprovalNode.length; i++){
                            		var RecApprovalNode = oRecApprovalNode.concat().eq(i);
                            		oCurrentOUNode.concat().eq(0).remove(RecApprovalNode.parent().parent().parent());
                            	}
                            	
                                /*$$(oRecApprovalNode).each(function (i, RecApprovalNode) {
                                   oCurrentOUNode[0].removeChild(RecApprovalNode.parentNode.parentNode.parentNode);
                                });*/
                            }

                            //person의 takinfo가 inactive가 있는 경우 routetype을 변경함
                            var nodesInactives = $$(oCurrentOUNode).find("step[routetype='receive']").has("ou > person > taskinfo[status='inactive']");

                            $$(nodesInactives).each(function (i, nodesInactive) {
                                $$(nodesInactive).attr("unittype", "person");
                                $$(nodesInactive).attr("routetype", "approve");
                                $$(nodesInactive).attr("name", Common.getDic("lbl_apv_ChargeDept"));	
                            });

                        }

                    	var oJFNode = $$(oCurrentOUNode).find("step").has("ou>role>taskinfo[status='pending'], ou>role>taskinfo[status='reserved']"); 
                        var bHold = false; //201108 보류여부
                        var oComment = null;
                        if (oJFNode.length != 0) {
                            var oHoldTaskinfo = $$(oJFNode).find("ou>role>taskinfo[status='reserved']");
                            if (oHoldTaskinfo.length != 0) {
                                bHold = true;
                                oComment = $$(oHoldTaskinfo).find("comment").json();
                                
                                // 보류한 사용자와 로그인한 사용자가 다른 경우
                                if($$(oComment).attr("reservecode") != undefined && $$(oComment).attr("reservecode") != getInfo("AppInfo.usid")) {
                                	Common.Warning(Common.getDic("msg_apv_holdOther")); // 해당 양식은 다른 사용자가 보류한 문서입니다.
                                	bHold = false;
                            	}
                            }
                            tempOu = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='reserved']");
                            
                            //$$(oCurrentOUNode).eq(0).remove($$(oJFNode).eq(0));
                            $$(oCurrentOUNode).eq(0).remove("step");
                        }

                        $$(oCurrentOUNode).attr("oucode", getInfo("AppInfo.dpid_apv"));
                        $$(oCurrentOUNode).attr("ouname", getInfo("AppInfo.dpdn_apv"));
                        
                        $$(oCurrentOUNode).find("taskinfo").attr("status", "pending");
                        $$(oCurrentOUNode).find("taskinfo").attr("result", "pending");
                        
                        var oStep = {};
                        var oOU = {};
                        var oPerson = {};
                        var oTaskinfo = {};

                        $$(oStep).attr("unittype", "person");
                        $$(oStep).attr("routetype", "approve");
                        $$(oStep).attr("name", Common.getDic("lbl_apv_ChargeDept"));
                        
                        $$(oOU).attr("code", getInfo("AppInfo.dpid_apv"));
                        $$(oOU).attr("name", getInfo("AppInfo.dpdn_apv"));
                        
                        $$(oOU).attr("taskid", (tempOu ? tempOu.find("ou").attr("taskid") : $$(oCurrentOUNode).find("step>ou").attr("taskid")));
						$$(oOU).attr("widescid", (tempOu ? tempOu.find("ou").attr("widescid") : $$(oCurrentOUNode).find("step>ou").attr("widescid")));
						$$(oOU).attr("wiid", (tempOu ? tempOu.find("ou").attr("wiid") : $$(oCurrentOUNode).find("step>ou").attr("wiid")));
                        
                        $$(oPerson).attr("code", getInfo("AppInfo.usid"));
                        $$(oPerson).attr("name", getInfo("AppInfo.usnm_multi"));
                        $$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
                        $$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
                        $$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
                        $$(oPerson).attr("oucode", getInfo("AppInfo.dpid"));
                        $$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
                        $$(oPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
                        
                        $$(oTaskinfo).attr("status", (bHold == true ? "reserved" : "pending")); 
                        $$(oTaskinfo).attr("result", (bHold == true ? "reserved" : "pending")); 
                        $$(oTaskinfo).attr("kind", "charge");
                        $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        if (bHold) $$(oTaskinfo).attr("comment", oComment); 
                        
                        $$(oPerson).append("taskinfo", oTaskinfo);
                        
                        $$(oOU).append("person", oPerson);
                        
                        $$(oStep).append("ou", oOU);

                    	// 승인자 내용변경 저장 시 제외
                    	if (!(getInfo("SchemaContext.scCHBSaveBtn.isUse") == "Y" && (getInfo("SchemaContext.scCHBis.isUse") == "Y" || getInfo("SchemaContext.scRCHBis.isUse") == "Y")
                    			&& $$(oApvList).find("steps > division[divisiontype='receive']>step>ou").length > 1 && $$(oApvList).find("division").has("taskinfo[kind='receive'][status='pending']").find(">step>ou>person>taskinfo[kind!='charge']").length != 0)) {
	                        // 조건 추가 - charge가 있는 경우에만 실행
	                        // receive division의 첫번째 step 교체
	                        if($$(oCurrentOUNode).find("step > ou > person > taskinfo[kind='charge']").length > 0) {
		                        $$(oCurrentOUNode).append("step", oStep);
		                        $$(oCurrentOUNode).find("step").concat().eq(0).remove();
	                        }
	                        //else if($$(oCurrentOUNode).find("step").length == 0) 
	                        else {
	                        	$$(oCurrentOUNode).append("step", oStep);
	                        }
                    	}
                        
                        //담당 수신자 대결 S ---------------------------------------------
                        if (isChkDeputy) {
                        	Common.Warning(Common.getDic("msg_ApprovalDeputyWarning"));

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

                        //퇴직자 및 인사정보 최신 적용을 위해 추가 예외사항생기더라도 기안/재기안자 결재선 디스플레이
                        document.getElementById("APVLIST").value = JSON.stringify($$(oApvList).json());
                        
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
                            document.getElementById("btDeptDraft").style.display = "";
                            document.getElementById("btRec").style.display = "none";
                            document.getElementById("btApproved").style.display = "none";
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
                    }else {
                    	// 자동결재선 옵션처리
                		// 1. (기본) 최종결재선 불러온 후 자동결재선 적용 & 재사용인 경우 자동결재선 적용하지 않음
                		// 2. (옵션) 자동결재선 사용하는 경우 최종결재선 불러오지 않기 & 재사용인 경우에 결재선 초기화 후 자동결재선 적용
						// 임시저장 문서는 모두 자동결재선 적용하지 않음
                		var useAutoApvlineOption = Common.getBaseConfig("useAutoApvlineOption");
                		var bSetOption = false; // 자동결재선 셋팅여부
                		
                		// 자동결재선 옵션 처리를 적용 & 합의자, 협조자, 결재자, 사후참조자, 사전참조사 중 하나라도 설정되어 있는 경우
                		if(useAutoApvlineOption == "Y") {
                			if(getInfo("AutoApprovalLine.Agree.autoSet") == "Y" || getInfo("AutoApprovalLine.Assist.autoSet") == "Y" || getInfo("AutoApprovalLine.Approval.autoSet") == "Y" 
                				|| getInfo("AutoApprovalLine.CCAfter.autoSet") == "Y" || getInfo("AutoApprovalLine.CCBefore.autoSet") == "Y") {
								// 자동결재선 옵션인경우(1), 재사용/임시저장이 아닌경우 최종결재선 삭제
								if((getInfo("Request.reuse") != "Y" && getInfo("Request.mode") != "TEMPSAVE")) oGetApvList = {};
                    			if(getInfo("Request.mode") != "TEMPSAVE") bSetOption = true; // 임시저장이 아닌경우 자동결재선 적용	
                			}
                		}else if(getInfo("Request.reuse") != "Y" && getInfo("Request.mode") != "TEMPSAVE"){ // 자동결재선 기본인경우(2), 재사용/임시저장이 아닌경우 자동결재선 적용(최종결재선에 추가)
							bSetOption = true;
						}
                		
                        if (bSetOption || (getInfo("Request.reuse") != "Y" && (CFN_GetQueryString("RequestFormInstID") == "" || CFN_GetQueryString("RequestFormInstID") == "undefined" ))) {
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
                            $$(oDiv).attr("name", Common.getDic("lbl_apv_circulation_sent"));
                            $$(oDiv).attr("oucode", getInfo("AppInfo.dpid_apv"));
                            $$(oDiv).attr("ouname", getInfo("AppInfo.dpdn_apv"));
                            
                            $$(oDivTaskinfo).attr("status", "inactive");
                            $$(oDivTaskinfo).attr("result", "inactive");
                            $$(oDivTaskinfo).attr("kind", "send");
                            $$(oDivTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                            
                            $$(oDiv).attr("taskinfo", oDivTaskinfo);
                            
                            $$(oStep).attr("unittype", "person");
                            $$(oStep).attr("routetype", "approve");
                            $$(oStep).attr("name", Common.getDic("lbl_apv_writer"));
                            
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
                            
                            //기간계 연동시 넘겨받은 결재선에 기안자가 있는경우
                            var legacyCargeInfo = $$(oGetApvList).find("steps>division[divisiontype='send']>step").has("taskinfo[kind='charge']");
                            if($$(legacyCargeInfo).exist() > 0) {
								oStep = $$(legacyCargeInfo).json();
							}
                            $$(oDiv).attr("step", oStep);
                            
                            $$(oSteps).attr("division", oDiv);
                            
                            oApvList = {"steps" : oSteps};
                            
                            $("#APVLIST").val(JSON.stringify(oApvList));
                        }
                        oCurrentOUNode = $$(oApvList).find("steps > division").has("taskinfo[status='inactive']").concat().eq(0);

                        /*// 합의를 사용하지 않는 기안에는 합의가 없음
                        // 개인결재선 -> 기본결재선(*) 정보
                        var sPath = "", sPathOU = "";
                        if (getInfo("SchemaContext.scPCoo.isUse") == "Y" || getInfo("SchemaContext.scPCooPL.isUse") == "Y") { sPath = "or @routetype='assist'"; }
                        if (getInfo("SchemaContext.scPAgr.isUse") == "Y" || getInfo("SchemaContext.scPAgrSEQ.isUse") == "Y") { sPath = sPath + " or @routetype='consult'"; }
                        if (getInfo("SchemaContext.scPAdt.isUse") == "Y") { sPath = sPath + " or @routetype='audit'"; } //개인감사 추가
                        if (getInfo("SchemaContext.scDAdt.isUse") == "Y") { sPathOU = sPathOU + " @routetype='audit'"; } //부서감사 추가
                        if (getInfo("SchemaContext.scDCoo.isUse") == "Y") { sPathOU += ((sPathOU != "") ? " or " : "") + " @routetype='assist'"; } //부서협조 추가
                        if (getInfo("SchemaContext.scDAgr.isUse") == "Y") { sPathOU += ((sPathOU != "") ? " or " : "") + " @routetype='consult'"; } //부서합의 추가*/
						
						// 퇴직자처리
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
                                $$(oSteps).find("division[divisiontype='send']>step").has("[unittype='person'],[unittype='role'],[unittype='ou']").has("taskinfo[kind!='charge']").each(function (i, enodeItem) {
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

                    	// 퇴직자처리 - 참조                        
                        var elmRoot = $$(oGetApvList).find("steps");                  	
                    	var chkAbsentCCInfo = chkAbsent(elmRoot, true, "ccinfo");
                    	if (chkAbsentCCInfo != "") {
                    		chkAbsentCCInfo = chkAbsentCCInfo.split("@@@");
                    		absentType = chkAbsentCCInfo[0];
                    		absentMsg = chkAbsentCCInfo[1];
                    		absentCode = chkAbsentCCInfo[2].split(",");

                    		alert(absentMsg);
                    		
                    		if(absentType == "absent") {
                    	        $$(elmRoot).find("ccinfo").remove();
                    		} else {
                    			for(var i = 0; i < absentCode.length; i++) {
                    				if(absentCode[i] != "") {
                    					$$(oApvList).find("ccinfo>ou>person[code='"+absentCode[i]+"']").parent().parent().remove();
                       				}
                    			}
                    		}	
                    	}
                        
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
									msg += Common.getDic("msg_apv_absentGroup") + " : " + CFN_GetDicInfo($$(oRecDept).attr("DN")); // 제외부서
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
                            
                        // 자동결재선 셋팅
						// 임시저장,재사용인 경우는 기존결재선에 중복체크 후 추가 나머지는 초기화(상단 oGetApvList = {};) 후 자동결재선만 추가
						// 합의자는 기안자 바로뒤에 추가, 나머지는 맨뒤에 추가
                        if(bSetOption) {    
	                        //자동합의자
	                        if (getInfo("AutoApprovalLine.Agree.autoSet") == "Y") {
	                            if (getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != undefined) {
	                                var oAutoLineAgree = $.parseJSON(getInfo("AutoApprovalLine.Agree.WorkedApprovalLine"));
	                                if ($$(oAutoLineAgree).find("step").length > 0) {
	                                    var oAppList = $$(oApvList).find("steps>division[divisiontype='send']>step[routetype='consult'][unittype='person']");
	                                    
	                                    //for (var i = 0; i < $$(oAppList).length; i++) {
	                        			//	var oChkNode = $$(oAutoLineAgree).find("step").has("ou>person[code='" + $$($$(oAppList).concat().eq(i)).find("ou>person").attr("code") + "']");
	                        			//	if (oChkNode.length > 0) {
	                        			//		$$(oAutoLineAgree).find("step").remove(oChkNode.index());
	                        			//	}
	                        			//}
	                                    
	                                    for (var i = 0; i < $$(oAppList).find("ou").concat().length; i++) {
	                                        var oChkNode = $$(oAutoLineAgree).find("step").has("ou>person[code='" + $$(oAppList).find("ou").concat().find("person").eq(i).attr("code") + "']");
	                                        
	                                        if($$(oAutoLineAgree).find("step>ou").concat().length > 1) {
                                        		oChkNode = $$(oAutoLineAgree).find("step").find("ou").has("person[code='" + $$(oAppList).find("ou").concat().find("person").eq(i).attr("code") + "']");
                                        		if (oChkNode.length > 0) {
                                        			$$(oChkNode).remove();
                                        		}
                                        	}
                                        	else if (oChkNode.length > 0) {
												$$(oAutoLineAgree).find("step").remove(oChkNode.index());
	                                        }
	                                    }
	                                    
										if($$(oAutoLineAgree).find("step").concat().length > 0){
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
											var tempChargeObj = {"step" : $$(oApvList).find("steps>division[divisiontype='send']>step").has("ou>person>taskinfo[kind='charge']").json()};
											var tempChargePath = "";

											if($$(tempChargeObj.step).exist()){
												tempChargePath = $$(oApvList).find("steps>division[divisiontype='send']>step").has("ou>person>taskinfo[kind='charge']").concat().eq(0).path();
												
												$$(oApvList).find("steps>division[divisiontype='send']>step").has("ou>person>taskinfo[kind='charge']").remove();
												
												if($$(oAutoLineAgree).find("step").length > 0) {
													$$(oAutoLineAgree).find("step").concat().each(function(i, elm){
														$$(tempChargeObj).append("step", elm.json());
													});
												}
												
												if($$(oApvList).find(tempChargePath.replace(/\//gi, ">")).parent().find("step").length > 0) {		// 기존 결재선이 기안자외에 결재선이 있을 경우
													if($$(oAutoLineAgree).find("step").length > 0) {
														$$(oApvList).find(tempChargePath.replace(/\//gi, ">")).parent().find("step").json().splice(0, 0, $$(tempChargeObj).find("step").json()[0], $$(tempChargeObj).find("step").json()[1]);
													}
													else {
														$$(oApvList).find(tempChargePath.replace(/\//gi, ">")).parent().find("step").json().splice(0, 0, $$(tempChargeObj).find("step").json());
													}
													
												}
												else {		// 기존 결재선이 기안자 외에 결재선이 없을 경우	                                    		


													//ou값이 없는 경우에도 결재선데이터 추가되어 필터추가
													var filter = $$(tempChargeObj).find("step").json().filter(function(item){
														return item.ou && Object.keys(item.ou).length > 0  || item.ou && item.ou.length > 0;
													});
													
													if (tempChargePath.replace(/\//gi, ">").indexOf("division[") >= 0){
														$$(oApvList).find(tempChargePath.replace(/\//gi, ">").replace("division[0]>step", "division[divisiontype='send']")).append("step", filter );
													}
													else{
														$$(oApvList).find(tempChargePath.replace(/\//gi, ">").replace("division>step", "division[divisiontype='send']")).append("step", filter );
													}
												}
											}
											// 기안자 (taskinfo가 charge) 바로 뒤에 자동합의자 데이터 넣기 위함 - 끝
										}

	                                }
	                            }
	                        }
	                        //자동협조자
	                        if (getInfo("AutoApprovalLine.Assist.autoSet") == "Y") {
	                            if (getInfo("AutoApprovalLine.Assist.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Assist.WorkedApprovalLine") != undefined) {
	                                var oAutoLineAssist = $.parseJSON(getInfo("AutoApprovalLine.Assist.WorkedApprovalLine"));
	                                if ($$(oAutoLineAssist).find("step").length > 0) {
	                                    var oAppList = $$(oApvList).find("steps>division[divisiontype='send']>step[routetype='assist'][unittype='person']");
	                                    
	                                    //for (var i = 0; i < $$(oAppList).length; i++) {
	                        			//	var oChkNode = $$(oAutoLineAssist).find("step").has("ou>person[code='" + $$($$(oAppList).concat().eq(i)).find("ou>person").attr("code") + "']");
	                        			//	if (oChkNode.length > 0) {
	                        			//		$$(oAutoLineAssist).find("step").remove(oChkNode.index());
	                        			//	}
	                        			//}
	                                    
	                                    for (var i = 0; i < $$(oAppList).find("ou").concat().length; i++) {
	                                        var oChkNode = $$(oAutoLineAssist).find("step").has("ou>person[code='" + $$(oAppList).find("ou").concat().find("person").eq(i).attr("code") + "']");
	                                        
	                                        if($$(oAutoLineAssist).find("step>ou").concat().length > 1) {
                                        		oChkNode = $$(oAutoLineAssist).find("step").find("ou").has("person[code='" + $$(oAppList).find("ou").concat().find("person").eq(i).attr("code") + "']");
                                        		if (oChkNode.length > 0) {
                                        			$$(oChkNode).remove();
                                        		}
                                        	}
                                        	else if (oChkNode.length > 0) {
												$$(oAutoLineAssist).find("step").remove(oChkNode.index());
	                                        }
	                                    }

	                                    var oCheckSteps = chkAbsent(oAutoLineAssist, false, "autoline");

	                                    if (oCheckSteps != "") {
	                                    	var absentType = oCheckSteps.split("@@@")[0];
	                                    	var absentMsg = oCheckSteps.split("@@@")[1];
	                                    	var absentCode = oCheckSteps.split("@@@")[2].split(",");
	                                    	                            		
	                                		alert(absentMsg);
	                                		
	                                		if(absentType == "absent") {
	                                			$$(oAutoLineAssist).find("ou>person>taskinfo[kind!='charge']").parent().remove();
	                                		} else {
	                                			for(var i = 0; i < absentCode.length; i++) {
	                                				if(absentCode[i] != "") {
	                                					$$(oAutoLineAssist).find("ou>person[code='"+absentCode[i]+"']").remove();
	                                				}	
	                                			}
	                                		}
	                                    }
	                                    
	                                    $$(oAutoLineAssist).find("step").concat().each(function(i, elm){
	                                    	$$(oApvList).find("steps>division[divisiontype='send']").append("step", elm.json());
	                                    });
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
	                        if (getInfo("AutoApprovalLine.CCAfter.autoSet") == "Y") {
	
	                            if (getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != undefined) {
	                                var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine"));
	                                if ($$(oAutoLineCC).find("ccinfo").length > 0) {
	                                    $$(oApvList).find("steps>ccinfo").each(function (i, elm) {
	                                        var oChkNode = $$(oAutoLineCC).find("ccinfo").has(">ou>person[code='" + $$(elm).find("ou > person").attr("code") + "']");
	                                        if (oChkNode.length > 0) {
	                                        	//$$(oChkNode).remove();
	                                        	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
	                                        }
	                                        var oChkNode = $$(oAutoLineCC).find("ccinfo").has("> ou[code='" + $$(elm).find("ou").attr("code") + "']");
	                                        if (oChkNode.length > 0) {
	                                        	//$$(oChkNode).remove();
	                                        	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
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
		                            					$$(oAutoLineCC).find("ccinfo").remove($$(oAutoLineCC).find("ccinfo>ou>person[code='"+absentCode[i]+"']").parent().parent().index());
		                            				}	
		                            			}
		                            		}	
	                                    }
	                                    
	                                    $$(oAutoLineCC).find("ccinfo").concat().attr("datereceived", "");
	                                    
	                                    $$(oAutoLineCC).find("ccinfo").concat().each(function(i, elm){
											if(getInfo("SchemaContext.scReceiptRef.isUse") == "Y") elm.attr("belongto","receiver");
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
	                                        	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
	                                        }
	                                        var oChkNode = $$(oAutoLineCC).find("ccinfo[belongto='sender'][beforecc='y']").has(">ou[code='" + $$(elm).find("ou").attr("code") + "']");
	                                        if (oChkNode.length > 0) {
	                                        	//$$(oChkNode).remove();
	                                        	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
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
		                            					$$(oAutoLineCC).find("ccinfo").remove($$(oAutoLineCC).find("ccinfo>ou>person[code='"+absentCode[i]+"']").parent().parent().index());
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
                    
                    if( oApvList.steps.ccinfo ){
                    	Array.isArray(oApvList.steps.ccinfo) || (oApvList.steps.ccinfo = [oApvList.steps.ccinfo]) 
                    	oApvList.steps.ccinfo.forEach(function(a,b){ $.extend(a,{ senderid : getInfo("AppInfo.usid"), sendername : getInfo("AppInfo.usnm_multi") }) });
                    }
                    
                    document.getElementById("APVLIST").value = JSON.stringify(oApvList);
                    
                    initApvList();
                }
            }
        }
    }
}

//긴급결재
function chk_urgent_onclick() {
	var bChecked = $("#chk_urgent").is(":checked");
	
	$("#chk_urgent").val(bChecked ? "1" : "0");
    $("#TempUseUrgent").val(bChecked);
}

//기밀문서
function chk_secrecy_onclick() {
	var bChecked = $("#chk_secrecy").is(":checked");
	
	$("#chk_secrecy").val(bChecked ? "1" : "0");
    $("#TempUseScrecy").val(bChecked);
        
    if(isGovMulti()) {
        if(bChecked) {
            $("#RELEASE_CHECK_1").prop("checked", false);
            $("#RELEASE_CHECK_3").prop("checked", true);
            HwpCtrl.PutFieldText("publication", Common.getDic("lbl_apv_open")); // 공개
        }else {
            $("#RELEASE_CHECK_1").prop("checked", true);
            $("#RELEASE_CHECK_3").prop("checked", false);
            HwpCtrl.PutFieldText("publication", Common.getDic("lbl_Private")); // 비공개
        }
    }
}

//예약기안,예약배포
function chk_reserved_onclick() {
    if ($("#chk_reserved_draft").is(":checked") || $("#chk_reserved_dist").is(":checked")) {
        $("#reservedchk").show();
        $("input,select","#reservedchk").attr("disabled", true);
        
        if($("#chk_reserved_draft").is(":checked")){
        	$("input,select","#reservedDraftChk").attr("disabled", false);
        }
        
        if($("#chk_reserved_dist").is(":checked")){
        	$("input,select","#reservedDistChk").attr("disabled", false);
        }
    } else {
        $("#reservedchk").hide();
        $("input,select","#reservedchk").attr("disabled", true);
    }
    coviInput.setDate();

	$("#TempUseReserveDraft").val($("#chk_reserved_draft").is(":checked"));
	$("#TempUseReserveDist").val($("#chk_reserved_dist").is(":checked"));
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
    	url:"apvline/checkAbsentMember.do",
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
	    			  var msg = Common.getDic("msg_apv_057").replace(/\\n/g, '\n'); //선택한 개인결재선 혹은 저장된 최종결재선에\n퇴직자가 포함되어 적용이 되지 않습니다.\n\n확인바랍니다.\n\n
	    			  if(isReuse) {
	    				  msg = Common.getDic("msg_apv_360").replace(/\\n/g, '\n'); //저장된 결재선에 퇴직자가 포함되어 적용이 되지 않습니다.
	    			  }
	    			  if(target == "autoline") {
	    				  msg = Common.getDic("msg_apv_361").replace(/\\n/g, '\n'); //자동결재선에 퇴직자가 포함되어 적용이 되지 않습니다.\n\n
	    			  }
	    			  if(target == "ccinfo") {
	    				  msg = msg.replace(Common.getDic("lbl_apv_approver"), Common.getDic("lbl_apv_cclisttitle")); //결재선 -> 참조목록
	    			  }
	    			  msg = msg + '\n' + Common.getDic("msg_apv_359") + " : " + sAbsentResult.substring(0, sAbsentResult.length - 1);
	                  bReturn = "absent@@@" + msg + "@@@" + sAbsentResultCode;
	              } else {
	                  if (sResult != "") {
		    			  var msg = Common.getDic("msg_apv_173").replace(/\\n/g, '\n'); //선택한 개인결재선 혹은 저장된 최종결재선의\n부서/인사정보가 최신정보와 일치하지 않아 적용이 되지 않습니다.\n\n---변경자--- \n\n
		    			  if(isReuse) {
		    				  msg = Common.getDic("msg_apv_357").replace(/\\n/g, '\n'); //저장된 결재선의 부서/인사정보가 최신정보와 일치하지 않아 제외됩니다.
		    			  }
		    			  if(target == "autoline") {
		    				  msg = Common.getDic("msg_apv_362").replace(/\\n/g, '\n'); //자동결재선의 부서/인사정보가 최신정보와 일치하지 않아 제외됩니다.
		    			  }
		    			  if(target == "ccinfo") {
		    				  msg = msg.replace(Common.getDic("lbl_apv_approver"), Common.getDic("lbl_apv_cclisttitle")); //결재선 -> 참조목록
		    			  }
		    			  msg = msg + '\n' + Common.getDic("msg_apv_358") + " : " + sResult.substring(0, sResult.length - 1);
		                  bReturn = "change@@@" + msg + "@@@" + sResultCode;
	                  } else {
	                	  bReturn = "";
	                  }
	              }
	    	},
	    	error:function(response, status, error){
				CFN_ErrorAjax("apvline/checkAbsentMember.do", response, status, error);
			}
	    	
	    });
	}
   
    return bReturn;
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

function getBodyHTML(mode, isServer) {
    var sBodyHTML = "<html><head><meta http-equiv='Content-Type' content='text/html; charset=EUC-KR'><style>";
    try {
        var strBodyTable = document.getElementById("bodytable").cloneNode(true);
        if (mode != null && mode == "PUB") {
            //대외공문출력양식 
            $(strBodyTable).html("<div class='draft_page'><span id='editor'>" + $("#bodytable_content").html() + "</span></div>");
            $(strBodyTable).find("#logoTB").attr("style", "display:"); //상단 회사명
            $(strBodyTable).find("#TableBlowCompanyInformation").attr("style", "display:"); //하단 직인란
			$(strBodyTable).find("#tr_docType").hide(); // 발송유형,공문유형 영역
            //직인가져오기
            var strSealPath = getUsingOfficialSeal();
            if (getInfo("ApprovalLine") == "") { //본사용 : 수기등록한 문서는 직인 안찍어줌
                $(strBodyTable).find("#ImgSeal").attr("style", "display:none");
            } else if (strSealPath != "") {
            	$(strBodyTable).find("#ImgSeal").attr("src", strSealPath); //가져온 직인 경로 삽입           
            } else {
                // 선택된 직인이 없을때
                $(strBodyTable).find("#ImgSeal").attr("style", "display:none");
                alert(Common.getDic("msg_apv_confirm_usingstamp"));
            }
        } else if (mode == "Print") {
            $(strBodyTable).html($("#printdoc").html());
        } else {
        	//의견 없이 출력 후 기존 문서에 의견이 사라지지 않도록 수정
        	if($("#CommentList").attr("style") != 'display: none;' && !isServer){
		        if (!confirm(Common.getDic("msg_apv_288").replace(/\\n/g, '\n'))){
		        	$(strBodyTable).find("#CommentList").attr("style", "display:none");
		        }
	        }
	
        	$(strBodyTable).find("> div > span").html($("#bodytable_content").html());
        	$(strBodyTable).find("#AttFileInfoList").find("dd").hide(); //미리보기 버튼 숨김
        	$(strBodyTable).find("#AttFileInfoList").find("a.totDownBtn").hide(); //전체받기 버튼 숨김
        	$(strBodyTable).find("#AttFileInfoList").find("dt").each(function(i, obj) { //파일 아이콘 숨김
        		$(obj).find("a > span").eq(0).hide();
        	});
        	
        	$(strBodyTable).find(".previewBtn").hide();
        	$(strBodyTable).find(".btn_Bill").hide();
        	$(strBodyTable).find('.comment.tooltips').hide();
        }
        $(strBodyTable).find("span[data-element-type='textarea_linebreak']").css('display', 'block'); // 출력 시 textarea 다음 장으로 넘어가는 현상있어서 수정함.

        //이미지 가로 사이즈가 본문영역 보다 클경우, 배율조정.
        var getBodyWidth = $("#bodytable_content").width();
        $(strBodyTable).find(".table_form_info_draft img").each(function (i, item) {
        	var orgImg = $("#bodytable img[src='"+$(item).attr("src")+"']");
        	var originalWidth = $(orgImg).width();
        	if(getBodyWidth < originalWidth){
        	    var desiredHeight = $(orgImg).height() * (getBodyWidth / originalWidth);
        	    $(item).attr("width", "100%");
        	    $(item).attr("height", desiredHeight+"px");
        	}
        });
        
        for (var i = 0; i < document.styleSheets.length; i++) {
            if (document.styleSheets[i].href != null && document.styleSheets[i].href.indexOf('approval_form') > -1) {
                if ($.browser.msie == true && parseFloat($.browser.version) <= 8) //ie8 이하일때
                    sBodyHTML += getStyle(document.styleSheets[i].href, i);
                else
                    sBodyHTML += getStyleChrome(document.styleSheets[i]);
            }
        }
    } catch (e) { alert(e.description); }
    
    if (mode == "PcSave") {
    	sBodyHTML = "";
    	// img tag to base64
    	convertInlineImages(strBodyTable);
    	// img tag to base64
    	if($(strBodyTable).find(".table_form_info_draft").find("table").css("width")!=null){
            	$(strBodyTable).find(".table_form_info_draft").find('table').css("width","");
    	}
    	sBodyHTML += strBodyTable.innerHTML;
	} else {
		sBodyHTML += "</style></head><body topmargin='0' leftmargin='0' scroll='auto' align='center' class='approval_form'>" + strBodyTable.innerHTML + "</body></html>";
	}

    return sBodyHTML;
}

/**
 * 서명 및 인라인이미지등 PC저장, 문서이관, 협업링크등 PDF 변환을 위해 base64 로 변환한다.
 * @returns
 */
function convertInlineImages(strBodyTable, forPdfConvert){
	var canvas, ctx;
	forPdfConvert = forPdfConvert || "Y";
	try{
		// strBodyTable 는 rendering 된 DOM 이 아니므로 img dimension 측정이 불가함.
		var imgtags_clone = $("img", strBodyTable);
		var imgtags_org = $("img", "#bodytable");
		var newMap = {};
		if($("#imgConvertCanvas").length == 0){
			$("body").append($("<canvas>",{id : "imgConvertCanvas"}).css({"display":"none"}));
		}
		var smart4jPath = Common.getGlobalProperties("smart4j.path");
		for(var i = 0; i < imgtags_org.length; i++){
			if(imgtags_org[i].src){
				try {
					var img = imgtags_org[i];
					
					// 인라인이미지중 대용량 이미지존재할 경우 성능에 문제발생하므로  photo.do 이미지는 서버에서 직접처리한다.
					// 게시등록용일 경우 전체 binary 변환(느려도..)
					if(forPdfConvert == "Y" && img.src.indexOf("/covicore/common/photo/photo.do") > -1) {
						var imgSrc = img.src;
						if(imgSrc.indexOf("/covicore/common/photo/photo.do") == 0) {
							newMap[i] = smart4jPath + imgSrc;
						}
						else if(imgSrc.indexOf("http") == 0) {
							var eIdx = imgSrc.indexOf("/covicore/common/photo/photo.do");
							rUrl = imgSrc.substring(eIdx, imgSrc.length);
							newMap[i] = smart4jPath + rUrl
						}
						continue;
					} 
					
					var w, h;
					w = $(img).width();
					h = $(img).height();
					
					canvas = $("#imgConvertCanvas")[0];
					canvas.width = w;
					canvas.height = h;
					
					ctx = canvas.getContext('2d');
					ctx.clearRect(0, 0, canvas.width, canvas.height);
					ctx.drawImage(img, 0, 0, w, h);
					var imgDataStr = canvas.toDataURL();
					
					newMap[i] = imgDataStr;
				}catch(e) {
					coviCmn.traceLog(e);
					continue;
				}
			}
		}
		for(var i = 0; i < imgtags_clone.length; i++){
			if(imgtags_clone[i].src){
				if(newMap[i] && newMap[i] != ""){
					imgtags_clone[i].src = newMap[i];
				}
			}
		}
	}
	catch (e) {
       coviCmn.traceLog(e);
    }
	finally{
		$("#imgConvertCanvas").remove();
		newMap = null;
		ctx = null;
	}
}

//ie8을 제외한 ie9, ie10, chrome등에서 현재페이지에서 사용하는 스타일 가져오기 
function getStyleChrome(sheet) {
    var style = "";
    var rules = sheet.rules || sheet.cssRules;
    for (var r = 0; r < rules.length; r++) {
        style += rules[r].cssText;
    }
    return style;
}

function getStyle(sURL, index) {
    var objStyle = "";
    if (document.styleSheets[index].cssText != null) {
        objStyle += document.styleSheets[index].cssText
    }
    return objStyle.replace("undefined", "");
}

//직인가져오기 
function getUsingOfficialSeal() {
	var SERVICE_TYPE = "ApprovalStamp";
	var sealPath = "";
	
	CFN_CallAjax("/approval/legacy/getGovUsingStamp.do", {"entCode":getInfo("AppInfo.etid")}, function (data){ 
    	var jsonData = data;
    	if(jsonData.error != undefined && jsonData.error != null){
    		Common.Error("Desc: " + jsonData.error);
    	}else{
    		if(jsonData.Table[0] != undefined) {
				var _data = jsonData.Table[0];
    			
    			if(_data.FileID && !isNaN(_data.FileID)){
					sealPath = coviCmn.loadImageId(_data.FileID, SERVICE_TYPE);	
    			} 
    			else { // 이전 직인표시를 위해서만 사용, 신규문서와는 무관
	    			sealPath = _data.FileInfo;
	    			if(sealPath.indexOf(Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"))) == -1){
	    				sealPath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + sealPath;
    				}
	    				
	    			sealPath = coviCmn.loadImage(sealPath);
				}
    		}
    	}
    },false,'json');
	
    return sealPath;
}

/* 날짜 가감 함수 
사용예 : 2009-01-01 에 3 일 더하기 ==> addDate("d", 3, "2009-01-01", "-");*/
function addDate(pInterval, pAddVal, pYyyymmdd, pDelimiter) {
    var yyyy;
    var mm;
    var dd;
    var cDate;
    var oDate;
    var cYear, cMonth, cDay;

    if (pDelimiter != "") {
		var regExp = new RegExp("/\\" + pDelimiter + "/g");
        pYyyymmdd = pYyyymmdd.replace(regExp, "");
    }

    yyyy = pYyyymmdd.substr(0, 4);
    mm = pYyyymmdd.substr(4, 2);
    dd = pYyyymmdd.substr(6, 2);

    if (pInterval == "yyyy") {
        yyyy = (yyyy * 1) + (pAddVal * 1);
    } else if (pInterval == "m") {
        mm = (mm * 1) + (pAddVal * 1);
    } else if (pInterval == "d") {
        dd = (dd * 1) + (pAddVal * 1);
    }

    cDate = new Date(yyyy, mm - 1, dd) // 12월, 31일을 초과하는 입력값에 대해 자동으로 계산된 날짜가 만들어짐.
    cYear = cDate.getFullYear();
    cMonth = cDate.getMonth() + 1;
    cDay = cDate.getDate();

    cMonth = cMonth < 10 ? "0" + cMonth : cMonth;
    cDay = cDay < 10 ? "0" + cDay : cDay;

    if (pDelimiter != "") {
        return cYear + pDelimiter + cMonth + pDelimiter + cDay;
    } else {
        return cYear + cMonth + cDay;
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
			oApprovedSteps = $$(elmRoot).find("division").has("taskinfo[status='pending']").find("> step[routetype='approve'] > ou > person > taskinfo[kind!='charge'][kind!='review'][kind!='bypass'][kind!='skip'][kind!='conveyance'][status='completed']");
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
			
			$$(oApprovedSteps).concat().each(function (i, oTaskInfo) {
				var oStep = oTaskInfo.parent().parent().parent();
				if ($$(oStep).attr("allottype") != "parallel") {
					if ($$(oTaskInfo).attr("rejectee") != 'y') {
						iApvCNT++;
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

/*새창으로 띄우기*/
function openNewFormWindow() {
    var sSize = "scroll"; var iWidth = 790; var iHeight = window.screen.availHeight - 100;
    var sUrl = String(document.location.href);
    sUrl = sUrl.replace("FormWrite", "Form"); //바닥 작성창에서 Open할 경우
    // sUrl = sUrl.replace("openMode=L", "openMode=W"); //
    //sUrl = sUrl.replace("openMode=P", "openMode=W"); //
    if (sUrl.lastIndexOf("#") == (sUrl.length - 1)) { sUrl = sUrl.substring(0, sUrl.lastIndexOf("#")); } //url에 #이 포함되어 있음 제거처리
    if (sUrl.lastIndexOf("openMode=") == -1) { sUrl = sUrl + "&openMode=B"; }
    
    // 미리보기 파라미터 제거
    sUrl = sUrl.replace("&listpreview=Y", "");
    
    //  sUrl = sUrl + "&Readtype=openwindow";   
    //mode = DRAFT
    var mode = CFN_GetQueryString("mode");
    if(mode == "DRAFT"){
        Common.Confirm(Common.getDic("msg_Mail_WritingContentsMayDeleted"), 'Confirmation Dialog', function (result) {
        if (result) {
            CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);  //윈도우팝업창으로 띄울것이므로 현재창에서 바로띄움(HIW)
    } else {
            self.close();
    }
    });
    } else {
        CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
    }
}

function print_part(frame) {

    if (AUTO_OBJECT == 2) { objectRun(); }

    try {
        Printmade.Run(DEFAULT_OPTION + " /fid:'" + frame + "'");
    }
    catch (e) {
        alert(ERR_MSG);
    }

}

//즐겨찾기 버튼 저장 이벤트 추가 시작
function favorform(szmode) {
	var url;
	var FormID = getInfo("FormInfo.FormID");
	
	if(szmode == "delete"){
		url = "user/removetFavoriteUsedFormListData.do";
	}else if(szmode == "insert"){
		url = "user/addFavoriteUsedFormListData.do";
	}			
	var Params = {
			userCode : sessionObjFormMenu["USERID"],
			formID : FormID
	};	
	
	$.ajax({
		url:url,
		type:"post",
		data:Params,
		async:false,
		success:function (data) {
			if (szmode == "insert") {
				document.getElementById("favorformadd").style.display = "none";
                document.getElementById("favorformdelete").style.display = "";
            } else {
                document.getElementById("favorformadd").style.display = "";
                document.getElementById("favorformdelete").style.display = "none";
            }
			
			// Common.Inform(Common.getDic("msg_apv_117"));
			setTimeout(function(){
				if(opener && !opener.closed && opener.location.pathname == '/approval/layout/approval_FormList.do') {
					opener.CoviMenu_GetContent(opener.location.href.replace(opener.location.origin, ""),false);	//opener.location.reload();
				} 
			}, 0);
		},
		error:function(response, status, error){
			CFN_ErrorAjax(url, response, status, error);
		}
	});

}
//즐겨찾기 버튼 이벤트 추가 끝

function fnGoPreNextList(objid) {
    var sPiid = "";
    var sWiid = "";
    var sFiid = "";
    var sPtid = "";
    var sMeggage = "";
    var sCount = "";
    
    var sBizData2 = "";
    var sTaskID = "";

    if(opener.strPiid_List == ""){
    	Common.Warning(Common.getDic("msg_apv_refreshList"), "Warning", function(){ Common.Close(); });
    }else{
	    if (openMode == "L") {
	        var aPiid_List = m_oInfoSrc.strPiid_List.split(";");
	        var aWiid_List = m_oInfoSrc.strWiid_List.split(";");
	        var aFiid_List = m_oInfoSrc.strFiid_List.split(";");
	        var aPtid_List = m_oInfoSrc.strPtid_List.split(";");
	        
	        var aBizData2_List = m_oInfoSrc.strBizData2_List.split(";");
	        var aTaskID_List = m_oInfoSrc.strTaskID_List.split(";");
	    } else {
	        var aPiid_List = opener.strPiid_List.split(";");
	        var aWiid_List = opener.strWiid_List.split(";");
	        var aFiid_List = opener.strFiid_List.split(";");
	        var aPtid_List = opener.strPtid_List.split(";");
	        
	        var aBizData2_List = opener.strBizData2_List.split(";");
	        var aTaskID_List = opener.strTaskID_List.split(";");
	    }
	    
	    var nPoint = 0;
	    var nTotal = aWiid_List.length - 1;
	
	    for (var i = 0; i < nTotal; i++) {
	        if (aWiid_List[i] == "" || aWiid_List[i] == "0") {
	            if (aPiid_List[i] == getInfo("ProcessInfo.ProcessID")) {
	                nPoint = i;
	                i = nTotal;
	            }
	        } else {
	            if ('TCINFO' == getInfo("Request.gloct") && 'COMPLETE' == getInfo("Request.loct")) {   //[2016-01-25 modi kh] 개인결재함 > 참조/회람함 에는 piid 값만 존재 하므로 일괄확인 시 piid로 체크 한다
	                if (aPiid_List[i] == getInfo("ProcessInfo.ProcessID")) {
	                    nPoint = i;
	                    i = nTotal;
	                }
	            }
	            else {
	                if (aWiid_List[i] == getInfo("Request.workitemID")) {
	                    nPoint = i;
	                    i = nTotal;
	                }
	            }
	        }
	    }
	    if (objid == "btPreList") {
	        if (nPoint == 0) sMeggage = Common.getDic("msg_apv_firstPage");
	        else {
	            sPiid = aPiid_List[nPoint - 1].toLowerCase();
	            sWiid = aWiid_List[nPoint - 1].toLowerCase();
	            sFiid = aFiid_List[nPoint - 1].toLowerCase();
	            sPtid = aPtid_List[nPoint - 1].toLowerCase();
	            
	            sBizData2 = aBizData2_List[nPoint - 1].toLowerCase();
	            sTaskID = aTaskID_List[nPoint - 1].toLowerCase();
	            
	            sCount = String(nPoint + 1 - 1) + "/" + String(nTotal);
	        }
	
	    } else if (objid == "btNextList") {
	        if (nPoint == nTotal - 1) sMeggage = Common.getDic("msg_apv_lastPage");
	        else {
	            sPiid = aPiid_List[nPoint + 1].toLowerCase();
	            sWiid = aWiid_List[nPoint + 1].toLowerCase();
	            sFiid = aFiid_List[nPoint + 1].toLowerCase();
	            sPtid = aPtid_List[nPoint + 1].toLowerCase();
	            
	            sBizData2 = aBizData2_List[nPoint + 1].toLowerCase();
	            sTaskID = aTaskID_List[nPoint + 1].toLowerCase();
	            
	            sCount = String(nPoint + 1 + 1) + "/" + String(nTotal);
	        }
	    }
	    if (sMeggage != ""){ Common.Warning(sMeggage); return false;}
	    else if (sPiid != "") {
	
	    	var nowURL = window.location.href.replace("/account/expenceApplication/ExpenceApplicationViewPopup.do", "/approval/approval_Form.do");
	    	
	        if (openMode == "L") {
	            m_oInfoSrc.sNowPiis = sPiid;
	            document.location.href = nowURL.substring(0, nowURL.indexOf("?")) +"?"+nowURL.substring(nowURL.indexOf("?")+1).replace(CFN_GetQueryString("processID"), sPiid).replace(CFN_GetQueryString("workitemID"), sWiid).replace(CFN_GetQueryString("forminstanceID"), sFiid).replace("userCode=" + CFN_GetQueryString("userCode"), "userCode=" + sPtid).replace("editMode=" + CFN_GetQueryString("editMode"), "editMode=N").replace("#", "").replace("ExpAppID=" + CFN_GetQueryString("ExpAppID"), "").replace("taskID=" + CFN_GetQueryString("taskID"), "").replace("&scount=" + CFN_GetQueryString("scount"), "") + "&scount=" + sCount + "&ExpAppID=" + sBizData2 + "&taskID=" + sTaskID;
	        } else {
	
	            opener.sNowPiis = sPiid;
	            document.location.href = nowURL.substring(0, nowURL.indexOf("?")) +"?"+nowURL.substring(nowURL.indexOf("?")+1).replace(CFN_GetQueryString("processID"), sPiid).replace(CFN_GetQueryString("workitemID"), sWiid).replace(CFN_GetQueryString("forminstanceID"), sFiid).replace("userCode=" + CFN_GetQueryString("userCode"), "userCode=" + sPtid).replace("editMode=" + CFN_GetQueryString("editMode"), "editMode=N").replace("#", "").replace("ExpAppID=" + CFN_GetQueryString("ExpAppID"), "").replace("taskID=" + CFN_GetQueryString("taskID"), "").replace("&scount=" + CFN_GetQueryString("scount"), "") + "&scount=" + sCount + "&ExpAppID=" + sBizData2 + "&taskID=" + sTaskID;
	        }
	    }
	    return true;
    }
}

function getDocListJSON() {
    var returnJSON = {};
    var sDocListType = "3";
    if (CFN_GetQueryString("doclisttype") != null) sDocListType = CFN_GetQueryString("doclisttype");

    if (sDocListType == "10" || sDocListType == "3" || sDocListType == "20") {
    	$.extend(returnJSON, makeNode("OwnerUnitCode", getInfo("AppInfo.etid")));
    	$.extend(returnJSON, makeNode("DocumentUnitCode", getInfo("AppInfo.etid")));
    	$.extend(returnJSON, makeNode("UnitAbbreviation", ""));
    	$.extend(returnJSON, makeNode("CategoryNumber", ""));
    	$.extend(returnJSON, makeNode("DocListType", sDocListType));
    	$.extend(returnJSON, makeNode("RegistrationComment", ""));
    	// 일반 대외공문 품의서인 경우만 사용
    	//$.extend(returnJSON, makeNode("RegistratorName", document.getElementById("NO").value));
    	$.extend(returnJSON, makeNode("RegistratorCode", getInfo("AppInfo.usid")));
    	$.extend(returnJSON, makeNode("SentByUnitName", getInfo("AppInfo.dpnm")));
    	$.extend(returnJSON, makeNode("SentByUnitCode", getInfo("AppInfo.dpid")));
    	$.extend(returnJSON, makeNode("ReceivedByUnitName", ""));
    	$.extend(returnJSON, makeNode("ReceivedByUnitCode", ""));
    	$.extend(returnJSON, makeNode("DocumentSubject", document.getElementById("Subject").value));
    	$.extend(returnJSON, makeNode("PersonInChargeName", ""));
    	$.extend(returnJSON, makeNode("PersonInChargeCode", ""));
    	$.extend(returnJSON, makeNode("ApprovedDate", getInfo("AppInfo.svdt")));
    	$.extend(returnJSON, makeNode("InitiatorName", getInfo("AppInfo.usnm")));
    	$.extend(returnJSON, makeNode("InitiatorCode", getInfo("AppInfo.usid")));
    	$.extend(returnJSON, makeNode("EffectuatedDate", getInfo("AppInfo.svdt")));
    	$.extend(returnJSON, makeNode("EffectuationMethod", ""));
        
        if (sDocListType == "3") {
        	$.extend(returnJSON, makeNode("GOV_RECIEVE_NAME", document.getElementById("GOV_RECIEVE_NAME").value));
        }
        else if (sDocListType == "20") {
        	$.extend(returnJSON, makeNode("GOV_DOC_NUMBER", document.getElementById("GOV_DOC_NUMBER").value));
        	$.extend(returnJSON, makeNode("GOV_SEND_NAME", document.getElementById("GOV_SEND_NAME").value));
        }
    }
    
    return returnJSON;
}

function getIncludeFormPrefix(formStr, gubun) {
    var arrForms = formStr.split(gubun);
    var check = false;
    for (var i = 0; i < arrForms.length; i++) {
        if (arrForms[i] == getInfo("FormInfo.FormPrefix")) {
            check = true;
            break;
        }
    }
    return check;
}


// XForm 저장연동 (장용욱:20160323)              
function fn_writelink(extdatatype) {
    var bLastApprovalYN = false;    // 마지막 결재자인지 여부
    var bErrorYN = false;

    var m_oApvList = $.parseXML(document.getElementById("APVLIST").value);

    // 후결(review), 후열(bypass), 결재안함(skip) 아니고 상태가 대기(pending) 이거나 보류(reserved) 인것
    var oPendingSteps = $(m_oApvList).find("steps > division > step:has(taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][status='pending']), steps > division > step:has(taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][status='reserved'])");
    // 후결(review), 후열(bypass), 결재안함(skip) 아니고 상태가 비활성화(inactive)
    var oinActiveSteps = $(m_oApvList).find("steps > division > step:has(taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][status='inactive'])");

    // 대기(pending), 보류(reserved) 상태가 1개 이고, 비활성화(inactive) 상태가 0개 일 경우
    if ((oPendingSteps.length == 1) && (oinActiveSteps.length == 0)) {
        bLastApprovalYN = true;
    }

    // 1인결재 : 대기(pending), 보류(reserved) 상태가 0개 이고, 비활성화(inactive) 상태가 1개 일 경우
    if ((oPendingSteps.length == 0) && (oinActiveSteps.length == 1)) {
        bLastApprovalYN = true;
    }

    // Request 담당업무 : division 수가 담당업무 수보다 작을 경우에는 마지막 결재자가 아님
    if (bLastApprovalYN) {
        if (getInfo("SchemaContext.scChgr.isUse") == "Y" && getInfo("SchemaContext.scChgr.value") != "") {                    
            if ($(m_oApvList).find("steps > division").length < (getInfo("SchemaContext.scChgr.value").split('^').length + 1)) {
                bLastApprovalYN = false;
            }
        }
    }

    // Request 담당업무함 계열사별 지정 : division 수가 담당업무함 계열사별 지정 수보다 작을 경우에는 마지막 결재자가 아님
    if (bLastApprovalYN) {
        if (getInfo("SchemaContext.scChgrEnt.isUse") == "Y" && getInfo("SchemaContext.scChgrEnt.value") != "") {
            if ($(m_oApvList).find("steps > division").length < (getInfo("SchemaContext.scChgrEnt.value").split('^').length + 1)) {
                bLastApprovalYN = false;
            }
        }
    }

    // Request 담당업무함 사업장별 지정 : division 수가 담당업무함 사업장별 지정 수보다 작을 경우에는 마지막 결재자가 아님
    if (bLastApprovalYN) {
        if (getInfo("SchemaContext.scChgrReg.isUse") == "Y" && getInfo("SchemaContext.scChgrReg.value") != "") {
            if ($(m_oApvList).find("steps > division").length < (getInfo("SchemaContext.scChgrReg.value").split('^').length + 1)) {
                bLastApprovalYN = false;
            }
        }
    }

    // Request 담당부서사용 : division 수가 담당부서사용 수보다 작을 경우에는 마지막 결재자가 아님
    if (bLastApprovalYN) {
        if (getInfo("SchemaContext.scChgrOU.isUse") == "Y" && getInfo("SchemaContext.scChgrOU.value") != "") {
            if ($(m_oApvList).find("steps > division").length < (getInfo("SchemaContext.scChgrOU.value").split('^').length + 1)) {
                bLastApprovalYN = false;
            }
        }
    }

    // Request 담당부서 계열사별 지정 : division 수가 담당부서 계열사별 지정 수보다 작을 경우에는 마지막 결재자가 아님
    if (bLastApprovalYN) {
        if (getInfo("SchemaContext.scChgrOUEnt.isUse") == "Y" && getInfo("SchemaContext.scChgrOUEnt.value") != "") {
            if ($(m_oApvList).find("steps > division").length < (getInfo("SchemaContext.scChgrOUEnt.value").split('^').length + 1)) {
                bLastApprovalYN = false;
            }
        }
    }

    // Request 담당수신자사용 : division 수가 담당수신자사용 작을 경우에는 마지막 결재자가 아님
    if (bLastApprovalYN) {
        if (getInfo("SchemaContext.scChgrPerson.isUse") == "Y" && getInfo("SchemaContext.scChgrPerson.value") != "") {
            if ($(m_oApvList).find("steps > division").length < (getInfo("SchemaContext.scChgrPerson.value").split('^').length + 1)) {
                bLastApprovalYN = false;
            }
        }
    }

    // 협조문서는 기안부서 최종 결재선에서 연동 수신처 결재시는 제외     
    // 배포사용, 배포그룹사용
    if (bLastApprovalYN) {
        if (getInfo("SchemaContext.scIPub.isUse") == "Y" || getInfo("SchemaContext.scGRec.isUse") == "") {                    
            if ($(m_oApvList).find("division[divisiontype='send']:has(>taskinfo[status='completed'])").length > 0) {
                bLastApprovalYN = false;
            }
        }
    }

    // 최종승인자 일 경우
    if (bLastApprovalYN) {
        if (extdatatype == "writelink_d_text") {
            if (document.getElementById("ACTIONINDEX").value == 'approve') {
                var strXml = "<params>";
                $('*[ext-data-type1="writelink_d_text"]').each(function (i, item) {
                    // 연결정보
                    var strConnectString = $(this).attr('ext-data-type2');

                    var strTable = $(this).attr('ext-data-type3');
                    var strField = $(this).attr('ext-data-type4');


                    // JSON 파라미터 "'", "\" 처리 -> [2016-06-13] kimhs, hidden 값 가져올 수 있도록 처리
                    var strValue = $(this).text() == "" ? $(this).val() : $(this).text();
                    strValue = strValue.replace(/'/g, "!!!!@@@@####^^^^");
                    strValue = strValue.replace(/\\/g, "!!!!@@@@####&&&&");

                    //var bodyContext = $.parseXML("<?xml version='1.0' encoding='utf-8'?>" + getInfo("BodyContext"));
                    //strValue = $(bodyContext).find(strField).text();

                    // JSON 파라미터 구성
                    strXml = strXml + "<param>";
                    strXml = strXml + "<connect>" + strConnectString + "</connect>";
                    strXml = strXml + "<tablename>" + strTable + "</tablename>";
                    strXml = strXml + "<columnname>" + strField + "</columnname>";
                    strXml = strXml + "<columnvalue><![CDATA[" + strValue + "]]></columnvalue>";
                    strXml = strXml + "</param>";
                });
                strXml = strXml + "</params>";

                if (strXml != "<params></params>") {
                    CFN_PageMethodJSON_Url("/WebSite/Approval/Forms/Templates/xform/xform_database.aspx", "SetDataInsert", "{strXml:'" + strXml
                        + "'}", false, function (pResult, pContext) {
                            if (pResult != "") {
                                if (pResult.d.indexOf('ERROR') == 0) {
                                    alert(pResult.d);
                                    bErrorYN = true;
                                }
                            }
                        });
                }
            }
        } else if (extdatatype == "writelink_w_text") {
            if (document.getElementById("ACTIONINDEX").value == 'approve') {
                var strXml = "<params>";

                // (본사운영) 프로젝트코드신청서 양식
                // [16-07-18] kimhs, 프로젝트 코드신청서 코드 발번 분기
                if (getInfo("FormInfo.FormPrefix") == "WF_FORM_PROJECTCODE") {
                    var projectNo = -1;
                    var selectJobNo = 0;
                    var subjectType = "";
                    if (getInfo("Request.templatemode") == "Read") { // 읽기모드
                        subjectType = formJson.BodyContext.SUBJECT_TYPE;
                    }
                    else { // 쓰기모드
                        subjectType = $("#SUBJECT_TYPE option:selected").val();
                    }

                    switch (subjectType) {
                        case "P":
                            selectJobNo = 3; // 299번 등록 후 300번대로 사용. 400번 초과시는 추가 정책 설정 필요) (2016/02/12 300번대 사용 중)
                            break;
                        case "R":
                            selectJobNo = 4;
                            break;
                        case "C":
                            selectJobNo = 6;
                            break;
                        case "S":
                            selectJobNo = 7;
                            break;
                        case "G":
                            selectJobNo = 1;
                            break;
                    }

                    var pXML = "USP_JOBNO_GENERATE";
                    var aXML = "<param><name>JOBNOINPUT</name><type>int</type><length>50</length><value><![CDATA[" + selectJobNo + "]]></value></param>";
                    var connectionname = "COVI_FLOW_SI_ConnectionString";
                    var sXML = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql><type>sp</type>" + aXML + "</Items>";
                    var szURL = "../getXMLQuery.aspx";

                    CFN_CallAjax(szURL, sXML, function (data) {
                        var xmlReturn = data;
                        var elmlist = $(xmlReturn).find("response > NewDataSet > Table");

                        projectNo = $(elmlist).find("RESULT").text();
                    }, false, "xml");

                    // JSON 파라미터 구성
                    strXml = strXml + "<param>";
                    strXml = strXml + "<connect>" + $("#pStrJobtype").attr('ext-data-type2') + "</connect>";
                    strXml = strXml + "<tablename>" + $("#pStrJobtype").attr('ext-data-type3') + "</tablename>";
                    strXml = strXml + "<columnname>pStrJobcode</columnname>";
                    strXml = strXml + "<columnvalue><![CDATA[" + projectNo + "]]></columnvalue>";
                    strXml = strXml + "</param>";
                }

                $('*[ext-data-type1="writelink_w_text"]').each(function (i, item) {
                    // 연결정보
                    var strConnectString = $(this).attr('ext-data-type2');

                    var strTable = $(this).attr('ext-data-type3');
                    var strField = $(this).attr('ext-data-type4');


                    // JSON 파라미터 "'", "\" 처리 -> [2016-06-13] kimhs, hidden 값 가져올 수 있도록 처리
                    var strValue = $(this).text() == "" ? $(this).val() : $(this).text();
                    strValue = strValue.replace(/'/g, "!!!!@@@@####^^^^");
                    strValue = strValue.replace(/\\/g, "!!!!@@@@####&&&&");

                    //var bodyContext = $.parseXML("<?xml version='1.0' encoding='utf-8'?>" + getInfo("BodyContext"));
                    //strValue = $(bodyContext).find(strField).text();

                    // JSON 파라미터 구성
                    strXml = strXml + "<param>";
                    strXml = strXml + "<connect>" + strConnectString + "</connect>";
                    strXml = strXml + "<tablename>" + strTable + "</tablename>";
                    strXml = strXml + "<columnname>" + strField + "</columnname>";
                    strXml = strXml + "<columnvalue><![CDATA[" + strValue + "]]></columnvalue>";
                    strXml = strXml + "</param>";
                });
                strXml = strXml + "</params>";

                if (strXml != "<params></params>") {
                    CFN_PageMethodJSON_Url("/WebSite/Approval/Forms/Templates/xform/xform_webservice.aspx", "SetDataInsert", "{strXml:'" + strXml
                        + "'}", false, function (pResult, pContext) {
                            if (pResult != "") {
                                if (pResult.d.indexOf('ERROR') == 0) {
                                    alert(pResult.d);
                                    bErrorYN = true;
                                }
                            }
                        });

                    if (getInfo("FormInfo.FormPrefix") == "WF_FORM_PROJECTCODE" && projectNo == '-1') { // 프로젝트 코드 번호대가 넘어갔을 시
                        Common.Warning('해당 업무타입으로 신청할 수 없습니다.\n담당자에게 문의해주세요.');
                        bErrorYN = true;
                    }
                }
            }
        } else if (extdatatype == "writelink_s_text") {
            if (document.getElementById("ACTIONINDEX").value == 'approve') {
                var strXml = "<params>";
                $('*[ext-data-type1="writelink_s_text"]').each(function (i, item) {
                    // 연결정보
                    var strConnectString = $(this).attr('ext-data-type2');

                    var strTable = $(this).attr('ext-data-type3');
                    var strField = $(this).attr('ext-data-type4');


                    // JSON 파라미터 "'", "\" 처리 -> [2016-06-13] kimhs, hidden 값 가져올 수 있도록 처리
                    var strValue = $(this).text() == "" ? $(this).val() : $(this).text();
                    strValue = strValue.replace(/'/g, "!!!!@@@@####^^^^");
                    strValue = strValue.replace(/\\/g, "!!!!@@@@####&&&&");

                    //var bodyContext = $.parseXML("<?xml version='1.0' encoding='utf-8'?>" + getInfo("BodyContext"));
                    //strValue = $(bodyContext).find(strField).text();

                    // JSON 파라미터 구성
                    strXml = strXml + "<param>";
                    strXml = strXml + "<connect>" + strConnectString + "</connect>";
                    strXml = strXml + "<tablename>" + strTable + "</tablename>";
                    strXml = strXml + "<columnname>" + strField + "</columnname>";
                    strXml = strXml + "<columnvalue><![CDATA[" + strValue + "]]></columnvalue>";
                    strXml = strXml + "</param>";
                });
                strXml = strXml + "</params>";

                if (strXml != "<params></params>") {
                    CFN_PageMethodJSON_Url("/WebSite/Approval/Forms/Templates/xform/xform_sap.aspx", "SetDataInsert", "{strXml:'" + strXml
                        + "'}", false, function (pResult, pContext) {
                            if (pResult != "") {
                                if (pResult.d.indexOf('ERROR') == 0) {
                                    alert(pResult.d);
                                    bErrorYN = true;
                                }
                            }
                        });
                }
            }
        }
    }

    return bErrorYN;
}

function getLngLabel(szLngLabel, szType, szSplit) {
    var rtnValue = "";
    if(szLngLabel){
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
	        return CFN_GetDicInfo(sValue02);
	    } else {
	        var sValue02 = szLngLabel;
	        if (szType) {
	
	        	sValue02 = szLngLabel.substring(szLngLabel.indexOf(";") + 1);
	        }
	        return CFN_GetDicInfo(sValue02);
	    }
    }else{
    	return "";
    }
}

// 대성: 수동 결재 함수 추가 - 관리자 소스 복사함 ==========================================
function autoAllApproved() {
	Common.Progress();
	
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
				sComment = Base64.utf8_to_b64(document.getElementById("ACTIONCOMMENT").value);
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
			parent.Common.Inform(Common.getDic("msg_apv_alert_006"), "Information", function(){
    			opener.location.reload();
    			Common.Close();
    		}); //성공하였습니다.
		}
    }, 500);
}

//get tasks
function getActTasks(){
	$.ajax({
	    url: "admin/getacttasks.do",
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
			CFN_ErrorAjax("getacttasks.do", response, status, error);
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
		url:"draft.do",
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
	    		Common.Error(res.message);
	    	}
	    },
	    error:function(response, status, error){
			CFN_ErrorAjax("draft.do", response, status, error);
		}
	});
}

function getUserSignInfo(usercode){
	var retVal = "";
	
	$.ajax({
	    url: "user/getUserSignInfo.do",
	    type: "POST",
	    data: {
			"UserCode" : usercode
		},
		async:false,
	    success: function (res) {
	    	if(res.status == 'SUCCESS'){
	    		retVal = res.data;
	    	} else if(res.status == 'FAIL'){
	    		Common.Error(res.message);
	    	}
        },
        error:function(response, status, error){
			CFN_ErrorAjax("getUserSignInfo.do", response, status, error);
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

// 문서수발신 담당자 확인
function chkDocManager(){
	var res = false;
	var userCode = Common.getSession("USERID");
	
	$.ajax({
		url: "/approval/user/getGovDocInOutManager.do",
		type: "post",
		data: {
			"deptCode": Common.getSession("DEPTID")
		},
		async: false,
		success: function(data) {
			var list = data.list;
			
			if(list != null && list != ""){
				$.each(list, function(idx, item){
					if(item.ListAuthorityID.indexOf(userCode) != -1){
						res = true;
						return false;
					}
				});
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/approval/user/getGovDocInOutManager.do", response, status, error);
		}
	});
	
	return res;
}

function SummaryPopupOpen() {
	var type = getInfo("Request.templatemode");
    var sUrl = "form/goSummaryPopup.do?type=" + type;
    var iHeight = 550; var iWidth = 500;
    
    CFN_OpenWindow(sUrl, "", iWidth, iHeight, "resize");
}

//전자결재 EDMS 파일첨부 
function AddEdmsFile(){
	// Fix EDMS MenuId
	var edmsMenuId = Common.getBaseConfig("DocMenu");
	var sUrl = "/groupware/board/goSearchMessagePopup.do?mode=Approval&modeType=Attach&bizSection=Doc&menuID="+edmsMenuId;
	
	// Callback setting.
	window._CallBackMethod = function(fileArr){
		callBackAddEdmsFile(fileArr);
	};
	CFN_OpenWindow(sUrl, "", 850, 660, "fix");
}

function callBackAddEdmsFile(files){
	// 파일 선택 시 파일명 중복 검사
	var nLength = files.length;
	var oFileInfo = JSON.parse(JSON.stringify(files));// IE 는 팝업의 객체이므로 참조를 잃는다.
	var bCheck = false;
	var aObjFiles = [];
	var fileDisenableName = Common.getBaseConfig("DisenableFileName").split("|");

	for (var i = 0; i < nLength; i++) {
		oFileInfo[i].attachType = "edms";
		oFileInfo[i].name = oFileInfo[i].FileName;
		oFileInfo[i].savedName = oFileInfo[i].fullPath;// relative path
		oFileInfo[i].size = oFileInfo[i].Size;
	}
	
	for (var i = 0; i < nLength; i++) {
		for (var j = 0; j < l_aObjFileList.length; j++) {
			if (oFileInfo[i].name == l_aObjFileList[j].name) { // 중복됨
				bCheck = true;
				parent.Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
				break;
			} else { // 중복안됨
				bCheck = false;
			}
		}
		var $chkFiles = $("input[name=chkFile]");
		for (var k = 0; k < $chkFiles.length; k++) {
			if (oFileInfo[i].name == $chkFiles.eq(k).val().split(":")[1]) { // 중복됨
				bCheck = true;
				parent.Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
				break;
			} else { // 중복안됨
				bCheck = false;
			}
		}
		for (var l = 0; l < fileDisenableName.length; l++){
			if(fileDisenableName[l] != "" && oFileInfo[i].name.indexOf(fileDisenableName[l]) > -1){
				var warningComment = Common.getDic("msg_disenableFileName") + " " + fileDisenableName.join(", ");
				parent.Common.Warning(warningComment.substr(0, warningComment.length - 2));
				bCheck = true;
				break;
			}
		}
		if (!bCheck) {
			aObjFiles.push(oFileInfo[i]);
		}
	}
	// CommonControls.js 함수 call.
	readfiles(aObjFiles);
	SetFileInfo(aObjFiles);
	
	setSeqInfo();
}


// oucode / personcode 가 없는 결재선 체크
// 1. 체크할 값을 aApprovalLine 에 바인딩.
// 2. 바인딩 된 데이터 기준 검사
function bool_ApvValidationCheck() {
	var bReturn = true;
	var aApprovalLine = new Array();
	try {
		var oApvList = $.parseJSON(document.getElementById("APVLIST").value);
		var nLength = $$(oApvList).find("steps>division>step").concat().length;
		
		// 1. 체크할 값을 aApprovalLine 에 바인딩.
		for (var k = 0; k < nLength; k++) {
        	var oStep = $$(oApvList).find("steps>division>step").concat().eq(k);
        	
        	var sStepPath = oStep.path();
			var sOUCode = "";
			var sPersonCode = "";
			if ((oStep.attr("ou") != null) &&
				(oStep.attr("ou").length == null)) { // ou가 1개
				if (oStep.attr("unittype") == "ou") {
					sOUCode = oStep.attr("ou").code;
					sPersonCode = "";
				}
				else if(oStep.find("role").length > 0){
					sOUCode =oStep.find("role").attr("oucode");
					sPersonCode = oStep.find("role").attr("code");
				}
				else {
					sOUCode = oStep.attr("ou").person.oucode;
					sPersonCode = oStep.attr("ou").person.code;
				}
				if (sOUCode == null) { sOUCode = ""; }
				if (sPersonCode == null) { sPersonCode = ""; }
				
				var aTemp = new Array();
				aTemp.push(sStepPath);
				aTemp.push(sOUCode);
				aTemp.push(sPersonCode);
				aApprovalLine.push(aTemp);
			}
			else { // ou가 n개(병렬)
				if (oStep.attr("unittype") == "ou") {
					for(var i = 0; i < oStep.attr("ou").length; i++) {
						sOUCode = oStep.attr("ou")[i].code;
						sPersonCode = "";
						if (sOUCode == null) { sOUCode = ""; }
						if (sPersonCode == null) { sPersonCode = ""; }
				
						var aTemp = new Array();
						aTemp.push(sStepPath);
						aTemp.push(sOUCode);
						aTemp.push(sPersonCode);
						aApprovalLine.push(aTemp);
					}
				}
				else {
					for(var i = 0; i < oStep.attr("ou").length; i++) {
						sOUCode = oStep.attr("ou")[i].person.oucode;
						sPersonCode = oStep.attr("ou")[i].person.code;
						if (sOUCode == null) { sOUCode = ""; }
						if (sPersonCode == null) { sPersonCode = ""; }
				
						var aTemp = new Array();
						aTemp.push(sStepPath);
						aTemp.push(sOUCode);
						aTemp.push(sPersonCode);
						aApprovalLine.push(aTemp);
					}
				}
			}
		}
		
		// 2. 바인딩 된 데이터 기준 검사
		for (var j = 0; j < aApprovalLine.length; j++) {
			var nDivision = 0;
			var nStartStep = 1;
			var sStepPath = aApprovalLine[j][0];
			var sDivision = sStepPath.split("/")[2];
			if (sDivision.indexOf("[") <= 0) {
				nDivision = -1;
			}
			else {
				if (sDivision.indexOf("[" + nDivision + "]") <= 0) {
					nDivision++;
					nStartStep = j + 1;
				}
			}
	
			if ((aApprovalLine[j][1] == "") &&
				(aApprovalLine[j][2] == "")) {
					
				/*var sMessage = "";
				if (nDivision !== -1 && nDivision === 0) {
					sMessage = "1 발신 ";
				}
				else {
					sMessage = (nDivision + 1).toString() + " 담당 ";
				}*/
				
				var sRank = "";
				if (j - nStartStep + 2 < 10) {
					//sRank = "0" + (j - nStartStep + 2).toString() + " 번째";
					sRank = "(" + Common.getDic("lbl_apv_no") + " : " + (j - nStartStep + 2).toString() + ") "; // (순번 : n) 
				}
				Common.Warning(sRank + Common.getDic("lbl_apv_lineNoneApprover"), "", function () { // 결재자가 설정되어 있지 않습니다.<br />결재선을 확인하여 주십시오.
					document.getElementById("btLine").click();
				});
				return false;
			}
		}
	}
	catch (ex) {
		Common.Warning(Common.getDic("lbl_apv_lineChkError") + "<br />" + ex.toString()); // 결재선 확인 중 오류
		bReturn = false;
	}
	return bReturn;
}

/**
 * 사용자 전자결재 비밀번호 확인
 * @param strPassword
 * @returns {Boolean}
 */
function chkCommentWrite(strPassword){
	var returnval = false;
	$.ajax({
		url:"/approval/chkCommentWrite.do",
		type:"post",
		data: {
			"ur_code" : Common.getSession("USERID"),
			"password" : aesUtil.encrypt(proaas, proaaI, proaapp, strPassword)
		},
		async:false,
		success:function (res) {				
			if(res){					
				returnval = true;					
			} else {					
				returnval = false;
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/chkCommentWrite.do", response, status, error);
		}
	});
	return returnval;
}

//사용자 전자결재 비밀번호 사용유무 조회
function chkUsePasswordYN(){
	var returnval = false;
	
	$.ajax({
		url:"/approval/chkUsePasswordYN.do",
		type:"post",
		data: {
			"ur_code" : Common.getSession("USERID")
		},
		async:false,
		success:function (res) {				
			if(res){					
				returnval = true;					
			} else {					
				returnval = false;
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/chkUsePasswordYN.do", response, status, error);
		}
	});
	return returnval;
}

// 문서연결 팝업창 오픈
function openDocLink() {
	var iWidth = 1040; 
	var iHeight = 660; 
	var sSize = "fix";

    var sUrl = "goDocListSelectPage.do";
    if (openMode == "L" || openMode == "P") {
        var nLeft = (screen.width - iWidth) / 2;
        var nTop = (screen.height - iHeight) / 2;
        var sWidth = iWidth.toString() + "px";
        var sHeight = iHeight.toString() + "px";
        parent.Common.ShowDialog("btDocLink", "DivPop_" + openID, $("#btDocLink").text(), sUrl + "?openID=" + openID, sWidth, sHeight, "iframe-ifNoScroll");    // 레이블 수정 필요.
    } else {
        if (location.href.indexOf("/Approval/ApprovalWrite") > -1) {
            return Common.ShowDialog("btDocLink", "DivPop_" + openID, "연관문서", sUrl + "?openID=" + openID, iWidth, iHeight, "iframe-ifNoScroll");
        } else {
            CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
        }
    }
}


//기록물철 팝업창 오픈
function openRecordDocLink() {
	//type=rc 기록물철 버튼으로 팝업
	var type = "rc";
	if(getInfo("ExtInfo.UseMultiEditYN")=="Y") type = "rcm";
	var idx = "1";
	if($("#writeTab li.on").attr("idx")) idx = $("#writeTab li.on").attr("idx");
	var sUrl ="form/goRecordRefSelectPopup.do?type="+type+"&idx="+idx;
	var iHeight = 650; 
	var iWidth = 1500;	

	  CFN_OpenWindow(sUrl, "", iWidth, iHeight, "fix");	
}

// EDMS 문서연결 팝업창 오픈
function openEDMSDocLink() {
	// Fix EDMS MenuId
	var edmsMenuId = Common.getBaseConfig("DocMenu");
	var sUrl = "/groupware/board/goSearchMessagePopup.do?mode=Approval&modeType=Link&bizSection=Doc&menuID="+edmsMenuId;
	
	// Callback setting.
	window._CallBackMethod = function(linkDocArr){
		EDMSDocLinks.addItem(linkDocArr);
	};
	CFN_OpenWindow(sUrl, "", 850, 660, "fix");
}

//기안 전 결재선 validation 체크
function chkAutoValApprovalLine() {
	//결재선 중복체크
	if(getInfo("SchemaContext.scChkDuplicateApv.isUse")=="Y") {
		if(chkDupApprovalLine()) {
	        return true;
		}
	}
	
	//TO-BE 이외 조건 추가
}

function chkDupApprovalLine(userCode) {
    var dupCnt = 0;
	var apvlist = $.parseJSON(document.getElementById("APVLIST").value);
	// 결재선 사용자 코드 (ApvlineManager.js 중복체크 조건과 동일)
	var arrPersonCode = [].concat($$(apvlist).find("steps>division").concat()
		.find("step[unittype!='ou']>ou>person[code][taskinfo]")
		.has("taskinfo[kind!='conveyance'][kind!='substitute']").attr('code'));

    // 중복 결재자 수
    if(!userCode) {
    	dupCnt = arrPersonCode.filter((code,idx) => arrPersonCode.indexOf(code) !== idx).length;
    }
    // 특정 사용자 중복 확인
    else if(userCode) {
    	dupCnt = arrPersonCode.filter(code => code == userCode).length;
    }
    
    if(dupCnt > 0) {
    	alert(Common.getDic("msg_apv_519")); //중복된 결재자가 있습니다.
        return true;
    }
}

//결재선 필수체크
function chkAutoApprovalLine(){
	
	//결재팝업 호출 여부
	var apvlinePopupYN; //결재선지정 팝업여부
	try{
		if(typeof chkAutopopup != "undefined" && chkAutopopup!='') apvlinePopupYN = true;
	}catch(e){
		coviCmn.traceLog(e);
	}

    //합의자 체크
    if (getInfo("AutoApprovalLine.Agree.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != undefined) {
            var oAutoLineAgree = $.parseJSON(getInfo("AutoApprovalLine.Agree.WorkedApprovalLine"));
            if ($$(oAutoLineAgree).find("step").concat().length > 0) {
            	var jsonApv;
				if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                else jsonApv = chkAutopopup.$$_m_oApvList;
                var oAppList = $$(jsonApv).find("steps>division[divisiontype='send']>step[routetype='consult'][unittype='person']");
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
                        //sAlert += " " + getLngLabel(elm.attr("position"), true);
                        g_DisplayJobType && (sAlert += " " + getLngLabel(elm.attr(g_DisplayJobType), true));
                    });
                    
                    sAlert += "]";
                    sAlert = Common.getDic("msg_apv_autoChkAgree").replace("{0}", sAlert);
                    if(!apvlinePopupYN){
                    	alert(sAlert);
                        return true;	
                    }else{
                    	chkAutopopup.alert(sAlert);
                    	return true;
                    }
                }
            }
        }
    }
    //협조자 체크
    if (getInfo("AutoApprovalLine.Assist.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.Assist.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Assist.WorkedApprovalLine") != undefined) {
            var oAutoLineAssist = $.parseJSON(getInfo("AutoApprovalLine.Assist.WorkedApprovalLine"));
            if ($$(oAutoLineAssist).find("step").concat().length > 0) {
				var jsonApv;            	
				if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                else jsonApv = chkAutopopup.$$_m_oApvList;
                var oAppList = $$(jsonApv).find("steps>division[divisiontype='send']>step[routetype='assist'][unittype='person']");
                for (var i = 0; i < $$(oAppList).find("ou>person").concat().length; i++) {
                    var oChkNode = $$(oAutoLineAssist).find("step>ou").has("person>[code='" + $$(oAppList).find("ou>person").concat().eq(i).attr("code") + "']");
                    if (oChkNode.length > 0) {
                        $$(oChkNode).remove();
                    }
                }
                if ($$(oAutoLineAssist).find("step>ou>person").concat().length > 0) {
                    var sAlert = "[";
                    $$(oAutoLineAssist).find("step>ou>person").concat().each(function(i, elm){
                    	if (i > 0) sAlert += ", ";
                        sAlert += getLngLabel(elm.attr("name"), false);
                        //sAlert += " " + getLngLabel(elm.attr("position"), true);
                        g_DisplayJobType && (sAlert += " " + getLngLabel(elm.attr(g_DisplayJobType), true));
                    });
                    
                    sAlert += "]";
                    sAlert = Common.getDic("msg_apv_autoChkAssist").replace("{0}", sAlert);
                    if(!apvlinePopupYN){
                    	alert(sAlert);
                        return true;	
                    }else{
                    	chkAutopopup.alert(sAlert);
                    	return true;
                    }
                }
            }
        }
    }
    //결재자 체크
    if (getInfo("AutoApprovalLine.Approval.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.Approval.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Approval.WorkedApprovalLine") != undefined) {
            var oAutoLineApproval = $.parseJSON(getInfo("AutoApprovalLine.Approval.WorkedApprovalLine"));
            if ($$(oAutoLineApproval).find("step").concat().length > 0) {
				var jsonApv;            	
				if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                else jsonApv = chkAutopopup.$$_m_oApvList;
                var oAppList = $$(jsonApv).find("steps>division[divisiontype='send']>step[name!='reference'][routetype='approve'][unittype='person']").has("ou>person>taskinfo[kind!=skip]");
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
                        //sAlert += " " + getLngLabel($$($$(oAutoLineApproval).find("step").concat().eq(i)).find("ou > person").attr("position"), true);
                        g_DisplayJobType && (sAlert += " " + getLngLabel($$($$(oAutoLineApproval).find("step").concat().eq(i)).find("ou > person").attr(g_DisplayJobType), true));
                    }
                    sAlert += "]";
                    sAlert = Common.getDic("msg_apv_autoChkApproval").replace("{0}", sAlert);
                    if(!apvlinePopupYN){
                    	alert(sAlert);
                        return true;	
                    }else{
                    	chkAutopopup.alert(sAlert);
                    	return true;
                    }
                }
            }
        }
    }
    //참조자 체크
    if (getInfo("AutoApprovalLine.CCAfter.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != undefined) {
            var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine"));
            if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
				var jsonApv;
            	if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                else jsonApv = chkAutopopup.$$_m_oApvList;
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
                            //sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("position"), true);
                            g_DisplayJobType && (sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr(g_DisplayJobType), true));
                        }
                    }
                    sAlert += "]";
                    sAlert = Common.getDic("msg_apv_autoChkCC").replace("{0}", sAlert);
                    if(!apvlinePopupYN){
                    	alert(sAlert);
                        return true;	
                    }else{
                    	chkAutopopup.alert(sAlert);
                        return true;
                    }
                }
            }
        }
    }
    //참조자 체크(사전)
    if (getInfo("AutoApprovalLine.CCBefore.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine") != undefined) {
            var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine"));
            if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
				var jsonApv;
            	if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                else jsonApv = chkAutopopup.$$_m_oApvList;
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
                            //sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("position"), true);
                            g_DisplayJobType && (sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr(g_DisplayJobType), true));
                        }
                    }
                    sAlert += "]";
                    sAlert = Common.getDic("msg_apv_autoChkCC").replace("{0}", sAlert);
                    if(!apvlinePopupYN){
                    	alert(sAlert);
                        return true;	
                    }else{
                    	chkAutopopup.alert(sAlert);
                    	return true;
                    }
                }
            }
        }
    }
}


// 다안기안 + 문서유통
// 다안기안 + 문서유통 문서 여부
function isGovMulti(obj) {
	let rtn = false;
	if (obj == undefined) {
		if ((getInfo("ExtInfo.UseWebHWPEditYN") == "Y" || getInfo("ExtInfo.UseEditYN") == "Y") && getInfo("ExtInfo.UseMultiEditYN") == "Y" && getInfo("SchemaContext.scDistribution.isUse") == "Y") rtn = true;
	} else {
		if ((obj.getInfo("ExtInfo.UseWebHWPEditYN") == "Y" || obj.getInfo("ExtInfo.UseEditYN") == "Y") && obj.getInfo("ExtInfo.UseMultiEditYN") == "Y" && obj.getInfo("SchemaContext.scDistribution.isUse") == "Y") rtn = true;
	}
	return rtn;
}

/**
 ********************************************************************************************************
 ******************************************* 문서유통 기능 *************************************************
 ********************************************************************************************************
 2022-11-04 대외공문(문서유통) 문서마다 동일하게 들어가있는 함수들을 공통으로 뺐음.
 */
 
// 대외공문(문서유통) 접수문서 여부 확인
const checkGovReceiveDoc = function(){
	var FormInstID = getInfo("FormInstanceInfo.FormInstID");

	if(getInfo("FormInstanceInfo.FormInstID") == undefined){
		result = "N";
	} else {
		$.ajax({
		    url: "user/CheckGovReceiveDoc.do",
		    type: "POST",
		    data: { FormInstID },
			async:false,
		    success: function (res) {
		    	if(res.status == 'SUCCESS'){
		    		result = res.message;
		    	} else if(res.status == 'FAIL'){
		    		// 대외시행문 수신문서 X
		    		result = res.message;
		    	}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("CheckGovReceiveDoc.do", response, status, error);
			}
		});
	}
	return result;
};

const convertHWP = function(html){
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
};

// 대외공문(문서유통) 거부 => 사용안함
const govDocDeny = function(){
	Common.Confirm("전자문서를 거부합니다.", "Confirmation Dialog", function (result) {
		if(result){
			updateReceiveState("deny").done(function(data){
				data.cnt === 1 && Common.Inform("거부되었습니다.", "Inform Dialog", function(){
					opener.docFunc.refresh();
					this.close();
				});
			}).fail(function(e){
				Common.Error(Common.getDic("msg_apv_030") + " : " + e);
				console.log(e);
			});
		}
	});
};

// 대외공문(문서유통) 접수
const govDocAccept = function(){
	govDocReceiveStateUpdate("accept", "전자문서를 접수합니다.", "접수되었습니다.");
};

// 대외공문(문서유통) 재발송 요청
const govDocReqResend = function(){
	govDocReceiveStateUpdate("req-resend", "전자문서를 재발송 요청합니다.", "재발송 요청되었습니다.");
};

// 대외공문(문서유통) 반송
const govDocReject = function(){
	// 2022-11-01 수정 : 수신함에서 수신상태 문서를 반송할때 사용
	govDocReceiveStateUpdate("return", "전자문서를 반송합니다.", "반송되었습니다.");
};

// 대외공문(문서유통) 수신문서 상태값 변경
const govDocReceiveStateUpdate = function(status, confirmMsg, completeMsg) {
	Common.Confirm(confirmMsg, "Confirmation Dialog", function (result) {
		if(result){
			updateReceiveState(status).done(function(data){
				data.cnt === 1 && callAcker(status).done(function(){
					Common.Inform(completeMsg, "Inform Dialog", function(){ 
						opener.docFunc.refresh();
						this.close();
					});
				}).fail(function(e){
					Common.Error(Common.getDic("msg_apv_030") + " : " + e);
					console.log(e);
				});
			}).fail(function(e){
				Common.Error(Common.getDic("msg_apv_030") + " : " + e);
				console.log(e);
			});
		}
	});
};

// 대외공문(문서유통) 배부
const startDistribution = function(dataInfo) {
	$.ajax({
		type:"POST",
		url : "/approval/legacy/startDistribution.do",
		data : {
			"DistributionInfo": dataInfo
		},
		dataType: "json", // 데이터타입을 JSON형식으로 지정
		success:function(res){
			if(res.result == 'ok'){
				updateReceiveState("distribute", dataInfo).done(function(data){
					if(data.cnt === 1){
						Common.Inform(Common.getDic("msg_apv_alert_006"), "Inform Dialog", function(){ 
							opener.docFunc.refresh();
							this.close();
						});
					}
				}).fail( function(e){  console.log(e) });
			} else {
				Common.Error(res.message);
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/legacy/startDistribution.do", response, status, error);
		}
	});
}

// 수신문서 상태값 변경
const updateReceiveState = function(status, dis){
	var deferred = $.Deferred();
	var sendData = {
			formInstId 	: formJson.FormInstanceInfo.FormInstID
			,status		: status
			,distribDeptId : ''
		    ,distribDeptName : ''
		};
	if (status == "distribute"){
		var dataInfo = JSON.parse(dis);
		for(var i=0; i<dataInfo.receiptList.length; i++){
			sendData["distribDeptId"]   += dataInfo.receiptList[i].code;
			sendData["distribDeptName"] += dataInfo.receiptList[i].name;
		}
	}
	$.ajax({
		url: "user/updateGovReceiveStatus.do",
		type:"POST",
		data: sendData,
		success:function (data) { deferred.resolve(data);},
		error:function(response, status, error){ deferred.reject(status); }
	});
 	return deferred.promise();
};

// 문서유통 Acker 호출
const callAcker = function(status){
	var deferred = $.Deferred();
	$.ajax({
		url: "/approval/govDocs/callAcker.do",
		type:"POST",
		data: {
			formInstId 	: formJson.FormInstanceInfo.FormInstID
			,status		: status
		},
		success:function (data) { deferred.resolve(data); },
		error:function(response, status, error){ deferred.reject(status); }
	});
 	return deferred.promise();
};

//접수대기문서정보
function displayDocInfo() {
	if(document.getElementById("docInfoTB") != null) {
		if(document.getElementById("docInfoTB").style.display == "") {
			document.getElementById("docInfoTB").style.display = "none";
			//document.getElementById("bodytable").style.top = "100px";
			//document.getElementById("divMenu02").style.top = "10px";
		}else {
			document.getElementById("docInfoTB").style.display = "";	
			//document.getElementById("bodytable").style.top = "290px";
			//document.getElementById("divMenu02").style.top = "223px";
		}
	}
}

// 문서유통 다안기안 발송버튼 이벤트
// XML이 생성된다.
var callPacker = function(status) {
	var rowSeq = new URLSearchParams(location.search).get("rowSeq");
	var ismulti = "N"
	
	if(formJson.BodyData.SubTable1 != null){
		var row = formJson.BodyData.SubTable1.filter(subTable => subTable.MULTI_ROWSEQ == rowSeq)[0];
		ismulti = "Y";
	}
	
	if(typeof HwpCtrl != "undefined"){
		HwpCtrl.MoveToField('body', true, true, true);
		HwpCtrl.SaveAs("test.xml", "PUBDOCBODY", "saveblock;", function (res) {
	    	$.ajax({
				url: "/govdocs/service/callPacker.do", // local:govdocs, prd:covigovdocs
				type:"POST",
				data: {
					formInstId: formJson.FormInstanceInfo.FormInstID,
					processId: formJson.FormInstanceInfo.ProcessID,
					uniqueID: typeof row != "undefined" ? row.UNIQUEID : "",
					type : status || "send",
					bodyUrl: res.downloadUrl,
					bodySize: res.size,
					bodyUniqueID: res.uniqueId,
					isMulti : ismulti
				},				
				success:function (data) { 
					if(data.status === "OK"){
						data.status === "OK" && Common.Inform("발송되었습니다.","",function(){ 
							$("#btGovDocsSend").hide();
							$("#btGovDocsReSend").hide();
							opener.docFunc.refresh(); 
							window.close();
		                });
					}else{
						Common.Inform("처리 실패하였습니다.", 'Information Dialog', null);
					}
				},  
				error:function(response, status, error){ 
					Common.Inform("처리 실패하였습니다.", 'Information Dialog', null);
				}
			});
		});
		HwpCtrl.MoveToField('body', true, true, false);
	}else{
		var bodyContextXml;
		// 단건
		if(ismulti == "N"){
			bodyContextXml = formJson.BodyContext.tbContentElement.replace("<br>","").replace(/<(\/span|span)([^>]*)>/gi,"");
		}else{
		// 다안
			var subTable = formJson.BodyData.SubTable1[rowSeq-1];
			var tbContentElement = Base64.b64_to_utf8(subTable.MULTI_BODY_CONTEXT_HTML);
			bodyContextXml = tbContentElement.replace("<br>","").replace(/<(\/span|span)([^>]*)>/gi,"");
		}
		
	    	$.ajax({
				url: "/govdocs/service/callPacker.do", // local:govdocs, prd:covigovdocs
				type:"POST",
				data: {
					formInstId: formJson.FormInstanceInfo.FormInstID,
					processId: formJson.FormInstanceInfo.ProcessID,
					uniqueID: typeof row != "undefined" ? row.UNIQUEID : "",
					type : status || "send",
					bodyContext : bodyContextXml,
					isEditor : "Y",
					isMulti : ismulti
					
				},				
				success:function (data) { 
					if(data.status === "OK"){
						data.status === "OK" && Common.Inform("발송되었습니다.","",function(){ 
							$("#btGovDocsSend").hide();
							$("#btGovDocsReSend").hide();
							opener.docFunc.refresh(); 
							window.close();
		                });
					}else{
						Common.Inform("처리 실패하였습니다.", 'Information Dialog', null);
					}
				},  
				error:function(response, status, error){ 
					Common.Inform("처리 실패하였습니다.", 'Information Dialog', null);
				}
			});
	}
}


//문서유통 > 기안시에 XML 사이즈 체크

var callCheckSize = function(status) {
	var rowSeq =1;
	var ismulti = "N"
	var curIdx = $("#writeTab li.on").attr("idx");//현재 활성화 되어 있는 안
	var message = "";
	
	if(formJson.BodyData.SubTable1 != null){
		var row = 1;
		ismulti = "Y";
	}
	
	HwpCtrl.MoveToField("body", true, true, true);
	HwpCtrl.SaveAs("test.xml", "PUBDOCBODY", "saveblock;", function (res) {//현재 본문 다운url  
		document.getElementsByName("MULTI_BODYURL")[curIdx].value = res.downloadUrl
	});	
	
	
	if(typeof HwpCtrl != "undefined"){
		for(i=1; i<=$("#writeTab li").length; i++){
			if(document.getElementsByName("MULTI_APV_RECEIVER_TYPE")[i].value =="else" ){// 시행문 경우만 
	    	$.ajax({
				url: "/govdocs/service/callCheckSize.do", 
				type:"POST",
				async: false,
				data: {
					formInstId: formJson.FormInstanceInfo.FormInstID,
					processId: formJson.FormInstanceInfo.ProcessID,
					receiveInfo : document.getElementsByName("MULTI_RECEIVENAMES")[i].value, 
					bodyUrl: document.getElementsByName("MULTI_BODYURL")[i].value,
				    apvcontext :  document.getElementById("APVLIST").value,
				    seal : document.getElementsByName("MULTI_STAMP")[i].value,
				    logo : document.getElementsByName("MULTI_LOGO")[i].value ,
				    symbol : document.getElementsByName("MULTI_SYMBOL")[i].value 
				},				
				success:function (data) { 
					if(data.status === "OK"){
						if(data.bodysize > 10){
							message += i+"안 : "+ (data.bodysize-10).toFixed(2) + "MB를 초과하였습니다.<br>";
						}

					}else{

					}
				},  
				error:function(response, status, error){ 
					Common.Error("처리 실패하였습니다.", 'Information Dialog', null);
				}
			});
		  }
		}
		if(message != ""){
			Common.Error("<br>"+ message +" 10MB이하만 상신가능 합니다."); 
		}
		else{
			m_legacyChked++;
			$("#btDraft").click();
		}
		
		HwpCtrl.MoveToField('body', true, true, false);
	}

}

//추가발송, 중복발송
function btSend_Click() {
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=OrgMap_CallBack&szObject=&type="+"D9"+"&setParamData=_setParamdata", "", "1060px", "580px");
}

//배부이력
function govDocDistInfo(){
	CFN_OpenWindow("goReceiptReadListPage.do?" + "&ProcessID=0" + "&FormInstID=" + getInfo("FormInstanceInfo.FormInstID") + "&GovDocs=distribution", "", "1060px", "580px");
}

function OrgMap_CallBack(pStrItemInfo) {
    var oJsonOrgMap = $.parseJSON(pStrItemInfo);
    
    
    var approvalLineObj ={
    	steps : {
    		datecreated : "2020-07-06 07:19:18"	
    	   		,division : {
    	   			divisiontype	: "send"
    				,name	: Common.getDic("lbl_apv_circulation_sent")
    				,oucode	: getInfo("AppInfo.dpid_apv")
    				,ouname	: getInfo("AppInfo.dpdn_apv")
    				,status : "complete"
    				,taskinfo : {				
    					status 	: "complete"
    	                ,result : "complete"
    	                ,kind 	: "send"
    	                ,datereceived : getInfo("AppInfo.svdt_TimeZone")
                        ,visible: "n"
    				}
    				,step : {
    					unittype : "person"
    					,routetype : "approve"
    					,name : Common.getDic("lbl_apv_writer")
    					,ou : {
    						code : getInfo("AppInfo.dpid_apv")
    						,name : getInfo("AppInfo.dpdn_apv")
    						,person : {
    							code 		: getInfo("AppInfo.usid")
    	                        ,name 		: getInfo("AppInfo.usnm_multi")
    	                        ,position 	: getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi")
    	                        ,title 		: getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi")
    	                        ,level 		: getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi")
    	                        ,oucode 	: getInfo("AppInfo.dpid")
    	                        ,ouname 	: getInfo("AppInfo.dpnm_multi")
    	                        ,sipaddress : getInfo("AppInfo.ussip")
    	                        ,taskinfo	: {
    	                        	status 	: "complete"
    	                            ,result : "complete"
    	                            ,kind 	: "charge"
    	                            ,datereceived : getInfo("AppInfo.svdt_TimeZone")
    	                            ,visible: "n"
    	                        }
    						}
    					}
    				}    	
    	   		}
    	}	
    } 
   
    
    if (oJsonOrgMap != null) {
    	m_oInfoSrc.m_bFrmExtDirty = true; 
    	
    	var objArr_person = new Array();
    	var objArr_ou = new Array();
    	
    	var dataInfo = {};
    	var dataInfoStr = "";
    	//dataInfo.piid = m_oInfoSrc.getInfo("ProcessInfo.ParentProcessID");    	
    	dataInfo.piid = "0";    	
    	dataInfo.approvalLine = JSON.stringify(approvalLineObj);    	
    	dataInfo.docNumber = m_oInfoSrc.getInfo("FormInstanceInfo.DocNo");
    	dataInfo.context = JSON.stringify(m_oInfoSrc.getDefaultJSON());
    	
        var strflag = true;

        var oChildren = $$(oJsonOrgMap).find("item");
        $$(oChildren).concat().each(function (i, oChild) {
        	var dataInfo_receiptList = {};
        	
            var cmpoucode = ";" +  $$(oChild).attr("AN") + ";";
            if (m_oInfoSrc.document.getElementById("ReceiptList").value.indexOf(cmpoucode) > -1) {
                strflag = false;
            }
            var currNode = {};
            if ($$(oChild).attr("itemType") == "user") {
            	$$(dataInfo_receiptList).attr("code", $$(oChild).attr("AN"));
            	$$(dataInfo_receiptList).attr("name", $$(oChild).attr("DN"));
            	$$(dataInfo_receiptList).attr("type", "1");
            	$$(dataInfo_receiptList).attr("status", "inactive");
            	
            	objArr_person.push(dataInfo_receiptList);
            } else {
            	$$(dataInfo_receiptList).attr("code", $$(oChild).attr("AN"));
            	$$(dataInfo_receiptList).attr("name", $$(oChild).attr("DN"));
            	$$(dataInfo_receiptList).attr("type", "0");
            	$$(dataInfo_receiptList).attr("status", "inactive");
            	
            	objArr_ou.push(dataInfo_receiptList);
            }
        });
        
        var sMsg = Common.getDic("msg_apv_191");//"해당 항목들을 발송하시겠습니까?"
        if(strflag == false) sMsg = Common.getDic("msg_apv_345");

        Common.Confirm(sMsg, "Confirmation Dialog", function (result) {
            if (result) {
            	if(objArr_person.length > 0) { // 사용자
            		dataInfo.receiptList = objArr_person;
            		dataInfo.type = "1";
            		
            		dataInfoStr = JSON.stringify(dataInfo);
            		
            		startDistribution(dataInfoStr);
            	}
            	
            	if(objArr_ou.length > 0) { // 부서
            		dataInfo.receiptList = objArr_ou;
            		dataInfo.type = "0";
            		
            		dataInfoStr = JSON.stringify(dataInfo);
            		
            		startDistribution(dataInfoStr);
            	}
            }
        });
    }
}
function mergeMultiRec() {
	//모든 안의 수신처 합치기
	var multiCount = $("#writeTab li").length;		
	document.getElementById("ReceiveNames").value = "";
	document.getElementById("ReceiptList").value = "";
	document.getElementById("RECEIVEGOV_NAMES").value = "";
	for(var i = 1; i < multiCount+1; i++) {
		var receiveType = document.getElementsByName("MULTI_RECEIVE_TYPE")[i].value;
		// 대내수신
		if (receiveType == 'inreceive') {
			document.getElementById("ReceiveNames").value += i == 1 ? document.getElementsByName('MULTI_RECEIVENAMES')[i].value :  ';' + document.getElementsByName('MULTI_RECEIVENAMES')[i].value;
		// 대외전자,대외종이
		} else {
			document.getElementById("RECEIVEGOV_NAMES").value += i == 1 ? document.getElementsByName('MULTI_RECEIVENAMES')[i].value : ';' + document.getElementsByName('MULTI_RECEIVENAMES')[i].value;
		}
	}
	//배포처 관련 시작
    var sRec0 = "";
    var sRec1 = "";
    var sRec2 = "";
    
    var aRecDept = document.getElementById("ReceiveNames").value.split(";");
    for (var i = 0; i < aRecDept.length; i++) {
        if (aRecDept[i] != "") {
            var aRec = aRecDept[i].split(":");
            if (aRec[0] == "0") {
                if (sRec0 == "") sRec0 += aRec[1] + "|" + aRec[3];
                else sRec0 += ";" + aRec[1] + "|" + aRec[3];
            } else if (aRec[0] == "1") {
                if (sRec1 == "") sRec1 += aRec[1];
                else sRec1 += ";" + aRec[1];
            } else {
                if (sRec2 == "") sRec2 += aRec[1];
                else sRec2 += ";" + aRec[1];
            }
        }
    }
    document.getElementById("ReceiptList").value = sRec0 + "@" + sRec1 + "@" + sRec2;
}