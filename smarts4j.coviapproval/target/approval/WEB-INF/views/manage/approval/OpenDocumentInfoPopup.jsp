<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<script>
var FormInstID = CFN_GetQueryString("FormInstID");
var isDeleted = CFN_GetQueryString("isDeleted");
//
$(document).ready(function (){
	//setSelectFolder();
	//setTreeData();
	setDocumentInfo();
	
	// 삭제마킹/문서복원 버튼
	if(isDeleted == "Y"){
		$("#btn_delMarking").hide();
		$("#btn_markingRollBack").show();
	}else{
		$("#btn_markingRollBack").hide();
	}
});

// 문서 삭제마킹
function deleteMarkingDel(){
	parent.Common.Confirm("<spring:message code='Cache.msg_apv_alert_001' />", "Confirmation Dialog", function (result) {
		if(result){
			$.ajax({
				url:"deleteMarkingDel.do",
				type:"post",
				data:{
					"FormInstID":FormInstID
				},
				async:false,
				success:function (data) {
					if(data.status == "SUCCESS"){
						parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />", "Information", function(){
							Common.Close();
							//opener.location.reload();
							window.parent.location.reload();
						});
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("deleteMarkingDel.do", response, status, error);
				}
			});
		}
	});
}
//문서 삭제마킹 복원
function markingRollBack(){
	parent.Common.Confirm("<spring:message code='Cache.msg_apv_alert_003' />", "Confirmation Dialog", function (result) {
		if(result){
			$.ajax({
				url:"markingRollBack.do",
				type:"post",
				data:{
					"FormInstID":FormInstID
				},
				async:false,
				success:function (data) {
					if(data.status == "SUCCESS"){
						parent.Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />", "Information", function(){
							Common.Close();
							//opener.location.reload();
							window.parent.location.reload();
						});
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("markingRollBack.do", response, status, error);
				}
			});
		}
	});
}
//문서 완전 삭제
function deleteClearDel(){
	parent.Common.Confirm("<spring:message code='Cache.msg_apv_alert_004' />", "Confirmation Dialog", function (result) {
		if(result){
			$.ajax({
				url:"deleteClearDel.do",
				type:"post",
				data:{
					"FormInstID":FormInstID
				},
				async:false,
				success:function (data) {
					if(data.status == "SUCCESS"){
						parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />", "Information", function(){
							Common.Close();
							//opener.location.reload();
							window.parent.location.reload();
						});
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("deleteClearDel.do", response, status, error);
				}
			});
		}
	});
}

//  속성값 조회된 결과값 세팅
function setDocumentInfo(){
	$.ajax({
		url:"setDocumentInfo.do",
		type:"post",
		data:{
			"FormInstID":FormInstID
			},
		async:false,
		success:function (data) {
			if(data != null && data != undefined){
				$("#INITIATOR_NAME").html(CFN_GetDicInfo(data.list[0].InitiatorName)); //작성자
				$("#INITIATOR_OU_NAME").html(CFN_GetDicInfo(data.list[0].InitiatorUnitName)); // 작성부서
				$("#INITIATE_DATE").html(data.list[0].InitiatedDate); // 작성일자
				$("#STATE").html(data.list[0].BusinessState); // 상태
				$("#SUBJECT").html(data.list[0].FormSubject); //제목
				$("#DOCLINKS").html(data.list[0].DocLinks); // 연결문서
				$("#txtDOCLINKS").html(data.list[0].DocLinks);
				$("#BODYCONTEXT").html(data.list[0].BodyType); //본문
				$("#SECDOC").html(data.list[0].IsSecureDoc); // 기밀여부
				$("#FILEATTACH").html(data.list[0].EntCode); // 첨부파일
				$("#DOCNUM").html(data.list[0].DocNo); // 문서번호
				$("#txtSECDOC").val(data.list[0].DocYn);
				$("#txtSUBJECT").val(data.list[0].FormSubject);
				$("#txtBODYCONTEXT").val(Base64.b64_to_utf8(data.list[0].BodyContext));
				$("#ProcessID").val(data.list[0].PiID);
				$("#txtDOCNO").val(data.list[0].DocNo);
				setAttachInputData(Base64.b64_to_utf8(data.list[0].AttachFileInfo));
				
				if(data.list[0].ExtInfo.UseMultiEditYN == "Y") {
					$("#trAttachDocLink").hide();
				}
			} else {
				parent.Common.Error(res.message,"Error");
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("setDocumentInfo.do", response, status, error);
		}
	});
}

function setAttachInputData(attachFileInfo){
	$("#txtFILEATTACH").val(attachFileInfo);
	
	var strReturn = "";
	if(attachFileInfo != ''){
		var attachFileInfoObjs = $.parseJSON(attachFileInfo).FileInfos;
		
		for(var i=0; i<attachFileInfoObjs.length; i++){
			strReturn += attachFileInfoObjs[i].FileName + "(" + attachFileInfoObjs[i].Size + "), ";
		}
		strReturn = strReturn.substring(0, strReturn.length-2);
	}
	$("#FILEATTACH").html(strReturn);
}

function fn_DisplayDivField(obj) {
    var objNm = "divField_" + obj.id.split("_")[1];
    var divObj = document.getElementsByTagName("div");
    for (var i = 0; i < divObj.length; i++) {
        if (divObj[i].id.indexOf("divField") > -1) {
            if (objNm == divObj[i].id) {
                divObj[i].style.display = "";
            }
            else {
                divObj[i].style.display = "none";
            }
        }
    }
}

// 제목 저장
function updateSubjectNm(){
	var SubjecNm = $("#txtSUBJECT").val();
	//
	if(SubjecNm == ""){
		parent.Common.Warning("<spring:message code='Cache.msg_apv_028' />");		//제목을 입력하세요
	}else{
		$.ajax({
			url:"updateDocData.do",
			type:"post",
			data:{
				"dataType" : "Subject",
				"SubjecNm":SubjecNm ,
				"FormInstID":FormInstID
				},
			async:false,
			success:function () {
				refresh();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("updateDocData.do", response, status, error);
			}
		});
	}
}

//기밀여부 변경 저장
function updateSecureDoc(){
	var DocYn = $("#txtSECDOC").val();
	//
	if(DocYn == ""){
		parent.Common.Warning("<spring:message code='Cache.msg_apv_ValidationSecure' />");		//기밀여부를 선택해주세요.
	}else{
		$.ajax({
			url:"updateDocData.do",
			type:"post",
			data:{
				"dataType" : "IsSecureDoc",
				"DocYn":DocYn ,
				"FormInstID":FormInstID
				},
			async:false,
			success:function () {
				refresh();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("updateDocData.do", response, status, error);
			}
		});
	}
}

//문서번호 변경 저장
function updateDocNo(){
	var DocNo = $("#txtDOCNO").val();
	//
	if(DocNo == ""){
		parent.Common.Warning("<spring:message code='Cache.msg_apv_ValidationDocNum' />");		//문서번호를 입력하세요.
	}else{
		$.ajax({
			url:"updateDocData.do",
			type:"post",
			data:{
				"dataType" : "DocNo",
				"DocNo":DocNo ,
				"FormInstID":FormInstID
				},
			async:false,
			success:function () {
				refresh();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("updateDocData.do", response, status, error);
			}
		});
	}
}

//본문 변경 저장
function updateBodyContext(){
	var BodyContext = $("#txtBODYCONTEXT").val();
	//
	if(BodyContext == ""){
		parent.Common.Warning("<spring:message code='Cache.msg_apv_ValidationContext' />");		//본문내용을 입력하세요
	}else{
		parent.Common.Confirm("<spring:message code='Cache.msg_apv_KeepJSONObject' />", "Confirmation Dialog", function (result) {
			if(result){
				$.ajax({
					url:"updateDocData.do",
					type:"post",
					data:{
						"dataType" : "BodyContext",
						"BodyContext": Base64.utf8_to_b64(BodyContext),
						"FormInstID":FormInstID
						},
					async:false,
					success:function () {
						refresh();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("updateDocData.do", response, status, error);
					}
				});
			}
		});
	}
}

//연결문서 변경 저장
function updateDocLinks(){
	var DocLinks = $("#txtDOCLINKS").val();
	//
	if(DocLinks == ""){
		parent.Common.Warning("<spring:message code='Cache.msg_apv_ValidationLinkDoc' />");		//연결문서 내용을 입력하세요
	}else{
		$.ajax({
			url:"updateDocData.do",
			type:"post",
			data:{
				"dataType" : "DocLinks",
				"DocLinks": DocLinks,
				"FormInstID":FormInstID
				},
			async:false,
			success:function () {
				refresh();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("updateDocData.do", status, error);
			}
		});
	}
}

//첨부파일 변경 저장
function updateAttachFileInfo(){
	var AttachFileInfo = $("#txtFILEATTACH").val();
	//
	if(AttachFileInfo == ""){
		parent.Common.Warning("<spring:message code='Cache.msg_apv_ValidationFile' />");		//"첨부파일 내용을 입력하세요"
	}else{
		parent.Common.Confirm("<spring:message code='Cache.msg_apv_KeepJSONObject' />", "Confirmation Dialog", function (result) {
			if(result){
				$.ajax({
					url:"updateDocData.do",
					type:"post",
					data:{
						"dataType" : "AttachFileInfo",
						"AttachFileInfo": Base64.utf8_to_b64(AttachFileInfo),
						"FormInstID":FormInstID
						},
					async:false,
					success:function () {
						refresh();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("updateDocData.do", response, status, error);
					}
				});
			}
		});
	}
}

//팝업 닫기
function closeLayer(){
	Common.Close();
}

//새로고침
function refresh(){
	//CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	window.parent.location.reload();
}
</script>
<form>
<div class="sadmin_pop">
	<div align="left">
		<a id="btn_markingRollBack" class="btnTypeDefault" onclick="markingRollBack();" style="display:none"><spring:message code="Cache.lbl_apv_rollback_doc"/></a> <!-- 문서 복원 -->
		<a id="btn_delMarking" class="btnTypeDefault" onclick="deleteMarkingDel();"><spring:message code="Cache.lbl_apv_delete_marking"/></a> <!-- 문서 삭제마킹 -->
		<a id="btn_allDelete" class="btnTypeDefault" onclick="deleteClearDel();"><spring:message code="Cache.lbl_apv_deleted_doc"/></a> <!-- 문서 완전 삭제 -->
	</div>
	<div style="margin-top: 10px">
		<table class="sadmin_table sa_menuBasicSetting">
			<tr>
				<th width="10%" >작성자</th>
				<td width="15%" > <span id="INITIATOR_NAME"></span></td>
				<th width="12%" >작성부서</th>
				<td width="15%" > <span id="INITIATOR_OU_NAME"></span></td>
				<th width="12%" >작성일자</th>
				<td width="13%" > <span id="INITIATE_DATE"></span></td>
				<th width="10%" >상태</th>
				<td width="13%" > <font color="red"><span id="STATE" style="font-weight:bold;"></span></font></td>
			</tr>
		</table>
	</div>
    <div style="margin-top: 10px; margin-bottom: 10px">
          <table class="sadmin_table sa_menuBasicSetting">
          	<colgroup>
          		<col style="width: 15%">
          		<col style="width: 35%">
          		<col style="width: 15%">
          		<col style="width: 35%">
          	</colgroup>
              <tr>
                  <th><a id="bta_Subject" onclick="fn_DisplayDivField(this)"><b>제목</b></a></th>
                  <td><span id="SUBJECT" style="word-break:break-all;"></span></td>
                  <th><a id="bta_DocNum" onclick="fn_DisplayDivField(this)"><b>문서번호</b></a></th>
                  <td><span id="DOCNUM"></span></td>
              </tr>
              <tr>
                  <th><a id="bta_BODYCONTEXT" onclick="fn_DisplayDivField(this)"><b>본문</b></a></th>
                  <td><span id="BODYCONTEXT"></span></td>
                  <th><a id="bta_SecDoc" onclick="fn_DisplayDivField(this)"><b>기밀여부</b></a></th>
                  <td><span id="SECDOC"></span></td>
              </tr>
              <tr id="trAttachDocLink">
                  <th><a id="bta_FileAttach" onclick="fn_DisplayDivField(this)"><b>첨부파일</b></a></th>
                  <td><span id="FILEATTACH" style="word-break:break-all;"></span></td>
                  <th><a id="bta_DocLinks" onclick="fn_DisplayDivField(this)"><b>연결문서</b></a></th>
                  <td><span id="DOCLINKS" style="word-break:break-all;"></span></td>
              </tr>
          </table>
    </div>
   	<div id="divField_Subject" style="text-align:center;display:none;">
         <table class="sadmin_table sa_menuBasicSetting" align="center">
         	<colgroup>
         		<col style="width: 15%">
         		<col width ="*">
         		<col width ="15%">
         	</colgroup>
             <tr>
                 <th>제목</th>
                 <td><input name="txtSUBJECT" type="text" id="txtSUBJECT" style="width:98%" /></td>
                 <td><input type="button" class="AXButton"  id="btSubject" onclick="updateSubjectNm();" value="<spring:message code="Cache.btn_apv_save"/>"></td>
             </tr>
             <tr>
                 <th>설명</th>
                 <td colspan="2">제목 변경시 기안부서 뿐만 아니라, 배포처문서의 제목까지 모두 변경됩니다.</td>
             </tr>
         </table>
	</div>

 	<div id="divField_BODYCONTEXT" style="text-align:center;display:none;">
            <table class="sadmin_table sa_menuBasicSetting" align="center">
            	<colgroup>
         		<col width ="15%">
         		<col width ="*">
         		<col width ="15%">
            	</colgroup>
                <tr>
                    <th>본문</th>
                    <td><textarea name="txtBODYCONTEXT" rows="10" id="txtBODYCONTEXT" json-value='true' style="width:98%;"></textarea></td>
                    <td><input type="button" class="AXButton"  id="btBODYCONTEXT" onclick="updateBodyContext();" value="<spring:message code="Cache.btn_apv_save"/>"></td>
                </tr>
                <tr>
                    <th>설명</th>
                    <td colspan="2">결재문서 본문정보 중 BODYCONTEXT 컬럼에 해당하는 정보를 수정하여 업데이트할 수 있습니다.<br />만약 그 외의 DFIELD값에 대한 변경을 원하면 데이터베이스에서 직접 수정이 필요합니다.</td>
                </tr>
            </table>
	</div>
	<div id="divField_FileAttach" style="text-align:center;display:none;">
        	<table class="sadmin_table sa_menuBasicSetting" align="center">
	        	<colgroup>
	         		<col width ="15%">
	         		<col width ="*">
	         		<col width ="15%">
	            </colgroup>
                <tr height="100px">
                    <th>첨부파일</th>
                    <td>
                    	<textarea name="txtFILEATTACH" rows="10" id="txtFILEATTACH" style="width:98%;" json-value='true'></textarea>
                    </td>
                    <td>
                    	<input type="button" class="AXButton"   id="btFILEATTACH" onclick="updateAttachFileInfo();" value="<spring:message code="Cache.btn_apv_save"/>">
                    </td>
                </tr>
                <tr>
                    <th>설명</th>
                    <td colspan="2">첨부된 파일 수정이 되는 것이 아니고, AttachFileInfo 데이터만 수정됩니다. <br />첨부파일을 수정하려면 양식을 열어서 편집모드로 수정하시기 바랍니다.</td>
                </tr>
            </table>
	</div>
	<div id="divField_DocLinks" style="text-align:center;display:none;">
            <table class="sadmin_table sa_menuBasicSetting" align="center" >
            	<colgroup>
	         		<col width ="15%">
	         		<col width ="*">
	         		<col width ="15%">
            	</colgroup>
                <tr>
                    <th>연결문서</th>
                    <td><textarea name="txtDOCLINKS" rows="10" id="txtDOCLINKS" style="width:98%;"></textarea></td>
                    <td><input type="button" class="AXButton"  id="btDOCLNKS" onclick="updateDocLinks();" value="<spring:message code="Cache.btn_apv_save"/>"></td>
                </tr>
                <tr>
                    <th>설명</th>
                    <td colspan="2">연결문서의 규칙에 맞게 수동으로 변경한 후 저장합니다. ( @@@ 와 &#94;&#94;&#94; 는 구분자에 해당합니다. )</td>
                </tr>
            </table>
	</div>
	<div id="divField_SecDoc" style="text-align:center;display:none;">
            <table class="sadmin_table sa_menuBasicSetting" align="center" >
           		<colgroup>
	         		<col width ="15%">
	         		<col width ="*">
	         		<col width ="15%">
            	</colgroup>
                <tr>
                    <th>기밀문서</th>
                    <td>
                        <select name="txtSECDOC" id="txtSECDOC" style="width:70px;">
							<option value="N">일반</option>
							<option value="Y">기밀</option>
						</select>
                    </td>
                    <td><input type="button" class="AXButton"  id="A5" onclick="updateSecureDoc();" value="<spring:message code="Cache.btn_apv_save"/>"></td>
                </tr>
                <tr>
                    <th>설명</th>
                    <td colspan="2" >[일반],[기밀]을 선택할 수 있으며, 이 값을 변경하는 것은 이미 만들어진 부서함목록에는 영향이 없으며, 문서를 오픈할 때 접근 가능한 사용자인지를 체크할 때만 이용됩니다.</td>
                </tr>
            </table>
	</div>
	<div id="divField_DocNum" style="text-align:center;display:none;">
            <table class="sadmin_table sa_menuBasicSetting" align="center">
            	<colgroup>
	         		<col width ="15%">
	         		<col width ="*">
	         		<col width ="15%">
            	</colgroup>
                <tr>
                    <th >문서번호</th>
                    <td><input name="txtDOCNO" type="text" id="txtDOCNO" style="width:98%;" /></td>
                    <td><input type="button" class="AXButton"  id="btDocno" onclick="updateDocNo();" value="<spring:message code="Cache.btn_apv_save"/>"></td>
                </tr>
                <tr>
                    <th>설명</th>
                    <td colspan="2">문서번호는 결재가 종료된 문서에서만, 변경 가능합니다.</td>
                </tr>
            </table>
	</div>
	<input type="hidden" id="ProcessID" value="" />
</div>
</form>