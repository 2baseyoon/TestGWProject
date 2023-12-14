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

    //기안부서 결재 완료시 테이블 보여주기
    var vApvlist = $.parseJSON($("#APVLIST").val());
    var vStepLen = $$(vApvlist).find("division").concat().eq(0).find("step").valLength();
    $$(vApvlist).find("division").concat().eq(0).find("step").concat().each(function (i, element) {
        if ((vStepLen - 1) == i) {
         if($$(element).find("ou > person > taskinfo").attr("status") == "completed"){
             $("#MultiRowTable1").css("display", "");
           }
        }
    });
    
    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        //<!--loadMultiRow_Read-->
        if (JSON.stringify(formJson.BodyContext)!="{}" && formJson.BodyContext.MultiRowTable1 != undefined && formJson.BodyContext.MultiRowTable1 !='') {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.MultiRowTable1), 'json', '#MultiRowTable1', 'R');
        } else {
            XFORM.multirow.load('', 'json', '#MultiRowTable1', 'R');
        }
        
        if (getInfo("Request.gloct") =="JOBFUNCTION" && getInfo("Request.loct") == "APPROVAL") {
            $("#btModify").css("display", "");
        }
    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        //<!--AddWebEditor-->
        LoadEditor("divWebEditorContainer");
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }
     
        //<!--loadMultiRow_Write-->
        if (JSON.stringify(formJson.BodyContext)!="{}" && formJson.BodyContext.MultiRowTable1 != undefined && formJson.BodyContext.MultiRowTable1 !='') {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.MultiRowTable1), 'json', '#MultiRowTable1', 'W');
        } else {
            XFORM.multirow.load('', 'json', '#MultiRowTable1', 'W', { minLength: 1, enableSubMultirow: true });
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
    	var tbl = $('#MultiRowTable1').find('tr.multi-row').find("td");
        var aScPRecV = getInfo("SchemaContext.scPRec.value").split("@@");
        
        if (getInfo("Request.gloct") =="JOBFUNCTION" && getInfo("Request.loct") == "APPROVAL")
        {
            if ((getInfo("Request.editmode") == 'Y') && ($(tbl).find("input[name=VM_NAME]").val() == ""
            		|| $(tbl).find("input[name=System]").val() == ""
    				|| $(tbl).find("input[name=Name]").val() == ""
    				|| $(tbl).find("input[name=Cpu]").val() == ""
    			    || $(tbl).find("input[name=Mem]").val() == ""
    			    || $(tbl).find("input[name=IP]").val() == "")) {
                alert("값 입력 후 승인 하시기 바랍니다.");
                return false;
            }else if ( (getInfo("Request.editmode") != 'Y') && ($(tbl).find("span[name=System]").text() == "" ||
            		$(tbl).find("span[name=Name]").text() == "" ||
            		$(tbl).find("span[name=Cpu]").text() == "" ||
            		$(tbl).find("span[name=Mem]").text() == "" ||
            		$(tbl).find("span[name=IP]").text() == "" )) {
                alert("값 입력 후 승인 하시기 바랍니다.");
                return false;
            } else {
              return EASY.check().result;
            }
       }else{
    	   return EASY.check().result;
       }
   }
}
function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
    /*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";*/
	
    var bodyContextObj = {};
	
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("MultiRowTable1", "rField"));
    
    return bodyContextObj;
}

//기간에 대한 validation 처리 추가
function validateVacDate() {

    var sdt = $('#SDATE').val().replace(/-/g, '');
    var edt = $('#EDATE').val().replace(/-/g, '');

    if (Number(sdt) > Number(edt)) {
        Common.Warning("시작일은 종료일보다 먼저 일 수 없습니다.");
        $('#EDATE').val('')
    }

}
