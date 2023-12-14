/**
 * pnShareTask - [포탈개선] My Place - 공유 업무
 */
var pnShareTask = {
	webpartType: "",
	attachFileInfoObj: {},
	init: function (data, ext){
		pnShareTask.setEvent();
	},
	setEvent: function(){
		$(".PN_ShareBox").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
			if(!$(this).hasClass("active")){
				$(this).addClass("active");
				$(this).next(".PN_portlet_menu").stop().slideDown(300);
				$(this).children(".PN_portlet_btn > span").addClass("on");
			}else{
				$(this).removeClass("active");
				$(this).next(".PN_portlet_menu").stop().slideUp(300);
				$(this).children(".PN_portlet_btn > span").removeClass("on");
			}
		});
		
		$(".PN_ShareBox").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on");
		});
		
		$(".PN_searchBox01 .btnSearchType01").on("click", function(){
			$(".PN_Share_Search input[type=text]").val("");
			
			pnShareTask.openTaskSearchPopup();
		});
		
		$(".PN_ShareBox").closest(".PN_myContents_box").find(".PN_portlet_menu li[mode=write]").off("click").on("click", function(){
			Common.open("", "taskSet", "<spring:message code='Cache.lbl_task_addTask'/>", "/groupware/task/goTaskSetPopup.do?mode=Add&isOwner=Y&folderID=0", "950px", "650px", "iframe", true, null, null, true); // 업무추가
		});
	},
	getTaskData: function(pFolderID, pTaskID){
		$.ajax({
			url: "/groupware/task/getTaskData.do",
			type: "POST",
			data: {
				TaskID: pTaskID,
				FolderID: pFolderID
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var taskInfo = data.taskInfo;
					var nowDateTime = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd")).getTime();
					var endDateTime = new Date(taskInfo.EndDate.replaceAll("-", "/")).getTime();
					var period = taskInfo.StartDate.replaceAll("-", ".") + " ~ " + taskInfo.EndDate.replaceAll("-", ".");
					var dDay = Math.ceil((endDateTime - nowDateTime) / (1000 * 60 * 60 * 24));
					var dDayStr = dDay >= 0 ? "D-" + dDay : "D+" + dDay * (-1);
					if(dDayStr.indexOf("NaN") > -1) dDayStr = "D-Day";
					var userCode = Common.getSession("USERID");
					var isOwner = (taskInfo.RegisterCode == userCode || taskInfo.OwnerCode == userCode) ? "Y" : "N";
					
					$(".shPeriod").show();
					$(".shPeriod .shDday").text(dDayStr);
					$(".shPeriod .shDate").text(period);
					$(".PN_Share_Process").show();
					$(".PN_Share_Process .PN_shState").text(taskInfo.TaskState);
					$(".PN_Share_Process .PN_shPer").text(taskInfo.Progress + "%");
					$("#PN_ProcessBar").css("width", taskInfo.Progress + "%");
					$(".PN_Share_Search input[type=text]").val(taskInfo.Subject);
					
					$(".shPeriod .shBtn").off("click").on("click", function(){
						pnShareTask.openTaskSetPopup(pFolderID, pTaskID, isOwner);
					});
				}else{
					Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>"); // 오류가 발생하였습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/task/getTaskData.do", response, status, error);
			}
		});
	},
	openTaskSetPopup: function(pFolderID, pTaskID, pIsOwner){
		Common.open("", "TaskSet", "<spring:message code='Cache.lbl_task_taskManage' />", "/groupware/task/goTaskSetPopup.do?mode=Modify&isOwner="+pIsOwner+"&taskID="+pTaskID+"&folderID="+pFolderID+"&isSearch=N", "950px", "650px", "iframe", true, null, null, true); // 업무관리
	},
	openTaskSearchPopup: function(){
		Common.open("", "TaskSearch", "<spring:message code='Cache.lbl_search' />", "/groupware/task/goTaskSearchPopup.do?searchWord=&callBackFunc=pnShareTask.taskSearchCallBack", "500px", "500px", "iframe", true, null, null, true); // 검색
	},
	taskSearchCallBack: function(pJsonData){
		pnShareTask.getTaskData(pJsonData.FolderID, pJsonData.TaskID);
		pnShareTask.setCommentView(pJsonData.TaskID);
	},
	setCommentView: function(pTaskID){
		var userCode = Common.getSession("USERID");
		
		$.ajax({
			type: "POST",
			url: "/groupware/pnPortal/selectCommentList.do",
			data: {
				"targetServiceType": "Task",
				"targetID": pTaskID,
			},
			success: function(res){
				if(res.list && res.list.length > 0){
					var commentList = res.list;
					var commentHtml = "";
					$(".shChatArea").closest(".PN_Share_Chat").show();
					$(".PN_Share_Chat.PN_nolist").hide();
					
					$.each(commentList, function(idx, item){
						var divWrap = $("<div class='shChatBox'></div>");
						var userName = item.Context.User.Name;
						var photoPath = item.Context.User.Photo;
						var registDate = new Date(CFN_TransLocalTime(item.RegistDate)).format("yyyy.MM.dd HH:mm");
						var commContent = coviComment.replaceHashTag(item.Comment).replace(/(\n|\r\n)/g, "<br>");
						pnShareTask.attachFileInfoObj[item.CommentID] = item.Context.File;
						
						divWrap.append($("<div class='shChat'></div>")
									.append($("<p class='shTxt_c'></p>").html(commContent))
									.append($("<span class='shDate_c'></span>").text(registDate))
									.append($("<div class='tIcon'></div>")
										.append($("<a href='#' class='btn_like' onclick='pnShareTask.addCommentLike(this, " + item.CommentID + ")'></a>")
											.append($("<span></span>")))));
						
						if(item.RegisterCode == userCode){
							divWrap.addClass("shChatMe");
						}else{
							divWrap.append($("<div class='shImgBox'></div>")
									.attr("cid", item.CommentID)
									.append($("<span class='shImg'></span>"))
									.append($("<strong class='shName'></strong>").text(userName)));
						}
						
						if(photoPath){
							divWrap.find(".shImg")
								.append($("<img class='mCS_img_loaded'>")
									.attr("src", photoPath)
									.attr("onerror", "pnShareTask.onErrorImage(this, '" + userName.substring(0, 1) + "');"));
						}else{
							divWrap.find(".shImg")
							.append($("<b class='mColor'></b>").text(userName.substring(0, 1)));
						}
						
						if(item.MyLikeCount > 0) divWrap.find(".btn_like span").addClass("like");
						
						if(pnShareTask.attachFileInfoObj[item.CommentID].length > 0){
							divWrap.find(".tIcon")
								.prepend($("<a href='#' class='PN_btn_File' onclick='pnShareTask.openFileList(this, " + item.CommentID + ");'></a>").text("첨부파일"));
						}
					
						commentHtml += $(divWrap)[0].outerHTML;
					});
					
					$(".shChatArea").empty().append(commentHtml);
				}else{
					$(".shChatArea").closest(".PN_Share_Chat").hide();
					$(".PN_Share_Chat.PN_nolist").show();
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/comment/get.do", response, status, error);
	   		}
	 	});
	},
	onErrorImage: function(pImgObj, pName){
		var bTag = $("<b>").addClass("mColor").text(pName);
		var imgSpan = $(pImgObj).closest(".shImg");
		var cbClassName = "." + imgSpan.closest(".shChatArea").attr("class");
		
		imgSpan.empty();
		imgSpan.append(bTag);
		pnShareTask.addClassImgBox(cbClassName);
	},
	addClassImgBox: function(posTagName){
		var imgCnt = 0;
		
		if(posTagName){
			$.each($(posTagName).find(".mColor"), function(idx, itme){
				var classIdx = (imgCnt % 5) + 1;
				$(this).attr("class", "");
				$(this).attr("class", "mColor mColor" + classIdx);
				imgCnt++;
			});
		}
	},
	addCommentLike: function(pCommObj, pTaskID){
		$.ajax({
			type: "POST",
			url: "/covicore/comment/addLike.do",
			data: {
				"TargetType": "Comment",
				"TargetID": pTaskID,
				"Point": "0"
			},
			success: function(res){
				if(res.status == "SUCCESS"){
					// 하트 애니메이션
					if(res.myLike) $(pCommObj).children("span").addClass("like");
					else $(pCommObj).children("span").removeClass("like");
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/comment/addLike.do", response, status, error);
	   		}
	 	});
	},
	openFileList: function(pObj, pCommentID){
		var fileList = pnShareTask.attachFileInfoObj[pCommentID];
		
		if(!axf.isEmpty($(pObj).parent().find(".file_box").html())){
			$(pObj).parent().find(".file_box").remove();
			return false;
		}
		
		$(".file_box").remove();
		
		if(fileList.length > 0){
			var ulWrap = $("<ul class='file_box'></ul>")
							.append($("<li class='boxPoint'></li>"));
			
			for(var i = 0; i < fileList.length; i++){
				ulWrap.append($("<li></li>")
							.append($("<a href='#'></a>")
								.attr("onclick", "pnShareTask.attachFileDownLoadCall("+i+", "+pCommentID+")")
								.text(fileList[i].FileName)));
			}
			
			$(pObj).parent().append(ulWrap);
		}
	},
	attachFileDownLoadCall: function(pIndex, pCommentID){
		var fileInfoObj = pnShareTask.attachFileInfoObj[pCommentID][pIndex];
		Common.fileDownLoad($$(fileInfoObj).attr("FileID"), $$(fileInfoObj).attr("FileName"), $$(fileInfoObj).attr("FileToken"));
	}
}