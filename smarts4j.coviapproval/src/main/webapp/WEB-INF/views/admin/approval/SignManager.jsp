<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit">서명 관리</span>	
</h3>
<form id="form1">
    <div style="width:100%; min-height: 500px">
		<div id="topitembar02" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select>	
			&nbsp;&nbsp;										
			<select class="AXSelect" name="sel_Search" id="sel_Search" >					
				<option value="UR_Name"><spring:message code="Cache.lbl_USER_NAME_01"/></option>
				<option value="DEPT_Name"><spring:message code="Cache.NumberFieldType_DeptName"/></option>					
				<option value="UR_Code"><spring:message code="Cache.lbl_User_Id"/></option>									
			</select>	
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" class="AXInput" />
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(1);" class="AXButton"/>							
		</div>	
		<div id="baseconfiggrid"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>
<script type="text/javascript">
	var EntCode;

	var myGrid = new coviGrid();

	initSignManager();

	function initSignManager(){
		setSelect();
		selSelectbind();
		setGrid();			// 그리드 세팅
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	            
		                  {key:'DEPT_Name', label:'<spring:message code="Cache.NumberFieldType_DeptName"/>', width:'200', align:'left', sort:"asc"},
		                  {key:'UR_Code',  label:'<spring:message code="Cache.lbl_User_Id"/>', width:'100', align:'center'},
		                  {key:'UR_Name', label:'<spring:message code="Cache.lbl_User"/>', width:'100', align:'center',
		                	  formatter:function () {
			      					return "<a onclick='updateConfig(true, \""+ this.item.UR_Code +"\"); return false;'>"+this.item.UR_Name+"</a>";
			      		  }},
		                  {key:'JobTitleName',  label:'<spring:message code="Cache.lbl_JobTitle"/>', width:'100', align:'center'},
		                  {key:'JobLevelName',  label:'<spring:message code="Cache.lbl_UserProfile_04"/>', width:'100', align:'center'},
		                  {key:'USER_SIGN',  label:'<spring:message code="Cache.lbl_Sign_Reg"/>', width:'150', align:'center'}
		             ];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();			
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
	
	// baseconfig 검색
	function searchConfig(flag){
		var EntCode = $("#selectUseAuthority").val(); 		
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();	
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/admin/getSignList.do",
				ajaxPars: {
					"EntCode":EntCode,				
					"sel_Search":sel_Search,
					"search":search				
				},
				onLoad:function(){
					$("#hidden_domain_val").val(EntCode);
					//아래 처리 공통화 할 것
					//custom 페이징 추가
					$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    	myGrid.fnMakeNavi("myGrid");
				}
		});
	}	

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){
		parent.Common.open("","updatebaseconfig","<spring:message code='Cache.lbl_apv_Regisign'/>|||<spring:message code='Cache.lbl_apv_sign_msg'/>","/approval/admin/goSignManagerSetPopup.do?mode=modify&key="+configkey+"&domain="+$("#hidden_domain_val").val(),"450px","250px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	//엔터검색
	function cmdSearch(){
		searchConfig(1);
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
				searchConfig();
			}
		});
		
	}
	//axisj selectbox변환
	function selSelectbind(){
		//검색selectbind
		$("#sel_Search").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		
	}
</script>