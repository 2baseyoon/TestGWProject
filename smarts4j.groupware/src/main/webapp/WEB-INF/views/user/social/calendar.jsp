<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<div id="Calendar" style="height:600px;">
	<i class="fa fa-desktop" aria-hidden="true"></i> PC
		<br/><br/>
		<h1>Date Picker</h1>
		
		<div id="sel_datepicker" style="display:inline"></div>
	 	<div id="calendarPicker" style="display:inline"></div>
	 	
	 	
	 	공통option설명<br>
	 	
		 	coviCtrl.renderDateSelect(initInfos, selectInfos);<br>
		 	
		 		var initInfos = <br>
				{<br>
						target : 'sel_datepicker',  picker 출력위치<br>
						width : ''                  기본값은 100<br>
				};<br>
				var selectInfos = <br>
				{<br>
						H : "1",        시간 선택<br>
						W : "1,2,3,4",  주 선택<br>
						M : "1,2",	    달 선택<br>
						Y : "1"	 	    년도 선택<br>
				} ;<br>
		 	
		 	
	 	
	 	
		 	coviCtrl.makeCalendarPicker(initInfos);<br>
		 	
		 		var initInfos = <br>
				{<br>
						target: "calendarPicker",    출력될 target Id값<br>
						useCalendarPicker : 'Y',<br>
						useTimePicker : 'Y'<br>
				};<br>
		 	
		 	
	 	
	 	
	</div>
<!-- 컨텐츠 End -->
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.control.js<%=resourceVersion%>"></script>
<link rel="stylesheet" type="text/css" href="/covicore/resources/css/covision.control.css<%=resourceVersion%>" />
<script type="text/javascript">
setCalendar();
function setCalendar(){
	
	target = 'sel_datepicker'; //picker 출력위치

	var timeInfos = {
		width : '', //기본값은 100
		H : "1", //시간 선택
		W : "1,2,3,4", //주 선택
		M : "1,2", //달 선택
		Y : "1" //년도 선택
	};

	coviCtrl.renderDateSelect(target, timeInfos);

	target = 'calendarPicker'; //출력될 target Id값
	var initInfos = {
		useCalendarPicker : 'Y',
		useTimePicker : 'Y'
	};

	coviCtrl.makeCalendarPicker(target, initInfos);
}
	
</script>
