<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
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
					<col width="110">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<th>
							<spring:message code='Cache.lbl_ProjectName'/>
						</th>
						<td>${prjName}</td>
					</tr>	
					<tr>
						<th>
							<spring:message code='Cache.lbl_PersonalName'/>
						</th>
						<td><input type="text" class="w100 HtmlCheckXSS ScriptCheckXSS Required SpecialCheck MaxSizeCheck" max="50" title="<spring:message code='Cache.lbl_sectionName'/>" id=PrjPersonalName value="${prjPersonalName}"/></td>
					</tr>	
				</tbody>	
			</table>
		</div>				
		<div class="popBtnWrap">
				<a href="#" class="btnTypeDefault btnTypeBg" id="btnAdd"><spring:message code='Cache.lbl_Save'/></a> 
			<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.lbl_Cancel'/></a>
		</div>
	</div>
</body>
<script type="text/javascript">
var collabPrjPersonalName = {
		objectInit : function(){			
			this.addEvent();
		},
		addEvent : function(){
			$("#btnAdd").on('click', function(){
				$.ajax({
					type:"POST",
					data:{"prjSeq":'${prjSeq}',"prjType":'${prjType}', "prjName":'${prjName}', "PrjPersonalName":  $("#PrjPersonalName").val().replace(/\'/gi, "′").replace(/\"/gi, "″")},
					url:"/groupware/collabProject/addPrjPersonalName.do",
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_apv_136'/>");
							parent.collabMenu.getUserMenu();
							Common.Close();
						}
					},
					error:function (request,status,error){
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
					}
				});
			});
			
			$("#btnClose").on('click', function(){
				Common.Close();
			});
		},
}

$(document).ready(function(){
	collabPrjPersonalName.objectInit();
});

</script>