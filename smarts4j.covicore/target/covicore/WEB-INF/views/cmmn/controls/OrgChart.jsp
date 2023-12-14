<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.baseframework.util.SessionHelper"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% 
	String resourceVersion = PropertiesUtil.getGlobalProperties().getProperty("resource.version", ""); 
	resourceVersion = resourceVersion.equals("") ? "" : ("?ver=" + resourceVersion);
	String useTeamsAddIn = "N";
	String userAgent = request.getHeader("User-Agent");
	String pIsTeamsAddIn = request.getParameter("teamsaddin");
    if ((userAgent != null && userAgent.toLowerCase().indexOf("teams") > -1) || (pIsTeamsAddIn != null && pIsTeamsAddIn.toUpperCase().equals("Y"))) {
    	useTeamsAddIn = "Y";
    }
%>

<link rel="stylesheet" id="cCss" type="text/css" /> 
<link rel="stylesheet" id="cthemeCss" type="text/css" />

<% if ("Y".equals(useTeamsAddIn)) { %>
	<!-- Teams Add-In -->
	<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/teams/resources/css/teams.css<%=resourceVersion%>" />
	<script type="text/javascript" src="/covicore/resources/script/MicrosoftTeams.min.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/TeamsApp.js<%=resourceVersion%>"></script>
<% } %>

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
 
<style>
	input[type=checkbox]:disabled { background:#Eaeaea; }
	body { overflow: hidden; }
</style>

<script>
	var openerID = CFN_GetQueryString("openerID");
	var callBackFunc = CFN_GetQueryString("callBackFunc");
	var type = CFN_GetQueryString("type") ;
	var treeKind = CFN_GetQueryString("treeKind") ;
	var allCompany = CFN_GetQueryString("allCompany");
	var setParamData = CFN_GetQueryString("setParamData") ;
	var bizcardKind = CFN_GetQueryString("bizcardKind");
	var userParams = CFN_GetQueryString("userParams");
	var checkboxRelationFixed = CFN_GetQueryString("checkboxRelationFixed");
	var defaultValue = CFN_GetQueryString("defaultValue");
	var loadMyDept = CFN_GetQueryString("loadMyDept");

	$(document).ready(function(){
		init();
		
		$("body").addClass("<%=teams_theme%>");
		if (parent && parent.communityID != '' && parent.communityCssPath != '' && parent.communityTheme != ''){
			$("#cCss").attr("href",parent.communityCssPath + "/community/resources/css/community.css");
			$("#cthemeCss").attr("href",parent.communityCssPath + "/covicore/resources/css/theme/community/"+parent.communityTheme+".css");
		}
		else {
			$("#cCss, #cthemeCss").remove();
		}
	});

	function init(){
		if(allCompany == undefined || allCompany == "" || allCompany == "undefined") {
			allCompany = Common.getBaseConfig("useAffiliateSearch");
			if(Common.getGlobalProperties("isSaaS") == "Y") {
				allCompany = "N";
			}
		}

		var config ={
				targetID: 'orgChart',
				drawOpt:'LMARB', //L:Left, M:Middle, A:Arrow, R:Right, B:Button 
				type: type,
				treeKind: treeKind,
				allCompany: allCompany,
				callbackFunc: callBackFunc,
				openerID: openerID,
				bizcardKind: bizcardKind,
				userParams:userParams,
				checkboxRelationFixed : checkboxRelationFixed=="false"?false:true,
				defaultValue:defaultValue,
				loadMyDept:loadMyDept
		};
		if(type == "MAIL"){
			//debugger;
			config.type = "D9";
			coviOrgMail.render(config);
			
		}else if(type == "TEAMS"){
			config.type = "D9";
			config.drawOpt = "LM_R_";
			config.allCompany = "Y";
			config.bizcardKind = "";
			coviOrgTeams.render(config);
		}else if(type != "A0"){
			coviOrg.render(config);
			if(setParamData != 'undefined' ){
		    	if(openerID != 'undefined' && openerID != ''){
		    		coviOrg.setParamData( coviCmn.getParentFrameObj(openerID)[setParamData] );
                }else if(parent[setParamData] != undefined && parent[setParamData] != ""){
					coviOrg.setParamData(parent[setParamData]);
                }else if(opener[setParamData] != undefined && opener[setParamData] != ""){
					coviOrg.setParamData(opener[setParamData]);
				}
			}
		}else{
			coviOrgA0.render(config);
		}
		
		//var item = {"item":[{"itemType":"user","so":"so","tl":"T2200_1;팀장","po":"P2300_1;부장","lv":"L2300_1;부장","no":"34","AN":"bigkbhan2","DN":"한기복","LV":"L2300_1;부장","TL":"T2200_1;팀장","PO":"P2300_1;부장","MT":"","EM":"","OT":"","SIP":"","USEC":"20130","RG":"U20000003","SG":"U20000003","RGNM":"경영전략","SGNM":"경영전략","ETID":"ORGROOT","ETNM":"코비그룹(공통)","JobType":"Original","UR_Code":"bigkbhan2","ExDisplayName":"한기복","ExJobLevelName":"L2300_1&부장","ExJobPositionName":"P2300_1&부장","ExJobTitleName":"T2200_1;팀장","AD_Mobile":"2042","EX_PrimaryMail":"","AD_PhoneNumber":"2042","PhotoPath":"","MSN_SipAddress":"","ChargeBusiness":"","PhoneNumberInter":"","EmpNo":"20130","GR_Code":"U20000003","GroupName":"경영전략","DN_Code":"ORGROOT","DomainName":"코비그룹(공통)"}]};
		//coviOrg.setParamData(item);
	}	
	
</script>

<div id="orgChart" >
</div>