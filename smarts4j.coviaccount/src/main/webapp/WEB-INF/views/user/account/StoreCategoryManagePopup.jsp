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
	<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:450px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents" >
			<div class="popContent" style="position:relative;">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style="width: 200px;">
							<col style="width: auto;">
						</colgroup>
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
						
						<tbody  id="itemAdd">	
							<tr >
								<th><!-- 업종명 -->
									<spring:message code="Cache.ACC_lbl_vendorSectorName"/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input type="text" id="inputCategoryName" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr >
								<th>	<!-- 업종코드 -->
									<spring:message code="Cache.ACC_lbl_vendorSectorCode"/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<input type="text" id="inputCategoryCode" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
							<tr >
								<th>	<!-- 표준적요 -->
									<spring:message code="Cache.ACC_standardBrief"/>
								</th>
								<td>
									<div class="box">
										<div class="name_box_wrap">
											<span class="name_box" id="inputStandardBriefName" ></span>
											<a class="btn_del03" onclick="StoreCategoryManagePopup.standardBriefDel()"></a>
										</div>
										<a class="btn_search03" onclick="StoreCategoryManagePopup.standardBriefSearchPopup()" style='float:right'></a>
										<input type="hidden" id="inputStandardBriefID" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
										<input type="hidden" id="inputAccountCode" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				
					<input type="hidden" id="inputCategoryID" >
				</div>
				<div class="bottom">
					<a onclick="StoreCategoryManagePopup.CheckValidation();"	id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save' /></a>
					<a onclick="StoreCategoryManagePopup.closeLayer();"			id="btnClose" class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel' /></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

	if (!window.StoreCategoryManagePopup) {
		window.StoreCategoryManagePopup = {};
	}
	
	/**
	기초코드 추가용 팝업
	상세조회 기능 미사용중
	BaseCodeSearchPopup으로 분리
	*/
	(function(window) {
		var StoreCategoryManagePopup = {
				params : {
					codeDataObj : {}
				},
				
				/**
				팝업 초기화와 상세정보 조회
				*/
				popupInit : function(){
					var me = this;
					accountCtrl.renderAXSelect('CompanyCode', 'selectCompanyCode', 'ko','','','');		
					if("${CategoryID}" == ""||"${CategoryID}" == "undefined")
						return;
					var CategoryID = "${CategoryID}";
					$.ajax({
						url:"/account/StoreCategoryManage/getStoreCategoryManageDetail.do",
						cache: false,
						data:{
							CategoryID : CategoryID
						},
						success:function (data) {
							if(data.result == "ok"){
								
								me.setDataBinding(data.list);
							}
						},
						error:function (error){
						}
					}); 
					
				},
				
				/**
				저장전 유효성 체크
				*/
				CheckValidation : function() {
				    
					var me = this; 
					me.getCodeData();

					
					if(	isEmptyStr(me.params.codeDataObj.CompanyCode)
					||	isEmptyStr(me.params.codeDataObj.CategoryCode)
					||	isEmptyStr(me.params.codeDataObj.CategoryName)){
						Common.Error("<spring:message code='Cache.ACC_Valid'/>");	// 입력되지 않은 필수값이 있습니다.
						return;
					}
			        Common.Confirm("<spring:message code='Cache.ACC_isSaveCk' />", "Confirmation Dialog", function(result){		//저장하시겠습니까?
			       		if(result){
			       			me.saveStoreCategory(); 
			       		}
			        });
				},
				
				/**
				저장
				*/
				saveStoreCategory : function() {
					$.ajax({
						type:"POST",
						url:"/account/StoreCategoryManage/saveStoreCategoryManageInfo.do",
						data		: JSON.stringify(StoreCategoryManagePopup.params.codeDataObj),
						dataType	: "json",
						contentType	: "application/json",
						success:function (data) {
							if(data.status == "SUCCESS"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다.
								
								StoreCategoryManagePopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
								
							}
							else if(data.status == "DUP"){
								Common.Error("<spring:message code='Cache.ACC_DuplCode'/>");	// 이미 존재하는 코드입니다.
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
							}
						},
						error:function (error){
							
						}
					});
				},
				
				/**
				저장정 화면 필드데이터 획득
				*/
				getCodeData : function() {
					var me = this;
					me.params.codeDataObj = {};
					me.params.codeDataObj.CompanyCode		= accountCtrl.getComboInfo("selectCompanyCode").val();
					me.params.codeDataObj.CategoryID		= me.getTxTFieldDataPopup("inputCategoryID");
					me.params.codeDataObj.CategoryCode		= me.getTxTFieldDataPopup("inputCategoryCode");
					me.params.codeDataObj.CategoryName		= me.getTxTFieldDataPopup("inputCategoryName");
					me.params.codeDataObj.StandardBriefID	= me.getTxTFieldDataPopup("inputStandardBriefID");
					me.params.codeDataObj.AccountCode		= me.getTxTFieldDataPopup("inputAccountCode");
					
				},
				
				
				/**
				필드에 값 세팅
				*/
				setDataBinding : function(data) {
					var me = this;
					data = data[0];
					$("#inputCategoryID").val(data.CategoryID);
					$("#inputCategoryCode").val(data.CategoryCode);
					$("#inputCategoryName").val(data.CategoryName);
					$("#inputStandardBriefID").val(data.StandardBriefID);
					$("#inputAccountCode").val(data.AccountCode);
					$("#inputStandardBriefName").text(data.StandardBriefName);
					

					accountCtrl.getComboInfo("selectCompanyCode").bindSelectSetValue(data.CompanyCode);
					
					accountCtrl.refreshAXSelect("selectCompanyCode");
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
				setFieldDisabledPopup : function(field, val) {
					$("#"+field).attr('disabled',val)
				},

				standardBriefSearchPopup : function() {
					var me = this;
					var popupTit	=	"<spring:message code='Cache.ACC_standardBrief'/>";
					var popupName	=	"StandardBriefSearchPopup";
					var popupID		=	"StandardBriefSearchPopup";
					var openerID	=	"StoreCategoryManagePopup";
					var popupYN		=   "Y";
					var callBack	=	"standardBriefSearchPopup_CallBack";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+   "popupYN="		+   popupYN	    +   "&"
									+	"companyCode="  + accountCtrl.getComboInfo("selectCompanyCode").val()+ "&"
									+	"callBackFunc="	+	callBack;
					parent.Common.open(	"",popupID,popupTit,url,"800px","730px","iframe",true,null,null,true);
					
					
				},

				standardBriefSearchPopup_CallBack : function(value) {
					var me = this
					$("#inputStandardBriefName").html(value.StandardBriefName);
					$("#inputStandardBriefID").val(value.StandardBriefID);
					$("#inputAccountCode").val(value.AccountCode);
					
				},
				standardBriefDel: function(value) {
					$("#inputStandardBriefName").html('');
					$("#inputStandardBriefID").val('');
					$("#inputAccountCode").val('');
				},
		}
		window.StoreCategoryManagePopup = StoreCategoryManagePopup;
	})(window);
	
	StoreCategoryManagePopup.popupInit();
	
</script>