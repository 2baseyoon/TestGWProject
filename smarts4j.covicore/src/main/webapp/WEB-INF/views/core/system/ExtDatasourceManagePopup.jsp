<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<form id="form_ExtDatasourcePop" name="form_ExtDatasourcePop">
	<div>
		<input type="hidden" id="DatasourceSeq" name="DatasourceSeq" />
		<table class="AXFormTable">
			<tr>
				<th style="width: 130px;"><font color="red">* </font>Pool Name</th>
				<td colspan="3">
					<input type="text" id="ConnectionPoolName" name="ConnectionPoolName" style="width:95%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>Driver Class Name</th>
				<td colspan="3">
					<input type="text" id="DriverClassName" name="DriverClassName" style="width:95%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>JDBC Url</th>
				<td colspan="3">
					<input type="text" id="Url" name="Url" style="width:95%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>User Name</th>
				<td>
					<input type="text" id="UserName" name="UserName" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
				<th style="width: 120px;"><font color="red">* </font>Password</th>
				<td>
					<input type="hidden" id="PrevPassword" name="PrevPassword" />
					<input type="password" id="Password" name="Password" autocomplete="off" style="width:90%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>Initial Size</th>
				<td>
					<input type="text" id="InitialSize" name="InitialSize" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
				<th><font color="red">* </font>Max Total</th>
				<td>
					<input type="text" id="MaxTotal" name="MaxTotal" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>Max Idle</th>
				<td>
					<input type="text" id="MaxIdle" name="MaxIdle" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
				<th><font color="red">* </font>Min Idle</th>
				<td>
					<input type="text" id="MinIdle" name="MinIdle" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>Max Wait Millis</th>
				<td>
					<input type="text" id="MaxWaitMillis" name="MaxWaitMillis" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
				<th><font color="red"></font>Validation Query</th>
				<td>
					<input type="text" id="ValidationQuery" name="ValidationQuery" style="width:90%;height:25px;" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr style="height:38px;">
				<th><font color="red"></font>Test on Borrow</th>
				<td>
					<input type="checkbox" id="TestOnBorrow" name="TestOnBorrow" value="true" class="AXCheck"/>
				</td>
				<th><font color="red"></font>Test on Return</th>
				<td>
					<input type="checkbox" id="TestOnReturn" name="TestOnReturn" value="true" class=""/>
				</td>
			</tr>
			<tr style="height:38px;">
				<th><font color="red"></font>Test while Idle</th>
				<td colspan="1">
					<input type="checkbox" id="TestWhileIdle" name="TestWhileIdle" value="true" class="AXCheck"/>
				</td>
				<th><font color="red"></font>Remove Abandoned<br/>On Maintenance</th>
				<td colspan="1">
					<input type="checkbox" id="RemoveAbandonedOnMaintenance" name="RemoveAbandonedOnMaintenance" value="true" class=""/>
				</td>
			</tr>
			<tr style="height:38px;">
				<th><font color=""></font>Time between Eviction<br/>Runs Millis(ms)</th>
				<td colspan="3">
					<input type="text" id="TimeBetweenEvictionRunsMillis" name="TimeBetweenEvictionRunsMillis" style="width:50px;height:25px;" class="AXInput HtmlCheckXSS ScriptCheckXSS" />
				</td>
			</tr>
			<tr style="height:38px;">
				<th><font color="red"></font>Remove Abandoned<br/>Timeout(seconds)</th>
				<td colspan="3">
					<input type="text" id="RemoveAbandonedTimeout" name="RemoveAbandonedTimeout" style="width:50px;height:25px;" class="AXInput HtmlCheckXSS ScriptCheckXSS" />
				</td>
			</tr>
			<tr>
				<th><font color="red"></font><spring:message code="Cache.lbl_Sort"/></th>
				<td colspan="3">
					<input type="text" id="SortSeq" name="SortSeq" style="width:50px;height:25px;" class="AXInput"/>
				</td>
			</tr>
			<tr>
				<th>Bind Target</th>
				<td colspan="3" style="line-height:170%;" class="bindTarget">
					<label style="display:block;">
						<input type="checkbox" id="target_covicore" value="/covicore" /><span style="position:relative;top:-3px;margin-left:5px;">/covicore</span>
					</label>
					<label style="display:block;">
						<input type="checkbox" id="target_groupware" value="/groupware" /><span style="position:relative;top:-3px;margin-left:5px;">/groupware</span>
					</label>
					<label style="display:block;">
						<input type="checkbox" id="target_approval" value="/approval" /><span style="position:relative;top:-3px;margin-left:5px;">/approval</span>
					</label>
					<label style="display:block;">
						<input type="checkbox" id="target_legacy" value="/legacy" /><span style="position:relative;top:-3px;margin-left:5px;">/legacy</span>
					</label>
					<label style="display:block;">
						<input type="checkbox" id="target_webhard" value="/webhard" /><span style="position:relative;top:-3px;margin-left:5px;">/webhard</span>
					</label>
					<input type="hidden" id="BindTarget" name="BindTarget" />
				</td>
			</tr>
			<tr style="height: 100px">
				<th><spring:message code="Cache.lbl_Description"/></th> <!-- 설명 -->
				<td colspan="3">
					<textarea rows="5" style="width: 95%;resize:none;" id="Description" name="Description" class="AXTextarea HtmlCheckXSS ScriptCheckXSS"></textarea>
				</td>
			</tr>
		</table>
		<div align="center" style="padding-top: 10px">
			<input type="button" id="btn_create" value="<spring:message code="Cache.btn_Add"/>" onclick="addDatasource();" class="AXButton red" />
			<input type="button" id="btn_modify" value="<spring:message code="Cache.btn_Edit"/>" onclick="modifyDatasource();" style="display: none"  class="AXButton red" />
			<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
</form>
<script>

var mode = coviCmn.isNull(CFN_GetQueryString("mode"), "add");
var DatasourceSeq = coviCmn.isNull(CFN_GetQueryString("datasourceSeq"), "0");

init();

function init(){
	if(mode == "modify"){
		$("#btn_create").hide();
		$("#btn_modify").show();
		setDataSourceData();
	}else{
		$("#btn_create").show();
		$("#btn_modify").hide();
	}
}

//정보 조회
function setDataSourceData(){
	$.ajax({
		type:"POST",
		data:{
			"datasourceSeq" : DatasourceSeq
		},
		url:"/covicore/extdatabase/getDatasourceInfo.do",
		success:function (data) {
			if(data.status =='SUCCESS'){
				for(key in data.info){
					if(key == "BindTarget") {
						var bindTargetData = data.info[key];
						var chks = $(".bindTarget").find("input[type=checkbox]").each(function(){
							if(bindTargetData.indexOf(this.value) > -1) {
								this.checked = true;
							}
						});
					}else{
						var $obj = $("#" + key);
						if($obj.length == 0) continue;
						if($obj[0].tagName.toLowerCase() == "textarea"){
							$obj.val(data.info[key]);
						}else{
							if("password" == $obj.attr("type") || "text" == $obj.attr("type") || "hidden" == $obj.attr("type")){
								$obj.val(data.info[key]);	
							}else if("checkbox" == $obj.attr("type")){
								if($obj.val() == data.info[key]){
									$obj.attr("checked", true);
								}else{
									$obj.attr("checked", false);
								}
							}
						}
					}
				}
				$("#PrevPassword").val(data.info.Password);
    		}else{
    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
    		}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/covicore/extdatabase/getDatasourceInfo.do", response, status, error);
		}
	});
	
}

//추가
function addDatasource(){
	if(validationChk()){
		makeTargetVal();
		$.ajax({
			type:"POST",
			data:$("#form_ExtDatasourcePop").serialize(),
			url:"/covicore/extdatabase/addDatasource.do",
			success:function (data) {
				if(data.status=='SUCCESS'){
		    		parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
						parent.datasourceGrid.reloadList();	    			
		    			Common.Close();
		    		});
	    		}else{
	    			parent.Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/extdatabase/addDatasource.do", response, status, error);
			}
		});
	}
}

//수정
function modifyDatasource(){
	if(validationChk()){
		makeTargetVal();
		$.ajax({
			type:"POST",
			data:$("#form_ExtDatasourcePop").serialize(),
			url:"/covicore/extdatabase/editDatasource.do",
			success:function (data) {
				if(data.status=='SUCCESS'){
		    		parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
						parent.datasourceGrid.reloadList();			
		    			Common.Close();
		    		});
	    		}else{
	    			parent.Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/extdatabase/editDatasource.do", response, status, error);
			}
		});
	}
	
}

function makeTargetVal() {
	var bindTargetArr = [];
	var chks = $(".bindTarget").find("input[type=checkbox]").each(function(){
		if(this.checked) {
			bindTargetArr.push(this.value);
		}
	});
	$("input#BindTarget").val(JSON.stringify(bindTargetArr));
}

//입력값 검증
function validationChk(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	var requiredInputs = $(".av-required");
	for(var i = 0; i < requiredInputs.length; i++){
		if(requiredInputs[i].value == ""){
			var txt = $(requiredInputs[i]).closest("td").prev("th").text();
			parent.Common.Warning("Field [" + txt + "] is required.", "Warning Dialog", function(){
				requiredInputs[i].focus();
			});
			return false; 
		}
	}
	return true;
}

//레이어 팝업 닫기
function closeLayer(){
	Common.Close();
}
</script>