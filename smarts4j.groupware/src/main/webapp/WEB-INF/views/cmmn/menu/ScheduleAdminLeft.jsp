<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

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
}
</style>

<script type="text/javascript" src="/groupware/resources/script/admin/scheduleAdmin.js<%=resourceVersion%>" ></script>

<nav class="lnb">
	<h2 class="gnb_left_tit">
		<span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false">일정 관리</span>
	</h2>
	<div>
		<select class="AXSelect W200" id="selectDomain" onchange="javascript:changeCompany();"></select>
	</div>
	
	<ul id="lnb_con" class="lnb_list"></ul>
</nav>

<script type="text/javascript">
	var myTotalTree = new coviTree();
	var myCafeTree = new coviTree();
	var myThemeTree = new coviTree();
	
	var leftData = ${leftMenuData};
	var leftmenuhtml = "";
	
	var currentFolderType =  CFN_GetQueryString("FolderType") == 'undefined' ? 'Total' : CFN_GetQueryString("FolderType");
	
	drawScheduleLeftMenu(leftData, 0);
	
	function drawScheduleLeftMenu(pObj,pDepth) {
		$("#selectDomain").coviCtrl("setSelectOption", "/groupware/admin/selectDomainList.do");
		
		var leftmenu_depth = pDepth + 1;

		//개별호출-일괄호출
		Common.getBaseConfigList(["ScheduleMenuID"]);
		
		$(pObj).each(function(){
			leftmenuhtml = "";
			if(this.Reserved1 != "Share"){
				var folderType = this.Reserved1;
				
				leftmenuhtml += "<li data-role='root-menu' data-folder-type='" + folderType + "' class='list_" + leftmenu_depth + "dep_close'><a id='adminleft_" + this.MenuID +"' onclick='toggleleftmenu(this); reloadTree(\""+folderType+"\");'>" + this.DisplayName + "</a>";
				leftmenuhtml += "<ul>";
				leftmenuhtml += "	<li><div id='folderTree_"+folderType+"' class='adminTree'></div></li>";
				leftmenuhtml += "</ul>";
			} else {
				leftmenuhtml += "<li data-folder-type='" + this.Reserved1 + "' class='list_" + leftmenu_depth + "dep'><a id='adminleft_" + this.MenuID + "' onclick='CoviMenu_GetContent(\""+ this.URL +"\"); setScheduleManuActive(this); return XFN_SelectedLeftMenu_Admin(\"" + this.MenuID + "\",true)'>" + this.DisplayName + "</a>";
			}
			leftmenuhtml += "</li>";

			$(".lnb_list").append(leftmenuhtml);
			// Tree 세팅
			getFolderData(folderType);
		});
		
		$(".lnb_list li[data-folder-type!=" + currentFolderType + "] ul").hide();
		$(".lnb_list li[data-folder-type=" + currentFolderType + "]").removeClass('list_1dep_close').addClass('list_1dep_open');
		$(".lnb_list li[data-folder-type=" + currentFolderType + "] a:first").addClass('admin-menu-active');
		
		setTimeout(function(){
			if (currentFolderType == 'Total') { myTotalTree.setFocus(0); }
			else if (currentFolderType == 'Cafe') { myCafeTree.setFocus(0); }
			else if (currentFolderType == 'Theme') { myThemeTree.setFocus(0); }
		}, 100);		
		
		leftmenu_goToPageMain();
	}
	
	//각 일정 폴더 데이터 조회
	function getFolderData(folderType){
		$.ajax({
		    url: "/groupware/schedule/getFolderTreeList.do",
		    type: "POST",
		    data: {
		    	"MenuID": Common.getBaseConfig("ScheduleMenuID"),
				"FolderType": "Schedule."+folderType,
				"lang": Common.getSession("lang"),
				"DomainID": $("#selectDomain").val()
			},
		    success: function (res) {
		    	if(folderType == "Total"){
		    		myTotalTree.setTreeList("folderTree_"+folderType, res.list, "nodeName", "190", "left", false, false, { onclick: function(idx, item){ setScheduleManuActive(item); }});
		    	}else if(folderType == "Cafe"){
		    		myCafeTree.setTreeList("folderTree_"+folderType, res.list, "nodeName", "190", "left", false, false, { onclick: function(idx, item){ setScheduleManuActive(item); }});
		    	}else if(folderType == "Theme"){
		    		myThemeTree.setTreeList("folderTree_"+folderType, res.list, "nodeName", "190", "left", false, false, { onclick: function(idx, item){ setScheduleManuActive(item); }});
		    	}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/getFolderTreeList.do", response, status, error);
			}
		});
	}
	
	function addScheduleFolderData(folderID){
		var pFolderID = folderID != null ? folderID : "";
		var mode = folderID != null ? "U" : "I";
		Common.open("","updateConfig","<spring:message code='Cache.lbl_schedule_title' />","/groupware/schedule/adminFolderPopup.do?mode="+mode+"&FolderID="+pFolderID+"&ScheduleType="+currentFolderType+"&DomainID="+$("#selectDomain").val(),"630px","520px","iframe",true,null,null,true);
	}
	
	function leftmenu_goToPageMain(){
		CoviMenu_GetContent('/groupware/layout/schedule_FolderManage.do?CLSYS=schedule&CLMD=admin&CLBIZ=Schedule?FolderType='+currentFolderType);
	}
	
	function reloadTree(folderType){
		if(folderType == "Total"){
    		myTotalTree.redrawGrid();
    	}else if(folderType == "Cafe"){
    		myCafeTree.redrawGrid();
    	}else if(folderType == "Theme"){
    		myThemeTree.redrawGrid();
    	}
	}
	
	function changeCompany(){
		if($("#selectDomain").val()!=""){
			$(leftData).each(function(){
				var folderType = this.Reserved1;
				getFolderData(folderType);
			});
			CoviMenu_GetContent("/groupware/layout/schedule_FolderManage.do?CLSYS=schedule&CLMD=admin&CLBIZ=Schedule?FolderType="+currentFolderType);	
		}
	}
	
	function setScheduleManuActive(obj){
		$("#lnb_con .admin-menu-active").removeClass("admin-menu-active");
		
		if (obj.nodeName == 'A'){
			myTotalTree.clearFocus();
			myCafeTree.clearFocus();
			myThemeTree.clearFocus();
			
			$.each($("li.list_1dep_open a"), function(idx, el) { toggleleftmenu(el); });
			
			$(obj).addClass("admin-menu-active");
		}
		else {
			if (obj.FolderType) currentFolderType = obj.FolderType.replace('Schedule.', '');

			var rootFolder = $("a[id=folder_item_"+obj.no+"]").closest("li[data-role=root-menu]");
			var selectedFolderType = $(rootFolder).attr('data-folder-type');
			
			if ($(rootFolder).attr('data-folder-type') != currentFolderType){
				if (currentFolderType != "Total") myTotalTree.clearFocus();
				if (currentFolderType != "Cafe") myCafeTree.clearFocus();
				if (currentFolderType != "Theme") myThemeTree.clearFocus();
			}
			
			$(rootFolder.find("a")[0]).addClass("admin-menu-active");
			
			if (obj.FolderType == 'Schedule' && obj.pno && selectedFolderType != currentFolderType) {
				$("#folder_item_" + obj.pno).click();
			}
			
			if (selectedFolderType == "Total") myTotalTree.setFocus(obj.__index);
			if (selectedFolderType == "Cafe") myCafeTree.setFocus(obj.__index);
			if (selectedFolderType == "Theme") myThemeTree.setFocus(obj.__index);
		}
	}
</script>