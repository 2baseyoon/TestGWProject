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

var postComment="\r\n 연장/휴일 추가 근무 가능 시간으로 연장/휴일근무 신청서 재 상신 부탁드리며, \r\n 주 12시간 초과 근무시간에 대해서는 팀장님께 별도로 메일 보고하여 주시기 바랍니다.";

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
    
    if(Common.getBaseConfig("ExtenStartTime") == "" && Common.getBaseConfig("ExtenEndTime") == "" ){
		//기본 설정 값
	}else if(Common.getBaseConfig("ExtenStartTime") == "0000" && Common.getBaseConfig("ExtenEndTime") == "0000" && Common.getBaseConfig("ExtenUnit") == "0"){
		//연장근무시간 설정이 비활성화 되어 있을 경우 기초설정 ExtenStartTime, ExtenEndTime 값 '0000', ExtenUnit 값 해당없음('0')
	}else{
		//연장근무시간 설정이 되어 있는 경우 직접 입력 막기
    	$("input[name=StartTime]").prop("readonly",true);
        $("input[name=EndTime]").prop("readonly",true);
    }
    
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();

	if ((typeof CFN_GetQueryString == "function" && CFN_GetQueryString("RequestFormInstID") != "undefined") || (formJson.BodyContext && formJson.BodyContext.HID_PROCESSID)) {
		$("#headname").text("연장근무 변경 신청서");
		$("#approval_view_formname").text("연장근무 변경 신청서");
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

			var tblWorkInfo ;
			if(tblWorkInfo == undefined) tblWorkInfo = formJson.BodyContext.TBL_WORK_INFO;
			if(tblWorkInfo != undefined) {
				if (tblWorkInfo.length == undefined) {
					tblWorkInfo = [tblWorkInfo];
				}

				var paramsArr = new Array();

				$(tblWorkInfo).each(function () {
					var paramsObj = {
						"UserName" : this.UserName,
						"UserCode" : this.UserCode,
						"JobDate" : this.JobDate,
						"CompanyCode" : this.CompanyCode,
						"ReqType" : "O"
					};
					paramsArr.push(paramsObj);
				});

				CFN_CallAjax("/approval/legacy/attendanceRealWorkInfo.do", {"params" : JSON.stringify(paramsArr)}, function (data){
					if(data.status == "SUCCESS"){
						var realWorkTimeList = data.realWorkTimeList;
						var trHtml = "";
						$(realWorkTimeList).each(function () {
							var realWorkInfo = this.RealWorkInfo;
							if(realWorkInfo != null) {
								if((realWorkInfo.StartTime != null && realWorkInfo.StartTime != "") && (realWorkInfo.EndTime != null && realWorkInfo.EndTime != "")) {
									trHtml += "<tr>";
									trHtml += "<td style='text-align: center'>" + realWorkInfo.UserName + "</td>";
									trHtml += "<td style='text-align: center'>" + realWorkInfo.TargetDate + "</td>";
									trHtml += "<td style='text-align: center'>" + realWorkInfo.StartTime + " ~ " + realWorkInfo.EndTime + "</td>";
									var gap = realWorkInfo.RealACTime * 60;
									var h = "";
									var m = "";

									h = Math.floor(gap / 3600) < 10 ? "0" + Math.floor(gap / 3600) : Math.floor(gap / 3600);
									m = Math.floor((gap - (h * 3600)) / 60) < 10 ? "0" + Math.floor((gap - (h * 3600)) / 60) : Math.floor((gap - (h * 3600)) / 60);
									trHtml += "<td style='text-align: center'>" + h + ":" + m + "</td>";
									trHtml += "</tr>";
								}
							}
						});
						if(trHtml != "") {
							$("#TBL_REAL_WORK_INFO_TR").after(trHtml);
							$("#TBL_REAL_WORK_INFO").show();
						}
					} else{
						Common.Warning("오류가 발생했습니다.");
						return false;
					}
				}, false, 'json');
			}
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
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            
            if (CFN_GetQueryString("RequestFormInstID") != "undefined") {
				$("#HID_OVERTIME_WORK_FIID").val(CFN_GetQueryString("RequestFormInstID"));
				getOvertimeWorkData();
			}else{
				//formTitle = "연장근무 신청서";
	            
	            if (JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
	                XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_WORK_INFO), 'json', '#TBL_WORK_INFO', 'W');
	            } else {
	                XFORM.multirow.load('', 'json', '#TBL_WORK_INFO', 'W', { minLength: 1 });
	            }
			}

            if (CFN_GetQueryString("RequestProcessID") != "undefined") {
				$("#HID_PROCESSID").val(CFN_GetQueryString("RequestProcessID"));
			}
            
			//제목설정
			//$("#Subject").val(formTitle+"_"+Common.getSession('UR_Name')+"("+today.format('MM/dd')+")");
			if(formJson.Request.mode == "DRAFT"){
				setSubject();
			}
            
        }else{
        	//<!--loadMultiRow_Write-->
        	if (JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
        		XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_WORK_INFO), 'json', '#TBL_WORK_INFO', 'W');
        	} else {
        		XFORM.multirow.load('', 'json', '#TBL_WORK_INFO', 'W', { minLength: 1 });
        	}
        }
     
    }
}

function setLabel() {
}

function setFormInfoDraft() {
}

function checkForm(bTempSave) {
	
	var returnBol = true;
	
    if (bTempSave) {
        return true;
    } else {
    	if(EASY.check().result){
    		if(getInfo("Request.mode") == "DRAFT" ||  getInfo("Request.mode")=="REDRAFT"  || getInfo("Request.subkind") == "T005"
    				|| document.getElementById("ACTIONINDEX").value == "REJECT" ||		document.getElementById("ACTIONINDEX").value == "DISAGREE") return true;// 기안은 입력할 때 체크
    		if(checkWorkingTime()) {
				returnBol = true;
    		} else {
    			returnBol = false;
    		}
    		return returnBol;
    	} else {
    		return false;
    	}
    }
    
    //return returnBol;
    /*
	
	if (bTempSave) {
        return true;
    } else {
        // 필수 입력 필드 체크
        return EASY.check().result;
    }*/
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

function getOvertimeWorkData() {
	CFN_CallAjax("/approval/legacy/getFormInstData.do", {"FormInstID":$("#HID_OVERTIME_WORK_FIID").val()}, function (data){ 
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
	var ones = $$(Base64.b64_to_utf8(pData)).remove("TBL_WORK_INFO").json();
	
	// 최하위노드를 찾아서  mField에 매핑
	GetLastNode(ones);
	
	//멀티로우 Table 값 매핑
	XFORM.multirow.load(JSON.stringify(jsonObj.TBL_WORK_INFO), "json", "#TBL_WORK_INFO", 'W');
	
	calTotalTime();
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

//신청시간 계산(row에서 개벌 호출)
function calWorkTime(obj) {
	var sObj = $(obj).closest("tr").find("input[name=StartTime]").val().replace(":", "");
	var eObj = $(obj).closest("tr").find("input[name=EndTime]").val().replace(":", "");

	var NextDay = $(obj).closest("tr").find("select").val()
	var idleTime = $(obj).closest("tr").find("input[name=IdleTime]").val();

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
				$(obj).closest("tr").find("input[name=IdleTime]").val(idleTime);
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
			$(obj).closest("tr").find("input[name=WorkTime]").val(h + ":" + m);
			
			checkWorkingTimeOne(obj);
			calTotalTime();
			checkAvailableTime(obj);
		}
		else{
			Common.Warning("시작시간은 종료시간보다 앞에 있을 수 없습니다.");
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
			XFORM.multirow.addRow($('#TBL_WORK_INFO'));
			
			var addTr = $('#TBL_WORK_INFO').find(".multi-row").last();
			$(addTr).find("input[name=UserCode]").val(v.UserCode);
			$(addTr).find("input[name=CompanyCode]").val(v.ETID);
			$(addTr).find("input[name=UserName]").val(CFN_GetDicInfo(v.DN));
		}
	});
	
	setSubject();
}

//주간 52시간 체크(승인시 확인)
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
				
				$(workTimeList).each(function(idx, obj){
					var workTimeCheck =obj["workTimeCheck"].split("/");
					var isOK = workTimeCheck[0];
					if (isOK== "D"){
						$("#RESULT_COMMENT").val(this.UserName + "님의  근무시간이 중복됩니다."+postComment);
						alert("근무시간이 중복됩니다.");
						return false;
					}
					var sWeekDate = workTimeCheck[2];
					var eWeekDate = workTimeCheck[3];
					if(isOK == "N") {
						$("#RESULT_COMMENT").val(this.UserName + "님의 '" + sWeekDate + "~" + eWeekDate + "\r\n 근무시간이 초과합니다."+postComment);
						alert(this.UserName + "님의 '" + sWeekDate + "~" + eWeekDate + "\r\n 근무시간이 초과합니다.");
						return false;
					} else {
						//양식단 시간 합계
						var tot = calWorkingTimeUser(this.UserCode, sWeekDate, eWeekDate);
						var rmTime = parseInt(workTimeCheck[1])*60;

						if(rmTime < parseInt(tot)) {
							var h = Math.floor(rmTime/3600) < 10 ? "0" + Math.floor(rmTime/3600) : Math.floor(rmTime/3600);
							var m = Math.floor((rmTime - (h*3600))/60) < 10 ? "0" + Math.floor((rmTime - (h*3600))/60) : Math.floor((rmTime - (h*3600))/60);
							
							$("#RESULT_COMMENT").val(this.UserName + "님의 '" + sWeekDate + "~" + eWeekDate + "'\r\n 연장/휴일 추가 근무 가능 시간은 " + h + "시간 " + m + "분 입니다."+postComment);
							alert(this.UserName + "님의 '" + sWeekDate + "~" + eWeekDate + "'\r\n 추가 근무 가능 시간은 " + h + "시간 " + m + "분 입니다.");
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

//리스트별 총 시간 구하기(다건 입력시)
function calWorkingTimeUser(userCode, sWeekDate, eWeekDate) {
	var sum = 0;
	var h = "";
	var m = "";

	var tblWorkInfo ;
	if (getBodyContext().BodyContext != undefined ) tblWorkInfo = getBodyContext().BodyContext.TBL_WORK_INFO;
	if(tblWorkInfo == undefined) tblWorkInfo = formJson.BodyContext.TBL_WORK_INFO;
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
function checkWorkingTimeOne(obj) {
	var userCode = $(obj).closest("tr").find("input[name=UserCode]").val();
	var userName = $(obj).closest("tr").find("input[name=UserName]").val();
	var companyCode = $(obj).closest("tr").find("input[name=CompanyCode]").val();
	var targetDate = $(obj).closest("tr").find("input[name=JobDate]").val();
	var startTime = $(obj).closest("tr").find("input[name=StartTime]").val();
	var endTime = $(obj).closest("tr").find("input[name=EndTime]").val();
	
	if(targetDate != "") {
		CFN_CallAjax("/approval/legacy/attendanceWorkTimeCheckOne.do", {"UserCode":userCode, "CompanyCode":companyCode, "TargetDate":targetDate, "StartTime":startTime, "EndTime":endTime, "orgProcessId":$("#HID_PROCESSID").val()}, function (data){
			if(data.status == "SUCCESS"){
				var workTimeCheck =data.list.workTimeCheck.split("/");
				var isOK = workTimeCheck[0];
				var sWeekDate = workTimeCheck[2];
				var eWeekDate = workTimeCheck[3];

				if (isOK== "D"){
					Common.Warning("근무시간이 중복됩니다.");
					$(obj).closest("tr").find("input[name=WorkTime]").val("");
					$(obj).closest("tr").find("input[name=AvailableTime]").val("");
					$(obj).closest("tr").find("input[name=AvailableTime]").attr("data-map","");
					return false;
				}
				if(isOK == "N") {
					$(obj).val("");
					$(obj).closest("tr").find("input[name=WorkTime]").val("");
					
					Common.Warning("근무시간이 초과되어 신청할 수 없습니다.");
				} else {
					var tot = calWorkingTimeUser(userCode, sWeekDate, eWeekDate); //양식단 시간 합계
					var rmTime = parseInt(workTimeCheck[1])*60;

					if(rmTime < parseInt(tot)) {
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
					$(obj).closest("tr").find("input[name=AvailableTime]").attr("data-map",JSON.stringify({"sWeekDate": sWeekDate,"eWeekDate":eWeekDate}));
				}
			} else{
				Common.Warning("오류가 발생했습니다.");
				return false;
			}
		}, false, 'json');
	}
}

//같은 근무자가 연속으로 신청할 경우 가능시간 조정
function checkAvailableTime(obj){
	var trnum = $("#TBL_WORK_INFO tr").length-1;
	var objIdx = $(obj).closest("tr").index();
	for(var j=objIdx; j< trnum;j++){
		var nowName = $("#TBL_WORK_INFO tr:eq("+j+") input[name=UserName]").val();
		var dataMapStr = $("#TBL_WORK_INFO tr:eq("+j+") input[name=AvailableTime]").attr("data-map");
		if ( dataMapStr=="" || dataMapStr==undefined) continue;
		var dataMap = JSON.parse(dataMapStr);
		var sWeekDate = dataMap["sWeekDate"];
		var eWeekDate = dataMap["eWeekDate"];
	
		for (var i= j-1; i>2; i--){
			var prevName = $("#TBL_WORK_INFO tr:eq("+i+") input[name=UserName]").val();
			var prevDate = $("#TBL_WORK_INFO tr:eq("+i+") input[name=JobDate]").val();
	
			if(prevName == nowName && (prevDate >= sWeekDate && prevDate <= eWeekDate)){
				var wObj = $("#TBL_WORK_INFO tr:eq("+i+") input[name=WorkTime]").val().replace(":", ""); //이전 행 신청시간
				var aObj = $("#TBL_WORK_INFO tr:eq("+i+") input[name=AvailableTime]").val().replace(":", ""); //이전 행 가능시간
				
				if(wObj != "" && aObj != "" && wObj <= aObj) {
					var wObjTime = parseInt(wObj.substring(0, 2) * 3600) + parseInt(wObj.substring(2) * 60);
					var aObjTime = parseInt(aObj.substring(0, 2) * 3600) + parseInt(aObj.substring(2) * 60);
					var gap = aObjTime - wObjTime;
					var h = "";
					var m = "";
					
					h = Math.floor(gap/3600) < 10 ? "0" + Math.floor(gap/3600) : Math.floor(gap/3600);
					m = Math.floor((gap - (h*3600))/60) < 10 ? "0" + Math.floor((gap - (h*3600))/60) : Math.floor((gap - (h*3600))/60);
					$("#TBL_WORK_INFO tr:eq("+j+") input[name=AvailableTime]").val(h+":"+m);
				}
				break;
			}
		}
	}	
}

// 첫행 날짜로 제목 셋팅
function setSubject(){
	var sUserName = $("#TBL_WORK_INFO").find(".multi-row").eq(0).find("[name='UserName']").val();
	if(!sUserName) sUserName = CFN_GetDicInfo(getInfo("AppInfo.usnm"));
	
	var sDate = $("#TBL_WORK_INFO").find(".multi-row").eq(0).find("[name='JobDate']").val();
	sDate = (sDate) ? sDate : "";
	if(sDate.length == 8) sDate = sDate.substring(0,4) + "-" + sDate.substring(4,6) + "-" + sDate.substring(6,8);
	var date = new Date(sDate);
	if(!isNaN(date)) $("#Subject").val($("#headname").text()+"_"+sUserName+"("+date.format('MM/dd')+")");
	else $("#Subject").val($("#headname").text()+"_"+sUserName);
}
