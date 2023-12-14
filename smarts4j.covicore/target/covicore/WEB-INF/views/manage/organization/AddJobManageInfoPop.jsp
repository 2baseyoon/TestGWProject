<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<body>
	<div class="sadmin_pop">

		<table class="sadmin_table sa_additionalJob">
			<colgroup>
			  <col width="130px;">
			  <col width="*">
			  <col width="130px;">
			  <col width="*">
			</colgroup>
			<tbody>
				<tr>
					<th><span class="thstar">*</span><spring:message code="Cache.lbl_AddJob_User"/></th><!-- 사용자 -->
					<td class="choice">
						<input type="text" id="txtUserName" readonly="readonly">
						<input type="hidden" id="hidUserCode">
						<input type="button" id="btnOrgMapUser" class="btnTypeDefault" value="<spring:message code="Cache.btn_Select"/>" onclick="OrgMap_Open('user');" style="min-width: 20px;">
					</td>
					<th><span class="thstar">*</span><spring:message code="Cache.lbl_IsHR"/></th><!-- 인사연동여부 -->
					<td>
						<select id="selIsHR" name="selIsHR" class="selectType02">
							<option value="Y" selected><spring:message code="Cache.lbl_UseY"/></option>
							<option value="N"><spring:message code="Cache.lbl_noUse"/></option>
						</select>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_Company"/></th><!-- 회사 -->
					<td>
						<input type="text"  id="txtCompanyName" readonly>
					</td>
					<th><spring:message code="Cache.lbl_AddJob_Company"/></th><!-- 겸직회사 -->
					<td>
						<input type="text" 	id="txtAddJobCompanyName" readonly>
						<input type="hidden" id="hidAddJobCompanyCode">
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_dept"/></th><!-- 부서 -->
					<td>
						<input type="text" id="txtDeptName" readonly>
					</td>
					<th><span class="thstar">*</span><spring:message code="Cache.lbl_AddJob_Dept"/></th><!-- 겸직부서 -->
					<td class="choice">
						<input type="text" id="txtAddJobDeptName" readonly><a href="#" class="btnTypeDefault" onclick="OrgMap_Open('dept');"><spring:message code="Cache.btn_Select"/></a>
						<input type="hidden" id="hidAddJobDeptCode">
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_JobTitle"/></th><!-- 직책 -->
					<td>
						<input type="text" id="txtJobTitleName" readonly>
					</td>
					<th><spring:message code="Cache.lbl_AddJob_JobTitle"/></th><!-- 겸직직책 -->
					<td>
						<select class="selectType02" id="selJobTitle" name="selJobTitle">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
						</select>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_JobPosition"/></th>
					<td>
						<input type="text" id="txtJobPositionName" readonly>
					</td>
					<th><spring:message code="Cache.lbl_AddJob_JobPosition"/></th><!-- 겸직직위 -->
					<td>
						<select class="selectType02" id="selJobPosition" name="selJobPosition">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
						</select>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_JobLevel"/></th><!-- 직급 -->
					<td>
						<input type="text" id="txtJobLevelName" readonly>
					</td>
					<th><spring:message code="Cache.lbl_AddJob_JobLevel"/></th><!-- 겸직직급 -->
					<td>
						<select class="selectType02" id="selJobLevel" name="selJobLevel">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
						</select>
					</td>
				</tr>
			</tbody>
		</table>
		<div class="bottomBtnWrap">
			<a href="#" onclick="saveAddJob();" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_save' /></a>
			<a href="#" onclick="closePopup();" class="btnTypeDefault"><spring:message code='Cache.btn_Close' /></a>
		</div>

	</div>
	<input type="hidden" ID="hidoldAddJobCompanyCode" />
	<input type="hidden" ID="hidoldAddJobDeptCode" />
	<input type="hidden" ID="hidoldJobTitle" />
	<input type="hidden" ID="hidoldJobPosition" />
	<input type="hidden" ID="hidoldJobLevel" />
</body>

<script type="text/javascript">

	var _mode = "${mode}";
	var _NO = "${NO}";
	var _domainId = "${DomainId}";
	var _domainCode = "${DomainCode}";
	
	var lang = Common.getSession("lang");
	
	window.onload = initContent();
	
	function initContent(){
		if(_mode == "modify"){
			selectAddJobInfoData();
			$('#btnOrgMapUser').css("display", "none");
			$('#txtUserName').closest('td').removeClass('choice')
		}
	}
	//겸직 정보 바인딩(수정시)
	function selectAddJobInfoData() {
		$.ajax({
			async:false,
			type:"POST",
			data:{
				"id" : _NO
			},
			url:"/covicore/manage/conf/selectAddJobInfoData.do",
			success:function (data) {
				$("#selIsHR option[value='" + data.list[0].ISHR + "']").prop("selected", true);
				$("#txtUserName").val(CFN_GetDicInfo(data.list[0].MULTIUSERNAME, lang));
				$("#hidUserCode").val(data.list[0].USERCODE);
				$("#txtAddJobDeptName").val(CFN_GetDicInfo(data.list[0].MULTIDEPTNAME, lang));
				$("#hidAddJobDeptCode").val(data.list[0].DEPTCODE);
				$("#txtAddJobCompanyName").val(CFN_GetDicInfo(data.list[0].MULTICOMPANYNAME, lang));
				$("#hidAddJobCompanyCode").val(data.list[0].COMPANYCODE);
				///////////////////////////////////////////////////////////////////////////////////////////
				bindDropDownList();
				$("#selJobTitle option[value='" + data.list[0].JOBTITLECODE + "']").prop("selected", true);
				$("#selJobPosition option[value='" + data.list[0].JOBPOSITIONCODE + "']").prop("selected", true);
				$("#selJobLevel option[value='" + data.list[0].JOBLEVELCODE + "']").prop("selected", true);
				$("#hidoldAddJobCompanyCode").val(data.list[0].COMPANYCODE);
				$("#hidoldAddJobDeptCode").val(data.list[0].DEPTCODE);
				$("#hidoldJobTitle").val(data.list[0].JOBTITLECODE);
				$("#hidoldJobPosition").val(data.list[0].JOBPOSITIONCODE);
				$("#hidoldJobLevel").val(data.list[0].JOBLEVELCODE);
				///////////////////////////////////////////////////////////////////////////////////////////
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/conf/selectAddJobInfoData.do", response, status, error);
			}
		});
		
		$.ajax({
			async:false,
			type:"POST",
			data:{
				"UserCode" : $("#hidUserCode").val()
			},
			url:"/covicore/manage/conf/selectUserInfo.do",
			success:function (data) {
				var MultiCompanyName = data.list[0].MultiCompanyName;
				var MultiDeptName = data.list[0].MultiDeptName;
				var MultiJobTitleName = data.list[0].MultiJobTitleName;
				var MultiJobPositionName = data.list[0].MultiJobPositionName;
				var MultiJobLevelName = data.list[0].MultiJobLevelName;
				
				
				if(!$.isEmptyObject(MultiCompanyName	))MultiCompanyName		=CFN_GetDicInfo(MultiCompanyName,lang);
				if(!$.isEmptyObject(MultiDeptName		))MultiDeptName			=CFN_GetDicInfo(MultiDeptName,lang);
				if(!$.isEmptyObject(MultiJobTitleName	))MultiJobTitleName		=CFN_GetDicInfo(MultiJobTitleName,lang);
				if(!$.isEmptyObject(MultiJobPositionName))MultiJobPositionName	=CFN_GetDicInfo(MultiJobPositionName,lang);
				if(!$.isEmptyObject(MultiJobLevelName	))MultiJobLevelName		=CFN_GetDicInfo(MultiJobLevelName,lang);
				$("#txtCompanyName").val(MultiCompanyName);
				$("#txtDeptName").val(MultiDeptName);
				$("#txtJobTitleName").val(MultiJobTitleName);
				$("#txtJobPositionName").val(MultiJobPositionName);
				$("#txtJobLevelName").val(MultiJobLevelName);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/conf/selectUserInfo.do", response, status, error);
			}
		});
		
	}
	
	function bindDropDownList(){
		$.ajax({
			type:"POST",
			async: false,
			data:{
				"companyCode" : $("#hidAddJobCompanyCode").val()
			},
			url:"/covicore/manage/conf/selectArbitraryGroupDropdownlist.do",
			success:function (data) {
				
				$.each(data.list, function (i, d) {
					if(d.GROUPTYPE == 'JobTitle'){
						 $('#selJobTitle').append($('<option>', { 
							value: d.GROUPCODE,
							text : d.GROUPNAME
						}));
					} else if(d.GROUPTYPE == 'JobPosition'){
						$('#selJobPosition').append($('<option>', { 
							value: d.GROUPCODE,
							text : d.GROUPNAME
						}));
					} else{
						 $('#selJobLevel').append($('<option>', { 
							value: d.GROUPCODE,
							text : d.GROUPNAME
						}));
					}
				});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/conf/getarbitrarygroupdropdownlist.do", response, status, error);
			}
		});
	}
	
	function OrgMap_Open(type){
		if(type == "user") { 
			parent.Common.open("","orgchart_pop","<spring:message code='Cache.btn_OrgManage'/>" ,"/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod3&openerID=divAddJobInfo&type=A1&allCompany=N&companyCode=" + _domainCode,"550px", "600px", "iframe", true, null, null,true);
		} else if(type == "dept") {
			parent.Common.open("","orgchart_pop","<spring:message code='Cache.btn_OrgManage'/>" ,"/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&openerID=divAddJobInfo&type=C1&companyCode=" + _domainCode,"1040px", "600px", "iframe", true, null, null,true);
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
			if(JobTitle!='')JobTitle=CFN_GetDicInfo(JobTitle.split( JobTitle.indexOf('|') > -1 ? '|' : ';')[1] );
			if(JobPositon!='')JobPositon=CFN_GetDicInfo(JobPositon.split( JobPositon.indexOf('|') > -1 ? '|' : ';')[1] );
			if(JobLevel!='')JobLevel=CFN_GetDicInfo(JobLevel.split( JobLevel.indexOf('|') > -1 ? '|' : ';')[1] );
			$("#txtUserName").val(CFN_GetDicInfo(jsonData.item[0].DN));
			$("#hidUserCode").val(jsonData.item[0].AN);
			$("#txtCompanyName").val(CFN_GetDicInfo(jsonData.item[0].ETNM));
			$("#txtDeptName").val(CFN_GetDicInfo(jsonData.item[0].RGNM));
			$("#txtJobTitleName").val(JobTitle );
			$("#txtJobPositionName").val(JobPositon);
			$("#txtJobLevelName").val(JobLevel);
			
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
			url : "/covicore/manage/conf/insertAddJob.do",
			type : "POST",
			data : {
				"Mode" : _mode,
				"id" : _NO,
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
							parent.pageObj.grid.reloadList()
							closePopup();
						}); 
					} else {
						Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>" ); //오류가 발생하였습니다.
					}
				} catch(e) {
					console.error(e.message);
				}
			},
			error:function(response, status, error){
				 //TODO 추가 오류 처리
				 CFN_ErrorAjax("/covicore/manage/conf/registaddjob.do", response, status, error);
			}
		});
	}
	function closePopup(){
		Common.Close();
	}
</script>