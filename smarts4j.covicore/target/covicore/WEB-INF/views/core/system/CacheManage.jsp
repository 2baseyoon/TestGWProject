<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

	<h3 class="con_tit_box">
        <span class="con_tit">개발지원-캐쉬관리</span>
        <a href="#" class="set_box">
        	<span class="set_initialpage"><p>초기 페이지로 설정</p></span>
        </a>
    </h3>
	<form id="form1">
		<table class="AXFormTable">
			<colgroup>	
				<col style="width: 100px">
				<col style="width: *">
				<col style="width: 200px">
			</colgroup>
			<tbody>
			<tr>
				<th>CacheType</th>
				<td>
					<select id="selCacheType">
						<option value="DIC">다국어</option>
						<option value="BASECONFIG">기초설정값</option>
						<option value="BASECODE">기초코드값</option>
						<option value="FORM">양식 템플릿</option>
						<option value="PORTAL">포탈 템플릿</option>
						<option value="SESSION">세션</option>
						<option value="MENU">사용자별 메뉴</option>
						<option value="AUTH">인증메뉴(권한대상)</option>
						<option value="AUDIT">URL(권한)</option>
					</select>
					<div id="explain" style="display: inline-block;padding-left:50px" class="star">
						<ul>
							<li>다국어키 : 예] Code : lbl_apv_apvType</li>
							<li style="display:none">기초설정키 : 예] Code : EditorType</li>
							<li style="display:none">기초코드값 : 예] CodeGroup : ActivityState/ Code: CP</li>
							<li style="display:none">양식 템플릿 : 예] Code : WF_FORM_VACATION_REQUEST2_V0.html</li>
							<li style="display:none">포탈 템플릿 : 예] Code : TabBoard.html</li>
							<li style="display:none">SESSION : 예] Code : CSJTK값</li>
							<li style="display:none">사용자 key_그룹seq: 예] Code : superadmin_15
							<li style="display:none">sys_object_menu의 url: 예] Code : /groupware/layout/board_BoardList.do</li>
							<li style="display:none">sys_object_module의 url: 예] Code : /account/accountCommon/accountCommonPopup.do</li>
						</ul>
					</div>
				</td>
				<td rowspan=4 style="text-valign:bottom;text-align:right">
					<input type="button" class="AXButton" onclick="deleteCache(); return false;" value="개별 캐쉬 삭제"><br>
					<input type="button" class="AXButton" onclick="deleteAllCache(); return false;" value="유형별 캐쉬 전체 삭제"><br>
					<input type="button" class="AXButton" onclick="getCache(); return false;" value="개별 캐쉬 조회">
				</td>
			</tr>
			<tr id="trDomain">
				<th>Domain</th>
				<td>
<!-- 					<input type="text" class="AXInput" id="txtDomainID"> -->
					<select class="AXSelect" id="selectDomain"></select>
				</td>
			</tr>
			<tr id="trCodeGroup">
				<th>CodeGroup</th>
				<td><input type="text" class="AXInput" id="txtCodeGroup"></td>
			</tr>
			<tr id="trCode">
				<th>Code</th>
				<td><input type="text" class="AXInput" id="txtCode"></td>
			</tr>
			</tbody>
		</table>
		<br>
		<div class="topbar_grid">
			<input type="button" class="AXButton" onclick="reloadCache('BASECONFIG'); return false;" value="BaseConfig 초기화">
			<input type="button" class="AXButton" onclick="reloadCache('BASECODE'); return false;" value="BaseCode 초기화">
			<input type="button" class="AXButton" onclick="reloadCache('DIC'); return false;" value="다국어 초기화">
		</div>
		<div class="topbar_grid">
			Domain: <!-- <input type="text" class="AXInput" id="txtDomainID2"> --><select class="AXSelect" id="selectDomain2"></select>
			<input type="button" class="AXButton" onclick="deleteUserMenu(); return false;" value="사용자 메뉴 권한  삭제">
		</div>
		<div class="topbar_grid">
			<input type="button" class="AXButton" onclick="reloadCache('AUTH'); return false;" value="메뉴 권한 초기화">
			<input type="button" class="AXButton" onclick="reloadCache('AUDIT'); return false;" value="URL 감시 초기화">
		</div>
		
		<div class="topbar_grid">
			<input type="button" class="AXButton Red" onclick="reloadCache('ALL'); return false;" value="Redis 초기화">
	        <span class="star">※ Redis 전체가  초기화 됩니다. 로그인 사용자는 로그아웃됩니다.</span>
		</div>
		
		<div class="topbar_grid">
			<input type="button" class="AXButton BtnDelete" value="<spring:message code="Cache.lbl_RemoveLicenseCache"/>" onclick="confirmRemove();"/> <!-- 라이선스 인증 캐쉬 제거 -->
		</div>
		<br/><br/><br/><br/>
		
		<table>
			<tr>
				<th>DicCode</th>
				<td><input type="text" class="AXInput" id="txtDicCode"></td>
				<th>DicType</th>
				<td><input type="text" class="AXInput" id="txtDicType"></td>
				<th>Locale</th>
				<td><input type="text" class="AXInput" id="txtLocale"></td>
			</tr>
		</table>
		<input type="button" class="AXButton" onclick="getDicResult(); return false;" value="다국어적용(GetDic)">
		<input type="button" class="AXButton" onclick="getDicResult('all'); return false;" value="다국어적용(GetDicAll)">
		<input type="text" class="AXInput" id="txtResult" readonly="readonly"><br/>
		<input type="button" class="AXButton" onclick="getRedisDicResult(); return false;" value="Redis 다국어 적용">
		<br/><br/><br/><br/>
		<div>
			<h2>Form Template Redis 캐시 삭제 (회사구분없이 전체삭제)</h2>
			(redis 삭제가 필요한 파일을 체크하세요)
			<div id="formRedisDelete">
				<br>
				<input type="checkbox" id="formMenuChk" value="FormMenu.html">FormMenu.html<br>
				<input type="checkbox" id="formApvLineChk" value="FormApvLine.html">FormApvLine.html<br>
				<input type="checkbox" id="formCommonFieldsChk" value="FormCommonFields.html">FormCommonFields.html<br>
				<input type="checkbox" id="formHeaderChk" value="FormHeader.html">FormHeader.html<br>
				<input type="checkbox" id="formFooterChk" value="FormFooter.html">FormFooter.html<br>
				<input type="checkbox" id="formAttachChk" value="FormAttach.html">FormAttach.html<br>
				<input type="checkbox" id="formFileChk" value=""><input type="text" id="formTempFileName" >&nbsp;양식 파일명을 입력하세요. ex)WF_Form_Draft.html<br><br>
			</div>
			<input type="button" class="AXButton" onclick="deleteFormTempleteRedisCache(); return false;" value="Form Templete Redis 캐시삭제">
		</div>
	</form>
	
<script type="text/javascript">
	/* 캐쉬 관리
	
	1. 공용 데이터
		1.1. 다국어 데이터
			DIC_{DomainID}_{DicCode}
			
		1.2. 기초 데이터
			1.2.1. BaseConfig
				CONFIG_{DomainID}_{SettingKey}
			
			1.2.2. BaseCode
				CODE_{CodeGroup}_{Code}
		
		1.3. template 정보
			1.3.1. 양식 template
				formTemplate_{양식명}
			1.3.2. portal template
				{템플릿명}
			
	2. 개인별 데이터
		2.1. 세션 데이터	
			{JSESSIONID}
		2.2. 권한 데이터
			ACL_{DomainID}_{UserID}
		2.3. 권한 처리 된 메뉴 데이터
			MENU_{DomainID}_{UserID}
	
	*/
	
	//개별호출 일괄처리
	var sessionObj = Common.getSession();
	Common.getBaseConfigList(["RedisReplicationMode"]);
	
	//기초설정 redis 이중화 여부 Y/N 조회
	var replication_mode = coviCmn.configMap["RedisReplicationMode"];
	
	$(document).ready(function (){
		//$('#trCodeGroup').hide();
		$('#txtCodeGroup').attr("disabled", true);
		$("#selCacheType").change(function() {
			$("#explain li").hide();
			$("#explain li:eq("+$('#selCacheType option').index($('#selCacheType option:selected'))+")").show();
			var $selected = $(this).val();
			
			if($selected == 'BASECONFIG' 
					|| $selected == 'DIC'
					|| $selected == 'ACL'
					|| $selected == 'MENU'){
				$("#selectDomain").bindSelectDisabled(false);
				$('#txtCodeGroup').val('').attr("disabled", true);
			} else if($selected == 'BASECODE'){
				$("#selectDomain").bindSelectDisabled(false);
				
				$('#txtCodeGroup').attr("disabled", false);
			} else if($selected == 'FORM'){
				if("Y" == Common.getGlobalProperties("isSaaS")){
					$("#selectDomain").bindSelectSetValue('').bindSelectDisabled(false);					
				}else{
					$("#selectDomain").bindSelectSetValue('').bindSelectDisabled(true);
				}
				$('#txtCodeGroup').val('').attr("disabled", true);
			} else {
				$("#selectDomain").bindSelectSetValue('').bindSelectDisabled(true)
				$('#txtCodeGroup').val('').attr("disabled", true);
			}
			
		});
		
		coviCtrl.renderDomainAXSelect('selectDomain', Common.getSession('lang'), null, null, null, 'Y')
		coviCtrl.renderDomainAXSelect('selectDomain2', Common.getSession('lang'), null, null, null, 'Y')
	});

	function getCache(){
		$.ajax({
			url:"/covicore/cache/get.do",
 			type:"post",
 			data:{
 				"cacheType" : $("#selCacheType option:selected").val(),
 				"domainID" : $("#selectDomain").val(), // $('#txtDomainID').val(),
 				"codeGroup" : $('#txtCodeGroup').val(),
 				"code" : $('#txtCode').val()
 			},
 			success: function (res) {
 				if (res.data){
 					Common.Inform(JSON.stringify(res.data));
 				}
 				else{
 					Common.Inform('캐싱된 내용이 없습니다.');
 				}
 			},
 			error : function (error){
 				Common.Error(error);
 			}
 		});
	}
	
	function deleteUserMenu(){
		$.ajax({
			url:"/covicore/cache/removeAll.do",
 			type:"post",
 			data:{
 				"replicationFlag": replication_mode,
 				"cacheType" : "MENU",
 				"domainID" : ($('#selectDomain2').val().trim() == "") ? "*" : $('#txtDomainID2').val()
 			},
 			success: function (res) {
 				Common.Inform(res.status);
 			},
 			error : function (error){
 				Common.Error(error);
 			}
 		});
	}
	
	function deleteCache(){
		if ($('#txtCode').val() == "*"|| $('#txtCode').val().trim()==""){
			Common.Inform("삭제할 데이타를 입력하세요");
			return;
		}
		$.ajax({
			url:"/covicore/cache/remove.do",
 			type:"post",
 			data:{
 				"replicationFlag": replication_mode,
 				"cacheType" : $("#selCacheType option:selected").val(),
 				"domainID" : $("#selectDomain").val(), // $('#txtDomainID').val(),
 				"codeGroup" : $('#txtCodeGroup').val(),
 				"code" : $('#txtCode').val()
 			},
 			success: function (res) {
 				Common.Inform(res.status);
 			},
 			error : function (error){
 				Common.Error(error);
 			}
 		});
	}
	
	function reloadCache(pCacheType){
		if (pCacheType == "ALL" && !confirm("Redis 전체가 초기화 됩니다. 로그인 사용자는 로그아웃됩니다.\r초기화 하시겠습니까?")) return;

		$.ajax({
			url:"/covicore/cache/reloadCache.do",
 			type:"post",
 			data:{
 				"replicationFlag": replication_mode,
 				"cacheType" : pCacheType
 			},
 			success: function (res) {
 				Common.Inform(res.status);
 			},
 			error : function (error){
 				Common.Error(error);
 			}
 		});
	}
	
	function deleteAllCache(){
		if ($("#selCacheType option:selected").val() == "DIC"
				|| $("#selCacheType option:selected").val() == "BASECONFIG"
				|| $("#selCacheType option:selected").val() == "BASECODE"
				){
			reloadCache($("#selCacheType option:selected").val());
		}
		else{
			$.ajax({
				url:"/covicore/cache/removeAll.do",
	 			type:"post",
	 			data:{
	 				"replicationFlag": replication_mode,
	 				"cacheType" : $("#selCacheType option:selected").val(),
	 				"domainID" : $("#selectDomain").val(), // $('#txtDomainID').val(),
	 				"codeGroup" : $('#txtCodeGroup').val()
	 			},
	 			success: function (res) {
	 				Common.Inform(res.status);
	 			},
	 			error : function (error){
	 				Common.Error(error);
	 			}
	 		});
		}	
	}
	
	function getDicResult(pMode){
		if(pMode == "all")
			$("#txtResult").val(Common.getDicAll($("#txtDicCode").val(),$("#txtDicType").val() == "Full" ? true : false,$("#txtLocale").val()));
		else 
			$("#txtResult").val(Common.getDic($("#txtDicCode").val(),$("#txtDicType").val() == "Full" ? true : false,$("#txtLocale").val()));
	}
	
	function deleteFormTempleteRedisCache(){
		var file = new Array();
		
		$("#formRedisDelete").find("input[type=checkbox]").each(function(){
			if($(this).is(":checked")==true){
				if($(this).attr("id") == "formFileChk"){
					file.push("ko_formTemplate_"+$("#formTempFileName").val());
					file.push("en_formTemplate_"+$("#formTempFileName").val());
					file.push("ja_formTemplate_"+$("#formTempFileName").val());
					file.push("zh_formTemplate_"+$("#formTempFileName").val());
					file.push("e1_formTemplate_"+$("#formTempFileName").val());
					file.push("e2_formTemplate_"+$("#formTempFileName").val());
					file.push("e3_formTemplate_"+$("#formTempFileName").val());
					file.push("e4_formTemplate_"+$("#formTempFileName").val());
					file.push("e5_formTemplate_"+$("#formTempFileName").val());
					file.push("e6_formTemplate_"+$("#formTempFileName").val());
				}else{
					file.push("ko_formTemplate_"+$(this).val());
					file.push("en_formTemplate_"+$(this).val());
					file.push("ja_formTemplate_"+$(this).val());
					file.push("zh_formTemplate_"+$(this).val());
					file.push("e1_formTemplate_"+$(this).val());
					file.push("e2_formTemplate_"+$(this).val());
					file.push("e3_formTemplate_"+$(this).val());
					file.push("e4_formTemplate_"+$(this).val());
					file.push("e5_formTemplate_"+$(this).val());
					file.push("e6_formTemplate_"+$(this).val());
				}
			}
		});
		
		var returnSucess = "";
		
		if(file && file.length > 0){
			$.ajax({
				url:"/covicore/cache/remove.do",
	 			type:"post",
	 			async:false,
	 			data:{
	 				"replicationFlag": replication_mode,
	 				"cacheType" : "FORM",
	 				"domainID" : "*",
	 				"code" : $("#formTempFileName").val()
	 			},
	 			success: function (res) {
	 				for(var i=0; i<file.length; i++){
	 					returnSucess += " " + file[i] + ",";
	 				}
	 				returnSucess = returnSucess.substring(0, returnSucess.length-1);
	 				Common.Inform(returnSucess + " 를 Redis에서 삭제하였습니다.");
	 			},
	 			error : function (error){
	 				Common.Error(error);
	 			}
	 		});
		}
		/*
		if(returnSucess != ""){
			returnSucess = returnSucess.substring(0, returnSucess.length-1);
			Common.Inform(returnSucess + " 를 Redis에서 삭제하였습니다.");
		}
		*/
	}
	
	function confirmRemove(){
		Common.Confirm("라이센스 인증캐쉬를 삭제하시겠습니까?", "<spring:message code='Cache.lbl_RemoveLicenseCache'/>", function(result){ /* 라이선스 인증 캐쉬 제거 */
			if(result)
				removeLicenseCache();		
		});
	}
	
	function removeLicenseCache(){
		Common.Confirm("<spring:message code='Cache.msg_RemoveLicenseCache'/>" /* 사용자 별 라이선스 인증 캐쉬를 제거합니다.<br>금일 관리자 알림 메일도 재전송하려면 [확인] 아니면 [취소]를 눌러주세요. */
				, "<spring:message code='Cache.lbl_RemoveLicenseCache'/>", function(result){ /* 라이선스 인증 캐쉬 제거 */
			var removeMailCache;
			
			if(result){
				removeMailCache = "Y";
			}else{
				removeMailCache = "N";
			}
			
			$.ajax({
				type: "post"
				, url: "/covicore/license/removeLicenseCache.do"
				, data: {
					"removeMailCache":removeMailCache
				}, 
				success: function(data){
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_50'/>");			//삭제되었습니다.
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>");	//오류가 발생헸습니다.
					}
				},
	        	error:function(response, status, error){
	       	     CFN_ErrorAjax("/covicore/license/removeLicenseCache.do", response, status, error);
	       		}	
			});

		});
	}
</script>