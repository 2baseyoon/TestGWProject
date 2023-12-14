<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
	.workReportListNode {
		width:100%; 
		height:30px; 
		cursor:pointer; 
		line-height:30px;
		border-bottom:1px solid #c9c9c9; 
		font-weight:500; 
		padding-left : 10px;
	}
</style>
<div>
	<h3 class="con_tit_box">
		<span class="con_tit">외주직원 관리</span>
	</h3>
	
	<!-- 상단 필터 및 메뉴 -->
	<div style="width:100%; height:40px; margin-bottom: 10px;">
		<div style="display:inline-block; width:100%;">
			<span style="" ><button type="button" id="btnSearch" class="AXButton" onclick="refreshData()" >새로고침</button></span>
			<span style="margin-left : 5px;">이름</span> 
			<input type="text" id="txtOSName" style="width: 85px; padding:0px!important;"  class="AXInput" /> 
			<div style="display:none;">
			<span style="margin-left : 5px;">계약 기간</span> 
			<input type="text" id="startdate" style="width: 85px; padding:0px!important;"  class="AXInput" /> ~ 
			<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 105px; padding:0px!important;"  class="AXInput"  />	
			</div>		
			<span style="margin-left:5px;" ><input type="checkbox" id="chkEndcontract" name="mycheck" style="margin-left:5px;" />계약 종료</span>
			
			<span style="margin-left:15px;" ><button type="button" id="btnSearch" class="AXButton" onclick="bindGridData()" >검색</button></span>
			
			<div id='divButton' style="float:right;">
				<button type="button" id="btnRegist" class="AXButton" onclick="osRegistOpen('Reg','')">등록</button>
				<button type="button" id="btnDelete" class="AXButton" onclick="osDelete()">삭제</button>
			</div>		
		</div>
	</div>	
	
	<!-- Grid -->
	<div id="resultBoxWrap" style="margin-top : 15px;">
		<div id="AXGridTarget"></div>
	</div>
</div>

<div id="divWorkReportList" style='width:300px; height:330px; display:none;'>
	<div style='width : 100%; height: 30px; box-sizing:border-box; font-weight:bold; font-size:13px; line-height:30px; background-color : #f8f8f8; border-bottom : 1px solid #c9c9c9;'>
		<h3 class="titIcn" style="font-size:13px!important;">업무보고 주차</h3>	
	</div>
	<div id="divCalInfoList" style='width:100%; height: 300px; box-sizing:border-box; overflow-y : auto; font-size:11px;'>
	</div>
</div>

<script>

var mode = "Reg";
var OsGrid = new coviGrid();

//Grid 관련 사항 추가 -
//Grid 생성 관련
function setGrid(){

	OsGrid.setGridHeader([
		                  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
		                  {key:'OUR_Code' , label:'ID', width:'60', align:'center', formatter : function(){
		                	  var sHtml = "<p class='our_code'>" + this.item.OUR_Code + "</p>";
		                	  
		                	  return sHtml;
		                  }},
		                  {key:'Name',  label:'이름', width:'100', align:'center' , formatter : function(){
							var sHtml = "<a href='#' onclick=osRegistOpen('Edit','"+ this.item.OUR_Code + "');>" + this.item.Name +"</a>";
		                	  
		                	  return sHtml;
		                  }},
		                  {key:'GradeKind',  label:'등급', width:'40', align:'center', formatter: function() {
		                	  var strResult = "";
		                	  switch(this.item.GradeKind) {
			                	  case "S" : strResult = "특급"; break;
			                	  case "H" : strResult = "고급"; break;
			                	  case "M" : strResult = "중급"; break;
			                	  case "N" : strResult = "초급"; break;
			                	  // N은 사용하지 않음
		                	  }
		                	  return strResult;
		                  }},
		                  {key:'FirstName', label:'담당자', width:'70', align:'center'},
		                  {key:'WorkSubject', label:'프로젝트', width:'200', align:'center', formatter : function(){
							  var sSubject = this.item.WorkSubject.toString();

		                	  var sHtml = "<a href='#' onclick=osRegistOpen('Edit','"+ this.item.OUR_Code + "');>" + sSubject +"</a>";
		                	  
		                	  return sHtml;
		                  }},
		                  {key:'WorkReport', label:'업무보고', width:'70', align:'center', sort: false, formatter : function(){
		                	  var sHTML = "<button type='button' onclick='openWorkReportList(\"" + this.item.OUR_Code + "\")' class='AXButton'>업무보고 조회</button>";
		                	  return sHTML;
		                  }}
			      		]);
	setGridConfig();
	bindGridData();
}

function refreshData() {
	$("#startdate").val("");
	$("#enddate").val("");
	$("#chkEndcontract").prop("checked", false).trigger("change");
	$("#txtOSName").val("");
	
	bindGridData();
}
function bindGridData() {
	var strStartDate = $("#startdate").val();
	var strEndDate = $("#enddate").val();
	var strEndContract = "";
	if($("#chkEndcontract").is(":checked")) {
		strStartDate = "";
		strEndDate = "";
		strEndContract = "Y";	
	}
	else strEndContract = "N";
	var strOSName = $("#txtOSName").val();
		
	OsGrid.bindGrid({
		ajaxUrl:"getoutsourcinglist.do",
		ajaxPars: {
			startdate : strStartDate,
			enddate : strEndDate,
			isendcontract : strEndContract.toString(),
			osname : strOSName
		}
	});
}

//Grid 설정 관련
function setGridConfig(){
	var configObj = {
		targetID : "AXGridTarget",		// grid target 지정
		sort : true,		// 정렬
		colHeadTool : false,	// 컬럼 툴박스 사용여부
		fitToWidth : true,		// 자동 너비 조정 사용여부
		colHeadAlign : 'center',
		height:"auto",
		
		page : {
			pageNo:1,
			pageSize:10
		},
		paging : true
	};
	
	// Grid Config 적용
	OsGrid.setGridConfig(configObj);
}

var bindOption = function() {
	var jQObj = $("#selDivision");
	$(jQObj).append("<option value=''>업무구분</option>");
	$("#allTypeListBox").empty();
	$.getJSON("getWorkReportDiv.do", {}, function(d){	
		var listData = d.list;
		$(listData).each(function(idx, data) {
			jQObj.append("<option value='" + data.code + "'>" + data.name + "</option>");
		});		
	}).error(function(response, status, error){
	     //TODO 추가 오류 처리
	     CFN_ErrorAjax("getWorkReportDiv.do", response, status, error);
	});
};

var osRegistOpen = function(pMode,pUR_Code) {
	
	Common.open("btnRegist", "OutsourcingRegistPop", "외주직원 등록", "registOS.do?mode=" + pMode + "&urcode=" + pUR_Code, "510px", "340px", "iframe", true, null, null, true);

};	

//외주직원 등록/수정
var addOutsourcing = function() {
	var strText = mode == "Reg" ? "등록" : "수정";
	var strURCode = $("#hidOUR_Code").val();
	var strName = $("#txtName").val();
	var strGrade = $("#selGrade").val();
	var strAge = $("#txtAge").val();
	var strFirstManagerCode = $("#selectFirstManagerInfo").attr("data-urcode");
	var strFirstManagerName = $("#selectFirstManagerInfo").text();
	var strSecondManagerCode = $("#selectSecondManagerInfo").attr("data-urcode");
	var strSecondManagerName = $("#selectSecondManagerInfo").text();
	var strJobNames = $("#txtProject").val();
	var strRole = $("#txtProjectRole").val();
	var strStatus = $("#selStatus").val();
	var strStartDate = $("#startdate_01").val();
	var strEndDate = $("#enddate_01").val();

	var iResult = validationCheck(strName,strFirstManagerName,strJobNames,strStartDate,strEndDate);

	if(iResult){		
		Common.Confirm(strText + "하시겠습니까?", "알림", function(result) {
			if(result) {
				$.post('workreportoutsourcingset.do', {
					mode : mode,
					urcode : strURCode,
					name : strName,
					grade : strGrade,
					age : strAge,
					fmCode : strFirstManagerCode,
					fmName : strFirstManagerName,
					smCode : strSecondManagerCode,
					smName : strSecondManagerName,
					jobName : strJobNames,
					role : strRole,
					status : strStatus,
					startdate : strStartDate,
					enddate : strEndDate
					
				}, function(d) {
					if(d.result == "success") {
						closeLayer("OutsourcingRegistPop");
						bindGridData();
					}
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("workreportoutsourcingset.do", response, status, error);
				});
			}
		});
	}
};

var validationCheck = function(pName,pManager,pJobName,pStartDate,pEndDate){

	// validation chk
	if(pName == "") {		
		Common.Inform("이름을 입력해 주세요.", "알림", function(){
			$("#txtName").focus();			
		});	
		return false;
	}	
	if(pManager == "") {
		Common.Inform("1차 담당자를 지정해 주세요.", "알림");
		return false;
	}
	if(pJobName == "") {
		Common.Inform("프로젝트를 입력해 주세요.", "알림");
		return false;
	}
	if(pStartDate == "" && pEndDate == "") {
		Common.Inform("계약기간을 지정해 주세요..", "알림");
		return false;
	}
	
	return true;
}


var osDelete = function() {
	var chkList = OsGrid.getCheckedList(0);
	var strChkList= "";
	chkList.forEach(function(data) {		
		strChkList += data.OUR_Code + ",";
	});
	
	strChkList = strChkList.substring(0,strChkList.length - 1);
	
	// 삭제
	Common.Confirm("삭제하시겠습니까?", "알림", function(result) {
		if(result) {
			$.post('workreportosdelete.do', {
				deleteIds : strChkList
			}, function(d) {
				// 최신목록을 보여주기위해 전체 Data Rebind
				OsGrid.reloadList();
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("workreportosdelete.do", response, status, error);
			});	
		}
	});
};

var closeLayer = function(pId) {
	Common.close(pId);
};

var openWorkReportList = function(pOUR_Code) {
	$("#divCalInfoList").empty();
	
	$.getJSON('getOSCalendarInfo.do', {OUR_Code : pOUR_Code}, function(d) {
		var result = d.result;
		$(result).each(function(idx, data) {
			var sHTML = "<div class='workReportListNode' onclick='osWorkReportPopOpen(" + data.WorkReportID + ", " + data.CalID + ", \"" + data.UR_Code + "\")'>"
			sHTML += "- " + data.Year + "년 " + XFN_AddFrontZero(data.Month, 2) + "월 " + data.WeekOfMonth + "주차</div>";
			$("#divCalInfoList").append(sHTML);
		});
		console.dir(d);
	});
	// oUR_Code를 통하여 등록된 주차코드 조회
	Common.open("", "osWorkReportListPop", "외주직원 업무보고 조회", "divWorkReportList", "300px", "330px", "id", true, null, null, true);
};

var osWorkReportPopOpen = function(wrid, calid, oUR_Code) {
	Common.open("", "osWorkReportPop", "업무보고", "viewWorkReport.do?wrid=" + wrid + "&calid=" + calid + "&uid=" + oUR_Code + "&isCors=Y", "1000px", "520px", "iframe", true, null, null, true);
};

$(function() {
	setGrid();
	bindOption();
	
	//진행상태 바인딩
	//B:진행전, I:진행중, C:완료)
	$("#selStatus").append("<option value='B' selected='selected'>진행전</option>");
	$("#selStatus").append("<option value='I'>진행중</option>");
	$("#selStatus").append("<option value='C'>완   료</option>");
	
	//등급 바인딩
	//selGrade

	var jQObj = $("#selGrade");
	$.getJSON("getOSGradeList.do", {}, function(d){	
		var listData = d.list;
	
		var name = "";
		$(listData).each(function(idx, data) {	
			switch(data.GradeKind.toString()){			
				case 'S' : name ="특급"; break;
				case 'H' : name ="고급"; break;
				case 'M' : name ="중급"; break;
				case 'N' : name ="초급"; break;				
			}
			jQObj.append("<option value='" + data.GradeKind.toString() + "'>" + name + "</option>");
		});
		
	}).error(function(response, status, error){
	     //TODO 추가 오류 처리
	     CFN_ErrorAjax("getOSGradeList.do", response, status, error);
	});	

	$("#chkEndcontract").change(function(){
		if($("#chkEndcontract").is(":checked")){
			$("#startdate").attr("disabled",true);
			$("#enddate").attr("disabled",true);
		}else{		
			$("#startdate").attr("disabled",false);
			$("#enddate").attr("disabled",false);
		}
	});
});

</script>