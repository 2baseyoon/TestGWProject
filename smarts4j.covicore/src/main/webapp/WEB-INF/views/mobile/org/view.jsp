<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="org_view_page">

	<header id="org_view_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
				<div class="menu_link">
					<a href="#" class="pg_tit" id="org_view_a_title"></a>
				</div>
			</div>
		</div>
	</header>
    
	<div data-role="content" class="cont_wrap" id="org_view_content">
		<div class="profile_wrap">
			<div class="profile_inner">
				<div class="photo" id="org_view_photo" style="background-position: 50% 0%;"></div>
				<ul class="info">
					<li class="team"><span id="org_view_span_deptname"></span><span id="org_view_span_joblevel"></span></li>
					<li class="name" id="org_view_li_displayname"></li>
					<li class="mobile" id="org_view_li_mobile"></li>
				</ul>
				<ul class="contact" id="org_view_contact"></ul>
				<div class="detail_contact">
					<ul>
						<li id="org_view_li_email"><i class="ico_email"></i></li>
						<li id="org_view_li_office"><i class="ico_office"></i></li>
					</ul>
				</div>
				
				<div id="org_view_addcontact" class="btn_mailprofile_wrap" style="display: none;">
					<a href="javascript: mobile_org_addContact();" class="btn_mailprofile"><span><spring:message code='Cache.lbl_AddContact' /></span></a>
				</div>
			</div>
		</div>
		<input type="hidden" id="org_view_hid_messenger" />
		<input type="hidden" id="org_view_hid_info" />
	</div>
	
</div>

