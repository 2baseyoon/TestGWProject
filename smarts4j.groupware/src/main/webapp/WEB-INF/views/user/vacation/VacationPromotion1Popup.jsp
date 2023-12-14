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

<div id="wrap" class="formVeiw formVeiw01" style="overflow:inherit;" >
	<div class="formHeader noprint">
		<a href="#" id="printBtn" class="btnTypeDefault type02 " onclick="javascript:Print();" style="margin-top: 15px; display:none;"><spring:message code='Cache.btn_print' /></a>
		<span id="printMessage" class="col_red"  style="display:none;">
			※ <spring:message code='Cache.lbl_vacationMsg40' />
		</span>
	</div>
	<div class="formContent">
		<h2><span id="title"><spring:message code='Cache.lbl_vacationMsg41' /></span><br><spring:message code='Cache.lbl_vacationMsg42' /></h2>
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
					<th class="bg alignLeft"><spring:message code="Cache.lbl_JobLevel" /></th>
					<td>${result.list[0].JobPositionName}</td>
				</tr>
			</tbody>
		</table>
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
					<td>${result.list[0].OWNDAYS}</td>
					<td>${result.list[0].USEDAYS}</td>
					<td>${result.list[0].REMINDDAYS}</td>
				</tr>
			</tbody>
		</table>
		<p class="mt30">
			${result.list[0].DisplayName}님의 통지일 현재 사용 가능한 미사용 연차유급휴가일수는 ${result.list[0].REMINDDAYS}日임을 알려드립니다.
			<br>
			<span id="lastDate"></span> 까지 미사용 연차유급휴가 일수를 지정하여 미사용 연차유급휴가 사용시기 지정통보서를 작성하여<br>
			인사팀으로 서면통보하여 주시기 바랍니다.
		</p>
		<p class="mt20">
			동기한내에 붙임서식에 의한 "미사용 연차유급휴가 사용시기 지정통보"가 제출되지 아니한 경우 관련 규정에 의해 추후 회사가 임의지정할 예정이며, 
			그럼에도 불구하고 사용하지 아니한 연차유급 휴가일수에 대하여는 향후 연차유급 휴가수당이 지급되지 않음을 알려드리니 유념하시기 바랍니다.
		</p>
		<p class="tit mt30">근로기준법 제61조 연차유급휴가의 사용촉진</p>
		<div class="notTxtBox mt10">
			<p>
				사용자가 제60조제1항·제3항 및 제4항에 따른 유급휴가의 사용을 촉진하기 위하여 다음 각 호의 조치를 하였음에도 불구하고 근로자가 휴가를 사용하지 
				아니하여 제60조제7항 본문에 따라 소멸된 경우에는 사용자는 그 사용하지 아니한 휴가에 대하여 보상할 의무가 없고, 제60조제7항 단서에 따른 사용자의 
				귀책사유에 해당하지 아니하는 것으로 본다. 
			</p>
			<p>
			</p>
			<p class="mt20">
				<strong>1. 제60조제7항 본문에 따른 기간이 끝나기 6개월 전을 기준으로 10일 이내에 사용자가 근로자별로 사용하지 아니한 휴가 일수를 알려주고, 근로자가 그 사용시기를 정하여 사용자에게 통보하도록 서면으로 촉구할 것</strong>
			</p>
			<p>
			</p>
			<p class="mt10">
				2. 제1호에 따른 촉구에도 불구하고 근로자가 촉구를 받은 때부터 10일 이내에 사용하지 아니한 휴가의 전부 또는 일부의 사용 시기를 정하여 사용자에게 통보하지 아니하면 제60조제7항 본문에 따른 기간이 끝나기 2개월 전까지 사용자가 사용하지 아니한 휴가의 사용 시기를 정하여 근로자에게 서면으로 통보할 것
			</p>
			<p>
			</p>
		<div>
		</div>		
		</div>
		<p class="mt30" style=" font-size: 17px;">코&nbsp;&nbsp;비&nbsp;&nbsp;젼</p>
	</div>
</div>

<script>
	//경영관리팀 요청사항: 서식의 기한은 1차 1/31, 2차 6/10, 3차 9/30로 고정
	const firstDate = "01/31"; 
	const secondDate = "06/10";
	
	var year = ${result.list[0].YEAR};
	var viewType = CFN_GetQueryString("viewType");
	var isAll = CFN_GetQueryString("isAll");
	var time = CFN_GetQueryString("time");
	
	initContent();
	
	function initContent() {
		
		var finishDate;
		
		if(('${result.list[0].REMINDDAYS}'==''? 0 : parseFloat('${result.list[0].REMINDDAYS}')) <= 0){
			Common.Warning("<spring:message code='Cache.msg_vacation_no_remindDay'/>", "Warning", function(){
				if(viewType == "user"){
					window.close();
				}
			});
		}
		
		if(time == "1"){ //1차
			$("#title").text("<spring:message code='Cache.lbl_vacationMsg41'/>"); //미사용연차유급휴가일수통지(1차)
			finishDate = XFN_getDateString(new Date(year + "/" + firstDate), "yyyy년 MM월 dd일");
		} else if(time == "2"){ //2차
			$("#title").text("<spring:message code='Cache.lbl_vacationMsg48'/>"); //미사용연차유급휴가일수통지(1차)
			finishDate = XFN_getDateString(new Date(year + "/" + secondDate), "yyyy년 MM월 dd일");
		}
		
		$("#lastDate").text(finishDate);
		/*
 		var vacationCodes = Common.getBaseCode("VACATION_MANAGE");   // VACATION_EXPEDITEBUTTON_FIRST 끝 날짜 조회
		var finishDate ="";
		
		$(vacationCodes.CacheData).each(function(idx, obj){
			if(obj.Code =="VACATION_EXPEDITEBUTTON_FIRST"){
				finishDate = obj.Reserved2;
				finishDate = XFN_getDateString(new Date((year+"." + finishDate).replaceAll(".","/")), "yyyy년 MM월 dd일");
				
				$("#lastDate").text(finishDate);
			}
		}); 
		*/
		
		if(viewType != "admin"){
			var pMessageID = (time == "1" ? 1 : 3);
			
			// 읽음 테이블에 입력
			$.ajax({
				type : "POST",
				data : {messageId : 1, year : year},
				async: false,
				url : "/groupware/vacation/setVacationMessageRead.do",
				error:function(response, status, error) {
					CFN_ErrorAjax("/groupware/vacation/setVacationMessageRead.do", response, status, error);
				}
			});
		}else{
			$("#printBtn").show(); 
			$("#printMessage").show(); 
		}
		
		
		if(isAll == "Y"){
			Print();
		}
		
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
