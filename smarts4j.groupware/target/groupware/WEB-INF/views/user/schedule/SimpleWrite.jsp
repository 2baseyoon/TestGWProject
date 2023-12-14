<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<aside id="simpleWritePop" class="schAddLayerPopup active schLayerPopContent" >
	<div>
		<div class="top">
			<ul class="tabMenu clearFloat">
				<li id="tapSCH" class="active" onclick="clickTap(this);"><a><spring:message code='Cache.lbl_Schedule' /></a></li><!-- 일정 -->
				<li id="tapRES" onclick="clickTap(this);"><a><spring:message code='Cache.lbl_Resources' /></a></li><!-- 자원 -->
			</ul>
			<a class="btnLayerClose" onclick="btnLayerCloseOnClick(this);"><spring:message code='Cache.lbl_schedule_closeView' /></a><!-- 일정보기 닫기 -->
		</div>
		<div class="middle" style="min-height: 210px;">
			<div class="tabContent shc active">
				<div class="cusSelect">
					<!-- 셀렉트 선택시 아래 input에 value값으로 ul 태그 li에 data-selvalue 값 입력 -->
					<input id="FolderType" type="txt" readonly class="selectValue"/>
					<span id="defaultFolderType" class="sleOpTitle" onclick="sleOpTitleOnClick(this);"></span>
					<ul id="ulFolderTypes" class="selectOpList">
					</ul>
				</div>
				<div>
					<input id="Subject" type="text" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.msg_mustEnterEvent' />" style="margin-right: 5px; width: calc(100% - 55px);" maxlength="100"/><!-- 일정명을 입력하세요. -->
					<div class="chkStyle01" style="display: inline-block;">
						<input type="checkbox" id="IsAllDay" onchange="scheduleUser.setAllDayCheck('S');"><label id="lbIsAllDay" for="IsAllDay" style="font-size: 12px;"><span></span><spring:message code='Cache.lbl_AllDay' /></label><!-- 종일 -->
					</div>
				</div>
				<div id="simpleSchDateCon" class="dateSel">
				</div>
				<div class="txtEdit">
					<span style="margin-right: 5px;"><spring:message code='Cache.lbl_Text'/></span><!-- 본문 -->
					<textarea id="Description" class="HtmlCheckXSS ScriptCheckXSS" style="display: inline-block; width: calc(100% - 38px);"></textarea>
					<input type="hidden" id="hidDescription" value="">
				</div>
			</div>
			<div class="tabContent res">
				<div>
					<div id="placeOfBusinessSel" style="display: none;"></div>
					<select id="resourceList" class="selectType02" onchange="scheduleUser.recommandResource();"></select>
					<a onclick="scheduleUser.addResource();" class="btnTypeDefault btnBlueBoder"><spring:message code='Cache.btn_Add' /></a><!-- 추가 -->
				</div>
				<div class="addSurveyTarget">
					<ul id="addedResourceList" class="clearFloat">
					</ul>
				</div>
				<!-- noti 클래스 상황에 맞는 텍스트에 active 클래스 추가 삭제로 텍스트 보이기 제거 -->
				<p id="msgSelectResource" class="noti noti02"><spring:message code='Cache.msg_mustSelectRes' /></p><!-- 자원을 선택해주세요 -->
				<p id="msgOK" class="noti"><spring:message code='Cache.msg_canReserveRes' /></p><!-- 해당시간에 예약이 가능합니다. -->
				<p id="msgNO" class="noti noti03"><spring:message code='Cache.msg_cannotpossiblereservationresource' /></p><!-- 예약이 불가능한 자원입니다. -->
				<p id="msgPast" class="noti noti03"><spring:message code='Cache.msg_cannotBookingBefore' /></p><!-- 현재보다 이전 시간에 대해서 예약할 수 없습니다. -->
				<p id="msgSelectTime" class="noti noti03"><spring:message code='Cache.msg_mustEnterDate' /></p><!-- 일시를 먼저 입력해주시기 바랍니다. -->
				<p id="msgRecommand1" class="noti noti03">
					<spring:message code='Cache.msg_cannotReserveRes' /><br /><!-- 선택하신 시간에 예약을 할 수 없습니다. -->
					<spring:message code='Cache.msg_recommendResBelow' /><!-- 아래 등록가능한 자원 및 시간을 추천합니다. -->
				</p>
				<div id="msgRecommand2" class="notiTxt">
					<p id="recReources"></p>
					<p><span><spring:message code='Cache.lbl_schedule_bestTime' /> </span><span id="recCloseTimes"></span></p><!-- 가장 가까운 추천 시간 -->
					<p><span><spring:message code='Cache.lbl_schedule_otherSuggestedTime' /></span><span id="recOtherTimes"></span></p><!-- 다른 추천시간 -->
				</div>
				<p id="recLastMsg" class="msg" style="display: none">
					<spring:message code='Cache.msg_YouCanCheckResAll' /><!-- 전체 자원 및 시간을 확인 해 보시겠습니까? --> <a onclick="scheduleUser.openResourceOnlyView();"><spring:message code='Cache.lbl_resource_check' /></a><!-- 자원확인 -->
				</p>
			</div>
		</div>
		<div class="bottom">
			<a onclick="scheduleUser.goDetailWritePage();" class="btnTypeDefault btnBlueBoder"><spring:message code='Cache.btn_WriteDetail' /></a>
			<a id="scheduleRegistBtn" onclick="scheduleUser.setOne('S');" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_register' /></a><!-- 상세등록 --><!-- 등록 -->
		</div>
	</div>
	<!-- 종일 버튼 클릭시 저장 -->
	<input type="hidden" id="hidStartDate">
	<input type="hidden" id="hidStartTime">
	<input type="hidden" id="hidStartHour">
	<input type="hidden" id="hidStartMinute">
	<input type="hidden" id="hidEndDate">
	<input type="hidden" id="hidEndTime">
	<input type="hidden" id="hidEndHour">
	<input type="hidden" id="hidEndMinute">
</aside>

