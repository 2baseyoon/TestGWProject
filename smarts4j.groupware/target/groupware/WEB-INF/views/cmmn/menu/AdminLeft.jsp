<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>

<script type="text/javascript">
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var domainId = '${domainId}';
	var isAdmin = '${isAdmin}';
	
	var coreLeft;
	$(document).ready(function (){
		//left menu 그리는 부분
		var opt = {
				lang : "ko",
				isPartial : "true"
		};
		coreLeft = new CoviMenu(opt);
		
		if(leftData.length == 0){
			var menuId = coviCmn.getCookie("c_leftId");
			if(menuId != null && menuId != ''){
				coreLeft.get(domainId, isAdmin, "", "Left", menuId, "getLeftMenuCallback");	
			}
		} else {
			coreLeft.render('#lnb_con', leftData, 'defaultVertical');
			var $first = $('#lnb_con li').first().find('a');
	    	if($first){
	    		$first.click();
	    	}
		}
		
	});
	
	function getLeftMenuCallback(data){
		coreLeft.render('#lnb_con', data, 'defaultVertical');
	}
	
</script>

<nav class="lnb">
	<h2 class="gnb_left_tit">
		<span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false">
			<spring:message code="Cache.lbl_AdminHome"/>
		</span>
	</h2>
	<!--  
	<ul>
		<li class="off over_non"><a href="javascript:;" onclick="CoviMenu_GetContent('/covicore/layout/system_BaseConfigManage.do?CLSYS=core');return false;">기초설정 관리</a>
		<li class="off over_non"><a href="javascript:;" onclick="CoviMenu_GetContent('/covicore/layout/system_BaseCodeManage.do?CLSYS=core');return false;">기초코드 관리</a>
		<li class="off over_non"><a href="javascript:;" onclick="CoviMenu_GetContent('/covicore/layout/system_DictionaryManage.do?CLSYS=core');return false;">다국어 관리</a>
		<li class="off over_non"><a href="javascript:;" onclick="CoviMenu_GetContent('/covicore/layout/system_DomainManage.do?CLSYS=core');return false;">도메인 관리</a>
		<li class="off over_non"><a href="javascript:;" onclick="CoviMenu_GetContent('/covicore/layout/menu_MenuManage.do?CLSYS=core');return false;">메뉴 관리</a>
		<li class="off over_non"><a href="javascript:;" onclick="CoviMenu_GetContent('/covicore/layout/system_CacheManage.do?CLSYS=core');return false;">캐쉬 관리</a>
		<li class="off over_non"><a href="javascript:;" onclick="CoviMenu_GetContent('/covicore/layout/devhelper_CommonControl.do?CLSYS=core');return false;">공통 컨트롤</a>
		<li class="off over_non"><a href="javascript:;" onclick="setACL();return false;">권한 지정 창</a>
		<li class="off over_non"><a href="javascript:;" onclick="reloadMenuCache();return false;">menu 캐쉬 Reload</a>
		<li class="off over_non"><a href="javascript:;" onclick="queryMenu();return false;">menu 쿼리</a>
	</ul>
	-->
	<ul id="lnb_con">
	</ul>
</nav>