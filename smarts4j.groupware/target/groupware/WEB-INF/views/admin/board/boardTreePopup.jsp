<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<script>
var bizSection = CFN_GetQueryString("bizSection");
var mySearchTree = new coviTree();
$(document).ready(function (){
	//관리자 메뉴 랜더링 이후 폴더 트리메뉴 랜더링
	setTreeData();
	//우선 적으로 2depth까지 expand
	mySearchTree.expandAll(2);
});

function setTreeData(){
	$.ajax({
		url:"/groupware/admin/selectSearchFolderTree.do",
		type:"POST",
		data:{
			"domainID" : parent.$("#domainIDSelectBox").val(),
			"bizSection": bizSection
		},
		async:false,
		success:function (data) {
			var List = data.list;
			//바인딩할 Selector, Param, DisplayName, width, align, checkbox, ? )
			mySearchTree.setTreeList("coviTree_SearchMenu", List, "nodeName", "170", "left", false, true);
		},
		error:function (error){
			alert(error);
		}
	});
	mySearchTree.displayIcon(true);
}

//하단의 닫기 버튼 함수
function closeLayer(){
	Common.Close();
}

var folderName = "";
var folderIDs = "";
function setSearch(){
	var myArray = mySearchTree.body.find("input[type=radio]:checked").val();
	var folderData = new Object;
	folderData = JSON.parse(myArray);
	
	if(folderData == "" || folderData == 'undefined'){
		parent.Common.Warning("게시판을 선택해주세요.", "Warning Dialog", function () {
	    });
		return;
	}

	parent.$("#searchFolder").val(folderData.FolderName);
	parent.$("#hiddenFolderID").val(folderData.FolderID);
	parent.$("#hiddenFolderIDs").val(folderData.FolderID);
	Common.Close();
}
</script>
<div>
	<form id="frmSearchTree">	
	<div id="coviTree_SearchMenu" style="max-height:250px; overflow: auto;"></div>
	<div align="center" style="padding-top: 15px">
		<input type="button" value="확인" onclick="setSearch();" class="AXButton red">
		<input type="button" value="닫기" onclick="closeLayer();" class="AXButton">
	</div>
	</form>
</div>