<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script>
var mode = "${param.mode}";
var paramStoreFormRevID = "${param.id}";

$(document).ready(function(){	
	// 양식명 다국어 세팅
	coviDic.renderInclude('dic', {
		lang : 'ko',
		hasTransBtn : 'true',
		allowedLang : 'ko,en,ja,zh',
		dicCallback : '',
		popupTargetID : '',
		init : '',
		styleType : "U"
	});
	$("#dic").find(".sadmin_table").css("border-top", "none");
	$("#dic").find(".sadmin_table tr:last").css("border-bottom", "none");
	
	$("#formPrefix").on("keyup", function(){
		$(this).val($(this).val().replace(/[^A-Za-z0-9_]/gi,''));
	}).on("blur", function(){
		if($(this).val() && !new RegExp(/^[A-Za-z][A-Za-z0-9_]*$/).test($(this).val())){
			Common.Warning("<spring:message code='Cache.msg_apv_chkInputTbName'/>");//"영어, 숫자, 언더바(_) 만 입력 가능합니다.";				
			$(this).val("");
		}
	});
	
	if(mode=="modify"){
		parent.$("#StoreUpdateFormPopup_Title span").text("<spring:message code='Cache.lbl_modifyForm'/>");
		$("#btn_delete").show();
		$("input#formPrefix").prop("disabled", true);
		$("#btnDuplicateCheck").hide();
		modifySetData();
		Common.toolTip($("#btn_formfile_id"), "ToolTip_ChangeForm", "width:570px"); //양식을 변경할 경우만 등록해주세요. 추가된 파일이 없을경우 기존파일로 대체됩니다.
	}
	
	setselCategory();
	
	//첨부파일 update 공통단 호출
	coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : false, fileEnable : 'zip', useWebhard : 'false'});
	$("#divFileLimitInfo").find("span").css("line-height","30px"); // 업로드제한 세로간격조절
	$("#coviFileTooltip").css("left","0px").css("width","65px"); // tooltip 위치 조정
	$("#oFile").change(function(){
	    readURL(this);
	});

});

function readURL(input) {
	 if (input.files && input.files[0]) {
		 if(input.files[0].type.match('image.*')){
			 var reader = new FileReader(); //파일을 읽기 위한 FileReader객체 생성
			 reader.onload = function (e) {
				 //파일 읽어들이기를 성공했을때 호출되는 이벤트 핸들러
		         $('#imgPreThumb').attr('src', e.target.result).css("max-height", "200px");
		         //이미지 Tag의 SRC속성에 읽어들인 File내용을 지정
		         //(아래 코드에서 읽어들인 dataURL형식)
		     }                   
		     reader.readAsDataURL(input.files[0]);
		     //File내용을 읽어 dataURL형식의 문자열로 저장
		 }else{
			 parent.Common.Warning("<spring:message code='Cache.msg_OnlyImageFileAttach' />", "Warning", function(){
	    			$("#fileurl").val("");
	    			$(input).val("");
	    			$(input).click();
	    		});
	    	}
	 }else{
		$("#imgPreThumb").attr("src","");		 
	 }
}

// 레이어 팝업 닫기
function closeLayer(){
	if(mode == "modify"){
		parent.Common.Close("StoreUpdateFormPopup");
	}else{
		parent.Common.Close("StoreAddFormPopup");
	}
}

function makeNode(sName, vVal) {
    var jsonObj = {};
    
    if(vVal == null || vVal == undefined){
    	vVal = "";
    }
    jsonObj[sName] = vVal;

    return jsonObj;
}

//저장
function saveSubmit(bVerUp){
	//data셋팅	
	var formName = $("#ko_full").val() + ";" + $("#en_full").val() + ";" + $("#ja_full").val() + ";" + $("#zh_full").val();
	
	if (axf.isEmpty(CFN_GetDicInfo(formName))) {
        Common.Warning("<spring:message code='Cache.msg_apv_016' />");
        return false;
    }
	
	var urlSubmit;
	var confirmMessage;
		
	if(mode == 'add'){
		urlSubmit = 'storeInsertFormData.do';
		confirmMessage = "<spring:message code='Cache.msg_RUSave' />";
	}else{
		urlSubmit = 'storeUpdateFormData.do';
		confirmMessage = "<spring:message code='Cache.msg_RUEdit' />";
	}
	
	if(checkValidation()){		
		parent.Common.Confirm(confirmMessage, "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				var formData = new FormData();
				var jsonObj = {};
			    $.extend(jsonObj, makeNode("StoredFormRevID", paramStoreFormRevID));
			    $.extend(jsonObj, makeNode("StoredFormID", $("#StoredFormID").val()));
			    $.extend(jsonObj, makeNode("FormPrefix", $("#formPrefix").val()));
			    $.extend(jsonObj, makeNode("FormName", formName));
			    $.extend(jsonObj, makeNode("CategoryID", $("#selCategory").val()));
			    $.extend(jsonObj, makeNode("IsFree", $('.onOffBtn').hasClass('on') ? "N": "Y"));
			    $.extend(jsonObj, makeNode("FormDescription", $("#formDesc").val()));
			    $.extend(jsonObj, makeNode("MobileFormYN", $('#mobileFormYN').is(':checked') ? "Y" : "N"));
			    
			    $.extend(jsonObj, makeNode("ItemType", "APP"));
			    $.extend(jsonObj, makeNode("ItemName", "<spring:message code='Cache.lbl_Approval_form' />"));//결재양식
			    $.extend(jsonObj, makeNode("Price", $("#formPrice").val().replace(/,/gi, '')));
			    
			    jsonObj.bVerUp = bVerUp || false;
			    
			    formData.append("formObj", JSON.stringify(jsonObj));
			    
			    // 파일정보
			    formData.append("ImgFileInfo", $('#oFile')[0].files[0]);
			    for (var i = 0; i < coviFile.files.length; i++) {
			    	if (typeof coviFile.files[i] == 'object') {
			    		formData.append("MultiFileData[]", coviFile.files[i]);
			        }
			    }
				
				$.ajax({
            		type:"post",
					url:urlSubmit,
					data: formData,
            		dataType : 'json',
            		processData : false,
        	        contentType : false,
					success:function (data) {
						if(data.result == "ok"){
							Common.Inform(data.message, "Inform", function() {
								parent.setSchemaGridData();
								closeLayer();
							});
						}else{
							Common.Error(data.message, "Error");
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax(urlSubmit, response, status, error);
					}
				});
			}
		});
	}
}	

function checkValidation(){
	if ($("#formPrefix").val() == "") { Common.Warning("<spring:message code='Cache.msg_apv_012' />"); return false; } //"양식키(영문)을 입력하십시오."
	if ($("#ko_full").val() == "") { Common.Warning("<spring:message code='Cache.msg_apv_011' />"); return false; }  //  "양식명(한글)을 입력하십시오."
	if ($("#selCategory").val() == "") { Common.Warning("<spring:message code='Cache.msg_apv_516' />"); return false; }  //  "양식분류를 선택해주세요"
	if ($('.onOffBtn').hasClass('on') && $("#formPrice").val() == "0") { Common.Warning("<spring:message code='Cache.msg_store_apv_001'/>"); return false; }  //  "유료양식은 금액을 입력해주세요."
	if ( mode=="add" && $("#oFile").val() == "") { Common.Warning("<spring:message code='Cache.msg_store_apv_002'/>"); return false; }
	if ( mode=="add" && checkformDuplicate()){ return false; }

	if(mode == "add"){
		var getFirstFromName = "";
		var getFirstFromExtention = "";
		var getFileResult = false;
		$.each(coviFile.fileInfos, function (i, data) {
			if($("#coviFileTooltip").text().indexOf(data.FileName.split(".")[1]) == -1){
				getFileResult = true; 
				return false;
			}
		});
		
		if(getFileResult || coviFile.fileInfos.length == 0){
			Common.Warning("<spring:message code='Cache.msg_store_apv_003' />");  //압축된 양식파일을 선택해주세요.
			return false;
		};
	}
	
	return true;
}

function checkformDuplicate(){ //formprefix 확인
	var isCheckDup = false;
	if($("#formPrefix").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_apv_012' />"); 
		return false;
	}
	
	$.ajax({
		url:"storeFormDuplicateCheck.do",
		type:"post",
		data: {
			"FormPrefix" : $("#formPrefix").val()
			},
		async:false,
		success:function (data) {
			if(data.result > 0){
				isCheckDup = true;
			}else{
				isCheckDup = false;
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("storeFormDuplicateCheck.do", response, status, error);
		}
	});
	
	if(isCheckDup){ 
		Common.Warning('<spring:message code="Cache._msg_FormDuplicate"/>'); //양식키가 중복되었습니다. 양식키 및 버전을 확인해주세요.
		return isCheckDup;
	}
	if($(event.target).attr("id") == "btnDuplicateCheck" && !isCheckDup){
		Common.Inform("<spring:message code='Cache.msg_UseAvailable' />"); //사용가능합니다
	}
	return isCheckDup;
}

//수정화면 data셋팅
function modifySetData(){
	//data 조회
	$.ajax({
		type:"POST",
		data:{
			"StoredFormRevID" : paramStoreFormRevID	
			,mode : "Write"
		},
		url:"getStoreFormData.do",
		success:function (data) {					
			if(Object.keys(data.info).length > 0){					
				$("#StoredFormID").val(data.info.StoredFormID);				
				$("#formPrefix").val(data.info.FormPrefix);				
				$("#ko_full").val(data.info.FormName.split(";")[0]);
				try { // 기존데이터에서 오류 발생할 수 있음.
	 				$("#en_full").val(data.info.FormName.split(";")[1]);
	 				$("#ja_full").val(data.info.FormName.split(";")[2]);
	 				$("#zh_full").val(data.info.FormName.split(";")[3]);
				} catch(e) { coviCmn.traceLog(e); }
				$("#selCategory").val(data.info.CategoryID).prop("selected",true);
				$("#mobileFormYN").prop("checked",data.info.MobileFormYN == "Y" ? true : false);
				var getIsFree = data.info.IsFree;
				$("#isFree").text(getIsFree=="Y" ? '<spring:message code="Cache.lbl_price_free"/>' : '<spring:message code="Cache.lbl_price_charged"/>');
				if(getIsFree == "Y"){
					$('.onOffBtn').removeClass('on').addClass('off')
					$("#formPrice").val("0").prop("readOnly",true);
				}
				$("#formPrice").val(toAmtFormat(data.info.Price));
				$("#formDesc").text(data.info.FormDescription);
				$("#imgPreThumb").prop("src", coviCmn.loadImageId(data.info.ThumbnailFileID)).css("max-height", "200px");
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("getFormClassData.do", response, status, error);
		}
	});
}

function onGubunChange(){
	if($('.onOffBtn').hasClass('on')){
		$('.onOffBtn').removeClass('on').addClass('off');
		$("#isFree").text('<spring:message code="Cache.lbl_price_free"/>'); //무료
		$("#formPrice").val("0").prop("readOnly",true);
	} else {
		$('.onOffBtn').removeClass('off').addClass('on');
		$("#isFree").text('<spring:message code="Cache.lbl_price_charged"/>'); //유료
		$("#formPrice").prop("readOnly",false);
	}
}

// 임시 이미지 업로드
function imgUpload(obj) {
    // 선택파일의 경로를 분리하여 확장자를 구합니다.
    document.getElementById('fileurl').value = obj;
    
    pathPoint = obj.lastIndexOf('.');
    filePoint = obj.substring(pathPoint + 1, obj.length);
    fileType = filePoint.toLowerCase();
    strImgNm = obj.substring(obj.lastIndexOf("\\") +1, obj.length);

    // 확장자가 이미지 파일이면 preview에 보여줍니다.
    if (fileType == 'jpg' || fileType == 'gif' || fileType == 'png' || fileType == 'jpeg' || fileType == 'bmp') {
    	return true;
    } else {
        //Common.Warning("<spring:message code='Cache.msg_OnlyImageFileAttach' />");			//이미지 파일만 첨부해 주세요.
        return false;
    }
}

//양식 분류 select box 세팅
function setselCategory(){
	$.ajax({
		url:"getStoreCategorySelectbox.do",
		type:"post",
		async:false,
		success:function (data) {
			$("select[id='selCategory'] option").remove();   
			$("#selCategory").append("<option value=''>"+Common.getDic('lbl_apv_selection')+"</option>");
			for(var i=0; i<data.list.length;i++){
				$("#selCategory").append("<option value='"+data.list[i].optionValue+"'>"+data.list[i].optionText+"</option>");
				/*if(getFormClassID == data.list[i].optionValue){
					$("#selCategory").val(getFormClassID).prop("selected", true);
				}*/
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("getStoreCategorySelectbox.do", response, status, error);
		}
	});
}

function toAmtFormat(val) {
	var retVal = "";
	if(val != null){
		if(val.toString != null){
			retVal = val.toString();
			if(!isNaN(retVal.replaceAll(",", ""))){
				var splitVal = retVal.split(".");
				if(splitVal.length==2){
					retVal = splitVal[0].replace(/(\d)(?=(?:\d{3})+(?!\d))/g,'$1,');
					retVal = retVal +"."+ splitVal[1];
				}
				else if(splitVal.length==1){
					retVal = splitVal[0].replace(/(\d)(?=(?:\d{3})+(?!\d))/g,'$1,');
				}else{
					retVal = "";
				}
			}
		}
	}
	//	str.replace(/[^\d]+/g,'')
	return retVal
}
</script>
<div class="divpop_contents">
	<div class="sadmin_pop">
		<input type="hidden" id="StoredFormID" />
		<table class="sadmin_table sa_menuBasicSetting">
			<colgroup>
				<col width="110px;">
				<col width="*">
				<col width="110px;">
				<col width="*">
			</colgroup>
			<tbody>
				<tr>
					<th><spring:message code='Cache.lbl_apv_formcreate_LCODE02'/></th>  <!--양식키(영문)-->
					<td colspan="3">
						<input name="formPrefix" id="formPrefix" type="text" style="width:calc(100% - 77px) !important;" maxlength="30"/>
						<a id="btnDuplicateCheck" class="btnTypeDefault" style="padding: 0px 9px 0 9px;" onclick="checkformDuplicate(); return false;"><spring:message code="Cache.btn_CheckDouble"/></a>
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_apv_formcreate_LCODE03'/></th> <!-- 양식명 -->
					<td style="padding: 0px" id="dic"  colspan="3"></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_FormCate'/></th>  <!--양식분류-->
					<td>
						<select id="selCategory" name="selCategory" class="selectType02" style="width:150px"></select>
					</td>				          
					<th><spring:message code='Cache.lbl_apv_isMobileForm'/></th>  <!--모바일양식-->
					<td class="chkStyle04 chkType01">
						<input type="checkbox" name="mobileFormYN" id="mobileFormYN"><label for="mobileFormYN"><span></span></label>
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_apv_gubun'/></th>  <!--구분-->
					<td>
						<span class="mr5" id="isFree"><spring:message code="Cache.lbl_price_charged"/></span> <div class="alarm type01 pd0"><a href="#" class="onOffBtn on" onClick="onGubunChange();"><span></span></a></div>
					</td>
					<th><spring:message code='Cache.lbl_amount'/></th>  <!--금액-->
					<td>
						<input type="text" id="formPrice" kind="money" money_max="99999999999" money_min="0" value="0" style="text-align: right;">
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_formDesc"/></th> <!-- 양식설명 -->
					<td colspan="3"><textarea name="formDesc" id="formDesc" cols="30" rows="10"></textarea></td>
				</tr>
				<tr>
		            <th><spring:message code="Cache.msg_RepresentativeImg"/></th><!-- 대표이미지 -->
		            <td>
		            	<div class="pagingType02 buttonStyleBoxLeft pb5">
			            	<input name="fileurl" id="fileurl" type="text" class="AXButton" readonly="readonly" style="display:none;">
			             	<a class='btnTypeDefault' onclick="document.getElementById('oFile').click();" ><spring:message code="Cache.lbl_RegistImage"/></a> <!-- 이미지등록 -->
			           	 	<input type="file" id="oFile"  onchange="imgUpload(this.value);" style="width:0px;filter:alpha(opacity:'0');opacity:0;position:absolute;cursor: pointer;" accept=".gif,.jpg,.png"/>
		            	</div>    
		            	<div class="form_img">
		            		<img id="imgPreThumb" onerror="coviCmn.imgError(this)" />
		            	</div>
		            </td>
		        </tr>
				<tr>
					<th><spring:message code="Cache.lbl_FormFile"/><!-- 양식파일 -->
						<c:if test="${!empty param.mode && param.mode eq 'modify'}" >
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="btn_formfile_id"></a>
							</div>
						</c:if>
					</th>
					<td colspan="3">
						<div id="fileDiv" class="inputBoxSytel01 type01" style="padding-top: 10px;">
							<div id="con_file" style="padding:0px;"></div>
						</div>
					</td>
				</tr>
			</tbody>
		</table>
		<div class="bottomBtnWrap">
			<c:if test="${!empty param.mode && param.mode eq 'modify'}" >
				<a class="btnTypeDefault btnTypeBg" onClick="saveSubmit(true);"><spring:message code="Cache.btn_saveVerUp"/></a> <!-- 저장(버젼업) --> 
			</c:if>
			<a class="btnTypeDefault btnTypeBg" onClick="saveSubmit();"><spring:message code="Cache.btn_save"/></a> <!-- 저장 -->
			<a href="javascript:closeLayer();" class="btnTypeDefault"><spring:message code="Cache.btn_att_close"/></a><!-- 닫기 -->
		</div>
	</div>
</div>