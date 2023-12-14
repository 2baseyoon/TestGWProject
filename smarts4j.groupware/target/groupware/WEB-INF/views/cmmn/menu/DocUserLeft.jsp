<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style type="text/css">
	#deptFolderTreeArea.selOnOffBoxChk.boxList a:not(.bodyNodeIcon):not(.bodyNodeIndent) { background: none; }
	#deptFolderTreeArea .treeList .AXTree_none .AXTreeScrollBody .AXTreeBody .treeBodyTable tbody tr td .bodyTdText a { padding: 0; }
	#deptFolderTreeArea .treeList:first-child { margin-top: 0; }
	#deptFolderTreeArea .AXTreeBody > div:first-child { width: 100% !important; }
	#deptFolderTreeArea .AXTreeScrollBody, #deptFolderTreeArea .AXTreeBody { height: 100% !important; }
	#deptFolderTreeArea .treeList .AXTree_none .AXTreeScrollBody .AXTreeBody .treeBodyTable tbody tr td { padding-left: 20px; }
</style>

<div class="cLnbTop">
	<h2><spring:message code='Cache.BizSection_Doc' /></h2> <!-- 문서관리 -->
	<div><a name="btnWrite" href="javascript:;" class="btnType01"><spring:message code='Cache.lbl_DocRegister'/></a></div>	<!-- 문서등록 -->
	<div class="searchBox02 lnb">
		<span>
			<input type="text" id="txtTotalSearch" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_TotalBoardSearch'/>">	<!-- 전체게시 검색 -->
			<button type="button" id="btnSearchTotal" class="btnSearchType01"><spring:message code='Cache.btn_search'/></button>	<!-- 검색 -->
		</span>
	</div>
</div>

<div class="cLnbMiddle mScrollV scrollVType01 boardCommContent">
	<ul id="leftmenu" class="contLnbMenu docMenu">
	</ul>
</div>

<script type="text/javascript">
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var domainId = '${domainId}';
	var isAdmin = '${isAdmin}';
	var menuCode = "<%= (request.getParameter("menuCode") == null) ? "DocMain" : request.getParameter("menuCode")%>";	//Board외에 추가되는 메뉴에 따라 Base_Config에서 메뉴ID조회
	var menuID = (menuCode == ""?CFN_GetQueryString("menuID"):Common.getBaseConfig(menuCode,Common.getSession("DN_ID")));
	
	var myFolderTree = new coviTree();
	var g_bizSection = '<%=request.getParameter("CLBIZ")%>';
	var $mScrollV = $('.mScrollV');
	var boardLeft;

	var body = { 
		onclick:function(idx, item) { //[Function] 바디 클릭 이벤트 콜백함수
			if (item.FolderType != "Folder" && item.FolderType != "Root" && item.FolderType != "DocRoot") {
				board.goFolderContents(item.bizSection, item.MenuID, item.FolderID, item.FolderType);
			} else {
				if (item.open) myFolderTree.expandToggleList(idx, item); else myFolderTree.expandToggleList(idx, item, true);
			}
		
			if($(".gridBodyTr").hasClass('selected')){
				$(".gridBodyTr").removeClass('selected');
				$("#folder_item_" + item.FolderID).closest('.gridBodyTr').addClass('selected');
			}else{
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
//     	$("#leftmenu > li:nth-child(1)").after("<li><div id='coviTree_FolderMenu' class='treeList radio' style='height:200px;' /></li>");
		$("#leftmenu > li:nth-child(1)").after("<li><div id='coviTree_FolderMenu' class='treeList radio'/></li>");
		setTreeData( myFolderTree, "coviTree_FolderMenu", menuID, g_bizSection);
		
		if(Common.getBaseConfig("useDeptDocBox") == "Y") setDeptTreeData();
		
		if(loadContent == 'true'){
    		CoviMenu_GetContent('/groupware/layout/board_DocHome.do?CLSYS=doc&CLMD=user&CLBIZ=' + g_bizSection + '&menuCode=' + menuCode);	
    	}

		//통합게시와 문서관리를 분류
		$("[name=btnWrite]").on("click",function(){
			var	url = '/groupware/layout/board_DocWrite.do?CLSYS=doc&CLMD=user&CLBIZ='+ g_bizSection +'&mode=create';
			
			if(CFN_GetQueryString("folderID") != "undefined" ){
				url += "&folderID="+CFN_GetQueryString("folderID");
			}

			if(CFN_GetQueryString("communityId") != "undefined" ){	//Community용 Parameter추가
				url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
			}
			CoviMenu_GetContent(url);
		});
		setMenuURL();
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
		
		$('#txtTotalSearch').on('keypress', function(e){ 
			if (e.which == 13) {
				e.preventDefault();
				if($('#txtTotalSearch').val() != ""){
					if (!XFN_ValidationCheckOnlyXSS()) { return; }
					
		        	var url = String.format('/groupware/layout/board_BoardList.do?CLSYS=doc&CLMD=user&CLBIZ=Doc&boardType=DocTotal&searchText={0}&searchType={1}', encodeURIComponent($('#txtTotalSearch').val()), "Subject");
					CoviMenu_GetContent(url);
					$('#txtTotalSearch').val("");
			    }
		    }
		});
	}

	$('#btnSearchTotal').on('click', function(){
		if (!XFN_ValidationCheckOnlyXSS()) { return; }
		
		var url = String.format('/groupware/layout/board_BoardList.do?CLSYS=doc&CLMD=user&CLBIZ=Doc&boardType=DocTotal&searchText={0}&searchType={1}',  encodeURIComponent($('#txtTotalSearch').val()), "Subject");
		CoviMenu_GetContent(url);
		$('#txtTotalSearch').val("");
	});
	//Left Menu 페이지 로드후 MenuID parameter 추가
	function setMenuURL(){
		$.each($('.cLnbMiddle [data-menu-url*=board_BoardList]'), function(i, item){ 
			var menuURL = $(this).attr('data-menu-url'); 
			menuURL+='&menuCode='+menuCode;
			$(this).attr('data-menu-url', menuURL );
		});
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
				"bizSection": param,
				"menuCode": menuCode
			},
			async:false,
			success:function (data) {
				var treeList = data.list;
				//바인딩할 Selector, Param, DisplayName, width, align, checkbox, ? )
				pTreeObject.setTreeList(pTreeDiv, treeList, "nodeName", "100%", "left", false, false, body);
				pTreeObject.expandAll(2);
				
				var tree_mobileStr = (Common.getBaseConfig('tree_mobileStr') == '') ? '' : Common.getBaseConfig('tree_mobileStr');
				$.each(treeList, function(idx, el){
					if (el.IsMobileSupport == 'Y') $("#folder_item_"+el.FolderID).html($("#folder_item_"+el.FolderID).text()+tree_mobileStr);
				});
				
				if ($("#"+pTreeDiv+"_AX_tree").height() == 0){
					$("#"+pTreeDiv+"_AX_tree, #"+pTreeDiv+"_AX_treeScrollBody, #"+pTreeDiv+"_AX_treeBody").css("height", "");
				}
				
				setTimeout(function(){
		 			if ($("#coviTree_FolderMenu .selected").length == 0 && typeof folderID != 'undefined' && folderID != ''){
			 			$("#folder_item_" + folderID).closest('.gridBodyTr').addClass('selected');
			 		}
		 		}, 300);
			},
			error:function (error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
		pTreeObject.displayIcon(true);
	}
	
	function setDeptTreeData(pTreeDiv){
		var deptFolderTree = new AXTree();
		var deptMenu = $("<li></li>").append($("<div class='selOnOffBox'/>")
			.append($("<a href='javascript:;' class='btnOnOff'><spring:message code='Cache.lbl_DepartDocBox'/><span></span></a>"))) // 부서 문서함
			.append($("<div id='deptFolderTreeArea' class='selOnOffBoxChk type02 boxList'/>")
				.append($("<div id='coviTree_DeptFolderMenu' class='treeList radio'/>")));
		
		$("#leftmenu > li:nth-child(2)").after(deptMenu);
		
		deptFolderTree.setConfig({
			targetID : "coviTree_DeptFolderMenu",	// HTML element target ID
			theme: "AXTree_none",		// css style name (AXTree or AXTree_none)
			xscroll: false,
			height: "100%",
			showConnectionLine: true,		// 점선 여부
			relation: {
				parentKey: "MemberOf",		// 부모 아이디 키
				childKey: "GroupCode"			// 자식 아이디 키
			},
			persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
			persistSelected: false,			// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
			colGroup: [{
				key: "GroupID",			// 컬럼에 매치될 item 의 키
				width: "100%",
				align: "left",	
				indent: true,					// 들여쓰기 여부
				getIconClass: function(){		// indent 속성 정의된 대상에 아이콘을 지정 가능
					var iconNames = "folder, AXfolder, movie, img, zip, file, fileTxt, company".split(/, /g);
					var iconName = "";
					if(typeof this.item.type == "number") {
						iconName = iconNames[this.item.type];
					} else if(typeof this.item.type == "string"){
						iconName = this.item.type.toLowerCase(); 
					} 
					return iconName;
				},
				formatter:function(){
					var anchorName = $("<a />").attr("id", "folder_item_"+this.item.GroupID);
					anchorName.text(this.item.DisplayName);
					
					var str = anchorName.prop("outerHTML");
					
					return str;
				}
			}],						// tree 헤드 정의 값
			body: {
				onclick:function(idx, item){
					// item.TransMultiDisplayName;
					var url = String.format('/groupware/layout/board_BoardList.do?CLSYS=Doc&CLMD=user&CLBIZ=Doc&boardType=Normal&menuID={0}&grCode={1}', menuID, item.GroupCode);
					CoviMenu_GetContent(url);
				},
				onexpand:function(idx, item){ //[Function] 트리 아이템 확장 이벤트 콜백함수
					$("#deptFolderTreeArea .treeBodyTable tr").removeClass("selected");
				}
			}									// 이벤트 콜벡함수 정의 값
		});
		
		deptFolderTree.displayIcon = function(value){
			if(value){
				$("[id^='"+this.config.targetID+"_AX_bodyNodeIcon']").css("display","block");
			}else{
				$("[id^='"+this.config.targetID+"_AX_bodyNodeIcon']").css("display","none");
			}
		}
		
		$.ajax({
			url: "/groupware/attendCommon/getDeptList.do",
			type: "POST",
			dataType: "json",
			success: function(data){
				var treeList = data.deptList;
				deptFolderTree.setList(treeList);
				deptFolderTree.displayIcon(false);
				deptFolderTree.expandAll(1);
			},
			error: function(error){
				//CFN_ErrorAjax("/groupware/layout/attendance_AttendanceBaseInfo.do", response, status, error);
			}
		});
	}
</script>
