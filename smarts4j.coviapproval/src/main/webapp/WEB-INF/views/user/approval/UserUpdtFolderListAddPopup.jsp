<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>

<div class="divpop_contents">
	<div class="popBox">
		<div class="bgPop">
			<dl class="editList">
				<dt>
					<spring:message code='Cache.lbl_apv_folderName' />
				</dt>
				<dd>
					<input type="text" class="W300" id="insertFolederNm" onkeypress="if(event.keyCode == 13) { UpdateFolder(); return false; }">
				</dd>
				<dd>
					<input type="button" value="<spring:message code='Cache.btn_Edit'/>" onclick="UpdateFolder()" class="smSave">
				</dd>
			</dl>
		</div>
	</div>
</div>

<script>
	var folderId = CFN_GetQueryString("folderId");
	var folderNm = urlDecodeValue(CFN_GetQueryString("folderNm"));
	 
	$("#insertFolederNm").val(folderNm);
	
	//수정버튼
	function UpdateFolder(){
		var FolDerName 		= $("#insertFolederNm").val().trim();
		
		if(FolDerName == ""){
			parent.Common.Warning("<spring:message code='Cache.msg_295' />");					// 폴더명을 입력하세요
			return false;
		}
		
		$.ajax({
			url:"/approval/user/updateUserFolder.do",
			type:"post",
			data:{
				"FolderId":folderId,
				"FolDerName":FolDerName
				},
			async:false,
			success:function (res) {
				parent.Common.Inform("<spring:message code='Cache.msg_Changed' />","Inform",function() {
					Common.Close();
					//parent.Refresh();
					parent.FolderRefresh();
				});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/updateUserFolder.do", response, status, error);
			}
		});
	}
</script>