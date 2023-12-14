<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/account/resources/script/user/baseCodeCommon.js<%=resourceVersion%>"></script>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>	
	<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents" name="baseCodeView_displayArea" style="display:none">
			<div class="popContent" style="position:relative;" >
				<div class="middle">
				
					<table class="tableTypeRow">
						<colgroup>
							<col style="width: 200px;">
							<col style="width: auto;">
						</colgroup>
						<tbody>
							<tr>
								<th  name="baseCodeViewPopup_codeLabel"></th>
								<td>
									<div class="box">
										<input type="text" id="viewCode" disabled="true">
									</div>
								</td>
							</tr>
							<tr>
								<th name="baseCodeViewPopup_codeNameLabel"></th>
								<td>
									<div class="box">
										<input type="text" id="inputCodeName" placeholder="">
									</div>
								</td>
							</tr>
							<tr  name="baseCodeViewPopup_reserved1Area" style="display:none">
								<th  name="baseCodeViewPopup_reserved1Label" ></th>
								<td>
									<div class="box">
										<input type="text" id="inputReserved1" placeholder="">
									</div>
								</td>
							</tr>
							<tr name="baseCodeViewPopup_reserved2Area" style="display:none" >
								<th name="baseCodeViewPopup_reserved2Label"></th>
								<td>
									<div class="box">
										<input type="text" id="inputReserved2" placeholder="">
									</div>
								</td>
							</tr>
							<tr  name="baseCodeViewPopup_reserved3Alea" style="display:none">
								<th name="baseCodeViewPopup_reserved3Label"></th>
								<td>
									<div class="box">
										<input type="text" id="inputReserved3" placeholder="">
									</div>
								</td>
							</tr>
							<tr name="baseCodeViewPopup_reservedIntArea" style="display:none" >
								<th name="baseCodeViewPopup_reservedInt"></th>
								<td>
									<div class="box">
										<input type="text" id="inputReservedInt" placeholder="">
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 사용여부 -->
									<spring:message code="Cache.ACC_lbl_isUse"/>
								</th>
								<td>
									<div class="box">
										<span id="inputIsUse" class="selectType06">
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<th>	<!-- 동기화일시 -->
									<spring:message code="Cache.ACC_lbl_syncDate"/>
								</th>
								<td>
									<div class="box">
										<input type="text" id="inputRegistDate" disabled="true">
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				<input type="hidden" id="hiddenBaseCodeID" >
				<input type="hidden" id="hiddenIsGroup" >
				<input type="hidden" id="hiddenCodeGroup" >
				<input type="hidden" id="hiddenCodeGroupName" >
				<input type="hidden" id="hiddenSortKey" >
				<input type="hidden" id="hiddenCompanyCode" >
			</div>
			<div class="bottom">
				<a onclick="BaseCodeViewPopup.CheckValidation(this);"	id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save' /></a>
				<a onclick="BaseCodeViewPopup.closeLayer();"			id="btnClose" class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel' /></a>
			</div>
		</div>	
		
		
	</div>
</body>
<script>

	if (!window.BaseCodeViewPopup) {
		window.BaseCodeViewPopup = {};
	}
	
	(function(window) {
		var BaseCodeViewPopup = {
				params : {
					lblObj			: baseCodeCommon.getLabelObj("${groupCode}"),
					groupCode		: "${groupCode}",
					codeDataObj		: {},
					searchedData	: {}
				},
				
				/**
				화면 초기화
				*/
				popupInit : function(){
					var me = this;
					accountCtrl.renderAXSelect('IsUse',	'inputIsUse',	'ko','','','');
					me.setLabel();
					me.setFieldDataPopup("inputIsNew", "${isNew}");
					var baseCodeId = "${baseCodeId}"
					$.ajaxSetup({
						cache : false
					});
					$.getJSON('/account/baseCode/searchBaseCodeDetail.do', {BaseCodeID : baseCodeId}
						, function(r) {
							if(r.result == "ok"){
								var data = r.data
								if(data.IsGroup == "Y"){
								}else{
									me.setCodeData(data);
									me.params.searchedData = data;
								}
							}
					}).error(function(response, status, error){
						CFN_ErrorAjax("getGroupList.do", response, status, error);
					});
				},
				
				/**
				분류코드에 따라 라벨 세팅
				*/
				setLabel : function() {
					var me = this;
					
					if(me.params.lblObj != null){
						$("th[name=baseCodeViewPopup_codeLabel]").html(me.params.lblObj.Code);
						$("th[name=baseCodeViewPopup_codeNameLabel]").html(me.params.lblObj.CodeName);
						//====
						if(me.params.lblObj.Reserved1 != null){
							$("th[name=baseCodeViewPopup_reserved1Label]").html(me.params.lblObj.Reserved1);
							$("tr[name=baseCodeViewPopup_reserved1Area]").css({"display":""});
						}
						else{
							$("tr[name=baseCodeViewPopup_reserved1Area]").css({"display":"none"});
						}
						//====
						if(me.params.lblObj.Reserved2 != null){
							$("th[name=baseCodeViewPopup_reserved2Label]").html(me.params.lblObj.Reserved2);
							$("tr[name=baseCodeViewPopup_reserved2Area]").css({"display":""});
						}
						else{
							$("tr[name=baseCodeViewPopup_reserved2Area]").css({"display":"none"});
						}
						//====
						if(me.params.lblObj.Reserved3 != null){
							$("th[name=baseCodeViewPopup_reserved3Label]").html(me.params.lblObj.Reserved3);
							$("tr[name=baseCodeViewPopup_reserved3Area]").css({"display":""});
						}
						else{
							$("tr[name=baseCodeViewPopup_reserved3Area]").css({"display":"none"});
						}
						//====
						if(me.params.lblObj.ReservedInt != null){
							$("th[name=baseCodeViewPopup_reservedInt]").html(me.params.lblObj.ReservedInt);
							$("tr[name=baseCodeViewPopup_reservedIntArea]").css({"display":""});
						}
						else{
							$("tr[name=baseCodeViewPopup_reservedIntArea]").css({"display":"none"});
						}
						accountCtrl.refreshAXSelect("inputIsUse");
					}
					$("div[name=baseCodeView_displayArea]").css({"display":""}); 
				},
				
				/**
				필드에 값 세팅
				*/
				setCodeData : function(data) {
					var me = this;
					me.setFieldDataPopup("hiddenBaseCodeID",data.BaseCodeID );
					me.setFieldDataPopup("hiddenIsGroup",data.IsGroup );
					me.setFieldDataPopup("hiddenCodeGroup",data.CodeGroup );
					me.setFieldDataPopup("hiddenCodeGroupName",data.CodeGroupName );
					me.setFieldDataPopup("hiddenSortKey",data.SortKey );
					me.setFieldDataPopup("hiddenCompanyCode",data.CompanyCode );

					me.setFieldDataPopup("viewCode",data.Code );
					me.setFieldDataPopup("inputReserved1",data.Reserved1 );
					me.setFieldDataPopup("inputReserved2",data.Reserved2 );
					me.setFieldDataPopup("inputReserved3",data.Reserved3 );
					me.setFieldDataPopup("inputReservedInt",data.ReservedInt );
					
					me.setFieldDataPopup("inputCodeName",data.CodeName );
					//me.setFieldDataPopup("inputIsUse",data.IsUse );
					me.setFieldDataPopup("inputRegistDate",data.RegistDate );
					
					accountCtrl.getComboInfo("inputIsUse").bindSelectSetValue(data.IsUse);
					accountCtrl.renderAXSelect('IsUse',	'inputIsUse',	'ko','','',data.IsUse);
					me.setFieldDisabledPopup("inputCode", true);
				},
				
				/**
				저장시 유효성 추가
				*/
				CheckValidation : function() {
					var me = this;
					me.getCodeeData();
					
					if(	isEmptyStr(me.params.codeDataObj.BaseCodeID)	||
						isEmptyStr(me.params.codeDataObj.Code)		||
						isEmptyStr(me.params.codeDataObj.CodeName)){
						Common.Error("<spring:message code='Cache.ACC_Valid'/>");	//입력되지 않은 필수값이 있습니다.
						return;
					}

			        Common.Confirm("<spring:message code='Cache.ACC_isSaveCk' />", "Confirmation Dialog", function(result){	//저장하시겠습니까?
			       		if(result){
							me.saveBaseCode();
			       		}
			        });
				},
				
				
				/**
				저장시 코드 데이터 추가
				*/
				getCodeeData : function(){
					var me = this;

					me.params.codeDataObj	= {};

					me.params.codeDataObj.Code			=	me.getTxTFieldDataPopup("viewCode");
					me.params.codeDataObj.CodeName		=	me.getTxTFieldDataPopup("inputCodeName");
					me.params.codeDataObj.IsUse			=	accountCtrl.getComboInfo("inputIsUse").val();
					
					me.params.codeDataObj.Reserved1		=	me.getTxTFieldDataPopup("inputReserved1");
					me.params.codeDataObj.Reserved2		=	me.getTxTFieldDataPopup("inputReserved2");
					me.params.codeDataObj.Reserved3		=	me.getTxTFieldDataPopup("inputReserved3");
					me.params.codeDataObj.ReservedInt	=	me.getTxTFieldDataPopup("inputReservedInt");

					me.params.codeDataObj.BaseCodeID	=	me.getTxTFieldDataPopup("hiddenBaseCodeID");
					me.params.codeDataObj.IsGroup		=	me.getTxTFieldDataPopup("hiddenIsGroup");
					me.params.codeDataObj.CodeGroup		=	me.getTxTFieldDataPopup("hiddenCodeGroup");
					me.params.codeDataObj.CodeGroupName	=	me.getTxTFieldDataPopup("hiddenCodeGroupName");
					me.params.codeDataObj.SortKey		=	me.getTxTFieldDataPopup("hiddenSortKey");
					me.params.codeDataObj.CompanyCode		=	me.getTxTFieldDataPopup("hiddenCompanyCode");
					
					me.params.codeDataObj.IsNew			=	"N";
					me.params.codeDataObj.SessionUser	=	Common.getSession().USERID;
				},
				
				/**
				코드 상세저장
				*/
				saveBaseCode : function() {
					$.ajax({
						type:"POST",
							url:"/account/baseCode/saveBaseCode.do",
						data:{
							"baseCodeObj" : JSON.stringify(BaseCodeViewPopup.params.codeDataObj),
						},
						success:function (data) {
							if(data.result == "ok"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
								BaseCodeViewPopup.closeLayer();
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
								
							}
							else if(data.result == "D"){
								Common.Error("<spring:message code='Cache.ACC_DuplCode'/>");	//이미 존재하는 코드입니다.
							}
							else if(data.result == "V"){
								Common.Error("<spring:message code='Cache.ACC_Valid'/>");	//입력되지 않은 필수값이 있습니다.
							}
							else if(data.result == "G"){
								Common.Error("<spring:message code='Cache.ACC_NoGrp'/>");	// 존재하지 않는 그룹 코드 입니다.
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							if(error.result == "D"){
								Common.Error("<spring:message code='Cache.ACC_DuplCode'/>");
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
							}
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
		window.BaseCodeViewPopup = BaseCodeViewPopup;
	})(window);
	
	BaseCodeViewPopup.popupInit();
</script>