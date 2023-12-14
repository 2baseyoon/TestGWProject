<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.covision.groupware.attend.user.util.AttendUtils"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="_printDN" value="${printDN}"/>
<!doctype html>
<html lang="ko">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
 <style type='text/css'>
     @media print {
         .noprint {
             visibility: hidden;
         }
     }
      @page { size: A4 landscape; margin:0; } 
 </style>
</head>
<body>	
	<div class="layer_divpop" style="width:100%; left:0; top:0; z-index:104; height:100%;">
		<div class="ATMgt_popup_wrap">
			<div class="ATMgt_popup_title_box">
				<p class="ATMgt_popup_title"><spring:message code='Cache.lbl_WeeklyMonthlyReport'/></p> <!-- 근태주보/월보 -->
				<div class="ATMgt_btn noprint">
					<a href="#" class="btnTypeDefault btnPrint2"><spring:message code='Cache.lbl_Print'/></a> <!-- 인쇄 -->
					<a href="#" class="btnTypeDefault btnExcel"><spring:message code='Cache.btn_SaveToExcel'/></a> <!-- 엑셀저장 -->
				</div>
			</div>
			<div class="ChkTitle">
				<strong><spring:message code='Cache.lbl_Postion'/> : ${DeptName}</strong> <!-- 소속 -->
				<strong><spring:message code='Cache.lbl_PersonNo'/>/<spring:message code='Cache.lbl_hr_name'/> : ${UserCode}/${UserName}</strong> <!-- 사번/성명 -->
				<strong><spring:message code='Cache.lbl_att_work'/><spring:message code='Cache.lbl_Period'/> : ${StartDate } ~ ${EndDate}</strong> <!-- 근무기간 -->
				<span><input type="checkbox" id="ckb_daynight" checked disabled/> <spring:message code='Cache.lbl_DayNightMarking'/></span> <!-- 주야표기 -->
			</div>
			<table class="ChkTable" cellpadding="0" cellspacing="0" id="tblDetail">
				<thead>
					<tr>
						<th><spring:message code='Cache.lbl_apv_date2'/></th> <!-- 일자 -->
						<th><spring:message code='Cache.lbl_ADay'/></th> <!-- 요일 -->
						<th>Cal</th>
						<th><spring:message code='Cache.lbl_apv_attendance'/></th> <!-- 근태 -->
						<th width="140"><spring:message code='Cache.lbl_att_work'/><spring:message code='Cache.lbl_SchDivision'/></th> <!-- 근무구분 -->
						<th><spring:message code='Cache.lbl_attendance'/></th> <!-- 출근 -->
						<th class="bd"><spring:message code='Cache.lbl_leave'/></th> <!-- 퇴근 -->
						<th <c:if test="${_printDN ne 'true'}">class="bd"</c:if> width="60"><spring:message code='Cache.lbl_BasicWork'/></th> <!-- 기본근무 -->
						<c:if test="${_printDN eq 'true'}">
							<th width="60"><spring:message code='Cache.lbl_Weekly'/></th> <!-- 주간 -->
							<th class="bd" width="60"><spring:message code='Cache.lbl_night'/></th> <!-- 야간 -->
						</c:if>
						<th <c:if test="${_printDN ne 'true'}">class="bd"</c:if> width="60"><spring:message code='Cache.lbl_att_overtime_work'/></th> <!-- 연장근무 -->
						<c:if test="${_printDN eq 'true'}">
							<th width="60"><spring:message code='Cache.lbl_Weekly'/></th> <!-- 주간 -->
							<th class="bd" width="60"><spring:message code='Cache.lbl_night'/></th> <!-- 야간 -->
						</c:if>
						<th <c:if test="${_printDN ne 'true'}">class="bd"</c:if> width="60"><spring:message code='Cache.lbl_att_holiday_work'/></th> <!-- 휴일근무 -->
						<c:if test="${_printDN eq 'true'}">
							<th width="60"><spring:message code='Cache.lbl_Weekly'/></th> <!-- 주간 -->
							<th class="bd" width="60"><spring:message code='Cache.lbl_night'/></th> <!-- 야간 -->
						</c:if>
						<th class="bd"><spring:message code='Cache.lbl_att_beingLate'/></th> <!-- 지각 -->
						<th class="bd"><spring:message code='Cache.lbl_att_leaveErly'/></th> <!-- 조퇴 -->
					</tr>
				</thead>
				<tbody>
					<c:set var="week" value="1"/>
					<c:set var="attAcT" value="0"/>
					<c:set var="extenAcT" value="0"/>
					<c:set var="holiAcT" value="0"/>
					<c:set var="lateMinT" value="0"/>
					<c:set var="earlyMinT" value="0"/>

					<c:set var="attAcW" value="0"/>
					<c:set var="extenAcW" value="0"/>
					<c:set var="holiAcW" value="0"/>
					<c:set var="lateMinW" value="0"/>
					<c:set var="earlyMinW" value="0"/>
					<c:forEach items="${data}" var="list" varStatus="status">
						<c:if test="${week ne list.week}">
							<tr class='bg'>
								<td><spring:message code='Cache.lbl_att_week_${week}'/></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td class="bd"></td>
								<td width="60" <c:if test="${_printDN ne 'true'}">class="bd"</c:if>>
									<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("attAcW")),"H")%>
								</td>
								<c:if test="${_printDN eq 'true'}">
								<td width="60">
									<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("attAcDW")),"H")%>
								</td>
								<td width="60" class="bd">
									<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("attAcNW")),"H")%>
								</td>
								</c:if>
								<td width="60" <c:if test="${_printDN ne 'true'}">class="bd"</c:if>>
									<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("extenAcW")),"H")%>
								</td>
								<c:if test="${_printDN eq 'true'}">
									<td width="60">
										<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("extenAcDW")),"H")%>
									</td>
									<td width="60" class="bd">
										<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("extenAcNW")),"H")%>
									</td>
								</c:if>
								<td width="60" <c:if test="${_printDN ne 'true'}">class="bd"</c:if>>
									<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("holiAcW")),"H")%>
								</td>
								<c:if test="${_printDN eq 'true'}">
									<td width="60">
										<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("holiAcDW")),"H")%>
									</td>
									<td width="60" class="bd">
										<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("holiAcNW")),"H")%>
									</td>
								</c:if>
								<td class="bd"><%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("lateMinW")),"H")%></td>
								<td class="bd"><%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("earlyMinW")),"H")%></td>
							</tr>
							<c:set var="attAcT" value="${attAcT+attAcW}"/>
							<c:set var="attAcDT" value="${attAcDT+attAcDW}"/>
							<c:set var="attAcNT" value="${attAcNT+attAcNW}"/>
							<c:set var="extenAcT" value="${extenAcT+extenAcW}"/>
							<c:set var="extenAcDT" value="${extenAcDT+extenAcDW}"/>
							<c:set var="extenAcNT" value="${extenAcNT+extenAcNW}"/>
							<c:set var="holiAcT" value="${holiAcT+holiAcW}"/>
							<c:set var="holiAcDT" value="${holiAcDT+holiAcDW}"/>
							<c:set var="holiAcNT" value="${holiAcNT+holiAcNW}"/>
							<c:set var="lateMinT" value="${lateMinT+lateMinW}"/>
							<c:set var="earlyMinT" value="${earlyMinT+earlyMinW}"/>

							<c:set var="attAcW" value="0"/>
							<c:set var="attAcDW" value="0"/>
							<c:set var="attAcNW" value="0"/>
							<c:set var="extenAcW" value="0"/>
							<c:set var="extenAcDW" value="0"/>
							<c:set var="extenAcNW" value="0"/>
							<c:set var="holiAcW" value="0"/>
							<c:set var="holiAcDW" value="0"/>
							<c:set var="holiAcNW" value="0"/>
							<c:set var="lateMinW" value="0"/>
							<c:set var="earlyMinW" value="0"/>
						</c:if>
						<c:set var="week" value="${list.week}"/>
						<c:set var="attAc" value="${list.AttAC}"/>
						<c:set var="attAcD" value="${list.AttAcD}"/>
						<c:set var="attAcN" value="${list.AttAcN}"/>
						<c:set var="extenAc" value="${list.ExtenAC}"/>
						<c:set var="extenAcD" value="${list.ExtenAcD}"/>
						<c:set var="extenAcN" value="${list.ExtenAcN}"/>
						<c:set var="holiAc" value="${list.HoliAC}"/>
						<c:set var="holiAcD" value="${list.HoliAcD}"/>
						<c:set var="holiAcN" value="${list.HoliAcN}"/>
						<c:set var="lateMin" value="${list.LateMin}"/>
						<c:set var="earlyMin" value="${list.EarlyMin}"/>

						<c:set var="attAcW" value="${attAcW+attAc}"/>
						<c:set var="attAcDW" value="${attAcDW+attAcD}"/>
						<c:set var="attAcNW" value="${attAcNW+attAcN}"/>
						<c:set var="extenAcW" value="${extenAcW+extenAc}"/>
						<c:set var="extenAcDW" value="${extenAcDW+extenAcD}"/>
						<c:set var="extenAcNW" value="${extenAcNW+extenAcN}"/>
						<c:set var="holiAcW" value="${holiAcW+holiAc}"/>
						<c:set var="holiAcDW" value="${holiAcDW+holiAcD}"/>
						<c:set var="holiAcNW" value="${holiAcNW+holiAcN}"/>
						<c:set var="lateMinW" value="${lateMinW+lateMin}"/>
						<c:set var="earlyMinW" value="${earlyMinW+earlyMin}"/>
						<tr>
							<td>${list.dayList}</td>
							<td><spring:message code='Cache.lbl_att_sch_${list.weekn}'/></td>
							<td>${list.HolidayName}</td>
							<td>${list.VacFlagName}</td>
							<td width="140">${list.SchName}</td>
							<td>${list.AttStartTime}</td>
							<td class="bd">${list.AttEndTime}</td>
							<td width="60" <c:if test="${_printDN ne 'true'}">class="bd"</c:if>>
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("attAc")),"H")%>
							</td>
							<c:if test="${_printDN eq 'true'}">
							<td width="60">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("attAcD")),"H")%>
							</td>
							<td width="60" class="bd">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("attAcN")),"H")%>
							</td>
							</c:if>
							<td width="60" <c:if test="${_printDN ne 'true'}">class="bd"</c:if>>
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("extenAc")),"H")%>
							</td>
							<c:if test="${_printDN eq 'true'}">
								<td width="60">
									<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("extenAcD")),"H")%>
								</td>
								<td width="60" class="bd">
									<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("extenAcN")),"H")%>
								</td>
							</c:if>
							<td width="60" <c:if test="${_printDN ne 'true'}">class="bd"</c:if>>
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("holiAc")),"H")%>
							</td>
							<c:if test="${_printDN eq 'true'}">
								<td width="60">
									<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("holiAcD")),"H")%>
								</td>
								<td width="60" class="bd">
									<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("holiAcN")),"H")%>
								</td>
							</c:if>
							<td class="bd"><%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("lateMin")),"H")%></td>
							<td class="bd"><%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("earlyMin")),"H")%></td>
						</tr>
					</c:forEach>
					
					<tr class="bg bg_f">
						<td><spring:message code='Cache.lbl_att_week_${week}'/></td>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td class="bd"></td>
						<td width="60" <c:if test="${_printDN ne 'true'}">class="bd"</c:if>>
							<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("attAcW")),"H")%>
						</td>
						<c:if test="${_printDN eq 'true'}">
							<td width="60">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("attAcDW")),"hh")%>
							</td>
							<td width="60" class="bd">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("attAcNW")),"hh")%>
							</td>
						</c:if>
						<td width="60" <c:if test="${_printDN ne 'true'}">class="bd"</c:if>>
							<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("extenAcW")),"H")%>
						</td>
						<c:if test="${_printDN eq 'true'}">
							<td width="60">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("extenAcDW")),"hh")%>
							</td>
							<td width="60" class="bd">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("extenAcNW")),"hh")%>
							</td>
						</c:if>
						<td width="60" <c:if test="${_printDN ne 'true'}">class="bd"</c:if>>
							<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("holiAcW")),"H")%>
						</td>
						<c:if test="${_printDN eq 'true'}">
							<td width="60">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("holiAcDW")),"hh")%>
							</td>
							<td width="60" class="bd">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("holiAcNW")),"hh")%>
							</td>
						</c:if>
						<td class="bd"><%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("lateMinW")),"H")%></td>
						<td class="bd"><%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("earlyMinW")),"H")%></td>
					</tr>	
				</tbody>	
				<tfoot>
					<c:set var="attAcT" value="${attAcT+attAcW}"/>
					<c:set var="extenAcT" value="${extenAcT+extenAcW}"/>
					<c:set var="holiAcT" value="${holiAcT+holiAcW}"/>
					<c:set var="lateMinT" value="${lateMinT+lateMinW}"/>
					<c:set var="earlyMinT" value="${earlyMinT+earlyMinW}"/>
					<tr class="bg">
						<td><strong><spring:message code='Cache.lbl_apv_Section'/></strong></td> <!-- 계 -->
						<td></td>
						<td></td>
						<td></td>
						<td width="140"></td>
						<td></td>
						<td class="bd"></td>
						<td width="60" <c:if test="${_printDN ne 'true'}">class="bd"</c:if>>
							<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("attAcT")),"hh")%>
						</td>
						<c:if test="${_printDN eq 'true'}">
							<td width="60">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("attAcDT")),"hh")%>
							</td>
							<td width="60" class="bd">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("attAcNT")),"hh")%>
							</td>
						</c:if>
						<td width="60" <c:if test="${_printDN ne 'true'}">class="bd"</c:if>>
							<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("extenAcT")),"hh")%>
						</td>
						<c:if test="${_printDN eq 'true'}">
							<td width="60">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("extenAcDT")),"hh")%>
							</td>
							<td width="60" class="bd">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("extenAcNT")),"hh")%>
							</td>
						</c:if>
						<td width="60" <c:if test="${_printDN ne 'true'}">class="bd"</c:if>>
							<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("holiAcT")),"hh")%>
						</td>
						<c:if test="${_printDN eq 'true'}">
							<td width="60">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("holiAcDT")),"hh")%>
							</td>
							<td width="60" class="bd">
								<%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("holiAcNT")),"hh")%>
							</td>
						</c:if>
						<td class="bd"><%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("lateMinT")),"H")%></td>
						<td class="bd"><%=AttendUtils.convertSecToStr(String.valueOf(pageContext.getAttribute("earlyMinT")),"H")%></td>
					</tr>
				</tfoot>
			</table>
		</div>
	</div>
	<!-- 근태주보/월보 팝업 끝 -->
<script>
var _printDN = "${_printDN}";
var DeptName = "${DeptName}";
var UserName = "${UserName}";
var StartDate = "${StartDate}";
var EndDate = "${EndDate}";
var UserCode = "${UserCode}";
// 인쇄
$(document).ready(function(){
	$(".btnPrint2").click(function(){
	    try {
	        window.print();
	    }
	    catch (e) {
	        alert(e.description);
	    }
	});
	$(".btnExcel").click(function(){
		$('#download_iframe').remove();
		
		var url = "/groupware/attendPortal/excelPortalDetail.do";
		var aJsonArray = new Array();

		if(_printDN=="true"){
			$("#tblDetail tbody").find('tr').each(function(col, idx) {
				var aData ="";
				for (var j=0; j < 18; j++){
					if (j>0) aData += " !!";
					aData +=$(this).find("td:eq("+j+")").text();
				}
				aJsonArray.push(aData);
			});

			var aData ="";
			for (var j=0; j < 18; j++){
				if (j>0) aData += " !!";
				aData +=$("#tblDetail tfoot").find('tr').find("td:eq("+j+")").text();
			}
		}else{
			$("#tblDetail tbody").find('tr').each(function(col, idx) {
				var aData ="";
				for (var j=0; j < 12; j++){
					if (j>0) aData += " !!";
					aData +=$(this).find("td:eq("+j+")").text();
				}
				aJsonArray.push(aData);
			});

			var aData ="";
			for (var j=0; j < 12; j++){
				if (j>0) aData += " !!";
				aData +=$("#tblDetail tfoot").find('tr').find("td:eq("+j+")").text();
			}
		}
		aJsonArray.push(aData);

		var params = {"dataList" : aJsonArray, "printDN" : _printDN, "DeptName":DeptName,
						"UserName":UserName, "StartDate":StartDate, "EndDate":EndDate, "UserCode":UserCode}
	
/*		var $iframe, iframe_doc, iframe_html;

	    if (($iframe = $('#download_iframe')).length === 0) {
	        $iframe = $("<iframe id='download_iframe' style='display: none1' src='about:blank'></iframe>").appendTo("body");
	    }
	    iframe_doc = $iframe[0].contentWindow || $iframe[0].contentDocument;
	    if (iframe_doc.document) {
	        iframe_doc = iframe_doc.document;
	    }

	    iframe_html = "<html><head></head><body><form method='POST' action='" + url +"' content-type='application/json; charset=utf-8' >"
        iframe_html += "<input type='hidden1' name='data' value='"+JSON.stringify(params)+"'>";
	    iframe_html +="</form></body></html>";

	    iframe_doc.open();
	    iframe_doc.write(iframe_html);
	    $(iframe_doc).find('form').submit();
	    alert(1)
	    */
		/*$.ajax({
		    url: "/groupware/attendPortal/excelPortalDetail.do",
		    type: "POST",
			contentType:'application/json; charset=utf-8',
			dataType   : 'json',
		    data: JSON.stringify(params),
		    success: function(data, status, xhr) {
		        var contentType = 'application/vnd.ms-Excel';

		        var filename = "";
		        var disposition = xhr.getResponseHeader('Content-Disposition');
		        if (disposition && disposition.indexOf('attachment') !== -1) {
		            var filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/;
		            var matches = filenameRegex.exec(disposition);
		            if (matches != null && matches[1]) filename = matches[1].replace(/['"]/g, '');
		        }

		        try {
		            var blob = new Blob([data], { type: contentType });

		            var downloadUrl = URL.createObjectURL(blob);
		            var a = document.createElement("a");
		            a.href = downloadUrl;
		            a.download = filename;
		            document.body.appendChild(a);
		            a.click();

		        } catch (exc) {
		        	coviCmn.traceLog("Save Blob method failed with the following exception.");
		        	coviCmn.traceLog(exc);
		        }
		    }
		});
	    */
		ajax_download(url, params); 	// 엑셀 다운로드 post 요청*/	
		
	});

	//주야 표기 모드
	if(_printDN == "true"){
		$("#ckb_daynight").attr("checked", true);
	}else{
		$("#ckb_daynight").attr("checked", false);
	}
});
</script>