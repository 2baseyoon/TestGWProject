<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<form>
	<input type="hidden" id ="_DNID" value = "${DN_ID}"/>
	<input type="hidden" id ="_CategoryID" value = "${CategoryID}"/>
	<input type="hidden" id ="_selTreeId" value = ""/>
	<input type="hidden" id ="_selTreeName" value = ""/>
	<input type="hidden" id ="target" value ="${target}"/>
		<div class="popContent layerType02 treeDefaultPop" style="padding: 15px 24px 0;">
			<div class="middle" style="overflow-y: auto; border: 1px solid #d9d9d9;  border-radius: 1px;">
				<ul class="contLnbMenu communityMenu">
					<li class="communityMenu02" style="border-bottom:0px;">
						<div  class="treeList"  id='coviTree_FolderMenu' style='height:210px;'>
						
						</div>
					</li>
				</ul>
			</div>
			<div class="bottom" style="margin-top: 15px;" >
			    <div class="popBottom" >
			    	<a href="#" class="btnTypeDefault btnTypeBg"  onclick="btnOnClick();"><spring:message code='Cache.btn_ok'/></a>
					<a href="#" class="btnTypeDefault" onclick="Common.Close();"><spring:message code='Cache.btn_apv_close'/></a>
			    </div>           
			</div>
		</div>
</form>

<script type="text/javascript">
var myFolderTree = new coviTree();

var body = { 
	onclick:function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
		selectCommunityTreeListByTree(item.FolderID, item.FolderType, item.FolderPath, item.FolderName);
	}
};

$(document).ready(function(){	
	setTreeData();
});

function btnOnClick(){
	if($("#_selTreeId").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_selCategory'/>"); //분류를 선택하세요.
	}else if($("#_selTreeName").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_selCategory'/>"); //분류를 선택하세요.
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
		url:"/groupware/manage/community/selectCommunityTreeData.do",
		type:"POST",
		data: { "DN_ID" : $("#_DNID").val() },
		async:false,
		success:function (data) {
			var List = data.list;
			//바인딩할 Selector, Param, DisplayName, width, align, checkbox, ? )
			myFolderTree.setTreeList("coviTree_FolderMenu", List, "nodeName", "210", "left", false, false, body);
		},
		error:function (error){
			CFN_ErrorAjax("/groupware/manage/community/selectCommunityTreeData.do", response, status, error);
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