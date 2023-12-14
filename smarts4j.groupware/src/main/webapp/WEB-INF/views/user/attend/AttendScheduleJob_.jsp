<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
.AXGrid .AXgridScrollBody .AXGridBody .gridBodyTable tbody tr.hover {
	background: #f5f5f5;
}
</style>

<div class='cRConTop titType'>
	<h2 class="title"><spring:message code='Cache.lbl_n_att_worksch'/><spring:message code='Cache.lbl_Setting'/></h2>					
</div>
<div class='cRContBottom mScrollVH'>
	<div class="boardAllCont">
		<ul id="topButton" class="schSelect clearFloat">
			<li id="liDay"><a onclick="clickTopButton('D');"><spring:message code='Cache.lbl_Daily' /></a></li><!-- 일간 -->
			<li id="liWeek" class="selected"><a onclick="clickTopButton('W');" ><spring:message code='Cache.lbl_Weekly' /></a></li><!-- 주간 -->
			<li id="liMonth"><a onclick="clickTopButton('M');" ><spring:message code='Cache.lbl_Monthly' /></a></li><!-- 월간 -->
			<li id="liList"><a onclick="clickTopButton('List');" ><spring:message code='Cache.lbl_List_View' /></a></li><!-- 목록보기 -->
		</ul>
	    <div class="pagingType02">
	        <a class="pre" onclick="clickTopButton('PREV');"></a><a class="next" onclick="clickTopButton('NEXT');"></a><a onclick="resourceUser.goCurrent();" class="btnTypeDefault"><spring:message code='Cache.lbl_Todays' /></a><!-- 오늘 -->
	    </div>
		<div class="boradTopCont">
			<div class="selectCalView">
				<div id="searchDateCon" class="dateSel type02"></div>
			</div>
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv"> 
				<select class="selectType02" id="deptList">
				</select>
				<a href="#" class="btnTypeDefault" id="btnSearch"><spring:message code='Cache.lbl_search'/></a>
				<a href="#" class="btnTypeDefault btnTypeBg" id="btnAdd"><spring:message code='Cache.btn_att_806_s_1'/></a>
				<a href="#" class="btnTypeDefault" id="btnScheduleJob"><spring:message code='Cache.lbl_n_att_worksch'/><spring:message code='Cache.lbl_Creation'/></a> <!-- 근무일정생성 -->
				<a href="#" class="btnTypeDefault" id="btnSearch"><spring:message code='Cache.lbl_n_att_worksch'/><spring:message code='Cache.lbl_Copy'/></a> <!-- 근무일정복사 -->
				<a href="#" class="btnTypeDefault" id="btnDelete"><spring:message code='Cache.lbl_n_att_worksch'/><spring:message code='Cache.lbl_delete'/></a> <!-- 근무일정 삭제 -->
			</div>
			<div class="buttonStyleBoxRight">
				<!-- 엑셀저장 -->
				<a class="btnTypeDefault btnExcel" id="btnExcelDown"><spring:message code="Cache.btn_ExcelDownload"/></a>
				<button href="#" class="btnRefresh" type="button" id="btnRefresh"></button>
				<select class="selectType02 listCount" id="listCntSel">
					<option>10</option>
					<option>15</option>
					<option>20</option>
					<option>30</option>
					<option>50</option>
				</select>
			</div>
		</div>
		<div class="boradTopCont1">
			<div class='buttonStyleBoxRight'>
				<span class='sch_' style='width:40px;height:13px;padding:2px 2px 2px 2px;text-align:center;background-color:#ffcc00'>9 <spring:message code='Cache.lbl_Hour'/></span>&nbsp;	<!-- 시 -->
				<span class='sch_' style='width:40px;height:13px;padding:2px 2px 2px 2px;text-align:center;background-color:#ff6666'>8 <spring:message code='Cache.lbl_Hour'/></span>&nbsp;	<!-- 시 -->
				<span class='sch_' style='width:40px;height:13px;padding:2px 2px 2px 2px;text-align:center;background-color:#66cccc'><spring:message code='Cache.lbl_Shortening'/></span>&nbsp;	<!-- 단축 -->
				<span class='sch_' style='width:40px;height:13px;padding:2px 2px 2px 2px;text-align:center;background-color:#9b72b0'><spring:message code='Cache.lbl_night'/></span>&nbsp;	<!-- 야간 -->
				<span class='sch_' style='width:40px;height:13px;padding:2px 2px 2px 2px;text-align:center;background-color:#d2d5e8'>9 <spring:message code='Cache.lbl_Hour'/></span>&nbsp;	<!-- 시 -->
				<span class='sch_' style='width:40px;height:13px;padding:2px 2px 2px 2px;text-align:center;background-color:#004bc7'>9 <spring:message code='Cache.lbl_Hour'/></span>&nbsp;	<!-- 시 -->
			</div>
		</div>
			<div id="DayCalendar" class="resDayListCont" style="display: none">
				<div class="resDayListCont" id="DayCalendar">
					<div class="reserTblContent reserTblTit">
						<div class="chkStyle04">
							<input id="chkWorkTimeDay" onchange="resourceUser.changeWorkTime(this);" type="checkbox"><label for="chkWorkTimeDay"><span></span><spring:message code='Cache.lbl_BusinessTime'/></label><!-- 업무시간 -->
						</div>
						<div class="reserTblView ">
							<table class=" reserTbl" id="headerTimeList"><tbody><tr class="ui-selectable"><th colspan="2">00</th><th colspan="2">01</th><th colspan="2">02</th><th colspan="2">03</th><th colspan="2">04</th><th colspan="2">05</th><th colspan="2">06</th><th colspan="2">07</th><th colspan="2">08</th><th colspan="2">09</th><th colspan="2">10</th><th colspan="2">11</th><th colspan="2">12</th><th colspan="2">13</th><th colspan="2">14</th><th colspan="2">15</th><th colspan="2">16</th><th colspan="2">17</th><th colspan="2">18</th><th colspan="2">19</th><th colspan="2">20</th><th colspan="2">21</th><th colspan="2">22</th><th colspan="2">23</th></tr></tbody></table>
						</div>
					</div>
					<div class="reserTblContent reserTblCont" id="bodyResourceDay">
						<div>
							<p title="<spring:message code='Cache.lbl_SeminarRoom' />" id="header_84" style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; "><spring:message code='Cache.lbl_SeminarRoom' /></p> <!-- 세미나실 -->
							<p title="101<spring:message code='Cache.ACC_lbl_aNo' />(4<spring:message code='Cache.lbl_Person' />)" id="header_85" style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; ">101<spring:message code='Cache.ACC_lbl_aNo' />(4<spring:message code='Cache.lbl_Person' />)</p> <!-- 101호(4인) -->
							<p title="102<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)" id="header_86" style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; ">102<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)</p> <!-- 102호(8인) -->
							<p title="301<spring:message code='Cache.ACC_lbl_aNo' />(6<spring:message code='Cache.lbl_Person' />)" id="header_6985" style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; ">301<spring:message code='Cache.ACC_lbl_aNo' />(6<spring:message code='Cache.lbl_Person' />)</p> <!-- 301호(6인) -->
							<p title="302<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)" id="header_6986" style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; ">302<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)</p> <!-- 302호(8인) -->
							<p title="<spring:message code='Cache.lbl_SeminarRoom' />(56<spring:message code='Cache.lbl_Person' />)" id="header_6987" style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; "><spring:message code='Cache.lbl_SeminarRoom' />(56<spring:message code='Cache.lbl_Person' />)</p> <!-- 세미나실(56인) -->
						</div>
						<div class="reserTblView">
							<table class=" reserTbl">
								<tbody>
									<tr class="ui-selectable" foldername="<spring:message code='Cache.lbl_SeminarRoom' />" resourceid="84"> <!-- 세미나실 -->
										<td class="ui-selectee" type="none" time="00:00"><div></div></td>
										<td class="ui-selectee" type="none" time="00:30"><div></div></td>
										<td class="ui-selectee" type="none" time="01:00"><div></div></td>
										<td class="ui-selectee" type="none" time="01:30"><div></div></td>
										<td class="ui-selectee" type="none" time="02:00"><div></div></td>
										<td class="ui-selectee" type="none" time="02:30"><div></div></td>
										<td class="ui-selectee" type="none" time="03:00"><div></div></td>
										<td class="ui-selectee" type="none" time="03:30"><div></div></td>
										<td class="ui-selectee" type="none" time="04:00"><div></div></td>
										<td class="ui-selectee" type="none" time="04:30"><div></div></td>
										<td class="ui-selectee" type="none" time="05:00"><div></div></td>
										<td class="ui-selectee" type="none" time="05:30"><div></div></td>
										<td class="ui-selectee" type="none" time="06:00"><div></div></td>
										<td class="ui-selectee" type="none" time="06:30"><div></div></td>
										<td class="ui-selectee" type="none" time="07:00"><div></div></td>
										<td class="ui-selectee" type="none" time="07:30"><div></div></td>
										<td class="ui-selectee" type="none" time="08:00"><div></div></td>
										<td class="ui-selectee" type="none" time="08:30"><div></div></td>
										<td class="ui-selectee" type="none" time="09:00"><div></div></td>
										<td class="ui-selectee" type="none" time="09:30"><div></div></td>
										<td class="ui-selectee" type="none" time="10:00"><div></div></td>
										<td class="ui-selectee" type="none" time="10:30"><div></div></td>
										<td class="ui-selectee" type="none" time="11:00"><div></div></td>
										<td class="ui-selectee" type="none" time="11:30"><div></div></td>
										<td class="ui-selectee" type="none" time="12:00"><div></div></td>
										<td class="ui-selectee" type="none" time="12:30"><div></div></td>
										<td class="ui-selectee" type="none" time="13:00"><div></div></td>
										<td class="ui-selectee" type="none" time="13:30"><div></div></td>
										<td class="ui-selectee" type="none" time="14:00"><div></div></td>
										<td class="ui-selectee" type="none" time="14:30"><div></div></td>
										<td class="ui-selectee" type="none" time="15:00"><div></div></td>
										<td class="ui-selectee" type="none" time="15:30"><div></div></td>
										<td class="ui-selectee" type="none" time="16:00"><div></div></td>
										<td class="ui-selectee" type="none" time="16:30"><div></div></td>
										<td class="ui-selectee" type="none" time="17:00"><div></div></td>
										<td class="ui-selectee" type="none" time="17:30"><div></div></td>
										<td class="ui-selectee" type="none" time="18:00"><div></div></td>
										<td class="ui-selectee" type="none" time="18:30"><div></div></td>
										<td class="ui-selectee" type="none" time="19:00"><div></div></td>
										<td class="ui-selectee" type="none" time="19:30"><div></div></td>
										<td class="ui-selectee" type="none" time="20:00"><div></div></td>
										<td class="ui-selectee" type="none" time="20:30"><div></div></td>
										<td class="ui-selectee" type="none" time="21:00"><div></div></td>
										<td class="ui-selectee" type="none" time="21:30"><div></div></td>
										<td class="ui-selectee" type="none" time="22:00"><div></div></td>
										<td class="ui-selectee" type="none" time="22:30"><div></div></td>
										<td class="ui-selectee" type="none" time="23:00"><div></div></td>
										<td class="ui-selectee" type="none" time="23:30"><div></div></td>
									</tr>
									<tr class="ui-selectable" foldername="101<spring:message code='Cache.ACC_lbl_aNo' />(4<spring:message code='Cache.lbl_Person' />)" resourceid="85"> <!-- 101호(4인) -->
										<td class="ui-selectee" type="none" time="00:00"><div></div></td>
										<td class="ui-selectee" type="none" time="00:30"><div></div></td>
										<td class="ui-selectee" type="none" time="01:00"><div></div></td>
										<td class="ui-selectee" type="none" time="01:30"><div></div></td>
										<td class="ui-selectee" type="none" time="02:00"><div></div></td>
										<td class="ui-selectee" type="none" time="02:30"><div></div></td>
										<td class="ui-selectee" type="none" time="03:00"><div></div></td>
										<td class="ui-selectee" type="none" time="03:30"><div></div></td>
										<td class="ui-selectee" type="none" time="04:00"><div></div></td>
										<td class="ui-selectee" type="none" time="04:30"><div></div></td>
										<td class="ui-selectee" type="none" time="05:00"><div></div></td>
										<td class="ui-selectee" type="none" time="05:30"><div></div></td>
										<td class="ui-selectee" type="none" time="06:00"><div></div></td>
										<td class="ui-selectee" type="none" time="06:30"><div></div></td>
										<td class="ui-selectee" type="none" time="07:00"><div></div></td>
										<td class="ui-selectee" type="none" time="07:30"><div></div></td>
										<td class="ui-selectee" type="none" time="08:00"><div></div></td>
										<td class="ui-selectee" type="none" time="08:30"><div></div></td>
										<td class="ui-selectee" type="none" time="09:00"><div></div></td>
										<td class="ui-selectee" type="none" time="09:30"><div></div></td>
										<td class="ui-selectee" type="none" time="10:00"><div></div></td>
										<td class="ui-selectee" type="none" time="10:30"><div></div></td>
										<td class="ui-selectee" type="none" time="11:00"><div></div></td>
										<td class="ui-selectee" type="none" time="11:30"><div></div></td>
										<td class="ui-selectee" type="none" time="12:00"><div></div></td>
										<td class="ui-selectee" type="none" time="12:30"><div></div></td>
										<td class="ui-selectee" type="none" time="13:00"><div></div></td>
										<td class="ui-selectee" type="none" time="13:30"><div></div></td>
										<td class="ui-selectee" type="none" time="14:00"><div></div></td>
										<td class="ui-selectee" type="none" time="14:30"><div></div></td>
										<td class="ui-selectee" type="none" time="15:00"><div></div></td>
										<td class="ui-selectee" type="none" time="15:30"><div></div></td>
										<td class="ui-selectee" type="none" time="16:00"><div></div></td>
										<td class="ui-selectee" type="none" time="16:30"><div></div></td>
										<td class="ui-selectee" type="none" time="17:00"><div></div></td>
										<td class="ui-selectee" type="none" time="17:30"><div></div></td>
										<td class="ui-selectee" type="none" time="18:00"><div></div></td>
										<td class="ui-selectee" type="none" time="18:30"><div></div></td>
										<td class="ui-selectee" type="none" time="19:00"><div></div></td>
										<td class="ui-selectee" type="none" time="19:30"><div></div></td>
										<td class="ui-selectee" type="none" time="20:00"><div></div></td>
										<td class="ui-selectee" type="none" time="20:30"><div></div></td>
										<td class="ui-selectee" type="none" time="21:00"><div></div></td>
										<td class="ui-selectee" type="none" time="21:30"><div></div></td>
										<td class="ui-selectee" type="none" time="22:00"><div></div></td>
										<td class="ui-selectee" type="none" time="22:30"><div></div></td>
										<td class="ui-selectee" type="none" time="23:00"><div></div></td>
										<td class="ui-selectee" type="none" time="23:30"><div></div></td>
									</tr>
									<tr class="ui-selectable" foldername="102<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)" resourceid="86"><!-- 102호(8인) -->
										<td class="ui-selectee" type="none" time="00:00"><div></div></td>
										<td class="ui-selectee" type="none" time="00:30"><div></div></td>
										<td class="ui-selectee" type="none" time="01:00"><div></div></td>
										<td class="ui-selectee" type="none" time="01:30"><div></div></td>
										<td class="ui-selectee" type="none" time="02:00"><div></div></td>
										<td class="ui-selectee" type="none" time="02:30"><div></div></td>
										<td class="ui-selectee" type="none" time="03:00"><div></div></td>
										<td class="ui-selectee" type="none" time="03:30"><div></div></td>
										<td class="ui-selectee" type="none" time="04:00"><div></div></td>
										<td class="ui-selectee" type="none" time="04:30"><div></div></td>
										<td class="ui-selectee" type="none" time="05:00"><div></div></td>
										<td class="ui-selectee" type="none" time="05:30"><div></div></td>
										<td class="ui-selectee" type="none" time="06:00"><div></div></td>
										<td class="ui-selectee" type="none" time="06:30"><div></div></td>
										<td class="ui-selectee" type="none" time="07:00"><div></div></td>
										<td class="ui-selectee" type="none" time="07:30"><div></div></td>
										<td class="ui-selectee" type="none" time="08:00"><div></div></td>
										<td class="ui-selectee" type="none" time="08:30"><div></div></td>
										<td class="ui-selectee" type="none" time="09:00"><div></div></td>
										<td class="ui-selectee" type="none" time="09:30"><div></div></td>
										<td class="ui-selectee" type="none" time="10:00"><div></div></td>
										<td class="ui-selectee" type="none" time="10:30"><div></div></td>
										<td class="ui-selectee" type="none" time="11:00"><div></div></td>
										<td class="ui-selectee" type="none" time="11:30"><div></div></td>
										<td class="ui-selectee" type="none" time="12:00"><div></div></td>
										<td class="ui-selectee" type="none" time="12:30"><div></div></td>
										<td class="ui-selectee" type="none" time="13:00"><div></div></td>
										<td class="ui-selectee" type="none" time="13:30"><div></div></td>
										<td class="ui-selectee" type="none" time="14:00"><div></div></td>
										<td class="ui-selectee" type="none" time="14:30"><div></div></td>
										<td class="ui-selectee" type="none" time="15:00"><div></div></td>
										<td class="ui-selectee" type="none" time="15:30"><div></div></td>
										<td class="ui-selectee" type="none" time="16:00"><div></div></td>
										<td class="ui-selectee" type="none" time="16:30"><div></div></td>
										<td class="ui-selectee" type="none" time="17:00"><div></div></td>
										<td class="ui-selectee" type="none" time="17:30"><div></div></td>
										<td class="ui-selectee" type="none" time="18:00"><div></div></td>
										<td class="ui-selectee" type="none" time="18:30"><div></div></td>
										<td class="ui-selectee" type="none" time="19:00"><div></div></td>
										<td class="ui-selectee" type="none" time="19:30"><div></div></td>
										<td class="ui-selectee" type="none" time="20:00"><div></div></td>
										<td class="ui-selectee" type="none" time="20:30"><div></div></td>
										<td class="ui-selectee" type="none" time="21:00"><div></div></td>
										<td class="ui-selectee" type="none" time="21:30"><div></div></td>
										<td class="ui-selectee" type="none" time="22:00"><div></div></td>
										<td class="ui-selectee" type="none" time="22:30"><div></div></td>
										<td class="ui-selectee" type="none" time="23:00"><div></div></td>
										<td class="ui-selectee" type="none" time="23:30"><div></div></td>
									</tr>
									<tr class="ui-selectable" foldername="301<spring:message code='Cache.ACC_lbl_aNo' />(6<spring:message code='Cache.lbl_Person' />)" resourceid="6985"> <!-- 301호(6인) -->
										<td class="ui-selectee" type="none" time="00:00"><div></div></td>
										<td class="ui-selectee" type="none" time="00:30"><div></div></td>
										<td class="ui-selectee" type="none" time="01:00"><div></div></td>
										<td class="ui-selectee" type="none" time="01:30"><div></div></td>
										<td class="ui-selectee" type="none" time="02:00"><div></div></td>
										<td class="ui-selectee" type="none" time="02:30"><div></div></td>
										<td class="ui-selectee" type="none" time="03:00"><div></div></td>
										<td class="ui-selectee" type="none" time="03:30"><div></div></td>
										<td class="ui-selectee" type="none" time="04:00"><div></div></td>
										<td class="ui-selectee" type="none" time="04:30"><div></div></td>
										<td class="ui-selectee" type="none" time="05:00"><div></div></td>
										<td class="ui-selectee" type="none" time="05:30"><div></div></td>
										<td class="ui-selectee" type="none" time="06:00"><div></div></td>
										<td class="ui-selectee" type="none" time="06:30"><div></div></td>
										<td class="ui-selectee" type="none" time="07:00"><div></div></td>
										<td class="ui-selectee" type="none" time="07:30"><div></div></td>
										<td class="ui-selectee" type="none" time="08:00"><div></div></td>
										<td class="ui-selectee" type="none" time="08:30"><div></div></td>
										<td class="ui-selectee" type="none" time="09:00"><div></div></td>
										<td class="ui-selectee" type="none" time="09:30"><div></div></td>
										<td class="ui-selectee" type="none" time="10:00"><div></div></td>
										<td class="ui-selectee" type="none" time="10:30"><div></div></td>
										<td class="ui-selectee" type="none" time="11:00"><div></div></td>
										<td class="ui-selectee" type="none" time="11:30"><div></div></td>
										<td class="ui-selectee" type="none" time="12:00"><div></div></td>
										<td class="ui-selectee" type="none" time="12:30"><div></div></td>
										<td class="ui-selectee" type="none" time="13:00"><div></div></td>
										<td class="ui-selectee" type="none" time="13:30"><div></div></td>
										<td class="ui-selectee" type="none" time="14:00"><div></div></td>
										<td class="ui-selectee" type="none" time="14:30"><div></div></td>
										<td class="ui-selectee" type="none" time="15:00"><div></div></td>
										<td class="ui-selectee" type="none" time="15:30"><div></div></td>
										<td class="ui-selectee" type="none" time="16:00"><div></div></td>
										<td class="ui-selectee" type="none" time="16:30"><div></div></td>
										<td class="ui-selectee" type="none" time="17:00"><div></div></td>
										<td class="ui-selectee" type="none" time="17:30"><div></div></td>
										<td class="ui-selectee" type="none" time="18:00"><div></div></td>
										<td class="ui-selectee" type="none" time="18:30"><div></div></td>
										<td class="ui-selectee" type="none" time="19:00"><div></div></td>
										<td class="ui-selectee" type="none" time="19:30"><div></div></td>
										<td class="ui-selectee" type="none" time="20:00"><div></div></td>
										<td class="ui-selectee" type="none" time="20:30"><div></div></td>
										<td class="ui-selectee" type="none" time="21:00"><div></div></td>
										<td class="ui-selectee" type="none" time="21:30"><div></div></td>
										<td class="ui-selectee" type="none" time="22:00"><div></div></td>
										<td class="ui-selectee" type="none" time="22:30"><div></div></td>
										<td class="ui-selectee" type="none" time="23:00"><div></div></td>
										<td class="ui-selectee" type="none" time="23:30"><div></div></td>
									</tr>
									<tr class="ui-selectable" foldername="302<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)" resourceid="6986"> <!-- 302호(8인) -->
										<td class="ui-selectee" type="none" time="00:00"><div></div></td>
										<td class="ui-selectee" type="none" time="00:30"><div></div></td>
										<td class="ui-selectee" type="none" time="01:00"><div></div></td>
										<td class="ui-selectee" type="none" time="01:30"><div></div></td>
										<td class="ui-selectee" type="none" time="02:00"><div></div></td>
										<td class="ui-selectee" type="none" time="02:30"><div></div></td>
										<td class="ui-selectee" type="none" time="03:00"><div></div></td>
										<td class="ui-selectee" type="none" time="03:30"><div></div></td>
										<td class="ui-selectee" type="none" time="04:00"><div></div></td>
										<td class="ui-selectee" type="none" time="04:30"><div></div></td>
										<td class="ui-selectee" type="none" time="05:00"><div></div></td>
										<td class="ui-selectee" type="none" time="05:30"><div></div></td>
										<td class="ui-selectee" type="none" time="06:00"><div></div></td>
										<td class="ui-selectee" type="none" time="06:30"><div></div></td>
										<td class="ui-selectee" type="none" time="07:00"><div></div></td>
										<td class="ui-selectee" type="none" time="07:30"><div></div></td>
										<td class="ui-selectee" type="none" time="08:00"><div></div></td>
										<td class="ui-selectee" type="none" time="08:30"><div></div></td>
										<td class="ui-selectee" type="none" time="09:00"><div></div></td>
										<td class="ui-selectee" type="none" time="09:30"><div></div></td>
										<td class="ui-selectee" type="none" time="10:00"><div></div></td>
										<td class="ui-selectee" type="none" time="10:30"><div></div></td>
										<td class="ui-selectee" type="none" time="11:00"><div></div></td>
										<td class="ui-selectee" type="none" time="11:30"><div></div></td>
										<td class="ui-selectee" type="none" time="12:00"><div></div></td>
										<td class="ui-selectee" type="none" time="12:30"><div></div></td>
										<td class="ui-selectee" type="none" time="13:00"><div></div></td>
										<td class="ui-selectee" type="none" time="13:30"><div></div></td>
										<td class="ui-selectee" type="none" time="14:00"><div></div></td>
										<td class="ui-selectee" type="none" time="14:30"><div></div></td>
										<td class="ui-selectee" type="none" time="15:00"><div></div></td>
										<td class="ui-selectee" type="none" time="15:30"><div></div></td>
										<td class="ui-selectee" type="none" time="16:00"><div></div></td>
										<td class="ui-selectee" type="none" time="16:30"><div></div></td>
										<td class="ui-selectee" type="none" time="17:00"><div></div></td>
										<td class="ui-selectee" type="none" time="17:30"><div></div></td>
										<td class="ui-selectee" type="none" time="18:00"><div></div></td>
										<td class="ui-selectee" type="none" time="18:30"><div></div></td>
										<td class="ui-selectee" type="none" time="19:00"><div></div></td>
										<td class="ui-selectee" type="none" time="19:30"><div></div></td>
										<td class="ui-selectee" type="none" time="20:00"><div></div></td>
										<td class="ui-selectee" type="none" time="20:30"><div></div></td>
										<td class="ui-selectee" type="none" time="21:00"><div></div></td>
										<td class="ui-selectee" type="none" time="21:30"><div></div></td>
										<td class="ui-selectee" type="none" time="22:00"><div></div></td>
										<td class="ui-selectee" type="none" time="22:30"><div></div></td>
										<td class="ui-selectee" type="none" time="23:00"><div></div></td>
										<td class="ui-selectee" type="none" time="23:30"><div></div></td>
									</tr>
									<tr class="ui-selectable" foldername="<spring:message code='Cache.lbl_SeminarRoom' />(56<spring:message code='Cache.lbl_Person' />)" resourceid="6987">	<!-- 세미나실(56인) -->
										<td class="ui-selectee" type="none" time="00:00"><div></div></td>
										<td class="ui-selectee" type="none" time="00:30"><div></div></td>
										<td class="ui-selectee" type="none" time="01:00"><div></div></td>
										<td class="ui-selectee" type="none" time="01:30"><div></div></td>
										<td class="ui-selectee" type="none" time="02:00"><div></div></td>
										<td class="ui-selectee" type="none" time="02:30"><div></div></td>
										<td class="ui-selectee" type="none" time="03:00"><div></div></td>
										<td class="ui-selectee" type="none" time="03:30"><div></div></td>
										<td class="ui-selectee" type="none" time="04:00"><div></div></td>
										<td class="ui-selectee" type="none" time="04:30"><div></div></td>
										<td class="ui-selectee" type="none" time="05:00"><div></div></td>
										<td class="ui-selectee" type="none" time="05:30"><div></div></td>
										<td class="ui-selectee" type="none" time="06:00"><div></div></td>
										<td class="ui-selectee" type="none" time="06:30"><div></div></td>
										<td class="ui-selectee" type="none" time="07:00"><div></div></td>
										<td class="ui-selectee" type="none" time="07:30"><div></div></td>
										<td class="ui-selectee" type="none" time="08:00"><div></div></td>
										<td class="ui-selectee" type="none" time="08:30"><div></div></td>
										<td class="ui-selectee" type="none" time="09:00"><div></div></td>
										<td class="ui-selectee" type="none" time="09:30"><div></div></td>
										<td class="ui-selectee" type="none" time="10:00"><div></div></td>
										<td class="ui-selectee" type="none" time="10:30"><div></div></td>
										<td class="ui-selectee" type="none" time="11:00"><div></div></td>
										<td class="ui-selectee" type="none" time="11:30"><div></div></td>
										<td class="ui-selectee" type="none" time="12:00"><div></div></td>
										<td class="ui-selectee" type="none" time="12:30"><div></div></td>
										<td class="ui-selectee" type="none" time="13:00"><div></div></td>
										<td class="ui-selectee" type="none" time="13:30"><div></div></td>
										<td class="ui-selectee" type="none" time="14:00"><div></div></td>
										<td class="ui-selectee" type="none" time="14:30"><div></div></td>
										<td class="ui-selectee" type="none" time="15:00"><div></div></td>
										<td class="ui-selectee" type="none" time="15:30"><div></div></td>
										<td class="ui-selectee" type="none" time="16:00"><div></div></td>
										<td class="ui-selectee" type="none" time="16:30"><div></div></td>
										<td class="ui-selectee" type="none" time="17:00"><div></div></td>
										<td class="ui-selectee" type="none" time="17:30"><div></div></td>
										<td class="ui-selectee" type="none" time="18:00"><div></div></td>
										<td class="ui-selectee" type="none" time="18:30"><div></div></td>
										<td class="ui-selectee" type="none" time="19:00"><div></div></td>
										<td class="ui-selectee" type="none" time="19:30"><div></div></td>
										<td class="ui-selectee" type="none" time="20:00"><div></div></td>
										<td class="ui-selectee" type="none" time="20:30"><div></div></td>
										<td class="ui-selectee" type="none" time="21:00"><div></div></td>
										<td class="ui-selectee" type="none" time="21:30"><div></div></td>
										<td class="ui-selectee" type="none" time="22:00"><div></div></td>
										<td class="ui-selectee" type="none" time="22:30"><div></div></td>
										<td class="ui-selectee" type="none" time="23:00"><div></div></td>
										<td class="ui-selectee" type="none" time="23:30"><div></div></td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
			
			<div id="WeekCalendar" class="resDayListCont reserTblWeekly" style="display: none1">
				<div class="reserTblContent reserTblTit">
					<div class="chkStyle04">
						<span></span>
					</div>
					<div class="reserTblView ">
						<table class=" reserTbl">
							<colgroup>
								<col width="16.6%">
								<col width="16.6%">
								<col width="16.6%">
								<col width="16.6%">
								<col width="16.6%">
								<col width="16.6%">
								<col width="16.6%">
								<col width="16.6%">
							</colgroup>
							<tbody id="headerDayList">
								<tr class="ui-selectable">
									<th></th>
									<th>1&nbsp;<spring:message code='Cache.lbl_sch_sun' /><span class="inDate" name="dayInfo" value="2020-03-01"></span></th> <!-- 일 -->
									<th class="selected">2&nbsp;<spring:message code='Cache.lbl_sch_mon' /><span class="inDate" name="dayInfo" value="2020-03-02"></span></th> <!-- 월 -->
									<th>3&nbsp;<spring:message code='Cache.lbl_sch_tue' /><span class="inDate" name="dayInfo" value="2020-03-03"></span></th> <!-- 화 -->
									<th>4&nbsp;<spring:message code='Cache.lbl_sch_wed' /><span class="inDate" name="dayInfo" value="2020-03-04"></span></th> <!-- 수 -->
									<th>5&nbsp;<spring:message code='Cache.lbl_sch_thu' /><span class="inDate" name="dayInfo" value="2020-03-05"></span></th> <!-- 목 -->
									<th>6&nbsp;<spring:message code='Cache.lbl_sch_fri' /><span class="inDate" name="dayInfo" value="2020-03-06"></span></th> <!-- 금 -->
									<th>7&nbsp;<spring:message code='Cache.lbl_sch_sat' /><span class="inDate" name="dayInfo" value="2020-03-07"></span></th> <!-- 토-->
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<div class="reserTblContent reserTblCont" id="bodyResourceWeek">
					<div>
						<p title="<spring:message code='Cache.lbl_SeminarRoom' />" id="header_84" style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; "><spring:message code='Cache.lbl_SeminarRoom' /></p> <!-- 세미나실 -->
						<p title="101<spring:message code='Cache.ACC_lbl_aNo' />(4<spring:message code='Cache.lbl_Person' />)" id="header_85" style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; ">101<spring:message code='Cache.ACC_lbl_aNo' />(4<spring:message code='Cache.lbl_Person' />)</p> <!-- 101호(4인) -->
						<p title="102<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)" id="header_86" style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; ">102<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)</p> <!-- 102호(8인) -->
						<p title="301<spring:message code='Cache.ACC_lbl_aNo' />(6<spring:message code='Cache.lbl_Person' />)" id="header_6985" style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; ">301<spring:message code='Cache.ACC_lbl_aNo' />(6<spring:message code='Cache.lbl_Person' />)</p> <!-- 301호(6인) -->
						<p title="302<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)" id="header_6986" style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; ">302<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)</p> <!-- 302호(8인) -->
						<p title="<spring:message code='Cache.lbl_SeminarRoom' />(56<spring:message code='Cache.lbl_Person' />)" id="header_6987" style="overflow:hidden; text-overflow:ellipsis; white-space:nowrap; "><spring:message code='Cache.lbl_SeminarRoom' />(56<spring:message code='Cache.lbl_Person' />)</p> <!-- 세미나실(56인) -->
					</div>
					<div class="reserTblView">
						<table class=" reserTbl">
							<colgroup><col width="16.6%">
								<col width="16.6%"><col width="16.6%"><col width="16.6%"><col width="16.6%"><col width="16.6%"><col width="16.6%"><col width="16.6%"><col width="16.6%">
								<col width="16.6%"><col width="16.6%"><col width="16.6%"><col width="16.6%"><col width="16.6%">
							</colgroup>
							<tbody>
								<tr class="ui-selectable" foldername="<spring:message code='Cache.lbl_SeminarRoom' />" resourceid="84"> <!-- 세미나실 -->
									<td schday="2020/03/01"><div class="ui-selectee" type="none" time="00:00"><span></span></div><div class="ui-selectee" type="none" time="02:00"><span></span></div><div class="ui-selectee" type="none" time="04:00"><span></span></div><div class="ui-selectee" type="none" time="06:00"><span></span></div><div class="ui-selectee" type="none" time="08:00"><span></span></div><div class="ui-selectee" type="none" time="10:00"><span></span></div></td>
									<td schday="2020/03/02"><div class="ui-selectee" type="none" time="00:00"><span></span></div><div class="ui-selectee" type="none" time="02:00"><span></span></div><div class="ui-selectee" type="none" time="04:00"><span></span></div><div class="ui-selectee" type="none" time="06:00"><span></span></div><div class="ui-selectee" type="none" time="08:00"><span></span></div><div class="ui-selectee" type="none" time="10:00"><span></span></div></td>
									<td schday="2020/03/03"><div class="ui-selectee" type="none" time="00:00"><span></span></div><div class="ui-selectee" type="none" time="02:00"><span></span></div><div class="ui-selectee" type="none" time="04:00"><span></span></div><div class="ui-selectee" type="none" time="06:00"><span></span></div><div class="ui-selectee" type="none" time="08:00"><span></span></div><div class="ui-selectee" type="none" time="10:00"><span></span></div></td>
									<td schday="2020/03/04"><div class="ui-selectee" type="none" time="00:00"><span></span></div><div class="ui-selectee" type="none" time="02:00"><span></span></div><div class="ui-selectee" type="none" time="04:00"><span></span></div><div class="ui-selectee" type="none" time="06:00"><span></span></div><div class="ui-selectee" type="none" time="08:00"><span></span></div><div class="ui-selectee" type="none" time="10:00"><span></span></div></td>
									<td schday="2020/03/05"><div class="ui-selectee" type="none" time="00:00"><span></span></div><div class="ui-selectee" type="none" time="02:00"><span></span></div><div class="ui-selectee" type="none" time="04:00"><span></span></div><div class="ui-selectee" type="none" time="06:00"><span></span></div><div class="ui-selectee" type="none" time="08:00"><span></span></div><div class="ui-selectee" type="none" time="10:00"><span></span></div></td>
									<td schday="2020/03/06"><div class="ui-selectee" type="none" time="00:00"><span></span></div><div class="ui-selectee" type="none" time="02:00"><span></span></div><div class="ui-selectee" type="none" time="04:00"><span></span></div><div class="ui-selectee" type="none" time="06:00"><span></span></div><div class="ui-selectee" type="none" time="08:00"><span></span></div><div class="ui-selectee" type="none" time="10:00"><span></span></div></td>
									<td schday="2020/03/07"><div class="ui-selectee" type="none" time="00:00"><span></span></div><div class="ui-selectee" type="none" time="02:00"><span></span></div><div class="ui-selectee" type="none" time="04:00"><span></span></div><div class="ui-selectee" type="none" time="06:00"><span></span></div><div class="ui-selectee" type="none" time="08:00"><span></span></div><div class="ui-selectee" type="none" time="10:00"><span></span></div></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			
			
			
			
			<div id="MonthCalendar" style="display:none">
				<div class="calMonHeader">
				<table class="calMonTbl">
					<tbody>
					<tr>
						<th class="sun"><spring:message code='Cache.lbl_sch_sun' /></th><th><spring:message code='Cache.lbl_sch_mon' /></th><th><spring:message code='Cache.lbl_sch_tue' /></th><th><spring:message code='Cache.lbl_sch_wed' /></th><th><spring:message code='Cache.lbl_sch_thu' /></th><th><spring:message code='Cache.lbl_sch_fri' /></th><th><spring:message code='Cache.lbl_sch_sat' /></th> <!-- 일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th>토 -->
					</tr>
					</tbody>
				</table>
				</div>
					<div class="calMonBody resMonth ui-selectable" style="position:relative;">
						<div class="calMonWeekRow" id="divWeekScheduleForMonth_20200301" week="0">
							<table class="calGrid">
							<tbody>
								<tr>
									<td class="ui-selectee" id="monthDate" schday="2020.03.01"></td><td class="ui-selectee" id="monthDate" schday="2020.03.02"></td><td class="ui-selectee" id="monthDate" schday="2020.03.03"></td><td class="ui-selectee" id="monthDate" schday="2020.03.04"></td><td class="ui-selectee" id="monthDate" schday="2020.03.05"></td><td class="ui-selectee" id="monthDate" schday="2020.03.06"></td><td class="ui-selectee" id="monthDate" schday="2020.03.07"></td>
								</tr>
							</tbody>
							</table>
							<table class="monShcList" id="tableWeekScheduleForMonth_20200301">
							<tbody>
								<tr>
									<td class="sun ui-selectee" schday="2020.03.01"><strong>1</strong><span class="day_info" name="dayInfo" value="2020-03-01"></span></td><td class="ui-selectee" schday="2020.03.02"><strong>2</strong><span class="day_info" name="dayInfo" value="2020-03-02"></span></td><td class="ui-selectee" schday="2020.03.03"><strong>3</strong><span class="day_info" name="dayInfo" value="2020-03-03"></span></td><td class="ui-selectee" schday="2020.03.04"><strong>4</strong><span class="day_info" name="dayInfo" value="2020-03-04"></span></td><td class="ui-selectee" schday="2020.03.05"><strong>5</strong><span class="day_info" name="dayInfo" value="2020-03-05"></span></td><td class="ui-selectee" schday="2020.03.06"><strong>6</strong><span class="day_info" name="dayInfo" value="2020-03-06"></span></td><td class="ui-selectee" schday="2020.03.07"><strong>7</strong><span class="day_info" name="dayInfo" value="2020-03-07"></span></td>
								</tr>
								<tr id="trAlldayBar_20200301_0" rowno="0">
									<td class="ui-droppable" id="tdAlldayBar_20200301_0_0" schday="2020.03.01" day="0">&nbsp;</td>
									<td class="ui-droppable" id="tdAlldayBar_20200301_0_1" schday="2020.03.02" day="1">
										<div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12271" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6669" dateid="12271" eventid="6846">
											<div><span class="time">14:00</span><span class="txt">302<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)</span></div> <!-- 302호(8인) -->
										</div>
									</td>
									<td class="ui-droppable" id="tdAlldayBar_20200301_0_2" schday="2020.03.03" day="2">
										<div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12283" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6693" dateid="12283" eventid="6872">
											<div><span class="time">09:00</span><span class="txt">302<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)</span></div> <!-- 302호(8인) -->
										</div>
									</td>
									<td class="ui-droppable" id="tdAlldayBar_20200301_0_3" schday="2020.03.04" day="3">
										<div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12290" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6699" dateid="12290" eventid="6878">
											<div><span class="time">13:00</span><span class="txt">302<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)</span></div> <!-- 302호(8인) -->
										</div>
									</td>
									<td class="ui-droppable" id="tdAlldayBar_20200301_0_4" schday="2020.03.05" day="4">
										<div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12041" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6626" dateid="12041" eventid="6801">
											<div><span class="time">15:00</span><span class="txt">102<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)</span></div> <!-- 102호(8인) -->
										</div>
									</td>
									<td class="ui-droppable" id="tdAlldayBar_20200301_0_5" schday="2020.03.06" day="5">
										<div class="shcDayText comp repeatW ui-draggable ui-draggable-handle" id="eventData_11377" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="Y" repeatid="6152" dateid="11377" eventid="6309">
											<div><span class="time">09:00</span><span class="txt">302<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)</span></div><div class="calToolTip"><spring:message code='Cache.lbl_schedule_repeatSch' /></div> <!-- 302호(8인) 반복일정 -->
										</div>
									</td>
									<td class="ui-droppable" id="tdAlldayBar_20200301_0_6" schday="2020.03.07" day="6">&nbsp;</td>
								</tr>
								<tr id="trAlldayBar_20200301_1" rowno="1">
									<td class="ui-droppable" id="tdAlldayBar_20200301_1_0" schday="2020.03.01" day="0">&nbsp;</td>
									<td class="ui-droppable" id="tdAlldayBar_20200301_1_1" schday="2020.03.02" day="1">&nbsp;</td>
									<td class="ui-droppable" id="tdAlldayBar_20200301_1_2" schday="2020.03.03" day="2">
										<div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12279" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6689" dateid="12279" eventid="6868">
										<div><span class="time">10:00</span><span class="txt">102<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)</span></div> <!-- 102호(8인) -->
										</div>
									</td>
									<td class="ui-droppable" id="tdAlldayBar_20200301_1_3" schday="2020.03.04" day="3">
										<div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12294" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6703" dateid="12294" eventid="6882">
										<div><span class="time">16:30</span><span class="txt">102<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)</span></div> <!-- 102호(8인) -->
										</div>
									</td>
									<td class="ui-droppable" id="tdAlldayBar_20200301_1_4" schday="2020.03.05" day="4">&nbsp;</td>
									<td class="ui-droppable" id="tdAlldayBar_20200301_1_5" schday="2020.03.06" day="5">
										<div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12321" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6721" dateid="12321" eventid="6902">
											<div><span class="time">10:30</span><span class="txt">302<spring:message code='Cache.ACC_lbl_aNo' />(8<spring:message code='Cache.lbl_Person' />)</span></div> <!-- 302호(8인) -->
										</div>
									</td>
									<td class="ui-droppable" id="tdAlldayBar_20200301_1_6" schday="2020.03.07" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200301_2" rowno="2"><td class="ui-droppable" id="tdAlldayBar_20200301_2_0" schday="2020.03.01" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200301_2_1" schday="2020.03.02" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200301_2_2" schday="2020.03.03" day="2"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12257" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6670" dateid="12257" eventid="6847"><div><span class="time">13:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200301_2_3" schday="2020.03.04" day="3">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200301_2_4" schday="2020.03.05" day="4">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200301_2_5" schday="2020.03.06" day="5"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12326" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6724" dateid="12326" eventid="6905"><div><span class="time">14:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200301_2_6" schday="2020.03.07" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200301_more" rowno=""><td class="ui-droppable" id="tdAlldayBar_20200301_more_0" schday="2020.03.01" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200301_more_1" schday="2020.03.02" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200301_more_2" schday="2020.03.03" day="2">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200301_more_3" schday="2020.03.04" day="3">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200301_more_4" schday="2020.03.05" day="4">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200301_more_5" schday="2020.03.06" day="5">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200301_more_6" schday="2020.03.07" day="6">&nbsp;</td></tr></tbody></table></div><div class="calMonWeekRow" id="divWeekScheduleForMonth_20200308" week="1"><table class="calGrid"><tbody><tr><td class="ui-selectee" id="monthDate" schday="2020.03.08"></td><td class="ui-selectee" id="monthDate" schday="2020.03.09"></td><td class="ui-selectee" id="monthDate" schday="2020.03.10"></td><td class="ui-selectee" id="monthDate" schday="2020.03.11"></td><td class="ui-selectee" id="monthDate" schday="2020.03.12"></td><td class="ui-selectee" id="monthDate" schday="2020.03.13"></td><td class="ui-selectee" id="monthDate" schday="2020.03.14"></td></tr></tbody></table><table class="monShcList" id="tableWeekScheduleForMonth_20200308"><tbody><tr><td class="sun ui-selectee" schday="2020.03.08"><strong>8</strong><span class="day_info" name="dayInfo" value="2020-03-08"></span></td><td class="ui-selectee" schday="2020.03.09"><strong>9</strong><span class="day_info" name="dayInfo" value="2020-03-09"></span></td><td class="ui-selectee" schday="2020.03.10"><strong>10</strong><span class="day_info" name="dayInfo" value="2020-03-10"></span></td><td class="ui-selectee" schday="2020.03.11"><strong>11</strong><span class="day_info" name="dayInfo" value="2020-03-11"></span></td><td class="ui-selectee" schday="2020.03.12"><strong>12</strong><span class="day_info" name="dayInfo" value="2020-03-12"></span></td><td class="ui-selectee" schday="2020.03.13"><strong>13</strong><span class="day_info" name="dayInfo" value="2020-03-13"></span></td><td class="ui-selectee" schday="2020.03.14"><strong>14</strong><span class="day_info" name="dayInfo" value="2020-03-14"></span></td></tr><tr id="trAlldayBar_20200308_0" rowno="0"><td class="ui-droppable" id="tdAlldayBar_20200308_0_0" schday="2020.03.08" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_0_1" schday="2020.03.09" day="1"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12330" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6728" dateid="12330" eventid="6909"><div><span class="time">10:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_0_2" schday="2020.03.10" day="2"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12351" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6736" dateid="12351" eventid="6917"><div><span class="time">09:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_0_3" schday="2020.03.11" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12368" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6761" dateid="12368" eventid="6943"><div><span class="time">14:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_0_4" schday="2020.03.12" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12363" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6987" isrepeat="N" repeatid="6756" dateid="12363" eventid="6938"><div><span class="time">09:00</span><span class="txt">세미나실(56인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_0_5" schday="2020.03.13" day="5"><div class="shcDayText comp repeatW ui-draggable ui-draggable-handle" id="eventData_11378" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="Y" repeatid="6152" dateid="11378" eventid="6309"><div><span class="time">09:00</span><span class="txt">302호(8인)</span></div><div class="calToolTip">반복일정</div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_0_6" schday="2020.03.14" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200308_1" rowno="1"><td class="ui-droppable" id="tdAlldayBar_20200308_1_0" schday="2020.03.08" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_1_1" schday="2020.03.09" day="1"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12341" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6738" dateid="12341" eventid="6919"><div><span class="time">14:50</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_1_2" schday="2020.03.10" day="2"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12355" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6987" isrepeat="N" repeatid="6749" dateid="12355" eventid="6931"><div><span class="time">09:00</span><span class="txt">세미나실(56인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_1_3" schday="2020.03.11" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12344" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6740" dateid="12344" eventid="6921"><div><span class="time">14:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_1_4" schday="2020.03.12" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12386" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6777" dateid="12386" eventid="6959"><div><span class="time">09:30</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_1_5" schday="2020.03.13" day="5"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12390" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6780" dateid="12390" eventid="6962"><div><span class="time">15:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_1_6" schday="2020.03.14" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200308_2" rowno="2"><td class="ui-droppable" id="tdAlldayBar_20200308_2_0" schday="2020.03.08" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_2_1" schday="2020.03.09" day="1"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12342" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6739" dateid="12342" eventid="6920"><div><span class="time">16:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_2_2" schday="2020.03.10" day="2"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12358" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="85" isrepeat="N" repeatid="6752" dateid="12358" eventid="6934"><div><span class="time">10:00</span><span class="txt">101호(4인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_2_3" schday="2020.03.11" day="3">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_2_4" schday="2020.03.12" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12381" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6772" dateid="12381" eventid="6954"><div><span class="time">11:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_2_5" schday="2020.03.13" day="5">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_2_6" schday="2020.03.14" day="6">&nbsp;</td></tr><tr class="daybar_off" id="trAlldayBar_20200308_3" style="display:none;" rowno="3"><td class="ui-droppable" id="tdAlldayBar_20200308_3_0" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_3_1" day="1"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12331" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6987" isrepeat="N" repeatid="6729" dateid="12331" eventid="6910"><div><span class="time">16:00</span><span class="txt">세미나실(56인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_3_2" day="2"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12360" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6753" dateid="12360" eventid="6935"><div><span class="time">13:30</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_3_3" day="3">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_3_4" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12387" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6778" dateid="12387" eventid="6960"><div><span class="time">14:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_3_5" day="5">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_3_6" day="6">&nbsp;</td></tr><tr class="daybar_off" id="trAlldayBar_20200308_4" style="display:none;" rowno="4"><td class="ui-droppable" id="tdAlldayBar_20200308_4_0" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_4_1" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_4_2" day="2">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_4_3" day="3">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_4_4" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12388" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6732" dateid="12388" eventid="6913"><div><span class="time">14:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_4_5" day="5">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_4_6" day="6">&nbsp;</td></tr><tr class="daybar_off" id="trAlldayBar_20200308_5" style="display:none;" rowno="5"><td class="ui-droppable" id="tdAlldayBar_20200308_5_0" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_5_1" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_5_2" day="2">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_5_3" day="3">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_5_4" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12389" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6779" dateid="12389" eventid="6961"><div><span class="time">17:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_5_5" day="5">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_5_6" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200308_more" rowno=""><td class="ui-droppable" id="tdAlldayBar_20200308_more_0" schday="2020.03.08" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_more_1" schday="2020.03.09" day="1"><div class="moreShcDayTextView"><a class="ui-draggable ui-draggable-handle" style="position: relative;" onclick="resourceUser.setMoreListPopup(this);">+1</a></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_more_2" schday="2020.03.10" day="2"><div class="moreShcDayTextView"><a class="ui-draggable ui-draggable-handle" style="position: relative;" onclick="resourceUser.setMoreListPopup(this);">+1</a></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_more_3" schday="2020.03.11" day="3">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_more_4" schday="2020.03.12" day="4"><div class="moreShcDayTextView"><a class="ui-draggable ui-draggable-handle" style="position: relative;" onclick="resourceUser.setMoreListPopup(this);">+3</a></div></td><td class="ui-droppable" id="tdAlldayBar_20200308_more_5" schday="2020.03.13" day="5">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200308_more_6" schday="2020.03.14" day="6">&nbsp;</td></tr></tbody></table></div><div class="calMonWeekRow" id="divWeekScheduleForMonth_20200315" week="2"><table class="calGrid"><tbody><tr><td class="ui-selectee" id="monthDate" schday="2020.03.15"></td><td class="ui-selectee" id="monthDate" schday="2020.03.16"></td><td class="ui-selectee" id="monthDate" schday="2020.03.17"></td><td class="ui-selectee" id="monthDate" schday="2020.03.18"></td><td class="ui-selectee" id="monthDate" schday="2020.03.19"></td><td class="ui-selectee" id="monthDate" schday="2020.03.20"></td><td class="ui-selectee" id="monthDate" schday="2020.03.21"></td></tr></tbody></table><table class="monShcList" id="tableWeekScheduleForMonth_20200315"><tbody><tr><td class="sun ui-selectee" schday="2020.03.15"><strong>15</strong><span class="day_info" name="dayInfo" value="2020-03-15"></span></td><td class="ui-selectee" schday="2020.03.16"><strong>16</strong><span class="day_info" name="dayInfo" value="2020-03-16"></span></td><td class="ui-selectee" schday="2020.03.17"><strong>17</strong><span class="day_info" name="dayInfo" value="2020-03-17"></span></td><td class="ui-selectee" schday="2020.03.18"><strong>18</strong><span class="day_info" name="dayInfo" value="2020-03-18"></span></td><td class="ui-selectee" schday="2020.03.19"><strong>19</strong><span class="day_info" name="dayInfo" value="2020-03-19"></span></td><td class="ui-selectee" schday="2020.03.20"><strong>20</strong><span class="day_info" name="dayInfo" value="2020-03-20"></span></td><td class="ui-selectee" schday="2020.03.21"><strong>21</strong><span class="day_info" name="dayInfo" value="2020-03-21"></span></td></tr><tr id="trAlldayBar_20200315_0" rowno="0"><td class="ui-droppable" id="tdAlldayBar_20200315_0_0" schday="2020.03.15" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200315_0_1" schday="2020.03.16" day="1"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12705" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6809" dateid="12705" eventid="6992"><div><span class="time">09:30</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_0_2" schday="2020.03.17" day="2"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12685" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6987" isrepeat="N" repeatid="6792" dateid="12685" eventid="6974"><div><span class="time">09:00</span><span class="txt">세미나실(56인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_0_3" schday="2020.03.18" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12731" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6835" dateid="12731" eventid="7018"><div><span class="time">09:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_0_4" schday="2020.03.19" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12686" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6987" isrepeat="N" repeatid="6793" dateid="12686" eventid="6975"><div><span class="time">09:00</span><span class="txt">세미나실(56인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_0_5" schday="2020.03.20" day="5"><div class="shcDayText comp repeatW ui-draggable ui-draggable-handle" id="eventData_11379" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="Y" repeatid="6152" dateid="11379" eventid="6309"><div><span class="time">09:00</span><span class="txt">302호(8인)</span></div><div class="calToolTip">반복일정</div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_0_6" schday="2020.03.21" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200315_1" rowno="1"><td class="ui-droppable" id="tdAlldayBar_20200315_1_0" schday="2020.03.15" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200315_1_1" schday="2020.03.16" day="1"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12697" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6801" dateid="12697" eventid="6983"><div><span class="time">16:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_1_2" schday="2020.03.17" day="2"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12721" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6825" dateid="12721" eventid="7008"><div><span class="time">09:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_1_3" schday="2020.03.18" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12714" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6818" dateid="12714" eventid="7001"><div><span class="time">10:30</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_1_4" schday="2020.03.19" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12766" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="85" isrepeat="N" repeatid="6863" dateid="12766" eventid="7046"><div><span class="time">11:00</span><span class="txt">101호(4인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_1_5" schday="2020.03.20" day="5"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12759" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6856" dateid="12759" eventid="7039"><div><span class="time">11:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_1_6" schday="2020.03.21" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200315_2" rowno="2"><td class="ui-droppable" id="tdAlldayBar_20200315_2_0" schday="2020.03.15" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200315_2_1" schday="2020.03.16" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200315_2_2" schday="2020.03.17" day="2"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12722" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6826" dateid="12722" eventid="7009"><div><span class="time">09:30</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_2_3" schday="2020.03.18" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_11916" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6536" dateid="11916" eventid="6708"><div><span class="time">14:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_2_4" schday="2020.03.19" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12768" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6865" dateid="12768" eventid="7048"><div><span class="time">14:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_2_5" schday="2020.03.20" day="5"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12760" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6857" dateid="12760" eventid="7040"><div><span class="time">13:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_2_6" schday="2020.03.21" day="6">&nbsp;</td></tr><tr class="daybar_off" id="trAlldayBar_20200315_3" style="display:none;" rowno="3"><td class="ui-droppable" id="tdAlldayBar_20200315_3_0" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200315_3_1" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200315_3_2" day="2"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12713" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6817" dateid="12713" eventid="7000"><div><span class="time">10:30</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_3_3" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12754" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6852" dateid="12754" eventid="7035"><div><span class="time">15:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_3_4" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12755" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6853" dateid="12755" eventid="7036"><div><span class="time">15:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_3_5" day="5"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12761" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6858" dateid="12761" eventid="7041"><div><span class="time">16:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_3_6" day="6">&nbsp;</td></tr><tr class="daybar_off" id="trAlldayBar_20200315_4" style="display:none;" rowno="4"><td class="ui-droppable" id="tdAlldayBar_20200315_4_0" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200315_4_1" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200315_4_2" day="2"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12712" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6816" dateid="12712" eventid="6999"><div><span class="time">16:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_4_3" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12715" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6819" dateid="12715" eventid="7002"><div><span class="time">17:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_4_4" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12716" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6820" dateid="12716" eventid="7003"><div><span class="time">17:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_4_5" day="5">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200315_4_6" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200315_more" rowno=""><td class="ui-droppable" id="tdAlldayBar_20200315_more_0" schday="2020.03.15" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200315_more_1" schday="2020.03.16" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200315_more_2" schday="2020.03.17" day="2"><div class="moreShcDayTextView"><a class="ui-draggable ui-draggable-handle" style="position: relative;" onclick="resourceUser.setMoreListPopup(this);">+2</a></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_more_3" schday="2020.03.18" day="3"><div class="moreShcDayTextView"><a class="ui-draggable ui-draggable-handle" style="position: relative;" onclick="resourceUser.setMoreListPopup(this);">+2</a></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_more_4" schday="2020.03.19" day="4"><div class="moreShcDayTextView"><a class="ui-draggable ui-draggable-handle" style="position: relative;" onclick="resourceUser.setMoreListPopup(this);">+2</a></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_more_5" schday="2020.03.20" day="5"><div class="moreShcDayTextView"><a class="ui-draggable ui-draggable-handle" style="position: relative;" onclick="resourceUser.setMoreListPopup(this);">+1</a></div></td><td class="ui-droppable" id="tdAlldayBar_20200315_more_6" schday="2020.03.21" day="6">&nbsp;</td></tr></tbody></table></div><div class="calMonWeekRow" id="divWeekScheduleForMonth_20200322" week="3"><table class="calGrid"><tbody><tr><td class="ui-selectee" id="monthDate" schday="2020.03.22"></td><td class="ui-selectee" id="monthDate" schday="2020.03.23"></td><td class="ui-selectee" id="monthDate" schday="2020.03.24"></td><td class="ui-selectee" id="monthDate" schday="2020.03.25"></td><td class="ui-selectee" id="monthDate" schday="2020.03.26"></td><td class="ui-selectee" id="monthDate" schday="2020.03.27"></td><td class="ui-selectee" id="monthDate" schday="2020.03.28"></td></tr></tbody></table><table class="monShcList" id="tableWeekScheduleForMonth_20200322"><tbody><tr><td class="sun ui-selectee" schday="2020.03.22"><strong>22</strong><span class="day_info" name="dayInfo" value="2020-03-22"></span></td><td class="ui-selectee" schday="2020.03.23"><strong>23</strong><span class="day_info" name="dayInfo" value="2020-03-23"></span></td><td class="ui-selectee" schday="2020.03.24"><strong>24</strong><span class="day_info" name="dayInfo" value="2020-03-24"></span></td><td class="ui-selectee" schday="2020.03.25"><strong>25</strong><span class="day_info" name="dayInfo" value="2020-03-25"></span></td><td class="ui-selectee" schday="2020.03.26"><strong>26</strong><span class="day_info" name="dayInfo" value="2020-03-26"></span></td><td class="ui-selectee" schday="2020.03.27"><strong>27</strong><span class="day_info" name="dayInfo" value="2020-03-27"></span></td><td class="ui-selectee" schday="2020.03.28"><strong>28</strong><span class="day_info" name="dayInfo" value="2020-03-28"></span></td></tr><tr id="trAlldayBar_20200322_0" rowno="0"><td class="ui-droppable" id="tdAlldayBar_20200322_0_0" schday="2020.03.22" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_0_1" schday="2020.03.23" day="1"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12781" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6878" dateid="12781" eventid="7061"><div><span class="time">13:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_0_2" schday="2020.03.24" day="2"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12810" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6987" isrepeat="N" repeatid="6899" dateid="12810" eventid="7082"><div><span class="time">09:00</span><span class="txt">세미나실(56인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_0_3" schday="2020.03.25" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12780" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6877" dateid="12780" eventid="7060"><div><span class="time">13:30</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_0_4" schday="2020.03.26" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12811" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6987" isrepeat="N" repeatid="6900" dateid="12811" eventid="7083"><div><span class="time">09:00</span><span class="txt">세미나실(56인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_0_5" schday="2020.03.27" day="5"><div class="shcDayText comp repeatW ui-draggable ui-draggable-handle" id="eventData_11380" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="Y" repeatid="6152" dateid="11380" eventid="6309"><div><span class="time">09:00</span><span class="txt">302호(8인)</span></div><div class="calToolTip">반복일정</div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_0_6" schday="2020.03.28" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200322_1" rowno="1"><td class="ui-droppable" id="tdAlldayBar_20200322_1_0" schday="2020.03.22" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_1_1" schday="2020.03.23" day="1"><div class="shcDayText my ui-draggable ui-draggable-handle" id="eventData_12784" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6880" dateid="12784" eventid="7063"><div><span class="time">13:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_1_2" schday="2020.03.24" day="2"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12819" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6905" dateid="12819" eventid="7088"><div><span class="time">13:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_1_3" schday="2020.03.25" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12841" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6924" dateid="12841" eventid="7107"><div><span class="time">14:45</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_1_4" schday="2020.03.26" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12850" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6932" dateid="12850" eventid="7115"><div><span class="time">11:30</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_1_5" schday="2020.03.27" day="5"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12854" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6936" dateid="12854" eventid="7119"><div><span class="time">13:30</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_1_6" schday="2020.03.28" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200322_2" rowno="2"><td class="ui-droppable" id="tdAlldayBar_20200322_2_0" schday="2020.03.22" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_2_1" schday="2020.03.23" day="1"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12774" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6871" dateid="12774" eventid="7054"><div><span class="time">14:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_2_2" schday="2020.03.24" day="2">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_2_3" schday="2020.03.25" day="3">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_2_4" schday="2020.03.26" day="4">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_2_5" schday="2020.03.27" day="5"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12865" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6946" dateid="12865" eventid="7129"><div><span class="time">16:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_2_6" schday="2020.03.28" day="6">&nbsp;</td></tr><tr class="daybar_off" id="trAlldayBar_20200322_3" style="display:none;" rowno="3"><td class="ui-droppable" id="tdAlldayBar_20200322_3_0" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_3_1" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_3_2" day="2">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_3_3" day="3">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_3_4" day="4">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_3_5" day="5"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12847" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6929" dateid="12847" eventid="7112"><div><span class="time">17:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_3_6" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200322_more" rowno=""><td class="ui-droppable" id="tdAlldayBar_20200322_more_0" schday="2020.03.22" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_more_1" schday="2020.03.23" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_more_2" schday="2020.03.24" day="2">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_more_3" schday="2020.03.25" day="3">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_more_4" schday="2020.03.26" day="4">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200322_more_5" schday="2020.03.27" day="5"><div class="moreShcDayTextView"><a class="ui-draggable ui-draggable-handle" style="position: relative;" onclick="resourceUser.setMoreListPopup(this);">+1</a></div></td><td class="ui-droppable" id="tdAlldayBar_20200322_more_6" schday="2020.03.28" day="6">&nbsp;</td></tr></tbody></table></div><div class="calMonWeekRow" id="divWeekScheduleForMonth_20200329" week="4"><table class="calGrid"><tbody><tr><td class="ui-selectee" id="monthDate" schday="2020.03.29"></td><td class="ui-selectee" id="monthDate" schday="2020.03.30"></td><td class="ui-selectee" id="monthDate" schday="2020.03.31"></td><td class="ui-selectee" id="monthDate" schday="2020.04.01"></td><td class="shcToDay ui-selectee" id="monthDate" schday="2020.04.02"><div></div></td><td class="ui-selectee" id="monthDate" schday="2020.04.03"></td><td class="ui-selectee" id="monthDate" schday="2020.04.04"></td></tr></tbody></table><table class="monShcList" id="tableWeekScheduleForMonth_20200329"><tbody><tr><td class="sun ui-selectee" schday="2020.03.29"><strong>29</strong><span class="day_info" name="dayInfo" value="2020-03-29"></span></td><td class="ui-selectee" schday="2020.03.30"><strong>30</strong><span class="day_info" name="dayInfo" value="2020-03-30"></span></td><td class="ui-selectee" schday="2020.03.31"><strong>31</strong><span class="day_info" name="dayInfo" value="2020-03-31"></span></td><td class="disable ui-selectee" schday="2020.04.01"><strong>1</strong><span class="day_info" name="dayInfo" value="2020-04-01"></span></td><td class="disable shcToDay ui-selectee" schday="2020.04.02"><strong>2</strong><span class="day_info" name="dayInfo" value="2020-04-02"></span></td><td class="disable ui-selectee" schday="2020.04.03"><strong>3</strong><span class="day_info" name="dayInfo" value="2020-04-03"></span></td><td class="disable ui-selectee" schday="2020.04.04"><strong>4</strong><span class="day_info" name="dayInfo" value="2020-04-04"></span></td></tr><tr id="trAlldayBar_20200329_0" rowno="0"><td class="ui-droppable" id="tdAlldayBar_20200329_0_0" schday="2020.03.29" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_0_1" schday="2020.03.30" day="1"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12866" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6947" dateid="12866" eventid="7130"><div><span class="time">11:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200329_0_2" schday="2020.03.31" day="2">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_0_3" schday="2020.04.01" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12862" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6943" dateid="12862" eventid="7126"><div><span class="time">10:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200329_0_4" schday="2020.04.02" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12938" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6975" dateid="12938" eventid="7158"><div><span class="time">09:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200329_0_5" schday="2020.04.03" day="5"><div class="shcDayText comp repeatW ui-draggable ui-draggable-handle" id="eventData_11381" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="Y" repeatid="6152" dateid="11381" eventid="6309"><div><span class="time">09:00</span><span class="txt">302호(8인)</span></div><div class="calToolTip">반복일정</div></div></td><td class="ui-droppable" id="tdAlldayBar_20200329_0_6" schday="2020.04.04" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200329_1" rowno="1"><td class="ui-droppable" id="tdAlldayBar_20200329_1_0" schday="2020.03.29" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_1_1" schday="2020.03.30" day="1"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12859" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6940" dateid="12859" eventid="7123"><div><span class="time">14:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200329_1_2" schday="2020.03.31" day="2">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_1_3" schday="2020.04.01" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12924" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6963" dateid="12924" eventid="7146"><div><span class="time">13:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200329_1_4" schday="2020.04.02" day="4"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12861" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6942" dateid="12861" eventid="7125"><div><span class="time">14:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200329_1_5" schday="2020.04.03" day="5">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_1_6" schday="2020.04.04" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200329_2" rowno="2"><td class="ui-droppable" id="tdAlldayBar_20200329_2_0" schday="2020.03.29" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_2_1" schday="2020.03.30" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_2_2" schday="2020.03.31" day="2">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_2_3" schday="2020.04.01" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12860" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="86" isrepeat="N" repeatid="6941" dateid="12860" eventid="7124"><div><span class="time">14:00</span><span class="txt">102호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200329_2_4" schday="2020.04.02" day="4">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_2_5" schday="2020.04.03" day="5">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_2_6" schday="2020.04.04" day="6">&nbsp;</td></tr><tr class="daybar_off" id="trAlldayBar_20200329_3" style="display:none;" rowno="3"><td class="ui-droppable" id="tdAlldayBar_20200329_3_0" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_3_1" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_3_2" day="2">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_3_3" day="3"><div class="shcDayText comp ui-draggable ui-draggable-handle" id="eventData_12925" style="" onclick="resourceUser.setSimpleViewPopup(this)" resourceid="6986" isrepeat="N" repeatid="6964" dateid="12925" eventid="7147"><div><span class="time">16:00</span><span class="txt">302호(8인)</span></div></div></td><td class="ui-droppable" id="tdAlldayBar_20200329_3_4" day="4">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_3_5" day="5">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_3_6" day="6">&nbsp;</td></tr><tr id="trAlldayBar_20200329_more" rowno=""><td class="ui-droppable" id="tdAlldayBar_20200329_more_0" schday="2020.03.29" day="0">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_more_1" schday="2020.03.30" day="1">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_more_2" schday="2020.03.31" day="2">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_more_3" schday="2020.04.01" day="3"><div class="moreShcDayTextView"><a class="ui-draggable ui-draggable-handle" style="position: relative;" onclick="resourceUser.setMoreListPopup(this);">+1</a></div></td><td class="ui-droppable" id="tdAlldayBar_20200329_more_4" schday="2020.04.02" day="4">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_more_5" schday="2020.04.03" day="5">&nbsp;</td><td class="ui-droppable" id="tdAlldayBar_20200329_more_6" schday="2020.04.04" day="6">&nbsp;</td></tr></tbody></table></div></div><article id="read_popup" style="position:absolute;"></article>
			</div>

			<div class="tblList tblCont" style="display:none">
				<div id="gridDiv"></div>
				<div id="gridTotDiv"></div>
			</div>
			
		<div class="tblButton text-r" >
			<form name="fButton">
				<div class="float-l">
				</div>
				<div class="text-r">
				<span style="font-weight:bold;color:#565E70">
					<div style="padding-top:5px;">*<spring:message code='Cache.mag_Attendance49' /></div> <!-- 미확정(설정)건은 기본근무제로 전월 15일에 자동 확정.(예: 4월 근무일정은 3월 15일 자동확정) -->
<!--  					<div style="padding-top:5px;">*일괄생성시 기존에 입력된 <font color="Red">[조퇴, 코칭]</font> 빼고 전부 삭제 됩니다.</div>-->
				</span>
			</form>
		</div>
		
	</div>
</div>
<%int max=31; %>
<script>
	var gridColor = ["","#ffcc00","#ff6666","#66cccc","#9b72b0","#d2d5e8",""];
	var gridName  = ["","900","800","<spring:message code='Cache.lbl_Shortening' />","<spring:message code='Cache.lbl_night' />","930","830"]; //"단축","야간"
	var grid = new coviGrid();
	var gridTot = new coviGrid();
	// 그리드 세팅
	var headerData = [ 
           {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		{key:'UrName',  label:'<spring:message code="Cache.lbl_name" />', width:'40', align:'left'}, //이름
		<%for (int i=1; i <=max ; i++){%>
			{key:'d<%=i%>',  label:'<%=i%>', width:'20', align:'left', formatter:function () {
		   		 return "<a><font style='background-color:"+gridColor[this.item.d<%=i%>]+";width:10px;'>"+gridName[this.item.d<%=i%>]+"</font></a>";
	    	}}, 
		<%}%>
		{key:'tot_time',  label:'<spring:message code="Cache.lbl_apv_TimeTotal" />', width:'40', align:'left'},		//총시간
		{key:'avg_time',  label:'<spring:message code="Cache.lbl_apv_TimeAverage" />', width:'40', align:'left'}	//평균시간
	];

	// 그리드 세팅
	var headerTotData = [ 
		{key:'UrName',  label:'<spring:message code="Cache.lbl_WorkExpulsionName" />', width:'40', align:'left'}, //근무제명
		<%for (int i=1; i <=max ; i++){%>
			{key:'d<%=i%>',  label:'<%=i%>', width:'20', align:'left'}, 
		<%}%>
		{key:'tot_time',  label:'<spring:message code="Cache.lbl_apv_TimeTotal" />', width:'40', align:'left'},	//총시간
		{key:'avg_time',  label:'<spring:message code="Cache.lbl_apv_TimeAverage" />', width:'40', align:'left'}	//평균시간
	];

	$(document).ready(function(){
		// config
		var configObj = {
			targetID : "gridDiv",
			height : "auto",
			page : {
				pageNo: 1,
				pageSize: $("#listCntSel").val(),
			},
			paging : true,
			colHead:{},
			body:{}
		};
		
		grid.setGridHeader(headerData);
		grid.setGridConfig({
			targetID : "gridDiv",
			height : "auto",
			page : {
				pageNo: 1,
				pageSize: $("#listCntSel").val(),
			},
			paging : true,
			colHead:{},
			body:{}
		});
		
		gridTot.setGridHeader(headerTotData);
		gridTot.setGridConfig({
			targetID : "gridTotDiv",
			height : "auto",
			paging : false,
			colHead:{},
			body:{}
			});

		AttendUtils.getDeptList($("#deptList"),'');
		searchList();
		
		//근무일정생성
		$("#btnScheduleJob").click(function(){
			var popupID		= "AttendScheduleJobPopup";
			var openerID	= "AttendScheduleJob";
			var popupTit	= "<spring:message code='Cache.MN_887' />";
			var popupYN		= "N";
			var callBack	= "AttendScheduleJobPopup_CallBack";
			var popupUrl	= "/groupware/attendScheduleJob/AttendScheduleJobPopup.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "callBackFunc="	+ callBack	;
			
			Common.open("", popupID, popupTit, popupUrl, "600px", "600px", "iframe", true, null, null, true);
		});
		
		//event 세팅
		$('#btnSearch').click(function(){
			searchList();
		});
		
		$("#listSecterSel,#listCntSel").change(function(){
			searchList();
		});
		
		$("#btnRefresh").click(function(){
			refreshPage();
		});
		
		$("#btnAdd").click(function(){
			openAttendSchedulePopup('add',0);
		});	
		
		$("#btnDelete").click(function(){
			deleteList();
		});	
		
		$("#btnExcelDown").click(function(){
			AttendUtils.gridToExcel($(".title").text(), headerData, "", "/groupware/attendSchedule/downloadExcel.do");
		});

	});
	
	// 검색
	function searchList(keepYn) {		

		var gridData = { list: [{'UrName':'<spring:message code="Cache.mag_Attendance50" />' //홍길동
			,  'd1':1,  'd2':1,  'd3':3,  'd4':4,  'd5':0,  'd6':0,  'd7':5,  'd8':2,  'd9':1, 'd10':1
			, 'd11':1, 'd12':0, 'd13':0, 'd14':4, 'd15':1, 'd16':3, 'd17':5, 'd18':2, 'd19':0, 'd20':0
			, 'd21':1, 'd22':1, 'd23':3, 'd24':4, 'd25':1, 'd26':0, 'd27':0, 'd28':2, 'd29':1, 'd30':1, 'd31':1, 'tot_time':160,'avg_time':8}
			,{'UrName':'<spring:message code="Cache.mag_Attendance50" />2'	//홍길동
			,  'd1':1,  'd2':1,  'd3':1,  'd4':1,  'd5':0,  'd6':0,  'd7':1,  'd8':1,  'd9':1, 'd10':1
			, 'd11':1, 'd12':0, 'd13':0, 'd14':4, 'd15':1, 'd16':3, 'd17':5, 'd18':2, 'd19':0, 'd20':0
			, 'd21':1, 'd22':1, 'd23':3, 'd24':4, 'd25':1, 'd26':0, 'd27':0, 'd28':2, 'd29':1, 'd30':1, 'd31':1, 'tot_time':120,'avg_time':8}
			
			]}
		grid.setData(gridData);
		
		
		var gridTotData = { list: [
		{'UrName':'<spring:message code="Cache.lbl_TFTotalCount" />' //총 인원
			,  'd1':5,  'd2':5,  'd3':5,   'd4':5,  'd5':'',  'd6':'',  'd7':5,  'd8':5,  'd9':5, 'd10':5
			, 'd11':5, 'd12':'', 'd13':'', 'd14':5, 'd15':5, 'd16':5, 'd17':5, 'd18':5, 'd19':'', 'd20':''
			, 'd21':5, 'd22':5, 'd23':5, 'd24':5, 'd25':5, 'd26':'', 'd27':'', 'd28':5, 'd29':5, 'd30':5, 'd31':5, 'tot_time':160,'avg_time':8}
	    ,{'UrName':'9<spring:message code="Cache.lbl_Hour" />'	//시
			,  'd1':1,  'd2':1,  'd3':3,  'd4':4,  'd5':'',  'd6':'',  'd7':5,  'd8':2,  'd9':1, 'd10':1
			, 'd11':1, 'd12':'', 'd13':'', 'd14':4, 'd15':1, 'd16':3, 'd17':5, 'd18':2, 'd19':'', 'd20':''
			, 'd21':1, 'd22':1, 'd23':3, 'd24':4, 'd25':1, 'd26':'', 'd27':'', 'd28':2, 'd29':1, 'd30':1, 'd31':1, 'tot_time':160,'avg_time':8}
		,{'UrName':'8<spring:message code="Cache.lbl_Hour" />'	//시
			,  'd1':1,  'd2':1,  'd3':1,  'd4':1,  'd5':'',  'd6':'',  'd7':1,  'd8':1,  'd9':1, 'd10':1
			, 'd11':1, 'd12':'', 'd13':'', 'd14':4, 'd15':1, 'd16':3, 'd17':5, 'd18':2, 'd19':'', 'd20':''
			, 'd21':1, 'd22':1, 'd23':3, 'd24':4, 'd25':1, 'd26':'', 'd27':'', 'd28':2, 'd29':1, 'd30':1, 'd31':1, 'tot_time':120,'avg_time':8}
		,{'UrName':'<spring:message code="Cache.lbl_Unset" />'	//미설정
			,  'd1':1,  'd2':1,  'd3':1,  'd4':1,  'd5':'',  'd6':'',  'd7':1,  'd8':1,  'd9':1, 'd10':1
			, 'd11':1, 'd12':'', 'd13':'', 'd14':4, 'd15':1, 'd16':3, 'd17':5, 'd18':2, 'd19':'', 'd20':''
			, 'd21':1, 'd22':1, 'd23':3, 'd24':4, 'd25':1, 'd26':'', 'd27':'', 'd28':2, 'd29':1, 'd30':1, 'd31':1, 'tot_time':120,'avg_time':8}
		,{'UrName':'<spring:message code="Cache.lbl_Vacation" />'	//휴가
			,  'd1':1,  'd2':1,  'd3':1,  'd4':1,  'd5':'',  'd6':'',  'd7':1,  'd8':1,  'd9':1, 'd10':1
			, 'd11':1, 'd12':'', 'd13':'', 'd14':4, 'd15':1, 'd16':3, 'd17':5, 'd18':2, 'd19':'', 'd20':''
			, 'd21':1, 'd22':1, 'd23':3, 'd24':4, 'd25':1, 'd26':'', 'd27':'', 'd28':2, 'd29':1, 'd30':1, 'd31':1, 'tot_time':'','avg_time':''}
			
			]}
		gridTot.setData(gridTotData);

		/*

		if(keepYn== 'Y'){
			grid.reloadList();
		}
		else{
			var params = {reqType : "A"};
			grid.page.pageNo = 1;
			grid.page.pageSize = $("#listCntSel").val();
			// bind
			grid.bindGrid({
				ajaxPars : params,
				ajaxUrl:"/groupware/attendSchedule/getAttendScheduleList.do"
			});
		}*/
		
	}
	
	function deleteList(){

		var deleteobj = grid.getCheckedList(0);
		var aJsonArray = new Array();
		if(deleteobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
			return;
		}else{
			for(var i=0; i<deleteobj.length; i++){
				var saveData = { "SchSeq":deleteobj[i].SchSeq};
                aJsonArray.push(saveData);
			}
			
			var objParams = {
                    "dataList" : aJsonArray       
                };
			$.ajax({
				type:"POST",
				contentType:'application/json; charset=utf-8',
				dataType   : 'json',
				data:JSON.stringify(objParams),
				url:"/groupware/attendSchedule/deleteAttendSchedule.do",
				success:function (data) {
					if(data.result == "ok"){
						Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_Deleted'/>");	//저장되었습니다.
						searchList('Y');
					}
					else{
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
					}
				},
				error:function (request,status,error){
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
			});
		}
	}
	
	
	function refreshPage() {
		$('#searchText').val("");
		$('#listSecterSel').val("");
//		$('#listPMSel').val("");
		$('#listSalesSel').val("");
		searchList();
	}
	
	
	function openAttendSchedulePopup(mode, SchSeq){
		var popupID		= "AttendSchedulePopup";
		var openerID	= "AttendSchedule";
		var popupTit	= "<spring:message code='Cache.MN_887' />";
		var popupYN		= "N";
		var callBack	= "AttendSchedulePopup_CallBack";
		var popupUrl	= "/groupware/attendSchedule/AttendSchedulePopup.do?"
						+ "popupID="		+ popupID	+ "&"
						+ "openerID="		+ openerID	+ "&"
						+ "popupYN="		+ popupYN	+ "&"
						+ "SchSeq="	+ SchSeq	+ "&"
						+ "callBackFunc="	+ callBack	+ "&"
						+ "mode="			+ mode;
		
		Common.open("", popupID, popupTit, popupUrl, "600px", "600px", "iframe", true, null, null, true);
	}
	
	function AttendSchedulePopup_CallBack(){
		searchList('Y');
	}

</script>
