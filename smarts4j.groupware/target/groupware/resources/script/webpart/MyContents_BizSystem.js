/**
 * myContents - 마이 컨텐츠 - 업무시스템
 */
var myContents_BizSystem ={
	init: function (data,ext){
		myContents_BizSystem.getSystemLinkList();	// 일정 조회
	},
	// 일정 조회
	getSystemLinkList : function(){
		var siteLinkList = Common.getBaseCode('SiteLinkList');
		var liLink = "";
		var ulWrap = "";
		var num = 0;
		var number = 0;
		var num_str = "";
		if(siteLinkList != undefined){
			
			$.each(siteLinkList.CacheData, function(i, item){
				    num++;
					if(num > 9){
						number++;
						num = 0;
						num_str = number+""+num;
					}else{
						num_str = number+""+num;
					}
					ulWrap += "<li class='businessSystemMenu"+num_str+"'>";
					if(item.Reserved1 != null && item.Reserved1 != ''){
						liLink = item.Reserved1;
					}else{
						liLink = "#";
					}
					ulWrap += '<a href="'+liLink+'">';
					ulWrap += CFN_GetDicInfo(item.MultiCodeName);
					ulWrap += "</a>";
					ulWrap += "</li>";
			});
			
		}
		
		$("#myContents_BizSystem_LinkList").html(ulWrap);
	}
}


