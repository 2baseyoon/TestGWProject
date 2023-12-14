<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<script type="text/javascript">
	var callbackFunc = CFN_GetQueryString("callback");
 	var lang = Common.getSession("lang");
	
	var sFieldName ="";
	function setDictionary(fieldName){
		sFieldName = fieldName;
		
		
		var option = {
				lang : lang,
				popupTargetID: 'setDictionary',
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh,lang1',
				useShort : 'false',
				dicCallback : 'callbackSetDictionary',
				init: 'initDictionary',
				openerID: "addAttribute"
		};
		
		var url = "";
		url += "/covicore/control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&popupTargetID=" + option.popupTargetID;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		url += "&init=" +  option.init;
		url += "&openerID=" +  option.openerID;
		
		parent.Common.open("","setDictionary","<spring:message code='Cache.lbl_MultiLangSet'/>|||<spring:message code='Cache.msg_MultilanguageSettings'/>",url,"400px","300px","iframe",true,null,null,true);
	}
	
	function initDictionary(){
		if(sFieldName==''){
			return "";
		}
		return $("#hid"+sFieldName).val()==''? $("#txt"+sFieldName).val() : $("#hid"+sFieldName).val()
	}

	function callbackSetDictionary(value){
		value = coviDic.convertDic(JSON.parse(value));
		
		if(sFieldName!=''){
			$("#txt"+sFieldName).val(CFN_GetDicInfo(value,lang) );
			$("#hid"+sFieldName).val(value);
		}
		sFieldName = ''; 
	}
	
	
	function returnAttribute(){
		if(chkValidation()){
			
			var sTitle = $("#txtAttributeName").val();
			var sValue = $("#txtAttributeValue").val();
			var sExTitle =  $("#hidAttributeName").val();
			var sExValue = $("#hidAttributeValue").val();
			
			if (sExTitle == "") {
                 switch (lang.toUpperCase()) {
                     case "KO": sExTitle = sTitle + ";;;;;;;;;"; break;
                     case "EN": sExTitle = ";" + sTitle + ";;;;;;;;"; break;
                     case "JA": sExTitle = ";;" + sTitle + ";;;;;;;"; break;
                     case "ZH": sExTitle = ";;;" + sTitle + ";;;;;;"; break;
                     case "E1": sExTitle = ";;;;" + sTitle + ";;;;;"; break;
                     case "E2": sExTitle = ";;;;;" + sTitle + ";;;;"; break;
                     case "E3": sExTitle = ";;;;;;" + sTitle + ";;;"; break;
                     case "E4": sExTitle = ";;;;;;;" + sTitle + ";;"; break;
                     case "E5": sExTitle = ";;;;;;;;" + sTitle + ";"; break;
                     case "E6": sExTitle = ";;;;;;;;;" + sTitle; break;
                     default : sExTitle = sTitle+ ";;;;;;;;;"; break;
                 }
             }

             if (sExValue == "") {
                 switch (lang.toUpperCase()) {
                     case "KO": sExValue = sValue + ";;;;;;;;;"; break;
                     case "EN": sExValue = ";" + sValue + ";;;;;;;;"; break;
                     case "JA": sExValue = ";;" + sValue + ";;;;;;;"; break;
                     case "ZH": sExValue = ";;;" + sValue + ";;;;;;"; break;
                     case "E1": sExValue = ";;;;" + sValue + ";;;;;"; break;
                     case "E2": sExValue = ";;;;;" + sValue + ";;;;"; break;
                     case "E3": sExValue = ";;;;;;" + sValue + ";;;"; break;
                     case "E4": sExValue = ";;;;;;;" + sValue + ";;"; break;
                     case "E5": sExValue = ";;;;;;;;" + sValue + ";"; break;
                     case "E6": sExValue = ";;;;;;;;;" + sValue; break;
                     default : sExValue = sValue+ ";;;;;;;;;"; break;
                 }
             }
			
			
			var retVal = {
					"Title": sTitle,
					"ExTitle" : sExTitle,
					"Value": sValue,
					"ExValue": sExValue
			};
	 		
			XFN_CallBackMethod_Call("divResourceInfo",callbackFunc, JSON.stringify(retVal));
	 		parent.Common.close('addAttribute');
			
		}
	}
	
	function chkValidation(){
		    if ( $("#txtAttributeName").val() == "") {
		        parent.Common.Warning("<spring:message code='Cache.msg_Common_12'/>", "Warning Dialog", function () {
		        	 $("#txtAttributeName").focus();
		        });
		        return false;
		    }else if ($("#txtAttributeValue").val() == "") {
		    	 parent.Common.Warning("<spring:message code='Cache.msg_ResourceManage_11'/>", "Warning Dialog", function () {
		        	$("#txtAttributeValue").focus();
		        });
		        return false;
		    }else{
			    return true;
		    }
	}
	
	
	
</script>
<form id="form1">
    <div class="sadmin_pop">
    	 <table class="sadmin_table">
    	 	<colgroup>
    	 		<col width="100px;"/>
    	 		<col/>
    	 	</colgroup>
    	 	<tbody>
    	 		<tr> 
    	 			<th><spring:message code='Cache.lbl_subject'/></th><!--제목-->
    	 			<td>
	    	 			<input type="text"  id="txtAttributeName" style="width: 70%;"/>&nbsp;
	    	 			<input type="hidden" id="hidAttributeName"  value=""/>
	    	 			<input type="button" class="AXButton"  value="<spring:message code='Cache.lbl_MultiLang2'/>"  onclick="setDictionary('AttributeName')"/>
    	 			</td>
    	 		</tr>
    	 		<tr>
    	 			<th><spring:message code='Cache.lbl_DisplayValue'/></th><!--표시값 -->
    	 			<td>
    	 				<input type="text"  id="txtAttributeValue" style="width: 70%;"/>&nbsp;
	    	 			<input type="hidden" id="hidAttributeValue"  value=""/>
	    	 			<input type="button" class="AXButton"  value="<spring:message code='Cache.lbl_MultiLang2'/>"  onclick="setDictionary('AttributeValue')"/>
    	 			</td>
    	 		</tr>
    	 	</tbody>
    	 </table>
		<div class="bottomBtnWrap">
			<a class="btnTypeDefault btnTypeBg" onclick="returnAttribute()"><spring:message code='Cache.btn_apv_save'/></a><!-- 저장 -->
			<a class="btnTypeDefault"  onclick="Common.Close()"><spring:message code='Cache.Cache.Cache.btn_Close'/></a><!-- 닫기 -->
		</div>
	</div>
</form>