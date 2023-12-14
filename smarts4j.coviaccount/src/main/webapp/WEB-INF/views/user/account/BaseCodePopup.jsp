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
	<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents" >
			<div class="popContent" style="position:relative;">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style="width: 200px;">
							<col style="width: auto;">
						</colgroup>
						<tbody>
							<tr id="checkArea">
								<th>	<!-- 그룹코드 신규생성 -->
									<spring:message code="Cache.ACC_btn_newGroupCode"/>
								</th>
								<td>
									<div class="box">
										<input type="checkbox" id="addNewGrp"  onchange="BaseCodePopup.setNewGrp(this);" >
										<label for="addNewGrp">
											<span></span>
										</label>
									</div>
								</td>
							</tr>
						</tbody>
						
						<tbody>
							<tr>
								<th>	<!-- 회사코드 -->
									<spring:message code="Cache.ACC_lbl_companyCode"/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<span id="selectCompanyCode" class="selectType06">
										</span>
									</div>
								</td>
							</tr>
						</tbody>
						
						<tbody  id="grpAdd" style="display:none">
							<tr name="grpAdd" >
								<th>	<!-- 코드그룹 -->
									<spring:message code="Cache.ACC_lbl_codeGroup"/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input type="text" id="inputCodeGroup" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr name="grpAdd">
								<th>	<!-- 코드그룹명 -->
									<spring:message code="Cache.ACC_lbl_codeGroupName"/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input type="text" id="inputCodeGroupName" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
						</tbody>
						<tbody  id="itemAdd">	
							<!-- ================================ -->
							<tr >
								<th>	<!-- 코드그룹 -->
									<spring:message code="Cache.ACC_lbl_codeGroup"/>
									<span class="star"></span>
								</th>
								<td>
									<div id="basecdGrpComboArea" class="box">
										<span class="selectType06" id="selectCodeGroupCombo" onchange="BaseCodePopup.setAccountCtrl(this);">
										</span>
									</div>
									<div id="basecdGrpTextArea" style="display:none" class="box">
										<input type="text" id="viewCodeGroupName"  disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr >
								<th>	<!-- 코드 -->
									<spring:message code="Cache.ACC_lbl_code"/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input type="text" id="inputCode" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr >
								<th>	<!-- 코드명 -->
									<spring:message code="Cache.ACC_lbl_codeNm"/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input type="text" id="inputCodeName" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr >
								<th>	<!-- 정렬순서 -->
									<spring:message code="Cache.ACC_lbl_sortOrder"/> 
								</th>
								<td>
									<div class="box">
										<input type="number" id="inputSortKey" min="1", max="30000" class="HtmlCheckXSS ScriptCheckXSS" 
											onkeypress = "return inputNumChk(event)" onkeydown ="pressHan(this)">										
									</div>
								</td>
							</tr>
						</tbody>
						<tbody  id="comAdd">	
							<tr >
								<th>	<!-- 설명 -->
									<spring:message code="Cache.lbl_Description"/> 
								</th>
								<td>
									<div class="box">
										<input type="text" id="inputDescription" placeholder="">
									</div>
								</td>
							</tr>
							<tr AccCtrlID="Reserved1">
								<th AccCtrlID="Reserved1">	<!-- 예비1 -->
									<spring:message code="Cache.lbl_Reserved"/>1 
								</th>
								<td>
									<div class="box" AccountCtrlRel="N">
										<input type="text" id="inputReserved1" placeholder="" >
									</div>
									<div class="box" AccountCtrlRel="Y" style="display:none">
										<span id = 'selectReserved1' AccCtrlID="inputReserved1" class="selectType06" onchange="BaseCodePopup.doAccountCtrlEvent(this);"></span>
									</div>
								</td>
							</tr>
							<tr AccCtrlID="Reserved2">
								<th AccCtrlID="Reserved2">	<!-- 예비2 -->
									<spring:message code="Cache.lbl_Reserved"/>2 
								</th>
								<td>
									<div class="box" AccountCtrlRel="N">
										<input type="text" id="inputReserved2" placeholder="">
									</div>
									<div class="box" AccountCtrlRel="Y" style="display:none">
										<input type="checkbox" AccCtrlID ="inputReserved2" >
									</div>
								</td>
							</tr>
							<tr AccCtrlID="Reserved3">
								<th AccCtrlID="Reserved3">	<!-- 예비3 -->
									<spring:message code="Cache.lbl_Reserved"/>3 
								</th>
								<td>
									<div class="box" AccountCtrlRel="N">
										<input type="text" id="inputReserved3" placeholder="" AccountCtrlRel="N">
									</div>
									<div class="box" AccountCtrlRel="Y" style="display:none">
										<input type="text" AccCtrlID ="inputReserved3" USE='Y'>
										<input type="checkbox" AccCtrlID ="inputReserved3" USE='N'>
									</div>
								</td>
							</tr>
							<tr AccCtrlID="Reserved4">
								<th AccCtrlID="Reserved4">	<!-- 예비4 -->
									<spring:message code="Cache.lbl_Reserved"/>4 
								</th>
								<td>
									<div class="box" AccountCtrlRel="N">
										<input type="text" id="inputReserved4" placeholder="" AccountCtrlRel="N">
									</div>
									<div class="box" AccountCtrlRel="Y" style="display:none">
										<span class="selectType06" type="select" id='AccCtrlReserved4' AccCtrlID ="inputReserved4">
										</span>
									</div>
								</td>
							</tr>
							<tr AccountCtrlRel="N">
								<th AccCtrlID="ReservedInt">	<!-- 예비Int -->
									<spring:message code="Cache.lbl_Reserved"/>(Int)
								</th>
								<td>
									<div class="box">
										<input type="text" id="inputReservedInt" placeholder="" AccountCtrlRel="N">
									</div>
								</td>
							</tr>
							<tr AccountCtrlRel="N">
								<th AccCtrlID="ReservedFloat">	<!-- 예비Float -->
									<spring:message code="Cache.lbl_Reserved"/>(Float) 
								</th>
								<td>
									<div class="box">
										<input type="text" id="inputReservedFloat" placeholder="" AccountCtrlRel="N">
									</div>
								</td>
							</tr>
							
						</tbody>
						<tbody>
							<!-- ================================ -->
							<tr >
								<th>	<!-- 사용여부 -->
									<spring:message code="Cache.ACC_lbl_isUse"/>
								</th>
								<td>
									<div class="box">
										<span id="selectIsUse" class="selectType06">
										</span>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				
					<input type="hidden" id="inputBaseCodeID" >
					<input type="hidden" id="inputIsGroup" >
					<input type="hidden" id="inputIsNew" >
				</div>
				
				<div class="bottom">
					<a onclick="BaseCodePopup.CheckValidation(this);"	id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save' /></a>
					<a onclick="BaseCodePopup.closeLayer();"			id="btnClose" class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel' /></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

	if (!window.BaseCodePopup) {
		window.BaseCodePopup = {};
	}
	
	/**
	기초코드 추가용 팝업
	상세조회 기능 미사용중
	BaseCodeSearchPopup으로 분리
	*/
	(function(window) {
		var BaseCodePopup = {
				params : {
					codeDataObj : {}
				},
				
				/**
				팝업 초기화와 상세정보 조회
				*/
				popupInit : function(){
					var me = this;
					
					me.setSelectCombo();

					me.setFieldDataPopup("inputIsNew", "${isNew}");
					if("${isNew}" != "Y"){
						var baseCodeId = "${baseCodeId}";
						var isGrp = "${isGrp}";
						
						if(isGrp == "Y"){
							me.setGrpDataForm();
						}else{
							me.setCodeDataForm();
						}
						
						$.ajaxSetup({
							cache : false,
							async: false
						});
						
						$.getJSON('/account/baseCode/searchBaseCodeDetail.do', {BaseCodeID : baseCodeId}
							, function(r) {
								if(r.result == "ok"){
									var data = r.data
									if(data.IsGroup == "Y"){
										me.setGrpData(data);
									}else{
										me.setCodeData(data);
									}
								}
						}).error(function(response, status, error){
							CFN_ErrorAjax("getGroupList.do", response, status, error);
						});
						
					}else{
						$("#inputIsGroup").val("N");
						$("#grpAdd").css({"display":"none"}); 
						$("#itemAdd").css({"display":""}); 

						$("#basecdGrpComboArea").css({"display":""}); 
						$("#basecdGrpTextArea").css({"display":"none"}); 

						me.setFieldDataPopup("inputSortKey", "1" );
					}
					
					$("#selectCompanyCode").attr("onchange", "BaseCodePopup.changeCompanyCode()");
				},
				
				setSelectCombo : function(pCompanyCode) {
					if(pCompanyCode == undefined) {
						accountCtrl.renderAXSelect('CompanyCode', 'selectCompanyCode', 'ko','','','');
						pCompanyCode = accountCtrl.getComboInfo("selectCompanyCode").val();
					}
					
					$("#selectCodeGroupCombo").children().remove();
					$("#selectIsUse").children().remove();
					
					$("#selectCodeGroupCombo").addClass("selectType06");
					$("#selectIsUse").addClass("selectType06");

					accountCtrl.renderAXSelect('IsUse', 'selectIsUse', 'ko','','','',null,pCompanyCode);		
					accountCtrl.renderAXSelectGrp('selectCodeGroupCombo', 'ko','','','','<spring:message code="Cache.ACC_lbl_comboSelect"/>',pCompanyCode); //선택
					accountCtrl.renderAXSelect('AccountCtrlType', 'selectReserved1', 'ko','','','');
					accountCtrl.renderAXSelectGrp('AccCtrlReserved4', 'ko','','','','<spring:message code="Cache.ACC_lbl_comboSelect"/>',pCompanyCode); //선택
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("selectCompanyCode").val());
				},
				
				/**
				신규  코드그룹 추가 체크시 처리
				*/
				setNewGrp : function(obj) {
					var checked = obj.checked;
					var popupH = '0px';
					if(checked){
						$("#inputIsGroup").val("Y");
						$("#grpAdd").css({"display":""}); 
						$("#itemAdd").css({"display":"none"}); 
						popupH = '550px'
					}
					else{
						$("#inputIsGroup").val("N");
						$("#grpAdd").css({"display":"none"}); 
						$("#itemAdd").css({"display":""}); 
						popupH = '660px'
					}
					accountCtrl.changePopupSize('',popupH);
					accountCtrl.refreshAXSelect("selectIsUse");
					accountCtrl.refreshAXSelect("selectCompanyCode");
					accountCtrl.refreshAXSelect("selectCodeGroupCombo");
				},
				
				/**
				저장전 유효성 체크
				*/
				CheckValidation : function() {
				    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				    
					var me = this;
					me.getCodeData();
					if(me.params.codeDataObj.IsGroup == "Y"){
						if(	isEmptyStr(me.params.codeDataObj.CodeGroup)	||
							isEmptyStr(me.params.codeDataObj.CodeGroupName)){
							Common.Error("<spring:message code='Cache.ACC_Valid'/>");	//	입력되지 않은 필수값이 있습니다.
							return;
						}
						if( chkInputCode(me.params.codeDataObj.CodeGroup) ||
							chkInputCode(me.params.codeDataObj.CodeGroupName)){
							Common.Inform("<spring:message code='Cache.ACC_msg_case_1' />");				// <는 사용할수 없습니다
							return;
						}
					}else{
						if(	isEmptyStr(me.params.codeDataObj.CodeGroupCombo)	||
							isEmptyStr(me.params.codeDataObj.Code)			||
							isEmptyStr(me.params.codeDataObj.CodeName)		||
							isEmptyStr(me.params.codeDataObj.SortKey)){
							Common.Error("<spring:message code='Cache.ACC_Valid'/>");	// 입력되지 않은 필수값이 있습니다.
							return;
						}
						if( chkInputCode(me.params.codeDataObj.Code)	||
							chkInputCode(me.params.codeDataObj.CodeName)){
							Common.Inform("<spring:message code='Cache.ACC_msg_case_1' />");				// <는 사용할수 없습니다
							return;
						}
					}
			
			        Common.Confirm("<spring:message code='Cache.ACC_isSaveCk' />", "Confirmation Dialog", function(result){		//저장하시겠습니까?
			       		if(result){
			       			me.saveBaseCode();
			       		}
			        });
				},
				
				/**
				화면 저장
				*/
				saveBaseCode : function() {
					$.ajax({
						type:"POST",
							url:"/account/baseCode/saveBaseCode.do",
						data:{
							"baseCodeObj" : JSON.stringify(BaseCodePopup.params.codeDataObj),
						},
						success:function (data) {
							if(data.result == "ok"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다.
								
								BaseCodePopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
								
							}
							else if(data.result == "D"){
								Common.Error("<spring:message code='Cache.ACC_DuplCode'/>");	// 이미 존재하는 코드입니다.
							}
							else if(data.result == "V"){
								Common.Error("<spring:message code='Cache.ACC_Valid'/>");		// 입력되지 않은 필수값이 있습니다.
							}
							else if(data.result == "G"){
								Common.Error("<spring:message code='Cache.ACC_NoGrp'/>");		// 존재하지 않는 코드 그룹입니다.
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
							}
						},
						error:function (error){
							if(error.result == "D"){
								Common.Error("<spring:message code='Cache.ACC_DuplCode'/>");	// 이미 존재하는 코드입니다.
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
							}
						}
					});
				},
				
				/**
				저장정 화면 필드데이터 획득
				*/
				getCodeData : function() {
					var me = this;
					me.params.codeDataObj = {};
					me.params.codeDataObj.BaseCodeID		= me.getTxTFieldDataPopup("inputBaseCodeID");
					me.params.codeDataObj.CompanyCode		= accountCtrl.getComboInfo("selectCompanyCode").val();
					me.params.codeDataObj.IsGroup			= me.getTxTFieldDataPopup("inputIsGroup");
					me.params.codeDataObj.CodeGroup 		= me.getTxTFieldDataPopup("inputCodeGroup");
					me.params.codeDataObj.CodeGroupName		= me.getTxTFieldDataPopup("inputCodeGroupName");
					me.params.codeDataObj.CodeGroupCombo	= accountCtrl.getComboInfo("selectCodeGroupCombo").val();
					me.params.codeDataObj.Code				= me.getTxTFieldDataPopup("inputCode");
					me.params.codeDataObj.CodeName			= me.getTxTFieldDataPopup("inputCodeName");
					me.params.codeDataObj.IsUse				= accountCtrl.getComboInfo("selectIsUse").val();
					me.params.codeDataObj.IsNew				= me.getTxTFieldDataPopup("inputIsNew");
					me.params.codeDataObj.SortKey			= me.getTxTFieldDataPopup("inputSortKey");
					me.params.codeDataObj.Description		= me.getTxTFieldDataPopup("inputDescription");
					me.params.codeDataObj.Reserved1			= me.getTxTFieldDataPopup("inputReserved1");
					me.params.codeDataObj.Reserved2			= me.getTxTFieldDataPopup("inputReserved2");
					me.params.codeDataObj.Reserved3			= me.getTxTFieldDataPopup("inputReserved3");
					me.params.codeDataObj.Reserved4			= me.getTxTFieldDataPopup("inputReserved4");
					me.params.codeDataObj.ReservedInt		= me.getTxTFieldDataPopup("inputReservedInt");
					me.params.codeDataObj.ReservedFloat		= me.getTxTFieldDataPopup("inputReservedFloat");
					me.params.codeDataObj.SessionUser		= Common.getSession().USERID;
					

					if(me.params.codeDataObj.CodeGroupCombo=='AccountCtrl')
					{

						me.params.codeDataObj.Reserved1			= $("[accctrlid=inputReserved1]").val();
						me.params.codeDataObj.Reserved2			= $("[accctrlid=inputReserved2]").prop('checked')?'required':'';
						var Reserved3 =  $("[accctrlid=inputReserved3][USE=Y]");
						if(Reserved3.attr('type')=='checkbox')
							Reserved3 = Reserved3.prop('checked')?'numeric':'';
						else
							Reserved3 = Reserved3.val();
						me.params.codeDataObj.Reserved3			= Reserved3;
						me.params.codeDataObj.Reserved4			= $("[accctrlid=inputReserved4]").val();
						me.params.codeDataObj.ReservedInt		= $("[accctrlid=inputReservedInt]").val();
						me.params.codeDataObj.ReservedFloat		= $("[accctrlid=inputReservedFloat]").val();
					}
				},
				
				/**
				코드그룹 입력으로 화면처리
				*/
				setGrpDataForm : function(data) {
					$("#checkArea").css({"display":"none"}); 
					$("#grpAdd").css({"display":""}); 
					$("#itemAdd").css({"display":"none"}); 
				},
				
				/**
				코드입력으로 화면 처리
				*/
				setCodeDataForm : function(data) {
					$("#checkArea").css({"display":"none"}); 
					$("#grpAdd").css({"display":"none"}); 
					$("#itemAdd").css({"display":""}); 
				},
				
				/**
				필드에 값 세팅
				*/
				setGrpData : function(data) {
					var me = this;
					$("#checkArea").css({"display":"none"}); 
					$("#grpAdd").css({"display":""}); 
					$("#itemAdd").css({"display":"none"}); 
					
					me.setFieldDisabledPopup("inputCodeGroup",	 true);
					me.setFieldDataPopup("inputBaseCodeID",		data.BaseCodeID);
					me.setFieldDataPopup("inputIsGroup",		data.IsGroup);
					me.setFieldDataPopup("inputCodeGroup",		data.CodeGroup);
					me.setFieldDataPopup("inputCode",			data.Code);
					me.setFieldDataPopup("inputCodeGroupName",	data.CodeGroupName);
					me.setFieldDataPopup("inputDescription",	data.Description);
					me.setFieldDataPopup("inputReserved1",		data.Reserved1);
					me.setFieldDataPopup("inputReserved2",		data.Reserved2);
					me.setFieldDataPopup("inputReserved3",		data.Reserved3);

					accountCtrl.getComboInfo("selectIsUse").bindSelectSetValue(data.IsUse);
					accountCtrl.getComboInfo("selectCompanyCode").bindSelectSetValue(data.CompanyCode);
					
					accountCtrl.refreshAXSelect("selectIsUse");
					accountCtrl.refreshAXSelect("selectCompanyCode");
					accountCtrl.refreshAXSelect("selectCodeGroupCombo");
				},
			
				
				/**
				필드에 값 세팅
				*/
				setCodeData : function(data) {
					var me = this;
					$("#checkArea").css({"display":"none"}); 
					$("#grpAdd").css({"display":"none"}); 
					$("#itemAdd").css({"display":""}); 
			
					$("#basecdGrpComboArea").css({"display":"none"}); 
					$("#basecdGrpTextArea").css({"display":""}); 
					
					me.setFieldDataPopup("inputBaseCodeID",		data.BaseCodeID);
					me.setFieldDataPopup("inputIsGroup",		data.IsGroup);
					me.setFieldDataPopup("inputCodeGroup",		data.CodeGroup);
					me.setFieldDataPopup("viewCodeGroupName",	data.CodeGroupName);
					me.setFieldDataPopup("inputCode",			data.Code);
					me.setFieldDataPopup("inputCodeName",		data.CodeName);
					me.setFieldDataPopup("inputSortKey",		data.SortKey);
					me.setFieldDataPopup("inputDescription",	data.Description);
					me.setFieldDataPopup("inputReserved1",		data.Reserved1);
					me.setFieldDataPopup("inputReserved2",		data.Reserved2);
					me.setFieldDataPopup("inputReserved3",		data.Reserved3);
					me.setFieldDataPopup("inputReserved4",		data.Reserved4);
					me.setFieldDataPopup("inputReservedInt",	data.ReservedInt);
					me.setFieldDataPopup("inputReservedFloat",	data.ReservedFloat);
					me.setFieldDisabledPopup("inputCode",		true);

					accountCtrl.getComboInfo("selectIsUse").bindSelectSetValue(data.IsUse);
					accountCtrl.getComboInfo("selectCompanyCode").bindSelectSetValue(data.CompanyCode);
					
					accountCtrl.refreshAXSelect("selectIsUse");
					accountCtrl.refreshAXSelect("selectCompanyCode");
					accountCtrl.refreshAXSelect("selectCodeGroupCombo");
				},
				setAccountCtrl : function(){
					var me = this;
					var CodeGroup = accountCtrl.getComboInfo("selectCodeGroupCombo").val();
					me.doAccountCtrlEventInit(CodeGroup=='AccountCtrl');
					
				},
				doAccountCtrlEventInit : function(isAccountCtrl){
					var me = this;
					me.refreshCombo();
					if(!isAccountCtrl)
					{
						$("[AccountCtrlRel=N]").show();
						$("[AccountCtrlRel=Y]").hide();
						$("tr[AccCtrlID=Reserved1]").show();
						$("tr[AccCtrlID=Reserved2]").show();
						$("tr[AccCtrlID=Reserved3]").show();
						$("tr[AccCtrlID=Reserved4]").show();
						$("th[AccCtrlID=Reserved1]").html('<spring:message code="Cache.lbl_Reserved"/>1');
						$("th[AccCtrlID=Reserved2]").html('<spring:message code="Cache.lbl_Reserved"/>2');
						$("th[AccCtrlID=Reserved3]").html('<spring:message code="Cache.lbl_Reserved"/>3');
						$("th[AccCtrlID=Reserved4]").html('<spring:message code="Cache.lbl_Reserved"/>4');
					}
					else
					{
						$("[AccountCtrlRel=N]").hide();
						$("[AccountCtrlRel=Y]").show();
						$("tr[AccCtrlID=Reserved1]").show();
						$("tr[AccCtrlID=Reserved2]").show();
						$("tr[AccCtrlID=Reserved3]").show();
						$("tr[AccCtrlID=Reserved4]").hide();
						$("th[AccCtrlID=Reserved1]").html('<spring:message code="Cache.lbl_type"/>');//유형
						$("th[AccCtrlID=Reserved2]").html('<spring:message code="Cache.ACC_lbl_RequireYN"/>');//필수여부
						
						accountCtrl.getComboInfo("selectReserved1").change();
					}
					
				},
				doAccountCtrlEvent : function(obj){
					var me = this;
					me.refreshCombo();
					var AccCtrlID = obj.getAttribute('AccCtrlID');
					var value;

					$("tr[AccCtrlID=Reserved3]").hide();
					$("tr[AccCtrlID=Reserved4]").hide();
					
					value = obj.value;
					$("[AccCtrlID=inputReserved3]").hide();
					$("[AccCtrlID=inputReserved4]").hide();
					$("[AccCtrlID=inputReserved3]").val('');
					$("[AccCtrlID=inputReserved4]").val('');
					$("[AccCtrlID=inputReserved3]").attr('USE','N');
					$("#AXselect_AX_"+accountCtrl.getComboInfo('AccCtrlReserved4').attr('id')).hide();
					if(obj.value.indexOf('input')>-1)
					{
						$("tr[AccCtrlID=Reserved3]").show();
						$("[AccCtrlID=inputReserved3][type=checkbox]").show();
						$("[AccCtrlID=inputReserved3][type=checkbox]").attr('USE','Y');
						$("th[AccCtrlID=Reserved3]").html('<spring:message code="Cache.ACC_lbl_NumberYN"/>');//숫자여부
					}
					else if(obj.value=='popup'||obj.value=='checkbox')
					{
						$("tr[AccCtrlID=Reserved3]").show();
						$("[AccCtrlID=inputReserved3][type=text]").show();
						$("[AccCtrlID=inputReserved3][type=text]").attr('USE','Y');
						$("th[AccCtrlID=Reserved3]").html('<spring:message code="Cache.ACC_lbl_callFunctionNM"/>');//호출함수명
					}
					else if(obj.value=='select')
					{
						$("tr[AccCtrlID=Reserved3]").show();
						$("tr[AccCtrlID=Reserved4]").show();
						$("[AccCtrlID=inputReserved3][type=text]").show();
						$("[AccCtrlID=inputReserved3][type=text]").attr('USE','Y');
						$("[AccCtrlID=inputReserved4][type=select]").show();

						$("#AXselect_AX_"+accountCtrl.getComboInfo('AccCtrlReserved4').attr('id')).show();
						$("th[AccCtrlID=Reserved3]").html('<spring:message code="Cache.ACC_lbl_callFunctionNM"/>');//호출함수명
						$("th[AccCtrlID=Reserved4]").html('<spring:message code="Cache.ACC_lbl_codeGroup"/>');//코드그룹
					}
				},
				refreshCombo : function(){
					accountCtrl.refreshAXSelect("selectIsUse");
					accountCtrl.refreshAXSelect("selectCompanyCode");
					accountCtrl.refreshAXSelect("selectCodeGroupCombo");
					accountCtrl.refreshAXSelect("selectReserved1");
					accountCtrl.refreshAXSelect("AccCtrlReserved4");
				},
				closeLayer : function(){
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				},
				
				getTxTFieldDataPopup : function(field) {
					return $("#"+field).val()
				},
				setFieldDataPopup : function(field, data) {
					return $("#"+field).val(data)
				},
				setFieldDisabledPopup : function(field, val) {
					$("#"+field).attr('disabled',val)
				}
		}
		window.BaseCodePopup = BaseCodePopup;
	})(window);
	
	BaseCodePopup.popupInit();
	
</script>