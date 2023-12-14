<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
%>
<!-- 컨텐츠앱 추가 -->
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/contentsApp/resources/css/contentsApp.css">
<body>	

	<div class="layer_divpop">
		<div class="contentsAppPop">
			<div class="caContent">
		        <a class="btnTypeDefault btnPlusAdd" href="#" id="btnFolder"><spring:message code='Cache.btn_addFold'/></a>
		        <a class="btnTypeDefault btnSaRemove" href="#" id="btnFolderDel"><spring:message code='Cache.btn_deleteFolder'/></a>
		        
		        <div class="treeList radio radioType02 org_tree mScrollV scrollVType01 mCustomScrollbar _mCS_1 mCS_no_scrollbar" style="height:290px;">
		        	<div id="coviTree_FolderMenu"></div>
		        </div>
		
		        <div class="popTop">
		          <p><spring:message code='Cache.msg_moveFolder'/></p>
		        </div>
		        <div class="bottomBtnWrap">
		          <a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.btn_Confirm'/></a>
		          <a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.btn_Cancel'/></a>
		        </div>
		
		      </div>
		</div>
	</div>

</body>
</html>

<script type="text/javascript">
var boardDomainID = CFN_GetQueryString("domainID") == 'undefined'? Common.getSession('DN_ID') : CFN_GetQueryString("domainID");
var bizSection = 'Board';
var myFolderTree = new coviTree();
var folderID = CFN_GetQueryString("fId");
var targetFolderID = "";
var targetFolderType = "";

var body = { 
		onclick: function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
			targetFolderID = item.FolderID;
			targetFolderType = item.FolderType;
			myFolderTree.setFocus(idx);
		}
	};

folderInit();

function folderInit(){
	setTreeData();
	myFolderTree.expandAll(2);
	
	//폴더생성
	$("#btnFolder").off("click").on("click", function(){
		if (targetFolderID == ""){
			Common.Warning(Common.getDic("msg_apv_164"));	//대상 폴더를 선택하십시오.
			return false;
		}
		
		if(targetFolderType == "Board"){
			Common.Warning(Common.getDic("msg_apv_164"));	//대상 폴더를 선택하십시오.
			return false;
		}
		
		var popupID	= "ContentsFolderAddPopup";
		var openerID	= "";
		var popupTit	= Common.getDic("lbl_AddFolder");
		var popupYN		= "N";
		var popupUrl	= "/groupware/contents/ContentsFolderAddPopup.do?"
						+ "&fId="    	+ targetFolderID
						+ "&popupID="		+ popupID	
						+ "&openerID="		+ openerID	
						+ "&popupYN="		+ popupYN ;
		parent.Common.open("", popupID, popupTit, popupUrl, "530px", "330px", "iframe", true, null, null, true);
	});
	
	//폴더메뉴 삭제
	$("#btnFolderDel").on('click', function(){
		if (targetFolderID == ""){
			Common.Warning(Common.getDic("msg_apv_164"));	//대상 폴더를 선택하십시오.
			return false;
		}
		
		Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function(result){ // 선택한 항목을 삭제하시겠습니까?
			if (result) {
				$.ajax({
					type: "POST",
					url: "/groupware/board/manage/deleteBoard.do",
					data: {
						"folderID": targetFolderID
					},
					success: function(data){
						if(data.status === 'SUCCESS'){
							Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
							setTreeData();
							myFolderTree.expandAll(2);
						}else{
							Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
						}
					},
					error: function(response, status, error){
						CFN_ErrorAjax("/groupware/board/manage/deleteBoard.do", response, status, error);
					}
				});
			}
		});
	});
	
	//저장(이동)
	$("#btnSave").on('click', function(){
		if (targetFolderID == ""){
			Common.Warning(Common.getDic("msg_apv_164"));	//대상 폴더를 선택하십시오.
			return false;
		}
		
		if(targetFolderType == "Board"){
			Common.Warning(Common.getDic("msg_apv_164"));	//대상 폴더를 선택하십시오.
			return false;
		}
		
		
		//신규 생성일 경우 위치만 변경
		if (folderID == ""){
			var parentFolder = myFolderTree.getSelectedListParent();
			var myFolder = myFolderTree.getSelectedList();

			var folderPathName = "\\"+myFolder.item.DisplayName;
			
			if(!!(parentFolder.item)) {
				folderPathName = "\\" + parentFolder.item.DisplayName + folderPathName;
			}

			folderPathName = folderPathName.replace(/\;/g,"\\");
			parent.fn_moveFolder(myFolder.item.FolderID, folderPathName);
  			Common.Close();
		}else{
			//사용자 정의 필드 위치 변경
			$.ajax({
			  	type:"POST",
			  	url: "/groupware/contents/moveFolder.do",
			  	dataType : 'json',
			  	data: {
			  		"domainID": boardDomainID,
					"bizSection": bizSection,
			      	"folderID": folderID,
			      	"memberOf": targetFolderID		//타겟 folderID
			  	},
			  	success:function(data){
			  		if(data.status=='SUCCESS'){
			  			var folderPathName = data.folderPathName;
			  			folderPathName = folderPathName.replace(/\;/g,"\\");
			  			$("#folderPathName", parent.document).val(folderPathName);
			  			
			  			Common.Warning("<spring:message code='Cache.msg_Changed'/>"); //변경했습니다.
			  			Common.Close();
			   		}else{
			   			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");		//오류가 발생헸습니다.
			   		}
			  	}, 
			  	error:function(response, status, error){
			  	     CFN_ErrorAjax("/groupware/contents/moveFolder.do", response, status, error);
			  	}
			  });
		}  
		
	});
	
	//닫기
	$("#btnClose").on('click', function(){
		Common.Close();
	});
}

// 폴더 트리 조회
function setTreeData(){
	$.ajax({
		url:"/groupware/contents/selectContentsList.do",
		type: "POST",
		data: {
			"domainID": boardDomainID,
			"isFolderMenu":"Y"
		},
		async: false,
		success: function (data) {
			var List = data.list;
			
			myFolderTree.setTreeList("coviTree_FolderMenu", List, "nodeName", "170", "left", false, false, body);
		},
		error:function (error){
			alert(error);
		}
	});
	myFolderTree.displayIcon(true);
}

</script>