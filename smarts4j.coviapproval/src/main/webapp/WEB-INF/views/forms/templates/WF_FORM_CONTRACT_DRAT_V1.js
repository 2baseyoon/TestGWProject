//양식별 다국어 정의 부분
var localLang_ko = {
    localLangItems: {
        selMessage: "●휴일이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        contractName: "계약명"

    }
};

var localLang_en = {
    localLangItems: {
        selMessage: "●vacation이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        contractName: "Contract name"

    }
};

var localLang_ja = {
    localLangItems: {
        selMessage: "●休日이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        contractName: "계약명"

    }
};

var localLang_zh = {
    localLangItems: {
        selMessage: "●休日이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        contractName: "계약명"

    }
};

//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
     //공통 후처리
    //체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        if (formJson.Request.mode == "COMPLETE") {
            $('#tbl_linkProj').show();
        }
      
        //제목
        document.getElementById("headname").innerHTML = "<u>" + formJson.FormInfo.FormName + "</u>";
        document.getElementById("Subject").value = getInfo("FormInstanceInfo.Subject");

		//테이블 초기화
        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
        	if(formJson.BodyContext.MultiRowTable1!=undefined)
        		XFORM.multirow.load(JSON.stringify(formJson.BodyContext.MultiRowTable1), 'json', '#MultiRowTable1', 'R');
        	else
        		XFORM.multirow.load(JSON.stringify("{}"), 'json', '#MultiRowTable1', 'R');
        }

    }
    else {
        $('#tbl_linkProj').hide();

        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
   			document.getElementById("InitiatedDate").value = formJson.AppInfo.svdt; // 재사용, 임시함에서 오늘날짜로 들어가게함.
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usid"), false);
            //작성일 오늘 날짜로       
			// document.getElementById("INITIATOR_INFO").value = formJson.oFormData.usdn;   
            document.getElementById("AppliedDate").value = formatDate(formJson.AppInfo.svdt, "D");
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
			
            //계약번호 연동 추가 시작
            document.getElementById("nYear").value = formJson.AppInfo.svdt.split("-")[0];
            document.getElementById("nfiid").value = formJson.FormInstanceInfo.FormInstID;
            //계약번호 연동 추가 끝
            //고객명 insert 시 필요 시작
            document.getElementById("salesNm").value = formJson.AppInfo.usnm.split(";")[0];
            //고객명 끝
			
              // 테이블 초기화
            if (formJson.Request.mode == "DRAFT" && formJson.Request.gloct == "") {
                var json_multi_data = '[{"PUMBUN":"","CNumber":"","CEmail":""}]';
                XFORM.multirow.load(json_multi_data, 'json', '#MultiRowTable1', 'W');              
            }
            else {

                if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext.MultiRowTable1 != undefined) {
                    XFORM.multirow.load(JSON.stringify(formJson.BodyContext.MultiRowTable1), 'json', '#MultiRowTable1', 'W');
                }else{
                	var json_multi_data = '[{"PUMBUN":"","CNumber":"","CEmail":""}]';
                    XFORM.multirow.load(json_multi_data, 'json', '#MultiRowTable1', 'W');
                }
            }
            
            // 임시저장 또는 재사용 시 저장하였던 프로젝트명 가져오기
            if (formJson.Request.mode == "TEMPSAVE" || getInfo("Request.reuse") == "Y" || getInfo("Request.reuse") == "P" || getInfo("Request.reuse") == "YH") {
                if (formJson.BodyContext.PROJECT_NAME != undefined) {
                    $("#PROJECT_NAME").val(formJson.BodyContext.PROJECT_NAME);
                }
            }
        }else{
          // 테이블 초기화
            if (typeof formJson.BodyContext != 'undefined' && JSON.stringify(formJson.BodyContext) != "{}" ) {
                XFORM.multirow.load(JSON.stringify(formJson.BodyContext.MultiRowTable1), 'json', '#MultiRowTable1', 'W');
            }
            document.getElementById("Subject").disabled = true;        
        }

    }
}

function setLabel() {
}

// checkbox 값을 hidden에 값 / 값 형태로 누적 시킴
function tempChkBox() {//체크박스 체크시 값 확인

    var tempGetchkBox = getCheckBox("chkBox_1");

    document.getElementById("chkBoxSpan").value = tempGetchkBox.replace("<chkBox_1>", "").replace("</chkBox_1>", "");

    var chkTmp = document.getElementById("chkBoxSpan").value.split(" / ");
    var chkLength = chkTmp.length - 1;
    var chkRevalue = "";
    for (var i = 0; i < chkLength; i++) {
        if (i == chkLength - 1) {
            chkRevalue += chkTmp[i];
        } else {
            chkRevalue += chkTmp[i] + " / ";
        }
    }

    document.getElementById("chkBoxSpan").value = chkRevalue;

}


function setFormInfoDraft() {
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

function checkForm(bTempSave) {
    var cnt = 1;
    if (bTempSave) {
        return true;
    } else {
        if (document.getElementById("Subject").value == '') {
            Common.Warning('제목을 입력하세요.');
            return false;
        }
        if (!$(':input:radio[name=contract_quarter]:checked').val()) { //$(':radio[name="contract_quarter"]').is(':checked');
            Common.Warning("계약분기를 선택해주세요.");
            return false;
        }
        else {
            return EASY.check().result;
        }
    }
}

function Dayout(args, conf) {
    var dt = $('input[name="SDATE"]').val();
    var dt2 = $('input[name="EDATE"]').val();

    if (dt == '') return;
    if (dt2 == '') return;

    var dts = dt.split("-");
    var sdt = new Date(dts[0], dts[1], dts[2], 00, 00, 00);

    dts = dt2.split("-");
    var edt = new Date(dts[0], dts[1], dts[2], 00, 00, 00);

    var rtn = (edt - sdt) / 3600 / 1000 / 24;

    document.getElementsByName('DAYS')[0].value = rtn + 1;
}

function setBodyContext(sBodyContext) {
}


/*** CheckBox Value display ***/
function setCheckBox1(szname, szvalue) {


    var chkTmp = szvalue.split(" / ");
    for (var i = 0; i < chkTmp.length; i++) {
        for (var j = 1; j < 7; j++) {
            if (j < 10) {
                j = "0" + j;
            }
            if (chkTmp[i] == document.getElementById("chkBox_" + j).value) {
                document.getElementById("chkBox_" + j).checked = true;
            }
        }
    }
}



//본문 XML로 구성
function makeBodyContext() {
    /* var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + getMultiRowFields("MultiRowTable1", "rField") + "</BODY_CONTEXT>";
    return sBodyContext;*/
	
    var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("MultiRowTable1", "rField"));
    return bodyContextObj;
}



function cdValue(sValue) {
    return "<![CDATA[" + sValue + "]]>";
}

/* 사용하지 않음.
// 사업장 쿼리 조회 요청
function initENTPART() {
    var connectionname = "FORM_DEF_ConnectionString";
    var pXML = "dbo.usp_wfform_regionlist";
    var aXML = "<param><name>ENT_CODE</name><type>varchar</type><length>100</length><value><![CDATA[" + getInfo("etid") + "]]></value></param>";
    var sPostBody = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql><type>sp</type>" + aXML + "</Items>";
    var sTargetURL = "../getXMLQuery.aspx";
    requestHTTP("POST", sTargetURL, true, "text/xml", receiveFORMQuery, sPostBody);

}
// 사업장 쿼리 조회 결과 처리 
function receiveFORMQuery() {
    if (m_xmlHTTP.readyState == 4) {
        m_xmlHTTP.onreadystatechange = event_noop;
        if (m_xmlHTTP.responseXML == null) {
            //alert(m_xmlHTTP.responseText);
        } else {
            var xmlReturn = m_xmlHTTP.responseXML;
            var elmlist = xmlReturn.selectNodes("response/NewDataSet/Table");
            var elm;
            for (var i = 0; i < elmlist.length; i++) {
                elm = elmlist.nextNode();
                var oOption = document.createElement("option");
                document.getElementById("SEL_ENTPART").options.add(option);
                if (elm.selectSingleNode("NAME") != null) {
                    oOption.text = elm.selectSingleNode("NAME").text;
                    oOption.value = elm.selectSingleNode("REGION_CODE").text;
                }
            }
            if ((getInfo("mode") == "DRAFT" || getInfo("mode") == "TEMPSAVE")) {
                if (document.getElementById("SEL_ENTPART").value == "") {
                    document.getElementById("SEL_ENTPART").value = getInfo("etid");
                }
            }
            if (elmlist.length > 1) {
                document.getElementById("partdisplay").style.display = "";
            }
        }
        delay(1000);
        //setDocLevel();
    }
}
function requestHTTP(sMethod, sUrl, bAsync, sCType, pCallback, vBody) {
    m_xmlHTTP.open(sMethod, sUrl, bAsync);
    m_xmlHTTP.setRequestHeader("Accept-Language", g_szAcceptLang);
    m_xmlHTTP.setRequestHeader("Content-type", sCType);
    if (pCallback != null) m_xmlHTTP.onreadystatechange = pCallback;
    (vBody != null) ? m_xmlHTTP.send(vBody) : m_xmlHTTP.send();
}
*/
/*** form data CheckBox 값 -> xml로 ***/
function getCheckBox(chkNm) {
    //debugger;
    var chkboxVal = "";
    //if (document.getElementsByName(chkNm)[i] != undefined) {
    for (var i = 0; i < document.getElementsByName(chkNm).length; i++) {
        if (document.getElementsByName(chkNm)[i].checked) {
            chkboxVal += document.getElementsByName(chkNm)[i].value + " / ";
        }
    }
    if (chkboxVal != "") {
        chkboxVal = "<" + chkNm + ">" + chkboxVal + "</" + chkNm + ">";
    }
    return chkboxVal;
    // }
}


////숫자만 입력받기
//function num_chk(ctrl) {//숫자만 입력받기
//  if (!_ie) {//IE가 아니면
//      return; //함수를 탈출함.
//  }
//  var keyCode = window.event.keyCode;
//  var i = 0;
//  if (((keyCode < 48) || (keyCode > 57)) && (keyCode != 46)) {
//      try {
//          for (i = 0; i < asgMinus.length; i++) {//if(ctrl.name == 'nmREQ_Profit' || ctrl.name == 'nmREQ_Margin')
//              try {
//                  if (ctrl.name == asgMinus[i]) {
//                      if (keyCode == 45) {//'-' 기호일 경우
//                          if (ctrl.value.indexOf('-') == -1) {//'-'가 중복돼지 않았을 경우
//                              if (ctrl.value == '0') {//'0-'와 같은 값을 방지함
//                                  ctrl.value = '';
//                              }
//                              return; //정상이므로 함수를 탈출함.
//                          }
//                      }
//                      break;
//                  }
//              }
//              catch (e0) {
//              }
//          }
//      }
//      catch (e1) {
//      }
//      event.returnValue = false;
//      alert("숫자와 소수점만 입력 가능합니다.");
//  }
//  return;
//}

////숫자 자릿수 콤마 삽입 함수  시작
//function auto_comma(val) {
//  if (!_ie) {//IE가 아니면
//      return; //함수를 탈출함.
//  }
//  var keyCode = window.event.keyCode;
//  var i = 0;
//  try {
//      for (i = 0; i < asgMinus.length; i++) {//if(val.name == 'nmREQ_Profit' || val.name == 'nmREQ_Margin')
//          if (val.name == asgMinus[i]) {
//              var sTmp = '';
//              if (keyCode == 189) {//'-' 기호일 경우; onkeyup에선 45에서 189로 바뀜.
//                  sTmp = val.value.substring(1, val.value.length); //if(val.value.substring(0, 1) == '-')//-가 최좌측에 있을 경우
//                  if (val.value.substring(0, 1) != '-' || sTmp.indexOf('-') == -1)//-가 최좌측에 있고 '-'가 유일한 경우가 아니면
//                  {
//                      return false;
//                  }
//              }
//              sTmp = val.value;
//              sTmp = get_number(sTmp).toString();
//              sTmp = add_comma(sTmp);
//              if (val.value.indexOf('-') > -1) {
//                  sTmp = '-' + sTmp;
//              }
//              val.value = sTmp;
//              return true; //정상이므로 함수를 탈출함.
//          }
//      }
//  }
//  catch (e) {
//  }
//  if (((keyCode >= 48) && (keyCode <= 105)) || (keyCode == 8) || (keyCode == 13) || (keyCode == 35) || (keyCode == 46)) {//0(48)~숫자키패드9(105), enter(13), bakspace(8), delete(46), end(35) key 일 때만 처리한다.
//      var str = "" + get_number(val.value); //숫자만 가져온다
//      var target = val;
//      if ((str != null) && (str != "") && (str != "0")) {
//          target.value = add_comma(str); //콤마삽입
//      }
//      else {
//          target.value = "";
//          target.focus();
//          return false;
//      }
//  }
//  return true;
//}

//function add_comma(val) {//콤마삽입
//  var num = val.toString();
//  var sosu = num.indexOf(".");
//  if (sosu != -1) {
//      var positive_num = num.split('.');
//      num = positive_num[0];
//      if (num.length <= 3) return num + "." + positive_num[1];
//  }
//  if (num.length <= 3) return num;
//  var loop = Math.ceil(num.length / 3);
//  var offset = num.length % 3;
//  if (offset == 0) offset = 3;
//  var str = num.substring(0, offset);
//  for (i = 1; i < loop; i++) {
//      str += "," + num.substring(offset, offset + 3);
//      offset += 3;
//  }
//  if (sosu != -1)
//      str = str + "." + positive_num[1];
//  return str;
//}
////숫자 자릿수 콤마 삽입 함수  끝

////숫자만 가져오기
//function get_number(val) {
//  var str = "" + val;
//  var temp = "";
//  var num = "";
//  for (var i = 0; i < str.length; i++) {
//      temp = str.charAt(i);
//      //if (temp >= "0" && temp <= "9") {
//      if ((temp >= "0" && temp <= "9") || temp == ".") {
//          num += temp;
//      }
//  }
//  if ((num != null) && (num != "") && (num != "0")) {
//      //return parseInt(num,10); //십진수로 변환하여 리턴
//      return parseFloat(num, 10);
//  } else {
//      return "0";
//  }
//}

//ej추가
function OpenCusName() {
    //Common.Show("btnIframe", "3", "고객명을 선택하세요.", "../../Extension/Doc/CustomName.aspx", "400px", "300px", "iframe");
	window.open("/approval/goCustomName.do", '', 'width=320px,height=380px');
}

function PROJECTNAME() {
    //var project_name = $('#PROJECT_CODE').val();
    //$("#SUBJECT").val(m_oFormMenu.getLngLabel(getInfo("fmnm") + " - " + project_name, false));
    var project_name = $('#Con_Name').val();
    $("#Subject").val(m_oFormMenu.getLngLabel(getInfo("FormInfo.FormName") + " - " + project_name, false));
}

//인정실적 계산 함수 추가 - 류다은(161024)
function figure_ap_count() {
    var ap_count;

    ap_count
        = Number($("#SW_Count").val())
        + Number($("#Service_Count").val())
        + Number($("#Third_Margin_Count").val())
        - Number($("#etc_AP_Except_Count").val());

    $("#Accept_Perform_Count").val(ap_count);
}
//전체 계약 금액 계산 함수 추가 - 류다은(161024)
function figure_total_count() {
    var total_count;

    total_count
        = Number($("#HW_Count").val())
        + Number($("#SW_Count").val())
        + Number($("#Service_Count").val())
        + Number($("#etc_Count").val())
        + Number($("#Third_Margin_Count").val())
        - Number($("#etc_AP_Except_Count").val());

    $("#Total_Count").val(total_count);
}