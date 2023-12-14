<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<script type="text/javascript">

(function() {
	var domainId = parent.$("#selectDomainList option:selected").val();

	var resourceTree = new coviTree(); 

	var initFunc = function() {
		setTreeData();
	}
	
 	var setTreeData = function() {
 		$.ajax({
 			url:"/groupware/resource/manage/getMainResourceTreeList.do",
 			type:"POST",
 			data:{
 				"domainID": domainId
 			},
 			async:false,
 			success : function (data) {
 				var List = data.list;
 				resourceTree.setTreeList("resourceTree", List, "nodeName", "170", "left", true, false);
 				setData();
 			},
 			error:function(response, status, error){
 				CFN_ErrorAjax("/groupware/resource/manage/getMainResourceTreeList.do", response, status, error);
 			}
 		});
 		resourceTree.expandAll();
 	}

 	var setData = function() {
 		$.ajax({
 			url:"/groupware/resource/manage/getMainResourceList.do",
 			type:"POST",
			data: {
				"domainID": domainId,
				"pageSize": 9999			// 전체 페이지를 가져오기 위하여 충분히 큰 값으로 사용.
			},
			success:function(data){
				if(data.status=='SUCCESS'){
					$.each(data.list, function(idx,obj){
						resourceTree.setCheckedObj('checkbox',obj.FolderID,true);
					});
				}
			},error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/resource/manage/getMainResourceList.do", response, status, error);
	    	}
 		});
 	}
 	
 	// 확인 버튼 클릭
 	this.saveMainResource = function() {
 		Common.Progress(Common.getDic('msg_apv_008')); 	// 처리 중입니다.
 		
 		try {
 			var checkList = resourceTree.getCheckedTreeList('checkbox');
 	 		
 	 		var resourceIDs = "";
 	 		
 	 		if(checkList.length > 0) {
 	 			$.each(checkList, function(idx,obj){
 	 	 			resourceIDs += obj.nodeValue +";";
 	 	 		});	
 	 		}
 	 		
 	 		$.ajax({
 	 			url:"/groupware/resource/manage/insertMainResourceList.do",
 	 			type:"POST",
 	 			data: {
 	 				"domainID": domainId,
 	 				"resourceIDs": resourceIDs
 	 			},
 	 			success: function(data) {
 	 				if(data.status=='SUCCESS'){
 	 		    		Common.Inform(Common.getDic('msg_37'), "Information", function() {	// 저장되었습니다.
 	 		    			// postMessage for callback.
							window.parent.postMessage({functionName : "resourceTree", param1 : "callback_saveMainResource"}, "*");	    			
 	 		    			
 	 		    			Common.Close();
 	 		    		});
 	 	    		}else{
 	 	    			Common.Warning(Common.getDic('msg_sns_03'));	// 저장 중 오류가 발생하였습니다.
 	 	    		}
 	 			},
 	 			error: function(response, status, error){
 	 				CFN_ErrorAjax("/groupware/resource/manage/insertMainResourceList.do", response, status, error);
 	 			}
 	 		});
 		}
 		catch (e){
 			Common.Error(Common.getDic('msg_ErrorOccurred')); 	// 오류가 발생하였습니다.
 		}
 	}
 	
 	$(document).ready(function() {
 		initFunc();
 	});
	
})();

</script>
<style>
.sadminContent .tblList .AXTreeScrollBody .AXTreeBody {
     top: 0px !important; 
}
</style>

<body>
<form id="form1">
	<div class="sadmin_pop sadminContent">
         <div style="width: 100%; height: calc(100% - 91px);border:1px solid #eaeaea !important">
               <div id="resourceTree" style="height:100%; overflow: auto;"></div>
         </div>
		<div class="bottomBtnWrap">
	     	<a class="btnTypeDefault btnTypeBg" onclick="saveMainResource();"><spring:message code='Cache.btn_Confirm'/></a><!-- 확인 -->
	     	<a class="btnTypeDefault" onclick="Common.Close();" ><spring:message code='Cache.btn_Cancel'/></a><!-- 취소 -->      
	    </div>     
  </div>
  <input type="hidden" ID="hidFolderID" />
</form>
</body>
