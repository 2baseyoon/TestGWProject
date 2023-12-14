<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.StringUtil" %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	String userCode = StringUtil.replaceNull(request.getParameter("code"),"");
	String mode= StringUtil.replaceNull(request.getParameter("mode"),"");
%>

<script type="text/javascript" src="/covicore/resources/script/menu/adminorganization.js<%=resourceVersion%>"></script>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
	<style>
		/* div padding */
		.divpop_body {
			padding: 20px !important;
		}
		.txt_red {
    	color: #e75c00;
		}
	</style>
</head>
<body>	
	<form>
		<div style="width:100%;" id="divGroupDefault" class="mt15">
			<table class="AXFormTable">
				<colgroup>	
					<col style="width: 20%">
					<col style="width: 30%">
					<col style="width: 20%">
					<col style="width: 30%">
				</colgroup>
				<tr>
					<th id="thTitle"><spring:message code="Cache.lbl_apv_DirectorName"/><span class="txt_red">*</span></th><!-- 임원명 -->
					<td colspan="3">
						<label id="txtPfx"></label>
						<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtOfficerName" readonly="readonly" />
						<input type="hidden" id="OfficerCode" />
						<input type="hidden" id="chkDuplication" value="N"/>
						<input type="button" id="btnOrgPop" class="AXButton" value="<spring:message code="Cache.btn_Select"/>" data-target-name="txtOfficerName" data-target-code="OfficerCode" onclick="OrgMapLayerPopup(this, 'addTarget_Callback', 'B1');"/>
						<label id="txtSfx"></label>
						<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_DuplicateCheck"/>" onclick="checkDuplicate();" id="btnIsDuplicate">
					</td>
				</tr>
				<tr>
					<th id="thName"><spring:message code="Cache.lbl_charge"/><span class="txt_red">*</span></th><!-- 담당자 -->
					<td colspan="3">
						<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtSecretarys" readonly="readonly" style="width:259px;" />
						<input type="hidden" id="SecretarysCode" />
						<input type="button" class="AXButton" value="<spring:message code="Cache.btn_Select"/>" data-target-name="txtSecretarys" data-target-code="SecretarysCode" onclick="OrgMapLayerPopup(this, 'addSecretary_Callback', 'B9');"/>
					</td>
				</tr>							
				<tr>				
					<th><spring:message code="Cache.lbl_PriorityOrder"/><span class="txt_red">*</span></th><!-- 우선순위 -->
					<td>
						<input type="text" class="AXInput" id="txtPriorityOrder" style="width: 98%;" onkeyup='writeNum(this);'>
					</td>
					<th ><spring:message code="Cache.lbl_IsUse"/><span class="txt_red">*</span></th><!-- 사용여부 -->
					<td>
						<select id="selIsUse" name="selIsUse" class="AXSelect">
							<option value="Y" selected><spring:message code="Cache.lbl_UseY"/></option>
							<option value="N"><spring:message code="Cache.lbl_noUse"/></option>
						</select>
					</td>
				</tr>
			</table>
			
			<div style="width: 100%; text-align: center; margin-top: 10px;">
				<input type="button" id="btnInsert" value="<spring:message code='Cache.btn_save' />" onclick="return addOfficer();" class="AXButton red" style="display:none;"> <!-- 추가 -->
				<input type="button" id="btnUpdate" value="<spring:message code='Cache.btn_save' />" onclick="return UpdateOfficer();" class="AXButton red" style="display:none;" > <!-- 수정 -->
				<input type="button" id="btnClose" value="<spring:message code='Cache.btn_Close' />" onclick="closePopup();" class="AXButton" > <!-- 닫기 -->
			</div>
		</div>		
	</form>	
	
	<script type="text/javascript">
		
		var pUserCode = "<%=userCode%>";
		var pMode = "<%=mode%>";
		
		
		//개별호출 일괄처리
		var lang = Common.getSession("lang");
		window.onload = initContent();
		
		function initContent(){
			if(pMode == "edit"){
				getOfficerData(pUserCode);
				$("#btnOrgPop").css("display", "none");
				$("#btnIsDuplicate").css("display", "none");				
				$("#txtOfficerName").attr("readonly", "readonly");
				$("#btnInsert").hide();
				$("#btnUpdate").show();
			}
			else {
				$("#btnInsert").show();
				$("#btnUpdate").hide();
			}
		}
		
		//임의그룹 정보 바인딩(수정시)
		function getOfficerData(usercode) {
			$.ajax({
				type:"POST",
				data:{
					"usercode" : usercode
				},
				url:"/groupware/webpart/getOfficerInfo.do",
				success:function (data) {
					$("#txtOfficerName").val(data.list[0].DisplayName);		
					$("#OfficerCode").val(data.list[0].UserCode);
					$("#txtSecretarys").val(getArrangement(data.list[0].SecretarysName));
					$("#SecretarysCode").val(data.list[0].Secretarys);
					$("#txtPriorityOrder").val(data.list[0].Sort);										
					$("#selIsUse").val(data.list[0].IsUse == "" ? "N" : data.list[0].IsUse);
					$("#chkDuplication").val("Y");
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/webpart/getOfficerInfo.do", response, status, error);
				}
			});
		}
		
		//유효성 검사
		function CheckValidation() {
			if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

			if($("#SecretarysCode").val() == "") {
				Common.Warning("<spring:message code='Cache.lbl_apv_charge_select' />", 'Warning Dialog', function() { /* 담당자를 선택해주십시오. */
					$("#txtSecretarys").focus();
				});
				return false;
			} else if($("#txtPriorityOrder").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_EnterPriorityNumber' />", 'Warning Dialog', function() { /* 담당자를 선택해주십시오. */
					$("#txtPriorityOrder").focus();
				});
				return false;
			} 
			return true;
		}
		
		function OrgMapLayerPopup(caller, callbackName, type) {
			var orgChartUrl = "/covicore/control/goOrgChart.do?callBackFunc="+callbackName+"&type="+type;
			var target = {
				name: (caller.getAttribute('data-target-name')) ? caller.getAttribute('data-target-name') : '',
				code: (caller.getAttribute('data-target-code')) ? caller.getAttribute('data-target-code') : '',
				selected: (caller.getAttribute('data-target-code')) ? document.getElementById(caller.getAttribute('data-target-code')).value : ''
			}
			
			orgChartUrl += '&userParams=' + encodeURIComponent(JSON.stringify(target));
			CFN_OpenWindow(orgChartUrl, "<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
		}
		
		// 조직도에서 전달받은 임원 코드 설정
		function addTarget_Callback(orgData){
			var _orgData = JSON.parse(orgData);			
			
			var _names = '';
			var _code = '';
			$.each(_orgData.item, function(idx, el){
				_names  = CFN_GetDicInfo(el.DN);
				_code  = el.UserCode;
			});
			
			if( _code != $("#OfficerCode").val())
			{
				$("#txtOfficerName").val(_names);
				$("#OfficerCode").val(_code);
				$("#chkDuplication").val("N");
			}			
		}		
		
		// 조직도에서 전달받은 담당자 코드 설정
		function addSecretary_Callback(orgData){
			var _orgData = JSON.parse(orgData);				// JSON 문자열을 객체로 변환

			var _names = '';
			var _codes = ';';
			$.each(_orgData.item, function(idx, el){
				_names += ((idx > 0) ? ',' : '') + CFN_GetDicInfo(el.DN);
				_codes += el.UserCode + ';';     
			});
			
			$("#txtSecretarys").val(_names);
			$("#SecretarysCode").val(_codes);
		}
		
		//임원 중복체크 
		function checkDuplicate() {
		    var officerCode = $("#OfficerCode").val();
		    
		    if(officerCode != "")
			{
				$.ajax({
					type:"POST",
					url:"/groupware/webpart/getIsDuplicate.do",
					data: {
						"OfficerCode" : officerCode
					},
					success:function(data){
						var mlist = data.list;				
						
						if (mlist[0].IsDuplicate == "N")
						{	
							Common.Inform("<spring:message code='Cache.lbl_apv_useOK'/>");
							$("#chkDuplication").val("Y");
						}
						else
						{
							Common.Inform("<spring:message code='Cache.lbl_apv_useNOT'/>");
							$("#chkDuplication").val("N");
						}
					}
				});
			}
		    else
			{
		    	Common.Inform("<spring:message code='Cache.msg_EnterValueInField'/>");
		    }		    	
		}
		
		function addOfficer() {	
		
			if(CheckValidation()){
				if($("#chkDuplication").val() != "Y")
				{
					Common.Inform("<spring:message code='Cache.msg_CheckDoubleAlert'/>");	
					return false;
				}
				else
				{
					$.ajax({
				    	type:"POST",
				    	url: "/groupware/webpart/addOfficer.do",
				    	dataType : 'json',
				    	data: {
				        	"officerCode": $("#OfficerCode").val(),
				        	"secretarysCode": $("#SecretarysCode").val(),			        	
				        	"sort": $("#txtPriorityOrder").val(),
				        	"isUse" : $("#selIsUse").val()
				    	},
				    	success:function(data){
				    		if(data.status=='SUCCESS'){
				    			/*저장되었습니다.*/
					    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){					    			
					    			parent.parent.ExecutiveOffice.getOfficerList();		// 웹파트 새로고침
					    			parent.bindGridData();									// 목록 새로고침
					    			location.reload();										// 현재 페이지 초기화
					    			closePopup();
					    		});
				    		}else{
				    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
				    		}
				    	}, 
				  		error:function(error){
				  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
				  		}
				    });
				}
			}
		}
		
		function UpdateOfficer() {	
			
			if(CheckValidation()){
				
				$.ajax({
			    	type:"POST",
			    	url: "/groupware/webpart/UpdateOfficer.do",
			    	dataType : 'json',
			    	data: {
			        	"officerCode": $("#OfficerCode").val(),
			        	"secretarysCode": $("#SecretarysCode").val(),			        	
			        	"sort": $("#txtPriorityOrder").val(),
			        	"isUse" : $("#selIsUse").val()
			    	},
			    	success:function(data){
			    		if(data.status=='SUCCESS'){
			    			/*저장되었습니다.*/
				    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){					    			
				    			parent.parent.ExecutiveOffice.getOfficerList();		// 웹파트 새로고침
				    			parent.bindGridData();									// 목록 새로고침
				    			location.reload();										// 현재 페이지 초기화
				    			closePopup();
				    		});
			    		}else{
			    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
			    		}
			    	}, 
			  		error:function(error){
			  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
			  		}
			    });
			
			}
		}
		
		
		function getArrangement(pNames){
			var vResult = "";
			
			if (pNames.startsWith(';'))
				vResult = pNames.substring(1);
			
			if (pNames.endsWith(';'))
				vResult = vResult.substring(0, pNames.length - 2);
			
			return vResult.replace(/;/g ,',')
		}
		
	</script>
</body>


