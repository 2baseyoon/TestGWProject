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



//조직도 기본정보
var _hrInfo ;

var lang = Common.getSession('lang');
function getMultiLangBySs(multiLang){
	return lang=="ko"?multiLang.split(";")[0]:lang=="en"?multiLang.split(";")[1]:lang=="ja"?multiLang.split(";")[2]:lang=="zh"?multiLang.split(";")[3]:multiLang.split(";")[0];
}

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

			var issuedType = Common.getBaseCode('IssuedType').CacheData;
			var issuedOp = "";
			for(var i=0;i<issuedType.length;i++){
				issuedOp += "<option value='"+issuedType[i].Code+"'>"+getMultiLangBySs(issuedType[i].MultiCodeName)+"</option>";
			}
			$("#issuedType").append(issuedOp);

			$("input[name=certType]").on('click',function(){
				setFormData();
			});
        }
     
        //<!--loadMultiRow_Write-->
    }
    
    $("#issuedType").on('change',function(){
		if( $("#issuedType").val()=="Etc"){
			$("#docTypeContents").show();
		}else{
			$("#docTypeContents").hide();
		}
	});
    
    
    $("#issuedType").trigger("change");
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
	$$(bodyContextObj["BodyContext"]).append("Subject", document.getElementById("Subject").value); 
	$$(bodyContextObj["BodyContext"]).append("UserCode", Common.getSession('USERID')); 
	$$(bodyContextObj["BodyContext"]).append("CompanyCode", Common.getSession('DN_Code')); 
    return bodyContextObj;
}

function OpenWinEmployee(obj){	
	$('#reqUserCode').val('');
	$('#reqUserName').val('');
    
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B9", "조직도", 1000, 580, "");
}

function Requester_CallBack(pStrItemInfo) {
	var oJsonOrgMap = $.parseJSON(pStrItemInfo);
	_hrInfo = oJsonOrgMap;

	setFormData();
}

function setFormData(){

	$.each(_hrInfo.item, function(i, v) {
		if(i == 0) {
			var params ={
				"userCode":v.UserCode
				,"deptCode":v.RG
				,"companyCode":v.ETID
				,"lang":$("input[name=certType]:checked").val().indexOf("Eng") > -1?'en':'ko'
			}; 
			
			$.ajax({
				type:"POST",
				dataType   : 'json',
				data: params,
				url:"/hrmanage/hrCert/getCertUserBaseInfo.do",
				success:function (data) {
					if(data.status =="SUCCESS"){

						
						var userInfo = data.userInfo;
						$('#reqUserCode').val(v.UserCode);
						$('#joinDate').val(userInfo.JOINING_DT);
						$('#retireDate').val(userInfo.RETIRE_DT);

						$('#reqUserName').val(userInfo.DisplayNm);
						
						//$('#socialNo').val(rrn(userInfo.SOCIAL_NM));
						$('#address').val(userInfo.ADDR+userInfo.DTL_ADDR);
						$('#headOffice').val(userInfo.DeptFullPath);
						$('#team').val(userInfo.DeptName);
						$('#resNm').val(userInfo.JobTitleName);
						$('#posNm').val(userInfo.JobPositionName);
					}
				}
			});  
			
		}
	});
}

function onlyNumber(o) {
	$(o).val($(o).val().replace(/[^0-9]/g, ""));
}

/* ※ 주민등록 번호 마스킹 (Resident Registration Number, RRN Masking) ex1) 
 * 원본 데이터 : 990101-1234567, 변경 데이터 : 990101-1****** ex2) 
 * 원본 데이터 : 9901011234567, 변경 데이터 : 9901011****** */

function checkNull (str){ 
	if(typeof str == "undefined" || str == null || str == ""){ 
		return true; 
	} else{ 
		return false; 
	} 
}

function rrn (str){ 
	var originStr = $(str).val(); 
	var rrnStr; 
	var maskingStr; 
	var strLength; 

	if(checkNull(originStr) == true){ 
		return originStr;
	} 
	
	rrnStr = originStr.match(/(?:[0-9]{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[1,2][0-9]|3[0,1]))-[1-4]{1}[0-9]{6}\b/gi); 
	
	if(checkNull(rrnStr) == false){ 
		strLength = rrnStr.toString().split('-').length; 
		maskingStr = originStr.toString().replace(rrnStr,rrnStr.toString().replace(/(-?)([1-4]{1})([0-9]{6})\b/gi,"$1$2******")); 
	}else { 
		rrnStr = originStr.match(/\d{13}/gi); 
		if(checkNull(rrnStr) == false){ 
			strLength = rrnStr.toString().split('-').length; 
			maskingStr = originStr.toString().replace(rrnStr,rrnStr.toString().replace(/([0-9]{6})$/gi,"******")); 
		}else{ 
			return originStr; 
		} 
	} 

	$(str).val(maskingStr);
}
