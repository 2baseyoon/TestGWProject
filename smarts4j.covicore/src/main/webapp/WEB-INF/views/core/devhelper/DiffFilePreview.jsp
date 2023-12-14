<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
%>
<!DOCTYPE HTML>
<style type="text/css">
	#block {
		position:absolute;
		left:0px;
		right:0px;
		top:137px;
		bottom:0;
		z-index:100;
		width:100%;
		height:100%;
		opacity: 0.8;
		background-color:#444;
		background:url('<%=cssPath%>/covicore/resources/images/common/fido_img_loading.gif') no-repeat;
		background-position:50% 20%;
	}
</style>
<script type="text/javascript" src="https://cdn.jsdelivr.net/npm/diff2html/bundles/js/diff2html-ui.min.js"></script>
<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
		var fileExists = "<c:out value='${fileExists}'/>";
		
		if(fileExists == "Y") {
			convert();	
		} else {
			alert("파일을 찾을 수 없습니다.");
			window.close();
		}
	});

	function download(filename, text, contentType) {
		  var element = document.createElement('a');
		  element.setAttribute('href', 'data:'+ contentType +';charset=utf-8,' + encodeURIComponent(text));
		  element.setAttribute('download', filename);
	
		  element.style.display = 'none';
		  document.body.appendChild(element);
	
		  element.click();
		  document.body.removeChild(element);
	}
	
	function Export(){
			// Start file download.
			var fileName = document.title + ".html";
			var downHtml = "";
			downHtml += "<!DOCUMENT html>";
			downHtml += "<html>";
			downHtml += "<head>";
			downHtml += "<meta charset=\"utf-8\" />";
			downHtml += "</head>";
			downHtml += "<body>";
			var cont = $(".download");
			for(var i = 0; i < cont.length; i++){
				downHtml += cont[i].outerHTML;
			}
			downHtml += "</body>";
			download(fileName, downHtml, "text/html");
	}
	
	var configuration = {
		drawFileList: true,
		fileListToggle: false,
		fileListStartVisible: false,
		fileContentToggle: false,
		matching: 'lines',
		outputFormat: 'side-by-side',
		synchronisedScroll: true,
		highlight: true,
		renderNothingWhenEmpty: false,
	};
	
	function convert(format){
		format = format || 'side-by-side';
		var targetElement = document.getElementById('myDiffElement');
		var diffString = document.getElementById('diffString').value;
		var diff2htmlUi = new Diff2HtmlUI(targetElement, diffString, configuration);
		diff2htmlUi.draw();
		diff2htmlUi.highlightCode();
		
		$("#block").hide();
	}
</script>
<!-- diff2html : MIT License -->
<html>
	<head>
		<title><c:out value='${fileName}'/></title>
		<meta charset="utf-8" />
	</head>
	<body>
		<style type="text/css" media="all" class="download">
			.hljs {display:block;overflow-x:auto;padding:.5em;color:#333;background:#f8f8f8}.hljs-comment,.hljs-quote{color:#998;font-style:italic}.hljs-keyword,.hljs-selector-tag,.hljs-subst{color:#333;font-weight:700}.hljs-literal,.hljs-number,.hljs-tag .hljs-attr,.hljs-template-variable,.hljs-variable{color:teal}.hljs-doctag,.hljs-string{color:#d14}.hljs-section,.hljs-selector-id,.hljs-title{color:#900;font-weight:700}.hljs-subst{font-weight:400}.hljs-class .hljs-title,.hljs-type{color:#458;font-weight:700}.hljs-attribute,.hljs-name,.hljs-tag{color:navy;font-weight:400}.hljs-link,.hljs-regexp{color:#009926}.hljs-bullet,.hljs-symbol{color:#990073}.hljs-built_in,.hljs-builtin-name{color:#0086b3}.hljs-meta{color:#999;font-weight:700}.hljs-deletion{background:#fdd}.hljs-addition{background:#dfd}.hljs-emphasis{font-style:italic}.hljs-strong{font-weight:700}
		</style>
		<style type="text/css" media="all" class="download">
			.d2h-d-none {display:none}.d2h-wrapper{text-align:left}.d2h-file-header{height:35px;padding:5px 10px;border-bottom:1px solid #d8d8d8;background-color:#f7f7f7;font-family:Source Sans Pro,Helvetica Neue,Helvetica,Arial,sans-serif}.d2h-file-header,.d2h-file-stats{display:-webkit-box;display:-ms-flexbox;display:flex}.d2h-file-stats{margin-left:auto;font-size:14px}.d2h-lines-added{text-align:right;border:1px solid #b4e2b4;border-radius:5px 0 0 5px;color:#399839;padding:2px;vertical-align:middle}.d2h-lines-deleted{text-align:left;border:1px solid #e9aeae;border-radius:0 5px 5px 0;color:#c33;padding:2px;vertical-align:middle;margin-left:1px}.d2h-file-name-wrapper{display:-webkit-box;display:-ms-flexbox;display:flex;-webkit-box-align:center;-ms-flex-align:center;align-items:center;width:100%;font-size:15px}.d2h-file-name{white-space:nowrap;text-overflow:ellipsis;overflow-x:hidden}.d2h-file-wrapper{margin-bottom:1em}.d2h-file-collapse,.d2h-file-wrapper{border:1px solid #ddd;border-radius:3px}.d2h-file-collapse{-webkit-box-pack:end;-ms-flex-pack:end;justify-content:flex-end;display:none;cursor:pointer;font-size:12px;-webkit-box-align:center;-ms-flex-align:center;align-items:center;padding:4px 8px}.d2h-file-collapse.d2h-selected{background-color:#c8e1ff}.d2h-file-collapse-input{margin:0 4px 0 0}.d2h-diff-table{width:100%;border-collapse:collapse;font-family:Menlo,Consolas,monospace;font-size:13px}.d2h-files-diff{display:block;width:100%}.d2h-file-diff{overflow-y:hidden}.d2h-file-side-diff{display:inline-block;overflow-x:scroll;overflow-y:hidden;width:50%;margin-right:-4px;margin-bottom:-8px}.d2h-code-line{padding:0 8em}.d2h-code-line,.d2h-code-side-line{display:inline-block;white-space:nowrap;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;width:100%}.d2h-code-side-line{padding:0 4.5em}.d2h-code-line-ctn{display:inline-block;background:none;padding:0;word-wrap:normal;white-space:pre;-webkit-user-select:text;-moz-user-select:text;-ms-user-select:text;user-select:text;width:100%;vertical-align:middle}.d2h-code-line del,.d2h-code-side-line del{background-color:#ffb6ba}.d2h-code-line del,.d2h-code-line ins,.d2h-code-side-line del,.d2h-code-side-line ins{display:inline-block;margin-top:-1px;text-decoration:none;border-radius:.2em;vertical-align:middle}.d2h-code-line ins,.d2h-code-side-line ins{background-color:#97f295;text-align:left}.d2h-code-line-prefix{display:inline;background:none;padding:0;word-wrap:normal;white-space:pre}.line-num1{float:left}.line-num1,.line-num2{-webkit-box-sizing:border-box;box-sizing:border-box;width:3.5em;overflow:hidden;text-overflow:ellipsis;padding:0 .5em}.line-num2{float:right}.d2h-code-linenumber{-webkit-box-sizing:border-box;box-sizing:border-box;width:7.5em;position:absolute;display:inline-block;background-color:#fff;color:rgba(0,0,0,.3);text-align:right;border:solid #eee;border-width:0 1px;cursor:pointer}.d2h-code-linenumber:after{content:"\200b"}.d2h-code-side-linenumber{position:absolute;display:inline-block;-webkit-box-sizing:border-box;box-sizing:border-box;width:4em;background-color:#fff;color:rgba(0,0,0,.3);text-align:right;border:solid #eee;border-width:0 1px;cursor:pointer;overflow:hidden;text-overflow:ellipsis;padding:0 .5em}.d2h-code-side-linenumber:after{content:"\200b"}.d2h-code-side-emptyplaceholder,.d2h-emptyplaceholder{background-color:#f1f1f1;border-color:#e1e1e1}.d2h-code-line-prefix,.d2h-code-linenumber,.d2h-code-side-linenumber,.d2h-emptyplaceholder{-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none}.d2h-code-linenumber,.d2h-code-side-linenumber{direction:rtl}.d2h-del{background-color:#fee8e9;border-color:#e9aeae}.d2h-ins{background-color:#dfd;border-color:#b4e2b4}.d2h-info{background-color:#f8fafd;color:rgba(0,0,0,.3);border-color:#d5e4f2}.d2h-file-diff .d2h-del.d2h-change{background-color:#fdf2d0}.d2h-file-diff .d2h-ins.d2h-change{background-color:#ded}.d2h-file-list-wrapper{margin-bottom:10px}.d2h-file-list-wrapper a{text-decoration:none;color:#3572b0}.d2h-file-list-wrapper a:visited{color:#3572b0}.d2h-file-list-header{text-align:left}.d2h-file-list-title{font-weight:700}.d2h-file-list-line{display:-webkit-box;display:-ms-flexbox;display:flex;text-align:left}.d2h-file-list{display:block;list-style:none;padding:0;margin:0}.d2h-file-list>li{border-bottom:1px solid #ddd;padding:5px 10px;margin:0}.d2h-file-list>li:last-child{border-bottom:none}.d2h-file-switch{display:none;font-size:10px;cursor:pointer}.d2h-icon{vertical-align:middle;margin-right:10px;fill:currentColor}.d2h-deleted{color:#c33}.d2h-added{color:#399839}.d2h-changed{color:#d0b44c}.d2h-moved{color:#3572b0}.d2h-tag{display:-webkit-box;display:-ms-flexbox;display:flex;font-size:10px;margin-left:5px;padding:0 2px;background-color:#fff}.d2h-deleted-tag{border:1px solid #c33}.d2h-added-tag{border:1px solid #399839}.d2h-changed-tag{border:1px solid #d0b44c}.d2h-moved-tag{border:1px solid #3572b0}
		</style>
		<style type="text/css" media="screen">
			#head {
				padding-bottom : 10px;
				margin-bottom: 10px;
				border-bottom : 1px solid black;
			}
	
			#file_drop{
				outline: 2px dashed #92b0b3 ;
				outline-offset:-10px;  
				text-align: center;
				transition: all .15s ease-in-out;
				width: 300px;
				background-color: #999;
				margin:auto;
				color:#fff;
				font-weight:bold;
				padding-top:30px;
				padding-bottom:30px;
				margin-bottom:5px;
			}
			
			.rel { 
				display:inline-block; 
			}
		</style>
		<div id="head" style="text-align:center;">
			<input type="hidden" id="diffString"  value="<c:out value='${diffString}'/>"/>
			<div class="rel">
				<button class="rel" type="button" onclick="Export()">Export HTML</button>
			</div>
		</div>
    	<div id="myDiffElement" class="download"></div>
		<div id="block" style="display:none;"></div>	
	</body>
</html>