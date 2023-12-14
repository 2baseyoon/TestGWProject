<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<head>
<title>CoviFlow4J</title>
<script type="text/javascript">
	         var printDiv;
	         
	         function initOnload() {
	             try {
	            	 var _isIframe = false;
	            	 var isAccount = false;
	            	 if(parent && parent != window) {
	            		 // Iframe type
	            		 _isIframe = true;
	            		 printDiv = parent.printDiv;
	            		 isAccount = parent.$("iframe#printIfr").prop("isAccount") == "Y" ? true : false;
	            	 }else if(opener && !opener.closed){
	            		 printDiv = opener.printDiv;
	            		 isAccount = opener.$("iframe#printIfr").prop("isAccount") == "Y" ? true : false;
	            	 }
	                 $("#printShow").append(printDiv);
	                 $("#printShow > .form_box").css("overflow", "visible");
	                 $("#printShow > #evidPreview").css("display", "none");

					if(isAccount){ //출력시 rowspan으로인한 깨짐현상 대응
					    $("#printShow .allMakeView").css("margin-top","30px").removeClass("allMakeView");
					    $("#printShow table [name=EditArea]").remove();
					}
                	 window.print();
                	 //window.close();
                	 // (2015-07-16 leesm) 크롬에서 print 팝업 페이지가 빨리 close되어 인쇄할 수 없으므로 추가함
                	 if(!_isIframe) {
                	     // popup 방식일 경우 크롬인쇄 Layer 에서 "시스템 대화상자를 사용하여 인쇄" 기능 사용시 창이 닫힘.
                	 	 setInterval(function() {window.close();}, 1500);
                	 }
	             }
	             catch (e) {
	                 alert(e.description);
	             }
	         }
	
	         $(document).ready(function () {
	             initOnload();
	         });
	</script>
<style>
.eaccounting_bill {
	width: 300px;
	margin: 20px;
	float: left;
}

.invoice_no {
	margin-top: 10px;
}
</style>
</head>
<body style='margin: 0px;'>
	<div id='printShow'></div>
</body>