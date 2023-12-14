<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv='cache-control' content='no-cache'> 
<meta http-equiv='expires' content='0'> 
<meta http-equiv='pragma' content='no-cache'>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
	td{
		border: 1px solid #c3d7df;
	}
</style>
</head>
<body>
<div style="padding: 10px;">
	
	<!-- 상단 필터 및 메뉴 -->
	<div id="topitembar02" class="bodysearch_Type01">
		<div style="display:inline-block;">
			<span style="margin-left:10px;">
				<input type="text" id="workName">
			</span>
			
			<button type="button" id="btnSearch" class="AXButton" onclick="initContent('${selDevID}');"><spring:message code="Cache.btn_search"></spring:message></button>
		</div>
	</div>
	
	<div style='width:100%; min-height:70px; margin-bottom : 10px;'>
		<div>
			<table style="width:100%; border-color:#c3d7df;" cellpadding="0" cellspacing="0" id="tbWork">
				<thead>
					<tr style='height:30px; text-align:center; font-weight:bold; font-size:12px; background-color : #f1f6f9;'>
						<td width="50">코드</td>
						<td width="250">업무</td>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div>
	</div>
	
	<br />
	
</div>
<script>

window.onload = initContent('${selDevID}');

$("#workName").keypress(function (e) {
    if (e.keyCode == 13) initContent('${selDevID}');
});

//업무검색
function initContent(division) {
	if(division != "") {
		
		var ssWorkJob = ''; 
		var ssWorkType = '';
		
		try {
			ssWorkJob = $.parseJSON(window.sessionStorage.getItem('workJob_' + division));
			ssWorkType = $.parseJSON(window.sessionStorage.getItem('workType_' + division));
		}catch(e){coviCmn.traceLog(e);}
	
		if(typeof ssWorkJob == 'object' && ssWorkJob !== null) {
			$("#tbWork tbody").empty();
			$.each(ssWorkJob, function(i, d) {
				
				if($("#workName").val() != ""){
					let str = $("#workName").val().toUpperCase();
					let jobName = d.JobName.toUpperCase();
					
					if(jobName.includes(str)){
						$("#tbWork tbody")
							.append('<tr onclick="fn_select(' + (i + 1) + ');" style="height:30px; font-size:12px; cursor:pointer;" onmouseover="this.style.color=\'#2f71ba\';" onmouseout="this.style.color=\'#111111\';">'
							+ '	<td align="center">' + d.JobID + '</td>'
							+ '	<td align="left" >&nbsp;&nbsp;' + d.JobName + '</td>'
							+ '</tr>');
					}
				}else{
					$("#tbWork tbody")
					.append('<tr onclick="fn_select(' + (i + 1) + ');" style="height:30px; text-align:left; font-size:12px; cursor:pointer;" onmouseover="this.style.color=\'#2f71ba\';" onmouseout="this.style.color=\'#111111\';">'
					+ '	<td align="center">' + d.JobID + '</td>'
					+ '	<td align="left">&nbsp;&nbsp;' + d.JobName + '</td>'
					+ '</tr>');
				}
				
			});
		}
		
	}
}

function fn_select(i){
	parent.workSelect("${num}", i);
	parent.Common.close('WorkSearchPop');
}

	
</script>
</body>
</html>