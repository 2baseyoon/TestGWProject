<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>


<div class="layer_divpop ui-draggable boradPopLayer" id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent layerType02 treeRadioPop">
			<div class="">
				<div class="middle">
					<div id="coviTree_SearchMenu" class="treeList radio" style="height:290px;">
						
					</div>										
				</div>
				<div class="bottom">
					<div class="popTop">
						<p><spring:message code='Cache.msg_selectProject'/></p>	<!-- 분류를 선택해주세요. -->
					</div>
					<div class="popBottom">
						<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code="Cache.btn_Confirm"/></a>	<!-- 확인 -->
						<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code="Cache.btn_Cancel"/></a>				<!-- 취소 -->
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>
<script>
var collabAlloc= {
		mySearchTree :'',
		callbackFunc:CFN_GetQueryString("callBackFunc"),
		objectInit : function(){	
			this.mySearchTree = new coviTree();
			this.addEvent();
			this.getTreeData();
		}	,
		addEvent : function(){
			//닫기
			$("#btnClose").on('click', function(){
				Common.Close();
			});
			$("#btnSave").on('click', function(){
				var myArray = collabAlloc.mySearchTree.body.find("input[type=radio]:checked").val();
				var folderData = new Object;
				
				if(myArray != null){
					folderData = JSON.parse(myArray);
				}else{
					folderData  = null;
				}
				if(folderData == "" || folderData == 'undefined' || folderData == null ){
					Common.Warning("<spring:message code='Cache.msg_selectProject'/>");
				}
				folderData["taskSeq"]=CFN_GetQueryString("taskSeq");
				folderData["isExport"]=CFN_GetQueryString("isExport");
				

				if(collabAlloc.callbackFunc != undefined && collabAlloc.callbackFunc  != ''){
					window.parent.postMessage(
						    { functionName : collabAlloc.callbackFunc
						    		,params :folderData }
						    , '*' 
						);
				}
				Common.Close();
				
			})
		},
		getTreeData:function(){
			$.ajax({
				url:"/groupware/collabTask/getNoAllocProject.do",
				type:"POST",
				data:{
					"taskSeq": CFN_GetQueryString("taskSeq"),
					"callbackFunc" : collabAlloc.callbackFunc
				},
				success:function (data) {
					var List = data.list;
					if (data.list.length==0){
						Common.Warning("<spring:message code='Cache.msg_MyTFNone'/>");
					}	
					else{
						collabAlloc.mySearchTree.setTreeList("coviTree_SearchMenu", List, "nodeName", "170", "left", false, true);
					}
				},
				error:function (error){
					alert(error);
				}
			});
			collabAlloc.mySearchTree.displayIcon(true);
		}
}

$(document).ready(function(){
	collabAlloc.objectInit();
});


</script>
