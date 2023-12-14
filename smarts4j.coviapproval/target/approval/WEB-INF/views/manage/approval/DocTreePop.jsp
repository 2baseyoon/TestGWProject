<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@page import="egovframework.coviframework.util.RedisDataUtil"%>
<!DOCTYPE html>
<%
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<head>
	<title></title>
	<!--CSS Include Start -->
	<jsp:include page="/WEB-INF/views/cmmn/PopupInclude.jsp"></jsp:include>
	<style>
		.appTree { height: 100%; }
		.AXTabsLarge {padding-top:0px;}
		.AXTabsTray{
			border-bottom : 0px;
		}
		.appTree .treeBodyTable input{
			margin-left: 0px !important;
		    border: 0;
		}
	</style>

	<!--JavaScript Include Start -->
	<script type="text/javascript" src="/approval/resources/script/user/common/ApprovalUserCommon.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Jsoner/Jsoner.0.8.2.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/Controls/covision.orgchart.js<%=resourceVersion%>"></script>
	
<script type="text/javascript">    
    var _strdomainCode = "${param.domainCode}";
    var _openType = "${param.openType}";
    var _EntName = Base64.b64_to_utf8("${param.EntName}");
    var chkObj = {};
    var ListGrid = new coviGrid();
	var myTree01 = new coviTree();
	var FavoritesGrid = new coviGrid();
	var Treebody = {
			onclick:function(){
				//onclickTree();				
			},
			ondblclick:function(){
			},
			oncheck:function(idx, item){ //[Function] 트리 체크박스클릭시 함수연결
			    var treeObj = myTree01.getCheckedTreeList("radio");			
				var id = treeObj[0].no;
				var name = treeObj[0].nodeName;
			    onRadioChecked(id, name);
			}
	};
	
	function setGridHeader(){
		var headerData = '';
		headerData =[
			{key:'chk', label:'선택', width:'30', align:'center',
				formatter:function () {
					return '<input type="radio" name="treeRadio" onClick="onRadioChecked(\''+this.item.DocClassID+'\', \''+this.item.ClassName+'\')"/>';
				}
			},
			{key:'ParentDocClassName', label:'문서분류', width:'50', align:'left', sort:false},
			{key:'ClassName',  label:'기능명칭', width:'80', align:'left', sort:false}
		];
		ListGrid.setGridHeader(headerData);
	}
	
    $(document).ready(function(){
		if(_openType != "manager"){
		    $("#ClassTab [value=Favorites]").show();
		    $("a[name=btnFavAdd]").show();
			getFavoritesGridListData();
		}
		
		setGrid();
		getTreeDocClassList();
	    $(".btnSearchType01").on('click', function(){
			onClickSearchBtn();
		});
	});
    
    function getTreeDocClassList(){
    	var EntCode = _strdomainCode;
		//호출
		$.ajax({
			type:"POST",
			async:false,
			data:{
				"EntCode" : EntCode
			},
			url:"/approval/manage/getFolderPopup.do",
			
			success:function (data) {			
				if(data.result == "ok"){
					if(data.list.length > 0){
						myTree01.setTreeList("coviTreeTarget01", data.list, "nodeName", "220", "left", false, true, Treebody, "ic_folder", "AXTree_none folder_tree");
											
						//트리 모두확장
						myTree01.expandAll();
						
						$(".AXTreeScrollBody").css("border", "none");
					}else{
						$("#coviTreeTarget01").html("<p style='text-align: center;margin: 10px;margin-top: 50px;'><spring:message code='Cache.msg_EmptyData'/></p>");
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("manage/getTopFolder.do", response, status, error);
			}
		});
    }
    
	function setGridConfig(){
		var configObj = {
			targetID : "DocClassSearchList",
			height : "auto",
			paging : false,
			body : {}
		}
		ListGrid.setGridConfig(configObj);
	}
    
	function setListData(){
		ListGrid.page.listCount = 0;
		var url = "/approval/manage/getDocClassSearchList.do";
		ListGrid.bindGrid({
			ajaxUrl: url,
			resizeable:false,
			ajaxPars: {
				"searchWord" : $("#searchWord").val(),
				"EntCode" : _strdomainCode
			}
		});
	}
	
	function setGrid(){
		setGridHeader();
		setGridConfig();
		
		setFavoritesGridHeader();
		setFavoritesGridConfig();
	}
	
	function onClickSearchBtn(){
		setListData();
	}
	
	function onRadioChecked(itemID, itemName){
	    chkObj.id = itemID;
	    chkObj.name = itemName;
	}
	
	function clickTab(pObj){
	    $("#ClassTab .AXTab").attr("class","AXTab");
	    $(pObj).addClass("AXTab on");
	    
		var str = $(pObj).attr("value");

		if(str == "search"){
		    $("#searchDiv").show();
		    $("#FavoritesDiv").hide();
		    setGridHeader();
			setGridConfig();
		}else{
		    $("#searchDiv").hide();
		    $("#FavoritesDiv").show();
		    setFavoritesGridHeader();
			setFavoritesGridConfig();
		}
	}
	
	function setFavoritesGridHeader(){
		var headerData = [
		    {key:'chk', label:'선택', width:'30', align:'center',
				formatter:function () {
					return '<input type="radio" name="treeRadio" onClick="onRadioChecked(\''+this.item.DocClassID+'\', \''+this.item.ClassName+'\')"/>';
				}
			},
			{key:'ParentDocClassName', label:'문서분류', width:'50', align:'left', sort:false},
			{key:'ClassName',  label:'기능명칭', width:'80', align:'left', sort:false}
		];
		FavoritesGrid.setGridHeader(headerData);
	}
	
	function setFavoritesGridConfig(){	
		var configObj = {
			targetID : "FavoritesListGrid",
			height : "auto",
			paging : false,
			body : {}
		}
		FavoritesGrid.setGridConfig(configObj);
	}
	function getFavoritesGridListData(){
		var params = {};
		params.EntCode = _strdomainCode;
		
		var url = "/approval/manage/getDocFavoritesListGridData.do";
		FavoritesGrid.bindGrid({
			ajaxUrl: url,
			resizeable:false,
			ajaxPars: {
				"params" :Base64.utf8_to_b64(JSON.stringify(params))
			}
		});
	}
	
	function setFavoritesSave(elem){
		if(chkObj && Object.keys(chkObj).length == 0){
			Common.Warning("<spring:message code='Cache.msg_SelectTarget' />"); return false; //대상을 선택해주세요.
		}else{
		    var url = "/approval/manage/insertFavorites.do";
		    var msg = "<spring:message code='Cache.msg_insert' />"; //등록되었습니다.
		    if($(elem).attr("name") === "btnFavDel") {
				url = "/approval/manage/deleteFavorites.do";
				msg = "<spring:message code='Cache.msg_50' />"; // 삭제되었습니다.
		    }
				
			$.ajax({
				type:"POST",
				async:false,
				data:{
					"docClassID" : chkObj.id,
					"docClassName" : chkObj.name
				},
				url:url,
				success:function (data) {			
				    Common.Inform(msg, "Information", function(result){
						if(result){
						    getFavoritesGridListData();
						}	
					});
				},
				error:function(response, status, error){
					CFN_ErrorAjax("manage/getTopFolder.do", response, status, error);
				}
			});
		}
	}
	
	// 레이어 팝업 닫기
	function closeLayer() {
		Common.Close();
	}
	
	// 확인버튼 클릭
	function btnSave_Click() {
	    if(chkObj && Object.keys(chkObj).length == 0){
			Common.Warning("<spring:message code='Cache.msg_SelectTarget' />"); return false; //대상을 선택해주세요.
		}else if(_openType == "manager"){
		    var returnObj = {
			    'EntCode' : _strdomainCode,
			    'EntName' : _EntName,
			    'docClassID' : chkObj.id,
			    'docClassName' : chkObj.name,
		    };
		    parent._CallBackMethod(returnObj);
		}else{
			opener.document.getElementById("DocClassID").value  = chkObj.id;
			opener.document.getElementById("DocClassName").value = chkObj.name;
		}
	    closeLayer();
	}
</script>
</head>
<body>
<div class="layer_divpop" id="testpopup_p" style="min-width: 500px; width: 100%; height: 100%; z-index: 51; padding:20px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
 <!-- 팝업 Contents 시작 --> 
    <div id="orgTargetDiv">
    	<div class="appTree">
			<div id="coviTreeTarget01" style="width:100%;height:100%;min-height:450px; overflow: auto;border: 1px solid #b1b1b1;"></div>
	    </div>
	    <div style="min-height:450px;">
		    <!-- 탭메뉴 시작 -->
			<div class="AXTabsLarge" id="ClassTab">
				<div class="AXTabsTray"> 
					<a class="AXTab on" href="#ax" value="search" onclick="clickTab(this)"><spring:message code='Cache.lbl_search'/></a> <!--검색-->
					<a class="AXTab" href="#ax" value="Favorites" onclick="clickTab(this)" style="display:none;"><spring:message code='Cache.lbl_Favorite'/></a> <!--즐겨찾기 -->
				</div>
			</div>
	        <!-- 탭메뉴 종료 -->
	        
	        <div id="searchDiv">
			    <div class="appList_top_b searchBox02">
					<input style="width:${(param.openType == 'manager' ? '390px' : '290px')}" type="text" autocomplete="off" placeholder="검색어를 입력하세요" id="searchWord" name="inputSelector_onsearch" data-axbind="selector" onkeypress="if (event.keyCode==13){ $('.btnSearchType01').click(); return false;}">
					<a class="btnSearchType01">검색</a>
					<a href="#" class="btnTypeDefault  btnTypeBg" onClick="setFavoritesSave(this);" name="btnFavAdd" style="display:none;"><spring:message code='Cache.btn_addFavorite'/></a><!-- 즐겨찾기 추가 -->
				</div>
				<div class="appList" style="overflow: auto; width:390px;height:385px;">
					<div id="DocClassSearchList"></div>
				</div>
			</div>
			
	 		<div id="FavoritesDiv" style="display:none;">
	 			<div class="appList_top_b searchBox02">
	 				<a href="#" class="btnTypeDefault  btnTypeBg" onClick="setFavoritesSave(this);" name="btnFavAdd" ><spring:message code='Cache.btn_addFavorite'/></a><!-- 즐겨찾기 추가 -->
	 				<a href="#" class="btnTypeDefault  btnTypeBg" onClick="setFavoritesSave(this);" name="btnFavDel" ><spring:message code='Cache.btn_Favorite_remove'/></a><!-- 즐겨찾기 제거 -->
	 			</div>
	 			<div class="appList" style="overflow: auto; width:390px;height:385px;">
					<div id="FavoritesListGrid"></div>
				</div>
			</div>
		</div>
	</div>

	<div style="clear: both;text-align: right; padding: 15px 0px 15px 0px;"> 
		<input type="button" id="btOK" name="cbBTN" onclick="btnSave_Click();" class="ooBtn ooBtnChk" value="<spring:message code='Cache.btn_Confirm'/>"/><!--확인-->
		<input type="button" id="btExit" name="cbBTN" onclick="closeLayer();" class="owBtn mr30" value="<spring:message code='Cache.btn_apv_close'/>"/><!--닫기-->
	</div>
<!--팝업 컨테이너 끝-->
</div>
</body>
