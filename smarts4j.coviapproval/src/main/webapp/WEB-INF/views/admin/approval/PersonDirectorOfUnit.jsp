<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_targetDeptUser"/></span>	
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">		
		<div id="topitembar02" class="topbar_grid">		
			<select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select>
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addAuthority(true);"/>
		</div>
		<div id="baseconfiggrid"></div>
	</div>
	<input type="hidden" id="hidden_useAuthority_val" value=""/>
</form>

<script type="text/javascript">

	var myGrid = new coviGrid();
	var objPopup;

	initPersonDirectorOfUnit();
	
	function initPersonDirectorOfUnit(){
		setSelect();		// Select Box 세팅
		
		setGrid();			// 그리드 세팅	
		setUseAuthority();		// 사용권한 히든 값 세팅
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[					
		                  {key:'SortKey', label:'<spring:message code="Cache.lbl_Sort"/>', width:'40', align:'center' ,sort:"asc"},	                 
		                  {key:'UserName', label:'<spring:message code="Cache.lbl_Specific_User"/>', width:'100', align:'center',
		                	  formatter:function () {
		      					return "<a onclick='updateAuthority(true, \""+ this.item.UserCode +"\"); return false;'>"+this.item.UserName+"</a>";
		      				}},
		                  {key:'UnitName',  label:'<spring:message code="Cache.lbl_apv_Assignmented_Dept"/>', width:'400', align:'left'},
		                  {key:'Description', label:'<spring:message code="Cache.lbl_Description"/>', width:'200', align:'left'}	                  
			      		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "baseconfiggrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	// 사용권한 히든 값 세팅
	function setUseAuthority(){
		document.getElementById("hidden_useAuthority_val").value = document.getElementById("selectUseAuthority").value;
		
		searchConfig();
	}
	
	// baseconfig 검색
	function searchConfig(){
		var useAuthority = document.getElementById("hidden_useAuthority_val").value;
	
		myGrid.page.pageNo = 1;	
		myGrid.bindGrid({
 			ajaxUrl:"/approval/admin/getPersonDirectorOfUnitList.do",
 			ajaxPars: {
 				"EntCode":useAuthority
 			},
 			onLoad:function(){
 				//아래 처리 공통화 할 것
 				coviInput.setSwitch();
 				//custom 페이징 추가
 				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid.fnMakeNavi("myGrid");
 			}
		});		
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addAuthority(pModal){
		var paramEntCode = $("#selectUseAuthority").val();
		objPopup = parent.Common.open("","addAuthority","<spring:message code='Cache.lbl_addAuthority'/>|||<spring:message code='Cache.lbl_apv_Specific_User_Manage'/>","/approval/admin/goPersonDirectorOfUnitSetPopup.do?mode=add&paramEntCode="+paramEntCode,"660px","520px","iframe",pModal,null,null,true);
		
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateAuthority(pModal, configkey){	
		var paramEntCode = $("#selectUseAuthority").val();
		objPopup = parent.Common.open("","updateAuthority","<spring:message code='Cache.lbl_updateAuthority'/>|||<spring:message code='Cache.lbl_apv_Specific_User_Manage'/>","/approval/admin/goPersonDirectorOfUnitSetPopup.do?mode=modify&paramEntCode="+paramEntCode+"&key="+configkey,"660px","520px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""), false);
	}
		
	// Select box 바인드
	function setSelect(){
		$("#selectUseAuthority").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/approval/common/getEntInfoListAssignData.do",			
			ajaxAsync:false,
			onchange: function(){
				setUseAuthority();
			}
		});
	}
</script>