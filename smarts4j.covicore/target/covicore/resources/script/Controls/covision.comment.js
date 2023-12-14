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
///<createDate>2017.09.11</createDate> 
///<lastModifyDate></lastModifyDate> 
///<version>0.8.0</version>
///<summary> 
///댓글 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/

if (!window.coviComment) {
    window.coviComment = {};
}

(function(window) {
	
	var coviComment = {
			dictionary : {
				like : '좋아요;Like;ええ、いいですよ;好;;;;;;',
				comment : '댓글;Comments;コメント;回帖;;;;;;',
				reply : '답글;reply;返事;跟帖;;;;;;;;',
				msg_leaveComment : '댓글을 남겨보세요.;Leave a comment.;書き込みを残してみてください;留言吧;;;;;;;',
				uploadImage : '이미지 올리기;Image raising;イメージ上げる;提升形象;文件附加;;;;;;',
				attach : '파일첨부;Attach file;ファイル添付;;;;;;;;;',
				map : '지도 올리기;Map up;指導上げる;地图;;;;;;;;;',
				save : '등록;Registration;登録;注册;;;;;;;;',
				msg_reply : '답글을 남겨보세요.;leave a reply.;返事を残してみてください;请留下留言;;;;;;;',
				msg_checkComment : '댓글을 입력하여 주세요.;Enter comment.;書き込みを入力してください;请输入留言;;;;;;;',
				msg_throwError : '오류가 발생하였습니다.;An error has occurred.;エラーが発生しました;发生错误;;;;;;;;',
				msg_checkReply : '답글을 입력하여 주세요.;Enter reply.;返事を入力してください;请输入回复;;;;;;;;',
				del : '삭제;delete;削除;删除;;;;;;;;;;',
				msg_deleted : '작성자에 의해 삭제된 글입니다.;Deleted by author.;作成者によって削除されたものです;是被制作者删除的文章;;;;;;;;;',
				more : '더보기;more;もっと見る;查看更多;;;;;;;;;;',
				moreReply : '답글 더 보기;Read more;返事もっと見る;回复回帖;;;;;;;;;;',
				msg_checkDupe : '이미 존재하는 파일입니다.;File already exists.;すでに存在するファイルです;已存在的文件;;;;;;;;;',
				delPhoto : '사진 삭제;Delete a picture;写真の削除;删除照片;;;;;;;',
				edit : '수정;Modify;修正;删除;;;;;;;',
				oneSelfWrite : '본인작성;Create Yourself;本人作成;本人制作;;;;;;;'
			},
			/*
			 * File 처리는 Front -> Back
			 * */
			commentVariables : {
				lang : 'ko',
				newBadgeTime : '1', //hour 기준
				rowCount : '5',
				commentDelAuth : false,
				//servicePath : Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + 'comment/', //변경하지 않음
				servicePath : '', // 불필요(파일저장시 fileid 기준으로 storageid 조회하도록 변경)
				frontPath : '/FrontStorage/' + Common.getSession("DN_Code") + "/",
				//backPath : Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + 'comment/',
				backPath : '', // 불필요(파일저장시 fileid 기준으로 storageid 조회하도록 변경)
				hashTagOption : {
						allowedChar : ['_', '-'],
						hashChar : ['#']
				}
			},
			setConfig : function(elemID, tarType, tarID, msgSetting, folderType, menuName){
				coviComment.commentVariables.folderType = folderType;
				coviComment.commentVariables[elemID] = {
						targetType : tarType,
						targetID : tarID,
						frontFileInfos : [],
						mapFileInfos : [],
						mentionInfos : {},
						rewriteFileInfos : [],
						rewriteMentionInfos : {},
						rewriteFrontFileInfos : [],
						rewriteMapFileInfos : [],
						messageSetting : {
							ObjectType : "",
							ObjectID : "",
							MessageID : "",
							SubMsgID : "",
							IsUse : "Y",
							IsDelay : "N",
							ReservedDate : "",
							XSLPath : "",
							Width : "",
							Height : "",
							PopupURL : "",
							GotoURL : "",
							MobileURL : "",
							OpenType : "",
							SenderCode : "",
					        RegistererCode : "",
					        ApprovalState : "P", //확인 필요
					        ApproverCode : "C", //확인 필요
					        ReceiversCode : "",
					        MessagingSubject : "",
					        MessageContext : "",
					        ReceiverText : "", //요약된 내용
					        MediaType : "",
					        ServiceType : "",
					        MsgType : "Comment",
					        MentionMsgType : "",
					        ReservedStr1 : menuName != "" ? menuName : "",
					        ReservedStr2 : "",
					        ReservedStr3 : "",
					        ReservedStr4 : "",
					        ReservedInt1 : "",
					        ReservedInt2 : ""
						}
				};
				//message 처리를 위한 기본 변수 초기화
				if(msgSetting != null){
					if(msgSetting.ObjectType != null && msgSetting.ObjectType != undefined){
						coviComment.commentVariables[elemID].messageSetting.ObjectType = msgSetting.ObjectType;
					}
					
					if(msgSetting.ObjectID != null && msgSetting.ObjectID != undefined){
						coviComment.commentVariables[elemID].messageSetting.ObjectID = msgSetting.ObjectID;
					}
					
					if(msgSetting.MessageID != null && msgSetting.MessageID != undefined){
						coviComment.commentVariables[elemID].messageSetting.MessageID = msgSetting.MessageID;
					}
					
					if(msgSetting.SubMsgID != null && msgSetting.SubMsgID != undefined){
						coviComment.commentVariables[elemID].messageSetting.SubMsgID = msgSetting.SubMsgID;
					}
					
					if(msgSetting.ReservedDate != null && msgSetting.ReservedDate != undefined){
						coviComment.commentVariables[elemID].messageSetting.ReservedDate = msgSetting.ReservedDate;
					}
					
					if(msgSetting.XSLPath != null && msgSetting.XSLPath != undefined){
						coviComment.commentVariables[elemID].messageSetting.XSLPath = msgSetting.XSLPath;
					}
					
					if(msgSetting.Width != null && msgSetting.Width != undefined){
						coviComment.commentVariables[elemID].messageSetting.Width = msgSetting.Width;
					}
					
					if(msgSetting.Height != null && msgSetting.Height != undefined){
						coviComment.commentVariables[elemID].messageSetting.Height = msgSetting.Height;
					}
					
					if(msgSetting.PopupURL != null && msgSetting.PopupURL != undefined){
						coviComment.commentVariables[elemID].messageSetting.PopupURL = msgSetting.PopupURL;
					}
					
					if(msgSetting.GotoURL != null && msgSetting.GotoURL != undefined){
						coviComment.commentVariables[elemID].messageSetting.GotoURL = msgSetting.GotoURL;
					}

					if(msgSetting.MobileURL != null && msgSetting.MobileURL != undefined){
						coviComment.commentVariables[elemID].messageSetting.MobileURL = msgSetting.MobileURL;
					}
					
					if(msgSetting.OpenType != null && msgSetting.OpenType != undefined){
						coviComment.commentVariables[elemID].messageSetting.OpenType = msgSetting.OpenType;
					}
					
					if(msgSetting.SenderCode != null && msgSetting.SenderCode != undefined){
						coviComment.commentVariables[elemID].messageSetting.SenderCode = msgSetting.SenderCode;
					}
					
					if(msgSetting.RegistererCode != null && msgSetting.RegistererCode != undefined){
						coviComment.commentVariables[elemID].messageSetting.RegistererCode = msgSetting.RegistererCode;
					}
					
					if(msgSetting.ReceiversCode != null && msgSetting.ReceiversCode != undefined){
						coviComment.commentVariables[elemID].messageSetting.ReceiversCode = msgSetting.ReceiversCode;
					}
					
					if(msgSetting.MessagingSubject != null && msgSetting.MessagingSubject != undefined){
						coviComment.commentVariables[elemID].messageSetting.MessagingSubject = msgSetting.MessagingSubject;
					}
					
					if(msgSetting.MessageContext != null && msgSetting.MessageContext != undefined){
						coviComment.commentVariables[elemID].messageSetting.MessageContext = msgSetting.MessageContext;
					}
					
					if(msgSetting.MsgType != null && msgSetting.MsgType != undefined){
						coviComment.commentVariables[elemID].messageSetting.MsgType = msgSetting.MsgType;
					}
					
					if(msgSetting.MentionMsgType != null && msgSetting.MentionMsgType != undefined){
						coviComment.commentVariables[elemID].messageSetting.MentionMsgType = msgSetting.MentionMsgType;
					}
					
					if(msgSetting.ReceiverText != null && msgSetting.ReceiverText != undefined){
						coviComment.commentVariables[elemID].messageSetting.ReceiverText = msgSetting.ReceiverText;
					}
					
					if(msgSetting.MediaType != null && msgSetting.MediaType != undefined){
						coviComment.commentVariables[elemID].messageSetting.MediaType = msgSetting.MediaType;
					}
					
					if(msgSetting.ServiceType != null && msgSetting.ServiceType != undefined){
						coviComment.commentVariables[elemID].messageSetting.ServiceType = msgSetting.ServiceType;
					}
					
					if(msgSetting.ReservedStr1 != null && msgSetting.ReservedStr1 != undefined){
						coviComment.commentVariables[elemID].messageSetting.ReservedStr1 = msgSetting.ReservedStr1;
					}
					
					if(msgSetting.ReservedStr2 != null && msgSetting.ReservedStr2 != undefined){
						coviComment.commentVariables[elemID].messageSetting.ReservedStr2 = msgSetting.ReservedStr2;
					}
					
					if(msgSetting.ReservedStr3 != null && msgSetting.ReservedStr3 != undefined){
						coviComment.commentVariables[elemID].messageSetting.ReservedStr3 = msgSetting.ReservedStr3;
					}
					
					if(msgSetting.ReservedStr4 != null && msgSetting.ReservedStr4 != undefined){
						coviComment.commentVariables[elemID].messageSetting.ReservedStr4 = msgSetting.ReservedStr4;
					}
					
					if(msgSetting.ReservedInt1 != null && msgSetting.ReservedInt1 != undefined){
						coviComment.commentVariables[elemID].messageSetting.ReservedInt1 = msgSetting.ReservedInt1;
					}
					
					if(msgSetting.ReservedInt2 != null && msgSetting.ReservedInt2 != undefined){
						coviComment.commentVariables[elemID].messageSetting.ReservedInt2 = msgSetting.ReservedInt2;
					}
				}
				
				if (window[elemID + '_callImgUploadCallBack'] == undefined) {
					window[elemID + '_callImgUploadCallBack'] = function(data, elemID){
						//이미지 append 영역 생성
						if(!$('#' + elemID + ' .fileUpview.main').length){
							$('<ul class="clearFloat fileUpview main"></ul>').insertAfter('#' + elemID + ' .commInput.main .txtArearBox');
						}
						
						var liHtml = '';
						for (var i = 0; i < data.length; i++) {
							liHtml += coviComment.makeImgFileRow(data[i], elemID, 'frontFileInfos');
						}
						
						$('#' + elemID + ' .fileUpview.main').append(liHtml);
						
						Common.close(elemID + "_CoviCommentImgUp");
						$('#' + elemID +' .commInput').addClass('focus');
					};
				}
				
				if (window[elemID + '_callFileUploadCallBack'] == undefined) {
					window[elemID + '_callFileUploadCallBack'] = function(data, elemID){
						var html = '';
						for (var i = 0; i < data.length; i++) {
							html += coviComment.makeFileRow(data[i], elemID, 'frontFileInfos');
						}
						
						//$('.commInpuBox').append(html);
						$(html).insertBefore('#' + elemID + ' .commInput.main .ui-autocomplete-multiselect')

						Common.close(elemID + "_CoviCommentFileUp");
						$('#' + elemID +' .commInput').addClass('focus');
					};
				}
				
				if (window[elemID + '_callMapCallBack'] == undefined) {
					window[elemID + '_callMapCallBack'] = function(data, elemID){
						//이미지 append 영역 생성
						if(!$('#' + elemID + ' .fileUpview.main').length){
							$('<ul class="clearFloat fileUpview main"></ul>').insertAfter('#' + elemID + ' .commInput.main .txtArearBox');
						}
						
						$('#' + elemID + ' .fileUpview.main').append(coviComment.makeMapRow(data, elemID, 'mapFileInfos'));
						
						Common.close(elemID + "_CoviCommentMap");
					};
				}
				
				if (window[elemID + '_callReImgUploadCallBack'] == undefined) {
					window[elemID + '_callReImgUploadCallBack'] = function(data, elemID){
						//이미지 append 영역 생성
						if(!$('#' + elemID + ' .fileUpview.rewrite').length){
							$('<ul class="clearFloat fileUpview rewrite"></ul>').insertAfter('#' + elemID + ' .commInput.rewrite .txtArearBox');
						}
						
						var liHtml = '';
						for (var i = 0; i < data.length; i++) {
							liHtml += coviComment.makeImgFileRow(data[i], elemID, 'rewriteFrontFileInfos');
						}
						
						$('#' + elemID + ' .fileUpview.rewrite').append(liHtml);
						
						Common.close(elemID + "_CoviCommentReImgUp");
						$('.commInput .rewrite').addClass('focus');
					};
				}
				
				if (window[elemID + '_callReFileUploadCallBack'] == undefined) {
					window[elemID + '_callReFileUploadCallBack'] = function(data, elemID){
						var html = '';
						for (var i = 0; i < data.length; i++) {
							html += coviComment.makeFileRow(data[i], elemID, 'rewriteFrontFileInfos');
						}
						
						//$('.commInpuBox').append(html);
						$(html).insertBefore('#' + elemID + ' .commInput.rewrite .ui-autocomplete-multiselect')

						Common.close(elemID + "_CoviCommentReFileUp");
						$('.commInput .rewrite').addClass('focus');
					};
				}
				
				if (window[elemID + '_callReMapCallBack'] == undefined) {
					window[elemID + '_callReMapCallBack'] = function(data, elemID){
						//이미지 append 영역 생성
						if(!$('#' + elemID + ' .fileUpview.rewrite').length){
							$('<ul class="clearFloat fileUpview rewrite"></ul>').insertAfter('#' + elemID + ' .commInput.rewrite .txtArearBox');
						}
						
						$('#' + elemID + ' .fileUpview.rewrite').append(coviComment.makeMapRow(data, elemID, 'rewriteMapFileInfos'));
						
						Common.close(elemID + "_CoviCommentReMap");
					};
				}
			},
			load : function(elemID, targetServiceType, targetID, msgSetting, folderType){
				//set locale
				var sessionLang = Common.getSession("lang");
				if(typeof sessionLang != "undefined" && sessionLang != ""){
					coviComment.commentVariables.lang = sessionLang;
				}
				
				if(targetServiceType == "Board"){
					var menuName = "";
					if(typeof(menuID) != "undefined") {
						if(window.hasOwnProperty('headerdata')) {
							$.each(headerdata, function(idx, el){
								if (el.MenuID == menuID){
									menuName = CFN_GetDicInfo(el.MultiDisplayName);
								}
							});
						}
					}
				}
				
				//set config
				coviComment.setConfig(elemID, targetServiceType, targetID, msgSetting, folderType, menuName);
				
				var html = ''
				html += '<div class="commentView">';
				//	<!--좋아요가 1이상일 경우 acitve 클래스를 아래 div에 추가-->
				html += '	<div class="commentInfo comHeart" data-liketype="emoticon" data-emoticon="heart">';
				html += '		<a href="javascript:;" onclick="coviComment.addLikeCount(this, \'' + targetServiceType + '\', \'' + targetID + '\');" class="selected">';
				html += '			<i class="fa fa-heart-o fa-2x" aria-hidden="true"></i>' + CFN_GetDicInfo(coviComment.dictionary.like, coviComment.commentVariables.lang) + '<span name="likeCnt">0</span>&nbsp;';
				html += '		</a>';
				html += '		<div class="comCount">';
				//html += '			<span class="icon">댓글</span><span class="count">2</span><span class="cycleNew new">N</span>';
				html += '			<span class="icon">' + CFN_GetDicInfo(coviComment.dictionary.comment, coviComment.commentVariables.lang) + '</span><span class="count">0</span>';
				html += '		</div>';
				html += '	</div>';
				html += '	<div class="commInput main">';
				html += '		<div class="commInpuBox">';
				html += '			<div class="txtArearBox">';
				html += '				<textarea class="HtmlCheckXSS ScriptCheckXSS" placeholder="' + CFN_GetDicInfo(coviComment.dictionary.msg_leaveComment, coviComment.commentVariables.lang) + '"></textarea>';
				html += '				<div class="commentBtn">';
				html += '					<a href="javascript:;" class="btnImgUpLoad" onclick="coviComment.callImgUpload(\'' + elemID + '\');">' + CFN_GetDicInfo(coviComment.dictionary.uploadImage, coviComment.commentVariables.lang) + '</a>';
				html += '					<a href="javascript:;" class="btnFileUpLoad" onclick="coviComment.callFileUpload(\'' + elemID + '\');">' + CFN_GetDicInfo(coviComment.dictionary.attach, coviComment.commentVariables.lang) + '</a>';
			/*	html += '					<a href="javascript:;" class="btnMapUpLoad" onclick="coviComment.callMap(\'' + elemID + '\');">' + CFN_GetDicInfo(coviComment.dictionary.map, coviComment.commentVariables.lang) + '</a>';*/
				html += '				</div>';
				html += '			</div>';
				html += '			<div class="ui-autocomplete-multiselect"></div>';
				html += '		</div>';
				html += '		<a href="javascript:;" class="btnTypeDefault btnTypeBg useEnterSubmit" onclick="coviComment.save(\'' + elemID + '\');return false;">' + CFN_GetDicInfo(coviComment.dictionary.save, coviComment.commentVariables.lang) + '</a>';
				html += '	</div>';
				html += '</div>';
				
				$('#' + elemID).html(html);
				coviComment.bindWriteEvent(elemID, 'write');
				//load like
				coviComment.loadLikeCount(elemID, targetServiceType, targetID);
				//load comment count
				coviComment.reloadCommentCount(elemID);
				//load comment
				coviComment.loadView(elemID, '0', '0');
			},
			reloadCommentCount : function(elemID){
				$.ajax({
					type : "POST",
				    url : "/covicore/comment/getCommentCount.do",
			        data : {
			        	'TargetType' : coviComment.commentVariables[elemID].targetType,
			        	'TargetID' : coviComment.commentVariables[elemID].targetID
			        },
			        success : function(res){
			        	$('#' + elemID + ' .comCount .count').html(res.data);
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/comment/getCommentCount.do", response, status, error);
		       		}
			 	});
			},
			editComment: function(elem, elemID, commentID, parentID){//댓글 수정
				if ($(".rewrite[data-comment-memberof="+commentID+"]").length > 0){
					var writeType = $(".rewrite[data-comment-memberof="+commentID+"]").attr("data-write-type");
					
					$(".commInput .rewrite").remove();
					if (writeType != 'EDIT') this.editComment(elem, elemID, commentID, parentID);
				}
				else {
					$(".commInput .rewrite").remove();
					$(elem).closest('.commCont').after(coviComment.renderRewrite(elemID, commentID, "EDIT"));
					$('#' + elemID + ' .commInput[data-comment-memberof="' + commentID + '"] textarea').val(
	                	$('#' + elemID + ' .commCont[data-comment-id="' + commentID + '"] .conTxt').text().replace(/(<br>|<br\/>|<br \/>)/g, '\r\n')
	            	);
					coviComment.bindWriteEvent(elemID, 'rewrite');
				}
			},
			callReWrite : function(elem, elemID, commentID){
				if ($(".rewrite[data-comment-memberof="+commentID+"]").length > 0){
					var writeType = $(".rewrite[data-comment-memberof="+commentID+"]").attr("data-write-type");
					
					$(".commInput .rewrite").remove();
					if (writeType == 'EDIT') this.callReWrite(elem, elemID, commentID);
				}
				else {
					$(".commInput .rewrite").remove();
					$(elem).closest('.commCont').after(coviComment.renderRewrite(elemID, commentID, "", "0"));
					coviComment.bindWriteEvent(elemID, 'rewrite');
				}
			},
			renderRewrite : function(elemID, commentID, type, parentID){
				var html = '';
				
				if(parentID == "0") {
					html += '<div class="commInput rewrite" data-comment-memberof="' + commentID + '" data-write-type="' + type + '" style="background-color: #eaeaea;">';
				} else {
					html += '<div class="commInput rewrite reply" data-comment-memberof="' + commentID + '" data-write-type="' + type + '" style="background-color: #eaeaea;">';	
				}
				
				html += '	<div class="commInpuBox">';
				html += '		<div class="txtArearBox">';
				html += '			<textarea class="HtmlCheckXSS ScriptCheckXSS" placeholder="' + CFN_GetDicInfo(coviComment.dictionary.reply, coviComment.commentVariables.lang) + '"></textarea>';
				html += '			<a href="javascript:;" class="btnImgUpLoad" onclick="coviComment.callReImgUpload(\'' + elemID + '\');">' + CFN_GetDicInfo(coviComment.dictionary.uploadImage, coviComment.commentVariables.lang) + '</a>';
				html += '			<a href="javascript:;" class="btnFileUpLoad" onclick="coviComment.callReFileUpload(\'' + elemID + '\');">' + CFN_GetDicInfo(coviComment.dictionary.attach, coviComment.commentVariables.lang) + '</a>';
				/*html += '			<a href="javascript:;" class="btnMapUpLoad" onclick="coviComment.callReMap(\'' + elemID + '\');">' + CFN_GetDicInfo(coviComment.dictionary.map, coviComment.commentVariables.lang) + '</a>';*/
				html += '		</div>';
				
				if(type && type == "EDIT"){
					$.ajax({
						type : "POST",
						url : "/covicore/comment/getComment.do",
						data : {
							'CommentID' : commentID
						},
						async: false,
						success : function(res){
							if(res.list != null && res.list.length > 0){
								var files = res.list[0].Context.File;
								coviComment.commentVariables[elemID]['rewriteFrontFileInfos'] = [];
								coviComment.commentVariables[elemID]['rewriteFileInfos'] = [];
								coviComment.commentVariables[elemID]['rewriteMentionInfos'] = {};
								if (res.list[0].Context.Mention){
									coviComment.commentVariables[elemID]['rewriteMentionInfos'] = res.list[0].Context.Mention;
								}	
								
								$.each(files, function(fIdx, file){
									coviComment.commentVariables[elemID]['rewriteFileInfos'].push(file);
									var savedName = file.SavedName;
									var fileName = file.FileName;
									var convertedSize = coviFile.convertFileSize(file.Size);
									var fileExt = fileName.substring(fileName.lastIndexOf('.')+1);
									var iconClass = coviComment.getFileIconClassByExt(fileExt);					// 첨부파일 확장자 css class 변환
									
									html += '<p class="fName" data-savedname="' + savedName + '">';
									html += '	<span class="'+iconClass+'">' + fileName + '</span>';
									html += '	<span>(' + convertedSize + ')</span>';
									html += '	<a href="javascript:;" class="btnPhotoRemove gray" onclick="coviComment.deleteFile(this, \'' + elemID + '\', \'rewriteFileInfos\');">' + CFN_GetDicInfo(coviComment.dictionary.del, coviComment.commentVariables.lang) + '</a>';
									html += '</p>';
								});
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/comment/get.do", response, status, error);
						}
					});
				}
				
				html += '		<div class="ui-autocomplete-multiselect"></div>';
				html += '	</div>';
				if (type == "EDIT")
					html += '	<a href="javascript:;" class="btnTypeDefault btnTypeBg useEnterSubmit" onclick="coviComment.edit(\'' + elemID + '\', \'' + commentID + '\');return false;">' + CFN_GetDicInfo(coviComment.dictionary.edit, coviComment.commentVariables.lang) + '</a>';
				else
					html += '	<a href="javascript:;" class="btnTypeDefault btnTypeBg useEnterSubmit" onclick="coviComment.saveRewrite(\'' + elemID + '\', \'' + commentID + '\');return false;">' + CFN_GetDicInfo(coviComment.dictionary.save, coviComment.commentVariables.lang) + '</a>';
				html += '</div>';
				
				return html;
			},
			bindReadEvent : function(elemID){
				$("#"+elemID +" .commCont .fName span").click(function(){
					Common.fileDownLoad($(this).parent().attr("fileID"), $(this).parent().find("span").attr("title"), $(this).parent().attr("fileToken"));
				});
				$("#"+elemID +" .commCont .fName .btnFilePrev").click(function(){
					Common.filePreview($(this).parent().attr("fileID"), $(this).parent().attr("fileToken"), $(this).parent().attr("fileExtention"));					
				});				
			},
			bindWriteEvent : function(elemID, writeType){
				var $txtarea;
				if(writeType == 'rewrite'){
					$txtarea = $('#' + elemID + ' .commInput.rewrite textarea');
				} else {
					$txtarea = $('#' + elemID + ' .commInput.main textarea');
				}
				
				$txtarea.on('focusin', function () {
					$(this).closest('.commInput').addClass('focus');
				});
				
				var fileUploadSelector;
				if(writeType == 'rewrite'){
					fileUploadSelector = '#' + elemID + ' .fileUpview.rewrite';
				} else {
					fileUploadSelector = '#' + elemID + ' .fileUpview.main';
				}
				
				var btnClick = false;
				$(".btnFileUpLoad, .btnImgUpLoad").on("mousedown", function(){
					btnClick = true;
				});	
				
				$txtarea.on('focusout', function () {
					if($(this).val().length < 1 && $(fileUploadSelector).children().length < 1 && !btnClick){
						$(this).closest('.commInput').removeClass('focus');
					}					
					btnClick = false;
				});
				
				var patternString = '(^|\\s)(';
				patternString += coviComment.commentVariables.hashTagOption.hashChar.join("|");
				patternString += ')([a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\\d';
				patternString += coviComment.commentVariables.hashTagOption.allowedChar.join("");
				patternString += ']+)';
				
				var regEx = new RegExp(patternString, "g");
				
				$txtarea.on("blur keyup", function() {
					var str = $(this).val();
					
					var html = '';
					var match;
					while(match = regEx.exec(str)) {
						//arr.push(match[1]);
						//html += '<div class="ui-autocomplete-multiselect-item" data-hashchar="' + match[2] + '">' + match[2] + match[3] + '<span class="ui-icon ui-icon-close"></span></div>';
						html += '<div class="ui-autocomplete-multiselect-item" data-hashchar="' + match[2] + '">' + match[2] + match[3] + '</div>';
					}
					
					//str = str.replace(regEx,'$1<span class="hashtag" data-hashchar="$2">$2$3</span>');
					$(this).parent().parent().children().closest('.ui-autocomplete-multiselect').html(html);
				});
				
				//enterkey
				$txtarea.keypress(function(e) {
			        if (e.keyCode == 13 && !e.shiftKey) {
			            $(this).closest('.commInput').find('.useEnterSubmit').click();
			            return false;
			        }
			    });

				//멘션 대상사 찾기-멘션타입과 코드에 등록되어 있을 경우
				var arrMsgType = Common.getBaseCode("TodoMsgType").CacheData;
				if (coviComment.commentVariables[elemID].messageSetting["MentionMsgType"] != "" && 
						arrMsgType.findIndex(v => v.Code ===  coviComment.commentVariables[elemID].messageSetting["MentionMsgType"]) >= 0 ){
					$txtarea.autocomplete({
						source : function(request, response) {
							if (request.term.substring(0,1) == "@" && request.term.length>2){
					            $.ajax({
					                type : 'post',
					                url : '/covicore/control/getAllUserAutoTagList.do',
					                data : {keyword : request.term.substring(1)},
					                success : function(data) {
					                    response(
					                        $.map(data.list, function(item) {
					                            return {
					                                label : "@"+item["UserName"],
					                                value : item["UserCode"]
					                            }
					                        })
					                    );
					                }
					            });
							}    
				        },
				        select : function(event, ui) {
		    				var item = ui.item;
		    				var type = "UR" ;
	
		    				coviComment.commentVariables[elemID]["mentionInfos"][item.value]=item.label;
							var liHtml = $("<p>",{"class":"date_del","type":"UR", "code":item.value, "text":item.label, "data-elemid":elemID})
											.append($("<a>",{"class":"ui-icon ui-icon-close"}).click(
													function(e, elemID){
														delete coviComment.commentVariables[$(this).closest(".date_del").data("elemid")]["mentionInfos"][$(this).closest(".date_del").attr("code")];
														$(this).closest(".date_del").remove();
													}));
							$txtarea.closest(".txtArearBox").before(liHtml);
							ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
				        },
				        focus : function(event, ui) {
				            return false;
				        },
				       
				        minLength : 1,
				        autoFocus : true,
				        classes : {
				            'ui-autocomplete': 'highlight'
				        },
				        delay : 500,
				        position : { my : 'right top', at : 'right bottom' },
				        close : function(event) {
//				        	coviCmn.traceLog(event);
				        }
					});      
				}	
			},
			getTags : function(elemID, writeType){
				var result = [];
				var $conTags;
				if(writeType == 'main'){
					$conTags = $('#' + elemID + ' .commInput.main .ui-autocomplete-multiselect');
				} else {
					$conTags = $('#' + elemID + ' .commInput.rewrite .ui-autocomplete-multiselect');
				}
				
				$conTags.children('.ui-autocomplete-multiselect-item').each(function () {
					var tagObj = new Object();
					tagObj.label = $(this).text();
					tagObj.hashChar = $(this).attr('data-hashchar');
				    result.push(tagObj);
				});
				return result;
			},
			save : function(elemID){
				var targetType = coviComment.commentVariables[elemID].targetType;
				var targetID = coviComment.commentVariables[elemID].targetID;
				var targetElemet = document.getElementById(elemID);
				var comment = $('#' + elemID + ' .commInput.main textarea').val();
				var context = {
						File : coviComment.commentVariables[elemID].frontFileInfos,
						Location : coviComment.commentVariables[elemID].mapFileInfos,
						Tag : coviComment.getTags(elemID, 'main'),
						MessageSetting : coviComment.commentVariables[elemID].messageSetting,
						Mention: coviComment.commentVariables[elemID].mentionInfos
				};
				
				if(!XFN_ValidationCheckOnlyXSS(false)){
					$(targetElemet).attr('data-processing', "off");
					return false;
				}
				
				if (!coviUtil.checkValidation("", true, true)) { return false; }	
				
				if((comment == undefined || comment.trim() == '') && ($('#' + elemID + ' .fileUpview.main').children().length < 1 && $('#' + elemID + ' .main .commInpuBox').find('.fName').length < 1)){					
					Common.Warning(CFN_GetDicInfo(coviComment.dictionary.msg_checkComment, coviComment.commentVariables.lang));
					$(targetElemet).attr('data-processing', "off");
					return false;
				}
				
				if ($(targetElemet).attr('data-processing') == "on") {
					return false;
				}
				$(targetElemet).attr('data-processing', "on");
				
				var commentObj = new Object();
				commentObj.TargetID = targetID;
				commentObj.TargetServiceType = targetType;
				commentObj.Comment = comment;
				commentObj.Context = context;
				commentObj.FolderType = coviComment.commentVariables.folderType;
				
				$.ajax({
					type : "POST",
					dataType : "json",
					contentType : "application/json; charset=UTF-8",
			        url : "/covicore/comment/add.do",
			        data : JSON.stringify(commentObj),
			        success : function(res){
			        	if(res.result == 'ok'){
				        	if ($('.commCont').length > 0){
								$('.commCont:first').before('<div>'+coviComment.renderView(elemID, res.list)+'</div>');
							}
							else {
								$('#' + elemID + ' .commInput.main').append('<div>'+coviComment.renderView(elemID, res.list)+'</div>');
							}
				        	
				        	//clear
				        	$('#' + elemID + ' .commInput.main textarea').val('');
				        	coviComment.commentVariables[elemID].frontFileInfos = [];
				        	coviComment.commentVariables[elemID].mapFileInfos = [];
				        	coviComment.commentVariables[elemID].mentionInfos = {};
				        	$('#' + elemID + ' .commInput.main .ui-autocomplete-multiselect').children().remove();
				        	//image clear
				        	$('#' + elemID + ' .commInput.main .fileUpview.main').remove();
				        	//file clear
				        	$('#' + elemID + ' .commInput.main .commInpuBox .fName').remove();
				        	//mention clear
				        	$('#' + elemID + ' .commInput.main .date_del').remove();
				        	
				        	//댓글 조회 이벤트 바인딩
				        	coviComment.bindReadEvent(elemID);
				        	
				        	//댓글 카운트 갱신
				        	coviComment.reloadCommentCount(elemID);
				        	//New 배지 처리
				        	$('#' + elemID + ' .comCount .cycleNew').remove();
				        	$('#' + elemID + ' .comCount').append('<span class="cycleNew new">N</span>');
			        	} else {
			        		Common.Warning(CFN_GetDicInfo(coviComment.dictionary.msg_throwError, coviComment.commentVariables.lang));
			        	}

						$(targetElemet).attr('data-processing', "off");
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/comment/add.do", response, status, error);
						$(targetElemet).attr('data-processing', "off");
		       		}
			 	});
			},
			edit : function(elemID, commentID){
				var comment = $('#' + elemID + ' .commInput.rewrite textarea:visible').val();				
				var context = {
						UploadFile : coviComment.commentVariables[elemID].rewriteFrontFileInfos,
						ExistFile : coviComment.commentVariables[elemID].rewriteFileInfos,
						Location : coviComment.commentVariables[elemID].rewriteMapFileInfos,
						Tag : coviComment.getTags(elemID, 'rewrite'),
						MessageSetting : coviComment.commentVariables[elemID].messageSetting,
						Mention: coviComment.commentVariables[elemID].rewriteMentionInfos
				};
				
				if(!XFN_ValidationCheckOnlyXSS(false)){
					return false;
				}
				
				if((comment == undefined || comment.trim() == '') && ($('#' + elemID + ' .fileUpview.rewrite').children().length < 1 && $('#' + elemID + ' .rewrite').find('.fName').length < 1)){
					Common.Warning(CFN_GetDicInfo(coviComment.dictionary.msg_checkReply, coviComment.commentVariables.lang));
					return false;
				}
				
				Common.Confirm(Common.getDic("msg_RUEdit"), 'Confirmation Dialog', function (result) { //수정하시겠습니까?
					if(result){
					
						var commentObj = new Object();
						commentObj.CommentID = commentID;
						commentObj.Comment = comment;
						commentObj.Context = context;
						commentObj.FolderType = coviComment.commentVariables.folderType;
						
						$.ajax({
							type : "POST",
							dataType : "json",
							contentType : "application/json; charset=UTF-8",
					        url : "/covicore/comment/edit.do",
					        data : JSON.stringify(commentObj),
					        success : function(res){
					        	if(res.result == 'ok'){
						        	$('#' + elemID + ' .commCont[data-comment-id="' + commentID + '"]').replaceWith(coviComment.renderView(elemID, res.list));
						        	$(".commInput .rewrite").remove();
						        	//clear
//									$('#' + elemID + ' .commInput.rewrite').remove();
//									$('#' + elemID + ' .commMore.replayMore').remove();
//									$('#' + elemID + ' .commCont.re').remove();
						        	coviComment.commentVariables[elemID].rewriteFrontFileInfos = [];
						        	coviComment.commentVariables[elemID].rewriteMapFileInfos = [];
									
						        	//댓글 조회 이벤트 바인딩
						        	coviComment.bindReadEvent(elemID);
						        	
					        	} else {
					        		Common.Warning(CFN_GetDicInfo(coviComment.dictionary.msg_throwError, coviComment.commentVariables.lang));
					        	}
							},
							error:function(response, status, error){
								CFN_ErrorAjax("/covicore/comment/add.do", response, status, error);
				       		}
					 	});
					}
				});
			},
			saveRewrite : function(elemID, memberOf){
				var targetType = coviComment.commentVariables[elemID].targetType;
				var targetID = coviComment.commentVariables[elemID].targetID;
				var comment = $('#' + elemID + ' .commInput.rewrite textarea').val();
				coviComment.commentVariables[elemID].messageSetting.ReservedStr2 = "ReComment";
				var context = {
						File : coviComment.commentVariables[elemID].rewriteFrontFileInfos,
						Location : coviComment.commentVariables[elemID].rewriteMapFileInfos,
						Tag : coviComment.getTags(elemID, 'rewrite'),
						MessageSetting : coviComment.commentVariables[elemID].messageSetting
				};
				
				if(!XFN_ValidationCheckOnlyXSS(false)){
					return false;
				}
				
				if((comment == undefined || comment.trim() == '') && ($('#' + elemID + ' .fileUpview.rewrite').children().length < 1 && $('#' + elemID + ' .rewrite').find('.fName').length < 1)){
					Common.Warning(CFN_GetDicInfo(coviComment.dictionary.msg_checkReply, coviComment.commentVariables.lang));
					return false;
				}
				
				var commentObj = new Object();
				commentObj.TargetID = targetID;
				commentObj.TargetServiceType = targetType;
				commentObj.Comment = comment;
				commentObj.Context = context;
				commentObj.MemberOf = memberOf;
				commentObj.FolderType = coviComment.commentVariables.folderType;
				
				$.ajax({
					type : "POST",
					dataType : "json",
					contentType : "application/json; charset=UTF-8",
			        url : "/covicore/comment/add.do",
			        data : JSON.stringify(commentObj),
			        success : function(res){
			        	if(res.result == 'ok'){
				        	$('#' + elemID + ' .commInput.rewrite').after(coviComment.renderView(elemID, res.list));
				        	//clear
				        	$('#' + elemID + ' .commInput.rewrite textarea').val('');
				        	coviComment.commentVariables[elemID].rewriteFrontFileInfos = [];
				        	coviComment.commentVariables[elemID].rewriteMapFileInfos = [];
				        	$('#' + elemID + ' .commInput.rewrite .ui-autocomplete-multiselect').children().remove();
				        	//image clear
				        	$('#' + elemID + ' .commInput.rewrite .fileUpview.rewrite').remove();
				        	//file clear
				        	$('#' + elemID + ' .commInput.rewrite .fName').remove();
				        	
				        	//댓글 조회 이벤트 바인딩
				        	coviComment.bindReadEvent(elemID);
				        	
				        	//답글 카운트 갱신
				        	coviComment.reloadCommentCount(elemID);
				        	coviComment.reloadReplyCount(elemID, memberOf);
				        	
				        	$(".commInput .rewrite").remove();
			        	} else {
			        		Common.Warning(CFN_GetDicInfo(coviComment.dictionary.msg_throwError, coviComment.commentVariables.lang));
			        	}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/comment/add.do", response, status, error);
		       		}
			 	});
			},
			reloadReplyCount : function(elemID, memberOf){
				$.ajax({
					type : "POST",
				    url : "/covicore/comment/getReplyCount.do",
			        data : {
			        	'MemberOf' : memberOf
			        },
			        success : function(res){
			        	$('#' + elemID + ' .commCont[data-comment-id="' + memberOf + '"] span[name="replyCount"]').html(res.data);
			        	if(memberOf != '0')
			        		return res.data;
			        },
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/comment/getReplyCount.do", response, status, error);
		       		}
			 	});
			},
			loadView : function(elemID, memberOf, lastID){
				$.ajax({
					type : "POST",
				    url : "/covicore/comment/get.do",
			        data : {
			        	'RowCount' : coviComment.commentVariables.rowCount,
			        	'TargetType' : coviComment.commentVariables[elemID].targetType,
			        	'TargetID' : coviComment.commentVariables[elemID].targetID,
			        	//'MemberOf' : memberOf,
			        	'LastCommentID' : lastID,
			        	'folderType' : coviComment.commentVariables.folderType
			        },
			        success : function(res){
			        	if(res.list != null && res.list.length > 0){
			        		coviComment.loadSuccesCallback(elemID, memberOf, lastID, res.list, res.moreCount);	
			        	}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/comment/get.do", response, status, error);
		       		}
			 	});
			},
			loadSuccesCallback : function(elemID, memberOf, lastID, data, moreCnt){
				if(memberOf == '0'){
					//New 배지 처리
					var firstRowDate = new Date(CFN_TransLocalTime(data[0].RegistDate, _StandardServerDateFormat ).replace(/\-/g,"/"));
//					var registDateTime = coviCmn.getLocalTime(row.RegistDate);
					var today = new Date();
					
					var diff = Math.abs(today.getTime() - firstRowDate.getTime()) / 3600000;
					if (diff < Number(coviComment.commentVariables.newBadgeTime)) {
						$('#' + elemID + ' .comCount .cycleNew').remove();
						$('#' + elemID + ' .comCount').append('<span class="cycleNew new">N</span>');
					}
					
					$('#' + elemID + ' .commMore.main').remove();
					//var targetId = '#' + elemID + ' .commInput.main';
					//var target = document.getElementById(targetId);
					$.each(data, function(idx, el){
						var tempArr = []
						tempArr.push(el);
						if (el.MemberOf == '0'){
							$('#' + elemID + ' .commInput.main').append('<div>' + coviComment.renderView(elemID, tempArr) + '</div>');
						}
						else {
							if ($(".commCont[data-comment-id="+el.MemberOf+"]").parent().find('.commCont.re:last-child').length > 0){
								$(".commCont[data-comment-id="+el.MemberOf+"]").parent().find('.commCont.re:last-child').after(coviComment.renderView(elemID, tempArr));
							}
							else {
								$(".commCont[data-comment-id="+el.MemberOf+"]").after(coviComment.renderView(elemID, tempArr));
							}
							//$(".commCont[data-comment-id="+el.MemberOf+"]").next().before(coviComment.renderView(elemID, tempArr))
							
						}
					})
					/*if(lastID == '0'){
						$('#' + elemID + ' .commInput.main').after(coviComment.renderView(elemID, data));
						if(data.length == coviComment.commentVariables.rowCount && moreCnt > 0){
							$('#' + elemID + ' .commentView').append(coviComment.renderMoreBtn(elemID, memberOf));	
						}
					} else {
						$('#' + elemID + ' .commentView').append(coviComment.renderView(elemID, data));
						if(data.length == coviComment.commentVariables.rowCount && moreCnt > 0){
							$('#' + elemID + ' .commentView').append(coviComment.renderMoreBtn(elemID, memberOf));	
						}
					}	*/
				} else {
					$('#' + elemID + ' .commMore.replayMore').remove();
					var html = coviComment.renderView(elemID, data);
					if(data.length == coviComment.commentVariables.rowCount && moreCnt > 0){
						html += coviComment.renderMoreBtn(elemID, memberOf);
					}
					if(lastID == '0'){
						$('#' + elemID + ' .commInput.rewrite[data-comment-memberof="' + memberOf + '"]').after(html);
					} else {
						$('#' + elemID + ' [data-comment-memberof="' + memberOf + '"]').last().after(html);
					}
				}
				
				$.each($(".commentView .commCont .comHeartSmall span[name=likeCnt]"), function(idx, el) {
				    var cnt = Number(el.innerHTML);
				    if (!isNaN(cnt) && cnt > 0) $(el).css('visibility', 'visible');
				});
				
				//댓글 조회 이벤트 바인딩
	        	coviComment.bindReadEvent(elemID);
				
			},
			deleteComment : function(elemID, commentID, memberOf){
				Common.Confirm(Common.getDic("msg_AreYouDelete"), 'Confirmation Dialog', function (result) { //삭제하시겠습니까?
					$(".commInput .rewrite").remove();
					if(result){
						$.ajax({
							type : "POST",
						    url : "/covicore/comment/remove.do",
					        data : {
					        	'CommentID' : commentID,
					        	'MemberOf' : memberOf,
					        	'folderType' : coviComment.commentVariables.folderType,
					        	'commentDelAuth' : coviComment.commentVariables.commentDelAuth
					        },
					        success : function(res){
					        	if(res.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
						        	if(res.list.length > 0){
						        		coviComment.deleteSuccesCallback(elemID, res.list[0]);	
						        	}
						        }else{
					    			if (res.message != ""){
					    				Common.Warning(res.message);//오류가 발생헸습니다.
					    			}
					    			else{
					    				Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
					    			}	
						        }	
							},
							error:function(response, status, error){
								CFN_ErrorAjax("/covicore/comment/remove.do", response, status, error);
				       		}
					 	});
					}
				});
			},
			deleteSuccesCallback : function(elemID, row){
				var $row = $('#' + elemID + ' div[data-comment-id="' + row.CommentID + '"]');

				coviComment.reloadCommentCount(elemID);
				if(row.MemberOf.toString() != '0'){
					coviComment.reloadReplyCount(elemID, row.MemberOf);
				}
				
				if(row.DeleteDate != null && row.DeleteDate != undefined && row.DeleteDate != '' && row.MemberOf.toString() == '0' && Number(row.ReplyCount) > 0){
					$row.replaceWith(coviComment.renderDeleteBlock(elemID, row));
				} else {
					$row.remove();
				}
			},
			clickMoreBtn: function(elem, elemID){
				var $parentDiv = $(elem).parent().parent('div');
				
				if($parentDiv.hasClass('replayMore')){
					coviComment.loadView(elemID, $parentDiv.attr('data-comment-memberof'), $parentDiv.prevAll('.commCont.re').first().attr('data-comment-id'));
				} else {
					coviComment.loadView(elemID, '0', $parentDiv.prevAll('.commCont').first().attr('data-comment-id'));
				}
				
			},
			renderView : function(elemID, data){
				var html = '';
				for (var i = 0; i < data.length; i++) {
					var row = data[i];
					
					var context = row.Context;
					var ImagePath = Common.getGlobalProperties("css.path") +  "/covicore/resources/images/common/bg_comm.png"; //답글 이미지 경로
					
					//JobLevel이 없는 경우 JobTitle 표시
					var JobLevel = '';
					var JobPosition = context.User.JobPosition;
					var JobTitle = context.User.JobTitle;
					if(context.User.JobLevel != undefined) {
						JobLevel = context.User.JobLevel;
					} else {
						JobLevel = context.User.JobTitle;
					}
					
					var registDateTime = new Date(CFN_TransLocalTime(row.RegistDate,_StandardServerDateFormat).replace(/\-/g,"/"));
//					var registDateTime = coviCmn.getLocalTime(row.RegistDate);
					var registDate = registDateTime.format('yyyy-MM-dd');
					var registTime = registDateTime.format('HH:mm:ss');
					
					var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
					var sRepJobType = JobLevel;
			        if(sRepJobTypeConfig == "PN"){
			        	sRepJobType = JobPosition;
			        } else if(sRepJobTypeConfig == "TN"){
			        	sRepJobType = JobTitle;
			        } else if(sRepJobTypeConfig == "LN"){
			        	sRepJobType = JobLevel;
			        }

					if(row.DeleteDate != null && row.DeleteDate != undefined && row.DeleteDate != '' && row.MemberOf.toString() == '0' && Number(row.ReplyCount) > 0){
						html += coviComment.renderDeleteBlock(elemID, row);
						continue;
					}
					
					if(row.MemberOf.toString() == '0'){
						html += '<div class="commCont" data-comment-id="' + row.CommentID + '" data-comment-memberof="' + row.MemberOf + '">';
					} else {
						if(CFN_GetQueryString("CLBIZ") != "Community") {
							if(row.Depth > 1) {
								var commentStyle = "padding: 15px 40px 25px " + (parseInt(105) + (parseInt(row.Depth - 1) * parseInt(40))) + "px !important; background: #f5f5f5 url("+ImagePath+") no-repeat " + (parseInt(77) + (parseInt(row.Depth - 1) * parseInt(40))) + "px 15px;";
								html += '<div style="' + commentStyle +'" class="commCont re" data-comment-id="' + row.CommentID + '" data-comment-memberof="' + row.MemberOf + '">';
							} else {
								html += '<div class="commCont re" data-comment-id="' + row.CommentID + '" data-comment-memberof="' + row.MemberOf + '">';
							}
						} else {
							var commentStyle = "padding: 11px 40px 25px " + (parseInt(55) + (parseInt(row.Depth - 1) * parseInt(20))) + "px !important; background: #f5f5f5 url("+ImagePath+") no-repeat " + (parseInt(35) + (parseInt(row.Depth - 1) * parseInt(20))) + "px 12px;";
							html += '<div style="' + commentStyle +'" class="commCont re" data-comment-id="' + row.CommentID + '" data-comment-memberof="' + row.MemberOf + '">';
						}
					}
					
					html += '	<div class="personBox">';					
					html += '		<div class="perPhoto">';
					html += '			<img src="' + coviCmn.loadImage(context.User.Photo) + '" onerror="coviCmn.imgError(this, true);" alt="ProfilePhoto">';
					html += '		</div>';
					html += '		<p class="name">';
										
					if(context.User.Dept != "") {
						html += '			<strong class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="position:relative;cursor:pointer" data-user-code="'+ row.RegisterCode +'" data-user-mail="" >' + context.User.Name + ' ' + sRepJobType + '</strong>';
						html += '			<span>(' + context.User.Dept + ')</span>';
					} else {
						if(coviComment.commentVariables.folderType == "Anonymous" && row.AnonymousAuthYn == "Y") {
							html += '			<strong>' + context.User.Name + '</strong>';
							html += '			<span>(' + CFN_GetDicInfo(coviComment.dictionary.oneSelfWrite, coviComment.commentVariables.lang) + ')</span>';
						}
					}
					
					html += '			<span class="pDate">' + registDate + '</span><span>' + registTime + " " + Common.getSession("UR_TimeZoneDisplay")+ '</span>';
					html += '			<span class="comHeartSmall ';
					
					if(Number(row.MyLikeCount) > 0){
						html += 'active">';	
					} else {
						html += '">';
					}
					
					html += '				<a href="javascript:;" data-liketype="emoticon" data-emoticon="heart" onclick="coviComment.addLikeCount(this, \'Comment\', \'' + row.CommentID + '\');" class="selected">';
					html += '					<i class="fa fa-heart-o fa-2x" aria-hidden="true"></i><span name="likeCnt">' + (Number(row.LikeCount) > 0 ? row.LikeCount : '') + '</span>&nbsp;';
					html += '				</a>';
					html += '			</span>';
					html += '		</p>';	
					html += '	</div>';
					html += '	<p>';

					if(row.Context.Mention!= null && !Array.isArray( row.Context.Mention)){
						for (var k in row.Context.Mention){
							html += '<font class="mr10 tBlue">'+row.Context.Mention[k]+'</font>';
						}
					}
					html += '	</p>';
					html += '	<p class="conTxt">' ;
					html +=  coviComment.replaceHashTag(row.Comment).replace(/(\n|\r\n)/g, '<br>') + '</p>';
					
					for (var l = 0; l < row.Context.File.length; l++) {
						var file = row.Context.File[l];
						var convertedSize = coviFile.convertFileSize(file.Size);

						var iconClass = "";
						if(file.Extention == "ppt" || file.Extention == "pptx"){
							iconClass = "ppt";
						} else if (file.Extention == "excel" || file.Extention == "xlsx" || file.Extention == "xls"){
							iconClass = "fNameexcel";
						} else if (file.Extention == "pdf"){
							iconClass = "pdf";
						} else if (file.Extention == "doc" || file.Extention == "docx"){
							iconClass = "word";
						} else if (file.Extention == "zip" || file.Extention == "rar" || file.Extention == "7z"){
							iconClass = "zip";
						} else if (file.Extention == "jpg" || file.Extention == "gif" || file.Extention == "png"|| file.Extention == "bmp"){
							iconClass = "attImg";
						} else {
							iconClass = "default";
						}
						
						html += '	<p class="fName" style="cursor:pointer;" fileID="'+file.FileID+'" fileToken="'+file.FileToken+'" fileExtention="'+file.Extention+'" >';
						html += '		<span class="'+iconClass+'" title="'+file.FileName+'">' + file.FileName + '</span>';
						html += '		<span>(' + convertedSize + ')</span>';
						html += '		<a href="#" class="btnFilePrev"></a>';
						html += '	</p>';
						
					}
					
					if(row.Context.Location.length > 0 || coviComment.checkExistImgInFiles(row.Context.File)){
						html += '	<ul class="clearFloat fileUpview">';
						for (var j = 0; j < row.Context.File.length; j++) {
							var imgFile = row.Context.File[j];
							if(imgFile.SaveType.toUpperCase() == 'IMAGE'){
								var thumbName = imgFile.SavedName.substr(0, imgFile.SavedName.lastIndexOf('.')) + '_thumb.jpg';
								var src = coviCmn.loadImageIdThumb(imgFile.FileID);
								var encodeSrc = encodeURI(coviCmn.loadImageId(imgFile.FileID));
								
								html += '		<li><div class="imgThum"><a href="javascript:;" onclick="coviComment.callImageViewer(\'' + encodeSrc + '\')">';
								html += '		<img src="' + src + '" alt="Image" style="width: 100%; height: 100%;"></a></div></li>';
							}
						}
						
						for (var k = 0; k < row.Context.Location.length; k++) {
							html += '		<li><div class="fMap"><img src="' + row.Context.Location[k] + '" alt="Map"></div></li>';
						}
						
						html += '	</ul>';
					}
					
					html += '	<div class="commentReplayBtnBox">';
					
					if(row.Depth < (Common.getBaseConfig("ReWriteCommentCount") == "" ? 1 : parseInt(Common.getBaseConfig("ReWriteCommentCount")))) {
						html += '		<a href="javascript:;" class="btnTypeDefault reply" onclick="coviComment.callReWrite(this, \'' + elemID + '\', \'' + row.CommentID + '\', \'' + row.Depth + '\');">' + CFN_GetDicInfo(coviComment.dictionary.reply, coviComment.commentVariables.lang) + '</a>';
					}
					
					if(Common.getSession("USERID") == row.RegisterCode || row.AnonymousAuthYn == "Y" || (typeof commentDelAuth != 'undefined' && commentDelAuth == "true")){
						html += '		<a href="javascript:;" class="btnTypeDefault delete" onclick="coviComment.deleteComment(\'' + elemID + '\', \'' + row.CommentID + '\', \'' + row.MemberOf + '\');">' + CFN_GetDicInfo(coviComment.dictionary.del, coviComment.commentVariables.lang) + '</a>';
						if((Common.getSession("USERID") == row.RegisterCode || row.AnonymousAuthYn == "Y") && Common.getBaseConfig("isCommentEdit") == "Y") 
							html += '		<a href="javascript:;" class="btnTypeDefault edit" onclick="coviComment.editComment(this, \'' + elemID + '\', \'' + row.CommentID + '\', \'' + row.MemberOf + '\');">' + CFN_GetDicInfo(coviComment.dictionary.edit, coviComment.commentVariables.lang) + '</a>';
					}

					html += '	</div>';
					html += '</div>';	
				}
				
				return html;
				
			},
			renderDeleteBlock : function(elemID, row){
				var html = '';
				var className;
				if(row.MemberOf.toString() == '0'){
					className = 'commCont commDeleteReplay';
				} else{
					className = 'commCont re commDeleteReplay';
				}
				
				var registDateTime = new Date(CFN_TransLocalTime(row.RegistDate, _StandardServerDateFormat).replace(/\-/g,"/"));
//				var registDateTime = coviCmn.getLocalTime(row.RegistDate);
				
				html += '<div class="' + className + '" data-comment-id="' + row.CommentID + '" data-comment-memberof="' + row.MemberOf + '">';
				html += '	<p>' + CFN_GetDicInfo(coviComment.dictionary.msg_deleted, coviComment.commentVariables.lang);
				html += '		<span class="date">' + registDateTime.format('yyyy-MM-dd hh:mm:ss') + " " + Common.getSession("UR_TimeZoneDisplay") + '</span>';
				html += '	</p>';
				html += '</div>';
				
				return html;
			},
			checkExistImgInFiles : function(files){
				var bExist = false;
				for (var j = 0; j < files.length; j++) {
					if(files[j].SaveType != undefined && files[j].SaveType.toUpperCase() == 'IMAGE'){
						bExist = true;
						break;
					}
				}
				return bExist;
			},
			replaceHashTag : function(comment){
				var patternString = '(^|\\s)(';
				patternString += coviComment.commentVariables.hashTagOption.hashChar.join("|");
				patternString += ')([a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\\d';
				patternString += coviComment.commentVariables.hashTagOption.allowedChar.join("");
				patternString += ']+)';
				
				var regEx = new RegExp(patternString, "g");
				
				return comment.replace(regEx,'$1<span class="tag" data-hashchar="$2">$2$3</span>');
			},
			renderMoreBtn : function(elemID, memberOf){
				var html = '', divClass, aText;
				
				if(memberOf == '0'){
					divClass = 'commCont commMore main';
					aText = CFN_GetDicInfo(coviComment.dictionary.more, coviComment.commentVariables.lang); 
				} else {
					divClass = 'commCont commMore replayMore';
					aText = CFN_GetDicInfo(coviComment.dictionary.moreReply, coviComment.commentVariables.lang);
				}
				
				html += '<div class="' + divClass + '" data-comment-memberof="' + memberOf + '">';
				html += '	<p><a href="javascript:;" onclick="coviComment.clickMoreBtn(this, \'' + elemID + '\', \'' + memberOf + '\');">' + aText + '</a></p>';
				html += '</div>';
				return html;
			},
			callImgUpload : function(elemID){
				var url = "";
				url += "/covicore/control/callFileUpload.do?"
				url += "lang=ko&";
				url += "listStyle=div&";
				url += "callback=" + elemID + "_callImgUploadCallBack&";
				url += "actionButton="+encodeURIComponent("add,upload")+"&";
				url += "multiple=true&";
				url += "servicePath=" + coviComment.commentVariables.servicePath + "&";
				url += "elemID=" + elemID+"&";
				url += "image=" + "true";
				
				Common.open("", elemID + "_CoviCommentImgUp", "File", url, "500px", "250px", "iframe", true, null, null, true);
			},
			callFileUpload : function(elemID){
				var url = "";
				url += "/covicore/control/callFileUpload.do?"
				url += "lang=ko&";
				url += "listStyle=div&";
				url += "callback=" + elemID + "_callFileUploadCallBack&";
				url += "actionButton="+encodeURIComponent("add,upload")+"&";
				url += "multiple=true&";
				url += "servicePath=" + coviComment.commentVariables.servicePath + "&";
				url += "elemID=" + elemID;
				
				Common.open("", elemID + "_CoviCommentFileUp", "File", url, "500px", "250px", "iframe", true, null, null, true);
			},
			callMap : function(elemID){
				var url = "";
				
				if (document.getElementById("chkPop") != null && document.getElementById("chkPop").value=='Y'){
					url += "/covicore/control/callMap.do?"
					url += "lang=ko&";
					url += "mapWidth=300&";
					url += "mapHeight=200&";
					url += "imgWidth=80&";
					url += "imgHeight=80&";
					url += "callback=" + elemID + "_callMapCallBack&";
					url += "elemID=" + elemID;
					
					Common.open("", elemID + "_CoviCommentMap", "Map", url, "400px", "300px", "iframe", true, null, null, true);
					
				}else{
				url += "/covicore/control/callMap.do?"
				url += "lang=ko&";
				url += "mapWidth=500&";
				url += "mapHeight=400&";
				url += "imgWidth=120&";
				url += "imgHeight=120&";
				url += "callback=" + elemID + "_callMapCallBack&";
				url += "elemID=" + elemID;
				
				Common.open("", elemID + "_CoviCommentMap", "Map", url, "600px", "500px", "iframe", true, null, null, true);
				}
			},
			callReImgUpload : function(elemID){
				var url = "";
				url += "/covicore/control/callFileUpload.do?"
				url += "lang=ko&";
				url += "listStyle=div&";
				url += "callback=" + elemID + "_callReImgUploadCallBack&";
				url += "actionButton="+encodeURIComponent("add,upload")+"&";
				url += "multiple=true&";
				url += "servicePath=" + coviComment.commentVariables.servicePath + "&";
				url += "elemID=" + elemID+"&";
				url += "image=" + "true";
				
				Common.open("", elemID + "_CoviCommentReImgUp", "File", url, "500px", "250px", "iframe", true, null, null, true);
			},
			callReFileUpload : function(elemID){
				var url = "";
				url += "/covicore/control/callFileUpload.do?"
				url += "lang=ko&";
				url += "listStyle=div&";
				url += "callback=" + elemID + "_callReFileUploadCallBack&";
				url += "actionButton="+encodeURIComponent("add,upload")+"&";
				url += "multiple=true&";
				url += "servicePath=" + coviComment.commentVariables.servicePath + "&";
				url += "elemID=" + elemID;
				
				Common.open("", elemID + "_CoviCommentReFileUp", "File", url, "500px", "250px", "iframe", true, null, null, true);
			},
			callReMap : function(elemID){
				var url = "";
				url += "/covicore/control/callMap.do?"
				url += "lang=ko&";
				url += "mapWidth=500&";
				url += "mapHeight=400&";
				url += "imgWidth=120&";
				url += "imgHeight=120&";
				url += "callback=" + elemID + "_callReMapCallBack&";
				url += "elemID=" + elemID;
				
				Common.open("", elemID + "_CoviCommentReMap", "Map", url, "600px", "500px", "iframe", true, null, null, true);
			},
			callImageViewer : function(src){
				var url = "";
				url += "/covicore/control/callimage.do?"
				url += "maxWidth=900&";
				url += "maxHeight=600&";
				url += "src=" + encodeURI(src);
				if (opener){
					var specs = "left=10,top=10,width=1000,height=700";
					specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
					window.open(url, "Image", specs);
				} else {
					parent.Common.open("", "CoviCommentImage", "Image", url, "1000px", "700px", "iframe", true, null, null, true);
				}
			},
			checkFrontFile : function(data, elemID, varName){
				var bExist = false;
				for (var i = 0; i < coviComment.commentVariables[elemID][varName].length; i++) {
					var frontFile = coviComment.commentVariables[elemID][varName][i];
					if(data.FileName == frontFile.FileName && data.Size == frontFile.Size){
						bExist = true;
						Common.Warning(CFN_GetDicInfo(coviComment.dictionary.msg_checkDupe, coviComment.commentVariables.lang));
					}
				}
				
				return bExist;
			},
			checkMapFile : function(data, elemID, varName){
				var bExist = false;
				for (var i = 0; i < coviComment.commentVariables[elemID][varName].length; i++) {
					var mapFile = coviComment.commentVariables[elemID][varName][i];
					if(mapFile == data){
						bExist = true;
						Common.Warning(CFN_GetDicInfo(coviComment.dictionary.msg_checkDupe, coviComment.commentVariables.lang));
					}
				}
				
				return bExist;
			},
			removeFrontFile : function(savedName, elemID, varName){
				for (var i =0; i < coviComment.commentVariables[elemID][varName].length; i++){
					var frontFile = coviComment.commentVariables[elemID][varName][i];
					if(savedName == frontFile.SavedName){
						coviComment.commentVariables[elemID][varName].splice(i,1);
						break;
					}
				}
			},
			removeMapFile : function(data, elemID, varName){
				for (var i = 0; i < coviComment.commentVariables[elemID][varName].length; i++) {
					var mapFile = coviComment.commentVariables[elemID][varName][i];
					if(mapFile == data){
						coviComment.commentVariables[elemID][varName].splice(i,1);
						break;
					}
				}
			},
			makeImgFileRow : function(data, elemID, varName){
				var liHtml = '';
				if(!coviComment.checkFrontFile(data, elemID, varName)){
					//File 정보 set
					coviComment.commentVariables[elemID][varName].push(data);
					var fileName = data.SavedName;
					var thumbName = fileName.substr(0, fileName.lastIndexOf('.')) + '_thumb.jpg';
					var frontAddPath = data.FrontAddPath + "/";
					var src = "";
					
					if(AwsS3.isActive()){
						src = AwsS3.getS3ApUrl()+coviComment.commentVariables.frontPath + frontAddPath + thumbName;
					}else{
						src = coviComment.commentVariables.frontPath + frontAddPath + thumbName;
					}
					liHtml += '<li data-savedname="' + fileName + '">';
					liHtml += '<div class="imgThum"><img src="' + src + '" ></div>';
					liHtml += '<a href="javascript:;" class="btnPhotoRemove" onclick="coviComment.deleteImgFile(this, \'' + elemID + '\', \'' + varName + '\');">' + CFN_GetDicInfo(coviComment.dictionary.delPhoto, coviComment.commentVariables.lang) + '</a>';
					liHtml += '</li>';
				}
				return liHtml;
			},
			makeMapRow : function(data, elemID, varName){
				var liHtml = '';
				if(!coviComment.checkMapFile(data, elemID, varName)){
					//Map 정보 set
					coviComment.commentVariables[elemID][varName].push(data);
					liHtml += '<li>';
					liHtml += '<div class="fMap"><img src="' + data + '" alt="Map"></div>';
					liHtml += '<a href="javascript:;" class="btnPhotoRemove" onclick="coviComment.deleteMapFile(this, \'' + elemID + '\', \'' + varName + '\');"> ' + CFN_GetDicInfo(coviComment.dictionary.del, coviComment.commentVariables.lang) + '</a>';
					liHtml += '</li>';
				}
				return liHtml;
			},
			makeFileRow : function(data, elemID, varName){
				var liHtml = '';
				if(!coviComment.checkFrontFile(data, elemID, varName)){
					//File 정보 set
					coviComment.commentVariables[elemID][varName].push(data);
					var savedName = data.SavedName;
					var fileName = data.FileName;
					var convertedSize = coviFile.convertFileSize(data.Size);
					var fileExt = fileName.substring(fileName.lastIndexOf('.')+1);
					var iconClass = coviComment.getFileIconClassByExt(fileExt);					// 첨부파일 확장자 css class 변환

					liHtml += '<p class="fName" data-savedname="' + savedName + '">';
					liHtml += '	<span class="'+iconClass+'">' + fileName + '</span>';
					liHtml += '	<span>(' + convertedSize + ')</span>';
					liHtml += '	<a href="javascript:;" class="btnPhotoRemove gray" onclick="coviComment.deleteFile(this, \'' + elemID + '\', \'' + varName + '\');">' + CFN_GetDicInfo(coviComment.dictionary.del, coviComment.commentVariables.lang) + '</a>';
					liHtml += '</p>';
				}
				return liHtml;
			},
			deleteImgFile : function(elem, elemID, varName){
				var $li = $(elem).parent();
				if($li.length){
					$li.remove();
					coviComment.removeFrontFile($li.attr('data-savedname'), elemID, varName);
				}
			},
			deleteMapFile : function(elem, elemID, varName){
				var $li = $(elem).parent();
				if($li.length){
					$li.remove();
					coviComment.removeMapFile($li.children().find('img').attr('src'), elemID, varName);
				}
			},
			deleteFile : function(elem, elemID, varName){
				var $p = $(elem).parent();
				if($p.length){
					$p.remove();
					coviComment.removeFrontFile($p.attr('data-savedname'), elemID, varName);
				}
			},
			loadLikeCount : function(elemID, targetType, targetID){
				$.ajax({
					type : "POST",
				    url : "/covicore/comment/getLike.do",
			        data : {
			        	'TargetType' : targetType,
			        	'TargetID' : targetID
			        },
			        success : function(res){
			        	var $con = $('#' + elemID + ' .commentInfo');
			        	$con.find('span[name="likeCnt"]').html(res.data);
			        	if(Number(res.myLike) > 0){
						    $con.addClass('active');
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/comment/getLike.do", response, status, error);
		       		}
			 	});
			},
			addLikeCount : function(elem, targetType, targetID){
				var $this = $(elem);
				var likeType = $this.parent().attr('data-liketype');
				var emoticon = $this.parent().attr('data-emoticon');
				var menuCode = CFN_GetQueryString("menuCode");
				
				if(targetType == "Board"){
					var menuName = "";
					if(typeof(menuID) != "undefined") {
						if(window.hasOwnProperty('headerdata')) {
							$.each(headerdata, function(idx, el){
								if (el.MenuID == menuID){
									menuName = CFN_GetDicInfo(el.MultiDisplayName);
								}
							});
						}
					}
				}
				
				$.ajax({
					type : "POST",
				    url : "/covicore/comment/addLike.do",
			        data : {
			        	'TargetType' : targetType,
			        	'TargetID' : targetID,
			        	'LikeType' : likeType,
			        	'Emoticon' : emoticon,
			        	'Point' : '0',
			        	'FolderType' : coviComment.commentVariables.folderType,
						'menuCode' : menuCode,
						'ReservedStr1' : menuName
			        },
			        async : false,
			        success : function(res){
			        	$this.find('span[name="likeCnt"]').html((res.data > 0 ? res.data : 0));
			        	if(Number(res.myLike) > 0){
						     $this.parent().addClass('active');
					    } else {
			        		$this.parent().removeClass('active');
			        	}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/comment/addLike.do", response, status, error);
		       		}
			 	});
			},
			
			//확장자로 첨부파일 아이콘 css class 구하기
			getFileIconClassByExt : function(fileExt) {
				var iconClass = "";
				
				if(fileExt !== undefined && fileExt !== '') {
					if(fileExt == "ppt" || fileExt == "pptx"){
						iconClass = "ppt";
					} else if (fileExt == "excel" || fileExt == "xlsx" || fileExt == "xls"){
						iconClass = "fNameexcel";
					} else if (fileExt == "pdf"){
						iconClass = "pdf";
					} else if (fileExt == "doc" || fileExt == "docx"){
						iconClass = "word";
					} else if (fileExt == "zip" || fileExt == "rar" || fileExt == "7z"){
						iconClass = "zip";
					} else if (fileExt == "jpg" || fileExt == "gif" || fileExt == "png"|| fileExt == "bmp"){
						iconClass = "attImg";
					} else {
						iconClass = "default";
					}
				} else {
					iconClass = "default";
				}
				
				return iconClass;
			}
			
	};
	
	window.coviComment = coviComment;
	
})(window);
