// TODO: 임시 작성함


/*!
 * 
 * 
 * SmartS4j / MobileOffice / 모바일 댓글 js 파일
 * 함수명 : mobile_comment_...
 * 
 * 
 */





/*!
 * 
 * 페이지별 init 함수
 * 
 */


/*
 * !
 * 
 * 첨부 수정용객체
 * 
 */

//첨부 객체
var mobile_comm_editFilesObj = {
	UploadFile : [], // 파일 정보
	ExistFile : []		// multipart file
};   

//댓글 목록 페이지
$(document).on('pageinit', '#comment_list_page', function () {
	if($("#comment_list_page").attr("IsLoad") != "Y"){
		$("#comment_list_page").attr("IsLoad", "Y");
		setTimeout("mobile_comment_ListInit()",10);
	}
});

// 커멘트 리스트 나올때 처리
$(document).on('pagebeforehide', '#comment_list_page', function () {
	$("#comment_list_page").remove();
	mobile_comment_getCommentLike(_mobile_comment_list.TargetType, _mobile_comment_list.TargetID, 'N');
});






/*!
 * 
 * 댓글 목록
 * 
 */


var _mobile_comment_list = {
	TargetType: '',
	TargetID: '',
	CommentID: '',	//답글할 댓글의 ID
	FrontPath : '/FrontStorage/'+mobile_comm_getSession("DN_Code")+"/"
	//BackPath : mobile_comm_replaceAll(mobile_comm_getBaseConfig("BackStoragePath"), "{0}", mobile_comm_getSession("DN_Code"))+'comment/'
};


function mobile_comment_ListInit(){
	
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('targettype', "comment_list_page") != 'undefined' && mobile_comm_getQueryString('targettype', "comment_list_page") != '') {
		_mobile_comment_list.TargetType = mobile_comm_getQueryString('targettype', "comment_list_page");
    } else {
    	_mobile_comment_list.TargetType = '';
    }
	if (mobile_comm_getQueryString('targetid', "comment_list_page") != 'undefined' && mobile_comm_getQueryString('targetid', "comment_list_page") != '') {
		_mobile_comment_list.TargetID = mobile_comm_getQueryString('targetid', "comment_list_page");
	} else {
		_mobile_comment_list.TargetID = '';
	}
	if (mobile_comm_getQueryString('commentid', "comment_list_page") != 'undefined' && mobile_comm_getQueryString('commentid', "comment_list_page") != '') {
		_mobile_comment_list.CommentID = mobile_comm_getQueryString('commentid', "comment_list_page");
	} else {
		_mobile_comment_list.CommentID = '0';
	}
	
	//작성자 표시(이름 직책명)
	if(_mobile_board_list.FolderType == "Anonymous") {
		$("div.u_cbox_write span.u_cbox_write_name").text(mobile_comm_getDic("lbl_Anonymity"));
	} else {
		$("div.u_cbox_write span.u_cbox_write_name").text(mobile_comm_getSession('UR_Name') + ' ' + mobile_comm_getSession("UR_JobTitleName"));
	}
	
	$("#comment_list_writeBtn textarea").attr("style", "height: 33px; padding: 0;");
	
	//첨부파일 객체 초기화
	mobile_comm_uploadfilesObj = {
		fileInfos : [],
		files : []
	};
	
	//댓글 target 정보 조회 및 표시
	setTimeout(function () {
		mobile_comment_getTargetInfo(_mobile_comment_list);
    }, 100);
	

	//댓글 목록 조회 및 표시
	setTimeout(function () {
		mobile_comment_getCommentLike(_mobile_comment_list.TargetType, _mobile_comment_list.TargetID, 'Y');
	}, 100);
	
	//답글로 들어온 경우
	setTimeout(function () {
		if(_mobile_comment_list.CommentID != '0' && _mobile_comment_list.CommentID != "Reply") {
			mobile_comment_setReCommentWrite(_mobile_comment_list.CommentID);
		}
	}, 100);
	
	//수정으로 들어온 경우
	setTimeout(function () {
		if(_mobile_comment_list.Mode == 'Edit') {
			mobile_comment_goCommentEdit(_mobile_comment_list.TargetType,
				_mobile_comment_list.TargetID, _mobile_comment_list.CommentID, _mobile_comment_list.MemberOf, "Y");
		}
	}, 100);
}



//상단 정보 조회 및 표시
function mobile_comment_getTargetInfo(pObj) {
	
	var targetType = pObj.TargetType;
	var targetID = pObj.TargetID;
	
	var sURL = "";
	var param = {};
	
	switch (targetType.toUpperCase()) {
		case "BOARD":
		case "DOC":
			sURL = "/groupware/mobile/board/getBoardMessageInfo.do";
			param = {
				messageID: targetID.split('_')[0],
				version: targetID.split('_')[1],
				bizSection: targetType
			};
			break;
		case "RESOURCE":
			sURL = "/groupware/mobile/resource/getBookingData.do";
			param = {
				mode: "S",
				EventID: targetID.split('_')[0],
				DateID: targetID.split('_')[1],
				ResourceID: targetID.split('_')[2],
				RepeatID: targetID.split('_')[3]
			};
			break;
		case "SCHEDULE":
			sURL = "/groupware/mobile/schedule/goOne.do";
			param = {
				mode: "S",
				lang: mobile_comm_getSession("LanguageCode"),
				EventID: targetID.split('_')[0],
				DateID: targetID.split('_')[1],
				IsRepeat: targetID.split('_')[2],
				UserCode: mobile_comm_getSession("UR_Code").toLowerCase()
			};
			break;
		case "TASK":
			sURL = "/groupware/mobile/task/getTaskData.do";
			param = {
				TaskID: targetID
			};
			break;
		case "COLLAB":
			if($("#collab_task_post_location").html() == "") $('#commnet_list_location').hide();
			else $('#commnet_list_location').show();
		
			$('#commnet_list_location').html($("#collab_task_post_location").html());
			$('#commnet_list_title').html($("#collab_task_tit").html());
			break;
	}
	
	
	if(sURL != "") {
		$.ajax({
			url: sURL,
			data: param,
			type: "post",
			success: function (response) {
				if(response.status == "SUCCESS") {
					switch (targetType.toUpperCase()) {
						case "BOARD":
						case "DOC":
							
							pObj.Location = response.view.FolderName;
							pObj.TitleIcon = (response.view.IsTop == "Y") ? "<span class=\"ico_notice\"></span>" : "";
							pObj.Title = response.view.Subject;
							
							break;
						case "RESOURCE":
							
							pObj.Location = response.data.bookingData.ResourceName;
							pObj.TitleIcon = "";
							pObj.Title = response.data.bookingData.Subject;
							
							break;
						case "SCHEDULE":
							
							pObj.Location = '<span id="schedule_view_foldercolor" class="rd_dot" style="background: ' + response.data.Event.FolderColor + '"></span>&nbsp'+response.data.Event.FolderName;
							pObj.TitleIcon = "";
							pObj.Title = response.data.Event.Subject;

							break;
						case "TASK":
							var taskFDName = response.taskInfo.FolderName;
							if(taskFDName == undefined || taskFDName == "") {
								taskFDName = mobile_comm_getDic("lbl_TaskManage"); //업무 관리
							}
							pObj.Location = taskFDName;
							pObj.TitleIcon = "";
							pObj.Title = response.taskInfo.Subject;

							break;
					}
					
					$('#commnet_list_location').html(pObj.Location);
					$('#commnet_list_title').html(pObj.TitleIcon + pObj.Title);
				}
			},
			error: function (response, status, error){
				mobile_comm_ajaxerror(sURL, response, status, error);
			}
		});
	}
}

//댓글 입력영역 변경 (입력 클릭/취소 클릭)
function mobile_comment_changeWriteArea(pMode) {
	
	//txtarea 클릭 시
	if(pMode == 'open') {
		if(!($('#comment_list_write').hasClass('open'))) {
			$('#comment_list_write').addClass('open');
			$('#comment_list_writeBtn').removeClass('open');
			
			//댓글 기본문구 설정
			$('#comment_list_write_txt').attr('placeholder', mobile_comm_getDic("msg_Mobile_enterComment"));
		}
		
		return;
	}
	
	//취소 클릭 시
	if(pMode == 'close') {
		
		//입력값 초기화
		$('#comment_list_write_txt').val('');
		$('#comment_list_write_add').html('');
		
		$("#btnSave").removeAttr("onclick");
		$("#btnSave").attr("onclick", "mobile_comment_clickAddComment('list')");
		$("#btnSave").children(".u_cbox_txt_upload").text("등록");
		
		if(($('#comment_list_write').hasClass('open'))) {
			$('#comment_list_write').removeClass('open');
			$('#comment_list_writeBtn').addClass('open');
		}
		
		//파일 정보 초기화
		$("#mobile_attach_uploded_file, #mobile_attach_uploded_img").hide().html("");
		mobile_comm_uploadfilesObj.files = [];
		mobile_comm_uploadfilesObj.fileInfos = [];
		mobile_comm_editFilesObj.UploadFile = [];
		mobile_comm_editFilesObj.ExistFile = [];
		return;
	}
}

//좋아요/댓글 조회
function mobile_comment_getCommentLike(pTargetType, pTargetID, pListYN) {
	var url = "/covicore/mobile/comment/getCommentLike.do";
	var param = {
		"targetType": pTargetType,
		"targetID": (pTargetType.toUpperCase() == "RESOURCE") ? pTargetID.split('_')[0] : pTargetID,
		"folderType" : _mobile_board_list.FolderType
	};
	var pDateID = (pTargetType.toUpperCase() == "RESOURCE") ? pTargetID.split('_')[1] : "";
	
	$.ajax({
		url : url,
		data :param,
		type : "post",
		async : false,
		success : function(res) {
			if (res.status == "SUCCESS") {
				
				// 1. 좋아요 영역 그리기
				
				pTargetType.toUpperCase() == "RESOURCE"
				
				var sLikeHtml = "";
				var sALinkLike = "javascript: mobile_comment_addLike('" + pTargetType + "', '" + ((pTargetType.toUpperCase() == "RESOURCE") ? pTargetID.split('_')[0] : pTargetID) + "');";
				var sALinkGoList = "javascript: mobile_comment_goCommentList('" + pTargetType + "', '" + pTargetID + "');";
				
				if(pListYN != "Y") {
					sLikeHtml += "<div class=\"end_like_area\">";
					sLikeHtml += "    <div class=\"btn_like_w\">";
					sLikeHtml += "        <a href=\"" + sALinkLike + "\" class=\"u_likeit_list_btn " + (res.myLike>0 ? "on" : "") + "\">";	//TODO: 나의 좋아요 여부 처리
					sLikeHtml += "            <i class=\"u_ico\"></i>" + mobile_comm_getDic("lbl_Good") + "<span class=\"u_cnt\">" + res.likecount+ "</span>";	//좋아요
					sLikeHtml += "        </a>";
					sLikeHtml += "    </div>";
					sLikeHtml += "</div>";	
				}
				
				// 2. 댓글 목록 그리기
				
				var sCommentHtml = "";
				
				if(res.commentlist.length > 0) {
					
					var commentCnt = 0;
					$(res.commentlist).each(function (i, comment) {	
						if((comment.DeleteDate != null && comment.DeleteDate != undefined && comment.DeleteDate != '' &&comment.MemberOf.toString() == '0' && Number(comment.ReplyCount) > 0)
							|| !(comment.DeleteDate != null && comment.DeleteDate != undefined && comment.DeleteDate != '')) {
							//1. 삭제된 댓글 중, 하위 답글이 있어서, 표시되어야하는 경우
							//2. 삭제된 댓글이 아닌 경우
							commentCnt++;
						}
					});
					
					//댓글 영역
					if(pListYN != "Y") {
						sCommentHtml += "<div class=\"section_comment\">";
						sCommentHtml += "    <div class=\"top_area\">";
						sCommentHtml += "        <h3 class=\"tit\"><a href=\"" + sALinkGoList + "\" class=\"tit_link\">" + mobile_comm_getDic("lbl_Comments") + "<em>" + res.commentcount + "</em></a></h3>";
						sCommentHtml += "        <a href=\"" + sALinkGoList + "\" class=\"more_comment\">" + mobile_comm_getDic("lbl_ViewAll") + "</a>"; //전체보기
						sCommentHtml += "    </div>";
					}
					
					sCommentHtml += "    <ul class=\"comment_list\">";
					sCommentHtml += mobile_comment_getCommentHtml(res.commentlist, 'MemberOf', '0', pListYN, pDateID);
					sCommentHtml += "    </ul>";
					
					if(pListYN != "Y") {
						sCommentHtml += "</div>";
						
						//버튼 영역
						sCommentHtml += "<div class=\"section_comment_btn align\">";
						sCommentHtml += "    <a href=\"" + sALinkGoList + "\" class=\"more re\"><span class=\"tx\">" + mobile_comm_getDic("lbl_Comments") + " " + mobile_comm_getDic("lbl_ViewAll") + "</span></a>";
						sCommentHtml += "    <a href=\"" + sALinkGoList + "\" class=\"more write\"><span class=\"tx\">" + mobile_comm_getDic("lbl_com_writeComments") + "</span></a>"; //댓글쓰기
						sCommentHtml += "</div>";
					}
					
				} else { //댓글 없는 경우
					if(pListYN == "Y") {
						if($("#comment_list_page").attr("data-url").toUpperCase().indexOf("/COMMENT/LIST.DO") > -1){ //댓글 리스트
							sCommentHtml += "<div class=\"no_list\" style=\"padding : 50px 0;\">";
							sCommentHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
							sCommentHtml += "</div>";
						}
						else { //업무 시스템 하단에 표시될 때
							//버튼 영역					
							sCommentHtml += "<div class=\"section_comment_btn align\" style=\"padding-right : 5px !important;\">";
							sCommentHtml += "    <a href=\"" + sALinkGoList + "\" class=\"more write full\" style=\"margin : 0px;\"><span class=\"tx\">" + mobile_comm_getDic("lbl_com_writeComments") + "</span></a>"; //댓글쓰기
							sCommentHtml += "</div>";
						}
					} else {
						sCommentHtml += "<div class=\"section_comment_btn align\" style=\"padding-right : 5px !important;\">";
						sCommentHtml += "    <a href=\"" + sALinkGoList + "\" class=\"more write full\" style=\"margin : 0px;\"><span class=\"tx\">" + mobile_comm_getDic("lbl_com_writeComments") + "</span></a>"; //댓글쓰기
						sCommentHtml += "</div>";
					}
				}
					
				var $comment = null;
				
				if(pListYN != "Y") {
					$comment = $('div[data-role="dialog"][adata=view]').find('div[covi-mo-comment]').eq(0);
					if($comment.length == 0) {
						$comment = $('div[data-role="dialog"][adata=view]').find('div[covi-mo-comment]').eq(0);
					} else {
						$comment = $('div[data-role="dialog"][adata=view]').find('div[covi-mo-comment]').last();
					}
				} else {
					$comment = $('#comment_list_page').find('div[covi-mo-comment]').eq(0);
					if($comment.length == 0) {
						$comment = $('#comment_list_page').find('div[covi-mo-comment]').eq(0);
					} else {
						$comment = $('#comment_list_page').find('div[covi-mo-comment]').last();
					}
				}
				$comment.html(sLikeHtml + sCommentHtml);
				
				//CommentID가 존재할 경우
				if(_mobile_comment_list.CommentID != '0' && _mobile_comment_list.CommentID != ''){
					mobile_comment_setReCommentWrite(_mobile_comment_list.CommentID);
				}
				
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//댓글 html
function mobile_comment_getCommentHtml(pData, pNode, pValue, pListYN, pDateID) {
	
	//pData - 트리 전체 데이터 Array
	//pNode - 확인하는 node명
	//pValue - pNode가 이 값인걸 html 생성
	
	//그려야할 댓글을 조회
	var arrLists = new Array();
	try {
		for(var i = 0; i < pData.length; i++) {
			if(pData[i][pNode] == pValue) {
				arrLists.push(pData[i]);
			}
		}
	} catch(e) {
		arrLists = null;
	}
	
	var sHtml = "";
	
	var sALinkLike = "";
	var sALinkDelete = "";
	var sALinkReply = "";
	var sALinkEdit = "";
	
	$(arrLists).each(function (i, comment) {
		sALinkLike = "javascript: mobile_comment_addLike('Comment', '" + comment.CommentID + "');";
		sALinkReply = "javascript: mobile_comment_goCommentList('" + comment.TargetServiceType + "', '" + ((comment.TargetServiceType.toUpperCase() == "RESOURCE") ? comment.TargetID+'_'+pDateID : comment.TargetID) + "', '" + comment.CommentID + "', '" + "Reply" + "');";
		sALinkDelete = "javascript: mobile_comment_delComment('" + comment.TargetServiceType + "', '" + comment.TargetID + "', '" + comment.CommentID + "', '" + comment.MemberOf + "', '" + pListYN + "');";
		sALinkEdit = "javascript: mobile_comment_goCommentEdit('" + comment.TargetServiceType + "', '" + ((comment.TargetServiceType.toUpperCase() == "RESOURCE") ? comment.TargetID+'_'+pDateID : comment.TargetID) + "', '" + comment.CommentID + "', '" + comment.MemberOf + "', '" + pListYN + "', '" + "Edit" + "');";

		if(pListYN == "Y") { //리스트일 경우 이동할 필요 없음
			sALinkReply = "javascript: mobile_comment_setReCommentWrite('" + comment.CommentID + "');";
		}
		
		if(comment.DeleteDate != null && comment.DeleteDate != undefined && comment.DeleteDate != ''){
						
			if(comment.MemberOf.toString() == '0' && Number(comment.ReplyCount) > 0) {
				
				//iOS 오류 방지용
				if(comment.RegistDate != null && comment.RegistDate != undefined && comment.RegistDate.length > 20) {
					comment.RegistDate = CFN_TransLocalTime(comment.RegistDate).substring(0, 19);
					comment.RegistDate = mobile_comm_replaceAll(comment.RegistDate, '.', '/');
					comment.RegistDate = mobile_comm_replaceAll(comment.RegistDate, '-', '/');
				}
				
				sHtml += "<li class=\"comment\" comment=\"" + comment.CommentID + "\">";
				sHtml += "    <div class=\"lst_wp\">";
				sHtml += "        <div class=\"thumb_area\">";
				sHtml += "            <a href=\"#\" class=\"photo\">";
				sHtml += "                <span class=\"thumb\" style=\"background-image: url(" + mobile_comm_noperson() + ");\"></span>";
				sHtml += "                <span class=\"name\">" + mobile_comm_getDicInfo('작성자에 의해 삭제된 글입니다.;Deleted by author.;作成者によって削除されたものです;是被制作者删除的文章;;;;;;;;;', undefined) + "</span>";
				sHtml += "            </a>";
				sHtml += "        </div>";
				sHtml += "        <div class=\"date_area\"><span class=\"date\">" + mobile_comm_getDateTimeString3('LIST', new Date(comment.RegistDate)) + "</span></div>";
				sHtml += "        <div class=\"btn_area\">";
				sHtml += "            <a href=\"" + sALinkEdit + "\" class=\"btn\">" + mobile_comm_getDic("btn_Edit") + "</a>";	//수정
				sHtml += "            <a href=\"" + sALinkReply + "\" class=\"btn\">" + mobile_comm_getDic("btn_Reply") + "</a>";	//답글
				sHtml += "        </div>";
				sHtml += "    </div>";
				sHtml += "</li>";
				
				if(comment.ReplyCount > 0) {
					sHtml += mobile_comment_getCommentHtml(pData, 'MemberOf', comment.CommentID, pListYN, pDateID);
				}
			}		
			
		} else {
			
			if(pValue == "0" || pNode.toUpperCase() == "COMMENTID" ) {
				sHtml += "<li class=\"comment\" comment=\"" + comment.CommentID + "\">";
			} else {
				sHtml += "<li class=\"comment re\" comment=\"" + comment.CommentID + "\">";
			}
			
			//iOS 오류 방지용
			if(comment.RegistDate != null && comment.RegistDate != undefined && comment.RegistDate.length > 20) {
				comment.RegistDate = CFN_TransLocalTime(comment.RegistDate).substring(0, 19);
				comment.RegistDate = mobile_comm_replaceAll(comment.RegistDate, '.', '/');
				comment.RegistDate = mobile_comm_replaceAll(comment.RegistDate, '-', '/');
			}
			
			if(comment.Depth > 1) {
				sHtml += "    <div class=\"lst_wp\" style=\"margin: 0 0 0 " + (parseInt(23) + (parseInt(comment.Depth - 1) * parseInt(10))) + "px !important;\">";
			} else {
				sHtml += "    <div class=\"lst_wp\">";
			}
			
			sHtml += "        <div class=\"thumb_area\">";
			sHtml += "            <a href=\"#\" class=\"photo\">";
			sHtml += "                <span class=\"thumb\" style=\"background-image: url('" + mobile_comm_getimg(comment.Context.User.Photo) + "'), url('" + mobile_comm_noperson() + "');\"></span>";
			
			if(_mobile_board_list.FolderType == "Anonymous" && comment.AnonymousAuthYn == "Y") {
				sHtml += "                <span class=\"name\">" + comment.Context.User.Name + " " + comment.Context.User.JobTitle + "<span class=\"dept\">(" + mobile_comm_getDic("lbl_OneSelfWrite") + ")</span></span>";
			} else {
				sHtml += "                <span class=\"name\">" + comment.Context.User.Name + " " + comment.Context.User.JobTitle + "<span class=\"dept\">" + comment.Context.User.Dept + "</span></span>";
			}
			
			sHtml += "            </a>";
			sHtml += "            <a comment=\"" + comment.CommentID + "\" href=\"" + sALinkLike + "\" class=\"comment_like " + (comment.MyLikeCount > 0 ? "on" : "") + "\"><span class=\"comment_like_ico\"></span><span class=\"comment_like_cnt\">" + comment.LikeCount + "</span></a>";
			sHtml += "        </div>";
			sHtml += "        <p class=\"txt\">" + comment.Comment + "</p>";
			sHtml += "        <div class=\"date_area\"><span class=\"date\">" + mobile_comm_getDateTimeString3('LIST', new Date(comment.RegistDate)) + "</span></div>";
			
			var sFileHtml = "";
			var sImageHtml = "";
			var sImageSrc = "";
			
			//첨부파일 - File
			$(comment.Context.File).each(function (j, file) {
				//TODO: 확장자 체크 해야 하나 ??
//				if(file.SaveType.toUpperCase() == "IMAGE" || file.SaveType.toUpperCase() == "VIDEO") {
//					
//					sImageSrc = _mobile_comment_list.BackPath + file.FilePath + file.SavedName.split('.')[0] + '_thumb.jpg';
//					
//					sImageHtml += "    <a href=\"javascript: mobile_comm_getFile('" + file.FileID + "', '" + file.FileName + "');\" class=\"img_link\">";
//					sImageHtml += "        <span class=\"thum\"><img src=\"" +  sImageSrc + "\" alt=\"\"></span>";
//					sImageHtml += "    </a>";
//				} else {
					sFileHtml += "	<a href=\"javascript: mobile_comm_getFile('" + file.FileID + "', '" + file.FileName + "', '" + file.FileToken + "');\" class=\"file_link\">";
					sFileHtml += "		<input type='hidden' id='file_"+file.FileID+"' val='" + file.FileID + "'_'" + file.FileName + "'_'" + file.FileToken + "'>";
					sFileHtml += "		<span class=\"file_ico " + mobile_comm_getFileExtension(file.SavedName) + "\"></span><span class=\"file_txt ellip\">" + file.FileName + "</span><span class=\"file_size\">" + mobile_comm_convertFileSize(file.Size) + "</span>";
					if(file.SaveType.toUpperCase() == "IMAGE" || file.SaveType.toUpperCase() == "VIDEO") {					
						sFileHtml += "		<ul class=\"clearFloat fileUpview\"><li><div class=\"imgThum\">";
						sFileHtml += "			<img src=\"/covicore/mobile/comment/preview/"+_mobile_comment_list.TargetType+"/" + file.FileID + ".do\" alt=\"Image\">";
						sFileHtml += "		</div></li></ul>";
					}
					sFileHtml += "	</a>";
//				}
			});
			//지도-Location
			$(comment.Context.Location).each(function (j, location) {
				sImageHtml += "    <a href=\"javascript: mobile_comm_showLocation('" + location + "');\" class=\"img_link\">";
				sImageHtml += "        <span class=\"thum\"><img src=\"" + location + "\" alt=\"\"></span>";
				sImageHtml += "    </a>";
			});
			
			if(sFileHtml != "") {
				sHtml += "    <div class=\"file_area\">" + sFileHtml + "</div>";
			}
			if(sImageHtml != "") {
				sHtml += "    <div class=\"img_area\">" + sImageHtml + "</div>";
			}
			
			sHtml += "        <div class=\"btn_area\">";
			
			if(comment.RegisterCode.toUpperCase() == mobile_comm_getSession('UR_Code').toUpperCase() || comment.AnonymousAuthYn == "Y") {	
				sHtml += "        <a href=\"" + sALinkDelete + "\" class=\"btn\">" + mobile_comm_getDic("btn_delete") + "</a>";		//삭제
				sHtml += "            <a href=\"" + sALinkEdit + "\" class=\"btn\">" + mobile_comm_getDic("btn_Edit") + "</a>";	//수정
			}
			
			if(comment.Depth < (mobile_comm_getBaseConfig("ReWriteCommentCount") == "" ? 1 : parseInt(mobile_comm_getBaseConfig("ReWriteCommentCount")))) {
				sHtml += "            <a href=\"" + sALinkReply + "\" class=\"btn\">" + mobile_comm_getDic("btn_Reply") + "</a>";	//답글
			}
			
			sHtml += "        </div>";
			
			sHtml += "    </div>";
			sHtml += "</li>";
			
			if(comment.ReplyCount > 0) {
				sHtml += mobile_comment_getCommentHtml(pData, 'MemberOf', comment.CommentID, pListYN, pDateID);
			}
		}

	});
	
	return sHtml;
}

//좋아요/댓글 영역 초기화
function mobile_comment_clearCommentLike(pList) {
	var $comment = null;
	if(pList != undefined && pList == "N") {
		$comment = $('div[data-role="dialog"][adata=view]').find('div[covi-mo-comment]').eq(0);
		if($comment.length == 0) {
			$comment = $('div[data-role="dialog"][adata=view]').find('div[covi-mo-comment]').eq(0);
		} else {
			$comment = $('div[data-role="dialog"][adata=view]').find('div[covi-mo-comment]').last();
		}
	} else {
		$comment = $('#comment_list_page').find('div[covi-mo-comment]').eq(0);
		if($comment.length == 0) {
			$comment = $('#comment_list_page').find('div[covi-mo-comment]').eq(0);
		} else {
			$comment = $('#comment_list_page').find('div[covi-mo-comment]').last();
		}	
	}
	
	$comment.html('');
}





//공통> 좋아요  선택/취소
function mobile_comment_addLike(pTargetType, pTargetID) {
	var menuCode = "";
	if(pTargetType == "Board"){
		menuCode = mobile_comm_getQueryString("menucode");
	}
	var url = "/covicore/mobile/comment/like.do";
	var param = {
			targetType: pTargetType,
			targetID: pTargetID,
			FolderType: pTargetType,
			'menuCode': (menuCode != undefined) ? menuCode : ""
	};
	
	$.ajax({
		url : url,
		data : param,
		type : "post",
		async : false,
		success : function(res) {
			if (res.status == "SUCCESS") {
				var targetObj = null;
				
				if(pTargetType != "Comment") {
					targetObj = $("span.u_cnt");
				} else {
					targetObj = $("a[comment="+ pTargetID + "] span.comment_like_cnt");
				}
				
				targetObj.text(res.data > 0 ? res.data : 0);
				
				if(Number(res.myLike) > 0) {
					targetObj.parents("a").addClass("on");
				} else {
					targetObj.parents("a").removeClass("on");
				}
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
}

//공통> 댓글 추가 클릭
function mobile_comment_clickAddComment(pMode) {
	
	mobile_comment_addComment(_mobile_comment_list.TargetType, _mobile_comment_list.TargetID, _mobile_comment_list.CommentID, "comment_list_write");
	
}

//공통> 댓글 추가
function mobile_comment_addComment(pTargetType, pTargetID, pMemberOf, pWriteObjID) {

	var $obj = $('#' + pWriteObjID);
	
	var sComment = $($obj).find('div.u_cbox_write_inner > div.u_cbox_write_area > div.u_cbox_inbox > textarea').val().replaceAll("\n","<br>");
	var objcontext = {
		File : mobile_comm_uploadfilesObj.fileInfos,
		Location : [],//coviComment.commentVariables[elemID].mapFileInfos,
		Tag : [],//coviComment.getTags(elemID, 'main')
		MessageSetting : (typeof mobile_commment_messageSetting != 'undefined') ? mobile_commment_messageSetting : ''
		/*
		var context = {
				File : coviComment.commentVariables[elemID].frontFileInfos,
				Location : coviComment.commentVariables[elemID].mapFileInfos,
				Tag : coviComment.getTags(elemID, 'main')
		};
	 * */
	};
	
	//입력칸 데이터 초기화
	$($obj).find('div.u_cbox_write_inner > div.u_cbox_write_area > div.u_cbox_inbox > textarea').val("");
	$("#mobile_attach_uploded_file, #mobile_attach_uploded_img").hide().html("");
	mobile_comm_uploadfilesObj.files = [];
	mobile_comm_uploadfilesObj.fileInfos = [];
	
	var url = "/covicore/mobile/comment/addComment.do";
	var param = {
			targetType: pTargetType,
			targetID: (pTargetType.toUpperCase() == "RESOURCE") ? pTargetID.split('_')[0] : pTargetID,
			memberOf: pMemberOf,
			comment: sComment,
			context: objcontext,
			folderType: _mobile_board_list.FolderType
	};
	
	$.ajax({
		url : url,
		data : JSON.stringify(param),
		type : "post",
		contentType : "application/json; charset=UTF-8",
		async : false,
		success : function(res) {
			if (res.status == "SUCCESS") {
				mobile_comm_getFullComment();
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

// 댓글 수정
function mobile_comment_clickEditComment(pMode) {
	mobile_comment_EditComment(_mobile_comment_list.TargetType, _mobile_comment_list.TargetID, _mobile_comment_list.CommentID, _mobile_comment_list.MemberOf);
}

function mobile_comment_EditComment(pTargetType, pTargetID, pCommentID, pMemberOf) {
	
	var objcontext = {
		UploadFile : mobile_comm_editFilesObj.UploadFile,
		ExistFile : mobile_comm_editFilesObj.ExistFile,
		Location : [],
		Tag : []
	};

	
	$("#mobile_attach_uploded_file, #mobile_attach_uploded_img").hide().html("");
	mobile_comm_uploadfilesObj.files = [];
	mobile_comm_uploadfilesObj.fileInfos = [];
	mobile_comm_editFilesObj.ExistFile = [];
	
	var url = "/covicore/mobile/comment/edit.do";
	
	var param = {
			Comment: $("#comment_list_write_txt").val().replaceAll("\n","<br>"),
			CommentID : pCommentID,
			Context: objcontext,
			FolderType: _mobile_board_list.FolderType
	};
		
	$.ajax({
		url : url,
		data : JSON.stringify(param),
		type : "post",
		contentType : "application/json; charset=UTF-8",
		async : false,
		success : function(res) {
			if (res.status == "SUCCESS") {
				mobile_comm_getFullComment();
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//댓글 삭제
function mobile_comment_delComment(pTargetType, pTargetID, pCommentID, pMemberOf, pIsList) {
	//pTargetType, pTargetID: 삭제할 댓글의 소속 정보(게시, 자원예약 등)
	//pCommentID, pMemberOf: 삭제할 댓글의 정보

	if(confirm(mobile_comm_getDic('msg_RUDelete'))) {//삭제 하시겠습니까?
		var url = "/covicore/mobile/comment/delComment.do";
		var param = {
			commentID: pCommentID,
			memberOf: (pMemberOf != undefined) ? pMemberOf : "0", 
			folderType: _mobile_board_list.FolderType
		};
		
		$.ajax({
			url : url,
			data :param,
			type : "post",
			async : false,
			success : function(res) {
				if (res.status == "SUCCESS") {
					if(pIsList == "Y") {
						mobile_comm_getFullComment();
					} else {
						mobile_comment_getCommentLike(pTargetType, pTargetID, pIsList);
					}
				}
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror(url, response, status, error);
			}
		});
	}
}

//댓글 목록 페이지로 이동
function mobile_comment_goCommentList(pTargetType, pTargetID, pCommentID, pMode) {

	if(pMode != null || pMode != undefined) {
		_mobile_comment_list.Mode = pMode;
	} else {
		_mobile_comment_list.Mode = "";
	}
	
	var sUrl = "/covicore/mobile/comment/list.do";
	sUrl += "?targettype=" + pTargetType;
	sUrl += "&targetid=" + pTargetID;
	if(pCommentID != undefined){
		sUrl += "&commentid=" + pCommentID;
	}
	
	mobile_comm_go(sUrl, "Y");
}

//댓글 수정 이동
function mobile_comment_goCommentEdit(pTargetType, pTargetID, pCommentID, pMemberOf, pIsList, pMode) {
	
	if(pIsList == 'N') {
		mobile_comment_goCommentList(pTargetType, pTargetID, pCommentID, pMode);
	} else {
		_mobile_comment_list.TargetType = pTargetType;
		_mobile_comment_list.TargetID = pTargetID;
		_mobile_comment_list.CommentID = pCommentID;
		_mobile_comment_list.MemberOf = pMemberOf;
		
		$.ajax({
			url : "/covicore/mobile/comment/getCommentInfo.do",
			data : { commentID : pCommentID },
			type : "POST",
			async : false,
			success : function(res) {
				if (res.status == "SUCCESS") {
					var setComment = res.comment[0].Comment.split("<br>").join("\n");
					$("#comment_list_write_txt").val(setComment);
					$("#btnSave").removeAttr("onclick");
					$("#btnSave").attr("onclick", "mobile_comment_clickEditComment('list')");
					$("#btnSave").children(".u_cbox_txt_upload").text(mobile_comm_getDic("btn_Edit")); // 수정

					if(res.comment[0].Context.File.length >= 1){
						$.each(res.comment[0].Context.File,function (i, item) {
							mobile_commentEditView(item.SavedName,item.FileName,item.Size,item);
						});	
					}
				}
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror(url, response, status, error);
			}
		});
		
		mobile_comment_changeWriteArea("open");
	}
}

//댓글 목록 페이지로 이동
function mobile_comment_setReCommentWrite(pCommentID) {
	_mobile_comment_list.CommentID = pCommentID;
	
	var $comment = $('#comment_list_page').find('div[covi-mo-comment]').eq(0);
	
	//목록 숨김
	$comment.find('ul.comment_list > li.comment').hide();
			
	//해당 코멘트 찾아서 보이도록 설정
	$comment.find('ul.comment_list > li.comment[comment=' + _mobile_comment_list.CommentID + ']').find(".lst_wp").attr("style", "");
	$comment = $comment.find('ul.comment_list > li.comment[comment=' + _mobile_comment_list.CommentID + ']').show();
	
	//입력창 위치
	$('#comment_list_write').attr("style", "border-bottom: 0 !important;").insertAfter($comment);
	mobile_comment_changeWriteArea("open");
	
	//'본문보기' 숨기고 '전체 댓글 보기' 표시
	$('#comment_list_viewContent').hide();
	$('#comment_list_viewFullComment').show();
	
	//답글 기본문구 추가
	$('#comment_list_write_txt').attr('placeholder', mobile_comm_getDic("msg_Mobile_enterReComment"));
}

//댓글 입력영역 초기화 (작성페이지)
function mobile_comment_clearWrite() {
	//입력값 초기화
	$('#comment_write_write_txt').val('');
	$('#comment_write_write_add').html('');	
}

//파일업로드 후
function mobile_comment_changeupload(ele, pFileType) {
	var $files = $(ele).prop('files');				//업로드한 파일 정보
	var tempFileInfos = {  							//임시 파일 정보
		fileInfos : [], //파일 정보
		files : []		//multipart file
	};
	var i;
	
	//업로드한 파일 정보($files) 기반으로 임시 파일 정보(tempFileInfos) 구성
	for (i = 0; i < $files.length; i++) {
		//TODO: validation체크
		var fileObj = new Object();
		fileObj.FileName = encodeURIComponent($files[i].name);
		fileObj.Size = $files[i].size;
		fileObj.FileID = '';
		fileObj.FilePath = '';
		fileObj.SavedName = '';
		fileObj.FileType = 'normal';
		
		tempFileInfos.files.push($files[i]);
		tempFileInfos.fileInfos.push(fileObj);	
	}
	
	
	var sUrl = "/covicore/mobile/comment/uploadToFront.do";
	var fileData = new FormData();				//파일 정보 Form(ajax parameter용)
	
	//임시 파일 정보(tempFileInfos) 기반으로 파일 정보 Form(fileData) 구성
	fileData.append("fileInfos", JSON.stringify(tempFileInfos.fileInfos));
	fileData.append("servicePath", mobile_comm_replaceAll(mobile_comm_getBaseConfig('ProfileImagePath'), '{0}', mobile_comm_getSession('DN_Code')));
	
	for (i = 0; i < tempFileInfos.files.length; i++) {
		if (typeof tempFileInfos.files[i] == 'object') {
			fileData.append("files", tempFileInfos.files[i]);
		}
	}	
	
	//프론트에 파일 업로드
	$.ajax({
		url: sUrl,
		data: fileData,
		type:"post",
		dataType : 'json',
		async: false,
		processData : false,
		contentType : false,
		success:function (res) {
			if(res.list.length > 0 ){
				$files =  res.list;
			}else{ //when no file
				$files = {};
				//alert(mobile_comm_getDic(coviFile.dictionary.msg_noFile, coviFile.option.lang));
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(sUrl, response, status, error);
		}			
	});
	

	//mobile_comm_uploadfilesObj에 파일 정보 추가
	mobile_comm_uploadfilesObj.files = $.merge( mobile_comm_uploadfilesObj.files, tempFileInfos.files);
	mobile_comm_uploadfilesObj.fileInfos = $.merge( mobile_comm_uploadfilesObj.fileInfos, $files);
	mobile_comm_editFilesObj.UploadFile = $.merge( mobile_comm_editFilesObj.UploadFile, $files);
	
	for (i = 0; i < $files.length; i++) {
		
		var sFileHtml = "";
		
		var sFileExtensionCss = mobile_comm_getFileExtension($files[i].FileName);
		var sFileExtension = mobile_comm_getFileExtensionName($files[i].FileName);
		
		//추가된 파일 그리기
		if("BMP|GIF|JPG|PNG|".indexOf(sFileExtension.toUpperCase()) > -1)//if(pFileType.toUpperCase() == "IMG")
		{
			var sFileThumClass = "";
			var sFileThumSrc = _mobile_comment_list.FrontPath + $files[i].FrontAddPath + $files[i].SavedName.split('.')[0] + '_thumb.jpg';
			
			if("AVI|MP4|MKV|WMV|MOV|".indexOf(sFileExtension) > -1){
				//wmv,wma,avi,mp3,mpg,mov,asf,jpg,gif,png,swf
				sFileThumClass = "video";
			}
			
			sFileHtml += "<span class=\"img_area_btn\" data-savedname=\"" + $files[i].SavedName + "\">";
			sFileHtml += "    <a href=\"\" class=\"img_link\">";
			sFileHtml += "    	<span class=\"thum " + sFileThumClass + "\"><img src=\"" + sFileThumSrc + "\" alt=\"\"></span>";
			sFileHtml += "        <span style=\"display: none;\"  class=\"ico_file " + sFileExtensionCss + "\"></span>";
			sFileHtml += "        <p style=\"display: none;\" class=\"tit\"><span>" + $files[i].FileName + "</span></p>";
			sFileHtml += "        <span style=\"display: none;\" class=\"file_size\">" + mobile_comm_convertFileSize($files[i].Size) + "</span>";
			sFileHtml += "    </a>";
			sFileHtml += "    <a onclick=\"javascript: mobile_comment_deleteImgFile(this);\" class=\"img_link_del\"></a>";
			sFileHtml += "</span>";
			
			$('#mobile_attach_uploded_img').append(sFileHtml).show();
		}
		else
		{
			sFileHtml += "<span class=\"img_area_btn\" data-savedname=\"" + $files[i].SavedName + "\" style=\"width: 100%;\">";
			sFileHtml += "    <a href=\"\" class=\"file_link\">";
			sFileHtml += "    	<span class=\"file_ico " + sFileExtensionCss + "\"></span>";
			sFileHtml += "        <span class=\"file_txt ellip\">" + $files[i].FileName + "</span>";
			sFileHtml += "        <span class=\"file_size\">" + mobile_comm_convertFileSize($files[i].Size) + "</span>";
			sFileHtml += "    </a>";
			sFileHtml += "    <a onclick=\"javascript: mobile_comment_deleteImgFile(this);\" class=\"img_link_del\"></a>"; //class : btnPhotoRemove gray?
			sFileHtml += "</span>";
			
			$('#mobile_attach_uploded_file').append(sFileHtml).show();
		}
	}
	
	//전자결재 첨부파일 업로드 추가
	if(typeof(readfiles) != "undefined") { 
		var aObjFiles = [];
		
		if (mobile_obj_filelist.length == 0) {
			readfiles($files); //CommonControls.js 내 함수
			SetFileInfo($files);
		} else {
			for (i = 0; i < $files.length; i++) {
				var bCheck = false;
				for (var j = 0; j < mobile_obj_filelist.length; j++) {
					if ($files[i].FileName == mobile_obj_filelist[j].FileName) { // 중복됨
						bCheck = true;
						alert(mobile_comm_getDic("msg_AlreadyAddedFile"));
						break;
					}
				}
				if (!bCheck) {
					aObjFiles.push($files[i]);
				}
			}
			readfiles(aObjFiles);
			SetFileInfo(aObjFiles);
		}
	}
}

//댓글 영역 첨부파일 삭제
function mobile_comment_deleteImgFile(elem){
	var $span = $(elem).parent();
	if($span.length){
		$span.remove();
		mobile_comment_removeFrontFile($span.attr('data-savedname'));
	}
}

//프론트에 올라간 파일 정보 삭제
function mobile_comment_removeFrontFile(savedName){
	for (var i =0; i < mobile_comm_uploadfilesObj.fileInfos.length; i++){
		var frontFile = mobile_comm_uploadfilesObj.fileInfos[i];
		if(savedName == frontFile.SavedName){
			mobile_comm_uploadfilesObj.files.splice(i,1);
			mobile_comm_uploadfilesObj.fileInfos.splice(i,1);
			break;
		}
	}
}

//전체 댓글 보기로 돌아가기
function mobile_comm_getFullComment(){
	
	//입력란 조정
	$('#comment_list_write').prependTo($('div.section_comment'));
	$("#comment_list_write").attr("style", "");
	mobile_comment_changeWriteArea("close");
	
	$('.u_cbox_write.open').each(function (wi, wComment) {
		if(wi > 0){
			$(wComment).removeClass("open");
		}
	});
	
	//데이터 초기화
	_mobile_comment_list.CommentID = '0';
	mobile_comment_getCommentLike(_mobile_comment_list.TargetType, _mobile_comment_list.TargetID, 'Y');
	
	//'전체 댓글 보기' 숨기고 '본문보기' 표시
	//$('#comment_list_viewContent').show();
	$('#comment_list_viewFullComment').hide();
	
	//첨부파일 객체 초기화
	mobile_comm_uploadfilesObj = {
		fileInfos : [],
		files : []
	};
	
	mobile_comm_editFilesObj = {
		UploadFile : [],
		ExistFile : []
	};
	
	mobile_comm_back();
}

//댓글 수정 파일데이터
function mobile_commentEditView(SavedName,FileName,Size,pfiles){
	var sFileHtml = "";
	
	mobile_comm_editFilesObj.ExistFile.push(pfiles);
	
	var sFileExtensionCss = mobile_comm_getFileExtension(FileName);
	var sFileExtension = mobile_comm_getFileExtensionName(FileName);
	//추가된 파일 그리기
	if("BMP|GIF|JPG|PNG|".indexOf(sFileExtension.toUpperCase()) > -1)//if(pFileType.toUpperCase() == "IMG")
	{
		var sFileThumClass = "";
		var sFileThumSrc =  "/covicore/mobile/comment/preview/"+_mobile_comment_list.TargetType+"/" + pfiles.FileID + ".do"
		
		sFileHtml += "<span class=\"img_area_btn\" data-savedname=\"" + SavedName + "\">";
		sFileHtml += "    <a href=\"\" class=\"img_link\">";
		sFileHtml += "    	<span class=\"thum " + sFileThumClass + "\"><img src=\"" + sFileThumSrc + "\" alt=\"\"></span>";
		sFileHtml += "        <span style=\"display: none;\"  class=\"ico_file " + sFileExtensionCss + "\"></span>";
		sFileHtml += "        <p style=\"display: none;\" class=\"tit\"><span>" + FileName + "</span></p>";
		sFileHtml += "        <span style=\"display: none;\" class=\"file_size\">" + mobile_comm_convertFileSize(Size) + "</span>";
		sFileHtml += "    </a>";
		sFileHtml += "    <a onclick=\"javascript: mobile_comment_editDeleteImgFile(this);\" class=\"img_link_del\"></a>";
		sFileHtml += "</span>";
		
		$('#mobile_attach_uploded_img').append(sFileHtml).show();
	}
	else
	{
		sFileHtml += "<span class=\"img_area_btn\" data-savedname=\"" + SavedName + "\" style=\"width: 100%;\">";
		sFileHtml += "    <a href=\"\" class=\"file_link\">";
		sFileHtml += "    	<span class=\"file_ico " + sFileExtensionCss + "\"></span>";
		sFileHtml += "        <span class=\"file_txt ellip\">" + FileName + "</span>";
		sFileHtml += "        <span class=\"file_size\">" + mobile_comm_convertFileSize(Size) + "</span>";
		sFileHtml += "    </a>";
		sFileHtml += "    <a onclick=\"javascript: mobile_comment_editDeleteImgFile(this);\" class=\"img_link_del\"></a>"; //class : btnPhotoRemove gray?
		sFileHtml += "</span>";
			
		$('#mobile_attach_uploded_file').append(sFileHtml).show();
	}

}

//댓글 영역 수정 첨부파일 삭제
function mobile_comment_editDeleteImgFile(elem){
	var $span = $(elem).parent();
	if($span.length){
		$span.remove();
		mobile_comment_editRemoveFrontFile($span.attr('data-savedname'));
	}
}

//프론트에 수정 파일 정보 삭제
function mobile_comment_editRemoveFrontFile(savedName){
	for (var i =0; i < mobile_comm_editFilesObj.ExistFile.length; i++){
		var frontFile = mobile_comm_editFilesObj.ExistFile[i];
		if(savedName == frontFile.SavedName){
			mobile_comm_editFilesObj.UploadFile.splice(i,1);
			mobile_comm_editFilesObj.ExistFile.splice(i,1);
			break;
		}
	}
}
