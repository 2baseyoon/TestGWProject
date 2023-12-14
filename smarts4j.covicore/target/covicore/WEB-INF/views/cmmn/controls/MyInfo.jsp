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
								<dd id="CompanyName" class="division"></dd>
							</dl>
						</div>
						<div class="rowTypeWrap contDetail">
							<dl style="display:none">
								<dt><spring:message code='Cache.lbl_JobPosition' /></dt>
								<dd id="JobPositionName"></dd>
							</dl>
							<dl style="display:none">
								<dt><spring:message code='Cache.lbl_JobLevel' /></dt>
								<dd id="JobLevelName"></dd>
							</dl>
							<dl style="display:none">
								<dt><spring:message code='Cache.lbl_JobTitle' /></dt>
								<dd id="JobTitleName"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lbl_Role' /></dt>
								<dd id="ChargeBusiness"></dd>
							</dl>
						</div>
						<ul class="profileCommuList clearFloat">
							<!-- TODO 메일, 와이파이 항목 구현 (미구현 항목으로 숨김처리)  -->
							<li class="profileCommuList01"><a id="MailAddressBtn"><spring:message code='Cache.lbl_Mail' /></a></li>
							<li class="profileCommuList02" style="display:none"><a>와이파이</a></li>
							<li class="profileCommuList03" style="display:none"><a id="sendTalk">말풍선</a></li>
							<li class="profileCommuList04"><a id="addNumber"><spring:message code='Cache.lbl_Add' /></a></li>
						</ul>
					</div>
					<div>
						<div class="rowTypeWrap contDetail">
							<dl>
								<dt><spring:message code='Cache.lbl_Birth' /></dt>
								<dd id="Birthdate"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lbl_Mail' /></dt>
								<dd id="MailAddress"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lbl_MobilePhone' /></dt>
								<dd id="Mobile"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lbl_PhoneNum' /></dt>
								<dd id="PhoneNumber"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lblOfficeCall' /></dt>
								<dd id="PhoneNumberInter"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lbl_Office_Fax' /></dt>
								<dd id="Fax"></dd>
							</dl>
							<dl>
								<dt><spring:message code='Cache.lbl_AddJobDisJob' /></dt>
								<dd id="AddJob"></dd>
							</dl>
						</div>
					</div>
				</div>
				<div id="scheduleBox" class="middle mt45">
					<h3 class="cycleTitle"><spring:message code='Cache.lbl_Schedule' /></h3>
					<div class="layerPopupCtop mt10">
						<h2 id="dateTitle" class="title"></h2>
						<div class="pagingType02">
							<a class="pre"  onclick="movePeroid('PREV');"></a><a class="next" onclick="movePeroid('NEXT');"></a><a class="btnTypeDefault" onclick="goCurrent();"><spring:message code='Cache.lbl_Todays' /></a>
						</div>
					</div>
					<div class="layerPopupCmiddle">
						<div class="calMonHeader"></div>
						<div class="calMonBody">
							<div class="calMonWeekRow">
								<table class="calGrid"></table>
								<!-- 일정이 들어가는 곳 한줄당 한라인-->
								<table class="monShcList">
									<tbody></tbody>
								</table>
							</div>
						</div>
						<div class="bulDashedTitle"></div>
					</div>
					<article id="popup" style="position: absolute;"></article>
				</div>
				<div class="bottom mt85" style="display:none;" id="divTargetInfo">
					<div>
						<div class="layerPopupCbottom">
							<ul id="bottomTab" class="tabMenu clearFloat">
								<li class="active" value="board"><a><spring:message code='Cache.WPBoardTabListType_RECENT' /></a></li><!-- 최근게시 -->
								<li value="approval"><a><spring:message code='Cache.lbl_apv_approval' /></a></li><!-- 결재 -->
							</ul>
							<div class="searchBox02">
								<a class="btnTypeDefault" id="showMore" onclick="showMoreData();">More +</a>
							</div>
						</div>													
						<div>
							<div class="tabContent active">
								<div class="tblList tblCont type02" style="margin-top: 0px !important;">
									<div id="boardList"></div>
								</div>
							</div>
							<div class="tabContent">
								<div class="tblList tblCont type02" style="margin-top: 0px !important;">
									<div id="approvalList"></div>
								</div>
							</div>
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
		
		if($("#bottomTab").find("li.active").attr("value") == "board"){
			$("#showMore").hide();
		} else {
			$("#showMore").show();
		}
		
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
				
				$("#PhotoPath").attr("src", coviCmn.loadImage(res.data.PhotoPath.replace(".jpg", "_org.jpg")));
				$("#PhotoPath").attr("onerror", "coviCmn.imgError(this, true);");
				
				
		        var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
		        var sRepJobType = res.data.JobLevelName;
		        if(sRepJobTypeConfig == "PN"){
		        	sRepJobType = res.data.JobPositionName;
		        } else if(sRepJobTypeConfig == "TN"){
		        	sRepJobType = res.data.JobTitleName;
		        } else if(sRepJobTypeConfig == "LN"){
		        	sRepJobType = res.data.JobLevelName;
		        }
		        
				$("#UserName").html("<strong id=userNm>"+res.data.DisplayName+"</strong>"+sRepJobType);
				userName=res.data.DisplayName;
				
				$("#DeptName").html(res.data.DeptName);
				$("#CompanyName").html("("+res.data.MultiCompanyName+")");
				
		        var sJobTypeUses = Common.getBaseConfig("JobTypeUses");
		        if(sJobTypeUses != null && sJobTypeUses != ""){
			        if(sJobTypeUses.indexOf("PN") > -1){
						$("#JobPositionName").html(res.data.JobPositionName);
						$("#JobPositionName").parent().show();
			        } else {
			        	$("#JobPositionName").parent().hide();
			        }
			        if(sJobTypeUses.indexOf("LN") > -1){
						$("#JobLevelName").html(res.data.JobLevelName);
						$("#JobLevelName").parent().show();
			        } else {
			        	$("#JobLevelName").parent().hide();
			        }
			        if(sJobTypeUses.indexOf("TN") > -1){
						$("#JobTitleName").html(res.data.JobTitleName);
						$("#JobTitleName").parent().show();
			        } else {
			        	$("#JobTitleName").parent().hide();
			        }
		        } else {
					$("#JobTitleName").html(res.data.JobTitleName);
					$("#JobTitleName").parent().show();
		        }

				
				$("#ChargeBusiness").html(res.data.ChargeBusiness);
				
				var birthDate = res.data.Birthdate.substr(5, 5);
				if (res.data.BirthDiv == 'L') {
					if (res.data.IsBirthLeapMonth == 'Y') birthDate = Common.getDic('lbl_lunar_leap_month') + birthDate;
					birthDate = ' (' + Common.getDic('lbl_sch_lunar') + ') ' + birthDate;
				}
				
				$("#Birthdate").html(birthDate);
				
				$("#MailAddress").html(res.data.MailAddress);
				
				if(Common.getBaseConfig("isUseMail") == "Y" && Common.getSession('UR_AssignedBizSection').includes('Mail')){
					$("#MailAddressBtn").show();
					$("#MailAddressBtn").click(function(){
						clickOrgContactMail(res.data.DisplayName,res.data.MailAddress);
					});
				}else{
					$("#MailAddressBtn").hide();
				}
				
				if(Common.getGlobalProperties("lync.chat.used") == "Y"){	//lync, skype 채팅 사용시 sip메일 연동
					$("#sendTalk").attr("href", "sip:"+res.data.MailAddress);
					$("#sendTalk").show();
				} else {
					$("#sendTalk").hide();
				}
				
				$("#PhoneNumber").html(res.data.PhoneNumber);
				
				$("#PhoneNumberInter").html(res.data.PhoneNumberInter);
				
				$("#Mobile").html(res.data.Mobile);
				
				$("#Fax").html(res.data.Fax);
				
				if(res.addJobList){
					var sAddJobDisJob = "<ul style='list-style:none;padding-inline-start: 0px;'>";
					
					res.addJobList.forEach(function(e){
						sAddJobDisJob += "<li>"
						if(e.JobType == 'DisJob'){
							sAddJobDisJob += '[<spring:message code="Cache.lbl_DisJob" />]';
						}else{
							sAddJobDisJob += '[<spring:message code="Cache.lbl_AddJob" />] ';
						}
						sAddJobDisJob += e.DeptName;
				        if(sRepJobTypeConfig != null && sRepJobTypeConfig != ""){
					        if(sRepJobTypeConfig == "PN"){
					        	if(e.JobPositionName != ""){
						        	sAddJobDisJob += "/";
					        	}
					        	sAddJobDisJob += e.JobPositionName;
					        } else if(sRepJobTypeConfig == "TN"){
					        	if(e.JobTitleName != ""){
						        	sAddJobDisJob += "/";
					        	}
					        	sAddJobDisJob += e.JobTitleName;
					        } else if(sRepJobTypeConfig == "LN"){
					        	if(e.JobLevelName != ""){
						        	sAddJobDisJob += "/";
					        	}
					        	sAddJobDisJob += e.JobLevelName;
					        } else{
					        	if(e.JobLevelName != ""){
						        	sAddJobDisJob += "/";
					        	}
					        	sAddJobDisJob += e.JobLevelName;
					        }
				        }

						sAddJobDisJob += "</li>"
					});
					sAddJobDisJob += "</ul>"
					$("#AddJob").html(sAddJobDisJob);
				}
				
			}
			
			//일정
			g_startDate = schedule_SetDateFormat(new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss")), '.');
			scheduleUser.setMyInfoProfileSchedule();
			
			// 최근게시, 전자결재
			if($("#userCode").val() != Common.getSession("UR_Code")){
				$("#divTargetInfo").show();
				setGrid('board');
			}
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
	
	if($("#bottomTab").find("li.active").attr("value") == "board"){
		$("#showMore").hide();
	} else {
		$("#showMore").show();
	}
}

function clickOrgContactMail(displayName, mailAddress){	// covision.control.js
	if(Common.getBaseConfig("isUseExchMail") == "Y" && Common.getBaseConfig("isUseMail") == "Y"){
		// 전송 데이터 세팅
		MailJsonData = {
		  "Token": GetEncryptToken(), // 인증용 JWT 토큰
		  "Subject": "", // 메일 제목
		  "Body": "", // 메일 본문
		  "To": [{'Name':displayName, 'Mail': mailAddress}], // 받는 사람
		  "Cc": [], // 참조
		  "Bcc": [], // 숨은 참조
		  "Attachment": [] // 첨부 파일
		};
		
		exch_mailSend(MailJsonData);
	} else {
		window.open("/mail/bizcard/goMailWritePopup.do?"
				+"callMenu=" + "MailList"
				+ "&userMail=" + Common.getSession("UR_Mail")
				+ "&toUserMail="+mailAddress 
				+ "&toUserName="+displayName
				+ "&ccUserMail="
				+ "&ccUserName="
				+ "&bccUserMail="
				+ "&bccUserName="
				+ "&inputUserId=" + Common.getSession().DN_Code + "_" + Common.getSession().UR_Code
				+ "&popup=Y&isInbox=Y",
				"MailWriteCommonPopup", "height=800, width=1000, resizable=yes");
	}
}

function setGrid(pType){
	setGridConfig(pType);
	bindGrid(pType);
}

function setGridConfig(pType){
	switch(pType) {
		case 'board':
			setBoardGridConfig();
			break;
		case 'approval':
			setApprovalGridConfig();
			break;
	}
}

function bindGrid(pType){
	switch(pType) {
		case 'board':
			boardGrid.bindGrid({
				ajaxUrl : "/groupware/board/selectMyInfoProfileBoardData.do",
				ajaxPars : {
					userCode : $("#userCode").val()
				}
			});
			
			break;
		case 'approval':
			approvalGrid.bindGrid({
				ajaxUrl : "/groupware/approval/getMyInfoProfileApprovalData.do",
				ajaxPars : {
					"userCode" : $("#userCode").val()
				}
			});
			
			break;
	}
}

function setBoardGridConfig(){
	var headerData = [
						{key:'MenuName', label:Common.getDic("lbl_menuName"), width:'100', align:'center',
							formatter: function(){
								const urlParams = new URLSearchParams(this.item.MenuURL);
            					var menuCode = urlParams.get('menuCode');
            					
								return '<div class="tblLink"><a onclick="boardGoMenu(\''+menuCode+'\');">'+this.item.MenuName+'</a></div>';
							}
						},
            			{key:'Subject', label:Common.getDic("lbl_subject"), width:'300', align:'left',
            				formatter: function(){
            					const urlParams = new URLSearchParams(this.item.MenuURL);
            					var menuCode = urlParams.get('menuCode');
            					
            					return '<div class="tblLink"><a onclick="boardGoView(\'Board\', \''+this.item.MenuID+'\', \''+this.item.Version+'\', \''+this.item.FolderID+'\', \''+this.item.MessageID+'\', \'\', \'\', \'\', \'\', \'\', \'List\',\'Normal\', \'\', \''+menuCode+'\');">'+this.item.Subject+'</a></div>';
            				}
            			},
            			{key:'RegistDate', label:Common.getDic("lbl_RegistDate") + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center',
            				formatter: function(){
	        					return CFN_TransLocalTime(this.item.RegistDate, "MM.dd");
	        				}
            			}
            		];

	boardGrid.setGridHeader(headerData);
	
	var configObj = {
		targetID : "boardList",
		height:"auto",
		page:false,
		sort:false
	};
	
	boardGrid.setGridConfig(configObj);
}

function setApprovalGridConfig(){
	var headerData = [
            			{key:'FormSubject', label:Common.getDic("lbl_subject"), width:'300', align:'left',
            				formatter: function(){
            					return '<div class="tblLink"><a onclick="CFN_OpenWindow(\'/approval/approval_Form.do?mode=COMPLETE&processID='+this.item.ProcessArchiveID+'&workitemID='+this.item.WorkitemArchiveID+'&performerID='+this.item.PerformerID+'&processdescriptionID='+this.item.ProcessDescriptionArchiveID+'&userCode='+userId+'&gloct=COMPLETE&admintype=&archived=true&usisdocmanager=true&listpreview=N&subkind='+this.item.SubKind+'\', \'\', 720, (window.screen.height - 100), \'resize\');">'+this.item.FormSubject+'</a></div>';
            				}
            			},
            			{key:'EndDate', label:Common.getDic("lbl_RegistDate") + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center',
            				formatter: function(){
	        					return CFN_TransLocalTime(this.item.EndDate, "MM.dd");
	        				}
            			}
            		];

	approvalGrid.setGridHeader(headerData);
	
	var configObj = {
		targetID : "approvalList",
		displayColHead: true, //설정하지 않을 시 자동으로 true
		height:"auto",
		page:false,
		sort:false
	};
	
	approvalGrid.setGridConfig(configObj);
}

function boardGoView(pBizSection, pMenuID, pVersion, pFolderID, pMessageID, pStartDate, pEndDate, pSortBy, pSearchText, pSearchType, pViewType, pBoardType, pPage, pMenuCode){
	//BizSection에따라 게시판인지 문서관리인지 구분해야함
	var prefix_url = "";
	if(pBizSection != "Doc"){
		prefix_url = "/groupware/layout/board_BoardView.do?CLSYS=board&CLMD=user";
	} else {
		prefix_url = "/groupware/layout/board_BoardView.do?CLSYS=doc&CLMD=user";
	}
	
	var url = String.format("{0}&CLBIZ={1}&menuID={2}&version={3}&folderID={4}&messageID={5}&viewType={6}&boardType={7}&startDate={8}&endDate={9}&sortBy={10}&searchText={11}&searchType={12}&page={13}&menuCode={14}",
		prefix_url,
		pBizSection, 
		pMenuID,
		pVersion, 
		pFolderID, 
		pMessageID,
		pViewType,
		pBoardType,
		pStartDate,
		pEndDate,
		pSortBy,
		pSearchText,
		pSearchType,
		pPage,
		pMenuCode
	);
	
	window.open(url, "_blank");
}

function boardGoMenu(pMenuCode) {
	Common.Close();
	parent.location.href = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuCode="+pMenuCode;
}

// 더보기 버튼
function showMoreData(){
	var url;
	
	if($("#bottomTab").find("li.active").attr("value") == "board"){
		url = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuID=10&searchText="+userName+"&searchType=CreatorName";
	}else{
		url = "/approval/layout/approval_ApprovalList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode=Complete"
	}
	
	Common.Close();
	parent.location.href = url;
}

// 일정 간단보기
function showSimpleScheduleView(obj){
	$("#popup").load("/groupware/schedule/getSimpleViewView.do", function(){
		var eventID = $(obj).attr("eventid");
		var dateID = $(obj).attr("dateid");
		var isRepeat = $(obj).attr("isrepeat");
		var folderID = $(obj).attr("folderid");
		var isPop = "Y";
		
		$("#eventID").val(eventID);
		$("#dateID").val(dateID);
		$("#isRepeat").val(isRepeat);
		$("#folderID").val(folderID);
		
		g_isPopup = true;
		popObj = obj;
		
    	// 데이터 세팅
		scheduleUser.setViewData("S", eventID, dateID, folderID, isRepeat, "", isPop);
    	
    	var popX = $(obj).offset().left;
    	var popY = $(obj).offset().top + $(obj).height();

    	if(popX  > ((Number($(".ProfilePopContainer").css("padding-left").replace("px", "")) + Number($("#scheduleBox").css("width").replace("px", ""))) - Number($(".schViewLayerPopup").css("width").replace("px", "")))){
    		popX = (Number($(".ProfilePopContainer").css("padding-left").replace("px", "")) + Number($("#scheduleBox").css("width").replace("px", ""))) - Number($(".schViewLayerPopup").css("width").replace("px", ""));
    	}
    	
    	$("#popup").css("left", popX);
    	$("#popup").css("top", popY);
    	
    	$("#divBtnBottom>a").eq(0).attr("onclick", "scheduleUser.goDetailViewPage('MyInfo');")
   });
}

//초기 설정 값 셋팅 시 빈값 확인
function isEmptyDefault(value, defaultVal){
	  if(value == null || value == 'undefined' || typeof(value) == 'undefined'){
		  return defaultVal;
	  }
	  return value;
}


function movePeroid(liType){
	var sDate = "";
	var startDateObj = new Date(replaceDate(g_startDate));
	
	 if(liType == "PREV"){		// 이전
		sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -7), '.');
	}else if(liType == "NEXT"){		// 다음
		sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 7), '.');
	}
	
	g_startDate = sDate;
	scheduleUser.setMyInfoProfileSchedule();
}

function goCurrent(){
	g_startDate = schedule_SetDateFormat(g_currentTime, ".");
	g_year = g_startDate.split(".")[0];			// 전역변수 세팅
	g_month = g_startDate.split(".")[1];		// 전역변수 세팅
	g_day = g_startDate.split(".")[2];			// 전역변수 세팅
	
	scheduleUser.setMyInfoProfileSchedule();
}

</script>