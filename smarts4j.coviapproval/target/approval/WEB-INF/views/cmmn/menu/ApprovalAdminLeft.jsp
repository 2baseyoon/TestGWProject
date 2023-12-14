<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<nav class="lnb">
	<h2 class="gnb_left_tit">
		<span class="gnb_tit" onclick="">
			전자결재
		</span>
	</h2>
	<ul id="lnb_con" class=lnb_list>
	</ul>
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
		var opt = {
				lang : "ko",
				isPartial : "true"
		};
		coreLeft = new CoviMenu(opt);
		
		if(leftData.length != 0){
			coreLeft.render('#lnb_con', leftData, 'adminLeft');
			if(loadContent == 'true'){
				var $first = $('#lnb_con li').first().find('a');
	        	if($first){
	        		$first.click();
	        	}	
			}
    	}
	}
	
		
</script>
