<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div>
	<h3 class="con_tit_box">
		<span class="con_tit">프로젝트 원가관리 > 외주비</span>
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
			<a class="AXButton" type="button" onclick="excelDownload(this)" >엑셀저장</a>
		</span>
	</div>
	
	<div id="resultBoxWrap" style="margin-top : 15px;">
		<table id="tbProjectCostOS" style="width:100%; border:1px solid #c9c9c9" border="1">
			<thead>
				<tr style='height:30px; text-align:center; font-size:11px; font-weight:bold;'>
					<td style='width:150px; background-color : #f1faff;'>투입월</td>
					<td style='width:200px; background-color : #f1faff;'>이름</td>
					<td style='width:100px; background-color : #f1faff;'>등급</td>
					<td style='min-width:250px; background-color : #f1faff;'>단가</td>
					<td style='width:150px; background-color : #f1faff;'>투입(M)</td>
					<td style='min-width:250px; background-color : #f1faff;'>비용</td>
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
		
		if(pData.length == 0) {
			var sHTML = "<tr style='height:50px; font-size:12px; background-color : #fff; text-align:center;'>";
			sHTML += "<td colspan='6'>표시 할 내용이 없습니다.</td>";
			sHTML += "</tr>"
							
			contArea.append(sHTML)
		} else {
			var yearMonth = "";
			var standardTime = 0;
			var standardCost = 0;
			var currMonth = "";
						
			$(pData).each(function(idx, data) {
				
				if(idx == 0)
					yearMonth = data.YearMonth;
				else {
					if(yearMonth != data.YearMonth) {
						currMonth = yearMonth.substr(4);
						// 신규 년월 또는 마지막 행의 경우 이전데이터의 합계를 출력
						var summaryHtml = "<tr style='height:30px; text-align:center; font-size:11px; font-weight:500;'>";
						summaryHtml += "<td colspan='4' style='background-color : #FFF4E3;'>" + currMonth + "월 총 합계" + "</td>";
						summaryHtml += "<td style='background-color : #FFF4E3;'>" + standardTime.toFixed(2) + "MM</td>";
						summaryHtml += "<td style='background-color : #FFF4E3;'>" + numberWithCommas(standardCost.toFixed(0)) + "</td>";
						summaryHtml += "</tr>";
						
						// 구분선
						summaryHtml += "<tr style='height:20px;'>";
						summaryHtml += "<td colspan='6'></td></tr>";
						
						yearMonth = data.YearMonth;
						contArea.append(summaryHtml);
						
						standardTime = 0;
						standardCost = 0;
					}
				}
				
				standardTime += parseFloat(data.ManMonth);
				standardCost += parseFloat(data.ManPrice);

				var sHTML = "<tr style='height:30px; text-align:center; font-size:11px; font-weight:500;'>";
				sHTML += "<td>" + data.YearMonth + "</td>";
				sHTML += "<td>" + data.Name + "</td>";
				sHTML += "<td>" + getGradeString(data.GradeKind) + "</td>";
				sHTML += "<td>" + numberWithCommas(parseInt(data.MonthPrice)) + "</td>";
				sHTML += "<td>" + parseFloat(data.ManMonth).toFixed(2) + "</td>";
				sHTML += "<td>" + numberWithCommas(parseFloat(data.ManPrice).toFixed(0))+ "</td>";
				sHTML += "</tr>";
				
				contArea.append(sHTML)
				
				// 마지막 행의 경우 합계표시
				if(pData.length == (idx + 1)) {
					currMonth = yearMonth.substr(4);
					// 신규 년월 또는 마지막 행의 경우 이전데이터의 합계를 출력
					var summaryHtml = "<tr style='height:30px; text-align:center; font-size:11px; font-weight:500;'>";
						summaryHtml += "<td colspan='4' style='background-color : #FFF4E3;'>" + currMonth + "월 총 합계" + "</td>";
						summaryHtml += "<td style='background-color : #FFF4E3;'>" + standardTime.toFixed(2) + "MM</td>";
						summaryHtml += "<td style='background-color : #FFF4E3;'>" + numberWithCommas(standardCost.toFixed(0)) + "</td>";
						summaryHtml += "</tr>";
					
					contArea.append(summaryHtml);
				}
			});
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
		
		fileName = prjName+"_외주비_" + currentDate.format("yyyyMMdd");
		
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
				
				$.getJSON('workreportgetprojectcostos.do', {JobID : jobId, StartDate : sym, EndDate : eym}, function(d) {
					drawDataTable(d.resultList);
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("workreportgetprojectcostos.do", response, status, error);
				});
				
			} else {
				$("#StartDate").val("");
				$("#EndDate").val("");
				$("#tbContents").empty();
				
				var sHTML = "<tr style='height:50px; font-size:12px; background-color : #fff; text-align:center;'>";
					sHTML += "<td colspan='6'>표시 할 내용이 없습니다.</td>";
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
				
				$.getJSON('workreportgetprojectcostos.do', {JobID : jobId, StartDate : sym, EndDate : eym}, function(d) {
					drawDataTable(d.resultList);
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("workreportgetprojectcostos.do", response, status, error);
				});
			}
		});
	
		bindOption();
		
	});
</script>