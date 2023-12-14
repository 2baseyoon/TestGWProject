<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="layer_divpop ui-draggable boradPopLayer" id="testpopup_p" style="width:349px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
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
						<a href="#" class="btnTypeDefault btnTypeBg" onclick="exportPopup.exportNotice();"><spring:message code="Cache.btn_Confirm"/></a>	<!-- 확인 -->
						<a href="#" class="btnTypeDefault" onclick="exportPopup.closeLayer();"><spring:message code="Cache.btn_Cancel"/></a>	<!-- 취소 -->
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>
<script>
var exportPopup = {
		domainID : CFN_GetQueryString("domainID"),
		messageID  : CFN_GetQueryString("messageID"),
		version : CFN_GetQueryString("version"),
		mySearchTree : new coviTree(),
		initContent:function(){
			$("#selectMenuID").coviCtrl("setSelectOption", "/groupware/board/manage/selectMenuList.do",	{domainID: this.domainID});
			$("#selectMenuID").on('change', function(){
				exportPopup.setTreeData();
				//우선 적으로 2depth까지 expand
				exportPopup.mySearchTree.expandAll(2);
			});
			
			//관리자 메뉴 랜더링 이후 폴더 트리메뉴 랜더링
			exportPopup.setTreeData();
			//우선 적으로 2depth까지 expand
			exportPopup.mySearchTree.expandAll(2);
			
			//게시판명 클릭시 라디오버튼 선택
			$(document).on('click', "a[id^='folder_item']",function(e){
				exportPopup.mySearchTree.setCheckedObj('radio', e.currentTarget.id.split("folder_item_")[1], true);
			})
			
			
		},
		setTreeData:function(){
			$.ajax({
				url:"/groupware/board/manage/selectRadioFolderTree.do",
				type:"POST",
				data:{
					"domainID": this.domainID,
					"menuID": $("#selectMenuID").val(),
				},
				async:false,
				success:function (data) {
					var List = data.list;
					//바인딩할 Selector, Param, DisplayName, width, align, checkbox, radio )
					exportPopup.mySearchTree.setTreeList("coviTree_SearchMenu", List, "nodeName", "170", "left", false, true);
				},
				error:function (error){
					alert(error);
				}
			});
			exportPopup.mySearchTree.displayIcon(true);
		},
		exportNotice:function(){
			var myArray = exportPopup.mySearchTree.body.find("input[type=radio]:checked").val();
			var folderData = new Object;
			
			if(!myArray){
				parent.Common.Warning("<spring:message code='Cache.msg_SelectBoard'/>", "Warning Dialog", function () {	//게시판을 선택해주세요.
			    });
				return;
			}
			
			folderData = JSON.parse(myArray);

			//통합게시는 comment를 남기지않고 이동 처리
			Common.Confirm(Common.getDic("msg_RURegist"), 'Confirmation Dialog', function (result) {	
	            if (result) {
					$.ajax({
				    	type:"POST",
				    	url:"/groupware/board/manage/exportMessage.do",
				    	data:{"messageID": exportPopup.messageID
				    		,"version": exportPopup.version
				    		,"domainID":exportPopup.domainID
				    		,"folderID": folderData.FolderID
				    	},
				    	success:function(data){
				    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
				    			Common.Inform(Common.getDic('msg_task_completeCopy')); // 복사 되었습니다.
			    				parent.confNotice.searchList();;	
				    		}else{
				    			if (data.message != ""){
				    				Common.Warning(data.message);//오류가 발생헸습니다.
				    			}
				    			else{
				    				Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
				    			}	
				    		}
				    	},
				    	error:function(response, status, error){
				    	     CFN_ErrorAjax("/groupware/board/copyMessage.do", response, status, error);
				    	}
				    });
					
					Common.Close();
	            }
			});    
		},
		closeLayer: function(){
			Common.Close();
		}
};

$(document).ready(function (){
	exportPopup.initContent();
});

</script>
