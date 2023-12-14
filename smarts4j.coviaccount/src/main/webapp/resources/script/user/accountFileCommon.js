
if (!window.accountFileCtrl) {
    window.accountFileCtrl = {};
}

(function(window) {
	var accountFileCtrl = {

			g_frontFileInfos : [],
			
			/*
			파일 업로드 팝업 호출
			covicore에서 copy
			 */
			callFileUpload : function(target, callbackFunc) {
				//setGlobalTargetIndex(target);

				var me = this;
				if(callbackFunc == null){
					callbackFunc = "accountFileCtrl.file_callback";
				}
				/*
				파일업로드시 정책에 설정된 대용량보다 크다면 Upload 불가.
				Upload 후 정책에 설정된 일반첨부용량보다 크다면 자동으로 대용량으로 변환
				*/
				
				var url = "";
				url += "/covicore/control/callFileUpload.do?"
				url += "lang=ko&";
				url += "listStyle=div&";
				url += "callback="+callbackFunc+"&";
				url += "actionButton="+encodeURIComponent("add,upload")+"&";
				url += "multiple=true";
				var maxUploadSize = Common.getGlobalProperties("account.max.upload.size");
				if(maxUploadSize*1) url += "&fileSizeLimit=" + maxUploadSize;
				
				var callbackFnObj = null;
				if(callbackFunc.indexOf(".") > 0){
					callbackFnObj = window;
					var callbackNsArr = callbackFunc.split(".");
					for(var i = 0; i < callbackNsArr.length; i++){
						var ns = callbackNsArr[i];
						callbackFnObj = callbackFnObj[ns];
					}
				}else{
					callbackFnObj = window[callbackFunc];
				}
				
				window[callbackFunc] = callbackFnObj;
				//url += "fileSizeLimit="+localStorage.getItem("userWriteBigFileSize");

				Common.open("", "FileUploadPopup", "파일", url, "500px", "250px", "iframe", true, null, null, true);
			}, 

			/*
			callback 미지정시 기본 호출
			 */
			file_callback : function(data) {
				
				var me = this;
				me.g_frontFileInfos = data;
				me.uploadFiles();
				window['accountFileCtrl.file_callback'] = null;
			},

			/*
			front 파일을 back로
			covicore에서 copy
			 */
			uploadFiles : function(callback, data){
				var me = this;
				var uploadArray = [];
				if(data==null){
					uploadArray = me.g_frontFileInfos;
				}else{
					uploadArray = data;
				}
				
				
				/*Front -> Back*/
				var sampleData = new FormData();
				if (uploadArray != undefined || uploadArray != "undefined")
					sampleData.append("frontFileInfos", JSON.stringify(uploadArray));
							//.stringify(g_frontFileInfos));
				$.ajax({
					type : "POST",
					dataType : "json",
					data : sampleData,
					url : "/account/EAccountFileCon/uploadFiles.do",
					processData : false,
					contentType : false,
					success : function(data) {
						
						if(typeof(callback)==='function'){
							callback(data);
						}

						Common.close("FileUploadPopup");
					},
					error : function() {
						obj["resultSts"] = "E";
						return obj;
					}
				});
			},
			fileFrame : null,
			/*
			파일 다운로드
			covicore에서 copy
			 */
			downloadFile : function(SavedName, FileName, FileID){
				SavedName = unescape(SavedName).replace(/'/gi, '&apos;');
				FileName = unescape(FileName).replace(/'/gi, '&apos;');
				
				var me = this;
				var alframe = null
				if($("[name=fileFrame]").length>0){
					alframe = $("[name=fileFrame]")[0];
				}
				else{
					alframe = document.createElement("iframe");
				}
				
				alframe.setAttribute("name", "fileFrame");
				alframe.style.width="1px";
				alframe.style.height="1px";
				var seturl=String.format('/account/EAccountFileCon/doDownloadFiles.do?' +
						'savedFileName={0}&fileName={1}&fileId={2}',
						encodeURIComponent(encodeURIComponent(SavedName)), 
						encodeURIComponent(encodeURIComponent(FileName)),
						FileID)
				alframe.src= seturl;
				document.getElementsByTagName("body")[0].appendChild(alframe);
				//alframe.remove();
			},

			makeError : function(){
				Common.Error('파일을 찾을 수 없습니다.');
			},

			closeFilePopup : function(){
				Common.close("FileUploadPopup");
			},
			
			attachFilePreview : function(fileId, fileToken, extention, popupYN) {
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
						extention ==  "hwp") {
					if(location.href.indexOf("approval_Form") > - 1) { //approval
						attachFilePreview(fileId, fileToken, extention); //FormAttach.js 내 함수 호출
					} else { //e-Accounting
						if(Common.getBaseConfig("usePreviewPopup") == "Y") {
							var url = Common.getBaseConfig("MobileDocConverterURL") 
							+ "?fileID=" + fileId + "&fileToken=" + encodeURIComponent(fileToken) ;	
							window.open(url, "", "width=850, height=" + (window.screen.height-100));
						}else{
							if(popupYN == "Y") {
								parent.Common.open("","expenceApplicationViewFilePreviewPopup","<spring:message code='Cache.ACC_lbl_addFile'/>" + "<spring:message code='Cache.lbl_preview'/>",
										"/account/expenceApplication/ExpenceApplicationViewFilePreviewPopup.do?fileId="+fileId+"&fileToken="+fileToken,"1200px","600px","iframe",true,null,null,true);
							} else {
								if(window.outerWidth < 1400) { //ListEdit
									window.resizeTo(1400, 800);
								}
								Common.open("","expenceApplicationViewFilePreviewPopup","<spring:message code='Cache.ACC_lbl_addFile'/>" + "<spring:message code='Cache.lbl_preview'/>",
										"/account/expenceApplication/ExpenceApplicationViewFilePreviewPopup.do?fileId="+fileId+"&fileToken="+fileToken,"1200px","600px","iframe",true,null,null,true);	
							}
						}
					}
				} else {
					alert("변환이 지원되지않는 형식입니다.");
					return false;
				}
			}
		}

	window.accountFileCtrl = accountFileCtrl;
})(window);

