<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
.treeList.radio .AXTree_none .AXTreeScrollBody .AXTreeBody .treeBodyTable tbody tr:first-child {
	display : none;
}
</style>

<div class="cLnbTop">
	<h2><spring:message code='Cache.lbl_EasyWorks' /></h2><!-- Easy Works -->
	<div><a class="btnType01 btnSurveyAdd" href="javascript:;" onclick="CoviMenu_GetContent('/groupware/layout/project_ProjectCreate.do?CLSYS=project&CLMD=user&CLBIZ=Project&mode=C');return false;"><spring:message code='Cache.lbl_project_regist' /></a></div> <!-- 프로젝트 등록 -->
</div>

<div class="cLnbMiddle mScrollV scrollVType01">
	<ul class="contLnbMenu projectMenu">
		<li class="taskMenu01 mScrollV scrollVType01" >
			<div id="projectTreeTarget" class="prjLeftTree treeList radio radioType02" ></div>
		</li>	
	</ul>
	<ul id="leftmenu" class="contLnbMenu projectMenu">
	</ul>
</div>

<script type="text/javascript">
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var adminCnt = 0;
	var g_lastURL;
	
	var myFolderTree = new coviTree();
	
	var body = {
		onclick:function(idx, item){
			if(item.type == "Folder") {
				getProjectList(item.PrjMode);
			} else if(item.type == "project") {
				getProjectItem(item.PrjCode, item.PrjName);
			}
		},
	};
	
	initLeft();
	
	function initLeft(){
		// 스크롤
		coviCtrl.bindmScrollV($('.mScrollV'));
		g_lastURL = '/groupware/layout/project_Home.do?CLSYS=project&CLMD=user&CLBIZ=Project';
		
		var opt = {
    			lang : "ko",
    			isPartial : "true"
    	};
    	var coviMenu = new CoviMenu(opt);
    	
    	if(leftData.length != 0){
    		coviMenu.render('#leftmenu', leftData, 'userLeft');
    	}
    	if(loadContent == 'true') {
    		//CoviMenu_GetContent('/groupware/layout/project_ProjectStatusList.do?CLSYS=project&CLMD=user&CLBIZ=Project&mode=S&prjmode=P');
    		CoviMenu_GetContent('/groupware/layout/project_Home.do?CLSYS=project&CLMD=user&CLBIZ=Project');
    		g_lastURL = '/groupware/layout/project_Home.do?CLSYS=project&CLMD=user&CLBIZ=Project';
    	}

    	setTreeData( myFolderTree, 'projectTreeTarget' );
    	
    	// 메뉴 숨기기
    	getAdminCount();
    	if(adminCnt <= 0)
			$("[data-menu-alias=ProjectAdmin]").hide();
    	
    	$('.btnOnOff').unbind('click').on('click', function(){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').removeClass('active');
			}else {
				$(this).addClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');			
			}	
		});
	}
	
	function setTreeData( pTreeObject, pTreeDiv ){
		$.ajax({
			url:"/groupware/project/getLeftProjectList.do",
			type:"POST",
			async:false,
			success:function (data) {
				var treeList = data.list;
				
				pTreeObject.setTreeList(pTreeDiv, data.list, "nodeName", "100%", "left", false, false, body);
				pTreeObject.expandAll();
			},
			error:function (error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
		pTreeObject.displayIcon(true);
	}
	
	function getProjectItem(prjCode, prjName){
		var url = '';
		url = String.format("/groupware/layout/project_ProjectDetailStatus.do?CLSYS=project&CLMD=user&CLBIZ=Project&PrjCode={0}&mode={1}&prjName={2}", prjCode, 'S', encodeURIComponent(prjName));
		CoviMenu_GetContent(url);
	}
	
	function getProjectList(prjmode) {	
		var url = '';
		url = String.format("/groupware/layout/project_ProjectStatusList.do?CLSYS=project&CLMD=user&CLBIZ=Project&mode=S&prjmode="+prjmode);
		CoviMenu_GetContent(url);
	}
	
	function getAdminCount(){
		$.ajax({
			type:"POST",
			url:"/groupware/project/getProjectAdminCount.do",
			async: false,
			success:function (data) {
				if(data.result=="ok"){
					adminCnt = data.cnt;
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/project/getProjectAdminCount.do", response, status, error);
			}
		});
	}
</script>

