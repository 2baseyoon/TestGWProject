<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<script  type="text/javascript">

var option = '${option}';

$(window).load(function(){
	coviDic.render('con_acl_popup', JSON.parse(option));
	
	// 번역이 안되어 있는 언어 부분이 있다면 번역해서 띄워준다.
	if ($("#ko_full").val() != "") {
		if ($("#en_full").val() === "") {
			$("#en_full").siblings('input').trigger('click');
		}
		if ($("#ja_full").val() === "") {
			$("#ja_full").siblings('input').trigger('click');
		}	
		if ($("#zh_full").val() === "") {
			$("#zh_full").siblings('input').trigger('click');
		}
	}
});

</script>

<div id="con_acl_popup">				
</div>