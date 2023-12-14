<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<head>
    <title></title>
</head>
<body>
    <div class="layer_divpop ui-draggable schPopLayer" style="width: 600px;">
        <div class="divpop_contents">
            <div class="pop_header">
                <h4 class="divpop_header ui-draggable-handle" id="popupTitle"><span class="divpop_header_ico"><spring:message code='Cache.lbl_AttachList'/></span></h4>
            </div>
            <div>
                <!-- 첨부파일 컨트롤 시작 -->
                <!-- 파일 컨트롤 타입 설정 : 0.None, 1.DEXTUploadX, 2.CoviFileTrans, 3.CoviSilverlightTrans, 4.CoviUploadNSlvTrans, 5.HTML 5 -->
                <div id="divFileControlContainer"></div>
                <div style="width: 0px; height: 0px; float: right; overflow-x: hidden;">
                    <input type="file" multiple name="FileSelect" id="FileSelect" onchange="javascript:FileSelect_onchangeMulti();" style="opacity: 0;" />
                    <input type="submit" id="btnsubmit" style="display: none;" />
                    <input type="hidden" id="hidsaveFileName" />
                    <input type="hidden" id="hidDeletFiles" />
                </div>
                <div class="addDataBtn">
                    <input type="button" class="smButton" onclick="AddFileMulti();" value="<spring:message code='Cache.btn_addfile'/>">
                    <input type="button" class="smButton" onclick="DeleteFileMulti(); clearDeleteFrontMulti();" value="<spring:message code='Cache.lbl_apv_file_delete'/>">
                </div>
                <div ondragenter="onDragEnterMulti(event)" ondragover="onDragOverMulti(event)" ondrop="onDropMulti(event)" style="min-height: 125px;">
                    <div class="file_controls" class="addData">
                        <table id="tblFileList" class="fileHover">
                            <colgroup>
                                <col style="width: 20px">
                                <col style="width: 20px">
                                <col style="width: *">
                                <col style="width: 120px">
                            </colgroup>
                            <tbody id="fileInfo" style="background-color: white;">
                                <tr id="trFileInfoBox" style="height: 99%">
                                    <td colspan="4">
                                        <div class="dragFileBox"><span class="dragFile">icn</span><spring:message code="Cache.lbl_DragFile" /></div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="bottom">
					<input type="hidden" id="fileInfoText" style="width: 99%; text-align: left;" />
                    <a class="btnTypeDefault" href="javascript:formDisplaySetFileInfoMulti();">확인</a>
                    <a class="btnTypeDefault" href="javascript:Common.Close();">닫기</a>
                </div>
            </div>
        </div>
    </div>
</body>

<script>
	var ItemIdx =  CFN_GetQueryString("idx")=="undefined"? "":CFN_GetQueryString("idx");

	var l_aObjFileList = [];
	var form_filesObj = [];

	initContent();

	function initContent(){
		if(opener.document.getElementById("fileInfo" + ItemIdx).value != ""){
			DrawTableMultiBind(opener.document.getElementById("fileInfo" + ItemIdx).value);
		}
	}
  
	// --------------------------------------------- 첨부파일 컨트롤 -------------------------------------------------------
	/**
	 * 1. 개발지원에 있는 첨부파일 컨트롤 HTML 사용
	 * 2. 스크립트단은 아래 함수들로 실행됨
	 * 3. 서버단에서는 개발지원에 있는 submit 함수를 이용해서 컨트롤에서 Request에 있는 MultipartFile 로 받아서 처리.
	 * 4. 컨트롤에서는 FileUtil.fileUpload 함수이용해서 첨부파일 저장
	*/
	
	// 파일추가 버튼
	function AddFileMulti() {
		// Iframe FileControl의 파일추가 버튼 클릭
		document.getElementById("FileSelect").click();
	}

	//Iframe의 파일 컨트롤 값이 입력될때(파일 선택 시)
	function FileSelect_onchangeMulti() {
    	// 파일 선택 시 파일명 중복 검사
		var nLength = document.getElementById("FileSelect").files.length;
		var oFileInfo = document.getElementById("FileSelect").files;
		var bCheck = false;
		var bCheck2 = false;
		var aObjFiles = [];

		if (l_aObjFileList.length == 0 && form_filesObj.length == 0) {
			readfilesMulti(document.getElementById("FileSelect").files);
			SetFileInfoMulti(document.getElementById("FileSelect").files);
		} else {
			for (var i = 0; i < nLength; i++) {
				for (var j = 0; j < l_aObjFileList.length; j++) {
                	if (oFileInfo[i].name == l_aObjFileList[j].name) { // 중복됨
                    	bCheck = true;
                    	parent.Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
                    	break;
                	} else { // 중복안됨
                    	bCheck = false;
                	}
            	}
            	for (var k = 0; k < form_filesObj.length; k++) {
                	if (oFileInfo[i].name == form_filesObj[k].name) { // 중복됨
                		bCheck2 = true;
                    	parent.Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
                    	break;
               		} else { // 중복안됨
                		bCheck2 = false;
                	}
            	}
            	if (!bCheck && !bCheck2) {
                	aObjFiles.push(oFileInfo[i]);
            	}
        	}
        	readfilesMulti(aObjFiles);
        	SetFileInfoMulti(aObjFiles);
    	}
	}

	// onDragEnter Event
	function onDragEnterMulti(event) {
	    event.preventDefault();
	}
	
	// onDragOver Event
	function onDragOverMulti(event) {
	    event.preventDefault();
	}
	
	// Drop Event
	function onDropMulti(event) {
	    var file = event.dataTransfer.files;
	    var aObjFileList = new Array();
	    aObjFileList = event.dataTransfer.files;
	
	    event.stopPropagation();
	    event.preventDefault();
	
	    // 파일 선택 시 파일명 중복 검사
	    var nLength = aObjFileList.length;
	    var oFileInfo = aObjFileList;
	    var bCheck = false;
	    var bCheck2 = false;
	    var aObjFiles = [];
	
	    if (l_aObjFileList.length == 0 && form_filesObj.length == 0) {
	        readfilesMulti(aObjFileList);
	        SetFileInfoMulti(aObjFileList);
	    } else {
	        for (var i = 0; i < nLength; i++) {
	            for (var j = 0; j < l_aObjFileList.length; j++) {
	                if (oFileInfo[i].name == l_aObjFileList[j].name) { // 중복됨
	                    bCheck = true;
	                    Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
	                    break;
	                } else { // 중복안됨
	                    bCheck = false;
	                }
	            }
	            for (var k = 0; k < form_filesObj.length; k++) {
	                if (oFileInfo[i].name == form_filesObj[k].name) { // 중복됨
	               		bCheck2 = true;
	                    parent.Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
	                    break;
	                } else { // 중복안됨
	               		bCheck2 = false;
	                }
	            }
	            if (!bCheck && !bCheck2) {
	                aObjFiles.push(oFileInfo[i]);
	            }
	        }
	        readfilesMulti(aObjFiles);
	        SetFileInfoMulti(aObjFiles);
	    }
	}
	
	// 파일정보 배열(l_aObjFileList)에 추가
	function readfilesMulti(files) {
	    for (var i = 0; i < files.length; i++) {
	        l_aObjFileList.push(files[i]);
	    }
	}
	
	 //파일 정보 히든필드에 셋팅
	 function SetFileInfoMulti(pObjFileInfo) {
	     var aObjFileInfo = new Array();
	     aObjFileInfo = pObjFileInfo;
	     var sFileInfo = "";
	     var sFileInfoTemp = "";
	     var nLength = aObjFileInfo.length;
	     for (var i = 0; i < nLength; i++) {
	         sFileInfo += aObjFileInfo[i].name + ":" + aObjFileInfo[i].size + ":" + "NEW" + ":" + "0" + ":" + "|";
	
	         // hidFileSize 값 셋팅
	         sFileInfoTemp += aObjFileInfo[i].name + ":" + aObjFileInfo[i].name.split(',')[aObjFileInfo[i].name.split(',').length - 1] + ":" + aObjFileInfo[i].size + "|";
	     }
	
	     // 유효성 검사를 위해 부모창의 히든필드에 값 셋팅
	  	 if (document.getElementById("fileInfoText") != null)
	      	 document.getElementById("fileInfoText").value += sFileInfo;
	
	     if (document.getElementById("fileInfo").value == null) {
	         document.getElementById("fileInfo").value = "";
	     }
	     document.getElementById("fileInfo").value += sFileInfo;
	     opener.document.getElementById("hidFileSize").value += sFileInfoTemp;
	
	     // 목록에 바인딩
	     DrawTableMulti(pObjFileInfo);
	     //formDisplaySetFileInfoMulti(sFileInfo);
	}
	
	// 첨부파일 정보 Row 추가
	function DrawTableMultiBind(sFileInfo) {
		document.getElementById("fileInfoText").value = sFileInfo;
	    var l_selObj = document.getElementById("fileInfo");
	     
	    form_filesObj = new Array();
	    var form_fileinfo = null;
	     
	    var l_arrFile = "";
	    if (sFileInfo != "" && sFileInfo != undefined)
	        l_arrFile = sFileInfo.split("|"); // 새 파일 정보
	    if (l_arrFile != "" && l_arrFile.length > 0) {
	        $("#trFileInfoBox").hide();
	    }
	    if (l_arrFile != "") {
	        if (l_selObj.rows[l_selObj.rows.length - 1].innerHTML.indexOf("colspan") > -1)
	            l_selObj.deleteRow(l_selObj.rows.length - 1); //기본 줄이 있을 경우 제거처리
	        for (var i = 0; i < l_arrFile.length - 1; i++) {
	            
	            var l_arrDetail = l_arrFile[i].split(':');
	            var l_oRow = l_selObj.insertRow(l_selObj.rows.length);
	 
	            form_fileinfo = new Object();
	            form_fileinfo.lastModifiedDate = null;
	            form_fileinfo.name = l_arrDetail[0];
	            form_fileinfo.size = l_arrDetail[1];
	            form_fileinfo.type = l_arrDetail[0].split('.').pop();
	            form_filesObj.push(form_fileinfo);
	
	            var l_oCell_1 = l_oRow.insertCell(l_oRow.cells.length);
	            l_oCell_1.innerHTML = '<input name="chkFile" type="checkbox" value="' + '_0' + ':' + l_arrDetail[0] + ':NEW' + ':' + l_arrDetail[1] + '" class="input_check">'; //+ l_arrDetail[3]
	
	            var l_oCell_2 = l_oRow.insertCell(l_oRow.cells.length);
	            l_oCell_2.innerHTML += '<span class=' + setFileIconClassMulti(l_arrDetail[0].split('.').pop()) + '>파일첨부</span>';
	
	            var l_oCell_3 = l_oRow.insertCell(l_oRow.cells.length);
	            l_oCell_3.innerHTML = l_arrDetail[0];
	
	            var l_oCell_4 = l_oRow.insertCell(l_oRow.cells.length);
	            l_oCell_4.innerHTML += ConvertFileSizeUnitMulti(l_arrDetail[1]);
	            l_oCell_4.className = "t_right";
	
	            l_selObj.appendChild(l_oRow); //상단에서 객체 insertRow로 이미 추가됨
	        }
	    }
	}
	 
	// 첨부파일 정보 Row 추가
	function DrawTableMulti(fileInfo) {
	    var aObjFileInfo = new Array();
	    aObjFileInfo = fileInfo;
	    var sFileInfo = "";
	
	    for (var l = 0; l < aObjFileInfo.length; l++) {
	        var sExtension = aObjFileInfo[l].name.split('.')[aObjFileInfo[l].name.split('.').length - 1];
	        var sFileName = aObjFileInfo[l].name;
	        var sFileSize = aObjFileInfo[l].size;
	         
	        var sFileType = "";
	        sFileInfo += sFileName + ":" + sExtension + ":" + sFileSize + "|"; //":" + sFilePath +
	    }
	     
	    var l_selObj = document.getElementById("fileInfo");
	    var l_arrFile = "";
	    if (sFileInfo != "" && sFileInfo != undefined)
	        l_arrFile = sFileInfo.split("|"); // 새 파일 정보
	    if (l_arrFile != "" && l_arrFile.length > 0) {
	        $("#trFileInfoBox").hide();
	    }
	    if (l_arrFile != "") {
	        if (l_selObj.rows[l_selObj.rows.length - 1].innerHTML.indexOf("colspan") > -1)
	            l_selObj.deleteRow(l_selObj.rows.length - 1); //기본 줄이 있을 경우 제거처리
	        for (var i = 0; i < l_arrFile.length - 1; i++) {
	            var l_arrDetail = l_arrFile[i].split(':');
	            var l_oRow = l_selObj.insertRow(l_selObj.rows.length);
	
	            var l_oCell_1 = l_oRow.insertCell(l_oRow.cells.length);
	            l_oCell_1.innerHTML = '<input name="chkFile" type="checkbox" value="' + '_0' + ':' + l_arrDetail[0] + ':NEW' + ':' + l_arrDetail[2] + '" class="input_check">'; //+ l_arrDetail[3]
	
	            var l_oCell_2 = l_oRow.insertCell(l_oRow.cells.length);
	            l_oCell_2.innerHTML += '<span class=' + setFileIconClassMulti(l_arrDetail[1]) + '>파일첨부</span>';
	
	            var l_oCell_3 = l_oRow.insertCell(l_oRow.cells.length);
	            l_oCell_3.innerHTML = l_arrDetail[0];
	
	            var l_oCell_4 = l_oRow.insertCell(l_oRow.cells.length);
	            l_oCell_4.innerHTML += ConvertFileSizeUnitMulti(l_arrDetail[2]);
	            l_oCell_4.className = "t_right";
	
	            l_selObj.appendChild(l_oRow); //상단에서 객체 insertRow로 이미 추가됨
	        }
	    }
	}
	
	// 부모창의 파일삭제 버튼 클릭 시 선택한 파일 제거
	function DeleteFileMulti() {
	    var l_selObj = document.getElementById("fileInfo");
	    //var l_selObj = opener.document.getElementById("fileInfo" + ItemIdx);
	    if($('input[name=chkFile]:Checked').length <= 0) return false;
	    var l_chk = document.getElementsByName("chkFile");
	    document.getElementById("hidDeletFiles").value = "";
	
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
	    for (var i = 0; i < nLength - 1; i++) {
	        for (var j = 0; j < l_aObjMultiFileList.length; j++) {
	            if (sDeletFiles[i] == l_aObjMultiFileList[j].name) {
	           		l_aObjMultiFileList.splice(j, 1);
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
	    document.getElementById("fileInfoText").value = sFileInfo;
	    //opener.document.getElementById("fileInfo" + ItemIdx).value = sFileInfo;
	    opener.document.getElementById("hidFileSize").value = sFileInfoTemp;
	
	    //수정 부분 강제 change
	    if (_ie) {
	        var temp_input = $(document.getElementById("FileSelect"));
	        temp_input.replaceWith(temp_input.val('').clone(true));
	    } else {
	        document.getElementById("FileSelect").value = "";
	    }
	    $("#FileSelect").change();
	}
	
	function clearDeleteFrontMulti() {
	    /// <summary>
	    /// Non ActiceX 에서 파일 추가, 삭제, 재추가시 첨부가 사라지는 문제점 해결
	    /// &#10; ( hidDeleteFront 컨트롤에서 값이 남아 있어서 문제가 됨. )
	    /// &#10; 값을 초기화 하여 조치. (2013-12-18 leesh)
	    /// </summary>
	
	    // ActiceX 인 경우에 첨부 UI 를 바로 업데이트 하지 않는다.(추가할때도 바로 업데이트가 안되므로 일관성 유지)
	    if (opener.document.getElementById("CoviUpload") == null) {
	        //setAttInfo();	// [2015-09-30 modi] 무조건 기안/임시저장/승인 등 저장행위시에만 UI에 추가되도록 수정
	    }
	
	    opener.document.getElementById("hidDeleteFront").value = "";
	}
	
	//파일 아이콘 class 타입 구별
	function setFileIconClassMulti(extention) {
	    var strReturn = "";
	
	    if (extention == "xls" || extention == "xlsx") {
	        strReturn = "exCel";
	    } else if (extention == "jpg" || extention == "JPG" || extention == "png" || extention == "PNG" || extention == "bmp") {
	        strReturn = "imAge";
	    } else if (extention == "doc" || extention == "docx") {
	        strReturn = "woRd";
	    } else if (extention == "ppt" || extention == "pptx") {
	         strReturn = "pPoint";
	    } else if (extention == "txt") {
	        strReturn = "teXt";
	    } else {
	        strReturn = "etcFile";
	    }
	
	    return strReturn;
	}
	
	// 파일 사이즈의 값 변환
	function ConvertFileSizeUnitMulti(pSize) {
	    var nSize = 0;
	    var sUnit = "Byte";
	
	    nSize = pSize;
	    if (nSize >= 1024) {
	        nSize = nSize / 1024;
	        sUnit = "KB";
	    }
	    if (nSize >= 1024) {
	        nSize = nSize / 1024;
	        sUnit = "MB";
	    }
	    if (nSize >= 1024) {
	        nSize = nSize / 1024;
	        sUnit = "GB";
	    }
	    if (nSize >= 1024) {
	        nSize = nSize / 1024;
	        sUnit = "TB";
	    }
	    sReturn = (Math.round(nSize) + (Math.round(nSize) - nSize)).toFixed(1) + sUnit;
	    return sReturn;
	}
	 
	 
	function formDisplaySetFileInfoMulti(sFileInfo) {
	
		var formAttachFileInfoObj = {};
		var objArr = new Array();
		var fileSeq = 0;
		
		if ($("[name=chkFile]").length > 0) {
			$("[name=chkFile]").each(function(i, checkObj) {
				var obj = {};
				var strArrObj = $(checkObj).val().split(":");
				
				if (strArrObj[2] == "OLD" || strArrObj[2] == "REUSE") {
					$(fileInfos).each(function(j, oldObj) {
						// 유지되는 파일은 파일정보를 그대로 가진다.
						if (oldObj.SavedName == strArrObj[3]) {
							objArr.push(oldObj);
							fileSeq++;
						}
					});
				} else if (strArrObj[2] == "NEW") {
					var strFormInstID = opener.getInfo("FormInstanceInfo.FormInstID") == undefined ? "" : opener.getInfo("FormInstanceInfo.FormInstID");
					
					$$(obj).append("ID", strFormInstID + "_" + fileSeq);
					$$(obj).append("FileName", strArrObj[1]);
					$$(obj).append("Type", strArrObj[2]);
					$$(obj).append("UserCode", opener.getInfo("AppInfo.usid"));
					$$(obj).append("Size", strArrObj[3]);
					
					objArr.push(obj);
				}
			});
		}
		
		if (objArr.length > 0) {
			$$(formAttachFileInfoObj).append("FileInfos", objArr);
			$("#AttachFileInfo").val(JSON.stringify($$(formAttachFileInfoObj).json()));
		} else {
			$("#AttachFileInfo").val("");
		}
		
		var fileInfoHtml = "";
		if(JSON.stringify($$(formAttachFileInfoObj).json()) != "" && JSON.stringify($$(formAttachFileInfoObj).json()) != "{}"){
			var fileInfos = $.parseJSON(JSON.stringify($$(formAttachFileInfoObj).json()));
		
			if (fileInfos.FileInfos.length > 0) {
				$(fileInfos.FileInfos).each(function(i, fileInfoObj) {
					var className = setFileIconClass($$(fileInfoObj).attr("Extention"));
					
					fileInfoHtml += "<dl class='excelData'><dt>";
					
					fileInfoHtml += "<span class='" + className + "'>파일첨부</span>";
					fileInfoHtml += $$(fileInfoObj).attr("FileName");
					fileInfoHtml += "<span>(" + ConvertFileSizeUnitMulti($$(fileInfoObj).attr("Size")) + ")</span>";
					
					fileInfoHtml += "</dt>";
					fileInfoHtml += "</dl>";
				});
		
				$(opener.document).find("#AttFileInfo" + ItemIdx).html(fileInfoHtml);
			}
		}
		else {
			$(opener.document).find("#AttFileInfo" + ItemIdx).html("");
		}
		if (opener.document.getElementById("fileInfo" + ItemIdx) != null)
		 opener.document.getElementById("fileInfo" + ItemIdx).value = document.getElementById("fileInfoText").value;
		if(opener.document.getElementsByName("MULTI_ATTACH_FILE")[ItemIdx] != null)
			opener.document.getElementsByName("MULTI_ATTACH_FILE")[ItemIdx].value = JSON.stringify($$(formAttachFileInfoObj).json());
		if(opener.document.getElementsByName("MULTI_FILE_SELECT")[ItemIdx] != null)
			opener.document.getElementsByName("MULTI_FILE_SELECT")[ItemIdx].files = document.getElementById("FileSelect").files;
		Common.Close();
	}
	
	// 체크박스 전체 선택 및 해제
	// 현재 함수를 사용하고 있지 않으며, 향후 수정하여 사용될 함수.
	var l_chkflag = "false";
	function CheckAllMulti() {
	    var l_chk = document.getElementsByName("chkFile");
	    if (l_chkflag == "false") {
	        for (i = 0; i < l_chk.length; i++) {
	            l_chk[i].checked = true;
	        }
	        l_chkflag = "true";
	    } else {
	        for (i = 0; i < l_chk.length; i++) {
	            l_chk[i].checked = false;
	        }
	        l_chkflag = "false";
	    }
	}
	
 	// 유효성 검사
	// 현재 함수를 사용하고 있지 않으며, 향후 수정하여 사용될 함수.
	function ChkIsValidationCheckMulti(pBoolRequired) {
	    // 파일의 전송 상태 Progress 창 팝업.    // [2015-08-07 han modi] 결재는 따로 프로그레스가 있고 시점도 다르므로 주석처리
	    //parent.Common.Progress("<span id='spanProgress'>" + Common.getDic("msg_Processing") + "<br /></span>"); // 다국어
	
	    if ('undefined' == typeof ($('#fileInfo').val()) || '' == $('#fileInfo').val()) { //파일 정보가 없는 경우 return
	        return true;
	    }
	
	    var l_arrFileList = document.getElementById("fileInfo").value.split("|"); // 컨트롤에 바인드된 파일들
	    var l_arrFileExtention = l_ExtenstionFileter.split("."); // 금지 확장자 목록
	    var l_cntFileList = 0; // 기존 파일 개수
	    var l_chkInsertFile = 0; // 새로 추가할 파일 개수
	    var l_OldFileList = ""; // 기존에 첨부된 파일
	
	    // 이미지 파일 첨부일 경우 체크 : OK
	    if ($("#hidImgCheck").val() != undefined) {
	        if ($("#hidImgCheck").val() == "1") {
	            for (var i = 0; i < l_arrFileList.length - 1; i++) {
	                var sImgname = l_arrFileList[i].split(":");
	                var aImgcheck = sImgname[0].substring(sImgname[0].lastIndexOf(".") + 1);
	                if (aImgcheck.toLowerCase() == "gif"
							|| aImgcheck.toLowerCase() == "jpg"
							|| aImgcheck.toLowerCase() == "jpeg"
							|| aImgcheck.toLowerCase() == "bmp"
							|| aImgcheck.toLowerCase() == "png") {
	                } else {
	                    parent.Common.Warning(Common.getDic("msg_OnlyImageFileAttach"));
	                    return false;
	                }
	            }
	        }
	    }
	
	    // 기존에 업로드한 파일 체크
	    if (document.getElementById("hidOldFile") != undefined) {
	        l_OldFileList = document.getElementById("hidOldFile").value;
	    }
	
	    var l_arrOldSplitList = l_OldFileList.split("|"); // 기존에 첨부한 파일
	    var l_arrDeleteFile = "";
	    var l_arrAddFileName = null;
	
	    // 기존에 추가된 것을 컨트롤에 바인드 하지 않고 체크(파일명만 입력되어 있음, 갯수 까지 체크함.)
	    if ($("#hidFileName") != null && $("#hidFileName") != undefined && $("#hidFileName").val() != "" && $("#hidFileName").val() != undefined) {
	        l_arrAddFileName = $("#hidFileName").val().split(":");
	    }
	
	    // 첨부파일 1개의 파일 사이즈 체크
	    opener.document.getElementById("hidFileSize").value = "";
	    for (var i = 0; i < l_arrFileList.length - 1; i++) {
	        var l_arrSplitList = l_arrFileList[i].split(":");
	        //document.getElementById("hidFileSize").value += l_arrSplitList[0] + ":" + l_arrSplitList[1] + "|";
	        opener.document.getElementById("hidFileSize").value += l_arrSplitList[0] + ":" + l_arrSplitList[0].split(".")[l_arrSplitList[0].split(".").length - 1] + ":" + l_arrSplitList[1] + "|";
	
	        // 팝업시 추가한 파일 중복 체크 : OK
	        if (l_arrSplitList[2] == "NEW") {
	            // 기존 추가 파일중 동일파일 체크 : OK
	            if (l_OldFileList) {
	                for (var j = 0; j < l_arrOldSplitList.length - 1; j++) {
	                    if (l_arrSplitList[0] == l_arrOldSplitList[j].split(":")[0]) {
	                        parent.Common.Warning(Common.getDic("msg_AIsAlreadyAdded").replace("{0}", l_arrSplitList[0]));
	                        return false;
	                    }
	                }
	            }
	
	        	// 기존 추가 파일중 동일파일 체크 : OK
	            if (l_arrAddFileName != null) {
	                for (var j = 0; j < l_arrAddFileName.length - 1; j++) {
	                    if (l_arrAddFileName[j] == l_arrSplitList[0]) {
	                        parent.Common.Warning(Common.getDic("msg_AIsAlreadyAdded").replace("{0}", l_arrSplitList[0]));
	                        return false;
	                    }
	                }
	            }
	        }
	
	        // 파일 사이즈 확인 : 파일사이즈가 0인것 확인 : OK
	        if (l_arrSplitList[2] == "NEW" && parseInt(l_arrSplitList[1], 10) < 1) {
	            parent.Common.Warning(Common.getDic("msg_NoUploadSizeZero"));
	            return false;
	        }
	
	        // 파일 사이즈 확인 : 제한 용량 보다 큰것 확인 : OK
	        if (l_arrSplitList[2] == "NEW" && parseInt(l_arrSplitList[1], 10) > l_MaxUnitSize) {
	            parent.Common.Warning(Common.getDic("msg_CanUploadLessThenMB").replace("{0}", g_LimitFileSize));
	            return false;
	        }
	
	        // 기존에 올라가 있던 파일중 삭제한것 목록
	        if (l_arrSplitList[2] == "DEL") {
	            document.getElementById("hidDeleteFile").value += l_arrSplitList[0] + "|"; // 삭제할 파일 아이디를 저장함.
	        } else {
	            // 파일 확장자 체크 : OK
	            if (document.getElementById("hidUseVideo") != null && document.getElementById("hidUseVideo").value == "Y") { // 동영상 게시인 경우 확장자 체크
	                var l_FileExt = l_arrSplitList[0].substring(l_arrSplitList[0].lastIndexOf(".") + 1).toUpperCase();
	                var l_VideoExt = Common.GetBaseConfig("EnableVideoExtention").toUpperCase();
	                if (l_VideoExt.indexOf(l_FileExt) == -1) {
	                    parent.Common.Warning(Common.getDic("msg_ExistLimitedExtensionFile"));
	                    return false;
	                }
	            } else {
	                for (var k = 0; k < l_arrFileExtention.length; k++) {
	                    if (l_arrSplitList[0].substring(l_arrSplitList[0].lastIndexOf(".") + 1).toUpperCase() == l_arrFileExtention[k].toUpperCase()) {
	                        parent.Common.Warning(Common.getDic("msg_ExistLimitedExtensionFile"));
	                        return false;
	                    }
	                }
	            }
	            // 파일명 금칙어 체크
	            if (Common.GetBaseConfig("FileNameFilter") != "") {
	                var l_arrLimitFileName = Common.GetBaseConfig("FileNameFilter").split(",");
	                for (var k = 0; k < l_arrLimitFileName.length; k++) {
	                    if (l_arrSplitList[0].indexOf(l_arrLimitFileName[k]) > -1) {
	                        parent.Common.Warning(Common.getDic("msg_ExistLimitedCharacterFileName").replace("{0}", Common.GetBaseConfig("FileNameFilter")));
	                        return false;
	                    }
	                }
	            }
	        }
	
	        // 기존 파일 개수(삭제된것 제외)  : OK
	        if (l_arrSplitList[2] == "OLD") {
	            l_cntFileList++;
	        }
	
	        // 전송할 파일 갯수 추가 : OK
	        if (l_arrSplitList[2] == "NEW") {
	            l_chkInsertFile = l_chkInsertFile + 1;
	        }
	    }
	
	    // 첨부파일 필수 사용 여부 확인 : OK
	    if (pBoolRequired) {
	        if ((l_cntFileList + l_chkInsertFile) <= 0) {
	            parent.Common.Warning(Common.getDic("msg_AddAttachFile"));
	            return false;
	        }
	    }
	
	    // 파일첨부 최대 개수 확인 : OK
	    if (g_LimitFileCnt < (l_chkInsertFile + l_cntFileList)) {
	        parent.Common.Warning(Common.getDic("msg_OverAttachFileCount"));
	        return false;
	    }
	
	    if (l_chkInsertFile > 0) {
	        var l_FrontPath = document.getElementById("hidFrontPath").value;
	        var l_saveType = "";
	        var sFileSaveInfo = "";
	
	        // 동영상 게시판인 경우
	        if (document.getElementById("hidUseVideo") != null && document.getElementById("hidUseVideo").value == "Y") {
	            l_saveType = "video";
	        } else {
	            // 업로드 진행 - FrontStorage에 업로드
	            l_saveType = "file";
	        }
	
	        sFileSaveInfo = encodeURIComponent(l_saveType + "," + l_FrontPath);
	
	        // Iframe의 formDataSubmit_onclick
	        $("#iframeHTML5_if")[0].contentWindow.formDataSubmit_onclick(sFileSaveInfo);
	        //XFN_CallBackMethod_Call("iframeHTML5", "formDataSubmit_onclick", sFileSaveInfo);
	
	        return true;
	    } else {
	        // 함수가 있을경우 ChkIsValidationCheck_After 함수 호출 없을 경우 true 리턴. -- 첨부파일 X
	        if (typeof ChkIsValidationCheck_After == 'function') {
	            return ChkIsValidationCheck_After();
	        } else {
	            return true;
	        }
	    }
	}
	
	// 현재 함수를 사용하고 있지 않으며, 향후 수정하여 사용될 함수.
	function formDataSubmitMulti_onclick(pStrFileSaveInfo) {
	    pStrFileSaveInfo = decodeURIComponent(pStrFileSaveInfo);
	    // Front Storage 경로와 저장 Type 셋팅 후 폼 전송
	    var sSaveType = pStrFileSaveInfo.split(',')[0];
	    var sSavePath = pStrFileSaveInfo.split(',')[1];
	
	    var formData = new FormData();
	    // 파일정보를 FormData에 저장
	    for (var i = 0; i < l_aObjFileList.length; i++) {
	        if (typeof l_aObjFileList[i] == 'object') {
	            formData.append("file", l_aObjFileList[i]);
	        }
	    }
	
	    formData.append("SavePath", sSavePath);
	    formData.append("SaveType", sSaveType);
	
	    xhr = new XMLHttpRequest();
	    xhr.upload.addEventListener("progress", progressHandler, false);
	    xhr.addEventListener("load", completeHandler, false);
	    xhr.addEventListener("error", errorHandler, false);
	    xhr.addEventListener("abort", abortHandler, false);
	    xhr.open('POST', '/WebSite/Common/ExControls/None/FileUploadHTML5_Iframe.aspx', true);
	    xhr.onreadystatechange = xmlHttp_onreadystatechange;
	    xhr.send(formData);
	}

	//--------------------------------------------- 첨부파일 컨트롤 끝 ------------------------------------------------------- 
</script>
