<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
.ITMLeftTabMenu li {
	width:100%;
}
.ITMLeftTabMenu > li:last-child {
	border-left : 1px solid #ddd;
}

#projectBtn a{
	margin : 1px;
}
</style>

<div class="cLnbTop">
	<h2 onclick="goMain();" title="<spring:message code='Cache.lbl_ITM' />">
		<spring:message code='Cache.lbl_ITM' /> 	<!-- 통합업무관리 -->
	</h2>
	<ul class="ITMLeftTabMenu">
		<li id="liproject" class="selected">
			<a href="#">
				<spring:message code='Cache.lbl_collaboration_mng' /> 	<!-- TF 룸 관리 -->
			</a>
		</li>
		<%-- <li id="litask" ><a  href="#" onclick="javascript:tabmenuChange('task');" style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 100%;" title="<spring:message code='Cache.lbl_task_taskManage' />"><spring:message code='Cache.lbl_task_taskManage' /></a></li> --%>
	</ul>
	<div id="projectBtn" class="cLnbTop_group">
		<a href="#" class="btnType01 half" onclick="javascript:projectRequest();"><spring:message code='Cache.btn_collaboration_apply' /></a> 	<!-- TF 룸 신청 -->
		<a href="#" class="btnType01 half" data-menu-target="Current" data-menu-url="/groupware/layout/TF_TFTempList.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask" onclick="CoviMenu_ClickLeft(this);return false;">
			<spring:message code='Cache.lbl_TempSaveList' /> 	<!-- 임시저장목록 -->
		</a>
	</div>
</div>

<div id="tabDetail" class="cLnbMiddle AddTab mScrollV scrollVType01">
	
	<!-- 프로젝트 목록 시작 -->
	<div id="projectTreeTarget"></div>
	<!-- 프로젝트 목록 끝 -->
	
	<ul class="ITMLeftTabMenu" style="padding: 18px 25px 26px;">
		<li id="litask" class="selected" >
			<a href="#" title="<spring:message code='Cache.lbl_general_business_mng' />">
				<spring:message code='Cache.lbl_general_business_mng' /> 	<!-- 일반 업무 관리 -->
			</a>
		</li>
	</ul>
	<div id="taskTreeTarget">
		<ul class="contLnbMenu">
			<li class="taskMenu01" style='padding-top: 10px;'>
				<div id="shareFolderTreeTarget" class="treeList radio radioType02"></div>
			</li>
			
			<li class="taskMenu02">
				<div id="personFolderTreeTarget" class="treeList radio radioType02" ></div>
			</li>
		</ul>
	</div>
	<div>
		<ul class="contLnbMenu ITM_Menu" id="leftmenu"></ul>
	</div>
	<div class="ITMmyworkBtnWrap">
		<a href="#" class="ITMmyworkBtn" onclick="javascript:MyTask();"><spring:message code='Cache.lbl_myworkreport' /></a>
	</div>
	
</div>

<script type="text/javascript">
	//# sourceURL=BizTaskUserLeft.jsp
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	
	var shareFolderTree = new coviTree();
	var personFolderTree = new coviTree();
	var myProjectTree = new coviTree();
	
	initLeft();
	
	function initLeft(){
		// 스크롤
		var opt = {
			lang : "ko",
			isPartial : "true"
		};
		var left = new CoviMenu(opt);
		left.render('#leftmenu', leftData, 'userLeft');
		
		coviCtrl.bindmScrollV($('.mScrollV'));
		$('.btnOnOff').unbind('click').on('click', function(){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').removeClass('active');
			}else {
				$(this).addClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');
			}
		});
		
		setLeftProjectTree(myProjectTree, "projectTreeTarget");//프로젝트 표시
		setLeftTree(); //업무관리 표시
		if(loadContent == 'true') {
			CoviMenu_GetContent('/groupware/layout/biztask_Portal.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask');
			g_lastURL = '/groupware/layout/biztask_Portal.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask';
		}
	}
	
	function setLeftTree(){
		var shareBody = {
			onclick:function(idx, item){
				if(item.type == "Root"){
					getFolderItem("0","N");
				}else{
					getFolderItem(item.FolderID,"N");
				}
				personFolderTree.clearFocus();
			}
		};
		
		var personBody = {
			onclick:function(idx, item){
				if(item.type == "Root"){
					getFolderItem("0","Y");
				}else{
					getFolderItem(item.FolderID,"Y");
				}
				
				shareFolderTree.clearFocus();
			}
		};
		
		$.ajax({
			type:"POST",
			url: "/groupware/task/getFolderList.do",
			data:{
				type:"All"
			},
			success: function(data){
				shareFolderTree.setTreeList("shareFolderTreeTarget", data.ShareList, "DisplayName", "269", "left", false, false, shareBody);
				personFolderTree.setTreeList("personFolderTreeTarget", data.PersonList, "DisplayName", "269", "left", false, false, personBody);
				
				shareFolderTree.expandAll();
				personFolderTree.expandAll();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/task/getFolderList.do", response, status, error);
			}
		});
	}
	
	function searhAllTask(){
		if($("#allTaskSearchWord").val() != ''){
			CoviMenu_GetContent('/groupware/layout/task_AllSearch.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask&search='+encodeURIComponent($("#allTaskSearchWord").val()));
		}else{
			Common.Inform("<spring:message code='Cache.msg_EnterSearchword'/>");
		}
	}
	
	function getFolderItem(folderID,isMine){
		CoviMenu_GetContent('/groupware/layout/task_ItemList.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask&folderID='+folderID+"&isMine="+isMine);
	}
	
	function setLeftProjectTree(pTreeObject, pTreeDiv){
		var body = {
			onclick:function(idx, item){
				if(item.type == "Folder") {
					getProjectList(item.PrjMode);
				} else if(item.type == "project") {
					getProjectItem(item.CU_ID, item.CommunityName);
				}
			},
		};
		$.ajax({
			type:"POST",
			url:"/groupware/biztask/getLeftProjectList.do",
			data:{
				pageNo:1,
				pageSize: 1000
			},
			async:false,
			success:function (data) {
				var treeList = data.list;
				
				pTreeObject.setTreeList(pTreeDiv, data.list, "nodeName", "100%", "left", false, false, body);
				pTreeObject.expandAll();
				$("#projectTreeTarget_AX_tr_0_AX_n_AX_0").hide();
				
			},
			error:function (error){
				CFN_ErrorAjax("/groupware/biztask/getLeftProjectList.do", response, status, error);
			}
		});
		pTreeObject.displayIcon(true);
	}
	
	function getProjectItem(prjCode, prjName){
		var url = '';
		url = String.format("/groupware/layout/biztask_ProjectDetailStatus.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask&PrjCode={0}&mode={1}&prjName={2}", prjCode, 'S', encodeURIComponent(prjName));
		CoviMenu_GetContent(url);
	}
	
	function getProjectList(prjmode) {
		var url = String.format("/groupware/layout/TF_TFMainList.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask&projectState={0}", prjmode);
		//CoviMenu_GetContent('/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ='+ g_bizSection);
		CoviMenu_GetContent(url);
	}
	
	function tabmenuChange(pTabName){
		if($("#li"+pTabName).hasClass('selected')){
			//기존선택 탭 클릭 통과시킴
		}else{
			$('.ITMLeftTabMenu li').each(function(){
				if($(this).hasClass('selected')){
					$(this).removeClass('selected');
				}else {
					$(this).addClass('selected');
				}
			});
			if(pTabName == "project"){
				if($(".cLnbMiddle").hasClass('AddTab')){
				}else{
					$(".cLnbMiddle").addClass('AddTab');
				}
				$("#projectTreeTarget").show();
				$("#taskTreeTarget").hide();
				$("#projectBtn").show();
			}else{
				if($(".cLnbMiddle").hasClass('AddTab')){
					$(".cLnbMiddle").removeClass('AddTab');
				}
				setLeftTree();
				
				$("#projectTreeTarget").hide();
				$("#taskTreeTarget").show();
				$("#projectBtn").hide();
			}
		}
	}
	
	function projectRequest(){
		CoviMenu_GetContent("/groupware/layout/TF_TFCreate.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask");
	}
	
	function MyTask(){
		$('.non').removeClass('selected');
		$('.sub').removeClass('selected');
		$('.gridBodyTr').removeClass('selected');
		$('.btnOnOff').removeClass('active');
		
		CoviMenu_GetContent("/groupware/layout/biztask_MyTask.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask");
	}
	
	function goMain(){
		CoviMenu_GetContent('/groupware/layout/biztask_Portal.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask');
		g_lastURL = '/groupware/layout/biztask_Portal.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask';
	}
	
	function goCommunitySite(cID){
		var specs = "left=10,top=10,width=1050,height=900,toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
		window.open("/groupware/layout/userCommunity/communityMain.do?C="+cID, "community", specs);
	}
</script>