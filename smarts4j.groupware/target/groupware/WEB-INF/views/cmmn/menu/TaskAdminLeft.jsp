<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
#coviTree_FolderMenu a,.AXTreeBody a {
	padding : 1px 0px !important;
}
.AXTree_none .AXTreeScrollBody .AXTreeBody{
	position: relative;
}
#folderTreeDiv_AX_tree_focus{
	display:none;
}
</style>

<nav class="lnb">
	<h2 class="gnb_left_tit">
		<span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false" ><spring:message code="Cache.lbl_task_taskManage"/><!-- 업무관리 --></span>
	</h2>	
	<ul id="lnb_con" class="lnb_list">
	</ul>
</nav>

<script type="text/javascript">
	var taskLeftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var folderTree = new coviTree();
	
	leftInif();
	
	function leftInif(){
		drawScheduleLeftMenu(taskLeftData);
	}
	
	function drawScheduleLeftMenu(pObj) {
		
	var lang = Common.getSession("lang");
		
		$(pObj).each(function(){
			leftmenuhtml = "";
			if(this.Reserved1 == "UserTaskFolder"){
				leftmenuhtml += "<li class='list_1dep_close'>";
				leftmenuhtml += "<a id='adminleft_" + this.MenuID +"' onclick='toggleleftmenu(this);' href='javascript:void(0);'>" + this.DisplayName + "</a>";
				leftmenuhtml +="<ul style='display:none;'><li>";
				leftmenuhtml +="	<div style='text-align: center; margin: 5px 0px;'><input type='text' class='AXInput' readonly='readonly' id='ownerName'>";
				leftmenuhtml +="		<img alt='search' style='cursor:pointer;'  onclick='goOrgChart();' src='/HtmlSite/smarts4j_n/covicore/resources/images/covision/btn_org.gif' width='25' height='24'>";
				leftmenuhtml +="		<input type='hidden' id='hidOwnerCode'>";
				leftmenuhtml +="	</div>";
				leftmenuhtml +="	<div id='folderTreeDiv' style='width: 190px; margin-left: 5px;'></div>";
				leftmenuhtml +="</li></ul>";
			} else {
				leftmenuhtml += "<li class='list_1dep'><a id='adminleft_" + this.MenuID + "' onclick='CoviMenu_GetContent(\""+ this.URL +"\");' onclick='return XFN_SelectedLeftMenu_Admin(\"" + this.MenuID + "\",true)' ' href='javascript:void(0);'>" + this.DisplayName + "</a>";
			}
			
			leftmenuhtml += "</li>";

			$("#lnb_con").append(leftmenuhtml);
		});
		

		$("li[class*=list_]").each(function () {
			if($(this).find("ul").is(":visible") == true ){
				$(pObj).attr("class",$(pObj).attr("class").replace(/_close/gi,"_open"));
			} else {
				$(this).attr("class",$(this).attr("class").replace(/_open/gi,"_close"));
			}
		});
		
		leftmenu_goToPageMain();
	}
	
	function goOrgChart(){
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?type=A1&callBackFunc=callBackOrgChart","540px", "580px", "iframe", true, null, null,true);
	}
	
	function callBackOrgChart(data){
		var dataObj = $.parseJSON(data);
		
		if(dataObj.item.length > 0){
			$("#ownerName").val(CFN_GetDicInfo(dataObj.item[0].DN));
			$("#hidOwnerCode").val(dataObj.item[0].AN);
			
			getFolderTreeData();
		}
	}
	
	//각 일정 폴더 데이터 조회
	function getFolderTreeData(){
		var personBody = {
				onclick:function(idx, item){
					if(item.type == "Root"){
						getFolderItem("0","Y");
					}else{
						getFolderItem(item.FolderID,"Y");
					}
				}
		};
		
		$.ajax({
			type:"POST",
			url: "/groupware/task/getFolderList.do",
			data:{
				type:"Person",
				userID : $("#hidOwnerCode").val()
			},
			success: function(data){
				folderTree.setTreeList("folderTreeDiv", data.PersonList, "nodeName", "170", "left", false, false, personBody);
				folderTree.expandAll(1);	
				folderTree.displayIcon(false);
			},
			error:function(response, status, error){
       	     	CFN_ErrorAjax("/groupware/task/getFolderList.do", response, status, error);
       		}
		});
	}
	
	function getFolderItem(folderID,isMine){
		CoviMenu_GetContent('/groupware/layout/task_AdminItemList.do?CLSYS=task&CLMD=admin&CLBIZ=Task&folderID='+folderID);
	}
	
	
	function leftmenu_goToPageMain(){
		CoviMenu_GetContent('/groupware/layout/task_AdminItemList.do?CLSYS=task&CLMD=admin&CLBIZ=Task');	
	}
</script>

