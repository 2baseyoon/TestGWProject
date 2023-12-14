<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil,egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
	String googleApiKey = RedisDataUtil.getBaseConfig("GoogleApiKey");
	String googleMapLevel = RedisDataUtil.getBaseConfig("GoogleMapLevel")!=null?RedisDataUtil.getBaseConfig("GoogleMapLevel"):"15";
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>

	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	<script type="text/javascript" src="https://maps.google.com/maps/api/js?key=<%=googleApiKey %>" ></script>
</head>
<body>
<form name="form" id="form" style="margin:0px;">
	<input type="hidden" id="ReqSeq" name="JobDate" value="${data.ReqSeq}">
	
	<div class="layer_divpop" style="width:100%; left:0; top:0; z-index:104;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<!-- 승인 의견 레이어 팝업 시작-->
		<div class="layer_divpop" style="width:440px;top:100px;left:170px;z-index:1000;display:none"  id="divWork">
			<div class="divpop_contents">
				<div class="pop_header"><h4 class="divpop_header"><span class="divpop_header_ico"><spring:message code="Cache.lbl_apv_comment_write"/></span></h4><a onclick='$("#divWork").hide()'  class="divpop_close" style="cursor:pointer;"></a></div>
				<div class="divpop_body" style="overflow:hidden; padding:0;">
					<div class="ATMgt_popup_wrap">
						<div class="ATMgt_opinion_wrap">
							<table class="ATMgt_popup_table" cellpadding="0" cellspacing="0">
								<tbody>
									<tr>	
										<td class="ATMgt_T_th"><spring:message code="Cache.lbl_comment"/></td>
										<td><textarea id="ApprovalComment" name="ApprovalComment" class="ATMgt_Tarea"  cols="30" rows="40"></textarea>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="bottom">
							<a href="#" class="btnTypeDefault  btnTypeBg btnAttAdd" id="btnSaveApproval"><spring:message code="Cache.lbl_apv_Approved"/></a>
							<a href="#" class="btnTypeDefault" id="btnSaveReject"><spring:message code="Cache.lbl_Reject"/></a>
							<a href="#" class="btnTypeDefault" onclick='$("#divWork").hide()'><spring:message code="Cache.btn_Close"/></a>
						</div>
					</div>
				</div>
			</div>
		</div>	
		<!-- 템플릿 선택 레이어 팝업 끝 -->
		<div class="ATMgt_popup_wrap">
			<p class="ATMgt_popup_title">${data.ReqName} ${data.ReqGubunName}
				<span class='tx_status <c:if test="${data.ReqStatus eq 'ApprovalRequest'}">stay</c:if> '>${data.StatusName}</span><!-- class (대기 : stay, 완료 : comp) --></p>
			<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
				<tbody>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.mag_Attendance40' /></td> <!-- 요청보낸 사람 -->
						<td><p class="tx_name">${data.URName }</p></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_ApplicationDate' /></td> <!-- 신청일자 -->
						<c:set var="ReqDate" value="${data.ReqDate }"/>
						<td><p class="tx_name"><%=ComUtils.TransLocalTime(String.valueOf(pageContext.getAttribute("ReqDate")))%> </p></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_worktype' />/<spring:message code='Cache.lbl_dept' /></td> <!-- 직무/부서 -->
						<td><p class="tx_dept">${data.DeptName }</p></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_RequestSummary' /></td> <!-- 요청사유 -->
						<td><p class="tx_cont w100">${data.Comment }</p></td>
					</tr>
					<c:if test="${data.ReqGubun  ne 'C' }">	<!-- 수정/삭제인경우 -->
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_BeforeChange' /></td> <!-- 변경 전 -->
							<td>
								<div class="dateSelfix_scroll">
								<c:forEach items="${reqList}" var="list" varStatus="status" >
									<p class="dateSelfix">
										<c:choose>
											<c:when test="${data.ReqType  eq 'V' }">
												${list.WorkDate} 
											</c:when>
											<c:when test="${data.ReqType  eq 'S' }">
												${list.WorkDate}
											</c:when>
											<c:otherwise>
												${list.WorkDate} 
												${fn:substring(list.BfStartTime,0,2)}:${fn:substring(list.BfStartTime,2,4)}
												~ ${fn:substring(list.BfEndTime,0,2)}:${fn:substring(list.BfEndTime,2,4)}											
											</c:otherwise>
										</c:choose>		
									</p>
								</c:forEach>
								</div>
								</td>
							</td>
						</tr>
					</c:if>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_RequestDate' /></td> <!-- 요청일자-->
						<td>
							<div class="dateCalBox">
								<div class="dateCalBox_l">
									<!-- 달력영역 시작 -->
									<div id="inputBasic_AX_EndDate_AX_expandBox" class="AXbindTwinDateExpandBox dateCal" style="">
										<div>
										<div class="dateControlBox">
											<c:choose>
												<c:when test="${data.ReqType  eq 'S' }">
													<c:if test="${reqList[0].Mode  eq 'T' }">
														<a href="javascript:;" class="yearbutton" id="inputBasic_AX_EndDate_AX_controlYear1"> ${fn:substring(reqList[0].WorkDate,0,4)}<spring:message code='Cache.lbl_year' /></a> <!-- 년 -->
														<a href="javascript:;" class="monthbutton" id="inputBasic_AX_EndDate_AX_controlMonth1">${fn:substring(reqList[0].WorkDate,5,7)}<spring:message code='Cache.lbl_month' /></a> <!-- 월 -->
													</c:if>
													<c:if test="${reqList[0].Mode  eq 'R' }">
														<a href="javascript:;" class="yearbutton" id="inputBasic_AX_EndDate_AX_controlYear1"> ${fn:substring(reqList[0].StartDate,0,4)}<spring:message code='Cache.lbl_year' /></a> <!-- 년 -->
														<a href="javascript:;" class="monthbutton" id="inputBasic_AX_EndDate_AX_controlMonth1">${fn:substring(reqList[0].StartDate,5,7)}<spring:message code='Cache.lbl_month' /></a> <!-- 월 -->
													</c:if>
												</c:when>
												<c:otherwise>
													<a href="javascript:;" class="yearbutton" id="inputBasic_AX_EndDate_AX_controlYear1"> ${fn:substring(reqList[0].WorkDate,0,4)}<spring:message code='Cache.lbl_year' /></a> <!-- 년 -->
													<a href="javascript:;" class="monthbutton" id="inputBasic_AX_EndDate_AX_controlMonth1">${fn:substring(reqList[0].WorkDate,5,7)}<spring:message code='Cache.lbl_month' /></a> <!-- 월 -->
												</c:otherwise>
											</c:choose>
										</div>
										</div>
										<div id="calendarBody" class="dateDisplayBox"></div>
									</div>
									<!-- 달력영역 끝 -->
								</div>
								<div class="dateCalBox_r">
									<c:forEach items="${reqList}" var="list" varStatus="status" >
										<div class="datelBox">
										<ul>
											<c:choose>
												<c:when test="${data.ReqType  eq 'V' }">	
													<li>
														<span><spring:message code='Cache.lbl_Vacation' /> : </span> <!-- 휴가 -->
														<span>${data.VacFlagName} <c:if test="${data.VacOffFlag  ne '0' }">${data.VacOffFlag}</c:if>
															<c:if test="${data.startTime ne null and data.endTime ne null}">${data.startTime}~${data.endTime}</c:if> </span>
													</li>	
													<li class="color">
														<span><spring:message code='Cache.lbl_RequestDate' /> : </span> <!-- 요청일자 -->
														<span>${list.WorkDate}</span>
													</li>	 
												</c:when>
												<c:when test="${data.ReqType  eq 'S' }">
													<li>
														<span><spring:message code='Cache.mag_Attendance30' /> : </span> <!-- 근무템플릿 -->
														<c:if test="${empty list.SchName}">
															<span><spring:message code='Cache.lbl_Mail_DirectInput' /> </span> <!-- 직접 입력 -->
														</c:if>
														<c:if test="${not empty list.SchName}">
															<span>${list.SchName} </span>
														</c:if>
													</li>
													<li class="color">
														<span><spring:message code='Cache.lbl_RequestDate' /> : </span> <!-- 요청일자 -->
														<c:if test="${list.Mode  eq 'T' }">
															<span>${list.WorkDate}</span>
														</c:if>
														<c:if test="${list.Mode  eq 'R' }">
															<span>${list.StartDate} ~ ${list.EndDate}</span>
														</c:if>
													</li>
													<li class="color">
														<span><spring:message code='Cache.lbl_reqTime' /> : </span> <!-- 요청시간 -->
														<span>
															${fn:substring(list.StartTime,0,2)}:${fn:substring(list.StartTime,2,4)}
															~ ${fn:substring(list.EndTime,0,2)}:${fn:substring(list.EndTime,2,4)}
														</span>
													</li>
												</c:when>
												<c:when test="${data.ReqType  eq 'A' or data.ReqType  eq 'L' }">
													<li class="color">
														<span>[<fmt:formatNumber value="${data.WorkDis}" pattern="#,###"/>m]<spring:message code='Cache.lbl_WorkingArea' /> : </span> <!-- 근무지 -->
														<span>${data.WorkZone}(${data.WorkAddr})</span>	
													</li>
													<c:forEach items="${workPlace}" var="work" varStatus="status" >
														<li class="color">
															<span>[<fmt:formatNumber value="${work.WorkDis}" pattern="#,###"/>m]
																<c:if test="${data.ReqType  eq 'A' }">
																<spring:message code='Cache.lbl_AttendanceArea'/>
																</c:if>
																<c:if test="${data.ReqType  eq 'L' }">
																<spring:message code='Cache.lbl_LeaveWorkArea'/>
																</c:if>
																: 
															</span> <!--  -->
															<span>${work.WorkZone}(${work.WorkAddr})</span>	
														</li>
													</c:forEach>
													<li class="color">
														<span><spring:message code='Cache.lbl_reqTime' /> : </span> <!-- 요청시간 -->
														<span>${list.CommuteTime}</span>
													</li>
												</c:when>
												<c:when test="${data.ReqType  eq 'C'}">
													<li>
														<span><spring:message code='Cache.lbl_Gubun' /> : </span> <!-- 구분 -->
														<span>
														<c:if test="${list.Division  eq 'StartSts' }"><spring:message code='Cache.lbl_att_goWork' /></c:if> <!-- 출근 -->
														 <c:if test="${list.Division  ne 'StartSts' }"><spring:message code='Cache.lbl_leave' /></c:if> <!-- 퇴근 -->
														 </span>
													</li>	 
													<li>
														<span><spring:message code='Cache.lbl_BeforeChange' /> : </span> <!-- 변경전 -->
														<span>${list.OrgTime}</span>
													</li>	
													<li class="color">
														<span><spring:message code='Cache.lbl_reqTime' /> : </span> <!-- 요청시간 -->
														<span>${list.WorkDate} ${fn:substring(list.ChgTime,0,2)}:${fn:substring(list.ChgTime,2,4)}</span>
													</li>												
												</c:when>
												<c:otherwise>
													<li>
														<span><spring:message code='Cache.lbl_reqTime' /> : </span> <!-- 요청시간 -->
														<span>
															${list.WorkDate} 
															${fn:substring(list.StartTime,0,2)}:${fn:substring(list.StartTime,2,4)}
															~ ${fn:substring(list.EndTime,0,2)}:${fn:substring(list.EndTime,2,4)}
														</span>
													</li>
													<c:if test="${not empty list.RealWorkInfo}">
														<c:if test="${not empty list.RealWorkInfo.StartTime and not empty list.RealWorkInfo.EndTime}">
														<li class="color">
															<span><spring:message code='Cache.lbl_att_workTime' /> : </span> <!-- 근무시간 -->
															<span>
																${list.RealWorkInfo.TargetDate}
																${list.RealWorkInfo.StartTime}
																~ ${list.RealWorkInfo.EndTime}
															</span>
														</li>
														</c:if>
														<c:if test="${not empty list.RealWorkInfo.RealACTime}">
														<li class="color">
															<span><spring:message code='Cache.lbl_att_ac_time' />(<spring:message code='Cache.lbl_Minutes' />) : </span> <!-- 인정시간(분) -->
															<span>
																${list.RealWorkInfo.RealACTime}
															</span>
														</li>
														</c:if>
													</c:if>
												</c:otherwise>
											</c:choose>
										</ul>
										</div>
									</c:forEach>
									</div>
									<div id="map_ma" class="ATMgt_Map_img" style="display:none;height:200px"></div>		
								</div>
							</div>
						</td>
					</tr>
				</tbody>
			</table>	
			
			<c:if test="${data.ReqStatus ne 'ApprovalRequest'}">
			<div class="ATMgt_approval_wrap">
				<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
					<tbody>
						<c:if test="${data.ReqMethod eq 'None'}">
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.CommunityJoin_D' /></td> <!-- 자동승인 -->
							</tr>
						</c:if>
						<c:if test="${data.ReqMethod ne 'None'}">
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Approver' /></td> <!-- 승인자 -->
								<td><p class="tx_name">${data.ApprovalName }</p></td>
							</tr>
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.lbl_ApprovalDate' /></td> <!-- 승인일자 -->
								<c:set var="ApprovalDate" value="${data.ApprovalDate }"/>
								<td><p class="tx_name"><%=ComUtils.TransLocalTime(String.valueOf(pageContext.getAttribute("ApprovalDate")))%> </p></td>
							</tr>
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.lbl_ApprovalDetail' /></td> <!-- 승인내용 -->
								<td><p class="tx_cont w100">${data.ApprovalComment }</p></td>
							</tr>
						</c:if>
					</tbody>
				</table>
			</div>
			</c:if>
			<div class="bottom mtop20">
				<a href="#" class="btnTypeDefault btnTypeChk" id="btnApproval" style="display:none;"><spring:message code='Cache.lbl_Approval' /></a> <!-- 승인 -->
				<a href="#" class="btnTypeDefault btnTypeChk" id="btnReject" style="display:none;"><spring:message code='Cache.btn_Reject' /></a> <!-- 거부 -->
				<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.btn_Close' /></a> <!-- 닫기 -->
			</div>
		</div>
		
	</div>
</form>	
</body>
<script>
var mycalendar = new AXCalendar();

$(document).ready(function(){
	// 기본 javascript bind함수가 변경되서 다시 원복 - /mail/resources/script/cmmn/cmmn.func.js
	if (Function.prototype._original_bind && Function.prototype.bind) {
		Function.prototype.bind = Function.prototype._original_bind;
	}
	
    mycalendar.setConfig({
		targetID:"calendarBody",
		//{ name: "일" }, { name: "월" }, { name: "화" }, { name: "수" }, { name: "목" }, { name: "금" }, { name: "토" }
		weeks :[{ name: "<spring:message code='Cache.lbl_sch_sun' />" }, { name: "<spring:message code='Cache.lbl_sch_mon' />" }, { name: "<spring:message code='Cache.lbl_sch_tue' />" }, { name: "<spring:message code='Cache.lbl_sch_wed' />" }, { name: "<spring:message code='Cache.lbl_sch_thu' />" }, { name: "<spring:message code='Cache.lbl_sch_fri' />" }, { name: "<spring:message code='Cache.lbl_sch_sat' />" } ], 
		<c:choose>
			<c:when test="${data.ReqType  eq 'S' }">
				<c:if test="${reqList[0].Mode  eq 'T' }">
					basicDate:new Date("${reqList[0].WorkDate}")
				</c:if>
				<c:if test="${reqList[0].Mode  eq 'R' }">
					basicDate:new Date("${reqList[0].StartDate}")
				</c:if>
			</c:when>
			<c:otherwise>
				basicDate:new Date("${reqList[0].WorkDate}")
			</c:otherwise>
		</c:choose>
	});
    mycalendar.printDayPage("${reqList[0].WorkDate}");
	
    <c:forEach items="${reqList}" var="list" varStatus="status" >
		<c:choose>
			<c:when test="${data.ReqType  eq 'S' }">
				<c:if test="${list.Mode  eq 'T' }">
					$("#calendarBody_AX_${list.WorkDate}_AX_date").addClass("selected");
				</c:if>
				<c:if test="${list.Mode  eq 'R' }">
					$("#calendarBody_AX_${list.StartDate}_AX_date").addClass("selected");
					$("#calendarBody_AX_${list.EndDate}_AX_date").addClass("selected");
				</c:if>
			</c:when>
			<c:otherwise>
				$("#calendarBody_AX_${list.WorkDate}_AX_date").addClass("selected");
			</c:otherwise>
		</c:choose>
	</c:forEach>
	<c:if test="${data.ReqType == 'A' or data.ReqType == 'L'}">	
		$("#map_ma").show();
		var marker ;
		var zoomLevel		= Number("<%=googleMapLevel%>");				// 지도의 확대 레벨 : 숫자가 클수록 확대정도가 큼
		
		const map = new google.maps.Map(document.getElementById('map_ma'), {
			center:{lat: ${data.CommutePointY}, lng: ${data.CommutePointX}},
			zoom: Number("<%=googleMapLevel%>")
		});
		
		const works = [];
		var i=0;
		works[i++]= ({label: 'P', name:'work', lat: ${data.CommutePointY}, lng: ${data.CommutePointX}});
		works[i++]= ({label: 'W0', name:'${data.WorkZone}', lat: ${data.WorkPointY}, lng: ${data.WorkPointX}});
		<c:forEach items="${workPlace}" var="work" varStatus="status" >
		works[i++]= ({label: 'W'+(i-2), name:'${work.WorkZone}', lat: ${work.WorkPointY}, lng: ${work.WorkPointX}});
		</c:forEach>

		works.forEach(({label, name, lat, lng}) => {
		const marker = new google.maps.Marker({
				position: {lat, lng},
				label,
				map: map,
			});	
		});
	</c:if>
	
    $('#btnClose').click(function(){
		Common.Close();
	});
    
	// 승인/거부 버튼 표시 
    if(parent.$("#btnApproval").length > 0) {
    	<c:if test="${data.ReqStatus eq 'ApprovalRequest'}">
	    	$("#btnApproval").show();
	    	$("#btnReject").show();
    	</c:if>  	
    }
	
    //승인
	$("#btnApproval").click(function(){
		$("#ApprovalComment").val("");
		$("#divWork").show();
		$("#btnSaveApproval").show();
		$("#btnSaveReject").hide();
	});
    
	//거부
	$("#btnReject").click(function(){
		$("#ApprovalComment").val("");
		$("#divWork").show();
		$("#btnSaveApproval").hide();
		$("#btnSaveReject").show();
	});
	
	$("#btnSaveApproval").click(function(){
		Common.Confirm("<spring:message code='Cache.msg_RUApprove' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				var aJsonArray = new Array();
				if(CFN_GetQueryString("ReqSeq") != "undefined") {
					aJsonArray.push(CFN_GetQueryString("ReqSeq"))	
				}				
				
				$.ajax({
					type:"POST",
					contentType:'application/json; charset=utf-8',
					dataType   : 'json',
					data:JSON.stringify({"dataList" : aJsonArray  , "ApprovalComment":$("#ApprovalComment").val()}),
					url:"/groupware/attendRequestMng/approvalAttendRequest.do",
					success:function (data) {
						if(data.status=='SUCCESS'){
							Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_com_processSuccess'/>");	//저장되었습니다.
							Common.Close();
							parent.searchData(-1);
						}else{
		            		if (data.dupFlag == true){
			            		Common.Warning("<spring:message code='Cache.msg_att_overlapping'/>");
			            	}else if (data.errorCode != undefined ){
			            		var subMsg="";
			            		if (data.errorCode == "lbl_n_att_overTimeHour"){
				            		if (data.errorData != "-1"){
				            			subMsg = "["+AttendUtils.convertSecToStr(data.errorData)+"]";
				            		}
			            		}	
			            		Common.Warning(Common.getDic(data.errorCode)+subMsg);
			            	}	
			            	else{
			            		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
			            	}
							$("#divWork").hide();
			            }	
					},
					error:function (request,status,error){
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
					}
				});
			}	
		});				
	});
	
	//거부
	$("#btnSaveReject").click(function(){
		Common.Confirm("<spring:message code='Cache.msg_RUReject' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				var aJsonArray = new Array();
				if(CFN_GetQueryString("ReqSeq") != "undefined") {
					aJsonArray.push(CFN_GetQueryString("ReqSeq"))	
				}
				
				$.ajax({
					type:"POST",
					contentType:'application/json; charset=utf-8',
					dataType   : 'json',
					data:JSON.stringify({"dataList" : aJsonArray  , "ApprovalComment":$("#ApprovalComment").val()}),
					url:"/groupware/attendRequestMng/rejectAttendRequest.do",
					success:function (data) {
						if(data.result == "ok"){
							Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_com_processSuccess'/>");	//저장되었습니다.
							Common.Close();
							parent.searchData(-1);
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
		});				
	});	    

});
</script>