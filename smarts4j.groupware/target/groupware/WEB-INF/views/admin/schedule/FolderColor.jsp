<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body>
	<div class="layer_divpop ui-draggable schPopLayer" id="testpopup_p" style="width:350px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<table class="AXFormTable" >
					<colgroup>
						<col width="30%">
						<col width="70%">
					</colgroup>
					<tr>
						<th>일정 색깔</th>
						<td>
							<div id="colorPicker" style="float:left"></div>
							<input type="button" class="AXButton" onclick="setColor();" value="확인" >
						</td>
					</tr>
				</table>
			</div>
		</div>
	</div>
</body>

<script>
initContent();

function initContent(){
	// colorPicker 세팅
	var colorList = Common.getBaseCode("ScheduleColor");
	var dataPalette = new Array();
	var defaultColor = "#" + CFN_GetQueryString("defaultColor");
	
	dataPalette.push({"default" : defaultColor});
	$(colorList.CacheData).each(function(){
		var obj = {};
		$$(obj).append(this.Code, "#"+this.Code);
		
		dataPalette.push(obj);
	});
	
	coviCtrl.renderColorPicker("colorPicker", dataPalette);
}

function setColor(){
	var selectColor = coviCtrl.getSelectColor().split(":")[1];
	
	parent.$("#pDefaultColor").css("background-color", selectColor);
	parent.$("#DefaultColor").val( selectColor);
	Common.Close();
}

</script>