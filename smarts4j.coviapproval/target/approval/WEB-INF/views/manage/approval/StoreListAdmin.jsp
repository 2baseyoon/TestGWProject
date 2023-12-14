<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.CN_1273"/></span> <!-- 이전문서 조회 -->
	</h2>
	<div class="searchBox02">
		<span>
			<input type="text" id="searchText" onkeypress="if (event.keyCode==13){ setApprovalListData();}" >
			<button type="button" class="btnSearchType01" id="icoSearch" onclick="setApprovalListData();" ><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
		</span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa04" id="DetailSearch">
		<div>
			<!-- <select name="" class="AXSelect" id="selectEntinfoListData"></select> -->
			<div class="selectCalView">
				<select class="selectType02 w120p" id="selectSearchType" ></select>
				<input type="text" id="searchInput" disabled="disabled" onkeypress="if (event.keyCode==13){ setApprovalListData();}" />
			</div>
			<div class="selectCalView">
				<select class="selectType02" id="selectSearchTypeDate"></select>
				<div class="dateSel type02">
					<input class="adDate" id="startdate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate" disabled="disabled" />
					<span>~</span>
					<input class=" adDate" id="enddate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate" disabled="disabled" />
				</div>
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="setApprovalListData();"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select class="selectType02 listCount" id="selectPageSize" onchange="setApprovalListData();">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="approvalListGrid"></div>
		</div>
		<input type="hidden" id="hidden_domain_val" value=""/>
		<input type="hidden" id="hiddenGroupWord" value=""/>
	</div>
</div>

</body>
<script>
	var ListGrid = new coviGrid();		// ListGrid 라는 변수는 각 함에서 동일하게 사용
	ListGrid.config.fitToWidthRightMargin = 0;
	var headerData;						// Grid 의 헤더 데이터. 엑셀저장을 위함. JSONObject
	var selectParams;					// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
	var approvalListType = "listAdmin";
	var bstored = "true";
	
	initListAdmin();
	
	function initListAdmin(){
		setControl(); // 초기 셋팅
		setGrid(); // 그리드셋팅 및 조회
	}

	// 초기 셋팅
	function setControl(){ 
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
		
		// 상세버튼 열고닫기
		$('.btnDetails').off('click').on('click', function(){
			var mParent = $('#DetailSearch');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).removeClass('active');
			}else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
			coviInput.setDate();
		});
		
		// 콤보셋팅
		setSelectEntinfoList(ListGrid);
	}
	
	function setSelectEntinfoList(gridObj){
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
	}

	function setAdminSelectParams(gridObj){
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		selectParams = {
				"searchType": isDetail ? $("#selectSearchType").val() : "",
				"searchWord": isDetail ? $("#searchInput").val() : "",
				"selectSearchTypeDate": isDetail ? $("#selectSearchTypeDate").val() : "",
				"selectEntinfoListData":$("#hidden_domain_val").val(),
				"selectSearchTypeDoc":"",
				"startDate": isDetail ? $("#startdate").val() : "",
				"endDate": isDetail ? $("#enddate").val() : "",
				"bstored":bstored, // 이관문서
				"icoSearch":$("#searchText").val()
		};
	}

	function setGrid(){
		setGridConfig();
		setApprovalListData();
	}

	function setGridConfig(){
			 headerData =[{key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'180',						       // 제목
						   	  formatter:function () {
						   		if(this.item.FormSubject != undefined){
						   		 	return "<a>"+this.item.FormSubject+"</a>";
						   		 }
							  }
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',
						   	  formatter:function () {
						   		if(this.item.InitiatorUnitName != undefined){
							   		return CFN_GetDicInfo(this.item.InitiatorUnitName);
						   		}
							  }
		                  },				           // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',
						   	  formatter:function () {
						   		if(this.item.InitiatorName != undefined){
							   		return CFN_GetDicInfo(this.item.InitiatorName);
						   		}
							  }
		                  },						   // 기안자
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center',
						   	  formatter:function () {
						   		if(this.item.FormName != undefined){
							   		return CFN_GetDicInfo(this.item.FormName);
						   		}
							  }
		                  },								 	   // 양식명
		                  {key:'InitiatedDate', label:'<spring:message code="Cache.lbl_apv_doc_requested"/>',  width:'60', align:'center', sort:'desc',
						   	  formatter:function () {
						   		if(this.item.InitiatedDate != undefined){
							   		return CFN_TransLocalTime(this.item.InitiatedDate);
						   		}
							  }
		                  },			   // 기안일자
		                  {key:'CompletedDate', label:'<spring:message code="Cache.lbl_apv_donedate"/>',  width:'60', align:'center', 
						   	  formatter:function () {
						   		if(this.item.IsArchived == "true" && this.item.PiState == "<spring:message code='Cache.TaskActType_CO' />"){
							   		return CFN_TransLocalTime(this.item.CompletedDate);
						   		}
							  }
		                  },				   // 완료일자
		                  {key:'DocNo',  label:'<spring:message code="Cache.lbl_DocNo"/>', width:'50', align:'center',
						   	  formatter:function () {
						   		if(this.item.DocNo != undefined){
							   		return this.item.DocNo;
						   		}
							  }
		                  },					// 문서번호
		                  {key:'PiDeletedDate', label:'<spring:message code="Cache.RequestStatus_Deleted"/>', width:'30', align:'center',
						   	  formatter:function () {
						   		if(this.item.PiDeletedDate != undefined){
							   		return "<span style='color: red;'>"+CFN_TransLocalTime(this.item.PiDeletedDate)+"</span>";
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
				onclick: function(){			
					onClickPopButton(this.item.ProcessID, this.item.IsArchived, this.item.FormInstID);
				}
			}
		};
		ListGrid.setGridConfig(configObj);
	}

	function setApprovalListData(){
		if(searchValueValidationCheck()){		// 공통 함수
			setAdminSelectParams(ListGrid);			
			ListGrid.page.pageNo = 1;
			ListGrid.page.pageSize = $("#selectPageSize").val();
			ListGrid.bindGrid({
				ajaxUrl:"/approval/manage/getListAdminData.do",
				ajaxPars: selectParams
			});
		}
	}

	function onClickPopButton(ProcessID, isArchived, forminstanceID){
		CFN_OpenWindow("/approval/approval_Form.do?mode=ADMIN&processID="+ProcessID+"&workitemID=&performerID=&processdescriptionID=&userCode=&gloct=&admintype=&archived=true&bstored=true&usisdocmanager=true&subkind=&forminstanceID="+forminstanceID, "", 790, (window.screen.height - 100), "resize");
	}
	
</script>