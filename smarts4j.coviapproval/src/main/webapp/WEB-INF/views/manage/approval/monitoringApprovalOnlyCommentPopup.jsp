<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<% String approvalAppPath = PropertiesUtil.getGlobalProperties().getProperty("approval.app.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="<%=approvalAppPath%>/resources/script/admin/Monitoring.js<%=resourceVersion%>"></script>
<script>
	var sMode = "${mode}";

	//엔진호출
	function approveProcess(){
		var apvLineObj = $.parseJSON(opener.$("#APVLIST").val());
		
		var person = $$(apvLineObj).find(opener.$("#hidDPath").val());
		var taskID = $$(person).parent().attr("taskid");
		
		var comment = Base64.utf8_to_b64($("#txtComment").val());
		var approvalAction = sMode;
		
		if((approvalAction == "REJECT" || approvalAction == "ABORT") && comment == ""){
        	Common.Warning("<spring:message code='Cache.msg_apv_064' />", "Warning", function(){
        		return false;
        	});
        }
		else {
			var apiData = {};
	        $$(apiData).append("g_action_"+taskID, approvalAction);
	        $$(apiData).append("g_actioncomment_"+taskID, comment);
	        $$(apiData).append("g_actioncomment_attach_"+taskID, []);
	        $$(apiData).append("g_signimage_"+taskID, "");
	        $$(apiData).append("g_isMobile_"+taskID, "N");
	        $$(apiData).append("g_isBatch_"+taskID, "N");
	            
	     	// 임시함에 저장될 문서 결재선 변경하기 위해 사용함.
	     	if(approvalAction == "ABORT") {
	        	$$(apiData).append("g_appvLine", opener.getApvList(opener.$("#APVLIST").val()));
	        	
	        	// 의견첨부 삭제 시 사용
	            var oCommentFile = $$(apvLineObj).find("step").concat().find("comment_fileinfo");
	            if(oCommentFile.length > 0) {
	            	$$(apiData).append("commentFileInfos", JSON.stringify($$(oCommentFile).json()));
	            }
	     	}
	        
			callRestAPI(taskID, apiData);	
		}
	}
	
	function Close(){
		Common.Close();
	}
</script>
<body>
	<div style="margin: 10px">
		<h3 class="con_tit_box">
			<span class="con_tit">수동 결재하기(의견입력)</span>	
		</h3>
		<div>
			<table id="" class="AXFormTable" width="100%">
				<colgroup>
					<col style="width: 30%">
					<col style="width: 70%">
				</colgroup>
				<tr>
					<th>결재 의견</th>
					<td>
						<textarea id="txtComment" name="txtComment" rows="12" style="width:98%;resize:none" ></textarea>
					</td>
				</tr>
			</table>
			<br>
			<div align="center">
				<input type="button" class="AXButton Blue" value="결재하기" onclick="approveProcess();"/>
				<input type="button" class="AXButton" value="닫기" onclick="Close();"/>
			</div>
		</div>
	</div>
	
</body>
</html>