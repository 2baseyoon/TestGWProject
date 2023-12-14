<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop">
	<h2 class="title"><spring:message code='Cache.lbl_ClosureApplication'/></h2>						
</div>
<div class="commIndividualInfoAdmin">
	<div class="commInputBoxDefault">								
		<div class="inputBoxSytel01 type02 commName">
			<div>
				<span><spring:message code='Cache.lbl_communityName'/></span>
			</div>
			<div>
				<p class="textBox" id="communityName"></p>
			</div>
			<div>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div>
				<span><spring:message code='Cache.lbl_Operator'/></span>
			</div>
			<div>
				<p class="textBox" id="opName"></p>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div>
				<span><spring:message code='Cache.lbl_Close_Date2'/></span>
			</div>
			<div>
				<p class="textBox" id="closingApDate"></p>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div>
				<span><spring:message code='Cache.lbl_closeState'/></span>
			</div>
			<div>
				<p class="textBox" id="closingApType"></p>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div>
				<span><spring:message code='Cache.lbl_Close_Date1'/></span>
			</div>
			<div>
				<p class="textBox" id="closingReDate"></p>
			</div>
		</div>
		<div class="inputBoxEdit">
			<div class="inputBoxSytel01 type02">
				<div>
					<span><spring:message code='Cache.lbl_closeReasonsCafe'/></span>
				</div>
				<div class="txtEdit" >
					<textarea id="txtStipulation" class="HtmlCheckXSS ScriptCheckXSS" maxlength="300"></textarea>
				</div>
			</div>
			
		</div>
		
	</div>						
	<div class="btm">
		<a id="applyBtn" onclick="goApply();" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_register'/></a><!-- <a onclick="setCommunityInfo();" class="btnTypeDefault ml5">취소</a> -->
	</div>					
</div>	

<script type="text/javascript">
$(function(){					
	setCommunityInfo();
});

function setCommunityInfo(){
	
	var str = "";
	$.ajax({
		url:"/groupware/layout/userCommunity/selectCommunityInfo.do",
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
			        
					$("#communityName").html(v.CommunityName);
					
					if(v.opJobPositionName != null && v.opJobPositionName != ""){
						$("#opName").html(v.opName+"("+v.opDeptName+"/"+v.opJobPositionName+")");
					}else{
						$("#opName").html(v.opName+"("+v.opDeptName+")");
					}
					
					$("#closingApDate").html(CFN_TransLocalTime(v.UnRegRequestDate,_ServerDateSimpleFormat));
					$("#closingApType").html(v.AppStatus);
					$("#closingReDate").html(CFN_TransLocalTime(v.UnRegProcessDate,_ServerDateSimpleFormat));
					$("#txtStipulation").val(v.ClosingMsg);
					
					if(v.AppStatusCode == "UA"){
						$("#applyBtn").hide();
						$("#closingApType").html("<spring:message code='Cache.lbl_ClosureApplication'/>");  // 폐쇄 신청
					}
				});
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/selectCommunityInfo.do", response, status, error); 
		}
	}); 
}

function goApply(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	Common.Confirm("<spring:message code='Cache.msg_closeReasonsConfirm'/>", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/CommunityClosingUpdate.do",
				type:"post",
				data:{
					CU_ID : cID,
					ClosingMsg : $("#txtStipulation").val()
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_closeReasonsCompleted'/>"); //폐쇄신청이 완료되었습니다.
						goCommunityMain();
					}else{ 
						Common.Error("<spring:message code='Cache.msg_closeReasonsFail'/>"); //폐쇄신청을 실패하였습니다.
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/CommunityClosingUpdate.do", response, status, error); 
				}
			}); 
		}
	});
}

</script>