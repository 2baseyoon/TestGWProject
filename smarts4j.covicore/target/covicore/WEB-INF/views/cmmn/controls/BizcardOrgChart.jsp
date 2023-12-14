<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<script>
	var openerID = CFN_GetQueryString("openerID");
	var callBackFunc = CFN_GetQueryString("callBackFunc");
	var type = CFN_GetQueryString("type") ;
	var treeKind = CFN_GetQueryString("treeKind") ;
	var setParamData = CFN_GetQueryString("setParamData") ;
	var bizcardKind = CFN_GetQueryString("bizcardKind");
	
	$(document).ready(function(){
		init();
	});

	function init(){
			
		var config ={
				targetID: 'orgChart',
				drawOpt:'LMARB', //L:Left, M:Middle, A:Arrow, R:Right, B:Button 
				type: type,
				treeKind: treeKind,
				callbackFunc: callBackFunc,
				openerID: openerID,
				bizcardKind: bizcardKind
		};
		if(type == "MAIL"){
			//debugger;
			config.type = "D9";
			coviOrgMail.render(config);
			
		}else if(type == "BIZCARD"){
			coviOrg.render(config);
		}else if(type != "A0"){

			coviOrg.render(config);			
			if(setParamData != 'undefined' ){
		    	if(openerID != 'undefined' && openerID != ''){
		    		coviOrg.setParamData( coviCmn.getParentFrameObj(openerID)[setParamData] );
		    	}else if(parent[setParamData] != undefined){
					coviOrg.setParamData(parent[setParamData]);
				}else if(opener[setParamData] != undefined){
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