/**
 * systemLinkBoardList - 업무시스템 바로가기
 */
var systemLinkBoardList = {
	init: function (data,ext){
		systemLinkBoardList.getSystemLinkBoardList();
	},
	getSystemLinkBoardList: function(){
		//var backStorage = Common.getBaseConfig("BackStorage");
		
		$.ajax({
			type: "POST",
			data: "",
			url: "/groupware/board/selectSystemLinkBoardList.do",
			success: function(data){
				var listData = data.list;
				var ulWrap = "";
				var openType = "";
				
				if(listData != undefined && listData != ""){
					$.each(listData, function(idx, item){
						var fileInfo = "";
						var filePath = "";
						
						if(item.fileList != undefined && item.fileList != ""){
							/* 
							fileInfo = item.fileList[0];
							backStorage = backStorage.replace("{0}", fileInfo.CompanyCode);
							filePath = backStorage + fileInfo.ServiceType + "/" + fileInfo.FilePath + fileInfo.SavedName;
							filePath ='/covicore/common/photo/photo.do?img=' + encodeURIComponent(filePath) ;
							fileList 넘어오지 않음 필요하다면 아래와 같이 처리 필요
							*/ 
							/* 아래
							if(item.SavedName) filePath = item.FullPath;
							*/
//							filePath ='/covicore/common/view/Board/'+fileInfo.FileID+'.do';
						}else{
							filePath = "/HtmlSite/smarts4j_n/covicore/resources/images/common/systemlink_sample.jpg";
						}
						
						ulWrap += '<li class="businessSystemMenu01">';
						
						if(item.OpenType == "1"){
							openType = "_self";
						}else{
							openType = "_blank";
						}
						
						ulWrap += '<a href="' + item.LinkURL + '" target="' + openType + '">';
						ulWrap += '<div class="systemlink_img_wrap">';
						ulWrap += '<img src="' + filePath + '" border="0" width="48px" height="33px" onerror="this.src=\'/covicore/resources/images/no_image.jpg\'">';
						ulWrap += '</div>';
						ulWrap += item.Subject;
						ulWrap += "</a>";
						ulWrap += "</li>";
					});
					
					$("#systemLinkBoard_List").html(ulWrap);
				}
			},
			error: function(response, status, error){
				 CFN_ErrorAjax("/groupware/board/selectSystemLinkBoardList.do", response, status, error);
			}
		});
	}
}
