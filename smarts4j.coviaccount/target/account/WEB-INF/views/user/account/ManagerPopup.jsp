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

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>	
	<input id="ManagerID"	name="managerField" datafield="ManagerID"		type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" id="" style="width:400px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents" >
			<div class="popContent" style="position:relative;">
				<div class="middle">
					<table class="tableTypeRow">
						<colgroup>
							<col style="width: 120px;">
							<col style="width: auto;">
						</colgroup>
						<tbody id="itemAdd">	
							<tr >
								<th>
									<!-- 회사 -->
									<spring:message code='Cache.ACC_lbl_company'/>
									<span class="star"></span>
								</th>
								<td>
									<div class="box">
										<span id="CompanyCode" class="selectType02" name="managerField" datafield="CompanyCode">
										</span>
									</div>
								</td>
							</tr>
							<tr >
								<th>
									<!-- 담당자명 -->
									<spring:message code='Cache.ACC_lbl_contactName'/>
									<span class="star"></span>
								</th>
								<td>
									<div id="basecdGrpComboArea" class="box">
										<input id="ManagerUserName" type="text" readonly="" style="width: 100px" disabled="true"
										name="managerField" datafield="ManagerUserName" class="HtmlCheckXSS ScriptCheckXSS" /> 
										<input id="ManagerUserCode" type="hidden" readonly="" style="width: 100px" 
										name="managerField" datafield="ManagerUserCode" class="HtmlCheckXSS ScriptCheckXSS" /> 
										<a id="managerSearchBtn" class="btnTypeDefault btnResInfo" onclick="ManagerPopup.managerSearch()"><spring:message code='Cache.ACC_btn_search'/></a>
									</div>
								</td>
							</tr>
							<tr >
								<th>
									<!-- 담당자 Email -->
									<spring:message code='Cache.ACC_lbl_taxMail'/>
									<span class="star"></span>
								</th>
								<td>
									<div id="basecdGrpComboArea" class="box">
										<input id="TaxMailAddress" name="managerField" datafield="TaxMailAddress" type="text" style="width: 90%" class="HtmlCheckXSS ScriptCheckXSS"/> 
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				
				<div class="popBtnWrap bottom">
					<a onclick="ManagerPopup.checkValidation();"	id="btnSave"	class="btnTypeDefault btnThemeLine"><spring:message code='Cache.ACC_btn_save' /></a>
					<a onclick="ManagerPopup.closeLayer();"			id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>
	if (!window.ManagerPopup) {
		window.ManagerPopup = {};
	}	
	
	(function(window) {
		
		var ManagerPopup = {
				popupInit : function(){
					var me = this;
					var ManagerID = "${ManagerID}";

					accountCtrl.renderAXSelect('CompanyCode', 'CompanyCode', 'ko','','','');
					
					if(!isEmptyStr(ManagerID)){
						me.searchManagerData(ManagerID);
					}					
				},

				searchManagerData : function(ManagerID){
					var me = this;	
					$.ajax({
						url:"/account/manager/searchManagerInfo.do",
						cache: false,
						data:{
							ManagerID : ManagerID
						},
						success:function (r) {
							if(r.result == "ok"){
								var getData = r.data
								
								var inputList = $("[name=managerField]");
								for(var i = 0; i < inputList.length; i++){
									var input = inputList[i];
							   		var datafield = input.getAttribute("datafield");
							   		
							   		input.value = getData[datafield];
							   		
							   		if(input.nodeName == "SELECT") {
							   			accountCtrl.refreshAXSelect(datafield);
							   		}
								}
								
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
				
				managerSearch : function(){
					var popupID		= "orgmap_pop";
					var openerID	= "ManagerPopup";
					var popupTit	= "<spring:message code='Cache.ACC_lbl_orgChart' />"; //조직도
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
					var items		= JSON.parse(orgData).item;
					var arr			= items[0];
					var UserName	= arr.DN.split(';')
					var UserCode	= arr.UserCode.split(';');
					$("[name=managerField][datafield=ManagerUserName]").val(UserName[0]);
					$("[name=managerField][datafield=ManagerUserCode]").val(UserCode[0]);
				},
				
				checkValidation : function(){
					if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
					
					if(isEmptyStr(accountCtrl.getComboInfo("CompanyCode").val()) || isEmptyStr($("#ManagerUserName").val()) || isEmptyStr($("#TaxMailAddress").val())) {
						Common.Error("<spring:message code='Cache.ACC_Valid'/>"); // 입력되지 않은 필수값이 있습니다.
						return;
					}
					
					var me = this;
					var saveObj = {};
					var inputList = $("[name=managerField]");
					for(var i = 0; i < inputList.length; i++){
						var input = inputList[i];
				   		var datafield = input.getAttribute("datafield");
				   		saveObj[datafield] = input.value;
					}
					
					$.ajax({
						url : "/account/manager/saveManagerInfo.do",
						type : "POST",
						data : saveObj,
						success : function(data) {
							if (data.status == "SUCCESS"){
								if (data.result == 'code') {
									Common.Inform("<spring:message code='Cache.ACC_msg_existManager' />");	//이미 입력된 관리자입니다.
								}else{
									parent.Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
									
									ManagerPopup. closeLayer();
									
									try{
										accountCtrl.popupCallBackStr([]);
									}catch (e) {
										coviCmn.traceLog(e);
										coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
									}
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
		window.ManagerPopup = ManagerPopup;
	})(window);
	ManagerPopup.popupInit();
</script>