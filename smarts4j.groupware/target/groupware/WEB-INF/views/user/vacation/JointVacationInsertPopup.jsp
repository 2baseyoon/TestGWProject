<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent extensionAddPopup" style="padding: 20px 24px 30px;">
	<div class="">
		<div class="top" style="height:320px;">
			<div class="schShareList">
				<div class="ATMgt_work_wrap">
					<table class="ATMgt_popup_table type03" cellpadding="0" cellspacing="0" id="step1" style="display: block;">
						<colgroup>
							<col style="width: 20%;"/>
							<col style="width: 80%;"/>
						</colgroup>
						<tbody>
							<tr style="width: 100%;">
								<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Register' /></span></td>
								<td>
									<div class="date_del_scroll ATMgt_T" id="resultViewDetailDiv">
										<input style="display:none;" id="resultViewDetailInput" type="text" class="ui-autocomplete-input  HtmlCheckXSS ScriptCheckXSS"  autocomplete="off">
										<div class="ATMgt_T_r">
											<a class="btnTypeDefault nonHover type01" onclick="openOrgMapLayerPopup('resultViewDetailDiv')"><spring:message code='Cache.btn_OrgManage' /></a>
										</div>
									</div>
								</Td>
							</tr>
							<tr style="width: 100%;">
								<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Excepter' /></span></td>
								<td>
									<div class="date_del_scroll ATMgt_T" id="excepterViewDetailDiv">
										<input style="display:none;" id="excepterViewDetailInput" type="text" class="ui-autocomplete-input  HtmlCheckXSS ScriptCheckXSS"  autocomplete="off">
										<div class="ATMgt_T_r">
											<a class="btnTypeDefault nonHover type01" onclick="openOrgMapLayerPopup('excepterViewDetailDiv')"><spring:message code='Cache.btn_OrgManage' /></a>
										</div>
									</div>
								</Td>
							</tr>
							<tr>
								<td class="ATMgt_T_th"><spring:message code="Cache.lbl_Deduction"/><spring:message code="Cache.lbl_apv_vacation_year"/></td> <!-- 차감년도 -->
								<td>
									<div id="vacYearDiv"></div>
								</td>
							</tr>
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Period' /></td>
								<td>
									<div class="dateSel type02" style="display:inline-block;">				
										<input class="adDate" type="text" id="sDate" name="sDate" value="" style="width:87px;" autocomplete="off">
										~
										<input class="adDate" type="text" id="eDate" name="eDate" value="" style="width:87px;" autocomplete="off">
									</div>
								</td>
							</tr>
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Reason' /></td>
								<td>
									<input type="text" id="reason" name="reason" value=""/>
								</td>
							</tr>
							<tr>
								<td class="ATMgt_T_th"><spring:message code='Cache.VACATION_TYPE_VACATION_TYPE' /></td>
								<td>
									<select class="selectType02" id="vacTypeSel" name="vacTypeSel">
										<c:forEach var="item" items="${vacType.vacationType}">
											<option value="${item.CODE}" vac_data="${item.Reserved3}" >${item.CodeName}</option>
										</c:forEach>									
									</select>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>	
		</div>
		<div class="bottom" style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveVacation();" id="btn_SAVE"><spring:message code="Cache.btn_save" /></a>
			<a href="#" class="btnTypeDefault" onclick="javascript:Common.Close(); return false;"><spring:message code="Cache.lbl_close" /></a>
		</div>
	</div>
</div>
<script>	
	var orgMapDivEl = $("<p/>", {'class' : 'date_del', attr : {type : '', code : ''}}).append($("<a/>", {'class' : 'ui-icon ui-icon-close'}));
	var fromDatePickerOpt = {
			dateFormat: 'yy-mm-dd',
			buttonText: 'calendar',
			buttonImage: Common.getGlobalProperties("css.path") + "/covicore/resources/images/theme/blue/app_calendar.png",
			buttonImageOnly: true,
			rangeSelect: true,
			onSelect: function (selected) {
				var $end = $("#eDate");
				var startDate = new Date(selected.replaceAll(".", "-"));
				var endDate = new Date($end.val().replaceAll(".", "-"));

				if (startDate.getTime() > endDate.getTime()) {
					Common.Warning("<spring:message code='Cache.mag_Attendance19' />");	//시작일 보다 이전 일 수 없습니다.
					$("#sDate").val(endDate.format('yyyy-MM-dd'));
				}
			}
		};
	
	var toDatePickerOpt ={
		dateFormat: 'yy-mm-dd',
		buttonText: 'calendar',
		buttonImage: Common.getGlobalProperties("css.path") + "/covicore/resources/images/theme/blue/app_calendar.png",
		buttonImageOnly: true,
		rangeSelect: true,			
		onSelect: function (selected) {
			var $start = $("#sDate");
			var startDate = new Date($start.val().replaceAll(".", "-"));
			var endDate = new Date(selected.replaceAll(".", "-"));

			if (startDate.getTime() > endDate.getTime()) {
				Common.Warning("<spring:message code='Cache.mag_Attendance19' />");	//시작일 보다 이전 일 수 없습니다.
				$("#eDate").val(startDate.format('yyyy-MM-dd'));
			}
		}
	};

	$(document).ready(function() {
		$("#sDate").datepicker(fromDatePickerOpt);
		$("#eDate").datepicker(toDatePickerOpt);
		
		// 휴가유형 변경 이벤트. 반차 이하의 휴가일 경우 종료날짜를 시작날짜로 변경.
		$('#vacTypeSel').on('change', function(e) {
			if ( parseFloat($("#vacTypeSel option:selected").attr("vac_data")) < 1 ) {
                $("#eDate").val( $("#sDate").val() );
          	}
		});
		
		$("#vacYearDiv").html(parent.document.getElementById('schYearSel').outerHTML.replace('schYearSel', 'vacYear'));

		$(document).on('click', '.ui-icon-close', function(e) {
			e.preventDefault();
			$(this).parent().remove();
		});
	});
	
	// 조직도 팝업
	function openOrgMapLayerPopup(reqTar) {
		if(reqTar == "resultViewDetailDiv"){
			AttendUtils.openOrgChart("${authType}", "orgMapLayerPopupCallBack");
		}
		else if(reqTar == "excepterViewDetailDiv"){
			AttendUtils.openOrgChart("${authType}", "orgMapLayerPopupCallBackEx");
		} 
	}	

	// 조직도 팝업 콜백
	function orgMapLayerPopupCallBack(orgData) {
		var data = $.parseJSON(orgData);
		var item = data.item

		if (item != '') {
			var reqOrgMapTarDiv = 'resultViewDetailDiv' ;
			var duplication = false; // 중복 여부
			$.each(item, function (i, v) {
				var cloned = orgMapDivEl.clone();
				var type = (v.itemType == 'user') ? 'UR' : 'GR';
				var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;
				var CompanyCode = v.CompanyCode;
				
				if ($('#' + reqOrgMapTarDiv).find(".date_del[type='"+ type+"'][code='"+ code+"'][CompanyCode='"+ CompanyCode+"']").length > 0) {
					duplication = true;
					return true;
				}

				cloned.attr('type', type).attr('code', code).attr('CompanyCode', CompanyCode);
				cloned.find('.ui-icon-close').before(CFN_GetDicInfo(v.DN));

				$('#' + reqOrgMapTarDiv + ' .ui-autocomplete-input').before(cloned);
			});

			$("#resultViewDetailInput").hide();

			if(duplication){
				Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
			}
		}else {
			$("#resultViewDetailInput").show();
		}
	}
	
	//제외자 조직도 팝업 콜백
	function orgMapLayerPopupCallBackEx(orgData) {
		var data = $.parseJSON(orgData);
		var item = data.item

		if (item != '') {
			var reqOrgMapTarDiv = 'excepterViewDetailDiv' ;
			var duplication = false; // 중복 여부
			$.each(item, function (i, v) {
				var cloned = orgMapDivEl.clone();
				var type = (v.itemType == 'user') ? 'UR' : 'GR';
				var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;
				var CompanyCode = v.CompanyCode;
				
				if ($('#' + reqOrgMapTarDiv).find(".date_del[type='"+ type+"'][code='"+ code+"'][CompanyCode='"+ CompanyCode+"']").length > 0) {
					duplication = true;
					return true;
				}

				cloned.attr('type', type).attr('code', code).attr('CompanyCode', CompanyCode);
				cloned.find('.ui-icon-close').before(CFN_GetDicInfo(v.DN));

				$('#' + reqOrgMapTarDiv + ' .ui-autocomplete-input').before(cloned);
			});

			$("#excepterViewDetailInput").hide();

			if(duplication){
				Common.Warning('<spring:message code="Cache.lbl_surveyMsg10" />');
			}
		}else {
			$("#excepterViewDetailInput").show();
		}
	}
	
	function dateRangeCheck(){
		var startDate = new Date($("#input_sdate").val().replaceAll(".", "-"));
		var endDate = new Date($("#input_edate").val().replaceAll(".", "-"));

		if (startDate.getTime() > endDate.getTime()){
			Common.Warning("<spring:message code='Cache.mag_Attendance19' />"); //시작일 보다 이전 일 수 없습니다.
			$("#EndDate").val(startDate.format('yyyy-MM-dd'));
			return false;
		}
		
		return true;
	}
	
	function validityCheck() {
		if ($('#resultViewDetailDiv').find('.date_del').length == 0) {
			Common.Warning(Common.getDic("msg_Teams_SelectUser")); 							// 사용자를 선택해주세요.
			return false;
		} else if ($("#sDate").val() === undefined || $("#sDate").val() === "") {
			Common.Warning(Common.getDic("msg_EnterStartDate")); 							// 시작일자를 입력하세요
			return false;
		} else if ($("#eDate").val() === undefined || $("#eDate").val() === "") {
			Common.Warning(Common.getDic("msg_EnterEndDate")); 								// 종료일자를 입력하세요
			return false;
		} else if ($("#reason").val() === undefined || $("#reason").val() === "") {
			Common.Warning(Common.getDic("msg_apv_chk_reason")); 							// 사유를 입력해주세요.
			return false;
		} else if (($("#sDate").val() != $("#eDate").val()) && ( 1 > parseFloat($("#vacTypeSel option:selected").attr("vac_data")))) {
			// 시작기간과 종료기간이 일치하지 않는 여러 날일 경우, 반차 이하를 선택
			Common.Warning(Common.getDic("msg_vacationdate_rangecheck"));   				// 휴가 사용 기한을 확인 하여 주세요.
			return false;
		} else {
			return true;	
		}
	}
	
	// 엑셀 업로드
	function saveVacation() {
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		if (!validityCheck()) {
			return;
		}
		
		var sDate = $("#sDate").val();
		var eDate = $("#eDate").val();
		
		var start_day = sDate.split('-');
        var finish_day = eDate.split('-');
        
        var tmpday = 0;
		var vacTypeDay = parseFloat($("#vacTypeSel option:selected").attr("vac_data"));
		
		if (vacTypeDay < 1) {
			// 1일 미만의 연차일 경우.
			tmpday = vacTypeDay;
		} else {
			// 1일 이상의 휴가일 경우.
			var sObjDate = new Date(parseInt(start_day[0], 10), parseInt(start_day[1], 10) - 1, parseInt(start_day[2], 10));
            var eObjDate = new Date(parseInt(finish_day[0], 10), parseInt(finish_day[1], 10) - 1, parseInt(finish_day[2], 10));
            tmpday = eObjDate - sObjDate;
            tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24) + 1;
		}
		
		var targetUserArr = new Array();
		$('#resultViewDetailDiv').find('.date_del').each(function (i, v) {
			var item = $(v);
			var saveData = {"Type": item.attr('type'), "urCode": item.attr('code'), "urName" : item.text(), "CompanyCode": item.attr('CompanyCode')};
			targetUserArr.push(saveData);
		});
		
		var exceptUserArr = new Array();
		$('#excepterViewDetailDiv').find('.date_del').each(function (i, v) {
			var item = $(v);
			var saveData = {"Type": item.attr('type'), "urCode": item.attr('code'), "urName" : item.text(), "CompanyCode": item.attr('CompanyCode')};
			exceptUserArr.push(saveData);
		});
		
		$.ajax({
			url: '/groupware/vacation/insertJointVacation.do',
			data: {
				"urList": JSON.stringify(targetUserArr),
				"exList": JSON.stringify(exceptUserArr),
				"vacYear" : $("#vacYear").val(),
				"sDate" : sDate,
				"eDate" : eDate,
				"vacDay" : tmpday,
				"reason" : $("#reason").val(),
				"vacFlag" : $("#vacTypeSel").val()
			},
			type: 'POST',
			success: function(result) {
				if(result.status == 'SUCCESS'){
					var totalCount = result.data.totalCount;
					var duplicateCount = result.data.duplicateCount;
					
					if(duplicateCount <= 0) {
						Common.Inform(Common.getDic("msg_DeonRegist"), "Inform", function() { 	// 등록 되었습니다.
							parent.Common.Close("target_pop");
							parent.$(".btnRefresh").trigger("click")
						});
					} else {
						if(totalCount == duplicateCount) {
							Common.Warning("<spring:message code='Cache.msg_DuplicateUser'/>"); // 중복된 데이터가 있습니다. 사용자를 다시 선택해주세요.
						} else if(totalCount > duplicateCount) {
							Common.Inform(String.format("<spring:message code='Cache.msg_severalDataSave'/>", totalCount, duplicateCount), "Inform", function() { 	// {0}개 중 중복된 데이터 {1}개를 제외하고 등록 되었습니다.
								parent.Common.Close("target_pop");
								parent.$(".btnRefresh").trigger("click")
							});
						}
					}
				} else {
                	Common.Warning(result.message);
				}
			},
			error:function (error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}

	// 날짜 계산
	function calcDays(sDate, eDate) {
		return new Date(new Date(eDate) - new Date(sDate)) / (1000 * 60 * 60 * 24) + 1;
	}
</script>
