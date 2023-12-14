<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<link rel="stylesheet" id="cCss" type="text/css" /> 
<link rel="stylesheet" id="cthemeCss" type="text/css" /> 

<input type="hidden" id ="CommunityID" value = "${CommunityID}"/>
<input type="hidden" id ="RecipientID" value = "${RecipientID}"/>
<input type="hidden" id ="status" value =  "${status}"/>
<input type="hidden" id ="PartiID" value = "${PartiID}"/>

<div class="layer_divpop surveryAllPop">
	<div class="popContent">
		<div class="popTop">
			<p id="alianceMsg"></p>
		</div>
		<div class="popMiddle" style="height:97px;">
			<textarea id="alianceText" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
		</div>
		<div class="popBottom">
			<a onclick="goAllianceApprove();" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.lbl_SmartConfirm'/></a>
			<a onclick="Common.Close();" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>
		</div>
	</div>
</div>

<script type="text/javascript">
var status = "${status}";
var msg = "";

$(function(){					
	setEventMsg();
	
	if (parent && parent.communityID != '' && parent.communityCssPath != '' && parent.communityTheme != ''){
		$("#cCss").attr("href",parent.communityCssPath + "/community/resources/css/community.css");
		$("#cthemeCss").attr("href",parent.communityCssPath + "/covicore/resources/css/theme/community/"+parent.communityTheme+".css");
	}
	else {
		$("#cCss, #cthemeCss").remove();
	}
});


function setEventMsg(){
	
	if(status == "P"){
		msg = "<spring:message code='Cache.msg_AffiliateRequest'/>";
		$("#alianceMsg").html(msg)
	}else if(status == "E"){
		msg = "<spring:message code='Cache.msg_RUPartiEnd'/>";
		$("#alianceMsg").html(msg);
	}else if(status == "R"){
		msg = "<spring:message code='Cache.msg_RUDenyPartiRequest'/>";
		$("#alianceMsg").html(msg);
	}else if(status == "C"){
		msg =  "<spring:message code='Cache.msg_RUCancelPartiRequest'/>";
		$("#alianceMsg").html(msg);
	}else if(status == "A"){
		msg = "<spring:message code='Cache.msg_RUPartiRequests'/>";
		$("#alianceMsg").html(msg);
	}else{
		Common.Close();
	}
}

function goAllianceApprove(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	Common.Confirm(msg, "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/communityAllianceApprove.do",
				type:"post",
				data:{
					communityID : $("#CommunityID").val(),
					RecipientID : $("#RecipientID").val(),
					Status : $("#status").val(),
					PartiID : $("#PartiID").val(),
					RequestMessage : $("#alianceText").val()
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_170'/>", "Information", function(){	 //완료되었습니다.
							if(opener){
								opener.selectCommunityList();
							}else{
								parent.selectCommunityList();				
							}
							
							Common.Close();
						});
						
					}else{ 
						Common.Warning("<spring:message code='Cache.msg_ComFailed'/>"); //실패하였습니다.
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/communityAllianceApprove.do", response, status, error); 
				}
			}); 
		}
	});	
	
}
</script>