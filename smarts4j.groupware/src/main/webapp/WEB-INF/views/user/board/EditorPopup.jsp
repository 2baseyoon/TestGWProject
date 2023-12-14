<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop ui-draggable boradPopLayer " id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent layerType02 boardReadingList ">
				<div>				
					<div class="middle">
						<div id="divWebEditor" class="writeEdit">
						</div>
					</div>
					<div class="bottom">
						<div class="popBottom">
							<a href="#" class="btnTypeDefault btnTypeBg" onclick="passData()"><spring:message code="Cache.btn_Confirm"/></a>	<!-- 확인 -->
							<a href="#" class="btnTypeDefault" onclick="javascript:Common.Close();"><spring:message code='Cache.btn_Close'/></a><!-- 닫기 -->
						</div>
					</div>
				</div>
			</div>
		</div>	
	</div>

<script type="text/javascript">
var editorBody = null;

var g_editorKind = Common.getBaseConfig('EditorType');

$(document).ready(function () {
	var parentText = parent.$("#boardBodyText").val();
	
	coviEditor.loadEditor(
		'divWebEditor',
		{
			editorType : g_editorKind,
			containerID : 'tbContentElement',
			frameHeight : '500',
			focusObjID : '',
			onLoad: function(){
				coviEditor.setBody(g_editorKind, 'tbContentElement', parentText);
			}
		}
	);
	
	//팝업 모드 별 parent, opener Element참조용...개선여부 확인
/* 	if(parent != null  && parent.$("#boardBodyText").val() != "undefined"){
		editorBody = parent.$("#boardBodyText");
	} else {
		editorBody = opener.$("#boardBodyText");
	}

	if(editorBody.length > 0){
		coviEditor.setBody('dext5', 'tbContentElement', editorBody.val());
	}  */
	
	/* var parentText = parent.$("#boardBodyText").val();
	if (parent != null && parentText != "") {
		setTimeout(function (){ 
			coviEditor.setBody('dext5', 'tbContentElement', parentText);
		}, 500);
	} */
	

});
	
function passData() {
	var textWithTag = escape(coviEditor.getBody(g_editorKind, 'tbContentElement'));
	var text = coviEditor.getBodyText(g_editorKind, 'tbContentElement');
	var textInlineImage = escape(coviEditor.getImages(g_editorKind, 'tbContentElement'));
	
	parent.editorPopupCallBack(textWithTag, text ,textInlineImage);
	Common.Close();
}	
</script>