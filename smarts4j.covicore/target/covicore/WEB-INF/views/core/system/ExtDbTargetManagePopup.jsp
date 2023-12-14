<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<form id="form_ExtDbSyncTargetPop" name="form_ExtDbSyncTargetPop">
	<div>
		<input type="hidden" id="TargetSeq" name="TargetSeq" />
		<table class="AXFormTable">
			<tr>
				<th style="width:150px;"><font color="red">* </font>Target Name</th>
				<td colspan="3">
					<input type="text" id="TargetName" name="TargetName" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>Remote Database</th>
				<td colspan="3">
					<input type="text" id="SrcDatabase" name="SrcDatabase" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>Remote Table Name</th>
				<td colspan="3">
					<input type="text" id="SrcTableNm" name="SrcTableNm" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>Target Database Name</th>
				<td colspan="3">
					<input type="text" id="TargetDatabase" name="TargetDatabase" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>Target Table Name</th>
				<td colspan="3">
					<input type="text" id="TargetTableNm" name="TargetTableNm" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_DN_Code"/></th>
				<td colspan="3">
					<select id="DomainID" name="DomainID" class="AXSelect"></select>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>Connection Pool<br>(Datasource)</th>
				<td colspan="3">
					<select id="DatasourceSeq" name="DatasourceSeq" class="AXSelect"></select>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font>Use<br></th>
				<td colspan="3">
					<select id="UseYn" name="UseYn" class="AXSelect">
						<option value="Y" selected>Y</option>
						<option value="N">N</option>
					</select>
				</td>
			</tr>
			<tr>
				<th><font color="red"></font>Condition SQL</th>
				<td colspan="3">
					<textarea rows="5" style="width: 90%" id="ConditionSQL" name="ConditionSQL" class="AXTextarea HtmlCheckXSS ScriptCheckXSS"></textarea>
				</td>
			</tr>
			<tr>
				<th>Schedule Type</th>
				<td colspan="3">
					<input type="text" id="ScheduleType" name="ScheduleType" style="width:90%;height:25px;" class="AXInput HtmlCheckXSS ScriptCheckXSS">
				</td>
			</tr>
			<tr>
				<th><font color="red"></font><spring:message code="Cache.lbl_Sort"/></th>
				<td colspan="3">
					<input type="text" id="SortSeq" name="SortSeq" style="width:50px;height:25px;" class="AXInput"/>
				</td>
			</tr>
			<tr style="height: 100px">
				<th><spring:message code="Cache.lbl_Description"/></th> <!-- 설명 -->
				<td colspan="3">
					<textarea rows="5" style="width: 90%" id="Description" name="Description" class="AXTextarea HtmlCheckXSS ScriptCheckXSS"></textarea>
				</td>
			</tr>
		</table>
		<div align="center" style="padding-top: 10px">
			<input type="button" id="btn_create" value="<spring:message code="Cache.btn_Add"/>" onclick="addTarget();" class="AXButton red" />
			<input type="button" id="btn_modify" value="<spring:message code="Cache.btn_Edit"/>" onclick="modifyTarget();" style="display: none"  class="AXButton red" />
			<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
</form>
<script>

var mode = coviCmn.isNull(CFN_GetQueryString("mode"), "add");
var TargetSeq = coviCmn.isNull(CFN_GetQueryString("TargetSeq"), "0");

setSelect();
init();

function setSelect(){
	// Domain List
	var lang = Common.getSession("lang");
	coviCtrl.renderDomainAXSelect('DomainID', lang, null, null);
	
	// Datasource list
	$("#DatasourceSeq").coviCtrl("setSelectOption", "/covicore/dbsync/getDatasourceSelectData.do");
	$("#DatasourceSeq,#UseYn").bindSelect();// style.
}
function init(){
	if(mode == "modify"){
		$("#btn_create").hide();
		$("#btn_modify").show();
		setTargetData();
	}else{
		$("#btn_create").show();
		$("#btn_modify").hide();
	}
}

//정보 조회
function setTargetData(){
	$.ajax({
		type:"POST",
		data:{
			"TargetSeq" : TargetSeq
		},
		url:"/covicore/dbsync/getTargetInfo.do",
		success:function (data) {
			if(data.status =='SUCCESS'){
				for(key in data.info){
					var $obj = $("#" + key);
					if($obj.length == 0) continue;
					
					if($obj[0].tagName.toLowerCase() == "span"){
						$obj.html(data.info[key]);
					}else if($obj[0].tagName.toLowerCase() == "textarea"){
						$obj.val(data.info[key]);
					}else if($obj[0].tagName.toLowerCase() == "select"){
						// $obj.val(data.info[key]);
						$obj.bindSelectSetValue(data.info[key]);
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
    		}else{
    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
    		}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/covicore/dbsync/getTargetInfo.do", response, status, error);
		}
	});
	
}

//추가
function addTarget(){
	if(validationChk()){
		$.ajax({
			type:"POST",
			data:$("#form_ExtDbSyncTargetPop").serialize(),
			url:"/covicore/dbsync/addTarget.do",
			success:function (data) {
				if(data.status=='SUCCESS'){
		    		parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
						parent.dbSyncTargetGrid.reloadList();	    			
		    			Common.Close();
		    		});
	    		}else{
	    			parent.Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/dbsync/addTarget.do", response, status, error);
			}
		});
	}
}

//수정
function modifyTarget(){
	if(validationChk()){
		$.ajax({
			type:"POST",
			data:$("#form_ExtDbSyncTargetPop").serialize(),
			url:"/covicore/dbsync/editTarget.do",
			success:function (data) {
				if(data.status=='SUCCESS'){
		    		parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
						parent.dbSyncTargetGrid.reloadList();			
		    			Common.Close();
		    		});
	    		}else{
	    			parent.Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/dbsync/editTarget.do", response, status, error);
			}
		});
	}
	
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