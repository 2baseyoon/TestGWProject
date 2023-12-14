<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body>	
	<div class="collabo_popup_wrap">
		<div class="collabo_table_wrap">
			<table class="collabo_table type02" cellpadding="0" cellspacing="0">
				<colgroup>
					<col width="90">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<th>
							<spring:message code='Cache.ACC_lbl_projectName'/>
						</th>
						<td>
							<div class="ATMgt_T"><div class="ATMgt_T_l">
								<input type="text" class="w100 HtmlCheckXSS ScriptCheckXSS Required SpecialCheck MaxSizeCheck" max="50" id="prjName" value="${prjData.PrjName }" title="<spring:message code='Cache.ACC_lbl_projectName'/>"/>
							</div></div>
						</td>
					</tr>	
				</tbody>	
			</table>
		</div>
		<div class="popBtnWrap">
			<a href="#" class="btnTypeDefault btnTypeBg" id="btnAdd"><spring:message code='Cache.lbl_Copy'/></a>
			<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.lbl_Cancel'/></a>
		</div>
	</div>
</body>
<script type="text/javascript">
var collabSectionAdd = {
		objectInit : function(){			
			this.addEvent();
		}	,
		addEvent : function(){
			$("#btnAdd").on('click', function(){
				if (!coviUtil.checkValidation("", true, true)) { return false; }			

				Common.Confirm("<spring:message code='Cache.msg_RUCopy' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						$.ajax({
							type:"POST",
							data:{"orgPrjSeq":'${prjSeq}', "prjName":  $("#prjName").val(), "prjType": '${prjType}'},
							url:"/groupware/collabProject/copyProject.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									Common.Inform("<spring:message code='Cache.msg_apv_510'/>");	//복사되었습니다.
									parent.collabMenu.getUserMenu();
									Common.Close();
								}
								else{
									Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
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
		}	
}

$(document).ready(function(){
	collabSectionAdd.objectInit();
});

</script>