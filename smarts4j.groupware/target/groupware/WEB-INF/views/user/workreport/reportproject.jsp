<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div>
	<h3 class="con_tit_box">
		<span class="con_tit">프로젝트 투입 현황</span>
	</h3>

	<!-- 검색 바 -->
	<div style='margin-bottom : 10px;'>
		<button type="button" id="btnRefresh" class="AXButton" onclick="refresh()">새로고침</button>
		<button type="button" id="btnSaveToExcel" class="AXButton" onclick="excelDownload()">엑셀저장</button>
	</div>
	<div>
		<span style="margin-left:5px;">업무명 : </span><input type="text" id="txtJobName" class="W200" placeholder="업무명을 입력해주세요."/>
		<select id="selProjectFilter" onchange="drawTable(this)" class="W200" style="max-width:200px; margin-right:10px;appearance:auto;"></select>
		
		<label>팀명 : </label>
		<!-- MARK 권한 사용자에게만 조직도 버튼 바인딩 (차후 필요한 작업) -->
		<span style=''>
			<input type="text" class="AXInput W120" id="selTeamName" readonly data-code="" style='margin-right:5px; display:inline-block; width:120px;'></span>
			<input id="btnOrgMap" type="button" class="AXButton" value="<spring:message code='Cache.lbl_DeptOrgMap'/>"/>
		</span>
		
		<span style="margin-left : 10px;">프로젝트 기간</span> 
		<input type="text" id="startdate" style="width: 85px; padding:0px!important;"  class="AXInput" /> ~ 
		<input type="text" kind="twindate" date_startTargetID="startdate" date_separator="-" date_selecttype="m" id="enddate" style="width: 105px; padding:0px!important;"  class="AXInput"  />	
	</div>
	
	<div id="resultBoxWrap" style="margin-top : 10px; width: 100%;">
		<table id="tbStatistics" style='width:100%; border : 1px solid #c9c9c9;' border = "1" cellpadding="5" width="auto" >
			<tbody>
			</tbody>
		</table>
	</div>
	
	<div id="hidExceldownload" style="display:none">
		<iframe name="ifExcelDownload" src="" style="display:none;"></iframe>
	</div>
</div>
<script>

$("#txtJobName").keypress(function (e) {
    if (e.keyCode == 13) {
    	bindOption();
    }
});

var refresh = function() {
	$("#selTeamName").val("").attr("data-code", "");
	setData();
};

var bindOption = function() {
	var selPrj = $("#selProjectFilter");
	selPrj.empty();
	selPrj.append("<option value='' data-sym='' data-eym=''>업무 검색 결과</option>");
	selPrj.trigger('change');
	
	let str = $("#txtJobName").val().toUpperCase();
	if(str){
		$.getJSON("workreportgetmanageprj.do", {}, function(d) {
			var liProject = d.list;
			var selPrj = $("#selProjectFilter");
			selPrj.empty();
			selPrj.append("<option value='' data-sym='' data-eym=''>업무 검색 결과</option>");
			
			liProject.forEach(function(data) {
				var sym = data.StartDate.substr(0, 7);
				var eym = data.EndDate.substr(0, 7);
				
				var sHTML = "<option ";
				sHTML += "value='" + data.JobID + "' data-sym='" + sym + "' data-eym='" + eym + "'>";
				sHTML += data.JobName + "</option>";
				
				if(str && data.JobName.toUpperCase().includes(str)){
					selPrj.append(sHTML);
				}
			});
			
			selPrj.trigger('change');
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("workreportgetmanageprj.do", response, status, error);
		});
	}
};

var excelDownload = function(target) {
	var fileName = "";
	var excelData = encodeURIComponent($("#tbStatistics")[0].outerHTML);
	
	if($("#selProjectFilter").val() == ""){
		
		Common.Inform("프로젝트를 선택하여 주세요.");
		
	}
	else{
		var prjName = $("#selProjectFilter>option:selected").text();
		var currentDate = new Date();
		fileName = prjName+"_투입현황_" + currentDate.format("yyyyMMdd");
		
		if (!_ie){
			fileName = encodeURIComponent(fileName);
		}
		
		var formHtml = "<form name='form_excelDownload' method='POST' action='WorkReportUtilExcelView.do'></form>";
		$("#hidExceldownload").append(formHtml);
		$(document.form_excelDownload).append("<input type='hidden' name='fileName' value='" + fileName + "' />");
		$(document.form_excelDownload).append("<textarea name='excelData'>" + excelData + "</textarea>");
		
		document.form_excelDownload.target = "ifExcelDownload";
		document.form_excelDownload.submit();
		
		$(document.form_excelDownload).remove();
	}	
};

var setData = function(){
	
	var strJobID = $("#selProjectFilter").val();
	var strStartDate = $("#startdate").val();
	var strEndDate = $("#enddate").val();
	var strGRCode = $("#selTeamName").attr("data-code");
	
	$.getJSON("getStatisticsProject.do",{jobID : strJobID , startdate : strStartDate, enddate : strEndDate, grcode : strGRCode}, function(d){
		var tbl_body = "";
		var tbl_header = "";
		var mm = "";
		var list = d.list;
		var grade = "";
		var gubun = "";
		var deptName = "";
		var userName = "";
		var jobPositionName = "";
		var cnt = 0;
		var month = d.months;
		var months = month.split(";");
		var inputdate = "";
		var sumMM = "";
		var totalcnt = 7;
		
		var totalSum = 0; // MM 총 합계
		var montlySum = {}; // 월별 합계
		
		tbl_header += "<tr><td width='5%' style='background-color : #008080; text-align : center; height : 30px; line-height : 30px; color : white; font-weight:bold;'>등급</td>";
		tbl_header += "<td width='10%' style='background-color : #008080; text-align : center; height : 30px; line-height : 30px; color : white; font-weight:bold;'>팀명</td>";
		tbl_header += "<td width='5%' style='background-color : #008080; text-align : center; height : 30px; line-height : 30px; color : white; font-weight:bold;'>구분</td>";
		tbl_header += "<td width='15%' style='background-color : #008080; text-align : center; height : 30px; line-height : 30px; color : white; font-weight:bold;'>이름</td>";
		tbl_header += "<td width='10%' style='background-color : #008080; text-align : center; height : 30px; line-height : 30px; color : white; font-weight:bold;'>직위</td>";
		tbl_header += "<td width='10%' style='background-color : #008080; text-align : center; height : 30px; line-height : 30px; color : white; font-weight:bold;'>투입MM</td>";
		tbl_header += "<td width='20%' style='background-color : #008080; text-align : center; height : 30px; line-height : 30px; color : white; font-weight:bold;'>투입일</td>";

		$.each(months,function(){
			tbl_header += "<td style='background-color : #008080; text-align : center; height : 30px; line-height : 30px; color : white; font-weight:bold;'>" + months[cnt].substring(5,7) + "월</td>";
			
			// 초기화
			montlySum[months[cnt++]] = 0;
		});
		
		tbl_header += "</tr>";
		
		totalcnt = totalcnt + cnt;		
		
		cnt=0;
				
		if(list.length == 0 ){
			tbl_body += "<tr height='200px;' style='background-color:white; border:1px solid #c9c9c9;'><td colspan=" + totalcnt + ">";
			tbl_body += "<p style='text-align:center;'>표시할 내용이 없습니다.</p></td></tr>";
		}
		else{
			list.forEach(function(obj) {				
				tbl_body +="<tr>";
				
					switch(obj.GradeKind){
						case "S" : grade="특급"; break;
						case "H" : grade="고급"; break;
						case "M" : grade="중급"; break;
						case "B" : grade="초급2"; break;
						case "N" : grade="초급1"; break;
					}			
					if(obj.MemberType == "O"){
						gubun = "외주";
						deptName = "";
						jobPositionName = "";
					}
					else if(obj.MemberType = "R" ) {
						gubun = "정직";
						deptName = obj.DeptName;
						jobPositionName = obj.JobPositionName;
					}			
					userName = obj.UserName;
					inputdate = obj.InputDate;
					sumMM = parseFloat(obj.SUMMM).toFixed(2);
					
					tbl_body +="<td  style='padding : 10px; text-align:center;'>" + grade + "</td>";
					tbl_body +="<td  style='padding : 10px; text-align:center;'>" + deptName + "</td>";
					tbl_body +="<td  style='padding : 10px; text-align:center;'>" + gubun + "</td>";
					tbl_body +="<td  style='padding : 10px; text-align:center;'>" + userName + "</td>";
					tbl_body +="<td  style='padding : 10px; text-align:center;'>" + jobPositionName + "</td>";
					tbl_body +="<td  style='padding : 10px; text-align:center;'><p style='color:red; font-weight : bold;'>" + sumMM + "</p></td>";
					tbl_body +="<td  style='padding : 10px; text-align:center;'>" + inputdate + "</td>";
					
					totalSum += parseFloat(obj.SUMMM);
										
					$.each(months,function(){
						var fColor = "#000";
						var fWeight = 400;
						if(obj[months[cnt]] > 0) {
							// fColor = "red";
							fWeight = 600;
						}
						
						tbl_body +="<td style='padding : 10px; text-align:center; color:" + fColor + "; font-weight:" + fWeight + ";'>" + parseFloat(obj[months[cnt]]).toFixed(2) + "</td>";
						montlySum[months[cnt]] += parseFloat(obj[months[cnt]]);
						cnt++;
					});
					tbl_body +="</tr>";
					
					cnt=0;
				}
			
			);
			
			// 합계 Row
			tbl_body += "<tr>";
			tbl_body += "<td  style='padding : 10px; text-align:center; font-weight:bold; background-color : #92D050;'>합계</td>";
			tbl_body += "<td  style='padding : 10px; text-align:center; background-color : #92D050;'></td>";
			tbl_body += "<td  style='padding : 10px; text-align:center; background-color : #92D050;'></td>";
			tbl_body += "<td  style='padding : 10px; text-align:center; background-color : #92D050;'></td>";
			tbl_body += "<td  style='padding : 10px; text-align:center; background-color : #92D050;'></td>";
			tbl_body += "<td  style='padding : 10px; text-align:center; background-color : #92D050;'><p style='color:red; font-weight : bold;'>" + totalSum.toFixed(2) + "</p></td>";
			tbl_body += "<td  style='padding : 10px; text-align:center; background-color : #92D050;'></td>";
			
			cnt=0;
			
			$.each(months,function(){
				var fColor = "#000";
				var fWeight = 400;
				if(montlySum[months[cnt]] > 0) {
					fColor = "red";
					fWeight = 600;
				}
				
				tbl_body +="<td style='padding : 10px; text-align:center; background-color : #92D050; color:" + fColor + "; font-weight:" + fWeight + ";'>" + montlySum[months[cnt]].toFixed(2) + "</td>";
				cnt++;
			});
			
			tbl_body +="</tr>";
		}
		
		var sHtml = tbl_header + tbl_body;
		$("#tbStatistics tbody").html(sHtml);
		
	}).error(function(response, status, error){
	     //TODO 추가 오류 처리
	     CFN_ErrorAjax("getStatisticsProject.do", response, status, error);
	});	
};

var drawTable = function(){
	var strStartDate = "";
	var strEndDate = "";
	
	strStartDate = $("#selProjectFilter option:selected").attr('data-sym').substr(0,7);
	strEndDate = $("#selProjectFilter option:selected").attr('data-eym').substr(0,7);
	
	
	
	
	var nowDate = new Date();
	strStartDate = strStartDate == '' ? (nowDate.getYear() + 1900) + "-" + XFN_AddFrontZero(nowDate.getMonth() + 1, 2) : strStartDate;
	strEndDate = strEndDate == '' ? (nowDate.getYear() + 1900) + "-" + XFN_AddFrontZero(nowDate.getMonth() + 1, 2) : strEndDate;
	
	$("#startdate").val(strStartDate);
	$("#enddate").val(strEndDate);

	
	setData();
	
};

var orgCallBackMethod = function(data) {
	var jsonData = $.parseJSON(data);
	
	if(jsonData.item.length > 0) {
		var selGRCode = jsonData.item[0].AN;
		var selGRName = CFN_GetDicInfo(jsonData.item[0].DN);
		
		$("#selTeamName").val(selGRName).attr("data-code", selGRCode);
		
		setData();
	}
};


$(function() {

	bindOption();
	
	var tbl_body = "";
	tbl_body += "<tr height='220px;' style='background-color:white; border:1px solid #c9c9c9;'><td>";
	tbl_body += "<p style='text-align:center;'>프로젝트를 선택하여 주세요.</p></td></tr>";

	$("#tbStatistics tbody").html(tbl_body);
	
	// 범위세팅은 한곳 변경 시 양쪽 이벤트 모두 발생
	$("#startdate").on("change", function() {
		// data rebind
		setData();
	});
	
	$("#btnOrgMap").on("click", function() {
		   Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=orgCallBackMethod&type=C1","1000px","580px","iframe",true,null,null,true);
	   });
});

</script>