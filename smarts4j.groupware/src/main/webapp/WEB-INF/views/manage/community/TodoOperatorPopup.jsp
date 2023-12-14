<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<%
	String DNID = request.getParameter("DN_ID");
	String paramArr = request.getParameter("paramArr");
	String notiMail = request.getParameter("notiMail");
	String todoList = request.getParameter("todoList");
%>

<form>
	<div class="sadmin_pop">
		<table class="sadmin_table">
			<tr>
				<th>
					<span><spring:message code='Cache.lbl_Sendmessage'/></span> <!-- 메시지를 입력하세요. -->
				</th>
			</tr>
			<tr>	
				<td>
					<textarea name="popup_prompt" rows="10" cols="20" id="popup_prompt"  class="w100" ></textarea>
				</td>
			</tr>	
		</table>
	    <div class="pop_btn2" align="center">
	     	<a onclick="todoSave();"  class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_apv_save'/></a>                    
	     	<a onclick="Common.Close();"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>                    
	    </div>           
	</div>
</form>

<script  type="text/javascript">

(function() {
	
	var dnID = "<%=DNID%>";
	var paramArr = "<%=paramArr%>";
	var notiMail = "<%=notiMail%>";
	var todoList = "<%=todoList%>";

	this.todoSave = function() {
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
			url:"/groupware/manage/community/todoSendMessage.do",
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
			     CFN_ErrorAjax("/groupware/manage/community/todoSendMessage.do", response, status, error);
			}
		});
	}

})();

</script>