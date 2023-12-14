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
	<div class="layer_divpop ui-draggable docPopLayer" id="vendorPopup" style="width:900px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style="width: 17%;" />
							<col style="width: auto;" />
							<col style="width: 17%;" />
							<col style="width: auto;" />
						</colgroup>
						<tbody>
							<tr>
								<th><spring:message code="Cache.ACC_lbl_vendorRequestType"/></th>
								<td colspan="3" >
									<div class="box" name="noViewArea">
										<span id="vendorPopup_inputVendorType" class="selectType02" onChange="VendorPopup.vendorTypeChange(this)">
										</span>
									</div>
									<div class="box" name="viewArea" style="display:none">
										<input id="vendorPopup_inputVendorTypeName" type="text" placeholder="" disabled class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr>
								<!-- 회사 -->
								<th><spring:message code="Cache.ACC_lbl_company"/><span class="star"></span></th>
								<td colspan="3">
									<div class="box">
										<span id="vendorPopup_inputCompany" class="selectType02">
										</span>
									</div>
								</td>
							</tr>
							<tr name="coArea">
								<!-- 사업자번호 -->
								<th><spring:message code="Cache.ACC_lbl_BusinessNumber"/><span class="star"></span></th>
								<td>
									<div class="box">
										<input id="vendorPopup_inputVendorNoView" type="text" placeholder="" name="viewDisabled" onkeyup="VendorPopup.onVendorNoChange(this)" class="HtmlCheckXSS ScriptCheckXSS">
										<a class="btnTypeDefault" onclick="VendorPopup.regCheck()" name="noViewArea">
											<!-- 등록확인 -->
											<spring:message code="Cache.ACC_btn_registCheck"/>
										</a>
										<input id="vendorPopup_inputVendorNo" name="vendorPopup_inputVendorNo" type="hidden" placeholder="" onkeyup="VendorPopup.onVendorNoChange(this)" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
									<th>
										<!-- 법인번호 -->
										<spring:message code="Cache.ACC_lbl_CorporateNumber"/>
									</th>
								<td>
									<div class="box">
										<input id="vendorPopup_inputCorporateNo" type="text" placeholder="" name="viewDisabled" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr name="coArea">
								<th>
									<!-- 거래처명 -->
									<spring:message code="Cache.ACC_lbl_vendorName"/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input id="vendorPopup_inputVendorName" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
								<th>
									<!-- 대표자명 -->
									<spring:message code="Cache.ACC_lbl_storeRepresentative"/>
								</th>
								<td>
									<div class="box">
										<input id="vendorPopup_inputCEOName" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr name="coArea">
								<th>
									<!-- 업태 -->
									<spring:message code="Cache.ACC_lbl_business"/>
								</th>
								<td>
									<div class="box">
										<input id="vendorPopup_inputIndustry" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
								<th>
									<!-- 업종 -->
									<spring:message code="Cache.ACC_lbl_vendorSector"/>
								</th>
								<td>
									<div class="box">
										<input id="vendorPopup_inputSector" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							
							
							<tr name="peArea" style="display:none">
								<th>
									<!-- 주민등록번호 -->
									<spring:message code="Cache.ACC_lbl_registrationNumber"/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input id="vendorPopup_inputRRNView" type="text" placeholder="" name="viewDisabled" onkeyup="VendorPopup.onPeopleNoChange(this)" class="HtmlCheckXSS ScriptCheckXSS">
										<!-- <input id="vendorPopup_inputRRNVendorId" type="text" placeholder="" name="viewDisabled" class="HtmlCheckXSS ScriptCheckXSS"> -->
										<a class="btnTypeDefault" onclick="VendorPopup.regCheck()" name="noViewArea">
											<!-- 등록확인 -->
											<spring:message code="Cache.ACC_btn_registCheck"/>
										</a>
										<input id="vendorPopup_inputRRN" name="vendorPopup_inputRRN" type="hidden" placeholder=""  onkeyup="VendorPopup.onPeopleNoChange(this)" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
								<th>
									<!-- 거래처명 -->
									<spring:message code="Cache.ACC_lbl_vendorName"/>
									<span class="star"></span>
								</th>
								<td >
									<div class="box">
										<input id="vendorPopup_inputVendorNamePeo" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr name="peArea" style="display:none">
								<th>
									<!-- 상세 주소 -->
									<spring:message code="Cache.ACC_lbl_detailAddress"/>
								</th>
								<td colspan="3">
									<div class="box">
										<input id="vendorPopup_inputAddress" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							
							<!-- 임직원 -->
							<tr name="orArea" style="display:none">
								<th>
									<!-- 사번 -->
									<spring:message code="Cache.ACC_lbl_idNumber"/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input id="vendorPopup_inputORIdView" type="text" placeholder="" disabled="disabled" readonly="readonly" class="HtmlCheckXSS ScriptCheckXSS">
										<a class="btnTypeDefault" onclick="VendorPopup.regCheck()" name="noViewArea">
											<!-- 등록확인 -->
											<spring:message code="Cache.ACC_btn_registCheck"/>
										</a>
									</div>
								</td>
								<th>
									<!-- 거래처명 -->
									<spring:message code="Cache.ACC_lbl_vendorName"/>
									<span class="star"></span>
								</th>
								<td >
									<div class="box">
										<input id="vendorPopup_inputVendorNameOrg" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
										<a id="organizationNameSearchBtn" class="btnTypeDefault btnResInfo" onclick="VendorPopup.organizationNameSearch()">검색</a>
									</div>
								</td>
							</tr>
							<tr name="orArea" style="display:none">
								<th>
									<!-- 상세 주소 -->
									<spring:message code="Cache.ACC_lbl_detailAddress"/>
								</th>
								<td colspan="3">
									<div class="box">
										<input id="vendorPopup_inputAddressOR" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
				</tbody>
				</table>	
				
				<!-- 대표계좌/추가/삭제 -->
				<div class="fRight" style="padding-bottom:10px; padding-top:10px;">
						<a onclick="VendorPopup.bankAccount()" id="bankAccount" class="btnTypeDefault" style="margin-right:5px;">
							<spring:message code='Cache.ACC_lbl_bankAccount'/> <!-- 대표계좌 -->
						</a>
						<a onclick="VendorPopup.addRow()" id="addRowBtn" class="btnTypeDefault" style="margin-right:5px;">
							<spring:message code='Cache.ACC_btn_add'/> <!-- 추가 -->
						</a>
						<a onclick="VendorPopup.delRow()" id="delRowBtn" class="btnTypeDefault">
							<spring:message code='Cache.ACC_btn_delete'/> <!-- 삭제 -->
						</a>
				</div>
				
				<table class="tableTypeRow" >
					<colgroup>
				        <col style="width: 17%;" />
						<col style="width: 33%;" />
						<col style="width: 25%;" />
						<col style="width: 25%;" />
					</colgroup>	
						
					<tbody id="rowInfoTable">
					    <tr>
					        <th class="multi-row-selector-wrap"  >선택</th>
					        <!-- 은행명 -->
					        <th><spring:message code="Cache.ACC_lbl_BankName"/> </th>
					        <!-- 은행계좌 -->
					        <th><spring:message code="Cache.ACC_lbl_BankAccount"/></th>
					        <!-- 예금주 -->
					        <th><spring:message code="Cache.ACC_lbl_BankAccountHolder"/></th>
					    </tr>
					</tbody>
				</table>
			
					<table class="tableTypeRow">
						<colgroup>
							<col style="width: 17%;" />
							<col style="width: auto;" />
							<col style="width: 17%;" />
							<col style="width: auto;" />
						</colgroup>
						<tbody>
							<tr>
								<th>
									<!-- 지급조건 -->
									<spring:message code="Cache.ACC_lbl_PayType"/>
								</th>
								<td>
									<div class="box">
										<span id="vendorPopup_inputPaymentConditione" class="selectType02">
										</span>
									</div>
								</td>
								<th>	
									<!-- 지급방법 -->
									<spring:message code="Cache.ACC_lbl_pay"/>
								</th>
								<td>
									<div class="box">
										<span id="vendorPopup_inputPaymentMethod" class="selectType02">
										</span>
									</div>
								</td>
							</tr>
							<tr name="peArea" style="display:none">
								<th>
									<!-- 원천세(소득세) -->
									<spring:message code="Cache.ACC_lbl_incomTax"/>
								</th>
								<td>
									<div class="box">
										<span id="vendorPopup_inputIncomTax" class="selectType02">
										</span>
									</div>
								</td>
								<th>
									<!-- 원천세(지방세) -->
									<spring:message code="Cache.ACC_lbl_localTax"/>
								</th>
								<td>
									<div class="box">
										<span id="vendorPopup_inputLocalTax" class="selectType02">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<!-- 상태 -->
									<spring:message code="Cache.ACC_lbl_status"/>
								</th>
								<td colspan="3">
									<div class="box">
										<span id="vendorPopup_inputVendorStatus" class="selectType02">
										</span>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<input type="hidden" id="vendorPopup_inputVendorID" >
				<input type="hidden" id="vendorPopup_inputIsNew" >
				<input type="hidden" id="vendorPopup_inputIsRegCheck" >
				
				<div class="popBtnWrap bottom">
					<a onclick="VendorPopup.CheckValidation(this);"	id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save' /></a>
					<a onclick="VendorPopup.closeLayer();"			id="btnClose" class="btnTypeDefault"><spring:message code='Cache.ACC_btn_close' /></a>
				</div>
			</div>
		</div>		
	</div>
</body>
<script>

	if (!window.VendorPopup) {
		window.VendorPopup = {};
	}
	
	(function(window) {
		var VendorPopup = {
				params :{
					vendorDataObj	: {},
					VendorID		: "${vendorId}",
					VendorType		: "${vendorType}",
					CompanyCode		: "${companyCode}"
				},
		
				popupInit : function(){
					var me = this;
					
					me.setSelectCombo();
					
					me.setFieldDataPopup("vendorPopup_inputIsNew",	"${isNew}");
					
					me.addRow();
					
					if("${isNew}" != "Y"){
						var getVendorID = "${vendorId}";
						var	getVendorType = "${vendorType}";
						me.searchDetailData(getVendorID,getVendorType);
					} else {
						me.setViewForm(false);
					}
					
					$("#vendor_inputCompanyCode").attr("onchange", "VendorPopup.changeCompanyCode()");
				},
				
				setSelectCombo : function(pCompanyCode) {
					var me = this;
					
					$("#vendorPopup_inputPaymentConditione").children().remove();
					$("#vendorPopup_inputPaymentMethod").children().remove();
					$("#vendorPopup_inputVendorStatus").children().remove();
					$("#vendorPopup_inputVendorType").children().remove();

					$("#vendorPopup_inputPaymentConditione").addClass("selectType02");
					$("#vendorPopup_inputPaymentMethod").addClass("selectType02");
					$("#vendorPopup_inputVendorStatus").addClass("selectType02");
					$("#vendorPopup_inputVendorType").addClass("selectType02");
					
					var AXSelectMultiArr	= [	
							{'codeGroup':'PayType',			'target':'vendorPopup_inputPaymentConditione',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_choice'/>"}	//선택
						,	{'codeGroup':'PayMethod',		'target':'vendorPopup_inputPaymentMethod',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_choice'/>"}
						,	{'codeGroup':'vendorStatus',	'target':'vendorPopup_inputVendorStatus',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'VendorType',		'target':'vendorPopup_inputVendorType',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'CompanyCode',		'target':'vendorPopup_inputCompany',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						]

					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
					
					me.vendorWHTaxComboMake(pCompanyCode);
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("vendor_inputCompanyCode").val());
				},

				vendorWHTaxComboMake : function(pCompanyCode){
					var me = this;
					if(pCompanyCode == undefined){
						pCompanyCode = accountCtrl.getComboInfo("vendorPopup_inputCompany").val();
					}
					
					$.ajax({
						type:"POST",
							url:"/account/accountCommon/getBaseCodeData.do",
						data:{
							codeGroups : "WHTax",
							companyCode : pCompanyCode
						},
						
						success:function (data) {
							if(data.result == "ok"){
								var codeList = data.list
							
								var WHTaxList = codeList.WHTax

								var incomList = WHTaxList.filter(function(item){
									if(item.Reserved1=="E1"){
										return true
									}
								});
								var localList = WHTaxList.filter(function(item){
									if(item.Reserved1=="E2"){
										return true
									}
								});
								
								accountCtrl.createAXSelectData("vendorPopup_inputIncomTax",incomList, "<spring:message code='Cache.ACC_lbl_choice'/>", 'Code', 'CodeName', null, null, null  )
								accountCtrl.createAXSelectData("vendorPopup_inputLocalTax",localList, "<spring:message code='Cache.ACC_lbl_choice'/>", 'Code', 'CodeName', null, null, null  )

								//vendorPopup_inputIncomTax
								//vendorPopup_inputLocalTax

							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}
					});
				},
				
				vendorComboRefresh : function(){
					var list = "vendorPopup_inputPaymentConditione,vendorPopup_inputPaymentMethod,vendorPopup_inputCompany,vendorPopup_inputVendorStatus"
					accountCtrl.refreshAXSelect(list);
				},
				
				vendorTypeChange : function(input){
					var me = this;

					if(input != null){
						if(input.tagName != "SELECT") return;
					}
					
					var val = "";
					var popupH = '0px';
					var getVendorType = "${vendorType}";
					if(input==null){
						val = accountCtrl.getComboInfo("vendorPopup_inputVendorType").val();
					}else{
						val = input.value;
					}
					
					if( getVendorType == null||
						isEmptyStr(getVendorType)){
						if(val == "CO"){
							$("tr[name=coArea]").css({"display":""});
							$("tr[name=peArea]").css({"display":"none"});
							$("tr[name=orArea]").css({"display":"none"});
							popupH = '650px';
						}
						else if(val == "PE"){
							$("tr[name=coArea]").css({"display":"none"});
							$("tr[name=peArea]").css({"display":""});
							$("tr[name=orArea]").css({"display":"none"});
							popupH = '550px';
						}
						else if(val == "OR"){
							$("tr[name=coArea]").css({"display":"none"});
							$("tr[name=peArea]").css({"display":"none"});
							$("tr[name=orArea]").css({"display":""});
							popupH = '550px';
						}
						
					}else{
						if(getVendorType == "CO"){
							$("tr[name=coArea]").css({"display":""});
							$("tr[name=peArea]").css({"display":"none"});
							$("tr[name=orArea]").css({"display":"none"});
							popupH = '650px';
						}
						else if(getVendorType == "PE"){
							$("tr[name=coArea]").css({"display":"none"});
							$("tr[name=peArea]").css({"display":""});
							$("tr[name=orArea]").css({"display":"none"});
							popupH = '550px';
						}
						else if(val == "OR"){
							$("tr[name=coArea]").css({"display":"none"});
							$("tr[name=peArea]").css({"display":"none"});
							$("tr[name=orArea]").css({"display":""});
							popupH = '550px';
						}
					}
					
					
					
					me.setRegCk('N');
					accountCtrl.changePopupSize('',popupH);
					me.vendorComboRefresh();
				},
	
				searchDetailData : function(getVendorID) {
					var me = this;
					var searchVendorID = "";
					me.setFieldDataPopup("vendorPopup_inputIsNew", "N");
					
					if(	getVendorID == null	||
						isEmptyStr(getVendorID)){
						searchVendorID = me.params.VendorID;
					}else{
						searchVendorID		= getVendorID;
						me.params.VendorID	= getVendorID;
					}
					
					$.ajaxSetup({
						cache : false,
						async : false
					});
					
					$.getJSON('/account/baseInfo/searchVendorDetail.do', {VendorID : searchVendorID, companyCode : me.params.CompanyCode}
						, function(r) {
							if(r.result == "ok"){
								var data = r.data
								me.setViewForm(true);			
								me.setVendorData(data);
								/* me.setFieldDisabledPopup("vendorPopup_inputVendorNoView",	true);
								me.setFieldDisabledPopup("vendorPopup_inputCorporateNoView",	true); */
							}
						}
					).error(function(response, status, error){});
				},
	
				regCheck : function(data){
					var me = this;
					var VendorNo	= "";
					var VendorType	= accountCtrl.getComboInfo("vendorPopup_inputVendorType").val();
					var CompanyCode = accountCtrl.getComboInfo("vendorPopup_inputCompany").val();
					
					if(VendorType=="PE"){
						VendorNo = me.getTxTFieldDataPopup("vendorPopup_inputRRN");
						if(isEmptyStr(VendorNo)){
							Common.Inform("<spring:message code='Cache.ACC_RRNMsg'/>");	//주민등록번호를 입력해주세요. ACC_RRNMsg
							return;
						}
					}else if(VendorType=="CO"){
						VendorNo = me.getTxTFieldDataPopup("vendorPopup_inputVendorNo");
						if(isEmptyStr(VendorNo)){
							Common.Inform("<spring:message code='Cache.ACC_005'/>");	//사업자번호를 입력해주세요.
							return;
						}
					}else{
						VendorNo = me.getTxTFieldDataPopup("vendorPopup_inputORIdView");
						if(isEmptyStr(VendorNo)){
							Common.Inform("<spring:message code='Cache.ACC_idNumber'/>");	//사번을 입력해주세요.
							return;
						}
					}
	
				
					
					$.ajax({
						type:"POST",
							url:"/account/baseInfo/checkVendorDuplicate.do",
						data:{
							"VendorNo"		: VendorNo,
							"VendorType"	: VendorType,
							"CompanyCode"	: CompanyCode
						},
						success:function (data) {
							if(data.result == "ok"){
								var duplItem = data.duplItem;
								
								if(duplItem != null){
									var duplCnt	= duplItem.CNT;
									var duplID	= duplItem.VendorID;
									
									if(duplCnt != 0){
								        Common.Confirm("<spring:message code='Cache.ACC_003' />", "Confirmation Dialog", function(result){	//이미 등록된 거래처입니다. 해당 거래처를 조회하시겠습니까?
								       		if(result){
												VendorPopup.searchDetailData(duplID);
								       		}
								        });
								        
									}else{
										parent.Common.Inform("<spring:message code='Cache.ACC_004'/>");	//등록 가능한 거래처 입니다.
										VendorPopup.setFieldDataPopup("vendorPopup_inputIsRegCheck","Y");
									}
								}else{
									Common.Error("<spring:message code='Cache.ACC_msg_error'/>");	//오류가 발생하였습니다.
								}
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					});
				},
	
				CheckValidation : function(){
					if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
					
					var me = this;
					
					me.getVendorData()
					
					if($("[name=noViewArea]").css("display") != "none" && me.params.vendorDataObj.IsRegCheck != "Y"){
						Common.Inform("<spring:message code='Cache.ACC_010'/>");//저장 전 등록확인을 해 주시기 바랍니다.
						return; 
					}

					if(isEmptyStr(me.params.vendorDataObj.VendorNo)){
						if(me.params.vendorDataObj.VendorType == "CO") {
							Common.Inform("<spring:message code='Cache.ACC_005'/>");	//사업자번호를 입력해주세요
						} else if(me.params.vendorDataObj.VendorType == "PE") {
							Common.Inform("<spring:message code='Cache.ACC_RRNMsg'/>");	//주민등록번호를 입력해주세요.						
						} else if(me.params.vendorDataObj.VendorType == "OR") {
							Common.Inform("<spring:message code='Cache.ACC_idNumber'/>");	//사번을 입력해주세요							
						}
						return;
					}
					
					if(	isEmptyStr(me.params.vendorDataObj.VendorName)	){
						Common.Inform("<spring:message code='Cache.ACC_msg_enterVendorName'/>");	//거래처명을 입력해주세요.
						return;
					}
					
					if(	isEmptyStr(me.params.vendorDataObj.CompanyCode)	){
						Common.Inform("<spring:message code='Cache.msg_Company_01'/>");	//회사코드를 입력하여 주십시오.
						return;
					}
					
					for(var i=0; i<$("#rowInfoTable").children('tr').length-1; i++){					
						if(	getTxTFieldDataPopup("vendorPopup_inputBankName"+(i+1)) != null	&& !(isEmptyStr(getTxTFieldDataPopup("vendorPopup_inputBankName"+(i+1))))){
							if(	getTxTFieldDataPopup("vendorPopup_inputBankAccountNo"+(i+1)) == null || isEmptyStr(getTxTFieldDataPopup("vendorPopup_inputBankAccountNo"+(i+1)))){
								Common.Inform("<spring:message code='Cache.ACC_accountno'/>");	//은행계좌를 입력해주십시오.
								return;
							}	
							if(	getTxTFieldDataPopup("vendorPopup_inputBankAccountName"+(i+1)) == null || isEmptyStr(getTxTFieldDataPopup("vendorPopup_inputBankAccountName"+(i+1)))){
								Common.Inform("<spring:message code='Cache.ACC_msg_noDataBankOwner'/>");	//예금주를 입력해주십시오.
								return;
							}							
						}							
					}					
					
					if( chkInputCode(me.params.vendorDataObj.BankAccountName) ||
							chkInputCode(me.params.vendorDataObj.VendorName) ||
							chkInputCode(me.params.vendorDataObj.Address) ||
							chkInputCode(me.params.vendorDataObj.CEOName) ||
							chkInputCode(me.params.vendorDataObj.CorporateNo) ||
							chkInputCode(me.params.vendorDataObj.Industry)||
							chkInputCode(me.params.vendorDataObj.Sector)){
							Common.Inform("<spring:message code='Cache.ACC_msg_case_1' />");	//<는 사용할수 없습니다.
							return;
						}
					
					
					//
					if(me.params.vendorDataObj.VendorType == "CO"
							&& me.params.vendorDataObj.VendorNo.replace(/-/gi, '').length != 10){
						Common.Inform("<spring:message code='Cache.ACC_msg_ckVendorNo' />");	//사업자 등록 번호를 확인해 주세요
						return;
					}
					
					if(me.params.vendorDataObj.VendorType == "PE"
							&& me.params.vendorDataObj.VendorNo.replace(/-/gi, '').length != 13){
						Common.Inform("<spring:message code='Cache.ACC_036'/>");//잘못된 주민등록번호입니다.
						return;
					}

					
			        Common.Confirm("<spring:message code='Cache.ACC_isSaveCk' />", "Confirmation Dialog", function(result){	//저장하시겠습니까?
			       		if(result){
							me.saveVendorData();
			       		}
			        });
				},
	
				saveVendorData : function(){
					var me = this;
					
					$.ajax({
						type:"POST",
							url:"/account/baseInfo/saveVendorData.do",
						data:{
							"vendorDataObj" : JSON.stringify(me.params.vendorDataObj),
						},
						success:function (data) {
							if(data.result == "ok"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
	
								VendorPopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
								
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다 관리자에게 문의바랍니다.
							}
						},
						error:function (error){
							if(error.result == "D"){
								Common.Error("<spring:message code='Cache.ACC_DuplCode'/>");	//이미 존재하는 코드입니다.
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
							}
						}
					});
				},

				setViewForm : function(type){
					var me = this;
					if(type==true){
						$("[name=viewDisabled]").attr('disabled',type)
						$("[name=viewArea]").css("display", "");
						$("[name=noViewArea]").css("display", "none");
						me.vendorWHTaxComboMake();
					}else{
						$("[name=viewDisabled]").attr('disabled',type)
						$("[name=viewArea]").css("display", "none");
						$("[name=noViewArea]").css("display", "");
					}
				}, 
				setVendorData : function(data){
					var me = this;
					var infoList= $("#rowInfoTable").children('tr');
					var TotalLen		= infoList.length;
					var len		= infoList.length;
					
					
					me.setFieldDataPopup("vendorPopup_inputVendorID",data.VendorID); 
					accountCtrl.getComboInfo("vendorPopup_inputVendorType").bindSelectSetValue(data.VendorType)
					me.setFieldDataPopup("vendorPopup_inputVendorTypeName",	data.VendorTypeName);
					
					if(data.VendorType == "CO"){
					 	me.setFieldDataPopup("vendorPopup_inputVendorNo",		data.BusinessNumber);
						me.setFieldDataPopup("vendorPopup_inputVendorNoView",	data.BusinessNumber); 
						
						var noField = $("#vendorPopup_inputVendorNoView");
						if(noField.length!=0){
							noField[0].onkeyup();
						}
						
						me.setFieldDataPopup("vendorPopup_inputCorporateNo",	data.CorporateNo);
						me.setFieldDataPopup("vendorPopup_inputVendorName",		data.VendorName);
						me.setFieldDataPopup("vendorPopup_inputCEOName",		data.CEOName);
						me.setFieldDataPopup("vendorPopup_inputIndustry",		data.Industry);
						me.setFieldDataPopup("vendorPopup_inputSector",			data.Sector);
					}
					else if(data.VendorType == "PE"){
					 	me.setFieldDataPopup("vendorPopup_inputRRN",			data.BusinessNumber);
						me.setFieldDataPopup("vendorPopup_inputRRNView",		data.BusinessNumber); 
						
						var noField = $("#vendorPopup_inputRRNView");
						if(noField.length!=0){
							noField[0].onkeyup();
						}
						
						me.setFieldDataPopup("vendorPopup_inputVendorNamePeo",	data.VendorName);		
						me.setFieldDataPopup("vendorPopup_inputAddress",		data.Address);		
						
						accountCtrl.getComboInfo("vendorPopup_inputIncomTax").bindSelectSetValue(data.IncomTax);
						accountCtrl.getComboInfo("vendorPopup_inputLocalTax").bindSelectSetValue(data.LocalTax);
					}
					else { //임직원 OR
						me.setFieldDataPopup("vendorPopup_inputORId",			data.BusinessNumber);
						me.setFieldDataPopup("vendorPopup_inputORIdView",		data.BusinessNumber); 
						
						me.setFieldDataPopup("vendorPopup_inputVendorNameOrg",	data.VendorName);
						me.setFieldDataPopup("vendorPopup_inputAddressOR",		data.Address);			
					}
					
					me.vendorTypeChange();
				
					var items = data.BankCode.split(',');
					
					var BankNameSplit=data.BankName.split(',');
					var BankCodeSplit=items;
					var BankAccountNoSplit=data.BankAccountNo.split(',');
					var BankAccountName=data.BankAccountName.split(',');

					for(var j=0;j<items.length-1;j++){
						me.addRow();
					}

					for(var i=0;i<items.length;i++){
						me.setFieldDataPopup("vendorPopup_inputBankName"+(i+1),			BankNameSplit[i]);
						me.setFieldDataPopup("vendorPopup_inputBankCode"+(i+1),			BankCodeSplit[i]);
						me.setFieldDataPopup("vendorPopup_inputBankAccountNo"+(i+1),	BankAccountNoSplit[i]);	
						me.setFieldDataPopup("vendorPopup_inputBankAccountName"+(i+1),	BankAccountName[i]);
					}
					
					accountCtrl.getComboInfo("vendorPopup_inputPaymentConditione").bindSelectSetValue(data.PaymentCondition)
					accountCtrl.getComboInfo("vendorPopup_inputPaymentMethod").bindSelectSetValue(data.PaymentMethod)
					accountCtrl.getComboInfo("vendorPopup_inputCompany").bindSelectSetValue(data.CompanyCode)
					accountCtrl.getComboInfo("vendorPopup_inputVendorStatus").bindSelectSetValue(data.VendorStatus)
					me.setRegCk("Y");
					
				},
	
				getVendorData : function(){
					var me = this;
					var infoList= $("#rowInfoTable").children('tr');
					var len		= infoList.length;
					var vendorType = accountCtrl.getComboInfo("vendorPopup_inputVendorType").val();
					
					me.params.vendorDataObj = {};
					me.params.vendorDataObj.VendorID		= me.getTxTFieldDataPopup("vendorPopup_inputVendorID");
					me.params.vendorDataObj.VendorType		= accountCtrl.getComboInfo("vendorPopup_inputVendorType").val();
					if(vendorType == "CO"){
						me.params.vendorDataObj.VendorNo	= me.getTxTFieldDataPopup("vendorPopup_inputVendorNoView");
						me.params.vendorDataObj.CorporateNo	= me.getTxTFieldDataPopup("vendorPopup_inputCorporateNo");
						me.params.vendorDataObj.VendorName	= me.getTxTFieldDataPopup("vendorPopup_inputVendorName");
						me.params.vendorDataObj.CEOName		= me.getTxTFieldDataPopup("vendorPopup_inputCEOName");
						me.params.vendorDataObj.Industry	= me.getTxTFieldDataPopup("vendorPopup_inputIndustry");
						me.params.vendorDataObj.Sector		= me.getTxTFieldDataPopup("vendorPopup_inputSector");
						me.params.vendorDataObj.CompanyCode	= accountCtrl.getComboInfo("vendorPopup_inputCompany").val();
					}else if(vendorType == "PE"){
						me.params.vendorDataObj.VendorNo	= me.getTxTFieldDataPopup("vendorPopup_inputRRNView");
						me.params.vendorDataObj.VendorName	= me.getTxTFieldDataPopup("vendorPopup_inputVendorNamePeo");
						me.params.vendorDataObj.IncomTax	= accountCtrl.getComboInfo("vendorPopup_inputIncomTax").val();
						me.params.vendorDataObj.LocalTax	= accountCtrl.getComboInfo("vendorPopup_inputLocalTax").val();
						me.params.vendorDataObj.CompanyCode	= accountCtrl.getComboInfo("vendorPopup_inputCompany").val();
						me.params.vendorDataObj.Address		= me.getTxTFieldDataPopup("vendorPopup_inputAddress");
					}else if(vendorType == "OR"){
						me.params.vendorDataObj.VendorNo	= me.getTxTFieldDataPopup("vendorPopup_inputORIdView");
						me.params.vendorDataObj.VendorName	= me.getTxTFieldDataPopup("vendorPopup_inputVendorNameOrg");
						me.params.vendorDataObj.CompanyCode	= accountCtrl.getComboInfo("vendorPopup_inputCompany").val();
						me.params.vendorDataObj.Address		= me.getTxTFieldDataPopup("vendorPopup_inputAddressOR");						
					}
						
					me.params.vendorDataObj.BankCode = "";
					me.params.vendorDataObj.BankName = "";
					me.params.vendorDataObj.BankAccountNo = "";
					me.params.vendorDataObj.BankAccountName = "";
					
					for(var i=0;i<len-1;i++){
						var comma = ",";
						if(i == ((len-1)-1)) { //마지막일경우 , 붙이지 않기
							comma = "";
						}
						me.params.vendorDataObj.BankCode += me.getTxTFieldDataPopup("vendorPopup_inputBankCode"+(i+1))+comma;
						me.params.vendorDataObj.BankName += me.getTxTFieldDataPopup("vendorPopup_inputBankName"+(i+1))+comma;
						me.params.vendorDataObj.BankAccountNo += me.getTxTFieldDataPopup("vendorPopup_inputBankAccountNo"+(i+1))+comma;
						me.params.vendorDataObj.BankAccountName += me.getTxTFieldDataPopup("vendorPopup_inputBankAccountName"+(i+1))+comma;
					}					
				
					me.params.vendorDataObj.PaymentCondition= accountCtrl.getComboInfo("vendorPopup_inputPaymentConditione").val();
					me.params.vendorDataObj.PaymentMethod	= accountCtrl.getComboInfo("vendorPopup_inputPaymentMethod").val();
					me.params.vendorDataObj.VendorStatus	= accountCtrl.getComboInfo("vendorPopup_inputVendorStatus").val();
					me.params.vendorDataObj.IsRegCheck		= me.getTxTFieldDataPopup("vendorPopup_inputIsRegCheck");
					me.params.vendorDataObj.IsNew			= me.getTxTFieldDataPopup("vendorPopup_inputIsNew");
					me.params.vendorDataObj.SessionUser		= Common.getSession().USERID
					
					return me.params.vendorDataObj;
				},
	
				popup_index : 0,
				bankSearchPopup : function(index){
					var me = this;
					me.popup_index = index;
					
					var popupID		=	"bankSelectPopup";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_bankSelect'/>";	//은행선택
					var popupName	=	"BankSearchPopup";
					var openerID	=	"VendorPopup";
					var callBack	=	"selectBankCode";
					var popupYN		=	"Y";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+	"popupYN="		+	popupYN		+	"&"
									+	"companyCode="	+	accountCtrl.getComboInfo("vendorPopup_inputCompany").val() + "&"
									+	"callBackFunc="	+	callBack;
					parent.Common.open(	"",popupID,popupTit,url,"350px","400px","iframe",true,null,null,true);
				},
				
				selectBankCode : function(bankInfo){
					var me = this;
					
					me.setFieldDataPopup("vendorPopup_inputBankCode"+me.popup_index,bankInfo.Code);
					me.setFieldDataPopup("vendorPopup_inputBankName"+me.popup_index,bankInfo.CodeName);		
				},

				bankAccountChange : function(obj){
					var me = this;
					var val = obj.value;
					var oriVal = val;
					if(val != null){
						val=val.toString();
						val = val.replaceAll("-", "");
						if(isNaN(val)){
							obj.value = ""
						}
					}
				},
				onVendorNoChange : function(obj){
					var me = this;
					me.setRegCk('N');
					
					var val = obj.value;
					var strVal = "";
					
					if(val != null){
						val=val.toString();
						val = val.replaceAll("-", "");
						val = val.substr(0,10)

						if(isNaN(val)){
							strVal = "";
							val = "";
						}
						else{
							strVal = me.vdNoFormat(val);
						}
						obj.value = strVal
						$("[name=vendorPopup_inputVendorNo]").val(val);
					}
				},
				

				onPeopleNoChange : function(obj){
					var me = this;
					me.setRegCk('N');
					
					var val = obj.value;
					var strVal = "";
					
					if(val != null){
						val=val.toString();
						val = val.replaceAll("-", "");
						val = val.substr(0,13)

						if(isNaN(val)){
							strVal = "";
							val = "";
						}
						else{
							strVal = me.peopleNoFormat(val);
						}
						obj.value = strVal
						
						$("[name=vendorPopup_inputRRN]").val(val);
						
					}
				},

				peopleNoFormat : function(val){
					var retVal = "";
					retVal = val.substr(0,6)
					if(val.substr(6,7) != ""){
						retVal = retVal + "-"+ val.substr(6,7)
					}
					return retVal
				},
				vdNoFormat : function(val){
					var retVal = "";
					retVal = val.substr(0,3)
					if(val.substr(3,2) != ""){
						retVal = retVal + "-"+ val.substr(3,2)
					}

					if(val.substr(5,5) != ""){
						retVal = retVal + "-"+ val.substr(5,5)
					}
					return retVal
				},
				setRegCk : function(val) {
					var me = this;
					$('#vendorPopup_inputIsRegCheck').val(val);
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
				bankAccount: function() {
					var me = this;
					
					var rows = $("input:checkbox[name=RowCheck]:checked");
					
					if (rows.length == 0) {
						Common.Inform("<spring:message code='Cache.msg_PleaseCheckbox'/>"); // 체크박스를 선택해주세요.
						return;
					} else if (rows.length > 1) {
						Common.Inform("<spring:message code='Cache.msg_SelectOne'/>"); // 한개만 선택되어야 합니다
						return;
					}
					
					var index = rows[0].getAttribute("index");
					var tmp = {
						BankCode: me.getTxTFieldDataPopup("vendorPopup_inputBankCode" + 1),
						BankName: me.getTxTFieldDataPopup("vendorPopup_inputBankName" + 1),
						BankAccountNo: me.getTxTFieldDataPopup("vendorPopup_inputBankAccountNo" + 1),
						BankAccountName: me.getTxTFieldDataPopup("vendorPopup_inputBankAccountName" + 1)
					};
					
					$("#vendorPopup_inputBankCode" + 1).val(me.getTxTFieldDataPopup("vendorPopup_inputBankCode" + index));
					$("#vendorPopup_inputBankName" + 1).val(me.getTxTFieldDataPopup("vendorPopup_inputBankName" + index));
					$("#vendorPopup_inputBankAccountNo" + 1).val(me.getTxTFieldDataPopup("vendorPopup_inputBankAccountNo" + index));
					$("#vendorPopup_inputBankAccountName" + 1).val(me.getTxTFieldDataPopup("vendorPopup_inputBankAccountName" + index));
					
					$("#vendorPopup_inputBankCode" + index).val(tmp.BankCode);
					$("#vendorPopup_inputBankName" + index).val(tmp.BankName);
					$("#vendorPopup_inputBankAccountNo" + index).val(tmp.BankAccountNo);
					$("#vendorPopup_inputBankAccountName" + index).val(tmp.BankAccountName);
					
					rows.attr("checked", false);
				},
				addRow : function(){
					var me = this;
					var VendorType	= accountCtrl.getComboInfo("vendorPopup_inputVendorType").val();
					var i=0;
/*					if(VendorType=="CO"){
						i=0;
					}else if(VendorType=="PE"){  
						i=1;
					}else{
						i=2
					}
*/
					//'#rowInfoTable"+i+"'
					var infoList = $('#rowInfoTable').children('tr');
					var len	= infoList.length;
			
					var appendStr	= "<tr>"
									+	"<td style='border-left:none;text-align:center' class='multi-row-selector-wrap'>"
									+		"<input type='checkbox' name='RowCheck' class='multi-row-select' index='" + len + "'/>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input type='hidden' id='vendorPopup_inputBankCode"+len+"' class='HtmlCheckXSS ScriptCheckXSS' >"
									+			"<input id='vendorPopup_inputBankName"+len+"' type='text' placeholder='' disabled='true' class='HtmlCheckXSS ScriptCheckXSS'>"
									+			"<a onClick='VendorPopup.bankSearchPopup(" + len + ")' class='btnTypeDefault btnResInfo'><spring:message code='Cache.ACC_btn_search'/></a>"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='vendorPopup_inputBankAccountNo"+len+"' type='text' placeholder='' onkeyup='VendorPopup.bankAccountChange(this)' class='HtmlCheckXSS ScriptCheckXSS' >"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='vendorPopup_inputBankAccountName"+len+"' type='text' placeholder='' class='HtmlCheckXSS ScriptCheckXSS'>"
									+		"</div>"
									+	"</td>"
									+ "</tr>"		
					$('#rowInfoTable').append(appendStr);
					me.vendorComboRefresh();
				},
				
				
				delRow : function(){
					var me = this;
					
					var infoList= $("#rowInfoTable").children('tr');
					var memberChk = document.getElementsByName("RowCheck");
					var count=0;
					var indexAry=new Array();
					for(i=0; i < memberChk.length; i++){
						   if(memberChk[i].checked){ //true면 
							   indexAry[count]=i;
							   count++;							  
						   }
					}
					for(var j=0;j<count;j++){
						infoList.eq((indexAry[j])+1).remove();
					}

					me.vendorComboRefresh();
				},
				
				organizationNameSearch : function(){
					var popupID		= "orgmap_pop";
					var openerID	= "VendorPopup";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_orgChart' />";	//조직도
					var callBackFn	= "goOrgChart_CallBack";
					var type		= "B1";
					var popupUrl	= "/covicore/control/goOrgChart.do?"
									+ "popupID="		+ popupID		+ "&"
									+ "callBackFunc="	+ callBackFn	+ "&"
									+ "type="			+ type;
						
					parent.window[callBackFn] = window[openerID][callBackFn];
					parent.Common.open("", popupID, popupTit, popupUrl, "1000px","580px","iframe",true,null,null,true);
	
				},
				
				goOrgChart_CallBack : function(orgData){
					var items = JSON.parse(orgData).item;
					var name = items[0].DN.split(';')[0];
					var id = items[0].AN;
					$("#vendorPopup_inputORIdView").val(id);
					$("#vendorPopup_inputVendorNameOrg").val(name);
				},
	
				
				getTxTFieldDataPopup : function(field){
					return $("#"+field).val()
				},
				
				setFieldDataPopup : function(field, data) {
					return $("#"+field).val(data)
				},
				
				setFieldDisabledPopup : function(field, val) {
					$("#"+field).attr('disabled',val)
				}
		}
		window.VendorPopup = VendorPopup;
	})(window);
	
	VendorPopup.popupInit();

</script>