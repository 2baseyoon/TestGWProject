/**
 * ctn_notice - 자유게시. folderID로 게시판(Board) 내용을 가져온다.
 * 디자인 팀의 요청으로 a 태그 href 속성 필수. href="#" 지정(더보기 버튼의 ext.moreUrl).
 */
var ctnBoard = {
	tmpFolderID : ""
	, pageSize : 0
	, settingKeyID : ""
	, confVal : ""
	, wpIdNum : ""
	, init: function (data, ext, pType, pWebpartID) {
		ctnBoard.pageSize = ext.pageSize;
		ctnBoard.settingKeyID = ext.settingKey;
		ctnBoard.wpIdNum = pWebpartID.replace("WP", "");
		ctnBoard.confVal = Common.getBaseConfig(ctnBoard.settingKeyID);
		
		let $webPart = $("#"+pWebpartID);
		let arrFolderID = {};
		
		if (ctnBoard.confVal) { 	// 기초설정값이 있을 때.
			arrFolderID = ctnBoard.confVal.split(';');	
			arrFolderID.forEach(function(el) {
				if (ctnBoard.wpIdNum === el?.split(":")[0]) { 	// 현재 웹파트
					ctnBoard.tmpFolderID = el.split(":")[1]; 	// 현재 폴더ID
				}
			});
			
			if (ctnBoard.tmpFolderID !== "") {
				ctnBoard.getBoardList(pWebpartID); 	// 데이터 조회.
			} else {
				$webPart.find(".widget_content").hide();
				$webPart.find(".widget_empty").attr("hidden", false);
			}
		} else { 	// 기초설정 값이 없을 때.
			$webPart.find(".widget_content").hide();
			$webPart.find(".widget_empty").attr("hidden", false);
		}
		
		
		let $option = $webPart.find("div.widget_option");
		
		this.sessionObj = Common.getSession(); 	// 설정 버튼은 관리자&PC모드 경우에만 보여줌.
		if ( (sessionObj["isAdmin"] === "Y" || sessionObj["isEasyAdmin"] === "Y") && !coviUtil.isMobile() ) {
			$option.append($("<button>",{"type":"button","data-action":"setting"})
				.append($("<span>",{"text":Common.getDic("lbl_Set")}))
			);
			
			$option.find("button").on("click", function() { 	// 더보기(...) 버튼 설정 클릭 이벤트.
				let $this = $(this);
				let actionOptions = $this.attr('data-action');
				
				switch (actionOptions) {
					case 'setting': 	// 설정 클릭.
						ctnBoard.openPopup(pWebpartID, ctnBoard.tmpFolderID);
						break;
					default :
						break;
				}
			});
		}
		// init Function end.
	}
	
	, getBoardList : function(pWebpartID) { 	// 게시판 조회.
		let pMenuID = Common.getBaseConfig("BoardMain");
		let arrFolderID = {};
		
		arrFolderID = ctnBoard.confVal.split(';');
		arrFolderID.forEach(function(el) {
			if (ctnBoard.wpIdNum === el?.split(":")[0]) {
				ctnBoard.tmpFolderID = el.split(":")[1];
			}
		});
		
		let pBoardType = "Normal";
		let pBizSection = "Board";
		let pCommunityID = "";
		let pPageSize = ctnBoard.pageSize;
		let pPageOffset = "0";
		let pPageNo = "1";
	
		let objParam = {"folderID" : ctnBoard.tmpFolderID, "menuID" : pMenuID, "boardType" : pBoardType, "bizSection" : pBizSection
					, "communityID" : pCommunityID, "pageSize": pPageSize, "pageOffset" : pPageOffset, "pageNo" : pPageNo
					, "startDate" : "", "endDate" : ""};
	
		$.ajax({
			type : 'POST'
			, url : "/groupware/board/selectMessageGridList.do"
			, data : objParam
			, success : function(result) {
				ctnBoard.renderData(pWebpartID, result);
			}
			, error : function(response, status, error) {
				CFN_ErrorAjax("/groupware/board/selectMessageGridList.do", response, status, error);
			}
		});
	}
	
	, renderData : function(pWebpartID, result) { 	// rendering for getData.
		let $ulTab = $(".grid_item[data-id="+pWebpartID+"]").find("div .widget_content");
		
		if (result.status === "SUCCESS" && result.list != undefined) {
			if (result.list.length === 0) { 	// case 0.
				$ulTab.hide();
				$ulTab.siblings(".widget_empty").attr("hidden", false);
			} else {
				$ulTab.show();
				$ulTab.siblings(".widget_empty").attr("hidden", true);
				
				let boardList = result.list;
				let $tmpHtml = $("<ul>",{"class":"content_list"});
				
				boardList.forEach(function(el) {
					if (ctnBoard.isMarkRecentlyDay(el.CreateDate)) { 	// 최근게시글 판별.
						$tmpHtml.append($("<li>")
							.append($("<a>", {"class": "post_item", "href": "#"}).on("click", function() {
								ctnBoard.goViewPopup('', el.MenuID, el.Version, el.FolderID, el.MessageID);
							})
								.append($("<i>", {"class": "new_badge", "text": "N"}))
								.append($("<strong>", {"class": "item_title", "text": el.Subject}))
								.append($("<time>", {"class": "item_date", "text": el.RegistDate.split(" ")[0]}))
							)
						);
					} else {
						$tmpHtml.append($("<li>")
							.append($("<a>", {"class": "post_item", "href": "#"})
								.on("click", function() {
									ctnBoard.goViewPopup('', el.MenuID, el.Version, el.FolderID, el.MessageID);
								})
								.append($("<strong>", {"class": "item_title", "text": el.Subject}))
								.append($("<time>", {"class": "item_date", "text": el.RegistDate.split(" ")[0]}))
							)
						);
					}
				});
				
				$ulTab.append($tmpHtml);
				return;	
			}
		}
		$ulTab.hide();
		$ulTab.siblings(".widget_empty").attr("hidden", false);
	}
	
	, isMarkRecentlyDay: function(pCreateDate) { 	// case : within 7 days.
		var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
		var registDate = new Date(CFN_TransLocalTime(pCreateDate));
		if (today < registDate.setDate(registDate.getDate()+ 7)) {
			return true;
		} else {
			return false;
		}
	}

	, goViewPopup: function(pBtnIdx, pMenuID, pVersion, pFolderID, pMessageID) { 	// 게시물 상세보기 팝업.
		let pBizSection = 'Board';
		if (coviUtil.isMobile()) {	// mobile인 경우
			if (mobile_board_checkReadAuth(pBizSection, pFolderID, pMessageID, pVersion)){	//읽기 권한 체크
				var url = "/groupware/mobile/" + pBizSection.toLowerCase() + "/view.do?folderid=" + pFolderID + "&version=" + pVersion + "&messageid=" + pMessageID + "&boardtype=Normal&menucode=Board";
				mobile_comm_go(url, "Y");
			} else { 	//권한 없음
				alert(mobile_comm_getDicInfo("msg_UNotReadAuth"));
			}
		} else {
			var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", pBizSection, pMenuID, pVersion, pFolderID, pMessageID);
			Common.open("", "boardViewPop", Common.getDic("lbl_DetailView"), url, "1080px", "600px", "iframe", true, null, null, true);
		}
	}
	
	, openPopup:function(pWebpartID, pCurrentVal) { 	// 설정 팝업
		let strUrl = "/groupware/portal/setWebpartPopup.do";
		strUrl += "?webpartID="+pWebpartID;
		strUrl += "&popupType=0";
		strUrl += "&currentValue="+pCurrentVal;
		let strTitle = Common.getDic("lbl_Boards")+" "+Common.getDic("lbl_change"); 	// 게시판 변경
		Common.open("", "setWebpartPopup", strTitle, strUrl, "431px", "175px", "iframe", true, null, null, true); 	//open: function (button_id, object_id, title, source, w, h, pMode, pIsModal, posX, posY, pReSize, objectType)
		
		return new Promise(resolve => {
			const listener = (e) => {
				if (e.data.functionName === pWebpartID) {
					var params = e.data.params;
					if (params.status=="SUCCESS") {
						ctnBoard.changeFolderID(pWebpartID, params.saveValue);
					}				
					window.removeEventListener('message', listener)
				}
			}
			window.addEventListener('message', listener)
		});
	}
	
	, changeFolderID : function(pWebpartID, pValue) {
		
		// 변경값.
		let changeSetVal = ctnBoard.wpIdNum+":"+pValue+";";
		// 전달값.
		let sendVal = "";
		
		if (ctnBoard.confVal) { 	// 비어있는 값이 아닐경우.
			
			// 웹파트ID의 중복값 저장을 피하기 위해 map형태로 정리.
			const tempConfMap = new Map();
			sendVal = ctnBoard.confVal.split(';');
			sendVal.forEach(function(pair){
				const [key, value] = pair.split(':');
				tempConfMap.set(key, value);
			});

			tempConfMap.set(ctnBoard.wpIdNum, pValue);
			// map to string
			sendVal = JSON.stringify(Object.fromEntries(tempConfMap));
			// 특수기호 삭제.
			sendVal = sendVal.replace(/\{|\}|"|\\/g, '');
			// , to ; 변환.
			sendVal = sendVal.replace(/,/g, ';');
			// 마지막 ;
			sendVal = sendVal+";";
			
		} else { 	// case ""
			sendVal = changeSetVal;
		}
		
		ctnBoard.tmpFolderID = pValue;
		
		$.ajax({
			type : "POST"
			, url: "/groupware/portal/changeFolderidOption.do"
			, data : {"setKeyID" : ctnBoard.settingKeyID, "changeConfVal" : sendVal, "folderID": pValue, "pageSize": ctnBoard.pageSize, "pageOffset": "0"}
			, async : false
			, success : function(result) {
				if (result.status === "SUCCESS") {
					if (result?.message) { 	// error occurred.
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
