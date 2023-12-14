<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/account/resources/script/admin/baseCodeCommon.js<%=resourceVersion%>"></script>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>
<body>	
	<div class="layer_divpop ui-draggable docPopLayer" style="width:416px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="rowTypeWrap formWrap tsize">
					<dl>
						<dt>
							<!-- 카드번호 -->
							<spring:message code="Cache.ACC_lbl_cardNumber"/>
						</dt>
						<dd>
							<input type="text" id="priCardViewPop_inputCardNo" disabled="true">
						</dd>
					</dl>
					<dl>
						<dt>
							<!-- 카드회사 -->
							<spring:message code="Cache.ACC_lbl_cardCompany"/>
						</dt>
						<dd>
							<input type="text" id="priCardViewPop_inputCardCompany" disabled="true">
						</dd>
					</dl>
					<dl>
						<dt>
							<!-- 소유자 -->
							<spring:message code="Cache.ACC_lbl_cardOwner"/>
						</dt>
						<dd>
							<input type="text" id="priCardViewPop_inputRegisterName" disabled="true">
						</dd>
					</dl>
					
					<dl>
						<dt>
							<!-- 사용여부 -->
							<spring:message code="Cache.ACC_lbl_isUse"/>
						</dt>
						<dd>
							<span id="priCardViewPop_inputIsUse" class="selectType06">
							</span>
						</dd>
					</dl>
					<dl>
						<dt>
							<!-- 신청사유 -->
							<spring:message code="Cache.ACC_lbl_applicationReason"/>
						</dt>
						<dd>
							<textarea id="priCardViewPop_inputApplicationReason" row="10" style="height:135px" disabled="true"></textarea>
						</dd>
					</dl>
				</div>
			
				<input type="hidden" id="priCardViewPop_inputCardApplicationID" >
				
				<div class="popBtnWrap">
					<a onclick="PrivateCardViewPopup.CheckValidation();"	id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save' /></a>
					<a onclick="PrivateCardViewPopup.closeLayer();"			id="btnClose" class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel' /></a>
				</div>
				
			</div>
		</div>	
	</div>
</body>
<script>

if (!window.PrivateCardViewPopup) {
	window.PrivateCardViewPopup = {};
}	

(function(window) {
	
	var PrivateCardViewPopup = {
			params : {
					searchedData: {}
				,	pageDataObj	: {}
			},
			
			popupInit : function(){
				var me = this;
				accountCtrl.renderAXSelect('UseYN',	'priCardViewPop_inputIsUse',	'ko','','','');

				var CardApplicationID = "${CardApplicationID}"
				$.ajaxSetup({
					cache : false
				});
				
				$.getJSON('/account/baseInfo/searchCardApplicationDetail.do', {CardApplicationID : CardApplicationID}
					, function(r) {
						if(r.result == "ok"){
							var data = r.data
							me.setCardData(data);
							me.params.searchedData = data;
						}
						
				}).error(function(response, status, error){
					Common.Error("ERROR");
				});
			},
			
			CheckValidation : function(){
				var me = this;
				me.getCardData();
				
				if(isEmptyStr(me.params.pageDataObj.CardApplicationID)){
					Common.Error("<spring:message code='Cache.ACC_Valid'/>");	//입력되지 않은 필수값이 있습니다.
					return;
				}

		        Common.Confirm("<spring:message code='Cache.ACC_isSaveCk' />", "Confirmation Dialog", function(result){	//저장하시겠습니까?
		       		if(result){
		       			me.savePrivateCardUseyn();
		       		}
		        });
			},

			savePrivateCardUseyn : function(){
				var me = this;
				var privateCardAppObj	= me.params.pageDataObj;
				
				$.ajax({
					type:"POST",
						url:"/account/baseInfo/savePrivateCardUseyn.do",
					data:{
						"privateCardAppObj" : JSON.stringify(privateCardAppObj),
					},
					success:function (data) {
						if(data.result == "ok"){
							parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
							
							PrivateCardViewPopup.closeLayer();
							
							try{
								accountCtrl.popupCallBackStr([]);
							}catch (e) {
								coviCmn.traceLog(e);
								coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
							}
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의바랍니다.
						}
					},
					error:function (error){
						if(error.result == "D"){
							Common.Error("<spring:message code='Cache.ACC_DuplCode'/>");
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의바랍니다.
						}
					}
				});
			},
			
			getCardData : function() {
				var me = this;
				me.params.pageDataObj = {};
				me.params.pageDataObj.CardApplicationID	= getTxTFieldDataPopup("priCardViewPop_inputCardApplicationID");
				me.params.pageDataObj.CardNo			= getTxTFieldDataPopup("priCardViewPop_inputCardNo");
				me.params.pageDataObj.CardCompanyName	= getTxTFieldDataPopup("priCardViewPop_inputCardCompany");
				me.params.pageDataObj.RegisterName		= getTxTFieldDataPopup("priCardViewPop_inputRegisterName");
				me.params.pageDataObj.ApplicationReason	= getTxTFieldDataPopup("priCardViewPop_inputApplicationReason");
				me.params.pageDataObj.IsUse				= getTxTFieldDataPopup("priCardViewPop_inputIsUse");
				me.params.pageDataObj.SessionUser		= Common.getSession().USERID;
			},

			setCardData : function(data){
				setFieldDataPopup("priCardViewPop_inputCardApplicationID",	data.CardApplicationID );
				setFieldDataPopup("priCardViewPop_inputCardNo",				data.CardNo );
				setFieldDataPopup("priCardViewPop_inputCardCompany",			data.CardCompanyName );
				setFieldDataPopup("priCardViewPop_inputRegisterName",		data.RegisterName );
				setFieldDataPopup("priCardViewPop_inputApplicationReason",	data.ApplicationReason );
				$("#priCardViewPop_inputIsUse").bindSelectSetValue(data.IsUse);
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
	window.PrivateCardViewPopup = PrivateCardViewPopup;
})(window);

PrivateCardViewPopup.popupInit();
	
</script>