<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:500px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">	
		<div class="popContent" style="position:relative;">
			<ul id="tabList" class="tabType2 clearFloat">
				<li name="boxType" class="active"><a href="#"><spring:message code='Cache.lbl_apv_search'/></a></li> <!-- 검색 -->
				<li name="boxType"><a href="#"><spring:message code='Cache.lbl_businessDivision'/></a></li>	<!-- 업무구분 -->
			</ul>
			<div id="searchPage">
				<div style="margin: 18px 0;">
					<select id="searchType" style="width: 100px;">
						<option value="All"><spring:message code="Cache.lbl_all"/></option> <!-- 전체 -->
						<option value="Code"><spring:message code='Cache.lbl_apv_Code'/></option> <!-- 코드 -->
						<option value="Name"><spring:message code='Cache.lbl_name'/></option> <!-- 이름 -->
					</select>
					<input type="text" id="searchWord" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
					<a id="simpleSearchBtn" class="btnTypeDefault btnSearchBlue nonHover" onclick="onClickSearchButton();"><spring:message code='Cache.lbl_apv_search'/></a> <!-- 검색 -->
				</div>
				<div>
					<div id="functionGrid"></div>
				</div>
			</div>
			<div class="treeList radio radioType02 org_tree mScrollVH scrollVHType01" >
				<div id="treePage" class="treeList radio radioType02 org_tree" style="display: none; height: 546px; margin-top: 18px; overflow:hidden;"></div>
			</div>
			<div class="bottom">
				<a id="btnSubmit" class="btnTypeDefault btnTypeChk" onclick="submitSeriesFunc();"><spring:message code='Cache.lbl_apv_Confirm'/></a> <!-- 확인 -->
				<a id="btnClose" class="btnTypeDefault" onclick="Common.Close(); return false;"><spring:message code='Cache.btn_Cancel'/></a> <!-- 취소 -->
			</div>
		</div>
	</div>	
</div>

<script>
	var ListGrid = new coviGrid();
	var funcObj = new Object();
	var $this = funcObj;
	var allGroupBind = "N";
	var selectedFuncCode = null;
	
	funcObj.groupTree = new AXTree();

	//전체 펴기
	funcObj.expandAllTree = function(obj){
		if(allGroupBind == "N"){
			$.each($this.groupTree.list,function(idx,group){
				if(group.haveChild == "Y" && group.isLoad == "N"){ //하위 항목이 있는데 로드가 안된 경우가 있는 경우 전체 트리 바인드
					setAllGroupTreeData();
					return false; //break
				}
			});
		}
		
		$this.groupTree.expandAll();
	}
	
	//전체 접기
	funcObj.collapseAllTree = function(obj){
		$this.groupTree.collapseAll();
	}
	
	//Tree 함수
	funcObj.groupTree.displayIcon = function(value){
		if(value){
			$("[id^='"+this.config.targetID+"_AX_bodyNodeIcon']").css("display","block");
		}else{
			$("[id^='"+this.config.targetID+"_AX_bodyNodeIcon']").css("display","none");
		}
	}
	
	funcObj.groupTree.getCheckedTreeList = function(inputType){
		var collect = [];
		var list = this.list;
		
		this.body.find("input[type="+inputType+"]").each(function(){
			var arr = this.id.split('_'); 
			if(this.checked && (arr[1] == "treeCheckbox" || arr[1]== "treeRadio")){
				var itemIndex = this.id.replace(arr[0]+ "_" + arr[1] + "_", "");
				for(var i=0; i < list.length; i++)
					if(list[i].FunctionCode == itemIndex)
						collect.push(list[i]);
			}
		});
		return collect;
	}
	
	function init(){
		setInitGroupTreeData();
		
		$("#tabList li").on("click", function(){
			var idx = $("#tabList li").index(this);
			
			if(idx == 0){
				$("#searchPage").show();
				$(".treeList").hide();
			}else{
				$("#searchPage").hide();
				$(".treeList").show();
			}
			
			$("#tabList li").removeClass("active");
			$(this).addClass("active");
		});
		
		setGrid();
	}
	
	function setGrid(){
		setGridConfig();
		setSeriesListData();
	}
	
	function setGridConfig(){
		var headerData = [
							{key:'chk', label:'chk', width:'5', align:'center', formatter:'checkbox', sort:false},
							{key:'FunctionCode', label:'<spring:message code="Cache.lbl_functionCode"/>', width:'20', align:'center'}, // 기능코드
							{key:'FunctionName', label:'<spring:message code="Cache.lbl_functionName"/>', width:'20', align:'center'} // 기능명
						];
		
		seriesHeaderData = headerData;
		ListGrid.setGridHeader(headerData);
	
		var configObj = {
			targetID: "functionGrid",
			height: "auto",
			listCountMSG: "<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", // 개
			body: {},
			page: {
				pageNo: 1,
				pageSize: 10
			},
			paging: true,
		};
		
		ListGrid.setGridConfig(configObj);
	}
	
	function setSeriesListData(){
		var searchType = $("#searchType").val();
		var searchWord = $("#searchWord").val();
		
		ListGrid.bindGrid({
			ajaxUrl: "/approval/user/getSeriesFunctionListData.do",
			ajaxPars: {
				"searchType": searchType,
				"searchWord": searchWord,
				"functionLevel": 3
			},
			onLoad: function(){
				$(".gridBodyTable > tbody > tr > td").css("background", "white");
				$(".AXGrid").css("overflow", "visible");
				coviInput.init();
			}
		});
	}
	
	function onClickSearchButton(){
		ListGrid.page.pageNo = 1;
		setSeriesListData();
	}
	
	function setGroupTreeConfig(){
		var pid = "treePage" //treeTargetID
		
		var bodyConfig = {
							onclick: function(idx, item){
								changeIndex=0;
								selectedFuncCode = item.FunctionCode;
								if(item.FunctionLevel != "3"){
									$(".treeBodyTable tr").removeClass("selected");
									$(".treeBodyTable tr").eq(idx).find(".bodyNodeIndent").click();
								}
							},
							onexpand: function(idx, item){ //[Function] 트리 아이템 확장 이벤트 콜백함수
								if(item.isLoad == "N" && item.haveChild == "Y"){ //하위 항목이 로드가 안된 상태
									$this.groupTree.updateTree(idx, item, {isLoad: "Y"});
								}
								$(".treeBodyTable tr").removeClass("selected");
							}
						};
		
		$this.groupTree.setConfig({
			targetID : "treePage",					// HTML element target ID
			theme: "AXTree_none",					// css style name (AXTree or AXTree_none)
			//height:"auto",
			xscroll: false,
			showConnectionLine:true,				// 점선 여부
			relation:{
				parentKey: "ParentFunctionCode",	// 부모 아이디 키
				childKey: "FunctionCode"			// 자식 아이디 키
			},
			persistExpanded: false,					// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
			persistSelected: false,					// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
			colGroup:[{
				key: "FunctionName",				// 컬럼에 매치될 item 의 키
				//label:"TREE",						// 컬럼에 표시할 라벨
				width: "490", 						// 부서명 말줌임하지 않고 전체 표시시킬 경우 주석해제(긴 부서가 없을때도 스크롤 생기는 문제 있음)
				align: "left",	
				indent: true,						// 들여쓰기 여부
				getIconClass: function(){			// indent 속성 정의된 대상에 아이콘을 지정 가능
					var iconNames = "folder, AXfolder, movie, img, zip, file, fileTxt, company".split(/, /g);
					var iconName = "";
					if(typeof this.item.type == "number") {
						iconName = iconNames[this.item.type];
					} else if(typeof this.item.type == "string"){
						iconName = this.item.type.toLowerCase(); 
					} 
					return iconName;
				},
				formatter:function(){
					var anchorName = $('<a />').attr('id', 'folder_item_'+this.item.FunctionCode);
					anchorName.text(this.item.FunctionName);
					
					if(this.item.onclick != "" && this.item.onclick != undefined){
						anchorName = $('<div />').attr('onclick', this.item.onclick).append(anchorName);
					}
					
					var str = anchorName.prop('outerHTML');
					
					return str;
				}
			}],								// tree 헤드 정의 값
			body: bodyConfig				// 이벤트 콜벡함수 정의 값
		});
		
	}
	
	//전체 트리 바인딩
	function setAllGroupTreeData(){
		setGroupTreeConfig();
		
		$.ajax({
			url: "/approval/user/getSeriesFunctionTreeData.do",
			type: "POST",
			data: {},
			async: false,
			success: function(data){
				allGroupBind = "Y";
				$this.groupTree.setList( data.list );
			},
			error: function(response, status, error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			}
		});

		$this.groupTree.displayIcon(false); //Icon에 checkbox 가려지는 현상 제거
	}
	
	function setInitGroupTreeData(){
		setGroupTreeConfig();
		
		$.ajax({
			url: "/approval/user/getSeriesFunctionTreeData.do",
			type: "POST",
			data: {},
			async: false,
			success: function(data){
				$this.groupTree.setList( data.list );
				//$this.groupTree.expandAll(1)
			},
			error: function(response, status, error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			},
		});

		$this.groupTree.displayIcon(false); //Icon에 checkbox 가려지는 현상 제거
	}
	
	
	function getSeriesPath(funcCode){
		var seriesPath = "";
		
		$.ajax({
			url: "/approval/user/getSeriesPath.do",
			type: "POST",
			data: {
				"SeriesCode": funcCode
			},
			async: false,
			success:function (data) {
				seriesPath = data.SeriesPath;
			},
			error:function(response, status, error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
			},
		});
		
		return seriesPath;
	}
	
	function submitSeriesFunc(){
		var callBackFunc = CFN_GetQueryString("callBackFunc") == "undefined" ? "" : CFN_GetQueryString("callBackFunc");
		var pSeriesFuncArr = [];
		var idx = $("#tabList li").index($("#tabList li.active"));
		
		switch(idx){
			case 0:
				var checkList = ListGrid.getCheckedList(0);
				
				if(checkList.length > 1){
					Common.Inform('<spring:message code="Cache.msg_SelectOne" />'); // 한개만 선택되어야 합니다
					return false;
				}else if(checkList.length == 0){
					Common.Inform('<spring:message code="Cache.lbl_apv_alert_selectRow" />'); // 선택한 행이 없습니다.
					return false;
				}else{
					$(checkList).each(function(i, item){
						var json = {
							"Code": item.FunctionCode,
							"Path": getSeriesPath(item.FunctionCode)
						}
						
						pSeriesFuncArr.push(json);
					});
				}
				break;
			case 1:
				if(selectedFuncCode == null){
					Common.Inform('<spring:message code="Cache.lbl_apv_alert_selectRow" />');
				}else{
					var json = {
							"Code": selectedFuncCode,
							"Path": getSeriesPath(selectedFuncCode)
						}
						
						pSeriesFuncArr.push(json);
				}
				break;
		}
		
		if(callBackFunc != ""){
			try{
				parent.window[callBackFunc].apply(parent.window, [pSeriesFuncArr]);
				
				Common.Close();
			}catch (e) {
				coviCmn.traceLog(e);
			}
		}
	}
	
	init();
</script>