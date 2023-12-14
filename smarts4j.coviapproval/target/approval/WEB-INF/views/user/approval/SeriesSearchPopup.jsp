<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
	pageContext.setAttribute("isUseAccount", RedisDataUtil.getBaseConfig("isUseAccount"));
%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<c:if test="${isUseAccount eq 'N'}"><link rel="stylesheet" type="text/css" href="<%=cssPath%>/eaccounting/resources/css/eaccounting.css<%=resourceVersion%>"></c:if>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<style>
	.btn_search03 {background-color: white;}
	.name_box{font-size: 13px;}
</style>

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:800px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">	
		<div class="popContent" style="position:relative;">
			<ul id="tabList" class="tabType2 clearFloat">
				<li name="boxType" class="active"><a href="#"><spring:message code='Cache.lbl_apv_search'/></a></li> <!-- 검색 -->
				<%-- <li name="boxType"><a href="#"><spring:message code='Cache.lbl_businessDivision'/></a></li> --%> <!-- 업무구분 -->
			</ul>
			<div id="searchPage">
				<div style="margin: 18px 0;">
					<div>
						<div class="selectCalView" style="display: inline-block;">
							<spring:message code='Cache.lbl_unitTaskName'/>
							<input type="text" id="searchWord" style="margin-left: 5px" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
						</div>
						<select id="selSearchBaseYear" class="selectType04"></select>
					</div>
					<div class="selectCalView" style="margin-top: 10px">
						<span><spring:message code='Cache.lbl_apv_ManageDept'/></span> <!-- 처리과 -->
						<div class="name_box_wrap" style="width: 100px; margin-left: 33px">
							<span class="name_box" id="deptNm"></span>
							<a class="btn_del03" onclick="delColumn(this);"></a>
						</div>
						<a class="btn_search03" onclick="orgChartPopup();"></a>
						<a id="simpleSearchBtn" class="btnTypeDefault btnSearchBlue nonHover" onclick="onClickSearchButton();" style="margin-left: 10px;"><spring:message code='Cache.lbl_apv_search'/></a> <!-- 검색 -->
					</div>
				</div>
				<div>
					<div id="searchGrid"></div>
				</div>
			</div>
			<div class="treeList radio radioType02 org_tree mScrollVH scrollVHType01" style="display: none;">
				<select id="selTreeBaseYear" class="selectType04"></select>
				<div id="treePage" class="treeList radio radioType02 org_tree" style="display: none; height: 300px; margin-top: 18px; overflow:hidden;"></div>
			</div>
			<div class="bottom">
				<a id="btnSubmit" class="btnTypeDefault btnTypeChk" onclick="submitSeries();"><spring:message code='Cache.lbl_apv_Confirm'/></a> <!-- 확인 -->
				<a id="btnClose" class="btnTypeDefault" onclick="Common.Close(); return false;"><spring:message code='Cache.btn_Cancel'/></a> <!-- 취소 -->			
			</div>
		</div>
	</div>	
</div>

<script>
	var ListGrid = new coviGrid();
	var allGroupBind = "N";
	var selectedFuncCode = null;
	var selectedItem = {};
	var funcObj = new Object();
	var $this = funcObj;
	let RecordAdmin = 'N';
	
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
			var arr = this.id.split("_"); 
			if(this.checked && (arr[1] == "treeCheckbox" || arr[1]== "treeRadio")){
				var itemIndex = this.id.replace(arr[0]+ "_" + arr[1] + "_", "");
				for(var i=0; i < list.length; i++)
					if(list[i].SFCode == itemIndex)
						collect.push(list[i]);
			}
		});
		return collect;
	}
	
	function init(){
		setYearList();
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
		
		$("#selSearchBaseYear").on("change", onClickSearchButton);
		$("#selTreeBaseYear").on("change", setAllGroupTreeData);
		
		setGrid();
	}
	
	function setYearList(){
		$.ajax({
			url: "/approval/user/getSeriesBaseYearList.do",
			type: "POST",
			dataType: "json",
			async: false,
			success: function(data){
				baseYear = new Date().getFullYear();
				var list = data.list;
				var baseYearHtml = "";
				
				$.each(list, function(idx, item){
					baseYearHtml += "<option value='"+item.BaseYear+"'>"+item.BaseYear+"</option>";
				});
				
				$("#selSearchBaseYear").html(baseYearHtml);
				$("#selSearchBaseYear").val(baseYear);
				$("#selTreeBaseYear").html(baseYearHtml);
				$("#selTreeBaseYear").val(baseYear);
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
			}
		});
	}
	
	function delColumn(thisObj){
		var delObj = $(thisObj).closest(".name_box_wrap").find(".name_box");
		delObj.text("");
		delObj.removeAttr("deptcode");
	}
	
	function setGrid(){
		setGridConfig();
		setSeriesListData();
	}
	
	function setGridConfig(){
		var headerData = [
							{key:'chk', label:'chk', width:'5', align:'center', formatter:'checkbox', sort:false},
							{key:'SeriesCode', label:'<spring:message code="Cache.lbl_unitTaskCode"/>', width:'30', align:'center'}, // 단위업무 코드
							{key:'SeriesName', label:'<spring:message code="Cache.lbl_unitTaskName"/>', width:'30', align:'center'}, // 단위업무명
							{key:'DeptName',   label:'<spring:message code="Cache.lbl_apv_ManageDept"/>', width:'30', align:'center'}, // 처리과
							{key:'DeptCode',   label:'<spring:message code="Cache.lbl_apv_DeptCode"/>', width:'30', align:'center'} // 처리과
						];
		
		seriesHeaderData = headerData;
		ListGrid.setGridHeader(headerData);
	
		var configObj = {
			targetID: "searchGrid",
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
		//var deptCode = $("#deptNm").attr("deptcode") == undefined ? "" : $("#deptNm").attr("deptcode");
		var deptCode = '';
		if(RecordAdmin != "Y") deptCode = sessionObj["DEPTID"];
		var baseYear = $("#selSearchBaseYear").val();
		var searchWord = $("#searchWord").val();
		
		ListGrid.bindGrid({
			ajaxUrl: "/approval/user/getSeriesSearchList.do",
			ajaxPars: {
				"deptCode": deptCode,
				"baseYear": baseYear,
				"searchWord": searchWord
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
								if(item.SFLevel != "4"){
									$(".treeBodyTable tr").removeClass("selected");
									$(".treeBodyTable tr").eq(idx).find(".bodyNodeIndent").click();
								}else{//생성한 단위업무만 선택가능. 
									selectedItem.Code = item.SFCode;
									selectedItem.Name = item.SFName;
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
			showConnectionLine: true,				// 점선 여부
			relation:{
				parentKey: "SFParentCode",	// 부모 아이디 키
				childKey: "SFCode"			// 자식 아이디 키
			},
			persistExpanded: false,					// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
			persistSelected: false,					// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
			colGroup:[{
				key: "SFName",				// 컬럼에 매치될 item 의 키
				//label:"TREE",						// 컬럼에 표시할 라벨
				width: "490", 						// 부서명 말줌임하지 않고 전체 표시시킬 경우 주석해제(긴 부서가 없을때도 스크롤 생기는 문제 있음)
				align: "left",	
				indent: true,						// 들여쓰기 여부
				getIconClass: function(){			// indent 속성 정의된 대상에 아이콘을 지정 가능
					var iconNames = "folder, AXfolder, movie, img, zip, file, fileTxt, company".split(/, /g);
					var iconName = "";
					
					if(this.item.SFLevel == "4") {
						iconName = "AXfolder";
					} else {
						iconName = "folder"; 
					} 
					return iconName;
				},
				formatter:function(){
					var anchorName = $('<a />').attr('id', 'folder_item_'+this.item.SFCode);
					anchorName.text(this.item.SFName);
					
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
		var baseYear = $("#selTreeBaseYear").val();
		setGroupTreeConfig();
		
		$.ajax({
			url: "/approval/user/getSeriesSearchTreeData.do",
			type: "POST",
			data: {
				"baseYear": baseYear
			},
			async: false,
			success: function(data) {
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
		var baseYear = $("#selTreeBaseYear").val();
		setGroupTreeConfig();
		
		$.ajax({
			url: "/approval/user/getSeriesSearchTreeData.do",
			type: "POST",
			data: {
				"baseYear": baseYear
			},
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
	
	//조직도 팝업 호출
	function orgChartPopup(){
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap' />","/covicore/control/goOrgChart.do?type=C1&callBackFunc=searchPopupOrg_CallBack","1000px","580px","iframe",true,null,null,true);
	}
	
	function submitSeries(){
		var callBackFunc = CFN_GetQueryString("callBackFunc") == "undefined" ? "" : CFN_GetQueryString("callBackFunc");
		var checkList = ListGrid.getCheckedList(0);
		var idx = $("#tabList li").index($("#tabList li.active"));
		var pSeriesArr = [];
		
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
							"Code": item.SeriesCode,
							"Name": item.SeriesName,
							"BaseYear": $("#").val(),
							"DeptName": item.DeptName,
							"DeptCode": item.DeptCode
						}
						
						pSeriesArr.push(json);
					});
				}
				break;
			case 1:
				if(selectedItem == {}){
					Common.Inform('<spring:message code="Cache.lbl_apv_alert_selectRow" />');
				}else{
					var json = {
							"Code": selectedItem.Code,
							"Name": selectedItem.Name,
							"BaseYear": $("#selTreeBaseYear").val(),
							"DeptName": item.DeptName,
							"DeptCode": item.DeptCode
						}
						
						pSeriesArr.push(json);
				}
				break;
		}
	
		if(callBackFunc != ""){
			try{
				parent.window[callBackFunc].apply(parent.window, [pSeriesArr]);
				Common.Close();
			}catch (e) {
				coviCmn.traceLog(e);
			}
		}
	}
	
	function hasRecordAdmin(){
		$.ajax({
			url: '/approval/user/getRecordAdmin.do',
			type: 'POST',
			data: {'UserId': sessionObj.USERID},
			async: false,
			success: function(data){
				if(data.Cnt >0){
					RecordAdmin = 'Y';
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			},
		});
	}
	
	hasRecordAdmin();
	init();
</script>