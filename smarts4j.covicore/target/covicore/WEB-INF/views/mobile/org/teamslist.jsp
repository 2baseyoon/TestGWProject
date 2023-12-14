<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = PropertiesUtil.getGlobalProperties().getProperty("resource.version", ""); 
	resourceVersion = resourceVersion.equals("") ? "" : ("?ver=" + resourceVersion);
%>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/mobile/resources/css/teams.css<%=resourceVersion%>" />
<script type="text/javascript" src="/covicore/resources/script/MicrosoftTeams.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/TeamsApp.js<%=resourceVersion%>"></script>
<%	
	Cookie[] cookies = request.getCookies();
	String cookieVal = "";
	
	if (cookies != null) {
	  	for (int i = 0 ; i < cookies.length ; i++) {
	        if("Teams_Theme".equals(cookies[i].getName())){
	        	cookieVal = cookies[i].getValue();
	        }
	    } 
	}
	
	String teams_theme = cookieVal.equals("dart") ? "teams_dark" : "";
%>

<script type="text/javascript">
	$(document).on('pageinit', '#teams_org_list_page', function () {
		lang = mobile_comm_getSession("lang"); //다국어
		
		mobile_org_TeamsList();

	});
	
	$(document).ready(function(){
		$("#body").addClass("<%=teams_theme%>");
		
		$(".btn_tslide").click(function(){
			if($(this).parents(".teams_orgchart #divSelectedList").is(":hidden")==false){
				$(this).toggleClass("active");
				$(this).parents(".teams_orgchart #divSelectedList").toggleClass("active");
			}
		});
	});
	
    var g_ChannelList = new Object();
    var g_TeamMemberList = new Object();
	
	function TeamsTab(pTabName) {
		$("div[id^='divTeams']").hide();
		$("li[id^='liTeams']").attr("class", "tabmenu_off");
		$("#div" + pTabName).show();
		$("#li" + pTabName).attr("class", "tabmenu_on");
		
		if (pTabName == "TeamsTeam" || pTabName == "TeamsChannel" || pTabName == "TeamsMember") {
		    SetTeamsTeamList(pTabName);
		}
	}
	
	function TeamsMessage() {
		try {
			var oSelectedUser = $("input[id^='org_list_selecteditems']").val().split(", ");
			if(oSelectedUser.length > 0){
				var sUsers = "";
	    		oSelectedUser.forEach(function(item) {
	    			var oItemInfo = JSON.parse(item);
           			sUsers += "," + oItemInfo.UserCode + "@" + mobile_comm_getBaseConfig("M365Domain");
				});
				XFN_TeamsDeppLink_Chat(sUsers.substring(1), $("#txtTeamsMessageTitle").val(), $("#txtTeamsMessageBody").val());
			} else {
				alert(mobile_comm_getDic("msg_Teams_SelectUser"));
			} 
		} catch (e) {
			alert(e.stack);
		}
	}
	
    function TeamsCalendar() {
    	try {
    		var oSelectedUser = $("input[id^='org_list_selecteditems']").val().split(", ");
			if(oSelectedUser.length > 0){
				var sUsers = "";
				oSelectedUser.forEach(function(item) {
	    			var oItemInfo = JSON.parse(item);
           			sUsers += "," + oItemInfo.UserCode + "@" + mobile_comm_getBaseConfig("M365Domain");
				});
       			XFN_TeamsDeppLink_Calendar(sUsers.substring(1), $("#txtTeamsCalendarTitle").val(), $("#txtTeamsCalendarBody").val(), "", "");
			} else {
				alert(mobile_comm_getDic("msg_Teams_SelectUser"));
			}
     	}
		catch (e) {
			alert(e.stack);
		}
	}
    
	// Teams 팀 목록 설정 
    function SetTeamsTeamList(pTabName) {

        if ((pTabName == "TeamsTeam" && $("#selTeamsTeamListByTeam").text().replace(/ /g, "") == "")
            || (pTabName == "TeamsChannel" && $("#selTeamsTeamListByChannel").text().replace(/ /g, "") == "")
            || (pTabName == "TeamsMember" && $("#selTeamsTeamListByMember").text().replace(/ /g, "") == "")) {
            XFN_TeamsGetTeamList(pTabName, SetTeamsTeamList_Callback);
        } else {
            if (pTabName == "TeamsTeam") {
            	selTeamsTeamListByTeam_OnChange($("#hidTeamsTeamId").val());
            } else if (pTabName == "TeamsChannel") {
            	selTeamsTeamListByChannel_OnChange($("#hidTeamsTeamId").val());
            } else if (pTabName == "TeamsMember") {
            	selTeamsTeamListByMember_OnChange($("#hidTeamsTeamId").val());
            }
        }
    }

    function SetTeamsTeamList_Callback(pResponse, pTabName) {
        try {
            var sOptionHTML = GetTeamsOptionListHTML(pResponse.list);

            $("#selTeamsTeamListByTeam").html("<option value=\"\" data=\"\" selected=\"selected\">" + mobile_comm_getDic("lbl_Teams_NewTeam") + "</option>" + sOptionHTML);  // 신규팀
            $("#selTeamsTeamListByChannel").html(sOptionHTML);
            $("#selTeamsTeamListByMember").html(sOptionHTML);

            if (pTabName == "TeamsTeam") {
            	selTeamsTeamListByTeam_OnChange($("#hidTeamsTeamId").val());
            } else if (pTabName == "TeamsChannel") {
            	selTeamsTeamListByChannel_OnChange($("#hidTeamsTeamId").val());
            } else if (pTabName == "TeamsMember") {
            	selTeamsTeamListByMember_OnChange($("#hidTeamsTeamId").val());
            }
        } catch (e) {
            alert(e.stack);
        }
    }

    // Teams 팀 목록 HTML 조회
    function GetTeamsOptionListHTML(pData) {
        var sHTML = "";
        var nLength = pData.length;
        for (var nIdx = 0; nIdx < nLength; nIdx++) {
            sHTML += "<option value=\"" + pData[nIdx].id + "\" data=\"" + encodeURIComponent(JSON.stringify(pData[nIdx])) + "\">" + $("<div />").text(pData[nIdx].displayName).html() + "</option>";
        }
        return sHTML;
    }
    
    function selTeamsTeamListByTeam_OnChange(pTeamId){
        if (typeof pTeamId != undefined && pTeamId != null && pTeamId != "") {
            $("#selTeamsTeamListByTeam").val(pTeamId);
        }
        
        if ($("#selTeamsTeamListByTeam").val() == "") {
            $("#hidTeamsTeamId").val("");
            $("#txtTeamsTeamDisplayName").val("");
            $("#txtTeamsTeamDesc").val("");
            $("#aTeamsTeamCreate").show();
            $("#aTeamsTeamUpdate").hide();
        } else {
            var sData = decodeURIComponent($("#selTeamsTeamListByTeam > option:selected").attr("data"));
            var oData = JSON.parse(sData);

            $("#hidTeamsTeamId").val(oData.id);
            $("#txtTeamsTeamDisplayName").val(oData.displayName);
            $("#txtTeamsTeamDesc").val(oData.description);
            $("#aTeamsTeamCreate").hide();
            $("#aTeamsTeamUpdate").show();
        }
    }
    
    // Teams 팀 생성/수정
    function SetTeamsTeam_Save(pMode){
        if ($("#txtTeamsTeamDisplayName").val().replace(/ /g, "") == "") {
            // 팀이름을 입력하세요.
            //Common.Warning(Common.getDic("msg_Teams_EnterTeamName"), "Warning Dialog", function () {
            	alert(mobile_comm_getDic("msg_Teams_EnterTeamName"));
                $("#txtTeamsTeamDisplayName").focus();
            //});
        } else {
            XFN_TeamsSetTeam(pMode, $("#hidTeamsTeamId").val(), $("#txtTeamsTeamDisplayName").val(), $("#txtTeamsTeamDesc").val(), SetTeamsTeam_Save_Callback);
        }
    }
    
    function SetTeamsTeam_Save_Callback(pResponse) {
        setTimeout(function () {
            try {
            	mobile_comm_hideload();
            	
                $("#txtTeamsTeamDisplayName").val("");
                $("#txtTeamsTeamDesc").val("");
                $("#selTeamsTeamListByTeam").html("");

                SetTeamsTeamList("TeamsTeam");
            } catch (e) {
                alert(e.stack);
            }
        }, 5000);
    }
    

    // Teams 팀 변경시(채널관리)
    function selTeamsTeamListByChannel_OnChange(pTeamId) {
        var bChanged = false;
        if (typeof pTeamId == undefined || pTeamId == null || pTeamId == "") {
            bChanged = true;
        } else if (pTeamId != $("#selTeamsTeamListByChannel").val()) {
            $("#selTeamsTeamListByChannel").val(pTeamId);
            bChanged = true;
        }
        if ($("#selTeamsTeamListByChannel > option").length > 0 && (bChanged || $("#selTeamsChannelList > option").length == 0)) {
            var sData = decodeURIComponent($("#selTeamsTeamListByChannel > option:selected").attr("data"));
            var oData = JSON.parse(sData);

            $("#hidTeamsTeamId").val(oData.id);

            if (g_ChannelList[oData.id] != undefined && g_ChannelList[oData.id] != null) {
                var sOptionHTML = GetTeamsOptionListHTML(g_ChannelList[oData.id].Data);

                $("#selTeamsChannelList").html("<option value=\"\" data=\"\" selected=\"selected\">" + mobile_comm_getDic("lbl_Teams_NewChannel") + "</option>" + sOptionHTML);  // 신규채널
                selTeamsChannelList_OnChange(true);
            } else {
                SetTeamsChannelList(oData);
            }
        }
    }

    // Teams 채널 목록 설정 
    function SetTeamsChannelList(pData) {
        XFN_TeamsGetChannelList(pData.id, SetTeamsChannelList_Callback);
    }
    function SetTeamsChannelList_Callback(pResponse, pTeamId) {
        try {
            var sOptionHTML = GetTeamsOptionListHTML(pResponse.list);

            $("#selTeamsChannelList").html("<option value=\"\" data=\"\" selected=\"selected\">" + mobile_comm_getDic("lbl_Teams_NewChannel") + "</option>" + sOptionHTML);  // 신규채널
            g_ChannelList[pTeamId] = pResponse;
            selTeamsChannelList_OnChange(true);

            mobile_comm_hideload();
        } catch (e) {
        	mobile_comm_hideload();
            alert(e.stack);
        }
    }

    // Teams 채널 변경시
    function selTeamsChannelList_OnChange(pInit) {
        if (pInit) {
            if ($("#selTeamsChannelList > option[value='" + $("#hidTeamsChannelId").val() + "']").length > 0) {
                $("#selTeamsChannelList").val($("#hidTeamsChannelId").val());
            } else {
                $("#hidTeamsChannelId").val("");
            }
        }

        if ($("#selTeamsChannelList").val() == "") {
            $("#hidTeamsChannelId").val("");
            $("#txtTeamsChannelDisplayName").val("");
            $("#txtTeamsChannelDesc").val("");
            $("#aTeamsChannelCreate").show();
            $("#aTeamsChannelUpdate").hide();
        } else {
            var sData = decodeURIComponent($("#selTeamsChannelList > option:selected").attr("data"));
            var oData = JSON.parse(sData);

            $("#hidTeamsChannelId").val(oData.id);
            $("#txtTeamsChannelDisplayName").val(oData.displayName);
            $("#txtTeamsChannelDesc").val(oData.description);
            $("#aTeamsChannelCreate").hide();
            $("#aTeamsChannelUpdate").show();
        }
    }

    // Teams 채널 생성/수정
    function SetTeamsChannel_Save(pMode) {
        if ($("#txtTeamsChannelDisplayName").val().replace(/ /g, "") == "") {
            // 채널이름을 입력하세요.
            //Common.Warning(Common.getDic("msg_Teams_EnterChannelName"), "Warning Dialog", function () {
            	alert(mobile_comm_getDic("msg_Teams_EnterChannelName"));
                $("#txtTeamsChannelDisplayName").focus();
            //});
        } else {
            XFN_TeamsSetChannel(pMode, $("#hidTeamsTeamId").val(), $("#hidTeamsChannelId").val(), $("#txtTeamsChannelDisplayName").val(), $("#txtTeamsChannelDesc").val(), SetTeamsChannel_Save_Callback);
        }
    }
    function SetTeamsChannel_Save_Callback(pResponse, pTeamId) {
        setTimeout(function () {
            try {
            	mobile_comm_hideload();

                $("#txtTeamsChannelDisplayName").val("");
                $("#txtTeamsChannelDesc").val("");
                $("#selTeamsChannelList").html("");
                g_ChannelList[pTeamId] = null;

                selTeamsTeamListByChannel_OnChange("");
            } catch (e) {
            	mobile_comm_hideload();
                alert(e.stack);
            }
        }, 5000);
    }
    
    // Teams 팀 변경시(팀원관리)
    function selTeamsTeamListByMember_OnChange(pTeamId) {
        var bChanged = false;
        if (typeof pTeamId == undefined || pTeamId == null || pTeamId == "") {
            bChanged = true;
        } else if (pTeamId != $("#selTeamsTeamListByMember").val()) {
            $("#selTeamsTeamListByMember").val(pTeamId);
            bChanged = true;
        }

        if ($("#selTeamsTeamListByMember > option").length > 0 && (bChanged || $("#ulTeamsMemberList > li").length == 0)) {
            var sData = decodeURIComponent($("#selTeamsTeamListByMember > option:selected").attr("data"));
            var oData = JSON.parse(sData);

            $("#hidTeamsTeamId").val(oData.id);
            
            if (g_TeamMemberList[oData.id] != undefined && g_TeamMemberList[oData.id] != null) {
                var sListHTML = GetTeamsTeamMemberListHTML(g_TeamMemberList[oData.id].list);

                $("#ulTeamsMemberList").html(sListHTML);
                $("input[name='chkTeamsMember']").checkboxradio();
            } else {
                SetTeamsTeamMemberList(oData);
            }
        }
    }
    
    // Teams 팀원 목록 설정 
    function SetTeamsTeamMemberList(pData) {
        XFN_TeamsGetTeamMember(pData.id, SetTeamsTeamMemberList_Callback);
    }
    function SetTeamsTeamMemberList_Callback(pResponse, pTeamId) {
        try {
            var sListHTML = GetTeamsTeamMemberListHTML(pResponse.list);

            $("#ulTeamsMemberList").html(sListHTML);
            $("input[name='chkTeamsMember']").checkboxradio();
            g_TeamMemberList[pTeamId] = pResponse;

            mobile_comm_hideload();
        } catch (e) {
        	mobile_comm_hideload();
            alert(e.stack);
        }
    }
    
    // Teams 팀원 전체 선택 클릭시
    function chkTeamsMemberAll_OnClick() {
        $("input[id^='chkTeamsMember']").prop("checked", $("#chkTeamsMemberAll").is(":checked"));
        if($("#chkTeamsMemberAll").is(":checked")){
        	$("#ulTeamsMemberList label").addClass("ui-checkbox-on").removeClass("ui-checkbox-off");
        } else {
        	$("#ulTeamsMemberList label").addClass("ui-checkbox-off").removeClass("ui-checkbox-on");
        }
        
    }
    

    // Teams 팀원 추가
    function SetTeamsTeamMember_Add() {
        try {
    		var oSelectedUser = $("input[id^='org_list_selecteditems']").val().split(", ");
			if(oSelectedUser.length > 0){
				var sUR_Codes = "";
				oSelectedUser.forEach(function(item) {
	    			var oItemInfo = JSON.parse(item);
	    			sUR_Codes += "," + oItemInfo.UserCode;
				});
                sUR_Codes = sUR_Codes.substring(1);
                XFN_TeamsSetTeamMemberAdd($("#hidTeamsTeamId").val(), sUR_Codes, SetTeamsTeamMember_Add_Callback);
            } else {
            	alert(mobile_comm_getDic("msg_Teams_SelectUser"))    // 사용자를 선택하세요.
            }
        } catch (e) {
        	mobile_comm_hideload();
            alert(e.stack);
        }
    }
    function SetTeamsTeamMember_Add_Callback(pResponse, pTeamId) {
        setTimeout(function (sTeamId) {
            try {
            	mobile_comm_hideload();

                g_TeamMemberList[sTeamId] = null;

                selTeamsTeamListByMember_OnChange("");
            } catch (e) {
            	mobile_comm_hideload();
                alert(e.stack);
            }
        }, 5000, pTeamId);
    }

    // Teams 팀원 삭제
    function SetTeamsTeamMember_Delete() {
        try {
            if ($("#selTeamsTeamListByMember > option").length > 0) {
                var oCheckedUser = $("input[name='chkTeamsMember']:checked");
                if (oCheckedUser.length > 0) {
                    var sMembershipIds = "";
                    oCheckedUser.each(function () {
                        var sData = decodeURIComponent($(this).val());
                        var oData = JSON.parse(sData);
                        var sMembershipId = oData.id;
                        var sDisplayName = oData.displayName;
                        sMembershipIds += ";" + sMembershipId;
                    });
                    sMembershipIds = sMembershipIds.substring(1);

                    XFN_TeamsSetTeamMemberDelete($("#hidTeamsTeamId").val(), sMembershipIds, SetTeamsTeamMember_Delete_Callback);
                } else {
                	alert(mobile_comm_getDic("msg_Teams_SelectUser"))    // 사용자를 선택하세요.
                }
            }
        } catch (e) {
        	mobile_comm_hideload();
            alert(e.stack);
        }
    }
    function SetTeamsTeamMember_Delete_Callback(pResponse, pTeamId) {
        setTimeout(function () {
            try {
            	mobile_comm_hideload();

                g_TeamMemberList[pTeamId] = null;

                selTeamsTeamListByMember_OnChange("");
            } catch (e) {
            	mobile_comm_hideload();
                alert(e.stack);
            }
        }, 5000);
    }
    // Teams 팀원 클릭시
    function chkTeamsMember_OnClick() {
        if ($("input[name='chkTeamsMember']").length == $("input[name='chkTeamsMember']:checked").length) {
            $("#chkTeamsMemberAll").prop("checked", true);
            $("#labelTeamsMemberAll").addClass("ui-checkbox-on").removeClass("ui-checkbox-off");
            
        } else {
            $("#chkTeamsMemberAll").prop("checked", false);
            $("#labelTeamsMemberAll").addClass("ui-checkbox-off").removeClass("ui-checkbox-on");
        }
    }
    
    // Teams 팀원 목록 HTML 조회
    function GetTeamsTeamMemberListHTML(pData) {
        var sHTML = "";
        var sAadObjectIds = "";
        var sJobTypeUses = mobile_comm_getBaseConfig("JobTypeUses");
        var arrJobTypeUses = sJobTypeUses.split(";");
        var nLength = pData.length;
        for (var nIdx = 0; nIdx < nLength; nIdx++) {
            var sJobString = "";
            if (pData[nIdx].GroupName != null && pData[nIdx].GroupName != "") {
                sJobString += pData[nIdx].GroupName;
            }
            for (var nIdx2 = 0; nIdx2 < arrJobTypeUses.length; nIdx2++) {
                if (arrJobTypeUses[nIdx2].toUpperCase() == "PN") {
                    if (pData[nIdx].jobPositionName != null && pData[nIdx].jobPositionName != "") {
                        if (sJobString != "") {
                            sJobString += ", ";
                        }
                        sJobString += pData[nIdx].jobPositionName;
                    }
                } else if (arrJobTypeUses[nIdx2].toUpperCase() == "LN") {
                    if (pData[nIdx].jobLevelName != null && pData[nIdx].jobLevelName != "") {
                        if (sJobString != "") {
                            sJobString += ", ";
                        }
                        sJobString += pData[nIdx].jobLevelName;
                    }
                } else if (arrJobTypeUses[nIdx2].toUpperCase() == "TN") {
                    if (pData[nIdx].jobTitleName != null && pData[nIdx].jobTitleName != "") {
                        if (sJobString != "") {
                            sJobString += ", ";
                        }
                        sJobString += pData[nIdx].jobTitleName;
                    }
                }
            }

            sHTML += "<li>";
            
            sHTML += "<input id=\"chkTeamsMember_" + pData[nIdx].userId + "\" ur_code=\"" + pData[nIdx].UR_Code + "\" name=\"chkTeamsMember\" type=\"checkbox\" class=\"input_check\" style=\"cursor: pointer;\" value=\"" + encodeURIComponent(JSON.stringify(pData[nIdx])) + "\" onclick=\"chkTeamsMember_OnClick();\" /> ";
            sHTML += "<label for=\"chkTeamsMember_" + pData[nIdx].userId + "\" style=\"cursor: pointer;\">";
            sHTML += "<span id=\"spanTeamsPresenceMember_" + pData[nIdx].userId + "\" class=\"pState pState06\" title=\"" + mobile_comm_getDic("lbl_Teams_PresenceUnknown") + "\"></span>"; // 알 수 없음
            sHTML += "<span class=\"txt_gn12\" title=\"" + $("<div />").text(pData[nIdx].email).html() + "\">" + $("<div />").text(pData[nIdx].displayName).html() + "</span><span class=\"txt_gn11_blur3\" title=\"" + $("<div />").text(pData[nIdx].email).html() + "\">" + (sJobString == "" ? "" : "(" + $("<div />").text(sJobString).html() + ")") + "</span>";
            sHTML += "</label>";

            sHTML += "</li>";

            sAadObjectIds += "," + pData[nIdx].userId;
        }

        if (sAadObjectIds != "") {
            GetTeamsPresence("", sAadObjectIds.substring(1), "spanTeamsPresenceMember_");
        }
        return sHTML;
    }
    
    // Teams Presence 조회
    function GetTeamsPresence(pUR_Codes, pAadObjectIds, pSpanID) {
        XFN_TeamsGetPresence(pUR_Codes, pAadObjectIds, pSpanID, GetTeamsPresence_Callback);
    }
    function GetTeamsPresence_Callback(pResponse, pSpanID) {
        try {
            if (pResponse.list != undefined && pResponse.list != null) {
                var sTitle = "";
                var nLength = pResponse.list.length;
                for (var nIdx = 0; nIdx < nLength; nIdx++) {
                    switch (pResponse.list[nIdx].availability.toUpperCase()) {
                        case "AVAILABLE":
                            sTitle = mobile_comm_getDic("lbl_Teams_PresenceAvailable")  // 대화 가능
                            sPresenceClass = "pState pState01";
                            break;
                        case "BUSY":
                            sTitle = mobile_comm_getDic("lbl_Teams_PresenceBusy")  // 다른 용무 중
                            sPresenceClass = "pState pState02";
                            break;
                        case "DONOTDISTURB":
                            sTitle = mobile_comm_getDic("lbl_Teams_PresenceDoNotDisturb")  // 방해 금지
                            sPresenceClass = "pState pState03";
                            break;
                        case "BERIGHTBACK":
                            sTitle = mobile_comm_getDic("lbl_Teams_PresenceBeRightBack")  // 곧 돌아오겠음
                            sPresenceClass = "pState pState04";
                            break;
                        case "AWAY":
                            sTitle = mobile_comm_getDic("lbl_Teams_PresenceAway")  // 자리 비움
                            sPresenceClass = "pState pState05";
                            break;
                        case "OFFLINE":
                            sTitle = mobile_comm_getDic("lbl_Teams_PresenceOffline");  // 오프라인
                            sPresenceClass = "pState pState06";
                            break;
                        default:
                            sTitle = mobile_comm_getDic("lbl_Teams_PresenceUnknown");  // 알 수 없음
                            sPresenceClass = "pState pState06";
                            break;
                    }

                    if (pSpanID.indexOf("Member") > -1) {
                        $("#" + pSpanID + pResponse.list[nIdx].id).attr("class", sPresenceClass);
                        $("#" + pSpanID + pResponse.list[nIdx].id).attr("title", sTitle);
                        
                    } else{
                        $("span[id='spanTeamsPresence_" + pResponse.list[nIdx].usercode.toLowerCase() + "']").attr("class", sPresenceClass);
                        $("span[id='spanTeamsPresence_" + pResponse.list[nIdx].usercode.toLowerCase() + "']").attr("title", sTitle);
                    }
                }
            }
        } catch (e) {
            alert(e.stack);
        }
     }
    
    function SetTeamsPresence(){
        var sUR_Codes = "";
        var arrUserList = $("input[id^='org_list_selectuser_']");
        var arrSerchUserList = $("input[id^='org_list_selectsearchuser_']");
        
        arrUserList.each(function () {
            sUR_Codes += "," + $(this).val();
        });
        
        arrSerchUserList.each(function () {
            sUR_Codes += "," + $(this).val();
        });

        if (sUR_Codes != "") {
            GetTeamsPresence(sUR_Codes.substring(1), "", "");
        }
    }
	
</script>

<div data-role="page" id="teams_org_list_page" data-close-btn="none"><!-- data-close-btn="none" > dialog로 띄울시 close 보여서 추가 -->

	<div id="mobile_content" class="ui-mobile-viewport ui-overlay-a">
		<div class="mail_org_wrap teams_orgchart">
		
			<div id="searchdiv" class="searchBox02">
				<a href="javascript: mobile_org_changeDisplay(); " class="topH_back ui-link"><span>이전페이지로 이동</span></a>
				<input type="text" autocomplete="off" placeholder=<spring:message code='Cache.msg_EnterSearchword' /> id="org_search_input" name="inputSelector_onsearch" data-axbind="selector" onkeypress="mobile_org_searchEnter(event)"><!-- 검색어를 입력하세요 -->
	        	<a class="btnSearchType01" onclick="mobile_org_search()"><spring:message code='Cache.lbl_search' /></a> <!-- 검색 -->
	    	</div>
	    	
			<!-- 선택목록 영역 -->
			<div id="org_list_selected" style="display: block;" class="org_select_wrap">
				<ul>
				</ul>
			</div>
			<input type="hidden" id="org_list_selecteditems" />
			
			<!-- 부서 step 영역 -->
			<div class="org_tree_wrap" id="org_list_div_step">
				<a href="javascript: mobile_org_goTop();" class="top"></a>
				<div class="scr_h" style="min-height : 22px;">
					<ol id="org_list_step" ></ol>
				</div>
			</div>
			
			<!-- 하위부서/부서원 영역 -->
			<ul id="org_list_sublist" class="org_list"></ul>
			
			<!-- 검색된 부서/부서원 영역 -->
			<ul id="org_list_searchlist" class="org_list"></ul>
			
			<div id="divSelectedList" class="active">
				<a href="#" class="btn_tslide active">버튼</a>
				<div class="layer_selectlist layer_selectTab">
					<ul class="r_tabmenu">
						<li class="tabmenu_on" id="liTeamsMessage"><a href="javascript:TeamsTab('TeamsMessage')"><spring:message code='Cache.lbl_Teams_Message' /></a></li> <!-- 메시지 -->
						<li class="tabmenu_off" id="liTeamsCalendar"><a href="javascript:TeamsTab('TeamsCalendar')"><spring:message code='Cache.lbl_Teams_Schedule' /></a></li> <!-- 일정예약 -->
						<li class="tabmenu_off" id="liTeamsTeam"><a href="javascript:TeamsTab('TeamsTeam')"><spring:message code='Cache.lbl_Teams_TeamManagement' /></a></li> <!-- 팀관리 -->
						<li class="tabmenu_off" id="liTeamsChannel"><a href="javascript:TeamsTab('TeamsChannel')"><spring:message code='Cache.lbl_Teams_ChannelManagement' /></a></li> <!-- 채널관리 -->
						<li class="tabmenu_off" id="liTeamsMember"><a href="javascript:TeamsTab('TeamsMember')"><spring:message code='Cache.lbl_Teams_TeamMemberManagement' /></a></li> <!-- 팀원관리 -->
					</ul>
					<div id="divTeamsMessage">
						<p class="mtit"><spring:message code='Cache.lbl_Teams_GroupChatName' /></p> <!-- 그룹채팅이름 -->
						<p class="mtxt"><input id="txtTeamsMessageTitle" type="text" maxlength="50"></p>
						<p class="mtit"><spring:message code='Cache.lbl_Teams_Message' /></p> <!--메시지  -->
						<p class="mtxt"><textarea name="txtTeamsMessageBody" id="txtTeamsMessageBody"></textarea></p>
						<div class="mbtn_area">
							<a style="cursor: pointer;" onclick="TeamsMessage();"><em class="btn_or_l"><span class="btn_or_r"><strong class="txt_btn_search2"><spring:message code='Cache.btn_Teams_Send' /></strong></span></em></a> <!-- 보내기 -->
						</div>
					</div>
					<div id="divTeamsCalendar" style="display:none;">
						<p class="mtit"><spring:message code='Cache.lbl_subject' /></p> <!-- 제목 -->
						<p class="mtxt"><input id="txtTeamsCalendarTitle" type="text" maxlength="50"></p>
						<p class="mtit"><spring:message code='Cache.lbl_Contents' /></p> <!-- 내용 -->
						<p class="mtxt"><textarea name="txtTeamsCalendarBody" id="txtTeamsCalendarBody"></textarea></p>
						<div class="mbtn_area">
							<a style="cursor: pointer;" onclick="TeamsCalendar();"><em class="btn_or_l"><span class="btn_or_r"><strong class="txt_btn_search2"><spring:message code='Cache.btn_Teams_ScheduleCreate' /></strong></span></em></a> <!-- 일정작성 -->
						</div>
					</div>
					<div id="divTeamsTeam" style="display:none;">
						<p class="mtxt"><select id="selTeamsTeamListByTeam" onchange="selTeamsTeamListByTeam_OnChange()"></select></p>
						<p class="mtit"><spring:message code='Cache.lbl_Teams_TeamName' /></p> <!-- 팀이름 -->
						<p class="mtxt"><input id="txtTeamsTeamDisplayName" type="text" maxlength="50"></p>
						<p class="mtit"><spring:message code='Cache.lbl_explanation' /></p> <!-- 설명 -->
						<p class="mtxt"><input id="txtTeamsTeamDesc" type="text" maxlength="50"></p>
						<div class="mbtn_area">
							<a id="aTeamsTeamCreate" style="cursor: pointer;" onclick="SetTeamsTeam_Save('CREATE');"><em class="btn_or_l"><span class="btn_or_r"><strong class="txt_btn_search2"><spring:message code='Cache.lbl_Creation' /></strong></span></em></a> <!-- 생성 -->
	    			        <a id="aTeamsTeamUpdate" style="cursor: pointer;" onclick="SetTeamsTeam_Save('UPDATE');"><em class="btn_or_l"><span class="btn_or_r"><strong class="txt_btn_search2"><spring:message code='Cache.lbl_Edit' /></strong></span></em></a> <!-- 수정 -->
						</div>
					</div>
					<div id="divTeamsChannel" style="display:none;">
						<div class="mtxtarea">
							<p class="mtxt"><select id="selTeamsTeamListByChannel" onchange="selTeamsTeamListByChannel_OnChange()"></select></p>
							<p class="mtxt"><select id="selTeamsChannelList" onchange="selTeamsChannelList_OnChange(false)"></select></p>
						</div>
						<p class="mtit"><spring:message code='Cache.lbl_Teams_ChannelName' /></p> <!-- 채널이름 -->
						<p class="mtxt"><input id="txtTeamsChannelDisplayName" type="text" maxlength="50"></p>
						<p class="mtit"><spring:message code='Cache.lbl_explanation' /></p> <!-- 설명 -->
						<p class="mtxt"><input id="txtTeamsChannelDesc" type="text" maxlength="50"></p>
						<div class="mbtn_area">
							<a id="aTeamsChannelCreate" style="cursor: pointer;" onclick="SetTeamsChannel_Save('CREATE');"><em class="btn_or_l"><span class="btn_or_r"><strong class="txt_btn_search2"><spring:message code='Cache.lbl_Creation' /></strong></span></em></a> <!-- 생성 -->
		    			    <a id="aTeamsChannelUpdate" style="cursor: pointer;" onclick="SetTeamsChannel_Save('UPDATE');"><em class="btn_or_l"><span class="btn_or_r"><strong class="txt_btn_search2"><spring:message code='Cache.lbl_Edit' /></strong></span></em></a> <!-- 수정 -->
						</div>
					</div>
					<div id="divTeamsMember" style="display:none;">
						<p class="mtxt"><select id="selTeamsTeamListByMember" onchange="selTeamsTeamListByMember_OnChange()"></select></p>
						<p class="mtit"><spring:message code='Cache.lbl_Teams_TeamMember' /></p> <!-- 팀원 -->
						<div class="mtxt mselbox">
							<div class="layer_searchlist_info2">
								<ul class="layer_searchlist_info_l">
									<li>
										<input id="chkTeamsMemberAll" name="chkTeamsMemberAll" type="checkbox" class="input_check" style="cursor: pointer;" onclick="chkTeamsMemberAll_OnClick();">
										<label id="labelTeamsMemberAll" for="chkTeamsMemberAll" style="cursor: pointer;"><span><spring:message code='Cache.lbl_selectall' /></span></label> <!-- 전체선택 -->
									</li>
								</ul>
							</div>
							<div class="mbtn">
								<a id="A1" style="cursor: pointer;" onclick="SetTeamsTeamMember_Add()"><em class="btn_bs2_l"><span class="btn_bs2_r"><strong class="txt_btn2_bs"><spring:message code='Cache.btn_Add' /></strong></span></em></a> <!-- 추가 -->
								<a id="A2" style="cursor: pointer;" onclick="SetTeamsTeamMember_Delete()"><em class="btn_bs2_l"><span class="btn_bs2_r"><strong class="txt_btn2_bs"><spring:message code='Cache.btn_Delete' /></strong></span></em></a> <!-- 삭제 -->
							</div>
							<div class="layer_selectlist_info_list1_cont layer_list">
								<ul id="ulTeamsMemberList" style="margin-right:0px;">
								</ul>
							</div>
						</div>
					</div>
				</div>
				<div style="height: 0px; overflow: hidden; display:none;">
		    		<input id="hidTeamsTeamId" type="hidden" />
		    		<input id="hidTeamsChannelId" type="hidden" />
		    	</div>
			</div>
		</div>
	</div>
</div>

