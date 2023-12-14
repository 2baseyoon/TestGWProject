<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<style type="text/css"> 
.AXTree_none .AXTreeScrollBody .AXTreeBody{
	position: relative;
} 
</style>
<form>
	<input type="hidden" id ="_DNID" value = "${DN_ID}"/>
	<input type="hidden" id ="_CategoryID" value = "${CategoryID}"/>
	<input type="hidden" id ="_selTreeId" value = ""/>
	<input type="hidden" id ="_selTreeName" value = ""/>
	<input type="hidden" id ="target" value ="${target}"/>
	
	<!-- <div id='coviTree_FolderMenu' style='height:250px;'> -->
	<div id='coviTree_FolderMenu' >
	
	</div>
	<div class="pop_body1" style="width:100%;">
	    <div class="pop_btn2" align="center">
	   		<input type="button" value="<spring:message code='Cache.btn_ok'/>" onclick="btnOnClick();" class="AXButton red">
	     	<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="Common.Close();"  class="AXButton" />                    
	    </div>           
	</div>
</form>
<script type="text/javascript">
var myFolderTree = new coviTree();

var body = { 
		onclick:function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
			if(item.FolderType == "Root" && item.FolderPath == ""){
				selectCommunityTreeListByTree(item.FolderID, item.FolderType, "0", item.FolderName);
			}else{
				selectCommunityTreeListByTree(item.FolderID, item.FolderType, item.FolderPath, item.FolderName);
			}
		}
};

$(document).ready(function(){	
	setTreeData();
});

function btnOnClick(){
	if($("#_selTreeId").val() == ""){
		alert("<spring:message code='Cache.msg_selCategory'/>");
	}else if($("#_selTreeName").val() == ""){
		alert("<spring:message code='Cache.msg_selCategory'/>");
	}else{
		//부모 접근.
		if($("#target").val() == "C"){
			if(opener){
				opener.TreeData($("#_selTreeId").val(),$("#_selTreeName").val(),"C");
			}else{
				parent.TreeData($("#_selTreeId").val(),$("#_selTreeName").val(),"C");
			}
		}else{
			if(opener){
				opener.TreeData($("#_selTreeId").val(),$("#_selTreeName").val(),"P");
			}else{
				parent.TreeData($("#_selTreeId").val(),$("#_selTreeName").val(),"P");
			}
		}
		
		
		Common.Close();
	}
}

function setTreeData(){
	$.ajax({
		url:"/groupware/layout/community/selectCommunityTreeData.do",
		type:"POST",
		data:{
			domain : $("#_DNID").val()
		},
		async:false,
		success:function (data) {
			var List = data.list;
			//바인딩할 Selector, Param, DisplayName, width, align, checkbox, ? )
			myFolderTree.setTreeList("coviTree_FolderMenu", List, "nodeName", "170", "left", false, false, body);
		},
		error:function (error){
			CFN_ErrorAjax("/groupware/layout/community/selectCommunityTreeData.do", response, status, error);
		}
	});
	myFolderTree.displayIcon(true);
	myFolderTree.clearFocus(); 
}

function selectCommunityTreeListByTree(pFolderID, pFolderType, pFolderPath, pFolderName){
	$("#_selTreeId").val(pFolderID);
	$("#_selTreeName").val(pFolderName);
}
</script>
