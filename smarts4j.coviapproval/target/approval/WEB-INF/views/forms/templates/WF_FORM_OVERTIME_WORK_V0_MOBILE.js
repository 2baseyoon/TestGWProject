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

	if ((typeof CFN_GetQueryString == "function" && CFN_GetQueryString("RequestFormInstID") != "undefined") || (formJson.BodyContext && formJson.BodyContext.HID_PROCESSID)) {
		if(getInfo("Request.templatemode") == "Write") $('input[name="JobDate"]').prop('disabled', true); // 날짜 변경 불가
	}
	
    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        //<!--loadMultiRow_Read-->
        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_WORK_INFO), 'json', '#TBL_WORK_INFO', 'R');
        }

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

        	//기안자 정보 바인딩
            $("input[name=UserCode]").val(Common.getSession("UR_Code"));
            $("input[name=CompanyCode]").val(Common.getSession("DN_Code"));
            $("input[name=UserName]").val(Common.getSession("UR_Name"));
            
            //날짜 바인딩
            var today = new Date();
            var year = today.getFullYear();
            var month = pad(today.getMonth() + 1, 2);
            var date = pad(today.getDate(), 2);
            
            $("input[name=JobDate]").val(year + "-" + month + "-" + date);
            
        }
     
        //<!--loadMultiRow_Write-->
        if (JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_WORK_INFO), 'json', '#TBL_WORK_INFO', 'W');
        } else {
            XFORM.multirow.load('', 'json', '#TBL_WORK_INFO', 'W', { minLength: 1 });
        }

		//제목설정
		if(formJson.Request.mode == "DRAFT"){
			setSubject();
		}
		
    }
}

function setLabel() {
}

function setFormInfoDraft() {
}

function checkForm(bTempSave) {
	/*
	var returnBol = true;
	
    if (bTempSave) {
        return true;
    } else {
    	if(EASY.check().result){
    		if(checkWorkingTime()) {
				returnBol = true;
    		} else {
    			returnBol = false;
    		}
    	} else {
    		return false;
    	}
    }
    
    return returnBol;
    */
	
	if (bTempSave) {
        return true;
    } else {
        // 필수 입력 필드 체크
        return EASY.check().result;
    }
}

function setBodyContext(sBodyContext) {
	if (Common.getBaseConfig("ExtenUnit") != "0"){
		$("input[name=StartTime]").attr("data-time-step", Common.getBaseConfig("ExtenUnit"));
		$("input[name=EndTime]").attr("data-time-step", Common.getBaseConfig("ExtenUnit"));
	}	
	if (Common.getBaseConfig("ExtenStartTime") != ""){
		$("input[name=StartTime]").attr("data-time-min", Common.getBaseConfig("ExtenStartTime").substring(0,2)+":"+Common.getBaseConfig("ExtenStartTime").substring(2,4));
		$("input[name=StartTime]").attr("data-time-max", Common.getBaseConfig("ExtenEndTime").substring(0,2)+":"+Common.getBaseConfig("ExtenEndTime").substring(2,4));
		
		$("input[name=EndTime]").attr("data-time-min", Common.getBaseConfig("ExtenStartTime").substring(0,2)+":"+Common.getBaseConfig("ExtenStartTime").substring(2,4));
		$("input[name=EndTime]").attr("data-time-max", Common.getBaseConfig("ExtenEndTime").substring(0,2)+":"+Common.getBaseConfig("ExtenEndTime").substring(2,4));
	}	
	
	if (Common.getBaseConfig("ExtenRestYn") == "Y"){
		$("input[name=IdleTime]").attr("disabled", true);
		$("input[name=WorkTime]").attr("disabled", true);
		
	}
}

//본문 XML로 구성
function makeBodyContext() {
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("TBL_WORK_INFO", "rField"));
	
    return bodyContextObj;
}

//신청시간 계산
function calWorkTime(obj, objName) {
	var m_index = $("input[name='" + objName + "']").index(obj);
	var sObj = $("input[name=StartTime]").eq(m_index).val().replace(":", "");
	var eObj = $("input[name=EndTime]").eq(m_index).val().replace(":", "");
	
	var NextDay = $("select[name=NextDayYn]").eq(m_index).val();
	var idleTime = $("input[name=IdleTime]").eq(m_index).val();
	
	if(sObj != "" && eObj != ""){
		if (NextDay == "Y"  || (NextDay == "N" && sObj <= eObj )) {
			var sObjTime = parseInt(sObj.substring(0, 2) * 3600) + parseInt(sObj.substring(2) * 60);
			var eObjTime = parseInt(eObj.substring(0, 2) * 3600) + parseInt(eObj.substring(2) * 60);
			var diffTime = 0;
			if (NextDay == "Y" ){
				diffTime = (24*3600 - sObjTime) + eObjTime;
			}else{
				diffTime = eObjTime - sObjTime;
			}
			if (Common.getBaseConfig("ExtenRestYn") == "Y"){
				idleTime = (Math.floor(((diffTime)/60)/Common.getBaseConfig("ExtenWorkTime")) * Common.getBaseConfig("ExtenRestTime"));
				$("input[name=IdleTime]").eq(m_index).val(idleTime);
			}
			var gap = diffTime - (idleTime == "" ? 0 : parseInt(idleTime * 60));
			var h = "";
			var m = "";
			
			h = Math.floor(gap/3600) < 10 ? "0" + Math.floor(gap/3600) : Math.floor(gap/3600);
			m = Math.floor((gap - (h*3600))/60) < 10 ? "0" + Math.floor((gap - (h*3600))/60) : Math.floor((gap - (h*3600))/60);
	/*		if (Common.getBaseConfig("ExtenMaxTime") != "" && Common.getBaseConfig("ExtenMaxTime") != "0"){
				if (gap > parseInt(Common.getBaseConfig("ExtenMaxTime"),10) *3600){
					Common.Warning("하루 최대 근무시간이 초과되어 신청할 수 없습니다.("+Common.getBaseConfig("ExtenMaxTime")+"H)");
					return;
				}
			}*/
			$("input[name=WorkTime]").eq(m_index).val(h + ":" + m);
			
			checkWorkingTimeOne(obj, m_index);
			calTotalTime();
			checkAvailableTime(obj, m_index);
		}
		else{
			alert("시작시간은 종료시간보다 앞에 있을 수 없습니다.");
			return false;
		}
	}
}

//신청시간 합계 계산
function calTotalTime() {
	var sum = 0;
	var h = "";
	var m = "";
	
	$("input[name=WorkTime]").each(function(i, obj){
		if($(obj).val() != "") {
			var time = $(obj).val().replace(":", "");
			sum += parseInt(time.substring(0, 2) * 3600) + parseInt(time.substring(2) * 60);
		}
    });

	h = Math.floor(sum/3600) < 10 ? "0" + Math.floor(sum/3600) : Math.floor(sum/3600);
	m = Math.floor((sum - (h*3600))/60) < 10 ? "0" + Math.floor((sum - (h*3600))/60) : Math.floor((sum - (h*3600))/60);
	
	$("#TotalTime").val(h + ":" + m);
}

//조직도 팝업
var objTr;
function OpenWinEmployee(obj) {
	var sUrl = "/covicore/mobile/org/list.do";
	
	objTr = $(obj).closest("tr");
	
	$(objTr).find("input[name=UserName]").val("");
	$(objTr).find("input[name=UserCode]").val("");
	$(objTr).find("input[name=CompanyCode]").val("");
	 
	window.sessionStorage["mode"] = "SelectUser"; //SelectUser:사용자 선택(3열-1명만),Select:그룹 선택(3열-1개만)
	window.sessionStorage["multi"] = "Y";
	window.sessionStorage["callback"] = "Requester_CallBack();";
	
	mobile_comm_go(sUrl, 'Y');
}

function Requester_CallBack(pStrItemInfo) {
	var pStrItemInfo = '{"item":[' + window.sessionStorage["userinfo"] + ']}';
	var oJsonOrgMap = $.parseJSON(pStrItemInfo);
	var oTR = objTr;

	$.each(oJsonOrgMap.item, function(i, v) {
		if(i > 0) {
			XFORM.multirow.addRow($('#TBL_WORK_INFO'));
			oTR = $('#TBL_WORK_INFO').find(".multi-row-selector").last().closest("tr");
		}

		$(oTR).find("input[name=UserName]").val(mobile_comm_getDicInfo(v.DN));
		$(oTR).find("input[name=UserCode]").val(v.UserCode);
		$(oTR).find("input[name=CompanyCode]").val(v.ETID);
	});
	
	setSubject();
}

//주간 52시간 체크(승인시 확인: 사용안함)
function checkWorkingTime() {
	var returnBol = false;
	var tblWorkInfo = formJson.BodyContext.TBL_WORK_INFO;
	if(tblWorkInfo != undefined){
		if(tblWorkInfo.length == undefined) {
			tblWorkInfo = [tblWorkInfo];
		}
		
		CFN_CallAjax("/approval/legacy/attendanceWorkTimeCheck.do", {"workInfo" : JSON.stringify(tblWorkInfo), "orgProcessId":formJson.BodyContext.HID_PROCESSID}, function (data){
			if(data.status == "SUCCESS"){
				var workTimeList = data.workTimeList;
				
				$(workTimeList).each(function(){
					var workTimeCheck =obj["workTimeCheck"].split("/");
					var isOK = workTimeCheck[0];
					var sWeekDate = workTimeCheck[2];
					var eWeekDate = workTimeCheck[3];
					
					if(isOK == "N") { //52시간
						alert(this.UserName + "님의 '" + this.sWeekDate + "~" + this.eWeekDate + "\r\n 근무시간이  초과합니다.");
						return false;
					} else {
						//양식단 시간 합계
						var tot = calWorkingTimeUser(this.UserCode, this.sWeekDate, this.eWeekDate);
						var rmTime = parseInt(workTimeCheck[1])*60;

						if(rmTime < parseInt(tot)) {
							var h = Math.floor(rmTime/3600) < 10 ? "0" + Math.floor(rmTime/3600) : Math.floor(rmTime/3600);
							var m = Math.floor((rmTime - (h*3600))/60) < 10 ? "0" + Math.floor((rmTime - (h*3600))/60) : Math.floor((rmTime - (h*3600))/60);
							
							alert(this.UserName + "님의 '" + this.sWeekDate + "~" + this.eWeekDate + "'\r\n 추가 근무 가능 시간은 " + h + "시간 " + m + "분 입니다.");
							returnBol = false;
							return false;
						} else {
							returnBol = true;
						}
					}
				});
			} else{
				alert("오류가 발생했습니다.");
				return false;
			}
		}, false, 'json');
	} else {
		return false;
	}
	
	return returnBol;
}

function calWorkingTimeUser(userCode, sWeekDate, eWeekDate) {
	var sum = 0;
	var h = "";
	var m = "";
	
	var tblWorkInfo = getBodyContext().BodyContext.TBL_WORK_INFO;
	if(tblWorkInfo != undefined){
		if(tblWorkInfo.length == undefined) {
			tblWorkInfo = [tblWorkInfo];
		}
		
		$(tblWorkInfo).each(function() {
			if(this.UserCode == userCode && (this.JobDate >= sWeekDate && this.JobDate <= eWeekDate)) {
				var time = this.WorkTime.replace(":", "");
				sum += parseInt(time.substring(0, 2) * 3600) + parseInt(time.substring(2) * 60);
			}
		});
		
		return sum;
	}
	
	return 0;
}

//20190919 추가
function checkWorkingTimeOne(pObj, pIndex) {
	var userCode = $("input[name=UserCode]").eq(pIndex).val();
	var userName = $("input[name=UserName]").eq(pIndex).val();
	var companyCode = $("input[name=CompanyCode]").eq(pIndex).val();
	var targetDate = $("input[name=JobDate]").eq(pIndex).val();
	var startTime = $("input[name=StartTime]").eq(pIndex).val();
	var endTime = $("input[name=EndTime]").eq(pIndex).val();
	
	if(targetDate != "") {
		CFN_CallAjax("/approval/legacy/attendanceWorkTimeCheckOne.do", {"UserCode":userCode, "CompanyCode":companyCode, "TargetDate":targetDate, "StartTime":startTime, "EndTime":endTime, "orgProcessId":$("#HID_PROCESSID").val()}, function (data){
			if(data.status == "SUCCESS"){
				var workTimeCheck =data.list.workTimeCheck.split("/");
				var isOK = workTimeCheck[0];
				var sWeekDate = workTimeCheck[2];
				var eWeekDate = workTimeCheck[3];
				
				if(isOK == "N") {
					$(pObj).val("");
					$("input[name=WorkTime]").eq(pIndex).val("");
					
					alert("근무시간이 초과되어 신청할 수 없습니다.");
				} else {
					var tot = calWorkingTimeUser(userCode, sWeekDate, eWeekDate); //양식단 시간 합계
					var rmTime = parseInt(workTimeCheck[1])*60;
				
					if(parseInt(rmTime) < parseInt(tot)) {
						var h = Math.floor(rmTime/3600) < 10 ? "0" + Math.floor(rmTime/3600) : Math.floor(rmTime/3600);
						var m = Math.floor((rmTime - (h*3600))/60) < 10 ? "0" + Math.floor((rmTime - (h*3600))/60) : Math.floor((rmTime - (h*3600))/60);
						
						$(pObj).val("");
						$("input[name=WorkTime]").eq(pIndex).val("");
						
						alert(userName + "님의 " + sWeekDate + "~" + eWeekDate + "\r\n 추가 근무 가능 시간은 " + h + "시간 " + m + "분 입니다.");
					}
					//'가능시간'에 추가 근무 가능한 시간 표시
					var h = Math.floor(rmTime/3600) < 10 ? "0" + Math.floor(rmTime/3600) : Math.floor(rmTime/3600);
					var m = Math.floor((rmTime - (h*3600))/60) < 10 ? "0" + Math.floor((rmTime - (h*3600))/60) : Math.floor((rmTime - (h*3600))/60);
					$("input[name=AvailableTime]").eq(pIndex).val(h+":"+m);
					$("input[name=AvailableTime]").eq(pIndex).attr("data-map",JSON.stringify({"sWeekDate": sWeekDate,"eWeekDate":eWeekDate}));
				}
			} else{
				alert("오류가 발생했습니다.");
				return false;
			}
		}, false, 'json');
	}
}

//같은 근무자가 연속으로 신청할 경우 가능시간 조정
function checkAvailableTime(pObj, pIndex){
	var trnum = pIndex - 1; // multi-row-template 행은 제외
	
	if(trnum > 0){
		var prevName = $("input[name=UserName]").eq(trnum).val();
		var nowName = $("input[name=UserName]").eq(trnum).val();
		
		if(prevName == nowName){
			var wObj = $("input[name=WorkTime]").eq(trnum).val().replace(":", ""); //이전 행 신청시간
			var aObj = $("input[name=AvailableTime]").eq(trnum).val().replace(":", ""); //이전 행 가능시간
			
			if(wObj != "" && aObj != "" && wObj <= aObj) {
				var wObjTime = parseInt(wObj.substring(0, 2) * 3600) + parseInt(wObj.substring(2) * 60);
				var aObjTime = parseInt(aObj.substring(0, 2) * 3600) + parseInt(aObj.substring(2) * 60);
				var gap = aObjTime - wObjTime;
				var h = "";
				var m = "";
				
				h = Math.floor(gap/3600) < 10 ? "0" + Math.floor(gap/3600) : Math.floor(gap/3600);
				m = Math.floor((gap - (h*3600))/60) < 10 ? "0" + Math.floor((gap - (h*3600))/60) : Math.floor((gap - (h*3600))/60);
				
				$("input[name=AvailableTime]").eq(pIndex).val(h+":"+m);
			}
		}
	}	
}

//날짜 선택시 제목 변경
function setSubject(){
	var sHeadName = "연장근무 신청서";
	if ((typeof CFN_GetQueryString == "function" && CFN_GetQueryString("RequestFormInstID") != "undefined") || (formJson.BodyContext && formJson.BodyContext.HID_PROCESSID)) {
		sHeadName = "연장근무 변경 신청서";
	}
	
	var sUserName = $("#TBL_WORK_INFO").find(".multi-row").find("[name='UserName']").eq(0).val();
	if(!sUserName) sUserName = CFN_GetDicInfo(getInfo("AppInfo.usnm"));
	
	var sDate = $("#TBL_WORK_INFO").find(".multi-row").find("[name='JobDate']").eq(0).val();
	sDate = (sDate) ? sDate : "";
	if(sDate.length == 8) sDate = sDate.substring(0,4) + "-" + sDate.substring(4,6) + "-" + sDate.substring(6,8);
	var date = new Date(sDate);
	if(!isNaN(date)) {
		var sMonth = String(date.getMonth() + 1).padStart(2, "0");
  		const sDay = String(date.getDate()).padStart(2, "0");
		$("#approval_write_Subject").val(sHeadName+"_"+sUserName+"("+sMonth+"/"+sDay+")");
	}else {
		$("#approval_write_Subject").val(sHeadName+"_"+sUserName);	
	}
	
	mobile_approval_changeSelectBox($("#approval_write_Subject"));
}

function pad(n, width) {
	  n = n + '';
	  return n.length >= width ? n : new Array(width - n.length + 1).join('0') + n;
}

//멀티로우 행 추가 시 이벤트
XFORM.multirow.event('afterRowAdded', function ($rows) {
	// 멀티로우 체크박스, 라디오 추가
	mobile_approval_addMultiCheckAndRadio($rows);
});

//멀티로우 행 삭제 시 이벤트
XFORM.multirow.event('afterRowRemoved', function () {
	// 멀티로우 체크박스, 라디오 시퀀스 다시 세팅
	mobile_approval_setMultiCheckAndRadio();

    // 전체선택 체크 해제
    $(".multi-row-select-all").prop("checked", false);
    $(".multi-row-select-all").checkboxradio('refresh');
});