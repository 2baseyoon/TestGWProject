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
							<td class="ATMgt_T_th"><spring:message code='Cache.ObjectType_UR' /></span></td>
							<td>
								<div class="date_del_scroll ATMgt_T" id="resultViewDetailDiv">
									<input id="resultViewDetailInput" type="text" class="ui-autocomplete-input  HtmlCheckXSS ScriptCheckXSS"  autocomplete="off">
									<div class="ATMgt_T_r">
										<a class="btnTypeDefault nonHover type01" onclick="openOrgMapLayerPopup('resultViewDetailDiv')"><spring:message code='Cache.btn_OrgManage' /></a>
									</div>
								</div>
							</Td>
						</tr>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_apv_Vacation_days' /></td> <!-- 설정 방식 -->
							<td>
								<input type="text" id="input_vacday" name="input_vacday" value="0" style="width:20%;"/>day
								<input type="text" id="input_vacmin" name="input_vacmin" value="0" style="width:20%;"/>min
								<!-- <select id="input_vachour" name="input_vacday" style="width:15%; margin-left:10px">
									<option value="0"><spring:message code='Cache.btn_Select' /></option>
									<option value="60">1시간</option>
									<option value="120">2시간</option>
									<option value="180">3시간</option>
									<option value="240">4시간</option>
									<option value="300">5시간</option>
									<option value="360">6시간</option>
									<option value="420">7시간</option>
								</select>
								<select id="input_vacmin" name="input_vacday" style="width:15%;">
									<option value="0"><spring:message code='Cache.btn_Select' /></option>
									<option value="10">10분</option>
									<option value="20">20분</option>
									<option value="30">30분</option>
									<option value="40">40분</option>
									<option value="50">50분</option>
								</select> -->
								<div id="vacdaymin" style="display: inline; float: right; line-height: 28px;">(0.0 vac / 0 hour / 0 min)</div>
							</td>
						</tr>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.VACATION_TYPE_VACATION_TYPE' /></td> <!-- 설정 방식 -->
							<td>
								<select id="sel_vackind" name="sel_vackind">
									<option value=""><spring:message code='Cache.btn_Select' /></option>
									<c:forEach var="item" items="${vacType.list}">
										<option value="${item.Code}">${item.CodeName}</option>
									</c:forEach>
								</select>
							</td>
						</tr>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_expiryDate' /></td> <!-- 설정 방식 -->
							<td>
								<input class="adDate" type="text" id="input_sdate" value="" style="width:87px;" onchange="dateRangeCheck()">
								~
								<input class="adDate" type="text" id="input_edate" value="" style="width:87px;" onchange="dateRangeCheck()" >
							</td>
						</tr>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Reason' /></td> <!-- 설정 방식 -->
							<td>
								<input type="text" id="input_comment" name="input_comment" value=""/>
							</td>
						</tr>
						</tbody>
					</table>
					<table class="ATMgt_popup_table type03" cellpadding="0" cellspacing="0" id="step2" style="display: none;">
						<colgroup>
							<col style="width: calc(50% - 60px);"/>
							<col style="width: 30px;"/>
							<col style="width: 30px;"/>
							<col style="width: calc(50% - 60px);"/>
							<col style="width: 30px;"/>
							<col style="width: 30px;"/>
						</colgroup>
						<thead>
						<tr>
							<td class="ATMgt_T_th" colspan="6" style="text-align: center;"><spring:message code='Cache.lbl_hrMng_targetUser'/> <spring:message code='Cache.lbl_apv_list'/></td>
						</tr>
						<tr style="text-align: center;">
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_name'/></td>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_cert_now'/><spring:message code='Cache.VACATION_TYPE_VACATION_ANNUAL'/></td>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_sum'/></td>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_name'/></td>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_cert_now'/><spring:message code='Cache.VACATION_TYPE_VACATION_ANNUAL'/></td>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_sum'/></td>
						</tr>
						</thead>
						<tbody id="tbody_checkData">
						</tbody>
					</table>
					<div class="AXgridPageBody" style="display: none;width: 100%;">
						<div style="width: 10%;float: left;">&nbsp;</div>
						<div id="div_pagging" style="width: 80%;float: left;text-align:center;margin-top:2px;"></div>
						<div style="width: 10%;float: left;text-align:right;height: 50px;vertical-align: middle;"><p id="p_totCnt" style="margin: 25px 0 0 0;">&nbsp;</p></div>
					</div>
				</div>
			</div>	
		</div>
		<div class="bottom" style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveVacation();" id="btn_SAVE"><spring:message code="Cache.btn_save" /></a>
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="displayStep(1);" id="btn_BACK" style="display: none;"><spring:message code="Cache.lbl_goBack" /></a>
			<a href="#" class="btnTypeDefault" onclick="javascript:Common.Close(); return false;"><spring:message code="Cache.lbl_close" /></a>
		</div>
	</div>
</div>

<script>
	var g_step = 1;
	var g_errCnt = 0;
	var _pageNo     = 1;
	var _pageSize   = 8;
	var _endPage    = 1;
	var orgMapDivEl = $("<p/>", {'class' : 'date_del', attr : {type : '', code : ''}}).append($("<a/>", {'class' : 'ui-icon ui-icon-close'}));
	var _RewardVacDay = 0;
	var _VacDay = 0;
	
// 조직도 팝업
	function openOrgMapLayerPopup(reqTar) {
		AttendUtils.openOrgChart("${authType}", "orgMapLayerPopupCallBack");
	}

	function displayStep(idx) {
		g_step = idx;
		if (idx === 1) {
			$("#btn_BACK").hide();
			$("#step1").show();
			$("#step2").hide();
			$("#btn_SAVE").html("<spring:message code="Cache.btn_save" />");
			$(".AXgridPageBody").hide();
		} else if (idx === 2) {
			$("#btn_BACK").show();
			$("#step1").hide();
			$("#step2").show();
			$("#btn_SAVE").html("<spring:message code="Cache.lbl_apv_determine" />");
			$(".AXgridPageBody").show();
			movePagging(1);
		}
	}


	function goPage(pnum){
		_pageNo = pnum;
		$(".AXPaging").each(function(idx){
			$(this).removeClass("Blue");
			var valNum = $(this).attr("value");
			if(Number(valNum)===_pageNo){
				$(this).addClass("Blue");
			}
		});
		movePagging(pnum);
	}

	function pagging(deptPage){
		//pageing
		var pageNo = Number(deptPage.pageNo);
		var sPage = pageNo - 5;
		if(sPage<1){
			sPage = 1;
		}
		var lPage = sPage + 9;
		if(lPage>Number(deptPage.pageCount)){
			lPage = Number(deptPage.pageCount);
		}
		var nextPage = Number(lPage)+1;
		if(nextPage>Number(deptPage.pageCount)){
			nextPage = Number(deptPage.pageCount);
		}
		var prePage = Number(sPage)-1;
		if(prePage<1){
			prePage = 1;
		}
		var firstPage = 1;
		var endPage = Number(deptPage.pageCount);
		var htmlStr = "";
		htmlStr+='<input type="button" id="AXPaging_begin" class="AXPaging_begin" onclick="javascript:goPage('+firstPage+');">';
		htmlStr+='<input type="button" id="AXPaging_prev" class="AXPaging_prev" onclick="javascript:goPage('+prePage+');">';

		for(var i=sPage;i<=lPage;i++){
			var blue = "";
			if(_pageNo==i){
				blue = " Blue";
			}
			htmlStr+='<input type="button" value="'+i+'" style="min-width:20px;" class="AXPaging'+blue+'" onclick="javascript:goPage('+i+');">';
		}
		htmlStr+='<input type="button" id="AXPaging_next" class="AXPaging_next" onclick="javascript:goPage('+nextPage+');">';
		htmlStr+='<input type="button" id="AXPaging_end" class="AXPaging_end" onclick="javascript:goPage('+endPage+');">';
		return htmlStr;
	}


	function movePagging(pageNo){
		_pageNo =pageNo;

		var sdate = $("#input_sdate").val();
		var edate = $("#input_edate").val();
		var targetUserArr = new Array();
		$('#resultViewDetailDiv').find('.date_del').each(function (i, v) {
			var item = $(v);
			var saveData = {"Type": item.attr('type'), "Code": item.attr('code')};
			targetUserArr.push(saveData);
		});

		var paramMap = {
			"pageNo": _pageNo,
			"pageSize": _pageSize,
			"year": sdate.substring(0, 4),
			"urCode": targetUserArr,
			"vacDay": _VacDay,
			"sDate" : sdate,
			"eDate" : edate,
			"vacKind" : $("#sel_vackind option:selected").val()
		};

		$.ajax({
			type : "POST",
			contentType:'application/json; charset=utf-8',
			dataType   : 'json',
			data : JSON.stringify(paramMap),
			url: "/groupware/vacation/checkExtraVacation.do",
			success:function (data) {
				if(data.status=="SUCCESS"){
					$("#div_pagging").html(pagging(data.page));
					$("#p_totCnt").html("<spring:message code='Cache.lbl_total'/>"+data.page.listCount+"<spring:message code='Cache.lbl_CountMan'/>");
					makeCheckData(data.list);
				}else{
					Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>");
				}
			},
			error:function (request,status,error){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			}
		});
	}

	function makeCheckData(data){
		g_errCnt = 0;
		var html = '<tr style="text-align: center;">';
		$(data).each(function(i, item){
			if(i%2===0&&i>1){
				html += '</tr><tr style="text-align: center;">';
			}
			var existDate = item.ExistDate;
			html += '<td>'+item.DisplayName+'</td>';
			if(existDate===""){
				html += '<td>'+item.VacDay+'</td>';
				html += '<td>'+item.TotVacDay+'</td>';
			}else{
				html += '<td colspan="2" style="color: #FF6600"><spring:message code='Cache.lbl_vacation_schedule' /> <spring:message code='Cache.lbl_duplicate2' />('+existDate+')</td>';
				g_errCnt++;
			}
		});
		if(data.length%2===1){
			html += '<td colspan="3">&nbsp;</td>';
		}
		html += '</tr>';
		$("#tbody_checkData").html(html);
	}

	function getVacationCreateMethodConfigVal(){
		var CreateMethod = "";
		$.ajax({
			type : "POST",
			url : "/groupware/vacation/getVacationConfigVal.do",
			data: {
				getName: "CreateMethod"
			},
			async:false,
			success:function (data) {
				if(data.status == 'SUCCESS') {
					if(data.data!=null && data.data!=""){
						CreateMethod = data.data;
					}
				} else {
					Common.Warning("<spring:message code='Cache.msg_apv_030' />");
				}
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
		return CreateMethod;
	}

	// 연차 사용정보
	function setDatePicker() {
		var CreateMethod = getVacationCreateMethodConfigVal();
		var urlPath = "";
		if(CreateMethod==="J"){
			urlPath = "/groupware/vacation/getUserVacationInfoV2.do";
		}else{
			urlPath = "/groupware/vacation/getUserVacationInfo.do";
		}
		$.ajax({
			type : "POST",
			data : {year : "${year}"},
			async: false,
			url : urlPath,
			success:function (list) {
				var data = list.list[0];
				var range = data.NOWYEAR;
				var arrRange = range.split("~");
				var from = arrRange[0].replace(' ','');
				var to = arrRange[1].replace(' ','');
				var fromDatePickerOpt = {
					dateFormat: 'yy-mm-dd',
					buttonText: 'calendar',
					buttonImage: Common.getGlobalProperties("css.path") + "/covicore/resources/images/theme/blue/app_calendar.png",
					buttonImageOnly: true,
					rangeSelect: true,
					minDate: from,
					maxDate: to
				};
				var toDatePickerOpt ={
					dateFormat: 'yy-mm-dd',
					buttonText: 'calendar',
					buttonImage: Common.getGlobalProperties("css.path") + "/covicore/resources/images/theme/blue/app_calendar.png",
					buttonImageOnly: true,
					rangeSelect: true,
					minDate: from,
					maxDate: to,
					onSelect: function (selected) {
						var $start = $("#input_sdate");
						var startDate = new Date($start.val().replaceAll(".", "-"));
						var endDate = new Date(selected.replaceAll(".", "-"));

						if (startDate.getTime() > endDate.getTime()) {
							Common.Warning("<spring:message code='Cache.mag_Attendance19' />");	//시작일 보다 이전 일 수 없습니다.
							$("#input_edate").val(startDate.format('yyyy-MM-dd'));
						}
					}
				};
				$("#input_sdate").datepicker(fromDatePickerOpt);
				$("#input_edate").datepicker(toDatePickerOpt);
			},
			error:function(response, status, error) {
				CFN_ErrorAjax("/groupware/vacation/getUserVacationInfo.do", response, status, error);
			}
		});
	}

	$(document).ready(function() {
		setDatePicker();

		$(document).on('click', '.ui-icon-close', function(e) {
			e.preventDefault();
			$(this).parent().remove();
		});
		
		$("#input_vacday, #input_vacmin").on('change', function(e) {
			_RewardVacDay = Number($("#input_vacday").val() * 480) + Number($("#input_vacmin").val());
			_VacDay = parseInt(_RewardVacDay / 60) * 0.125;
			var vacHour = parseInt(_RewardVacDay / 60);
			$("#vacdaymin").text("( " + _VacDay + " vac / " + vacHour + " hour / "+ _RewardVacDay +" min)");
		});
		
		
	});//end onReady

	// 조직도 팝업 콜백
	function orgMapLayerPopupCallBack(orgData) {
		var data = $.parseJSON(orgData);
		var item = data.item;

		if (item != '') {
			var reqOrgMapTarDiv = 'resultViewDetailDiv' ;
			var duplication = false; // 중복 여부
			$.each(item, function (i, v) {
				var cloned = orgMapDivEl.clone();
				var type = (v.itemType == 'user') ? 'UR' : 'GR';
				var code = (v.itemType == 'user') ? v.UserCode : v.GroupCode;

				if ($('#' + reqOrgMapTarDiv).find(".date_del[type='"+ type+"'][code='"+ code+"']").length > 0) {
					duplication = true;
					return true;
				}

				cloned.attr('type', type).attr('code', code);
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
	function validationChk(){
		if($('#resultViewDetailDiv').find('.date_del').length == 0){
			Common.Warning("<spring:message code='Cache.msg_apv_271'/>");
			return;
		}

		if(_RewardVacDay == 0) {
			Common.Warning("<spring:message code='Cache.lbl_apv_Vacation_days'/> <spring:message code='Cache.CPMail_PleaseSelect'/>");
			$("#input_vacday").focus();
			return;
		}else if(isNaN(parseFloat($("#input_vacday").val()))){
			Common.Warning("[<spring:message code='Cache.lbl_apv_Vacation_days'/>]<spring:message code='Cache.msg_apv_249'/>");
			$("#input_vacday").focus();
			return;
		}else if(isNaN(parseFloat($("#input_vacmin").val()))){
			Common.Warning("[<spring:message code='Cache.lbl_apv_Vacation_days'/>]<spring:message code='Cache.msg_apv_249'/>");
			$("#input_vacmin").focus();
			return;
		}

		if($("#sel_vackind option:selected").val()==""){
			Common.Warning("<spring:message code='Cache.VACATION_TYPE_VACATION_TYPE'/> <spring:message code='Cache.CPMail_PleaseSelect'/>");
			$("#input_sdate").focus();
			return;
		}
		if($("#input_sdate").val()==""){
			Common.Warning("<spring:message code='Cache.CPMail_PleaseSelectValidityPeriod'/>");
			$("#input_sdate").focus();
			return;
		}
		if($("#input_edate").val()==""){
			Common.Warning("<spring:message code='Cache.CPMail_PleaseSelectValidityPeriod'/>");
			$("#input_edate").focus();
			return;
		}
		if($("#input_comment").val()==""){
			Common.Warning("<spring:message code='Cache.msg_EnterReason'/>");
			$("#input_comment").focus();
			return;
		}
		if(!dateRangeCheck()){
			return;
		}


		return true;

	}
	// 저장
	function saveVacation() {
		if(g_step===1) {
			if (!validationChk()) {
				return;
			}
			displayStep(2);
		}else if(g_step===2) {
			if(g_errCnt>0){
				Common.Warning("<spring:message code='Cache.lbl_vacation_schedule' /> <spring:message code='Cache.msg_sns_doubled' />");
				return;
			}
			var sdate = $("#input_sdate").val();
			var targetUserArr = new Array();
			$('#resultViewDetailDiv').find('.date_del').each(function (i, v) {
				var item = $(v);
				var saveData = {"Type": item.attr('type'), "Code": item.attr('code')};
				targetUserArr.push(saveData);
			});
			
			var paramMap = {
				"year": sdate.substring(0, 4),
				"urCode": targetUserArr,
				"vacKind": $("#sel_vackind option:selected").val(),
				"sDate": $('#input_sdate').val().replaceAll("-", ""),
				"eDate": $('#input_edate').val().replaceAll("-", ""),
				"vacDay": _VacDay,
				"rewardVacDay": _RewardVacDay,
				"comment": $('#input_comment').val()
			};

			Common.Confirm("<spring:message code='Cache.msg_155' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					$.ajax({
						type: "POST",
						contentType: 'application/json; charset=utf-8',
						data: JSON.stringify(paramMap),
						url: "/groupware/vacation/insertRewardVacation.do",
						success: function (data) {
							if (data.result == "ok") {
								if (data.status == 'SUCCESS') {
									Common.Inform("<spring:message code='Cache.msg_37' />", "Inform", function () {
										parent.Common.Close("target_pop");

										parent.$(".btnRefresh").trigger("click");
									});
								} else {
									Common.Warning("<spring:message code='Cache.msg_apv_030' />");
								}
							} else {
								Common.Inform(data.message, "Inform", function () {
									parent.Common.Close("target_pop");
								});
							}
						},
						error: function (response, status, error) {
							CFN_ErrorAjax("/groupware/vacation/insertRewardVacation.do", response, status, error);
						}
					});
				} else {
					return false;
				}
			});
		}
	}

	// 날짜 계산
	function calcDays(sDate, eDate) {
		return new Date(new Date(eDate) - new Date(sDate)) / (1000 * 60 * 60 * 24) + 1;

	}
</script>
