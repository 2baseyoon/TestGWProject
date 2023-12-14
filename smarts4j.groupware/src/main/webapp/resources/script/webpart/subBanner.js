/**
 * 
 */

var wpSubBanner = {
	config: {
		path: '/HtmlSite/smarts4j_n/customizing/Ptype03/images/project/img_w_banner01.jpg',
		link: '/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuCode=BoardMain'
	},
	init: function(data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		this.render();
	},
	render: function(){
		$("#sub_banner_path").attr("src", wpSubBanner.config.path);
		$("#sub_banner_link").attr("href", wpSubBanner.config.link);
	}
}