/* 프로그램 저작권 정보
//이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
//(주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
//(주)코비젼의 지적재산권 침해에 해당됩니다.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
//
//You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
//as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
//owns the intellectual property rights in and to this program.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

///<creator>기술연구소</creator> 
///<createDate>2017.08.17</createDate> 
///<lastModifyDate></lastModifyDate> 
///<version>0.8.0</version>
///<summary> 
///첨부파일 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/
if (!window.coviFile) {
    window.coviFile = {};
}

(function(window) {
	var fileEnable  = null;
	var fileImageEnable = null;
	var fileDisenableName = null;
	var useWebhard = null;
	var useWebhardAttach = null;
	var coviFile = {
			dictionary : {
				add : '추가;Add;追加;追加;;;;;;',
				//upload : '업로드;Upload;アップロード;上传;;;;;',
				upload : '등록;Enrollment;登録;注册;;;;;',
				webhard : '웹하드;Webhard;ウェブハード;网络硬盘;;;;;',
				attach : '파일첨부;Attach file;ファイル添付;文件附加;;;;;',
				msg_dragFile : '마우스로 파일을 끌어 오세요.;Drag the file with the mouse.;マウスでファイルを集めてきてください;请用鼠标把文件拉过来;;;;;',
				msg_checkDupe : '이미 추가된 파일이 있습니다.;File already added exists.;すでに追加されたファイルがあります;已追加的文件已存在;;;;;',
				msg_enableFile : '업로드 할 수 없는 파일입니다.;This file can not be uploaded.;アップロードできないファイルです;此文件无法上传;;;;;',
				msg_disenableFileName : '업로드 할 수 없는 파일입니다.<br>지원하지 않는 파일명 형식: ;This file cannot be uploaded.<br>Unsupported file name format: ;アップロードできないファイルです。<br>サポートしないファイル名形式: ;不能上传的文件。<br>不支持的文件名形式: ;;;;;',
				msg_checkFileSize : '{0} 이하의 파일만 업로드 가능합니다.;Only files below {0} can be uploaded.;{0}以下のファイルのみアップロード可能です。;只能上传{0}以下的文件。;;;;;;;',
				msg_noFile : '추가할 파일이 없습니다.;No files to add.;追加するファイルがありません;欲追加的文件不存在;;;;;',
				msg_checkMultipartDupe : '파일을 두개이상 추가할 수 없습니다.;Two or more files can not be added.;ファイルを二つ以上追加できません;两个以上文件无法被添加;;;;;',
				attachWebhardFile: '웹하드 파일첨부;Webhard the Attach Files;ウェブハードファイル添付;网络硬盘附件;;;;;',
				msg_fileNameLengthLimited: '업로드 할 수 있는 파일명의 최대 길이는 {0} 자 입니다.;The maximum length of the file name that can be uploaded is {0} characters.;アップロードできるファイル名の最大長さは{0}字です。;可上传的文件名最大长度为{0}字。;;;;;;;',
				msg_checkTotalFileSize: '업로드 할 수 있는 총 파일 용량은 {0} 입니다.;The total file capacity that can be uploaded is {0};アップロードできるファイルの総容量は{0}です。;可上传的总文件容量为{0}。;;;;;;;',
			},
			/*
			 * filesInfos : [
			 * 	{ 
			 * 		FileName : '',
			 * 		Size : '', 
			 * 		FileID : '',
			 * 		FilePath : '',
			 * 		SavedName : ''
			 * 		
			 * 	}
			 * 
			 * ]
			 * */
			fileInfos : [], //파일 정보
			files : [], //multipart file
			option : {
				lang : 'ko',
				totalFileSize : 209715200,
				fileSizeLimit : 209715200,
				limitFileCnt : 0,
				image : 'false',
				multiple : 'true',
				fileEnable : Common.getBaseConfig('EnableFileExtention'),
				fileImageEnable : Common.getBaseConfig("EnableFileImageExtention"),
				useWebhard : Common.getBaseConfig("isUseWebhard"),
				useWebhardAttach : Common.getBaseConfig("useWebhardAttach"),
				fileDisenableName : Common.getBaseConfig('DisenableFileName').split("|"),
				systemName : Common.getSystemName()
			},
			renderFileControl : function(target, option, data){
			    var queryString = $("script[src*='covision.file.js']").attr('src').split('?')[1];
			    if (queryString && queryString.indexOf("maxsize=")>=-1 && queryString.substring(queryString.indexOf("maxsize=")+8)){
			    	this.option.fileSizeLimit=queryString.substring(queryString.indexOf("maxsize=")+8)
			    }
				
				//변수 초기화
				if(!coviFile.option.systemName) coviFile.option.systemName = "covicore";
				coviFile.files = [];
				//coviFile.option = option;
				$.extend(coviFile.option, option);
				coviFile.option.target = target;
				
				//set locale
				var sessionLang = Common.getSession("lang");
				if(typeof sessionLang != "undefined" && sessionLang != ""){
					coviFile.option.lang = sessionLang;
				}
				
				/*
				 * option = {
				 * 	lang : 'ko',
				 * 	listStyle : 'table' or 'div',
				 * 	callback : '',
				 * 	actionButton : 'add,upload', //upload 버튼 사용 시 Front -> Back 시나리오, 비사용시는 Back Temp -> Back
				 * 	multiple : true,
				 * 	servicePath : '', //GWStorage 경로의 파일들을 mock 처리 후 합칠 때 사용.
				 *  fileSizeLimit' : '209715200'
				 * }
				 * 
				 * */
				var html = '';
				html += '<div>';
				html += '	<div class="addDataBtn">';
				if(coviFile.option.actionButton.indexOf('add') > -1){
					html += '		<button type="button" class="btnTypeDefault" name="addBtn" onclick="coviFile.addFileClick(\'' + target + '\');" style="cursor: pointer;" ><i class="fa fa-plus" aria-hidden="true"></i> ' + CFN_GetDicInfo(coviFile.dictionary.add, coviFile.option.lang) + '</button>';	
				}
				
				if(coviFile.option.useWebhard == "Y" && coviFile.option.useWebhardAttach == "Y"){
					html += '		<button type="button" class="btnTypeDefault" name="webhardBtn" onclick="coviFile.addWebhardFile();" style="cursor: pointer;"><i class="fa fa-cloud" aria-hidden="true"></i> ' + CFN_GetDicInfo(coviFile.dictionary.webhard, coviFile.option.lang) + '</button>';	
				}

				if(coviFile.option.actionButton.indexOf('upload') > -1){
					html += '		<button type="button" class="btnTypeDefault btnTypeBg" name="uploadBtn" onclick="coviFile.uploadToFront();" style="cursor: pointer;"><i class="fa fa-upload" aria-hidden="true"></i> ' + CFN_GetDicInfo(coviFile.dictionary.upload, coviFile.option.lang) + '</button>';	
				}
				
				html += '<div id="divFileLimitInfo" style="display:inline-block; margin-left:10px;">'
				if(coviFile.option.fileSizeLimit > 0 ) {
					html += '<span style="color:#999">';
					html += Common.getDic("lbl_UploadLimit3")+': ';
					html += coviFile.convertFileSize(coviFile.option.fileSizeLimit);
					html += '</span>';
				}
				
				html += '</div>'
				
				html += '		<input type="file" ';
				if(coviFile.option.multiple == 'true' || coviFile.option.multiple == true){
					html += 'multiple';
				}
				if(coviFile.option.name != null){
					html += ' name="'+coviFile.option.name+'" ';
				}
				
				html += ' onchange="coviFile.fileOnChange(\'' + target + '\',this);" onclick="this.value=null" style="position:absolute;left:-99999px;"/>';
				// KT 추가 ( 파일확장자 툴팁 표시 )
				html += '<div onmouseover="coviFile.showTooltip();" onmouseleave="coviFile.hideTooltip();" style="cursor:default; font-weight: bold;padding-bottom: 2px;float: right;display: inline-block;border-bottom: 1px solid #ddd;position: relative;width: 70px;height: 20px; font-size: 11px; color: #666;">';
				html += '* '+Common.getDic("lbl_AllowExtension"); // 허용 확장자
				html += '<div id="coviFileTooltip" style="display:none; position: absolute; width: 300px; left: -230px; top: 23px; border: 1px solid #d9d9d9; box-sizing: border-box; padding: 5px; background-color: #f5f5f5; border-radius: 5px; white-space: normal;">';
				
				if(coviFile.option.image == 'true' || coviFile.option.image == true ){
					html += coviFile.option.fileImageEnable.replaceAll(',', ', ');
				}else{
					html += coviFile.option.fileEnable.replaceAll(',', ', ');
				}
				
				html += '</div>';
				html += '</div>';				
				
				html += '	</div>';
				
				html += '	<div ondragenter="coviFile.onDragEnter(event)" ondragover="coviFile.onDragOver(event)" ondrop="coviFile.onDrop(event)" style="min-height:125px;border:2px dashed #0087F7;border-radius:5px;">';
				html += '		<div class="addData">';
				html += '			<div class="dragFileBox"><span class="dragFile">icn</span>' + CFN_GetDicInfo(coviFile.dictionary.msg_dragFile, coviFile.option.lang) + '</div>';
				if(coviFile.option.listStyle == 'table'){
					html += '			<table class="fileHover">';
					html += '				<colgroup>';
					html += '					<col style="width:20px">';
					html += '					<col style="width:*">';
					html += '					<col style="width:50px">';
					html += '				</colgroup>';
					html += '				<tbody style="background-color:white;">';
					html += '				</tbody>';
					html += '			</table>';
				} else if(coviFile.option.listStyle == 'div'){
					html += '			<div class="confile"></div>';
				}
				
				html += '		</div>';
				html += '	</div>';
				html += '</div>';
				
				$('#' + target).append(html);
				//set file data
				coviFile.setFile(target, data);
			},
			setFile : function(target, data){
				if(data != null){
					for (var i = 0; i < data.length; i++ ){
						var fileObj = coviFile.makeFileObj('normal',data[i].FileID, data[i].FileName, data[i].Size, data[i].FilePath, data[i].SavedName);
						coviFile.fileInfos.push(fileObj);
						coviFile.addRow(target, fileObj);
					}
				}
			},
			addFileClick : function(target){
				$('#' + target + ' input:file').focus().trigger('click');
			},
			addWebhardFile : function(){
				var url = "/webhard/user/popup/callWebhardAttachPopup.do?CLSYS=webhard&CLMD=user&CLBIZ=Webhard&callbackFunc=coviFile.callBackWebhardFile&openType=common";
				
				parent.coviFile.callBackWebhardFile = coviFile.callBackWebhardFile;
				
				parent.Common.open("", "WebhardFileUploadPopup", CFN_GetDicInfo(coviFile.dictionary.attachWebhardFile, coviFile.option.lang) , url, "1100px", "500px", "iframe", true, null, null, true);
			},
			callBackWebhardFile : function(files){
				var $this = coviFile.option.target;
				var $files = files;
							
				var comfileEnable = coviFile.option.fileEnable;
 				var fileFlag = true;
				
				if(coviFile.option.image == 'true' || coviFile.option.image == true){
					comfileEnable = coviFile.option.fileImageEnable;
				}

				if(coviFile.option.multiple == 'false' || coviFile.option.multiple == false){
					if($files.length > 1 || coviFile.files.length > 0){
						fileFlag = false;
					}
				}
				
				if(fileFlag == true || fileFlag == 'true'){
					for (var i = 0; i < $files.length; i++) {
						
						var _fileLen = $files[i].FileName.length;
						var _lastDot = $files[i].FileName.lastIndexOf('.');
						var _fileExt = $files[i].FileName.substring(_lastDot+1, _fileLen).toLowerCase();
						var _isFileName = false;
						
						for(var j = 0; j < coviFile.option.fileDisenableName.length; j++){
							if($files[i].FileName.indexOf(coviFile.option.fileDisenableName[j]) > -1 && coviFile.option.fileDisenableName[j] != ""){
								_isFileName = true;
							}
						}

						if(coviFile.checkDuplicationInFiles($files[i])){
							parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_checkDupe, coviFile.option.lang));
						}else if(comfileEnable.indexOf(_fileExt) < 0){
							parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_enableFile, coviFile.option.lang));
						}else if(_isFileName){
							var warningComment = CFN_GetDicInfo(coviFile.dictionary.msg_disenableFileName, coviFile.option.lang)+coviFile.option.fileDisenableName.join(", ");
							parent.Common.Warning(warningComment.substr(0, warningComment.length - 2));
						}else {
							if($files[i].size > Number(coviFile.option.fileSizeLimit)){
								parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_checkFileSize, coviFile.option.lang).replace("{0}", coviFile.convertFileSize(coviFile.option.fileSizeLimit)));
							}else{
								// 총 업로드 제한 용량 체크
								var totalFileSize = 0;
								if(coviFile.fileInfos.length > 0) {
									$(coviFile.fileInfos).each(function(i, item){
										totalFileSize += Number(item.Size);
									});
								}
								totalFileSize += $files[i].size;
								
								if(totalFileSize > Number(coviFile.option.totalFileSize)){
									parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_checkTotalFileSize, coviFile.option.lang).replace("{0}", coviFile.convertFileSize(coviFile.option.totalFileSize)));
								} else {
									var _fileNameMaxLength = Common.getBaseConfig('FileNameMaxLength');
									if(_fileNameMaxLength != 0 && (_fileLen > _fileNameMaxLength)) {
										parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_fileNameLengthLimited, coviFile.option.lang).replace("{0}", Common.getBaseConfig('FileNameMaxLength')));	
									} else {
										var fileObj = coviFile.makeFileObj('webhard', '', $files[i].FileName, $files[i].Size, '', $files[i].SavedName);
										coviFile.files.push($files[i]);
										coviFile.fileInfos.push(fileObj);
										coviFile.addRow(coviFile.option.target, fileObj);
									}
								}
							}
						}
					}
				}else{
					parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_checkMultipartDupe, coviFile.option.lang));
				}
				
				/*	
				if(coviFile.option.multiple == 'false' || coviFile.option.multiple == false){
					$('#' + target + ' .addDataBtn button[name=addBtn]').hide();
				}
				*/				
			},
			checkDuplicationInFiles : function(file){
				var bExist = false;
				for (var i = 0; i < coviFile.fileInfos.length; i++ ){
					//중복 여부를 encodeURIComponent(filename), filesize로 판별함
			        if (coviFile.fileInfos[i].FileName == encodeURIComponent(file.name) && coviFile.fileInfos[i].Size == file.size){
			        	bExist = true;
			        }
			    }
				return bExist;
			},
			setHidden : function(files){
			},
			convertFileSize : function(pSize){
				var sizes = ['Byte', 'KB', 'MB', 'GB', 'TB'];
			    if (pSize == 0) return 'n/a';
			    var i = parseInt(Math.floor(Math.log(pSize) / Math.log(1024)));
			    return (pSize / Math.pow(1024, i)).toFixed(1) + sizes[i];
			},
			getIconClass : function(extension){
				var strReturn = "";
				var lowerExt = extension.toLowerCase();
				if (lowerExt == "xls" || lowerExt == "xlsx") {
					strReturn = "exCel";
				} else if (lowerExt == "jpg" || lowerExt == "png" || lowerExt == "bmp") {
					strReturn = "imAge";
				} else if (lowerExt == "doc" || lowerExt == "docx") {
					strReturn = "woRd";
				} else if (lowerExt == "ppt" || lowerExt == "pptx") {
					strReturn = "pPoint";
				} else if (lowerExt == "txt" || lowerExt == "hwp") {
					strReturn = "teXt";
				} else {
					strReturn = "etcFile";
				}

				return strReturn;
			},
			addRow : function(target, file){
				var html = '';
				var sFileName = file.FileName;
				var sExtension = sFileName.split('.')[sFileName.split('.').length - 1];
				var sFileSize = file.Size;
				
				if (file != null) {
					$('#' + target + ' .dragFileBox').hide();
				}
				
				if(coviFile.option.listStyle == 'table'){
					html += '<tr data-filename = "' + sFileName + '" data-filesize = "' + sFileSize + '" data-fileid = "' + file.FileID + '" data-filepath = "' + file.FilePath + '" data-savedname = "' + file.SavedName + '">';
					html += '	<td><span class="' + coviFile.getIconClass(sExtension) + '">' + CFN_GetDicInfo(coviFile.dictionary.attach, coviFile.option.lang) + '</span></td>';
					html += '	<td>' + decodeURIComponent(sFileName) + '(' + coviFile.convertFileSize(sFileSize) + ')</td>';
					html += '	<td class="t_right"><a href="javascript:;" onclick="coviFile.delRow(\'' + target + '\', this);"><i class="fa fa-times fa-lg" aria-hidden="true"></i></a></td>';
					html += '</tr>';
					
					$('#' + target + ' table tbody').append(html);
				} else if(coviFile.option.listStyle == 'div'){
					html += '<div class="dvFileItem" data-filename = "' + sFileName + '" data-filesize = "' + sFileSize + '" data-fileid = "' + file.FileID + '" data-filepath = "' + file.FilePath + '" data-savedname = "' + file.SavedName + '">';
					html += '	<div class="dvFileItemHolder">';
					html += '		<div class="dvFileItemCell"><span class="' + coviFile.getIconClass(sExtension) + '">' + CFN_GetDicInfo(coviFile.dictionary.attach, coviFile.option.lang) + '</span></div>';
					html += '		<div class="dvFileItemCell">' + decodeURIComponent(sFileName) + '(' + coviFile.convertFileSize(sFileSize) + ')</div>';
					html += '		<div class="dvFileItemCell"><a href="javascript:;" onclick="coviFile.delRow(\'' + target + '\', this);"><i class="fa fa-times fa-lg" aria-hidden="true"></i></a></div>';
					html += '	</div>';
					html += '</div>';
					$('#' + target + ' .confile').append(html);
				}
			},
			delRow : function(target, elem){
				var $con;
				if(coviFile.option.listStyle == 'table'){
					$con = $(elem).closest('tr');
				} else if(coviFile.option.listStyle == 'div'){
					$con = $(elem).parent().parent().parent();
				} else {
					return ;
				}
				
				var escapedFileName = $con.attr('data-filename');
				var fileSize = $con.attr('data-filesize');
				
				//파일 정보 삭제
				coviFile.fileInfos = $.map(coviFile.fileInfos, function(item, index) {
					if(item.FileName == escapedFileName && item.Size == fileSize){
				        return null;
				    }
					
					return item;
				});
				
				//물리 파일 삭제
				coviFile.files = $.map(coviFile.files, function(item, index) {
					if(encodeURIComponent(item.name) == escapedFileName && item.size == fileSize){
				        return null;
				    }
					
					return item;
				});
				
				$con.remove();
				
				if(coviFile.files.length == 0 && coviFile.fileInfos.length == 0){
					$('#' + target + ' .dragFileBox').show();
				}
			},
			makeFileObj : function(fileType, fileId, fileName, fileSize, filePath, savedName){
				var fileObj = new Object();
				
				fileObj.FileType = fileType;  //normal or webhard 
				fileObj.FileName = encodeURIComponent(fileName);
				fileObj.Size = fileSize;
				fileObj.FileID = fileId;
				fileObj.FilePath = filePath;
				fileObj.SavedName = savedName;
				
				return fileObj;
			},
			fileOnChange : function(target, elem){
				var $this = $(elem);
				var $files = $this.prop('files');
				
				var comfileEnable = coviFile.option.fileEnable;
 				var fileFlag = true;
				
				if(coviFile.option.image == 'true' || coviFile.option.image == true){
					comfileEnable = coviFile.option.fileImageEnable;
				}

				if(coviFile.option.multiple == 'false' || coviFile.option.multiple == false){
					if($files.length > 1 || coviFile.files.length > 0){
						fileFlag = false;
					}
				}
				
				if(fileFlag == true || fileFlag == 'true'){
					for (var i = 0; i < $files.length; i++) {
						
						var _fileLen = $files[i].name.length;
						var _lastDot = $files[i].name.lastIndexOf('.');
						var _fileExt = $files[i].name.substring(_lastDot+1, _fileLen).toLowerCase();
						var _isFileName = false;
						
						for(var j = 0; j < coviFile.option.fileDisenableName.length; j++){
							if($files[i].name.indexOf(coviFile.option.fileDisenableName[j]) > -1 && coviFile.option.fileDisenableName[j] != ""){
								_isFileName = true;
							}
						}

						if(coviFile.checkDuplicationInFiles($files[i])){
							parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_checkDupe, coviFile.option.lang));
						}else if(comfileEnable.indexOf(_fileExt) < 0){
							parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_enableFile, coviFile.option.lang));
						}else if(_isFileName){
							var warningComment = CFN_GetDicInfo(coviFile.dictionary.msg_disenableFileName, coviFile.option.lang)+coviFile.option.fileDisenableName.join(", ");
							parent.Common.Warning(warningComment.substr(0, warningComment.length - 2));
						}else {
							if($files[i].size > Number(coviFile.option.fileSizeLimit)){
								parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_checkFileSize, coviFile.option.lang).replace("{0}", coviFile.convertFileSize(coviFile.option.fileSizeLimit)));
							}else{
								// 총 업로드 제한 용량 체크
								var totalFileSize = 0;
								if(coviFile.fileInfos.length > 0) {
									$(coviFile.fileInfos).each(function(i, item){
										totalFileSize += Number(item.Size);
									});
								}
								totalFileSize += $files[i].size;
								
								if(totalFileSize > Number(coviFile.option.totalFileSize)){
									parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_checkTotalFileSize, coviFile.option.lang).replace("{0}", coviFile.convertFileSize(coviFile.option.totalFileSize)));
								} else {
									var _fileNameMaxLength = Common.getBaseConfig('FileNameMaxLength');
									if(_fileNameMaxLength != 0 && (_fileLen > _fileNameMaxLength)) {
										parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_fileNameLengthLimited, coviFile.option.lang).replace("{0}", Common.getBaseConfig('FileNameMaxLength')));	
									} else {
										var fileObj = coviFile.makeFileObj('normal', '', $files[i].name, $files[i].size, '', '');
										coviFile.files.push($files[i]);
										coviFile.fileInfos.push(fileObj);
										coviFile.addRow(target, fileObj);
										
										// 정보 공유 시스템
										if((coviFile.option.systemName == "feed" || CFN_GetQueryString("CLBIZ") == "Feed") && _fileExt == "diff") {
											coviFile.diff($files[i]);
										}
									}
								}
							}
						}
					}
				}else{
					parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_checkMultipartDupe, coviFile.option.lang));
				}
			},
			onDragEnter : function(event) {
				event.preventDefault();
			},
			onDragOver : function(event) {
				event.preventDefault();
			},
			onDrop : function(event) {
				event.stopPropagation();
				event.preventDefault();
				var $files = event.dataTransfer.files;
				
				var comfileEnable = coviFile.option.fileEnable;
 				var fileFlag = true;
				
				if(coviFile.option.image == 'true' || coviFile.option.image == true){
					comfileEnable = coviFile.option.fileImageEnable;
				}
				
				if(coviFile.option.multiple == 'false' || coviFile.option.multiple == false){
					if($files.length > 1 || coviFile.files.length > 0){
						fileFlag = false;
					}
				}
				
				if(fileFlag == true || fileFlag == 'true'){
				
					for (var i = 0; i < $files.length; i++) {
						
						var _fileLen = $files[i].name.length;
						var _lastDot = $files[i].name.lastIndexOf('.');
						var _fileExt = $files[i].name.substring(_lastDot+1, _fileLen).toLowerCase();
						var _isFileName = false;
						
						for(var j = 0; j < coviFile.option.fileDisenableName.length; j++){
							if($files[i].name.indexOf(coviFile.option.fileDisenableName[j]) > -1 && coviFile.option.fileDisenableName[j] != ""){
								_isFileName = true;
							}
						}
						
						if(coviFile.checkDuplicationInFiles($files[i])){
							parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_checkDupe, coviFile.option.lang));
						}else if(comfileEnable.indexOf(_fileExt) < 0){
							parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_enableFile, coviFile.option.lang));
						}else if(_isFileName){
							var warningComment = CFN_GetDicInfo(coviFile.dictionary.msg_disenableFileName, coviFile.option.lang)+coviFile.option.fileDisenableName.join(", ");
							parent.Common.Warning(warningComment.substr(0, warningComment.length - 2));
						}else {
							if($files[i].size > Number(coviFile.option.fileSizeLimit)){
								parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_checkFileSize, coviFile.option.lang).replace("{0}", coviFile.convertFileSize(coviFile.option.fileSizeLimit)));
							}else{
								// 총 업로드 제한 용량 체크
								var totalFileSize = 0;
								if(coviFile.fileInfos.length > 0) {
									$(coviFile.fileInfos).each(function(i, item){
										totalFileSize += Number(item.Size);
									});
								}
								totalFileSize += $files[i].size;
								
								if(totalFileSize > Number(coviFile.option.totalFileSize)){
									parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_checkTotalFileSize, coviFile.option.lang).replace("{0}", coviFile.convertFileSize(coviFile.option.totalFileSize)));
								} else {
									var _fileNameMaxLength = Common.getBaseConfig('FileNameMaxLength');
									if(_fileNameMaxLength != 0 && (_fileLen > _fileNameMaxLength)) {
										parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_fileNameLengthLimited, coviFile.option.lang).replace("{0}", Common.getBaseConfig('FileNameMaxLength')));	
									} else {
										var fileObj = coviFile.makeFileObj('normal', '', $files[i].name, $files[i].size, '', '');
										coviFile.files.push($files[i]);
										coviFile.fileInfos.push(fileObj);
										coviFile.addRow(coviFile.option.target, fileObj);
										
										// 정보 공유 시스템
										if((coviFile.option.systemName == "feed" || CFN_GetQueryString("CLBIZ") == "Feed") && _fileExt == "diff") {
											coviFile.diff($files[i]);
										}
									}
								}
							}
						}
					}
				}else{
					parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_checkMultipartDupe, coviFile.option.lang));
				}
			},
			uploadToFront : function(){				
				var fileData = new FormData();
				
				fileData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
				fileData.append("servicePath", coviFile.option.servicePath);
				
		        // 파일정보
		        for (var i = 0; i < coviFile.files.length; i++) {
		        	if (typeof coviFile.files[i] == 'object') {
		        		fileData.append("files", coviFile.files[i]);
		            }
		        }
				
				$.ajax({
	        		url: "/" + coviFile.option.systemName + "/control/uploadToFront.do",
	        		data: fileData,
	        		type:"post",
	        		dataType : 'json',
	        		processData : false,
	    	        contentType : false,
	        		success:function (res) {
	        			if(res.status == "SUCCESS"){
	        				if(res.list.length > 0 ){
		        				//callback method 호출
		        				if(coviFile.option.callback != null && coviFile.option.callback != ''){
		        					if(window[coviFile.option.callback] != undefined && window[coviFile.option.callback] != null && window[coviFile.option.callback] != ''){
		        						window[coviFile.option.callback](res.list, coviFile.option.elemID);
		        					} else if(parent[coviFile.option.callback] != undefined && parent[coviFile.option.callback] != null && parent[coviFile.option.callback] != ''){
		        						parent[coviFile.option.callback](res.list, coviFile.option.elemID);
		        					} else if(opener[coviFile.option.callback] != undefined && opener[coviFile.option.callback] != null && opener[coviFile.option.callback] != ''){
		        						opener[coviFile.option.callback](res.list, coviFile.option.elemID);
		        					}
		        				}
		        			}else{
		        				parent.Common.Warning(CFN_GetDicInfo(coviFile.dictionary.msg_noFile, coviFile.option.lang));
		        			}
	        			} else {
	        				parent.Common.Warning(res.message);
	        			}
	        		},
	        		error:function(response, status, error){
						CFN_ErrorAjax("control/uploadToFront.do", response, status, error);
		       		}			
	        	});
				
			},
			
			showTooltip : function() {
				$("#coviFileTooltip").show();
			},
			
			hideTooltip : function() {
				$("#coviFileTooltip").hide();
			},
			
			diff : function(fileObj) {
				var reader = new FileReader();
				
				reader.onload = function () {
					var diffString = reader.result;
					var diffArray = diffString.split("diff --git a/");
					var returnArray = new Array();
					
					$.each(diffArray, function(i, item) {
						if(item.substring(0, item.indexOf(" b/")) != "") {
							var sourcePath = item.substring(0, item.indexOf(" b/"));
							
							if(typeof(feedWrite.setDiffSourcePath) === "function") {
								feedWrite.setDiffSourcePath(sourcePath);
							} else {
								if($("#sourcePath").length > 0 && sourcePath != null && sourcePath != "") {
									$("#sourcePath").val("");
									var dupCheck = false;
									var sHTML = "";
									
									$("#divSourceList").children().each(function () {
							            if ($(this).attr("sourcePath") == sourcePath)
							            	dupCheck = true;
									});
							
									if (!dupCheck) {
										sHTML += String.format("<div sourcePath='{0}'>{0}", sourcePath);
										sHTML += String.format("<a href='#' class='btnRemoveAuto' onclick='feedWrite.deleteSource(this);'/>");
										sHTML += String.format("</div>");
									}
									
									$("#divSourceList").append(sHTML);
									
									$("#sourceCount").text(String.format("({0}" + Common.getDic("lbl_Count") + ")", $("#divSourceList").children().size()));
									
									if(!$('#divSourceHeader .btnSurMove').hasClass('active')){
										$("#divSourceHeader").find(".btnSurMove").addClass("active");
							    		$("#divSourceHeader").next().addClass("active");
									}
								}
							}
						}
					});
				};
				
				reader.readAsText(fileObj, "utf-8");
			}
	};
	
	window.coviFile = coviFile;
	
})(window);
