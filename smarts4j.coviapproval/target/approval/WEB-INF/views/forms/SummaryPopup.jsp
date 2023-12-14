<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/approval/resources/script/forms/WebEditor_Approval_HWP.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Hwp/HwpToolbars.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Hwp/HwpCtrl.js<%=resourceVersion%>"></script>

<head>
<title></title>
</head>
<body>
	<div class="layer_divpop ui-draggable schPopLayer" style="width:500px;">
		<div class="divpop_contents">
			<div>
				<div id="summaryContent" style="margin: 10px; overflow: auto; height: 450px;">
				</div>
				<div class="bottom">
					<a class="btnTypeDefault" id="summaryBtnSave" href="javascript:doSave();">저장</a>
					<a class="btnTypeDefault" id="summaryBtnDelete" href="javascript:doDelete();">삭제</a>
					<a class="btnTypeDefault" id="summaryBtnClose" href="javascript:Common.Close();">닫기</a>
				</div>
			</div>
		</div>	
	</div>
</body>

<script>

$(window).load(function () {
	var type = CFN_GetQueryString("type");
	
	LoadSummaryEditorHWP("summaryContent", type); //HwpCtrl 공통 함수 사용
});

function doSave() {
	var objEditor = $("#SummaryEditorArea");
	if(objEditor.length == 0) {
	   	objEditor = document.getElementById("summaryContentFrame").contentWindow.HwpCtrl;
	}
	var strHtml = $(objEditor)[0].GetTextFile("HTML", "");
	opener.document.getElementById("SummaryContent").value = strHtml;
	
	Common.Close();
}

function doDelete() {
	opener.document.getElementById("SummaryContent").value = "";
	
	Common.Close();
}

</script>