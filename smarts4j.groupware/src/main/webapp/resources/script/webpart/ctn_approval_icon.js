/**
 * ctn_approval_icon - 37.결재함(아이콘)
 * @since 2023.6
 */
var ctnApprovalIcon = {
	init: function (data, ext, caller, webPartID){
		let $divWebpart = $("#"+webPartID);
		
		// 서버랜더링 (getApprovalListCount)
		if(data && data[0] && data[0][0] && data[0][0].status && data[0][0].status == "SUCCESS"){
			var listData = data[0][0].list;
			
			$.each(listData, function(idx,item){
				if(item.type && item.cnt != undefined){
					$divWebpart.find(".a-icon").eq(idx).find("em.ui_badge").text(item.cnt);
				}
			});
		}
		
		$divWebpart.find(".a-icon").each(function(idx,item){
			$(item).attr("href", ext.targetUrl[idx]);
		});
	}
}