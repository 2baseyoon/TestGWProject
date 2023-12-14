<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<%
	String DNID = request.getParameter("DN_ID");
	String paramArr = request.getParameter("paramArr");
	String notiMail = request.getParameter("notiMail");
	String todoList = request.getParameter("todoList");
%>

<form>
	<div class="pop_body1">
		<div id="popup_message" style="txt-align:center;overflow-y:auto;">
			<div style="padding-bottom: 10px; text-align: center;">
				<span><spring:message code='Cache.lbl_Sendmessage'/></span> <!-- 메시지를 입력하세요. -->
			</div>
			<textarea name="popup_prompt" rows="4" cols="20" id="popup_prompt"  style="width: 100%; vertical-align: middle; text-align: left; overflow: auto; resize: none;"></textarea>
		</div>
	</div>
	<div class="pop_btn2" align="center" style="margin-top: 10px;">
		<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="todoSave();" class="AXButton red" />
		<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="Common.Close();" class="AXButton" />
	</div>           
</form>

<script  type="text/javascript">
var dnID = "<%=DNID%>";
var paramArr = "<%=paramArr%>";
var notiMail = "<%=notiMail%>";
var todoList = "<%=todoList%>";

function todoSave(){
	$.ajax({
		type:"POST",
		data:{
			dnID : dnID,
			paramArr : paramArr,
			notiMail : notiMail,
			todoList : todoList,
			popup_prompt : $("#popup_prompt").val()
		},
		async : false,
		url:"/groupware/layout/community/todoSendMessage.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				alert("<spring:message code='Cache.msg_insert'/>");
				Common.Close();
			}else{ 
				alert("<spring:message code='Cache.msg_FailProcess' />");
				Common.Close();
			}
			
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/layout/community/todoSendMessage.do", response, status, error);
		}
	});
	
}

</script>