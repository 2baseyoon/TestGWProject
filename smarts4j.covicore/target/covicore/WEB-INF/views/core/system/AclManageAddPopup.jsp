<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="EUC-KR"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<style>
	.AXPaging {
		width: 20px !important;
	}
	
	#searchArea .AXButton {
		margin-left: 5px;
	}
	
	#view .bodyNode > input[type=checkbox] {
		margin-left: 7px;
	}
	
	.AXTreeScrollBody, .AXTreeBody {
		height: 300px;
	}
</style>

<body>
	<div>
		<div id="searchArea">
			<span><spring:message code="Cache.lbl_Domain"/>&nbsp;</span> <!-- 도메인 -->
			<select id="selectDomain" class="AXSelect W100"></select>
		</div>
		<div style="padding: 15px;">
			<div id="view"></div>
		</div>
		<div align="center">
			<input type="button" id="addBtn" class="AXButton red" value="<spring:message code="Cache.btn_Add"/>"/> <!-- 추가 -->
			<input type="button" id="closeBtn" class="AXButton" value="<spring:message code="Cache.btn_Close"/>"/> <!-- 닫기 -->
		</div>
	</div>
</body>

<script>
	(function(param){
		
		var _view;
		
		var treeView = function(){
			
			if (!(this instanceof arguments.callee)) return new arguments.callee();
			
			var tree = new coviTree();
			
			var setTree = function(){
				var treeBody = {
					oncheck: function(idx){
						if (event.target.checked) {
							var _list = this.list;
							var recursive = function( target ){
								var rtn = [ target ];
								_list.filter(function( _cur ){ 
									return _cur.pno ===  target.no 
								}).forEach(function(item){
									rtn = rtn.concat( recursive( item ) )
								});
								return rtn;
							}
							
							// 상위 노드 체크 시 하위 노드도 체크
							var itemIndex = $("#"+idx).prev("a").attr("id").split(/_AX_/g).last();
							recursive( this.list[itemIndex] ).forEach(function(item){
								$("#view").find("#view_treeCheckbox_" + item.no).get(0).checked = event.target.checked;
							});
						}
					}
				};
		    	
				$.ajax({
					url: "/covicore/aclManage/getAddList.do",
					type: "POST",
					data: {
						  objectType:	param.objectType
						, subjectType:	param.subjectType
						, subjectCode:	param.subjectCode
						, folderType:	$("#folderType").val()
						, domain:		$("#selectDomain").val()
						, isAdmin:		$("#selectIsAdmin").val()
					},
					success: function(data){
						if(data.status === "SUCCESS"){
							tree.setTreeList("view", data.list, "no", "220", "left", true, false, treeBody);					
						}
					},
					error: function(response, status, error){
						CFN_ErrorAjax("/covicore/aclManage/getAddList.do", response, status, error);
					}
				});
			}
			
			var setFolderType = function(){
				$.ajax({
					url: "/covicore/aclManage/getFolderType.do",
					type: "POST",
					data: "",
					async: false,
					success: function(data){
						if(data.status === "SUCCESS"){
							if(data.list.length > 0){
								var optionList = [];
								
								optionList.push({optionValue: "", optionText: "<spring:message code='Cache.lbl_Whole'/>"}); // 전체
								
								$(data.list).each(function(idx, item){
									var option = new Object();
									
									option.optionValue = item.ObjectType;
									option.optionText = item.ObjectName;
									
									optionList.push(option);
								});
								
								$("#folderType").bindSelect({
									options: optionList,
									setValue: param.folderType,
									onchange: function(){
										setTree();
									}
								});
							}
						}else{
							Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
						}
					},
					error: function(response, status, error){
						CFN_ErrorAjax("/covicore/aclManage/getFolderType.do", response, status, error);
					}
				});
			}
			
			var setComponent = function(){
				if (param.objectType === "MN") {
					$("#view").parent("div").css({"height": "305px", "overflow-y": "hidden"});
					$("#view").css({"height": "300px"});
					$("#searchArea").append($("<span/>", {"text": "<spring:message code='Cache.lbl_User'/>/<spring:message code='Cache.lbl_admin'/> "}))
									.append($("<select/>", {"id": "selectIsAdmin", "class": "AXSelect W100"}))
									.append($("<input/>", {"id": "btnTreeOpenAll", "class": "AXButton", "type": "button", "value": "<spring:message code='Cache.lbl_OpenAll'/>"})) // 전체열기
									.append($("<input/>", {"id": "btnTreeCloseAll", "class": "AXButton", "type": "button", "value": "<spring:message code='Cache.lbl_CloseAll'/>"})); // 전체닫기
					
					$("#selectIsAdmin").bindSelect({
						reserveKeys: {optionValue: "value", optionText: "name"},
						setValue: param.isAdmin,
						options: [
							  {"name": "<spring:message code='Cache.lbl_User'/>", "value": "N"}
							, {"name": "<spring:message code='Cache.lbl_admin'/>", "value": "Y"}
						],
						onchange: function(){
							setTree();
						}
					});
				} else if (param.objectType === "FD") {
					$("#searchArea").append($("<span/>", {"text": "<spring:message code='Cache.lbl_FolderType'/> "})) // 폴더 유형
									.append($("<select/>", {"id": "folderType", "class": "AXSelect W100"}))
									.append($("<input/>", {"id": "btnTreeOpenAll", "class": "AXButton", "type": "button", "value": "<spring:message code='Cache.lbl_OpenAll'/>"})) // 전체열기
									.append($("<input/>", {"id": "btnTreeCloseAll", "class": "AXButton", "type": "button", "value": "<spring:message code='Cache.lbl_CloseAll'/>"})); // 전체닫기
	
					setFolderType();
				}
				
				setEvent();
			}
			
			var setEvent = function(){
				// 트리 전체 열기
				$("#btnTreeOpenAll").off("click").on("click", function(){
					tree.expandAll();
				});
				
				// 트리 전체 닫기
				$("#btnTreeCloseAll").off("click").on("click", function(){
					tree.collapseAll();
				});
			}
			
			this.getSelectedList = function(){
				return tree.getCheckedTreeList('checkbox');
			}
			
			this.refresh = function(){
				setTree();
			}
			
			this.init = function(){
				setComponent();
				setTree();
			}
		}();
		
		var gridView = function(){
			
			if (!(this instanceof arguments.callee)) return new arguments.callee();
			
			var grid = new coviGrid();
			
			var setGridConfig = function(){
				grid.setGridHeader([
					{key:'chk',			label:'chk', 	width:'3',	align:'center',	hideFilter : 'Y', formatter: 'checkbox'},
					{key:'DisplayName',	label:'Name',	width:'20', align:'left', 	hideFilter : 'Y'}
				]);
				
				grid.setGridConfig({
					targetID		: "view",
					width			: "500px",
					height			: "auto",
					paging			: true,
					sort			: true,
					overflowCell	: [],
					body			: {}
				});
			}
			
			var renderGrid = function(){
				grid.bindGrid({
					ajaxUrl: "/covicore/aclManage/getAddList.do",
					ajaxPars: {
						  objectType:	param.objectType
						, subjectType:	param.subjectType
						, subjectCode:	param.subjectCode
						, domain:		$("#selectDomain").val()
						, folderType:	$("#folderType").val()
						, searchText:	$("#searchText").val()
					}
				});
			}
			
			var setComponent = function(){
				$("#searchArea").append($("<span/>", {"text": "Name "}))
								.append($("<input/>", {"type": "text", "id": "searchText", "class": "AXInput"}))
								.append($("<input/>", {"type": "button", "id": "searchBtn", "class": "AXButton", "value": "<spring:message code='Cache.btn_search'/>"})); // 검색
					
				setEvent();
			}
			
			var setEvent = function(){
				// 검색
				$("#searchBtn").off("click").on("click", function(){
					renderGrid();
				});
				
				$("#searchText").off("keypress").on("keypress", function(e){
					if (e.keyCode === 13) renderGrid();
				});
			}
			
			this.getSelectedList = function(){
				return grid.getCheckedList(0);
			}
			
			this.refresh = function(){
				renderGrid();
			}
			
			this.init = function(){
				setComponent();
				setGridConfig();
				renderGrid();
			}
		}();
		
		var setComponent = function(){
			coviCtrl.renderCompanyAXSelect('selectDomain', Common.getSession("lang"), '', '', '', param.domain);
		}
		
		var setEvent = function(){
			// 추가
			$("#addBtn").off("click").on("click", function(){
				addAclInfo();
			});
			
			// 닫기
			$("#closeBtn").off("click").on("click", function(){
				Common.Close();
			});
			
			// 새로고침
			$("#selectDomain").off("change").on("change", function(){
				_view.refresh();
			})
		}
		
		var addAclInfo = function(){
			var selList = _view.getSelectedList();
			
			if (selList.length > 0) {
				var objIDList = _view.getSelectedList().map(function(item){
					return item.ObjectID;
				}).join(";");
				
				$.ajax({
					url: "/covicore/aclManage/addAclInfo.do",
					type: "POST",
					data: {
						  objectType:	param.objectType
						, subjectType:	param.subjectType
						, subjectCode:	param.subjectCode
						, objectIDList:	objIDList
						, domain:		param.domain
					},
					success: function(data){
						if(data.status === "SUCCESS"){
							parent.Common.Inform("<spring:message code='Cache.msg_successSave'/>", "Information", function(){ // 저장에 성공했습니다.
								parent.aclManage.searchAclData(1);
								parent.aclManage.searchAclDetail(parent.aclManage.gridAcl.getSelectedItem().item, 1);
								Common.Close();
							});
						}else{
							Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
						}
					},
					error: function(response, status, error){
						CFN_ErrorAjax("/covicore/aclManage/addAclInfo.do", response, status, error);
					}
				});
			} else {
				Common.Inform("<spring:message code='Cache.msg_apv_003'/>"); // 선택된 항목이 없습니다.
			}
		}
		
		var init = function(){
			setComponent();
			setEvent();
			
			if (["MN", "FD"].includes(param.objectType)) {
				_view = treeView;
			} else if(["PT", "CU"].includes(param.objectType)) {
				_view = gridView;
			}
			
			_view.init();
		}
		
		init();
	})({
		  objectType: "${objType}" // MN, FD, PT, CU
		, folderType: "${folderType}"
		, subjectType: "${sType}"
		, subjectCode: "${sCode}"
		, isAdmin: "${isAdmin}"
		, domain: "${domain}"
	})
</script>