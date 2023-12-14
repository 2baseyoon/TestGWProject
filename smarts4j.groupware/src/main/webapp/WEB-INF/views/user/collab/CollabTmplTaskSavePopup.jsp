<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/collab_util.js"></script>
<style>
	.ui-autocomplete-multiselect.ui-state-default{width:100% !important;border:0px}
	.ui-autocomplete-multiselect input{width:200px !important; border:0px !important}
</style>
<body>	
<div class="collabo_popup_wrap">
<form id="form1">
	<div class="c_titBox">
		<h3 class="cycleTitle">
		<c:if test="${taskData =='' || taskData.TaskSeq eq null  }">
			${tmplName}
			<c:if test="${sectionName !=''  }">
			> ${sectionName}
			</c:if>
		</c:if>	
		<c:if test="${taskData !='' && taskData.TaskSeq ne null  }">
		<spring:message code='Cache.lbl_WorkInformation'/>		<!-- 업무 정보 -->
		</c:if>	
		</h3>
	</div>
	<div class="collabo_table_wrap mb40">
		<table class="collabo_table">
			<colgroup>
				<col width="106">
				<col width="*">
				<col width="106">
				<col width="*">
			</colgroup>
			<tr>
				<th>*<spring:message code='Cache.lbl_workname'/></th>
				<td colspan=3><input type="text" class="w100" id="taskName" name="taskName" value="${taskData.TaskName}"/>	</td>	
			</tr>
			<tr>	
				<th>범주</th>
				<td>
					<div class="cusSelect02">
						<input type="txt" readonly="" class="selectValue" value="${taskData.Label}">
						<span class="sleOpTitle">
							<c:if test="${taskData.Label == 'E'}">
								<span class="important"></span> <spring:message code="Cache.lbl_Urgency" />
							</c:if>
						</span>
						<ul class="selectOpList">
							<li data-selvalue="E"><span class="important"></span> <spring:message code='Cache.lbl_Urgency' /></li> <!-- 긴급 -->
							<li data-selvalue=""></li> <!-- 긴급 -->
						</ul>
					</div>
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_detailworkname'/></th>
				<td colspan=3><textarea id="remark" name="remark">${taskData.Remark}</textarea></td>
			</tr>
		</table>

		<div class="popBtnWrap">
			<c:if test="${taskData =='' || taskData.TaskSeq eq null  }">
				<a href="#" class="btnTypeDefault btnTypeBg" id="btnAdd"><spring:message code='Cache.lbl_AddTask'/></a>
			</c:if>
			<c:if test="${taskData !='' && taskData.TaskSeq ne null  }">
				<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.lbl_SaveTask'/></a>
			</c:if>
			
			<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.lbl_Cancel'/></a>
		</div>
	</div>
</form>	
</div>
<!-- ê¸°íê·¼ë¬´ë±ë¡ íì ë -->
</body>
<script type="text/javascript">
var collabTaskAdd = {
		callbackFunc:CFN_GetQueryString("callBackFunc"),
		objectInit : function(){			
			this.addEvent();
		}	,
		addEvent : function(){
			collabUtil.attachEventAutoTags("resultViewMemberInput");
			$('.sleOpTitle').on('click', function(){
		 		if($(this).hasClass('active')){
		 			$(this).removeClass('active');
		 			$('.selectOpList').removeClass('active');
		 		}else {
		 			$(this).addClass('active');
		 			$('.selectOpList').addClass('active');
		 		}
		 	});
			
		 	$('.selectOpList>li').on('click', function(){
		 		$('.sleOpTitle').html($(this).html());
		 		$('.selectValue').val($(this).data( "selvalue" ));
		 		$('.sleOpTitle').removeClass('active');
		 		$(this).closest('.selectOpList').removeClass('active');
		 	});
		 	
			$("#btnSave").on('click', function(){
				if(!collabTaskAdd.validationChk())     	return ;
				//Common.Confirm("<spring:message code='Cache.msg_RUSave' />", "Confirmation Dialog", function (confirmResult) {
				//	if (confirmResult) {
						var taskData = collabTaskAdd.getTaskData();
						$.ajax({
							type:"POST",
							enctype: 'multipart/form-data',
							data: taskData,
							processData: false,
							contentType: false,
							url:"/groupware/collabTmpl/saveTmplTask.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>", "Confirmation Dialog", function (confirmResult) {
										if(collabTaskAdd.callbackFunc != undefined && collabTaskAdd.callbackFunc  != ''){
											var retData = data.taskData;
											window.parent.postMessage(
												    { functionName : collabTaskAdd.callbackFunc
												    		,params :data.taskData
												    		,reqParams:{"prjType":"${prjType}","prjSeq":"${prjSeq}"}
												    }
												    , '*' 
												);
										}
										Common.Close();
									});
								}
								else{
									Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	ì¤ë¥ê° ë°ìíìµëë¤. ê´ë¦¬ììê² ë¬¸ìë°ëëë¤
								}
							},
							error:function (request,status,error){
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
				//	}
				//});	
			});	
			$("#btnAdd").on('click', function(){
				if(!collabTaskAdd.validationChk())     	return ;
				Common.Confirm("<spring:message code='Cache.msg_AreYouCreateQ' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						var taskData = collabTaskAdd.getTaskData();

						$.ajax({
							type:"POST",
							enctype: 'multipart/form-data',
							data: taskData,
							processData: false,
							contentType: false,
							url:"/groupware/collabTmpl/addTmplTask.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>");	//ë³µì¬ëììµëë¤.
									if(collabTaskAdd.callbackFunc != undefined && collabTaskAdd.callbackFunc  != ''){
										var retData = data.taskData;
										window.parent.postMessage(
											    { functionName : collabTaskAdd.callbackFunc
											    		,params :data.taskData
											    		,reqParams:{"prjType":"${prjType}","prjSeq":"${prjSeq}"}
											    }
											    , '*' 
											);
									}
									//parent.collabMenu.getUserMenu();
									Common.Close();
								}
								else{
									Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	ì¤ë¥ê° ë°ìíìµëë¤. ê´ë¦¬ììê² ë¬¸ìë°ëëë¤
								}
							},
							error:function (request,status,error){
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
					}
				});	
			});
			
			$("#btnClose").on('click', function(){
				Common.Close();
			});
		},
		getTaskData:function(){
			var formData = new FormData($('#form1')[0]);

			formData.append("label", $(".selectValue").val());
			formData.append("taskSeq", "${taskData.TaskSeq}");
			formData.append("sectionSeq", "${sectionSeq}");
            formData.set("taskName", $("#taskName").val().replace(/\'/gi, "′").replace(/\"/gi, "″"));
			return formData;
		},
		validationChk:function(){
			var returnVal= true;
			 	
			if ($('#taskName').val() == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterTheRequiredValue'/>".replace("{0}", "<spring:message code='Cache.lbl_workname' />"));
			    return false;
			}
			return returnVal;
	 }	
}

$(document).ready(function(){
	collabTaskAdd.objectInit();
});
</script>