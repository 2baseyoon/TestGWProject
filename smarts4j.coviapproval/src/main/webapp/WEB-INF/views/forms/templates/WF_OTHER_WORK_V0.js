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
	//기안자 정보 바인딩
    $("input[name=UserCode]").val(Common.getSession("UR_Code"));
    $("input[name=CompanyCode]").val(Common.getSession("DN_Code"));
    $("input[name=UserName]").val(Common.getSession("UR_Name"));
    
    //날짜 바인딩
    var today = new Date();
    var year = today.getFullYear();
    var month = (today.getMonth()+1) < 10 ? "0" + (today.getMonth()+1) : (today.getMonth()+1);
    var date = today.getDate() < 10 ? "0" + today.getDate() : today.getDate();
    
    $("input[name=JobDate]").val(year + "-" + month + "-" + date);
    
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();
    
    setSelect();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        //<!--loadMultiRow_Read-->
        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_OTHER_WORK_INFO), 'json', '#TBL_OTHER_WORK_INFO', 'R');
        }

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            
            if (CFN_GetQueryString("RequestFormInstID") != "undefined") {
				$("#HID_OTHER_WORK_FIID").val(CFN_GetQueryString("RequestFormInstID"));
				
				//제목설정
	            $("#Subject").val(Common.getSession('UR_Name')+" - 기타근무 변경 신청서");
				$("#headname").text("기타근무 변경 신청서");
				getOtherWorkData();
			}else{
				//제목설정
				$("#Subject").val(Common.getSession('UR_Name')+" - 기타근무 신청서");
	            
	            if (JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
	                XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_OTHER_WORK_INFO), 'json', '#TBL_OTHER_WORK_INFO', 'W');
	            } else {
	                XFORM.multirow.load('', 'json', '#TBL_OTHER_WORK_INFO', 'W', { minLength: 1 });
	            }
			}
            
            if (CFN_GetQueryString("RequestProcessID") != "undefined") {
				$("#HID_PROCESSID").val(CFN_GetQueryString("RequestProcessID"));
			}
        }else{
        	//<!--loadMultiRow_Write-->
            if (JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
                XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_OTHER_WORK_INFO), 'json', '#TBL_OTHER_WORK_INFO', 'W');
            } else {
                XFORM.multirow.load('', 'json', '#TBL_OTHER_WORK_INFO', 'W', { minLength: 1 });
            }
        }
    }
}

function setSelect(){
	CFN_CallAjax("/groupware/attendCommon/getOtherJobList.do", {}, function (data){ 
		var tarType = $('select[name="WorkType"]');
	    $(data.jobList).each(function(i, v) {
			tarType.append($('<option/>', { 
		        value: v.JobStsSeq,
		        text : ( (v.MultiDisplayName==null || v.MultiDisplayName=='' ) ?v.JobStsName :v.MultiDisplayName ) 
		    }));
	    });
	}, false, 'json');
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
    		if(checkHoliday()) {
    			if(checkWorkingTime()) {
    				returnBol = true;
        		} else {
        			returnBol = false;
        		}
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
}

//본문 XML로 구성
function makeBodyContext() {
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("TBL_OTHER_WORK_INFO", "rField"));
	
    return bodyContextObj;
}


function getOtherWorkData() {
	CFN_CallAjax("/approval/legacy/getFormInstData.do", {"FormInstID":$("#HID_OTHER_WORK_FIID").val()}, function (data){ 
		receiveHTTPState(data); 
	}, false, 'json');
}

function receiveHTTPState(dataresponseXML) {
	var xmlReturn = dataresponseXML.Table;
	var errorNode = dataresponseXML.error;
	if (errorNode != null && errorNode != undefined) {
		Common.Error("Desc: " + $(errorNode).text());
	} else {
		$(xmlReturn).each(function (i, elm) {
			SetData(elm.BodyContext);
		});
	}
}

function SetData(pData) {
	var jsonObj = $.parseJSON(Base64.b64_to_utf8(pData)); // xml을 json으로 변경하기
	var ones = $$(Base64.b64_to_utf8(pData)).remove("TBL_OTHER_WORK_INFO").json();
	
	// 최하위노드를 찾아서  mField에 매핑
	GetLastNode(ones);
	
	//멀티로우 Table 값 매핑
	XFORM.multirow.load(JSON.stringify(jsonObj.TBL_OTHER_WORK_INFO), "json", "#TBL_OTHER_WORK_INFO", 'W');
}

function GetLastNode(obj) {
	for(var key in obj){
		if($$(obj).find(key).valLength()>0){
			GetLastNode($$(obj).find(key).json());
		}else{
			$("[id=" + key.toUpperCase() + "]").val($$(obj).attr(key));
			$("[id=" + key.toUpperCase() + "]").text($$(obj).attr(key));
		}
	}
}

//신청시간 체크
function chkWorkTime(obj) {
	var sObj = $(obj).closest("tr").find("input[name=StartTime]").val().replace(":", "");
	var eObj = $(obj).closest("tr").find("input[name=EndTime]").val().replace(":", "");
	
	if(sObj != "" && eObj != "") {
		var sObjTime = parseInt(sObj.substring(0, 2) * 3600) + parseInt(sObj.substring(2) * 60);
		var eObjTime = parseInt(eObj.substring(0, 2) * 3600) + parseInt(eObj.substring(2) * 60);
		
		if(sObjTime > eObjTime){
			Common.Warning("시작시간은 종료시간보다 먼저일 수 없습니다.");
			$(obj).closest("tr").find("input[name=StartTime]").val(null);
			$(obj).closest("tr").find("input[name=EndTime]").val(null);
		}
	}
}

//신청시간 계산
function calWorkTime(obj) {
	var sObj = $(obj).closest("tr").find("input[name=StartTime]").val().replace(":", "");
	var eObj = $(obj).closest("tr").find("input[name=EndTime]").val().replace(":", "");
	var idleTime = $(obj).closest("tr").find("input[name=IdleTime]").val();
	
	if(sObj != "" && eObj != "" && sObj <= eObj) {
		var sObjTime = parseInt(sObj.substring(0, 2) * 3600) + parseInt(sObj.substring(2) * 60);
		var eObjTime = parseInt(eObj.substring(0, 2) * 3600) + parseInt(eObj.substring(2) * 60);
		var gap = eObjTime - sObjTime - (idleTime == "" ? 0 : parseInt(idleTime * 60));
		var h = "";
		var m = "";
		
		h = Math.floor(gap/3600) < 10 ? "0" + Math.floor(gap/3600) : Math.floor(gap/3600);
		m = Math.floor((gap - (h*3600))/60) < 10 ? "0" + Math.floor((gap - (h*3600))/60) : Math.floor((gap - (h*3600))/60);
		
		$(obj).closest("tr").find("input[name=WorkTime]").val(h + ":" + m);
		
		checkWorkingTimeOne(obj);
		calTotalTime();
		checkAvailableTime(obj);
	}
}

//조직도 팝업
var objTr;
function OpenWinEmployee(obj) {
	objTr = $(obj).closest("tr");
	$(objTr).find("input[name=UserCode]").val("");
	$(objTr).find("input[name=CompanyCode]").val("");
	$(objTr).find("input[name=UserName]").val("");
    
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B9", "조직도", 1000, 580, "");
}

function Requester_CallBack(pStrItemInfo) {
	var oJsonOrgMap = $.parseJSON(pStrItemInfo);
	
	if(oJsonOrgMap.item.length > 1) {
		$(objTr).nextUntil(".totalTr").remove();
	}

	$.each(oJsonOrgMap.item, function(i, v) {
		if(i == 0) {
			$(objTr).find("input[name=UserCode]").val(v.UserCode);
			$(objTr).find("input[name=CompanyCode]").val(v.ETID);
			$(objTr).find("input[name=UserName]").val(CFN_GetDicInfo(v.DN));
		} else {
			XFORM.multirow.addRow($('#TBL_OTHER_WORK_INFO'));
			
			var addTr = $('#TBL_OTHER_WORK_INFO').find(".multi-row").last();
			$(addTr).find("input[name=UserCode]").val(v.UserCode);
			$(addTr).find("input[name=CompanyCode]").val(v.ETID);
			$(addTr).find("input[name=UserName]").val(CFN_GetDicInfo(v.DN));
		}
	});
}

//주간 52시간 체크
function checkWorkingTime() {
	var returnBol = false;
	var tblWorkInfo = getBodyContext().BodyContext.TBL_OTHER_WORK_INFO;
	if(tblWorkInfo != undefined){
		if(tblWorkInfo.length == undefined) {
			tblWorkInfo = [tblWorkInfo];
		}
		
		CFN_CallAjax("/approval/legacy/attendanceWorkTimeCheck.do", {"workInfo" : JSON.stringify(tblWorkInfo)}, function (data){
			if(data.status == "SUCCESS"){
				var workTimeList = data.workTimeList;
				
				$(workTimeList).each(function(){
					var workTime = parseInt(this.workTimeCheck.substring(0, 2) * 3600) + parseInt(this.workTimeCheck.substring(2) * 60);
					
					if(workTime >= 187200) { //52시간
						Common.Warning(this.UserName + "님의 '" + this.sWeekDate + "~" + this.eWeekDate + "\r\n 근무시간이 52시간을 초과합니다.");
						return false;
					} else {
						//양식단 시간 합계
						var tot = calWorkingTimeUser(this.UserCode, this.sWeekDate, this.eWeekDate);
						
						if(parseInt(workTime) + parseInt(tot) > 187200) { //52시간
							var h = "";
							var m = "";
							var diff = 187200 - parseInt(workTime);
							
							h = Math.floor(diff/3600) < 10 ? "0" + Math.floor(diff/3600) : Math.floor(diff/3600);
							m = Math.floor((diff - (h*3600))/60) < 10 ? "0" + Math.floor((diff - (h*3600))/60) : Math.floor((diff - (h*3600))/60);
							
							Common.Warning(this.UserName + "님의 '" + this.sWeekDate + "~" + this.eWeekDate + "'\r\n 추가 근무 가능 시간은 " + h + "시간 " + m + "분 입니다.");
							returnBol = false;
							return false;
						} else {
							returnBol = true;
						}
					}
				});
			} else{
				Common.Warning("오류가 발생했습니다.");
				return false;
			}
		}, false, 'json');
	} else {
		return false;
	}
	
	return returnBol;
}

//휴일일자 체크
function checkHoliday() {
	var returnBol = false;
	var tblWorkInfo = getBodyContext().BodyContext.TBL_OTHER_WORK_INFO;
	if(tblWorkInfo != undefined){
		if(tblWorkInfo.length == undefined) {
			tblWorkInfo = [tblWorkInfo];
		}
		
		CFN_CallAjax("/approval/legacy/attendanceHolidayCheck.do", {"workInfo" : JSON.stringify(tblWorkInfo)}, function (data){
			if(data.status == "SUCCESS"){
				var notHoliday = data.notHoliday;
				if(notHoliday.length > 0){
					var messageStr = "";
					
					$(notHoliday).each(function(){
						alert(this.UserName + "님은  '" + this.JobDate +"'에 휴무가 아닙니다.");
          			 });
					
					return false;
          		} else{
          			returnBol = true;
          		}
			} else{
				Common.Warning("오류가 발생했습니다.");
				return false;
			}
		}, false, 'json');
	} else {
		return false;
	}
	
	return returnBol;
}

//20190919 추가
function checkWorkingTimeOne(obj) {
	var userCode = $(obj).closest("tr").find("input[name=UserCode]").val();
	var userName = $(obj).closest("tr").find("input[name=UserName]").val();
	var companyCode = $(obj).closest("tr").find("input[name=CompanyCode]").val();
	var targetDate = $(obj).closest("tr").find("input[name=JobDate]").val();
	
	if(targetDate != "") {
		CFN_CallAjax("/approval/legacy/attendanceWorkTimeCheckOne.do", {"UserCode":userCode, "CompanyCode":companyCode, "TargetDate":targetDate}, function (data){
			if(data.status == "SUCCESS"){
				var isOK = data.list.workTimeCheck.split("/")[0];
				var sWeekDate = data.list.sWeekDate;
				var eWeekDate = data.list.eWeekDate;
				
				if(isOK == "N") {
					$(obj).val("");
					$(obj).closest("tr").find("input[name=WorkTime]").val("");
					
					Common.Warning("근무시간이 초과되어 신청할 수 없습니다.");
				} else {
					var tot = calWorkingTimeUser(userCode, sWeekDate, eWeekDate); //양식단 시간 합계
					var rmTime = data.list.workTimeCheck.split("/")[1];
					
					if(parseInt(rmTime) < parseInt(tot)) {
						var h = Math.floor(rmTime/3600) < 10 ? "0" + Math.floor(rmTime/3600) : Math.floor(rmTime/3600);
						var m = Math.floor((rmTime - (h*3600))/60) < 10 ? "0" + Math.floor((rmTime - (h*3600))/60) : Math.floor((rmTime - (h*3600))/60);
						
						$(obj).val("");
						$(obj).closest("tr").find("input[name=WorkTime]").val("");
						
						Common.Warning(userName + "님의 " + sWeekDate + "~" + eWeekDate + "\r\n 추가 근무 가능 시간은 " + h + "시간 " + m + "분 입니다.");
					}
					//'가능시간'에 추가 근무 가능한 시간 표시
					var h = Math.floor(rmTime/3600) < 10 ? "0" + Math.floor(rmTime/3600) : Math.floor(rmTime/3600);
					var m = Math.floor((rmTime - (h*3600))/60) < 10 ? "0" + Math.floor((rmTime - (h*3600))/60) : Math.floor((rmTime - (h*3600))/60);
					$(obj).closest("tr").find("input[name=AvailableTime]").val(h+":"+m);
				}
			} else{
				Common.Warning("오류가 발생했습니다.");
				return false;
			}
		}, false, 'json');
	}
}

function checkHolidayOne(obj) {
	var userCode = $(obj).closest("tr").find("input[name=UserCode]").val();
	var userName = $(obj).closest("tr").find("input[name=UserName]").val();
	var companyCode = $(obj).closest("tr").find("input[name=CompanyCode]").val();
	var targetDate = $(obj).closest("tr").find("input[name=JobDate]").val();
	
	CFN_CallAjax("/approval/legacy/attendanceHolidayCheckOne.do", {"UserCode":userCode, "CompanyCode":companyCode, "TargetDate":targetDate}, function (data){
		if(data.status == "SUCCESS"){
			var isHoliday = data.isHoliday.split("/")[0];
			
			if(isHoliday != "H") {
				$(obj).val("");
				
				Common.Warning(userName + "님은 '" + targetDate + "'에 휴무가 아닙니다.");
			}
			ChangeSubject(obj);
		} else{
			Common.Warning("오류가 발생했습니다.");
			return false;
		}
	}, false, 'json');
}

//같은 근무자가 연속으로 신청할 경우 가능시간 조정
function checkAvailableTime(obj){
	var trnum = $(obj).closest("tr").prevAll().length;
	
	if(trnum>3){
		var prevName = $(obj).closest("tr").prev().find("input[name=UserName]").val();
		var nowName = $(obj).closest("tr").find("input[name=UserName]").val();
		if(prevName == nowName){
			var wObj = $(obj).closest("tr").prev().find("input[name=WorkTime]").val().replace(":", ""); //이전 행 신청시간
			var aObj = $(obj).closest("tr").prev().find("input[name=AvailableTime]").val().replace(":", ""); //이전 행 가능시간
			
			if(wObj != "" && aObj != "" && wObj <= aObj) {
				var wObjTime = parseInt(wObj.substring(0, 2) * 3600) + parseInt(wObj.substring(2) * 60);
				var aObjTime = parseInt(aObj.substring(0, 2) * 3600) + parseInt(aObj.substring(2) * 60);
				var gap = aObjTime - wObjTime;
				var h = "";
				var m = "";
				
				h = Math.floor(gap/3600) < 10 ? "0" + Math.floor(gap/3600) : Math.floor(gap/3600);
				m = Math.floor((gap - (h*3600))/60) < 10 ? "0" + Math.floor((gap - (h*3600))/60) : Math.floor((gap - (h*3600))/60);
				
				$(obj).closest("tr").find("input[name=AvailableTime]").val(h+":"+m);
			}
		}
	}
	
}
//날짜 선택시 제목 변경
function ChangeSubject(obj){
	var objDate = $(obj).val();
	var date = new Date(objDate).format('MM/dd');
	
	$("#Subject").val("기타근무 신청서_"+Common.getSession('UR_Name')+"("+date+")");
}