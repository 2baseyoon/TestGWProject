<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<form id="form_APILogInfoPop" name="form_APILogInfoPop">
<div>
	<input type="hidden" id="SecID" name="SecID" />
	<input type="hidden" id="DomainID" name="DomainID" />
	<table class="AXFormTable">
		<tr style="height:36px;">
			<th style="width: 130px;">Path</th>
			<td colspan="3">
				<div id="URL" style="word-wrap: break-word;"></div>
			</td>
		</tr>
		<tr style="height:36px;">
			<th style="width: 130px;">Version</th>
			<td colspan="3">
				<div id="Version" style="word-wrap: break-word;"></div>
			</td>
		</tr>
		<tr style="height:36px;">
			<th style="width: 130px;"><spring:message code="Cache.lbl_State"/></th>
			<td colspan="3">
				<div id="State" style="word-wrap: break-word;"></div>
			</td>
		</tr>
		<tr style="height:36px;">
			<th style="width: 130px;"><spring:message code="Cache.lbl_reqTimestamp"/></th>
			<td colspan="3">
				<div id="ReqTime" style="word-wrap: break-word;"></div>
			</td>
		</tr>
		<tr style="height:36px;">
			<th style="width: 130px;"><spring:message code="Cache.lbl_resTimestamp"/></th>
			<td colspan="3">
				<div id="ResTime" style="word-wrap: break-word;"></div>
			</td>
		</tr>
		<tr style="height:36px;">
			<th style="width: 130px;"><spring:message code="Cache.lbl_elapsedTime_Total"/></th>
			<td colspan="3">
				<div id="ElapsedTTime" style="word-wrap: break-word;"></div>
			</td>
		</tr>
		<tr style="height:36px;">
			<th style="width: 130px;"><spring:message code="Cache.lbl_elapsedTime_App"/></th>
			<td colspan="3">
				<div id="ElapsedATime" style="word-wrap: break-word;"></div>
			</td>
		</tr>
		<tr style="height:36px;">
			<th style="width: 130px;"><spring:message code="Cache.lbl_reqToken"/></th>
			<td colspan="3">
				<div id="ReqToken" style="word-wrap: break-word;"></div>
			</td>
		</tr>
		<tr style="height:36px;">
			<th style="width: 130px;"><spring:message code="Cache.lbl_IP"/></th>
			<td colspan="3">
				<div id="IP" style="word-wrap: break-word;"></div>
			</td>
		</tr>
		<tr style="height:36px;">
			<th style="width: 130px;"><spring:message code="Cache.lbl_Payload"/></th>
			<td colspan="3">
				<div id="ReqBody" style="word-wrap: break-word;"></div>
			</td>
		</tr>
		<tr style="height:36px;">
			<th style="width: 130px;"><spring:message code="Cache.lbl_Message"/></th>
			<td colspan="3">
				<div id="Message" style="word-wrap: break-word;"></div>
			</td>
		</tr>
	</table>
	<div align="center" style="padding-top: 10px">
		<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"  class="AXButton" />
	</div>
</div>
</form>
<script type="text/javascript">
var LogID = coviCmn.isNull(CFN_GetQueryString("LogID"), "");
var lang = Common.getSession("lang");

init();

function init(){
	setLogData();
}

//정보 조회
function setLogData(){
	$.ajax({
		type:"POST",
		url : "/covicore/api/config/getRequestLogDetail.do",
		data : { "LogID" : LogID },
		success : function(data){
			if(data.status=='SUCCESS'){
				var info = data.data;
				// $("#LogID").val(LogID);
				$("#URL").html(info.URL);
				$("#Version").html(info.Version);
				$("#State").html(info.State);
				$("#ReqTime").html(info.ReqTime == null ? "N/A" : info.ReqTime);
				$("#ResTime").html(info.ResTime == null ? "N/A" : info.ResTime);
				$("#ElapsedTTime").html(info.ElapsedTTime == null ? "N/A" : info.ElapsedTTime + " ms");
				$("#ElapsedATime").html(info.ElapsedATime == null ? "N/A" : info.ElapsedATime + " ms");
				$("#ReqToken").html(info.ReqToken);
				$("#IP").html(info.IP);
				$("#ReqBody").html(info.ReqBody);
				$("#Message").html(info.Message);
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/covicore/api/config/getRequestLogDetail.do", response, status, error);
		}
	});
}

//레이어 팝업 닫기
function closeLayer(){
	Common.Close();
}
</script>