<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<script type="text/javascript">
	var domainID =  CFN_GetQueryString("domainID") == 'undefined'? 0 : CFN_GetQueryString("domainID");
	var folderID =  CFN_GetQueryString("folderID");
	var callbackFunc = CFN_GetQueryString("callback");
	
 	var resourceTree = new coviTree(); 
 	
 	$(document).ready(function(){
		$("#resourceTree .AXTreeBody").css("height",parseInt($("#resourceTree").css("height"))-20);
 		setTreeData();
 		
 	});
 	
 	
 	function setTreeData(){
 		$.ajax({
 			url:"/groupware/resource/manage/getOnlyFolderTreeList.do",
 			type:"POST",
 			data:{
 				"domainID": domainID
 			},
 			async:false,
 			success:function (data) {
 				var List = data.list;
 				resourceTree.setTreeList("resourceTree", List, "nodeName", "220", "left", true, false);
 			},
 			error:function(response, status, error){
 				CFN_ErrorAjax("/groupware/resource/getOnlyFolderTreeList.do", response, status, error);
 			}
 		});
 		
	 	resourceTree.setConfig({
			body: {
				onclick:function(idx, item){
					treeNode_Click(item.FolderID,item.MultiDisplayName);
				}
			}
		});
	 	
 		resourceTree.expandAll(1)	// tree의 depth 1만 open
 		
 		if(folderID!='undefined' && folderID != ""){
	 		$.each(resourceTree.list,function(idx,obj){
	 			if(obj.FolderID == folderID){
	 				resourceTree.click(idx,"open",'')
	 				return false;
	 			}
	 		});
 		}
 		
 	}
 	
 	function treeNode_Click(folderID,folderName) {
 	    $("#hidFolderInfo").val(folderID + "|" + folderName);
 	}
 	
 	function returnFolder(){
 		if( $("#hidFolderInfo").val() =="" ||  $("#hidFolderInfo").val() == 'undefined' ){
 			Common.Warning("<spring:message code='Cache.msg_SelCate'/>")
 			return false;
 		}
 		XFN_CallBackMethod_Call("divResourceInfo",callbackFunc,  $("#hidFolderInfo").val());
 		parent.Common.close('findParentFolder');
 	}
</script>

<body>
<form id="form1">
  <div class="sadmin_pop">
       <div id="resourceTree" style="border: 1px solid #CCCCCC"></div>
		<div class="bottomBtnWrap">
	     	<a onclick="returnFolder()"  class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.Cache.btn_apv_save'/></a>                    
	     	<a onclick="Common.Close();"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>                    
		</div>
	     <div class="pop_btn2" align="center" style="margin-top:25px">
	    </div>     
  </div>
  <input type="hidden" ID="hidFolderInfo" />
</form>
</body>