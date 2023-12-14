<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
</head>
<body>
	<!-- 등록 -->
	<div id="divRegistBox">
		<div style="padding:10px;">
			<table class="AXFormTable" id="tbGradeInfo">
			<colgroup>
				<col width="150px">
				<col width="100%">
			</colgroup>
			<tbody>
				<tr>
					<th>
						적용년도 
					</th>
					<td>
						<input type="text" kind="date" date_selecttype="y" id="selRegYear" class="AXInput W100" data-axbind="date" style="padding:0px!important;"/>
					</td>
				</tr>
				<tr>
					<th>
						등급
					</th>
					<td>
						<select id="selGrade">
							<option value="S">특급</option>
							<option value="H">고급</option>
							<option value="M">중급</option>
							<option value="N">초급1</option>
							<option value="B">초급2</option>
						</select>
					</td>
				</tr>
				<tr>
					<th>MM 단가</th>
					<td>
						<input type="text" mode="moneyint" class="AXInput" id="mmAmount" data-axbind="pattern">
					</td>
				</tr>
			</tbody>
		</table>
		
		<div align="center" style="padding-top: 10px">
			<input type="button" id="btnGradeRegist" value="추가" onclick="addSubmit();" class="AXButton">
			<input type="button" value="취소" onclick="closeLayer();" class="AXButton">
		</div>
		</div>
	</div>
	
	<script>
		var mode = "${mode}";
	
		var addSubmit = function() {
			
			// 해당 내용 등록 ( 이미 등록된 기준년에 등급일 시 Alert 보여주며 팝업은 종료하지 않음 )
			var year = $("#selRegYear").val();
			var grade = $("#selGrade").val();
			var mmAmount = new Number($("#mmAmount").val().replace(/,/g, ''));
			
			
			var mmExAmount = 0;
			var mdAmount = 0;

			// 외주일 경우 MM 지방 값 저장
			if(mode == "outsourcing") {
				
				mmExAmount = new Number($("#mmExAmount").val().replace(/,/g, ''));
			}
			else if(mode =="regular"){
				mdAmount = new Number($("#mdAmount").val().replace(/,/g, ''));
			}
			
			var seq = 0;
			
			switch(grade) {
				case 'S' : seq = 1; break;
				case 'H' : seq = 2; break;
				case 'M' : seq = 3; break;
				case 'N' : seq = 4; break;
				case 'B' : seq = 5; break;
			}
			
			// 등록
			Common.Confirm("등록하시겠습니까?", "알림", function(result) {
				if(result) {
					$.post('workreportosgraderegist.do', {
						year : year,
						memberType : mode.charAt(0).toUpperCase(),
						grade : grade,
						mmAmount : mmAmount,
						mmExAmount : mmExAmount,
						mdAmount : mdAmount,
						seq : seq
					}, function(d) {
						
						if(d.resultMsg == "EXIST") {
							Common.Inform("이미 등록된 단가가 존재합니다.", "알림");
						} else if(d.resultMsg == "OK") {
							Common.Inform("등록되었습니다.", "알림",function(){
								
								$("#selRegYear").val("");
								$("#selGrade")[0].selectedIndex = 0;
								$("#mmAmount").val("");
								
								if(mode == "outsourcing") {
									$("#mmExAmount").val("");
								}
								else if(mode == "regular") {
									$("#mdAmount").val("");
								}
								
								closeLayer();
								// 최신목록을 보여주기위해 부모 페이지 Data Rebind	
								parent.bindGridData();														
							});
							
						}
					}).error(function(response, status, error){
					     //TODO 추가 오류 처리
					     CFN_ErrorAjax("workreportosgraderegist.do", response, status, error);
					});	
				}
			});
		}
	
		var closeLayer = function() {
			parent.Common.close("GradeAddPop");
		}
		
		
		
		// DOM READY
		$(function() {
			// 외주직원 등급 등록 시 초급 코드는 N만 사용
			if(mode == "outsourcing") {
				$("#selGrade>option[value='B']").remove();
				$("#selGrade>option[value='N']").text("초급");
				
				// MM(지방) 입력 추가
				var sHTML = '<tr id="mmExAmountRow">';
				sHTML += '<th>MM 단가(출장)</th>';
				sHTML += '<td>';
				sHTML += '<input type="text" mode="moneyint" class="AXInput" id="mmExAmount" data-axbind="pattern">';
				sHTML += '</td>';
				sHTML += '</tr>';
				
				$("#tbGradeInfo>tbody").append(sHTML);
			}
			else if(mode == "regular"){
				// 정직원 등급 등록 시 MD 단가 사용
				// MD 입력 추가
				var sHTML = '<tr id="mdAmountRow">';
				sHTML += '<th>MD 단가</th>';
				sHTML += '<td>';
				sHTML += '<input type="text" mode="moneyint" class="AXInput" id="mdAmount" data-axbind="pattern">';
				sHTML += '</td>';
				sHTML += '</tr>';
				
				$("#tbGradeInfo>tbody").append(sHTML);				
			}
			else {
				
				// resize
				parent.Common.toResize("GradeAddPop", "400px", "190px");
			}
		});
	</script>
</body>
</html>