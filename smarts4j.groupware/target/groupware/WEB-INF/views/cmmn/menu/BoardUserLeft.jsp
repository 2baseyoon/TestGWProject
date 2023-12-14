<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	.mCSB_container_wrapper { margin-right: 0; }
	.mCSB_container_wrapper > .mCSB_container { padding-right: 0; }
</style>

<div class="cLnbTop">
	<h2><spring:message code='Cache.lbl_Boards' /></h2><!-- 게시판 -->
	<div><a href="javascript:;" class="btnType01" onclick="board.goWrite();"><spring:message code='Cache.lbl_Board_leftRegist'/></a></div><!-- 게시등록 -->
	<div class="searchBox02 lnb">
		<span>
			<input type="text" id="txtTotalSearch" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_TotalBoardSearch'/>">	<!-- 전체게시 검색 -->
			<button type="button" id="btnSearchTotal" class="btnSearchType01"><spring:message code='Cache.btn_search'/></button>	<!-- 검색 -->
		</span>
	</div>
</div>

<div class="cLnbMiddle mScrollV scrollVType01 boardCommContent">
	<ul id="leftmenu" class="contLnbMenu borderMenu">
	</ul>
</div>

<script type="text/javascript">
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var domainId = '${domainId}';
	var isAdmin = '${isAdmin}';
	var menuCode = "<%= (request.getParameter("menuCode") == null) ? "BoardMain" : request.getParameter("menuCode")%>";	//Board외에 추가되는 메뉴에 따라 Base_Config에서 메뉴ID조회
	var menuID = (menuCode == ""?"":Common.getBaseConfig(menuCode,Common.getSession("DN_ID")));
	var menuName; 
	var treeExpandCnt = (Common.getBaseConfig("treeExpandCnt",Common.getSession("DN_ID")) == ""? 'all' : Common.getBaseConfig("treeExpandCnt",Common.getSession("DN_ID")));
	var treeMinHeight = (Common.getBaseConfig("treeMinHeight",Common.getSession("DN_ID")) == ""? 250 : Common.getBaseConfig("treeMinHeight",Common.getSession("DN_ID")));
	var treeMaxHeight = (Common.getBaseConfig("treeMaxHeight",Common.getSession("DN_ID")) == ""? 400 : Common.getBaseConfig("treeMaxHeight",Common.getSession("DN_ID")));
	var treeScrollInertia = (Common.getBaseConfig("treeScrollInertia",Common.getSession("DN_ID")) == ""? 300 : Common.getBaseConfig("treeScrollInertia",Common.getSession("DN_ID")));
	
	var myFolderTree = new coviTree();

	var boardLeft;

	var treeList;
	
	var body = { 
		onclick:function(idx, item) { //[Function] 바디 클릭 이벤트 콜백함수
			$("#left .selected").removeClass("selected");
			if (item.FolderType != "Folder" && item.FolderType != "Root") {
				board.goFolderContents(item.bizSection, item.MenuID, item.FolderID, item.FolderType,'','',menuCode, item.FolderName);
			} else {
				if (item.open) myFolderTree.expandToggleList(idx, item); else myFolderTree.expandToggleList(idx, item, true);
			}
		
			if($(".gridBodyTr").hasClass('selected')){
				$(".gridBodyTr").removeClass('selected');
				$("#folder_item_" + item.FolderID).closest('.gridBodyTr').addClass('selected');
			} else{
				$("#folder_item_" + item.FolderID).closest('.gridBodyTr').addClass('selected');
			}
		}
	};
	
	initLeft();

	function initLeft(){
		//left menu 그리는 부분
		var opt = {
    			lang : "ko",
    			isPartial : "true"
    	};
		boardLeft = new CoviMenu(opt);
		boardLeft.render('#leftmenu', leftData, 'userLeft');

		//대메뉴 항목 생성 이후 TreeMenu 재조회
		$("#leftmenu > li:nth-child(1)").after("<li class=\"tree-menu scrollVType01\" style=\"height: auto; min-height: "+treeMinHeight+"px; max-height: "+treeMaxHeight+"px; overflow: hidden;\"><div id=\"coviTree_FolderMenu\" class=\"treeList radio\" /></li>");
		setTreeData( myFolderTree, 'coviTree_FolderMenu', menuID, 'Board');
		
		if(loadContent == 'true'){
    		CoviMenu_GetContent('/groupware/layout/board_BoardHome.do?CLSYS=board&CLMD=user&CLBIZ=Board&menuCode='+menuCode);
    	}
		
		setMenuURL();

		$('.mScrollV').mCustomScrollbar({
			axis: 'y',
			scrollInertia: treeScrollInertia
		});

		$('.btnOnOff').unbind('click').on('click', function(){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').removeClass('active');
			}else {
				$(this).addClass('active');
				$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');			
			}	
		});
		
		$.each(headerdata, function(idx, el){
			if (el.MenuID == menuID) menuName = CFN_GetDicInfo(el.MultiDisplayName);
		});
		if (menuName != '') $(".cLnbTop h2").text(menuName);
	}

	$('#txtTotalSearch').on('keypress', function(e){ 
		if (e.which === 13) {			
	       e.preventDefault();	       
	       $("#btnSearchTotal").trigger('click');
    	}
	});
	
	$('#btnSearchTotal').on('click', function(){
		if (!XFN_ValidationCheckOnlyXSS()) { return; }
		var inputText = $("#txtTotalSearch").val();
		var url = String.format('/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&searchText={0}&searchType={1}', encodeURIComponent(inputText), "Total");
		CoviMenu_GetContent(url);
		inputText && coviCtrl.insertSearchData(inputText, 'Board');		
		$('#txtTotalSearch').val("");
	});
	
	//메뉴ID 정보 URL뒤에 추가
	function setMenuURL(){
		$.each($('.cLnbMiddle [data-menu-url*=board_BoardList]'), function(i, item){ 
			var menuURL = $(this).attr('data-menu-url'); 
			menuURL+='&menuCode='+menuCode;
			$(this).attr('data-menu-url', menuURL);
		});
	}
	
	//페이지 이동 
	function goMenuContents( pUrl, pMenuID, pBoardType ){
		if(pUrl !== "#"){
			var url
			if(arguments.length < 2){
				url = arguments[0]==null?sessionStorage.getItem("urlHistory"):arguments[0];
			} else {
				//Tree Menu에서 선택한 게시판들은 모두 boardType이 Normal로 고정 추후 FolderType은 앨범목록 보기를 사용해야할때...추후 분기처리 
				url = String.format("{0}", pUrl);
			}

			if(CFN_GetQueryString("communityId") != "undefined" ){	//Community용 Parameter추가
				url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
			}
			sessionStorage.setItem("urlHistory", url);
			g_urlHistory = url;
			
			CoviMenu_GetContent(url);
		}
	}

	//Left menu 하위에 위치하는 Tree Menu 추가
	//pTreeObject: coviTree 객체
	//pTreeDiv: 바인딩할 DIV Element
	//leftMenuType: 전체게시 조회(Total), 즐겨찾기 게시(Favorite) 구분 
	function setTreeData( pTreeObject, pTreeDiv, pLeftMenuID, param ){
		$.ajax({
			url:"/groupware/board/selectFolderTreeData.do",
			type:"POST",
			data:{
				"menuID": pLeftMenuID,
				"bizSection": param,
				"menuCode": menuCode
			},
			async:false,
			success:function (data) {
				treeList = data.list;
				var treeHeight = treeList.length * 18
				
				$('.tree-menu').css("height", treeHeight + "px");
				
				pTreeObject.setTreeList(pTreeDiv, treeList, "nodeName", "100%", "left", false, false, body);
				
				var tree_mobileStr = (Common.getBaseConfig('tree_mobileStr') == '') ? '' : Common.getBaseConfig('tree_mobileStr');
				$.each(treeList, function(idx, el){
					if (el.IsMobileSupport == 'Y') $("#folder_item_"+el.FolderID).html($("#folder_item_"+el.FolderID).text()+tree_mobileStr);
					if (!["Root", "DocRoot", "Folder"].includes(el.FolderType) && el.IsContents == 'Y') $("#folder_item_"+el.FolderID).prev().addClass("icon20");
				});
				
		 		$('.tree-menu').mCustomScrollbar({
		 			axis: 'yx',
		 			scrollInertia: treeScrollInertia
		 		});
				
		 		if ($("#"+pTreeDiv+"_AX_tree").height() == 0){
					$("#"+pTreeDiv+"_AX_tree, #"+pTreeDiv+"_AX_treeScrollBody, #"+pTreeDiv+"_AX_treeBody").css("height", "");
				}
		 		
		 		if (loadContent == 'false' && CFN_GetQueryString('folderID') != 'undefined' && (CFN_GetQueryString('boardType') == 'undefined' || CFN_GetQueryString('boardType') == 'Normal')) {		// 특정 게시판이 선택된 경우 
	    			$("#left .selected").removeClass("selected");
					var folderSortPath = '';
	    			var folderTreeIndex = 0;
	    			$.each(pTreeObject.list, function (idx, el){ 
	    				if (el.FolderID == CFN_GetQueryString('folderID')) {
	    					folderTreeIndex = idx;
	    					folderSortPath = el.SortPath;
	    				} 
	    			});
	    			
	    			if (folderSortPath == ''){
	    				pTreeObject.expandAll(treeExpandCnt);
	    			}
	    			else {
	    				var folderDepth = folderSortPath.split(';').length - 2;
		    			if (treeExpandCnt != 'all' && folderDepth < treeExpandCnt) folderDapth = treeExpandCnt;
		    			pTreeObject.collapseAll();
		    			pTreeObject.setFocus(folderTreeIndex);
		    			pTreeObject.expandAll(folderDepth);
	    			}
	    			
	    		} else {
					pTreeObject.expandAll(treeExpandCnt);
					
					if (['Approval', 'MyOwnWrite', 'OnWriting', 'RequestModify', 'MyBooking', 'Scrap'].indexOf(CFN_GetQueryString('boardType'))> -1) {		// 전체글보기, 게시판보기가 아닌 경우
						var menuBoardType = CFN_GetQueryString('boardType');
						$("#left .selected").removeClass("selected");
						$("#left [data-menu-url*="+menuBoardType+"] a").addClass("selected");
						if ($("#left [data-menu-url*="+menuBoardType+"]").prop("tagName") == 'DIV'){
							$("#left [data-menu-url*="+menuBoardType+"]").closest(".selOnOffBoxChk").addClass("active");
							$("#left [data-menu-url*="+menuBoardType+"]").closest("li").find(".selOnOffBox a").addClass("active");
						}
					}
	    		}
		 		
		 		setTimeout(function(){ loadContent = 'true'; }, 300);
			},
			error:function (error){
				CFN_ErrorAjax("/groupware/board/selectFolderTreeData.do", response, status, error);
			}
		});
		pTreeObject.displayIcon(true);
	}
</script>
