/**
 * systemLink - 시스템 바로가기 
 */
var systemLink ={
	config: {},
	init: function (data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		
		systemLink.getSystemList();
	},
	getSystemList: function(){
		var systemLinkList = Common.getBaseCode('SystemLinkList');
		var ulWrap = "";
		var liLink = "";
		if(systemLinkList != undefined){
			
			$.each(systemLinkList.CacheData, function(i, item){
				if(item.CodeName != null && item.CodeName != ''){
					ulWrap += "<li>";
					if(item.Reserved1 != null && item.Reserved1 != ''){
						liLink = item.Reserved1;
					}else{
						liLink = "javascript:void(0);";
					}
					ulWrap += '<a href="'+liLink+'" class="title" target="_blank">';
					ulWrap += CFN_GetDicInfo(item.MultiCodeName);
					ulWrap += "</a>";
					ulWrap += '<a href="'+liLink+'" class="btnSysScMore" target="_blank"></a>';	//새창으로 띄우기
					ulWrap += "</li>";
				}
			});
			
		}
		
		$('#systemLink_List').html(ulWrap);
		
	}
}


