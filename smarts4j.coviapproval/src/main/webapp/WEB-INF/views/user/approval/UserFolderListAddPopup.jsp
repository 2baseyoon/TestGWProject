<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String mode = request.getParameter("mode");
	
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<c:set var="mode" value="<%=mode%>"/>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<form>
	<div>
		<div class="divpop_contents">
		<!-- 팝업 Contents 시작 -->
			<div class="popBox">
				<div class=" borderLine">
					<dl class="treeBox">
						<dd class="treeBot" style="height:260px;">
							<div class="mar10">
								<div style="width:390px; height: 200px;" id="coviTreeTarget"></div>
							</div>
						</dd>
					</dl>
				</div>
				<div class="bgPop">
					<dl class="editList">
						<dt><spring:message code='Cache.lbl_apv_folderName' /></dt>
						<dd><input type="text" class="W300" id="insertFolederNm"></dd>
						<dd><input type="button" class="smSave" value="<spring:message code='Cache.lbl_SchAddItem' />" onclick="InsertFolder()"/></dd>
					</dl>
				</div>
			</div>
			<!-- 하단버튼 시작 -->
			<div class="popBtn borderNon t_center"> 						
				<c:if test="${mode eq 'copy'}">
					<dd><input type="button" class="smSave" value="<spring:message code='Cache.btn_Copy' />" onclick="onClickListCopy()"/></dd>
				</c:if>
				<c:if test="${mode eq 'move'}">
					<dd><input type="button" class="smSave" value="<spring:message code='Cache.btn_Move' />" onclick="onClickListMove()"/></dd>
				</c:if>
			</div>
			<!-- 하단버튼 끝 -->
			<!-- 팝업 Contents 끝 -->
		</div>
	</div>
	<input type="hidden" id="folderNo"/>
	</form>
<script>
var myTree = new coviTree();

initUserFolderPopup();
//일괄호출처리 2019.02

function initUserFolderPopup(){
	setTreeData();
	$('.bodyNodeIcon.folder').show();
	$('#FolderDiv').hide();
}



function setTreeData(){
	var mode = "all";
	
	var body = {
			onclick:function(){
				$("#folderNo").val(this.item.no);
		    	$("#folderNo").attr("pno",this.item.pno);
		    	$("#folderNo").attr("foldernm",this.item.nodeName);
			}
	};
	
	$.ajax({
		url:"/approval/user/getUserFolderList.do",
		type:"POST",
		data:{
			"mode":mode
		},
		async:false,
		success:function (data) {
			
			myTree.setTreeList("coviTreeTarget", data.list, "nodeName", "220", "left", false, false ,body, "folder2", "AXTree_none folder_tree");
			//트리 모두확장
			myTree.expandAll();
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/getUserFolderList.do", response, status, error);
		}
	});
	//openAllTree();			// 트리를 모두 연 상태로 보여줌
}

//선택된 리스트 해당폴더에 복사
function onClickListCopy(){
	//
	var Processtmp 	= [];
	var ProcessID 	= null;
	var Workitemtmp = [];
	var WorkitemID 	= null;
	var CirculationBoxtmp = [];
	var CirculationBoxID = null;
	<%
		if(mode.equals("copy")){
	%>
	var checkApprovalList 	= parent.ListGrid.getCheckedList(1);
	<%
		}else{
	%>
	var checkApprovalList 	= parent.ListGrid.getCheckedList(0);
	<%
		}
	%>
	var FolderID			= $("#folderNo").val();
	var g_mode				= parent.g_mode;
	var bstored = "false";
	 
	if(checkApprovalList.length == 0){
		parent.Common.Warning(Common.getDic("msg_apv_003")); //선택된 항목이 없습니다.
		return false;
	}else if(FolderID == ""){
		parent.Common.Warning("<spring:message code='Cache.msg_164' />");				//대상 폴더를 선택하십시오.
		return false;
	}else if(FolderID == "0.1"){
		parent.Common.Warning(Common.getDic("_msg_rootFolderNotSelected")); //최상위 폴더를 제외한 대상 폴더를 선택하십시오.
		return false;
	}

	
	for(var i = 0; i < checkApprovalList.length; i++){
		
		if(g_mode == "TCInfo" || g_mode == "DeptTCInfo"){ //개인결재 참조 || 부서결재 참조
			Processtmp.push(checkApprovalList[i].ProcessID);
			Workitemtmp.push(checkApprovalList[i].WorkitemID);
			CirculationBoxtmp.push(checkApprovalList[i].CirculationBoxID);
		}else{
			Processtmp.push(checkApprovalList[i].ProcessArchiveID);
			Workitemtmp.push(checkApprovalList[i].WorkitemArchiveID);
		}
	}
	ProcessID = Processtmp.join(",");
	WorkitemID = Workitemtmp.join(",");
	CirculationBoxID = CirculationBoxtmp.join(",");
	
	$.ajax({
		url:"/approval/user/insertUserFolderCopy.do",
		type:"post",
		data:{"ProcessID":ProcessID,"WorkitemID":WorkitemID,"FolderID":FolderID,"mode":g_mode, "CirculationBoxID":CirculationBoxID},
		async:false,
		success:function (res) {
			parent.Common.Inform("<spring:message code='Cache.msg_insert' />","Inform",function() {
					closeLayer();
				});
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/insertUserFolderCopy.do", response, status, error);
		}
	});
}

// 선택된 리스트 해당 폴더에 이동
function onClickListMove(){
	var checkApprovalList 	= parent.ListGrid.getCheckedList(0);
	var FolderID			= $("#folderNo").val();
	var FolederListtmp 		= [];
	var FolederListID 		= null;

	if(FolderID == "") {
		parent.Common.Warning("<spring:message code='Cache.msg_apv_164' />");				//대상 폴더를 선택하십시오.
		return false;
	}else if(FolderID == "0.1"){
		parent.Common.Warning(Common.getDic("_msg_rootFolderNotSelected")); //최상위 폴더를 제외한 대상 폴더를 선택하십시오.
		return false;
	}
	
	for(var i = 0; i < checkApprovalList.length; i++) {
		FolederListtmp.push(checkApprovalList[i].FolderListID);
	}
	
	FolederListID = FolederListtmp.join(",");
	
	$.ajax({
		url:"/approval/user/updateUserFolderMove.do",
		type:"post",
		data:{"FolederListID":FolederListID,"FolderID":FolderID},
		async:false,
		success:function (res) {
			parent.Common.Inform(res.message, "Inform", function() {
				<%
				if(mode.equals("copy")){
				%>
					closeLayer();
					parent.Refresh();
				<%
				}else{
				%>
					closeLayer();
					parent.FolderListRefresh();
				<%
				}
				%>
			});
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/updateUserFolderMove.do", response, status, error);
		}
	});
}

//팝업 닫기
function closeLayer(){
	Common.Close();
}


// 부서/개인 결재함-새폴더새성
function InsertFolder(){
	// 체크된 항목 확인
	var seleteCheck 	= $("#folderNo").val();
	var FolDerName 		= $("#insertFolederNm").val().trim();
	var FolDerPno 		= $("#folderNo").attr("pno");
	
	if(FolDerName == ""){
		parent.Common.Warning("<spring:message code='Cache.msg_295' />"); // 폴더명을 입력하세요
		return false;
	}else if (FolDerPno > 1){
		parent.Common.Warning("<spring:message code='_msg_folderLv2Till' />"); // 폴더 추가는 차상위 폴더까지만 선택해주세요.
		return false;
	}
	
	$.ajax({
		url:"/approval/user/insertUserFolder.do",
		type:"post",
		data:{
			"ParentsID":seleteCheck,
			"FolDerName":FolDerName
			},
		async:false,
		success:function (res) {
			if(res.data == 1){
				parent.Common.Inform("<spring:message code='Cache.msg_insert' />","Inform",function() {
					location.reload();
				});
			} else {
				parent.Common.Error(res.message,"Error");
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/insertUserFolder.do", response, status, error);
		}
	});
}


</script>

