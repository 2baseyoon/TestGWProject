<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js"></script>

<style>	
	.AXTree_none .AXTreeScrollBody .AXTreeBody .treeBodyTable tbody tr td .bodyNode .bodyNodeIcon {
    	width: 24px !important;
	}
	
	.AXTree_none .AXTreeScrollBody .AXTreeBody .treeBodyTable tbody tr td .bodyTdText a:last-child:before {
	    content: '';
	    display: inline-block;
	    width: 6px;
	    height: 20px;
	    vertical-align: top;
	}
</style>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_ClassifiedDocuments'/></h2>
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
				<div class="conin_list rightBorder" style="width:250px;"><!-- 좌우 폭 조정에 따라 값 변경(좌측 width값) -->
					<div class="polTreeScroll mScrollV scrollVType01" style="padding-top:15px;">
						<dl class="polTree" id="DocTypeTreeList"></dl>
					</div>
				</div>
				<!-- 컨텐츠 좌측 끝 -->
				<!-- 컨텐츠 우측 시작 -->
				<div class="conin_view" style="left:210px;" id="folderDiv"><!-- 좌우 폭 조정에 따라 값 변경 -->
					<div class="tPadd" style="padding-right: 0px;">
						<!-- thead 시작 -->
						<div class="btn_group mb10" id="subfolderDiv">
							<div class="buttonStyleBoxLeft">
								<a id="saveExlBtn" class="btnTypeDefault btnExcel" onclick="ExcelDownLoad(selectParams, getHeaderDataForExcel(), gridCount);"><spring:message code='Cache.btn_SaveToExcel' /></a> <!-- 엑셀저장 -->
								<div style="display: inline-block; float: right;">
									<select id="selectPageSize" class="selectType02" style="width: 62px; height: 33px;">
										<option value="10">10</option>
										<option value="20">20</option>
										<option value="30">30</option>
									</select>
									<button class="btnRefresh ml5" onclick="DocTypeListRefresh();"></button>
								</div>
							</div>
						</div>
						<div class="table_th_f mtm10"><!-- 좌우 폭 조정에 따라 값 변경(상단 폭에 12px를 뺀 값) -->
							<div id="DocTypeListGrid"></div>
						</div>
					</div>
				</div>
				<!-- 컨텐츠 우측 끝 -->
			</div>
			<!-- 본문 끝 -->
		</div>
	</div>
</div>
<input type="hidden" id="docClassID" value="" />
<script>
	var myTree = new coviTree();
	var ListGrid = new coviGrid();			// ListGrid 라는 변수는 각 함에서 동일하게 사용
	var headerData;							// Grid 의 헤더 데이터. 엑셀저장을 위함. JSONObject
	var gridCount = 0;						// gridCount 라는 변수는 각 함에서 동일하게 사용
	var selectParams;						// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
	var approvalListType = "docType";		// 공통 사용 변수 - 결재함 종류 표현 - 문서분류함
	var bstored = "false";
	var g_mode = "docType";

	var Treebody = {
		onclick:function(idx, item) {
			$("#docClassID").val(item.no);
			$("#searchInput").val("");
			setDocTypeListData();
		}
	};
	
	//일괄 호출 처리
	initApprovalListComm(initUserListFolder, changePageSize);
	
	function initUserListFolder() {
		setSelect(ListGrid, approvalListType, "/approval/user/getAuditDeptCompleteGroupListData.do");
		setTreeData();
		setGrid();
		coviCtrl.bindmScrollV($('.mScrollV'));
	}

	function DocTypeListRefresh(){
		setDocTypeListData();
	}

	function setTreeData(){
		$.ajax({
			type:"POST",
			async:false,
			data:{
				"EntCode" : Common.getSession("DN_Code")
			},
			url:"/approval/admin/getFolderPopup.do",
			success:function (data) {			
				if(data.result == "ok"){
					if(data.list.length > 0){
						myTree.setTreeList("DocTypeTreeList", data.list, "nodeName", "220", "left", false, false, Treebody);
						
						myTree.expandAll(2);

						$(".AXTreeScrollBody").css("border", "none");
					}else{
						$("#DocTypeTreeList").html("<p style='text-align: center;margin: 10px;margin-top: 50px;'><spring:message code='Cache.msg_EmptyData'/></p>");
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("admin/getFolderPopup.do", response, status, error);
			}
		});
		myTree.displayIcon(true);
	}

	function setGrid(){
		$("#searchInput").val(""); // 트리틀릭시 검색어 삭제처리
		setGridConfig();
	}

	function setGridConfig(){
			 headerData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'150', align:'left',						       // 제목
						   	  formatter:function () {
						   			return "<a onclick='onClickPopButton(\""+ this.item.ProcessID +"\"); return false;'>"+this.item.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")+"</a>";
								}
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',
		                	  formatter:function(){return this.item.InitiatorUnitName;}
		                  },				           // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',
		                	  formatter:function(){return setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName);}
		                  },						   // 기안자
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center'},	// 양식명
		                  {key:'DocNo',  label:'<spring:message code="Cache.lbl_DocNo"/>', width:'50', align:'center'}, // 문서번호
		                  {key:'EndDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'60', align:'center', sort:'desc',
		                	  formatter:function () {
	                			  return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.EndDate);
	                	  	   }
		                  }];	// 일시	

		ListGrid.setGridHeader(headerData);

		var configObj = {
			targetID : "DocTypeListGrid",
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

	function setDocTypeListData(){
		if(searchValueValidationCheck()){		// 공통 함수
			setSelectParams(ListGrid);// 공통 함수
			ListGrid.bindGrid({
				ajaxUrl:"/approval/user/getDocTypeListData.do",
				ajaxPars: selectParams,
				onLoad: function(){
					setGridCount();
					$('.gridBodyTable > tbody > tr > td').css('background', 'white');
				}
			});
		}
	}
	
	function setGridCount(){
		gridCount = ListGrid.page.listCount;
	}
	
	function changePageSize() {
		setGridConfig();
		setDocTypeListData();
	}

	function onClickSearchButton(){
		if($("#seSearchID").attr("value") !="" && $("#searchInput").val() ==""){
			Common.Warning("<spring:message code='Cache.msg_EnterSearchword' />");							//검색어를 입력하세요
			$("#searchInput").focus();
			return false;
		}
		ListGrid.page.pageNo = 1;				// 조회기능 사용시 페이지 초기화
		setDocTypeListData();
		
		// 검색어 저장
		coviCtrl.insertSearchData($("#searchInput").val(), 'Approval');
	}

	function onClickPopButton(ProcessID){
		CFN_OpenWindow("/approval/approval_Form.do?mode=COMPLETE&processID="+ProcessID+"&workitemID=&performerID=&userCode=&gloct=DOCTYPE&admintype=&archived=true&usisdocmanager=true&subkind=", "", 790, (window.screen.height - 100), "resize");
	}
</script>