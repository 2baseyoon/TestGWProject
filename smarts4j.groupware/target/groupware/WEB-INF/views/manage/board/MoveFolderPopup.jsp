<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.sadminContent .tblList .AXTreeScrollBody .AXTreeBody {
     top: 0px !important; 
}
</style>
	<div class="sadmin_pop sadminContent">
		<div>
			<input type="button" value="<spring:message code='Cache.lbl_OpenAll'/>" onclick="movePopup.folderGrid.expandAll();" class="AXButton" /><!-- 전체열기 -->
			<input type="button" value="<spring:message code='Cache.lbl_CloseAll'/>" onclick="movePopup.folderGrid.collapseAll();" class="AXButton" /><!-- 전체닫기 -->				
		</div>
		<div id="treeDiv" class="tblFix tblCont" style="height:330;border:1px solid #eaeaea !important"></div>
		<div class="bottomBtnWrap">
			<a onclick="movePopup.moveFolder();" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.Cache.lbl_Move'/></a>
			<a onclick="Common.Close();" class="btnTypeDefault"><spring:message code='Cache.Cache.Cache.btn_Close'/></a>			
		</div>
		
	</div>	
<script>
var movePopup = {
		domainID : CFN_GetQueryString("domainID"),
		folderID  : CFN_GetQueryString("folderID"),
		bizSection : CFN_GetQueryString("bizSection"),
		folderGrid : new coviTree(),
	
		initContent:function(){
			movePopup.folderGrid.setConfig({
				targetID: "treeDiv",			// HTML element target ID
				theme: "AXTree_none",
				colGroup: [{
					key: "FolderName",			// 컬럼에 매치될 item 의 키
					indent: true,				// 들여쓰기 여부
					label: '<spring:message code="Cache.lbl_BoardNm"/>',
					width: "100%",
					align: "left",
					getIconClass: function(){	// indent 속성 정의된 대상에 아이콘을 지정 가능
	   					return "ic_folder";
					}
				}],							// tree 헤드 정의 값
				relation: {
					parentKey: "MemberOf",	// 부모 아이디 키
					childKey: "FolderID"	// 자식 아이디 키
				},
				showConnectionLine: true,	// 점선 여부
				persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
				persistSelected: false,		// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
				colHead: {display: false}
			});
			$("#treeDiv .AXTreeBody").css("height",parseInt($("#treeDiv").css("height"))-20);
			this.setTree();
		},
		setTree:function(){
			$.ajax({
				url: "/groupware/board/manage/selectFolderTreeData.do",
				type: "POST",
				data: {"domainID": movePopup.domainID,
					"bizSection": movePopup.bizSection,
					"onlyFolder":"Y"},
				async: false,
				success: function(data){
					var List = data.list;
					movePopup.folderGrid.setList(List);
					movePopup.folderGrid.expandAll(1);
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/board/manage/selectFolderTreeData.do", response, status, error);
				}
			});
	    }
		,moveFolder:function(isRoot) {
			var tarMenuId = "";
/*			if (isRoot  == "0")	{
				tarMenuId = "0";
				tarSortPath = "";
			}else{*/
				var obj = movePopup.folderGrid.getSelectedList();
				tarMenuId = obj.item.MenuID;
				tarFolderID= obj.item.FolderID;
				tarFolderPath= obj.item.FolderPath;
				tarSortPath = obj.item.SortPath;
//			}
			
			if (movePopup.folderID == "") {
		        Common.Inform("<spring:message code='Cache.msg_NoCuttedFolder'/>");  //잘라낸 폴더가 없습니다
		        return;
		    }
			
			Common.Confirm("<spring:message code='Cache.msg_inheritedAclDeleted'/>", "Confirm Dialog", function(result){ // 작업 수행 시 기존에 상속 받았던 권한은 삭제됩니다.<br>계속 진행하시겠습니까?
				if (result) {
					$.ajax({
						type:"POST",
						url:"/groupware/board/manage/pasteBoard.do",
						data:{
							"orgFolderID": movePopup.folderID,
							"targetMenuID": tarMenuId,
							"targetFolderID": tarFolderID,
							"targetFolderPath": tarFolderPath,
							"targetSortPath": tarSortPath
						},
						success:function(data){
							Common.Warning("<spring:message code='Cache.msg_Processed'/>", "Warning Dialog", function () {
								if (movePopup.bizSection == "Doc")
									parent.confDoc.setFolderTreeData();
								else
									parent.confBoard.setFolderTreeData();
								Common.Close();
							}); 
						},
						error:function(error){
							Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
						}
					});
				}
			});

			/*
			Common.Confirm("<spring:message code='Cache.msg_inheritedAclDeleted'/>", "Confirm Dialog", function(result){ // 작업 수행 시 기존에 상속 받았던 권한은 삭제됩니다.<br>계속 진행하시겠습니까?
				if (result) {
			 		$.ajax({
						type: "POST",
						data: {
							'menuId' : menuId,
							'sortPath' : sortPath,
							'tarMenuId' : tarMenuId,
							'tarSortPath' : tarSortPath,
							'tarDomainId' : tarDomainId,
							'tarIsAdmin' : tarIsAdmin,
							'sourceDomain' : domain
						},
						url: "/covicore/manage/menu/moveMenu.do",
						success: function(data){
							if (data.status === "SUCCESS") {
								parent.initTreeData();
								Common.Close();
							} else {
								Common.Warning(data.message);
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/menu/moveMenu.do", response, status, error);
						}
					});
				}
			});*/
		},
		closeLayer: function(){
			Common.Close();
		}
};

$(document).ready(function (){
	movePopup.initContent();
});


</script>