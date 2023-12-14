<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent extensionAddPopup" style="padding: 20px 24px 30px;">
	<div class="">
		<div class="top" style="height:320px;">
			<div class="schShareList">
				<div class="ATMgt_work_wrap">
					<div style="height: 50px;width: 100%;vertical-align: middle;background-color: #f4fdff;padding: 20px;;border: solid 1px #666 !important;">
						<p style="font-size: 14px"><spring:message code='Cache.msg_vacationcancel_confirm'/></p>
					</div>
					<br/>
					<table class="ATMgt_popup_table type03" cellpadding="0" cellspacing="0">
						<colgroup>
							<col style="width: calc(50% - 60px);"/>
							<col style="width: 20px;"/>
							<col style="width: 20px;"/>
							<col style="width: 20px;"/>
							<col style="width: calc(50% - 60px);"/>
							<col style="width: 20px;"/>
							<col style="width: 20px;"/>
							<col style="width: 20px;"/>
						</colgroup>
						<thead>
						<tr>
							<td class="ATMgt_T_th" colspan="8" style="text-align: center;font-weight: bold;"><spring:message code='Cache.lbl_hrMng_targetUser'/> <spring:message code='Cache.lbl_apv_list'/></td>
						</tr>
						<tr style="text-align: center;">
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_name'/></td>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_RemainVacation'/></td>
							<td class="ATMgt_T_th"><spring:message code='Cache.Messaging_Cancel'/><spring:message code='Cache.VACATION_TYPE_VACATION_ANNUAL'/></td>
							<td class="ATMgt_T_th" style="font-weight: bold;"><spring:message code='Cache.VACATION_TYPE_VACATION_ANNUAL'/><spring:message code='Cache.lbl_sum'/></td>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_name'/></td>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_RemainVacation'/></td>
							<td class="ATMgt_T_th"><spring:message code='Cache.Messaging_Cancel'/><spring:message code='Cache.VACATION_TYPE_VACATION_ANNUAL'/></td>
							<td class="ATMgt_T_th" style="font-weight: bold;"><spring:message code='Cache.VACATION_TYPE_VACATION_ANNUAL'/><spring:message code='Cache.lbl_sum'/></td>
						</tr>
						</thead>
						<tbody id="tbody_checkData">
						</tbody>
					</table>
					<div class="AXgridPageBody" style="width: 100%;">
						<div style="width: 10%;float: left;">&nbsp;</div>
						<div id="div_pagging" style="width: 80%;float: left;text-align:center;margin-top:2px;"></div>
						<div style="width: 10%;float: left;text-align:right;height: 50px;vertical-align: middle;"><p id="p_totCnt" style="margin: 25px 0 0 0;">&nbsp;</p></div>
					</div>
				</div>
			</div>
		</div>
		<div class="bottom" style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveVacation();" id="btn_SAVE"><spring:message code="Cache.lbl_apv_determine" /></a>
			<a href="#" class="btnTypeDefault" onclick="javascript:Common.Close(); return false;"><spring:message code="Cache.lbl_close" /></a>
		</div>
	</div>
</div>

<script>
	var g_step = 1;
	var _pageNo     = 1;
	var _pageSize   = 8;
	var _endPage    = 1;
	var orgMapDivEl = $("<p/>", {'class' : 'date_del', attr : {type : '', code : ''}}).append($("<a/>", {'class' : 'ui-icon ui-icon-close'}));

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

		var delArry = new Array();
		for(var i=0;i<$("input[name=chk]:checked", parent.document.body).length;i++){
			delArry.push($("input[name=chk]:checked", parent.document.body).eq(i).val());
		}
		var params = {
			"vacationInfoID" : JSON.stringify(delArry)
			,"year" : "${year}"
			,"pageNo": _pageNo
			,"pageSize": _pageSize
		};
		$.ajax({
			type:"POST",
			dataType : "json",
			data: params,
			url:"/groupware/vacation/getVacationCancelCheck.do",
			success:function (data) {
				if(data.status =="SUCCESS"){
					$("#div_pagging").html(pagging(data.page));
					$("#p_totCnt").html("<spring:message code='Cache.lbl_total'/>"+data.page.listCount+"<spring:message code='Cache.lbl_CountMan'/>");
					makeCheckData(data.list);
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
				}
			}
		});
	}

	function makeCheckData(data){
		var html = '<tr style="text-align: center;">';
		$(data).each(function(i, item){
			if(i%2===0&&i>1){
				html += '</tr><tr style="text-align: center;">';
			}
			html += '<td>'+item.DisplayName+'</td>';
			html += '<td>'+item.VacDayRemain+'</td>';
			html += '<td>'+item.VacDay+'</td>';
			var sumVac = parseFloat(item.VacDay)+parseFloat(item.VacDayRemain);
			html += '<td style="font-weight: bold;">'+sumVac+'</td>';
		});
		if(data.length%2===1){
			html += '<td colspan="4">&nbsp;</td>';
		}
		html += '</tr>';
		$("#tbody_checkData").html(html);
	}

	$(document).ready(function() {
		$("#input_sdate").datepicker({
			dateFormat: 'yy-mm-dd',
			buttonText: 'calendar',
			buttonImage: Common.getGlobalProperties("css.path") + "/covicore/resources/images/theme/blue/app_calendar.png",
			buttonImageOnly: true
		});
		$("#input_edate").datepicker({
			dateFormat: 'yy-mm-dd',
			buttonText: 'calendar',
			buttonImage: Common.getGlobalProperties("css.path") + "/covicore/resources/images/theme/blue/app_calendar.png",
			buttonImageOnly: true,
			onSelect: function (selected) {
				var $start = $("#input_sdate");
				var startDate = new Date($start.val().replaceAll(".", "-"));
				var endDate = new Date(selected.replaceAll(".", "-"));

				if (startDate.getTime() > endDate.getTime()) {
					Common.Warning("<spring:message code='Cache.mag_Attendance19' />");	//시작일 보다 이전 일 수 없습니다.
					$("#input_edate").val(startDate.format('yyyy-MM-dd'));
				}
			}
		});

		$(document).on('click', '.ui-icon-close', function(e) {
			e.preventDefault();
			$(this).parent().remove();
		});

		movePagging(1);
	});//end onReady

	function validationChk(){
		if($('#resultViewDetailDiv').find('.date_del').length == 0){
			Common.Warning("<spring:message code='Cache.msg_apv_271'/>");
			return;
		}

		if($("#input_vacday").val()=="") {
			Common.Warning("<spring:message code='Cache.lbl_apv_Vacation_days'/> <spring:message code='Cache.CPMail_PleaseSelect'/>");
			$("#input_vacday").focus();
			return;
		}else if(isNaN(parseFloat($("#input_vacday").val()))){
			Common.Warning("[<spring:message code='Cache.lbl_apv_Vacation_days'/>]<spring:message code='Cache.msg_apv_249'/>");
			$("#input_vacday").focus();
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


		return true;

	}
	// 저장
	function saveVacation() {
		parent.vacationVacationCancelManager.delVacation();
	}

	// 날짜 계산
	function calcDays(sDate, eDate) {
		return new Date(new Date(eDate) - new Date(sDate)) / (1000 * 60 * 60 * 24) + 1;

	}
</script>
