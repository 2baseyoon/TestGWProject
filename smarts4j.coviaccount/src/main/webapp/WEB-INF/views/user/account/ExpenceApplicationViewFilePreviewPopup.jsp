<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>
<style>
.pad10 { padding:10px;}
</style>

<body>	
	<div id="filePreview">
		<div>
			<div>
				<iframe id="IframePreview" name="IframePreview" frameborder="0" width="100%" height="600px" scrolling="no" title=""></iframe>
				<input type="hidden" id="previewVal" value="">
			</div>
	  	</div>
	</div>
</body>
<script>
	$(document).ready(function (){
		var fileId = CFN_GetQueryString("fileId");
		var fileToken = CFN_GetQueryString("fileToken");
		
		if(fileId != null) {
			if($("#evidPreview").css("display") != "none") {
				$("#evidPreview").hide();
				/*$("#e_IframePreview").attr('src', '');
				$("#e_previewVal").val('');*/
			}
			
			var url = Common.getBaseConfig("MobileDocConverterURL") 
				+ "?fileID=" + fileId + "&fileToken=" + encodeURIComponent(fileToken);
			$("#IframePreview").attr('src', url);
			$("#previewVal").val(fileId);
		} else {
			parent.Common.close("expenceApplicationViewFilePreviewPopup");
		}
	});
</script>
