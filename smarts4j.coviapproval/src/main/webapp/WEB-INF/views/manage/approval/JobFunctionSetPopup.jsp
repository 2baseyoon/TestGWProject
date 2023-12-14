<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode = CFN_GetQueryString("mode")=="undefined"? "" : CFN_GetQueryString("mode")
	var paramJobFunctionID =  CFN_GetQueryString("configkey")=="undefined"? "" : CFN_GetQueryString("configkey")
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가
	var lang = Common.getSession("lang");
	
	$(document).ready(function(){		
		selSelectbind();
		if(mode=="modify"){
			$("#btn_delete").show();
			modifySetData();
			$("#JobFunctionCode").attr("disabled",true);
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
				"JobFunctionID" : paramJobFunctionID				
			},
			url:"getJobFunctionData.do",
			success:function (data) {					
				if(Object.keys(data.list[0]).length > 0){					
					$("#EntCode").bindSelectSetValue(data.list[0].EntCode);
					$("#hidJobFunctionName").val(data.list[0].JobFunctionName);
					$("#JobFunctionName").val(CFN_GetDicInfo(data.list[0].JobFunctionName));				
					$("#JobFunctionCode").val(data.list[0].JobFunctionCode);		
					$("#JobFunctionType").bindSelectSetValue(data.list[0].JobFunctionType);
					$("#Description").val(data.list[0].Description);				
					$("#SortKey").val(data.list[0].SortKey);
					$("#IsUse").bindSelectSetValue(data.list[0].IsUse);
					$("#InsertDate").val(data.list[0].InsertDate);
				}
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getJobFunctionData.do", response, status, error);
			}
		});
	}
	

	
	//저장
	function saveSubmit(){
		//data셋팅	
		var EntCode			= $("#EntCode").val();
		var JobFunctionName = $("#hidJobFunctionName").val();				
		var JobFunctionCode	= $("#JobFunctionCode").val();				
		var JobFunctionType	= $("#JobFunctionType").val();		
		var Description		= $("#Description").val();				
		var SortKey			= $("#SortKey").val();
		var IsUse		    = $("#IsUse").val();
		var InsertDate		= $("#InsertDate").val();

		if (axf.isEmpty(JobFunctionName)) {
            Common.Warning("<spring:message code='Cache.msg_apv_ValidationBizDocName' />");//업무함 명칭을 입력하세요
            return false;
        }
		/*if (axf.isEmpty(JobFunctionCode)) {
            Common.Warning("<spring:message code='Cache.msg_apv_ValidationChargeCode' />");//담당자 코드를 입력하세요
            return false;
        }*/
		if (axf.isEmpty(SortKey)) {
            Common.Warning("<spring:message code='Cache.msg_apv_141' />");//정렬값은 숫자로 입력하십시오.
            return false;
        }
			
		var urlSubmit;
		if(mode == 'add'){
			urlSubmit = 'insertJobFunction.do';
		}else{
			urlSubmit = 'updateJobFunction.do';
		}
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{
				"EntCode"		  : EntCode,
				"JobFunctionID"   : paramJobFunctionID,
				"JobFunctionName" : JobFunctionName,
				"JobFunctionCode" : JobFunctionCode,
				"JobFunctionType" : JobFunctionType,
				"Description"     : Description,
				"SortKey"         : SortKey,
				"IsUse"           : IsUse,
				"InsertDate"      : InsertDate				
			},
			url:urlSubmit,
			success:function (data) {
				if (mode == 'add' && data.object == 0){
					Common.Inform("<spring:message code='Cache._msg_CodeDuplicate' />"); // 코드가 중복되었습니다. 
				}else if(data.result == "ok"){
					parent.Common.Inform("<spring:message code='Cache.msg_apv_117' />"); // 성공적으로 저장하였습니다.
					closeLayer();
					parent.searchConfig();
				} else {
					parent.Common.Error(data.message);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax(urlSubmit, response, status, error);
			}
		});
	}
	
	
	//삭제
	function deleteSubmit(){
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				var JobFunctionID = paramJobFunctionID;
				
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"JobFunctionID" : JobFunctionID
					},
					url:"deleteJobFunction.do",
					success:function (data) {
						if(data.result == "ok")
							parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />"); // 성공적으로 삭제되었습니다.
						closeLayer();
						parent.searchConfig();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteJobFunction.do", response, status, error);
					}
				});
			}
		});
	}
		
	//axisj selectbox변환
	function selSelectbind(){
		//검색selectbind
		coviCtrl.renderAjaxSelect([{target: "JobFunctionType",codeGroup: "JobFunctionType"}], '', lang);
		$("#JobFunctionType").val("APPROVAL"); // default
		coviCtrl.renderDomainAXSelect('EntCode', lang, null, null, Common.getSession("DN_Code"), false, {codeType: "CODE"});
	}

	// 기본설정 - 다국어 레이어팝업
	function dictionaryLayerPopup() {
		var option = {
				lang : 'ko',
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh',
				useShort : 'false',
				dicCallback : 'addMenuDicCallback',
				popupTargetID : 'DictionaryPopup',
				init : 'initDicPopup',
				styleType : "U"
		};
		
		var url = "";
		url += "/covicore/control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		url += "&popupTargetID=" + option.popupTargetID;
		url += "&init=" + option.init;
		url += "&styleType=" + option.styleType;
		
		//CFN_OpenWindow(url,"다국어 지정",500,300,"");
		Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultilanguageSettings'/>", url, "500px", "250px", "iframe", true, null, null, true);
	}

	function initDicPopup(){
		return $('#hidJobFunctionName').val();
	}
	
	function addMenuDicCallback(data){
		$('#JobFunctionName').val(data.KoFull);
		$('#hidJobFunctionName').val(coviDic.convertDic(data))
		Common.close("DictionaryPopup");
	}
</script>
<div class="sadmin_pop">		 		
	<table class="sadmin_table sa_menuBasicSetting" >
		<colgroup>
			<col width="120px">
			<col width="*">
		</colgroup>
		<tbody>
	    <tr <covi:admin hiddenWhenEasyAdmin="true"/>>
	      	<th><spring:message code="Cache.lbl_Domain"/></th>
		  	<td>
				<select id="EntCode" name="EntCode" class="selectType02 w190p">
				</select>
		  	</td>
	    </tr>
	    <tr>
	      	<th><spring:message code="Cache.lbl_apv_BizDocName"/></th>
		  	<td>
		  		<input id="JobFunctionName" name="JobFunctionName" type="text" class="menuName04" readonly="readonly" maxlength="64" /><a 
		  			class="btnTypeDefault" onclick="dictionaryLayerPopup();" ><spring:message code='Cache.lbl__DicModify'/></a>
		  	</td>
	    </tr>
	    <tr <covi:admin hiddenWhenEasyAdmin="true"/>>
	      	<th><spring:message code="Cache.lbl_apv_BizDocCode"/></th>
		  	<td><input id="JobFunctionCode" name="JobFunctionCode" type="text" class="w100"  maxlength="64" /></td>
	    </tr>
		<tr <covi:admin hiddenWhenEasyAdmin="true"/>>
	      	<th><spring:message code="Cache.lbl_BizSection"/></th>
            <td>
				<select id="JobFunctionType" name="JobFunctionType" class="selectType02 w190p">
				</select>
            </td>
	    </tr>
		<tr>
	      	<th><spring:message code="Cache.lbl_apv_desc"/></th>
		  	<td><textarea id="Description" name="Description" maxlength="512" style="resize:none"></textarea></td>
	    </tr>
		<tr>
	      	<th><spring:message code="Cache.lbl_apv_Sort"/></th>
		  	<td><input mode="numberint" num_max="32767" class="w100" id="SortKey" name="SortKey" type="text" maxlength="16" /></td>
	    </tr>
		<tr>
	    	<th><spring:message code="Cache.lbl_apv_IsUse"/></th>
            <td>
                   <select id="IsUse" name="IsUse" class="selectType02 w190p">
					<option value="Y" selected><spring:message code="Cache.lbl_apv_jfform_07"/></option>
					<option value="N"><spring:message code="Cache.lbl_apv_jfform_08"/></option>
				</select>
        	</td>
	    </tr>
		<tr>
	      <th><spring:message code="Cache.lbl_apv_formcreate_LCODE15"/></th>
		  <td><input id="InsertDate" name="InsertDate" type="text" class="w100"  readonly="readonly" /></td>
	    </tr>
    	</tbody>
	</table>
	<div class="bottomBtnWrap">
		<a onclick="saveSubmit();" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_apv_save'/></a>
		<a id="btn_delete" onclick="deleteSubmit();" style="display: none"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_delete'/></a>
		<a onclick="closeLayer();" class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>
	</div>
</div>
<input type="hidden" id="hidJobFunctionName" value="">
<input type="hidden" id="SeqHiddenValue" value="" />
<input type="hidden" id="EntCode" value="" />