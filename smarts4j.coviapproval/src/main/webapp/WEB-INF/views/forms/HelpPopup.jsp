<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<head>
<title></title>
</head>
<body>
	<div class="layer_divpop ui-draggable schPopLayer" style="width:600px;">
		<div class="divpop_contents">
			<div class="pop_header">
				<h4 class="divpop_header ui-draggable-handle" id="popupTitle"><span class="divpop_header_ico"></span></h4>
			</div>
			<div>
				<div id="helpContent" style="margin: 10px;overflow: auto;height: 280px;">
				</div>
				<div class="bottom">
					<a class="btnTypeDefault" href="javascript:Common.Close();">닫기</a>
				</div>
			</div>
		</div>	
	</div>
</body>

<script>
initContent();

function initContent(){
	var type = CFN_GetQueryString("type");
	var sTitle = "";
	 if (type == "popup") {
	    sTitle = "<spring:message code='Cache.lbl_NoticePopup' />";
	}else if (type == "popupbtn") {
	    sTitle = "<spring:message code='Cache.lbl_apv_formcreate_LCODE28' />";
	}
	
	document.getElementsByTagName('title')[0].text = sTitle;
	$("#popupTitle > span").html(sTitle);
	
	if(opener != null && opener.length > 0){
		$("#helpContent").html(opener.getInfo("FormInfo.FormNoticeContext"));
	}else{
		window.close();
	}
}
</script>