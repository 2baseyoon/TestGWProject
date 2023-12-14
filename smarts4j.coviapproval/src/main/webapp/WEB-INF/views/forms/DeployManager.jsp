<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@page import="egovframework.coviframework.util.RedisDataUtil"%>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
	
	String lstr_userID = SessionHelper.getSession("USERID");
	String lstr_langCode = SessionHelper.getSession("lang");
	String lstr_entCode = SessionHelper.getSession("DN_Code");

	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<!DOCTYPE html>
<html>
<head>
	<title></title>
	
	<!--CSS Include Start -->
	<!-- 공통 CSS  -->
	<jsp:include page="/WEB-INF/views/cmmn/PopupInclude.jsp"></jsp:include>

	<style>
		.appTree { height: 100%; }
	</style>
	<!--JavaScript Include Start -->
	<!-- 공통 JavaScript  -->	
	<script type="text/javascript" src="/approval/resources/script/user/common/ApprovalUserCommon.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.orgchart.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/approval/resources/script/forms/DeployManager.js<%=resourceVersion%>"></script>
	<script>
	//# sourceURL=ApvlineManager.jsp
	var myDeptTree = new coviTree();
	var openID =  CFN_GetQueryString("openID")=="undefined"? "":CFN_GetQueryString("openID");
	var admintype =  CFN_GetQueryString("admintype")=="undefined"? "":CFN_GetQueryString("admintype");
  	var selTab = "tSearch";
  	var userID = "<%=lstr_userID%>";
  	var langCode = "<%=lstr_langCode%>";
  	var iItemNum = parseInt("${itemnum}");
   
  	//결재선선택
    var m_oParent, m_oUserList;
    var m_selectedCCRow = null;
    var m_selectedCCRowId = null;

    var ApvListDisplayOrder = "DESC"; // 결재선 목록 정렬 순서 default : DESC(역순), ASC:정순
    let g_GovMultiIdx = CFN_GetQueryString("multiidx") != "undefined" ? CFN_GetQueryString("multiidx") : ""; // 다안기안 선택된 안 idx
    let g_GovMultiReceiveType = CFN_GetQueryString("multireceivetype") != "undefined" ? CFN_GetQueryString("multireceivetype") : ""; // 다안기안 선택된 수신처 타입
    
    $(document).ready(function(){
		setOrgChart();
		
		getPrivateDistribution();
		clickTab($("#aPrivateDomain"));
		clickDeployTab($("#divtPersonDeployList"));
		
	});
    
   $(window).load(function(){
	   fnShowApvLineMgr("close");
   });
   
   
   function setOrgChart(){
		var config ={
				targetID: 'orgTargetDiv',
				drawOpt:'LM___'
		};
		
		coviOrg.render(config);
		coviOrg.contentDoubleClick = contentDoubleClick;
   }
	
	//Double Click 시 결재선에 추가
	function contentDoubleClick(obj){
		$(obj).find("input[type=checkbox]").prop('checked', true);
		$("#btRecDept").click();
	}
	
	//탭 선택(그리드 헤더 변경)
	function clickTab(pObj){
		$("#divTabTray .AXTab").attr("class","AXTab");
		$(pObj).addClass("AXTab on");
		
		var str = $(pObj).attr("value");
		
		$("#PrivateDomain").hide();
		$("#PrivateGroup").hide();
		$("#Group").hide();
		
		$("#" + str).show();
	}
	
	function clickflag(object){
		if(object.css("display") =="none"){
			object.show();
		}else{
			object.hide();
		}
	}
		
	function clickPrivateDistribution(obj){
		var selectID =$("#"+obj.id).attr("value");

		if($("#privateDistribution"+selectID).attr("class")=="persOn"){
			$("tr[id^='privateDistribution']").attr("class","");
			$("td[id^='privateDistributionDataSubject']").attr("class","subject");
			$("ul[id^='privateDistributioMenu']").css({ "display": "none" });
			$("a[id^='privateDistributionMoreEnd']").css({ "display": "none" });
			
			$("#divDeployGroupDetail"+selectID).css({ "display": "none" });
			return;
		}
		
		
		$("tr[id^='privateDistribution']").attr("class","");
		$("#privateDistribution"+selectID).attr("class","persOn");
		
		$("td[id^='privateDistributionDataSubject']").attr("class","subject");
		$("#privateDistributionDataSubject"+selectID).attr("class","appSubject");
		
		$("ul[id^='privateDistributioMenu']").css({ "display": "none" });
		//$("#privateDistributioMenu"+selectID).css({ "display": "" });

		$("a[id^='privateDistributionMoreEnd']").css({ "display": "none" });
		$("#privateDistributionMoreEnd"+selectID).css({ "display": "" });
		
		$("tr[id^='divDeployGroupDetail']").css({ "display": "none" });
		$("#divDeployGroupDetail"+selectID).css({ "display": "" });
		
		getPrivateDistributionMember(selectID);
		
	}
	
	function clickDistribution(obj){
		var selectID =$("#"+obj.id).attr("value");
		
		if($("#distribution"+selectID).attr("class")=="persOn"){
			$("tr[id^='distribution']").attr("class","");
			$("td[id^='distributionSubject']").attr("class","subject");
			
			$("#divDeployListDetail"+selectID).css({ "display": "none" });
			return;
		}
		

		$("tr[id^='distribution']").attr("class","");
		$("#distribution"+selectID).attr("class","persOn");
		
		$("td[id^='distributionSubject']").attr("class","subject");
		$("#pdistributionSubject"+selectID).attr("class","appSubject");
		
		$("tr[id^='divDeployListDetail']").css({ "display": "none" });
		$("#divDeployListDetail"+selectID).css({ "display": "" });
		
		getDeployListDetail(selectID)
	}
	
	function getDistributionList(){
		$.ajax({
			type:"POST",
			url: "apvline/getDistributionList.do",
			data:{
				"entCode" : "<%=lstr_entCode%>"
			},
			success: function(data){
				if(data.result=="ok"){
					var htmlList = "";
		            $.each(data.list, function (i, list) {
		                var groupID = list.GroupID
		                var groupCode = list.GroupCode
		                var groupName = list.GroupName
							
	    		         htmlList += "<tr id='distribution"+groupID+"'>";
		                 htmlList += "<td><input type='checkbox' name='distributionCheckbox' value = '"+groupID+"'/></td>";
		                 htmlList += "<td value='"+groupID+"' onclick='clickDistribution(this)' id='distributionSubject"+groupID+"' class='subject'>" + groupName;
		                 htmlList += "<textarea id='groupCode" + groupID + "'style='display:none;'>" + groupCode + "</textarea>";
		                 htmlList += "<textarea id='" + groupCode + "_CD' name='" + groupCode + "_CD' style='display:none;'>" + groupCode + "</textarea>";
		                 htmlList += "<textarea id='" + groupCode + "_NM' name='" + groupCode + "_NM' style='display:none;'>" + groupName + "</textarea>";	
		                 htmlList += "</td>";
		                 htmlList += "</tr>";
		                 htmlList += "<tr id='divDeployListDetail"+groupID+"' style='display:none'></tr>";
		            });
		            
		            $("#divdetailtDeployList tbody tr").remove()
					$("#divdetailtDeployList").append(htmlList);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("apvline/getDistributionList.do", response, status, error);
			}
		});
	}
	
    //배포그룹 구성원 가져오기
    function getDeployListDetail(pGROUP_ID) {
        var objDetail = document.getElementById("divDeployListDetail" + pGROUP_ID);

        if (document.getElementById("divDeployListDetail" + pGROUP_ID).innerHTML == "") {    // 수신인 목록이 없으면 생성
            getGroupDetailSub(pGROUP_ID);
        }
    }
    
    // 배포그룹 구성원 가져오기 Sub
    function getGroupDetailSub(pGROUP_ID) {
        $.ajax({
        	type:"POST",
        	url: "apvline/getDistributionMember.do",
        	data:{
        		groupID: pGROUP_ID
        	},
        	success: function(data){
        		var htmlList ="<td colspan='2' class='bgG'>";
        		$(data.list).each(function(i,obj){
        			htmlList += "<ul class='proNum'>";
        			htmlList += "<li>"+ (i+1) +"</li>";
        			htmlList += "<li>"+CFN_GetDicInfo(obj.Name,langCode)+"</li>";
        			htmlList += "</ul>";
        		});
        		htmlList += "</td>";
                document.getElementById("divDeployListDetail" + pGROUP_ID).innerHTML = htmlList;
        	},
        	error:function(response, status, error){
				CFN_ErrorAjax("apvline/getDistributionMember.do", response, status, error);
			}
        });
    }
    
    function SetDefaultApvList(privateDomainID,sYN){
        if (privateDomainID == "" && sYN == "Y") {
            return;
        } else {
        	$.ajax({
        		type:"POST",
        		url:"apvline/updatePrivateDomainDefault.do",
        		data:{
        			"defaultYN" : sYN,
        			"userID" : userID,
        			"PrivateDomainID" : privateDomainID
        		},
        		success: function(data){
        			if(data.result=="ok"){
	        			getPrivateDomainList();
        			}
        		},
        		error:function(response, status, error){
    				CFN_ErrorAjax("apvline/updatePrivateDomainDefault.do", response, status, error);
    			}
        	});
        }
    }
        
    function applyApvListGroup() {
        var strPDDID = $('input[name="privateDomainCheckbox"]:checked').val();
        var strGROUP_NAME = "";
        if (strPDDID == undefined || strPDDID == "") {
            //alert("<spring:message code='Cache.msg_apv_172' />");  // 회람 그룹을 선택하십시오.
            return;
        } else {
             //document.getElementById("privateDomainContext"+strPDDID).value = document.getElementById("privateDomainContext"+strPDDID).value.replace(/&/g, '&amp;');
             var sJSON = document.getElementById("privateDomainContext"+strPDDID).value;
             var oJSON = $.parseJSON(sJSON);
          	 var oSteps = $$(oJSON).find("steps");   
          	 switch (m_sApvMode) {
	          	case "REDRAFT":
	                m_oApvList = jQuery.parseJSON(m_oFormMenu.document.getElementById("APVLIST").value.replace(/&/g, "&amp;"));
	                var m_oCurrentOUNode = $$(m_oApvList).find("division[divisiontype='receive']:has(taskinfo[status='pending'])");
	
	                var $$_oSteps = $$(oSteps);
	                
	                if (getInfo("SchemaContext.scPCoo.isUse") == "N") {  //개인합의(순차) 추가
	                	$$_oSteps.find("step[unittype='person'][routetype='assist'][allottype='serial']").remove();
                    }
                    if (getInfo("SchemaContext.scPCooPL.isUse") == "N") {  //개인합의(병렬) 추가
                    	$$_oSteps.find("step[unittype='person'][routetype='assist'][allottype='parallel']").remove();
                    }
                    if (getInfo("SchemaContext.scPAgrSEQ.isUse") == "N") {  //개인협조(순차) 추가
                    	$$_oSteps.find("step[unittype='person'][routetype='consult'][allottype='serial']").remove();
                    }
                    if (getInfo("SchemaContext.scPAgr.isUse") == "N") {  //개인협조(병렬) 추가
                    	$$_oSteps.find("step[unittype='person'][routetype='consult'][allottype='parallel']").remove();
                    }

                    if (getInfo("SchemaContext.scDCooR.isUse") == "N") {  //부서협조(순차) 추가
                    	$$_oSteps.find("step[unittype='ou'][routetype='assist'][allottype='serial']").remove();
                    }
                    if (getInfo("SchemaContext.scDCooPLR.isUse") == "N") {  //부서협조(병렬) 추가
                    	$$_oSteps.find("step[unittype='ou'][routetype='assist'][allottype='parallel']").remove();
                    }
                    if (getInfo("SchemaContext.scDAgrSEQR.isUse") == "N") {  //부서합의(순차) 추가
                    	$$_oSteps.find("step[unittype='ou'][routetype='consult'][allottype='serial']").remove();
                    }
                    if (getInfo("SchemaContext.scDAgrR.isUse") == "N") {  //부서합의(병렬) 추가
                    	$$_oSteps.find("step[unittype='ou'][routetype='consult'][allottype='parallel']").remove();
                    }
	                
	                //추가된 사람 있음 지우기 - 기안자 빼고
	                var elementToRemove = null;
	                $$(m_oCurrentOUNode).find("step > ou > person:has(taskinfo[kind != 'charge'])").each(function (i, $$) {
	                    elementToRemove = $$;
	                    if (elementToRemove != null)elementToRemove.parent().parent().remove(); //step 배열의 요소 삭제
	                });
	
	                var oCheckSteps = chkAbsent(oSteps);
	                if (oCheckSteps) {
	                    $$(oSteps).find("division > step[unittype='person']").each(function (i,$$) {
	                        m_oCurrentOUNode.append($$);
	                    });
	                    //                            var nodesAllItems = oSteps.selectNodes("division/step");
	                    //                            for (var x = 0; x < nodesAllItems.length; x++) {
	                    //                                m_oCurrentOUNode.appendChild(nodesAllItems.item(x));
	                    //                            }
	                    document.getElementById("Apvlist").innerHTML = "";
	                    refreshList();
	                }
	                break;
	          	case "SUBREDRAFT":
                    //alert("error : "+"<spring:message code='Cache.strMsg_047' />");
                    
                    Common.Inform("일반결재자만 적용됩니다.");

					var $$_oSteps = $$(oSteps);

                    //부서협조, 부서합의일때는 일반결재자 외에는 모두 삭제한다.
                    $$_oSteps.find("step > ou[unittype='ou']").remove();

                    $$_oSteps.find("step[routetype!='approve']").remove();

                    $$_oSteps.find("ccinfo").remove();

                    //수신처 삭제
                    $$_oSteps.find("division[divisiontype='receive']").remove();

                    // 일반결재자 외에는 모두 삭제
                    var oApvList = $$("{}").create("steps");
					var $$_oApvList = $$(oApvList);

                    var oCheckSteps = chkAbsent(oSteps);
                    if (oCheckSteps) {
                    	var oStep = $$_oApvList.create("step");
                        var oOU = $$_oApvList.create("ou");
                        var oPerson = $$_oApvList.create("person");
                        var oTaskinfo = $$_oApvList.create("taskinfo");
                        var oDivStep = $$_oSteps.find("division>step").concat().eq(0);
                        var oDivTaskinfo = $$_oSteps.find("division > taskinfo").concat().eq(0);
                        var oDiv = $$_oSteps.find("division").concat().eq(0);
                        $$(oSteps).attr("initiatoroucode", getInfo("AppInfo.dpid_apv"));
                        $$(oStep).attr("unittype", "person");
                        $$(oStep).attr("routetype", "approve");
                        $$(oStep).attr("name", strlable_writer);
                        $$(oOU).attr("code", getInfo("AppInfo.dpid_apv"));
                        $$(oOU).attr("name", getInfo("AppInfo.dpdn_apv"));
                        $$(oPerson).attr("code", getInfo("AppInfo.usid"));
                        $$(oPerson).attr("name", getInfo("AppInfo.usnm_multi"));
                        $$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
                        $$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
                        $$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
                        $$(oPerson).attr("oucode", getInfo("AppInfo.dpid"));
                        $$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
                        $$(oPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
                        $$(oTaskinfo).attr("status", "inactive");
                        $$(oTaskinfo).attr("result", "inactive");
                        $$(oTaskinfo).attr("kind", "charge");
                        $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        $$(oTaskinfo).attr("customattribute1", getInfo("AppInfo.usit"));
                        $$(oDivTaskinfo).attr("status", "inactive");
                        $$(oDivTaskinfo).attr("result", "inactive");
                        $$(oDivTaskinfo).attr("kind", "normal");
                        $$(oDivTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        $$(oDiv).attr("name", strlable_circulation_sent); //"발신"
                        $$(oDiv).attr("oucode", getInfo("AppInfo.dpid_apv"));
                        $$(oDiv).attr("ouname", getInfo("AppInfo.dpdn_apv"));
                        $$(oDiv).attr("divisiontype", "send");
                       
                        $$(oPerson).attr("taskinfo",oTaskinfo.json());
                        $$(oOU).attr("person",oPerson.json());
                        $$(oStep).attr("ou",oOU.json());
                        oDiv.find("step").json().splice(0,0,oStep.json());
                    	                        
                        //m_oApvList.loadXML((new XMLSerializer()).serializeToString(oSteps[0]));
                        m_oApvList = oSteps.json(true);
						$$_m_oApvList = $$(oSteps.json(true));
                        document.getElementById("Apvlist").innerHTML = "";
                        refreshList();
                        refreshCC(true);
                    }
                    break;
                default:
                    var oCheckSteps = chkAbsent(oSteps);
                    var oApvList = $$("{}").create("steps");
					var $$_oApvList = $$(oApvList);
					
					var $$_oSteps = $$(oSteps);
					
					if (getInfo("SchemaContext.scPCoo.isUse") == "N") {  //개인합의(순차) 추가
						$$_oSteps.find("step[unittype='person'][routetype='assist'][allottype='serial']").remove();
                    }
                    if (getInfo("SchemaContext.scPCooPL.isUse") == "N") {  //개인합의(병렬) 추가
                    	$$_oSteps.find("step[unittype='person'][routetype='assist'][allottype='parallel']").remove();
                    }
                    if (getInfo("SchemaContext.scPAgrSEQ.isUse") == "N") {  //개인협조(순차) 추가
                    	$$_oSteps.find("step[unittype='person'][routetype='consult'][allottype='serial']").remove();
                    }
                    if (getInfo("SchemaContext.scPAgr.isUse") == "N") {  //개인협조(병렬) 추가
                    	$$_oSteps.find("step[unittype='person'][routetype='consult'][allottype='parallel']").remove();
                    }

                    if (getInfo("SchemaContext.scDCoo.isUse") == "N") {  //부서협조(순차) 추가
                    	$$_oSteps.find("step[unittype='ou'][routetype='assist'][allottype='serial']").remove();
                    }
                    if (getInfo("SchemaContext.scDCooPL.isUse") == "N") {  //부서협조(병렬) 추가
                    	$$_oSteps.find("step[unittype='ou'][routetype='assist'][allottype='parallel']").remove();
                    }
                    if (getInfo("SchemaContext.scDAgrSEQ.isUse") == "N") {  //부서합의(순차) 추가
                    	$$_oSteps.find("step[unittype='ou'][routetype='consult'][allottype='serial']").remove();
                    }
                    if (getInfo("SchemaContext.scDAgr.isUse") == "N") {  //부서합의(병렬) 추가
                    	$$_oSteps.find("step[unittype='ou'][routetype='consult'][allottype='parallel']").remove();
                    }

                    if (getInfo("SchemaContext.scPRec.isUse") == "N" && getInfo("SchemaContext.scPRecEnt.isUse") == "N" && getInfo("SchemaContext.scPRecReg.isUse") == "N") {  //수신담당자
                    	$$_oSteps.find("division[divisiontype='receive']:has(step[unittype='person'][routetype='receive'])").remove();
                    }
                    if (getInfo("SchemaContext.scDRec.isUse") == "N" && getInfo("SchemaContext.scDRecEnt.isUse") == "N" && getInfo("SchemaContext.scDRecReg.isUse") == "N") {  //수신부서
                    	$$_oSteps.find("division[divisiontype='receive']:has(step[unittype='ou'][routetype='receive'])").remove();
                    }
					
                    var oReceiveDivision = $$_oSteps.find("division[divisiontype='receive']");
                    $$_oSteps.find("division[divisiontype='receive']").remove();
                    
                    if (oCheckSteps) {
                        var oStep = $$_oApvList.create("step");
                        var oOU = $$_oApvList.create("ou");
                        var oPerson = $$_oApvList.create("person");
                        var oTaskinfo = $$_oApvList.create("taskinfo");
                        var oDivStep = $$_oSteps.find("division>step").concat().eq(0);
                        var oDivTaskinfo = $$_oSteps.find("division > taskinfo").concat().eq(0);
                        var oDiv = $$_oSteps.find("division").concat().eq(0);
                        $$(oSteps).attr("initiatoroucode", getInfo("AppInfo.dpid_apv"));
                        $$(oStep).attr("unittype", "person");
                        $$(oStep).attr("routetype", "approve");
                        $$(oStep).attr("name", strlable_writer);
                        $$(oOU).attr("code", getInfo("AppInfo.dpid_apv"));
                        $$(oOU).attr("name", getInfo("AppInfo.dpdn_apv"));
                        $$(oPerson).attr("code", getInfo("AppInfo.usid"));
                        $$(oPerson).attr("name", getInfo("AppInfo.usnm_multi"));
                        $$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
                        $$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
                        $$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
                        $$(oPerson).attr("oucode", getInfo("AppInfo.dpid"));
                        $$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
                        $$(oPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
                        $$(oTaskinfo).attr("status", "inactive");
                        $$(oTaskinfo).attr("result", "inactive");
                        $$(oTaskinfo).attr("kind", "charge");
                        $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        $$(oTaskinfo).attr("customattribute1", getInfo("AppInfo.usit"));
                        $$(oDivTaskinfo).attr("status", "inactive");
                        $$(oDivTaskinfo).attr("result", "inactive");
                        $$(oDivTaskinfo).attr("kind", "normal");
                        $$(oDivTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        $$(oDiv).attr("name", strlable_circulation_sent); //"발신"
                        $$(oDiv).attr("oucode", getInfo("AppInfo.dpid_apv"));
                        $$(oDiv).attr("ouname", getInfo("AppInfo.dpdn_apv"));
                        $$(oDiv).attr("divisiontype", "send");
						
                        if ((getInfo("SchemaContext.scPRec.isUse") == "Y" || getInfo("SchemaContext.scPRecEnt.isUse") == "Y" || getInfo("SchemaContext.scPRecReg.isUse") == "Y"
                        		|| getInfo("SchemaContext.scDRec.isUse") == "Y" || getInfo("SchemaContext.scDRecEnt.isUse") == "Y" || getInfo("SchemaContext.scDRecReg.isUse") == "Y") 
                        		&& oReceiveDivision.length > 0) {
                            //개인결재선에 추가된 수신처 추가
                            if ($$_oSteps.find("division[divisiontype='receive']").length >= parseInt(gRequestDivisionLimit)) {
                                var message = msg_RequestDivisionLimit.replace(/\{0\}/g, gRequestDivisionLimit);
                                alert(message);

                            } else {
                                $$(oReceiveDivision).concat().each(function (i, item) {
                                    if ($$(item).find("step").length == 0) {
                                        return;
                                    }
                                    if ($$_oSteps.find("division[divisiontype='receive']").length >= parseInt(gRequestDivisionLimit)) {
                                        return false;
                                    }
                                    else if ($$_oSteps.find("division[divisiontype='receive'][oucode=" + $$(item).attr("oucode") + "]").length == 0) {
                                    	$$_oSteps.append("division", $$(item).json());
                                    }
                                });
                            }
                        }
                        
                        $$(oPerson).attr("taskinfo",oTaskinfo.json());
                        $$(oOU).attr("person",oPerson.json());
                        $$(oStep).attr("ou",oOU.json());
                        
                        if(oDiv.find("step").length == 0) {
                        	$$(oDiv).append("step", oStep.json());
                        }
                        else {
                        	oDiv.find("step").json().splice(0,0,oStep.json());	
                        }                        
						
                        //m_oApvList.loadXML((new XMLSerializer()).serializeToString(oSteps[0]));
                        m_oApvList = oSteps.json(true);
						$$_m_oApvList = $$(oSteps.json(true));
                        document.getElementById("Apvlist").innerHTML = "";
                        refreshList();
                        refreshCC(true);
                    }
                    break;
          	 }
        }
    }
    
    function getPrivateDistribution() {
    	
    	$.ajax({
    		type:"POST",
    		url: "/approval/apvline/getPrivateDistribution.do",
    		data:{
    			userID: userID
    		},
    		success:function(data){
    			var htmlList = "";
    	    	
    			$(data.list).each(function(i,obj){
    				 var privateDistributionID = obj.GroupID;
    		         var displayName = obj.DisplayName;
    		         
    		         htmlList += "<tr id='privateDistribution"+privateDistributionID+"'>";
	                 htmlList += "<td><input type='checkbox' name='privateDistributionCheckbox' value = '"+privateDistributionID+"'/></td>";
	                 htmlList += "<td id='privateDistributionDataSubject"+privateDistributionID+"' class='subject'><span id ='privateDisSubjectSpan"+privateDistributionID+"' value='"+privateDistributionID+"' onclick='clickPrivateDistribution(this)' >" + displayName + "</span>"
	                 htmlList += "<a href='#' id='privateDistributionMoreEnd"+privateDistributionID+"' class='moreEnd' style='display:none' onclick='clickflag($(\"#privateDistributioMenu"+privateDistributionID+"\"));'><spring:message code='Cache.lbl_MoreView'/></a>"; /*더보기*/
	                 htmlList += "<ul id='privateDistributioMenu"+privateDistributionID+"'class='menu_more' style='display:none'>";
	                 htmlList += "<li><span>icn</span></li>";
	                 htmlList += "<li class='first' onclick='deletePrivateDistribution("+privateDistributionID+"); $(\"#privateDistributioMenu"+privateDistributionID+"\").hide();'><spring:message code='Cache.btn_delete'/></li>"; /*삭제 */ 
	                 htmlList += "</ul>";
	                 htmlList += "</td>";
	                 htmlList += "</tr>";
	                 htmlList += "<tr id='divDeployGroupDetail"+privateDistributionID+"' style='display:none'></tr>";
			         
    			});
    		    
    			$("#divdetailtPersonDeployList tbody tr").remove()
				$("#divdetailtPersonDeployList").append(htmlList);
    		},
    		error:function(response, status, error){
				CFN_ErrorAjax("apvline/getPrivateDistribution.do", response, status, error);
			}
    	});
      
   }
    
    //개인수신처 삭제
    function deletePrivateDistribution(strPDDID) {
        Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (result) {
           if (result) {
        	    $.ajax({
        	    	type:"POST",
        	    	url:"apvline/deletePrivateDistribution.do",
        	    	data:{
        	    		groupID: strPDDID
        	    	},
        	    	success:function(data){
        	    		if(data.result=="ok"){
        	    			getPrivateDistribution();
        	    		}
        	    	},
        	    	error:function(response, status, error){
        				CFN_ErrorAjax("apvline/deletePrivateDistribution.do", response, status, error);
        			}
        	    });
            }
        });
    }
   //배포그룹 구성원 가져오기
   function getPrivateDistributionMember(pPDD_ID) {
       var objDetail = document.getElementById("divDeployGroupDetail" + pPDD_ID);

       if (document.getElementById("divDeployGroupDetail" + pPDD_ID).innerHTML == "") {   
               getPrivateDistributionMemberSub(pPDD_ID);
       }
   }
   
   function getPrivateDistributionMemberSub(strPDDID) {

	   $.ajax({
		   type:"POST",
		   url: "apvline/getPrivateDistributionMember.do",
		   data:{
			   groupID: strPDDID,
			   CheckType: "divtPersonDeployList"
		   },
		   success:function(data){
			   
			   //jsoner-conver 02 시작
			   var rtnValue = "";
       		   var htmlList = "<td colspan='2' class='bgG'>";
       		   var idx =0;
			   
       		   $$(data).find('list[Type="group"]').each(function(i,$$){
       			   htmlList += displayPrivateDistributionDetail( (i+1) , strPDDID, $$.attr('GroupMemberID'), CFN_GetDicInfo($$.attr('ReceiptName'),langCode) );
       			   idx=i+1;
			   });

			   $$(data).find('list[Type="user"]').each(function(i,$$){
				   htmlList += displayPrivateDistributionDetail( (idx+i+1) , strPDDID,$$.attr('GroupMemberID'), CFN_GetDicInfo($$.attr('ReceiptName'),langCode));	 
			   });
			   
			   htmlList += "</td>";
		       document.getElementById("divDeployGroupDetail" + strPDDID).innerHTML = htmlList;
			   //jsoner-conver 02 끝
			   
		   },
		   error:function(response, status, error){
				CFN_ErrorAjax("apvline/getPrivateDistributionMember.do", response, status, error);
			}
	   });
  }
   
 
  function displayPrivateDistributionDetail(strNum, strPDDID, strId, strName) {
       var rtnValue = "";

       rtnValue += "<ul class='proNum'>";
       rtnValue += "<li>"+strNum+"</li>";
       rtnValue += "<li>"+strName+"</li>";
       rtnValue += "</ul>";
       return rtnValue;
   }
  
   //개인수신처 수신자 삭제
  function delDeployGroupDetail(strPDDID, strId) {
      Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (result) {
         if (result) {
        	 $.ajax({
     	    	type:"POST",
     	    	url:"apvline/deletePrivateDistributionMemberData.do",
     	    	data:{
     	    		groupMemberID: strId
     	    	},
     	    	success:function(data){
     	    		if(data.result=="ok"){
     	    			getPrivateDistributionMemberSub(strPDDID);
     	    		}
     	    	},
     	    	error:function(response, status, error){
    				CFN_ErrorAjax("apvline/deletePrivateDistributionMemberData.do", response, status, error);
    			}
     	    });
          }
      });
  }
    
//결재선 추출
  function getApvListGroupXML() {
       
      //JAR-CONVERT 02 시작
	  var oJSON = $.parseJSON(JSON.stringify(m_oApvList)); 

      var elementToRemove = null;

      if(getInfo("Request.mode") == "REDRAFT"){
          //기안자 제거
          $$(oJSON).find("steps > division[divisiontype='receive'] > step > ou > person:has(taskinfo[kind='charge'])").each(function (i, $$) {
              elementToRemove = $$;
          });
          if (elementToRemove != null) elementToRemove.parent().parent().remove(); //step 배열 요소 삭제 (ex.)

          //감사-부서처리 제거
          //$$(oJSON).find("steps > division[divisiontype='receive'] > step[routetype='audit'],steps > division[divisiontype='receive'] > step[unittype='ou']").each(function (i, $$) {
          $$(oJSON).find("steps > division[divisiontype='receive'] > step[routetype='audit']").each(function (i, $$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove(); //step 배열 요소 삭제
          });

          //발신부서 삭제
          $$(oJSON).find("steps > division[divisiontype='send'] ").each(function (i, $$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove(); //division 배열 요소 삭제 (ex. division[1] 삭제)
          });

          //다른 division 삭제
          $$(oJSON).find("steps > division").concat().has("taskinfo[status!='pending']").each(function (i, $$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove(); //division 배열 요소 삭제 (ex. division[1] 삭제)
          });
         
          //발신부서 참조 제거
          $$(oJSON).find("steps > ccinfo[belongto='sender']").each(function (i, $$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove();
          });
      }else{
          //기안자 제거
          $$(oJSON).find("steps> division[divisiontype='send']> step > ou > person:has(taskinfo[kind='charge')").each(function (i, $$) {
              elementToRemove = $$;
          });
          if (elementToRemove != null) elementToRemove.parent().parent().remove(); //step 배열 요소 삭제 (ex. step[0] 삭제)

          //감사-부서처리 제거
          //$$(oJSON).find("steps > division[divisiontype='send'] > step[routetype='audit'],steps > division[divisiontype='send'] > step[unittype='ou']").each(function (i,$$) {
          $$(oJSON).find("steps > division[divisiontype='send'] > step[routetype='audit']").each(function (i,$$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove(); //step 배열 요소 삭제 
          });
      }

      return JSON.stringify(oJSON);
  }
  
  //개인 수신처 생성
  function savePrivateDistribution(){
      
      Common.Prompt("<spring:message code='Cache.msg_apv_278' />","","<spring:message code='Cache.lbl_apv_persongroup' />",function(strGroup){
    	  
    	  if(strGroup == null){
    		  return;
    	  }else if (strGroup == "") {
	          Common.Warning("<spring:message code='Cache.msg_apv_278' />");  // 배포그룹 이름을 입력하세요.
	          return;
	      }else if (getDeployGroupXML().user.length < 1 && getDeployGroupXML().group.length < 1){
	    	  Common.Warning(Common.getDic("msg_apv_003")); //선택된 항목이 없습니다.
	          return;
	      }
    	  
	      Common.Confirm("<spring:message code='Cache.msg_apv_155' />", "Confirmation Dialog", function (result) {
	    	  if (!result) return; 
		
	    	  $.ajax({
	    		  type:"POST",
	    		  url:"apvline/insertPrivateDistribution.do",
	    		  data : {
	    			  "type":'D',
	    			  "ownerID" : userID,
	    			  "displayName" : strGroup,
	    			  "privateContext" : JSON.stringify(getDeployGroupXML()),
	    		  },
	    		  success : function(data){
	    			  if(data.result =="ok" && data.cnt >=1 )
	    				  getPrivateDistribution();
	    		  },
	    		  error:function(response, status, error){
	  				CFN_ErrorAjax("apvline/insertPrivateDistribution.do", response, status, error);
	  			}
	    	  });
	      });
      });
  }
//개인배포목록 수신자 가져오기
  function getDeployGroupXML() {
 
      var userArr = new Array();
      var groupArr = new Array();
      var strReturn = new Object();
      $("#tblrecinfo").find("tr").each(function (x, elm) {
	      var temp = new Object();
          if(x > 0 && parseInt($(elm).attr("mType")) < 2){
              var oitem = new Object();
              oitem.AN = $(elm).attr("AN");
              oitem.DN=$(elm).attr("DN");
              oitem.RG= "";
              oitem.RGNM="";
              oitem.SG="";
              oitem.SGNM= "";
              oitem.ETNM="";
              oitem.hasChild= $(elm).find("td>input[type='Checkbox']").length;
              oitem.SORTKEY=x.toString();
              if($(elm).attr("mType")=="0"){
                  var strUserArr = new Array();
                  var ogroupItem = new Object();
                  var aRecDept = m_RecDept.split("@")[0].split(";");
                  for (var ii = 0; ii < aRecDept.length; ii++) {
                      if (aRecDept[ii].indexOf("##") > -1) {
                          if ($(elm).attr("AN") == aRecDept[ii].split(":")[0]) {
                              var aSelectRecDept = aRecDept[ii].split("##")[1].split("$$");
                              for (var i = 0; i < aSelectRecDept.length; i++) {
                            	  ogroupItem.AN = aSelectRecDept[i].split(":")[0];
      							  ogroupItem.DN = XFN_Replace(aSelectRecDept[i].split(":")[1],"^",";");
      							  ogroupItem.RG = $(elm).attr("AN");
      							  temp.item = ogroupItem;
      							  strUserArr.push(temp);
      							  temp = new Object();
                              }
                          }
                      }
                  }
                  //strReturn += "</item>";
                  if(strUserArr != ""){
                	  oitem.user = strUserArr;
                  }
                  temp.item = oitem;
                  groupArr.push(temp);
              }else{
            	  temp.item = oitem;
            	  userArr.push(temp);
              }
          }
      });
      
      strReturn.user = userArr;
      strReturn.group = groupArr;
      
      return strReturn;
  }
  
  function clickDeployTab(obj){
	  var objID = obj.id;
	  if(objID=="divtPersonDeployList"){//개인배포
		  $("#divtPersonDeployList").attr("class","on");
		  $("#divtDeployList").attr("class","off");
		  
		  $("#divdetailtPersonDeployList").attr("style", "display:;");
		  $("#divdetailtDeployList").attr("style", "display:none;");
		  $("#applyPrivateDistributionBtn").attr("style", "display:;");
		  $("#applyDistributionBtn").attr("style", "display:none;");
		  getPrivateDistribution();	  
	  } else if(objID=="divtDeployList"){//공용배포
		  $("#divtDeployList").attr("class","on");
		  $("#divtPersonDeployList").attr("class","off");
		  
		  $("#divdetailtDeployList").attr("style", "display:;");
		  $("#divdetailtPersonDeployList").attr("style", "display:none;");
		  
		  $("#applyPrivateDistributionBtn").attr("style", "display:none;");
		  $("#applyDistributionBtn").attr("style", "display:;");
		  getDistributionList()	
	  }
  }
  
  function applyPrivateDistribution(){
	  var listIDs = $('input[name="privateDistributionCheckbox"]:checked');
	  
	  //다중선택의 경우를 위해 반복문
	  for(var i = 0; i<listIDs.length;i++){
			
		  var strID = listIDs.eq(i).val();
		  
		  $.ajax({
			   type:"POST",
			   url: "apvline/getPrivateDistributionMember.do",
			   data:{
				   groupID: strID,
				   CheckType: "divtPersonDeployList"
			   },
			   success:function(data){
				   
				   // JAR-CONVERT 05 시작 
				    m_sSelectedRouteType = "dist";
	                m_sSelectedUnitType = "ou";
	                m_sSelectedAllotType = "parallel";
	                m_sSelectedStepRef = "부서배포";
	                
				   var m_Json = {
	               		 "selected": {
	               	          "to": {},
	               	          "cc": {},
	               	          "bcc": {},
	               	          "user": {},
	               	          "group": {},
	               	          "role": {}
	               	       }
					};
	                
				   var sElm = "selected>user";
				   
				   var $$_m_Json = $$(m_Json);
				   
				   $$(data).find("list[Type='user']").each(function (i,ojsoner) {
					   var m_item_JSON = {
		                		 "item": {
		                		  "itemType" : "user",		 
		   				          "AN": "",
		   				          "DN": "",
		   				          "RG": "",
		   				          "RGNM": "",
		   				          "SG": "",
		   				          "SGNM": "",
		   				          "ETNM": "",
		   				          "hasChild": "",
		   				       }
		                 }
					   var $$_m_item_JSON = $$(m_item_JSON).find("item")
					   $$_m_item_JSON.attr("AN",ojsoner.attr("ReceiptID"));
					   $$_m_item_JSON.attr("DN",ojsoner.attr("ReceiptName"));
					   $$_m_item_JSON.attr("hasChild",ojsoner.attr("HasChild"));
	                   
	                   $$_m_Json.find("selected > user ").append($$(m_item_JSON).json());
				   });
	                
	               mType = 1;
	               insertToList($$_m_Json.find("selected > user "));
	               
	               $$(data).find("list[Type='group']").each(function (i,ojsoner) {
					   var m_item_JSON = {
		                		 "item": {
		                		  "itemType" : "group",	
		   				          "AN": "",
		   				          "DN": "",
		   				          "RG": "",
		   				          "RGNM": "",
		   				          "SG": "",
		   				          "SGNM": "",
		   				          "ETNM": "",
		   				          "hasChild": "",
		   				       }
		                 }
					   var $$_m_item_JSON = $$(m_item_JSON).find("item")
					   $$_m_item_JSON.attr("AN",ojsoner.attr("ReceiptID"));
					   $$_m_item_JSON.attr("DN",ojsoner.attr("ReceiptName"));
					   $$_m_item_JSON.attr("hasChild",ojsoner.attr("HasChild"));
	                   
	                   $$_m_Json.find("selected > group ").append($$(m_item_JSON).json());
				   });
	               
	               insertToList($$_m_Json.find("selected > group "));
			   },
			   error:function(response, status, error){
					CFN_ErrorAjax("apvline/getPrivateDistributionMember.do", response, status, error);
				}
		   });
	  } 
	  
	  //적용 완료후 체크박스 해제.
	  $('input[name="privateDistributionCheckbox"]').prop('checked',false)
  }
  
  function applyDistribution(){
	 
	  var strIDs = $('input[name="distributionCheckbox"]:checked');
      
      for(var i = 0; i<strIDs.length;i++){
		  var strGROUP_CODE = document.getElementById("groupCode"+( strIDs.eq(i).val())).value;
	      var strGROUP_NAME = "";
	      if (strGROUP_CODE == "") {
	          //alert("<spring:message code='Cache.msg_apv_172' />");  // 회람 그룹을 선택하십시오.
	          return;
	      } else {
	          strGROUP_NAME = document.getElementById(strGROUP_CODE+"_NM").value;
	          m_sSelectedRouteType = "dist";
	          m_sSelectedUnitType = "ou";
	          m_sSelectedAllotType = "parallel";
	          m_sSelectedStepRef = "부서배포";
	          l_bGroup = false;
	          //mtype 변경
	            var m_Json = {
	               		 "selected": {
	               	          "to": {},
	               	          "cc": {},
	               	          "bcc": {},
	               	          "user": {},
	               	          "group": {
	               	        	"item": {
	  	   				          "AN":  strGROUP_CODE,
	  	   				          "DN": strGROUP_NAME,
	  	   				          "EM":strGROUP_CODE
	  	   				       }
	               	          },
	               	          "role": {}
	               	       }
					};
	                
	
	          mType = 2;
	          insertToList($$(m_Json).find("selected>group"));
	      }
		  //JAR-CONVERT 06 끝
      }
      
      //적용 완료후 체크박스 해제.
	  $('input[name="distributionCheckbox"]').prop('checked',false)
  }
</script>
</head>
<body>
<div class="layer_divpop ui-draggable" id="testpopup_p" style="min-width: 1100px; width:100%;height: 100%; z-index: 51;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
 <!-- 팝업 Contents 시작 --> 
    <!--appBox 시작 -->
    <div id="orgTargetDiv" class="appBox">
	  <!-- 트리 및 리스트는 공통 조직도에서 처리 -->
	  
	  <!-- 버튼 영역 시작 -->
	  <div class="appBtn">
	        <!--배포 관련 버튼 모음(배포추가) 시작 -->
	        <div id="divrecinfoButton">
		        <div id="dvRec">
		           	<input type="button" class="btn_send" id="btRecDept" name="cbBTN" onclick="doButtonAction(this);" value="<spring:message code='Cache.btn_apv_deploy_add' />"/><!--배포추가-->
			    </div>
	        </div>
	        <!--배포 관련 버튼 모음(배포추가) 끝 -->
	  </div>
	  <!-- 버튼 영역 끝 -->
	  
	  <!-- 탭영역 시작 -->
	  <div class="appTab" style="margin-top: -70px;">
		   <!-- 탭메뉴 시작 -->
	        <div class="AXTabsLarge" id="ApvTab">
	          <div class="AXTabsTray"> 
		          <a id="tabrecinfo" class="AXTab on" href="#ax" value="divrecinfo"><spring:message code='Cache.lbl_apv_DDistribute' /></a> <!--배포목록 -->
	          </div>
	        </div>
	        <!-- 탭메뉴 끝 -->
	        <!-- 결재자 몰  -->
	        
	        <!--배포 목록 시작 -->
	        <div class="appInfo02" id="divrecinfo">
	        	<div id="divrecinfolist">
		        	<table id="tblrecinfo" name="tblrecinfo" class="tableStyle t_center hover infoTable"><colgroup>
								<col id="Col1" style="width:100px" />
								<col id="Col2" style="width:*"/>
								<col id="Col3" style="width:50px"/>
							</colgroup><thead>
								<tr>
			                		<td colspan="3"><h3 class="titIcn"><spring:message code='Cache.lbl_apv_DDistribute' /></h3></td><!--참조자-->
			              		</tr>
							</thead>
							<tbody>
								<tr style="display: none;">
									<td></td>
									<td></td>
								</tr>
								<tr style="display: none;">
									<td></td>
									<td></td>
								</tr>
								<!-- <tr>
									<td></td>
									<td></td>
								</tr> -->
							</tbody>
					</table>
				</div>
	        	<div id="ReclistSendRight" class="btnWArea02"><a href="#" class="sendRight" onclick="savePrivateDistribution()">&nbsp;&nbsp;&nbsp;&nbsp;<spring:message code='Cache.lbl_save_privategroup'/></a></div><!--개인수신처로 저장-->
	        </div>	  
	        <!--배포목록 끝-->   
	  </div> 
 	  <!-- 탭영역 끝 --> 
 	  
      <!-- 펼침/접힘 시작 --> 
      <a href="#" id="btnOpen" class="appOpen" onclick="fnShowApvLineMgr('open')" style="display:none;"><spring:message code='Cache.btn_open'/></a> <!--열기 -->
      <a href="#" id="btnClose" class="appClose" onclick="fnShowApvLineMgr('close')" style="display:none;"><spring:message code='Cache.btn_Close'/></a> <!--닫기-->
      <!-- 펼침/접힘  끝 --> 

	  <!--개인결재선 ,개인수신처, 공용 배포목록 시작-->	
	  <div class="appPers" id="divApvLineMgrSub" style="display:none;">
	  	  <!--개인배포 & 공용배포 시작-->
	  	  <div id="divrecinfoLine">
		  	  <table class="tableStyle t_center hover persTable">
		          <colgroup>
			          <col style="width:50%">
			          <col style="width:*">
		          </colgroup>
		          <thead>
		            <tr>
		              <td id="divtPersonDeployList" class="on" onclick="clickDeployTab(this)"><spring:message code='Cache.lbl_apv_distributiongroup'/></td><!--개인배포-->
		              <td id="divtDeployList" class="off" onclick="clickDeployTab(this)"><spring:message code='Cache.lbl_apv_public_distribution'/></td><!--공용배포-->
		            </tr>
		          </thead>
	          </table>		 
			  <table class="tableStyle t_center hover persTable" id="divdetailtPersonDeployList">
		          <colgroup>
		          <col style="width:50px">
		          <col style="width:*">
		          </colgroup>          
		          <tbody></tbody>
              </table>
			  <table class="tableStyle t_center hover persTable" id="divdetailtDeployList">
		          <colgroup>
		          <col style="width:50px">
		          <col style="width:*">
		          </colgroup>          
		          <tbody></tbody>
              </table>
            <div class="tCenter mt15" id="applyPrivateDistributionBtn" >
        		<input type="button" class="smButton" onclick="applyPrivateDistribution()" value="<spring:message code='Cache.lbl_apply' />"/><!--적용-->
       		</div>
       		<div class="tCenter mt15" id="applyDistributionBtn" style="display:none">
        		<input type="button" class="smButton" onclick="applyDistribution()" value="<spring:message code='Cache.lbl_apply'/>" /><!--적용-->
       		</div>    
	  	  </div>
	  	  <!--개인배포 & 공용배포 끝-->
	  </div>
	  <!--결재선,개인수신처,배포목록 끝 -->

		 
      </div>
	  <!--appBox 끝 -->
      <!-- 하단버튼 시작 -->
      <div class="popBtn"> 
	      <input type="button" id="btOK" name="cbBTN" onclick="doButtonAction(this);" class="ooBtn" value="<spring:message code='Cache.btn_Confirm'/>"/><!--확인-->
	      <input type="button" id="btExit" name="cbBTN" onclick="doButtonAction(this);" class="gryBtn mr30" value="<spring:message code='Cache.btn_apv_close'/>"/><!--닫기-->
      </div>
      <!-- 하단버튼 끝 --> 
	<!-- </div> -->
	<!--팝업 컨테이너 끝-->
</div>


<div style="height: 0px; overflow: hidden;">
        <input  ID="TextBox1" />
        <input ID="hidType" value="D9"/>
        <input  ID="hidInGroup"/>
        <input  ID="hidInAllCompany"/>
        <input  ID="hidSubSystem" />
        <input  ID="hidSearchType" value="DC"/>
        <input  ID="hidSearchText" />
        <input  ID="hidSelectedItemID" />
        <input  ID="hidCallBackMethod" />
        <input  ID="hidOpenName"/>
</div>
</body>
</html>