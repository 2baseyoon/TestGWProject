<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<style>
.AXTreeScrollBody { height: 100%; overflow: auto !important; }
</style>

<script type="text/javascript">
	var domainID =  CFN_GetQueryString("domainID") == 'undefined'? 0 : CFN_GetQueryString("domainID");
	var folderID =  CFN_GetQueryString("folderID");
	var callbackFunc = CFN_GetQueryString("callback");
	
 	var resourceTree = new coviTree(); 
 	
 	$(document).ready(function(){
 		setTreeData();
 	});
 	
 	function setTreeData(){
 		$.ajax({
 			url:"/groupware/resource/getOnlyFolderTreeList.do",
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
	 	
 		//resourceTree.expandAll(1)	// tree의 depth 1만 open
 		resourceTree.expandAll();
 		
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
 			Common.Warning(Common.getDic('msg_SelCate'));
 			return false;
 		}
 		XFN_CallBackMethod_Call("divResourceInfo",callbackFunc,  $("#hidFolderInfo").val());
 		parent.Common.close('findParentFolder');
 	}
</script>

<body>
	<form id="form1">
		<div>
			<div style="width: 100%; height: 290px; ">
				<div id="resourceTree" style="height:100%;"></div>
			</div>
			<div class="pop_btn2" align="center" style="margin-top:25px">
				<input type="button" value="<spring:message code='Cache.btn_Confirm'/>" onclick="returnFolder();" class="AXButton red" />
				<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="Common.Close();" class="AXButton" />                    
			</div>     
	  	</div>
	  	<input type="hidden" ID="hidFolderInfo" />
	</form>
</body>