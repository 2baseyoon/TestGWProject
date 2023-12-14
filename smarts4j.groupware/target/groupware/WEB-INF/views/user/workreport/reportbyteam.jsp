<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style type="text/css">

.tblHeader{
	height:30px; 
	line-height:30px; 
	background-color : #f1faff; 
	box-sizing:border-box; 
	font-weight:bold; 
	text-align:center;
	padding: 0 5px 0 5px;
}

</style>
<div>
	<h3 class="con_tit_box">
		<span class="con_tit">팀별 원가관리 > 인건비</span>
	</h3>

	<div id="divFilterBox" style="width:100%; height:40px; margin-bottom: 10px;">
		<label>팀명 : </label>
		<!-- MARK 권한 사용자에게만 조직도 버튼 바인딩 (차후 필요한 작업) -->
		<span>
			<input type="text" class="AXInput W120" id="selTeamName" readonly data-code="" style='margin-right:10px; display:inline-block; width:120px;'></span>
			<input id="btnOrgMap" type="button" class="AXButton" value="<spring:message code='Cache.lbl_DeptOrgMap'/>" style='display:none;'/>
		</span>
		
		<span style='display:inline-block; margin-left : 20px;'>
			<label>기준월</label>
			<input type="text" id="startdate" class="AXInput W100" style="padding:0px!important;"> ~ 
			<input type="text" kind="twindate" date_align="right" date_valign="bottom" date_separator="-"  style="padding:0px!important;"
				   date_starttargetid="startdate" date_selecttype="m" id="enddate" class="AXInput W100" data-axbind="twinDate">
		</span>
		
		<span style="display:inline-block; margin-left:10px;">
			<button class="AXButton" type="button" onclick="excelDownload();">엑셀저장</button>
		</span>
		
		<span style="display:inline-block; margin-left:10px;">
			<button class="AXButton" type="button" onclick="chartView();">차트보기</button>
		</span>
	</div>
	
	<div id="resultBoxWrap" style="margin-top : 15px; position:relative; min-height:600px;">
		<table id="tblResult" border ="1" style="border : 1px solid #c9c9c9;">
			<tbody id="tbodyResult">
			
			</tbody>
		</table>
		<div id="divNoData" style="height : 200px; width : 100%; border : 1px solid #c9c9c9; display:none;">
			<p style="margin-top:90px; text-align:center;">표시할 내용이 없습니다.</p>
		</div>
	</div>
	
	<div id="hidExceldownload" style="display:none">
		<iframe name="ifExcelDownload" src="" style="display:none;"></iframe>
	</div>
</div>
<script>

var orgCallBackMethod = function(data) {
	var jsonData = $.parseJSON(data);
	
	if(jsonData.item.length > 0) {
		var selGRCode = jsonData.item[0].AN;
		var selGRName = CFN_GetDicInfo(jsonData.item[0].DN);
		
		$("#selTeamName").val(selGRName).attr("data-code", selGRCode);
		
		// data rebind
		setData();
	}
};

var excelDownload = function(target) {
	var fileName = "";
	var excelData = encodeURIComponent($("#tblResult")[0].outerHTML);
	
	var teamName = $("#selTeamName").val();
	
	if(teamName == ""){
		Common.Inform("팀을 선택하여 주세요.");
	}
	else{
		var currentDate = new Date();
		
		fileName = teamName+"_인건비_" + currentDate.format("yyyyMMdd");
		
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

	var strStartDate = $("#startdate").val().replace("-","");
	var strEndDate = $("#enddate").val().replace("-","");
	var strGR_Code = $("#selTeamName").attr("data-code");
	
	var typecodes ="";
	var typenames="";
	var cnt=0;
	
	$.getJSON("getJobTypeList.do",{gr_code : strGR_Code, startdate : strStartDate, enddate : strEndDate}, function(d){
		
		var list = d.list;
				
		list.forEach(function(obj) {
			$.each(obj,function(key, value){
				if(key == "TypeCode"){
					typecodes +=  value + ";" ;
				}else if(key == "DisplayName"){
					typenames += value + ";";
				}		
			});
		});

		typecodes = typecodes.substring(0,typecodes.length-1);
		typenames = typenames.substring(0,typenames.length-1);

		$("#tbodyResult").html('');
				
		if(typecodes != "") {

			$.getJSON("getSumHourList.do", {gr_code : strGR_Code, startdate : strStartDate, enddate : strEndDate , typecodes : typecodes}, function(list){
				var tblBody = "";
				var tblHeader = "";
				var list = list.list;
				var userName = "";
				var stypecodes = typecodes.split(";");
				var displaynames = typenames.split(";");

				var tblTotal = "";
				
				tblHeader += "<tr><td  class='tblHeader' width='20%'>이름</td>";
				
				$.each(displaynames,function(idx,data){
					tblHeader += "<td  class='tblHeader'>" + data + "</td>";
				});
				
				tblHeader += "<td  class='tblHeader' width='15%'>총합계</td>";
				tblHeader += "</tr>";

				list.forEach(function(obj) {
					userName = obj.UR_Code == "Total" ? "총합계" : obj.UR_Name;
					
					if(obj.UR_Code == "Total") {
						tblTotal += "<tr><td width='20%' style='padding : 10px;'>" + userName + "</td>";
						
						$.each(stypecodes,function(idx,data){

							tblTotal += "<td width='10%' style='padding : 10px; text-align : center;'>" + obj[data].toFixed(1) + "</td>";
							
						});
						
						tblTotal += "<td width='15%' style='padding : 10px; text-align : right;'>" + obj["SUM"].toFixed(1) + "</td>";
						tblTotal +="</tr>";
					} else {
						tblBody += "<tr><td width='20%' style='padding : 10px;'>" + userName + "</td>";

						$.each(stypecodes,function(idx,data){

							tblBody += "<td width='10%' style='padding : 10px; text-align : center;'>" + obj[data].toFixed(1) + "</td>";
							
						});
						
						tblBody += "<td width='15%' style='padding : 10px; text-align : right;'>" + obj["SUM"].toFixed(1) + "</td>";
						tblBody +="</tr>";
					}
				});
				
				
				tblBody += tblTotal;
				
				$("#divNoData").hide();
				$("#tbodyResult").html(tblHeader + tblBody);
				
				$("#tbodyResult tr:last td").css({
					'background-color' : "#f1faff",
					'font-weight' : 'bold'
					}
				);
				
				// $("#tbodyResult tr:last td:first-child").text("총합계");
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("getSumHourList.do", response, status, error);
			});
		}else{
			$("#divNoData").show();
		}
	
	}).error(function(response, status, error){
	     //TODO 추가 오류 처리
	     CFN_ErrorAjax("getJobTypeList.do", response, status, error);
	});
};

var chartView = function() {
	var strStartDate = $("#startdate").val().replace("-","");
	var strEndDate = $("#enddate").val().replace("-","");
	var strGR_Code = $("#selTeamName").attr("data-code");
	
	Common.open("", "WorkReportChart", "팀별 원가관리 - 차트", "chartReportByTeam.do?gr_code=" + strGR_Code + "&startdate=" + strStartDate + "&enddate=" + strEndDate, "500px", "480px", "iframe", true, null, null, true);
};

$(function() {

	// mark 권한여부에 따른 조직도 버튼 표시여부
	$("#selTeamName").val("${gr_name}").attr("data-code", "${gr_code}");
	
	// 기준월 default 세팅
	var currentDate = new Date();
	var strCurDate = (currentDate.getYear() + 1900) + "-" + XFN_AddFrontZero(currentDate.getMonth() + 1, 2);
	$("#startdate").val(strCurDate);
	$("#enddate").val(strCurDate);
	
	setData();
	
	// 범위세팅은 한곳 변경 시 양쪽 이벤트 모두 발생
	$("#startdate").on("change", function() {
		// data rebind
		setData();
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