<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit">결재알림 관리</span>	
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
		<div id="topitembar02" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>			
			&nbsp;&nbsp;&nbsp;&nbsp;												
			<select class="AXSelect"  name="sel_State" id="sel_State" >
				<option selected="selected" value="">상태-전체</option>
				<option value="Y">Y</option>
				<option value="N">N</option>
				<option value="E">E</option>				
			</select>				
			&nbsp;&nbsp;&nbsp;&nbsp;				
			<select class="AXSelect" name="sel_Search" id="sel_Search" >
				<option selected="selected" value="Sender">Sender</option>
				<option value="Subject">Subject</option>
				<option value="Recipients">Recipients</option>	
			</select>	
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" class="AXInput" />
			&nbsp;&nbsp;&nbsp;&nbsp;												
			<input class="AXInput" id="startdate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="enddate">
		   	    ~ 				   	   
			<input class="AXInput" id="enddate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startdate">
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(1);" class="AXButton"/>
		</div>	
		<div id="baseconfiggrid"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>

<script type="text/javascript">
	
	var myGrid = new coviGrid();
	initMailMgr();

	function initMailMgr(){		
		selSelectbind();
		setGrid();			// 그리드 세팅			
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	            
		                  {key:'MailID', label:'MailID', width:'100', align:'left'},
		                  {key:'Sender',  label:'Sender', width:'100', align:'left'},	                	  
		                  {key:'Subject', label:'Subject', width:'200', align:'left',
		                	  formatter:function () {	                  
			      					return "<a onclick='updateConfig(true, \""+ this.item.MailID +"\"); return false;'>"+this.item.Subject+"</a>";
			      		  }},
		                  {key:'Recipients',  label:'Recipients', width:'100', align:'left', sort:false},
		                  {key:'SendYN',  label:'SendYN', width:'100', align:'center'},
		                  {key:'InsertDate',  label:'InsertDate', width:'150', align:'center' , sort:"desc"},
		                  {key:'ProcessID', label:'ProcessID', width:'100', align:'left'},
		                  {key:'ErrorMessage', label:'ErrorMessage', width:'100', align:'left', sort:false}	  
			      		];
		
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
		var sel_State = $("#sel_State").val();	
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();		
		var startdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/admin/getMailMgrList.do",
				ajaxPars: {					
					"sel_State":sel_State,
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
		parent.Common.open("","updatebaseconfig","전자결재알림","/approval/admin/goMailDetail.do?mode=modify&key="+configkey,"650px","690px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	//엔터검색
	function cmdSearch(){
		searchConfig(1);
	}
	
	//axisj selectbox변환
	function selSelectbind(){
		//상태selectbind
		$("#sel_State").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		
		//검색selectbind
		$("#sel_Search").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
		
	}
</script>