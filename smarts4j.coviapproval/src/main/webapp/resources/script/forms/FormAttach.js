/**
 * 파일 업로드 확인을 위한 임의 javascript 소스
 */

// 파일 컨트롤과 드래그 앤 드롭하여 추가한 파일 정보를 저장.

// 읽기모드일 경우 화면에 첨부목록 화면 세팅
function formDisplaySetFileInfo() {
	var fileInfoHtml = "";
	if(getInfo("FileInfos") != ""){
		var fileInfos = $.parseJSON(getInfo("FileInfos"));
		var cnt = 0;
		if (fileInfos.length > 0) {
			$(fileInfos).each(function(i, fileInfoObj) {
				var tmpExt = $$(fileInfoObj).attr("Extention");
				var tmpName = $$(fileInfoObj).attr("FileName");
				if(!tmpExt && tmpName) tmpExt = tmpName.split('.')[tmpName.split('.').length - 1];
				var className = setFileIconClass(tmpExt);
				
				if (formJson.Request.ishistory //히스토리 내 첨부 다운로드 불가하도록 처리 필요(단순 리스트 표시)
						|| (!$$(fileInfoObj).attr("FileID") && $$(fileInfoObj).attr("FileID") != "0") // 편집중 중 추가한 파일은 미리보기시 다운로드 불가
						){ 
					fileInfoHtml += "<dl class='excelData'><dt>";
					//fileInfoHtml += "<p style='display:inline-block'>" + $$(fileInfoObj).attr("FileName") + "</p>";
					//fileInfoHtml += "<span>(" + ConvertFileSizeUnit($$(fileInfoObj).attr("Size")) + ")</span>";
					fileInfoHtml += "<span class='" + className + "'>파일첨부</span>";
					fileInfoHtml += "<span class='fileName'>"+$$(fileInfoObj).attr("FileName")+"</span>";
					fileInfoHtml += "<span class='fileSize'>(" + ConvertFileSizeUnit($$(fileInfoObj).attr("Size")) + ")</span>";
					fileInfoHtml += "</dt></dl>";
				} else {
					cnt++;
					fileInfoHtml += "<dl class='excelData'><dt>";
					
					fileInfoHtml += "<a href='javascript:void(0);' onclick='attachFileDownLoadCall("+ i + ")' >";
					fileInfoHtml += "<span class='" + className + "'>파일첨부</span>";
					fileInfoHtml += "<span class='fileName'>"+$$(fileInfoObj).attr("FileName")+"</span>";
					fileInfoHtml += "<span class='fileSize'>(" + ConvertFileSizeUnit($$(fileInfoObj).attr("Size")) + ")</span>";
					fileInfoHtml += "</a>";
					
					fileInfoHtml += "</dt>";
					fileInfoHtml += "<dd>";
					fileInfoHtml += "<a class='previewBtn fRight' href='javascript:void(0);' onclick='attachFilePreview(\"" + $$(fileInfoObj).attr("FileID") + "\",\"" + $$(fileInfoObj).attr("FileToken") + "\",\"" + $$(fileInfoObj).attr("Extention") + "\");'>" + Common.getDic("lbl_preview") + "</a>";
					fileInfoHtml += "</dd>";
					fileInfoHtml += "</dl>";
				}
			});
	
			$("#AttFileInfo").html(fileInfoHtml);
	
			if (cnt > 1  && !formJson.Request.ishistory) { // 실제 있는 파일만 개수체크 fileInfos.length 
				// $("#AttFileInfo").append("<dl class='excelData'><dt></ dt><dd><a
				// class='totDownBtn' href='#ax'
				// onclick='Common.downloadAll($.parseJSON(getInfo(\"FileInfos\")));'
				// href='#ax'><span class='etcFile'>파일첨부</span>전체 다운로드
				// </a></dd></dl>");
				$("#TIT_ATTFILEINFO").html(Common.getDic("lbl_apv_AddFile") + "<br/><a class='totDownBtn' href='javascript:void(0);' onclick='Common.downloadAll($.parseJSON(getInfo(\"FileInfos\")));' href='javascript:void(0);'>" + Common.getDic("lbl_download_all") + "</a>");
			}
		}
	}
}

//문서유통 대용량 첨부목록 생성
function formDisplaySetUrlFileInfo() {
	var fileInfoHtml = "";
	if(formJson.BodyContext.pubdocinfo != "" && formJson.BodyContext.pubdocinfo != undefined){
		if(formJson.BodyContext.pubdocinfo.fileUrlInfos != "" && formJson.BodyContext.pubdocinfo.fileUrlInfos != undefined){
			var fileInfos = $.parseJSON(Base64.b64_to_utf8(formJson.BodyContext.pubdocinfo.fileUrlInfos));
			var cnt = 0;
			if (fileInfos.fileUrlInfos.length > 0) {
				$(fileInfos.fileUrlInfos).each(function(i, fileInfoObj) {
						cnt++;
						fileInfoHtml += "<dl class='excelData'><dt>";
						fileInfoHtml += "<a onclick=\"window.open('"+$$(fileInfoObj).attr("fileContent") + "', '_blank', 'width=800, height=600, location=no, status=no, scrollbars=yes'); \">";
						fileInfoHtml += "<span class='etcFile'>파일첨부</span>";
						fileInfoHtml += "<span class='fileName'>"+$$(fileInfoObj).attr("fileName")+"</span>";
						fileInfoHtml += "</a>";
						fileInfoHtml += "</dt>";
						fileInfoHtml += "</dl>";
				});
				$("#AttFileInfo").append(fileInfoHtml);
			}
		}
	}
}

function attachFileDownLoadCall(index) {
	var fileInfoObj = $.parseJSON(getInfo("FileInfos"))[index];
	Common.fileDownLoad($$(fileInfoObj).attr("FileID"), $$(fileInfoObj).attr("FileName"), $$(fileInfoObj).attr("FileToken"));
}

function attachFileDownLoadCall_comment(fileid, filename, filetoken) {
	Common.fileDownLoad(fileid, filename, filetoken);
}

// 첨부파일 미리보기 (Synap)
function attachFilePreview(fileId, fileToken, extention) {
	extention = extention.toLowerCase();
	if (extention ==  "jpg" ||
			extention ==  "jpeg" ||
			extention ==  "png" ||
			extention ==  "tif" ||
			extention ==  "bmp" ||
			extention ==  "xls" ||
			extention ==  "xlsx" ||
			extention ==  "doc" ||
			extention ==  "docx" ||
			extention ==  "ppt" ||
			extention ==  "pptx" ||
			extention ==  "txt" ||
			extention ==  "pdf" ||
			extention ==  "hwp" ||
			extention ==  "mht") {
		var url = Common.getBaseConfig("MobileDocConverterURL") + "?fileID=" + fileId + "&fileToken=" + encodeURIComponent(fileToken) ;
		if(Common.getBaseConfig("usePreviewPopup") == "Y" || location.href.indexOf("CommentViewPage") > -1) { //의견팝업에서 조회 시 팝업
			window.open(url, "", "width=850, height=" + (window.screen.height-100));
		} else {
			if ($("#filePreview").css('display') == 'none') {
				$("#filePreview").show();
				$("#evidPreview").hide();
				
				if(getInfo("ExtInfo.UseWideForm") == "Y") { // 가로양식
					$("#formBox").css('width', '1070px');
					$("#filePreview .conin_view").css("left", "1070px");
				}
				else {
					$("#formBox").css('width', '790px');
					$("#filePreview .conin_view").css("left", "790px");
				}
				
				$("#IframePreview").attr('src', url);
				window.moveTo(0, 0);
				if (window.screen.width < 1550) {
					window.resizeTo(window.screen.width, window.screen.height);
				}
				else {
					window.resizeTo(1550, window.screen.height);
				}
				$("#previewVal").val(fileId);
			} else {
				if ($("#previewVal").val() == fileId) {
					$("#filePreview").hide();
					$("#formBox").css('width', '');
					$("#IframePreview").attr('src', '');
					var centerplaceWidth = (window.screen.width / 2) - 385;
					if (window.screen.width < 1550) {
						window.resizeTo(790, window.screen.height);
						window.moveTo(centerplaceWidth, 0);
					}
					else {
						window.resizeTo(790, window.screen.height);
					}
				} else {
					$("#IframePreview").attr('src', url);
					$("#previewVal").val(fileId);
				}
			}
		}
	} else {
		alert("변환이 지원되지않는 형식입니다.");
		return false;
	}
}

// 편집모드일 경우, 기존 파일 정보를 첨부파일 컨트롤 화면에 세팅
function controlDisplaySetFIleInfo() {
	var fileInfoHtml = "";
	var fileInfos = $.parseJSON(getInfo("FileInfos"));

	if ($("#AttachFileInfo").val() != "") {
		var attachInfos = $.parseJSON($("#AttachFileInfo").val());

		// 재사용, 임시저장일 경우 정보에 new로 변경
		if ((getInfo("Request.mode") == "DRAFT" && getInfo("Request.gloct") == "COMPLETE") || (getInfo("Request.mode") == "DRAFT" && getInfo("Request.gloct") == "REJECT") || (getInfo("Request.mode") == "TEMPSAVE")) {
			$$(attachInfos).find("FileInfos").concat().attr("Type", "REUSE");
			$("#AttachFileInfo").val(JSON.stringify($$(attachInfos).json()));
			setInfo("FormInstanceInfo.AttachFileInfo", JSON.stringify($$(attachInfos).json()));
		}
	}

	if (fileInfos.length > 0) {
		$("#trFileInfoBox").hide();

		$(fileInfos).each(function(i, fileInfoObj) {
			var className = setFileIconClass($$(fileInfoObj).attr("Extention"));
			
			fileInfoHtml += "<tr>";
			fileInfoHtml += '<td><input name="chkFile" type="checkbox" value="'+ $$(fileInfoObj).attr("MessageID") + '_' + $$(fileInfoObj).attr("Seq") + ":" + $$(fileInfoObj).attr("FileName") + ":OLD:" + $$(fileInfoObj).attr("SavedName") + ":" + $$(fileInfoObj).attr("Size") + '" class="input_check"></td>';
			fileInfoHtml += '<td><span class=' + className + '>파일첨부</span></td>';
			fileInfoHtml += "<td>" + $$(fileInfoObj).attr("FileName") + "</td>";
			fileInfoHtml += '<td class="t_right">' + ConvertFileSizeUnit($$(fileInfoObj).attr("Size")) + '</td>';
			fileInfoHtml += "</tr>";
		});

		$("#fileInfo").html(fileInfoHtml);
	}
	
	if(Common.getBaseConfig("useWebhardAttach") == "Y" && Common.getBaseConfig("isUseWebhard") == "Y"){ //Common.getExtensionProperties("isUse.webhard")
		$("#webhardAttach").show();
	}
	
	// EDMS 첨부
	if(Common.getBaseConfig("useEdmsAttach") == "Y"){
		$("#edmsAttach").show();
	}
	
	if(fileInfos.length > 0) setSeqInfo();
	
	// 사이즈 정보
	var limitFileSize = getLimitFileSize(true);
	
	if(getInfo("SchemaContext.scDistribution.isUse") == "Y") limitFileSize = '7.0MB';
	
	if(limitFileSize){
		var limitInfo = '<span style="color:#999">';
		limitInfo += Common.getDic("lbl_UploadLimit3")+': ';
		limitInfo += limitFileSize;
		limitInfo += '</span>';
		$("[name='divFileLimitInfo']").html(limitInfo);
	}
	
	// 허용확장자 정보
	$("[name='coviFileTooltip']").html(Common.getBaseConfig("EnableFileExtention").replaceAll(',',', '));
}

//[저축은행중앙회] 편집모드일 경우, 다안기안 기존 파일 정보를 첨부파일 컨트롤 화면에 세팅(HYS)
function controlDisplaySetMultiFIleInfo() {
	if(getInfo('BodyData.SubTable1') != ''){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
			var fileInfoHtml = "";
			var fileInfos = "";
			
			if(item.MULTI_ATTACH_FILE){
				if(typeof(item.MULTI_ATTACH_FILE) == "string") {
					item.MULTI_ATTACH_FILE = JSON.parse(item.MULTI_ATTACH_FILE.replace(/\"/gi, '').replace(/\\\\/gi, ''));
				}
				
				fileInfos = item.MULTI_ATTACH_FILE.FileInfos;
			}
	
			if (fileInfos != undefined && fileInfos.length > 0) {
				$("#trFileInfoBox").hide();
				var formIdx = "";
				$(fileInfos).each(function(i, fileInfoObj) {

					var className = setFileIconClass($$(fileInfoObj).attr("Extention"));
					formIdx = $$(fileInfoObj).attr("ObjectID");

					var className = setFileIconClass($$(fileInfoObj).attr("Extention"));
					
					fileInfoHtml += "<tr>";
					fileInfoHtml += '<td><input name="chkFile" type="checkbox" value="'+ $$(fileInfoObj).attr("MessageID") + '_' + $$(fileInfoObj).attr("Seq") + ":" + $$(fileInfoObj).attr("FileName") + ":OLD:" + $$(fileInfoObj).attr("SavedName") + ":" + $$(fileInfoObj).attr("Size") + '" class="input_check"></td>';
					fileInfoHtml += '<td><span class=' + className + '>파일첨부</span></td>';
					fileInfoHtml += "<td>" + $$(fileInfoObj).attr("FileName") + "</td>";
					fileInfoHtml += '<td class="t_right">' + ConvertFileSizeUnit($$(fileInfoObj).attr("Size")) + '</td>';
					fileInfoHtml += "</tr>";
				});
		
				if(formIdx != undefined){
					$("#fileInfo" + formIdx).html(fileInfoHtml);
				}
			}
		});
	}
}

// formInstance의 attachfileinfo 컬럼 값을 세팅
function setFormAttachFileInfo(bPlain) {

	var strOldAttachFileInfo = getInfo("FormInstanceInfo.AttachFileInfo");
	var oldAttachFileInfoLength = 0;
	var oldAttachFileInfoArr = new Array();
	var formAttachFileInfoObj = {};
	var objArr = new Array();
	var fileSeq = 0;

	if (strOldAttachFileInfo != "" && strOldAttachFileInfo != undefined) {
		oldAttachFileInfoLength = $$(strOldAttachFileInfo).json().FileInfos.length;
		oldAttachFileInfoArr = $$(strOldAttachFileInfo).json().FileInfos;
	}

	var fileInfos = $.parseJSON(getInfo("FileInfos"));

	if ($("[name=chkFile]").length > 0) {
		$("[name=chkFile]").each(function(i, checkObj) {
			var obj = {};
			var strArrObj = $(checkObj).val().split(":");
			
			if (strArrObj[2] == "OLD" || strArrObj[2] == "REUSE") {
				$(fileInfos).each(function(j, oldObj) {
					// 유지되는 파일은 파일정보를 그대로 가진다.
					if (oldObj.SavedName == strArrObj[3]) {
						if(!bPlain) oldObj.FileName = encodeURIComponent(oldObj.FileName); // 미리보기시 인코딩 안함
						objArr.push(oldObj);
						fileSeq++;
					}
				});
			} else if (strArrObj[2] == "NEW") {
				var strFormInstID = getInfo("FormInstanceInfo.FormInstID") == undefined ? "" : getInfo("FormInstanceInfo.FormInstID");
				
				$$(obj).append("ID", strFormInstID + "_" + fileSeq);
				$$(obj).append("FileName", (bPlain ? strArrObj[1] : encodeURIComponent(strArrObj[1]))); // 미리보기시 인코딩 안함
				$$(obj).append("Type", strArrObj[2]);
				$$(obj).append("AttachType", strArrObj[4]); //webhard or normal
				$$(obj).append("UserCode", getInfo("AppInfo.usid"));
				if(strArrObj.length > 6) $$(obj).append("OriginID", strArrObj[6]); // edms 원파일 fileid
				
				if(strArrObj[4] == "webhard" || strArrObj[4] == "edms"){
					$$(obj).append("SavedName", strArrObj[3]); 
				}
				
				if(strArrObj.length > 5) $$(obj).append("Size",strArrObj[5]);

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
}

function getLimitFileSize(pConvert){
	var rtnString = "";
	var limitFileSize = Common.getGlobalProperties("approval.max.upload.size") * 1;
	if(limitFileSize && limitFileSize != -1){ // -1인 경우 제한없음
		if(pConvert){
			var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
			var i = parseInt(Math.floor(Math.log(limitFileSize) / Math.log(1024)));
			return (limitFileSize / Math.pow(1024, i)).toFixed(1) + sizes[i];
		}else{
			rtnString = limitFileSize;
		}
	}
	return rtnString;
}

function showTooltip(pObj){
	$(pObj).find("[name='coviFileTooltip']").show();
}

function hideTooltip(pObj){
	$(pObj).find("[name='coviFileTooltip']").hide();
}
