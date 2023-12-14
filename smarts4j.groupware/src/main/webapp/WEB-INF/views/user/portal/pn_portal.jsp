<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.coviframework.util.SessionCommonHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
	String isDark = SessionCommonHelper.getSessionMapKey("PortalOption","isDark","N");
	String useLeft = SessionCommonHelper.getSessionMapKey("PortalOption","useLeft","Y");
	String isActiveMyContents = SessionCommonHelper.getSessionMapKey("PortalOption","isActiveMyContents","N");
	
/*	String portalOption = egovframework.covision.groupware.portal.user.web.PNPortalCon.getUserPortalOption();

	if(portalOption != null && !portalOption.equals("")){
		org.json.simple.parser.JSONParser parser = new org.json.simple.parser.JSONParser();
		Object obj = parser.parse(portalOption);
		org.json.simple.JSONObject json = (org.json.simple.JSONObject) obj;
		
		isDark = json.get("isDark") == null ? "N" : (String) json.get("isDark");
		useLeft = json.get("useLeft") == null ? "N" : (String) json.get("useLeft");
		isActiveMyContents = json.get("isActiveMyContents") == null ? "N" : (String) json.get("isActiveMyContents");
	}else{
		isDark = "N";
		useLeft = "Y";
		isActiveMyContents = "N";
		portalOption = "{'isDark': 'N', 'useLeft': 'Y', 'isActiveMyContents': 'N'}";
	}
	
	pageContext.setAttribute("portalOption", portalOption);
	pageContext.setAttribute("DarkMode", isDark);
*/	

	pageContext.setAttribute("isDark", isDark);
	pageContext.setAttribute("useLeft", useLeft);
	pageContext.setAttribute("isActiveMyContents", isActiveMyContents);
	pageContext.setAttribute("themeCode", SessionCommonHelper.getSession("UR_ThemeCode"));
	
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();	//포탈페이지의 정적 스크립트 버전관리 하지 않아 추가
	String assignedBizSection = SessionCommonHelper.getSession("UR_AssignedBizSection");
%>

${incResource}
  
<script type="text/javascript" src="<%=cssPath%>/customizing/ptype05/js/jcarousellite_1.0.1.pack.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=cssPath%>/customizing/ptype05/js/packery.pkgd.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/user/approvestat.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/ExControls/Chart.js-master/Chart.js<%=resourceVersion%>"></script>
<script defer type="text/javascript" src="/mail/resources/script/cmmn/cmmn.variables.js<%=resourceVersion%>"></script>
<script defer type="text/javascript" src="/mail/resources/script/cmmn/mail.api.js<%=resourceVersion%>"></script>

<style>
	<%if (useLeft.equals("N")){%>
		.PN_mainLeft{left:-388px}
		.PN_mainRight{width: 100%; margin-left: 0}
	<%}else{ %>
		.PN_mainLeft{left:0}
		.PN_mainRight{width: calc(100% - 388px); margin-left: 388px}
	<%}%>
	<%if (isActiveMyContents.equals("Y")){%>
		.PN_myContents{transform:translateY(-547px)}
	<% }%>

	
</style>

<div id="portal_con" class="commContRight mainContainer">${layout}</div>

<script type="text/javascript">
	${javascriptString}
	var access = '${access}' ;
	var _portalInfo = '${portalInfo}';
	var _data = ${data};
	var cssPath = "<%=cssPath%>";
	var g_pageNum = 1; // 메일 스크롤 페이징 변수
	var g_isActiveMyContents = '${isActiveMyContents}';
	var g_useLeft = '${useLeft}';
	var gwPortal = {};	
	//ready 
	window.addEventListener('DOMContentLoaded', function(){ 
		if(g_useLeft == 'Y'){
			$(".PN_mainLeft").addClass('open');
		}else{
			$(".PN_mainLeft .PN_btnArea a").removeClass('btnClose').addClass("btnOpen");
		}

		if(g_isActiveMyContents == 'Y'){
			$(".PN_myContents .PN_myBtn").addClass("active");
			$('.PN_myContents').addClass('open');
		}
	})
	$(window).load(function(){
		initPortal();
//		saveUserPortalOption();
	})

	function initPortal(){
		// 히스토리 추가
		var url  = location.href;
		var state = CoviMenu_makeState(url); 
		history.pushState(state, url, url);
		CoviMenu_SetState(state)

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
			
			var jsMethod = Base64.b64_to_utf8(value.initMethod);
			var methodType = typeof window[jsMethod];		
			try{
				if(parseInt(value.WebpartOrder, 10) > 100){					
					setTimeout("loadWebpart('" + JSON.stringify(value) + "','"+methodType+"')", parseInt(value.WebpartOrder, 10));
				}else{
					loadWebpart(value, methodType)
				}
			}catch(e){
				coviCmn.traceLog(e);
				$("#WP"+value.WebpartID+" .webpart").css({"border": "2px solid red"});
			}		
		});
		
	}
	
	function loadWebpart(value, pMethodType){
		if(typeof(value) === "string"){
			value = $.parseJSON(value);
		}
		
		var html = Base64.b64_to_utf8(value.viewHtml==undefined?"":value.viewHtml);
		
		// 포탈 개선 My Place active 표시 여부
		if(html.indexOf("PN_myContents") > -1 && html.indexOf("PN_myBtn")){
			if(g_isActiveMyContents && g_isActiveMyContents == "Y"){
				html = html.replace("PN_myContents", "PN_myContents active");
				html = html.replace("PN_myBtn", "PN_myBtn active");
			}
		}
		
		if (html != ''){
			//default view로 인한 분기문
			if($("#WP"+value.WebpartID).attr("isLoad")=='Y'){
				$("#WP"+value.WebpartID).append(html);
			}else{
				$("#WP"+value.WebpartID).html(html);
				$("#WP"+value.WebpartID).attr("isLoad",'Y');
			}
		}
		
		if(pMethodType == 'function'){			// 웹파트 스크립트 및 소스를 재사용하기 위한 코드 추가. 전역변수 gwPortal에 pMethodType이 함수인경우 실행후 반환되는 객체를 등록.
			gwPortal[value.WebpartID] =  window[Base64.b64_to_utf8(value.initMethod)].call(this, value.data, value.ExtentionJSON, 'portal', value.WebpartID);
		}
		else {
			if(value.jsModuleName != '' && typeof window[value.jsModuleName] != 'undefined' && typeof(new Function ("return "+value.jsModuleName+".webpartType").apply()) != 'undefined'){
				new Function (value.jsModuleName+".webpartType = "+ value.WebpartOrder).apply();
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
	}
	
	function sortFunc(a, b) {
		if(a.WebpartOrder < b.WebpartOrder){
			return -1;
		}else if(a.WebpartOrder > b.WebpartOrder){
			return 1;
		}else{
			return 0;
		} 
	}
	
	function setNoImage(imgObj, imgOption){
		var noImgSrc = cssPath;
		
		if(imgOption && imgOption == "n2"){
			noImgSrc += "/customizing/ptype05/images/project/noimg02.jpg";
		}else{
			noImgSrc += "/customizing/ptype05/images/project/noimg01.jpg";
		}
		
		$(imgObj).attr("src", noImgSrc)
			.css({"width": "100%", "height": "100%"});
	}

	function onErrorImage(imgObj, name){
		var bTag = $("<b>").addClass("mColor").text(name);
		var imgSpan = $(imgObj).closest(".PN_mImg");
		imgSpan = imgSpan.length != 0 ? imgSpan : $(imgObj).closest(".PN_apImg");
		imgSpan = imgSpan.length != 0 ? imgSpan : $(imgObj).closest(".PN_apImg2");
		var cbClassName = imgSpan.closest(".contentBox").attr("class");
		cbClassName = cbClassName ? "." + cbClassName.replaceAll(" ", ".") : "";
		
		imgSpan.empty();
		imgSpan.append(bTag);
		addClassImgBox(cbClassName);
	}
	
	function addClassImgBox(posTagName){
		var imgCnt = 0;
		
		if(posTagName){
			$.each($(posTagName).find(".mColor"), function(idx, itme){
				var classIdx = (imgCnt % 5) + 1;
				$(this).attr("class", "");
				$(this).attr("class", "mColor mColor" + classIdx);
				imgCnt++;
			});
		}
	}
		
	function slideLeftArea(target){
		if($('.PN_mainLeft').hasClass('open')){
			$('.PN_mainLeft').removeClass('open').addClass('close');
		}else{
			$('.PN_mainLeft').removeClass('close').addClass('open');
		}
		
		if(!$('.PN_mainLeft').hasClass('animate')){
			$('.PN_mainLeft').addClass('animate');
		}

		if($(target).hasClass('btnClose')){
			$(target).removeClass('btnClose').addClass('btnOpen');
		}else{
			$(target).removeClass('btnOpen').addClass('btnClose');
		}

		saveUserPortalOption("useLeft",$('.PN_mainLeft').hasClass("open") ? "Y" : "N" );
	}
	
	function slideUpdownArea(target){

		if($('.PN_myContents').hasClass('open')){
			$('.PN_myContents').removeClass('open').addClass('close');
		}else{
			$('.PN_myContents').removeClass('close').addClass('open');
		}
		
		$(target).toggleClass("active");
		saveUserPortalOption("isActiveMyContents",$(".PN_myContents").hasClass("open") ? "Y" : "N");
	}
</script>
