<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode = CFN_GetQueryString("mode")=="undefined"? "" : CFN_GetQueryString("mode")
	var paramJobFunctionID =  CFN_GetQueryString("configkey")=="undefined"? "" : CFN_GetQueryString("configkey")
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가

	$(document).ready(function(){		
		selSelectbind();
		if(mode=="modify"){
			$("#btn_delete").show();
			modifySetData();
			$("#JobFunctionCode").attr("disabled",true);
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
		if (axf.isEmpty(JobFunctionCode)) {
            Common.Warning("<spring:message code='Cache.msg_apv_ValidationBizDocCode' />");//업무함 코드를 입력하세요
            return false;
        }
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
					Common.Inform("<spring:message code='Cache._msg_CodeDuplicate' />");
				}else if(data.result == "ok"){
					parent.Common.Inform("<spring:message code='Cache.msg_apv_137' />");
					closeLayer();
					parent.setUseAuthority();
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
							parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />");
						closeLayer();
						parent.setUseAuthority();
						parent.$("#divMember").hide();
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
		$("#IsUse").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		
		coviCtrl.renderAXSelect('JobFunctionType', 'JobFunctionType', 'ko', '', '', 'ORGROOT');
		coviCtrl.renderCompanyAXSelect("EntCode",'ko',false,"","",'');
		//$("#EntCode").coviCtrl("setSelectOption", "/approval/common/getEntInfoListAssignIdData.do");
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
		return $('#hidJobFunctionName').val();
	}
	
	function addMenuDicCallback(data){
		$('#JobFunctionName').val(data.KoFull);
		$('#hidJobFunctionName').val(coviDic.convertDic(data))
		Common.close("DictionaryPopup");
	}
</script>
<form id="PersonDirectorOfUnitSetPopup" name="PersonDirectorOfUnitSetPopup">
	<div>				
		<table class="AXFormTable" >
		  <colgroup>
			<col id="t_tit4">
			<col id="">
		  </colgroup>
		  <tbody>
		    <tr>
		      <th style="width: 85px ;"><spring:message code="Cache.lbl_Domain"/></th>
			  <td>
				<select id="EntCode" name="EntCode" class="AXSelect">
				</select>
			  </td>
		    </tr>
		    <tr>
		      <th  style="width: 85px ;"><spring:message code="Cache.lbl_apv_BizDocName"/></th>
			  <td>
			  	<input id="JobFunctionName" name="JobFunctionName" type="text" class="AXInput" readonly="readonly" maxlength="64" style="width:289px;"/>
			  	<input type="button" value="<spring:message code='Cache.lbl__DicModify'/>" class="AXButton" onclick="dictionaryLayerPopup();" />
			  </td>
		    </tr>
		    <tr>
		      <th style="width: 85px ;"><spring:message code="Cache.lbl_apv_BizDocCode"/></th>
			  <td><input id="JobFunctionCode" name="JobFunctionCode" type="text" class="AXInput"  maxlength="64" style="width:350px;"/></td>
		    </tr>
			<tr>
		      <th style="width: 85px ;"><spring:message code="Cache.lbl_BizSection"/></th>
              <td>
				<select id="JobFunctionType" name="JobFunctionType" class="AXSelect">
				</select>
              </td>
		    </tr>
			<tr>
		      <th style="width: 85px ;"><spring:message code="Cache.lbl_apv_desc"/></th>
			  <td><textarea id="Description" name="Description" maxlength="512"  class="AXTextarea" style="width:342px; height:50px;resize:none"></textarea></td>
		    </tr>
			<tr>
		      <th style="width: 85px ;"><spring:message code="Cache.lbl_apv_Sort"/></th>
			  <td><input mode="numberint"  num_max="32767" class="AXInput"   id="SortKey" name="SortKey" type="text" maxlength="16" style="width:350px;"/></td>
		    </tr>
			<tr>
		      <th style="width: 85px ;"><spring:message code="Cache.lbl_apv_IsUse"/></th>
                <td>
                    <select id="IsUse" name="IsUse" class="AXSelect">
						<option value="Y" selected><spring:message code="Cache.lbl_apv_jfform_07"/></option>
						<option value="N"><spring:message code="Cache.lbl_apv_jfform_08"/></option>
					</select>
                </td>
		    </tr>
			<tr>
		      <th style="width: 85px ;"><spring:message code="Cache.lbl_apv_formcreate_LCODE15"/></th>
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
	<input type="hidden" id="hidJobFunctionName" value="">
	<input type="hidden" id="SeqHiddenValue" value="" />
	<input type="hidden" id="EntCode" value="" />
</form>