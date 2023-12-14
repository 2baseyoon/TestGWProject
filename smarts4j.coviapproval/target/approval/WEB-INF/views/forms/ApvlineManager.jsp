<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@page import="egovframework.coviframework.util.RedisDataUtil"%>
<!DOCTYPE html>
<%
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
	
	pageContext.setAttribute("isUseAccount", RedisDataUtil.getBaseConfig("isUseAccount"));
	
	String lstr_userID = SessionHelper.getSession("USERID");
	String lstr_langCode = SessionHelper.getSession("lang");
	String lstr_entCode = SessionHelper.getSession("DN_Code");

	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<html>
<head>
	<title></title>
	
	<!--CSS Include Start -->
	<!-- 공통 CSS  -->
	<!-- 공통 CSS  -->
	<jsp:include page="/WEB-INF/views/cmmn/PopupInclude.jsp"></jsp:include>
	
	<style>
		.appTree { height: 100%; }
	</style>
	
	<!--JavaScript Include Start -->
	<!-- 공통 JavaScript  -->	
	<script type="text/javascript" src="/approval/resources/script/user/common/ApprovalUserCommon.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Jsoner/Jsoner.0.8.2.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.orgchart.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.orgchart.govdist.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/approval/resources/script/forms/ApvlineManager.js<%=resourceVersion%>"></script>

<script type="text/javascript">
	//# sourceURL=ApvlineManager.jsp
	var myDeptTree = new coviTree();
	var openID =  CFN_GetQueryString("openID")=="undefined"? "":CFN_GetQueryString("openID");
	var admintype =  CFN_GetQueryString("admintype")=="undefined"? "":CFN_GetQueryString("admintype");
  	var selTab = "tSearch";
  	var userID = "<%=lstr_userID%>";
  	var langCode = "<%=lstr_langCode%>";
  	var Sendtype = "In";
 
  	//결재선선택
    var m_oParent, m_oUserList;
    var m_selectedCCRow = null;
    var m_selectedCCRowId = null;

    var ApvListDisplayOrder = "DESC"; // 결재선 목록 정렬 순서 default : DESC(역순), ASC:정순
    var ApvKindUsage = Common.getBaseConfig("ApvKindUsage"); //201111 결재종류사용여부 전결;결재안함;후결;후열
    var g_DisplayJobType = Common.getBaseConfig("ApprovalLine_DisplayJobType") || "title"; // 직책, 직급, 직위 중 결재선에 표시될 타입 설정 (직책 : title, 직급 : level, 직위 : position)
    var useAffiliateSearch = Common.getBaseConfig("useAffiliateSearch");
    
    $(document).ready(function(){
		setOrgChart();
		
		//getPrivateDomainList(); // 중복호출 제거
		getPrivateDistribution();
		clickTab($("#aPrivateDomain"));
		clickDeployTab($("#divtPersonDeployList"));
		
		
		//조직도,대외수신처  선택 radio 버튼
		$('input[type=radio][name="groupTypeRadio"]').change(function(){
		   var rdCheck = $(this).val();	   
		   if(rdCheck=="dept"){
			   clickApvTab($("#tabapvandcc"));
		   }else{//대외수신처
			   clickApvTab($("#tabdistribution"));
		   }  
		});
	});
    
    $(window).load(function(){
		if(m_sApvMode != "CFADMIN") {
			if(getInfo('ExtInfo.UseHWPEditYN') == "Y" || opener.getInfo('ExtInfo.UseMultiEditYN') == "Y"){
			   $('#tabrecinfo').hide();
	   		}
			fnShowApvLineMgr("close");
		}
		clickApvTab($("#tabapvandcc"));
		setPrivateApvline(m_sApvMode);
		
		//조직도,대외수신처 버튼 활성 여부
		 /* if (getInfo("SchemaContext.scDistribution.isUse")=="Y"){
			 $("#dvGroupType").show();
			 $("#orgTargetDiv").css("height","calc(100% - 100px)");
		 } */

		// 양식내 결재선 기능중 내 결재선 버튼클릭해서 열었을 경우 load 완료 후에 내 결재선 내역 보여주기
		if (CFN_GetQueryString('callby') != 'undefined' && CFN_GetQueryString('callby') == 'myappline') {
			if ($('#btnOpen').is(':visible')) fnShowApvLineMgr('open');
		}
   });
   
   function setPrivateApvline(pMode){
	   if(m_sApvMode != "DRAFT" && m_sApvMode != "TEMPSAVE" && m_sApvMode != "REDRAFT" && m_sApvMode != "SUBREDRAFT"){
			$("#btnOpen,#a_saveDomaindata,#a_saveDistribution").hide();
		}
   }
   
   function setOrgChart(){
		var config ={
				targetID: 'orgTargetDiv',
				drawOpt:'LM___',
				allCompany:useAffiliateSearch, // 타 계열사 검색 허용 여부
				dragEndFunc:"void_dragEnd"
		};
		
		coviOrg.render(config);
		coviOrg.contentDoubleClick = contentDoubleClick;
   }
   
   //대외수신처 조직도 추가
   function setOrgChartDist(){
		var config ={
			 targetID: 'orgTargetDiv',
			 drawOpt:'LM___',
			 type: "G9",
			 treeKind: "gov"				
		};
		
		coviOrgDist.render(config);
		coviOrgDist.contentDoubleClick = contentDoubleClick;
  }
	
	//Double Click 시 결재선에 추가
	function contentDoubleClick(obj){
		$(obj).find("input[type=checkbox]").prop('checked', true);
		var selectedTab = $("#ApvTab .AXTab.on").attr("value");
		if(selectedTab === "apvandcc") {
			$("#btnSelect").click();
		} else {
			$("#btRecDept").click();
		}
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
	
	function getPrivateDomainList(){
		$.ajax({
			type:"POST",
			url: "apvline/getPrivateDomainList.do",
			data:{
				"userID" : userID
			},
			success: function(data){
				if(data.result=="ok"){
					var htmlList = "";
					$.each(data.list, function(index, list){
						var privateDomainID = list.PrivateDomainDataID;
						var defaultYN = list.DefaultYN;
						var description = list.Description;
						var privateContext = list.PrivateContext;
						var displayName = (defaultYN=="Y") ? ("["+"<spring:message code='Cache.lbll_Default' />"+"]"+list.DisplayName) : (list.DisplayName);		//기본
						
						var priJSON = privateContext;
						var priDivisionType = $$(priJSON).find('division').concat().eq(0).attr('divisiontype');
						
						var priDivisionFlag = false;
						
						if (typeof(getInfo("Request.mode")) != "undefined") {
							if(getInfo("Request.mode").substring(0,2) == "RE" && priDivisionType=="receive"){
								priDivisionFlag=true;
							}else if(getInfo("Request.mode").substring(0,2) != "RE" && priDivisionType=="send"){
								priDivisionFlag=true;
							}
						}
						 
		                if (priDivisionFlag) {
		                	htmlList += "<tr id='privateDomainData"+privateDomainID+"'>";
		                	htmlList += "<td style='display:none;'><textarea id='privateDomainContext" + privateDomainID + "' name='privateDomainContext" + privateDomainID + "' style='display:none;'>" + JSON.stringify(privateContext) + "</textarea></td>";
		                	htmlList += "<td><input type='checkbox' name='privateDomainCheckbox' value = '"+privateDomainID+"'/></td>";
		                	htmlList += "<td id='privateDoaminDataSubject"+privateDomainID+"'class='subject'>" + "<span id='privateDomainSubjectSpan"+privateDomainID+"' value='"+privateDomainID+"' onclick='clickPrivateDomain(this)' >"+ (priDivisionType == "send" ? "["+"<spring:message code='Cache.lbl_send' />"+"]" : "["+"<spring:message code='Cache.lbl_apv_receive' />"+"]") + displayName+"</span>";			//발신 | 수신
		                	htmlList += "<a href='#' id='privateDomainMoreEnd"+privateDomainID+"' onclick='clickflag($(\"#privateDoaminMenu"+privateDomainID+"\"));' class='moreEnd' style='display:none'><spring:message code='Cache.lbl_MoreView'/></a>"; /*더보기*/
		                 	htmlList += "<ul id='privateDoaminMenu"+privateDomainID+"'class='menu_more' style='display:none'>";
		                 	htmlList += "<li><span>icn</span></li>";
		                 	htmlList += "<li class='first' onclick='delPrivateDomain("+privateDomainID+"); $(\"#privateDoaminMenu"+privateDomainID+"\").hide();'><spring:message code='Cache.btn_delete'/></li>"; /*삭제 */
		                 	htmlList += "<li onclick='overwritePrivateDomainData("+privateDomainID+"); $(\"#privateDoaminMenu"+privateDomainID+"\").hide();'><spring:message code='Cache.btn_apv_save'/></li>"; /*저장(덮어쓰기) */
		                 	if(defaultYN !="Y"){
		                 		htmlList += "<li onclick='SetDefaultApvList("+privateDomainID+",\"Y\"); $(\"#privateDoaminMenu"+privateDomainID+"\").hide();'><spring:message code='Cache.lbl_set_default'/></li>"; /*기본으로 설정*/
		                 	}else{
			                 	htmlList += "<li onclick='SetDefaultApvList("+privateDomainID+",\"N\"); $(\"#privateDoaminMenu"+privateDomainID+"\").hide();'><spring:message code='Cache.lbl_set_none_default'/></li>";/*기본 해제*/
		                 	}
		                	htmlList += "</ul>";
		                	htmlList += "</td>";
		                	htmlList += "</tr>";
		                	htmlList += "<tr id='divApvListGroupDetail"+privateDomainID+"' style='display:none'></tr>";
		                }
					});
					
					$("#divdetailtApvLine tbody tr").remove()
					$("#divdetailtApvLine").append(htmlList);
					//document.getElementById("ulApvListGroup").innerHTML = htmlList;

					 $('input[type="checkbox"][name="privateDomainCheckbox"]').click(function(){
					        //클릭 이벤트 발생한 요소가 체크 상태인 경우
					        if ($(this).prop('checked')) {
					            //체크박스 그룹의 요소 전체를 체크 해제후 클릭한 요소 체크 상태지정
					            $('input[type="checkbox"][name="privateDomainCheckbox"]').prop('checked', false);
					            $(this).prop('checked', true);
					        }
					 });
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("apvline/getPrivateDomainList.do", response, status, error);
			}
		});
	}

	function clickflag(object){
		if(object.css("display") =="none"){
			object.show();
		}else{
			object.hide();
		}
	}
	
	function clickPrivateDomain(obj){
		var selectID =$("#"+obj.id).attr("value");

		if($("#privateDomainData"+selectID).attr("class")=="persOn"){
			$("tr[id^='privateDomainData']").attr("class","");
			$("td[id^='privateDoaminDataSubject']").attr("class","subject");
			$("ul[id^='privateDoaminMenu']").css({ "display": "none" });
			$("a[id^='privateDomainMoreEnd']").css({ "display": "none" });
			
			$("#divApvListGroupDetail"+selectID).css({ "display": "none" });
			return;
		}
		
		
		$("tr[id^='privateDomainData']").attr("class","");
		$("#privateDomainData"+selectID).attr("class","persOn");
		
		$("td[id^='privateDoaminDataSubject']").attr("class","subject");
		$("#privateDoaminDataSubject"+selectID).attr("class","appSubject");
		
		$("ul[id^='privateDoaminMenu']").css({ "display": "none" });
		//$("#privateDoaminMenu"+selectID).css({ "display": "" });

		$("a[id^='privateDomainMoreEnd']").css({ "display": "none" });
		$("#privateDomainMoreEnd"+selectID).css({ "display": "" });
		
		$("tr[id^='divApvListGroupDetail']").css({ "display": "none" });
		$("#divApvListGroupDetail"+selectID).css({ "display": "" });
		
		getApvListGroupDetail(selectID);
		
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
					//document.getElementById("ulApvListGroup").innerHTML = htmlList;

					/*  $('input[type="checkbox"][name="distributionCheckbox"]').click(function(){
					        if ($(this).prop('checked')) {
					            $('input[type="checkbox"][name="distributionCheckbox"]').prop('checked', false);
					            $(this).prop('checked', true);
					        }
					 }); */

				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("apvline/getDistributionList.do", response, status, error);
			}
		});
	}
	
    // 개인결재선그룹 삭제하기
    function delPrivateDomain(privateDomainID) {
        var results;
        Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (result) {
            if (result) {
            	$.ajax({
            		type:"POST",
            		url:"apvline/deletePrivateDomain.do",
            		data:{
            			"privateDomainID":privateDomainID
            		},
            		success:function(data){
            			if(data.result=="ok"){
            				getPrivateDomainList();
            			}
            		},
            		error:function(response, status, error){
        				CFN_ErrorAjax("apvline/deletePrivateDomain.do", response, status, error);
        			}
            	});
            }
        });
     }
    
  	//개인결재선 구성원 가져오기
    function getApvListGroupDetail(privateDomainID) {
        var objDetail = document.getElementById("divApvListGroupDetail" + privateDomainID);

        if (document.getElementById("divApvListGroupDetail" + privateDomainID).innerHTML == "") {    // 수신인 목록이 없으면 생성
            getApvListGroupDetailSub(privateDomainID);
        }
    }
  	
    // 개인결재선 구성원 가져오기 Sub
    function getApvListGroupDetailSub(privateDomainID) {
        var rtnValue = "";
        var html_list = "<td colspan='2' class='bgG'>";
        html_list += "<table class='ApvTable'><colgroup><col style='width:10%'><col style='width:45%'><col style='width:45%'></colgroup><tbody>";
        
        var oJson =  $.parseJSON( document.getElementById("privateDomainContext"+privateDomainID).value );
        var idx=1;
        
        // 결재선 지정 순서대로 출력하기 위해 수정함.
        //$$(oJson).find("steps>division>step>ou>person, steps>division>step[unittype='ou']>ou, steps>division>step>ou>role").each(function (i, $$) {
        $$(oJson).find("steps>division>step>ou").concat().each(function (i, $$) {
        	var sConvertKind ="";
        	
       		if($$.find("role").length > 0){
       			$$ = $$.find("role");
       			html_list += displayGroupDetail((i + 1), $$.attr('code'), "division"+i, CFN_GetDicInfo($$.attr('name'),langCode) +  "," + CFN_GetDicInfo($$.attr('ouname'),langCode)+",", privateDomainID, null);
       		} else if($$.find("person").length > 0){
       			$$.find("person").concat().each(function(j,$$$){
       				sConvertKind = convertKindToSignTypeByRTnUT($$$.find('taskinfo').attr('kind'),$$$.parent().parent().concat().find('[unittype]').attr('unittype'), $$$.parent().parent().concat().find('[routetype]').attr('routetype'), $$$.parent().parent().concat().find('[unittype]').attr('unittype'), "", $$$.parent().parent().concat().find('[allottype]').attr('allottype')) ;
                    html_list += displayGroupDetail((i + 1), $$$.attr("code"), "division"+i, CFN_GetDicInfo($$$.attr("name"),langCode) + "," + splitName($$$.attr("position")) + "," + sConvertKind, privateDomainID, CFN_GetDicInfo($$$.attr("ouname")));
       			});
       		} else if ($$.parent().attr("unittype") == "ou") {
                if (m_sApvMode != "SUBREDRAFT") {
                	sConvertKind = convertKindToSignTypeByRTnUT($$.find('taskinfo').attr('kind'),$$.parent().concat().find('[unittype]').attr('unittype'), $$.parent().concat().find('[routetype]').attr('routetype'), $$.parent().concat().find('[unittype]').attr('unittype'), "", $$.parent().concat().find('[allottype]').attr('allottype')) ;
                    html_list += displayGroupDetail((i + 1), $$.attr("code"), "division"+i, CFN_GetDicInfo($$.attr("name"),langCode) + ",," + sConvertKind, privateDomainID, CFN_GetDicInfo($$.attr("ouname")));
                }
            }
        });

        // 참조 표시
        if (getInfo("SchemaContext.scBeforCcinfo.isUse") == "Y") {
        	var cclength = $$(oJson).find('ccinfo[beforecc!="y"]>ou').concat().length;
        	$$(oJson).find('ccinfo[beforecc!="y"]>ou').each(function (i, $$) { // 사후참조
        		if($$.has("person").length > 0){
        			html_list += displayGroupDetail((i + 1), $$.find("person").attr("code"), "ccinfo"+i, CFN_GetDicInfo($$.find("person").attr("name"),langCode) + "," + splitName($$.find("person").attr("position")) + "," + "<spring:message code='Cache.btn_apv_ccinfo_after' />" + "<spring:message code='Cache.lbl_apv_cc' />", privateDomainID, CFN_GetDicInfo($$.find("person").attr("ouname"),langCode),cclength);	
            	}else{
            		html_list += displayGroupDetail((i + 1), $$.attr("code"), "ccinfo"+i,CFN_GetDicInfo($$.attr("name"),langCode) + ",," + "<spring:message code='Cache.btn_apv_ccinfo_after' />" + "<spring:message code='Cache.lbl_apv_cc' />", privateDomainID, CFN_GetDicInfo($$.attr("name"),langCode),cclength);
            	}
        	});
        	cclength = $$(oJson).find('ccinfo[beforecc="y"]>ou').concat().length;
        	$$(oJson).find('ccinfo[beforecc="y"]>ou').each(function (i, $$) { // 사전참조
        		if($$.has("person").length > 0){
        			html_list += displayGroupDetail((i + 1), $$.find("person").attr("code"), "ccinfo"+i, CFN_GetDicInfo($$.find("person").attr("name"),langCode) + "," + splitName($$.find("person").attr("position")) + "," + "<spring:message code='Cache.btn_apv_ccinfo_before' />" + "<spring:message code='Cache.lbl_apv_cc' />", privateDomainID, CFN_GetDicInfo($$.find("person").attr("ouname"),langCode),cclength);	
            	}else{
            		html_list += displayGroupDetail((i + 1), $$.attr("code"), "ccinfo"+i,CFN_GetDicInfo($$.attr("name"),langCode) + ",," + "<spring:message code='Cache.btn_apv_ccinfo_before' />" + "<spring:message code='Cache.lbl_apv_cc' />", privateDomainID, CFN_GetDicInfo($$.attr("name"),langCode),cclength);
            	}
        	});	
        }else{
        	var cclength = $$(oJson).find('ccinfo>ou').concat().length;
        	$$(oJson).find('ccinfo>ou').each(function (i, $$) { // 참조
        		if($$.has("person").length > 0){
        			html_list += displayGroupDetail((i + 1), $$.find("person").attr("code"), "ccinfo"+i, CFN_GetDicInfo($$.find("person").attr("name"),langCode) + "," + splitName($$.find("person").attr("position")) + "," + "<spring:message code='Cache.lbl_apv_cc' />", privateDomainID, CFN_GetDicInfo($$.find("person").attr("ouname"),langCode),cclength);	
            	}else{
            		html_list += displayGroupDetail((i + 1), $$.attr("code"), "ccinfo"+i,CFN_GetDicInfo($$.attr("name"),langCode) + ",," + "<spring:message code='Cache.lbl_apv_cc' />", privateDomainID, CFN_GetDicInfo($$.attr("name"),langCode),cclength);
            	}
        	});
        }
        
        //jsoner-convert 01 끝
        html_list += "</tbody></table>";
        html_list += "</td>";
        document.getElementById("divApvListGroupDetail" + privateDomainID).innerHTML = html_list;
    }
        
    function displayGroupDetail(strNum, strId, strType, strName, strPDDID, strOuName, cclength) {
        var rtnValue = "";
        var nameSplit = strName.split(",");
        
        
        if(strType.indexOf('ccinfo')>=0){
        	rtnValue += "";
        	if(strNum == 1){
        		rtnValue += "<tr><td></td><td>"+nameSplit[2]+"</td>";
        		rtnValue += "<td style='line-height:14px;text-align:left;'>"+nameSplit[0]+' '+nameSplit[1];//이름 직급
        	}else{
        		rtnValue += "<br />"+nameSplit[0]+' '+nameSplit[1];//이름 직급
        	}
	        //rtnValue += "<li><a href=\"javascript:delApvListGroupDetail('" + strPDDID + "','" + strId + "','" + strType + "');\"><img src='/approval/resources/images/Approval/app_conf_x.gif' alt='" + "<spring:message code='Cache.btn_apv_delete' />" + "' title='" + "<spring:message code='Cache.btn_apv_delete' />" + "' class='img_align2' /></a></li>"
	        if(strNum == cclength){
	        	rtnValue += "</td></tr>";
	        }
        }else{
        	rtnValue += "<tr>";
	        rtnValue += "<td>"+strNum+"</td>";
	        rtnValue += "<td>"+nameSplit[2]+"</td>"; //결재 유형
	        rtnValue += "<td style='text-align:left;'>"+nameSplit[0]+' '+nameSplit[1] +"</td>"; //이름 직급
	        //rtnValue += "<li><a href=\"javascript:delApvListGroupDetail('" + strPDDID + "','" + strId + "','" + strType + "');\"><img src='/approval/resources/images/Approval/app_conf_x.gif' alt='" + "<spring:message code='Cache.btn_apv_delete' />" + "' title='" + "<spring:message code='Cache.btn_apv_delete' />" + "' class='img_align2' /></a></li>"
	        rtnValue += "</tr>";
        }

        return rtnValue;
    }
    
    
    //개인결재선 멤버 삭제
    function delApvListGroupDetail(strPDDID, strId, strType) {
        Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (result) {
            if (!result) return; // 삭제하시겠습니까??

            var col;
            var delNode;
            var oJson = $.parseJSON( document.getElementById(strPDDID).value );
            var elementToRemove = null;
            
            $$(oJson).find('steps>division>step>ou>person , division>step>ou>role').each(function (i, $$) {
                if (String("division"+i) == strType) elementToRemove = $$;
            });
            
            if (elementToRemove != null) {
                switch (elementToRemove.nodename()) {
                    case "person":
                    case "role":
                        if( elementToRemove.parent().parent().concat().find('[allottype]').attr('allottype') =="parallel" && $$(elementToRemove).parent().parent().find("ou > person").length>1) {
                        	elementToRemove.parent().remove() //ou 삭제
                        }else{
                        	elementToRemove.parent().parent().remove(); //step 배열의 요소 삭제
                        }
                        break;
                    case "ou":
                    	elementToRemove.parent().remove() //ou 삭제
                        break;
                }
            }
            
            elementToRemove = null;
            
            $$(oJson).find('ccinfo>ou>person').each(function (i, $$) {
                if (String("ccinfo"+i) == strType) elementToRemove = $$;
            });
            
            if(elementToRemove != null){
            	elementToRemove.parent().parent().remove(); // ccinfo 의 요소 삭제
            }

            $.ajax({
            	type:"POST",
            	url:"apvline/updatePrivateDomain.do",
            	data:{
            		"abstract": makeAbstract(oJson),
            		"privateDomainDataID": strPDDID,
            		"privateContext" : JSON.stringify(oJson)
            	},
            	success:function(data){
            		if(data.result=="ok"){
            			 document.getElementById(strPDDID).value = JSON.stringify(oJson);
                         getApvListGroupDetailSub(strPDDID);
            		}
            	},
            	error:function(response, status, error){
    				CFN_ErrorAjax("apvline/updatePrivateDomain.do", response, status, error);
    			}
            });
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
        		var htmlList = "<td colspan='2' class='bgG'>";
        		htmlList += "<table class='ApvTable'><colgroup><col style='width:15%'><col style='width:85%'></colgroup><tbody>";
        		$(data.list).each(function(i,obj){
        			htmlList += "<tr>";
        			htmlList += "<td>"+ (i+1) +"</td>";
        			htmlList += "<td style='text-align:left;'>"+CFN_GetDicInfo(obj.Name,langCode)+"</td>";
        			htmlList += "</tr>";
        		});
        		htmlList += "</tbody></table></td>";
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
    
   /*  function applyApvListGroup() {
        var strPDDID = document.getElementById("selPDD_ID").value;
        var strGROUP_NAME = "";
        if (strPDDID == "") {
            //alert("<spring:message code='Cache.msg_apv_172' />");  // 회람 그룹을 선택하십시오.
            return;
        } else {
             document.getElementById(strPDDID).value = document.getElementById(strPDDID).value.replace(/&/g, '&amp;');
             var sXML = document.getElementById(strPDDID).value;
             var oXML = $.parseXML(sXML);
             var oSteps = $(oXML).find("steps");
             switch (m_sApvMode) {
                 case "REDRAFT":
                     m_oApvList = $.parseXML(m_oFormMenu.document.getElementById("APVLIST").value);
                     var m_oCurrentOUNode = $(m_oApvList).find("division[divisiontype='receive']:has(taskinfo[status='pending'])");

                     //추가된 사람 있음 지우기 - 기안자 빼고
                     var elementToRemove = null;
                     m_oCurrentOUNode.find("step > ou > person:has(taskinfo[kind!='charge'])").each(function (i, elm) {
                         elementToRemove = elm;
                         if (elementToRemove != null) elementToRemove.parentNode.parentNode.parentNode.removeChild(elementToRemove.parentNode.parentNode);
                     });

                     var oCheckSteps = chkAbsent(oSteps);
                     if (oCheckSteps) {
                         $(oSteps).find("division > step[unittype='person']").each(function () {
                             m_oCurrentOUNode.append($(this));
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
                     Common.Error(strMsg_047);
                     break;
                 default:
                     var oCheckSteps = chkAbsent(oSteps);
                     var oApvList = $.parseXML("<steps />");

                     if (oCheckSteps) {
                         var oStep = oApvList.createElement("step");
                         var oOU = oApvList.createElement("ou");
                         var oPerson = oApvList.createElement("person");
                         var oTaskinfo = oApvList.createElement("taskinfo");
                         var oDivStep = $(oSteps).find("division > step")[0];
                         var oDivTaskinfo = $(oSteps).find("division > taskinfo")[0];
                         var oDiv = $(oSteps).find("division")[0];
                         oDiv.insertBefore(oStep, oDivStep);
                         $(oStep).append(oOU);
                         $(oOU).append(oPerson);
                         $(oPerson).append(oTaskinfo);
                         $(oSteps).attr("initiatoroucode", getInfo("dpid_apv"));
                         $(oStep).attr("unittype", "person");
                         $(oStep).attr("routetype", "approve");
                         $(oStep).attr("name", strlable_writer);
                         $(oOU).attr("code", getInfo("dpid_apv"));
                         $(oOU).attr("name", getInfo("dpdn_apv"));
                         $(oPerson).attr("code", getInfo("usid"));
                         $(oPerson).attr("name", getInfo("usdn"));
                         $(oPerson).attr("position", getInfo("uspc") + ";" + getInfo("uspn"));
                         $(oPerson).attr("title", getInfo("ustc") + ";" + getInfo("ustn"));
                         $(oPerson).attr("level", getInfo("uslc") + ";" + getInfo("usln"));
                         $(oPerson).attr("oucode", getInfo("dpid"));
                         $(oPerson).attr("ouname", getInfo("dpdn"));
                         $(oPerson).attr("sipaddress", getInfo("ussip"));
                         $(oTaskinfo).attr("status", "inactive");
                         $(oTaskinfo).attr("result", "inactive");
                         $(oTaskinfo).attr("kind", "charge");
                         $(oTaskinfo).attr("datereceived", getInfo("svdt"));
                         $(oTaskinfo).attr("customattribute1", getInfo("usit"));
                         $(oDivTaskinfo).attr("status", "inactive");
                         $(oDivTaskinfo).attr("result", "inactive");
                         $(oDivTaskinfo).attr("kind", "normal");
                         $(oDivTaskinfo).attr("datereceived", getInfo("svdt"));
                         $(oDiv).attr("name", strlable_circulation_sent); //"발신"
                         $(oDiv).attr("oucode", getInfo("dpid_apv"));
                         $(oDiv).attr("ouname", getInfo("dpdn_apv"));
                         $(oDiv).attr("divisiontype", "send");

                         //m_oApvList.loadXML((new XMLSerializer()).serializeToString(oSteps[0]));
                         m_oApvList = $.parseXML(CFN_XmlToString(oSteps[0]));
                         document.getElementById("Apvlist").innerHTML = "";
                         refreshList();
                         refreshCC(true);
                     }
                     break;
             }
        }
    } */
    
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
	                $$(m_oCurrentOUNode).find("step > ou > person:has(taskinfo[kind!='charge'])").parent().parent().remove(); //step 배열의 요소 삭제
	                
            		var arrSteps = [];
	                var oCheckSteps = chkAbsent(oSteps);
	                if (oCheckSteps) {
	                    $$(oSteps).find("division > step").concat().find("[unittype='person']").each(function (i,$$) {
	                    	if(m_oCurrentOUNode.find("step").json().length != undefined) { //step이 array일 경우
	                    		m_oCurrentOUNode.find("step").json().push($$.json());
	                    	} else { //step이 json object일 경우
	                    		arrSteps.push($$.json());
	                    	}
	                    });

	                    if(arrSteps.length > 0) {
                			arrSteps.unshift(m_oCurrentOUNode.find("step").json()); //기안자 추가
                			m_oCurrentOUNode.json().step = arrSteps;
	                    }
	                    
	                    $$(m_oApvList).find("ccinfo[belongto='receiver']").remove();
	                    if($$(m_oApvList).find("ccinfo").length > 0){
	                    	$$_oSteps.find("ccinfo").concat().each(function(idx,item){
	                    		$$(m_oApvList).find("ccinfo").json().push($$(item).json());	
	                    	});
	                    }else{
	                    	m_oApvList.steps.ccinfo = $$_oSteps.find("ccinfo").json();
	                    }
	                    
						$$_m_oApvList = $$(m_oApvList);
						
	                    document.getElementById("Apvlist").innerHTML = "";
	                    refreshList();
	                    refreshCC(true);
	                }
	                break;
	          	case "SUBREDRAFT":
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
                    var m_oReceiveDivision = $$_m_oApvList.find("division[divisiontype='receive']");
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
                            if ($$_oSteps.find("division[divisiontype='receive']").length >= parseInt(gRequestDivisionLimit) && gRequestDivisionLimit != "0") {
                            	Common.Warning(Common.getDic("msg_apvDivisionLimit").replace("0", gRequestDivisionLimit));
                                return;
                            } else {
                                $$(oReceiveDivision).concat().each(function (i, item) {
                                    if ($$(item).find("step").length == 0) {
                                        return;
                                    }
                                    if ($$_oSteps.find("division[divisiontype='receive']").length >= parseInt(gRequestDivisionLimit) && gRequestDivisionLimit != "0") {
                                        return false;
                                    }
                                    else {
                                    	$$_oSteps.append("division", $$(item).json());
                                    }
                                });
                            }
                        }
                        
                        // 이미 있는 수신자/수신부서를 유지시키는 기능인데, 개인결재선 저장시 수신자/수신부서도 저장하므로 중복가능성이 있어 제거
                        /*
                      	//기본 수신자 추가
                   	  	if((getInfo("SchemaContext.scPRec.isUse") == "Y" || getInfo("SchemaContext.scPRecEnt.isUse") == "Y" || getInfo("SchemaContext.scPRecReg.isUse") == "Y"
                   	  			|| getInfo("SchemaContext.scDRec.isUse") == "Y" || getInfo("SchemaContext.scDRecEnt.isUse") == "Y" || getInfo("SchemaContext.scDRecReg.isUse") == "Y") 
                   	  			&& m_oReceiveDivision.length > 0) {
                            if ($$_m_oApvList.find("division[divisiontype='receive']").length >= parseInt(gRequestDivisionLimit) && gRequestDivisionLimit != "0") {
                            	Common.Warning(Common.getDic("msg_apvDivisionLimit").replace("0", gRequestDivisionLimit));
                                return;
                            } else {
                                $$(m_oReceiveDivision).concat().each(function (i, item) {
                                    if ($$(item).find("step").length == 0) {
                                        return;
                                    }
                                    if ($$_m_oApvList.find("division[divisiontype='receive']").length >= parseInt(gRequestDivisionLimit) && gRequestDivisionLimit != "0") {
                                        return false;
                                    }
                                    else if ($$_m_oApvList.find("division[divisiontype='receive'][oucode=" + $$(item).attr("oucode") + "]").length > 0) {
                                    	$$_oSteps.append("division", $$(item).json());
                                    }
                                });
                            }
                   		}
                        */
                        
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
    		url: "apvline/getPrivateDistribution.do",
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
				//document.getElementById("ulApvListGroup").innerHTML = htmlList;

				/*  $('input[type="checkbox"][name="privateDistributionCheckbox"]').click(function(){
				        if ($(this).prop('checked')) {
				            $('input[type="checkbox"][name="privateDistributionCheckbox"]').prop('checked', false);
				            $(this).prop('checked', true);
				        }
				 }); */
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
			   groupID: strPDDID
		   },
		   success:function(data){
			   
			   //jsoner-conver 02 시작
			   var rtnValue = "";
       		   var htmlList = "<td colspan='2' class='bgG'>";
       		   htmlList += "<table class='ApvTable'><colgroup><col style='width:15%'><col style='width:85%'></colgroup><tbody>";
       		   var idx =0;
			   
       		   $$(data).find('list[Type="group"]').each(function(i,$$){
       			   htmlList += displayPrivateDistributionDetail( (i+1) , strPDDID, $$.attr('GroupMemberID'), CFN_GetDicInfo($$.attr('ReceiptName'),langCode) );
       			   idx=i+1;
			   });

			   $$(data).find('list[Type="user"]').each(function(i,$$){
				   htmlList += displayPrivateDistributionDetail( (idx+i+1) , strPDDID,$$.attr('GroupMemberID'), CFN_GetDicInfo($$.attr('ReceiptName'),langCode));	 
			   });
			   
			   htmlList += "</tbody></table></td>";
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

       rtnValue += "<tr>";
       rtnValue += "<td>"+strNum+"</td>";
       rtnValue += "<td style='text-align:left;'>"+strName+"</td>";
       rtnValue += "</tr>";
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
   
  //*결재선 생성 Head
  function fn_tblCreateHead(oTable, viewtype) {
      
      var oColGroup = document.createElement("COLGROUP");
      var newCol_dp_apv_checkbox = document.createElement("col"); //checkbox
      var newCol_dp_apv_no = document.createElement("col"); //number
      var newCol_dp_apv_username= document.createElement("col");
      var newCol_dp_apv_state= document.createElement("col"); //결재 status
      var newCol_dp_apv_kind = document.createElement("col"); //결재 종류
      var newCol_dp_apv_approvdate = document.createElement("col"); //결재일자 (create일 경우 표시 안됨.)
      var newCol_dp_apv_delete_button = document.createElement("col"); //삭제 버튼
      
      var oTHead = document.createElement("THEAD");
      var newTR = document.createElement("tr");
      var newTD = document.createElement("td");
      
      var strTHeadTrTdButtons = "";
      strTHeadTrTdButtons += "<h3 class='titIcn'><spring:message code='Cache.lbl_ApprovalUser' /></h3>"; /*결재자*/
      strTHeadTrTdButtons += "<div class='fRight'>";
      strTHeadTrTdButtons += "<input type='button' class='smButton' id='btAssistGroup' name='cbBTN' onclick='doButtonAction(this)' style='display: none;' value='<spring:message code='Cache.btn_apv_AssistGroup'/>' />";/*합의그룹구분*/
      strTHeadTrTdButtons += " <input type='button' class='smButton' id='btAssistGroupDelete' name='cbBTN' onclick='doButtonAction(this)' style='display: none;' value='<spring:message code='Cache.btn_apv_AssistGroupDelete'/>' />";/*합의그룹전체해제*/
      strTHeadTrTdButtons += " <input type='button' class='smButton' id='btExtType' name='cbBTN' onclick='doButtonAction(this)' style='display: none;' value='<spring:message code='Cache.btn_apv_ExtType'/>' />";/*특이기능*/
      strTHeadTrTdButtons += " <input type='button' class='smButton' id='btDelete' name='cbBTN' onclick='doButtonAction(this)' style='display: none;' value='<spring:message code='Cache.btn_apv_person_audit'/>' />";/*개인감사*/
      strTHeadTrTdButtons += " <input type='button' class='smButton' id='btDAudit1' name='cbBTN' onclick='doButtonAction(this)' style='display: none;' value='<spring:message code='Cache.btn_apv_dept_audit1'/>' />";/*부서준법*/
      strTHeadTrTdButtons += " <input type='button' class='smButton' id='btPAudit1' name='cbBTN' onclick='doButtonAction(this)' style='display: none;' value='<spring:message code='Cache.btn_apv_person_audit1'/>' />";/*개인준법*/
      strTHeadTrTdButtons += " <input type='button' class='smButton' id='btDAudit' name='cbBTN' onclick='doButtonAction(this)' style='display: none;' value='<spring:message code='Cache.btn_apv_dept_audit'/>' />";/*부서감사*/
      strTHeadTrTdButtons += " <input type='button' class='smButton' id='btPAudit' name='cbBTN' onclick='doButtonAction(this)' style='display: none;' value='<spring:message code='Cache.btn_apv_person_audit'/>' />";/*개인감사*/
      //strTHeadTrTdButtons += " <input type='button' class='smButton' id='btUp' name='cbBTN' onclick='doButtonAction(this)' value='<spring:message code='Cache.lbl_apv_up'/>' />";/*위*/
      //strTHeadTrTdButtons += " <input type='button' class='smButton' id='btDown' name='cbBTN' onclick='doButtonAction(this)' value='<spring:message code='Cache.lbl_apv_down'/>' />";/*아래*/
      strTHeadTrTdButtons += "</div>";
      
      newTD.innerHTML =  strTHeadTrTdButtons;
    	  
      if (this.viewtype == "create") {
    	  newCol_dp_apv_checkbox.style.width = "50px";
    	  newCol_dp_apv_no.style.width = "30px";
    	  newCol_dp_apv_username.style.width = "160px";
    	  newCol_dp_apv_state.style.width = "60px";
    	  newCol_dp_apv_kind.style.width = "100px";
    	  newCol_dp_apv_delete_button.style.width = "50px";
    	  newCol_dp_apv_approvdate.style.display = "none";
    	  $(newTD).attr("colspan","6");
    	  
      } else {
    	  newCol_dp_apv_checkbox.style.width = "30px";
    	  newCol_dp_apv_no.style.width = "20px";
    	  newCol_dp_apv_username.style.width = "120px";
    	  newCol_dp_apv_state.style.width = "60px";
    	  newCol_dp_apv_kind.style.width = "90px";
    	  newCol_dp_apv_approvdate.style.width = "90px";
    	  newCol_dp_apv_delete_button.style.width = "40px";
    	  $(newTD).attr("colspan","7");
      }

      oColGroup.appendChild(newCol_dp_apv_checkbox);
      oColGroup.appendChild(newCol_dp_apv_no);
      oColGroup.appendChild(newCol_dp_apv_username);
      oColGroup.appendChild(newCol_dp_apv_state);
      oColGroup.appendChild(newCol_dp_apv_kind);
      oColGroup.appendChild(newCol_dp_apv_approvdate);
      oColGroup.appendChild(newCol_dp_apv_delete_button);
      
      
      newTR.appendChild(newTD);
      oTHead.appendChild(newTR);
      
      oTable.appendChild(oColGroup);
      oTable.appendChild(oTHead);
      
  }   
   
  function clickApvTab(pObj){	  
		$("#ApvTab .AXTab").attr("class","AXTab");
		$(pObj).addClass("AXTab on");
		
		var str = $(pObj).attr("value");

		$("#apvandcc").hide(); //결재자 & 참조자 목록
		$("#divrecinfo").hide(); //배포목록
		$("#divdistribution").hide(); //대외수신처 
		
		$("#apvandccButton").hide(); //결재자 & 참조자 버튼
		$("#divrecinfoButton").hide(); //배포목록 버튼
		$("#divdistributionButton").hide(); //대외수신처 버튼

		$("#apvandccLine").hide(); //개인결재선
		$("#divrecinfoLine").hide(); //개인 & 공용 배포목록
					
		$("#" + str).show();
		$("#" + str+"Button").show();
		$("#" + str+"Line").show();
		
		//대외수신처 옵션 사용 경우
		 if (getInfo("SchemaContext.scDistribution.isUse")=="Y"){
		   if(str=="divdistribution"){
			   $("#groupTreeDiv").remove();
			   $("#divSearchList_Main").remove();
			   $("#searchdiv").remove();
		   		   
			   setOrgChartDist();			   
			   $("input:radio[name ='groupTypeRadio'][value='dist']").prop("checked", true);
		   }else{
			   $("#groupTreeDiv").remove();
			   $("#divSearchList_Main").remove();	
			   $("#searchdiv").remove();
			   
			   setOrgChart();
	           $("input:radio[name ='groupTypeRadio'][value='dept']").prop("checked", true);
		   }
		 }
	   
	   
	}

  
  // 개인결재 그룹 생성
  function savePrivateDomainData() {
      makeApvLineXml(); 
      
      //JAR-CONVERT 01 시작
      var elmRoot = $$(m_oApvList).find("steps");  
      
      if(elmRoot.children().length<1){
    	  Common.Warning(strMsg_052);  //결재선에서 합의는 최종결재자 전에 위치해야 합니다.\n현 합의자를 결재자 아래로 내려주십시요.
          return false;
      }
      //JAR-CONVERT 01 끝
      
      //기안자만 지정되어 있는 상태에서 저장하고자 할 때 방지;
      if(getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE"){
	      if(elmRoot.find("division").concat().length == 1 && elmRoot.find("step").concat().length == 1 && elmRoot.find("step>ou>person").find("taskinfo[kind=charge]").length == 1){
	    	  Common.Warning("<spring:message code='Cache.msg_apv_personDomainDataCheck' />");			//기안자만 지정되어 있을 경우, 저장할 수 없습니다.
	    	  return false;
	      }
      }else{
    	  var isOneStep = false;
          elmRoot.find("division").concat().each(function(idx,item){
        	if($$(item).find(">taskinfo").attr("status") == "pending"){
          		if($$(item).find(">step").concat().length == 1 && $$(item).find(">step>ou>person>taskinfo[kind='charge']").length == 1){
        	  		isOneStep = true;
        	  	}
          	}
          });
          if(isOneStep){
        	  Common.Warning("<spring:message code='Cache.msg_apv_personDomainDataCheck' />");			//기안자만 지정되어 있을 경우, 저장할 수 없습니다.
        	  return false;
          }  
      }
      
      Common.Prompt("<spring:message code='Cache.msg_apv_input_privateDomainData' />","","<spring:message code='Cache.btn_PersonalApvLine' />",function(strGroup){
    	  
    	  if(strGroup == null){
    		  return;
    	  }else if(strGroup == "") {
    		  Common.Warning("<spring:message code='Cache.msg_apv_276' />");  // 결재선 이름을 입력하세요.
              return;
          }
    	  
    	  var sApvLine = getApvListGroupXML();
    	  var sAbstract = makeAbstract($.parseJSON(sApvLine));
    	  
    	  
    	  Common.Confirm("<spring:message code='Cache.msg_apv_343' />", "Confirmation Dialog", function (result) {
              if (!result) return; 

              $.ajax({
            	  type:"POST",
            	  url:"apvline/insertPrivateDomain.do",
            	  data:{
            		  "customCategory" : 'APPROVERCONTEXT',
            		  "displayName" : strGroup,
            		  "ownerID" : userID,
            		  "abstract" : sAbstract,
            		  "description" : '',
            		  "privateContext" : sApvLine
            	  },
            	  success : function(data){
            		  if(data.result == "ok" && data.cnt >= 1){
            			  getPrivateDomainList();
            			  // 문서 내 결재선 사용
	           			  if (getInfo('SchemaContext.scFormAddInApvLine.isUse') == 'Y' && typeof (m_oFormEditor) == 'object' && m_oFormEditor.addInApvLine != undefined) {
	           				  m_oFormEditor.addInApvLine.getPrivateDomainList();
	           			  }
            		  }
            	  },
            	  error:function(response, status, error){
      				CFN_ErrorAjax("apvline/insertPrivateDomain.do", response, status, error);
      			}
              });
          });
    	}); 
      
  }
  
  //개인결재 그룹 생성
  function overwritePrivateDomainData(privateDomainID) {
	  makeApvLineXml(); 
      
      //JAR-CONVERT 01 시작
      var elmRoot = $$(m_oApvList).find("steps");  
      
      if(elmRoot.children().length<1){
    	  Common.Warning(strMsg_052);  //결재선에서 합의는 최종결재자 전에 위치해야 합니다.\n현 합의자를 결재자 아래로 내려주십시요.
          return false;
      }
      //JAR-CONVERT 01 끝
      
      //기안자만 지정되어 있는 상태에서 저장하고자 할 때 방지;
      if(elmRoot.find("division").concat().length == 1 && elmRoot.find("step").concat().length == 1 && elmRoot.find("step>ou>person").find("taskinfo[kind=charge]").length == 1){
    	  Common.Warning("<spring:message code='Cache.msg_apv_personDomainDataCheck' />");			//기안자만 지정되어 있을 경우, 저장할 수 없습니다.
    	  return false;
      }
      
      Common.Confirm("<spring:message code='Cache.msg_apv_343' />", "Confirmation Dialog", function (result) {
          if (!result) return; 
          var sApvLine = getApvListGroupXML();
    	  var sAbstract = makeAbstract($.parseJSON(sApvLine));
          
          $.ajax({
            	type:"POST",
            	url:"apvline/updatePrivateDomain.do",
            	data:{
            		"abstract": sAbstract,
            		"privateDomainDataID": privateDomainID,
            		"privateContext" : sApvLine
            	},
            	success:function(data){
            		if(data.result=="ok"){
            			 //document.getElementById(strPDDID).value = sApvLine;
                         //getApvListGroupDetailSub(strPDDID);
            			getPrivateDomainList();
            		}
            	},
            	error:function(response, status, error){
    				CFN_ErrorAjax("apvline/updatePrivateDomain.do", response, status, error);
    			}
            });
          
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
          /*$$(oJSON).find("steps > division[divisiontype='receive'] > step[routetype='audit']").each(function (i, $$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove(); //step 배열 요소 삭제
          });*/
          $$(oJSON).find("steps > division[divisiontype='receive'] > step[routetype='audit']").remove();

          //발신부서 삭제
          /*$$(oJSON).find("steps > division[divisiontype='send'] ").each(function (i, $$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove(); //division 배열 요소 삭제 (ex. division[1] 삭제)
          });*/
          $$(oJSON).find("steps > division[divisiontype='send'] ").remove();

          //다른 division 삭제
          /*$$(oJSON).find("steps > division").concat().has("taskinfo[status!='pending']").each(function (i, $$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove(); //division 배열 요소 삭제 (ex. division[1] 삭제)
          });*/
          $$(oJSON).find("steps > division").concat().has("taskinfo[status!='pending']").remove();
         
          //발신부서 참조 제거
          /*
          $$(oJSON).find("steps > ccinfo[belongto='sender']").each(function (i, $$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove();
          });
          */
          $$(oJSON).find("steps > ccinfo[belongto='sender']").remove();
          
      }else{
          //기안자 제거
          $$(oJSON).find("steps> division[divisiontype='send']> step > ou > person:has(taskinfo[kind='charge'])").each(function (i, $$) {
              elementToRemove = $$;
          });
          if (elementToRemove != null) elementToRemove.parent().parent().remove(); //step 배열 요소 삭제 (ex. step[0] 삭제)

          //감사-부서처리 제거
          //$$(oJSON).find("steps > division[divisiontype='send'] > step[routetype='audit'],steps > division[divisiontype='send'] > step[unittype='ou']").each(function (i,$$) {
          /*$$(oJSON).find("steps > division[divisiontype='send'] > step[routetype='audit']").each(function (i,$$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove(); //step 배열 요소 삭제 
          });*/
          $$(oJSON).find("steps > division[divisiontype='send'] > step[routetype='audit']").remove();

          //수신부서 삭제
          /* $$(oJSON).find("steps > division[divisiontype='receive'] ").each(function (i, $$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove(); //division 배열 요소 삭제 (ex. division[1] 삭제)
          }); */
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
  // 개인배포목록 수신자 가져오기
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
				   groupID: strID
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
<div class="layer_divpop" id="testpopup_p" style="min-width: 1100px; width: 100%; height: 100%; z-index: 51;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
 <!-- 팝업 Contents 시작 --> 
 <!-- <div class="divpop_contents"> -->
    <!-- 
    <div class="pop_header" id="testpopup_ph">
      <h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico">결재선</span></h4>
      <a class="divpop_close" id="testpopup_px" style="cursor: pointer;" onclick="doButtonAction(document.getElementById('btExit'))"></a>
      <a class="divpop_window" id="testpopup_LayertoWindow" style="cursor: pointer;" onclick="Common.LayerToWindow('layerpopuptest.do?as=ads', 'testpopup', '331px', '270px', 'both')"></a>
      <a class="divpop_full" style="cursor: pointer;" onclick="Common.ScreenFull('testpopup', $(this))"></a><a class="divpop_mini" style="cursor: pointer;" onclick="Common.ScreenMini('testpopup', $(this))"></a>
    </div> 
    -->
    <!--appBox 시작 -->  
 <div id="dvGroupType" class="org_tree_top_radio_wrap" style="margin-left:10px; display:none">					
  <input id="deptRadio" type="radio" class="org_tree_top_radio" value="dept" name="groupTypeRadio" checked=""><label for="deptRadio"><spring:message  code='Cache.lbl_apv_org' /></label>	<!-- 조직도 -->				
  <input id="distRadio" type="radio" class="org_tree_top_radio" value="dist" name="groupTypeRadio"><label for="groupRadio"><spring:message  code='Cache.lbl_apv_overdistribution' /></label>	<!--대외 수신처 -->			
 </div>  
       
    <div id="orgTargetDiv" class="appBox">
	  <!-- 트리 및 리스트는 공통 조직도에서 처리 -->
	  
	  <!-- 버튼 영역 시작 -->
	  <div class="appBtn">
	  		
	  		<!-- 결재(참조, 배포 제외 버튼) & 참조 버튼 목록 (탭영역 구분을 위해 묶음) 시작-->
	  		<div id="apvandccButton">
				
				<!--참조, 배포 제외 버튼  시작-->
				<div id="dvCommon">
					 <input type="button" id="btnSelect" class="btnSelect" onclick="doButtonAction(document.getElementById('btPerson'))" value="<spring:message code='Cache.lbl_apv_normalapprove' />"/><!--선택된 버튼 --><!--기본선택:일반결재--><input type="button" id="sendArrowBtn" class="sendArrow" onclick="$('#dvCommonList').show();" value="보내기"/>
					 <!--버튼 목록-->
					 <ul id="dvCommonList" class="select_list" style="display:none;">
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btDAuditLeft"><spring:message  code='Cache.btn_apv_dept_audit' /></li><!-- 부서 감사 -->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btDAudit1Left"><spring:message code='Cache.btn_apv_dept_audit1' /></li><!-- 부서준법 -->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btDConsult"><spring:message code='Cache.lbl_apv_DeptConsent' /></li><!-- 다국어:부서합의, 기능:부서합의 (순차) -->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btDConsult2"><spring:message code='Cache.lbl_apv_DeptConsent_2' /></li><!-- 다국어:부서합의,  기능:부서합의 (병렬) -->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btDAssist" ><spring:message code='Cache.lbl_apv_DeptAssist' /></li><!-- 다국어:부서협조(순차), 기능:부서협조(순차) -->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btDAssistPL"><spring:message code='Cache.lbl_apv_DeptAssist2' /></li><!-- 다국어:부서협조(병렬), 기능:부서협조(병렬) -->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btReceipt" ><spring:message code='Cache.btn_apv_recdept' /></li><!-- 수신처 -->
			          <li name="cbBTN" onclick="selectButton(this)" id="btPerson"><spring:message code='Cache.lbl_apv_normalapprove' /></li><!--일반결재-->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btPAuditLeft"><spring:message code='Cache.btn_apv_person_audit' /></li><!--개인감사-->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btPAudit1Left"><spring:message code='Cache.btn_apv_person_audit1' /></li><!--개인준법-->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btPConsult"><spring:message code='Cache.btn_apv_consultors' /></li><!--다국어:개인합의, 기능:개인합의(순차)-->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btPConsult2"><spring:message code='Cache.btn_apv_consultors_2' /></li><!--다국어:개인합의, 기능:개인합의(병렬) -->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btPAssist" ><spring:message code='Cache.lbl_apv_assist' /></li><!--다국어:개인협조(순차), 기능:반려합의(순차)-->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btPAssistPL"  ><spring:message code='Cache.lbl_apv_assist_2' /></li><!--다국어:개인협조(병렬), 기능:반려합의(병렬)  -->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btCharge"><spring:message code='Cache.btn_apv_charge' /></li><!--담당자 -->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btPersonConfirm"><spring:message code='Cache.lbl_apv_PApprConfirm' /></li><!--확인자 -->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btPersonShare"><spring:message code='Cache.lbl_apv_PApprShare' /></li><!--참조자 -->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btPlPerson"><spring:message code='Cache.lbl_apv_approv_sametime' /></li><!--동시결재-->
			          <li name="cbBTN" onclick="selectButton(this)" style="display: none;" id="btPReview"><spring:message code='Cache.btn_apv_confirmor' /></li><!--공람자-->
			        </ul>
		        </div>
		        <!--참조, 배포 제외 버튼 끝-->
		        
		        <!--참조 관련 버튼 모음(사전참조,사후참조,참조자)시작-->
		        <div id="dvCC" name="dvCC" style="display: none;" class="appBtnSend">
		        	<div id="tblDraftRefBefor" style="display: none;"><input type="button" class="btn_send" id="btSendCCBefor" name="cbBTN" onclick="doButtonAction(this);"
		        		value="<spring:message code='Cache.btn_apv_ccinfo_before' /><spring:message code='Cache.lbl_apv_cc'/>"/> <!--사전,참조-->
		        	</div>
		        	<div id="tblDraftRefAfter" style="display: none;"><input type="button" class="btn_send" id="btSendCCAfter" name="cbBTN" onclick="doButtonAction(this);"
		        		value="<spring:message code='Cache.btn_apv_ccinfo_after' /><spring:message code='Cache.lbl_apv_cc'/>"/> <!--사후,참조-->
		        	</div>
		        	<div id="tblDraftRef" style="display:;"><input type="button" class="btn_send" id="btSendCC" name="cbBTN" onclick="doButtonAction(this);"
		        		value="<spring:message code='Cache.lbl_apv_cc' />"/> <!--참조-->
		        	</div>
		        	<div id="tblReceiptRef" style="display:none;"><input type="button" class="btn_send" id="btRecCC" name="cbBTN" onclick="doButtonAction(this);"
		        		value="<spring:message code='Cache.btn_apv_receive' /><spring:message code='Cache.lbl_apv_cc' />"/> <!--수신참조-->
		        	</div>
		        </div>
		        <!--참조 관련 버튼 모음(사전참조,사후참조,참조자) 끝-->
		        
	       	</div>
	       	<!-- 결재(참조, 배포 제외 버튼) & 참조 버튼 목록 (탭영역 구분을 위해 묶음) 시작-->
	       	
	        <!--배포 관련 버튼 모음(배포추가) 시작 -->
	        <div id="divrecinfoButton">
		        <div id="dvRec" style="display: none;">
		           	<input type="button" class="btn_send" id="btRecDept" name="cbBTN" onclick="doButtonAction(this);"
		        		value="<spring:message code='Cache.btn_apv_deploy_add' />"/><!--배포추가-->
			    </div>
	        </div>
	        <!--배포 관련 버튼 모음(배포추가) 끝 -->
        
	        <!--문서유통 대외수신처 관련 버튼 모음 시작 -->
	        <div id="divdistributionButton">
		        <div id="dvDist" style="display: none;">
		           	<input type="button" class="btn_send" id="btDistribution" name="cbBTN" onclick="doButtonAction(this);"
		        		value="<spring:message code='Cache.btn_apv_recdept' />"/><!--수신처-->
			    </div>
	        </div>
	        <!--문서유통 대외수신처 관련 버튼 모음 끝 -->        
        
	    </div>
	    <!-- 버튼 영역 끝 -->
	  
	    <!-- 탭영역 시작 -->
        <div class="appTab" style="margin-top: -70px;">
            <!-- 탭메뉴 시작 -->
            <div style="padding: 0px 1px; width: calc(100% - 1px);">
                <div class="AXTabsLarge" id="ApvTab">
                    <div class="AXTabsTray"> 
                        <a id="tabapvandcc" class="AXTab on" href="#ax" value="apvandcc" onclick='clickApvTab(this)'><spring:message code='Cache.lbl_apv_apprvlist' /></a> <!--결재목록-->
                        <a id="tabrecinfo" class="AXTab" href="#ax"  value="divrecinfo" onclick='clickApvTab(this)' style="display:none;"><spring:message code='Cache.lbl_apv_DDistribute' /></a> <!--배포목록 -->
                        <a id="tabdistribution" class="AXTab" href="#ax"  value="divdistribution" onclick='clickApvTab(this)' style="display:none;"><spring:message code='Cache.lbl_apv_overdistribution' /></a> <!--대외수신처 -->
                    </div>
                </div>
            </div>
            <!-- 탭메뉴 끝 -->
            <!--결재자 & 참조자 목록 시작 (탭 영역 구분을 위해 묶음)-->
            <div id="apvandcc">
                <!--결재자 목록 시작-->
                <div class="appInfo" id="divapvinfo">
                    <!--테이블이 추가되는 div-->
                    <div id="Apvlist" style="overflow-x:hidden;"></div>
                    <div id="ApvlistSendRight" class="btnWArea" style="border-top: 1px solid #d3d8df;">
                    	<div style="margin-top: -6px; margin-left: 5px; float: left;">
							<input type='button' class='smButton' id='btUp' name='cbBTN' onclick='doButtonAction(this)' value='<spring:message code='Cache.lbl_apv_up'/>' /><!--위로-->
							<input type='button' class='smButton' id='btDown' name='cbBTN' onclick='doButtonAction(this)' value='<spring:message code='Cache.lbl_apv_down'/>' /><!--아래로-->
						</div>
						<div>
                    		<a href="#" id="a_saveDomaindata" class="sendRight" onclick="savePrivateDomainData()"><spring:message code='Cache.lbl_save_privatedomaindata'/><!--개인결재선으로 저장--></a>
                    	</div>
                    </div>
                </div>
                <!--결재자 목록 끝 -->
                <!--참조자 목록 시작-->
                <div class="appInfoBot" id="divccinfo" style="display: none;">
                    <table class="tableStyle t_center hover infoTableBot" id="tblccinfo">
                        <colgroup>
                            <col style="width:100px" />
                            <col style="width:250px" />
                            <col style="width:50px" />
                        </colgroup>
                        <thead>
                            <tr>
                                <td colspan="3"><h3 class="titIcn"><spring:message code='Cache.lbl_apv_ref' /></h3></td><!--참조자-->
                            </tr>
                        </thead>
                        <tbody>
                        	<tr id='hTRTemp' data-type='temp' ondrop='void_drop(event,"tblccinfo")' ondragover='event.preventDefault();'>
                        		<td colspan='3' ></td>
                        	</tr>
                        </tbody>
                    </table>
                </div>
                <!--참조자 목록 끝-->
            </div>
            <!--결재자 & 참조자 목록 끝(탭 영역 구분을 위해 묶음)-->
	         
	        <!--배포 목록 시작 -->
	        <div class="appInfo02" id="divrecinfo" style="display:none">
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
								<tr>
									<td></td>
									<td></td>
								</tr>
							</tbody>
					</table>
				</div>
	        	<div id="ReclistSendRight" class="btnWArea02" style="border-top: 1px solid #d3d8df;">
	        		<a href="#" class="sendRight" id="a_saveDistribution" onclick="savePrivateDistribution()">&nbsp;&nbsp;&nbsp;&nbsp;<spring:message code='Cache.lbl_save_privategroup'/></a><!--개인수신처로 저장-->
	        	</div>
	        </div>	  
	        <!--배포목록 끝-->
	        
	        <!--문서유통 대외수신처 목록 시작 -->
	        <div class="appInfo02" id="divdistribution" style="display:none">
	        	<div id="divdistributionlist">
		        	<table id="tbldistinfo" name="tblrecinfo" class="tableStyle t_center hover infoTable"><colgroup>
								<col id="Col1" style="width:*" />
								<col id="Col2" style="width:10px"/>
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
								<tr>
									<td></td>
									<td></td>
								</tr>
							</tbody>
					</table>
				</div>
	        	<div id="ReclistSendRight" class="btnWArea02" style="display: none;"><a href="#" class="sendRight" onclick="savePrivateDistribution()">&nbsp;&nbsp;&nbsp;&nbsp;<spring:message code='Cache.lbl_save_privategroup'/></a></div><!--개인수신처로 저장-->
	        </div>	  
	        <!--문서유통 대외수신처 끝-->   	        
	  </div>
 	  <!-- 탭영역 끝 --> 
 	  
      <!-- 펼침/접힘 시작 --> 
      <a href="#" id="btnOpen" class="appOpen" onclick="fnShowApvLineMgr('open')" style="display:none;"><spring:message code='Cache.btn_open'/></a> <!--열기 -->
      <a href="#" id="btnClose" class="appClose" onclick="fnShowApvLineMgr('close')" style="display:none;"><spring:message code='Cache.btn_Close'/></a> <!--닫기-->
      <!-- 펼침/접힘  끝 --> 

	  <!--개인결재선 ,개인수신처, 공용 배포목록 시작-->	
	  <div class="appPers" id="divApvLineMgrSub" style="display:none;">
	  	  <div id="apvandccLine">
		  	  <div id="divtApvLine">
			      <table class="tableStyle t_center hover persTable" id="divdetailtApvLine">
				      <colgroup>
				          <col style="width:50px">
				          <col style="width:*">
			          </colgroup>
			           <thead>
				          <tr>
				              <td colspan="2"><h3 class="titIcn"><spring:message code='Cache.lbl_apv_doc_privateapv' /></h3></td><!--개인결재선-->
				          </tr>
			           </thead>
			           <tbody></tbody>
			      </table>
			      <div class="tCenter mt15">
        			<input type="button" class="smButton" onclick="applyApvListGroup()" value="<spring:message code='Cache.lbl_apply' />"/><!--적용-->
       			 </div> 
		  	  </div>
	  	  </div>
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
	      <input type="button" id="btOK" name="cbBTN" onclick="doButtonAction(this);" class="ooBtn ooBtnChk" value="<spring:message code='Cache.btn_Confirm'/>"/><!--확인-->
	      <input type="button" id="btExit" name="cbBTN" onclick="doButtonAction(this);" class="owBtn mr30" value="<spring:message code='Cache.btn_apv_close'/>"/><!--닫기-->
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