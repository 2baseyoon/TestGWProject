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
    return bodyContextObj;
}

//시작일, 종료일 유효성 체크
function validateVacDate() {
    var sdt = $('#SDATE').val().replace(/-/g, '');
    var edt = $('#EDATE').val().replace(/-/g, '');

    if (Number(sdt) > Number(edt)) {
    	alert(mobile_comm_getDic("msg_Mobile_InvalidStartDate"));
        $('#EDATE').val('')
        $('#NIGHTS').val('')
        $('#DAYS').val('')
    }
    else {
    	SetDaysNights();
    }
}

//몇박 며칠 구하기
function SetDaysNights() {
  var vStartDate = $("input[id=SDATE]").val();
  var vEndDate = $("input[id=EDATE]").val();
  
  if (vStartDate != "" && vEndDate != "") {
      if ($("input[id=DAYS]") != undefined) {
          var arrDate1 = vStartDate.split("/");
          var arrDate2 = vEndDate.split("/");
          var vDate1 = new Date(arrDate1[0], arrDate1[1] - 1, arrDate1[2]).getTime();
          var vDate2 = new Date(arrDate2[0], arrDate2[1] - 1, arrDate2[2]).getTime();
          var vResult = (vDate2 - vDate1) / (1000 * 60 * 60 * 24);

          $("input[id=DAYS]").val(vResult + 1);
      }

      if ($("input[id=NIGHTS]") != undefined) {
          $("input[id=NIGHTS]").val(vResult);
      }
  }
}

//조직도에서 출장자 선택
var objSeq;
function OpenWinEmployee(seq) {
	var sUrl = "/covicore/mobile/org/list.do";
	objSeq = seq;

	window.sessionStorage["mode"] = "SelectUser"; //SelectUser:사용자 선택(3열-1명만),Select:그룹 선택(3열-1개만)
	window.sessionStorage["multi"] = "N";
	window.sessionStorage["callback"] = "Requester_CallBack();";
	
	mobile_comm_go(sUrl, 'Y');
}

function Requester_CallBack(pStrItemInfo) {
	var pStrItemInfo = '{"item":[' + window.sessionStorage["userinfo"] + ']}';
	var oJsonOrgMap;
	var I_User;
	
	oJsonOrgMap = $.parseJSON(pStrItemInfo);
	I_User = oJsonOrgMap.item[0];
	
	if (I_User != undefined) {
        $("#user_dept_" + objSeq).val(mobile_comm_getDicInfo(I_User.ExGroupName));
        $("#user_name_" + objSeq).val(mobile_comm_getDicInfo(I_User.DN));
        $("#user_pstn_" + objSeq).val(mobile_comm_getDicInfo(I_User.po.split(";")[1]));
	}
}

//경비 입력에 따른 금액 계산
function calcExpense(pObj) {
  var m_index = $(pObj).attr("id").split("_")[2].substring(0, 1); // 몇 번째 예상경비인지
  var currentRowPrice = 0;		// 현재 행의 예산경비 합계
  
  // 1: 교통비
  // 2: 숙박비
  // 4: 일비
  // 5: 기타
  // 6: 합계
  
  // 현재 입력한 행의 금액 합계 계산
  for(var i = 1 ; i <= $("[id^='a_cost_" + m_index + "']").length ; i++) {
	  if($("#a_cost_" + m_index + i).length > 0) {
		  currentRowPrice += parseInt($("#a_cost_" + m_index + i).val() == "" ? 0 : $("#a_cost_" + m_index + i).val());
	  }
  }
  
  $("#a_cost_" + m_index + "6").val(currentRowPrice);
  
  // 각 종류별 합계 계산
  $("input[id^='a_sum_']").each(function(i, obj) {
	  var costType = $(obj).attr("id").split("_")[2];
	  var totalByType = 0; // 종류별 합계
	  
	  $("input[id^='a_cost_'][id$='" + costType + "']").each(function(i, target) {
		  totalByType += parseInt($(target).val() == "" ? 0 : $(target).val());
	  });
	  
	  $(obj).val(totalByType);
  });
}