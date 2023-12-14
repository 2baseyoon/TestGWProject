<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<nav class="lnb">
	<h2 class="gnb_left_tit">
		<span class="gnb_tit" onclick="">
			CoviCore
		</span>
	</h2>
	<ul id="lnb_con" class=lnb_list></ul>
</nav>

<script type="text/javascript">
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var domainId = '${domainId}';
	var isAdmin = '${isAdmin}';
	
	var coreLeft;
	
	initLeft();
	
	function initLeft(){
		//left menu 그리는 부분
		coreLeft = new CoviMenu({
			lang: "ko",
			isPartial: "true"
		});
		
		if(leftData.length != 0){
			coreLeft.render('#lnb_con', leftData, 'adminLeft');
			
			var $first = $('#lnb_con li').first().find('a');
			var pageReload = false;
			
			$.each($('#lnb_con li'), function(idx, el){
				if (decodeURIComponent(el.dataset.menuUrl).indexOf(location.pathname) > -1){
					setManuActive(el);
					pageReload = true;
				}
			});
			
			if (!pageReload && $first){
				$first.click();
			}
    	}
	}
</script>
