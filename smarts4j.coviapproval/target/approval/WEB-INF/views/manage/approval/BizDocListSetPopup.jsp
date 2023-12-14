<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramBizDocID =  param[1].split('=')[1];
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가
	var lang = Common.getSession("lang");
	
	$(document).ready(function(){	
		selSelectbind();
		if(mode=="modify"){
			$("#btn_delete").show();
			modifySetData();
			$("#BizDocCode").attr("disabled",true);
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
				"BizDocID" : paramBizDocID				
			},
			url:"getBizDocData.do",
			success:function (data) {					
				if(Object.keys(data.list[0]).length > 0){
					$("#EntCode").bindSelectSetValue(data.list[0].EntCode)
					$("#hidBizDocName").val(data.list[0].BizDocName);	
					$("#BizDocName").val(CFN_GetDicInfo(data.list[0].BizDocName));				
					$("#BizDocCode").val(data.list[0].BizDocCode);				
					$("#Description").val(data.list[0].Description);				
					$("#SortKey").val(data.list[0].SortKey);
					$("#IsUse").val(data.list[0].IsUse);
					$("#BizDocType").val(data.list[0].BizDocType);
					$("#InsertDate").val(data.list[0].InsertDate);
				}
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getBizDocData.do", response, status, error);
			}
		});
	}
	

	
	//저장
	function saveSubmit(){
		//data셋팅	
		var EntCode = $("#EntCode").val();	
		var BizDocCode = $("#BizDocCode").val();				
		var BizDocName = $("#hidBizDocName").val();
		var BizDocType = $("#BizDocType").val();		
		var Description = $("#Description").val();		
		var SortKey = $("#SortKey").val();		
		var IsUse = $("#IsUse").val();
		
		if (axf.isEmpty(BizDocName)) {
			parent.Common.Warning("<spring:message code='Cache.msg_apv_ValidationBizDocName' />");	//업무함 명칭을 입력하세요
            return false;
        }
		/* 코드사용처 없음 "BIZDOC_{name}" 고정
		if (axf.isEmpty(BizDocCode)) {
			parent.Common.Warning("<spring:message code='Cache.msg_apv_ValidationBizDocCode' />");	//업무함 코드를 입력하세요.
            return false;
        }*/
		if (axf.isEmpty(SortKey)) {
			parent.Common.Warning("<spring:message code='Cache.msg_apv_141' />");//정렬값은 숫자로 입력하십시오.
            return false;
        }
			
		var urlSubmit;
		if(mode == 'add'){
			urlSubmit = 'insertBizDoc.do';
		}else{
			urlSubmit = 'updateBizDoc.do';
		}
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{
				"BizDocID"		: paramBizDocID,
				"BizDocCode"	: BizDocCode,
				"BizDocName"	: BizDocName,
				"BizDocType"	: BizDocType,
 				"Description"	: Description,				
				"SortKey"		: SortKey,				
				"IsUse"			: IsUse,
				"EntCode"		: EntCode				
			},
			url:urlSubmit,
			success:function (data) {
				if (mode == 'add' && data.object == 0){
					Common.Inform("<spring:message code='Cache._msg_CodeDuplicate' />"); // 코드가 중복되었습니다. 
				}else if(data.result == "ok"){
					parent.Common.Inform("<spring:message code='Cache.msg_apv_117' />"); // 성공적으로 저장하였습니다.
					closeLayer();
					parent.searchConfig();
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax(urlSubmit, response, status, error);
			}
		});
	}
	
	
	//삭제
	function deleteSubmit(){
		parent.Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				var BizDocID = paramBizDocID;
					
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"BizDocID" : BizDocID
					},
					url:"deleteBizDoc.do",
					success:function (data) {
						if(data.result == "ok")
							Common.Inform("<spring:message code='Cache.msg_apv_138' />"); // 성공적으로 삭제되었습니다.
						closeLayer();
						parent.searchConfig();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteBizDoc.do", response, status, error);
					}
				});
			}
		});
	}
		
	//axisj selectbox변환
	function selSelectbind(){
		//검색selectbind
		coviCtrl.renderAjaxSelect([{target: "BizDocType",codeGroup: "JobFunctionType"}], '', lang);
		// initial : APPROVAL
		$("#BizDocType").val("APPROVAL");
		coviCtrl.renderDomainAXSelect('EntCode', lang, null, null, Common.getSession("DN_Code"), false, {codeType: "CODE"});
	}
	
	// 기본설정 - 다국어 레이어팝업
	function dictionaryLayerPopup() {
		var option = {
				lang : lang,
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh',
				useShort : 'false',
				dicCallback : 'addMenuDicCallback',
				popupTargetID : 'DictionaryPopup',
				init : 'initDicPopup',
				styleType : 'U'
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
		Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultilanguageSettings'/>", url, "500px", "270px", "iframe", true, null, null, true);
	}

	function initDicPopup(){
		return $('#hidBizDocName').val();
	}
	
	function addMenuDicCallback(data){
		$('#BizDocName').val(data.KoFull);
		$('#hidBizDocName').val(coviDic.convertDic(data))
		Common.close("DictionaryPopup");
	}
</script>
<div class="sadmin_pop">		 		
	<table class="sadmin_table sa_menuBasicSetting" >
	  <colgroup>
		<col width="130px">
		<col width="*">
	  </colgroup>
	  <tbody>
	    <tr <covi:admin hiddenWhenEasyAdmin="true"/>>
	      <th><spring:message code="Cache.lbl_Domain"/></th>
		  <td>
			<select id="EntCode" name="EntCode" class="selectType02 w190p" >
			</select>
		  </td>
	    </tr>
	    <tr>
	      <th><spring:message code='Cache.lbl_apv_BizDocName'/></th>
		  <td>
	  		<input id="BizDocName" name="BizDocName" type="text" class="menuName04" maxlength="64" readonly="readonly" /><a 
	  			class="btnTypeDefault" onclick="dictionaryLayerPopup();" ><spring:message code='Cache.lbl__DicModify'/></a>
		  </td>
	    </tr>
	    <tr style="display:none;">
	      <th><spring:message code='Cache.lbl_apv_BizDocCode'/></th>
		  <td><input id="BizDocCode" name="BizDocCode" type="text" class="w100" maxlength="64"/></td>
	    </tr>
		<tr <covi:admin hiddenWhenEasyAdmin="true"/>>
	      <th><spring:message code="Cache.lbl_apv_ChargerType"/></th>
               <td>
                   <select id="BizDocType" name="BizDocType" class="selectType02 w190p">
				</select>
               </td>
	    </tr>
		<tr>
	      <th><spring:message code='Cache.lbl_apv_desc'/></th>
		  <td><textarea id="Description" name="Description" maxlength="512" style="resize:none;"></textarea></td>
	    </tr>
		<tr>
	      <th><spring:message code='Cache.lbl_apv_Sort'/></th>
		  <td><input mode="numberint" num_max="32767" class="w100" id="SortKey" name="SortKey" type="text" maxlength="16" /></td>
	    </tr>
		<tr>
	      <th><spring:message code='Cache.lbl_apv_IsUse'/></th>
               <td>
                   <select id="IsUse" name="IsUse" class="selectType02 w190p">
					<option value="Y" selected><spring:message code='Cache.lbl_apv_jfform_07'/></option>
					<option value="N"><spring:message code='Cache.lbl_apv_jfform_08'/></option>
				</select>
               </td>
	    </tr>
		<tr>
	      <th><spring:message code='Cache.lbl_apv_formcreate_LCODE15'/></th>
		  <td><input id="InsertDate" name="InsertDate" type="text" class="w100"  readonly="readonly" style="width:350px;"></td>
	    </tr>
      </tbody>
         
	</table>
	<div class="bottomBtnWrap">
		<a onclick="saveSubmit();" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_apv_save'/></a>
		<a id="btn_delete" onclick="deleteSubmit();" style="display: none"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_delete'/></a>
		<a onclick="closeLayer();"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>
	</div>
</div>
<input type="hidden" id="hidBizDocName" value="">
<input type="hidden" id="SeqHiddenValue" value="" />