<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit">양식분류 관리</span>	
</h3>
<form id="form1">
    <div style="width:100%;min-height: 400px">
		<div id="topitembar02" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addConfig(true);"/>
			
			&nbsp;
			<label for="selectUseAuthority"><spring:message code="Cache.lbl_Domain"/>:</label>
			<select name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select>
		</div>	
		<div id="GridView1"></div>
	</div>	
</form>
<script type="text/javascript">

	var myGrid = new coviGrid();
	var objPopup;
	
	initFormClassList();

	function initFormClassList(){
		$("#selectUseAuthority").coviCtrl("setSelectOption", "/approval/common/getEntInfoListData.do"); //, {"type" : "ID"} 
		$("#selectUseAuthority").bindSelect({
			onchange: function(){
				searchConfig();
			}
		});
		setGrid();			// 그리드 세팅	
		searchConfig();
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정1
		var headerData =[					
		                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_Sort"/>', width:'50', align:'center', sort:"asc"},	                 
		                  {key:'FormClassName', label:'<spring:message code="Cache.lbl_apv_Name"/>', width:'250', align:'left',
		                	formatter:function(){
		                		var setClick = false;
		                		if(this.item.ModifyAcl == "Y"){ setClick = true; }
		                		return "<a onclick='updateConfig(true, \""+ this.item.FormClassID +"\", "+setClick+"); return false;'>"+CFN_GetDicInfo(this.item.FormClassName)+"</a>";
		                	}  
		                  },
		                  {key:'EntName',  label:'<spring:message code="Cache.lbl_apv_chage_ent"/>', width:'150', align:'left'},
		                  {key:'DisplayName',  label:'<spring:message code="Cache.lbl_aclTarget"/>', width:'250', align:'left'}
			      		];	
		
		myGrid.setGridHeader(headerData);		
		setGridConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "GridView1",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",			
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			colHead:{},
			body:{
				 onclick: function(){
					     //toast.push(Object.toJSON({index:this.index, r:this.r, c:this.c, item:this.item}))	
					 }			
			},
			notFixedWidth : 1
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	// baseconfig 검색
	function searchConfig(){
		var DomainId = $("#selectUseAuthority").val();	
		myGrid.bindGrid({
			ajaxUrl:"/approval/admin/getFormClassList.do",
 			ajaxPars:{
 				"DomainID" : DomainId
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
	
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey, setClick){
		if(setClick){
			objPopup = parent.Common.open("","updateConfig","<spring:message code='Cache.lbl_CateMng'/>|||<spring:message code='Cache.lbl_apv_ClassManage_instruction'/>","/approval/admin/goFormClassPopup.do?mode=modify&configkey="+configkey,"550px","350px","iframe",pModal,null,null,true);
		}else{
			Common.Warning("<spring:message code='Cache.lbl_noAuth'/>");//권한이 없습니다.
		}
		//objPopup.close(); 
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addConfig(pModal){		
		objPopup = parent.Common.open("","addbaseconfig","<spring:message code='Cache.lbl_CateMng'/>|||<spring:message code='Cache.lbl_apv_ClassManage_instruction'/>","/approval/admin/goFormClassPopup.do?mode=add","550px","350px","iframe",pModal,null,null,true);
		//objPopup.close(); 
	}
	
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
</script>