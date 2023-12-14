<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
<style>
	#jb-container {
		width: 1280px;
		margin: 0px auto;
		padding: 20px;
		border: 1px solid #bcbcbc;
	}
	
	#jb-header {
		padding: 20px;
		margin-bottom: 20px;
		border: 1px solid #bcbcbc;
	}
	
	#jb-sidebar-left {
		width: 200px;
		padding: 20px;
		margin-right: 20px;
		margin-bottom: 20px;
		float: left;
		border: 1px solid #bcbcbc;
	}
	
	#jb-content {
		width: 715px;
		padding: 20px;
		margin-bottom: 20px;
		float: left;
		border: 1px solid #bcbcbc;
	}
	
	#jb-sidebar-right {
		width: 200px;
		padding: 20px;
		margin-bottom: 20px;
		float: right;
		border: 1px solid #bcbcbc;
	}
	
	#jb-footer {
		clear: both;
		padding: 20px;
		border: 1px solid #bcbcbc;
	}
</style>
<script type="text/javascript">
${jsString}
</script>

<script>
	
	var _data = '${data}';
	require([ 'jquery.min', 'underscore', 'json2' ], 
			function(dummy$, dummy_, dummyJSON) {

		//페이지가 완전히 로드된 뒤에 실행
		$(document).ready(function() {
			
			//alert($('#jb-header h1').text());
			//underscore binding 시작 부분
			//escape 문자 설정
			_.templateSettings = {
				variable : "doc",
				interpolate : /\{\{(.+?)\}\}/g, // print value: {{ value_name }}
				evaluate : /\{%([\s\S]+?)%\}/g, // excute code: {% code_to_execute %}
				escape : /\{%-([\s\S]+?)%\}/g
			};

			var templateHtml = $("#portal_con").html();

			//template 내의 underscore 구문의 정합성을 체크하는 부분
			//underscore binding 부분은 {{ doc.~~ }} 형태를 준수 할 것
			//templateHtml = validateUnderscore(templateHtml);

			var template = _.template(templateHtml);

			/* 비사용
			//2015.09.11 B.K. 기간계 연동 추가
			//body context의 CDATA정리
			setCDataSection(formJson.BodyContext); */

			// template와 data binding
			/* 비사용
			$("#templateContainer").html(
			    template(formJson)
			); */
			var oData = JSON.parse(_data);
			$("#portal_con").html(template(oData));

			/* var html = '<ul>';

			$.each(oData.content2, function(index, value) {
				html += '<li> key : ' + value.key + ', value : ' + value.value + '</li>';
			});
			
			html += '</ul>';

			$('#l_con_2').append(html); */
			loadPortal();
		});

	});
	
	
	function onClickPopButton(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,FormPrefix){
		strPiid_List = "";
		strWiid_List = "";
		strFiid_List = "";
		strPtid_List = "";
		
		var width;
		var archived = "false";
		mode="APPROVAL"; gloct = "APPROVAL"; subkind=SubKind; userID=UserCode;
		
		width = 790;
		CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"", "", width, (window.screen.height - 100), "resize");
	}

	function loadPortal(){
		var oData = JSON.parse(_data);
		
		$.each(oData, function(idx, value){
			try{
				if (parseInt(value.type, 10) > 100) {
					setTimeout("loadWebpart('" + JSON.stringify(value) + "')", parseInt(value.type, 10));
				}else{
					loadWebpart(value)
					/* var html = Base64.b64_to_utf8(value.viewHtml==undefined?"":value.viewHtml);
					$("#"+value.divNumber).html(html);
					//document.getElementById(value.bindingHtmlID).innerHTML = html;
					if(value.initMethod != '' && typeof(value.initMethod) != 'undefined'){
						let ptFunc = new Function('a', Base64.b64_to_utf8 + '(a)');
						ptFunc(value.initMethod);
					} */
				}
			}catch(e){
				$("#WP"+value.webPartID).html("<span>"+e+"</span>");
			}
		});
	}
	
	function loadWebpart(value){
		if(typeof(value) === "string"){
			value = $.parseJSON(value);
		}
		var html = Base64.b64_to_utf8(value.viewHtml==undefined?"":value.viewHtml);
		$("#WP"+value.webPartID).html(html);
		//document.getElementById(value.bindingHtmlID).innerHTML = html;
		if(value.initMethod != '' && typeof(value.initMethod) != 'undefined'){
			let ptFunc = new Function('a', Base64.b64_to_utf8 + '(a)');
			ptFunc(value.initMethod);
		}
	}
</script>
	<body>
		<div id="portal_con">${layout}</div>
	</body>
</html>
