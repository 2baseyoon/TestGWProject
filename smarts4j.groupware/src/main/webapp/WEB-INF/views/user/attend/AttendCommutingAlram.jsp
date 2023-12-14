<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%
	String serverTime = ComUtils.GetLocalCurrentDate("yyyy/MM/dd/HH/mm/ss");
%>
<!doctype html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript">

var _commuteType = "${commuteType}";
var _targetDate = "${targetDate}";

$(document).ready(function(){
	init();
	
});


function init(){
	
	var popMsg = "";
	var msg1 = "";
	var msg2 = "";
	if(_commuteType == "S"){	//출근
		msg1 = "<spring:message code='Cache.msg_att_commuAlramMsgY'/>";
		msg2 = "<spring:message code='Cache.msg_att_commuAlramY'/>";
	}else if(_commuteType == "E"){	//퇴근

		msg1 = "<spring:message code='Cache.msg_att_commuAlramMsgN'/>";
		msg2 = "<spring:message code='Cache.msg_att_commuAlramN'/>";
	}else if(_commuteType == "SE"){ //퇴근  (전날 미처리건)
		msg1 = String.format("<spring:message code='Cache.msg_n_att_commuAlramNotEnd'/>","${targetDate}");
		msg2 = "<spring:message code='Cache.msg_att_commuAlramN'/>";
		_commuteType = "E";
	}else if(_commuteType == "EE"){ //퇴근  (전날 미처리건)
		msg1 = "<spring:message code='Cache.mst_n_att_commuAlramReEnd'/>";
		msg2 = "<spring:message code='Cache.msg_att_commuAlramN'/>";
		_commuteType = "E";
	}
	$("#alramTimeMsg").html(popMsg);
	$("#msg1").html(msg1);
	$("#msg2").html(msg2);

}

function goSetStatus(){
	var reVal =  AttendUtils.setCommute('W',_commuteType,_targetDate);
	var status = reVal.status;
	if(status == "SUCCESS"){
		var msg = Common.getDic("msg_SuccessRegist");
		Common.Inform(msg,"Information",function(){
			parent.Common.Close('CommuAlram');
			parent.getCommuteData();
		}); 
	}else{
		Common.Warning(reVal.message);
	}
}

</script>
</head>
<body> 
<div class="popContent">
	<div class="popTop">
		<div class="am_pop_wrap">
			<span class="ic_am_pop"></span>
			<p class="am_pop_tx am_pop_tx_msg" id="msg1"></p>
			<p class="am_pop_tx" id="msg2"></p> 
		</div>
	</div>
	<div class="popBottom">
	 	<a href="#" class="btnTypeDefault btnTypeBg" onclick="goSetStatus();"><spring:message code='Cache.btn_ok'/></a>
		<a href="#" class="btnTypeDefault" onclick="parent.Common.Close('CommuAlram');"><spring:message code='Cache.btn_Cancel'/></a> 
	</div>
</div>	
</body>
</html>
