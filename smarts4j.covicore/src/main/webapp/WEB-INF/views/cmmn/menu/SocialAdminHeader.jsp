<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<script type="text/javascript">
	var headerdata = ${topMenuData};
	
	$(document).ready(function (){
		var opt = {
    			lang : "ko",
    			isPartial : "true"
    	};
    	var coviMenu = new CoviMenu(opt);
    	
    	coviMenu.render("#topmenu", headerdata, "jqueryUIHorizontal");
    	//coviMenu.renderAjax("#topmenu", "1", "N", "", "Top", "", "jqueryUIHorizontal");
	});
	
		// 관리자상단 메뉴 선택
	function clickAdminHeader(pUrl) {
	    /*
		// 선택된 상단 메뉴 정보 기억
	    window.sessionStorage.setItem("TopMenuUrl_Admin", pUrl);

	    // 좌측 메뉴 선택 상태값 초기화
	    if (window.sessionStorage.getItem("AdminLeftID") != undefined && window.sessionStorage.getItem("AdminLeftID") != null && window.sessionStorage.getItem("AdminLeftID") != "" && window.sessionStorage.getItem("AdminLeftID") != "undefined")
	        window.sessionStorage.removeItem("AdminLeftID");
	    */
	    
	  	//left partial loading
		$.ajax({
	        type : "GET",
	        beforeSend : function(req) {
	            req.setRequestHeader("Accept", "text/html;type=ajax");
	        },
	        url : "menu/adminleft.do?fragments=left&menuid=1",
	        success : function(res) {
	        	$("#left").html(res);
	        },
	        error : function(response, status, error){
					CFN_ErrorAjax("menu/adminleft.do", response, status, error);
	        }
	    });
	    
	    //content partial loading
		$.ajax({
	        type : "GET",
	        beforeSend : function(req) {
	            req.setRequestHeader("Accept", "text/html;type=ajax");
	        },
	        url : pUrl + "?fragments=content",
	        success : function(res) {
	        	$("#content").html(res);
	        },
	        error : function(response, status, error){
				CFN_ErrorAjax(pUrl, response, status, error);
	        }
	    });
	}
	
</script>

<h1 class="nav_logo"><a></a></h1>
<nav class="gnb">
	<ul id="topmenu"></ul>
</nav>
