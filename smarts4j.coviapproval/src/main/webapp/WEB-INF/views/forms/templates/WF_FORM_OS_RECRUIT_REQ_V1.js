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
        
        //<!--loadMultiRow_Read-->

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        //<!--AddWebEditor-->
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            
            // 채용요청서 스크립트
            var deptName = "";
            var memberOfName = "";
            $.ajax({
            	url : "/covicore/admin/orgmanage/getgroupinfo.do"
                ,type : "POST"
                ,async : false
                ,data : {
                	gr_code : Common.getSession("GR_Code")
                }
                ,success : function (data) {
                	deptName = CFN_GetDicInfo(data.list[0].MultiDisplayName);
                    memberOfName = CFN_GetDicInfo(data.list[0].ParentName);
                    $("#Central").val(memberOfName );
                    $("#Dept").val(deptName);
                }
            });
            
            //제목설정
            var formTitle = "[외주용역 채용 요청]";
            if(!$("#Subject").val()) $("#Subject").val(formTitle);
        }
     
        //<!--loadMultiRow_Write-->
    }
}
function setTitle(){
    if (getInfo("Request.templatemode") != "Read") {

        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
            var formTitle = "[외주용역 채용 요청] ";
            $("#Subject").val(formTitle + $("input#ProjectName").val());
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
        if(!EASY.check().result){
        	return false;
        }
        // 양식별 직접체크.
        
        return true;
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
    return bodyContextObj;
}