/**
 * 
 */

var wpButtonMenu = {
	config: {
		rButtonName: 'VISION',
		rButtonLink: '/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuCode=BoardMain',
		lButtonName: '경영이념',
		lButtonLink: '/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuCode=BoardMain'
	},
	init: function(data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		this.render();
	},
	render: function(){
		$("#right_btn_menu_name").text(Common.getDic(wpButtonMenu.config.rButtonName));
		$("#right_btn_menu_link").attr("href", wpButtonMenu.config.rButtonLink);
		$("#left_btn_menu_name").text(Common.getDic(wpButtonMenu.config.lButtonName));
		$("#left_btn_menu_link").attr("href", wpButtonMenu.config.lButtonLink);
	}
}