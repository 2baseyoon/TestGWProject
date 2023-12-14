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
			<input type="button" value="<spring:message code='Cache.lbl_OpenAll'/>" onclick="tree.expandAll();" class="AXButton" /> <!-- 전체열기 -->
			<input type="button" value="<spring:message code='Cache.lbl_CloseAll'/>" onclick="tree.collapseAll();" class="AXButton" /> <!-- 전체닫기 -->		
		</div>
		<div id="treeDiv" class="tblFix tblCont" style="height:330;border:1px solid #eaeaea !important"></div>
		<div class="bottomBtnWrap">
			<a onclick="moveMenu('0');" class="btnTypeDefault btnTypeBg">Root <spring:message code='Cache.Cache.lbl_Move'/></a>
			<a onclick="moveMenu();" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.Cache.lbl_Move'/></a>
			<a onclick="Common.Close();" class="btnTypeDefault"><spring:message code='Cache.Cache.Cache.btn_Close'/></a>			
		</div>
		
	</div>	
<script>
	var menuId = CFN_GetQueryString("menuId");
	var sortPath = CFN_GetQueryString("sortPath");
	var domain = CFN_GetQueryString("domain");
	var isAdmin = CFN_GetQueryString("isAdmin");
	var tree = new coviTree();
	
	window.onload = init();
	
	function init() {
		tree.setConfig({
			targetID: "treeDiv",				// HTML element target ID
			theme: "AXTree_none",
			colGroup: [	{
					key: "nodeName",			// 컬럼에 매치될 item 의 키
					indent: true,				// 들여쓰기 여부
					label: '<spring:message code="Cache.lbl_BoardNm"/>',
					width: "170",
					align: "left",
					getIconClass: function(){	return "ic_folder";}
				}],							// tree 헤드 정의 값
			showConnectionLine: true,	// 점선 여부
			relation: {
				parentKey: "pno",	// 부모 아이디 키
				childKey: "no"	// 자식 아이디 키
			},
			colHead: {display: false},
			fitToWidth: true			// 너비에 자동 맞춤
		});
		$("#treeDiv .AXTreeBody").css("height",parseInt($("#treeDiv").css("height"))-20);
		setTree();
	}

	// 트리 조회
    function setTree() {
		$.ajax({
			type:"POST",
			data:{
				'domain' :domain,
				'isAdmin' : isAdmin
			},
			async:false,
			url:"/covicore/manage/menu/getTreeList.do",
			success:function (data) {
				if (data.result == "ok") {
					tree.setList(data.list);
//					tree.setTreeList("treeDiv", data.list, "no", "220", "left", false, false, treeBody);					
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/menu/getTreeList.do", response, status, error);
			}
		});
    }
    
	function moveMenu(isRoot) {
		var tarMenuId = "";
		if (isRoot  == "0")	{
			tarMenuId = "0";
			tarSortPath = "";
		}else{
			var obj = tree.getSelectedList();
			tarMenuId = obj.item.no;
			tarSortPath = obj.item.SortPath;
		}
		var tarDomainId = domain;
		var tarIsAdmin = isAdmin;
		
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
		});
	}
</script>