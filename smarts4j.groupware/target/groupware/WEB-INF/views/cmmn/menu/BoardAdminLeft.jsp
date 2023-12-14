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
	max-height: 398px;
}
</style>

<nav class="lnb">
	<h2 class="gnb_left_tit">
		<span class="gnb_tit">통합 게시</span>
	</h2>
	<div>
		<%-- <label>
			<spring:message code="Cache.lbl_Domain" />&nbsp;
			<select id="domainIDSelectBox" onchange="javascript:changeCompany();"></select>
		</label> --%>
		<select id="domainIDSelectBox" class="AXSelect W200" onchange="javascript:changeCompany();"></select>
	</div>
	
	<ul id="lnb_con" class="lnb_list"></ul>
</nav>

<script type="text/javascript">
	var boardDomainID = CFN_GetQueryString("domainID") == 'undefined'? Common.getSession('DN_ID') : CFN_GetQueryString("domainID");
	var myFolderTree = new coviTree();
	var bizSection = 'Board';
	
	var left_orgMenuID = "";
	var left_orgFolderID = "";

	var body = { 
		onclick: function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
			selectFolderGridListByTree(item.MenuID, item.FolderID, item.FolderType, item.FolderPath, idx);
			myFolderTree.setFocus(idx);
		}
	};
	
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	
	leftInit();
	
	function leftInit(){
		$("#domainIDSelectBox").coviCtrl("setSelectOption", "/groupware/admin/selectDomainList.do");
		$("#domainIDSelectBox").val(boardDomainID);
		
		//left menu 그리는 부분
		var portalLeft = new CoviMenu({
   			lang: "ko",
   			isPartial: "true"
    	});
		portalLeft.render('#lnb_con', leftData, 'adminLeft');
		
		//관리자 메뉴 랜더링 이후 폴더 트리메뉴 랜더링
		var normalMenu = '';
		$.each($("#lnb_con li"), function(idx, el){
			if (el.dataset.menuUrl && el.dataset.menuUrl.indexOf('Normal') > -1)
				normalMenu = el;
		});
		$(normalMenu).after("<li style='list-style: none; border: 0;'><div id='coviTree_FolderMenu' class='treeList'/></li>");
		$(normalMenu).css("border", 0);
		$(normalMenu).find("a:first").css("padding-bottom", 0);
		
		setTreeData();
		myFolderTree.expandAll(2);
		myFolderTree.setConfig({
			contextMenu: {
				theme: "AXContextMenu", // 선택항목
	            width: "150", // 선택항목
           		menu: [
	                {
	                    userType:1, label:"<spring:message code='Cache.lbl_new'/>", className:"plus", onclick:function(){
								ctxCreateBoardPopup(this.sendObj.MenuID, this.sendObj.FolderID);
	                    }
	                },
	                {
	                    userType:2, label:"<spring:message code='Cache.lbl_delete'/>", className:"minus", onclick:function(){
	                    	ctxDeleteBoard(this.sendObj.MenuID, this.sendObj.FolderID);
	                    }
	                },
	                {
	                    userType:1, label:"<spring:message code='Cache.lbl_paste'/>", className:"paste", onclick:function(){
	                    	ctxPasteBoard(this.sendObj.MenuID, this.sendObj.FolderID, this.sendObj.FolderPath, this.sendObj.SortPath);
	                    }
	                },
	                {
	                    userType:2, label:"<spring:message code='Cache.lbl_Cut'/>", className:"cut", onclick:function(){
	                    	ctxCutBoard(this.sendObj.MenuID, this.sendObj.FolderID, this.sendObj.SortPath, this.sendObj.FolderPath);
	                    }
	                },
	                {
	                    userType:0, label:"<spring:message code='Cache.lbl_Property'/>", className:"edit", onclick:function(){
	                    	ctxEditBoardPopup(this.sendObj.MenuID, this.sendObj.FolderID);
	                    }
	                }
	                
	            ],
	            filter: function(id){
	            	if(this.sendObj.FolderType == 'Root'){
	                	return (this.menu.userType == 0 || this.menu.userType == 1);
	            	} else if (this.sendObj.FolderType =='Folder'){
	            		return true;
	                } else {
	                	return (this.menu.userType == 0 || this.menu.userType == 2);
	                } 
	            }
        	}
		});
		
		setBoardMenuActive();
        
		if(loadContent == 'true'){
    		CoviMenu_GetContent('/groupware/layout/board_boardManage.do?CLSYS=Board&CLMD=admin&CLBIZ=Board&domainID='+$("#domainIDSelectBox").val());	
    	}
	}
	
	function changeCompany(){
		var url = '/groupware/layout/board_boardManage.do?CLSYS=Board&CLMD=admin&CLBIZ=Board&domainID='+$("#domainIDSelectBox").val();
		if (CFN_GetQueryString("boardType") != 'undefinded') url += '&boardType=' + CFN_GetQueryString("boardType");
		
		if (left_orgMenuID != "" && left_orgFolderID != "") {
			Common.Confirm(Common.getDic('msg_confirm_initTempFolder'), "Confirmation Dialog", function(result){
				if (result) {
					if($("#domainIDSelectBox").val()!=""){
						left_orgMenuID = "";
						left_orgFolderID = "";
						setTreeData();
						setBoardMenuActive();
						CoviMenu_GetContent(url);
					}
				}
				else {
					$("#domainIDSelectBox").val(boardDomainID);
				}
			});
		}
		else {
			if($("#domainIDSelectBox").val()!=""){
				setTreeData();
				setBoardMenuActive();
				CoviMenu_GetContent(url);
			}
		}
	}

	function setTreeData(){
		$.ajax({
			url: "/groupware/admin/selectFolderTreeData.do",
			type: "POST",
			data: {
				"domainID": $("#domainIDSelectBox").val(),
				"bizSection": bizSection
			},
			async: false,
			success: function (data) {
				var List = data.list;
				//바인딩할 Selector, Param, DisplayName, width, align, checkbox, ? )
				myFolderTree.setTreeList("coviTree_FolderMenu", List, "nodeName", "170", "left", false, false, body);
				$("#lnb_con li.list_1dep a").attr("onclick", "CoviMenu_ClickLeft(this); setBoardMenuActive(); return false;");
			},
			error:function (error){
				alert(error);
			}
		});
		myFolderTree.displayIcon(true);
	}
	
	function leftmenu_goToPageMain(){
		location.href = "/groupware/admin/boardManage.do";
	}

	// 추가 버튼에 대한 레이어 팝업
	function ctxCreateBoardPopup(pMenuID, pFolderID){
		parent.Common.open("","createBoard","<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderAdd'/>","/groupware/admin/goBoardConfigPopup.do?folderID="+pFolderID+"&menuID="+pMenuID+"&mode=create&bizSection=Board&domainID="+$("#domainIDSelectBox").val(),"750px","600px","iframe",true,null,null,true);
	}
	
	function ctxEditBoardPopup(pMenuID, pFolderID){
		parent.Common.open("","editBoard","<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderModify'/>","/groupware/admin/goBoardConfigPopup.do?folderID="+pFolderID+"&menuID="+pMenuID+"&mode=edit&bizSection=Board&domainID="+$("#domainIDSelectBox").val(),"750px","600px","iframe",true,null,null,true);
	}
	
	
	//context 잘라내기 클릭
    function ctxCutBoard(pMenuID, pFolderID) {
        left_orgMenuID = pMenuID; 
        left_orgFolderID = pFolderID;
        Common.Inform("<spring:message code='Cache.msg_TempSaveCuttingFolder'/>");   //잘라낼 폴더를 임시 저장했습니다
    }

	//context 붙여넣기 클릭
	function ctxPasteBoard(pMenuID, pFolderID, pFolderPath, pSortPath){
		if (left_orgFolderID == "") {
            Common.Inform("<spring:message code='Cache.msg_NoCuttedFolder'/>");  //잘라낸 폴더가 없습니다
            return;
        }
		
		Common.Confirm("<spring:message code='Cache.msg_inheritedAclDeleted'/>", "Confirm Dialog", function(result){ // 작업 수행 시 기존에 상속 받았던 권한은 삭제됩니다.<br>계속 진행하시겠습니까?
			if (result) {
				$.ajax({
					type:"POST",
					url:"/groupware/admin/pasteBoard.do",
					data:{
						"orgMenuID": left_orgMenuID,
						"orgFolderID": left_orgFolderID,
						"targetMenuID": pMenuID,
						"targetFolderID": pFolderID,
						"targetFolderPath": pFolderPath,
						"targetSortPath": pSortPath
					},
					success:function(data){
						Common.Inform("<spring:message code='Cache.msg_Processed'/>", "Information", function () {
							setTreeData();
		            		myFolderTree.expandAll(2);
		                  	folderGrid.reloadList();
						}); 
					},
					error:function(error){
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
					}
				});
			}
		});
	}

	//context 삭제 - API는 동일하지만 Param처리 및 Page가 동일 하지 않으므로 분리 하여 구현
	function ctxDeleteBoard(pMenuID, pFolderID){
		Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
            if (result) {
               $.ajax({
               	type:"POST",
               	url:"/groupware/admin/deleteBoard.do",
               	data:{
                   	"menuID": pMenuID,
               		"folderID":pFolderID
               	},
               	success:function(data){
               		if(data.status=='SUCCESS'){
               			Common.Warning("<spring:message code='Cache.msg_50'/>", "Warning Dialog", function () {// 삭제되었습니다.
               				setTreeData();
            				myFolderTree.expandAll(2);
                  			folderGrid.reloadList();
        				});
               			//page reload
               		}else{
               			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
               		}
               	},
               	error:function(error){
               		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");// 오류가 발생헸습니다. 
               	}
               	
               });
            }
        });
	}
	
	function setBoardMenuActive(){
		$("#lnb_con .admin-menu-active").removeClass("admin-menu-active");
		myFolderTree.clearFocus();
		
		$.each($("#lnb_con li"), function(idx, el) {
		    if (el.dataset.menuUrl && decodeURIComponent(el.dataset.menuUrl).indexOf(CFN_GetQueryString('boardType')) > -1)
		        $(el).find("a:first").addClass("admin-menu-active");
		});

		// 메뉴와 url의 boardType이 일치하는 항목이 없는 경우, 첫번째 li 요소에 클래스 부여
		if ($("#lnb_con .admin-menu-active").length == 0)
			$("#lnb_con li:first a:first").addClass("admin-menu-active");
	}
</script>
