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

	var codeCol = ['EduType','AfterEdu'];
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
				$("#"+codeCol[i]).append(ihtml[0].outerHTML+' '+getMultiLangBySs(colType[j].MultiCodeName)+'&nbsp; &nbsp');
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

		//교육신청 승인 완료 후 조회 시 교육보고서 등록 버튼 추가 ( 교육보고서 완료 시 완료 보고서 내용출력 / 보고서 미등록 시 등록 양식 출력 )
		var reportBtn = $('<input/>',{
			type : 'button'
			,class : 'AXButton'
			,value : Common.getDic('lbl_hredu_eduReport')
			,"onclick" : "openReport()"
	
		});
		if(formJson.Request.mode == "COMPLETE"){
			$(".form_wrap .wordTop .topWrap").find("input")[$(".form_wrap .wordTop .topWrap").find("input").length-1].insertAdjacentHTML('afterend',reportBtn[0].outerHTML);    
		}
		       
        
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
	$$(bodyContextObj["BodyContext"]).append("Subject", document.getElementById("Subject").value); 
	$$(bodyContextObj["BodyContext"]).append("UserCode", Common.getSession('USERID')); 
	$$(bodyContextObj["BodyContext"]).append("DeptCode", Common.getSession('DEPTID')); 
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


function openReport(){
	var params = {
		procId : formJson.Request.processID
	}
	$.ajax({
		type:"POST",
		dataType   : 'json',
		data: params,
		url:"/hrmanage/hrEdu/getEduData.do",
		success:function (data) {
			if(data.status =="SUCCESS"){
				var eduMap = data.eduMap;
				if(eduMap.COMP_PROC_ID != null && eduMap.COMP_PROC_ID != ''){
					var _approvalSts = Common.getBaseCode('ApprovalSts').CacheData;
					for(var i=0;i<_approvalSts.length;i++){
						if(eduMap.COMP_PROC_STS == _approvalSts[i].Code){
							CFN_OpenWindow('/approval/approval_Form.do?mode='+_approvalSts[i].Reserved2+'&processID='+eduMap.COMP_PROC_ID,'',790, (window.screen.height - 100), 'scroll'); 
							break;
						}
					}
				}else{
					if(eduMap.APP_USERYN == 'Y'){	//본인 기안건에 대해서만 교육 보고서 추가 가능
						CFN_OpenWindow("/approval/approval_Form.do?formPrefix=HR_EDU_REPORT&mode=DRAFT&procId="+formJson.Request.processID, "", 790, (window.screen.height - 100), "resize", "false");			
					}
				}
			}else{
				alert(data.message);
				window.close();
			}
		}
	}); 
	
}