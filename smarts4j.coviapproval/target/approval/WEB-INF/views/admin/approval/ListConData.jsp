<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<script type="text/javascript">

	$(document).ready(function (){
		setGrid();			// 그리드 세팅			
	});
	
	// 헤더 설정
	var headerData =[	            
	                  {key:'IDX', label:'순번', width:'100', align:'center'},
	                  {key:'DocID',  label:'FormInstID', width:'300', align:'left'},	                  
	                  {key:'InterfaceID',  label:'InterfaceID', width:'100', align:'center'},
	                  {key:'InitiatorID', label:'기안자', width:'100', align:'center'},
	                  {key:'exsistErr',  label:'오류', width:'200', align:'center', sort:"desc"},
	                  {key:'RegDate', label:'받은시간', width:'200', align:'center'}	                  
		      		];
	
	var myGrid = new coviGrid();
	
	//그리드 세팅
	function setGrid(){
		myGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();
		$("#sel_State").change(function(){
			searchConfig();
	    });		
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
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();		
		var startdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		myGrid.bindGrid({
				ajaxUrl:"admin/getConDataLogLegacy.do",
				ajaxPars: {					
					"sel_Search":sel_Search,
					"search":search,					
					"startdate":startdate,
					"enddate":enddate
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
	function updateConfig(pModal, configkey){
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	//엔터검색
	function cmdSearch(){
		searchConfig(1);
	}
	
</script>
<h3 class="con_tit_box">
	<span class="con_tit">연동시스템 수신로그</span>	
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
		<div id="topitembar02" class="topbar_grid">
			<label>
				<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>	
				&nbsp;&nbsp;											
			</label>			
			<label>	
				검색			
				<select class="AXSelect" name="sel_Search" id="sel_Search" >
					<option value="">검색조건</option>
					<option value='DocID' >FormInstID</option>
					<option value="InterfaceID">InsterfaceID</option>
                	<option value='ErrMsg'>본문</option>			
				</select>	
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" class="AXInput" />
				&nbsp;&nbsp;&nbsp;&nbsp;			
			</label>			
			<label>
				조회기간			
				<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
				<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 85px" class="AXInput" />
				<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(1);" class="AXButton"/>
			</label>
		</div>	
		<div id="baseconfiggrid"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>