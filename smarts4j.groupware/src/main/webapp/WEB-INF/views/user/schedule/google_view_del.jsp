<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.TimeZone"%>
<%@ page import="java.util.*, java.text.*"  %>
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>

<html lang="en">
  <head>
    <meta charset="utf-8">
    <title></title>
    <meta name="description" content="">
    <meta name="author" content="">
  </head>
  <script>
	document.getElementById("google_oauth_b").onclick = google_oauth;
	document.getElementById("google_list_single_b").onclick = google_list_single;
	document.getElementById("google_list_all_b").onclick = google_list_all;
	document.getElementById("google_add_b").onclick = google_add;
	document.getElementById("google_delete_b").onclick = google_delete;
	document.getElementById("google_update_b").onclick = google_update;
	
	function google_oauth(){
		alert("oauth");
		alert("google_oauth");
		$.ajax({
		    url: "googleOauth.do",
		    type: "POST",
			success: function (data) {
				alert("인증이 성공되었습니다.");
			},
			error : function (error){
				alert("인증이 실패했습니다.");
			}
		});
	  }
	function google_list_all(){
		$.ajax({
		    url: "googleListAll.do",
		    type: "POST",
			success : function(data) {
				var result = ""
					for(var i=0;data[i] != undefined;i++){
						if(data[i] != undefined){
							result += "==========================================";
				        	result += " <br>제목 : "+data[i].summary;
				        	result += " <br>시작시간 : "+new Date(data[i].start.value);
				        	result += " <br>끝시간 : "+new Date(data[i].end.value);
				        	result += " <br>이벤트 id : "+data[i].eventId;
				        	if(data[i].attachment!= undefined){
				        		for(var j=0;data[i].attachment[j] != undefined;j++){
						        	result += " <br>첨부파일이름: "+data[i].attachment[j].title;
						        	result += " <br>첨부파일주소 : "+data[i].attachment[j].fileUrl;
				        		}
				        	}
				        	result += " <br>color id : "+data[i].colorId;
				        	if(data[i].attendee!= undefined){
				        		for(var j=0;data[i].attendee[j] != undefined;j++){
				        			result += " <br>참석자"+j+"번째 : "+data[i].attendee[j].email;
				        		}
				        	}
				        	if(data[i].reminders.overrides!=undefined){
				        		for(var j=0;data[i].reminders.overrides[j] != undefined;j++){
				        			result += " <br>알림방식 : "+data[i].reminders.overrides[j].method;
				        			result += " <br>알림몇분전: "+data[i].reminders.overrides[j].minutes;
				        		}
				        	}
				        	result += " <br>생성시간 : "+new Date(data[i].create.value);
				        	result += " <br>생성자 : "+data[i].creator.email;
				        	result += " <br>이벤트 링크 : "+data[i].htmllink;
				        	result += " <br>위치 : "+data[i].location;
				        	result += " <br>최종업데이트 날자 : "+new Date(data[i].updated.value);
				        	result += "<br>";
						}
					}
		        	$("#ListDiv").html(result);
			},
			error: function (err) {
		        alert("이벤트 불러오기 실패");
		    }
		});
	}
	function google_list_single(){
		alert("single");
		$.ajax({
		    url: "googleListSingle.do",
		    type: "POST",
			success : function(data) {
				var result = ""
				for(var i=0;data[i] != undefined;i++){
					if(data[i] != undefined){
						result += "==========================================";
			        	result += " <br>제목 : "+data[i].summary;
			        	result += " <br>시작시간 : "+new Date(data[i].start.value);
			        	result += " <br>끝시간 : "+new Date(data[i].end.value);
			        	result += " <br>이벤트 id : "+data[i].summary;
			        	result += " <br>첨부파일 : "+new Date(data[i].start.value);
			        	result += " <br>color id : "+new Date(data[i].end.value);
			        	
			        	result += " <br>참석자 : "+data[i].summary;
			        	result += " <br>알림 : "+new Date(data[i].reminders);
			        	result += " <br>생성시간 : "+new Date(data[i].create);
			        	result += "<br>";
					}
				}
	        	$("#ListDiv").html(result);
			},
			error: function (err) {
		        alert("이벤트 불러오기 실패");
		    }
		});
	}
	//일정 등록하는 화면
	function google_add(){
		alert("add");
		$.ajax({
		    url: "googleAdd.do",
		    type: "POST",
		    data: {
				"summary" :document.forms["InsertForm"]["summary"].value,
				"description" : document.forms["InsertForm"]["description"].value,
				"startTime" : document.forms["InsertForm"]["startTime"].value,
				"startTimeZone" :document.forms["InsertForm"]["startTimeZone"].value,
				"endTime" : document.forms["InsertForm"]["endTime"].value,
				"endTimeZone" : document.forms["InsertForm"]["endTimeZone"].value,
				"location" :document.forms["InsertForm"]["location"].value,
				"attendee" : document.forms["InsertForm"]["attendee"].value,
				"method" : document.forms["InsertForm"]["method"].value,
				"endTime" : document.forms["InsertForm"]["endTime"].value,
				"minute" : document.forms["InsertForm"]["minute"].value,
				"rrule" : document.forms["InsertForm"]["rrule"].value
			},
			success : function(data) {
				alert("이벤트 추가에 성공했습니다.")
			},
			error: function (err) {
		        alert("이벤트 추가에 실패했습니다.");
		    }
		});
	} 
	function google_delete(){
		alert("delete");
		$.ajax({
		    url: "googleDelete.do",
		    type: "POST",
		    data: {
				"eventId" :document.forms["InsertForm"]["eventId"].value
			},
			success : function(data) {
				alert("이벤트 삭제에 성공했습니다.")
			},
			error: function (err) {
		        alert("이벤트 삭제에 실패했습니다.");
		    }
		});
	}
	function google_update(){
		alert("update");
		$.ajax({
		    url: "googleUpdate.do",
		    type: "POST",
		    data: {
				"summary" :document.forms["InsertForm"]["summary"].value,
				"description" : document.forms["InsertForm"]["description"].value,
				"startTime" : document.forms["InsertForm"]["startTime"].value,
				"startTimeZone" :document.forms["InsertForm"]["startTimeZone"].value,
				"endTime" : document.forms["InsertForm"]["endTime"].value,
				"endTimeZone" : document.forms["InsertForm"]["endTimeZone"].value,
				"location" :document.forms["InsertForm"]["location"].value,
				"attendee" : document.forms["InsertForm"]["attendee"].value,
				"method" : document.forms["InsertForm"]["method"].value,
				"endTime" : document.forms["InsertForm"]["endTime"].value,
				"minute" : document.forms["InsertForm"]["minute"].value,
				"rrule" : document.forms["InsertForm"]["rrule"].value,
		    	"eventId" :document.forms["InsertForm"]["eventId"].value
			},
			success : function(data) {
				alert("이벤트 업데이트에 성공했습니다.")
			},
			error: function (err) {
		        alert("이벤트 업데이트에 실패했습니다.");
		    }
		});
	}
    </script>
	<style>
	div{
		border : 1px solid black;
		margin-top:10px;
	}

	</style>
  <body>
  
	  <div>
	  <form name="OauthForm" onsubmit="google_insert()" method="post">
	     <table>
	  		<tr>
				<td><input type="button" onclick= "google_oauth()" value="연동로그인" id="google_oauth_b"></td>
			</tr>
		 </table>
	  </form>
	  </div>
	  <!-- 가져온 이벤트 출력하는 함수 -->
	  <div>
	  <input type="button" onclick="google_list_all()" value="모든일정확인" id="google_list_all_b">
	  	***이벤트 목록***<br>
	  	<p id="ListDiv"></p>
	  </div>
	  <div>
	    <form name="InsertForm" onsubmit="google_add()" method="post">
		  <table>
			<%
				TimeZone tz[]=new TimeZone[6];
			    Date date = new Date();
			    DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss (z Z)");
			    
			    tz[0] = TimeZone.getTimeZone("Asia/Seoul"); df.setTimeZone(tz[0]);
			    tz[1] = TimeZone.getTimeZone("Greenwich"); df.setTimeZone(tz[1]);
			    tz[2] = TimeZone.getTimeZone("America/Los_Angeles"); df.setTimeZone(tz[2]);
			    tz[3] = TimeZone.getTimeZone("America/New_York"); df.setTimeZone(tz[3]);
			    tz[4] = TimeZone.getTimeZone("Pacific/Honolulu"); df.setTimeZone(tz[4]);
			    tz[5] = TimeZone.getTimeZone("Asia/Shanghai"); df.setTimeZone(tz[5]);
			%>
			<tr><td>제목</td><td><input type="text" name="summary"></td>
			<tr><td>설명</td><td><input type="text" name="description"></td>
			<tr>
			<td>시작시간</td>
			<td><input type="datetime-local" name="startTime"></td>
			<td>타임존</td><td><select name="startTimeZone">
			<% for(int i=0;i<6;i++){ %>
			   <option value="<%=tz[i].getID() %>"><%=tz[i].getID() %></option>
			  <%} %>
			</select></td></tr>
			
			<tr>
			<td>끝 시간</td>
			<td><input type="datetime-local" name="endTime">></td>
			<td>타임존</td><td>
			<select id="endTimeZone">
			<% for(int i=0;i<6;i++){ %>
			  <option value="<%=tz[i].getID() %>"><%=tz[i].getID() %></option>
			  <%} %>
			</select></td></tr>
			
			<tr><td>장소</td><td><input type="text" name="location"></td>
			<tr><td>참석자</td><td><input type="text" name="attendee" value="@gmail.com"></td>
			<tr><td>알림</td>
			<td>
			<select name="method">
				<option value="email">email</option>
				<option value="popup">popup</option>
				<option value="sms">sms</option>
			</select></td>
				<td>분</td>
				<td><input type="text" value=0 name="minute"></td>
			</tr>
			
			<tr><td>반복쿼리</td><td><input type="text" name="rrule"></td></tr>
			<tr><td colspan=3>
			RRULE:FREQ=DAILY(매일 반복)<br>
			RRULE:FREQ=DAILY;COUNT=10(10번 반복)<br>
			RRULE:FREQ=DAILY;UNTIL=20150919T063000Z(해당 날짜까지)<br>
			
			RRULE:FREQ=WEEKLY;BYDAY=TH(매주 목요일)<br>
			RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR; (매주 월,수,금)<br>
			RRULE:FREQ=WEEKLY;BYDAY=TU;INTERVAL=2(2주에 한번, 목요일마다)<br>
			<tr>
	  			<td>이벤트 아이디</td>
	  			<td><input type="text" id="eventId"></td>
	  			
	  		</tr>
			</td></tr>
			<tr>
				<td><input type="button" onclick="google_add()" value="일정추가" id=google_add_b></td>
				<td><input type="button" onclick="google_update()" value="일정수정" id=google_update_b></td>
				<td><input type="button" onclick="google_delete()" value="일정삭제" id=google_delete_b></td>
				
			</tr>
	      </table>
	   	</form>
	  </div>
  </body>
</html>

