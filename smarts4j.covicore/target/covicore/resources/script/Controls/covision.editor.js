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
				var resourceVersion = coviCmn.isNull(Common.getGlobalProperties("resource.version"), "");
				resourceVersion = resourceVersion == "" ? "" : ("?ver=" + resourceVersion);
				
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
				var frameH 		= ($.trim(option.frameHeight)	|| '600').replace("px","");
				var focusID 	= $.trim(option.focusObjID) 	|| '';
				var useResize 	= $.trim(option.useResize) 		|| 'N';				
				var bizSection 	= $.trim(option.bizSection) 	|| '';
				var onLoad 		= option.onLoad ? option.onLoad : function(){};
				
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
				
				switch (option.editorType) {
				case "3":
				case "xfree": 
					$(".writeEdit").css("min-height", "");
					html += '<iframe id="' + option.containerID + 'Frame" name="' + option.containerID + '" ';
					html += 'marginwidth="0" frameborder="0" scrolling="yes" style="width:100%; height:' + frameH + 'px;" ';
					html += 'src="' + Common.getBaseConfig("xfreeEditorURL") +'XFreeEditor.html' + resourceVersion + '"></iframe>';
					break;
				case "8":
				case "dext5":
					html += '<iframe id="' + option.containerID + 'Frame" name="' + option.containerID + '" ';
					html += 'marginwidth="0" frameborder="0" scrolling="yes" width="100%" height="' + frameH + '" ';
					html += 'src="' + Common.getBaseConfig("dext5EditorURL") +'Dext5.html' + resourceVersion + '"></iframe>';
	                break;
				case "9":
				case "ch": // ChEditor
					html += '<script type="text/javascript" src="/WebSite/Common/ExControls/Cheditor/cheditor.js' + resourceVersion + '"></script>';
	                html += '<iframe id="cheditorFrame" src="/WebSite/Approval/Forms/Templates/common/Cheditor.html' + resourceVersion + '" marginwidth="0" frameborder="0" scrolling="no" width="100%" height="500" ></iframe>';
	                html += '<script language="javascript" event="OnControlInit">setTimeout("setEditor()", 1000);</script>';//width="730" height="600"
	                break;
	            case "10":
	            case "synap":
	            	html += '<iframe id="' + option.containerID + 'Frame" name="' + option.containerID + '" ';
					html += 'marginwidth="0" frameborder="0" scrolling="no" width="100%" height="' + frameH + '" ';
					html += 'src="' + Common.getBaseConfig("synapEditorURL") +'SynapEditor.html' + resourceVersion + '"></iframe>';
	            	break;
	            case "11":
	            case "ck":
	            	html += '<iframe id="' + option.containerID + 'Frame" name="' + option.containerID + '" ';
	            	html += 'marginwidth="0" frameborder="0" scrolling="no" width="100%" height="' + frameH + '" ';
	            	html += 'src="' + Common.getBaseConfig("ckEditorURL") +'CKEditor.html' + resourceVersion + '"></iframe>';
	            	break;
	            case "12":
	            case "webhwpctrl":
	            	html += '<iframe id="' + option.containerID + 'Frame" name="' + option.containerID + '" doctype="' + option.doctype + '" ';
	            	html += 'marginwidth="0" frameborder="0" scrolling="no" width="100%" height="' + frameH + '" ';
	            	html += 'src="' + Common.getBaseConfig("webhwpctrlEditorURL") +'WebHwpCtrlEditor.html' + resourceVersion + '"></iframe>';
	            	break;
				case "13":
				case "covieditor":
					html += '<iframe id="' + option.containerID + 'Frame" name="' + option.containerID + '" doctype="' + option.doctype + '" ';
					html += 'marginwidth="0" frameborder="0" scrolling="no" width="100%" height="' + frameH + '" ';
					
					// 23.08.17, 기존 html 연결 파일을 jsp로 변경하여 수정 후 인터넷 기록 삭제 최소화.
					html += 'src="' + Common.getBaseConfig("coviEditorURL") +'covieditor.jsp"></iframe>';
					
					break;
				case "14":
				case "keditor":
					html += '<iframe id="' + option.containerID + 'Frame" name="' + option.containerID + '" ';
					html += 'marginwidth="0" frameborder="0" scrolling="yes" width="100%" height="' + frameH + '" ';
					html += 'src="' + Common.getBaseConfig("raonkEditorURL") +'KEditor.html' + resourceVersion + '"></iframe>';
	                break;
	            default:
	                break;
				}
				$('#' + target).html(html);
			},
			getBody : function(editorType, containerID, plainText){
				var bodyData = '';
				var frontStrage = (typeof Common != 'undefined') ? Common.getBaseConfig('FrontStorage').replace('{0}', '') : 
						(typeof mobile_comm_getBaseConfig != 'undefined') ? mobile_comm_getBaseConfig('FrontStorage').replace('{0}', '') : '';
				switch (editorType) {
				case "3":
				case "xfree": 
					bodyData = document.getElementById(containerID + 'Frame').contentWindow.xfe.getBodyValue();
					break;
				case "8":
				case "dext5":
					if(document.getElementById(containerID + 'Frame') != null){
						var bodyDom = document.getElementById(containerID + 'Frame').contentWindow.DEXT5.getDext5BodyDom();
						$.each($(bodyDom).find("img"), function(idx, el){
							if(el.src.indexOf(location.origin) > -1 && el.src.indexOf(frontStrage) == -1) el.src = el.src.replace(location.origin, '');
						});
					}
					if(coviEditor.editorVariables[containerID].bizSection != null && coviEditor.editorVariables[containerID].bizSection != undefined
							&& coviEditor.editorVariables[containerID].bizSection == "Mail"){
						bodyData = document.getElementById(containerID + 'Frame').contentWindow.DEXT5.getHtmlValueEx(containerID).replace(/&quot;/gi, "'"); //맑은 고딕 폰트 스타일 깨짐 방지
					}else{
						bodyData = document.getElementById(containerID + 'Frame').contentWindow.DEXT5.getBodyValue(containerID).replace(/&quot;/gi, "'");
					}
	                break;
				case "9":
				case "ch": // ChEditor
	                
	                break;
	            case "10":
	            case "synap":
					bodyData = document.getElementById(containerID + 'Frame').contentWindow.editor.getPublishingHtml();
	                break;
	            case "11":
	            case "ck":
	            	bodyData = document.getElementById(containerID + 'Frame').contentWindow.cke.document.getBody().getHtml();
	            	break;
	            case "12":
	            case "webhwpctrl":
	            	document.getElementById(containerID + 'Frame').contentWindow.HwpCtrl.GetTextFile("HTML", "", function(data){
	            		bodyData = Base64.utf8_to_b64(data);
	            	});
	            	break;
				case "13":
				case "covieditor":
					var editor = document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor;
					var bodyDom = this.getBodyDom(editorType, containerID);
					var enableOutputWrapper = editor.getParam('output_wrapper', false);
					var covi_out = false;
					
					// /covicore/common/photo/photo.do를 가져오는 인라인 이미지 처리 시, src치환 오류가 발생. src내에서 오류발생되는 location.origin과 일치하는 내용 제거
					$.each($(bodyDom).find("img"), function(idx, el){
						if(el.src.indexOf(location.origin) > -1 && el.src.indexOf(frontStrage) == -1) el.src = el.src.replace(location.origin, '');
					});
					if (enableOutputWrapper && $(bodyDom).find(".covi_out_wrapper").length <= 0) {
						covi_out = true;
					}
					bodyData = editor.getContent({format: 'raw', covi_out: covi_out});
					bodyData = bodyData.replace(/&quot;/gi, "'");
					
					/*
					bodyData = document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor.getContent({covi_out: false});
					*/
					break;
				case "14":
				case "keditor":
					if(coviEditor.editorVariables[containerID].bizSection != null && coviEditor.editorVariables[containerID].bizSection != undefined
							&& coviEditor.editorVariables[containerID].bizSection == "Mail"){
						document.getElementById(containerID + 'Frame').contentWindow.k_editor_fn_getHtmlValueEx("htmlex", function(data){
		            		bodyData = data.strData;
		            	});
					}else{
						document.getElementById(containerID + 'Frame').contentWindow.k_editor_fn_getBodyValue("body", function(data){
		            		bodyData = data.strData;
		            	});
						bodyData = bodyData.replace(/&quot;/gi, "'");
					}
	                break;
   	            default:
	                break;
				}
				
				if(plainText == undefined || plainText == false){
					var imgInfo = coviEditor.getImages(editorType, containerID);

					if(imgInfo != ""){
						$(imgInfo.split("|")).each(function(idx,imgSrc){
							if(imgSrc.trim() != ""){
								bodyData = bodyData.replaceAll(imgSrc, "‡"+idx+"‡");
							}
						});
						
						bodyData = bodyData.replace(/src\s*=\s*["|'](‡\d*‡)["|']/gmi,"$1");
					}

				}

				var backImg = coviEditor.getBackgroundImage(editorType, containerID);
				if(backImg != null && backImg != "") {
					if(backImg.trim() != ""){
						bodyData = bodyData.replaceAll(backImg, "‡"+9999+"‡");
					}
				}
				return bodyData;
			},
			getImages : function(editorType, containerID){
				var retImgInfo = '';
				switch (editorType) {
				case "3":
				case "xfree": 
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
					
					break;
				case "8":
				case "dext5":
					var arrimg =  document.getElementById(containerID + 'Frame').contentWindow.DEXT5.getImages().split('\u000c');
					var dextHtmlValue = document.getElementById(containerID + 'Frame').contentWindow.DEXT5.getHtmlValueEx(containerID);
			        dextHtmlValue = dextHtmlValue.replace(dextHtmlValue.substring(dextHtmlValue.indexOf('<title>') + 7, dextHtmlValue.indexOf('</title>')), '');

		            var imgInfo = "";

		            for (var i = 0; i < arrimg.length; i++) {
		                var img = arrimg[i];
		                var imgPath = img.split('\u000b')[0];//.replace(location.protocol + '//' + location.host,'');
		                imgInfo += imgPath + "|";
		            }
		            if (imgInfo.length > 0) {
		                imgInfo = imgInfo.substr(0, (imgInfo.length - 1));
		            }

		            retImgInfo = imgInfo;
		            
	                break;
				case "9":
				case "ch": // ChEditor
	                
	                break;
	            case "10":
	            case "synap": // SynapEditor
	            	var imgInfo = "";
	            	var synamHtmlValue = document.getElementById(containerID + 'Frame').contentWindow.editor.getPublishingHtml();
	            	
	            	if ($(synamHtmlValue).find("img").length > 0) {
		                 $(synamHtmlValue).find("img").each(function () {
		                      imgInfo += $(this).attr("src") + "|";
		                 });
		            }
	                
	            	if (imgInfo.length > 0) {
			             imgInfo = imgInfo.substr(0, (imgInfo.length - 1));
			        }
	            	 
	            	retImgInfo = imgInfo;
	            	 
	                break;
	            case "11":
	            case "ck":
	            	var imgInfo = "";
	            	var imgArray = document.getElementById(containerID + 'Frame').contentWindow.cke.document.getElementsByTag("img").$;
	            	
	            	$.each(imgArray, function(){
	            		imgInfo += $(this).attr("src") + "|";
	            	});
	            	
	            	if (imgInfo.length > 0) {
			             imgInfo = imgInfo.substr(0, (imgInfo.length - 1));
			        }
	            	 
	            	retImgInfo = imgInfo;
	            	 
	                break;
	            case "12":
	            case "webhwpctrl":
	            	break;
				case "13":
				case "covieditor":
					var imgInfo = "";
					var coviHtmlValue = document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor.getContent();

					if ($(coviHtmlValue).find("img").length > 0) {
						$(coviHtmlValue).find("img").each(function () {
							imgInfo += $(this).attr("src") + "|";
						});
					}

					if (imgInfo.length > 0) {imgInfo = imgInfo.substr(0, (imgInfo.length - 1));
					}

					retImgInfo = imgInfo;
					break;
				case "14":
				case "keditor":
					var arrimg =  document.getElementById(containerID + 'Frame').contentWindow.RAONKEDITOR.getImages().split('\u000c');
					var keditorHtmlValue = "";
					document.getElementById(containerID + 'Frame').contentWindow.k_editor_fn_getHtmlValueEx('xfe', function(data){
		            	keditorHtmlValue = data.strData;
		            });
			        keditorHtmlValue = keditorHtmlValue.replace(keditorHtmlValue.substring(keditorHtmlValue.indexOf('<title>') + 7, keditorHtmlValue.indexOf('</title>')), '');

		            var imgInfo = "";

		            for (var i = 0; i < arrimg.length; i++) {
		                var img = arrimg[i];
		                var imgPath = img.split('\u000b')[0];//.replace(location.protocol + '//' + location.host,'');
		                imgInfo += imgPath + "|";
		            }
		            if (imgInfo.length > 0) {
		                imgInfo = imgInfo.substr(0, (imgInfo.length - 1));
		            }

		            retImgInfo = imgInfo;
		            
	                break;
	            default:
	                break;
				}
				
				return retImgInfo;
			},
			getBodyText : function(editorType, containerID){
				var bodyData = '';
				switch (editorType) {
				case "3":
				case "xfree": 
					bodyData = document.getElementById(containerID + 'Frame').contentWindow.xfe.getTextValue();
					break;
				case "8":
				case "dext5":
					bodyData = document.getElementById(containerID + 'Frame').contentWindow.DEXT5.getBodyTextValue(containerID);
					bodyData = bodyData.replace(/&quot;/gi, "'");
	                break;
				case "9":
				case "ch": // ChEditor
	                
	                break;
	            case "10":
	            case "synap": // SynapEditor
	            	bodyData = document.getElementById(containerID + 'Frame').contentWindow.editor.getTextContent();
	                break;
	            case "11":
	            case "ck":
	            	bodyData = document.getElementById(containerID + 'Frame').contentWindow.cke.document.getBody().getText();
	            	break;
	            case "12":
	            case "webhwpctrl":
	            	document.getElementById(containerID + 'Frame').contentWindow.HwpCtrl.GetTextFile("TEXT", "", function(data){
	            		bodyData = data;
	            	});
	            	break;
				case "13":
				case "covieditor":
					bodyData = document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor.getContent({format:"text"});
					break;
				case "14":
				case "keditor":
					document.getElementById(containerID + 'Frame').contentWindow.k_editor_fn_getBodyValue("text", function(data){
		            	bodyData = data.strData;
		            });
	                break;
   	            default:
	                break;
				}
				
				return bodyData;
			},
			setBody : function(editorType, containerID, data){
				var replacedData = data;
				
				switch (editorType) {
				case "3":
				case "xfree": 
					document.getElementById(containerID + 'Frame').contentWindow.xfe.setBodyValue(replacedData);
					break;
				case "8":
				case "dext5":
					//document.getElementById(containerID + 'Frame').contentWindow.DEXT5.setBodyValue(replacedData);
					document.getElementById(containerID + 'Frame').contentWindow.DEXT5.SetHtmlContentsEw(replacedData, containerID);
	                break;
				case "9":
				case "ch": // ChEditor
	                
	                break;
	            case "10":
	            case "synap": // SynapEditor
	            	document.getElementById(containerID + 'Frame').contentWindow.editor.openHTML(replacedData);
	                break;
	            case "11":
	            case "ck":
	            	document.getElementById(containerID + 'Frame').contentWindow.cke.setData(replacedData);
	            	break;
	            case "12":
	            case "webhwpctrl":
	            	document.getElementById(containerID + 'Frame').contentWindow.HwpCtrl.SetTextFile(Base64.b64_to_utf8(replacedData), "HTML", "");
	            	break;
				case "13":
				case "covieditor":
					document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor.setContent(replacedData, {format: 'raw', covi_out: true});
					// 23.02.08, covision 자체 추가. 서명이나 양식까지 undo 하지 못하도록 undo level 초기화.
					document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor.undoManager.reset();
					break;
				case "14":
				case "keditor":
					document.getElementById(containerID + 'Frame').contentWindow.RAONKEDITOR.SetHtmlContentsEw(replacedData, containerID);
	                break;
	            default:
	                break;
				}
			},
			hide : function(editorType, containerID){
				switch (editorType) {
				case "3":
				case "xfree": 
					$(document.getElementById(containerID + 'Frame')).hide();
					if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","none");
					}
					break;
				case "8":
				case "dext5":
					document.getElementById(containerID + 'Frame').contentWindow.DEXT5.hidden(containerID);
					if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","none");
					}
	                break;
				case "9":
				case "ch": // ChEditor
	                
	                break;
	            case "10":
	            case "synap": // SynapEditor
	            	$(document.getElementById('tbContentElementFrame')).hide();
					if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","none");
					}
	                break;
	            case "11":
				case "ck": 
					$(document.getElementById(containerID + 'Frame')).hide();
					if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","none");
					}
					break;
				case "12":
	            case "webhwpctrl":
	            	$(document.getElementById(containerID + 'Frame')).hide();
					if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","none");
					}
	            	break;
				case "13":
				case "covieditor":
					$(document.getElementById(containerID + 'Frame')).hide();
					if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","none");
					}
					break;
				case "14":
				case "keditor":
					$(document.getElementById(containerID + 'Frame')).hide();
					if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","none");
					}
					break;
	            default:
	                break;
				}
			},
			show:function(editorType, containerID){
				switch (editorType) {
				case "3":
				case "xfree":
					if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","");
					}
	            	$(document.getElementById(containerID + 'Frame')).show();
	            	break;
				case "8":
				case "dext5":
					if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","");
					}
					document.getElementById(containerID + 'Frame').contentWindow.DEXT5.show(containerID);
					document.getElementById(containerID + 'Frame').contentWindow.resizeHeight();
	                break;
				case "9":
				case "ch": // ChEditor
	                
	                break;
	            case "10":
	            case "synap": // SynapEditor
	            	if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","");
					}
	            	$(document.getElementById('tbContentElementFrame')).show();
	            	document.getElementById(containerID + 'Frame').contentWindow.resizeHeight();
	                break;
	            case "11":
	            case "ck":
	            	if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","");
					}
	            	$(document.getElementById(containerID + 'Frame')).show();
	            	break;
	            case "12":
	            case "webhwpctrl":
	            	if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","");
					}
	            	$(document.getElementById(containerID + 'Frame')).show();
	            	break;
				case "13":
				case "covieditor":
					if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","");
					}
					$(document.getElementById(containerID + 'Frame')).show();
					break;
				case "14":
				case "keditor":
					if(coviEditor.editorVariables[containerID].target != undefined){
						$("#"+coviEditor.editorVariables[containerID].target).css("display","");
					}
					$(document.getElementById(containerID + 'Frame')).show();
					break;
	            default:
	                break;
				}
			},
			/*Editor 내용을 DOM 형식으로 조회*/
			getBodyDom : function(editorType, containerID){
				switch (editorType) {
				case "3":
				case "xfree":
					return document.getElementById(containerID + 'Frame').contentWindow.xfe.getBody();
				case "8":
				case "dext5":
					return document.getElementById(containerID + 'Frame').contentWindow.DEXT5.getDext5BodyDom("dext5_design_"+containerID);
				case "9":
	            case "ch": // ChEditor
	                
	                break;
	            case "10":
	            case "synap": // SynapEditor
	                return document.getElementById(containerID + 'Frame').contentWindow.editor.contentsManager.elContents;
	            case "11":
	            case "ck":
	            	return document.getElementById(containerID + 'Frame').contentWindow.cke.document.getBody().$;
	            case "12":
	            case "webhwpctrl":
	            	break;
				case "13":
				case "covieditor":
					return document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor.getBody();
				case "14":
				case "keditor":
					return document.getElementById(containerID + 'Frame').contentWindow.RAONKEDITOR.GetBodyDom(containerID);
	            default:
	                break;
				}
			},
			getBackgroundImage : function(editorType, containerID){
				switch (editorType) {
					case "3":
					case "xfree":
						return null;
					case "8":
					case "dext5":
						return null;
					case "9":
					case "ch": // ChEditor
						return null;
					case "10":
					case "synap": // SynapEditor
						return null;
					case "11":
					case "ck":
						return null;
					case "12":
					case "webhwpctrl":
						return null;
					case "13":
					case "covieditor":
						var editor = document.getElementById(containerID + 'Frame').contentWindow.COVIEDITOR.activeEditor;
						var bodyEl = editor.getBody();

						if (bodyEl.style.cssText.length > 0) {
							var backgroundImgUrl = editor.dom.getStyle(bodyEl, 'backgroundImage', true); //배경이미지 url만 추출
							if(backgroundImgUrl != null && backgroundImgUrl != "" && backgroundImgUrl !== "none") {
								return backgroundImgUrl.split('(')[1].split('"')[1];
							}
						}
						return null;
					case "14":
					case "keditor":
						return null;
					default:
						break;
				}

			},
			toggleEditLock: function(isLock, editorType, containerID) {
				switch (editorType) {
					case "13":
					case "covieditor":
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

						this.setBody(editorType, containerID, editor.getContent());
						break;
					default:
						break;
				}
			}
			
	};
	
	window.coviEditor = coviEditor;
	
})(window);

