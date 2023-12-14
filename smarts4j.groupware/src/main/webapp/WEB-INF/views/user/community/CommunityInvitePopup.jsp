<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<link rel="stylesheet" id="cCss" type="text/css" /> 
<link rel="stylesheet" id="cthemeCss" type="text/css" /> 

<style>
	.taskFolderAdmin .autoCompleteCustom .ui-autocomplete-multiselect.ui-state-default { width: calc(100% - 77px)!important; }
</style>

<input type="hidden" id="inviteCode" value=''/>
<div class="divpop_contents">
	<div class="popContent">
		<!-- 팝업 내부 시작 -->
		<div class="taskPopContent taskFolderAdmin" style="padding: 0;">
			<div class="middle">
				<div class="inputBoxSytel01 type03">
					<div><span><spring:message code='Cache.lbl_To'/></span></div>
					<div>
						<div class="autoCompleteCustom">
							<input id="myAutocompleteMultiple" type="text" class="ui-autocomplete-input" style="width: calc(100% - 82px) !important;" autocomplete="off">
							<a class="btnTypeDefault" onclick="inviteMember();return false;" style="height: 31px; line-height: 30px;"><spring:message code='Cache.lbl_To'/></a>
						</div>
					</div>
				</div>
				<div class="inputBoxSytel01 type03">
					<div><span><spring:message code='Cache.lbl_InvitationMessage'/></span></div>
					<div>
						<textarea id="inviteMsg" kind="write" style=""></textarea>
					</div>
				</div>
			</div>
			<div class="bottom mt20" style="text-align: center;">
				<a onclick="goSendInviteMsg()" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_Mail_Send'/></a> 
				<a onclick="Common.Close(); return false;" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>
			</div>
		</div>
		<!-- 팝업 내부 끝 -->
	</div>
</div>

<script type="text/javascript">
var dnID = parent.dnID;

$(function(){
	if(dnID == "0"){
		// 자동완성 옵션
		var autoInfos = {
			labelKey : 'UserName',
			addInfoKey : 'DeptName',
			valueKey : 'UserCode',
			minLength : 1,
			useEnter : false,
			multiselect : true,
		};
		coviCtrl.setUserWithDeptAutoTags('myAutocompleteMultiple', '/covicore/control/getAllUserAutoTagList.do?onlyUser=Y', autoInfos);
	}else{
		var autoInfos = {
			labelKey : 'Name',
			addInfoKey : 'DeptName',
			valueKey : 'Code',
			minLength : 1,
			useEnter : false,
			multiselect : true,
		};
		coviCtrl.setUserWithDeptAutoTags('myAutocompleteMultiple', '/covicore/control/getAllUserGroupAutoTagList.do?onlyUser=Y', autoInfos);
	}
	
	if (parent && parent.communityID != '' && parent.communityCssPath != '' && parent.communityTheme != ''){
		$("#cCss").attr("href",parent.communityCssPath + "/community/resources/css/community.css");
		$("#cthemeCss").attr("href",parent.communityCssPath + "/covicore/resources/css/theme/community/"+parent.communityTheme+".css");
	}
	else {
		$("#cCss, #cthemeCss").remove();
	}
})

function goSendInviteMsg(){
	if(!$('.ui-autocomplete-multiselect-item').length > 1){
		Common.Warning("<spring:message code='Cache.msg_recipients'/>");
		return;
	}
	
	if($("#inviteMsg").val() == '' || $("#inviteMsg").val() == null){
		Common.Warning("<spring:message code='Cache.msg_InviteMessage'/>");
		return;
	} 
	
	var text = $("#inviteMsg").val().replace(/(\r\n|\n|\n\n)/gi, '<br />');
	Common.Confirm(Common.getDic("msg_CommunityInvitation") , "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			$.ajax({
				url: "/groupware/layout/communitySendSimpleMail.do",
				type: "POST",
				data: {
					userCode: getReceiverData()
					,bodyText: text
					,cid : parent.cID
				},
				async: false,
				success: function (res) {
					if(res.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_SentMDM'/>", "Information Dialog", function(result){ //정상적으로 발송되었습니다.
							Common.Close();
							return false;
						});
					}else{
						Common.Error("<spring:message code='Cache.msg_FailedToSend'/>"); //발송에 실패하였습니다.
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/control/sendSimpleMail.do", response, status, error);
				}
			});
		}
	});
}

function inviteMember(){
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=depUserManage_CallBack&type=B9","<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
	//parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=depUserManage_CallBack&type=B9&treeKind=Group&groupDivision=Basic","1000px","580px","iframe",true,null,null,true);
}



function depUserManage_CallBack(orgData){
	var userJSON =  $.parseJSON(orgData);
	var sCode, sDisplayName, sDNCode, sMail;
	var bCheck;
	
	$(userJSON.item).each(function (i, item) {
  		var sObjectType = item.itemType;
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			sCode = item.AN;			//UR_Code
  			sDisplayName = CFN_GetDicInfo(item.DN) + ' [' + CFN_GetDicInfo(item.RGNM) + ']';
  			sDNCode = item.ETID; //DN_Code
  			sMail = item.EM; // E-mail
  		}

		bCheck = false;	
		$('.ui-autocomplete-multiselect-item').each( function(i, item){
			 if ($(this).attr("data-value") == sCode) {
                 bCheck = true;
             }
		});

		if (!bCheck) {
			var orgMapItem = $('<div class="ui-autocomplete-multiselect-item" />')
			.attr({'data-value': sCode, 'data-json': JSON.stringify({ 'MailAddress' : sMail}) } )
			.text(sDisplayName)
			.append($("<span></span>")
            .addClass("ui-icon ui-icon-close")
            .click(function(){
                var item = $(this).parent();
            	item.remove();
            }));
			$("#myAutocompleteMultiple").before(orgMapItem);
		}
 	});
}

//수신자 목록 jsonstring으로 변경
function getReceiverData(){
	var userIDs = '';
	$('.ui-autocomplete-multiselect-item').each(function () {
		userIDs += $(this).attr("data-value") + ';'
	});
	
	return userIDs;
}

</script>