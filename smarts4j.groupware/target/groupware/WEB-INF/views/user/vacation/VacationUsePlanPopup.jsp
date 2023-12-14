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
	<div class="formHeader noprint" >
		<a href="#" class="btnTypeDefault type02" onclick="openVacationUsePlanDetailPopup()" ><spring:message code='Cache.lbl_apv_AnnaulUseTerm' /></a>
		<a id="printBtn" href="#" class="btnTypeDefault type02 " onclick="javascript:Print();" style="visibility: hidden;"><spring:message code='Cache.btn_print' /></a> 
		<span id="printMessage" class="col_red" style="display:none">
			※ <spring:message code='Cache.lbl_vacationMsg40' />
		</span>
	</div>
	<div class="formContent">
		<h2><spring:message code='Cache.lbl_vacationMsg46' />(<span id="time"><spring:message code='Cache.lbl_vacation_first' /></span>)</h2> <!-- 미사용 연차유급휴가 사용시기 지정통보서  -->
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
		<p class="mt35">
			${result.list[0].YEAR}.01.01 기준으로 부여받은 "미사용연차유급휴가일수" 및 휴가사용시기지정통보촉구"에 의거하여 아래와 같이
			<br>
			본인의 미사용 연차유급휴가 사용시기를 지정하여 통보합니다.
		</p>
		<p class="mt35">- 아 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;래 - </p>		
		<h3 class="mt25">통지받은 내역</h3>
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
		<h3 class="mt20">미사용 연차유급휴가 사용 시기 지정 통보내역 (월별 날짜 기재, 추후 변경 가능)</h3>
		<table class="tbl tblType02">
			<colgroup>
				<col width="95">
				<col width="240">
				<col width="95">
				<col width="240">
				<col width="240">
			</colgroup>
			<tbody>
				<tr>
					<th class="bg "><spring:message code="Cache.lbl_Gubun" /> </th>
					<th class="bg ">사용시기 지정일</th>
					<th class="bg"><spring:message code="Cache.lbl_Gubun" /> </th>
					<th class="bg ">사용시기 지정일</th>
					<th class="bg ">비고</th>
				</tr>
				<tr>
					<td>1월</td>
					<td id="janTd"></td>
					<td>7월</td>
					<td id="julTd"></td>
					<td class="tblInput"><input type="text"></td>
				</tr>
				<tr>
					<td>2월</td>
					<td id="febTd"></td>
					<td>8월</td>
					<td id="augTd"></td>
					<td class="tblInput"><input type="text"></td>
				</tr>
				<tr>
					<td>3월</td>
					<td id="marTd"></td>
					<td>9월</td>
					<td id="sepTd"></td>
					<td class="tblInput"><input type="text"></td>
				</tr>
				<tr>
					<td>4월</td>
					<td id="aprTd"></td>
					<td>10월</td>
					<td id="octTd"></td>
					<td class="tblInput"><input type="text"></td>
				</tr>
				<tr>
					<td>5월</td>
					<td id="mayTd"></td>
					<td>11월</td>
					<td id="novTd"></td>
					<td class="tblInput"><input type="text"></td>
				</tr>
				<tr>
					<td>6월</td>
					<td id="junTd"></td>
					<td>12월</td>
					<td id="decTd"></td>
					<td class="tblInput"><input type="text"></td>
				</tr>
			</tbody>
		</table>
		<%-- <p class="mt35">${result.list[0].YEAR}년&nbsp;&nbsp;${result.list[0].MONTH}월&nbsp;&nbsp;27일</p> --%>
		<p class="mt35" id="lastDate">${result.list[0].YEAR}년&nbsp;&nbsp;6월&nbsp;&nbsp;25일</p>
		<p class="mt20"> 본인확인 : ${result.list[0].DisplayName}는(은) 미사용 연차유급휴가 사용시기 지정통보에 대하여 본인확인하고 승인 하였습니다.</p>
	</div>		
</div>

<script>
	const firstDate = "01/31"; //경영관리팀 요청사항: 서식의 기한은 1차 1/31, 2차 6/10로 고정
	const secodeDate = "06/10"; //경영관리팀 요청사항: 서식의 기한은 1차 1/31, 2차 6/10로 고정

	var year = ${result.list[0].YEAR};
	var urCode = '${result.list[0].UserCode}';
	var vacPlan = '${result.list[0].VACPLAN}' == '' ? '' : $.parseJSON('${result.list[0].VACPLAN}');
	var remindDays = '${result.list[0].REMINDDAYS}' == '' ? '' : $.parseJSON('${result.list[0].REMINDDAYS}');
	var viewType = CFN_GetQueryString("viewType");
	var time = CFN_GetQueryString("time"); //1 or 2 (1회차 2회차)
	var isAll = CFN_GetQueryString("isAll");
	
	initContent();
	
	function initContent() {
		
		if(('${result.list[0].REMINDDAYS}'==''? 0 : parseFloat('${result.list[0].REMINDDAYS}')) <= 0){
			Common.Warning("<spring:message code='Cache.msg_vacation_no_remindDay'/>", "Warning", function(){
				if(viewType == "user"){
					window.close();
				}
			});
		}
		
		var finishDate = "";
		var sTime
		if(time == "1"){
			finishDate = XFN_getDateString(new Date(year + "/" + firstDate), "yyyy년 MM월 dd일");
			sTime = "<spring:message code='Cache.lbl_vacation_first'/>"; //1차
		}else{
			finishDate = XFN_getDateString(new Date(year + "/" + secodeDate), "yyyy년 MM월 dd일");
			sTime = "<spring:message code='Cache.lbl_vacation_second'/>"; //2차 
		}
		
		$("#lastDate").text(finishDate);
		$("#time").text(sTime);
		
		
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
			var pMessageID = (time == "1" ? 2 : 4);
			// 읽음 테이블에 입력
			$.ajax({
				type : "POST",
				data : {messageId : pMessageID,
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
		
		var months = (time == "1" ? vacPlan.months : vacPlan.months2);
		
		if (months == null || typeof(months) == 'undefined' || months.length == 0) {	 //null,[]은 1차 2차중 둘중 하나만 저장한 상태, undefined는 둘다 저장안해서 테이블 row 자체가 없는 상태
			months = new Array();
		}
		
		var len = months.length;
		if (len > 0) {
			$.each(months, function(i, v) {
 				var month = v.month;
 				var vacPlan = v.vacPlan;
 				var text = "";
				$.each(vacPlan, function(i, v) {
					var startDate = v.startDate;
					var endDate = v.endDate;
					
					if (text != "") text += ", ";
					if (startDate == endDate) {
						text += startDate;
					} else {
						text += v.startDate + "~" + endDate.substr(endDate.length - 2);
					}
				});
 				
				var tdObj;
 				
				switch (month.number()) {
					case 1 : tdObj = $('#janTd'); break;
					case 2 : tdObj = $('#febTd');break;
					case 3 : tdObj = $('#marTd');break;
					case 4 : tdObj = $('#aprTd');break;
					case 5 : tdObj = $('#mayTd');break;
					case 6 : tdObj = $('#junTd');break;
					case 7 : tdObj = $('#julTd');break;
					case 8 : tdObj = $('#augTd');break;
					case 9 : tdObj = $('#sepTd');break;
					case 10 : tdObj = $('#octTd');break;
					case 11 : tdObj = $('#novTd');break;
					case 12 : tdObj = $('#decTd');break;
				}
				
				if($(tdObj).html() != ""){
					text = ($(tdObj).html() + ", " + text);
				}
				
				$(tdObj).html(text);
			});
		}
		
		if(isAll == "Y"){
			Print();
		}
	}
	
 	// 연차사용시기 입력
	function openVacationUsePlanDetailPopup() {
		Common.open("","vacationUsePlanDetailPopup", Common.getDic("lbl_apv_AnnaulUseTerm"), "/groupware/vacation/goVacationUsePlanDetailPopup.do?year="+year+"&urCode="+urCode+"&time="+time,"794px","530px","iframe",true,null,null,true);
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
