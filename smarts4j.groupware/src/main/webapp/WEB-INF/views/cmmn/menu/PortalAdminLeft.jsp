<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<nav class="lnb">
	<h2 class="gnb_left_tit">
		<span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false">
			포탈
		</span>
	</h2>
	<ul id="lnb_con" class="lnb_list"></ul>
</nav>

<script type="text/javascript">
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	
	leftInif();
	
	function leftInif(){
		//left menu 그리는 부분
		var portalLeft = new CoviMenu({
			lang: "ko",
			isPartial: "true"
		});
		
		if(leftData.length != 0){
			portalLeft.render('#lnb_con', leftData, 'adminLeft');
			
			if(loadContent == 'true'){
				//leftmenu_goToPageMain();
				var $first = $('#lnb_con li').first().find('a').first();
	        	if($first){
	        		$first.click();
	        	}
	    	}
			else {
				$.each($('#lnb_con li'), function(idx, el){
					if (decodeURIComponent(el.dataset.menuUrl).indexOf(location.pathname) > -1){
						$(el).find('a').click();
					}
				});
			}
			
    	}
	}

	function leftmenu_goToPageMain(){
		CoviMenu_GetContent('/groupware/layout/portal_PortalManage.do?CLSYS=portal&CLMD=admin&CLBIZ=Portal');	
	}
	
</script>
