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
///<createDate>2017.09.20</createDate> 
///<lastModifyDate></lastModifyDate> 
///<version>0.8.0</version>
///<summary> 
///공통 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/


if (!window.Common) {
	window.Common = {
		getSession : function() {
			return "ko";
		}
	};
}

if (!window.coviEditor) {
	window.coviEditor = {};
}

(function(window) {

	var coviEditor = {
		getContainerID : {

		},
		editorVariables : {

		},
		loadEditor : function(target, option){

			var html = '';
			/*
             * option = {
             * 	editorType : 'dext5',
             * 	containerID : 'tbContentElement',
             * 	frameHeight : '',
             * 	focusObjID : '',
             * 	useResize : 'N',
             * 	onLoad : ''
             * }
             * */
			var frameH = '600';
			if(option.frameHeight != null || option.frameHeight != undefined || option.frameHeight != ''){
				frameH = option.frameHeight;
			}

			var focusID = '';
			if(option.focusObjID != null || option.focusObjID != undefined){
				focusID = option.focusObjID;
			}

			var useResize = 'N';
			if(option.useResize != null || option.useResize != undefined || option.useResize != ''){
				useResize = option.useResize;
			}

			var onLoad = '';
			if(option.onLoad != null || option.onLoad != undefined || option.onLoad != ''){
				onLoad = option.onLoad;
			}

			var bizSection = '';
			if(option.bizSection != null || option.bizSection != undefined || option.bizSection != ''){
				bizSection = option.bizSection;
			}

			//set variables
			coviEditor.editorVariables[option.containerID] = {
				target : target,
				focusObjID : focusID,
				frameHeight : frameH,
				useResize : useResize,
				onLoad : onLoad,
				bizSection: bizSection
			};

			coviEditor.getContainerID = {
				containerID: option.containerID
			};

			var editorPath = '';

			//switch (option.editorType) {
			html += '<iframe id="' + option.containerID + 'Frame" name="' + option.containerID + '" ';
			html += 'marginwidth="0" frameborder="0" scrolling="no" width="100%" height="' + frameH + '" ';
			html += 'src="' + editorPath +'covieditor.html"></iframe>';
			//}
			$('#' + target).html(html);
		},
		getBody : function(editorType, containerID, plainText){
			var bodyData = '';
			var editor = document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor;
			var bodyDom = this.getBodyDom(editorType, containerID);
			var enableOutputWrapper = editor.getParam('output_wrapper', false);
			var covi_out = false;

			if (enableOutputWrapper && $(bodyDom).find(".covi_out_wrapper").length <= 0) {
				covi_out = true;
			}

			//switch (editorType) {
			bodyData = editor.getContent({format: 'raw', covi_out: covi_out});
			//}

			if(plainText == undefined || plainText == false){
				var imgInfo = coviEditor.getImages(editorType, containerID);

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

			return bodyData;
		},
		getImages : function(editorType, containerID){
			//switch (editorType) {
			var retImgInfo = '';
			var imgInfo = "";
			var bodyDom = this.getBodyDom(editorType, containerID);

			if ($(bodyDom).find("img").length > 0) {
				$(bodyDom).find("img").each(function () {
					imgInfo += $(this).attr("src") + "|";
				});
			}

			if (imgInfo.length > 0) {
				imgInfo = imgInfo.substr(0, (imgInfo.length - 1));
			}

			retImgInfo = imgInfo;
			//}

			return retImgInfo;
		},
		getBodyText : function(editorType, containerID){
			var bodyData = '';
			//switch (editorType) {
			bodyData = document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor.getContent({format:"text"});
			//}

			return bodyData;
		},
		setBody : function(editorType, containerID, data){
			var replacedData = '';
			replacedData = data.replace(/\\n/gi, "");

			//switch (editorType) {
			document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor.setContent(replacedData);
			//}
		},
		hide : function(editorType, containerID){
			//switch (editorType) {
			document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor.hide();

			if(coviEditor.editorVariables[containerID].target != undefined){
				$("#"+coviEditor.editorVariables[containerID].target).css("display","none");
			}
			//}
		},
		show:function(editorType, containerID){
			//switch (editorType) {
			if(coviEditor.editorVariables[containerID].target != undefined){
				$("#"+coviEditor.editorVariables[containerID].target).css("display","");
			}

			document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor.show();
			//}
		},
		/*Editor 내용을 DOM 형식으로 조회*/
		getBodyDom : function(editorType, containerID){
			//switch (editorType) {
			return document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor.getDoc();
			//}
		},
		toggleEditLock: function(isLock, containerID) {
			var editor = document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor;
			var domUtils = document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor.dom;
			var editableClassName = editor.getParam('noneditable_editable_class');
			var noneEditableClassName = editor.getParam('noneditable_noneditable_class');
			var oldClassName = isLock ? editableClassName : noneEditableClassName;
			var newClassName = isLock ? noneEditableClassName : editableClassName;
			var elemList = domUtils.$("." + oldClassName);

			for (var i = 0; i < elemList.length; i++) {
				elemList[i].className = elemList[i].className.replace(oldClassName, newClassName);
			}

			editor.setContent(editor.getContent());
		},
		docFilter: function(editorType, containerID, html) {
			return document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.docFilter(html);
		}
	};

	window.coviEditor = coviEditor;

})(window);
