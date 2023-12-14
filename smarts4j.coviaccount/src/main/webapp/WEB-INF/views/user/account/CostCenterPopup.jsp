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
	<input id="mode"			type="hidden" />
	<input id="type"			type="hidden" />
	<input id="costCenterID"	type="hidden" />
	<input id="saveProperty" 	type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" id="costCenterPopup" style="width:620px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
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
									<spring:message code="Cache.ACC_lbl_company"/> <!-- 회사 -->
									<span class="star"></span>
								</th>
								<td>
									<div id="companyCodeArea" class="box">
										<span id="companyCode" class="selectType02">
										</span>
									</div>
									<div id="companyCodeTxtArea" style="display:none" class="box">
										<input id="companyCodeTxt" type="text" disabled="true">
										<input id="companyCodeHidden" type="hidden">
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code="Cache.ACC_lbl_costCenterType"/>	<!-- costCenter구분 -->
									<span class="star"></span>
								</th>
								<td>
									<div id="costCenterTypeArea"	class="box">
										<span id="costCenterType" onchange="CostCenterPopup.costCenterTypeChange()"	class="selectType02">
										</span>
									</div>
									<div id="costCenterTypeTxtArea"	class="box"	style="display:none">
										<input id="costCenterTypeTxt" type="text" disabled="true">
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code="Cache.ACC_lbl_costCenterCode"/>	<!-- CostCenter코드 -->
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input id="costCenterCode" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code="Cache.ACC_lbl_costCenterName"/>	<!-- CostCenter명 -->
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input id="costCenterName" type="text" placeholder class="HtmlCheckXSS ScriptCheckXSS">
										<a id="costCenterNameSearchBtn" class="btnTypeDefault btnResInfo" onclick="CostCenterPopup.costCenterNameSearch()">찾기</a>
									</div>
								</td>
							</tr>
							<tr id="nameCodeArea">
								<th>
									<spring:message code="Cache.ACC_lbl_projectCode"/>	<!-- 프로젝트 코드 -->
								</th>
								<td>
									<div class="box">
										<input id="nameCode" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code="Cache.ACC_lbl_isUse"/>	<!-- 사용여부 -->
								</th>
								<td>
									<div class="box">
										<span id="isUse" class="selectType02">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code="Cache.ACC_lbl_usePeriod"/>	<!-- 사용기간 -->
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<span id="usePeriod" class="dateSel type02">
										</span>
										<span class="chkStyle04 valign">
											<input type="checkbox" id="isPermanent" onchange="CostCenterPopup.changeChkForever()">
											<label for="isPermanent">
												<span></span>
												<spring:message code="Cache.ACC_lbl_permanentUse"/>
											</label>
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code="Cache.ACC_lbl_description"/>	<!-- 비고 -->
								</th>
								<td>
									<div class="box" style="width: 100%;">
										<textarea rows="5" style="width: 90%" id="description" name="<spring:message code="Cache.ACC_lbl_description"/>" class="AXTextarea av-required HtmlCheckXSS ScriptCheckXSS"></textarea>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="bottom">
					<a onclick="CostCenterPopup.checkValidation()"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code="Cache.ACC_btn_save"/></a>
					<a onclick="CostCenterPopup.closeLayer()"		id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

	if (!window.CostCenterPopup) {
		window.CostCenterPopup = {};
	}	

	(function(window) {
		
		var CostCenterPopup = {
				popupInit : function(){
					var me = this;
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						$("#"+paramKey).val(paramValue);
					}
					
					me.costCenterTypeChangeInit();
					me.pageDatepicker();
					me.setSelectCombo();
					me.setPopupEdit();
					me.getPopupInfo();
					
					$("#companyCode").attr("onchange", "CostCenterPopup.changeCompanyCode()");
				},
				
				setPopupEdit : function(){
					var me = this;
					var mode			= $("#mode").val();
					var costCenterID	= $("#costCenterID").val();
					var saveProperty  	= $("#saveProperty").val();
					me.changeChkForever();
					$("#costCenterCode").attr("disabled", true);
					
					if(saveProperty == 'N'){
						$("#costCenterCode").attr("disabled", false);
						
					}
					
					if (mode == 'modify') {
						$("#costCenterCode").attr("disabled",	true);
						$("#costCenterName").attr("disabled",	true);
						$("#nameCode").attr("disabled",			true);
						$('#isPermanent').attr('disabled',		true);
						
						$('#companyCodeArea').css("display",		"none");
						$('#costCenterTypeArea').css("display",		"none");

						$('#companyCodeTxtArea').css("display",		"");
						$('#costCenterTypeTxtArea').css("display",	"");
					}
				},
				
				pageDatepicker : function(){
					var mode = $("#mode").val();
					var disabledTF = false;
					if(mode == 'modify'){
						disabledTF = true;
					}else{
						disabledTF = false;
					}
					
					makeDatepicker('usePeriod','usePeriodStartN','usePeriodFinishN','','','',disabledTF);
				},
				
				setSelectCombo : function(pCompanyCode){
					$("#costCenterType").children().remove();
					$("#isUse").children().remove();
					
					$("#costCenterType").addClass("selectType02").attr("onchange", "CostCenterPopup.costCenterTypeChange()");
					$("#isUse").addClass("selectType02");
					
					var AXSelectMultiArr = [	
								{'codeGroup':'IsUse',			'target':'isUse',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
							,	{'codeGroup':'CostCenterGubun',	'target':'costCenterType',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
							,	{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
	                   	];
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop();
					}
					
               		accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("companyCode").val());
				},
				
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("isUse");
					accountCtrl.refreshAXSelect("costCenterType");
					accountCtrl.refreshAXSelect("companyCode");
				},
				
				getPopupInfo : function(){
					var costCenterID	= $("#costCenterID").val();
					var saveProperty 	= $("#saveProperty").val();
					var companyCode		= $("#companyCode").val(); 
					$.ajax({
						url	:"/account/costCenter/getCostCenterDetail.do",
						type: "POST",
						data: {
								"costCenterID"	: costCenterID,
								"companyCode"	: companyCode
						},
						async: false,
						success:function (data) {
							if(data.result == "ok"){
								var info = data.list[0];
								var mode = $("#mode").val();
								if(saveProperty == 'Y'){
									$("#costCenterCode").val(info.CostCenterCode);
								}
								if(mode == 'modify'){
									$("#costCenterCode").val(info.CostCenterCode);
									$("#costCenterID").val(info.CostCenterID);
									accountCtrl.getComboInfo("costCenterType").bindSelectSetValue(info.CostCenterType);
									$("#costCenterName").val(info.CostCenterName);
									$("#nameCode").val(info.NameCode);
									accountCtrl.getComboInfo("isUse").bindSelectSetValue(info.IsUse);
									$("#usePeriodStartN").val(info.UsePeriodStart);
									$("#usePeriodFinishN").val(info.UsePeriodFinish);
									$("#description").val(info.Description);
									$("#isPermanent").attr("checked", info.IsPermanent == "Y" ? true:false);
									$("#companyCodeHidden").val(info.CompanyCode);
									$("#companyCodeTxt").val(info.companyCodeTxt);
									$("#costCenterTypeTxt").val(info.costCenterTypeTxt);
								}
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
						}
					});
				},
				
				costCenterNameSearch : function(){
					var costCenterType	= accountCtrl.getComboInfo("costCenterType").val();
					if(costCenterType == "USER"){
						// [B1: 사용자 선택(3열-1명만)]
						var popupID		= "orgmap_pop";
						var openerID	= "CostCenterPopup";
						var popupTit	= "<spring:message code='Cache.ACC_lbl_orgChart' />";	//조직도
						var callBackFn	= "goOrgChart_CallBack";
						var type		= "B1";
						var popupUrl	= "/covicore/control/goOrgChart.do?"
										+ "popupID="		+ popupID		+ "&"
										+ "callBackFunc="	+ callBackFn	+ "&"
										+ "type="			+ type;
						
						parent.window[callBackFn] = window[openerID][callBackFn];
						parent.Common.open("", popupID, popupTit, popupUrl, "1000px","580px","iframe",true,null,null,true);
					}
					
					if(costCenterType == "DEPT"){
						// [C1: 그룹 선택(3열-1개만)]
						var popupID		= "orgmap_pop";
						var openerID	= "CostCenterPopup";
						var popupTit	= "<spring:message code='Cache.ACC_lbl_orgChart' />";	//조직도
						var callBackFn	= "goOrgChart_CallBack";
						var type		= "C1";
						var popupUrl	= "/covicore/control/goOrgChart.do?"
										+ "popupID="		+ popupID		+ "&"
										+ "callBackFunc="	+ callBackFn	+ "&"
										+ "type="			+ type;
						
						parent.window[callBackFn] = window[openerID][callBackFn];
						parent.Common.open("", popupID, popupTit, popupUrl, "1000px","580px","iframe",true,null,null,true);
					}
				},
				
				goOrgChart_CallBack : function(orgData){
					var items = JSON.parse(orgData).item;
					var arr = items[0].DN.split(';');
					$("#costCenterName").val(arr[0]);
				},
				
				costCenterTypeChangeInit : function(){
					var me = this;
					var type	= $("#type").val();
					if(type == "PROJECT"){
						$("#nameCodeArea").show();
						$("#costCenterNameSearchBtn").hide();
					}else{
						$("#nameCodeArea").hide();
						$("#costCenterNameSearchBtn").show();
					}
				},
				
				costCenterTypeChange : function(){
					var me = this;
					var costCenterType	= accountCtrl.getComboInfo("costCenterType").val();
					var mode			= $("#mode").val();
					var popupH			= '0px';
					
					if(costCenterType == "PROJECT"){
						$("#nameCodeArea").show();
						$("#costCenterNameSearchBtn").hide();
						popupH = '550px';
					}else{
						$("#nameCodeArea").hide();
						$("#costCenterNameSearchBtn").show();
						popupH = '500px';
					}
					
					if(mode == 'modify'){
						$("#costCenterNameSearchBtn").hide();
					}else{
						accountCtrl.changePopupSize('',popupH);
					}
					
					$("#costCenterName").val('');
					
					me.refreshCombo();
				},
				
				changeChkForever : function(){
					var isPermanent	= $("#isPermanent").prop("checked") ? "Y" : "N";
					
					if(isPermanent == 'Y'){
						$("#usePeriodStartN").val('1900.01.01');
						$("#usePeriodFinishN").val('2999.12.31');
					}
				},
				
				checkValidation : function(){
					if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
					 
					var me = this;
					
					var companyCode		= accountCtrl.getComboInfo("companyCode").val();
					var costCenterID	= $("#costCenterID").val();
					var nameCode		= $("#nameCode").val();
					var costCenterType	= accountCtrl.getComboInfo("costCenterType").val();
					var costCenterCode	= $("#costCenterCode").val();
					var costCenterName	= $("#costCenterName").val();
					var isUse			= accountCtrl.getComboInfo("isUse").val();
					var usePeriodStart	= $("#usePeriodStartN").val().replaceAll('.','');
					var usePeriodFinish	= $("#usePeriodFinishN").val().replaceAll('.','');
					var isPermanent		= $("#isPermanent").prop("checked") ? "Y" : "N";
					var description		= $("#description").val();
					var saveProperty  = $("#saveProperty").val();					
					
					if(costCenterName == null ||  costCenterName == ''){
						Common.Inform("<spring:message code='Cache.ACC_msg_noCostCenterName' />"); //소속부서명을 입력해주세요
						return;
					}
					
					if(costCenterCode == null ||  costCenterCode == ''){
						Common.Inform("<spring:message code='Cache.ACC_msg_noCostCenterCode' />"); //소속부서 코드를 입력해주세요
						return;
					}
					
					var cnt = 0;
					if($("#mode").val() =="add" && costCenterCode != null && costCenterCode != '') {
						$.ajax({
							url	:"/account/costCenter/getCostCenterCodeCnt.do",
							type: "POST",
							async: false,
							data: {
									"costCenterCode" : costCenterCode
							},
							success:function (data) {
								if(data.result == "ok"){
									cnt = Number(data.cnt);
								}
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
							}
						});					
					}
					if(cnt > 0) {						
						Common.Inform("<spring:message code='Cache.ACC_msg_duplicateCostCenterCode' />"); //소속부서 코드는 중복될 수 없습니다
						return;	
					}
					
					if(	usePeriodStart == null	||  usePeriodStart == '' ||
						usePeriodFinish == null ||  usePeriodFinish == ''){
						Common.Inform("<spring:message code='Cache.ACC_msg_noUsePeriod' />"); //사용기간을 입력해주세요
						return;
					}
					if(chkInputCode(description) 	||
						chkInputCode(costCenterCode)||
						chkInputCode(nameCode)){
						Common.Inform("<spring:message code='Cache.ACC_msg_case_1' />");	//<는 사용할수 없습니다.
						return;
					}
					
					$.ajax({
						url	: "/account/costCenter/saveCostCenterInfo.do",
						type: "POST",
						data: {
								"companyCode"		: companyCode
							,	"costCenterID"		: costCenterID
							,	"costCenterType"	: costCenterType
							,	"costCenterCode"	: costCenterCode
							,	"costCenterName"	: costCenterName
							,	"isUse"				: isUse
							,	"usePeriodStart"	: usePeriodStart
							,	"usePeriodFinish"	: usePeriodFinish
							,	"isPermanent"		: isPermanent
							,	"description"		: description
							,	"nameCode"			: nameCode
							,	"saveProperty"	: saveProperty
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다.
								
								CostCenterPopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
								
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다 . 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}
					});
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
		window.CostCenterPopup = CostCenterPopup;
	})(window);
	
	CostCenterPopup.popupInit();
	
</script>