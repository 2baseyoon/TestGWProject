<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<c:set var="today" value="<%=new java.util.Date()%>" />
<div class="cRConTop titType">
	<h2 class="title">
		<a href="#" class="btn_coStar" id="btnFav" style="display:none"><spring:message code='Cache.btn_Favorite'/></a>	<!-- 즐겨찾기 -->
		<span></span>
	</h2>
	<div class="coBtn_list">
			<a href="#" class="btn_coPopup" id="prjInfo" style="display:none" title="<spring:message code='Cache.lbl_PrjOverView'/>"></a> <!-- 프로젝트 개요 -->
			<%if (RedisDataUtil.getBaseConfig("isUseCollabMessenger").equals("Y")){ %>
				<a href="#" class="btn_coTalk" id="btnChat" style="display:none" title="<spring:message code='Cache.lbl_Messanger'/>"></a> <!-- 메신저 -->
			<%}%>
			<a href="#" class="btn_coMenu" id="btnPrjFunc" style="display:none"></a>
			<div class="coMenu_list" id="column_menu">
				<!-- 복사 -->
				<a data-only="P" id="btnCopy"><spring:message code='Cache.ACC_btn_copy' /></a>
				<!--삭제 -->
				<a data-only="P" id="btnDel"><spring:message code='Cache.lbl_delete' /></a>
				<!--상세 -->
				<a data-only="P" id="btnPrjPop"><spring:message	code='Cache.lbl_change' /></a>
				<!--초대-->
				<a data-only="P" id="btnInvite"><spring:message	code='Cache.TodoMsgType_Invited' /></a>
				<!-- 인쇄 -->
				<a data-only="" id="btnPrint" style="display:none"><spring:message code='Cache.lbl_Print' /></a>
				<!-- 탬플릿으로 저장 -->
				<a data-only="P" id="btnSaveTempl"><spring:message	code='Cache.Collab_Save_Templ' /></a>
				<!-- 마감-->
				<a data-only="" id="btnClose"><spring:message	code='Cache.lbl_TaskClose' /></a>
			</div>
		</div>
</div>
<div class="cRContCollabo mScrollVH">
	<!-- 컨텐츠 시작 -->
	<div class="ProjectArea Area active">
		<div class="Project_tabList tabList">
			<ul>
				<li class="active" data-tab="tstab-1" data-type="TASK" data-view="KANB" data-mode="SEC"><a href="#n"><spring:message code='Cache.lbl_task_task' /></a></li> <!-- 업무 -->
				<li class="" data-tab="tstab-2" data-type="FILE"><a href="#n"><spring:message code='Cache.lbl_File' /></a></li> <!-- 파일 -->
<%if (RedisDataUtil.getBaseConfig("isUseCollabApproval").equals("Y")){%>
				<li class="" data-tab="tstab-3" data-type="APPROVAL"><a href="#n"><spring:message code='Cache.lbl_RelatedApproval' /></a></li> <!-- 관련 결재 -->
<%}%>
<%if (RedisDataUtil.getBaseConfig("isUseCollabSurvey").equals("Y")){ %>
				<li class="" data-tab="tstab-4" data-type="SURVEY"><a href="#n"><spring:message code='Cache.BizSection_Survey' /></a></li> <!-- 설문 -->
<%} %>
				<li class="" data-tab="tstab-5" data-type="REPORT"  style="display:none"><a href="#n"><spring:message code='Cache.BizSection_Report' /><spring:message code='Cache.lbl_Views' /></a></li> <!-- 업무보고조회 -->
			</ul>
		</div>
		<div class="Project_date" id="collab_status_date"><strong><spring:message code='Cache.lbl_all'/></strong></div>
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
				<ul>
					<p class="Project_tit">프로젝트 <spring:message code='Cache.btn_All'/></p>
					<div class="total_progress">
						<strong class="num" id="tnum">999</strong>
					</div>
					<li class="bg03">
						<a href="#" class="">
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
							<span class="txt"><spring:message code='Cache.lbl_Project' /><Br>
								<spring:message code='Cache.lbl_TFProgressing' />
							</span> <!-- 프로젝트 진행률 -->
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
		<div class="Project_tabCont tabCont">
			<div id="tstab-1" class="tstab_cont active">
				<div class="Project_top Project_top_r1">
					<div class="Project_cal cal" id="calTitle" style="display: none">
						<div class="calBtn">
							<strong class="title">2021.04</strong>
							<div class="pagingType02">
								<a href="#" class="pre dayChg" data-paging="-"></a> 
								<a href="#"	class="next dayChg" data-paging="+"></a> 
								<a href="#"	class="btnTypeDefault calendartoday"><spring:message code='Cache.lbl_Todays' /></a>
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
							<select id="selSection"></select>
							<select id="selMember"></select>
						</div>
						<ul class="calSelect" id="gantTab">
							<li data-tab="GANT"><a href="#"><spring:message code='Cache.lbl_sectionEng' /></a></li> <!-- 섹션 -->
							<li class="selected" data-tab="GANTN"><a href="#"><spring:message code='Cache.lbl_task_task' /></a></li> <!-- 업무 -->
						</ul>
					</div>
<%} %>						
					<div class="Project_filter tag" id="myTask_tag">
						<input class="adDate" type="text" id="date1" date_separator="." readonly=""> - 
						<input id="date2" date_separator="." date_startTargetID="date1" class="adDate" type="text" readonly="">
						<!--  <input type="text" list="taskTag" autocomplete="off" id="taskTagInput" value='#<spring:message code='Cache.lbl_all' />' style="border-radius: 5px 5px 0px 0px;"/>-->
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
						<!-- 
						<span class="TopCont_option">
							<input id="vChk" value="" type="checkbox" >
							<label for="vChk"><spring:message code='Cache.msg_collab12' /></label>	
						</span>
						-->
						<!--  
						<span class="TopCont_option">
							<input id="vChk" value="" type="checkbox">
							<label for="vChk">전체업무</label>
						</span>-->
					</div>	 
					<div class="Project_btn btn">
					<%if (RedisDataUtil.getBaseConfig("CollabGantt").equals("Y")){ %>
						<a href="#" class="btnListView listViewType05" data-tab="dttab-1" data-view="GANTN" data-mode="SEC"  title="<spring:message code='Cache.lbl_GantChart'/>"><spring:message code='Cache.lbl_GantChart'/></a> <!-- 간트차트 -->
					<%}%> 
					<%if (RedisDataUtil.getBaseConfig("isUseCollabSchedule").equals("Y")){ %>
						<a href="#" class="btnListView listViewType06" data-tab="dttab-2" data-view="CAL" data-mode="SEC"  title="<spring:message code='Cache.lbl_LookCalendar'/>"><spring:message code='Cache.lbl_LookCalendar'/></a> <!-- 캘린더형보기 --> 
					<%}%> 
						<a href="#" class="btnListView listViewType01" data-tab="dttab-3" data-view="LIST" data-mode="SEC" title="<spring:message code='Cache.lbl_LookList'/>"><spring:message code='Cache.lbl_LookList'/></a>  <!-- 리스트보기 -->
						<a href="#" class="btnListView listViewType02 active" data-tab="dttab-3" data-view="KANB" data-mode="SEC" title="<spring:message code='Cache.lbl_LookCanban'/>"><spring:message code='Cache.lbl_LookCanban'/></a> <!-- 칸반형보기 --> 
						<a href="#" class="btnListView listViewType09" data-tab="dttab-3" data-view="KANB" data-mode="MEM" title="<spring:message code='Cache.lbl_charge'/>"><spring:message code='Cache.lbl_charge' /></a> 
						<a href="#" class="btnListView listViewType10" data-tab="dttab-3" data-view="KANB" data-mode="STAT" title="<spring:message code='Cache.lbl_Status'/>"><spring:message code='Cache.lbl_Status' /></a> 
						<a href="#" class="btnRefresh" title="<spring:message code='Cache.btn_Refresh'/>"></a> <!-- 새로고침 -->
						<!-- <a href="#" class="btnVideo"></a> -->
						<a href="#" class="btnTypeDefault btnExcel" title="<spring:message code='Cache.btn_ExcelDownload'/>"></a> <!-- 엑셀 다운로드 -->
						<a href="#" class="btnTypeDefault btnPlus" id="btnSecPlus" title="<spring:message code='Cache.lbl_AddSection'/>" style="display:none"></a> <!-- 섹션추가 -->
					</div>
				</div>
				<div class="container-fluid" id="dttab-1">
					<div class="gannt-container"></div>
				</div>
				<div class="container-fluid" id="dttab-2">
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
								<c:forTokens var="week" items="1,2,3,4,5,6" delims=",">
									<div class="calMonWeekRow" style="min-height:178px">
										<c:forTokens var="type" items="FirstLine,Bg" delims=",">
											<table class="calGrid ${type}" cellpadding="0"
												cellspacing="0">
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
				<div class="container-fluid active card-fluid" id="dttab-3">
					<div class="row"></div>
				</div>
			</div>
			<div id="tstab-2" class="tstab_cont">
				<div class="Project_top">
					<div class="Project_filter tag" id="myFile_tag">
<!--  						<input type="text" list="fileTag" id="fileTagInput" value='#<spring:message code='Cache.lbl_all' />'/>-->
						<select id="fileTag"  class="selectType02">
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
									<th><spring:message code='Cache.ACC_lbl_projectName' /></th>
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
									<th><spring:message code='Cache.ACC_lbl_projectName' /></th>
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
						<select id="surveyTag"  class="selectType02">
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
						<a href="#" class="btnTypeDefault btnPlus" id="btnSvyPlus"></a>
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
                <div class="bsReportArea bsReport_day" id="rptab-2">
                	    <!-- 일간보고 -->
	                	<div class="bsReport_top">
	                		<h3 class="bsTit"><spring:message code='Cache.lbl_dailyreport' /></h3>
	                	</div>
	                	<div class="reportList01" style="height:auto;">
							<div class="AXGrid"  style="overflow:hidden;height:auto;">
								<table cellpadding="0" cellspacing="0" class="CollabTable" id="taskDayTableContents">
									<colgroup>
										<col width="10%" style="">
										<col width="20%" style="">
										<col width="20%" style="">
										<col width="12%" style="">
										<col width="7%" style="">
										<col width="*" style="">
									</colgroup>
									<thead>
										<tr>
											<th><spring:message code='Cache.lbl_apv_date2' /></th> <!-- 일자 -->
											<th><spring:message code='Cache.lbl_sectionName' /></th> <!-- 섹션명 -->
											<th><spring:message code='Cache.lbl_prj_workName' /></th> <!-- 업무명 -->
											<th><spring:message code='Cache.lbl_ProgressRate' /></th> <!-- 진행률 -->
											<th><spring:message code='Cache.lbl_Time' /></th> <!-- 시간 -->
											<th><spring:message code='Cache.lbl_Remark' /></th> <!-- 비고 -->
										</tr>
									</thead>
									<tbody>
										<td class="bodyTd bodyTd_0 bodyTdr_0" style="vertical-align:middle;text-align: center;" colspan="6"><spring:message code='Cache.msg_ComNoData' /></td> <!-- 조회된 데이터가 없습니다. -->
									</tbody>
								</table>
							</div>
						</div>
                        <div class="bsReport_top">
                            <h3 class="bsTit"><spring:message code='Cache.lbl_weeklyreport'/></h3> <!-- 주간업무보고 -->
                            <div class="calBtn" id="reportCal">
                                <strong class="title"></strong>
                                <div class="pagingType02">
                                    <a href="#" class="pre dayChg" data-paging="-" data-type="week"></a>
                                    <a href="#" class="next dayChg" data-paging="+" data-type="week"></a>
                                    <a href="#" class="btnTypeDefault calendartoday" data-type="week"><spring:message code='Cache.lbl_Todays'/></a>
                                </div>
                            </div>
                        </div>
                        <div class="reportList01">
							<div class="AXGrid"  style="overflow:hidden;height:auto;">
								<table cellpadding="0" cellspacing="0" class="CollabTable" id="reportWeekTableContents">
									<colgroup>
										<col width="*" style="">
										<col width="43%" style="">
										<col width="43%" style="">
									</colgroup>
									<thead>
									<tr>
										<th><spring:message code='Cache.lbl_name' /></th> <!-- 이름 -->
										<th><spring:message code='Cache.lbl_ConAndIssue' /></th> <!-- 내용/이슈 -->
										<th><spring:message code='Cache.lbl_prj_nextWeekPlan' /></th> <!-- 차주계획 -->
									</tr>
									</thead>
									<tbody>
									</tbody>
								</table>
							</div>                        	
                </div>
			</div>
		</div>
	</div>
	<a href="#" class="btn_mySlide"></a>
	<!-- 컨텐츠 끝 -->
</div>
<!-- <div style="right: -0px;width: 600px;background-color: white;position: absolute;top:0px;bottom:0;min-width: 600px;transition:top 0.5s ease;">
	<iframe id="IframePreview" name="IframePreview" frameborder="0" width="600" height="100%" scrolling="no" src="/groupware/collabTask/CollabTaskPopup.do?&taskSeq=2968&prjType=P&prjSeq=9&topTaskSeq=2968&popupID=CollabTaskPopup2968&openerID=P_9&popupYN=N&callBackFunc=&CFN_OpenWindowName=CollabTaskPopup2968"></iframe>
</div>
 -->