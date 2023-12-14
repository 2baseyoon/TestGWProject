

/**
 * 모바일 포탈 탭게시 웹파트
 */
var MWP_TabBoard = {
		webpartType: '', 
		init: function (data,ext){
					
			var tabList = ext.tabList;
			$.each(tabList, function(i, item) {	//탭형태 웹파트 검색: 최근게시, 최근문서탭 추가
			
				//메뉴ID 체크-@@ 있으면 기초설정값(BC)에서 조회//@@BC|MWP_QuickLink_MenuID
				if(item.MenuID.indexOf("@@") > -1) {
					try {
						item.MenuID = item.MenuID.replace('@@', '');
						if(item.MenuID.split('|')[0] == "BC") {
							item.MenuID = mobile_comm_getBaseConfig(item.MenuID.split('|')[1]);	
						}
					} catch(e) {
						mobile_comm_log(e);
					}
				}
				
				var tabName = mobile_comm_getDicInfo(item.DisplayName);
				$("#ulWebpartBoardListTab").append('<li mnid=\'' + item.MenuID + '\'><a class="tabTitle" onclick="MWP_TabBoard.SelectTab(this,\''+ item.Type +'\',\''+ item.MenuID +'\');">' + tabName + '</a></li>');
			});
			//추가된 탭 선택하여 게시글 검색
			$("#divWebpartBoardList li:nth(0) a").click();
		},
		 
		//최근게시, 문서 탭 변경
		SelectTab: function(pObj, pBizSection, pMenuID){
			$(pObj).parent().parent().find('.on').removeClass('on');
			$(pObj).parent().addClass('on');
			if(pBizSection == "Board") {
				MWP_TabBoard.getLatestMessageList(pBizSection, pMenuID);	
			} else {
				MWP_TabBoard.getNoticeMessageList();
			}
		},

		//공지 리스트 조회
		getNoticeMessageList: function(){
			 $.ajax({
				type:"POST",
				url:"/groupware/board/selectNoticeMessageList.do",
				success:function(data){
					var listData = data.list;
					var sHtml = "";
					
					$("#tbBoardList").html("");
					
					if(data.status == "SUCCESS") {
						if(listData.length > 0){
							$.each( listData, function(index, value) {
								sHtml += '<tr>'
								sHtml += '    <td class="title">';
								sHtml += '    	<a class="new" onclick="javascript:MWP_TabBoard.goView(\'Board\', '+value.MenuID+','+value.Version+','+value.FolderID+','+value.MessageID+')" >';
								sHtml += '		'+ value.Subject + '</a></td>'
								sHtml += '    <td class="date">' + CFN_TransLocalTime(value.CreateDate, "yyyy.MM.dd") + '</td>'
								sHtml += '  </tr>'
							});
						} else {
							sHtml = "<tr><td><p>" + mobile_comm_getDic("msg_NoDataList") + "</p></td></tr>"; //조회할 목록이 없습니다.
						}
					}
					
					$("#tbBoardList").html(sHtml);
				}
			});
		},
		
		getLatestMessageList: function(pBizSection, pMenuID){
			var params = {
				bizSection: pBizSection,
				menuID: pMenuID
			}
			$.ajax({
				type:"POST",
				url:"/groupware/board/selectLatestMessageList.do",
				data: params,
				success:function(data){
					var listData = data.list;
					var sHtml = "";
					
					$("#tbBoardList").html("");
					
					if(data.status == "SUCCESS") {
						if(listData.length > 0){
							$.each( listData, function(index, value) {
								sHtml += '<tr>'
								sHtml += '    <td class="title">';
								sHtml += '    	<a class="new" onclick="javascript:MWP_TabBoard.goView(\''+pBizSection+'\', '+value.MenuID+','+value.Version+','+value.FolderID+','+value.MessageID+')" >';
								sHtml += '		'+ value.Subject + '</a></td>'
								//<a href="#" class="new">' + value.Subject + '</a></td>'
								sHtml += '    <td class="date">' + CFN_TransLocalTime(value.CreateDate, "yyyy.MM.dd") + '</td>'
								sHtml += '  </tr>'
							});
						} else {
							sHtml = "<tr><td><p>" + mobile_comm_getDic("msg_NoDataList") + "</p></td></tr>"; //조회할 목록이 없습니다.
						}
					}
					
					$("#tbBoardList").html(sHtml);
				}
			});
		},
		
		//조회로 이동
		goView: function(pBizSection, pMenuID, pVersion, pFolderID, pMessageID){
			if (mobile_board_checkReadAuth(pBizSection, pFolderID, pMessageID, pVersion)){	//읽기 권한 체크
				var url = "/groupware/mobile/" + pBizSection.toLowerCase() + "/view.do?folderid=" + pFolderID + "&version=" + pVersion + "&messageid=" + pMessageID + "&boardtype=Normal&menucode=Board";
				mobile_comm_go(url, "Y");
			} else {//권한 없음
				alert(mobile_comm_getDicInfo("msg_UNotReadAuth"));
			}
		}
}

