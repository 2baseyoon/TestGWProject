<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">	
	const comTableID = CFN_GetQueryString("id")=="undefined"? "" : CFN_GetQueryString("id");
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
		$.ajax({
			type:"POST",
			data:{
				"ComTableID" : comTableID				
			},
			url:"getComTableFieldData.do",
			async : true,
			success:function (data) {			
				if(data.status == "SUCCESS"){
					if(data.list && data.list.length > 0){
						toggleEditMode(false); // 읽기모드 - 설정된 필드가 있는경우
						oldFieldKey = [];
						$.each(data.list, function(i,obj) {
							addRow(obj);
							if(obj.ComTableFieldID) oldFieldKey.push(obj.ComTableFieldID);
						});
						
						// title 셋팅
						$("#tbody_field").find("td").each(function(idx,item){
							var sTitle = $(item).find(".for-display").text();
							$(item).attr("title",sTitle);
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
	
	// 필드 불러오기 (작성된 쿼리를 기준으로 필드 초기화)
	function resetField(){
		
		Common.Confirm("<spring:message code='Cache.msg_confirmFieldReset' />", "", function(result){ // 기존 필드정보를 삭제하고, 쿼리를 기준으로 필드를 로드합니다. 진행 하시겠습니까?
			if(result){
				var strSampleQuery = "";	
				
				$.ajax({
					type:"POST",
					data:{
						"ComTableID" : comTableID				
					},
					url:"getComTableFieldReset.do",
					async : true,
					success:function (data) {			
						if(data.status == "SUCCESS"){
							$("#tbody_field").find("tr").not("#tr_template").remove(); // 필드 초기화
							
							if(data.list && data.list.length > 0){
								toggleEditMode(true); // 편집모두 - 필드 불러오기(초기화) 한 경우
								$.each(data.list, function(i,obj) {
									addRow(obj);
								});
							}else{ 
								toggleEditMode(false); // 읽기모드 - 조회된 필드가 없는 경우 
							}
						}else {
		                    Common.Error(data.message);
		                }
					},
					error:function(response, status, error){
						CFN_ErrorAjax("getComTableFieldReset.do", response, status, error);
					}
				});
				
						
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
				var oTarget = $(newRow).find("[name='" + key + "']"); // SortKey,FieldID,FieldName,FieldDisplayType,FieldWidth,FieldAlign,IsDisplay,IsSearch,IsSort,IsPopup,DecodeB64
				if($(oTarget).length > 0){
					
					$(oTarget).val(pData[key]);
					
					if(key == "FieldName"){ // 다국어(필드표시명)은 한국어값 별도셋팅
						var txtDisplay = pData[key].split(";")[0];
						$(oTarget).closest("td").find("[name='dp_FieldName']").val(txtDisplay)
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
			$(newRow).find("[name='FieldID']").removeAttr("readonly");
		}
			
		//toggleEditMode(bEdit,newRow);
		$("#tbody_field").append(newRow);
		setRowNum();
	}
	
	// 행삭제
	function removeRow(){
		var oChecked = $("#tbody_field").find("tr").not("#tr_template").find("[name='chk_row']:checked");
		$(oChecked).closest("tr").remove();
		setRowNum();
	}
	
	// 행이동
	function moveRow(pType){
		var oChecked = $("#tbody_field").find("tr").not("#tr_template").find("[name='chk_row']:checked");
		if(pType == "down") oChecked = $(oChecked).get().reverse();
		
		$(oChecked).each(function(idx,item){
			var oRow = $(item).closest("tr");
			if(pType == "up"){
				if($(oRow).prev().length > 0 && $(oRow).prev().attr("id") != "tr_template") $(oRow).insertBefore($(oRow).prev());
				else return false;
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
		$("#tbody_field").find("tr").not("#tr_template").find("[name='chk_row']").prop("checked",bCheck);
	}
	
	// 순번 초기화
	function setRowNum(){
		$("#tbody_field").find("tr").not("#tr_template").each(function(idx,item){
			var oTarget = $(item).find("[name='SortKey']");
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
			$("#tbody_field").find("td").removeAttr("title");
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
				"ComTableID" : comTableID,
				"FieldList" : JSON.stringify(oFieldList),
				"OldFieldKey" : JSON.stringify(oldFieldKey)
			},
			url:"setComTableField.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					//if (popupType == 'Add' && data.object == 0) Common.Inform("<spring:message code='Cache._msg_CodeDuplicate' />");
					parent.Common.Inform("<spring:message code='Cache.msg_Processed' />","",function(){ // 처리 되었습니다
						parent.searchConfig();
						closeLayer();
					}); 
				} else {
					Common.Error(data.message);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("setComTableField.do", response, status, error);
			}
		});
	}
	
	// validation
	function chkValidation(){
		var bValid = true;
		
		$("#tbody_field").find("tr").not("#tr_template").each(function(idx,item){
			if($(item).find("[name='FieldID']").val().trim() == ""){
				Common.Warning("<spring:message code='Cache.msg_inputComFieldId' />"); // 필드ID를 입력하세요.
				bValid = false;
				return false;
			}else if($(item).find("[name='FieldName']").val().trim() == ""){
				Common.Warning("<spring:message code='Cache.msg_inputComDisplayName' />"); // 필드표시명을 입력하세요.
				bValid = false;
				return false;
			}else if($(item).find("[name='FieldWidth']").val().trim() == "" || $(item).find("[name='FieldWidth']").val().trim() == "0"){
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
		$("#tbody_field").find("tr").not("#tr_template").each(function(idx,item){
			var oField = {};
			var aTarget = ["ComTableFieldID","SortKey","FieldID","FieldName","FieldDisplayType","FieldWidth","FieldAlign","IsDisplay","IsSearch","IsSort","IsPopup","DecodeB64"];
			$.each(aTarget, function(i,key){
				var sValue = $(item).find("[name='" + key + "']").val();
				oField[key] = sValue;
			});
			oFieldList.push(oField);
		});
		
		return oFieldList;
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
		return $(objSelectedRow).find("input[name='FieldName']").val()
	}
	function addMenuDicCallback(data){
		$(objSelectedRow).find("input[name='dp_FieldName']").val(data.KoFull);
		$(objSelectedRow).find("input[name='FieldName']").val(coviDic.convertDic(data));
		Common.close("DictionaryPopup");
	}
	
</script>

<style>
	.admin-list th{
		text-align: center !important; 
		padding:5px 10px 5px 10px !important;
		height:35px;
	}
	.admin-list th:last-child { border-right:0 !important; }
	.admin-list th,.admin-list td {
		overflow:hidden;
		white-space:nowrap;
		text-overflow:ellipsis;
	}
</style>

<div class="sadmin_pop">	
	<div style="margin-bottom:5px;">
		<a class="for-display btnTypeDefault" id="btn_edit" href="#" onclick="toggleEditMode(true);" style="display:none;"><spring:message code='Cache.btn_Edit'/></a> <!-- 수정 -->
		<a id="btn_resetField" href="#" class="btnTypeDefault" onclick="resetField();"><spring:message code='Cache.btn_resetField'/></a> <!-- 필드 불러오기-->
		<div class="for-edit" style="float:right;display:none;">
			<a href="#" class="btnTypeDefault btnPlusAdd" onclick="addRow();"><spring:message code='Cache.btn_Add'/></a> <!-- 추가-->
			<a href="#" class="btnTypeDefault btnSaRemove" onclick="removeRow();"><spring:message code='Cache.lbl_delete'/></a> <!-- 삭제-->
			<a href="#" class="btnTypeDefault btnMoveUp" onclick="moveRow('up');"><spring:message code='Cache.lbl_apv_up'/></a> <!-- 위로-->
			<a href="#" class="btnTypeDefault btnMoveDown" onclick="moveRow('down');"><spring:message code='Cache.lbl_apv_down'/></a> <!-- 아래-->
		</div>
	</div>
	<table class="sadmin_table sa_menuBasicSetting admin-list" >
		<colgroup>
			<col width="4%" class="for-edit">
			<col width="5%">
			<col width="14%">
			<col width="15%">
			<col width="12%">
			<col width="7%">
			<col width="8%">
			<col width="7%">
			<col width="7%">
			<col width="7%">
			<col width="7%">
			<col width="7%">
		</colgroup>
		<!-- 체크박스 , 순서  , 필드ID , 필드표시명 , 표시타입 , 너비(px) , 사용여부 , 검색여부 , 정렬여부 , 팝업여부 , Base64 Decode -->
		<thead>
			<tr>
				<th class="for-edit"> <!-- 체크박스 --> 
					<input type="checkbox" id="chk_all" class="input_check" onchange="chkAll(this);">
				</th>
				<th><spring:message code='Cache.lbl_Order'/></th> <!-- 순서 -->
				<th><spring:message code='Cache.lbl_ComFieldId'/></th> <!-- 필드ID -->
				<th><spring:message code='Cache.lbl_ComDisplayName'/></th> <!-- 필드표시명 -->
				<th><spring:message code='Cache.lbl_ComDisplayType'/></th> <!-- 표시타입 -->
				<th><spring:message code='Cache.lbl_ComFieldWidth'/>(px)</th> <!-- 너비 -->
				<th><spring:message code='Cache.lbl_ComFieldAlign'/></th> <!-- 좌우정렬 --> 
				<th><spring:message code='Cache.lbl_ComIsDisplay'/></th> <!-- 표시여부 -->
				<th><spring:message code='Cache.lbl_ComIsSearch'/></th> <!-- 검색여부 -->
				<th><spring:message code='Cache.lbl_ComIsSort'/></th> <!-- 정렬여부 -->
				<th><spring:message code='Cache.lbl_ComIsPopup'/></th> <!-- 팝업여부-->
				<th>Base64<br>Decode</th>
			</tr> 
		</thead>
		<tbody id="tbody_field">
			<tr id="tr_template" style="display:none;">
		      	<td class="for-edit" style="text-align:center;"> <!-- 체크박스 --> 
		      		<input type="checkbox" name="chk_row" class="input_check">
		      		<input type="hidden" name="ComTableFieldID" value="">
		      	</td>
		      	<td style="text-align:center;"> <!-- 순서 -->
		      		<input class="for-edit" mode="numberint" name="SortKey" type="text" readonly="readonly" maxlength="9" style="text-align:center;" />
		      		<span class="for-display" name="spn_display"></span>
		      	</td>
		      	<td> <!-- 필드ID -->
		      		<input class="for-edit" name="FieldID" type="text" readonly="readonly" />
		      		<span class="for-display" name="spn_display"></span>
		      	</td>
		      	<td> <!-- 필드표시명 -->
		      		<input class="for-edit" name="dp_FieldName" type="text" readonly="readonly" onclick="dictionaryLayerPopup(this);" />
		      		<!-- <a class="btnTypeDefault for-edit" onclick="dictionaryLayerPopup(this);" ><spring:message code='Cache.lbl__DicModify'/></a>  --> <!-- 다국어 -->
		      		<span class="for-display" name="spn_display"></span>
		  			<input type="hidden" name="FieldName" value="">
		      	</td>
		      	<td style="text-align:center;"> <!-- 표시타입 -->
		      		<select class="for-edit selectType02" name="FieldDisplayType">
						<option value="" selected><spring:message code="Cache.lbl_NotApplicable"/></option> <!-- 해당없음 -->
						<option value="dictionary"><spring:message code="Cache.lbl_MultiLang2"/></option> <!-- 다국어 -->
						<option value="dateFormat"><spring:message code="Cache.lbl_date"/>(YYYY-MM-DD)</option> <!-- 날짜 -->
						<!-- <option value="tag">Tag(html,xml)</option>  -->
						<option value="json">JSON</option>
					</select>
					<span class="for-display" name="spn_display"></span>
		      	</td>
		      	<td style="text-align:center;"> <!-- 너비 -->
		      		<input class="for-edit" mode="numberint" name="FieldWidth" type="text" maxlength="9" style="text-align:center;" value="100" />
		      		<span class="for-display" name="spn_display"></span>
		      	</td>
		      	
		      	<td style="text-align:center;"> <!-- 좌우정렬 -->
		      		<select class="for-edit selectType02" name="FieldAlign">
						<option value="left" selected>left</option>
						<option value="center">center</option>
						<option value="right">right</option>
					</select>
					<span class="for-display" name="spn_display"></span>
		      	</td>
		      	<td style="text-align:center;"> <!-- 표시여부 -->
					<select class="for-edit selectType02" name="IsDisplay">
						<option value="Y" selected>Y</option>
						<option value="N">N</option>
					</select>
					<span class="for-display" name="spn_display"></span>
		      	</td>
		      	<td style="text-align:center;"> <!-- 검색여부 -->
					<select class="for-edit selectType02" name="IsSearch">
						<option value="Y">Y</option>
						<option value="N" selected>N</option>
					</select>
					<span class="for-display" name="spn_display"></span>
		      	</td>
		      	<td style="text-align:center;"> <!-- 정렬여부 -->
					<select class="for-edit selectType02" name="IsSort">
						<option value="Y">Y</option>
						<option value="N" selected>N</option>
					</select>
					<span class="for-display" name="spn_display"></span>
		      	</td>
		      	
		      	<td style="text-align:center;"> <!-- 팝업여부 -->
					<select class="for-edit selectType02" name="IsPopup">
						<option value="Y">Y</option>
						<option value="N" selected>N</option>
					</select>
					<span class="for-display" name="spn_display"></span>
		      	</td>
		      	
		      	<td style="text-align:center;"> <!-- Base64 Decode -->
					<select class="for-edit selectType02" name="DecodeB64">
						<option value="Y">Y</option>
						<option value="N" selected>N</option>
					</select>
					<span class="for-display" name="spn_display"></span>
		      	</td>
		    </tr>
    	</tbody>
	</table>
	<div class="bottomBtnWrap">
		<a class="for-edit btnTypeDefault btnTypeBg" id="btn_save" onclick="saveSubmit();" style="display:none;"><spring:message code='Cache.btn_save'/></a> <!-- 저장 -->
		<a onclick="closeLayer();" class="btnTypeDefault" ><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
	</div>
</div>
