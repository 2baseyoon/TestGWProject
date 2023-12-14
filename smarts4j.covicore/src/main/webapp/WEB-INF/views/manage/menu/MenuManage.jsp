<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.baseframework.util.SessionHelper"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.SessionHelper" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>

<%
String resourceVersion ="";
%>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_menuManage'/></h2>	<!-- 메뉴관리 -->
    <div class="searchBox02">
        <span><input type="text" id="searchText"><button type="button" class="btnSearchType01"  id="icoSearch"><spring:message code='Cache.btn_search' /></button></span> <!-- 검색 -->
    </div>
</div>		


<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.treetable.js<%=resourceVersion%>"></script>

<div class="cRContBottom mScrollVH ">
<form>
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<select name="" class="selectType02" id="selectIsAdmin"></select>
				<covi:admin><a class="btnTypeDefault btnPlusAdd" onclick="addMenu();"><spring:message code="Cache.btn_Add"/></a></covi:admin>
				<a class="btnTypeDefault"  onclick="openAllMenu()"><spring:message code="Cache.lbl_OpenAll"/></a>
				<a class="btnTypeDefault"  onclick="closeAllMenu()"><spring:message code="Cache.lbl_CloseAll"/></a>
				<a class="btnTypeDefault" id="allExport"  onclick="exportMenuCallBack(-1, 'root')"><spring:message code= "Cache.lbl_Export"/></a>
				<a class="btnTypeDefault"  onclick="applyCache()"><spring:message code="Cache.btn_CacheApply"/></a>
			</div>
			<div class="buttonStyleBoxRight">
				<div class="chkStyle10"><input type="checkbox" class="check_class" id="chk_IsAll" value="Y" ><label for="chk_IsAll"><span class="s_check"></span><spring:message code='Cache.btn_All' /></label> </div>
				<button class="btnRefresh" type="button" href="#"  id="folderRefresh"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="sadminTree" class="treeBody"></div>
		</div>	
	</div>		
</form>
</div>
<script>
	var g_domain ;
	initContent();
	
	function initContent(){
		g_domain = confMenu.domainId ;
		
		if(g_domain != 0) $("#allExport").hide();
		else  $("#allExport").show();
		
		setSelectBox();
		// 폴더 새로고침
		$("#folderRefresh, #chk_IsAll").click(function(){
			initTreeData();
		});
		
		
		//검색
		$("#searchText").on( 'keydown',function(){
			if(event.keyCode=="13"){
				$('#icoSearch').trigger('click');

			}
		});	
		$("#icoSearch").on( 'click',function(){
			var keyword = $("#searchText").val();
			if (keyword =="") {
				initTreeData();
				return;
			}
			coviCtrl.treeTableCollapseAll('sadminTree');
			$( '#treetable_sadminTree tr').removeClass("selected");
			var bFind = false;
			$( '.folder' ).each( function(idx, v) {
				if ($(v).text().indexOf(keyword)>=0){
					bFind = true;
					$(v).closest("tr").addClass("selected");
					var sortPath = $(v).closest("tr").attr("data-sortpath")
					var sortPathArry = sortPath.split(";");//data-tt-id
					var ttId = "";
					for (var i=0; i < sortPathArry.length; i++){
						if (i>0) ttId += "-";
						ttId += sortPathArry[i];
						$( '#treetable_sadminTree tr[data-tt-id="'+ttId+'"] .indenter a').trigger('click');
					}
				}
			});

			if (bFind == false){
				Common.Inform("<spring:message code='Cache.msg_apv_112'/>");
			}
		});
		
	}
	
	function setSelectBox() {
		
		$("#selectIsAdmin").bindSelect({
			reserveKeys : {
				optionValue : "value",
				optionText : "name"
			},
			options : [ 
			            {
							"name" : "<spring:message code='Cache.lbl_User'/>",
							"value" : "N"
						}, 
						{
							"name" : "<spring:message code='Cache.lbl_admin'/>",
							"value" : "Y"
						} 
			],
			onchange: function(){
				initTreeData();
	        }
		});
		initTreeData();
	}
	
 	function selectRenderComplete(){
 		initTreeData();
	}
	
	function selectOnchange($this){
		g_domain = $this.value;
		
		initTreeData();
	}
	
	function initTreeData(){
		$.ajax({
			type:"POST",
			data:{
				"domain" : g_domain,
				"isAdmin" : $('#selectIsAdmin').val(),
				"isAll":$("#chk_IsAll").prop("checked")?"Y":"N"
			},
			async : false,
			url:"/covicore/manage/menu/getList.do",
			success:function (data) {
				if(data.list != undefined){
					var config = {
							target : "sadminTree",
							sortPathKey : "SortPath",
							drag : "true",
							checkBox : "false",
							useControl :"up,down<%=(!SessionHelper.getSession("isEasyAdmin").equals("Y")?",add,remove,move":"")%>"+(g_domain === "0"?",export":""),
							cols : [
							        {colKey : "DisplayName", colName : "<spring:message code='Cache.lbl_CollabName'/>", colWidth:"400px"}, //명칭
							        {colKey : "MenuID", colName : "MenuID", colWidth:"60px"},
							        {colKey : "MenuTypeName", colName : "<spring:message code='Cache.lbl_menuType'/>", colWidth:"140px"}, // 메뉴유형
							        {colKey : "BizSectionName", colName : "<spring:message code='Cache.lbl_BizSection'/>", colWidth:"200px"}, //업무구분
							        {colKey : "IsUse", colName : "<spring:message code='Cache.IsUse_Y'/>", colWidth:"60px", eventBind: "false",
							        	formatter: function() { return formatSwitch(this); }
									}, //사용
							        {colKey : "ModifyDate", colName : "<spring:message code='Cache.lbl_ModifyDate'/>" + Common.getSession("UR_TimeZoneDisplay"), colWidth:"120px", formatter: function(){ //수정일
										return (this.ModifyDate!=null?CFN_TransLocalTime(this.ModifyDate).substring(0,10):"")	}}
							        ],
							dataAttrs : ["MenuID","MemberOf","MenuPath","SortKey","SortPath","BizSection"],  
					        clicked : "menuPopup",
					        upClicked : "moveCallBack",
					        downClicked : "moveCallBack",
					        dropped : "moveCallBack",
					        addClicked : "addCallBack",
					        removeClicked : "removeCallBack",
					        moveClicked : "moveMenuCallBack",
							exportClicked: "exportMenuCallBack"
						};
					}
					
					$('#sadminTree').empty();
					coviCtrl.makeTreeTable(data.list, config);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/menu/getList.do", response, status, error);
			}
		});
	}
	
	function formatSwitch(pObj){
		var param = pObj;
		param.on = 'Y'; param.off = 'N';
		param.defVal = param.IsUse;
		param.retVal = param.MenuID;
		return coviCmn.getCoviSwitch('switch_'+param.MenuID, param, 'updateIsUse');
	}
	
	function moveCallBack(rowArray){
		$.ajax({
			type: "POST",
			data: {
				"rows" : encodeURIComponent(JSON.stringify(rowArray)),
				"domainID" : g_domain
			},
			url: "/covicore/manage/menu/move.do",
			success: function(res){
				if (res.result !== "ok") {
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/menu/move.do", response, status, error);
			}
		});
	}
	
	function removeCallBack(id){
		var $rows = new Array();
		var $row = $("tr[data-tt-id=" + id + "]");

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
		
		var domainID = g_domain;
		
		Common.Confirm( Common.getDic("msg_RUDelete"), "Confirmation Dialog", function (confirmResult) {
    		if (confirmResult) {
				$.ajax({
					type:"POST",
					data:{
						"removeMenuIDs" : removedMenuIDs,
						"domainID" : domainID
					},
					url:"/covicore/manage/menu/remove.do",
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
						CFN_ErrorAjax("/covicore/manage/menu/getmenu.do", response, status, error);
					}
				});
			}
		});
		
	}
	
	function moveMenuCallBack(menuId, sortPath){
		var url = "/covicore/manage/menu/goMoveMenuPopup.do?menuId=" + menuId + "&sortPath=" + escape(sortPath) + "&domain=" + g_domain + "&isAdmin=" + $('#selectIsAdmin').val();
		
		parent.Common.open("","moveMenuCallBack","<spring:message code='Cache.lbl_MoveMenu'/>", url,"550px","450px","iframe",true,null,null,true); //메뉴이동
	}
	
	function exportMenuCallBack(menuId, sortPath){
		
		var url = "/covicore/manage/menu/goExportMenuPopup.do"
				+ "?menuId=" + menuId
				+ "&sortPath=" + (sortPath == 'root' ? $("#selectIsAdmin").val() : escape(sortPath))
				+ "&domainId=" + g_domain
				+ "&isAll=" + ($("#chk_IsAll").prop("checked")?"Y":"N");
		
		parent.Common.open("", "exportMenuCallBack", "<spring:message code='Cache.lbl_exportMenu'/>", url, "550px", "600px", "iframe", true, null, null, true); // 메뉴 내보내기
	}
	
	function addCallBack(menuId, ttId){
		/*
		1. elm이 null 또는 빈값인 경우 root level에 생성
		2. 그렇지 않은 경우 특정 node의 하위 node로 생성
		*/
		
		/*
		g_domain = '0';
		menuId
		ttId
		mode
		*/
		var url = '/covicore/manage/menu/goMenuPopup.do?';
		url += 'domainId=' + g_domain + '&';
		url += 'isAdmin=' + $("#selectIsAdmin").val() + '&';
		url += 'menuId=' + menuId + '&';
		url += 'ttId=' + ttId + '&';
		url += 'bizSection=' + $("tr[data-menuid=" + menuId + "]").attr("data-bizsection") + '&';
		url += 'mode=add&';
		url += "popupTargetID=addMenuPopup";
		if($("[data-memberof=" + menuId + "]").length > 0) url += '&hasChild=Y';
		
		Common.open("", "addMenuPopup", "<spring:message code='Cache.lbl_AddMenu'/>", url, "700px", "685px", "iframe", true, null, null, true); // 메뉴 추가
	}
	
	function menuPopup(menuId, ttId){
		var url = '/covicore/manage/menu/goMenuPopup.do?';
		url += 'domainId=' + g_domain + '&';
		url += 'menuId=' + menuId + '&';
		url += 'ttId=' + ttId + '&';
		url += 'mode=modify&';
		url += "popupTargetID=addMenuPopup";
		if($("[data-memberof=" + menuId + "]").length > 0) url += '&hasChild=Y';
		
		Common.open("", "addMenuPopup", "<spring:message code='Cache.lbl_ModifyMenu'/>", url, "700px", "<%=(SessionHelper.getSession("isEasyAdmin").equals("Y")?"300px":"685px")%>", "iframe", true, null, null, true);
	}
	
	function addMenu(){
		var url = '/covicore/manage/menu/goMenuPopup.do?';
		url += 'domainId=' + g_domain + '&';
		url += 'isAdmin=' + $("#selectIsAdmin").val()  + '&';
		url += 'mode=add&';
		url += "popupTargetID=addMenuPopup";
		if($("[data-memberof=" + menuId + "]").length > 0) url += '&hasChild=Y';
		
		Common.open("", "addMenuPopup", "<spring:message code='Cache.lbl_AddMenu'/>", url, "700px", "685px", "iframe", true, null, null, true);
	}
	
	
	function openAllMenu(){
		coviCtrl.treeTableExpandAll('sadminTree');
	}
	
	function closeAllMenu(){
		coviCtrl.treeTableCollapseAll('sadminTree');
	}
	
	// 사용 스위치 버튼에 대한 값 변경
	function updateIsUse(pMenuID, pIsUse, pTarget){
		$.ajax({
			type:"POST",
			data:{
				"CN_ID" : pMenuID,
				"IsUse" : pIsUse
			},
			url:"/covicore/manage/menu/updateisuseadminmenu.do",
			success:function (data) {
				if(data.result === 'ok'){
					Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
					if (typeof data.object == 'object' && data.object instanceof Array && data.object.length > 0 && pIsUse == 'N') {
						$.each(data.object, function(idx, el){
							$("#switch_"+el).val($("#switch_"+el).attr("off_value"))
							$("a[data-return-value="+el+"]").removeClass("on");
						});
					}
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
					if (pIsUse == 'Y') {
						$("#switch_"+pMenuID).val($("#switch_"+pMenuID).attr("off_value"));
						$(pTarget).removeClass("on");
					} else {
						$("#switch_"+pMenuID).val($("#switch_"+pMenuID).attr("on_value"));
						$(pTarget).addClass("on");
					}
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
			data:{"domainID" : g_domain},
			url:"/covicore/manage/menu/reloadCache.do",
			success:function (data) {
				if(data.result == "ok"){
					coviCmn.clearCache(true);
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
	
	window.addEventListener('message', function(e){ 
		switch(e.data.functionName) {
		case "selectAddOrModifyMenu":
			selectAddOrModifyMenu(e.data.params);
			break;
		}
	});
	// 추가 및 수정을 한 다음, 트리에서 추가 수정된 메뉴까지 펼쳐서 보여주는 메서드
	function selectAddOrModifyMenu(menuPath) {
		var pathList = menuPath.split(";");
		pathList.splice(pathList.length - 1);
		
		pathList.forEach(menuID => $("tr[data-menuid=" + menuID + "]").find("a[title='Expand']").trigger("click"));
	}

	
	//# sourceURL=MenuManage.jsp
</script>