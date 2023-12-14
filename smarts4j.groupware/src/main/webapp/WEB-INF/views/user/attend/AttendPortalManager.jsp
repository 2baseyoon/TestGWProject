<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.RedisDataUtil,egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<style>
.StateBox .commuteList .coPhoto img{
    width: 40px;
}
.StateBox .commuteList .coTxt {
    width: calc(100% - 250px);
}
</style>
<script type="text/javascript" src="/covicore/resources/ExControls/Chart.js-master/Chart.js<%=resourceVersion%>"></script>
<div class="cRContAll mScrollVH">
	<!-- 컨텐츠 시작 -->
	<div class="StateCont">
		<div class="StateArea">
			<div class="StateTop StateTop3">
				<div class="StateTopLeft">
					<h2 class="title"><spring:message code='Cache.lbl_att_attendance_sts' /></h2> <!-- 근태현황 -->
					<input id="deptUpCode" type="hidden" onchange="changeDept()">
					<span id=deptCodeList></span>
				</div>
				<div class="StateTopRight">
					<a href="#" class="btn_slide_close"><spring:message code='Cache.btn_Close' /></a> <!-- 닫기 -->
				</div>
			</div>
			<div class="StateBottom StateBottom1">
				<strong class="date">${TargetDate}(${TargetWeek}) <spring:message code='Cache.lbl_att_goWork' /> <spring:message code='Cache.lbl_CurrentSituation' /></strong> <!-- 출근 현황 -->
				<a href="#" data="DETAIL" class="more">more +</a>
				<ul class="StateList">
					<li class="bg1">
						<p class="">
							<a href=# class="Status" data="COMMCNT"><strong id="work_cnt" class="num">0</strong>
							<span class="txt"><spring:message code='Cache.lbl_att_goWork' /></span></a> <!-- 출근 -->
						</p>
					</li>
					<li class="bg2">
						<p class="">
							<a href=#  class="Status" data="LATE"><strong id="late_cnt" class="num">0</strong>
							<span class="txt"><spring:message code='Cache.lbl_att_beingLate' /></span></a> <!-- 지각 -->
						</p>
					</li>
					<li class="bg3">
						<p class="">
							<a href=#  class="Status" data="ABSENT"><strong id="absent_cnt" class="num">0</strong>
							<span class="txt"><spring:message code='Cache.lbl_n_att_absent' /></span></span></a> <!-- 결근 -->
						</p>
					</li>
					<li class="bg4">
						<p class="">
							<a href=#  class="Status" data="VAC"><strong id="vac_cnt" class="num">0</strong>
							<span class="txt"><spring:message code='Cache.lbl_Vacation' /></span></span></a> <!-- 휴가 -->
						</p>
					</li>
				</ul>
				<div class="StateBoxArea">
					<div class="StateBox">
						<div class="StateBoxT">
							<h3 class="sTit"><spring:message code='Cache.lbl_att_attendance_sts' /></h3> <!-- 근태현황 -->
							<ul class="ATMschSelect inb tabCompany">
								<li class="selected" data-type="W"><a href="#"><spring:message code='Cache.lbl_Weekly' /></a></li> <!-- 주간 -->
								<li data-type="M"><a href="#"><spring:message code='Cache.lbl_Monthly' /></a></li> <!-- 월간 -->
							</ul>
						</div>
						<div class="StateBoxB">
							<div class="StateTit">
								<div class="StateTitLeft"  id="companyTit">
									<strong class="date">${StartDate} ~ ${EndDate}</strong>
									<div class="pagingType03" section-type="C">
										<a href="#" class="pre" data-paging="-"></a><a href="#" class="next" data-paging="+"></a>
										<a href="#" class="calendartoday btnTypeDefault"><spring:message code='Cache.lbl_Todays'/></a>
										<a href="#" class="calendarcontrol btnTypeDefault cal"></a>
										<input type="text" class="calendarinput" style="height: 0px; width:0px; border: 0px;" >
									</div>
								</div>
							</div>
							<div class="StateDg">
								<!-- 도표 영역 -->
								<div class="diagramBx">
									<div style="width:180px;height:180px; margin:0 auto;"><canvas id="companyPie"></canvas></div>
								</div>	
								<div class="diagramTxt" id="companyState">
									<p class="TotalNum"><spring:message code='Cache.lbl_total' /> <strong id=tot_cnt>0</strong><spring:message code="Cache.lbl_personCnt"/></p> <!-- 총 -->
									<ul class="TotalList">
										<li><a href=# class="Status" data="EXTEN"><span class="txt"><spring:message code='Cache.lbl_att_overtime_work' /></span><strong class="num" id="exten_cnt">0</strong></a></li> <!-- 연장근무 -->
										<li><a href=# class="Status" data="HOLI"><span class="txt"><spring:message code='Cache.lbl_att_holiday_work' /></span> <strong class="num" id="holi_cnt">0</strong></a></li> <!-- 휴일근무 -->
										<li><a href=# class="Status" data="VAC_COM"><span class="txt"><spring:message code='Cache.lbl_Vacation' /></span> <strong class="num" id="vac_cnt">0</strong></a></li> <!-- 휴가 -->
										<li><a href=# class="Status" data="COMM"><span class="txt"><spring:message code='Cache.lbl_attendance_normal' /></span> <strong class="num" id="normal_cnt">0</strong></a></li> <!-- 정상 -->
									</ul>
								</div>
								<!-- //도표 영역 -->
							</div>
						</div>
						<a href="#" data="ATT" class="more">more +</a>
					</div>
					<div class="StateBox">
						<div class="StateBoxT">
							<h3 class="sTit"><spring:message code='Cache.lbl_commuteMiss'/><span id=commuteCnt></span></h3>
						</div>
						<div class="StateBoxB pd0">
							<div class="commuteTop">
								<%if (RedisDataUtil.getBaseConfig("isUseMail").equals("Y")){%>
								<div class="chkStyle08">
									<input type="checkbox" id="checkAll" name="checkAll">
									<label for="checkAll"><span class="s_check"></span></label>
								</div>
								<a href="#" class="btnBlueType02 btnSend" id="btnSelSend"><spring:message code='Cache.lbl_Send' /></a>
								<%} %>
							</div>
							<div class="commuteList">
								<ul></ul>
							</div>
						</div>
						<a href="#" data="SEND"  class="more">more +</a>
					</div>
				</div>
			</div>
		</div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>
<script>
//날짜paging
var _targetDate = "${TargetDate}";
var _companyMap = {targetDate:"${TargetDate}",startDate:"${StartDate}", endDate: "${EndDate}", pageType: "W"};
var _userMap    = {targetDate:"${TargetDate}",startDate:"${StartDate}", endDate: "${EndDate}", pageType: "W"};
var _deptMap    = {targetDate:"${TargetDate}",startDate:"${TargetDate}", endDate: "${TargetDate}", pageType: "D"};
var _pageNo     = 1;
var _pageSize   = 10;
var _endPage    = 1;
var _callStartDate = "";
var _callEndDate = "";
var _printDN = true;
var deptChart;
var myChart;
var lateSendYn = "${MngMst.LateSendYn}";
var absentSendYn = "${MngMst.AbsentSendYn}";
var earlySendYn = "${MngMst.EarlySendYn}";
var callingSendYn = "${MngMst.CallingSendYn}";
var chartColor = [ "rgb(209,239,240)","rgb(240,138,100)","rgb(90,206,126)","rgb(156,95,184)"];
	$(document).ready(function(){
		AttendUtils.getDeptStepList($("#deptCodeList"),"", false, false, "deptUpCode");

		//회사별 근태현황 event
		$(".pre, .next").click(function(){
			var targetDate;
			var startDate;
			var endDate ;
			var section_type=$(this).parent().attr("section-type")
			switch (section_type){
				case "C":
					startDate = _companyMap["startDate"];
					endDate = _companyMap["endDate"];
					break;
				case "U":
					startDate = _userMap["startDate"];
					endDate = _userMap["endDate"];
					break;
				case "D":	
					startDate = _deptMap["startDate"];
					endDate = _deptMap["endDate"];
					break;
			}

			if("+"==$(this).attr("data-paging")){
				targetDate = schedule_SetDateFormat(schedule_AddDays(endDate, 1), '-');
			}else {
				targetDate = schedule_SetDateFormat(schedule_AddDays(startDate, -1), '-');
			}

			getCompanyAttInfo(section_type, targetDate, 1);
		});

		//오늘 클릭시
		$(".calendartoday").click(function(){
			getCompanyAttInfo($(this).parent().attr("section-type"), "${TargetDate}", 1);
		});
		
		$(".calendarinput").datepicker({
			dateFormat: 'yy-mm-dd',
			beforeShow: function(input) {
	           var i_offset = $(this).closest(".calendarcontrol").offset();      // 버튼이미지 위치 조회
	           setTimeout(function(){
	              jQuery("#ui-datepicker-div").css({"left":i_offset});
	           })
	        },
			onSelect: function(dateText){
				getCompanyAttInfo($(this).closest(".pagingType03").attr("section-type"), dateText, 1);
			}
		});
		
		$(".calendarcontrol").click(function(event){
			$(this).next("input").datepicker().datepicker("show");
		});

		//슬라이드 제어
		$(".StateTop .btn_slide_close").click(function(){
			 $(this).parents().next(".StateBottom").slideToggle(500);
			 $(this).toggleClass('btn_slide_close');
			 $(this).toggleClass('btn_slide_open');
			 if($(".StateTop").has("btn_slide_open")) {
					$(".btn_slide_open").html("<spring:message code='Cache.lbl_Open' />"); //열기
					$(".btn_slide_close").html("<spring:message code='Cache.btn_Close' />"); //닫기
			 }
		});

		//탭영역-회사근태
		$('.tabCompany li').click(function(){
			$('.tabCompany li').removeClass('selected');
			$(this).addClass('selected');
			_companyMap["pageType"]=$(this).attr('data-type');
			getCompanyAttInfo('C', "" , 1);
		});

		//탭영역-my근태
		$('.tabUser li').click(function(){
			$('.tabUser li').removeClass('selected');
			$(this).addClass('selected');
			_userMap["pageType"]=$(this).attr('data-type');
			getCompanyAttInfo('U', "", 1);
		});
		
		//탭영역-부서근태
		$('.TabList li').click(function(){
			var tab_id = $(this).attr('data-tab');

			$('.TabList li').removeClass('selected');
			$('.TabCont').removeClass('selected');

			$(this).addClass('selected');
			$("#"+tab_id).addClass('selected');
			_deptMap["pageType"]=$(this).attr('data-type');
			getCompanyAttInfo('D', "", 1);
		});		
		
		$(".Status").click(function(){		//출퇴근 상세
			var startDate;
			var endDate;
			var deptCode;
			var searchStatus;
			switch ($(this).attr("data")){
				case "VAC_COM":
				case "EXTEN":
				case "HOLI":
				case "COMM":
					startDate = _companyMap["startDate"];
					endDate = _companyMap["endDate"];
					break;
				default:
					startDate = _targetDate;
					endDate = _targetDate;
					break;
			}

			var popupID		= "AttendPortalStatusPopup";
			var openerID	= "AttendPortal";
			var popupTit	= "<spring:message code='Cache.lbl_n_att_history'/>";
			var popupYN		= "N";
			var popupUrl	= "/groupware/attendPortal/AttendPortalStatusPopup.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "StartDate="		+ startDate	+ "&"
							+ "EndDate="		+ endDate	+ "&"
							+ "SearchStatus="	+ $(this).attr("data")	+ "&"
							+ "DeptUpCode="		+ $("#deptUpCode").val()	+ "&"
			
			Common.open("", popupID, popupTit, popupUrl, "820px", "750px", "iframe", true, null, null, true);
		});
		
		//검색 클릭시
		$(".btnSearchType01").click(function(){
			getCompanyAttInfo('D', "", 1);
		});
		
		//more 클릭
		$(".more").click(function(){
			switch ($(this).attr("data")){
				case "DETAIL":	//근태상셍
					var popupID		= "AttendPortalStatusPopup";
					var openerID	= "AttendPortal";
					var popupTit	= "<spring:message code='Cache.lbl_n_att_history'/>";
					var popupYN		= "N";
					var popupUrl	= "/groupware/attendPortal/AttendPortalStatusPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "StartDate="		+ _companyMap["startDate"]	+ "&"
									+ "EndDate="		+ _companyMap["endDate"]	+ "&"
									+ "SearchStatus="	+ "COMM&"
									+ "DeptUpCode="		+ $("#deptUpCode").val()	+ "&"
					
					Common.open("", popupID, popupTit, popupUrl, "820px", "750px", "iframe", true, null, null, true);
					break;
				case "ATT":	//매니저근태
					CoviMenu_GetContent('/groupware/layout/attend_AttendUserStatusViewer.do?CLSYS=attend&CLMD=user&CLBIZ=Attend');
					break;
				case "SEND":	//누락
					var popupID		= "AttendPortalSendPopup";
					var openerID	= "AttendPortal";
					var popupTit	= "<spring:message code='Cache.lbl_commuteMiss'/>";
					var popupYN		= "N";
					var popupUrl	= "/groupware/attendPortal/AttendPortalSendPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "StartDate="		+ (_callStartDate == null?"${TargetDate}":_callStartDate)	+ "&"
									+ "EndDate="		+ (_callStartDate == null?"${TargetDate}":_callEndDate)	+ "&"
					
					Common.open("", popupID, popupTit, popupUrl, "820px", "690px", "iframe", true, null, null, true);
					break;
				case "MYATT":	//사용자근태
				case "CALL":	//소명신청
					CoviMenu_GetContent('/groupware/layout/attend_AttendMyStatus.do?CLSYS=attend&CLMD=user&CLBIZ=Attend');
					break;
				case "MYREQ":	//나의 요청
					CoviMenu_GetContent('/groupware/layout/attend_AttendMyRequestMng.do?CLSYS=attend&CLMD=user&CLBIZ=Attend');
					break;
				
			}
		});
	
		//소명신청
		$(".btnApply").click(function(){
			AttendUtils.openCallPopup();
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
		
		$("#checkAll").click(function() {
			$(".commuteList input:checkbox").each(function() {
				$(this).prop("checked", $("#checkAll").prop("checked"));
			});

		});		
	});

	function goPage(pnum){
		_pageNo = pnum;
		$(".AXPaging").each(function(idx){
			$(this).removeClass("Blue");
			var valNum = $(this).attr("value");
			if(Number(valNum)===_pageNo){
				$(this).addClass("Blue");
			}
		});
		getCompanyAttInfo("D", "", pnum);
	}

	function pagging(deptPage){
		//pageing
		var pageNo = Number(deptPage.pageNo);
		var sPage = pageNo - 5;
		if(sPage<1){
			sPage = 1;
		}
		var lPage = sPage + 9;
		if(lPage>Number(deptPage.pageCount)){
			lPage = Number(deptPage.pageCount);
		}
		var nextPage = Number(lPage)+1;
		if(nextPage>Number(deptPage.pageCount)){
			nextPage = Number(deptPage.pageCount);
		}
		var prePage = Number(sPage)-1;
		if(prePage<1){
			prePage = 1;
		}
		var firstPage = 1;
		var endPage = Number(deptPage.pageCount);
		var htmlStr = "";
		htmlStr+='<input type="button" id="AXPaging_begin" class="AXPaging_begin" onclick="javascript:goPage('+firstPage+');">';
		htmlStr+='<input type="button" id="AXPaging_prev" class="AXPaging_prev" onclick="javascript:goPage('+prePage+');">';

		for(var i=sPage;i<=lPage;i++){
			var blue = "";
			if(_pageNo==i){
				blue = " Blue";
			}
			htmlStr+='<input type="button" value="'+i+'" style="min-width:20px;" class="AXPaging'+blue+'" onclick="javascript:goPage('+i+');">';
		}
		htmlStr+='<input type="button" id="AXPaging_next" class="AXPaging_next" onclick="javascript:goPage('+nextPage+');">';
		htmlStr+='<input type="button" id="AXPaging_end" class="AXPaging_end" onclick="javascript:goPage('+endPage+');">';
		return htmlStr;
	}

	function changeDept(){
		getCompanyAttInfo('A', "", 1);
	}
	
	function getCompanyAttInfo(type, targetDate, pageNo){
		_pageNo =pageNo; 
		if (targetDate != ""){
			switch (type){
				case "C":
					_companyMap["targetDate"]=targetDate;
					break;
				case "U":
					_userMap["targetDate"]=targetDate;
					break;
				case "D":	
					_deptMap["targetDate"]=targetDate;
					break;
			}
		}	
		
		var params = {
			companyMap : _companyMap
			,userMap : _userMap
			,deptMap : _deptMap
			,queryType:type
			,deptUpCode:$("#deptUpCode").val()
			,deptUpCodeWork:($("#deptUpCodeWork").val()==""?$("#deptUpCode").val():$("#deptUpCodeWork").val())
			,searchText:$("#searchText").val()
			,pageNo:_pageNo
			,pageSize:String(_pageSize)
		}
		
		$.ajax({
			type : "POST",
			contentType:'application/json; charset=utf-8',
			dataType   : 'json',
			data : JSON.stringify(params),
			url : "/groupware/attendPortal/getMangerAttStatus.do",
			success:function (data) {
				if(data.status=="SUCCESS"){
					if (data.companyCalling)			displayCompanyToday(data.companyToday, data.companyCalling, data.companyCallingCnt);
					if (data.companyDay)				displayCompanyAttInfo(data.StartDate, data.EndDate, data.companyDay);
					if (data.userAttWorkTime)			displayMyAttInfo(data.StartDate, data.EndDate, data.userAttWorkTime);
				}else{
					Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>");
				}
			},
			error:function (request,status,error){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			}
		});
	}
	
	//오늘의 회사 근태 현황
	function displayCompanyToday(todayMap, callingList, callingCnt){
		$(".StateList #work_cnt").text(AttendUtils.convertNull(todayMap["WorkCnt"],"0"));
		$(".StateList #late_cnt").text(AttendUtils.convertNull(todayMap["LateCnt"],"0"));
		$(".StateList #absent_cnt").text(AttendUtils.convertNull(todayMap["AbsentCnt"],"0"));
		$(".StateList #vac_cnt").text(AttendUtils.convertNull(todayMap["VacCnt"],"0"));
		$("#commuteCnt").text("("+callingCnt["Cnt"]+")");
		_callStartDate = callingCnt["MinDate"];
		_callEndDate = callingCnt["MaxDate"];
		$(".commuteList ul").html('');
		
		if (callingList.length == 0) {
			$(".commuteList ul").html("<p class='OWList_none'><spring:message code='Cache.msg_NoDataList' /></p>"); //조회할 목록이 없습니다.
		} else {
			$.each(callingList, function(idx, item){
				var lbl_ProfilePhoto = "<spring:message code='Cache.lbl_ProfilePhoto' />"; //프로필사진
				var dataMap = {"URName": item["URName"], "UserCode": item["UserCode"], "JobDate":item["JobDate"]};
	
				var sHtml ='<li class="" data-map=\''+JSON.stringify(dataMap)+'\' >'+
							'	<div class="chkStyle08 coChk">';
				
				var bSendMail = false;
				if (Common.getBaseConfig("isUseMail") == "Y" && Common.getSession('UR_AssignedBizSection').includes("Mail")) bSendMail = true;
				
				bSendMail = AttendUtils.isSendMail(item, {"LateSendYn":lateSendYn,"AbsentSendYn":absentSendYn,"EarlySendYn":earlySendYn,"CallingSendYn":callingSendYn});				 
				 
				if (bSendMail) {
					sHtml +='		<input type="checkbox" id="a'+idx+'" name="aa" >';
				}else{
					sHtml += '		<span style="width:24px;display:block"></span>';		
				}
				
				sHtml +='		<label for="a'+idx+'"><span class="s_check"></span></label>'+
						'	</div>'+
						'	<div class="coPhoto">';
				
				sHtml+=((item["PhotoPath"]!= null && item["PhotoPath"]!= "")?'<p><img src="'+coviCmn.loadImage(item["PhotoPath"])+'" alt="'+lbl_ProfilePhoto+'" class="mCS_img_loaded" onerror="coviCmn.imgError(this, true)"></p>':'<p class=\"bgColor'+Math.floor(idx%5+1)+'\"><strong>'+item["URName"].substring(0,1)+'</strong></p>');
				
				sHtml+=	'</div>'+
					'<div class="coTxt">'+
					'	<div class="coName"><a href="#" class="">'+item.URName + ' '+ AttendUtils.userRepJobType(item) + '('+item.DeptName+')</a></div>'+
					'	<p class="coDate">'+item.JobDate+'</p>'+
					'</div>';
					
				if (item.EndSts!= null && item.EndSts!='lbl_att_normal_offWork'){
					sHtml += '<span class="coState coState2">'+Common.getDic(item.EndSts)+'</span>';
				} else if (item.StartSts!= null && item.StartSts!='lbl_att_normal_goWork'){
					sHtml += '<span class="coState coState2">'+Common.getDic(item.StartSts)+'</span>';
				} else{
					sHtml += '<span class="coState coState1">'+Common.getDic("lbl_n_att_absent")+'</span>';
				}
				
				if (bSendMail) {
					sHtml +='<a href="#" class="btnBlueType02 btnSend" id="btnSend""><spring:message code="Cache.lbl_Send" /></a>';
				}
				
				sHtml += '</li>';
				$(".commuteList ul").append(sHtml);
			 }); 
		}
	}
	
	//기긴별 근태 현황
	function displayCompanyAttInfo(StartDate, EndDate, dataMap){
		$("#companyTit .date").text(AttendUtils.maskDate(StartDate) +" ~ "+AttendUtils.maskDate(EndDate));
		_companyMap["startDate"] = StartDate;
		_companyMap["endDate"] = EndDate;

		$("#companyState #tot_cnt").text(AttendUtils.convertNull(dataMap["UserCnt"],"0"));
		$("#companyState #exten_cnt").text(AttendUtils.convertNull(dataMap["ExtenCnt"],"0")+'<spring:message code="Cache.lbl_personCnt"/>');
		$("#companyState #holi_cnt").text(AttendUtils.convertNull(dataMap["HoliCnt"],"0")+'<spring:message code="Cache.lbl_personCnt"/>');
		$("#companyState #vac_cnt").text(AttendUtils.convertNull(dataMap["VacCnt"],"0")+'<spring:message code="Cache.lbl_personCnt"/>');
		$("#companyState #normal_cnt").text(AttendUtils.convertNull(dataMap["NormalCnt"],"0")+'<spring:message code="Cache.lbl_personCnt"/>');

		var chartData = {datasets : [{data : [],borderWidth:0,backgroundColor : chartColor}]};
		var companyObj = {data : chartData, type:"doughnut",options:{legend: { display: false }}};
		companyObj.data.labels=["<spring:message code='Cache.lbl_att_overtime_work' />","<spring:message code='Cache.lbl_att_holiday_work' />","<spring:message code='Cache.lbl_Vacation' />","<spring:message code='Cache.lbl_attendance_normal' />"]; //"연장근무","휴일근무","휴가","정상"
		
		if (dataMap["ExtenCnt"] == 0 && dataMap["HoliCnt"] == 0 && dataMap["VacCnt"] == 0) {
			companyObj.data.datasets[0].data=[0,0,0,100];
		} else {
			companyObj.data.datasets[0].data=[dataMap["ExtenCnt"],dataMap["HoliCnt"],dataMap["VacCnt"],dataMap["NormalCnt"]];
		}
		
		if( deptChart ){
			deptChart.destroy();
		}
		
		deptChart= new Chart(  $("#companyPie"), companyObj );
	}
	
	//내 근태현황
	function displayMyAttInfo(StartDate, EndDate, dataMap){
		$("#userTit .date").text(AttendUtils.maskDate(StartDate) +" ~ "+AttendUtils.maskDate(EndDate));
		_userMap["startDate"] = StartDate;
		_userMap["endDate"] = EndDate;

		
		$("#userState #tot_time").text(AttendUtils.convertSecToStr(dataMap["TotWorkTime"],"H"));
		$("#userState #work_time").text(AttendUtils.convertSecToStr(dataMap["AttRealTime"],"H"));
		$("#userState #exten_time").text(AttendUtils.convertSecToStr(dataMap["ExtenAc"],"H"));
		$("#userState #holi_time").text(AttendUtils.convertSecToStr(dataMap["HoliAc"],"H"));
		$("#userState #remain_time").text(AttendUtils.convertSecToStr(dataMap["RemainTime"],"H"));
		
		var chartData = {datasets : [{data : [],borderWidth:0,backgroundColor : chartColor}]};
		var attendObj = {data : chartData, type:"doughnut",options:{legend: { display: false }}};
		attendObj.data.labels=["<spring:message code='Cache.lbl_n_att_normalWork' />","<spring:message code='Cache.lbl_att_overtime_work' />","<spring:message code='Cache.lbl_att_holiday_work' />","<spring:message code='Cache.lbl_n_att_remainWork' />"]; //"정상근무","연장근무","휴일근무","잔여근무"
		attendObj.data.datasets[0].data=[dataMap["AttRealTime"]/60, dataMap["ExtenAc"]/60, dataMap["HoliAc"]/60, dataMap["RemainTime"]/60];
		if( myChart ){
			myChart.destroy();
		}	
		myChart= new Chart(  $("#attendPie"), attendObj ); 
	}

	function printDN(){
		if(_printDN) {
			$(".printmode").each(function () {
				var dnmode = $(this).data('dnmode');
				if ("on" == dnmode) {
					$(this).show();
				} else {
					$(this).hide();
				}
			});
		}else{
			$(".printmode").each(function () {
				var dnmode = $(this).data('dnmode');
				if ("off" == dnmode) {
					$(this).show();
				} else {
					$(this).hide();
				}
			});
		}
	}
	
	$(document).on("click",".btnSearchDetail",function(){
		var dataMap = JSON.parse($(this).attr("data-map"));
		/*if (dataMap["JobDate"] == null)
		{
			Common.Inform("지정일에 근무가 없습니다.");	
			return;
		}*/
		var popupID		= "AttendPortalDetailPopup";
		var openerID	= "AttendPortalDetail";
		var popupTit	= "<spring:message code='Cache.lbl_WeeklyMonthlyReport' />"; //근태주보/월보
		var popupYN		= "N";
		var popupUrl	= "/groupware/attendPortal/AttendPortalDetailPopup.do?"
						+ "popupID="		+ popupID	+ "&"
						+ "openerID="		+ openerID	+ "&"
						+ "popupYN="		+ popupYN	+ "&"
						+ "UserName="		+ encodeURIComponent(dataMap["URName"])	+ "&"
						+ "UserCode="		+ dataMap["UserCode"]	+ "&"
						+ "StartDate="		+ _deptMap["startDate"]	+ "&"
						+ "EndDate="		+ _deptMap["endDate"]	+ "&"
						+ "printDN="		+ _printDN	+ "&"
						+ "DeptName="		+ encodeURIComponent(dataMap["DeptName"])	+ "&"
		
		Common.open("", popupID, popupTit, popupUrl, "1124px", "700px", "iframe", true, null, null, true);
	});
	
	//선택발송
	$(document).on("click","#btnSelSend", function(){
		var toUsers="";
		var aJsonArray = new Array();

		$(".commuteList input:checked").each(function() {
			var dataMap = JSON.parse($(this).closest("li").attr("data-map"));
			var saveData ={ "UserCode":dataMap["UserCode"], "JobDate":dataMap["JobDate"]};
			
			toUsers += (i>0?", ":"")+ dataMap["URName"];
			aJsonArray.push(saveData);
		});
		
		if(aJsonArray.length == 0){
			Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>");
			return false;
		}
		
		Common.Confirm("<spring:message code='Cache.msg_apv_191' /> [To "+toUsers+"]", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				var sendParam = {"dataList" : aJsonArray }
				sendAttendMail(sendParam);
			}
		});
	});
		
	//개별발송
	$(document).on("click","#btnSend",function(){
		var aJsonArray = new Array();

		var dataMap = JSON.parse($(this).closest("li").attr("data-map"));
		Common.Confirm("<spring:message code='Cache.msg_SendQ' />  [To "+dataMap["URName"]+"]", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				var aJsonArray = new Array();
				var saveData ={ "UserCode":dataMap["UserCode"], JobDate:dataMap["JobDate"]};
				aJsonArray.push(saveData);
				var sendParam = {"dataList" : aJsonArray }
				sendAttendMail(sendParam);
			}
		});
	})
	
	function sendAttendMail(sendParam){
		$.ajax({
		    url: "/groupware/attendPortal/sendMessageTarget.do",
		    type: "POST",
			contentType:'application/json; charset=utf-8',
			dataType   : 'json',
		    data: JSON.stringify(sendParam),
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		Common.Inform("<spring:message code='Cache.lbl_Mail_SendCompletion'/>[<spring:message code='Cache.lbl_SendNumber' />: "+res.sendCnt+"]"); //전송 건수
		    	}else{
		    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
		    	}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/attendPortal/sendMessageTarget.do", response, status, error);
			}
		});
	}
</script>	