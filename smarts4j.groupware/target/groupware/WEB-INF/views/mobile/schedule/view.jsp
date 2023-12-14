<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="schedule_view_page" adata='view'>

	<header id="schedule_view_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
				<div class="menu_link gnb">
					<a href="#" class="pg_tit"><spring:message code='Cache.BizSection_Schedule' /> <spring:message code='Cache.lbl_DetailView' /></a> <!-- 일정 상세보기 -->
				</div>
			</div>
			<div class="utill" style="display: none;">
				<div class="dropMenu">
					<a href="#" class="topH_exmenu" onclick="javascript: mobile_schedule_showORhide(this);"><span class="Hicon">확장메뉴</span></a>
					<div class="exmenu_layer">
						<!-- <strong class="blind">본문 폰트 크기 조정</strong>
						<div class="font_box font_box_s">
							<a href="#" class="small dis"><span class="sim">본문 폰트 크기 작게 보기</span></a>
							<a href="#" class="big"><span class="sim">본문 폰트 크기 크게 보기</span></a>
							<span class="font_box_size font_zoom1">가</span>
						</div> -->
						<ul class="exmenu_list" id="schedule_view_exmenu_list">
							<li><a id="schedule_view_modify" href="javascript: mobile_schedule_clickmodify();" class="btn" style="display: none;"><spring:message code='Cache.btn_Modify' /></a></li> <!-- 수정 -->
							<li><a id="schedule_view_delete" href="javascript: mobile_schedule_clickdelete();" class="btn" style="display: none;"><spring:message code='Cache.btn_delete' /></a></li> <!-- 삭제 -->
						</ul>
					</div>
				</div>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="schedule_view_content">

		<div class="post_title">
			<p  id="schedule_view_folder" class="post_location"></p>
			<h2 id="schedule_view_subject" class="tit"></h2>
			<a id="schedule_view_photo"  href="#" class="thumb" style="background-image:url(../../resources/images/user_01.jpg);"></a>
			<p class="info"><a id="schedule_view_name" href="#" class="name"></a></p>
			<p class="info"><span id="schedule_view_registDate" class="date"></span><span class="ico_hits"></span></p>
		</div>
		<div class="write_wrap view">
			<div class="more_info">
				<dl>
					<dt><spring:message code='Cache.lbl_RepeateDate' /></dt> <!-- 일시 -->
					<dd id="schedule_view_startenddatetime"></dd>
				</dl>
				<dl class="place">
					<dt><spring:message code='Cache.lbl_Place' /></dt> <!-- 장소 -->
					<dd id="schedule_view_place"></dd>
					<dd id="schedule_view_placemap"><img id="schedule_view_placeimg" src="../../resources/images/@ex_map02.jpg" alt=""></dd>
				</dl>
				<dl id="schedule_view_attendee" class="attendant"></dl> <!-- 참석자 -->
				<dl>
					<dt><spring:message code='Cache.lbl_Resources' /></dt> <!-- 자원 -->
					<dd id="schedule_view_resource"></dd>
				</dl>
			</div>
			<div id="schedule_view_isnotificationdiv" class="more_info" style="display: none;">
				<dl>
					<dt><spring:message code='Cache.lbl_BeforInform' /></dt> <!-- 미리알림 -->
					<dd>
						<div class="opt_setting" onclick="javascript: mobile_schedule_saveAlarm(this);">
							<span id="schedule_view_isremindera" class="ctrl" ></span>
						</div>
						<div id="schedule_view_notice_divReminderTime" style="display: inline; visibility: hidden;">
							<select id="schedule_view_remindertime" class="" name="" onchange="javascript: mobile_schedule_saveAlarm(this);">
								<option value="1">1<spring:message code='Cache.lbl_before_m' /></option> <!-- 1분 전 -->
								<option selected="selected" value="10">10<spring:message code='Cache.lbl_before_m' /></option> <!-- 10분 전 -->
								<option value="20">20<spring:message code='Cache.lbl_before_m' /></option> <!-- 20분 전 -->
								<option value="30">30<spring:message code='Cache.lbl_before_m' /></option> <!-- 30분 전 -->
								<option value="60">1<spring:message code='Cache.lbl_before_h' /></option> <!-- 1시간 전 -->
								<option value="180">3<spring:message code='Cache.lbl_before_h' /></option> <!-- 3시간 전 -->
								<option value="360">6<spring:message code='Cache.lbl_before_h' /></option> <!-- 6시간 전 -->
								<option value="720">12<spring:message code='Cache.lbl_before_h' /></option> <!-- 12시간 전 -->
								<option value="1440">1<spring:message code='Cache.lbl_before_d' /></option> <!-- 1일 전 -->
								<option value="2880">2<spring:message code='Cache.lbl_before_d' /></option> <!-- 2일 전 -->
								<option value="4320">3<spring:message code='Cache.lbl_before_d' /></option> <!-- 3일 전 -->
							</select>
						</div>
					</dd>
				</dl>
				<dl>
					<dt><spring:message code='Cache.lbl_commentNotify' /></dt> <!-- 댓글알림 -->
					<dd>
						<div class="opt_setting" onclick="javascript: mobile_schedule_saveAlarm(this);">
							<span id="schedule_view_isrcommenta" class="ctrl"></span>
						</div>
					</dd>
				</dl>
			</div>
			
			<div id="schedule_view_isnotificationtotaldiv" class="more_info" style="display:none;">			
				<dl>
					<dt><spring:message code='Cache.lbl_totalAlarm' /></dt> 
					<dd>
    					<div class="ui-checkbox">
    					
    						<label for="schedule_view_totalisremindera" class="ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off"><spring:message code='Cache.lbl_BeforInform' /></label>
    						<input id="schedule_view_totalisremindera" type="checkbox" onchange="mobile_schedule_changeTotalReminder(this);">
   						</div>						
						<div id="schedule_view_notice_totaldivReminderTime" style="display: inline; visibility: visible;">
							<div class="ui-select">
								<div id="schedule_view_totalremindertime-button" class="ui-btn ui-icon-carat-d ui-btn-icon-right ui-corner-all ui-shadow">
									<select id="schedule_view_totalremindertime" class="" name="" disabled="disabled">										
										<option value="1">1<spring:message code='Cache.lbl_before_m' /></option> <!-- 1분 전 -->
										<option selected="selected" value="10">10<spring:message code='Cache.lbl_before_m' /></option> <!-- 10분 전 -->
										<option value="20">20<spring:message code='Cache.lbl_before_m' /></option> <!-- 20분 전 -->
										<option value="30">30<spring:message code='Cache.lbl_before_m' /></option> <!-- 30분 전 -->
										<option value="60">1<spring:message code='Cache.lbl_before_h' /></option> <!-- 1시간 전 -->
										<option value="180">3<spring:message code='Cache.lbl_before_h' /></option> <!-- 3시간 전 -->
										<option value="360">6<spring:message code='Cache.lbl_before_h' /></option> <!-- 6시간 전 -->
										<option value="720">12<spring:message code='Cache.lbl_before_h' /></option> <!-- 12시간 전 -->
										<option value="1440">1<spring:message code='Cache.lbl_before_d' /></option> <!-- 1일 전 -->
										<option value="2880">2<spring:message code='Cache.lbl_before_d' /></option> <!-- 2일 전 -->
										<option value="4320">3<spring:message code='Cache.lbl_before_d' /></option> <!-- 3일 전 -->
									</select>
								</div>
							</div>
						</div>
						<a id="schedule_view_btnAllNotiModify" onclick="javascript: mobile_schedule_modifyAllNoti();" class="g_btn01 ui-link" style="float: right;"><spring:message code='Cache.btn_totalAlarmModify' /></a>
					</dd>
					<dd>
					    <div class="ui-checkbox">
					    	<label for="schedule_view_totalisrcomment" class="ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off"><spring:message code='Cache.lbl_commentNotify' /></label>
					    	<input id="schedule_view_totalisrcomment" type="checkbox">
				    	</div>
						<a id="schedule_view_btnAllNotiDelete" onclick="javascript: mobile_schedule_deleteAllNoti();" class="g_btn01 ui-link" style="float: right;"><spring:message code='Cache.btn_totalAlarmTurnOff' /></a>
					</dd>
				</dl>				
			</div>
			
			<div id="schedule_view_description" class="post_cont" style="padding-top:10px;min-height:53px;"></div>
			<div id="schedule_view_like" class="end_like_area"></div>
			<div covi-mo-comment></div>
		</div>
		
	</div>
	
</div>

