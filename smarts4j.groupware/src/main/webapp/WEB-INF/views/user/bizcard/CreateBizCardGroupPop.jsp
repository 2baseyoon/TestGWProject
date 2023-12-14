<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	<!-- script type="text/javascript" src="/groupware/resources/script/user/popup.js"></script-->
</head>

<body>	
	<div class="layer_divpop ui-draggable popBizGroupAdd" id="testpopup_p" style="width:750px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent BizGroupAdd">
				<div class="rowTypeWrap formWrap">
					<dl>
						<dt><spring:message code='Cache.lbl_GroupName' /></dt><!-- 그룹명 지정 -->
						<dd>
							<input type="text" id="txtGroupName" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.msg_EnterGroupName' />">
						</dd>
					</dl>
					<dl class="popBizGroupTarget">
						<dt><spring:message code='Cache.lbl_target' /></dt><!-- 대상 지정 -->
						<dd>
							<span class="radioStyle04"><input type="radio" id="ShareTypeP" name="ShareTypeVal" value="P" ><label for="ShareTypeP"><span class="mr5"><span></span></span><spring:message code='Cache.lbl_ShareType_Personal' /></label></span>
							<span class="radioStyle04"><input type="radio" id="ShareTypeD" name="ShareTypeVal" value="D" ><label for="ShareTypeD"><span class="mr5"><span></span></span><spring:message code='Cache.lbl_ShareType_Dept' /></label></span>
							<span class="radioStyle04"><input type="radio" id="ShareTypeU" name="ShareTypeVal" value="U" ><label for="ShareTypeU"><span class="mr5"><span></span></span><spring:message code='Cache.lbl_ShareType_Comp' /></label></span>
						</dd>
					</dl>
				</div>
				
				<div class="BizGroupUser_add_wrap">
							
							<div class="BizGroupUser_add_left">
								<div class="inpBtnBox">									
									<p><spring:message code='Cache.btn_apv_directinsert' /></p><a href="#" class="btnTypeDefault ml5 " onclick="BizcardOrgMapLayerPopup(this,'CreateBizCardGroupPop');return false;"><spring:message code='Cache.lbl_apv_org' /></a>									
								</div>
								<div class="BizGroupUser_add_left_box" style="margin-right: 0px !important;">
								<div class="rowTypeWrap formWrap">
									<dl>
										<dt><spring:message code='Cache.lbl_apv_username' /></dt><!--  이름 입력  -->
										<dd>
											<input type="text" id="txtName" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_Mail_PleaseEnterName' />">
										</dd>
									</dl>
									<dl>
										<dt><spring:message code='Cache.lbl_Email2' /></dt><!-- 이메일 입력 -->
										<dd>
											<input type="text" id="txtEmail" class="HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_Mail_PleaseEnterEmail' />">
										</dd>
									</dl>
								</div>
								</div>
							</div>
							<div class="arrowBtn bizgroup_add_pop" style="top: 30px !important;">
								<div class="arrowBtn01"><input class="btnRight mail" onclick="addSelectedBizcardRow();" type="button" value=">"><input class="btnLeft" onclick="removeSelectedBizcardRow();" type="button" value="<"></div>
							</div>
							<div class="BizGroupUser_add_right">
								<table class="BizGroupUser_add_table">
									<thead>
										<tr>
											<th width="54"><input type="checkbox" class="BizGroupUser_add_chk"></th>
											<th width="116" style="font-size: 10pt;"><spring:message code='Cache.CPMail_UserName' /></th>
											<th style="font-size: 10pt;"><spring:message code='Cache.CPMail_EmailAddress' /></th>
										</tr>
									</thead>
								</table>
								<div class="BizGroupUser_add_scroll">
									<table class="BizGroupUser_add_table">
										<tbody id="orgSelectedList">
											
										</tbody>
									</table>
								</div>
							</div>
						</div>
				
				<div class="popBtnWrap">
				  <a href="#" onclick="CheckValidation(this);" href="#" id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_register' /></a>
				  <a href="#" onclick="CheckValidation(this);" href="#" id="btnModify" class="btnTypeDefault btnThemeBg" style="display: none;"><spring:message code='Cache.btn_Edit' /></a>
				  <a href="#" onclick="closeLayer();" id="btnClose" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel' /></a>
				</div>
		  </div>
	  </div>	
	</div>

</body>
<script>

	$(function(){
		if("${mode}" == "modify"){
			$("#btnSave").css("display", "none");
			$("#btnModify").css("display", "");
			
			$.ajaxSetup({
				cache : false
			});
						
			$.getJSON('getBizcardGroup.do', {ShareType : '${ShareType}',GroupID : '${GroupID}'}, function(d) {
				d.list.forEach(function(d) {
					var UR_ID = Common.getSession("UR_ID");
					if((d.ShareType == 'U' || d.ShareType == 'D') && d.RegisterID != UR_ID && sessionObj["isAdmin"] != "Y"){ // 회사/부서의 구분 권한 처리
						$("input:radio[name=ShareTypeVal]").attr("disabled", true);
					}
					
					$("#txtGroupName").val(d.GroupName);
					$('input:radio[name=ShareTypeVal]').filter('[value='+d.ShareType+']').prop('checked', true);
				});
				d.bizcardlist.forEach(function(d) {
					var name = d.Name;
					var email = d.Email;
					var code = d.Code; 
					var itemType = d.ItemType;
					var bizcardid = d.BizCardID;
					var dataObj = {"itemType":""+itemType+"","BizCardID":""+bizcardid+"","Code":""+code+"","Name":""+name+"","EM":""+email+""};
					
					var html = "";
						html += "<tr>";
						html += "	<td width='54' align='center'><input type='checkbox' class='BizGroupUser_add_chk' id='orgSelectedList_"+CFN_GetDicInfo(email,lang) +"' name='"+name+"' value='"+ Object.toJSON(dataObj) +"'/></td>";
						html += "	<td width='116' align='center' style='font-size: 10pt;'>" + name + "</td>";
						html += "	<td style='font-size: 10pt;'>" + email + "</td>";
						html += "</tr>";
				  	if( html != ""){
				  		$("#orgSelectedList").append(html); //type: people or dept
				  	}
				});
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("getBizcardGroup.do", response, status, error);
			});
		
		}
		
		$(".BizGroupUser_add_right .BizGroupUser_add_chk").on("click", function(){
			if($(".BizGroupUser_add_chk").prop("checked")){
				$("#orgSelectedList .BizGroupUser_add_chk").prop("checked", true);
			}else{
				$("#orgSelectedList .BizGroupUser_add_chk").prop("checked", false);
			}
		});
	});

	function closeLayer() {
		var isWindowed = CFN_GetQueryString("CFN_OpenedWindow");
		
		if(isWindowed.toLowerCase() == "true") {
			window.close();
		} else {
			parent.Common.close('CreateBizCardGroupPop');
		}
	};
	
	function CheckValidation(pObj) {
	    var bReturn = true;
	    var shareTypeVal = $(":input:radio[name=ShareTypeVal]:checked").val();
	    
	    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	    
	    if ($.trim($("#txtGroupName").val()) == "") {
	        Common.Warning("<spring:message code='Cache.msg_EnterGroupName'/>", ""); //그룹명을 입력하세요.
	        bReturn = false;
	    } else if (shareTypeVal == "" || shareTypeVal == "undefined" || shareTypeVal == undefined) {
	        Common.Warning("<spring:message code='Cache.msg_apv_Line_UnSelect'/>", ""); //대상을 선택하세요.
	        bReturn = false;
	    }
	
	    if(!bReturn) return false;
		
		$.ajaxSetup({
		     async: true
		});
		var memberInfo = new Array();
		memberInfo = getSelectedGroupMemberData();
        
		if(pObj.id == 'btnSave'){
			$.ajax({
				url : "RegistBizCardGroup.do",
				type : "POST",
				data : {
					"GroupName" :  $("#txtGroupName").val(),
					"GroupPriorityOrder" :  '0',
					"ShareType" : shareTypeVal,					
					"GroupMember" : memberInfo
				},
				success : function(d) {
					try {
						if(d.result == "OK") {
							Common.Inform("<spring:message code='Cache.msg_SuccessRegist'/>", 'Information Dialog', function (result) { //정상적으로 등록되었습니다.
								parent.window.location.reload();
					        }); 
						} else if(d.result == "FAIL") {
							Common.Warning("<spring:message code='Cache.msg_ErrorRegistBizCardGroup'/>"); //그룹 등록 오류가 발생했습니다.
						} else {
							Common.Warning("<spring:message code='Cache.msg_CantRegistGroupDuplicateName'/>"); //이름이 중복된 그룹은 등록할 수 없습니다.
						}
					} catch(e) {
						coviCmn.traceLog(e);
					}
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("RegistBizCardGroup.do", response, status, error);
				}
			});
		} else if(pObj.id == 'btnModify'){
			$.ajax({
				url : "UpdateBizCardGroup.do",
				type : "POST",
				data : {
					"GroupName" :  $("#txtGroupName").val(),
					"GroupPriorityOrder" :  '0',
					"ShareType" : shareTypeVal,	
					"GroupID" : "${GroupID}",					
					"GroupMember" : memberInfo
				},
				success : function(d) {
					try {
						if(d.result == "OK") {
							Common.Inform("<spring:message code='Cache.msg_SuccessModify'/>", 'Information Dialog', function (result) { //정상적으로 수정되었습니다.
								parent.bizCardGrid.reloadList();
								closeLayer();
					        }); 
						} else if(d.result == "FAIL") {
							Common.Warning("<spring:message code='Cache.msg_ErrorModifyBizCardGroup'/>"); //그룹 수정 오류가 발생했습니다.
						} else {
							Common.Warning("<spring:message code='Cache.msg_CantRegistGroupDuplicateName'/>"); //이름이 중복된 그룹은 등록할 수 없습니다.
						}
					} catch(e) {
						coviCmn.traceLog(e);
					}
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("ModifyGroup.do", response, status, error);
				}
			});
		}
	}
	var lang = Common.getSession("lang"); //프로필 이미지 경로
	var dupStr=""; //중복된 데이터
	var orgDic =  Common.getDicAll(["lbl_officer", "lbl_apv_deptsearch", "btn_Confirm","btn_Close", "lbl_apv_person","btn_apv_search",
	                                ,"msg_OrgMap03","msg_OrgMap04","msg_OrgMap05","msg_OrgMap06","lbl_name","lbl_dept" , "msg_EnterSearchword"
	                                ,"lbl_MobilePhone", "lbl_apv_InPhone", "lbl_Role", "lbl_JobPosition","lbl_JobLevel","msg_NoDataList"
	                                ,"OrgTreeKind_Dept","OrgTreeKind_Group", "lbl_UserProfile", "lbl_DeptOrgMap" , "lbl_group","lbl_OpenAll","lbl_CloseAll", "lbl_apv_recinfo_td2"
									,"lbl_com_exportAddress", "lbl_apv_appMail", "lbl_com_Absense", "lbl_com_searchByName", "lbl_com_searchByDept", "lbl_com_searchByPhone"
									, "lbl_com_searchByRole", "lbl_com_searchByJobPosition", "lbl_com_searchByJobLevel" ,"lbl_Mail_Cc" , "lbl_Mail_Bcc" , "lbl_Mail_To"]);

	
	function removeSelectedBizcardRow(){
		$("#orgSelectedList input:checkbox").each(function(){
			if($(this).is(":checked")){
				$(this).parent().parent().remove();
			}
		});
	}
	function addSelectedBizcardRow(){
		var name = $("#txtName").val();
		var email = $("#txtEmail").val();
		
		var l_HtmlCheckValue = false;
		var l_ScriptCheckValue = false;
		var l_oTarget;
		
		if ($.trim(name) == ""){
			Common.Warning(Common.getDic("msg_ObjectUR_07"));			//이름 넣기
			return ;
		} else {
			if (XFN_CheckHTMLinText($("#txtName").val())) {
				l_HtmlCheckValue = true;
				l_oTarget = $("#txtName");
			}
			
			if (XFN_CheckInputLimit($("#txtName").val())) {
				l_ScriptCheckValue = true;
				l_oTarget = $("#txtName");
			}
			
			if(l_HtmlCheckValue || l_ScriptCheckValue) {
				if (l_ScriptCheckValue) { 	// 스크립트 입력불가
					l_WarningMsg = Common.getDic("msg_ThisPageLimitedScript");
				} else {  					// HTML 테그 입력 불가
					l_WarningMsg = Common.getDic("msg_ThisPageLimitedHTMLTag");
				}
				
				Common.Warning(l_WarningMsg, "Warning[" + $(l_oTarget).attr("id") + "]", function () { $(l_oTarget).focus(); });
				return ;
			}
		}
		
		var regex=/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([A-Za-z]{2,6}(?:\.[A-Za-z]{2})?)$/;
		if(regex.test(email) === false) {  
		    Common.Warning("<spring:message code='Cache.msg_bizcard_invalidEmailFormat'/>");  
			return ;
		}

		dupStr=""; //중복된 데이터
		var diffStr = "orgSelectedList_";
		var isOld = false;
		var oldSelectList_people = getSelectedBizcardData();	// 선택한 데이터 가져옴
		if (oldSelectList_people.length != 0) {
			for(var i=0; i<oldSelectList_people.length; i++){
				if(oldSelectList_people[i] == (diffStr + email)){
					dupStr += name +", "
					isOld = true;
					break;
				}
			}
		}
		
		if (!isOld) {		// 이미 추가된 목록이 아닐 때만
			var dataObj = {"itemType":"bizcard","BizCardID":"","Code":"","Name":""+name+"","EM":""+email+""};
			
			var html = "";
				html += "<tr>";
				html += "	<td width='54' align='center'><input type='checkbox' class='BizGroupUser_add_chk' id='orgSelectedList_"+CFN_GetDicInfo(email,lang) +"' name='"+name+"' value='"+ Object.toJSON(dataObj) +"'/></td>";
				html += "	<td width='116' align='center' style='font-size: 10pt;'>" + name + "</td>";
				html += "	<td style='font-size: 10pt;'>" + email + "</td>";
				html += "</tr>";
		  	if( html != ""){
		  		$("#orgSelectedList").append(html); //type: people or dept
		  	}
		  	
		  	$("#txtName").val('');
			$("#txtEmail").val('');
		}
		else{
			if(dupStr != ""){
				dupStr = dupStr.substr(0, dupStr.length-2);
				Common.Warning(dupStr +orgDic["msg_OrgMap06"]); //은(는) 이미 선택목록에 추가되어 있습니다.
			}
		}

	}
	function getSelectedBizcardData() {
		var rtnArr = new Array();
		$("[id^='orgSelectedList']").each(function(){
			rtnArr.push($(this)[0].id);
		});

		return rtnArr;
	}
	
	function getSelectedGroupMemberData() {
		var rtnArr = new Array();
		$("[id^='orgSelectedList']").each(function(){
			if($(this)[0].value != null && $(this)[0].value != undefined){
				rtnArr.push($(this)[0].value);
			}
		});

		return rtnArr;
	}
</script>