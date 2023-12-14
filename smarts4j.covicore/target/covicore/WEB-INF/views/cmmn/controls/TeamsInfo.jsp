<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<link rel="stylesheet" id="cCss" type="text/css" /> 
<link rel="stylesheet" id="cthemeCss" type="text/css" /> 

<div class="layer_divpop ui-draggable  commonLayerPop popBizCardView " id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent ProfilePopContainer">
			<div class="ProfilePopContent">
				<div class="top">
					<div>
						<div class="popContTop nameCard">
							<div class="photoArea">
								<img id="PhotoPath" src="">
							</div>
							<dl class="infoArea">
								<dt id="UserName"></dt>
								<dd id="DeptName" class="division"></dd>
							</dl>
						</div>
					</div>
					<div>
						<div class="rowTypeWrap contDetail">
							<dl>
								<dt><spring:message code='Cache.lbl_JobTitle' /></dt>
								<dd id="JobTitleName"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lbl_Role' /></dt>
								<dd id="ChargeBusiness"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lbl_SmartDateofBirth' /></dt>
								<dd id="Birthdate"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lbl_Mail' /></dt>
								<dd id="MailAddress"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lbl_PhoneNum' /></dt>
								<dd id="PhoneNumber"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lbl_MobilePhone' /></dt>
								<dd id="Mobile"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lbl_Office_Fax' /></dt>
								<dd id="Fax"></dd>
							</dl>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<input type="hidden" id="userCode">

<script>

var boardGrid = new coviGrid();
var approvalGrid = new coviGrid();
var userId = isEmptyDefault(CFN_GetQueryString("userID"), Common.getSession("USERID") );
var profileImagePath = Common.getBaseConfig("ProfileImagePath").replace("{0}", Common.getSession("DN_Code"));
var userName = "";

initContent();

function initContent(){
	//개별 호출 일괄처리
	Common.getDicList(["lbl_schedule_repeatSch","msg_thereNoShareEvent", "lbl_WPSun","lbl_WPMon","lbl_WPTue","lbl_WPWed","lbl_WPThu","lbl_WPFri","lbl_WPSat"]);
	
	$("#addNumber").attr("onclick", 'coviCtrl.addFavoriteContact(\''+userId+'\');');
	
	$('.tabMenu>li').off('click').on('click', function(){
		$('.tabMenu>li').removeClass('active');
		$('.tabContent').removeClass('active');
		$(this).addClass('active');
		$('.tabContent').eq($(this).index()).addClass('active');
		setGrid($("#bottomTab li.active").attr("value"));
	});
	
	$.ajax({
		type:"POST",
		data:{
			"userId" : userId
		},
		url:"/covicore/control/getMyInfo.do",
		success:function (res) {
			if(res.data){
				
				$("#userCode").val(userId);
				
				profileImagePath = Common.getBaseConfig("ProfileImagePath").replace("{0}", res.data.CompanyCode);
				
				$("#PhotoPath").attr("src", coviCmn.loadImage(profileImagePath+userId+"_org.jpg"));
				$("#PhotoPath").attr("onerror", "coviCmn.imgError(this, true);");
				
				$("#UserName").html("<strong id=userNm>"+res.data.DisplayName+"</strong>"+res.data.JobLevelName);
				userName=res.data.DisplayName;
				
				$("#DeptName").html(res.data.DeptName);
				
				$("#JobTitleName").html(res.data.JobTitleName);
				
				$("#ChargeBusiness").html(res.data.ChargeBusiness);
				
				$("#Birthdate").html(res.data.Birthdate.substr(5, 5));
				
				$("#MailAddress").html(res.data.MailAddress);
				
				if(Common.getGlobalProperties("lync.chat.used") == "Y"){	//lync, skype 채팅 사용시 sip메일 연동
					$("#sendTalk").attr("href", "sip:"+res.data.MailAddress);
					$("#sendTalk").show();
				} else {
					$("#sendTalk").hide();
				}
				
				$("#PhoneNumber").html(res.data.PhoneNumber);
				
				$("#Mobile").html(res.data.Mobile);
				
				$("#Fax").html(res.data.Fax);
			}
			
			// 타임존 표시
			$("#txtTimeZone").html(Common.getSession("UR_TimeZoneDisplay"));
			
		},
		error:function (response, status, error){
			CFN_ErrorAjax("/covicore/control/getMyInfo.do", response, status, error);
		}
	});
	
	if (parent && parent.communityID != '' && parent.communityCssPath != '' && parent.communityTheme != ''){
		$("#cCss").attr("href",parent.communityCssPath + "/community/resources/css/community.css");
		$("#cthemeCss").attr("href",parent.communityCssPath + "/covicore/resources/css/theme/community/"+parent.communityTheme+".css");
	}
	else {
		$("#cCss, #cthemeCss").remove();
	}
}


//초기 설정 값 셋팅 시 빈값 확인
function isEmptyDefault(value, defaultVal){
	  if(value == null || value == 'undefined' || typeof(value) == 'undefined'){
		  return defaultVal;
	  }
	  return value;
}

</script>