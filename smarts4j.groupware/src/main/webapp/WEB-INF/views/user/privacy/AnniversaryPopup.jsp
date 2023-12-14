<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent miAnniversaryPopup" style="padding: 20px 24px 30px;">
	<div class="">
		<div class="top">						
			<div class="ulList">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_AnniversaryName"/></strong></div> <!-- 기념일 명 -->
						<div>
							<input type="text" class="inpFullSize HtmlCheckXSS ScriptCheckXSS" maxlength="50" placeholder="<spring:message code='Cache.msg_Anniversary_01'/>" id="subject"> <!-- 기념일을 입력하세요. -->
						</div>
					</li>	
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_AnniversaryDate"/></strong></div> <!-- 기념일자 -->
						<div>
							<div class="dateSel type02">											
								<div id="anniversaryCalendarPicker" style="display:inline;"></div>
								<span class="radioStyle04 size"><input type="radio" id="rrr01" name="anniDateType" value="S" onclick="javascript:changeDateDiv(this);" checked><label for="rrr01"><span><span></span></span><spring:message code="Cache.lbl_Solar"/></label></span> <!-- 양력 -->
								<span class="radioStyle04 size"><input type="radio" id="rrr02" name="anniDateType" value="L" onclick="javascript:changeDateDiv(this);"><label for="rrr02"><span><span></span></span><spring:message code="Cache.lbl_Lunar"/></label></span> <!-- 음력 -->
							</div>										
						</div>
					</li>											
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_Alram"/></strong></div> <!-- 알림 -->
						<div>
							<div class="alarm type01">
								<a href="#" class="onOffBtn" id="alarmYn"><span></span></a>
							</div>
							<select class="selectType02" id="alramPeriod" style="display: none;">
							</select>
						</div>
					</li>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_importance"/></strong></div> <!-- 중요도 -->
						<div class="dateSel type02">
							<select class="selectType02" id="priority">
								<option value="1"><spring:message code="Cache.Anni_Priority_1"/></option> <!-- 매우 높음 -->
								<option value="2"><spring:message code="Cache.Anni_Priority_2"/></option> <!-- 높음 -->
								<option value="3" selected><spring:message code="Cache.Anni_Priority_3"/></option> <!-- 보통 -->
								<option value="4"><spring:message code="Cache.Anni_Priority_4"/></option> <!-- 낮음 -->
								<option value="5"><spring:message code="Cache.Anni_Priority_5"/></option> <!-- 매우 낮음 -->
							</select>
						</div>
					</li>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_Contents"/></strong></div> <!-- 내용 -->
						<div>
							<textarea id="description" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
						</div>
					</li>	
				</ul>							
			</div>
		</div>
		<div class="bottom" style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeChk" onclick="saveAnniversary()"><spring:message code="Cache.lbl_Regist"/></a> <!-- 등록 -->
			<a href="#" class="btnTypeDefault btnBlueBoder" id="scheduleRegistBtn" onclick="parent.openCalendarPopup($('#anniversaryCalendarPicker_Date').val(), $('#anniversaryCalendarPicker_Date').val(), $('#subject').val());Common.Close()"><spring:message code="Cache.lbl_schedule_addEvent"/></a> <!-- 일정등록 -->
			<a href="#" class="btnTypeDefault" onclick="resetVal()"><spring:message code="Cache.btn_init"/></a> <!-- 초기화 -->
			<a href="#" class="btnTypeDefault" onclick="Common.Close()"><spring:message code="Cache.btn_Close"/></a> <!-- 닫기 -->
		</div>
	</div>
</div>
			
<script>
	var param = location.search.substring(1).split('&');
	var messageId = CFN_GetQueryString("messageId") == 'undefined' ? '' : CFN_GetQueryString("messageId");
	var grid = new coviGrid();

	initContent();

	function initContent() {
		$('#alarmYn').on('click', function(e) {
 			if ($(this).hasClass('on')) {
 				$(this).removeClass('on');
 				$("#alramPeriod").hide();
 			}else {
 				$(this).addClass('on');
 				$("#alramPeriod").show();
 			}
		});
		
		coviCtrl.makeSimpleCalendar('anniversaryCalendarPicker');
		
		// 기념일자 option 생성	
		for (var i=1; i<32; i++) {
		    $('#alramPeriod').append($('<option>', {
		        value: i,
		        text : "<spring:message code='Cache.lbl_AnniversaryAlarm3'/>".replace("{0}", i) // 일 전부터 알림
		    }));
		}
		
		if (messageId != '') {
			var url = '/groupware/privacy/getAnniversary.do';
    		$.ajax({
    			type : "POST",
    			data : {messageId : messageId},
    			async: false,
    			url : url,
    			success:function (list) {
    				var data = list.list[0];
    				
    				$('#subject').val(data.Subject);
    				$('#anniversaryCalendarPicker_Date').val(data.AnniDate);
    				if (data.AnniDateType != '') $('input:radio[name=anniDateType]:input[value=' + data.AnniDateType + ']').attr("checked", true);
					if (data.AlarmYN == 'Y') {
						$('#alarmYn').addClass('on'); 
						$("#alramPeriod").show();
					}
					$('#alramPeriod').val(data.alarmDay);
					$('#priority').val(data.Priority);
    				$('#description').val(data.Description);

    				if (data.AnniDateType == 'L'){
    					initLeapMonth($('input:radio[name=anniDateType]:input[value=L]'));
    					$("#leapMonth").prop("checked", (data.IsLeapMonth == 'Y'));
    				}
    				
    				$('#subject').focus();
    			},
    			error:function(response, status, error) {
    				CFN_ErrorAjax(url, response, status, error);
    			}
    		});
		}
		else {
			$('#subject').focus();
			$("#scheduleRegistBtn").hide();
		}
	}
	
	// 초기화
	function resetVal() {
	    $("#anniversaryCalendarPicker_Date").val('');
	    $("#subject").val('');
	    $("#description").val('');
	    $("#priority").val('3');
	    $("#rrr01").click();
	    $('#alarmYn').removeClass('on');
	    $('#alramPeriod').val('1');
	}
	
	// 저장
	function saveAnniversary() {
		var params = new Object();
		
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		if($('#subject').val() == null || $('#subject').val().trim() == ""){
			$('#subject').val("");
			Common.Warning("<spring:message code='Cache.msg_Anniversary_01'/>");
			return;
		}
		
		if($('#anniversaryCalendarPicker_Date').val().replaceAll('.','-') == null || $('#anniversaryCalendarPicker_Date').val().replaceAll('.','-').trim() == ""){
			parent.Common.Warning("<spring:message code='Cache.msg_Anniversary_04'/>", "", function(){
				$('#subject').focus();
			});
			return;
		} else {
			var dataStr = $('#anniversaryCalendarPicker_Date').val();			
			if(XFN_ReplaceAllSpecialChars(dataStr).length == 8){
				dataStr = XFN_ReplaceAllSpecialChars(dataStr);
				var returnStr = dataStr.substring(0, 4) + "." + dataStr.substring(4, 6) + "." + dataStr.substring(6, 8);
				
				if(!isNaN(Date.parse(returnStr))){
					$('#anniversaryCalendarPicker_Date').val(returnStr);
				} else {
					parent.Common.Warning("<spring:message code='Cache.mag_Attendance20' />");		//날짜 포맷에 맞는 데이터를 입력해주시기 바랍니다.
					return;
				}
			}else{
				$('#anniversaryCalendarPicker_Date').val("");
				parent.Common.Warning("<spring:message code='Cache.mag_Attendance20' />");			//날짜 포맷에 맞는 데이터를 입력해주시기 바랍니다.
				return;
			}
		}
		
		if($('#priority option:selected').val() == null || $('#priority option:selected').val() == ""){
			parent.Common.Warning("<spring:message code='Cache.msg_Anniversary_05'/>");
			return;
		}
		
		params.subject = $('#subject').val();
		params.anniDate = $('#anniversaryCalendarPicker_Date').val().replaceAll('.','-');
		params.anniDateType = $('input:radio[name=anniDateType]:checked').val();
		params.alarmYn = $('#alarmYn').hasClass("on") ? 'Y' : 'N';
		params.alramPeriod = $('#alramPeriod option:selected').val();
		params.priority = $('#priority option:selected').val();
		params.description = $('#description').val();
		
		if (params.anniDateType == 'L'){
			params.isLeapMonth = ($("#leapMonth").prop("checked")) ? 'Y' : 'N';
		}
		
		var url = '/groupware/privacy/insertAnniversary.do';
		if (messageId != '') {
			params.messageId = messageId;
			url = '/groupware/privacy/updateAnniversary.do';
		}
		
  		$.ajax({
			type : "POST",
			data : params,
			async: false,
			url : url,
			success: function (list) {
				parent.Common.Inform("<spring:message code='Cache.msg_117'/>", "Inform", function() { //성공적으로 저장하였습니다.
					parent.Common.Close("target_pop");
					parent.searchData();
				});
			},
			error: function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	function changeDateDiv(target){
		if (target.value == 'S'){
			if ($("#leapMonthSpan").length > 0) $("#leapMonthSpan").remove();
		}
		else if (target.value == 'L'){
			if ($("#leapMonthSpan").length == 0) initLeapMonth(target);
		}
	}
	
	function initLeapMonth(target){
		$(target).parent().after(
			'<span class="radioStyle04 size" id="leapMonthSpan">'+
				'<input type="checkbox" id="leapMonth">'+
				'<label for="rrr03" style="margin-left: 5px;">'+Common.getDic('lbl_lunar_leap_month')+'</label>'+
			'</span>'
		);
	}
</script>
