<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style type="text/css">
.contextMenuItem.plus, .contextMenuItem.minus{
	text-indent : 0;
	margin : 0;
	width : initial;
}

#coviTree_FolderMenu a,.AXTreeBody a {
	padding : 1px 0px !important;
}

#resourceFolderTree_AX_tree_focus { padding: 0; }

.AXTree_none .AXTreeScrollBody .AXTreeBody{
	position: relative;
	max-height: 588px;
}
</style>

<nav class="lnb">
	<h2 class="gnb_left_tit">
		<span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false"><spring:message code='Cache.lbl_Resources'/></span>
	</h2>
	<div>
		<select id="leftDomainSelectBox" class="AXSelect" onchange="javascript:changeCompany();" style="width: 200px;"></select>
	</div>
	
	<ul id="lnb_con" class="lnb_list"></ul>
</nav>

<script type="text/javascript">
	var domainID = CFN_GetQueryString("domainID") == 'undefined' ? Common.getSession('DN_ID') : CFN_GetQueryString("domainID") ;
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var resourceMenu = '';
	
	var resourceFolderTree = new coviTree();
	
	var body = { 
		onclick: function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
			selectResourceFolder(item.FolderID, item.domainID, item.FolderType, idx);
		}
	};
	
	//ready
	leftInit();
	
	function leftInit(){
		if(domainID == ""){
			domainID = Common.getSession("DN_ID");
		}

		$("#leftDomainSelectBox").coviCtrl("setSelectOption", "/groupware/admin/selectDomainList.do");
		$("#leftDomainSelectBox").val(domainID);
		
		//left menu 그리는 부분
		var coreLeft = new CoviMenu({
			lang: "ko",
			isPartial: "true"
		});
		coreLeft.render('#lnb_con', leftData, 'adminLeft');
		
		$.each($("#lnb_con li"), function(idx, el){
			if (el.dataset.menuUrl && el.dataset.menuUrl.indexOf('resource_ResourceManage') > -1)
				resourceMenu = el;
		});
		
		$(resourceMenu).after("<li style='list-style: none; border: 0;'><div id='resourceFolderTree' class='treeList'/></li>");
		$(resourceMenu).attr("data-role", "resourece-tree");
		$(resourceMenu).css("border", 0);
		$(resourceMenu).find("a:first").css("padding-bottom", 0);
		// Tree 셋팅
		setTreeData();
		
		setResourceMenuActive();
		
		if(loadContent == 'true'){
			leftmenu_goToPageMain();
		}
	}
	
	function leftmenu_goToPageMain(){
		CoviMenu_GetContent('/groupware/layout/resource_ResourceManage.do?CLSYS=resource&CLMD=admin&CLBIZ=Resource&domainID=' + $("#leftDomainSelectBox").val());
	}
	
	function changeCompany(){
		setTreeData();
		leftmenu_goToPageMain();
		setResourceMenuActive();
	}

	function setTreeData(){
		$.ajax({
			url: "/groupware/resource/getFolderResourceTreeList.do",
			type: "POST",
			data: {
				"domainID": $("#leftDomainSelectBox").val()
			},
			async: false,
			success: function (data) {
				var List = data.list;
				resourceFolderTree.setTreeList("resourceFolderTree", List, "nodeName", "170", "left", false, false, body);
				$("#lnb_con li.list_1dep a").attr("onclick", "CoviMenu_ClickLeft(this); setResourceMenuActive(); return false;");
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/resource/getFolderResourceTreeList.do", response, status, error);
			}
       	});
	}
	
	function selectResourceFolder(pfolderID, pDomainID, pFolderType, pFolderIdx){
		var pathname = '/groupware/layout/resource_ResourceManage.do';
		
		var url = pathname + '?CLSYS=resource&CLMD=admin&CLBIZ=Resource';
			url += '&folderID=' + pfolderID + '&domainID=' + pDomainID + '&folderType=' + pFolderType;
		if(pFolderIdx) 
			url += '&folderIdx=' + pFolderIdx;	
		
		if (location.pathname != pathname){
			CoviMenu_GetContent(url);
		}
		else {
			var state = CoviMenu_makeState(url); 
			history.pushState(state, url, url);
			CoviMenu_SetState(state);
			
			queryStr = initQueryStr();
			folderID = queryStr.folderID;
			resourceManageInit();
		}
		
		setResourceMenuActive(pFolderIdx);
	}
	
	function setResourceMenuActive(folderIdx){
		$("#lnb_con .admin-menu-active").removeClass("admin-menu-active");
		resourceFolderTree.clearFocus();
		
		var currentMenu = '';
		
		$.each($("#lnb_con li"), function(idx, el) {
		    if (el.dataset.menuUrl && location.href.indexOf(decodeURIComponent(el.dataset.menuUrl)) > -1)
		        $(el).find("a:first").addClass("admin-menu-active");
		});
			
		if ($("#lnb_con .admin-menu-active").length == 0){
			$($(resourceMenu).find("a")[0]).addClass("admin-menu-active");
		}
		
		if($("#lnb_con .admin-menu-active").closest("li").attr("data-role") == 'resourece-tree') {
			var fidx = (folderIdx) ? folderIdx : 0;
			resourceFolderTree.setFocus(fidx);
			
			if (fidx == 0){
				resourceFolderTree.expandAll(1);
			}
			else {
				openTreeItem(resourceFolderTree.list[fidx].no);
			}
		}
	}
	
	function openTreeItem(fid){
		if (!resourceFolderTree) return false;
		
		var treeItem = resourceFolderTree.list.find(function(item){ return item.FolderID == fid; });
		var parentFolder = resourceFolderTree.list.find(function(item){ return item.FolderID == treeItem.pno; });
		if (parentFolder) {
			resourceFolderTree.expandToggleList(parentFolder.__index, parentFolder, true);
			openTreeItem(parentFolder.no)
		}
	}
</script>
