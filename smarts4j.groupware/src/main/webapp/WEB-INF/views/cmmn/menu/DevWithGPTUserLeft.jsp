<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<div class="cLnbTop"><h2>ChatGPT 도우미</h2></div>
<div>
	<ul id="leftmenu" class="contLnbMenu devhelperMenu">
	</ul>
</div>
<script type="text/javascript">
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	
	initLeft();
	
function initLeft(){
		var opt = {
    			lang : "ko",
    			isPartial : "true"
    	};
		
    	var coviMenu = new CoviMenu(opt);
    	
    	g_lastURL = '/groupware/layout/devwithgpt_main.do?CLSYS=DevWithGPT&CLMD=user&CLBIZ=DevWithGPT&promptType=FindError';
    	
    	if(leftData.length != 0){
    		coviMenu.render('#leftmenu', leftData, 'userLeft');
    	}
    	if(loadContent == 'true') {
    		CoviMenu_GetContent('/groupware/layout/devwithgpt_main.do?CLSYS=DevWithGPT&CLMD=user&CLBIZ=DevWithGPT&promptType=FindError');
    		g_lastURL = '/groupware/layout/devwithgpt_main.do?CLSYS=DevWithGPT&CLMD=user&CLBIZ=DevWithGPT&promptType=FindError';
    	}
	}	
</script>

