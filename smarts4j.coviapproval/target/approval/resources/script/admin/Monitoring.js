function getInfo(sKey) {
	try {
		sKey = "$." + sKey;
		
		var isExitJsonValue = jsonPath(formJson, sKey).length == undefined ? false : true;
		var formJsonValue = isExitJsonValue ? jsonPath(formJson, sKey)[0] : jsonPath(formJson, sKey);

	if (formJsonValue === false && isExitJsonValue === false) {
		return undefined;
	} else if (formJsonValue.constructor === "".constructor) {
		return formJsonValue;
	} else if (formJsonValue.constructor === [].constructor
		|| formJsonValue.constructor === {}.constructor
		|| formJsonValue.constructor === true.constructor) {
		return JSON.stringify(formJsonValue);
	} else {
		return undefined;
	}
	} catch (e) {
		return undefined;
	}
}

// 이후 결재자 변경
function changeAfterApvLine(){
	$("#APVLIST").val(g_domainData);
	CFN_OpenWindow("/approval/approvalline.do", "", 1110, 580, "fix");
}

// 결재선 변경 Update
function goBatchApvLine(typeStr, isNotChgStep){	
	var apvLine = $("#APVLIST").val();
	var apvLineObj = $.parseJSON(apvLine);
	var sUSID = $$(apvLineObj).find($("#hidDPath").val()).attr("code");
	
	var taskID = $$(apvLineObj).find("division").find("step").concat().find("ou").has("[code="+sUSID+"],person[code="+sUSID+"]").has("taskinfo[result=pending],[result=reserved]").attr("taskid");
	if(taskID == null || taskID == "") {
		taskID = $$(apvLineObj).find("division").find("step").concat().find("ou").has("taskinfo[result=pending],[result=reserved]").attr("taskid");
	}		
	
	if($$(apvLineObj).find($("#hidDPath").val()).parent().parent().attr("unittype")=="ou"
		&&	($$(apvLineObj).find($("#hidDPath").val()).parent().parent().attr("routetype") == "assist"
		|| $$(apvLineObj).find($("#hidDPath").val()).parent().parent().attr("routetype") =="consult")){
		taskID = $$(apvLineObj).find($("#hidDPath").val()).attr("taskid");
	}
	var comment = $("#comment").val().trim();
	$.ajax({
		url:"setDomainListData.do",
		type:"post",
		data: {
			"ProcessID": g_ProcessID,
			"FormInstID": g_FormInstID,
			"taskID" : taskID,
			"DomainDataContext" : apvLine,
			"Comment" : comment
		},
		async:false,
		success:function (data) {
			if(data.status == "SUCCESS"){
				if(isNotChgStep){
					parent.Common.Inform(Common.getDic("msg_apv_alert_006"), "Information", function(){
						location.reload();
					});
				}else{
					//결재 step 변경
					var apvLineObj = $.parseJSON(apvLine);
					var processID = $$(apvLineObj).find("division").find("step").concat().has("taskinfo[result=pending],[result=reserved]").parent().attr("processID");
					var stepTotalCount = $$(apvLineObj).find("division").find("step").concat().length;
					setProcessStep(processID, stepTotalCount);
				}
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("setDomainListData.do", response, status, error);
		}
	});
}

//결재 step 변경
function setProcessStep(processID, stepTotalCount){
	$.ajax({
		url:"setProcessStep.do",
		type:"post",
		data: {
			"ProcessID": processID,
			"stepTotalCount":stepTotalCount
		},
		async:false,
		success:function (data) {
			if(data.status == "SUCCESS"){
				parent.Common.Inform(Common.getDic("msg_apv_alert_006"), "Information", function(){
					location.reload();
				});
			}else{
				parent.Common.Error(Common.getDic("msg_apv_030"), "Error", function(){
					location.reload();
				});
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("setProcessStep.do", response, status, error);
		}
	});
}


// 현 결재자 변경
function changeNowApvLine(){
	_CallBackMethod2 = doChangeNowApvLine;
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B1",Common.getDic("lbl_apv_org"),1060,580,"");
}

// 추가발송
function addReceipt(){
	// 조직도 띄우기
	_CallBackMethod2 = doAddReceipt;
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=D9",Common.getDic("lbl_apv_org"),1060,580,"");
}

// 수신처 삭제
function deleteReceipt(){
	Common.Confirm("ProcessID: " + g_selectedProcessID + "를 발송취소(546) 처리하시겠습니까?", "Confirmation Dialog", function (result) {
		if (result) {
			var dataInfo = {};
			var items = new Array();
			var item = {};
			item.wiid = ""; // 관리자에서 삭제 시에는 process만 546으로 update함.
			item.piid = g_selectedProcessID;

			items.push(item);
			dataInfo.item = items;
			
			$.ajax({
				type:"POST",
				url : "/approval/legacy/deleteDistribution.do",
				data : {
					"Items": JSON.stringify(dataInfo)
				},
				dataType: "json", // 데이터타입을 JSON형식으로 지정
				success:function(res){
					if(res.result == 'ok'){
						Common.Inform(Common.getDic("msg_apv_alert_006"));		//성공적으로 처리 되었습니다.
						setTimeout("document.location.reload()", 1000);
					} else {
						Common.Error(res.message);
					}	
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/legacy/deleteDistribution.do", response, status, error);
				}
			});
		}
	});
}

function doChangeNowApvLine(dataObj) {
    //전달
    var sChargeId = ""
    var sChargeName = ""

    sChargeId = $$(dataObj).find("item").concat().attr("AN");
    sChargeName = $$(dataObj).find("item").concat().attr("DN");
    
    var apvLineObj = $.parseJSON($("#APVLIST").val());
    var sUSID = $$(apvLineObj).find($("#hidDPath").val()).attr("code");

    var itemType = $$(dataObj).find("item").concat().attr("itemType");

    var confirmMessage = CFN_GetDicInfo(sChargeName) + " 사용자로 지정 하겠습니까?";// + Common.getDic("msg_apv_ChargeConfirm");
    Common.Confirm(confirmMessage, "Confirmation Dialog", function (result) {
        if (result) {
        	try{
				if(setForwardApvList(dataObj, sUSID, apvLineObj, itemType)){
		        	// workitem 및 performer 데이터 변경
	        		var workitemID;
	        		var processID;
	        		if(itemType == "user"){
	        			workitemID = $$(apvLineObj).find($("#hidDPath").val()).parent().attr("wiid");
	        			processID = $$(apvLineObj).find($("#hidDPath").val()).parent().parent().parent().attr("processID");
	        			
	        			if($$(apvLineObj).find($("#hidDPath").val()).parent().parent().attr("unittype")=="ou"
	        			  && ($$(apvLineObj).find($("#hidDPath").val()).parent().parent().attr("routetype") == "assist"
	              		  || $$(apvLineObj).find($("#hidDPath").val()).parent().parent().attr("routetype") =="consult")){
	                  		workitemID = $$(apvLineObj).find($("#hidDPath").val()).attr("wiid");
	                  		processID = $$(apvLineObj).find($("#hidDPath").val()).parent().attr("taskinfo").piid;	
	              		}
	        			
	        		}else{
	        			workitemID = $$(apvLineObj).find($("#hidDPath").val()).attr("wiid");
	        			processID = $$(apvLineObj).find($("#hidDPath").val()).parent().parent().attr("processID");
	        		}
	        		
		        	changeWorkitemData(workitemID, sChargeId, sChargeName);
		        	
		        	// description 의 현결재자 변경
		        	changeDescription(processID, sChargeId, sChargeName);
		        	
		        	// 결재선 변경
		        	goBatchApvLine();
				}else{
					Common.Error(Common.getDic("msg_apv_030") + "\r\n" + Common.getDic("msg_apv_003")); // 오류가 발생했습니다. 선택된 항목이 없습니다. 
				}
        	}catch(e){
        		Common.Error("Error : "+e.message);
        	}
        }
    });
}

// 전달 결재선 수정
function setForwardApvList(elmRoot, sUSID, apvLineObj, itemType) {
	var bModify = false;
    try {
    	
    	if(itemType == "user"){
    		var oFirstNode = $$(apvLineObj).find("division").has(">taskinfo[status='pending']").concat().find(
					"step[routetype='approve']>ou"
					+ ",step[routetype='consult']>ou"
					+ ",step[routetype='assist']>ou"
					+ ",step[routetype='receive']>ou").concat().find(">person[code='" + sUSID + "']").concat().find(">taskinfo[status='pending']");
			
			if(oFirstNode.length > 1){
				var sUnitType = $$(apvLineObj).find($("#hidDPath").val()).closest("step").attr("unittype");
				var sWIID = "";
				if(sUnitType == "ou"){
					sWIID = $$(apvLineObj).find($("#hidDPath").val()).attr("wiid");
					oFirstNode = $$(apvLineObj).find("division").has(">taskinfo[status='pending']").concat().find(
						"step[routetype='approve']>ou"
						+ ",step[routetype='consult']>ou"
						+ ",step[routetype='assist']>ou"
						+ ",step[routetype='receive']>ou").concat().find(">person[code='" + sUSID + "'][wiid='" + sWIID + "']").concat().find(">taskinfo[status='pending']");
				}else{ // person
					sWIID = $$(apvLineObj).find($("#hidDPath").val()).parent().attr("wiid");
					oFirstNode = $$(apvLineObj).find("division").has(">taskinfo[status='pending']").concat().find(
						"step[routetype='approve']>ou[wiid='" + sWIID + "']"
						+ ",step[routetype='consult']>ou[wiid='" + sWIID + "']"
						+ ",step[routetype='assist']>ou[wiid='" + sWIID + "']"
						+ ",step[routetype='receive']>ou[wiid='" + sWIID + "']").concat().find(">person[code='" + sUSID + "']").concat().find(">taskinfo[status='pending']");
				}
			} 
			if (oFirstNode.length == 0){
				var oFirstNode = $$(apvLineObj).find("division").has(">taskinfo[status='pending']").concat().find(
					"step[routetype='approve']>ou").concat().find(">role").has("person[code='" + sUSID + "'])").concat().find(">taskinfo[status='pending']");
			}
			
	        if (oFirstNode.length > 0) {
	            $$(oFirstNode).parent().attr("code", $$(elmRoot).find("item").concat().attr("AN"));
	            $$(oFirstNode).parent().attr("name", $$(elmRoot).find("item").concat().attr("DN"));
	            $$(oFirstNode).parent().attr("position", $$(elmRoot).find("item").concat().attr("po"));
	            $$(oFirstNode).parent().attr("title", $$(elmRoot).find("item").concat().attr("tl"));
	            $$(oFirstNode).parent().attr("level", $$(elmRoot).find("item").concat().attr("lv"));
	            $$(oFirstNode).parent().attr("oucode", $$(elmRoot).find("item").concat().attr("RG"));
	            $$(oFirstNode).parent().attr("ouname", $$(elmRoot).find("item").concat().attr("RGNM"));
	            $$(oFirstNode).parent().attr("sipaddress", $$(elmRoot).find("item").concat().attr("SIP"));
	            
	            $("#APVLIST").val(JSON.stringify(apvLineObj));
				bModify = true;
	        }
    	}else{
    		var oFirstNode = $$(apvLineObj).find($("#hidDPath").val());
			                    
			if (oFirstNode.length > 0) {
				$$(oFirstNode).attr("code", $$(elmRoot).find("item").concat().attr("AN"));
				$$(oFirstNode).attr("name", $$(elmRoot).find("item").concat().attr("DN"));
				$$(oFirstNode).parent().parent().attr("oucode", $$(elmRoot).find("item").concat().attr("AN"));
				$$(oFirstNode).parent().parent().attr("ouname", $$(elmRoot).find("item").concat().attr("DN"));
				
				$("#APVLIST").val(JSON.stringify(apvLineObj));
				bModify = true;
			}
    	}
    } catch (e) { Common.Error("Error : "+ e.message); }

	return bModify;
}

//Workitem 데이터 수정
function changeWorkitemData(workitemID, chargeId, chargeName){
	$.ajax({
		url:"setWorkitemData.do",
		type:"post",
		data: {
			"WorkitemID": workitemID,
			"chargeId" : chargeId,
			"chargeName" : chargeName
		},
		async:false,
		success:function (data) {
			if(data.status == "SUCCESS"){
			}else{
				throw true;
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("setWorkitemData.do", response, status, error);
		}
	});
}

//Description 데이터 수정
function changeDescription(processID, chargeCode, chargeName){
	$.ajax({
		url:"setDescriptionData.do",
		type:"post",
		data: {
			"ProcessID": processID,
			"chargeName" : chargeName,
			"chargeCode" : chargeCode
		},
		async:false,
		success:function (data) {
			if(data.status == "SUCCESS"){
			}else{
				throw true;
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("setDescriptionData.do", response, status, error);
		}
	});
}

function doAddReceipt(dataObj) {
    var confirmMessage = "선택한 사용자/부서에게 추가발송 하시겠습니까?";
    Common.Confirm(confirmMessage, "Confirmation Dialog", function (result) {
        if (result) {
        	try{
        		var bExec=false;
        		
        		var dataInfo = {};
        		var dataArray_person = new Array();
        		var dataArray_ou = new Array();
        		
        		// 기안부서 결재선만 가져오기.
        		var sendApvList = JSON.parse(g_domainData);
        		var tmpSendDiv = $$(sendApvList).find("division[divisiontype='send']").json();
        		$$(sendApvList).find("division").remove();
        		$$(sendApvList).find("steps").attr("division", tmpSendDiv);
        		
        		// 사용자
        		$$(dataObj).find("item[itemType='user']").concat().each(function (i, obj) {
    				var userInfo = {};
    				userInfo.code = $$(obj).attr("AN");
    				userInfo.name = $$(obj).attr("DN");
    				userInfo.oucode = $$(obj).attr("RG");
    				userInfo.type = "1";
    				userInfo.status = "inactive";
    				
    				dataArray_person.push(userInfo);
    				
    				bExec = true;
        		});
        		if(bExec) {
	        		dataInfo.type = "1";
	        		dataInfo.receiptList = dataArray_person;
	        		dataInfo.piid = g_ProcessID;
	        		dataInfo.docNumber = g_docNo;
	        		dataInfo.context = getFormInfo();
	        		dataInfo.approvalLine = JSON.stringify(sendApvList);
	        		
	        		callDistribution(dataInfo);
	        		
	        		bExec = false;
        		}
        		
        		// 부서
        		dataInfo = {};
        		$$(dataObj).find("item[itemType='group']").concat().each(function (i, obj) {
    				var deptInfo = {};
    				deptInfo.code = $$(obj).attr("AN");
    				deptInfo.name = $$(obj).attr("DN");
    				deptInfo.type = "0";
    				deptInfo.status = "inactive";
    				
    				dataArray_ou.push(deptInfo);
    				
    				bExec = true;
        		});
        		if(bExec) {
	        		dataInfo.type = "0";
	        		dataInfo.receiptList = dataArray_ou;
	        		dataInfo.piid = g_ProcessID;
	        		dataInfo.docNumber = g_docNo;
	        		dataInfo.context = getFormInfo();
	        		dataInfo.approvalLine = JSON.stringify(sendApvList);
	        		
	        		callDistribution(dataInfo);
        		}
        	}catch(e){
        		Common.Error("Error : "+e.message);
        	}
        }
    });
}

function callDistribution(dataInfo) {
	$.ajax({
		type:"POST",
		url : "/approval/legacy/startDistribution.do",
		data : {
			"DistributionInfo": JSON.stringify(dataInfo)
		},
		dataType: "json", // 데이터타입을 JSON형식으로 지정
		success:function(res){
			if(res.status == 'SUCCESS'){
				Common.Inform(Common.getDic("msg_apv_alert_006"));		//성공적으로 처리 되었습니다.
				location.reload();
			} else {
				Common.Error(res.message);
			}	
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/legacy/startDistribution.do", response, status, error);
		}
	});
}

function getFormInfo() {
	var pFormInstID = (typeof g_FormInstID == "undefined" ? opener.g_FormInstID : g_FormInstID);
	var retData;
	
	$.ajax({
		type:"POST",
		url : "doGetFormInfo.do",
		async: false,
		data : {
			"FormInstID": pFormInstID
		},
		dataType: "json", // 데이터타입을 JSON형식으로 지정
		success:function(res){
			if(res.status == 'SUCCESS'){
				retData = res.data;
			} else {
				Common.Error(res.message);
			}	
		},
		error:function(response, status, error){
			CFN_ErrorAjax("doGetFormInfo.do", response, status, error);
		}
	});
	
	return retData;
}

// 수동 결재하기
function approveByAdmin(){
	CFN_OpenWindow("monitoringApprovalPopup.do", "", 550, 410, "fix");
}

// 회수
function withdrawByAdmin(){
	Common.Confirm(Common.getDic("msg_apv_391"), "Confirmation Dialog", function (result) {
        if (result) {
        	var apvLineObj = $.parseJSON($("#APVLIST").val());
        	
        	var person = $$(apvLineObj).find($("#hidDPath").val());
        	var taskID = $$(person).parent().attr("taskid");
        	
        	var apiData = {};
            $$(apiData).append("g_action_"+taskID, "WITHDRAW");
            $$(apiData).append("g_actioncomment_"+taskID, "");
            $$(apiData).append("g_actioncomment_attach_"+taskID, []);
            $$(apiData).append("g_signimage_"+taskID, "");
            $$(apiData).append("g_isMobile_"+taskID, "N");
            $$(apiData).append("g_isBatch_"+taskID, "N");
            
            // 임시함에 저장될 문서 결재선 변경하기 위해 사용함.
            $$(apiData).append("g_appvLine", getApvList($("#APVLIST").val()));
            
        	callRestAPI(taskID, apiData);
        }
        else {
            return;
        }
    });
}

//기안취소 등 의견만 입력하고 행위처리
function approvalByAdminComment(pMode){
	CFN_OpenWindow("monitoringApprovalOnlyCommentPopup.do?mode=" + pMode, "", 550, 310, "fix");
}

// 담당자 변경
function changeChargePerson(){
	_CallBackMethod2 = doChangeNowApvLine;
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B1",Common.getDic("lbl_apv_org"),1060,580,"");
}

// 수신부서 변경
function changeReceiptDept(){
	_CallBackMethod2 = doChangeNowApvLine;
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=C1",Common.getDic("lbl_apv_org"),1060,580,"");
}

// 강제 합의
function consentByAdmin(){
	CFN_OpenWindow("monitoringApprovalPopup.do?mode=SubDept", "", 550, 410, "fix");
}

function getSuperAdminData(){
	var result;
	$.ajax({
		url:"getSuperAdminData.do",
		type:"post",
		data: {
		},
		async:false,
		success:function (data) {
			if(data.status == "SUCCESS"){
				result = data.result;
			}else{
				throw true;
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("getSuperAdminData.do", response, status, error);
		}
	});
	
	return result;
}

// 엔진 호출하기
function callRestAPI(taskid, data){
	var pFormInstID = (typeof g_FormInstID == "undefined" ? opener.g_FormInstID : g_FormInstID);
	
	$.ajax({
	    url: "doaction.do",
	    type: "POST",
	    data: {
			"id" : taskid,
			"data" : JSON.stringify(data),
			"formInstID" : pFormInstID // 문서번호 update 위해 추가
		},
		dataType: "json",
	    success: function (res) {
	    	if(res.status == 'SUCCESS'){
	    		parent.Common.Inform(Common.getDic("msg_apv_alert_006"), "Information", function(){
	    			opener.location.reload();
	    			Common.Close();
	    		}); //성공하였습니다.
	    	} else if(res.status == 'FAIL'){
	    		Common.Error(res.message);
	    	}
	    },
	    error:function(response, status, error){
			CFN_ErrorAjax("doaction.do", response, status, error);
		}
	});
}

//프로필 사진 경로 가져오기
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
				returnObj = res.data;
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getProfileImagePath.do", response, status, error);
			}
		});	
	}
	
	return returnObj;
}

function getApvList(apvlist) {
	var jsonApv = $.parseJSON(apvlist);
	
    //결재선 임시 저장 관련 수정 - 기안자만 있는 경우 넘기지 결재선을 넘기지 않는다.
    // 회수 및 기안취소 포함
    var oFirstNodeList = $$(jsonApv).find("steps>division>step>ou>person");
    //기안자만 있는 경우 초기화  시키는데, 그럴경우 추가된 참조자도 사라짐.*/
    var oCurrentDivNode = $$(jsonApv).find("steps>division[divisiontype='send']");
    var oChargeNode = $$(oCurrentDivNode).find("step").has("ou>person>taskinfo[kind='charge']");
    
    if (oChargeNode.length != 0)
    	$$(oCurrentDivNode).find("step").has("ou>person>taskinfo[kind='charge']").concat().eq(0).remove();
    
    var oCurrentDivTaskinfo = $$(oCurrentDivNode).find("taskinfo");
    $$(oCurrentDivTaskinfo).attr("status", "inactive");
    $$(oCurrentDivTaskinfo).attr("result", "inactive");
    
    try { $$(oCurrentDivTaskinfo).remove("datereceived"); } catch (e) { coviCmn.traceLog(e); }
    try { $$(oCurrentDivTaskinfo).remove("datecompleted"); } catch (e) { coviCmn.traceLog(e); }
    try { $$(oCurrentDivTaskinfo).remove("customattribute1"); } catch (e) { coviCmn.traceLog(e); }
    try { $$(oCurrentDivTaskinfo).remove("wiid"); } catch (e) { coviCmn.traceLog(e); }
    try { $$(oCurrentDivTaskinfo).remove("mobileType"); } catch (e) { coviCmn.traceLog(e); }
    try { $$(oCurrentDivNode).find("step").concat().find("person").concat().find("taskinfo>comment").remove(); } catch (e) { coviCmn.traceLog(e); }
    
    $$(oCurrentDivNode).find("step").concat().each(function(i, elm){
    	if ($$(elm).attr("unittype") == "ou") {
            var oOU = $$(elm).find("ou");
            $$(oOU).concat().each(function (i, ouNode) {
                $$(ouNode).children().remove();
            	
                var newOuTaskinfo = {};
                
                if ($$(elm).attr("routetype") == "consult") { $$(newOuTaskinfo).attr("kind", "consult"); }
                else if ($$(elm).attr("routetype") == "assist") { $$(newOuTaskinfo).attr("kind", "assist"); }
                else { $$(newOuTaskinfo).attr("kind", "normal"); }

                $$(ouNode).append("taskinfo", newOuTaskinfo);
            });
            $$(elm).find("taskinfo").remove("datereceived");
        }
    	
    	var oOU = $$(elm).find("ou").concat();
    	
    	$$(oOU).concat().each(function(i, ouObj){
        	// 엔진에서 작성되는 값들 지우기
	        $$(ouObj).remove("pfid");
	        $$(ouObj).remove("taskid");
	        $$(ouObj).remove("widescid");
	        $$(ouObj).remove("wiid");
	
	        //division/step/ou/taskinfo
	        var oOUTaskinfo = $$(ouObj).find("taskinfo");
	        if ($$(oOUTaskinfo).length != 0) {
	            $$(oOUTaskinfo).attr("status", "inactive");
	            $$(oOUTaskinfo).attr("result", "inactive");
	            $(oOUTaskinfo).attr("datereceived", "");
	
	            if ($$(oOUTaskinfo).attr("datecompleted")) { $$(oOUTaskinfo).remove("datecompleted"); }
	            if ($$(oOUTaskinfo).attr("wiid")) { $$(oOUTaskinfo).remove("wiid"); }
	
	            if ($$(oOUTaskinfo).find("comment").concat().eq(0)) { $$(oOUTaskinfo).find("comment").remove(); }
	            if ($$(oOUTaskinfo).find("comment_fileinfo").concat().eq(0)) { $$(oOUTaskinfo).find("comment_fileinfo").remove(); }
	            
	            $$(oOUTaskinfo).remove("datereceived");
	        }
	        //division/step/person/taskinfo
	        var oPersonTaskinfo = $$(ouObj).find("person>taskinfo");
	        if ($$(oPersonTaskinfo).length != 0) {
	            $$(oPersonTaskinfo).attr("status", "inactive");
	            $$(oPersonTaskinfo).attr("result", "inactive");
	            if ($$(oPersonTaskinfo).attr("kind") == "charge") $$(oPersonTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
	            else $$(oPersonTaskinfo).attr("datereceived", "");
	            
	            if ($$(oPersonTaskinfo).attr("datecompleted")) { $$(oPersonTaskinfo).remove("datecompleted"); }
	            if ($$(oPersonTaskinfo).attr("wiid")) { $$(oPersonTaskinfo).remove("wiid"); }
	            if ($$(oPersonTaskinfo).attr("customattribute1")) { $$(oPersonTaskinfo).remove("customattribute1"); }
	            if ($$(oPersonTaskinfo).attr("mobileType")) { $$(oPersonTaskinfo).remove("mobileType"); }
	
	            if ($$(oPersonTaskinfo).find("comment").concat().eq(0).json()) { $$(oPersonTaskinfo).find("comment").remove(); }
	            if ($$(oPersonTaskinfo).find("comment_fileinfo").concat().eq(0).json()) { $$(oPersonTaskinfo).find("comment_fileinfo").remove(); }
	        }
    	});
    });
    
    //참조 셋팅
    var oCcinfo = $$(jsonApv).find("steps>ccinfo");
    try {
    	if(oCcinfo.exist()){
            $$(oCcinfo).concat().each(function (i, elm) {
                $$(elm).attr("datereceived", "");
            });
    	}
    } catch (e) { coviCmn.traceLog(e); }
    return jsonApv;
}