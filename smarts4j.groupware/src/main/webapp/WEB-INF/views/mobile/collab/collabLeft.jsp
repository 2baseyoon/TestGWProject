<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="egovframework.baseframework.util.SessionHelper, egovframework.coviframework.util.RedisDataUtil" %>

<div class="cover_leftmenu collaboration" style="display:none; cursor: pointer;">
	<div class="LsubHeader">
		<span class="LsubTitle collaboration" onclick="javascript: mobile_comm_go('/groupware/mobile/collab/portal.do')"><spring:message code='Cache.lbl_Collab' /></span> <!-- 협업스페이스 -->
		<span class="LsubTitle_btn">
			<button type="button" onclick="mobile_comm_TopMenuClick('collab_leftmenu_tree',true); $('#collab_menu_btnPrjAdd').siblings('.column_menu').removeClass('active'); return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i><spring:message code='Cache.btn_Close' /></i></button>
		</span>
	</div>
	<div class="tree_default" id="collab_leftmenu_tree">
		<ul class="h_tree_menu_wrap">
			<li>
				<div class="h_tree_menu">
					<a class="t_link not_tree ui-link" id="collab_myTodo">
						<span class="t_ico_with"></span><spring:message code='Cache.lbl_MyWork' /><!-- 내업무 -->
					</a>
				</div>
			</li>
			<li>
				<div class="h_tree_menu">
					<a class="t_link not_tree ui-link" data-menu-target="Current" data-menu-alias="" data-menu-url="">
						<span class="t_ico_open"></span>
						<span class="t_ico_my"></span>
						<spring:message code='Cache.lbl_TeamWorkBox' /><!-- 팀업무함 -->
					</a>
					<ul class="sub_list" id="collab_deptList">
					</ul>
				</div>
			</li>
			<li>
				<div class="h_tree_menu">
					<a class="t_link not_tree ui-link" data-menu-target="Current" data-menu-alias="" data-menu-url="">
						<span class="t_ico_open"></span>
						<span class="t_ico_my"></span>
						<spring:message code='Cache.lbl_Project' /><!-- 프로젝트 -->
					</a>
					<ul class="sub_list" id="collab_prjListP">
					</ul>
				</div>
				<a class="btn_spc_add ui-link" id="collab_menu_btnPrjAdd"></a>
				<div class="column_menu">
					<a id="collab_menu_Usingtemplate"><spring:message code='Cache.btn_UseTemplate' /></a><!-- 템플릿 사용 -->
	                <a id="collab_menu_PrjAdd"><spring:message code='Cache.btn_EmptyProject' /></a><!-- 빈 프로젝트 -->
				</div>
			</li>
			<%if(RedisDataUtil.getBaseConfig("isUseCollabStatMenu").equals("Y")){ %>
			<li>
				<div class="h_tree_menu">
					<a class="t_link not_tree ui-link" data-menu-target="Current" data-menu-alias="" data-menu-url="">
						<span class="t_ico_close"></span>
						<span class="t_ico_my"></span>
						<spring:message code='Cache.lbl_Ready' /><spring:message code='Cache.lbl_Project' /> <!-- 대기프로젝트 -->
					</a>
					<ul class="sub_list" id="collab_prjListW">
					</ul>
				</div>
			</li>
			<li>
				<div class="h_tree_menu">
					<a class="t_link not_tree ui-link" data-menu-target="Current" data-menu-alias="" data-menu-url="">
						<span class="t_ico_close"></span>
						<span class="t_ico_my"></span>
						<spring:message code='Cache.lbl_Hold' /><spring:message code='Cache.lbl_Project' /> <!-- 보류프로젝트 -->
					</a>
					<ul class="sub_list" id="collab_prjListH">
					</ul>
				</div>
			</li>
			<li>
				<div class="h_tree_menu">
					<a class="t_link not_tree ui-link" data-menu-target="Current" data-menu-alias="" data-menu-url="">
						<span class="t_ico_close"></span>
						<span class="t_ico_my"></span>
						<spring:message code='Cache.lbl_Completed' /><spring:message code='Cache.lbl_Project' /> <!-- 완료프로젝트 -->
					</a>
					<ul class="sub_list" id="collab_prjListC">
					</ul>
				</div>
			</li>
			<% } %>
		</ul>	
	</div>						
</div>