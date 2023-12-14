<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">	
	var aggFormId = "${param.id}";
	var entCode = "${param.entCode}";
	var companyCode = "";
	var bEdit = false;
	var objSelectedRow = null;
	var oldFieldKey = [];
	
	$(document).ready(function(){		
		setControl();
	});
	
	// Select box 및 이벤트 바인드 및 데이터로드
	function setControl(){
		// 기존 필드 조회
		$("#tbody_field").find("tr").not("#tr_template,.header").remove();
		$.ajax({
			type:"POST",
			data:{
				"aggFormId" : aggFormId				
			},
			url:"/approval/manage/aggregation/form/fields.do",
			async : true,
			success:function (data) {			
				if(data.status == "SUCCESS"){
					if(data.list && data.list.length > 0){
						toggleEditMode(false); // 읽기모드 - 설정된 필드가 있는경우
						oldFieldKey = [];
						$.each(data.list, function(i,obj) {
							addRow(obj);
							if(obj.aggFieldId && obj.aggFieldId != '') oldFieldKey.push(obj.aggFieldId.toString());
						});
					}else{ 
						toggleEditMode(false); // 읽기모드 - 설정된 필드가 없는 경우 
						$("#btn_edit").hide(); // 최초에는 편집 없이 필드불러오기만 실행가능
					}
				}else {
                    Common.Error(data.message);
                }
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getComTableFieldData.do", response, status, error);
			}
		});
	}
	
	// 행 추가
	function addRow(pData){
		var newRow = $("#tr_template").clone();
		$(newRow).removeAttr("id");
		$(newRow).show();
		
		if(pData){ // 데이터 있으면 바인딩
			$.each(Object.keys(pData), function(i,key) {
				var oTarget = $(newRow).find("[name='" + key + "']");
				if($(oTarget).length > 0){
					
					$(oTarget).val(pData[key]);
					
					if(key == "fieldName"){ // 다국어(필드표시명)은 한국어값 별도셋팅
						var txtDisplay = pData[key].split(";")[0];
						$(oTarget).closest("td").find("[name='dp_fieldName']").val(txtDisplay)
						$(oTarget).closest("td").find("[name='spn_display']").html(txtDisplay);
					}else if($(oTarget).is("select")) { // select는 selectedtext로 표시
						var txtDisplay = $(oTarget).find("option:selected").text();
						$(oTarget).closest("td").find("[name='spn_display']").html(txtDisplay);
					} else {
						$(oTarget).closest("td").find("[name='spn_display']").html(pData[key]);
					}
					
				}
			});
		}else{ // 신규행추가
			$(newRow).find("[name='fieldId']").removeAttr("readonly");
		}
			
		//toggleEditMode(bEdit,newRow);
		$("#tbody_field").append(newRow);
		setRowNum();
	}
	
	// 행삭제
	function removeRow(){
		var oChecked = $("#tbody_field").find("tr").not("#tr_template,.header").find("[name='chk_row']:checked");
		$(oChecked).closest("tr").remove();
		setRowNum();
	}
	
	// 행이동
	function moveRow(pType){
		var oChecked = $("#tbody_field").find("tr").not("#tr_template,.header").find("[name='chk_row']:checked");
		if(pType == "down") oChecked = $(oChecked).get().reverse();
		
		$(oChecked).each(function(idx,item){
			var oRow = $(item).closest("tr");
			if(pType == "up"){
				if($(oRow).prev().length > 0 && $(oRow).prev().attr("id") != "tr_template" && $(oRow).prev().attr("class") != "header") {
					$(oRow).insertBefore($(oRow).prev());
				}else {
					return false;
				}
			}else if(pType == "down"){
				if($(oRow).next().length > 0) $(oRow).insertAfter($(oRow).next()); 
				else return false;
			}
			
		});
		
		setRowNum();
	}
	
	// checkbox 전체선택
	function chkAll(pObj){
		var bCheck = $(pObj).is(":checked");
		$("#tbody_field").find("tr").not("#tr_template,.header").find("[name='chk_row']").prop("checked",bCheck);
	}
	
	// 순번 초기화
	function setRowNum(){
		$("#tbody_field").find("tr").not("#tr_template,.header").each(function(idx,item){
			var oTarget = $(item).find("[name='sortKey']");
			$(oTarget).val(idx + 1);
			$(oTarget).closest("td").find("[name='spn_display']").html(idx + 1);
		});
	}
	
	// 편집/읽기 모드 변경
	function toggleEditMode(pEdit){
		bEdit = pEdit;
		if(bEdit){
			$(".for-display").hide();
			$(".for-edit").show();
		}else{
			$(".for-display").show();
			$(".for-edit").hide();
			$("[name='chk_row']").prop("checked",false);
		}
	}
		
	// 저장
	function saveSubmit(){
		if(!chkValidation()) return false;
		
		var oFieldList = getFieldList();
		
		$.ajax({
			type:"POST",
			data:{
				"aggFormId" : aggFormId,
				"FieldList" : JSON.stringify(oFieldList),
				"OldFieldKey" : JSON.stringify(oldFieldKey)
			},
			url:"/approval/manage/aggregation/form/saveFormFields.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					//if (popupType == 'Add' && data.object == 0) Common.Inform("<spring:message code='Cache._msg_CodeDuplicate' />");
					parent.Common.Inform("<spring:message code='Cache.msg_Processed' />","",function(){ // 처리 되었습니다
						setControl();
						//closeLayer();
					}); 
				} else {
					Common.Error(data.message);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("fieldAdd.do", response, status, error);
			}
		});
	}
	
	// validation
	function chkValidation(){
		var bValid = true;
		
		$("#tbody_field").find("tr").not("#tr_template,.header").each(function(idx,item){
			if($(item).find("[name='fieldId']").val().trim() == ""){
				Common.Warning("<spring:message code='Cache.msg_inputComFieldId' />"); // 필드ID를 입력하세요.
				bValid = false;
				return false;
			}else if($(item).find("[name='fieldName']").val().trim() == ""){
				Common.Warning("<spring:message code='Cache.msg_inputComDisplayName' />"); // 필드표시명을 입력하세요.
				bValid = false;
				return false;
			}else if($(item).find("[name='fieldWidth']").val().trim() == "" || $(item).find("[name='fieldWidth']").val().trim() == "0"){
				Common.Warning("<spring:message code='Cache.msg_ComFieldWidth' />"); // 너비를 입력하세요.
				bValid = false;
				return false;
			}
		});
		
		return bValid;
	}
	
	// 현재 설정된 데이터 가져오기
	function getFieldList(){
		var oFieldList = [];
		$("#tbody_field").find("tr").not("#tr_template,.header").each(function(idx,item){
			var oField = {};
			var aTarget = ["aggFieldId","sortKey","fieldId","fieldName","fieldWidth","fieldAlign","displayYN","isCommon"];
			$.each(aTarget, function(i,key){
				var sValue = $(item).find("[name='" + key + "']").val();
				oField[key] = sValue;
			});
			oFieldList.push(oField);
		});
		
		return oFieldList;
	}
	
	function addFormField(){
    	Common.open("","addFormField",
                "<spring:message code='Cache.lbl_addAggregationField'/>", /* 집계함 필드 추가 */
                "/approval/admin/aggregation/form/fieldAdd.do?entCode=" + entCode + "&aggFormId=" + aggFormId,
                "450px","520px","iframe",true,null,null,true);
    }
    
	function callBackAddFields(data) {
		for(var i = 0; i < data.commonFields.length; i++) {
			var item = data.commonFields[i];
			var obj = {
					"fieldId" : item.fieldId,
					"fieldName" : item.fieldName,
					"aggFormId" : data.aggFormId,
					"isCommon" : "Y",
					"displayYN" : "Y",
					"fieldAlign" : "center",
					"fieldWidth" : "100"
			};
			addRow(obj); // and setting.
		}
		for(var i = 0; i < data.formFields.length; i++) {
			var item = data.formFields[i];
			var obj = {
					"fieldId" : item.FieldName,
					"fieldName" : item.FieldLabel,
					"aggFormId" : data.aggFormId,
					"isCommon" : "N",
					"displayYN" : "Y",
					"fieldAlign" : "center",
					"fieldWidth" : "100"
			};
			addRow(obj);
		}
	}
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	// 필드표시명 - 다국어 처리
	function dictionaryLayerPopup(pObj) {
		objSelectedRow = $(pObj).closest("tr");
		var option = {
				lang : 'ko',
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh',
				useShort : 'false',
				dicCallback : 'addDicCallback',
				popupTargetID : 'DictionaryPopup',
				init : 'initDicPopup',
				styleType : "T"
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
		return $(objSelectedRow).find("input[name='fieldName']").val()
	}
	
	function addDicCallback(data){
		$(objSelectedRow).find("input[name='dp_fieldName']").val(data.KoFull);
		$(objSelectedRow).find("input[name='fieldName']").val(coviDic.convertDic(data));
		Common.close("DictionaryPopup");
	}
	
</script>

<style>
	.admin-list th{
		text-align: center !important; 
		padding:5px 10px 5px 10px !important;
		height:35px;
	}
	.admin-list td{
		height:35px;
	}
	
	.bottomBtnWrap {
		margin-top:10px;
		text-align:center;
	}
	
	#tbody_field input[type=text] {
		width:100%;
	}
</style>

<div style="width:100%;">
	<div style="margin-bottom:5px;">
		<input type="button" class="for-display AXButton" id="btn_edit" onclick="toggleEditMode(true);" style="display:none;" value="<spring:message code='Cache.btn_Edit'/>"> <!-- 수정 -->
		<div class="for-edit" style="display:none;">
			<input type="button" class="AXButton btnPlusAdd" onclick="addFormField();" value="<spring:message code='Cache.btn_Add'/>" /><!-- 추가-->
			<input type="button" class="AXButton btnSaRemove" onclick="removeRow();" value="<spring:message code='Cache.lbl_delete'/>" /><!-- 삭제-->
			<input type="button" class="AXButton btnMoveUp" onclick="moveRow('up');" value="<spring:message code='Cache.lbl_apv_up'/>"/><!-- 위로-->
			<input type="button" class="AXButton btnMoveDown" onclick="moveRow('down');" value="<spring:message code='Cache.lbl_apv_down'/>" /><!-- 아래-->
		</div>
	</div>
	<table class="AXFormTable admin-list">
		<colgroup>
			<col width="3%" class="for-edit">
			<col width="5%">
			<col width="15%">
			<col width="25%">
			<col width="6%">
			<col width="6%">
			<col width="6%">
			<col width="5%">
		</colgroup>
		<!-- 체크박스 , 순서  , 필드ID , 필드표시명 , 표시타입 , 너비(px) , 사용여부 , 검색여부 , 정렬여부 , 팝업여부 , Base64 Decode -->
		<tbody id="tbody_field">
			<tr class="header">
				<th class="for-edit"> <!-- 체크박스 --> 
					<input type="checkbox" id="chk_all" class="input_check" onchange="chkAll(this);">
				</th>
				<th><spring:message code='Cache.lbl_Order'/></th> <!-- 순서 -->
				<th><spring:message code='Cache.lbl_ComFieldId'/></th> <!-- 필드ID -->
				<th><spring:message code='Cache.lbl_ComDisplayName'/></th> <!-- 필드표시명 -->
				<th><spring:message code='Cache.lbl_ComFieldWidth'/>(px)</th> <!-- 너비 -->
				<th><spring:message code='Cache.lbl_ComFieldAlign'/></th> <!-- 좌우정렬 --> 
				<th><spring:message code='Cache.lbl_ComIsDisplay'/></th> <!-- 표시여부 -->
				<th><spring:message code='Cache.lbl_isCommonField'/></th> <!-- 공통필드여부 -->
			</tr> 
			<tr id="tr_template" style="display:none;">
		      	<td class="for-edit" style="text-align:center;"> <!-- 체크박스 --> 
		      		<input type="checkbox" name="chk_row" class="input_check">
		      		<input type="hidden" name="aggFieldId" value="">
		      	</td>
		      	<td style="text-align:center;"> <!-- 순서 -->
		      		<input class="for-edit" mode="numberint" name="sortKey" type="text" disabled maxlength="9" style="text-align:center;" />
		      		<span class="for-display" name="spn_display"></span>
		      	</td>
		      	<td> <!-- 필드ID -->
		      		<input class="for-edit" name="fieldId" type="text" disabled />
		      		<span class="for-display" name="spn_display"></span>
		      	</td>
		      	<td> <!-- 필드표시명 -->
		      		<input class="for-edit" name="dp_fieldName" type="text" readonly style="cursor:pointer;" onclick="dictionaryLayerPopup(this);" />
		      		<!-- <a class="btnTypeDefault for-edit" onclick="dictionaryLayerPopup(this);" ><spring:message code='Cache.lbl__DicModify'/></a>  --> <!-- 다국어 -->
		      		<span class="for-display" name="spn_display"></span>
		  			<input type="hidden" name="fieldName" value="">
		      	</td>
		      	<td style="text-align:center;"> <!-- 너비 -->
		      		<input class="for-edit" mode="numberint" name="fieldWidth" type="text" maxlength="9" style="text-align:center;" value="100" />
		      		<span class="for-display" name="spn_display"></span>
		      	</td>
		      	<td style="text-align:center;"> <!-- 좌우정렬 -->
		      		<select class="for-edit selectType02" name="fieldAlign">
						<option value="left" selected>left</option>
						<option value="center">center</option>
						<option value="right">right</option>
					</select>
					<span class="for-display" name="spn_display"></span>
		      	</td>
		      	<td style="text-align:center;"> <!-- 표시여부 -->
					<select class="for-edit selectType02" name="displayYN">
						<option value="Y" selected>Y</option>
						<option value="N">N</option>
					</select>
					<span class="for-display" name="spn_display"></span>
		      	</td>
		      	<td style="text-align:center;"> <!-- 공통필드여부 -->
					<input class="for-edit" name="isCommon" type="text" disabled style="text-align:center;" />
					<span class="for-display" name="spn_display"></span>
		      	</td>
		    </tr>
    	</tbody>
	</table>
	<div class="bottomBtnWrap">
		<a class="for-edit AXButton btnTypeBg" id="btn_save" onclick="saveSubmit();" style="display:none;"><spring:message code='Cache.btn_save'/></a> <!-- 저장 -->
		<a onclick="closeLayer();" class="AXButton" ><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
	</div>
</div>