<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div>
	<h3 class="con_tit_box">
		<span class="con_tit">팀원 프로젝트 분석</span>
	</h3>
	
	<div id="divFilterBox" style="width:100%; height:40px; margin-bottom: 10px;">
		<label>팀명 : </label>
		<!-- MARK 권한 사용자에게만 조직도 버튼 바인딩 -->
		<span>
			<input type="text" class="AXInput W120" id="selTeamName" readonly data-code="" style='margin-right:10px; display:inline-block; width:120px;'></span>
			<input id="btnOrgMap" type="button" class="AXButton" value="<spring:message code='Cache.lbl_DeptOrgMap'/>" style='display:none;'/>
		</span>
		
		<span style='display:inline-block; margin-left : 20px;'>
			<label>기준월</label>
			<input type="text" id="StartDate" class="AXInput W100" readonly style='background-color : #fff; padding:0px!important;'> ~ 
			<input type="text" kind="twindate" date_align="right" date_valign="bottom" date_separator="-" readonly style='background-color : #fff; padding:0px!important;'
				   date_starttargetid="StartDate" date_selecttype="m" id="EndDate" class="AXInput W100" data-axbind="twinDate">
		</span>
		
		<span style="display:inline-block; margin-left:10px;" onclick="excelDownload();">
			<button class="AXButton" type="button">엑셀저장</button>
		</span>
		
		<span style="display:inline-block; margin-left:10px;" onclick="chartView();">
			<button class="AXButton" type="button">차트보기</button>
		</span>
	</div>
	
	<div id="resultBoxWrap" style="margin-top : 15px; position:relative; min-height:450px; max-height:600px; overflow-y:auto; overflow-x:hidden;">
		<div id="divFixedHeader" style="border:1px solid #c9c9c9; width:100%; position:absolute; top:0px; left:0px; box-sizing:border-box;">
			<div style="display:inline-block; border-right:1px solid #c9c9c9; height:30px; line-height:30px; position:relative;
						background-color : #f1faff; width:20%; box-sizing:border-box; font-weight:bold; float:left; text-align:center;">
				팀원
				<span onclick="filterColumn('USER');" class="filtercolumn"></span>
			</div>
			<div style="display:inline-block; border-right:1px solid #c9c9c9; height:30px; line-height:30px; position:relative;
						background-color : #f1faff; width:40%; box-sizing:border-box; font-weight:bold; float:left; text-align:center;">
				프로젝트
				<span onclick="filterColumn('JOB');" class="filtercolumn"></span>
			</div>
			<div style="display:inline-block; border-right:1px solid #c9c9c9; height:30px; line-height:30px; 
						background-color : #f1faff; width:20%; box-sizing:border-box; font-weight:bold; float:left; text-align:center;">
				프로젝트 M/H
			</div>
			<div style="display:inline-block; height:30px; line-height:30px; background-color : #f1faff; 
						width:20%; box-sizing:border-box; font-weight:bold; float:left; text-align:center;">
				프로젝트 누적
			</div>
		</div>
		<div id="divContent" style="border-left:1px solid #c9c9c9; border-right:1px solid #c9c9c9; width:100%; box-sizing:border-box; padding-top : 30px;">
			
		</div>
	</div>

</div>

<div id="hidExceldownload" style="display:none">
	<iframe name="ifExcelDownload" src="" style="display:none;"></iframe>
</div>

<div id="divFilterColumnBox" style="display:none;">
	<div style='padding:10px; box-sizing:border-box;'>
		<div style='height:240px; margin-bottom:10px; width: 100%; border : 1px solid #c9c9c9; overflow-y:auto; overflow-x:hidden;'>
			<ul id="ulFilterList" data-fmode="">
				<li>
					<span style='display:inline-block; width:20px;'><input type='checkbox' id="allChkFilter" onchange="allChkFilter(this);" /></span> 전체선택
				</li>
			</ul>
		</div>
		<div style='height:30px; width: 100%; text-align:center;'>
			<button type='button' class='AXButton' onclick='submitFilter();'>적용</button>
			<button type='button' class='AXButton' onclick='closeLayer("filterPop");'>취소</button>
		</div>
	</div>
</div>

<script>
	var g_listObj = {};
	var g_userFilterObj = [];
	var g_jobFilterObj = [];
	
	var g_currListObj = {};
	
	var orgCallBackMethod = function(data) {
		var jsonData = $.parseJSON(data);
		
		if(jsonData.item.length > 0) {
			var selGRCode = jsonData.item[0].AN;
			var selGRName = CFN_GetDicInfo(jsonData.item[0].DN);
			
			$("#selTeamName").val(selGRName).attr("data-code", selGRCode);
			
			// data rebind
			getTeamProjectData();
		}
	};
	
	var getTeamProjectData = function() {
		// 기존 data 삭제
		$("#divContent .divContentRow").remove();
		
		var pGR_Code = $("#selTeamName").attr("data-code");
		
		var pStartDate = $("#StartDate").val().replace("-", "");
		var pEndDate = $("#EndDate").val().replace("-", "");
		
		$.getJSON("getWorkReportTeamProject.do", {grcode : pGR_Code, startDate : pStartDate, endDate : pEndDate}, function(d) {
			g_listObj = d.list;
			g_currListObj = d.list;
			
			var contArea = $("#divContent");
			
			// 최초 화면을 그리면서 filter 생성
			if(g_listObj.length == 0) {
				var sHTML = '<div class="divContentRow" style="width:100%; height:30px; text-align:center; border-bottom: 1px solid #c9c9c9;">';
				sHTML += '<div style="display:inline-block; height:30px; line-height:30px; width:100%; box-sizing:border-box;">';
				sHTML += '표시할 내용이 없습니다.';
				sHTML += '</div>';
				sHTML += '</div>';
				contArea.append(sHTML);
			} else {
				g_listObj.forEach(function(data) {
					var sHTML = '<div class="divContentRow" style="width:100%; height:30px; text-align:center; border-bottom: 1px solid #c9c9c9;">';
					sHTML += '<div style="display:inline-block; border-right:1px solid #c9c9c9; height:30px; line-height:30px; ';
					sHTML += 'width:20%; box-sizing:border-box; float:left;">';
					sHTML += data.UR_Name + " " + data.JobPositionName;
					sHTML += '</div>';
					sHTML += '<div style="display:inline-block; border-right:1px solid #c9c9c9; height:30px; line-height:30px;';
					sHTML += 'width:40%; box-sizing:border-box; float:left;">';
					sHTML += data.JobName;
					sHTML += '</div>';
					sHTML += '<div style="display:inline-block; border-right:1px solid #c9c9c9; height:30px; line-height:30px;';
					sHTML += 'width:20%; box-sizing:border-box; float:left;">';
					sHTML += parseFloat(data.MonthHour).toFixed(1);
					sHTML += '</div>';
					sHTML += '<div style="display:inline-block; height:30px; line-height:30px; ';
					sHTML += 'width:20%; box-sizing:border-box; float:left; ">';
					sHTML += parseFloat(data.TotalHour).toFixed(1);
					sHTML += '</div>';
					sHTML += '</div>';
					
					var appendFlag = true;
					g_userFilterObj.forEach(function(d) {
						if(d.userCode == data.UR_Code)
							appendFlag = false;
						
						return appendFlag;
					});
					
					if(appendFlag)
						g_userFilterObj.push({userName : data.UR_Name, userCode : data.UR_Code, isFilter : 'Y'});
					
					appendFlag = true;
					
					g_jobFilterObj.forEach(function(d) {
						if(d.jobId == data.JobID)
							appendFlag = false;
						
						return appendFlag;
					});
					if(appendFlag)
						g_jobFilterObj.push({jobName : data.JobName, jobId : data.JobID, isFilter : 'Y'});
					
					contArea.append(sHTML);
				});
			}
			
			resizeTableHeight(g_listObj);
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getWorkReportTeamProject.do", response, status, error);
		});
	};
	
	var drawData = function(pData) {
		var contArea = $("#divContent");
		contArea.empty();
		
		g_currListObj = pData;
		
		if(pData.length == 0) {
			var sHTML = '<div class="divContentRow" style="width:100%; height:30px; text-align:center; border-bottom: 1px solid #c9c9c9;">';
			sHTML += '<div style="display:inline-block; height:30px; line-height:30px; width:100%; box-sizing:border-box;">';
			sHTML += '표시할 내용이 없습니다.';
			sHTML += '</div>';
			sHTML += '</div>';
			contArea.append(sHTML);
		} else {
			pData.forEach(function(data) {
				var sHTML = '<div class="divContentRow" style="width:100%; height:30px; text-align:center; border-bottom: 1px solid #c9c9c9;">';
				sHTML += '<div style="display:inline-block; border-right:1px solid #c9c9c9; height:30px; line-height:30px; ';
				sHTML += 'width:20%; box-sizing:border-box; float:left;">';
				sHTML += data.UR_Name + " " + data.JobPositionName;
				sHTML += '</div>';
				sHTML += '<div style="display:inline-block; border-right:1px solid #c9c9c9; height:30px; line-height:30px;';
				sHTML += 'width:40%; box-sizing:border-box; float:left;">';
				sHTML += data.JobName;
				sHTML += '</div>';
				sHTML += '<div style="display:inline-block; border-right:1px solid #c9c9c9; height:30px; line-height:30px;';
				sHTML += 'width:20%; box-sizing:border-box; float:left;">';
				sHTML += parseFloat(data.MonthHour).toFixed(1);
				sHTML += '</div>';
				sHTML += '<div style="display:inline-block; height:30px; line-height:30px; ';
				sHTML += 'width:20%; box-sizing:border-box; float:left; ">';
				sHTML += parseFloat(data.TotalHour).toFixed(1);
				sHTML += '</div>';
				sHTML += '</div>';
				
				
				contArea.append(sHTML);
			});
		}
		
		resizeTableHeight(pData);
	};
	
	var resizeTableHeight = function(pData) {
		var tabArea = $("#resultBoxWrap");
		// border-bottom:1px solid #c9c9c9; 

		if(pData.length == 0) {
			tabArea.css('height', '60px');
		} else {
			var calHeight = 30;
			calHeight += (pData.length * 30);
			
			if(calHeight > 600) { 
				tabArea.css("border-bottom", "1px solid #c9c9c9");
			} else {				
				tabArea.css("height", calHeight + "px");
			}
		}
	};

	
	var filterColumn = function(type) {
		if(type=='USER') {
			if(g_userFilterObj.length > 0) {
				$("#ulFilterList").attr("data-fmode", "USER");
				$("#ulFilterList>li").not(":first-child").remove();
				var filterList = $("#ulFilterList"); 
				$(g_userFilterObj).each(function(idx, data) {
					
					var chkFlag = data.isFilter == "Y" ? "checked" : "";
					
					var sHTML = "<li>";
					sHTML += "<span style='float:left; display:inline-block; width:20px;'>";
					sHTML += "<input type='checkbox' name='chkFilterItem' data-idx='" + idx + "' data-ucode='" + data.userCode + "' " + chkFlag + " /></span>";
					sHTML += "<span style='display:inline-block; width : 180px; overflow:hidden; white-space:nowrap; text-overflow:ellipsis; float:left; padding-right:10px;'>";
					sHTML += data.userName;
					sHTML += "</span>"; 
					
					filterList.append(sHTML);
				});
				
				Common.open("", "filterPop", "컬럼 필터링", "divFilterColumnBox", "250px", "300px", "id", true, null, null, true);
			}
		} else if (type=='JOB') {
			if(g_jobFilterObj.length > 0) {
				$("#ulFilterList").attr("data-fmode", "JOB");
				$("#ulFilterList>li").not(":first-child").remove();
				
				var filterList = $("#ulFilterList"); 
				$(g_jobFilterObj).each(function(idx, data) {
					
					var chkFlag = data.isFilter == "Y" ? "checked" : "";
					
					var sHTML = "<li>";
					sHTML += "<span style='float:left; display:inline-block; width:20px;'>";
					sHTML += "<input type='checkbox' name='chkFilterItem' data-idx='" + idx + "' data-jid='" + data.jobId + "' " + chkFlag + " /></span>";
					sHTML += "<span style='display:inline-block; width : 180px; overflow:hidden; white-space:nowrap; text-overflow:ellipsis; float:left; padding-right:10px;'>";
					sHTML += data.jobName;
					sHTML += "</span>"; 
					
					filterList.append(sHTML);
				});
				
				Common.open("", "filterPop", "컬럼 필터링", "divFilterColumnBox", "250px", "300px", "id", true, null, null, true);
			}
		}
	}
	
	var allChkFilter = function(target) {
		$("input[name='chkFilterItem']").prop("checked", $(target).prop("checked"));
	};
	
	var closeLayer = function(layerId) {
		Common.close(layerId);
	};
	
	var submitFilter = function() {
		var mode = $("#ulFilterList").attr("data-fmode");
		var filterObj = mode == "USER" ? g_userFilterObj : g_jobFilterObj;
		
		$("input[name='chkFilterItem']").each(function(idx, obj) {			
			var target = $(obj);
			
			filterObj[target.attr("data-idx")].isFilter = target.prop("checked") ? "Y" : "N";
		});
		
		// filter & redraw data
		var userFilterIds = [];
		var jobFilterIds = [];
		
		g_userFilterObj.forEach(function(data) {
			if(data.isFilter == "Y")
				userFilterIds.push(data.userCode);
		});
		
		g_jobFilterObj.forEach(function(data) {
			if(data.isFilter == "Y")
				jobFilterIds.push(data.jobId);
		});
		
		var filterData = g_listObj.filter(function(data) {
			var viewFlag = false;
			userFilterIds.forEach(function(id) {
				if(id == data.UR_Code) {
					viewFlag = true;
					return false;
				}
			});
			
			// user 필터 통과한 경우 job 필터도 확인
			if(viewFlag) {
				var jViewFlag = false;
				
				jobFilterIds.forEach(function(id) {
					if(id == data.JobID) {
						jViewFlag = true;
						return false;
					}
				});
				
				viewFlag = jViewFlag;
			}
			
			return viewFlag;
		});
		
		drawData(filterData);
		
		// close
		Common.close("filterPop");
	}
	
	var excelDownload = function(target) {
		var fileName = "";
		var excelData = "";

		excelData = "<table style='border:1px solid #c9c9c9;' border='1'>";
		excelData += "<thead>";
		excelData += "<tr style='height:30px; text-align:center;font-weight:bold;'>";
		excelData += "<th style='background-color:#f1faff;'>팀원</th>";
		excelData += "<th style='background-color:#f1faff;'>프로젝트</th>";
		excelData += "<th style='background-color:#f1faff;'>프로젝트 M/H</th>";
		excelData += "<th style='background-color:#f1faff;'>프로젝트 누적</th>";
		excelData += "</tr>";
		excelData += "</thead><tbody>";
		$(g_currListObj).each(function(idx, data) {
			excelData += "<tr style='height:30px; text-align:center;'>";
			excelData += "<td>" + data.UR_Name + " " + data.JobPositionName + "</td>";
			excelData += "<td>" + data.JobName + "</td>";
			excelData += "<td>" + parseFloat(data.MonthHour).toFixed(1) + "</td>";
			excelData += "<td>" + parseFloat(data.TotalHour).toFixed(1) + "</td>";
			excelData += "</tr>";
		});
		excelData += "</tbody></table>";
		
		excelData = encodeURIComponent(excelData);
		
		var teamName = $("#selTeamName").val();
		var currentDate = new Date();
		
		fileName = teamName + "_팀원프로젝트분석_" + currentDate.format("yyyyMMdd");
		
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
	
	var chartView = function() {
		var pGR_Code = $("#selTeamName").attr("data-code");
		
		var pStartDate = $("#StartDate").val().replace("-", "");
		var pEndDate = $("#EndDate").val().replace("-", "");
		
		Common.open("", "WorkReportChart", "팀 프로젝트 분석 - 차트", "chartTeamProject.do?grcode=" + pGR_Code + "&startDate=" + pStartDate + "&endDate=" + pEndDate, "500px", "480px", "iframe", true, null, null, true);	
	};
	
	
	$(function(){
		// mark 권한여부에 따른 조직도 버튼 표시여부
		$("#selTeamName").val("${gr_name}").attr("data-code", "${gr_code}");
		
		
		// 기준월 default 세팅
		var currentDate = new Date();
		var strCurDate = (currentDate.getYear() + 1900) + "-" + XFN_AddFrontZero(currentDate.getMonth() + 1, 2);
		$("#StartDate").val(strCurDate);
		$("#EndDate").val(strCurDate);
		
		getTeamProjectData();
		
		// 범위세팅은 한곳 변경 시 양쪽 이벤트 모두 발생
		$("#StartDate").on("change", function() {
			// data rebind
			getTeamProjectData();
		});
		
		$("#resultBoxWrap").on("scroll", function() {
			var sTop = $(this).scrollTop();
			
			$("#divFixedHeader").css("top", sTop);
		});
		

		// 조직도 버튼 관리자권한 확인
		var strManagerInfo = Common.getBaseConfig("TempWorkReportManager");
		
		var arrManagerInfo = strManagerInfo.split('|');
		var flagM = false;
		
		//개별호출-일괄호출
		var sessionObj = Common.getSession(); //전체호출
		
		arrManagerInfo.forEach(function(mInfo) {
			var arrInfo = mInfo.split(":");
			if(arrInfo.length == 2) {
				if(arrInfo[0] == "UR") {
					if(arrInfo[1] == sessionObj["UR_Code"]) {
						flagM = true;
						return false;
					}
				} else if(arrInfo[0] == "GR"){
					if(arrInfo[1] == sessionObj["GR_Code"]) {
						flagM = true;
						return false;
					}
				}	
			}
		});
		
		if(flagM) {
			$("#btnOrgMap").css("display", "")
						   .on("click", function() {
							   Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=orgCallBackMethod&type=C1","1000px","580px","iframe",true,null,null,true);
						   });
		} else  {
			$("#btnOrgMap").remove();
		}
	});
</script>