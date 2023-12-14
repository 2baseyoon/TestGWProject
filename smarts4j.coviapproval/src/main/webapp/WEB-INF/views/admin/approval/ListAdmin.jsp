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
		<span class="con_tit"><spring:message code='Cache.CN_116' /></span>
	</h3>
	<div style="padding:5px 7px 7px 7px;">
	<strong style="font-size: 13px;color: #ee0000;"><spring:message code='Cache.lbl_apv_ListAdmin_notice' /></strong>
	</div>
	<div id="topitembar02" class="topbar_grid">
		<input type="button" value="<spring:message code='Cache.btn_apv_refresh' />" onclick="Refresh();" class="AXButton BtnRefresh"/> <!-- 새로고침 -->
		<select name="" class="AXSelect" id="selectEntinfoListData"></select>
		&nbsp;&nbsp;
		<select name="" class="AXSelect" id="selectSearchTypeDoc"></select>
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
	var bstored = "false";

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

		$("#selectSearchTypeDoc").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/admin/getEntinfototalListData.do",
			ajaxPars: {"filter": "selectSearchTypeDoc"},
			ajaxAsync:false,
			onchange: function(){
				gridObj.bindGrid({page:{pageNo:1,pageSize:10,pageCount:1},list:[]});
				//setGroupType(gridObj, url);
				setApprovalListData();
			}
		});
	}

	function setAdminSelectParams(gridObj){
		selectParams = {
				"searchType":$("#selectSearchType").val(),
				"searchWord":$("#searchInput").val(),
				"selectSearchTypeDate":$("#selectSearchTypeDate").val(),
				"selectEntinfoListData":$("#selectEntinfoListData").val(),
				"selectSearchTypeDoc":$("#selectSearchTypeDoc").val(),
				"startDate":$("#startdate").val(),
				"endDate":$("#enddate").val(),
				"bstored":bstored, // 이관문서
				"businessData1":"APPROVAL"
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
							   		return "<a onclick='ViewProcessListPop(\""+this.item.FormInstID+"\", \""+this.item.ProcessID+"\", false, \"" + this.item.DocNo + "\"); return false;'><img src=\"/approval/resources/images/Approval/ico_approval.gif\" class=\"ico_btn\" /></a>";
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
						   		 	return "<a onclick='onClickPopButton(\""+this.item.ProcessID+"\", \""+this.item.IsArchived+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); return false;'>"+this.item.FormSubject+"</a>";
						   		 }
							  }
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',
						   	  formatter:function () {
						   		if(this.item.InitiatorUnitName != undefined){
							   		return "<span onclick='onClickPopButton(\""+this.item.ProcessID+"\", \""+this.item.IsArchived+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); return false;'>"+CFN_GetDicInfo(this.item.InitiatorUnitName)+"</span>";
						   		}
							  }
		                  },				           // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'45', align:'center',
						   	  formatter:function () {
						   		if(this.item.InitiatorName != undefined){
							   		return "<span onclick='onClickPopButton(\""+this.item.ProcessID+"\", \""+this.item.IsArchived+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); return false;'>"+CFN_GetDicInfo(this.item.InitiatorName)+"</span>";
						   		}
							  }
		                  },						   // 기안자
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'65', align:'center',
						   	  formatter:function () {
						   		if(this.item.FormName != undefined){
							   		return "<span onclick='onClickPopButton(\""+this.item.ProcessID+"\", \""+this.item.IsArchived+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); return false;'>"+CFN_GetDicInfo(this.item.FormName)+"</span>";
						   		}
							  }
		                  },								 	   // 양식명
		                  {key:'InitiatedDate', label:'<spring:message code="Cache.lbl_apv_doc_requested"/>',  width:'60', align:'center', sort:'desc',
						   	  formatter:function () {
						   		if(this.item.InitiatedDate != undefined){
							   		return "<span onclick='onClickPopButton(\""+this.item.ProcessID+"\", \""+this.item.IsArchived+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); return false;'>"+CFN_TransLocalTime(this.item.InitiatedDate)+"</span>";
						   		}
							  }
		                  },			   // 기안일자
		                  {key:'CompletedDate', label:'<spring:message code="Cache.lbl_apv_donedate"/>',  width:'60', align:'center', 
						   	  formatter:function () {
						   		if(this.item.IsArchived == "true" && this.item.PiState == "<spring:message code='Cache.TaskActType_CO' />"){
							   		return "<span onclick='onClickPopButton(\""+this.item.ProcessID+"\", \""+this.item.IsArchived+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); return false;'>"+CFN_TransLocalTime(this.item.CompletedDate)+"</span>";
						   		}
							  }
		                  },				   // 완료일자
		                  {key:'DocNo',  label:'<spring:message code="Cache.lbl_DocNo"/>', width:'50', align:'center',
						   	  formatter:function () {
						   		if(this.item.DocNo != undefined){
							   		return "<span onclick='onClickPopButton(\""+this.item.ProcessID+"\", \""+this.item.IsArchived+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); return false;'>"+this.item.DocNo+"</span>";
						   		}
							  }
		                  },	 								       // 문서번호
		                  {key:'PiState', label:'<spring:message code="Cache.lbl_CommunityRegStatus"/>',  width:'25', align:'center',
						   	  formatter:function () {
						   	  	if(this.item.PiState == '<spring:message code="Cache.Messaging_Error"/>'){
						   	  		return "<span style='color: red;' onclick='onClickPopButton(\""+this.item.ProcessID+"\", \""+this.item.IsArchived+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); return false;'>"+this.item.PiState+"</span>";
						   	  	}else if(this.item.PiState != undefined){
							   		return "<span onclick='onClickPopButton(\""+this.item.ProcessID+"\", \""+this.item.IsArchived+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); return false;'>"+this.item.PiState+"</span>";
						   		}
							  } 
		                  },				   // 상태
		                  {key:'BusinessState', label:'<spring:message code="Cache.lbl_apv_result2"/>',  width:'25', align:'center',
						   	  formatter:function () {
						   		if(this.item.BusinessState != undefined){
							   		return "<span onclick='onClickPopButton(\""+this.item.ProcessID+"\", \""+this.item.IsArchived+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); return false;'>"+this.item.BusinessState+"</span>";
						   		}
							  }
		                  },							   // 결과
		                  {key:'PiDeletedDate', label:'<spring:message code="Cache.RequestStatus_Deleted"/>', width:'25', align:'center',
						   	  formatter:function () {
						   		if(this.item.PiDeletedDate != undefined){
							   		return "<span style='color: red;' onclick='onClickPopButton(\""+this.item.ProcessID+"\", \""+this.item.IsArchived+"\", \"" + this.item.FormInstID + "\", \"" + this.item.BusinessData1 + "\", \"" + this.item.BusinessData2 + "\"); return false;'>"+this.item.PiDeletedDate+"</span>";
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
			paging : true
		};
		ListGrid.setGridConfig(configObj);
	}

	function setApprovalListData(){
		if(searchValueValidationCheck()){		// 공통 함수
			setAdminSelectParams(ListGrid);
			ListGrid.page.pageNo = 1;
			ListGrid.bindGrid({
				ajaxUrl:"/approval/admin/getListAdminData.do",
				ajaxPars: selectParams,
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
	
	function onClickPopButton(ProcessID, isArchived, forminstanceID, BusinessData1, BusinessData2){
		if(BusinessData1 == "ACCOUNT") {
			CFN_OpenWindow("/approval/approval_Form.do?mode=ADMIN&processID="+ProcessID+"&workitemID=&performerID=&processdescriptionID=&userCode=&gloct=&admintype=&archived="+isArchived+"&usisdocmanager=true&subkind=&forminstanceID="+forminstanceID+"&ExpAppID="+BusinessData2, "", 790, (window.screen.height - 100), "resize");
		} else {
			CFN_OpenWindow("/approval/approval_Form.do?mode=ADMIN&processID="+ProcessID+"&workitemID=&performerID=&processdescriptionID=&userCode=&gloct=&admintype=&archived="+isArchived+"&usisdocmanager=true&subkind=&forminstanceID="+forminstanceID, "", 790, (window.screen.height - 100), "resize");
		}
		
	}
	
	function ViewProcessListPop(fiid, piid, archived, DocNO){
		CFN_OpenWindow("/approval/admin/monitoring.do?FormInstID=" + fiid+"&ProcessID="+piid+"&archived="+archived+"&DocNO="+encodeURI(DocNO), "", 1360, (window.screen.height - 100), "both");
	}
</script>