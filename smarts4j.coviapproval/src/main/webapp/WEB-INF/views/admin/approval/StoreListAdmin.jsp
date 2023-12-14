<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<body>
	<h3 class="con_tit_box">
		<span class="con_tit"><spring:message code='Cache.CN_1273' /></span>
	</h3>
	<div id="topitembar02" class="topbar_grid">
		<input type="button" value="<spring:message code='Cache.btn_apv_refresh' />" onclick="Refresh();" class="AXButton BtnRefresh"/> <!-- 새로고침 -->
		<select name="" class="AXSelect" id="selectEntinfoListData"></select>
		&nbsp;&nbsp;
		<select name="" class="AXSelect" id="selectSearchType"></select>
		<input type="text" id="searchInput" onKeyPress="if (event.keyCode == 13) {onClickSearchButton();}" class="AXInput" disabled="disabled"/>
		<select name="" class="AXSelect" id="selectSearchTypeDate"></select>
		<input class="AXInput" id="startdate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate" disabled="disabled">
	   	    ~ 				   	   
		<input class="AXInput" id="enddate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate" disabled="disabled">
		<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="onClickSearchButton();" class="AXButton"/>
	</div>
	<div id="approvalListGrid"></div>
	<input type="hidden" id="hiddenGroupWord" value="" />
</body>
<script>
	var ListGrid = new coviGrid();		// ListGrid 라는 변수는 각 함에서 동일하게 사용
	var headerData;						// Grid 의 헤더 데이터. 엑셀저장을 위함. JSONObject
	var selectParams;					// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
	var approvalListType = "listAdmin";
	var bstored = "true";
	
	initListAdmin();
	
	function initListAdmin(){
		setSelectEntinfoList(ListGrid);				// 공통함수
		setGrid();
	}

	function setSelectEntinfoList(gridObj){
		$("#selectEntinfoListData").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/common/getEntInfoListData.do",
			ajaxAsync:false,
			setValue : Common.getSession("DN_Code"),
		});

		$("#selectSearchType").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/admin/getEntinfototalListData.do",
			ajaxPars: {"filter": "selectSearchType"},
			ajaxAsync:false,
			onchange: function(){
				if($("#selectSearchType").val() != ''){
					$("#searchInput").attr("disabled",false);
				}else{
					$("#searchInput").attr("disabled",true);
				}
			}
		});

		$("#selectSearchTypeDate").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/admin/getEntinfototalListData.do",
			ajaxPars: {"filter": "selectSearchTypeDate"},
			ajaxAsync:false,
			onchange: function(){
				if($("#selectSearchTypeDate").val() != ''){
					$("#startdate").attr("disabled",false);
					$("#enddate").attr("disabled",false);
				}else{
					$("#startdate").attr("disabled",true);
					$("#enddate").attr("disabled",true);
				}
			}
		});
	}

	function setAdminSelectParams(gridObj){
		selectParams = {
				"searchType":$("#selectSearchType").val(),
				"searchWord":$("#searchInput").val(),
				"selectSearchTypeDate":$("#selectSearchTypeDate").val(),
				"selectEntinfoListData":$("#selectEntinfoListData").val(),
				"selectSearchTypeDoc":"",
				"startDate":$("#startdate").val(),
				"endDate":$("#enddate").val(),
				"bstored":bstored // 이관문서
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
			ListGrid.bindGrid({
				ajaxUrl:"/approval/admin/getListAdminData.do",
				ajaxPars: selectParams
			});
		}
	}

	//문서속성 팝업
	function OpenDocumentInfo(id, isDeleted){
		Common.open("","OpenDocumentInfo","문서속성","/approval/admin/OpenDocumentInfoPopup.do?FormInstID="+id+"&isDeleted="+isDeleted,"800px","400px","iframe",true,null,null,true);
	}

	function setSearchGroupWord(id){
		$("#hiddenGroupWord").val(id);
		setApprovalListData();
	}

	function onClickSearchButton(){
		setApprovalListData();
	}
	
	function onClickPopButton(ProcessID, isArchived, forminstanceID){
		CFN_OpenWindow("/approval/approval_Form.do?mode=ADMIN&processID="+ProcessID+"&workitemID=&performerID=&processdescriptionID=&userCode=&gloct=&admintype=&archived=true&bstored=true&usisdocmanager=true&subkind=&forminstanceID="+forminstanceID, "", 790, (window.screen.height - 100), "resize");
	}
	
	function ViewProcessListPop(fiid, piid, archived, DocNO){
		CFN_OpenWindow("/approval/admin/monitoring.do?FormInstID=" + fiid+"&ProcessID="+piid+"&archived="+archived+"&DocNO="+DocNO, "", 1360, (window.screen.height - 100), "both");
	}
	
</script>