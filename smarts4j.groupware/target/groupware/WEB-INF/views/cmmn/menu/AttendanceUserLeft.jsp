<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import = "java.text.SimpleDateFormat" %>
<%@ page import = "java.util.Date" %>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<% String approvalAppPath = PropertiesUtil.getGlobalProperties().getProperty("approval.app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<%

	String bizSection = request.getParameter("bizSection");
	String serverTime = ComUtils.GetLocalCurrentDate("yyyy/MM/dd/HH/mm/ss");
	
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();

%>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/AttendanceManagement/resources/css/AttendanceManagement.css<%=resourceVersion%>">
<%-- <jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include> --%>
<script type="text/javascript" src="/groupware/resources/script/user/attendance.js<%=resourceVersion%>"></script>
<div class='cLnbTop'>
<input type="hidden" id="leftSchSeq" value=""/>
<input type="hidden" id="hisSeq" value=""/>
<input type="hidden" id="PreStsName" value="" />
<input type="hidden" id="PreStsSeq" value="" />
	<h2><spring:message code='Cache.MN_754'/></h2>
	<div class="attendanceM_time_wrap"  >
		<p class="attendanceM_time" id="atTime" style="display:none;"></p>
		<p class="attendanceM_time_type" id="atSchSts" style="display:none;"></p>
		<p class="attendanceM_time_tx" id="atSts" style="display:none;"></p>
<!-- 		<p class="attendanceM_time_tx">출근완료:08:10:17</p> -->
	</div>
	<div id="attStsBtn1" style="display:none;">
		<a href="#" onclick="setAtt('Y');" class='btnType01 ' ><spring:message code='Cache.btn_att_checkin'/></a>
	</div>
	<div id="attStsBtn2"  style="display:none;">
		<a href="#" onclick="setAtt('N');" class='btnType01 '><spring:message code='Cache.btn_att_checkout'/></a>
		<!-- <select class="half"></select> -->
	</div>
	<div id="attStsBtn3"  style="display:none;">
		<a href="#" onclick="" class='btnType01 ' ><spring:message code='Cache.lbl_att_left_sts_checkout'/></a>
	</div>
</div>					
<div class='cLnbMiddle mScrollV scrollVType01' style="top:200px;">
	<ul class="contLnbMenu attendanceM_Menu" id="leftmenu"></ul>			
</div>

<script type="text/javascript">
	
	//# sourceURL=AttendanceUserLeft.jsp
	
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	
	/*추후 테마별 css 적용 확인 할 것*/
	
	var themeCode = '${themeCode}'; 
	var themeType = '${themeType}';
	
<%-- 	var curDate = "<%=fmtDate%>";

	var curYear = "<%=year%>";
	var curMonth = "<%=month%>";
	var curDay = "<%=day%>";
	var curHours = "<%=hour%>";
	var curMinute = "<%=min%>";
	var curSeconds = "<%=sec%>";
	var vTime = new Date(curYear,curMonth,curDay,curHours,curMinute,curSeconds);
 --%>	
	//top메뉴 진입 시  내 근태현황으로 이동
	$(document).ready(function(){
		initLeft(); //메뉴로딩
		getLeftData(); // 기본정보표기
		
		/*근태관리 메뉴 클릭 시 출퇴근 버튼정보 리로드*/
		$(".attendanceM_Menu li").click(function(){ 
			getLeftData();
		});
		/*주간 월간 리트트 변경시  출퇴근 버튼정보 리로드*/
		$(".attendanceMschSelect li").click(function(){ 
			getLeftData();
		});
		
		
	})
	
	function getLeftData(){
		
		/*관리자 권한 외 엑셀 다운로드 불가*/
		if("${adminCnt}"!="1"){
			$(".btnExcel").remove();
		} 
		
		
		$.ajax({
			type:"POST",
			url:"/groupware/layout/getCommuLeftSts.do",
			success:function (data) {
				if(data.status =="SUCCESS"){
					var btnSts = data.btnSts;
					var schList = data.schList;
					var atSts = "";
					if("X" != btnSts){
						//근무제 seq
						$("#leftSchSeq").val(data.schList[0].SchSeq);
						
						$("#atSchSts").html(data.schList[0].schMulti);	//근무제 표시	
						$("#atSchSts").removeAttr("style");
						
						setWorkStatus( data.workList , data.workHisList ); //업무상태 리스트
						//setCommBtnSet( data.btnSts );	//출퇴근 버튼 상태
						//출퇴근 버튼 상태
						if(data.schList[0].PcUseYn=="Y"){
							if("Y" == btnSts){
								$("#attStsBtn3").attr("style","display:none");
								$("#attStsBtn2").attr("style","display:none");
								$("#attStsBtn1").removeAttr("style");
							}else if("N" == btnSts){
								$("#attStsBtn3").attr("style","display:none");
								$("#attStsBtn1").attr("style","display:none");
								$("#attStsBtn2").removeAttr("style");
							}else if("S" == btnSts){	//당일 퇴근처리 완료시
								$("#attStsBtn2").attr("style","display:none");
								$("#attStsBtn1").attr("style","display:none");
								$("#attStsBtn3").removeAttr("style");
							}
						}else{
							$("#attStsBtn1").attr("style","display:none");
							$("#attStsBtn2").attr("style","display:none");
							$("#attStsBtn3").attr("style","display:none");
						}

						if("Y" == btnSts){
							atSts = "<spring:message code='Cache.lbl_att_left_sts_wait'/>"; 
						}else if("N" == btnSts){
							atSts = "<spring:message code='Cache.lbl_att_left_sts_checkin'/>";
							atSts += data.sTime; //출근시간
						}else if("S" == btnSts){	//당일 퇴근처리 완료시
							atSts = "<spring:message code='Cache.lbl_att_left_sts_checkout'/>";
							//atSts += data.eTime; //퇴근시간
						}
						$("#atSts").html(atSts);
						$("#atSts").removeAttr("style");
						
					}
					
					
					
					$("#hisSeq").val(data.HisSeq);
					
					
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); //저장 중 오류가 발생하였습니다.
				}
			}
		});
		
		setMenuTime();
	}
	
	
	
	function initLeft(){
		
	 	var opt = {
	 			lang : "ko",
	 			isPartial : "true"
	 	};
	 	var coviMenu = new CoviMenu(opt);
	 	
	 	if(leftData.length != 0){
	 		coviMenu.render('#leftmenu', leftData, 'userLeft');
	 	}
	 	
	 	
	 	if(loadContent == 'true'){
	   		CoviMenu_GetContent('/groupware/layout/attendance_AttendanceStatusWeek.do?CLSYS=attendance&CLMD=user&CLBIZ=Attendance');
	   		g_lastURL = '/groupware/layout/attendance_AttendanceStatusWeek.do?CLSYS=attendance&CLMD=user&CLBIZ=Attendance';
	  	}
	 	
		
	
	} 
	
	var serverTimeStr = "<%=serverTime%>"; 
	var spServerTime = serverTimeStr.split("/");
	var serverTime = new Date(spServerTime[0],spServerTime[1]-1,spServerTime[2],spServerTime[3],spServerTime[4],spServerTime[5]);
	var clientTime = new Date();
	var time_diff = serverTime.getTime() - clientTime.getTime();
	function setMenuTime(){

		var now_client_time = new Date();
	       
		var now_server_time = new Date(now_client_time.getTime() + time_diff);

		var timeFormat = addZeros(now_server_time.getHours(),2) + ":" + addZeros(now_server_time.getMinutes(),2) ;
		$("#atTime").html(timeFormat);
		setTimeout("setMenuTime()",1000);
		
		$("#atTime").removeAttr("style");
	}

	
	function addZeros(num, digit) { // 자릿수 맞춰주기
		  var zero = '';
		  num = num.toString();
		  if (num.length < digit) {
		    for (i = 0; i < digit - num.length; i++) {
		      zero += '0';
		    }
		  }
		  return zero + num;
	} 
	

	//업무상태 표시
	function setWorkStatus(workList,hisList){
		var opStr = "";
		for(var i=0;i<workList.length;i++){
			opStr += "<option ";
			for(var j=0;j<hisList.length;j++){
				if(workList[i].WorkStsSeq == hisList[j].WorkStsSeq){
					opStr +="selected ";
					
					$("#PreStsSeq").val(hisList[j].WorkStsSeq);
					$("#PreStsName").val(hisList[j].TransMultiDisplayName);
					
				}
			}
			opStr += "value='"+workList[i].WorkStsSeq+"'>"+workList[i].TransMultiDisplayName;
			opStr += "</option>";
		}
		$("#attStsBtn2 select").html(opStr);
		
		$("#attStsBtn2 select").change(function(){
			
			var params = {
					"WorkStsSeq" : this.value
					,"PreStsSeq" : $("#PreStsSeq").val()
					,"PreStsName" : $("#PreStsName").val()
			}
			
			$.ajax({
				type:"POST",
				url:"/groupware/layout/changeWorkSts.do",
				data : params,
				dataType : "JSON",
				success:function (data) {
					if(data.status =="SUCCESS"){
						
					}else{
						Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); //저장 중 오류가 발생하였습니다.
					}
				}
			});
		});
	}
	
	
	
	

</script>