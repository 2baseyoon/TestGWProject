<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div>
	<h3 class="con_tit_box">
		<span class="con_tit">기준일(Workday) 설정</span>
	</h3>
	
	<!-- 상단 필터 -->
	<div id="inputBoxWrap" style="text-align:right;">
		<div style="display:inline-block; float:left;">
			<button type="button" id="btnRefresh" class="AXButton">새로고침</button>
			
			<span style="margin-left : 15px;">기준년도</span> 
			<input type="text" id="standardYear" kind="date" date_selecttype="y" id="AXInputDate3" class="AXInput W100" data-axbind="date" style="padding:0px!important;">
			
			<button type="button" id="btnSearch" class="AXButton">조회</button>
			
			<button type="button" id="btnDelete" class="AXButton" style="margin-left:15px;">삭제</button>
		</div>
		<div style="display:inline-block">
			<span style="font-size:12px;">적용 기준년월 :</span> 
			<input type="text" id="standardYM" kind="date" date_separator="-" date_selecttype="m" id="AXInputDate2" class="AXInput W120" data-axbind="date" style="padding:0px!important;">
			
			<input type="text" onkeyup="$(event.target).val($(event.target).val().replace(/[^0-9]/, ''));" id="txtWorkday" class="AXInput W100" placeholder="기준일">
					
			<button type="button" id="btnSave" class="AXButton">저장</button>
		</div>
	</div>

	<!-- Grid -->
	<div id="resultBoxWrap" style="margin-top : 15px;">
		<div id="AXGridTarget"></div>
	</div>
</div>

<script>

	// Grid 객체 생성
	var myGrid = new coviGrid();
	
	
	var validationCheck = function(yearMonth, workDay) {
		if(!(yearMonth.length > 0)) {
			Common.Inform("기준년월을 선택하세요.", "알림");
			return false;	
		}
		
		if(!(workDay.length > 0)) {
			Common.Inform("기준일을 입력해 주세요.", "알림");
			return false;	
		}
		
		workDay = new Number(workDay);

		var strYear = yearMonth.split('-')[0];
		var iMonth = new Number(yearMonth.split('-')[1]);
		
		var dtInput = new Date();
		dtInput.setYear(strYear);
		dtInput.setMonth(iMonth);	// 마지막날을 계산하기 위해 입력된 월을 그대로 삽입
		dtInput.setDate(1);
		
		dtInput.setDate(dtInput.getDate() - 1);
		
		if(workDay<1 || workDay>dtInput.getDate()) {
			Common.Inform("해당하신 기준년월에 지정할 수 있는 최대 일 수 는 " + dtInput.getDate() + "일 입니다.", "알림");
			return false;
		}
	
		return true;
	}
	
	
	var resetControl = function() {
		$("#standardYM").val("");
		$("#txtWorkday").val("");
	}
	
	
	// 삽입
	var insertWorkDaySetting = function() {
		var yearMonth = $("#standardYM").val();
		var workDay = $("#txtWorkday").val();
		
		if(!validationCheck(yearMonth, workDay)) {
			return false;
		}
		
		var strYear = yearMonth.split('-')[0];
		var strMonth = yearMonth.split('-')[1];
		
		
		Common.Confirm("등록하시겠습니까?", "확인", function(result) {
			
			if(result) {
				
				$.post("InsertWorkDaySetting.do", {
					"year" : strYear,
					"month" : strMonth,
					"workDay" : workDay
				}, function(d) {
					var resultObj = d.result;
					
					if(resultObj.result == "OK") {
						// 성공
					} else if (resultObj.result == "EXIST") {
						// 중복
						Common.Inform("이미 입력된 기준년월입니다.", "알림");
					} else {
						// 실패
						Common.Inform("입력에 실패했습니다. 관리자에게 문의해주세요", "알림");
					}
					
					// control 초기화
					resetControl();
					// data rebind
					myGrid.reloadList();
					
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("InsertWorkDaySetting.do", response, status, error);
				});
			}
		});
	};
	
	
	// 수정
	var updateWorkDaySetting = function(target, year, month, workday) {
		
		month = XFN_AddFrontZero(month, 2);
		
		Common.Prompt("수정하실 기준일을 입력해주세요", workday, "확인", function(result) {
			if(!validationCheck(year + "-" + month, result.toString())) {
				return false;
			}
			
			if(result != workday) {
				$.post("UpdateWorkDaySetting.do", {
					"year" : year,
					"month" : month,
					"workDay" : result
				}, function(d) {
					// 중복
					Common.Inform("정상적으로 수정되었습니다.", "알림");
					// data rebind
					myGrid.reloadList();
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("UpdateWorkDaySetting.do", response, status, error);
				});
			}
		});
	};
	
	// 삭제
	var deleteWorkDaySetting = function() {
		var checkedList = myGrid.getCheckedList(0);
		var checkedStr = "";
		$(checkedList).each(function(idx, data){
			checkedStr += data.year + data.month + ","
		});
		
		Common.Confirm("삭제하시겠습니까?", "확인", function(result) {
			if(result) {
				$.post("DeleteWorkDaySetting.do", {
					"checkedStr" : checkedStr
				}, function(result) {
					// data rebind
					myGrid.reloadList();
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("DeleteWorkDaySetting.do", response, status, error);
				});
			}
		});
	};
	
	
	
	// Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		//myGrid.setGridHeader(headerData);
		myGrid.setGridHeader([
			                  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
			                  {key:'year',  label:'년도', width:'70', align:'center'},
			                  {key:'month',  label:'월', width:'70', align:'center'},
			                  {key:'workday', label:'기준일', width:'70', align:'center',
			                	  formatter : function() {
			                		  return '<a href=\'#\' onclick=\'updateWorkDaySetting(this,' 
			                				  + this.item.year + ',' + this.item.month + ','
			                				  + this.item.workday + ')\'>' 
			                				  + this.item.workday + '</a>';
			                	  }},
			                  {key:'registdate',  label:'등록일' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', 
			                   formatter : function() {
			                	   return CFN_TransLocalTime(this.item.registdate, "yyyy-MM-dd");
			                   }},
			                  {key:'modifydate', label:'수정일' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', 
			                   formatter : function() {
			                	   var dateStr = this.item.modifydate;
			                	   
			                	   if(dateStr != ""){
				                	   return CFN_TransLocalTime(dateStr, "yyyy-MM-dd");
			                	   }else{
			                		   return "-";
			                	   }	   
			                	   	   
			                   }}
				      		]);
		setGridConfig();
		bindGridData();
	}
	
	
	function bindGridData() {
		var strYear = $("#standardYear").val();
		
		myGrid.bindGrid({
			ajaxUrl:"GetWorkDaySetting.do",
			ajaxPars: {
				"year" : strYear
			},
			onLoad:function () {
			    myGrid.fnMakeNavi("myGrid");
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
		myGrid.setGridConfig(configObj);
	}
	
	
	
	
	
	// DOM READY
	$(function() {
		
		// 저장
		$("#btnSave").on("click", insertWorkDaySetting);
		// 삭제
		$("#btnDelete").on("click", deleteWorkDaySetting);
		// 조회
		$("#btnSearch").on("click", function() {
			bindGridData();
		});
		// 새로고침
		$("#btnRefresh").on("click", function() {
			$("#standardYear").val("");
			myGrid.clearSort();
			bindGridData();
		});
		
		// Grid Draw
		setGrid();
	});
</script>