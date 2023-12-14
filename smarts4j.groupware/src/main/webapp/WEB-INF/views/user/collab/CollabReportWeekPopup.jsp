<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" %>
<%@ page import="egovframework.coviframework.util.ComUtils" %>	
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="el" uri="/WEB-INF/tlds/el-functons.tld"%>

<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/collab_util.js"></script>
<body>
<style>
.btn_del { position:absolute; top:-4px; right:-7px; display:block; width:14px; height:14px; background:#566472 url(/HtmlSite/smarts4j_n/eaccounting/resources/images/btn_filedel.png) no-repeat 50% 50%; background-size:6px; border-radius:50%; }
.tagview li{height:30px}
.tagview div{text-align:center}
.prevImg{max-width:200px}
.CollabTable { width:100%; table-layout:fixed;/*border-top:1px solid #969696; */}
.CollabTable th {height:33px; border-bottom:1px solid #ACAEB2; font-size:13px; font-family:맑은 고딕, Malgun Gothic,sans-serif, dotum,'돋움',Apple-Gothic;font-color:#5E5E5E}
.CollabTable td{height:40px;border-bottom:1px solid #ededed;}

</style>	
<div class="collabo_popup_wrap">
	<div class="c_titBox">
		<h3 class="cycleTitle">${prjName} [${reporterName}] 
			 ${fn:substring(startDate,0,4)}.${fn:substring(startDate,4,6)}.${fn:substring(startDate,6,8)}
			 ~
			 ${fn:substring(endDate,0,4)}.${fn:substring(endDate,4,6)}.${fn:substring(endDate,6,8)}
			 주간보고</h3>
	</div>
	<div class="collabo_table_wrap mb40">
		<table cellpadding="0" cellspacing="0" class="CollabTable" id="taskDayTableContents">
			<colgroup>
				<col width="150" style="" >
				<col width="150" style="" >
				<col width="100%" style="">
				<col width="70" style="">
				<col width="70" style="">
				<col width="90" style="">
			</colgroup>
			<thead>
			<tr>
				<th><spring:message code='Cache.lbl_scope' /></th>
				<th><spring:message code='Cache.lbl_sectionName' /></th>
				<th><spring:message code='Cache.lbl_prj_workName' /></th>
				<th><spring:message code='Cache.lbl_ProgressRate' /></th>
				<th>처리시간</th>
				<th><spring:message code='Cache.lbl_Remark' /></th>
			</tr>
			</thead>
			
			<tbody>
				<c:forEach items="${dayList}" var="list" varStatus="status">
					<tr>
						<td>${fn:substring(list.ReportDate,0,4)}.${fn:substring(list.ReportDate,4,6)}.${fn:substring(list.ReportDate,6,8)}</td>
						<td>${list.SectionName }</td>
						<td><a class="icoTaskPop" data-taskSeq="${list.TaskSeq}"><script>document.write(collabUtil.getTaskStatus({"DaySeq":"${list.DaySeq}","TaskStatus":"${list.TaskStatus}","TaskName":"${list.TaskName}" }))</script></a></td>
						<td>${list.ProgRate }</td>
						<td>${list.TaskTime }</td>
						<td>${list.Remark }</td>
					</tr>
				</c:forEach>
			</tbody>
		</table>
	</div>		
</div>
<script>
var collabReportPopup= {
		pageSize : 10,
    	objectInit : function (){
	   		this.addEvent();
        },
        addEvent:function(){
        	$(document).on('click','.icoTaskPop',function(){
				collabUtil.openTaskPopup('CollabReportSavePopup', 'openerID', $(this).data("taskseq"),  $(this).data("taskseq"));
			});
        }
}
$(document).ready(function(){
	collabReportPopup.objectInit();
});

</script>