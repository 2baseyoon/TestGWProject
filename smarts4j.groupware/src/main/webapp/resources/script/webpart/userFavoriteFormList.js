
var favoriteList = {
		webpartType: '', 
		extJson : {},
		init:function (data,ext){
			var extJson = ext;
			this.getFavoriList(extJson.id);
		},
		getFavoriList: function (id){
			$.ajax({
				type:"post",
				url:"/approval/user/getFavoriteUsedFormListData.do",
				data:{
					"userCode":Common.getSession("USERID")
				},
				success:function(data){
					$.each(data.list, function(index, value) {
						if(index>=5){
							return false;
						}
						$("#"+id+" > tbody").append('<tr><td height="25">'+value.LabelText+'</td></tr>');
					});
				},
				error:function(response, status, error){
				     CFN_ErrorAjax("/approval/user/getFavoriteUsedFormListData.do", response, status, error);
				}
			});
		}
};

