<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit">메뉴 관리</span>
	<a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a>
</h3>
<form>
	<div style="width:100%;min-height: 500px">
		<div id="topitembar_1" class="topbar_grid">
			<input type="button" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"class="AXButton BtnRefresh"/>
			<input type="button" value="<spring:message code="Cache.btn_Add"/>" onclick="addMenu();" class="AXButton BtnAdd" />
			<!-- <input type="button" value="<spring:message code="Cache.btn_delete"/>" onclick="deleteMenu();"class="AXButton"/>  -->
			<!-- 미구현 -->
			<!-- <input type="button" value="위로" onclick="moveUp();"class="AXButton"/> -->
			<!-- <input type="button" value="아래로" onclick="moveDown();"class="AXButton"/> -->
			<!-- <input type="button" value="이동" onclick="moveMenu();"class="AXButton"/> -->
			<input type="button" value="<spring:message code="Cache.lbl_OpenAll"/>" onclick="openAllMenu();"class="AXButton"/>
			<input type="button" value="<spring:message code="Cache.lbl_CloseAll"/>" onclick="closeAllMenu();"class="AXButton"/>
			<input type="button" value="<spring:message code="Cache.btn_CacheApply"/>" onclick="applyCache();"class="AXButton"/>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<span class=domain>
				<spring:message code="Cache.lbl_Domain"/>&nbsp;
				<select class="AXSelect" id="selectDomain"></select>
			</span>	
			사용자/관리자&nbsp;
				<select name="" class="AXSelect" id="selectIsAdmin"></select>
			<!-- <input type="button" value="조회" onclick="initTreeData();"class="AXButton"/> -->
			
			
			<!-- 
			<label>
				<spring:message code="Cache.lbl_SearchCondition"/>&nbsp;
				<select name="" class="AXSelect" id="selectSearch"></select>
				<input type="text" id="searchInput"  class="AXInput" />&nbsp;
			</label>
			<label>
				<spring:message code="Cache.lblSearchScope"/>&nbsp;<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
				<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 85px" class="AXInput" />
				<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig();" class="AXButton"/>
			</label>
			 -->
		</div>
		<div id="MenuTree"></div>
		<div id="customTree"></div>
	</div>
</form>

<script>
	var bizSection = CFN_GetQueryString("bizSection") == 'undefined'? '' : CFN_GetQueryString("bizSection");
	var g_domain = '<%=egovframework.baseframework.util.SessionHelper.getSession("DN_ID")%>';
	var g_isAdmin = 'N';
	
	initContent();
	
	function initContent(){
		setSelectBox();
	}
	
	function setSelectBox() {
		
		coviCtrl.renderDomainAXSelect('selectDomain', 'ko', 'selectOnchange', 'selectRenderComplete', g_domain);
		$("#selectIsAdmin").bindSelect({
			reserveKeys : {
				optionValue : "value",
				optionText : "name"
			},
			options : [ 
			            {
							"name" : "사용자",
							"value" : "N"
						}, 
						{
							"name" : "관리자",
							"value" : "Y"
						} 
			],
			onchange: function(){
				g_isAdmin = this.value;
				
				initTreeData();
	        }
		});
	}
	
 	function selectRenderComplete(){
 		initTreeData();
	}
	
	function selectOnchange($this){
		g_domain = $this.value;
		
		initTreeData();
	}
	
	function initTreeData(){
		
		$('#customTree').empty();
		
		$.ajax({
			type:"POST",
			data:{
				"domain" : g_domain,
				"isAdmin" : g_isAdmin
			},
			async: false,
			url:"/covicore/menu/getList.do",
			success:function (data) {
				/*
				if(typeof myGridTree != "undefined"){
					//myGridTree.setTree(data.list);
					//스위치 재바인딩
					//coviInput.setSwitch();
				}*/
				
				if(data.list != undefined){
					var config = {
							target : "customTree",
							sortPathKey : "SortPath",
							drag : "true",
							checkBox : "false",
							useControl : "up,down,add,remove,move",
							cols : [
							        {colKey : "DisplayName", colName : "명칭"},
							        {colKey : "MenuID", colName : "메뉴ID"},
							        {colKey : "MenuTypeName", colName : "메뉴유형"},
							        {colKey : "BizSectionName", colName : "업무구분"},
							        {colKey : "IsUse", colName : "사용여부"},
							        {colKey : "ModifyDate", colName : "수정일" + Common.getSession("UR_TimeZoneDisplay"), formatter: function(){
										return CFN_TransLocalTime(this.ModifyDate);
									}
							        }
							        ],
							dataAttrs : ["MenuID","MemberOf","MenuPath","SortKey","SortPath", "BizSection"],  
					        doubleClicked : "menuPopup",
					        upClicked : "moveCallBack",
					        downClicked : "moveCallBack",
					        dropped : "moveCallBack",
					        addClicked : "addCallBack",
					        removeClicked : "removeCallBack",
					        moveClicked : "moveMenuCallBack"
						};
					
					if (g_domain === '0') {
						config.useControl = "up,down,add,remove,move,export";
						config["exportClicked"] = "exportMenuCallBack";
					}
					
					coviCtrl.makeTreeTable(data.list, config);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/menu/getList.do", response, status, error);
			}
		});
	}
	
 	function moveCallBack(rowArray){
		$.ajax({
			type: "POST",
			data: {
				"rows" : encodeURIComponent(JSON.stringify(rowArray)),
				"domainID" : $("#selectDomain").val()
			},
			url: "/covicore/menu/move.do",
			success: function(res){
				if (res.result !== "ok") {
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/menu/move.do", response, status, error);
			}
		});
	}
	
	function removeCallBack(id){
		//$("tr[data-tt-id=" + id + "]").remove();
		var $rows = new Array();
		var $row = $("tr[data-tt-id=" + id + "]");
		//remove 될 대상 추출
		var removedMenuIDs = '';
		removedMenuIDs += $row.attr('data-menuid') + ',';
		$rows.push($row);
		$row.nextAll('tr').each(function(){
			var parent_tt_id = $(this).attr('data-tt-parent-id');
			if(parent_tt_id != undefined && parent_tt_id.substring(0,id.length) == id){
				removedMenuIDs += $(this).attr('data-menuid') + ',';
				$rows.push($(this));
			}
		});
		
		var lastChar = removedMenuIDs.slice(-1);
		if (lastChar == ',') {
			removedMenuIDs = removedMenuIDs.slice(0, -1);
		}
		
		var domainID = $("#selectDomain").val();
		
		Common.Confirm( Common.getDic("msg_RUDelete"), "Confirmation Dialog", function (confirmResult) {
    		if (confirmResult) {
				$.ajax({
					type:"POST",
					data:{
						"removeMenuIDs" : removedMenuIDs,
						"domainID" : domainID
					},
					url:"/covicore/menu/remove.do",
					success : function (res) {
						if(res.result == "ok"){
							for (i = 0; i < $rows.length; i++) { 
							    $rows[i].remove();
							}
							
						} else {
							Common.Error("Fail.");
						}
					},
					error : function(response, status, error){
						CFN_ErrorAjax("/covicore/menu/getmenu.do", response, status, error);
					}
				});
			}
		});
		
	}
	
	function moveMenuCallBack(menuId, sortPath){
		var url = "/covicore/menu/goMoveMenuPopup.do?menuId=" + menuId + "&sortPath=" + escape(sortPath) + "&domain=" + $('#selectDomain').val() + "&isAdmin=" + $('#selectIsAdmin').val();
		
		parent.Common.open("","moveMenuCallBack","메뉴 이동", url,"550px","400px","iframe",false,null,null,true);
	}
	
	function exportMenuCallBack(menuId, sortPath){
		var url = "/covicore/menu/goExportMenuPopup.do"
				+ "?menuId=" + menuId
				+ "&sortPath=" + escape(sortPath)
				+ "&domainId=" + $('#selectDomain').val();
		
		parent.Common.open("", "exportMenuCallBack", "<spring:message code='Cache.lbl_exportMenu'/>", url, "550px", "400px", "iframe", false, null, null, true); // 메뉴 내보내기
	}
	
	function addCallBack(menuId, ttId){
		/*
		1. elm이 null 또는 빈값인 경우 root level에 생성
		2. 그렇지 않은 경우 특정 node의 하위 node로 생성
		*/
		
		/*
		g_domain = '0';
		g_isAdmin = 'N';
		menuId
		ttId
		mode
		*/
		var url = '/covicore/menu/goMenuPopup.do?';
		url += 'domainId=' + g_domain + '&';
		url += 'isAdmin=' + g_isAdmin + '&';
		url += 'menuId=' + menuId + '&';
		url += 'ttId=' + ttId + '&';
		url += 'bizSection=' + $("tr[data-menuid=" + menuId + "]").attr("data-bizsection") + '&';
		url += 'mode=add&';
		url += "popupTargetID=addMenuPopup";
		
		Common.open("","addMenuPopup","메뉴 추가",url,"650px","610px","iframe",true,null,null,true);
	}
	
	function menuPopup(menuId, ttId){
		var url = '/covicore/menu/goMenuPopup.do?';
		url += 'domainId=' + g_domain + '&';		
		url += 'menuId=' + menuId + '&';
		url += 'ttId=' + ttId + '&';
		url += 'mode=modify&';
		url += "popupTargetID=addMenuPopup";
		//url += 'isAdmin=' + g_isAdmin + '&';
		
		Common.open("","addMenuPopup","메뉴 수정",url,"650px","610px","iframe",true,null,null,true);
	}
	
	function Refresh(){
		window.location.reload();
	}
	
	function addMenu(){
		var url = '/covicore/menu/goMenuPopup.do?';
		url += 'domainId=' + g_domain + '&';
		url += 'isAdmin=' + g_isAdmin + '&';		
		url += 'mode=add&';
		url += "popupTargetID=addMenuPopup";
		
		Common.open("","addMenuPopup","메뉴 추가",url,"650px","610px","iframe",true,null,null,true);
	}
	
	function deleteMenu(){
		var deleteObject = myGridTree.getCheckedList(0);
		if(deleteObject.length == 0 || deleteObject == null){
			Common.Inform("<spring:message code='Cache.msg_CheckDeleteObject'/>");
			return false;
		}else{
			/*
			1. 해당 메뉴의 다국어 비사용 처리 - 미구현
			2. 하위 메뉴의 다국어 비사용 처리 - 미구현
			3. 해당 메뉴 삭제 - 구현
			4. 하위 메뉴 삭제 - 미구현
			*/
			
			var deleteSeq = "";
			
			for(var i=0; i < deleteObject.length; i++){
				if(i==0){
					deleteSeq = deleteObject[i].CN_ID;
				}else{
					deleteSeq = deleteSeq + "," + deleteObject[i].CN_ID;
				}
			}
			
			$.ajax({
				type:"POST",
				data:{
					"DeleteData" : deleteSeq
				},
				url:"menumanage/deleteadminmenu.do",
				success:function (data) {
					window.location.reload();
				},
				error:function (error){
					Common.Error(error.message);
				}
			});
		}
	}
	
	function openAllMenu(){
		coviCtrl.treeTableExpandAll('customTree');
	}
	
	function closeAllMenu(){
		coviCtrl.treeTableCollapseAll('customTree');
	}
	
	// 사용 스위치 버튼에 대한 값 변경
	function updateIsUse(id){
		var now = new Date();
		var isUseValue = $("#AXInputSwitch_ADMN_IsUse_" + id).val();
		
		$.ajax({
			type:"POST",
			data:{
				"CN_ID" : id,
				"IsUse" : isUseValue
			},
			url:"menumanage/updateisuseadminmenu.do",
			success:function (data) {
				if(data.result == "ok"){
					//toast.push("정상처리되었습니다.");
					window.location.reload();
				}
			},
			error:function (error){
				Common.Error(error.message);
			}
		});
		
	}
	
	/*캐쉬적용*/
	function applyCache(){

		$.ajax({
			type:"POST",
			data:{"domainID" : $("#selectDomain").val()},
			url:"/covicore/menu/reloadCache.do",
			success:function (data) {
				if(data.result == "ok"){
					coviCmn.clearCache(true, true);
					Common.Inform(Common.getDic("msg_Processed"),"Information",function(){
						location.reload();
		    		});
				}
			},
			error:function (error){
				Common.Error(error.message);
			}
		});
		
	}

	
	//# sourceURL=MenuManage.jsp
</script>