<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = PropertiesUtil.getGlobalProperties().getProperty("resource.version", ""); 
	resourceVersion = resourceVersion.equals("") ? "" : ("?ver=" + resourceVersion);
%>
<script type="text/javascript" src="resources/script/user/legacyLeft.js<%=resourceVersion%>"></script>
<div class='cLnbTop'>
	<h2>Legacy Framework</h2> 
</div>
<div class="cLnbMiddle mScrollV scrollVType01">
	<ul id="leftmenu" class="contLnbMenu borderMenu">
	</ul>
</div>
<script type="text/javascript">
	
	var jobfunctionCnt = 0;
	var BizDocListCnt = 0;
	var menuID = 10;
	var myFolderTree = new coviTree();
	var $mScrollV = $('.mScrollV');
	var boardLeft;
	var body = { 
			onclick:function(idx, item) { //[Function] 바디 클릭 이벤트 콜백함수
				if (item.FolderType != "Folder" && item.FolderType != "Root") {
					board.goFolderContents(item.bizSection, item.MenuID, item.FolderID, item.FolderType);
				} else {
					if (item.open) myFolderTree.expandToggleList(idx, item); else myFolderTree.expandToggleList(idx, item, true);
				}
			}
		};
	
	initLeft();
	
</script>

