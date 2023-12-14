<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<!-- 컨텐츠앱 추가 -->
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/contentsApp/resources/css/contentsApp.css">
	<script type="text/javascript" src="<%=cssPath%>/contentsApp/resources/js/contentsApp.js"></script>
	<div class='commContLeft contentsAppLeft'>
		<div class='cLnbTop'>
			<h2><a href="/groupware/contents/ContentsMain.do" class="btn_cahome"><spring:message code='Cache.lbl_contentApps'/></a></h2>
			<div>
				<a href="#" class="btnType01" id="btnMake"><spring:message code='Cache.lbl_creatingContentApp'/></a>
				<ul id="makeMenu" style="width:229px;position:absolute;display:none;">
					<li><input type="button" value="<spring:message code='Cache.lbl_Folder'/> <spring:message code='Cache.lbl_Creation'/>" id="btnFolder" class="btnTypeDefault" style="width:100%" /></li>
					<li><input type="button" value="<spring:message code='Cache.lbl_contentApps'/> <spring:message code='Cache.lbl_Creation'/>" id="btnApp" class="btnTypeDefault" style="width:100%" /></li>
				</ul>
				<a href="/groupware/contents/ContentsMain.do" id="btnList" class="btnType01 btnBlueBoder"><spring:message code='Cache.lbl_contentAppStore'/></a>
			</div>
		</div>
		<div class="cLnbMiddle mScrollV scrollVType01">
			<div>
				<ul id="leftmenu" class="contLnbMenu contentsAppMenu">
					<li class="caMenu01" style="height:30px">
						<a href="/groupware/contents/ContentsMain.do?isFav=Y" <%= (request.getParameter("isFav") != null && "Y".equals(request.getParameter("isFav"))) ? "style='font-weight: 700;'" : ""%>><spring:message code='Cache.lbl_favoriteApps'/></a>
					</li>
					<li class="tree-menu">
						<div id="coviTree_FolderMenu" class="treeList radio"></div>
					</li>
				</ul>
			</div>
		</div>
	</div>
	
<script type="text/javascript">
(function(param){
	var menuCode = "<%= (request.getParameter("menuCode") == null) ? "BoardMain" : request.getParameter("menuCode")%>";	//Board외에 추가되는 메뉴에 따라 Base_Config에서 메뉴ID조회
	var menuID = (menuCode == ""?"":Common.getBaseConfig(menuCode,Common.getSession("DN_ID")));
	var folderID = (param.folderID == '')?param.memberOf:param.folderID;
	
	var myFolderTree = new coviTree();
	
	var body = { 
			onclick:function(idx, item) { //[Function] 바디 클릭 이벤트 콜백함수
				if (item.FolderType != "Folder" && item.FolderType != "Root") {
					location.href="/groupware/contents/ContentsList.do?folderID="+item.FolderID
				} else {
					location.href="/groupware/contents/ContentsMain.do?memberOf="+item.FolderID
				}
			}
		};
	
	var setEvent = function(){
		//켄텐츠 앱 만들기 메뉴
		$("#btnMake").off("click").on("click", function(){
			$("#makeMenu").toggle();
		});
		
		$("#btnList").off("click").on("click", function(){
			location.href="/groupware/contents/ContentsMain.do?memberOf="+item.FolderID
		});
		
		//폴더생성
		$("#btnFolder").off("click").on("click", function(){
			var popupID	= "ContentsFolderAddPopup";
			var openerID	= "";
			var popupTit	= Common.getDic("lbl_AddFolder");
			var popupYN		= "N";
			var popupUrl	= "/groupware/contents/ContentsFolderAddPopup.do?"
							+ "&fId="    	+ param.memberOf
							+ "&popupID="		+ popupID	
							+ "&openerID="		+ openerID	
							+ "&popupYN="		+ popupYN ;
			Common.open("", popupID, popupTit, popupUrl, "530px", "330px", "iframe", true, null, null, true);
		});
		
		//컨텐츠앱 생성
		$("#btnApp").off("click").on("click", function(){
			location.href="/groupware/contents/ContentsUserForm.do?memberOf="+param.memberOf
		});
	};
	
	var setTreeData=function( pTreeObject, pTreeDiv, pLeftMenuID, param ){
		var tree_mobileStr = (Common.getBaseConfig('tree_mobileStr') == '') ? '' : Common.getBaseConfig('tree_mobileStr');
		var colGroup = [{
			key: "nodeName",			// 컬럼에 매치될 item 의 키
			width: "100%",
			align: "left",				// left
			indent: true,					// 들여쓰기 여부
			getIconClass: function(){		// indent 속성 정의된 대상에 아이콘을 지정 가능
				var sRetIcon;
				if (this.item.FolderType=="Root" || this.item.FolderType=="Folder")
					sRetIcon = "ic_folder ";
				else {
					sRetIcon = "ic_file ";
					if (this.item.IsContents == "Y") sRetIcon += "icon20";
				}	
				return sRetIcon;
			},
			formatter:function(){
				var anchorName = $('<a>',{'id': 'folder_item_'+this.item.no, "html":this.item.nodeName+((!["Root", "Folder"].includes(this.item.FolderType) && this.item.IsMobileSupport=="Y")?tree_mobileStr:"")});
				return anchorName.prop('outerHTML');
			}
		}];
		
		pTreeObject.setTreeConfig(pTreeDiv, "pno", "no", false, false, colGroup, body);
			
		$.ajax({
			url:"/groupware/board/manage/selectFolderTreeData.do",
			type:"POST",
			data:{
				"bizSection": "Board",
				"isContents":"Y",
				"isAll":"N"
			},
			async:false,
			success:function (data) {
				var treeList = data.list;
				//pTreeObject.setTreeList(pTreeDiv, treeList, "nodeName", "100%", "left", false, false, body);
				//this.setTreeConfig(pid, "pno", "no", false, false, colGroup, body);
				pTreeObject.setList(treeList);
				
				if (folderID != ""){
					$( pTreeObject.list ).each( function(idx, v) {
						if (v["FolderID"].indexOf(folderID)>=0){
							if (v.__subTreeLength>0){
								pTreeObject.expandToggleList(idx, v, true); // 노드를 열린 상태로 바꾸어 줍니다.
							}	
							var focusItem = pTreeObject.click(idx, "open", true); // 아이템 확장처리만 원함.
							return;
						}
					});
				}else{
					pTreeObject.expandAll(1);
				}
			},
			error:function (error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
		pTreeObject.displayIcon(true);
	};
	
	var init = function(){
		setTreeData( myFolderTree, 'coviTree_FolderMenu', menuID, 'Board');
		setEvent();
		coviCtrl.bindmScrollV($('.mScrollV'));
	};
	
	init();
	
})({
	folderID: "${folderID}"
	, memberOf: "${memberOf}"
});
</script>	