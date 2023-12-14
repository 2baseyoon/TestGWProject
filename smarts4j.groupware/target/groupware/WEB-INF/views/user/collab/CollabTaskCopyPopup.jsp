<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body>	
	<div class="layer_divpop" style="width:100%; left:0; top:0; z-index:104;">
		<div class="" style="overflow:hidden; padding:0;">
			<div class="ATMgt_popup_wrap">
				<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
					<tbody>
						<tr>
							<td class="ATMgt_T_th" >
								<spring:message code='Cache.lbl_workname'/>
							</td>
							<td>
								<div class="ATMgt_T"><div class="ATMgt_T_l">
									<input type="text" class="tx_status w100 HtmlCheckXSS ScriptCheckXSS Required SpecialCheck MaxSizeCheck" max="50" id="taskName" value="" title="<spring:message code='Cache.lbl_workname'/>"/>
								</div></div>
							</td>
						</tr>	
					</tbody>	
				</table>
			</div>
			<div class="bottom">
					<a href="#" class="btnTypeDefault btnTypeBg" id="btnAdd"><spring:message code='Cache.lbl_Copy'/></a>
					<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.lbl_Cancel'/></a>
			</div>
		</div>				
	</div>
</body>
<script type="text/javascript">
var collabTaskCopy = {
		callbackFunc:CFN_GetQueryString("callBackFunc"),
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
							data:{"orgTaskSeq":'${taskSeq}', "taskName":  $("#taskName").val()},
							url:"/groupware/collabTask/copyTask.do",
							success:function (data) {
								if(data.status == "SUCCESS"){
									Common.Inform("<spring:message code='Cache.msg_apv_510'/>","", function (confirmResult) {
										if(collabTaskCopy.callbackFunc != undefined && collabTaskCopy.callbackFunc  != ''){
											window.parent.postMessage(
												    { functionName : collabTaskCopy.callbackFunc
												    		,reqParams:{"objId":CFN_GetQueryString("objId")}
												    }
												    , '*' 
												);
										}
										Common.Close();
									});	//복사되었습니다.
								}	
								else{
									Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
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
	collabTaskCopy.objectInit();
});

</script>