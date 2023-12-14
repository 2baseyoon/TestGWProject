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
						<c:if test="${sectionSeq =='' || sectionSeq eq null  }">
							<spring:message code='Cache.btn_AddSection'/>
						</c:if>
						<c:if test="${sectionSeq !='' && sectionSeq ne null  }">
							<spring:message code='Cache.btn_ModiSection'/>
						</c:if>
						</th>
						<td><input type="text" class="w100 HtmlCheckXSS ScriptCheckXSS Required SpecialCheck MaxSizeCheck" max="50" title="<spring:message code='Cache.lbl_sectionName'/>" id="sectionName" value="${sectionName}"/></td>
					</tr>	
				</tbody>	
			</table>
		</div>				
		<div class="popBtnWrap">
			<c:if test="${sectionSeq =='' || sectionSeq eq null  }">
				<a href="#" class="btnTypeDefault btnTypeBg" id="btnAdd"><spring:message code='Cache.btn_AddSection'/></a>
			</c:if>
			<c:if test="${sectionSeq !='' && sectionSeq ne null  }">
				<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.lbl_Save'/></a>
			</c:if>
			<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.lbl_Cancel'/></a>
		</div>
	</div>
</body>
<script type="text/javascript">
var callbackParam =  {"prjSeq":'${prjSeq}',"prjType":'${prjType}', "taskSeq":'${taskSeq}'};
var collabSectionAdd = {
		objectInit : function(){			
			this.addEvent();
		}	,
		addEvent : function(){
			$("#btnAdd").on('click', function(){
				//Common.Confirm("<spring:message code='Cache.msg_AreYouCreateQ' />", "Confirmation Dialog", function (confirmResult) {
				//	if (confirmResult) {
						$.ajax({
							type:"POST",
							data:{"prjSeq":'${prjSeq}',"prjType":'${prjType}', "sectionName":  $("#sectionName").val().replace(/\'/gi, "′").replace(/\"/gi, "″")},
							url:"/groupware/collabProject/addProjectSection.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									Common.Inform("<spring:message code='Cache.msg_apv_136'/>");	//복사되었습니다.
									callbackParam["SectionSeq"]= data.SectionSeq;
									callbackParam["SectionName"]= data.SectionName;
									callbackParam["Count"]= "0";
									parent.collabMain.loadSection(callbackParam);
									Common.Close();
								}
								else{
									switch (data.code){
										case "DUP":
											Common.Error("<spring:message code='Cache.lbl_Mail_DuplicationWords' />"); //	중복
											break;
										default:
											Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
									}
									
								}
							},
							error:function (request,status,error){
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
				//}	
				//});	
			});
			
			$("#btnSave").on('click', function(){
				//Common.Confirm("<spring:message code='Cache.msg_RUSave' />", "Confirmation Dialog", function (confirmResult) {
				//	if (confirmResult) {
						$.ajax({
							type:"POST",
							data:{"sectionSeq":'${sectionSeq}', "sectionName":  $("#sectionName").val().replace(/\'/gi, "′").replace(/\"/gi, "″")},
							url:"/groupware/collabProject/saveProjectSection.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>");	//복사되었습니다.
									callbackParam["SectionSeq"]= '${sectionSeq}';
									callbackParam["SectionName"]= data.SectionName;
									
									if("${isMile}" == "Y")
										parent.collabProjectAdd.changeSection(callbackParam);
									else
										parent.collabMain.changeSection(callbackParam);
									
									Common.Close();
								}
								else{
									switch (data.code){
										case "DUP":
											Common.Error("<spring:message code='Cache.lbl_Mail_DuplicationWords' />"); //	중복
											break;
										default:
											Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
									}
									
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
		},
}

$(document).ready(function(){
	collabSectionAdd.objectInit();
});

</script>