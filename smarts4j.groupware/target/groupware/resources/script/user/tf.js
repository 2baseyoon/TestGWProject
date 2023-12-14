//# sourceURL=tf.js
var profilePath = Common.getBaseConfig("ProfileImagePath").replace("{0}", Common.getSession("DN_Code")); //개인 프로필 이미지 경로
var g_fileList = null;
var g_performerList = null;

//업무 정보 셋팅
function setTaskData(tfID, activityID){
	var taskObj = getTaskData(tfID, activityID);
	
	setTaskDataBind(taskObj.taskInfo); //폴더 정보를 input 또는 p태그에 바인딩
	setMember("performer", t_haveModifyAuth, taskObj.performerList);
	setComment(taskObj); //댓글 
	
	g_fileList = taskObj.fileList;
	g_performerList = taskObj.performerList;
}

//업무 정보 조회
function getTaskData(tfID, activityID){
	var returnData; 
	
	$.ajax({
		url:"/groupware/tf/getTaskData.do",
		type:"POST",
		async: false,
		data : {
			"CU_ID" : tfID,
			"AT_ID" : activityID
		},
		success:function(data){
			returnData =  data;
		},error:function(response, status, error){
			CFN_ErrorAjax("/groupware/tf/getTaskData.do", response, status, error);
		}
	});
	
	return returnData;
}

function getPojectPerformerInfo(){
	var performerList = g_performerList;
	var itemArray = null;
	if(performerList != null && performerList != ""){
		var uc = new Array();
		for(var i=0;i<performerList.length;i++){
			uc.push(performerList[i].Code);
		}
		
		$.ajax({
			url:"/groupware/tf/selectUserMailList.do",
			type:"POST",
			async: false,
			data : {"userCode" : uc},
			success:function(data){
				if(data.status == "SUCCESS"){
					itemArray = {"item":data.userList};
				}
			},error:function(response, status, error){
				CFN_ErrorAjax("/groupware/tf/selectUserMailList.do", response, status, error);
			}
		});
	}
	return itemArray;
}

function getProjectFileInfo(){
	var fileList = g_fileList;
	var attFileInfo = new Array();
	var attachFileRootPath = "";
	var bizSection = "TF";
	
	if(fileList != null && fileList != ""){
		var osType = Common.getGlobalProperties("Globals.OsType");
		
		if(osType == "UNIX"){
			attachFileRootPath = Common.getGlobalProperties("attachUNIX.path");
		}else{
			attachFileRootPath = Common.getGlobalProperties("attachWINDOW.path");
		}
		
		$.each(fileList, function(i, file){
			var json = new Object();
			
			json.fileName = file.FileName;
			json.saveFileName = file.SavedName;
			json.savePath = attachFileRootPath + bizSection + "/" + file.FilePath;
			json.fileSize = file.Size;
			
			attFileInfo.push(json);
		});
	}
	
	return attFileInfo;
}

function setTaskDataBind(taskObj){
	$("#registDate").text(new Date(taskObj.RegistDate).format("yyyy.MM.dd HH:mm"));
	$("#registerName").text(taskObj.RegisterName);
	
	if(t_haveModifyAuth=="Y"){ //수정이 가능한 경우 write 요소에 바인딩
		$("#ATnameWrite").val(taskObj.ATName);
		$("#periodWrite").find("[id=periodWrite_StartDate]").val(isNull(taskObj.StartDate,'').replaceAll('-','.'));
		$("#periodWrite").find("[id=periodWrite_EndDate]").val(isNull(taskObj.EndDate,'').replaceAll('-','.'));
		coviCtrl.setSelected('stateWrite', taskObj.TaskStateCode);
		//$("#hidDescription").val(taskObj.Description);
		$("#description").val(taskObj.Description);
		$("#progressWrite").val(taskObj.Progress);
		$("#weightWrite").val(taskObj.Weight);
		$("#sortkeyWrite").val(taskObj.SortKey);
		$("#txtMemberOf").val(taskObj.MemberOf);
		$("#txtATPath").val(taskObj.ATPath);

		// Description
		/*if(!/<[a-z][\s\S]*>/i.test(taskObj.Description)){
			$("#description").val(taskObj.Description);
		}else{
			$("#description").hide();
			$("#dext5").show();
			
			$("#changeEdit").attr("value", "editor");
			$("#changeEdit").find("a").html(coviDic.dicMap["lbl_writeTextArea"]); //텍스트로 작성
			
			if($("#dext5").html() == ""){
				coviEditor.loadEditor( 'dext5', {
							editorType : g_editorKind,
							containerID : 'tbContentElement',
							frameHeight : '400',
							focusObjID : '',
							useResize : 'Y',
							bizSection : 'Task',
							onLoad: function(){
								coviEditor.setBody(g_editorKind, 'tbContentElement', taskObj.Description);
							}
				});
			}
		}*/
	}else{ //수정이 불가능한 경우 read 요소에 바인딩
		$("#ATnameRead").text(taskObj.ATName);
		$("#periodRead").text(isNull(taskObj.StartDate,'').replaceAll('-','.')+" ~ "+ isNull(taskObj.EndDate,'').replaceAll('-','.'));
		$("#stateRead").text(taskObj.TaskState);
		$("#descriptionRead").html(taskObj.Description.replace(/\n/gi, '<br/>'));
		
		$("#progressWrite").next("p").html("");
		$("#progressRead").html(taskObj.Progress + '%');
		
		//$("#weightRead").html(taskObj.Weight + '%');
		$("#sortkeyRead").html(taskObj.SortKey);
		$("#txtMemberOf").val(taskObj.MemberOf);
		$("#selCategoryRead").html(taskObj.MEM_ATName);
		
		/*if(taskObj.MemberOf == ""){
			$("#ATMemberOf").hide();
		}else{
			$("#ATMemberOf").show();
			$("#selLCategory").val(taskObj.MemberOf);
			$("#selMCategory").val(taskObj.MemberOf);
		}*/
	}
}


//공유자or 수행자 HTML 그리기
function setMember(target, haveModifyAuth, memberList){
	var listHTML = '';
	var haveDup = false; //중복 요소 체크
	
	$.each(memberList,function(idx,obj){
		if($("#"+target+"List>li[code='"+ obj.Code +"'][type='"+ obj.Type +"']").length > 0 ){
			haveDup = true;
			return true; //continue;
		}
		
		listHTML +='<li code="'+obj.Code+'" type="'+obj.Type +'">';
		listHTML +='	<div class="personBox perBoxType02">';
		if(obj.Type == "UR"){
			listHTML +='		<div class="perPhoto">';
			listHTML +='			<img src="' + coviCmn.loadImage(profilePath + obj.Code + ".jpg") + '" style="width:100%;height:100%;" onerror="coviCmn.imgError(this, true);">';
			listHTML +='		</div>';
		}
		listHTML +='		<div class="name">';
		listHTML +='			<p><strong>'+obj.Name+'</strong></p>';
		listHTML +='			<p><span>'+isNull(obj.DeptName,'')+'</span></p>';
		listHTML +='		</div>';
		if(haveModifyAuth == "Y"){
			listHTML +='	<a class="btnListRemove" onclick="removeMember(this)"></a>';
		}
		listHTML +='	</div>';
		listHTML +='</li>';
	});
	
	$("#"+target+"List").append(listHTML);
	
	if(haveDup){
		Common.Warning(Common.getDic("msg_task_notDupAdd"));  //특정 사용자 또는 그룹을 중복 추가할 수 없습니다
	}
}

//공유자 목록 조회
function getMemberList(target){
	var arrMember = [];
	
	$("ul#"+target+"List").children("li").each(function(idx,obj){
		
		arrMember.push(	{
			"PerformerCode": $(obj).attr("code"),
		});
	});
	
	return arrMember;
}

// 공유자 삭제
function removeMember(obj){
	if(obj != undefined){ //개별 삭제 버튼 (row에 위치하는 삭제 버튼을 클릭한 경우
		$(obj).closest('li').eq(0).remove();
	}
}

//업무 저장
function saveTask(mode){
	if(!chekValidation()){
		return; 
	}
	
	var formData = new FormData();		// [Added][FileUpload]
	
	formData.append("mode", mode);
	formData.append("taskStr", JSON.stringify(getTaskObj(mode)));
	
	formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
	for (var i = 0; i < coviFile.files.length; i++) {
		if (typeof coviFile.files[i] == 'object') {
			formData.append("files", coviFile.files[i]);
		}
	}
	formData.append("fileCnt", coviFile.fileInfos.length);
	
	$.ajax({
		url: '/groupware/tf/saveTaskData.do',
		type: 'post',
		data: formData,
		contentType: false,
		processData : false,
		success: function (res) {
			if(res.status=='SUCCESS'){
				// 추가/생성 시 동일 업무명 체크 
				if(res.chkDuplilcation.isDuplication=="Y"){
					var message =  ( mode =="I" || mode =="IT" ? Common.getDic("msg_task_insertRenameTask") : Common.getDic("msg_task_saveRenameTask")  ) // 동일한 이름의 업무가 존재하여<br>[{0}]로 등록되었습니다. : 동일한 이름의 업무가 존재하여<br>[{0}]로 저장되었습니다. 
					 message = String.format(message, res.chkDuplilcation.saveName);
					
					Common.Inform(message, "Inform", function(){
						parent.search();
						Common.Close();
					});
				}else{
					Common.Inform(( mode =="I" || mode =="IT" ? Common.getDic("msg_insert") : Common.getDic("msg_37")  ),"Inform",function(){
						parent.search();
						Common.Close();
					});	
				}
			}else{
				Common.Error(Common.getDic("msg_ErrorOccurred")); //오류가 발생했습니다.
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("saveTaskData.do", response, status, error);
		}
	});
}

//업무 추가/수정 시 필요한 Data를 JSON 형식으로 생성
function getTaskObj(mode){
	var taskObj; 
	var period = coviCtrl.getDataByParentId('periodWrite');
	
	var desc;
	if($("#progressWrite").val() == "") $("#progressWrite").val("0");
	if($("#weightWrite").val() == "") $("#weightWrite").val("0");
	
	if(coviCtrl.getSelected('stateWrite').val == "Complete"){
		$("#progressWrite").val("100");
	}
	if($("#progressWrite").val() == "100" && coviCtrl.getSelected('stateWrite').val != "Complete" ){
		coviCtrl.setSelected('stateWrite', "Complete");
	}	
	
	//gubun(구분)값 처리 넣어야 함
	var gubun = "A";
	if(mode.toUpperCase()=="I" || mode.toUpperCase()=="IT"){ //추가, 임시저장
		taskObj = { 
				  "CU_ID": t_CU_ID,
				  "ATName": $("#ATnameWrite").val(),
				  "State": coviCtrl.getSelected('stateWrite').val,
				  "Weight": $("#weightWrite").val(),
				  "Progress": $("#progressWrite").val(),
				  "SortKey": $("#sortkeyWrite").val(),
				  "StartDate": period.startDate,
				  "EndDate":  period.endDate,
				  "Gubun":  gubun,
				  "MemberOf":  $("#txtMemberOf").val(),
				  //"InlineImage": getTaskInlineImage(),
				  "Description": getTaskDescription(),
				  "RegisterCode": userCode,
				  //"OwnerCode":   isNull(t_folderInfoObj.OwnerCode,userCode), //내가 하는 일 폴더는 ownerCode가 넘어오지 않음
				  "PerformerList": getMemberList("performer"),
				  "useProgressOption": Common.getBaseConfig("IsUseWeight"),
				};
	}else if(mode.toUpperCase()=="U" || mode.toUpperCase()=="UT"){ //수정, 등록(임시저장->등록)
		taskObj = {
				  "AT_ID": t_AT_ID,
				  "CU_ID": t_CU_ID,
				  "ATName": $("#ATnameWrite").val(),
				  "State": coviCtrl.getSelected('stateWrite').val,
				  "Weight": $("#weightWrite").val(),
				  "Progress": $("#progressWrite").val(),
				  "SortKey": $("#sortkeyWrite").val(),
				  "StartDate": period.startDate,
				  "EndDate":  period.endDate,
				  "Gubun":  gubun,
				  "MemberOf":  $("#txtMemberOf").val(),
				  //"InlineImage": getTaskInlineImage(),
				  "Description": getTaskDescription(),
				  "UpdaterCode": userCode,
				  "PerformerList": getMemberList("performer"),
				  "useProgressOption": Common.getBaseConfig("IsUseWeight"),
				};
	}
	
	return taskObj;
}

//업무 추가/수정 시 사용하는 컨트롤 바인딩
function setTaskControl(CU_ID){
	var timeInfos = {
			width : "100",
			H : "",
			W : "1,2,3,4", //주 선택
			M : "1,2,3,6", //달 선택
			Y : "1" //년도 선택
		};
	
	var initInfos = {
			useCalendarPicker : 'Y',	//캘린더 paicker의 사용여부로, 날짜를 선택하는 달력의 사용여부를 묻는 옵션입니다.
			useTimePicker : 'N',	//time picker의 사용여부로, 00:00 부터 23:00 까지의 시간을 선택하는 select box의 사용여부를 묻는 옵션입니다.
			useBar : 'Y'	//time picker 사이의 bar의 사용여부를 묻는 옵션입니다.
		};
	
	coviCtrl.renderDateSelect('periodWrite', timeInfos, initInfos);
	
	coviCtrl.setSelected('periodWrite [name=datePicker]', "select");	//coviCtrl.clickSelectListBox($("[data-codename=선택]"), 'selPickerChange');
	$("#periodWrite").find("[id=periodWrite_StartDate]").val("");
	$("#periodWrite").find("[id=periodWrite_EndDate]").val("");
	
	// 완료일
	coviCtrl.makeSimpleCalendar('completeWrite', "");
	
	coviCtrl.renderAjaxSelect(initInfos = [ {
		target : 'stateWrite',
		codeGroup : 'TaskState',
		defaultVal : 'Waiting',
		width : '160',
		onclick : ''
	}], '', lang);
}

//조회일 경우 댓글 바인딩
function setComment(taskObj){
	var userId = sessionObj["USERID"];
	var isOwner = (taskObj.taskInfo.RegisterCode==userCode || taskObj.taskInfo.OwnerCode == userCode)? "Y":"N";
	var receiverList = taskObj.taskInfo.RegisterCode;
	
	if(taskObj.taskInfo.RegisterCode != taskObj.taskInfo.OwnerCode){
		receiverList += ";"+  taskObj.taskInfo.OwnerCode;
	}
	
	var msgContext = String.format(Common.getDic("msg_task_replyMessage"), taskObj.taskInfo.ATName, sessionObj["USERNAME"] ); // {0} 업무에 대해서 {1}님이 댓글을 남기셨습니다.
	//연결 URL
	var goToUrl = String.format("{0}/groupware/tf/goActivitySetPopup.do?mode=Modify&AT_ID={0}&CU_ID={1}&isSearch=&isOwner={3}&FN_OpenLayerName=activitySet", Common.getGlobalProperties("smart4j.path"), taskObj.taskInfo.AT_ID, taskObj.taskInfo.CU_ID, isOwner);
	var mobileUrl = String.format("/groupware/mobile/tf/view.do?atid={0}&cuid={1}", Common.getGlobalProperties("smart4j.path"), isOwner, taskObj.taskInfo.AT_ID, taskObj.taskInfo.CU_ID);
	
	var messageSetting = {
		SenderCode : userId,
		RegistererCode : userId,
		ReceiversCode : receiverList,
		MessagingSubject : taskObj.taskInfo.ATName, //댓글 알림
		MessageContext : msgContext, 
		ReceiverText :  taskObj.taskInfo.ATName ,  //댓글 알림   
		GotoURL: goToUrl,
		PopupURL: goToUrl,
		MobileURL: mobileUrl,
		Width:"700",
		Height:"980",
		ServiceType : "TF",
		MsgType : "TFActivityComment"
	};
	
	coviComment.load('commentView', 'TKAT', taskObj.taskInfo.AT_ID, messageSetting);
}

//표시 버튼 셋팅
function setButton(mode, haveModifyAuth, isTempSave){
	if(mode=="ADD"){
		$("a[name='registBtn']").show();
		$("a[name='cancelBtn']").show();
	}else if( mode == "MODIFY" && haveModifyAuth == "Y"){
		$("a[name='saveBtn']").show();
		$("a[name='cancelBtn']").show();
		$("a[name='mailBtn']").show();
	}else{
		$("a[name='confirmBtn']").show();
	}
}
// 추가 및 수정 시 validation chk
function chekValidation(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	//가중치 사용하는 경우 가중치 합 안내
	var lweight = parseInt($("#weightWrite").val());
	var lsumweight = 0;
	
	if(Common.getBaseConfig("IsUseWeight")=="Y"){
		$.ajax({
			url:"/groupware/tf/getSumTaskWeight.do",
			type:"POST",
			async: false,
			data : {
				"CU_ID" : t_CU_ID,
				"AT_ID" : t_AT_ID,
				"MemberOf" : $("#txtMemberOf").val(),
				"mode" : t_mode
			},
			success:function(data){
				lsumweight = parseInt(data.SumTaskWeight);
			},error:function(response, status, error){
				CFN_ErrorAjax("/groupware/tf/getSumTaskWeights.do", response, status, error);
			}
		});
	}
	
	if($("#ATnameWrite").val() == ''){
		Common.Warning(Common.getDic("msg_028")); //제목을 입력하세요
		// TODO focus 주가
		return false;
	}else if(coviCtrl.getSelected('stateWrite').val == '' || coviCtrl.getSelected('stateWrite').val == 'TaskState'){
		Common.Warning(Common.getDic("msg_task_selectState")); //상태를 선택하세요
		return false;
	}else if(Common.getBaseConfig("IsUseWeight")=="Y" && ((lweight+lsumweight)> 100)){
		Common.Warning("기존 동일 단계 가중치 합 : "+ String(lsumweight) + "<br>가중치 값을 변경하세요.");
		return false;
	}else if($("#periodWrite_StartDate").val() == "" || $("#periodWrite_EndDate").val() == ""){
		Common.Warning(Common.getDic("msg_fillPeriod")); // 수행기간을 입력하세요.
		return false;
	}else{
		if(t_haveModifyAuth != null && t_haveModifyAuth != "Y"){
			Common.Warning(Common.getDic("msg_noModifyACL")); //수정 권한이 없습니다.
			return false;
		}
		
		return true;
	}
}

//조직도 팝업 오픈
function orgChartPopup(type,funcName,openerID){
	//조직도
	parent.Common.open("","orgmap_pop",Common.getDic("lbl_DeptOrgMap"),"/covicore/control/goOrgChart.do?type="+type+"&callBackFunc="+funcName+"&openerID="+openerID,"1000px","580px","iframe",true,null,null,true);
}

//조직도 콜백 함수(공유자 지정)
function OrgCallBack_SetShareMember(data){
	//var isMySelf = false; //본인 스스로를 지정한 경우 (상위에서 지정된 경우에는 지정되어 있을 수 있지만 스스로를 공유자로 추가할 수는 없음)
	var orgObj = $.parseJSON(data);
	var arrMember = [];
	
	$.each(orgObj.item,function(idx,obj){
		var type = obj.itemType.toUpperCase() == "USER" ? "UR" : (obj.AN == obj.CompanyCode ? "CM": "GR");
		
		/* if(obj.AN == userCode){
			isMySelf = true;
			return true; 
		} */
		
		var memObj = {
			"Code": obj.AN,
			"Type": type,
			"Name": CFN_GetDicInfo(obj.DN,lang),
			"DeptName": CFN_GetDicInfo(isNull(obj.ExGroupName, ''), lang)
		};
		
		arrMember.push(memObj);
	});
	
	setMember("shareMember", f_haveModifyAuth, arrMember);
	
	/* if(isMySelf){
		Common.Warning("공유자로 본인을 지정할 수 없습니다.");
	} */
}

//조직도 콜백 함수(수행자 지정)
function OrgCallBack_SetPerformer(data){
	var orgObj = $.parseJSON(data);
	var arrMember = [];
	
	$.each(orgObj.item,function(idx,obj){
		
		var memObj = {
			"Code": obj.AN,
			"Type": 'UR',
			"Name": CFN_GetDicInfo(obj.DN,lang),
			"DeptName": CFN_GetDicInfo(isNull(obj.ExGroupName,''), lang)
		};
		
		arrMember.push(memObj);
	});
	
	setMember("performer", t_haveModifyAuth, arrMember);
}

//용도 Textarea | Editor 변환
function switchTextAreaEditor(obj){
	if($(obj).attr("value") == "textarea"){
		$("#description").hide();
		$("#dext5").show();
		
		if($("#dext5").html() == ""){
			coviEditor.loadEditor( 'dext5', {
						editorType : g_editorKind,
						containerID : 'tbContentElement',
						frameHeight : '400',
						focusObjID : '',
						useResize : 'Y',
						bizSection : 'Task',
						onLoad : function(){
							coviEditor.setBody(g_editorKind, 'tbContentElement', $("#description").val().replaceAll("\n", "<br>"));
						}
			});
		}else{
			if(coviEditor.getBodyText(g_editorKind, 'tbContentElement') == $("#description").val())
				coviEditor.setBody(g_editorKind, 'tbContentElement', $("#hidDescription").val());
			else
				coviEditor.setBody(g_editorKind, 'tbContentElement', $("#description").val().replaceAll("\n", "<br>"));
		}
		
		$(obj).attr("value", "editor");
		$(obj).find("a").html(coviDic.dicMap["lbl_writeTextArea"]); //텍스트로 작성
	}else{
		$("#dext5").hide();
		$("#description").show();
		
		$(obj).attr("value", "textarea");
		$(obj).find("a").html(coviDic.dicMap["lbl_editChange"]); //편집기로 작성
		
		$("#hidDescription").val(coviEditor.getBody(g_editorKind, 'tbContentElement'));
		$("#description").val(coviEditor.getBodyText(g_editorKind, 'tbContentElement'));
	}
}

//textarea 또는 editor로 작성된 설명 값 조회
function getTaskInlineImage(){
	// 본문 에디터 혹은 TextArea
	if($("#changeEdit").attr("value") == "textarea"){
		return "";
	}else{
		return  coviEditor.getImages(g_editorKind, 'tbContentElement');
	}
}

//textarea 또는 editor로 작성된 설명 값 조회
function getTaskDescription(){
	// 본문 에디터 혹은 TextArea
	if($("#changeEdit").attr("value") == "textarea"){
		return $("#description").val();
	}
	else{
		return  coviEditor.getBody(g_editorKind, 'tbContentElement');
	}
}

//빈값 체크
function isNull(value ,defaultValue){
	if(typeof value == 'undefined' || value == null || value == 'undefined'){
		return defaultValue;
	}
	return value;
}

//진행현황조회
function getActivityProgress(){
	$("#ProgressTable").html('<p class="noSearchListCont">조회중입니다.</p>');	
	$("#hidGubun").val($("#selGubun").val());
	$.ajax({
		type: "POST",
		url: "/groupware/tf/getActivityProgress.do",
		data:{
			"CU_ID": communityId,
			"DateType" : $("#selGubun").val(),
			"SDate" : $("#selYear").val()+'-'+$("#selMonth").val()
		}
		, success : function(data){
			if(data.status=='SUCCESS'){
				if(data.list.length < 1 ){
					$("#ProgressTable").html('<p class="noSearchListCont">'+Common.getDic("msg_NoDataList")+'</p>'); //조회할 목록이 없습니다.
				}else{
					switch($("#hidGubun").val()){
						case "D" : setDateProgressList(data);break;
						case "M" : setWeeklyProgressList(data);break;
					}
				}
			}else{
				Common.Warning(Common.getDic("msg_ErrorOccurred")); //오류가 발생했습니다.
			}
		}
		, error:function(response, status, error){
			 CFN_ErrorAjax("/groupware/tf/getActivityProgress.do", response, status, error);
		}
	}); 
}	
//일자별그리기
function setDateProgressList(ProgressObj){
	var StrHtml = '';
	StrHtml += "<table id='ProgressTable' class='ITMtrpfield_table'>";
	StrHtml += "<colgroup><col width='40'></col><col width='200'></col><col width='50'></col><col width='95'></col><col width='95'></col><col width='"+String(25*ProgressObj.headerlist.length)+"'></col></colgroup>";
	StrHtml += "<tbody><tr height='30' class='borderbottom'>";
	StrHtml += "<td class='HeaderCell' rowspan='2'>"+Common.getDic("lbl_executive_id")+"</td>";
	StrHtml += "<td class='HeaderCell' rowspan='2'>"+Common.getDic("lbl_WorkName")+"</td>";
	StrHtml += "<td class='HeaderCell' rowspan='2'>"+Common.getDic("lbl_scope")+"</td>";
	StrHtml += "<td class='HeaderCell' rowspan='2'>"+Common.getDic("lbl_startdate")+"</td>" ;
	StrHtml += "<td class='HeaderCell RightLine' rowspan='2'>"+Common.getDic("lbl_EndDate")+"</td>" ;
	StrHtml += "<td class='MonthCell'>"+$("#selYear").val() + Common.getDic("lbl_year") +" "+ $("#selMonth").val() + Common.getDic("lbl_month")+"</td>";
	StrHtml += "</tr>";
	StrHtml += "<tr height='15' class='borderbottom'><td><table width='100%' class='hidden' border='0' cellspacing='0' cellpadding='0' style=><tbody><tr ID='headerCell' class='ITMtrp_noline'>";
	
	$.each(ProgressObj.headerlist, function(idx,obj){
		StrHtml += "<td class='WeekCell' width='25'>"+CFN_PadLeft(obj.SEQ,2,'0')+"</td>";
	});
	
	StrHtml += "</tr></tbody></table></td></tr>";
	
	$.each(ProgressObj.list, function(idx,obj){
		StrHtml += "<tr Class='";
		if(obj.ParentName == ""){
			StrHtml +="ITMtrp_Titlist";
		}else{
			StrHtml += "ITMtrp_Sublist";
			if(idx < ProgressObj.list.length){
				//if(obj.MemberOf == ProgressObj.list[idx+1].MemberOf ){
					
				//}else{
				//	StrHtml += " last";
				//}
			}
		}
		StrHtml += "'>";
		var ATgubun = (obj.ParentName == "" ? "Activity":"Task");
		StrHtml += "<td class='"+ATgubun+"Cell' style='text-align: center;'>"+obj.SortKey+"</td>";
		if (ATgubun == "Activity")
		{
			StrHtml += "<td class='"+ATgubun+"Cell ellipsis' style='text-align: left;'>"+obj.ATName+"</td>";
		}
		else
		{
			StrHtml += "<td class='"+ATgubun+"Cell ellipsis Sublist_re' style='text-align: left;'>"+obj.ATName+"</td>";
		}
		StrHtml += "<td class='"+ATgubun+"Cell'>"+obj.TF_Period+"일</td>";
		StrHtml += "<td class='"+ATgubun+"Cell'>"+obj.StartDate+"</td>";
		StrHtml += "<td class='"+ATgubun+"Cell'>"+obj.EndDate+"</td>";
		StrHtml += "<td class='"+ATgubun+"Cell'>";
		StrHtml += "<table width='600' class='hidden' border='0' cellspacing='0' cellpadding='0'><tbody><tr class='ITMtrp_noline monthborder'>";
		
		//게이지 최소값
		var MinPoint = 0;
		if (parseInt(obj.ProgressPoint) < parseInt(obj.StartPoint))
		{ MinPoint = parseInt(obj.StartPoint); }
		else { MinPoint = parseInt(obj.ProgressPoint); }
		
		//alert(obj.StartPoint + " " + obj.ProgressPoint + " " + MinPoint + " " + obj.EndPoint);
		var ATStateClass = "ITMtrpTableBack_02_wait";//대기
		switch(obj.TaskState){
		case "Process":ATStateClass = "ITMtrpTableBack_02_progress";break;
		case "Complete":ATStateClass = "ITMtrpTableBack_02_finish";break;
		}
		for (var i = 1; i <= parseInt(obj.MaxSEQ); i++)
		{
			if (i >= parseInt(obj.StartPoint) && i <= parseInt(obj.ProgressPoint))
			{
				if (ATgubun == "Activity")
				{
					StrHtml += "<td class='"+ATStateClass+"' onmouseover='javascript:helpBoxAct(event,\""+obj.AT_ID+"\",\""+obj.ATName+"\",\""+obj.StartDate + " ~ " + obj.EndDate+"\",\""+obj.Progress+"\",\""+obj.Gubun+"\");' " ;
					StrHtml += 		" onmouseout='javascript:helpBoxHide();' " ;
					StrHtml += 		" onClick='javascript:ViewAT(\""+obj.AT_ID+"\",\""+obj.Gubun+"\");' " ;
					//StrHtml += 		" style='height: 8px; vertical-align: middle; background: #009de0;'";
					StrHtml +=" ></td>";
					/*	obj.ATName,//0
						obj.StartDate + " ~ " + obj.EndDate,//1
						obj.Progress,//2
						obj.AT_ID,//3
						obj.Gubun//4*/
				}
				else
				{
					StrHtml += "<td class='"+ATStateClass+"'  onmouseover='javascript:helpBoxTask(event,\""+obj.AT_ID+"\",\""+obj.ParentName+"\",\""+obj.ATName+"\",\""+obj.StartDate + " ~ " + obj.EndDate+"\",\""+obj.Progress+"\",\""+obj.Member+"\",\""+obj.Gubun+"\");' ";
					StrHtml += " onmouseout='javascript:helpBoxHide();' ";
					StrHtml += " onClick='javascript:ViewAT(\""+obj.AT_ID+"\",\""+obj.Gubun+"\");' ";
					//StrHtml += " style='height: 8px; vertical-align: middle; background: #8C8C8C;' ";
					StrHtml += "></td>";
					/*	obj.ParentName,//0
						obj.ATName,//1
						obj.StartDate + " ~ " + obj.EndDate,//2
						obj.Progress,//3
						obj.Member,//4
						obj.AT_ID,//5
						obj.Gubun//6 */
				}
			}
			else if (i >= MinPoint && i <= parseInt(obj.EndPoint))
			{
				if (ATgubun == "Activity")
				{
					StrHtml += "<td class='"+ATStateClass+"'  onmouseover='javascript:helpBoxAct(event,\""+obj.AT_ID+"\",\""+obj.ATName+"\",\""+obj.StartDate + " ~ " + obj.EndDate+"\",\""+obj.Progress+"\",\""+obj.Gubun+"\");' " ;
					StrHtml += " onmouseout='javascript:helpBoxHide();' ";
					StrHtml += " onClick='javascript:ViewAT(\""+obj.AT_ID+"\",\""+obj.Gubun+"\");' ";
					//StrHtml += " style='height: 8px; vertical-align: middle; background: skyblue;'" ;
					StrHtml += " ></td>";
				}
				else
				{
					StrHtml += "<td class='"+ATStateClass+"'  onmouseover='javascript:helpBoxTask(event,\""+obj.AT_ID+"\",\""+obj.ParentName+"\",\""+obj.ATName+"\",\""+obj.StartDate + " ~ " + obj.EndDate+"\",\""+obj.Progress+"\",\""+obj.Member+"\",\""+obj.Gubun+"\");' ";
					StrHtml += " onmouseout='javascript:helpBoxHide();' ";
					StrHtml += " onClick='javascript:ViewAT(\""+obj.AT_ID+"\",\""+obj.Gubun+"\");' ";
					//StrHtml += " style='height: 8px; vertical-align: middle; background: grey;'" ;
					StrHtml += " ></td>";
				}
			}
			else
			{
				StrHtml += "<td></td>";
			}
		}
		StrHtml += "</tr></tbody></table></td></tr>";
	});
	
	StrHtml += "</tbody></table>";
	$("#ProgressTable").html(StrHtml);
}

//주별그리기
function setWeeklyProgressList(ProgressObj){
	var StrHtml = '';
	
	StrHtml += "<table id='ProgressTable' class='ITMtrpfield_table'>";
	StrHtml += "<colgroup><col width='50'></col><col width='200'></col><col width='50'></col><col width='95'></col><col width='95'></col><col width='150'></col><col width='150'></col><col width='150'></col></colgroup>";
	StrHtml += "<tbody><tr>";
	StrHtml += "<td class='HeaderCell' rowspan='2'>"+ Common.getDic("lbl_executive_id") +"</td>";
	StrHtml += "<td class='HeaderCell' rowspan='2'>"+ Common.getDic("lbl_WorkName") +"</td>";
	StrHtml += "<td class='HeaderCell' rowspan='2'>"+ Common.getDic("lbl_scope") +"</td>";
	StrHtml += "<td class='HeaderCell' rowspan='2'>"+ Common.getDic("lbl_startdate")+"</td>";
	StrHtml += "<td class='HeaderCell RightLine' rowspan='2'>"+ Common.getDic("lbl_EndDate") +"</td>";
	
	//헤더그리기
	$.each(ProgressObj.headerlist, function(idx,obj){
		StrHtml += "<td class='MonthCell RightLine' style='text-align:center;'>"+obj.SolarDate.substring(0, 4) + Common.getDic("lbl_year") +" "+ obj.SolarDate.substring(5,7)+Common.getDic("lbl_month") +"</td>";
	});
	StrHtml += "</tr>";
	StrHtml += "<tr height='15'>";
	
	$.each(ProgressObj.headerlist, function(idx,obj){
		StrHtml += "<td><table width='100%' class='hidden' border='0' cellspacing='0' cellpadding='0'><tbody><tr id='headerCell' class='ITMtrp_noline'>";
		for (var i = 1; i <= parseInt(obj.OrderWeekInMonth); i++)
		{
			if (i == parseInt(obj.OrderWeekInMonth))
			{
				StrHtml += "<td class='WeekCell RightLine' style='text-align: center;'>"+ String(i) +"</td>";
			}
			else
			{
				StrHtml += "<td class='WeekCell' style='text-align: center;'>"+String(i)+"</td>";
			}
		}
		StrHtml += "<tr></tbody></table></td>";
	});
	StrHtml += "</tr>";
	
	$.each(ProgressObj.list, function(idx,obj){
		StrHtml += "<tr Class='"+(obj.ParentName == "" ? "ITMtrp_Titlist":"ITMtrp_Sublist")+"'>";
		var ATgubun = (obj.ParentName == "" ? "Activity":"Task");
		StrHtml += "<td class='"+ATgubun+"Cell' style='text-align: center;'>"+ obj.SortKey +"</td>";
		if (ATgubun == "Activity") //obj.Gubun
		{
			StrHtml += "<td class='"+ATgubun+"Cell ellipsis' style='text-align: left;'>"+ obj.ATName +"</td>";
		}
		else
		{
			StrHtml += "<td class='"+ATgubun+"Cell ellipsis Sublist_re' style='text-align: left;'>"+obj.ATName+"</td>";
		}
		StrHtml += "<td class='"+ATgubun+"Cell'>"+ obj.TF_Period +"일</td>";
		StrHtml += "<td class='"+ATgubun+"Cell'>"+ obj.StartDate +"</td>";
		StrHtml += "<td class='"+ATgubun+"Cell'>"+ obj.EndDate +"</td>";
		StrHtml += "<td class='"+ATgubun+"Cell' colspan='3'>";
		StrHtml += "<table width='100%' class='hidden' border='0' cellspacing='0' cellpadding='0'><tbody><tr class='ITMtrp_noline monthborder'>";
		
		//게이지 최소값
		var MinPoint = 0;
		if (parseInt(obj.ProgressPoint) < parseInt(obj.StartPoint))
		{ MinPoint = parseInt(obj.StartPoint); }
		else { MinPoint = parseInt(obj.ProgressPoint); }
		
		var ATStateClass = "ITMtrpTableBack_02_wait";//대기
		switch(obj.TaskState){
		case "Process":ATStateClass = "ITMtrpTableBack_02_progress";break;
		case "Complete":ATStateClass = "ITMtrpTableBack_02_finish";break;
		}
		for (var i = 1; i <= parseInt(obj.MaxSEQ); i++)
		{
			if (i >= parseInt(obj.StartPoint) && i <= parseInt(obj.ProgressPoint))
			{
				if (ATgubun == "Activity")
				{
					StrHtml += "<td class='"+ATStateClass+"'  onmouseover='helpBoxAct(event,\""+obj.AT_ID+"\",\""+obj.ATName+"\",\""+obj.StartDate + " ~ " + obj.EndDate+"\",\""+obj.Progress+"\",\""+obj.Gubun+"\");' " ;
					StrHtml += " onmouseout='helpBoxHide();' ";
					StrHtml += " onClick='ViewAT(\""+obj.AT_ID+"\",\""+obj.Gubun+"\");' " ;
					//StrHtml += " style='height: 8px; vertical-align: middle; background: #009de0;' ";
					StrHtml += " ></td>";
					   /* obj.ATName,//0
						obj.StartDate + " ~ " + obj.EndDate,//1
						obj.Progress,//2
						obj.AT_ID,//3
						obj.Gubun//4
						*/
				}
				else
				{
					StrHtml += "<td class='"+ATStateClass+"'  onmouseover='helpBoxTask(event,\""+obj.AT_ID+"\",\""+obj.ParentName+"\",\""+obj.ATName+"\",\""+obj.StartDate + " ~ " + obj.EndDate+"\",\""+obj.Progress+"\",\""+obj.Member+"\",\""+obj.Gubun+"\");' ";
					StrHtml += " onmouseout='helpBoxHide();' ";
					StrHtml += " onClick='javascript:ViewAT(\""+obj.AT_ID+"\",\""+obj.Gubun+"\");' ";
					//StrHtml += " style='height: 8px; vertical-align: middle; background: #8C8C8C;' " ;
					StrHtml += "></td>";
						/*obj.ParentName,//0
						obj.ATName,//1
						   obj.StartDate + " ~ " + obj.EndDate,//2
						   obj.Progress,//3
						   obj.Member,//4
						   obj.AT_ID,//5
						   obj.Gubun//6
						   */
				}
			}
			else if (i >= MinPoint && i <= parseInt(obj.EndPoint))
			{
				if (ATgubun == "Activity")
				{
					StrHtml += "<td class='"+ATStateClass+"'  onmouseover='helpBoxAct(event,\""+obj.AT_ID+"\",\""+obj.ATName+"\",\""+obj.StartDate + " ~ " + obj.EndDate+"\",\""+obj.Progress+"\",\""+obj.Gubun+"\");' " ;
					StrHtml += " onmouseout='helpBoxHide();' ";
					StrHtml += " onClick='javascript:ViewAT(\""+obj.AT_ID+"\",\""+obj.Gubun+"\");' ";
					//StrHtml += " style='height: 8px; vertical-align: middle; background: skyblue;' " ;
					StrHtml += "></td>";
				}
				else
				{
					StrHtml += "<td class='"+ATStateClass+"'  onmouseover='helpBoxTask(event,\""+obj.AT_ID+"\",\""+obj.ParentName+"\",\""+obj.ATName+"\",\""+obj.StartDate + " ~ " + obj.EndDate+"\",\""+obj.Progress+"\",\""+obj.Member+"\",\""+obj.Gubun+"\");' ";
					StrHtml += " onmouseout='helpBoxHide();' ";
					StrHtml += " onClick='javascript:ViewAT(\""+obj.AT_ID+"\",\""+obj.Gubun+"\");' ";
					//StrHtml += " style='height: 8px; vertical-align: middle; background: #BDBDBD;' ";
					StrHtml += " ></td>";
				}
			}
			else
			{
				StrHtml += "<td></td>";
			}
		}
		StrHtml += "</tr></tbody></table></td></tr>";
	});
	
	StrHtml += "</tbody></table>";
	$("#ProgressTable").html(StrHtml);
}
//Activity시작

//Activity종료