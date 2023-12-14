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
			연차 유급휴가 사용시기 지정 통보서<br>
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
			<span class="dateField normalBaseDate" name="date1" kind="normal">${dateform.VacLimitOneFromForm}</span>
			<span class="dateField newEmpForNineBaseDate" name="date3" kind="newEmpForNine">${dateform.VacLimit091FromForm}</span>
			<span class="dateField newEmpForTwoBaseDate" name="date5" kind="newEmpForTwo">${dateform.VacLimit021FromForm}</span>
			현재까지 사용하지 않은 연차 유급휴가 <span name="remindDays"></span>일에 대하여 아래와 같이 <br>
			사용시기를 지정하여 통보합니다.
		</p>
		<h3 class="mt50">미사용 연차 유급 휴가 일수</h3>
		<table class="tbl tblType02" >
			<colgroup>
				<col width="144">
				<col width="144">
				<col width="144">
			</colgroup>
			<tbody>
				<tr>
					<th class="bg"><spring:message code='Cache.lbl_occurrenceYear' /></th>
					<th class="bg "><spring:message code="Cache.lbl_UseVacation" /></th>
					<th class="bg "><spring:message code="Cache.lbl_RemainVacation" /></th>
				</tr>
				<tr>
					<td><span name="ownDays"></span></td>
					<td><span name="useDays"></span></td>
					<td><span name="remindDays"></span></td>
				</tr>
			</tbody>
		</table>
		<h3 class="mt30">미사용 연차 유급 휴가 사용시기 지정 통보내역 (월별 날짜 기재, 추후 변경 가능)</h3>
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
		<p class="mt30" >
			<span class="dateField" name="date2" kind="normal">${dateform.VacLimitOneToForm}</span>
			<span id="newEmpForNineSignDate" class="dateField" name="date4" kind="newEmpForNine">${dateform.VacLimit091ToForm}</span>
			<span id="newEmpForTwoSignDate" class="dateField" name="date6" kind="newEmpForTwo">${dateform.VacLimit021ToForm}</span>
		</p>
		<p class="mt30"> 본인확인 : ${result.list[0].DisplayName}는(은) 미사용 연차유급휴가 사용시기 지정통보에 대하여 본인확인하고 승인 하였습니다.</p>
		<p class="mt25" style="text-align:right;"> 
			<span class="mr50">통보자 :</span> 
			<span class="mr40">${result.list[0].DisplayName}</span> 
			(서명) <b><i>${result.list[0].DisplayName}</i></b> 
		</p>
		<p class="mt25"><span id="vacationPromotionSubject"></span>&nbsp;귀중 </p>
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
			if( remindDays <= 0){
				Common.Warning("<spring:message code='Cache.msg_vacation_no_remindDay'/>", "Warning", function(){
					if(viewType == "user"){
						window.close();
					}
				});
			}
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
		/*if(empType != "normal"){
			$("." + empType + "BaseDate").text(getBaseDate(enterDate));
			
			$("#" + empType + "SignDate").text(getSignDate(enterDate));
		}*/
		
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
		termDate = strToDate(vacation.changeDateFormat(termDate,false)).format("yyyyMMdd");
		if(CreateMethod=="J"){
			vacation.getVacationInfoV2(termDate, empType);
		}else {
			vacation.getVacationInfo(termDate, empType);
		}
		/*if (empType != "normal" && vacPlan["ownDays"] != undefined){//입력된 시점의 발생건수로 변경
			$("span[name='ownDays']").text(vacPlan["ownDays"]);
			//$("span[name='remindDays']").text(parseFloat(vacPlan["ownDays"])-(parseFloat($("span[name='useDays']").text())));
			$("span[name='useDays']").text(parseFloat(vacPlan["ownDays"])-parseFloat($("span[name='remindDays']:eq(0)").text()));
		}*/


	}
	
	// 1년미만자 9일(newEmpForNine): 입사일로부터 만 9개월+1일 (EX) 4/1입사자 - 차년 1/1일
	// 1년미만자 2일(newEmpForTwo): 입사일로부터 만 11개월+1일 (EX) 4/1입사자 - 차년 3/1일
	function getBaseDate(strEnterDate){
		if(strEnterDate == undefined || strEnterDate == ""){
			return  "";
		}
	
		var addMonth = (empType == "newEmpForNine" ? 9 : 11);
		
		var enterDate = strToDate(strEnterDate);
		var currentMonth = enterDate.getMonth();
		var currentDate = enterDate.getDate();
		
		enterDate.setMonth(currentMonth + addMonth, currentDate);

	    if (enterDate.getMonth() > ((currentMonth + addMonth) % 12)) {
	    	enterDate.setDate(1);
	    }
	    
	    return enterDate.format("yyyy년 MM월 dd일");
	}
	
	// 1년미만자 9일(newEmpForNine): 입사일로부터 만 9개월+10일 (EX) 4/1입사자 - 차년 1/10일
	// 1년미만자 2일(newEmpForTwo): 입사일로부터 만 11개월+5일 (EX) 4/1입사자 - 차년 3/5일
	function getSignDate(strEnterDate){
		if(strEnterDate == undefined || strEnterDate == ""){
			return  "";
		}
	
		var addMonth = (empType == "newEmpForNine" ? 9 : 11);
		
		var enterDate = strToDate(strEnterDate);
		var currentMonth = enterDate.getMonth();
		var currentDate = enterDate.getDate();
		
		enterDate.setMonth(currentMonth + addMonth, currentDate);

	    if (enterDate.getMonth() > ((currentMonth + addMonth) % 12)) {
	    	enterDate.setDate(1);
	    }
	    
	    enterDate.setDate(enterDate.getDate() + 9);
	    
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
