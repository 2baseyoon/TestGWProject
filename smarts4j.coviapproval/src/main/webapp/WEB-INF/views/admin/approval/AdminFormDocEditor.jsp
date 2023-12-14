<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%		
	String kind 			= StringUtil.replaceNull(request.getParameter("kind"),"");	
%>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var kind =param[0].split('=')[1];
	var doublecheck = false;
	
	var g_editorTollBar = '0';	// 0, 1, 2 
	var gx_id = 'xfe';
	var g_id = 'tagfe';
	var g_heigth = '400px';
	var g_editorKind = Common.getBaseConfig('EditorType');

	$(document).ready(function(){
		coviEditor.loadEditor(
				'divWebEditor',
			{
				editorType : g_editorKind,
				containerID : g_id,
				frameHeight : '400',
				focusObjID : '',
				onLoad: 'onLoadEditor' 
			}
		);
		//setTimeout(function () { DEXT5.setBodyValueEx(parent._setDocEditorVal(kind), gx_id); }, 500);
	});
	
	function onLoadEditor(){
		coviEditor.setBody(g_editorKind, g_id, parent._setDocEditorVal(kind));
	}
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
		
	function getdata(){
// 		var dextHtmlValue = DEXT5.getHtmlValueEx(gx_id);
// 		dextHtmlValue = dextHtmlValue.replace(dextHtmlValue.substring(dextHtmlValue.indexOf('<title>') + 7, dextHtmlValue.indexOf('</title>')), '');		
		parent._setDocEditor(kind,coviEditor.getBody(g_editorKind, g_id),coviEditor.getImages(g_editorKind, g_id));
		closeLayer()
	}	
	
	//저장
	function saveSubmit(){
		//data셋팅			
		
		if($("#tableBizDocFormBody tr").length==1){
			Common.Warning("<spring:message code='Cache.msg_Mail_PleaseSelectForm' />");	//양식을 선택하여 주십시오.		
			return;
		}
	
		var BizDocFormArray = new Array();		
		jQuery.ajaxSettings.traditional = true;
		$("#tableBizDocFormBody tr:not(:first)").each(function(i){			
			var BizDocFormObj = new Object();				
			BizDocFormObj.BizDocID = paramBizDocID;
			BizDocFormObj.SortKey = $("#iptSortKey"+i).val();
			BizDocFormObj.FormPrefix = $(this).next().text();
			BizDocFormObj.FormName = $(this).next().next().text();
			BizDocFormObj.FormID = $("#iptFormName"+i).val()
			BizDocFormArray.push(BizDocFormObj);
			
		});	
		
		//jsavaScript 객체를 JSON 객체로 변환
		BizDocFormArray = JSON.stringify(BizDocFormArray);		
		
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{				
				"BizDocForm" : BizDocFormArray
			},
			url:"insertBizDocForm.do",
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_apv_137' />");
				parent._CallBackMethod1();
				closeLayer();
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("insertBizDocForm.do", response, status, error);
			}
		});
	}
	
	
</script>
<form id="AdminFormDocEditor" name="AdminFormDocEditor">
	<div class="pop_body1">
        <!--웹에디터-->
		<div id="divWebEditor">	
<!-- 			<script type="text/javascript" src="/covicore/resources/script/Dext5/js/dext5editor.js"></script> -->
<!-- 			<script src="/covicore/resources/script/Dext5/Dext5.js" type="text/javascript"></script>      -->
		</div>	   	    
   </div>	
   <div class="popBtn" align="center" style="padding-top: 10px">
			<input type="button" value="<spring:message code='Cache.lbl_apv_apply'/>" onclick="getdata();" class="AXButton red" />			
			<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="closeLayer();"  class="AXButton" />
	</div>
</form>
