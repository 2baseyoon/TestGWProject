<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop">
	<h2 class="title"><spring:message code='Cache.lbl_WithdrawalOfApp'/></h2>	<!--탈퇴신청-->		 			
</div>
<div class="commIndividualInfoAdmin">
	<div class="commInputBoxDefault">								
		<div class="inputBoxSytel01 type02 commName">
			<div><span><spring:message code='Cache.lbl_communityName'/></span></div> <!--커뮤니티 명-->	
			<div>
				<p class="textBox" id="cName"></p>
			</div>
			<div>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div><span><spring:message code='Cache.lbl_User_Info'/></span></div> <!--회원정보-->	
			<div>
				<p class="textBox" id="cMName"></p>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div><span><spring:message code='Cache.lbl_User_Grade'/></span></div> <!--회원등급-->	
			<div>
				<p class="textBox" id="cMLevel"></p>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div><span><spring:message code='Cache.lbl_Join_Day'/></span></div> <!--가입일-->	
			<div>
				<p class="textBox" id="cMJoinDate"></p>
			</div>
		</div>
		<div class="inputBoxEdit">
			<div class="inputBoxSytel01 type02">
				<div><span><spring:message code='Cache.lbl_Withdrawal_Date'/></span></div> <!--탈퇴일-->	
				<div>
					<p class="textBox" id="cMLeaveDate"></p>
				</div>
				
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div><span><spring:message code='Cache.lbl_Withdrawal_Reason'/></span></div> <!--탈퇴사유-->	
			<div class="txtEdit">
				<textarea id="leaveText" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
			</div>
		</div>
		<div class="cRContEnd">
			<div class="cRTopButtons">
				<a href="#" class="btnTypeDefault btnTypeChk" onclick="goLeave();"><spring:message code='Cache.CuMemberStatus_U'/></a><a href="#" class="btnTypeDefault" onclick="goCommunityMain();"><spring:message code='Cache.lbl_Cancel'/></a> <!--탈퇴-->	 <!--취소-->	
			</div>
		</div>					
	</div>	
</div>
<script type="text/javascript">
$(function(){					
	setLeaveInfo();
});

function setLeaveInfo(){
	var str = "";
	$.ajax({
		url:"/groupware/layout/userCommunity/selectCommunityLeaveInfo.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID
		},
		success:function (e) {
			if(e.list.length > 0){
				$(e.list).each(function(i,v){
					
					var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
			        var sRepJobType = v.MultiJobLevelName;
			        if(sRepJobTypeConfig == "PN"){
			        	sRepJobType = v.MultiJobPositionName;
			        } else if(sRepJobTypeConfig == "TN"){
			        	sRepJobType = v.MultiJobTitleName;
			        } else if(sRepJobTypeConfig == "LN"){
			        	sRepJobType = v.MultiJobLevelName;
			        }
			        
					$("#cName").html(v.CommunityName);
					$("#cMName").html(v.DisplayName+" ("+v.DeptName+" / "+ sRepJobType +")");
					$("#cMJoinDate").html(CFN_TransLocalTime(v.RegProcessDate,_ServerDateSimpleFormat));
					$("#cMLevel").html(v.CuMemberLevel);
					$("#cMLeaveDate").html(CFN_TransLocalTime(v.now_date,_ServerDateSimpleFormat));
				});
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/selectCommunityLeaveInfo.do", response, status, error); 
		}
	}); 
}

function goLeave(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	Common.Confirm("<spring:message code='Cache.msg_withdrewCommunity'/>", "Confirmation Dialog", function (confirmResult) { //커뮤니티를 탈퇴 하시겠습니까?
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/CommunityMemberLeave.do",
				type:"post",
				data:{
					CU_ID : cID,
					LeaveMessage : $("#leaveText").val()
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_MemberWithdraw'/>"); //커뮤니티 회원에서 탈퇴되었습니다.
						goCommunityMain();
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