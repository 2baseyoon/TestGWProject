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

.AXTree_none .AXTreeScrollBody .AXTreeBody{
	position: relative;
	max-height: 488px;
}

</style>

<nav class="lnb">
	<h2 class="gnb_left_tit">
		<span class="gnb_tit"><spring:message code='Cache.lbl_Community'/></span><!-- 커뮤니티 -->
	</h2>
	<div>
		<select id="selectDomain" class="AXSelect" onchange="javascript:changeCompany();" style="width: 200px;"></select>
	</div>
	
	<ul id="lnb_con" class="lnb_list"></ul>
</nav>

<script type="text/javascript">
	var domainID = CFN_GetQueryString("DNID") == 'undefined' ? Common.getSession('DN_ID') : CFN_GetQueryString("DNID") ;
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var communityMenu = '';
	
	var myFolderTree = new coviTree();

	var body = { 
		onclick: function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
			selectCommunityTreeListByTree(
				item.FolderID, item.FolderType, 
				(item.FolderType == "Root" && item.FolderPath == "") ? "0" : item.FolderPath, 
			item.FolderName, idx);
		}
	};
	
	$(document).ready(function (){
		if(domainID == ""){
			domainID = Common.getSession("DN_ID");
		}
		
		$("#selectDomain").coviCtrl("setSelectOption", "/groupware/admin/selectDomainList.do");
		$("#selectDomain").val(domainID);
		
		//left menu 그리는 부분
		var communityLeft = new CoviMenu({
   			lang: "ko",
   			isPartial: "true"
    	});
		communityLeft.render('#lnb_con', leftData, 'adminLeft');
		
		$.each($("#lnb_con li"), function(idx, el){
			if (el.dataset.menuUrl && el.dataset.menuUrl.indexOf('community_CommunityList') > -1)
				communityMenu = el;
		});
		
		$(communityMenu).after("<li style='list-style: none; border: 0;'><div id='coviTree_FolderMenu' class='treeList'/></li>");
		$(communityMenu).attr("data-role", "community-tree");
		$(communityMenu).css("border", 0);
		$(communityMenu).find("a:first").css("padding-bottom", 0);
		
		setTreeData();
		
		setCommunityManuActive();
		
		if(loadContent == 'true'){
			leftmenu_goToPageMain();
		}
	});
	
	function leftmenu_goToPageMain(){
		CoviMenu_GetContent('/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=admin&CLBIZ=Community&DNID='+$("#selectDomain").val(), true);
	}
	
	function changeCompany(){
		setTreeData();
		leftmenu_goToPageMain();
		setCommunityManuActive();
	}
	
	function setTreeData(){
		$.ajax({
			url: "/groupware/layout/community/selectCommunityTreeData.do",
			type: "POST",
			data: {
				domain: $("#selectDomain").val()
			},
			async: false,
			success: function (data) {
				var url = '/groupware/layout/community_CommunityList.do?CLSYS=community&CLMD=admin&CLBIZ=Community&DNID=' + $("#selectDomain").val();
				$("#lnb_con li.list_1dep[data-role=community-tree]").attr("data-menu-url", encodeURIComponent(url));
				
				var List = data.list;
				if (List.length > 0) {
					myFolderTree.setTreeList("coviTree_FolderMenu", List, "nodeName", "170", "left", false, false, body);
					$("#lnb_con li.list_1dep a").attr("onclick", "CoviMenu_ClickLeft(this); setCommunityManuActive(); return false;");					
				}
				else {
					$("#coviTree_FolderMenu").html('<div class="AXTree_none"><div class="AXTreeScrollBody" style="padding: 10px 5px;">데이터가 없습니다.</div></div>');
				}
			},
			error:function (error){
				CFN_ErrorAjax("/groupware/layout/community/selectCommunityTreeData.do", response, status, error);
			}
		});
	}
	
	function selectCommunityTreeListByTree(pFolderID, pFolderType, pFolderPath, pFolderName, pFolderIdx){
		var pathname = '/groupware/layout/community_CommunityList.do';
		
		var url = pathname + '?CLSYS=community&CLMD=admin&CLBIZ=Community';
			url += '&DNID=' + $("#selectDomain").val() + '&folderID=' + pFolderID + '&folderType=' + pFolderType;
			url += '&path=' + pFolderPath.replace(/;/gi, '@') + '&folder=' + pFolderID + '&pType=' + pFolderType;
		if(pFolderIdx) 
			url += '&folderIdx=' + pFolderIdx;	
		
		//CoviMenu_GetContent(url, true);
		
		if (location.pathname != pathname){
			CoviMenu_GetContent(url);
		}
		else {
			var state = CoviMenu_makeState(url); 
			history.pushState(state, url, url);
			CoviMenu_SetState(state);
			
			queryStr = initQueryStr();
			dnID = queryStr.DNID;
			CategoryID = queryStr.folder;
			MemberOf = queryStr.path.replace(/@/gi, ';');
			pType = queryStr.pType;
			initLoad();
		}
		
		setCommunityManuActive(pFolderIdx);
	}
	
	function setCommunityManuActive(folderIdx){
		$("#lnb_con .admin-menu-active").removeClass("admin-menu-active");
		myFolderTree.clearFocus();
		
		$.each($("#lnb_con li"), function(idx, el) {
		    if (el.dataset.menuUrl && location.href.indexOf(decodeURIComponent(el.dataset.menuUrl)) > -1)
		        $(el).find("a:first").addClass("admin-menu-active");
		});
		
		if ($("#lnb_con .admin-menu-active").length == 0){
			$($(communityMenu).find("a")[0]).addClass("admin-menu-active");
		}
		
		if (myFolderTree.tree.length > 0){
			if($("#lnb_con .admin-menu-active").closest("li").attr("data-role") == 'community-tree') {
				var fidx = (folderIdx) ? folderIdx : 0;

				if (folderIdx) {
					myFolderTree.setFocus(folderIdx);
				}
				
				if (fidx == 0){
					myFolderTree.expandAll(fidx);
				}
				else {
					openTreeItem(myFolderTree.list[fidx].no);
				}
			}
		}
	}
	
	function openTreeItem(fid){
		if (!myFolderTree) return false;
		
		var treeItem = myFolderTree.list.find(function(item){ return item.FolderID == fid; });
		var parentFolder = myFolderTree.list.find(function(item){ return item.FolderID == treeItem.pno; });
		if (parentFolder) {
			myFolderTree.expandToggleList(parentFolder.__index, parentFolder, true);
			openTreeItem(parentFolder.no)
		}
	}
</script>