<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<style>
input:disabled{background-color:#Eaeaea}
.dis_check{background-color:#Eaeaea !important}
input[type="checkbox"] { display:inline-block; }
.chkStyle10 { display:inline-block; margin-left:7px; vertical-align:middle; }
.chkStyle10:first-child { margin-left:0; }
.chkStyle10 input[type="checkbox"] { display:none; }
.chkStyle10 input[type="checkbox"] + label { font-size:13px; color:#333; }
.chkStyle10 input[type="checkbox"] + label .s_check { position:relative; display:inline-block; margin:-3px 6px 0 0; width:15px;  height:15px; vertical-align:middle; background-color: #fff; border: 1px solid #ACAEB2; border-radius:3px; box-sizing: border-box; cursor:pointer; }
.chkStyle10 input[type="checkbox"]:checked + label .s_check { background:#566472; border:1px solid #566472; }
.chkStyle10 input[type="checkbox"]:checked + label .s_check:after { position:absolute; left:4px; top:1px; display:block; content:""; width:3px; height:6px; border:1px solid #fff; border-width: 0 2px 2px 0; -webkit-transform: rotate(45deg); -ms-transform: rotate(45deg); transform: rotate(45deg); }
</style>

<form id="addBaseCode" name="addBaseCode">
	<div>
		<table class="AXFormTable">
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_DN_Code"/></th>
				<td>
					<select id="add_domain" style="height: 28px;"></select>
				</td>
				<th><spring:message code="Cache.lbl_BizSection"/></th>
				<td>
					<div id="add_BizSection"></div>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_CodeGroup"/></th>
				<td colspan="3">
					<input type="text" id="add_CodeGroup" name="<spring:message code="Cache.lbl_SettingKey" />" value="TodoMsgType" readonly style="width:70%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
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
				<th><spring:message code="Cache.lbl_Mail"/></th> <!-- 메일  -->
				<td>
					<div id="message1"></div>
				</td>
				<th><spring:message code="Cache.lbl_ToDo"/></th> <!-- TODO  -->
				<td>
					<div id="message2"></div>
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.CPMail_MDM"/></th>  <!-- PUSH  -->
				<td>
					<div id="message3"></div>
				</td>
				<th><spring:message code="Cache.lbl_Messanger"/></th>  <!-- 메신저  -->
				<td>
					<div id="message4"></div>
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_n_att_vacTypeDisplay"/></th>
				<td>
					<input type="text" kind="switch" on_value="1" off_value="0" id="userView" value="" style="width:40px;height:21px;border:0px none;" />
				</td>
				<th></th>
				<td></td>
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
			<tr style="height: 50px">
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
		
		$("#message1").html(drawMedia({Reserved1:"",Reserved2:"",Reserved3:"",CodeID:""}, "MAIL"));
		$("#message2").html(drawMedia({Reserved1:"",Reserved2:"",Reserved3:"",CodeID:""}, "TODOLIST"));
		$("#message3").html(drawMedia({Reserved1:"",Reserved2:"",Reserved3:"",CodeID:""}, "MDM"));
		$("#message4").html(drawMedia({Reserved1:"",Reserved2:"",Reserved3:"",CodeID:""}, "MESSENGER"));
		$("#message5").html('<input type="text" kind="switch" on_value="1" off_value="0" id="userView" value="" style="width:40px;height:21px;border:0px none;" />');
		
		if(mode=="modify"){
			$("#btn_create").hide();
			$("#btn_modify").show();
			setSelectData();		// Selct box 데이터 세팅
			
			origin_code = $("#add_Code").val();
			origin_code_group = $("#add_CodeGroup").val();
		}
		
		$(document).off('click','.check_class').on('click','.check_class',function(){
			var dataMap = $(this).data();
			var mediaType = $(this).val();
			var mediaFlag = $(this).prop("checked")?"Y":"N";
			var reserved1 = $("#add_Reserved1").val();
			var reserved2 = $("#add_Reserved2").val();
			var reserved3 = $("#add_Reserved3").val();
			
			if(reserved1.length > 0)
				if(reserved1.charAt(reserved1.length-1) != ";") reserved1 = reserved1 + ";";
			if(reserved2.length > 0)
				if(reserved2.charAt(reserved2.length-1) != ";") reserved2 = reserved2 + ";";
			if(reserved3.length > 0)
				if(reserved3.charAt(reserved3.length-1) != ";") reserved3 = reserved3 + ";";
			
			if($(this).data("mode") == "USE"){
				if(mediaFlag == "Y"){
					reserved1 = reserved1.replace(mediaType + ';', '') + mediaType + ';';
					
					$(this).closest('td').find(".s_check").removeClass("dis_check");
					$(this).closest('td').find(".check_class").attr("disabled", false);
				}else{
					reserved1 = reserved1.replace(mediaType + ';', '');
					reserved2 = reserved2.replace(mediaType + ';', '');
					reserved3 = reserved3.replace(mediaType + ';', '');
					
					$(this).closest('td').find(".s_check").eq(1).removeClass("dis_check").addClass("dis_check");
					$(this).closest('td').find(".s_check").eq(2).removeClass("dis_check").addClass("dis_check");
					$(this).closest('td').find(".check_class").eq(1).attr("disabled", true);
					$(this).closest('td').find(".check_class").eq(2).attr("disabled", true);
				}
			}else if($(this).data("mode") == "DEF"){
				if(mediaFlag == "Y"){
					reserved2 = reserved2.replace(mediaType + ';', '') + mediaType + ';';
				}else{
					reserved2 = reserved2.replace(mediaType + ';', '');
				}
			}else if($(this).data("mode") == "DIV"){
				if(mediaFlag == "Y"){
					reserved3 = reserved3.replace(mediaType + ';', '') + mediaType + ';';
				}else{
					reserved3 = reserved3.replace(mediaType + ';', '');
				}
			}
			
			$("#add_Reserved1").val(reserved1);
			$("#add_Reserved2").val(reserved2);
			$("#add_Reserved3").val(reserved3);
	    });
		
		//사용자 노출
		$("#userView").change(function(){
			$("#add_ReservedInt").val($(this).val());
		});
		
	}
	
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
					url:"/covicore/basecode/add.do",
					success:function (data) {
						if(data.result == "ok")
							Common.Inform("<spring:message code='Cache.msg_AddData'/>");
						
						//parent.baseCodeGrid.reloadList();
						parent.msgTypeObj.grid.myGrid.reloadList();
						closeLayer();
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
					url:"/covicore/basecode/modify.do",
					success:function (data) {
						if(data.result == "ok")
							Common.Inform("<spring:message code='Cache.msg_Edited'/>");
						
						parent.msgTypeObj.grid.myGrid.reloadList();
						closeLayer();
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
			},
			async: false,
			url: "/covicore/basecode/getOne.do",
			
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
					
					$("#message1").html(drawMedia(data.list[0], "MAIL"));
					$("#message2").html(drawMedia(data.list[0], "TODOLIST"));
					$("#message3").html(drawMedia(data.list[0], "MDM"));
					$("#message4").html(drawMedia(data.list[0], "MESSENGER"));
					$("#userView").val(data.list[0].ReservedInt);
					
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
	
	function drawMedia(data, filterType){
		
		var mediaList = data.Reserved1.split(";");//사용가능한 매체
		var useMedia = data.Reserved2.split(";");//사용자가 설정 가능한 매체 
		var defaultMedia = data.Reserved3.split(";");//초기설정값
		var codeId = data.CodeID;
		var objId = filterType+'_'+codeId;
		
		var isUse = inArray(filterType, mediaList)?true:false;
		var dataMap	 = " data-codeId='"+data.CodeID+"'";				
		// data-map='"+JSON.stringify(dataMap)+"'
		
		return '<div class="chkStyle10">'+
		'			<input type="checkbox" class="check_class" id="chk'+objId+'_1" value="'+filterType+'"' +(isUse ?"checked":"")+' data-mode="USE" '+dataMap+'">'+
		'			<label for="chk'+objId+'_1"><span class="s_check"></span>사용</label>'+
		'		</div>	'+
		'<div class="chkStyle10">'+
		'			<input type="checkbox" class="check_class" id="chk'+objId+'_2" value="'+filterType+'"' +(isUse?"":"")+'  '+(isUse?"":"disabled")+' '+(inArray(filterType, defaultMedia) ?"checked":"")+'  data-mode="DIV" '+dataMap+'">'+
		'			<label for="chk'+objId+'_2"><span class="s_check  '+(isUse?"":"dis_check")+' "></span>기본</label>'+
		'		</div>	'+
		'<div class="chkStyle10">'+
		'			<input type="checkbox" class="check_class" id="chk'+objId+'_3" value="'+filterType+'"' +(isUse?"":"")+'  '+(isUse?"":"disabled")+' '+(inArray(filterType, useMedia) ?"checked":"")+'  data-mode="DEF" '+dataMap+'">'+
		'			<label for="chk'+objId+'_3"><span class="s_check  '+(isUse?"":"dis_check")+' "></span>개인</label>'+
		'		</div>	'
		;
	}
	
	function inArray(findStr, arrayList, col){
		for (var i=0; i < arrayList.length; i++){
			if (col != "")
				if (arrayList[i][col] == findStr)	return true;
			else
				if (arrayList[i] == findStr)	return true;
		}
		return false;
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
