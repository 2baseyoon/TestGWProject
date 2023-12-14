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


//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();

    setReceiveGovInfo();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });


    }
    else {
        if (!_ie) {
            alert("해당 브라우져는 대외공문 작성기능을 지원하지 않습니다.\nInternet Explorer를 이용해주세요.");
            top.close();
        }

        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        LoadEditorHWP("divWebEditorContainer");

        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
        	document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }


    }
}

function setLabel() {
}

function setFormInfoDraft() {
}

function checkForm(bTempSave) {
    if (bTempSave) {
        return true;
    } else {
        // 필수 입력 필드 체크

        //if (document.getElementById("RECEIVEGOV_NAMES").value == "") {
        //    Common.Warning("대외수신처를 지정하세요.");
        //    return false;
        //}
        if (document.getElementById("FILEATTACH").value == "false") {
            Common.Warning("3MB이상으로는 파일을 올리지마세요.");
            return false;
        }
        return EASY.check().result;
    }
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

function setReceiveGovInfo() {
    if (formJson.BodyContext != null && formJson.BodyContext.RECEIVEGOV_NAMES != null) {
        var sReceiveGovNames = formJson.BodyContext.RECEIVEGOV_NAMES;
        var sReceiveGovInfo = "";

        for (var i = 0; i < sReceiveGovNames.split(";").length; i++) {
            if (sReceiveGovInfo == "") {
                sReceiveGovInfo = sReceiveGovNames.split(";")[i].split(":")[3];
            } else {
                sReceiveGovInfo += ", " + sReceiveGovNames.split(";")[i].split(":")[3];
            }
        }

        $("#RECEIVEGOV_INFO").get(0).innerHTML = sReceiveGovInfo;
    }
}

function setPubType(type) {
	if (getInfo("Request.templatemode") == "Read") {
    } else {
        if (type != "공개") {
            try { document.getElementsByName("PUBLICATION_2")[0].style.display = ""; } catch (e) { coviCmn.traceLog(e); }
        } else {
            try { document.getElementsByName("PUBLICATION_2")[0].style.display = "none"; } catch (e) { coviCmn.traceLog(e); }
        }
    }
}

function displayInputSend(obj) {
    if ($(obj).is(":checked") == true) {
        $("#INITIATOR_DEPT").css("display", "");
        $("select[name=SEND_DEPT]").css("display", "none");
    } else {
        $("#INITIATOR_DEPT").css("display", "none");
        $("#INITIATOR_DEPT").val("");
        $("select[name=SEND_DEPT]").css("display", "");
    }
}

//추가발송, 중복발송
function btSend_Click() {
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=OrgMap_CallBack&szObject=&type="+"D9"+"&setParamData=_setParamdata", "", "1060px", "580px");
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
    				,status : "pending"
    				,taskinfo : {				
    					status 	: "inactive"
    	                ,result : "inactive"
    	                ,kind 	: "send"
    	                ,datereceived : getInfo("AppInfo.svdt_TimeZone")
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
    	                        	status 	: "inactive"
    	                            ,result : "inactive"
    	                            ,kind 	: "charge"
    	                            ,datereceived : getInfo("AppInfo.svdt_TimeZone")
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