<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>  
	<!-- 프로젝트용 -->
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/CEOportal/css/project.css<%=resourceVersion%>" />	
	<!-- 프로젝트용 테마 -->
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/CEOportal/css/color_01.css<%=resourceVersion%>" />
	<!-- 프로젝트용 스크립트 
	<script type="text/javascript" src="http://www.no1.com/HtmlSite/smarts4j_n/customizing/CEOportal/js/project.js<%=resourceVersion%>"></script>
		-->
${incResource}
<style>
	#portal_con>table{table-layout: fixed;}
	#portal_con>table td{padding: 2px;}
</style>
<div class="commContRight mainContainer">
	<section class="mainContent clearFloat">
		${layout}
	</section>
</div>

<script type="text/javascript">
	${javascriptString}
			
	var access = '${access}' 
	var _portalInfo = '${portalInfo}';
	var _data = ${data};
	
	//ready 
	initPortal();
	function initPortal(){
		if(access == 'SUCCESS'){
			loadPortal();
		}else if(access == 'NOT_AHTHENTICATION'){
			var sHtml = '';
			sHtml += '<div class="errorCont">';
			sHtml += '	<h1>포탈 접속 실패</h1>';
			sHtml += '	<div class="bottomCont">';
			sHtml += '		<p class="txt">해당 포탈에 접속 권한이 없습니다.<br>관리자에게 문의 바랍니다.</p>';
			sHtml += '		<p class="copyRight mt30">Copyright 2017. Covision Corp. All Rights Reserved.</p>';
			sHtml += '	<div/>';
			sHtml += '<div/>';
			
			$("#portal_con").html(sHtml);
		}
	}
	
	function loadPortal(){
		var oData = _data;
		
		oData.sort(sortFunc);
		
		$.each(oData, function(idx, value){
			try{
				if (parseInt(value.webpartOrder, 10) > 100) {
					setTimeout("loadWebpart('" + JSON.stringify(value) + "')", parseInt(value.webpartOrder, 10));
				}else{
					loadWebpart(value)
				}
			}catch(e){
				coviCmn.traceLog(e);
				$("#WP"+value.WebpartID+" .webpart").css({"border": "2px solid red"});
			}
		});
		
		setDefaultEvent();
	}

	function loadWebpart(value){
		if(typeof(value) === "string"){
			value = $.parseJSON(value);
		}
		var html = Base64.b64_to_utf8(value.viewHtml==undefined?"":value.viewHtml);

		if (html != ''){
			//default view로 인한 분기문
			if($("#WP"+value.WebpartID).attr("isLoad")=='Y'){
				$("#WP"+value.WebpartID).append(html);
			}else{
				$("#WP"+value.WebpartID).html(html);
				$("#WP"+value.WebpartID).attr("isLoad",'Y');
			}
		}
		
		if(value.jsModuleName != '' && typeof window[value.jsModuleName] != 'undefined' && typeof(new Function ("return "+value.jsModuleName+".webpartType").apply()) != 'undefined'){
			new Function (value.jsModuleName+".webpartType = "+ value.webpartOrder).apply();
		}
		
		if(value.initMethod != '' && typeof(value.initMethod) != 'undefined'){
			if(typeof(value.data)=='undefined'){
				value.data = $.parseJSON("[]");
			}
			
			if(typeof(value.ExtentionJSON) == 'undefined'){
				value.ExtentionJSON = $.parseJSON("{}");
			}

			let ptFunc = new Function('a', 'b', Base64.b64_to_utf8(value.initMethod)+'(a, b)');
			ptFunc(value.data, value.ExtentionJSON);
		}
	}
	
	 function sortFunc(a, b) {
	       if(a.webpartOrder < b.webpartOrder){
	    	   return -1;
	       }else if(a.webpartOrder > b.webpartOrder){
	    	   return 1;
	       }else{
	    	   return 0;
	       } 
	    }
	
	 
	 function setDefaultEvent() {
			if (_portalInfo == "") return;
	        var sLayoutType = $.parseJSON(_portalInfo).LayoutType;
	        switch (sLayoutType) {
	        	case "8": 	//1행2열 데모용
	            case "7":   // 1행3열
	            	$('.btnMyContView').on('click', function(){
	            		var parentCont = $(this).closest('.mainMyContent');
	            		if(parentCont.hasClass('active')){
	            			parentCont.removeClass('active');
	            		}else {
	            			parentCont.addClass('active');
	            		}
	            	});
	            	break;
	            case "0":   // 기타
	                break;
	            default: 
	            	break;
	        }
	        
	    }
</script>


	
	
