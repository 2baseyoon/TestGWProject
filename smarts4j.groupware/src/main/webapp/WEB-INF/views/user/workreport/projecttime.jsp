<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div>
	<h3 class="con_tit_box">
		<span class="con_tit">프로젝트 투입시간</span>
	</h3>
	
	<div id="divFilterBox" style="width:100%; height:40px; margin-bottom: 10px;">
		<label>프로젝트 : </label>
		<!-- MARK 권한 사용자에게만 조직도 버튼 바인딩 -->
		<span>
			<span style="margin-left : 5px;">업무명 : </span><input type="text" id="txtJobName" class="W200" placeholder="업무명을 입력해주세요."/>
			<select id="selPrj" class="W200" style="appearance:auto;"></select>
		</span>
		
		<span id="spnDateBox" style='display:inline-block; margin-left : 20px;'>
			<label>기준월</label>
			<input type="text" id="StartDate" class="AXInput W100" readonly style='background-color : #fff; padding:0px!important;' /> ~ 
			<input type="text" kind="twindate" date_align="right" date_valign="bottom" date_separator="-" date_selecttype="m" 
				   date_starttargetid="StartDate" id="EndDate" class="AXInput W100" data-axbind="twindate" readonly style='background-color : #fff; padding:0px!important;'>
		</span>
		
		<span style="display:inline-block; margin-left:10px;">
			<button class="AXButton" type="button" onclick="excelDownload();">엑셀저장</button>
		</span>
	</div>
	
	<div id="resultBoxWrap" style="margin-top : 15px;">
		<table style="width:100%; border:1px solid #c9c9c9" border="1">
			<thead>
				<tr style='height:30px; text-align:center; font-size:11px; font-weight:bold; '>
					<td style='width:50px; background-color : #f1faff;'>투입월</td>
					<td style='width:50px; background-color : #f1faff;'>이름</td>
					<td style='width:40px; background-color : #f1faff;'>등급</td>
					<td colspan="32" style='background-color : #f1faff;'>일별 투입시간</td>
				</tr>
				<tr style='height:30px; text-align:center; font-size:11px; font-weight:bold;'>
					<td colspan="3" style='background-color : #f1faff;'></td>
					<td style='width:35px; background-color : #f1faff;'>합계</td>
					<td style='width:35px; background-color : #f1faff;'>1</td>
					<td style='width:35px; background-color : #f1faff;'>2</td>
					<td style='width:35px; background-color : #f1faff;'>3</td>
					<td style='width:35px; background-color : #f1faff;'>4</td>
					<td style='width:35px; background-color : #f1faff;'>5</td>
					<td style='width:35px; background-color : #f1faff;'>6</td>
					<td style='width:35px; background-color : #f1faff;'>7</td>
					<td style='width:35px; background-color : #f1faff;'>8</td>
					<td style='width:35px; background-color : #f1faff;'>9</td>
					<td style='width:35px; background-color : #f1faff;'>10</td>
					<td style='width:35px; background-color : #f1faff;'>11</td>
					<td style='width:35px; background-color : #f1faff;'>12</td>
					<td style='width:35px; background-color : #f1faff;'>13</td>
					<td style='width:35px; background-color : #f1faff;'>14</td>
					<td style='width:35px; background-color : #f1faff;'>15</td>
					<td style='width:35px; background-color : #f1faff;'>16</td>
					<td style='width:35px; background-color : #f1faff;'>17</td>
					<td style='width:35px; background-color : #f1faff;'>18</td>
					<td style='width:35px; background-color : #f1faff;'>19</td>
					<td style='width:35px; background-color : #f1faff;'>20</td>
					<td style='width:35px; background-color : #f1faff;'>21</td>
					<td style='width:35px; background-color : #f1faff;'>22</td>
					<td style='width:35px; background-color : #f1faff;'>23</td>
					<td style='width:35px; background-color : #f1faff;'>24</td>
					<td style='width:35px; background-color : #f1faff;'>25</td>
					<td style='width:35px; background-color : #f1faff;'>26</td>
					<td style='width:35px; background-color : #f1faff;'>27</td>
					<td style='width:35px; background-color : #f1faff;'>28</td>
					<td style='width:35px; background-color : #f1faff;'>29</td>
					<td style='width:35px; background-color : #f1faff;'>30</td>
					<td style='width:35px; background-color : #f1faff;'>31</td>
				</tr>
			</thead>
			<tbody id="tbContents">
				
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
	
	var bindOption = function(){
		var selPrj = $("#selPrj");
		selPrj.empty();
		selPrj.append("<option value=''>업무 검색 결과</option>");
		selPrj.trigger('change');
		
		let str = $("#txtJobName").val().toUpperCase();
		
		if(str){
			$.getJSON("workreportgetmanageprj.do", {}, function(d) {
				var liProject = d.list;
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
	}

	var drawDataTable = function(pData) {
		var contArea = $("#tbContents");
		
		contArea.empty();
		$("#trTotalHour").remove();
		
		if(pData.length == 0) {
			var sHTML = "<tr style='height:50px; font-size:12px; background-color : #fff; text-align:center;'>";
			sHTML += "<td colspan='35'>표시 할 내용이 없습니다.</td>";
			sHTML += "</tr>"
							
			contArea.append(sHTML)
		} else {
			var yearMonth = "";
			var standardTime = 0;
			var overTime = 0;
			var standardCost = 0;
			var overCost = 0;
			var currMonth = "";
			
			var workTime = 0;
			
			var totalHour = 0;
			
			$(pData).each(function(idx, data) {
				// 1MM으로 제한된 값으로 집계
				totalHour += parseFloat(data.WorkTime);
				
				if(idx == 0)
					yearMonth = data.YearMonth;
				else {
					if(yearMonth != data.YearMonth) {
						currMonth = yearMonth.substr(4);
						// 신규 년월 또는 마지막 행의 경우 이전데이터의 합계를 출력
						var summaryHtml = "<tr style='height:30px; text-align:center; font-size:11px; font-weight:500;'>";
						summaryHtml += "<td colspan='3' style='font-weight:bold;'>" + currMonth + "월 총 합계</td>";	
						summaryHtml += "<td colspan='32' style='background-color : #FFF4E3'>";
						summaryHtml += "투입시간 (H) : " + workTime.toFixed(2);
						summaryHtml += "</td>";
						summaryHtml += "</tr>";
						
						// 구분선
						summaryHtml += "<tr style='height:20px; background-color : #fff;'>";
						summaryHtml += "<td colspan='35'></td></tr>";
						
						yearMonth = data.YearMonth;
						contArea.append(summaryHtml);
						
						workTime = 0;
					}
				}
								
				workTime += parseFloat(data.WorkTime);
				
				var sHTML = "<tr style='height:30px; text-align:center; font-size:11px; font-weight:500;'>";
				sHTML += "<td>" + data.YearMonth + "</td>";
				sHTML += "<td>" + data.UR_Name + "</td>";
				sHTML += "<td>" + getGradeString(data.GradeKind) + "</td>";
				sHTML += "<td>" + parseFloat(data.WorkTime).toFixed(2) + "</td>";
				sHTML += "<td>" + parseFloat(data["1"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["2"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["3"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["4"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["5"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["6"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["7"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["8"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["9"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["10"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["11"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["12"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["13"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["14"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["15"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["16"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["17"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["18"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["19"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["20"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["21"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["22"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["23"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["24"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["25"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["26"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["27"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["28"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["29"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["30"]).toFixed(1) + "</td>";
				sHTML += "<td>" + parseFloat(data["31"]).toFixed(1) + "</td>";
				sHTML += "</tr>";
				
				contArea.append(sHTML)
				
				// 마지막 행의 경우 합계표시
				if(pData.length == (idx + 1)) {
					currMonth = yearMonth.substr(4);
					// 신규 년월 또는 마지막 행의 경우 이전데이터의 합계를 출력
					var summaryHtml = "<tr style='height:30px; text-align:center; font-size:11px; font-weight:500;'>";
						summaryHtml += "<td colspan='3' style='font-weight:bold;'>" + currMonth + "월 총 합계</td>";	
						summaryHtml += "<td colspan='32' style='background-color : #FFF4E3'>";
						summaryHtml += "투입시간 (H): " + workTime.toFixed(2);
						summaryHtml += "</td>";
						summaryHtml += "</tr>";
					
					contArea.append(summaryHtml);
				}
			});
			
			
			var totalHourInfo = "<tr id='trTotalHour' style='height:30px; font-size:11px;'>";
			totalHourInfo += "<td colspan='3' style='text-align:center; font-weight:bold; background-color : #fff4f4;'>총 투입 시간</td>";
			totalHourInfo += "<td colspan='32' style='padding-left : 10px; font-weight: bold;'>총 투입 시간 (단위 H): " + totalHour.toFixed(2) + "</td>";
			totalHourInfo += "</tr>";
			
			$("#resultBoxWrap>table>thead").prepend(totalHourInfo);
		}
	}
	
	var numberWithCommas = function (x) {
	    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	}
	
	var getGradeString = function (pGradeKind) {
		var gradeName = "";
		switch(pGradeKind) {
		case "S" : gradeName="특급"; break;
		case "H" : gradeName="고급"; break;
		case "M" : gradeName="중급"; break;
		case "B" : gradeName="초급2"; break;
		case "N" : gradeName="초급1"; break;
		}
		
		return gradeName;
	}

	var excelDownload = function(target) {
		var fileName = "";
		var excelData = encodeURIComponent($("#resultBoxWrap").html());
		
		var prjName = $("#selPrj>option:selected").text();
		var currentDate = new Date();
		
		fileName = prjName+"_프로젝트투입시간_" + currentDate.format("yyyyMMdd");

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
	};
	
	
	$(function(){
		$("#selPrj").on("change", function() {
			var selOption = $("#selPrj>option:selected");
			var sym = selOption.attr("data-sym");
			var eym = selOption.attr("data-eym");
			var jobId = selOption.val();

			if(jobId != "" && sym != "" && eym != "") {				
				$("#StartDate").val(sym);
				$("#EndDate").val(eym);
			
				sym = sym.replace(/[^0-9]/g, '');
				eym = eym.replace(/[^0-9]/g, '');
				
				$.getJSON('workreportgetprojecttime.do', {JobID : jobId, StartDate : sym, EndDate : eym}, function(d) {
					drawDataTable(d.resultList);
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("workreportgetprojecttime.do", response, status, error);
				});
				
			} else {
				$("#StartDate").val("");
				$("#EndDate").val("");
				$("#tbContents").empty();
				
				var sHTML = "<tr style='height:50px; font-size:12px; background-color : #fff; text-align:center;'>";
					sHTML += "<td colspan='39'>표시 할 내용이 없습니다.</td>";
					sHTML += "</tr>"
									
				$("#tbContents").append(sHTML)
			}
		});
		  
		$("#StartDate").on("change", function() {
			var jobId = $("#selPrj").val();
			var sym = $("#StartDate").val();
			var eym = $("#EndDate").val();
						
			if(jobId != "" && sym != "" && eym != "") {
				sym = sym.replace(/[^0-9]/g, '');
				eym = eym.replace(/[^0-9]/g, '');
				
				$.getJSON('workreportgetprojecttime.do', {JobID : jobId, StartDate : sym, EndDate : eym}, function(d) {
					drawDataTable(d.resultList);
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("workreportgetprojecttime.do", response, status, error);
				});
			}
		});
	
		bindOption();
		
	});
</script>