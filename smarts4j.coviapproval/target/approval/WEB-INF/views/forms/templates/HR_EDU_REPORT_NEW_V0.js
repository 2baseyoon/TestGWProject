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

var lang = Common.getSession('lang');
function getMultiLangBySs(multiLang){
	return lang=="ko"?multiLang.split(";")[0]:lang=="en"?multiLang.split(";")[1]:lang=="ja"?multiLang.split(";")[2]:lang=="zh"?multiLang.split(";")[3]:multiLang.split(";")[0];
}


//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
	
	
	var codeCol = ['EduType','EduTypeTwo'];
	for(var i=0;i<codeCol.length;i++){
		var colType = Common.getBaseCode(codeCol[i]).CacheData;
		for(var j=0;j<colType.length;j++){
			var ihtml = $('<input/>',{
				type : 'radio'
				,name : codeCol[i]
				,value : colType[j].Code
				,id : codeCol[i]+j
			});
			if( j == 0 ){ 
				ihtml.attr('checked',true); 
			}
			
			if(colType[j].Code !="BeforeHouse"){
				$("#"+codeCol[i]).append(ihtml[0].outerHTML+' '+getMultiLangBySs(colType[j].MultiCodeName)+'&nbsp; &nbsp;');
			}
			
		}
	}
	
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

			
        }

		getRequestData();
        //<!--loadMultiRow_Write-->
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
        return EASY.check().result;
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
	$$(bodyContextObj["BodyContext"]).append("eduTime", $("#eduTime").val()); 
	$$(bodyContextObj["BodyContext"]).append("docSeq", CFN_GetQueryString('docSeq')!='undefined'? CFN_GetQueryString('docSeq') : null); 
	$$(bodyContextObj["BodyContext"]).append("procId", CFN_GetQueryString('procId')!='undefined'? CFN_GetQueryString('procId') : null); 
	$$(bodyContextObj["BodyContext"]).append("UserCode", Common.getSession('USERID')); 
	$$(bodyContextObj["BodyContext"]).append("CompanyCode", Common.getSession('DN_Code')); 
    return bodyContextObj;
}

function calSDATEEDATE(obj) {
    var tmpObj = obj;
    while (tmpObj.tagName != "TR") {
        tmpObj = tmpObj.parentNode; 
    }
    if ($(tmpObj).find("input[id=SDATE]").val() != "" && $(tmpObj).find("input[id=EDATE]").val() != "") {
        var SDATE = $(tmpObj).find("input[id=SDATE]").val().split('-');
        var EDATE = $(tmpObj).find("input[id=EDATE]").val().split('-');

        var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        var tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
        if (tmpday < 0) {
            alert("이전 일보다 전 입니다. 확인하여 주십시오.");
            $(tmpObj).find("input[id=SDATE]").val("");
            $(tmpObj).find("input[id=EDATE]").val("");
        }
        else {
            $("#NIGHTS").val(tmpday);
            $("#DAYS").val(tmpday + 1);
        }
    }
}

function getRequestData(){
	var params = {
		 docSeq : CFN_GetQueryString('docSeq')!='undefined'? CFN_GetQueryString('docSeq') : null
		,procId : CFN_GetQueryString('procId')!='undefined'? CFN_GetQueryString('procId') : null
	}
	
	
	$.ajax({
		type:"POST",
		dataType   : 'json',
		data: params,
		url:"/hrmanage/hrEdu/getEduDataNew.do",
		success:function (data) {
			if(data.status =="SUCCESS"){
				var eduMap = data.eduMap;
				
				$("#eduYear").val(eduMap.EDU_YEAR);
				$("#eduName").val(eduMap.EDU_NM);
				$("#SDATE").val(eduMap.EDU_START_DATE);
				$("#EDATE").val(eduMap.EDU_END_DATE);
				$("#eduTime").val(eduMap.EDU_TIME);
				$("#eduAgency").val(eduMap.EDU_CENTER);
				$("#SDATE").change();
				
				$("#eduIns").val(eduMap.EDU_INS);
				$("#eduContent").val(eduMap.EDU_CONTENT);
				
				$("#eduYear").attr("disabled","disabled");
				$("#eduName").attr("disabled","disabled");
				$("#SDATE").attr("disabled","disabled");
				$("#EDATE").attr("disabled","disabled");
				$("#EDATE").trigger("change");
				$("#eduTime").attr("disabled","disabled");
				$("#eduAgency").attr("disabled","disabled");
				$("#eduIns").attr("disabled","disabled");
				$("#eduContent").attr("disabled","disabled");
				
				$("#NIGHTS").attr("disabled","disabled");
				$("#DAYS").attr("disabled","disabled");
				
				$("input:radio[name=EduType][value='"+eduMap.EDU_TYPE+"']").prop("checked", true);
				$("input:radio[name=EduTypeTwo][value='"+eduMap.EDU_TYPE2+"']").prop("checked", true);
				
				$("input:radio[name=EduType]").attr("disabled","disabled");
				$("input:radio[name=EduTypeTwo]").attr("disabled","disabled");
				
				$("input:radio[name=EduType]:checked").css("background","black");
				$("input:radio[name=EduTypeTwo]:checked").css("background","black");
				
			}else{
				alert(data.message);
				window.close();
			}
		}
	}); 
}