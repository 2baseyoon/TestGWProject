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
	<div class="layer_divpop ui-draggable docPopLayer" id="vendorPopup" style="width:900px;height:650px" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<table class="tableTypeRow">
					<colgroup>
					<col style="width: 17%;" />
					<col style="width: auto;" />
				</colgroup>
				<tbody>
					<tr>
						<!-- 회사 -->
						<th><spring:message code="Cache.ACC_lbl_company"/><span class="star"></span></th>
						<td >
							<div class="box">
								<span id="vendorRequestPopup_inputCompany"  style="width: 200px;" class="selectType02">
								</span>
							</div>
						</td>
					</tr>
					<tr>
						<!-- 제목 -->
						<th><spring:message code="Cache.ACC_lbl_title"/><span class="star"></span></th>
						<td >
							<div class="box" style="width: 100%;">
								<input id="vendorRequestPopup_inpupApplicationTitle" type="text" style="width: 85%;" placeholder="<spring:message code='Cache.ACC_msg_noTitle' />" class="HtmlCheckXSS ScriptCheckXSS" >	<!-- 제목을 입력하세요 -->
							</div>
						</td>
					</tr>
					<tr>
						<!-- 신청유형 -->
						<th><spring:message code="Cache.ACC_lbl_vendorRequestType"/></th>
						<td >
							<div class="box">
								<span id="vendorRequestPopup_inputApplicationType"  style="width: 200px;" class="selectType02" onChange="VendorRequestPopup.appTypeChange(this)">
								</span>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
				<div style="height:10px">
				</div>
				<div class="middle">
					<div id="bankChangeArea" style="display:none">
						<jsp:include page="VendorRequestPopupChange.jsp" ></jsp:include>
					</div>
					<div id="peopleArea" style="display:none">
						<jsp:include page="VendorRequestPopupPeople.jsp" ></jsp:include>
					</div>
					<div id="companyArea" style="display:none">
						<jsp:include page="VendorRequestPopupCompany.jsp" ></jsp:include>
					</div>
					<div id="organizationArea" style="display:none">
						<jsp:include page="VendorRequestPopupOrganization.jsp" ></jsp:include>
					</div>
				</div>
				<input type="hidden" id="vendorRequestPopup_inputVendorApplicationID" >
				<input type="hidden" id="vendorRequestPopup_inputIsSearched" >
				<input type="hidden" id="vendorRequestPopup_inputIsRegCheck" >
				<div class="popBtnWrap bottom">
					<a onclick="VendorRequestPopup.CheckValidation('T');"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save' /></a>
					<a onclick="VendorRequestPopup.CheckValidation('S');"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_application' /></a>
					<a onclick="VendorRequestPopup.closeLayer();"			id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel' /></a>
				</div>
			</div>
		</div>		
	</div>
</body>
<script>

if (!window.VendorRequestPopup) {
	window.VendorRequestPopup = {};
}

(function(window) {
	var i=1;
	var VendorRequestPopup = {
			params : {
				pageDataObj				: {},
				pageVendorApplicationID	: "${VendorApplicationID}"
			},
			
			popupInit : function(){
				var me = window.VendorRequestPopup;
				
				accountCtrl.renderAXSelect('CompanyCode', 'vendorRequestPopup_inputCompany', 'ko','','','');
				accountCtrl.renderAXSelect('VendorApplicationType',	'vendorRequestPopup_inputApplicationType',	'ko','','','', null, accountCtrl.getComboInfo("vendorRequestPopup_inputCompany").val());

				me.peopleComboMake();
				me.companyComboMake();
				me.organizationComboMake();
				
				setFieldDataPopup("vendorRequestPopup_inputIsSearched", "${isSearched}");
				
				if("${isSearched}" == "Y"){
					var getVendorApplicationID = "${VendorApplicationID}";
					me.searchDetailData(getVendorApplicationID);
				} else{
					$("#bankChangeArea").css("display", "");
					$("#peopleArea").css("display", "none");
					$("#companyArea").css("display", "none");
					$("#organizationArea").css("display", "none");
				}
			},
			
			searchDetailData : function(getVendorApplicationID) {
				var me = window.VendorRequestPopup;
				setFieldDataPopup("vendorRequestPopup_inputIsSearched", "Y");

				var searchVendorApplicationID = "";
				if(	getVendorApplicationID == null	||
					isEmptyStr(getVendorApplicationID)){
					searchVendorApplicationID	= me.params.pageVendorApplicationID;
				}else{
					searchVendorApplicationID			= getVendorApplicationID;
					me.params.pageVendorApplicationID	= getVendorApplicationID;
				}
				
				setFieldDataPopup("vendorRequestPopup_inputVendorApplicationID", me.params.pageVendorApplicationID);
				
				var getCompanyCode = accountCtrl.getComboInfo("vendorRequestPopup_inputCompany").val();
			
				$.ajaxSetup({
					cache : false
				});
				
				$.getJSON('/account/baseInfo/searchVendorRequestDetail.do', {VendorApplicationID : getVendorApplicationID, companyCode : getCompanyCode}
					, function(r) {
						if(r.result == "ok"){
							var data = r.data
							accountCtrl.getComboInfo("vendorRequestPopup_inputApplicationType").bindSelectSetValue(data.ApplicationType)
							setFieldDataPopup("vendorRequestPopup_inpupApplicationTitle",data.ApplicationTitle);

							var ApplicationType = data.ApplicationType
							if(ApplicationType == "BankChange"){
								me.setVendorRequestChangeData(data);
							}
							else if(ApplicationType == "People"){
								me.setVendorRequestPeopleData(data);
							}
							else if(ApplicationType == "Company"){
								me.setVendorRequestCompanyData(data);
							}
							else if(ApplicationType == "Organization"){
								me.setVendorRequestOrganizationData(data);
							}
							
							//setVendorData(data);
							//setFieldDisabledPopup("vendorRequestPopup_inputVendorNo", true);
							//setFieldDisabledPopup("vendorRequestPopup_inputCorporateNo", true);
						}
				}).error(function(response, status, error){
					//TODO 추가 오류 처리
					//CFN_ErrorAjax("getGroupList.do", response, status, error);
				});
			},

			appTypeChange : function(input) {
				var me = window.VendorRequestPopup;
				var val = input.value;

				if(input.tagName !="SELECT"){
					return;
				}
				
				var popupH = '0px';
				if(val == "BankChange"){
					$("#bankChangeArea").css("display", "");
					$("#peopleArea").css("display", "none");
					$("#companyArea").css("display", "none");
					$("#organizationArea").css("display", "none");
					popupH = '400px';
				}else if(val == "People"){
					$("#bankChangeArea").css("display", "none");
					$("#peopleArea").css("display", "");
					$("#companyArea").css("display", "none");
					$("#organizationArea").css("display", "none");
					me.peopleComboRefresh();
					popupH = '570px';
				}else if(val == "Company"){
					$("#bankChangeArea").css("display", "none");
					$("#peopleArea").css("display", "none");
					$("#companyArea").css("display", "");
					$("#organizationArea").css("display", "none");
					me.companyComboRefresh();
					popupH = '630px';
				}else if(val == "Organization"){
					$("#bankChangeArea").css("display", "none");
					$("#peopleArea").css("display", "none");
					$("#companyArea").css("display", "none");
					$("#organizationArea").css("display", "");
					me.organizationComboRefresh();
					popupH = '630px';
				}
		
				
				accountCtrl.changePopupSize('',popupH);
			},

			CheckValidation : function(type) {
				if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				
				var me = window.VendorRequestPopup;
				me.params.pageDataObj = {};
							
				var CompanyCode			= accountCtrl.getComboInfo("vendorRequestPopup_inputCompany").val();
				var ApplicationID		= getTxTFieldDataPopup("vendorRequestPopup_inputVendorApplicationID");
				var ApplicationType		= accountCtrl.getComboInfo("vendorRequestPopup_inputApplicationType").val();
				var ApplicationTitle	= getTxTFieldDataPopup("vendorRequestPopup_inpupApplicationTitle");
				var IsSearched			= getTxTFieldDataPopup("vendorRequestPopup_inputIsSearched");
				var IsRegCheck			= getTxTFieldDataPopup("vendorRequestPopup_inputIsRegCheck");
				var BankName = new Array();
				var AccountNo = new Array();
				var BankNameID = "";
				var AccountNoID = "";

				me.params.pageDataObj.CompanyCode			= CompanyCode;
				me.params.pageDataObj.VendorApplicationID	= ApplicationID;
				me.params.pageDataObj.SessionUser			= Common.getSession().USERID
				me.params.pageDataObj.ApplicationType		= ApplicationType;
				me.params.pageDataObj.ApplicationTitle		= ApplicationTitle;
				me.params.pageDataObj.IsSearched			= IsSearched;
				me.params.pageDataObj.ApplicationStatus = type;
	
				if(	ApplicationType == null	||
					isEmptyStr(ApplicationType)){
					Common.Inform("<spring:message code='Cache.ACC_011'/>");	//신청유형을 선택해 주십시오.
					return;
				}
											
				if(	ApplicationTitle == null	||
					isEmptyStr(ApplicationTitle)){
					Common.Inform("<spring:message code='Cache.ACC_012'/>");	//제목을 입력해 주십시오.
					return;
				}
				
				switch(ApplicationType){
					case "BankChange" :
						BankNameID = "vendorRequestPopupChange_inputBankName";
						AccountNoID = "vendorRequestPopupChange_inputBankAccountNo";
						AccountNameID = "vendorRequestPopupChange_inputBankAccountName";
						break;
					default :
						BankNameID = "vendorRequestPopup"+ApplicationType+"_inputBankName";
						AccountNoID = "vendorRequestPopup"+ApplicationType+"_inputBankAccountNo";
						AccountNameID = "vendorRequestPopup"+ApplicationType+"_inputBankAccountName";
						break;
				}				
				
				for(var i=0; i<$("#rowInfoTable" + ApplicationType).children('tr').length-1; i++){					
					if(	getTxTFieldDataPopup(BankNameID+(i+1)) != null && !(isEmptyStr(getTxTFieldDataPopup(BankNameID+(i+1)))) ){
						if(	getTxTFieldDataPopup(AccountNoID+(i+1)) == null || isEmptyStr(getTxTFieldDataPopup(AccountNoID+(i+1)))){
							Common.Inform("<spring:message code='Cache.ACC_accountno'/>");	//은행계좌를 입력해주십시오.
							return;
						}	
						if(	getTxTFieldDataPopup(AccountNameID+(i+1)) == null || isEmptyStr(getTxTFieldDataPopup(AccountNameID+(i+1)))){
							Common.Inform("<spring:message code='Cache.ACC_msg_noDataBankOwner'/>");	//예금주를 입력해주십시오.
							return;
						}
					}	
					
				}
				
				if(	IsRegCheck!="Y"	&&
					(	ApplicationType == "People"	||
						ApplicationType == "Company")){
					Common.Inform("<spring:message code='Cache.ACC_010'/>");	//저장 전 등록확인을 해 주시기 바랍니다.
					return;
				}
				
				if(ApplicationType == "BankChange"){
					me.getVendorRequestChangeData();
				}else if(ApplicationType == "People"){
					me.getVendorRequestPeopleData();
				}else if(ApplicationType == "Company"){
					me.getVendorRequestCompanyData();
				}else if(ApplicationType == "Organization"){
					me.getVendorRequestOrganizationData();
				}

				var msg = "ACC_isSaveCk";	//저장하시겠습니까?
				if(type=="S"){
					msg = "ACC_isAppCk"		//신청하시겠습니까?
				}
				
				if( chkInputCode(ApplicationTitle) ||
					chkInputCode(me.params.pageDataObj.BankAccountName) ||
					chkInputCode(me.params.pageDataObj.VendorName) ||
					chkInputCode(me.params.pageDataObj.Address) ||
					chkInputCode(me.params.pageDataObj.CEOName) ||
					chkInputCode(me.params.pageDataObj.CorporateNo) ||
					chkInputCode(me.params.pageDataObj.Industry)||
					chkInputCode(me.params.pageDataObj.Sector)){
					Common.Inform("<spring:message code='Cache.ACC_msg_case_1' />");		//<는 사용할수 없습니다.
					return;
				}
				
				Common.Confirm(Common.getDic(msg), "Confirmation Dialog", function(result){
					if(result){
						me.saveVendorRequestData();
					}
				});
			},

			saveVendorRequestData : function() {
				var me = window.VendorRequestPopup;

				$.ajax({
					type:"POST",
					url:"/account/baseInfo/saveVendorRequestData.do",
					data:{
						"vendorRequestDataObj" : JSON.stringify(me.params.pageDataObj),
					},
					success:function(data) {
						if(data.result == "ok"){
							parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
							try{
								accountCtrl.popupCallBackStr([]);
							}catch (e){
								coviCmn.traceLog(e);
								coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
							}
							me.closeLayer();
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의바랍니다.
						}
					},
					error:function(error){
						Common.Error(error.message);
						
					}
				});
			},

			popup_index : 0,
			bankSearchPopup : function(index) {
				var me = this;
				me.popup_index = index;
				var popupID		=	"bankSelectPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_bankSelect'/>";	//은행선택
				var popupName	=	"BankSearchPopup";
				var openerID	=	"VendorRequestPopup";
				var callBack	=	"selectBankCode";
				var CompanyCode	= accountCtrl.getComboInfo("vendorRequestPopup_inputCompany").val();
				var popupYN		=	"Y";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"openerID="		+	openerID	+	"&"
								+	"popupYN="		+	popupYN		+	"&"
								+	"companyCode="	+	CompanyCode	+	"&"
								+	"callBackFunc="	+	callBack;
				parent.Common.open(	"",popupID,popupTit,url,"350px","400px","iframe",true,null,null,true);
			},

			selectBankCode : function(bankInfo){
				var me = this;
				var val = accountCtrl.getComboInfo("vendorRequestPopup_inputApplicationType").val();
				if(val == "BankChange"){
					setFieldDataPopup("vendorRequestPopupChange_inputBankCode"+me.popup_index,bankInfo.Code);
					setFieldDataPopup("vendorRequestPopupChange_inputBankName"+me.popup_index,bankInfo.CodeName);
				}
				else if(val == "People"){
					setFieldDataPopup("vendorRequestPopupPeople_inputBankCode"+me.popup_index,bankInfo.Code);
					setFieldDataPopup("vendorRequestPopupPeople_inputBankName"+me.popup_index,bankInfo.CodeName);
				}
				else if(val == "Company"){
					setFieldDataPopup("vendorRequestPopupCompany_inputBankCode"+me.popup_index,bankInfo.Code);
					setFieldDataPopup("vendorRequestPopupCompany_inputBankName"+me.popup_index,bankInfo.CodeName);
				}
				else if(val == "Organization"){
					setFieldDataPopup("vendorRequestPopupOrganization_inputBankCode"+me.popup_index,bankInfo.Code);
					setFieldDataPopup("vendorRequestPopupOrganization_inputBankName"+me.popup_index,bankInfo.CodeName);
				}
				
			},

			vendorSelectPopup : function(){
				var popupID		=	"vendorSelectPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_vendor'/>";	//거래처 선택
				var popupYN		=	"Y";
				var popupName	=	"VendorSearchPopup";
				var openerID	=	"VendorRequestPopup";
				var callBack	=	"selectVendorInfo";
				var CompanyCode	= accountCtrl.getComboInfo("vendorRequestPopup_inputCompany").val();
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"openerID="		+	openerID	+	"&"
								+	"popupYN="		+	popupYN		+	"&"
								+	"includeAccount=N&"
								+	"companyCode="	+	CompanyCode	+	"&"
								+	"callBackFunc="	+	callBack;
				parent.Common.open(	"",popupID,popupTit,url,"700px","630px","iframe",true,null,null,true);
			},
			
			selectVendorInfo : function(vdInfo) {
				setFieldDataPopup("vendorRequestPopupChange_inputVendorID",		vdInfo.VendorID);
				setFieldDataPopup("vendorRequestPopupChange_inputVendorName",	vdInfo.VendorName);
				setFieldDataPopup("vendorRequestPopupChange_inputVendorNo",		vdInfo.VendorNo);
			},

			regCheck : function(data) {
				var me = window.VendorRequestPopup;
				var CompanyCode		= accountCtrl.getComboInfo("vendorRequestPopup_inputCompany").val();
				var VendorNo		= "";
				var IsNew			= "";
				var VendorType		= "";
				var ApplicationType	= accountCtrl.getComboInfo("vendorRequestPopup_inputApplicationType").val();
				
				if(ApplicationType == "BankChange"){
					
				}else if(ApplicationType == "People"){
					VendorNo	= getTxTFieldDataPopup("vendorRequestPopupPeople_inputVendorNo");
					if(VendorNo.replace(/-/gi, '').length != 13){
						Common.Inform("<spring:message code='Cache.ACC_032'/>");	//형식이 올바르지 않습니다.
						return;
					}
					IsNew		= $("input[name=vendorRequestPopupPeople_inputVendorIsNew]:checked").val();
					VendorType	= "PE"
				}else if(ApplicationType == "Company"){
					VendorNo	= getTxTFieldDataPopup("vendorRequestPopupCompany_inputVendorNo");
					IsNew		= $("input[name=vendorRequestPopupCompany_inputVendorIsNew]:checked").val();
					VendorType	= "CO"
				}else if(ApplicationType == "Organization"){
					VendorNo	= getTxTFieldDataPopup("vendorRequestPopupOrganization_inputVendorNoView");
					IsNew		= $("input[name=vendorRequestPopupOrganization_inputVendorIsNew]:checked").val();
					VendorType	= "OR"
				} 

				if(isEmptyStr(VendorNo)){
					Common.Inform("<spring:message code='Cache.ACC_005'/>");	//사업자 번호를 입력해주세요.
					return;
				}
				$.ajax({
					type:"POST",
						url:"/account/baseInfo/checkVendorDuplicate.do",
					data:{
						"VendorNo"		: VendorNo,
						"VendorType"	: VendorType,
						"CompanyCode"	: CompanyCode
					},
					success:function(data) {
						if(data.result == "ok"){
							var duplItem = data.duplItem;
							if(duplItem != null){
								var duplCnt	= duplItem.CNT;
								var duplID	= duplItem.VendorID;
								if(duplCnt != 0){
									var msg = "<spring:message code='Cache.ACC_006'/>"	//등록되어 있는 거래처 입니다.
									if(IsNew=="Y"){
										msg=msg+"<br>"+"<spring:message code='Cache.ACC_008'/>"	//변경 신청을 하시겠습니까?

										Common.Confirm(msg, "Confirmation Dialog", function(result){
											if(result){
												me.setIsNew('N');
												me.setRegCk('Y');
											}
										});
									}else{
										Common.Inform(msg);
										me.setRegCk('Y');
									}
									
									
								}else{
									var msg = "<spring:message code='Cache.ACC_007'/>"	//등록되어 있지 않은 거래처입니다.
									if(IsNew!="Y"){
										msg=msg+"<br>"+"<spring:message code='Cache.ACC_009'/>"	//신규신청을 하시겠습니까??
										Common.Confirm(msg, "Confirmation Dialog", function(result){
											if(result){
												me.setIsNew('Y');
												me.setRegCk('Y');
											}
										});
									}else{
										Common.Inform(msg);
										me.setRegCk('Y');
									}
								}
								//06/등록되어 있는 거래처 입니다.
								//07/등록되어 있지 않은
								//ACC_008 변경신청을 하시겠습니까?
								//ACC_009 신규신청을 하시겠습니까?
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error'/>");	//오류가 발생하였습니다.
							}
							//parent.searchBaseCode();
							//parent.comboInit();
						}else{
							Common.Error(data.message);
						}
					},
					error:function(error){
						Common.Error(error.message);
					}
				});
			},
			
			setIsNew : function(val) {
				var me = this;
				var ApplicationType = accountCtrl.getComboInfo("vendorRequestPopup_inputApplicationType").val();
				if(ApplicationType == "People"){
					$("input[name=vendorRequestPopupPeople_inputVendorIsNew]:radio[value='"+val+"']").prop("checked", true);
					me.peopleIsNewChange();
				}else if(ApplicationType == "Company"){
					$("input[name=vendorRequestPopupCompany_inputVendorIsNew]:radio[value='"+val+"']").prop("checked", true);
					me.companyIsNewChange();
				}
			},

			setRegCk : function(val) {
				setFieldDataPopup("vendorRequestPopup_inputIsRegCheck",val);
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
			
			organizationNameSearch : function(){
				var popupID		= "orgmap_pop";
				var openerID	= "VendorRequestPopup";
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
				$("#vendorRequestPopupOrganization_inputVendorNoView").val(id);
				$("#vendorRequestPopupOrganization_inputVendorName").val(name);
			},
			
			ckAccountNo : function(obj){
				var me = this;
				var val = obj.value;
				var strVal = "";
				
				if(val != null){
					val=val.toString();
					val = val.replaceAll("-", "");
					//val = val.substr(0,13)
					if(isNaN(val)){
						strVal = "";
						val = "";
					}
					else{
						//strVal = me.vdNoFormat(val);
						strVal = val;
					}
					obj.value = strVal
				}
				
			}
	}
	window.VendorRequestPopup = $.extend(window.VendorRequestPopup, VendorRequestPopup);

})(window);

VendorRequestPopup.popupInit();

</script>