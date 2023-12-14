
if (!window.Common) {
	window.Common = {
		getSession : function() {
			return "ko";
		}
	};
}

if (!window.mobileEditor) {
	window.mobileEditor = {};
}

(function(window) {

	var mobileEditor = {
		tempHtml : "",
		tempHeight : 0,
		getBody : function(plainText){
			var bodyData = '';

			var editor = document.getElementById('MobileEditorFrame').contentWindow.tinymce.activeEditor;
			var docMaxWidth = parseFloat(editor.dom.getStyle(editor.getDoc().documentElement, 'max-width'));

			bodyData = editor.getContent();

			bodyData = bodyData.replace(/(<[^>]+ class="+[^"]*)covi_layout([^>]*)/gi, '$1$2');

			if (!isNaN(docMaxWidth)) {
				var bodyMarginLeft = parseInt(editor.$(editor.getBody()).css('margin-left'));
				var bodyMarginRight = parseInt(editor.$(editor.getBody()).css('margin-right'));

				bodyMarginLeft = isNaN(bodyMarginLeft) ? 0 : bodyMarginLeft;
				bodyMarginRight = isNaN(bodyMarginRight) ? 0 : bodyMarginRight;
				bodyData = '<div style="max-width:' + (docMaxWidth - (bodyMarginLeft + bodyMarginRight)) + 'px">' + bodyData + '</div>';
			}


			if(plainText == undefined || plainText == false){
				var imgInfo = this.getImages();

				if(imgInfo != ""){
					$(imgInfo.split("|")).each(function(idx,imgSrc){
						if(imgSrc.trim() != ""){
							//bodyData = bodyData.replaceAll(imgSrc, "‡"+idx+"‡");
							imgSrc = imgSrc.replace("?", "\\?");
							bodyData = bodyData.replace(new RegExp(imgSrc, 'gmi'), "‡"+idx+"‡");
						}
					});

					bodyData = bodyData.replace(/src\s*=\s*["|'](‡\d*‡)["|']/gmi,"$1");
				}

			}

			var backImg = this.getBackgroundImage();
			if(backImg != null && backImg != "") {
				if(backImg.trim() != ""){
					bodyData = bodyData.replaceAll(backImg, "‡"+9999+"‡");
				}
			}
			

			return bodyData;
		},
		getImages : function(){
			var imgInfo = "";
			var coviHtmlValue = document.getElementById('MobileEditorFrame').contentWindow.tinymce.activeEditor.getContent();

			if ($(coviHtmlValue).find("img").length > 0) {
				$(coviHtmlValue).find("img").each(function () {
					imgInfo += $(this).attr("src") + "|";
				});
			}

			if (imgInfo.length > 0) {
				imgInfo = imgInfo.substr(0, (imgInfo.length - 1));
			}

			return imgInfo;
		},
		getBodyText : function(){
			var bodyData = '';
			bodyData = document.getElementById('MobileEditorFrame').contentWindow.tinymce.activeEditor.getContent({format:"text"});
			return bodyData;
		},
		setBody : function(data){
			var replacedData = '';
			replacedData = data.replace(/\\n/gi, "");
			document.getElementById('MobileEditorFrame').contentWindow.tinymce.activeEditor.setContent(replacedData, {format: 'raw'});
		},
		/*Editor 내용을 DOM 형식으로 조회*/
		getBodyDom : function(){
			return document.getElementById('MobileEditorFrame').contentWindow.tinymce.activeEditor.getDoc();
		},
		getBackgroundImage : function(){
			var editor = document.getElementById('MobileEditorFrame').contentWindow.tinymce.activeEditor;
			var bodyEl = editor.getBody();

			if (bodyEl.style.cssText.length > 0) {
				var backgroundImgUrl = editor.dom.getStyle(bodyEl, 'backgroundImage', true); //배경이미지 url만 추출
				if(backgroundImgUrl != null && backgroundImgUrl != "" && backgroundImgUrl !== "none") {
					return backgroundImgUrl.split('(')[1].split('"')[1];
				}
			}
		},
		getBodyTemp : function(){
			var bodyData = '';
			bodyData = document.getElementById('MobileEditorFrame').contentWindow.tinymce.activeEditor.getContent();
			return bodyData;
		}
	};

	window.mobileEditor = mobileEditor;

})(window);
