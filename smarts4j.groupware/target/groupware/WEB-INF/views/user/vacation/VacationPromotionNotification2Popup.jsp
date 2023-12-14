<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/vacation.js<%=resourceVersion%>"></script> 
  
 <style type='text/css'>
     @media print {
         .noprint {
             display: none;
         }
     }
 </style>
 
<div id="wrap" class="formVeiw formVeiw01" style="overflow:inherit;">
	<div class="formHeader noprint" >
		<a href="#" class="btnTypeDefault type02" onclick="vacation.openVacationUsePlanDetailPopup()" ><spring:message code='Cache.lbl_apv_AnnaulUseTerm' /></a>
		<a id="printBtn" href="#" class="btnTypeDefault type02 " onclick="javascript:Print();" style="visibility: hidden;"><spring:message code='Cache.btn_print' /></a> 
		<span id="printMessage" class="col_red" style="display:none">
			※ <spring:message code='Cache.lbl_vacationMsg40' />
		</span>
	</div>
	<div class="formContent">
		<h2>
			미사용 연차 유급휴가 사용시기 지정 통보<br>
			<span style="font-size:20px">&lt;근로기준법 제61조 (연차 유급휴가의 사용촉진) 관련&gt;</span>						
		</h2>
		<h3>대상 근로자</h3>
		<table class="tbl tblType02">
			<colgroup>
				<col width="100">
				<col width="">
				<col width="100">
				<col width="">
				<col width="100">
				<col width="">
			</colgroup>
			<tbody>
				<tr>
					<th class="bg"><spring:message code='Cache.lbl_User_DisplayName' /></th>
					<td>${result.list[0].DisplayName}</td>
					<th class="bg"><spring:message code='Cache.lbl_Postion' /></th>
					<td>${result.list[0].DeptName}</td>
					<th class="bg"><spring:message code="Cache.lbl_JobLevel" /></th>
					<td>${result.list[0].JobPositionName}</td>
					<th class="bg"><spring:message code="Cache.lbl_EnterDate" /></th>
					<td>${result.list[0].EnterDate}</td>
				</tr>
			</tbody>
		</table>
		<p class="mt35">
			${result.list[0].DisplayName}님의 미사용 연차(${result.list[0].OWNDAYS}) 유급휴가의 사용시기 미통보에 따라, 부득이 사용시기를 아래와 같이 지정하여 통보드리오니, <br>
			지정된 날짜에 연차 유급휴가를 반드시 사용하시기 바랍니다. <br>
			 <br>
			※ 만약, 지정된 날짜에 연차 유급휴가를 사용하지 않은 경우에는 연차 유급휴가가 소멸되더라도  <br>
			연차미사용수당은 지급되지 않음을 알려 드립니다. <br>						
		</p>
		<h3 class="mt50">미사용 연차 유급휴가 사용시기 지정</h3>
		<table class="tbl tblType02">
			<colgroup>
				<col width="80">
				<col width="295">
				<col width="80">
				<col width="80">
				<col width="295">
				<col width="80">
			</colgroup>
			<tbody id="monthly_tbody">
			</tbody>
		</table>
		<p class="mt30"> 본인확인 : ${result.list[0].DisplayName}는(은) 미사용 연차유급휴가 사용시기 지정통보에 대하여 본인확인하고 승인 하였습니다.</p>
		<p class="mt30">
			<span class="dateField normalBaseDate" name="date1" kind="normal">${dateform.VacLimitTwoFrom}</span>
			<span id="newEmpForNineSignDate" class="dateField newEmpForNineBaseDate" name="date2" kind="newEmpForNine">${dateform.VacLimit092Form}</span>
			<span id="newEmpForTwoSignDate" class="dateField newEmpForTwoBaseDate" name="date3" kind="newEmpForTwo">${dateform.VacLimit022Form}</span>
		</p>
		<p class="mt25"><span id="vacationPromotionSubject"></span> </p>
	</div>	
	<!-- 연차 사용시기  입력에서 조회하는 값-->
	<div style="display:none;">
		<span name="ownDays">${result.list[0].OWNDAYS}</span>
		<span name="useDays">${result.list[0].USEDAYS}</span>
		<span name="remindDays">${result.list[0].REMINDDAYS}</span>
	</div>	
</div>

<script>
	var year = ${result.list[0].YEAR};
	var urCode = '${result.list[0].UserCode}';
	var enterDate = '${result.list[0].EnterDate}';
	var vacPlan = '${result.list[0].VACPLAN}' == '' ? '' : $.parseJSON('${result.list[0].VACPLAN}');
	var remindDays = 0;
	var rangeYear = '${result.list[0].NOWYEAR}';
	var arrRangeDate = rangeYear.split("~");
	var rangeDateFrom = arrRangeDate[0].replace(" ","");
	var rangeDateTo = arrRangeDate[1].replace(" ","");
	var dateRangeFrom = new Date(rangeDateFrom.replace("-","/").replace("-","/"));
	var dateRangeTo = new Date(rangeDateTo.replace("-","/").replace("-","/"));
	
	var viewType = CFN_GetQueryString("viewType");
	var formType = CFN_GetQueryString("formType"); 	// plan/notification1/request/notification2
	var empType = CFN_GetQueryString("empType"); 	// normal/newEmp/newEmpForNine/newEmpForTwo
	var isAll = CFN_GetQueryString("isAll");

	var CreateMethod = vacation.getVacationCreateMethodConfigVal();
	initContent();
	
	function initContent() {
		printMonthlyTbody();
		$("*[kind][kind!='" + empType + "']").hide();
		
		if(viewType == "admin"){	
			$("#printBtn").css('visibility', 'visible');
			$("#printMessage").show(); 
		}
		
		bindDateAndControl();
		 
		if(isAll == "Y"){
			Print();
		}else{
			/*if( remindDays <= 0){
				Common.Warning("<spring:message code='Cache.msg_vacation_no_remindDay'/>", "Warning", function(){
					if(viewType == "user"){
						window.close();
					}
				});
			}*/
		}
	}


	function printMonthlyTbody(){
		var html = "";
		html += "<tr>";
		html += "	<th class=\"bg \"><spring:message code="Cache.lbl_Gubun" /> </th>";
		html += "	<th class=\"bg \">사용시기 지정일</th>";
		html += "	<th class=\"bg \">사용일수</th>";
		html += "	<th class=\"bg\"><spring:message code="Cache.lbl_Gubun" /> </th>";
		html += "	<th class=\"bg \">사용시기 지정일</th>";
		html += "	<th class=\"bg \">사용일수</th>";
		html += "</tr>";
		if(CreateMethod==="F") {
			for (var i = 1; i <= 6; i++) {
				html += "<tr>";
				html += "	<td>" + i + "월</td>";
				html += "	<td month=\"" + i + "\" name=\"monthTd\"></td>";
				html += "	<td month=\"" + i + "\" name=\"monthCntTd\"></td>";
				html += "	<td>" + (i + 6) + "월</td>";
				html += "	<td month=\"" + (i + 6) + "\" name=\"monthTd\"></td>";
				html += "	<td month=\"" + (i + 6) + "\" name=\"monthCntTd\"></td>";
				html += "</tr>";
			}
		}else{//입사일기준
			var enterDate = "${result.list[0].EnterDate}";
			var arrEnterDate = enterDate.split("-");
			var mon = Number(arrEnterDate[1]);
			var year = "";
			for (var i=1; i <= 6; i++) {
				var m = mon+(i-1);
				if(m>12){
					year = dateRangeTo.getFullYear();
					m = m%12;
					html += "<tr>";
					html += "	<td>"+year+"년 "+ m%12 + "월</td>";
					html += "	<td year=\""+year+"\" month=\"" + m%12 + "\" name=\"monthTd\"></td>";
					html += "	<td year=\""+year+"\" month=\"" + m%12 + "\" name=\"monthCntTd\"></td>";
					html += "	<td>"+year+"년 " + (m + 6)%12 + "월</td>";
					html += "	<td  year=\""+year+"\"month=\"" + (m + 6)%12 + "\" name=\"monthTd\"></td>";
					html += "	<td year=\""+year+"\" month=\"" + (m + 6)%12 + "\" name=\"monthCntTd\"></td>";
					html += "</tr>";
				}else {
					year = dateRangeFrom.getFullYear();
					html += "<tr>";
					html += "	<td>"+year+"년 "+ m + "월</td>";
					html += "	<td year=\""+year+"\" month=\"" + m + "\" name=\"monthTd\"></td>";
					html += "	<td year=\""+year+"\" month=\"" + m + "\" name=\"monthCntTd\"></td>";
					if((m+6)>12){
						m = (m+6)-18;
						year = dateRangeTo.getFullYear();
					}
					html += "	<td>"+year+"년 "+ (m + 6) + "월</td>";
					html += "	<td year=\""+year+"\" month=\"" + (m + 6) + "\" name=\"monthTd\"></td>";
					html += "	<td year=\""+year+"\" month=\"" + (m + 6) + "\" name=\"monthCntTd\"></td>";
					html += "</tr>";
				}
			}
			if(new Date(enterDate.replace("-","/").replace("-","/")) !== new Date(arrEnterDate[0],arrEnterDate[1],0)){//입사일이 월중 마지막일이 아니면 입사일기준시 추가 월 필요
				html += "<tr>";
				html += "	<td colspan=\"3\" style='background-color: #eeeeee;'></td>";
				html += "	<td>"+dateRangeTo.getFullYear()+"년 "+ Number(arrEnterDate[1]) + "월</td>";
				html += "	<td year=\""+dateRangeTo.getFullYear()+"\" month=\"" + Number(arrEnterDate[1]) + "\" name=\"monthTd\"></td>";
				html += "	<td year=\""+dateRangeTo.getFullYear()+"\" month=\"" + Number(arrEnterDate[1]) + "\" name=\"monthCntTd\"></td>";
				html += "</tr>";
			}
		}
		$("#monthly_tbody").html(html);
	}

	function bindDateAndControl(){
		if(empType != "normal"){
			$("#" + empType + "SignDate").text(getSignDate(enterDate));
		}
		
		if(viewType == "admin"){
			vacation.bindDateFieldEvent(".dateField");
		}
		
		$("#vacationPromotionSubject").text(Common.getBaseConfig("VacationPromotionSubject"));
		
		//연차서식날짜 바인딩
		vacation.bindSavedDate(vacPlan);
		
		//연차사용계획 바인딩
		//20210726 nkpark 회사 휴무일 등록데이터 기준 휴가 사용일수 체크 예외 처리 추가
		var jsonOffDaysList = '${offDaysList.dayOffList}' == '' ? '' : JSON.stringify('${offDaysList.dayOffList}');
		//기존:vacation.bindSavedPlan(vacPlan, jsonOffDaysList);
		if(CreateMethod=="J") {
			vacation.bindSavedPlanV2(vacPlan, jsonOffDaysList);
		}else{
			vacation.bindSavedPlan(vacPlan, jsonOffDaysList);
		}
		//-->
		
		//기준일 잔여연차 가져오기
		var termDate = $("."+empType+"BaseDate").text();
		termDate = strToDate(termDate).format("yyyyMMdd");

		if(CreateMethod=="J"){
			vacation.getVacationInfoV2(termDate);
		}else {
			vacation.getVacationInfo(termDate);
		}
	}
	
	// 1년미만자 9일(newEmpForNine): 입사일로부터 만 11개월 (EX) 4/1입사자 - 차년 2/28일							
	// 1년미만자 2일(newEmpForTwo): 입사일로부터 만 12개월 - 10일 (EX) 4/1입사자 - 차년 3/21일
	function getSignDate(strEnterDate){
		if(strEnterDate == undefined || strEnterDate == ""){
			return  "";
		}
	
		var addMonth = (empType == "newEmpForNine" ? 11 : 12);
		var minusDate = (empType == "newEmpForNine" ? 1 : 11);
		var enterDate = strToDate(strEnterDate);
		var currentMonth = enterDate.getMonth();
		var currentDate = enterDate.getDate();
		
		enterDate.setMonth(currentMonth + addMonth, currentDate);

	    if (enterDate.getMonth() > ((currentMonth + addMonth) % 12)) {
	    	enterDate.setDate(1);
	    }
	    
	    enterDate.setDate(enterDate.getDate() - minusDate);
	    
	    return enterDate.format("yyyy년 MM월 dd일");
	}
 	
	 // 인쇄
    function Print() {
        try {
            window.print();
        }
        catch (e) {
            alert(e.description);
        }
    }
	 
</script>
