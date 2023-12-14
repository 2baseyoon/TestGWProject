<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="staffNews_popup">
	<div class="popContent">
		<textarea rows=10 cols=30 id="messsage" name="messsage">${messsage}</textarea>
	</div>
	<div class="bottom">
		<a href="#" id="btnModify" class="btnTypeDefault btnTypeChk" onclick="saveMessage()"><spring:message code="Cache.btn_Modify"/></a> <!-- 수정 -->
		<a href="#" id="btnCancel" class="btnTypeDefault"  onclick="closeMessage()"><spring:message code="Cache.btn_Cancel"/></a> <!-- 취소 -->
	</div>
	<input type="hidden" id="siteLinkID" />
</div>

<script>
function saveMessage(){
	var url = "/groupware/portal/saveCeoMessage.do";
	
	$.ajax({
		url: url,
		type: "POST",
		data: {"webpartID":"${webpartID}","settingKey":"${settingKey}","settingVal":$("#messsage").val()},
		success: function(data){
				window.parent.postMessage(
						{ functionName :"ceoMessage"
					    		,params:{"webpartID":"${webpartID}", "status":data.status,"message":$("#messsage").val()}
					    }
						, '*' 
					);
				Common.Close();
		},
		error: function(response, status, error){
			CFN_ErrorAjax(url, response, status, error);
		}
	});
}
function closeMessage(){
	window.parent.postMessage(
			{ functionName :"ceoMessage"
		    		,params:{"webpartID":"${webpartID}", "status":"FAIL"}
		    }
			, '*' 
		);
	Common.Close();

}


</script>

