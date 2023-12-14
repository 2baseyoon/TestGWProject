<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>

<style>	
	.polTree dt { font-weight: normal; }
</style>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_apv_userdefinedfolder'/></h2><!-- 업무문서함 -->
	<div class="searchBox02">
		<div class="selBox" style="width: 100px;" id="selectSearchType"></div>
		<span><input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}" ><button id="simpleSearchBtn" type="button" onclick="onClickSearchButton(this);" class="btnSearchType01"><spring:message code='Cache.lbl_search'/></button></span>
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="apprvalContent">
		<div>
			<!-- 본문 시작 -->
			<div class="contbox" > <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
				<!-- 컨텐츠 좌측 시작 -->
				<div class="conin_list rightBorder" style="width:210px;"><!-- 좌우 폭 조정에 따라 값 변경(좌측 width값) -->
					<div class="polTop">
						<input type="button" value="<spring:message code='Cache.Cache.btn_apv_newFolder' />" class="btnAdd" onclick="onClickNewFolderPop();">
						<div class="fRight">
							<input type="button" value="<spring:message code='Cache.Cache.btn_apv_folderEdit' />" class="btnEra" onclick="onClickUpdtListFolderPop();" title="<spring:message code='Cache.Cache.btn_apv_folderEdit' />">
							<input type="button" value="<spring:message code='Cache.Cache.btn_delete' />" class="btnDel" onclick="deleteFolder(ListGrid);" title="<spring:message code='Cache.Cache.btn_delete' />">
							<input type="button" value="<spring:message code='Cache.btn_apv_refresh' />" class="btnRefr" onclick="FolderRefresh();" title="<spring:message code='Cache.btn_apv_refresh' />">
						</div>
					</div>
					<div class="polTreeScroll mScrollV scrollVType01">
						<dl class="polTree" id="folderTreeList"></dl>
					</div>
				</div>
				<!-- 컨텐츠 좌측 끝 -->
				<!-- 컨텐츠 우측 시작 -->
				<div class="conin_view" style="left:210px;" id="folderDiv"><!-- 좌우 폭 조정에 따라 값 변경 -->
					<div class="tPadd" style="padding-right: 0px;">
						<!-- thead 시작 -->
						<div class="btn_group mb10" id="subfolderDiv">
							<div class="buttonStyleBoxLeft">
								<a class="btnTypeDefault" onclick="deleteFolderList(ListGrid);"><spring:message code='Cache.Cache.btn_delete' /></a>
								<a class="btnTypeDefault mr15" onclick="onClickMoveFolderPop(ListGrid);"><spring:message code='Cache.Cache.lbl_apv_userfoldertitle_2' /></a>
								<div style="display: inline-block; float: right;">
									<select id="selectPageSize" class="selectType02" style="width: 62px; height: 33px;">
										<option value="10">10</option>
										<option value="20">20</option>
										<option value="30">30</option>
									</select>
									<button class="btnRefresh ml5" onclick="FolderListRefresh();"></button>
								</div>
							</div>
						</div>
						<div class="table_th_f mtm10"><!-- 좌우 폭 조정에 따라 값 변경(상단 폭에 12px를 뺀 값) -->
							<div id="UserFolderListGrid" class="tblList"></div>
						</div>
					</div>
				</div>
				<!-- 컨텐츠 우측 끝 -->
			</div>
			<!-- 본문 끝 -->
		</div>
	</div>
</div>
<input type="hidden" id="hiddenGroupWord" value="" />
<input type="hidden" id="folderId"   value="" />
<input type="hidden" id="parentId"   value="" />
<input type="hidden" id="folderMode" value="" />
<script>
	var myTree = new coviTree();
	var ListGrid = new coviGrid();			// ListGrid 라는 변수는 각 함에서 동일하게 사용
	var headerData;							// Grid 의 헤더 데이터. 엑셀저장을 위함. JSONObject
	var gridCount = 0;						// gridCount 라는 변수는 각 함에서 동일하게 사용
	var selectParams;						// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
	var approvalListType = "userFolder";	// 공통 사용 변수 - 결재함 종류 표현 - 개인폴더함
	var folderId	= "";                   // 각폴더의ID
	var folderMode	= "";                   // 개인폴더관리인지/폴더인지 구분값 개인폴더:A 아닌경우:M
	var folderCnt = 0;
	var bstored = "false";
	var g_mode = CFN_GetQueryString("mode") == "undefined" ? "Approval" : CFN_GetQueryString("mode");

	//일괄 호출 처리
	initApprovalListComm(initUserListFolder, changePageSize);
	
	function initUserListFolder() {
		setSelect(ListGrid, approvalListType, "/approval/user/getAuditDeptCompleteGroupListData.do");
		setTreeData();
		setGrid();
		coviCtrl.bindmScrollV($('.mScrollV'));
	}

	function FolderListRefresh(){
		if(folderCnt>0){
			setApprovalListData();
		}
	}

	function FolderRefresh(){
		setTreeData();
	}
	
	function setTreeData(){
		$.ajax({
			url:"/approval/user/getUserListFolder.do",
			type:"POST",
			data:{
				 },
			async:false,
			success:function (data) {
				var html = "";
				var firstFolder = "";
				for(var i = 0; i < data.list.length; i++){
					if(data.list[i].ParentsID == 0){
						html += "<dt><input type=\"checkbox\" id=\"folderCheckId\" name=\"folderCheckId\" value=\""+data.list[i].FolderID+"^"+data.list[i].FolDerName+"^"+data.list[i].ParentsID+"\"/><a class=\"polWidth\">Icn</a><a class=\"polName01\" onclick=\"onClickFolderModeList("+data.list[i].FolderID+","+data.list[i].ParentsID+")\">"+data.list[i].FolDerName+"</a><a class=\"polPlus\" onclick='onClick2LvNewFolderPop("+data.list[i].FolderID+")'><spring:message code='Cache.Cache.Cache.lbl_task_addFolder' /></a></dt>"
						if(firstFolder==""){firstFolder=data.list[i].FolderID}
					}
					for(var j = 0; j < data.list.length; j++){
						if(data.list[j].ParentsID == data.list[i].FolderID){
							html += "<dd><ul class=\"polSub\"><li><input type=\"checkbox\" name=\"folderCheckId\" id=\"folderCheckId\" value=\""+data.list[j].FolderID+"^"+data.list[j].FolDerName+"^"+data.list[j].ParentsID+"\"/><a class=\"polName02\" onclick=\"onClickFolderModeList("+data.list[j].FolderID+","+data.list[j].ParentsID+")\">"+data.list[j].FolDerName+"</a></li></ul></dd>";
						}
					}
				}
				folderCnt = data.list.length;
				$("#folderTreeList").html(html);				
				//if(firstFolder!=""){onClickFolderModeList(firstFolder,0)}
				//TODO 그리드를 그릴때 페이징값을 이상하게 보내서 setTimeOut 사용. 추후 개선 필요
				setTimeout(function(){
					if(firstFolder!=""){onClickFolderModeList(firstFolder,0)}
					//$("#folderTreeList dt:eq(0) a:eq(1)").trigger('onclick')
				}, 300);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getUserListFolder.do", response, status, error);
			}
		});
	}

	function onClickFolderList(pObj,ID){
		if($("[id='"+ID+"']").css('display') == 'none'){
			$("[id='"+ID+"']").show();
		}else{
			$("[id='"+ID+"']").hide();
		}
	}

	function onClickFolderModeList(FolderID,ParentsID){		
		$("#folderTreeList a[class*='polName']").removeProp('style');
		event && $( event.target ).prop('style','font-weight: bold;');		
		!event && $("#folderTreeList dt:eq(0) a:eq(1)").prop('style','font-weight: bold;');		
		$("#folderId").val(FolderID);
	    $("#parentId").val(ParentsID);
	    $("#searchInput").val("");
	    setApprovalListData();
	}

	function setGrid(){
		$("#searchInput").val(""); // 트리틀릭시 검색어 삭제처리
		setGridConfig();
		//setApprovalListData();
	}

	function setSetting(){
		var button = "";
		if(folderMode == 'M'){ // 개인폴더클릭시
			//
			button = "<input type=\"button\" class=\"AXButton\" onclick=\"Refresh();\" value=\"<spring:message code='Cache.Cache.Cache.btn_apv_refresh' />\">"
                   + "<input type=\"button\" class=\"AXButton\" onclick=\"deleteFolder(ListGrid);\" value=\"<spring:message code='Cache.Cache.btn_delete' />\">"
                   + "<input type=\"button\" class=\"AXButton mr15\" onclick=\"onClickMoveFolderPop(ListGrid);\" value=\"<spring:message code='Cache.Cache.lbl_apv_userfoldertitle_2' />\">"
			//
                   $("#subfolderDiv").css('padding-bottom','8px');
		}else{
			$("#subfolderDiv").css('padding-bottom','35px');
		}
		$("#buttonList").html(button);
	}

	function setGridConfig(){
			 headerData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'150', align:'left',						       // 제목
						   	  formatter:function () {
						   			return "<a onclick='onClickPopButton(\""+ this.item.ProcessID +"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
								}
		                  },
		                  {key:'RegDate', label:'<spring:message code="Cache.lbl_StorageDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'60', align:'center', sort:'desc',
		                	  formatter:function () {
	                			  return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.RegDate);
	                	  	   }
		                  },					// 일시
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',
		                	  formatter:function(){return this.item.InitiatorUnitName;}
		                  },				           // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',
		                	  formatter:function(){return setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName, 'AXGrid');}
		                  },						   // 기안자
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center'}];								 // 양식명

		ListGrid.setGridHeader(headerData);

		var configObj = {
			targetID : "UserFolderListGrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			notFixedWidth : 1
		};

		ListGrid.setGridConfig(configObj);
	}

	function setApprovalListData(){
		if(searchValueValidationCheck()){		// 공통 함수
			setSelectParams(ListGrid);// 공통 함수
			ListGrid.bindGrid({
				ajaxUrl:"/approval/user/getUserFolderListData.do",
				ajaxPars: selectParams,
				onLoad: function(){
					$('.gridBodyTable > tbody > tr > td').css('background', 'white');
				}
			});
		}
	}
	
	function changePageSize() {
		setGridConfig();
		setApprovalListData();
	}

	function onClickSearchButton(){
		if($("#seSearchID").attr("value") !="" && $("#searchInput").val() ==""){
			Common.Warning("<spring:message code='Cache.msg_EnterSearchword' />");							//검색어를 입력하세요
			$("#searchInput").focus();
			return false;
		}
		ListGrid.page.pageNo = 1;				// 조회기능 사용시 페이지 초기화
		setApprovalListData();
		
		// 검색어 저장
		coviCtrl.insertSearchData($("#searchInput").val(), 'Approval');
	}

	function onClickPopButton(ProcessID){
		
		CFN_OpenWindow("/approval/approval_Form.do?mode=COMPLETE&processID="+ProcessID+"&workitemID=&performerID=&userCode=&gloct=UFOLDER&admintype=&archived=true&usisdocmanager=true&subkind=", "", 790, (window.screen.height - 100), "resize");
	}

	//폴더명 수정버튼
	function onClickUpdtListFolderPop(){
	
		var checkApprovalList = $('input[name="folderCheckId"]:checked').length;
		var folderId;
		var folderNm;
		if(checkApprovalList == 0){
			Common.Warning("<spring:message code='Cache.msg_apv_003' />");				//선택된 항목이 없습니다.
			return false;
		}
		if(checkApprovalList > 1){
			Common.Warning("<spring:message code='Cache.msg_apv_326' />");
			return false;
		}
		
		var info = $('input[name="folderCheckId"]:checked').val().split("^");
		folderId = info[0];
		info.splice(0, 1);
		info.splice(info.length-1,1);
		folderNm = info.join("^");
		folderNm = encodeURIComponent(folderNm);
		Common.open("","onClickUpdtFolderPop","<spring:message code='Cache.btn_apv_folderEdit' />","/approval/user/UserUpdtFolderAddPopup.do?&folderId="+folderId+"&folderNm="+folderNm+"","500px","130px","iframe",true,null,null,true);
	}

	//리스트삭제버튼
	function deleteFolderList(gridObj){
		var FolderListIdTemp  = [];
		var FolderListID 	  = null;
		var checkApprovalList = gridObj.getCheckedList(0);

		for(var i = 0; i < checkApprovalList.length; i++){
			FolderListIdTemp.push(checkApprovalList[i].FolderListID);
		}

		FolderListID = FolderListIdTemp.join(",");

		if(checkApprovalList.length == 0){
			Common.Warning("<spring:message code='Cache.msg_apv_003' />");				//선택된 항목이 없습니다.
			return false;
		}
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result) {
			if(result){
				$.ajax({
					url:"/approval/user/deleteUserFolderList.do",
					type:"post",
					data:{
						"folderMode" : "M",
						"FolderListID" : FolderListID
					},
					async:false,
					success:function (res) {
						setApprovalListData();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/approval/user/deleteUserFolderList.do", response, status, error);
					}
				});
			}
		});
	}

	//폴더삭제버튼
	function deleteFolder(){
		var FolderListIdTemp  = [];
		var FolderListID 	  = null;
		var checkApprovalList = $('input[name="folderCheckId"]:checked').length;
		var parentId;
		$('input[name="folderCheckId"]:checked').each(function () {
			var info = $(this).val().split("^");
			FolderListIdTemp.push(info[0]);
			parentId = info[info.length-1];
		});

		FolderListID = FolderListIdTemp.join(",");

		if(checkApprovalList == 0){
			Common.Warning("<spring:message code='Cache.msg_apv_003' />");				//선택된 항목이 없습니다.
			return false;
		}
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result) {
			if(result){
				$.ajax({
					url:"/approval/user/deleteUserFolderList.do",
					type:"post",
					data:{
						"folderMode" : "A",
						"parentId" : parentId,
						"FolderListID" : FolderListID
					},
					async:false,
					success:function (res) {
							//Refresh();
						FolderRefresh();
						if (folderCnt == 0) {
							changePageSize();
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/approval/user/deleteUserFolderList.do", response, status, error);
					}
				});
			}
		});
	}
</script>