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
		<span id="title" class="con_tit"></span>
	</h3>
	<form id="form1">
		<div style="margin-bottom: 20px;">
			<span id="folderPath" style="font-size: 20px; font-weight: bold; display: none; padding-top: 20px"></span>
		</div>
		
		<div id="topitembar01" class="topbar_grid">
			<input type="button" value="<spring:message code='Cache.btn_apv_refresh' />" onclick="refresh();" class="AXButton BtnRefresh"/> <!-- 새로고침 -->
			<input type="button" class="AXButton BtnAdd" onclick="addScheduleFolderData();" value="<spring:message code='Cache.btn_Add' />"/><!-- 추가 -->
			<input type="button" class="AXButton BtnDelete" onclick="deleteData();" value="<spring:message code='Cache.btn_delete' />" /><!-- 삭제 -->
			<input type="button" class="AXButton" onclick="" value="<spring:message code='Cache.btn_CacheApply' />" /><!-- 캐시 적용 --><!-- TODO: 캐시 관련 사항 개발 완료 후 진행 -->
		</div>
		<div id="topitembar02" class="topbar_grid">
			<select name="" class="AXSelect" id="selectSearchType">
				<option value="MultiDisplayName" selected="selected"><spring:message code='Cache.lbl_ScheduleNm' /></option> <!-- 일정명 -->
				<option value="OwnerCode"><spring:message code='Cache.lbl_Operator' /></option> <!-- 운영자 -->
				<option value="RegisterCode"><spring:message code='Cache.lbl_Register' /></option> <!-- 등록자 -->
			</select>
			<input type="text" id="searchValue" class="AXInput" onKeyDown="onKeyDown();">
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchListData();" class="AXButton"/>
		</div>
		<div id="folderListGrid" ></div>
	</form>
</body>

<script type="text/javascript">
	var FolderID = CFN_GetQueryString("FolderID") == "undefined" ? Common.getBaseConfig("ScheduleTotalFolderID") : CFN_GetQueryString("FolderID");
	var lang = Common.getSession("lang");
	var ListGrid;
	
	initContent();
	
	function initContent(){
		$("#selectSearchType").bindSelect();
		
		// 폴더에 대한 명칭 가져오기
		getFolderTitle();
		
		// 그리드 그리기
		setGrid();
	}
	
	function getFolderTitle(){
		$.ajax({
		    url: "/groupware/schedule/getFolderDisplayName.do",
		    type: "POST",
		    data: {
				"FolderID":FolderID,
				"lang":lang
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS")
		    		//$("#title").html(res.value);
		    		$("#folderPath").html(res.value).show();
		    },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/getFolderDisplayName.do", response, status, error);
			}
		});
	}
	
	function setGrid(){
		ListGrid = new coviGrid();
		
		setGridConfig();
		searchListData();
	}
	
	function setGridConfig(){
		var headerData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		                 	  {key:'DefaultColor', label:'<spring:message code="Cache.lbl_DefaultColor"/>', width:'80', align:'center',					// 기본 컬러
									formatter:function(){
										var htmlStr = "";
										
										if(this.item.DefaultColor != "" && this.item.DefaultColor != undefined){
											htmlStr += "<span id='pDefaultColor' style='background-color:"+this.item.DefaultColor+";float: left;display: inline;width: 80px;height: 25px;'>";
											//htmlStr += "<a><img id='btnChangeColor' src='/HtmlSite/smarts4j_n/covicore/resources/images/covision/trn.gif' style='width: 80px;height:25px;'></a>";
											htmlStr += "</span>";
										}
										
										return htmlStr;
									}
							   },
			                  {key:'MultiDisplayName', label:'<spring:message code="Cache.lbl_ScheduleNm"/>', width:'200', align:'center'},				// 일정명
			                  {key:'ManageCompanyName', label:'<spring:message code="Cache.lbl_MngCompany"/>', width:'100', align:'center'},			// 관리회사
			                  {key:'OwnerCode', label:'<spring:message code="Cache.lbl_Operator"/>', width:'100', align:'center'},						// 운영자
			                  {key:'RegisterCode', label:'<spring:message code="Cache.lbl_Register"/>', width:'100', align:'center'},					// 등록자
			                  {key:'IsUse', label:'<spring:message code="Cache.lbl_Use"/>', width:'50', align:'center'},								// 사용
			                  {key:'SortKey', label:'<spring:message code="Cache.lbl_Sort"/>', width:'50', align:'center', sort:'asc'},					// 정렬
			                  {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDateHour"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', 
			                	  formatter: function(){
			                		  return CFN_TransLocalTime(this.item.RegistDate);
			                	  }
			                  }				// 등록일시
			                  ];
			                  
		ListGrid.setGridHeader(headerData);
		var configObj = {
			targetID : "folderListGrid",
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
					 setScheduleManuActive(this);
					 addScheduleFolderData(this.item.FolderID);
				 }
			}
		};
		
		ListGrid.setGridConfig(configObj);
	}
	
	function searchListData(){
		var selectSearchType = $("#selectSearchType").val();	
		var searchValue = $("#searchValue").val();
		
		ListGrid.bindGrid({
			ajaxUrl:"/groupware/schedule/getAdminFolderList.do",
			ajaxPars: {
				"FolderID":FolderID,
				"selectSearchType":selectSearchType,
				"searchValue":searchValue,
				"lang":lang,
				"DomainID": $("#selectDomain").val()
			}
		});
	}
	
	function onKeyDown()
	{
	     if(event.keyCode == 13)
	     {
	    	 searchListData();
	    	 event.preventDefault();
	     }
	}
	
	//데이터 삭제 버튼
	function deleteData(){
		var checkList = ListGrid.getCheckedList(0);
		var isIncludeFolder = false;
		
		if(checkList.length > 0){
			//폴더가 있을 경우 하위데이터 모두 삭제할지 확인
			$(checkList).each(function(){
				if(this.FolderType == "Folder"){
					isIncludeFolder = true;
				}
			});
			
			if(isIncludeFolder){
				Common.Confirm("<spring:message code='Cache.msg_DeleteFailFDQ'/>", "Confirm", function(result){
					if(result)
						doDeleteData(checkList);
				});
			}else{
				doDeleteData(checkList);
			}
			
		}else{
			Common.Warning("<spring:message code='Cache.msg_270'/>");		//삭제할 대상이 없습니다.
		}
	}
	
	function doDeleteData(checkList){
		$.ajax({
		    url: "/groupware/schedule/deleteAdminFolderData.do",
		    type: "POST",
		    data: {
				"folderData":JSON.stringify(checkList)
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		            Common.Inform("<spring:message code='Cache.msg_Deleted'/>", "Information", function(){
		            	searchListData();
		            });
		    	}else{
		    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
		    	}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/deleteAdminFolderData.do", response, status, error);
			}
		});
	}
	
	function refresh() {
		searchListData();
	}
</script>