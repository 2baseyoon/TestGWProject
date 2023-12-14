<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<style>
	.AXTreeBody { height: calc(100% - 2px); }
</style>

<script type="text/javascript">
	var domainId = CFN_GetQueryString("domainId") == 'undefined' ? "0" :  CFN_GetQueryString("domainId");
 	var resourceTree = new coviTree(); 
 	
 	$(document).ready(function(){
 		setTreeData();
 	});

 	function setTreeData(){
 		$.ajax({
 			url:"/groupware/resource/getMainResourceTreeList.do",
 			type:"POST",
 			data:{
 				"domainID": domainId
 			},
 			async:false,
 			success:function (data) {
 				var List = data.list;
 				resourceTree.setTreeList("resourceTree", List, "nodeName", "170", "left", true, false);
 				setData();
 			},
 			error:function(response, status, error){
 				CFN_ErrorAjax("/groupware/resource/getResourceList.do", response, status, error);
 			}
 		});
 		
 		resourceTree.expandAll();
 	}
 	
 	function saveMainResource(){
 		Common.Progress(Common.getDic('msg_apv_008'));
 		
 		try {
 			var checkList = resourceTree.getCheckedTreeList('checkbox');
 	 		
 	 		var resourceIDs = "";
 	 		$.each(checkList,function(idx,obj){
 	 			resourceIDs += obj.nodeValue +";";
 	 		});
 	 		
 	 		$.ajax({
 	 			url:"/groupware/resource/insertMainResourceList.do",
 	 			type:"POST",
 	 			data: {
 	 				"domainID": domainId,
 	 				"resourceIDs": resourceIDs
 	 			},
 	 			success: function(data){
 	 				if(data.status=='SUCCESS'){
 	 		    		Common.Inform(Common.getDic('msg_37'), "Information", function(){	// 저장되었습니다.
 	 						if(parent.resourceGrid != undefined){ parent.resourceGrid.reloadList(); }		    			
 	 		    			Common.Close();
 	 		    		});
 	 	    		}else{
 	 	    			Common.Warning(Common.getDic('msg_sns_03'));	// 저장 중 오류가 발생하였습니다.
 	 	    		}
 	 			},
 	 			error: function(response, status, error){
 	 				CFN_ErrorAjax("/groupware/resource/insertMainResourceList.do", response, status, error);
 	 			}
 	 		});
 		}
 		catch (e){
 			coviCmn.traceLog(e.name, e.message);
 			Common.Error(Common.getDic('msg_ErrorOccurred'));
 		}
 	}
 	
 	function setData(){
 		$.ajax({
 			url:"/groupware/resource/getMainResourceList.do",
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
	    	     CFN_ErrorAjax("/groupware/resource/getMainResourceList.do", response, status, error);
	    	}
			
 		});
 		
 	}
 	
</script>

<body>
<form id="form1">
  <div>
	     <%-- 
	     <spring:message code="Cache.lbl_OwnedCompany"/>: <!-- 소유회사 -->
	         <select id="domainSelectBox" class="AXSelect W100"></select>--%>
	           <div style="width: 100%; height: calc(100% - 51px);">
	                  <div id="resourceTree" style="height:100%; overflow: auto;"></div>
	           </div>
	      
	     <div class="pop_btn2" align="center" style="width: 100%; margin-top: 25px; bottom: 0; position: fixed;">
	     	<input type="button" value="<spring:message code='Cache.btn_Confirm'/>" onclick="saveMainResource();" class="AXButton red" /><!-- 확인 -->
	     	<input type="button" value="<spring:message code='Cache.btn_Cancel'/>" onclick="Common.Close();"  class="AXButton" /><!-- 취소 -->      
	    </div>     
  </div>
  <input type="hidden" ID="hidFolderID" />
</form>
</body>