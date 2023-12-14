/**
 * pnShareTask - [포탈개선] My Place - 태그 구름
 */
var pnTagCloud = {
	config:{
		searchType:"",
		searchWord:"",
		sortBy:"SearchDate DESC",
		pageNo: "1",
		tagCnt: "30"
	},
	init: function (data, ext){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		pnTagCloud.setEvent();
		pnTagCloud.getSearchWord();
	},
	getSearchWord: function(){
		$.ajax({
			type:"POST",
			data:{
				"domainID":Common.getSession("DN_ID"),
				"searchType":pnTagCloud.config.searchType,
				"searchWord":pnTagCloud.config.searchWord,
				"sortBy":pnTagCloud.config.sortBy,
				"pageNo": pnTagCloud.config.pageNo,
				"pageSize": pnTagCloud.config.tagCnt
			},
			url:"/covicore/searchWord/getList.do",
			success:function(data) {
				if(data.status == "SUCCESS"){
					var listData = data.list;
					if(listData.length > 0){
						$.each(listData, function(idx, item){
							var totalPoint = parseInt(item.RecentlyPoint * 5) + parseInt(item.SearchCnt / 100);
							var url = String.format('/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&searchText={0}&searchType={1}', encodeURIComponent(item.SearchWord), "Total");
							$(".PN_tagCloud ul").append('<li><a href="' + url + '" class="tag_item ' + pnTagCloud.tagCssType(totalPoint) + '"><span>' + item.SearchWord + '</span></a></li>')
						});
					} else{
						$(".PN_tagCloud ul").hide();
						$(".PN_tagCloud").closest(".PN_nolist").show();
					}
				}
			},
			error:function(response, status, error){
	    	     CFN_ErrorAjax("/covicore/searchWord/getList.do", response, status, error);
	    	}
		});
	},
	tagCssType: function(pTotalPoint){
        if (pTotalPoint > 70)
            sRtnStr = "tag01";
        else if (pTotalPoint > 50)
            sRtnStr = "tag02";
        else if (pTotalPoint > 40)
            sRtnStr = "tag03";
        else if (pTotalPoint > 30)
            sRtnStr = "tag04";
        else if (pTotalPoint > 20)
            sRtnStr = "tag05";
        else if (pTotalPoint > 10)
            sRtnStr = "tag06";
        else
            sRtnStr = "tag07";

        return sRtnStr;
	},
	setEvent: function(){
		$(".PN_tagCloud").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
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
		
		$(".PN_tagCloud").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on");
		});
		coviCtrl.bindmScrollV($('.PN_tagCloud'));
	}
}