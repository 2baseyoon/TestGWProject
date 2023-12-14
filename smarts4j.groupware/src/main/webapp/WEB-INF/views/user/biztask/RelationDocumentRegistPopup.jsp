<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>
	<input type="hidden" id="hidDocLinks"/>
	<div class="layer_divpop ui-draggable workportal-documentadd" id="relationDocumentRegist" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="rowTypeWrap formWrap">
					<dl>
						<dt><spring:message code="Cache.lbl_task_task"/> <spring:message code="Cache.lbl_selection"/></dt> <!-- 업무 선택 -->
						<dd>
							<span class="radioStyle04"><input type="radio" id="tfRadioBtn" name="radioTask" value="TF" checked><label for="tfRadioBtn"><span class="mr5"><span></span></span><spring:message code="Cache.lbl_Project"/></label></span> <!-- 프로젝트 -->
							<span class="radioStyle04"><input type="radio" id="taskRadioBtn" name="radioTask" value="Task"><label for="taskRadioBtn"><span class="mr5"><span></span></span><spring:message code="Cache.lbl_TaskManage"/></label></span> <!-- 업무관리 -->
							<a href="#" id="addTaskBtn" class="btnPlusAdd"><spring:message code="Cache.lbl_NewWork"/></a> <!-- 새 업무 -->
							<div class="projectSelDiv">
								<select class="selProject selectType02 mt20" name="" style="width: 100%;"></select>
							</div>
							<div class="taskSelDiv" style="display: none;">
								<select class="selProject selectType02 mt20" name="" style="width: 100%;"></select>	
							</div>
						</dd>
					</dl>
					<dl>
						<dt>카테고리</dt>
						<dd>
							<div class="projectSelDiv">
								<select class="selCategory selectType02" name="" style="width: 100%;">
									<option value=""><spring:message code="Cache.lbl_DataRoom"/></option> <!-- 자료실 -->
								</select>								
							</div>
							<div class="taskSelDiv" style="display: none;">
								<select class="selCategory selectType02" name="" style="width: 100%;"></select>
							</div>
						</dd>
					</dl>
					<dl style="display: none;">
						<dt><spring:message code="Cache.lbl_subject"/></dt> <!-- 제목 -->
						<dd>
							<input type="text" id="docSubject" class="inpFullSize">
						</dd>
					</dl>
					<dl style="display: none;">
						<dt><spring:message code="Cache.lbl_Contents"/></dt> <!-- 내용 -->
						<dd>
							<textarea id="docContent"></textarea>
						</dd>
					</dl>
					<dl style="display: none;">
						<dt><spring:message code="Cache.lbl_apv_ConDoc"/></dt> <!-- 연관문서 -->
						<dd><p class="files_title"><span class="ic_eml"></span><span class="file_name"></span></p></dd>
					</dl>
					<dl style="display: none;">
						<dt><spring:message code="Cache.lbl_apv_form"/></dt> <!-- 양식 -->
						<dd><p class="files_title"><span class="ic_pdf"></span><span class="file_name"></span></p></dd>
					</dl>
					<dl style="display: none;">
						<dt><spring:message code="Cache.lbl_Attachment"/></dt> <!-- 첨부파일 -->
						<dd></dd>
					</dl>
				</div>
				<div id="docFileCtrl" style="display: none;"></div><!--  -->
				<div id="dext5" kind="write" style="visibility: hidden; position:fixed;"></div>
				<div class="popBtnWrap">
					<a href="#" class="btnTypeDefault btnTypeChk" id="btnSave"><spring:message code="Cache.lbl_Regist"/></a><!-- 등록 -->
					<a href="#" class="btnTypeDefault" id="btnClose" onclick="Common.Close(); return false;"><spring:message code="Cache.btn_Close"/></a><!-- 닫기 -->
				</div>
			</div>
		</div>
	</div>
</body>

<script>
	var UserCode = Common.getSession("UR_Code");
	var regExp = /[\{\}\[\]\/?.,;:|\)*~`!^\-_+<>@\#$%&\\\=\(\'\"]/gi;
	var saveMode = CFN_GetQueryString("mode") == undefined ? "" : CFN_GetQueryString("mode");
	var fileName = CFN_GetQueryString("fileName") == undefined ? "" : decodeURI(CFN_GetQueryString("fileName")).split("|")[0].replaceAll(regExp, "");
	var docLink = CFN_GetQueryString("docLink") == undefined ? "" : decodeURI(CFN_GetQueryString("docLink"));
	var pdfInfo = new Array(), emlInfo = null;
	var isAdd = false;
	
	var g_editorKind = Common.getBaseConfig('EditorType');
	
	$(document).ready(function(){
		
		$("#docFileCtrl").empty();
		coviFile.fileInfos = new Array();
		
		// 프로젝트 리스트 가져오기
		setProjectPopupList();
		
		// 업무 폴더 리스트 가져오기
		setTaskFolderList();
		
		// 메일, 결재 별 화면 구성
		if(saveMode == "Mail"){	
			fileName += ".eml";
			$("#relationDocumentRegist dl").eq(4).find("dd .file_name").text(fileName);
			$("#relationDocumentRegist dl").eq(4).show();
			$("#relationDocumentRegist dl").eq(5).hide();
			$("#relationDocumentRegist dl").eq(6).hide();
		}else{
			fileName += ".pdf";
			$("#relationDocumentRegist dl").eq(5).find("dd .file_name").text(fileName);
			$("#relationDocumentRegist dl").eq(4).hide();
			$("#relationDocumentRegist dl").eq(5).show();
			$("#relationDocumentRegist dl").eq(6).show();
		}
		
		$("#btnSave").on("click", saveProjectFile);
		
		// 라디오 버튼 클릭 이벤트
		$("#relationDocumentRegist input[name=radioTask]").on("click", function(){
			var radioTask = $("input[name=radioTask]:checked").val();
			if(radioTask == "TF"){
				var cID = $(".projectSelDiv .selProject option:selected").val();
				
				getProjectBasicInfo(cID, "info");
				$("#relationDocumentRegist dl").eq(1).find("dt").text("<spring:message code='Cache.lbl_JvCate'/>"); // 카테고리
				$(".projectSelDiv").show();
				$(".taskSelDiv").hide();
				$("#btnSave").off("click");
				
				if(isAdd){
					$("#relationDocumentRegist dl").eq(3).hide();
					$("#btnSave").on("click", saveTFTask);
				}else{
					$("#btnSave").on("click", saveProjectFile);
				}
				
			}else{
				var folderID = $(".taskSelDiv .selProject option:selected").val();
				var taskID = $(".taskSelDiv .selCategory option:selected").val();
				
				getTaskData("set", taskID, folderID);
				$("#relationDocumentRegist dl").eq(1).find("dt").text("<spring:message code='Cache.lbl_task_task'/>"); // 업무
				$(".projectSelDiv").hide();
				$(".taskSelDiv").show();
				$("#btnSave").off("click");
				
				if(isAdd){
					$("#relationDocumentRegist dl").eq(3).show();
					$("#btnSave").on("click", function(){
						saveTask("I");
					});
				}else{
					$("#btnSave").on("click", function(){
						saveTask("U");
					});
				}
			}
		});
		
		// 새 업무 버튼 클릭 이벤트
		$("#addTaskBtn").on("click", function(){
			var radioTask = $("input[name=radioTask]:checked").val();
			isAdd = true;
			$("#relationDocumentRegist dl").eq(1).find(".selCategory").val("");
			$("#relationDocumentRegist dl").eq(1).hide();
			$("#relationDocumentRegist dl").eq(2).show();
			$("#btnSave").off("click");
			
			if(radioTask == "TF"){
				$("#btnSave").on("click", saveTFTask);
				$("#relationDocumentRegist dl").eq(3).hide();
			}else{
				$("#btnSave").on("click", function(){
					saveTask("I");
				});
				$("#relationDocumentRegist dl").eq(3).show();
			}
		});
		
		$(".projectSelDiv .selProject").on("change", function(){
			var selVal = $(".projectSelDiv .selProject option:selected").val();
			
			getProjectBasicInfo(selVal, "info");
		});

		$(".taskSelDiv .selProject").on("change", function(){
			var selVal = $(".taskSelDiv .selProject option:selected").val();
			
			setTaskList(selVal);
		})
		
		$(".taskSelDiv .selCategory").on("change", function(){
			var folderID = $(".taskSelDiv .selProject option:selected").val();
			var taskID = $(".taskSelDiv .selCategory option:selected").val();
			
			getTaskData("set", taskID, folderID);
		})
		
		setTaskList($(".taskSelDiv .selProject option:selected").val());
		
		getProjectBasicInfo($(".projectSelDiv .selProject option:selected").val(), "info")
	});
	
	function deleteFileList(thisObj){
		var parentObj = $(thisObj).closest(".files_title");
		var idx = $("#relationDocumentRegist dl").eq(6).find(".files_title").index(parentObj);
		
		pdfInfo.splice(idx+1, 1);
		parentObj.remove();
	}
	
	function setProjectPopupList(){
		$.ajax({
			url: "/groupware/layout/selectUserMyTFGridList.do",
			type: "post",
			async: false,
			data: {
				"pageNo": 1,
				"pageSize": 10,
				"searchWord": "",
				"searchType": "",
				"AppStatus": "RV",
				"sortColumn": "",
				"sortDirection": ""
			},
			success: function(data){
				var selProjectStr = '';
				var list = data.list;
				
				if(list.length != 0){
					list.forEach(function(item, idx){
						selProjectStr += '<option value="'+item.CU_ID+'">'+item.CommunityName+'</option>';
					});
				}
				
				// 프로젝트 목록
				$(".projectSelDiv .selProject").html(selProjectStr);
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/biztask/getHomeProjectListData.do", response, status, error);
			}
		});
	}
	
	function getProjectBasicInfo(cID, mode){
		var formData = new FormData();
		
		$.ajax({
			url: "/groupware/layout/selectTFDetailInfo.do",
			type: "POST",
			async: false,
			data: {
				"CU_ID": cID
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var info = data.TFInfo[0];
					var fileList = data.fileList;
					var progressinfo = data.TFProgressInfo[0];
					
					if(mode == "info"){
						$("#hidDocLinks").val(info.TF_DocLinks);
						$("#docFileCtrl").empty();
						coviFile.fileInfos = new Array();
						coviFile.renderFileControl("docFileCtrl", {listStyle:"table", actionButton :"add", multiple : "true"}, fileList);
						
						info.Description = unescape(info.Description);
						
						// 에디터 인라인 이미지 처리
						if(/<[a-z][\s\S]*>/i.test(info.Description)){
							if($("#dext5").html() == ""){
								coviEditor.loadEditor("dext5", {
									editorType: g_editorKind,
									containerID: "tbContentElement",
									frameHeight: "400",
									useResize: "N",
									onLoad: function(){
										$("#dext5").css("display", "none");
										coviEditor.setBody(g_editorKind, 'tbContentElement', info.Description.replaceAll("\n", "<br>"));
									}
								});
							}else{
								if(coviEditor.getBodyText(g_editorKind, "tbContentElement") == info.Description)
									coviEditor.setBody(g_editorKind, "tbContentElement", info.Description);
								else
									coviEditor.setBody(g_editorKind, "tbContentElement", info.Description.replaceAll("\n", "<br>"));
							}
						}
					}else if(mode == "save"){
						var PMArr = info.TF_PM.split("@");
						var PMCodes = "", PMTxts = "";
						var AdminArr = info.TF_Admin.split("@");
						var AdminCodes = "", AdminTxts = "";
						var MemberArr = info.TF_Member.split("@");
						var MemberCodes = "", MemberTxts = "";
						
						$.each(PMArr, function(idx, item){
							PMCodes += item.split("|")[0] + ";";
							PMTxts += item.split("|")[1] + ";";
						});
						
						$.each(AdminArr, function(idx, item){
							AdminCodes += item.split("|")[0] + ";";
							AdminTxts += item.split("|")[1] + ";";
						});
						
						$.each(MemberArr, function(idx, item){
							MemberCodes += item.split("|")[0] + ";";
							MemberTxts += item.split("|")[1] + ";";
						});
						
						formData.append("CU_ID", info.CU_ID);
						formData.append("Category", info.DN_ID);
						
						formData.append("txtMajorDeptCode", info.TF_MajorDeptCode);
						formData.append("txtMajorDept", info.TF_MajorDept);
						
						formData.append("txtStart", info.TF_StartDate);
						formData.append("txtEnd", info.TF_EndDate);
						
						formData.append("txtPMCount", PMArr.length);
						formData.append("txtPMCode", PMCodes);
						formData.append("txtPM", PMTxts);
						
						formData.append("txtAdminCount", AdminArr.length);
						formData.append("txtAdminCode", AdminCodes);
						formData.append("txtAdmin", AdminTxts);
						
						formData.append("txtMemberCount", MemberArr.length);
						formData.append("txtMemberCode", MemberCodes);
						formData.append("txtMember", MemberTxts);
						
						formData.append("txtDocLinks", $("#hidDocLinks").val());
						
						formData.append("frontStorageURL", escape(Common.getGlobalProperties("smart4j.path")+ Common.getBaseConfig("FrontStorage").replace("{0}", Common.getSession("DN_Code"))));
						
						if(!/<[a-z][\s\S]*>/i.test(info.Description)){
							formData.append("txtContentSize", info.Description.length);
							formData.append("txtContent", info.Description);
							formData.append("txtContentEditer", "");
							formData.append("txtContentInlineImage", "");
							formData.append("ContentOption", "N");
						}else{
							formData.append("txtContentSize", coviEditor.getBodyText(g_editorKind, 'tbContentElement').length);
							formData.append("txtContent", coviEditor.getBodyText(g_editorKind, 'tbContentElement'));
							formData.append("txtContentEditer", coviEditor.getBody(g_editorKind, 'tbContentElement'));
							formData.append("txtContentInlineImage", coviEditor.getImages(g_editorKind, 'tbContentElement'));
							formData.append("ContentOption", "Y");
						}
					}
				}
			},
			error: function(error){
				CFN_ErrorAjax("/groupware/project/getProjectInfoOne.do", response, status, error);
			}
		});
		
		if(mode == "save"){
			return formData;
		}
	}
	
	function setTaskFolderList(){
		$.ajax({
			type: "POST",
			url: "/groupware/task/getSearchAll.do",
			async: false,
			data: {
				"searchWord": "",
				"stateCode": "",
				"sortColumn": "",
				"sortDirection": ""
			},
			success: function(data){
				if(data.status=="SUCCESS"){
					var selTaskStr = '<option value="0"><spring:message code="Cache.lbl_Person_Task"/></option>'; // 내가 하는 일
					var list = data.FolderList;
					
					if(list.length != 0){
						list.forEach(function(item, idx){
							selTaskStr += '<option value="'+item.FolderID+'">'+item.DisplayName+'</option>';
						});
					}
					
					// 프로젝트 목록
					$(".taskSelDiv .selProject").html(selTaskStr);
					
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030' />"); //오류가 발생했습니다.
				}
			}, 
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/task/getFolderItemList.do", response, status, error);
			}
		});
	}
	
	function setTaskList(folderID){
		$.ajax({
			type: "POST",
			url: "/groupware/task/getFolderItemList.do",
			data: {
				"folderID": folderID,
				"isMine": "Y",
				"stateCode": "",
				"searchType": "Subject",
				"searchWord": "",
				"sortColumn": "",
				"sortDirection": ""
			}, 
			success: function(data){
				if(data.status=='SUCCESS'){
					var taskList = data.TaskList;
					var taskListStr = '';
					
					$.each(taskList, function(idx, item){
						taskListStr += '<option value="'+item.TaskID+'">'+item.Subject+'</option>';
					});
					
					$(".taskSelDiv .selCategory").html(taskListStr);
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030' />"); //오류가 발생했습니다.
				}
			},
			error: function(response, status, error){
				 CFN_ErrorAjax("/groupware/task/getFolderItemList.do", response, status, error);
			}
		}); 
	}
	
	function getTaskData(mode, taskID, folderID){
		var formData = new FormData();
		
		$.ajax({
			url: "/groupware/task/getTaskData.do",
			type: "POST",
			async: false,
			data: {
				"TaskID": taskID,
				"FolderID": folderID
			},
			success: function(data){
				var taskInfo = data.taskInfo;
				var performerList = data.performerList;
				var fileList = data.fileList;
				
				if(mode == "set"){
					$("#docFileCtrl").empty();
					coviFile.fileInfos = new Array();
					coviFile.renderFileControl("docFileCtrl", {listStyle:"table", actionButton :"add", multiple : "true"}, fileList);
				}else if(mode == "save"){
					var performerCodeList = new Array();
					
					$.each(performerList, function(idx, item){
						performerCodeList.push({"PerformerCode": item.Code});
					});
					
					// 에디터의 인라인 이미지 처리
					if(/<[a-z][\s\S]*>/i.test(taskInfo.Description)){
						if($("#dext5").html() == ""){
							coviEditor.loadEditor("dext5", {
								editorType: g_editorKind,
								containerID: "tbContentElement",
								frameHeight: "400",
								useResize: "N",
								onLoad: function(){
									$("#dext5").hide();
									coviEditor.setBody(g_editorKind, "tbContentElement", taskInfo.Description);
								}
							});
						}else{
							if(coviEditor.getBodyText(g_editorKind, "tbContentElement") == taskInfo.Description)
								coviEditor.setBody(g_editorKind, "tbContentElement", taskInfo.Description);
							else
								coviEditor.setBody(g_editorKind, "tbContentElement", taskInfo.Description.replaceAll("\n", "<br>"));
						}
					}
					
					var taskObj = {
						"TaskID": taskInfo.TaskID,
						"FolderID": taskInfo.FolderID,
						"Subject": taskInfo.Subject,
						"State": taskInfo.TaskStateCode,
						"Progress": taskInfo.Progress,
						"StartDate": taskInfo.StartDate,
						"EndDate":  taskInfo.EndDate,
						"InlineImage": "",
						"Description": "",
						"PerformerList": performerCodeList
					};
					
					if(!/<[a-z][\s\S]*>/i.test(taskInfo.Description)){
						taskObj.Description = taskInfo.Description;
					}else{
						taskObj.InlineImage = coviEditor.getImages(g_editorKind, "tbContentElement");
						taskObj.Description = coviEditor.getBody(g_editorKind, "tbContentElement");
					}

					formData.append("mode", "U");
					formData.append("taskStr", JSON.stringify(taskObj));
					
					formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
				}
			},
			error: function(response, status, error){
				 CFN_ErrorAjax("/groupware/task/getTaskData.do", response, status, error);
			}
		});
		if(mode == "save"){
			return formData;
		}
	}
	
	function setProjectList(cID){
		$.ajax({
			type: "POST",
			url: "/groupware/tf/getActivityList.do",
			data: {
				"pageNo": 1,
				"pageSize": 10,
				"reqType": "A",
				"schContentType": undefined,
				"schTxt": undefined,
				"simpleSchTxt": undefined,
				"CU_ID": cID,
				"startDate": undefined,
				"endDate": undefined
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var list = data.list;
					var projectListStr = '';
					
					$.each(list, function(idx, item){
						projectListStr += '<option value="'+item.AT_ID+'">'+item.ATName+'</option>';
					});
					
					$(".projectSelDiv .selCategory").html(projectListStr);
				}
			},
			error: function(error){
				CFN_ErrorAjax("/groupware/project/getProjectInfoOne.do", response, status, error);
			}
		});
	}
	
	function saveProjectFile(){
		var cID = $(".projectSelDiv .selProject option:selected").val();
		var formData = getProjectBasicInfo(cID, "save");
		var fileCnt = coviFile.fileInfos.length;
		
		formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
		for (var i = 0; i < coviFile.files.length; i++) {
			if (typeof coviFile.files[i] == 'object') {
				formData.append("files", coviFile.files[i]);
			}
		}
		formData.append("saveMode", saveMode);
		
		if(saveMode == "Approval"){
			var docLinks = $("#hidDocLinks").val() == "" ? docLink : $("#hidDocLinks").val() + "^^^" + docLink;
			
			formData.set("txtDocLinks", docLinks);
			//pdfInfo.splice(0, 1);
			
			if(pdfInfo.length != 0){
				var fileNameArr = new Array();
				var filePathArr = new Array();
				var fileIDArr = new Array();
				
				$.each(pdfInfo, function(idx, item){
					fileNameArr.push(item.fileName);
					filePathArr.push(item.savePath + item.saveFileName);
					fileIDArr.push((item.fileID) ? item.fileID : "");
					fileCnt++;
				});
				
				formData.append("fileName", fileNameArr);
				formData.append("filePath", filePathArr);
				formData.append("fileID", fileIDArr);
			}
		}else{
			formData.append("fileName", emlInfo.fileName);
			formData.append("filePath", emlInfo.filePath);
		}
		formData.append("fileCnt", fileCnt);
		
		$.ajax({
			url: "/groupware/layout/updateTFTeamRoomAddFile.do",
			type: "post",
			async: false,
			data: formData,
			dataType: "json",
			processData: false,
			contentType: false,
			success: function(data){
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_insert'/>", "Information", function(result){ 
						if(result){
							pdfInfo = new Array();
							emlInfo = null; 
							$("#btnClose").click();
						}
					});
				}else{ 
					Common.Warning("<spring:message code='Cache.msg_38'/>");
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	function getFolderOwnerCode(folderID){
		var ownerCode = ""; 
		
		$.ajax({
			url: "/groupware/task/getFolderData.do",
			type: "POST",
			async: false,
			data: {
				"FolderID": folderID
			},
			success: function(data){
				var folderInfo = data.folderInfo;
				
				if("OwnerCode" in folderInfo){
					ownerCode = folderInfo.OwnerCode;
				}else{
					ownerCode = "";
				}
			},error:function(response, status, error){
				CFN_ErrorAjax("/groupware/task/getFolderData.do", response, status, error);
			}
		});
		
		return ownerCode;
	}
	
	function saveTask(mode){
		var formData = new FormData();
		
		if(mode == "I"){
			var folderID = $(".taskSelDiv .selProject option:selected").val();
			var fileCnt = 1;
			var today = new Date(CFN_GetLocalCurrentDate().split(" ")[0].replaceAll("-", "/")); // 현재 날짜, 시간  - 타임존 적용
			var todayStr = today.format("yyyy.MM.dd");
			var ownerCode = getFolderOwnerCode(folderID);
			var taskObj = {
				"FolderID": folderID,
				"Subject": $("#docSubject").val(),
				"State": "Waiting",
				"Progress": 0,
				"StartDate": todayStr,
				"EndDate":  todayStr,
				"InlineImage": "",
				"Description": $("#docContent").val(),
				"RegisterCode": UserCode,
				"OwnerCode": ownerCode == "" ? UserCode : ownerCode,
				"PerformerList": []
			};
			formData.append("mode", mode);
			formData.append("saveMode", saveMode);
			formData.append("taskStr", JSON.stringify(taskObj));
			
			if(saveMode == "Approval"){
				var fileNameArr = new Array();
				var filePathArr = new Array();
				var fileIDArr = new Array();
				
				$.each(pdfInfo, function(idx, item){
					fileNameArr.push(item.fileName);
					filePathArr.push(item.savePath + item.saveFileName);
					fileIDArr.push((item.fileID) ? item.fileID : "");
					fileCnt++;
				});
				
				formData.append("fileName", fileNameArr);
				formData.append("filePath", filePathArr);
				formData.append("fileID", fileIDArr);
			}else{
				formData.append("fileName", emlInfo.fileName);
				formData.append("filePath", emlInfo.filePath);
			}
			formData.append("fileInfos", JSON.stringify([]));
			formData.append("fileCnt", fileCnt);
		}else{
			var fileCnt = coviFile.fileInfos.length + 1;
			formData = getTaskData("save", $(".taskSelDiv .selCategory option:selected").val(), $(".taskSelDiv .selProject option:selected").val());
			formData.append("saveMode", saveMode);
			
			if(saveMode == "Approval"){
				var fileNameArr = new Array();
				var filePathArr = new Array();
				var fileIDArr = new Array();
				
				$.each(pdfInfo, function(idx, item){
					fileNameArr.push(item.fileName);
					filePathArr.push(item.savePath + item.saveFileName);
					fileIDArr.push((item.fileID) ? item.fileID : "");
					fileCnt++;
				});
				
				formData.append("fileName", fileNameArr);
				formData.append("filePath", filePathArr);
				formData.append("fileID", fileIDArr);
			}else{
				formData.append("fileName", emlInfo.fileName);
				formData.append("filePath", emlInfo.filePath);
			}
			formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
			formData.append("fileCnt", fileCnt);
		}
		
		$.ajax({
			url: "/groupware/task/saveTaskDataAddFile.do",
			type: "post",
			async: false,
			data: formData,
			contentType: false,
			processData: false,
			success: function(res){
				if(res.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_insert'/>", "Information", function(result){
						if(result){
							pdfInfo = new Array();
							emlInfo = null; 
							$("#btnClose").click();
						}
					});
				}else{
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred'/>"); //오류가 발생했습니다.
				}		
			},
			error:function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	function saveTFTask(){
		var formData = new FormData();
		var fileCnt = 1;
		var cID = $(".projectSelDiv .selProject option:selected").val();
		var today = new Date(CFN_GetLocalCurrentDate().split(" ")[0].replaceAll("-", "/")); // 현재 날짜, 시간  - 타임존 적용
		var todayStr = today.format("yyyy.MM.dd");
		var taskObj = {
			"CU_ID": cID,
			"ATName": $("#docSubject").val(),
			"State": "Waiting",
			"Weight": 0,
			"Progress": 0,
			"SortKey": 0,
			"StartDate": todayStr,
			"EndDate": todayStr,
			"Gubun": "A",
			"MemberOf": "",
			"RegisterCode": UserCode,
			"PerformerList": []
		};
		
		formData.append("mode", "I");
		formData.append("saveMode", saveMode);
		formData.append("taskStr", JSON.stringify(taskObj));
		
		if(saveMode == "Approval"){
			var fileNameArr = new Array();
			var filePathArr = new Array();
			var fileIDArr = new Array();
			
			$.each(pdfInfo, function(idx, item){
				fileNameArr.push(item.fileName);
				filePathArr.push(item.savePath + item.saveFileName);
				fileIDArr.push((item.fileID) ? item.fileID : "");
				fileCnt++;
			});
			
			formData.append("fileName", fileNameArr);
			formData.append("filePath", filePathArr);
			formData.append("fileID", fileIDArr);
		}else{
			formData.append("fileName", emlInfo.fileName);
			formData.append("filePath", emlInfo.filePath);
		}
		formData.append("fileInfos", JSON.stringify([]));
		formData.append("fileCnt", fileCnt);
		
		$.ajax({
			url: "/groupware/tf/saveTaskDataAddFile.do",
			type: "post",
			data: formData,
			contentType: false,
			processData: false,
			success: function(res){
				if(res.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_Edited'/>", "Information", function(result){
						if(result){
							pdfInfo = new Array();
							emlInfo = null; 
							$("#btnClose").click();
						}
					});
				}else{
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred'/>"); //오류가 발생했습니다.
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
</script>