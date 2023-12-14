<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.CN_116' /></h2>
	<div class="searchBox02">
		<span><input id="searchInputSimple" type="text" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}"><button type="button" id="simpleSearchBtn" class="btnSearchType01" onclick="searchList(this);"><spring:message code="Cache.btn_search"/></button></span><a href="#" class="btnDetails" onclick="DetailDisplay(this);"><spring:message code="Cache.lbl_apv_detail"/></a>
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<!-- 상세 검색영역 -->
	<div id="DetailSearch" class="inPerView type02 sa04">
		<div>
			<div class="selectCalView">
				<select class="selectType02" id="selectSearchTypeDoc"></select>
				<select class="selectType02" id="selectSearchType"></select>
				<input type="text" value="" id="searchInput" onKeyPress="if (event.keyCode == 13) {onClickSearchButton();}" disabled="disabled">
			</div>
			<div class="selectCalView">
				<select class="selectType02" id="selectSearchTypeDate"></select>
				<div class="dateSel type02">
					<input class="adDate" id="startdate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate" disabled="disabled" />
					<span>~</span>
					<input class=" adDate" id="enddate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate" disabled="disabled" />
				</div>
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="onClickSearchButton();"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<div class="sadminContent">
		<!-- 상단버튼 영역 -->
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<strong style="font-size: 13px;color: #ee0000;"><spring:message code='Cache.lbl_apv_ListAdmin_notice' /></strong>
				&nbsp;
				<select id="selectPageSize" class="selectType02 listCount" onchange="searchList();">
					<option>10</option>
					<option>20</option>
					<option>30</option>
				</select>
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div id="approvalListGrid" class="tblList"></div>
	</div>
</div>
<input type="hidden" id="hiddenGroupWord" value="" />
<script>
	var lang = Common.getSession("lang");
	var ListGrid = new coviGrid();		// ListGrid 라는 변수는 각 함에서 동일하게 사용
	ListGrid.config.fitToWidthRightMargin = 0;
	
	var headerData;						// Grid 의 헤더 데이터. 엑셀저장을 위함. JSONObject
	var selectParams;					// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
	var approvalListType = "listAdmin";
	var bstored = "false";

	initListAdmin();
	
	function initListAdmin(){
		setSelectSearchInfo(ListGrid);				// 공통함수
		setGrid();
	}

	function setSelectSearchInfo(gridObj){
// 		$("#selectEntinfoListData").bindSelect({
// 			reserveKeys: {
// 				options: "list",
// 				optionValue: "optionValue",
// 				optionText: "optionText"
// 			},
// 			ajaxUrl: "/approval/common/getEntInfoListData.do",
// 			ajaxAsync:false,
// 			setValue : Common.getSession("DN_Code"),
// 		});

		var options = {
			nameKey : "optionText"
			,valueKey : "optionValue"
			,listDataKey : "list"
			,onchange : function (obj){
				if($("#selectSearchType").val() != ''){
					$("#searchInput").attr("disabled",false);
				}else{
					$("#searchInput").attr("disabled",true);
				}
			}
		};
		coviCtrl.renderNormalSelect($("#selectSearchType"), "/approval/manage/getEntinfototalListData.do", {"filter": "selectSearchType"}, options, lang);
		
		options = {
				nameKey : "optionText"
				,valueKey : "optionValue"
				,listDataKey : "list"
				,onchange : function (obj){
					if($("#selectSearchTypeDate").val() != ''){
						$("#startdate").attr("disabled",false);
						$("#enddate").attr("disabled",false);
					}else{
						$("#startdate").attr("disabled",true);
						$("#enddate").attr("disabled",true);
					}
				}
		};
		coviCtrl.renderNormalSelect($("#selectSearchTypeDate"), "/approval/manage/getEntinfototalListData.do", {"filter": "selectSearchTypeDate"}, options, lang);
		
		options = {
				nameKey : "optionText"
				,valueKey : "optionValue"
				,listDataKey : "list"
				,onchange : function (obj){
					setApprovalListData();
				}
		};
		coviCtrl.renderNormalSelect($("#selectSearchTypeDoc"), "/approval/manage/getEntinfototalListData.do", {"filter": "selectSearchTypeDoc"}, options, lang);
	}

	function setAdminSelectParams(gridObj){
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		selectParams = {
				"searchType":isDetail ? $("#selectSearchType").val() : "",
				"searchWord":isDetail ? $("#searchInput").val() : "",
				"selectSearchTypeDate":isDetail ? $("#selectSearchTypeDate").val() : "",
				"selectEntinfoListData":confMenu.domainCode,
				"selectSearchTypeDoc":isDetail ? $("#selectSearchTypeDoc").val() : "",
				"startDate":isDetail ? $("#startdate").val() : "",
				"endDate":isDetail ? $("#enddate").val() : "",
				"bstored":bstored, // 이관문서
				"businessData1":"APPROVAL",
				"icoSearch":$("#searchInputSimple").val()
		};
	}

	
	function setGrid(){
		setGridConfig();
		setApprovalListData();
	}

	function setGridConfig(){
			 headerData =[{key:'DocumentInfo', label:'<spring:message code="Cache.lbl_Doc_Properties"/>', width:'30', align:'center', sort: false, 
						   	  formatter:function () {
							   		return "<a onclick='OpenDocumentInfo(\""+this.item.FormInstID+"\", \""+this.item.PiDeletedDate+"\"); return false;'><img src=\"/approval/resources/images/Approval/data_text.gif\" class=\"ico_btn\" /></a>";
							   }
				 		  },			// 문서속성
			              {key:'Process', label:'<spring:message code="Cache.lbl_process"/>', width:'30', align:'center',  sort: false, 
						   	  formatter:function () {
							   		return "<a onclick='ViewProcessListPop(\""+this.item.FormInstID+"\", \""+this.item.ProcessID+"\", "+( (this.item.PiState == "<spring:message code='Cache.TaskActType_CO' />") ? "true" : "false")+", \"" + this.item.DocNo + "\"); return false;'><img src=\"/approval/resources/images/Approval/ico_approval.gif\" class=\"ico_btn\" /></a>";
							   }
			              },				// 프로세스
			              {key:'Complete', label:'완료 프로세스', width:'30', align:'center', sort: false, 
						   	  formatter:function () {
						   		  	if(this.item.IsArchived == "true" && this.item.PiState == "<spring:message code='Cache.TaskActType_CO' />"){
							   			//return "<a onclick='ViewArchiveProcessListPop(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkitemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\"\",\"\",\"\",\"\"); return false;'><img src=\"/approval/resources/images/Approval/ico_approval_gray.gif\" class=\"ico_btn\" /></a>";
						   		  		return "<a onclick='ViewProcessListPop(\""+this.item.FormInstID+"\", \""+this.item.ProcessID+"\", "+this.item.IsArchived+", \"" + this.item.DocNo + "\"); return false;'><img src=\"/approval/resources/images/Approval/ico_approval_gray.gif\" class=\"ico_btn\" /></a>";
						   		  	}
								}
			              },				// 완료프로세스
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'130',						       // 제목
						   	  formatter:function () {
						   		if(this.item.FormSubject != undefined){
						   		 	return "<a class='txt_underline'>"+this.item.FormSubject+"</a>";
						   		 }
							  }
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',
						   	  formatter:function () {
						   		if(this.item.InitiatorUnitName != undefined){
							   		return "<span>"+CFN_GetDicInfo(this.item.InitiatorUnitName)+"</span>";
						   		}
							  }
		                  },				           // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'45', align:'center',
						   	  formatter:function () {
						   		if(this.item.InitiatorName != undefined){
							   		return "<span>"+CFN_GetDicInfo(this.item.InitiatorName)+"</span>";
						   		}
							  }
		                  },						   // 기안자
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'65', align:'center',
						   	  formatter:function () {
						   		if(this.item.FormName != undefined){
							   		return "<span>"+CFN_GetDicInfo(this.item.FormName)+"</span>";
						   		}
							  }
		                  },								 	   // 양식명
		                  {key:'InitiatedDate', label:'<spring:message code="Cache.lbl_apv_doc_requested"/>',  width:'60', align:'center', sort:'desc',
						   	  formatter:function () {
						   		if(this.item.InitiatedDate != undefined){
							   		return "<span>"+CFN_TransLocalTime(this.item.InitiatedDate)+"</span>";
						   		}
							  }
		                  },			   // 기안일자
		                  {key:'CompletedDate', label:'<spring:message code="Cache.lbl_apv_donedate"/>',  width:'60', align:'center', 
						   	  formatter:function () {
						   		if(this.item.IsArchived == "true" && this.item.PiState == "<spring:message code='Cache.TaskActType_CO' />"){
							   		return "<span>"+CFN_TransLocalTime(this.item.CompletedDate)+"</span>";
						   		}
							  }
		                  },				   // 완료일자
		                  {key:'DocNo',  label:'<spring:message code="Cache.lbl_DocNo"/>', width:'50', align:'center',
						   	  formatter:function () {
						   		if(this.item.DocNo != undefined){
							   		return "<span>"+this.item.DocNo+"</span>";
						   		}
							  }
		                  },	 								       // 문서번호
		                  {key:'PiState', label:'<spring:message code="Cache.lbl_CommunityRegStatus"/>',  width:'25', align:'center',
						   	  formatter:function () {
						   	  	if(this.item.PiState == '<spring:message code="Cache.Messaging_Error"/>'){
						   	  		return "<span style='color: red;'>"+this.item.PiState+"</span>";
						   	  	}else if(this.item.PiState != undefined){
							   		return "<span>"+this.item.PiState+"</span>";
						   		}
							  } 
		                  },				   // 상태
		                  {key:'BusinessState', label:'<spring:message code="Cache.lbl_apv_result2"/>',  width:'25', align:'center',
						   	  formatter:function () {
						   		if(this.item.BusinessState != undefined){
							   		return "<span>"+this.item.BusinessState+"</span>";
						   		}
							  }
		                  },							   // 결과
		                  {key:'PiDeletedDate', label:'<spring:message code="Cache.RequestStatus_Deleted"/>', width:'25', align:'center',
						   	  formatter:function () {
						   		if(this.item.PiDeletedDate != undefined){
							   		return "<span style='color: red;'>"+this.item.PiDeletedDate+"</span>";
						   		}
							  }
		                  }];								       // 삭제
		                  //
		ListGrid.setGridHeader(headerData);
		var configObj = {
			targetID : "approvalListGrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			body:{
				onclick:function(){
					var idx = Number(this.c);
					var colInfo = ListGrid.config.colGroup[idx];
					if(["FormSubject"].indexOf(colInfo.key) > -1) {
						onClickPopButton(this.item.ProcessID, this.item.IsArchived, this.item.FormInstID, this.item.BusinessData1, this.item.BusinessData2);
					}
				}
			}
		};
		ListGrid.setGridConfig(configObj);
	}

	function setApprovalListData(pageNo){
		if(searchValueValidationCheck()){		// 공통 함수
			setAdminSelectParams(ListGrid);
			ListGrid.page.pageNo = 1;
			ListGrid.page.pageSize = $("#selectPageSize").val();
			ListGrid.bindGrid({
				ajaxUrl:"/approval/manage/getListAdminData.do",
				ajaxPars: selectParams,
			});
		}
	}

	//문서속성 팝업
	function OpenDocumentInfo(id, isDeleted){
		Common.open("","OpenDocumentInfo","문서속성","/approval/manage/OpenDocumentInfoPopup.do?FormInstID="+id+"&isDeleted="+isDeleted,"800px","400px","iframe",true,null,null,true);
	}

	// 상세검색 열고닫기
	function DetailDisplay(pObj){
		if($("#DetailSearch").hasClass("active")){
			$(pObj).removeClass("active");
			$('#DetailSearch').removeClass("active");
		}else{
			$(pObj).addClass("active");
			$('#DetailSearch').addClass("active");
		}
		
		$(".contbox").css('top', $(".content").height());
		coviInput.setDate();
	}
	
	function Refresh() {
		setApprovalListData();
	}
	
	function searchList(pObj) {
		/*
		if(pObj && pObj.id == "simpleSearchBtn"){
			$("#search").val($("#searchInputSimple").val());
		}
		*/
		setApprovalListData();
	}
	
	function setSearchGroupWord(id){
		$("#hiddenGroupWord").val(id);
		setApprovalListData();
	}

	function onClickSearchButton(){
		setApprovalListData();
	}
	
	function onClickPopButton(ProcessID, isArchived, forminstanceID, BusinessData1, BusinessData2){
		if(BusinessData1 == "ACCOUNT") {
			CFN_OpenWindow("/approval/approval_Form.do?mode=ADMIN&processID="+ProcessID+"&workitemID=&performerID=&processdescriptionID=&userCode=&gloct=&admintype=&archived="+isArchived+"&usisdocmanager=true&subkind=&forminstanceID="+forminstanceID+"&ExpAppID="+BusinessData2, "", 790, (window.screen.height - 100), "resize");
		} else {
			CFN_OpenWindow("/approval/approval_Form.do?mode=ADMIN&processID="+ProcessID+"&workitemID=&performerID=&processdescriptionID=&userCode=&gloct=&admintype=&archived="+isArchived+"&usisdocmanager=true&subkind=&forminstanceID="+forminstanceID, "", 790, (window.screen.height - 100), "resize");
		}
		
	}
	
	function ViewProcessListPop(fiid, piid, archived, DocNO){
		CFN_OpenWindow("/approval/manage/monitoring.do?FormInstID=" + fiid+"&ProcessID="+piid+"&archived="+archived+"&DocNO="+encodeURI(DocNO), "", 1360, (window.screen.height - 100), "both");
	}
</script>