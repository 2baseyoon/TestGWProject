<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<style>
#AXselect_AX_add_BizSection_AX_SelectBox{
	left:6px;
}
#AXselect_AX_add_isused_AX_SelectBox{
	left : 6px;
}
#AXselect_AX_add_BizSection_AX_expandBox{
	left:120px;
}
</style>
<form id="twoFactorForm" name="twoFactorForm">
	<div>
		<table class="AXFormTable">
			<tr>
				<th style="width: 110px;"><font color="red">* </font><spring:message code="Cache.lbl_StartIP"/></th>
				<td>
					<input type="text" id="startIP" name="startIP" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th style="width: 110px;"><font color="red">* </font><spring:message code="Cache.lbl_EndIP"/></th>
				<td>
					<input type="text" id="endIP" name="endIP" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th style="width: 110px;"><font color="red">* </font><spring:message code="Cache.lbl_OwnedCompany"/></th>
				<td>
					 <select id="selectCompany" class="AXSelect W100"></select>
				</td>
			</tr>
			<tr>
				<th style="width: 110px;"><font color="red">* </font>Login</th>
				<td>
					 <select id="selectLogin">
						<option value="Y">Y</option>
						<option value="N">N</option>
					</select>
				</td>
			</tr>
			<tr>
				<th style="width: 110px;"><font color="red">* </font>Admin</th>
				<td>
					 <select id="selectAdmin">
						<option value="Y">Y</option>
						<option value="N">N</option>
					</select>
				</td>
			</tr>
			<tr style="height: 100px">
				<th><spring:message code="Cache.lbl_Description"/></th>
				<td>
					<textarea rows="5" style="width: 90%" id="descript" name="<spring:message code="Cache.lbl_Description"/>" class="AXTextarea av-required HtmlCheckXSS ScriptCheckXSS"></textarea>
				</td>
			</tr>
		</table>
		<div align="center" style="padding-top: 10px">
			<input type="button" id="btn_create" value="<spring:message code="Cache.btn_Add"/>" onclick="addSubmit();" class="AXButton red" />
			<input type="button" id="btn_modify" value="<spring:message code="Cache.btn_Edit"/>" onclick="modifySubmit();" style="display: none"  class="AXButton red" />
			<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
	<input type="hidden" id="SeqHiddenValue" value="" />
</form>
<script>

var mode = "${mode}";
var seq = "${seq}";

$(document).ready(function () {		
	
	coviCtrl.renderCompanyAXSelect("selectCompany", Common.getSession("lang"), false, "", "", '');
	
	if(mode == "modify"){
		$("#btn_create").hide();
		$("#btn_modify").show();
		setFactor();
	}else{
		$("#btn_create").show();
		$("#btn_modify").hide();
	}
	
});

function setFactor(){
		
	$.ajax({
		type:"POST",
		data:{
			"seq" : seq
		},
		url:"/covicore/layout/TwoFactorInfo.do",
		success:function (data) {
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					$("#startIP").val(v.STARTIP);
					$("#endIP").val(v.ENDIP);
					$("#selectCompany").bindSelectSetValue(v.COMPANYCODE);
					$("#descript").val(v.DESCRIPTION);
					$("#selectLogin").val(v.ISLOGIN);
					$("#selectAdmin").val(v.ISADMIN);
				});
			}
		},
		error:function (error){
			CFN_ErrorAjax("/covicore/layout/TwoFactorInfo.do", response, status, error);
		}
	});
	
}

//레이어 팝업 닫기
function closeLayer(){
	Common.Close();
}

function modifySubmit(){
	if(validation()){
		$.ajax({
			type:"POST",
			data:{
				"seq" : seq,
				"STARTIP" : $("#startIP").val(),
				"ENDIP" :  $("#endIP").val(),
				"COMPANYCODE" : $("#selectCompany").val(),
				"DESCRIPTION" : $("#descript").val(),
				"ISLOGIN" : $("#selectLogin").val(),
				"ISADMIN" : $("#selectAdmin").val()
			},
			url:"/covicore/layout/TwoFactorEdit.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					parent.Common.Inform("<spring:message code='Cache.msg_Edited'/>");
					
					if(opener){
						opener.searchGrid();
					}else{
						parent.searchGrid();
					}
					closeLayer();
				}else{
					parent.Common.Warning("<spring:message code='Cache.msg_ComFailed'/>");
				}
			},
			error:function (error){
				CFN_ErrorAjax("/covicore/layout/TwoFactorInfo.do", response, status, error);
			}
		});
	}
	
}

function addSubmit(){
	if(validation()){
		$.ajax({
			type:"POST",
			data:{
				"STARTIP" : $("#startIP").val(),
				"ENDIP" :  $("#endIP").val(),
				"COMPANYCODE" : $("#selectCompany").val(),
				"DESCRIPTION" : $("#descript").val(),
				"ISLOGIN" : $("#selectLogin").val(),
				"ISADMIN" : $("#selectAdmin").val()
			},
			url:"/covicore/layout/TwoFactorAdd.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					parent.Common.Inform("<spring:message code='Cache.msg_insert'/>");
					
					if(opener){
						opener.searchGrid();
					}else{
						parent.searchGrid();
					}
					closeLayer();
				}else{
					parent.Common.Warning("<spring:message code='Cache.msg_ComFailed'/>");
				}
			},
			error:function (error){
				CFN_ErrorAjax("/covicore/layout/TwoFactorInfo.do", response, status, error);
			}
		});
	}
}

function validation(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	if($("#startIP").val() == ""){
		parent.Common.Warning("<spring:message code='Cache.msg_enter_startIP'/>", "Warning", function(){ //시작 IP를 입력하세요.
			$("#startIP").focus();
		});
		return false;
	}
	
	if(!checkIP($("#startIP").val())){
		parent.Common.Warning("<spring:message code='Cache.msg_att_ip_notreg'/>", "Warning", function(){ //IP형식이 틀립니다
			$("#startIP").focus();
		});  
		return false;
	}
	
	if($("#endIP").val() == ""){
		parent.Common.Warning("<spring:message code='Cache.msg_enter_endIP'/>", "Warning", function(){ //종료 IP를 입력하세요.
			$("#endIP").focus();
		}); 
		return false;
	}

	if(!checkIP($("#endIP").val())){
		parent.Common.Warning("<spring:message code='Cache.msg_att_ip_notreg'/>", "Warning", function(){ //IP형식이 틀립니다
			$("#endIP").focus();
		});  
		return false;
	}
	
	return true;
}

function checkIP(strIP) {
    var expUrl = /^(1|2)?\d?\d([.](1|2)?\d?\d){3}$/;
    return expUrl.test(strIP);
}

</script>
