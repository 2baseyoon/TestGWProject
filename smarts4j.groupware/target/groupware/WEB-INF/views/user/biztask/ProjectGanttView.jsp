<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>jsGantt Improved</title>
	<meta name="description" content="FREE javascript gantt - jsGantt Improved HTML, CSS and AJAX only">
	<meta name="keywords" content="jsgantt-improved free javascript gantt-chart html css ajax">
	<meta name="viewport" content="width=device-width,initial-scale=1">

  <!-- External resources -->
	<!-- jQuery + Ajax [required by Bootstrap] -->
	  <script src="https://code.jquery.com/jquery-3.1.1.slim.min.js" integrity="sha384-A7FZj7v+d/sdmMqp/nOQwliLvUsJfDHW+k9Omg/a/EheAdgtzNs3hpfag6Ed950n" crossorigin="anonymous"></script>
	  <script src="https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.0/js/tether.min.js" integrity="sha384-DztdAPBWPRXSA/3eYEEUWrWCy7G5KFbe8fFjk5JAIxUYHKkDx6Qin1DkWx51bBrb" crossorigin="anonymous"></script>
	  <!-- Required by smooth scrolling -->
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
	<!-- Bootstrap v4.0.0 Alpha -->
	  <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rwoIResjU2yc3z8GV/NPeZWAv56rSmLldC3R/AZzGRnGxQQKnKkoFVhFQhNUwEyJ" crossorigin="anonymous" />
	  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/js/bootstrap.min.js" integrity="sha384-vBWWzlZJ8ea9aCX4pEW3rVHjgjt7zpkNpZk+02D9phzyeVkE+jo0ieGizqPLForn" crossorigin="anonymous"></script>
	<!-- Font Awesome -->
	  <script src="https://use.fontawesome.com/78d1e57168.js"></script>
	<!-- Google's Code Prettify -->
	  <script src="https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js?lang=css&amp;skin=sunburst"></script>
	<!-- Google Fonts -->
	  <link href="https://fonts.googleapis.com/css?family=Cookie|Satisfy|Kelly+Slab|Overlock" rel="stylesheet">

  <!-- Internal resources -->
	<!-- Webpage -->
	  <link rel="stylesheet" type="text/css" href="/groupware/resources/css/groupware/jsgantt.main.css<%=resourceVersion%>" />
	  <script src="/groupware/resources/script/user/jsgantt.main.js<%=resourceVersion%>" type="text/javascript"></script>
	<!-- jsGanttImproved App -->
	  <link rel="stylesheet" type="text/css" href="/groupware/resources/css/groupware/jsgantt.css<%=resourceVersion%>" />
	  <script src="/covicore/resources/script/axisj/AXJ.min.js<%=resourceVersion%>" type="text/javascript"></script>
	  <script src="/covicore/resources/script/Controls/Common.js<%=resourceVersion%>" type="text/javascript"></script>
	  <script src="/covicore/resources/script/Controls/CommonControls.js<%=resourceVersion%>" type="text/javascript"></script>
	  <script src="/groupware/resources/script/user/jsgantt.js<%=resourceVersion%>" type="text/javascript"></script>
</head>
<body>
	<div id="embedded-Gantt1"></div>
	
	<script type="text/javascript">
		var g = new JSGantt.GanttChart(document.getElementById('embedded-Gantt1'), 'week');
		var key = parent.$("#txtProjectCode").val();
		var lang = parent.lang;
		if (g.getDivId() != null) {
			if(parent.location.href.indexOf("tf_TFProgressGantt.do")>-1){
				//프로젝트룸의 경우 폭이 좁아서 단위를 높임
				g = new JSGantt.GanttChart(document.getElementById('embedded-Gantt1'), 'month');
			}
			g.setCaptionType('Complete');  // Set to Show Caption (None,Caption,Resource,Duration,Complete)
			g.setQuarterColWidth(36);
			g.setDateTaskDisplayFormat('yyyy month dd'); // Shown in tool tip box
			g.setDayMajorDateDisplayFormat('yyyy month') // Set format to display dates in the "Major" header of the "Day" view
			g.setWeekMinorDateDisplayFormat('mon/dd') // Set format to display dates in the "Minor" header of the "Week" view
			g.setShowTaskInfoLink(1); // Show link in tool tip (0/1)
			g.setShowEndWeekDate(0); // Show/Hide the date for the last day of the week in header for daily view (1/0)
			g.setUseSingleCell(10000); // Set the threshold at which we will only use one cell per table row (0 disables).  Helps with rendering performance for large charts.
			g.setFormatArr('Day', 'Week', 'Month', 'Quarter'); // Even with setUseSingleCell using Hour format on such a large chart can cause issues in some browsers
			g.setLang(lang);
			g.setRowHeight(60);
			g.setDateTaskTableDisplayFormat('yyyy-mm-dd');
			
			$.ajax({
				url : "/groupware/biztask/getProjectGanttList.do",
				data:{
					"ProjectCode": key
				},
				type:"post",
				success:function(res){
					if(res.list.length > 0) {
						var taskcolor = "";
						var taskGroup = "";
						var taskmember = "";
						var taskmember2 = "";
						$(res.list).each(function(i, item){
							if(item.SubCnt && item.SubCnt != "0"){
								taskGroup = 1; //taskcolor = "ggroupblack";
							}else {
								taskGroup = 0;
							}
							switch(item.State){
							case "Waiting": taskcolor = "gtaskyellow"; break;
							case "Process": taskcolor = "gtaskgreen"; break;
							case "Complete": taskcolor = "gtaskblue"; break;
							}
							if( item.TaskStartDate == item.TaskEndDate){
								//taskcolor ="gmilestone";
							}
							taskmember = MemberDisplay(item.AT_ID,res.memberlist);
							taskmember2 = MemberDisplay(item.AT_ID,res.memberlist,"Y");
							// Parameter (pID, pName, pStart, pEnd, pStyle, pLink, pMile, pRes, pComp, pGroup, pParent, pOpen, pDepend, pCaption, pNotes, pGantt)
							g.AddTaskItem(new JSGantt.TaskItem(item.AT_ID, item.ATName, item.StartDate, item.EndDate, taskcolor, '', 0, taskmember, taskmember2, item.Progress, taskGroup, item.MemberOf, 1, '', '', '', g));
							//g.AddTaskItem(new JSGantt.TaskItem(item.TaskIDX, item.TaskName, item.TaskStartDate, item.TaskEndDate, taskcolor, '', 0, item.MemName, item.TaskPercent, taskGroup, item.ParentTaskCode, 1, '', '', '', g));
						});
						g.Draw();
						
						// 테이블 높이 맞춤
						var ganttListTr = $("#embedded-Gantt1glistbody tr");
						var ganttChartTr = $("#embedded-Gantt1gchartbody tr");
						
						$.each(ganttListTr, function(i, obj) {
							var height = $(obj).height();
							$("#embedded-Gantt1gchartbody tr:eq(" + i + ")").height(height);
						}) ;
						
						// 오늘 날짜 표시선 맞춤
						$("#embedded-Gantt1line1").height($("#embedded-Gantt1chartTable").height());
					}
					else {
						var nomessage = Common.getDic("msg_NoDataList"); //조회할 목록이 없습니다
						document.getElementById('embedded-Gantt1').innerHTML = "<div style='text-align:center;color:#9a9a9a;font-size:13px;'><br><br>"+nomessage+"</div>";
					}
				}
			});
		} else {
			alert("Error, unable to create Gantt Chart");
		}
		
		function MemberDisplay(pAT_ID, Objmemberlist, isShort){
			var returnText="";
			var lActivitymemberList = Objmemberlist.filter(function(object){ return object["AT_ID"]=== pAT_ID});
			
			//주 수행자 외 n명 표기
			if(isShort == "Y"){
				var owner = CFN_GetDicInfo(lActivitymemberList[0].MultiDisplayName,lang);
				
				if(lActivitymemberList.length > 1){
					var performerCnt = lActivitymemberList.length - 1;
					returnText = String.format(Common.getDic('msg_BesidesCount'), owner, performerCnt);
				}else{
					returnText = owner;
				}
			}else{
				$(lActivitymemberList).each(function(idx,obj){
					returnText += (returnText==""?"":",")+CFN_GetDicInfo(obj.MultiDisplayName,lang);
				});
			}
			
			return returnText;
		}
	</script>
</body>
</html>