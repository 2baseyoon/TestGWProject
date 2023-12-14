<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<head>
<title>CoviFlow4J</title>
	<script type="text/javascript">
		var printDiv;
		   window.onload = initOnload;
		   function initOnload() {
		       printCommand();
		   }
		   function printCommand() {
		       if (window.document.readyState == "complete") {
		           try {
		               printDiv = opener.printDiv;
		
		               $("#printShow").append(printDiv);
		               $("#printShow > .form_box").css("overflow", "visible");
		               $("#printShow > #evidPreview").css("display", "none");
		               if (window.ActiveXObject !== undefined) {
		                   //printGo();
		                   //printIE();
		                   print();
		                   //window.close();
		               } else {
		                   window.print();
		                   window.close();
		               }
		
		           } catch (e) {
		
		               // [2015-08-04 han modi] 설정 안내문구 추가
		               // alert(e.description);
		               if (e.description == "구성원이 없습니다.\r\n") {
		                   Common.Inform("<spring:message code='Cache.msg_apv_507' />");
		               } else {
		                   alert(e.description);
		               }
		
		           }
		       } else {
		           setTimeout("printCommand()", 500);
		       }
		   }
		
		   function printGo() {
		       try {
		           factory.printing.header = "";
		           factory.printing.footer = "";
		           factory.printing.portrait = true;
		           factory.printing.leftMargin = 5.0;
		           factory.printing.topMargin = 15.0;
		           factory.printing.rightMargin = 5.0;
		           factory.printing.bottomMargin = 15.0;
		           factory.printing.Preview();
		           //factory.printing.Print(false, window);
		       }
		       catch (e) { 
		    	   coviCmn.traceLog(e);
		       }
		       window.close();
		   }
		
		   function printIE() {
		       var wb = '<OBJECT ID="WebBrowser" WIDTH=0 HEIGHT=0 CLASSID="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2"></OBJECT>';
		       document.body.insertAdjacentHTML('beforeEnd', wb);
		       WebBrowser.ExecWB(7, -1);
		       WebBrowser.outerHTML = '';
		       self.close();
		   }
	</script>
</head>
<body  style='margin:0px;'>
   <div id='printShow'></div>
</body>