<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
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
	</style>
</head>
<body>
	<form>
		<div style="width:100%;" id="divGroupDefault">
			<table class="AXFormTable">
				<colgroup>	
					<col style="width: 20%">
					<col style="width: 30%">
					<col style="width: 20%">
					<col style="width: 30%">
				</colgroup>
				<tr>
					<th><spring:message code="Cache.lbl_AddJob_User"/></th><!-- 사용자 -->
					<td>
						<input type="text" class="AXInput" id="txtUserName" readonly="readonly" style="width: 70%;">
						<input type="hidden" id="hidUserCode">
						<input type="button" id="btnOrgMapUser" class="AXButton" value="<spring:message code="Cache.btn_Select"/>" onclick="OrgMap_Open('user');" style="min-width: 20px;">
					</td>
					<th><spring:message code="Cache.lbl_IsHR"/></th><!-- 인사연동여부 -->
					<td>
						<select id="selIsHR" name="selIsHR" class="AXSelect" style="width: 70%;">
							<option value="Y" selected><spring:message code="Cache.lbl_UseY"/></option>
							<option value="N"><spring:message code="Cache.lbl_noUse"/></option>
						</select>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_Company"/></th><!-- 회사 -->
					<td>
						<input type="text" class="AXInput" id="txtCompanyName" readonly="readonly" style="width: 70%;">
					</td>
					<th><spring:message code="Cache.lbl_AddJob_Company"/></th><!-- 겸직회사 -->
					<td>
						<input type="text" class="AXInput" id="txtAddJobCompanyName" readonly="readonly" style="width: 70%;">
						<input type="hidden" id="hidAddJobCompanyCode">
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_dept"/></th><!-- 부서 -->
					<td>
						<input type="text" class="AXInput" id="txtDeptName" readonly="readonly" style="width: 70%;">
					</td>
					<th><spring:message code="Cache.lbl_AddJob_Dept"/></th><!-- 겸직부서 -->
					<td>
						<input type="text" class="AXInput" id="txtAddJobDeptName" readonly="readonly" style="width: 70%;">
						<input type="hidden" id="hidAddJobDeptCode">
						<input type="button" class="AXButton" value="<spring:message code="Cache.btn_Select"/>" onclick="OrgMap_Open('dept');" style="min-width: 20px;">
					</td>
				</tr>
		 		<tr>
					<th><spring:message code="Cache.lbl_JobTitle"/></th><!-- 직책 -->
					<td>
						<input type="text" class="AXInput" id="txtJobTitleName" readonly="readonly" style="width: 70%;">
					</td>
					<th><spring:message code="Cache.lbl_AddJob_JobTitle"/></th><!-- 겸직직책 -->
					<td>
						<select id="selJobTitle" name="selJobTitle" class="AXSelect" style="width: 70%;">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
						</select>
					</td>	
				</tr>
				<tr>
				<th><spring:message code="Cache.lbl_JobPosition"/></th><!-- 직위 -->
					<td>
						<input type="text" class="AXInput" id="txtJobPositionName" readonly="readonly" style="width: 70%;">
					</td>
					<th><spring:message code="Cache.lbl_AddJob_JobPosition"/></th><!-- 겸직직위 -->
					<td>
						<select id="selJobPosition" name="selJobPosition" class="AXSelect" style="width: 70%;">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
						</select>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_JobLevel"/></th><!-- 직급 -->
					<td>
						<input type="text" class="AXInput" id="txtJobLevelName" readonly="readonly" style="width: 70%;">
					</td>
					<th><spring:message code="Cache.lbl_AddJob_JobLevel"/></th><!-- 겸직직급 -->
					<td>
						<select id="selJobLevel" name="selJobLevel" class="AXSelect" style="width: 70%;">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
						</select>
					</td>
				</tr> 
			</table>			
			<div style="width: 100%; text-align: center; margin-top: 10px;">
				<input type="button" id="btnSave" value="<spring:message code='Cache.btn_save' />" onclick="return saveAddJob();" class="AXButton red" > <!-- 저장 -->
				<input type="button" id="btnClose" value="<spring:message code='Cache.btn_Close' />" onclick="closePopup();" class="AXButton" > <!-- 닫기 -->
			</div>
		</div>
		<input type="hidden" ID="hidoldAddJobCompanyCode" />
		<input type="hidden" ID="hidoldAddJobDeptCode" />
		<input type="hidden" ID="hidoldJobTitle" />
		<input type="hidden" ID="hidoldJobPosition" />
		<input type="hidden" ID="hidoldJobLevel" />
	</form>
	<script type="text/javascript">
		
		var mode = "${mode}";
		var id = "${id}";
		
		var lang = Common.getSession("lang");
		
		window.onload = initContent();
		
		function initContent(){
			if(mode == "modify"){
				getAddJobInfoData(id);
				$('#btnOrgMapUser').css("display", "none");
			}
		}
		
		//겸직 정보 바인딩(수정시)
		function getAddJobInfoData(pID) {
			$.ajax({
				async:false,
				type:"POST",
				data:{
					"id" : pID
				},
				url:"/covicore/admin/orgmanage/getaddjobInfodata.do",
				success:function (data) {
					
					var UserName = data.list[0].UserName;
					var DeptName = data.list[0].DeptName;
					var CompanyName = data.list[0].CompanyName;
					var JobTitle = data.list[0].JobTitleName;
					var JobPositon =data.list[0].JobPositionName;
					var JobLevel = data.list[0].JobLevelName;
					
					$("#txtUserName").val( UserName.split( UserName.indexOf('&') > -1 ? '&' : ';')[0] );
					$("#hidUserCode").val(data.list[0].UserCode);
					
					$("#selIsHR option[value='" + data.list[0].IsHR + "']").prop("selected", true);
					$("#txtAddJobDeptName").val( DeptName.split( DeptName.indexOf('&') > -1 ? '&' : ';')[0] );
					$("#hidAddJobDeptCode").val(data.list[0].DeptCode);
					$("#txtAddJobCompanyName").val( CompanyName.split( CompanyName.indexOf('&') > -1 ? '&' : ';')[0] );
					$("#hidAddJobCompanyCode").val(data.list[0].CompanyCode);
					
					bindDropDownList();
					
					$("#selJobTitle option[value='" + data.list[0].JobTitleCode + "']").prop("selected", true);
					$("#selJobPosition option[value='" + data.list[0].JobPositionCode + "']").prop("selected", true);
					$("#selJobLevel option[value='" + data.list[0].JobLevelCode + "']").prop("selected", true);
					$("#hidoldAddJobCompanyCode").val(data.list[0].CompanyCode);
					$("#hidoldAddJobDeptCode").val(data.list[0].DeptCode);
					$("#hidoldJobTitle").val(data.list[0].JobTitleCode);
					$("#hidoldJobPosition").val(data.list[0].JobPositionCode);
					$("#hidoldJobLevel").val(data.list[0].JobLevelCode);
					
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/admin/orgmanage/getaddjobInfodata.do", response, status, error);
				}
			});
			
			$.ajax({
				async:false,
				type:"POST",
				data:{
					"ur_code" : $("#hidUserCode").val()
				},
				url:"/covicore/admin/orgmanage/getaddjobuserInfodata.do",
				success:function (data) {
					$("#txtCompanyName").val(CFN_GetDicInfo(data.list[0].MultiCompanyName, lang));
					$("#txtDeptName").val(CFN_GetDicInfo(data.list[0].MultiDeptName, lang));
					$("#txtJobTitleName").val(data.list[0].JobTitleName);
					$("#txtJobPositionName").val(data.list[0].JobPositionName);
					$("#txtJobLevelName").val(data.list[0].JobLevelName);
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/admin/orgmanage/getaddjobuserInfodata.do", response, status, error);
				}
			});
			
		}
		
		function bindDropDownList(){
			$.ajax({
				type:"POST",
				async: false,
				data:{
					"domain" : $("#hidAddJobCompanyCode").val()
				},
				url:"/covicore/admin/orgmanage/getarbitrarygroupdropdownlist.do",
				success:function (data) {
					
					$.each(data.list, function (i, d) {
						if(d.GroupType == 'JobTitle'){
							 $('#selJobTitle').append($('<option>', { 
							        value: d.GroupCode,
							        text : d.GroupName
							    }));
						} else if(d.GroupType == 'JobPosition'){
							$('#selJobPosition').append($('<option>', { 
						        value: d.GroupCode,
						        text : d.GroupName
						    }));
						} else{
							 $('#selJobLevel').append($('<option>', { 
							        value: d.GroupCode,
							        text : d.GroupName
							    }));
						}
					});
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/admin/orgmanage/getarbitrarygroupdropdownlist.do", response, status, error);
				}
			});
		}
		
		function OrgMap_Open(type){
			if(Common.getGlobalProperties("isSaaS") == "Y") {
				var companyCode = parent.$("#domainCodeSelectBox").val();
		
				if(type == "user") {
					parent.Common.open("","orgchart_pop","<spring:message code='Cache.btn_OrgManage'/>" ,"/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod3&openerID=ViewAddJob&type=A1&companyCode=" + companyCode,"540px", "580px", "iframe", true, null, null,true);
				} else if(type == "dept") {
					parent.Common.open("","orgchart_pop","<spring:message code='Cache.btn_OrgManage'/>" ,"/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&openerID=ViewAddJob&type=C1&companyCode=" + companyCode,"1040px", "600px", "iframe", true, null, null,true);
				}
			} else {
				if(type == "user") {
					parent.Common.open("","orgchart_pop","<spring:message code='Cache.btn_OrgManage'/>" ,"/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod3&openerID=ViewAddJob&type=A1","540px", "580px", "iframe", true, null, null,true);
				} else if(type == "dept") {
					parent.Common.open("","orgchart_pop","<spring:message code='Cache.btn_OrgManage'/>" ,"/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&openerID=ViewAddJob&type=C1","1040px", "600px", "iframe", true, null, null,true);
				}
			}
		}
		
		function _CallBackMethod2(data){ //조직도 콜백함수 구현 : 부서(parent에 정의)
			var jsonData = JSON.parse(data);
			
			$("#txtAddJobDeptName").val(CFN_GetDicInfo(jsonData.item[0].DN));
			$("#hidAddJobDeptCode").val(jsonData.item[0].AN);
			$("#txtAddJobCompanyName").val(CFN_GetDicInfo(jsonData.item[0].ETNM));
			$("#hidAddJobCompanyCode").val(jsonData.item[0].ETID);
			
			bindDropDownList();			
		}
				
		
		function _CallBackMethod3(data){ //조직도 콜백함수 구현 : 사용자(parent에 정의)
			var jsonData = JSON.parse(data);
		
			if(jsonData.item.length > 0){
				var JobPositon = jsonData.item[0].PO;
				var JobTitle = jsonData.item[0].TL;
				var JobLevel = jsonData.item[0].LV;
				
				$("#txtUserName").val(CFN_GetDicInfo(jsonData.item[0].DN));
				$("#hidUserCode").val(jsonData.item[0].AN);
				$("#txtCompanyName").val(CFN_GetDicInfo(jsonData.item[0].ETNM));
				$("#txtDeptName").val(CFN_GetDicInfo(jsonData.item[0].RGNM));
				$("#txtJobTitleName").val( CFN_GetDicInfo(JobTitle.split( JobTitle.indexOf('|') > -1 ? '|' : ';')[1] ));
				$("#txtJobPositionName").val( CFN_GetDicInfo(JobPositon.split( JobPositon.indexOf('|') > -1 ? '|' : ';')[1] ));
				$("#txtJobLevelName").val( CFN_GetDicInfo(JobLevel.split( JobLevel.indexOf('|') > -1 ? '|' : ';')[1] ));
			}
		}
		
		//유효성 검사
		function CheckValidation() {
			if($("#txtUserName").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_selectretireuser'/>");// 사용자를 선택하세요.
			} else if($("#txtAddJobDeptName").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_apv_120'/>");//겸직부서를 선택하세요.
			} else{
				return true;
			}		
			return false;
		}
		
		//겸직 추가
		function saveAddJob(){
			
		    if(!CheckValidation()) return false;
			
		    var type = 'AddJob';
		    var userCode = $("#hidUserCode").val();
		    var addJob_Company = $("#hidAddJobCompanyCode").val();
		    var addJob_Group = $("#hidAddJobDeptCode").val();
		    var addJob_Title = $("#selJobTitle").val();
		    var addJob_Position = $("#selJobPosition").val();
		    var addJob_Level = $("#selJobLevel").val();
		    var isHR = $("#selIsHR").val();
		    
		    var addJob_CompanyName = $("#txtAddJobCompanyName").val();
		    var addJob_GroupName = $("#txtAddJobDeptName").val();
		    var addJob_TitleName = $("#selJobTitle").find("option[value='"+$("#selJobTitle").val()+"']").text();
		    var addJob_PositionName = $("#selJobPosition").find("option[value='"+$("#selJobPosition").val()+"']").text();
		    var addJob_LevelName = $("#selJobLevel").find("option[value='"+$("#selJobLevel").val()+"']").text();		    		    		    
		    
		    var oldaddJob_Company = $("#hidoldAddJobCompanyCode").val();
		    var oldaddJob_Group = $("#hidoldAddJobDeptCode").val();
		    var oldaddJob_Title = $("#hidoldJobTitle").val();
		    var oldaddJob_Position = $("#hidoldJobPosition").val();
		    var oldaddJob_Level = $("#hidoldJobLevel").val();

			Common.Progress(Common.getDic('msg_apv_008'));
			
			$.ajax({
				url : "/covicore/admin/orgmanage/registaddjob.do",
				type : "POST",
				data : {
					"Mode" : mode,
					"id" : id,
					"Type" : type,
					"UserCode" : userCode,					
					"AddJob_Company" : addJob_Company,
					"AddJob_Group" : addJob_Group,
					"AddJob_Title" :  addJob_Title,
					"AddJob_Position" :  addJob_Position,
					"AddJob_Level" :  addJob_Level,
					"AddJob_CompanyName" : addJob_CompanyName,
					"AddJob_GroupName" : addJob_GroupName,
					"AddJob_TitleName" : addJob_TitleName,
					"AddJob_PositionName" : addJob_PositionName,
					"AddJob_LevelName" : addJob_LevelName,
					"oldAddJob_Company" : oldaddJob_Company,
					"oldAddJob_Group" : oldaddJob_Group,
					"oldAddJob_Title" :  oldaddJob_Title,
					"oldAddJob_Position" :  oldaddJob_Position,
					"oldAddJob_Level" :  oldaddJob_Level,
					"IsHR" :  isHR
				},
				success : function(d) {
					try {
						if(d.result == "OK") {
							Common.Inform("<spring:message code='Cache.msg_Common_10'/>" , 'Information Dialog', function (result) { //저장 되었습니다
								parent.orgGrid.reloadList();
								closePopup();
					        }); 
						} else {
							Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>" ); //오류가 발생하였습니다.
						}
					} catch(e) {
						
					}
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("/covicore/admin/orgmanage/registaddjob.do", response, status, error);
				}
			});
		}

	</script>
</body>