<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@page import="egovframework.coviframework.util.ClientInfoHelper"%>
<%@page import="egovframework.coviframework.util.RedisDataUtil"%>

<div data-role="page" id="collab_menu_list">
	<header>
		<div class="sub_header">
			<div class="l_header w_header menu_header">
				<a href="javascript: mobile_comm_back();" class="topH_close ui-link"><span class="Hicon"><spring:message code='Cache.btn_Close' /></span></a><!-- 닫기 -->
				<div class="menu_link gnb show">
					<div class="menu_list_area menu_list_project">
						<div class="menu_list_top">
							<strong class="type">Project</strong>
							<!-- 제목 2줄까지만 노출 -->
							<strong class="title"></strong>
							<div class="menu_list_btn">
								<ul>
									<li><a class="btn_invite"><spring:message code='Cache.btn_InviteMember' /></a></li><!-- 팀원초대 -->
									<!-- <li><a class="btn_groupchat">그룹채팅</a></li>
									<li><a class="btn_video">화상회의</a></li> -->
								</ul>
							</div>
						</div>
						<ul class="collabo_menu_list">
							<li><a class="t_link" data-view="KANB"><span class="t_ico_collabo01"></span><spring:message code='Cache.lbl_KanbanBoard' /></a></li><!-- 칸반보드 -->
							<li><a class="t_link" data-view="LIST"><span class="t_ico_collabo02"></span><spring:message code='Cache.lbl_List_View' /></a></li><!--  목록보기 -->
							<li><a class="t_link" data-view="CAL"><span class="t_ico_collabo03"></span><spring:message code='Cache.lbl_Calendar' /></a></li><!-- 캘린더 -->
<%if (RedisDataUtil.getBaseConfig("CollabGantt").equals("Y")){ %>
							<li style="display:none"><a class="t_link" data-view="GANT"><span class="t_ico_collabo04"></span><spring:message code='Cache.lbl_Gant' /></a></li><!-- 간트차트 -->
<%} %>

							<!--<li><a class="t_link" data-type="FILE"><span class="t_ico_collabo04"></span><spring:message code='Cache.lbl_File' /></a></li> 파일 -->
							<!--<li><a class="t_link" data-type="APPROVAL"><span class="t_ico_collabo05"></span><spring:message code='Cache.lbl_RelatedApproval' /></a></li> 관련결재 -->
							<!-- <li><a class="t_link" data-type="SURVEY"><span class="t_ico_collabo06"></span><spring:message code='Cache.lbl_Profile_Questions' /></a></li>설문 -->
							<!-- <li><a class="t_link"><span class="t_ico_collabo07"></span>업무보고</a></li> -->
						</ul>
					</div>
				</div>
			</div>
		</div>
	</header>
</div>