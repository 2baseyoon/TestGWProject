<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>


<style>
	.pad10 { padding:10px;}
</style>

<div class="cRConTop titType">
	<h2 id="headerTitle" class="title"></h2>
</div>

<div class='cRContBottom mScrollVH'>
	<!-- 컨텐츠 시작 -->
	<div class="eaccountingCont">
		<div id="topitembar02" class="bodysearch_Type01" style="border: none; padding: 0px;">
			<div class="inPerView type07">
				<div style="width:900px;">
					<div class="inPerTitbox">
						<span id="companyCode" class="selectType02" onchange="Deadline.searchDeadline();">
						</span>
					</div>
				</div>
			</div>
		</div>
		<div id="topitembar02" class="bodysearch_Type01">
			<div class="inPerView type07" style="margin-bottom: 10px;">
				<div style="width:900px;">
					<span class="bodysearch_tit">
						<spring:message code='Cache.ACC_lbl_deadlineDate'/>	<!-- 마감일자 -->
					</span>
					<div class="inPerTitbox">
						<span id="standardMonth" class="selectType02">
						</span>
						<div id="deadline" class="dateSel type02">
						</div>
					</div>
				</div>
			</div>
			<div class="inPerView type07" style="margin-bottom: 10px;">
				<div style="width:900px;">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code='Cache.ACC_lbl_noticeText'/>	<!-- 공지사항 -->
						</span>
						<input type="text" id="noticeText" style="width: 500px;" />
					</div>
				</div>			
			</div>
			<div class="inPerView type07" style="margin-bottom: 10px;">
				<div style="width:900px;">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code='Cache.ACC_lbl_isUse'/> <!-- 사용여부 -->
						</span>
						<span id="isUse" class="selectType02">
						</span>
					</div>
				</div>
			</div>
			<div class="inPerView type07">
				<div style="width:900px;">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code='Cache.ACC_lbl_control'/> <!-- 통제여부 -->
						</span>
						<span id="control" class="selectType02">
						</span>
					</div>
					<a class="btnTypeDefault btnThemeLine" onclick="Deadline.deadlineAdd();"><spring:message code='Cache.ACC_btn_save'/></a>
				</div>
			</div>
		</div>
	</div>
</div>
	
<script>
	if (!window.Deadline) {
		window.Deadline = {};
	}
	
	(function(window) {
		var Deadline = {
				pageInit : function() {
					var me = this;
					setHeaderTitle('headerTitle');
					me.setSelectCombo();
					me.pageDatepicker();
					me.searchDeadline();
				},
				pageView : function() {
					var me = this;
					
					me.refreshCombo();
				},
				pageDatepicker : function(){
					makeDatepicker('deadline', 'deadlineStart', 'deadlineFinish', '', '', '');
				},
				setSelectCombo : function(){
					var AXSelectMultiArr = [	
						{ 
							'codeGroup':'CompanyCode',		
							'target':'companyCode',		
							'lang':'ko',	
							'onchange':'',	
							'oncomplete':'',	
							'defaultVal':''
						},
						{
							'codeGroup':'StandardMonth',	
							'target':'standardMonth',	
							'lang':'ko',	
							'onchange':'',	
							'oncomplete':'',	
							'defaultVal':''
						},
						{
						   	'codeGroup': 'IsUse',
						   	'target': 'isUse',
						   	'lang': 'ko',
						   	'onchange':'',
						   	'oncomplete':'',
						   	'defaultVal':'Y'
					    },
					   	{
							'codeGroup': 'DeadlineControl',
						   	'target': 'control',
						   	'lang': 'ko',
						   	'onchange':'',
						   	'oncomplete':'',
						   	'defaultVal':'N'
					   	}
   					]
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},
				searchDeadline : function(){
					$.ajax({
						url : "/account/deadline/getDeadlineInfo.do",
						type : "POST",
						data : {
							"companyCode" : accountCtrl.getComboInfo("companyCode").val()
						},
						success : function(data) {
							if (data.status == "SUCCESS"){
								if(data.list.length > 0) {
									accountCtrl.getInfo('deadlineStart').val(data.list[0].DeadlineStartDate);
									accountCtrl.getInfo('deadlineFinish').val(data.list[0].DeadlineFinishDate);
									accountCtrl.getInfo('noticeText').val(data.list[0].NoticeText);
									accountCtrl.getComboInfo("standardMonth").val(data.list[0].StandardMonth);
									accountCtrl.refreshAXSelect("standardMonth");
									
									accountCtrl.getComboInfo("isUse").val(data.list[0].IsUse); // 사용여부
									accountCtrl.refreshAXSelect("isUse");
									accountCtrl.getComboInfo("control").val(data.list[0].Control); // 통제여부
									accountCtrl.refreshAXSelect("control");
								}
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error : function(error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					});
				},
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("companyCode");
					accountCtrl.refreshAXSelect("standardMonth");
					accountCtrl.refreshAXSelect("isUse");
					accountCtrl.refreshAXSelect("control");
				},
				deadlineAdd : function(){
					var companyCode = accountCtrl.getComboInfo("companyCode").val();
					var noticeText = accountCtrl.getInfo("noticeText").val();
					var StandardMonth = accountCtrl.getComboInfo("standardMonth").val();
					
					var stDt = accToString(accountCtrl.getInfo('deadlineStart').val());
					var edDt = accToString(accountCtrl.getInfo('deadlineFinish').val());					
					if (stDt == "" || edDt == "") {
						Common.Inform("<spring:message code='Cache.ACC_msg_selectDate' />"); //날짜를 선택해 주세요.
						return;
					}
					
					var DeadlineStartDate = stDt.replaceAll(".", "");
					var DeadlineFinishDate = edDt.replaceAll(".", "");					
					if (DeadlineStartDate > DeadlineFinishDate){
						Common.Inform("<spring:message code='Cache.ACC_msg_startDate' />");	//시작 날짜를 확인해 주세요
						return;
					}
					
					let isUse = accountCtrl.getComboInfo("isUse").val(); // 사용여부
					let control = accountCtrl.getComboInfo("control").val(); // 통제여부
					
					$.ajax({
						url : "/account/deadline/saveDeadlineInfo.do",
						type : "POST",
						data : {
							"companyCode"			: companyCode,
							"noticeText"			: noticeText,
							"deadlineStartDate"		: DeadlineStartDate,
							"deadlineFinishDate"	: DeadlineFinishDate,
							"standardMonth"			: StandardMonth,
							"isUse": isUse,
							"control": control
						},
						success : function(data) {
							if (data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>"); //저장되었습니다.
								Deadline.refresh();
							} else {
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error : function(error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}
					});
				},
				refresh : function(){
					accountCtrl.pageRefresh();
				}		
		}
	window.Deadline = Deadline;
	})(window);
</script>
