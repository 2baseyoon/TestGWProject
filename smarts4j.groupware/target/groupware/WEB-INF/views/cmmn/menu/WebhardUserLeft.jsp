<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
.treeList .AXTree_none .AXTreeScrollBody .AXTreeBody .treeBodyTable tbody tr.selected td .bodyTdText {color: #19abd8;font-weight: 700;}
</style>

<div class="cLnbTop">
	<h2>웹하드</h2>						
	<div class="searchBox02 lnb">
	</div>
</div>					
<div class="cLnbMiddle taskLnbContent">
	<div>
		<ul class="contLnbMenu taskMenu">								
			<li class="taskMenu01">
				<div id="AXTreeTarget" class="treeList radio radioType02" style='height:600px;'></div>
			</li>
		</ul>
	</div>						
</div>

<script type="text/javascript">
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	
	var myTree = new AXTree();
	var myModal = new AXModal();
	
	// 폴더 추가(하위 조직원 폴더가 있을 때 그 위에 추가)
	myTree.appendTree = function (itemIndex, item, subTree) {
		var cfg = this.config;
		var reserveKeys = cfg.reserveKeys;

		if (itemIndex == null || itemIndex == undefined || item == null || item == undefined) {
			var tree = this.tree;
			axf.each(subTree, function () {
				this[cfg.reserveKeys.subTree] = [];
				this._CUD = "C";
				tree.push(this);
			});

			var pushedList = this.appendSubTree("0".setDigit(cfg.hashDigit), true, subTree, this.tree);
			this.printList();
		} else { // 부모 하위 개체로 추가할 때에.
			axf.each(subTree, function () {
				if (!this[cfg.reserveKeys.subTree]) this[cfg.reserveKeys.subTree] = [];
			});
			var hashs = item[cfg.reserveKeys.hashKey].split(/_/g);

			var tree = this.tree; // 추가될 트리 구하기
			axf.each(hashs, function (idx, T) {
				if (idx > 0) {
					if (idx == 1) tree = tree[T.number()];
					else tree = tree[cfg.reserveKeys.subTree][T.number()];
				}
			});

			var subTreeLen = tree.subTree.length;
			var lastSubTree = tree.subTree[subTreeLen - 1];
			axf.each(subTree, function () {
				this._CUD = "C";
				
				if (typeof(lastSubTree) != 'undefined' && lastSubTree.folderType == 'I') {
					tree[reserveKeys.subTree].splice(subTreeLen - 1, 0, this);
				} else {
					tree[reserveKeys.subTree].push(this);
				}
			});

			this.list = this.convertHashListToTree(this.tree);
			this.printList();
		}

		this.contentScrollXAttr = null;
		this.contentScrollYAttr = null;
	};

	// 폴더 이동 처리(선택 실패시 해제, 하위 조직원 폴더가 있을 때 그 위에 추가)
	myTree.moveTreeExec = function (moveIndex, targetIndex) {
		var cfg = this.config;
		var reserveKeys = cfg.reserveKeys;
		var relation = cfg.relation;

		if (moveIndex == targetIndex) {
			alert("이동 위치와 이동대상이 같습니다. 이동 할 수 없습니다.");
			this.cancelMove();
			return;
		}

		var moveObj = this.list[moveIndex];
		var targetObj = this.list[targetIndex];

		if (moveObj[reserveKeys.parentHashKey] == targetObj[reserveKeys.hashKey]) {
			alert("이동 위치가 현재 위치와 다르지 않습니다. 이동 할 수 없습니다.");
			this.cancelMove();
			return;
		}
		if (moveObj[reserveKeys.hashKey] == targetObj[reserveKeys.hashKey].left(moveObj[reserveKeys.hashKey].length)) {
			alert("이동 위치가 자식위치입니다. 이동 할 수 없습니다.");
			this.cancelMove();
			return;
		}

		if (this.moveValidate) {
			var validateResult = this.moveValidate.call({ moveObj: moveObj, targetObj: targetObj }, moveObj, targetObj);
			if (!validateResult) {
				this.cancelMove();
				return;
			}
		}

		//아이템 복사 ~~~~~~~~~~~~~~~~~~
		var move_hashs = moveObj[reserveKeys.hashKey].split(/_/g);
		var move_Tree_parent = this.tree;
		for (var hidx = 1; hidx < move_hashs.length - 1; hidx++) {
			if (hidx == 1) {
				move_Tree_parent = move_Tree_parent[move_hashs[hidx].number()];
			} else {
				move_Tree_parent = move_Tree_parent[cfg.reserveKeys.subTree][move_hashs[hidx].number()];
			}
		}
		var copyObject = {};
		var move_Tree_parent_subTree = [];
		if (move_hashs.length == 2) {
			move_Tree_parent_subTree = this.tree;
		} else {
			move_Tree_parent_subTree = move_Tree_parent[cfg.reserveKeys.subTree];
		}

		axf.each(move_Tree_parent_subTree, function (subTreeIndex, ST) {
			if (ST[relation.childKey] == moveObj[relation.childKey]) {
				copyObject = AXUtil.copyObject(ST);
			} else {

			}
		});
		//~~~~~~~~~~~~~~~~~~ 아이템 복사

		//아이템 이동 ~~~~~~~~~~~~~~~~~~
		var target_hashs = targetObj[reserveKeys.hashKey].split(/_/g);
		var target_Tree_parent = this.tree;

		var newSelectedHashs = [];
		newSelectedHashs.push(target_hashs[0]);
		for (var hidx = 1; hidx < target_hashs.length; hidx++) {
			newSelectedHashs.push(target_hashs[hidx]);
			if (hidx == 1) {
				target_Tree_parent = target_Tree_parent[target_hashs[hidx].number()];
			} else {
				target_Tree_parent = target_Tree_parent[cfg.reserveKeys.subTree][target_hashs[hidx].number()];
			}
		}
		newSelectedHashs.push((target_Tree_parent[cfg.reserveKeys.subTree].length).setDigit(cfg.hashDigit));

		copyObject[relation.parentKey] = target_Tree_parent[relation.childKey];
		try {
			copyObject[relation.parentName] = target_Tree_parent[relation.childName];
		} catch (e) {
			coviCmn.traceLog(e);
		}

		function treeExtend( _treeItems ){
			for(var ti = 0 ; ti < _treeItems.length ; ti++){
				if(typeof _treeItems[ti]._CUD == "undefined") _treeItems[ti]._CUD = "U";
				if( _treeItems[ti][cfg.reserveKeys.subTree] ){
					treeExtend( _treeItems[ti][cfg.reserveKeys.subTree] );
				}
			}
		}
		if(typeof copyObject._CUD == "undefined") copyObject._CUD = "U";
		treeExtend( copyObject[cfg.reserveKeys.subTree] );

		var subTree = target_Tree_parent[cfg.reserveKeys.subTree];
		var subTreeLen = subTree.length;
		var lastSubTree = subTree[subTreeLen - 1];
		if (typeof(lastSubTree) != 'undefined' && lastSubTree.folderType == 'I') {
			subTree.splice(subTreeLen - 1, 0, copyObject);
		} else {
			subTree.push(copyObject);
		}
		
		var newSelectedHash = newSelectedHashs.join("_");

		//~~~~~~~~~~~~~~~~~~ 아이템 이동

		//이동된 아이템 제거
		var new_subTree = [];
		axf.each(move_Tree_parent_subTree, function (subTreeIndex, ST) {
			if (ST[relation.childKey] == moveObj[relation.childKey]) {

			} else {
				new_subTree.push(ST);
			}
		});

		if (move_hashs.length == 2) {
			this.tree = new_subTree;
		} else {
			move_Tree_parent[cfg.reserveKeys.subTree] = new_subTree;
		}

		this.selectedCells.clear();
		this.selectedRow.clear();

		this.list = this.convertHashListToTree(this.tree);
		this.printList();

		var newSelecteIndex;
		for (var idx = 0; idx < this.list.length; idx++) {
			if (this.list[idx][reserveKeys.hashKey] == newSelectedHash) {
				newSelecteIndex = idx;

				this.body.find(".gridBodyTr_" + newSelecteIndex).addClass("selected");
				this.selectedRow.push(newSelecteIndex);

				break;
			}
		};

		this.cancelMove();
	};
	
	// 자신 우클릭시 메뉴엔 폴더 추가만
	myTree.onContextmenu = function (event) {
		var cfg = this.config;

		if (this.readyMoved) return false;

		// event target search -
		if(event.target.id == "") return;
		var eid = event.target.id.split(/_AX_/g);
		var eventTarget = event.target;
		if (eventTarget.tagName.toLowerCase() == "input") return; //input 인 경우 제외
		var myTarget = this.getEventTarget({
			evt: eventTarget, evtIDs: eid,
			until: function (evt, evtIDs) { return (axdom(evt.parentNode).hasClass("gridBodyTr")) ? true : false; },
			find: function (evt, evtIDs) { return (axdom(evt).hasClass("bodyTd") || axdom(evt).hasClass("bodyNodeIndent")) ? true : false; }
		});
		// event target search ------------------------

		if (myTarget) {
			//colHeadTool ready
			var targetID = myTarget.id;
			var itemIndex = targetID.split(/_AX_/g).last();
			var ids = targetID.split(/_AX_/g);

			if (this.selectedCells.length > 0) {
				axf.each(this.selectedCells, function () {
					axdom("#" + this).removeClass("selected");
				});
				this.selectedCells.clear();
			}
			if (this.selectedRow.length > 0) {
				var body = this.body;
				axf.each(this.selectedRow, function () {
					body.find(".gridBodyTr_" + this).removeClass("selected");
				});
			}

			this.selectedRow.clear();
			this.body.find(".gridBodyTr_" + itemIndex).addClass("selected");
			this.selectedRow.push(itemIndex);

			var item = this.list[itemIndex];
			var menu = [{label:"폴더 추가", className:"", onclick:fnObj.addTree},
						{label:"삭제", className:"", onclick:fnObj.delTree},
						{label:"이동", className:"", onclick:fnObj.moveTree},
						{label:"이름변경", className:"", onclick:fnObj.modifyTree}
			];
			if (cfg.contextMenu && item.folderType == 'N') menu = [{label:"폴더 추가", className:"", onclick:fnObj.addTree}];
			AXContextMenu.bind({
				id: cfg.targetID + "ContextMenu",
				theme: cfg.contextMenu.theme, // 선택항목
				width: cfg.contextMenu.width, // 선택항목
				menu: menu
			});
			
			axdom("#" + cfg.targetID).unbind("contextmenu").bind("contextmenu", this.onContextmenu.bind(this));
			
			AXContextMenu.open({ id: cfg.targetID + "ContextMenu", filter: cfg.contextMenu.filter, sendObj: item }, event); // event 직접 연결 방식
		}
		return false;
	};
	
	var fnObj = {
		pageStart: function(){
			fnObj.tree1();
		},
		tree1: function(){
			myTree.setConfig({
				targetID : "AXTreeTarget",
				theme: "AXTree_none",
				//height:"auto",
				xscroll:false,
				relation:{
                    // rootID:"0", // 부모가 없는 최상위 아이템의 parentKey value (필요한 경우에만 사용)
					parentKey:"parentFolderId",
					childKey:"folderId"
				},				
				colGroup: [
					{key:"no", label:"번호", width:"100", align:"center", display:false},
					{key:"nodeName", label:"제목", width:"100%", align:"left", indent:true,
						getIconClass: function(){
							//folder, AXfolder, movie, img, zip, file, fileTxt, fileTag
							//var iconNames = "company, folder, AXfolder, movie, img, zip, file, fileTxt, fileTag".split(/, /g);
							var iconName = "file";
							if(this.item.type) iconName = this.item.type;
							return iconName;
						},
						formsatter:function(){
							//return "<b>"+this.item.no.setDigit(2) + "</b> : " + this.item.nodeName + " (" + this.item.writer + ")";
							return this.item.nodeName;
						}
					},
					{key:"writer", label:"작성자", width:"100", align:"center", display:false}
				],
				body: {
					onclick:function(idx, item) {
						var folderType = item.folderType;	// N : 이름, D : 기본폴더(B,E,S,T), C : 생성폴더, I : 하위조직원
						
						if (item.__subTreeLength == 0) { //자식개체가 없으므로.. subTree 호출 처리 합니다.
							myTree.setLoading(index, item); // 화살표를 loading mark 로 전환 합니다.
							
							var index = this.index, item = this.item;
							var owner = item.owner;
							var params = {};
							var url = '';
							
 							if (folderType == 'D' || folderType == 'C') {
 								params.folderId = this.item.folderId;
 								url = '/groupware/webhard/getTreeChildDataList.do';
							} else if (folderType == 'I') {
								params.reqType = 'include';	// initLeft : 초기, folder : 폴더, include : 하위 조직원
								params.userCode = owner;
								url = '/groupware/webhard/getTreeDataList.do';
							} else if (folderType == 'N') {
								params.reqType = 'user';
								params.userCode = owner;
								url = '/groupware/webhard/getTreeDataList.do';
							}
 							
					 	  	$.ajax({
								type : "POST",
								data : params,
								async: false,
								url : url,
								success: function (list) {
									var data = list.list;
									
 									myTree.appendTree(index, item, data);
									if (data.length > 0) myTree.click(index, "expand", true);
								},
								error: function(response, status, error) {
									CFN_ErrorAjax(url, response, status, error);
								},
							    complete : function() {
							    	myTree.endLoading(index, item); // 화살표를 loading mark 로 전환 합니다.
							    	
							    	if ($('#dupe_overlay').length > 0) $('#dupe_overlay').remove();
							    }
							});
						}
						
						var ownerYn = Common.getSession('USERID') == item.owner ? 'Y' : 'N';
						
						if (folderType == 'D' || folderType == 'C') {
							CoviMenu_GetContent('/groupware/layout/webhard_WebhardList.do?CLSYS=webhard&CLMD=user&CLBIZ=Webhard&folderId=' + item.folderId +'&folderName=' + item.nodeName +'&ownerYn=' + ownerYn);
						}
					}
				},
				contextMenu: {
					theme:"AXContextMenu", // 선택항목
					width:"80", // 선택항목
					menu:[
						{label:"폴더 추가", className:"", onclick:fnObj.addTree},
						{label:"삭제", className:"", onclick:fnObj.delTree},
						{label:"이동", className:"", onclick:fnObj.moveTree},
						{label:"이름변경", className:"", onclick:fnObj.modifyTree}
					],
					filter:function(id) {
						if (this.sendObj && // 선택된 트리 아이템이 있을때
							this.sendObj.folderType != "D" && // 기본 폴더가 아닐때
							this.sendObj.folderType != "I" &&	// 하위 조직원 폴더가 아닐때
							Common.getSession('USERID') == this.sendObj.owner) {	// 본인의 폴더 일때
							return true;
						} else {
							return false;
						}
					}
				}
			});
			
			// reqType - initLeft : 초기, folder : 폴더, include : 하위 조직원
			// folderType - N : 이름, D : 기본폴더(B,E,S,T), C : 생성폴더, I : 하위조직원
  	  		$.ajax({
				type : "POST",
				data : {reqType : 'initLeft'},
				async: false,
				url : "/groupware/webhard/getTreeDataList.do",
				success: function (list) {
					myTree.setList(list.list);
				},
				error: function(response, status, error) {
					CFN_ErrorAjax("/groupware/webhard/getTreeDataList.do", response, status, error);
				}
			});
			
		},
		addTree: function(){
			var obj = myTree.getSelectedList();
			var item = obj.item;
			
			Common.open("","target_pop","폴더 추가","/groupware/webhard/goAddTreePopup.do?folderId=" + item.folderId + "&owner=" + item.owner,"499px","140px","iframe",true,null,null,true);
		},
		delTree: function(){
			var obj = myTree.getSelectedList();
			
 	        Common.Confirm("폴더를 삭제 하시겠습니까?", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
			  		$.ajax({
						type : "POST",
						data : {folderId : obj.item.folderId},
						async: false,
						url : "/groupware/webhard/deleteFolder.do",
						success: function (list) {
							myTree.removeTree(obj.index, obj.item);
							
							myTree.click(1);
						},
						error: function(response, status, error) {
							CFN_ErrorAjax("/groupware/webhard/deleteFile.do", response, status, error);
						}
					});
				} else {
					return false;
				}
			});
		},
		moveTree: function(){
			var obj = myTree.getSelectedList();
			
			myTree.moveTree({
				startMove: function(){      //moveTree가 발동 되었을 때 발생되는 콜백함수
					myTree.addClassItem({
			     		className:"disable",
			     		addClass:function(){
			     			return (this.nodeID == "N");
			     		}
			     	});
			     },
			     validate:function(){        //moveTree가 활성화 된 상태에서 사용자의 선택을 검증하는 콜백함수
			    	if (this.targetObj.folderType == 'I' ||	// 하위 조직원 폴더
			    		Common.getSession('USERID') != this.targetObj.owner) {	// 본인의 폴더 여부
				    		alert("본인의 폴더만 이동 가능합니다.");
				     		return false;
			     	} else {
				  		$.ajax({
							type : "POST",
							data : {reqType : 'parentFolderId',
									folderId : obj.item.folderId,
									newParentFolderId : this.targetObj.folderId},
							async: false,
							url : "/groupware/webhard/updateFolder.do",
							success: function (list) {
								
							},
							error: function(response, status, error) {
								CFN_ErrorAjax("/groupware/webhard/updateFolder.do", response, status, error);
							}
						});
				  		
			     		return true;
			     	}
			     },
			     endMove: function(){        //moveTree가 완료 되었을때 발생되는 콜백함수
			     	myTree.removeClassItem({
			     		className:"disable",
			     			removeClass:function() {
			     				return (this.nodeID == "N");
			     			}
			     	});
			     }
			});
		},		
		modifyTree: function(){
			var obj = myTree.getSelectedList();
			var item = obj.item;
			
			Common.open("","target_pop","폴더 이름 변경","/groupware/webhard/goModifyTreePopup.do?folderId=" + item.folderId +'&folderName=' + item.nodeName,"499px","170px","iframe",true,null,null,true);
		}
	};
	
	initLeft();

	function initLeft() {
		fnObj.pageStart();
		
  		if (loadContent == 'true') myTree.click(1);
	}
</script>
