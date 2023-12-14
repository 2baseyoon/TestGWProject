<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<html>
<head>
<title>전결규정 관리</title>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style type="text/css">
#tableDiv {
    padding-top: 10px;
    padding-right: 20px;
    padding-bottom: 10px;
    padding-left: 20px;
}
#tableDiv .tableStyle thead td {
    height: 40px;
    border-bottom: 1px solid #d2d7de;
    font-size: 13px;
    font-weight: bold;
    color: #000;
    background: #f1f6f9;
}
#tableDiv .linePlus thead tr td {
    border-top: 1px solid #c3d7df;
    border-bottom: 1px solid #c3d7df;
}
#tableDiv .tableStyle thead tr:last-child td, #tableDiv .tableStyle thead tr:last-child th {
    border-bottom: 1px solid #c3d7df;
}
#tableDiv .tableStyle tbody tr th {
	text-align: left;
	padding-left: 5px;
}
#tableDiv .tableStyle tbody td {
    color: #000;
    border-bottom: 1px solid #c3d7df;
    padding: 5px;
    height: 20px;
    text-align: center;
}
</style>
<script type="text/javascript">
	var parent = top.opener;
	var result = new Object();
	
	$(document).ready(function() {
		init();		// 초기화
	});

	// 초기화
	function init() {
		var ruleItemList = parent.getInfo("RuleInfo") ? parent.getInfo("RuleInfo") : parent.getInfo("ExtInfo.RuleItemLists");
		
		if (typeof(ruleItemList) != "undefined") {
			ruleItemList = $.parseJSON(ruleItemList);
			var len = ruleItemList.length;
			var paramArr = new Array();
			
			if (len > 0) {
				for (var i=0; i<len; i++) {
					Array.prototype.push.apply(paramArr, ruleItemList[i].ruleitem);
				}
				
				$.ajax({
					type:"POST",
					data:{
						"paramArr" : paramArr
					},
					url:"manage/getApvRuleList.do",
					success:function (data) {
						if (data.result == "ok") {
							result = $.extend({}, data.list);
							var list = filterData(data.list);		// 최상위 삭제
							var len = list.length; 
							var cnt = 0;
							if(len>0) cnt = typeof(list[0].CNT) == "undefined" ? 1 : list[0].CNT;
							
							$("#tableDiv").empty();
							
							var html = "<table class='tableStyle linePlus mt10'>";
							html += "<thead>";
							html += "<tr>";
							html += "<th style='width:25%'><spring:message code='Cache.lbl_apv_gubun'/></th>"; //구분
							html += "<th style='width:9%'><spring:message code='Cache.lbl_apv_writer'/></th>"; //기안자
							html += "<th style='width:9%'><spring:message code='Cache.btn_apv_CReference'/></th>"; //사전참조
							html += "<th style='width:40%' colspan=\"" + cnt + "\"><spring:message code='Cache.lbl_apv_rule02'/></th>"; //합의자/결재자
							html += "<th style='width:9%'><spring:message code='Cache.btn_apv_AReference'/></th>"; //사후참조
							html += "<th style='width:8%'><spring:message code='Cache.lbl_apv_note'/></th>"; //비고
							html += "</tr>";
							html += "</thead>";
							for (var i=0; i<len; i++) {
								if (list[i].PATH != "") {									
									html += "<tr>";
									
									html += "<th>";
									html += "<div>";
									html += "<input type='radio' id='itemRadio_" + i + "' name='itemRadio' value=\"" + list[i].ItemCode + "\" style=\"cursor: pointer;\" />";
									html += "<input type='hidden' name='itemId' value=\"" + list[i].ItemID + "\" />";
									html += "<label for=\"itemRadio_" + i + "\" style=\"cursor: pointer;\">" + list[i].PATH + "</label>";
									html += "</div>";
									html += "</th>";
									
									// 기안자
									if (typeof(list[i].draftNm) != "undefined") {
										html += "<td>" + list[i].draftNm + "</td>";
									} else {
										html += "<td></td>";
									}
									
									var ccStrArr = new Array();
									var ccBfStrArr = new Array();
									var apvStrArr = new Array();
									
									if (typeof(list[i].ApvNames) != "undefined") {
										var apvArr = list[i].ApvNames.split(',');

										$.each(apvArr, function(i, v) {
											var arr = v.split('|');
											// arr[0](ApvType), arr[1](RuleID), arr[2](ApvName), arr[3](Sort)
											
											if(arr.length > 1){
												if (arr[0] == "ccinfo") {
													ccStrArr.push(arr[2]);
												} else if(arr[0] == "ccinfo-before") {
													ccBfStrArr.push(arr[2]);
												} else if(!(arr[0] == "initiator")){ //  && arr[3] == 0
													apvStrArr.push(arr[2]);
												}
											}
										});

										// 사전참조
										html += "<td>" + ccBfStrArr + "</td>";

										// 합의자/결재자
										for (var j=0; j<apvStrArr.length; j++) {
											html += "<td>" + apvStrArr[j] + "</td>";	
										}

										// 합의자/결재자가 없거나 최대치보다 적을 경우 빈값으로 추가하기 위해
										for (var j=0; j<(cnt-apvStrArr.length); j++) {
											html += "<td></td>";
										}
									} else {
										for (var j=0; j<cnt; j++) {
											html += "<td></td>";
										}
									}
									
									// 사후참조
									html += "<td>" + ccStrArr + "</td>";
									
									// 비고
									if(list[i].MaxAmount && list[i].MaxAmount.split(".")[0] != "0") {
										html += "<td>" + " ~" + CFN_AddComma(list[i].MaxAmount.split(".")[0]) + " " + Common.getDic("lbl_below") + "</td>";
									} else if (list[i].ItemDesc) {
										html += "<td>" + list[i].ItemDesc + "</td>";
									} else {
										html += "<td></td>";
									}
									html += "</tr>";
								}
							}
								
							html += "</table>";
							$("#tableDiv").append(html);
							
							if (len > 0) {
								$("#itemRadio_0").prop("checked", true);
							}
							
							if (len == 1) {
								//applyClick();
							}
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("manage/getApvRuleList.do", response, status, error);
					}
				});
			}
		}
	}
	
	// 최상위 삭제
	function filterData(list) {
		$.each(list, function(i, v) {
			var splitPath = v.PATH.split('>');
			splitPath.splice(0,1);
			v.PATH = splitPath.join(">");
		});
		
		return list;
	}
	
	// 적용 버튼
 	function applyClick() {
 		var sessionObj = Common.getSession(); //전체호출	
		//var itemId = $(':radio[name="itemRadio"]:checked').val();
		var itemCode = $(':radio[name="itemRadio"]:checked').val();
		var itemId = $(':radio[name="itemRadio"]:checked').siblings('[type="hidden"][name="itemId"]').val();
		var chargeJob = ""; // 전결규정에서 변경한 담당업무 정보
		// 선택 아이템 체크
		if (typeof(itemCode) == "undefined") {
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem'/>");  // 선택된 항목이 없습니다.
			return;
		}
		
		// 합의, 협조 자리 체크
		var lastItem = "";
		$.each(result, function(i, v) {
			if (v.ItemCode == itemCode && v.ApvNames != null) {
				var itemArr = v.ApvNames.split(',');
				var remTar = new Array();
				$.each(itemArr, function(i, v) {
					var arr = v.split("|");
					if ((arr[0] == "initiator" && arr[3] == 0) || arr[0].indexOf("ccinfo") > -1) {
						remTar.push(i);
					}
				});
				for (var i = remTar.length -1; i >= 0; i--) {
					itemArr.splice(remTar[i],1);
				}
				
				if(itemArr.length > 0) {
					lastItem = itemArr[itemArr.length-1].split('|')[0];
				}
			}
		});

		var m_oApvList = "";
		if(Common.getBaseConfig("RuleBtnApvMgr") == "Y" && parent.location.href.indexOf("approvalline") > -1) {
			m_oApvList = parent.m_oApvList;
		} else {
			m_oApvList = $.parseJSON(parent.document.getElementById("APVLIST").value);
		}
		 		
 		var oAppList;
 		oAppList = $$(m_oApvList).find("steps > division > step").concat();
 		for (var i = 0; i < $$(oAppList).length; i++) {
            var oChkNode; 
            oChkNode = $$(oAppList).has("ou > person > taskinfo[kind!='charge']");
            if (oChkNode.length > 0) {
                $$(oChkNode).remove();
            }
            oChkNode = $$(oAppList).has("ou > role > taskinfo[kind!='charge']");
            if (oChkNode.length > 0) {
                $$(oChkNode).remove();
            }
            oChkNode = $$(oAppList).has("ou").not("person"); // 부서합의/협조 등 부서류 step 삭제
            if (oChkNode.length > 0) {
                $$(oChkNode).remove();
            }
        }
 		oAppList = $$(m_oApvList).find("steps").concat();
 		for (var i = 0; i < $$(oAppList).length; i++) {
            var oChkNode = $$(oAppList).find("ccinfo");
            if (oChkNode.length > 0) {
                $$(oChkNode).remove();
            }
        }
 		oAppList = $$(m_oApvList).find("steps > division").concat();
 		for (var i = 0; i < $$(oAppList).length; i++) {
            var oChkNode = $$(oAppList).find("[divisiontype='receive']");
            if (oChkNode.length > 0) {
                $$(oChkNode).remove();
            }
        }
        
		$.ajax({
			type:"POST",
			data:{
				"itemCode" : itemCode,
				"grCode" : sessionObj["DEPTID"]
			},
			async:false,
			url:"admin/getApvRuleListForForm.do",
			success:function (data) {
				if(data.result == "ok") {
					var list = data.list;
					var nLength = list.length;

					// 겸직 중복 제거 - 역순으로 체크 // 결재타입(결재/합의/참조..) 체크
					data.list.reverse();
					var sUserList = "";
					for (var i = 0; i < nLength; i++) {
						if(list[i].ObjectType == "person" && list[i].ObjectCode == parent.getInfo("AppInfo.usid")){ // 기안자와 동일한사용자는 모두 제거
							delete list[i];
							continue;
						}
						if (sUserList == "") {
							if ((list[i].ObjectCode != null) &&
								(list[i].ObjectCode != "")) {
								sUserList = ";" +list[i].ApvType+ list[i].ObjectCode + ";";
							}
							continue;
						}

						if ((list[i].ObjectCode != null && list[i].ApvType != null) &&
							(list[i].ObjectCode != "" && list[i].ApvType != "" )) {
							if (sUserList.indexOf(";" + list[i].ApvType + list[i].ObjectCode + ";") >= 0) {
								delete list[i];
								continue;
							}
							else {
								//sUserList = ";" + list[i].ApvType+ list[i].ObjectCode + ";"; // 연속되는 경우에만 중복제거
								sUserList += ";" + list[i].ApvType+ list[i].ObjectCode + ";"; // 연속되지 않은 경우에도 중복 제거
							}
						}
					}
					data.list.reverse();
					
					var len = list.length;
					for (var i = 0; i < nLength; i++) {
						if (list[i] == null) {
							continue;
						}
						var sApvType = list[i].ApvType;
						var sStep_UnitType = list[i].ObjectType;
						var sStep_Name = "";
						var sStep_RouteType = "";
						var sStep_AllotType = "";
						var sTaskinfo_Kind = "";
						
                        switch (sApvType) {
                        case "approve":
                            sStep_Name = "<spring:message code='Cache.lbl_apv_normalapprove'/>";
                            sStep_RouteType = "approve";
                            sTaskinfo_Kind = "normal";
                            break;
                        case "assist":
                            sStep_Name = "<spring:message code='Cache.lbl_apv_assist'/>";
                            sStep_RouteType = "assist";
                            sTaskinfo_Kind = "normal";
                            sStep_AllotType = "serial";
                            break;
                        case "assist-parallel":
                            sStep_Name = "<spring:message code='Cache.lbl_apv_assist'/>";
                            sStep_RouteType = "assist";
                            sTaskinfo_Kind = "normal";
                            sStep_AllotType = "parallel";
                            break;
                        case "consult":
                            sStep_Name = "<spring:message code='Cache.lbl_apv_consent'/>";
                            sStep_RouteType = "consult";
                            sTaskinfo_Kind = "consult";
                            sStep_AllotType = "serial";
                            break;
                        case "consult-parallel":
                            sStep_Name = "<spring:message code='Cache.lbl_apv_consent'/>";
                            sStep_RouteType = "consult";
                            sTaskinfo_Kind = "consult";
                            sStep_AllotType = "parallel";
                            break;
                        case "receive":
                        	if(sStep_UnitType != "role"){
                            	sStep_Name = "<spring:message code='Cache.lbl_apv_normalapprove'/>";
                        	}else{
                        		//sStep_Name = "<spring:message code='Cache.lbl_apv_charge_approve'/>";
                        		chargeJob = chargeJob + (chargeJob == "" ? "" : "^") + list[i].grCode + "@" + list[i].grName; // 전결규정에서 변경한 담당업무 정보
                        		continue;
                        	}
                            sStep_RouteType = "receive";
                            sTaskinfo_Kind = "charge";
                            break;
                        case "ccinfo":
                        case "ccinfo-before":
                            break;
                    	}
                        
                        if (sApvType.indexOf("ccinfo") < 0) {
                        	var oDivision = {};
                        	
                        	if (sApvType == "receive") {
                            	//division //수신일때만 새로 만듬.
                                $$(m_oApvList).find("steps").append("division", oDivision);
                                $$(oDivision).attr("name", "<spring:message code='Cache.lbl_apv_charge_approve'/>");
                                $$(oDivision).attr("divisiontype", "receive");
                                
                                if(sStep_UnitType != "role"){
                                	$$(oDivision).attr("ouname", sStep_UnitType == "person"? list[i].UR_Name : list[i].grName);
                                    $$(oDivision).attr("oucode", sStep_UnitType == "person" ? list[i].UR_Code : list[i].grCode);	
                                }
                                
                                var oDivisionTaskinto = {};
                                $$(oDivision).append("taskinfo", oDivisionTaskinto);
                                $$(oDivisionTaskinto).attr("kind", "receive");
                                $$(oDivisionTaskinto).attr("status", "inactive");
                                $$(oDivisionTaskinto).attr("result", "inactive");
                            }

                          	//step
                          	var oStep = {};
                            var bStep = true;
                            
                            if (sStep_AllotType == "parallel" && i > 0) {
                            	var nIndex = i - 1;
                            	while (list[nIndex] == null) {
                            		nIndex--;
                            		if (nIndex < 0) {
                            			break;
                            		}
                            	}
                            	if (nIndex >= 0)
                            	{
                            		var apvType = list[nIndex].ApvType;
                                    if (apvType.indexOf("parallel") > -1 && apvType.indexOf(sStep_RouteType) > -1) {
                                        oStep = $$(m_oApvList).find("division[divisiontype='send'] > step[routetype="+sStep_RouteType+"][allottype='parallel']");
                                        bStep = false;
                                    }
                            	}
                            }

                            if (bStep) {
                            	if (sApvType == "receive") {
                                	$$(oDivision).append("step", oStep);
                                } else {
                                	$$(m_oApvList).find("division[divisiontype='send']").append("step", oStep);
                                }
                                
                                $$(oStep).attr("unittype", sStep_UnitType);
                                $$(oStep).attr("routetype", sStep_RouteType);
                                if (sStep_AllotType != "") {
                                	$$(oStep).attr("allottype", sStep_AllotType);
                                }
                                $$(oStep).attr("name", sStep_Name);
                                
                                var oTaskinto = {};
                                if (sStep_RouteType == "consult" || sStep_RouteType == "assist") {
                                	$$(oStep).append("taskinfo", oTaskinto);
                                    $$(oTaskinto).attr("status", "inactive");
                                    $$(oTaskinto).attr("result", "inactive");
                                    $$(oTaskinto).attr("kind", sTaskinfo_Kind);
                                }

                                if (list[i].ApvClass != null) {
                                    $$(oStep).attr("ruleapvclass", list[i].ApvClass);
                                }
                                if (list[i].ApvClassAtt01 != null) {
                                    $$(oStep).attr("ruleapvclassatt01", list[i].ApvClassAtt01);
                                }
                            }
                            
                          	//ou
                          	var oOu = {};
                          	if (sStep_AllotType == "parallel" && (sStep_RouteType == "consult" || sStep_RouteType == "assist")) {
                          		//병렬 합의/협조가 한 결재선에 두 번 이상 나올 경우 두 개의 step에 모두 추가되는 현상 방지
                                $$($$(oStep).pack.jsoner[$$(oStep).length-1].json).append("ou", oOu);
                          	} else {
                                $$(oStep).append("ou", oOu);
                          	}
                            $$(oOu).attr("code", list[i].grCode);
                            $$(oOu).attr("name", list[i].grName);

                            if (sStep_UnitType == "person") {
                            	var oPerson = {};
                            	$$(oOu).append("person", oPerson);
                                $$(oPerson).attr("code", list[i].UR_Code);
                                $$(oPerson).attr("name", list[i].UR_Name);
                                
                                $$(oPerson).attr("position", list[i].JobPositionCode + ";" + list[i].JobPositionName);
                                $$(oPerson).attr("title", list[i].JobTitleCode + ";" + list[i].JobTitleName);
                                $$(oPerson).attr("level", list[i].JobLevelCode + ";" + list[i].JobLevelName);

                                $$(oPerson).attr("oucode", list[i].grCode);
                                $$(oPerson).attr("ouname", list[i].grName);

                                $$(oPerson).attr("sipaddress", list[i].ExternalMailAddress);

                                var oTaskinto = {};
                                $$(oPerson).append("taskinfo", oTaskinto);
                                $$(oTaskinto).attr("status", "inactive");
                                $$(oTaskinto).attr("result", "inactive");
                                $$(oTaskinto).attr("kind", sTaskinfo_Kind);
                            }
                            else if (sStep_UnitType == "role") {
                            	var oPerson = {};
                            	$$(oOu).append("role", oPerson);
                            	$$(oPerson).attr("code", list[i].grCode);
                            	$$(oPerson).attr("name", list[i].grName);

                            	$$(oPerson).attr("oucode", list[i].grCode);
                            	$$(oPerson).attr("ouname", list[i].grName);

                                var oTaskinto = {};
                                $$(oPerson).append("taskinfo", oTaskinto);
                                $$(oTaskinto).attr("kind", sTaskinfo_Kind);
                                $$(oTaskinto).attr("status", "pending");
                                $$(oTaskinto).attr("result", "pending");
                            }
                            else {
                            	var oTaskinto = {};
                            	$$(oOu).append("taskinfo", oTaskinto);
                                $$(oTaskinto).attr("kind", sTaskinfo_Kind);
                                $$(oTaskinto).attr("status", "inactive");
                                $$(oTaskinto).attr("result", "inactive");
                            }
                        }
                        else {
                            //ccinfo
                            var oCcinfo = {};
                            $$(m_oApvList).find("steps").append("ccinfo", oCcinfo)
                            $$(oCcinfo).attr("belongto", "sender");
                            if(sApvType == "ccinfo-before") {
                            	$$(oCcinfo).attr("beforecc", "y");
                            }
                            $$(oCcinfo).attr("datereceived", "");
                            $$(oCcinfo).attr("senderid", sessionObj["UR_Code"]);
                            $$(oCcinfo).attr("sendername", sessionObj["UR_MultiName"]);

                            //ou
                            var oOu = {};
                            $$(oCcinfo).append("ou", oOu);
                            $$(oOu).attr("code", list[i].grCode);
                            $$(oOu).attr("name", list[i].grName);

                            if (sStep_UnitType == "person") {
                            	var oPerson = {};
                            	$$(oOu).append("person", oPerson);
                                $$(oPerson).attr("code", list[i].UR_Code);
                                $$(oPerson).attr("name", list[i].UR_Name);

                                $$(oPerson).attr("title", list[i].JobTitleCode + ";" + list[i].JobTitleName);
                                $$(oPerson).attr("position", list[i].JobPositionCode + ";" + list[i].JobPositionName);
                                $$(oPerson).attr("level", list[i].JobLevelCode + ";" + list[i].JobLevelName);
                                $$(oPerson).attr("level", list[i].JobLevelCode + ";" + list[i].JobLevelName);
                                $$(oPerson).attr("sipaddress", list[i].ExternalMailAddress);

                                $$(oPerson).attr("oucode", list[i].grCode);
                                $$(oPerson).attr("ouname", list[i].grName);
                            }
                        }
					}
					
					if(Common.getBaseConfig("RuleBtnApvMgr") == "Y" && parent.location.href.indexOf("approvalline") > -1) {
						parent.m_oApvList = m_oApvList;
				        parent.$$_m_oApvList = $$(parent.m_oApvList);
				        parent.document.getElementById("Apvlist").innerHTML = "";
				        parent.chargeJob = chargeJob; // 전결규정에서 변경한 담당업무 정보
						parent.refreshList();
						parent.refreshCC(true);
						parent.refreshRule(true, itemId);
					} else {
						parent.document.getElementById("APVLIST").value = JSON.stringify(m_oApvList);
						// 전결규정에서 변경한 담당업무 정보
						if(parent.setChargeJob) parent.setChargeJob(chargeJob); //$("#RuleChargeJob", parent.document).val(chargeJob);
						
						var ApvLines = parent.__setInlineApvList(m_oApvList);
						if(parent.drawFormApvLinesAll){
							parent.drawFormApvLinesAll(ApvLines);
						}
					}
			        
					var standStr = ["assist","assist-parallel","consult","consult-parallel"];
					if (standStr.indexOf(lastItem) > -1) {
						Common.Warning("<spring:message code='Cache.msg_apv_setFormRuleErrorMsg'/>", "Warning", function(){
							closeLayer();
						});
					}else{
						closeLayer();	// 팝업 닫기
					}
		            
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("admin/getApvRuleListForForm.do", response, status, error);
			}
		});   
	}

	// 팝업 닫기
	function closeLayer() {
		Common.Close();
	}
</script>
</head>
<body>
<form>
	<div class="layer_divpop ui-draggable">
		<div class="divpop_contents">
		    <div class="pop_header" id="testpopup_ph">
		      <h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico"><spring:message code="Cache.apv_btn_rule"/></span></h4>
		    </div>	
			<div id="tableDiv">
			</div>
			<div align="center" style="padding-top: 10px;padding-bottom: 20px">
				<input type="button" value="<spring:message code='Cache.btn_Apply'/>" onclick="applyClick();" class="ooBtn" />
				<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="closeLayer();"  class="owBtn" />
			</div>
		</div>
	</div>
</form>
</body>
</html>
