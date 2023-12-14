//json object로 대체
//getInfo, setInfo 대체 방안
//sKey = $.level1.level2		ex) $.BodyContext.InitiatorDisplay
function getInfo(sKey) {
	try {
		var l_formJson;
		
		if(typeof m_oInfoSrc != "undefined" && m_oInfoSrc) {
			if ('function' == typeof (m_oInfoSrc.getInfo) || 'object' == typeof (m_oInfoSrc.getInfo)) {
	        	if(m_oInfoSrc.g_dicFormInfo != undefined && m_oInfoSrc.g_dicFormInfo.item("CLSYS") == "approval") { //이어카운팅에서 결재로 넘어올 때  getInfo 함수가 남아있음
	                return m_oInfoSrc.g_dicFormInfo.item(sKey);
	        	} else {
	        		l_formJson = m_oInfoSrc.formJson;
	        	}
	        } else {
	            return m_oInfoSrc.g_dicFormInfo.item(sKey);
	        }
		} else {
			l_formJson = formJson;
		}
		
		sKey = "$."+sKey;
		
		var isExistJsonValue = jsonPath(l_formJson, sKey).length == undefined ? false : true;
		var formJsonValue = isExistJsonValue ? jsonPath(l_formJson, sKey)[0] : jsonPath(l_formJson, sKey);
	  
		if (formJsonValue === false && isExistJsonValue === false) {
			return undefined;
		} else if (formJsonValue.constructor === "".constructor) {
			return formJsonValue;
		} else if (formJsonValue.constructor === [].constructor || new Array(formJsonValue).constructor === [].constructor || formJsonValue.constructor === {}.constructor || formJsonValue.constructor === true.constructor) {
			return JSON.stringify(formJsonValue);
		} else {
			return undefined;
		}
	} catch (e) {
		return undefined;
	}
}

function setInfo(sKey, sValue, sException) {
	try {
		var sKeyArr = sKey.split('.');
	  
		switch(sKeyArr.length){
		case 0:
			return undefined;
		default:
			var findKey = sKey.replace(/\./g, ">");					// Jsoner 라이브러리를 통해 찾을 수 있게 변경
	  
			if(sKeyArr.length == 1){
				$$(formJson).attr(sKeyArr[0], sValue);
			}
			else if($$(formJson).find(findKey).exist()) { // 해당 키값이 있을 경우 formJson에 값을 세팅해줌
				$$(formJson).find(findKey.substring(0, findKey.lastIndexOf('>'))).attr(sKeyArr[sKeyArr.length-1], sValue);
			}
			else { // 해당 키값이 없을 경우, formJson에 상위 구조를 만들어준 후 값을 세팅
				var strKey = "";

				$(sKeyArr).each(function(i, key){
					strKey += ">"+key;
					var val;
					if(!$$(formJson).find(strKey).exist()){
						if(i != sKeyArr.length-1)
							val = {};
						else
							val = sValue;
						$$(formJson).find(strKey.substring(0, strKey.lastIndexOf('>'))).attr(key, val);
					}
	  		  	});
			} 
			break;
		}
	} catch (e) {
		if (sException == null) {
			return undefined;
		}
	}
}

//가로양식은 여기서 정의 하세요.
function IsWideOpenFormCheck(fmpf, formId) {
    var _return = false;
    try {
    	// 기초설정 방식 제거. 2022.03.28
    	/*if(Common.getBaseConfig("WideOpenFormprefix").toLowerCase().indexOf(fmpf.toLowerCase()) > -1) {
    		_return = true;
    	}*/

		// redis 를 활용하나 baseconfig 는 domain 별 관리될 수 있으므로 formId(unique) 기준 redis cache
		if(fmpf != undefined || formId != undefined){
			var isCached = false;
			/*
			// 사용자 캐시초기화시에 BaseConfigXXX 만 지우므로.
			var LOCALSTORAGENAME = "BaseConfig_APV_FORMEXTINFO";
			var formExtInfoAll = coviStorage.getValue(LOCALSTORAGENAME);
			var formExtInfoAllObj = {};
			if(formExtInfoAll != undefined && "" != formExtInfoAll){
				formExtInfoAllObj = JSON.parse(formExtInfoAll);
				if(formExtInfoAllObj[formId]){
					isCached = true;
				}
			}
			*/
			if(isCached == true){
				_return = formExtInfoAllObj[formId].UseWideForm;
			}else{
				var strurl = "/approval/user/getCachedFormExtInfo.do";// FormCon.java
				$.ajax({
					url : strurl,
					type:"post",
					async : false,
					data:{
						FormID : formId,
						FormPrefix : fmpf
					},
					success:function (data) {
						if(data.status == "SUCCESS") {
							var extInfo = data.result;
							//formExtInfoAllObj[formId] = extInfo;
							//coviStorage.setValue(LOCALSTORAGENAME, JSON.stringify(formExtInfoAllObj));
							
							_return = extInfo.UseWideForm == "Y";
						}else{
							//CFN_ErrorAjax(strurl, response, status, error);
							throw "Fail to formExtInfo.";
						}
					},
					error:function(response, status, error){
						//throw "Error on Ajax Call ["+ strurl +"]";
						if(window.console)console.error("Error on Ajax Call ["+ strurl +"]");
						_return = false; 
					}
				});
			}
			
		}
    } catch (e) {
		if(window.console)console.error(e);
		_return = false; 
	}
    return _return;
}

// 목록 및 홈 화면에서 승인 및 반려
function approvalDoButtonAction(mode, subkind, taskId, actionMode, actionComment,forminstID, isMobile, processID, UserCode, signImage, isSerial, processName, apvToken, authKey, formID, workitemID, formDraftkey){
	
	var apvToken = apvToken || "";
	var authKey = authKey || "";
	
	//다국어 개별호출 -> 일괄호출
	var sessionObj = Common.getSession(); //전체호출
	
	if(actionMode == "approved"){
		if(subkind == "T009" || subkind == "T004")
			actionMode = "AGREE";
		else
			actionMode = "APPROVAL";
	}else if(actionMode == "reject"){
		if(subkind == "T009" || subkind == "T004")
			actionMode = "DISAGREE";
		else
			actionMode = "REJECT";
	}
	
	if(subkind == "T009" || subkind == "T004"){		// 합의 및 협조
		mode = "PCONSULT";
	}else if((subkind == "C" || subkind == "AS") && approvalType == "DEPT"){
		mode = "SUBREDRAFT";
	}else if(subkind == "T016"){
		mode = "AUDIT";
	}else{
		if(processName == "Sub"){
			mode = "SUBAPPROVAL";
		}else{
			mode = "APPROVAL";
		}		
	}	
	
    var sJsonData = {};
    
    $.extend(sJsonData, {"mode": mode});
    $.extend(sJsonData, {"subkind": subkind});
    $.extend(sJsonData, {"taskID": taskId});
    $.extend(sJsonData, {"FormInstID": forminstID});
    $.extend(sJsonData, {"usid" : sessionObj["USERID"]});
    $.extend(sJsonData, {"actionMode": actionMode});
    $.extend(sJsonData, {"signimagetype" : signImage});
    $.extend(sJsonData, {"gloct" : ""});
    $.extend(sJsonData, {"actionComment": actionComment});
    $.extend(sJsonData, {"workitemID": workitemID});
    $.extend(sJsonData, {"g_authKey": authKey});
    $.extend(sJsonData, {"g_password": apvToken});
    $.extend(sJsonData, {"formDraftkey" : formDraftkey});
    $.extend(sJsonData, {"formID" : formID});

    if(isSerial) { // 연속결재 처리 todo
    	$.extend(sJsonData, {"actionComment_Attach": "[]"});	
    }
    else {
    	$.extend(sJsonData, {"actionComment_Attach": document.getElementById("ACTIONCOMMENT_ATTACH").value});
    }
    
    // 대결자가 결재하는 경우 결재선 변경
    var apvList = setDeputyList(mode, subkind, taskId, actionMode, actionComment,forminstID, isMobile, processID, UserCode);
    
    if(apvList != arrDomainDataList[processID]){
    	$.extend(sJsonData, {"processID" : processID});
    	$.extend(sJsonData, {"ChangeApprovalLine" : apvList});
    }
    
    var formData = new FormData();
    // 양식 기안 및 승인 정보
    formData.append("formObj", Base64.utf8_to_b64(JSON.stringify(sJsonData)));
	
	$.ajax({
		url:"/approval/draft.do",
		data: formData,
		type:"post",
		dataType : 'json',
		processData : false,
        contentType : false,
		success:function (res) {
			if (res.status == "SUCCESS" || (res.status == "FAIL" && res.message.indexOf("NOTASK")>-1)) {
				if(res.status == "FAIL"){
					res.message = Common.getDic("msg_apv_notask").replace(/(<([^>]+)>)/gi, "");
				}
				if(isMobile){
					alert(res.message);
					location.reload();
				} else if (isSerial) {
					callBackDoProcess();
				} else{
					Common.Inform(res.message, "Inform", function(){
						if(location.href.indexOf("/approval/layout/approval_Home.do") > -1) {
							window.isApprovalHomeReload = true;
						}
						CoviMenu_GetContent(location.href.replace(location.origin, ""), false);
						if(location.href.indexOf("/approval/layout/approval_Home.do") < 0) {
							setDocreadCount();
						}
					});
				}
			}else{
				// 엔진쪽에서 Transaction lock (일시적) 인경우, 병렬합의자 동시 액션등.
				if(/VariableInstanceEntity(.)+ was updated by another transaction concurrently/g.test(res.message)){
					res.message = Common.getDic("msg_apv_tasklocked");
				}
				Common.Warning(Common.getDic("msg_apv_030") + " : " + res.message);			//오류가 발생했습니다.
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/draft.do", response, status, error);
		}
	});
}

function setDeputyList(mode, subkind, taskId, actionMode, actionComment, forminstID, isMobile, processID, UserCode) {//대결일 경우 처리
	try {
		var sessionObj = Common.getSession(); //전체호출
        //var jsonApv = $.parseJSON(arrDomainDataList[forminstID]);
		var jsonApv = arrDomainDataList[processID];
		
        //담당 수신자 대결
        var isChkDeputy = false;
    	var oCurrentOUNode = $$(jsonApv).find("steps > division").children().find("[divisiontype='receive']").has(">taskinfo[status='pending']");
        if (oCurrentOUNode == null) {
        	oCurrentOUNode = $$(jsonApv).find("steps > division:has(>taskinfo[status='pending'])[divisiontype='receive']");
        }
        
        var oRecOUNode = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']");
        var tempOu = null;
        if (oRecOUNode.length != 0 && $$(oRecOUNode).find("ou").hasChild("person").length == 0) {
        	tempOu = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']");
        	$$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']").remove();
        }
        
        var oChargeNode = $$(oCurrentOUNode).find("step").has("ou>person>taskinfo[status='pending']");

        if (oChargeNode.length != 0) {
            //담당 수신자 대결 S ----------------------------------------
            var objDeputyOU = $$(jsonApv).find("steps>division[divisiontype='receive']>step>ou");
            var chkObjPersonNode = $$(objDeputyOU).find("person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "']").find(">taskinfo[status='pending']");
            var chkObjRoleNode = $$(objDeputyOU).find("role:has(person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "'])");
            if (0 < (chkObjPersonNode.length + chkObjRoleNode.length)) {
                isChkDeputy = true;
            }
        }
        	//담당 수신자 대결 E -----------------------------------------
        	
		
		if(!sessionObj["ApprovalParentGR_Name"]) sessionObj["ApprovalParentGR_Name"] = sessionObj["GR_MultiName"];

        if (mode == "APPROVAL" || mode == "PCONSULT" || mode == "RECAPPROVAL" || mode == "AUDIT") { //기안부서결재선 및 수신부서 결재선
            var oFirstNode; //step에서 taskinfo select로 변경

            if (mode == "APPROVAL" || mode== "RECAPPROVAL") {
                oFirstNode = $$(jsonApv).find("steps>division>step:has([routetype='approve'])>ou>person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "']>taskinfo[status='pending'], steps>division>step:has([routetype='approve'])>ou>role:has(person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "'])");
                if (oFirstNode.length == 0) { //편집 후 결재 시 대결 오류로 인하여 소스 추가
                    oFirstNode = $$(jsonApv).find("steps>division>step:has([routetype='approve'])>ou>person[code='" + sessionObj["USERID"] + "']>taskinfo[status='pending'][kind='substitute']");
                }
            } else if (mode == "PCONSULT") {
                oFirstNode = $$(jsonApv).find("steps>division>step>ou>person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "']>taskinfo[status='pending'], steps>division>step>ou>role>taskinfo:has(person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "'])[status='pending']");
            } else if (mode == "AUDIT") {
                oFirstNode = $$(jsonApv).find("steps>division>step[routetype='audit']>ou>person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "'] > taskinfo[status='pending'], steps>division>step[routetype='audit']>ou>role:has(person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "'])");
            } else {
                oFirstNode = $$(jsonApv).find("steps>division>step[unittype='ou'][routetype='receive']>ou>person[code!='" + sessionObj["USERID"] + "']>taskinfo[kind!='charge'][status='pending']");
            }
            if (oFirstNode.length != 0) {
                var m_bDeputy = true; var m_bApvDirty = true; var elmOU; var elmPerson;
                switch (mode) {
                    case "APPROVAL":
                    case "PCONSULT":
                    case "AUDIT":
                        elmOU = $$(oFirstNode).parent().parent();
                        elmPerson = $$(oFirstNode).parent();
                        break;
                    case "RECAPPROVAL":
                        elmOU = $$(oFirstNode).parent().parent();
                        elmPerson = $$(oFirstNode).parent();
                        break;
                }
                var elmTaskInfo = $$(elmPerson).find("taskinfo");
                var skind = $$(elmTaskInfo).attr("kind");
                var sallottype = "serial";
                var elmStep = $$(elmOU).parent();
                try { if ($$(elmStep).attr("allottype") != null) sallottype = $$(elmStep).attr("allottype"); } catch (e) { coviCmn.traceLog(e); }
                //taskinfo kind에 따라 처리  일반결재 -> 대결, 대결->사용자만 변환, 전결->전결, 기존사용자는 결재안함으로
                switch (skind) {
                    case "substitute": //대결
                        if (actionMode == "APPROVAL") {
                            $$(elmOU).attr("code", sessionObj["ApprovalParentGR_Code"]);
                            $$(elmOU).attr("name", sessionObj["ApprovalParentGR_Name"]);
                        }
                        $$(elmPerson).attr("code", sessionObj["USERID"]);
                        $$(elmPerson).attr("name", sessionObj["UR_MultiName"]);
                        $$(elmPerson).attr("position", sessionObj["UR_JobPositionCode"] + ";" + sessionObj["UR_MultiJobPositionName"]);
                        $$(elmPerson).attr("title", sessionObj["UR_JobTitleCode"] + ";" + sessionObj["UR_MultiJobTitleName"]);
                        $$(elmPerson).attr("level", sessionObj["UR_JobLevelCode"] + ";" + sessionObj["UR_MultiJobLevelName"]);
                        $$(elmPerson).attr("oucode", sessionObj["DEPTID"]);
                        $$(elmPerson).attr("ouname", sessionObj["GR_MultiName"]);
                        $$(elmPerson).attr("sipaddress", sessionObj.UR_Mail);
                        $$(elmTaskInfo).attr("datereceived", new Date().format('yyyy-MM-dd HH:mm:ss'));
                        break;
                    case "authorize"://전결 결재안함
                        $$(elmTaskInfo).attr("status", "completed");
                        $$(elmTaskInfo).attr("result", "skipped");
                        $$(elmTaskInfo).attr("kind", "skip");
                        $$(elmTaskInfo).remove("datereceived");
                        break;
                    case "consent": //합의 -> 후열
                    case "charge":  //담당 -> 후열
                    case "consult":
                    case "normal":  //일반결재 -> 후열
                        $$(elmTaskInfo).attr("status", "inactive");
                        $$(elmTaskInfo).attr("result", "inactive");
                        $$(elmTaskInfo).attr("kind", "bypass");
                        $$(elmTaskInfo).remove("datereceived");
                        break;
                }
                if (skind == "authorize" || skind == "normal" || skind == "consent" || skind == "charge" || skind == "consult") {
                    var oStep = {};
                    var oOU = {};
                    var oPerson = {};
                    var oTaskinfo = {};

                    $$(oStep).attr("unittype", "person");
                    $$(oStep).attr("routetype", "approve");
                    $$(oStep).attr("name", Common.getDic("lbl_apv_ChargeDept"));
                    
                    $$(oOU).attr("code", getInfo("AppInfo.dpid_apv"));
                    $$(oOU).attr("name", getInfo("AppInfo.dpdn_apv"));
                    
                    $$(oOU).attr("taskid", (tempOu ? tempOu.find("ou").attr("taskid") : $$(oCurrentOUNode).find("step>ou").attr("taskid")));
					$$(oOU).attr("widescid", (tempOu ? tempOu.find("ou").attr("widescid") : $$(oCurrentOUNode).find("step>ou").attr("widescid")));
					$$(oOU).attr("wiid", (tempOu ? tempOu.find("ou").attr("wiid") : $$(oCurrentOUNode).find("step>ou").attr("wiid")));
                 
                    
                    $$(oTaskinfo).attr("status", "pending");
                    $$(oTaskinfo).attr("result", "pending");
                    $$(oTaskinfo).attr("kind", (skind == "authorize" || isChkDeputy) ? skind : "substitute");
                    $$(oTaskinfo).attr("datereceived", new Date().format('yyyy-MM-dd HH:mm:ss'));
                    
                    $$(oPerson).attr("code", sessionObj["USERID"]);
                    $$(oPerson).attr("name", sessionObj["UR_MultiName"]);
                    $$(oPerson).attr("position", sessionObj["UR_JobPositionCode"] + ";" + sessionObj["UR_MultiJobPositionName"]);
                    $$(oPerson).attr("title", sessionObj["UR_JobTitleCode"] + ";" + sessionObj["UR_MultiJobTitleName"]);
                    $$(oPerson).attr("level", sessionObj["UR_JobLevelCode"] + ";" + sessionObj["UR_MultiJobLevelName"]);
                    $$(oPerson).attr("oucode", sessionObj["DEPTID"]);
                    $$(oPerson).attr("ouname", sessionObj["GR_MultiName"]);
                    $$(oPerson).attr("sipaddress", sessionObj.UR_Mail);
                    
                    $$(oPerson).append("taskinfo", oTaskinfo);
                    
                    $$(oOU).append("person", oPerson);
                    
                    $$(oStep).append("ou", oOU);
                    
                    if(!isChkDeputy){
	                    $$(elmOU).append("person", oPerson);							// person이 object일 경우를 위해서 추가하여 배열로 만듬
	                    $$(elmOU).find("person").json().splice(0, 0, oPerson);			// 다시 앞에 추가
	                    $$(elmOU).find("person").concat().eq($$(elmOU).find("person").concat().length-1).remove();			// 배열로 만들기 위해서 추가했던 person을 지움
                    }else{
                    	$$(oCurrentOUNode).append("step", oStep);
                  		$$(oCurrentOUNode).find("step").concat().eq(0).remove();
                    }
                    
                    //담당 수신자 대결 S ---------------------------------------------
                    if (isChkDeputy) {
                    	Common.Warning(Common.getDic("msg_ApprovalDeputyWarning"));

                        var objOriginalApprover = $$(oChargeNode).find('ou').find("person");
                        $$(objOriginalApprover).attr('title', $$(objOriginalApprover).attr('title'));
                        $$(objOriginalApprover).attr('level', $$(objOriginalApprover).attr('level'));
                        $$(objOriginalApprover).attr('position', $$(objOriginalApprover).attr('position'));

                        $$(objOriginalApprover).find('taskinfo').remove('datereceived');
                        $$(objOriginalApprover).find('taskinfo').attr('kind', 'bypass');
                        $$(objOriginalApprover).find('taskinfo').attr('result', 'inactive');
                        $$(objOriginalApprover).find('taskinfo').attr('status', 'inactive');

                        $$(oChargeNode).attr("routetype", "approve");
                        $$(oChargeNode).attr("name", "원결재자");
                    	$$(oCurrentOUNode).append("step", $$(oChargeNode).json());
                    }
                    //담당 수신자 대결 E ----------------------------------------------
                    
                    if (skind == 'charge' && !isChkDeputy) {
                        oFirstNode = oStep;
                        
                        var oStep = {};
                        var oOU = {};
                        var oPerson = {};
                        var oTaskinfo = {};
                        
                        $$(oStep).attr("unittype", "person");
                        $$(oStep).attr("routetype", "approve");
                        $$(oStep).attr("name", Common.getDic("lbl_apv_writer"));		//gLabel__writer);
                        
                        $$(oOU).attr("code", sessionObj["ApprovalParentGR_Code"]);
                        $$(oOU).attr("name", sessionObj["ApprovalParentGR_Name"]);
                        
                        $$(oPerson).attr("code", sessionObj["USERID"]);
                        $$(oPerson).attr("name", sessionObj["UR_MultiName"]);
                        $$(oPerson).attr("position", sessionObj["UR_JobPositionCode"] + ";" + sessionObj["UR_MultiJobPositionName"]);
                        $$(oPerson).attr("title", sessionObj["UR_JobTitleCode"] + ";" + sessionObj["UR_MultiJobTitleName"]);
                        $$(oPerson).attr("level", sessionObj["UR_JobLevelCode"] + ";" + sessionObj["UR_MultiJobLevelName"]);
                        $$(oPerson).attr("oucode", sessionObj["DEPTID"]);
                        $$(oPerson).attr("ouname", sessionObj["GR_MultiName"]);
                        $$(oPerson).attr("sipaddress", sessionObj.UR_Mail);
                        
                        $$(oTaskinfo).attr("status", "complete");
                        $$(oTaskinfo).attr("result", "complete");
                        $$(oTaskinfo).attr("kind", "charge");
                        $$(oTaskinfo).attr("datereceived", new Date().format('yyyy-MM-dd HH:mm:ss'));
                        $$(oTaskinfo).attr("datecompleted", new Date().format('yyyy-MM-dd HH:mm:ss'));
                        
                        $$(oPerson).append("taskinfo", oTaskinfo);
                        
                        $$(oOU).append("person", oPerson);
                        
                        $$(oStep).append("ou", oOU);
                        
                        $$(jsonApv).find("steps>division").append("step", oStep);
                        $$(jsonApv).find("steps>division>step").json().splice(0, 0, oStep);
                        $$(jsonApv).find("steps>division>step").concat().eq($$(jsonApv).find("steps>division>step").concat().length-1).remove();
                        
                        //$$(jsonApv).find("steps>division").insertBefore(oStep, elmStep);
                    }
                }

                var oResult = $$(jsonApv).json();
                return JSON.stringify(oResult);
            }
            else {
            	return arrDomainDataList[processID];
            }
        }
        else {
        	return arrDomainDataList[processID];
        }
    }
    catch (e) {
        alert(e.message);
    }
}


/**
 * 회람지정 (20210126 이관함 기능 추가)
 * @param gridObj
 */
function ListCirculation(gridObj){
	strPiid_List = "";
	strWiid_List = "";
	strFiid_List = "";
	
	var str_mode = g_mode.toUpperCase();
	
	// 이관문서는 양식별 일괄확인 여부 필요 없음
//		var excludeItem = false;
//		$.each(gridObj.getCheckedListWithIndex(1), function(idx,obj){
//			if(typeof obj.item.ExtInfo == 'undefined'  || obj.item.ExtInfo.UseBlocCheck != 'Y'){
//				excludeItem = true;
//				gridObj.checkedColSeq(1,false,obj.index);
//			}
//		});
	
	var msgWarning = '';
	msgWarning += Common.getDic("msg_apv_003"); //선택된 항목이 없습니다.
	
	// 체크된 항목 확인
	var checkCheckList = gridObj.getCheckedList(1);
	if(checkCheckList.length == 0){
		Common.Warning(msgWarning);
	}else if(checkCheckList.length > 0){
		// 양식 오픈
		for(var i = 0; i < checkCheckList.length; i++){
			//if(mnid_chk == "477" || mnid_chk == "478" || mnid_chk == "479" || mnid_chk == "483"){
			if(str_mode == "PREAPPROVAL" || str_mode == "APPROVAL" || str_mode == "PROCESS" || str_mode == "TCINFO" || str_mode == "DEPTTCINFO"){
				strPiid_List += checkCheckList[i].ProcessID == "undefined" || checkCheckList[i].ProcessID == undefined ? ";" : checkCheckList[i].ProcessID + ";";
				strWiid_List += checkCheckList[i].WorkItemID == "undefined" || checkCheckList[i].WorkItemID == undefined ? ";" : checkCheckList[i].WorkItemID + ";";
			}else{
				strPiid_List += checkCheckList[i].ProcessArchiveID == "undefined" || checkCheckList[i].ProcessArchiveID == undefined ? ";" : checkCheckList[i].ProcessArchiveID + ";";
				strWiid_List += checkCheckList[i].WorkitemArchiveID == "undefined" || checkCheckList[i].WorkitemArchiveID == undefined ? ";" : checkCheckList[i].WorkitemArchiveID + ";";
			}

			strFiid_List += checkCheckList[i].FormInstID == "undefined" || checkCheckList[i].FormInstID == undefined ? ";" : checkCheckList[i].FormInstID + ";";
		}
		
		// 목록에서 선택한 항목이 하나일 경우 ID를 붙여주고 여러개일경우 ID를 비우고 참조/회람함을 연다.
		var ProcessID = strPiid_List.split(";").length == 2 ? strPiid_List.split(";")[0] : "";
		var WorkItemID = strWiid_List.split(";").length == 2 ? strWiid_List.split(";")[0] : "";
		var FormInstID = strFiid_List.split(";").length == 2 ? strFiid_List.split(";")[0] : "";
		g_CirculationFiid = strFiid_List;
		g_CirculationPiid = strPiid_List;
		g_CirculationWiid = strWiid_List;
		strPiid_List = "";

		var width = 1000;
		var height = 580;
		var url = "../goCirculationMgrListpage.do?piid=" + ProcessID + "&fiid=" + FormInstID
				+ "&openDo=Circulate&openType=C&pState=528"
				+ "&bstored=true&callType=List";
		
		CFN_OpenWindow(url, "", width, height, "fix");
	}else{
		Common.Error(Common.getDic("msg_ScriptApprovalError"));			// 오류 발생
	}
}

// 프로필 사진 경로 가져오기
function getProfileImagePath(userCodes){
	var returnObj = new Array();
	
	if(userCodes.split(";").length > 0){
		$.ajax({
			url:"/approval/user/getProfileImagePath.do",
			data: {
				"UserCodes" : userCodes
			},
			type:"post",
			dataType : 'json',
			async : false,
			success:function (res) {
				if(res.data) {
					//dgkim 2021.01.11
					//phothPath default Set		
					returnObj = res.data.map( function(item){
						var _path = item.PhotoPath.replace(/\s/g,"").length > 0 ?  "/covicore/common/photo/photo.do?img="+item.PhotoPath : "/covicore/resources/images/no_profile.png";
						return { UserCode : item.UserCode, PhotoPath : _path } 
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getProfileImagePath.do", response, status, error);
			}
		});	
	}
	
	return returnObj;
}

/*
개인결재함
미결함, 진행함 - 전체 개수
*/
function setDocreadCount(listType) {
	setDocReadCountAll(listType); // 카운트 조회시 서버요청 1번만 하도록 변경
}

function setDocReadCountAll(listType){
	if(!listType) listType = "";
	
	$.ajax({
		url: "/approval/user/getApprovalCntAll.do",
		type:"post",
		data:{
			businessData1 : "APPROVAL",
			listType : listType
		},
		success:function (data) {
			if(data.status == "SUCCESS" && data.list && data.list.length > 0) {
				for(var boxInfo of data.list){
					var boxAlias = boxInfo.type;
					var boxCnt = boxInfo.cnt;
					if(boxAlias && boxInfo.cnt != undefined){
						if(boxAlias.indexOf("U_") > -1){
							$("[data-menu-alias=ApprovalUser]").each(function(){
								if(boxAlias.substring(2) == decodeURIComponent($(this).attr("data-menu-url")).split("&mode=")[1]){
									$(this).find("a>span>span").remove();
									var menuName = $(this).find("a>span").text();
									$(this).find("a>span").html(menuName + "<span class='fCol19abd8'>&nbsp;"+boxCnt+"</span>");
									// 좌측 퀵 메뉴 영역의 count도 변경되도록 처리 (2019.06.14)
									if(boxAlias == "U_Approval") {
										if(boxCnt > 0) {
											$("#quickCnt_Approval").addClass("ui_badge");
											$("#quickCnt_Approval").text(boxCnt);
										} else {
											$("#quickCnt_Approval").removeClass("ui_badge");
											$("#quickCnt_Approval").text("");
										}
										$("#ApprovalCnt").html(boxCnt);
									}else if(boxAlias == "U_Process"){
										$("#ProcessCnt").html(boxCnt);
									}
								}
							});
						}else if(boxAlias.indexOf("D_") > -1){
							$("[data-menu-alias=ApprovalDept]").each(function(){
								if(boxAlias.substring(2) == decodeURIComponent($(this).attr("data-menu-url")).split("&mode=")[1]){
									$(this).find("a>span>span").remove();
									var menuName = $(this).find("a>span").text();
									$(this).find("a>span").html(menuName + "<span class='fCol19abd8'>&nbsp;"+boxCnt+"</span>");
								}
							});
						}
					}	
				}
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("getApprovalCntAll.do", response, status, error);
		}
	});
}

function setDocReadCount_User(){
	var getConfig = Common.getBaseConfig("ApprovalBoxListCnt");
	var strApprovalCntConfig = getConfig == "" ? "U_Approval;U_Process" : getConfig;
	var arrBoxlistCon = strApprovalCntConfig.split(';').filter(function (item) {
		if(item.indexOf('U_') > -1){ return item;}
	});

	var strurl = "";
	for(i = 0; i < arrBoxlistCon.length; i++){
		switch (arrBoxlistCon[i]) {
        	case "U_Approval": 
        		strurl = "/approval/user/getApprovalCnt.do";
        		break;
        	case "U_Process": 
        		strurl = "/approval/user/getProcessCnt.do";
        		break;
        	case "U_TCInfo":
        		strurl = "/approval/user/getTCInfoNotDocReadCnt.do";
        		break;
        	default:
        		strurl = "/approval/user/getUserBoxListCnt.do";
        		break;
		}
		
		(function(i) {
			$.ajax({
				url: strurl,
				type:"post",
				data:{
					businessData1 : "APPROVAL",
					listGubun : arrBoxlistCon[i]
				},
				success:function (data) {
					if(data.status == "SUCCESS") {
						//메소드 호출마다 갱신되도록 수정
						approvalCnt = data.cnt;
						
						$("[data-menu-alias=ApprovalUser]").each(function(){
							if(arrBoxlistCon[i].substring(2) == decodeURIComponent($(this).attr("data-menu-url")).split("&mode=")[1]){
								$(this).find("a>span>span").remove();
								var menuName = $(this).find("a>span").text();
								$(this).find("a>span").html(menuName + "<span class='fCol19abd8'>&nbsp;"+approvalCnt+"</span>");
								// 좌측 퀵 메뉴 영역의 count도 변경되도록 처리 (2019.06.14)
								if(arrBoxlistCon[i] == "U_Approval") {
									$("#quickCnt_Approval").html(approvalCnt);
								}
							}
						});
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax(strurl, response, status, error);
				}
			});
		})(i);
	}
}
function setDocReadCount_Dept(){
	var getConfig = Common.getBaseConfig("ApprovalBoxListCnt");
	var strApprovalCntConfig = getConfig == "" ? "D_Receive;D_DeptProcess" : getConfig;
	var arrBoxlistCon = strApprovalCntConfig.split(';').filter(function (item) {
		if(item.indexOf('D_') > -1){ return item;}
	});

	var strurl = "";
	for(i = 0; i < arrBoxlistCon.length; i++){
		switch (arrBoxlistCon[i]) {
        	case "D_Receive": 
        		strurl = "/approval/user/getDeptReceptionCnt.do";
        		break;
        	case "D_DeptProcess": 
        		strurl = "/approval/user/getDeptProcessCnt.do";
        		break;
        	case "D_DeptTCInfo":
        		strurl = "/approval/user/getDeptTCInfoNotDocReadCnt.do";
        		break;
        	default:
        		strurl = "/approval/user/getDeptBoxListCnt.do";
        		break;
		}
		
		(function(i) {
			$.ajax({
				url: strurl,
				type:"post",
				data:{
					listGubun : arrBoxlistCon[i]
				},
				success:function (data) {
					if(data.status == "SUCCESS") {
						//메소드 호출마다 갱신되도록 수정
						approvalCnt = data.cnt;
						
						$("[data-menu-alias=ApprovalDept]").each(function(){
							if(arrBoxlistCon[i].substring(2) == decodeURIComponent($(this).attr("data-menu-url")).split("&mode=")[1]){
								$(this).find("a>span>span").remove();
								var menuName = $(this).find("a>span").text();
								$(this).find("a>span").html(menuName + "<span class='fCol19abd8'>&nbsp;"+approvalCnt+"</span>");
							}
						});
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax(strurl, response, status, error);
				}
			});
		})(i);
	}
}

// 2022-11-10 FlowerName 설정
function setUserFlowerName(id, name, type) {
	let func = '';
	// 객체를 받아온 경우 추가적으로 css 수정. (쓰이는 곳에 따라 상위/하위 css 수정해야 하는 경우가 있음)
	if (type) {
		func = 'setUserFlowerNameAddEtc(this, \'' + type + '\');';
	}
	const rtn = '<span class="btnFlowerName" onclick="coviCtrl.setFlowerName(this); ' + func + '" style="position:relative;cursor:pointer;" data-user-code="'+ id +'" data-user-mail="" >' + name + '</span>';
	return rtn;
}

// 추가적인 처리
function setUserFlowerNameAddEtc(obj, type) {
	if (type == 'flowerPos') {
		// 결재목록에서 결재상세 정보 그래픽 영역 첫번째 요소일때 처리. (앞에 짤리는 현상있어서 flowerPos css 추가시킴)
		if ($(obj).closest('li.step').prevAll().length == 0 && !$(obj).find('ul.flowerMenuList').hasClass(type)) {
			$(obj).find('ul.flowerMenuList').addClass(type);
		}
	} else if (type == 'AXGrid') {
		// 결재목록에서 AXGrid 기능을 적용한 목록들 처리
		if ($.trim($(obj).closest('div').css('overflow')) != 'visible') {
			$(obj).closest('div').css('overflow', 'visible');
		}
	} else if (type == 'upTdOverflow') {
		// 상위 TD 객체 overflow: visible 처리
		if ($.trim($(obj).closest('td').css('overflow')) != 'visible') {
			$(obj).closest('td').css('overflow', 'visible');
		}
	}
}

$(document).ready(function(){
	// [2021-08-24 add] ie에서 노드 배열에 관해 forEach 메소드 지원하지 않아 추가 
	if (window.NodeList && !NodeList.prototype.forEach) {
		NodeList.prototype.forEach = Array.prototype.forEach;
	}
});

//null값 공백 반환
function nullToBlank(val) {
	var retVal = "";
	
	if(!isEmptyStr(val)){
		retVal = val
	}
	
	return retVal
}

//문자열 공백 체크
function isEmptyStr(str){
	if(str == null){
		return true;
	}
	if(str.toString == null){
		return true;
	}	
	
	var getStr = str.toString();
	if(getStr == null){
		return true;
	}
	if(getStr != ""
		&& getStr != null
		&& !getStr.isBlank()){
		return false;
	}
	return true;
}