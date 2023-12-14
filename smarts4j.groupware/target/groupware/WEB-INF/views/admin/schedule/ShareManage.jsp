<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/groupware/resources/script/admin/scheduleAdmin.js<%=resourceVersion%>" ></script>
<body>
	<h3 class="con_tit_box">
		<span class="con_tit"><spring:message code='Cache.CN_138' /></span>
	</h3>
	<form id="form1">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" value="<spring:message code='Cache.btn_AddShare' />" onclick="addShareScheduleData();" class="AXButton BtnAdd"/>	<!-- 공유 추가 -->
			<input type="button" class="AXButton BtnDelete" onclick="deleteShareScheduleData();" value="<spring:message code='Cache.btn_delete' />" /><!-- 삭제 -->
			<input type="button" value="<spring:message code='Cache.btn_apv_refresh' />" onclick="refresh();" class="AXButton BtnRefresh"/> <!-- 새로고침 -->
		</div>
		<div id="topitembar02" class="topbar_grid">
			<select name="" class="AXSelect" id="selectSearchType">
				<option value="SpecifierCode" selected="selected"><spring:message code='Cache.lbl_ShareSpecifier' /></option> <!-- 공유 등록자 -->
				<option value="TargetCode"><spring:message code='Cache.lbl_ShareTarget' /></option> <!-- 공유 대상자 -->
			</select>
			<input type="text" id="shareUserName" class="AXInput" onKeyDown="onKeyDown();">&nbsp;&nbsp;&nbsp;
			
			<spring:message code="Cache.lbl_SharingPeriod"/> &nbsp;<!-- 공유 기간 -->
			<input class="AXInput" id="startDate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="endDate">
		   	    ~ 				   	   
			<input class="AXInput" id="endDate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startDate">
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchListData();" class="AXButton"/>
		</div>
		<div id="shareListGrid" ></div>
	</form>
</body>
<script type="text/javascript">
	var ListGrid = new coviGrid();
	
	initContent();
	
	function initContent(){
		$("#selectSearchType").bindSelect();
		
		setGrid();
	};
	
	function setGrid(){
		ListGrid = new coviGrid();
		
		setGridConfig();
		searchListData();
	}
	
	function setGridConfig(){
		var headerData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		                 {key:'SpecifierCode', label:'<spring:message code="Cache.lbl_ShareSpecifier"/>', width:'100', align:'center', sort:"desc",				// 공유 등록자
								  formatter:function(){
									  return CFN_GetDicInfo(this.item.SpecifierName) + "("+ this.item.SpecifierCode +")";
								  }
		                 	  },
			                  {key:'TargetData', label:'<spring:message code="Cache.lbl_ShareTarget"/>', width:'200', align:'center'}];				 						// 공유 대상자
			                  
		ListGrid.setGridHeader(headerData);
		var configObj = {
			targetID : "shareListGrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			onLoad:function(){
			},
			body:{
				 onclick: function(){
					 addShareScheduleData(this.item.SpecifierCode);
				 }
			}
		};
		
		ListGrid.setGridConfig(configObj);
	}
	
	function searchListData(){
		var domainID = $("#selectDomain").val();
		var selectSearchType = $("#selectSearchType").val();	
		var shareUserName = $("#shareUserName").val();
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		
		ListGrid.bindGrid({
			ajaxUrl:"/groupware/schedule/getAdminShareList.do",
			ajaxPars: {
				"domainID":domainID,
				"selectSearchType":selectSearchType,
				"shareUserName":shareUserName,
				"startDate":startDate,
				"endDate":endDate
			}
		});
	}
	
	function onKeyDown()
	{
	     if(event.keyCode == 13)
	     {
	    	 searchListData();
	     }
	}
	
	function addShareScheduleData(shareID){
		Common.open("","updateConfig","<spring:message code='Cache.lbl_AddEditShare' />","/groupware/schedule/adminSharePopup.do?ShareID="+shareID,"570px","370px","iframe",true,null,null,true);
	}
	
	function deleteShareScheduleData(){
		var checkList = ListGrid.getCheckedList(0);
		
		if(checkList.length > 0){
			Common.Confirm("<spring:message code='Cache.msg_AreYouDelete'/>", "Confirm", function(result){
				if(result){
					var specifierCode = checkList[0].SpecifierCode;
					
					$.ajax({
					    url: "/groupware/schedule/deleteAdminShareData.do",
					    type: "POST",
					    data: {
					    	"mode":"U",
					    	"SpecifierCode":specifierCode
						},
					    success: function (res) {
				            Common.Inform("<spring:message code='Cache.msg_Deleted'/>", "Information", function(){
				            	parent.searchListData();
				            	//Common.Close();
				            });
				        },
				        error:function(response, status, error){
							CFN_ErrorAjax("/groupware/schedule/deleteAdminShareData.do", response, status, error);
						}
					});
				}
			});
		}else{
			Common.Warning("<spring:message code='Cache.msg_270'/>");		//삭제할 대상이 없습니다.
		}
	}
	
	function refresh(){
		searchListData();
	}
</script>