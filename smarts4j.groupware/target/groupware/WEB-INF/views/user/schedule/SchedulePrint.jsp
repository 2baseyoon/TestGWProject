<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body id="printBody"></body>

<script type="text/javascript">
	//# sourceURL = SchedulePrint.jsp
	
	window.onload = initOnload;
	function initOnload(){
		try {
			var innerHtml = $(opener.document.getElementById("content")).clone().removeClass("commContRight");
			var scriptCode = innerHtml.children("script");
			
			innerHtml.children("script").remove();
			
			document.getElementById("printBody").innerHTML = innerHtml[0].outerHTML;
			//$("#printBody").append(innerHtml);
			
			//CoviMenu_GetContent(opener.location.href.replace(opener.location.origin, ""),false);
			
			$(".pagingType02").hide();
			$(".searchBox02").hide();
			$(".scheduleTop").hide();
			$(".cRContBottom").css("overflow","visible");
			$(".cRConTop").css("borderBottom","0px");
			$(".scheduleContent").css("paddingBottom","0px");
			$(".shcToDay ").removeClass("shcToDay");
			$(".ui-selected").removeClass("ui-selected");
			$(".weeklyListBody").css("height", "auto");
				 
			/* 	var scriptNEW = document.createElement('script');
			scriptNEW.type = 'text/javascript';
			scriptNEW.text = scriptCode.html();
			var scriptPos = document.getElementById('printBody');
			scriptPos.appendChild(scriptNEW); */
			
			this.document.execCommand("print", false, null);
			window.close();
		} catch(e) {
			Common.Inform("<spring:message code='Cache.msg_failedLoadPrintPage'/>", "Information", function(result){ // 인쇄할 페이지를 불러오지 못했습니다.<br>다시 시도해 주십시오.
				if(result){
					if(_ie) window.open("", "_self", ""); // ie에서 window.close시 표시되는 prompt 방지
					window.close();
				}
			});
			
			return false;
		}
	}
	
</script>