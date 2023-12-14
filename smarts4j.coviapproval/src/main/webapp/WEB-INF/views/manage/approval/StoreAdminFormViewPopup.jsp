<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script>
var mode = "${param.mode}";
var paramStoredFormRevID = "${param.id}"; 

$(document).ready(function(){
	// coviCmn.imgError($("#imgPreThumb")[0]);
	
	// 양식명 다국어 세팅
	coviDic.renderInclude('dic', {
		lang : 'ko',
		hasTransBtn : 'false',
		allowedLang : 'ko,en,ja,zh',
		dicCallback : '',
		popupTargetID : '',
		init : '',
		styleType : "U"
	});
	$("#dic").find(".sadmin_table").css("border-top", "none");
	$("#dic").find(".sadmin_table tr:last").css("border-bottom", "none");

	setData(paramStoredFormRevID);
	$("#dic").find("input").prop("disabled", true).css({"border" : "none", "background-color": "#fff"});
	
});

// 레이어 팝업 닫기
function closeLayer(){
	Common.Close();
}

function makeNode(sName, vVal) {
    var jsonObj = {};
    
    if(vVal == null || vVal == undefined){
    	vVal = "";
    }
    jsonObj[sName] = vVal;

    return jsonObj;
}

//수정
function goModifyPage(){
	location.href = "/approval/manage/StoreAddFormPopup.do?mode=modify&id="+paramStoredFormRevID;
}

//data셋팅
function setData(storedFormRevID){
	//data 조회
	$.ajax({
		type:"POST",
		data:{
			"StoredFormRevID" : storedFormRevID
			,mode : "View"
		},
		url:"getStoreFormData.do",
		success:function (data) {					
			if(Object.keys(data.info).length > 0){
				$("#formPrefix").html(data.info.FormPrefix);
				var dicArr = data.info.FormName.split(";");
				$("#ko_full").val(dicArr[0]);
				try { // 기존데이터에서 오류 발생할 수 있음.
	 				if(dicArr.length > 1)$("#en_full").val(data.info.FormName.split(";")[1]);
	 				if(dicArr.length > 2)$("#ja_full").val(data.info.FormName.split(";")[2]);
	 				if(dicArr.length > 3)$("#zh_full").val(data.info.FormName.split(";")[3]);
				} catch(e) { coviCmn.traceLog(e); }
				$("#selCategory").html(data.info.CategoryName);
				$("#mobileFormYN").html(data.info.MobileFormYN == "Y" ? '<spring:message code="Cache.lbl_Include"/>' : '<spring:message code="Cache.lbl_Exclude"/>');
				$("#isFree").html(data.info.IsFree == "Y" ? '<spring:message code="Cache.lbl_price_free"/>' : '<spring:message code="Cache.lbl_price_charged"/>');
				$("#formPrice").html(toAmtFormat(data.info.Price));
				$("#PurchasedCnt").html(toAmtFormat(data.info.PurchasedCnt));
				$("#formDesc").text(data.info.FormDescription);
				
				setImageInfo(data.info);
				
				setFileInfo(data.info, data.fileList);
				
				// Set Revision List
				var currentFormRevID = data.info.CurrentFormRevID;
				var revisionList = data.revList;
				$("#revisionSelectDiv").hide();
				if(revisionList && revisionList.length > 1) {
					$("#revisionSelect").html("");
					for(var idx = 0; revisionList != null && idx < revisionList.length; idx++) {
						var info = revisionList[idx];
						var selectedText = "";
						var selectedOptText = info["RevisionNo"];
						if(storedFormRevID == info["StoredFormRevID"]) {
							selectedText = "selected";
						}
						if(paramStoredFormRevID == info["StoredFormRevID"]){
							selectedOptText = info["RevisionNo"] + " (Current)";
						}
						$("#revisionSelect").append("<option value='" + info["StoredFormRevID"] + "' " + selectedText + ">" + selectedOptText + "</option>");
					}
					$("#revisionSelectDiv").show();
				}
				
				//활성 버젼인 경우만 수정버튼 활성화
				if(storedFormRevID != currentFormRevID) {
					$("#btnModify").hide();
				}else{
					$("#btnModify").show();
				}
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("getFormClassData.do", response, status, error);
		}
	});
}

function setImageInfo(data){
	$("#imgPreThumb").prop("src", coviCmn.loadImageId(data.ThumbnailFileID)).css("max-height", "200px");
}

function setFileInfo(data, fileList){
	var fileDownHTML = "";
	for(var i = 0; i < fileList.length; i++){
		fileDownHTML += "<div class='form_detail'>";
		fileDownHTML += "<strong title='<spring:message code='Cache.btn_save'/>' onclick='downFile(this)' fileId='"+fileList[i].FileID+"' fileToken='"+fileList[i].FileToken+"' style='cursor:pointer'>"+ fileList[i].FileName +"</strong>";
		if(fileList[i].Extention != undefined && fileList[i].Extention.toLowerCase() == "html" && data.FormHtmlFileID == fileList[i].FileID) fileDownHTML += "<a onclick='previewForm(\"" + paramStoredFormRevID + "\")' class='btn_enlarge' title='<spring:message code='Cache.btn_apv_preview'/>'></a>";
		fileDownHTML += "</div>";
	}
	
	$("td#fileTD").html(fileDownHTML);
	
}

function downFile(obj) {
	var fileID = $(obj).attr("fileId");
	var fileToken = $(obj).attr("fileToken");
	Common.fileDownLoad(fileID, fileToken);
}

function previewForm(storedFormRevID){
	CFN_OpenWindow("/approval/approval_CstfForm.do?cstfRevID=" + storedFormRevID, "", 790, (window.screen.height - 100), "resize", "false");
}

//삭제
function deleteSubmit(){
	parent.Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
		if(!result){
			return false;
		}else{
			var FormClassID = $("#FormClassID").val();
			
			//delete 호출
			$.ajax({
				type:"POST",
				data:{
					"FormClassID" : FormClassID
				},
				url:"deleteFormClassData.do",
				success:function (data) {
					if(data.result == "ok"){
						parent.Common.Inform(data.message);
						
						if(data.cnt==0){
							closeLayer();
							parent.searchConfig();							
						}
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("deleteFormClassData.do", response, status, error);
				}
			});
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

// 버젼변 조회(현재버젼아닐경우 조회만 가능)
function changeFormRevision(){
	var selectedRevID = $("#revisionSelect").val();
	setData(selectedRevID);
}
</script>
<div class="divpop_contents">
	<div class="sadmin_pop">
		<div id="revisionSelectDiv" style="text-align:right;display:none;margin-bottom:5px;">
			Revision. <select id="revisionSelect" onchange="changeFormRevision()" class="selectType02 w100p"></select>
		</div>
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
						<span id="formPrefix"></span>
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_apv_formcreate_LCODE03'/></th> <!-- 양식명 -->
					<td style="padding: 0px" id="dic"  colspan="3"></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_FormCate'/></th>  <!--양식분류-->
					<td>
						<span id="selCategory"></span>
					</td>
					<th><spring:message code='Cache.lbl_apv_isMobileForm'/></th>  <!--모바일양식-->
					<td>
						<span id="mobileFormYN">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_apv_gubun'/></th>  <!--구분-->
					<td>
						<span class="mr5" id="isFree"></span>
					</td>
					<th><spring:message code='Cache.lbl_amount'/></th>  <!--금액-->
					<td>
						<span id="formPrice"></span>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_purchasedCnt"/></th> <!-- 구매수 -->
					<td colspan="3"><span id="PurchasedCnt"></span></td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_formDesc"/></th> <!-- 양식설명 -->
					<td colspan="3"><textarea name="formDesc" id="formDesc" cols="30" rows="10" readonly></textarea></td>
				</tr>
				<tr>
		            <th><spring:message code="Cache.msg_RepresentativeImg"/></th><!-- 대표이미지 -->
		            <td>
		            	<div class="form_img">
		            		<img id="imgPreThumb" onerror="coviCmn.imgError(this)" />
		            	</div>                   
		            </td>
		        </tr>                    
				<tr>
					<th><spring:message code="Cache.lbl_FormFile"/></th><!-- 양식파일 -->
					<td colspan="3" id="fileTD">
					</td>
				</tr>
			</tbody>
		</table>
		<div class="bottomBtnWrap">
			<a id="btnModify" class="btnTypeDefault btnTypeBg" onClick="goModifyPage();"><spring:message code="Cache.btn_Modify"/></a> <!-- 수정 -->
			<a href="javascript:closeLayer();" class="btnTypeDefault"><spring:message code="Cache.btn_att_close"/></a><!-- 닫기 -->
		</div>
	</div>
</div>