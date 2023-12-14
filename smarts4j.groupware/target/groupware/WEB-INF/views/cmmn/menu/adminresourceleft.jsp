<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
${folderIconCss}
</style>

<script type="text/javascript">
	var domainID = CFN_GetQueryString("domainID") == 'undefined' ? "" : CFN_GetQueryString("domainID") ;
	var leftdata = ${adminResourceLeft};
	var menuID = ${menuID};
	var resourceFolderTree = new coviTree();
	
	$(document).ready(function (){
		if(domainID==""){
			domainID = Common.getSession("DN_ID");
		}
		
		coviCtrl.renderDomainAXSelect(
				"leftDomainSelectBox",
				"ko",
				"changeCompany",
				"setMenuControl",
				domainID
		);
		
	});
	
	function setMenuControl(){
		setTreeData();

		drawadminleftmenu(leftdata);
	}
	
	function leftmenu_goToPageMain(){
		location.href = "/groupware/resource/ResourceManage.do";
	}
	
	
	function changeCompany(){
		if($("#leftDomainSelectBox").val()!=""){
			$(location).attr('href',"/groupware/resource/ResourceManage.do?domainID="+ $("#leftDomainSelectBox").val());
		}
	}

	function toggleleftmenu(pObj){
		$(pObj).parent().find("ul").toggle();
		
	}
	

	function setTreeData(){
		$.ajax({
			url:"/groupware/resource/getFolderResourceTreeList.do",
			type:"POST",
			data:{
				"domainID" : $("#leftDomainSelectBox").val(),
			},
			async:false,
			success:function (data) {
				var List = data.list;
				//바인딩할 Selector, Param, DisplayName, width, align, checkbox, ? )
				resourceFolderTree.setTreeList("resourceFolderTree", List, "nodeName", "170", "left", false, false);
				resourceFolderTree.expandAll(2);	
			},
			error:function(response, status, error){
       	     CFN_ErrorAjax("/groupware/resource/getFolderResourceTreeList.do", response, status, error);
			}
       	});
	}
	
	function selectResourceFolder(FolderID, domainID){
		location.href = "/groupware/resource/ResourceManage.do?folderID="+FolderID+"&domainID="+domainID;
	}
	
</script>
	


<nav class="lnb">
	<h2 class="gnb_left_tit"><span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false"><spring:message code='Cache.CN_139'/></span></h2>  <!--자원-->
	<select id="leftDomainSelectBox" class="AXSelect" style="width:97%;"></select>
	<div style="width: 98%; height: 400px; margin-top:15px;">
	   <div id="resourceFolderTree" style="height:100%;"></div>
	</div>
	<ul class="lnb_list">
	</ul>
</nav>
