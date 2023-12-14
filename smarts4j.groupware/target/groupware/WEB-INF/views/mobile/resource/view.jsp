<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="resource_view_page" data-close-btn="none" adata='view'>

	<header data-role="header" id="resource_view_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_back();" class="topH_close"><span><!-- 닫기 --></span></a>
				<div class="menu_link gnb">
					<a id="resource_view_title" class="pg_tit"><spring:message code='Cache.lbl_resource_title' /> <spring:message code='Cache.lbl_detail' /></a> <!-- 자원예약 상세 -->
				</div>
			</div>
			<div class="utill" style="display: none;">
          		<div class="dropMenu">
            		<a class="topH_exmenu" onclick="javascript: mobile_resource_showORhide(this);"><span class="Hicon">확장메뉴</span></a>
					<div class="exmenu_layer">
						<!-- <strong class="blind">본문 폰트 크기 조정</strong>
						<div class="font_box font_box_s">
							<a href="#" class="small"><span class="sim">본문 폰트 크기 작게 보기</span></a>
							<a href="#" class="big"><span class="sim">본문 폰트 크기 크게 보기</span></a>
							<span class="font_box_size font_zoom1">가</span>
						</div> -->
						<ul class="exmenu_list" id="resource_view_exmenu_list"></ul>
					</div>
        		</div>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="resource_view_content">
		<div class="resource_view">
			<dl class="info_list">
				<dt id="resource_view_datetime"></dt>
				<dd class="name" id="resource_view_registerName"></dd>
				<dd class="place" id="resource_view_folderName"> <a onclick="javascript: mobile_resource_clickResourceInfo();" class="g_btn01"><spring:message code='Cache.lbl_FromInfo' /></a></dd> <!-- 정보 -->
				<dd class="desc" id="resource_view_subject"></dd>
				<dd class="repeat" id="resource_view_repeatInfo"></dd>
				<dd class="state" id="resource_view_approvalState"></dd>
			</dl>
			<div id="resource_view_isnotificationdiv" class="write_wrap view" style="padding-bottom: 0; border-top: 1px solid #ddd;">
			    <div class="more_info" style="border: none; padding: 12px 14px 12px 14px;">
					<dl id="resource_view_attendee" class="attendant"></dl> <!-- 참석자 -->
					<dl style="padding-left: 70px; display: none;">
						<dt style="color: #999;font-size: 0.87rem;top: 13px;"><spring:message code='Cache.lbl_BeforInform' /></dt> <!-- 미리알림 -->
						<dd>
							<div class="opt_setting" onclick="javascript: mobile_resource_saveAlarm(this);">
								<span id="resource_view_isremindera" class="ctrl" ></span>
							</div>
							<div id="resource_view_notice_divReminderTime" style="display: inline; visibility: hidden;">
								<select id="resource_view_remindertime" class="" name="" onchange="javascript: mobile_resource_saveAlarm(this);">
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
					<dl style="padding-left: 70px; margin-top: 13px; display: none;">
						<dt style="color: #999;font-size: 0.87rem;"><spring:message code='Cache.lbl_commentNotify' /></dt> <!-- 댓글알림 -->
						<dd>
							<div class="opt_setting" onclick="javascript: mobile_resource_saveAlarm(this);" style="top: 0px;">
								<span id="resource_view_isrcommenta" class="ctrl"></span>
							</div>
						</dd>
					</dl>
		        </div>
			</div>
			
			<div id="resource_view_isnotificationtotaldiv" class="write_wrap" style="padding-bottom: 0; border-top: 1px solid #ddd;display:none;">			
				<div class="more_info" style="border: none; padding: 12px 14px 12px 14px;">
					<dl style="padding-left: 70px;">
						<dt style="color: #999;font-size: 0.87rem;top: 13px;"><spring:message code='Cache.lbl_totalAlarm' /></dt> 
						<dd>
	    					<div class="ui-checkbox">	    					
	    						<label for="resource_view_totalisremindera" class="ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off"><spring:message code='Cache.lbl_BeforInform' /></label>
	    						<input id="resource_view_totalisremindera" type="checkbox" onchange="mobile_resource_changeTotalReminder(this);">
	   						</div>						
							<div id="resource_view_notice_totaldivReminderTime" style="display: inline; visibility: visible;">
								<div class="ui-select">
									<div id="resource_view_totalremindertime-button" class="ui-btn ui-icon-carat-d ui-btn-icon-right ui-corner-all ui-shadow">
										<select id="resource_view_totalremindertime" class="" name="" disabled="disabled">										
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
							<a id="resource_view_btnAllNotiModify" onclick="javascript: mobile_resource_modifyAllNoti();" class="g_btn01 ui-link" style="float: right;"><spring:message code='Cache.btn_totalAlarmModify' /></a>
						</dd>
						<dd>
						    <div class="ui-checkbox">
						    	<label for="resource_view_totalisrcomment" class="ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off"><spring:message code='Cache.lbl_commentNotify' /></label>
						    	<input id="resource_view_totalisrcomment" type="checkbox">
					    	</div>
							<a id="resource_view_btnAllNotiDelete" onclick="javascript: mobile_resource_deleteAllNoti();" class="g_btn01 ui-link" style="float: right;"><spring:message code='Cache.btn_totalAlarmTurnOff' /></a>
						</dd>
					</dl>				
				</div>
			</div>
			
			<ul class="info_list">
				<li id="resource_view_schedule">
					<span class="label"><spring:message code='Cache.lbl_resource_linkedSchedule' /></span>
				</li> <!-- 연결일정 -->
			</ul>
			<!-- <a onclick="javascript: mobile_resource_showORhide(this, 'self');" class="acc_link"><spring:message code='Cache.lbl_resource_standBy' /></a> 대기자 
			<div class="acc_cont person_list">
				<div class="src_h" id="resource_view_standByPersonList">
				</div>
			</div> -->
			<!-- 댓글 -->
			<div covi-mo-comment></div>
		</div>
	</div>
</div>