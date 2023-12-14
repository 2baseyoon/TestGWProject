<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<form id="addBaseConfig" name="addBaseConfig">
	<div>
		<table class="AXFormTable">
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_DN_Code"/></th>
				<td>
					<select id="add_domain" style="height: 28px;"></select>
				</td>
				<th><spring:message code="Cache.lbl_BizSection"/></th>
				<td>
					<div id="add_worktype"></div>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_SettingKey"/></th>
				<td colspan="3">
					<input type="text" id="add_configkey" name="<spring:message code="Cache.lbl_SettingKey"/>" style="width:70%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					<input type="button"  value="<spring:message code="Cache.btn_CheckDouble"/>" onclick="doubleCheck('add_configkey');" class="AXButton" />
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_SettingValue"/></th>
				<td colspan="3">
					<input type="text" id="add_configvalue" name="<spring:message code="Cache.lbl_SettingValue"/>" style="width:70%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS" />
					<input type="button" value="<spring:message code="Cache.btn_Encryption"/>" onclick="EncryptValue('add_configvalue');" class="AXButton"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_IsCheck"/></th>
				<td>	
					<select id="add_ischeck" class="selectType04">
						<option value="Y" selected>Y</option> 
						<option value="N" >N</option>
					</select>
					
				</td>
				<th><font color="red">* </font><spring:message code="Cache.lbl_IsUse"/></th>
				<td style="padding-left:5px">
					<select id="add_isused" class="selectType04">
						<option value="Y" selected><spring:message code="Cache.lbl_Use"/></option> <!-- 사용  -->
						<option value="N" ><spring:message code="Cache.lbl_NotUse"/></option><!-- 비사용  -->
					</select>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>설정타입</th>
				<td colspan="3">
					<div id="add_type"></div>
					<input type="hidden" id="hidConfigType" value="">
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>설정명</th>
				<td colspan="3">
					<input type="text" id="add_configname" name="<spring:message code="Cache.lbl_SettingValue"/>" style="width:90%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS" />
				</td>
			</tr>
			<tr style="height: 100px">
				<th><font color="red">* </font><spring:message code="Cache.lbl_Description"/></th>
				<td colspan="3">
					<textarea rows="5" style="width: 90%" id="add_explain" name="<spring:message code="Cache.lbl_Description"/>" class="AXTextarea av-required HtmlCheckXSS ScriptCheckXSS"></textarea>
				</td>
			</tr>
		</table>
		<div align="center" style="padding-top: 10px">
			<input type="button" id="btn_create" value="<spring:message code="Cache.btn_Add"/>" onclick="addSubmit();" class="AXButton red" />
			<input type="button" id="btn_modify" value="<spring:message code="Cache.btn_Edit"/>" onclick="modifySubmit();" style="display: none"  class="AXButton red" />
			<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
</form>
<script>
	var mode = CFN_GetQueryString("mode");
	var configID = CFN_GetQueryString("configID");
	var doublecheck = false;
	var origin_settingkey;
	
	initContent();
	
	function initContent(){ 
		setSelect();					// Select box 세팅
		if(mode=="modify"){
			$("#btn_modify").show();
			$("#btn_create").hide();
			setSelectData();		// Selct box 데이터 세팅
			origin_settingkey = $("#add_configkey").val();
			
			// 기초설정 수정 제한
			var baseConfigType = Common.getGlobalProperties("baseConfigType");
			if(baseConfigType.indexOf($("#hidConfigType").val()) > -1) $("#btn_modify").hide();
		}
	};
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	// 중복 체크
	function doubleCheck(id){
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		if(document.getElementById(id).value == null || document.getElementById(id).value == ""){
			Common.Warning("<spring:message code='Cache.msg_RequiredCheck'/>");
			document.getElementById(id).focus();
			return false;
		}else{
			// 중복 체크 처리
			var settingkey =  $("#add_configkey").val();
			if(origin_settingkey === settingkey){
				Common.Inform("<spring:message code='Cache.msg_ValueNotChange'/>")
				doublecheck = true;
				return true;
			}
			
			var dnid = $('#add_domain').val();
			
			
			$.ajax({
				type:"POST",
				data:{
					"SettingKey" : settingkey,
					"DN_ID" : dnid
				},
				url:"checkDouble.do",
				success:function (data) {
					if(data.result == "ok"){
						Common.Inform("<spring:message code='Cache.msg_UseAvailable'/>")
						doublecheck = true;
					}else{
						Common.Warning("<spring:message code='Cache.msg_UseUnavailable'/>")
						doublecheck = false;
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/baseconfig/checkDouble.do", response, status, error);
				}
			});
			return true;
		}
	}
	
	// 암호화
	function EncryptValue(id){
		if(document.getElementById(id).value == null || document.getElementById(id).value == ""){
			Common.Warning("<spring:message code='Cache.msg_RequiredCheck'/>");
			document.getElementById(id).focus();
			return false;
		}else{
			//암호화 처리
			var settingvalue =  $("#add_configvalue").val();
			
			$.ajax({
				type:"POST",
				data:{
					"SettingValue" : settingvalue
				},
				url:"encrypt.do",
				success:function (data) {
					if(data.result == "ok"){
						$("#add_configvalue").val(data.encryptText);
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/baseconfig/encrypt.do", response, status, error);
				}
			});
			return true;
		}
	}
	
	function RequiredCheck(){
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		if(dnid = $('#add_domain').val() == "DomainID" || $('#add_domain').val() == null || $('#add_domain').val() == undefined){
			Common.Warning("<spring:message code='Cache.msg_RequiredDomainCode'/>");
			return false;
		}else if($('#add_configkey').val() == "" || $('#add_configkey').val()== null || $('#add_configkey').val() == undefined){
			Common.Warning("<spring:message code='Cache.msg_RequiredConfigKey'/>");
			return false;
		}else if($('#add_configvalue').val() == "" || $('#add_configvalue').val() == null || $('#add_configvalue').val() == undefined){
			Common.Warning("<spring:message code='Cache.msg_RequiredConfigValue'/>");
			return false;
		}else if($('#add_explain').val()== "" || $('#add_explain').val() == null || $('#add_explain').val()== undefined){
			Common.Warning("<spring:message code='Cache.msg_RequiredExplain'/>");
			return false;
		}else if(mode == "modify" && $("#hidConfigType").val() == "Immutable" && coviCtrl.getSelected('add_type').val == "Immutable"){
			Common.Warning("<spring:message code='Cache.msg_notModifySetting'/>"); // 수정할 수 없는 설정입니다.
			return false;
		}else{
			return true;
		}
	}
	
	// 데이터 추가
	function addSubmit(){
		if(RequiredCheck()) {
			if(!doublecheck){
				Common.Warning("<spring:message code='Cache.msg_CheckDoubleAlert'/>");
			} else {
				var dnid = $('#add_domain').val();
				var bizsection = coviCtrl.getSelected('add_worktype').val;
				var ischeck = $("#add_ischeck").val();
				var isuse =  $("#add_isused").val();
				var settingkey =  $("#add_configkey").val();
				var settingvalue =  $("#add_configvalue").val();
				var add_type = coviCtrl.getSelected('add_type').val;
				var add_configname =  $("#add_configname").val();
				var description =  $("#add_explain").val();
				//insert 호출
				$.ajax({
					type:"POST",
					data:{
						"BizSection" : bizsection,
						"DN_ID" : dnid,
						"SettingKey" : settingkey ,
						"SettingValue" : settingvalue,
						"IsCheck" : ischeck,
						"IsUse" : isuse,
						"ConfigType" : add_type,
						"ConfigName" : add_configname,
						"Description" : description
					},
					url:"/covicore/baseconfig/add.do",
					success:function (data) {
						if(data.result == "ok")
							Common.Inform("<spring:message code='Cache.msg_AddData'/>");
						closeLayer();
						parent.baseConfigGrid.reloadList();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/baseconfig/add.do", response, status, error);
					}
				});
			}
		}
	}
	
	// 데이터 수정
	function modifySubmit(){
		if(RequiredCheck()) {
			 if(mode != "modify" && !doublecheck){  // [2019-01-28 MOD] gbhwang 수정 시 중복확인 로직 제외
				 Common.Warning("<spring:message code='Cache.msg_CheckDoubleAlert'/>");
			} else {
				var dnid = $('#add_domain').val();
				var bizsection = coviCtrl.getSelected('add_worktype').val;
				var ischeck = $("#add_ischeck").val();
				var isuse = $("#add_isused").val();
				var settingkey =  $("#add_configkey").val();
				var settingvalue =  $("#add_configvalue").val();
				var add_type = coviCtrl.getSelected('add_type').val;
				var add_configname =  $("#add_configname").val();
				var description =  $("#add_explain").val();
				
				//update 호출
				$.ajax({
					type:"POST",
					data:{
						"Seq" : configID,
						"BizSection" : bizsection, 
						"DN_ID" : dnid, 
						"SettingKey" : settingkey ,
						"SettingValue" : settingvalue,
						"IsCheck" : ischeck,
						"IsUse" : isuse,
						"ConfigType" : add_type,
						"ConfigName" : add_configname,
						"Description" : description
					},
					url:"/covicore/baseconfig/modify.do",
					success:function (data) {
						if(data.result == "ok")
							Common.Inform("<spring:message code='Cache.msg_Edited'/>");
						closeLayer();
						parent.baseConfigGrid.reloadList();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/baseconfig/modify.do", response, status, error);
					}
				});
			}
		}
	}
	
	//Selct box 데이터 세팅. 기초 코드 값
	function setSelectData(){
		$.ajax({
			type:"POST",
			data:{
				"Seq" : configID
			},
			async:false,
			url:"getOne.do",
			success:function (data) {
				$("#add_domain").setValueSelect(data.list[0].DomainID);
				coviCtrl.setSelected('add_worktype', data.list[0].BizSection); 
				$("#add_isused").val(data.list[0].IsUse);
				$("#add_ischeck").val(data.list[0].IsCheck);
				$("#add_configkey").val(data.list[0].SettingKey);
				$("#add_configvalue").val(data.list[0].SettingValue);
				coviCtrl.setSelected('add_type', data.list[0].ConfigType); 
				$("#hidConfigType").val(data.list[0].ConfigType);
				$("#add_configname").val(data.list[0].ConfigName);
				$("#add_explain").val(data.list[0].Description);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/baseconfig/getOne.do", response, status, error);
			}
		});
	}
	
	// Select Box 바인드
	function setSelect(){

		coviCtrl.renderDomainAXSelect('add_domain', Common.getSession("lang"), null, null);

		// add_worktype, add_type
		var initInfos = [
	   		{
		   		target : 'add_worktype',
		   		codeGroup : 'BizSection',
		   		defaultVal : '',
		   		width : '100',
		   		onchange : ''
	   		},
	   		{
		   		target : 'add_type',
		   		codeGroup : 'ConfigType',
		   		defaultVal : '',
		   		width : '100',
		   		onchange : ''
	   		}
	   	];
		         		
		coviCtrl.renderAjaxSelect(initInfos, '', Common.getSession("lang"));
		
	}
	
</script>
