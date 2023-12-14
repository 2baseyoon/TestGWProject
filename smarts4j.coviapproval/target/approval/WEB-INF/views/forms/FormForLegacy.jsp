<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<div>
	<input type="hidden" id="htmlBody" name="htmlBody" value="">
	<input type="hidden" id="mobileBody" name="mobileBody" value="">
	<input type="hidden" id="jsonBody" name="jsonBody" value="">
	<input type="hidden" id="bodyContext" name="bodyContext" value="">
	<input type="hidden" id="subject" name="subject" value="">
	<input type="hidden" id="legacyApprovalLine" name="legacyApprovalLine" value="">
</div>
<script>

var htmlBody = "${HTMLBody}";
var mobileBody = "${MobileBody}";
var jsonBody = "${JSONBody}";
var bodyContext = "${BodyContext}";
var subject = "${Subject}";
var logonid = "${logonid}";
var language = "${language}";
var legacyApprovalLine = "${legacyApprovalLine}";

initContent();

function initContent(){
	debugger;
	if("${status}" == "SUCCESS"){
		$("#htmlBody").val(htmlBody);
		$("#mobileBody").val(mobileBody);
		
		jsonBody = decodeURIComponent(escape(window.atob( jsonBody )));			//Base64.b64_to_utf8(jsonBody);
		$("#jsonBody").val(jsonBody);
		
		$("#bodyContext").val(bodyContext);
		$("#subject").val(subject);
		$("#legacyApprovalLine").val(legacyApprovalLine);
		
		debugger;
		var url = "${URL}";
		var width = "${width}";
	    
	    var form = document.createElement("form");
	    form.method = "POST";
	    form.action = url;
	    form.style.display = "none";

	    form.appendChild(document.getElementById("htmlBody"));
	    form.appendChild(document.getElementById("mobileBody"));
	    form.appendChild(document.getElementById("jsonBody"));
	    form.appendChild(document.getElementById("bodyContext"));
	    form.appendChild(document.getElementById("subject"));
	    form.appendChild(document.getElementById("legacyApprovalLine"));

	    document.body.appendChild(form);
	    
	    /*
	    // 미사용 goFormLink.do에서 모두 처리하도록 변경
	    var url = "/approval/legacy/loginchk.do";
	    $.ajax({
		method: "POST",
		    data: {empno : logonid, language: language},
			url: url,
			success:function (data) {
				 if(data.status=="ok"){
					 form.submit();
				 } else{
					alert("fail login");
					return ;
				 }
			
			}
		
		});  
	    */
	    form.submit();
	    
	}else{
		alert("${message}");
		if (opener != null) window.close();
		else history.go(-1);
	}
}

</script>