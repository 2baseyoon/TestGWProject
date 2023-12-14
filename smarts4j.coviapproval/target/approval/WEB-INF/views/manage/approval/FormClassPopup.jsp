<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramFormClassID =  param[1].split('=')[1];
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가
	var lang = Common.getSession("lang");
	
	$(document).ready(function(){	
		setSelect();
		
		// 양식명 다국어 세팅
		coviDic.renderInclude('dic', {
			lang : 'ko',
			hasTransBtn : 'true',
			allowedLang : 'ko,en,ja,zh',
			dicCallback : '',
			popupTargetID : '',
			init : '',
			styleType : "U"
		});
		
		$("#dic").find(".AXFormTable").removeClass("AXFormTable").addClass("sadmin_table sa_menuBasicSetting");
		$("#dic").find(".sadmin_table").css("border-top", "none");
		$("#dic").find(".sadmin_table tr:last").css("border-bottom", "none");
		$("#dic").find("input[type=text]").removeClass("AXInput").addClass("menuName04");
		
		if(mode=="modify"){
			$("#btn_delete").show();
			modifySetData();
			//$("#SeqHiddenValue").val(key);					
		}else{
			setUseAuthority();
			$("#AclAllYN_Y").prop("checked", true);
		}
	});
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
		
	
	//수정화면 data셋팅
	function modifySetData(){
		//data 조회
		$.ajax({
			type:"POST",
			data:{
				"FormClassID" : paramFormClassID				
			},
			url:"getFormClassData.do",
			success:function (data) {					
				if(Object.keys(data.list[0]).length > 0){					
					$("#FormClassID").val(data.list[0].FormClassID);				
					//$("#FormClassName").val(data.list[0].FormClassName);
					$("#ko_full").val(data.list[0].FormClassName.split(";")[0]);
					try { // 기존데이터에서 오류 발생할 수 있음.
		 				$("#en_full").val(data.list[0].FormClassName.split(";")[1]);
		 				$("#ja_full").val(data.list[0].FormClassName.split(";")[2]);
		 				$("#zh_full").val(data.list[0].FormClassName.split(";")[3]);
					} catch(e) { coviCmn.traceLog(e); }
					
					$("#SortKey").val(data.list[0].SortKey);
					$("#EntCode").val(data.list[0].EntCode);					
					//$("#selectUseAuthority").bindSelectSetValue(data.list[0].EntCode);					
					$("#selectUseAuthority").val(data.list[0].EntCode).prop("selected", true);
					
					if(data.item.length > 0){
						parent._setParamdataAuth = data;
					}else{
						parent._setParamdataAuth = {}; 
					}
					
					if(Object.keys(parent._setParamdataAuth).length == 0 || (parent._setParamdataAuth.item && parent._setParamdataAuth.item.length == 0)){
						$("#AclAllYN_Y").prop("checked", true).trigger("change");
					}else{
						$("#AclAllYN_N").prop("checked", true).trigger("change");
					}
				}
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getFormClassData.do", response, status, error);
			}
		});
	}
	
	//저장
	function saveSubmit(){
		//data셋팅	
		var FormClassID = $("#FormClassID").val();				
		//var FormClassName = $("#FormClassName").val();
		var FormClassName = $("#ko_full").val() + ";" + $("#en_full").val() + ";" + $("#ja_full").val() + ";" + $("#zh_full").val();
		var EntCode = $("#selectUseAuthority").val();		
		var SortKey = $("#SortKey").val();		
		
		if (axf.isEmpty(CFN_GetDicInfo(FormClassName))) {
            Common.Warning("<spring:message code='Cache.msg_apv_016' />");
            return false;
        }
		
		var urlSubmit;
		var confirmMessage;
		
		var AclAllYN = "Y";
		var userAclAllYn = $("[name=AclAllYN]:checked").val(); // radio box
		if("Y" == userAclAllYn){
			parent._setParamdataAuth = {};
			AclAllYN = userAclAllYn;
		}
		var AuthDept = JSON.stringify(parent._setParamdataAuth);
		
		if (parent._setParamdataAuth.hasOwnProperty('item') && parent._setParamdataAuth.item.length > 0){ AclAllYN = "N"; }
		
		if(mode == 'add'){
			urlSubmit = 'insertFormClassData.do';
			confirmMessage = "<spring:message code='Cache.msg_RUSave' />";
		}else{
			urlSubmit = 'updateFormClassData.do';
			confirmMessage = "<spring:message code='Cache.msg_RUEdit' />";
		}
		
		parent.Common.Confirm(confirmMessage, "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				//insert 호출
				$.ajax({
					type:"POST",
					data:{
						"FormClassID"   : paramFormClassID,
						"FormClassName"   : FormClassName,
						"EntCode"   : EntCode,
						"SortKey"   : SortKey,
						"AuthDept" : AuthDept,
						"AclAllYN" : AclAllYN
					},
					url:urlSubmit,
					success:function (data) {
						if(data.result == "ok")
							Common.Inform(data.message);				
						closeLayer();
						parent.searchConfig();
					},
					error:function(response, status, error){
						CFN_ErrorAjax(urlSubmit, response, status, error);
					}
				});
			}
		});
	}
	
	//삭제
	function deleteSubmit(){
		parent.Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				var FormClassID = $("#FormClassID").val();
				
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"FormClassID" : FormClassID
					},
					url:"deleteFormClassData.do",
					success:function (data) {
						if(data.result == "ok"){
							parent.Common.Inform(data.message);
							
							if(data.cnt==0){
								closeLayer();
								parent.searchConfig();							
							}
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteFormClassData.do", response, status, error);
					}
				});
			}
		});
	}
	
	// Select box 바인드
	function setSelect(){
		var _onchange = function(){
			setUseAuthority();
		};
		coviCtrl.renderDomainAXSelect('selectUseAuthority', lang, _onchange, null, Common.getSession("DN_Code"), false, {codeType: "CODE"});
		$("#selectUseAuthority").unbindSelect();// remove style 
	}
	
	// Select box onchange
	function setUseAuthority(){
		$("#EntCode").val($("#selectUseAuthority").val());
	}
	
	//조직도띄우기
	function OrgMap_Open(mapflag){		
		var strType = "C9";
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_adminFrmPopCallback&type="+strType+"&setParamData=_setParamdataAuth","1060px","580px","iframe",true,null,null,true);	
	}
	
	parent._setParamdataAuth = {};

	//조직도선택후처리관련
	var peopleObj = {};
	parent._adminFrmPopCallback = setMGRDEPTLIST;
	function setMGRDEPTLIST(peopleValue){
		var dataObj = $.parseJSON(peopleValue);	
		parent._setParamdataAuth = dataObj;
		
		if(dataObj && dataObj.item && dataObj.item.length > 0){
			$("#AclAllYN_N").prop("checked", true).trigger("change");
		}else{
			$("#AclAllYN_Y").prop("checked", true).trigger("change");
		}
	}
	
	function changeAclAllYn (){
		var aclAllYn = $("[name=AclAllYN]:checked").val();
		if("Y" == aclAllYn){
			$("#permissionBtnSpan").css("visibility","hidden");
		}else{
			$("#permissionBtnSpan").css("visibility","");
		}
	}
</script>
<div class="sadmin_pop">
	<table class="sadmin_table sa_menuBasicSetting">
		<colgroup>
			<col width="130px">
			<col width="*">
		</colgroup>
		<tbody>
			<tr>
				<th><spring:message code='Cache.lbl_CateID' /></th>
				<td>
					<input id="FormClassID" name="FormClassID" class="w100" disabled="disabled" type="text" maxlength="64" />
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_CateName' /></th>
				<td style="padding: 0px" id="dic"></td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_apv_chage_ent' /></th>
				<td>
					<select name="selectUseAuthority" class="selectType02 w190p" id="selectUseAuthority" onchange="setUseAuthority();"></select>
					<input id="EntCode" name="EntCode" disabled="disabled" type="text" class="menuName03 mr0" maxlength="64"/>
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_SettingPermission' /></th>
				<!--권한설정-->
				<td>
					<span class="radioStyle04 size">
						<input type="radio" id="AclAllYN_Y" name="AclAllYN" value="Y" onchange="changeAclAllYn()" />
						<label for="AclAllYN_Y"><span><span></span></span><spring:message code='Cache.btn_All' /></label>
					</span>
					<span class="radioStyle04 size">
						<input type="radio" id="AclAllYN_N" name="AclAllYN" value="N" onchange="changeAclAllYn()" />
						<label for="AclAllYN_N"><span><span></span></span><spring:message code='Cache.lbl_SettingPermission' /></label>
					</span>
					<span id="permissionBtnSpan" style="visibility: hidden;">
					<a class="btnTypeDefault" onclick="OrgMap_Open(0);" ><spring:message code='Cache.lbl_SettingPermission'/></a>
				</span></td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_apv_SortKey' /></th>
				<td>
					<input class="w300p" max_length="5" mode="numberint" id="SortKey" name="SortKey" type="text" maxlength="64" />
				</td>
			</tr>
		</tbody>
	</table>
	<div class="bottomBtnWrap">
		<a onclick="saveSubmit();" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_apv_save'/></a> 
		<a id="btn_delete" class="btnTypeDefault" onclick="deleteSubmit();" style="display: none" ><spring:message code='Cache.btn_apv_delete'/></a>
		<a onclick="closeLayer();" class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>
	</div>
</div>