<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
	Cookie[] cookies = request.getCookies();
	String cookieVal = "";

	if (cookies != null) {
      	for (int i = 0 ; i < cookies.length ; i++) {
            if("CSJTK".equals(cookies[i].getName())){
            	cookieVal = cookies[i].getValue();
            }
        } 
    }
	
	String profileImagePath = RedisDataUtil.getBaseConfig("ProfileImagePath").replace("/{0}", "");
	
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<style>
	.VacationLayer .MWR_Worktypelayer.Ltype03{top: -4px;}
	.VacationLayer.active .MWR_Worktypelayer.Ltype03{display: block;}
	.OutsideWorkLayer .MWR_Worktypelayer.Ltype03{top: 20px;}
	.OutsideWorkLayer.active .MWR_Worktypelayer.Ltype03{display: block;}
	.workBtnR a{
		display: none;
	}
	#taskManageList, #TFRoomList{
		margin-top: 0;
	}
	.deptList{
		display: none;
	}
	.VacationLayer .mScrollV, .OutsideWorkLayer .mScrollV, .Overtimelayer .mScrollV, .Worktypelayer .part02 .mScrollV{
		height: 120px;
	}
	.VacationLayer .mScrollV ul, .OutsideWorkLayer .mScrollV ul, .Overtimelayer .mScrollV ul, .Worktypelayer .part02 .mScrollV ul{
		height: auto;
	}
	#MailContextMenu, #ApprovalListMenu, #ApprovalProgressMenu, #TaskFilterMenu, #ApprovalFilterMenu{
		display: none;
		position: absolute;
		z-index: 10;
	}
	#TaskFilterMenu{
		position: absolute;
		top: 27px;
		right: 31px;
	}
	#ApprovalFilterMenu{
		top: 375px;
		left: 132px;
	}
	.workportal-leftCon{
		z-index: 0;
	}
	.cycleCont > .cycleSlice > .pie {
		position:absolute;
		width:100%;
		height:100%;
		clip:rect(0em,101px,201px,0em);
		-moz-border-radius:101px;
		-webkit-border-radius:101px;
		border-radius:101px;
	}
	.cycleCont > .cycleSlice > .pie.fill {display:none;-moz-transform:rotate(180deg) !important;-webkit-transform:rotate(180deg) !important;-o-transform:rotate(180deg) !important;transform:rotate(180deg) !important;}
	.cycleCont > .cycleSlice.gt50 > .pie.fill {display:block;}
	.cycleCont > .cycleSlice {position:absolute;width:202px;height:201px;clip:rect(0px,202px,201px,101px);}
	.cycleCont > .cycleSlice.gt50 {clip:rect(auto, auto, auto, auto);}
	#channelLayer{
		width: 100%; 
		height: 624px;
		border: 0;
	}
	.nolist{
		display: none;
	}
	.ITMTeamroomListBox_image{
		background-color: white;
	}
</style>

<section class="workportalWrap">
	<!-- 시작 날짜 -->
	<input type="hidden" value="" id="p_StartDate"/>
	<!-- 종료 날짜 -->
	<input type="hidden" value="" id="p_EndDate"/>
	<!-- 게시 삭제 처리 사유 -->
	<input type="hidden" value="" id="hiddenComment"/>
	<!-- 메일 세션 정보 -->
	<input type="hidden" value="" id="inputUserId"/>
	<ul class="contLnbMenu mailMenu" style="display: none"></ul>
	<!-- 결재 문서 정보 가져오기 용 iframe -->
	<iframe name="IframeSerialApprovalFrm" width="100%;" height="auto" id="IframeSerialApprovalFrm" frameborder="0" scrolling="yes" style="-ms-overflow-style: none; display: none;"></iframe>
	
	<!-- 상단 사용자 정보 -->	
	<div class="workportalTop">
		<div class="photo"><img src="" alt="<spring:message code="Cache.lbl_ProfilePhoto"/>" onerror="coviCmn.imgError(this, true);"></div> <!-- 프로필사진 -->
		<div class="userInformation">
			<p></p>
			<ul>
				<li><span><spring:message code="Cache.lbl_ThisWeek"/></span><span><strong></strong><spring:message code="Cache.lbl_Hours"/></span></li> <!-- 금주, 시간 -->
				<li>&nbsp;<span><spring:message code="Cache.lbl_ThisMonth"/></span><span><strong></strong><spring:message code="Cache.lbl_Hours"/></span></li> <!-- 금월, 시간 -->
			</ul>
		</div>
	</div>
	<div class="workportalCont">
		<!-- 좌측 근태/결재/메일 정보 -->
		<div class="mywork">
			<!-- 근태정보 -->	
			<div class="MWR AManagement">
				<div class="MWRTit">
				  	<span class="W_title"><spring:message code="Cache.lbl_AttInfo"/></span> <!-- 근태정보 -->
				  	<a href="/groupware/layout/attendance_AttendanceStatusWeek.do?CLSYS=attendance&CLMD=user&CLBIZ=Attendance" class="W_more">more</a>
				</div>
				<ul class="MWRCont">
					<li class="VacationLayer">
						<span class="MWRCont_L"><spring:message code="Cache.lbl_vacationer"/></span><span class="MWRCont_R"></span><a class="MWR_more" href="#">자세히보기</a> <!-- 휴가자 -->
						<div class="MWR_Worktypelayer Ltype03">
							<div class="MWRlayer_close_wrap"><a href="#" class="MWRlayer_close"></a></div>
							<div class="part02">
								<p class="layerT">
									<spring:message code="Cache.lbl_vacationer"/> <!-- 휴가자 -->
									<select class="deptList selectType04"></select>
								</p>
								<div class="mScrollV scrollVType01">
									<ul></ul>
								</div>
								<div class="nolist">
									<p class="nolist-txt"><spring:message code="Cache.msg_NoDataList"/></p> <!-- 조회할 목록이 없습니다.-->
								</div>
							</div>
						</div>
					</li>
					<li class="OutsideWorkLayer">
						<span class="MWRCont_L"><spring:message code="Cache.lbl_OutsideWorking"/></span><span class="MWRCont_R"></span><a class="MWR_more" href="#"><spring:message code="Cache.lbl_DetailView1"/></a> <!-- 외근, 자세히보기 -->
						<div class="MWR_Worktypelayer Ltype03">
							<div class="MWRlayer_close_wrap"><a href="#" class="MWRlayer_close"></a></div>
							<div class="part02">
								<p class="layerT">
									<spring:message code="Cache.lbl_OutsideWorking"/> <!-- 외근 -->
									<select class="deptList selectType04"></select>
								</p>
								<div class="mScrollV scrollVType01">
									<ul></ul>
								</div>
								<div class="nolist">
									<p class="nolist-txt"><spring:message code="Cache.msg_NoDataList"/></p> <!-- 조회할 목록이 없습니다.-->
								</div>
							</div>
						</div>
					</li>
					<li class="Overtimelayer">
						<span class="MWRCont_L"><spring:message code="Cache.lbl_OvertimeWork"/></span><span class="MWRCont_R"></span><a class="MWR_more" href="#"><spring:message code="Cache.lbl_DetailView1"/></a> <!-- 시간외근무, 자세히보기 -->
						<div class="MWR_Worktypelayer Ltype03">
							<div class="MWRlayer_close_wrap"><a href="#" class="MWRlayer_close"></a></div>
							<div class="part02">
								<p class="layerT">
									<spring:message code="Cache.lbl_OvertimeWork"/> <!-- 시간외근무 -->
									<select class="deptList selectType04"></select>
								</p>
								<div class="mScrollV scrollVType01">
									<ul></ul>
								</div>
								<div class="nolist">
									<p class="nolist-txt"><spring:message code="Cache.msg_NoDataList"/></p> <!-- 조회할 목록이 없습니다.-->
								</div>
							</div>
						</div>
					</li>
					<li class="Worktypelayer">
						<span class="MWRCont_L"><spring:message code="Cache.lbl_att_806_s_1_h"/></span><span class="MWRCont_R">00:00 ~ 00:00</span><a class="MWR_more" href="#"><spring:message code="Cache.lbl_DetailView1"/></a> <!-- 근무유형, 자세히보기 -->
						<div class="MWR_Worktypelayer Ltype04">
							<div class="MWRlayer_close_wrap"><a href="#" class="MWRlayer_close"></a></div>
							<div class="part01">
								<p class="layerT"><spring:message code="Cache.lbl_MyWorkType"/></p> <!-- 내 근무유형 -->
								<p class="layerC"><span class="layertime">00:00 ~ 00:00</span></p>
							</div>
							<div class="part02" style="display: none;">
								<p class="layerT">
									<spring:message code="Cache.lbl_TeamWorkType"/> <!-- 팀 근무유형 -->
									<select class="deptList selectType04"></select>
								</p>
								<div class="mScrollV scrollVType01">
									<ul></ul>
								</div>
								<div class="nolist">
									<p class="nolist-txt"><spring:message code="Cache.msg_NoDataList"/></p> <!-- 조회할 목록이 없습니다.-->
								</div>
							</div>
						</div>
					</li>
					<li>
						<a class="MWRCont_btn" href="#" onclick="openForm('WF_FORM_OVERTIME_WORK','','');"><spring:message code="Cache.lbl_ApplyNightWork"/></a><a class="MWRCont_btn" href="#" onclick="openForm('WF_FORM_HOLIDAY_WORK','','');"><spring:message code="Cache.lbl_app_approval_holiday"/></a><a class="MWRCont_btn" href="#" onclick="openForm('WF_FORM_CALL','','');"><spring:message code="Cache.lbl_app_approval_call"/></a>
					</li>
				</ul>
			</div>
			<!-- 전자결재 -->
			<div class="MWR Approval">
				<div id="ApprovalFilterMenu">
					<ul class="Applayer Ltype01" style="min-width: 100px;">
						<li>
							<a href="#" state=""><span></span><spring:message code="Cache.lbl_Whole"/></a> <!-- 전체 -->
						</li>
						<li>
							<a href="#" state="Approval"><span></span><spring:message code="Cache.tte_ApprovalListBox"/></a> <!-- 미결함 -->
						</li>
						<li>
							<a href="#" state="Process"><span></span><spring:message code="Cache.tte_ProcessListBox"/></a> <!-- 진행함 -->
						</li>
					</ul>
				</div>
				<div class="MWRTit">
					<span class="W_title"><spring:message code='Cache.lbl_apv_approval' /></span> <!-- 전자결재 -->
					<a class="W_filter" href="#" onclick="filterApprovalList();"><spring:message code='Cache.lbl_Filter' /></a> <!-- 필터 -->
					<a class="W_write" href="#"><spring:message code='Cache.lbl_Write' /></a> <!-- 작성 -->
					<a href="/approval/layout/approval_Home.do?CLSYS=approval&CLMD=user&CLBIZ=Approval" class="W_more">more</a>
				</div>
				<div class="MWR_timeWrap mScrollV scrollVType01">
					<ul class="MWR_time"></ul>
				</div>
				<!-- 전자결재 진행함 레이어  -->
				<div id="ApprovalProgressMenu">
					<ul class="Applayer Ltype01">
						<li>
							<a href="#"><span class="ico_applayer n04"></span></a> 
						</li>
						<li>
							<a href="#"><span class="ico_applayer n05"></span></a>
						</li>
						<li>
							<a href="#"><span class="ico_applayer n03"></span></a>
						</li>
					</ul>
				</div>
				<!-- 전자결재 미결함 레이어  -->
				<div id="ApprovalListMenu">
					<ul class="Applayer Ltype02">
						<li>
							<a href="#"><span class="ico_applayer n01"></span></a>
						</li>
						<li>
							<a href="#"><span class="ico_applayer n02"></span></a>
						</li>
						<li>
							<a href="#"><span class="ico_applayer n03"></span></a>
						</li>
					</ul>
				</div>
			</div>
			<!-- 메일 -->
			<div class="MWR Mail">
				<div class="MWRTit">
					<span class="W_title"><spring:message code="Cache.lbl_ReceivedMail"/></span> <!-- 반은메일 -->
					<a class="W_write" href="#"><spring:message code='Cache.lbl_Write' /></a> <!-- 필터 -->
					<a href="/mail/layout/mail_Mail.do?CLSYS=mail&CLMD=user&CLBIZ=Mail" class="W_more">more</a>
				</div>
				<div class="MWR_timeWrap mScrollV scrollVType01">
					<ul class="MWR_time"></ul>
				</div>
				<div id="MailContextMenu">
					<ul class="Applayer Ltype03">
						<li>
							<a href="#"><span class="ico_applayer n06"></span></a>
						</li>
						<li>
							<a href="#"><span class="ico_applayer n07"></span></a>
						</li>
						<li>
							<a href="#"><span class="ico_applayer n08"></span></a>
						</li>
						<li>
							<a href="#"><span class="ico_applayer n09"></span></a>
						</li>
						<li>
							<a href="#"><span class="ico_applayer n10"></span></a>
						</li>
					</ul>
				</div>
			</div>
		</div>
		<!-- 업무현황 board -->
		<div class="Overallworkstatus">
			<!-- 업무현황 탭 -->	
			<div class="workstatusTab">
				<ul>
					<li class="on"><a href="#"><spring:message code="Cache.lbl_AllBusinessStatus"/></a></li> <!-- 전체업무현황 -->
					<li><a href="#"><spring:message code="Cache.lbl_TFRoom"/></a></li> <!-- 프로젝트룸 -->
					<li><a href="#"><spring:message code="Cache.lbl_TaskManage"/></a></li> <!-- 업무관리 -->
				</ul>
				<div class="workBtnR">
					<a id="btnRefresh" class="btnRepeatType02" type="button" style="padding: 7px 10px 7px 18px; height: 28px;"><spring:message code="Cache.btn_Refresh"/></a> <!-- 새로고침 -->
					<a class="W_filter_txt" href="#" onclick="filterTaskList();"><spring:message code="Cache.lbl_Filter"/></a> <!-- 필터 -->
					<div id="TaskFilterMenu">
						<ul class="Applayer Ltype04">
							<li>
								<a href="#" state=""><spring:message code="Cache.lbl_allwork"/></a> <!-- 전체업무 -->
							</li>
						</ul>
					</div>
					<a class="W_write_txt" href="#" onclick="addTask();"><spring:message code="Cache.lbl_Write"/></a> <!-- 작성 -->
					<a class="W_add_txt" href="#" onclick="addProject();"><spring:message code="Cache.lbl_AddProject"/></a> <!-- 프로젝트추가 -->
				</div>
 			</div>
			<!-- 전체업무 현황 -->	
			<div id="allWorkWrap">
	           	<div class="workstatus">				  	
					<div id="delayTaskList" class="OWListBox_p">
						<div class="OWListBox">
							<div class="OWList_Top">
								<h3 class="OWList_Toptitle"><span class="OWList_ico01"></span><span class="OWList_title"><spring:message code="Cache.lbl_delaywork"/></span><span class="OWList_num color01">0</span></h3> <!-- 지연업무 -->
								<a href="/groupware/layout/biztask_MyTask.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask" class="W_more">more</a>
							</div>
							<div class="OWList_Cont">
								<div class="OWList">
									<ul></ul>
								</div>
								<div class="OWList_none" style="display:none"><spring:message code="Cache.msg_NoDataList"/></div> <!-- 조회할 목록이 없습니다. -->
							</div>
						</div>
					</div>
					<!-- 진행업무 -->
					<div id="progressTaskList" class="OWListBox_p">
						<div class="OWListBox">
							<div class="OWList_Top">
								<h3 class="OWList_Toptitle"><span class="OWList_ico02"></span><span class="OWList_title"><spring:message code="Cache.lbl_progresswork"/></span><span class="OWList_num color02">0</span></h3> <!-- 진행업무 -->
								<a href="/groupware/layout/biztask_MyTask.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask" class="W_more">more</a>
							</div>
							<div class="OWList_Cont">
								<div class="OWList">
									<ul></ul>
								</div>
								<div class="OWList_none" style="display: none"><spring:message code="Cache.msg_NoDataList"/></div> <!-- 조회할 목록이 없습니다. -->
							</div>
						</div>
					</div>
					<!-- 예고업무 -->	
					<div id="noticeTaskList" class="OWListBox_p">
						<div class="OWListBox">
							<div class="OWList_Top">
								<h3 class="OWList_Toptitle"><span class="OWList_ico03"></span><span class="OWList_title"><spring:message code="Cache.lbl_PreWork"/></span><span class="OWList_num color03" id="spanPreTaskCNT">0</span></h3> <!-- 예고업무 -->
							</div>
							<div class="OWList_Cont">
								<div class="OWDocbox">
									<a id="ahrefLeft" href="#" onclick="javascript:setPageMoveTaskPre('p');" class="OWDoc_leftarrow" style="display:none;">왼쪽 넘기기</a>
									<div class="OWDocWrap" id="divPreTask"></div>
									<div class="OWList_none" style="display:none; line-height: 100px;"><spring:message code="Cache.msg_NoDataList"/></div> <!-- 조회할 목록이 없습니다. -->
									<a id="ahrefRight" href="#" onclick="javascript:setPageMoveTaskPre('n');" class="OWDoc_rightarrow" style="display:none;">오른쪽 넘기기</a>
								</div>
							</div>
						</div>
					</div>
			 	</div>
			 	<!-- 내업무 현황/내 프로젝트 현황 -->	
				<div class="workboard">
					<div class="prograssArea">
						<div class="PrograssImg">
							<h3 style="display: inline-block;"><spring:message code="Cache.lbl_myworkreport"/></h3> <!-- 나의 업무 현황 -->
							<div style="float: right; margin-top: -5px;">
								<select>
									<option value="All"><spring:message code="Cache.lbl_allwork"/></option> <!-- 전체업무 -->
									<option value="TF"><spring:message code="Cache.lbl_Project"/></option> <!-- 프로젝트 -->
									<option value="Task"><spring:message code="Cache.lbl_TaskManage"/></option> <!-- 업무관리 -->
								</select>
							</div>
							<div class="cyclePrograssBarimg">											
								<div class="cyclePrograssBar" style=" margin-left: 40px;">											
								<div class="cycleCont">			
									<div class="cycleBg cycleTotal">
										<div class="pie"></div>										
									</div>
									<div class="cycleSlice">
										<div class="pie pieDiv"></div>
										<div class="pie fill"></div>
									</div>
									<div class="cycleSlice">
										<div class="pie pieDiv"></div>
										<div class="pie fill"></div>
									</div>
									<div class="cycleSlice">
										<div class="pie pieDiv"></div>
										<div class="pie fill"></div>
									</div>
								</div>
								<div class="cycleTxt" style="background: none; top: -35px;">
									<p><spring:message code="Cache.lbl_MyWork"/></p> <!-- 내업무 -->
									<p>
										<span id="myTaskTxt">0</span> <spring:message code="Cache.lbl_DocCount"/> <!-- 건 -->
									</p>
								</div>											
							</div>
							</div>
							<div class="cyclePrograssBarper">
								<div class="progress_num">
									<span class="txt"><spring:message code="Cache.lbl_Progress"/></span> <!-- 진행 -->
									<span class="num">0</span>
								</div>
								<div class="complete_num">
									<span class="txt"><spring:message code="Cache.lbl_Completed"/></span> <!-- 완료 -->
									<span class="num">0</span>
								</div>
								<div class="wait_num">
									<span class="txt"><spring:message code="Cache.lbl_Ready"/></span> <!-- 대기 -->
									<span class="num">0</span>
								</div>
								<div class="delay_num">
									<span class="txt"><spring:message code="Cache.lbl_Delay"/></span> <!-- 지연 -->
									<span class="num">0</span>
								</div>
							</div>
						</div>
						<div class="PrograssList TodayWorks">
							<h3>Today Works</h3>
							<ul class="MWR_time mScrollV scrollVType01"></ul>
							<div class="nolist" style="text-align: center; margin: 115px 50px; color: #888;">
								<p class="nolist-txt"><spring:message code="Cache.msg_NoDataList"/></p> <!-- 조회할 목록이 없습니다.-->
							</div>
						</div>
					</div>
			 	</div>
		 	</div>
			<div id="TManageWrap" style="display: none;">
				<div class="workportal-fullcon">
					<div class="workportal-leftCon mScrollV scrollVType01">
						<div id="tfList" style="display: none;">
							<ul class="Projectroom-list"></ul>
							<div class="tasklist_none_title" style="display: none; text-align:center; margin-top: 30px;">
								<p class="taskline_none_object">조회할 목록이 없습니다.</p>
							</div>
						</div>
						<div id="taskList" style="display: none;">
							<ul class="Taskmanagement-list"></ul>
							<div class="tasklist_none_title" style="display: none; text-align:center; margin-top: 30px;">
								<p class="taskline_none_object">조회할 목록이 없습니다.</p>
							</div>
						</div>
					</div>
					<div class="workportal-rightCon">
						<!-- [S]세부 컨텐츠 -->
						<div class="workcon_wrap" style="display: none;">
							<!-- [S]타이틀 영역 -->
							<div class="workcon_tit">
								<div class="tfTabList">
									<div class="workcon_tit01" style="cursor: pointer;">
										<div class="ITMTeamroomListBox_image"><img src="" onerror="this.src='/covicore/resources/images/no_image.jpg'"></div>
										<span class="task-name"></span>
										<span class="task-info">
											<span></span>
											<span></span>
										</span>
									</div>
									<div class="workcon_tit02">
										<div class="workcon_detail_info">
											<span class="classtxt"><spring:message code="Cache.lbl_ProgressState"/></span> <!-- 진행상태 -->
											<select class="selectType04"></select>
											<span class="edit active"><spring:message code="Cache.lbl_Modifiable"/></span> <!-- 수정가능 -->
										</div>
										<div class="workcon_detail_info">
											<span class="classtxt"><spring:message code="Cache.lbl_ProgressRate"/></span> <!-- 진도율 -->
											<span class="classtxt progressText">0%</span>
											<span class="edit" style="position: absolute; right: 92px;"><spring:message code="Cache.lbl_UnableModify"/></span> <!-- 수정불가 -->
										</div>
									</div>
								</div>
								<div class="taskTabList">
									<div class="workcon_tit01">
										<div class="ITMTeamroomListBox_image"><img src="<%=cssPath%>/IntegratedTaskManagement/resources/images/teamroom_img.jpg" onerror="this.src='/covicore/resources/images/no_image.jpg'"></div>
										<span class="task-name"></span>
										<span class="task-info">
											<span></span>
											<span></span>
										</span>
									</div>
									<div class="workcon_tit02">
										<div class="workcon_detail_info">
											<span class="classtxt"><spring:message code="Cache.lbl_ProgressState"/></span> <!-- 진행상태 -->
											<select class="selectType04"></select>
											<span class="edit active"><spring:message code="Cache.lbl_Modifiable"/></span> <!-- 수정가능 -->
										</div>
										<div class="workcon_detail_info">
											<span class="classtxt"><spring:message code="Cache.lbl_ProgressRate"/></span> <!-- 진도율 -->
											<select class="selectType04">
												<option value="0">0%</option>
												<option value="5">5%</option>
												<option value="10">10%</option>
												<option value="15">15%</option>
												<option value="20">20%</option>
												<option value="25">25%</option>
												<option value="30">30%</option>
												<option value="35">35%</option>
												<option value="40">40%</option>
												<option value="45">45%</option>
												<option value="50">50%</option>
												<option value="55">55%</option>
												<option value="60">60%</option>
												<option value="65">65%</option>
												<option value="70">70%</option>
												<option value="75">75%</option>
												<option value="80">80%</option>
												<option value="85">85%</option>
												<option value="90">90%</option>
												<option value="95">95%</option>
												<option value="100">100%</option>
											</select>
											<span class="edit"><spring:message code="Cache.lbl_UnableModify"/></span> <!-- 수정불가 -->
										</div>
									</div>
								</div>
							</div>
							<!-- [E]타이틀 영역 -->
							<!-- [S]탭영역 -->
							<div class="workcon_bottom">
								<div class="worcon_tab">
									<ul id="tfTabMenu" class="tabMenu clearFloat">
										<li class=""><a href="#"><spring:message code="Cache.lbl_TFWorkInProgress"/></a></li> <!-- 작업진행 -->
										<li class=""><a href="#"><spring:message code="Cache.lbl_Boards"/>(0)</a></li> <!-- 게시판 -->
										<li class=""><a href="#"><spring:message code="Cache.lbl_DataRoom"/></a></li> <!-- 자료실 -->
									</ul>
									<ul id="taskTabMenu" class="tabMenu clearFloat">
										<li class=""><a href="#"><spring:message code="Cache.lbl_Comments"/>(0)</a></li> <!-- 댓글 -->
										<li class=""><a href="#"><spring:message code="Cache.lbl_apv_ConDoc"/>(0)</a></li> <!-- 연관문서 -->
										<li class=""><a href="#"><spring:message code="Cache.lbl_Details"/></a></li> <!-- 상세내역 -->
									</ul>
								</div>
								<div id="dext5" kind="write" style="position: absolute; visibility: hidden;"></div>
								<div class="tfTabList">
									<!-- [S]작업진행 -->
									<div id="activityArea" class="tabContent">
										<div class="workcon_mytask_select_wrap">
											<select class="workcon_mytask_select" onchange="setActivityList();">
												<option value="all"><spring:message code="Cache.lbl_allwork"/></option> <!-- 전체업무 -->
												<option value="myTask"><spring:message code="Cache.lbl_MyWork"/></option> <!-- 내업무 -->
											</select>
										</div>
										<div class="workcon_mytask_scroll mScrollV scrollVType01">
											<div class="workcon_mytask_wrap">
												<ul class="workcon_mytask_list"></ul>
												<div class="tasklist_none_title" style="display: none; text-align:center; margin-top: 30px;">
													<p class="taskline_none_object"><spring:message code="Cache.msg_NoDataList"/></p> <!-- 조회할 목록이 없습니다. -->
												</div>
											</div>
										</div>
										<div class="workcon_bottom_btn">
											<a href="#" class="btnTypeDefault btnTypeChk" onclick="addActivity();"><spring:message code="Cache.btn_register"/></a> <!-- 등록 -->
											<a href="#" class="btnTypeX btnTypeDefault" onclick="deleteActivity();"><spring:message code="Cache.btn_delete"/></a> <!-- 삭제 -->
										</div>
									</div>
									<!-- [E]작업진행 -->
									<!-- [S]게시판 -->
									<div id="boardArea" class="tabContent board">
										<div class="workcon_mytask_select_wrap">
											<select class="workcon_mytask_select"></select>
										</div>
										<div class="workcon_mytask_scroll mScrollV scrollVType01">
											<div class="workcon_mytask_wrap">
												<ul class="workcon_mytask_list"></ul>
												<div class="tasklist_none_title" style="display: none; text-align:center; margin-top: 30px;">
													<p class="taskline_none_object"><spring:message code="Cache.msg_NoDataList"/></p> <!-- 조회할 목록이 없습니다. -->
												</div>
											</div>
										</div>
										<div class="workcon_bottom_btn">
											<a href="#" class="btnTypeDefault btnTypeChk" onclick="TFBoardWrite();"><spring:message code="Cache.btn_register"/></a> <!-- 등록 -->
											<a href="#" class="btnTypeX btnTypeDefault" onclick="delCommentPopup();"><spring:message code="Cache.btn_delete"/></a> <!-- 삭제 -->
										</div>
									</div>
									<!-- [E]게시판 -->
									<!-- [S]자료실 -->
									<div id="resourceArea" class="tabContent">
										<div class="workcon_mytask_data_scroll mScrollV scrollVType01">
											<div class="workcon_docment_wrap"></div>
											<div class="tasklist_none_title" style="display: none; text-align:center; margin-top: 30px;">
												<p class="taskline_none_object"><spring:message code="Cache.msg_NoDataList"/></p> <!-- 조회할 목록이 없습니다. -->
											</div>
											<div id="tfFileControl" style="display: none; margin: 10px 20px;"></div>
										</div>
										<div class="workcon_bottom_btn">
											<a href="#" class="btnTypeDefault btnTypeChk" onclick="renderFileUpload();"><spring:message code="Cache.btn_register"/></a> <!-- 등록 -->
											<a href="#" class="btnTypeX btnTypeDefault" onclick="deleteTFFile();"><spring:message code="Cache.btn_delete"/></a> <!-- 삭제 -->
											<a href="#" class="btnTypeDefault btnTypeChk" onclick="setFileUploadValue();" style="display: none;"><spring:message code="Cache.btn_register"/></a> <!-- 등록 -->
											<a href="#" class="btnTypeX btnTypeDefault" onclick="changeFileUploadView();" style="display: none;"><spring:message code="Cache.btn_Cancel"/></a> <!-- 취소 -->
										</div>
									</div>
									<!-- [E]자료실 -->
								</div>
								<div class="taskTabList">
									<!-- [S]댓글영역-->
									<div id="commentArea" class="tabContent">
										<div class="workcon_comment_scroll mScrollV scrollVType01">
											<div class="workcon_comment_wrap">
												<div id="commentView" class="commentView"></div>
											</div>
										</div>
									</div>
									<!-- [E]댓글영역 -->
									<!-- [S]연관문서 -->
									<div id="documentArea" class="tabContent">
										<div class="workcon_comment_scroll mScrollV scrollVType01">
											<div class="workcon_docment_wrap"></div>
											<div class="tasklist_none_title" style="display: none; text-align:center; margin-top: 30px;">
												<p class="taskline_none_object"><spring:message code="Cache.msg_NoDataList"/></p> <!-- 조회할 목록이 없습니다. -->
											</div>
											<div id="taskFileControl" style="display: none; margin: 10px 20px;"></div>
										</div>
									</div>
									<!-- [E]연관문서 -->
									<!-- [S]상세내역 -->
									<div id="detailInfoArea" class="tabContent">
										<div class="workcon_comment_scroll mScrollV scrollVType01">
											<div class="workcon_detail_box">
												<table class="workcon_detail_table">
													<tbody>
														<tr>
															<td class="workcon_detail_01"><spring:message code="Cache.lbl_Location"/></td> <!-- 위치 -->
															<td class="workcon_detail_02"></td>
														</tr>
														<tr>
															<td class="workcon_detail_01"><spring:message code="Cache.lbl_explanation"/></td> <!-- 설명 -->
															<td class="workcon_detail_02"></td>
														</tr>
														<tr>
															<td class="workcon_detail_01"><spring:message code="Cache.lbl_task_performer"/></td> <!-- 수행자 -->
															<td class="workcon_detail_02"></td>
														</tr>
													</tbody>
												</table>
											</div>
										</div>
									</div>
									<!-- [E]상세내역 -->
								</div>
							</div>
							<!-- [E]탭영역 -->
						</div>
						<!-- [E]세부 컨텐츠 -->
						<div class="groupchat-btn-wrap up" style="display: none;">
							<a href="#" class="groupchat-btn"><p class="groupchat-txt"><spring:message code="Cache.lbl_GroupConversation"/></p></a> <!-- 그룹대화 -->
						</div>
						<div class="worktoktalk" style="margin-top: 50px;">
							<iframe id="channelLayer" src=""></iframe>
						</div>
					</div>
					<!-- [E]우측 세부 컨텐츠 영역 -->
				</div>
				<!-- [S]우측 세부 컨텐츠 영역 -->	
			</div>
		</div>
	</div>
</section>

<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<script>
	var UserCode = Common.getSession("UR_Code");
	var DeptCode = Common.getSession("DEPTID");
	var UR_Mail = Common.getSession("UR_Mail");
	var DN_Code = Common.getSession("DN_Code");
	var UR_Name = Common.getSession("UR_Name");
	var UR_JobTitleCode = Common.getSession("UR_JobTitleCode");
	var lang = Common.getSession("lang");
	var frontStorageUrl = Common.getBaseConfig("FrontStorage").replace("{0}", DN_Code);
	var smart4jPathUrl = Common.getGlobalProperties("smart4j.path");
	
	var schList; // 근무 유형 리스트
	var tfList = new Array; // tf 리스트
	var tfFileList = new Array(); // 프로젝트 파일 목록
	var tfDocList = new Array(); // 프로젝트 결재 문서 목록
	var taskList; // 업무 리스트
	var taskFileList = new Array(); // 업무 파일 목록
	var folderPath = ""; // 업무 폴더 경로
	var waiting_num = 0; // 대기 업무 개수
	var progress_num = 0; // 진행 업무 개수
	var delay_num = 0; // 지연 업무 개수
	var complete_num = 0; // 완료 업무 개수
	var printDiv; // 결재문서 pdf 변환용 html
	var approvalType = null; // 전자결재 클릭 이벤트 사용 변수
	var isChangeTF = false; // TF 리스트 클릭 여부 (tfFileList의 값 변경 여부)
	var isDocReg = false; // 업무 등록 버튼 클릭 여부
	
	var g_editorKind = Common.getBaseConfig("EditorType");
	
	//예고업무함 변수
	var gPreTaskPageCnt = 6;
	var gPreTaskCurrentPage = 1;//현재페이지
	var gPreTaskTotalCnt = 0; //전체 count
	var gPreTaskTotalPage = 1; //최종페이지
	var preTaskList;
	
	$(document).ready(function(){
		$(".workportalWrap").on("mousedown", function(){
			// 메일 클릭 옵션 이벤트 처리
			if($("#MailContextMenu").css("display") == "block"){
				$("#MailContextMenu").hide();
			}
			// 결재 진행함 클릭 옵션 이벤트 처리
			if($("#ApprovalProgressMenu").css("display") == "block"){
				$("#ApprovalProgressMenu").hide();
			}
			// 결재 미결함 클릭 옵션 이벤트 처리
			if($("#ApprovalListMenu").css("display") == "block"){
				$("#ApprovalListMenu").hide();
			}
			// 결재 문서 목록 필터 옵션 이벤트 처리
			if($("#ApprovalFilterMenu").css("display") == "block"){
				$("#ApprovalFilterMenu").hide();
			}
			// 업무 목록 필터 옵션 이벤트 처리
			if($("#TaskFilterMenu").css("display") == "block"){
				$("#TaskFilterMenu").hide();
			}
		});
		
		$(".groupchat-btn-wrap").on("click", function(){
			$(".worktoktalk").toggle();
			$(".groupchat-btn-wrap").toggleClass("up");
			$(".groupchat-btn-wrap").toggleClass("down");
		});
		
		// 포탈 메뉴 이동시 업무형 포탈 숨김
		$("#anchorLogo, #topmenu li, #siteMapCont a, #myInfoViewList #liLast").on("click", hideWorkPortal);
		$("#siteMapCont .todoBtnBox a, .favoriteSiteMenu li .btnRemove").off("click", hideWorkPortal);
		
		// 부서 목록 변경 이벤트
		$(".deptList").on("change", function(){
			$(".OutsideWorkLayer .part02 ul").empty();
			$(".VacationLayer .part02 ul").empty();
			$(".Overtimelayer .part02 ul").empty();
			$(".Worktypelayer .part02 ul").empty();
		});
		
		// 메일 정보 조회용
		$("#inputUserId").val(DN_Code+"_"+UserCode);
		
		// 간편작성 - 전자결재
		$(".Approval .W_write").on("click", function(){
			 coviCtrl.toggleSimpleMake(); 
			 $(".simpleMakeLayerPopUp .tabMenuArrow li[type=Approval]").click();
		});
		
		// 간편작성 - 메일
		$(".Mail .W_write").on("click", function(){
			 coviCtrl.toggleSimpleMake(); 
			 $(".simpleMakeLayerPopUp .tabMenuArrow li[type=Mail]").click();
		});
		
		// 부서  select box 변경 이벤트
		$(".deptList").change(function(){
			var idx = $(".deptList").index(this);
			
			$(".deptList").val($(".deptList").eq(idx).val());
			getAttendenceDeptWeekList();
		});
		
		// 휴가 레이어
		$(".VacationLayer .MWR_more, .VacationLayer .MWRlayer_close").on("click", function(){
			var parentCont = $(this).closest(".VacationLayer");
			
			if(parentCont.hasClass("active")){
				$(".MWR_Worktypelayer").closest("li").removeClass("active");
			}else{
				$(".MWR_Worktypelayer").closest("li").removeClass("active");
				parentCont.addClass("active");	
			}
		});
		
		// 외근 레이어
		$(".OutsideWorkLayer .MWR_more, .OutsideWorkLayer .MWRlayer_close").on("click", function(){
			var parentCont = $(this).closest(".OutsideWorkLayer");
			
			if(parentCont.hasClass("active")){
				$(".MWR_Worktypelayer").closest("li").removeClass("active");
			}else{
				$(".MWR_Worktypelayer").closest("li").removeClass("active");
				parentCont.addClass("active");	
			}
		});
		
		// 근무유형 레이어
		$(".Worktypelayer .MWR_more, .Worktypelayer .MWRlayer_close").on("click", function(){
			var parentCont = $(this).closest(".Worktypelayer");

			if(parentCont.hasClass("active")){
				$(".MWR_Worktypelayer").closest("li").removeClass("active");
			}else{
				$(".MWR_Worktypelayer").closest("li").removeClass("active");
				parentCont.addClass("active");	
			}
		});
		
		// 시간외 근무 레이어
		$(".Overtimelayer .MWR_more, .Overtimelayer .MWRlayer_close").on("click", function(){
			var parentCont = $(this).closest(".Overtimelayer");

			if(parentCont.hasClass("active")){
				$(".MWR_Worktypelayer").closest("li").removeClass("active");
			}else{
				$(".MWR_Worktypelayer").closest("li").removeClass("active");
				parentCont.addClass("active");	
			}
		});
		
		// 내업무 현황 select 변경 이벤트
		$(".PrograssImg select").on("change", function(){
			var selVal = $(".PrograssImg select option:selected").val();
			setMyWork(selVal);
		});
		
		// TF 진행상태
		$(Common.getBaseCode("TFDetailState").CacheData).each(function(){
			if(this.Code != "" && this.Code != "TFDetailState"){
				$(".tfTabList .workcon_detail_info .selectType04").append('<option value="'+this.Code+'">'+CFN_GetDicInfo(this.MultiCodeName, lang)+'</option>');
			}
		});
		
		// Task 진행상태
		$(Common.getBaseCode("TaskState").CacheData).each(function(){
			if(this.Code != "" && this.Code != "TaskState"){
				$(".taskTabList .workcon_detail_info").eq(0).find(".selectType04").append('<option value="'+this.Code+'">'+CFN_GetDicInfo(this.MultiCodeName, lang)+'</option>');
				$("#TaskFilterMenu .Applayer").append('<li><a href="#" state="'+this.Code+'">'+CFN_GetDicInfo(this.MultiCodeName, lang)+'<spring:message code="Cache.lbl_task_task"/></a></li>'); // 업무
			}
		});

		// 메일 클릭 리스트
		var cnt = 0;
		$(Common.getBaseCode("WorkPortalMailContext").CacheData).each(function(){
			if(this.Code != ""){
				$("#MailContextMenu .Applayer li").eq(cnt).find("a").attr("state", this.Code);
				$("#MailContextMenu .Applayer li").eq(cnt).find("a").append(CFN_GetDicInfo(this.MultiCodeName, lang));
				cnt++;
			}
		});

		// 진행함 클릭 리스트
		cnt = 0;
		$(Common.getBaseCode("WorkPortalProgressMenu").CacheData).each(function(){
			if(this.Code != ""){
				$("#ApprovalProgressMenu .Applayer li").eq(cnt).find("a").attr("state", this.Code);
				$("#ApprovalProgressMenu .Applayer li").eq(cnt).find("a").append(CFN_GetDicInfo(this.MultiCodeName, lang));
				cnt++;
			}
		});

		// 미결함 클릭 리스트
		cnt = 0;
		$(Common.getBaseCode("WorkPortalApprovalMenu").CacheData).each(function(){
			if(this.Code != ""){
				$("#ApprovalListMenu .Applayer li").eq(cnt).find("a").attr("state", this.Code);
				$("#ApprovalListMenu .Applayer li").eq(cnt).find("a").append(CFN_GetDicInfo(this.MultiCodeName, lang));
				cnt++;
			}
		});
		
		// 업무 상태 탭 이벤트
		$(".workstatusTab li").on("click", function(){
			var idx = $(".workstatusTab li").index(this);
			$(".workstatusTab li").removeClass("on");
			$(".workstatusTab li").eq(idx).addClass("on");
			
			switch(idx){
				case 0: // 전체 업무 현황
					$("#allWorkWrap").show();
					$("#TManageWrap").hide();
					$(".worktok_wrap").hide();
					$("#btnRefresh").hide();
					$(".workstatusTab .workBtnR .W_filter_txt").hide();
					$(".workstatusTab .workBtnR .W_write_txt").hide();
					$(".workstatusTab .workBtnR .W_add_txt").hide();
					break;
				case 1: // 프로젝트룸
					$("#allWorkWrap").hide();
					$("#TManageWrap").show();
					$("#tfList").show();
					$("#taskList").hide();
					$("#tfTabMenu").show();
					$("#taskTabMenu").hide();
					$(".tfTabList").css("display", "inline");
					$(".taskTabList").hide();
					$("#tfTabMenu>li").removeClass("active");
					$("#tfTabMenu>li").eq(0).addClass("active");
					$(".workcon_bottom div").removeClass("active");
					$("#activityArea").addClass("active");
					$("#btnRefresh").css("display", "inline-block");
					$(".workstatusTab .workBtnR .W_filter_txt").hide();
					$(".workstatusTab .workBtnR .W_write_txt").hide();
					$(".workstatusTab .workBtnR .W_add_txt").css("display", "inline-block");
					$(".workcon_bottom").removeClass("type02");
					if($(".workstatusTab li").eq(1).attr("ismsg") == "Y"){
						$(".groupchat-btn-wrap").show();
					}
					
					$("#btnRefresh").off("click").on("click", function(){
						setProjectList();
						$("#tfList li").eq(0).click();
					});
					
					if($("#tfList ul li").length != 0){
						$(".workportal-rightCon").show();
						$(".workcon_wrap").show();
						if($(".tfTabList .workcon_tit01 .task-name").text() == ""){
							$("#tfList ul li").eq(0).click();
						}
					}else{
						$(".workportal-rightCon").hide();
					}
					break;
				case 2: // 업무관리
					$("#allWorkWrap").hide();
					$("#TManageWrap").show();
					$(".worktok_wrap").hide();
					$("#tfList").hide();
					$("#taskList").show();
					$("#tfTabMenu").hide();
					$("#taskTabMenu").show();
					$(".tfTabList").hide();
					$(".taskTabList").css("display", "inline");
					$("#taskTabMenu>li").removeClass("active");
					$("#taskTabMenu>li").eq(0).addClass("active");
					$(".workcon_bottom div").removeClass("active");
					$("#commentArea").addClass("active");
					$("#btnRefresh").css("display", "inline-block");
					$(".workstatusTab .workBtnR .W_filter_txt").css("display", "inline-block");
					$(".workstatusTab .workBtnR .W_write_txt").css("display", "inline-block");
					$(".workstatusTab .workBtnR .W_add_txt").hide();
					$(".workcon_bottom").addClass("type02");
					$(".groupchat-btn-wrap").hide();
					
					$("#btnRefresh").off("click").on("click", function(){
						getAllTaskList();
					});
					
					if($("#taskList ul li").length != 0){
						$(".workportal-rightCon").show();
						$(".workcon_wrap").show();
					}else{
						$(".workportal-rightCon").hide();
					}
					break;
			}
		});
		
		// TF 탭메뉴
		$("#tfTabMenu>li").on("click", function(){
			$("#tfTabMenu>li").removeClass("active");
			$(".tfTabList .tabContent").removeClass("active");
			$(this).addClass("active");
			$(".tfTabList .tabContent").eq($(this).index()).addClass("active");
		});

		// Task 탭메뉴
		$("#taskTabMenu>li").on("click", function(){
			$("#taskTabMenu>li").removeClass("active");
			$(".taskTabList .tabContent").removeClass("active");
			$(this).addClass("active");
			$(".taskTabList .tabContent").eq($(this).index()).addClass("active");
		});
		
		// 사용자 직급에 따라 표시되는 화면을 다르게 함
		var jobTitleCode = Common.getBaseConfig("WorkReportTMJobTitle").split("|");
		var jobTMTitleCode = Common.getBaseConfig("AttendanceTMJobTiltle").split("|");
		
		$.each(jobTitleCode, function(idx, item){
			if(UR_JobTitleCode == item){
				if(UR_JobTitleCode == jobTMTitleCode[0] || UR_JobTitleCode == jobTMTitleCode[1]){
					$(".deptList").hide();
				}else{
					$(".deptList").show();
				}
				$(".Worktypelayer .part02").show();
				$(".Worktypelayer .part01").css("margin-bottom", "40px");
				
				return false;
			}else{
				$(".Worktypelayer .part01").css("margin-bottom", 0);
			}
		});
		
		// 업무 관리 탭 리스트 상태, 진행도 변경 이벤트
		$(".taskTabList .workcon_tit02 .workcon_detail_info .selectType04").on("change", function(){
			var index = $(".taskTabList .workcon_tit02").attr("index");
			
			// 완료 표시된 업무를 체크 해제할 때 수행
			if($("#taskList ul.Taskmanagement-list li").eq(index).hasClass("complete")){
    			var chObj = $("#taskList ul.Taskmanagement-list li").eq(index);
    			$(chObj).removeClass("complete");	
			}
			
			// 업무 저장
			saveTask(index);
		});
		
		// 프로젝트 룸 목록 상태 변경 이벤트
		$(".tfTabList .workcon_tit02 .workcon_detail_info .selectType04").on("change", function(){
			var index = $(".tfTabList .workcon_tit02").attr("index");
			var cID = $("#tfList ul li.active").attr("cid");
			var selVal = $(".tfTabList .workcon_tit02 .workcon_detail_info .selectType04 option:selected").val();
			
			// 프로젝트 상태 변경
			setTFStatus(cID, selVal);
		});
		
		// 프로젝트 룸 세부 보기 > 게시판 변경 이벤트
		$("#boardArea .workcon_mytask_select_wrap select").on("change", function(){
			var cID = $("#tfList ul li.active").attr("cid");
			
			getMessageList(cID);
		});
		
		// 결재 문서 목록 필터 이벤트
		$("#ApprovalFilterMenu ul li").on("mousedown", function(){
			var state = $(this).find("a").attr("state");
			
			setApprovalList(state);
		});

		// 업무 관리 목록 필터 이벤트
		$("#TaskFilterMenu ul li").on("mousedown", function(){
			var state = $(this).find("a").attr("state");
			
			getAllTaskList(state);
		});
		
		// 결재 문서 iframe 로드 이벤트
		$("#IframeSerialApprovalFrm").load(function(){
			if(isDocReg && approvalType == "CreatePdf"){
				printDiv = $("#IframeSerialApprovalFrm").get(0).contentWindow.getBodyHTML("PcSave");
				var fileName = $("#IframeSerialApprovalFrm").get(0).contentWindow.getInfo("FormInstanceInfo.Subject");
			    
			    if(fileName == ""){
			    	fileName = $("#IframeSerialApprovalFrm").get(0).contentWindow.getInfo("FormInfo.FormName");
			    }else{
			    	fileName += "_" + $("#IframeSerialApprovalFrm").get(0).contentWindow.getInfo("FormInstanceInfo.DocNo");
			    }
			    
			    createPdf(fileName);
				setApvFileList();
				
				isDocReg = false;
			}else if(approvalType == "showCommentView"){
				$("#IframeSerialApprovalFrm").get(0).contentWindow.CFN_OpenWindow("/approval/goCommentViewPage.do", "", 540, 617, "iframe-ifNoScroll");
			}
			
			approvalType = null;
	    });
		
		// 메일 세션 생성
		chkMailSession();
		
		// 부서 목록 세팅
		getDeptList();
		
		// 근태 유형 전체를 가져옴
		getSchList();
		
		// 현재 날짜가 포함된 달의 첫 날, 마지막 날을 구함
		getAttDate("month");
		
		// 현재 날짜가 포함된 주의 첫 날, 마지막 날을 구함
		getAttDate("week");
		
		// 사용자의 지연, 진행, 오늘 할 일 목록을 가져옴
		setMyWork("All");
		
		// 팀룸 탭 처리 
		setProjectList();
		
		// 업무 관리 탭 처리
		getAllTaskList();
		
		// 예고업무함 조회
		setMyPreTask();		

		// 미결함, 진행함 결재 목록을 가져옴
		setApprovalList();
		
		// 메일 목록을 가져옴
		setMailList();
		
	});
	
	function hideWorkPortal(){
		$(".commContent").removeClass("oh");
		$(".work_pop").css("right", "-100%");
	}
	
	function getAttDate(mode){
		$.ajax({
			url: "/groupware/layout/getWeek.do",
			type: "POST",
			dataType: "json",
			data: {
				"StartDate": "",
				"SearchSts": mode,
				"sNum": 0
			},
			success: function(data){
				if(mode == "week"){
					$("#p_StartDate").val(data.StartDate);
					$("#p_EndDate").val(data.EndDate);									

					// 해당 주의 근태관련 정보를 가져옴
					getAttendenceDeptWeekList();
				}else{
					$("#p_StartDate").val(data.BaseMonth);
					$("#p_EndDate").val(data.BaseEndMonth);							
					
					// 해당 월의 근태관련 정보를 가져옴
					getAttendenceDeptMonthList();
				}	
			},
			error: function(error){	
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			}
		}); 
	}
	
	function getAttendenceDeptWeekList(){
		var schStr = '';
		
		$.ajax({
			type:"POST",
			url:"/groupware/layout/getAttendenceDeptWeekList.do",
			data: {
				"DEPTID": $(".deptList").val(),
				"SchSeq": "",
				"StartDate": $("#p_StartDate").val(),
				"EndDate": $("#p_EndDate").val(),
				"SearchTxt": "",
				"jobType": "",
				"jobList": "",
				"pageSize": 20,
				"pageNo": 1,
				"RetireUser": "N",
				"Mode": "All"
			}, 
			success: function(data){
				var user = data.user;
				var overTimeStr = '';    // 연장근무 목록
				var vacationStr = '';    // 휴가 목록
				var vacationCnt = 0;     // 휴가자 수
				var outsideWorkCnt = 0;  // 외근자 수
				var outsideWorker = '';  // 외근자 
				var outsideWorkStr = ''; // 외근 목록
				var outsideWorkTxt = ''; // 외근 상태 표시		
				var today = new Date(CFN_GetLocalCurrentDate().replaceAll("-", "/")); // 현재 날짜, 시간  - 타임존 적용
				var todayStr = today.format("yyyy-MM-dd");
				var day = today.getDay(); // 현재 요일(일: 0, 월: 1, …, 토: 6)
				
				if(user.length > 0){
					for(var i = 0; i < user.length; i++){
						var userInfo = user[i];
						var basicInfo = userInfo.basicInfo;
						
						for(var j = 0; j < basicInfo.length; j++){
							var basicObj = basicInfo[j];
							var VacationYn = basicObj.VacationYn;		//휴가유무
							var ExHoTime = basicObj.ExHoTime;			//휴일근무+연장근무시간
							var TotalSumTime = basicObj.TotalSumTime;	//일별일정시간 합
							var JobStsName = basicObj.TransJobStsName;  //근무 상태
							
							// 현재 날짜 기준
							if(basicObj.dayList == todayStr){
								// 휴가 목록
								if(VacationYn == "Y"){
									vacationStr += '<li class="layerC">';
									if(basicObj.VacTime != 0.0000){
										vacationStr += '<span class="layername"><strong>'+userInfo.TransMultiDisplayName+'&nbsp;'+userInfo.TransMultiJobLevelName+'</strong>: </span><span class="layertime">'+Number(basicObj.VacTime/3600)+'<spring:message code="Cache.lbl_Hours"/></span>'; // 시간
									}else{
										vacationStr += '<span class="layername">'+userInfo.TransMultiDisplayName+'&nbsp;'+userInfo.TransMultiJobLevelName+'</span><span class="layertime">'+0+'<spring:message code="Cache.lbl_Hours"/></span>'; // 시간
									}
									vacationStr += '</li>';
									vacationCnt += 1;
								}
								
								// 외근 목록
								if(JobStsName.indexOf("<spring:message code='Cache.lbl_OutsideWorking'/>") != -1 || JobStsName.indexOf("<spring:message code='Cache.AttendanceCode_businessTrip'/>") != -1){ // 외근, 출장
									outsideWorkStr += '<li class="layerC">';
									outsideWorkStr += '<span class="layername"><strong>'+userInfo.TransMultiDisplayName+' '+userInfo.TransMultiJobLevelName+'</strong>: </span><span class="layertime">'+JobStsName+'</span>';
									outsideWorkStr += '</li>';
									if(outsideWorkCnt == 0){										
										outsideWorker = userInfo.TransMultiDisplayName+' '+userInfo.TransMultiJobLevelName;
									}
									outsideWorkCnt += 1;
								}
							}	
						}
						var SumTotalTimeHour = userInfo.SumTotalTimeHour;
						var SumOTimeHour = userInfo.SumOTimeHour;

						if(userInfo.UserCode == UserCode){
							// 사용자 정보
							$(".workportalTop .userInformation p").text(String.format("<spring:message code='Cache.lbl_PersonBusinessPortal' />", userInfo.TransMultiDisplayName)); // {0}님의 업무포탈
							$(".workportalTop .photo img").attr("src", coviCmn.loadImage(userInfo.PhotoPath));
							
							// 연장근무 시간
							if(SumOTimeHour == ""){
								$(".Overtimelayer .MWRCont_R").text("0<spring:message code='Cache.lbl_Hours'/>"); // 시간
							}else{
								$(".Overtimelayer .MWRCont_R").text(Number(SumOTimeHour.split("h")[0])+"<spring:message code='Cache.lbl_Hours'/>"); // 시간
							}
							
							// 금주 업무 시간
							if(SumTotalTimeHour == ""){
								$(".workportalTop .userInformation ul li").eq(0).find("strong").text(0);						
							}else{
								$(".workportalTop .userInformation ul li").eq(0).find("strong").text(Number(SumTotalTimeHour.split("h")[0]));		
							}
							
						}else{
							// 연장근무 목록
							overTimeStr += '<li class="layerC">';
							if(ExHoTime == ""){
								overTimeStr += '<span class="layername"><strong>'+userInfo.TransMultiDisplayName+'&nbsp;'+userInfo.TransMultiJobLevelName+'</strong>: </span><span class="layertime">0<spring:message code="Cache.lbl_Hours"/></span>'; // 시간
							}else{
								overTimeStr += '<span class="layername"><strong>'+userInfo.TransMultiDisplayName+'&nbsp;'+userInfo.TransMultiJobLevelName+'</strong>: </span><span class="layertime">'+Number(SumOTimeHour.split("h")[0])+'<spring:message code="Cache.lbl_Hours"/></span>'; // 시간
							}
							overTimeStr += '</li>';
						}
						
						// 근무유형 목록
						for(var k = 0; k < schList.length; k++){
							var schSubStr = ''; // 근무유형 목록
							var schTime = "00:00 ~ 00:00";
							
							if(schList[k].SchSeq == userInfo.SchSeq){
								schSubStr += '<li class="layerC">';
								schSubStr += '<span class="layername"><strong>'+userInfo.TransMultiDisplayName+' '+userInfo.TransMultiJobLevelName+'</strong>: </span>';
								switch(day){
									case 0:
										if(schList[k].AttDayStsSun != "H"){
											schTime = schList[k].SetStartSunHour+" ~ "+schList[k].SetEndSunHour;
										}
										break;
									case 1:
										if(schList[k].AttDayStsMon != "H"){
											schTime = schList[k].SetStartMonHour+" ~ "+schList[k].SetEndMonHour;
										}
										break;
									case 2:
										if(schList[k].AttDayStsTue != "H"){
											schTime = schList[k].SetStartTueHour+" ~ "+schList[k].SetEndTueHour;
										}
										break;
									case 3:
										if(schList[k].AttDayStsWed != "H"){
											schTime = schList[k].SetStartWedHour+" ~ "+schList[k].SetEndWedHour;
										}						
										break;
									case 4:
										if(schList[k].AttDayStsThu != "H"){
											schTime = schList[k].SetStartThuHour+" ~ "+schList[k].SetEndThuHour;
										}
										break;
									case 5:
										if(schList[k].AttDayStsFri != "H"){
											schTime = schList[k].SetStartFriHour+" ~ "+schList[k].SetEndFriHour;
										}
										break;
									case 6:
										if(schList[k].AttDayStsSat != "H"){
											schTime = schList[k].SetStartSatHour+" ~ "+schList[k].SetEndSatHour;
										}
										break;
								}
								schSubStr += '<span class="layertime">'+schTime+'</span>';
								schSubStr += '</li>';
							}
							if(userInfo.UserCode != UserCode){ // 자신의 근태유형은 목록에 표시되지 않음
								schStr += schSubStr;
							}else{
								schSubStr = '';
								$(".Worktypelayer .part01 p.layerC span.layertime").text(schTime);
								$(".Worktypelayer .MWRCont_R").text(schTime);
							}
						}	
					}
				}else{
					// 조회할 목록이 없습니다.
				}
				
				// 연장근무 목록
				if(overTimeStr == ''){
					$(".Overtimelayer .part02 div").hide();
					$(".Overtimelayer .nolist").show();
				}else{
					$(".Overtimelayer .part02 ul").html(overTimeStr);
				}
				
				// 휴가 목록
				if(vacationStr == ''){
					$(".VacationLayer .part02 div").hide();
					$(".VacationLayer .nolist").show();
				}else{
					$(".VacationLayer .part02 ul").html(vacationStr);
				}
				
				// 외근 현황
				switch(outsideWorkCnt){
					case 0:
						outsideWorkTxt = outsideWorkCnt+"<spring:message code='Cache.lbl_personCnt'/>"; // 휴가자가 없을 때는 0명으로 펴시
						break;
					case 1:
						outsideWorkTxt = outsideWorker; // [휴가자 이름][직급]
						break;
					default: msg_BesidesCount
						outsideWorkTxt =  String.format('<spring:message code="Cache.msg_BesidesCount" />', outsideWorker, (outsideWorkCnt-1)); // {}[휴가자 이름][직급]}외  {n-1}명
						break;
				}
				
				//휴가 현황
				$(".VacationLayer .MWRCont_R").text(vacationCnt+"<spring:message code='Cache.lbl_personCnt'/>"); // 명
				$(".OutsideWorkLayer .MWRCont_R").text(outsideWorkTxt);
				
				// 외근 목록
				if(outsideWorkStr == ''){
					$(".OutsideWorkLayer .part02 div").hide();
					$(".OutsideWorkLayer .nolist").show();
				}else{
					$(".OutsideWorkLayer .part02 ul").html(outsideWorkStr);
				}
				
				// 근무 유형 목록
				if(schStr == ''){
					$(".Worktypelayer .part02 div").hide();
					$(".Worktypelayer .nolist").show();
				}else{
					$(".Worktypelayer .part02 ul").html(schStr);
				}
				
				// 스크롤 바인딩
				coviCtrl.bindmScrollV($(".mScrollV"));
			},
			error: function(error){	
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			}
		});
	}
	
	// 근무 유형 데이터 가져오기
	function getSchList(){
		$.ajax({
			type: "POST",
			url: "/groupware/layout/getAttendanceSchInfo.do",
			success: function(data){
				schList = data.schList;
			}
		});
	}
	
	function getAttendenceDeptMonthList(){
		$.ajax({
			type: "POST",
			url: "/groupware/layout/getAttendenceDeptWeekList.do",
			data: {
				"DEPTID": DeptCode,
				"SchSeq": "",
				"StartDate": $("#p_StartDate").val(),
				"EndDate": $("#p_EndDate").val(),
				"SearchTxt": "",
				"jobType": "",
				"jobList": "",
				"pageSize": 20,
				"pageNo": 1,
				"RetireUser": "N",
				"Mode": "All"
			},
			success: function(data){
				var user = data.user;
				
				if(user.length > 0){
					for(var i = 0; i < user.length; i++){
						var userInfo = user[i];
						
						var SumTotalTimeHour = userInfo.SumTotalTimeHour;
						
						// 사용자 정보  - 금월 업무 시간
						if(UserCode == userInfo.UserCode){
							if(SumTotalTimeHour == ""){
								$(".workportalTop .userInformation ul li").eq(1).find("strong").text(0);						
							}else{
								$(".workportalTop .userInformation ul li").eq(1).find("strong").text(Number(SumTotalTimeHour.split("h")[0]));		
							}
						}	
					} 
				}else{
					//조회할 목록이 없습니다.
				}	
			}
		});
	}
	
	function getDeptList(){
		$.ajax({
			url: "/groupware/layout/getDeptSchList.do",
			async: false,
			type: "POST",
			dataType: "json",
			success: function(data){
				var subDeptList = data.subDeptList;
				var subDeptOption = "<option value=''><spring:message code='Cache.lbl_Whole'/></option>"; //전체
				
				for(var i = 0; i < subDeptList.length; i++){
					var SortDepth = subDeptList[i].SortDepth;
					subDeptOption += "<option value='"+subDeptList[i].GroupCode+"'>"+subDeptList[i].TransMultiDisplayName+"</option>";
				}
				
				$(".deptList").html(subDeptOption);
				$(".deptList").val(DeptCode); // 사용자의 부서를 기본으로 선택함
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			}
		}); 	
	}
	
	function setMyWork(mode){
		$.getJSON("/groupware/biztask/getAllMyTaskList.do", {userCode: UserCode, stateCode: ""}, function(data){
			var projectTaskDaily = data.ProjectTaskList;
			var taskDaily = data.TaskList;
			var delayHTML = '';
			var pendingHTML = '';
			var todayWorkHTML = '';
			
			delay_num = 0;
			waiting_num = 0;
			progress_num = 0;
			complete_num = 0;
			
			// 프로젝트 > 업무 목록 처리
			if(mode != "Task"){
				projectTaskDaily.forEach(function(item){
					var inlineHTML = "";
					var progress = 0;
					var dDayStr = item.DelayDay > 0 ? "D+"+item.DelayDay : item.DelayDay == 0 ? "D-0" : "D"+item.DelayDay;
					var colorClass = "";
					
					if(item.DelayDay <= 0){
						colorClass = "color01";
					}else{
						colorClass = "color03";
					}
					
					if(item.Progress != ""){
						progress = item.Progress;
					}
					
					if(item.State == "Process"){
						inlineHTML += '<li onclick="clickTFDailyList('+item.CU_ID+');">';
						inlineHTML += '<a href="#">';
						inlineHTML += '<span class="OWList_title"><spring:message code="Cache.lbl_Project"/></span>'; // 프로젝트
						inlineHTML += '<span class="OWList_number"><span class="dday-info '+colorClass+'">'+dDayStr+'</span>'+item.ATName+'</span>';
						inlineHTML += '<span class="OWList_date">~ '+item.EndDate+'</span>';
						inlineHTML += '<span class="OWList_participation"><div class="participationRateBar color01"><div style="width:'+progress+'%;"></div></div><span>'+progress+'%</span></span>';
						inlineHTML += '</a>';
						inlineHTML += '</li>';
					}
					
					if(item.State == "Process" && item.DelayDay > 0){
						if(delay_num < 3){
							delayHTML += inlineHTML;
						}
						
						delay_num++;
					}else{
						if(progress_num < 3){
							pendingHTML += inlineHTML;
						}
						
						switch(item.State){
							case "Waiting":
								waiting_num++;
								break;
							case "Process":
								todayWorkHTML += '<li class="clearFloat" onclick="editTask(\'tf\', '+item.CU_ID+', '+item.AT_ID+');">';
								todayWorkHTML += '<a href="#">';
								todayWorkHTML += '<div class="exeInfoTxt">';
								if(item.DelayDay == 0){
									todayWorkHTML += '<span class="PrcountStyle c01"><spring:message code="Cache.lbl_UntilToday"/></span>'; // 오늘까지
								}else{
									todayWorkHTML += '<span class="PrcountStyle c02">'+dDayStr+'</span>';
								}
								todayWorkHTML += '<p class="exeTit">'+item.ATName+'</p>';
								todayWorkHTML += '<p class="exPer"><spring:message code="Cache.lbl_Project"/> <spring:message code="Cache.lbl_TFProgressing"/>: '+progress+'% | ~'+item.EndDate+'</p>'; // 프로젝트 진행율
								todayWorkHTML += '</div>';
								todayWorkHTML += '</a>';
								todayWorkHTML += '</li>';
								
								progress_num++;
								break;
							case "Complete":
								complete_num++;
								break;
						}
					}
				});
			}
			
			if(mode != "TF"){
				// 업무관리 > 업무 목록 처리
				taskDaily.forEach(function(item){
					var inlineHTML = "";
					var progress = 0;
					var dDayStr = item.DelayDay > 0 ? "D+"+item.DelayDay : item.DelayDay == 0 ? "D-0" : "D"+item.DelayDay;
					var colorClass = "";
					
					if(item.DelayDay <= 0){
						colorClass = "color01";
					}else{
						colorClass = "color03";
					}
					
					if(item.Progress != ""){
						progress = item.Progress;
					}
					
					if(item.State == "Process"){
						inlineHTML += '<li onclick="clickTaskDailyList('+item.TaskID+');">';
						inlineHTML += '<a href="#">';
						inlineHTML += '<span class="OWList_title"><spring:message code="Cache.lbl_generalwork"/></span>'; // 일반업무
						inlineHTML += '<span class="OWList_number"><span class="dday-info '+colorClass+'">'+dDayStr+'</span>'+item.Subject+'</span>';
						inlineHTML += '<span class="OWList_date">~ '+item.EndDate+'</span>';
						inlineHTML += '<span class="OWList_participation"><div class="participationRateBar color01"><div style="width:'+progress+'%;"></div></div><span>'+progress+'%</span></span>';
						inlineHTML += '</a>';
						inlineHTML += '</li>';
					}
					
					if(item.State == "Process" && item.DelayDay > 0){
						if(delay_num < 3){
							delayHTML += inlineHTML;
						}
						
						delay_num++;
					}else{
						if(progress_num < 3){
							pendingHTML += inlineHTML;
						}
						
						switch(item.State){
							case "Waiting":
								waiting_num++;
								break;
							case "Process":
								var isOwner = item.OwnerCode == UserCode ? "Y" : "N";
								todayWorkHTML += '<li class="clearFloat" onclick="editTask(\'task\', '+item.FolderID+', '+item.TaskID+', \''+isOwner+'\')">';
								todayWorkHTML += '<a href="#">';
								todayWorkHTML += '<div class="exeInfoTxt">';
								if(item.DelayDay == 0){
									todayWorkHTML += '<span class="PrcountStyle c01"><spring:message code="Cache.lbl_UntilToday"/></span>'; // 오늘까지
								}else{
									todayWorkHTML += '<span class="PrcountStyle c02">'+dDayStr+'</span>';
								}
								todayWorkHTML += '<p class="exeTit">'+item.Subject+'</p>';
								todayWorkHTML += '<p class="exPer"><spring:message code="Cache.lbl_Project"/> <spring:message code="Cache.lbl_TFProgressing"/>: '+progress+'% | ~'+item.EndDate+'</p>'; // 프로젝트 진행율
								todayWorkHTML += '</div>';
								todayWorkHTML += '</a>';
								todayWorkHTML += '</li>';
								
								progress_num++;
								break;
							case "Complete":
								complete_num++;
								break;
						}
					}
				});
			}
			
			// 지연 업무 개수가 99보다 클 때
			if(delay_num > 99){
				$(".workboard .delay_num .num").text("99+");
			}else{
				$(".workboard .delay_num .num").text(delay_num);
			}
			
			// 진행 업무 개수가 99보다 클 때
			if(progress_num > 99){
				$(".workboard .progress_num .num").text("99+");
			}else{
				$(".workboard .progress_num .num").text(progress_num);
			}
			
			// 대기 업무 개수가 99보다 클 때
			if(waiting_num > 99){
				$(".workboard .wait_num .num").text("99+");
			}else{
				$(".workboard .wait_num .num").text(waiting_num);
			}
			
			// 완료 업무 개수가 99보다 클 때
			if(complete_num > 99){
				$(".workboard .complete_num .num").text("99+");
			}else{
				$(".workboard .complete_num .num").text(complete_num);
			}

			// 진행&지연 업무 목록
			if($("#progressTaskList .OWList ul").html() == "" && $("#delayTaskList .OWList ul").html() == ""){
				if(delay_num == 0){ // 지연 업무 개수가 0일때 처리
					$("#delayTaskList .OWList_none").show();
					$("#delayTaskList .OWList").hide();
					$("#delayTaskList .OWList_num").text(delay_num);
					$(".workboard .delay_num .num").text(delay_num);
				}else if(delay_num > 99){ // 지연 업무 개수가 99보다 클 때
					$("#delayTaskList .OWList_num").text("99+");
				}else{
					$("#delayTaskList .OWList_num").text(delay_num);
				}
				
				if(progress_num == 0){ // 진행 업무 개수가 0일때 처리
					$("#progressTaskList .OWList_none").show();
					$("#progressTaskList .OWList").hide();
					$("#progressTaskList .OWList_num").text(progress_num);
					$(".workboard .progress_num .num").text(progress_num);
				}else if(progress_num > 99){ // 진행 업무 개수가 99보다 클 때
					$("#progressTaskList .OWList_num").text("99+");
				}else{
					$("#progressTaskList .OWList_num").text(progress_num);
				}
				
				$("#progressTaskList .OWList ul").html(pendingHTML);
				$("#delayTaskList .OWList ul").html(delayHTML);
			}
			
			// 오늘 할일 목록
			if(todayWorkHTML == ''){
				$(".workboard .TodayWorks ul").hide();
				$(".workboard .TodayWorks .nolist").show();
			}else{
				$(".workboard .TodayWorks ul").html(todayWorkHTML);
			}
			
			// 원형 그래프 처리
			setCircleGraph();
		});
	}
	
	function clickTaskDailyList(taskID){
		getAllTaskList("set", taskID);
	}
	
	function clickTFDailyList(cID){
		clickProjectRoomList($("#TManageWrap .Projectroom-list li[cid="+cID+"]").get(0), cID);
		$(".workstatusTab ul li").eq(1).click();
	}
	
	//업무 정보 조회
	function getTaskData(taskID, folderID){
		$.ajax({
			url: "/groupware/task/getTaskData.do",
			type: "POST",
			async: false,
			data: {
				"TaskID": taskID,
				"FolderID": folderID
			},
			success: function(data){
				var taskInfo = data.taskInfo;
				var fileList = data.fileList;
				var performerList = data.performerList;
				var performerStr = "";
				var performerCodeList = new Array();
				
				// 수행자 코드 리스트 생성(업무 저장용)
				$.each(performerList, function(idx, item){
					if(idx == performerList.length - 1){
						performerStr += item.Name;
					}else{
						performerStr += item.Name + ", ";
					}
					
					performerCodeList.push(item.Code);
				});
				
				$.each(taskList, function(idx, item){
					if(item.TaskID == taskID && item.FolderID == folderID){
						var performerArr = new Array();
						$.each(performerCodeList, function(idx, code){
							performerArr.push({"PerformerCode": code});
						});
						item.PerformerList = performerArr;
						return false;
					}
				});	
				
				// 에디터의 인라인 이미지 처리
				if(/<[a-z][\s\S]*>/i.test(taskInfo.Description)){
					if($("#dext5").html() == ""){
						coviEditor.loadEditor("dext5", {
					    	editorType: g_editorKind,
						    containerID: "tbContentElement",
						    frameHeight: "400",
						    useResize: "N",
					        onLoad: function(){
					        	$("#dext5").css("display", "none");
					        	coviEditor.setBody(g_editorKind, "tbContentElement", taskInfo.Description);
					        }
						});
					}else{
						if(coviEditor.getBodyText(g_editorKind, "tbContentElement") == taskInfo.Description)
							coviEditor.setBody(g_editorKind, "tbContentElement", taskInfo.Description);
						else
							coviEditor.setBody(g_editorKind, "tbContentElement", taskInfo.Description.replaceAll("\n", "<br>"));
					}
				}
				
				$("#detailInfoArea table.workcon_detail_table tr").eq(2).find("td.workcon_detail_02").text(performerStr);
				$("#detailInfoArea table.workcon_detail_table tr").eq(1).find("td.workcon_detail_02").html(taskInfo.Description);
				$("#documentArea .workcon_docment_wrap").empty();
				
				// 업무관리 목록 > 연관문서 탭
				if(fileList != undefined && fileList != null && fileList.length > 0){
					taskFileList = fileList;
					var attFileListCont = $("<ul>").addClass("file_list");
					
					$(".attFileListBox").show();
					$(".attFileListBox").empty();

					$.each(fileList, function(i, item){
						var attFileList = $("<li>");
						var iconClass = "";
						item.Extention = item.Extention.toLowerCase();
						
						if(item.Extention == "ppt" || item.Extention == "pptx"){
							iconClass = "ppt";
						}else if(item.Extention == "excel" || item.Extention == "xlsx" || item.Extention == "xls"){
							iconClass = "fNameexcel";
						}else if(item.Extention == "pdf"){
							iconClass = "pdf";
						}else if(item.Extention == "doc" || item.Extention == "docx"){
							iconClass = "word";
						}else if(item.Extention == "zip" || item.Extention == "rar" || item.Extention == "7z"){
							iconClass = "zip";
						}else if(item.Extention == "jpg" || item.Extention == "gif" || item.Extention == "png"|| item.Extention == "bmp"){
							iconClass = "attImg";
						}else{
							iconClass = "default";
						}
						
						$(attFileList).append($("<a/>").addClass("btn_File").addClass(iconClass).text(item.FileName).append($("<span>").addClass("tx_size").text("("+coviFile.convertFileSize(item.Size)+")")));
						$(attFileList).append($("<div>").addClass("btn-con").append($("<a href='#' onclick='Common.fileDownLoad("+item.FileID+", \""+item.FileName+"\", \""+item.FileToken+"\")'>").addClass("btn-download").text("<spring:message code='Cache.WH_download'/>")).append($("<a href='#' onclick='openFilePreview("+item.FileID+", \""+item.FileToken+"\", \""+item.Extention+"\")'>").addClass("btn-preview").text("<spring:message code='Cache.lbl_preview'/>")));
						$(attFileListCont).append(attFileList);
					});
					
					$("#documentArea .tasklist_none_title").hide();
					$("#documentArea .workcon_docment_wrap").html(attFileListCont);
					
					$("#taskFileControl").empty();
					coviFile.fileInfos = new Array();
					coviFile.renderFileControl("taskFileControl", {listStyle: "table", actionButton: "add", multiple: "true"}, fileList);
				}else{
					$("#taskFileControl").empty();
					coviFile.fileInfos = new Array();
					coviFile.renderFileControl("taskFileControl", {listStyle: "table", actionButton: "add", multiple: "true"});
					$("#documentArea div.workcon_docment_wrap").empty();
					$("#documentArea .tasklist_none_title").show();
				}
				// 연관문서 개수 표시
				$("#taskTabMenu li").eq(1).find("a").text("<spring:message code='Cache.lbl_apv_ConDoc'/>("+fileList.length+")"); // 연관문서
			},
			error: function(response, status, error){
			     CFN_ErrorAjax("/groupware/task/getTaskData.do", response, status, error);
			}
		});
	}
	
	function openFilePreview(fileId, fileToken, extention){
		extention = extention.toLowerCase();
		if(extention == "jpg" ||
				extention == "jpeg" ||
				extention == "png" ||
				extention == "tif" ||
				extention == "bmp" ||
				extention == "xls" ||
				extention == "xlsx" ||
				extention == "doc" ||
				extention == "docx" ||
				extention == "ppt" ||
				extention == "pptx" ||
				extention == "txt" ||
				extention == "pdf" ||
				extention == "hwp"){
			var url = Common.getBaseConfig("MobileDocConverterURL") + "?fileID=" + fileId + "&fileToken=" + encodeURIComponent(fileToken) ;
			CFN_OpenWindow(url, "", "1000px", "700px", "resize");
		}else{
			Common.Warning("<spring:message code='Cache.msg_ConversionNotSupport'/>"); // 변환이 지원되지 않는 형식입니다.
			return false;
		}
	}
	
	function getProjectInfo(cID, mode){
		var returnProgress = 0;
		var formData = new FormData();
		
		$.ajax({
			url: "/groupware/layout/selectTFDetailInfo.do",
			type: "POST",
			async: false,
			data: {
				"CU_ID": cID
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var info = data.TFInfo[0];
					var fileList = data.fileList;
					var progressinfo = data.TFProgressInfo[0];
					
					if(mode == "TF"){
						var memberList = info.TF_Member.split("@");
						var performerStr = "", state = "";
						var progress = 0;
						var state = "";
						// 결재 문서 처리
						var szdoclinksinfo = "";
						var szdoclinks =  info.TF_DocLinks;
						szdoclinks = szdoclinks.replace("undefined^", "");
						szdoclinks = szdoclinks.replace("undefined", "");
						
						if(szdoclinks != ""){
							var adoclinks = szdoclinks.split("^^^");
							tfDocList = adoclinks;
						}
						
						if($(".tfTabList .ITMTeamroomListBox_image img").attr("src") == ""){
							var initialHTML = '<p style="margin-top: 30%; font-weight: bold;">'+info.CommunityName.replaceAll(" ", "").slice(0, 3)+'</p>';
							$(".tfTabList .ITMTeamroomListBox_image").html(initialHTML);
						}
						
						if(progressinfo != null && progressinfo != undefined){
							progress = (Common.getBaseConfig("IsUseWeight") == "Y" ? progressinfo.TF_WProgress : progressinfo.TF_AVGProgress)+"%";
						}
						
						$(".workcon_tit .tfTabList .workcon_tit01 .task-name").text(info.CommunityName);
						$(".workcon_tit .tfTabList .workcon_tit01 .task-info").eq(0).text("<spring:message code='Cache.lbl_Project'/>"); // 프로젝트
						$(".workcon_tit .tfTabList .workcon_tit01 .task-info").eq(1).text("<spring:message code='Cache.lbl_Register'/> : "+info.CreatorName.split(";")[0]); // 등록자
						$("#resourceArea .workcon_mytask_data_wrap .workcon_mytask_data_list").empty();
						$(".workcon_tit .tfTabList .workcon_tit01").off("click");
						$(".workcon_tit .tfTabList .workcon_tit01").on("click", function(){
							goCommunitySite(info.CU_ID);
						});
						
						if(info.Reserved1 != "" && info.Reserved1 != null){
							var agt = navigator.userAgent.toLowerCase();
							
							if(navigator.appName == 'Microsoft Internet Explorer' || (navigator.appName == 'Netscape' && agt.indexOf('trident') != -1) || agt.indexOf("msie") != -1){
								var htmlTag = "<html>";
			 	 				htmlTag += "<head></head>";
			 	 				htmlTag += "<body style='font:15px arial, serif;'>";
			 	 				htmlTag += "<div>";
			 	 				htmlTag += "지원하지 않는 브라우저입니다.</br>";
			 	 				htmlTag += "지원하는 브라우저는 아래와 같습니다.</br>";
			 	 				htmlTag += "&nbsp;  - Chrome </br>";
			 	 				htmlTag += "&nbsp;  - Edge </br>";	
			 	 				htmlTag += "&nbsp;  - Firefox </br>";
			 	 				htmlTag += "&nbsp;  - Safari/iOS Safari";
			 	 				htmlTag += "</div>";
			 	 				htmlTag += "</body>";
			 	 				htmlTag += "</html>";
			 	 				
			 	 				iframeElementContainer = document.getElementById('channelLayer').contentDocument;
			 	 				iframeElementContainer.open();
			 	 				iframeElementContainer.writeln(htmlTag);
			 	 				iframeElementContainer.close();
			 				}else{
			 					var channelServer = Common.getBaseConfig("eumServerUrl");
								var channelDir = "/client/nw/channel/"+info.Reserved1;
								var csjtk = encodeURIComponent("<%= cookieVal%>");
								var channelURL = channelServer+"/manager/na/sso/gate.do?CSJTK="+csjtk+"&dir="+channelDir;
								
								$("#channelLayer").attr("src", channelURL);
			 				}
							
							$(".groupchat-btn-wrap").show();
							$(".worktoktalk").hide();
							$(".workstatusTab li").eq(1).attr("ismsg", "Y");
							$(".groupchat-btn-wrap").removeClass("down");
							$(".groupchat-btn-wrap").addClass("up");
						}else{
							$(".groupchat-btn-wrap").hide();
							$(".worktoktalk").hide();
							$(".workstatusTab li").eq(1).attr("ismsg", "N");
							$(".groupchat-btn-wrap").removeClass("down");
							$(".groupchat-btn-wrap").addClass("up");
							$("#channelLayer").attr("src", "");
						}
						
						if($("#tfFileControl").css("display") == "block"){
							changeFileUploadView();
						}
						
						// 프로젝트 룸 목록 > 자료실
						if(fileList != undefined && fileList != null && fileList.length > 0){
							tfFileList = fileList;
							isChangeTF = true;
							var attFileListCont = $("<ul>").addClass("file_list");
							
							$.each(fileList, function(i, item){
								var attFileList = $("<li>");
								var iconClass = "";
								item.Extention = item.Extention.toLowerCase();
								
								if(item.Extention == "ppt" || item.Extention == "pptx"){
									iconClass = "ppt";
								}else if(item.Extention == "excel" || item.Extention == "xlsx" || item.Extention == "xls"){
									iconClass = "fNameexcel";
								}else if(item.Extention == "pdf"){
									iconClass = "pdf";
								}else if(item.Extention == "doc" || item.Extention == "docx"){
									iconClass = "word";
								}else if(item.Extention == "zip" || item.Extention == "rar" || item.Extention == "7z"){
									iconClass = "zip";
								}else if(item.Extention == "jpg" || item.Extention == "gif" || item.Extention == "png"|| item.Extention == "bmp"){
									iconClass = "attImg";
								}else{
									iconClass = "default";
								}
								
								$(attFileList).append("<input type='checkbox' style='float: left; margin-top: 10px; margin-right: 10px;'>");
								$(attFileList).append($("<div>").append($("<a style='display: inline;'/>").addClass("btn_File").addClass(iconClass).text(item.FileName).append($("<span>").addClass("tx_size").text("("+coviFile.convertFileSize(item.Size)+")"))));
								$(attFileList).append($("<div>").addClass("btn-con").append($("<a href='#' onclick='Common.fileDownLoad("+item.FileID+", \""+item.FileName+"\", \""+item.FileToken+"\")'>").addClass("btn-download").text("<spring:message code='Cache.WH_download'/>")).append($("<a href='#' onclick='openFilePreview("+item.FileID+", \""+item.FileToken+"\", \""+item.Extention+"\")'>").addClass("btn-preview").text("<spring:message code='Cache.lbl_preview'/>")));
								$(attFileListCont).append(attFileList);
							});
							
							$("#resourceArea .tasklist_none_title").hide();
							$("#resourceArea .workcon_docment_wrap").html(attFileListCont);
						}else{
							tfFileList = new Array();
							isChangeTF = true;
							$("#resourceArea .workcon_docment_wrap .file_list").empty();
							$("#resourceArea .tasklist_none_title").show();
						}
						
						info.Description = unescape(info.Description);
						
						// 에디터 인라인 이미지 처리
						if(/<[a-z][\s\S]*>/i.test(info.Description)){
							if($("#dext5").html() == ""){
								coviEditor.loadEditor("dext5", {
							    	editorType: g_editorKind,
								    containerID: "tbContentElement",
								    frameHeight: "400",
								    useResize: "N",
							        onLoad: function(){
							        	$("#dext5").css("display", "none");
							        	coviEditor.setBody(g_editorKind, "tbContentElement", info.Description.replaceAll("\n", "<br>"));
							        }
								});
							}else{
								if(coviEditor.getBodyText(g_editorKind, "tbContentElement") == info.Description)
									coviEditor.setBody(g_editorKind, "tbContentElement", info.Description);
								else
									coviEditor.setBody(g_editorKind, "tbContentElement", info.Description.replaceAll("\n", "<br>"));
							}
						}
						
						$(".tfTabList .workcon_tit02 .workcon_detail_info").eq(0).find(".selectType04 option").prop("selected", false);
						$(".tfTabList .workcon_tit02 .workcon_detail_info").eq(0).find(".selectType04 option[value="+info.AppStatus+"]").prop("selected", true);
						$(".tfTabList .workcon_tit02 .workcon_detail_info").eq(1).find(".progressText").text(progress);
					}else if(mode == "save"){
						var PMArr = info.TF_PM.split("@");
						var PMCodes = "", PMTxts = "";
						var AdminArr = info.TF_Admin.split("@");
						var AdminCodes = "", AdminTxts = "";
						var MemberArr = info.TF_Member.split("@");
						var MemberCodes = "", MemberTxts = "";
						
						$.each(PMArr, function(idx, item){
							PMCodes += item.split("|")[0] + ";";
							PMTxts += item.split("|")[1] + ";";
						});
						
						$.each(AdminArr, function(idx, item){
							AdminCodes += item.split("|")[0] + ";";
							AdminTxts += item.split("|")[1] + ";";
						});
						
						$.each(MemberArr, function(idx, item){
							MemberCodes += item.split("|")[0] + ";";
							MemberTxts += item.split("|")[1] + ";";
						});
						
						formData.append("CU_ID", info.CU_ID);
						formData.append("Category", info.DN_ID);
						
						formData.append("txtMajorDeptCode", info.TF_MajorDeptCode);
						formData.append("txtMajorDept", info.TF_MajorDept);
						
						formData.append("txtStart", info.TF_StartDate);
						formData.append("txtEnd", info.TF_EndDate);
						
						formData.append("txtPMCount", PMArr.length);
						formData.append("txtPMCode", PMCodes);
						formData.append("txtPM", PMTxts);
						
						formData.append("txtAdminCount", AdminArr.length);
						formData.append("txtAdminCode", AdminCodes);
						formData.append("txtAdmin", AdminTxts);
						
						formData.append("txtMemberCount", MemberArr.length);
						formData.append("txtMemberCode", MemberCodes);
						formData.append("txtMember", MemberTxts);
						
						formData.append("fileInfos", JSON.stringify(tfFileList));
						
					    for(var i = 0; i < coviFile.files.length; i++){
					    	if(typeof coviFile.files[i] == "object"){
					    		formData.append("files", coviFile.files[i]);
					        }
					    }
					    
					    formData.append("fileCnt", tfFileList.length);
						
						formData.append("txtDocLinks", tfDocList.join("^^^"));	
						
						formData.append("frontStorageURL", escape(smart4jPathUrl+ frontStorageUrl));

						if(!/<[a-z][\s\S]*>/i.test(info.Description)){
							formData.append("txtContentSize", info.Description.length);
							formData.append("txtContent", info.Description);
							formData.append("txtContentEditer", "");
							formData.append("txtContentInlineImage", "");
							formData.append("ContentOption", "N");
						}else{
							formData.append("txtContentSize", coviEditor.getBodyText(g_editorKind, "tbContentElement").length);
							formData.append("txtContent", coviEditor.getBodyText(g_editorKind, "tbContentElement"));
							formData.append("txtContentEditer", coviEditor.getBody(g_editorKind, "tbContentElement"));
							formData.append("txtContentInlineImage", coviEditor.getImages(g_editorKind, "tbContentElement"));
							formData.append("ContentOption", "Y");
						}
						
					}
				}
			},
			error: function(error){
				CFN_ErrorAjax("/groupware/project/getProjectInfoOne.do", response, status, error);
			}
		});
		
		if(mode == "Pro"){
			return returnProgress;
		}else if(mode == "save"){
			return formData;
		}
	}
	
	function getAllTaskList(stateCode, targetTaskID){
		$.getJSON("/groupware/biztask/getAllMyTaskList.do", {"userCode": UserCode, "stateCode": stateCode == undefined || stateCode == "set" ? "" : stateCode}, function(data){
			taskList = data.TaskList;
			var taskManageStr = '';
			
			if(taskList.length != 0){
				// 프로젝트 > 업무 목록 처리
				taskList.forEach(function(item){
					var progress = item.Progress == "" ? 0 : item.Progress;
					
					if(item.State == "Complete"){
						taskManageStr += '<li taskID='+item.TaskID+' class="complete" onclick="clickTaskList(this);">';
					}else{
						taskManageStr += '<li taskID='+item.TaskID+' onclick="clickTaskList(this);">';
					}
					
					taskManageStr += '<div class="check">';
					taskManageStr += '<div class="chkStyle">';
					taskManageStr += '<input type="checkbox"><label for="chk01" onclick="chkTaskManage(this)"><span></span></label>';
					taskManageStr += '</div>';
					taskManageStr += '</div>';
					taskManageStr += '<div class="con-link" onclick="showTaskManage(this)">';
					taskManageStr += '<a href="#" class="task-txt">';
					taskManageStr += '<span class="task-name">'+item.Subject+'</span>';
					taskManageStr += '<span class="task-info">';
					taskManageStr += '<span class="txt_status">'+item.TaskState+'</span>';
					taskManageStr += '<span class="txt_deadline">~'+item.EndDate.replaceAll("-", ".")+'</span>';
					taskManageStr += '<span class="task-List_participation"><div class="participationRateBar color02"><div style="width:'+progress+'%;"></div></div><span>'+progress+'%</span></span>';
					taskManageStr += '</span>';
					taskManageStr += '</a>';
					taskManageStr += '</div>';
					taskManageStr += '</li>';
				});
				
				$("#taskList .tasklist_none_title").hide();
				$("#taskList ul.Taskmanagement-list").html(taskManageStr);
				
				if(stateCode != "set"){
					$("#taskList ul li .con-link").eq(0).click();
				}else{
					clickTaskList($("#taskList .Taskmanagement-list li[taskid="+targetTaskID+"]").get(0));
					showTaskManage($("#taskList .Taskmanagement-list li[taskid="+targetTaskID+"] .con-link").get(0));
					$(".workstatusTab ul li").eq(2).click();
				}
			}else{
				$("#taskList ul.Taskmanagement-list").empty();
				$("#taskList .tasklist_none_title").show();
				$(".workportal-rightCon").hide();
			}
		});
	}
	
	function clickTaskList(thisObj){
		$("#taskList .Taskmanagement-list li").removeClass("active"); 
		$(thisObj).addClass("active");
	}
	
	function filterTaskList(){
		$("#TaskFilterMenu").toggle();
	}
	
	function setProjectList(){
		$.ajax({
			url: "/groupware/layout/selectUserMyTFGridList.do",
			type: "post",
			data: {
				"pageNo": 1,
				"pageSize": 10,
				"searchWord": "",
				"searchType": "",
				"AppStatus": "",
				"sortColumn": "",
				"sortDirection": ""
			},
			success: function(data){
				var tfStr = '';
				var list = data.list;
				tfList.push(data);
				
				if(list.length != 0){
					list.forEach(function(item, idx){
						if(item.AppStatus == "RV" || item.AppStatus == "RC" || item.AppStatus == "RW"){
							var progress = Common.getBaseConfig("IsUseWeight") == "Y" ? item.TF_WProgress : item.TF_AVGProgress;
							var endDate = item.TF_Period.split("~")[1];
							var initial = item.CommunityName.replaceAll(" ", "").slice(0,3);
							var eDate = new Date(endDate.replaceAll(".", "/"));
							var rDate = new Date(CFN_GetLocalCurrentDate().replaceAll("-", "/"));
							
							if(item.AppStatus == "RC"){ // 완료된 프로젝트일 때
								tfStr += '<li cid='+item.CU_ID+' class="complete" onclick="clickProjectRoomList(this, '+item.CU_ID+');">';							
							}else{
								tfStr += '<li cid='+item.CU_ID+' onclick="clickProjectRoomList(this, '+item.CU_ID+');">';
							}
							
							tfStr += '<div class="con-link">';
							tfStr += '<a href="#" class="task-txt">';
							
							if(item.FilePath == ""){ // 사진이 없을 때
								tfStr += '<div class="ITMTeamroomListBox_image" style="background-color:white;"><p style="margin-top: 30%; font-weight: bold;">'+initial+'</p></div>';							
							}else{
								tfStr += '<div class="ITMTeamroomListBox_image"><img src="'+coviCmn.loadImage(item.FilePath)+'" onerror="this.src=\'/covicore/resources/images/no_image.jpg\'"></div>';
							}
							
							tfStr += '<span class="task-name">'+item.CommunityName+'</span>';
							tfStr += '<span class="task-info">';
							tfStr += '<span class="txt_status">'+item.AppStatusName+'</span>';
							tfStr += '<span class="txt_deadline">~'+endDate+'</span>';
							tfStr += '<span class="task-List_participation"><div class="participationRateBar color02"><div style="width:'+progress+'%;"></div></div><span>'+progress+'%</span></span>';
							tfStr += '</span>';
							tfStr += '</a>';
							tfStr += '<a href="#" class="chart-btn" onclick="showDetailStatus('+item.CU_ID+', \''+item.CommunityName+'\')"></a>';
							tfStr += '</div>';
							tfStr += '</li>';
						}
					});
					
					// 프로젝트 룸 관리 탭 목록
					$("#tfList .tasklist_none_title").hide();
					$("#tfList ul.Projectroom-list").html(tfStr);
				}else{
					$("#tfList .tasklist_none_title").show();
					$(".workportal-rightCon").hide();
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/biztask/getHomeProjectListData.do", response, status, error);
			}
		});
	}
	
	function clickProjectRoomList(thisObj, cID){
		$("#TManageWrap .Projectroom-list li").removeClass("active");
		$(thisObj).addClass("active");
		$(".tfTabList .ITMTeamroomListBox_image").html('<img src="" onerror="this.src=\'/covicore/resources/images/no_image.jpg\'">');
		$(".tfTabList .ITMTeamroomListBox_image img").attr("src", $(thisObj).find(".mCS_img_loaded").attr("src"));
		showTFManage(cID);
		chkTFEditAuth(cID);
	}
	
	// 업무 관리 탭 목록에서 체크하면 리스트의 스타일과 데이터를 변경함
	function chkTaskManage(thisObj){
		var idx = $("#taskList .Taskmanagement-list li").index($(thisObj).closest("li"));
		var chObj = $("#taskList ul.Taskmanagement-list li").eq(idx);
		
		$(chObj).toggleClass("complete");
		showTaskManage($(thisObj).closest("li").find(".con-link")); // 업무를 저장하기 전, 해당 업무에 대한 정보를 가져옴
		
		if($(chObj).hasClass("complete")){
			$(".taskTabList .workcon_tit02 .workcon_detail_info .selectType04").prop("selected", false);
			$(".taskTabList .workcon_tit02 .workcon_detail_info").eq(0).find(".selectType04 option[value=Complete]").prop("selected", true);
			$(".taskTabList .workcon_tit02 .workcon_detail_info").eq(1).find(".selectType04").val(100);
		}else{
			$(".taskTabList .workcon_tit02 .workcon_detail_info").eq(0).find(".selectType04 option[value=Process]").prop("selected", true);
			$(".taskTabList .workcon_tit02 .workcon_detail_info .selectType04").prop("selected", false);
		}
		
		saveTask(idx);
	}
	
	// 원형 그래프 처리
	function setCircleGraph(){
		var totalNum = waiting_num+progress_num+delay_num+complete_num;
		
		if(totalNum != 0){
			var perArr = [
							{
								percent: waiting_num/totalNum*100,
								style: "40px solid #5FCAFA"
			            	}, 
			            	{
								percent: progress_num/totalNum*100,
								style: "40px solid #6892F2"
			            	}, 
			            	{
								percent: delay_num/totalNum*100,
								style: "40px solid rgb(49, 112, 212)"
			            	}, 
			            	{
								percent: complete_num/totalNum*100,
								style: "40px solid rgb(38, 172, 244)"
			            	}
						];
			
			perArr.sort(function(a, b) {
			    return a.percent > b.percent ? -1 : a.percent < b.percent ? 1 : 0;
			});
			
			$(".cycleSlice").removeClass("gt50");
			
			$.each(perArr, function(idx, item){
				if(idx == 0){
					$(".cycleTotal .pie").css("border", item.style);
				}else{
					var percent = 0;
					
					for(var i = idx; i < perArr.length; i++){
						percent += perArr[i].percent;
					}
					
					$(".cycleSlice").eq(idx-1).find(".pie").css("border", item.style);
					$(".cycleSlice").eq(idx-1).find(".pieDiv").css("transform", "rotate(" + (3.6*percent) + "deg)");
					
					if(percent > 49) {
						$(".cycleSlice").eq(idx-1).addClass("gt50");
					}
				}
			});
			
			$("#myTaskTxt").text(totalNum);
		}else{
			$(".cycleTotal .pie").css("border", "40px solid rgb(221, 221, 221)");
			$(".cycleSlice .pie").css("border", "40px solid rgb(221, 221, 221)");
			$(".pieDiv").css("transform", "rotate(0deg)");
			$("#myTaskTxt").text("0");
		}
	}
	
	function setApprovalList(mode){
		mode = mode == undefined || mode == "" ? "TotalProcess" : mode;
		
		// 결재 문서 목록 가져오기
		$.ajax({
			url: "/approval/user/getApprovalListData.do?&mode="+mode,
			type: "POST",
			data: {
				pageNo: 1,
				pageSize: 4,
				searchType: "FormSubject",
				searchWord: "",
				searchGroupType: "all",
				searchGroupWord: "",
				startDate: "",
				endDate: "",
				sortColumn: "",
				sortDirection: "",
				isCheckSubDept: 0,
				bstored: "false",
				userID: UserCode,
				titleNm: "",
				userNm: "",
				selectDateType: ""
			},
			success: function(data){
				var apvListStr = '';
				var totalApvList = data.list;
				
				if(totalApvList != null && totalApvList != ""){
					$(totalApvList).each(function(idx, item){
						apvListStr += '<li class="clearFloat">';
						apvListStr += '<div class="exePhoto">';
						apvListStr += '<p><img src="'+coviCmn.loadImage(item.PhotoPath)+'" alt="프로필사진" class="mCS_img_loaded" onerror="coviCmn.imgError(this);"></p>';
						apvListStr += '</div>';
						
						if("Mode" in item){
							if(item.Mode == "Approval"){
								apvListStr += '<div class="exeInfoTxt Proceed" onclick="clickApprovalList(event)">'; // 미결함
							}else{
								apvListStr += '<div class="exeInfoTxt Proceed" onclick="clickApprovalProgressList(event)">'; // 진행함
							}
						}else{
							if(mode == "Approval"){
								apvListStr += '<div class="exeInfoTxt Proceed" onclick="clickApprovalList(event)">'; // 미결함
							}else{
								apvListStr += '<div class="exeInfoTxt Proceed" onclick="clickApprovalProgressList(event)">'; // 진행함
							}
						}
						
						if(item.ReadDate == ""){
							apvListStr += '<a href="#"><p class="exeTit unread">'+item.FormSubject+'</p></a>';
						}else{
							apvListStr += '<a href="#"><p class="exeTit read">'+item.FormSubject+'</p></a>';
						}
						
						apvListStr += '<p class="exepart">';
						apvListStr += '<span class="fcStyle">';
						
						// 날짜 포맷
						var StartDate;
						if(mode == "Approval"){
							StartDate = item.Created.split(" ")[0].slice(5, 10);
							apvListStr += '<a class="ProceedBtn" href="#"><spring:message code="Cache.tte_ApprovalListBox" /></a>'; // 미결함
						}else{
							StartDate = item.StartDate.split(" ")[0].slice(5, 10);
							
							if(mode == "Process"){
								apvListStr += '<a class="ProceedBtn" href="#"><spring:message code="Cache.tte_ProcessListBox" /></a>'; // 진행함
							}else{
								if(item.Mode == "Approval"){
									apvListStr += '<a class="ProceedBtn" href="#"><spring:message code="Cache.tte_ApprovalListBox" /></a>'; // 미결함
								}else if(item.Mode == "Process"){
									apvListStr += '<a class="ProceedBtn" href="#"><spring:message code="Cache.tte_ProcessListBox" /></a>'; // 진행함
								}
							}
						}
						StartDate = StartDate.replaceAll("-", ".");
						apvListStr += '</span>';
						apvListStr += '<span class="fcStyle">'+item.InitiatorName+'</span><span class="fcStyle">'+StartDate+'</span>';
						apvListStr += '</p>';
						apvListStr += '</div>';
						apvListStr += '<div class="exeBtnCont">';
						apvListStr += '<a class="MWR_T" href="#" onclick="isDocReg = true;">task</a>';
						apvListStr += '</div>';
						apvListStr += '</li>';
					});
					
					$(".Approval .MWR_time").html(apvListStr);
				}
				
				// 결재 문서 목록 클릭 이벤트
				$(".Approval .MWR_time li").on("click", function(e){
					var idx = $(".Approval .MWR_time li").index(this);

					// 결재문서 - 연관문서 등록 이벤트 처리
					if(isDocReg){				
						documentRegist("Approval", totalApvList[idx].FormSubject, totalApvList[idx].ProcessID+"@@@"+totalApvList[idx].FormPrefix+"@@@"+totalApvList[idx].FormSubject+"@@@"+totalApvList[idx].FormInstID+"@@@false");
						$("#ApprovalRegistPopup_if").load(function(){
							getFormInfo(totalApvList[idx].Mode, totalApvList[idx].ProcessID, totalApvList[idx].WorkItemID, totalApvList[idx].PerformerID, totalApvList[idx].ProcessDescriptionID, totalApvList[idx].FormSubKind);
							approvalType = "CreatePdf";
						});
					}
									
					// 전자결재 진행함 옵션 이벤트
					$("#ApprovalProgressMenu li").off("mousedown");
					$("#ApprovalProgressMenu li").on("mousedown", function(){
						var state = $(this).find("a").attr("state");
						
						switch(state){
							case "ApprovalStateCheck": // 결재현황보기
								CFN_OpenWindow("/approval/user/ApprovalDetailList.do?FormInstID="+totalApvList[idx].FormInstID+"&ProcessID="+totalApvList[idx].ProcessID, "", "510", "300", "resize");
								break;
							case "ApprovalCommentView": // 의견보기
								approvalType = "showCommentView";
								getFormInfo(totalApvList[idx].Mode, totalApvList[idx].ProcessID, totalApvList[idx].WorkItemID, totalApvList[idx].PerformerID, totalApvList[idx].ProcessDescriptionID, totalApvList[idx].FormSubKind);
								break;
							case "ApprovalFormShortcut": // 양식 바로가기
								openApprovalPopup(totalApvList[idx].Mode,totalApvList[idx].ProcessID,totalApvList[idx].WorkItemID,totalApvList[idx].PerformerID,totalApvList[idx].ProcessDescriptionID,totalApvList[idx].FormSubKind,totalApvList[idx].FormInstID,totalApvList[idx].FormID,UserCode,totalApvList[idx].FormPrefix);
								break;
						}
					});
					
					// 전자결재 미결함 옵션 이벤트
					$("#ApprovalListMenu li").off("mousedown");
					$("#ApprovalListMenu li").on("mousedown", function(){
						var state = $(this).find("a").attr("state");
						
						switch(state){
							case "Approved": // 승인
								approvalType = "approved";
								chkApprovalPassword("Approval", totalApvList[idx]);
								break;
							case "Rejected": // 반려
								approvalType = "reject";
								chkApprovalPassword("Reject", totalApvList[idx]);
								break;
							case "ApprovalFormShortcut": // 양식 바로가기
								openApprovalPopup(totalApvList[idx].Mode,totalApvList[idx].ProcessID,totalApvList[idx].WorkItemID,totalApvList[idx].PerformerID,totalApvList[idx].ProcessDescriptionID,totalApvList[idx].FormSubKind,totalApvList[idx].FormInstID,totalApvList[idx].FormID,UserCode,totalApvList[idx].FormPrefix);
								break;
						}
					});
				});
			},
			error: function(response, status, error){
				//CFN_ErrorAjax(url, response, status, error);
				setApprovalList();
			}
		});
	}
	
	// 결재 문서 목록 필터링
	function filterApprovalList(){
		$("#ApprovalFilterMenu").toggle();
	}
	
	// 결재 문서 첨부파일 세팅
	function setApvFileList(){
		var fileInfos = $.parseJSON($("#IframeSerialApprovalFrm").get(0).contentWindow.getInfo("FileInfos"));
		var resFileInfos = $("#ApprovalRegistPopup_if").get(0).contentWindow.coviFile.fileInfos;
		var fileStr = '';
		//var apvAttachFilePath = "";
		//var osType = Common.getGlobalProperties("Globals.OsType");
		
		// fileid로 경로 조회하도록 변경
		//if(osType == "WINDOWS"){
			//apvAttachFilePath = Common.getGlobalProperties("attachWINDOW.path");
			//apvAttachFilePath = apvAttachFilePath.substr(0, apvAttachFilePath.length - 1) + Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + Common.getBaseConfig("ApprovalAttach_SavePath");
		//}else{
			//apvAttachFilePath = Common.getGlobalProperties("attachUNIX.path")
			//apvAttachFilePath = apvAttachFilePath.substr(0, apvAttachFilePath.length - 1) + Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + Common.getBaseConfig("ApprovalAttach_SavePath");
		//}
		
		if(fileInfos.length != 0){
			$.each(fileInfos, function(idx, item){
				var filePath = ""; //apvAttachFilePath + item.FilePath;
				var fileName = item.FileName;
				var iconClass = "";
				 
				if(item.Extention == "ppt" || item.Extention == "pptx"){
					iconClass = "ppt";
				}else if(item.Extention == "excel" || item.Extention == "xlsx" || item.Extention == "xls"){
					iconClass = "xls";
				}else if(item.Extention == "pdf"){
					iconClass = "pdf";
				}else if(item.Extention == "doc" || item.Extention == "docx"){
					iconClass = "doc";
				}else if(item.Extention == "zip" || item.Extention == "rar" || item.Extention == "7z"){
					iconClass = "zip";
				}else{
					iconClass = "etc";
				}
				
				fileStr += '<p class="files_title"><span class="ic_'+iconClass+'"></span><span class="file_name">'+item.FileName+'</span><a class="filedelete" onclick="deleteFileList(this);">삭제</a></p>';
				$("#ApprovalRegistPopup_if").get(0).contentWindow.pdfInfo.push({"fileName": fileName, "fileSize": item.Size, "savePath": filePath, "saveFileName": item.SavedName, "fileID" : item.FileID});
			});
			
			$("#ApprovalRegistPopup_if").contents().find("#relationDocumentRegist dl").eq(6).find("dd").html(fileStr);
		}
	}
	
	// 결재 문서 정보 가져오기
	function getFormInfo(Mode, ProcessID, WorkItemID, PerformerID, ProcessDescriptionID, subkind){
		var url = "/approval/approval_Form.do?mode="+Mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+UserCode+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"";
		url += "&gloct=APPROVAL&formID=&forminstanceID=&formtempID=&forminstancetablename=&admintype=&archived=false&usisdocmanager=true";
		$("#IframeSerialApprovalFrm").attr("src", url);
	}
	
	// 결재문서 양식 팝업 오픈
	function openApprovalPopup(mode, ProcessID, WorkItemID, PerformerID, ProcessDescriptionID, SubKind, FormInstID, FormID, userCode, FormPrefix){
		var width, gloct;
		var archived = "false";
		
		switch(mode){
			case "Approval": // 미결함
				mode = "APPROVAL"; 
				gloct = "APPROVAL"; 
				break;
			case "Process": // 진행함
				mode = "PROCESS"; 
				gloct = "PROCESS"; 
				break;
		}
		
		if(IsWideOpenFormCheck(FormPrefix) == true){
			width = 1070;
		}else{
			width = 790;
		}
		
		CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userCode+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+SubKind+"", "", width, (window.screen.height - 100), "resize");
	}
	
	function chkApprovalPassword(apvMode, approvalList){
		Common.Confirm("<spring:message code='Cache.msg_127' />", "Confirmation Dialog", function(confirm){ // 처리 하시겠습니까?
			if(chkUsePasswordYN()){
				Common.Password("<spring:message code='Cache.msg_enter_PW' />", null, "<spring:message code='Cache.lbl_apv_ApvPwd_Check' />", function(password){ // 비밀번호를 입력하여 주십시오. 결재암호 확인
					if(password){
						if(password.indexOf("e1Value:") > -1){ //생체인증 처리  
							this.fidoCallBack = function(){
								getApprovalLine(apvMode, approvalList);
							}
							Common.open("", "checkFido", "<spring:message code='Cache.lbl_RequestUserAuth' />", "/covicore/control/checkFido.do?logonID="+UserCode+"&authType=Approval", "400px", "510px", "iframe", true, null, null, true); //사용자 본인인증 요청
						}else{
							if(chkCommentWrite(password) && password != ""){
								getApprovalLine(apvMode, approvalList);
							}else{
								Common.Warning("<spring:message code='Cache.msg_PasswordChange_02' />"); // 비밀번호를 정확하게 입력하여 주십시오.
							}
						}
					}else{
						Common.Warning("<spring:message code='Cache.msg_PasswordChange_02' />"); // 비밀번호를 정확하게 입력하여 주십시오.
					}
				});
				
				// 생체인증 버튼 제어
				setTimeout(function(){
					var oTargetObj = $("#alert_container").find("#popup_e1")
					$(oTargetObj).find("strong").text("<spring:message code='Cache.lbl_Biometrics' />"); // 생체인증
					$(oTargetObj).show();
				}, 350);
			}else{
				getApprovalLine(apvMode, approvalList);
			}
		});
	}
	
	var arrDomainDataList = new Array();
	function getApprovalLine(apvMode, approvalList){
		var processIDs = new Array();
		var oApprovalList = {"approvalList" : approvalList};
		
		if($$(oApprovalList).find("approvalList").concat().length > 0)
			processIDs = $$(oApprovalList).find("approvalList").concat().attr("ProcessID");
		
		// 체크항목 결재선 조회
		if($$(oApprovalList).find("approvalList").concat().length > 0){
			$.ajax({
				url: "/approval/getBatchApvLine.do",
				data: {
					"processIDArr": processIDs.toString()
				},
				type: "post",
				success: function(res){
					if(res.length > 0){
						$(res).each(function(i, obj){
							arrDomainDataList[$$(obj).attr("ProcessID")] = obj.DomainDataContext;
						});
						doEngineApproval(apvMode, approvalList);
					}else{
						Common.Inform("<spring:message code='Cache.msg_apv_319' />"); // 처리할 결재문서가 없습니다.
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/approval/getBatchApvLine.do", response, status, error);
				}
			});
		}else{
			Common.Inform("<spring:message code='Cache.msg_apv_319' />"); // 처리할 결재문서가 없습니다.
		}
	}
	
	function doEngineApproval(apvMode, approvalList){
		var actionMode = "";
		var subkind = approvalList.FormSubKind;
		var taskId = approvalList.TaskID;
		var mode = "APPROVAL";
		var sSign = getUserSignInfo(UserCode);
		
		if(subkind == "T009" || subkind == "T004"){ // 합의 및 협조
			actionMode = "AGREE";
			mode = "PCONSULT";
		}else if((subkind == "C" || subkind == "AS") && approvalType == "DEPT"){
			actionMode = "REDRAFT";
			mode = "SUBREDRAFT";
		}else{
			mode = "APPROVAL";
			
			if(apvMode == "Approval"){
				actionMode = "APPROVAL";
			}else{
				actionMode = "REJECT";
			}
		}
		
	    var sJsonData = {};
	    $.extend(sJsonData, {"mode": mode});
	    $.extend(sJsonData, {"subkind": subkind});
	    $.extend(sJsonData, {"taskID": taskId});
    	$.extend(sJsonData, {"FormInstID" : approvalList.FormInstID});
	    $.extend(sJsonData, {"actionMode": actionMode});
	    $.extend(sJsonData, {"actionComment": ""});
	    $.extend(sJsonData, {"actionComment_Attach": "[]"});
	    $.extend(sJsonData, {"signimagetype": sSign});
	    $.extend(sJsonData, {"gloct": ""});
	    $.extend(sJsonData, {"isBatch": "Y"}); // 일괄결재 표시여부
	    
	    if(approvalList.ApvLine != undefined){
	    	$.extend(sJsonData, {"processID": approvalList.ProcessID});
	    	$.extend(sJsonData, {"ChangeApprovalLine": approvalList.ApvLine});
	    }
	    
	    // 대결자가 결재하는 경우 결재선 변경
	    if(arrDomainDataList[approvalList.ProcessID] != null && arrDomainDataList[approvalList.ProcessID] != undefined) {
	    	var apvList = setDeputyList(mode, subkind, taskId, actionMode, "", approvalList.FormInstID, "N", approvalList.ProcessID, approvalList.UserCode);
		    
		    if(apvList != arrDomainDataList[approvalList.ProcessID]){
		    	$.extend(sJsonData, {"processID" : approvalList.ProcessID});
		    	$.extend(sJsonData, {"ChangeApprovalLine" : apvList});
		    }	
	    }
	    
	    var formData = new FormData();
	    formData.append("formObj", Base64.utf8_to_b64(JSON.stringify(sJsonData)));
	    
		$.ajax({
			url: "/approval/draft.do",
			data: formData,
			type: "post",
			dataType: "json",
			processData: false,
	        contentType: false,
			success: function(res){
				if(res.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_ProcessOk' />"); // 요청하신 작업이 정상적으로 처리되었습니다.
					setApprovalList();
				}else{
					Common.Inform("<spring:message code='Cache.msg_ErrorOccurred' />"); // 오류가 발생하였습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/approval/draft.do", response, status, error);
			}
		});
	}
	
	function createPdf(fileName){
		$.ajax({
			url: "/approval/common/createPdf.do",
			type: "POST",
			data: {
				txtHtml: printDiv,
				filename: fileName
			},
			async: false,
			success: function(data){
				data.fileName = decodeURI(data.fileName);
				$("#ApprovalRegistPopup_if").get(0).contentWindow.pdfInfo.push(data);
			},
			error: function(response, status, error){
				//CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	// 메일 리스트 처리
	function setMailList(){
		var mailInfo = null;
		var mailInfo_del = {
			"boxName": "INBOX",
			"msgId": null,
			"sender": null,
			"uid": null
		};
		// 메일 리스트 가져올 때 필요한 옵션
		var opts = {
			useMail: UR_Mail,
			detailMap: "",
			mailBox: "INBOX",
			page: 1,
			replyToList: null,
			sortType: "",
			threadsRowNum: 0,
			type: "MAILLIST",
			type2: "ALL",
			userMail: UR_Mail,
			viewNum: "4"
		};

		// 메일 리스트 가져오기
		MessageAPI.getList(
			UR_Mail, opts
		).done(function(data){
			if(data != null && data != ""){
				var fieldList = data[0].mailList;
				var mailStr = '';
				$(fieldList).each(function(idx, item){
					var resDateArr = item.mailReceivedDateStr.split(" ")[0].split("-");
					var resDate = resDateArr[1]+"."+resDateArr[2];
					mailStr += '<li class="clearFloat">';
					
					if(item.flag == "\\Seen"){
						mailStr += '<div class="exemail read">';
						mailStr += '<img src="<%=cssPath%>/covicore/resources/images/common/workportal/ic_drafts.png">';
						mailStr += '</div>';
						mailStr += '<div class="exeInfoTxt">';
						mailStr += '<p class="exeName read" onclick="clickMailList(event)"><a href="#">'+item.mailSender+'</a><span class="exeDate">'+resDate+'</span></p>';
						mailStr += '<p class="exepart read" onclick="clickMailList(event)"><a href="#"><span class="fcStyle">'+item.subject+'</span></a></p>';
						mailStr += '</div>';
					}else{
						mailStr += '<div class="exemail unread">';
						mailStr += '<img src="<%=cssPath%>/covicore/resources/images/common/workportal/ic_markunread.png">';
						mailStr += '</div>';
						mailStr += '<div class="exeInfoTxt">';
						mailStr += '<p class="exeName unread" onclick="clickMailList(event)"><a href="#">'+item.mailSender+'</a><span class="exeDate">'+resDate+'</span></p>';
						mailStr += '<p class="exepart unread" onclick="clickMailList(event)"><a href="#"><span class="fcStyle">'+item.subject+'</span></a></p>';
						mailStr += '</div>';
					}
					
					mailStr += '<div class="exeBtnCont">';
					mailStr += '<a class="MWR_T" href="#" onclick="isDocReg=true;">task</a>';
					mailStr += '</div>';
					mailStr += '</li>';
				});
				
				$(".Mail ul.MWR_time").html(mailStr);
				
				$(".Mail ul li").off("click");
				$(".Mail ul li").on("click", function(){
					var idx = $(".Mail ul li").index(this);
					mailInfo_del.msgId = fieldList[idx].mailId;
					mailInfo_del.sender = fieldList[idx].mailSenderAddr;
					mailInfo_del.uid = fieldList[idx].uid;
					mailInfo = fieldList[idx];
					
					if(isDocReg){
						documentRegist("Mail", mailInfo.subject);
						$("#MailRegistPopup_if").load(function(){
							createEml(UR_Mail, JSON.stringify([{"uid": mailInfo.uid, "boxName": "INBOX"}]));
						});
						isDocReg = false;
					}
				});
			}else{
				setMailList();
			}
		});
		
		// 메일 리스트 클릭 > 부가 옵션 클릭 이벤트 - 회신, 전체회신, 전달, 삭제, 메일 상세보기
		$("#MailContextMenu li").off("mousedown");
		$("#MailContextMenu li").on("mousedown", function(){
			var state = $(this).find("a").attr("state");
			var mailInfo_list;
			// 기본 url(회신, 전체회신, 전달)
			_query = "/mail/userMail/goMailWindowWritePopup.do?";
			_queryParam = {
				uid: (mailInfo === undefined) ? undefined : mailInfo.uid,
				folderNm: (mailInfo === undefined) ? undefined : mailInfo.folderTy,
				userMail: UR_Mail,
				inputUserId: DN_Code + "_" + UserCode,
				messageId: (mailInfo === undefined) ? undefined : mailInfo.mailId.replace("%3C", "<").replace("%3E", ">"),
				popup: "Y",
				replyType: null,
				type: null
			};
            
			// 메일 부가 옵션 클릭 이벤트 분기
			switch(state){
				case "MailReply": // 회신
					_queryParam.replyType = "MAILREPLY";
					_queryParam.type = "MAILREPLY";
			 		_query += $(_queryParam).serializeQuery();
			 		window.open(_query, "Mail Reply" + stringGen(10), "height=700, width=1000");
					break;
				case "MailAllReply": // 전체 회신
					_queryParam.replyType = "ALL";
					_queryParam.type = "ALL";
					_query += $(_queryParam).serializeQuery();
					window.open(_query, "Mail All Reply" + stringGen(10), "height=700, width=1000");
					break;
				case "MailRelay": // 전달
					_queryParam.replyType = "MAILRELAYTEXT";
					_queryParam.type = "MAILRELAYTEXT";
					_query += $(_queryParam).serializeQuery();
					window.open(_query, "Mail Relay" + stringGen(10), "height=700, width=1000");
					break;
				case "MailDelete": // 삭제
					Common.Confirm("<spring:message code='Cache.msg_Common_08' />", "Confirmation Dialog", function(result){ // 선택한 항목을 삭제하시겠습니까?
						if(result){
							mailInfo_list = [mailInfo_del];
							MessageAPI.deleteMessage(UR_Mail, "INBOX", "MD", mailInfo_list).done(function(){
								$(".Mail ul.MWR_time").empty();
								setMailList();
							});
							Common.Inform("<spring:message code='Cache.msg_DeleteResult' />"); // 성공적으로 삭제되었습니다
						}
					});
					break;
				case "MailDetail": // 메일 상세보기
					_query = "/mail/userMail/goMailWindowPopup.do?";
					_queryParam = {
						messageId: (mailInfo === undefined) ? undefined : mailInfo.mailId.replace("%3C", "<").replace("%3E", ">"),
						folderNm: (mailInfo === undefined) ? undefined : mailInfo.folderTy,
						viewType: "LST",
						sort: "",
						uid: (mailInfo === undefined) ? undefined : mailInfo.uid,
						userMail: UR_Mail,
						inputUserId: DN_Code + "_" + UserCode,
						popup: "Y",
						CLSYS: "mail",
						isSendMail: undefined
					};
					_query += $(_queryParam).serializeQuery();
					window.open(_query, "Mail Read" + stringGen(10), "height=700, width=1000");
					setTimeout(function(){
						$(".Mail ul.MWR_time").empty();
						setMailList();
					}, 5000);
					break;
			}
		});
	}
	
	function createEml(userMail, emlInfos){
		$.ajax({
			url: "/mail/userMail/createEml.do",
			type: "POST",
			data: {
				inputUserMail: userMail,
				inputEmlTarget: emlInfos,
				inputReadMessageId: "", 
				inputMailBox: "INBOX"
			},
			async: false,
			success: function(data){
				$("#MailRegistPopup_if").get(0).contentWindow.emlInfo = data;
			},
			error: function(response, status, error){
				//CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	function showTaskManage(thisObj){
		var idx = $("#taskList .Taskmanagement-list li .con-link").index(thisObj);
		var taskObj = taskList[idx];
		var progress = taskObj.Progress == "" ? "0" : taskObj.Progress >= 100 ? 100 : taskObj.Progress;
		
		$(".workcon_wrap").show();
		$(".workportal-rightCon").show();
		$(".taskTabList .workcon_tit02").attr("index", idx);
		
		var userName = getUserName(taskObj.RegisterCode);
		
		$(".taskTabList .workcon_tit01 .task-name").text(taskObj.Subject);
		$(".taskTabList .workcon_tit01 .task-info span").eq(0).text("<spring:message code='Cache.lbl_generalwork'/>"); // 일반업무
		$(".taskTabList .workcon_tit01 .task-info span").eq(1).text("<spring:message code='Cache.lbl_Register'/> : "+userName); // 등록자
		
		if(UserCode == taskObj.OwnerCode){
			$(".taskTabList .workcon_tit02 .workcon_detail_info .selectType04").prop("disabled", false);
			$(".taskTabList .workcon_detail_info .edit").addClass("active");
			$(".taskTabList .workcon_detail_info .edit").text("<spring:message code='Cache.lbl_Modifiable'/>"); // 수정가능
		}else{
			$(".taskTabList .workcon_tit02 .workcon_detail_info .selectType04").prop("disabled", true);
			$(".taskTabList .workcon_detail_info .edit").removeClass("active");
			$(".taskTabList .workcon_detail_info .edit").text("<spring:message code='Cache.lbl_UnableModify'/>"); // 수정불가
		}
		
		// 업무의 경로를 구함
		folderPath = "";
		var taskPath = getFolderPath(taskObj.FolderID, taskObj.OwnerCode != UserCode ? "Y" : "N");
		
		$("#detailInfoArea .workcon_detail_table tr").eq(0).find(".workcon_detail_02").text(taskPath);
		$(".taskTabList .workcon_tit02 .workcon_detail_info .selectType04 option").prop("selected", false);
		$(".taskTabList .workcon_tit02 .workcon_detail_info").eq(0).find(".selectType04 option[value="+taskObj.State+"]").prop("selected", true);
		$(".taskTabList .workcon_tit02 .workcon_detail_info").eq(1).find(".selectType04 option[value="+progress+"]").prop("selected", true);
		
		// 업무 정보 가져오기
		getTaskData(taskObj.TaskID, taskObj.FolderID);
		
		// 댓글창 표시
		setCommentView(taskObj);
		
		// 댓글 개수 가져오기
		getCommentCount(taskObj.TaskID);
	}
	
	// 업무 부모 폴더 경로 가져오기
	function getFolderPath(parentID, IsShare){
		if(parentID != 0){
			var folderInfo = getFolderInfo(parentID);
			
			if(IsShare == "Y"){
				folderPath = folderInfo.DisplayName + " > " + folderPath;
			}else{
				folderPath = folderInfo.DisplayName + " > " + folderPath;
			}
				
			getFolderPath(folderInfo.ParentFolderID, IsShare);
		}else{
			if(IsShare == "Y"){
				folderPath = "<spring:message code='Cache.lbl_Share_Task' />" + " > " + folderPath; // 같이 하는 일
			}else{
				folderPath = "<spring:message code='Cache.lbl_Person_Task' />" + " > " + folderPath; // 내가 하는 일
			}
		}
		
		return folderPath.slice(0, folderPath.length - 3);
	}
	
	function getFolderInfo(folderID){
		var folderInfo = null;
		
		$.ajax({
			url: "/groupware/task/getFolderData.do",
			type: "POST",
			async: false,
			data: {
				"FolderID": folderID
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					folderInfo = data.folderInfo;
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getMyInfo.do", response, status, error);
			}
		});
		
		return folderInfo;
	}
	
	// 사용자 이름 가져오기
	function getUserName(userId){
		var userName = "";
		
		$.ajax({
			url: "/covicore/control/getMyInfo.do",
			type: "POST",
			async: false,
			data: {
				"userId": userId
			},
			success: function(res){
				if(res.data){
					userName = res.data.DisplayName;
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getMyInfo.do", response, status, error);
			}
		});
		
		return userName;
	}
	
	//댓글 개수 가져오기
	function getCommentCount(TaskID){
		$.ajax({
			type: "POST",
		    url: "/covicore/comment/getCommentCount.do",
	        data: {
	        	"TargetType": "Task",
	        	"TargetID": TaskID
	        },
	        success: function(res){
	        	var commCount = res.data;
	    		$("#taskTabMenu li").eq(0).find("a").text("<spring:message code='Cache.lbl_Comments'/>("+commCount+")"); // 댓글
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/comment/getCommentCount.do", response, status, error);
       		}
	 	});
	}
	
	function showTFManage(cID){
		$(".workcon_wrap").show();
		$("#activityArea").attr("cid", cID);

		// TF 정보 가져오기
		getProjectInfo(cID, "TF");	
		
		// 작업 목록
		setActivityList();
		
		// 게시판 목록
		getBoardList(cID);
		
		// 게시 목록
		getMessageList(cID);
	}
	
	// 작업 목록 표시
	function setActivityList(){
		var cID = $("#activityArea").attr("cid");
		
		if($("#activityArea .workcon_mytask_select").val() == "all"){
			// 작업 목록
			getActivityList(cID);
		}else{			
			// 나의 작업 목록
			getMyActivityList(cID);
		}
	}
	
	function search(){
		setActivityList();
	}
	
	// 게시판 목록 가져오기
	function getBoardList(cID, mode){
		$.ajax({
			type: "POST",
			url: "/groupware/board/selectBoardList.do",
			async: false,
			data: {
				"bizSection": "Board",
				"menuID": cID,
				"communityID": cID
			},
			success: function(data){
				var list = data.list;
	        	
	        	if(mode == "simpleMake"){
					var simpleMakeStr = '<option value=""><spring:message code="Cache.lbl_JvCate" /></option>'; // 카테고리
		        	
					$.each(list, function(idx, item){
						simpleMakeStr += '<option value="'+cID+"_"+item.FolderID+'">'+item.DisplayName+'</option>';
					});
					
					$("#boardFolderID").empty();
					$("#boardFolderID").html(simpleMakeStr);
				}else{
					var boardListStr = '';
					
					$.each(list, function(idx, item){
						boardListStr += '<option value="'+item.FolderID+"_"+item.FolderType+'">'+item.DisplayName+'</option>';
					});
					
					$("#boardArea .workcon_mytask_select_wrap select").html(boardListStr);
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	// 게시 목록 가져오기
	function getMessageList(cID){
		var selVal = $("#boardArea .workcon_mytask_select_wrap select option:selected").val();
		
		if(selVal != "" && selVal != null){
			$.ajax({
				type: "POST",
			    url: "/groupware/board/selectMessageGridList.do",
		        data: {
		        	"pageNo": 1,
					"pageSize": 10,
					"bizSection": "Board",
					"boardType": "Normal",
					"viewType": "List",
					"boxType": "Receive",
					"menuID": cID,
					"folderID": selVal.split("_")[0],
					"folderType": selVal.split("_")[1],
					"categoryID": "",
					"searchType": "Subject",
					"searchText": "",
					"useTopNotice": "Y",
					"useUserForm": "",
					"approvalStatus": "R",
					"readSearchType": "",
					"communityID": cID,
					"startDate": "",
					"endDate": ""
				},
		        success: function(data){
		        	var list = data.list;
		        	var msgListStr = '';
		        	
		        	if(data.status == "SUCCESS"){
		        		$.each(list, function(idx, item){
			        		msgListStr += '<li msgID='+item.MessageID+'>';
				        	msgListStr += '<a href="#" class="">';
				        	msgListStr += '<label><input type="checkbox" class="workcon_mytask_chk"></label>';
				        	msgListStr += '<div onclick="showTFBoardView('+item.MenuID+', '+item.FolderID+', '+item.MessageID+', '+cID+')">';
				        	msgListStr += '<span class="workcon_mytask_tit">'+item.Subject+'</span>';
				        	msgListStr += '<span class="workcon_mytask_date">'+item.RegistDate.split(" ")[0]+'</span>';
				        	msgListStr += '</div>';
				        	msgListStr += '</a>';
				        	msgListStr += '</li>';
			        	});
			        	
		        		$("#boardArea .workcon_mytask_wrap ul").empty();
		        		
		        		if(msgListStr == ''){
		        			$("#boardArea .tasklist_none_title").show();
		        		}else{
		        			$("#boardArea .tasklist_none_title").hide();
		        			$("#boardArea .workcon_mytask_wrap ul").html(msgListStr);
		        		}
			        	
			        	$("#tfTabMenu li").eq(1).find("a").text("<spring:message code='Cache.lbl_Boards'/>("+list.length+")"); // 게시판
		        	}else{
		        		("#boardArea .workcon_mytask_wrap ul").empty();
			        	$(".tabMenu li").eq(1).find("a").text("<spring:message code='Cache.lbl_Boards'/>(0)"); // 게시판
		        	}
				},
				error: function(response, status, error){
					CFN_ErrorAjax(url, response, status, error);
	       		}
		 	});
		}
	}
	
	// 삭제 사유 팝업
	function delCommentPopup(){
		var msgIDs = "";
		var len = $("#boardArea .workcon_mytask_list li").length;
		
		for(var i = 0; i < len; i++){
			var isChecked = $("#boardArea .workcon_mytask_list li").eq(i).find(".workcon_mytask_chk").prop("checked");
			
			if(isChecked){
				msgIDs += $("#boardArea .workcon_mytask_list li").eq(i).attr("msgid") + ";";	
			}
		}
		
		if(msgIDs == ""){
			Common.Warning("<spring:message code='Cache.msg_SelectTarget' />"); // 대상을 선택해주세요.
		    return false;
		}
		
		parent._CallBackMethod = new Function("delMessage()");
		parent.Common.open("", "commentPopup", "<spring:message code='Cache.lbl_ReasonForProcessing' />", "/groupware/board/goCommentPopup.do?mode=delete", "280px", "230px", "iframe", true, null, null, true); // 처리 사유
	}
	
	// 게시 삭제
	function delMessage(){
		var cID = $("#activityArea").attr("cid");
		var msgIDs = "";
		var len = $("#boardArea .workcon_mytask_list li").length;
		var params = new Object();
		
		for(var i = 0; i < len; i++){
			var isChecked = $("#boardArea .workcon_mytask_list li").eq(i).find(".workcon_mytask_chk").prop("checked");
			
			if(isChecked){
				msgIDs += $("#boardArea .workcon_mytask_list li").eq(i).attr("msgid") + ";";	
			}
		}
		
		params.bizSection = "Board";
		params.messageID = msgIDs;
		params.comment = $("#hiddenComment").val();
		params.communityId = cID
		params.CSMU = "C";
		
	    $.ajax({
	    	type: "POST",
	    	url: "/groupware/board/deleteMessage.do",
	    	data: params,
	    	success: function(data){
	    		if(data.status == "SUCCESS"){
	    			Common.Inform("<spring:message code='Cache.msg_50' />"); // 삭제되었습니다.
	    			getMessageList(cID);
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_apv_030' />"); //오류가 발생헸습니다.
	    		}
	    	},
	    	error: function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/board/deleteMessage.do", response, status, error);
	    	}
	    });
	}
	
	// 전체 작업 목록 가져오기
	function getActivityList(cID){
		$.ajax({
			type: "POST",
		    url: "/groupware/tf/getActivityList.do",
	        data: {
	        	"pageNo": 1,
				"pageSize": 10,
				"reqType": "A",
				"schContentType": undefined,
				"schTxt": undefined,
				"simpleSchTxt": undefined,
				"CU_ID": cID,
				"startDate": undefined,
				"endDate": undefined
			},
	        success: function(data){
				var list = data.list;
				var taskStr = '';
				
				$.each(list, function(idx, item){
					taskStr += '<li at_id='+item.AT_ID+'>';
					taskStr += '<a href="#" class="">';
					taskStr += '<label><input type="checkbox" class="workcon_mytask_chk"></label>';
					taskStr += '<div onclick="editTask(\'tf\', '+item.CU_ID+', '+item.AT_ID+');">';
					taskStr += '<span class="workcon_mytask_tit">'+item.ATName+'</span>';
					taskStr += '<span class="workcon_mytask_date">'+item.StartDate+'~'+item.EndDate+'</span>';
					taskStr += '<span class="workcon_mytask_percent"><strong>'+item.Progress+'</strong>%</span>';
					taskStr += '</div>';
					taskStr += '</a>';
					taskStr += '</li>';
				});
				
				$("#activityArea .workcon_mytask_wrap ul").empty();
				
				if(taskStr == ''){
					$("#activityArea .tasklist_none_title").show();
				}else{
					$("#activityArea .tasklist_none_title").hide();
					$("#activityArea .workcon_mytask_wrap ul").html(taskStr);
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	// 나의 작업 목록 가져오기
	function getMyActivityList(cID){
		$.ajax({
			type: "POST",
		    url: "/groupware/tf/getMyActivityList.do",
	        data: {
	        	"pageNo": 1,
				"pageSize": 10,
	        	"reqType": "A",
				"schContentType": undefined,
				"schTxt": undefined,
				"simpleSchTxt": undefined,
				"CU_ID": cID,
				"startDate": undefined,
				"endDate": undefined
			},
	        success: function(data){
	        	var list = data.list;
	        	var myTaskStr = '';
	        	
	        	$.each(list, function(idx, item){
	        		myTaskStr += '<li at_id='+item.AT_ID+'>';
	        		myTaskStr += '<a href="#" class="">';
	        		myTaskStr += '<div onclick="editTask(\'tf\', '+item.CU_ID+', '+item.AT_ID+');">';
	        		myTaskStr += '<label><input type="checkbox" class="workcon_mytask_chk"></label>';
	        		myTaskStr += '<span class="workcon_mytask_tit">'+item.ATName+'</span>';
	        		myTaskStr += '<span class="workcon_mytask_date">'+item.StartDate+'~'+item.EndDate+'</span>';
	        		myTaskStr += '<span class="workcon_mytask_percent"><strong>'+item.Progress+'</strong>%</span>';
	        		myTaskStr += '</div>';
	        		myTaskStr += '</a>';
	        		myTaskStr += '</li>';
	        	});
	        	
	        	$("#activityArea .workcon_mytask_wrap ul").html(myTaskStr);
			},
			error: function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
       		}
	 	});
	}
	
	// 연관 문서 등록
	function documentRegist(mode, fileName, docLink){	
		Common.open("", mode+"RegistPopup", "<spring:message code='Cache.lbl_apv_ConDoc' /> <spring:message code='Cache.lbl_Regist' />", "/groupware/biztask/goRelationDocumentRegistPopup.do?mode="+mode+"&fileName="+fileName+"&docLink="+docLink, "430px", "340px", "iframe", true, null, null, true); // 연관 문서
	}
	
	// 진행함 리스트 부가 옵션 클릭 이벤트
	function clickApprovalProgressList(e){
		$("#ApprovalProgressMenu").show();
		
    	var posX = e.clientX - pxToNumber($("#ApprovalProgressMenu").css("width"))/1.85;
        var posY = e.clientY - pxToNumber($("#ApprovalProgressMenu").css("height"))/1.2;
		
    	$("#ApprovalProgressMenu").css("left", posX+"px");
    	$("#ApprovalProgressMenu").css("top", posY+"px");
    }
	
	// 미결함 리스트 부가 옵션 클릭 이벤트
	function clickApprovalList(e){
		$("#ApprovalListMenu").show();		
		
    	var posX = e.clientX - pxToNumber($("#ApprovalListMenu").css("width"))/1.85;
        var posY = e.clientY - pxToNumber($("#ApprovalListMenu").css("height"))/1.2;
       
    	$("#ApprovalListMenu").css("left", posX+"px");
    	$("#ApprovalListMenu").css("top", posY+"px");
    }
	
	// 메일 리스크 부가 옵션 클릭 이벤트
	function clickMailList(e){
		$("#MailContextMenu").show();
		
    	var posX = e.clientX - pxToNumber($("#MailContextMenu").css("width"))/2;
        var posY = e.clientY - pxToNumber($("#MailContextMenu").css("height"))/2;
		
    	$("#MailContextMenu").css("left", posX+"px");
    	$("#MailContextMenu").css("top", posY+"px");
    }
	
	// 업무 추가 창 띄우기
	function addTask(){
		Common.open("", "AddTask", "<spring:message code='Cache.lbl_task_addTask' />", "/groupware/task/goTaskSetPopup.do?mode=Add&isOwner=Y&folderID=0", "1000px", "700px", "iframe", true, null, null, true); // 업무추가
	}
	
	function editTask(mode, parentID, objectID, isOwner){
		var height = isOwner=="Y"? "650px": "570px";
		
		if(mode == "tf"){
			Common.open("", "ActivitySet", "<spring:message code='Cache.lbl_Edit' />", "/groupware/tf/goActivitySetPopup.do?mode=MODIFY&CLSYS=TF&CLMD=user&CLBIZ=TF&CSMU=T&C="+parentID+"&ActivityId="+objectID+"&isOwner="+isOwner, "950px", "650px", "iframe", true, null, null, true); // 수정
		}else{
			Common.open("", "taskSet", "<spring:message code='Cache.lbl_task_taskManage' />", "/groupware/task/goTaskSetPopup.do?mode=Modify&isOwner="+isOwner+"&taskID="+objectID+"&folderID="+parentID+"&isSearch=N", "950px", height, "iframe", true, null, null, true); // 업무관리
		}
	}
	
	// 업무 수정
	function saveTask(idx){
		var taskObj = taskList[idx];
		var formData = new FormData();
		var state = $(".taskTabList .workcon_tit02 .workcon_detail_info").eq(0).find(".selectType04 option:selected").val();
		var progress = $(".taskTabList .workcon_tit02 .workcon_detail_info").eq(1).find(".selectType04 option:selected").val(); 
		var stateVal = "";
		
		var task = {
			"TaskID": taskObj.TaskID,
			"FolderID": taskObj.FolderID,
			"Subject": taskObj.Subject,
			"State": state,
			"Progress": progress,
			"StartDate": taskObj.StartDate,
			"EndDate": taskObj.EndDate,
			"InlineImage": "",
			"Description": "",
			"PerformerList": taskObj.PerformerList
		};
		
		if(!/<[a-z][\s\S]*>/i.test(taskObj.Description)){
			task.Description = taskObj.Description;
		}else{
			task.InlineImage = coviEditor.getImages(g_editorKind, "tbContentElement");
			task.Description = coviEditor.getBody(g_editorKind, "tbContentElement");
		}
		
		formData.append("mode", "U");
		formData.append("taskStr", JSON.stringify(task));
	    
	    formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
	    
	    for(var i = 0; i < coviFile.files.length; i++){
	    	if(typeof coviFile.files[i] == "object"){   		
	    		formData.append("files", coviFile.files[i]);
	        }
	    }
	    formData.append("fileCnt", coviFile.fileInfos.length);
	    
		$.ajax({
			url: "/groupware/task/saveTaskData.do",
			type: "post",
			async: false,
			data: formData,
			contentType: false,
			processData: false,
		    success: function(res){
		    	if(res.status == "SUCCESS"){
		    		var stateStr = "";
		    		
		    		switch(state){
			    		case "Process":
			    			stateStr = "<spring:message code='Cache.lbl_Progressing' />"; // 진행중
			    			break;
			    		case "Complete":
			    			stateStr = "<spring:message code='Cache.lbl_Completed' />"; // 완료
			    			break;
			    		case "Waiting":
			    			stateStr = "<spring:message code='Cache.lbl_Ready' />"; // 대기
			    			break;
		    		}
		    		
		    		$(".Taskmanagement-list li").eq(idx).find(".txt_status").text(stateStr);
		    		$(".Taskmanagement-list li").eq(idx).find(".task-List_participation .participationRateBar div").css("width", progress+"%");
		    		$(".Taskmanagement-list li").eq(idx).find(".task-List_participation span").text(progress+"%");
		    		$(".taskTabList .task-List_participation .participationRateBar div").css("width", progress+"%");
		    		$(".taskTabList .workcon_space .selectType04").prop("selected", false);
					$(".taskTabList .workcon_space .selectType04").eq(0).find("option[value="+state+"]").prop("selected", true);
					$(".taskTabList .workcon_tit02 .selectType04").eq(1).val(progress);
					
		    		// 변경된 값이 완료일 때 완료 표시를 해줌
		    		if(state == "Complete"){
		    			var chObj = $("#taskList .Taskmanagement-list li").eq(idx);
			    		if($(chObj).hasClass("complete") == false){
			    			$(chObj).addClass("complete");
			    		}
		    		}
		    		getTaskData(taskObj.TaskID, taskObj.FolderID);
				}else{
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //오류가 발생했습니다.
				}    	
		    },
	       error: function(response, status, error){
			CFN_ErrorAjax("saveFolderData.do", response, status, error);
		   }
		});
	}
	
	function getFolderItemList(){}
	
	//프로젝트 작업 추가
	function addActivity(){
		var cID = $("#activityArea").attr("cid");
		
		Common.open("", "ActivitySet", "<spring:message code='Cache.btn_Add' />", "/groupware/tf/goActivitySetPopup.do?mode=ADD&CLSYS=TF&CLMD=user&CLBIZ=TF&CSMU=T&C="+cID, "950px", "650px", "iframe", true, null, null, true);
	}
	
	// 프로잭트 작업 삭제
	function deleteActivity(){
		var cID = $("#activityArea").attr("cid");
		var params = new Object();
		var AT_IDs = "";
		var len = $("#activityArea .workcon_mytask_list li").length;
		
		for(var i = 0; i < len; i++){
			var isChecked = $("#activityArea .workcon_mytask_list li").eq(i).find(".workcon_mytask_chk").prop("checked");
			
			if(isChecked){
				AT_IDs += $("#activityArea .workcon_mytask_list li").eq(i).attr("at_id") + ";";	
			}
		}
		
		if(AT_IDs == ""){
			Common.Warning("<spring:message code='Cache.msg_SelectTarget' />"); //대상을 선택해주세요.
		    return false;
		}
		params.AT_ID = AT_IDs;
		params.communityId = cID;
		
      	Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function(confirmResult){ // 삭제하시겠습니까?
			if(confirmResult){
		 		$.ajax({
					type: "POST",
					data: params,
					url: "/groupware/tf/deleteTask.do",
					success: function(data){
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_50' />"); // 삭제되었습니다.
							search();
	          			}else{
		          			Common.Warning("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
	          			}
					},
					error: function(response, status, error){
						CFN_ErrorAjax(url, response, status, error);
					}
				});
			}else{
				return false;
			}
		});
	}
	
	function showTFBoardView(menuID, folderID, msgID, cID){
		var url = "/groupware/layout/board_BoardView.do?CLSYS=board&CLMD=user&CLBIZ=Board&menuID="+menuID+"&version=1&folderID="+folderID+"&messageID="+msgID+"&viewType=List&startDate=&endDate=&sortBy=&searchText=&searchType=Subject&boxType=Receive&communityId="+cID+"&CSMU=C";
		CFN_OpenWindow(url, "", "1050px", "900px", "resize");
	}
	
	// 프로젝트 룸 추가 팝업
	function addProject(){
		Common.open("", "TFRoomPopup", "<spring:message code='Cache.lbl_Project' /> <spring:message code='Cache.btn_Add' />", "/groupware/layout/goTFTeamRoomPopup.do?CLSYS=TF&CLMD=user&CLBIZ=TF", "950px", "650px", "iframe", true, null, null, true);
	}
	
	// 프로젝트 상태 확인 팝업
	function showDetailStatus(projectCode, projectName){
		var pUrl = "/groupware/biztask/ProjectDetailStatus.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask&PrjCode="+projectCode+"&mode=A&prjName="+projectName;
		Common.open("", "ProjectDetailStatusPopup", projectName, pUrl, "930px", "500px", "iframe", true, null, null, true); // 연관 문서
	
		$("#ProjectDetailStatusPopup_if").ready(function(){
			$("#ProjectDetailStatusPopup_if").hide();
		});
		
		$("#ProjectDetailStatusPopup_if").load(function(){
			$("#ProjectDetailStatusPopup_if").contents().find(".cRConTop").hide();
			$("#ProjectDetailStatusPopup_if").contents().find(".cRContBottom").css("top", "0");
			$("#ProjectDetailStatusPopup_if").contents().find(".tabMenu > li").css("height", "30px");
			$("#ProjectDetailStatusPopup_if").contents().find(".tabMenu > li").css("line-height", "30px");
			$("#ProjectDetailStatusPopup_if").contents().find("#btnWrite").removeAttr("onclick");
			$("#ProjectDetailStatusPopup_if").contents().find("#btnWrite").off().on("click", function(){
				var cID = $("#ProjectDetailStatusPopup_if").get(0).contentWindow.communityId;
				parent.Common.open("","ActivitySet","<spring:message code='Cache.btn_Add' />","/groupware/tf/goActivitySetPopup.do?mode=ADD&CLSYS=TF&CLMD=user&CLBIZ=TF&CSMU=T&C="+cID ,"950px", "650px","iframe", true,null,null,true);
			});
			$("#ProjectDetailStatusPopup_if").show();
		});
	}
	
	function goCommunitySite(cID){
		 var specs = "left=10,top=10,width=1050,height=900,toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
		 window.open("/groupware/layout/userCommunity/communityMain.do?C="+cID+"&IsAdmin=Y", "community", specs);
	}
	
	function setTFStatus(cID, appStatus){
		$.ajax({
			url: "/groupware/layout/userCommunity/setCommunityStatus.do",
			type: "post",
			data: {
				"CU_ID": cID,
				"RegStatus": "P",
				"AppStatus": appStatus,
				"txtOperator": UserCode
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var statusName = "";
					Common.Inform("<spring:message code='Cache.msg_ProcessOk' />"); // 요청하신 작업이 정상적으로 처리되었습니다.
					
					if(appStatus == "RC"){
						$("#tfList ul li.active").addClass("complete");
					}else{
						$("#tfList ul li.active").removeClass("complete");
					}
					
					switch(appStatus){
						case "RV":
							statusName = "<spring:message code='Cache.lbl_Progress' />"; // 진행
							break;
						case "RC":
							statusName = "<spring:message code='Cache.lbl_Completed' />"; // 완료
							break;
						case "RW":
							statusName = "<spring:message code='Cache.lbl_Stop' />"; // 중지
							break;
					}
					
					$("#tfList ul li.active .task-info .txt_status").text(statusName);
					$("#tfList ul li.active").click();
				}else{
					Common.Inform("<spring:message code='Cache.msg_ErrorOccurred' />"); // 오류가 발생하였습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/biztask/getHomeProjectListData.do", response, status, error);
			}
		});
	}
	
	function changeFileUploadView(){
		$("#resourceArea .file_list").toggle();
		if($("#resourceArea .file_list li").length == 0){
			$("#resourceArea .tasklist_none_title").toggle();
		}
		$("#resourceArea #tfFileControl").toggle();
		$("#resourceArea .workcon_bottom_btn a").toggle();
	}
	
	function renderFileUpload(){
		changeFileUploadView();
		
		if(isChangeTF){
			if(tfFileList != null && tfFileList.length > 0){
				$("#tfFileControl").empty();
				coviFile.fileInfos = new Array();
				coviFile.renderFileControl("tfFileControl", {listStyle: "table", actionButton: "add", multiple: "true"}, tfFileList);
			}else{
				$("#tfFileControl").empty();
				coviFile.fileInfos = new Array();
				coviFile.renderFileControl("tfFileControl", {listStyle: "table", actionButton: "add", multiple: "true"});
			}
			$("#resourceArea #tfFileControl #coviFileTooltip").closest("div[onmouseover]").hide();
			isChangeTF = false;
		}
	}
	
	function setFileUploadValue(){
		var cID = $("#activityArea").attr("cid");
		var formData = getProjectInfo(cID, "save");	
		
		formData.set("fileInfos", JSON.stringify(coviFile.fileInfos));
	    formData.set("fileCnt", coviFile.fileInfos.length);
		
		saveTF(formData);
	}
	
	// 팀룸 설정 수정 권한 조회
	function chkTFEditAuth(cID){
		$.ajax({
			url: "/groupware/layout/userTF/TFBoardLeft.do",
			type: "POST",
			data: {
				CU_ID: cID
			},
			success: function(data){
				var TFPMLevel = Common.getBaseConfig("TFPMLevel");
				var TFAdminLevel = Common.getBaseConfig("TFAdminLevel");
				var TFMemberLevel = Common.getBaseConfig("TFMemberLevel");
				
				switch(data.memberLevel){
					case TFAdminLevel:
						$("#resourceArea .workcon_bottom_btn").css("visibility", "visible");
						$(".tfTabList .workcon_tit02 .selectType04").prop("disabled", true);
						$(".tfTabList .workcon_detail_info .edit").eq(0).removeClass("active");
						$(".tfTabList .workcon_detail_info .edit").eq(0).text("<spring:message code='Cache.lbl_UnableModify'/>"); // 수정불가
						break;
					case TFPMLevel:
						$("#resourceArea .workcon_bottom_btn").css("visibility", "visible");
						$(".tfTabList .workcon_tit02 .selectType04").prop("disabled", false);
						$(".tfTabList .workcon_detail_info .edit").eq(0).addClass("active");
						$(".tfTabList .workcon_detail_info .edit").eq(0).text("<spring:message code='Cache.lbl_Modifiable'/>"); // 수정가능
						break;
					case TFMemberLevel:
						$("#resourceArea .workcon_bottom_btn").css("visibility", "hidden");
						$(".tfTabList .workcon_tit02 .selectType04").prop("disabled", true);
						$(".tfTabList .workcon_detail_info .edit").eq(0).removeClass("active");
						$(".tfTabList .workcon_detail_info .edit").eq(0).text("<spring:message code='Cache.lbl_UnableModify'/>"); // 수정불가
				}
			},
			error: function(error){
				CFN_ErrorAjax("/groupware/layout/userTF/TFBoardLeft.do", response, status, error);
			}
		});
	}
	
	// 프로젝트 룸 결재 문서, 첨부파일 삭제
	function deleteTFFile(){
		var cID = $("#activityArea").attr("cid");
		var len = $("#resourceArea .file_list li").length;
		var idxs = "";

		for(var i = 0; i < len; i++){
			var isChecked = $("#resourceArea .file_list li").eq(i).find("input").prop("checked");
			
			if(isChecked){
				var idx = $("#resourceArea .file_list li").index($("#resourceArea .file_list li").eq(i));
				
				idxs += idx;
				tfFileList.splice(idx, 1);
				$("#resourceArea .file_list li").eq(i).remove();
				len--;
				i--;
			}
		}
		
		if(idxs == ""){
			Common.Warning("<spring:message code='Cache.msg_SelectTarget' />"); //대상을 선택해주세요.
		    return false;
		}
		
		$("#tfFileControl").empty();
		coviFile.fileInfos = new Array();
		coviFile.renderFileControl("tfFileControl", {listStyle: "table", actionButton: "add", multiple: "true"}, tfFileList);
		
		var formData = getProjectInfo(cID, "save");
		saveTF(formData);
	}
	
	// 프로젝트 룸 설정 수정
	function saveTF(formData){
		var cID = $("#activityArea").attr("cid");
		
		Common.Confirm("<spring:message code='Cache.msg_RUEdit'/>", "Confirmation Dialog", function(confirmResult){ // 수정하시겠습니까?
			if(confirmResult){
				$.ajax({
					url: "/groupware/layout/updateTFTeamRoom.do",
					type: "post",
					async: false,
					data: formData,
					dataType: "json",
					processData: false,
					contentType: false,
					success: function(data){
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_Edited'/>"); // 수정되었습니다
							getProjectInfo(cID, "TF");
						}else{ 
							Common.Warning("<spring:message code='Cache.msg_38'/>"); // 오류로 인해 저장 하지 못 하였습니다.
						}
					},
					error: function(response, status, error){
						CFN_ErrorAjax(url, response, status, error);
					}
				}); 
			}else{
				getProjectInfo(cID, "TF");
			}
		});
	}
	
	// 프로젝트 게시 등록
	function TFBoardWrite(){
		var cID = $("#activityArea").attr("cID");
		var folderID = $("#boardArea .workcon_mytask_select_wrap select option:selected").val().split("_")[0];
		// 간단 게시 등록 팝업
		coviCtrl.toggleSimpleMake(); 
		$(".simpleMakeLayerPopUp .tabMenuArrow li[type=Board]").click();
		getBoardList(cID, "simpleMake");
		
		$(".simpleMakeLayerPopUp #btnBoardWrite").on("click", function(){
			showTFManage(cID);
		});
		
		$("#boardFolderID").on("change", function(){
			if(!board.checkFolderWriteAuth($(this).val().split("_")[1])){ //폴더별 권한 체크
				Common.Warning("<spring:message code='Cache.msg_UNotWriteAuth'/>", "Warning Dialog", function(){ // 쓰기권한이 없습니다!
					$("#boardFolderID").val("");
				});
			}
			$("#checkBoardChange").val("true");
		});
		
		$("#btnSimpleWrite").on("click", function(){
			$(".simpleMakeLayerPopUp #btnBoardWrite").off("click").on('click', function(){
				var simpleMenuID = $('#boardFolderID').val().split("_")[0];
				var simpleFolderID = $('#boardFolderID').val().split("_")[1];
				board.createSimpleMessage(simpleFolderID, simpleMenuID);
			});
			
			$("#boardFolderID").coviCtrl("setSelectOption","/groupware/board/selectSimpleBoardList.do", {}, "<spring:message code='Cache.lbl_JvCate'/>", ""); // 카테고리
		});
	}
	
	// 업무관리 댓글 창 표시
	function setCommentView(taskObj){
		var userId = UserCode;
		var isOwner = (taskObj.RegisterCode == userCode || taskObj.OwnerCode == userCode)? "Y" : "N";
		var receiverList = taskObj.RegisterCode;
		var messageSetting;
		var msgContext;
		var goToUrl;
		var mobileUrl;
		
		if(taskObj.RegisterCode != taskObj.OwnerCode){
			receiverList += ";" + taskObj.OwnerCode;
		}
		
		msgContext = String.format('<spring:message code="Cache.msg_task_replyMessage" />', taskObj.Subject, UR_Name); // {0} 업무에 대해서 {1}님이 댓글을 남기셨습니다.
		goToUrl = String.format("{0}/groupware/task/goTaskSetPopup.do?mode=Modify&isOwner={1}&taskID={2}&folderID={3}&isSearch=&CFN_OpenLayerName=taskSet", smart4jPathUrl, isOwner, taskObj.TaskID, taskObj.FolderID);
		mobileUrl = String.format("{0}/groupware/mobile/task/view.do?isowner={1}&taskid={2}&folderid={3}", smart4jPathUrl, isOwner, taskObj.TaskID, taskObj.FolderID);
		messageSetting = {
			SenderCode: userId,
			RegistererCode: userId,
			ReceiversCode: receiverList,
			MessagingSubject: taskObj.Subject,
			MessageContext: msgContext, 
			ReceiverText: taskObj.Subject,
			GotoURL: goToUrl,
		    PopupURL: goToUrl,
		    MobileURL: mobileUrl,
		    Width: "330",
		    Height: "980",
			ServiceType: "Task",
			MsgType: "TaskComment"
		};
		
		// 댓글창 가져오기
		coviComment.load("commentView", "Task", taskObj.TaskID, messageSetting);
	}
	
	function chkMailSession(){
		if(sessionStorage.getItem($("#inputUserId").val()) == null){
			var index = 0;
			var userMail = UR_Mail;
			var isSendMail = "Y";
			var isMailDomainCode = DN_Code;
			var isMailUserCode = UserCode;
			var mailDeptCode = DeptCode;
			var data = sessionStorage.getItem(isMailDomainCode+"_"+isMailUserCode) == null ? {} : JSON.parse(sessionStorage.getItem(isMailDomainCode+"_"+isMailUserCode));
			
			if(sessionStorage.getItem(isMailDomainCode+"_"+isMailUserCode) == null){
				var isLayouTypeStr = "MAILLIST";
				
				data.isLayoutType = isLayouTypeStr;	//목록 레이아웃	
				data.isSortType = "";	//목록 정렬
				data.isViewType = "";	//목록 시간,대화형
				data.isViewNum = "10";
				data.isCurrentPage = "1";
				data.initYn = "Y";
			}
			
			//메일작성 새창에서 사용
			data.ismailuserid = UserCode;
			data.ismailuserNm = UR_Name;
			//sessionStorage에 값 저장
			data.userMail = userMail;
			data.isSendMail = isSendMail;
			data.isMailDomainCode = isMailDomainCode;
			data.isMailUserCode = isMailUserCode;
			data.isMailDeptCode =  mailDeptCode;
			
			sessionStorage.setItem(isMailDomainCode+"_"+isMailUserCode, JSON.stringify(data));
			
			//페이지가 새로고침되어 userId를 담아둔 태그가 초기화되어 임시로 담아둔 후 태그에 담고 삭제한다.
			sessionStorage.setItem("tempMailUserCode", isMailDomainCode+"_"+isMailUserCode);
		}
	}
	//예고업무 조회 처리
	function setMyPreTask(){
		var today = new Date(CFN_GetLocalCurrentDate()); // 현재 날짜, 시간  - 타임존 적용
		var todayStr = today.format("yyyyMMdd");	
		$.getJSON("/groupware/biztask/getMyPreTaskList.do", {ownerCode: UserCode, currentDate: todayStr}, function(data){
			if(data.count > 0 ){
				$("#divPreTask").show();
				$(".OWDocbox .OWList_none").hide();
				$("#spanPreTaskCNT").text(data.count);
				preTaskList = data.list;
				gPreTaskTotalCnt = data.count;

				setPreTaskHTML();
			}else{
				$("#divPreTask").hide();
				$(".OWDocbox .OWList_none").show();
			}
		});
	}
	//예고업무 목록 그리기
	function setPreTaskHTML(){
		var preTaskHTML = "";
		var i=1;
		
		preTaskList.forEach(function(item) {
			if(i > (gPreTaskCurrentPage-1)*gPreTaskPageCnt && i <= gPreTaskCurrentPage*gPreTaskPageCnt ){
				preTaskHTML += '<div class="OWDoc" id="divPreTask'+item.PreTaskID+'">';
				preTaskHTML += '<a class="OWDoc_xbtn" href="#" onclick="javascript:deleteMyPreTask(\''+item.PreTaskID+'\')">'+'<spring:message code='Cache.btn_Close'/>'+'</a>';
				preTaskHTML += '<p class="OWDoc_year">'+item.Term + ' '+ convertPreTaskTermMode(item.TermMode,item.BeforeAfter)+'</p>';
				preTaskHTML += '<p class="OWDoc_date">'+item.TaskDate.substring(0,10).replace(/'-'/g,'')+'</p>';
				preTaskHTML += '<p class="OWDoc_title">'+item.Subject+'</p>';
				preTaskHTML += '</div>';
			}
			i++;
		});
		if(gPreTaskTotalCnt > gPreTaskCurrentPage*gPreTaskPageCnt){
			$("#ahrefRight").show();
		}else{
			$("#ahrefRight").hide();
		}
		if(gPreTaskCurrentPage > 1){
			$("#ahrefLeft").show();
		}else{
			$("#ahrefLeft").hide();
		}
		$("#divPreTask").html(preTaskHTML);
	}
	//예고업무 삭제처리
	function deleteMyPreTask(pPreTaskID){
		$.ajax({
			type:"POST",
			data:{
				"preTaskID" : pPreTaskID
			},
			url:"/groupware/biztask/deleteMyPreTask.do",
			success:function (data) {
				if(data.status == "SUCCESS") {
					$("#divPreTask"+pPreTaskID).hide();
				} else {
					Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>", '', function (result) {  }); //오류가 발생하였습니다.
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/biztask/deleteMyPreTask.do", response, status, error);
			}
		});
	}
	//예고업무 기간 변환
	function convertPreTaskTermMode(pTerm, pBeforeAfter){
		var rtnString;

		switch(pBeforeAfter){
			case "B": 
				switch(pTerm){
					case "Y": rtnString = "<spring:message code='Cache.lbl_before_year'/>"; break; // 년전
					case "M": rtnString = "<spring:message code='Cache.lbl_before_month'/>"; break; // 개월전
					case "W": rtnString = "<spring:message code='Cache.lbl_before_week'/>"; break; // 주전
					case "D": rtnString = "<spring:message code='Cache.lbl_before_day'/>"; break; // 일전
				}
				break;
			case "A": 
				switch(pTerm){
				case "Y": rtnString = "<spring:message code='Cache.lbl_after_year'/>"; break; // 년후
				case "M": rtnString = "<spring:message code='Cache.lbl_after_month'/>"; break; // 개월후
				case "W": rtnString = "<spring:message code='Cache.lbl_after_week'/>"; break; // 주후
				case "D": rtnString = "<spring:message code='Cache.lbl_arter_day'/>"; break; // 일후
				}
				break;
		}		
		return rtnString;
	}
	//예고업무 생성 확인용
	function setPreTaskSchedule(){
		var today = new Date(CFN_GetLocalCurrentDate()); // 현재 날짜, 시간  - 타임존 적용
		var todayStr = today.format("yyyyMMdd");
		$.ajax({
			type:"POST",
			data:{
				ownerCode: UserCode, currentDate: todayStr
			},
			url:"/groupware/biztask/setPreTaskSchedule.do",
			success:function (data) {
				alert(data.status +"\r\n"+data.message);
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("biztask/setPreTaskSchedule.do", response, status, error);
			}
		});
	}
	//기존 예고업무 삭제 확인용
	function deletePreTaskSchedule(){
		var today = new Date(CFN_GetLocalCurrentDate()); // 현재 날짜, 시간  - 타임존 적용
		var todayStr = today.format("yyyyMMdd");	
		$.ajax({
			type:"POST",
			data:{
				ownerCode: UserCode, currentDate: todayStr
			},
			url:"/groupware/biztask/deletePreTaskSchedule.do",
			success:function (data) {
				alert(data.status +"\r\n"+data.message);
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("biztask/deletePreTaskSchedule.do", response, status, error);
			}
		});		
	}
	//예고업무 목록 페이징처리
	function setPageMoveTaskPre(pMode){
		switch(pMode){
			case "p":
				gPreTaskCurrentPage--;
				break;
			case "n":
				gPreTaskCurrentPage++;
				break;
		}
		setPreTaskHTML();
	}
</script>