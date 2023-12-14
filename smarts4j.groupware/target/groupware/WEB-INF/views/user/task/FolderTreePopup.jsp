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

<div class="layer_divpop ui-draggable taskPopLayer" id="testpopup_p" style="width:349px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent">
			<!--팝업 내부 시작 -->
			<div class="taskPopContent taskCopyMove">
				<div class="top">
					<ul class="contLnbMenu taskMenu">				
						<li class="taskMenu02" style="height:100%;overflow: auto;">
							<div id="personFolderTreeTarget" class="treeList radio radioType02" ></div>
						</li>							
					</ul>
				</div>				
				<div class="bottom mt10">
					<input type="hidden" id="targetFolderID">
					<input type="text" readonly="readonly" id="targetFolderName">
					<a id="moveFolderBtn" class="btnTypeDefault btnThemeLine " onclick="clickMoveFolderBtn()" style="display:none;"><spring:message code='Cache.lbl_Move'/><!-- 이동 --></a>
					<a id="moveTaskBtn" class="btnTypeDefault btnThemeLine " onclick="clickMoveTaskBtn()" style="display:none;"><spring:message code='Cache.lbl_Move'/> <!-- 이동 --></a>
					<a id="copyTaskBtn" class="btnTypeDefault btnThemeLine " onclick="clickCopyTaskBtn()" style="display:none;"><spring:message code='Cache.lbl_Copy'/><!-- 복사 --></a>
				</div>
			</div>
			<!--팝업 내부 끝 -->
		</div>
	</div>
</div>


<script>
	//# sourceURL=FolderTreePopup.jsp
	var personFolderTree = new coviTree();
	var folderID = isNull(CFN_GetQueryString("folderID"),'');
	var taskID = isNull(CFN_GetQueryString("taskID"),'');
	var mode = isNull(CFN_GetQueryString("mode"),''); //moveFolder |  moveTask | copyTask
	
	init();
	
	function init(){
		$("#"+mode+"Btn").show();
		
		var treeBody = {
				onclick:function(idx, item){
					$("#targetFolderID").val(item.FolderID);
					$("#targetFolderName").val(item.DisplayName);
				},
		};
		
		$.ajax({
			type: "POST",
			url: "/groupware/task/getFolderList.do",
			data:{
				"type": "Person"
			}
			, success : function(data){
				personFolderTree.setTreeList("personFolderTreeTarget", data.PersonList, "DisplayName", "250", "left", false, false, treeBody);
				personFolderTree.expandAll();
				
				if(mode == "moveFolder"){
					$.each(personFolderTree.list,function(idx,obj){  
						if(obj.FolderID == folderID){
							personFolderTree.removeTree(idx,obj);
							return false;
						}
					});
				}
				
				
			}
		});
	}

	// 폴더 이동
	function clickMoveFolderBtn(){
		Common.Confirm("<spring:message code='Cache.msg_RUMove' />","Inform",function(result){  //이동 하시겠습니까?
			if(result){
				$.ajax({
					type: "POST",
					url: "/groupware/task/moveFolder.do",
					data:{
						"FolderID": folderID,
						"targetFolderID": $("#targetFolderID").val()
					}
					, success : function(data){
						if(data.status=='SUCCESS'){
							if(data.isHaveShareChild=="Y"){
								parent.Common.Warning("<spring:message code='Cache.msg_task_shareFolderNotMove' />", "Warning", mainRefresh ); //해당 폴더 또는 하위 항목에 공유 폴더가 있을 경우 이동이 불가합니다.
							}else if(data.chkDuplilcation.isDuplication=="Y"){
								
								parent.Common.Inform(String.format("<spring:message code='Cache.msg_task_renameFolder' />", data.chkDuplilcation.saveName) , "Inform", mainRefresh);  //이동 위치에 동일한 이름의 폴더가 존재하여<br>[{0}]로 이름이 변경하였습니다.
							}else{
								parent.Common.Inform("<spring:message code='Cache.msg_task_completeMove' />", "Inform", mainRefresh); //이동 되었습니다.
							}	
						}else{
							parent.Common.Warning("<spring:message code='Cache.msg_ErrorOccurred' />"); //오류가 발생했습니다.
						}
					}
					,error:function(response, status, error){
               	     CFN_ErrorAjax("/groupware/task/moveFolder.do", response, status, error);
               	}
				});
			}
		});
	}
	
	//업무 이동
	function clickMoveTaskBtn(){
		Common.Confirm("<spring:message code='Cache.msg_task_deletePerformer' /><br><spring:message code='Cache.msg_RUMove' />","Inform",function(result){ //수행자 정보가 삭제됩니다.<br>이동 하시겠습니까?
			if(result){
				$.ajax({
					type: "POST",
					url: "/groupware/task/moveTask.do",
					data:{
						"TaskID": taskID,
						"targetFolderID": $("#targetFolderID").val()
					}
					, success : function(data){
						if(data.status=='SUCCESS'){
							if(data.chkDuplilcation.isDuplication=="Y"){
								
								parent.Common.Inform(String.format("<spring:message code='Cache.msg_task_moveRenameTask' />", data.chkDuplilcation.saveName) , "Inform", mainRefresh); //이동 위치에 동일한 이름의 업무가 존재하여 [{0}]로 이름이 변경되었습니다.
							}else{
								parent.Common.Inform("<spring:message code='Cache.msg_task_completeMove' />", "Inform", mainRefresh); //이동 되었습니다.
							}	
						}else{
							parent.Common.Warning("<spring:message code='Cache.msg_ErrorOccurred' />"); //오류가 발생했습니다.
						}
					}
					,error:function(response, status, error){
               	     CFN_ErrorAjax("/groupware/task/moveTask.do", response, status, error);
               	}
				});
			}
		});
	}

	//업무 복사
	function clickCopyTaskBtn(){
		Common.Confirm("<spring:message code='Cache.Cache.msg_task_deletePerformer'/><br><spring:message code='Cache.msg_RUCopy'/>","Inform",function(result){ //수행자 정보가 삭제됩니다.<br>복사 하시겠습니까?  
			if(result){
				$.ajax({
					type: "POST",
					url: "/groupware/task/copyTask.do",
					data:{
						"TaskID": taskID,
						"targetFolderID": $("#targetFolderID").val()
					}
					, success : function(data){
						if(data.status=='SUCCESS'){
							if(data.chkDuplilcation.isDuplication=="Y"){
								parent.Common.Inform(String.format("<spring:message code='Cache.msg_task_copyRenameTask' />", data.chkDuplilcation.saveName), "Inform", mainRefresh); //복사 위치에 동일한 이름의 업무가 존재하여 [{0}]로 이름이 변경되었습니다.
							}else{
								parent.Common.Inform("<spring:message code='Cache.msg_task_completeCopy' />", "Inform", mainRefresh);  //복사 되었습니다.
							}	
						}else{
							parent.Common.Warning("<spring:message code='Cache.msg_ErrorOccurred' />"); //오류가 발생했습니다.
						}
					}
					,error:function(response, status, error){
               	     CFN_ErrorAjax("/groupware/task/copyTask.do", response, status, error);
               	}
				});
			}
		});
	}
	
	
	
	
	function getFolderItem(folderID, IsMine){
		return;
	}
	
	function mainRefresh(){
		if(mode == "moveFolder"){
			parent.setLeftTree();
			parent.getFolderItemList();
			Common.Close();
		}else{
			parent.parent.getFolderItemList();
			Common.Close();
			parent.Common.Close();		
		}
	}

</script>