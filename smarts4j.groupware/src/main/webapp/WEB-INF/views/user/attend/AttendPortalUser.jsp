<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper
	,egovframework.coviframework.util.ComUtils
	,egovframework.coviframework.util.DicHelper
	,egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<script type="text/javascript" src="/covicore/resources/ExControls/Chart.js-master/Chart.js<%=resourceVersion%>"></script>

<div class="cRContAll mScrollVH">
	<div class="StateCont">
		<div class="StateArea">
			<div class="StateTop StateTop2">
				<div class="StateTopLeft">
					<h2 class="title"><span><%=SessionHelper.getSession("UR_Name") %></span> <spring:message code='Cache.lbl_Sir' /> <spring:message code='Cache.lbl_att_attendance_sts' /></h2> <!-- 님 근태현황 -->
					<c:if test="${userSchedule.SchName != ''}">
						<span class="timeType">${userSchedule.SchName}</span>
						<span class="time">${userSchedule.AttDayStartTime} ~ ${userSchedule.AttDayEndTime}</span>
					</c:if>
				</div>
			</div>
			<div class="StateBottom StateBottom2">
				<div class="StateTimeArea">
					<strong class="date">${TargetDate}(${TargetWeek}) <spring:message code='Cache.lbl_att_goWork' /> <spring:message code='Cache.lbl_CurrentSituation' /></strong> <!-- 출근 현황 -->
					<div class="StateTimeBox">
						<ul>
							<li>
								<a href="#">
									<strong class="tit tit1"><spring:message code='Cache.lbl_att_goWork' /></strong> <!-- 출근 -->
									<span class="txt" id="attendStatus" data-type="${StartSts}"></span>
								</a>
							</li>
							<li>
								<a href="#">
									<strong class="tit tit2"><spring:message code='Cache.lbl_ThisWeek' /> <spring:message code='Cache.lbl_n_att_remain' /> <spring:message code='Cache.lbl_n_att_workingHours' /></strong> <!-- 금주 잔여 근로시간 -->
									<span class="txt">${RemainTime}</span>
								</a>
							</li>
							<li>
								<a href="#">
									<strong class="tit tit3"><spring:message code='Cache.lbl_PrescribedWorkingHours' /></strong> <!-- 소정근로시간 -->
									<span class="txt">${FixWorkTime}h</span>
								</a>
							</li>
						</ul>
					</div>
					<a class="more" data="MYATT" href="#">more +</a>
				</div>
				<div class="StateBoxArea">
					<div class="StateBox">
						<div class="StateBoxT">
							<h3 class="sTit"><spring:message code='Cache.lbl_att_attendance_sts' /></h3> <!-- 근태현황 -->
							<ul class="ATMschSelect inb">
								<li class="selected" data="W"><a href="#"><spring:message code='Cache.lbl_Weekly' /></a></li> <!-- 주간 -->
								<li data="M"><a href="#"><spring:message code='Cache.lbl_Monthly' /></a></li> <!-- 월간 -->
							</ul>
						</div>
						<div class="StateBoxB">
							<div class="StateTit">
								<div class="StateTitLeft">
									<strong class="date">${StartDate} ~ ${EndDate}</strong>
									<div class="pagingType03">
										<a href="#" class="pre" data-paging="-"></a>
										<a href="#" class="next" data-paging="+"></a>
										<a href="#" class="calendartoday btnTypeDefault"><spring:message code='Cache.lbl_Todays'/></a>
										<a href="#" class="calendarcontrol btnTypeDefault cal"></a>
										<input type="text" id="inputCalendarcontrol" style="height: 0px; width:0px; border: 0px;" >
									</div> 
								</div>
							</div>
							<div class="StateDg">
								<!-- 도표 영역 -->
								<div class="diagramBx">
									<div   style="width:180px;height:180px; margin:0 auto;"><canvas id="attendPie"></canvas></div>
								</div>	
								<div class="diagramTxt">
									<p class="TotalNum">총 <strong id="tot_time"></strong></p>
									<ul class="TotalList">
										<li><span class="txt"><spring:message code='Cache.lbl_n_att_normalWork'/></span> <strong class="num" id="work_time"></strong></li> <!-- 정상근무 -->
										<li><span class="txt"><spring:message code='Cache.lbl_att_overtime_work'/></span> <strong class="num" id="exten_time"></strong></li> <!-- 연장근무 -->
										<li><span class="txt"><spring:message code='Cache.lbl_att_holiday_work'/></span> <strong class="num" id="holi_time"></strong></li> <!-- 휴일근무 -->
										<li><span class="txt"><spring:message code='Cache.lbl_n_att_remainWork'/></span> <strong class="num" id="remain_time"></strong></li> <!-- 잔여근무 -->
									</ul>
								</div>
							<!-- //도표 영역 -->
							</div>
						</div>
						<a class="more" data="MYATT"  href="#">more +</a>
					</div>
					<div class="StateBox">
						<div class="StateBoxT">
							<h3 class="sTit"><spring:message code='Cache.mag_Attendance28'/></h3> <!-- 근태 누락 소명 신청 -->
						</div>
						<div class="StateBoxB">
							<div class="omList">
								<c:choose>
									<c:when test="${fn:length(userCallingList)== 0}">
										<div class="taskCont4" id="itemContainer"><p class="OWList_none"><spring:message code='Cache.msg_NoDataList'/></p></div> <!-- 조회할 목록이 없습니다. -->
									</c:when>
									<c:otherwise>
									<ul>
										<c:set var="i" value="0" />
										<c:forEach items="${userCallingList}" var="list" varStatus="status">
											<c:set var="WorkNm" value="lbl_n_att_absent" />
											<c:set var="WorkClass" value="omState1" />

											<c:if  test="${i < 6 && fn:length(list.EndSts)> 0 && list.EndSts!='lbl_att_normal_offWork'}">
													<c:set var="WorkNm" value="${list.EndSts}" />
													<c:set var="WorkClass" value="omState2" />
													<c:set var="i" value="${i+1}" />
													<li>
														<a class="omTime" href="#">${fn:replace( list.JobDate,'-','.')}</a>
														<span class="omState ${WorkClass}"><spring:message code="Cache.${WorkNm}"></spring:message></span>
														<a class="btnTypeDefault btnApply" href="#"  onclick="javascript:clickBtnApply('${list.JobDate}');"><spring:message code="Cache.lbl_app_approval_call"></spring:message></a>
													</li>
											</c:if>	
											<c:if  test="${i < 6 && fn:length(list.StartSts)> 0 && list.StartSts!='lbl_att_normal_goWork'}">
													<c:set var="WorkNm" value="${list.StartSts}" />
													<c:set var="WorkClass" value="omState2" />
													<c:set var="i" value="${i+1}" />
													<li>
														<a class="omTime" href="#">${fn:replace( list.JobDate,'-','.')}</a>
														<span class="omState ${WorkClass}"><spring:message code="Cache.${WorkNm}"></spring:message></span>
														<a class="btnTypeDefault btnApply" href="#"  onclick="javascript:clickBtnApply('${list.JobDate}');"><spring:message code="Cache.lbl_app_approval_call"></spring:message></a>
													</li>
											</c:if>
										</c:forEach>
									</ul>					
									</c:otherwise>
								</c:choose>
							</div>
						</div>
						<a class="more" data="MYATT"  href="#">more +</a>
					</div>
				</div>
				<div class="StateBoxArea">
					<div class="StateBox">
						<div class="StateBoxT">
							<h3 class="sTit"><spring:message code='Cache.mag_Attendance29' /></h3> <!-- 연장/휴일 근무 신청 -->
						</div>
						<div class="StateBoxB">
							<div class="holiList">
								<c:choose>
									<c:when test="${fn:length(userExtendList)== 0}">
										<div class="taskCont4" id="itemContainer"><p class="OWList_none"><spring:message code='Cache.msg_NoDataList'/></p></div> <!-- 조회할 목록이 없습니다. -->
									</c:when>
									<c:otherwise>
									<ul>
										<c:forEach items="${userExtendList}" var="list" varStatus="status">
											<li>
											<div class="holiTxt">
												<p class="holiTit"><a href="#">${list.URName} ${list.JobPositionName} / ${list.ReqDate}</a></p>
												<p class="holiCon"><a href="#">${list.Comment}</a></p>
											</div>
											<div class="holiBtn">
												<span class="stateSuc">${list.StatusName }</span>
											</div>
											</li>
										</c:forEach>
									</ul>	
									</c:otherwise>
								</c:choose>
							</div>
						</div>
						<a class="more" data="MYREQ"  href="#">more +</a>
					</div>
					<div class="StateBox">
						<div class="StateBoxT">
							<h3 class="sTit"><spring:message code='Cache.lbl_att_work' /> <spring:message code='Cache.lbl_att_approval' /></h3> <!-- 근무 신청 -->
						</div>
						<div class="StateBoxB StateBoxB2">
							<ul class="workList">
								<li>
									<a href="#" data="O" >
										<span class="Wimg"><img src="<%=cssPath%>/AttendanceManagement/resources/images/ic_work1.jpg"></span>
										<span class="Wtxt"><spring:message code='Cache.lbl_app_approval_extention' /></span> <!-- 연장근무 신청 -->
									</a>
								</li>
								<li>
									<a href="#" data="H"> 
										<span class="Wimg"><img src="<%=cssPath%>/AttendanceManagement/resources/images/ic_work2.jpg"></span>
										<span class="Wtxt"><spring:message code='Cache.lbl_app_approval_holiday' /></span> <!-- 휴일근무 신청 -->
									</a>
								</li>
								<li>
									<a href="#" data="V">
										<span class="Wimg"><img src="<%=cssPath%>/AttendanceManagement/resources/images/ic_work3.jpg"></span>
										<span class="Wtxt"><spring:message code='Cache.btn_apv_vacation_req' /></span> <!-- 휴가 신청 -->
									</a>
								</li>
								<li>
									<a href="#" data="J"> 
										<span class="Wimg"><img src="<%=cssPath%>/AttendanceManagement/resources/images/ic_work4.jpg"></span>
										<span class="Wtxt"><spring:message code='Cache.lbl_n_att_otherJobReq' /></span> <!-- 기타근무 신청 -->
									</a>
								</li>
							</ul>
						</div>
						<a class="more" data="MYATT"  href="#">more +</a>
					</div>
				</div>
			</div>
			<div class=StateBox style="width:100%">
				<h3 class="sTit"><spring:message code='Cache.lbl_apv_attend_rule' /></h3>
				${MngMst.AttendPolicy }
			</div>
		</div>
	</div>
</div>	
<script>
//날짜paging
var _targetDate = "${TargetDate}";
var _stDate     = "${StartDate}";
var _edDate     = "${EndDate}";;
var _pageType   = "W";
var chartColor = [ "rgb(209,239,240)","rgb(240,138,100)","rgb(90,206,126)","rgb(156,95,184)"];
var myChart;

$(document).ready(function(){
	
	if(($("#attendStatus").attr('data-type') == 'lbl_att_goWork' || $("#attendStatus").attr('data-type') == 'lbl_att_normal_goWork')) {
		$("#attendStatus").html(Common.getDic('lbl_attendance_normal'))
	}
	else {
		$("#attendStatus").html(Common.getDic($("#attendStatus").attr('data-type')))
	}
	
//	$(".StateTitLeft .date").text(_stDate +" ~ "+_edDate);
	getMyAttInfo();
	$(".ATMschSelect li").click(function(){
		$(".ATMschSelect li").each(function(idx, val){
			$(this).toggleClass("selected");
			if ($(this).hasClass("selected")){
				_pageType = $(this).attr("data");
			}	
		});
		getMyAttInfo();
		
	});

	$(".pre, .next").on('click',function(){
		if("+"==$(this).data("paging")){
			_targetDate = _edDate;
			_targetDate = schedule_SetDateFormat(schedule_AddDays(_targetDate, 1), '-');
		}else {
			_targetDate = _stDate;
			_targetDate = schedule_SetDateFormat(schedule_AddDays(_targetDate, -1), '-');
		}

		getMyAttInfo();
	});
	
	setTodaySearch();
	
	//more 클릭
	$(".more").click(function(){
		switch ($(this).attr("data")){
			case "ATT":	//매니저근태
				CoviMenu_GetContent('/groupware/layout/attend_AttendUserStatus.do?CLSYS=attend&CLMD=user&CLBIZ=Attend');
				break;
			case "SEND":	//누락
				break;
			case "MYATT":	//사용자근태
			case "CALL":	//소명신청
				CoviMenu_GetContent('/groupware/layout/attend_AttendMyStatusV2.do?CLSYS=attend&CLMD=user&CLBIZ=Attend');
				break;
			case "MYREQ":	//나의 요청
				CoviMenu_GetContent('/groupware/layout/attend_AttendMyRequestMng.do?CLSYS=attend&CLMD=user&CLBIZ=Attend');
				break;
			
		}
	});

	
	//각종클릭
	$(".workList a").click(function(){
		switch ($(this).attr("data")){
			case "O":	//연장
				AttendUtils.openOverTimePopup();
				break;
			case "H":	//휴일
				AttendUtils.openHolidayPopup();
				break;
			case "V":	//휴가
				AttendUtils.openVacationPopup("USER");
				break;
			case "J":	//기타
				CoviMenu_GetContent('/groupware/layout/attend_AttendMyStatus.do?CLSYS=attend&CLMD=user&CLBIZ=Attend');
				break;
			
		}
	});

});
//소명신청 클릭
function clickBtnApply(jobDate){
	var selDateform = schedule_SetDateFormat(jobDate,'-');
	AttendUtils.openCallPopup('','','portal_callback',selDateform);
}
function portal_callback(){
	location.reload();
}
function searchList(dateText){
	_targetDate = dateText;
	getMyAttInfo();
}
function refreshList(){
	_targetDate = "${TargetDate}";
	getMyAttInfo();
}
function getMyAttInfo(){

	var params = {
		dateTerm : _pageType
		,targetDate : _targetDate
	}
	
	$.ajax({
		type : "POST",
		data : params,
		url : "/groupware/attendPortal/getMyAttStatus.do",
		success:function (data) {
			if(data.status=="SUCCESS"){
				$(".StateTitLeft .date").text(data.StartDate +" ~ "+data.EndDate);
				_stDate = data.StartDate;
				_edDate = data.EndDate;
				var dataMap = data.userAttWorkTime; 

				$("#tot_time").text(AttendUtils.convertSecToStr(dataMap["TotWorkTime"],"H"));
				$("#work_time").text(AttendUtils.convertSecToStr(dataMap["AttRealTime"],"H"));
				$("#exten_time").text(AttendUtils.convertSecToStr(dataMap["ExtenAc"],"H"));
				$("#holi_time").text(AttendUtils.convertSecToStr(dataMap["HoliAc"],"H"));
				$("#remain_time").text(AttendUtils.convertSecToStr(dataMap["RemainTime"],"H"));

				var chartData = {datasets : [{data : [],borderWidth:0,backgroundColor : chartColor}]};
				var attendObj =  {data : chartData, type:"doughnut",options:{legend: { display: false } }};
				attendObj.data.labels=["<spring:message code='Cache.lbl_n_att_normalWork' />","<spring:message code='Cache.lbl_att_overtime_work' />","<spring:message code='Cache.lbl_att_holiday_work' />","<spring:message code='Cache.lbl_n_att_remainWork' />"]; //"정상근무","연장근무","휴일근무","잔여근무"
				attendObj.data.datasets[0].data=[dataMap["AttRealTime"]/60,dataMap["ExtenAc"]/60,dataMap["HoliAc"]/60,dataMap["RemainTime"]/60];
				if( myChart ){
					myChart.destroy();
				}	

				myChart= new Chart(  $("#attendPie"), attendObj ); 
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
			}
		},
		error:function (request,status,error){
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
		}
	});
}

</script>