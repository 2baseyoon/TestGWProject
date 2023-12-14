<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var type = param[0].split('=')[1];	
 	$(document).ready(function(){
 		setData();
	});
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	var objTxtSelect = null;
	function setAutoApvLine(szObject) { 
		objTxtSelect = $(szObject).closest("tr").find("[name='TXT_APV_PERSON']");		
    	parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=formARASBack&type=B1","1060px","580px","iframe",true,null,null,true);    	
    }
    
	//조직도선택후처리관련
	var peopleObj = {};
	parent.formARASBack = setMGRDEPTLIST;
	function setMGRDEPTLIST(peopleValue){		
		var dataObj = $.parseJSON(peopleValue);	
		if(dataObj.item.length > 0){
		    $(objTxtSelect).val(peopleValue);	
		}			
	}
	
    function removeRow() {
    	if ($("#tblList tr:last").hasClass('firstRow')) {
    		Common.Warning("<spring:message code='Cache.msg_apv_270' />");		//삭제할 대상이 없습니다.
    	} else {
    		$("#tblList tr:last").remove();
    	}

    }

    function addRow(type, item) { 
    	var type = type || "normal";
    	var item = item || "";
    	var newTr = $("#tblList").find(".firstRow").clone(); 
    	$(newTr).removeClass('firstRow');
    	$(newTr).find("[name='SEL_APV_TYPE']").val(type);
    	$(newTr).find("[name='TXT_APV_PERSON']").val(item);
    	$(newTr).show();
    	$("#tblList tr:last").after(newTr);  
    }

    function saveSubmit(){
    	var tblListArray = new Array();		
    	$("#tblList tr:not(:first)").each(function(i){
		var tblListObj = new Object();				
		var tblListObjItem = $(this).find("[name='TXT_APV_PERSON']").val();
		if(tblListObjItem){
			tblListObj.item = jQuery.parseJSON(tblListObjItem);
			tblListObj.type = $(this).find("[name='SEL_APV_TYPE']").val();
			tblListArray.push(tblListObj);
		}	
		});	
		var returnStr = "";
    	if(tblListArray.length > 0){
	    	var tblListObj = new Object();
	    	tblListObj.autoApv = tblListArray;
	    	returnStr = JSON.stringify(tblListObj);
    	}
    	parent._setNomalValue(type, returnStr);
    	Common.Close();
    }

    function setData(){
        var openID = CFN_GetQueryString("openID");
        var scPRecAVal = $("#"+openID+"_if",parent.document).contents().find("input[name='scPRecA'][type='text']").val();
        if(scPRecAVal){
            var autoApvJson = JSON.parse(scPRecAVal);
            $(autoApvJson.autoApv).each(function(idx, item){
                var typeVal = $(item).attr("type");
                var itemVal = JSON.stringify($(item).attr("item"));
                addRow(typeVal, itemVal);
            });
        } else {
        	addRow();
        }
    }
</script>
<form id="FormAutoRecApvSet" name="FormAutoRecApvSet">
	<div id="divFormBasicInfo">
		<div style="padding-bottom:10px; padding-left:10px; padding-right:10px; padding-top:10px;"> 
			<div>
				<div class="t_back" style="margin-right:0px; height:330px">
					<span style="float:right;margin-bottom:5px;">
						<input type="button" class="AXButton" onclick="addRow();" value="+" />
						<input type="button" class="AXButton" onclick="removeRow();" value="-" />
					</span>
					<table id="tblList" class="AXFormTable" cellpadding="0" cellspacing="0">
						<tr>
							<th style='text-align:center; width:100px;'><spring:message code='Cache.lbl_apv_separation' /></th><!--결재구분-->
							<th style='text-align:center; width:200px;'><spring:message code='Cache.lbl_apv_by' /></th><!--결재자-->
							<th style='text-align:center;'><spring:message code='Cache.lbl_selection' /></th>
							<th style="display:none;"><textarea rows="10" cols="10" id="tmpTextarea"></textarea></th>
						</tr>
						<tr class="firstRow" style="display:none;">
							<td style='text-align:center;'>
								<select name="SEL_APV_TYPE">
									<option value="normal"><spring:message code='Cache.lbl_apv_by' /></option><!--결재자-->
									<option value="confirm"><spring:message code='Cache.lbl_apv_PApprConfirm' /></option><!--확인자-->
								</select>
							</td>
							<td style='text-align:center;'>
								<input name="TXT_APV_PERSON" type='text' style='width:200px;' disabled="disabled" />
							</td>
							<td style='text-align:center;'>
								<input type="button" id="btApvLine" name='btApvLine' class="AXButton" onclick="setAutoApvLine(this);" value="<spring:message code='Cache.lbl_selection' />">
							</td>
						</tr>				
					</table>
				</div>
				<div align="center" style="padding-top: 10px">
					<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveSubmit();" class="AXButton" />
					<input type="button" id="btn_delete" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="deleteSubmit();" style="display: none"  class="AXButton" />
					<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="closeLayer();"  class="AXButton" />
				</div>
			</div> 
		</div>
		<span class="shadow shadow2"></span>
		<span class="shadow shadow3"></span>
		<span class="shadow shadow4"></span>
	</div>
</form>