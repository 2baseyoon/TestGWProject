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
	<div id="attendRequestList" style="padding: 13px 24px 24px;"></div>
</body>

<script>
	var CLSYS = CFN_GetQueryString("CLSYS");
	var CLBIZ = CFN_GetQueryString("CLBIZ");
	
	var AttendRequestGrid = new coviGrid();
	
	$(document).ready(function(){
		initAttendRequest();
	});
	
	function initAttendRequest(){
		var headerData = [
			{key:'AttendantID', label:'AttendantID', width:'30', align:'center', display: false},
			{key:'EventID', label:'EventID', width:'30', align:'center', display: false},
			{key:'FolderID', label:'FolderID', width:'30', align:'center', display: false},
			{key:'DateID', label:'DateID', width:'30', align:'center', display: false},
			{key:'DisplayName', label: Common.getDic('lbl_Requester'), width:'30', align:'center'},
			{key:'Subject', label: Common.getDic('lbl_subject'), width:'100', align:'center', formatter: function(){
				return '<a onclick="javascript:detailViewSchedulePopup(\''+this.item.EventID+'\',\''+this.item.DateID+'\',\''+this.item.FolderID+'\',\''+this.item.RepeatID+'\',\''+this.item.RepeatType+'\');">'+ this.item.Subject +'</a>'
			}}
		];

		AttendRequestGrid.setGridHeader(headerData);

		var configObj = {
			targetID: "attendRequestList",
			height:"auto",	
			paging: false
		};
		AttendRequestGrid.setGridConfig(configObj);

		selectAttendRequest();
	}
	
	function selectAttendRequest() {
		AttendRequestGrid.bindGrid({
			ajaxUrl : "/groupware/schedule/selectAttendRequest.do"
		});
	}
	
	function detailViewSchedulePopup(pEventID, pDateID, pFolderID,pRepeatID, pRepeatType){
		parent.scheduleUser.goDetailViewPage('AttendRequest',pEventID,pDateID,pRepeatID,(pRepeatType != '') ? 'Y' : '',pFolderID);
	}
</script>