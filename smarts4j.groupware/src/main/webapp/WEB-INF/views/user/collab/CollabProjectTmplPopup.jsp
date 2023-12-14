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
						<th><spring:message code='Cache.lbl_JvCate'/></th>
						<td><select id="tmplKind" class="AXSelect W80"></select></td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_templateName'/></th>
						<td>
							<input type="text" class="w100 Required MaxSizeCheck" max="50" id="requestTitle" value="${prjName}" title="<spring:message code='Cache.lbl_templateName'/>"/>
						</td>
					</tr>	
					<tr>
						<th><spring:message code='Cache.lbl_RequestContent'/></th>
						<td><textarea id="requestRemark" class ="MaxSizeCheck" max="400" title="<spring:message code='Cache.lbl_RequestContent'/>"></textarea></td>
					</tr>	
				</tbody>	
			</table>
		</div>				
		<div class="popBtnWrap">
			<a href="#" class="btnTypeDefault btnTypeBg" id="btnAdd"><spring:message code='Cache.CPMail_mail_approvalReq'/></a>
			<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.lbl_Cancel'/></a>
		</div>
	</div>
</body>
<script type="text/javascript">
var collabTmpl = {
		objectInit : function(){		
			this.addEvent();
		}	,
		addEvent : function(){
			coviCtrl.renderAXSelect("COLLAB_KIND","tmplKind",lang,"", 	"", "");
			
			$("#btnAdd").on('click', function(){
				if (!coviUtil.checkValidation("", true, true)) { return false; }
				//Common.Confirm("<spring:message code='Cache.msg_AreYouCreateQ' />", "Confirmation Dialog", function (confirmResult) {
				//	if (confirmResult) {
						$.ajax({
							type:"POST",
							data:{"prjSeq":'${prjSeq}',"requestTitle":$("#requestTitle").val(),"tmplKind":$("#tmplKind").val(), "requestRemark":  $("#requestRemark").val()},
							url:"/groupware/collabProject/addProjectTmpl.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									Common.Inform("<spring:message code='Cache.msg_apv_136'/>");	//복사되었습니다.
									Common.Close();
								}

							},
							error:function (request,status,error){
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
				//}	
				//});	
			});
			
			$("#btnClose").on('click', function(){
				Common.Close();
			});
		}	
}

$(document).ready(function(){
	collabTmpl.objectInit();
});

</script>