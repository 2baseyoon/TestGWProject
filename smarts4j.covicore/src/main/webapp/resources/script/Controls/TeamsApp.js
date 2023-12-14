﻿
var teams_ie = ((window.navigator.userAgent.indexOf("MSIE") != -1) ? true : ((window.navigator.userAgent.indexOf("Trident") != -1) ? true : false));
//IE 버젼
var teams_ieVer = ((window.navigator.userAgent.indexOf("MSIE 6") != -1) ? 6 : ((window.navigator.userAgent.indexOf("MSIE 7") != -1) ? 7 : ((window.navigator.userAgent.indexOf("Trident/4.0") != -1) ? 8 : ((window.navigator.userAgent.indexOf("Trident/5.0") != -1) ? 9 : ((window.navigator.userAgent.indexOf("Trident/6.0") != -1) ? 10 : ((window.navigator.userAgent.indexOf("Trident/7.0") != -1) ? 11 : 12))))));
//IE의 호환성 보기와 상관없는 IE의 원버젼 정보
var teams_ieOrgVer = ((window.navigator.userAgent.indexOf("Trident/4.0") != -1) ? 8 : ((window.navigator.userAgent.indexOf("Trident/5.0") != -1) ? 9 : ((window.navigator.userAgent.indexOf("Trident/6.0") != -1) ? 10 : ((window.navigator.userAgent.indexOf("Trident/7.0") != -1) ? 11 : teams_ieVer))));
//Firefox
var teams_firefox = ((window.navigator.userAgent.indexOf("Firefox") != -1) ? true : false);
//Safari
var teams_safari = ((window.navigator.userAgent.indexOf("Safari") != -1 && window.navigator.userAgent.indexOf("Chrome") == -1 && window.navigator.userAgent.indexOf("Mobile") == -1) ? true : false);
//Chrome
var teams_chrome = ((window.navigator.userAgent.indexOf("Chrome") != -1) ? true : false);
//Opera
var teams_opera = ((window.navigator.userAgent.indexOf("Opera") != -1) ? true : false);
//Edge
var teams_edge = ((window.navigator.userAgent.indexOf("Edge") != -1) ? true : false);
//Android
var teams_android = ((window.navigator.userAgent.toLowerCase().indexOf("android") != -1) ? true : false);
//iPhone
var teams_iphone = ((window.navigator.userAgent.toLowerCase().indexOf("iphone") != -1) ? true : false);
//iPad
var teams_ipad = ((window.navigator.userAgent.toLowerCase().toLowerCase().indexOf("ipad") != -1) ? true : false);
//Mac
var teams_mac = ((window.navigator.userAgent.indexOf("Macintosh") != -1) ? true : false);
//coviHybrid
var teams_coviHybrid = ((window.navigator.userAgent.indexOf("COVI_HYBRID") != -1) ? true : false);
//Mobile 여부
var teams_mobile = ((window.navigator.userAgent.indexOf("Mobile") != -1) ? true : (teams_android ? true : (teams_iphone ? true : (teams_ipad ? true : ((window.navigator.userAgent.indexOf("COVI_HYBRID") != -1) ? true : false)))));
//운영체제
var teams_OS = ((window.navigator.userAgent.indexOf("Windows NT 5.1") != -1) ? "WinXp" : ((window.navigator.userAgent.indexOf("Windows NT 5.2") != -1) ? "Win2003Svr" : ((window.navigator.userAgent.indexOf("Windows NT 5") != -1) ? "Win2000" : ((window.navigator.userAgent.indexOf("Windows NT 6.0") != -1) ? "Win2008" : ((window.navigator.userAgent.indexOf("Windows NT 6.1") != -1) ? "Win7" : ((window.navigator.userAgent.indexOf("Windows NT 6.2") != -1) ? "Win8" : ((window.navigator.userAgent.indexOf("Windows NT 6.3") != -1) ? "Win8.1" : "OrderOS")))))))

// Teams의 로딩 표시기를 종료합니다.
function XFN_TeamsLoadComplete() {
    try {
        if (typeof parent.TeamsMain_LoadingComplete == 'function') {
            parent.TeamsMain_LoadingComplete();
        } else {
            microsoftTeams.initialize(window);
            microsoftTeams.appInitialization.notifySuccess();
        }
    } catch (e) {
        microsoftTeams.initialize(window);
        microsoftTeams.appInitialization.notifySuccess();
    }
}

// Teams의 팝업 기능으로 url을 오픈합니다.
// pStrURL = 호출할 URL
// pStrPopupId = 팝업창 Id
// pStrPopupName = 팝업창 Title
// pIntWidth = 팝업창 Width
// pIntHeight = 팝업창 Height
// pStrCallBackMethod = 팝업창의 Callback을 수신받을 Function명
function XFN_TeamsPopupOpen(pStrURL, pStrPopupId, pStrPopupName, pIntWidth, pIntHeight, pStrCallBackMethod) {
    microsoftTeams.initialize(window);

    var oTaskInfo = {
        title: null,
        height: null,
        width: null,
        url: null,
        card: null,
        fallbackUrl: null,
        completionBotId: null,
    };

    if (pStrURL.toLowerCase().indexOf("http") != 0) {
        pStrURL = location.protocol + "//" + location.host + pStrURL;
    }

    oTaskInfo.url = pStrURL;
    oTaskInfo.title = pStrPopupName;
    oTaskInfo.width = pIntWidth;
    oTaskInfo.height = pIntHeight;

    microsoftTeams.tasks.startTask(oTaskInfo, function (pError, pCallbackData) {
        if (pStrCallBackMethod != null && pStrCallBackMethod != "") {
            eval(pStrCallBackMethod + "(\"" + pCallbackData + "\")");
        }
    });
}

// Teams의 팝업 기능으로 열린 페이지 닫기
// pStrCallbackData = 부모창으로 전달할 Callback Data
function XFN_TeamsPopupClose(pStrCallbackData) {
    microsoftTeams.initialize(window);
    microsoftTeams.tasks.submitTask(pStrCallbackData);
}

// Teams에서 브라우저 팝업 호출
// pStrURL = 호출할 URL
// pStrPopupId = 팝업창 Id
// pStrMode = redirect : 페이지 이동 / popup : 새창
// pIntWidth = 팝업창 Width
// pIntHeight = 팝업창 Height
// pStrEtcParam = 팝업창 기타 Parameter(fix / resize / scroll / both / all)
function XFN_TeamsOpenWindow(pStrURL, pStrPopupId, pStrMode, pIntWidth, pIntHeight, pStrEtcParam, pBolIsTeamsPopup) {
    try {
        var sURL = "/covicore/m365/selectTeamsSLOToken.do";
        $.ajax({
            type: "GET",
            url: sURL,
            success: function (data) {
                //Common.AlertClose();

                var sessionObj = Common.getSession();
                var sURL = "/covicore/teamsSLOAuth.do";
                sURL += "?mode=" + pStrMode;
                sURL += "&logonid=" + sessionObj["LogonID"];
                sURL += "&lang=" + sessionObj["lang"];
                sURL += "&width=" + pIntWidth;
                sURL += "&height=" + pIntHeight;
                sURL += "&etcparam=" + pStrEtcParam;
                sURL += "&ReturnUrl=" + encodeURIComponent(pStrURL);
                sURL += "&token=" + encodeURIComponent(data.token);

                window.open(sURL);

                if (pBolIsTeamsPopup) {
                    XFN_TeamsPopupClose();
                }
            },
            error: function (response, status, error) {
                CFN_ErrorAjax(sURL, response, status, error);
            }
        });
    } catch (e) {
        //Common.AlertClose();
        alert(e.stack);
    }
}


// Teams에서 브라우저 팝업 호출(그룹웨어)
// pStrType = 호출할 그룹웨어 모듈(PORTAL / APPROVAL / MAIL...)
function XFN_TeamsOpenGroupware(pStrType) {
    try {
        //Common.Progress();
        var sReturnUrl = "/groupware/portal/home.do?CLSYS=portal&CLMD=user&CLBIZ=Portal";
        switch (pStrType.toUpperCase()) {
            case "APPROVAL":
                sReturnUrl = "/approval/layout/approval_Home.do?CLSYS=approval&CLMD=user&CLBIZ=Approval";
                break;
            case "APPROVAL_FORMLIST":
                sReturnUrl = "/approval/layout/approval_FormList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval";
                break;
            case "ATTENDANCE":
                sReturnUrl = "/groupware/attend/attendHome.do?CLSYS=attend&CLMD=user&CLBIZ=Attend";
                break;
            case "EACCOUNTING":
                sReturnUrl = "/account/accountPortal/portalHome.do?CLSYS=account&CLMD=user&CLBIZ=Account&Auth=A";
                break;
            case "MAIL":
                sReturnUrl = "/mail/layout/mail_Mail.do?CLSYS=mail&CLMD=user&CLBIZ=Mail";
                break;
            case "RESOURCE":
                sReturnUrl = "/groupware/layout/resource_View.do?CLSYS=resource&CLMD=user&CLBIZ=Resource&viewType=D";
                break;
            case "BOARD":
                sReturnUrl = "/groupware/layout/board_BoardHome.do?CLSYS=board&CLMD=user&CLBIZ=Board&menuCode=BoardMain";
                break;
            case "SURVEY":
                sReturnUrl = "/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=proceed&communityId=0";
                break;

        }

        var sURL = "/covicore/m365/selectTeamsSLOToken.do";
        $.ajax({
            type: "GET",
            url: sURL,
            success: function (data) {
                //Common.AlertClose();

                var sessionObj = Common.getSession();
                var sURL = "/covicore/teamsSLOAuth.do";
                sURL += "?mode=" + "REDIRECT";
                sURL += "&logonid=" + sessionObj["LogonID"];
                sURL += "&lang=" + sessionObj["lang"];
                sURL += "&width=" + "0";
                sURL += "&height=" + "0";
                sURL += "&etcparam=" + "";
                sURL += "&ReturnUrl=" + encodeURIComponent(sReturnUrl);
                sURL += "&token=" + encodeURIComponent(data.token);

                window.open(sURL);
            },
            error: function (response, status, error) {
                CFN_ErrorAjax(sURL, response, status, error);
            }
        });
    } catch (e) {
        //Common.AlertClose();
        alert(e.stack);
    }
}

// Teams의 채팅앱으로 이동
// pStrUsers = 참석자들 정보(ex: ckycky85@covision.co.kr,kjkim2@covision.co.kr,hbkim@covision.co.kr,...)
// pStrTopicName = 채팅방 이름
// pStrMessage = 채팅 메시지
function XFN_TeamsDeppLink_Chat(pStrUsers, pStrTopicName, pStrMessage) {
    microsoftTeams.initialize(window);

    //https://teams.microsoft.com/l/chat/0/0?users=<user1>,<user2>,...&topicName=<chat_name>&message=<precanned_text>
    var sLinkURL = "";
    sLinkURL += "https://teams.microsoft.com/l/chat/0/0";
    sLinkURL += "?users=" + encodeURIComponent(pStrUsers);
    sLinkURL += "&topicName=" + encodeURIComponent(pStrTopicName);
    sLinkURL += "&message=" + encodeURIComponent(pStrMessage);

    microsoftTeams.executeDeepLink(sLinkURL);
}

// Teams의 통화앱으로 이동
// pStrUsers = 참석자들 정보(ex: ckycky85@covision.co.kr,kjkim2@covision.co.kr,hbkim@covision.co.kr,...)
// pStrTopicName = 통화방 이름
function XFN_TeamsDeppLink_Call(pStrUsers, pStrTopicName) {
    microsoftTeams.initialize(window);

    //https://teams.microsoft.com/l/call/0/0?users=<user1>,<user2>,...&topicName=<call_name>
    var sLinkURL = "";
    sLinkURL += "https://teams.microsoft.com/l/call/0/0";
    sLinkURL += "?users=" + encodeURIComponent(pStrUsers);
    //sLinkURL += "?users=" + pStrUsers + "&withVideo=true";
    if (pStrTopicName != null && pStrTopicName != "") {
        sLinkURL += "&topicName=" + encodeURIComponent(pStrTopicName);
    }

    microsoftTeams.executeDeepLink(sLinkURL);
}

// Teams의 일정작성화면으로 이동
// pStrAttendees = 참석자들 정보(ex: ckycky85@covision.co.kr,kjkim2@covision.co.kr,hbkim@covision.co.kr,...)
// pStrSubject = 일정 제목
// pStrContent = 일정 본문
// pStrStartDateTime = 일정 시작일시(ex: 2021-02-25 15:00)
// pStrEndDateTime = 일정 종료일시(ex: 2021-02-25 15:00)
function XFN_TeamsDeppLink_Calendar(pStrAttendees, pStrSubject, pStrContent, pStrStartDateTime, pStrEndDateTime) {
    microsoftTeams.initialize(window);

    //https://teams.microsoft.com/l/meeting/new?attendees=<user1>,<user2>,<user3>,...&subject=<meeting_subject>&content=<content>&startTime=<date>&endTime=<date>
    var sLinkURL = "";
    sLinkURL += "https://teams.microsoft.com/l/meeting/new";
    sLinkURL += "?attendees=" + encodeURIComponent(pStrAttendees);
    sLinkURL += "&subject=" + encodeURIComponent(pStrSubject);
    sLinkURL += "&content=" + encodeURIComponent(pStrContent);
    sLinkURL += "&startTime=" + encodeURIComponent(pStrStartDateTime);
    sLinkURL += "&endTime=" + encodeURIComponent(pStrEndDateTime);

    microsoftTeams.executeDeepLink(sLinkURL);
}


// 사용자 팝업 메뉴 표시
function XFN_TeamsShowContextMenu(e, pStrURCode, pStrUPN, pStrMailAddress, pStrTemp) {
    var aStrDictionary = Common.getDicAll("lbl_UserProfile;lbl_Chat;lbl_UserProfileSendMail;lbl_Teams_TeamsCall");
    var sWidth = "92px";
    var sHTML = "";
    sHTML += "<div id=\"divBallomUserProfile\" style='padding-top:5px;padding-left:3px;padding-right:3px'>";
    sHTML += "<ul class=\"user_select\">";
    sHTML += "<li><a href=\"javascript:XFN_TeamsShowUserProfile('" + pStrURCode + "');\">" + aStrDictionary["lbl_UserProfile"] + "</a></li>";
    if (pStrUPN != "") {
        sHTML += "<li><a href=\"javascript:XFN_TeamsDeppLink_Chat('" + pStrUPN + "', '', '');\">" + aStrDictionary["lbl_Chat"] + "</a></li>"; // 대화하기
        //sHTML += "<li><a href=\"javascript:XFN_TeamsDeppLink_Call('" + pStrUPN + "', '');\">" + aStrDictionary["lbl_Teams_TeamsCall"] + "</a></li>"; // 팀즈 앱 통화
    }
    if (pStrMailAddress != "") {
        sHTML += "<li><a href=\"javascript:XFN_TeamsMailWrite('" + pStrMailAddress + "', '" + pStrMailAddress + "');\">" + aStrDictionary["lbl_UserProfileSendMail"] + "</a></li>";
    }

    sHTML += "</ul>";
    sHTML += "</div>";

    if (Common.getSession("LanguageCode").toUpperCase() == "EN") {
        sWidth = "115px";
    } else if (Common.getSession("LanguageCode").toUpperCase() == "JA") {
        sWidth = "148px";
    } else if (Common.getSession("LanguageCode").toUpperCase() == "ZH") {
        sWidth = "94px";
    } else {
        sWidth = "112px";
    }

    Common.openballoon("", "BalloonConnectUser", "", sHTML, sWidth, "", null, null, "left", e);
    if ($("#BalloonConnectUser_p").length > 0) {
        $("#BalloonConnectUser_p").css("position", "absolute");
        $("#BalloonConnectUser_p").css("border", "1px solid #eee");
        $("#BalloonConnectUser_p").css("box-shadow", "0 2px 40px 0 rgb(0 0 0 / 28%)");
        $("#BalloonConnectUser_p").css("background-color", "white");
        $("#BalloonConnectUser_p").css("margin-top", "5px");
        $("#BalloonConnectUser_p").css("padding", "5px");
        $("#BalloonConnectUser_p").css("height", $("#BalloonConnectUser_p").height() + 44);
        $(".user_select li").css("font-size", "13px");
        $(".user_select li").css("height", "20px");
        $(".user_select li").css("padding-left", "7px");
        $(".user_select li").css("background", "url(/HtmlSite/smarts4j_n/covicore/resources/images/covision/dot02.gif) no-repeat 0 5px");
    }
}

// 사용자 프로필 보기
function XFN_TeamsShowUserProfile(pStrURCode) {
    var sURL = "/covicore/control/callTeamsInfo.do";
    sURL += "?userID=" + pStrURCode;
    var sPopupId = "TeamsProfile";
    var sPopupName = "Profile";
    var nWidth = 700;
    var nHeight = 345;

    try {
        $("#BalloonConnectUser_p").attr("layerout", "Y");
        document.onmouseup();
    } catch (e) {coviCmn.traceLog(e) }

    microsoftTeams.initialize(window);

    var oTaskInfo = {
        title: null,
        height: null,
        width: null,
        url: null,
        card: null,
        fallbackUrl: null,
        completionBotId: null,
    };

    if (sURL.toLowerCase().indexOf("http") != 0) {
        sURL = location.protocol + "//" + location.host + sURL;
    }

    oTaskInfo.url = sURL;
    oTaskInfo.title = sPopupName;
    oTaskInfo.width = nWidth;
    oTaskInfo.height = nHeight;

    microsoftTeams.tasks.startTask(oTaskInfo, function (pError, pCallbackData) {

    });
}

// 메일 보내기
function XFN_TeamsMailWrite(pStrDisplayName, pStrMailAddress) {
    try {
        $("#BalloonConnectUser_p").attr("layerout", "Y");
        document.onmouseup();
    } catch (e) {coviCmn.traceLog(e)}

    var sPopupId = "TeamsMailWrite";
    var nWidth = 1200;
    var nHeight = 800;

    var sURL = "/mail/bizcard/goMailWritePopup.do";
    sURL += "?callMenu=MailList";
    sURL += "&toUserMail=" + encodeURIComponent(pStrMailAddress);
    sURL += "&toUserName=" + encodeURIComponent(pStrDisplayName);
    sURL += "&popup=Y";
    sURL += "&isInbox=Y";

    XFN_TeamsOpenWindow(sURL, sPopupId, "POPUP", nWidth, nHeight, "both", false);
}


// 팀 목록 조회
function XFN_TeamsGetTeamList(pTabName, pCallbackMethod) {
    try {
        //Common.Progress();

        microsoftTeams.initialize(window);
        microsoftTeams.authentication.getAuthToken({
            silent: true,
            successCallback: function (oResultAuth) {
                try {
                    var sURL = "/covicore/m365/selectTeamList.do";
                    $.ajax({
                        type: "POST",
                        data: {
                            "authToken": oResultAuth
                        },
                        url: sURL,
                        success: function (data) {
                            //Common.AlertClose();
                            if (typeof pCallbackMethod == "function") {
                                pCallbackMethod(data, pTabName);
                            }
                        },
                        error: function (response, status, error) {
                            CFN_ErrorAjax(sURL, response, status, error);
                        }
                    });
                } catch (e2) {
                    //Common.AlertClose();
                    alert(e2.stack);
                }
            },
            failureCallback: function (oResult) {
                //Common.AlertClose();
                alert(oResult);
            }
        });
    } catch (e) {
        //Common.AlertClose();
        alert(e.stack);
    }
}

// 팀 생성/수정
function XFN_TeamsSetTeam(pMode, pTeamId, pDisplayName, pDescription, pCallbackMethod) {
    try {
        //Common.Progress();

        microsoftTeams.initialize(window);
        microsoftTeams.authentication.getAuthToken({
            silent: true,
            successCallback: function (oResultAuth) {
                try {
                    var sURL = "";
                    var oData = null;
                    if (pMode == "UPDATE") {
                        sURL = "/covicore/m365/updateTeam.do";
                        oData = {
                            "authToken": oResultAuth,
                            "teamid": pTeamId,
                            "displayName": pDisplayName,
                            "description": pDescription
                        };
                    } else {
                        sURL = "/covicore/m365/createTeam.do";
                        oData = {
                            "authToken": oResultAuth,
                            "displayName": pDisplayName,
                            "description": pDescription
                        };
                    }
                    $.ajax({
                        type: "POST",
                        data: oData,
                        url: sURL,
                        success: function (data) {
                            //Common.AlertClose();
                            if (typeof pCallbackMethod == "function") {
                                pCallbackMethod(data);
                            }
                        },
                        error: function (response, status, error) {
                            CFN_ErrorAjax(sURL, response, status, error);
                        }
                    });
                } catch (e2) {
                    //Common.AlertClose();
                    alert(e2.stack);
                }
            },
            failureCallback: function (oResult) {
                //Common.AlertClose();
                alert(oResult);
            }
        });
    } catch (e) {
        //Common.AlertClose();
        alert(e.stack);
    }
}

// 채널 목록 조회
function XFN_TeamsGetChannelList(pTeamId, pCallbackMethod) {
    try {
        //Common.Progress();

        microsoftTeams.initialize(window);
        microsoftTeams.authentication.getAuthToken({
            silent: true,
            successCallback: function (oResultAuth) {
                try {
                    var sURL = "/covicore/m365/selectChannelList.do";
                    $.ajax({
                        type: "POST",
                        data: {
                            "authToken": oResultAuth,
                            "teamid": pTeamId
                        },
                        url: sURL,
                        success: function (data) {
                            //Common.AlertClose();
                            if (typeof pCallbackMethod == "function") {
                                pCallbackMethod(data, pTeamId);
                            }
                        },
                        error: function (response, status, error) {
                            CFN_ErrorAjax(sURL, response, status, error);
                        }
                    });
                } catch (e2) {
                    //Common.AlertClose();
                    alert(e2.stack);
                }
            },
            failureCallback: function (oResult) {
                //Common.AlertClose();
                alert(oResult);
            }
        });
    } catch (e) {
        //Common.AlertClose();
        alert(e.stack);
    }
}

// 채널 생성/수정
function XFN_TeamsSetChannel(pMode, pTeamId, pChannelId, pDisplayName, pDescription, pCallbackMethod) {
    try {
        //Common.Progress();

        microsoftTeams.initialize(window);
        microsoftTeams.authentication.getAuthToken({
            silent: true,
            successCallback: function (oResultAuth) {
                try {
                    var sURL = "";
                    var oData = null;
                    if (pMode == "UPDATE") {
                        sURL = "/covicore/m365/updateChannel.do";
                        oData = {
                            "authToken": oResultAuth,
                            "teamid": pTeamId,
                            "channelid": pChannelId,
                            "displayName": pDisplayName,
                            "description": pDescription
                        };
                    } else {
                        sURL = "/covicore/m365/createChannel.do";
                        oData = {
                            "authToken": oResultAuth,
                            "teamid": pTeamId,
                            "displayName": pDisplayName,
                            "description": pDescription
                        };
                    }
                    $.ajax({
                        type: "POST",
                        data: oData,
                        url: sURL,
                        success: function (data) {
                            //Common.AlertClose();
                            if (typeof pCallbackMethod == "function") {
                                pCallbackMethod(data, pTeamId);
                            }
                        },
                        error: function (response, status, error) {
                            CFN_ErrorAjax(sURL, response, status, error);
                        }
                    });
                } catch (e2) {
                    //Common.AlertClose();
                    alert(e2.stack);
                }
            },
            failureCallback: function (oResult) {
                //Common.AlertClose();
                alert(oResult);
            }
        });
    } catch (e) {
        //Common.AlertClose();
        alert(e.stack);
    }
}

// 팀원 목록 조회
function XFN_TeamsGetTeamMember(pTeamId, pCallbackMethod) {
    try {
        //Common.Progress();

        microsoftTeams.initialize(window);
        microsoftTeams.authentication.getAuthToken({
            silent: true,
            successCallback: function (oResultAuth) {
                try {
                    $.ajax({
                        type: "POST",
                        data: {
                            "authToken": oResultAuth,
                            "teamid": pTeamId
                        },
                        url: "/covicore/m365/selectTeamMemberList.do",
                        success: function (data) {
                            //Common.AlertClose();
                            if (typeof pCallbackMethod == "function") {
                                pCallbackMethod(data, pTeamId);
                            }
                        },
                        error: function (response, status, error) {
                            CFN_ErrorAjax("/covicore/m365/selectTeamMemberList.do", response, status, error);
                        }
                    });
                } catch (e2) {
                    //Common.AlertClose();
                    alert(e2.stack);
                }
            },
            failureCallback: function (oResult) {
                //Common.AlertClose();
                alert(oResult);
            }
        });
    } catch (e) {
        //Common.AlertClose();
        alert(e.stack);
    }
}

// 팀원 추가
function XFN_TeamsSetTeamMemberAdd(pTeamId, pUserCodes, pCallbackMethod) {
    try {
        //Common.Progress();
        microsoftTeams.initialize(window);
        microsoftTeams.authentication.getAuthToken({
            silent: true,
            successCallback: function (oResultAuth) {
                try {
                    var sURL = "/covicore/m365/addTeamMember.do";
                    $.ajax({
                        type: "POST",
                        data: {
                            "authToken": oResultAuth,
                            "teamid": pTeamId,
                            "userCodes": pUserCodes
                        },
                        url: sURL,
                        success: function (data) {
                            //Common.AlertClose();
                            if (typeof pCallbackMethod == "function") {
                                pCallbackMethod(data, pTeamId);
                            }
                        },
                        error: function (response, status, error) {
                            CFN_ErrorAjax(sURL, response, status, error);
                        }
                    });
                } catch (e2) {
                    //Common.AlertClose();
                    alert(e2.stack);
                }
            },
            failureCallback: function (oResult) {
                //Common.AlertClose();
                alert(oResult);
            }
        });
    } catch (e) {
        //Common.AlertClose();
        alert(e.stack);
    }
}

// 팀원 삭제
function XFN_TeamsSetTeamMemberDelete(pTeamId, pMembershipIds, pCallbackMethod) {
    try {
        //Common.Progress();

        microsoftTeams.initialize(window);
        microsoftTeams.authentication.getAuthToken({
            silent: true,
            successCallback: function (oResultAuth) {
                try {
                    var sURL = "/covicore/m365/deleteTeamMember.do";
                    $.ajax({
                        type: "POST",
                        data: {
                            "authToken": oResultAuth,
                            "teamid": pTeamId,
                            "membershipIds": pMembershipIds
                        },
                        url: sURL,
                        success: function (data) {
                            //Common.AlertClose();
                            if (typeof pCallbackMethod == "function") {
                                pCallbackMethod(data, pTeamId);
                            }
                        },
                        error: function (response, status, error) {
                            CFN_ErrorAjax(sURL, response, status, error);
                        }
                    });
                } catch (e2) {
                    //Common.AlertClose();
                    alert(e2.stack);
                }
            },
            failureCallback: function (oResult) {
                //Common.AlertClose();
                alert(oResult);
            }
        });
    } catch (e) {
        //Common.AlertClose();
        alert(e.stack);
    }
}

// Presence 조회
function XFN_TeamsGetPresence(pUserCodes, pAadObjectIds, pSpanID, pCallbackMethod) {
    try {
        microsoftTeams.initialize(window);
        microsoftTeams.authentication.getAuthToken({
            silent: true,
            successCallback: function (oResultAuth) {
                try {
                    var sURL = "/covicore/m365/selectPresence.do";
                    $.ajax({
                        type: "POST",
                        data: {
                            "authToken": oResultAuth,
                            "userCodes": pUserCodes,
                            "aadObjectIds": pAadObjectIds
                        },
                        url: sURL,
                        success: function (data) {
                            //Common.AlertClose();
                            if (typeof pCallbackMethod == "function") {
                                pCallbackMethod(data, pSpanID);
                            }
                        },
                        error: function (response, status, error) {
                            //Common.AlertClose();
                            CFN_ErrorAjax(sURL, response, status, error);
                        }
                    });
                } catch (e2) {
                    //Common.AlertClose();
                    alert(e2.stack);
                }
            },
            failureCallback: function (oResult) {
                //Common.AlertClose();
                alert(oResult);
            }
        });
    } catch (e) {
        //Common.AlertClose();
        alert(e.stack);
    }
}

// Teams의 테마 설정
function XFN_TeamsSetTheme() {
    window.setTimeout(function () {
        microsoftTeams.initialize(window);
        microsoftTeams.getContext(function (oResultContext) {
            XFN_SetCookieDay("Teams_Theme", oResultContext.theme, 31536000000);

            $("body").removeClass("teams_default");
            $("body").removeClass("teams_dark");
            $("body").removeClass("teams_contrast");
            $("body").addClass("teams_" + oResultContext.theme);
        });
    }, 500);
}

// Teams의 테마 변경 Event Handler
function XFN_TeamsRegThemeChangeHandler() {
    microsoftTeams.initialize(window);
    microsoftTeams.registerOnThemeChangeHandler(function (pTheme) {
        // default dark contrast
        XFN_SetCookieDay("Teams_Theme", pTheme, 31536000000);

        $("body").removeClass("teams_default");
        $("body").removeClass("teams_dark");
        $("body").removeClass("teams_contrast");
        $("body").addClass("teams_" + pTheme);
    });
}

//pStrKey : 키
//pStrValue : 값
//pDtExpires : 유지기간(milisecond) [지정하지 않을경우(==null) 현재일에 1일을 더한 설정]
function XFN_SetCookieDay(pStrKey, pStrValue, pExpiresDuration) {
    var dtExpires = new Date();
    //if (pExpiresDuration == null && pExpiresDuration == 0) {
    if (pExpiresDuration == null || pExpiresDuration == 0) {
        dtExpires = XFN_GetDateAddMilisecond(null, 24 * 60 * 60 * 1000)
    } else {
        dtExpires = XFN_GetDateAddMilisecond(null, pExpiresDuration)
    }
    document.cookie = pStrKey + '=' + escape(pStrValue) + ';expires=' + dtExpires.toGMTString() + ';path=/';
}
//날짜 변환 반환
function XFN_GetDateAddMilisecond(pTargetDate, pAddMilisecond) {
    var dtDate = new Date();
    if (pTargetDate != null) {
        dtDate = pTargetDate
    }
    var numb = Date.parse(dtDate);
    dtDate.setTime(numb + pAddMilisecond);

    return dtDate;
}

//플로팅 버튼 Event
function XFN_FloatingBtnMore_OnClick(pObj) {
    $(pObj).removeClass('active');
    $(pObj).siblings().addClass('active');
    $('.popBtn2').fadeIn(100).addClass('active');
}
function XFN_FloatingBtnClose_OnClick(pObj) {
    $(pObj).removeClass('active');
    $(pObj).siblings().addClass('active');
    $('.popBtn2').fadeOut(100).removeClass('active');
}

$(document).ready(function () {
    try {
        if ($("#teams_org_list_page").length == 0) {
            $("#mobile_content").addClass("teams_rw");
        }

        // Teams 테마 처리
        XFN_TeamsSetTheme();
        XFN_TeamsRegThemeChangeHandler();
    } catch (e) {coviCmn.traceLog(e)}
});