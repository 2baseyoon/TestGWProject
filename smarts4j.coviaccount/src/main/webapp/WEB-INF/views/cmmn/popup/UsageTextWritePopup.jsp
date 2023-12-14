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
	<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:500px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents" >
			<div class="popContent" style="position:relative;">
				<div class="middle">
					<table class="tableTypeRow tableStyle">
						<colgroup>
							<col style="width: 120px;">
							<col style="width: auto;">
						</colgroup>
						<tbody id="itemAdd">	
							<tr id="acArea" style="display: none;">
								<th>
									<!-- 계정과목 -->
									<spring:message code='Cache.ACC_lbl_account'/>
									<span class="star"></span>
								</th>
								<td style="width: 340px;">
									<div class="" style="width: 100%;">
										<input id="AccountCode" type="hidden">
										<input id="AccountName" type="text" readOnly class="HtmlCheckXSS ScriptCheckXSS">
										<a onclick="UsageTextWritePopup.accountSearchPopup()" id="accountSearchPopupID"	class="btnTypeDefault btnResInfo"><spring:message code='Cache.ACC_btn_search'/></a>
									</div>
								</td>
							</tr>
							<tr id="stArea" style="display: none;">
								<th>
									<!-- 표준적요 -->
									<spring:message code='Cache.ACC_standardBrief'/>
									<span class="star"></span>
								</th>
								<td style="width: 340px;">
									<div class="" style="width: 100%;">
										<input id="StandardBriefID" type="hidden">
										<input id="StandardBriefName" type="text" readOnly class="HtmlCheckXSS ScriptCheckXSS">
										<a onclick="UsageTextWritePopup.standardBriefSearchPopup()" id="standardBriefSearchPopupID"	class="btnTypeDefault btnResInfo"><spring:message code='Cache.ACC_btn_search'/></a>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<!-- 적요 -->
									<spring:message code='Cache.ACC_lbl_useHistory2'/>
									<span class="star"></span>
								</th>
								<td style="width: 340px;">
									<textarea class="write_info_list_textarea HtmlCheckXSS ScriptCheckXSS" id="UsageText" rows="5"></textarea>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div class="popBtnWrap bottom">
					<a onclick="UsageTextWritePopup.saveUsageText();"	id="btnSave"	class="btnTypeDefault btnThemeLine"><spring:message code='Cache.ACC_btn_save' /></a>
					<a onclick="UsageTextWritePopup.closeLayer();"		id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>
	if (!window.UsageTextWritePopup) {
		window.UsageTextWritePopup = {};
	}	
	
	(function(window) {		
		var companyCode = CFN_GetQueryString("companyCode");
		var validationMsg = "<spring:message code='Cache.CPEAccounting_chooseStandard' />"; //표준적요를 선택해주세요.
		var UsageTextWritePopup = {		
				receiptID : '',
				proofCode : '',
				popupInit : function(){
					var me = this;
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						me[paramKey] = paramValue;
					}
					
					if(Common.getBaseConfig("IsUseStandardBrief") == "Y") {
						$("#stArea").show();
					} else {
						$("#acArea").show();
						validationMsg = "<spring:message code='Cache.ACC_msg_selectAccountCode' />"; //계정을 선택해주세요.
					}
									
					if(!isEmptyStr(me.receiptID)){
						me.searchUsageTextData();
					}
				},

				searchUsageTextData : function(){
					var me = this;	
					$.ajax({
						url:"/account/accountCommon/searchUsageTextData.do",
						type : "POST",
						cache: false,
						data:{
							"ReceiptID" : me.receiptID,
							"ProofCode" : me.proofCode,
							"CompanyCode" : companyCode
						},
						success:function (data) {
							if(data.result == "ok"){
								if(data.data.list.length > 0) {
									var getData = data.data.list[0];
									
									$("#UsageText").val(getData.UsageText);
									$("#AccountCode").val(getData.AccountCode);
									$("#AccountName").val(getData.AccountName);
									$("#StandardBriefID").val(getData.StandardBriefID);
									$("#StandardBriefName").val(getData.StandardBriefName);
								}
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				accountSearchPopup : function() {
					var popupName	=	"AccountSearchPopup";
					var popupID		=	"accountSearchPopup";
					var openerID	=	"UsageTextWritePopup";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_account' />"; //계정과목
					var popupYN		=	"Y";
					var callBack	=	"accountSearchPopup_CallBack";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+	"popupYN="		+	popupYN		+	"&"
									+	"callBackFunc="	+	callBack;
					parent.Common.open(	"",popupID,popupTit,url,"740px","690px","iframe",true,null,null,true);
				},
				
				accountSearchPopup_CallBack : function(info){
					var me = this;
					
					var accountCode = info.AccountCode;
					var accountName = info.AccountName;
					
					$("#AccountCode").val(accountCode);
					$("#AccountName").val(accountName);
				},
				
				standardBriefSearchPopup : function() {
					var popupName	=	"StandardBriefSearchPopup";
					var popupID		=	"standardBriefSearchPopup";
					var openerID	=	"UsageTextWritePopup";
					var popupTit	=	"<spring:message code='Cache.ACC_standardBrief' />"; //표준적요
					var popupYN		=	"Y";
					var callBack	=	"standardBriefSearchPopup_CallBack";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+	"popupYN="		+	popupYN		+	"&"
									+	"companyCode="	+	companyCode	+	"&"
									+	"callBackFunc="	+	callBack;
					parent.Common.open(	"",popupID,popupTit,url,"1000px","700px","iframe",true,null,null,true);
				},
				
				standardBriefSearchPopup_CallBack : function(info){
					var me = this;
					
					var accountCode = info.AccountCode;
					var accountName = info.AccountName;
					var standardBriefID = info.StandardBriefID;
					var standardBriefName = info.StandardBriefName;
					
					$("#AccountCode").val(accountCode);
					$("#AccountName").val(accountName);
					$("#StandardBriefID").val(standardBriefID);
					$("#StandardBriefName").val(standardBriefName);
				},
				
				saveUsageText : function(){
					if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
					
					var me = this;
					var usageText = $("#UsageText").val();		
					var accountCode = $("#AccountCode").val();		
					var standardBriefID = $("#StandardBriefID").val();				
					
					if(accountCode == "" || standardBriefID == ""){
					    Common.Error(validationMsg);
					    return false;
					}
					$.ajax({
						url : "/account/accountCommon/saveUsageTextData.do",
						type : "POST",
						data : {
							"ReceiptID" : me.receiptID,
							"ProofCode" : me.proofCode,
							"UsageText" : usageText,
							"AccountCode" : accountCode,
							"StandardBriefID" : standardBriefID
						},
						success : function(data) {
							if (data.status == "SUCCESS"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
								
								UsageTextWritePopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error : function(error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
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
		window.UsageTextWritePopup = UsageTextWritePopup;
	})(window);
	
	UsageTextWritePopup.popupInit();
</script>