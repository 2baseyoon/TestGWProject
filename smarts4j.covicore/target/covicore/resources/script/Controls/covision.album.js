/* 프로그램 저작권 정보
//이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
//(주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
//(주)코비젼의 지적재산권 침해에 해당됩니다.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
//
//You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
//as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
//owns the intellectual property rights in and to this program.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

///<creator>기술연구소</creator> 
///<createDate>2017.08.17</createDate> 
///<lastModifyDate></lastModifyDate> 
///<version>0.8.0</version>
///<summary> 
///앨범 리스트 조회 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/
if (!window.coviAlbum) {
    window.coviAlbum = {};
}

(function($) {
	var coviAlbum= {
		target: '',
		url : '',
		page : { 
			pageNo: 1,
			pageOffset: 0,
			pageCount: 1,
			pageSize: 10,
			listCount: 0,
			sortBy: "",
		}, 	//페이지 정보
		searchParam : {},
		boardConfig : {},
		renderAlbumList : function(data){
			var topRibbon = $("<span/>").addClass("albumTopRibbons");		//상단공지 항목
			var recentlyIcon = $("<span/>").addClass("cycleNew new small");	//최신글 아이콘
			var albumContent = $("#"+this.target);
			
        	albumContent.html("<div style='text-align: center; color: #9a9a9a; padding-bottom: 20px;'>"+ coviDic.dicMap["msg_NoDataList"]  +"</div>"); //조회할 목록이 없습니다.
        	var wrapAlbum = $("<ul class='clearFloat'/>");
        	if(data.list !== undefined){
				$.each(data.list, function(i, item){
					var viewAnchor = String.format("<a href='#' onclick='javascript:board.goView(\"{1}\", {2}, {3}, {4}, {5}, \"{6}\", \"{7}\", \"{8}\", \"{9}\", \"{10}\",\"{11}\", \"{12}\", {13}, {14}, \"\", \"{15}\", \"{16}\", \"{17}\");' >{0}</a>", 
    					item.Subject,
 						bizSection,
 						item.MenuID,
 						item.Version,
 						item.FolderID,
 						item.MessageID,
 						$("#startDate").val(),
 						$("#endDate").val(),
 						"RegistDate desc",
 						$("#searchText").val(),
 						$("#searchType").val(),
 						"Album",
 						boardType,
 						data.page.pageNo, 
 						data.page.pageSize,
 						item.RNUM,
 						item.MultiFolderType,
 						grCode
 					);
					
					//이미지가 없을 경우 no_image로 처리 
					//var previewURL = item.FileID==undefined?"/GWStorage/no_image.jpg":String.format("/covicore/common/preview/{0}/{1}.do", bizSection, item.FileID);
					var previewURL = Common.getThumbSrc(bizSection, item.FileID);
					
					var divFile = $('<span class="attFileListBox"/>');
					var ulFileList = $('<ul class="attFileListCont topOptionListCont"/>');
					var anchorAttFile = $("<a href='#' class='abFilebtn abAttFile' onclick='javascript:board.renderFileList(this,"+ item.FolderID +","+ item.MessageID +","+ item.Version +")'/>").append(item.FileCnt);
					var anchorClose = $('<a class="btnXClose btnTopOptionContClose" onclick="$(\'.topOptionListCont\').removeClass(\'active\');"></a>');
					var anchorDownloadAll = $('<a onclick="javascript:board.gridDownloadAll('+ item.FolderID +','+ item.MessageID +','+ item.Version +')"/>').text(Common.getDic("lbl_download_all"));
					ulFileList.append($('<li />').append(anchorDownloadAll, anchorClose));
					
					//HTML 구조ㅋ
					// <li> wrapAlbum
					//	└ <div> albumBox
					//		├ <div> titleImage
					//		│	└ <a> titleAnchor	: 앨범보기 썸네일 이미지 표시부분
					//		└ <div> albumBody
					//			├ <p> albumSubject	: 게시글 제목, 최근게시 아이콘 표시
					//			├ <p> albumInfo		: 조회수 | 등록일자
					//			├ <p> 작성자명	
					//			└ <div> albumData	: 좋아요, 댓글, 첨부 파일 개수 표시 

					var imgOption = (previewURL == "no_image.jpg" ? "style='cursor: default;'" : "onclick='goImageSlidePopup("+item.MessageID+", "+item.FolderID+")'");
					var titleAnchor = $("<a href='#' " + imgOption + "/>").append($("<img/>").attr("src", previewURL == "no_image.jpg" ? "/covicore/resources/images/no_image.jpg" : previewURL).attr("onerror", "this.onerror=null; this.src='/covicore/resources/images/no_image.jpg'"));
					
					if(item.IsTop == "Y") {
						titleAnchor.append($("<span/>").addClass("albumTopRibbons"));
					}
					
					var titleImage = $("<div class='titImg'/>").append(titleAnchor);
					var albumSubject = $("<p class='abTitle'/>").append($(viewAnchor), item.RecentlyFlag=="Y"?recentlyIcon:"");
					var albumInfo;
					
					if(bizSection != "Board" || coviAlbum.boardConfig.UseReadCnt == "Y"){
						albumInfo = $("<p class='abInfo'/>").append($("<span/>").append("조회 : "), $("<span/>").append(item.ReadCnt), $("<span class='line'/>").append("|"), $("<span/>").append(item.RegistDate.substring(0,10)));
					}else{
						albumInfo = $("<p class='abInfo'/>").append(item.RegistDate.substring(0,10));
					}
					
					var albumData;
					
					if(item.FileCnt != "0"){
						albumData = $("<div class='abData'/>").append($("<span class='abHeart'/>").append(item.RecommendCnt), $("<span class='abReplayCout'/>").append(item.CommentCnt), divFile.append(anchorAttFile, ulFileList));
					}else{
						albumData = $("<div class='abData'/>").append($("<span class='abHeart'/>").append(item.RecommendCnt), $("<span class='abReplayCout'/>").append(item.CommentCnt));
					}
					
					var albumBody = $("<div/>").addClass("abTxt").append(albumSubject, albumInfo, $("<p class='abName/>").append(item.CreatorName), albumData);
					var albumBox = $("<div/>").addClass("albumBox").append(titleImage, albumBody);
					wrapAlbum.append($("<li/>").append(albumBox));
	     		});
				
				if(data.list.length == 0){
					wrapAlbum.append($("<li style='width: 100%; text-align: center;  color: #9a9a9a;  padding: 20px;'>").text(coviDic.dicMap["msg_NoDataList"]));
				}
				
				albumContent.html(wrapAlbum);
					
				coviAlbum.fnMakeNavi(this.target, data.page)
		 	}
			//set file data
		},
		fnMakeNavi : function(target, data){
			var divPageNaviID = target + "PageBody";	//앨범 Div targetID + pageBody ID생성
			$('#'+divPageNaviID).remove();				//기존 Page Div 삭제
			$('#'+target).after($('<div/>').attr('id', divPageNaviID).addClass('pagingBox cRContEnd'));
			
			var rowCount = $('<div class="AXgridStatus">').append($('<b>').text(data.listCount), coviDic.dicMap["lbl_Count"]);		//개수 표시 다국어 필요
			var divCustomNavi = $('<div>').attr('id', 'custom_navi_'+divPageNaviID).attr('style', 'text-align:center;margin-top:2px;');
			
	    	var list_offset = 5; // navigation에서 한번에 보여질 페이지 개수
	    	this.page = data;
	    	
	        // gypark 전체갯수가 한번 보여주는 갯수의 배일 경우 페이지가 하나 더 나오는 오류 수정
	        if(this.page.listCount != 0 && this.page.listCount % this.page.pageSize == 0){
	        	this.page.pageCount = (this.page.listCount / this.page.pageSize);
	        }
	        if(this.page.pageCount == 0){
	        	this.page.pageCount = 1;
	        }
	    	
	        var start_page = Math.ceil(this.page.pageNo / list_offset) * list_offset - (list_offset - 1);
	        var end_page = (start_page + list_offset - 1 > this.page.pageCount) ? this.page.pageCount : start_page + list_offset - 1;
	        
	        var pageCount = this.page.pageCount;//this.page.listCount == this.page.pageCount * this.page.pageSize ? this.page.pageCount - 1 : this.page.pageCount; 
	        var inputPageMove = $('<div class=goPage>').append($('<input id="txtPageMove" type="text">'), $('<span>').text(" / 총 "), $('<span>').text(pageCount), $('<span>').text('페이지'), $('<a class="btnGo">').text("go"));
	        //페이징 표시용 DIV에 custom_navi div 추가
//	        $('#'+divPageNaviID).append(rowCount, divCustomNavi, inputPageMove);
	        //페이지 바로가기 숨김
	        $('#'+divPageNaviID).append(rowCount, divCustomNavi);
	        
	        var custom_navi_html = '';

	        custom_navi_html += "<input type=\"button\" id=\"AXPaging_begin\" class=\"AXPaging_begin\"/>";
	        custom_navi_html += "<input type=\"button\" id=\"AXPaging_prev\" class=\"AXPaging_prev\"/>";
	        
	        for (var i=start_page; i<= end_page; i++) {
	            custom_navi_html += "<input type=\"button\" id=\"AXPaging\" value=\"" + i + "\" style=\"width:20px;\" class=\"AXPaging " + (i == this.page.pageNo ? "Blue\"" : "\" ") + "/>";
	        }
	        custom_navi_html += "<input type=\"button\" id=\"AXPaging_next\" class=\"AXPaging_next\"/>";
	        custom_navi_html += "<input type=\"button\" id=\"AXPaging_end\" class=\"AXPaging_end\"/>";
	        $('#custom_navi_' + divPageNaviID).html(custom_navi_html);
	        
	        var pagemovefunc = function (pObj) {
            	coviAlbum.setList(pObj, coviAlbum.boardConfig);
	        }
	        
	        $("#"+divPageNaviID).find(".AXPaging_begin").click(function () {
	        	this.page.pageNo = 1;
	        	pagemovefunc(this.searchParam);
	        }.bind(this));
	        
	        $("#"+divPageNaviID).find(".AXPaging_prev").click(function () {
	        	this.page.pageNo = start_page > 1 ? start_page - 1 : 1;
	        	pagemovefunc(this.searchParam);
	        }.bind(this));
	        
	        var obj = this;
	        $("#"+divPageNaviID).find(".AXPaging").each(function () {
	        	$(this).click(function () { 
	                var thisobjname =$(this).parents("div").parents("div").attr("id");
	                if($("#"+divPageNaviID).attr("id")==thisobjname){
	                	obj.page.pageNo = $(this).attr("value");           
	                    pagemovefunc(obj.searchParam);
	                   }             
	             });     
	        });
	        
	        $("#"+divPageNaviID).find(".AXPaging_next").click(function () {
	        	obj.page.pageNo = end_page < obj.page.pageCount ? end_page + 1 : end_page;
	        	pagemovefunc(obj.searchParam);
	        }.bind(this));
	        
	        $("#"+divPageNaviID).find(".AXPaging_end").click(function () {
	        	obj.page.pageNo = pageCount;
	        	pagemovefunc(obj.searchParam);
	        }.bind(this));
		},
		
		setList: function( pObj, pConfig){
			coviAlbum.boardConfig = pConfig;

			Common.getDicList(["msg_apv_030","msg_NoDataList","lbl_Count"]);

			var url = this.url;		//coviAlbum.url 설정값
			pObj["pageNo"] = this.page.pageNo;
			pObj["pageSize"] = this.page.pageSize;
			pObj["sortBy"] = this.page.sortBy;
			this.searchParam = pObj;
			
			$.ajax({
				type:"POST",
			    async : false,
				url : url,
				data : this.searchParam,
				success: function(data){
					if(data.status=='SUCCESS'){
						coviAlbum.renderAlbumList(data, pConfig);
						coviAlbum.page = data.page;
			   		}else{
			   			Common.Warning(coviDic.dicMap["msg_apv_030"] );//오류가 발생했습니다.
			   		}
			   	},
			   	error:function(response, status, error){
				     CFN_ErrorAjax(url, response, status, error);
				}
		   });
		}
	};
	window.coviAlbum = coviAlbum;
})(jQuery);
