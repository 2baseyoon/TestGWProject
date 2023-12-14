<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramBizDocID =  param[1].split('=')[1];
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가

	$(document).ready(function(){	
		selSelectbind();
		if(mode=="modify"){
			$("#btn_delete").show();
			modifySetData();
			$("#BizDocCode").attr("disabled",true);
			//$("#SeqHiddenValue").val(key);					
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
					$("#IsUse").bindSelectSetValue(data.list[0].IsUse);
					$("#BizDocType").bindSelectSetValue(data.list[0].BizDocType);
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
		if (axf.isEmpty(BizDocCode)) {
			parent.Common.Warning("<spring:message code='Cache.msg_apv_ValidationBizDocCode' />");	//업무함 코드를 입력하세요.
            return false;
        }
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
					Common.Inform("<spring:message code='Cache._msg_CodeDuplicate' />");
				}else if(data.result == "ok"){
					parent.Common.Inform("<spring:message code='Cache.msg_apv_117' />");
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
							Common.Inform("<spring:message code='Cache.msg_apv_138' />");
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
		$("#IsUse").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		coviCtrl.renderAXSelect('JobFunctionType', 'BizDocType', 'ko', '', '', '');
		coviCtrl.renderCompanyAXSelect("EntCode",'ko',false,"","",'');
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
				init : 'initDicPopup'
		};
		
		var url = "";
		url += "/covicore/control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		url += "&popupTargetID=" + option.popupTargetID;
		url += "&init=" + option.init;
		
		//CFN_OpenWindow(url,"다국어 지정",500,300,"");
		Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultilanguageSettings'/>", url, "500px", "250px", "iframe", true, null, null, true);
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
<form id="BizDocListSetPopup" name="BizDocListSetPopup">
	<div>		 		
		<table class="AXFormTable" >
		  <colgroup>
			<col id="t_tit4">
			<col id="">
		  </colgroup>
		  <tbody>
		    <tr>
		      <th  style="width: 85px ;"><spring:message code="Cache.lbl_Domain"/></th>
			  <td>
				<select id="EntCode" name="EntCode" >
				</select>
			  </td>
		    </tr>
		    <tr>
		      <th style="width: 85px ;"><spring:message code='Cache.lbl_apv_BizDocName'/></th>
			  <td>
		  		<input id="BizDocName" name="BizDocName" type="text" class="AXInput" maxlength="64" readonly="readonly" style="width:289px;"/>
  			  	<input type="button" value="<spring:message code='Cache.lbl__DicModify'/>" class="AXButton" onclick="dictionaryLayerPopup();" />
			  </td>
		    </tr>
		    <tr>
		      <th style="width: 85px ;"><spring:message code='Cache.lbl_apv_BizDocCode'/></th>
			  <td><input id="BizDocCode" name="BizDocCode" type="text" class="AXInput" maxlength="64" style="width:350px;"/></td>
		    </tr>
			<tr>
		      <th style="width: 85px ;"><spring:message code="Cache.lbl_apv_ChargerType"/></th>
                <td>
                    <select id="BizDocType" name="BizDocType" class="AXSelect">
					</select>
                </td>
		    </tr>
			<tr>
		      <th style="width: 85px ;"><spring:message code='Cache.lbl_apv_desc'/></th>
			  <td><textarea id="Description" name="Description" maxlength="512" class="AXTextarea" style="width:340px; height:50px; overflow:scroll; overflow-x:hidden; resize:none;"></textarea></td>
		    </tr>
			<tr>
		      <th style="width: 85px ;"><spring:message code='Cache.lbl_apv_Sort'/></th>
			  <td><input mode="numberint"  num_max="32767" class="AXInput"   id="SortKey" name="SortKey" type="text" maxlength="16" style="width:350px;"/></td>
		    </tr>
			<tr>
		      <th style="width: 85px ;"><spring:message code='Cache.lbl_apv_IsUse'/></th>
                <td>
                    <select id="IsUse" name="IsUse" >
						<option value="Y" selected><spring:message code='Cache.lbl_apv_jfform_07'/></option>
						<option value="N"><spring:message code='Cache.lbl_apv_jfform_08'/></option>
					</select>
                </td>
		    </tr>
			<tr>
		      <th style="width: 85px ;"><spring:message code='Cache.lbl_apv_formcreate_LCODE15'/></th>
			  <td><input id="InsertDate" name="InsertDate" type="text" class="AXInput"  readonly="readonly" style="width:350px;"></td>
		    </tr>
	      </tbody>
          
		</table>
		<div align="center" style="padding-top: 10px">
			<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveSubmit();" class="AXButton red" />
			<input type="button" id="btn_delete" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="deleteSubmit();" style="display: none"  class="AXButton" />
			<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
	<input type="hidden" id="hidBizDocName" value="">
	<input type="hidden" id="SeqHiddenValue" value="" />
</form>