<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<form id="addBaseCode" name="addBaseCode">
	<div>
		<table class="AXFormTable">
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_DN_Code"/></th>
				<td>
					<select id="add_domain" style="height:28px; width:135px;"></select>
				</td>
				<th><spring:message code="Cache.lbl_BizSection"/></th>
				<td>
					<div id="add_BizSection"></div>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_CodeGroup"/></th>
				<td colspan="3">
					<input type="text" id="add_CodeGroup" name="<spring:message code="Cache.lbl_SettingKey"/>" style="width:70%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_Code"/></th>
				<td colspan="3">
					<input type="text" id="add_Code" name="<spring:message code="Cache.lbl_SettingKey"/>" style="width:70%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					<input type="button"  value="<spring:message code="Cache.btn_CheckDouble"/>" onclick="doubleCheck('add_Code');" class="AXButton" />
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_codeNm"/></th>
				<td colspan="3">
					<input type="text" id="add_CodeNm" name="<spring:message code="Cache.lbl_SettingKey"/>" style="width:70%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					<input id="add_MultiCodeName" name="add_MultiCodeName" type="hidden" />
		  			<input type="button" value="<spring:message code='Cache.lbl_MultiLang2'/>" class="AXButton" onclick="dictionaryLayerPopup();" /> <!-- 다국어 -->
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_Sort"/></th>
				<td>
					<input type="text" id="add_Sort" mode="number" allow_minus="false" name="<spring:message code="Cache.lbl_CodeGroup"/>" style="width:70%;height:25px;" class="AXInput av-required"/>
				</td>
				<th><font color="red">* </font><spring:message code="Cache.lbl_IsUse"/></th>
				<td style="padding-left:5px">
					<select id="add_isused" class="selectType04">
						<option value="Y"  selected><spring:message code="Cache.lbl_Use"/></option> <!-- 사용  -->
						<option value="N" ><spring:message code="Cache.lbl_NotUse"/></option><!-- 비사용  -->
					</select>
				</td>
			</tr>
			<tr>
				<th>Reserved1</th>
				<td>
					<input type="text" id="add_Reserved1" name="Reserved1" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
				<th>Reserved2</th>
				<td>
					<input type="text" id="add_Reserved2" name="Reserved2" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th>Reserved3</th>
				<td>
					<input type="text" id="add_Reserved3" name="Reserved3" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
				<th>ReservedInt</th>
				<td>
					<input type="text" id="add_ReservedInt" mode="number" allow_minus="false" name="ReservedInt" style="width:90%;height:25px;" class="AXInput av-required"/>
				</td>
			</tr>
			<tr style="height: 100px">
				<th><spring:message code="Cache.lbl_Description"/></th>
				<td colspan="3">
					<textarea rows="5" style="width: 90%" id="add_explain" name="<spring:message code="Cache.lbl_Description"/>" class="AXTextarea av-required HtmlCheckXSS ScriptCheckXSS	"></textarea>
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
	var codeID = CFN_GetQueryString("codeID");
	var doublecheck = false;
	var origin_code;
	var origin_code_group;
	var lang = Common.getSession("lang");
	var	mode = CFN_GetQueryString("mode");
	
	initContent();
	
	function initContent(){ 
		setSelect();					// Select box 세팅
		if(mode=="modify"){
			$("#btn_create").hide();
			$("#btn_modify").show();
			setSelectData();		// Selct box 데이터 세팅
			origin_code = $("#add_Code").val();
			origin_code_group = $("#add_CodeGroup").val();
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
			var DomainID = document.getElementById("add_domain").value;
			var CodeGroup = document.getElementById("add_CodeGroup").value;
			var Code = document.getElementById("add_Code").value;

			if(origin_code === Code && origin_code_group === CodeGroup){
				Common.Inform("<spring:message code='Cache.msg_ValueNotChange'/>")
				doublecheck = true;
				return true;
			}
			$.ajax({
				type:"POST",
				data:{
					"DN_ID" : DomainID,
					"CodeGroup" : CodeGroup,
					"Code" : Code
				},
				url:"/covicore/basecode/checkDouble.do",
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
					CFN_ErrorAjax("/covicore/basecode/checkDouble.do", response, status, error);
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
					CFN_ErrorAjax("/covicore/basecode/encrypt.do", response, status, error);
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
		}else if($("#add_Sort").val() == "" || $("#add_Sort").val() == null || $("#add_Sort").val() == undefined){
			Common.Warning("<spring:message code='Cache.msg_RequiredSort'/>");
			return false;
		}else if($("#add_CodeGroup").val() == "" || $("#add_CodeGroup").val() == null || $("#add_CodeGroup").val() == undefined){
			Common.Warning("<spring:message code='Cache.msg_RequiredCodeGroup'/>");
			return false;
		}else if($("#add_Code").val() == "" || $("#add_Code").val() == null || $("#add_Code").val() == undefined){
			Common.Warning("<spring:message code='Cache.msg_RequiredCode'/>");
			return false;
		}else if($("#add_CodeNm").val() == "" || $("#add_CodeNm").val() == null || $("#add_CodeNm").val() == undefined){
			Common.Warning("<spring:message code='Cache.msg_RequiredCodeNm'/>");
			return false;
		}else if(!coviInput.setValidator("addBaseCode", "<spring:message code='Cache.msg_ValidationCheck'/>")){
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
			} 
			else if(origin_code === $("#add_Code").val() && origin_code_group === $("#add_CodeGroup").val()){
				Common.Warning("<spring:message code='Cache.msg_BaseCode_04'/>");
			}else {
				var dnid = $('#add_domain').val();
				var bizsection = coviCtrl.getSelected('add_BizSection').val;
				var sort =  $("#add_Sort").val();
				var codegroup =  $("#add_CodeGroup").val();
				var code =  $("#add_Code").val();
				var codenm = $("#add_CodeNm").val();
				var isuse = $("#add_isused").val();
				if(isuse ==undefined){isuse='Y';}
				var reserved1 = $("#add_Reserved1").val();
				var reserved2 = $("#add_Reserved2").val();
				var reserved3 = $("#add_Reserved3").val();
				var reservedInt = $("#add_ReservedInt").val();
				var description =  $("#add_explain").val();

				setMultiCodeName();
				
				//insert 호출
				$.ajax({
					type:"POST",
					data:{
						"DN_ID" : dnid,
						"BizSection" : bizsection,
						"SortKey" : sort,
						"CodeGroup" : codegroup,
						"Code" : code,
						"CodeName" : codenm,
						"IsUse" : isuse,
						"Reserved1" : reserved1,
						"Reserved2" : reserved2,
						"Reserved3" : reserved3,
						"ReservedInt" : reservedInt,
						"Description" : description,
						"MultiCodeName" : $("#add_MultiCodeName").val()
					},
					url:"add.do",
					success:function (data) {
						if(data.result == "ok")
							Common.Inform("<spring:message code='Cache.msg_AddData'/>");
						closeLayer();
						parent.codeGroupGrid.reloadList();
						parent.baseCodeGrid.reloadList();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/basecode/add.do", response, status, error);
					}
				});
			}
		}
	}
	
	// 데이터 수정
	function modifySubmit(){
		if(RequiredCheck()) {
			if(mode != "modify" && !doublecheck){ // [2019-01-28 MOD] gbhwang 수정 시 중복확인 로직 제외
				Common.Warning("<spring:message code='Cache.msg_CheckDoubleAlert'/>");
			} else {
				var dnid = $('#add_domain').val();
				var bizsection = coviCtrl.getSelected('add_BizSection').val;
				var sort =  $("#add_Sort").val();
				var codegroup =  $("#add_CodeGroup").val();
				var code =  $("#add_Code").val();
				var codenm = $("#add_CodeNm").val();
				var isuse = $("#add_isused").val();
				var description =  $("#add_explain").val();
				var reserved1 = $("#add_Reserved1").val();
				var reserved2 = $("#add_Reserved2").val();
				var reserved3 = $("#add_Reserved3").val();
				var reservedInt = $("#add_ReservedInt").val();
				
				setMultiCodeName();
				
				//update 호출
				$.ajax({
					type:"POST",
					data:{
						"Seq" : codeID,
						"DN_ID" : dnid,
						"BizSection" : bizsection,
						"SortKey" : sort,
						"CodeGroup" : codegroup,
						"Code" : code,
						"CodeName" : codenm,
						"IsUse" : isuse,
						"Reserved1" : reserved1,
						"Reserved2" : reserved2,
						"Reserved3" : reserved3,
						"ReservedInt" : reservedInt,
						"Description" : description,
						"MultiCodeName" : $("#add_MultiCodeName").val()
					},
					url:"modify.do",
					success:function (data) {
						if(data.result == "ok")
							Common.Inform("<spring:message code='Cache.msg_Edited'/>");
						closeLayer();
						parent.baseCodeGrid.reloadList();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/basecode/modify.do", response, status, error);
					}
				});
			}
		}
	}
	
	//Selct box 데이터 세팅. 기초 코드 값
	function setSelectData(){
		$.ajax({
			type: "POST",
			data: {
				  "code": CFN_GetQueryString("code")
				, "codeGroup": CFN_GetQueryString("codeGroup")
				, "domainID": CFN_GetQueryString("domainID")
				, "codeID" : codeID 							// 22.02.28 : code값 안에 빈값이 있을 경우 초기값 조회가 안될 수 있으므로, codeID 값 추가.
			},
			async: false,
			url: "getOne.do",
			success: function (data) {
				if(data.list != null && data.list[0] != null){
					$("#add_domain").setValueSelect(data.list[0].DomainID).bindSelectDisabled(true);
					coviCtrl.setSelected('add_BizSection', data.list[0].BizSection); 
					$("#add_Sort").val(data.list[0].SortKey);
					$("#add_CodeGroup").val(data.list[0].CodeGroup).prop("disabled", true);
					$("#add_Code").val(data.list[0].Code).prop("disabled", true);
					$("#add_CodeNm").val(data.list[0].CodeName);
					$("#add_MultiCodeName").val(data.list[0].MultiCodeName);
					$("#add_isused").val(data.list[0].IsUse);
					$("#add_Reserved1").val(Common.ObjectToString(data.list[0].Reserved1));
					$("#add_Reserved2").val(Common.ObjectToString(data.list[0].Reserved2));
					$("#add_Reserved3").val(Common.ObjectToString(data.list[0].Reserved3));
					$("#add_ReservedInt").val(data.list[0].ReservedInt);
					$("#add_explain").val(data.list[0].Description);	
				}	
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/basecode/getOne.do", response, status, error);
			}
		});
	}
	// Select Box 바인드
	function setSelect(){
		coviCtrl.renderDomainAXSelect('add_domain', lang, null, null);
		
		var initInfos = [
		{
		target : 'add_BizSection',
		codeGroup : 'BizSection',
		defaultVal : '',
		width : '80',
		onchange : ''
		}];
		
		coviCtrl.renderAjaxSelect(initInfos, '', lang);

	}
	
	
	//다국어 설정 팝업
	function dictionaryLayerPopup(){
		var option = {
				lang : lang,
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh,lang1,lang2',
				useShort : 'false',
				dicCallback : 'dicCallback',
				openerID : CFN_GetQueryString("CFN_OpenLayerName"),
				popupTargetID : 'setMultiLangData',
				init : 'dicInit'
		};
		
		var url = "";
		url += "/covicore/control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		url += "&openerID=" + option.openerID;
		url += "&popupTargetID=" + option.popupTargetID;
		url += "&init=" + option.init;
		
		parent.Common.open("","setMultiLangData","<spring:message code='Cache.lbl_MultiLangSet' />",url,"400px","280px","iframe",true,null,null,true);
	}

	//다국어 세팅 함수
	function dicInit(){
		if(document.getElementById("add_MultiCodeName").value == ''){
			value = document.getElementById('add_CodeNm').value;
		}else{
			value = document.getElementById("add_MultiCodeName").value;
		}
		
		return value;
	}

	//다국어 콜백 함수
	function dicCallback(data){
		var jsonData = JSON.parse(data);
		
		$("#add_MultiCodeName").val(coviDic.convertDic(jsonData));
		if(document.getElementById('add_CodeNm').value == ''){
			document.getElementById('add_CodeNm').value = CFN_GetDicInfo(coviDic.convertDic(jsonData), lang);
		}
		
		Common.Close("setMultiLangData");
	}
	
	function setMultiCodeName(){
		var sDictionaryInfo = document.getElementById("add_MultiCodeName").value;
		if (sDictionaryInfo == "") {
		      switch (lang.toUpperCase()) {
		          case "KO": sDictionaryInfo = document.getElementById("add_CodeNm").value + ";;;;;;;;;"; break;
		          case "EN": sDictionaryInfo = ";" + document.getElementById("add_CodeNm").value + ";;;;;;;;"; break;
		          case "JA": sDictionaryInfo = ";;" + document.getElementById("add_CodeNm").value + ";;;;;;;"; break;
		          case "ZH": sDictionaryInfo = ";;;" + document.getElementById("add_CodeNm").value + ";;;;;;"; break;
		          case "E1": sDictionaryInfo = ";;;;" + document.getElementById("add_CodeNm").value + ";;;;;"; break;
		          case "E2": sDictionaryInfo = ";;;;;" + document.getElementById("add_CodeNm").value + ";;;;"; break;
		          case "E3": sDictionaryInfo = ";;;;;;" + document.getElementById("add_CodeNm").value + ";;;"; break;
		          case "E4": sDictionaryInfo = ";;;;;;;" + document.getElementById("add_CodeNm").value + ";;"; break;
		          case "E5": sDictionaryInfo = ";;;;;;;;" + document.getElementById("add_CodeNm").value + ";"; break;
		          case "E6": sDictionaryInfo = ";;;;;;;;;" + document.getElementById("add_CodeNm").value; break;
		       }
		       document.getElementById("add_MultiCodeName").value = sDictionaryInfo
		}
	}
	
</script>
