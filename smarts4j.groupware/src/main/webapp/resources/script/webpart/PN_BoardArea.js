/**
 * pnBoardArea - 게시판 영역
 */
var pnBoardArea = {
	webpartType: "",
	recentlyDay: 3,
	init: function(data,ext){
		var tickerFolderID = ext.TickerFolderID;
		var folderInfo = ext.FolderInfo;
		
		pnBoardArea.getCovid19Api();
		pnBoardArea.getWeatherApi();
		pnBoardArea.getMessageList(tickerFolderID, true);
		pnBoardArea.setBoardTab(folderInfo);
	},
	getCovid19Api: function(){
		var nowDate = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
		var sDate = schedule_SetDateFormat(schedule_AddDays(nowDate, -2), "");
		var yDate = schedule_SetDateFormat(schedule_AddDays(nowDate, -1), "");
		var eDate = schedule_SetDateFormat(nowDate, "");
		
		$.ajax({
			type: "POST",
			url: "/covicore/control/getCovid19Api.do",
			data: {
				  "sDate": sDate
				, "eDate": eDate
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var covidInfo = data.result.sort(function(a, b){
					    if(a.stateDt > b.stateDt){
					        return -1;
					    }else if(a.stateDt < b.stateDt){
					        return 1;
					    }else{
					        return a.updateDt == "" ? 1 : -1;
					    }
					}).filter(function(val, idx, arr){
						return !arr[idx-1] || (arr[idx-1] && ((val.stateDt == arr[idx-1].stateDt && val.updateDt != "") || val.stateDt != arr[idx-1].stateDt));
					}, []);
					var sDateCnt = 0;
					var eDateCnt = 0;
					
					$.each(covidInfo, function(idx, item){
						if(covidInfo.length == 2){
							if(Number(sDate) == item.stateDt){
								sDateCnt = item.decideCnt;
							}else if(Number(yDate) == item.stateDt){
								eDateCnt = item.decideCnt;
							}
						}else{
							if(Number(yDate) == item.stateDt){
								sDateCnt = item.decideCnt;
							}else if(Number(eDate) == item.stateDt){
								eDateCnt = item.decideCnt;
							}
						}
					});
					
					var subCnt = eDateCnt - sDateCnt;
					
					if(subCnt > 0){
						$(".PN_People .PN_Variation").addClass("up");
					}else if(subCnt < 0){
						$(".PN_People .PN_Variation").addClass("down");
					}
					
					$(".PN_People .PN_Variation").text(subCnt.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
					$(".PN_People .PN_Num").text(eDateCnt.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
					
					pnBoardArea.setCountUp();
				}
			}
		});
	},
	setCountUp: function(){
		$(".PN_People .PN_Num").counterUp();
		$(".PN_People .PN_Variation").counterUp();
	},
	getWeatherApi: function(){
		$.ajax({
			type: "POST",
			url: "/covicore/control/getWeatherApi.do",
			data: "",
			success: function(data){
				if(data.status == "SUCCESS"){
					var weatherInfo = data.result;
					var wData = weatherInfo.weather[0];
					var weatherClass = "ic_weather";
					
					switch(wData.main){
						case "Clear":
							weatherClass += "01";
							break;
						case "Clouds":
							weatherClass += "02";
							break;
						case "Drizzle":
						case "Rain":
							weatherClass += "03";
							break;
						case "Snow":
							weatherClass += "04";
							break;
						case "Mist":
						case "Smoke":
						case "Haze":
						case "Dust":
						case "Fog":
						case "Sand":
						case "Dust":
						case "Ash":
						case "Squall":
							weatherClass += "05";
							break;
						case "Thunderstorm":
							weatherClass += "06";
							break;
						case "Tornado":
							weatherClass += "07";
							break;
					}
					
					$(".PN_Temp .ic_weather").addClass(weatherClass);
					$("#tempMetric").text(Math.floor(weatherInfo.main.temp) + "℃");
				}
			}
		});
	},
	setBoardTab: function(folderInfo){
		var lang = sessionObj["lang"];
		
		$.each(folderInfo, function(idx, item){
			var folderName = CFN_GetDicInfo(item.DisplayName, lang);
			
			$(".PN_boardTitle li[data-tab=PN_tab2_" + (idx + 1) + "] a").text(folderName + " ");
			
			if(item.hasOwnProperty("FolderID")){
				pnBoardArea.getMessageList(item.FolderID, false, (idx + 1));
			}else{
				pnBoardArea.getBoardMessageList(item.Type, item.MenuID, (idx + 1));
			}
		});
		
		$(".PN_boardTitle li").click(function(){
			var tab_id = $(this).attr("data-tab");
			
			$(".PN_boardTitle li").removeClass("active");
			$(".PN_tabCont").removeClass("active");
			
			$(this).addClass("active");
			$("#"+tab_id).addClass("active");
		});
	},
	getMessageList: function(pFolderID, pIsTicker, pFolderIdx){
		board.getBoardConfig(pFolderID);
		
		$.ajax({
			type: "POST",
			url: "/groupware/board/selectMessageGridList.do",
			data: {
				  "boardType": "Normal"
				, "bizSection": "Board"
				, "folderID": pFolderID
				, "folderType": g_boardConfig.FolderType
				, "viewType": "Album"
				, "startDate": ""
				, "endDate": ""
				, "pageSize": 6
				, "pageNo": 1
			},
			success: function(data){
				var listData = data.list;
				var liHtml = "";
				var tickerHtml = "";
				var recentFlag = false;
				
				if(listData != null && listData.length > 0){
					$.each(listData, function(idx, item){
						if(pIsTicker){
							var titleAnchor = $("<a href='#' onclick='pnBoardArea.openBoardPopup(" + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");'/>").text(item.Subject);
							var liWrap = $("<li></li>").append($("<div></div>").addClass("movieThumb").append(titleAnchor));
							
							tickerHtml += $(liWrap)[0].outerHTML;
						}else{
							var titleAnchor = $("<a href='#' onclick='pnBoardArea.openBoardPopup(" + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");'/>")
												.append($("<span></span>").addClass("boTitle").text(item.Subject))
												.append($("<span></span>").addClass("boName").text(item.CreatorName))
												.append($("<span></span>").addClass("boDate").text(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd HH:mm")));
							var liWrap = $("<li></li>").append(titleAnchor);
							var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
							var compareDate = schedule_AddDays(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd"), pnBoardArea.recentlyDay);
							
							if(today.getTime() < compareDate.getTime()){
								var recentlyBadge = $("<span></span>").addClass("countStyle new").text("N");
								
								liWrap.find(".boTitle").text(" " + item.Subject).prepend(recentlyBadge);
								recentFlag = true;
							}
							
							if(idx == 0){
								var previewURL = Common.getThumbSrc("Board", item.FileID);
								
								liWrap.addClass("first");
								liWrap.find("a")
									.prepend($("<span class='boImg'></span>")
										.append($("<img onerror='setNoImage(this, \"n2\");'>")
											.attr("src", previewURL)));
								
								if(previewURL.indexOf("no_image.jpg") > -1) setNoImage(liWrap.find(".boImg img"), "n2");
							}
							
							if(item.IsRead == "N") liWrap.find(".boTitle").addClass("bold");
							
							liHtml += $(liWrap)[0].outerHTML;
						}
					});
					
					if(!pIsTicker) $("#PN_tab2_" + pFolderIdx + " .PN_boardList").empty().append(liHtml);
					else $(".rollList ul").append(tickerHtml);
				}else{
					if(!pIsTicker){
						var wUrl = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&menuID=" + g_boardConfig.MenuID + "&folderID=" + pFolderID;
						
						$("#PN_tab2_" + pFolderIdx + " .PN_boardList").hide();
						$("#PN_tab2_" + pFolderIdx + " .PN_nolist").show();
						$("#PN_tab2_" + pFolderIdx + " .PN_nolist .PN_btnType01").attr("href", wUrl);
					}
				}
				
				if(recentFlag){
					var recentlyBadge = $("<span></span>").addClass("countStyle new").text("N");
					$(".PN_boardTitle li[data-tab=PN_tab2_" + pFolderIdx + "] a").append(recentlyBadge);
				}
				
				if(pIsTicker) pnBoardArea.setRollingList();
				else{
					var linkUrl = "/groupware/layout/board_BoardList.do?CLSYS=Board&CLMD=user&boardType=Normal&CLBIZ=Board&menuID=" + g_boardConfig.MenuID + "&folderID=" + pFolderID;
					
					$("#PN_tab2_" + pFolderIdx + " .PN_TitleBox .PN_More").attr("href", linkUrl);
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/selectMessageGridList.do", response, status, error);
	    	}
		});
	},
	getBoardMessageList: function(pBizSection, pMenuID, pFolderIdx){
		$.ajax({
			type: "POST",
			url: "/groupware/pnPortal/selectBoardMessageList.do",
			data: {
				"bizSection": pBizSection,
				"menuID": pMenuID
			},
			success: function(data){
				var listData = data.list;
				//var backStroage = Common.getBaseConfig("BackStorage");
				var liHtml = "";
				
				if(listData && listData.length > 0){
					var recentFlag = false;
					var linkUrl = "";
					
					if(pBizSection == "Board"){
						linkUrl = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuID=" + pMenuID;
					}else{
						linkUrl = "/groupware/layout/board_BoardList.do?CLSYS=Doc&CLMD=user&CLBIZ=Doc&boardType=DocTotal&menuID=" + pMenuID;
					}
					
					$("#PN_tab2_" + pFolderIdx + " .PN_TitleBox .PN_More").attr("href", linkUrl);
					
					$.each(listData, function(idx, item){
						var titleAnchor = $("<a href='#' onclick='pnBoardArea.openBoardPopup(" + item.MenuID + "," + item.Version + "," + item.FolderID + "," + item.MessageID + ");'/>")
												.append($("<span></span>").addClass("boTitle").text(item.Subject))
												.append($("<span></span>").addClass("boName").text(item.CreatorName))
												.append($("<span></span>").addClass("boDate").text(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd HH:mm")));
						var liWrap = $("<li></li>").append(titleAnchor);
						var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
						var compareDate = schedule_AddDays(CFN_TransLocalTime(item.CreateDate, "yyyy.MM.dd"), pnBoardArea.recentlyDay);
						
						if(today.getTime() < compareDate.getTime()){
							var recentlyBadge = $("<span></span>").addClass("countStyle new").text("N");
							
							liWrap.find(".boTitle").text(" " + item.Subject).prepend(recentlyBadge);
							recentFlag = true;
						}
						
						if(idx == 0){
							var previewURL = Common.getThumbSrc(pBizSection, item.FileID);
							
							liWrap.addClass("first");
							liWrap.find("a")
								.prepend($("<span class='boImg'></span>")
									.append($("<img onerror='setNoImage(this, \"n2\");'>")
										.attr("src", previewURL)));
							
							if(previewURL.indexOf("no_image.jpg") > -1) setNoImage(liWrap.find(".boImg img"), "n2");
						}
						
						if(item.IsRead == "N") liWrap.find(".boTitle").addClass("bold");
						
						liHtml += $(liWrap)[0].outerHTML;
					});
					
					if(recentFlag){
						var recentlyBadge = $("<span></span>").addClass("countStyle new").text("N");
						$(".PN_boardTitle li[data-tab=PN_tab2_" + pFolderIdx + "] a").append(recentlyBadge);
					}
					
					$("#PN_tab2_" + pFolderIdx + " .PN_boardList").empty().append(liHtml);
				}else{
					var wUrl = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&menuID=" + pMenuID + "&folderID=" + pFolderID;
					
					$("#PN_tab2_" + pFolderIdx + " .PN_boardList").hide();
					$("#PN_tab2_" + pFolderIdx + " .PN_nolist").show();
					$("#PN_tab2_" + pFolderIdx + " .PN_nolist .PN_btnType01").attr("href", wUrl);
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/pnPortal/selectBoardtMessageList.do", response, status, error);
	    	}
		});
	},
	openBoardPopup: function(pMenuID, pVersion, pFolderID, pMessageID){
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", "Board", pMenuID, pVersion, pFolderID, pMessageID);
		Common.open("", "boardViewPop", "<spring:message code='Cache.lbl_DetailView'/>", url, "1080px", "600px", "iframe", true, null, null, true); // 상세보기
	},
	setRollingList: function(){
		var startNum = Number(0);	//첫번째 이미지 초기화
		$(".rollList").show();	//일시적으로 깨짐 방지하기 위해 숨겼다 보여짐.
		var visibleCnt = $(".movieThumb").length;
		var visibleNum = 1;

		if (visibleCnt > visibleNum) {	//visibleNum보다 많을경우 이미지 롤링
			$(".rollList").jCarouselLite({
				auto: 1000,
				speed: 1000,
				visible: visibleNum,
				start: startNum,
				vertical: true
			});
		}
	}
}
