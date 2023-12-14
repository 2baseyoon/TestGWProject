<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop">
	<h2 class="title"><spring:message code='Cache.lbl_User_Join'/></h2>	 <!-- 회원가입  -->					
</div>
<div class="commIndividualInfoAdmin">
	<div class="commInputBoxDefault">
			<div class="inputBoxSytel01 type02 commName">
				<div><span><spring:message code='Cache.lbl_name'/></span></div> <!-- 이름  -->
				<div>
					<p class="textBox" id="uName"></p>
				</div>
				<div>
				</div>
			</div>
		<div class="inputBoxEdit">
			<%if (RedisDataUtil.getBaseConfig("isUseMail").equals("Y")){ %>
			<div class="inputBoxSytel01 type02">
				<div><span><spring:message code='Cache.lbl_Mail_Address'/></span></div> <!-- 메일주소  -->
				<div>
					<p class="textBox" id="uEmail"></p>
				</div>
			</div>
			<%} %>
			<div class="inputBoxSytel01 type02">
				<div><span><spring:message code='Cache.lbl_Self_Intro'/></span></div> <!-- 자기소개  -->
				<div><textarea style="margin: 0px; width: 100%; height: 65px;" id="uRegMessage" class="HtmlCheckXSS ScriptCheckXSS"></textarea></div>
			</div>
			<div class="inputBoxSytel01 type02 communityTerms" style="display:none;">
				<div><span><spring:message code='Cache.lbl_community_SubsTerm' /></span></div> <!-- 가입약관 -->
				<div class="txtEdit">
					<p class="textBox" id="cProvision">
				</div>
			</div>
			<div class="inputBoxSytel01 type02 communityTerms" style="border-top: 0; display:none;">
				<div style="text-align: right;">
				<input type="checkbox" id="applyUserAgree">
				<label for="community_apply_userAgree"><spring:message code='Cache.lbl_CommunityAgreementJoinCheck' /></label> <!-- 위 약관에 동의하며 회원가입을 신청합니다. -->
				</div>
			</div>
		</div>
	</div>		
	<div class="btm">
		<a href="#" class="btnTypeDefault btnTypeBg " onclick="joinCommunity();">가입</a><a href="#" class="btnTypeDefault ml5" onclick="joinCancel()">취소</a>
	</div>					
</div>
<input type="hidden" id="hiddenUName"/>
<input type="hidden" id="hiddenUEmail"/>
<input type="hidden" id="hiddenCType"/>

<script type="text/javascript">
$(function(){					
	setJoinInfo();
});

function setJoinInfo(){
	var url = "/groupware/community/communityJoinInfo.do";
	
	$.ajax({
		url: url,
		data: {
			CU_ID: cID
		},
		type: "POST",
		async: false,
		success: function(result){
			if(result.userInfo.length > 0){
				var userObj = result.userInfo[0];
				$("#uName").html(userObj.DisplayName);
				$("#hiddenUName").val(userObj.DisplayName);
				
				$("#uEmail").html(userObj.MailAddress);
				$("#hiddenUEmail").html(userObj.MailAddress);
				
				$("#hiddenCType").val(userObj.JoinOption);
			}else{
				location.href = "/groupware/layout/userCommunity/communityMain.do?C="+cID;
			}
			
			if(result.communityInfo.length > 0){
				var communityObj = result.communityInfo[0];

				if (typeof communityObj.Provision == 'string' && communityObj.Provision != ''){
					$("#cProvision").html( communityObj.ProvisionEditor.replace(/(\r\n|\n|\n\n)/gi, '<br />'));
					$(".communityTerms").show();
				} else {
					$(".communityTerms").hide();
				}
			}else{
				location.href = "/groupware/layout/userCommunity/communityMain.do?C="+cID;
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax(url, response, status, error); 
		}
	});
}

function joinCancel(){
	location.href = "/groupware/layout/userCommunity/communityMain.do?C="+cID;
}

function joinCommunity(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	//약관 동의에 체크하지 않았을 경우
	if($($(".communityTerms")[0]).css("display") != 'none' && !$("#applyUserAgree").prop("checked")){
		Common.Warning(Common.getDic('msg_community_userAgree')); 		//약관에 동의하셔야 회원가입 신청이 완료됩니다.'
		return false;
	}

	Common.Confirm(Common.getDic('msg_applicationCommunity'), "Confirmation Dialog", function (confirmResult) { //커뮤니티 가입신청을 하시겠습니까?
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/communityUserJoin.do",
				type:"post",
				data:{
					CU_ID : cID,
					RegMessage : $("#uRegMessage").val(),
					MailAddress : $("#hiddenUEmail").val(),
					NickName : $("#hiddenUName").val(),
					JoinOption : $("#hiddenCType").val()
					
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform(Common.getDic('msg_CommunityJoinMsg_05'), "", function(){		//회원가입 신청이 완료되었습니다.
							goCommunityMain();	
						}); 
					}else{ 
						Common.Error(Common.getDic('msg_CommunityJoinMsg_07')); //회원가입 신청에 실패하였습니다.
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/communityUserJoin.do", response, status, error); 
				}
			}); 
		}
	});
}

</script>