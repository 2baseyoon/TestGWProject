<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop popContent vmUseInputPopup hidden">
	<div class="">
		<div class="vacation_plan_wrap">
			<div class="vacation_plan type01">
				<div class="vacation_plan_img"></div>
				<dl class="vacation_plan_dl">
					<dt><spring:message code='Cache.lbl_occurrenceYear' /><!-- 발생연차 --></dt>
					<dd><span name="ownDays"></span></dd>
				</dl>
			</div>
			<div class="vacation_plan type02">
				<div class="vacation_plan_img"></div>
				<dl class="vacation_plan_dl">
					<dt><spring:message code='Cache.lbl_UseVacation' /><!-- 사용연차 --></dt>
					<dd><span name="useDays"></dd>
				</dl>
			</div>
			<div class="vacation_plan type03">
				<div class="vacation_plan_img"></div>
				<dl class="vacation_plan_dl">
					<dt><spring:message code='Cache.lbl_RemainVacation' /><!-- 잔여연차 --></dt>
					<dd><span name="remindDays"></dd>
				</dl>
			</div>
		</div>
		<div class="top">		
			<div class="pagingType02 left">
				<a class="btnPlusAdd" onclick="addItem()"><spring:message code='Cache.btn_apv_add' /></a>
				<a class="btnMinusAdd" onclick="delItem(false)"><spring:message code='Cache.btn_delete' /></a>
				<a class="btnMinusAdd" onclick="delItem(true)"><spring:message code='Cache.btn_apv_DelAll' /></a>
			</div>
		</div>
		<div class="middle">
			<div class="ulList type05 ">
				<ul>
					<li class="ulListTitle">
						<div class="chkStyle04 chkType01">
							<input type="checkbox" id="checkAll"/><label for="checkAll"><span></span></label>	
						</div>
						<div><strong><spring:message code="Cache.lbl_Gubun" /></strong></div>
						<div><strong><spring:message code='Cache.lbl_apv_vacation_sdate' /></strong></div>
					</li>
				</ul>
				<div class="ulList_scroll">
					<ul id="itemUl">
					</ul>	
				</div>
			</div>
		</div>
		<div class="bottom mt20">
			<a class="btnTypeDefault btnTypeBg" onclick="saveItem()"><spring:message code="Cache.btn_save" /></a>
			<a class="btnTypeDefault" onclick="Common.Close()"><spring:message code="Cache.lbl_close" /></a>
		</div>
	</div>
</div>

<script>
	var lbl_Month_1 = "<spring:message code="Cache.lbl_Month_1" />";
	var lbl_Month_2 = "<spring:message code="Cache.lbl_Month_2" />";
	var lbl_Month_3 = "<spring:message code="Cache.lbl_Month_3" />";
	var lbl_Month_4 = "<spring:message code="Cache.lbl_Month_4" />";
	var lbl_Month_5 = "<spring:message code="Cache.lbl_Month_5" />";
	var lbl_Month_6 = "<spring:message code="Cache.lbl_Month_6" />";
	var lbl_Month_7 = "<spring:message code="Cache.lbl_Month_7" />";
	var lbl_Month_8 = "<spring:message code="Cache.lbl_Month_8" />";
	var lbl_Month_9 = "<spring:message code="Cache.lbl_Month_9" />";
	var lbl_Month_10 = "<spring:message code="Cache.lbl_Month_10" />";
	var lbl_Month_11 = "<spring:message code="Cache.lbl_Month_11" />";
	var lbl_Month_12 = "<spring:message code="Cache.lbl_Month_12" />";
	var lbl_apv_year = "<spring:message code="Cache.lbl_apv_year" />";
	var time = CFN_GetQueryString("time"); //1: 사용시기 지정1차, 2: 사용시기 지정2차, 3: 연차촉진지정통보 3차, 2020: 2020년 연차촉진제도 변경 적용
	var num = 0;
	var itemLiObj;
	var remindDays = parent.remindDays;
	var year = ${result.list[0].TargetYear};
	var vacPlan = '${result.list[0].VACPLAN}' == '' ? '' : $.parseJSON('${result.list[0].VACPLAN}');
	var rangeDateFrom = '${rangeDateFrom}';
	var rangeDateTo = '${rangeDateTo}';
	var dateRangeFrom = new Date(rangeDateFrom.replace("-","/").replace("-","/"));
	var dateRangeTo = new Date(rangeDateTo.replace("-","/").replace("-","/"));
	var CreateMethod = '${CreateMethod}';

	var urCode = CFN_GetQueryString("urCode");
	var formType = CFN_GetQueryString("formType"); 	// plan/notification1/request/notification2
	var empType = CFN_GetQueryString("empType"); 	// normal/newEmp/newEmpForNine/newEmpForTwo
	var vacTypeList = null;
	var viewType = CFN_GetQueryString("viewType");
	//신규입사자는 입사일 기준
	if (empType != "normal") year = "${result.list[0].EnterDate}".substring(0,4);
	$( document ).ready(function() {
		getVacationTypeList();
		initContent();
	});

	function getVacationTypeList(){
		//컬럼 정보 조회
		$.ajax({
			url : "/groupware/vacation/getVacTypeCol.do",
			type: "POST",
			dataType : 'json',
			async: false,
			success:function (data) {
				var listData = data.list;
				if(listData.length>0){
					vacTypeList = listData;//JSON.stringify(listData);
				}
			}
		});
	}
	
	function initContent() {
		if(time == "1"){
			 itemLiObj = $("<li/>", {'class' : 'listCol'}).append(
				 	$("<div/>", {'class' : 'chkStyle04 chkType01'}).append(
							$("<input/>", {attr : {type : 'checkbox'}})
					).append(
						$("<label/>").append($("<span/>"))		
					),
					$("<div/>").append(
						$("<select/>", {'onchange': 'changeMonth(this)'}).append(
							$('<option/>').text('<spring:message code="Cache.lbl_Month_1" />').val('1'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_2" />').val('2'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_3" />').val('3'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_4" />').val('4'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_5" />').val('5'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_6" />').val('6'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_7" />').val('7'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_8" />').val('8'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_9" />').val('9'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_10" />').val('10'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_11" />').val('11'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_12" />').val('12')
						)
					).append(
						$("<select/>", {'style': 'margin-left: 5px;'}).append(
							$('<option/>').text('<spring:message code="Cache.VACATION_ANNUAL" />').val(''), 
							$('<option/>').text('<spring:message code="Cache.VACATION_OFF" />').val('off') 
						)
					),
					$("<div/>").append(
						$("<div />", {'name': 'period' })
					)
				);
		}else if(time == "2"){
			 itemLiObj = $("<li/>", {'class' : 'listCol'}).append(
					 	$("<div/>", {'class' : 'chkStyle04 chkType01'}).append(
								$("<input/>", {attr : {type : 'checkbox'}})
						).append(
							$("<label/>").append($("<span/>"))		
						),
						$("<div/>").append(
							$("<select/>", {'onchange': 'changeMonth(this)'}).append(
								$('<option/>').text('<spring:message code="Cache.lbl_Month_6" />').val('6'), 
								$('<option/>').text('<spring:message code="Cache.lbl_Month_7" />').val('7'), 
								$('<option/>').text('<spring:message code="Cache.lbl_Month_8" />').val('8'), 
								$('<option/>').text('<spring:message code="Cache.lbl_Month_9" />').val('9'), 
								$('<option/>').text('<spring:message code="Cache.lbl_Month_10" />').val('10'), 
								$('<option/>').text('<spring:message code="Cache.lbl_Month_11" />').val('11'), 
								$('<option/>').text('<spring:message code="Cache.lbl_Month_12" />').val('12')
							)
						).append(
							$("<select/>", {'style': 'margin-left: 5px;'}).append(
								$('<option/>').text('<spring:message code="Cache.VACATION_ANNUAL" />').val(''), 
								$('<option/>').text('<spring:message code="Cache.VACATION_OFF" />').val('off') 
							)
						),
						$("<div/>").append(
							$("<div />", {'name': 'period' })
						)
					);
		}else if(time == "3"){
			itemLiObj = $("<li/>", {'class' : 'listCol'}).append(
					$("<div/>", {'class' : 'chkStyle04 chkType01'}).append(
							$("<input/>", {attr : {type : 'checkbox'}})
					).append(
						$("<label/>").append($("<span/>"))		
					),
					$("<div/>").append(
						$("<select/>", {'onchange': 'changeMonth(this)'}).append(
							$('<option/>').text('<spring:message code="Cache.lbl_Month_10" />').val('10'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_11" />').val('11'), 
							$('<option/>').text('<spring:message code="Cache.lbl_Month_12" />').val('12')
						)
					).append(
						$("<select/>", {'style': 'margin-left: 5px;'}).append(
							$('<option/>').text('<spring:message code="Cache.VACATION_ANNUAL" />').val(''), 
							$('<option/>').text('<spring:message code="Cache.VACATION_OFF" />').val('off') 
						)
					),
					$("<div/>").append(
						$("<div />", {'name': 'period' })
					)
				);
		}else if(time == "2020"){
			itemLiObj = $("<li/>", {'class' : 'listCol'}).append(
					$("<div/>", {'class' : 'chkStyle04 chkType01'}).append(
						$("<input/>", {attr : {type : 'checkbox'}})
					).append(
						$("<label/>").append($("<span/>"))		
					),
					$("<div/>").append(function(){
						if(CreateMethod==="F"){
							var y = dateRangeFrom.getFullYear();
							return $("<select/>", {'onchange': 'changeMonth(this)'}).append(
									$('<option/>',{'year': y}).text('<spring:message code="Cache.lbl_Month_1" />').val('1'),
									$('<option/>',{'year': y}).text('<spring:message code="Cache.lbl_Month_2" />').val('2'),
									$('<option/>',{'year': y}).text('<spring:message code="Cache.lbl_Month_3" />').val('3'),
									$('<option/>',{'year': y}).text('<spring:message code="Cache.lbl_Month_4" />').val('4'),
									$('<option/>',{'year': y}).text('<spring:message code="Cache.lbl_Month_5" />').val('5'),
									$('<option/>',{'year': y}).text('<spring:message code="Cache.lbl_Month_6" />').val('6'),
									$('<option/>',{'year': y}).text('<spring:message code="Cache.lbl_Month_7" />').val('7'),
									$('<option/>',{'year': y}).text('<spring:message code="Cache.lbl_Month_8" />').val('8'),
									$('<option/>',{'year': y}).text('<spring:message code="Cache.lbl_Month_9" />').val('9'),
									$('<option/>',{'year': y}).text('<spring:message code="Cache.lbl_Month_10" />').val('10'),
									$('<option/>',{'year': y}).text('<spring:message code="Cache.lbl_Month_11" />').val('11'),
									$('<option/>',{'year': y}).text('<spring:message code="Cache.lbl_Month_12" />').val('12')
							);
						}else{
							const monthObj = $("<select/>", {'onchange': 'changeMonth(this)'});
							var sm = dateRangeFrom.getMonth()+1;
							for(var i=sm;i<=sm+12;i++){
								var m = i;
								var y = dateRangeFrom.getFullYear();
								if(m>12){
									m = m%12;
									if (m==0) m=12;
									y = dateRangeTo.getFullYear();
								}
								monthObj.append($('<option/>',{'year': y}).text(y+lbl_apv_year+" "+ window['lbl_Month_'+m] ).val(m));
							}
							return monthObj;
						}
					}).append(
						$("<select/>", {'style': 'margin-left: 5px;'}).append(
							$('<option/>').text('<spring:message code="Cache.VACATION_ANNUAL" />').val(''), 
							$('<option/>').text('<spring:message code="Cache.VACATION_OFF" />').val('off') 
						)
					),
					/*.append(function (){
						var optionHtml = "<select stype='margin-left: 5px;'>";
						for(var i=0;i<vacTypeList.length;i++){
							var reserved3 = Number(vacTypeList[i].Reserved3);
							var listCode = vacTypeList[i].Code;
							var codeName = vacTypeList[i].CodeName
							var multiCodeName = vacTypeList[i].MultiCodeName;
							if(multiCodeName!=""){
								codeName = multiCodeName;
							}
							if(reserved3>=0.5){
								optionHtml+='<option value="'+listCode+'">'+codeName+'</option>';
							}
						}
						optionHtml+='</select>';
						return optionHtml;
						/!*$("<select/>", {'style': 'margin-left: 5px;'}).append(

							$('<option/>').text('<spring:message code="Cache.VACATION_ANNUAL" />').val(''),
							$('<option/>').text('<spring:message code="Cache.VACATION_OFF" />').val('off')
						)*!/
					}),*/
					$("<div/>").append(
						$("<div />", {'name': 'period' })
					)
				);
		}
		
		var months;
		
		if(vacPlan != ''){
			if(time == "2020"){
				months = $$(vacPlan).find(formType + " " + empType + " months").json();
			}else{
				months = (time == "1" ? vacPlan.months : (time == "2" ? vacPlan.months2 : vacPlan.months3) );
			}
		}
		
		if (months == null || typeof(months) == 'undefined' || months.length == 0) { //null,[]은 1차 2차중 둘중 하나만 저장한 상태, undefined는 둥다 저장안해서 테이블 row 자체가 없는 상태
			months = new Array();
		}
		
		var len = months.length;
	
		if (len > 0) {
 			$.each(months, function(i, v) {
 				var vacPlan = v.vacPlan;
 				var month = v.month;
 				if (typeof(month) != 'undefined' && month != '') {
					$.each(vacPlan, function(i, v) {
						var dateStart = new Date(v.startDate.replace(".","/").replace(".","/"));
						var isOff = v.hasOwnProperty("isOff") && v.isOff ? "off" : "";
						var cloned = $(itemLiObj).clone();
						cloned.find('div[name=period]').eq(0).attr("id", "period"+num);
						cloned.find('input[type=checkbox]').eq(0).attr("id", "chk"+num);
						cloned.find('select').eq(0).attr("id", "selMonth"+num);
						cloned.find('select').eq(1).attr("id", "selVacType"+num);
						cloned.find('label').eq(0).attr("for", "chk"+num);
						cloned.find('select:eq(0) option[value=' + month +'][year='+dateStart.getFullYear()+']').prop('selected', true);
						cloned.find('select:eq(1) option[value=\'' + isOff +'\']').prop('selected', true);
						
						$('#itemUl').append(cloned);
						setControl("period"+num);
						
						cloned.find("[id=period"+num+"_StartDate]").val(v.startDate);
						cloned.find("[id=period"+num+"_EndDate]").val(v.endDate);
						
						num++;
					});
				}
			});
		}
		
		if(num==0){
			addItem();
		}
		
		$("span[name='ownDays']").text($(parent.document).find("span[name='ownDays']").eq(0).text());
		$("span[name='useDays']").text($(parent.document).find("span[name='useDays']").eq(0).text());
		$("span[name='remindDays']").text($(parent.document).find("span[name='remindDays']").eq(0).text());
	}

	$(function() {
		$("#checkAll").change(function () {
		    $("input:checkbox").prop('checked', $(this).prop("checked"));
		});	
	});
	
	// 추가
 	function addItem() {
		var cloned = $(itemLiObj).clone();
		cloned.find('div[name=period]').eq(0).attr("id", "period"+num);
		cloned.find('input[type=checkbox]').eq(0).attr("id", "chk"+num);
		cloned.find('select').eq(0).attr("id", "selMonth"+num);
		cloned.find('select').eq(1).attr("id", "selVacType"+num);
		cloned.find('label').eq(0).attr("for", "chk"+num);
		$('#itemUl').append(cloned);
		setControl("period"+num);
		num++;
	}
	
	// 삭제
	function delItem(isAll) {
		$('.listCol').each(function (i, v) {
			if(isAll || $(this).find('input:checkbox').is(':checked')){
				$(this).remove();
			}
		});
	}
	
	function checkValidation(){
		var retVal = true;
		var allDays = 0;
		
		$('.listCol').each(function (i, v) {
			var li = $(this);
			var month = li.find('select:eq(0) option:selected').val();
			var isOff = li.find('select:eq(1) option:selected').val();
			var startDate = li.find("input:text").eq(0).val();
			var endDate = li.find("input:text").eq(1).val();
			
			if(startDate == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterStartDate'/>", "Warning", function(){
					li.find("input:text").eq(0).focus();
				}); //시작일자를 입력하세요
				retVal = false;
				return false;
			}else if(endDate == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterEndDate'/>", "Warninig", function(){
					li.find("input:text").eq(1).focus();
				}); //종료일자를 입력하세요
				retVal = false;
				return false;
			}
			
			var dStartDate, dEndDate;
			if(startDate != undefined && startDate != '' && endDate != undefined && endDate != ''){
				dStartDate = new Date(startDate.replace(/\./g, "/"));
				dEndDate = new Date(endDate.replace(/\./g, "/"));
				
				if(month != (dStartDate.getMonth()+1) ){
					Common.Warning("<spring:message code='Cache.msg_Attendance_DateError'/>", "Warning", function(){
						li.find("input:text").eq(0).focus();
					}); //올바르지 않은 시간값 입니다.
					retVal = false;
					return false;
				}else if(month != (dEndDate.getMonth()+1) ){
					Common.Warning("<spring:message code='Cache.msg_Attendance_DateError'/>", "Warning", function(){
						li.find("input:text").eq(1).focus();
					}); //올바르지 않은 시간값 입니다.
					retVal = false;
					return false;
				}
				
				var diff = Math.abs(dEndDate.getTime() - dStartDate.getTime());
				diff = (Math.ceil(diff / (1000 * 3600 * 24))) + 1;
				
				if(isOff){ // 반차
					diff /= 2;
				}
				
				allDays += diff; 
				
			}
		});
		
		if(retVal == false){
			return false;
		}else{
			if(viewType==="user" && allDays < remindDays){
				Common.Warning(String.format("<spring:message code='Cache.msg_vacation_input_usePlan'/>", remindDays, remindDays)); //현재 잔여연차는 {0}일입니다.<br>{1}일 이상 입력해주세요.
				return false;
			}else{
				return true;
			}
		}
	}


	function checkValidationPre(){
		var retVal = true;

		$('.listCol').each(function (i, v) {
			var li = $(this);
			var month = li.find('select:eq(0) option:selected').val();
			var isOff = li.find('select:eq(1) option:selected').val();
			var startDate = li.find("input:text").eq(0).val();
			var endDate = li.find("input:text").eq(1).val();

			if(startDate == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterStartDate'/>", "Warning", function(){
					li.find("input:text").eq(0).focus();
				}); //시작일자를 입력하세요
				retVal = false;
				return false;
			}else if(endDate == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterEndDate'/>", "Warninig", function(){
					li.find("input:text").eq(1).focus();
				}); //종료일자를 입력하세요
				retVal = false;
				return false;
			}

			var dStartDate, dEndDate;
			if(startDate != undefined && startDate != '' && endDate != undefined && endDate != ''){
				dStartDate = new Date(startDate.replace(/\./g, "/"));
				dEndDate = new Date(endDate.replace(/\./g, "/"));

				if(month != (dStartDate.getMonth()+1) ){
					Common.Warning("<spring:message code='Cache.msg_Attendance_DateError'/>", "Warning", function(){
						li.find("input:text").eq(0).focus();
					}); //올바르지 않은 시간값 입니다.
					retVal = false;
					return false;
				}else if(month != (dEndDate.getMonth()+1) ){

					var preEndDate = new Date(new Date(startDate.replace(/\./g, "/")).getFullYear(), new Date(startDate.replace(/\./g, "/")).getMonth()+1, 0);
					var nextStartDate = new Date(new Date(endDate.replace(/\./g, "/")).getFullYear(), new Date(endDate.replace(/\./g, "/")).getMonth(), 1);
					var nextEndDate = new Date(endDate.replace(/\./g, "/"));
					$("#period"+i+"_EndDate").val(preEndDate.format('yyyy.MM.dd'));

					var cloned = $(itemLiObj).clone();
					cloned.find('div[name=period]').eq(0).attr("id", "period"+num);
					cloned.find('input[type=checkbox]').eq(0).attr("id", "chk"+num);
					cloned.find('select').eq(0).attr("id", "selMonth"+num);
					cloned.find('select').eq(1).attr("id", "selVacType"+num);
					cloned.find('label').eq(0).attr("for", "chk"+num);
					$('#itemUl').append(cloned);
					setControl("period"+num);
					$("#period"+num+"_StartDate").val(nextStartDate.format('yyyy.MM.dd'));
					$("#period"+num+"_EndDate").val(nextEndDate.format('yyyy.MM.dd'));
					$("#selMonth"+num).val(nextStartDate.getMonth()+1);
					$("#selVacType"+num).val($("#selVacType"+i).val());
					num++;
				}

			}
		});
 		return retVal;
	}
	
	// 저장
	function saveItem() {
		if(!checkValidationPre()){
			return ;
		}
		if(!checkValidation()){
			return ;
		}
		
		var usePlan;
		if(vacPlan != ''){
			usePlan = vacPlan;
			usePlan.year = year;
		}else{
			usePlan = new Object();
			usePlan.year = year;
			usePlan.urCode = urCode;
		}
		usePlan.ownDays = $("span[name='ownDays']").text();

		var vacPlanArr = new Array();
		var usePlanMonthArr = null;
		var usePlanMonth = null;
		var usePlanDate = null;
		
		$('.listCol').each(function (i, v) {
			var li = $(this);
			var month = li.find('select:eq(0) option:selected').val();
			var isOff = li.find('select:eq(1) option:selected').val();
			
			usePlanDate = new Object();
			li.find('input:text').each(function (i, v) {
				if (i == 0) {
					usePlanDate.startDate = v.value;
				} else {
					usePlanDate.endDate = v.value;
				}
			});
			
			var index = -1;
			$.each(vacPlanArr, function(i, v) {
				if (v.month == month) {
					index = i;
					return false;
				}
			});
			
			if(isOff && isOff === "off"){ // 반차 체크
				usePlanDate.isOff = true;
			}
			
			//if (usePlanDate.startDate != '' && usePlanDate.endDate != '') {
				if (index == -1) {
					usePlanMonth = new Object();
					usePlanMonth.month = month;
					usePlanMonthArr = new Array();
					usePlanMonthArr.push(usePlanDate);
					usePlanMonth.vacPlan = usePlanMonthArr;
					vacPlanArr.push(usePlanMonth);
				} else {
					vacPlanArr[index].vacPlan.push(usePlanDate);
				}
			//}
		});
		
		if(time == "1"){ //사용시기지정통보 1차
			usePlan.months = vacPlanArr;
		}else if(time =="2"){			//사용시기지정통보 2차
			usePlan.months2 = vacPlanArr;
		}else if(time=="3"){	//연차촉진제 3차
			usePlan.months3 = vacPlanArr;
		}else  if(time=="2020"){	//2020년 연차촉진제도 변경 적용
			if(usePlan[formType] == undefined) usePlan[formType] = {};
			if(usePlan[formType][empType] == undefined) usePlan[formType][empType] = {};
			usePlan[formType][empType]["months"] = vacPlanArr;
		} 

		if(usePlan.months == undefined)	usePlan.months = [];
		if(usePlan.months2 == undefined) usePlan.months2 = []; 
		if(usePlan.months3 == undefined) usePlan.months3 = []; 
		
 		$.ajax({
			type : "POST",
			contentType : 'application/json; charset=utf-8',
			data : JSON.stringify(usePlan),
			url : "/groupware/vacation/insertVacationUsePlan.do",
			success:function (data) {
				if(data.result == "ok") {
					if(data.status == 'SUCCESS') {
						parent.location.reload();
						Common.Close();
	          		} else {
	          			Common.Warning("<spring:message code='Cache.msg_apv_030' />");
	          		}
				}
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
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

	function setControl(id){
		var initInfos = {
				useCalendarPicker : 'Y',	//캘린더 paicker의 사용여부로, 날짜를 선택하는 달력의 사용여부를 묻는 옵션입니다.
				useTimePicker : 'N',	//time picker의 사용여부로, 00:00 부터 23:00 까지의 시간을 선택하는 select box의 사용여부를 묻는 옵션입니다.
				useBar : 'Y'	//time picker 사이의 bar의 사용여부를 묻는 옵션입니다.
			};
		
		coviCtrl.renderDateSelect3(id, initInfos, num);
		
		var month = Number($("#"+id).parents(".listCol").find("select").val());
		var years = Number($("#"+id).parents(".listCol").find("select").find("option:selected").attr("year"));
		if(years===null || years===""){
			years = year;
		}
		var startDate = new Date(years, month-1, 1);
		var endDate = new Date(years, month, 0);
		
		var startDateObj = $("#"+id).parents(".listCol").find("input[id$='StartDate']");
		var endDateObj = $("#"+id).parents(".listCol").find("input[id$='EndDate']");

		var selY = $("#"+id).parents(".listCol").find("select").find("option:selected").attr("year");
		var month2 = month+1;
		var year2 = Number(selY);
		if(month2>12){
			month2 = month2%12;
			year2++;
		}
		var endDate2 = new Date(year2, month2, 0);
		if(endDate2>dateRangeTo){
			endDate2 = endDate;
		}

		startDateObj.datepicker("option", "minDate", startDate);
		startDateObj.datepicker("option", "maxDate", endDate);

		endDateObj.datepicker("option", "minDate", startDate);
		endDateObj.datepicker("option", "maxDate", endDate2);
	}
	
	function changeMonth(monthObj){
		var month = Number($(monthObj).val());
		var selY = $(monthObj).find("option:selected").attr("year");

		
		var startDateObj = $(monthObj).parents(".listCol").find("input[id$='StartDate']");
		var endDateObj = $(monthObj).parents(".listCol").find("input[id$='EndDate']");
		var startDate = new Date(selY, month-1, 1);
		var endDate = new Date(selY, month, 0);
		var month2 = month+1;
		var year2 = Number(selY);
		if(month2>12){
			month2 = month2%12;
			year2++;
		}
		var endDate2 = new Date(year2, month2, 0);
		if(endDate2>dateRangeTo){
			endDate2 = endDate;
		}
		
		startDateObj.val("");
		startDateObj.datepicker("option", "minDate", startDate);
		startDateObj.datepicker("option", "maxDate", endDate);

		endDateObj.val("");
		endDateObj.datepicker("option", "minDate", startDate);
		endDateObj.datepicker("option", "maxDate", endDate2);
		
	}
	
</script>
