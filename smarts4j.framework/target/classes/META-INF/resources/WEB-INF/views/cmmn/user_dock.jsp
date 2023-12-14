<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"  %>
<div class="nav_root">
    <div class="nav_list">
        <nav id="quickContainer">
			<c:forEach var="list"  items="${myQuickMenu}" varStatus="status">
	            <a href="#" class="link ${fn:toLowerCase(list.Code)}" id="quick_${list.Code}"  data-menu-id="${list.Code}" data-menu-url="${list.Reserved1}"  onclick="CoviMenu_ClickQuick(this)" data-tooltip-title="${covi:getDicInfo(list.MultiCodeName,lang)}"><span>${covi:getDicInfo(list.MultiCodeName,lang)}</span>
            	<c:if test="${list.ReservedInt eq 1}">
		            <em id="quickCnt_${list.Code}"></em>
            	</c:if>
	            </a>
            </c:forEach>
        </nav>
    </div>
    <button type="button" class="ui_icon_button nav_setting_toggle" id="btnFavAdd"><span>편집</span></button>
</div>
<script type="text/template" id="dock_setting_context_menu">
    <div class="head">
        <h3 class="title">독메뉴</h3>
    </div>
    <div class="menu_content">
        <ul>
			<c:forEach var="list"  items="${allQuickMenu}" varStatus="status">
	            <li><label class="ui_checkbox"><input type="checkbox" ${list.MyUse == "Y"?"checked":""}><i></i><span>${covi:getDicInfo(list.MultiCodeName,lang)}</span></label></li>
            </c:forEach>
        </ul>
    </div>
</script>