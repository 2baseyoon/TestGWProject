<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/task.js<%=resourceVersion%>"></script>
<style>
.fileSize {
    width: auto;
    max-width: 80px;
    margin-left: 4px;
    margin-top: 1px;
}

.woRd {
   height: 18px !important;
}

.word {
    padding-left: 26px;
    line-height: 17px;
    color: #000;
    background: url('/HtmlSite/smarts4j_n/covicore/resources/images/common/ic_word.png') no-repeat 0 center;
    text-indent: 0 !important;    
}
</style>

<div class="layer_divpop ui-draggable taskPopLayer" id="testpopup_p" style="width:100%" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent">
				<!-- 팝업 내부 시작 -->
				<form id="formData" method="post" enctype="multipart/form-data">
					<div class="taskPopContent  taskAddContent">
						<div class="top">
							<a name="registBtn" onclick="saveTask('I')" class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Regist'/><!-- 등록 --></a> <!-- 추가 시  -->
							<a name="tempSaveBtn" onclick="saveTask('IT')" class="btnTypeDefault ml5" style="display:none"><spring:message code='Cache.lbl_TempSave'/><!-- 임시저장 --></a> <!-- 등록 시  -->
							<a name="tempRegistBtn" onclick="saveTask('UT')" class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Regist'/><!-- 등록 --></a> <!-- 임시저장 후 등록 시  -->
							<a name="saveBtn" onclick="saveTask('U')" class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Save'/><!-- 저장 --></a>  <!--  수정 시  -->
							<a name="confirmBtn"  onclick='Common.Close(); return false; ' class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Confirm'/><!-- 확인 --></a>  <!-- 단순 조회 시  -->
							<a name="cancelBtn" onclick='Common.Close(); return false; ' class="btnTypeDefault ml5" style="display:none"><spring:message code='Cache.lbl_Cancel'/> <!-- 취소 --></a>
						</div>				
						<div class="middle">
							<div class=" cRContBtmTitle">
								<div class="boardTitle">
									<!-- <h2>사용자 화면설계</h2>		 -->								
									<h2 id="nameRead"><input id="nameWrite" kind="write" type="text" class="inpStyle01 HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.msg_028'/>"  style="display:none;"/></h2>		 <!-- 제목을 입력하세요  -->
									<div  id="taskRegInfo" class="boardTitData" style="display:none;">
										<span id="registerName" class="popName"></span><span id="registDate" class="date"></span>
										<div class="addFuncBox type02">
											<a class="btnAddFunc type02 " onclick="clickContextBtn(this)"  kind="write"></a>
											<ul class="addFuncLilst">														
												<li id="copyTaskBtn" style= "display:none;"><a class="icon-copy02" onclick="copyTask(t_taskID); return false;"><spring:message code='Cache.lbl_Copy'/><!-- 복사 --></a></li> <!--내 폴더인 경우만 내 폴더로 복사 가능 -->
												<li id="moveTaskBtn" style= "display:none;"><a class="icon-move" onclick="moveTask(t_taskID); return false;"><spring:message code='Cache.lbl_Move'/><!-- 이동 --></a><span class="icon-arrowLeft"></span></li>			 <!--내 폴더인 경우만 내 폴더로 복사 가능-->								
												<li id="deleteTaskBtn" kind="write" ><a class="icon-remove" onclick="deleteTask(t_taskID); return false;"><spring:message code='Cache.lbl_delete'/><!-- 삭제 --></a></li>							 <!--수정 권한이 있는 사람만 가능-->	 				
											</ul>
										</div>
									</div>
								</div>							
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_RepeateDate'/><!-- 일시 --></span></div>
								<div>
									<div id="periodWrite" kind="write" class="dateSel type02"  style="display:none;"></div>
									<!-- 텍스트만 나올 경우는 아래 태그 사용-->
									<p id="periodRead"  kind="read" class="textBox" style="display:none;"></p>
								</div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_State'/><!-- 상태 --></span></div>
								<div>
									<div id="stateWrite" kind="write" style="display:none;"></div>
									<p id="stateRead" class="textBox" kind="read" style="display:none;"></p>
								</div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_ProgressRate'/><!-- 진도율--></span></div>
								<div>
									<span id="progressRead" class="textBox" kind="read" style="display:none;"></span>
									<input type="text" id="progressWrite" kind="write" style="display:none;" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" />%
								</div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_task_performer'/><!-- 수행자 --></span></div>
								<div>
									<div class="autoCompleteCustom"  kind="write" style="display:none;">
										<input type="text" id="performer" class="HtmlCheckXSS ScriptCheckXSS"/>									
										<a class="btnTypeDefault ml5 " onclick="goShareUserListPopup(t_folderID);"><spring:message code='Cache.lbl_Coowner'/><!-- 공유자 --></a>									
										<span class="blueStart ml15"><spring:message code='Cache.msg_task_sharePerformer'/><!-- 수행자는 폴더의 공유자로 지정되어 있어야 합니다. --></span>
									</div>
									<div class="sharePerSonListBox mt10">
										<ul id="performerList"  class="personBoxList clearFloat">
											
										</ul>
									</div>
								</div>
							</div>
							<div class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_Description'/><!-- 설명 --></span></div>
								<div class="txtEdit">
									<textarea id="description" class="readOnlyFocus HtmlCheckXSS ScriptCheckXSS" kind="write" style="display:none;"></textarea>
									<div id="dext5" kind="write" style="display:none;"></div>
									<p id="changeEdit" class="editChange" kind="write" onclick="switchTextAreaEditor(this);" value="textarea" style="display:none;"><a><spring:message code='Cache.lbl_editChange'/><!-- 편집기로 작성 --></a></p>
									
									<p id="descriptionRead" class="textBox" kind="read" style="display:none;"></p>
									<input type="hidden" id="hidDescription" value="">
								</div>							
							</div>
							
							<!-- 첨부] -->
							<div class="inputBoxSytel01 type03" id="divFileInfos">
								<div><spring:message code='Cache.lbl_File'/></div>
								<div class="attFileListBox" style="position:relative;"></div>					<!-- [Added][FileUpload] 첨부파일 -->
							</div>
							
							<div id="divAppendFile" class="inputBoxSytel01 type03">
								<div><span><spring:message code='Cache.lbl_apv_attachfile'/></span></div>	<!-- 파일 첨부 -->
								<div id="con_file" style="padding : 0px;"></div>
							</div>
							
							<div id="commentView" class="commentView"> </div> <!-- 공통 댓글 -->
						</div>
						<div class="bottom pb0">
							<a name="registBtn" onclick="saveTask('I')" class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Regist'/><!-- 등록 --></a> <!-- 추가 시  -->
							<a name="tempSaveBtn" onclick="saveTask('IT')" class="btnTypeDefault ml5" style="display:none"><spring:message code='Cache.lbl_TempSave'/><!-- 임시저장 --></a> <!-- 추가 시  -->
							<a name="tempRegistBtn" onclick="saveTask('UT')" class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Regist'/><!-- 등록 --></a> <!-- 임시저장 후 추가 시  -->
							<a name="saveBtn" onclick="saveTask('U')" class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Save'/><!-- 저장 --></a>  <!--  수정 시  -->
							<a name="confirmBtn"  onclick='Common.Close(); return false; ' class="btnTypeDefault btnTypeChk" style="display:none"><spring:message code='Cache.lbl_Confirm'/><!-- 확인 --></a>  <!-- 단순 조회 시  -->
							<a name="cancelBtn" onclick='Common.Close(); return false; ' class="btnTypeDefault ml5" style="display:none"><spring:message code='Cache.lbl_Cancel'/> <!-- 취소 --></a>
						</div>
					</div>
				</form>
				<!-- 팝업 내부 끝 -->
		</div>
	</div>
</div>



<script>
	//# sourceURL=TaskSetPopup.jsp
	var t_mode = isNull(CFN_GetQueryString("mode").toUpperCase(),'');
	var t_folderID = isNull(CFN_GetQueryString("folderID"),'');
	var t_taskID = isNull(CFN_GetQueryString("taskID"),'');
	var t_isOwner = isNull(CFN_GetQueryString("isOwner"),'');
	var t_isSearch = isNull(CFN_GetQueryString("isSearch"),'N');
	var t_haveModifyAuth;  //수정권한 (추가시, 수정 시 등록자 또는 소유자일 경우)
	var t_isPerformer = 'N';

	var t_folderInfoObj;  
	var t_TaskInfoObj;  //수정 시 (업무 정보)
	var t_isTempSave; 	//임시저장 여부	: setTaskDataBind() 에서 처리
	
	var commentDelAuth;
	
	init();
	
	function init(){
		t_folderInfoObj = getFolderData(t_folderID).folderInfo;
		
		// 폴더가 없는 업무일 경우
		if(t_folderID == "0") {
			$("#divTaskPerformer").hide();
		}
		
		// [Added][FileUpload]
    	coviFile.fileInfos.length = 0;			// coviFile.fileInfos 초기화
		
		if(t_mode == "ADD"){ //추가
			$("#taskRegInfo").hide();
			
			t_haveModifyAuth = "Y";
			
			$('*[kind="read"]').hide();
			$('*[kind="write"]').show();
			setTaskControl(t_folderID);
			
			// [Added][FileUpload]
			$("#divFileInfos").hide();
			coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true'});
		}else{	 //수정 혹은 조회 (mode == MODIFY)
			$("#taskRegInfo").show();
			
			t_haveModifyAuth = t_isOwner == "Y" ? "Y" : "N";
			commentDelAuth = (t_isOwner == "Y") ? "true" : "false";
			
			getTaskData(t_taskID, t_folderID);

			if(t_haveModifyAuth == "Y"){
				if (t_isOwner == "Y"){
					$('*[kind="read"]').hide();
					$('*[kind="write"]').show();
				}
				else {
					$('*[kind="read"]').not("#progressRead").show();
					$("#progressWrite").show();
					$(".addFuncBox").css("display", "none");
				}
				
				if(t_folderInfoObj.OwnerCode == userCode){
					$("#copyTaskBtn").show();
					$("#moveTaskBtn").show();
				}
				
				setTaskControl(t_folderID);
			}else{
				$('*[kind="write"]').hide();
				$('*[kind="read"]').show();
			}
			
			setTaskData();

			$(".attFileListBox").html("");
			if(g_fileList !== undefined && g_fileList !== null && g_fileList.length > 0){
				var attFileAnchor = $('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');"/>').addClass('btnAttFile btnAttFileListBox').text('(' + g_fileList.length + ')');
				var attFileListCont = $('<ul>').addClass('attFileListCont').attr("style", "left: 0;");
				var attFileDownAll = $('<li>').append("<a href='#' onclick='javascript:downloadAll(g_fileList)'>"+Common.getDic("lbl_download_all")+"</a>").append($('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');" >').addClass("btnXClose btnAttFileListBoxClose"));
				var attFileList = $('<li>');
				var videoHtml = '';
				
				$.each(g_fileList, function(i, item){
					var iconClass = "";
					if(item.Extention == "ppt" || item.Extention == "pptx"){
						iconClass = "ppt";
					} else if (item.Extention == "excel" || item.Extention == "xlsx" || item.Extention == "xls"){
						iconClass = "fNameexcel";
					} else if (item.Extention == "pdf"){
						iconClass = "pdf";
					} else if (item.Extention == "doc" || item.Extention == "docx"){
						iconClass = "word";
					} else if (item.Extention == "zip" || item.Extention == "rar" || item.Extention == "7z"){
						iconClass = "zip";
					} else if (item.Extention == "jpg" || item.Extention == "gif" || item.Extention == "png"|| item.Extention == "bmp"){
						iconClass = "attImg";
					} else {
						iconClass = "default";
					}
					$(attFileList).append($('<p style="cursor:pointer;"/>').attr({"fileID": item.FileID, "fileToken": item.FileToken}).addClass('fName').append($('<span title="'+item.FileName+'">').addClass(iconClass).text(item.FileName)).append($('<span class="fileSize">').text("("+convertFileSize(item.Size)+")")));
				});
				
				$(attFileListCont).append(attFileDownAll, attFileList);
				$('.attFileListBox').append(attFileAnchor ,attFileListCont);
				$('.attFileListBox .fName').click(function(){
					Common.fileDownLoad($(this).attr("fileID"),$(this).text(), $(this).attr("fileToken"));
				});
				$('.attFileListBox').show();
			} else {
				$('.attFileListBox').hide();
			}
			
			// [Added][FileUpload]
			if(t_haveModifyAuth == "Y" && t_isOwner == "Y") {
				var fileList = JSON.parse(JSON.stringify(g_fileList));
				coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true'}, fileList);
				// $(".attFileListBox").hide();
			} else {
				// [Added][FileUpload]
				$("#divAppendFile").hide();
			}
			
			// 업무관리 이외의 서비스에서 호출되었을 때 처리
			if (parent && parent.getFolderItemList && parent.g_FolderID && parent.g_IsMine) {
				parent.getFolderItemList(); //읽음처리
			}
			
			if(coviComment){
				coviComment.commentVariables.commentDelAuth = commentDelAuth;
			}
		}
		
		setTitleWidth();
		setButton(t_mode, t_haveModifyAuth, t_isTempSave);
	}
	
	function convertFileSize(pSize) {
		var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
	    if (pSize == 0) return 'n/a';
	    var i = parseInt(Math.floor(Math.log(pSize) / Math.log(1024)));
	    return (pSize / Math.pow(1024, i)).toFixed(1) + sizes[i];
	}
</script>