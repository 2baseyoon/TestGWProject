<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop">
	<h2 class="title"><spring:message code='Cache.lbl_CommunityInfo'/></h2>						
</div>
<div class="commIndividualInfoAdmin">
	<div class="commInputBoxDefault">								
		<div class="inputBoxSytel01 type02 commName">
			<div><span><spring:message code='Cache.lbl_communityName'/></span></div>
			<div>
				<p class="textBox" id="cName"></p>
			</div>
			<div>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div><span><spring:message code='Cache.lbl_Category'/></span></div>
			<div>
				<p class="textBox" id="cCategoryNm"></p>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div><span><spring:message code='Cache.lbl_Establishment_Day'/></span></div>
			<div>
				<p class="textBox" id="crDate"></p>
			</div>
			<div class="inputBoxSytel01 subDepth type02">
				<div><span><spring:message code='Cache.lbl_Establishment_Man'/></span></div>
				<div>
					 <p class="textBox" id="ccrName"></p>
				</div>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div><span><spring:message code='Cache.lbl_type'/></span></div>
			<div>
				<p class="textBox" id="cType"></p>
			</div>
			<div class="inputBoxSytel01 subDepth type02">
				<div><span><spring:message code='Cache.lbl_Operator'/></span></div>
				<div>
					<p class="textBox" id="copName"></p>
				</div>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div><span><spring:message code='Cache.lbl_User_Count'/></span></div>
			<div>
				<p class="textBox"><span class="colorTheme" id="cMemberCnt"></span></p>
			</div>
			<div class="inputBoxSytel01 subDepth type02">
				<div><span><spring:message code='Cache.lbl_All_Count'/></span></div>
				<div>
					<p class="textBox"><span class="colorTheme" id="cMsgCnt"></span></p>
				</div>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div><span><spring:message code='Cache.lbl_AllocatedCapacity'/></span></div>
			<div>
				<p class="textBox" id="cfdSize"></p>
			</div>
			<div class="inputBoxSytel01 subDepth type02">
				<div><span><spring:message code='Cache.lbl_UseFileSize'/></span></div>
				<div>
					<p class="textBox" id="cfuSize"></p>
				</div>
			</div>
		</div>
		<div class="inputBoxSytel01 type02">
			<div><span><spring:message code='Cache.lbl_SingleLineIntroduction'/></span></div>
			<div><p class="textBox" id="cOneTitle"></p></div>
		</div>							
		<div class="inputBoxEdit">
			<div class="inputBoxSytel01 type02">
				<div><span><spring:message code='Cache.lbl_CommunityStipulation'/></span></div>
				<div class="txtEdit">
					<p class="textBox" id="cProvision"></p>
				</div>
			</div>
			<div class="inputBoxSytel01 type02">
				<div><span><spring:message code='Cache.lbl_Community_Guide'/></span></div>
				<div class="txtEdit">
					<p class="textBox" id="cDescription"></p>
				</div>
			</div>
		</div>
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
					        
					$("#cName").html(v.CommunityName);
					$("#crDate").html(CFN_TransLocalTime(v.RegProcessDate,_ServerDateSimpleFormat));
					$("#cType").html( v.CommunityType);
					$("#cMemberCnt").html( v.MemberCount);
					$("#cMsgCnt").html(v.MsgCount);
					$("#cfdSize").html( v.LimitFileSize);
					$("#cfuSize").html( v.FileSize);
					$("#cOneTitle").html( v.SearchTitle);
					
					if(v.opDeptName != "" && v.opDeptName != null && v.opJobPositionName != "" && v.opJobPositionName != null){
						var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
				        var sRepJobType = v.opJobPositionName;
				        if(sRepJobTypeConfig == "PN"){
				        	sRepJobType = v.opJobPositionName;
				        } else if(sRepJobTypeConfig == "TN"){
				        	sRepJobType = v.opJobTitleName;
				        } else if(sRepJobTypeConfig == "LN"){
				        	sRepJobType = v.opJobLevelName;
				        }
						$("#copName").html(v.opName+"("+v.opDeptName+"/"+sRepJobType+")");
					}else{
						$("#copName").html(v.opName);
					}
					
					if(v.crDeptName != "" && v.crDeptName != null && v.crJobPositionName != "" && v.crJobPositionName != null){
						var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
				        var sRepJobType = v.crJobLevelName;
				        if(sRepJobTypeConfig == "PN"){
				        	sRepJobType = v.crJobPositionName;
				        } else if(sRepJobTypeConfig == "TN"){
				        	sRepJobType = v.crJobTitleName;
				        } else if(sRepJobTypeConfig == "LN"){
				        	sRepJobType = v.crJobLevelName;
				        }
						$("#ccrName").html(v.crName+"("+v.crDeptName+"/"+sRepJobType+")");
					}else{
						$("#ccrName").html(v.crName);
					}
					
					$("#cProvision").html( v.ProvisionEditor.replace(/(\r\n|\n|\n\n)/gi, '<br />'));
					$("#cDescription").html( v.DescriptionEditor.replace(/(\r\n|\n|\n\n)/gi, '<br />'));
					
					var positionStr = '';
 					if(v.MemberLevel == '0'){
 						$("#CM1,#CM2,#CM3,#CM4,#CM5,#CM6,#CM7,#subInfoMenu,#memberList,#memberJoin").hide();
 						if (v.DetailStatus == 'RA') {
 							positionStr = "("+"<spring:message code='Cache.lbl_WaitingCommunity'/>"+")";
 						}
 					}
 					$("#CPosition").html(positionStr);
 					
					setCurrentLocation(v.CategoryID);
					
				});
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/selectCommunityInfo.do", response, status, error); 
		}
	}); 
}

function setCurrentLocation(categoryID){
	var locationText= "";
	$.ajax({
		type:"POST",
		data:{
			"CategoryID" : categoryID
		},
		async : false,
		url:"/groupware/layout/userCommunity/setCurrentLocation.do",
		success:function (data) {
			
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					
					if(v.num == '1'){
						locationText += v.DisplayName;
					}else{
						if(data.list.length == 1){
							locationText += v.DisplayName;
						}else{
							locationText += v.DisplayName+" > ";
						}
					}
    			});
			}
			$("#cCategoryNm").html(locationText);
			
		},
		error:function (error){
			  CFN_ErrorAjax("/groupware/layout/community/setCurrentLocation.do", response, status, error);
		}
	});
}

</script>