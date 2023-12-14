<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.taskFolderAdmin .autoCompleteCustom .ui-autocomplete-multiselect.ui-state-default {width: calc(100% - 89px)!important;}
#inviteTitle {width: 317px;}
</style>
<input type="hidden" id="inviteCode" value=''/>
<div class="divpop_contents">
	<div class="popContent">
		<!-- 팝업 내부 시작 -->
		<input type="hidden" value="${cId}" name="cId" id="cId">
		<input type="hidden" value="${URcode}" name="URcode" id="URcode">
				
		<div class="taskPopContent  taskFolderAdmin" style="height: 100%">
			<div class="middle">				
				<div class="inputBoxSytel01 type03">
					<div><span><spring:message code='Cache.lbl_username'/></span></div> <!-- 이름  -->
					<div>
						<p class="textBox" id="cMName">${UName}</p>
					</div>
				</div>
				<div class="inputBoxSytel01 type03">
					<div><span><spring:message code='Cache.lbl_Withdrawal_Reason'/></span></div><%-- 탈퇴사유 --%>
					<div>
						<textarea id="leaveText" class="HtmlCheckXSS ScriptCheckXSS" kind="write" ></textarea>
					</div>
				</div>
			</div>
			<div class="bottom mt20" style="text-align: center;">
				<a name="registBtn" onclick="goLeave()" class="btnTypeDefault btnTypeBg" style=""><spring:message code='Cache.CuMemberStatus_U'/></a>  <!-- 탈퇴 -->
				<a name="cancelBtn" onclick="Common.Close(); return false; " class="btnTypeDefault " style=""><spring:message code='Cache.btn_Cancel'/></a> <!-- 취소 -->
			</div>
		</div>
		<!-- 팝업 내부 끝 -->
	</div>
</div>

<input type="hidden" id="hidType" value="${Type}" />
<script type="text/javascript">


function goLeave(){	
	var cID =$("#cId").val();
	var URcode = $("#URcode").val();
	var hidType = $("#hidType").val();
	var isForce = false;

	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	if (hidType == "force") {
		isForce = true;
	}
	
	Common.Confirm("커뮤니티를 탈퇴 하시겠습니까?", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/CommunityMemberLeavePopup.do",
				type:"post",
				data:{
					CU_ID : cID,
					UR_Code : URcode,
					LeaveMessage : $("#leaveText").val(),
					isForce: isForce
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_MemberWithdraw'/>", "Information", function(){  //커뮤니티 회원에서 탈퇴되었습니다.
							Common.Close();
							parent.selectCallList();
						});
					}else{ 
						Common.Error("<spring:message code='Cache.msg_ErrorWithdrawalRequest'/>"); //탈퇴신청 중 오류가 발생했습니다.
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/CommunityMemberLeave.do", response, status, error); 
				}
			}); 
		}
	}); 
}



</script>