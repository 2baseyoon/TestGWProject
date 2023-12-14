<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>	
	<div class="popContent sclist">
		<div class="cRConTop sctitType">
			<h2 class="title"></h2>
			<div class="sclist pagingType02">
				<a href="#" class="pre" onclick="changeDate('PREV');"></a><a href="#" class="next" onclick="changeDate('NEXT');"></a><a href="#" class="btnTypeDefault" onclick="changeDate('CURRENT');">오늘</a>
			</div>
			<div class="sclist pagingType02" style="float: right;">
				<!-- 
				<select id="schSelect" style="height: 33px;">
					<option value="All">전체일정</option>
					<option value="Person">개인일정</option>
				</select> 
				--> <!-- 참석자 일정 확인 시 일정조회 관련 권한 문제로 개인 일정만 표시되도록 전체일정 제외 -->
			</div>
		</div>
		<div class="resDayListCont">
			<div class="reserTblContent reserTblTit sclist_pop">
				<div class="chkStyle04">
					<input type="checkbox" id="tt01" onclick="setWorkTime();"><label for="tt01"><span></span>업무시간</label>
				</div>
				<div class="reserTblView sclist_pop01">
					<table class="reserTbl sclist_pop02">
						<tbody>
							<tr>
								<th colspan="2">00</th>
								<th colspan="2">01</th>
								<th colspan="2">02</th>
								<th colspan="2">03</th>
								<th colspan="2">04</th>
								<th colspan="2">05</th>
								<th colspan="2">06</th>
								<th colspan="2">07</th>
								<th colspan="2">08</th>
								<th colspan="2">09</th>
								<th colspan="2">10</th>
								<th colspan="2">11</th>
								<th colspan="2">12</th>
								<th colspan="2">13</th>
								<th colspan="2">14</th>
								<th colspan="2">15</th>
								<th colspan="2">16</th>
								<th colspan="2">17</th>
								<th colspan="2">18</th>
								<th colspan="2">19</th>
								<th colspan="2">20</th>
								<th colspan="2">21</th>
								<th colspan="2">22</th>
								<th colspan="2">23</th>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div class="mScrollV scrollVType01 scrollbar">
				<div class="reserTblContent reserTblCont sclist_pop03">
					<div></div>
					<div class="reserTblView sclist_pop01">
						<table class="reserTbl sclist_pop02">
							<tbody></tbody>
						</table>
					</div>
				</div>
			</div>
		</div>	
		<div class="bottom sclistbtn">
			<a href="#" class="btnTypeDefault" onclick="Common.Close(); return false;">닫기</a>
		</div>
	</div>
</body>

<script>
	var CLSYS = CFN_GetQueryString("CLSYS");
	var CLBIZ = CFN_GetQueryString("CLBIZ");
	var attendanceInfos = decodeURI(CFN_GetQueryString("attendanceInfos")).split(",");
	var startDate = CFN_GetQueryString("startDate");
	
	var today; // 오늘 날짜
	var timeStart = 0; // 업무 시작 시간
	var timeEnd = 24; // 업무 종료 시간
	var nowDate; // 현재 날짜
	var nowHour; // 현재 시간
	var attMemCnt = 0; // 참석자 수
	var isWorkTime = false; // 업무 시간 체크 여부
	
	$(document).ready(function(){
		
		// 현재 시간 타입존 적용
		today = new Date(CFN_GetLocalCurrentDate().replaceAll("-", "/")).format("yyyy.MM.dd HH");
		
		// 현재 일자
		nowDate = today.split(" ")[0];
		
		// 현재 시간
		nowHour = Number(today.split(" ")[1]);
		
		if(startDate == "undefined") {
			startDate = nowDate;
		}
		
		$(".title").text(startDate);
		
		if(startDate == nowDate) {
			$(".reserTblContent .reserTbl th").eq(nowHour).addClass("selected");	
		}
		
		// 참석자 이름 가져오기
		var attNameStr = '';
		$.each(attendanceInfos, function(idx, uInfo){
			var userCode = uInfo.split(" ")[0];
			var userName = uInfo.split(" ")[1];
			attNameStr += '<p uid='+userCode+'>'+userName+'</p>';
			
			chkAttMemberSch(userCode);
		});
		
		$(".scrollbar .reserTblContent div").eq(0).html(attNameStr);
		
		$("#schSelect").on("change", setAttMemberSch);
		
    	// 스크롤 바인딩
		coviCtrl.bindmScrollV($(".mScrollV"));
	})
	
	// 날짜 변경 이벤트
	function changeDate(mode){
		if(mode == "PREV"){ // 이전
			var pDate = schedule_SetDateFormat(schedule_AddDays(new Date(startDate.replaceAll(".", "/")), -1), '.');
			startDate = pDate;
			$(".title").text(startDate);
		}else if(mode == "NEXT"){ // 이후
			var nDate = schedule_SetDateFormat(schedule_AddDays(new Date(startDate.replaceAll(".", "/")), 1), '.');
			startDate = nDate;
			$(".title").text(startDate);
		}else{ // 오늘
			startDate = today.split(" ")[0];
			$(".title").text(startDate);
		}
		
		if(nowDate == startDate) {
			$(".reserTblContent .reserTbl th").eq(nowHour).addClass("selected");	
		} else {
			$(".reserTblContent .reserTbl th").removeClass("selected");
		}
		
		$(".scrollbar .reserTblView .reserTbl tr td div").removeClass("selectedComp");
		
		setAttMemberSch();
	}
	
	function setAttMemberSch(){
		var len = $(".scrollbar .reserTblContent div p").length;
		attMemCnt = 0;
		$(".scrollbar div table tbody").empty();
		
		for(var i = 0; i < len; i++){
			var uID = $(".scrollbar .reserTblContent div p").eq(i).attr("uid");
			
			chkAttMemberSch(uID);
		}
	}
	
	// 업무 시간 체크박스 이벤트
	function setWorkTime(){
		var workTimeStr = '';
		isWorkTime = !isWorkTime;
		
		if(isWorkTime){
	    	Common.getBaseConfigList(["WorkStartTime", "WorkEndTime"]);		    	
		    if(coviCmn.configMap["WorkStartTime"] != ""){
		    	timeStart = Number(coviCmn.configMap["WorkStartTime"]);
		    }
		    if(coviCmn.configMap["WorkEndTime"] != ""){
		    	timeEnd = Number(coviCmn.configMap["WorkEndTime"]);
		    }
		}else{
			timeStart = 0;
	    	timeEnd = 24;
		}
		
		for(var i = timeStart; i < timeEnd; i++){
			var nowClass = '';
			
			if(nowHour == i){
				nowClass = 'class="selected"';
			}
			
	    	if(i >= 10){
			    workTimeStr += '<th colspan="2" '+nowClass+'>'+i+'</th>';
	    	}else{
			    workTimeStr += '<th colspan="2" '+nowClass+'>0'+i+'</th>';
	    	}
	    }
		
		$(".sclist_pop .reserTblView.sclist_pop01 tbody tr").html(workTimeStr);
		setAttMemberSch();
	}
	
	var URBG_ID;
	var DEPTID;
	function getUserInfo(userCode){
		$.ajax({
		    url: "/groupware/privacy/getUserBasicInfo.do",
		    type: "POST",
		    data: {
		    	"userCode" : userCode
		    },
		    async: false,
		    success: function(data){
		    	URBG_ID = data.list[0].Seq;
		    	DEPTID = data.list[0].DeptCode;
	        },
	        error: function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/getACLFolder.do", response, status, error);
			}
		});
	}
	
	function getACLFolderID(userCode){
		var folderIDs = "";
		var schAclArray;
		getUserInfo(userCode);
		
		$.ajax({
		    url: "/groupware/schedule/getUserACLFolder.do",
		    type: "POST",
		    data: {
		    	"isCommunity": false,
		    	"USERID": userCode,
		    	"URBG_ID": URBG_ID,
		    	"DN_ID": Common.getSession("DN_ID"),
		    	"DEPTID": DEPTID,
		    	"DN_Code": Common.getSession("DN_Code")
		    },
		    async: false,
		    success: function(data){
		    	if(data.status == "SUCCESS"){
		    		schAclArray = data;
		    		
		    		$($(schAclArray).get(0).view).each(function(i, obj){
		    			folderIDs += obj.FolderID + ",";
		    		});
		    		
		    		folderIDs = "(" + folderIDs.substring(0, folderIDs.length-1) + ")";
		    	}else{
		    		Common.Error(Common.getDic("msg_apv_030")); // 오류가 발생했습니다.
		    	}
	        },
	        error: function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
		
		$.ajax({
		    url: "/groupware/schedule/getACLLeftFolder.do",
		    type: "POST",
		    async: false,
		    data: {
		    	"FolderIDs" : folderIDs
		    },
		    success: function(res){
		    	folderIDs = "";
		    	if(res.status == "SUCCESS"){
		     		if(res.totalFolder.length > 0){
		     			$(res.totalFolder).each(function(idx, item){
		     				folderIDs += ";"+item.FolderID;
		     			});
		     			
		     			$(res.listFolder).each(function(idx, item){
		     				folderIDs += ";"+item.FolderID;
		     			});
		     		}
		    	}
		    },
	        error: function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/getACLLeftFolder.do", response, status, error);
			}
		});
		
		return folderIDs+";";
	}
	
	function chkAttMemberSch(userCode){
		var folderIDs = "";
		
		if($("#schSelect").val() == "All"){
			folderIDs = getACLFolderID(userCode);
		}else{
			folderIDs = ";"+Common.getBaseConfig("SchedulePersonFolderID")+";";
		}
	    
		$.ajax({
		    url: "/groupware/schedule/getList.do",
		    type: "POST",
		    async: false,
		    data: {
		    	"FolderIDs": folderIDs,
		    	"StartDate": CFN_TransServerTime(startDate.replaceAll(".", "-") + ' 00:00'),
		    	"EndDate": CFN_TransServerTime(schedule_SetDateFormat(schedule_AddDays(startDate.replaceAll(".", "-"), 1),'-') + ' 00:00'),
		    	"UserCode": userCode,
		    	"lang": Common.getSession("lang"),
			},
		    success: function(res){
		    	if(res.status == "SUCCESS"){
		    		var resList = res.list;
		    		var selVal = false;
		    		var schHTML = $("<tr>");
					
		    		if(resList != null && resList != ""){
	    				for(var i = timeStart*2; i<(timeEnd*2); i++){
	    					$.each(resList, function(idx, item){
	    						var startHour = Number(item.StartTime.split(":")[0]);
				    			var startMin = Number(item.StartTime.split(":")[1]);
				    			var endHour = Number(item.EndTime.split(":")[0]);
				    			var endMin = Number(item.EndTime.split(":")[1]);
				    			var startNum = 0, endNum = 0;
				    			
				    			var itemStartDate = Number(item.StartDate.replaceAll("-", ''));
				    			var itemEndDate = Number(item.EndDate.replaceAll("-", ''));
				    			var checkDate = Number(startDate.replaceAll(".", ''));
								
								if(checkDate > itemStartDate){
									startNum = 0;
								}else if(startMin >= 30){
									startNum = startHour*2 + 1;
								}else{
									startNum = startHour*2;
								}
								
								if(checkDate < itemEndDate){
									endNum = timeEnd*2 + 1;
								}else if(item.StartTime == item.EndTime){
									endNum = -1;
								}else if(endMin > 30){
									endNum = endHour*2 + 1;
								}else if(endMin == 0){
									endNum = endHour*2 - 1;
								}else{
									endNum = endHour*2;
								}
				    			
	    						if(i >= startNum && i <= endNum){
	    							selVal = true;
	    						}
	    					});
	    					
	    					if(selVal){
	    						$(schHTML).append($("<td>").append($("<div>").addClass("selectedComp")));
	    					}else{
	    						$(schHTML).append($("<td>").append($("<div>")));
	    					}
	    					
	    					selVal = false;
	    				}
		    		}else{
		    			for(var i = timeStart*2; i<(timeEnd*2); i++){
	    					$(schHTML).append($("<td>").append($("<div>")));
	    				}
		    		}
		    		
		    		$(".scrollbar div table tbody").append($(schHTML));
		    	}else{
					Common.Error("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
				}
	        },
	        error: function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/getView.do", response, status, error);
			}
		});
	}
</script>