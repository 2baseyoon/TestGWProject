<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<% 
String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path");
String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
String filename = request.getParameter("filename") == null ? "" : request.getParameter("filename");
String fiid = request.getParameter("fiid") == null ? "" : request.getParameter("fiid");
%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ko" xml:lang="ko">
<head>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/pdf.css<%=resourceVersion%>" />
<link rel="stylesheet" id="themeCSS" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/<c:out value="${themeType}"/>.css" />
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<title>CoviFlow4J</title>
<script type="text/javascript">
	var paramHtml = opener.printDiv;
	
	$(document).ready(function () {
		// thead에 여러개의 table을 넣어두면 wkhtmltopdf에서 pdf 출력될때 반복되는 버그가 있음.
		$("#printShow").html(paramHtml.replace("<thead>","")/*.replace("min-height","height")*/);
		$("#AppLine").attr('align', 'right');
		$("#RApvLine").attr('align', 'right');
		
		makeHtml();
		
		// 출력 버튼 클릭
		$('#printBtn').click(function(){
			// html 만들고 submit
			makeHtml();
		});
	});
	// html 만들고 submit
	function makeHtml() {
		if (document.styleSheets[0].href != null) {
			//var html = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">";
			//html += "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"ko\" xml:lang=\"ko\"><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><style>";
			
	        // browser 확인
/* 	        navigator.browserSpecs = (function() {
	        	var ua= navigator.userAgent, tem, 
	        	M= ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
	        	if(/trident/i.test(M[1])){
	        		tem=  /\brv[ :]+(\d+)/g.exec(ua) || [];
	        		return {name:'IE',version:(tem[1] || '')};
	        	}
	        	if(M[1]=== 'Chrome'){
	        		tem= ua.match(/\b(OPR|Edge)\/(\d+)/);
	        		if(tem!= null) return {name:tem[1].replace('OPR', 'Opera'),version:tem[2]};
	        	}
	        	M= M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
	        	if((tem= ua.match(/version\/(\d+)/i))!= null) M.splice(1, 1, tem[1]);
	        	return {name:M[0],version:M[1]};
	        })(); */
	        
/* 	        if (navigator.browserSpecs.name == 'IE' && navigator.browserSpecs.version < 9) {
				html += getStyle(document.styleSheets[0].href, 0);
			} else {
				html += getStyleChrome(document.styleSheets[0]);
			} */
			
			//html += "</style></head><body>" + $("#printShow").html() + "</body></html>";
			var printShowClone = $("#printShow").clone();
			$(printShowClone).find('img').each(function(idx, item){
				if($(item).prop("src").indexOf("/common/photo/photo.do") > 0){
					$(item).prop("src", $(item).prop("src").replace("/common/photo/photo.do", "/covics/loadPdfPhoto.do") + "&filename=" + CFN_GetQueryString("filename"));
				}
			});
			
			$("#txtHtml").val($(printShowClone).html());
			$("#pdfForm").attr("target", "targetIframe");
			$("#pdfForm").attr("action", "/approval/common/printPdf.do");
			$("#pdfForm").submit();
		}
	}
	
/* 	function getStyleChrome(sheet) {
	    var style = "";
	    var rules = sheet.rules || sheet.cssRules;
	    for (var r = 0; r < rules.length; r++) {
	        style += rules[r].cssText;
	    }
	    return style;
	} */

/* 	function getStyle(sURL, index) {
	    var objStyle = "";
	    if (document.styleSheets[index].cssText != null) {
	        objStyle += document.styleSheets[index].cssText
	    }
	    return objStyle.replace("undefined", "");
	} */
	
</script>
</head>
<body>
 	<div class="wordTop">
		<div class="topWrap" style="min-height: 30px;">
			<input type="button" class="AXButton" id="printBtn" name="printBtn" value="<spring:message code='Cache.btn_PCSave'/>">
        </div>
	</div>
	
	<div id='printShow' class="wordCont"></div>
	
	<form id="pdfForm" name="pdfForm" method="post" style="visibility:hidden">
		<textarea id="txtHtml" name="txtHtml" rows="" cols="" style="display:none;"></textarea>
		<input type="hidden" id="filename" name="filename" value="<%=filename%>"/>
		<input type="hidden" id="fiid" name="fiid" value="<%=fiid%>"/>
	</form>
	
	<iframe width=0 height=0 frameborder=0 scrolling=no name="targetIframe" style="margin-top:0"></iframe>
</body>
</html>