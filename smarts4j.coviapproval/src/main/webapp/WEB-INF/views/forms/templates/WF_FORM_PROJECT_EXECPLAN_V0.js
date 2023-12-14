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

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
            
        if ($("#select_project_name span").text() == "직접 입력") {
            $("#select_project_code_th").hide();
            $("#select_project_code").hide();
            $("#select_project_name_th").css("width", "12%");
            $("#select_project_name").hide();
            $("#input_self").show();
            $("#input_self").css("width", "88%");
            $("#input_self").css("border-top", "1px solid #c3d7df");
        }

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

		getData("");


        // 에디터 처리
         LoadEditor("divWebEditorContainer");

        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
   			document.getElementById("InitiatedDate").value = formJson.AppInfo.svdt; // 재사용, 임시함에서 오늘날짜로 들어가게함.
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);       
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        	
             // 임시저장 또는 재사용 시 저장하였던 프로젝트명 가져오기
            if (formJson.Request.mode == "TEMPSAVE" || getInfo("Request.reuse") == "Y" || getInfo("Request.reuse") == "P" || getInfo("Request.reuse") == "YH") {
                if (formJson.BodyContext.PROJECT_NAME != undefined) {
                    $("#PROJECT_NAME").val(formJson.BodyContext.PROJECT_NAME);
                }
            }

        }
        // 편집, 임시저장 또는 재사용 시 저장하였던 프로젝트명 가져오기
        if (formJson.Request.mode != "DRAFT") {
            if (formJson.BodyContext.PROJECT_NAME != undefined) {
                $("#PROJECT_NAME").val(formJson.BodyContext.PROJECT_NAME);
                PROJECTNAME();
            }
        }
    }
}


function PROJECTNAME() {
    //var project_name = $('#PROJECT_CODE').val();
    //$("#SUBJECT").val(m_oFormMenu.getLngLabel(getInfo("FormInfo.FormName") + " - " + project_name, false));
    var project_name = $('#PROJECT_NAME option:selected').text();
    if (project_name == "직접 입력") {
        $("#input_self").show();
        $("#PROJECT_NAME_INPUT").prop('required', true);
        $("#PROJECT_NAME_INPUT").addClass("input-required");
        $("#PROJECT_CODE").val("");
    } else {
        $("#input_self").hide();
        $("#PROJECT_NAME_INPUT").prop('required', false);
        $("#PROJECT_NAME_INPUT").removeClass("input-required");
        $("#PROJECT_CODE").val($("#PROJECT_NAME option:selected").val());
        if (formJson.Request.mode == "DRAFT" ){
        	$("#Subject").val(m_oFormMenu.getLngLabel(getInfo("FormInfo.FormName") + " - " + project_name, false));
        }
    }
}

function PROJECTNAME_INPUT() {
    $("#Subject").val(m_oFormMenu.getLngLabel(getInfo("FormInfo.FormName") + " - " + $("#PROJECT_NAME_INPUT").val(), false));
}

function setLabel() {
}

function setFormInfoDraft() {
}

//수주보고 연결 확인을 위한 함수
//function checkDoc() {
//    szdoclinks = document.getElementById("DOCLINKS").value;
//    var checkDocfmpf = false;
//    if (szdoclinks != null) {
//        var adoclinks = szdoclinks.split("^^^");
//        for (var i = 0; i < adoclinks.length; i++) {

//            var adoc = adoclinks[i].split("@@@");

//            if (adoc[1] == "WF_FORM_CONTRACT_DRAT") {
//                checkDocfmpf = true;
//            }
//        }
//    }
//    return checkDocfmpf;
//}

function checkForm(bTempSave) {
    if (bTempSave) {
        return true;
    } else {
        //if ($("#PROJECT_NAME option:selected").val() != "input_self") {
        //    if (!checkDoc()) {
        //        alert("해당 프로젝트와 관련된 수주보고 문서를 연결해주세요.");
        //        return false;
        //    }
        //}

        // 필수 입력 필드 체크
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

/* DB 데이터(프로젝트명)를 불러옴 */
function getData(pvalue) {
    var Sel_id = "PROJECT_NAME";
    
   /* var connectionname = "COVI_FLOW_SI_ConnectionString";
    var pXML = "dbo.usp_select_projectname_gw";
    var param_1 = "WF_FORM_PROJECT_EXECPLAN";
    var aXML = "<param><name>appr_key</name><type>nvarchar</type><length>20</length><value><![CDATA[" + param_1 + "]]></value></param>";
    var sXML = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql><type>sp</type>" + aXML + "</Items>";
    var szURL = "../getXMLQuery.aspx";
    */
    
   CFN_CallAjax("/approval/legacy/getProjectList.do", {"appr_key":"WF_FORM_PROJECT_EXECPLAN"}, function (data){ 
    	receiveHTTPGetData_SapBaseCode_master(data, Sel_id, pvalue); 
    },false,'json');
}


function receiveHTTPGetData_SapBaseCode_master(responseXMLdata, Sel_id, pvalue) {
    var xmlReturn = responseXMLdata;
    var elmlist = xmlReturn.Table;
    var Codegrp = '';

    $("select[id=" + Sel_id + "]").eq(0).append("<option value=''>선택</option>");
    $(elmlist).each(function () {
        //JOB_STATE_CD = G:회사일반 , P:프로젝트 , R:내부개발 , C:고객지원 , S:세일즈
        if (this.JOB_STATE_CD == "P") {
            $("select[id=" + Sel_id + "]").eq(0).append("<option value='" + this.JOB_NO + "'>" + this.JOB_NM + "</option>");
        }
    });
    $("select[id=" + Sel_id + "]").eq(0).append("<option value='input_self'>직접 입력</option>");
}