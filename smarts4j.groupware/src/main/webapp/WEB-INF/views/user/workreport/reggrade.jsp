<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div>
	<h3 class="con_tit_box">
		<span class="con_tit">정직원 단가 관리</span>
	</h3>
	
	<!-- 상단 필터 및 메뉴 -->
	<div style="width:100%; height:40px; margin-bottom: 10px;">
		<div style="display:inline-block;">
			<button type="button" id="btnAdd" class="AXButton" onclick="gradeAddOpen();"><spring:message code="Cache.btn_Add"></spring:message></button>
			<button type="button" id="btnCopy" class="AXButton" onclick="reUseRecentYear();">이전년도 단가 가져오기</button>
		</div>
	</div>
	
	<!-- 검색 바 -->
	<div>
		<input type="text" kind="date" date_selecttype="y" id="selYear" class="AXInput W100" data-axbind="date" onchange="bindGridData()" style="padding:0px!important;"/>
	</div>
	
	<!-- Grid -->
	<div id="resultBoxWrap" style="margin-top : 15px;">
		<div id="AXGridTarget"></div>
	</div>
	
	<div id="ModifyBtnBoxWrap" style="text-align:center; margin-top : 10px; display:none;">
		<button type="button" class="AXButton" id="btnModify"><spring:message code="Cache.btn_Modify"></spring:message></button>
		<button type="button" class="AXButton" id="btnDelete">삭제</button>
	</div>
	
	<div id="SaveBtnBoxWrap" style="text-align:center; margin-top:10px; display:none;">
		<button type="button" class="AXButton" id="btnSave">저장</button>
		<button type="button" class="AXButton" id="btnCancle">취소</button>
	</div>
</div>

<script>
	var osGradeGrid = new coviGrid();

	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		//myGrid.setGridHeader(headerData);
		osGradeGrid.setGridHeader([
			                  {key:'GradeKind',  label:'등급', width:'100', align:'center', formatter: function() {
			                	  var strResult = "";
			                	  switch(this.item.GradeKind) {
				                	  case "S" : strResult = "특급"; break;
				                	  case "H" : strResult = "고급"; break;
				                	  case "M" : strResult = "중급"; break;
				                	  case "B" : strResult = "초급2"; break;
				                	  case "N" : strResult = "초급1"; break;
			                	  }
			                	  return strResult;
			                  }},
			                  {key:'MonthPrice',  label:'MM단가', width:'100', align:'center', formatter:function() {
			                	  return '<input type="text" mode="moneyint" class="AXInput priceBox" id="mmAmount' + this.item.GradeKind + '" data-axbind="pattern" value="' + this.item.MonthPrice + '" readonly="true"  style="background : none; border:none;">';
			                  }},
			                  {key:'MonthPriceEx', label:'MD단가', width:'100', align:'center', formatter:function() {
			                	  return '<input type="text" mode="moneyint" class="AXInput priceBox" id="mdAmount' + this.item.GradeKind + '" data-axbind="pattern" value="' + this.item.DayPrice + '" readonly="true"  style="background : none; border:none;">';
			                  }}
				      		]);
		setGridConfig();
		bindGridData();
	}


	function bindGridData() {
		var year = $("#selYear").val();
		
		osGradeGrid.bindGrid({
			ajaxUrl:"getregulargrade.do",
			ajaxPars: {
				year : year
			},
			onLoad: function() {
				// paging 사용하지 않음
				$("#AXGridTarget_AX_gridPageBody").hide();
				
				// 1개 이상의 결과물이 있을때 버튼박스 활성화 및 이벤트 바인딩
				$("#btnCancle").off("click");
				$("#btnSave").off("click");
				$("#btnModify").off("click");
				$("#btnDelete").off("click");
				
				if(osGradeGrid.list.length > 0) {
					$("#ModifyBtnBoxWrap").show();
					$("#SaveBtnBoxWrap").hide();
					
					$("#btnModify").on("click", function() {
						$(".priceBox").prop("readonly", false)
									  .css({
										  "border" : "",
										  "background-color" : ""
									  });
						
						$("#ModifyBtnBoxWrap").hide();
						$("#SaveBtnBoxWrap").show();
						
						$("#btnSave").one("click", function() {
							// 각 등급별 MM단가, MD단가 값 읽어서  json parameter로 전송
							// list에 불러와진 Data기준으로 JSON 객체 생성
							var jsonArr = new Array();
							$(osGradeGrid.list).each(function(idx, data){
								var obj = {};
								obj.ApplyYear = data.ApplyYear;
								obj.GradeKind = data.GradeKind;
								obj.MonthPrice = new Number($("#mmAmount" + data.GradeKind).val().replace(/,/g, ''));
								obj.DayPrice = new Number($("#mdAmount" + data.GradeKind).val().replace(/,/g, ''));
								
								jsonArr.push(obj);
							});
							
							
							$.ajax({
								url : "ModRegularGrade.do",
								type : "POST",
								data : JSON.stringify(jsonArr),
								contentType : "application/json; charset=utf-8",
								dataType : "json",
								success : function(d) {
									if(d.cnt > 0)
										osGradeGrid.reloadList();
								},
								error : function(response, status, error){
								     //TODO 추가 오류 처리
								     CFN_ErrorAjax("ModRegularGrade.do", response, status, error);
								}
							});
						});
						
						$("#btnCancle").one("click", function() {
							$("#SaveBtnBoxWrap").hide();
							osGradeGrid.reloadList();
						});
					});
					
					$("#btnDelete").on("click", function() {
						Common.Confirm("삭제 하시겠습니까?", "알림", function(result) {
							if(result) {
								var year = $("#selYear").val();
								$.post("deleteregulargrade.do", {year : year}, function(d) {
									bindGridData();
								}).error(function(response, status, error){
								     //TODO 추가 오류 처리
								     CFN_ErrorAjax("deleteregulargrade.do", response, status, error);
								});	
							}
						});
					});
				} else {
					$("#ModifyBtnBoxWrap").hide();
					$("#SaveBtnBoxWrap").hide();
					
					$("#btnModify").off("click");
					$("#btnDelete").off("click");
				}
			}
		});
	}

	//Grid 설정 관련
	function setGridConfig(){
		var configObj = {
			targetID : "AXGridTarget",		// grid target 지정
			sort : false,		// 정렬
			colHeadTool : false,	// 컬럼 툴박스 사용여부
			fitToWidth : true,		// 자동 너비 조정 사용여부
			colHeadAlign : 'center',
			height:"auto",
			paging : false
		};
		
		// Grid Config 적용
		osGradeGrid.setGridConfig(configObj);
	}
	
	function gradeAddOpen() {
		Common.open("btnAdd", "GradeAddPop", "등급등록", "addGrade.do?mode=regular", "400px", "230px", "iframe", true, null, null, true);
	};
	
	function reUseRecentYear() {
		var currentYear = new Number($("#selYear").val());
		
		Common.Confirm((currentYear - 1) + "년도 단가로 해당년도 단가를 설정합니다.", "알림", function(result) {
			if(result) {
				$.post("reuseRegularGrade.do", {ApplyYear : currentYear}, function(d) {
					if(d.cnt == 0)
						Common.Inform("이전년도 단가가 존재하지 않습니다.", "알림");
					else 
						bindGridData();
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("reuseRegularGrade.do", response, status, error);
				});
			}
		});
	}
	
	$(function() {
		var now = new Date();
		$("#selYear").val(now.getYear() + 1900);
		
		setGrid();
	});
</script>