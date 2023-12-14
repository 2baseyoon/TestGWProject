
	function initLeft(){
		//left menu 그리는 부분
		var opt = {
    			lang : "ko",
    			isPartial : "true"
    	};
		boardLeft = new CoviMenu(opt);

		$("#leftmenu").prepend("<li><div id='coviTree_FolderMenu' class='treeList radio' /></li>");
		setTreeData( myFolderTree, 'coviTree_FolderMenu', menuID, 'Legacy');
	
		
		coviCtrl.bindmScrollV($('.mScrollV'));
	}

	
	//Left menu 하위에 위치하는 Tree Menu 추가
	//pTreeObject: coviTree 객체
	//pTreeDiv: 바인딩할 DIV Element
	//leftMenuType: 전체게시 조회(Total), 즐겨찾기 게시(Favorite) 구분 
	function setTreeData( pTreeObject, pTreeDiv, pLeftMenuID, param ){
		$.ajax({
			url:"board/selectFolderTreeData.do",
			type:"POST",
			data:{
				"menuID": pLeftMenuID,
				"bizSection": param
			},
			async:false,
			success:function (data) {
				var treeList = data.list;				
				pTreeObject.setTreeList(pTreeDiv, treeList, "nodeName", "100%", "left", false, false, body);
				pTreeObject.expandAll(2);
			},
			error:function (error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
		pTreeObject.displayIcon(true);
	}