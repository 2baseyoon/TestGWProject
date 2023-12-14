/**
 * 바로가기 링크
 */ 
var MWP_QuickLink = {
	init: function(data,ext) {
		try {
			var linkList = ext.linkList;
			if(linkList != undefined) {
				$.each(linkList, function(i, item) {
					
					//URL 체크-@@ 있으면 기초설정값(BC)에서 조회//@@BC|MWP_QuickLink_3_MenuID&@@BC|MWP_QuickLink_3_FolderID
					if(item.URL.indexOf("@@") > -1) {
						try {
							var arrURL = item.URL.split('@@');
							for(var i = 0; i < arrURL.length; i++) {
								if(arrURL[i] != '' && arrURL[i].indexOf('BC|') > -1) {
									var key = arrURL[i].split('BC|')[1];
									key = key.split('&')[0];
									
									item.URL = item.URL.replace('@@BC|' + key, mobile_comm_getBaseConfig(key));
								}
							}
						} catch(e) {
							mobile_comm_log(e);
						}
					}
					
					if(item.IsPop == "Y") {
						$("#ulWebpartLink").append('<li><a href="javascript:mobile_comm_go(\''+ item.URL +'\', \'Y\')">'+ mobile_comm_getDicInfo(item.DisplayName) +'</a></li>');
					} else {
						$("#ulWebpartLink").append('<li><a href="javascript:mobile_comm_go(\''+ item.URL +'\', \'N\')">'+ mobile_comm_getDicInfo(item.DisplayName) +'</a></li>');
					}
				});
			}
		}
		catch(e){mobile_comm_log(e)} // 메인배너 호출시 오류발생으로 임의 처리
	}
}
