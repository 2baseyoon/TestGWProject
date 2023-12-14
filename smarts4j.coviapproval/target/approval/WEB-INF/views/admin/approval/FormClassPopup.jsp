<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramFormClassID =  param[1].split('=')[1];
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가

	$(document).ready(function(){	
		setSelect();
		
		// 양식명 다국어 세팅
		coviDic.renderInclude('dic', {
			//lang : langCode,
			lang : 'ko',
			hasTransBtn : 'true',
			allowedLang : 'ko,en,ja,zh',
			dicCallback : '',
			popupTargetID : '',
			init : '',
			styleType : 'T'
		});
		$("#dic").find(".AXFormTable").css("box-shadow", "none");
		$("#dic").find(".AXFormTable tbody td").css("border-right", "0px !important");
		$("#dic").find(".AXFormTable tbody th:last").css("border-bottom", "0px");
		$("#dic").find("input[id$='_full']").attr("maxlength", 50);
		
		if(mode=="modify"){
			$("#btn_delete").show();
			modifySetData();
			//$("#SeqHiddenValue").val(key);					
		}else{
			setUseAuthority();
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
		$("#selectUseAuthority").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/common/getEntInfoListAssignData.do",
			ajaxAsync:false,
			onchange: function(){
				setUseAuthority();
			}
		});
		$("#selectUseAuthority").unbindSelect();
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
<form id="BizDocListSetPopup.jsp" name="BizDocListSetPopup.jsp">
	<div>		 		
		<table class="AXFormTable" >
		  <colgroup>
			<col id="t_tit4">
			<col id="">
		  </colgroup>
		  <tbody>
		    <tr>
		      <th style="width:100px;"><spring:message code='Cache.lbl_CateID'/></th>
			  <td><input id="FormClassID" name="FormClassID" class="AXInput" disabled="disabled" type="text" maxlength="64" style="width:350px;"/></td>
		    </tr>
		    <tr>
		      <th style="width:100px;"><spring:message code='Cache.lbl_CateName'/></th>
		      <td style="width:550px;padding:0px" id="dic">	</td>
			  <!-- <td><input id="FormClassName" name="FormClassName" class="AXInput" type="text" maxlength="64" class="AXInput" style="width:350px;"/></td> -->
		    </tr>
			<tr>
		      <th style="width:100px;"><spring:message code='Cache.lbl_apv_chage_ent'/></th>
			  <td>
			  	<select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority" style="" onchange="setUseAuthority();"></select>			  	
			  	<input id="EntCode" name="EntCode" disabled="disabled" type="text" class="AXInput" maxlength="64" style="width:200px;"/>			  	
			  </td>
		    </tr>
		    <tr>
	          <th style="width:100px;"><spring:message code='Cache.lbl_SettingPermission'/></th> <!--권한설정-->
	          <td>
	          	<input type="radio" id="AclAllYN_Y" name="AclAllYN" value="Y" onchange="changeAclAllYn()" /><label for="AclAllYN_Y"><spring:message code='Cache.btn_All'/></label>
	          	<input type="radio" id="AclAllYN_N" name="AclAllYN" value="N" onchange="changeAclAllYn()" /><label for="AclAllYN_N"><spring:message code='Cache.lbl_SettingPermission'/></label>
	          	<span id="permissionBtnSpan" style="visibility:hidden;">
	          		<input type="button" class="AXButton"  value="<spring:message code='Cache.lbl_SettingPermission'/>" onclick="OrgMap_Open(0);"/>
	          	</span>
	          </td>
	        </tr>
			<tr>
		      <th style="width:100px;"><spring:message code='Cache.lbl_apv_SortKey'/></th>
			  <td><input class="AXInput" max_length="5" mode="numberint" id="SortKey" name="SortKey" type="text" maxlength="64" style="width:350px;"/></td>
		    </tr>
	      </tbody>
          
		</table>
		<div align="center" style="padding-top: 10px">
			<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveSubmit();" class="AXButton red" />
			<input type="button" id="btn_delete" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="deleteSubmit();" style="display: none"  class="AXButton" />
			<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
	<input type="hidden" id="SeqHiddenValue" value="" />
	<input type="hidden" id="EntCode" value="" />
</form>