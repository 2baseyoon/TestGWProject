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
		<a id="printBtn" href="#" class="btnTypeDefault type02 " onclick="javascript:Print();" style="margin: 12px 0px; visibility: hidden;"><spring:message code='Cache.btn_print' /></a> 
		<span id="printMessage" class="col_red" style="display:none">
			※ <spring:message code='Cache.lbl_vacationMsg40' />
		</span>
	</div>
	<div class="formContent">
		<h2>미사용 연차 유급휴가 일수 알림 및 사용시기 지정 요청 <br>							
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
		<h3 class="mt25">연차 유급 휴가 일수</h3>
		<table class="tbl tblType02">
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
		<p class="mt35">
			${result.list[0].DisplayName}님께서
			<span class="dateField normalBaseDate" name="date1" kind="normal">${dateform.VacLimitOneFromForm}</span>
			<span class="dateField newEmpForNineBaseDate" name="date4" kind="newEmpForNine">${dateform.VacLimit091FromForm}</span>
			<span class="dateField newEmpForTwoBaseDate" name="date7" kind="newEmpForTwo">${dateform.VacLimit021FromForm}</span>
			현재까지 사용하지 않은 연차 유급휴가가 <span name="remindDays"></span>일임을 알려 드립니다.<br>
			<br>
			<span class="dateField" name="date2" kind="normal">${dateform.VacLimitOneToForm}</span>
			<span id="newEmpForNineDeadline" class="dateField" name="date5" kind="newEmpForNine">${dateform.VacLimit091ToForm}</span>
			<span id="newEmpForTwoDeadline" class="dateField" name="date8" kind="newEmpForTwo">${dateform.VacLimit021ToForm}</span>
			까지 (촉구를 받은 날로부터 <span kind="normal">${dateform.VacLimitOneDiffDays}</span><span kind="newEmpForNine">${dateform.VacLimit091DiffDays}</span><span kind="newEmpForTwo">${dateform.VacLimit021DiffDays}</span>일 이내) 미사용 연차 유급휴가의 사용시기를<br>
			지정한 후 첨부된 서식을 작성하여서 <span kind="normal" id="facilitatingSenderDept">인사팀</span> 으로 통보해주시기 바랍니다.<br>
			<br>
			${result.list[0].DisplayName}님께서 동 기한 내 첨부된 서식으로 미사용 연차 유급휴가의 사용시기를<br>
			지정하여 통보하지 않는 경우, 회사가 사용시기를 지정할 예정입니다.<br>
			<br>
			아울러, 회사의 사용촉구에도 불구하고, 연차 유급휴가를 사용하지 않을 경우에는<br>
			연차휴가미사용수당이 지급되지 않음을 알려드리오니, 연차 유급 휴가를 적극적으로<br>
			사용해주시기 바랍니다.<br>
			<br>
			<span class="dateField" name="date3" kind="normal">${dateform.VacLimitOneFromForm}</span>
			<span id="newEmpForNineSignDate" class="dateField" name="date6" kind="newEmpForNine">${dateform.VacLimit091FromForm}</span>
			<span id="newEmpForTwoSignDate" class="dateField" name="date9" kind="newEmpForTwo">${dateform.VacLimit021FromForm}</span>
			<br>
			<br>
			<span id="vacationPromotionSubject"></span>							
		</p>
		<h3 class="mt50">근로기준법 제61조 연차유급휴가의 사용촉진</h3>
		<p class="mt35">
			제61조(연차 유급휴가의 사용 촉진) ① 사용자가 제60조제1항ㆍ제2항 및 제4항에 따른 유급휴가(계속하여 근로한 기간이 1년 미만인 근로자의 제60조제2항에 따른 유급휴가는 제외한다)의 사용을 촉진하기 위하여 다음 각 호의 조치를 하였음에도 불구하고 근로자가 휴가를 사용하지 아니하여 제60조제7항 본문에 따라 소멸된 경우에는 사용자는 그 사용하지 아니한 휴가에 대하여 보상할 의무가 없고, 제60조제7항 단서에 따른 사용자의 귀책사유에 해당하지 아니하는 것으로 본다.  &lt;개정 2012. 2. 1., 2017. 11. 28., 2020. 3. 31.&gt; <br>
			1. 제60조제7항 본문에 따른 기간이 끝나기 6개월 전을 기준으로 10일 이내에 사용자가 근로자별로 사용하지 아니한 휴가 일수를 알려주고, 근로자가 그 사용 시기를 정하여 사용자에게 통보하도록 서면으로 촉구할 것 <br>
			2. 제1호에 따른 촉구에도 불구하고 근로자가 촉구를 받은 때부터 10일 이내에 사용하지 아니한 휴가의 전부 또는 일부의 사용 시기를 정하여 사용자에게 통보하지 아니하면 제60조제7항 본문에 따른 기간이 끝나기 2개월 전까지 사용자가 사용하지 아니한 휴가의 사용 시기를 정하여 근로자에게 서면으로 통보할 것 <br>
			② 사용자가 계속하여 근로한 기간이 1년 미만인 근로자의 제60조제2항에 따른 유급휴가의 사용을 촉진하기 위하여 다음 각 호의 조치를 하였음에도 불구하고 근로자가 휴가를 사용하지 아니하여 제60조제7항 본문에 따라 소멸된 경우에는 사용자는 그 사용하지 아니한 휴가에 대하여 보상할 의무가 없고, 같은 항 단서에 따른 사용자의 귀책사유에 해당하지 아니하는 것으로 본다.  &lt;신설 2020. 3. 31.&gt; <br>
			1. 최초 1년의 근로기간이 끝나기 3개월 전을 기준으로 10일 이내에 사용자가 근로자별로 사용하지 아니한 휴가 일수를 알려주고, 근로자가 그 사용 시기를 정하여 사용자에게 통보하도록 서면으로 촉구할 것. 다만, 사용자가 서면 촉구한 후 발생한 휴가에 대해서는 최초 1년의 근로기간이 끝나기 1개월 전을 기준으로 5일 이내에 촉구하여야 한다. <br>
			2. 제1호에 따른 촉구에도 불구하고 근로자가 촉구를 받은 때부터 10일 이내에 사용하지 아니한 휴가의 전부 또는 일부의 사용 시기를 정하여 사용자에게 통보하지 아니하면 최초 1년의 근로기간이 끝나기 1개월 전까지 사용자가 사용하지 아니한 휴가의 사용 시기를 정하여 근로자에게 서면으로 통보할 것. 다만, 제1호 단서에 따라 촉구한 휴가에 대해서는 최초 1년의 근로기간이 끝나기 10일 전까지 서면으로 통보하여야 한다. <br>
		</p>
	</div>		
</div>

<script>
	var year = ${result.list[0].YEAR};
	var urCode = '${result.list[0].UserCode}';
	var enterDate = '${result.list[0].EnterDate}';
	var vacPlan = '${result.list[0].VACPLAN}' == '' ? '' : $.parseJSON('${result.list[0].VACPLAN}');
	var remindDays = 0;
	
	var viewType = CFN_GetQueryString("viewType");
	var formType = CFN_GetQueryString("formType"); 	// plan/notification1/request/notification2
	var empType = CFN_GetQueryString("empType"); 	// normal/newEmp/newEmpForNine/newEmpForTwo
	var isAll = CFN_GetQueryString("isAll");

	var CreateMethod = vacation.getVacationCreateMethodConfigVal();
	initContent();

	function initContent() {
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

		//인사팀 부서 명칭 baseCode 기준 세팅
		var senderDeptNm = Common.getBaseConfig("FacilitatingSenderDept");
		if(senderDeptNm != null && senderDeptNm !== "") {
			$("#facilitatingSenderDept").html(senderDeptNm);
		}
	}
	
	function bindDateAndControl(){
		/*if(empType != "normal"){
			$("." + empType + "BaseDate").text(getBaseDate(enterDate));
			$("#" + empType + "SignDate").text(getBaseDate(enterDate));
			$("#" + empType + "Deadline").text(getDeadline(enterDate));
		}*/
		
		if(viewType == "admin"){
			vacation.bindDateFieldEvent(".dateField");
		}
		
		$("#vacationPromotionSubject").text(Common.getBaseConfig("VacationPromotionSubject"));
	
		//연차서식날짜 바인딩
		vacation.bindSavedDate(vacPlan);
		
		//기준일 잔여연차 가져오기
		var termDate = $("."+empType+"BaseDate").text();
		termDate = strToDate(vacation.changeDateFormat(termDate,false)).format("yyyyMMdd");

		if(CreateMethod=="J"){
			vacation.getVacationInfoV2(termDate, empType);
		}else{
			vacation.getVacationInfo(termDate, empType);
		}
		
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
	function getDeadline(strEnterDate){
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
