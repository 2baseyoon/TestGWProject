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
	<input id="mode"		type="hidden" />
	<input id="accountID"	type="hidden" />
	<input id="accountCD"	type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" style="width:520px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
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
									<spring:message code='Cache.ACC_lbl_company'/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<span id="companyCode" class="selectType06">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_accountClass'/>	<!-- 계정유형 -->
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<span id="accountClass" class="selectType06">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_accountCode'/>	<!-- 계정코드 -->
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input id="accountCode" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS" onkeyup="AccountPopup.toNumFormat(this)">
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_account'/>	<!-- 계정과목 -->
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input id="accountName" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_shortName'/>	<!-- 단축명 -->
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input id="accountShortName" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr style="display: none;">
								<th>
									<spring:message code='Cache.ACC_lbl_taxType'/>	<!-- 부가세 -->
								</th>
								<td>
									<div class="box">
										<span id="taxType" class="selectType06">
										</span>
									</div>
								</td>
							</tr>
							<tr style="display: none;">
								<th>
									<spring:message code='Cache.ACC_lbl_taxCode'/>	<!-- 과세유형 -->
								</th>
								<td>
									<div class="box">
										<span id="taxCode" class="selectType06">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_isUse'/>	<!-- 사용여부 -->
								</th>
								<td>
									<div class="box">
										<span id="isUse" class="selectType06">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>
									<spring:message code='Cache.ACC_lbl_description'/>	<!-- 비고 -->
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
					<a onclick="AccountPopup.CheckValidation();"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save'/></a> 	<!-- 저장 -->
					<a onclick="AccountPopup.closeLayer();"			id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>				<!-- 취소 -->
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

if (!window.AccountPopup) {
	window.AccountPopup = {};
}

(function(window) {
	
	var AccountPopup = {
			popupInit : function() {
				var me = this;
				var param = location.search.substring(1).split('&');
				for(var i = 0; i < param.length; i++){
					var paramKey	= param[i].split('=')[0];
					var paramValue	= param[i].split('=')[1];
					$("#"+paramKey).val(paramValue);
				}
				
				me.setSelectCombo();
				me.setPopupEdit();
				me.getPopupInfo();
				
				$("#companyCode").attr("onchange", "AccountPopup.changeCompanyCode()");
			},
			
			//팝업 수정
			setPopupEdit : function(){
				var mode		= $("#mode").val();
				var accountId	= $("#accountId").val();
				if (mode == 'modify') {
					$("#accountCode").attr("disabled", true);
				}
				$("#taxCode").parents("tr").css("display", "");
				$("#taxType").parents("tr").css("display", "");
			},
			
			//콤보 설정
			setSelectCombo : function(pCompanyCode){
				$("#accountClass").children().remove();
				$("#taxCode").children().remove();
				$("#taxType").children().remove();
				$("#isUse").children().remove();
				
				$("#accountClass").addClass("selectType06");
				$("#taxCode").addClass("selectType06");
				$("#taxType").addClass("selectType06");
				$("#isUse").addClass("selectType06");
				
				var AXSelectMultiArr	= [	
							{'codeGroup':'AccountClass',	'target':'accountClass',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'TaxCode',			'target':'taxCode',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_choice' />"}
						,	{'codeGroup':'TaxType',			'target':'taxType',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_choice' />"}
						,	{'codeGroup':'IsUse',			'target':'isUse',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
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
			
			//팝업 정보
			getPopupInfo : function(){
				var mode		= $("#mode").val();
				var accountID	= $("#accountID").val();
				
				if (mode == 'modify') {
					$.ajax({
						url	:"/account/accountManage/getAccountManageDetail.do",
						type: "POST",
						data: {
							"accountID"	: accountID
						},
						async: false,
						success:function (data) {
							if(data.result == "ok"){
								var info = data.list[0];
								$("#accountID").val(info.AccountID);
								accountCtrl.getComboInfo("companyCode").bindSelectSetValue(info.CompanyCode);
								accountCtrl.getComboInfo("accountClass").bindSelectSetValue(info.AccountClass);
								$("#accountCode").val(info.AccountCode);
								$("#accountName").val(info.AccountName);
								$("#accountShortName").val(info.AccountShortName);
								accountCtrl.getComboInfo("taxType").bindSelectSetValue(info.TaxType);
								accountCtrl.getComboInfo("taxCode").bindSelectSetValue(info.TaxCode);
								accountCtrl.getComboInfo("isUse").bindSelectSetValue(info.IsUse);
								$("#description").val(info.Description);
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				}
				
			},
			
			toNumFormat: function(element) {
				var val = $(element).val();
				if(val != undefined) {
					$(element).val(ckNaN(val.replace(/[^0-9]/g, "")));
				}
			},
			
			CheckValidation : function(){
			    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
			    var mode = $("#mode").val();
				
				var accountID			= $("#accountID").val();		//계정관리 ID
				var companyCode			= accountCtrl.getComboInfo("companyCode").val();	//회사 코드
				var accountClass		= accountCtrl.getComboInfo("accountClass").val();	//계정유형(공통코드)
				var accountCode			= $("#accountCode").val();		//계정 코드
				var accountName			= $("#accountName").val();		//계정 명
				var accountShortName	= $("#accountShortName").val();	//계정단축 명
				var taxType				= accountCtrl.getComboInfo("taxType").val();		//부가세
				var taxCode				= accountCtrl.getComboInfo("taxCode").val();		//과세유형
				var isUse				= accountCtrl.getComboInfo("isUse").val();			//사용 여부
				var description			= $("#description").val();		//비고
				
				if( chkInputCode(accountCode)	||
					chkInputCode(accountName) 	||
					chkInputCode(accountShortName) ||
					chkInputCode(description)){
						Common.Inform("<spring:message code='Cache.ACC_msg_case_1' />");	// <는 사용할수 없습니다.
						return;
					}
				
				if(accountCode == null ||  accountCode == ''){
					Common.Inform("<spring:message code='Cache.ACC_msg_noAccountCode' />")	//계정코드를 입력해주세요.
					return;
				}
				
				if(accountCode.match(/[^0-9]/g) != undefined){
					if(accountCode.match(/[^0-9]/g).length > 0) {
						Common.Inform("<spring:message code='Cache.ACC_msg_accountCodeOnlyNum' />")	//계정코드는 숫자만 입력가능합니다.
						return;
					}
				}
				
				var params = {
							"accountID"			: accountID
						,	"companyCode"		: companyCode
						,	"accountClass"		: accountClass
						,	"accountCode"		: accountCode
						,	"accountName"		: accountName
						,	"accountShortName"	: accountShortName
						,	"taxType"			: taxType
						,	"taxCode"			: taxCode
						,	"isUse"				: isUse
						,	"description"		: description
				};
				 
				$.ajax({
					url	: "/account/accountManage/saveAccountManageInfo.do",
					type: "POST",
					data: params,
					success:function (data) {
						if(data.status == "SUCCESS"){
							if(data.result == 'code'){
								Common.Inform("<spring:message code='Cache.ACC_msg_existAccountCode' />");	//이미 존재하는 계정코드입니다.
							}else{
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다.
								
								AccountPopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
							}
						}else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			closeLayer : function(){
				var isWindowed = CFN_GetQueryString("CFN_OpenedWindow");
				var popupID		= CFN_GetQueryString("popupID");
				
				if(isWindowed.toLowerCase() == "true") {
					window.close();
				} else {
					parent.Common.close(popupID);
				}
			}
	}
	window.AccountPopup = AccountPopup;
})(window);

AccountPopup.popupInit();
	
</script>