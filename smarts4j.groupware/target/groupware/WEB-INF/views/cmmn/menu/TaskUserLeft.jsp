<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	.mCSB_container { overflow: hidden !important; }
</style>

<div class="cLnbTop">
	<h2><spring:message code="Cache.lbl_task_taskManage"/></h2> <!-- 업무관리 -->
	<div class="searchBox02 lnb">
		<span><input type="text" id="allTaskSearchWord" onkeypress="if (event.keyCode==13){ searhAllTask(); return false;}"  placeholder="<spring:message code="Cache.lbl_AllSearch"/>"><!-- 전체 검색--><button type="button" class="btnSearchType01"  onclick="searhAllTask()" ><spring:message code="Cache.lbl_search"/><!--검색--></button></span>
	</div>
</div>					
<div class="cLnbMiddle askLnbContent">
	<div>
		<ul class="contLnbMenu taskMenu">								
			<li class="taskMenu01 mScrollV scrollVType01" style='height:240px;'>
				<div id="shareFolderTreeTarget" class="treeList radio radioType02"  ></div>
			</li>	
			<li class="taskMenu02 mScrollV scrollVType01"  style='height:240px;'>
				<div id="personFolderTreeTarget" class="treeList radio radioType02" ></div>
			</li>								
		</ul>
	</div>						
</div>



<script type="text/javascript">
	//# sourceURL=TaskUserLeft.jsp
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';

	var shareFolderTree = new coviTree();
	var personFolderTree = new coviTree();
	
	initLeft();

	function initLeft(){
		
		// 스크롤
		coviCtrl.bindmScrollV($('.mScrollV'));
		
		setLeftTree();
		if(loadContent == 'true'){
    		CoviMenu_GetContent('/groupware/layout/task_ItemList.do?CLSYS=task&CLMD=user&CLBIZ=Task&folderID=0&isMine=Y');	
    	}
	}
	
	function setLeftTree(){
		var shareBody = {
				onclick:function(idx, item){
					if(item.type == "Root"){
						getFolderItem("0","N");
					}else{
						getFolderItem(item.FolderID,"N");
					}
					personFolderTree.clearFocus();
				},
		};
		
		var personBody = {
				onclick:function(idx, item){
					if(item.type == "Root"){
						getFolderItem("0","Y");
					}else{
						getFolderItem(item.FolderID,"Y");
					}
					
					shareFolderTree.clearFocus();
				},
		};
		
		$.ajax({
			type:"POST",
			url: "/groupware/task/getFolderList.do",
			data:{
				type:"All"
			},
			success: function(data){
				shareFolderTree.setTreeList("shareFolderTreeTarget", data.ShareList, "DisplayName", "220", "left", false, false, shareBody);
				personFolderTree.setTreeList("personFolderTreeTarget", data.PersonList, "DisplayName", "220", "left", false, false, personBody);
				
				shareFolderTree.expandAll();	
				personFolderTree.expandAll();
				
				/* 	
				if(loadContent == 'true'){
		    		CoviMenu_GetContent('/groupware/layout/task_ItemList.do?CLSYS=task&CLMD=user&CLBIZ=Task&folderID=0&isMine=Y');	
		    	} */
			},
			error:function(response, status, error){
       	     	CFN_ErrorAjax("/groupware/task/getFolderList.do", response, status, error);
       		}
		});
	}
	
	function searhAllTask(){
		if($("#allTaskSearchWord").val() != ''){
			CoviMenu_GetContent('/groupware/layout/task_AllSearch.do?CLSYS=task&CLMD=user&CLBIZ=Task&search='+encodeURIComponent($("#allTaskSearchWord").val()));
		}else{
			Common.Inform("<spring:message code='Cache.msg_EnterSearchword'/>");
		}
	}
	
	function getFolderItem(folderID,isMine){
		CoviMenu_GetContent('/groupware/layout/task_ItemList.do?CLSYS=task&CLMD=user&CLBIZ=Task&folderID='+folderID+"&isMine="+isMine);
	}
</script>
