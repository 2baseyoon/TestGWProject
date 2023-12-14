<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>
			
<body>
	<input id="auditID"		type="hidden"/>
	<input id="ruleCode"	type="hidden"/>
	<div class="layer_divpop ui-draggable docPopLayer" style="width:600px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style = "width: 200px;">
							<col style = "width: auto;">
						</colgroup>
						<tbody>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_company'/>		<!-- 회사 -->
								</th>
								<td>
									<div class="box">
										<label id="companyName"></label>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_ruleName'/>		<!-- 규칙명 -->
								</th>
								<td>
									<div class="box">
										<input id="ruleName" type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS" style="width: 300px">
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_ruleDesc'/>		<!-- 규칙설명 -->
								</th>
								<td>
									<div class="box">
										<input id="ruleDescription" type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS" style="width: 300px">
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_standardType'/>			<!-- 기준유형 -->
								</th>
								<td>
									<div class="box">
										<span id="stdType" class="selectType06" style="width:150px"
											onChange="AuditPopup.changeStdType(this)">
										</span>
									</div>
								</td>
							</tr>
							<tr id="stdAmountArea" style="display:none;">
								<th>
									<spring:message code='Cache.ACC_lbl_standardValue'/>		<!-- 기준값 -->
								</th>
								<td>
									<div class="box">
										<input	id="stdValue" type="money" class="HtmlCheckXSS ScriptCheckXSS"
												onkeypress	= "return inputNumChk(event)"
												onkeydown	= "pressHan(this)"
												onkeyup	= "AuditPopup.changeStdValue(this)">
										<label id="stdValueLabel"><spring:message code='Cache.ACC_lbl_tenThousandWon'/></label>	<!-- 만원 -->
									</div>
								</td>
							</tr>
							<tr id="stdTimeArea" style="display:none;">
								<th>
									<spring:message code='Cache.ACC_lbl_standardTime'/>		<!-- 기준시간 -->
								</th>
								<td>
									<div class="box">
										<input	id="stdStartTime" type="text" class="HtmlCheckXSS ScriptCheckXSS"
												onkeypress	= "return inputNumChk(event)"
												onkeydown	= "pressHan(this)"
												style="width: 40%;"> ~ 
										<input	id="stdEndTime" type="text" class="HtmlCheckXSS ScriptCheckXSS"
												onkeypress	= "return inputNumChk(event)"
												onkeydown	= "pressHan(this)"
												style="width: 40%; float: none;">
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_standardDesc'/>		<!-- 기준설명 -->
								</th>
								<td>
									<div class="box">
										<input id="stdDescription"	type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS" style="width: 300px">
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_applicationColor'/>		<!-- 적용사항 -->
								</th>
								<td>
									<div class="box">
										<span id="applicationColor" class="selectType06" style="width:150px">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_isUse'/>		<!-- 사용여부 -->
								</th>
								<td>
									<div class="box">
										<span id="isUse" class="selectType06" style="width:150px">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_auditPoint'/>		<!-- 감사시점 -->
								</th>
								<td>
									<div class="box" id="AuditPointArea">
									</div>
								</td>
							</tr>
							<tr id="ApplicationLimitTR" style="display: none;">
								<th>
									<spring:message code='Cache.ACC_lbl_appPointLimitLevel'/>		<!-- 신청 통제수준 -->
								</th>
								<td>
									<div class="box" id="ControlLevelArea">
									</div>
								</td>
							</tr>
							<tr id="DocDisplayTR" style="display: none;">
								<th>
									<spring:message code='Cache.ACC_lbl_docDisplayLocation'/>		<!-- 문서 표시위치 -->
								</th>
								<td>
									<div class="box" id="DisplayLocationArea">
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="bottom">
					<a onclick="AuditPopup.checkValidation()"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save'/></a>	<!-- 저장 -->
					<a onclick="AuditPopup.closeLayer()"		id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>				<!-- 취소 -->
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

	if (!window.AuditPopup) {
		window.AuditPopup = {};
	}	

	(function(window) {
		
		var AuditPopup = {
				popupInit : function(){
					var me = this;
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						$("#"+paramKey).val(paramValue);
					}
					
					me.setSelectCombo();
					me.setCheckBoxArea();
					me.getPopupInfo();
				},
				
				setSelectCombo : function(){
					var AXSelectMultiArr	= [	
								{'codeGroup':'IsUse',			'target':'isUse',				'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
							,	{'codeGroup':'AuditColor',		'target':'applicationColor',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
							,	{'codeGroup':'AuditStdType',	'target':'stdType',				'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.lbl_Select' />"}
						]
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},
				
				refreshCombo : function() {
					accountCtrl.refreshAXSelect("isUse");
					accountCtrl.refreshAXSelect("applicationColor");
					accountCtrl.refreshAXSelect("stdType");
				},
				
				setCheckBoxArea : function() {
					var me = this;
					
					$.ajax({
						type:"POST",
							url:"/account/accountCommon/getBaseCodeDataAll.do",
						data:{
							codeGroups : "AuditPoint,ControlLevel,DisplayLocation"
						},
						async: false,
						success:function (data) {
							if(data.result == "ok"){
								me.makeCheckBoxHtml(data.list.AuditPoint, "AuditPointArea");
								me.makeRadioBtnHtml(data.list.ControlLevel, "ControlLevelArea");
								me.makeCheckBoxHtml(data.list.DisplayLocation, "DisplayLocationArea");
							}
							else{
								Common.Error(data);
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				makeCheckBoxHtml : function(codeList, targetArea) {
					var sHtml = "";
					for(var i = 0; i < codeList.length; i++) {
						var obj = codeList[i];
						
						var onchange = "";
						if(obj.CodeGroup == "AuditPoint") {
							onchange = "onchange='AuditPopup.ToggleCheckBox(this);'";
						}
						
						sHtml += "<label style='margin-right: 10px;' for='"+obj.Code+"'>";
						sHtml += "<input type='checkbox' id='"+obj.Code+"' value='"+obj.Code+"' name='"+obj.CodeGroup+"' "+onchange+"> "+obj.CodeName+"</label>";
					}
					
					$("#"+targetArea).html(sHtml);
				},
				
				makeRadioBtnHtml : function(codeList, targetArea) {
					var sHtml = "";
					for(var i = 0; i < codeList.length; i++) {
						var obj = codeList[i];
												
						sHtml += "<label style='margin-right: 10px;' for='"+obj.Code+"'>";
						sHtml += "<input type='radio' id='"+obj.Code+"' value='"+obj.Code+"' name='"+obj.CodeGroup+"'> "+obj.CodeName+"</label>";
					}
					
					$("#"+targetArea).html(sHtml);
				},
				
				ToggleCheckBox : function(chkObj) {
					if($("#"+$(chkObj).val()+"TR").length > 0) {
						if($(chkObj).prop("checked")) { 
							$("#"+$(chkObj).val()+"TR").show(); 
						} else {
							$("#"+$(chkObj).val()+"TR").hide();
						}
					}
				},
				
				getPopupInfo : function(){
					var me = this;
					
					var auditID	= $("#auditID").val();
					
					$.ajax({
						url	:"/account/audit/getAuditDetail.do",
						type:"POST",
						data:{
								"auditID" : auditID
						},
						async:false,
						cache:false,
						success:function (data) {
							if(data.result == "ok"){
								var info = data.list[0];
								
								$("#companyName").text(info.CompanyName);
								$("#ruleName").val(info.RuleName);
								$("#ruleDescription").val(info.RuleDescription);
								$("#stdDescription").val(info.StdDescription);
								$("#stdValue").val(getAmountValue(info.StdValue));
								$("#stdStartTime").val(info.StdStartTime);
								$("#stdEndTime").val(info.StdEndTime);
								
								accountCtrl.getComboInfo("stdType").bindSelectSetValue(info.StdType);
								accountCtrl.getComboInfo("applicationColor").bindSelectSetValue(info.ApplicationColor);
								accountCtrl.getComboInfo("isUse").bindSelectSetValue(info.IsUse);
								
								var ruleInfo = info.RuleInfo;
								if(ruleInfo != null && ruleInfo != "") {
									if(ruleInfo.AuditPoint != null) {
										for(var i = 0; i < ruleInfo.AuditPoint.length; i++) {
											$("input[name=AuditPoint][id="+ruleInfo.AuditPoint[i]+"]").prop("checked", "checked").trigger('change');
										}
									}
									if(ruleInfo.ControlLevel != null) {
										for(var i = 0; i < ruleInfo.ControlLevel.length; i++) {
											$("input:radio[name=ControlLevel][value='"+ruleInfo.ControlLevel[i]+"']").prop("checked", true);
										}
									}
									if(ruleInfo.DisplayLocation != null) {
										for(var i = 0; i < ruleInfo.DisplayLocation.length; i++) {
											$("input[name=DisplayLocation][id="+ruleInfo.DisplayLocation[i]+"]").prop("checked", "checked");
										}
									}
								}
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				checkValidation : function(){
				    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				    
					var ruleCode			= $("#ruleCode").val();
					var auditID				= $("#auditID").val();
					var stdType				= accountCtrl.getComboInfo("stdType").val();
					var stdValue			= getNumOnly(nullToBlank($("#stdValue").val()));
					var stdStartTime		= nullToBlank($("#stdStartTime").val());
					var stdEndTime			= nullToBlank($("#stdEndTime").val());
					var stdDescription		= nullToBlank($("#stdDescription").val());
					var applicationColor	= accountCtrl.getComboInfo("applicationColor").val();
					var isUse				= accountCtrl.getComboInfo("isUse").val();
					
					var chkVal = "";
					if(stdType	== "A"){
						chkVal = stdValue;
						stdDescription = getAmountValue(stdValue) + "<spring:message code='Cache.ACC_lbl_tenThousandWon' />"; //만원
					} else if(stdType == "T") {
						chkVal = stdStartTime;
						stdDescription = stdStartTime + "<spring:message code='Cache.lbl_Hour' />" + " ~ " + stdEndTime + "<spring:message code='Cache.lbl_Hour' />"; //시
					} else{
						chkVal = stdDescription;
					}
					
					if(chkVal == ""){
						Common.Inform("<spring:message code='Cache.ACC_msg_noStandard' />");		//기준을 입력해주세요.
						return;
					}
					
					var ruleInfo = {};
					var arr = [];
					for(var i = 0; i < $("input[name=AuditPoint]").length; i++) {
					    if($("input[name=AuditPoint]").eq(i).is(":checked")) {
					        arr.push($("input[name=AuditPoint]").eq(i).val());
					    }
					}
					ruleInfo.AuditPoint = arr;
					
					if($("#ApplicationLimitTR").css("display") != "none") {
						arr = [];
						if($("input[name=ControlLevel]:checked").val() != undefined && $("input[name=ControlLevel]:checked").val() != "") {
							arr.push($("input[name=ControlLevel]:checked").val());
						}
						
						ruleInfo.ControlLevel = arr;
					}

					if($("#DocDisplayTR").css("display") != "none") {
						arr = [];
						for(var i = 0; i < $("input[name=DisplayLocation]").length; i++) {
						    if($("input[name=DisplayLocation]").eq(i).is(":checked")) {
						        arr.push($("input[name=DisplayLocation]").eq(i).val());
						    }
						}
						ruleInfo.DisplayLocation = arr;
					}
					
					$.ajax({
						url	: "/account/audit/saveAuditInfo.do",
						type: "POST",
						data: {	"auditID"			: auditID
							,	"stdType"			: stdType
							,	"stdValue"			: stdValue
							,	"stdStartTime"		: stdStartTime
							,	"stdEndTime"		: stdEndTime
							,	"stdDescription"	: stdDescription
							,	"applicationColor"	: applicationColor
							,	"isUse"				: isUse
							,	"ruleInfo"			: JSON.stringify(ruleInfo)
							,	"popupYN"			: 'Y'
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
								
								AuditPopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
								
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // error.message
						}
					});
				},
				
				changeStdValue : function(obj){
					obj.value = getAmountValue(obj.value);
				},
				
				changeStdType : function(obj) {
					var me = this;
					var stdType = obj.value;
					
					if(stdType == "A") {
						$("#stdAmountArea").show();
						$("#stdTimeArea").hide();
					} else if(stdType == "T") {
						$("#stdAmountArea").hide();
						$("#stdTimeArea").show();
					} else {
						$("#stdAmountArea").hide();
						$("#stdTimeArea").hide();
					}
					
					me.refreshCombo();
				},
				
				closeLayer : function(){
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				}
		}
		window.AuditPopup = AuditPopup;
	})(window);
	
	AuditPopup.popupInit();
	
</script>