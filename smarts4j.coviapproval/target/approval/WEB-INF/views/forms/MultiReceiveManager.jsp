<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/approval/resources/script/forms/ApvlineManager.js<%=resourceVersion%>"></script>

<script>
	//# sourceURL=ApvlineManager.jsp
	var myDeptTree = new coviTree();
	var openID =  CFN_GetQueryString("openID")=="undefined"? "":CFN_GetQueryString("openID");
	var admintype =  CFN_GetQueryString("admintype")=="undefined"? "":CFN_GetQueryString("admintype");
  	var selTab = "tSearch";
  	var userID = Common.getSession("USERID");
  	var langCode = Common.getSession("lang")
  	var Sendtype = "${gbn}";
  	var BankGroupList = "";
  	var treekind = "${gbn}" == "Out" ? "GROUP" : "Dept";
  	
  	//결재선선택
    var m_oParent, m_oUserList;
    var m_selectedCCRow = null;
    var m_selectedCCRowId = null;

    var ApvListDisplayOrder = "DESC"; // 결재선 목록 정렬 순서 default : DESC(역순), ASC:정순
    var ApvKindUsage = Common.getBaseConfig("ApvKindUsage"); //201111 결재종류사용여부 전결;결재안함;후결;후열
	
    $(document).ready(function(){
		setOrgChart();
		
		getPrivateDomainList();
		getPrivateDistribution();
		
		clickTab($("#aPrivateDomain"));
		clickDeployTab($("#divtPersonDeployList"));

		$('[id^=companySelect]').attr('disabled', true);
		$('[id^=AXselect]').attr('disabled', true);
		$('[class^=AXanchor]').attr('disabled', true);
		$('[id^=AXselect]').attr('readOnly', "readOnly");
	});
    
	$(window).load(function(){
		clickApvTab($("#tabrecinfo"));
		fnShowApvLineMgr("close");
	});
   
   
	function setOrgChart(){
		var config ={
				targetID: 'orgTargetDiv',
				type:'C9',
				drawOpt:'LM___',
				OrgGbn:"${gbn}",
				allCompany:"N",
				treeKind : treekind
		};
		
		coviOrg.render(config);
		coviOrg.contentDoubleClick = contentDoubleClick;
	}
	
	//Double Click 시 결재선에 추가
	function contentDoubleClick(obj){
		$(obj).find("input[type=checkbox]").prop('checked', true);
		$("#btnSelect").click();
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
						var displayName = (defaultYN=="Y") ? ("["+Common.getDic("lbll_Default")+"]"+list.DisplayName) : (list.DisplayName);		//기본
						
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
		                	htmlList += "<td id='privateDoaminDataSubject"+privateDomainID+"'class='subject'>" + "<span id='privateDomainSubjectSpan"+privateDomainID+"' value='"+privateDomainID+"' onclick='clickPrivateDomain(this)' >"+ (priDivisionType == "send" ? "["+Common.getDic("lbl_send")+"]" : "["+Common.getDic("lbl_apv_receive")+"]") + displayName+"</span>";			//발신 | 수신
		                	htmlList += "<a href='#' id='privateDomainMoreEnd"+privateDomainID+"' onclick='clickflag($(\"#privateDoaminMenu"+privateDomainID+"\"));' class='moreEnd' style='display:none'><spring:message code='Cache.lbl_MoreView'/></a>"; /*더보기*/
		                 	htmlList += "<ul id='privateDoaminMenu"+privateDomainID+"'class='menu_more' style='display:none'>";
		                 	htmlList += "<li><span>icn</span></li>";
		                 	htmlList += "<li class='first' onclick='delPrivateDomain("+privateDomainID+"); $(\"#privateDoaminMenu"+privateDomainID+"\").hide();'><spring:message code='Cache.btn_delete'/></li>"; /*삭제 */ 
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
				"entCode" : Common.getSession("DN_Code")
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
	
    // 개인결재선그룹 삭제하기
    function delPrivateDomain(privateDomainID) {
        var results;
        Common.Confirm(Common.getDic("msg_apv_093"), "Confirmation Dialog", function (result) {
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
		
        //jsoner-convert 01 시작
        
        var oJson =  $.parseJSON( document.getElementById("privateDomainContext"+privateDomainID).value );
        var idx=1;
        
        $$(oJson).find('steps>division>step>ou>person , steps>division>step>ou>role').each(function (i, $$) {
	       		if($$.nodename()=="role"){
	       			html_list += displayGroupDetail((i + 1), $$.attr('code'), "division"+i, CFN_GetDicInfo($$.attr('name'),langCode) +  "," + CFN_GetDicInfo($$.attr('ouname'),langCode)+",", privateDomainID, null);
	       		}else if($$.nodename()=="person"){
	       		  	 var sConvertKind ="";
	                 sConvertKind = convertKindToSignTypeByRTnUT($$.find('taskinfo').attr('kind'),$$.parent().parent().concat().find('[unittype]').attr('unittype'), $$.parent().parent().concat().find('[routetype]').attr('routetype'), $$.parent().parent().concat().find('[unittype]').attr('unittype'), "", $$.parent().parent().concat().find('[allottype]').attr('allottype')) ;
	                 html_list += displayGroupDetail((i + 1), $$.attr("code"), "division"+i, CFN_GetDicInfo($$.attr("name"),langCode) + "," + splitName($$.attr("position")) + "," + sConvertKind, privateDomainID, CFN_GetDicInfo($$.attr("ouname")));
	       		}else if($$.nodename()=="role"){
	       		 	 html_list += displayGroupDetail((i + 1), $$attr("code"), "division"+i, CFN_GetDicInfo($$.attr("name"),langCode) , privateDomainID, null);
	       		} 
        });

        if($$(oJson).find('ccinfo>ou>person').length>0){
        	html_list += "<dl class='addList'>";
        	html_list += "<dt><spring:message code='Cache.lbl_apv_cc'/> :</dt>";
        }
        //아래 라인 추가 표시될 부분은 수정하여 추가
        $$(oJson).find('ccinfo>ou>person').each(function (i, $$) {
            if ($$.nodename() == "person") {
                var sConvertKind = "";
                sConvertKind = convertKindToSignTypeByRTnUT($$.find('taskinfo').attr('kind'),$$.parent().parent().concat().find('[unittype]').attr('unittype'), $$.parent().parent().concat().find('[routetype]').attr('routetype'), $$.parent().parent().concat().find('[unittype]').attr('unittype'), "", $$.parent().parent().concat().find('[allottype]').attr('allottype'));

                if (getInfo("SchemaContext.scBeforCcinfo.isUse") == "Y") {
                    if ($$.parent().parent().attr("beforecc") == undefined) {
                        html_list += displayGroupDetail((i + 1), $$.attr("code"), "ccinfo"+i, CFN_GetDicInfo($$.attr("name"),langCode) + "(," + splitName($$.attr("position")) + "," + Common.getDic("btn_apv_ccinfo_after") + Common.getDic("lbl_apv_cc"), privateDomainID, CFN_GetDicInfo($$.attr("ouname"),langCode));
                    }
                    else {
                        html_list += displayGroupDetail((i + 1), $$.attr("code"), "ccinfo"+i, CFN_GetDicInfo($$.attr("name"),langCode) + "," + splitName($$.attr("position")) + "," + Common.getDic("btn_apv_ccinfo_before") + Common.getDic("lbl_apv_cc"), privateDomainID, CFN_GetDicInfo($$.attr("ouname"),langCode));
                    }
                }
                else {
                    html_list += displayGroupDetail((i + 1), $$.attr("code"), "ccinfo"+i, CFN_GetDicInfo($$.attr("name"),langCode) + "," + splitName($$.attr("position")) + "," + Common.getDic("lbl_apv_cc"), privateDomainID, CFN_GetDicInfo($$.attr("ouname"),langCode));
                }
            }
            else if (elm.tagName == "ou") {
                html_list += displayGroupDetail((i + 1), $$.attr("code"), i,CFN_GetDicInfo($$.attr("name"),langCode), privateDomainID, null);
            }
        }); 
                        
        if($$(oJson).find('ccinfo>ou>person').length>0){
        	html_list += "</dl>";
        }
        
        //jsoner-convert 01 끝
        
        html_list += "</td>";
        document.getElementById("divApvListGroupDetail" + privateDomainID).innerHTML = html_list;
    }
        
    function displayGroupDetail(strNum, strId, strType, strName, strPDDID, strOuName) {
        var rtnValue = "";
        var nameSplit = strName.split(",");
        
        
        if(strType.indexOf('ccinfo')>=0){
        	rtnValue += "<dd>"+nameSplit[0]+' '+nameSplit[1] +"</dd>";
        }else{
	        if(strOuName != null){
	            rtnValue += "<ul class='proNum'>";
	        }else{
	            rtnValue += "<ul class='proNum'>";
	        }
	        
	       
	        rtnValue += "<li>"+strNum+"</li>"
	        rtnValue += "<li>"+nameSplit[0]+' '+nameSplit[1] +"</li>"//이름 직급
	        rtnValue += "<li>"+nameSplit[2]+"</li>" //결재 유형
	        //rtnValue += "<li><a href=\"javascript:delApvListGroupDetail('" + strPDDID + "','" + strId + "','" + strType + "');\"><img src='/approval/resources/images/Approval/app_conf_x.gif' alt='" + Common.getDic("btn_apv_delete") + "' title='" + Common.getDic("btn_apv_delete") + "' class='img_align2' /></a></li>"
	        rtnValue += "</ul>";
        }

        return rtnValue;
    }
    
    
    //개인결재선 멤버 삭제
    function delApvListGroupDetail(strPDDID, strId, strType) {
        Common.Confirm(Common.getDic("msg_apv_093"), "Confirmation Dialog", function (result) {
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
        if (strPDDID == "") {
            return;
        } else {
             var sJSON = document.getElementById("privateDomainContext"+strPDDID).value;
             var oJSON = $.parseJSON(sJSON);
          	 var oSteps = $$(oJSON).find("steps");   
          	 switch (m_sApvMode) {
	          	case "REDRAFT":
	                m_oApvList = jQuery.parseJSON(m_oFormMenu.document.getElementById("APVLIST").value.replace(/&/g, "&amp;"));
	                var m_oCurrentOUNode = $$(m_oApvList).find("division[divisiontype='receive']:has(taskinfo[status='pending'])");
	
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
	                    document.getElementById("Apvlist").innerHTML = "";
	                    refreshList();
	                }
	                break;
	          	case "SUBREDRAFT":
                    alert("error"+Common.getDic("strMsg_047"));
                    break;
                default:
                    var oCheckSteps = chkAbsent(oSteps);
                    var oApvList = $$("{}").create("steps");
					var $$_oApvList = $$(oApvList);
					
					var $$_oSteps = $$(oSteps);
					
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
                        $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt"));
                        $$(oTaskinfo).attr("customattribute1", getInfo("AppInfo.usit"));
                        $$(oDivTaskinfo).attr("status", "inactive");
                        $$(oDivTaskinfo).attr("result", "inactive");
                        $$(oDivTaskinfo).attr("kind", "normal");
                        $$(oDivTaskinfo).attr("datereceived", getInfo("AppInfo.svdt"));
                        $$(oDiv).attr("name", strlable_circulation_sent); //"발신"
                        $$(oDiv).attr("oucode", getInfo("AppInfo.dpid_apv"));
                        $$(oDiv).attr("ouname", getInfo("AppInfo.dpdn_apv"));
                        $$(oDiv).attr("divisiontype", "send");
						
                        $$(oPerson).attr("taskinfo",oTaskinfo.json());
                        $$(oOU).attr("person",oPerson.json());
                        $$(oStep).attr("ou",oOU.json());
                        oDiv.find("step").json().splice(0,0,oStep.json())                      
						
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
    		},
    		error:function(response, status, error){
				CFN_ErrorAjax("apvline/getPrivateDistribution.do", response, status, error);
			}
    	});
	}
    
    //개인수신처 삭제
    function deletePrivateDistribution(strPDDID) {
        Common.Confirm(Common.getDic("msg_apv_093"), "Confirmation Dialog", function (result) {
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
      Common.Confirm(Common.getDic("msg_apv_093"), "Confirmation Dialog", function (result) {
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
      strTHeadTrTdButtons += " <input type='button' class='smButton' id='btUp' name='cbBTN' onclick='doButtonAction(this)' value='<spring:message code='Cache.lbl_apv_up'/>' />";/*위*/
      strTHeadTrTdButtons += " <input type='button' class='smButton' id='btDown' name='cbBTN' onclick='doButtonAction(this)' value='<spring:message code='Cache.lbl_apv_down'/>' />";/*아래*/
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
    	  newCol_dp_apv_no.style.width = "30px";
    	  newCol_dp_apv_username.style.width = "110px";
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
		
		$("#apvandccButton").hide(); //결재자 & 참조자 버튼
		$("#divrecinfoButton").hide(); //배포목록 버튼

		$("#apvandccLine").hide(); //개인결재선
		$("#divrecinfoLine").hide(); //개인 & 공용 배포목록
		
		$("#" + str).show();
		$("#" + str+"Button").show();
		$("#" + str+"Line").show();
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
      if(elmRoot.find("division").concat().length == 1 && elmRoot.find("step").concat().length == 1 && elmRoot.find("step>ou>person").find("taskinfo[kind=charge]").length == 1){
    	  Common.Warning(Common.getDic("msg_apv_personDomainDataCheck"));			//기안자만 지정되어 있을 경우, 저장할 수 없습니다.
    	  return false;
      }
      
      Common.Prompt(Common.getDic("msg_apv_input_privateDomainData"),"",Common.getDic("btn_PersonalApvLine"),function(strGroup){
    	  
    	  if(strGroup == null){
    		  return;
    	  }else if(strGroup == "") {
    		  Common.Warning(Common.getDic("msg_apv_276"));  // 결재선 이름을 입력하세요.
              return;
          }
    	  
    	  var sApvLine = getApvListGroupXML();
    	  var sAbstract = makeAbstract($.parseJSON(sApvLine));
    	  
    	  
    	  Common.Confirm(Common.getDic("msg_apv_343"), "Confirmation Dialog", function (result) {
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
            		  }
            	  },
            	  error:function(response, status, error){
      				CFN_ErrorAjax("apvline/insertPrivateDomain.do", response, status, error);
      			}
              });
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
          $$(oJSON).find("steps > division[divisiontype='receive'] > step[routetype='audit'],steps > division[divisiontype='receive'] > step[unittype='ou']").each(function (i, $$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove();; //step 배열 요소 삭제
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
         
      }else{
          //기안자 제거
          $$(oJSON).find("steps> division[divisiontype='send']> step > ou > person:has(taskinfo[kind='charge')").each(function (i, $$) {
              elementToRemove = $$;
          });
          if (elementToRemove != null) elementToRemove.parent().parent().remove(); //step 배열 요소 삭제 (ex. step[0] 삭제)

          //감사-부서처리 제거
          $$(oJSON).find("steps > division[divisiontype='send'] > step[routetype='audit'],steps > division[divisiontype='send'] > step[unittype='ou']").each(function (i,$$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove(); //step 배열 요소 삭제 
          });

          //수신부서 삭제
          $$(oJSON).find("steps > division[divisiontype='receive'] ").each(function (i, $$) {
              elementToRemove = $$;
              if (elementToRemove != null) elementToRemove.remove(); //division 배열 요소 삭제 (ex. division[1] 삭제)
          });
      }

      return JSON.stringify(oJSON);
  }
  
  //개인 수신처 생성
  function savePrivateDistribution(){	  
      Common.Prompt(Common.getDic("msg_apv_278"),"",Common.getDic("lbl_apv_persongroup"),function(strGroup){
    	  
    	  if(strGroup == null){
    		  return;
    	  }else if (strGroup == "") {
	          Common.Warning(Common.getDic("msg_apv_278"));  // 배포그룹 이름을 입력하세요.
	          return;
	      }else if (getDeployGroupXML().user.length < 1 && getDeployGroupXML().group.length < 1){
	    	  Common.Warning(Common.getDic("msg_apv_003")); //선택된 항목이 없습니다.
	          return;
	      }
    	  
	      Common.Confirm(Common.getDic("msg_apv_155"), "Confirmation Dialog", function (result) {
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
	          //alert(Common.getDic("msg_apv_172"));  // 회람 그룹을 선택하십시오.
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

  function addRecDeptMulti() {
      var $$_m_Json = $$({
         "selected": {
            "to": {},
            "cc": {},
            "bcc": {},
            "user": {},
            "group": {},
            "role": {}
         }
      });
      var sSelectedUserJson = aContentAdd_OnClick();
      var $$_m_JsonExt = $$(sSelectedUserJson);
      //const BOOL_KEYNAME_INCLUDED = true;  //[IE 10 이하  const 사용 오류]
      var BOOL_KEYNAME_INCLUDED = true;				// 선언 이외의 곳에서 값 변경 X

      var bUser = false;
      $$_m_JsonExt.find("Items > item").concat().each(function (i, $$) {
          var $$_json = $$.json(BOOL_KEYNAME_INCLUDED);
          if ($$.attr("type") == "user" && bUser) {
              Common.Warning(Common.getDic("msg_apv_addRecDept")); //수신처에는 부서만 추가 가능합니다.
          } else {
              //selected > group 이 항상 실행되며, 
              //이 때 append node가 이동되므로, 아래 라인은 불필요한 것으로 보여 주석처리함
              //$$_m_Json.find("selected > user ").append($$_json);
          }
          
          // 선택된 데이터 중 중복 되지 않은 데이터만
      	if (!isDupl($$, $$_m_Json, BOOL_KEYNAME_INCLUDED)) {
      		$$_m_Json.find("selected > group ").append($$_json);
      	}
          
      });
      setDistDeptMulti($$_m_Json.find("selected"));
  }

  function setDistDeptMulti($$_oList) {
  	
      var aRecDept = m_RecDept.split(";");
      var elmList, emlNode;
      var sRecDept = "";
      $$_elmList = $$_oList.find("item");
      
      $$_elmList.concat().each(function (i, $$_emlNode) {
         if (chkDuplicate($$_emlNode.attr("AN"))) {
              var sDN = $$_emlNode.attr("DN");
              var sType = $$_emlNode.attr("itemType") == null ? mType : ($$_emlNode.attr("itemType") == "group" ? "0" : "1");

              sRecDept += ";" + sType + ":" + $$_emlNode.attr("AN") + ":" + sDN.replace(/;/gi, "^"); //다국어처리
              if (sType == "0" && !bchkAbsent && $$_emlNode.attr("ETID") != "SAVINGSBANK") {
                  if ($$_emlNode.attr("hasChild") != "0" && $$_emlNode.attr("MemberOf") == "GENERAL") {
                      sRecDept += ":Y"; //Y에서 N으로 변경, 하위부서포함 default에서 미포함으로 변경
                  } else {
                      sRecDept += ":X"; //Y에서 N으로 변경, 하위부서포함 default에서 미포함으로 변경
                  }
                  if ($$_emlNode.attr("CHILD_CNT") != null) {
                      if (mType == 0 && $$_emlNode.attr("CHILD_CNT") == "N") {
                          sCheckBoxFormat += ";" + $$_emlNode.attr("AN") + ":";
                      }
                  }
              } else {
                  sRecDept += ":X";
              }
          }
      });
      m_RecDept += sRecDept;
      if (m_RecDept.indexOf(";") == 0) m_RecDept = m_RecDept.substring(1);
      chkActionMulti(mType);
  }

  function chkActionMulti(actType) {
      if (m_sApvMode.toUpperCase() != "DEPTLIST" && m_sApvMode.toUpperCase() != "CFADMIN") {
          mType = actType;

          make_selRecMulti();
          if (mType == "2" && selTab != "tDeployList") {
              changeTab("tDeployList");
          }
      }
  }
  
  function make_selRecMulti() {

	    var otbl = document.getElementById("tblrecinfo");
	    var tbllength = otbl.rows.length;
	    //Table 지우기
	    for (var i = 0; i < tbllength - 2; i++) {
	        otbl.deleteRow(tbllength - i - 1);
	    }

	    var eTR, eTD;

	    var sRec = m_RecDept.split(";");
	    if (m_RecDept == "") return;
	    for (var i = 0; i < sRec.length; i++) {
	        if (sRec[i] != "" && sRec[i] != null) {
	            aRec = sRec[i].split(":");
	            eTR = otbl.insertRow(otbl.rows.length);
	            eTR.setAttribute("id", aRec[1]);
	            eTR.setAttribute("AN", aRec[1]); //개인배포그룹추가201111
	            eTR.setAttribute("DN", XFN_Replace(aRec[2], "^", ";")); //개인배포그룹추가201111
	            eTR.setAttribute("mType", aRec[0]);
	            eTR.setAttribute("mKind", aRec[3]);

	            $(eTR).bind("mousedown", selectDistRow);

	            var strName = aRec[2];
	            //JAL
	            if(standalone_mode) {
	                eTD = eTR.insertCell(eTR.cells.length);
	                eTD.innerHTML = strName.split('^')[0];
	                eTD.height = 20 + "px";
	            } else {
	                eTD = eTR.insertCell(eTR.cells.length); eTD.innerHTML = m_oFormEditor.getLngLabel(strName, false, "^"); eTD.height = 20 + "px";
	            }
	            
	            if (aRec[0] == "0") {
	                eTD = eTR.insertCell(eTR.cells.length);
	            } else {
	                eTD = eTR.insertCell(eTR.cells.length);
	                eTD.innerHTML = "&nbsp;";
	            }
	            
	            //삭제 버튼 추가
	            eTD = eTR.insertCell(eTR.cells.length);
	            eTD.innerHTML = "<a href='#' class='icnDel' onclick='delList(this)'>"+Common.getDic("btn_apv_delete")+"</a>";
	        }
	    }

	    return;
	}
    
	function setMultiReceiveInfo(){
    	var idx = m_oFormEditor.$("#writeTab li.on").attr('idx');
		m_oFormEditor.$('[name=MULTI_RECEIVER_TYPE]').eq(idx).val(Sendtype);
      	//배포처 관련 시작
      	var sRec0 = "";
      	var sRec1 = "";
      	var sRec2 = "";
		var tRec0 = "";
		var tRec1 = "";
		var tRec2 = "";
		var totalRecDept = "";
		if(m_oFormEditor.$('[name=MULTI_RECEIVENAMES]').eq(idx) != null){
			m_oFormEditor.$('[name=MULTI_RECEIVENAMES]').eq(idx).val(m_RecDept);
		}
		if(m_oFormMenu.document.getElementById("ReceiveNames")!=null){
			m_oFormEditor.$(".multi-row [name=MULTI_RECEIVENAMES]").each(function(idx, item){
			var type = m_oFormEditor.$(".multi-row [name=MULTI_RECEIVER_TYPE]").eq(idx).val();
			if($(item).val() != "" && type == "In"){
 		  		totalRecDept += ';' + $(item).val();
 		  	}
 	  	});
       	if (totalRecDept.indexOf(";") == 0) totalRecDept = totalRecDept.substring(1);
 	  		m_oFormMenu.document.getElementById("ReceiveNames").value = totalRecDept;
	  	}
		var aRecDept = "";
		var szReturn = "";
		if (m_RecDept != "") {
			aRecDept = m_RecDept.split(";");
			var Include = "";
			for (var i = 0; i < aRecDept.length; i++) {
		    	if (aRecDept[i] != "") {
		        	var aRec = aRecDept[i].split(":");
		        	if (aRec[0] == "0") {
			            if (sRec0 == "") sRec0 += aRec[1] + "|" + aRec[3];
			            else sRec0 += ";" + aRec[1] + "|" + aRec[3];
			        } else if (aRec[0] == "1") {
			            if (sRec1 == "") sRec1 += aRec[1];
			            else sRec1 += ";" + aRec[1];
			        } else {
			            if (sRec2 == "") sRec2 += aRec[1];
			            else sRec2 += ";" + aRec[1];
			        }
		        
			        if (aRecDept[i].split(":")[3] == "Y") {
			            Include = "(" + Common.getDic("lbl_apv_recinfo_td2") + ")";
			        }
			        szReturn += (szReturn != '' ? ", " : "") + (m_oFormEditor.getLngLabel(aRecDept[i].split(":")[2], false, "^"));// + Include;
			        Include = "";
		    	}
			}
		}
	
		if (totalRecDept != "") {
			var tRecDept = totalRecDept.split(";");
			for (var i = 0; i < tRecDept.length; i++) {
				if (tRecDept[i] != "") {
					var tRec = tRecDept[i].split(":");
					if (tRec[0] == "0") {
						if (tRec0 == "") tRec0 += tRec[1] + "|" + tRec[3];
						else tRec0 += ";" + tRec[1] + "|" + tRec[3];
						} else if (tRec[0] == "1") {
						if (tRec1 == "") tRec1 += tRec[1];
						else tRec1 += ";" + tRec[1];
					} else {
						if (tRec2 == "") tRec2 += tRec[1];
						else tRec2 += ";" + tRec[1];
					}
				}
			}
		}
		
		if(m_oFormEditor.$('[name=MULTI_RECEIPTLIST]').eq(idx) != null){
			m_oFormEditor.$('[name=MULTI_RECEIPTLIST]').eq(idx).val(sRec0 + "@" + sRec1 + "@" + sRec2);
		}
	
		if(m_oFormEditor.document.getElementById("ReceiptList") != null){
			m_oFormEditor.document.getElementById("ReceiptList").value = tRec0 + "@" + tRec1 + "@" + tRec2;
	    }
		
		if(opener.isUseHWPEditor()) {
			var isGroup = checkBankGroup(m_RecDept);
			var oMultiCtrl = opener.getMultiCtrlEditor();
		var addText = "";
			var senderText = "";
			var subSender = "";
			if(Sendtype == "In"){
				senderText = getInfo('AppInfo.dpnm') + "장"; // 발신처 표시
				if(getInfo('AppInfo.pdeptNm') != ""){
					senderText = getInfo('AppInfo.pdeptNm') + "장"; // 부가 아닌 팀일 경우 상위부서명으로 표시 (조직도 관리자에서 설정)
					subSender = "(" + getInfo('AppInfo.dpnm') + ")"; // 기안부서표시
				}
				if(aRecDept.length ==	1 && sRec0.indexOf(Common.getBaseConfig("AuditGroup")) > -1){
					addText = "";
				} else if(aRecDept.length ==	1 && Common.getBaseConfig("OwnerGroup").indexOf(sRec0.split('|')[0]) > -1){
					szReturn = "저축은행중앙회장";
				} else {
					addText = sRec1 != "" ? "" : "장"; // 수신자 표시 (부서일 경우 '장' 붙임)
				}
			} else {
				addText = " 저축은행 대표이사";
				senderText = "저축은행중앙회장";
			}
			
			if (HwpCtrl != null) {
				HwpCtrl.PutFieldText('sendername', senderText);
				HwpCtrl.PutFieldText('SubDept', subSender);
				
				if(aRecDept.length == 0){
					HwpCtrl.PutFieldText('recipient_single', "내부결재");
					HwpCtrl.PutFieldText('recipient_mul', " ");
					HwpCtrl.PutFieldText('recipient', " ");
					HwpCtrl.PutFieldText('sendername', " ");
				} else if(aRecDept.length > 1){
					HwpCtrl.PutFieldText('recipient_single', "수신자참조");
					HwpCtrl.PutFieldText('recipient', "수신자");
					if(isGroup.isGroup){
						HwpCtrl.PutFieldText('recipient_single', isGroup.ReceiveTxt + addText.trim());
						HwpCtrl.PutFieldText('recipient', " ");
						HwpCtrl.PutFieldText('recipient_mul', " ");
					} else {
						HwpCtrl.PutFieldText('recipient_mul', szReturn + addText);
					}
				} else if (aRecDept.length == 1) {
					if(szReturn != ""){
						HwpCtrl.PutFieldText('recipient_single', szReturn + addText);
					} else {
						HwpCtrl.PutFieldText('recipient_single', " ");
					}
					HwpCtrl.PutFieldText('recipient', " ");
					HwpCtrl.PutFieldText('recipient_mul', " ");
				}
			}   
		} else {
			m_oFormEditor.G_displaySpnReceiveInfoMulti(idx);
		}
		
		if(Sendtype == "In" && aRecDept.length > 0){
			if(Common.getBaseConfig("HwpSenderUse").indexOf(Common.getSession("DEPTID")) > -1){
				m_oFormEditor.$("#spanSender").show();
			}
		}
		if (openID == "L") {
			Common.Close();
		} else if (openID != "") {
			parent.Common.Close("btLine" + getInfo("FormInstanceInfo.FormInstID"));
		} else {
			window.close();
		}
	}
  
function checkBankGroup(SelList){
    var strReturn = new Object();
	var groupAll = "";
	var groupNoAll = "";
	var groupIfis = "";
	var groupNoIfis = "";
	var ReceiveTxt = "";
	
	$(BankGroupList).each(function(idx, item){
		if(this.GroupCode == "all"){
			groupAll += groupAll == "" ? this.BankCode : (";" + this.BankCode);
		} else if(this.GroupCode == "noall"){
			groupNoAll += groupNoAll == "" ? this.BankCode : (";" + this.BankCode);
		} else if(this.GroupCode == "ifisx"){
			groupIfis += groupIfis == "" ? this.BankCode : (";" + this.BankCode);
		} else if(this.GroupCode == "noifis"){
			groupNoIfis += groupNoIfis == "" ? this.BankCode : (";" + this.BankCode);
		}
	});
	
	var target = "";
	if(groupAll.split(';').length == SelList.split(';').length){
		target = groupAll;
		ReceiveTxt = "각 지부장,";
	} else if(groupNoAll.split(';').length == SelList.split(';').length){
		target = groupNoAll;
		ReceiveTxt = "";
	} else if(groupIfis.split(';').length == SelList.split(';').length){
		target = groupIfis;
		ReceiveTxt = "통합";
	} else if(groupNoIfis.split(';').length == SelList.split(';').length){
		target = groupNoIfis;
		ReceiveTxt = "미통합";
	}
	
	var sameCnt = 0;
	$(target.split(';')).each(function(tidx, titem){
		$(SelList.split(';')).each(function(sidx, sitem){
			if(titem == sitem.split(':')[1]){
				sameCnt++;
			}
		});
	});
	
	if(sameCnt == target.split(';').length && sameCnt == SelList.split(';').length){
		strReturn.isGroup = true;
		strReturn.ReceiveTxt = ReceiveTxt;
	} else {
		strReturn.isGroup = false;
		strReturn.ReceiveTxt = null;
	}
	
	return strReturn;
}

//배포처 목록 조회
function initRecListMulti() {
    if (getInfo("SchemaContext.scIPub.isUse") == "Y" && getInfo("SchemaContext.scIPub.value") != "" && getInfo("Request.templatemode") == "Write" && document.getElementById("ReceiveNames").value == "") {
        var strIPub = getInfo("SchemaContext.scIPub.value");
        document.getElementById("ReceiveNames").value = strIPub.split("||")[0];
        document.getElementById("ReceiptList").value = strIPub.split("||")[1];
    }
    var szReturn = '';
    var aRec = document.getElementById("ReceiveNames").value.split(";");
    var Include = "";
    for (var i = 0; i < aRec.length; i++) {
        if (aRec[i] != "") {
            if (aRec[i].split(":")[3] == "Y") {
                Include = "(" + Common.getDic("lbl_apv_recinfo_td2") + ")";
            }
            szReturn += (szReturn != '' ? ", " : "") + (getLngLabel(aRec[i].split(":")[2], false, "^")) + Include;
            Include = "";
        }
    }
    
    //if (szReturn != "") document.getElementById("ReceiveLine").style.display = "";
    return szReturn;
}

function ResetrecInfo(){
	$('#tblrecinfo tr:not(:first-child)').remove();
	m_RecDept = "";
}
</script>
<body>
<div class="layer_divpop ui-draggable" id="testpopup_p" style="width: 1100px; /*height: 741px;*/ z-index: 51;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
 <!-- 팝업 Contents 시작 --> 
    <!--appBox 시작 -->
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
			          <li id="btDAuditLeft" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message  code='Cache.btn_apv_dept_audit' /></li><!-- 부서 감사 -->
			          <li id="btDAudit1Left" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.btn_apv_dept_audit1' /></li><!-- 부서준법 -->
			          <li id="btDConsult" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.lbl_apv_DeptConsent' /></li><!-- 다국어:부서합의, 기능:부서합의 (순차) -->
			          <li id="btDConsult2" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.lbl_apv_DeptConsent_2' /></li><!-- 다국어:부서합의,  기능:부서합의 (병렬) -->
			          <li id="btDAssist" name="cbBTN" onclick="selectButton(this)" style="display: none;" ><spring:message code='Cache.lbl_apv_DeptAssist' /><!-- 다국어:부서협조(순차), 기능:부서협조(순차) -->
			          <li id="btDAssistPL" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.lbl_apv_DeptAssist2' /></li><!-- 다국어:부서협조(병렬), 기능:부서협조(병렬) -->
			          <li id="btReceipt" name="cbBTN" onclick="selectButton(this)" style="display: none;" ><spring:message code='Cache.btn_apv_recdept' /></li><!-- 수신처 -->
			          <li id="btPerson" name="cbBTN" onclick="selectButton(this)"><spring:message code='Cache.lbl_apv_normalapprove' /></li><!--일반결재-->
			          <li id="btPAuditLeft" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.btn_apv_person_audit' /></li><!--개인감사-->
			          <li id="btPAudit1Left" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.btn_apv_person_audit1' /></li><!--개인준법-->
			          <li id="btPConsult" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.btn_apv_consultors' /></li><!--다국어:개인합의, 기능:개인합의(순차)-->
			          <li id="btPConsult2" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.btn_apv_consultors_2' /></li><!--다국어:개인합의, 기능:개인합의(병렬) -->
			          <li id="btPAssist"  name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.lbl_apv_assist' /></li><!--다국어:개인협조(순차), 기능:반려합의(순차)-->
			          <li id="btPAssistPL"  name="cbBTN" onclick="selectButton(this)" style="display: none;" ><spring:message code='Cache.lbl_apv_assist_2' /></li><!--다국어:개인협조(병렬), 기능:반려합의(병렬)  -->
			          <li id="btCharge" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.btn_apv_charge' /></li> <!--담당자 -->
			          <li id="btPersonConfirm" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.lbl_apv_PApprConfirm' /></li><!--확인자 -->	
			          <li id="btPersonShare" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.lbl_apv_PApprShare' /></li><!--참조자 -->
			          <li id="btPlPerson" name="cbBTN" onclick="selectButton(this)" style="display: none;"><spring:message code='Cache.lbl_apv_approv_sametime' /></li>	<!--동시결재-->
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
		        </div>
		        <!--참조 관련 버튼 모음(사전참조,사후참조,참조자) 끝-->
		        
	       	</div>
	       	<!-- 결재(참조, 배포 제외 버튼) & 참조 버튼 목록 (탭영역 구분을 위해 묶음) 시작-->
	       	
	        <!--배포 관련 버튼 모음(배포추가) 시작 -->
	        <div id="divrecinfoButton">
		        <div id="dvRec" style="display: none;">
		           	<%-- <input type="button" class="btn_send" id="btRecDept" name="cbBTN" onclick="doButtonAction(this);"
		        		value="<spring:message code='Cache.btn_apv_deploy_add' />"/> --%><!--배포추가-->
		        		
		           	<input type="button" class="btn_send" id="btRecDept" name="cbBTN" onclick="addRecDeptMulti();"
		        		value="<spring:message code='Cache.btn_apv_deploy_add' />"/>
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
		          <a id="tabapvandcc" class="AXTab on" href="#ax" value="apvandcc" onclick='clickApvTab(this)' style="display:none;"><spring:message code='Cache.lbl_apv_apprvlist' /></a> <!--결재목록-->
		          <a id="tabrecinfo" class="AXTab" href="#ax"  value="divrecinfo" onclick='clickApvTab(this)' style="display:none;"><spring:message code='Cache.lbl_apv_DDistribute' /></a> <!--배포목록 -->
	          </div>
	        </div>
	        <!-- 탭메뉴 끝 -->
	        <!-- 결재자 몰  -->
	        
	        <!--결재자 & 참조자 목록 시작 (탭 영역 구분을 위해 묶음)-->
	        <div id="apvandcc">
		        <!--결재자 목록 시작-->
		        <div class="appInfo" id="divapvinfo">
		        	<div id="Apvlist" style="overflow-x:hidden;"></div><!--테이블이 추가되는 div-->
		        	<div id="ApvlistSendRight" class="btnWArea"><a href="#" class="sendRight" onclick="savePrivateDomainData()"><spring:message code='Cache.lbl_save_privatedomaindata'/></a></div><!--개인결재선으로 저장-->
		        </div>
		        <!--결재자 목록 끝 -->
		        
		        <!--참조자 목록 시작-->
		        <div class="appInfoBot" id="divccinfo" style="display: none;">
		         	<table class="tableStyle t_center hover infoTableBot" id="tblccinfo"><colgroup>
			            	<col style="width:100px">
			            	<col style="width:*">
			            	<col style="width:50px">
		            	</colgroup><thead>
		              		<tr>
		                		<td colspan="3"><h3 class="titIcn"><spring:message code='Cache.lbl_apv_ref' /></h3></td><!--참조자-->
		              		</tr>
	            		</thead></table>
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
			                		<td colspan="3">
			                			<h3 class="titIcn"><spring:message code='Cache.lbl_apv_DDistribute' /></h3>
			                			<input name="cbBTN" class="ooBtn" id="btResetrecInfo" onclick="ResetrecInfo();" type="button" style="float:right" value="배포목록 초기화">
			                		</td><!--참조자-->
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
	    <%-- <input type="button" id="btOK" name="cbBTN" onclick="doButtonAction(this);" class="ooBtn" value="<spring:message code='Cache.btn_Confirm'/>"/> --%><!--확인-->
	    <input type="button" id="btOK" name="cbBTN" onclick="setMultiReceiveInfo();" class="ooBtn" value="<spring:message code='Cache.btn_Confirm'/>"/>
	    <input type="button" id="btExit" name="cbBTN" onclick="doButtonAction(this);" class="gryBtn mr30" value="<spring:message code='Cache.btn_apv_close'/>"/><!--닫기-->
    </div>
    <!-- 하단버튼 끝 --> 
	<!--팝업 컨테이너 끝-->
</div>


<div style="height: 0px; overflow: hidden;">
	<input  ID="TextBox1" />
	<input  ID="hidType" value="D1"/>
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
