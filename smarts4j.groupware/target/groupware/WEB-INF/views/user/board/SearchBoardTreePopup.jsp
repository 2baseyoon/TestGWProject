<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>


<div class="layer_divpop ui-draggable boradPopLayer" id="testpopup_p" style="width:344px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent layerType02 treeRadioPop">
			<div class="">
				<div class="top">
					<select id="selectMenuID" class="selectType02">
					</select>
				</div>
				<div class="middle">
					<div id="coviTree_SearchMenu" class="treeList radio" style="height:290px;">
						
					</div>										
				</div>
				<div class="bottom">
					<div class="popTop">
						<p><spring:message code='Cache.msg_SelCate'/></p>	<!-- 분류를 선택해주세요. -->
					</div>
					<div class="popBottom">
						<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveFolderID();"><spring:message code="Cache.btn_Confirm"/></a>	<!-- 확인 -->
						<a href="#" class="btnTypeDefault" onclick="closeLayer();"><spring:message code="Cache.btn_Cancel"/></a>				<!-- 취소 -->
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>
<script>
var bizSection = CFN_GetQueryString("bizSection");
var docMultiFolder = CFN_GetQueryString("docMultiFolder") == "undefined" ? "N" : CFN_GetQueryString("docMultiFolder");
var mode = CFN_GetQueryString("mode");
var isEDMS = CFN_GetQueryString("isEDMS") == "undefined" ? "" : CFN_GetQueryString("isEDMS");

var mySearchTree = new coviTree();

$(document).ready(function (){
	$("#selectMenuID").coviCtrl("setSelectOption", 
			"/groupware/admin/selectMenuList.do", 
			{domainID: Common.getSession("DN_ID"), bizSection: bizSection}
	);
	
	$("#selectMenuID").on('change', function(){
		setTreeData();
	});
	
	//관리자 메뉴 랜더링 이후 폴더 트리메뉴 랜더링
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

function setTreeData(){
	$.ajax({
		url:"/groupware/board/selectRadioFolderTree.do",
		type:"POST",
		data:{
			"leftMenuType": "Total",
			"menuID": $('#selectMenuID').val(),
			"bizSection": bizSection,
			"isEDMS": isEDMS,
			"docMultiFolder": docMultiFolder
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

var folderName = "";
var folderIDs = "";
function saveFolderID(){
	var myArray = mySearchTree.body.find("input[type=radio]:checked").val();
	var folderData = new Object;
	
	if(myArray != null){
		folderData = JSON.parse(myArray);
	}else{
		folderData  = null;
	}
	
	if(folderData == "" || folderData == 'undefined' || folderData == null ){
		if(opener){
			if(isEDMS == "Y"){
				Common.Warning("<spring:message code='Cache.msg_selCategory'/>", "Warning Dialog", function () {});
			}else{
				Common.Warning("<spring:message code='Cache.msg_SelectBoard'/>", "Warning Dialog", function () {});
			}
		}else{
			if(isEDMS == "Y"){
				parent.Common.Warning("<spring:message code='Cache.msg_selCategory'/>", "Warning Dialog", function () {});
			}else{
				parent.Common.Warning("<spring:message code='Cache.msg_SelectBoard'/>", "Warning Dialog", function () {});
			}
		}
		return;
	}

	if(opener){
		opener._CallBackMethod(folderData);
	}else{
		parent._CallBackMethod(folderData);
	}
	
	Common.Close();
}
</script>
