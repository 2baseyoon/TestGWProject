<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop ui-draggable  commonLayerPop" id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="pop_header" id="testpopup_ph">
			</div>
			<div class="popContent">
				<div id="guideDiv">
					<div class="top">						
						<p id="guideMessage"></p>
					</div>	
					<div class="middle">
					</div>
					<div class="bottom mt20">
						<a href="#" class="btnTypeDefault btnTypeBg" onclick="javascript:Common.Close();"><spring:message code='Cache.lbl_Confirm'/></a>
					</div>
				</div>
			</div>
		</div>	
	</div>
<script>
var messageType = CFN_GetQueryString("messageType");

$(document).ready(function(){
	$('#guideHeader').text(Common.getDic("lbl_" + messageType + "_guide_header"));
	$('#guideMessage').text(Common.getDic("msg_" + messageType + "_guide"));
	$('#guideDiv').addClass(messageType + "guide");
})

</script>