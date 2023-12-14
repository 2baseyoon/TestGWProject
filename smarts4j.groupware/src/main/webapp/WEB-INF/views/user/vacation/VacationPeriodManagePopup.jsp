<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent extensionPeriodSettingPopup" style="padding: 20px 24px 30px;">
	<div class="">
		<div class="top">						
			<h3><spring:message code='Cache.lbl_annualPromotionPeriod' /><!-- 연차촉진제 운영 기간  --></h3>
			<div class="ulList ">
				<ul>
					<li class="listCol">
						<div style="width:150px;"><strong><spring:message code='Cache.lbl_annualUsePlan' /><!-- 연차 사용계획  --></strong></div>
						<div>
							<div id="Code1CalendarPicker" name="Code1" class="PeriodPicker">
							</div>
						</div>
					</li>		
					<li class="listCol">
						<div style="width:150px;"><strong><spring:message code='Cache.lbl_annualPromotion' /> <spring:message code='Cache.lbl_vacation_first' /> <!-- 연차촉진제 1차 --></strong></div>
						<div>
							<div id="Code2CalendarPicker" name="Code2" class="PeriodPicker">
							</div>
						</div>
					</li>								
					<li class="listCol">
						<div style="width:150px;"><strong><spring:message code='Cache.lbl_annualPromotion' /> <spring:message code='Cache.lbl_vacation_second' /> <!-- 연차촉진제 2차 --></strong></div>
						<div>
							<div id="Code3CalendarPicker" name="Code3" class="PeriodPicker">
							</div>
						</div>
					</li>								
				</ul>							
			</div>
			<h3 class="mt30"><spring:message code='Cache.lbl_annualPromotionPeriod' /> - <spring:message code='Cache.lbl_underOneYearWorker' /><!-- 연차촉진제 운영 기간 - 1년 미만 근로자 --></h3>
				<div class="ulList">
					<ul>	
						<li class="listCol">
							<div style="width:150px;"><strong><spring:message code='Cache.lbl_annualUsePlan' /><!-- 연차 사용계획 --></strong></div>
							<div>
								<div id="Code4CalendarPicker" name="Code4" class="PeriodPicker">
								</div>
							</div>
						</li>
						<li class="listCol">
							<div style="width:150px;"><strong><spring:message code='Cache.lbl_annualPromotion' /> <spring:message code='Cache.lbl_vacation_first' /> [9<spring:message code='Cache.lbl_day' />]<!-- 연차촉진제 1차 [9일] --></strong></div>
							<div>
								<div id="Code5CalendarPicker" name="Code5" class="PeriodPicker">
								</div>
							</div>
						</li>
						<li class="listCol">
							<div style="width:150px;"><strong><spring:message code='Cache.lbl_annualPromotion' /> <spring:message code='Cache.lbl_vacation_second' /> [9<spring:message code='Cache.lbl_day' />]<!-- 연차촉진제 2차 [9일] --></strong></div>
							<div>
								<div id="Code6CalendarPicker" name="Code6" class="PeriodPicker">
								</div>
							</div>
						</li>
						<li class="listCol">
							<div style="width:150px;"><strong><spring:message code='Cache.lbl_annualPromotion' /> <spring:message code='Cache.lbl_vacation_first' /> [2<spring:message code='Cache.lbl_day' />]<!-- 연차촉진제 1차 [2일] --></strong></div>
							<div>
								<div id="Code7CalendarPicker" name="Code7" class="PeriodPicker">
								</div>
							</div>
						</li>	
						<li class="listCol">
							<div style="width:150px;"><strong><spring:message code='Cache.lbl_annualPromotion' /> <spring:message code='Cache.lbl_vacation_second' /> [2<spring:message code='Cache.lbl_day' />]<!-- 연차촉진제 2차 [2일] --></strong></div>
							<div>
								<div id="Code8CalendarPicker" name="Code8" class="PeriodPicker">
								</div>
							</div>
						</li>	
					</ul>
				</div>	
		</div>
		<div class="bottom" style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="updateVacPeriodDay()"><spring:message code="Cache.btn_save" /></a>
		</div>
	</div>
</div>
			
<script>
	
	initContent();

	function initContent() {
		localCache.remove("CODE_VacationPromotionPeriod")
		
		var year = new Date().getFullYear();
		var promotionPeriod = Common.getBaseCode("VacationPromotionPeriod");
		var initInfos = {						// 달력 옵션
				useCalendarPicker : 'Y', 		// [필수] 날짜 선택 Input 사용여부 (Y/N)
				useTimePicker : 'N',	 		// [필수] 시간 선택 SelecBox 사용여부  (Y/N)
		};
		
		coviCtrl.renderDateSelect2('Code1CalendarPicker', initInfos);	// 연차촉진제 운영 기간 - 연차 사용계획
		coviCtrl.renderDateSelect2('Code2CalendarPicker', initInfos);	// 연차촉진제 운영 기간 - 연차촉진제 1차
		coviCtrl.renderDateSelect2('Code3CalendarPicker', initInfos);	// 연차촉진제 운영 기간 - 연차촉진제 2차
		coviCtrl.renderDateSelect2('Code4CalendarPicker', initInfos);	// 연차촉진제 운영 기간 - 1년 미만 근로자 - 연차 사용계획
		coviCtrl.renderDateSelect2('Code5CalendarPicker', initInfos);	// 연차촉진제 운영 기간 - 1년 미만 근로자 - 연차촉진제 1차 [9일]
		coviCtrl.renderDateSelect2('Code6CalendarPicker', initInfos);	// 연차촉진제 운영 기간 - 1년 미만 근로자 - 연차촉진제 2차 [9일]
		coviCtrl.renderDateSelect2('Code7CalendarPicker', initInfos);	// 연차촉진제 운영 기간 - 1년 미만 근로자 - 연차촉진제 1차 [2일]
		coviCtrl.renderDateSelect2('Code8CalendarPicker', initInfos);	// 연차촉진제 운영 기간 - 1년 미만 근로자 - 연차촉진제 2차 [2일]
		
		$(promotionPeriod.CacheData).each(function(idx, obj){
			var code = obj.Code;
			
			$('#' + code + 'CalendarPicker_StartDate').val(obj.Reserved1 == undefined ? "": (obj.Reserved1.length == 5 ? (year + "." + obj.Reserved1) : "" ));	
			$('#' + code + 'CalendarPicker_EndDate').val(obj.Reserved2 == undefined ? "": (obj.Reserved2.length == 5 ? (year + "." + obj.Reserved2) : "" ));	
		});
	}
	
	// 수정
	function updateVacPeriodDay() {
		var params = new Array();
		
		$(".PeriodPicker").each(function(idx,obj){
			var settingObj = new Object();
		    var name = $(obj).attr("name");
		    var startDate = $('#' + name + 'CalendarPicker_StartDate').val();
		    var endDate = $('#' + name + 'CalendarPicker_EndDate').val(); 
		    
		    settingObj["Code"] = name;
		    settingObj["StartDate"] = ( startDate == "" ? "" : startDate.substring(startDate.length, startDate.length-5) );
		    settingObj["EndDate"] = ( endDate == "" ? "" : endDate.substring(endDate.length, endDate.length-5) );
		    
		    params.push(settingObj);
		});
		
        Common.Confirm("<spring:message code='Cache.lbl_vacationMsg38' />", "Confirmation Dialog", function (confirmResult) { //연차기간을 수정 하시겠습니까?
			if (confirmResult) {
		 		$.ajax({
					type: "POST",
					url: "/groupware/vacation/updateVacationPeriod.do",
					data: JSON.stringify(params),
					dataType: "json",
					contentType: "application/json; charset=utf-8",
					success:function (data) {
						if (data.result == "ok") {
							if(data.status == 'SUCCESS') {
								Common.Inform("<spring:message code='Cache.lbl_vacationMsg39' />", "Inform", function() {
									parent.Common.Close("target_pop");
									parent.search();
								});
			          		} else {
			          			Common.Warning("<spring:message code='Cache.msg_apv_030' />");
			          		}
						}
					},
					error:function(response, status, error) {
						CFN_ErrorAjax("/groupware/vacation/updateVacationPeriod.do", response, status, error);
					}
				});
			} else {
				return false;
			}
		});
	}
</script>
