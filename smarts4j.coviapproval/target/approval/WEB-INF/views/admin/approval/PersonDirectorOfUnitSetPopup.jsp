<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode = param[0].split('=')[1];
	var paramEntCode = param[1].split('=')[1];
	var paramUserCode = param[2].split('=')[1];
	var doublecheck = false;
	var flag = 2;  //falg 0=권한사용자선택 falg 1=피권한부서추가

	$(document).ready(function(){
		$("#Ent_Code").val(paramEntCode);
		
		if(mode=="modify"){
			$("#btn_delete").show();
			modifySetData();
		}
		
		$(document).on("keyup", "input:text[InputMode]", function() {
			if($(this).attr('InputMode')=="Numberic"){
				$(this).val( $(this).val().replace(/[^0-9]/gi,"") );
				var max = parseInt($(this).attr('num_max'));
			    var min = parseInt($(this).attr('num_min'));
			    if ($(this).val() > max)
			    {
			        $(this).val(max);
			    }
			    else if ($(this).val() < min)
			    {
			        $(this).val(min);
			    }   
			}			
		});
	});
	
	// 피권한 부서 테이블 내 행 추가
	function addDataRow(pCode, pName, pViewStartDate, pViewEndDate) {
		if(pCode && pName) {
			var sHTML = "";
			
			sHTML += "<tr style='border-bottom: 1px solid #ddd !important;'>";
			sHTML += "	<td style='text-align: center; word-break: break-all;'><input type='checkbox' name='ckhalias' id='user_" + XFN_ReplaceAllSpecialChars(pCode) + "' value='" + pCode + "'></td>";
			sHTML += "	<td style='text-align: center; word-break: break-all;'><input type='hidden' name='hidden_UNIT_NAME' id='hidden_UNIT_NAME_" + XFN_ReplaceAllSpecialChars(pCode) + "' value='" + pName + "'><label for='user_" + XFN_ReplaceAllSpecialChars(pCode) + "'>" + CFN_GetDicInfo(pName) + "</label></td>";
			sHTML += "	<td style='word-break: break-all;'><span>" + pCode + "</span><input type='hidden' name='hidden_UNIT_CODE' id='hidden_UNIT_CODE_" + XFN_ReplaceAllSpecialChars(pCode) + "' value='" + pCode + "'></td>";
			sHTML += "	<td style='text-align: center;'><input type='text' id='SEARCH_START_"+ XFN_ReplaceAllSpecialChars(pCode) +"' style='width: 95px' class='AXInput' /><div style='width: 15px; display: inline-block; padding-top: 5px;'>~</div><input type='text' kind='twindate' date_startTargetID='SEARCH_START_" + XFN_ReplaceAllSpecialChars(pCode) + "' id='SEARCH_END_" + XFN_ReplaceAllSpecialChars(pCode) + "' style='width: 95px' class='AXInput' /></td>";
			sHTML += "</tr>";
			
			$("#MGRDEPTLIST").append(sHTML);
			
			coviInput.init();
			
			if(pViewStartDate && pViewEndDate) {
				$("#SEARCH_START_" + XFN_ReplaceAllSpecialChars(pCode)).val(isEmpty(pViewStartDate,"") == "0000-00-00 00:00:00" ? "" : getStringDateToString("yyyy-MM-dd", isEmpty(pViewStartDate, "")));
				$("#SEARCH_END_" + XFN_ReplaceAllSpecialChars(pCode)).val(isEmpty(pViewEndDate,"") == "0000-00-00 00:00:00" ? "" : getStringDateToString("yyyy-MM-dd", isEmpty(pViewEndDate, "")));
			}
		}
	}
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	function isEmpty(value, defaultValue){
		return (value == null || value == undefined) ? defaultValue : value;
	}
	
	//수정화면 data셋팅
	function modifySetData(){
		//data 조회
		$.ajax({
			type:"POST",
			data:{
				"UserCode" : paramUserCode,
				"EntCode" : paramEntCode
			},
			url:"getPersonDirectorOfUnitData.do",
			success:function (data) {
				if(data.cnt>0){
					$("#DIS_APP_NAME").val(CFN_GetDicInfo(data.list[0].UserName));
					$("#APP_NAME").val(data.list[0].UserName);
					$("#UR_Code").val(data.list[0].UserCode);
					$("#AUTH_START").val(getStringDateToString("yyyy-MM-dd",data.list[0].AuthStartDate));
					$("#AUTH_END").val(getStringDateToString("yyyy-MM-dd",data.list[0].AuthEndDate));
					
					$("#MGRDEPTLIST").empty();

					for(var i=0; i<data.list.length;i++){
						addDataRow(data.list[i].UnitCode, data.list[i].UnitName, data.list[i].ViewStartDate, data.list[i].ViewEndDate);
					}
					
					$("#APP_DETAIL").val(data.list[0].Description);
					$("#APP_SORT").val(data.list[0].SortKey);
				}
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getPersonDirectorOfUnitData.do", response, status, error);
			}
		});
	}
	
	//조직도띄우기
	function OrgMap_Open(mapflag){
		flag = mapflag;
		
		if(mapflag == "0"){
			parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B1","1060px","580px","iframe",true,null,null,true);
		}else{
			parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=C9","1060px","580px","iframe",true,null,null,true);
		}
	}
	
	//저장
	function saveSubmit(){
		var UserCode = $("#UR_Code").val();
		var EntCode = $("#Ent_Code").val();		
		var UserName = $("#APP_NAME").val();
		var Description = $("#APP_DETAIL").val();
		var SortKey = $("#APP_SORT").val();
		var AuthStartDate = $("#AUTH_START").val();
		var AuthEndDate = $("#AUTH_END").val();
		
		if (axf.isEmpty(UserCode)) {
			parent.Common.Warning("<spring:message code='Cache.msg_apv_157' />");//대상자를 선택해 주세요.
            return false;
        }
		
		parent.Common.Confirm("<spring:message code='Cache.msg_apv_155' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				var directormemberArray = new Array();
				
				jQuery.ajaxSettings.traditional = true;
				
				$("#MGRDEPTLIST > tr").each(function(i, oRow){		
					var directormemberObj = new Object();
					
					directormemberObj.UserCode = UserCode;
					directormemberObj.UnitCode = $(oRow).find("input[name='hidden_UNIT_CODE']").val();
					directormemberObj.UnitName = $(oRow).find("input[name='hidden_UNIT_NAME']").val();
					directormemberObj.ViewStartDate = $(oRow).find("input[id^='SEARCH_START']").val();
					directormemberObj.ViewEndDate = $(oRow).find("input[id^='SEARCH_END']").val();

					directormemberArray.push(directormemberObj);		
				});
				
				//jsavaScript 객체를 JSON 객체로 변환
				directormemberArray = JSON.stringify(directormemberArray);		
				
				//insert 호출
				$.ajax({
					type:"POST",
					data:{
						"UserCode" 			: UserCode,			 
						"EntCode" 			: EntCode, 
						"UserName" 			: UserName ,
						"Description" 		: Description,
						"SortKey" 			: SortKey,
						"AuthStartDate" 	: AuthStartDate,
						"AuthEndDate" 		: AuthEndDate,
						"directormember" 	: directormemberArray
					},
					url:"insertPersonDirectorOfUnit.do",
					success:function (data) {
						if(data.result == "ok") {
							parent.Common.Inform("<spring:message code='Cache.msg_apv_117' />");
							closeLayer();
							parent.setUseAuthority();
						} else {
							parent.Common.Warning(data.message);
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("insertPersonDirectorOfUnit.do", response, status, error);
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
				var UserCode = $("#UR_Code").val();
				var EntCode = $("#Ent_Code").val();		
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"UserCode" : UserCode,			 
						"EntCode" : EntCode			
					},
					url:"deletePersonDirectorOfUnit.do",
					success:function (data) {
						if(data.result == "ok")
							parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />");
						closeLayer();
						parent.setUseAuthority();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deletePersonDirectorOfUnit.do", response, status, error);
					}
				});
			}
		});
	}
	
	//조직도선택후처리관련	
	parent._paramdata = paramdata;
	function paramdata(){
		return peopleObj;
	}
	
	//조직도선택후처리관련
	var peopleObj = "";
	parent._CallBackMethod2 = setMGRDEPTLIST;
	function setMGRDEPTLIST(peopleValue){
		peopleObj = peopleValue;
		
		var dataObj = $.parseJSON(peopleValue);

		
		if(dataObj.item.length > 0){
			if(flag==0){
				var UR_Name_Data = dataObj.item[0].DN;
				var UR_Code_Data = dataObj.item[0].AN;
				var Ent_Code_Data = dataObj.item[0].ETID;
				
				paramUserCode = UR_Code_Data;
				paramEntCode = Ent_Code_Data;
				modifySetData();
				
				$("#DIS_APP_NAME").val(CFN_GetDicInfo(UR_Name_Data));
				$("#APP_NAME").val(UR_Name_Data);
				$("#UR_Code").val(UR_Code_Data);
				$("#Ent_Code").val(Ent_Code_Data);
			} else if(flag==1){
				$(dataObj.item).each(function(i){	
					//기존리스트에 포함되어있는지 확인
                    if($("input[name='ckhalias'][value='" + dataObj.item[i].AN + "']").length > 0){
                    	parent.Common.Warning(CFN_GetDicInfo(dataObj.item[i].DN)+"(" + dataObj.item[i].AN + ")"+"<spring:message code='Cache.msg_AlreadyAdd' />");		//은(는) 이미 추가 되었습니다.
                        return;
                    }
					
                    addDataRow(dataObj.item[i].AN, dataObj.item[i].DN);
				});
			}
		}
	}
	
	//직접입력
	function addConfig(){		 
		if(!axf.isEmpty($("#DEPTNAME").val())&& !axf.isEmpty($("#DEPTCODE").val())){
			if($("#user_"+$("#DEPTCODE").val()).val()==$("#DEPTCODE").val()){
				parent.Common.Warning($("#DEPTNAME").val()+"("+$("#DEPTCODE").val()+")"+"<spring:message code='Cache.msg_AlreadyAdd' />");		//은(는) 이미 추가 되었습니다.
				return;
			}
			
			// 행 추가
			addDataRow($("#DEPTCODE").val(), $("#DEPTNAME").val());
			
			// 데이터 초기화
			$("#DEPTCODE").val("");
			$("#DEPTNAME").val("");
		}
	} 
	
	//부서삭제
	function delConfig(){
		$("#MGRDEPTLIST input[type='checkbox']:checked").each(function(){
			$(this).closest("tr").remove();	
		});

		coviInput.init();
	}
	
	function void_showManual_OnClick() {
		$("#DEPTCODE").val("");
		$("#DEPTNAME").val("");
		
		if($("#hDivManualInput").is(":visible")) {
			void_btnClose_OnClick();
		} else {
			$("#hDivManualInput").show();
			$("#DEPTNAME").focus();
		}
		
		coviInput.init();
	}
	
	function void_btnClose_OnClick() {
		$("#hDivManualInput").hide();
		coviInput.init();
	}
</script>
<form id="PersonDirectorOfUnitSetPopup" name="PersonDirectorOfUnitSetPopup">
	<div>
		<p class="txt_nt_01"><span style="font-size: 12px;color: #ee9700;font-weight: normal;"><spring:message code='Cache.msg_apv_DeptDocAuthorityScope'/></span></p>
		<p class="txt_nt_01"><span style="font-size: 12px;color: #ee9700;font-weight: normal;"><spring:message code='Cache.msg_apv_269'/></span></p>
		<table class="AXFormTable">
			<tr>
				<th style="width: 100px"><spring:message code='Cache.lbl_Specific_User'/></th>
				<td>
					<input name="DIS_APP_NAME" type="text" id="DIS_APP_NAME" style="width:100px;" ReadOnly="true" class="AXInput av-required" />
					<input name="APP_NAME" type="hidden" id="APP_NAME" />
					<input name="UR_Code" id="UR_Code" type="hidden" />
					<input type="button" class="AXButton" value="<spring:message code='Cache.lbl_apv_selection'/>" onclick="OrgMap_Open(0);"/>
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_Auth_Duration'/></th>
				<td>
					<input type="text" id="AUTH_START" style="width: 85px;" class="AXInput" />
					~
					<input type="text" kind="twindate" date_startTargetID="AUTH_START" id="AUTH_END" style="width: 105px;" class="AXInput" />
				</td>
			</tr>
			<tr>
				<th rowspan="2"><spring:message code='Cache.lbl_apv_Assignmented_Dept'/></th>
				<td class="t_back01_line">
					<input type="button" class="AXButton" value="<spring:message code='Cache.btn_apv_directinsert'/>" onclick="void_showManual_OnClick();"/>
					<input type="button" class="AXButton" value="<spring:message code='Cache.lbl_apv_orgselect'/>" onclick="OrgMap_Open(1);"/>
					<input type="button" class="AXButton" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="delConfig()"/>
					<div id="hDivManualInput" style="display: none; background-color: #eee; border: solid 1px #cccccc; padding: 4px; margin-top: 5px;">
						<span>
							<div style="display: inline-block; width: 55px; margin-left: 10px; padding-top: 5px;"><spring:message code="Cache.lbl_DeptName"/></div>
							<input type="text" id="DEPTNAME" style="width: 100px;" maxlength="30" class="AXInput av-required"/>
						</span>
						<span>
							<div style="display: inline-block; width: 70px; margin-left: 10px; padding-top: 5px;"><spring:message code="Cache.lbl_DeptCode"/></div>
							<input type="text" id="DEPTCODE" style="width: 100px;" maxlength="30" class="AXInput av-required"/>
						</span>
						<span style="float: right;">
							<input type="button" class="AXButton" value="<spring:message code='Cache.btn_Add'/>" onclick="addConfig();"/>
							<input type="button" class="AXButton" value="<spring:message code='Cache.btn_Close'/>" onclick="void_btnClose_OnClick();"/>
						</span>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<div style="margin: 2px; min-height: 200px;">
						<table class="AXFormTable">
							<colgroup>
								<col style="width: 30px;"/>
								<col style="width: 20%;"/>
								<col style="width: 25%;"/>
								<col style="width: 55%;"/>
							</colgroup>
							<thead>
								<tr style="height: 38px;">
									<th style="border-left: none !important; border-right: none !important;"></th>
									<th style="text-align: center; padding: 5px; border-left: none !important; border-right: none !important;"><spring:message code="Cache.lbl_DeptName"/></th>
									<th style="text-align: center; padding: 5px; border-left: none !important; border-right: none !important;"><spring:message code="Cache.lbl_DeptCode"/></th>
									<th style="text-align: center; padding: 5px; border-left: none !important; border-right: none !important;"><spring:message code="Cache.lbl_Search_Duration"/></th>
								</tr>
							</thead>
							<tbody id="MGRDEPTLIST" name="MGRDEPTLIST"></tbody>
						</table>
					</div>
				</td>
			</tr>
			<tr style="display: none;"> <!-- 쿼리 작업 후 사용-->
				<th></th>
				<td>
					<span class="pleft"> <spring:message code='Cache.lbl_Search_Duration'/> : </span>&nbsp;
					<input type="text" id="SEARCH_START" style="width: 85px" class="AXInput" />
					~
					<input type="text" kind="twindate" date_startTargetID="SEARCH_START" id="SEARCH_END" style="width: 85px" class="AXInput" />
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_apv_desc'/></th>
				<td><input name="APP_DETAIL" type="text" id="APP_DETAIL" style="width: 100%;" maxlength="255" class="AXInput av-required" /></td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_apv_Sort'/></th>
				<td><input name="APP_SORT" type="text" id="APP_SORT" InputMode="Numberic"  num_min="0" num_max="32767" style="width: 50px;" maxlength="9"  class="AXInput"/>
			</tr>
		</table>
		<div align="center" style="padding-top: 10px">
			<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveSubmit();" class="AXButton red" />
			<input type="button" id="btn_delete" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="deleteSubmit();" style="display: none"  class="AXButton" />
			<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
	<input type="hidden" id="SeqHiddenValue" value="" />
	<input type="hidden" id="Ent_Code" value="" />
</form>