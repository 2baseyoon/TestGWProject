<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<style>
	.linePlus tr:first-child td, .linePlus tr:first-child th, .linePlus tr:last-child th {border-top: 1px solid #000000 !important; border-bottom: 1px solid #000000 !important;}	
	.linePlus td:first-child, .linePlus th:first-child {border-left: 1px solid #000000;}
    .tableStyle thead td, .tableStyle tbody td {color: #000; border-bottom: 1px solid #000000; border-top: 1px solid #000000; padding: 5px;  height: 31px; position: relative;}
	.tableStyle thead th, .tableStyle tbody th { height: 40px; border-bottom: 1px solid #000000; font-size: 13px; font-weight: bold; color: #000; background: #e8e8e8; }   
	.linePlus td, .linePlus th { border-right: 1px solid #000000;}
</style>
<head>
<title>CoviFlow4J</title>
	<script type="text/javascript">
	         var printDiv;
	         
	         window.onload = initOnload;
	         function initOnload() {
	             try {
	                 printDiv = opener.printDiv;
	                 $("#printShow").append(printDiv);
	                 $("#printShow > .form_box").css("overflow", "visible");
	                 $("#TIT_ATTFILEINFO").attr("style","border-top:1px solid #000000");
	                 $("#trDocLinkInfoAddmark").attr("style","border-top:1px solid #000000");
	                 $(".table_form_info_draft").attr("style","margin-top: 5px; padding:5xp 5px 5px 5px; table-layout: fixed; min-height: 580px; width:100%; border:1px solid #000000; word-break:break-all;　")
	                 setTimeout(function(){
	                	 window.print();
	                	 //setInterval('window.close()', '100');				// (2015-07-16 leesm) 크롬에서 print 팝업 페이지가 빨리 close되어 인쇄할 수 없으므로 추가함
	                	 }, 300);
	             }
	             catch (e) {
	                 alert(e.description);
	             }
	
	         }
	
	
	         $(document).ready(function () {
	             if (opener.document.getElementById($("#hidPrintContainerID").val()) != undefined) {
	                 document.getElementById("printShow").innerHTML = opener.printDiv;
	                 // 투명 레이어 깔기
	             }
	         });
	</script>
</head>
<body  style='margin:0px;'>
   <div id='printShow'></div>
</body>