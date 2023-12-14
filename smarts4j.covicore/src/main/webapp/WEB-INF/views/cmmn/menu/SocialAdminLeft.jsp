<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>


<nav class="lnb">
	<h2 class="gnb_left_tit">
		<span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false">
			<spring:message code="Cache.lbl_AdminHome"/>
		</span>
	</h2>
	<ul>
		<li class="off over_non"><a href="javascript:;" onclick="loadContent('layout/system_BaseConfigManage.do?system=Core');return false;">기초설정 관리</a>
		<li class="off over_non"><a href="javascript:;" onclick="loadContent('layout/system_BaseCodeManage.do?system=Core');return false;">기초코드 관리</a>
		<li class="off over_non"><a href="javascript:;" onclick="loadContent('layout/system_DictionaryManage.do?system=Core');return false;">다국어 관리</a>
		<li class="off over_non"><a href="javascript:;" onclick="loadContent('layout/system_DomainManage.do?system=Core');return false;">도메인 관리</a>
		<li class="off over_non"><a href="javascript:;" onclick="loadContent('layout/menu_MenuManage.do?system=Core');return false;">메뉴 관리</a>
		<li class="off over_non"><a href="javascript:;" onclick="loadContent('layout/system_CacheManage.do?system=Core');return false;">캐쉬 관리</a>
		<li class="off over_non"><a href="javascript:;" onclick="loadContent('layout/devhelper_CommonControl.do?system=Core');return false;">공통 컨트롤</a>
		<!--  
		<li class="off over_non"><a href="javascript:;" onclick="setACL();return false;">권한 지정 창</a>
		<li class="off over_non"><a href="javascript:;" onclick="reloadMenuCache();return false;">menu 캐쉬 Reload</a>
		<li class="off over_non"><a href="javascript:;" onclick="queryMenu();return false;">menu 쿼리</a>
		-->
	</ul>
	<ul id="lnb_con">
	</ul>
</nav>

<script type="text/javascript">
	var menuId = '${topMenuId}';
	
	function leftmenu_goToPageMain(){
		location.href = "home.do";
	}
	$(document).ready(function (){		
		if(menuId != '' && menuId != null){
			$('.lnb h2').text(menuId);	
		}
		
	});
		
	function queryMenu(){
		$.ajax({
			type:"POST",
			data:{
				"DomainID" : "1",
				"IsAdmin" : "N",
				"BizSection" : "",
				"MenuType" : "Top"
			},
			url:"menu/getmenu.do",
			success : function (res) {
				if(res.result == "ok"){
					var $leftMenu = $("#lnb_con"); 
					$leftMenu.empty();
					$.each(res.data, function () {
				        $leftMenu.append(
				            coviMenu.getMenuItem(this)
				        );
				    });
				    
					$leftMenu.menu();
					
				}
			},
			error : function(response, status, error){
				CFN_ErrorAjax("menu/getmenu.do", response, status, error);
			}
		});
	}
	
	function reloadMenuCache(){
		$.ajax({
			type:"POST",
			data:{
				"Key" : "MENU_"
			},
			url:"menu/reload.do",
			success : function (res) {
				if(res.result == "ok"){
					Common.Inform("Success");
				} else {
					Common.Inform("Fail");
				}
			},
			error : function(response, status, error){
				CFN_ErrorAjax("menu/getmenu.do", response, status, error);
			}
		});
	}
	
	function loadContent(pUrl){
		$.ajax({
	        type : "GET",
	        beforeSend : function(req) {
	            req.setRequestHeader("Accept", "text/html;type=ajax");
	        },
	        url : pUrl + "&fragments=content",
	        success : function(res) {
	        	$("#content").html(res);
	        },
	        error : function(response, status, error){
				CFN_ErrorAjax(pUrl, response, status, error);
	        }
	    });
	}
	
</script>
