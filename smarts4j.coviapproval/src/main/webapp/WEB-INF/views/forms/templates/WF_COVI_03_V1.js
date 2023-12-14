
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

        if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
            getData("");
            //Java Migration 이후 멀티로우 ID 변경에 따른 수정
            if(typeof formJson.BodyContext.SubTable1 != 'undefined'){
            	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.SubTable1), 'json', '#SubTable1', 'R', { minLength: 1 });
            }else{
            	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.sub_table1), 'json', '#SubTable1', 'R', { minLength: 1 });
            }
            
        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'R');
        }

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리


        if (formJson.Request.mode == "DRAFT") {

            //document.getElementById("INITIATOR_OU_DP").value = m_oFormMenu.getLngLabel(getInfo("dpdn"), false);
            //document.getElementById("INITIATOR_DP").value = m_oFormMenu.getLngLabel(getInfo("usdn"), false);
	       	document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
	        document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
	        document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);
	        document.getElementById("InitiatedDate").value = formJson.AppInfo.svdt;

            /* 전월 나타내기 */
            var yearmonth = formatDate(formJson.AppInfo.svdt, "M").split('.');
            var year = yearmonth[0];
            var month = yearmonth[1];
            //if (month == "01") {
            //    year -= 1;
            //}
            month -= 1;

            yearmonth = (year + "-" + month).newDate().yyyymmdd();
            $("#table_1").find("input[id=hd_TDATE]").val(yearmonth);
            document.getElementById("T_DATE").value = yearmonth.replace(/([0-9]{4})-([0-9]{2})-([0-9]{2})/, "$1년 $2월");

            setRequestYM("T_DATE");
            
            if (formJson.Request.mode == "DRAFT" && formJson.Request.gloct == "") {
                getData("");
                XFORM.multirow.load("", 'json', '#SubTable1', 'W', { minLength: 1 });
                document.getElementById("Subject").value = "[프로젝트 수당청구] " + document.getElementById("T_DATE").value + " " + $("#SubTable1").find("tr.multi-row").find("select[name=PRO_NAME]").eq(0).val() + " 프로젝트";
            }
            else {
                if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
                    getData("");
                    
                    //Java Migration 이후 멀티로우 ID 변경에 따른 수정
                    //XFORM.multirow.load(JSON.stringify(formJson.BodyContext.SubTable1), 'json', '#SubTable1', 'W', { minLength: 1 });
                    if(typeof formJson.BodyContext.SubTable1 != 'undefined'){
                    	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.SubTable1), 'json', '#SubTable1', 'W', { minLength: 1 });
                    }else{
                    	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.sub_table1), 'json', '#SubTable1', 'W', { minLength: 1 });
                    }
                }
            }

            /* 해당월만 선택하는 속성 추가 */
            var hd_TDATE = $("#table_1").find("input[id=hd_TDATE]").val();
            $("#SubTable1").find("input[name=S_DATE]").attr("data-date-min", hd_TDATE);
            $("#SubTable1").find("input[name=E_DATE]").attr("data-date-min", hd_TDATE);

            var TDATE = hd_TDATE.split('-');
            hd_TDATE = new Date(TDATE[0], TDATE[1], 0);
            hd_TDATE = hd_TDATE.yyyymmdd();
            $("#SubTable1").find("input[name=S_DATE]").attr("data-date-max", hd_TDATE);
            $("#SubTable1").find("input[name=E_DATE]").attr("data-date-max", hd_TDATE);

        }
        else {

            if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
                getData("");
                //XFORM.multirow.load(JSON.stringify(formJson.BodyContext.SubTable1), 'json', '#SubTable1', 'W', { minLength: 1 });
                if(typeof formJson.BodyContext.SubTable1 != 'undefined'){
                	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.SubTable1), 'json', '#SubTable1', 'W', { minLength: 1 });
                }else{
                	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.sub_table1), 'json', '#SubTable1', 'W', { minLength: 1 });
                }
            }
        }
    }
}

/* 프로젝트 명이 바뀔 때마다 제목 변경 */
function changeTitle() {
	//var proname = $("#SubTable1").find("tr.multi-row").find("select[name=PRO_NAME]").eq(0).val();
	var proname = $("#SubTable1").find("tr.multi-row:eq(0)").find("select[name=PRO_NAME] option:selected").text();
	if (proname == $("#SubTable1").find("tr.multi-row:eq(0)").find("select[name=PRO_NAME] option:eq(0)").text()) {
		proname = "";
	}

    var date = $("#table_1").find("input[id=T_DATE]").val();
    document.getElementById("Subject").value = "[프로젝트 수당청구] " + date + " " + proname + " 프로젝트";

    setRequestYM("T_DATE");
}

function afterSumFormula() {
   /* if (parseInt($("#COST").val().numeric()) > 250000) {
        $("#COST").val("250000".currency());
    }*/
}

function setLabel() {
}

function setFormInfoDraft() {
}

function checkForm(bTempSave) {
    if (bTempSave) {
        return true;
    } else {
        if (document.getElementById("MONTH_DATE").value == "") {
            Common.Warning("해당월 근무일수 를 입력하세요");
            return false;
        } /*else if (parseInt($("#SubTable1").find("input[id=PART_RATE]").val()) < 80) {
            Common.Warning("총 근무일수의 80% 이상 상주 근무하지 않았습니다.");
            return false;
        } */
        else if(parseInt($("#ALL_WORK").val().numeric()) < 2){
        	Common.Warning("해당월 근무일수가 2일 이상이어야 합니다.");
        	return false;
        }
        // [19-07-01] 규정 변경에 따라 일수 제한 없앰.
        /*else if(parseInt($("#ALL_WORK").val().numeric()) > 31){ //[yjlee] 20180706 경영관리팀 합의 후 25 → 31로 변경
        	Common.Warning("실 근무일수 합계가 31일을 넘을 수가 없습니다.");
        	return false;
        }*/
        /*else if (parseInt($("#MONTH_DATE").val().numeric()) < parseInt($("#ALL_WORK").val().numeric())) {
            Common.Warning("해당월 실 근무일수보다 실 근무일수가 더 많을 수 없습니다.");
            return false;
        }*/
        else {
            return EASY.check().result;
        }
    }

}

function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("SubTable1", "rField"));
    
    return bodyContextObj;
}

/* 날짜 계산 */
function calSDATEEDATE(obj) {
    // 현재 객채(input) 에서 제일 가까이 있는 tr을 찾음
    var tmpObj = $(obj).closest("tr");

    if ($(tmpObj).find("input[name=S_DATE]").val() != "" && $(tmpObj).find("input[name=E_DATE]").val() != "") {
        var SDATE = $(tmpObj).find("input[name=S_DATE]").val().split('-');
        var EDATE = $(tmpObj).find("input[name=E_DATE]").val().split('-');

        var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        var tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
        tmpday += 1;
        if (tmpday < 0) {
            alert("이전 일보다 전 입니다. 확인하여 주십시오.");
            $(tmpObj).find("input[name=E_DATE]").val("");
            $(tmpObj).find("input[name=WORK_CNT]").val("");
            EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
        } else {
            $(tmpObj).find("input[name=WORK_CNT]").val(tmpday);
        }
    }
    EASY.triggerFormChanged();
}

/* DB 데이터를 불러옴 */
function getData(pvalue) {
    var Sel_id = "PRO_NAME";
    /*
    var connectionname = "COVI_FLOW_SI_ConnectionString";
    var pXML = "dbo.usp_select_projectname_gw";
    var param_1 = "WF_COVI_03";
    var aXML = "<param><name>appr_key</name><type>nvarchar</type><length>20</length><value><![CDATA[" + param_1 + "]]></value></param>";
    var sXML = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql><type>sp</type>" + aXML + "</Items>";
    var szURL = "../getXMLQuery.aspx";
	*/
    
    CFN_CallAjax("/approval/legacy/getProjectList.do", {"appr_key":"WF_COVI_03"}, function (data){ 
		receiveHTTPGetData_SapBaseCode_master(data, Sel_id, pvalue); 
	}, false, 'json');
}

function receiveHTTPGetData_SapBaseCode_master(responseXMLdata, Sel_id, pvalue) {
	var xmlReturn = responseXMLdata;
    var elmlist = responseXMLdata.Table;
    var Codegrp = '';
        
    $("#SubTable1").find("tr.multi-row-template").each(function (i) {
        $("#SubTable1").find("tr.multi-row-template").find("select[name=" + Sel_id + "]").eq(0).append("<option value=''>선택</option>");
        $(elmlist).each(function () {
        	//JOB_STATE_CD = G:회사일반 , P:프로젝트 , R:내부개발 , C:고객지원 , S:세일즈
        	if (this.JOB_STATE_CD == "P") {
        		$("#SubTable1").find("tr.multi-row-template").find("select[name=" + Sel_id + "]").eq(i).append("<option value='" + this.JOB_NO + "'>" + this.JOB_NM + "</option>");
        	}
        });
    });
}


/* 조직도 관련 함수 - SubTable1 */
var objTxtSelect;
var m_index;
function OpenWinEmployee(szObject) {
    objTxtSelect = document.getElementsByName(szObject);
    objTxtSelect.value = "";

    m_index = $("a[name=BUTTON]").index(szObject);
    
    /*
    var sType = "B9";
    var sGroup = "N";
    var sTarget = "Y";
    var sCompany = "Y";
    var sSearchType = "";
    var sSearchText = "";
    var sSubSystem = "";
    XFN_OrgMapShow_WindowOpen("REQUEST_TEAM_LEADER", "bodytable_content", objTxtSelect.id, openID, "Requester_CallBack", sType, sGroup, sCompany, sTarget, sSubSystem, sSearchType, sSearchText);
	*/
    
    CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B1","<spring:message code='Cache.lbl_apv_org'/>",1000,580,"");
}

function Requester_CallBack(pStrItemInfo) {
    var dept = "";
    var oJsonOrgMap =  $.parseJSON(pStrItemInfo);
    
    if (oJsonOrgMap.item.length == 1) {
        document.getElementsByName("PEOPLE_NAME")[m_index].value = CFN_GetDicInfo(oJsonOrgMap.item[0].DN);
        document.getElementsByName("EMPNO")[m_index].value = CFN_GetDicInfo(oJsonOrgMap.item[0].EmpNo);
    }
    else {
        alert("인원은 1명까지 지정 가능합니다. 다시 지정해주세요.");
        //OpenWinEmployee(objTxtSelect.name);
    }
}

/* 청구년월 값에 따른 히든필드 값 설정 */
function setRequestYM(objName) {
    var requestYM = $("#" + objName).val();

    $("#REQUEST_Y").val(requestYM.substring(0, 4));
    $("#REQUEST_M").val(requestYM.substring(6, 8));
}