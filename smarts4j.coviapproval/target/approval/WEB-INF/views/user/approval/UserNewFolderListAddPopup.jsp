<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript"
	src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>

<div class="divpop_contents">
	<div class="popBox">
		<div class="bgPop">
			<dl class="editList">
				<dt>
					<spring:message code='Cache.lbl_apv_folderName' />
				</dt>
				<dd>
					<input type="text" class="W300" id="insertFolederNm" onkeypress="if(event.keyCode == 13) { InsertFolderList(); return false; }">
				</dd>
				<dd>
					<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="InsertFolderList()" class="smSave">
				</dd>
			</dl>
		</div>
	</div>
</div>

<script>
	var type = CFN_GetQueryString("type");
	var FolderID = CFN_GetQueryString("FolderID");
	
	// 폴더등록
	function InsertFolderList() {
		// 체크된 항목 확인
		var seleteCheck;
		if (type == "1Lv") {
			seleteCheck = "";
		} else {
			seleteCheck = FolderID;
		}
		var FolDerName = $("#insertFolederNm").val().trim();
		
		if (FolDerName == "") {
			parent.Common.Warning("<spring:message code='Cache.msg_295' />"); // 폴더명을 입력하세요
			return false;
		}
		
		$.ajax({
			url : "/approval/user/insertUserFolder.do",
			type : "post",
			data : {
				"ParentsID" : seleteCheck,
				"FolDerName" : FolDerName
			},
			async : false,
			success : function(res) {
				if (res.data == 1) {
					parent.Common.Inform("<spring:message code='Cache.msg_insert' />", "Inform", function() {
						Common.Close();
						parent.Refresh();
					});
				} else {
					parent.Common.Error(res.message, "Error");
				}
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("/approval/user/insertUserFolder.do", response, status, error);
			}
		});
	}
</script>