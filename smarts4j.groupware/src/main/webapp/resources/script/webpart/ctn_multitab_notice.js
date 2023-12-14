/**
 * ctn_multitab_notice - 공지사항, 통합게시(멀티게시판)

 * 2023.08.01 : 멀티탭 게시판.
 * fixTab : 공지사항과 최근게시는 고정.
 * 		(공지사항/최근게시는 게시판 세팅의 공지/최근게시 설정이 이루어진 것으로 하나의 게시판이 아닌 여러 게시판의 내용을 가져옴)
 * changeableTab : 공지사항, 최근게시 제외하고 나머지 탭정보는 folderID가 지정되어 있는 게시판으로 WpMultiBoard 기초설정 값에서 가져옴.
 */

var ctnMultiTabNotice = {
	boardConfig : {}
	, pageSize : 0
	, settingKeyID : ""
	, wpIdNum : ""
	, multiBoard : ""
	, folderID : ""
	, isGetConfig : false 	// 단일 게시판 여부.
	, today : new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"))
	, init: function (data, ext, pType, pWebpartID) {
		ctnMultiTabNotice.pageSize = ext.pageSize;
		ctnMultiTabNotice.settingKeyID = ext.settingKey;
		ctnMultiTabNotice.wpIdNum = pWebpartID.replace("WP", "");
		
		let strBoards = Common.getBaseConfig(ctnMultiTabNotice.settingKeyID);
		let $tabList = $("#"+pWebpartID).find(".tab_list");

		let $webpart = $("#"+pWebpartID);
		$webpart.addClass("widget_board");
		
		if (strBoards !== "") {
			ctnMultiTabNotice.multiBoard = strBoards;
			ctnMultiTabNotice.getTitleInfo(pWebpartID);
		}
		
		$tabList.find("button").on('click', function() { 	// title btn click.
			let btnIdx = $(this).index();
			$(this).attr("aria-selected", "true").siblings().attr("aria-selected", "false");
			ctnMultiTabNotice.getBoardInfo(btnIdx, pWebpartID, ctnMultiTabNotice.pageSize);
		});
		
		ctnMultiTabNotice.getBoardInfo("0", pWebpartID, ctnMultiTabNotice.pageSize);
		
		this.sessionObj = Common.getSession();
		if (sessionObj["isAdmin"] === "Y" || sessionObj["isEasyAdmin"] === "Y") {
			
			// 더보기 설정 버튼 추가.
			let $option = $webpart.find("div.widget_option");
			$option.append($("<button>",{"type":"button","data-action":"setting"})
					.append($("<span>",{"text":Common.getDic("lbl_Set")}))
			);
			
			// 설정 버튼 클릭. 내부 item click events.
			$option.find("button").on("click", function() {
				let $this = $(this);
				let actionOptions = $this.attr('data-action');
				
				switch (actionOptions) {
					case 'setting': 	// 설정 클릭.
						ctnMultiTabNotice.openPopup(pWebpartID, ctnMultiTabNotice.multiBoard);
						break;
				}
			});
		}
	}
	
	, getTitleInfo(pWebpartID) { 	// changeable tab title setting.
		let $webpart = $("#"+pWebpartID);
		let $tabList = $("#"+pWebpartID).find(".tab_list");
		
		if (coviUtil.isMobile()) { 	// CASE : mobile mode. 3개까지만(공지사항, 최근게시, 경조사) 보여준다.
			$tabList.find("button:gt(2)").remove();
		} else {
			$tabList.find("button:gt(1)").remove();
		}
		
		$.ajax({
			type : "POST"
			, async : false
			, url : "/groupware/portal/getBoardFolderInfo.do"
			, data : {"multiBoard" : ctnMultiTabNotice.multiBoard}
			, success : function(data) {
				if (data.status === "SUCCESS") {
					if (data.list.length > 0) {
						data.list.forEach(function(obj) {
							$tabList.append($("<button>", {"type": "button", "text" : obj.DisplayName, "folder-id" : obj.FolderID, "class" : "tab", "role" : "tab", "aria-selected" : false}))
						});
						
						let $buttons = $tabList.find("button");

						if (coviUtil.isMobile()) { 	// mobile tab header click 표시.
							$webpart.find(".widget_empty").addClass("ui_empty");
							$buttons.on('click', function () {
							    const target = $(this).attr('aria-controls');
							    $(this).attr('aria-selected', 'true').siblings().attr('aria-selected', 'false');
							
							    if (target !== undefined) {
							        $('#' + target + '').removeAttr('hidden').siblings('[role="tabpanel"]').attr('hidden', 'hidden');
							    }
							});
						} else {
							// 클릭 이벤트 재지정.
							$buttons.on('click', function() { 	// title btn click.
								let btnIdx = $(this).index();
								ctnMultiTabNotice.getBoardInfo(btnIdx, pWebpartID, ctnMultiTabNotice.pageSize);
							});
						}
					}
				}
			}
		});
	}
	
	// 게시판 옵션 조회.(단일 folderID의 게시글 불러오기는 해당 게시판의 설정을 불러옴)
	, getBoardInfo : function (pTabIdx, pWebpartID, pPageSize) {
		ctnMultiTabNotice.boardConfig = {};

		switch(pTabIdx) {
			case 0 : 	// 공지사항
			case "0" :
			case 1 : 	// 최근게시
			case "1":
				ctnMultiTabNotice.isGetConfig = false;
				break;
			default : 	// folderID가 있는 단일게시판.
				ctnMultiTabNotice.isGetConfig = true;
				ctnMultiTabNotice.folderID = $("#"+pWebpartID).find(".tab_list button").eq(pTabIdx).attr("folder-id");
				break;
		}
		
		if (ctnMultiTabNotice.isGetConfig) {
			$.ajax({
				type : "POST"
				, url : "/groupware/admin/selectBoardConfig.do"
				, async : false
				, data : { "folderID": (ctnMultiTabNotice.folderID == "undefined" ? "": ctnMultiTabNotice.folderID) }
		       	, success : function(data) {
					ctnMultiTabNotice.boardConfig = data.config;
					ctnMultiTabNotice.getList(pTabIdx, pWebpartID, pPageSize);
				}
				, error : function(response, status, error) {
					CFN_ErrorAjax("/groupware/admin/selectBoardConfig.do", response, status, error);
				}
			});
		} else {
			ctnMultiTabNotice.getList(pTabIdx, pWebpartID, pPageSize);
		}
	}
	
	, getList : function(pTabIdx, pWebpartID, pPageSize) { 	// 공지사항 불러오기.
		let params = {};
		let txtUrl = "";
		let pageSize = 15; 	// 화면에 보여질 목록 default 갯수 (x2,y2).
		let txtMoreUrl = "";
		
		if (!isNaN(pPageSize)) {
			pageSize = pPageSize;
		}
		
		switch(pTabIdx) {
			case 0 :	// 공지사항.
			case "0" : 	
				txtUrl = "/groupware/board/selectNoticeMessageList.do";
				params = {"pageSize" : pageSize};
				break;
			case 1 :	// 최근게시.
			case "1" :
				txtUrl = "/groupware/board/selectLatestMessageList.do";
				params = {
					"bizSection" : "Board"
					, "menuID" : Common.getBaseConfig("BoardMenu")
					, "messageCount" : pageSize
				};
				break;
			default :
				txtUrl = "/groupware/board/selectMessageGridList.do";
				params = {
					"boardType" : "Normal"
					, "bizSection" : "Board"
					, "folderID" :  ctnMultiTabNotice.folderID
					, "pageNo" : 1
					, "pageSize" : pageSize
				}
				break;
		}

		if (!(txtUrl === "")) {
			$.ajax({
				type : "POST"
				, url : txtUrl
				, data : params
				, async : false
				, success : function(data) {
					if (data.status === "SUCCESS") {
						// tab contents setting.
						let $ulTab = $("#"+pWebpartID).find("ul[name=tab]");
						$ulTab.find("li").remove();
						let listObj = data.list;
						
						if ( listObj.length != 0 ) {
							$("#"+pWebpartID + " .widget_content").attr("hidden", false);
							$("#"+pWebpartID + " .widget_empty").attr("hidden", true);
							
							switch(pTabIdx) {
								case 0 :
								case "0" :
								case 1 :
								case "1" :
									listObj.forEach(function(key) {
										$ulTab.append($("<li>")
											.append($("<a>", {"href": "#", "class": "post_item"})
												.append($("<span>", {"class": "item_title", "text": key.Subject}))
												.append($("<span>", {"class": "item_user", "text": key.CreatorName}))
												.append($("<time>", {"class": "item_date", "text": key.CreateDate.split(" ")[0]}))
											)
											.on("click", function() {
												ctnMultiTabNotice.goViewPopup(key.MenuID, key.Version, key.FolderID, key.MessageID);
											})
										)
									});
									
									if (coviUtil.isMobile()) {
										txtMoreUrl = "/groupware/mobile/board/list.do?menucode=BoardMain&boardtype=Total";
									} else {
										txtMoreUrl = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuCode=BoardMain";	
									}
									
									break;
								default :
									let pRecentlyFlag = ctnMultiTabNotice.boardConfig.UseIncludeRecentReg;
									let pRecentlyDay = ctnMultiTabNotice.boardConfig.RecentlyDay;

									listObj.forEach(function(key) {
										if (ctnMultiTabNotice.isRecentFlag(pRecentlyFlag, pRecentlyDay, key.CreateDate)) {
											$ulTab.append($("<li>")
												.append($("<a>", {"href": "#", "class": "post_item"})
													.append($("<i>", {"class":"new_badge", "text": "N"}))
													.append($("<span>", {"class": "item_title", "text": key.Subject}))
													.append($("<span>", {"class": "item_user", "text": key.CreatorName}))
													.append($("<time>", {"class": "item_date", "text": key.CreateDate.split(" ")[0]}))
												)
												.on("click", function() {
													ctnMultiTabNotice.goViewPopup(key.MenuID, key.Version, key.FolderID, key.MessageID);
												})
											)
										} else {
											$ulTab.append($("<li>")
												.append($("<a>", {"href": "#", "class": "post_item"})
													.append($("<span>", {"class": "item_title", "text": key.Subject}))
													.append($("<span>", {"class": "item_user", "text": key.CreatorName}))
													.append($("<time>", {"class": "item_date", "text": key.CreateDate.split(" ")[0]}))
												)
												.on("click", function() {
													ctnMultiTabNotice.goViewPopup(key.MenuID, key.Version, key.FolderID, key.MessageID);
												})
											)	
										}
									});
									
									if (coviUtil.isMobile()) {
										txtMoreUrl = "/groupware/mobile/board/list.do?boardtype=Normal&menucode=BoardMain&folderid="+ctnMultiTabNotice.folderID;
									} else {
										txtMoreUrl = "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&boardType=Normal&CLBIZ=Board&menuCode=BoardMain&folderID="+ctnMultiTabNotice.folderID;	
									}
									
									break;
							}
							// moreUrl.
							$("#"+pWebpartID+" .action").find("a.widget_more").attr("href", txtMoreUrl);
							
						} else {
							// case : data count is 0.
							$("#"+pWebpartID + " .widget_content").attr("hidden", true);
							$("#"+pWebpartID + " .widget_empty").attr("hidden", false);
						}
					}
				}
			});
		}
	}
	
	// 단일 폴더 조회의 경우, 해당 폴더의 게시글 설정값에서 최근게시 표시여부를 확인 후 표기.
	, isRecentFlag : function(pRecentlyFlag, pRecentlyDay, pCreateDate) {
		if (pRecentlyFlag === "Y" && pRecentlyDay > 0) {
			let registDate = new Date(CFN_TransLocalTime(pCreateDate));
			if ( ctnMultiTabNotice.today < registDate.setDate(registDate.getDate()+ pRecentlyDay)) {
				return true;
			}
		}
		return false;
	}
	
	// 게시글 상세 팝업.
	, goViewPopup: function(pMenuID, pVersion, pFolderID, pMessageID){
		let pBizSection = 'Board';
		
		if (coviUtil.isMobile()){	// mobile인 경우
			if (mobile_board_checkReadAuth(pBizSection, pFolderID, pMessageID, pVersion)){	//읽기 권한 체크
				var url = "/groupware/mobile/" + pBizSection.toLowerCase() + "/view.do?folderid=" + pFolderID + "&version=" + pVersion + "&messageid=" + pMessageID + "&boardtype=Normal&menucode=Board";
				mobile_comm_go(url, "Y");
			} else {//권한 없음
				alert(mobile_comm_getDicInfo("msg_UNotReadAuth"));
			}
		}	else{
			var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", pBizSection, pMenuID, pVersion, pFolderID, pMessageID);
			Common.open("", "boardViewPop", Common.getDic("lbl_DetailView"), url, "1080px", "600px", "iframe", true, null, null, true);
		}
	}
	
	// 설정 팝업(게시판 변경)
	, openPopup:function(pWebpartID, pCurrentVal) {
		let strUrl = "/groupware/portal/setWebpartPopup.do";
		strUrl += "?webpartID="+pWebpartID;
		strUrl += "&popupType=2";
		strUrl += "&currentValue="+pCurrentVal;
		let strTitle = Common.getDic("lbl_Boards")+" "+Common.getDic("lbl_change"); 	// 게시판 변경
		Common.open("", "setWebpartPopup", strTitle, strUrl, "431px", "175px", "iframe", true, null, null, true); 	//open: function (button_id, object_id, title, source, w, h, pMode, pIsModal, posX, posY, pReSize, objectType)
		
		return new Promise(resolve => {
			const listener = (e) => {
				if (e.data.functionName === pWebpartID) {
					var params = e.data.params;
					
					if (params.status=="SUCCESS") {
						ctnMultiTabNotice.changeFolderID(pWebpartID, params.saveValue);
					}					
					window.removeEventListener('message', listener)
				}	
			}
			window.addEventListener('message', listener)
		});
	}
	
	// folderID 변경.
	, changeFolderID : function(pWebpartID, pValue) {
		ctnMultiTabNotice.multiBoard = pValue;
		
		$.ajax({
			type : "POST"
			, url: "/groupware/portal/changeFolderidOption.do"
			, data : {"setKeyID" : ctnMultiTabNotice.settingKeyID, "changeConfVal" : pValue, "pageSize": ctnMultiTabNotice.pageSize, "pageOffset": "0"}
			, success : function(result) {
				if (result.status === "SUCCESS") {
					if (result?.message) {
						Common.Warning(result.message);
						return;
					}
					
					coviCmn.reloadCache("BASECONFIG", sessionObj.DN_ID);
					coviStorage.clear("CONFIG");
				}
			}
			, error : function(response, status, error) {
				CFN_ErrorAjax("/groupware/portal/changeFolderidOption.do", response, status, error);
			}
		});
	}
	
}
