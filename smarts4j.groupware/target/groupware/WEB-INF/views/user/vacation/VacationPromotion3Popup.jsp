<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

 <style type='text/css'>
     @media print {
         .noprint {
             display: none;
         }
     }
 </style>

<div id="wrap" class="formVeiw formVeiw01" style="overflow:inherit;">
	<div class="formHeader noprint">
		<a href="#" class="btnTypeDefault type02" onclick="openVacationUsePlanDetailPopup()" ><spring:message code='Cache.lbl_apv_AnnaulUseTerm' /></a>
		<a href="#" class="btnTypeDefault type02 " id="printBtn" onclick="javascript:Print();" style="visibility: hidden;"><spring:message code='Cache.btn_print' /></a>
		<span id="printMessage" class="col_red" style="display:none;">
			※ <spring:message code='Cache.lbl_vacationMsg40' />
		</span>
	</div>
	<div class="formContent">
		<h2><spring:message code='Cache.lbl_vacation_fixNotice'/>&nbsp;(<spring:message code='Cache.lbl_vacation_third'/>)</h2> <%-- 연차휴가 사용촉진 지정통보 (3차)  --%>
		<h3><spring:message code='Cache.lbl_userInformation' /></h3>
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
					<th class="bg alignLeft"><spring:message code='Cache.lbl_User_DisplayName' /></th>
					<td>${result.list[0].DisplayName}</td>
					<th class="bg alignLeft"><spring:message code='Cache.lbl_Postion' /></th>
					<td>${result.list[0].DeptName}</td>
					<th class="bg alignLeft"><spring:message code='Cache.lbl_notificationDate' /></th>
					<td>${result.list[0].YEAR}.09.30</td> <!-- 경영관리팀 요청사항: 서식의 기한은 1차 1/31, 2차 6/10로 고정 , 3차는 9/30-->
				</tr>
			</tbody>
		</table>
		<p class="mt35">
			귀하의 ${result.list[0].YEAR}년 미사용 연차휴가를 아래와 같이 지정하여 통보하오니, 적극적으로 사용하시기 바라며, 
			<br>
			사용하지 아니할 경우 근로기준법 제61조에 의거 귀하의 연차휴가와 수당은 소멸되오니 이점 참고하시기 바랍니다. 
		</p>
		<p class="mt35">- 아 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;래 - </p>
		<h3 class="mt25"><spring:message code='Cache.lbl_annualLeaveDetails' /></h3>
		<table class="tbl tblType02">
			<colgroup>
				<col width="238">
				<col width="238">
				<col width="144">
				<col width="144">
				<col width="144">
			</colgroup>
			<tbody>
				<tr>
					<th class="bg "><spring:message code='Cache.lbl_annualLeaveTargetPeriod' /></th>
					<th class="bg "><spring:message code='Cache.lbl_annualLeaveTargetPeriod2' /></th>
					<th class="bg"><spring:message code='Cache.lbl_occurrenceYear' /></th>
					<th class="bg "><spring:message code="Cache.lbl_UseVacation" /></th>
					<th class="bg "><spring:message code="Cache.lbl_RemainVacation" /></th>
				</tr>
				<tr>
					<td>${result.list[0].YESTERYEAR}</td>
					<td>${result.list[0].NOWYEAR}</td>
					<td><span name="ownDays">${result.list[0].OWNDAYS}</span></td>
					<td><span name="useDays">${result.list[0].USEDAYS}</span></td>
					<td><span name="remindDays">${result.list[0].REMINDDAYS}</span></td>
				</tr>
			</tbody>
		</table>					
		<table class="tbl tblType02 mt25">
			<colgroup>
				<col width="100">
				<col width="810">
			</colgroup>
			<tbody id="vacationList">
				<tr>
					<th id="titleTD" rowspan="4" class="bg">휴가 지정일</th>
					<td></td>
				</tr>
			</tbody>
		</table>		
		<p class="tit mt20">근로기준법 제61조 연차유급휴가의 사용촉진</p>
		<div class="notTxtBox mt10">
			<p>
				사용자가 제60조제1항·제3항 및 제4항에 따른 유급휴가의 사용을 촉진하기 위하여 다음 각 호의 조치를 하였음에도 불구하고 근로자가 휴가를 사용하지 
				아니하여 제60조제7항 본문에 따라 소멸된 경우에는 사용자는 그 사용하지 아니한 휴가에 대하여 보상할 의무가 없고, 제60조제7항 단서에 따른 사용자의 
				귀책사유에 해당하지 아니하는 것으로 본다. 
			</p>
			<p>
			</p>
			<p class="mt20">
				1. 제60조제7항 본문에 따른 기간이 끝나기 6개월 전을 기준으로 10일 이내에 사용자가 근로자별로 사용하지 아니한 휴가 일수를 알려주고, 근로자가 그 사용시기를 정하여 사용자에게 통보하도록 서면으로 촉구할 것
			</p>
			<p>
			</p>
			<p class="mt10">
				<strong>
					2. 제1호에 따른 촉구에도 불구하고 근로자가 촉구를 받은 때부터 10일 이내에 사용하지 아니한 휴가의 전부 또는 일부의 사용 시기를 정하여 사용자에게 통보하지 아니하면 제60조제7항 본문에 따른 기간이 끝나기 2개월 전까지 사용자가 사용하지 아니한 휴가의 사용 시기를 정하여 근로자에게 서면으로 통보할 것
				</strong>
			</p>
			<p>
			</p>
			<div>
			</div>		
		</div>
		<p class="mt35"> 본인확인 : ${result.list[0].DisplayName}는(은) 미사용 연차유급휴가 사용시기 지정통보에 대하여 본인확인하고 승인 하였습니다.</p>
	</div>
</div>

<script>
	var vacPlan = '${result.list[0].VACPLAN}' == '' ? '' : $.parseJSON('${result.list[0].VACPLAN}');
	var urCode = '${result.list[0].UserCode}';
	var remindDays = '${result.list[0].REMINDDAYS}' == '' ? '' : $.parseJSON('${result.list[0].REMINDDAYS}');
	var year = ${result.list[0].YEAR};
	var viewType = CFN_GetQueryString("viewType");
	var isAll = CFN_GetQueryString("isAll");
	var time = CFN_GetQueryString("time"); 	//3 고정 (3차)
	
	initContent();
	
	function initContent() {
		
		if(('${result.list[0].REMINDDAYS}'==''? 0 : parseFloat('${result.list[0].REMINDDAYS}')) <= 0){
			Common.Warning("<spring:message code='Cache.msg_vacation_no_remindDay'/>", "Warning", function(){
				if(viewType == "user"){
					window.close();
				}
			});
		}
		
		
		if(viewType != "admin"){
			// 읽음 테이블에 입력
			$.ajax({
				type : "POST",
				data : {messageId : 5,
						year : year},
				async: false,
				url : "/groupware/vacation/setVacationMessageRead.do",
				success:function (list) {
				},
				error:function(response, status, error) {
					CFN_ErrorAjax(url, response, status, error);
				}
			});
		}else{
			$("#printBtn").css('visibility', 'visible');
			$("#printMessage").show(); 
		}
		
		
		if(isAll == "Y"){
			Print();
		}
		
		
		var months = (time == "1" ? vacPlan.months : (time == "2" ? vacPlan.months2 : vacPlan.months3) );
		
		if (months == null || typeof(months) == 'undefined' || months.length == 0) { //null,[]은 1차 2차중 둘중 하나만 저장한 상태, undefined는 둥다 저장안해서 테이블 row 자체가 없는 상태
			months = new Array();
		}
		
		var len = months.length;
		if (len > 0) {
			$.each(months, function(i, v) {
 				var month = v.month;
 				var vacPlan = v.vacPlan;
 				var text = "";
 				
 				if(month != ""){
					$.each(vacPlan, function(i, v) {
						text += v.startDate + " ~ " + v.endDate;
					});
	 				
					if(i == 0){
						$("#vacationList").find("tr").eq(0).find("td").html(text);
					}else{
						$("#vacationList").append("<tr><td>" + text + "</td></td>");
					}
 				}
			});
		}
	}

	function generateVacPlan(str) {
		var splitStr = str.split('~');
		var arr = new Array();
		arr.push({
			startDate : splitStr[0],
			endDate : splitStr[1]
		});
		
		var obj = new Object();
		obj.month = (splitStr[0].substring(5,6) == 0) ? splitStr[0].substring(6,7) : splitStr[0].substring(5,7);
		obj.vacPlan = arr;

		return obj;
	}	
	
	// 연차사용시기 입력
	function openVacationUsePlanDetailPopup() {
		Common.open("","vacationUsePlanDetailPopup", Common.getDic("lbl_apv_AnnaulUseTerm"), "/groupware/vacation/goVacationUsePlanDetailPopup.do?year="+year+"&urCode="+urCode+"&time="+time,"794px","530px","iframe",true,null,null,true);
		//CFN_OpenWindow("/groupware/vacation/goVacationUsePlanDetailPopup.do?year="+year+"&urCode="+urCode+"&time="+time, "", 800, 500, "resize");
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
