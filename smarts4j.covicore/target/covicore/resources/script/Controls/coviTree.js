/**
 * coviTree
 * @class coviTree
 * @extends AXTree
 */

var coviTree= Class.create(AXTree, {
	
	/**
	 * setTreeList
	 * @method setTreeList
	 * @param pid - HTML element target ID
	 * @param data - tree date
	 * @param nodeName - data에서 title node 명
	 * @parma col_width - tree width
	 * @param col_align - tree align
	 * @param IsCheck - tree list의 checkbox 여부
	 * @param IsRadio - tree list의 radiobox 여부
	 */
	setTreeList: function(pid, data, nodeName, col_width, col_align, IsCheck, IsRadio){
		var colGroup = [{
			key: nodeName,			// 컬럼에 매치될 item 의 키
			//label:"TREE",				// 컬럼에 표시할 라벨
			width: col_width,
			align: col_align,				// left
			indent: true,					// 들여쓰기 여부
			getIconClass: function(){		// indent 속성 정의된 대상에 아이콘을 지정 가능
				var iconNames = "folder, AXfolder, movie, img, zip, file, fileTxt, company".split(/, /g);
				var iconName = "";
				if(this.item.type) iconName = iconNames[this.item.type];
				return iconName;
			},
			formatter:function(){
				var str =  "<a ";
				
				if(this.item.url != "" && this.item.url != undefined){
					str += " href='"+this.item.url+"' ";
				}
				if(this.item.onclick != "" && this.item.onclick != undefined){
					str +=" onclick='"+this.item.onclick+"'";
				}
				str += ">"+this.item.nodeName+"</a>";
				
				if(IsCheck){
					str = func.covi_setCheckBox(this.item) + str;
				}
				if(IsRadio){
					str = func.covi_setRadio(this.item) + str;
				}
				return str;
			}
		}];
		
		var body = {
				onclick:function(idx, item){
					//toast.push(Object.toJSON(item));
				}};
		
		var func = { 		// 내부에서 필요한 함수 정의
			covi_setCheckBox : function(item){		// checkbox button
				if(item.chk == "Y"){
					return "<input type='checkbox' id='treeCheckbox_"+item.no+"' name='treeCheckbox_"+item.no+"' value='"+Object.toJSON(item)+"' />";
				}else if(item.chk == "N"){
					return "";
				}else{
					return "";
				}
			},
			covi_setRadio : function(item){			// radio button
				if(item.rdo == "Y"){
					return "<input type='radio' id='treeRadio_"+item.no+"' name='treeRadio' value='"+Object.toJSON(item)+"' />";
				}else if(item.rdo == "N"){
					return "";
				}else{
					return "";
				}
			}
		};
		
		this.setTreeConfig(pid, "pno", "no", false, false, colGroup, body);
		this.setList(data);
	},
	
	/**
	 * setTreeConfig
	 * @method setTreeConfig
	 * @param pid - HTML element target ID
	 * @param parentkey - parent node의 child key
	 * @param childkey - tree node의 number 
	 * @param cookie_expand - 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
	 * @param cookie_select - 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
	 * @param colGroup - tree 헤드 정의 값
	 * @param body - 이벤트 콜벡함수 정의 값
	 */
	setTreeConfig : function(pid, parentkey, childkey, cookie_expand, cookie_select, colGroup, body){
		this.setConfig({
			targetID : pid,					// HTML element target ID
			theme: "AXTree_none",		// css style name (AXTree or AXTree_none)
			showConnectionLine:true,		// 점선 여부
			relation:{
				parentKey: parentkey,		// 부모 아이디 키
				childKey: childkey			// 자식 아이디 키
			},
			persistExpanded: cookie_expand,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
			persistSelected: cookie_select,			// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
			colGroup:colGroup,						// tree 헤드 정의 값
			body:body									// 이벤트 콜벡함수 정의 값
		});
	},
	
	/**
	 * setappendTree
	 * @method setappendTree
	 * @param data - 추가할 item
	 */
	setAppendTree : function(data){
		var obj = this.getSelectedList();						// 현재 선택된 item
		this.appendTree(obj.index, obj.item, data);		// 해당 item의 하위 노드에 추가
	},
	
	/**
	 * getCheckedTreeList
	 * @method getCheckedTreeList
	 * @param inputType - input 타입. checkbox | radio
	 */
	getCheckedTreeList : function(inputType){
		var collect = [];
		var list = this.list;
		
		this.body.find("input[type="+inputType+"]").each(function(){
			var arr = this.id.split('_');
			if(this.checked && (arr.first() == "treeCheckbox" || arr.first() == "treeRadio")){
				var itemIndex = arr.last();
				for(var i=0; i < list.length; i++)
					if(list[i].no == itemIndex)
						collect.push(list[i]);
			}
		});
		return collect;
	},
	
	/**
	 * gridCheckClick : Tree 형 Grid 에서 체크박스를 check 했을 경우 상위 노드 혹은 하위 노드까지 다 선택되는 것을 막기 위해 빈 내용의 함수로 다시 정의
	 */
	gridCheckClick: function (event, tgId) {},
	
	callExpandAllTree: function(id, IsExpand){
		var itemIndex = new Array();
		var treeObj = this.tree;
			
		this.body.find("#"+id+"_AX_tbody tr").each(function(){
			itemIndex.push($(this)[0].id.split("_").last());
		});
		//trace(itemIndex);
		
		this.expandAllTree(itemIndex, treeObj, 0, IsExpand);
	},
	
	expandAllTree : function(itemIndex, obj, startCnt, IsExpand){
		var cnt = startCnt;
		for(var i=0; i< obj.length; i++){
			if(obj[i].__subTree != false && obj[i].open != IsExpand)
				this.expandToggleList(itemIndex[cnt], obj[i], IsExpand);
			cnt ++;
			if(obj[i].subTree.length > 0){
				//trace(obj[i].hash);
				cnt = this.expandAllTree(itemIndex, obj[i].subTree, cnt, IsExpand);
			}
		}
		return cnt;
	}
});
