//# sourceURL=task.js
//개별호출-일괄호출
var sessionObj = Common.getSession(); //전체호출

var lang = sessionObj["lang"];
var userCode = sessionObj["USERID"];
var profilePath = Common.getBaseConfig("ProfileImagePath").replace("{0}", Common.getSession("DN_Code")); //개인 프로필 이미지 경로
Common.getDicList(["lbl_Folder","lbl_task_task","msg_NoDataList","msg_ErrorOccurred","lbl_Move","lbl_Copy", "lbl_TempSave"
				, "lbl_Setting","lbl_delete","lbl_NoReadAuth","lbl_task_folderMove","lbl_task_taskMove","lbl_task_taskCopy"
				, "lbl_task_deleteChildren", "msg_AreYouDelete", "msg_50", "lbl_task_folderManage", "lbl_task_taskManage"
				, "lbl_task_addFolder", "lbl_task_addTask", "msg_028","msg_task_selectState","lbl_DeptOrgMap", "lbl_writeTextArea"
				, "lbl_editChange", "msg_task_notYourself", "msg_insert", "msg_37", "msg_task_notDupAdd", "msg_task_insertRenameTask"
				, "msg_task_insertRenameFolder", "msg_task_saveRenameFolder", "msg_task_saveRenameTask", "lbl_task_selectPerformer", "lbl_com_replyAlarm", "msg_task_replyMessage", "msg_noModifyACL", "msg_task_plzEnterPerformer", "msg_StartDateCannotAfterEndDate"]);


//메인화면 공통 사용 변수(item.jsp에서 주로 사용)
var g_FolderID;
var g_ParentFolderID;
var g_IsMine;
var g_isSearch;

var g_fileList = null;

var g_editorKind = Common.getBaseConfig('EditorType');

//필요한 데이터 초기화
function initTaskData(){
	g_isSearch = "N";
	g_FolderID = CFN_GetQueryString("folderID") == "undefined" ? '' : CFN_GetQueryString("folderID");
	g_IsMine =  CFN_GetQueryString("isMine") == "undefined" ? '' : CFN_GetQueryString("isMine");
}

//컨트롤 바인딩(selectbox 등)
function setControl(type){
	var onchangeFunc = type.toUpperCase()=="FOLDER" ? "getFolderItemList": "getSearchAll";
	var sortColumn = window.sessionStorage.getItem("TaskSortColumn_"+userCode);
	var sortDirection = window.sessionStorage.getItem("TaskSortDirection_"+userCode);
	var initInfos;
	
	if(sortColumn != null){
		$("#sortColumnSelect").val(sortColumn);
	}
	
	if(sortDirection != null){
		$("#sortDirectionSelect").val(sortDirection);
	}
	
	coviCtrl.renderAjaxSelect(initInfos = [ {
	    target : 'stateSelect',	
	    codeGroup : 'TaskState',
	    defaultVal : '',
	    width : '160',	
	    onchange: onchangeFunc
	}], '', lang);
	
	if(g_FolderID == 0){
		if(g_IsMine=="N"){
			$("#topDivButton").hide();
		}else{
			$("#btnPrevStep").hide();
		}
	}
	
}

//폴더 하위 항목 조회
function getFolderItemList(){
	$.ajax({
		type: "POST",
		url: "/groupware/task/getFolderItemList.do",
		data:{
			"folderID": g_FolderID,
			"isMine" : g_IsMine,
			"stateCode" : coviCtrl.getSelected('stateSelect').val,
			"searchType" : $("#searchTypeSelect").val(),
			"searchWord" : $("#searchWord").val(),
			"sortColumn" : $("#sortColumnSelect").val(),
			"sortDirection" : $("#sortDirectionSelect").val()
		}
		, success : function(data){
			if(data.status=='SUCCESS'){
				g_ParentFolderID = data.FolderInfo.ParentFolderID;
				focusCurrentFolder(); //좌측트리에서 현재 폴더에 포커스
				$("#folderName").text(data.FolderInfo.DisplayName);
				
				if(data.FolderList.length < 1 && data.TaskList.length < 1 && data.TempTaskList.length < 1){
					$("#itemContainer").html('<p class="noSearchListCont">'+coviDic.dicMap["msg_NoDataList"]+'</p>'); //조회할 목록이 없습니다.
				}else{
					//조회할 목록이 없는 상태에서 항목 추가 시 
					if($("#folderListContainer")[0] == undefined){
						var sHtml = '';
						sHtml += '<div id="folderDiv" style="display:none">';
						sHtml += '	<h2 class="lineTitle"><span>'+coviDic.dicMap["lbl_Folder"]+'</span><span id="folderCnt">(0)</span></h2>'; //폴더
						sHtml += '	<div id="folderListContainer" class="mt15px taskListCont"></div>';
						sHtml += '</div>';
						sHtml += '<div id="taskDiv" class="mt25" style="display:none">';
						sHtml += '	<h2 class="lineTitle"><span>'+coviDic.dicMap["lbl_task_task"]+'</span><span id="taskCnt">(0)</span></h2>'; //업무
						sHtml += '	<div id="taskListContainer" class="taskListCont"></div>';
						sHtml += '</div>';
						sHtml += '<div id="tempTaskDiv" class="mt25" style="display:none;">';
						sHtml += '	<h2 class="lineTitle"><span>'+coviDic.dicMap["lbl_TempSave"]+coviDic.dicMap["lbl_task_task"]+'</span><span id="tempTaskCnt">(0)</span></h2>'; //임시저장 업무 
						sHtml += '	<div id="tempTaskListContainer" class="taskListCont"></div>';
						sHtml += '</div>';
						
						$("#itemContainer").html(sHtml);
					} 
					setFolderItemResult(data);
				}
			}else{
				Common.Warning(coviDic.dicMap["msg_ErrorOccurred"]); //오류가 발생했습니다.
			}
		}
		, error:function(response, status, error){
		     CFN_ErrorAjax("/groupware/task/getFolderItemList.do", response, status, error);
		}
	}); 
}

//좌측메뉴 전체 결과 조회
function getSearchAll(){
	$.ajax({
		type: "POST",
		url: "/groupware/task/getSearchAll.do",
		data:{
			"searchWord": searchWord,
			"stateCode": coviCtrl.getSelected('stateSelect').val,
			"sortColumn" : $("#sortColumnSelect").val(),
			"sortDirection" : $("#sortDirectionSelect").val()
		}
		, success : function(data){
			if(data.status=='SUCCESS'){
				if(data.FolderList.length < 1 && data.TaskList.length < 1  && data.TempTaskList.length < 1 ){
					$("#itemContainer").html('<p class="noSearchListCont">'+coviDic.dicMap["msg_NoDataList"]+'</p>'); //조회할 목록이 없습니다.
				}else{
					//조회할 목록이 없는 상태에서 항목 추가 시 
					if($("#folderListContainer")[0] == undefined){
						var sHtml = '';
						sHtml += '<div id="folderDiv" style="display:none">';
						sHtml += '	<h2 class="lineTitle"><span>'+coviDic.dicMap["lbl_Folder"]+'</span><span id="folderCnt">(0)</span></h2>'; //폴더
						sHtml += '	<div id="folderListContainer" class="mt15px taskListCont"></div>';
						sHtml += '</div>';
						sHtml += '<div id="taskDiv" class="mt25" style="display:none">';
						sHtml += '	<h2 class="lineTitle"><span>'+coviDic.dicMap["lbl_task_task"]+'</span><span id="taskCnt">(0)</span></h2>'; //업무
						sHtml += '	<div id="taskListContainer" class="taskListCont"></div>';
						sHtml += '</div>';
						sHtml += '<div id="tempTaskDiv" class="mt25" style="display:none;">';
						sHtml += '	<h2 class="lineTitle"><span> ' + coviDic.dicMap["lbl_TempSave"] +coviDic.dicMap["lbl_task_task"]+'</span><span id="tempTaskCnt">(0)</span></h2>'; //임시저장 업무
						sHtml += '	<div id="tempTaskListContainer" class="taskListCont"></div>';
						sHtml += '</div>';
						
						$("#itemContainer").html(sHtml);
					} 
					setSearchResult(data);
				}
			}else{
				Common.Warning(coviDic.dicMap["msg_ErrorOccurred"]); //오류가 발생했습니다.
			}
		}
		,error:function(response, status, error){
		     CFN_ErrorAjax("/groupware/task/getSearchAll.do", response, status, error);
		}
	});
}

//폴더 조회 결과 셋팅
function setFolderItemResult(folderObj){
	/*g_ParentFolderID = folderObj.FolderInfo.ParentFolderID;
	
	focusCurrentFolder(); //좌측트리에서 현재 폴더에 포커스
	
	$("#folderName").text(folderObj.FolderInfo.DisplayName);*/
	
	
	$("#folderListContainer").html(getFolderListHTML(folderObj.FolderList));
	$("#taskListContainer").html(getTaskListHTML(folderObj.TaskList));
	$("#tempTaskListContainer").html(getTempTaskListHTML(folderObj.TempTaskList));

	setTitleWidth();
}

//전체 검색 결과 바인딩
function setSearchResult(searchObj){
	$("#folderListContainer").html(getFolderListHTML(searchObj.FolderList));
	$("#taskListContainer").html(getTaskListHTML(searchObj.TaskList));
	$("#tempTaskListContainer").html(getTempTaskListHTML(searchObj.TempTaskList));
}

//폴더 리스트 HTML 그리기
function getFolderListHTML(folderList){
	if(folderList.length <= 0){
		$("#folderDiv").hide();
		$("#taskDiv").removeClass("mt25");
		return "";
	}else{
		$("#folderDiv").show();
		$("#folderCnt").text("("+folderList.length+")");
	}
	
	var listHTML = '';
	listHTML += '<ul id="folderListUL" class="folderList clearFloat">';
	
	$.each(folderList, function(idx,obj){
		var stateClass = ( obj.FolderStateCode == "Process" ? "colorTheme" : "" );
		var isOwner = obj.OwnerCode == userCode ? "Y":"N";
		
		listHTML += '<li>';
		listHTML += '		<a onclick="getFolderItem(\''+obj.FolderID +'\',\''+ isOwner +'\')"> <p>';
		listHTML += '			<span class="tit" title="'+ obj.DisplayName +'">'+ obj.DisplayName +'</span>';
		listHTML += '			<span class="txt '+ stateClass +'">' + obj.FolderState + ((obj.FolderStateCode == "Complete" || obj.FolderProgress == ""|| obj.FolderProgress == null)? "" :('('+obj.FolderProgress+'%)')) +'</span>';
		listHTML += '		</p> </a> ';
		
		listHTML += '	<div class="addFuncBox type02">';
		listHTML += '		<a class="btnAddFunc type02 " onclick="clickContextBtn(this)">ContextMenu</a>';
		listHTML += '		<ul class="addFuncLilst ">';
		if(obj.OwnerCode == userCode){
			listHTML += '			<li><a class="icon-move" onclick="moveFolder(\''+obj.FolderID +'\')">'+coviDic.dicMap["lbl_Move"]+'</a><span class="icon-arrowLeft"></span></li>'; //이동
		}
		if(obj.RegisterCode==userCode || obj.OwnerCode == userCode){
			listHTML += '			<li><a class="icon-remove" onclick="deleteFolder(\''+obj.FolderID +'\')">'+Common.getDic("lbl_delete")+'</a></li>'; //삭제
			listHTML += '			<li><a class="icon-setting" onclick="goFolderSetPopup(\''+obj.FolderID +'\',\'Y\',\''+obj.ParentFolderID +'\',\''+g_isSearch +'\')">'+coviDic.dicMap["lbl_Setting"]+'</a></li>'; //설정
		}else{
			listHTML += '			<li><a class="icon-setting" onclick="goFolderSetPopup(\''+obj.FolderID +'\',\'N\',\''+obj.ParentFolderID +'\',\''+g_isSearch +'\')">'+coviDic.dicMap["lbl_Setting"]+'</a></li>'; //설정
		}
		listHTML += '		</ul>';
		listHTML += '	</div>';
		
		if(obj.IsShare =="Y"){
			listHTML += '	<div class="folderTool">';
			listHTML += '		<a class="btnFolderTool" onclick="getFolderShareMember(\''+ obj.FolderID +'\', this)"></a>';
			listHTML += '		<div class="graphToolTip" id="shareTargetDiv'+obj.FolderID +'"></div>';
			listHTML += '	</div>';
		}
		listHTML += '</li>';
	});
	listHTML += '</ul>';
	
	return listHTML;
}

//공유 폴더의 공유 대상 조회
function getFolderShareMember(folderID, objThis){
	if($("#shareTargetDiv"+folderID).text() == ""){
			$.ajax({
				url:"/groupware/task/getFolderShareMember.do",
				type:"POST",
				async: false,
				data:{
					"FolderID": folderID
				},
				success:function(data){
					if(data.status=='SUCCESS'){
						var shareMember = '';
						
						$.each(data.list,function(idx,obj){ 
							var name = obj.Type=='UR'? String.format("{0}({1})",obj.Name,obj.DeptName) : obj.Name;
							
							if(idx != data.list.length - 1){
								shareMember += name +",";
							}else{
								shareMember += name;
							}
						})
						
						$("#shareTargetDiv"+folderID).text(shareMember);
					}else{
						Common.Warning(coviDic.dicMap["msg_ErrorOccurred"]); //오류가 발생했습니다.
					}
				}
				,error:function(response, status, error){
				     CFN_ErrorAjax("/groupware/task/getFolderShareMember.do", response, status, error);
				}
			});
	}

	if($(objThis).hasClass('active')){
		$(objThis).removeClass('active');
		$(objThis).closest('.folderTool').removeClass('active');
	}else {
		$(objThis).addClass('active');
		$('.folderTool').removeClass('active');
		var len = $(objThis).siblings('.graphToolTip').text().length * 15;
		 $(objThis).siblings('.graphToolTip').css('width', len);
		$(objThis).closest('.folderTool').addClass('active');
	}
}


//업무 리스트 HTML 그리기
function getTaskListHTML(taskList){
	if(taskList.length <= 0){
		$("#taskDiv").hide();
		return "";
	}else{
		$("#taskDiv").show();
		$("#taskCnt").text("("+taskList.length+")");
	}
	
	var listHTML = '';
	
	listHTML += '<ul id="taskListUL" class="taskFileList clearFloat">';
					
	$.each(taskList, function(idx,obj){
		var stateClass = ( obj.TaskStateCode == "Process" ? "colorTheme" : "" );
		
		//var isOwner = (obj.RegisterCode==userCode || obj.OwnerCode == userCode || obj.IsPerformer == "Y") ? "Y":"N";  // 수행자도 수정페이지로 오픈
		var isOwner = (obj.RegisterCode==userCode || obj.OwnerCode == userCode)? "Y":"N";
		
		listHTML += '<li>';
		listHTML += '		<a onclick="goTaskSetPopup(\''+obj.TaskID +'\',\''+obj.FolderID +'\',\''+ isOwner +'\')">'
		listHTML += '			<p>';
		listHTML += '					<span class="tit"  title="'+ obj.Subject +'">' + obj.Subject + '</span>';
		listHTML += '					<span class="txt ' + stateClass + '">' + obj.TaskState +((obj.TaskStateCode == "Complete" || obj.TaskProgress == "" || obj.TaskProgress == null)?"":('('+ obj.TaskProgress+'%)')) +'</span>';
		
		if(obj.IsRead == "N" || obj.IsRead == ""){
			listHTML += '			<span class="newDot"/>';
		}
		
		listHTML += '			</p>';
		if(obj.IsDelay=="Y"){
			listHTML += '					<span class="icPoint"/>';
		}
		listHTML += '		</a> ';
		if(isOwner=="Y"){ //삭제버튼 추가
			listHTML += '	<a onclick="deleteTask(\''+obj.TaskID +'\')" class="taskdel">'+Common.getDic("btn_delete")+'</a>';
		}
		listHTML += '</li> ';
		
	});
	
	listHTML += '</ul>';
	return listHTML;
}

//임시저장된 업무 리스트 HTML 그리기
function getTempTaskListHTML(taskList){
	if(taskList.length <= 0){
		$("#tempTaskDiv").hide();
		return "";
	}else{
		$("#tempTaskDiv").show();
		$("#tempTaskCnt").text("("+taskList.length+")");
	}
	
	var listHTML = '';
	
	listHTML += '<ul id="tempTaskListUL" class="taskFileList clearFloat">';
					
	$.each(taskList, function(idx,obj){
		var stateClass = ( obj.TaskStateCode == "Process" ? "colorTheme" : "" );
		var isOwner = (obj.RegisterCode==userCode || obj.OwnerCode == userCode)? "Y":"N";
		
		listHTML += '<li>';
		listHTML += '		<a onclick="goTaskSetPopup(\''+obj.TaskID +'\',\''+obj.FolderID +'\',\''+ isOwner +'\')">'
		listHTML += '			<p>';
		listHTML += '					<span class="tit"  title="'+ obj.Subject +'">' + obj.Subject + '</span>';
		listHTML += '					<span class="txt ' + stateClass + '">' + obj.TaskState + '</span>';
		
		if(obj.IsRead == "N" || obj.IsRead == ""){
			listHTML += '			<span class="newDot"/>';
		}
		
		listHTML += '			</p>';
		if(obj.IsDelay=="Y"){
			listHTML += '					<span class="icPoint"/>';
		}
		listHTML += '		</a> ';
		if(isOwner=="Y"){ //삭제버튼 추가
			listHTML += '	<a onclick="deleteTask(\''+obj.TaskID +'\')" class="taskdel">'+Common.getDic("btn_delete")+'</a>';
		}
		listHTML += '</li> ';
		
	});
	
	listHTML += '</ul>';
	return listHTML;
}
 
//상태에 따른 CSS Class 값 조회 (퍼블리싱 변경으로 주석처리)
/*function getStateClass(stateCode){
		var retClass = '';
		
		switch(stateCode.toUpperCase()){
			case 'WAITING':
				retClass = 'nemoGray';
				break;
			case 'PROCESS':
				retClass = 'nemoBlue';
				break;
			case 'COMPLETE':
				retClass = 'nemoJinGray';
				break;
		}
		
		return retClass;
}*/

//context 버튼 on/off 이벤트
function clickContextBtn(clickObj){
	if($(clickObj).hasClass('active')){
		$(clickObj).removeClass('active');
		$(clickObj).next('.addFuncLilst').removeClass('active');
	}else {
		$(clickObj).addClass('active');
		$('.addFuncLilst').removeClass('active');
		$(clickObj).next('.addFuncLilst').addClass('active');
	}
}


//해당 폴더 조회 권한 체크
function chkAuthority(){
	if(g_FolderID == "0"){
		return;
	}
	
	$.ajax({
		url:"/groupware/task/checkAuthority.do",
		type:"POST",
		data:{
			"FolderID": g_FolderID
		},
		success:function(data){
			if(data.haveAuthority!=true){
				Common.Warning(coviDic.dicMap["lbl_NoReadAuth"],"Warning",function(){ //조회권한이 없습니다.
					history.back();
				});
			}
		}
		,error:function(response, status, error){
		     CFN_ErrorAjax("/groupware/task/checkAuthority.do", response, status, error);
		}
	});
	
}


//현재 선택된 폴더에 포커스
function focusCurrentFolder(){
	if(g_IsMine=="Y"){
		$.each(personFolderTree.list, function(idx, obj){
			   if(obj.FolderID == g_FolderID){
				   personFolderTree.click(idx, "open", true);
			       return false;
			   }
			});
	}else{
		$.each(shareFolderTree.list, function(idx, obj){
			   if(obj.FolderID == g_FolderID){
				   shareFolderTree.click(idx, "open", true);
			       return false;
			   }
			});
	}
}

//session 값 저장
function setSessionStorage(sessionID, elementID){
	var saveVal = $("#"+elementID).val();
	
	window.sessionStorage.setItem(sessionID+"_"+userCode, saveVal);
}

//폴더 이동팝업
function moveFolder(folderID){
	
	Common.open("","moveFolder",coviDic.dicMap["lbl_task_folderMove"],"/groupware/task/goFolderTreePopup.do?mode=moveFolder&folderID="+folderID,"345px", "395px","iframe", true,null,null,true); //폴더 이동
}

//업무 이동팝업
function moveTask(taskID){
	Common.open("","moveTask",coviDic.dicMap["lbl_task_taskMove"],"/groupware/task/goFolderTreePopup.do?mode=moveTask&taskID="+taskID,"345px", "395px","iframe", true,null,null,true); //업무 이동
}

//업무 복사팝업
function copyTask(taskID){
	Common.open("","copyTask",coviDic.dicMap["lbl_task_taskCopy"],"/groupware/task/goFolderTreePopup.do?mode=copyTask&taskID="+taskID,"345px", "395px","iframe", true,null,null,true); //업무 복사
}

//폴더 삭제
function deleteFolder(folderID){
	Common.Confirm(coviDic.dicMap["lbl_task_deleteChildren"]+"<br>"+coviDic.dicMap["msg_AreYouDelete"],"Inform",function(result){ //하위 항목도 함께 삭제됩니다.<br>삭제하시겠습니까?
		if(result){
			$.ajax({
				type: "POST",
				url: "/groupware/task/deleteFolderData.do",
				data:{
					"FolderID": folderID,
				}
				, success : function(data){
					if(data.status=='SUCCESS'){
						Common.Inform(coviDic.dicMap["msg_50"], "Inform", function(){ //삭제되었습니다.
							setLeftTree();
							if(g_isSearch != "Y"){
								getFolderItemList();
							}else{
								getSearchAll();
							}
						});
					}else{
						Common.Warning(coviDic.dicMap["msg_ErrorOccurred"]); //오류가 발생했습니다.
					}
				}
				,error:function(response, status, error){
           	     CFN_ErrorAjax("/groupware/task/deleteFolderData.do", response, status, error);
           	}
			});
		}
	});
}


//빈값 체크
function isNull(value, defaultValue){
	if(typeof value == 'undefined' || value == null || value == 'undefined'){
		return defaultValue;
	}
	return value;
}

//제목 바인딩 시 제목 가로 길이 지정
function setTitleWidth(){
	var h2W = $('.boardTitle .boardTitData').innerWidth() + 20;
	$('.boardTitle h2').attr('style', 'width:calc(100% - ' + h2W + 'px);' )
}

//폴더 수정/조회 팝업 
function goFolderSetPopup(folderID, isOwner, parentFolderID, isSearch){
	var height = isOwner=="Y"? "490px": "400px";
	
	//폴더관리
	Common.open("","folderSet",coviDic.dicMap["lbl_task_folderManage"],"/groupware/task/goFolderSetPopup.do?mode=Modify&parentFolderID="+parentFolderID+"&isOwner="+isOwner+"&folderID="+folderID+"&isSearch="+isSearch,"495px", height ,"iframe", true,null,null,true);
}

//업무 수정/조회 팝업 
function goTaskSetPopup(taskID,folderID,isOwner,isSearch){
	var height = isOwner=="Y"? "650px": "570px";
	
	//업무관리
	Common.open("","taskSet",coviDic.dicMap["lbl_task_taskManage"],"/groupware/task/goTaskSetPopup.do?mode=Modify&isOwner="+isOwner+"&taskID="+taskID+"&folderID="+folderID+"&isSearch="+isSearch,"950px", height ,"iframe", true,null,null,true);
}

//위로
function clickBtnPrevStep(){
	CoviMenu_GetContent('/groupware/layout/task_ItemList.do?CLSYS=task&CLMD=user&CLBIZ=Task&folderID='+g_ParentFolderID+"&isMine="+g_IsMine);
}

//폴더 추가
function clickBtnFolderAdd(){
	//폴더추가
	Common.open("","folderSet",coviDic.dicMap["lbl_task_addFolder"],"/groupware/task/goFolderSetPopup.do?mode=Add&parentFolderID="+g_FolderID+"&isOwner="+g_IsMine ,"495px", "500px","iframe", true,null,null,true);
}

//업무 추가
function clickBtnTaskAdd(){
	//업무추가
	Common.open("","taskSet",coviDic.dicMap["lbl_task_addTask"],"/groupware/task/goTaskSetPopup.do?mode=Add&isOwner="+g_IsMine+"&folderID="+g_FolderID ,"950px", "650px","iframe", true,null,null,true);
}

//새로고침
function refresh(){
	CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
}

// 폴더/업무 팝업 내부 사용-----------------------------------------------------------------------------------------------------

//표시 버튼 셋팅
function setButton(mode, haveModifyAuth, isTempSave){
	if(mode=="ADD"){
		$("a[name='registBtn']").show();
		$("a[name='tempSaveBtn']").show();			
		$("a[name='cancelBtn']").show();
	}else if( mode == "MODIFY" && haveModifyAuth == "Y"){
		$("a[name='saveBtn']").show();
		$("a[name='cancelBtn']").show();
		
		if(isTempSave && isTempSave === 'Y') {		// 임시저장 -> 등록 : 임시저장된 업무일때만, 등록버튼 나타남
			$("a[name='tempRegistBtn']").show();	
		}	
	}else{
		$("a[name='confirmBtn']").show();
	}
}
// 추가 및 수정 시 validation chk
function chekValidation(mode){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	if($("#nameWrite").val() == ''){
		Common.Warning(coviDic.dicMap["msg_028"]); //제목을 입력하세요
		// TODO focus 주기
		return false;
	}else if(coviCtrl.getSelected('stateWrite').val == ''){
		Common.Warning(coviDic.dicMap["msg_task_selectState"]); //상태를 선택하세요
		return false;
	}else if($("#performerList").children().length == 0 && window.location.pathname.endsWith("goTaskSetPopup.do")){
		Common.Warning(coviDic.dicMap["msg_task_plzEnterPerformer"]); //수행자를 선택하세요
		return false;
	}else{
		if($("#periodWrite_StartDate").val() > $("#periodWrite_EndDate").val()){
			Common.Warning(coviDic.dicMap["msg_StartDateCannotAfterEndDate"]);	// 시작일은 종료일 보다 이후일 수 없습니다.
			return false;
		} else if($("#periodWrite_StartDate").val() == $("#periodWrite_EndDate").val()){
			if(coviCtrl.getSelected('periodWrite [name=startHour]').val > coviCtrl.getSelected('periodWrite [name=endHour]').val){
				Common.Warning(coviDic.dicMap["msg_StartDateCannotAfterEndDate"]);	// 시작일은 종료일 보다 이후일 수 없습니다.
				return false;
			} else if(coviCtrl.getSelected('periodWrite [name=startHour]').val == coviCtrl.getSelected('periodWrite [name=endHour]').val){
				if(coviCtrl.getSelected('periodWrite [name=startMinute]').val > coviCtrl.getSelected('periodWrite [name=endMinute]').val){
					Common.Warning(coviDic.dicMap["msg_StartDateCannotAfterEndDate"]);	// 시작일은 종료일 보다 이후일 수 없습니다.
					return false;
				}
			}
		}
		
		if((mode == "Task" && t_haveModifyAuth != null && t_haveModifyAuth != "Y")
			|| (mode == "Folder" && f_haveModifyAuth != null && f_haveModifyAuth != "Y")){
			Common.Warning(coviDic.dicMap["msg_noModifyACL"]); //수정 권한이 없습니다.
			return false;
		}
		return true;
	}
}

//조직도 팝업 오픈
function orgChartPopup(type,funcName,openerID){
	//조직도
	parent.Common.open("","orgmap_pop",coviDic.dicMap["lbl_DeptOrgMap"],"/covicore/control/goOrgChart.do?type="+type+"&callBackFunc="+funcName+"&openerID="+openerID,"1000px","580px","iframe",true,null,null,true);
}

//조직도 콜백 함수(공유자 지정)
function OrgCallBack_SetShareMember(data){
	//var isMySelf = false; //본인 스스로를 지정한 경우 (상위에서 지정된 경우에는 지정되어 있을 수 있지만 스스로를 공유자로 추가할 수는 없음)
	var orgObj = $.parseJSON(data);
	var arrMember = [];
	
	$.each(orgObj.item,function(idx,obj){
		var type = obj.itemType.toUpperCase() == "USER" ? "UR" : (obj.AN == obj.CompanyCode ? "CM": "GR" );
		
		/* if(obj.AN == userCode){
			isMySelf = true;
			return true; 
		} */
		
		var memObj = 	{
           	 "Code": obj.AN,
           	 "Type": type,
           	 "Name": CFN_GetDicInfo(obj.DN,lang),
           	 "DeptName":  CFN_GetDicInfo( isNull(obj.ExGroupName,''),lang )
		}
		
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
		
		var memObj = 	{
				"Code": obj.AN,
				"Type": 'UR',
				"Name": CFN_GetDicInfo(obj.DN,lang),
				"DeptName":  CFN_GetDicInfo( isNull(obj.ExGroupName,''),lang )
		}
		
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

//폴더 설정 시 사용하는 컨트롤 바인딩 (공통 컨트롤: selecBox, autoComplete)
function setFolderControl(){
	var initInfos;
	coviCtrl.renderAjaxSelect(initInfos = [ {
	    target : 'stateWrite',	
	    codeGroup : 'FolderState',
	    defaultVal : 'Waiting',
	    width : '160',	
	    onclick : ''
	}], '', lang);
	
	coviCtrl.setCustomAjaxAutoTags(
			'shareMember', //타겟
			'/covicore/control/getAllUserGroupAutoTagList.do', //url 
			{
				labelKey : 'Name',
				valueKey : 'Code',
				minLength : 1,
				useEnter : false,
				multiselect : true,
		    	select : function(event,ui) {
		    		 if(ui.item.value == userCode){
		    			Common.Warning(coviDic.dicMap["msg_task_notYourself"]); //공유자로 본인을 지정할 수 없습니다.
		    		}else{ 
		    		setMember("shareMember",f_haveModifyAuth,[{
		    		                    	 "Code": ui.item.value,
		    		                    	 "Type": ui.item.Type,
		    		                    	 "Name":ui.item.label,
	    			                    	 "DeptName":ui.item.DeptName
	    			                     }]);
		    		 } 
		    		
		    		ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
		    	}
			}
	);
}

//폴더 추가/수정 시 필요한 Data를 JSON 형식으로 생성
function getFolderObj(mode){
	var folderObj;
	
	if(coviCtrl.getSelected('stateWrite').val == "Complete"){
		$("#progressWrite").val("100");
	}
	
	if($("#progressWrite").val() == "100" && coviCtrl.getSelected('stateWrite').val != "Complete" ){
		coviCtrl.setSelected('stateWrite', "Complete");
	}
	if(mode.toUpperCase()=="I"){ //추가
		folderObj = { 
				  "ParentFolderID": f_parentFolderID,
				  "DisplayName": $("#nameWrite").val(),
				  "State": coviCtrl.getSelected('stateWrite').val,
				  "Description": $("#descriptionWrite").val(),
				  "Progress": $("#progressWrite").val() == "" ? "0" : $("#progressWrite").val(),
				  "RegistCode":  userCode,
				  "OwnerCode": isNull(f_parentInfoObj.OwnerCode,userCode), //내가 하는 일 폴더는 ownerCode가 넘어오지 않음
				  "ShareMember": getMemberList("shareMember")
				};
	}else if(mode.toUpperCase()=="U"){ //수정
		folderObj = {
				  "FolderID": f_folderID,
				  "ParentFolderID": f_parentFolderID,
				  "DisplayName": $("#nameWrite").val(),
				  "State": coviCtrl.getSelected('stateWrite').val,
				  "Progress": $("#progressWrite").val() == "" ? "0" : $("#progressWrite").val(),
				  "Description": $("#descriptionWrite").val(),
				  "ShareMember": getMemberList("shareMember")
				};
	}
	
	return folderObj;
}


function saveFolder(mode){
	if(!chekValidation("Folder")){
		return; 
	}
	
	parent.Common.Progress(Common.getDic('msg_apv_008'));
	
	$.ajax({
		url: '/groupware/task/saveFolderData.do',
		type: 'post',
		data:{
			"mode" : mode,
			"folderStr": JSON.stringify(getFolderObj(mode)),
			"FolderID": f_folderID
		},
	    success: function (res) {
	    	if(res.status=='SUCCESS'){
	    		//추가/생성 시 동일 폴더명 체크 
				if(res.chkDuplilcation.isDuplication=="Y"){
					var message =  ( mode =="I" ? coviDic.dicMap["msg_task_insertRenameFolder"] : coviDic.dicMap["msg_task_saveRenameFolder"]  ) // 동일한 이름의 폴더가 존재하여<br>[{0}]로 등록되었습니다. : 동일한 이름의 폴더가 존재하여<br>[{0}]로 저장되었습니다. 
					message = String.format(message, res.chkDuplilcation.saveName);
					
					Common.Inform(message, "Inform", function(){
						Common.Close();
		    			parent.setLeftTree();
		    			if(f_isSearch != "Y"){
		    				parent.getFolderItemList();
						}else{
							parent.getSearchAll();
						}
					});
				}else{
					Common.Inform( ( mode =="I" ? coviDic.dicMap["msg_insert"] : coviDic.dicMap["msg_37"]  )  ,"Inform",function(){// 등록되었습니다 : 저장되었습니다.
		    			Common.Close();
		    			parent.setLeftTree();
		    			if(f_isSearch != "Y"){
		    				parent.getFolderItemList();
						}else{
							parent.getSearchAll();
						}
		    		});	
				}
			}else{
				Common.Warning(common.getDic('msg_ErrorOccurred')); //오류가 발생했습니다.
			}    	
	
	    },
		error:function(response, status, error){
			CFN_ErrorAjax("saveFolderData.do", response, status, error);
		}
	});
}


//상위 폴더 정보 조회 (공유자 정보는 상위에 속하는 모든 폴더에서 조회)
function setParentFolderData(parentFolderID){
	$.ajax({
		url:"/groupware/task/getParentFolderData.do",
		type:"POST",
		data : {
			"ParentFolderID" : parentFolderID,
			"isMine": "Y" //폴더 추가시 상위 정보는 최상위일 경우 무조건 Y
		},
		success:function(data){
			f_parentInfoObj = data.folderData;
			setMember("shareMember",f_haveModifyAuth,data.shareMemberList);
		}
	});
}

//수정 시 폴더 정보 조회 및 바인딩 함수 호출
function setFolderData(folderID){
	var folderObj = getFolderData(folderID);
	
	setFolderDataBind(folderObj.folderInfo); //폴더 정보를 input 또는 p태그에 바인딩
	setMember("shareMember",f_haveModifyAuth,folderObj.shareMemberList);
}


//폴더 정보 조회
function getFolderData(folderID){
	var returnData; 
	
	$.ajax({
		url:"/groupware/task/getFolderData.do",
		type:"POST",
		async: false,
		data : {
			"FolderID" : folderID
		},
		success:function(data){
			returnData =  data;
		},error:function(response, status, error){
		     CFN_ErrorAjax("/groupware/task/getFolderData.do", response, status, error);
		}
	});
	
	return returnData;
}


//수정 시 데이터 바인딩
function setFolderDataBind(folderObj){
	$("#registDate").text(new Date(CFN_TransLocalTime(folderObj.RegistDate)).format("yyyy.MM.dd HH:mm") +" "+ Common.getSession("UR_TimeZoneDisplay"));
	$("#registerName").text(folderObj.RegisterName);
	
	if(f_haveModifyAuth=="Y"){ //수정이 가능한 경우 write 요소에 바인딩
		
		$("#nameWrite").val(folderObj.DisplayName);
		coviCtrl.setSelected('stateWrite', folderObj.State);
		$("#descriptionWrite").val(folderObj.Description);
		$("#progressWrite").val(folderObj.Progress);
		
	}else{ //수정이 불가능한 경우 read 요소에 바인딩
		
		$("#nameRead").text(folderObj.DisplayName);
		$("#stateRead").text(folderObj.FolderState);
		$("#descriptionRead").text(folderObj.Description);
		$("#progressRead").text(folderObj.Progress);
		
	}
	//setTitleWidth();
}


//업무 정보 셋팅
function setTaskData(){
	setTaskDataBind();
	setMember("performer", t_haveModifyAuth, t_TaskInfoObj.performerList);
	setComment(t_TaskInfoObj); //댓글 
	
	g_fileList = t_TaskInfoObj.fileList;
}

//업무 정보 조회
function getTaskData(taskID, folderID){
	$.ajax({
		url:"/groupware/task/getTaskData.do",
		type:"POST",
		async: false,
		data : {
			"TaskID" : taskID,
			"FolderID" : folderID
		},
		success:function(data){
			t_TaskInfoObj = data;
	
			if (JSON.stringify(t_TaskInfoObj.performerList).indexOf(userCode) > -1) {
				t_haveModifyAuth = "Y";
				t_isPerformer = 'Y';
			}
		},
		error:function(response, status, error){
		     CFN_ErrorAjax("/groupware/task/getTaskData.do", response, status, error);
		}
	});
}

function setTaskDataBind(){
	var taskObj = t_TaskInfoObj.taskInfo;
	
	$("#registDate").text(new Date(CFN_TransLocalTime(taskObj.RegistDate)).format("yyyy.MM.dd HH:mm") +" "+ Common.getSession("UR_TimeZoneDisplay"));
	$("#registerName").text(taskObj.RegisterName);
	t_isTempSave = taskObj.IsTempSave;		// 임시저장인지 여부확인
	
	if(t_haveModifyAuth=="Y" && t_isOwner == "Y"){ //수정이 가능한 경우 write 요소에 바인딩
		$("#nameWrite").val(taskObj.Subject);
		$("#periodWrite").find("[id=periodWrite_StartDate]").val(isNull(CFN_TransLocalTime(taskObj.StartDate).split(" ")[0],'').replaceAll('-','.'));
		$("#periodWrite").find("[id=periodWrite_EndDate]").val(isNull(CFN_TransLocalTime(taskObj.EndDate).split(" ")[0],'').replaceAll('-','.'));
		coviCtrl.setSelected('periodWrite'+' [name=startHour]', CFN_TransLocalTime(taskObj.StartDate).split(" ")[1].split(":")[0]);
		coviCtrl.setSelected('periodWrite'+' [name=startMinute]', CFN_TransLocalTime(taskObj.StartDate).split(" ")[1].split(":")[1]);
		coviCtrl.setSelected('periodWrite'+' [name=endHour]', CFN_TransLocalTime(taskObj.EndDate).split(" ")[1].split(":")[0]);
		coviCtrl.setSelected('periodWrite'+' [name=endMinute]', CFN_TransLocalTime(taskObj.EndDate).split(" ")[1].split(":")[1]);
		coviCtrl.setSelected('stateWrite', taskObj.TaskStateCode);
		$("#hidDescription").val(taskObj.Description);
		$("#progressWrite").val(taskObj.Progress);
		
		// Description
		if(!/<[a-z][\s\S]*>/i.test(taskObj.Description)){
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

			// TODO 향후 개선 필요
		/*	setTimeout(function(){
				coviEditor.setBody(g_editorKind, 'tbContentElement', taskObj.Description);
			}, 500);*/
		}
	}
	else if(t_haveModifyAuth=="Y" && t_isOwner == "N"){
		$("#nameRead").text(taskObj.Subject);
		$("#periodRead").text(isNull(taskObj.StartDate,'').replaceAll('-','.')+" ~ "+ isNull(taskObj.EndDate,'').replaceAll('-','.'));
		$("#stateRead").text(taskObj.TaskState);
		$("#descriptionRead").html(taskObj.Description);
		$("#progressWrite").val(taskObj.Progress);
	}
	else{ //수정이 불가능한 경우 read 요소에 바인딩
		$("#nameRead").text(taskObj.Subject);
		$("#periodRead").text(isNull(taskObj.StartDate,'').replaceAll('-','.')+" ~ "+ isNull(taskObj.EndDate,'').replaceAll('-','.'));
		$("#stateRead").text(taskObj.TaskState);
		$("#descriptionRead").html(taskObj.Description);
		$("#progressRead").html(taskObj.Progress);
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
		if(haveModifyAuth == "Y" && (
				(typeof t_mode != 'undefined' && (t_mode == "ADD" || (t_mode == "MODIFY" && t_isOwner == "Y"))) || 
				(typeof f_mode != 'undefined' && (f_mode == "ADD" || (f_mode == "MODIFY" && f_isOwner == "Y")))
		)){
			listHTML +='	<a class="btnListRemove" onclick="removeMember(this)"></a>';
		}
		listHTML +='	</div>';
		listHTML +='</li>';
	});
	
	$("#"+target+"List").append(listHTML);
	
	if(haveDup){
		Common.Warning(coviDic.dicMap["msg_task_notDupAdd"]);  //특정 사용자 또는 그룹을 중복 추가할 수 없습니다
	}
}

//공유자 목록 조회
function getMemberList(target){
	var arrMember = [];
	
	if(target.toUpperCase()=="SHAREMEMBER"){
		$("ul#"+target+"List").children("li").each(function(idx,obj){
			arrMember.push(	{
	           	 "Code": $(obj).attr("code"),
	           	 "Type": $(obj).attr("type")
			});
		});
	}else{
		$("ul#"+target+"List").children("li").each(function(idx,obj){
			
			arrMember.push(	{
	           	 "PerformerCode": $(obj).attr("code"),
			});
		});
	}
	
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
	if(!chekValidation("Task")){
		return; 
	}
	
	parent.Common.Progress(Common.getDic('msg_apv_008'));
	
	var formData = new FormData();		// [Added][FileUpload]
	
	formData.append("mode", mode);
	formData.append("taskStr", JSON.stringify(getTaskObj(mode)));
	
	if (t_isOwner == 'Y'){
		formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
	    for (var i = 0; i < coviFile.files.length; i++) {
	    	if (typeof coviFile.files[i] == 'object') {
	    		formData.append("files", coviFile.files[i]);
	        }
	    }
	    formData.append("fileCnt", coviFile.fileInfos.length);
	}
	
   
	$.ajax({
		url: '/groupware/task/saveTaskData.do',
		type: 'post',
		data: formData,
		contentType: false,
		processData : false,
	    success: function (res) {
	    	if(res.status=='SUCCESS'){
	    		// 추가/생성 시 동일 업무명 체크 
				if(res.chkDuplilcation.isDuplication=="Y"){
					var message =  ( mode =="I" || mode =="IT" ? coviDic.dicMap["msg_task_insertRenameTask"] : coviDic.dicMap["msg_task_saveRenameTask"]  ) // 동일한 이름의 업무가 존재하여<br>[{0}]로 등록되었습니다. : 동일한 이름의 업무가 존재하여<br>[{0}]로 저장되었습니다. 
					message = String.format(message, res.chkDuplilcation.saveName);
					
					Common.Inform(message, "Inform", function(){
						if(t_isSearch != "Y"){
		    				parent.getFolderItemList();
						}else{
							parent.getSearchAll();
						}
		    			Common.Close();
					});
				}else{
					Common.Inform(( mode =="I" || mode =="IT" ? coviDic.dicMap["msg_insert"] : coviDic.dicMap["msg_37"]  ),"Inform",function(){
						if(t_isSearch != "Y"){
		    				parent.getFolderItemList();
						}else{
							parent.getSearchAll();
						}
		    			Common.Close();
		    		});	
				}
			}else{
				Common.Error(coviDic.dicMap["msg_ErrorOccurred"]); //오류가 발생했습니다.
			}
	    },
       error:function(response, status, error){
		CFN_ErrorAjax("saveFolderData.do", response, status, error);
	   }
	});
}

//업무 추가/수정 시 필요한 Data를 JSON 형식으로 생성
function getTaskObj(mode){
	var taskObj; 
	var period = coviCtrl.getDataByParentId('periodWrite');
	
	var StartDateTime = CFN_TransServerTime(period.startDate + " " + period.startHour + ":" + period.startMinute);
	var EndDateTime = CFN_TransServerTime(period.endDate + " " + period.endHour + ":" + period.endMinute); 
	
	var desc;

	if(coviCtrl.getSelected('stateWrite').val == "Complete"){
		$("#progressWrite").val("100");
	}
	if($("#progressWrite").val() == "100" && coviCtrl.getSelected('stateWrite').val != "Complete" ){
		coviCtrl.setSelected('stateWrite', "Complete");
	}	
	if(mode.toUpperCase()=="I" || mode.toUpperCase()=="IT"){ //추가, 임시저장
		taskObj = { 
				  "FolderID": t_folderID,
				  "Subject": $("#nameWrite").val(),
				  "State": coviCtrl.getSelected('stateWrite').val,
				  "Progress": $("#progressWrite").val() == "" ? "0" : $("#progressWrite").val(),
				  "StartDate": StartDateTime,
				  "EndDate":  EndDateTime,
				  "InlineImage": getTaskInlineImage(),
				  "Description": getTaskDescription(),
				  "RegisterCode": userCode,
				  "OwnerCode":   isNull(t_folderInfoObj.OwnerCode,userCode), //내가 하는 일 폴더는 ownerCode가 넘어오지 않음
				  "PerformerList": getMemberList("performer")
				};
	}else if(mode.toUpperCase()=="U" || mode.toUpperCase()=="UT"){ //수정, 등록(임시저장->등록)
		taskObj = {
				  "TaskID": t_taskID,
				  "FolderID": t_folderID,
				  "Subject": (t_isPerformer == 'Y') ? $("#nameWrite").val() : t_TaskInfoObj.taskInfo.Subject,
				  "State": (t_isPerformer == 'Y') ? coviCtrl.getSelected('stateWrite').val : t_TaskInfoObj.taskInfo.TaskStateCode,
				  "Progress": $("#progressWrite").val() == "" ? "0" : $("#progressWrite").val(),
				  "StartDate": (t_isPerformer == 'Y') ? StartDateTime : t_TaskInfoObj.taskInfo.StartDate,
				  "EndDate":  (t_isPerformer == 'Y') ? EndDateTime : t_TaskInfoObj.taskInfo.EndDate,
				  "InlineImage": getTaskInlineImage(),
				  "Description": (t_isPerformer == 'Y') ? getTaskDescription() : t_TaskInfoObj.taskInfo.Description,
				  "PerformerList": getMemberList("performer")
				};
	}
	
	return taskObj;
}

//업무 추가/수정 시 사용하는 컨트롤 바인딩
function setTaskControl(folderID){
	var timeInfos = {
			width : "100",
			H : "1,2,3,4,8",
			W : "1,2,3,4", //주 선택
			M : "1,2,3,6", //달 선택
			Y : "1" //년도 선택
		};
	
	var initInfos = {
			useCalendarPicker : 'Y',	//캘린더 paicker의 사용여부로, 날짜를 선택하는 달력의 사용여부를 묻는 옵션입니다.
			useTimePicker : 'Y',	//time picker의 사용여부로, 00:00 부터 23:00 까지의 시간을 선택하는 select box의 사용여부를 묻는 옵션입니다.
			useSeparation : 'Y', // 시간 선택 시 시와 분 분리 여부를 묻는 옵션입니다.
			minuteInterval : 5,
			useBar : 'Y'	//time picker 사이의 bar의 사용여부를 묻는 옵션입니다.
		};
	
	var nowHour = new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat));
	var nowMinite = AddFrontZero(Math.ceil((new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat)).getMinutes())/5)*5, 2);
	
	if(nowMinite >= 60) {
		nowHour.setHours(new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat)).getHours() + 1);	
		nowMinite = AddFrontZero(0, 2);
	}
	
	coviCtrl.renderDateSelect('periodWrite', timeInfos, initInfos);
	
	coviCtrl.setSelected('periodWrite [name=datePicker]', "select");
	coviCtrl.setSelected('periodWrite [name=startHour]', AddFrontZero(nowHour.getHours(), 2));
	coviCtrl.setSelected('periodWrite [name=startMinute]', nowMinite);
	
	nowHour.setTime(nowHour.getTime() + (60*60*1000));
	
	$("#detailDateCon_EndDate").val(schedule_SetDateFormat(nowHour, "."));
	coviCtrl.setSelected('periodWrite [name=endHour]', AddFrontZero(nowHour.getHours(), 2));
	coviCtrl.setSelected('periodWrite [name=endMinute]', nowMinite);
	
	coviCtrl.renderAjaxSelect(initInfos = [ {
	    target : 'stateWrite',	
	    codeGroup : 'TaskState',
	    defaultVal : 'Waiting',
	    width : '160',	
	    onclick : ''
	}], '', lang);
	
	coviCtrl.setCustomAjaxAutoTags(
			'performer', //타겟
			'/groupware/task/getShareUseList.do?FolderID='+folderID, //url 
			{
				labelKey : 'Name',
				valueKey : 'Code',
				minLength : 1,
				useEnter : false,
				multiselect : true,
		    	select : function(event,ui) {
		    		setMember('performer',t_haveModifyAuth,[{
		    		                    	 "Code": ui.item.value,
		    		                    	 "Type": 'UR',
		    		                    	 "Name":ui.item.label,
	    			                    	 "DeptName":ui.item.DeptName
	    			                     }]);
		    		
		    		ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
		    	}
			}
	);

}

//조회일 경우 댓글 바인딩
function setComment(taskObj){
	var userId = sessionObj["USERID"];
	var isOwner = (taskObj.taskInfo.RegisterCode==userCode || taskObj.taskInfo.OwnerCode == userCode)? "Y":"N";
	var receiverList = taskObj.taskInfo.RegisterCode;
	
	if(taskObj.taskInfo.RegisterCode != taskObj.taskInfo.OwnerCode){
		receiverList += ";"+  taskObj.taskInfo.OwnerCode;
	}
	
	var msgContext = String.format(coviDic.dicMap["msg_task_replyMessage"], taskObj.taskInfo.Subject, sessionObj["USERNAME"] ); // {0} 업무에 대해서 {1}님이 댓글을 남기셨습니다.
	//연결 URL
	var goToUrl = String.format("{0}/groupware/task/goTaskSetPopup.do?mode=Modify&isOwner={1}&taskID={2}&folderID={3}&isSearch=&CFN_OpenLayerName=taskSet", Common.getGlobalProperties("smart4j.path"), isOwner, taskObj.taskInfo.TaskID, taskObj.taskInfo.FolderID);
	var mobileUrl = String.format("/groupware/mobile/task/view.do?isowner={0}&taskid={1}&folderid={2}", isOwner, taskObj.taskInfo.TaskID, taskObj.taskInfo.FolderID);
	
	var messageSetting = {
		SenderCode : userId,
		RegistererCode : userId,
		ReceiversCode : receiverList,
		MessagingSubject : taskObj.taskInfo.Subject, //댓글 알림
		MessageContext : msgContext, 
		ReceiverText :  taskObj.taskInfo.Subject ,  //댓글 알림   
		GotoURL: goToUrl,
	    PopupURL: goToUrl,
	    MobileURL: mobileUrl,
	    Width:"700",
	    Height:"980",
		ServiceType : "Task",
		MsgType : "TaskComment"
	};
	
	coviComment.load('commentView', 'Task', taskObj.taskInfo.TaskID, messageSetting);
}

function goShareUserListPopup(folderID){
	//수행자 지정
	parent.Common.open("","shareUserList",coviDic.dicMap["lbl_task_selectPerformer"],"/groupware/task/goShareUserListPopup.do?folderID="+folderID + "&callback=goShareUserListPopup_callBack","500px", "600px","iframe", true,null,null,true);
}

function goShareUserListPopup_callBack(data){
	var performerObj = $.parseJSON(data);
	
	setMember('performer',t_haveModifyAuth,performerObj);
}

//폴더 삭제
function deleteTask(taskID){
	Common.Confirm(coviDic.dicMap["msg_AreYouDelete"],"Inform",function(result){ //삭제하시겠습니까?
		if(result){
			$.ajax({
				type: "POST",
				url: "/groupware/task/deleteTaskData.do",
				data:{
					"TaskID": taskID,
				}
				, success : function(data){
					if(data.status=='SUCCESS'){
						Common.Inform(coviDic.dicMap["msg_50"], "Inform", function (){ //삭제되었습니다.
							if(g_isSearch != "Y"){
			    				parent.getFolderItemList();
							}else{
								parent.getSearchAll();
							}
							Common.Close();
						});
					}else{
						Common.Warning(coviDic.dicMap["msg_ErrorOccurred"]); //오류가 발생했습니다.
					}
				}
				,error:function(response, status, error){
           	     CFN_ErrorAjax("/groupware/task/deleteTaskData.do", response, status, error);
           	}
			});
		}
	});
}

//object내부 데이터를 하나씩 재귀호출로 삭제하면서 시도
function downloadAll( pFileList ){
	var fileList = pFileList.slice(0);	//array 객체 복사용
	Common.downloadAll(fileList);
}