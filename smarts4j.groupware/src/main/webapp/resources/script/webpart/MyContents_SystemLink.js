/**
 * myContents - 마이 컨텐츠 - 시스템 바로가기 
 */
var myContents_SystemLink ={
	init: function (data,ext){
		myContents_SystemLink.getSystemList();
	},
	getSystemList: function(){
		var systemLinkList = Common.getBaseCode('SystemLinkList');
		var ulWrap = "";
		var liLink = "";

		if(systemLinkList != undefined){
			ulWrap = '<ul>';
			
			$.each(systemLinkList.CacheData, function(i, item){
				if(item.CodeName != null && item.CodeName != ''){
					ulWrap += "<li>";
					if(item.Reserved1 != null && item.Reserved1 != ''){
						liLink = item.Reserved1;
					}else{
						liLink = "#";
					}
					ulWrap += '<a href="'+liLink+'" class="title" target="_blank">';
					ulWrap += CFN_GetDicInfo(item.MultiCodeName);
					ulWrap += "</a>";
					ulWrap += '<a href="'+liLink+'" class="btnSysScMore" target="_blank">';	//새창으로 띄우기
					ulWrap += "</a>";
					ulWrap += "</li>";
				}
			});
			
			ulWrap += '</ul>';
		}

		$('#myContents_SystemLink_List > div').html(ulWrap);
		
		coviCtrl.bindmScrollV($('#myContents_SystemLink_List').find('.mScrollV'));
		
	}
}


