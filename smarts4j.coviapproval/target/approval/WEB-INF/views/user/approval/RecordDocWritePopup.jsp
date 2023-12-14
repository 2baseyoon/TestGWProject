<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/approval/resources/script/forms/WebEditor_Approval_HWP.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Hwp/HwpToolbars.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Hwp/HwpCtrl.js<%=resourceVersion%>"></script>

<head>
<title></title>
</head>
<body>
	<div class="layer_divpop ui-draggable schPopLayer">
		<div class="divpop_contents" style="padding: 10px;">
			<div class="pop_header" name="default_info">
				<h4 class="divpop_header ui-draggable-handle"><span class="divpop_header_ico">기본 등록사항</span></h4>
			</div>
			<table class="table_3 tableStyle linePlus mt10" cellpadding="0" cellspacing="0" name="default_info">
				<colgroup>
					<col style="width: 20%">
					<col style="width: 30%">
					<col style="width: 20%">
					<col style="width: 30%">
				</colgroup>
				<tr>
					<th><font color="red">* </font>제목</th>
					<td colspan="3"><input type="text" style="width: 98%;" id="TITLE" name="inputDataField" required></td>
				</tr>
				<tr>		
					<th>시행일자</th>
					<td><input type="text" class="calendar_picker" style="width: 90%;" id="COMPLETEDATE" name="inputDataField" maxlength="8" readonly></td>		
					<th><font color="red">* </font>등록구분</th>
					<td><select id="REGISTCHECK" name="inputDataField" cdgrp="RegistCheck" required></select></td>
				</tr>
				<tr>
					<th><font color="red">* </font>처리과기관코드</th>
					<td><input type="text" style="width: 98%;" id="RECORDDEPTCODE" name="inputDataField" disabled="disabled"></td>
					<th><font color="red">* </font>기록물생산기관명</th>
					<td>
						<input type="text" style="width: 80%;" id="RECORDPRODUCTNAME" name="inputDataField" disabled="disabled" required>
						<input type="button" class="AXButton" id="btSelectRecord" onclick="openOrgPopup();" value="선택">
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font>생산(접수)등록번호</th>
					<td><input type="text" style="width: 98%;" id="PRODUCTNUM" name="inputDataField" required></td>
					<th><font color="red">* </font>생산(접수)등록일자</th>
					<td><input type="text" class="calendar_picker" style="width: 90%;" id="PRODUCTDATE" name="inputDataField" maxlength="12" readonly required></td>
				</tr>
				<tr>
					<th>생산기관등록번호</th>
					<td><input type="text" style="width: 98%;" id="RECORDSEQ" name="inputDataField"></td>
					<th>기록물문서번호</th>
					<td><input type="text" style="width: 98%;" id="OLDPRODUCTNUM" name="inputDataField"></td>
				</tr>
				<!-- 
				<tr>
					<th>분리등록번호(첨부번호)</th>
					<td><input type="text" style="width: 98%;" id="ATTACHNUM" name="inputDataField" maxlength="2" ></td>
					<th>쪽수</th>
					<td><input type="text" style="width: 98%;" id="RECORDPAGECOUNT" name="inputDataField" maxlength="6" ></td>
				</tr>
				-->
				<tr>
					<th>기안자(업무담당자)</th>
					<td><input type="text" style="width: 98%;" id="PROPOSALNAME" name="inputDataField"></td>
					<th>결재권자(직위/직급)</th>
					<td><input type="text" style="width: 98%;" id="APPROVALNAME" name="inputDataField"></td>
				</tr>
				<tr>
					<th>수신자(발신자)</th>
					<td><input type="text" style="width: 98%;" id="RECEIPTNAME" name="inputDataField"></td>
					<th>문서과배부번호</th>
					<td><input type="text" style="width: 98%;" id="DISTNUM" name="inputDataField" maxlength="6"></td>
				</tr>
				<tr>
					<th>전자기록물 여부</th>
					<td><select id="RECORDCHECK" name="inputDataField" cdgrp="RecordCheck"></select></td>
					<th>기록물구분(신/구)</th>
					<td><select id="RECORDCLASS" name="inputDataField" cdgrp="RecordClass"></select></td>
				</tr>
			</table>
			
			<br>
			
			<div class="pop_header" name="record_info">
				<h4 class="divpop_header ui-draggable-handle"><span class="divpop_header_ico">기록물철 등록사항</span></h4>
			</div>
			<table class="table_3 tableStyle linePlus mt10" cellpadding="0" cellspacing="0" name="record_info">
				<colgroup>
					<col style="width: 20%">
					<col style="width: 30%">
					<col style="width: 20%">
					<col style="width: 30%">
				</colgroup>
				<tr>
					<th><font color="red">* </font>분류번호</th>
					<td><input type="text" id="RECORDCLASSNUM" name="inputDataField" style="width: 98%;" disabled="disabled"></td>
					<th><font color="red">* </font>기록물철명</th>
					<td>
						<input type="text" id="RECORDSUBJECT" name="inputDataField" style="width: 80%;" disabled="disabled" required>
						<input type="button" class="AXButton" id="btSelectRecord" onclick="openSelectRecordPopup();" value="선택">
					</td>
				</tr>
				<tr>
					<th>특수기록물</th>
					<td><select id="SPECIALRECORD" name="inputDataField" cdgrp="SpecialRecord"></select></td>
					<th>보존기간</th>
					<td><select id="KEEPPERIOD" name="inputDataField" cdgrp="KeepPeriod"></select></td>
				</tr>
				<tr>
					<th>공개여부</th>
					<td>
						<select id="RELEASECHECK" name="inputDataField" cdgrp="ReleaseCheck" onchange="toggleCheckDiv();"></select>
						<div id="RELEASERESTRICTION" style="display: none;"></div>
					</td>
					<th>열람범위<br>(보안등급)</th>
					<td><select id="SECURELEVEL" name="inputDataField" cdgrp="SecureLevel"></select></td>
				</tr>
			</table>
			
			<br>
			
			<div class="pop_header" name="audiovisual_info">
				<h4 class="divpop_header ui-draggable-handle"><span class="divpop_header_ico">시청각기록물 추가 등록사항</span></h4>
			</div>
			<table class="table_3 tableStyle linePlus mt10" cellpadding="0" cellspacing="0" name="audiovisual_info">
				<colgroup>
					<col style="width: 20%">
					<col style="width: 30%">
					<col style="width: 20%">
					<col style="width: 30%">
				</colgroup>
				<tr>
					<th>내용요약</th>
					<td><input type="text" id="CONTENTSUMMARY" name="inputDataField" style="width: 98%;"></td>
					<th>기록물형태</th>
					<td><input type="text" id="RECORDTYPE" name="inputDataField" style="width: 98%;"></td>
				</tr>
			</table>
			
			<br>
			
			<div class="pop_header" name="add_info">
				<h4 class="divpop_header ui-draggable-handle"><span class="divpop_header_ico">부가 정보</span></h4>
			</div>
			<table class="table_3 tableStyle linePlus mt10" cellpadding="0" cellspacing="0" name="add_info">
				<colgroup>
					<col style="width: 20%">
					<col style="width: 30%">
					<col style="width: 20%">
					<col style="width: 30%">
				</colgroup>
				<!-- 
				<tr>
					<th>수정여부</th>
					<td><select id="MODIFYCHECK" name="inputDataField" cdgrp="ModifyCheck"></td>
					<th>반려여부</th>
					<td><select id="REJECTCHECK" name="inputDataField" cdgrp="RejectCheck"></td>
				</tr>
				 -->
				<tr>
					<th>전자결재문서</th>
					<td colspan="3"><input type="text" id="APPROVALDOCLINK" name="inputDataField" style="width: 98%;"></td>
				</tr>
				<!-- 
				<tr>
					<th>파일경로</th>
					<td colspan="3"><input type="text" id="RECORDFILEPATH" name="inputDataField" style="width: 98%;display:none;">
					첨부파일 시작 작성페이지의 경우 첨부파일Uload UX 조회페이지 다운로드UX표시
						<div id="attachDiv">
							<table class="tableStyle linePlus">
							  <colgroup>
							  <col style="width:100%">
							  </colgroup>
							  <tbody>
							    <tr>
							      <td style="padding: 5px 10px 10px;">
							      		첨부파일 컨트롤 시작
							           	파일 컨트롤 타입 설정 : 0.None, 1.DEXTUploadX, 2.CoviFileTrans, 3.CoviSilverlightTrans, 4.CoviUploadNSlvTrans, 5.HTML 5
							            <div id="divFileControlContainer"></div>
							            <div style="width:0px; height:0px; float:right; overflow-x:hidden;">
							            	<input type="file" multiple name="FileSelect" id="FileSelect" onchange="javascript:FileSelect_onchange();" style="opacity:0;"/>
							            	<input type="submit" id="btnsubmit" style="display:none;"/>
							            	<input type="hidden" id="hidsaveFileName" />
							            	<input type="hidden" id="hidDeletFiles" name="inputDataField" />
							            </div>
							            </form>
							            <div class="addDataBtn">
							            	<input type="button" class="smButton" onclick="AddFile();" value="<spring:message code='Cache.btn_addfile'/>">
							            	<input type="button" class="smButton" onclick="RecordDeleteFile();clearDeleteFront();" value="<spring:message code='Cache.lbl_apv_file_delete'/>">
							            	<input id="webhardAttach" type="button" class="smButton" onclick="AddWebhardFile();" style="display:none;" value="<spring:message code='Cache.lbl_webhard'/>">
							            </div>
							            <div ondragenter="onDragEnter(event)" ondragover="onDragOver(event)" ondrop="onDrop(event)" style="min-height:125px;">
							             <div class="file_controls"  class="addData">
							             	<table id="tblFileList" class="fileHover">
							              	<colgroup>
							              		<col style="width:25px">
							              		<col style="width:25px">
							              		<col style="width:*">
							              		<col style="width:120px">
							              	</colgroup>
							               <tbody id = "fileInfo" style="background-color:white;">
							                	<tr id="trFileInfoBox" style="height:99%">
							                		<td colspan="4">
							                			<div class="dragFileBox"><span class="dragFile">icn</span><spring:message code="Cache.lbl_DragFile"/></div>
							                		</td>
							                	</tr>
							               </tbody>
							              </table>
							             </div>
							            </div>
							        </td>
							    </tr>
							    </tbody>
							</table>
							
							<input type="hidden" ID="hidFrontPath"/>
							<input type="hidden" ID="hidFileSize"/>
							<input type="hidden" ID="hidOldFile"/>
							<input type="hidden" ID="hidDeleteFront"/>
							<input type="hidden" ID="hidImageFile"/>
							<input type="hidden" ID="hidDeleteFile"/>
							<input type="hidden" ID="hidUseVideo" Value="N" />
							<input type="hidden" ID="hidFileSeq"/>
						</div>
						첨부파일 컨트롤 끝
					</td>
				</tr>
				-->
			</table>
			
			<div class="bottom">
				<a class="btnTypeDefault" href="javascript:doSave();">저장</a>
				<a class="btnTypeDefault" href="javascript:Common.Close();">닫기</a>
			</div>
		</div>	
	</div>
</body>

<script>

var doc_id = "${doc_id}";
var lang = Common.getSession("lang");

$(window).load(function () {
	var now =  new Date();
	var nowtime = AddFrontZero(now.getHours(), 2) + AddFrontZero(now.getMinutes(), 2);

	$(".calendar_picker").datepicker({
		dateFormat: 'yymmdd',
	    showOn: 'button',
	    buttonText : 'calendar',
	    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
        buttonImageOnly: true,
        onSelect: function(){ if(this.id == "PRODUCTDATE") this.value += nowtime}
	});
	
	setSelectBox();
	if(doc_id != "") {
		setSavedInfo();
	}
});

function setSelectBox() {
	var codeList = [];
	$("select").each(function(i, obj) {
		codeList.push($(obj).attr("cdgrp"));
	});
	
	Common.getBaseCodeList(codeList);
	
	for(var i = 0; i < codeList.length; i++) {
		var codeGroup = codeList[i];
		var codeMap = coviCmn.codeMap[codeGroup];
		
		var optHtml = "";
		if(codeMap[0].Code != "") { // 코드그룹 내 첫번째 코드가 빈값인 경우는 선택 option 필요 X
			optHtml += "<option value=''>선택</option>";
		}
		
		for(var j = 0; j < codeMap.length; j++) {
			optHtml += "<option value='"+codeMap[j].Code+"'>"+CFN_GetDicInfo(codeMap[j].MultiCodeName)+"</option>";
		}
		$("select[cdgrp="+codeGroup+"]").append(optHtml);
	}
	
	var checkHtml = "";
	for(var i = 1; i <= 8; i++) {
		checkHtml += "<input type='checkbox' name='ReleaseCheckField' id='RELEASECHECK_HO"+i+"'><label for='RELEASECHECK_HO"+i+"'> "+i+"호</label>&nbsp;&nbsp;";
		if(i == 4) {
			checkHtml += "<br/>";
		}
	}
	$("#RELEASERESTRICTION").html(checkHtml);
}

function setSavedInfo() {
	$.ajax({
		url	: "/approval/user/getRecordDocInfo.do",
		type: "POST",
		data: {
			"RecordDocumentID" : doc_id
		},
		success:function (data) {
			if(data.status == "SUCCESS" && data.data != 0){
				var docInfo = data.data.map[0];
				$("[name=inputDataField]").each(function(i, obj){
					var id = $(obj).attr("id");
					var savedVal = docInfo[id];
					
					if(id == "RELEASECHECK") {
						$(obj).val(savedVal.charAt(0));

						var hoArr = savedVal.substring(1).split('');
						for(var h = 1; h <= 8; h++) {
							if(hoArr[h-1] == "Y") {
								$("#RELEASECHECK_HO"+h).prop("checked", "checked");
							} else {
								$("#RELEASECHECK_HO"+h).prop("checked", false);
							}
						}
						
						toggleCheckDiv();
					} else if (id == "RECORDFILEPATH" && savedVal != ""){
						controlDisplaySetFIleInfo(savedVal);
						savedVal.forEach(function(data, idx){
							delete data.FileToken;
							delete data.FileID;
						});
						
						$(obj).val(JSON.stringify(savedVal));
					} else {
						$(obj).val(savedVal);
					}
				});	
			}else{
				Common.Error("오류가 발생했습니다. 관리자에게 문의 바랍니다.");
			}
		},
		error:function (error){
			Common.Error("오류가 발생했습니다. 관리자에게 문의 바랍니다.");
		}
	});
}

function openSelectRecordPopup() {
	var oApproveStep;
	var iHeight = 700; 
	var iWidth = 1050;
	var sUrl = "/approval/form/goRecordSelectPopup.do";
	var sSize = "scrollbars=yes,toolbar=no,resizable=yes";
	
	CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
}

function setRecord(returnObj) {
	$("#RECORDCLASSNUM").val(returnObj.RecordClassNum);
	$("#RECORDSUBJECT").val(returnObj.RecordSubject);
}

function openOrgPopup() {
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=setDept&type=C1",Common.getDic("lbl_apv_org"),1060,580,"");
}

function setDept(returnObj) {
	var deptJSON =  $.parseJSON(returnObj).item[0];
	
	$("#RECORDDEPTCODE").val(deptJSON.AN);
	$("#RECORDPRODUCTNAME").val(CFN_GetDicInfo(deptJSON.DN, lang));
}

function doSave() {
	var returnData = {};
	
	var ho = "";
	$("[name=ReleaseCheckField]").each(function(i, obj){
		ho += ($(obj)[0].checked ? "Y" : "N");
	});
	
	$("[name=inputDataField]").each(function(i, obj){
		var id = $(obj).attr("id");
		
		returnData[id] = $(obj).val();
		
		if(id == "REGISTCHECK") {
			if($(obj).find("option:selected").text().indexOf("접수") > -1) {
				returnData["DIVISIONTYPE"] = "DISTCOMPLETE";
			} else {
				returnData["DIVISIONTYPE"] = "COMPLETE";
			}
		}
		
		if(id == "RELEASECHECK" && $(obj).val() != "") {
			returnData[id] += ho;
		}
	});
	
	returnData["RowSeq"] = "1";
	
	if(!validationCheck()) return;
	
	//파일첨부
	var formData = new FormData();
	for (var i = 0; i < l_aObjFileList.length; i++) {
		typeof l_aObjFileList[i] === 'object' && formData.append("fileData_record[]", l_aObjFileList[i]);
    }
	
	formData.append("DocInfoParam", JSON.stringify(returnData));
	formData.append("RecordDocumentID", doc_id);

	
	$.ajax({
		type : "POST",
		data : formData,
		url	: "/approval/user/saveRecordDocInfo.do",
		async : false,
		dataType : 'json',
		processData : false,
		contentType : false,
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Inform(data.message, "Information", function(result){
					if(result){
						window.close();
					}
				});
			}else{
				Common.Error("오류가 발생했습니다. 관리자에게 문의 바랍니다.");
			}
		},
		error:function (error){
			Common.Error("오류가 발생했습니다. 관리자에게 문의 바랍니다.");
		}
	});
}

function toggleCheckDiv() {
	if($("#RELEASECHECK").val() == "" || $("#RELEASECHECK").val() == "1") {
		$("#RELEASERESTRICTION").hide();
	} else {
		$("#RELEASERESTRICTION").show();
	}
}

function validationCheck(){
	var WarningMessage = "<spring:message code='Cache.ACC_msg_case_2'/>";
	var msgArray = ["제목", "등록구분", "기록물생산기관명", "생산(접수)등록번호", "생산(접수)등록일자", "기록물철명"];
	var returnval = true;
	$("[required]").each(function(i, obj){
		if ($(obj).val() == "" ){
			WarningMessage = WarningMessage.replace("{0}",msgArray[i]);
			alert(WarningMessage);
			returnval = false;
			return false;
		}
	});
	return returnval;
}

//편집모드일 경우, 기존 파일 정보를 첨부파일 컨트롤 화면에 세팅
function controlDisplaySetFIleInfo(filedata) {
	var fileInfoHtml = "";
	var fileInfos = filedata;

	if (fileInfos.length > 0) {
		$("#trFileInfoBox").hide();

		$(fileInfos).each(function(i, fileInfoObj) {
			var l_FileExt = fileInfoObj.name.substring(fileInfoObj.name.lastIndexOf(".") + 1).toLowerCase();
			var className = setFileIconClass(l_FileExt);
			
			fileInfoHtml += "<tr>";
			fileInfoHtml += '<td><input name="chkFile" type="checkbox" value="' + "_"+i + ":" + $$(fileInfoObj).attr("name") + ":OLD:" + $$(fileInfoObj).attr("savedname") + ":" + $$(fileInfoObj).attr("size") + '" class="input_check"></td>';
			fileInfoHtml += '<td><span class=' + className + '>파일첨부</span></td>';
			fileInfoHtml += "<td>" + $$(fileInfoObj).attr("name") + "</td>";
			fileInfoHtml += '<td class="t_right">' + ConvertFileSizeUnit($$(fileInfoObj).attr("size")) + '</td>';
			fileInfoHtml += "</tr>";
		});

		$("#fileInfo").html(fileInfoHtml);
	}
	if(fileInfos.length > 0) setSeqInfo();
}

function RecordDeleteFile() {
	var l_selObj = document.getElementById("fileInfo");
	var l_chk = document.getElementsByName("chkFile");

	if (l_chk.length <= 0) {
		return;
	}

	for (var i = l_chk.length - 1; i > -1; i--) {
		if (l_chk[i].checked) {
			document.getElementById("hidDeletFiles").value += l_chk[i].value.split(":")[1] + "|"; // 선택한 파일명

			if (l_chk[i].value.split(":")[2] == "OLD") {
				document.getElementById("hidDeleteFile").value += l_chk[i].value.split(":")[1] + "|";
			}

			l_selObj.deleteRow(i);
			if (l_selObj.rows.length < 1) {
				var l_oRow = l_selObj.insertRow(l_selObj.rows.length);
				l_oRow.setAttribute("id", "trFileInfoBox");
				l_oRow.setAttribute("height", "99%");

				var l_oCell_1 = l_oRow.insertCell(l_oRow.cells.length);
				l_oCell_1.innerHTML = '<td><div class="dragFileBox"><span class="dragFile">icn</span>' + Common.getDic("lbl_DragFile") + '</div></td>';
				l_oCell_1.setAttribute("colspan", "4");
				l_selObj.appendChild(l_oRow); //상단에서 객체 insertRow로 이미 추가됨
			}
		}
	}

	// 삭제한 파일
	var sDeletFiles = document.getElementById("hidDeletFiles").value.split("|");
	var nLength = sDeletFiles.length;

	for (var i = 0; i < nLength - 1; i++) {
		for (var j = 0; j < l_aObjFileList.length; j++) {
			if (sDeletFiles[i] == l_aObjFileList[j].name) {
				l_aObjFileList.splice(j, 1);
				break;
			}
		}
	}

	var sFileInfo = "";
	var sFileInfoTemp = "";
	for (var i = 0; i < l_aObjFileList.length; i++) {
		sFileInfo += l_aObjFileList[i].name + ":" + l_aObjFileList[i].size + ":NEW:0:|";
		sFileInfoTemp += l_aObjFileList[i].name + ":" + l_aObjFileList[i].name.split('.')[l_aObjFileList[i].name.split('.').length - 1] + ":" + l_aObjFileList[i].size + "|";
	}
	document.getElementById("fileInfo").value = sFileInfo;
	document.getElementById("hidFileSize").value = sFileInfoTemp;

	//수정 부분 강제 change
	if (_ie) {
		var temp_input = $(document.getElementById("FileSelect"));
		temp_input.replaceWith(temp_input.val('').clone(true));
	} else {
		document.getElementById("FileSelect").value = "";
	}
	$("#FileSelect").change();
	
	setSeqInfo();
}
</script>