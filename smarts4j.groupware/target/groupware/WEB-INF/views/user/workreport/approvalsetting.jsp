<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div>
	<h3 class="con_tit_box">
		<span class="con_tit">승인자 설정</span>
	</h3>
	
	<!-- 상단 필터 -->
	<div id="inputBoxWrap" style="text-align:right;">
		<div style='text-align:left; margin-bottom : 5px;'>
			<button type="button" id="btnDelete" class="AXButton">삭제</button>
		</div>
		<div style="display:inline-block; float:left;">
			<button type="button" id="btnRefresh" class="AXButton" style='margin-right : 10px;'>새로고침</button>
			<label>팀명 : </label>
			<!-- MARK 권한 사용자에게만 조직도 버튼 바인딩 (차후 필요한 작업) -->
			<span>
				<input type="text" class="AXInput W120 HtmlCheckXSS ScriptCheckXSS" id="selTeamName" style='margin-right:10px; display:inline-block; width:120px;' data-code=""></span>
				<input id="btnOrgMap" type="button" class="AXButton" value="<spring:message code='Cache.lbl_DeptOrgMap'/>" />
			</span>
			
			<button type="button" id="btnSearch" class="AXButton">조회</button>
			
			
		</div>
		<div style="display:inline-block">
			<span style="font-size:12px;">승인자 추가 : </span> 
			<input type="text" id="txtApproval" class="AXInput W200" style="padding:0px!important; text-align:center;" readonly data-urcode="" data-grcode="" />
			<input id="btnOrgMapApproval" type="button" class="AXButton" value="<spring:message code='Cache.lbl_DeptOrgMap'/>" />
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
	
	
	var orgCallBackMethod = function(data) {
		var jsonData = $.parseJSON(data);
		
		if(jsonData.item.length > 0) {
			var selGRCode = jsonData.item[0].AN;
			var selGRName = CFN_GetDicInfo(jsonData.item[0].DN);
			
			$("#selTeamName").val(selGRName).attr("data-code", selGRCode);
			
			// data rebind
			// setData();
		}
	};
	
	var orgCallBackMethodApproval = function(data) {
		var jsonData = $.parseJSON(data);
				
		if(jsonData.item.length > 0) {		
			var selURName = CFN_GetDicInfo(jsonData.item[0].DN);
			var selURCode = jsonData.item[0].AN;
			var selGRCode = jsonData.item[0].RG;
			var selGroupName = CFN_GetDicInfo(jsonData.item[0].RGNM);
			
			$("#txtApproval").val("[" + selGroupName + "] " + selURName).attr("data-urcode", selURCode).attr("data-grcode", selGRCode);
			
			// data rebind
			// setData();
		}
	};	
		
	
	// 삽입
	var insertApproverSetting = function() {
		var approverUserCode = $("#txtApproval").attr('data-urcode');
		var approverGroupCode = $("#txtApproval").attr('data-grcode');
		
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		if(approverUserCode == "" || approverGroupCode == "") {
			Common.Inform("등록할 사용자가 선택되지 않았습니다.", "알림");
			return 0;
		}
		
		Common.Confirm("등록하시겠습니까?", "확인", function(result) {
			
			if(result) {
				
				$.post("InsertApproverSetting.do", {
					"urCode" : approverUserCode,
					"grCode" : approverGroupCode
				}, function(d) {
					var resultObj = d.result;
					
					if(resultObj.result == "OK") {
						// 성공
					} else if (resultObj.result == "EXIST") {
						// 중복
						Common.Inform("이미 추가된 사용자입니다.", "알림");
					} else {
						// 실패
						Common.Inform("입력에 실패했습니다. 관리자에게 문의해주세요", "알림");
					}
					
					$("#txtApproval").val("").attr("data-urcode", "").attr("data-grcode", "");
					
					// data rebind
					myGrid.reloadList();
					
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("InsertApproverSetting.do", response, status, error);
				});
			}
		});
	};
	
	
	// 삭제
	var deleteApproverSetting = function() {
		var checkedList = myGrid.getCheckedList(0);
		var checkedStr = "";
		
		if(checkedList.length == 0) {
			Common.Inform("선택된 항목이 없습니다.", "알림");
			return false;
		}
		
		$(checkedList).each(function(idx, data){
			checkedStr += data.ApproverNo + ","
		});
		
		Common.Confirm("삭제하시겠습니까?", "확인", function(result) {
			if(result) {
				$.post("DeleteApproverSetting.do", {
					"checkedStr" : checkedStr
				}, function(result) {
					// data rebind
					myGrid.reloadList();
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("DeleteApproverSetting.do", response, status, error);
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
			                  {key:'urName',  label:'이름', width:'70', align:'center'},
			                  {key:'grName',  label:'부서', width:'70', align:'center'},
			                ]);
		setGridConfig();
		bindGridData();
	}
	
	
	function bindGridData() {
		var strGrCode = $("#selTeamName").attr("data-code");
		
		myGrid.bindGrid({
			ajaxUrl:"GetApproverSetting.do",
			ajaxPars: {
				"grCode" : strGrCode
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
			sort : false,		// 정렬
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
		$("#btnOrgMap").on("click", function() {
			   Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=orgCallBackMethod&type=C1","1000px","580px","iframe",true,null,null,true);
		   });
		
		$("#btnOrgMapApproval").on("click", function() {
			   Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=orgCallBackMethodApproval&type=A1","520px","580px","iframe",true,null,null,true);
		   });
		
		
		// 저장
		$("#btnSave").on("click", insertApproverSetting);
		// 삭제
		$("#btnDelete").on("click", deleteApproverSetting);
		// 조회
		$("#btnSearch").on("click", function() {
			bindGridData();
		});
		// 새로고침
		$("#btnRefresh").on("click", function() {
			$("#selTeamName").val("").attr("data-code", "");
			bindGridData();
		});
		
		// Grid Draw
		setGrid();
	});
</script>