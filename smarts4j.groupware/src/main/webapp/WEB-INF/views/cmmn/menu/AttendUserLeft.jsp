<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import = "java.text.SimpleDateFormat" %>
<%@ page import = "java.util.Date" %>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%
	String serverTime = ComUtils.GetLocalCurrentDate("yyyy/MM/dd/HH/mm/ss");
%>
<div class='cLnbTop'>
<input type="hidden" id="leftSchSeq" value=""/>
<input type="hidden" id="hisSeq" value=""/>
<input type="hidden" id="PreStsName" value="" />
<input type="hidden" id="PreStsSeq" value="" />
	<h2 onclick="CoviMenu_GetContent('/groupware/attend/attendHome.do?CLSYS=attend&CLMD=user&CLBIZ=Attend&AuthMode=U')" style="cursor: pointer;"><spring:message code='Cache.MN_754'/></h2>
	<div class="attendanceM_time_wrap"  ondblclick="CoviMenu_GetContent('/groupware/attend/attendHome.do?CLSYS=attend&CLMD=user&CLBIZ=Attend&AuthMode=U');">
		<p class="attendanceM_time" id="atTime" style="display:none;"></p>
		<!-- <p class="attendanceM_time_type" id="atSchSts" style="display:none;"></p> --><!-- 근무제  -->
		<p class="attendanceM_time_tx" id="atSts" style="display:none;"></p>
	</div>
	<div id="attStsBtn" style="display:none;">
		<a href="#" class='btnType01 ' ></a>
	</div>
</div>					
<div class='cLnbMiddle mScrollV scrollVType01' style="top:155px;">
	<ul class="contLnbMenu ATM_Menu" id="leftAttendMenu"></ul>			
</div>

<script type="text/javascript">
var attendUserLeft = function(){
	
	//# sourceURL=AttendUserLeft.jsp
	
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	
	var themeCode = '${themeCode}'; 
	var themeType = '${themeType}';
	
	//현재 사용자 메뉴별 접근권한
	var aclAuth ;
	var contentUrl = '/groupware/attend/attendHome.do?CLSYS=attend&CLMD=user&CLBIZ=Attend&AuthMode=U';
	var $mScrollV = $('.mScrollV');
	//top메뉴 진입 시  내 근태현황으로 이동
	$(document).ready(function(){
		initLeft(); //메뉴로딩
		setMenuTime(); //현재시간
		getCommuteData() //출퇴근버튼
		
		
		//leftmenu 하위 리스트 조회
		$(".selOnOffBox").find('a').click(function () {	
			var cla= $(this).closest('li').find('.selOnOffBoxChk');
			
			var liname = $(this).parent().parent().attr("class");
			
			if(liname=="ATM_Menu03"||liname=="ATM_Menu04"||liname=="ATM_Menu06"||liname=="ATM_Menu07"||liname=="ATM_Menu08"||liname=="ATM_Menu09"){
				if(cla.hasClass('active')){
					cla.removeClass("active");
					$(this).removeClass("active");
				}else{
					cla.addClass("active");
					$(this).addClass("active"); 
				}			
			}
		});  
		
		//left menu 클릭 시 해당 메뉴에 대한 접근 권한 조회  각 메뉴별로 버튼 기능 제한이 필요 없는 경우 : 속도 이슈로 인해 메뉴별로 적용 추천
		coviCtrl.bindmScrollV($('.mScrollV'));
		$("#leftAttendMenu li").click(function(){
			//aclAuth = AttendUtils.getACL($(this).data("menu-id"),"SCDMEVR");
		});
		
		
	})
	
	function initLeft(){
		
	 	var opt = {
	 			lang : "ko",
	 			isPartial : "true"
	 	};
	 	var coviMenu = new CoviMenu(opt);
	 	
	 	if(leftData.length != 0){
	 		coviMenu.render('#leftAttendMenu', leftData, 'userLeft');
	 	}
	 	
	 	if(loadContent == 'true'){
			CoviMenu_OpenMenu(contentUrl);
	   		g_lastURL = contentUrl;
	  	}
	} 
	
	/*
		사용자 timezone 에 따른 현재시간 정보 
	*/
	var serverTimeStr = "<%=serverTime%>";
	var spServerTime = serverTimeStr.split("/");
	var serverTime = new Date(spServerTime[0],spServerTime[1]-1,spServerTime[2],spServerTime[3],spServerTime[4],spServerTime[5]);
	var clientTime = new Date();
	var time_diff = serverTime.getTime() - clientTime.getTime();
	function setMenuTime(){

		var now_client_time = new Date();
	       
		var now_server_time = new Date(now_client_time.getTime() + time_diff);

		var timeFormat = addZeros(now_server_time.getHours(),2) + ":" + addZeros(now_server_time.getMinutes(),2) + ":" + addZeros(now_server_time.getSeconds(),2) ;
		$("#atTime").html(timeFormat);

		setTimeout(function(){setMenuTime();$("#atTime").removeAttr("style");},1000);
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
	

	/*
		사용자 출 퇴근 정보 조회
	*/
	function getCommuteData(){
		//출퇴근 버튼 설정
		
		var data = {
			commuteChannel : "W"
		}
		$.ajax({
			type:"POST",
			data:data,
			dataType:"json",
			url:"/groupware/attendCommute/getCommuteBtnStatus.do",
			success:function (data) {
				if(data.result=="ok"){
					$("#leftAttendMenu").closest(".cLnbMiddle").css("top","200px");
					$("#attStsBtn").removeAttr("style");
					$("#attStsBtn a").html(Common.getDic(data.btnLabel));
					$("#attStsBtn a").off('click');
					$("#attStsBtn a").on('click',function(){
						//setCommute(data.commuteStatus,data.targetDate);
						AttendUtils.openCommuteAlram(data.commuteStatus,data.targetDate);
					});
					
					$("#atSts").removeAttr("style");
					var stsStr = Common.getDic(data.atSts);
					if(data.commuteStatus=="E"){
						stsStr +=" : "+data.startTime; 
					}else if(data.commuteStatus=="SE"){ 
						stsStr +=" : ["+data.targetDate+"]"+data.startTime;
					}else if(data.commuteStatus=="EE"){
						stsStr +=" : "+data.endTime; 
					}else if(data.commuteStatus=="O"){
						stsStr +=" : "+data.startTime+"~"+data.endTime; 
						$("#attStsBtn a").off('click');
					}
					$("#atSts").html(stsStr);
				}
			}
		});
	}
	this.getMainUrl=function(){
		return contentUrl;
	}
}();
</script>