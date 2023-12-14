<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>
<div class="cRConTop titType">
	<h2 class="title">그룹사 공지관리</h2>
	<span id="folderPath"></span>
	<div class="searchBox02">
	    <span><input type="text" id="searchText"><button type="button" class="btnSearchType01"  id="btnSearch"><spring:message code='Cache.btn_search' /></button></span> <!-- 검색 -->
	</div>
</div>	

<form id="form1">
<div class="cRContBottom mScrollVH">
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
<!--  				<a class="btnTypeDefault" href="#">삭제</a>-->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#"  id="btnRefresh"></button>
			</div>
		</div>	
		<div class="tblList">
			<div id="orgNoticeGrid"></div>
		</div>	
	</div>
</div>	
</form>
<script type="text/javascript">
var confNotice = {
	confNoticeGrid:new coviGrid(),// onclick="javascript:board.goViewPopup(\'Board\', 10, 1, '+this.item.FolderID+', '+this.item.MessageID+'
	headerData:[ {key:'Subject', label:'<spring:message code="Cache.lbl_Title"/>', width:'200', align:'left',
	            	 formatter:function () {
	            		 	var data = '<div class="tblLink" name="subjectColumn" title="'+this.item.Subject+
	            		 		'" data-folder="' + this.item.FolderID +'" data-message="' + this.item.MessageID +'">';
	            		 
	            		 	if(this.item.IsRead == 'N') {
	            		 		data = data + "<strong>" + this.item.Subject + "</strong></div>";
	            		 	} else {
	            		 		data = data + this.item.Subject + "<div>";
	            		 	}
	            		 	
	            		 	return data;
	            		 }},
        		 {key:'BodyText',  label:'<spring:message code="Cache.lbl_SummaryInfo"/>', width:'400', align:'left'},
			     {key:'CreatorName', label:'<spring:message code="Cache.lbl_Register"/>',  width:'50', align:'center'},
	             {key:'CreateDate', label:'<spring:message code="Cache.lbl_RegistDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', 
      				formatter: function(){
      					return CFN_TransLocalTime(this.item.CreateDate);
  					}},
 				{key:'',  label:'<spring:message code="Cache.lbl_apv_Post"/>', width:'70', align:'center', formatter:function(){
					if (confMenu.domainId == "0"){
						return '<a href="javascript:;" class="btnTypeDefault btnPlusAdd" onclick="confNotice.exportNoticeList(\'' + this.item.MessageID+'\',\'' + this.item.Version+'\');"><spring:message code="Cache.lbl_List_View"/></a>';
					}else{	
						if (this.item.HistoryID == null) {
							return '<a href="javascript:;" class="btnTypeDefault btnPlusAdd" onclick="confNotice.exportFolderPopup(\'' + this.item.MessageID+'\',\'' + this.item.Version+'\');"><spring:message code="Cache.lbl_apv_Post"/></a>';
						}
					}
				}}
		      	],
    initLoad:function(){ 
    	confNotice.setGrid();			// 그리드 세팅
		//검색
		$("#searchText").on('keydown',function(){
			if(event.keyCode=="13"){
				confNotice.searchList();
			}
		});	
		$("#btnSearch").on('click',function(){
			confNotice.searchList();
		});
		
		$("#btnRefresh").on("click",function(){
			confNotice.searchList();
		});
		$('#selectPageSize').on('change', function(e) {
			confNotice.confNoticeGrid.page.pageSize = $(this).val();
			confNotice.searchList();
		});
		
		if (confMenu.domainId == "0"){
			$.ajax({
				url: "/groupware/board/manage/getOrgFolderPath.do",
				type: "POST",
				success: function(json){
					$("#folderPath").text(json.data.FolderPathName.replaceAll(";",">")+">"+json.data.MultiDisplayName)
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/admin/selectFolderTreeData.do", response, status, error);
				}
			});
		}
		confNotice.searchList();
	},
	setGrid:function(){
		this.confNoticeGrid.setGridHeader(this.headerData);
		this.confNoticeGrid.setGridConfig({
			targetID : "orgNoticeGrid",
			height:"auto",
			page:{pageSize:10,pageNo:1}
		});
	},
	searchList:function(){
		this.confNoticeGrid.page.pageNo = 1;
		this.confNoticeGrid.bindGrid({
 			ajaxUrl:"/groupware/board/manage/getOrgNoticeList.do",
 			ajaxPars: {
 				"domainID":confMenu.domainId,
 				"searchText":$("#searchText").val()
 			},
 			onLoad:function() {
 				$("#orgNoticeGrid [name=subjectColumn]").on("click", function() {
 					var folderID = $(this).data("folder");
 					var messageID = $(this).data("message");
 					
 					var elem = $(this);
 					
 					if(elem.children("strong").length > 0) {
 						var text = elem.text();
 						elem.children("strong").remove();
 						elem.text(text);
 					}
						 					
 					board.goViewPopup('Board', 10, 1, folderID, messageID,'W', '');
 				});
 			}
		});
	},
	//게시 이동, 복사용 게시판 목록 조회 팝업
	exportFolderPopup : function(messageID, version) {
		var url = "/groupware/board/manage/ExportNoticeFolderPopup.do?domainID="+confMenu.domainId+"&messageID="+messageID+"&version="+version;
		Common.open("", "boardTreePopup", Common.getDic("lbl_SelectBoard"), url, "360px", "500px", "iframe", true, null, null, true);
	},
	//게시 도메인
	exportNoticeList : function(messageID, version) {
		var url = "/groupware/board/manage/ExportNoticeListPopup.do?domainID="+confMenu.domainId+"&messageID="+messageID+"&version="+version;
		Common.open("", "boardTreePopup", Common.getDic("lbl_AllListBoardList"), url, "660px", "600px", "iframe", true, null, null, true);
	},
	
}
window.onload = confNotice.initLoad();
</script>