/**
 * bindHtmlWebpart - 게시판 웹파트 기본형 
 */
var bindHtmlWebpart ={
	webpartType: '',
	init: function (data,ext){
		$("#BindHtmlWebpart_frame").html(ext.html);
	}
}
