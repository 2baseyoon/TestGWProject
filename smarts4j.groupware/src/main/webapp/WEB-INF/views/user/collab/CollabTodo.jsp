<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<script>
    var collabTodo = {
    	tabMode : 'KANB',
         pop : function(){
                var popupID	= "CollabTagPopup";
                var openerID = "AttendReq";
                var popupTit	= Common.getDic("lbl_TagPopup");//"<spring:message code='Cache.lblcollabTodocollabTodoroval_extention' />";
                var popupYN		= "N";
                var callBack	= "";
                var popupUrl	= "/groupware/collab/todo/collabTagPopup.do?"
                    + "popupID="		+ popupID	+ "&"
                    + "openerID="		+ openerID	+ "&"
                    + "popupYN="		+ popupYN	+ "&"
                    + "callBackFunc="	+ callBack	;
                Common.open("", popupID, popupTit, popupUrl, "720px", "815px", "iframe", true, null, null, true);
            },
    }

</script>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<style>
.inPerView{width:100%}
.tx_title .gant {}
</style>
<c:set var="today" value="<%=new java.util.Date()%>" />
<!-- 상단 끝 -->
<div class="cRConTop titType">
    <h2 class="title"><spring:message code='Cache.lbl_MyWork' /></h2> <!-- 내업무 -->
</div>
<div class='cRContCollabo mScrollVH'>
       <!-- 컨텐츠 시작 -->
	<div class="myTaskArea Area active">
			<div class="Project_tabList tabList">
				<ul>
				  <li class="active" data-tab="tstab-1" data-type="TASK"><a href="#n"><spring:message code='Cache.lbl_task_task' /></a></li> <!-- 업무 -->
				  <li class="" data-tab="tstab-2" data-type="FILE"><a href="#n"><spring:message code='Cache.lbl_File' /></a></li> <!-- 파일 -->
<%if (RedisDataUtil.getBaseConfig("isUseCollabApproval").equals("Y")){ %>
				  <li class="" data-tab="tstab-3" data-type="APPROVAL"><a href="#n"><spring:message code='Cache.lbl_RelatedApproval' /></a></li> <!-- 관련 결재 -->
<%} %>
<%if (RedisDataUtil.getBaseConfig("isUseCollabSurvey").equals("Y")){ %>
				  <li class="" data-tab="tstab-4" data-type="SURVEY"><a href="#n"><spring:message code='Cache.BizSection_Survey' /></a></li> <!-- 설문 -->
<%} %>
				  <li class="" data-tab="tstab-5" data-type="ADDREPORT"><a href="#n"><spring:message code='Cache.TodoCategory_WorkReport' /></a></li> <!-- 업무보고 -->
				</ul>
			</div>
			<div class="Project_date" id="collab_status_date"><strong></strong></div>
			<div class="Project_list_co pos">
				<div class="Project_list_01">
					<p class="Project_tit"><spring:message code='Cache.lbl_Ready' />/<spring:message code='Cache.lbl_Progress' />/<spring:message code='Cache.lbl_Hold' /></p>
					<ul>
						<li class="bg01 bg01_1">
							<a href="#" class="">
								<span class="txt"><spring:message code='Cache.lbl_Urgency' /></span> </span>
								<strong class="num"><span class="pro_urgent" id="enum">999</span></strong>
							</a>
						</li>
						<li class="bg01 bg01_2">
							<a href="#" class="">
								<span class="txt"><spring:message code='Cache.lbl_Delay' /></span></span>
								<strong class="num" id=dnum><span class="pro_important">999</span></strong>
							</a>
						</li>
						<li class="bg02">
							<a href="#" class="">
								<span class="txt"><spring:message code='Cache.lbl_importance' /></span>
								<div class="num_case_area">
									<span class="num_case num_up" id="lvlhnum"><span class="txt_s"><spring:message code='Cache.Anni_Priority_2' /></span><strong class="num">999</strong></span>
									<span class="num_case num_equal" id="lvlmnum"><span class="txt_s"><spring:message code='Cache.Anni_Priority_3' /></span><strong class="num">999</strong></span>
									<span class="num_case num_down" id="lvllnum"><span class="txt_s"><spring:message code='Cache.Anni_Priority_4' /></span><strong class="num">999</strong></span>
								</div>
							</a>
						</li>
					</ul>
				</div>							
				<div class="Project_list_02">
					<p class="Project_tit"><spring:message code='Cache.btn_All'/></p>
					<div class="total_progress">
						<strong class="num" id="tnum">999</strong>
					</div>
					<ul>
						<li class="bg03">
							<a href="#" class="">
								<div class="total_progress">
									<span class="txt"><spring:message code='Cache.lbl_MyWork' />&nbsp;<spring:message code='Cache.btn_All' /></span>
									<strong class="num" id="tnum">999</strong>
								</div>
								<div class="total_num_case">
									<ul>
										<li class="tnum01" id="wnum"><span><spring:message code='Cache.lbl_Ready' /></span><strong>999</strong></li>
										<li class="tnum02" id="pnum"><span><spring:message code='Cache.lbl_Progress' /></span><strong>999</strong></li>
										<li class="tnum03" id="hnum"><span><spring:message code='Cache.lbl_Hold' /></span><strong>999</strong></li>
										<li class="tnum04" id="cnum"><span><spring:message code='Cache.lbl_Completed' /></span><strong>999</strong></li>
									</ul>
								</div>
							</a>
						</li>
					</ul>
				</div>	
				<div class="Project_list_03">
					<ul>
						<li class="bg04">
							<a href="#" class=""> 
								<span class="txt"><spring:message code='Cache.lbl_MyWork' /><br><spring:message code='Cache.lbl_TFProgressing' />
								</span>
								<div class="Project_cycleCont">
									<div class="cycleBg">
										<div class="pie"></div>
										<div class="cycleTxt">
											<div class="inner">
												<strong class="cNum">0<span>%</span></strong>
											</div>
										</div>
									</div>
									<div id="slice">
										<div class="pie" id="pieDiv" style="transform: rotate(36deg);"></div>
										<div class="pie fill"></div>
									</div>
								</div>
							</a>
						</li>
					</ul>
				</div>	
			</div>
			<div class="myTask_tabCont tabCont">
				<div id="tstab-1" class="tstab_cont active">
					<div class="myTask_top myTask_top_r">
						<div class="myTask_cal" id="calTitle" style="display:none">
							<div class="calBtn">
								<strong class="title"><fmt:formatDate value="${today}" pattern="yyyy.MM" /></strong>
								<div class="pagingType02">
									<a href="#" class="pre dayChg" data-paging="-"></a>
									<a href="#" class="next dayChg" data-paging="+"></a>
									<a href="#" class="btnTypeDefault calendartoday"><spring:message code='Cache.lbl_Todays'/></a>
								</div>
							</div>
							<ul class="calSelect" id="calTab">
								<li class="selected" data-tab="calPlan"><a href="#"><spring:message code='Cache.lbl_Schedule'/></a></li> <!-- 일정 -->
								<li data-tab="calSchedule"><a href="#"><spring:message code='Cache.lbl_ScheduleEng'/></a></li> <!-- 스케줄 -->
							</ul>
						</div>
<%if (RedisDataUtil.getBaseConfig("CollabGantt").equals("Y")){ %>
					<div class="Project_cal gantt" id="gantTitle" style="display: none">
						<div class="calBtn">
							<strong class="title">2021.04</strong>
							<select id="selType">
								<option value="D" selected>Day</option>
								<option value="W">Week</option>
								<option value="M">Month</option>
								<option value="Q">Quater</option>
								<option value="H">Half</option>
								<option value="Y">Year</option>
							</select>
							<div class="pagingType02">
								<a href="#" class="pre dayChg" data-paging="-"></a> 
								<a href="#"	class="next dayChg" data-paging="+"></a> 
  								<a href="#"	class="btnTypeDefault calendartoday"><spring:message code='Cache.lbl_Todays' /></a>
							</div>
						</div>
						<ul class="calSelect" id="gantTab">
							<li data-tab="GANT"><a href="#"><spring:message code='Cache.lbl_ByCondition' /></a></li> <!-- 섹션 -->
							<li class="selected" data-tab="GANTN"><a href="#"><spring:message code='Cache.lbl_task_task' /></a></li> <!-- 업무 -->
						</ul>
					</div>
<%} %>
					<div class="Project_filter tag" id="myTask_tag">
						<input class="adDate" type="text" id="date1" date_separator="." readonly=""> - 
						<input id="date2" date_separator="." date_startTargetID="date1" class="adDate" type="text" readonly="">
<!--  						<input type="text" list="taskTag" id="taskTagInput" value='#<spring:message code='Cache.lbl_all' />'/>-->
						<select id="taskTag" class="selectType02" style="width:180px">
							<option data="#" data-opt='1'><spring:message code='Cache.lbl_subject'/></option> <!-- 제목 -->
							<option data="#" data-opt='2'><spring:message code='Cache.lbl_Contents' /></option> <!-- 내용 -->
							<option data="#" data-opt='4'><spring:message code='Cache.lbl_Tag' /></option> <!-- 태그 -->
							<option data="#" data-opt='3'><spring:message code='Cache.lbl_subject' /> + <spring:message code='Cache.lbl_Contents' /> + <spring:message code='Cache.lbl_Tag' /></option> <!-- 제목 + 내용 + 태그 -->
							<option data="" selected>#<spring:message code='Cache.lbl_all' /></option>
							<c:forEach var="list" items="${tag}">
								<c:if test="${list.TagType == 'TASK' || list.TagType == 'PRJONLY'}">
									<option data="${list.TagSeq}">#${list.TagName}</option>
								</c:if>
							</c:forEach>
						</select>
						<select class="selectType02" name="searchOption" id="searchOption" style="display:none">
							<option value=""><spring:message code='Cache.lbl_Select' /></option> <!-- 선택 -->
							<option value="1"><spring:message code='Cache.lbl_subject' /></option> <!-- 제목 -->
							<option value="2"><spring:message code='Cache.lbl_Contents' /></option> <!-- 내용 -->
							<option value="4"><spring:message code='Cache.lbl_Tag' /></option> <!-- 태그 -->
							<option value="3"><spring:message code='Cache.lbl_subject' /> + <spring:message code='Cache.lbl_Contents' /> + <spring:message code='Cache.lbl_Tag' /></option> <!-- 제목 + 내용 + 태그 -->
						</select>
						<div class="dateSel type02">
							<input type="text" name="searchWord" id="searchWord" disabled>
						</div>
			            <a href="#" class="btnTypeDefault btnSearchBlue nonHover" id="btnSearch"><spring:message code='Cache.btn_search' /></a> <!-- 검색 -->
						<!-- <span class="TopCont_option">
							<input id="vChk" value="" type="checkbox">
							<label for="vChk">미정 업무 보기</label>
						</span> -->
						</div>
						<div class="myTask_btn btn">
							<a style="display:none" href="#" class="btnTypeDefault btnPlus" onclick="collabTodo.myTaskList.pop();"></a>
						<%if (RedisDataUtil.getBaseConfig("CollabGantt").equals("Y")){ %>
							<a href="#" class="btnListView listViewType05"  data-tab="dttab-1" data-view="GANTN" title="<spring:message code='Cache.lbl_GantChart'/>"><spring:message code='Cache.lbl_GantChart'/></a> <!-- 간트차트 -->
						<%}%>	
						<%if (RedisDataUtil.getBaseConfig("isUseCollabSchedule").equals("Y")){ %>
							<a href="#" class="btnListView listViewType06"  data-tab="dttab-2" data-view="CAL" title="<spring:message code='Cache.lbl_LookCalendar'/>"><spring:message code='Cache.lbl_LookCalendar'/></a> <!-- 캘린더형보기 -->
						<%}%>
							<a href="#" class="btnListView listViewType01"  data-tab="dttab-3" data-view="LIST" data-mode="STAT" title="<spring:message code='Cache.lbl_LookList'/>"><spring:message code='Cache.lbl_LookList'/></a> <!-- 리스트보기 -->
							<a href="#" class="btnListView listViewType02 active"  data-tab="dttab-3"  data-view="KANB" data-mode="STAT" title="<spring:message code='Cache.lbl_LookCanban'/>"><spring:message code='Cache.lbl_LookCanban'/></a> <!-- 칸반형보기 -->

							<a href="#" class="btnRefresh" title="<spring:message code='Cache.btn_Refresh'/>"></a> <!-- 새로고침 -->
							<a href="#" class="btnTypeDefault btnExcel" title="<spring:message code='Cache.btn_ExcelDownload'/>"></a> <!-- 엑셀 다운로드 -->
						</div>
					</div>
					<div class="container-fluid" id="dttab-1" >
						<div class="gannt-container"></div>
					</div>
					<div class="container-fluid" id="dttab-2" >
						<div class="calendarWrap">
							<div id="calPlan" class="calMonthWrap selected">
								<div class="calMonHeader">
									<table class="calMonTbl" cellpadding="0" cellspacing="0">
										<tbody>
											<tr>
												<th class="sun"><spring:message code='Cache.lbl_sch_sun'/></th> <!-- 일 -->
												<th><spring:message code='Cache.lbl_sch_mon'/></th> <!-- 월 -->
												<th><spring:message code='Cache.lbl_sch_tue'/></th> <!-- 화 --> 
												<th><spring:message code='Cache.lbl_sch_wed'/></th> <!-- 수 --> 
												<th><spring:message code='Cache.lbl_sch_thu'/></th> <!-- 목 --> 
												<th><spring:message code='Cache.lbl_sch_fri'/></th> <!-- 금 --> 
												<th><spring:message code='Cache.lbl_sch_sat'/></th> <!-- 토 --> 
											</tr>
										</tbody>
									</table>
								</div>
								<div class="calMonBody">
									<c:forTokens var="week" items="1,2,3,4,5" delims=",">
									<div class="calMonWeekRow" style="min-height:178px">
										<c:forTokens var="type" items="FirstLine,Bg" delims=",">
										<table class="calGrid ${type}" cellpadding="0" cellspacing="0">
											<tbody>
												<c:forTokens var="rows" items="1,2,3" delims=",">
													<tr>
														<c:forTokens var="cols" items="1,2,3,4,5,6,7" delims=",">
															<td></td>
														</c:forTokens>
													</tr>
												</c:forTokens>
											</tbody>
										</table>
										</c:forTokens>
										<table class="monShcList" cellpadding="0" cellspacing="0">
											<tbody>
												<tr>
													<td class="sun"><strong></strong></td>
													<td class=""><strong></strong></td>
													<td class=""><strong></strong></td>
													<td class=""><strong></strong></td>
													<td class=""><strong></strong></td>
													<td class=""><strong></strong></td>
													<td class="sat"><strong></strong></td>
												</tr>
											</tbody>
										</table>
									</div>
									</c:forTokens>
								</div>

							</div>
						</div>
					</div>
					<div class="container-fluid mycard-fluid active" id="dttab-3" >
						<div class="row">
						</div>
					</div>
				</div>
				<div id="tstab-2" class="tstab_cont">
					<div class="Project_top">
						<div class="Project_filter tag" id="myFile_tag">
							<!--  <input type="text" list="fileTag" id="fileTagInput" value='#<spring:message code='Cache.lbl_all' />'/>-->
							<select id="fileTag" class="selectType02">
								<option data="#" data-opt='0'><spring:message code='Cache.lbl_subject'/></option> <!-- 제목 -->
								<option data="#" data-opt='1'><spring:message code='Cache.lbl_TaskName'/></option>
								<option data="" selected>#<spring:message code='Cache.lbl_all' /></option>
								<c:forEach var="list" items="${tag}">
									<c:if test="${list.TagType == 'FILE' }">
										<option data="${list.TagSeq}">#${list.TagName}</option>
									</c:if>
								</c:forEach>
							</select>	
							<div class="dateSel type02">
								<input type="text" name="searchFile" id="searchFile" disabled>
							</div>
				            <a href="#" class="btnTypeDefault btnSearchBlue nonHover" id="btnSearchFile"><spring:message code='Cache.btn_search' /></a> <!-- 검색 -->
						</div>
						<div class="Project_btn btn">
							<a href="#" class="btnListView listViewType01" data-tab="ftab-1" data-view="LIST"><spring:message code='Cache.lbl_LookList'/></a> <!-- 리스트보기 -->
							<a href="#" class="btnListView listViewType02 active" data-tab="ftab-2" data-view="KANB"><spring:message code='Cache.lbl_LookCanban'/></a> <!-- 칸반형보기 -->
						</div>
					</div>
					<div class="container-fluid" id="ftab-1">
						<div class="WebHardListType01 fileList01">
						<table cellpadding="0" cellspacing="0" class="CollabTable">
							<thead>
								<tr>
									<th style="width:50px"><spring:message code='Cache.lbl_delete'/></th> <!-- 삭제 -->
									<th><spring:message code='Cache.lbl_project_name' /></th>
									<th><spring:message code='Cache.lbl_sectionName' /></th>
									<th><spring:message code='Cache.lbl_workname' /></th>
									<th style="width:80px"><spring:message code='Cache.lbl_kind' /></th> <!-- 종류 -->
									<th><spring:message code='Cache.lbl_CollabName' /></th> <!-- 명칭 -->
									<th style="width:80px"><spring:message code='Cache.lbl_Size' /></th> <!-- 크기 -->
									<th style="width:120px"><spring:message code='Cache.lbl_RegDate' />(GMT+9)</th> <!-- 등록일 -->
								</tr>
							</thead>
							<tbody>
							</tbody>	
						</table>
						</div>
					</div>
					<div class="container-fluid active" id="ftab-2">
						<div class="WebHardListType02 fileList02">
							<div class="WebHardListType02_div kanb"></div>
						</div>
					</div>
				</div>
				<div id="tstab-3" class="tstab_cont">
					<!-- Start Tag Area -->
					<div class="Project_top">
						<div class="Project_filter tag" id="myApproval_tag">
							<!--  <input type="text" list="approvalTag" id="approvalTagInput" value='#<spring:message code='Cache.lbl_all' />'/>-->
							<select id="approvalTag" class="selectType02">
								<option data="#" data-opt='1'><spring:message code='Cache.lbl_subject'/></option> <!-- 제목 -->
								<option data="" selected>#<spring:message code='Cache.lbl_all' /></option>
								<c:forEach var="list" items="${tag}">
									<c:if test="${list.TagType == 'APPROVAL' }">
										<option data="${list.TagSeq}">#${list.TagName}</option>
									</c:if>
								</c:forEach>
							</select>
							<div class="dateSel type02">
								<input type="text" name="searchApproval" id="searchApproval" disabled>
							</div>
				            <a href="#" class="btnTypeDefault btnSearchBlue nonHover" id="btnSearchApproval"><spring:message code='Cache.btn_search' /></a> <!-- 검색 -->
						</div>
						<div class="Project_btn btn">
							<a href="#" class="btnListView listViewType01" data-tab="atab-1" data-view="LIST"><spring:message code='Cache.lbl_LookList'/></a> <!-- 리스트보기 -->
							<a href="#" class="btnListView listViewType02 active" data-tab="atab-2" data-view="KANB"><spring:message code='Cache.lbl_LookCanban'/></a> <!-- 칸반형보기 -->
						</div>
					</div>
					<!-- End Tag Area -->
					<div class="container-fluid" id="atab-1">
						<div class="approval_area tblList list">
							<table cellpadding="0" cellspacing="0" class="CollabTable">
								<thead>
									<tr>
										<th><spring:message code='Cache.lbl_project_name' /></th>
										<th><spring:message code='Cache.lbl_sectionName' /></th>
										<th style="width:200px"><spring:message code='Cache.lbl_apv_writer'/></th> <!-- 기안자 -->
										<th><spring:message code='Cache.lbl_Title'/></th> <!-- 제목 -->
										<th style="width:150px"><spring:message code='Cache.lbl_apv_reqdate'/></th> <!-- 기안일 -->
									</tr>
								</thead>
								<tbody>
								</tbody>	
							</table>
						</div>
						<!-- List -->
					</div>
					<div class="container-fluid active" id="atab-2">
						<div class="approval_area kanb"></div>
						<!-- Kanban -->
					</div>
				</div>
				<div id="tstab-4" class="tstab_cont">
					<div class="Project_top">
						<div class="Project_filter tag" id="mySurvey_tag">
							<!--  <input type="text" list="surveyTag" id="surveyTagInput" value='#<spring:message code='Cache.lbl_all' />'/>-->
							<select id="surveyTag" class="selectType02">
								<option data="#" data-opt='1'><spring:message code='Cache.lbl_subject'/></option> <!-- 제목 -->
								<c:forEach var="list" items="${tag}">
									<c:if test="${list.TagType == 'SURVEY' }">
										<option data="${list.TagSeq}"<c:if test="${list.TagSeq == 'ProcSurvey' }"> selected</c:if>>#${list.TagName}</option>
									</c:if>
								</c:forEach>
							</select>
							<div class="dateSel type02">
								<input type="text" name="searchSurvey" id="searchSurvey" disabled>
							</div>
				            <a href="#" class="btnTypeDefault btnSearchBlue nonHover" id="btnSearchSurvey"><spring:message code='Cache.btn_search' /></a> <!-- 검색 -->
				            <spring:message code='Cache.msg_searchTitProceedOnly' /> <!-- 제목검색은 진행중인 설문만 검색됩니다. -->
						</div>	
						<div class="Project_btn btn">
							<a href="#" class="btnListView listViewType01" data-tab="stab-1" data-view="LIST"><spring:message code='Cache.lbl_LookList'/></a> <!-- 리스트보기 -->
							<a href="#" class="btnListView listViewType02 active" data-tab="stab-2" data-view="KANB"><spring:message code='Cache.lbl_LookCanban'/></a> <!-- 칸반형보기 -->
						</div>
					</div>
					<div class="container-fluid" id="stab-1">
						<div class="survey_area tblList list">
							<table cellpadding="0" cellspacing="0" class="CollabTable">
								<thead>
									<tr>
										<th><spring:message code='Cache.lbl_Title'/></th> <!-- 제목 -->
										<th style="width:200px"><spring:message code='Cache.lbl_Survey_period'/></th> <!-- 설문기간 -->
										<th style="width:150px"><spring:message code='Cache.lbl_Register'/></th> <!-- 등록자 -->
										<th style="width:200px"><spring:message code='Cache.lbl_rate'/></th> <!-- 참여율 -->
										<th style="width:200px"></th>
									</tr>
								</thead>
								<tbody>
								</tbody>	
							</table>
						</div>
					</div>
					<div class="container-fluid active" id="stab-2">
						<div class="survey_area kanb"></div>
					</div>
				</div>
				<div id="tstab-5" class="tstab_cont">
					<!-- 목록보기-->
					<div class="myTask_top">
						<div class="myTask_btn" id="rpTab">
							<a href="#" class="btnListView listViewType07 active" data-tab="rptab-1" data-view="day"><spring:message code='Cache.lbl_Daily'/></a> <!-- 일간 -->
							<a href="#" class="btnListView listViewType08" data-tab="rptab-2" data-view="week"><spring:message code='Cache.lbl_Weekly'/></a> <!-- 주간 -->
						</div>
					</div>
					<div class="bsReportArea bsReport_day" id="rptab-1">
						<div class="bsReport_l">
							<div class="bsReport_top">
								<h3 class="bsTit"><spring:message code='Cache.BizSection_Report'/></h3> <!-- 업무보고 -->
								<div class="calBtn" id="reportAddCal">
									<strong class="title"><fmt:formatDate value="${today}" pattern="yyyy.MM.dd" /></strong>
									<div class="pagingType02">
										<a href="#" class="pre dayChg" data-paging="-" data-type="day"></a>
										<a href="#" class="next dayChg" data-paging="+" data-type="day"></a>
										<a href="#" class="btnTypeDefault calendartoday" data-type="day"><spring:message code='Cache.lbl_Todays'/></a>
									</div>
								</div>
							</div>
							<!-- 업무상태 - 대기:bs_state01, 시작:bs_state02, 진행:bs_state03, 보류:bs_state04, 완료:bs_state05 -->
							<div class="reportList01">
								<div style="height: auto;">
									<table cellpadding="0" cellspacing="0" class="CollabTable" id="reportDayTableContents">
										<colgroup>
											<col width="5%" style="">
											<col width="20%" style="" >
											<col width="20%" style="" >
											<col width="20%" style="">
											<col width="12%" style="">
											<col width="7%" style="">
											<col width="*" style="">
										</colgroup>
										<thead>
										<tr>
											<th><input type="checkbox" name="checkAll" class="gridCheckBox gridCheckBox_colHead_colSeq0" id="reportCheckAll"></th>
											<th><spring:message code='Cache.lbl_project_name' /></th>
											<th><spring:message code='Cache.lbl_sectionName' /></th>
											<th><spring:message code='Cache.lbl_prj_workName' /></th>
											<th><spring:message code='Cache.lbl_ProgressRate' /></th>
											<th><spring:message code='Cache.lbl_Time'/></th>
											<th><spring:message code='Cache.lbl_Remark' /></th>
										</tr>
										</thead>
										<tbody>
										</tbody>
									</table>
									<div class="AXgridPageBody" style="z-index:1;">
										<div class="AXgridStatus" id="reportDayListCnt"><b>0</b> <spring:message code='Cache.lbl_Count' /></div> <!-- 개 -->
										<div style="text-align:center;margin-top:2px;" id="reportDayListPageDiv">
											<input type="button" class="AXPaging_begin"><input type="button" class="AXPaging_prev"><input type="button" value="1" style="width:20px;" class="AXPaging Blue"><input type="button" value="2" style="width:20px;" class="AXPaging "><input type="button" value="3" style="width:20px;" class="AXPaging "><input type="button" value="4" style="width:20px;" class="AXPaging "><input type="button" value="5" style="width:20px;" class="AXPaging "><input type="button" class="AXPaging_next"><input type="button" class="AXPaging_end">
										</div>
									</div>
								</div>
								<div class="btn_area">
									<div class="btn_r">
										<a href="#" class="btnTypeDefault btnTypeBg" id="deleteReportDay"><spring:message code='Cache.lbl_dailyreport' /> <spring:message code='Cache.btn_delete' /></a> <!-- 일일업무보고 삭제 -->
									</div>
								</div>
							</div>
						</div>
						<div class="bsReport_r">
							<div class="bsReport_top">
								<h3 class="bsTit"><spring:message code='Cache.lbl_MyWork' /></h3> <!-- 내업무 -->
							</div>
							<div class="reportList01">
								<div style="height: auto;"><a id="boxGrid_AX_grid_focus" href="#axtree"></a>
									<table cellpadding="0" cellspacing="0" class="CollabTable" id="taskDayTableContents">
										<colgroup>
											<col width="5%" style="">
											<col width="20%" style="" >
											<col width="20%" style="" >
											<col width="20%" style="">
											<col width="12%" style="">
											<col width="*" style="">
										</colgroup>
										<thead>
										<tr>
											<th><input type="checkbox" name="checkAll" class="gridCheckBox gridCheckBox_colHead_colSeq0" id="taskCheckAll"></th>
											<th><spring:message code='Cache.lbl_project_name' /></th>
											<th><spring:message code='Cache.lbl_sectionName' /></th>
											<th><spring:message code='Cache.lbl_prj_workName' /></th>
											<th><spring:message code='Cache.lbl_ProgressRate' /></th>
											<th><spring:message code='Cache.lbl_Remark' /></th>
										</tr>
										</thead>
										<tbody>
										</tbody>
									</table>
									<div class="AXgridPageBody" style="z-index:1;">
										<div class="AXgridStatus" id="taskDayListCnt"><b>0</b> <spring:message code='Cache.lbl_Count' /></div> <!-- 개 -->
										<div style="text-align:center;margin-top:2px;" id="taskDayListPageDiv">
											<input type="button" class="AXPaging_begin"><input type="button" class="AXPaging_prev"><input type="button" value="1" style="width:20px;" class="AXPaging Blue"><input type="button" value="2" style="width:20px;" class="AXPaging "><input type="button" value="3" style="width:20px;" class="AXPaging "><input type="button" value="4" style="width:20px;" class="AXPaging "><input type="button" value="5" style="width:20px;" class="AXPaging "><input type="button" class="AXPaging_next"><input type="button" class="AXPaging_end">
										</div>
									</div>
								</div>
								<div class="btn_area">
									<div class="btn_r">
										<a href="#" class="btnTypeDefault btnTypeBg" id="addReportDay"><spring:message code='Cache.lbl_dailyreport' /> <spring:message code='Cache.lbl_Registor' /></a> <!-- 일일업무보고 등록 -->
									</div>
								</div>
							</div>
						</div>
					</div>
					<div class="bsReportArea bsReport_week" id="rptab-2" style="display: none;">
						<div class="bsReport_l">
							<div class="bsReport_top">
								<div class="calBtn" id="reportAddCal">
									<strong class="title"></strong>
									<div class="pagingType02">
										<a href="#" class="pre dayChg" data-paging="-" data-type="week"></a>
										<a href="#" class="next dayChg" data-paging="+" data-type="week"></a>
										<a href="#" class="btnTypeDefault calendartoday" data-type="week"><spring:message code='Cache.lbl_Todays'/></a>
									</div>
								</div>
								<div class="bsSel">
									<select class="selectType02" id="reportWeekProjectList">
									</select>
								</div>
							</div>
							<div class="reportList01">
								<div class="AXGrid"  style="overflow:hidden;height:auto;">
									<table cellpadding="0" cellspacing="0" class="CollabTable" id="reportWeekTableContents">
										<colgroup>
											<col width="90" style="">
											<col width="120" style="">
											<col width="100%" style="">
											<col width="70" style="">
											<col width="70" style="">
											<col width="90" style="">
										</colgroup>
										<thead>
										<tr>
											<th><spring:message code='Cache.lbl_apv_date2' /></th> <!-- 일자 -->
											<th><spring:message code='Cache.lbl_sectionName' /></th>
											<th><spring:message code='Cache.lbl_prj_workName' /></th>
											<th><spring:message code='Cache.lbl_ProgressRate' /></th>
											<th><spring:message code='Cache.lbl_Time' /></th> <!-- 시간 -->
											<th><spring:message code='Cache.lbl_Remark' /></th>
										</tr>
										</thead>
										<tbody>
										</tbody>
									</table>
									<div class="AXgridPageBody" style="z-index:1;">
										<div class="AXgridStatus" id="reportWeekListCnt"><b>0</b> <spring:message code='Cache.lbl_Count' /></div> <!-- 개 -->
										<div style="text-align:center;margin-top:2px;" id="reportWeekListPageDiv">
											<input type="button" class="AXPaging_begin"><input type="button" class="AXPaging_prev"><input type="button" value="1" style="width:20px;" class="AXPaging Blue"><input type="button" value="2" style="width:20px;" class="AXPaging "><input type="button" value="3" style="width:20px;" class="AXPaging "><input type="button" value="4" style="width:20px;" class="AXPaging "><input type="button" value="5" style="width:20px;" class="AXPaging "><input type="button" class="AXPaging_next"><input type="button" class="AXPaging_end">
										</div>
									</div>
									
								</div>
							</div>
						</div>		
						<div class="bsReport_r">
							<div class="bsReport_top">
								<h4 class="bsTit_s"><spring:message code='Cache.lbl_WeeklyReportDetail' /></h4> <!-- 주간보고 상세입력 -->
							</div>
							<div class="reportList01">
								<div class="collabo_table_wrap mb20">
									<table class="collabo_table" cellpadding="0" cellspacing="0">
										<colgroup>
											<col width="106">
											<col width="*">
										</colgroup>
										<tbody>
										<tr>
											<th><spring:message code='Cache.lbl_ConAndIssue' /></th> <!-- 내용/이슈 -->
											<td><textarea name="weekRemark" id="weekRemark" cols="30" rows="6"></textarea></td>
										</tr>
										<tr>
											<th><spring:message code='Cache.lbl_prj_nextWeekPlan' /></th> <!-- 차주계획 -->
											<td><textarea name="nextPlan" id="nextPlan" cols="30" rows="6"></textarea></td>
										</tr>
										</tbody>
									</table>
								</div>
								<div class="btn_area">
									<!-- 초기 화면 -->
									<div class="center">
										<a href="#" class="btnTypeDefault btnTypeBg" id="addReportWeek"><spring:message code='Cache.btn_register'/></a>
										<a href="#" class="btnTypeDefault btnTypeBg" id="updateReportWeek" style="display: none"><spring:message code='Cache.btn_save'/></a>
										<a href="#" class="btnTypeDefault" id="deleteReportWeek" style="display: none"><spring:message code='Cache.btn_delete'/></a>
									</div>
									<!-- 저장후 화면 style제거하시고 적용
									<div class="center" style="display:none;">
										<a href="#" class="btnTypeDefault btnTypeBg">보고</a>
									</div>
									<div class="center" style="display:none;">
										<a href="#" class="btnTypeDefault btnTypeBg">회수</a>
										<a href="#" class="btnTypeDefault">취소</a>
									</div>
									-->
								</div>
								<input type="hidden" name="reportSeq" id="reportSeq"/>
								<input type="hidden" id="taskListPageNo" value="1" />
								<input type="hidden" id="reportListPageNo" value="1" />
								<input type="hidden" id="reportWeekListPageNo" value="1" />
							</div>
						</div>
					</div>
				</div>
			</div>
			<a href="#" class="btn_mySlide"></a>
		</div>
		<!-- 컨텐츠 끝 -->
    </div>
<script>
var collabTodo= {
		pageSize : 10,
    	objectInit : function (){
	   		this.addEvent();
        },
        addEvent:function(){
        	//popup창
        	$(document).off('click','#reportDayTableContents .icoReportPop').on('click','#reportDayTableContents .icoReportPop',function(){
        		collabUtil.openReportDayPopup('CollabReportSavePopup', 'todo', $(this).data("daySeq"), $(this).data("daySeq"));
        	});
        	$(document).off('click','#taskDayTableContents .icoTaskPop').on('click','#taskDayTableContents .icoTaskPop',function(){
        		collabUtil.openTaskPopup('CollabReportSavePopup', 'todo', $(this).data("taskSeq"),  $(this).data("taskSeq"));
        	});
        	$(document).off('click','#reportWeekTableContents .icoReportPop').on('click','#reportWeekTableContents .icoReportPop',function(){
        		collabUtil.openReportDayPopup('CollabReportSavePopup', '', 'todo', $(this).data("daySeq"));
        	});
        	
        	/* 업무보고(일일,주간) */
			$('#todo #rpTab a').click(function () {
				var tab_id = $(this).attr('data-tab');
			
				var today = CFN_GetLocalCurrentDate("yyyy.MM.dd");
			
				if (tab_id == 'rptab-1') {
					$("#todo #rptab-1 #reportAddCal .title").text(today);
					$("#todo #rptab-2").hide();
					$("#todo #rptab-1").show();
					collabTodo.getUserReportDay(1);
				} else {
					var sunday = AttendUtils.getWeekStart(CFN_GetLocalCurrentDate("yyyy-MM-dd"), 0)
					var sDate = schedule_SetDateFormat(sunday, '.');
					var eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '.');
					$("#todo #rptab-2 #reportAddCal .title").data({"sDate":sDate,"eDate":eDate});
					$("#todo #rptab-2 #reportAddCal .title").text(sDate + " ~ " + eDate+ " ["+getWeekNo(sDate)+"<spring:message code='Cache.lbl_TheWeek' />]"); //주차
					$("#todo #rptab-1").hide();
					$("#todo #rptab-2").show();
					collabTodo.getWeekProject();
				}
			
				$('#todo #rpTab a').removeClass('active');
				$(this).addClass('active');
			
			});
			
			//업무보고 이전
			$('#todo #reportAddCal .pre').on('click',function(e){

				if ($(this).attr('data-type') == 'day'){
					var currentDateText = coviCmn.getDateFormat($("#todo #rptab-1 #reportAddCal .title").text(),"-");
					var currentDate = new Date(currentDateText)
					var preDate = new Date(currentDate.setDate(currentDate.getDate() - 1));
					$("#todo #rptab-1 #reportAddCal .title").text(schedule_SetDateFormat(preDate, '.'));
					collabTodo.getUserReportDay(1 );
				} else {
					var sDate = schedule_SetDateFormat(schedule_AddDays($("#todo #rptab-2 #reportAddCal .title").data("sDate"), -7), '.');
					var eDate = schedule_SetDateFormat(schedule_AddDays($("#todo #rptab-2 #reportAddCal .title").data("eDate"), -7), '.');
					
					$("#todo #rptab-2 #reportAddCal .title").data({"sDate":sDate,"eDate":eDate});
					$("#todo #rptab-2 #reportAddCal .title").text(sDate + " ~ " + eDate + " ["+getWeekNo(sDate)+"<spring:message code='Cache.lbl_TheWeek' />]"); //주차
					collabTodo.getWeekProject( 1);
				}
			
			});
			
			//업무보고 이후
			$('#todo #reportAddCal .next').on('click', function(e){
				if ($(this).attr('data-type') == 'day'){
					var currentDateText = coviCmn.getDateFormat($("#todo #rptab-1 #reportAddCal .title").text(),"-");
					var currentDate = new Date(currentDateText)
					var nextDate = new Date(currentDate.setDate(currentDate.getDate() + 1));
					$("#todo #rptab-1 #reportAddCal .title").text(schedule_SetDateFormat(nextDate, '.'));
					collabTodo.getUserReportDay(1 );
				} else {
					var sDate = schedule_SetDateFormat(schedule_AddDays($("#todo #rptab-2 #reportAddCal .title").data("sDate"), 7), '.');
					var eDate = schedule_SetDateFormat(schedule_AddDays($("#todo #rptab-2 #reportAddCal .title").data("eDate"), 7), '.');
					
					$("#todo #rptab-2 #reportAddCal .title").data({"sDate":sDate,"eDate":eDate});
					$("#todo #rptab-2 #reportAddCal .title").text(sDate + " ~ " + eDate + " ["+getWeekNo(sDate)+"<spring:message code='Cache.lbl_TheWeek' />]"); //주차
					collabTodo.getWeekProject( 1);
				}
			});
			
			//오늘
			$('#todo #reportAddCal .calendartoday').on('click', function(e){
				var today = CFN_GetLocalCurrentDate("yyyy.MM.dd");
			
				if ($(this).attr('data-type') == 'day') {
					$("#todo #rptab-1 #reportAddCal .title").text(today);
					collabTodo.getUserReportDay(1);
				} else {
					var sunday = AttendUtils.getWeekStart(CFN_GetLocalCurrentDate("yyyy-MM-dd"), 0)
					var sDate = schedule_SetDateFormat(sunday, '.');
					var eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '.');

					$("#todo #rptab-2 #reportAddCal .title").data({"sDate":sDate,"eDate":eDate});
					$("#todo #rptab-2 #reportAddCal .title").text(sDate + " ~ " + eDate+ " ["+getWeekNo(sDate)+"<spring:message code='Cache.lbl_TheWeek' />]"); //주차
					collabTodo.getWeekProject( 1);
				}
			
			});
			
			//주간업무보고 프로젝트 변경
			$("#todo #reportWeekProjectList").change(function(e) {
				$("#todo #reportWeekListPageNo").val(1);
				collabTodo.getUserReportWeek(1);
			});
			
			//일일업무보고 전체선택
			$('#todo #reportCheckAll').on('click', function(e){
				collabUtil.checkAll($("#todo #reportDayTableContents"), $(this).prop("checked"));
			});
			
			//업무 전체선택
			$('#todo #taskCheckAll').on('click', function(e){
				collabUtil.checkAll($("#todo #taskDayTableContents"), $(this).prop("checked"));
			});
			
			//일일업무보고 삭제
			$('#todo #deleteReportDay').on('click', function(e){
				var daySeqList = "";
				$('#todo #reportDayTableContents tbody input:checkbox').each(function() {
					if($(this).prop("checked")) {
						//alert($(this).val());
						daySeqList += $(this).val() + ";";
					}
				});
			
				if(daySeqList == "") {
					alert("<spring:message code='Cache.msg_NoBusinessReport' />"); //선택된 업무보고가 없습니다
					return;
				} else {
					$.ajax({
						type: "POST",
						url: "/groupware/collabReport/deleteReportDay.do",
						data:{
							"daySeqList" : daySeqList
						},
						success: function(data){
							alert("<spring:message code='Cache.msg_deleteBusinessReport'/>"); //선택한 업무보고가 삭제되었습니다.
							collabTodo.getUserReportDay(1);
						},
						error: function(request, status, error){
							Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
						}
					});
				}
			});
			
			//일일업무보고 등록
			$("#todo #addReportDay").on('click', function(e){
				var taskSeqList = "";
				$('#todo #taskDayTableContents tbody input:checkbox').each(function() {
					if($(this).prop("checked")) {
						taskSeqList += $(this).val() + ";";
					}
				});

				if(taskSeqList == "") {
					alert("<spring:message code='Cache.msg_NoSelectTask' />"); //선택된 업무가 없습니다.
					return;
				} else {
					var currentDateText = $("#todo #rptab-1 #reportAddCal .title").text();
					$.ajax({
						type: "POST",
						url: "/groupware/collabReport/addReportDay.do",
						data:{
							"reportDate": schedule_SetDateFormat(currentDateText, '')
							, "taskSeqList": taskSeqList
						},
						success: function(data){
							alert("<spring:message code='Cache.msg_RegBusinessReport' />"); //선택한 업무보고가 일일업무보고로 등록 되었습니다.
			
							collabTodo.getUserReportDay(1);
						},
						error: function(request, status, error){
							Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
						}
					});
				}
			});
			
			//주간업무보고 삭제
			$('#deleteReportWeek').on('click', function(e){
				$.ajax({
					type: "POST",
					url: "/groupware/collabReport/deleteReportWeek.do",
					data:{
						"reportSeq" : $("#todo #rptab-2 #reportSeq").val()
					},
					success: function(data){
						alert("<spring:message code='Cache.msg_DeleteWeeklyReport' />"); //주간보고가 삭제 되었습니다.
						collabTodo.getUserReportWeek(1);
					},
					error: function(request, status, error){
						Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
					}
				});
			});
			
			//주간업무보고 수정
			$('#updateReportWeek').on('click', function(e){
				if($("#todo #weekRemark").val() == "" || $("#todo #nextPlan").val() == "") {
					alert("<spring:message code='Cache.msg_PleaseReport' />"); //보고내용을 입력하세요.
					return;
				} else {
					$.ajax({
						type: "POST",
						url: "/groupware/collabReport/updateReportWeek.do",
						data: {
							"weekRemark": $("#todo #rptab-2 #weekRemark").val()
							, "nextPlan": $("#todo #rptab-2 #nextPlan").val()
							, "reportSeq": $("#todo #rptab-2 #reportSeq").val()
						},
						success: function (data) {
							alert("<spring:message code='Cache.msg_RevisedWeeklyReport' />"); //주간보고가 수정 되었습니다.
							collabTodo.getUserReportWeek(1);
						},
						error: function (request, status, error) {
							Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error);
						}
					});
				}
			});
			
			//주간업무보고 등록
			$('#addReportWeek').on('click', function(e){
				var startDate = $("#rptab-2 #reportAddCal .title").data("sDate");
				var endDate   = $("#rptab-2 #reportAddCal .title").data("eDate");

				if($("#todo #rptab-2 #weekRemark").val() == "" || $("#todo #rptab-2 #nextPlan").val() == "") {
					alert("<spring:message code='Cache.msg_PleaseReport' />"); //보고내용을 입력하세요.
					return;
				} else {
					$.ajax({
						type: "POST",
						url: "/groupware/collabReport/addReportWeek.do",
						data: {
							"startDate": schedule_SetDateFormat(startDate, '')
							, "endDate": schedule_SetDateFormat(endDate, '')
							, "prjSeq": $("#todo #rptab-2 #reportWeekProjectList option:selected").val()
							, "prjType": $("#todo #rptab-2 #reportWeekProjectList option:selected").attr("data-type")
							, "weekRemark": $("#todo #rptab-2 #weekRemark").val()
							, "nextPlan": $("#todo #rptab-2 #nextPlan").val()
						},
						success: function (data) {
							collabTodo.getUserReportWeek(1);
						},
						error: function (request, status, error) {
							Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error);
						}
					});
				}
			});
        },
    	getUserReportDay: function(pageNo){
			collabTodo.getUserReportDayList(1);
			collabTodo.getUserTaskDayList(1);
    	},//일일업무보고 조회
    	getUserReportDayList: function(pageNo) {
			$("#todo #reportListPageNo").val(pageNo);
    		var currentDateText = $("#todo #rptab-1 #reportAddCal .title").text();
    		$.ajax({
    			type: "POST",
    			url: "/groupware/collabReport/getUserReportDayList.do",
    			data: {
    				"reportDate": schedule_SetDateFormat(currentDateText, '')
    				,"pageNo" : $("#todo #reportListPageNo").val()
    				,"pageSize" : collabTodo.pageSize
    			},
    			success: function (data) {
    				collabTodo.loadUserReportDayList(data);
    			},
    			error: function (request, status, error) {
    				Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error);
    			}
    		});
    	},////내업무 목록 조회
    	getUserTaskDayList: function(pageNo) {
			$("#todo #taskListPageNo").val(pageNo);
    		var currentDateText = $("#todo #rptab-1 #reportAddCal .title").text();
    		$.ajax({
    			type: "POST",
    			url: "/groupware/collabReport/getUserTaskDayList.do",
    			data: {
    				"reportDate": schedule_SetDateFormat(currentDateText, '')
    				,"pageNo" : $("#todo #taskListPageNo").val()
    				,"pageSize" : collabTodo.pageSize
    			},
    			success: function (data) {
    				collabTodo.loadUserTaskDayList(data);
    			},
    			error: function (request, status, error) {
    				Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error);
    			}
    		});
    	},    	//v프로젝트 리스트
    	getWeekProject:function(){

	    	$.ajax({
				type: "POST",
				url: "/groupware/collabReport/getUserReportWeekProjectList.do",
				data: {
					"startDate": schedule_SetDateFormat($("#todo #rptab-2 #reportAddCal .title").data("sDate"), '')
					, "endDate": schedule_SetDateFormat($("#todo #rptab-2 #reportAddCal .title").data("eDate"), '')
				},
				success: function (data) {
					$("#todo #rptab-2 #reportWeekProjectList").empty();
					if (data.reportWeekProjectList != null && data.reportWeekProjectList.length != 0) {
						for (var i = 0; i < data.reportWeekProjectList.length; i++) {
							var reportWeekProject = data.reportWeekProjectList[i];
							var option = "<option value='" + reportWeekProject.PrjSeq + "' data-type='" + reportWeekProject.PrjType + "'>" + (reportWeekProject.PrjType == "P"?"[P]":"[T]") + reportWeekProject.PrjName + (reportWeekProject.PrjType.substring(0,1)=="K"?"[KR]":"") + "</option>";
							$("#todo #rptab-2 #reportWeekProjectList").append(option);
						}
					}
					collabTodo.getUserReportWeek(1);
				},
				error: function (request, status, error) {
					Common.Error(Common.getDic("msg_ErrorOccurred") + "code:" + request.status + "\n" + "message:" + request.responseText + "\n" + "error:" + error);
				}
			});
    	},
        getUserReportWeek: function(pageNo){
			$("#todo #reportWeekListPageNo").val(pageNo);

    		$.ajax({
    			type: "POST",
    			url: "/groupware/collabReport/getUserReportWeekData.do",
    			data:{
    				"startDate" : schedule_SetDateFormat( $("#todo #rptab-2 #reportAddCal .title").data("sDate"), '')
    				, "endDate" : schedule_SetDateFormat( $("#todo #rptab-2 #reportAddCal .title").data("eDate"), '')
    				, "prjType" : $("#todo #rptab-2 #reportWeekProjectList option:selected").data("type")
    				, "prjSeq" : $("#todo #rptab-2 #reportWeekProjectList option:selected").val()
    				, "pageNo" : $("#todo #reportWeekListPageNo").val()
    				, "pageSize" : collabTodo.pageSize
    			},
    			success: function(data){
    				collabTodo.loadUserReportWeek(data);
    			},
    			error: function(request, status, error){
    				Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
    			}
    		});
    	},
    	goReportPage:function(sType, pageNo){
			collabTodo.getUserReportDayList(pageNo);
    	},
    	goTaskPage:function(sType, pageNo){
			collabTodo.getUserTaskDayList(pageNo);
    	},
    	goWeekListPage:function(sType, pageNo){
			collabTodo.getUserReportWeek(pageNo);
    	},//v프로젝트 리스트
    	loadUserReportWeek: function(data) {
			var obj = $(document.createDocumentFragment());
			var page = data.reportWeekListPage;
			$("#todo #reportWeekListCnt b").text(page.totalCnt);

			if (data.reportWeekList != null && data.reportWeekList.length != 0) {
				data.reportWeekList.map(function(item, idx){	
					obj.append($("<tr>")
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":coviCmn.getDateFormat(item.ReportDate)}))
							.append($("<td>",{"class":"bodyTdText","text":item.SectionName}))
							.append($("<td>",{"class":"bodyTdText"}).append($("<a>",{"class":"icoReportPop","data": {"daySeq":item.DaySeq},"html":collabUtil.getTaskStatus(item)})))
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":coviCmn.convertNull(item.ProgRate,"")}))
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":coviCmn.convertNull(item.TaskTime,"")}))
							.append($("<td>",{"class":"bodyTdText","text":coviCmn.convertNull(item.Remark,"")}))
						);
				});
				$("#todo #reportWeekListPageDiv").html(collabUtil.getPageStr(page, "collabTodo.goWeekListPage"));

			} else {
				obj.append(collabUtil.getNoList());
				$("#todo #reportWeekListPageDiv").empty();
			}

			$("#todo #reportWeekTableContents  tbody").empty().append(obj);


			if (data.reportWeekData != null && data.reportWeekData.ReportSeq != undefined && data.reportWeekData.ReportSeq != "") {
				$("#todo #rptab-2 #reportSeq").val(data.reportWeekData.ReportSeq);
				$("#todo #rptab-2 #weekRemark").val(data.reportWeekData.WeekRemark);
				$("#todo #rptab-2 #nextPlan").val(data.reportWeekData.NextPlan);
				$("#todo #rptab-2 #addReportWeek").hide();
				$("#todo #rptab-2 #updateReportWeek").show();
				$("#todo #rptab-2 #deleteReportWeek").show();
			} else {
				$("#todo #rptab-2 #reportSeq").val("");
				$("#todo #rptab-2 #weekRemark").val("");
				$("#todo #rptab-2 #nextPlan").val("");
				if (data.reportWeekList != null && data.reportWeekList.length != 0) {
					$("#todo #rptab-2 #addReportWeek").show();
					$("#todo #rptab-2 #updateReportWeek").hide();
					$("#todo #rptab-2 #deleteReportWeek").hide();
				} else {
					$("#todo #addReportWeek").hide();
					$("#todo #updateReportWeek").hide();
					$("#todo #deleteReportWeek").hide();
				}
			}
    	},
   		loadUserReportDayList: function(data) {	//일일업무보고 출력
			var obj = $(document.createDocumentFragment());
			var page = data.reportDayPage;
			$("#todo #reportDayListCnt b").text(page.totalCnt);

			if (data.reportDayList != null && data.reportDayList.length != 0) {
				data.reportDayList.map(function(item, idx){	
					var objPrjDesc = item.PrjDesc !=null && item.PrjDesc != ""? item.PrjDesc.split("^"):"";
					obj.append($("<tr>")
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center"}).html("<input type='checkbox' class='gridCheckBox_body_colSeq0' onFocus='this.blur();' id='report_chk_" + idx + "' value='" + item.DaySeq + "'>"))
							.append($("<td>",{"class":"bodyTdText","text":(objPrjDesc.length>0 ? objPrjDesc[1] +(objPrjDesc[0].substring(0,1)=="K"?"[KR]":""): "내업무") + (item.PrjCount > 1 ? " 외" : "")}))
							.append($("<td>",{"class":"bodyTdText","text":(objPrjDesc.length>0 ? objPrjDesc[3] : "") }))
							.append($("<td>",{"class":"bodyTdText"}).append($("<a>",{"class":"icoReportPop","data": {"daySeq":item.DaySeq},"html":collabUtil.getTaskStatus(item)})))
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":coviCmn.convertNull(item.ProgRate,"")}))
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":coviCmn.convertNull(item.TaskTime,"")}))
							.append($("<td>",{"class":"bodyTdText","text":coviCmn.convertNull(item.Remark,"")}))
						);
				});
				$("#todo #reportDayListPageDiv").html(collabUtil.getPageStr(page, "collabTodo.goReportPage"));

			} else {
				obj.append(collabUtil.getNoList());
				$("#todo #reportDayListPageDiv").empty();
			}

			$("#todo #reportDayTableContents  tbody").empty().append(obj);

			
    	},
    	loadUserTaskDayList: function(data) {	//내업무 출력
			var obj = $(document.createDocumentFragment());
			var page = data.taskDayPage;
			$("#todo #taskDayListCnt b").text(page.totalCnt);

			if (data.taskDayList != null && data.taskDayList.length != 0) {
				data.taskDayList.map(function(item, idx){	
					var objPrjDesc =  item.PrjDesc!= null && item.PrjDesc!= ""? item.PrjDesc.split("^"):"";
					obj.append($("<tr>")//btnReportPop
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center"}).html("<input type='checkbox' class='gridCheckBox_body_colSeq0' onFocus='this.blur();' id='report_chk_" + idx + "' value='" + item.TaskSeq + "'>"))
							.append($("<td>",{"class":"bodyTdText","text":(objPrjDesc.length>0 ? objPrjDesc[1]+(objPrjDesc[0].substring(0,1)=="K"?"[KR]":"") : "<spring:message code='Cache.lbl_MyWork' />") + (item.PrjCount > 1 ? " <spring:message code='Cache.lbl_att_and' />" : "")})) //내업무, 외
							.append($("<td>",{"class":"bodyTdText","text":(objPrjDesc.length>0 ? objPrjDesc[3] : "") }))
							.append($("<td>",{"class":"bodyTdText"}).append($("<a>",{"class":"icoTaskPop","data": {"taskSeq": item.TaskSeq},"html":collabUtil.getTaskStatus(item)})))
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":coviCmn.convertNull(item.ProgRate,"")}))
							.append($("<td>",{"class":"bodyTdText","style":"text-align:center","text":coviCmn.convertNull(item.Remark,"")}))
						);
				});
				$("#todo #taskDayListPageDiv").html(collabUtil.getPageStr(page, "collabTodo.goTaskPage"));

			} else {
				obj.html(collabUtil.getNoList(6));
				$("#todo #taskDayListPageDiv").empty();
			}

			$("#todo #taskDayTableContents  tbody").empty().append(obj);

    	},
}    

//시작
$(document).ready(function (){
	collabTodo.objectInit();
});
        
</script>