<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var type = CFN_GetQueryString("type");
	var sKind = CFN_GetQueryString("kind");
	var targetID = CFN_GetQueryString("targetID");
	
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
    	
    	if(type == "E" || type == "R"){
    		parent._setPRecAValue(returnStr); // 유형별 수신결재자
    	}else{
    		parent._setNomalValue(targetID, returnStr); // 일반 수신결재자
    	}
    	
    	Common.Close();
    }

    function setData(){
        var openID = CFN_GetQueryString("openID");
        var scPRecAVal = $("#"+openID+"_if",parent.document).contents().find("input[name='" + targetID + "'][type='text']").val();
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
	<div id="divFormBasicInfo" class="sadmin_pop">
		<div style=""> 
			<div>
				<span style="float:right;margin-bottom:5px;">
					<a href="#" class="btnTypeDefault" onclick="addRow();" style="min-width:40px;">+</a>
					<a href="#" class="btnTypeDefault" onclick="removeRow();" style="min-width:40px;">-</a>
				</span>
				<div class="" style="height:270px;width:100%;overflow-y:auto;">
					<table id="tblList" class="sadmin_table sa_menuBasicSetting mb20">
						<tr style="height:35px;">
							<th style='text-align:center; width:100px;'><spring:message code='Cache.lbl_apv_separation' /></th><!--결재구분-->
							<th style='text-align:center; width:200px;'><spring:message code='Cache.lbl_apv_by' /></th><!--결재자-->
							<th style='text-align:center;'><spring:message code='Cache.lbl_selection' /></th>
							<th style="display:none;"><textarea rows="10" cols="10" id="tmpTextarea"></textarea></th>
						</tr>
						<tr class="firstRow" style="display:none;">
							<td style='text-align:center;'>
								<select name="SEL_APV_TYPE" class="selectType02">
									<option value="normal"><spring:message code='Cache.lbl_apv_by' /></option><!--결재자-->
									<option value="confirm"><spring:message code='Cache.lbl_apv_PApprConfirm' /></option><!--확인자-->
								</select>
							</td>
							<td style='text-align:center;'>
								<input name="TXT_APV_PERSON" type='text' style='' disabled="disabled" />
							</td>
							<td style='text-align:center;'>
								<a href="#" class="btnTypeDefault" id="btApvLine" name='btApvLine' onclick="setAutoApvLine(this);"><spring:message code='Cache.lbl_selection' /></a>
							</td>
						</tr>				
					</table>
				</div>
				<div class="bottomBtnWrap">
					<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveSubmit();" ><spring:message code="Cache.btn_apv_save"/></a>
					<a id="btn_delete" href="#" class="btnTypeDefault" onclick="deleteSubmit();" style="display:none"><spring:message code="Cache.btn_apv_delete"/></a>
					<a href="#" class="btnTypeDefault" onclick="closeLayer();" ><spring:message code="Cache.btn_apv_close"/></a>
				</div>
			</div> 
		</div>
		<span class="shadow shadow2"></span>
		<span class="shadow shadow3"></span>
		<span class="shadow shadow4"></span>
	</div>
</form>