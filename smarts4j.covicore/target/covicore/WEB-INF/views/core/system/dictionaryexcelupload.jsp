<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
<script>
function closeLayer(){
	Common.Close();
}

</script>
<div align="center" >
	<div>
	※ <spring:message code="Cache.msg_ExcelUpload2"/>
	</div>
	<div style="padding-top: 10px">
		<input type="text" id="downloadurlinput" readonly="readonly" class="AXInput" />
		<input type="button" value="<spring:message code="Cache.btn_FindFiletoUpload"/>"  class="AXButton"/>
	</div>
	<div style="padding-top: 10px">
		<input type="button" value="<spring:message code="Cache.btn_Upload"/>" onclick="" class="AXButton"/>
		<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer()" class="AXButton"/>
	</div>
</div>