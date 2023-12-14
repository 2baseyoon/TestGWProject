<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>

<form id="addDictionary" name="addDictionary">
	<div>
		<table class="AXFormTable" id="dic">
			<colgroup>
				<col width="90px"/>
				<col width="70%"/>
				<col width="80px"/>
				<col width="50%"/>
			</colgroup>
			<tr>
				<th><spring:message code='Cache.lbl_Section'/></th>
				<td>
					<select id="selDicSection" class="AXSelect"></select>
					<input type="text" id="txtDicSection" style="width:55px" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
				</td>
				
				<th><spring:message code='Cache.lbl_OwnedCompany'/></th>
				<td>
					<select id="selDomain"  class="AXSelect"></select>
				</td>
				
			</tr>
			<tr>
				<th><span><font color="red">* </font></span><spring:message code="Cache.lbl_DicID"/></th>
				<td>
					<input type="text" id="txtDicCode" style="width:90%" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
				</td>
				<th><spring:message code='Cache.lbl_IsUse'/></th>
				<td>
					<select id="selIsUse"  class="AXSelect"></select>
				</td>
			</tr>
			<tr style="height: 100px">
				<th><spring:message code='Cache.lbl_Description'/></th>
				<td colspan="3">
					<textarea rows="5" style="width: 90%" id="txtDesc" class="AXTextarea HtmlCheckXSS ScriptCheckXSS" style="resize:none"></textarea>
				</td>
			</tr>
		</table>
		<div align="center" style="padding-top: 10px">
			<input type="button" value="<spring:message code='Cache.btn_Add'/>" onclick="addSubmit(); return false;" class="AXButton red"/>
			<input type="button" id="btn_modify" value="<spring:message code='Cache.btn_Edit'/>" onclick="modifySubmit();" style="display: none" class="AXButton red"/>
			<input type="button" value="<spring:message code='Cache.btn_Close'/>" onclick="Common.Close(); return false;" class="AXButton"/>
		</div>
	</div>
</form>
<script>
    //# sourceURL=adddictionarylayerpopup.jsp
	var mode = CFN_GetQueryString("mode");
	var key = CFN_GetQueryString("key");
	var langCode = Common.getSession("lang");
	//ready
	initContent();
	
	function initContent(){ 
		setSelect();
		if(mode=="modify"){
			$("#btn_modify").show();
			getDictionaryInfo();
		}
		
	};
	function setSelect(){
	    
	    var objallowedLang = 'ko,en,ja,zh';
		var objLanguageCode = Common.getBaseCode("LanguageCode");
		$(objLanguageCode.CacheData).each(function(idx, obj) {
			if (obj.Code == 'LanguageCode'){
				//코드그룹명 제외
		    }else{
				if(objallowedLang.indexOf(obj.Code) == -1){
				    objallowedLang +="," + obj.Code;
				}
			}
		}); 
	    
		coviDic.renderInclude('dic', {
			lang : langCode,
			hasTransBtn : 'true',
			allowedLang : objallowedLang,
			dicCallback : '',
			popupTargetID : '',
			init : ''
		});
		$("#dic").find(".AXFormTable").css("box-shadow", "none");
		$("#dic").find(".AXFormTable tbody td").css("border-right", "0px !important");
		$("#dic").find(".AXFormTable tbody th:last").css("border-bottom", "0px");
		
   		coviCtrl.renderAXSelect('DicSection','selDicSection', langCode, 'setDicSection', '', 'DicSection' );
   		coviCtrl.renderDomainAXSelect('selDomain', langCode, null, null);
   		$("#selIsUse").bindSelect({ //검색 조건
			options: [{'optionValue':'Y','optionText':"<spring:message code='Cache.lbl_USE_Y'/>"},{'optionValue':'N','optionText':"<spring:message code='Cache.lbl_USE_N'/>"}]
		});
   		
	}
	
	function setDicSection(){
		var selected = $('#selDicSection').val();
		if(selected != "DicSection"){
			$('#txtDicSection').val(selected);
			$('#txtDicCode').val(""+selected+"_");
		}
	}
	function getDictionaryInfo(){
		$.ajax({
			type:"POST",
			data:{
				"dicID" : CFN_GetQueryString("key")
			},
			url:"/covicore/dic/get.do",
			async:false,
			success:function (data) {
				if(data.result == "ok"){
					$("#selDicSection").bindSelectSetValue(data.list[0].DicSection); 
					$("#selDomain").bindSelectSetValue(data.list[0].DomainID); 
					$("#selIsUse").bindSelectSetValue(data.list[0].IsUse); 
	 				$("#txtDicSection").val(data.list[0].DicSection);
	 				$("#txtDicCode").val(data.list[0].DicCode);
	 				$("#ko_full").val(data.list[0].KoFull);
	 				$("#en_full").val(data.list[0].EnFull);
	 				$("#ja_full").val(data.list[0].JaFull);
	 				$("#zh_full").val(data.list[0].ZhFull);
	 				$("#txtDesc").val(data.list[0].Description);
				}
			},
			error:function(response, status, error){
	       	     CFN_ErrorAjax("/covicore/dic/get.do", response, status, error);
	       	}
		});
	}
	
	function addSubmit(){
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		if($('#selDicSection').val() == ""){
			parent.Common.Warning("<spring:message code='Cache.msg_EnterTheRequiredValue'/>".replace("{0}","<spring:message code='Cache.lbl_Section'/>")); ; //[{0}] 필수 입력값 입니다. , 영역
			return false;
		}
		
		if($("#txtDicCode").val() == ""){
			parent.Common.Warning("<spring:message code='Cache.msg_EnterTheRequiredValue'/>".replace("{0}","<spring:message code='Cache.lbl_DicID'/>")); //[{0}] 필수 입력값 입니다. , 다국어키
			return false;
		}
		
		if($('#selIsUse').val() == "" || $('#selIsUse').val() == null){
			$("#selIsUse").val("Y");
		}
		
		$.ajax({
			url:"/covicore/dic/add.do",
			type:"post",
			data:{
				"dicSection" :  $('#selDicSection').val(),
				"domainID" :  $('#selDomain').val(),
				"dicCode" : $("#txtDicCode").val(),
				"isUse" :   $('#selIsUse').val(),
				"koShort" : $("#ko_full").val(),
				"koFull" : $("#ko_full").val(),
				"enShort" : $("#en_full").val(),
				"enFull" : $("#en_full").val(),
				"jaShort" : $("#ja_full").val(),
				"jaFull" : $("#ja_full").val(),
				"zhShort" : $("#zh_full").val(),
				"zhFull" : $("#zh_full").val(),
				"description" : $("#txtDesc").val()
			},
			success:function (data){
				if(data.result == "ok"){
					parent.Common.Inform("<spring:message code='Cache.msg_Added'/>"); //추가 되었습니다.
					Common.Close();
					parent.Refresh();
				}
			},
			error:function(response, status, error){
       	     CFN_ErrorAjax("/covicore/dic/add.do", response, status, error);
       		}
		});
	}
	
	function modifySubmit(){
		if(!chkValidation()){
			return;
		}
		
		$.ajax({
			url:"/covicore/dic/modify.do",
			type:"post",
			data:{
				"dicID" : key,
				"dicSection" :  $('#selDicSection').val(),
				"domainID" :  $('#selDomain').val(),
				"dicCode" : $("#txtDicCode").val(),
				"isUse" :   $('#selIsUse').val(),
				"koShort" : $("#ko_full").val(),
				"koFull" : $("#ko_full").val(),
				"enShort" : $("#en_full").val(),
				"enFull" : $("#en_full").val(),
				"jaShort" : $("#ja_full").val(),
				"jaFull" : $("#ja_full").val(),
				"zhShort" : $("#zh_full").val(),
				"zhFull" : $("#zh_full").val(),
				"description" : $("#txtDesc").val()
			},
			success:function (data){
				if(data.result == "ok"){
					parent.Common.Inform("<spring:message code='Cache.msg_ChangeAlert'/>"); //수정되었습니다.
					Common.Close();
					parent.Refresh();
				}
			},
			error:function(response, status, error){
	       	     CFN_ErrorAjax("/covicore/dic/modify.do", response, status, error);
	       	}
		});
	}

	
	function chkValidation(){
		if( $('#selDicSection').val() == ""){
			parent.Common.Warning("<spring:message code='Cache.msg_EnterTheRequiredValue'/>".replace("{0}","<spring:message code='Cache.lbl_Section'/>")); ; //[{0}] 필수 입력값 입니다. , 영역
			return false;
		}else	if($("#txtDicCode").val() == ""){
			parent.Common.Warning("<spring:message code='Cache.msg_EnterTheRequiredValue'/>".replace("{0}","<spring:message code='Cache.lbl_DicID'/>")); //[{0}] 필수 입력값 입니다. , 다국어키
			$("#txtDicCode").focus();
			return false;
		}else{
			return true;
		}
		
	}
	
	
	function bingtranslate(pObj){
		var text = "";
		var src_lang = "ko";
		
		//영어 텍스트가 있을시 영어, 아니면 한글을 통해 번역 시도
		if($("#en").val() != "" && $("#ko").val() == ""){
			text = $("#en").val();
			src_lang = "en";
		} else if ($("#ko").val() != ""){
			text = $("#ko").val();
			src_lang = "ko";
		}
		
		$.ajax({
			url:"translate.do",
			data:{
				"text":text,
				"src_lang":src_lang,
				"dest_lang":$(pObj).attr("lang")
			},
			type:"post",
			success:function (data) {
				if(data.result == "ok"){
					$("#" + $(pObj).attr("lang")).val(data.text);	
				}
			},
			error:function(response, status, error){
	       	     CFN_ErrorAjax("/covicore/dic/translate.do", response, status, error);
	       	}
		});
	}
</script>
<style type="text/css">
	input[type=text]{
		height:inherit
	}
</style>
