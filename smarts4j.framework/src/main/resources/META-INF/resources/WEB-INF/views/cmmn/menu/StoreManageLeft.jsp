<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ page import="egovframework.coviframework.util.StringUtil"%>
<%
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<style>
/*.AXTree_none{outline:1px solid #eaeaea !important}
.AXTree_none .alink {cursor:cell}
.AXTree_none .alink:link {text-decoration:underline;cursor:hand}*/
</style>
<link rel="stylesheet" type="text/css" href="<%=cssPath %>/simpleAdmin/resources/css/simpleAdmin.css">
<link rel="stylesheet" type="text/css" href="<%=cssPath %>/appstore/resources/css/appstore.css">
<div class="cLnbTop">
	<h2><spring:message code="Cache.lbl_appStore"/></h2><!-- 앱스토어 -->
	<div class=domain style="display:none;">
		<label><spring:message code="Cache.lbl_Domain"/></label>
		<select class="selectType02" id="selectDomain"></select>
	</div>	
</div>
<div class='cLnbMiddle mScrollV scrollVType01'>
	<ul class="contLnbMenu appstoreMenu" id="leftStoreMenu"></ul>			
</div>
<script type="text/javascript">
	var confMenu = {
		leftData : '${leftMenuData}',
		loadContent : '${loadContent}',
		domainId : '${selDomainid ne null && selDomainid ne '' ? selDomainid: domainId}',
		isAdmin : '${isAdmin}',
		$mScrollV : $('.mScrollV'),
		portalUrl : '/approval/layout/approval_StoreUserFormList.do?CLSYS=store&CLMD=manage&CLBIZ=store',
		objectInit : function(){			
			$(".commContLeft").addClass("appstoreLeft");
			//기준날짜 구하기
			this.initLeft();
			$('.selOnOffBox a').unbind('click').on('click', function(){
				if($(this).hasClass('active')){
					$(this).removeClass('active');
					$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').removeClass('active');
				}else {
					$(this).addClass('active');
					$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');			
				}	
			});
		},
		initLeft : function(){
		 	var opt = {
		 			lang : "ko",
		 			isPartial : "true"
		 	};
		 	var leftData = ${leftMenuData};
		 	var coviMenu = new CoviMenu(opt);
		 	
		 	if(leftData.length != 0){
		 		coviMenu.render('#leftStoreMenu', leftData, 'userLeft');
		 	}
		 	
		 	confMenu.domainCode = coviCtrl.renderDomainAXSelect('selectDomain', 'ko', 'changeDomain', '', confMenu.domainId);
			coviCtrl.bindmScrollV($('.mScrollV'));
		 	if(this.loadContent == 'true'){
		 		CoviMenu_GetContent(confMenu.portalUrl);
		  	}else{
		  		if ('${menuId}' != ''){
		  			var obj  = $( "#leftStoreMenu div[data-menu-id='${menuId}']");
		  			
		  			obj.find("a").addClass("selected");
		  			var parentObj =obj.parent(".selOnOffBoxChk");
		  			
		  			parentObj.siblings(".selOnOffBox").find(".btnOnOff").addClass('active');		
		  			parentObj.addClass('active');		

		  			parentObj =parentObj.parent(".selOnOffBoxChk");
		  			if(parentObj.length>0){
			  			parentObj.siblings(".selOnOffBox").find(".btnOnOff").addClass('active');		
			  			parentObj.addClass('active');		
		  			}	
		  		}
		  	}
		},
	}
	function changeDomain($this){
		var menuObj = $("#leftStoreMenu .selected").closest("div");
		var url =confMenu.portalUrl;
		
		if ($("#leftStoreMenu .selected").length > 0)
			url = decodeURIComponent(menuObj.attr("data-menu-url"));

		url += "&menuid="+menuObj.attr("data-menu-id")+"&seldomainid="+$this.value;
		location.replace(url)
	}
	$(document).ready(function(){
		confMenu.objectInit();
	});

</script>
