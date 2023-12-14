<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cLnbTop">
	<h2><spring:message code='Cache.lbl_schedule_title' /></h2><!-- 일정관리 -->
	<div><a class="btnType01" onclick="CoviMenu_GetContent('schedule_DetailWrite.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule');"><spring:message code='Cache.lbl_schedule_addEvent' /></a></div><!-- 일정등록 -->
</div>
<div class='cLnbMiddle mScrollV scrollVType01'>
	<div class="scheduleMenu">
		<div class="calContanier">
			<div class="calendarTop active">
				<a class="btnFold active" onclick="btnFoldOnClick(this);"><spring:message code='Cache.lbl_folding' /></a><!-- 접기 -->
				<a class="btnPervArrow" onclick="moveLeftMonth('-');"><spring:message code='Cache.lbl_previous' /></a><span class="calTopdate"></span><a class="btnNextArrow" onclick="moveLeftMonth('+');"><spring:message code='Cache.lbl_next' /></a><!-- 이전 --><!-- 다음 -->
				<input type="hidden" id="calTopDateVal" >
			</div>
			<div class="calCont">
			
				<div id="leftCalendar" class="tablCalendar active">
					
				</div>
				<div class="shcLeftLinkMenu">
					<p class="allScheduleView" onclick="aAllOnClick();">
						<a id="aAll" ><span></span><spring:message code='Cache.lbl_schedule_viewAllSchedule' /></a><!-- 전체일정보기 -->
					</p>
				</div>
				<div id="scheduleTotal">
				</div>
				<div id= "schedule" class="myScheduleContent">
				</div>
				<div class="shcLeftLinkMenu">
					<p class="impSchedule" onclick="aImpOnClick();">
						<a id="aImport" ><span></span><spring:message code='Cache.lbl_schedule_impSchedule' /></a><!-- 중요일정 -->
					</p>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- 간단등록에서 상세등록으로 이동시 temp -->
<input type="hidden" id="simpleSelectDatePicker" >
<input type="hidden" id="simpleFolderType" >
<input type="hidden" id="simpleSubject" >
<input type="hidden" id="simpleStartDate" >
<input type="hidden" id="simpleStartHour" >
<input type="hidden" id="simpleStartMinute" >
<input type="hidden" id="simpleEndDate" >
<input type="hidden" id="simpleEndHour" >
<input type="hidden" id="simpleEndMinute" >
<input type="hidden" id="simpleResources" >
<input type="hidden" id="simpleIsAllDay" >
<input type="hidden" id="simpleDescription" >
<script type="text/javascript">
	//# sourceURL=ScheduleUserLeft.jsp
	var loadContent = '${loadContent}';
	var folderCheckList = ";";

	var g_lastURL;
	
	/* if(loadContent == 'true' || location.href.indexOf("schedule_View.do") < 0){
		//2019.03 sunnyhwang 이중 호출로 주석처리
		//scheduleUser.fn_schedule_onload();
	} */
	
	initLeft();
	
	function initLeft(){
		
		// 스크롤
		coviCtrl.bindmScrollV($('.mScrollV'));
		
		g_lastURL = '/groupware/layout/schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&viewType=M';
		
		//if(window.sessionStorage.getItem("ScheduleCheckBox_"+userCode) != null)
		//	folderCheckList = window.sessionStorage.getItem("ScheduleCheckBox_"+userCode);
		if(localStorage.getItem("ScheduleCheckBox_"+userCode) != null) {
			folderCheckList = localStorage.getItem("ScheduleCheckBox_"+userCode);
		} else {
			getMainScheduleMenuList();
		}
			
		//개별호출-일괄호출
		Common.getBaseConfigList(["ScheduleGoogleFolderID"]);
		
		//구글일정
		chkUseGoogleSchedule(Common.getSession("DN_ID"));
		
		//content load - Home.jsp
		if(loadContent == 'true'){
			CoviMenu_OpenMenu("/groupware/layout/schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&viewType=M");
			g_lastURL = "/groupware/layout/schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&viewType=M";
		}
		
		setLeftMenu();
	};
	
	function setLeftMenu(){
		scheduleUser.setAclEventFolderData();
		
		var folderIDs = "";
		
		if($$(schAclArray).find("view").concat().length > 0){
			
			$$(schAclArray).find("view").concat().each(function(i, obj){
				folderIDs += $$(obj).attr("FolderID") + ",";
			});
			
			folderIDs = "(" + folderIDs.substring(0, folderIDs.length-1) + ")";
			
			$.ajax({
			    url: "/groupware/schedule/getACLLeftFolder.do",
			    type: "POST",
			    data: {
			    	"FolderIDs" : folderIDs
			    },
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		var totalFolderHtml = "";
			     		var listFolderHtml = "";
						var defaultFolderList = ";";		 
			     		
			     		// 통합일정 목록 세팅
			     		if(res.totalFolder.length > 0){
			     			$(res.totalFolder).each(function(){
			     				var folderID = this.FolderID; 
			     				var subCount = Number(this.SubCount);
			     				
			     				if(subCount == 0){
			     					totalFolderHtml += "<div class='chkStyle03' id='totalFolder_"+folderID+"'>";
			     					totalFolderHtml += "<input type='checkbox' id='chkMenu"+folderID+"' name='chkMenu' value='"+folderID+"' onchange='checkFolderData(this);'>";
			     					totalFolderHtml += "<label for='chkMenu"+folderID+"'><span id='"+folderID+"' style='background-color:"+this.Color+"'></span>" + this.MultiDisplayName + "</label>";
			     					totalFolderHtml += "</div>";
			     					
			     					defaultFolderList += folderID + ";";
			     				}else{
			     					totalFolderHtml += "<div>";
			     					totalFolderHtml += "<div class='selOnOffBox type02' id='totalFolder_"+folderID+"'>";
			     					totalFolderHtml += "<a  class='btnOnOff' onclick='showSubFolderMenu(this);'>"+ this.MultiDisplayName +"</a>";
			     					totalFolderHtml += "</div>";
//			     					totalFolderHtml += "<div class='selOnOffBoxChk' id='subFolder_"+folderID+"'></div>"
//			     					totalFolderHtml += "</div>";
			     					
			     					// 하위항목 그리기
				     				var child = this.child;
				     				if(child.length > 0){
				     					totalFolderHtml += "<div class='selOnOffBoxChk type02' id='subFolder_"+folderID+"'>"
				     					
				     					$(child).each(function(){
				     						if(this.FolderType == "Folder"){
				     							totalFolderHtml += "<div>";
						     					totalFolderHtml += "<div class='selOnOffBox type02' id='totalFolder_"+folderID+"'>";
						     					totalFolderHtml += "<a  class='btnOnOff' onclick='showSubFolderMenu(this);'>"+ this.MultiDisplayName +"</a>";
						     					totalFolderHtml += "</div>";
				     						} else {
				     							totalFolderHtml += "<div class='chkStyle03' id='schedule_"+this.FolderID+"'>";
					     						totalFolderHtml += "<input type='checkbox' id='chkMenu"+this.FolderID+"' name='chkMenu' value='"+this.FolderID+"' onclick='checkFolderData(this);'>";
					     						totalFolderHtml += "<label for='chkMenu"+this.FolderID+"'><span id='"+this.FolderID+"' style='background-color:"+this.Color+"'></span>" + this.MultiDisplayName;
					     						totalFolderHtml += "</div>";
				     						}
	
				     						defaultFolderList += this.FolderID + ";";
				     					});
				     					
				     					totalFolderHtml += "</div>";
				     				}
	
			     					totalFolderHtml += "</div>";
			     				}
			     				
			     			});
			     			$("#scheduleTotal").html(totalFolderHtml);
			     		}
	
			     		// 일정 목록 세팅
			     		if(res.listFolder.length > 0){
			     			var gBaseConfigGoogleFolderID = coviCmn.configMap["ScheduleGoogleFolderID"];
			     			$(res.listFolder).each(function(){
			     				var folderID = this.FolderID; 
			     				var subCount = Number(this.SubCount);
			     				var folderType = this.FolderType;
			     				
			     				// 구글 연동했을 때만 구글 일정 표시
			     				if(isConnectGoogle == false && folderID == gBaseConfigGoogleFolderID){
			     				}
			     				else{
			     					if(folderType == "Schedule.Cafe" || folderType == "Schedule.Theme"){
				      					var plusClass = "";
				      					listFolderHtml += "<div>";
				      					listFolderHtml += "<div class='selOnOffBox"+plusClass+"' id='schedule_"+folderID+"'>";
				      					listFolderHtml += "<a  class='btnOnOff' onclick='showSubFolderMenu(this);'>"+ this.MultiDisplayName +"</a>";
				      					if(folderType == "Schedule.Theme"){
				      						listFolderHtml += "<a onclick='openThemeList();' class='btnOption' ></a>";
				      					}
				      					listFolderHtml += "</div>";
	
					     				// 하위항목 그리기
					     				var child = this.child;
					     				if(child.length > 0){
					     					listFolderHtml += "<div class='selOnOffBoxChk type02' id='subFolder_"+folderID+"'>"
					     					
					     					$(child).each(function(){
					     						listFolderHtml += "<div class='chkStyle03' id='schedule_"+this.FolderID+"'>";
					     						listFolderHtml += "<input type='checkbox' id='chkMenu"+this.FolderID+"' name='chkMenu' value='"+this.FolderID+"' onclick='checkFolderData(this);'>";
					     						listFolderHtml += "<label for='chkMenu"+this.FolderID+"'><span id='"+this.FolderID+"' style='background-color:"+this.Color+"'></span>" + this.MultiDisplayName;
					     						listFolderHtml += "</div>";
					     					});
					     					
					      					listFolderHtml += "</div>";
					     				}
				      					listFolderHtml += "</div>";
				      				}
			     					else{
				      					listFolderHtml += "<div class='chkStyle03' id='schedule_"+folderID+"'>";
				      					listFolderHtml += "<input type='checkbox' id='chkMenu"+folderID+"' name='chkMenu' value='"+folderID+"' onchange='checkFolderData(this);'>";
				      					listFolderHtml += "<label for='chkMenu"+folderID+"'><span id='"+folderID+"' style='background-color:"+this.Color+"'></span>" + this.MultiDisplayName + "</label>";
				      					
				      					if(folderType == "Schedule.Person"){
				      						listFolderHtml += "<a onclick='openShareList();' class='btnShare'></a>";
										
			      							defaultFolderList += folderID + ";";
				      					}
				      					
				      					listFolderHtml += "</div>";
				      				}
			     				}
			     			});
			     			$("#schedule").html(listFolderHtml);
			     		}
			     		
			     		
			     		var isDefaultLoad = false;
			     		if(folderCheckList == ";" || folderCheckList == "") {
			     			// 최초 좌측메뉴 설정 시 세팅값이 없다면 회사일정, 개인일정 Default 세팅
			     			folderCheckList = defaultFolderList;
			     			isDefaultLoad = true;
			     		}
			     		
			     		
			     		// 세션에서 선택했던 폴더 값 세팅
		     			for (var i=0; i<folderCheckList.split(";").length; i++) {
		     				var val = folderCheckList.split(";")[i];
		     				if(val != "" && val != "undefined" && $$(schAclArray).find("view").concat().find("[FolderID="+val+"]").length > 0){
			     				var tar = $('#chkMenu' + val).closest('.selOnOffBoxChk');
			     				
		     					if ($('#chkMenu' + val).length > 0) {
				                    $("#chkMenu" + val).prop("checked", true);
				                    
			     					tar.addClass('active');
				     				tar.siblings('.selOnOffBox').find('a').addClass('active');
			     				}
		     				}
		                }
		     			
		     			// 기본선택값 조회
			     		if(isDefaultLoad) 
			     			checkFolderData();
			    	}else{
			    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
			    	}
		        },
		        error:function(response, status, error){
					CFN_ErrorAjax("/groupware/schedule/getACLLeftFolder.do", response, status, error);
				}
			});
		}
	}
	
	// 개인일정 설정 팝업
	function openShareList(){
		Common.open("","themeList_Popup","<spring:message code='Cache.lbl_schedule_shareMySch' />","/groupware/schedule/goShareMineList.do","420px","423px","iframe",true,null,null,true);		//내 일정 공유하기
	}
	// 테마일정 설정 팝업
	function openThemeList(){
		Common.open("","themeList_Popup","<spring:message code='Cache.lbl_schedule_themeMng' />","/groupware/schedule/goThemeList.do","420px","320px","iframe",true,null,null,true);				//테마일정관리
	}
	
	// 체크된 Folder 데이터 View로 전달
	function checkFolderData(obj){
		var folderID = $(obj).val();
		if(folderCheckList.indexOf(";"+folderID+";") > -1){
			folderCheckList = folderCheckList.replace(";"+folderID+";", ";");
		}else{
			folderCheckList += folderID + ";";
		}
		
		//window.sessionStorage.setItem("ScheduleCheckBox_"+userCode, folderCheckList);
		localStorage.setItem("ScheduleCheckBox_" + (userCode != sessionObj["USERID"] ? sessionObj["USERID"] : userCode), folderCheckList);
		
		scheduleUser.saveChkFolderListRedis(folderCheckList);
		
		var url = "schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&viewType="+g_viewType+"&startDate="+g_startDate+(g_endDate == undefined ? "" : ("&endDate="+g_endDate));
		CoviMenu_GetContent(url, false);
		g_lastURL = url;
	}
	
	// 하위 폴더 펼치기
	function showSubFolderMenu(obj){
		if ($(obj).hasClass('active')) {
			$(obj).removeClass('active');
			$(obj).closest('.selOnOffBox').siblings('.selOnOffBoxChk').removeClass('active');
		} else {
			$(obj).addClass('active');
			$(obj).closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');
		}
	}
	
	// 전체일정 보기
	var g_allCheck = false;
	function aAllOnClick(){
		// TODO : 폴더로 된 것들을 모두 펼침.
		//$(".btnOnOff").click();
		
		if(g_allCheck){
			folderCheckList = ";";
			
			$("[name=chkMenu]").each(function(){
				$(this).prop("checked", false);
			});
			
			$("#aAll").removeClass("active");
		}else{
			folderCheckList = ";";
			$("[name=chkMenu]").each(function(){
				$(this).prop("checked", true);
				folderCheckList += $(this).val() + ";";
			});
			
			$("#aAll").addClass("active");
		}
		$("#aImport").removeClass("active");
		
		g_allCheck = !g_allCheck;
		
		var url = "schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&viewType="+g_viewType+"&startDate="+g_startDate+(g_endDate == undefined ? "" : ("&endDate="+g_endDate));
		CoviMenu_GetContent(url);
		g_lastURL = url;
		
		//window.sessionStorage.setItem("ScheduleCheckBox_"+userCode, folderCheckList);
		localStorage.setItem("ScheduleCheckBox_"+userCode, folderCheckList);
	}
	//중요일정 보기
	function aImpOnClick(){
		var url = "schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&type=import&viewType="+g_viewType+"&startDate="+g_startDate+(g_endDate == undefined ? "" : ("&endDate="+g_endDate));
		
		if($("#aImport").hasClass("active")){
			url = "schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&type=no_import&viewType="+g_viewType+"&startDate="+g_startDate+(g_endDate == undefined ? "" : ("&endDate="+g_endDate));
			$("#aImport").removeClass("active");	
		}else{
			$("#aImport").addClass("active");
		}
		
		CoviMenu_GetContent(url);
		g_lastURL = url;
		
		$("#aAll").removeClass("active");
	}
	
	//메인 화면 목록 데이터 가져오기
	function getMainScheduleMenuList(){
		$.ajax({
		    url: "/groupware/schedule/getMainScheduleMenuList.do",
		    type: "POST",
		    async: false,
		    data: {
		    	"domainID" : Common.getSession("DN_ID")
		    },
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		if(res.redisData != undefined && res.redisData != ""){
		    			folderCheckList = res.redisData;
		    		}   		
		    	}else{
		    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
		    	}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/getMainScheduleMenuList.do", response, status, error);
			}
		});
	}
	
	function chkUseGoogleSchedule(domainID){
		$.ajax({
			type:"POST",
			data:{
				"DomainID" : domainID
			},
			async: false,
			url:"/covicore/domain/get.do",
			success:function (data){
				var isUseGoogleSchedule = data.list[0].IsUseGoogleSchedule;
				
				if(isUseGoogleSchedule == "Y"){
					initGoogleJS();
				}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/covicore/domain/get.do", response, status, error);
			}
		});
	}
</script>