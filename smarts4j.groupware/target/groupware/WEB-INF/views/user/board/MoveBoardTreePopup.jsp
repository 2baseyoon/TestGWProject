<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<link rel="stylesheet" id="cCss" type="text/css" /> 
<link rel="stylesheet" id="cthemeCss" type="text/css" /> 

<style>
	#coviTree_SearchMenu.treeList input[type='radio'] { margin: 0px 5px 0 0 !important; }
	#coviTree_SearchMenu.treeList .AXTree_none .AXTreeScrollBody .AXTreeBody .treeBodyTable tbody tr td .bodyTdText a:last-child { display:inline !important; }
</style>

<div class="layer_divpop ui-draggable boradPopLayer" id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent layerType02 treeDefaultPop">
			<div class="">
				<div class="top">
					<select id="selectMenuID" class="selectType02"></select>
				</div>	
				<div class="middle">
					<div id="coviTree_SearchMenu" class="treeList radio" style="height:280px;">
					</div>										
				</div>
				<div class="bottom">
					<div class="popTop">
						<p id="confirmMsg"><spring:message code='Cache.msg_RUProcessBoard' /> </p>	<!-- 선택한 게시를 처리하시겠습니까?. -->
					</div>
					<div class="popBottom">
						<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveFolderID();"><spring:message code="Cache.btn_Confirm"/></a>	<!-- 확인 -->
						<a href="#" class="btnTypeDefault" onclick="closeLayer();"><spring:message code="Cache.btn_Cancel"/></a>	<!-- 취소 -->
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>
<script>
var bizSection = CFN_GetQueryString("bizSection");
var folderID = CFN_GetQueryString("folderID");
var menuID = CFN_GetQueryString("menuID");
var menuCode = CFN_GetQueryString("menuCode");
var communityID = CFN_GetQueryString("communityID");
var mode = CFN_GetQueryString("mode");
var multiFolderIDs = CFN_GetQueryString("multiFolderIDs") == "undefined" ? "" : CFN_GetQueryString("multiFolderIDs");

var mySearchTree = new coviTree();

var hiddenFolderID = null;
$(document).ready(function (){
	$("#selectMenuID").coviCtrl("setSelectOption", 
			"/groupware/admin/selectMenuList.do", 
			{domainID: Common.getSession("DN_ID"), bizSection: bizSection, communityID: communityID}
	).val(menuID);
	$("#selectMenuID").on('change', function(){
		menuID = $("#selectMenuID").val();
		setTreeData();
		//우선 적으로 2depth까지 expand
		mySearchTree.expandAll(2);
	});
	
	//게시판명 클릭시 라디오버튼 선택
	$(document).on('click', "tr[id^='coviTree_SearchMenu_AX_tr']",function(e){
		if($(e.currentTarget).hasClass("selected")){
			if(typeof $(e.currentTarget).find("input").attr('id') != "undefined" &&  $(e.currentTarget).find("input").attr('id') != "" ){
				mySearchTree.setCheckedObj('radio', $(e.currentTarget).find("input").attr('id').split("coviTree_SearchMenu_treeRadio_")[1], true);
			}
		}
	})
	$(document).on('click', "input[id^='coviTree_SearchMenu_treeRadio']",function(e){
	    var obj = JSON.parse($(e.currentTarget).val());
	    mySearchTree.setFocus(obj.__index);
	})
	
	//mode에 따라 문구 변경시 사용 case문으로 할까...?는 break 처리가 귀찮아서 if로 사용
	if(mode == "copy"){
		$("#confirmMsg").text("<spring:message code='Cache.msg_RUCopyNMoveBoard'/>");
	} else if (mode =="move"){
		$("#confirmMsg").text("<spring:message code='Cache.msg_RUCopyNMoveBoard'/>");
	} else {
		$("#confirmMsg").text("<spring:message code='Cache.msg_RUProcessBoard'/>");
	}
	
	//관리자 메뉴 랜더링 이후 폴더 트리메뉴 랜더링
	setTreeData();
	//우선 적으로 2depth까지 expand
	mySearchTree.expandAll(2);

	//팝업 모드 별 parent, opener Element참조용...개선이 필요함 구림
	if(parent != null 
			&& parent.$("#hiddenFolderID").val() != undefined 
			&& parent.$("#hiddenComment").val() != undefined){
		hiddenFolderID = parent.$("#hiddenFolderID");
		hiddenComment = parent.$("#hiddenComment");
	} else {
		hiddenFolderID = opener.$("#hiddenFolderID");
		hiddenComment = opener.$("#hiddenComment");
	}
	
	if (parent && parent.communityID != '' && parent.communityCssPath != '' && parent.communityTheme != ''){
		$("#cCss").attr("href",parent.communityCssPath + "/community/resources/css/community.css");
		$("#cthemeCss").attr("href",parent.communityCssPath + "/covicore/resources/css/theme/community/"+parent.communityTheme+".css");
	}
	else {
		$("#cCss, #cthemeCss").remove();
	}
});

function setTreeData(){
	$.ajax({
		url:"/groupware/board/selectRadioFolderTree.do",
		type:"POST",
		data:{
			"leftMenuType": "Total",	//Total: 전체항목, Favorite:즐겨찾기 추가된 항목
			"bizSection": bizSection,
			"folderID": folderID,
			"menuID": menuID,
			"menuCode": menuCode,
			"communityID": communityID,
			"multiFolderIDs": multiFolderIDs
		},
		async:false,
		success:function (data) {
			var List = data.list;
			//바인딩할 Selector, Param, DisplayName, width, align, checkbox, radio )
			mySearchTree.setTreeList("coviTree_SearchMenu", List, "nodeName", "170", "left", false, true);
		},
		error:function (error){
			alert(error);
		}
	});
	mySearchTree.displayIcon(true);
}

//하단의 닫기 버튼 함수
function closeLayer(){
	Common.Close();
}

function setFolderID(pFolderID){
	hiddenFolderID.val(pFolderID);

	
}

var folderName = "";
var folderIDs = "";
function saveFolderID(){
	var myArray = mySearchTree.body.find("input[type=radio]:checked").val();
	var folderData = new Object;
	
	if(!myArray){
		parent.Common.Warning("<spring:message code='Cache.msg_SelectBoard'/>", "Warning Dialog", function () {	//게시판을 선택해주세요.
	    });
		return;
	}
	
	folderData = JSON.parse(myArray);

	//문서게시의 경우 문서 이동사유를 작성해야 함
	if(bizSection == "Doc"){
		setFolderID(folderData.FolderID);
		parent.Common.open("", "commentPopup", "<spring:message code='Cache.lbl_ReasonForProcessing'/>", "/groupware/board/goCommentPopup.do?frangment=contents", "300px", "190px", "iframe", true, null, null, true);
	} else {
		//통합게시는 comment를 남기지않고 이동 처리
		parent._CallBackMethod(setFolderID(folderData.FolderID));
	}
	Common.Close();
}
</script>
