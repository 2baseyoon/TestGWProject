<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body>	

	<div class="collabo_popup_wrap">
<form id="frm">
		<div class="c_titBox">
			<h3 class="cycleTitle2"><spring:message code='Cache.lbl_doc_detailSetting' /></h3>	<!-- 상세설정 -->
		</div>

		<div class="tblList tblCont boradBottomCont StateTb">
			<div id="AXGridTarget" style="height: auto;">
				<a id="AXGridTarget_AX_grid_focus" href="#axtree"></a>
				<div class="AXGrid" id="AXGridTarget_AX_grid" style="overflow:hidden;height:auto;">
					<div class="AXgridScrollBody" id="AXGridTarget_AX_gridScrollBody" style="z-index: 2; height:141px;">
						<div class="AXGridColHead AXUserSelectNone" id="AXGridTarget_AX_gridColHead" onselectstart="return false;" style="width: 100%; left: 0px;">
							<table cellpadding="0" cellspacing="0" class="colHeadTable" style="width:100%;">
								<colgroup>
									<col width="120" style="" id="AXGridTarget_AX_col_AX_0_AX_CB">
									<col width="180" style="" id="AXGridTarget_AX_col_AX_1_AX_CB">
									<col width="*" style="" id="AXGridTarget_AX_col_AX_2_AX_CB">
								</colgroup>
								<tbody>
									<tr>
										<td valign="bottom" id="AXGridTarget_AX_colHead_AX_0_AX_1" class="colHeadTd" style="height:35px;">
											<div class="tdRelBlock" style="height:35px;">
												<div class="colHeadNode colHeadTdText" align="center" id="AXGridTarget_AX_colHeadText_AX_0_AX_1" style="padding-top: 7px;"><spring:message code='Cache.lbl_Gubun' /></div>	<!-- 구분 -->
												<a href="#AXexec" class="colHeadTool" id="AXGridTarget_AX_colHeadTool_AX_0_AX_1" style="top: 0;">T</a>
												<div class="colHeadResizer" id="AXGridTarget_AX_colHeadResizer_AX_0_AX_1" style="height: 35px;"></div>
											</div>
										</td>
										<td valign="bottom" id="AXGridTarget_AX_colHead_AX_0_AX_2" class="colHeadTd" style="height:35px;">
											<div class="tdRelBlock" style="height:35px;">
												<div class="colHeadNode colHeadTdText" align="center" id="AXGridTarget_AX_colHeadText_AX_0_AX_2" style="padding-top: 7px;"><spring:message code='Cache.btn_Setting' /></div>	<!-- 설정 -->
												<a href="#AXexec" class="colHeadTool" id="AXGridTarget_AX_colHeadTool_AX_0_AX_2" style="top: 0;">T</a>
												<div class="colHeadResizer" id="AXGridTarget_AX_colHeadResizer_AX_0_AX_2" style="height: 35px;"></div>
											</div>
										</td>
										<td valign="bottom" id="AXGridTarget_AX_colHead_AX_0_AX_3" class="colHeadTd" style="height:35px;">
											<div class="tdRelBlock" style="height:35px;">
												<div class="colHeadNode colHeadTdText" align="center" id="AXGridTarget_AX_colHeadText_AX_0_AX_3" style="padding-top: 7px;"><spring:message code='Cache.lbl_Description' /></div>	<!-- 설명 -->
												<a href="#AXexec" class="colHeadTool" id="AXGridTarget_AX_colHeadTool_AX_0_AX_3" style="top: 0;">T</a>
												<div class="colHeadResizer" id="AXGridTarget_AX_colHeadResizer_AX_0_AX_3" style="height: 35px;"></div>
											</div>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="AXGridToolGroup top" id="AXGridTarget_AX_gridToolGroupTop"></div>
						<div class="AXGridBody" id="AXGridTarget_AX_gridBody" style="top: 36px; height: 105px;">
							<div id="AXGridTarget_AX_scrollContent" class="gridScrollContent" style="width: 100%; left: 0px; top: 0px;">
								<table cellpadding="0" cellspacing="0" class="gridBodyTable" id="AXGridTarget_AX_gridBodyTable">
									<colgroup>
										<col width="120" style="" id="AXGridTarget_AX_col_AX_0_AX_CB">
										<col width="180" style="" id="AXGridTarget_AX_col_AX_1_AX_CB">
										<col width="*" style="" id="AXGridTarget_AX_col_AX_2_AX_CB">
									</colgroup>
									<thead id="AXGridTarget_AX_thead"></thead>
									<tbody id="AXGridTarget_AX_hpadding">
										<tr class="thpadding">
											<td colspan="3" style="height: 0px;"></td>
										</tr>
									</tbody>
									<tbody id="AXGridTarget_AX_tbody">
										<tr class="gridBodyTr gridBodyTr_0 line0" id="AXGridTarget_AX_tr_0_AX_n_AX_0">
											<td valign="middle" style="vertical-align:middle;" id="" class="bodyTd bodyTd_1 bodyTdr_0 " rowspan="1">
												<div class="bodyNode bodyTdText" align="center" id="" title="">
													<a href="#" class="slink"><spring:message code='Cache.msg_collab3' /></a>	<!-- 마감일 알림 -->
												</div>
											</td>
											<td valign="middle" style="vertical-align:middle;" id="" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
												<div class="bodyNode bodyTdText black" align="center" id="" title="">
													<div class="alarm type01">
														<a href="#" class="onOffBtn" id="DeadlineAlarmUse"><span></span></a>
													</div>
													<select id="add_AlarmSetep1" style="width:120px;height: 28px;"></select>
												</div>
											</td>
											<td valign="middle" style="vertical-align:middle;" id="" class="bodyTd bodyTd_3 bodyTdr_0 " rowspan="1">
												<div class="bodyNode bodyTdText black" align="left" id="" title=""><spring:message code='Cache.msg_collab4' /></div>	<!-- 마감일 전 알림을 받을 일정을 설정합니다. -->
											</td>
										</tr>
										<tr class="gridBodyTr gridBodyTr_0 line0" id="AXGridTarget_AX_tr_0_AX_n_AX_0">
											<td valign="middle" style="vertical-align:middle;" id="" class="bodyTd bodyTd_1 bodyTdr_0 " rowspan="1">
												<div class="bodyNode bodyTdText" align="center" id="" title="">
													<a href="#" class="slink"><spring:message code='Cache.msg_collab5' /></a>	<!-- 반복 알림 -->
												</div>
											</td>
											<td valign="middle" style="vertical-align:middle;" id="" class="bodyTd bodyTd_2 bodyTdr_0 " rowspan="1">
												<div class="bodyNode bodyTdText black" align="center" id="" title="">
													<div class="alarm type01">
														<a href="#" class="onOffBtn" id="RepeatAlarmUse"><span></span></a>
													</div>
													<select id="add_AlarmSetep2" style="width:120px;height: 28px;"></select>

												</div>
											</td>
											<td valign="middle" style="vertical-align:middle;" id="" class="bodyTd bodyTd_3 bodyTdr_0 " rowspan="1">
												<div class="bodyNode bodyTdText black" align="left" id="" title=""><spring:message code='Cache.msg_collab6' /></div>	<!-- 반복 알림을 받을 주기를 설정합니다. -->
											</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>

		
		<!-- 버튼영역 -->
		<div class="popBtnWrap">
			<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.lbl_Save'/></a>
			<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.btn_Close'/></a>
		</div>
		
		<div class="collabo_help">
			<p> <span class="bul"></span><spring:message code='Cache.msg_collab7' /></p>	<!-- 마감일 알림 일정과 반복 알림 주기를 설정할 수 있습니다. -->
			<p> <span class="bul"></span><spring:message code='Cache.msg_collab8' /><br>	<!-- [1일 전], [1시간 마다]를 선택하면, 마감일 하루 전부터 1시간 간격으로 알림을 받게 됩니다. -->
				&nbsp;&nbsp;	<spring:message code='Cache.msg_collab9' /></p>	<!-- 알람 시간은 기본 오전 9시이며, 스케쥴 설정에 포함된 시간에만 알림을 받을 수 있습니다. -->
		</div>
		
</form>

	</div>
</body>
<script type="text/javascript">
var collabClosingAlarm = {
		grid:'',
		objectInit : function(){	
			this.setSelect();
			this.addEvent();
			this.searchData();
		},
		addEvent : function(){	
			
			$(".onOffBtn").on('click',function(){
				if($(this).attr("class").lastIndexOf("on") > 0 ) {
					$(this).removeClass("on");
				}else{
					$(this).addClass("on");			
				}
			});
			
			$("#btnSave").on('click', function(){
				
				var data = $("#frm").serializeObject();
				
				data.deadlineAlarm = $("#add_AlarmSetep1").val();
				data.deadlineAlarmUse = $("#DeadlineAlarmUse").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
				data.repeatAlarm = $("#add_AlarmSetep2").val();
				data.repeatAlarmUse = $("#RepeatAlarmUse").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
				
				$.ajax({
					type : "POST",
					data : data,
					async: false,
					url : "/groupware/collabProject/saveClosingAlarm.do",
					success: function (list) {
						alert("<spring:message code='Cache.msg_com_processSuccess'/>");	//저장되었습니다.
					},
					error: function(response, status, error) {
						Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
					}
				});
			});
			
			$("#btnClose").on('click', function(){
				Common.Close();
			});
			
		},
		searchData:function(){
			$.ajax({
				type : "POST",
				async: false,
				url : "/groupware/collabProject/getClosingAlarm.do",
				success: function (result) {
					if (result.status == "SUCCESS") {
						
						if(result.data != null){
							if(result.data.DeadlineAlarmUse == "Y") $("#DeadlineAlarmUse").addClass("on");
							if(result.data.RepeatAlarmUse == "Y") $("#RepeatAlarmUse").addClass("on");
							
							if(result.data.DeadlineAlarm != null && result.data.DeadlineAlarm != '')
								$("#add_AlarmSetep1").val(result.data.DeadlineAlarm);
							if(result.data.RepeatAlarm != null && result.data.RepeatAlarm != '')
								$("#add_AlarmSetep2").val(result.data.RepeatAlarm);
						}
					}
				},
				error: function(response, status, error) {
					Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
				}
			});
				
		},
		setSelect:function(){
			// Select Box 바인드
			var initInfos = [
				{
					target : 'add_AlarmSetep1',
					codeGroup : 'AlarmSetep1',
					defaultVal : '',
					width : '120',
					onchange : ''
				},
				{
					target : 'add_AlarmSetep2',
					codeGroup : 'AlarmSetep2',
					defaultVal : '',
					width : '120',
					onchange : ''
				}
			];
			
			coviCtrl.renderAjaxSelect(initInfos, '', lang);
			
		}
}

$(document).ready(function(){
	collabClosingAlarm.objectInit();
});

</script>