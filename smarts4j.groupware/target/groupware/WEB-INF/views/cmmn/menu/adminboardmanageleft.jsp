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

</style>
<script type="text/javascript">
	var myFolderTree = new coviTree();
	var leftdata = ${adminBoardManageLeft};
	var domainList = ${domainList};			
	var	menuID = ${menuID};
	var leftmenuhtml = "";

	var left_orgMenuID = "";
	var left_orgFolderID = "";
	
	function changeCompany(){
		if($("#domainIDSelectBox").val()!=""){
			$(location).attr('href',$(location).attr('pathname')+"?domainID="+$("#domainIDSelectBox").val());
		}
	}

	function toggleleftmenu(pObj){
		$(pObj).parent().find("ul").toggle();
		
	}
	
	function drawLeftBoardMenu(pObj,pDepth) {
		var leftmenu_depth = pDepth + 1;
		$(pObj).each(function(){
			if(this.HasFolder != undefined && this.HasFolder.length > 0 && this.HasFolder == 'Y'){
				leftmenuhtml += String.format("<li class='list_{0}dep_close'><a href='{1}' onclick='toggleleftmenu(this);'>{2}</a>", leftmenu_depth, this.URL, this.DisplayName);
				leftmenuhtml += "<ul><div id='coviTree_FolderMenu' style='height:300px;'></div>";
				leftmenuhtml += "</ul>";
			} else {
				leftmenuhtml += String.format("<li class='list_{0}dep'><a href='{1}&domainID={2}'>{3}</a>", leftmenu_depth, this.URL, $("#domainIDSelectBox").val(), this.DisplayName);
			}
			leftmenuhtml += "</li>";
		});
	} 

	//tree 데이터 조회
	/*
	 * MenuID Fixed 데이터 사용중( Menu ID : 4 ) 동적으로 변경 필요
	 */

	function setTreeData(){
		$.ajax({
			url:"/groupware/admin/selectFolderTreeData.do",
			type:"POST",
			data:{
				"domainID" : $("#domainIDSelectBox").val(),
				"menuID": menuID
				
			},
			async:false,
			success:function (data) {
				var List = data.list;
				//바인딩할 Selector, Param, DisplayName, width, align, checkbox, ? )
				myFolderTree.setTreeList("coviTree_FolderMenu", List, "nodeName", "170", "left", false, false);
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
		parent.Common.open("","createBoard","<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderAdd'/>","admin/goBoardConfigPopup.do?folderID="+pFolderID+"&menuID="+pMenuID+"&mode=create","750px","600px","iframe",false,null,null,true);
		//objPopup.close(); 
	}
	
	function ctxEditBoardPopup(pMenuID, pFolderID){
		parent.Common.open("","editBoard","<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderModify'/>","admin/goBoardConfigPopup.do?folderID="+pFolderID+"&menuID="+pMenuID+"&mode=edit","750px","600px","iframe",false,null,null,true);
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
				Common.Warning("<spring:message code='Cache.msg_Processed'/>", "Warning Dialog", function () {
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
	
	$(document).ready(function (){
		$("#domainIDSelectBox").bindSelect({
			reserveKeys: {
				optionValue: "optionValue",
				optionText: "optionText"
			},
			options:domainList
		});
		
		drawLeftBoardMenu(leftdata,0);
		
		$(".lnb_list").html(leftmenuhtml);	
		
		//관리자 메뉴 랜더링 이후 폴더 트리메뉴 랜더링
		setTreeData();
		//우선 적으로 2depth까지 expandㅎ
		myFolderTree.expandAll(2);	

		myFolderTree.setConfig({contextMenu:{
			theme:"AXContextMenu", // 선택항목
            width:"150", // 선택항목
            menu:[
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
            filter:function(id){
            	if(this.sendObj.FolderType == 'Root'){
                	return (this.menu.userType == 0 || this.menu.userType == 1);
            	} else if (this.sendObj.FolderType =='Folder'){
            		return true;
                } else {
                	return (this.menu.userType == 0 || this.menu.userType == 2);
                } 
            }
        }});
	});
</script>

<nav class="lnb">
	<h2 class="gnb_left_tit"><span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false">통합 게시</span></h2>
	<div>
		<label>
			<spring:message code="Cache.lbl_Domain" />&nbsp;
			<select id="domainIDSelectBox" class="AXSelect W100" onchange="javascript:changeCompany();"></select>
		</label>
	</div>
	<ul class="lnb_list">
	</ul>
</nav>


